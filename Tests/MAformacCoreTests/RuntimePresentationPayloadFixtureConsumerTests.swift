import XCTest
@testable import MAformacCore

final class RuntimePresentationPayloadFixtureConsumerTests: XCTestCase {
    func testPublicRuntimePresentationPayloadFixtureMapsToPresentationSnapshot() throws {
        let snapshot = try RuntimePresentationPayloadFixtureConsumer.consume(Self.validPayload())

        XCTAssertEqual(snapshot.traceId, "trace-payload")
        XCTAssertEqual(snapshot.storeCells.map(\.key), ["ac.power"])
        XCTAssertEqual(snapshot.storeCells.first?.actualValue, "on")
        XCTAssertEqual(snapshot.storeCells.first?.revision, 2)
        XCTAssertEqual(snapshot.storeCells.first?.visualState, .satisfied)
        XCTAssertEqual(snapshot.activeCells[.ac], "ac.power")
        XCTAssertNil(snapshot.refusedCell)
        XCTAssertEqual(snapshot.scopeOrigins["ac.power"], .explicit)
        XCTAssertEqual(snapshot.orbState, .speak)
        XCTAssertEqual(snapshot.voiceState, .speaking)
        XCTAssertEqual(snapshot.dialogText, "空调已打开")
        XCTAssertEqual(snapshot.readbacks.first?.spokenText, "空调已打开")
        XCTAssertEqual(snapshot.resultKind, .acceptedToolCall)
        XCTAssertEqual(snapshot.proofClass, .localMock)
    }

    func testConsumerRejectsUnknownTopLevelPayloadFields() {
        let payload = Self.validPayload(extraTopLevel: #""timestamp": 0,"#)

        XCTAssertThrowsError(try RuntimePresentationPayloadFixtureConsumer.consume(payload)) { error in
            XCTAssertEqual(
                error as? RuntimePresentationPayloadFixtureConsumerError,
                .unknownTopLevelField("timestamp")
            )
        }
    }

    func testConsumerRejectsUnknownNestedPayloadFields() {
        let payload = Self.validPayload(extraCardField: #""rawNestedField": "x","#)

        XCTAssertThrowsError(try RuntimePresentationPayloadFixtureConsumer.consume(payload)) { error in
            XCTAssertEqual(
                error as? RuntimePresentationPayloadFixtureConsumerError,
                .unknownNestedField(path: "cards[]", field: "rawNestedField")
            )
        }
    }

    func testConsumerRejectsUnknownSchemaProofOutcomeAndReconciliationValues() {
        XCTAssertThrowsError(
            try RuntimePresentationPayloadFixtureConsumer.consume(Self.validPayload(schemaVersion: "r5_runtime_presentation_payload_v2"))
        ) { error in
            XCTAssertEqual(
                error as? RuntimePresentationConsumerValidationError,
                .unknownPayloadSchema("r5_runtime_presentation_payload_v2")
            )
        }

        XCTAssertThrowsError(
            try RuntimePresentationPayloadFixtureConsumer.consume(Self.validPayload(proofClass: "runtime_ready"))
        ) { error in
            XCTAssertEqual(
                error as? RuntimePresentationConsumerValidationError,
                .unknownProofClass("runtime_ready")
            )
        }

        XCTAssertThrowsError(
            try RuntimePresentationPayloadFixtureConsumer.consume(Self.validPayload(outcomeResult: "production_runtime"))
        ) { error in
            XCTAssertEqual(
                error as? RuntimePresentationPayloadFixtureConsumerError,
                .unknownResultKind("production_runtime")
            )
        }

        XCTAssertThrowsError(
            try RuntimePresentationPayloadFixtureConsumer.consume(Self.validPayload(reconciliationStatus: "runtime_ready"))
        ) { error in
            XCTAssertEqual(
                error as? RuntimePresentationConsumerValidationError,
                .unknownReconciliationStatus("runtime_ready")
            )
        }
    }

    func testProofClassMappingsAreExplicitAndDoNotPromoteMainlineProofs() throws {
        let expectedProofClasses: [String: PresentationProofClass] = [
            "docs_local": .staticPreview,
            "openspec_contract": .staticPreview,
            "local_static_contract": .staticPreview,
            "local_unit": .localMock,
            "local_shape_no_model": .staticPreview,
            "local_receipt_consistency": .staticPreview,
            "simulator_mock": .simulatorMock,
            "external_gptpro_review": .operatorReview
        ]

        XCTAssertEqual(Set(RuntimePresentationConsumerMapping.d15ProofClassNames), Set(expectedProofClasses.keys))

        for (mainlineName, expectedProofClass) in expectedProofClasses {
            let snapshot = try RuntimePresentationPayloadFixtureConsumer.consume(Self.validPayload(proofClass: mainlineName))
            XCTAssertEqual(snapshot.proofClass, expectedProofClass, mainlineName)
        }
    }

    func testConsumerRejectsForbiddenPrivateAndDurableMarkersAnywhereInFixture() {
        XCTAssertThrowsError(
            try RuntimePresentationPayloadFixtureConsumer.consume(Self.validPayload(extraTopLevel: #""requestFingerprint": "x","#))
        ) { error in
            XCTAssertEqual(
                error as? RuntimePresentationConsumerValidationError,
                .forbiddenPrivateName("requestFingerprint")
            )
        }

        XCTAssertThrowsError(
            try RuntimePresentationPayloadFixtureConsumer.consume(Self.validPayload(outcomeReason: "RuntimeAdapterBox leaked"))
        ) { error in
            XCTAssertEqual(
                error as? RuntimePresentationConsumerValidationError,
                .forbiddenPrivateName("RuntimeAdapterBox")
            )
        }

        XCTAssertThrowsError(
            try RuntimePresentationPayloadFixtureConsumer.consume(Self.validPayload(outcomeReason: "runtimeadapterbox leaked"))
        ) { error in
            XCTAssertEqual(
                error as? RuntimePresentationConsumerValidationError,
                .forbiddenPrivateName("RuntimeAdapterBox")
            )
        }

        for name in RuntimePresentationConsumerMapping.forbiddenPrivateNames {
            XCTAssertFalse(RuntimePresentationConsumerMapping.payloadFieldNames.contains(name), name)
            XCTAssertFalse(RuntimePresentationConsumerMapping.d15ProofClassNames.contains(name), name)
            XCTAssertFalse(RuntimePresentationConsumerMapping.proofCaps.contains(name), name)
        }
    }

    func testCommittedCrossRepoPublicFixturesDecodeToPresentationSnapshots() throws {
        let snapshots = Dictionary(
            uniqueKeysWithValues: try Self.expectedFixtureNames.map { fixtureName in
                (
                    fixtureName,
                    try RuntimePresentationPayloadFixtureConsumer.consume(
                        try Data(contentsOf: Self.fixtureURL(fixtureName))
                    )
                )
            }
        )

        let acPower = try XCTUnwrap(snapshots[Self.fixtureName])
        XCTAssertEqual(acPower.traceId, "trace-public-1")
        XCTAssertEqual(acPower.storeCells.map(\.key), ["ac.power"])
        XCTAssertEqual(acPower.activeCells[.ac], "ac.power")
        XCTAssertEqual(acPower.scopeOrigins["ac.power"], .explicit)
        XCTAssertEqual(acPower.dialogText, "空调已打开")
        XCTAssertEqual(acPower.readbacks.first?.spokenText, "空调已打开")
        XCTAssertEqual(acPower.resultKind, .acceptedToolCall)
        XCTAssertEqual(acPower.proofClass, .localMock)

        let refusal = try XCTUnwrap(snapshots["refusal_safety_public_payload.v1.json"])
        XCTAssertEqual(refusal.storeCells.map(\.key), ["door.lock"])
        XCTAssertEqual(refusal.storeCells.first?.visualState, .unsafe)
        XCTAssertTrue(refusal.activeCells.isEmpty)
        XCTAssertEqual(refusal.refusedCell, "door.lock")
        XCTAssertEqual(refusal.dialogText, "safety_policy_refusal")
        XCTAssertEqual(refusal.resultKind, .refusalSafetyOrPolicy)
        XCTAssertEqual(refusal.proofClass, .localMock)

        let runtimeError = try XCTUnwrap(snapshots["runtime_error_public_payload.v1.json"])
        XCTAssertEqual(runtimeError.storeCells.map(\.key), ["ac.power"])
        XCTAssertTrue(runtimeError.activeCells.isEmpty)
        XCTAssertNil(runtimeError.refusedCell)
        XCTAssertEqual(runtimeError.dialogText, "execution_error")
        XCTAssertEqual(runtimeError.resultKind, .runtimeError)
        XCTAssertEqual(runtimeError.proofClass, .localMock)

        let mismatch = try XCTUnwrap(snapshots["reconciliation_mismatch_public_payload.v1.json"])
        XCTAssertEqual(mismatch.activeCells[.ac], "ac.power")
        XCTAssertEqual(mismatch.dialogText, "ac state was not verified")
        XCTAssertEqual(mismatch.readbacks.first?.actualValue, "off")
        XCTAssertEqual(mismatch.resultKind, .acceptedToolCall)
        XCTAssertEqual(mismatch.proofClass, .localMock)

        let partial = try XCTUnwrap(snapshots["partial_accept_refuse_public_payload.v1.json"])
        XCTAssertEqual(partial.storeCells.map(\.key), ["ac.power", "door.lock"])
        XCTAssertEqual(partial.activeCells[.ac], "ac.power")
        XCTAssertEqual(partial.refusedCell, "door.lock")
        XCTAssertEqual(partial.dialogText, "ac opened")
        XCTAssertEqual(partial.resultKind, .partialAcceptPartialRefuse)
        XCTAssertEqual(partial.proofClass, .localMock)
    }

    func testCommittedCrossRepoFixtureSha256AndPublicFieldManifest() throws {
        let manifest = try Self.loadManifest()
        XCTAssertEqual(manifest.schemaVersion, "r5_runtime_presentation_payload_fixture_manifest_v1")
        XCTAssertEqual(Set(manifest.fixtures.map(\.name)), Self.expectedFixtureNames)

        for fixture in manifest.fixtures {
            let fixtureURL = Self.fixtureURL(fixture.name)
            let fixtureData = try Data(contentsOf: fixtureURL)
            let fixtureText = try XCTUnwrap(String(data: fixtureData, encoding: .utf8))
            let fixtureObject = try Self.loadJSONObject(fixtureData)

            XCTAssertEqual(fixture.schemaVersion, "r5_runtime_presentation_payload_v1", fixture.name)
            XCTAssertEqual(try C6Hash.fileHash(url: fixtureURL), fixture.sha256, fixture.name)
            XCTAssertEqual(fixture.producerRepo, "MAformac", fixture.name)
            XCTAssertEqual(fixture.consumerRepo, "MAformac-uiue", fixture.name)
            XCTAssertEqual(fixture.producerPath, "Tests/Fixtures/RuntimePresentationPayload/\(fixture.name)", fixture.name)
            XCTAssertEqual(fixture.consumerPath, "Tests/Fixtures/RuntimePresentationPayload/\(fixture.name)", fixture.name)
            XCTAssertEqual(fixture.proofClass, "local_unit", fixture.name)
            XCTAssertEqual(Set(fixtureObject.keys), Set(RuntimePresentationConsumerMapping.payloadFieldNames), fixture.name)
            XCTAssertFalse(fixtureObject.keys.contains("timestamp"), fixture.name)

            for marker in RuntimePresentationConsumerMapping.forbiddenPrivateNames {
                XCTAssertNil(fixtureText.range(of: marker, options: [.caseInsensitive, .diacriticInsensitive]), "\(fixture.name): \(marker)")
            }
        }
    }

    private static let fixtureName = "ac_power_public_payload.v1.json"

    private static let expectedFixtureNames: Set<String> = [
        fixtureName,
        "refusal_safety_public_payload.v1.json",
        "runtime_error_public_payload.v1.json",
        "reconciliation_mismatch_public_payload.v1.json",
        "partial_accept_refuse_public_payload.v1.json"
    ]

    private static var manifestURL: URL {
        fixturesDirectory.appendingPathComponent("manifest.json")
    }

    private static var fixturesDirectory: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Fixtures/RuntimePresentationPayload")
    }

    private static func fixtureURL(_ fixtureName: String) -> URL {
        fixturesDirectory.appendingPathComponent(fixtureName)
    }

    private static func loadJSONObject(_ data: Data) throws -> [String: Any] {
        guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw FixtureError.invalidJSONObject
        }
        return object
    }

    private static func loadManifest() throws -> FixtureManifest {
        try JSONDecoder().decode(FixtureManifest.self, from: try Data(contentsOf: manifestURL))
    }

    private struct FixtureManifest: Decodable {
        var schemaVersion: String
        var fixtures: [FixtureManifestEntry]
    }

    private struct FixtureManifestEntry: Decodable {
        var name: String
        var schemaVersion: String
        var sha256: String
        var producerRepo: String
        var producerPath: String
        var consumerRepo: String
        var consumerPath: String
        var proofClass: String
        var notes: [String]
    }

    private enum FixtureError: Error {
        case invalidJSONObject
    }

    private static func validPayload(
        schemaVersion: String = "r5_runtime_presentation_payload_v1",
        proofClass: String = "local_unit",
        outcomeResult: String = "accepted_tool_call",
        outcomeReason: String = "readback_verified",
        reconciliationStatus: String = "verified",
        extraTopLevel: String = "",
        extraCardField: String = ""
    ) -> Data {
        Data(
            """
            {
              \(extraTopLevel)
              "schemaVersion": "\(schemaVersion)",
              "traceID": "trace-payload",
              "turnID": "turn-1",
              "eventID": "event-1",
              "isTerminal": true,
              "outcome": {
                "result": "\(outcomeResult)",
                "reason": "\(outcomeReason)"
              },
              "proofClass": "\(proofClass)",
              "cards": [
                {
                  \(extraCardField)
                  "key": "ac.power",
                  "actualValue": "on",
                  "availability": "available",
                  "timestamp": 0,
                  "source": "mock",
                  "revision": 2,
                  "visualState": "satisfied"
                }
              ],
              "cardSemantics": [
                {
                  "cellKey": "ac.power",
                  "role": "accepted",
                  "scopeOrigin": "explicit",
                  "reason": "user_requested",
                  "isActive": true,
                  "siblingKeys": []
                }
              ],
              "readbacks": [
                {
                  "key": "ac.power",
                  "actualValue": "on",
                  "revision": 2,
                  "spokenText": "空调已打开",
                  "scopeOrigin": "explicit"
                }
              ],
              "reconciliation": {
                "status": "\(reconciliationStatus)",
                "readbackKey": "ac.power",
                "safeReason": "readback_verified"
              },
              "traceEnvelope": {
                "traceID": "trace-payload",
                "entries": []
              }
            }
            """.utf8
        )
    }
}

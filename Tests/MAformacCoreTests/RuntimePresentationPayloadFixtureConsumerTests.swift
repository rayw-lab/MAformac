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

        for name in RuntimePresentationConsumerMapping.forbiddenPrivateNames {
            XCTAssertFalse(RuntimePresentationConsumerMapping.payloadFieldNames.contains(name), name)
            XCTAssertFalse(RuntimePresentationConsumerMapping.d15ProofClassNames.contains(name), name)
            XCTAssertFalse(RuntimePresentationConsumerMapping.proofCaps.contains(name), name)
        }
    }

    func testCommittedCrossRepoPublicFixtureDecodesToPresentationSnapshot() throws {
        let data = try Data(contentsOf: Self.fixtureURL)
        let snapshot = try RuntimePresentationPayloadFixtureConsumer.consume(data)

        XCTAssertEqual(snapshot.traceId, "trace-public-1")
        XCTAssertEqual(snapshot.storeCells.map(\.key), ["ac.power"])
        XCTAssertEqual(snapshot.storeCells.first?.actualValue, "on")
        XCTAssertEqual(snapshot.activeCells[.ac], "ac.power")
        XCTAssertEqual(snapshot.scopeOrigins["ac.power"], .explicit)
        XCTAssertEqual(snapshot.dialogText, "空调已打开")
        XCTAssertEqual(snapshot.readbacks.first?.spokenText, "空调已打开")
        XCTAssertEqual(snapshot.resultKind, .acceptedToolCall)
        XCTAssertEqual(snapshot.proofClass, .localMock)
    }

    func testCommittedCrossRepoFixtureSha256AndPublicFieldManifest() throws {
        let manifest = try Self.loadManifest()
        let fixture = try XCTUnwrap(manifest.fixtures.first { $0.name == Self.fixtureName })
        let fixtureData = try Data(contentsOf: Self.fixtureURL)
        let fixtureText = try XCTUnwrap(String(data: fixtureData, encoding: .utf8))
        let fixtureObject = try Self.loadJSONObject(fixtureData)

        XCTAssertEqual(fixture.sha256, Self.fixtureSHA256)
        XCTAssertEqual(try C6Hash.fileHash(url: Self.fixtureURL), fixture.sha256)
        XCTAssertEqual(Set(fixtureObject.keys), Set(RuntimePresentationConsumerMapping.payloadFieldNames))
        XCTAssertFalse(fixtureObject.keys.contains("timestamp"))

        for marker in RuntimePresentationConsumerMapping.forbiddenPrivateNames {
            XCTAssertFalse(fixtureText.contains(marker), marker)
        }
    }

    private static let fixtureName = "ac_power_public_payload.v1.json"
    private static let fixtureSHA256 = "57951e0811bbb75f9a21516df41295ed1619e18ee6d804ac1ef1b21055cdff8f"

    private static var fixtureURL: URL {
        fixturesDirectory.appendingPathComponent(fixtureName)
    }

    private static var manifestURL: URL {
        fixturesDirectory.appendingPathComponent("manifest.json")
    }

    private static var fixturesDirectory: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Fixtures/RuntimePresentationPayload")
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

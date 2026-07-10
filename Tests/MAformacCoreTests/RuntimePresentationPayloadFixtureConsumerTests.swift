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

    func testConsumerRejectsCardTimestampsBecausePublicProjectionStripsThem() {
        let payload = Self.validPayload(extraCardField: #""timestamp": 0,"#)

        XCTAssertThrowsError(try RuntimePresentationPayloadFixtureConsumer.consume(payload)) { error in
            XCTAssertEqual(
                error as? RuntimePresentationPayloadFixtureConsumerError,
                .unknownNestedField(path: "cards[]", field: "timestamp")
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
        let expectedProofClasses: [String: StagePresentationProofClass] = [
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
        XCTAssertEqual(partial.storeCells.map(\.key), ["window.position[主驾]", "ac.power"])
        XCTAssertEqual(partial.activeCells[.ac], "ac.power")
        XCTAssertEqual(partial.refusedCell, "window.position[主驾]")
        XCTAssertEqual(partial.dialogText, "ac opened")
        XCTAssertEqual(partial.resultKind, .partialAcceptPartialRefuse)
        XCTAssertEqual(partial.proofClass, .localMock)

        let window = try XCTUnwrap(snapshots[RuntimeFixtureName.windowPosition])
        XCTAssertEqual(window.storeCells.map(\.key), ["window.position[主驾]"])
        XCTAssertEqual(window.activeCells[.window], "window.position[主驾]")
        XCTAssertEqual(window.scopeOrigins["window.position[主驾]"], .explicit)
        XCTAssertEqual(window.dialogText, "主驾车窗开度100%")
        XCTAssertEqual(window.readbacks.first?.actualValue, "100")
        XCTAssertEqual(window.resultKind, .acceptedToolCall)
        XCTAssertEqual(window.proofClass, .localMock)

        let screen = try XCTUnwrap(snapshots[RuntimeFixtureName.screenBrightness])
        XCTAssertEqual(screen.storeCells.map(\.key), ["screen.brightness[中控屏]"])
        XCTAssertEqual(screen.activeCells[.screen], "screen.brightness[中控屏]")
        XCTAssertEqual(screen.scopeOrigins["screen.brightness[中控屏]"], .explicit)
        XCTAssertEqual(screen.dialogText, "中控屏亮度80%")
        XCTAssertEqual(screen.resultKind, .acceptedToolCall)
        XCTAssertEqual(screen.proofClass, .localMock)

        let ambient = try XCTUnwrap(snapshots[RuntimeFixtureName.ambientBrightness])
        XCTAssertEqual(ambient.storeCells.map(\.key), ["ambient.brightness[面发光氛围灯]"])
        XCTAssertEqual(ambient.activeCells[.ambient], "ambient.brightness[面发光氛围灯]")
        XCTAssertEqual(ambient.scopeOrigins["ambient.brightness[面发光氛围灯]"], .explicit)
        XCTAssertEqual(ambient.dialogText, "面发光氛围灯亮度40%")
        XCTAssertEqual(ambient.resultKind, .acceptedToolCall)
        XCTAssertEqual(ambient.proofClass, .localMock)

        let noop = try XCTUnwrap(snapshots[RuntimeFixtureName.windowPositionNoop])
        XCTAssertEqual(noop.storeCells.map(\.key), ["window.position[主驾]"])
        XCTAssertEqual(noop.activeCells[.window], "window.position[主驾]")
        XCTAssertEqual(noop.dialogText, "主驾车窗开度100%")
        XCTAssertEqual(noop.readbacks.first?.revision, 1)
        XCTAssertEqual(noop.resultKind, .acceptedToolCall)
        XCTAssertEqual(noop.proofClass, .localMock)
    }

    func testCommittedCrossRepoFixtureSha256AndPublicFieldManifest() throws {
        let manifest = try Self.loadManifest()
        let schema = try Self.loadSharedSchema()

        XCTAssertEqual(manifest.schemaVersion, schema.manifestSchemaVersion)
        XCTAssertEqual(manifest.sharedSchema.name, "public_fixture_schema.v1.json")
        XCTAssertEqual(manifest.sharedSchema.schemaVersion, schema.schemaVersion)
        XCTAssertEqual(manifest.sharedSchema.ownerRepo, "MAformac")
        XCTAssertEqual(manifest.sharedSchema.ownerPath, schema.ownerPath)
        XCTAssertEqual(manifest.sharedSchema.consumerRepo, "MAformac-uiue")
        XCTAssertEqual(manifest.sharedSchema.consumerPath, schema.ownerPath)
        XCTAssertEqual(try C6Hash.fileHash(url: Self.sharedSchemaURL), manifest.sharedSchema.sha256)
        XCTAssertEqual(Set(manifest.fixtures.map(\.name)), Set(schema.fixtureNames))
        XCTAssertEqual(manifest.fixtures.count, schema.fixtureCount)

        for fixture in manifest.fixtures {
            let fixtureURL = Self.fixtureURL(fixture.name)
            let fixtureData = try Data(contentsOf: fixtureURL)
            let fixtureText = try XCTUnwrap(String(data: fixtureData, encoding: .utf8))
            let fixtureObject = try Self.loadJSONObject(fixtureData)

            XCTAssertEqual(fixture.schemaVersion, schema.payloadSchemaVersion, fixture.name)
            XCTAssertEqual(try C6Hash.fileHash(url: fixtureURL), fixture.sha256, fixture.name)
            XCTAssertEqual(fixture.producerRepo, "MAformac", fixture.name)
            XCTAssertEqual(fixture.consumerRepo, "MAformac-uiue", fixture.name)
            XCTAssertEqual(fixture.producerPath, "Tests/Fixtures/RuntimePresentationPayload/\(fixture.name)", fixture.name)
            XCTAssertEqual(fixture.consumerPath, "Tests/Fixtures/RuntimePresentationPayload/\(fixture.name)", fixture.name)
            XCTAssertTrue(schema.allowedProofClasses.contains(fixture.proofClass), fixture.name)
            XCTAssertTrue(Set(schema.allowedFixtureClasses).contains(fixture.fixtureClass), fixture.name)
            XCTAssertTrue(Set(schema.allowedResults).contains(fixture.result), fixture.name)
            XCTAssertEqual(fixture.result, try Self.fixtureResult(fixtureData), fixture.name)
            XCTAssertNotNil(RuntimePresentationConsumerMapping.localResultKind(forMainlineResultName: fixture.result), fixture.name)
            let expectedMetadata = try XCTUnwrap(Self.expectedManifestMetadata[fixture.name], fixture.name)
            XCTAssertEqual(fixture.caseID, expectedMetadata.caseID, fixture.name)
            XCTAssertEqual(fixture.fixtureClass, expectedMetadata.fixtureClass, fixture.name)
            XCTAssertEqual(fixture.result, expectedMetadata.result, fixture.name)
            XCTAssertEqual(fixture.familyCoverage, expectedMetadata.familyCoverage, fixture.name)
            if fixture.fixtureClass == "runtime_generated_fixture" {
                XCTAssertEqual(fixture.proofClass, "local_unit", fixture.name)
            }
            XCTAssertEqual(Set(fixtureObject.keys), Set(schema.publicTopLevelFields), fixture.name)
            for field in schema.forbiddenTopLevelFields {
                XCTAssertFalse(fixtureObject.keys.contains(field), fixture.name)
            }
            for card in (fixtureObject["cards"] as? [[String: Any]]) ?? [] {
                for field in schema.forbiddenCardFields {
                    XCTAssertFalse(card.keys.contains(field), fixture.name)
                }
            }

            for marker in schema.privateDurableRawMarkers {
                XCTAssertNil(fixtureText.range(of: marker, options: [.caseInsensitive, .diacriticInsensitive]), "\(fixture.name): \(marker)")
            }
        }
    }

    func testSharedPublicFixtureSchemaIsMainOwnedAndMappedByUIUEConsumer() throws {
        let schema = try Self.loadSharedSchema()

        XCTAssertEqual(schema.schemaVersion, "r5_runtime_presentation_public_fixture_schema_v1")
        XCTAssertEqual(schema.ownerRepo, "MAformac")
        XCTAssertEqual(schema.ownerPath, "Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json")
        XCTAssertEqual(schema.manifestSchemaVersion, "r5_runtime_presentation_payload_fixture_manifest_v1")
        XCTAssertEqual(schema.payloadSchemaVersion, "r5_runtime_presentation_payload_v1")
        XCTAssertEqual(schema.fixtureCount, Self.expectedFixtureNames.count)
        XCTAssertEqual(Set(schema.fixtureNames), Self.expectedFixtureNames)
        XCTAssertEqual(Set(schema.allowedFixtureClasses), Self.allowedFixtureClasses)
        XCTAssertEqual(Set(schema.allowedProofClasses), ["local_unit"])
        XCTAssertEqual(Set(schema.requiredManifestFields), Self.requiredManifestFields)
        XCTAssertEqual(Set(schema.publicTopLevelFields), Set(RuntimePresentationConsumerMapping.payloadFieldNames))
        XCTAssertEqual(Set(schema.forbiddenTopLevelFields), ["timestamp"])
        XCTAssertEqual(Set(schema.forbiddenCardFields), ["timestamp"])
        XCTAssertEqual(schema.traceEntryTimestampPolicy, "allowed_only_inside_traceEnvelope.entries")
        XCTAssertTrue(
            Set(schema.privateDurableRawMarkers).isSubset(of: Set(RuntimePresentationConsumerMapping.forbiddenPrivateNames))
        )
        XCTAssertEqual(schema.proofClassCeiling, "local_unit_static_fixture_contract_only")
        XCTAssertTrue(schema.nonClaims.contains("runtime_ready"))
        XCTAssertTrue(schema.nonClaims.contains("uiue_merge"))

        for result in schema.allowedResults {
            XCTAssertNotNil(RuntimePresentationConsumerMapping.localResultKind(forMainlineResultName: result), result)
        }
    }

    func testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable() throws {
        let schema = try Self.loadSharedSchema()
        let mainFixtureDirectory = Self.repoRoot
            .deletingLastPathComponent()
            .appendingPathComponent("MAformac/Tests/Fixtures/RuntimePresentationPayload")

        guard FileManager.default.fileExists(atPath: mainFixtureDirectory.path) else {
            throw XCTSkip("sibling main repo fixture directory is not available in this checkout")
        }

        for fileName in ["manifest.json", "public_fixture_schema.v1.json"] + schema.fixtureNames {
            let uiueURL = Self.fixturesDirectory.appendingPathComponent(fileName)
            let mainURL = mainFixtureDirectory.appendingPathComponent(fileName)
            XCTAssertEqual(try C6Hash.fileHash(url: uiueURL), try C6Hash.fileHash(url: mainURL), fileName)
        }
    }

    private static let fixtureName = "ac_power_public_payload.v1.json"

    private static let expectedFixtureNames: Set<String> = [
        fixtureName,
        "refusal_safety_public_payload.v1.json",
        "runtime_error_public_payload.v1.json",
        "reconciliation_mismatch_public_payload.v1.json",
        "partial_accept_refuse_public_payload.v1.json",
        RuntimeFixtureName.windowPosition,
        RuntimeFixtureName.screenBrightness,
        RuntimeFixtureName.ambientBrightness,
        RuntimeFixtureName.windowPositionNoop
    ]

    private enum RuntimeFixtureName {
        static let windowPosition = "window_position_runtime_public_payload.v1.json"
        static let screenBrightness = "screen_brightness_runtime_public_payload.v1.json"
        static let ambientBrightness = "ambient_brightness_runtime_public_payload.v1.json"
        static let windowPositionNoop = "window_position_noop_runtime_public_payload.v1.json"
    }

    private static let allowedFixtureClasses: Set<String> = [
        "runtime_generated_fixture",
        "bridge_contract_fixture"
    ]

    private static let requiredManifestFields: Set<String> = [
        "name",
        "schemaVersion",
        "caseID",
        "fixtureClass",
        "result",
        "familyCoverage",
        "sha256",
        "producerRepo",
        "producerPath",
        "consumerRepo",
        "consumerPath",
        "proofClass",
        "notes"
    ]

    private static let expectedManifestMetadata: [String: ManifestExpectation] = [
        fixtureName: ManifestExpectation(
            caseID: "D22-AC-POWER-ACCEPTED-BRIDGE-V1",
            fixtureClass: "bridge_contract_fixture",
            result: "accepted_tool_call",
            familyCoverage: ["ac.power"]
        ),
        "refusal_safety_public_payload.v1.json": ManifestExpectation(
            caseID: "D22-REFUSAL-SAFETY-BRIDGE-V1",
            fixtureClass: "bridge_contract_fixture",
            result: "refusal_safety_or_policy",
            familyCoverage: ["door.lock", "safety_refusal"]
        ),
        "runtime_error_public_payload.v1.json": ManifestExpectation(
            caseID: "D22-RUNTIME-ERROR-BRIDGE-V1",
            fixtureClass: "bridge_contract_fixture",
            result: "runtime_error",
            familyCoverage: ["ac.power", "runtime_error"]
        ),
        "reconciliation_mismatch_public_payload.v1.json": ManifestExpectation(
            caseID: "D22-RECONCILIATION-MISMATCH-BRIDGE-V1",
            fixtureClass: "bridge_contract_fixture",
            result: "accepted_tool_call",
            familyCoverage: ["ac.power", "reconciliation_mismatch"]
        ),
        "partial_accept_refuse_public_payload.v1.json": ManifestExpectation(
            caseID: "D22-PARTIAL-ACCEPT-REFUSE-BRIDGE-V1",
            fixtureClass: "bridge_contract_fixture",
            result: "partial_accept_partial_refuse",
            familyCoverage: ["ac.power", "window.position", "partial_accept_partial_refuse"]
        ),
        RuntimeFixtureName.windowPosition: ManifestExpectation(
            caseID: "D22-WINDOW-POSITION-ACCEPTED-RUNTIME-V1",
            fixtureClass: "runtime_generated_fixture",
            result: "accepted_tool_call",
            familyCoverage: ["window.position"]
        ),
        RuntimeFixtureName.screenBrightness: ManifestExpectation(
            caseID: "D22-SCREEN-BRIGHTNESS-ACCEPTED-RUNTIME-V1",
            fixtureClass: "runtime_generated_fixture",
            result: "accepted_tool_call",
            familyCoverage: ["screen.brightness"]
        ),
        RuntimeFixtureName.ambientBrightness: ManifestExpectation(
            caseID: "D22-AMBIENT-BRIGHTNESS-ACCEPTED-RUNTIME-V1",
            fixtureClass: "runtime_generated_fixture",
            result: "accepted_tool_call",
            familyCoverage: ["ambient.brightness"]
        ),
        RuntimeFixtureName.windowPositionNoop: ManifestExpectation(
            caseID: "D22-WINDOW-POSITION-NOOP-RUNTIME-V1",
            fixtureClass: "runtime_generated_fixture",
            result: "accepted_tool_call",
            familyCoverage: ["window.position", "already_state_noop"]
        )
    ]

    private static var manifestURL: URL {
        fixturesDirectory.appendingPathComponent("manifest.json")
    }

    private static var sharedSchemaURL: URL {
        fixturesDirectory.appendingPathComponent("public_fixture_schema.v1.json")
    }

    private static var fixturesDirectory: URL {
        repoRoot.appendingPathComponent("Tests/Fixtures/RuntimePresentationPayload")
    }

    private static var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
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

    private static func fixtureResult(_ data: Data) throws -> String {
        let object = try loadJSONObject(data)
        guard let outcome = object["outcome"] as? [String: Any],
              let result = outcome["result"] as? String else {
            throw FixtureError.invalidJSONObject
        }
        return result
    }

    private static func loadManifest() throws -> FixtureManifest {
        try JSONDecoder().decode(FixtureManifest.self, from: try Data(contentsOf: manifestURL))
    }

    private static func loadSharedSchema() throws -> PublicFixtureSchema {
        try JSONDecoder().decode(PublicFixtureSchema.self, from: try Data(contentsOf: sharedSchemaURL))
    }

    private struct FixtureManifest: Decodable {
        var schemaVersion: String
        var sharedSchema: SharedSchemaReference
        var fixtures: [FixtureManifestEntry]
    }

    private struct SharedSchemaReference: Decodable {
        var name: String
        var schemaVersion: String
        var ownerRepo: String
        var ownerPath: String
        var sha256: String
        var consumerRepo: String
        var consumerPath: String
        var updateRule: String
    }

    private struct FixtureManifestEntry: Decodable {
        var name: String
        var schemaVersion: String
        var caseID: String
        var fixtureClass: String
        var result: String
        var familyCoverage: [String]
        var sha256: String
        var producerRepo: String
        var producerPath: String
        var consumerRepo: String
        var consumerPath: String
        var proofClass: String
        var notes: [String]
    }

    private struct ManifestExpectation {
        var caseID: String
        var fixtureClass: String
        var result: String
        var familyCoverage: [String]
    }

    private struct PublicFixtureSchema: Decodable {
        var schemaVersion: String
        var ownerRepo: String
        var ownerPath: String
        var manifestSchemaVersion: String
        var payloadSchemaVersion: String
        var fixtureCount: Int
        var fixtureNames: [String]
        var allowedFixtureClasses: [String]
        var allowedProofClasses: [String]
        var allowedResults: [String]
        var requiredManifestFields: [String]
        var publicTopLevelFields: [String]
        var forbiddenTopLevelFields: [String]
        var forbiddenCardFields: [String]
        var traceEntryTimestampPolicy: String
        var privateDurableRawMarkers: [String]
        var proofClassCeiling: String
        var nonClaims: [String]
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

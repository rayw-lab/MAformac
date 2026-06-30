import Foundation
import XCTest
@testable import MAformacCore

final class RuntimePresentationPayloadPublicFixtureTests: XCTestCase {
    func testMainRuntimePresentationPayloadGeneratesCommittedPublicFixtureObject() throws {
        let fixtureObject = try Self.loadJSONObject(Self.fixtureURL)
        let generatedObject = try Self.generatedPublicFixtureObject()

        XCTAssertEqual(fixtureObject as NSDictionary, generatedObject as NSDictionary)
        XCTAssertEqual(Set(fixtureObject.keys), Self.publicTopLevelFields)
        XCTAssertFalse(fixtureObject.keys.contains("timestamp"))
    }

    @MainActor
    func testRuntimeGeneratedPublicFixturesMatchCommittedProjection() async throws {
        for fixtureCase in RuntimeFixtureCase.allCases {
            let fixtureURL = Self.fixturesDirectory.appendingPathComponent(fixtureCase.fixtureName)
            let fixtureObject = try Self.loadJSONObject(fixtureURL)
            let generated = try await Self.generatedRuntimeFixture(for: fixtureCase)

            XCTAssertEqual(fixtureObject as NSDictionary, generated.publicObject as NSDictionary, fixtureCase.fixtureName)
            XCTAssertTrue(
                generated.traceMessages.contains { $0.contains(fixtureCase.expectedExecuteMarker) },
                "\(fixtureCase.fixtureName): \(generated.traceMessages)"
            )
        }
    }

    func testPublicFixtureManifestCoversExpectedFixturesWithSha256s() throws {
        let manifest = try Self.loadManifest()
        let schema = try Self.loadSharedSchema()

        XCTAssertEqual(manifest.schemaVersion, schema.manifestSchemaVersion)
        XCTAssertEqual(manifest.sharedSchema.name, "public_fixture_schema.v1.json")
        XCTAssertEqual(manifest.sharedSchema.schemaVersion, schema.schemaVersion)
        XCTAssertEqual(manifest.sharedSchema.ownerRepo, schema.ownerRepo)
        XCTAssertEqual(manifest.sharedSchema.ownerPath, schema.ownerPath)
        XCTAssertEqual(manifest.sharedSchema.consumerRepo, "MAformac-uiue")
        XCTAssertEqual(manifest.sharedSchema.consumerPath, schema.ownerPath)
        XCTAssertEqual(
            try C6Hash.fileHash(url: Self.sharedSchemaURL),
            manifest.sharedSchema.sha256
        )
        XCTAssertEqual(Set(manifest.fixtures.map(\.name)), Set(schema.fixtureNames))
        XCTAssertEqual(manifest.fixtures.count, schema.fixtureCount)

        for fixture in manifest.fixtures {
            let fixtureURL = Self.fixturesDirectory.appendingPathComponent(fixture.name)

            XCTAssertEqual(fixture.schemaVersion, schema.payloadSchemaVersion, fixture.name)
            XCTAssertEqual(try C6Hash.fileHash(url: fixtureURL), fixture.sha256, fixture.name)
            XCTAssertEqual(fixture.producerRepo, "MAformac", fixture.name)
            XCTAssertEqual(fixture.consumerRepo, "MAformac-uiue", fixture.name)
            XCTAssertEqual(fixture.producerPath, "Tests/Fixtures/RuntimePresentationPayload/\(fixture.name)", fixture.name)
            XCTAssertEqual(fixture.consumerPath, "Tests/Fixtures/RuntimePresentationPayload/\(fixture.name)", fixture.name)
            XCTAssertTrue(schema.allowedProofClasses.contains(fixture.proofClass), fixture.name)
            XCTAssertTrue(Set(schema.allowedFixtureClasses).contains(fixture.fixtureClass), fixture.name)
            XCTAssertTrue(Set(schema.allowedResults).contains(fixture.result), fixture.name)
            XCTAssertEqual(fixture.result, try Self.fixtureResult(fixtureURL), fixture.name)
            let expectedMetadata = try XCTUnwrap(Self.expectedManifestMetadata[fixture.name], fixture.name)
            XCTAssertEqual(fixture.caseID, expectedMetadata.caseID, fixture.name)
            XCTAssertEqual(fixture.fixtureClass, expectedMetadata.fixtureClass, fixture.name)
            XCTAssertEqual(fixture.result, expectedMetadata.result, fixture.name)
            XCTAssertEqual(fixture.familyCoverage, expectedMetadata.familyCoverage, fixture.name)
        }
    }

    func testSharedPublicFixtureSchemaIsMainOwnedAndExpressibleByPublicTypes() throws {
        let schema = try Self.loadSharedSchema()
        let typedResults = Set(DemoRuntimeResult.allCases.map(\.rawValue))

        XCTAssertEqual(schema.schemaVersion, "r5_runtime_presentation_public_fixture_schema_v1")
        XCTAssertEqual(schema.ownerRepo, "MAformac")
        XCTAssertEqual(schema.ownerPath, "Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json")
        XCTAssertEqual(schema.manifestSchemaVersion, "r5_runtime_presentation_payload_fixture_manifest_v1")
        XCTAssertEqual(schema.payloadSchemaVersion, "r5_runtime_presentation_payload_v1")
        XCTAssertEqual(schema.fixtureCount, Self.expectedFixtureNames.count)
        XCTAssertEqual(Set(schema.fixtureNames), Self.expectedFixtureNames)
        XCTAssertEqual(Set(schema.allowedFixtureClasses), Self.allowedFixtureClasses)
        XCTAssertEqual(Set(schema.allowedProofClasses), ["local_unit"])
        XCTAssertTrue(Set(schema.allowedResults).isSubset(of: typedResults))
        XCTAssertEqual(Set(schema.requiredManifestFields), Self.requiredManifestFields)
        XCTAssertEqual(Set(schema.publicTopLevelFields), Self.publicTopLevelFields)
        XCTAssertEqual(Set(schema.forbiddenTopLevelFields), ["timestamp"])
        XCTAssertEqual(Set(schema.forbiddenCardFields), ["timestamp"])
        XCTAssertEqual(schema.traceEntryTimestampPolicy, "allowed_only_inside_traceEnvelope.entries")
        XCTAssertEqual(Set(schema.privateDurableRawMarkers), Set(Self.privateAndDurableMarkers))
        XCTAssertEqual(schema.proofClassCeiling, "local_unit_static_fixture_contract_only")
        XCTAssertTrue(schema.nonClaims.contains("runtime_ready"))
        XCTAssertTrue(schema.nonClaims.contains("uiue_merge"))
    }

    func testBridgeContractFixtureResultsArePublicRuntimeResults() throws {
        let manifest = try Self.loadManifest()
        let publicRuntimeResults = Set(DemoRuntimeResult.allCases.map(\.rawValue))

        for fixture in manifest.fixtures where fixture.fixtureClass == "bridge_contract_fixture" {
            XCTAssertTrue(publicRuntimeResults.contains(fixture.result), fixture.name)
            XCTAssertEqual(fixture.result, try Self.fixtureResult(Self.fixturesDirectory.appendingPathComponent(fixture.name)), fixture.name)
        }
    }

    func testPublicFixturesDecodeThroughMainPublicVocabularyTypes() throws {
        let manifest = try Self.loadManifest()
        let decoder = JSONDecoder()

        for fixture in manifest.fixtures {
            let data = try Data(contentsOf: Self.fixturesDirectory.appendingPathComponent(fixture.name))
            let envelope = try decoder.decode(PublicFixtureTypedEnvelope.self, from: data)

            XCTAssertEqual(envelope.schemaVersion, .v1, fixture.name)
            XCTAssertEqual(envelope.outcome.result.rawValue, fixture.result, fixture.name)
            XCTAssertEqual(envelope.proofClass.rawValue, fixture.proofClass, fixture.name)
            XCTAssertFalse(envelope.cards.isEmpty, fixture.name)
            XCTAssertEqual(envelope.traceEnvelope?.traceID, envelope.traceID, fixture.name)
        }
    }

    func testPublicFixturesContainOnlyPublicTopLevelFieldsAndNoPrivateOrDurableMarkers() throws {
        let schema = try Self.loadSharedSchema()

        for fixtureName in Self.expectedFixtureNames {
            let fixtureURL = Self.fixturesDirectory.appendingPathComponent(fixtureName)
            let text = try String(contentsOf: fixtureURL, encoding: .utf8)
            let fixtureObject = try Self.loadJSONObject(fixtureURL)

            XCTAssertEqual(Set(fixtureObject.keys), Set(schema.publicTopLevelFields), fixtureName)
            for field in schema.forbiddenTopLevelFields {
                XCTAssertFalse(fixtureObject.keys.contains(field), fixtureName)
            }
            for card in (fixtureObject["cards"] as? [[String: Any]]) ?? [] {
                for field in schema.forbiddenCardFields {
                    XCTAssertFalse(card.keys.contains(field), fixtureName)
                }
            }
            for marker in schema.privateDurableRawMarkers {
                XCTAssertNil(text.range(of: marker, options: [.caseInsensitive, .diacriticInsensitive]), "\(fixtureName): \(marker)")
            }
        }
    }

    func testNonHappyPathPublicFixturesCoverContractBoundaries() throws {
        let expectations: [String: (result: String, status: String, mismatchClass: String?)] = [
            "refusal_safety_public_payload.v1.json": (
                result: "refusal_safety_or_policy",
                status: "not_applicable",
                mismatchClass: nil
            ),
            "runtime_error_public_payload.v1.json": (
                result: "runtime_error",
                status: "unavailable",
                mismatchClass: nil
            ),
            "reconciliation_mismatch_public_payload.v1.json": (
                result: "accepted_tool_call",
                status: "mismatch",
                mismatchClass: "value_mismatch"
            ),
            "partial_accept_refuse_public_payload.v1.json": (
                result: "partial_accept_partial_refuse",
                status: "verified",
                mismatchClass: nil
            )
        ]

        for (fixtureName, expected) in expectations {
            let object = try Self.loadJSONObject(Self.fixturesDirectory.appendingPathComponent(fixtureName))
            let outcome = try XCTUnwrap(object["outcome"] as? [String: Any], fixtureName)
            let reconciliation = try XCTUnwrap(object["reconciliation"] as? [String: Any], fixtureName)

            XCTAssertEqual(outcome["result"] as? String, expected.result, fixtureName)
            XCTAssertEqual(reconciliation["status"] as? String, expected.status, fixtureName)
            XCTAssertEqual(reconciliation["mismatchClass"] as? String, expected.mismatchClass, fixtureName)
        }
    }

    private static let fixtureName = "ac_power_public_payload.v1.json"

    private static let expectedFixtureNames: Set<String> = [
        fixtureName,
        "refusal_safety_public_payload.v1.json",
        "runtime_error_public_payload.v1.json",
        "reconciliation_mismatch_public_payload.v1.json",
        "partial_accept_refuse_public_payload.v1.json",
        RuntimeFixtureCase.windowPosition.fixtureName,
        RuntimeFixtureCase.screenBrightness.fixtureName,
        RuntimeFixtureCase.ambientBrightness.fixtureName,
        RuntimeFixtureCase.windowPositionNoop.fixtureName
    ]

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
            familyCoverage: ["ac.power", "door.lock", "partial_accept_partial_refuse"]
        ),
        RuntimeFixtureCase.windowPosition.fixtureName: ManifestExpectation(
            caseID: "D22-WINDOW-POSITION-ACCEPTED-RUNTIME-V1",
            fixtureClass: "runtime_generated_fixture",
            result: "accepted_tool_call",
            familyCoverage: ["window.position"]
        ),
        RuntimeFixtureCase.screenBrightness.fixtureName: ManifestExpectation(
            caseID: "D22-SCREEN-BRIGHTNESS-ACCEPTED-RUNTIME-V1",
            fixtureClass: "runtime_generated_fixture",
            result: "accepted_tool_call",
            familyCoverage: ["screen.brightness"]
        ),
        RuntimeFixtureCase.ambientBrightness.fixtureName: ManifestExpectation(
            caseID: "D22-AMBIENT-BRIGHTNESS-ACCEPTED-RUNTIME-V1",
            fixtureClass: "runtime_generated_fixture",
            result: "accepted_tool_call",
            familyCoverage: ["ambient.brightness"]
        ),
        RuntimeFixtureCase.windowPositionNoop.fixtureName: ManifestExpectation(
            caseID: "D22-WINDOW-POSITION-NOOP-RUNTIME-V1",
            fixtureClass: "runtime_generated_fixture",
            result: "accepted_tool_call",
            familyCoverage: ["window.position", "already_state_noop"]
        )
    ]

    private static let publicTopLevelFields: Set<String> = [
        "schemaVersion",
        "traceID",
        "turnID",
        "eventID",
        "isTerminal",
        "outcome",
        "proofClass",
        "cards",
        "cardSemantics",
        "readbacks",
        "reconciliation",
        "traceEnvelope"
    ]

    private static let privateAndDurableMarkers = [
        "DemoRuntimeAdapter",
        "RuntimeAdapterBox",
        "durableLedger",
        "persistentLedger",
        "adapterLedger",
        "local_durable_adapter_ledger",
        "requestFingerprint",
        "parentRequestFingerprint",
        "failureLedger",
        "successLedger",
        "settledParentPlan",
        "runtimeStore",
        "rawRuntimeStore",
        "rawModelOutput",
        "trainingReceipt",
        "DemoForceStateContext"
    ]

    private static var fixtureURL: URL {
        fixturesDirectory.appendingPathComponent(fixtureName)
    }

    private static var manifestURL: URL {
        fixturesDirectory.appendingPathComponent("manifest.json")
    }

    private static var sharedSchemaURL: URL {
        fixturesDirectory.appendingPathComponent("public_fixture_schema.v1.json")
    }

    private static var fixturesDirectory: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Fixtures/RuntimePresentationPayload")
    }

    private static func generatedPublicFixtureObject() throws -> [String: Any] {
        let snapshot = PresentationSnapshot(
            traceID: "trace-public-1",
            runtimeOutcome: DemoRuntimeOutcome(result: .acceptedToolCall, reason: "readback_verified"),
            cards: [
                DemoVehicleStateCell(
                    key: "ac.power",
                    actualValue: "on",
                    timestamp: Date(timeIntervalSince1970: 0),
                    revision: 2,
                    visualState: .satisfied
                )
            ],
            cardSemantics: [
                PresentationCardSemantics(
                    cellKey: "ac.power",
                    role: .accepted,
                    scopeOrigin: .explicit,
                    reason: "user_requested",
                    isActive: true
                )
            ],
            readbacks: [
                DemoActionReadback(
                    key: "ac.power",
                    actualValue: "on",
                    revision: 2,
                    spokenText: "空调已打开",
                    scopeOrigin: .explicit
                )
            ],
            proofClass: .localUnit,
            traceEnvelope: TraceEnvelope(validatedTraceID: "trace-public-1", entries: []),
            isTerminal: true,
            timestamp: Date(timeIntervalSince1970: 0)
        )
        let payload = RuntimePresentationPayload(
            snapshot: snapshot,
            turnID: "turn-public-1",
            eventID: "event-public-1",
            reconciliation: PresentationReconciliation(
                status: .verified,
                readbackKey: "ac.power",
                safeReason: "readback_verified"
            )
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try publicJSONObject(from: payload, encoder: encoder)
    }

    @MainActor
    private static func generatedRuntimeFixture(for fixtureCase: RuntimeFixtureCase) async throws -> GeneratedRuntimeFixture {
        let store = DemoVehicleStateStore()
        for seedTransition in fixtureCase.seedTransitions {
            store.applyMockTransition(seedTransition)
        }
        let trace = InMemoryTraceLogger()
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try repoPipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            frameDecoder: { _ in fixtureCase.frame },
            timestampProvider: { Date(timeIntervalSince1970: 1_800_000_100) }
        )

        let payload = try await runner.run(text: fixtureCase.text)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return GeneratedRuntimeFixture(
            publicObject: try publicJSONObject(from: payload, encoder: encoder),
            traceMessages: trace.entries.map { "\($0.stage.rawValue):\($0.message)" }
        )
    }

    private static func publicJSONObject(from payload: RuntimePresentationPayload, encoder: JSONEncoder) throws -> [String: Any] {
        let encoded = try encoder.encode(payload)
        let rawObject = try loadJSONObject(encoded)
        let generatedFields = Set(rawObject.keys)
        let allowedGeneratedFields = publicTopLevelFields.union(["timestamp"])
        let unexpectedFields = generatedFields.subtracting(allowedGeneratedFields)
        if !unexpectedFields.isEmpty {
            throw FixtureError.unexpectedGeneratedFields(unexpectedFields.sorted())
        }

        var publicObject = rawObject.filter { publicTopLevelFields.contains($0.key) }
        if let cards = publicObject["cards"] as? [[String: Any]] {
            publicObject["cards"] = cards.map { card in
                var publicCard = card
                publicCard.removeValue(forKey: "timestamp")
                return publicCard
            }
        }
        if var traceEnvelope = publicObject["traceEnvelope"] as? [String: Any] {
            traceEnvelope["entries"] = []
            publicObject["traceEnvelope"] = traceEnvelope
        }
        return publicObject
    }

    private static func repoPipeline() throws -> C3ExecutionPipeline {
        C3ExecutionPipeline(
            semantic: try SemanticContractLookup(jsonl: readRepoFile("contracts/semantic-function-contract.jsonl")),
            stateCells: try StateCellContractLookup(yaml: readRepoFile("contracts/state-cells.yaml")),
            riskPolicy: try RiskPolicyLookup(yaml: readRepoFile("contracts/risk-policy.yaml")),
            allowlist: try L1DemoAllowlistLookup(yaml: readRepoFile("contracts/l1-demo-allowlist.yaml"))
        )
    }

    private static func readRepoFile(_ relativePath: String) throws -> String {
        let repoRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return try String(contentsOf: repoRoot.appendingPathComponent(relativePath), encoding: .utf8)
    }

    private static func loadJSONObject(_ url: URL) throws -> [String: Any] {
        try loadJSONObject(try Data(contentsOf: url))
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

    private static func loadSharedSchema() throws -> PublicFixtureSchema {
        try JSONDecoder().decode(PublicFixtureSchema.self, from: try Data(contentsOf: sharedSchemaURL))
    }

    private static func fixtureResult(_ url: URL) throws -> String {
        let object = try loadJSONObject(url)
        guard let outcome = object["outcome"] as? [String: Any],
              let result = outcome["result"] as? String else {
            throw FixtureError.invalidJSONObject
        }
        return result
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

    private struct PublicFixtureTypedEnvelope: Decodable {
        var schemaVersion: RuntimePresentationPayloadSchema
        var traceID: String
        var outcome: DemoRuntimeOutcome
        var proofClass: PresentationProofClass
        var cards: [PublicFixtureTypedCard]
        var readbacks: [DemoActionReadback]
        var reconciliation: PresentationReconciliation
        var traceEnvelope: TraceEnvelope?
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

    private struct PublicFixtureTypedCard: Decodable {
        var key: String
        var actualValue: String
        var desiredValue: String?
        var availability: DemoVehicleAvailability
        var source: DemoVehicleValueSource
        var revision: Int
        var visualState: DemoVisualState
    }

    private struct ManifestExpectation {
        var caseID: String
        var fixtureClass: String
        var result: String
        var familyCoverage: [String]
    }

    private struct GeneratedRuntimeFixture {
        var publicObject: [String: Any]
        var traceMessages: [String]
    }

    private enum RuntimeFixtureCase: CaseIterable {
        case windowPosition
        case screenBrightness
        case ambientBrightness
        case windowPositionNoop

        var fixtureName: String {
            switch self {
            case .windowPosition:
                return "window_position_runtime_public_payload.v1.json"
            case .screenBrightness:
                return "screen_brightness_runtime_public_payload.v1.json"
            case .ambientBrightness:
                return "ambient_brightness_runtime_public_payload.v1.json"
            case .windowPositionNoop:
                return "window_position_noop_runtime_public_payload.v1.json"
            }
        }

        var text: String {
            switch self {
            case .windowPosition:
                return "打开主驾车窗"
            case .screenBrightness:
                return "中控屏调亮一点"
            case .ambientBrightness:
                return "面发光氛围灯亮度调到40%"
            case .windowPositionNoop:
                return "主驾车窗保持全开"
            }
        }

        var frame: ToolCallFrame {
            switch self {
            case .windowPosition:
                return Self.frame(
                    id: "turn-d22-window-position-1",
                    traceID: "trace-d22-window-position-1",
                    device: "window",
                    actionPrimitive: "power_on",
                    slots: ["position": "主驾"]
                )
            case .screenBrightness:
                return Self.frame(
                    id: "turn-d22-screen-brightness-1",
                    traceID: "trace-d22-screen-brightness-1",
                    device: "screen_brightness",
                    actionPrimitive: "increase_by_exp",
                    slots: ["screen_type": "中控屏"],
                    value: ContractValue(ref: "CUR", direct: "+", offset: "LITTLE", type: "EXP")
                )
            case .ambientBrightness:
                return Self.frame(
                    id: "turn-d22-ambient-brightness-1",
                    traceID: "trace-d22-ambient-brightness-1",
                    device: "atmosphere_lamp_brightness",
                    actionPrimitive: "by_percent",
                    slots: ["name": "面发光氛围灯"],
                    value: ContractValue(ref: "ZERO", direct: "+", offset: "40", type: "PERCENT")
                )
            case .windowPositionNoop:
                return Self.frame(
                    id: "turn-d22-window-position-noop-1",
                    traceID: "trace-d22-window-position-noop-1",
                    device: "window",
                    actionPrimitive: "power_on",
                    slots: ["position": "主驾"]
                )
            }
        }

        var seedTransitions: [DemoMockTransition] {
            switch self {
            case .windowPositionNoop:
                return [DemoMockTransition(key: "window.position[主驾]", desiredValue: "100")]
            case .windowPosition, .screenBrightness, .ambientBrightness:
                return []
            }
        }

        var expectedExecuteMarker: String {
            switch self {
            case .windowPositionNoop:
                return "already_state_noop"
            case .windowPosition, .screenBrightness, .ambientBrightness:
                return "first_execution"
            }
        }

        private static func frame(
            id: String,
            traceID: String,
            device: String,
            actionPrimitive: String,
            slots: [String: String] = [:],
            value: ContractValue = ContractValue()
        ) -> ToolCallFrame {
            ToolCallFrame(
                id: id,
                traceID: traceID,
                agentID: "vehicle-control",
                capabilityID: "cabin.\(device)",
                toolName: "vehicle_control",
                device: device,
                actionPrimitive: actionPrimitive,
                slots: slots,
                value: value,
                stateRevision: 0,
                candidateSource: .upstreamToolCall
            )
        }
    }

    private enum FixtureError: Error {
        case invalidJSONObject
        case unexpectedGeneratedFields([String])
    }
}

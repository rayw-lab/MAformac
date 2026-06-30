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

    func testPublicFixtureManifestCoversExpectedFixturesWithSha256s() throws {
        let manifest = try Self.loadManifest()

        XCTAssertEqual(manifest.schemaVersion, "r5_runtime_presentation_payload_fixture_manifest_v1")
        XCTAssertEqual(Set(manifest.fixtures.map(\.name)), Self.expectedFixtureNames)

        for fixture in manifest.fixtures {
            let fixtureURL = Self.fixturesDirectory.appendingPathComponent(fixture.name)

            XCTAssertEqual(fixture.schemaVersion, "r5_runtime_presentation_payload_v1", fixture.name)
            XCTAssertEqual(try C6Hash.fileHash(url: fixtureURL), fixture.sha256, fixture.name)
            XCTAssertEqual(fixture.producerRepo, "MAformac", fixture.name)
            XCTAssertEqual(fixture.consumerRepo, "MAformac-uiue", fixture.name)
            XCTAssertEqual(fixture.producerPath, "Tests/Fixtures/RuntimePresentationPayload/\(fixture.name)", fixture.name)
            XCTAssertEqual(fixture.consumerPath, "Tests/Fixtures/RuntimePresentationPayload/\(fixture.name)", fixture.name)
            XCTAssertEqual(fixture.proofClass, "local_unit", fixture.name)
        }
    }

    func testPublicFixturesContainOnlyPublicTopLevelFieldsAndNoPrivateOrDurableMarkers() throws {
        for fixtureName in Self.expectedFixtureNames {
            let fixtureURL = Self.fixturesDirectory.appendingPathComponent(fixtureName)
            let text = try String(contentsOf: fixtureURL, encoding: .utf8)
            let fixtureObject = try Self.loadJSONObject(fixtureURL)

            XCTAssertEqual(Set(fixtureObject.keys), Self.publicTopLevelFields, fixtureName)
            XCTAssertFalse(fixtureObject.keys.contains("timestamp"), fixtureName)
            for marker in Self.privateAndDurableMarkers {
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
        "partial_accept_refuse_public_payload.v1.json"
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
        return publicObject
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
        case unexpectedGeneratedFields([String])
    }
}

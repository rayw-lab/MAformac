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

    func testPublicFixtureSha256IsRecordedInManifest() throws {
        let manifest = try Self.loadManifest()
        let fixture = try XCTUnwrap(manifest.fixtures.first { $0.name == Self.fixtureName })

        XCTAssertEqual(fixture.schemaVersion, "r5_runtime_presentation_payload_v1")
        XCTAssertEqual(fixture.sha256, Self.fixtureSHA256)
        XCTAssertEqual(try C6Hash.fileHash(url: Self.fixtureURL), fixture.sha256)
        XCTAssertEqual(fixture.producerRepo, "MAformac")
        XCTAssertEqual(fixture.consumerRepo, "MAformac-uiue")
    }

    func testPublicFixtureContainsNoPrivateOrDurableMarkers() throws {
        let text = try String(contentsOf: Self.fixtureURL, encoding: .utf8)

        for marker in Self.privateAndDurableMarkers {
            XCTAssertFalse(text.contains(marker), marker)
        }
    }

    private static let fixtureName = "ac_power_public_payload.v1.json"
    private static let fixtureSHA256 = "57951e0811bbb75f9a21516df41295ed1619e18ee6d804ac1ef1b21055cdff8f"

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

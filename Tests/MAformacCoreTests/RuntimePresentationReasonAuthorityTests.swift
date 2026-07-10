import Foundation
import XCTest
@testable import MAformacCore

final class RuntimePresentationReasonAuthorityTests: XCTestCase {
    func testGeneratedReasonAuthorityMatchesEveryT0Projection() throws {
        let registry = try Self.loadRegistry()

        XCTAssertEqual(Set(RuntimePresentationReasonAuthority.finiteReasons), Set(registry.finiteReasonEnum))
        XCTAssertEqual(
            Set(RuntimePresentationSafeReasonKind.allCases.map(\.rawValue)),
            Set(registry.reasonKindEnum)
        )

        for expected in registry.finiteReasonProjections {
            let actual = try XCTUnwrap(
                RuntimePresentationReasonAuthority.projection(forFiniteReason: expected.finiteReason),
                expected.finiteReason
            )
            XCTAssertEqual(actual.safeReasonKind.rawValue, expected.reasonKind)
            XCTAssertEqual(actual.result.rawValue, expected.bridgeResult)
        }
    }

    func testPublicPayloadNeverEncodesRawFiniteReason() throws {
        let registry = try Self.loadRegistry()

        for expected in registry.finiteReasonProjections {
            let traceID = "trace-public-reason-boundary"
            let trace = try XCTUnwrap(
                TraceEnvelope(
                    traceID: traceID,
                    entries: [
                        TraceEntry(
                            stage: .guard,
                            traceID: traceID,
                            message: "typed refusal",
                            attributes: TraceAttributes(
                                guardReason: expected.finiteReason,
                                finiteReason: expected.finiteReason
                            ),
                            timestamp: Date(timeIntervalSince1970: 1_800_001_000)
                        )
                    ]
                )
            )
            var payload = RuntimePresentationPayload(
                traceID: traceID,
                turnID: "turn-1",
                isTerminal: true,
                outcome: DemoRuntimeOutcome(result: .acceptedToolCall, reason: expected.finiteReason),
                proofClass: .localUnit,
                cards: [],
                cardSemantics: [
                    PresentationCardSemantics(
                        cellKey: "fallback.test",
                        role: .refused,
                        reason: expected.finiteReason
                    )
                ],
                reconciliation: PresentationReconciliation(
                    status: .notApplicable,
                    safeReason: expected.finiteReason
                ),
                traceEnvelope: trace,
                timestamp: Date(timeIntervalSince1970: 1_800_001_000)
            )

            // The serialization boundary must remain safe even after mutation of public value fields.
            payload.outcome.reason = expected.finiteReason
            payload.cardSemantics?[0].reason = expected.finiteReason
            payload.reconciliation.safeReason = expected.finiteReason
            payload.traceEnvelope = trace

            let data = try JSONEncoder().encode(payload)
            let text = try XCTUnwrap(String(data: data, encoding: .utf8))
            XCTAssertFalse(text.contains("\"finiteReason\""), text)

            let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
            let outcome = try XCTUnwrap(object["outcome"] as? [String: Any])
            XCTAssertEqual(outcome["result"] as? String, expected.bridgeResult)
            XCTAssertEqual(outcome["reason"] as? String, expected.reasonKind)

            let semantics = try XCTUnwrap((object["cardSemantics"] as? [[String: Any]])?.first)
            XCTAssertEqual(semantics["reason"] as? String, expected.reasonKind)

            let reconciliation = try XCTUnwrap(object["reconciliation"] as? [String: Any])
            XCTAssertEqual(reconciliation["safeReason"] as? String, expected.reasonKind)

            let envelope = try XCTUnwrap(object["traceEnvelope"] as? [String: Any])
            let entry = try XCTUnwrap((envelope["entries"] as? [[String: Any]])?.first)
            let attributes = try XCTUnwrap(entry["attributes"] as? [String: Any])
            XCTAssertNil(attributes["finiteReason"])
            XCTAssertEqual(attributes["guardReason"] as? String, expected.reasonKind)
        }
    }

    private static func loadRegistry() throws -> Registry {
        let repoRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let url = repoRoot
            .appendingPathComponent("openspec/changes/add-c1-demo-capability-governance/ownership-map.yaml")
        return try JSONDecoder().decode(Registry.self, from: Data(contentsOf: url))
    }

    private struct Registry: Decodable {
        let finiteReasonEnum: [String]
        let reasonKindEnum: [String]
        let finiteReasonProjections: [Projection]

        private enum CodingKeys: String, CodingKey {
            case finiteReasonEnum = "finiteReason_enum"
            case reasonKindEnum = "reasonKind_enum"
            case finiteReasonProjections = "finiteReason_projections"
        }
    }

    private struct Projection: Decodable {
        let finiteReason: String
        let reasonKind: String
        let bridgeResult: String

        private enum CodingKeys: String, CodingKey {
            case finiteReason
            case reasonKind
            case bridgeResult = "bridge_result"
        }
    }
}

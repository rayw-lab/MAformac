import XCTest
@testable import MAformacCore

final class RuntimePresentationBridgeTests: XCTestCase {
    func testBehaviorClassMapsToBridgeRuntimeResultWithoutRenamingC6Source() {
        XCTAssertEqual(DemoRuntimeResult(behaviorClass: .toolCall), .acceptedToolCall)
        XCTAssertEqual(DemoRuntimeResult(behaviorClass: .clarifyMissingSlot), .clarifyMissingSlot)
        XCTAssertEqual(DemoRuntimeResult(behaviorClass: .refusalNoAvailableTool), .refusalNoAvailableTool)
        XCTAssertEqual(DemoRuntimeResult(behaviorClass: .refusalSafetyOrPolicy), .refusalSafetyOrPolicy)
        XCTAssertEqual(DemoRuntimeResult(behaviorClass: .alreadyStateNoop), .alreadyStateNoop)

        let outcome = DemoRuntimeOutcome(behaviorClass: .toolCall)
        XCTAssertEqual(outcome.result, .acceptedToolCall)
        XCTAssertEqual(outcome.behaviorClassSource, .toolCall)
    }

    func testMissingScopeTravelsAsReasonNotCoreScopeOriginCase() {
        XCTAssertNil(ScopeOrigin(rawValue: "missing"))

        let snapshot = PresentationSnapshot(
            traceID: "trace-1",
            runtimeOutcome: DemoRuntimeOutcome(
                result: .clarifyMissingSlot,
                missingSlot: "direction",
                scopeFailureReason: "missing_required_scope"
            ),
            cards: [],
            scopeOrigin: nil,
            scopeFailureReason: "missing_required_scope",
            proofClass: .openspecContract,
            isTerminal: true
        )

        XCTAssertNil(snapshot.scopeOrigin)
        XCTAssertEqual(snapshot.scopeFailureReason, "missing_required_scope")
        XCTAssertEqual(snapshot.runtimeOutcome.missingSlot, "direction")
    }

    func testProofClassUnknownValuesFailClosedAndDoNotGrantReadinessClaims() throws {
        for proofClass in PresentationProofClass.allCases {
            XCTAssertTrue(proofClass.displayCaps.isEmpty)
        }

        let data = Data(#""runtime_ready""#.utf8)
        XCTAssertThrowsError(try JSONDecoder().decode(PresentationProofClass.self, from: data))
    }

    func testPresentationSnapshotIsCodableAndCarriesPresentationSafeTraceEnvelope() throws {
        let timestamp = Date(timeIntervalSince1970: 1_800_000_000)
        let traceEntry = TraceEntry(
            stage: .readback,
            traceID: "trace-2",
            message: "空调已打开",
            attributes: TraceAttributes(readbackResult: .verified),
            timestamp: timestamp
        )
        let readback = DemoActionReadback(
            key: "ac.power",
            actualValue: "on",
            revision: 1,
            spokenText: "空调已打开",
            scopeOrigin: .explicit
        )
        let snapshot = PresentationSnapshot(
            traceID: "trace-2",
            runtimeOutcome: DemoRuntimeOutcome(behaviorClass: .toolCall),
            cards: [
                DemoVehicleStateCell(key: "ac.power", actualValue: "on", revision: 1, visualState: .satisfied)
            ],
            dialogText: "已打开空调",
            readbacks: [readback],
            scopeOrigin: .explicit,
            voiceState: .unavailable,
            orbState: .speak,
            proofClass: .localUnit,
            traceEnvelope: TraceEnvelope(traceID: "trace-2", entries: [traceEntry]),
            isTerminal: true,
            timestamp: timestamp
        )

        let data = try JSONEncoder().encode(snapshot)
        let decoded = try JSONDecoder().decode(PresentationSnapshot.self, from: data)

        XCTAssertEqual(decoded, snapshot)
        XCTAssertEqual(decoded.traceEnvelope?.entries.first?.attributes.readbackResult, .verified)
    }
}

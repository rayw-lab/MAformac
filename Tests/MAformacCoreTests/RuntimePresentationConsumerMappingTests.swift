import XCTest
@testable import MAformacCore

final class RuntimePresentationConsumerMappingTests: XCTestCase {
    func testStableMainlineEventKindsExcludeTimeoutEventKind() {
        XCTAssertEqual(
            RuntimePresentationConsumerMapping.stableMainlineEventKinds,
            ["text_input", "mic_start", "mic_end", "card_tap", "cancel", "interruption"]
        )
        XCTAssertFalse(RuntimePresentationConsumerMapping.stableMainlineEventKinds.contains("timeout"))
    }

    func testStableMainlineEventSourcesAreSeparateFromScopeOrigin() {
        XCTAssertEqual(
            RuntimePresentationConsumerMapping.stableMainlineEventSources,
            ["user", "system", "demo_harness", "runtime_adapter"]
        )

        let scopeOriginNames = Set([ScopeOrigin.defaulted, .explicit, .fanout].map(\.rawValue))
        XCTAssertTrue(Set(RuntimePresentationConsumerMapping.stableMainlineEventSources).isDisjoint(with: scopeOriginNames))
    }

    func testRuntimeResultsMapFromStableMainlineNamesToExistingUIUESurfaces() {
        let expected: [(String, DemoRuntimeResultKind)] = [
            ("accepted_tool_call", .acceptedToolCall),
            ("clarify_missing_slot", .clarifyMissingSlot),
            ("refusal_no_available_tool", .refusalNoAvailableTool),
            ("refusal_safety_or_policy", .refusalSafetyOrPolicy),
            ("already_state_noop", .alreadyStateNoop),
            ("runtime_error", .runtimeError),
            ("cancelled", .cancelled),
            ("interrupted", .cancelled)
        ]

        XCTAssertEqual(RuntimePresentationConsumerMapping.resultEntries.map(\.mainlineResultName), expected.map(\.0))

        for (mainlineName, localKind) in expected {
            XCTAssertEqual(
                RuntimePresentationConsumerMapping.localResultKind(forMainlineResultName: mainlineName),
                localKind,
                mainlineName
            )
        }
    }

    func testRuntimeResultMappingUsesStructuredNamesRatherThanDisplayCopy() {
        for entry in RuntimePresentationConsumerMapping.resultEntries {
            XCTAssertEqual(entry.structuredSource, "mainline_structured_runtime_result")
            XCTAssertFalse(entry.mainlineResultName.contains("已"))
            XCTAssertFalse(entry.mainlineResultName.contains("为了安全"))
            XCTAssertTrue(DemoRuntimeResultPresentationMatrix.allEntries.map(\.motionKind).contains(entry.motionKind))
        }
    }

    func testTerminalStopsMapTimeoutToRuntimeErrorWithoutAddingTimeoutResult() {
        XCTAssertEqual(RuntimePresentationConsumerMapping.terminalStopResultNames["timeout"], "runtime_error")
        XCTAssertEqual(RuntimePresentationConsumerMapping.terminalStopResultNames["interrupted"], "interrupted")
        XCTAssertEqual(RuntimePresentationConsumerMapping.terminalStopResultNames["backgrounding"], "interrupted")
        XCTAssertNil(RuntimePresentationConsumerMapping.localResultKind(forMainlineResultName: "timeout"))
    }

    func testProofCapsStayAtDocsLocalUnitAndSimulatorMockOnly() {
        XCTAssertEqual(RuntimePresentationConsumerMapping.proofCaps, ["docs_local", "local_unit", "simulator_mock"])

        let forbiddenClaims = [
            "runtime_ready",
            "mobile",
            "true_device",
            "voice_ready",
            "model_ready",
            "golden_ready",
            "endpoint_ready",
            "UIUE_merge",
            "V" + "-PASS",
            "S" + "-PASS",
            "U" + "-PASS",
            "A-2" + " complete"
        ]

        for claim in forbiddenClaims {
            XCTAssertFalse(RuntimePresentationConsumerMapping.proofCaps.contains(claim), claim)
        }
    }

    func testDeferredGatesRemainMainlineOwned() throws {
        let deferredRows = ["C005", "C018", "C052", "C061"]

        for rowID in deferredRows {
            let row = try XCTUnwrap(RuntimePresentationConsumerMapping.disposition(for: rowID))
            XCTAssertEqual(row.disposition, .deferredMainlineOwner, rowID)
            XCTAssertNotEqual(row.owner, "UIUE", rowID)
        }
    }

    func testK1RowsRemainSpikeBeforeImplementationLedger() throws {
        let spikeRows = ["C082", "C083", "C096", "C117", "C182", "C197", "C207", "C208"]

        for rowID in spikeRows {
            let row = try XCTUnwrap(RuntimePresentationConsumerMapping.disposition(for: rowID))
            XCTAssertEqual(row.disposition, .spikeBeforeImplementation, rowID)
            XCTAssertEqual(row.owner, "future spike", rowID)
        }
    }

    func testC034ReduceMotionIsLocalPolicyOnly() throws {
        let row = try XCTUnwrap(RuntimePresentationConsumerMapping.disposition(for: "C034"))

        XCTAssertEqual(row.disposition, .localPolicyOnly)
        XCTAssertEqual(row.owner, "UIUE")
        XCTAssertEqual(PresentationReducedMotionPolicy.feedback(for: PresentationOrbState.think), .staticThinking)
        XCTAssertFalse(PresentationReducedMotionPolicy.allowsContinuousAnimation(reduceMotion: true))
    }
}

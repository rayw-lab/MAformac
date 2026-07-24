import Foundation
import XCTest
@testable import MAformacCore

final class DemoRuntimeSessionRunnerAtomicExecutionTests: XCTestCase {
    @MainActor
    func testMountedAndUnmountedPlanRefusesWholePlanBeforeMutation() async throws {
        let store = DemoVehicleStateStore()
        let before = store.cells
        let trace = InMemoryTraceLogger()
        let accepted = acPowerFrame(id: "accepted-ac", traceID: "trace-atomic")
        let refused = unmountedFragranceFrame(id: "refused-fragrance", traceID: "trace-atomic")
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try DemoRuntimeContractBundle.singleCommandDemoDefault.makePipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            // GOVERNANCE: bypasses NLU by design (not product behavior)
            planDecoder: { _ in try atomicRuntimePlan([accepted, refused]) }
        )

        let payload = try await runner.run(text: "打开空调并关闭香氛")

        XCTAssertEqual(payload.outcome.result, .refusalNoAvailableTool)
        XCTAssertEqual(payload.outcome.reason, RuntimePresentationSafeReasonKind.notAvailableInDemo.rawValue)
        XCTAssertTrue(payload.readbacks.isEmpty)
        XCTAssertEqual(store.cells, before)
        XCTAssertTrue(payload.traceEnvelope?.entries.contains {
            $0.message == "runtime_plan_policy:atomic"
        } == true)
        XCTAssertFalse(trace.entries.contains { $0.stage == .execute || $0.stage == .readback })

        let subactions = trace.entries.filter { $0.message.hasPrefix("partial_subaction:") }
        XCTAssertEqual(
            subactions.map(\.message),
            [
                "partial_subaction:accepted-ac:refused:tool_call_count=0:readback_count=0:state_mutation=false",
                "partial_subaction:refused-fragrance:refused:tool_call_count=0:readback_count=0:state_mutation=false",
            ]
        )
        XCTAssertEqual(subactions[0].attributes.finiteReason, .runtimeExecutionError)
        XCTAssertEqual(subactions[1].attributes.finiteReason, .unmountedToolName)
    }

    @MainActor
    func testSafetyDeniedSubactionRefusesWholePlanWithoutMutation() async throws {
        let store = DemoVehicleStateStore()
        _ = store.applyMockTransition(DemoMockTransition(key: "vehicle.speed", desiredValue: "12"))
        let before = store.cells
        let trace = InMemoryTraceLogger()
        let accepted = acPowerFrame(id: "accepted-ac", traceID: "trace-safety-atomic")
        let refused = safetyDeniedDoorFrame(id: "refused-door", traceID: "trace-safety-atomic")
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            // GOVERNANCE: bypasses NLU by design (not product behavior)
            planDecoder: { _ in try atomicRuntimePlan([accepted, refused]) }
        )

        let payload = try await runner.run(text: "打开空调并打开车门")

        XCTAssertEqual(payload.outcome.result, .refusalNoAvailableTool)
        XCTAssertTrue(payload.readbacks.isEmpty)
        XCTAssertEqual(store.cells, before)
        XCTAssertFalse(trace.entries.contains { $0.stage == .execute || $0.stage == .readback })
        let refusedEntry = try XCTUnwrap(
            trace.entries.first {
                $0.message == "partial_subaction:refused-door:refused:tool_call_count=0:readback_count=0:state_mutation=false"
            }
        )
        XCTAssertEqual(refusedEntry.attributes.finiteReason, .safetyOrPolicyRefusal)
    }

    @MainActor
    func testTwoAcceptedReviewedFramesProduceAcceptedOutcomeRatherThanPartialRefusal() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let power = acPowerFrame(id: "accepted-power", traceID: "trace-all-accepted")
        let temperature = acTemperatureFrame(id: "accepted-temperature", traceID: "trace-all-accepted")
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try DemoRuntimeContractBundle.singleCommandDemoDefault.makePipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            // GOVERNANCE: bypasses NLU by design (not product behavior)
            planDecoder: { _ in try atomicRuntimePlan([power, temperature]) }
        )

        let payload = try await runner.run(text: "打开空调并调到26度")

        XCTAssertEqual(payload.outcome.result, .acceptedToolCall)
        XCTAssertEqual(payload.outcome.reason, "readback_verified")
        XCTAssertNotEqual(payload.outcome.result, .partialAcceptPartialRefuse)
        XCTAssertEqual(payload.reconciliation.status, .verified)
        XCTAssertEqual(payload.readbacks.map(\.key), ["ac.power", "ac.temp_setpoint[主驾]"])
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, "26")
    }

    @MainActor
    func testTwoRefusedReviewedFramesProduceRefusalWithoutVerifiedReconciliation() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let first = unmountedFragranceFrame(id: "refused-fragrance-one", traceID: "trace-all-refused")
        let second = unmountedFragranceFrame(id: "refused-fragrance-two", traceID: "trace-all-refused")
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            // GOVERNANCE: bypasses NLU by design (not product behavior)
            planDecoder: { _ in try atomicRuntimePlan([first, second]) }
        )

        let payload = try await runner.run(text: "关闭两个未挂载香氛")

        XCTAssertEqual(payload.outcome.result, .refusalNoAvailableTool)
        XCTAssertEqual(
            payload.outcome.reason,
            RuntimePresentationSafeReasonKind.notAvailableInDemo.rawValue
        )
        XCTAssertNotEqual(payload.outcome.result, .partialAcceptPartialRefuse)
        XCTAssertEqual(payload.reconciliation.status, .notApplicable)
        XCTAssertTrue(payload.readbacks.isEmpty)
        XCTAssertEqual(store.currentRevision, 0)
        XCTAssertEqual(trace.entries.filter { $0.stage == .execute }.count, 0)
    }

    @MainActor
    func testMultipleReadbackFrameDoesNotLeakWhenSiblingIsRefused() async throws {
        let store = DemoVehicleStateStore()
        let before = store.cells
        let trace = InMemoryTraceLogger()
        let temperature = acTemperatureFrame(id: "accepted-temperature", traceID: "trace-multi-readback")
        let refused = unmountedFragranceFrame(id: "refused-fragrance", traceID: "trace-multi-readback")
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try DemoRuntimeContractBundle.singleCommandDemoDefault.makePipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            // GOVERNANCE: bypasses NLU by design (not product behavior)
            planDecoder: { _ in try atomicRuntimePlan([temperature, refused]) }
        )

        let payload = try await runner.run(text: "空调调到26度并关闭香氛")

        XCTAssertEqual(payload.outcome.result, .refusalNoAvailableTool)
        XCTAssertTrue(payload.readbacks.isEmpty)
        XCTAssertEqual(store.cells, before)
        XCTAssertFalse(trace.entries.contains { $0.stage == .execute || $0.stage == .readback })
    }

    @MainActor
    func testStaleSecondSubactionRollsBackWholePlan() async throws {
        let store = DemoVehicleStateStore()
        let before = store.cells
        let trace = InMemoryTraceLogger()
        let accepted = acPowerFrame(id: "accepted-ac", traceID: "trace-stale-atomic")
        let stale = acPowerOffFrame(id: "stale-ac-off", traceID: "trace-stale-atomic", stateRevision: 0)
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            // GOVERNANCE: bypasses NLU by design (not product behavior)
            planDecoder: { _ in try atomicRuntimePlan([accepted, stale]) },
            alignsFrameStateRevisionToStore: false
        )

        let payload = try await runner.run(text: "打开空调再关闭空调")

        XCTAssertEqual(payload.outcome.result, .refusalNoAvailableTool)
        XCTAssertTrue(payload.readbacks.isEmpty)
        XCTAssertEqual(store.cells, before)
        XCTAssertFalse(trace.entries.contains { $0.stage == .execute || $0.stage == .readback })
        let staleEntry = try XCTUnwrap(
            trace.entries.first {
                $0.message == "partial_subaction:stale-ac-off:refused:tool_call_count=0:readback_count=0:state_mutation=false"
            }
        )
        XCTAssertEqual(staleEntry.attributes.finiteReason, .staleStateRevision)
    }

    @MainActor
    func testUnknownSecondSubactionRefusesWholePlanWithoutMutation() async throws {
        let store = DemoVehicleStateStore()
        let before = store.cells
        let trace = InMemoryTraceLogger()
        let accepted = acPowerFrame(id: "accepted-ac", traceID: "trace-unknown-atomic")
        let unknown = unknownFrame(id: "unknown-action", traceID: "trace-unknown-atomic")
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            // GOVERNANCE: bypasses NLU by design (not product behavior)
            planDecoder: { _ in try atomicRuntimePlan([accepted, unknown]) }
        )

        let payload = try await runner.run(text: "打开空调并执行未知动作")

        XCTAssertEqual(payload.outcome.result, .refusalNoAvailableTool)
        XCTAssertTrue(payload.readbacks.isEmpty)
        XCTAssertEqual(store.cells, before)
        XCTAssertFalse(trace.entries.contains { $0.stage == .execute || $0.stage == .readback })
        let unknownEntry = try XCTUnwrap(
            trace.entries.first {
                $0.message == "partial_subaction:unknown-action:refused:tool_call_count=0:readback_count=0:state_mutation=false"
            }
        )
        XCTAssertEqual(unknownEntry.attributes.finiteReason, .unsupportedToolPlan)
    }

    @MainActor
    func testUnknownEnumSecondSubactionRefusesWholePlanWithoutMutation() async throws {
        let store = DemoVehicleStateStore()
        let before = store.cells
        let trace = InMemoryTraceLogger()
        let accepted = acPowerFrame(id: "accepted-ac", traceID: "trace-enum-atomic")
        let badColor = unknownColorFrame(id: "bad-color", traceID: "trace-enum-atomic")
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            // GOVERNANCE: bypasses NLU by design (not product behavior)
            planDecoder: { _ in try atomicRuntimePlan([accepted, badColor]) }
        )

        let payload = try await runner.run(text: "打开空调并把氛围灯调成未知颜色")

        XCTAssertEqual(payload.outcome.result, .refusalNoAvailableTool)
        XCTAssertTrue(payload.readbacks.isEmpty)
        XCTAssertEqual(store.cells, before)
        XCTAssertFalse(trace.entries.contains { $0.stage == .execute || $0.stage == .readback })
        let refusedEntry = try XCTUnwrap(
            trace.entries.first {
                $0.message == "partial_subaction:bad-color:refused:tool_call_count=0:readback_count=0:state_mutation=false"
            }
        )
        XCTAssertEqual(refusedEntry.attributes.finiteReason, .unsupportedToolPlan)
    }

    @MainActor
    func testReviewedRefusalWithoutCardStillRefusesWholeAtomicPlan() async throws {
        let store = DemoVehicleStateStore()
        let before = store.cells
        let trace = InMemoryTraceLogger()
        let accepted = acPowerFrame(id: "accepted-ac", traceID: "trace-missing-refused-card")
        let refused = reviewedUnmappableRefusalFrame(
            id: "refused-without-card",
            traceID: "trace-missing-refused-card"
        )
        XCTAssertTrue(DemoRuntimePartialPlan.isReviewed(refused))

        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            // GOVERNANCE: bypasses NLU by design (not product behavior)
            planDecoder: { _ in try atomicRuntimePlan([accepted, refused]) }
        )

        let payload = try await runner.run(text: "打开空调并执行无法投影的拒绝动作")

        XCTAssertEqual(payload.outcome.result, .refusalNoAvailableTool)
        XCTAssertTrue(payload.readbacks.isEmpty)
        XCTAssertEqual(store.cells, before)
        XCTAssertFalse(trace.entries.contains { $0.stage == .execute || $0.stage == .readback })
    }

    @MainActor
    func testUnreviewedExtraActionRejectsWholePlanBeforeAnyMutation() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let accepted = acPowerFrame(id: "accepted-ac", traceID: "trace-unreviewed")
        var unreviewed = unmountedFragranceFrame(id: "unreviewed-generic", traceID: "trace-unreviewed")
        unreviewed.toolName = "vehicle_control"
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            // GOVERNANCE: bypasses NLU by design (not product behavior)
            planDecoder: { _ in try atomicRuntimePlan([accepted, unreviewed]) }
        )

        do {
            _ = try await runner.run(text: "打开空调并执行未审查动作")
            XCTFail("expected unreviewed action to reject the whole plan")
        } catch {
            XCTAssertEqual(
                error as? DemoRuntimeSessionRunnerError,
                .multiFramePlanContainsUnreviewedAction(frameIDs: ["accepted-ac", "unreviewed-generic"])
            )
        }

        XCTAssertEqual(store.currentRevision, 0)
        let guardEntry = try XCTUnwrap(trace.entries.first)
        XCTAssertEqual(trace.entries.count, 1)
        XCTAssertEqual(guardEntry.stage, .guard)
        XCTAssertEqual(guardEntry.message, "multi_frame_plan_rejected")
        XCTAssertEqual(guardEntry.attributes.toolCallCount, 0)
        XCTAssertEqual(
            guardEntry.attributes.guardReason,
            "multi_frame_plan_contains_unreviewed_action"
        )
        XCTAssertFalse(trace.entries.contains { $0.stage == .execute })
        XCTAssertFalse(trace.entries.contains { $0.stage == .readback })
    }

    @MainActor
    func testPlanAboveBoundRejectsBeforeAnyMutation() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let frames = [
            acPowerFrame(id: "one", traceID: "trace-overbound"),
            unmountedFragranceFrame(id: "two", traceID: "trace-overbound"),
            acPowerFrame(id: "three", traceID: "trace-overbound"),
        ]
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            // GOVERNANCE: bypasses NLU by design (not product behavior)
            planDecoder: { _ in try atomicRuntimePlan(frames) }
        )

        do {
            _ = try await runner.run(text: "三个动作")
            XCTFail("expected bounded plan rejection")
        } catch {
            XCTAssertEqual(
                error as? DemoRuntimePartialPlanError,
                .subactionLimitExceeded(limit: 2, actual: 3)
            )
        }

        XCTAssertEqual(store.currentRevision, 0)
        XCTAssertTrue(trace.entries.isEmpty)
    }

    @MainActor
    func testLengthTruncatedPlanFailsClosedBeforeAnyMutation() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            // GOVERNANCE: bypasses NLU by design (not product behavior)
            planDecoder: { _ in throw ToolExecutionError.malformed(.lengthTruncated) }
        )

        do {
            _ = try await runner.run(text: "被截断的多意图")
            XCTFail("expected length-truncated plan to fail closed")
        } catch {
            XCTAssertEqual(error as? ToolExecutionError, .malformed(.lengthTruncated))
        }

        XCTAssertEqual(store.currentRevision, 0)
        XCTAssertTrue(trace.entries.isEmpty)
    }

    private func acPowerFrame(id: String, traceID: String) -> ToolCallFrame {
        // GOVERNANCE: bypasses NLU by design (not product behavior)
        ToolCallFrame(
            id: id,
            traceID: traceID,
            agentID: "vehicle-control",
            capabilityID: "vehicle.ac.toggle",
            toolName: "set_vehicle_control",
            device: "ac",
            actionPrimitive: "power_on",
            value: ContractValue(offset: "on", type: "STATE"),
            stateRevision: 0,
            candidateSource: .fastPath
        )
    }

    private func acTemperatureFrame(id: String, traceID: String) -> ToolCallFrame {
        // GOVERNANCE: bypasses NLU by design (not product behavior)
        ToolCallFrame(
            id: id,
            traceID: traceID,
            agentID: "vehicle-control",
            capabilityID: "vehicle.ac.temperature",
            toolName: "adjust_ac_temperature_to_number",
            device: "ac_temperature",
            actionPrimitive: "adjust_to_number",
            value: ContractValue(direct: "26", type: "SPOT"),
            stateRevision: 0,
            candidateSource: .fastPath
        )
    }

    private func unmountedFragranceFrame(id: String, traceID: String) -> ToolCallFrame {
        // GOVERNANCE: bypasses NLU by design (not product behavior)
        ToolCallFrame(
            id: id,
            traceID: traceID,
            agentID: "vehicle-control",
            capabilityID: "cabin.fragrance",
            toolName: "close_fragrance",
            device: "fragrance",
            actionPrimitive: "power_off",
            stateRevision: 0,
            candidateSource: .upstreamToolCall
        )
    }

    private func safetyDeniedDoorFrame(id: String, traceID: String) -> ToolCallFrame {
        // GOVERNANCE: bypasses NLU by design (not product behavior)
        ToolCallFrame(
            id: id,
            traceID: traceID,
            agentID: "vehicle-control",
            capabilityID: "vehicle.door",
            toolName: "set_vehicle_control",
            device: "car_door",
            actionPrimitive: "power_on",
            stateRevision: 0,
            candidateSource: .fastPath
        )
    }

    private func acPowerOffFrame(id: String, traceID: String, stateRevision: Int) -> ToolCallFrame {
        // GOVERNANCE: bypasses NLU by design (not product behavior)
        ToolCallFrame(
            id: id,
            traceID: traceID,
            agentID: "vehicle-control",
            capabilityID: "vehicle.ac.toggle",
            toolName: "set_vehicle_control",
            device: "ac",
            actionPrimitive: "power_off",
            value: ContractValue(offset: "off", type: "STATE"),
            stateRevision: stateRevision,
            candidateSource: .fastPath
        )
    }

    private func unknownFrame(id: String, traceID: String) -> ToolCallFrame {
        // GOVERNANCE: bypasses NLU by design (not product behavior)
        ToolCallFrame(
            id: id,
            traceID: traceID,
            agentID: "vehicle-control",
            capabilityID: "vehicle.unknown",
            toolName: "set_vehicle_control",
            device: "ac",
            actionPrimitive: "definitely_unknown",
            stateRevision: 0,
            candidateSource: .fastPath
        )
    }

    private func unknownColorFrame(id: String, traceID: String) -> ToolCallFrame {
        // GOVERNANCE: bypasses NLU by design (not product behavior)
        ToolCallFrame(
            id: id,
            traceID: traceID,
            agentID: "vehicle-control",
            capabilityID: "vehicle.ambient",
            toolName: "set_vehicle_control",
            device: "atmosphere_lamp_color",
            actionPrimitive: "set_mode",
            value: ContractValue(ref: "ZERO", direct: "+", offset: "粉", type: "SPOT"),
            stateRevision: 0,
            candidateSource: .fastPath
        )
    }

    private func reviewedUnmappableRefusalFrame(id: String, traceID: String) -> ToolCallFrame {
        // GOVERNANCE: bypasses NLU by design (not product behavior)
        ToolCallFrame(
            id: id,
            traceID: traceID,
            agentID: "vehicle-control",
            capabilityID: "vehicle.unmappable",
            toolName: "adjust_seat_backrest_to_number",
            device: "missing_card_device",
            actionPrimitive: "adjust_to_number",
            value: ContractValue(direct: "26", type: "SPOT"),
            stateRevision: 0,
            candidateSource: .upstreamToolCall
        )
    }

    private func makeRepoPipeline() throws -> C3ExecutionPipeline {
        C3ExecutionPipeline(
            semantic: try SemanticContractLookup(jsonl: readRepoFile("contracts/semantic-function-contract.jsonl")),
            stateCells: try StateCellContractLookup(yaml: readRepoFile("contracts/state-cells.yaml")),
            riskPolicy: try RiskPolicyLookup(yaml: readRepoFile("contracts/risk-policy.yaml")),
            allowlist: try L1DemoAllowlistLookup(yaml: readRepoFile("contracts/l1-demo-allowlist.yaml"))
        )
    }

    private func readRepoFile(_ relativePath: String) throws -> String {
        let testFile = URL(fileURLWithPath: #filePath)
        let repoRoot = testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return try String(contentsOf: repoRoot.appendingPathComponent(relativePath), encoding: .utf8)
    }

}

private func atomicRuntimePlan(_ frames: [ToolCallFrame]) throws -> RuntimePlan {
    try RuntimePlan(
        traceID: frames.first?.traceID ?? "",
        frames: frames.map(RuntimeFrame.tool),
        executionPolicy: .atomic
    )
}

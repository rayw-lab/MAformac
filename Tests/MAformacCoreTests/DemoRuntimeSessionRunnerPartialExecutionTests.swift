import Foundation
import XCTest
@testable import MAformacCore

final class DemoRuntimeSessionRunnerPartialExecutionTests: XCTestCase {
    @MainActor
    func testMountedAndUnmountedPlanExecutesAcceptedAndTracesRefusedInInputOrder() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let accepted = acPowerFrame(id: "accepted-ac", traceID: "trace-partial")
        let refused = unmountedWindowFrame(id: "refused-window", traceID: "trace-partial")
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try DemoRuntimeContractBundle.singleCommandDemoDefault.makePipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            planDecoder: { _ in [accepted, refused] }
        )

        let payload = try await runner.run(text: "打开空调并打开车窗")

        XCTAssertEqual(payload.outcome.result, .partialAcceptPartialRefuse)
        XCTAssertEqual(payload.outcome.reason, "partial_accept_refuse")
        XCTAssertEqual(payload.readbacks.map(\.key), ["ac.power"])
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(store.cell(for: "window.position[主驾]")?.actualValue, "0")

        let executionEntries = trace.entries.filter { $0.stage == .execute }
        let readbackEntries = trace.entries.filter { $0.stage == .readback }
        XCTAssertEqual(executionEntries.count, 1)
        XCTAssertEqual(readbackEntries.count, 1)

        let partialEntries = trace.entries.filter { $0.message.hasPrefix("partial_subaction:") }
        XCTAssertEqual(
            partialEntries.map(\.message),
            [
                "partial_subaction:accepted-ac:accepted:state_mutation=true",
                "partial_subaction:refused-window:refused:state_mutation=false",
            ]
        )
        XCTAssertEqual(partialEntries[0].attributes.toolCallCount, 1)
        XCTAssertNil(partialEntries[0].attributes.finiteReason)
        XCTAssertEqual(partialEntries[1].attributes.toolCallCount, 0)
        XCTAssertEqual(partialEntries[1].attributes.finiteReason, "unmounted_tool_name")

        let fixture = try partialFixtureJSONObject()
        let fixtureOutcome = try XCTUnwrap(fixture["outcome"] as? [String: Any])
        let fixtureReadbacks = try XCTUnwrap(fixture["readbacks"] as? [[String: Any]])
        XCTAssertEqual(fixtureOutcome["result"] as? String, payload.outcome.result.rawValue)
        XCTAssertEqual(fixtureOutcome["reason"] as? String, payload.outcome.reason)
        XCTAssertEqual(fixtureReadbacks.compactMap { $0["key"] as? String }, payload.readbacks.map(\.key))
    }

    @MainActor
    func testAcceptedAndSafetyDeniedPlanMutatesOnlyAcceptedSubaction() async throws {
        let store = DemoVehicleStateStore()
        _ = store.applyMockTransition(DemoMockTransition(key: "vehicle.speed", desiredValue: "12"))
        let trace = InMemoryTraceLogger()
        let accepted = acPowerFrame(id: "accepted-ac", traceID: "trace-safety-partial")
        let refused = safetyDeniedDoorFrame(id: "refused-door", traceID: "trace-safety-partial")
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            planDecoder: { _ in [accepted, refused] }
        )

        let payload = try await runner.run(text: "打开空调并打开车门")

        XCTAssertEqual(payload.outcome.result, .partialAcceptPartialRefuse)
        XCTAssertEqual(payload.readbacks.map(\.key), ["ac.power"])
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(store.cell(for: "vehicle.speed")?.actualValue, "12")
        XCTAssertEqual(trace.entries.filter { $0.stage == .execute }.count, 1)
        XCTAssertEqual(trace.entries.filter { $0.stage == .readback }.count, 1)

        let refusedEntry = try XCTUnwrap(
            trace.entries.first { $0.message == "partial_subaction:refused-door:refused:state_mutation=false" }
        )
        XCTAssertEqual(refusedEntry.attributes.toolCallCount, 0)
        XCTAssertEqual(refusedEntry.attributes.finiteReason, "safety_or_policy_refusal")
    }

    @MainActor
    func testStaleSecondSubactionIsRefusedWithoutUndoingAcceptedFirstMutation() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let accepted = acPowerFrame(id: "accepted-ac", traceID: "trace-stale-partial")
        let stale = acPowerOffFrame(id: "stale-ac-off", traceID: "trace-stale-partial", stateRevision: 0)
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            planDecoder: { _ in [accepted, stale] },
            alignsFrameStateRevisionToStore: false
        )

        let payload = try await runner.run(text: "打开空调再关闭空调")

        XCTAssertEqual(payload.outcome.result, .partialAcceptPartialRefuse)
        XCTAssertEqual(payload.readbacks.map(\.key), ["ac.power"])
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(store.cell(for: "ac.power")?.revision, 1)
        XCTAssertEqual(trace.entries.filter { $0.stage == .execute }.count, 1)
        XCTAssertEqual(trace.entries.filter { $0.stage == .readback }.count, 1)

        let staleEntry = try XCTUnwrap(
            trace.entries.first { $0.message == "partial_subaction:stale-ac-off:refused:state_mutation=false" }
        )
        XCTAssertEqual(staleEntry.attributes.toolCallCount, 0)
        XCTAssertEqual(staleEntry.attributes.finiteReason, "stale_state_revision")
    }

    @MainActor
    func testUnknownSecondSubactionFailsClosedAsRefusedWithoutMutation() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let accepted = acPowerFrame(id: "accepted-ac", traceID: "trace-unknown-partial")
        let unknown = unknownFrame(id: "unknown-action", traceID: "trace-unknown-partial")
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            planDecoder: { _ in [accepted, unknown] }
        )

        let payload = try await runner.run(text: "打开空调并执行未知动作")

        XCTAssertEqual(payload.outcome.result, .partialAcceptPartialRefuse)
        XCTAssertEqual(payload.readbacks.map(\.key), ["ac.power"])
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(trace.entries.filter { $0.stage == .execute }.count, 1)
        XCTAssertEqual(trace.entries.filter { $0.stage == .readback }.count, 1)

        let unknownEntry = try XCTUnwrap(
            trace.entries.first { $0.message == "partial_subaction:unknown-action:refused:state_mutation=false" }
        )
        XCTAssertEqual(unknownEntry.attributes.toolCallCount, 0)
        XCTAssertEqual(unknownEntry.attributes.finiteReason, "unsupported_tool_plan")
    }

    @MainActor
    func testUnknownEnumSecondSubactionIsRefusedWithoutMutation() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let accepted = acPowerFrame(id: "accepted-ac", traceID: "trace-enum-partial")
        let badColor = unknownColorFrame(id: "bad-color", traceID: "trace-enum-partial")
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            planDecoder: { _ in [accepted, badColor] }
        )

        let payload = try await runner.run(text: "打开空调并把氛围灯调成未知颜色")

        XCTAssertEqual(payload.outcome.result, .partialAcceptPartialRefuse)
        XCTAssertEqual(payload.readbacks.map(\.key), ["ac.power"])
        XCTAssertEqual(store.cell(for: "ambient.color")?.actualValue, "白")

        let refusedEntry = try XCTUnwrap(
            trace.entries.first { $0.message == "partial_subaction:bad-color:refused:state_mutation=false" }
        )
        XCTAssertEqual(refusedEntry.attributes.toolCallCount, 0)
        XCTAssertEqual(refusedEntry.attributes.finiteReason, "unsupported_tool_plan")
    }

    @MainActor
    func testUnreviewedExtraActionRejectsWholePlanBeforeAnyMutation() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let accepted = acPowerFrame(id: "accepted-ac", traceID: "trace-unreviewed")
        var unreviewed = unmountedWindowFrame(id: "unreviewed-generic", traceID: "trace-unreviewed")
        unreviewed.toolName = "vehicle_control"
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            planDecoder: { _ in [accepted, unreviewed] }
        )

        do {
            _ = try await runner.run(text: "打开空调并执行未审查动作")
            XCTFail("expected unreviewed action to reject the whole plan")
        } catch {
            XCTAssertEqual(
                error as? DemoRuntimeSessionRunnerError,
                .multiFramePlanRequiresPartialExecution(frameIDs: ["accepted-ac", "unreviewed-generic"])
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
            "multi_frame_plan_requires_partial_execution"
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
            unmountedWindowFrame(id: "two", traceID: "trace-overbound"),
            acPowerFrame(id: "three", traceID: "trace-overbound"),
        ]
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            planDecoder: { _ in frames }
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

    private func unmountedWindowFrame(id: String, traceID: String) -> ToolCallFrame {
        ToolCallFrame(
            id: id,
            traceID: traceID,
            agentID: "vehicle-control",
            capabilityID: "cabin.window",
            toolName: "open_window",
            device: "window",
            actionPrimitive: "power_on",
            slots: ["position": "主驾"],
            stateRevision: 0,
            candidateSource: .upstreamToolCall
        )
    }

    private func safetyDeniedDoorFrame(id: String, traceID: String) -> ToolCallFrame {
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

    private func partialFixtureJSONObject() throws -> [String: Any] {
        let testFile = URL(fileURLWithPath: #filePath)
        let repoRoot = testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let fixtureURL = repoRoot
            .appendingPathComponent("Tests/Fixtures/RuntimePresentationPayload")
            .appendingPathComponent("partial_accept_refuse_public_payload.v1.json")
        let object = try JSONSerialization.jsonObject(with: Data(contentsOf: fixtureURL))
        return try XCTUnwrap(object as? [String: Any])
    }
}

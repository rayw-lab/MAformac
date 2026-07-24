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
            planDecoder: { _ in try self.partialPlan([accepted, refused]) }
        )

        let payload = try await runner.run(text: "打开空调并打开车窗")

        XCTAssertEqual(payload.outcome.result, .partialAcceptPartialRefuse)
        XCTAssertEqual(payload.outcome.reason, "partial_accept_refuse")
        XCTAssertEqual(payload.readbacks.map(\.key), ["ac.power"])
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(store.cell(for: "window.position[主驾]")?.actualValue, "0")

        XCTAssertEqual(payload.cards.map(\.key), ["window.position[主驾]", "ac.power"])
        XCTAssertEqual(payload.cards.map(\.visualState), [.blocked_with_alternative, .satisfied])
        let refusedSemantics = try XCTUnwrap(
            payload.cardSemantics?.first { $0.cellKey == "window.position[主驾]" }
        )
        XCTAssertEqual(refusedSemantics.role, .refused)
        XCTAssertEqual(refusedSemantics.reason, "capability_not_mounted")
        XCTAssertEqual(refusedSemantics.siblingKeys, ["ac.power"])

        let encodedPayload = String(decoding: try JSONEncoder().encode(payload), as: UTF8.self)
        XCTAssertFalse(encodedPayload.contains("unmounted_tool_name"))
        XCTAssertFalse(encodedPayload.contains("finiteReason"))
        XCTAssertTrue(encodedPayload.contains("capability_not_mounted"))

        let executionEntries = trace.entries.filter { $0.stage == .execute }
        let readbackEntries = trace.entries.filter { $0.stage == .readback }
        XCTAssertEqual(executionEntries.count, 1)
        XCTAssertEqual(readbackEntries.count, 1)

        let partialEntries = trace.entries.filter { $0.message.hasPrefix("partial_subaction:") }
        XCTAssertEqual(
            partialEntries.map(\.message),
            [
                "partial_subaction:accepted-ac:accepted:tool_call_count=1:readback_count=1:state_mutation=true",
                "partial_subaction:refused-window:refused:tool_call_count=0:readback_count=0:state_mutation=false",
            ]
        )
        XCTAssertEqual(partialEntries[0].attributes.toolCallCount, 1)
        XCTAssertNil(partialEntries[0].attributes.finiteReason)
        XCTAssertEqual(partialEntries[1].attributes.toolCallCount, 0)
        XCTAssertEqual(partialEntries[1].attributes.finiteReason, .unmountedToolName)

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
            planDecoder: { _ in try self.partialPlan([accepted, refused]) }
        )

        let payload = try await runner.run(text: "打开空调并打开车门")

        XCTAssertEqual(payload.outcome.result, .partialAcceptPartialRefuse)
        XCTAssertEqual(payload.readbacks.map(\.key), ["ac.power"])
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(store.cell(for: "vehicle.speed")?.actualValue, "12")
        XCTAssertEqual(trace.entries.filter { $0.stage == .execute }.count, 1)
        XCTAssertEqual(trace.entries.filter { $0.stage == .readback }.count, 1)

        let refusedEntry = try XCTUnwrap(
            trace.entries.first { $0.message == "partial_subaction:refused-door:refused:tool_call_count=0:readback_count=0:state_mutation=false" }
        )
        XCTAssertEqual(refusedEntry.attributes.toolCallCount, 0)
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
            planDecoder: { _ in try self.partialPlan([power, temperature]) }
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
        let first = unmountedWindowFrame(id: "refused-window-one", traceID: "trace-all-refused")
        let second = unmountedWindowFrame(id: "refused-window-two", traceID: "trace-all-refused")
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            planDecoder: { _ in try self.partialPlan([first, second]) }
        )

        let payload = try await runner.run(text: "打开两个未挂载车窗")

        XCTAssertEqual(payload.outcome.result, .refusalNoAvailableTool)
        XCTAssertEqual(
            payload.outcome.reason,
            RuntimePresentationSafeReasonKind.capabilityNotMounted.rawValue
        )
        XCTAssertNotEqual(payload.outcome.result, .partialAcceptPartialRefuse)
        XCTAssertEqual(payload.reconciliation.status, .notApplicable)
        XCTAssertTrue(payload.readbacks.isEmpty)
        XCTAssertEqual(store.currentRevision, 0)
        XCTAssertEqual(trace.entries.filter { $0.stage == .execute }.count, 0)
    }

    @MainActor
    func testAcceptedFrameWithMultipleReadbacksCountsOneToolCallAndRecordsReadbackCount() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let temperature = acTemperatureFrame(id: "accepted-temperature", traceID: "trace-multi-readback")
        let refused = unmountedWindowFrame(id: "refused-window", traceID: "trace-multi-readback")
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try DemoRuntimeContractBundle.singleCommandDemoDefault.makePipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            planDecoder: { _ in try self.partialPlan([temperature, refused]) }
        )

        let payload = try await runner.run(text: "空调调到26度并打开车窗")

        XCTAssertEqual(payload.outcome.result, .partialAcceptPartialRefuse)
        XCTAssertEqual(payload.readbacks.map(\.key), ["ac.power", "ac.temp_setpoint[主驾]"])
        let acceptedEntry = try XCTUnwrap(
            trace.entries.first {
                $0.message == "partial_subaction:accepted-temperature:accepted:tool_call_count=1:readback_count=2:state_mutation=true"
            }
        )
        XCTAssertEqual(acceptedEntry.attributes.toolCallCount, 1)
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
            planDecoder: { _ in try self.partialPlan([accepted, stale]) },
            alignsFrameStateRevisionToStore: false
        )

        let payload = try await runner.run(text: "打开空调再关闭空调")

        XCTAssertEqual(payload.outcome.result, .partialAcceptPartialRefuse)
        XCTAssertEqual(payload.readbacks.map(\.key), ["ac.power"])
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(store.cell(for: "ac.power")?.revision, 1)
        let staleSemantics = try XCTUnwrap(
            payload.cardSemantics?.first { $0.reason == "runtime_unavailable" }
        )
        XCTAssertEqual(staleSemantics.cellKey, "ac.power")
        XCTAssertEqual(staleSemantics.role, .refused)
        let encodedPayload = String(decoding: try JSONEncoder().encode(payload), as: UTF8.self)
        XCTAssertFalse(encodedPayload.contains("stale_state_revision"))
        XCTAssertFalse(encodedPayload.contains("finiteReason"))
        XCTAssertEqual(trace.entries.filter { $0.stage == .execute }.count, 1)
        XCTAssertEqual(trace.entries.filter { $0.stage == .readback }.count, 1)

        let staleEntry = try XCTUnwrap(
            trace.entries.first { $0.message == "partial_subaction:stale-ac-off:refused:tool_call_count=0:readback_count=0:state_mutation=false" }
        )
        XCTAssertEqual(staleEntry.attributes.toolCallCount, 0)
        XCTAssertEqual(staleEntry.attributes.finiteReason, .staleStateRevision)
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
            planDecoder: { _ in try self.partialPlan([accepted, unknown]) }
        )

        let payload = try await runner.run(text: "打开空调并执行未知动作")

        XCTAssertEqual(payload.outcome.result, .partialAcceptPartialRefuse)
        XCTAssertEqual(payload.readbacks.map(\.key), ["ac.power"])
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(trace.entries.filter { $0.stage == .execute }.count, 1)
        XCTAssertEqual(trace.entries.filter { $0.stage == .readback }.count, 1)

        let unknownEntry = try XCTUnwrap(
            trace.entries.first { $0.message == "partial_subaction:unknown-action:refused:tool_call_count=0:readback_count=0:state_mutation=false" }
        )
        XCTAssertEqual(unknownEntry.attributes.toolCallCount, 0)
        XCTAssertEqual(unknownEntry.attributes.finiteReason, .unsupportedToolPlan)
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
            planDecoder: { _ in try self.partialPlan([accepted, badColor]) }
        )

        let payload = try await runner.run(text: "打开空调并把氛围灯调成未知颜色")

        XCTAssertEqual(payload.outcome.result, .partialAcceptPartialRefuse)
        XCTAssertEqual(payload.readbacks.map(\.key), ["ac.power"])
        XCTAssertEqual(store.cell(for: "ambient.color")?.actualValue, "白")

        let refusedEntry = try XCTUnwrap(
            trace.entries.first { $0.message == "partial_subaction:bad-color:refused:tool_call_count=0:readback_count=0:state_mutation=false" }
        )
        XCTAssertEqual(refusedEntry.attributes.toolCallCount, 0)
        XCTAssertEqual(refusedEntry.attributes.finiteReason, .unsupportedToolPlan)
    }

    @MainActor
    func testAcceptedAndReviewedRefusalWithoutCardFailsClosedInsteadOfEmittingEmptyRefusedCards() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let accepted = acPowerFrame(id: "accepted-ac", traceID: "trace-missing-refused-card")
        let refused = reviewedUnmappableRefusalFrame(
            id: "refused-without-card",
            traceID: "trace-missing-refused-card"
        )
        let expectedExecutionResult = DemoRuntimePartialPlanResult(
            traceID: "trace-missing-refused-card",
            subactions: [
                DemoRuntimePartialSubactionResult(
                    frameID: accepted.id,
                    disposition: .accepted,
                    readbacks: [
                        DemoActionReadback(
                            key: "ac.power",
                            actualValue: "on",
                            revision: 1,
                            spokenText: "空调已打开"
                        )
                    ],
                    finiteReason: nil,
                    observedToolCallCount: 1,
                    observedReadbackCount: 1,
                    stateMutation: true
                ),
                DemoRuntimePartialSubactionResult(
                    frameID: refused.id,
                    disposition: .refused,
                    readbacks: [],
                    finiteReason: .unmountedToolName,
                    observedToolCallCount: 0,
                    observedReadbackCount: 0,
                    stateMutation: false
                )
            ],
            atomicityContract: .partial
        )
        XCTAssertTrue(DemoRuntimePartialPlan.isReviewed(refused))
        XCTAssertFalse(
            RuntimePresentationTerminalSnapshotAdapter.canProjectPartialRefusalIdentity(
                executionResult: expectedExecutionResult,
                refusedCardsBySubactionID: [:]
            )
        )

        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            planDecoder: { _ in try self.partialPlan([accepted, refused]) }
        )

        do {
            _ = try await runner.run(text: "打开空调并执行无法投影的拒绝动作")
            XCTFail("expected missing refused card to fail closed instead of emitting an empty refused list")
        } catch {
            XCTAssertEqual(
                error as? RuntimePresentationPartialProjectionError,
                .refusedSubactionMissingCard(frameID: "refused-without-card")
            )
        }
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
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
            planDecoder: { _ in try self.partialPlan([accepted, unreviewed]) }
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
            unmountedWindowFrame(id: "two", traceID: "trace-overbound"),
            acPowerFrame(id: "three", traceID: "trace-overbound"),
        ]
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            planDecoder: { _ in try self.partialPlan(frames) }
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

    private func acTemperatureFrame(id: String, traceID: String) -> ToolCallFrame {
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

    private func unmountedWindowFrame(id: String, traceID: String) -> ToolCallFrame {
        ToolCallFrame(
            id: id,
            traceID: traceID,
            agentID: "vehicle-control",
            capabilityID: "cabin.window",
            toolName: "close_window",
            device: "window",
            actionPrimitive: "power_off",
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

    private func reviewedUnmappableRefusalFrame(id: String, traceID: String) -> ToolCallFrame {
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

    private func partialPlan(_ frames: [ToolCallFrame]) throws -> RuntimePlan {
        guard let traceID = frames.first?.traceID else {
            throw RuntimePlanError.emptyFrames
        }
        return try RuntimePlan(
            traceID: traceID,
            frames: frames.map(RuntimeFrame.tool),
            executionPolicy: .partial
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
            .appendingPathComponent("partial_accept_refuse_public_payload.v2.json")
        let object = try JSONSerialization.jsonObject(with: Data(contentsOf: fixtureURL))
        return try XCTUnwrap(object as? [String: Any])
    }
}

import Foundation
import XCTest
@testable import MAformacCore

/// COR-7/8 Mutation Tests
/// Tests for:
/// - COR-7: alreadyStateNoop should not mutate state or create fake mutation evidence
/// - COR-8: PartialPlan atomic/partial contract for mixed acceptance/refusal
@MainActor
final class Cor78MutationTests: XCTestCase {

    // MARK: - COR-7: alreadyStateNoop mutation=0

    func testCOR7_alreadyStateNoopMutationZero() async throws {
        let adapter = DemoRuntimeAdapter()
        let store = DemoVehicleStateStore()

        // Pre-set AC power to "on"
        _ = store.applyMockTransition(DemoMockTransition(key: "ac.power", desiredValue: "on", source: .user))
        let revBefore = store.currentRevision

        // Execute command to set AC power to "on" (already on)
        let frame = DemoRuntimeAdapterTests_fixture(
            stateKey: "ac.power",
            targetState: "on",
            stateRevision: revBefore
        )
        let result = try adapter.execute(commandID: "cmd-1", frame: frame, store: store)

        // COR-7: mutation should be 0 (store.currentRevision unchanged)
        XCTAssertEqual(result.provenance, DemoRuntimeAdapterProvenance.alreadyStateNoop)
        XCTAssertEqual(store.currentRevision, revBefore, "COR-7: alreadyStateNoop must not increment revision")
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")

        // Readback should reflect current state without mutation
        XCTAssertEqual(result.readback.actualValue, "on")
        XCTAssertEqual(result.readback.revision, revBefore)
    }

    func testCOR7_alreadyStateNoopTemperatureAlreadyAtTarget() async throws {
        let adapter = DemoRuntimeAdapter()
        let store = DemoVehicleStateStore()

        // Pre-set temperature to 26
        _ = store.applyMockTransition(DemoMockTransition(key: "ac.temp_setpoint[主驾]", desiredValue: "26", source: .user))
        let revBefore = store.currentRevision

        // Execute command to set temperature to 26 (already at 26)
        let frame = DemoRuntimeAdapterTests_fixture(
            stateKey: "ac.temp_setpoint[主驾]",
            targetState: "26",
            stateRevision: revBefore
        )
        let result = try adapter.execute(commandID: "cmd-2", frame: frame, store: store)

        // COR-7: mutation should be 0
        XCTAssertEqual(result.provenance, DemoRuntimeAdapterProvenance.alreadyStateNoop)
        XCTAssertEqual(store.currentRevision, revBefore, "COR-7: alreadyStateNoop must not increment revision")
        XCTAssertEqual(store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, "26")
        XCTAssertEqual(result.readback.actualValue, "26")
        XCTAssertEqual(result.readback.revision, revBefore)
    }

    func testCOR7_alreadyStateNoopNoFakeAcceptedToolCall() async throws {
        let adapter = DemoRuntimeAdapter()
        let store = DemoVehicleStateStore()

        _ = store.applyMockTransition(DemoMockTransition(key: "ac.power", desiredValue: "on", source: .user))
        let revBefore = store.currentRevision

        let frame = DemoRuntimeAdapterTests_fixture(
            stateKey: "ac.power",
            targetState: "on",
            stateRevision: revBefore
        )
        let result = try adapter.execute(commandID: "cmd-3", frame: frame, store: store)

        // COR-7: provenance should be alreadyStateNoop, NOT firstExecution (which would imply mutation)
        XCTAssertEqual(result.provenance, DemoRuntimeAdapterProvenance.alreadyStateNoop)
        // Verify no mutation happened by checking revision unchanged
        XCTAssertEqual(store.currentRevision, revBefore)
    }

    // MARK: - COR-8: PartialPlan atomic/partial contract

    func testCOR8_atomicPolicyAllAcceptedCommitsBoth() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let pipeline = try DemoRuntimeContractBundle.singleCommandDemoDefault.makePipeline()
        let frame1 = acPowerFrame(id: "frame-1", traceID: "trace-atomic-all-accepted")
        let frame2 = acTemperatureFrame(id: "frame-2", traceID: "trace-atomic-all-accepted")
        let plan = try runtimePlan([frame1, frame2], policy: .atomic)

        let result = try DemoRuntimePartialPlan().execute(
            plan: plan,
            store: store,
            pipeline: pipeline,
            traceLogger: trace,
            alignsFrameStateRevisionToStore: true
        )

        XCTAssertEqual(result.atomicityContract, .atomic)
        XCTAssertTrue(result.hasAccepted)
        XCTAssertFalse(result.hasRefused)
        XCTAssertEqual(result.subactions.count, 2)
        XCTAssertTrue(result.subactions.allSatisfy { $0.disposition == .accepted })
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, "26")
    }

    func testCOR8_atomicPolicyPreflightRefusalLeavesWholeStoreUnchanged() async throws {
        let store = DemoVehicleStateStore()
        let before = store.cells
        let trace = InMemoryTraceLogger()
        let pipeline = try DemoRuntimeContractBundle.singleCommandDemoDefault.makePipeline()
        let executable = acPowerFrame(id: "frame-1", traceID: "trace-atomic-refused")
        let refused = unmountedFragranceFrame(id: "frame-2", traceID: "trace-atomic-refused")
        let plan = try runtimePlan([executable, refused], policy: .atomic)

        let result = try DemoRuntimePartialPlan().execute(
            plan: plan,
            store: store,
            pipeline: pipeline,
            traceLogger: trace,
            alignsFrameStateRevisionToStore: true
        )

        XCTAssertEqual(result.atomicityContract, .atomic)
        XCTAssertFalse(result.hasAccepted)
        XCTAssertTrue(result.hasRefused)
        XCTAssertTrue(result.subactions.allSatisfy { $0.disposition == .refused })
        XCTAssertEqual(store.cells, before)
        XCTAssertEqual(store.currentRevision, 0)
        XCTAssertFalse(trace.entries.contains { $0.stage == .execute })
    }

    func testCOR8_atomicPolicyMixedMountedAndUnmountedRefusesWholePlan() async throws {
        let store = DemoVehicleStateStore()
        _ = store.applyMockTransition(DemoMockTransition(key: "vehicle.speed", desiredValue: "12", source: .user))
        let before = store.cells
        let trace = InMemoryTraceLogger()
        let accepted = acPowerFrame(id: "accepted-ac", traceID: "trace-atomic-mixed")
        let refused = unmountedFragranceFrame(id: "refused-fragrance", traceID: "trace-atomic-mixed")
        let plan = try runtimePlan([accepted, refused], policy: .atomic)

        let result = try DemoRuntimePartialPlan().execute(
            plan: plan,
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            alignsFrameStateRevisionToStore: true
        )

        XCTAssertEqual(result.atomicityContract, .atomic)
        XCTAssertFalse(result.hasAccepted)
        XCTAssertTrue(result.subactions.allSatisfy { $0.disposition == .refused })
        XCTAssertEqual(store.cells, before)
        XCTAssertFalse(trace.entries.contains { $0.stage == .execute })
    }

    func testCOR8_atomicPolicySafetyRefusalBlocksEverySubaction() async throws {
        let store = DemoVehicleStateStore()
        _ = store.applyMockTransition(DemoMockTransition(key: "vehicle.speed", desiredValue: "12", source: .user))
        let before = store.cells
        let trace = InMemoryTraceLogger()
        let refused = safetyDeniedDoorFrame(id: "refused-door", traceID: "trace-atomic-safety")
        let otherwiseAccepted = acTemperatureFrame(id: "accepted-temp", traceID: "trace-atomic-safety")
        let plan = try runtimePlan([refused, otherwiseAccepted], policy: .atomic)

        let result = try DemoRuntimePartialPlan().execute(
            plan: plan,
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            alignsFrameStateRevisionToStore: true
        )

        XCTAssertEqual(result.atomicityContract, .atomic)
        XCTAssertFalse(result.hasAccepted)
        XCTAssertTrue(result.subactions.allSatisfy { $0.disposition == .refused })
        XCTAssertEqual(result.subactions.first { $0.frameID == "refused-door" }?.finiteReason, .safetyOrPolicyRefusal)
        XCTAssertEqual(store.cells, before)
        XCTAssertFalse(trace.entries.contains { $0.stage == .execute })
    }

    func testCOR8_atomicPolicyStaleFrameBlocksFreshSibling() async throws {
        let store = DemoVehicleStateStore()
        _ = store.applyMockTransition(DemoMockTransition(key: "vehicle.speed", desiredValue: "12", source: .user))
        let before = store.cells
        let trace = InMemoryTraceLogger()
        let stale = acPowerOffFrame(id: "stale-ac-off", traceID: "trace-atomic-stale", stateRevision: 0)
        var otherwiseAccepted = acTemperatureFrame(id: "accepted-temp", traceID: "trace-atomic-stale")
        otherwiseAccepted.stateRevision = store.currentRevision
        let plan = try runtimePlan([stale, otherwiseAccepted], policy: .atomic)

        let result = try DemoRuntimePartialPlan().execute(
            plan: plan,
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            alignsFrameStateRevisionToStore: false
        )

        XCTAssertEqual(result.atomicityContract, .atomic)
        XCTAssertFalse(result.hasAccepted)
        XCTAssertEqual(result.subactions.first { $0.frameID == "stale-ac-off" }?.finiteReason, .staleStateRevision)
        XCTAssertEqual(store.cells, before)
        XCTAssertFalse(trace.entries.contains { $0.stage == .execute })
    }

    func testCOR8_atomicExecutionFailureRollsBackStoreAndDurableAdapterLedger() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("maformac-cor8-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let store = DemoVehicleStateStore()
        let before = store.cells
        let trace = InMemoryTraceLogger()
        let pipeline = try makeDurablePipeline(directory: directory)
        let powerOn = acPowerFrame(id: "same-command", traceID: "trace-atomic-runtime-failure")
        let powerOff = acPowerOffFrame(
            id: "same-command",
            traceID: "trace-atomic-runtime-failure",
            stateRevision: 0
        )
        let plan = try runtimePlan([powerOn, powerOff], policy: .atomic)

        let result = try DemoRuntimePartialPlan().execute(
            plan: plan,
            store: store,
            pipeline: pipeline,
            traceLogger: trace,
            alignsFrameStateRevisionToStore: true
        )

        XCTAssertEqual(result.atomicityContract, .atomic)
        XCTAssertTrue(result.subactions.allSatisfy { $0.disposition == .refused })
        XCTAssertEqual(store.cells, before)
        XCTAssertEqual(store.currentRevision, 0)

        let reloaded = try makeDurablePipeline(directory: directory)
        let retry = try reloaded.execute(powerOff, store: store, traceLogger: InMemoryTraceLogger())
        XCTAssertEqual(retry.readbacks.map(\.actualValue), ["off"])
        XCTAssertEqual(store.currentRevision, 0)
    }

    func testCOR8_partialPolicyPlanConstructsAndPreservesPolicyAndFrames() throws {
        let frames = [
            acPowerFrame(id: "frame-1", traceID: "trace-partial-constructed"),
            acTemperatureFrame(id: "frame-2", traceID: "trace-partial-constructed"),
        ]

        let plan = try runtimePlan(frames, policy: .partial)
        XCTAssertEqual(plan.executionPolicy, .partial)
        XCTAssertEqual(plan.frames.count, 2)
        XCTAssertEqual(plan.toolFrames, frames)
    }

    // MARK: - AF-5: TTS success/failure, no-op, fresh mutation, retry replay

    @MainActor
    func testAF5_TTSSuccessProducesSpeakVoiceAndOrb() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let speech = RecordingSpeechSynthesisEngine(nextResult: .enqueued(route: .testDouble))
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            speech: speech
        )
        let payload = try await runner.run(text: "打开空调")

        XCTAssertEqual(payload.outcome.result, .acceptedToolCall)
        XCTAssertEqual(payload.mutationCount, 1)
        XCTAssertEqual(payload.voiceState, .speak)
        XCTAssertEqual(payload.orbState, .speak)
    }

    @MainActor
    func testAF5_TTSFailureProducesIdleVoiceAndOrbButPreservesStoreReadback() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let speech = RecordingSpeechSynthesisEngine(
            nextResult: .failed(reason: "chinese_voice_unavailable")
        )
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            speech: speech
        )
        let payload = try await runner.run(text: "打开空调")

        // Store/readback truth preserved.
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(payload.readbacks.first?.key, "ac.power")
        XCTAssertEqual(payload.outcome.result, .acceptedToolCall)
        XCTAssertEqual(payload.mutationCount, 1)
        // Voice/orb frozen to idle on synthesis failure (ROB-1).
        XCTAssertEqual(payload.voiceState, .idle)
        XCTAssertEqual(payload.orbState, .idle)
        // TTS failure observable on trace.
        XCTAssertTrue(trace.entries.contains { $0.message.hasPrefix("tts_fail_open:") })
    }

    @MainActor
    func testAF5_NoOpOutcomeIsAlreadyStateNoopWithZeroMutation() async throws {
        let store = DemoVehicleStateStore()
        _ = store.applyMockTransition(DemoMockTransition(key: "ac.power", desiredValue: "on"))
        let revBefore = store.currentRevision
        let trace = InMemoryTraceLogger()
        let speech = RecordingSpeechSynthesisEngine(nextResult: .enqueued(route: .testDouble))
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            speech: speech
        )
        let payload = try await runner.run(text: "打开空调")

        // COR-7: no-op outcome, zero mutation, revision unchanged.
        XCTAssertEqual(payload.outcome.result, .alreadyStateNoop)
        XCTAssertEqual(payload.mutationCount, 0)
        XCTAssertEqual(store.currentRevision, revBefore)
    }

    @MainActor
    func testAF5_FreshTemperatureAdjustMutatesTwoCellsAndCountsTwoMutations() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let speech = RecordingSpeechSynthesisEngine(nextResult: .enqueued(route: .testDouble))
        let tempFrame = acTemperatureFrame(id: "turn-temp", traceID: "trace-temp")
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            speech: speech,
            planDecoder: { _ in try self.runtimePlan([tempFrame], policy: .atomic) }
        )
        let payload = try await runner.run(text: "调到26度")

        // Fresh AC temp adjust auto-powers on (2 firstExecution transitions).
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, "26")
        XCTAssertEqual(payload.outcome.result, .acceptedToolCall)
        XCTAssertEqual(payload.mutationCount, 2, "fresh cold-start temp adjust produces 2 firstExecution mutations")
    }

    @MainActor
    func testAF5_RetryReplayDoesNotCountAsNewMutation() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("maformac-af5-retry-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let store = DemoVehicleStateStore()
        let retryFrame = acPowerFrame(id: "af5-durable-retry", traceID: "trace-af5-durable-retry")
        let pipeline1 = try makeDurablePipeline(directory: directory)
        let trace1 = InMemoryTraceLogger()
        let speech1 = RecordingSpeechSynthesisEngine(nextResult: .enqueued(route: .testDouble))
        let runner1 = DemoRuntimeSessionRunner(
            store: store,
            pipeline: pipeline1,
            traceLogger: trace1,
            speech: speech1,
            planDecoder: { _ in try self.runtimePlan([retryFrame], policy: .atomic) },
            alignsFrameStateRevisionToStore: false
        )
        _ = try await runner1.run(text: "打开空调")
        let revAfterFirst = store.currentRevision
        XCTAssertEqual(revAfterFirst, 1)

        // Retry with a stale frame (revision 0 < store revision 1): triggers replay path.
        let pipeline2 = try makeDurablePipeline(directory: directory)
        let trace2 = InMemoryTraceLogger()
        let speech2 = RecordingSpeechSynthesisEngine(nextResult: .enqueued(route: .testDouble))
        let runner2 = DemoRuntimeSessionRunner(
            store: store,
            pipeline: pipeline2,
            traceLogger: trace2,
            speech: speech2,
            planDecoder: { _ in try self.runtimePlan([retryFrame], policy: .atomic) },
            alignsFrameStateRevisionToStore: false
        )
        let payload = try await runner2.run(text: "打开空调")

        // Retry replay: revision unchanged, mutation=0.
        XCTAssertEqual(store.currentRevision, revAfterFirst)
        XCTAssertEqual(payload.mutationCount, 0, "retry replay must not count as new mutation")
    }

    @MainActor
    func testAF5_v2EncodeRoundTripsThroughStrictConsumer() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let speech = RecordingSpeechSynthesisEngine(nextResult: .enqueued(route: .testDouble))
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            speech: speech
        )
        let payload = try await runner.run(text: "打开空调")

        let encoded = try JSONEncoder().encode(payload)
        let decoded = try JSONDecoder().decode(RuntimePresentationPayload.self, from: encoded)

        XCTAssertEqual(decoded.schemaVersion, .v2)
        XCTAssertEqual(decoded.voiceState, .speak)
        XCTAssertEqual(decoded.orbState, .speak)
        XCTAssertEqual(decoded.mutationCount, 1)
        XCTAssertEqual(decoded.outcome.result, .acceptedToolCall)
    }

    @MainActor
    func testAF5_PartialPlanTTSSuccessProducesSpeakVoiceAndOrb() async throws {
        let store = DemoVehicleStateStore()
        _ = store.applyMockTransition(DemoMockTransition(key: "vehicle.speed", desiredValue: "12"))
        let trace = InMemoryTraceLogger()
        let speech = RecordingSpeechSynthesisEngine(nextResult: .enqueued(route: .testDouble))
        let accepted = acPowerFrame(id: "accepted-ac", traceID: "trace-partial-tts-ok")
        let refused = safetyDeniedDoorFrame(id: "refused-door", traceID: "trace-partial-tts-ok")
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            speech: speech,
            planDecoder: { _ in try self.runtimePlan([accepted, refused], policy: .partial) }
        )
        let payload = try await runner.run(text: "打开空调并打开车门")

        // Partial accept+refuse with TTS success: voice/orb=speak, mutation=1.
        XCTAssertEqual(payload.outcome.result, .partialAcceptPartialRefuse)
        XCTAssertEqual(payload.voiceState, .speak)
        XCTAssertEqual(payload.orbState, .speak)
        XCTAssertEqual(payload.mutationCount, 1)
    }

    @MainActor
    func testAF5_PartialPlanTTSFailureProducesIdleVoiceAndOrb() async throws {
        let store = DemoVehicleStateStore()
        _ = store.applyMockTransition(DemoMockTransition(key: "vehicle.speed", desiredValue: "12"))
        let trace = InMemoryTraceLogger()
        let speech = RecordingSpeechSynthesisEngine(
            nextResult: .failed(reason: "chinese_voice_unavailable")
        )
        let accepted = acPowerFrame(id: "accepted-ac", traceID: "trace-partial-tts-fail")
        let refused = safetyDeniedDoorFrame(id: "refused-door", traceID: "trace-partial-tts-fail")
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            speech: speech,
            planDecoder: { _ in try self.runtimePlan([accepted, refused], policy: .partial) }
        )
        let payload = try await runner.run(text: "打开空调并打开车门")

        // Partial accept+refuse with TTS failure: voice/orb=idle, mutation still 1.
        XCTAssertEqual(payload.outcome.result, .partialAcceptPartialRefuse)
        XCTAssertEqual(payload.voiceState, .idle, "TTS failure must freeze voice to idle")
        XCTAssertEqual(payload.orbState, .idle, "TTS failure must freeze orb to idle")
        XCTAssertEqual(payload.mutationCount, 1)
        // Store truth preserved despite TTS failure.
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
    }


    // MARK: - Helper frame constructors (matching existing test patterns)

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

    private func runtimePlan(
        _ frames: [ToolCallFrame],
        policy: DemoRuntimeAtomicityContract
    ) throws -> RuntimePlan {
        try RuntimePlan(
            traceID: frames.first?.traceID ?? "trace-cor8",
            frames: frames.map(RuntimeFrame.tool),
            executionPolicy: policy
        )
    }

    private func makeDurablePipeline(directory: URL) throws -> C3ExecutionPipeline {
        let bundle = DemoRuntimeContractBundle.singleCommandDemoDefault
        return C3ExecutionPipeline(
            semantic: try SemanticContractLookup(jsonl: bundle.semanticJSONL),
            stateCells: try StateCellContractLookup(yaml: bundle.stateCellsYAML),
            riskPolicy: try RiskPolicyLookup(yaml: bundle.riskPolicyYAML),
            allowlist: try L1DemoAllowlistLookup(yaml: bundle.allowlistYAML),
            localDurableLedgerDirectory: directory
        )
    }

    private func makeRepoPipeline() throws -> C3ExecutionPipeline {
        C3ExecutionPipeline(
            semantic: try SemanticContractLookup(
                jsonl: readRepoFile("contracts/semantic-function-contract.jsonl")
            ),
            stateCells: try StateCellContractLookup(
                yaml: readRepoFile("contracts/state-cells.yaml")
            ),
            riskPolicy: try RiskPolicyLookup(
                yaml: readRepoFile("contracts/risk-policy.yaml")
            ),
            allowlist: try L1DemoAllowlistLookup(
                yaml: readRepoFile("contracts/l1-demo-allowlist.yaml")
            )
        )
    }

    private func readRepoFile(_ relativePath: String) throws -> String {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return try String(
            contentsOf: root.appendingPathComponent(relativePath),
            encoding: .utf8
        )
    }
}
/// COR-7/8 fixture helper — creates a ToolCallFrame matching the pattern used
/// by other test files while keeping the helper in this file (not fileprivate elsewhere).
private func DemoRuntimeAdapterTests_fixture(
    stateKey: String,
    targetState: String,
    stateRevision: Int = 0
) -> ToolCallFrame {
    ToolCallFrame(
        agentID: "vehicle-control",
        capabilityID: "cabin.runtime_adapter",
        toolName: "set_vehicle_control",
        arguments: [
            "state_key": stateKey,
            "target_state": targetState,
            "state_revision": String(stateRevision)
        ]
    )
}
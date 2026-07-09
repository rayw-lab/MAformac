import XCTest
@testable import MAformacCore

final class DemoRuntimeSessionRunnerTests: XCTestCase {
    @MainActor
    func testCommandTextReachesC3PipelineAndEmitsRuntimePresentationPayload() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let speech = RecordingSpeechSynthesisEngine()
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            speech: speech
        )

        let payload = try await runner.run(text: "打开空调")

        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(payload.schemaVersion, .v1)
        XCTAssertEqual(payload.proofClass, .localUnit)
        XCTAssertEqual(payload.readbacks.first?.key, "ac.power")
        XCTAssertEqual(payload.reconciliation.status, .verified)
        XCTAssertEqual(speech.spokenTexts, ["空调已打开"])
        XCTAssertTrue(trace.entries.contains { $0.stage == .decode && $0.message == "fast_path:ac.power_on" })
        XCTAssertFalse(trace.entries.contains { $0.message.contains("fast_path: 打开空调") })
    }

    @MainActor
    func testDefaultRunnerUsesSingleCommandDemoBundleForAppPath() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let speech = RecordingSpeechSynthesisEngine()
        let runner = try DemoRuntimeSessionRunner.defaultRunner(
            store: store,
            traceLogger: trace,
            speech: speech
        )

        let payload = try await runner.run(text: "打开空调")

        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(payload.readbacks.first?.spokenText, "空调已打开")
        XCTAssertEqual(payload.reconciliation.safeReason, "c2_readback_verified")
        XCTAssertEqual(speech.spokenTexts, ["空调已打开"])
    }

    @MainActor
    func testDefaultRunnerUsesInjectedModelRouterForDDomainText() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let speech = RecordingSpeechSynthesisEngine()
        let completion = #"<tool_call>{"name":"adjust_ac_temperature_to_number","arguments":{"temperature":"26"}}</tool_call>"#
        let runner = try DemoRuntimeSessionRunner.defaultRunner(
            store: store,
            traceLogger: trace,
            speech: speech,
            modelBackend: DDomainToolPlanBackend(completionProvider: { _ in completion })
        )

        let payload = try await runner.run(text: "空调调到26度")

        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, "26")
        XCTAssertTrue(payload.readbacks.contains { $0.key == "ac.temp_setpoint[主驾]" && $0.actualValue == "26" })
        XCTAssertEqual(payload.reconciliation.safeReason, "c2_readback_verified")
    }

    @MainActor
    func testTTSFailureDoesNotBlockVisualReadbackPresentation() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let speech = RecordingSpeechSynthesisEngine(nextResult: .failed(reason: "synthesizer_busy"))
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            speech: speech
        )

        let payload = try await runner.run(text: "打开空调")

        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(payload.outcome.result, .acceptedToolCall)
        XCTAssertEqual(payload.reconciliation.status, .verified)
        XCTAssertEqual(payload.readbacks.first?.key, "ac.power")
        XCTAssertEqual(speech.spokenTexts, ["空调已打开"])
        XCTAssertTrue(trace.entries.contains { entry in
            entry.stage == .readback
                && entry.message == "tts_fail_open:synthesizer_busy"
                && entry.attributes.readbackResult == .failed
        })
    }

    @MainActor
    func testRunnerUpdatesShortTermDialogueStateFromMockReadback() async throws {
        let store = DemoVehicleStateStore()
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: InMemoryTraceLogger(),
            speech: RecordingSpeechSynthesisEngine()
        )

        _ = try await runner.run(text: "打开空调")
        let state = runner.currentDialogueState

        XCTAssertEqual(state.turns.map(\.role), [.user, .assistant])
        XCTAssertEqual(state.turns.map(\.text), ["打开空调", "空调已打开"])
        XCTAssertEqual(state.focusEntity, "ac")
        XCTAssertEqual(state.lastReadback?.key, "ac.power")
    }

    @MainActor
    func testFrameDecoderDoesNotBlockMainActorDuringBackendWork() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let speech = RecordingSpeechSynthesisEngine()
        let frame = acPowerFrame(id: "cmd-async-decoder", traceID: "trace-async-decoder")
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            speech: speech,
            frameDecoder: { _ in
                await Task.detached {
                    return frame
                }.value
            },
            alignsFrameStateRevisionToStore: false
        )

        let payload = try await runner.run(text: "打开空调")

        XCTAssertEqual(payload.readbacks.first?.key, "ac.power")
    }

    @MainActor
    func testRuntimePayloadRedactsPrivateTraceMarkersFromAppFacingEntry() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let frame = acPowerFrame(id: "cmd-redact", traceID: "trace-redact")
        trace.recordDecode(
            traceID: frame.traceID,
            message: "DemoRuntimeAdapter RuntimeAdapterBox durableLedger requestFingerprint rawRuntimeStore"
        )
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            frameDecoder: { _ in frame },
            alignsFrameStateRevisionToStore: false
        )

        let payload = try await runner.run(text: "打开空调")
        let encoded = String(decoding: try JSONEncoder().encode(payload), as: UTF8.self)

        for forbidden in ["DemoRuntimeAdapter", "RuntimeAdapterBox", "durableLedger", "requestFingerprint", "rawRuntimeStore"] {
            XCTAssertFalse(encoded.contains(forbidden), "payload leaked \(forbidden)")
        }
        XCTAssertTrue(encoded.contains(#""schemaVersion":"r5_runtime_presentation_payload_v1""#))
    }

    @MainActor
    func testAppFacingEntryPreservesDurableStaleReplayWithoutSecondWrite() async throws {
        let directory = try temporaryDurableLedgerDirectory()
        let store = DemoVehicleStateStore()
        let firstFrame = windowFrame(id: "cmd-runner-durable-replay", traceID: "trace-runner-replay", stateRevision: 0)
        let firstRunner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(durabilityDirectory: directory),
            traceLogger: InMemoryTraceLogger(),
            speech: RecordingSpeechSynthesisEngine(),
            frameDecoder: { _ in firstFrame },
            alignsFrameStateRevisionToStore: false
        )

        _ = try await firstRunner.run(text: "open window")
        let cellAfterFirst = try XCTUnwrap(store.cell(for: "window.position[主驾]"))

        let trace = InMemoryTraceLogger()
        let staleFrame = windowFrame(id: "cmd-runner-durable-replay", traceID: "trace-runner-replay", stateRevision: 0)
        let replayRunner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(durabilityDirectory: directory),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            frameDecoder: { _ in staleFrame },
            alignsFrameStateRevisionToStore: false
        )

        let payload = try await replayRunner.run(text: "open window")
        let cellAfterReplay = try XCTUnwrap(store.cell(for: "window.position[主驾]"))

        XCTAssertEqual(payload.readbacks.first?.key, "window.position[主驾]")
        XCTAssertEqual(cellAfterReplay.revision, cellAfterFirst.revision)
        XCTAssertEqual(cellAfterReplay.timestamp, cellAfterFirst.timestamp)
        XCTAssertTrue(trace.entries.contains { $0.stage == .guard && $0.message == "stale_retry_replay" })
    }

    private func makeRepoPipeline(durabilityDirectory: URL? = nil) throws -> C3ExecutionPipeline {
        let semantic = try SemanticContractLookup(jsonl: readRepoFile("contracts/semantic-function-contract.jsonl"))
        let stateCells = try StateCellContractLookup(yaml: readRepoFile("contracts/state-cells.yaml"))
        let risk = try RiskPolicyLookup(yaml: readRepoFile("contracts/risk-policy.yaml"))
        let allowlist = try L1DemoAllowlistLookup(yaml: readRepoFile("contracts/l1-demo-allowlist.yaml"))
        if let durabilityDirectory {
            return C3ExecutionPipeline(
                semantic: semantic,
                stateCells: stateCells,
                riskPolicy: risk,
                allowlist: allowlist,
                localDurableLedgerDirectory: durabilityDirectory
            )
        }
        return C3ExecutionPipeline(
            semantic: semantic,
            stateCells: stateCells,
            riskPolicy: risk,
            allowlist: allowlist
        )
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

    private func windowFrame(id: String, traceID: String, stateRevision: Int) -> ToolCallFrame {
        ToolCallFrame(
            id: id,
            traceID: traceID,
            agentID: "vehicle-control",
            capabilityID: "cabin.window",
            toolName: "vehicle_control",
            device: "window",
            actionPrimitive: "power_on",
            slots: ["position": "主驾"],
            stateRevision: stateRevision,
            candidateSource: .upstreamToolCall
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

    private func temporaryDurableLedgerDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("MAformac-DemoRuntimeSessionRunnerTests", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
}

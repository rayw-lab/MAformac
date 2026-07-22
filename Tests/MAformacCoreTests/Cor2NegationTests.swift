import XCTest
@testable import MAformacCore

/// COR-2 否定违背 failsafe 测试。
/// 用户说"不要打开空调，只保持24度" → 最终 ac.power=off（无自动 on），温度 24。
/// 同时验证正常"开空调调26"仍 ac.power=on + temp=26（防伤正常路径）。
/// 禁手造带否定 flag 的 ToolCallFrame 自证：必须从原始 completion envelope 跑到 store。
final class Cor2NegationTests: XCTestCase {
    @MainActor
    func testNegation_PowerOffWithTemperature_DoesNotAutoPowerOn() throws {
        // "不要打开空调，只保持24度" → set_cabin_ac(power=off, target_temperature=24)
        let store = DemoVehicleStateStore()
        let pipeline = try makePipeline()
        let frames = try framesFrom(
            completion: #"<tool_call>{"name":"set_cabin_ac","arguments":{"power":"off","target_temperature":"24"}}</tool_call>"#,
            traceID: "trace-cor2-negation"
        )

        let trace = InMemoryTraceLogger()
        for var frame in frames {
            frame.stateRevision = store.currentRevision
            _ = try pipeline.execute(frame, store: store, traceLogger: trace)
        }

        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "off",
                       "Power must stay off when user explicitly requests power off — COR-2")
        XCTAssertEqual(store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, "24",
                       "Temperature must be set to 24")
    }

    @MainActor
    func testDDomainMountedPowerOffAndTemperaturePlanRunsFromCompletionToStore() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let speech = RecordingSpeechSynthesisEngine()
        let completion = #"<tool_call>{"name":"close_ac","arguments":{}}</tool_call><tool_call>{"name":"adjust_ac_temperature_to_number","arguments":{"temperature":"26"}}</tool_call>"#
        let backend = DDomainToolPlanBackend(
            cardinalityPolicy: .boundedReviewed(maximum: 2),
            completionEnvelopeProvider: { _ in
                DDomainCompletionEnvelope(
                    content: completion,
                    finishReason: "tool_calls",
                    stopReason: "end_turn",
                    toolCallCount: 2,
                    source: "cor2_mounted_model"
                )
            }
        )
        let runner = try DemoRuntimeSessionRunner.defaultRunner(
            store: store,
            traceLogger: trace,
            speech: speech,
            modelBackend: backend
        )

        let payload = try await runner.run(text: "不要打开空调，只调到26度")

        XCTAssertEqual(payload.outcome.result, .acceptedToolCall)
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "off")
        XCTAssertEqual(store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, "26")
        XCTAssertEqual(payload.readbacks.map(\.key), ["ac.power", "ac.temp_setpoint[主驾]"])
        XCTAssertTrue(payload.traceEnvelope?.entries.contains {
            $0.message == "runtime_plan_policy:atomic"
        } == true)
        XCTAssertTrue(trace.entries.contains {
            $0.stage == .decode && $0.message == "model_router:ac.power_off"
        })
        XCTAssertTrue(trace.entries.contains {
            $0.stage == .decode && $0.message == "model_router:ac_temperature.adjust_to_number"
        })
    }

    @MainActor
    func testPositive_PowerOnWithTemperature_StillWorks() throws {
        // "开空调调26" → set_cabin_ac(power=on, target_temperature=26)
        let store = DemoVehicleStateStore()
        let pipeline = try makePipeline()
        let frames = try framesFrom(
            completion: #"<tool_call>{"name":"set_cabin_ac","arguments":{"power":"on","target_temperature":"26"}}</tool_call>"#,
            traceID: "trace-cor2-positive"
        )

        let trace = InMemoryTraceLogger()
        for var frame in frames {
            frame.stateRevision = store.currentRevision
            _ = try pipeline.execute(frame, store: store, traceLogger: trace)
        }

        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on",
                       "Power must turn on when user requests power on")
        XCTAssertEqual(store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, "26",
                       "Temperature must be set to 26")
    }

    @MainActor
    func testPositive_DDomainTemperatureOnly_StillAutoPowerOns() throws {
        // D-domain path: adjust_ac_temperature_to_number(temperature=26) — no power directive
        let store = DemoVehicleStateStore()
        let pipeline = try makePipeline()
        let frames = try framesFrom(
            completion: #"<tool_call>{"name":"adjust_ac_temperature_to_number","arguments":{"temperature":"26"}}</tool_call>"#,
            traceID: "trace-cor2-ddomain"
        )

        let trace = InMemoryTraceLogger()
        for var frame in frames {
            frame.stateRevision = store.currentRevision
            _ = try pipeline.execute(frame, store: store, traceLogger: trace)
        }

        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on",
                       "D-domain temperature-only should auto-power-on (no explicit power directive)")
        XCTAssertEqual(store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, "26")
    }

    // MARK: - Helpers

    /// 从原始 completion envelope 走到 ToolCallFrame 数组，不打桩。
    private func framesFrom(completion: String, traceID: String) throws -> [ToolCallFrame] {
        let envelope = DDomainCompletionEnvelope(
            content: completion,
            finishReason: "tool_calls",
            stopReason: "end_turn",
            toolCallCount: 1,
            source: "cor2_test"
        )
        let parsedPlan = try DDomainToolCallParser.parse(envelope, policy: .exactlyOne)
        guard case let .toolCalls(parsedCalls) = parsedPlan else {
            throw ToolExecutionError.noToolCall
        }
        let irMap = DDomainIRMap.irMapCompiled
        return try parsedCalls.flatMap { parsed -> [ToolCallFrame] in
            let call = C6ToolCall(name: parsed.name, arguments: parsed.arguments)
            let irs = ToolContractNormalizer.normalize(call, irMap: irMap)
            guard !irs.isEmpty else {
                throw DDomainToolPlanFailure.irUnclassified(parsed.name)
            }
            return try irs.map {
                try ToolContractIRFrameBridge.frame(from: $0, traceID: traceID, rawCall: call)
            }
        }
    }

    private func makePipeline() throws -> C3ExecutionPipeline {
        let semantic = try SemanticContractLookup(jsonl: readRepoFile("contracts/semantic-function-contract.jsonl"))
        let stateCells = try StateCellContractLookup(yaml: readRepoFile("contracts/state-cells.yaml"))
        let risk = try RiskPolicyLookup(yaml: readRepoFile("contracts/risk-policy.yaml"))
        let allowlist = try L1DemoAllowlistLookup(yaml: readRepoFile("contracts/l1-demo-allowlist.yaml"))
        return C3ExecutionPipeline(
            semantic: semantic,
            stateCells: stateCells,
            riskPolicy: risk,
            allowlist: allowlist,
            intentConfirmed: { true }
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
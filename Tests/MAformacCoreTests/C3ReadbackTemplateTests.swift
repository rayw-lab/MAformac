import XCTest
@testable import MAformacCore

/// gap#5: readback 播报必须消费 C2 `readback_zh` 模板,不是硬编码 switch。
/// spec tool-execution:135「播报 SHALL 基于 actual mock state」+ C2 拥有 readback_zh 模板。
/// 原先 DemoVehicleStateStore.spokenText 是硬编码,氛围灯/车窗/温区 全落 "key 当前为 value" 兜底。
final class C3ReadbackTemplateTests: XCTestCase {
    @MainActor
    func testTemperatureReadbackUsesC2TemplateWithScopeAndValue() throws {
        let pipeline = try makePipeline()
        let store = DemoVehicleStateStore()
        let frame = ToolCallFrame.fixture(
            device: "ac_temperature",
            actionPrimitive: "adjust_to_number",
            slots: ["direction": "主驾"],
            value: ContractValue(ref: "ZERO", direct: "+", offset: "26", type: "SPOT"),
            stateRevision: 0
        )

        let result = try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger())
        let tempReadback = try XCTUnwrap(result.readbacks.first { $0.key == "ac.temp_setpoint[主驾]" })
        // C2 模板 "{温区}空调温度{值}度" → "主驾空调温度26度"
        XCTAssertEqual(tempReadback.spokenText, "主驾空调温度26度")
    }

    @MainActor
    func testACPowerReadbackResolvesEnumBranchFromC2Template() throws {
        let pipeline = try makePipeline()
        let store = DemoVehicleStateStore()
        let frame = ToolCallFrame.fixture(
            device: "ac",
            actionPrimitive: "power_on",
            value: ContractValue(),
            stateRevision: 0
        )

        let result = try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger())
        let acReadback = try XCTUnwrap(result.readbacks.first { $0.key == "ac.power" })
        // C2 模板 "空调{已打开|已关闭}" + value=on(values[0]) → "空调已打开"
        XCTAssertEqual(acReadback.spokenText, "空调已打开")
    }

    @MainActor
    func testWindowReadbackUsesC2PercentTemplate() throws {
        let pipeline = try makePipeline()
        let store = DemoVehicleStateStore()
        let frame = ToolCallFrame.fixture(
            device: "window",
            actionPrimitive: "by_percent",
            slots: ["position": "主驾"],
            value: ContractValue(ref: "ZERO", direct: "+", offset: "30", type: "PERCENT"),
            stateRevision: 0
        )

        let result = try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger())
        let windowReadback = try XCTUnwrap(result.readbacks.first { $0.key == "window.position[主驾]" })
        // C2 模板 "{位置}车窗开度{值}%" → "主驾车窗开度30%"
        XCTAssertEqual(windowReadback.spokenText, "主驾车窗开度30%")
    }

    @MainActor
    func testOmittedWindowReadbackKeepsDefaultDriverScopeAndCarriesOrigin() throws {
        let pipeline = try makePipeline()
        let store = DemoVehicleStateStore()
        let frame = ToolCallFrame.fixture(
            device: "window",
            actionPrimitive: "power_on",
            value: ContractValue(),
            stateRevision: 0
        )

        let result = try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger())
        let readback = try XCTUnwrap(result.readbacks.first { $0.key == "window.position[主驾]" })

        XCTAssertEqual(readback.scopeOrigin, .defaulted)
        XCTAssertEqual(readback.spokenText, "主驾车窗开度100%")
    }

    @MainActor
    func testExplicitDriverWindowReadbackKeepsDriverTextAndOrigin() throws {
        let pipeline = try makePipeline()
        let store = DemoVehicleStateStore()
        let frame = ToolCallFrame.fixture(
            device: "window",
            actionPrimitive: "power_on",
            slots: ["position": "主驾"],
            value: ContractValue(),
            stateRevision: 0
        )

        let result = try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger())
        let readback = try XCTUnwrap(result.readbacks.first { $0.key == "window.position[主驾]" })

        XCTAssertEqual(readback.scopeOrigin, .explicit)
        XCTAssertEqual(readback.spokenText, "主驾车窗开度100%")
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

private extension ToolCallFrame {
    static func fixture(
        device: String,
        actionPrimitive: String,
        slots: [String: String] = [:],
        value: ContractValue = ContractValue(),
        stateRevision: Int
    ) -> ToolCallFrame {
        ToolCallFrame(
            agentID: "vehicle-control",
            capabilityID: "cabin.\(device)",
            toolName: "vehicle_control",
            device: device,
            actionPrimitive: actionPrimitive,
            slots: slots,
            value: value,
            stateRevision: stateRevision,
            candidateSource: .upstreamToolCall
        )
    }
}

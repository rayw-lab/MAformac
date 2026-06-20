import XCTest
@testable import MAformacCore

/// gap#3: L1 allowlist 命中 device 后必须校验 action_primitive 在 reviewed primitives 内。
/// design E7 把 device + primitive 列为 L1 闭合维度;`L1DemoAllowlistEntry.primitives` 已解析但
/// 执行链原先只按 device 取 cell,没校验 primitive → 非 reviewed primitive 被当 L1 静默执行。
final class C3AllowlistPrimitiveGateTests: XCTestCase {
    @MainActor
    func testAllowlistedDeviceExecutesReviewedPrimitive() throws {
        let pipeline = try makePipeline()
        let store = DemoVehicleStateStore()
        // increase_by_exp 在 ac_temperature 的 reviewed primitives 内 → 应执行。
        let frame = ToolCallFrame.fixture(
            device: "ac_temperature",
            actionPrimitive: "increase_by_exp",
            slots: ["direction": "主驾"],
            value: ContractValue(ref: "CUR", direct: "+", offset: "LITTLE", type: "EXP"),
            stateRevision: 0
        )
        XCTAssertNoThrow(try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger()))
    }

    @MainActor
    func testAllowlistedDeviceRejectsNonReviewedPrimitive() throws {
        let pipeline = try makePipeline()
        let store = DemoVehicleStateStore()
        // increase_by_number 是合法 C1 primitive 但不在 ac_temperature L1 reviewed primitives →
        // 不得作为 L1 静默执行,应 guardDenied(primitive_not_in_l1_allowlist)。
        let frame = ToolCallFrame.fixture(
            device: "ac_temperature",
            actionPrimitive: "increase_by_number",
            slots: ["direction": "主驾"],
            value: ContractValue(ref: "CUR", direct: "+", offset: "2", type: "SPOT"),
            stateRevision: 0
        )
        XCTAssertThrowsError(try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger())) { error in
            XCTAssertEqual(error as? ToolExecutionError, .guardDenied("primitive_not_in_l1_allowlist"))
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

import XCTest
@testable import MAformacCore

/// FA-4 / B07=B: window risk gate — moving refuse; stationary P/N allow, D/R refuse; bad state fail-closed.
final class RiskPolicyLookupWindowSafetyTests: XCTestCase {
    private func lookup() throws -> RiskPolicyLookup {
        try RiskPolicyLookup(yaml: readRepoFile("contracts/risk-policy.yaml"))
    }

    private func readRepoFile(_ relativePath: String) throws -> String {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return try String(contentsOf: root.appendingPathComponent(relativePath), encoding: .utf8)
    }

    func testWindowRuleIsMountedInPolicy() throws {
        let risk = try lookup()
        let windowRules = risk.forbiddenRules.filter { $0.devices.contains("window") }
        XCTAssertEqual(windowRules.count, 1)
        XCTAssertEqual(windowRules[0].stationaryGearAllow, ["P", "N"])
        XCTAssertEqual(windowRules[0].gearCell, "vehicle.gear")
    }

    func testMovingSpeedRefusesWindow() throws {
        let risk = try lookup()
        let decision = risk.evaluate(
            device: "window",
            stateValues: ["vehicle.speed": "12", "vehicle.gear": "P"]
        )
        XCTAssertEqual(
            decision,
            .refuse(reason: "行驶中为了安全暂时不能开窗, 停稳后我再帮您")
        )
    }

    func testStationaryParkAllowsWindow() throws {
        let risk = try lookup()
        let decision = risk.evaluate(
            device: "window",
            stateValues: ["vehicle.speed": "0", "vehicle.gear": "P"]
        )
        XCTAssertEqual(decision, .allow)
    }

    func testStationaryNeutralAllowsWindow() throws {
        let risk = try lookup()
        let decision = risk.evaluate(
            device: "window",
            stateValues: ["vehicle.speed": "0", "vehicle.gear": "N"]
        )
        XCTAssertEqual(decision, .allow)
    }

    func testStationaryDriveRefusesWindow() throws {
        let risk = try lookup()
        let decision = risk.evaluate(
            device: "window",
            stateValues: ["vehicle.speed": "0", "vehicle.gear": "D"]
        )
        XCTAssertEqual(
            decision,
            .refuse(reason: "当前挡位不适合开窗, 请挂入 P 或 N 挡后再试")
        )
    }

    func testStationaryReverseRefusesWindow() throws {
        let risk = try lookup()
        let decision = risk.evaluate(
            device: "window",
            stateValues: ["vehicle.speed": "0", "vehicle.gear": "R"]
        )
        XCTAssertEqual(
            decision,
            .refuse(reason: "当前挡位不适合开窗, 请挂入 P 或 N 挡后再试")
        )
    }

    func testMissingSpeedFailClosed() throws {
        let risk = try lookup()
        let decision = risk.evaluate(
            device: "window",
            stateValues: ["vehicle.gear": "P"]
        )
        XCTAssertEqual(
            decision,
            .refuse(reason: "车速或挡位状态未知, 安全起见暂不执行开窗操作, 请确认传感器正常后重试")
        )
    }

    func testMissingGearAtStationaryFailClosed() throws {
        let risk = try lookup()
        let decision = risk.evaluate(
            device: "window",
            stateValues: ["vehicle.speed": "0"]
        )
        XCTAssertEqual(
            decision,
            .refuse(reason: "车速或挡位状态未知, 安全起见暂不执行开窗操作, 请确认传感器正常后重试")
        )
    }

    func testMalformedSpeedFailClosed() throws {
        let risk = try lookup()
        let decision = risk.evaluate(
            device: "window",
            stateValues: ["vehicle.speed": "fast", "vehicle.gear": "P"]
        )
        XCTAssertEqual(
            decision,
            .refuse(reason: "车速或挡位状态未知, 安全起见暂不执行开窗操作, 请确认传感器正常后重试")
        )
    }

    func testUnknownGearFailClosed() throws {
        let risk = try lookup()
        let decision = risk.evaluate(
            device: "window",
            stateValues: ["vehicle.speed": "0", "vehicle.gear": "X"]
        )
        XCTAssertEqual(
            decision,
            .refuse(reason: "当前挡位不适合开窗, 请挂入 P 或 N 挡后再试")
        )
    }

    func testDoorRuleUnchangedWithoutGearGate() throws {
        let risk = try lookup()
        // Stationary door remains allowed (door rule has no gear allowlist).
        let decision = risk.evaluate(
            device: "car_door",
            stateValues: ["vehicle.speed": "0", "vehicle.gear": "D"]
        )
        XCTAssertEqual(decision, .allow)
    }

    @MainActor
    func testPipelineRefusesMovingWindow() throws {
        let store = DemoVehicleStateStore()
        _ = store.applyMockTransition(DemoMockTransition(key: "vehicle.speed", desiredValue: "30"))
        _ = store.applyMockTransition(DemoMockTransition(key: "vehicle.gear", desiredValue: "D"))
        let pipeline = try makeWindowPipeline()
        let frame = ToolCallFrame(
            agentID: "vehicle-control",
            capabilityID: "vehicle.window.position",
            toolName: "open_window_by_number",
            device: "window",
            actionPrimitive: "by_percent",
            slots: ["position": "主驾"],
            value: ContractValue(ref: "CUR", direct: "+", offset: "50", type: "PERCENT"),
            stateRevision: store.currentRevision,
            candidateSource: .fastPath
        )
        XCTAssertThrowsError(try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger())) { error in
            XCTAssertEqual(
                error as? ToolExecutionError,
                .guardDenied("行驶中为了安全暂时不能开窗, 停稳后我再帮您")
            )
        }
    }

    @MainActor
    func testPipelineRefusesStationaryDriveWindow() throws {
        let store = DemoVehicleStateStore()
        _ = store.applyMockTransition(DemoMockTransition(key: "vehicle.speed", desiredValue: "0"))
        _ = store.applyMockTransition(DemoMockTransition(key: "vehicle.gear", desiredValue: "D"))
        let pipeline = try makeWindowPipeline()
        let frame = ToolCallFrame(
            agentID: "vehicle-control",
            capabilityID: "vehicle.window.position",
            toolName: "open_window_by_number",
            device: "window",
            actionPrimitive: "by_percent",
            slots: ["position": "主驾"],
            value: ContractValue(ref: "CUR", direct: "+", offset: "50", type: "PERCENT"),
            stateRevision: store.currentRevision,
            candidateSource: .fastPath
        )
        XCTAssertThrowsError(try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger())) { error in
            XCTAssertEqual(
                error as? ToolExecutionError,
                .guardDenied("当前挡位不适合开窗, 请挂入 P 或 N 挡后再试")
            )
        }
    }

    private func makeWindowPipeline() throws -> C3ExecutionPipeline {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        func read(_ name: String) throws -> String {
            try String(contentsOf: root.appendingPathComponent(name), encoding: .utf8)
        }
        return C3ExecutionPipeline(
            semantic: try SemanticContractLookup(jsonl: read("contracts/semantic-function-contract.jsonl")),
            stateCells: try StateCellContractLookup(yaml: read("contracts/state-cells.yaml")),
            riskPolicy: try RiskPolicyLookup(yaml: read("contracts/risk-policy.yaml")),
            allowlist: try L1DemoAllowlistLookup(yaml: read("contracts/l1-demo-allowlist.yaml")),
            intentConfirmed: { true }
        )
    }
}

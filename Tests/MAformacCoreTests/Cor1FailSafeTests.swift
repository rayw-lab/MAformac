import XCTest
@testable import MAformacCore

/// COR-1 fail-safe proofs: speed unknown/empty/non-numeric/negative → refuse (fail-closed),
/// not Int() ?? 0 → allow (fail-open).
///
/// Verifies both the RiskPolicyLookup.evaluate unit contract and the pipeline-level
/// integration: adapter is never called, store is completely unchanged.
@MainActor
final class Cor1FailSafeTests: XCTestCase {

    // MARK: - RiskPolicyLookup.evaluate unit tests

    func testUnknownSpeedNilRefusesDoorOpen() throws {
        let risk = try RiskPolicyLookup(yaml: readRepoFile("contracts/risk-policy.yaml"))
        let decision = risk.evaluate(device: "car_door", stateValues: [:])
        XCTAssertEqual(decision, .refuse(reason: "车速状态未知, 安全起见暂不执行开门操作, 请确认传感器正常后重试"))
    }

    func testUnknownSpeedEmptyRefusesDoorOpen() throws {
        let risk = try RiskPolicyLookup(yaml: readRepoFile("contracts/risk-policy.yaml"))
        let decision = risk.evaluate(device: "car_door", stateValues: ["vehicle.speed": ""])
        XCTAssertEqual(decision, .refuse(reason: "车速状态未知, 安全起见暂不执行开门操作, 请确认传感器正常后重试"))
    }

    func testUnknownSpeedWhitespaceOnlyRefusesDoorOpen() throws {
        let risk = try RiskPolicyLookup(yaml: readRepoFile("contracts/risk-policy.yaml"))
        let decision = risk.evaluate(device: "car_door", stateValues: ["vehicle.speed": "   "])
        XCTAssertEqual(decision, .refuse(reason: "车速状态未知, 安全起见暂不执行开门操作, 请确认传感器正常后重试"))
    }

    func testNonNumericSpeedRefusesDoorOpen() throws {
        let risk = try RiskPolicyLookup(yaml: readRepoFile("contracts/risk-policy.yaml"))
        let decision = risk.evaluate(device: "car_door", stateValues: ["vehicle.speed": "fast"])
        XCTAssertEqual(decision, .refuse(reason: "车速状态未知, 安全起见暂不执行开门操作, 请确认传感器正常后重试"))
    }

    func testNegativeSpeedRefusesDoorOpen() throws {
        let risk = try RiskPolicyLookup(yaml: readRepoFile("contracts/risk-policy.yaml"))
        let decision = risk.evaluate(device: "car_door", stateValues: ["vehicle.speed": "-5"])
        XCTAssertEqual(decision, .refuse(reason: "车速状态未知, 安全起见暂不执行开门操作, 请确认传感器正常后重试"))
    }

    func testZeroSpeedAllowsDoorOpen() throws {
        let risk = try RiskPolicyLookup(yaml: readRepoFile("contracts/risk-policy.yaml"))
        let decision = risk.evaluate(device: "car_door", stateValues: ["vehicle.speed": "0"])
        XCTAssertEqual(decision, .allow)
    }

    func testPositiveSpeedRefusesDoorOpen() throws {
        let risk = try RiskPolicyLookup(yaml: readRepoFile("contracts/risk-policy.yaml"))
        let decision = risk.evaluate(device: "car_door", stateValues: ["vehicle.speed": "12"])
        XCTAssertEqual(decision, .refuse(reason: "行驶中为了安全暂时不能开门, 停稳后我再帮您"))
    }

    func testNonDoorDeviceNotAffectedBySpeedRule() throws {
        let risk = try RiskPolicyLookup(yaml: readRepoFile("contracts/risk-policy.yaml"))
        // ac_temperature is not in the forbidden devices list
        let decision = risk.evaluate(device: "ac_temperature", stateValues: ["vehicle.speed": "12"])
        XCTAssertEqual(decision, .allow)
    }

    // MARK: - Pipeline-level integration: adapter not called + store unchanged

    func testPipelineUnknownSpeedRefusesDoorOpenAndStoreUnchanged() throws {
        let store = DemoVehicleStateStore()
        // Remove vehicle.speed cell to simulate unknown state
        let storeWithoutSpeed = storeWithoutSpeedCell()
        let trace = InMemoryTraceLogger()
        let pipeline = try makePipeline(intentConfirmed: true)

        let frame = ToolCallFrame.fixture(
            device: "car_door",
            actionPrimitive: "power_on",
            stateRevision: storeWithoutSpeed.currentRevision
        )

        let snapshotBefore = snapshotValues(storeWithoutSpeed)

        XCTAssertThrowsError(try pipeline.execute(frame, store: storeWithoutSpeed, traceLogger: trace)) { error in
            XCTAssertEqual(error as? ToolExecutionError, .guardDenied("车速状态未知, 安全起见暂不执行开门操作, 请确认传感器正常后重试"))
        }

        let snapshotAfter = snapshotValues(storeWithoutSpeed)
        XCTAssertEqual(snapshotAfter, snapshotBefore, "store must be completely unchanged after fail-closed refusal")

        // Verify adapter was NOT called: no execute stage in trace
        let executeStages = trace.entries.filter { $0.stage == .execute }
        XCTAssertTrue(executeStages.isEmpty, "adapter must not be called when guard denies")

        // Verify guard stage recorded the refusal
        let guardEntries = trace.entries.filter { $0.stage == .guard }
        XCTAssertFalse(guardEntries.isEmpty, "guard must be recorded")
        XCTAssertTrue(guardEntries.contains { $0.message.contains("状态未知") })
    }

    func testPipelineEmptySpeedRefusesDoorOpenAndStoreUnchanged() throws {
        let store = DemoVehicleStateStore()
        // Set vehicle.speed to empty string
        _ = store.applyMockTransition(DemoMockTransition(key: "vehicle.speed", desiredValue: ""))
        let pipeline = try makePipeline(intentConfirmed: true)
        let trace = InMemoryTraceLogger()
        let frame = ToolCallFrame.fixture(
            device: "car_door",
            actionPrimitive: "power_on",
            stateRevision: store.currentRevision
        )

        let snapshotBefore = snapshotValues(store)

        XCTAssertThrowsError(try pipeline.execute(frame, store: store, traceLogger: trace)) { error in
            XCTAssertEqual(error as? ToolExecutionError, .guardDenied("车速状态未知, 安全起见暂不执行开门操作, 请确认传感器正常后重试"))
        }

        let snapshotAfter = snapshotValues(store)
        XCTAssertEqual(snapshotAfter, snapshotBefore, "store must be completely unchanged after fail-closed refusal")

        let executeStages = trace.entries.filter { $0.stage == .execute }
        XCTAssertTrue(executeStages.isEmpty, "adapter must not be called when guard denies")
    }

    func testPipelineNonNumericSpeedRefusesDoorOpenAndStoreUnchanged() throws {
        let store = DemoVehicleStateStore()
        _ = store.applyMockTransition(DemoMockTransition(key: "vehicle.speed", desiredValue: "not_a_number"))
        let pipeline = try makePipeline(intentConfirmed: true)
        let trace = InMemoryTraceLogger()
        let frame = ToolCallFrame.fixture(
            device: "car_door",
            actionPrimitive: "power_on",
            stateRevision: store.currentRevision
        )

        let snapshotBefore = snapshotValues(store)

        XCTAssertThrowsError(try pipeline.execute(frame, store: store, traceLogger: trace)) { error in
            XCTAssertEqual(error as? ToolExecutionError, .guardDenied("车速状态未知, 安全起见暂不执行开门操作, 请确认传感器正常后重试"))
        }

        let snapshotAfter = snapshotValues(store)
        XCTAssertEqual(snapshotAfter, snapshotBefore, "store must be completely unchanged after fail-closed refusal")

        let executeStages = trace.entries.filter { $0.stage == .execute }
        XCTAssertTrue(executeStages.isEmpty, "adapter must not be called when guard denies")
    }

    func testPipelineZeroSpeedAllowsDoorOpenAndAdapterCalled() throws {
        // This is a positive control: zero speed should allow the action
        let store = DemoVehicleStateStore()
        // vehicle.speed defaults to "0" in defaultCells
        let trace = InMemoryTraceLogger()
        let pipeline = try makePipeline(intentConfirmed: true)
        let frame = ToolCallFrame.fixture(
            device: "car_door",
            actionPrimitive: "power_on",
            stateRevision: store.currentRevision
        )

        // At speed 0, door open should be allowed by the risk policy.
        // It will then be subject to other guards (allowlist, intent, etc.),
        // but the risk policy gate should pass.
        // We verify that the risk policy gate does NOT block it.
        // If it throws, it should NOT be due to the risk policy refusal.
        do {
            _ = try pipeline.execute(frame, store: store, traceLogger: trace)
            // If it succeeds, adapter was called
            let executeStages = trace.entries.filter { $0.stage == .execute }
            XCTAssertFalse(executeStages.isEmpty, "adapter should be called for zero-speed door open")
        } catch let error as ToolExecutionError {
            // If it fails, it must NOT be because of risk policy refusal
            switch error {
            case .guardDenied(let reason):
                XCTAssertFalse(reason.contains("行驶中") || reason.contains("状态未知"),
                               "zero speed should not trigger risk policy refusal, got: \(reason)")
            default:
                break
            }
        }
    }

    // MARK: - Helpers

    /// Creates a store without the vehicle.speed cell (simulating unknown state).
    private func storeWithoutSpeedCell() -> DemoVehicleStateStore {
        let cells = DemoVehicleStateStore.defaultCells().filter { $0.key != "vehicle.speed" }
        return DemoVehicleStateStore(cells: cells)
    }

    /// Snapshot of all store key→value pairs for before/after comparison.
    private func snapshotValues(_ store: DemoVehicleStateStore) -> [String: String] {
        var snapshot: [String: String] = [:]
        for cell in store.cells {
            snapshot[cell.key] = cell.actualValue
        }
        return snapshot
    }

    private func makePipeline(intentConfirmed: Bool) throws -> C3ExecutionPipeline {
        let semantic = try SemanticContractLookup(jsonl: readRepoFile("contracts/semantic-function-contract.jsonl"))
        let stateCells = try StateCellContractLookup(yaml: readRepoFile("contracts/state-cells.yaml"))
        let risk = try RiskPolicyLookup(yaml: readRepoFile("contracts/risk-policy.yaml"))
        let allowlist = try L1DemoAllowlistLookup(yaml: readRepoFile("contracts/l1-demo-allowlist.yaml"))
        return C3ExecutionPipeline(
            semantic: semantic,
            stateCells: stateCells,
            riskPolicy: risk,
            allowlist: allowlist,
            intentConfirmed: { intentConfirmed }
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
        id: String = UUID().uuidString,
        device: String,
        actionPrimitive: String,
        slots: [String: String] = [:],
        value: ContractValue = ContractValue(),
        stateRevision: Int
    ) -> ToolCallFrame {
        ToolCallFrame(
            id: id,
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
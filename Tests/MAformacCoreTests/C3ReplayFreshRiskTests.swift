import XCTest
@testable import MAformacCore

/// G3 first knife: settled stale replay must re-evaluate live risk before returning prior success.
/// Mutation-negative: removing `evaluateFreshRiskOrThrow` from the replay path makes these fail.
final class C3ReplayFreshRiskTests: XCTestCase {
    private let movingRefuse = "行驶中为了安全暂时不能开窗, 停稳后我再帮您"
    private let gearRefuse = "当前挡位不适合开窗, 请挂入 P 或 N 挡后再试"
    private let unknownRefuse = "车速或挡位状态未知, 安全起见暂不执行开窗操作, 请确认传感器正常后重试"

    @MainActor
    func testSettledReplayRefusesWhenLiveSpeedBecomesMoving() throws {
        let store = DemoVehicleStateStore()
        let pipeline = try makePipeline()
        let parentID = "cmd-g3-fresh-risk-moving"
        let first = windowFrame(id: parentID, stateRevision: store.currentRevision)

        let firstResult = try pipeline.execute(first, store: store, traceLogger: InMemoryTraceLogger())
        XCTAssertFalse(firstResult.readbacks.isEmpty)
        let windowAfterFirst = try XCTUnwrap(store.cell(for: "window.position[主驾]"))

        _ = store.applyMockTransition(DemoMockTransition(key: "vehicle.speed", desiredValue: "30"))
        _ = store.applyMockTransition(DemoMockTransition(key: "vehicle.gear", desiredValue: "P"))
        XCTAssertEqual(store.cell(for: "vehicle.speed")?.actualValue, "30")

        let staleRetry = windowFrame(id: parentID, stateRevision: 0)
        let trace = InMemoryTraceLogger()
        XCTAssertThrowsError(try pipeline.execute(staleRetry, store: store, traceLogger: trace)) { error in
            XCTAssertEqual(error as? ToolExecutionError, .guardDenied(movingRefuse))
        }

        XCTAssertFalse(trace.entries.contains { $0.stage == .guard && $0.message == "stale_retry_replay" })
        XCTAssertTrue(trace.entries.contains { $0.stage == .guard && $0.message == movingRefuse })
        let windowAfterRefuse = try XCTUnwrap(store.cell(for: "window.position[主驾]"))
        XCTAssertEqual(windowAfterRefuse.actualValue, windowAfterFirst.actualValue)
        XCTAssertEqual(windowAfterRefuse.revision, windowAfterFirst.revision)
        XCTAssertEqual(windowAfterRefuse.timestamp, windowAfterFirst.timestamp)
    }

    @MainActor
    func testSettledReplayRefusesWhenLiveGearBecomesDrive() throws {
        let store = DemoVehicleStateStore()
        let pipeline = try makePipeline()
        let parentID = "cmd-g3-fresh-risk-gear-d"
        _ = try pipeline.execute(
            windowFrame(id: parentID, stateRevision: store.currentRevision),
            store: store,
            traceLogger: InMemoryTraceLogger()
        )
        let windowAfterFirst = try XCTUnwrap(store.cell(for: "window.position[主驾]"))

        _ = store.applyMockTransition(DemoMockTransition(key: "vehicle.speed", desiredValue: "0"))
        _ = store.applyMockTransition(DemoMockTransition(key: "vehicle.gear", desiredValue: "D"))

        let trace = InMemoryTraceLogger()
        XCTAssertThrowsError(
            try pipeline.execute(windowFrame(id: parentID, stateRevision: 0), store: store, traceLogger: trace)
        ) { error in
            XCTAssertEqual(error as? ToolExecutionError, .guardDenied(gearRefuse))
        }
        XCTAssertFalse(trace.entries.contains { $0.stage == .guard && $0.message == "stale_retry_replay" })
        XCTAssertEqual(store.cell(for: "window.position[主驾]")?.revision, windowAfterFirst.revision)
    }

    @MainActor
    func testSettledReplayUnknownSpeedFailClosed() throws {
        let store = DemoVehicleStateStore()
        let pipeline = try makePipeline()
        let parentID = "cmd-g3-fresh-risk-unknown-speed"
        _ = try pipeline.execute(
            windowFrame(id: parentID, stateRevision: store.currentRevision),
            store: store,
            traceLogger: InMemoryTraceLogger()
        )
        let windowAfterFirst = try XCTUnwrap(store.cell(for: "window.position[主驾]"))

        _ = store.applyMockTransition(DemoMockTransition(key: "vehicle.speed", desiredValue: " "))
        _ = store.applyMockTransition(DemoMockTransition(key: "vehicle.gear", desiredValue: "P"))

        let trace = InMemoryTraceLogger()
        XCTAssertThrowsError(
            try pipeline.execute(windowFrame(id: parentID, stateRevision: 0), store: store, traceLogger: trace)
        ) { error in
            XCTAssertEqual(error as? ToolExecutionError, .guardDenied(unknownRefuse))
        }
        XCTAssertFalse(trace.entries.contains { $0.stage == .guard && $0.message == "stale_retry_replay" })
        XCTAssertEqual(store.cell(for: "window.position[主驾]")?.revision, windowAfterFirst.revision)
    }

    @MainActor
    func testSettledReplayUnknownGearFailClosed() throws {
        let store = DemoVehicleStateStore()
        let pipeline = try makePipeline()
        let parentID = "cmd-g3-fresh-risk-unknown-gear"
        _ = try pipeline.execute(
            windowFrame(id: parentID, stateRevision: store.currentRevision),
            store: store,
            traceLogger: InMemoryTraceLogger()
        )

        _ = store.applyMockTransition(DemoMockTransition(key: "vehicle.speed", desiredValue: "0"))
        _ = store.applyMockTransition(DemoMockTransition(key: "vehicle.gear", desiredValue: ""))

        let trace = InMemoryTraceLogger()
        XCTAssertThrowsError(
            try pipeline.execute(windowFrame(id: parentID, stateRevision: 0), store: store, traceLogger: trace)
        ) { error in
            XCTAssertEqual(error as? ToolExecutionError, .guardDenied(unknownRefuse))
        }
        XCTAssertFalse(trace.entries.contains { $0.stage == .guard && $0.message == "stale_retry_replay" })
    }

    @MainActor
    func testSettledReplayStillAllowedWhenLiveStateRemainsSafe() throws {
        let store = DemoVehicleStateStore()
        let pipeline = try makePipeline()
        let parentID = "cmd-g3-fresh-risk-still-safe"
        let first = windowFrame(id: parentID, stateRevision: store.currentRevision)
        _ = try pipeline.execute(first, store: store, traceLogger: InMemoryTraceLogger())
        let windowAfterFirst = try XCTUnwrap(store.cell(for: "window.position[主驾]"))

        // Keep stationary P; bump unrelated cell so revision advances and stale path engages.
        _ = store.applyMockTransition(DemoMockTransition(key: "ambient.power", desiredValue: "on"))
        XCTAssertEqual(store.cell(for: "vehicle.speed")?.actualValue, "0")
        XCTAssertEqual(store.cell(for: "vehicle.gear")?.actualValue, "P")

        let trace = InMemoryTraceLogger()
        let replay = try pipeline.execute(
            windowFrame(id: parentID, stateRevision: 0),
            store: store,
            traceLogger: trace
        )
        XCTAssertFalse(replay.readbacks.isEmpty)
        XCTAssertTrue(trace.entries.contains { $0.stage == .guard && $0.message == "stale_retry_replay" })
        XCTAssertEqual(store.cell(for: "window.position[主驾]")?.revision, windowAfterFirst.revision)
        XCTAssertEqual(store.cell(for: "window.position[主驾]")?.actualValue, windowAfterFirst.actualValue)
    }

    private func windowFrame(id: String, stateRevision: Int) -> ToolCallFrame {
        ToolCallFrame.fixture(
            id: id,
            device: "window",
            actionPrimitive: "power_on",
            slots: ["position": "主驾"],
            stateRevision: stateRevision
        )
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
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return try String(contentsOf: root.appendingPathComponent(relativePath), encoding: .utf8)
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
        // GOVERNANCE: bypasses NLU by design (not product behavior)
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

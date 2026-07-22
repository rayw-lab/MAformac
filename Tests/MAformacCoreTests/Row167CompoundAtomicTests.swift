import XCTest
@testable import MAformacCore

/// G3 knife 3 / row167 compound atomic:
/// power-if-needed + mode + scoped temp as one action (0…3 differential transitions);
/// mid-action adapter failure rolls back every cell (no partial store success).
final class Row167CompoundAtomicTests: XCTestCase {

    // MARK: - Happy path: 0…3 differential transitions

    @MainActor
    func testColdStart_threeUnsatisfied_plansPowerModeTemp() throws {
        let store = DemoVehicleStateStore()
        // default: power=off, mode=制冷, temp[主驾]=24 → target 26 needs all three
        let pipeline = try makePipeline()
        let frame = row167Frame(temperature: "26", stateRevision: store.currentRevision)

        let preflight = try pipeline.preflight(frame, store: store)
        XCTAssertEqual(
            preflight.transitions.map(\.key),
            ["ac.power", "ac.mode", "ac.temp_setpoint[主驾]"]
        )
        XCTAssertEqual(preflight.transitions.map(\.desiredValue), ["on", "制热", "26"])

        let result = try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger())
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(store.cell(for: "ac.mode")?.actualValue, "制热")
        XCTAssertEqual(store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, "26")
        XCTAssertEqual(result.mutationCount, 3)
        XCTAssertEqual(result.readbacks.map(\.key), ["ac.power", "ac.mode", "ac.temp_setpoint[主驾]"])
        XCTAssertEqual(result.provenance, [.firstExecution, .firstExecution, .firstExecution])
    }

    @MainActor
    func testColdStart_tempAlreadyAtTarget_twoTransitions_powerAndMode() throws {
        let store = DemoVehicleStateStore()
        // default temp already 24; target 24 → skip temp
        let pipeline = try makePipeline()
        let frame = row167Frame(temperature: "24", stateRevision: store.currentRevision)

        let preflight = try pipeline.preflight(frame, store: store)
        XCTAssertEqual(preflight.transitions.map(\.key), ["ac.power", "ac.mode"])
        XCTAssertEqual(preflight.transitions.map(\.desiredValue), ["on", "制热"])

        let result = try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger())
        XCTAssertEqual(result.mutationCount, 2)
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(store.cell(for: "ac.mode")?.actualValue, "制热")
        XCTAssertEqual(store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, "24")
    }

    @MainActor
    func testOnlyTempUnsatisfied_singleTransition() throws {
        let store = DemoVehicleStateStore()
        _ = store.applyMockTransition(DemoMockTransition(key: "ac.power", desiredValue: "on", source: .user))
        _ = store.applyMockTransition(DemoMockTransition(key: "ac.mode", desiredValue: "制热", source: .user))
        _ = store.applyMockTransition(DemoMockTransition(key: "ac.temp_setpoint[主驾]", desiredValue: "20", source: .user))
        let pipeline = try makePipeline()
        let frame = row167Frame(temperature: "24", stateRevision: store.currentRevision)

        let preflight = try pipeline.preflight(frame, store: store)
        XCTAssertEqual(preflight.transitions.map(\.key), ["ac.temp_setpoint[主驾]"])
        XCTAssertEqual(preflight.transitions.map(\.desiredValue), ["24"])

        let result = try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger())
        XCTAssertEqual(result.mutationCount, 1)
        XCTAssertEqual(store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, "24")
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(store.cell(for: "ac.mode")?.actualValue, "制热")
    }

    @MainActor
    func testFullTargetsSatisfied_zeroTransitions() throws {
        let store = DemoVehicleStateStore()
        _ = store.applyMockTransition(DemoMockTransition(key: "ac.power", desiredValue: "on", source: .user))
        _ = store.applyMockTransition(DemoMockTransition(key: "ac.mode", desiredValue: "制热", source: .user))
        _ = store.applyMockTransition(DemoMockTransition(key: "ac.temp_setpoint[主驾]", desiredValue: "24", source: .user))
        let before = storeSnapshot(store)
        let pipeline = try makePipeline()
        let frame = row167Frame(temperature: "24", stateRevision: store.currentRevision)

        let preflight = try pipeline.preflight(frame, store: store)
        XCTAssertTrue(preflight.transitions.isEmpty)

        let result = try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger())
        XCTAssertEqual(result.mutationCount, 0)
        XCTAssertTrue(result.readbacks.isEmpty)
        assertStoreUnchanged(store, before: before)
    }

    @MainActor
    func testPlainRow164_withoutModeSlot_doesNotTouchMode() throws {
        let store = DemoVehicleStateStore()
        let modeBefore = store.cell(for: "ac.mode")?.actualValue
        let pipeline = try makePipeline()
        let frame = ToolCallFrame(
            id: "cmd-row164",
            agentID: "vehicle-control",
            capabilityID: "vehicle.ac.temperature",
            toolName: "adjust_ac_temperature_to_number",
            device: "ac_temperature",
            actionPrimitive: "adjust_to_number",
            slots: [:],
            value: ContractValue(direct: "26", type: "SPOT"),
            stateRevision: store.currentRevision,
            candidateSource: .fastPath
        )

        let preflight = try pipeline.preflight(frame, store: store)
        XCTAssertFalse(preflight.transitions.contains { $0.key == "ac.mode" })
        _ = try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger())
        XCTAssertEqual(store.cell(for: "ac.mode")?.actualValue, modeBefore)
        XCTAssertEqual(store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, "26")
    }

    // MARK: - Rollback: adapter mid-failure → 0 cells committed

    @MainActor
    func testMidAdapterFailure_rollsBackPriorTransitions() throws {
        // Remove ac.mode so power applies then mode adapter throws missingStateCell.
        let cells = DemoVehicleStateStore.defaultCells().filter { $0.key != "ac.mode" }
        let store = DemoVehicleStateStore(cells: cells)
        let before = storeSnapshot(store)
        let pipeline = try makePipeline()
        let frame = row167Frame(temperature: "26", stateRevision: store.currentRevision)

        XCTAssertThrowsError(
            try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger())
        ) { error in
            XCTAssertEqual(error as? DemoRuntimeAdapterError, .missingStateCell("ac.mode"))
        }

        // Whole action rollback: power must not stay "on".
        assertStoreUnchanged(store, before: before)
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "off")
        XCTAssertEqual(store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, "24")
        XCTAssertNil(store.cell(for: "ac.mode"))
    }

    @MainActor
    func testRiskRefuseBeforeMutations_storeUnchanged() throws {
        // AC temperature has no speed/gear risk today; use window-like refuse by
        // injecting an invalid mode enum so plan fails closed before any write.
        let store = DemoVehicleStateStore()
        let before = storeSnapshot(store)
        let pipeline = try makePipeline()
        var frame = row167Frame(temperature: "26", stateRevision: store.currentRevision)
        frame = ToolCallFrame(
            id: frame.id,
            agentID: frame.agentID,
            capabilityID: frame.capabilityID,
            toolName: frame.toolName,
            device: frame.device,
            actionPrimitive: frame.actionPrimitive,
            slots: [
                "direction": "主驾",
                "mode": "不存在的模式",
                "adjustment_mode": "摄氏度",
            ],
            value: frame.value,
            stateRevision: frame.stateRevision,
            candidateSource: frame.candidateSource
        )

        XCTAssertThrowsError(
            try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger())
        ) { error in
            XCTAssertEqual(error as? ToolExecutionError, .schemaInvalid(.unknownEnum("ac.mode")))
        }
        assertStoreUnchanged(store, before: before)
    }

    // MARK: - Route path: runner + mutation boundary

    @MainActor
    func testRoute_coldStart26_mutationThree() async throws {
        let harness = try RouteHarness()
        let result = try await harness.route.route(text: "主驾制热调26度")
        let exec = try XCTUnwrap(result.execution)
        XCTAssertEqual(harness.route.runnerCallCount, 1)
        XCTAssertEqual(exec.payload.mutationCount, 3)
        XCTAssertEqual(harness.store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(harness.store.cell(for: "ac.mode")?.actualValue, "制热")
        XCTAssertEqual(harness.store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, "26")
    }

    @MainActor
    func testRoute_onlyTempUnsatisfied_mutationOne() async throws {
        let harness = try RouteHarness()
        _ = harness.store.applyMockTransition(
            DemoMockTransition(key: "ac.power", desiredValue: "on", source: .user)
        )
        _ = harness.store.applyMockTransition(
            DemoMockTransition(key: "ac.mode", desiredValue: "制热", source: .user)
        )
        _ = harness.store.applyMockTransition(
            DemoMockTransition(key: "ac.temp_setpoint[主驾]", desiredValue: "20", source: .user)
        )
        let result = try await harness.route.route(text: "主驾制热调24度")
        let exec = try XCTUnwrap(result.execution)
        XCTAssertEqual(harness.route.runnerCallCount, 1)
        XCTAssertEqual(exec.payload.mutationCount, 1)
        XCTAssertEqual(harness.store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, "24")
    }

    // MARK: - Helpers

    @MainActor
    private struct RouteHarness {
        let store: DemoVehicleStateStore
        let route: DemoSliceRoute
        init() throws {
            let store = DemoVehicleStateStore()
            self.store = store
            self.route = try DemoSliceRoute(
                store: store,
                traceLogger: InMemoryTraceLogger(),
                speech: RecordingSpeechSynthesisEngine()
            )
        }
    }

    private struct StoreSnap {
        let revision: Int
        let cells: [DemoVehicleStateCell]
    }

    @MainActor
    private func storeSnapshot(_ store: DemoVehicleStateStore) -> StoreSnap {
        StoreSnap(revision: store.currentRevision, cells: store.cells)
    }

    @MainActor
    private func assertStoreUnchanged(_ store: DemoVehicleStateStore, before: StoreSnap) {
        XCTAssertEqual(store.currentRevision, before.revision)
        XCTAssertEqual(store.cells, before.cells)
    }

    private func row167Frame(temperature: String, stateRevision: Int, id: String = UUID().uuidString) -> ToolCallFrame {
        ToolCallFrame(
            id: id,
            agentID: "vehicle-control",
            capabilityID: "vehicle.ac.temperature",
            toolName: "adjust_ac_temperature_to_number",
            device: "ac_temperature",
            actionPrimitive: "adjust_to_number",
            slots: [
                "direction": "主驾",
                "mode": "制热",
                "adjustment_mode": "摄氏度",
            ],
            value: ContractValue(direct: temperature, type: "SPOT", sourceUnit: .celsius),
            stateRevision: stateRevision,
            candidateSource: .fastPath
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

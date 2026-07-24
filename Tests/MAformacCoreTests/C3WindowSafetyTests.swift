import XCTest
@testable import MAformacCore

/// G3 knife 2 / R2-Q4: window CUR quartet + B07 safety on the shared C3 path.
/// Covers 20→70 success, 70→120 range refusal (runner attempt=1, mutation=0),
/// generic「打开车窗」notInCatalog, and stationary/moving/gear refuse.
final class C3WindowSafetyTests: XCTestCase {
    private let movingRefuse = "行驶中为了安全暂时不能开窗, 停稳后我再帮您"
    private let gearRefuse = "当前挡位不适合开窗, 请挂入 P 或 N 挡后再试"

    // MARK: - C3 CUR quartet

    @MainActor
    func testCUR_prestate20_plus50_yields70_otherWindowsUnchanged() throws {
        let store = DemoVehicleStateStore()
        _ = store.applyMockTransition(DemoMockTransition(key: "window.position[主驾]", desiredValue: "20"))
        let beforePassenger = store.cell(for: "window.position[副驾]")
        let beforeRL = store.cell(for: "window.position[左后]")
        let beforeRR = store.cell(for: "window.position[右后]")
        let pipeline = try makePipeline()
        let frame = windowCURFrame(stateRevision: store.currentRevision)

        let result = try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger())

        XCTAssertEqual(store.cell(for: "window.position[主驾]")?.actualValue, "70")
        XCTAssertEqual(store.cell(for: "window.position[副驾]")?.actualValue, beforePassenger?.actualValue)
        XCTAssertEqual(store.cell(for: "window.position[左后]")?.actualValue, beforeRL?.actualValue)
        XCTAssertEqual(store.cell(for: "window.position[右后]")?.actualValue, beforeRR?.actualValue)
        let readback = try XCTUnwrap(result.readbacks.first { $0.key == "window.position[主驾]" })
        XCTAssertEqual(readback.actualValue, "70")
        XCTAssertEqual(readback.revision, store.cell(for: "window.position[主驾]")?.revision)
    }

    @MainActor
    func testCUR_prestate70_plus50_outOfRange_mutationZero() throws {
        let store = DemoVehicleStateStore()
        _ = store.applyMockTransition(DemoMockTransition(key: "window.position[主驾]", desiredValue: "70"))
        let before = storeSnapshot(store)
        let pipeline = try makePipeline()
        let frame = windowCURFrame(stateRevision: store.currentRevision)

        XCTAssertThrowsError(try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger())) { error in
            XCTAssertEqual(error as? ToolExecutionError, .schemaInvalid(.outOfRange("window.position")))
        }
        assertStoreUnchanged(store, before: before)
    }

    @MainActor
    func testCUR_prestate60_plus50_outOfRange_mutationZero() throws {
        let store = DemoVehicleStateStore()
        _ = store.applyMockTransition(DemoMockTransition(key: "window.position[主驾]", desiredValue: "60"))
        let before = storeSnapshot(store)
        let pipeline = try makePipeline()

        XCTAssertThrowsError(
            try pipeline.execute(windowCURFrame(stateRevision: store.currentRevision), store: store, traceLogger: InMemoryTraceLogger())
        ) { error in
            XCTAssertEqual(error as? ToolExecutionError, .schemaInvalid(.outOfRange("window.position")))
        }
        assertStoreUnchanged(store, before: before)
    }

    @MainActor
    func testCUR_freshPathRecalculatesFromLiveCurrent_notPriorPlanned() throws {
        let store = DemoVehicleStateStore()
        _ = store.applyMockTransition(DemoMockTransition(key: "window.position[主驾]", desiredValue: "20"))
        let pipeline = try makePipeline()

        _ = try pipeline.execute(
            windowCURFrame(id: "cmd-cur-first", stateRevision: store.currentRevision),
            store: store,
            traceLogger: InMemoryTraceLogger()
        )
        XCTAssertEqual(store.cell(for: "window.position[主驾]")?.actualValue, "70")

        // Drift live current; a new CUR command must recompute 40+50=90, not replay 70.
        _ = store.applyMockTransition(DemoMockTransition(key: "window.position[主驾]", desiredValue: "40"))
        let second = try pipeline.execute(
            windowCURFrame(id: "cmd-cur-second", stateRevision: store.currentRevision),
            store: store,
            traceLogger: InMemoryTraceLogger()
        )
        XCTAssertEqual(store.cell(for: "window.position[主驾]")?.actualValue, "90")
        XCTAssertEqual(second.readbacks.first { $0.key == "window.position[主驾]" }?.actualValue, "90")
    }

    // MARK: - Route-level runner/mutation (R2-Q4)

    @MainActor
    func testRoute_CUR20to70_runner1_mutation1_readbackAligned() async throws {
        var cells = DemoVehicleStateStore.defaultCells()
        let idx = try XCTUnwrap(cells.firstIndex { $0.key == "window.position[主驾]" })
        cells[idx].actualValue = "20"
        let h = try RouteHarness(cells: cells)

        let result = try await h.route.route(text: "把主驾车窗再开50%")
        let execution = try XCTUnwrap(result.execution)

        XCTAssertNil(result.rejection)
        XCTAssertEqual(h.route.runnerCallCount, 1)
        XCTAssertEqual(execution.payload.mutationCount, 1)
        XCTAssertEqual(h.store.cell(for: "window.position[主驾]")?.actualValue, "70")
        XCTAssertEqual(h.store.cell(for: "window.position[副驾]")?.actualValue, "0")
        XCTAssertTrue(execution.payload.readbacks.contains {
            $0.key == "window.position[主驾]"
                && $0.actualValue == "70"
                && $0.revision == h.store.cell(for: "window.position[主驾]")?.revision
        })
    }

    @MainActor
    func testRoute_CUR70to120_rangeRefusal_runnerAttempt1_mutation0() async throws {
        var cells = DemoVehicleStateStore.defaultCells()
        let idx = try XCTUnwrap(cells.firstIndex { $0.key == "window.position[主驾]" })
        cells[idx].actualValue = "70"
        let h = try RouteHarness(cells: cells)
        let beforeRevision = h.store.currentRevision
        let beforeCells = h.store.cells

        do {
            _ = try await h.route.route(text: "把主驾车窗再开50%")
            XCTFail("expected out-of-range ToolExecutionError")
        } catch let error as ToolExecutionError {
            guard case .schemaInvalid(.outOfRange(let field)) = error else {
                return XCTFail("expected .schemaInvalid(.outOfRange), got \(error)")
            }
            XCTAssertEqual(field, "window.position")
        }

        XCTAssertEqual(h.route.runnerCallCount, 1, "range refusal must still count a runner attempt")
        XCTAssertEqual(h.store.currentRevision, beforeRevision)
        XCTAssertEqual(h.store.cells, beforeCells)
        XCTAssertEqual(h.store.cell(for: "window.position[主驾]")?.actualValue, "70")
    }

    @MainActor
    func testGenericOpenWindow_notInCatalog_runner0() async throws {
        let h = try RouteHarness()
        let before = h.store.cells

        let result = try await h.route.route(text: "打开车窗")

        XCTAssertNil(result.execution)
        XCTAssertEqual(result.rejection, .notInCatalog)
        XCTAssertEqual(h.route.runnerCallCount, 0)
        XCTAssertEqual(h.store.cells, before)
        XCTAssertEqual(DemoSliceAdmissionCatalog().classify(for: "打开车窗"), .contractRefusal(.notInCatalog))
    }

    // MARK: - B07 safety on CUR frames (C3)

    @MainActor
    func testCUR_stationaryParkAllows() throws {
        let store = DemoVehicleStateStore()
        _ = store.applyMockTransition(DemoMockTransition(key: "window.position[主驾]", desiredValue: "20"))
        _ = store.applyMockTransition(DemoMockTransition(key: "vehicle.speed", desiredValue: "0"))
        _ = store.applyMockTransition(DemoMockTransition(key: "vehicle.gear", desiredValue: "P"))
        let pipeline = try makePipeline()

        let result = try pipeline.execute(
            windowCURFrame(stateRevision: store.currentRevision),
            store: store,
            traceLogger: InMemoryTraceLogger()
        )
        XCTAssertEqual(store.cell(for: "window.position[主驾]")?.actualValue, "70")
        XCTAssertFalse(result.readbacks.isEmpty)
    }

    @MainActor
    func testCUR_stationaryNeutralAllows() throws {
        let store = DemoVehicleStateStore()
        _ = store.applyMockTransition(DemoMockTransition(key: "window.position[主驾]", desiredValue: "20"))
        _ = store.applyMockTransition(DemoMockTransition(key: "vehicle.speed", desiredValue: "0"))
        _ = store.applyMockTransition(DemoMockTransition(key: "vehicle.gear", desiredValue: "N"))
        let pipeline = try makePipeline()

        _ = try pipeline.execute(
            windowCURFrame(stateRevision: store.currentRevision),
            store: store,
            traceLogger: InMemoryTraceLogger()
        )
        XCTAssertEqual(store.cell(for: "window.position[主驾]")?.actualValue, "70")
    }

    @MainActor
    func testCUR_movingSpeedRefuses_mutationZero() throws {
        let store = DemoVehicleStateStore()
        _ = store.applyMockTransition(DemoMockTransition(key: "window.position[主驾]", desiredValue: "20"))
        _ = store.applyMockTransition(DemoMockTransition(key: "vehicle.speed", desiredValue: "30"))
        _ = store.applyMockTransition(DemoMockTransition(key: "vehicle.gear", desiredValue: "D"))
        let before = storeSnapshot(store)
        let pipeline = try makePipeline()

        XCTAssertThrowsError(
            try pipeline.execute(windowCURFrame(stateRevision: store.currentRevision), store: store, traceLogger: InMemoryTraceLogger())
        ) { error in
            XCTAssertEqual(error as? ToolExecutionError, .guardDenied(movingRefuse))
        }
        assertStoreUnchanged(store, before: before)
    }

    @MainActor
    func testCUR_stationaryDriveRefuses_mutationZero() throws {
        let store = DemoVehicleStateStore()
        _ = store.applyMockTransition(DemoMockTransition(key: "window.position[主驾]", desiredValue: "20"))
        _ = store.applyMockTransition(DemoMockTransition(key: "vehicle.speed", desiredValue: "0"))
        _ = store.applyMockTransition(DemoMockTransition(key: "vehicle.gear", desiredValue: "D"))
        let before = storeSnapshot(store)
        let pipeline = try makePipeline()

        XCTAssertThrowsError(
            try pipeline.execute(windowCURFrame(stateRevision: store.currentRevision), store: store, traceLogger: InMemoryTraceLogger())
        ) { error in
            XCTAssertEqual(error as? ToolExecutionError, .guardDenied(gearRefuse))
        }
        assertStoreUnchanged(store, before: before)
    }

    // MARK: - Helpers

    @MainActor
    private struct RouteHarness {
        let store: DemoVehicleStateStore
        let route: DemoSliceRoute
        init(cells: [DemoVehicleStateCell] = DemoVehicleStateStore.defaultCells()) throws {
            let store = DemoVehicleStateStore(cells: cells)
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

    private func windowCURFrame(id: String = UUID().uuidString, stateRevision: Int) -> ToolCallFrame {
        ToolCallFrame(
            id: id,
            agentID: "vehicle-control",
            capabilityID: "vehicle.window.position",
            toolName: "open_window_by_number",
            device: "window",
            actionPrimitive: "by_percent",
            slots: ["position": "主驾"],
            value: ContractValue(ref: "CUR", direct: "+", offset: "50", type: "PERCENT"),
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

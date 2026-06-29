import XCTest
@testable import MAformacCore

final class C3ExecutionPipelineTests: XCTestCase {
    @MainActor
    func testPipelineTurnsOnACAndAppliesExpTemperatureFromC2Step() throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let pipeline = try makePipeline(intentConfirmed: true)
        let frame = ToolCallFrame(
            traceID: "trace-ac-exp",
            agentID: "vehicle-control",
            capabilityID: "cabin.ac_temperature",
            toolName: "vehicle_control",
            device: "ac_temperature",
            actionPrimitive: "increase_by_exp",
            slots: ["direction": "主驾"],
            value: ContractValue(ref: "CUR", direct: "+", offset: "LITTLE", type: "EXP"),
            stateRevision: 0,
            candidateSource: .upstreamToolCall
        )

        let result = try pipeline.execute(frame, store: store, traceLogger: trace)

        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, "26")
        XCTAssertEqual(result.readbacks.map(\.key), ["ac.power", "ac.temp_setpoint[主驾]"])
        XCTAssertEqual(Set(trace.entries.map(\.stage)), Set([.decode, .plan, .guard, .execute, .readback]))
    }

    @MainActor
    func testPipelineRejectsStaleStateBeforeExecution() throws {
        let store = DemoVehicleStateStore()
        _ = store.applyMockTransition(DemoMockTransition(key: "window.position[主驾]", desiredValue: "30"))
        let pipeline = try makePipeline(intentConfirmed: true)
        let frame = ToolCallFrame.fixture(
            device: "window",
            actionPrimitive: "by_percent",
            slots: ["position": "主驾"],
            value: ContractValue(ref: "ZERO", direct: "+", offset: "50", type: "PERCENT"),
            stateRevision: 0
        )

        XCTAssertThrowsError(try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger())) { error in
            XCTAssertEqual(error as? ToolExecutionError, .staleState(expected: 1, actual: 0))
        }
    }

    @MainActor
    func testRiskPolicyDeniesMovingDoorFromIndependentPolicy() throws {
        let store = DemoVehicleStateStore()
        _ = store.applyMockTransition(DemoMockTransition(key: "vehicle.speed", desiredValue: "12"))
        let pipeline = try makePipeline(intentConfirmed: true)
        let frame = ToolCallFrame.fixture(device: "car_door", actionPrimitive: "power_on", stateRevision: store.currentRevision)

        XCTAssertThrowsError(try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger())) { error in
            XCTAssertEqual(error as? ToolExecutionError, .guardDenied("行驶中为了安全暂时不能开门, 停稳后我再帮您"))
        }
    }

    @MainActor
    func testFanoutWritesOnlyC2SupportedWindowScopes() throws {
        let store = DemoVehicleStateStore()
        let pipeline = try makePipeline(intentConfirmed: true)
        let frame = ToolCallFrame.fixture(
            device: "window",
            actionPrimitive: "by_percent",
            slots: ["position": "全车"],
            value: ContractValue(ref: "ZERO", direct: "+", offset: "30", type: "PERCENT"),
            stateRevision: 0
        )

        _ = try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger())

        XCTAssertEqual(store.cell(for: "window.position[主驾]")?.actualValue, "30")
        XCTAssertEqual(store.cell(for: "window.position[副驾]")?.actualValue, "30")
        XCTAssertEqual(store.cell(for: "window.position[左后]")?.actualValue, "30")
        XCTAssertEqual(store.cell(for: "window.position[右后]")?.actualValue, "30")
    }

    @MainActor
    func testRepeatedAlreadyStateCommandDoesNotDoubleWriteRevision() throws {
        let store = DemoVehicleStateStore()
        let pipeline = try makePipeline(intentConfirmed: true)
        let first = ToolCallFrame.fixture(
            device: "window",
            actionPrimitive: "power_on",
            slots: ["position": "主驾"],
            stateRevision: 0
        )

        _ = try pipeline.execute(first, store: store, traceLogger: InMemoryTraceLogger())
        let revisionAfterFirstWrite = try XCTUnwrap(store.cell(for: "window.position[主驾]")).revision

        let repeated = ToolCallFrame.fixture(
            device: "window",
            actionPrimitive: "power_on",
            slots: ["position": "主驾"],
            stateRevision: store.currentRevision
        )
        let result = try pipeline.execute(repeated, store: store, traceLogger: InMemoryTraceLogger())

        XCTAssertEqual(store.cell(for: "window.position[主驾]")?.actualValue, "100")
        XCTAssertEqual(store.cell(for: "window.position[主驾]")?.revision, revisionAfterFirstWrite)
        XCTAssertEqual(result.readbacks.first?.revision, revisionAfterFirstWrite)
    }

    @MainActor
    func testC3RetryReplayUsesAdapterLedgerWithoutSecondWrite() throws {
        let store = DemoVehicleStateStore()
        let pipeline = try makePipeline(intentConfirmed: true)
        let first = ToolCallFrame.fixture(
            id: "cmd-window-driver",
            device: "window",
            actionPrimitive: "power_on",
            slots: ["position": "主驾"],
            stateRevision: 0
        )

        _ = try pipeline.execute(first, store: store, traceLogger: InMemoryTraceLogger())
        let cellAfterFirst = try XCTUnwrap(store.cell(for: "window.position[主驾]"))

        let retry = ToolCallFrame.fixture(
            id: "cmd-window-driver",
            device: "window",
            actionPrimitive: "power_on",
            slots: ["position": "主驾"],
            stateRevision: store.currentRevision
        )
        let result = try pipeline.execute(retry, store: store, traceLogger: InMemoryTraceLogger())

        let cellAfterRetry = try XCTUnwrap(store.cell(for: "window.position[主驾]"))
        XCTAssertEqual(cellAfterRetry.revision, cellAfterFirst.revision)
        XCTAssertEqual(cellAfterRetry.timestamp, cellAfterFirst.timestamp)
        XCTAssertEqual(result.readbacks.first?.revision, cellAfterFirst.revision)
    }

    @MainActor
    func testC3ExactStaleRetryReplaysSettledAdapterResultBeforeStaleGuard() throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let pipeline = try makePipeline(intentConfirmed: true)
        let first = ToolCallFrame.fixture(
            id: "cmd-window-stale-replay",
            device: "window",
            actionPrimitive: "power_on",
            slots: ["position": "主驾"],
            stateRevision: 0
        )

        _ = try pipeline.execute(first, store: store, traceLogger: trace)
        let cellAfterFirst = try XCTUnwrap(store.cell(for: "window.position[主驾]"))

        let staleRetry = ToolCallFrame.fixture(
            id: "cmd-window-stale-replay",
            device: "window",
            actionPrimitive: "power_on",
            slots: ["position": "主驾"],
            stateRevision: 0
        )
        let result = try pipeline.execute(staleRetry, store: store, traceLogger: trace)

        let cellAfterReplay = try XCTUnwrap(store.cell(for: "window.position[主驾]"))
        XCTAssertEqual(cellAfterReplay.revision, cellAfterFirst.revision)
        XCTAssertEqual(cellAfterReplay.timestamp, cellAfterFirst.timestamp)
        XCTAssertEqual(result.readbacks.first?.revision, cellAfterFirst.revision)
        XCTAssertTrue(trace.entries.contains { $0.stage == .guard && $0.message == "stale_retry_replay" })
    }

    @MainActor
    func testC3ExactStaleRetryReplaysSettledFanoutPlanWhenCurrentPlanWouldOmitPrerequisite() throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let pipeline = try makePipeline(intentConfirmed: true)
        let first = ToolCallFrame(
            id: "cmd-ac-stale-replay",
            traceID: "trace-ac-stale-replay",
            agentID: "vehicle-control",
            capabilityID: "cabin.ac_temperature",
            toolName: "vehicle_control",
            device: "ac_temperature",
            actionPrimitive: "increase_by_exp",
            slots: ["direction": "主驾"],
            value: ContractValue(ref: "CUR", direct: "+", offset: "LITTLE", type: "EXP"),
            stateRevision: 0,
            candidateSource: .upstreamToolCall
        )

        let firstResult = try pipeline.execute(first, store: store, traceLogger: trace)
        let powerAfterFirst = try XCTUnwrap(store.cell(for: "ac.power"))
        let tempAfterFirst = try XCTUnwrap(store.cell(for: "ac.temp_setpoint[主驾]"))

        let staleRetry = ToolCallFrame(
            id: "cmd-ac-stale-replay",
            traceID: "trace-ac-stale-replay",
            agentID: "vehicle-control",
            capabilityID: "cabin.ac_temperature",
            toolName: "vehicle_control",
            device: "ac_temperature",
            actionPrimitive: "increase_by_exp",
            slots: ["direction": "主驾"],
            value: ContractValue(ref: "CUR", direct: "+", offset: "LITTLE", type: "EXP"),
            stateRevision: 0,
            candidateSource: .upstreamToolCall
        )
        let replay = try pipeline.execute(staleRetry, store: store, traceLogger: trace)

        XCTAssertEqual(firstResult.readbacks.map(\.key), ["ac.power", "ac.temp_setpoint[主驾]"])
        XCTAssertEqual(replay.readbacks.map(\.key), ["ac.power", "ac.temp_setpoint[主驾]"])
        XCTAssertEqual(store.cell(for: "ac.power")?.revision, powerAfterFirst.revision)
        XCTAssertEqual(store.cell(for: "ac.power")?.timestamp, powerAfterFirst.timestamp)
        XCTAssertEqual(store.cell(for: "ac.temp_setpoint[主驾]")?.revision, tempAfterFirst.revision)
        XCTAssertEqual(store.cell(for: "ac.temp_setpoint[主驾]")?.timestamp, tempAfterFirst.timestamp)
        XCTAssertTrue(trace.entries.contains { $0.stage == .guard && $0.message == "stale_retry_replay" })
    }

    @MainActor
    func testC3SameCommandIdentityWithDifferentRequestFailsClosed() throws {
        let store = DemoVehicleStateStore()
        let pipeline = try makePipeline(intentConfirmed: true)
        let first = ToolCallFrame.fixture(
            id: "cmd-window-conflict",
            device: "window",
            actionPrimitive: "by_percent",
            slots: ["position": "主驾"],
            value: ContractValue(ref: "ZERO", direct: "+", offset: "30", type: "PERCENT"),
            stateRevision: 0
        )

        _ = try pipeline.execute(first, store: store, traceLogger: InMemoryTraceLogger())

        let conflicting = ToolCallFrame.fixture(
            id: "cmd-window-conflict",
            device: "window",
            actionPrimitive: "by_percent",
            slots: ["position": "主驾"],
            value: ContractValue(ref: "ZERO", direct: "+", offset: "60", type: "PERCENT"),
            stateRevision: store.currentRevision
        )

        XCTAssertThrowsError(try pipeline.execute(conflicting, store: store, traceLogger: InMemoryTraceLogger())) { error in
            XCTAssertEqual(error as? DemoRuntimeAdapterError, .idempotencyConflict(commandID: "cmd-window-conflict#window.position[主驾]"))
        }
        XCTAssertEqual(store.cell(for: "window.position[主驾]")?.actualValue, "30")
    }

    @MainActor
    func testC3StaleChangedRequestFallsBackToStaleGuardBeforeMutation() throws {
        let store = DemoVehicleStateStore()
        let pipeline = try makePipeline(intentConfirmed: true)
        let first = ToolCallFrame.fixture(
            id: "cmd-window-stale-conflict",
            device: "window",
            actionPrimitive: "by_percent",
            slots: ["position": "主驾"],
            value: ContractValue(ref: "ZERO", direct: "+", offset: "30", type: "PERCENT"),
            stateRevision: 0
        )

        _ = try pipeline.execute(first, store: store, traceLogger: InMemoryTraceLogger())

        let staleChanged = ToolCallFrame.fixture(
            id: "cmd-window-stale-conflict",
            device: "window",
            actionPrimitive: "by_percent",
            slots: ["position": "主驾"],
            value: ContractValue(ref: "ZERO", direct: "+", offset: "60", type: "PERCENT"),
            stateRevision: 0
        )

        XCTAssertThrowsError(try pipeline.execute(staleChanged, store: store, traceLogger: InMemoryTraceLogger())) { error in
            XCTAssertEqual(error as? ToolExecutionError, .staleState(expected: 1, actual: 0))
        }
        XCTAssertEqual(store.cell(for: "window.position[主驾]")?.actualValue, "30")
    }

    @MainActor
    func testC3PerTransitionIdentityKeepsFanoutFromConflicting() throws {
        let store = DemoVehicleStateStore()
        let pipeline = try makePipeline(intentConfirmed: true)
        let frame = ToolCallFrame.fixture(
            id: "cmd-window-fanout",
            device: "window",
            actionPrimitive: "by_percent",
            slots: ["position": "全车"],
            value: ContractValue(ref: "ZERO", direct: "+", offset: "45", type: "PERCENT"),
            stateRevision: 0
        )

        let result = try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger())

        XCTAssertEqual(Set(result.readbacks.map(\.key)), Set([
            "window.position[主驾]",
            "window.position[副驾]",
            "window.position[左后]",
            "window.position[右后]"
        ]))
        XCTAssertEqual(store.cell(for: "window.position[主驾]")?.actualValue, "45")
        XCTAssertEqual(store.cell(for: "window.position[副驾]")?.actualValue, "45")
        XCTAssertEqual(store.cell(for: "window.position[左后]")?.actualValue, "45")
        XCTAssertEqual(store.cell(for: "window.position[右后]")?.actualValue, "45")
    }

    @MainActor
    func testC3AdapterFailureDoesNotCreateSuccessLedger() throws {
        let cells = DemoVehicleStateStore.defaultCells().filter { $0.key != "window.position[主驾]" }
        let brokenStore = DemoVehicleStateStore(cells: cells)
        let pipeline = try makePipeline(intentConfirmed: true)
        let frame = ToolCallFrame.fixture(
            id: "cmd-window-missing-cell",
            device: "window",
            actionPrimitive: "power_on",
            slots: ["position": "主驾"],
            stateRevision: 0
        )

        XCTAssertThrowsError(try pipeline.execute(frame, store: brokenStore, traceLogger: InMemoryTraceLogger())) { error in
            XCTAssertEqual(error as? DemoRuntimeAdapterError, .missingStateCell("window.position[主驾]"))
        }

        let repairedStore = DemoVehicleStateStore()
        let result = try pipeline.execute(frame, store: repairedStore, traceLogger: InMemoryTraceLogger())

        XCTAssertEqual(result.readbacks.first?.key, "window.position[主驾]")
        XCTAssertEqual(result.readbacks.first?.actualValue, "100")
        XCTAssertEqual(repairedStore.cell(for: "window.position[主驾]")?.actualValue, "100")
    }

    func testOmittedWindowScopeResolvesToC2DefaultScope() throws {
        let pipeline = try makePipeline(intentConfirmed: true)
        let cell = try XCTUnwrap(pipeline.stateCells.cell(id: "window.position"))
        let frame = ToolCallFrame.fixture(device: "window", actionPrimitive: "power_on", stateRevision: 0)

        let resolution = try C2ScopeResolver.resolve(frame: frame, cell: cell)

        XCTAssertEqual(resolution.origin, .defaulted)
        XCTAssertEqual(resolution.keys, ["window.position[主驾]"])
        XCTAssertEqual(resolution.resolvedScopes, ["主驾"])
    }

    func testExplicitAllWindowScopeFansOut() throws {
        let pipeline = try makePipeline(intentConfirmed: true)
        let cell = try XCTUnwrap(pipeline.stateCells.cell(id: "window.position"))
        let frame = ToolCallFrame.fixture(device: "window", actionPrimitive: "power_on", slots: ["position": "全车"], stateRevision: 0)

        let resolution = try C2ScopeResolver.resolve(frame: frame, cell: cell)

        XCTAssertEqual(resolution.origin, .fanout)
        XCTAssertEqual(Set(resolution.keys), Set([
            "window.position[主驾]",
            "window.position[副驾]",
            "window.position[左后]",
            "window.position[右后]"
        ]))
    }

    func testExplicitDriverScopeRemainsExplicit() throws {
        let pipeline = try makePipeline(intentConfirmed: true)
        let cell = try XCTUnwrap(pipeline.stateCells.cell(id: "window.position"))
        let frame = ToolCallFrame.fixture(device: "window", actionPrimitive: "power_on", slots: ["position": "主驾"], stateRevision: 0)

        let resolution = try C2ScopeResolver.resolve(frame: frame, cell: cell)

        XCTAssertEqual(resolution.origin, .explicit)
        XCTAssertEqual(resolution.keys, ["window.position[主驾]"])
    }

    @MainActor
    func testPipelineOmittedWindowScopeUsesC2DefaultAndCarriesOrigin() throws {
        let store = DemoVehicleStateStore()
        let pipeline = try makePipeline(intentConfirmed: true)
        let frame = ToolCallFrame.fixture(device: "window", actionPrimitive: "power_on", stateRevision: 0)

        let result = try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger())

        XCTAssertEqual(store.cell(for: "window.position[主驾]")?.actualValue, "100")
        XCTAssertEqual(store.cell(for: "window.position[副驾]")?.actualValue, "0")
        XCTAssertEqual(store.cell(for: "window.position[左后]")?.actualValue, "0")
        XCTAssertEqual(store.cell(for: "window.position[右后]")?.actualValue, "0")
        let readback = try XCTUnwrap(result.readbacks.first { $0.key == "window.position[主驾]" })
        XCTAssertEqual(readback.scopeOrigin, .defaulted)
    }

    @MainActor
    func testScreenAndAmbientValueNormalizationUseC2RangesAndAllowedValues() throws {
        let store = DemoVehicleStateStore()
        let pipeline = try makePipeline(intentConfirmed: true)
        let screen = ToolCallFrame.fixture(
            device: "screen_brightness",
            actionPrimitive: "increase_by_exp",
            slots: ["screen_type": "中控屏"],
            value: ContractValue(ref: "CUR", direct: "+", offset: "LITTLE", type: "EXP"),
            stateRevision: 0
        )

        _ = try pipeline.execute(screen, store: store, traceLogger: InMemoryTraceLogger())
        XCTAssertEqual(store.cell(for: "screen.brightness[中控屏]")?.actualValue, "80")

        let ambient = ToolCallFrame.fixture(
            device: "atmosphere_lamp_brightness",
            actionPrimitive: "by_percent",
            slots: ["name": "面发光氛围灯"],
            value: ContractValue(ref: "ZERO", direct: "+", offset: "40", type: "PERCENT"),
            stateRevision: store.currentRevision
        )
        _ = try pipeline.execute(ambient, store: store, traceLogger: InMemoryTraceLogger())
        XCTAssertEqual(store.cell(for: "ambient.brightness[面发光氛围灯]")?.actualValue, "40")

        let badColor = ToolCallFrame.fixture(
            device: "atmosphere_lamp_color",
            actionPrimitive: "set_mode",
            value: ContractValue(ref: "ZERO", direct: "+", offset: "粉", type: "SPOT"),
            stateRevision: store.currentRevision
        )
        XCTAssertThrowsError(try pipeline.execute(badColor, store: store, traceLogger: InMemoryTraceLogger())) { error in
            XCTAssertEqual(error as? ToolExecutionError, .schemaInvalid(.unknownEnum("ambient.color")))
        }
    }

    @MainActor
    func testReadbackVerifierFailsWhenActualStateDiffersFromExpected() {
        let store = DemoVehicleStateStore()
        _ = store.applyMockTransition(DemoMockTransition(key: "screen.brightness[中控屏]", desiredValue: "20"))

        XCTAssertThrowsError(try C2ReadbackVerifier.verify(store: store, key: "screen.brightness[中控屏]", expectedValue: "50")) { error in
            XCTAssertEqual(error as? ToolExecutionError, .readbackMismatch(expected: "50", actual: "20"))
        }
    }

    @MainActor
    func testImplicitCandidateRequiresIntentConfirmationHook() throws {
        let pipeline = try makePipeline(intentConfirmed: false)
        let frame = ToolCallFrame.fixture(device: "window", actionPrimitive: "power_on", stateRevision: 0)

        XCTAssertThrowsError(try pipeline.execute(frame, store: DemoVehicleStateStore(), traceLogger: InMemoryTraceLogger())) { error in
            XCTAssertEqual(error as? ToolExecutionError, .guardDenied("intent_not_confirmed"))
        }
    }

    @MainActor
    func testPendingFailedUnknownReadbackTextDoesNotClaimCompletion() {
        for state in ["pending", "failed", "unknown"] {
            let text = DemoVehicleStateStore.spokenText(for: DemoVehicleStateCell(key: "mock.cell", actualValue: state))
            XCTAssertFalse(text.contains("已完成"))
            XCTAssertFalse(text.contains("完成"))
        }
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

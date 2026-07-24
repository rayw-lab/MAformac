import XCTest
@testable import MAformacCore

final class DemoSliceClassificationTests: XCTestCase {
    private let catalog = DemoSliceAdmissionCatalog()

    func testPoliteCommand_nengTiaoDao_isCommandNotCapability() {
        let classification = catalog.classify(for: "能调到26度吗")
        guard case let .command(admission) = classification else {
            return XCTFail("expected command, got \(classification)")
        }
        XCTAssertEqual(admission.entry.matrixID, 4)
        XCTAssertEqual(admission.frame.value.direct, "26")
        XCTAssertNil(catalog.rejection(for: "能调到26度吗"))
    }

    func testPleaseSetTemperature_isCommand() {
        let classification = catalog.classify(for: "空调调到26度")
        guard case let .command(admission) = classification else {
            return XCTFail("expected command, got \(classification)")
        }
        XCTAssertEqual(admission.frame.value.direct, "26")
    }

    func testCapabilityQueries_areDisjointFromPoliteCommand() {
        let utterances = [
            "空调能调到26度吗",
            "你能调到26度吗",
            "能不能调到26度",
            "可以调到26度吗",
        ]
        for utterance in utterances {
            let classification = catalog.classify(for: utterance)
            guard case let .capabilityQuery(spec) = classification else {
                return XCTFail("expected capabilityQuery for \(utterance), got \(classification)")
            }
            XCTAssertEqual(spec.stateBase, "ac.temp_setpoint")
            XCTAssertEqual(spec.probedTemperature, 26)
            XCTAssertNil(catalog.admission(for: utterance))
        }
    }

    func testCapabilityRangeQuery_airSupport() {
        let classification = catalog.classify(for: "空调支持多少度")
        guard case let .capabilityQuery(spec) = classification else {
            return XCTFail("expected capabilityQuery, got \(classification)")
        }
        XCTAssertNil(spec.probedTemperature)
    }

    func testStateQuery_currentTemperature() {
        let classification = catalog.classify(for: "现在空调多少度")
        guard case let .stateQuery(spec) = classification else {
            return XCTFail("expected stateQuery, got \(classification)")
        }
        XCTAssertEqual(spec.stateBase, "ac.temp_setpoint")
        XCTAssertEqual(spec.scopeHint, "主驾")
    }

    func testCorrectionWrapper_fullCommand_isNewTurnCommand() {
        let classification = catalog.classify(for: "不对，空调调到24度")
        guard case let .command(admission) = classification else {
            return XCTFail("expected command, got \(classification)")
        }
        XCTAssertEqual(admission.frame.value.direct, "24")
    }

    func testCorrectionIncomplete_isClarification() {
        for utterance in ["不对，调到24度", "改成24度"] {
            let classification = catalog.classify(for: utterance)
            guard case .clarification = classification else {
                return XCTFail("expected clarification for \(utterance), got \(classification)")
            }
            XCTAssertEqual(catalog.rejection(for: utterance), .clarifyMissingSlot)
        }
    }

    func testConjunctionAndMultiIntent_zeroFrameRefusal() {
        let utterances = [
            "打开空调并调到26度",
            "打开空调，再打开氛围灯",
            "打开空调到26度并打开氛围灯",
            "把主驾车窗再开50%然后打开副驾座椅加热",
            "空调调到26度，不对，24度",
            "打开空调\n再打开氛围灯",
            "打开空调;打开氛围灯",
            "{\"tool\":\"open_ac\"}",
        ]
        for utterance in utterances {
            let classification = catalog.classify(for: utterance)
            guard case let .contractRefusal(reason) = classification else {
                return XCTFail("expected contractRefusal for \(utterance), got \(classification)")
            }
            XCTAssertEqual(reason, .conjunctionOrMultiIntent, utterance)
            XCTAssertNil(catalog.admission(for: utterance))
        }
    }

    func testNoGlobalQuestionSuffixStrip_onNonQuestionTemplates() {
        // `空调调到` does not declare optional 吗 — must fail-closed.
        let classification = catalog.classify(for: "空调调到26度吗")
        guard case let .contractRefusal(reason) = classification else {
            return XCTFail("expected refusal, got \(classification)")
        }
        XCTAssertEqual(reason, .notInCatalog)
    }

    func testWindowLiteral_stillExactAndNotConjunction() {
        let classification = catalog.classify(for: "把主驾车窗再开50%")
        guard case let .command(admission) = classification else {
            return XCTFail("expected command, got \(classification)")
        }
        XCTAssertEqual(admission.entry.matrixID, 31)
        XCTAssertEqual(admission.frame.slots["position"], "主驾")
    }

    func testClassifyIsSinglePass_admissionAndRejectionDoNotDisagree() {
        let samples = [
            "打开空调",
            "能调到26度吗",
            "空调能调到26度吗",
            "现在空调多少度",
            "打开车窗",
            "空调",
            "   ",
            "打开空调并调到26度",
        ]
        for sample in samples {
            let classification = catalog.classify(for: sample)
            let admission = catalog.admission(for: sample)
            let rejection = catalog.rejection(for: sample)
            switch classification {
            case .command:
                XCTAssertNotNil(admission, sample)
                XCTAssertNil(rejection, sample)
            case .clarification:
                XCTAssertNil(admission, sample)
                XCTAssertEqual(rejection, .clarifyMissingSlot, sample)
            case let .contractRefusal(reason):
                XCTAssertNil(admission, sample)
                XCTAssertEqual(rejection, reason, sample)
            case let .cancel(target):
                XCTAssertNil(admission, sample)
                XCTAssertEqual(rejection, .cancel(target: target), sample)
            case .stateQuery, .capabilityQuery:
                XCTAssertNil(admission, sample)
                XCTAssertNil(rejection, sample)
            }
        }
    }

    func testTargetProjection_returnsPerKeyDesired() throws {
        let admission = try XCTUnwrap(catalog.admission(for: "空调调到26度"))
        let bundle = DemoRuntimeContractBundle.singleCommandDemoDefault
        let pipeline = try bundle.makePipeline()
        let projection = try DemoSliceAdmissionCatalog.targetProjection(
            for: admission,
            stateCells: pipeline.stateCells
        )
        XCTAssertEqual(projection.map(\.key), ["ac.temp_setpoint[主驾]"])
        XCTAssertEqual(projection.map(\.desired), ["26"])
    }

    @MainActor
    func testRoute_politeCommand_freshRunsAndAlreadyStateNoops() async throws {
        let harness = try RouteHarness()
        let fresh = try await harness.route.route(text: "能调到26度吗")
        guard case .command = fresh.classification else {
            return XCTFail("expected command classification")
        }
        let exec = try XCTUnwrap(fresh.execution)
        XCTAssertEqual(harness.route.runnerCallCount, 1)
        XCTAssertGreaterThan(exec.payload.mutationCount, 0)
        XCTAssertEqual(harness.store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, "26")

        let again = try await harness.route.route(text: "能调到26度吗")
        let noop = try XCTUnwrap(again.execution)
        XCTAssertEqual(noop.payload.outcome.result, .alreadyStateNoop)
        XCTAssertEqual(noop.payload.mutationCount, 0)
        XCTAssertEqual(harness.route.runnerCallCount, 1)
    }

    @MainActor
    func testRoute_capabilityQuery_zeroRunnerZeroMutation_contractEvidence() async throws {
        let harness = try RouteHarness()
        let before = harness.store.cells
        let beforeRevision = harness.store.currentRevision
        let result = try await harness.route.route(text: "空调能调到26度吗")
        guard case .capabilityQuery = result.classification else {
            return XCTFail("expected capabilityQuery")
        }
        let readOnly = try XCTUnwrap(result.readOnly)
        XCTAssertNil(result.execution)
        XCTAssertNil(result.rejection)
        XCTAssertEqual(harness.route.runnerCallCount, 0)
        XCTAssertEqual(readOnly.payload.mutationCount, 0)
        XCTAssertEqual(readOnly.payload.readbacks.count, 1)
        XCTAssertEqual(readOnly.payload.readbacks.first?.spokenText, "空调温度支持18到32度")
        XCTAssertEqual(readOnly.payload.outcome.result, .capabilityQuery)
        XCTAssertEqual(harness.store.currentRevision, beforeRevision)
        XCTAssertEqual(harness.store.cells, before)
    }

    @MainActor
    func testKnife1_capabilityQuery_resultIsCapabilityQuery_notNoAction() async throws {
        let harness = try RouteHarness()
        let result = try await harness.route.route(text: "空调能调到26度吗")
        let readOnly = try XCTUnwrap(result.readOnly)
        XCTAssertEqual(readOnly.payload.outcome.result, .capabilityQuery)
        XCTAssertNotEqual(readOnly.payload.outcome.result, .noAction)
        XCTAssertEqual(harness.route.runnerCallCount, 0)
        XCTAssertEqual(readOnly.payload.mutationCount, 0)
    }

    @MainActor
    func testRoute_stateQuery_liveReadback_zeroRunner() async throws {
        let harness = try RouteHarness()
        _ = harness.store.applyMockTransition(
            DemoMockTransition(key: "ac.temp_setpoint[主驾]", desiredValue: "22", source: .user)
        )
        let revision = try XCTUnwrap(harness.store.cell(for: "ac.temp_setpoint[主驾]")?.revision)
        let result = try await harness.route.route(text: "现在空调多少度")
        guard case .stateQuery = result.classification else {
            return XCTFail("expected stateQuery")
        }
        let readOnly = try XCTUnwrap(result.readOnly)
        XCTAssertEqual(harness.route.runnerCallCount, 0)
        XCTAssertEqual(readOnly.payload.mutationCount, 0)
        XCTAssertEqual(readOnly.payload.readbacks.map(\.key), ["ac.temp_setpoint[主驾]"])
        XCTAssertEqual(readOnly.payload.readbacks.map(\.actualValue), ["22"])
        XCTAssertEqual(readOnly.payload.readbacks.map(\.revision), [revision])
        XCTAssertEqual(readOnly.payload.outcome.result, .stateQuery)
    }

    @MainActor
    func testKnife1_stateQuery_resultIsStateQuery_notNoAction() async throws {
        let harness = try RouteHarness()
        let result = try await harness.route.route(text: "现在空调多少度")
        let readOnly = try XCTUnwrap(result.readOnly)
        XCTAssertEqual(readOnly.payload.outcome.result, .stateQuery)
        XCTAssertNotEqual(readOnly.payload.outcome.result, .noAction)
        XCTAssertEqual(harness.route.runnerCallCount, 0)
        XCTAssertEqual(readOnly.payload.mutationCount, 0)
    }

    @MainActor
    func testRoute_conjunction_zeroFrameRefusal() async throws {
        let harness = try RouteHarness()
        let before = harness.store.cells
        let result = try await harness.route.route(text: "打开空调并调到26度")
        XCTAssertEqual(result.rejection, .conjunctionOrMultiIntent)
        XCTAssertNil(result.execution)
        XCTAssertNil(result.readOnly)
        XCTAssertEqual(harness.route.runnerCallCount, 0)
        XCTAssertEqual(harness.store.cells, before)
    }

    @MainActor
    func testIRBridge_discardsNonValueSlot_failClosed() {
        let ir = ToolContractIR(
            sourceToolName: "open_window_by_number",
            device: "window",
            actionPrimitive: "by_percent",
            slots: ["position": "主驾"],
            value: ContractValue(ref: "CUR", direct: "+", offset: "50", type: "PERCENT")
        )
        XCTAssertThrowsError(
            try ToolContractIRFrameBridge.frame(
                from: ir,
                traceID: "t",
                rawCall: C6ToolCall(name: "open_window_by_number", arguments: [:]),
                projectedSlotKeys: []
            )
        )
    }

    @MainActor
    func testIRBridge_explicitProjectionKeepsSlot() throws {
        let ir = ToolContractIR(
            sourceToolName: "open_window_by_number",
            device: "window",
            actionPrimitive: "by_percent",
            slots: ["position": "主驾"],
            value: ContractValue(ref: "CUR", direct: "+", offset: "50", type: "PERCENT")
        )
        let frame = try ToolContractIRFrameBridge.frame(
            from: ir,
            traceID: "t",
            rawCall: C6ToolCall(name: "open_window_by_number", arguments: [:]),
            projectedSlotKeys: ["position"]
        )
        XCTAssertEqual(frame.slots["position"], "主驾")
    }

    func testRow167_admitsDriverHeatTuneWithSlotsAndUnit() {
        let classification = catalog.classify(for: "主驾制热调24度")
        guard case let .command(admission) = classification else {
            return XCTFail("expected command, got \(classification)")
        }
        XCTAssertEqual(admission.entry.matrixID, 167)
        XCTAssertEqual(admission.entry.contractRowID, "c1_airControl_000167")
        XCTAssertEqual(admission.frame.slots["direction"], "主驾")
        XCTAssertEqual(admission.frame.slots["mode"], "制热")
        XCTAssertEqual(admission.frame.slots["adjustment_mode"], "摄氏度")
        XCTAssertEqual(admission.frame.value.direct, "24")
        XCTAssertEqual(admission.frame.value.sourceUnit, .celsius)
    }

    func testRow167_fahrenheitUnitCarriesSourceUnit() {
        let classification = catalog.classify(for: "主驾制热调68华氏度")
        guard case let .command(admission) = classification else {
            return XCTFail("expected command, got \(classification)")
        }
        XCTAssertEqual(admission.frame.value.direct, "68")
        XCTAssertEqual(admission.frame.value.sourceUnit, .fahrenheit)
        XCTAssertEqual(admission.frame.slots["adjustment_mode"], "华氏度")
    }

    func testRow167_celsiusOutOfRange_refuses() {
        let classification = catalog.classify(for: "主驾制热调17度")
        guard case let .contractRefusal(reason) = classification else {
            return XCTFail("expected refusal, got \(classification)")
        }
        XCTAssertEqual(reason, .valueOutOfRange(actual: 17, allowed: 18 ... 32))
    }

    func testRow167_targetProjection_perKeyPowerModeTemp() throws {
        let admission = try XCTUnwrap(catalog.admission(for: "主驾制热调24度"))
        let bundle = DemoRuntimeContractBundle.singleCommandDemoDefault
        let pipeline = try bundle.makePipeline()
        let projection = try DemoSliceAdmissionCatalog.targetProjection(
            for: admission,
            stateCells: pipeline.stateCells
        )
        XCTAssertEqual(
            projection.map(\.key),
            ["ac.power", "ac.mode", "ac.temp_setpoint[主驾]"]
        )
        XCTAssertEqual(projection.map(\.desired), ["on", "制热", "24"])
    }

    @MainActor
    func testRoute_row167_fullTargetsSatisfied_preRunNoop() async throws {
        let harness = try RouteHarness()
        _ = harness.store.applyMockTransition(
            DemoMockTransition(key: "ac.power", desiredValue: "on", source: .user)
        )
        _ = harness.store.applyMockTransition(
            DemoMockTransition(key: "ac.mode", desiredValue: "制热", source: .user)
        )
        _ = harness.store.applyMockTransition(
            DemoMockTransition(key: "ac.temp_setpoint[主驾]", desiredValue: "24", source: .user)
        )
        let before = harness.store.cells
        let result = try await harness.route.route(text: "主驾制热调24度")
        let exec = try XCTUnwrap(result.execution)
        XCTAssertEqual(exec.payload.outcome.result, .alreadyStateNoop)
        XCTAssertEqual(exec.payload.mutationCount, 0)
        XCTAssertEqual(harness.route.runnerCallCount, 0)
        XCTAssertEqual(harness.store.cells, before)
    }

    @MainActor
    func testRoute_row167_onlyTempUnsatisfied_runnerOnce() async throws {
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
        XCTAssertNotNil(result.execution)
        XCTAssertEqual(harness.route.runnerCallCount, 1)
        // Differential compound atomic transitions remain G3; G2 only gates runner boundary.
    }

    func testScopeResolution_conflictingExplicitScopes_typedRefuse() throws {
        let pipeline = try DemoRuntimeContractBundle.singleCommandDemoDefault.makePipeline()
        let cell = try XCTUnwrap(pipeline.stateCells.cell(id: "ac.temp_setpoint"))
        let frame = ToolCallFrame(
            agentID: "vehicle-control",
            capabilityID: "vehicle.ac.temperature",
            toolName: "adjust_ac_temperature_to_number",
            device: "ac_temperature",
            actionPrimitive: "adjust_to_number",
            slots: ["direction": "主驾", "position": "副驾"],
            value: ContractValue(direct: "24", type: "SPOT"),
            candidateSource: .fastPath
        )
        XCTAssertThrowsError(try C2ScopeResolver.resolve(frame: frame, cell: cell)) { error in
            XCTAssertEqual(error as? ToolExecutionError, .semanticInvalid("scope_conflict"))
        }
        XCTAssertThrowsError(try C2ScopeResolver.requestedScope(from: frame)) { error in
            XCTAssertEqual(error as? ToolExecutionError, .semanticInvalid("scope_conflict"))
        }
    }

    func testScopeResolution_matchingExplicitScopes_keepsExplicit() throws {
        let pipeline = try DemoRuntimeContractBundle.singleCommandDemoDefault.makePipeline()
        let cell = try XCTUnwrap(pipeline.stateCells.cell(id: "ac.temp_setpoint"))
        let frame = ToolCallFrame(
            agentID: "vehicle-control",
            capabilityID: "vehicle.ac.temperature",
            toolName: "adjust_ac_temperature_to_number",
            device: "ac_temperature",
            actionPrimitive: "adjust_to_number",
            slots: ["direction": "主驾", "position": "主驾"],
            value: ContractValue(direct: "24", type: "SPOT"),
            candidateSource: .fastPath
        )
        let resolution = try C2ScopeResolver.resolve(frame: frame, cell: cell)
        XCTAssertEqual(resolution.origin, .explicit)
        XCTAssertEqual(resolution.keys, ["ac.temp_setpoint[主驾]"])
        XCTAssertEqual(try C2ScopeResolver.requestedScope(from: frame), "主驾")
    }

    func testScopeResolution_directionAndModeDoNotConflict() throws {
        // mode is not a scope-bearing slot; must not first-wins-drop or conflict with direction.
        let admission = try XCTUnwrap(catalog.admission(for: "主驾制热调24度"))
        let pipeline = try DemoRuntimeContractBundle.singleCommandDemoDefault.makePipeline()
        let cell = try XCTUnwrap(pipeline.stateCells.cell(id: "ac.temp_setpoint"))
        let resolution = try C2ScopeResolver.resolve(frame: admission.frame, cell: cell)
        XCTAssertEqual(resolution.origin, .explicit)
        XCTAssertEqual(resolution.resolvedScopes, ["主驾"])
    }
}

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

import XCTest
@testable import MAformacCore

/// Phase 1a golden + G3 四族 mutation/readback 行为门。
/// 元断言：每条必经 DemoSliceRoute.route(text:) 真实解析路径。
/// 禁：直接构造帧 / 自定义解码器 / 预设规划器注入。
/// 后三族仍为 Phase2 candidate：本门只证静止态 mutation/readback，不抬 proven / 不授权演示。
final class DemoSliceProductBehaviorGateTests: XCTestCase {

    private let windowMovingRefuse = "行驶中为了安全暂时不能开窗, 停稳后我再帮您"

    @MainActor
    struct Harness {
        let store: DemoVehicleStateStore
        let route: DemoSliceRoute
        init(cells: [DemoVehicleStateCell] = DemoVehicleStateStore.defaultCells()) throws {
            let store = DemoVehicleStateStore(cells: cells)
            let speech = RecordingSpeechSynthesisEngine()
            self.store = store
            self.route = try DemoSliceRoute(
                store: store,
                traceLogger: InMemoryTraceLogger(),
                speech: speech
            )
        }
    }

    // MARK: - Positive: 执行并变更状态

    @MainActor
    func test01_openAC_powerOn() async throws {
        let h = try Harness()
        let result = try await h.route.route(text: "打开空调")
        let exec = try XCTUnwrap(result.execution)
        XCTAssertEqual(h.store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(h.route.runnerCallCount, 1)
        XCTAssertTrue(exec.payload.readbacks.contains { $0.key == "ac.power" })
    }

    @MainActor
    func test02_setTemp26_prefixA() async throws {
        let h = try Harness()
        let result = try await h.route.route(text: "把空调调到26度")
        let exec = try XCTUnwrap(result.execution)
        XCTAssertEqual(h.store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(h.store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, "26")
        XCTAssertTrue(exec.payload.readbacks.contains { $0.actualValue == "26" })
    }

    @MainActor
    func test03_setTemp26_prefixB() async throws {
        let h = try Harness()
        let result1 = try await h.route.route(text: "空调调到26度")
        let exec1 = try XCTUnwrap(result1.execution)
        XCTAssertEqual(exec1.payload.outcome.result, .acceptedToolCall)
        XCTAssertEqual(h.store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(h.store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, "26")

        let cellsAfterFirst = h.store.cells
        let revisionAfterFirst = h.store.currentRevision
        let runnerCountAfterFirst = h.route.runnerCallCount

        let result2 = try await h.route.route(text: "空调调到26度")
        let exec2 = try XCTUnwrap(result2.execution)
        XCTAssertEqual(exec2.payload.outcome.result, .alreadyStateNoop)
        XCTAssertEqual(exec2.payload.readbacks.map(\.key), ["ac.temp_setpoint[主驾]"])
        XCTAssertEqual(h.route.runnerCallCount, runnerCountAfterFirst)
        XCTAssertEqual(h.store.currentRevision, revisionAfterFirst)
        XCTAssertEqual(h.store.cells, cellsAfterFirst)
    }

    @MainActor
    func test03a_freshDefaultTemp24StillPowersOn() async throws {
        let h = try Harness()

        let result = try await h.route.route(text: "把空调调到24度")
        let execution = try XCTUnwrap(result.execution)

        XCTAssertEqual(execution.payload.outcome.result, .acceptedToolCall)
        XCTAssertEqual(h.route.runnerCallCount, 1)
        XCTAssertEqual(h.store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(h.store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, "24")
        XCTAssertTrue(execution.payload.readbacks.contains {
            $0.key == "ac.power" && $0.actualValue == "on"
        })
        XCTAssertEqual(execution.payload.mutationCount, 1)
    }

    @MainActor
    func testWP21BatchA_driverWindowAddsFiftyPercentFromCurrentState() async throws {
        var cells = DemoVehicleStateStore.defaultCells()
        let driverIndex = try XCTUnwrap(
            cells.firstIndex { $0.key == "window.position[主驾]" }
        )
        cells[driverIndex].actualValue = "20"
        let h = try Harness(cells: cells)

        let result = try await h.route.route(text: "把主驾车窗再开50%")
        let execution = try XCTUnwrap(result.execution)

        XCTAssertNil(result.rejection)
        XCTAssertEqual(execution.admission.entry.matrixID, 31)
        XCTAssertEqual(execution.admission.entry.contractRowID, "c1_carControl_000021")
        XCTAssertEqual(execution.admission.frame.toolName, "open_window_by_number")
        XCTAssertEqual(execution.admission.frame.device, "window")
        XCTAssertEqual(execution.admission.frame.actionPrimitive, "by_percent")
        XCTAssertEqual(execution.admission.frame.slots["position"], "主驾")
        XCTAssertEqual(execution.admission.frame.value, ContractValue(
            ref: "CUR",
            direct: "+",
            offset: "50",
            type: "PERCENT"
        ))
        XCTAssertEqual(h.route.runnerCallCount, 1)
        XCTAssertEqual(execution.payload.mutationCount, 1)
        XCTAssertEqual(h.store.cell(for: "window.position[主驾]")?.actualValue, "70")
        XCTAssertEqual(h.store.cell(for: "window.position[副驾]")?.actualValue, "0")
        XCTAssertEqual(h.store.cell(for: "window.position[左后]")?.actualValue, "0")
        XCTAssertEqual(h.store.cell(for: "window.position[右后]")?.actualValue, "0")
        XCTAssertTrue(execution.payload.readbacks.contains {
            $0.key == "window.position[主驾]"
                && $0.actualValue == "70"
                && $0.revision == h.store.cell(for: "window.position[主驾]")?.revision
        })
        let display = try XCTUnwrap(
            VehicleCardDisplay.displays(from: [
                try XCTUnwrap(h.store.cell(for: "window.position[主驾]"))
            ])
                .first { $0.accessibilityKey == "window.position[主驾]" }
        )
        XCTAssertEqual(display.valueText, "70%")
    }

    @MainActor
    func testWP21BatchA_windowSixtyToHundredTenOutOfRangeFailClosed() async throws {
        var cells = DemoVehicleStateStore.defaultCells()
        let driverIndex = try XCTUnwrap(
            cells.firstIndex { $0.key == "window.position[主驾]" }
        )
        cells[driverIndex].actualValue = "60"
        let h = try Harness(cells: cells)

        do {
            let _ = try await h.route.route(text: "把主驾车窗再开50%")
            XCTFail("expected ToolExecutionError.schemaInvalid(.outOfRange)")
        } catch let error as ToolExecutionError {
            guard case .schemaInvalid(.outOfRange(let field)) = error else {
                return XCTFail("expected .schemaInvalid(.outOfRange), got \(error)")
            }
            XCTAssertEqual(field, "window.position")
        }

        // Store/runtime unchanged — no mutation, no revision bump
        XCTAssertEqual(h.store.currentRevision, 0)
        XCTAssertEqual(h.store.cell(for: "window.position[主驾]")?.actualValue, "60")
        XCTAssertEqual(h.store.cell(for: "window.position[副驾]")?.actualValue, "0")
        XCTAssertEqual(h.store.cell(for: "window.position[左后]")?.actualValue, "0")
        XCTAssertEqual(h.store.cell(for: "window.position[右后]")?.actualValue, "0")
    }

    @MainActor
    func testWP21BatchA_genericWindowCommandRemainsRejectedWithoutMutation() async throws {
        let h = try Harness()
        let cellsBefore = h.store.cells

        let result = try await h.route.route(text: "打开车窗")

        XCTAssertNil(result.execution)
        XCTAssertEqual(result.rejection, .notInCatalog)
        XCTAssertEqual(h.route.runnerCallCount, 0)
        XCTAssertEqual(h.store.currentRevision, 0)
        XCTAssertEqual(h.store.cells, cellsBefore)
    }

    @MainActor
    func testWP21BatchB_openAmbientLightMutatesPower() async throws {
        let h = try Harness()
        let result = try await h.route.route(text: "打开氛围灯")
        let execution = try XCTUnwrap(result.execution)

        XCTAssertNil(result.rejection)
        XCTAssertEqual(execution.admission.entry.matrixID, 1972)
        XCTAssertEqual(execution.admission.entry.contractRowID, "c1_carControl_001972")
        XCTAssertEqual(execution.admission.frame.toolName, "open_atmosphere_lamp")
        XCTAssertEqual(execution.admission.frame.device, "atmosphere_lamp")
        XCTAssertEqual(execution.admission.frame.actionPrimitive, "power_on")
        XCTAssertEqual(h.route.runnerCallCount, 1)
        XCTAssertEqual(execution.payload.mutationCount, 1)
        XCTAssertEqual(h.store.cell(for: "ambient.power")?.actualValue, "on")
        XCTAssertTrue(execution.payload.readbacks.contains {
            $0.key == "ambient.power"
                && $0.actualValue == "on"
                && $0.revision == h.store.cell(for: "ambient.power")?.revision
        })
        let display = try XCTUnwrap(
            VehicleCardDisplay.displays(from: [
                try XCTUnwrap(h.store.cell(for: "ambient.power"))
            ])
                .first { $0.accessibilityKey == "ambient.power" }
        )
        XCTAssertEqual(display.title, "氛围灯开关")
        XCTAssertEqual(display.valueText, "开")
        let cellsAfterFirst = h.store.cells
        let revisionAfterFirst = h.store.currentRevision
        let secondResult = try await h.route.route(text: "打开氛围灯")
        let secondExecution = try XCTUnwrap(secondResult.execution)
        XCTAssertEqual(secondExecution.payload.outcome.result, .alreadyStateNoop)
        XCTAssertEqual(secondExecution.payload.mutationCount, 0)
        XCTAssertEqual(h.route.runnerCallCount, 1)
        XCTAssertEqual(h.store.currentRevision, revisionAfterFirst)
        XCTAssertEqual(h.store.cells, cellsAfterFirst)
    }

    @MainActor
    func testWP21BatchC_openPassengerSeatHeatMutatesLevel() async throws {
        let h = try Harness()
        let result = try await h.route.route(text: "打开副驾座椅加热")
        let execution = try XCTUnwrap(result.execution)

        XCTAssertNil(result.rejection)
        XCTAssertEqual(execution.admission.entry.matrixID, 201)
        XCTAssertEqual(execution.admission.entry.contractRowID, "c1_carControl_000201")
        XCTAssertEqual(execution.admission.frame.toolName, "open_seat_heat")
        XCTAssertEqual(execution.admission.frame.device, "seat_heat")
        XCTAssertEqual(execution.admission.frame.actionPrimitive, "power_on")
        XCTAssertEqual(h.route.runnerCallCount, 1)
        XCTAssertEqual(execution.payload.mutationCount, 1)
        XCTAssertEqual(h.store.cell(for: "seat.heat_level[副驾]")?.actualValue, "1")
        XCTAssertEqual(h.store.cell(for: "seat.heat_level[主驾]")?.actualValue, "0")
        XCTAssertTrue(execution.payload.readbacks.contains {
            $0.key == "seat.heat_level[副驾]"
                && $0.actualValue == "1"
                && $0.revision == h.store.cell(for: "seat.heat_level[副驾]")?.revision
        })
        let display = try XCTUnwrap(
            VehicleCardDisplay.displays(from: [
                try XCTUnwrap(h.store.cell(for: "seat.heat_level[副驾]"))
            ])
                .first { $0.accessibilityKey == "seat.heat_level[副驾]" }
        )
        XCTAssertEqual(display.title, "副驾座椅加热")
        XCTAssertEqual(display.valueText, "1挡")
        let cellsAfterFirst = h.store.cells
        let revisionAfterFirst = h.store.currentRevision
        let secondResult = try await h.route.route(text: "打开副驾座椅加热")
        let secondExecution = try XCTUnwrap(secondResult.execution)
        XCTAssertEqual(secondExecution.payload.outcome.result, .alreadyStateNoop)
        XCTAssertEqual(secondExecution.payload.mutationCount, 0)
        XCTAssertEqual(h.route.runnerCallCount, 1)
        XCTAssertEqual(h.store.currentRevision, revisionAfterFirst)
        XCTAssertEqual(h.store.cells, cellsAfterFirst)
    }

    // MARK: - G3 four-family gate extension (row167 compound + CUR OOR + moving refuse)

    @MainActor
    func testG3_row167_compoundColdStart_mutatesPowerModeTempWithReadbackAndUI() async throws {
        let h = try Harness()
        let result = try await h.route.route(text: "主驾制热调26度")
        let execution = try XCTUnwrap(result.execution)

        XCTAssertNil(result.rejection)
        XCTAssertEqual(execution.admission.entry.matrixID, 167)
        XCTAssertEqual(execution.admission.entry.contractRowID, "c1_airControl_000167")
        XCTAssertEqual(execution.admission.frame.toolName, "adjust_ac_temperature_to_number")
        XCTAssertEqual(execution.admission.frame.slots["direction"], "主驾")
        XCTAssertEqual(execution.admission.frame.slots["mode"], "制热")
        XCTAssertEqual(h.route.runnerCallCount, 1)
        XCTAssertEqual(execution.payload.mutationCount, 3)
        XCTAssertEqual(h.store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(h.store.cell(for: "ac.mode")?.actualValue, "制热")
        XCTAssertEqual(h.store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, "26")
        XCTAssertEqual(
            execution.payload.readbacks.map(\.key),
            ["ac.power", "ac.mode", "ac.temp_setpoint[主驾]"]
        )
        XCTAssertTrue(execution.payload.readbacks.contains {
            $0.key == "ac.power" && $0.actualValue == "on"
                && $0.revision == h.store.cell(for: "ac.power")?.revision
        })
        XCTAssertTrue(execution.payload.readbacks.contains {
            $0.key == "ac.mode" && $0.actualValue == "制热"
                && $0.revision == h.store.cell(for: "ac.mode")?.revision
        })
        XCTAssertTrue(execution.payload.readbacks.contains {
            $0.key == "ac.temp_setpoint[主驾]" && $0.actualValue == "26"
                && $0.revision == h.store.cell(for: "ac.temp_setpoint[主驾]")?.revision
        })

        let powerDisplay = try XCTUnwrap(
            VehicleCardDisplay.displays(from: [
                try XCTUnwrap(h.store.cell(for: "ac.power"))
            ])
            .first { $0.accessibilityKey == "ac.power" }
        )
        XCTAssertEqual(powerDisplay.valueText, "开")

        let modeDisplay = try XCTUnwrap(
            VehicleCardDisplay.displays(from: [
                try XCTUnwrap(h.store.cell(for: "ac.mode"))
            ])
            .first { $0.accessibilityKey == "ac.mode" }
        )
        XCTAssertEqual(modeDisplay.valueText, "制热")

        let tempDisplay = try XCTUnwrap(
            VehicleCardDisplay.displays(from: [
                try XCTUnwrap(h.store.cell(for: "ac.temp_setpoint[主驾]"))
            ])
            .first { $0.accessibilityKey == "ac.temp_setpoint[主驾]" }
        )
        XCTAssertEqual(tempDisplay.valueText, "26℃")
    }

    @MainActor
    func testG3_row167_onlyTempUnsatisfied_mutationOne() async throws {
        var cells = DemoVehicleStateStore.defaultCells()
        let powerIdx = try XCTUnwrap(cells.firstIndex { $0.key == "ac.power" })
        let modeIdx = try XCTUnwrap(cells.firstIndex { $0.key == "ac.mode" })
        let tempIdx = try XCTUnwrap(cells.firstIndex { $0.key == "ac.temp_setpoint[主驾]" })
        cells[powerIdx].actualValue = "on"
        cells[modeIdx].actualValue = "制热"
        cells[tempIdx].actualValue = "20"
        let h = try Harness(cells: cells)

        let result = try await h.route.route(text: "主驾制热调24度")
        let execution = try XCTUnwrap(result.execution)

        XCTAssertEqual(execution.admission.entry.matrixID, 167)
        XCTAssertEqual(h.route.runnerCallCount, 1)
        XCTAssertEqual(execution.payload.mutationCount, 1)
        XCTAssertEqual(h.store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(h.store.cell(for: "ac.mode")?.actualValue, "制热")
        XCTAssertEqual(h.store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, "24")
        XCTAssertEqual(execution.payload.readbacks.map(\.key), ["ac.temp_setpoint[主驾]"])
        XCTAssertTrue(execution.payload.readbacks.contains {
            $0.key == "ac.temp_setpoint[主驾]" && $0.actualValue == "24"
        })
    }

    @MainActor
    func testG3_row167_fullTargetsSatisfied_alreadyStateNoop() async throws {
        var cells = DemoVehicleStateStore.defaultCells()
        let powerIdx = try XCTUnwrap(cells.firstIndex { $0.key == "ac.power" })
        let modeIdx = try XCTUnwrap(cells.firstIndex { $0.key == "ac.mode" })
        let tempIdx = try XCTUnwrap(cells.firstIndex { $0.key == "ac.temp_setpoint[主驾]" })
        cells[powerIdx].actualValue = "on"
        cells[modeIdx].actualValue = "制热"
        cells[tempIdx].actualValue = "24"
        let h = try Harness(cells: cells)
        let cellsBefore = h.store.cells
        let revisionBefore = h.store.currentRevision

        let result = try await h.route.route(text: "主驾制热调24度")
        let execution = try XCTUnwrap(result.execution)

        XCTAssertEqual(execution.admission.entry.matrixID, 167)
        XCTAssertEqual(execution.payload.outcome.result, .alreadyStateNoop)
        XCTAssertEqual(execution.payload.mutationCount, 0)
        XCTAssertEqual(h.route.runnerCallCount, 0)
        XCTAssertEqual(h.store.currentRevision, revisionBefore)
        XCTAssertEqual(h.store.cells, cellsBefore)
    }

    @MainActor
    func testG3_windowSeventyToHundredTwentyOutOfRangeFailClosed() async throws {
        var cells = DemoVehicleStateStore.defaultCells()
        let driverIndex = try XCTUnwrap(
            cells.firstIndex { $0.key == "window.position[主驾]" }
        )
        cells[driverIndex].actualValue = "70"
        let h = try Harness(cells: cells)
        let beforeRevision = h.store.currentRevision
        let beforeCells = h.store.cells

        do {
            _ = try await h.route.route(text: "把主驾车窗再开50%")
            XCTFail("expected ToolExecutionError.schemaInvalid(.outOfRange)")
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
    func testG3_windowMovingSpeedRefusesWithoutMutation() async throws {
        var cells = DemoVehicleStateStore.defaultCells()
        let windowIdx = try XCTUnwrap(cells.firstIndex { $0.key == "window.position[主驾]" })
        let speedIdx = try XCTUnwrap(cells.firstIndex { $0.key == "vehicle.speed" })
        let gearIdx = try XCTUnwrap(cells.firstIndex { $0.key == "vehicle.gear" })
        cells[windowIdx].actualValue = "20"
        cells[speedIdx].actualValue = "30"
        cells[gearIdx].actualValue = "D"
        let h = try Harness(cells: cells)
        let beforeRevision = h.store.currentRevision
        let beforeCells = h.store.cells

        do {
            _ = try await h.route.route(text: "把主驾车窗再开50%")
            XCTFail("expected ToolExecutionError.guardDenied(moving)")
        } catch let error as ToolExecutionError {
            XCTAssertEqual(error, .guardDenied(windowMovingRefuse))
        }

        XCTAssertEqual(h.route.runnerCallCount, 1, "safety refusal must still count a runner attempt")
        XCTAssertEqual(h.store.currentRevision, beforeRevision)
        XCTAssertEqual(h.store.cells, beforeCells)
        XCTAssertEqual(h.store.cell(for: "window.position[主驾]")?.actualValue, "20")
    }

    @MainActor
    func test04_setTemp26_polite() async throws {
        let h = try Harness()
        let result = try await h.route.route(text: "请把空调调到26度")
        XCTAssertNotNil(result.execution)
        XCTAssertEqual(h.store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(h.store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, "26")
    }

    @MainActor
    func test05_setTemp26_question() async throws {
        let h = try Harness()
        let result = try await h.route.route(text: "能调到26度吗")
        XCTAssertNotNil(result.execution)
        XCTAssertEqual(h.store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(h.store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, "26")
    }

    @MainActor
    func test06_setTemp26_openTo() async throws {
        let h = try Harness()
        let result = try await h.route.route(text: "打开空调到26度")
        XCTAssertNotNil(result.execution)
        XCTAssertEqual(h.store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(h.store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, "26")
    }

    // MARK: - Negative: 拒绝并不变更状态

    @MainActor
    func test07_alreadyOn_noDuplicateMutation() async throws {
        let h = try Harness()
        let result1 = try await h.route.route(text: "打开空调")
        let exec1 = try XCTUnwrap(result1.execution)
        XCTAssertEqual(exec1.payload.outcome.result, .acceptedToolCall)
        let revAfterFirst = h.store.currentRevision
        let cellsAfterFirst = h.store.cells
        let runnerCountAfterFirst = h.route.runnerCallCount
        
        let result2 = try await h.route.route(text: "打开空调")
        let exec2 = try XCTUnwrap(result2.execution)
        
        // Second call: alreadyStateNoop - no runner increment or mutation
        XCTAssertEqual(h.route.runnerCallCount, runnerCountAfterFirst, "runnerCallCount should not increment on already-on")
        XCTAssertEqual(h.store.currentRevision, revAfterFirst, "store revision should not change on already-on")
        XCTAssertEqual(h.store.cells, cellsAfterFirst, "all store cells should remain byte-for-byte equivalent on already-on")
        XCTAssertEqual(h.store.cell(for: "ac.power")?.actualValue, "on", "ac.power should remain 'on'")
        XCTAssertEqual(exec2.runnerCallCount, 1, "execution.runnerCallCount should reflect single runner call")
        XCTAssertEqual(exec2.payload.outcome.result, .alreadyStateNoop, "outcome should be alreadyStateNoop")
        XCTAssertEqual(exec2.payload.outcome.reason, "already_done", "reason should be already_done")
        XCTAssertEqual(exec2.payload.readbacks.count, 1, "should have one readback")
        XCTAssertEqual(exec2.payload.readbacks.first?.key, "ac.power", "readback key should be ac.power")
    }

    @MainActor
    func test08_unreviewedWindowShorthandIsRejected() async throws {
        let h = try Harness()
        let result = try await h.route.route(text: "打开车窗")
        XCTAssertNil(result.execution)
        XCTAssertEqual(result.rejection, .notInCatalog)
        XCTAssertEqual(h.route.runnerCallCount, 0)
        XCTAssertEqual(h.store.currentRevision, 0)
    }

    @MainActor
    func test09_blank_rejected() async throws {
        let h = try Harness()
        let result = try await h.route.route(text: "")
        XCTAssertNil(result.execution)
        XCTAssertEqual(result.rejection, .blank)
        XCTAssertEqual(h.route.runnerCallCount, 0)
    }

    @MainActor
    func test10_outOfRange_low() async throws {
        let h = try Harness()
        let result = try await h.route.route(text: "把空调调到17度")
        XCTAssertNil(result.execution)
        XCTAssertEqual(result.rejection, .valueOutOfRange(actual: 17, allowed: 18...32))
        XCTAssertEqual(h.store.currentRevision, 0)
    }

    @MainActor
    func test11_outOfRange_high() async throws {
        let h = try Harness()
        let result = try await h.route.route(text: "把空调调到33度")
        XCTAssertNil(result.execution)
        XCTAssertEqual(result.rejection, .valueOutOfRange(actual: 33, allowed: 18...32))
        XCTAssertEqual(h.store.currentRevision, 0)
    }

    @MainActor
    func test12_multiIntent_gap_rejected() async throws {
        let h = try Harness()
        let result = try await h.route.route(text: "打开空调并打开车窗")
        // 当前 fail-closed：多意图无切分，catalog 拒绝
        XCTAssertNil(result.execution)
        XCTAssertNotNil(result.rejection)
        XCTAssertEqual(h.route.runnerCallCount, 0)
    }
}

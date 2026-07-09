import XCTest
@testable import MAformacCore

@MainActor
final class SceneBeatIntegrationTests: XCTestCase {
    func testScene1Beat1ACAlreadyOffNoopRunsEndToEndForContractVariants() throws {
        let variants = ["关空调", "把空调关了", "空调关掉", "不用空调了"]

        for utterance in variants {
            let snapshot = try commitPlannerBeat(
                utterance: utterance,
                cells: [
                    DemoVehicleStateCell(key: "ac.power", actualValue: "off", revision: 4, visualState: .normal),
                    DemoVehicleStateCell(key: "ac.temp_setpoint[主驾]", actualValue: "24")
                ],
                expectedPreset: .acAlreadyOffNoop
            )

            XCTAssertEqual(snapshot.resultKind, .alreadyStateNoop, utterance)
            XCTAssertEqual(snapshot.dialogText, "空调已经是关闭的了", utterance)
            XCTAssertEqual(snapshot.readbacks.map(\.spokenText), ["空调已经是关闭的了"], utterance)
            XCTAssertEqual(snapshot.cell("ac.power")?.actualValue, "off", utterance)
            XCTAssertEqual(snapshot.cell("ac.power")?.visualState, .normal, utterance)
            XCTAssertEqual(snapshot.activeCells[.ac], "ac.power", utterance)
            XCTAssertEqual(snapshot.proofClass, .simulatorMock, utterance)
        }
    }

    func testRT2FMP01ACOnCloseRunsEndToEndInsteadOfFalseNoop() throws {
        let variants = ["关空调", "把空调关了", "空调关掉", "不用空调了", "空调关一下"]

        for utterance in variants {
            let snapshot = try commitPlannerBeat(
                utterance: utterance,
                cells: [
                    DemoVehicleStateCell(key: "ac.power", actualValue: "on", revision: 4, visualState: .satisfied),
                    DemoVehicleStateCell(key: "ac.temp_setpoint[主驾]", actualValue: "24")
                ],
                expectedPreset: .acClose
            )

            XCTAssertEqual(snapshot.resultKind, .acceptedToolCall, utterance)
            XCTAssertEqual(snapshot.dialogText, "空调已关闭", utterance)
            XCTAssertEqual(snapshot.readbacks.map(\.spokenText), ["空调已关闭"], utterance)
            XCTAssertEqual(snapshot.cell("ac.power")?.actualValue, "off", utterance)
            XCTAssertEqual(snapshot.cell("ac.power")?.visualState, .normal, utterance)
            XCTAssertEqual(snapshot.activeCells[.ac], "ac.power", utterance)
            XCTAssertEqual(snapshot.proofClass, .simulatorMock, utterance)
        }
    }

    func testScene1Beat2ColdFeelingFallsThroughPlannerAndLegacyPathRaisesTemperature() throws {
        let variants = ["有点冷", "好冷啊", "冻死了", "车里温度有点低", "凉飕飕的"]

        for utterance in variants {
            XCTAssertNil(MockVoicePresetPlanner.plan(
                utterance: utterance,
                cells: DemoVehicleStateStore.defaultCells(),
                context: .idle,
                priorReadbacks: []
            ), utterance)

            let snapshot = commitLegacyColdIntent(cells: [
                DemoVehicleStateCell(key: "ac.power", actualValue: "off"),
                DemoVehicleStateCell(key: "ac.temp_setpoint[主驾]", actualValue: "24")
            ])

            XCTAssertEqual(snapshot.resultKind, .acceptedToolCall, utterance)
            XCTAssertEqual(snapshot.dialogText, "当前 24℃，已为您升到 26℃", utterance)
            XCTAssertEqual(snapshot.readbacks.last?.key, "ac.temp_setpoint[主驾]", utterance)
            XCTAssertEqual(snapshot.readbacks.last?.actualValue, "26", utterance)
            XCTAssertEqual(snapshot.cell("ac.temp_setpoint[主驾]")?.actualValue, "26", utterance)
            XCTAssertEqual(snapshot.cell("ac.temp_setpoint[主驾]")?.visualState, .changing, utterance)
            XCTAssertEqual(snapshot.activeCells[.ac], "ac.temp_setpoint[主驾]", utterance)
        }
    }

    func testScene1Beat3ScreenBrightnessIsExplicitlySkippedUntilMockPresetIsMounted() throws {
        throw XCTSkip("scene1 beat3 screen.brightness is not RT2-mounted: MockVoicePresetPlanner has no screen route, and applyMockVoiceColdIntent legacy fallback only targets AC temperature.")
    }

    func testScene2Beat1ACOnAndTemperature24RunsEndToEndForContractVariants() throws {
        let variants = ["打开空调把温度调到24度", "开空调调到24度", "空调打开设成24", "把空调开了温度24"]

        for utterance in variants {
            let snapshot = try commitPlannerBeat(
                utterance: utterance,
                cells: [
                    DemoVehicleStateCell(key: "ac.power", actualValue: "off"),
                    DemoVehicleStateCell(key: "ac.temp_setpoint[主驾]", actualValue: "22")
                ],
                expectedPreset: .acOnTemp24
            )

            XCTAssertEqual(snapshot.resultKind, .acceptedToolCall, utterance)
            XCTAssertEqual(snapshot.dialogText, "空调已打开, 温度24度", utterance)
            XCTAssertEqual(snapshot.readbacks.map(\.key), ["ac.power", "ac.temp_setpoint[主驾]"], utterance)
            XCTAssertEqual(snapshot.cell("ac.power")?.actualValue, "on", utterance)
            XCTAssertEqual(snapshot.cell("ac.power")?.visualState, .satisfied, utterance)
            XCTAssertEqual(snapshot.cell("ac.temp_setpoint[主驾]")?.actualValue, "24", utterance)
            XCTAssertEqual(snapshot.cell("ac.temp_setpoint[主驾]")?.visualState, .changing, utterance)
            XCTAssertEqual(snapshot.activeCells[.ac], "ac.temp_setpoint[主驾]", utterance)
        }
    }

    func testScene2Beat2AmbientLampCompositeIsExplicitlySkippedUntilMockPresetIsMounted() throws {
        throw XCTSkip("scene2 beat2 ambient.color + ambient.brightness composite is not RT2-mounted in MockVoicePresetPlanner.")
    }

    func testScene3Turn1WindowOpenRunsEndToEndForContractVariants() throws {
        let variants = ["打开车窗", "把车窗开开", "开一下窗户"]

        for utterance in variants {
            let snapshot = try commitPlannerBeat(
                utterance: utterance,
                cells: DemoVehicleStateStore.defaultCells(),
                expectedPreset: .windowOpen
            )

            XCTAssertEqual(snapshot.resultKind, .acceptedToolCall, utterance)
            XCTAssertEqual(snapshot.dialogText, "主驾车窗开度25%", utterance)
            XCTAssertEqual(snapshot.readbacks.last?.key, "window.position[主驾]", utterance)
            XCTAssertEqual(snapshot.readbacks.last?.spokenText, "主驾车窗开度25%", utterance)
            XCTAssertEqual(snapshot.cell("window.position[主驾]")?.actualValue, "25", utterance)
            XCTAssertEqual(snapshot.cell("window.position[主驾]")?.visualState, .changing, utterance)
            XCTAssertEqual(snapshot.activeCells[.window], "window.position[主驾]", utterance)
            XCTAssertEqual(snapshot.scopeOrigins["window.position[主驾]"], .defaulted, utterance)
        }
    }

    func testScene3Turn2WindowOpenMoreUsesPriorWindowReadbackFocusForContractVariants() throws {
        let variants = ["开大点", "再开大些", "拉大一点", "再大点"]
        let turn1Readback = DemoActionReadback(
            key: "window.position[主驾]",
            actualValue: "25",
            revision: 1,
            spokenText: "主驾车窗开度25%"
        )

        for utterance in variants {
            let snapshot = try commitPlannerBeat(
                utterance: utterance,
                cells: [
                    DemoVehicleStateCell(key: "window.position[主驾]", actualValue: "25"),
                    DemoVehicleStateCell(key: "window.position[副驾]", actualValue: "10")
                ],
                priorReadbacks: [turn1Readback],
                expectedPreset: .windowOpenMore
            )

            XCTAssertEqual(snapshot.resultKind, .acceptedToolCall, utterance)
            XCTAssertEqual(snapshot.dialogText, "车窗已开大", utterance)
            XCTAssertEqual(snapshot.readbacks.map(\.key), ["window.position[主驾]", "window.position[主驾]"], utterance)
            XCTAssertEqual(snapshot.readbacks.last?.actualValue, "45", utterance)
            XCTAssertEqual(snapshot.cell("window.position[主驾]")?.actualValue, "45", utterance)
            XCTAssertEqual(snapshot.cell("window.position[副驾]")?.actualValue, "10", utterance)
            XCTAssertEqual(snapshot.cell("window.position[主驾]")?.visualState, .changing, utterance)
            XCTAssertEqual(snapshot.activeCells[.window], "window.position[主驾]", utterance)
        }
    }

    func testScene4Beat1ExplicitDriverWindowIsExplicitlySkippedUntilScopedMockPresetIsMounted() throws {
        throw XCTSkip("scene4 beat1 explicit scoped driver-window utterances are not RT2-mounted: current window preset only covers default-scope open_window.")
    }

    func testScene5Beat1MovingDoorAndTailgateSafetyRefusalRunsEndToEndForContractVariants() throws {
        let variants: [(utterance: String, expectedPreset: MockVoicePresetID, refusedCell: String, expectedValue: String)] = [
            ("打开车门", .movingDoorSafetyRefusal, "door.car_door", "closed"),
            ("把车门打开", .movingDoorSafetyRefusal, "door.car_door", "closed"),
            ("开一下门", .movingDoorSafetyRefusal, "door.car_door", "closed"),
            ("车门开开", .movingDoorSafetyRefusal, "door.car_door", "closed"),
            ("开个后备箱", .movingTailgateSafetyRefusal, "door.tailgate_height", "0")
        ]

        for variant in variants {
            let snapshot = try commitPlannerBeat(
                utterance: variant.utterance,
                cells: [
                    DemoVehicleStateCell(key: "vehicle.speed", actualValue: "30"),
                    DemoVehicleStateCell(key: "vehicle.gear", actualValue: "D"),
                    DemoVehicleStateCell(key: "door.car_door", actualValue: "closed", visualState: .normal)
                ],
                expectedPreset: variant.expectedPreset
            )

            XCTAssertEqual(snapshot.resultKind, .refusalSafetyOrPolicy, variant.utterance)
            XCTAssertEqual(snapshot.dialogText, "行驶中为了安全暂时不能开门, 停稳后我再帮您", variant.utterance)
            XCTAssertEqual(snapshot.refusedCell, variant.refusedCell, variant.utterance)
            XCTAssertEqual(snapshot.readbacks.last?.key, variant.refusedCell, variant.utterance)
            XCTAssertEqual(snapshot.readbacks.last?.actualValue, variant.expectedValue, variant.utterance)
            XCTAssertEqual(snapshot.cell(variant.refusedCell)?.actualValue, variant.expectedValue, variant.utterance)
            XCTAssertEqual(snapshot.cell(variant.refusedCell)?.visualState, .unsafe, variant.utterance)
            XCTAssertEqual(snapshot.activeCells[.door], variant.refusedCell, variant.utterance)
        }
    }

    func testRT2FMP04ParkedDoorAndTailgateFailClosedInsteadOfLegacyColdFallback() throws {
        let variants: [(utterance: String, expectedPreset: MockVoicePresetID, refusedCell: String, expectedValue: String)] = [
            ("打开车门", .movingDoorPreconditionFailed, "door.car_door", "closed"),
            ("把车门打开", .movingDoorPreconditionFailed, "door.car_door", "closed"),
            ("开一下门", .movingDoorPreconditionFailed, "door.car_door", "closed"),
            ("车门开开", .movingDoorPreconditionFailed, "door.car_door", "closed"),
            ("开个后备箱", .movingTailgatePreconditionFailed, "door.tailgate_height", "0")
        ]

        for variant in variants {
            let snapshot = try commitPlannerBeat(
                utterance: variant.utterance,
                cells: [
                    DemoVehicleStateCell(key: "vehicle.speed", actualValue: "0"),
                    DemoVehicleStateCell(key: "vehicle.gear", actualValue: "P"),
                    DemoVehicleStateCell(key: "ac.temp_setpoint[主驾]", actualValue: "24"),
                    DemoVehicleStateCell(key: "door.car_door", actualValue: "closed", visualState: .normal)
                ],
                expectedPreset: variant.expectedPreset
            )

            XCTAssertEqual(snapshot.resultKind, .clarifyMissingSlot, variant.utterance)
            XCTAssertEqual(snapshot.dialogText, "当前非行驶态, 这条安全演示暂不执行", variant.utterance)
            XCTAssertEqual(snapshot.refusedCell, variant.refusedCell, variant.utterance)
            XCTAssertEqual(snapshot.readbacks.last?.key, variant.refusedCell, variant.utterance)
            XCTAssertEqual(snapshot.readbacks.last?.actualValue, variant.expectedValue, variant.utterance)
            XCTAssertEqual(snapshot.cell(variant.refusedCell)?.actualValue, variant.expectedValue, variant.utterance)
            XCTAssertEqual(snapshot.cell(variant.refusedCell)?.visualState, .blocked_with_alternative, variant.utterance)
            XCTAssertEqual(snapshot.cell("ac.temp_setpoint[主驾]")?.actualValue, "24", variant.utterance)
            XCTAssertEqual(snapshot.activeCells[.door], variant.refusedCell, variant.utterance)
        }
    }

    private func commitPlannerBeat(
        utterance: String,
        cells: [DemoVehicleStateCell],
        context: DemoContext = .idle,
        priorReadbacks: [DemoActionReadback] = [],
        expectedPreset: MockVoicePresetID
    ) throws -> StagePresentationSnapshot {
        let plan = try XCTUnwrap(MockVoicePresetPlanner.plan(
            utterance: utterance,
            cells: cells,
            context: context,
            priorReadbacks: priorReadbacks
        ), utterance)
        XCTAssertEqual(plan.presetID, expectedPreset, utterance)

        let store = DemoVehicleStateStore(cells: cells)
        store.replaceCells(plan.cells)
        return StagePresentationSnapshot.from(
            store: store,
            activeCells: plan.activeCells,
            context: context,
            resultKind: plan.resultKind,
            refusedCell: plan.refusedCell,
            scopeOrigins: plan.scopeOrigins,
            orbState: plan.orbState,
            voiceState: plan.voiceState,
            dialogText: plan.dialogText,
            readbacks: priorReadbacks + plan.readbacks,
            proofClass: plan.proofClass
        )
    }

    private func commitLegacyColdIntent(cells: [DemoVehicleStateCell]) -> StagePresentationSnapshot {
        let store = DemoVehicleStateStore(cells: cells)
        let key = "ac.temp_setpoint[主驾]"
        let currentTemp = Int(store.cell(for: key)?.actualValue ?? "") ?? 26
        let targetTemp = Int(ValueRangeMapper.clamp(Double(currentTemp + 2), forBase: "ac.temp_setpoint"))
        let readback = store.applyMockTransition(
            DemoMockTransition(key: key, desiredValue: "\(targetTemp)", source: .mock)
        )

        return StagePresentationSnapshot.from(
            store: store,
            activeCells: [.ac: key],
            resultKind: .acceptedToolCall,
            scopeOrigins: [key: .defaulted],
            orbState: .speak,
            voiceState: .idle,
            dialogText: "当前 \(currentTemp)℃，已为您升到 \(targetTemp)℃",
            readbacks: [readback],
            proofClass: .simulatorMock
        )
    }
}

private extension StagePresentationSnapshot {
    func cell(_ key: String) -> DemoVehicleStateCell? {
        storeCells.first { $0.key == key }
    }
}

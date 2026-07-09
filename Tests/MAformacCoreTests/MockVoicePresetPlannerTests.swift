import XCTest
@testable import MAformacCore

final class MockVoicePresetPlannerTests: XCTestCase {
    @MainActor
    func testMP01ContractOriginalNoopKeepsACNormalAndDoesNotUseMatrixSatisfiedVisual() throws {
        let cells = [
            DemoVehicleStateCell(key: "ac.power", actualValue: "off", revision: 4, visualState: .normal),
            DemoVehicleStateCell(key: "ac.temp_setpoint[主驾]", actualValue: "24")
        ]

        let plan = try XCTUnwrap(MockVoicePresetPlanner.plan(
            utterance: "关空调",
            cells: cells,
            context: .idle,
            priorReadbacks: []
        ))

        XCTAssertEqual(plan.presetID, .acAlreadyOffNoop)
        XCTAssertEqual(plan.utteranceSource, .contractOriginal)
        XCTAssertEqual(plan.resultKind, .alreadyStateNoop)
        XCTAssertEqual(plan.dialogText, "空调已经是关闭的了")
        XCTAssertEqual(plan.cells.first { $0.key == "ac.power" }?.actualValue, "off")
        XCTAssertEqual(plan.cells.first { $0.key == "ac.power" }?.visualState, .normal)
        XCTAssertEqual(plan.readbacks.map(\.spokenText), ["空调已经是关闭的了"])
        XCTAssertEqual(DemoRuntimeResultPresentationMatrix.entry(for: .alreadyStateNoop).visualState, .satisfied)
    }

    @MainActor
    func testMP01ExtraParaphraseIsMarkedLocalAndStillNoop() throws {
        let plan = try XCTUnwrap(MockVoicePresetPlanner.plan(
            utterance: "空调关一下",
            cells: DemoVehicleStateStore.defaultCells(),
            context: .idle,
            priorReadbacks: []
        ))

        XCTAssertEqual(plan.presetID, .acAlreadyOffNoop)
        XCTAssertEqual(plan.utteranceSource, .extraParaphraseLocal)
        XCTAssertEqual(plan.resultKind, .alreadyStateNoop)
        XCTAssertEqual(plan.cells.first { $0.key == "ac.power" }?.actualValue, "off")
    }

    @MainActor
    func testMP02MultiIntentWritesPowerAndTemperatureWithTwoReadbacks() throws {
        let plan = try XCTUnwrap(MockVoicePresetPlanner.plan(
            utterance: "打开空调把温度调到24度",
            cells: [
                DemoVehicleStateCell(key: "ac.power", actualValue: "off"),
                DemoVehicleStateCell(key: "ac.temp_setpoint[主驾]", actualValue: "22")
            ],
            context: .idle,
            priorReadbacks: []
        ))

        XCTAssertEqual(plan.presetID, .acOnTemp24)
        XCTAssertEqual(plan.resultKind, .acceptedToolCall)
        XCTAssertEqual(plan.cells.first { $0.key == "ac.power" }?.actualValue, "on")
        XCTAssertEqual(plan.cells.first { $0.key == "ac.power" }?.visualState, .satisfied)
        XCTAssertEqual(plan.cells.first { $0.key == "ac.temp_setpoint[主驾]" }?.actualValue, "24")
        XCTAssertEqual(plan.readbacks.map(\.key), ["ac.power", "ac.temp_setpoint[主驾]"])
        XCTAssertEqual(plan.readbacks.last?.spokenText, "空调已打开, 温度24度")
        XCTAssertEqual(plan.activeCells[.ac], "ac.temp_setpoint[主驾]")
    }

    @MainActor
    func testMP03Turn1UsesStateCellsStructuredReadbackInsteadOfYamlDialogAnchor() throws {
        let plan = try XCTUnwrap(MockVoicePresetPlanner.plan(
            utterance: "打开车窗",
            cells: DemoVehicleStateStore.defaultCells(),
            context: .idle,
            priorReadbacks: []
        ))

        XCTAssertEqual(plan.presetID, .windowOpen)
        XCTAssertEqual(plan.dialogCopySource, .stateCellsStructuredReadback)
        XCTAssertEqual(plan.cells.first { $0.key == "window.position[主驾]" }?.actualValue, "25")
        XCTAssertEqual(plan.readbacks.last?.key, "window.position[主驾]")
        XCTAssertEqual(plan.readbacks.last?.spokenText, "主驾车窗开度25%")
        XCTAssertEqual(plan.activeCells[.window], "window.position[主驾]")
    }

    @MainActor
    func testMP03Turn2UsesLastReadbackKeyAsWindowFocusAndAddsTwentyPercent() throws {
        let turn1 = DemoActionReadback(
            key: "window.position[主驾]",
            actualValue: "25",
            revision: 1,
            spokenText: "主驾车窗开度25%"
        )
        let plan = try XCTUnwrap(MockVoicePresetPlanner.plan(
            utterance: "开大点",
            cells: [
                DemoVehicleStateCell(key: "window.position[主驾]", actualValue: "25"),
                DemoVehicleStateCell(key: "window.position[副驾]", actualValue: "10")
            ],
            context: .idle,
            priorReadbacks: [turn1]
        ))

        XCTAssertEqual(plan.presetID, .windowOpenMore)
        XCTAssertEqual(plan.cells.first { $0.key == "window.position[主驾]" }?.actualValue, "45")
        XCTAssertEqual(plan.cells.first { $0.key == "window.position[副驾]" }?.actualValue, "10")
        XCTAssertEqual(plan.readbacks.last?.key, "window.position[主驾]")
        XCTAssertEqual(plan.readbacks.last?.spokenText, "车窗已开大")
        XCTAssertEqual(plan.activeCells[.window], "window.position[主驾]")
    }

    @MainActor
    func testMP04DoorSafetyRefusalHasNoExecutionWriteAndUsesT5MatrixSafetyVisual() throws {
        let plan = try XCTUnwrap(MockVoicePresetPlanner.plan(
            utterance: "打开车门",
            cells: [
                DemoVehicleStateCell(key: "vehicle.speed", actualValue: "30"),
                DemoVehicleStateCell(key: "vehicle.gear", actualValue: "D"),
                DemoVehicleStateCell(key: "door.car_door", actualValue: "closed", visualState: .normal)
            ],
            context: .idle,
            priorReadbacks: []
        ))

        XCTAssertEqual(plan.presetID, .movingDoorSafetyRefusal)
        XCTAssertEqual(plan.resultKind, .refusalSafetyOrPolicy)
        XCTAssertEqual(plan.dialogText, "行驶中为了安全暂时不能开门, 停稳后我再帮您")
        XCTAssertEqual(plan.cells.first { $0.key == "door.car_door" }?.actualValue, "closed")
        XCTAssertEqual(plan.cells.first { $0.key == "door.car_door" }?.visualState, DemoRuntimeResultPresentationMatrix.errorEntry(for: .safety).visualState)
        XCTAssertEqual(plan.refusedCell, "door.car_door")
        XCTAssertEqual(plan.readbacks.last?.key, "door.car_door")
        XCTAssertEqual(plan.timing, .safetyFixed(milliseconds: 1000))
    }

    @MainActor
    func testMP04TailgateUtteranceTargetsTailgateHeight() throws {
        let plan = try XCTUnwrap(MockVoicePresetPlanner.plan(
            utterance: "开个后备箱",
            cells: [
                DemoVehicleStateCell(key: "vehicle.speed", actualValue: "30"),
                DemoVehicleStateCell(key: "vehicle.gear", actualValue: "D")
            ],
            context: .idle,
            priorReadbacks: []
        ))

        XCTAssertEqual(plan.presetID, .movingTailgateSafetyRefusal)
        XCTAssertEqual(plan.refusedCell, "door.tailgate_height")
        XCTAssertEqual(plan.cells.first { $0.key == "door.tailgate_height" }?.actualValue, "0")
        XCTAssertEqual(plan.cells.first { $0.key == "door.tailgate_height" }?.visualState, .unsafe)
        XCTAssertEqual(plan.readbacks.last?.actualValue, "0")
    }

    @MainActor
    func testMP04DoesNotTriggerSafetyPresetWhenVehicleIsParked() {
        let plan = MockVoicePresetPlanner.plan(
            utterance: "打开车门",
            cells: [
                DemoVehicleStateCell(key: "vehicle.speed", actualValue: "0"),
                DemoVehicleStateCell(key: "vehicle.gear", actualValue: "P")
            ],
            context: .idle,
            priorReadbacks: []
        )

        XCTAssertNil(plan)
    }
}

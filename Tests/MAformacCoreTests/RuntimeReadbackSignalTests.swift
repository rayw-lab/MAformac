import XCTest
@testable import MAformacCore

/// D1a T7c —— 招牌① 能量线 runtime 事件缝单测（B①：stub 事件注入点，T5 未 merge 留缝）。
final class RuntimeReadbackSignalTests: XCTestCase {

    func testFiresOnlyWithTarget() {
        // 有目标卡 → 触发能量线
        let withTarget = RuntimeReadbackSignal.stub(readbackID: "rb-1", target: "ac")
        XCTAssertTrue(RuntimeReadbackSignalRouter.shouldFireEnergyLine(withTarget))
        XCTAssertEqual(RuntimeReadbackSignalRouter.targetFamily(withTarget), "ac")
    }

    func testNoFireWhenNilOrEmptyTarget() {
        XCTAssertFalse(RuntimeReadbackSignalRouter.shouldFireEnergyLine(nil))
        XCTAssertNil(RuntimeReadbackSignalRouter.targetFamily(nil))
        let noTarget = RuntimeReadbackSignal.stub(readbackID: "rb-2", target: "")
        XCTAssertFalse(RuntimeReadbackSignalRouter.shouldFireEnergyLine(noTarget), "无目标不触发能量线")
        XCTAssertNil(RuntimeReadbackSignalRouter.targetFamily(noTarget))
    }

    func testStubCarriesReadbackID() {
        let s = RuntimeReadbackSignal.stub(readbackID: "rb-42", target: "seat")
        XCTAssertEqual(s.readbackID, "rb-42")   // 对齐 T5 readbackID 语义
        XCTAssertEqual(s.targetFamilyID, "seat")
    }

    func testRuntimeEventDerivesTargetFromLatestReadbackKey() {
        let event = T5PresentationEvent.runtime(
            snapshot: StagePresentationSnapshot(
                storeCells: [DemoVehicleStateCell(key: "screen.brightness[中控屏]", actualValue: "60", visualState: .changing)],
                activeCells: [:],
                readbacks: [
                    DemoActionReadback(key: "screen.brightness[中控屏]", actualValue: "60", revision: 3, spokenText: "屏幕亮度已调到60%")
                ]
            ),
            readbackID: "rb-screen-3"
        )

        let signal = RuntimeReadbackSignal.from(event: event)
        XCTAssertEqual(signal?.readbackID, "rb-screen-3")
        XCTAssertEqual(signal?.targetFamilyID, "screen")
    }

    func testRuntimeEventPrefersActiveCellMappingOverReadbackPrefix() {
        let event = T5PresentationEvent.runtime(
            snapshot: StagePresentationSnapshot(
                storeCells: [DemoVehicleStateCell(key: "ambient.color", actualValue: "蓝", visualState: .satisfied)],
                activeCells: [.ambient: "ambient.color"],
                readbacks: [
                    DemoActionReadback(key: "vehicle.speed", actualValue: "0", revision: 1, spokenText: "已保持静止")
                ]
            ),
            readbackID: "rb-active-ambient"
        )

        XCTAssertEqual(RuntimeReadbackSignal.from(event: event)?.targetFamilyID, "ambient")
    }

    func testForceStateAndIdleEventsDoNotEmitEnergySignal() {
        XCTAssertNil(RuntimeReadbackSignal.from(event: .forceState(.unsafe)))
        XCTAssertNil(RuntimeReadbackSignal.from(event: .idlePanorama()))
    }

    @MainActor
    func testMP02RuntimeSequenceEmitsTwoT5EventsInReadbackOrder() throws {
        let plan = try XCTUnwrap(MockVoicePresetPlanner.plan(
            utterance: "打开空调把温度调到24度",
            cells: [
                DemoVehicleStateCell(key: "ac.power", actualValue: "off", revision: 2),
                DemoVehicleStateCell(key: "ac.temp_setpoint[主驾]", actualValue: "22", revision: 2)
            ],
            context: .idle,
            priorReadbacks: []
        ))
        let store = DemoVehicleStateStore(cells: [])
        store.replaceCells(plan.cells)
        let finalSnapshot = StagePresentationSnapshot.from(
            store: store,
            activeCells: plan.activeCells,
            resultKind: plan.resultKind,
            scopeOrigins: plan.scopeOrigins,
            orbState: plan.orbState,
            voiceState: plan.voiceState,
            dialogText: plan.dialogText,
            readbacks: plan.readbacks,
            proofClass: plan.proofClass
        )

        let steps = RuntimeReadbackEventSequence.steps(
            snapshot: finalSnapshot,
            priorReadbacks: [],
            readbacks: plan.readbacks
        )
        let expectedIDs = plan.readbacks.map(RuntimeReadbackEventSequence.readbackRuntimeID)

        XCTAssertEqual(steps.count, 2)
        XCTAssertEqual(steps.compactMap { $0.event.readbackID }, expectedIDs)
        XCTAssertEqual(steps.map { $0.event.snapshot.readbacks.last?.key }, ["ac.power", "ac.temp_setpoint[主驾]"])
        XCTAssertEqual(steps.map(\.speechText.text), ["空调已打开", "空调已打开, 温度24度"])
        XCTAssertEqual(steps[0].event.snapshot.readbacks.map(\.key), ["ac.power"])
        XCTAssertEqual(steps[1].event.snapshot.readbacks.map(\.key), ["ac.power", "ac.temp_setpoint[主驾]"])

        let signals = steps.compactMap { RuntimeReadbackSignal.from(event: $0.event) }
        XCTAssertEqual(signals.map(\.readbackID), expectedIDs)
        XCTAssertEqual(signals.map(\.targetFamilyID), ["ac", "ac"])
    }
}

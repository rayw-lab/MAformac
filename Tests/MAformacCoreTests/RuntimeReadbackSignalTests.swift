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
        let initialCells = [
            DemoVehicleStateCell(key: "ac.power", actualValue: "off", revision: 2),
            DemoVehicleStateCell(key: "ac.temp_setpoint[主驾]", actualValue: "22", revision: 2)
        ]
        let plan = try XCTUnwrap(MockVoicePresetPlanner.plan(
            utterance: "打开空调把温度调到24度",
            cells: initialCells,
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
            initialStoreCells: initialCells,
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
        XCTAssertEqual(cellValue("ac.power", in: steps[0].event.snapshot), "on")
        XCTAssertEqual(cellValue("ac.temp_setpoint[主驾]", in: steps[0].event.snapshot), "22")
        XCTAssertEqual(steps[0].event.snapshot.activeCells[.ac], "ac.power")
        XCTAssertEqual(cellValue("ac.power", in: steps[1].event.snapshot), "on")
        XCTAssertEqual(cellValue("ac.temp_setpoint[主驾]", in: steps[1].event.snapshot), "24")
        XCTAssertEqual(steps[1].event.snapshot.activeCells[.ac], "ac.temp_setpoint[主驾]")

        let signals = steps.compactMap { RuntimeReadbackSignal.from(event: $0.event) }
        XCTAssertEqual(signals.map(\.readbackID), expectedIDs)
        XCTAssertEqual(signals.map(\.targetFamilyID), ["ac", "ac"])
    }

    func testRuntimeReadbackQueueRequiresCompletionBeforeAdvancing() throws {
        let snapshot = StagePresentationSnapshot(storeCells: [])
        let steps = [
            RuntimeReadbackEventStep(
                event: .runtime(snapshot: snapshot, readbackID: "rb-1"),
                speechText: T5ReadbackText(id: "rb-1", text: "第一条")
            ),
            RuntimeReadbackEventStep(
                event: .runtime(snapshot: snapshot, readbackID: "rb-2"),
                speechText: T5ReadbackText(id: "rb-2", text: "第二条")
            )
        ]
        var queue = RuntimeReadbackEventQueue()

        XCTAssertEqual(queue.start(steps)?.event.readbackID, "rb-1")
        XCTAssertEqual(queue.inFlightReadbackID, "rb-1")
        XCTAssertEqual(queue.pendingCount, 1)
        XCTAssertNil(queue.completeInFlight(readbackID: "rb-2"))
        XCTAssertEqual(queue.inFlightReadbackID, "rb-1")
        XCTAssertEqual(queue.pendingCount, 1)

        XCTAssertEqual(queue.completeInFlight(readbackID: "rb-1")?.event.readbackID, "rb-2")
        XCTAssertEqual(queue.inFlightReadbackID, "rb-2")
        XCTAssertEqual(queue.pendingCount, 0)
        XCTAssertNil(queue.completeInFlight(readbackID: "rb-1"))
        XCTAssertEqual(queue.inFlightReadbackID, "rb-2")

        XCTAssertNil(queue.completeInFlight(readbackID: "rb-2"))
        XCTAssertTrue(queue.isIdle)
    }

    func testRuntimeReadbackQueueCancelClearsInFlightAndPendingSteps() {
        let snapshot = StagePresentationSnapshot(storeCells: [])
        let steps = ["rb-1", "rb-2"].map { readbackID in
            RuntimeReadbackEventStep(
                event: .runtime(snapshot: snapshot, readbackID: readbackID),
                speechText: T5ReadbackText(id: readbackID, text: readbackID)
            )
        }
        var queue = RuntimeReadbackEventQueue()

        XCTAssertEqual(queue.start(steps)?.event.readbackID, "rb-1")
        XCTAssertEqual(queue.pendingCount, 1)

        queue.cancel()

        XCTAssertTrue(queue.isIdle)
        XCTAssertNil(queue.inFlightReadbackID)
        XCTAssertEqual(queue.pendingCount, 0)
        XCTAssertNil(queue.completeInFlight())
    }

    func testRuntimeSequenceSynthesizesMockCellWhenReadbackKeyIsMissing() throws {
        let readback = DemoActionReadback(
            key: "window.position[主驾]",
            actualValue: "45",
            revision: 7,
            spokenText: "主驾车窗已调到45%"
        )
        let steps = RuntimeReadbackEventSequence.steps(
            snapshot: StagePresentationSnapshot(storeCells: [], readbacks: [readback]),
            initialStoreCells: [],
            priorReadbacks: [],
            readbacks: [readback]
        )

        let cell = try XCTUnwrap(steps.first?.event.snapshot.storeCells.first)
        XCTAssertEqual(cell.key, readback.key)
        XCTAssertEqual(cell.actualValue, "45")
        XCTAssertEqual(cell.desiredValue, "45")
        XCTAssertEqual(cell.source, .mock)
        XCTAssertEqual(cell.revision, 7)
        XCTAssertEqual(steps.first?.event.snapshot.activeCells[.window], readback.key)
    }

    private func cellValue(_ key: String, in snapshot: StagePresentationSnapshot) -> String? {
        snapshot.storeCells.first { $0.key == key }?.actualValue
    }
}

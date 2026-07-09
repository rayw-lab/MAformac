import XCTest
@testable import MAformacCore

final class DialogueStateTests: XCTestCase {
    func testKeepsOnlyRecentTurnsAndTracksFocusFromReadback() {
        var state = DialogueState(maxTurns: 3)

        state.recordUserText("第一轮")
        state.recordAssistantText("第一轮回复")
        state.recordUserText("第二轮")
        state.recordAssistantText("第二轮回复")
        state.recordReadbacks([
            DemoActionReadback(
                key: "window.position[主驾]",
                actualValue: "100",
                revision: 2,
                spokenText: "主驾车窗已打开",
                scopeOrigin: .explicit
            )
        ])

        XCTAssertEqual(state.turns.map(\.text), ["第一轮回复", "第二轮", "第二轮回复"])
        XCTAssertEqual(state.focusEntity, "window")
        XCTAssertEqual(state.lastReadback?.key, "window.position[主驾]")
    }

    func testClearTransientContextKeepsDialogueTurnsButDropsRuntimePointers() {
        var state = DialogueState(maxTurns: 3)
        state.recordUserText("打开空调")
        state.recordAssistantText("空调已打开")
        state.recordReadbacks([
            DemoActionReadback(
                key: "ac.power",
                actualValue: "on",
                revision: 1,
                spokenText: "空调已打开"
            )
        ])

        state.clearTransientContext()

        XCTAssertEqual(state.turns.map(\.text), ["打开空调", "空调已打开"])
        XCTAssertNil(state.focusEntity)
        XCTAssertNil(state.lastReadback)
    }
}

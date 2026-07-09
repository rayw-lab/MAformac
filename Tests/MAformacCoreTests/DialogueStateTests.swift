import XCTest
@testable import MAformacCore

final class DialogueStateTests: XCTestCase {
    func testInitClampsMaxTurnsAndKeepsNewestBoundaryTurns() {
        let state = DialogueState(
            turns: [
                DialogueTurn(role: .user, text: "旧请求"),
                DialogueTurn(role: .assistant, text: "旧回复"),
                DialogueTurn(role: .user, text: "新请求")
            ],
            maxTurns: 0
        )

        XCTAssertEqual(state.maxTurns, 1)
        XCTAssertEqual(state.turns, [DialogueTurn(role: .user, text: "新请求")])
    }

    func testInitKeepsExplicitRuntimePointersWhenTurnsAreTrimmed() {
        let readback = DemoActionReadback(
            key: "seat.heat[副驾]",
            actualValue: "on",
            revision: 9,
            spokenText: "副驾座椅加热已打开"
        )
        let state = DialogueState(
            turns: [
                DialogueTurn(role: .user, text: "第一轮"),
                DialogueTurn(role: .assistant, text: "第一轮回复"),
                DialogueTurn(role: .user, text: "第二轮")
            ],
            focusEntity: "seat",
            lastReadback: readback,
            maxTurns: 2
        )

        XCTAssertEqual(state.maxTurns, 2)
        XCTAssertEqual(state.turns.map(\.text), ["第一轮回复", "第二轮"])
        XCTAssertEqual(state.focusEntity, "seat")
        XCTAssertEqual(state.lastReadback, readback)
    }

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

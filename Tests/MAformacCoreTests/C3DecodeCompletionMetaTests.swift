import XCTest
@testable import MAformacCore

/// gap#1: decode 必须携带 completion 元信息（finish_reason/stop_reason/tool_call_count）。
/// spec tool-execution:16「finish reason 为 length 时 reject」、:23-26「length 截断不修成动作」。
/// 旧 decode 只收 content:String，无法区分「完整 JSON」与「length 截断的半个 JSON」。
final class C3DecodeCompletionMetaTests: XCTestCase {
    func testLengthFinishReasonRejectsBeforeRepairEvenWithParseableJSON() {
        let decoder = ToolCallCandidateDecoder(contentFallbackEnabled: true)
        let content = #"{"device":"window","action_primitive":"power_on","slot":{"position":"主驾"},"value":{"ref":"ZERO","direct":"+","offset":"100","type":"PERCENT"},"state_revision":0}"#
        // 即使 JSON 本身可解析，finish_reason=length 表示输出被截断，不可信。
        let input = ToolCallDecodeInput(content: content, finishReason: .length)

        XCTAssertThrowsError(try decoder.decode(input)) { error in
            XCTAssertEqual(error as? ToolExecutionError, .malformed(.lengthTruncated))
        }
    }

    func testMultipleToolCallCountRejectedAsMultipleFrames() {
        let decoder = ToolCallCandidateDecoder(contentFallbackEnabled: true)
        let content = #"{"device":"window","action_primitive":"power_on"}"#
        let input = ToolCallDecodeInput(content: content, finishReason: .stop, toolCallCount: 2)

        XCTAssertThrowsError(try decoder.decode(input)) { error in
            XCTAssertEqual(error as? ToolExecutionError, .schemaInvalid(.multipleFrames))
        }
    }

    func testStopFinishReasonWithSingleCallDecodesNormally() throws {
        let decoder = ToolCallCandidateDecoder(contentFallbackEnabled: true)
        let content = #"{"device":"window","action_primitive":"power_on","slot":{"position":"主驾"},"value":{"ref":"ZERO","direct":"+","offset":"100","type":"PERCENT"},"state_revision":0}"#
        let input = ToolCallDecodeInput(content: content, finishReason: .stop, toolCallCount: 1)

        let frame = try decoder.decode(input)
        XCTAssertEqual(frame.device, "window")
        XCTAssertEqual(frame.actionPrimitive, "power_on")
    }

    func testDecodeInputDefaultsKeepBackwardCompatibleStringPath() throws {
        // content-only 入口仍可用（默认 finishReason=.stop, toolCallCount=1），保证旧调用不破。
        let decoder = ToolCallCandidateDecoder(contentFallbackEnabled: true)
        let content = #"{"device":"window","action_primitive":"power_on"}"#
        let frame = try decoder.decode(ToolCallDecodeInput(content: content))
        XCTAssertEqual(frame.device, "window")
    }
}

import XCTest
@testable import MAformacCore

/// COR-4: NO_TOOL protocol — legitimate zero-tool vs rejection.
///
/// A stop completion with zero declared tool calls is legitimate only when it
/// carries a non-empty source, empty content, and a non-empty stop reason.
/// Ordinary content and tool-call-shaped content are rejected rather than
/// being silently treated as no-action.
///
/// Bare empty completions, malformed JSON, and tool_calls+0 MUST throw.
final class Cor4NoToolTests: XCTestCase {

    // MARK: - Legitimate no-action

    func testOrdinaryContentWithZeroCallsFailsClosed() {
        let envelope = DDomainCompletionEnvelope(
            content: "The answer is 42.",
            finishReason: "stop",
            stopReason: "",
            toolCallCount: 0,
            source: "local_model"
        )
        assertRejected(envelope, .unsupportedFinishReason("stop"))
    }

    func testLegitimateNoActionWithStopReasonReturnsTypedPlan() throws {
        let envelope = DDomainCompletionEnvelope(
            content: "",
            finishReason: "stop",
            stopReason: "end_turn",
            toolCallCount: 0,
            source: "local_model"
        )
        let result = try DDomainToolCallParser.parse(envelope, policy: .exactlyOne)
        XCTAssertEqual(result, .noAction(NoActionFrame(reason: "end_turn")))
    }

    // MARK: - Bare empty → rejection

    func testBareEmptyContentThrows() {
        let envelope = DDomainCompletionEnvelope(
            content: "",
            finishReason: "stop",
            stopReason: "",
            toolCallCount: 0,
            source: "local_model"
        )
        assertRejected(envelope, .unsupportedFinishReason("stop"))
    }

    // MARK: - Bad JSON → rejection

    func testBadJSONBodyThrows() {
        let envelope = DDomainCompletionEnvelope(
            content: #"<tool_call>{"name":}</tool_call>"#,
            finishReason: "tool_calls",
            stopReason: "end_turn",
            toolCallCount: 1,
            source: "local_model"
        )
        assertRejected(envelope, .invalidToolCallJSON(index: 0))
    }

    // MARK: - tool_calls + 0 count → rejection (contradiction)

    func testToolCallsFinishReasonWithZeroCountThrows() {
        let envelope = DDomainCompletionEnvelope(
            content: "",
            finishReason: "tool_calls",
            stopReason: "end_turn",
            toolCallCount: 0,
            source: "local_model"
        )
        assertRejected(envelope, .invalidDeclaredToolCallCount(0))
    }

    func testToolCallsFinishReasonWithZeroCountAndNonEmptyContentThrows() {
        let envelope = DDomainCompletionEnvelope(
            content: "some text without tool tags",
            finishReason: "tool_calls",
            stopReason: "end_turn",
            toolCallCount: 0,
            source: "local_model"
        )
        assertRejected(envelope, .invalidDeclaredToolCallCount(0))
    }

    // MARK: - Missing source → still rejects

    func testLegitimateNoActionMissingSourceThrows() {
        let envelope = DDomainCompletionEnvelope(
            content: "",
            finishReason: "stop",
            stopReason: "end_turn",
            toolCallCount: 0,
            source: ""
        )
        assertRejected(envelope, .missingSource)
    }

    // MARK: - Missing stopReason → still rejects (finishReason check fires first)

    func testLegitimateNoActionMissingStopReasonThrows() {
        let envelope = DDomainCompletionEnvelope(
            content: "",
            finishReason: "stop",
            stopReason: "",
            toolCallCount: 0,
            source: "local_model"
        )
        assertRejected(envelope, .unsupportedFinishReason("stop"))
    }

    // MARK: - Non-empty content with zero count → not legitimate

    func testToolCallShapedContentWithZeroCountThrows() {
        let envelope = DDomainCompletionEnvelope(
            content: #"<tool_call>{"name":}</tool_call>"#,
            finishReason: "stop",
            stopReason: "end_turn",
            toolCallCount: 0,
            source: "local_model"
        )
        assertRejected(envelope, .unsupportedFinishReason("stop"))
    }

    func testOversizedLegitimateNoActionFailsClosed() {
        let envelope = DDomainCompletionEnvelope(
            content: String(repeating: "x", count: DDomainCompletionEnvelope.maximumContentBytes + 1),
            finishReason: "stop",
            stopReason: "",
            toolCallCount: 0,
            source: "local_model"
        )
        assertRejected(envelope, .contentTooLarge)
    }

    func testBackendMapsLegitimateNoActionToAtomicRuntimePlan() async throws {
        let backend = DDomainToolPlanBackend(completionEnvelopeProvider: { _ in
            DDomainCompletionEnvelope(
                content: "",
                finishReason: "stop",
                stopReason: "end_turn",
                toolCallCount: 0,
                source: "local_model"
            )
        })

        let plan = try await backend.generateToolPlan(
            for: ToolPlanRequest(text: "不需要操作", traceID: "trace-no-action")
        )

        XCTAssertEqual(plan.traceID, "trace-no-action")
        XCTAssertEqual(plan.frames, [.noAction(NoActionFrame(reason: "end_turn"))])
        XCTAssertEqual(plan.executionPolicy, .atomic)
        XCTAssertTrue(plan.toolFrames.isEmpty)
    }

    // MARK: - Helpers

    private func assertRejected(
        _ envelope: DDomainCompletionEnvelope,
        _ expected: DDomainCompletionRejection,
        policy: ToolPlanCardinalityPolicy = .exactlyOne,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(try DDomainToolCallParser.parse(envelope, policy: policy), file: file, line: line) { error in
            XCTAssertEqual(error as? DDomainCompletionRejection, expected, file: file, line: line)
        }
    }
}
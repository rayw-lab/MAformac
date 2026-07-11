import XCTest
@testable import MAformacCore

final class DDomainCompletionEnvelopeTests: XCTestCase {
    private let call = #"<tool_call>{"name":"adjust_ac_temperature_to_number","arguments":{"temperature":"26"}}</tool_call>"#

    func testValidEnvelopeParsesOneCall() throws {
        let parsed = try DDomainToolCallParser.parse(envelope(content: call), policy: .exactlyOne)
        XCTAssertEqual(parsed.map(\.name), ["adjust_ac_temperature_to_number"])
    }

    func testMissingSourceFailsClosed() {
        assertRejected(envelope(content: call, source: ""), .missingSource)
    }

    func testUnknownFinishReasonFailsClosed() {
        assertRejected(envelope(content: call, finishReason: "mystery"), .unsupportedFinishReason("mystery"))
    }

    func testMissingStopReasonFailsClosed() {
        assertRejected(envelope(content: call, stopReason: ""), .missingStopReason)
    }

    func testNegativeDeclaredCountFailsClosed() {
        assertRejected(envelope(content: call, toolCallCount: -1), .invalidDeclaredToolCallCount(-1))
    }

    func testCountMismatchFailsClosed() {
        assertRejected(envelope(content: call, toolCallCount: 2), .toolCallCountMismatch(declared: 2, parsed: 1))
    }

    func testExtraTextFailsClosed() {
        assertRejected(envelope(content: "answer: \(call)"), .invalidContentShape)
    }

    func testBareJSONFailsClosed() {
        assertRejected(envelope(content: #"{"name":"adjust_ac_temperature_to_number","arguments":{}}"#), .invalidContentShape)
    }

    func testMalformedTagsFailClosed() {
        assertRejected(envelope(content: call.replacingOccurrences(of: "</tool_call>", with: "")), .invalidContentShape)
    }

    func testInvalidJSONBodyFailsClosed() {
        assertRejected(envelope(content: #"<tool_call>{"name":}</tool_call>"#), .invalidToolCallJSON(index: 0))
    }

    func testOversizedContentFailsClosed() {
        let oversized = String(repeating: " ", count: DDomainCompletionEnvelope.maximumContentBytes + 1)
        assertRejected(envelope(content: oversized, toolCallCount: 0), .contentTooLarge)
    }

    func testExactlyOneRejectsZeroAndTwoCalls() {
        assertRejected(envelope(content: "", toolCallCount: 0), .cardinalityRejected(policy: .exactlyOne, actual: 0))
        assertRejected(envelope(content: call + call, toolCallCount: 2), .cardinalityRejected(policy: .exactlyOne, actual: 2))
    }

    func testBoundedReviewedAcceptsTwoAndRejectsThreeCalls() throws {
        let two = try DDomainToolCallParser.parse(envelope(content: call + call, toolCallCount: 2), policy: .boundedReviewed(maximum: 2))
        XCTAssertEqual(two.count, 2)
        assertRejected(
            envelope(content: call + call + call, toolCallCount: 3),
            .cardinalityRejected(policy: .boundedReviewed(maximum: 2), actual: 3),
            policy: .boundedReviewed(maximum: 2)
        )
    }

    private func envelope(
        content: String,
        finishReason: String = "tool_calls",
        stopReason: String = "end_turn",
        toolCallCount: Int = 1,
        source: String = "local_model"
    ) -> DDomainCompletionEnvelope {
        DDomainCompletionEnvelope(
            content: content,
            finishReason: finishReason,
            stopReason: stopReason,
            toolCallCount: toolCallCount,
            source: source
        )
    }

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

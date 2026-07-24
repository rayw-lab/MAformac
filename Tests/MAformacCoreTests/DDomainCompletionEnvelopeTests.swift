import XCTest
@testable import MAformacCore

final class DDomainCompletionEnvelopeTests: XCTestCase {
    private let call = #"<tool_call>{"name":"adjust_ac_temperature_to_number","arguments":{"temperature":"26"}}</tool_call>"#

    func testValidEnvelopeParsesOneCall() throws {
        let parsed = try DDomainToolCallParser.parse(envelope(content: call), policy: .exactlyOne)
        guard case let .toolCalls(calls) = parsed else {
            return XCTFail("expected typed tool-call plan")
        }
        XCTAssertEqual(calls.map(\.name), ["adjust_ac_temperature_to_number"])
    }

    func testMissingSourceFailsClosed() {
        assertRejected(envelope(content: call, source: ""), .missingSource)
    }

    func testUnknownFinishReasonFailsClosed() {
        assertRejected(envelope(content: call, finishReason: "mystery"), .unsupportedFinishReason("mystery"))
    }

    func testLengthFinishReasonFailsClosedBeforeProjection() {
        assertRejected(envelope(content: call, finishReason: "length"), .unsupportedFinishReason("length"))
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
        assertRejected(envelope(content: "", toolCallCount: 0), .invalidDeclaredToolCallCount(0))
        assertRejected(envelope(content: call + call, toolCallCount: 2), .cardinalityRejected(policy: .exactlyOne, actual: 2))
    }

    func testBoundedReviewedAcceptsTwoAndRejectsThreeCalls() throws {
        let parsed = try DDomainToolCallParser.parse(
            envelope(content: call + call, toolCallCount: 2),
            policy: .boundedReviewed(maximum: 2)
        )
        guard case let .toolCalls(two) = parsed else {
            return XCTFail("expected typed tool-call plan")
        }
        XCTAssertEqual(two.count, 2)
        assertRejected(
            envelope(content: call + call + call, toolCallCount: 3),
            .cardinalityRejected(policy: .boundedReviewed(maximum: 2), actual: 3),
            policy: .boundedReviewed(maximum: 2)
        )
    }

    @MainActor
    func testBoundedReviewedProductionChainPreservesMountedSiblingWhenOtherItemIsUnmounted() async throws {
        let unmounted = #"<tool_call>{"name":"close_fragrance","arguments":{}}</tool_call>"#
        let backend = DDomainToolPlanBackend(
            cardinalityPolicy: .boundedReviewed(maximum: 2),
            completionEnvelopeProvider: { [call] _ in
                DDomainCompletionEnvelope(
                    content: call + unmounted,
                    finishReason: "tool_calls",
                    stopReason: "end_turn",
                    toolCallCount: 2,
                    source: "production-shaped-test"
                )
            }
        )
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let runner = try DemoRuntimeSessionRunner.defaultRunner(
            store: store,
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            modelBackend: backend
        )

        let payload = try await runner.run(text: "空调调到26度并关闭香氛")

        XCTAssertEqual(payload.outcome.result, .partialAcceptPartialRefuse)
        XCTAssertEqual(payload.readbacks.map(\.key), ["ac.power", "ac.temp_setpoint[主驾]"])
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, "26")
        XCTAssertEqual(store.currentRevision, 1)
        XCTAssertEqual(payload.mutationCount, 2)
        XCTAssertTrue(trace.entries.contains { $0.stage == .execute })
        XCTAssertTrue(
            trace.entries.contains {
                $0.message.contains(":refused:") && $0.attributes.finiteReason == .unmountedToolName
            }
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

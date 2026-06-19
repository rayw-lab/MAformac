import XCTest
@testable import MAformacCore

final class TraceLoggerTests: XCTestCase {
    func testTraceEntryCarriesExecutionMetricsMetadata() {
        let logger = InMemoryTraceLogger()

        logger.recordDecode(
            traceID: "trace-1",
            message: "candidate",
            metadata: [
                "toolCalls.count": "1",
                "stopReason": "stop",
                "rawToolCall.count": "1",
                "fallbackCandidate.count": "0",
                "executedToolCall.count": "0"
            ]
        )

        XCTAssertEqual(logger.entries.first?.metadata["toolCalls.count"], "1")
        XCTAssertEqual(logger.entries.first?.metadata["stopReason"], "stop")
        XCTAssertEqual(logger.entries.first?.metadata["rawToolCall.count"], "1")
    }
}

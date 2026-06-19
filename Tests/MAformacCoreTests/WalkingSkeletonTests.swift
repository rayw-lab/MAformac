import XCTest
@testable import MAformacCore

final class WalkingSkeletonTests: XCTestCase {
    @MainActor
    func testOpenAirConditionerFastPathUpdatesReadbackAndTrace() async throws {
        let store = DemoVehicleStateStore()
        let traceLogger = InMemoryTraceLogger()
        let speaker = RecordingSpeechSynthesisEngine()
        let skeleton = DemoWalkingSkeleton(
            store: store,
            guardrail: DemoFastPathGuard(),
            traceLogger: traceLogger,
            speech: speaker
        )

        let readback = try await skeleton.handle(text: "打开空调")

        XCTAssertEqual(readback.key, "hvac.ac")
        XCTAssertEqual(readback.actualValue, "on")
        XCTAssertEqual(store.cell(for: "hvac.ac")?.actualValue, "on")
        XCTAssertEqual(store.cell(for: "hvac.ac")?.visualState, .satisfied)
        XCTAssertEqual(speaker.spokenTexts, ["空调已打开"])
        XCTAssertEqual(traceLogger.entries.map(\.stage), [.decode, .plan, .guard, .execute, .readback])
        XCTAssertEqual(traceLogger.entries.first?.metadata["toolCalls.count"], "1")
        XCTAssertEqual(traceLogger.entries.first?.metadata["rawToolCall.count"], "0")
        XCTAssertEqual(traceLogger.entries.first?.metadata["fallbackCandidate.count"], "0")
        XCTAssertEqual(traceLogger.entries.first(where: { $0.stage == .execute })?.metadata["executedToolCall.count"], "1")
    }

    @MainActor
    func testRawToolCallCandidateRunsFullContractLayerAndTraceMetrics() async throws {
        let store = DemoVehicleStateStore()
        let traceLogger = InMemoryTraceLogger()
        let speaker = RecordingSpeechSynthesisEngine()
        let skeleton = DemoWalkingSkeleton(
            store: store,
            guardrail: DemoSchemaGuard(),
            traceLogger: traceLogger,
            speech: speaker
        )
        let candidate = ToolCallCandidate(
            toolName: "set_cabin_fan",
            arguments: ["level": .int(2)],
            source: .rawToolCall,
            stopReason: "stop"
        )

        let readback = try await skeleton.handle(candidate: candidate)

        XCTAssertEqual(readback.key, "fan.speed")
        XCTAssertEqual(readback.actualValue, "2")
        XCTAssertEqual(traceLogger.entries.map(\.stage), [.decode, .plan, .guard, .execute, .readback])
        XCTAssertEqual(traceLogger.entries.first?.metadata["toolCalls.count"], "1")
        XCTAssertEqual(traceLogger.entries.first?.metadata["stopReason"], "stop")
        XCTAssertEqual(traceLogger.entries.first?.metadata["rawToolCall.count"], "1")
        XCTAssertEqual(traceLogger.entries.first?.metadata["fallbackCandidate.count"], "0")
    }

    @MainActor
    func testContentFallbackCandidateRunsThroughSameGuardAndTraceMetrics() async throws {
        let store = DemoVehicleStateStore()
        let traceLogger = InMemoryTraceLogger()
        let speaker = RecordingSpeechSynthesisEngine()
        let skeleton = DemoWalkingSkeleton(
            store: store,
            guardrail: DemoSchemaGuard(),
            traceLogger: traceLogger,
            speech: speaker
        )

        let readback = try await skeleton.handle(content: #"{"name":"set_cabin_ac","arguments":{"power":"off"}}"#, stopReason: "stop")

        XCTAssertEqual(readback.key, "hvac.ac")
        XCTAssertEqual(readback.actualValue, "off")
        XCTAssertEqual(traceLogger.entries.first?.metadata["toolCalls.count"], "0")
        XCTAssertEqual(traceLogger.entries.first?.metadata["fallbackCandidate.count"], "1")
        XCTAssertEqual(traceLogger.entries.first?.metadata["rawToolCall.count"], "0")
        XCTAssertEqual(traceLogger.entries.first(where: { $0.stage == .execute })?.metadata["executedToolCall.count"], "1")
    }

    @MainActor
    func testThinkLeakIsTracedAndDoesNotExecute() async {
        let store = DemoVehicleStateStore()
        let traceLogger = InMemoryTraceLogger()
        let speaker = RecordingSpeechSynthesisEngine()
        let skeleton = DemoWalkingSkeleton(
            store: store,
            guardrail: DemoSchemaGuard(),
            traceLogger: traceLogger,
            speech: speaker
        )

        do {
            _ = try await skeleton.handle(content: #"<think>maybe</think>{"name":"set_cabin_ac","arguments":{"power":"on"}}"#, stopReason: "stop")
            XCTFail("think leak should fail before execution")
        } catch {
            XCTAssertEqual(error as? ToolCallDecodeError, .malformed("think_leak"))
        }

        XCTAssertEqual(store.cell(for: "hvac.ac")?.actualValue, "off")
        XCTAssertEqual(traceLogger.entries.map(\.stage), [.decode])
        XCTAssertEqual(traceLogger.entries.first?.metadata["think_leak"], "true")
        XCTAssertEqual(traceLogger.entries.first?.metadata["executedToolCall.count"], "0")
    }
}

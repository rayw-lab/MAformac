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

        XCTAssertEqual(readback.key, "ac.power")
        XCTAssertEqual(readback.actualValue, "on")
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(store.cell(for: "ac.power")?.visualState, .satisfied)
        XCTAssertEqual(speaker.spokenTexts, ["空调已打开"])
        XCTAssertEqual(traceLogger.entries.map(\.stage), [.decode, .plan, .guard, .execute, .readback])
    }
}

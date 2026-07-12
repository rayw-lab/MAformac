import XCTest
@testable import MAformacCore

final class DemoSliceRouteTests: XCTestCase {
    @MainActor
    func testOpenACRunsExactlyOnceOnTheBoundStoreAndProducesReadbackAndTTS() async throws {
        let harness = try Harness()

        let result = try await harness.route.route(text: "打开空调")

        let execution = try XCTUnwrap(result.execution)
        XCTAssertEqual(execution.admission.entry.matrixID, 1)
        XCTAssertEqual(harness.route.runnerCallCount, 1)
        XCTAssertEqual(harness.store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(execution.payload.readbacks.map(\.key), ["ac.power"])
        XCTAssertEqual(execution.payload.readbacks.map(\.spokenText), ["空调已打开"])
        XCTAssertEqual(harness.speech.spokenTexts, ["空调已打开"])
    }

    @MainActor
    func testTemperatureInputCausallyControlsStoreReadbackAndTTS() async throws {
        for value in [22, 26] {
            let harness = try Harness()

            let result = try await harness.route.route(text: "把空调调到\(value)度")

            let execution = try XCTUnwrap(result.execution)
            XCTAssertEqual(execution.admission.entry.matrixID, 4)
            XCTAssertEqual(execution.admission.frame.value.direct, String(value))
            XCTAssertEqual(harness.route.runnerCallCount, 1)
            XCTAssertEqual(harness.store.cell(for: "ac.power")?.actualValue, "on")
            XCTAssertEqual(harness.store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, String(value))
            XCTAssertEqual(execution.payload.readbacks.map(\.key), ["ac.power", "ac.temp_setpoint[主驾]"])
            XCTAssertTrue(execution.payload.readbacks.contains { $0.actualValue == String(value) })
            XCTAssertTrue(harness.speech.spokenTexts.joined().contains(String(value)))
        }
    }

    @MainActor
    func testFourFailClosedClassesNeverCallRunnerOrMutateStore() async throws {
        let cases: [(String, DemoSliceAdmissionRejection)] = [
            ("   ", .blank),
            ("打开车窗", .notInCatalog),
            ("空调调到17度", .valueOutOfRange(actual: 17, allowed: 18 ... 32)),
            ("空调调到33度", .valueOutOfRange(actual: 33, allowed: 18 ... 32)),
            ("空调", .clarifyMissingSlot),
        ]

        for (input, expectedRejection) in cases {
            let harness = try Harness()
            let before = harness.store.cells
            let beforeRevision = harness.store.currentRevision

            let result = try await harness.route.route(text: input)

            XCTAssertEqual(result.rejection, expectedRejection, "input=\(input)")
            XCTAssertNil(result.execution, "input=\(input)")
            XCTAssertEqual(harness.route.runnerCallCount, 0, "input=\(input)")
            XCTAssertEqual(harness.store.currentRevision, beforeRevision, "input=\(input)")
            XCTAssertEqual(harness.store.cells, before, "input=\(input)")
            XCTAssertEqual(harness.speech.spokenTexts, [], "input=\(input)")
        }
    }
}

private extension DemoSliceRouteTests {
    @MainActor
    struct Harness {
        let store: DemoVehicleStateStore
        let speech: RecordingSpeechSynthesisEngine
        let route: DemoSliceRoute

        init() throws {
            let store = DemoVehicleStateStore()
            let speech = RecordingSpeechSynthesisEngine()
            self.store = store
            self.speech = speech
            self.route = try DemoSliceRoute(
                store: store,
                traceLogger: InMemoryTraceLogger(),
                speech: speech
            )
        }
    }
}

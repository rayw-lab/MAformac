import XCTest
@testable import MAformacCore

final class W20ARuntimeProjectionTests: XCTestCase {
    @MainActor
    func testHallucinatedDirectionFallsBackToDefaultScope() async throws {
        let store = DemoVehicleStateStore()
        let runner = try runner(
            store: store,
            completion: toolCall("adjust_ac_temperature_to_number", [
                "temperature": "26",
                "direction": "副驾"
            ])
        )

        let payload = try await runner.run(text: "副驾空调调到26度")

        XCTAssertEqual(store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, "26")
        XCTAssertEqual(store.cell(for: "ac.temp_setpoint[副驾]")?.actualValue, "24")
        XCTAssertTrue(payload.readbacks.contains { $0.key == "ac.temp_setpoint[主驾]" })
        XCTAssertFalse(payload.readbacks.contains { $0.key == "ac.temp_setpoint[副驾]" })
    }

    @MainActor
    func testACTemperatureReadbackAllowsPowerOnSideEffect() async throws {
        let store = DemoVehicleStateStore()
        let runner = try runner(
            store: store,
            completion: toolCall("adjust_ac_temperature_to_number", ["temperature": "24"])
        )

        let payload = try await runner.run(text: "空调调到24度")

        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, "24")
        XCTAssertEqual(payload.readbacks.map(\.key), ["ac.power", "ac.temp_setpoint[主驾]"])
    }

    @MainActor
    func testExcludedToolNameReturnsTypedPresentationSafeFallbackPayload() async throws {
        let store = DemoVehicleStateStore()
        let speech = RecordingSpeechSynthesisEngine()
        let runner = try runner(
            store: store,
            speech: speech,
            completion: toolCall("lock_ac", [:])
        )

        let payload = try await runner.run(text: "锁定空调")

        XCTAssertEqual(payload.outcome.result, .refusalNoAvailableTool)
        XCTAssertEqual(payload.outcome.reason, RuntimePresentationSafeReasonKind.capabilityNotMounted.rawValue)
        XCTAssertEqual(payload.reconciliation.status, .notApplicable)
        XCTAssertEqual(
            payload.reconciliation.safeReason,
            RuntimePresentationSafeReasonKind.capabilityNotMounted.rawValue
        )
        XCTAssertEqual(payload.readbacks, [])
        XCTAssertEqual(speech.spokenTexts, ["这项空调控制暂未接入演示版，我先不改车内状态。"])
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "off")
        let encoded = String(decoding: try JSONEncoder().encode(payload), as: UTF8.self)
        XCTAssertFalse(encoded.contains("name_rejected"))
        XCTAssertFalse(encoded.contains("lock_ac"))
    }

    @MainActor
    func testTraceKeepsPrivateFiniteReasonWhilePayloadUsesTypedSafeReason() async throws {
        let projectedTrace = InMemoryTraceLogger()
        let projectedRunner = try runner(
            trace: projectedTrace,
            completion: toolCall("adjust_ac_temperature_to_number", [
                "temperature": "26",
                "direction": "副驾"
            ])
        )

        _ = try await projectedRunner.run(text: "副驾空调调到26度")

        let slotProjectedEntry = projectedTrace.entries.first { $0.message == "slot_projected" }
        XCTAssertEqual(slotProjectedEntry?.attributes.slotProjected, true)
        XCTAssertNotNil(slotProjectedEntry?.attributes.rawPayloadHash)

        let failureTrace = InMemoryTraceLogger()
        let failureRunner = try runner(
            trace: failureTrace,
            completion: #"<tool_call>{"name":"lock_ac","arguments":{}}</tool_call>"#
        )

        let failurePayload = try await failureRunner.run(text: "锁定空调")

        let failureEntry = failureTrace.entries.first { $0.message == "unsupported_tool_plan" }
        XCTAssertEqual(failureEntry?.attributes.finiteReason, .nameRejected)
        XCTAssertEqual(failurePayload.outcome.reason, FallbackSafeReasonKind.capabilityNotMounted.rawValue)
        XCTAssertEqual(failurePayload.reconciliation.safeReason, FallbackSafeReasonKind.capabilityNotMounted.rawValue)
        let encoded = String(decoding: try JSONEncoder().encode(failurePayload), as: UTF8.self)
        XCTAssertFalse(encoded.contains("name_rejected"))
    }

    @MainActor
    private func runner(
        store: DemoVehicleStateStore = DemoVehicleStateStore(),
        trace: InMemoryTraceLogger = InMemoryTraceLogger(),
        speech: RecordingSpeechSynthesisEngine = RecordingSpeechSynthesisEngine(),
        completion: String
    ) throws -> DemoRuntimeSessionRunner {
        try DemoRuntimeSessionRunner.defaultRunner(
            store: store,
            traceLogger: trace,
            speech: speech,
            modelBackend: DDomainToolPlanBackend(completionProvider: { _ in completion })
        )
    }

    private func toolCall(_ name: String, _ arguments: [String: String]) -> String {
        let args = arguments
            .map { #""\#($0.key)":"\#($0.value)""# }
            .sorted()
            .joined(separator: ",")
        return #"<tool_call>{"name":"\#(name)","arguments":{\#(args)}}</tool_call>"#
    }
}

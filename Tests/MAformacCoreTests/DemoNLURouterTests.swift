import XCTest
@testable import MAformacCore

final class DemoNLURouterTests: XCTestCase {
    func testRouterTakesFirstBackendFrame() async throws {
        let first = frame(id: "first", device: "ac_temperature")
        let second = frame(id: "second", device: "window")
        let router = DemoNLURouter(backend: FixedPlanBackend(frames: [first, second]))

        let decoded = try await router.decode(text: "调到26度")

        XCTAssertEqual(decoded.id, "first")
        XCTAssertEqual(decoded.device, "ac_temperature")
    }

    func testRouterDoesNotDecodeOrNormalize() async throws {
        let backendFrame = frame(
            id: "backend-owned",
            toolName: "unmounted_backend_only_name",
            device: "backend_device",
            actionPrimitive: "backend_action",
            candidateSource: .contentFallback
        )
        let router = DemoNLURouter(backend: FixedPlanBackend(frames: [backendFrame]))

        let decoded = try await router.decode(text: #"<tool_call>{"name":"adjust_ac_temperature_to_number","arguments":{"temperature":"26"}}</tool_call>"#)

        XCTAssertEqual(decoded, backendFrame)
    }

    func testRouterRejectsEmptyToolPlan() async {
        let router = DemoNLURouter(backend: FixedPlanBackend(frames: []))

        do {
            _ = try await router.decode(text: "调到26度")
            XCTFail("expected noToolPlanFrames")
        } catch {
            XCTAssertEqual(error as? DemoNLURouterError, .noToolPlanFrames)
        }
    }

    private func frame(
        id: String,
        toolName: String = "adjust_ac_temperature_to_number",
        device: String,
        actionPrimitive: String = "adjust_to_number",
        candidateSource: ToolCandidateSource = .modelRouter
    ) -> ToolCallFrame {
        ToolCallFrame(
            id: id,
            traceID: "trace-\(id)",
            agentID: "vehicle-control",
            capabilityID: "cabin.\(device)",
            toolName: toolName,
            device: device,
            actionPrimitive: actionPrimitive,
            value: ContractValue(direct: "26", type: "SPOT"),
            candidateSource: candidateSource
        )
    }
}

private struct FixedPlanBackend: LLMBackend {
    let frames: [ToolCallFrame]

    func load() async throws {}

    func generateToolPlan(for request: ToolPlanRequest) async throws -> [ToolCallFrame] {
        frames
    }

    func streamText(for prompt: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { $0.finish() }
    }

    func cancel() {}
}

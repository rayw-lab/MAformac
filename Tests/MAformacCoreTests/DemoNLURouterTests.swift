import XCTest
@testable import MAformacCore

final class DemoNLURouterTests: XCTestCase {
    func testRouterPreservesAllBackendFramesInOrder() async throws {
        let first = frame(id: "first", device: "ac_temperature")
        let second = frame(id: "second", device: "window")
        let router = DemoNLURouter(backend: FixedPlanBackend(frames: [first, second]))

        let decoded = try await router.decodePlan(text: "调到26度并打开车窗")

        XCTAssertEqual(decoded.frames, [.tool(first), .tool(second)])
        XCTAssertEqual(decoded.executionPolicy, .partial)
    }

    func testSingleFrameDecodeRejectsUncheckedMultiFramePlan() async throws {
        let first = frame(id: "first", device: "ac_temperature")
        let second = frame(id: "second", device: "window")
        let router = DemoNLURouter(backend: FixedPlanBackend(frames: [first, second]))

        do {
            _ = try await router.decode(text: "调到26度")
            XCTFail("expected explicit single-frame cardinality rejection")
        } catch {
            XCTAssertEqual(error as? DemoNLURouterError, .expectedSingleToolPlanFrame(actual: 2))
        }
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
            XCTFail("expected validated RuntimePlan to reject empty frames")
        } catch {
            XCTAssertEqual(error as? RuntimePlanError, .emptyFrames)
        }
    }

    func testRuntimePlanRejectsMixedControlFramesAndSinglePartialPolicy() throws {
        let tool = frame(id: "tool", device: "ac_temperature")

        XCTAssertThrowsError(
            try RuntimePlan(
                traceID: "trace-mixed",
                frames: [.tool(tool), .noAction(NoActionFrame(reason: "end_turn"))],
                executionPolicy: .partial
            )
        ) { error in
            XCTAssertEqual(error as? RuntimePlanError, .controlFrameMustBeSingle)
        }
        XCTAssertThrowsError(
            try RuntimePlan(
                traceID: "trace-single",
                frames: [.tool(tool)],
                executionPolicy: .partial
            )
        ) { error in
            XCTAssertEqual(error as? RuntimePlanError, .singleFrameRequiresAtomic)
        }
    }

    private func frame(
        id: String,
        toolName: String = "adjust_ac_temperature_to_number",
        device: String,
        actionPrimitive: String = "adjust_to_number",
        candidateSource: ToolCandidateSource = .modelRouter
    ) -> ToolCallFrame {
        // GOVERNANCE: bypasses NLU by design (not product behavior)
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

    func generateToolPlan(for request: ToolPlanRequest) async throws -> RuntimePlan {
        try RuntimePlan(
            traceID: request.traceID,
            frames: frames.map(RuntimeFrame.tool),
            executionPolicy: frames.count > 1 ? .partial : .atomic
        )
    }

    func streamText(for prompt: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { $0.finish() }
    }

    func cancel() {}
}

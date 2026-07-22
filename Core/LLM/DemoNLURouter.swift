import Foundation

public enum DemoNLURouterError: Error, Equatable {
    case noToolPlanFrames
    case expectedSingleToolPlanFrame(actual: Int)
}

public struct DemoNLURouter: Sendable {
    private let backend: any LLMBackend

    public init(backend: any LLMBackend) {
        self.backend = backend
    }

    public func decodePlan(text: String) async throws -> RuntimePlan {
        try await backend.generateToolPlan(for: ToolPlanRequest(text: text))
    }

    public func decode(text: String) async throws -> ToolCallFrame {
        let plan = try await decodePlan(text: text)
        guard plan.frames.count == 1, let runtimeFrame = plan.frames.first else {
            throw DemoNLURouterError.expectedSingleToolPlanFrame(actual: plan.frames.count)
        }
        guard case let .tool(frame) = runtimeFrame else {
            throw DemoNLURouterError.noToolPlanFrames
        }
        return frame
    }
}

public struct FastPathDemoToolPlanBackend: LLMBackend {
    public init() {}

    public func load() async throws {}

    public func generateToolPlan(for request: ToolPlanRequest) async throws -> RuntimePlan {
        var frame = try FastPathIntentEngine().decode(request.text)
        frame.traceID = request.traceID
        return try RuntimePlan(
            traceID: request.traceID,
            frames: [.tool(frame)],
            executionPolicy: .atomic
        )
    }

    public func streamText(for prompt: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            continuation.finish()
        }
    }

    public func cancel() {}
}

import Foundation

public enum DemoNLURouterError: Error, Equatable {
    case noToolPlanFrames
}

public struct DemoNLURouter: Sendable {
    private let backend: any LLMBackend

    public init(backend: any LLMBackend) {
        self.backend = backend
    }

    public func decodePlan(text: String) async throws -> [ToolCallFrame] {
        let frames = try await backend.generateToolPlan(for: ToolPlanRequest(text: text))
        guard !frames.isEmpty else {
            throw DemoNLURouterError.noToolPlanFrames
        }
        return frames
    }

    public func decode(text: String) async throws -> ToolCallFrame {
        try await decodePlan(text: text)[0]
    }
}

public struct FastPathDemoToolPlanBackend: LLMBackend {
    public init() {}

    public func load() async throws {}

    public func generateToolPlan(for request: ToolPlanRequest) async throws -> [ToolCallFrame] {
        [try FastPathIntentEngine().decode(request.text)]
    }

    public func streamText(for prompt: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            continuation.finish()
        }
    }

    public func cancel() {}
}

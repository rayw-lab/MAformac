import Foundation

public struct ToolPlanRequest: Sendable, Equatable {
    public var text: String
    public var traceID: String

    public init(text: String, traceID: String = UUID().uuidString) {
        self.text = text
        self.traceID = traceID
    }
}

public protocol LLMBackend: Sendable {
    func load() async throws
    func generateToolPlan(for request: ToolPlanRequest) async throws -> [ToolCallFrame]
    func streamText(for prompt: String) -> AsyncThrowingStream<String, Error>
    func cancel()
}


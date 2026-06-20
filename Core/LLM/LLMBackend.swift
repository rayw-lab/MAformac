import Foundation

public struct ToolPlanRequest: Sendable, Equatable {
    public var text: String
    public var traceID: String

    public init(text: String, traceID: String = UUID().uuidString) {
        self.text = text
        self.traceID = traceID
    }
}

public struct RuntimePrewarmContext: Sendable, Equatable {
    public var reason: String
    public var stateRevision: Int
    public var promptFingerprint: String?

    public init(reason: String, stateRevision: Int, promptFingerprint: String? = nil) {
        self.reason = reason
        self.stateRevision = stateRevision
        self.promptFingerprint = promptFingerprint
    }
}

public protocol LLMBackend: Sendable {
    func load() async throws
    func generateToolPlan(for request: ToolPlanRequest) async throws -> [ToolCallFrame]
    func streamText(for prompt: String) -> AsyncThrowingStream<String, Error>
    func cancel()
}

public protocol RuntimePrewarmCapable: Sendable {
    func prewarm(context: RuntimePrewarmContext) async throws
}

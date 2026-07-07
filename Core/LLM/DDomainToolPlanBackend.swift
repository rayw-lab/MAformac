import Foundation

public struct DDomainToolPlanBackend: LLMBackend {
    public typealias CompletionProvider = @Sendable (ToolPlanRequest) async throws -> String
    public typealias StreamTextProvider = @Sendable (String) -> AsyncThrowingStream<String, Error>

    private let mountedToolNames: Set<String>
    private let irMap: [String: DDomainIRMapEntry]
    private let completionProvider: CompletionProvider
    private let streamTextProvider: StreamTextProvider

    public init(
        mountedToolNames: Set<String> = DDomainMountedToolCatalog.mountedToolNames,
        irMap: [String: DDomainIRMapEntry] = DDomainIRMap.irMapCompiled,
        completionProvider: @escaping CompletionProvider,
        streamTextProvider: @escaping StreamTextProvider = { _ in AsyncThrowingStream { $0.finish() } }
    ) {
        self.mountedToolNames = mountedToolNames
        self.irMap = irMap
        self.completionProvider = completionProvider
        self.streamTextProvider = streamTextProvider
    }

    public func load() async throws {}

    public func generateToolPlan(for request: ToolPlanRequest) async throws -> [ToolCallFrame] {
        let completion = try await completionProvider(request)
        let parsed = try DDomainToolCallParser.parse(completion)
        guard mountedToolNames.contains(parsed.name) else {
            throw DDomainToolPlanFailure.nameRejected(parsed.name)
        }
        let call = C6ToolCall(name: parsed.name, arguments: parsed.arguments)
        let irs = ToolContractNormalizer.normalize(call, irMap: irMap)
        guard !irs.isEmpty else {
            throw DDomainToolPlanFailure.irUnclassified(parsed.name)
        }
        return try irs.map {
            try ToolContractIRFrameBridge.frame(from: $0, traceID: request.traceID, rawCall: call)
        }
    }

    public func streamText(for prompt: String) -> AsyncThrowingStream<String, Error> {
        streamTextProvider(prompt)
    }

    public func cancel() {}
}

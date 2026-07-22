import Foundation

public struct DDomainToolPlanBackend: LLMBackend {
    public typealias CompletionEnvelopeProvider = @Sendable (ToolPlanRequest) async throws -> DDomainCompletionEnvelope
    public typealias StreamTextProvider = @Sendable (String) -> AsyncThrowingStream<String, Error>

    private let mountedToolNames: Set<String>
    private let irMap: [String: DDomainIRMapEntry]
    private let completionEnvelopeProvider: CompletionEnvelopeProvider
    private let cardinalityPolicy: ToolPlanCardinalityPolicy
    private let streamTextProvider: StreamTextProvider

    public init(
        mountedToolNames: Set<String> = DDomainMountedToolCatalog.mountedToolNames,
        irMap: [String: DDomainIRMapEntry] = DDomainIRMap.irMapCompiled,
        cardinalityPolicy: ToolPlanCardinalityPolicy = .exactlyOne,
        completionEnvelopeProvider: @escaping CompletionEnvelopeProvider,
        streamTextProvider: @escaping StreamTextProvider = { _ in AsyncThrowingStream { $0.finish() } }
    ) {
        self.mountedToolNames = mountedToolNames
        self.irMap = irMap
        self.cardinalityPolicy = cardinalityPolicy
        self.completionEnvelopeProvider = completionEnvelopeProvider
        self.streamTextProvider = streamTextProvider
    }

    public func load() async throws {}

    public func generateToolPlan(for request: ToolPlanRequest) async throws -> RuntimePlan {
        let envelope = try await completionEnvelopeProvider(request)
        switch try DDomainToolCallParser.parse(envelope, policy: cardinalityPolicy) {
        case let .noAction(frame):
            return try RuntimePlan(
                traceID: request.traceID,
                frames: [.noAction(frame)],
                executionPolicy: .atomic
            )

        case let .toolCalls(parsedCalls):
            // Ordinary bounded multi-call plans retain per-item refusal semantics.
            // Mount checks are deferred for those plans so the partial executor can
            // preserve accepted siblings while refusing unmounted items.
            let defersMountChecksToPerItemRuntime = parsedCalls.count > 1
            var frames = try parsedCalls.flatMap { parsed in
                guard mountedToolNames.contains(parsed.name) || defersMountChecksToPerItemRuntime else {
                    throw DDomainToolPlanFailure.nameRejected(parsed.name)
                }
                let call = C6ToolCall(name: parsed.name, arguments: parsed.arguments)
                let irs = ToolContractNormalizer.normalize(call, irMap: irMap)
                guard !irs.isEmpty else {
                    throw DDomainToolPlanFailure.irUnclassified(parsed.name)
                }
                return try irs.map {
                    // G2: pass through all IR slots explicitly; bridge fail-closes on silent drop.
                    try ToolContractIRFrameBridge.frame(
                        from: $0,
                        traceID: request.traceID,
                        rawCall: call,
                        projectedSlotKeys: Set($0.slots.keys)
                    )
                }
            }
            let hasExplicitACPowerOff = frames.contains {
                $0.device == "ac" && $0.actionPrimitive == "power_off"
            }
            let hasACTemperatureMutation = frames.contains {
                $0.device == "ac_temperature" && $0.actionPrimitive != "query"
            }
            if hasExplicitACPowerOff && hasACTemperatureMutation {
                frames = frames.map { candidate in
                    var frame = candidate
                    if frame.device == "ac_temperature", frame.actionPrimitive != "query" {
                        frame.doNotAutoPowerOn = true
                    }
                    return frame
                }
            }
            let executionPolicy: DemoRuntimeAtomicityContract =
                hasExplicitACPowerOff && hasACTemperatureMutation
                ? .atomic
                : (parsedCalls.count > 1 ? .partial : .atomic)
            return try RuntimePlan(
                traceID: request.traceID,
                frames: frames.map(RuntimeFrame.tool),
                executionPolicy: executionPolicy
            )
        }
    }

    public func streamText(for prompt: String) -> AsyncThrowingStream<String, Error> {
        streamTextProvider(prompt)
    }

    public func cancel() {}
}

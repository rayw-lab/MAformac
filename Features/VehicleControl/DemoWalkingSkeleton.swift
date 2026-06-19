import Foundation

@MainActor
public final class DemoWalkingSkeleton {
    private let intentEngine: FastPathIntentEngine
    private let actionExecutor: DemoActionExecutor
    private let toolCallDecoder: ToolCallDecoder
    private let store: DemoVehicleStateStore
    private let guardrail: any DemoGuard
    private let traceLogger: any TraceLogger
    private let speech: any SpeechSynthesisEngine

    public init(
        intentEngine: FastPathIntentEngine = FastPathIntentEngine(),
        actionExecutor: DemoActionExecutor = DemoActionExecutor(),
        toolCallDecoder: ToolCallDecoder = ToolCallDecoder(),
        store: DemoVehicleStateStore,
        guardrail: any DemoGuard,
        traceLogger: any TraceLogger,
        speech: any SpeechSynthesisEngine
    ) {
        self.intentEngine = intentEngine
        self.actionExecutor = actionExecutor
        self.toolCallDecoder = toolCallDecoder
        self.store = store
        self.guardrail = guardrail
        self.traceLogger = traceLogger
        self.speech = speech
    }

    @discardableResult
    public func handle(text: String) async throws -> DemoActionReadback {
        let fastPathFrame = try intentEngine.decode(text)
        let candidate = ToolCallCandidate(
            toolName: fastPathFrame.toolName,
            arguments: fastPathFrame.arguments,
            source: .fastPath
        )
        return try await handle(candidate: candidate, traceID: fastPathFrame.traceID, decodeMessage: "fast_path: \(text)")
    }

    @discardableResult
    public func handle(candidate: ToolCallCandidate) async throws -> DemoActionReadback {
        try await handle(candidate: candidate, traceID: UUID().uuidString, decodeMessage: "candidate: \(candidate.toolName)")
    }

    /// Handles raw model content (not a structured tool call).
    ///
    /// Fail-closed: content-fallback candidates are only recorded and traced — they are NOT
    /// executed. Execution requires an explicit `intentConfirmed` route verdict (change7 intent
    /// gate). This prevents schema-valid restraint/OOD inputs (e.g. N016/N017) from reaching
    /// the executor.
    ///
    /// To opt-in to execution (e.g., change6 benchmark), call `handle(candidate:)` directly
    /// after checking `candidate.source == .contentFallback` and applying intent gate logic.
    @discardableResult
    public func handle(content: String, stopReason: String? = nil) async throws -> DemoActionReadback {
        let traceID = UUID().uuidString
        if content.contains("<think>") {
            traceLogger.recordDecode(
                traceID: traceID,
                message: "think_leak",
                metadata: [
                    "think_leak": "true",
                    "toolCalls.count": "0",
                    "rawToolCall.count": "0",
                    "fallbackCandidate.count": "0",
                    "executedToolCall.count": "0",
                    "stopReason": stopReason ?? ""
                ]
            )
            throw ToolCallDecodeError.malformed("think_leak")
        }

        // toolCallDecoder is constructed with contentFallbackEnabled: false (fail-closed default),
        // so contentFallbackCandidate returns nil — no candidate, no execution.
        guard let candidate = try toolCallDecoder.contentFallbackCandidate(from: content, stopReason: stopReason) else {
            traceLogger.recordDecode(
                traceID: traceID,
                message: "no_tool_call",
                metadata: [
                    "toolCalls.count": "0",
                    "rawToolCall.count": "0",
                    "fallbackCandidate.count": "0",
                    "executedToolCall.count": "0",
                    "stopReason": stopReason ?? ""
                ]
            )
            throw ToolCallDecodeError.no_tool_call
        }

        // Candidate detected but not executed: record + trace only.
        // change7 intent gate hook: set intentConfirmed=true on DemoGuardContext before executing.
        traceLogger.recordDecode(
            traceID: traceID,
            message: "content_fallback_candidate_not_executed: \(candidate.toolName)",
            metadata: [
                "toolCalls.count": "0",
                "rawToolCall.count": "0",
                "fallbackCandidate.count": "1",
                "executedToolCall.count": "0",
                "stopReason": stopReason ?? ""
            ]
        )
        throw ToolCallDecodeError.no_tool_call
    }

    @discardableResult
    private func handle(
        candidate: ToolCallCandidate,
        traceID: String,
        decodeMessage: String
    ) async throws -> DemoActionReadback {
        let frame = try toolCallDecoder.decode(candidate, traceID: traceID)
        traceLogger.recordDecode(
            traceID: frame.traceID,
            message: decodeMessage,
            metadata: decodeMetadata(for: candidate)
        )
        traceLogger.recordPlan(traceID: frame.traceID, message: "\(frame.capabilityID) -> \(frame.arguments)")

        switch guardrail.evaluate(frame) {
        case .allow(let reason):
            traceLogger.recordGuard(traceID: frame.traceID, message: reason, metadata: ["executedToolCall.count": "0"])
        case .deny(let reason):
            traceLogger.recordGuard(traceID: frame.traceID, message: reason, metadata: ["executedToolCall.count": "0"])
            throw DemoActionError.guardDenied(reason)
        }

        let readback = try actionExecutor.applyMockTransition(frame, store: store)
        traceLogger.recordExecute(
            traceID: frame.traceID,
            message: "\(readback.key)=\(readback.actualValue)",
            metadata: ["executedToolCall.count": "1"]
        )
        traceLogger.recordReadback(traceID: frame.traceID, message: readback.spokenText)
        speech.speak(readback.spokenText)
        return readback
    }

    private func decodeMetadata(for candidate: ToolCallCandidate) -> [String: String] {
        [
            "toolCalls.count": candidate.source == .contentFallback ? "0" : "1",
            "stopReason": candidate.stopReason?.rawValue ?? "",
            "rawToolCall.count": candidate.source == .rawToolCall ? "1" : "0",
            "fallbackCandidate.count": candidate.source == .contentFallback ? "1" : "0",
            "executedToolCall.count": "0"
        ]
    }
}

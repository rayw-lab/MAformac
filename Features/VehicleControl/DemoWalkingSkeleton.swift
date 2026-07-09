import Foundation

@MainActor
public final class DemoWalkingSkeleton {
    private let intentEngine: FastPathIntentEngine
    private let actionExecutor: DemoActionExecutor
    private let store: DemoVehicleStateStore
    private let guardrail: any DemoGuard
    private let traceLogger: any TraceLogger
    private let speech: any SpeechSynthesisEngine

    public init(
        intentEngine: FastPathIntentEngine = FastPathIntentEngine(),
        actionExecutor: DemoActionExecutor = DemoActionExecutor(),
        store: DemoVehicleStateStore,
        guardrail: any DemoGuard,
        traceLogger: any TraceLogger,
        speech: any SpeechSynthesisEngine
    ) {
        self.intentEngine = intentEngine
        self.actionExecutor = actionExecutor
        self.store = store
        self.guardrail = guardrail
        self.traceLogger = traceLogger
        self.speech = speech
    }

    @discardableResult
    public func handle(text: String) async throws -> DemoActionReadback {
        let frame = try intentEngine.decode(text)
        traceLogger.recordDecode(traceID: frame.traceID, message: "fast_path: \(text)")
        traceLogger.recordPlan(traceID: frame.traceID, message: "\(frame.capabilityID) -> \(frame.arguments)")

        switch guardrail.evaluate(frame) {
        case .allow(let reason):
            traceLogger.recordGuard(traceID: frame.traceID, message: reason)
        case .deny(let reason):
            traceLogger.recordGuard(traceID: frame.traceID, message: reason)
            throw DemoActionError.guardDenied(reason)
        }

        let readback = try actionExecutor.applyMockTransition(frame, store: store)
        traceLogger.recordExecute(traceID: frame.traceID, message: "\(readback.key)=\(readback.actualValue)")
        traceLogger.recordReadback(traceID: frame.traceID, message: readback.spokenText)
        _ = speech.speak(readback.spokenText)
        return readback
    }
}

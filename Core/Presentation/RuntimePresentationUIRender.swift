import Foundation

/// G5 knife4: App/ContentView only renders. Dialogue / resultKind / orb / voice
/// authority stays on `RuntimePresentationPayload` (+ Core matrix fallback).
enum RuntimePresentationUIRender {
    /// Prefer payload `readbacks.spokenText`; empty → matrix dialog for `outcome.result`.
    static func dialogueText(from payload: RuntimePresentationPayload) -> String {
        let spoken = payload.readbacks
            .map(\.spokenText)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        if !spoken.isEmpty {
            return spoken.joined(separator: "；")
        }
        return DemoRuntimeResultPresentationMatrix.entry(for: resultKind(from: payload)).dialogText
    }

    static func resultKind(from payload: RuntimePresentationPayload) -> DemoRuntimeResultKind {
        payload.outcome.result.stageResultKind
    }
}

extension DemoRuntimeResult {
    /// Exhaustive payload → stage kind projection (interrupted folds to cancelled).
    var stageResultKind: DemoRuntimeResultKind {
        switch self {
        case .acceptedToolCall: return .acceptedToolCall
        case .noAction: return .noAction
        case .clarifyMissingSlot: return .clarifyMissingSlot
        case .refusalNoAvailableTool: return .refusalNoAvailableTool
        case .refusalSafetyOrPolicy: return .refusalSafetyOrPolicy
        case .alreadyStateNoop: return .alreadyStateNoop
        case .partialAcceptPartialRefuse: return .partialAcceptPartialRefuse
        case .runtimeError: return .runtimeError
        case .cancelled, .interrupted: return .cancelled
        case .stateQuery: return .stateQuery
        case .capabilityQuery: return .capabilityQuery
        case .refusalContractViolation: return .refusalContractViolation
        }
    }
}

/// Admission rejection → presentation payload (copy lives in Core, not App).
enum DemoSliceAdmissionRejectionPresentation {
    static func payload(
        for rejection: DemoSliceAdmissionRejection,
        cards: [DemoVehicleStateCell],
        revision: Int,
        traceID: String = UUID().uuidString
    ) -> RuntimePresentationPayload {
        let result: DemoRuntimeResult
        let spoken: String
        let reason: String
        switch rejection {
        case .blank:
            result = .clarifyMissingSlot
            spoken = "请输入车控指令"
            reason = "blank"
        case let .valueOutOfRange(_, allowed):
            result = .clarifyMissingSlot
            spoken = "空调温度支持\(allowed.lowerBound)到\(allowed.upperBound)度，请重新输入"
            reason = "value_out_of_range"
        case .clarifyMissingSlot:
            result = .clarifyMissingSlot
            spoken = "请告诉我空调要打开，还是调到多少度"
            reason = "clarify_missing_slot"
        case .notInCatalog:
            result = .refusalNoAvailableTool
            spoken = DemoRuntimeResultPresentationMatrix.entry(for: .refusalNoAvailableTool).dialogText
            reason = "not_in_catalog"
        case .conjunctionOrMultiIntent:
            result = .refusalNoAvailableTool
            spoken = DemoRuntimeResultPresentationMatrix.entry(for: .refusalNoAvailableTool).dialogText
            reason = "conjunction_or_multi_intent"
        case .cancel:
            result = .cancelled
            spoken = DemoRuntimeResultPresentationMatrix.entry(for: .cancelled).dialogText
            reason = "user_cancelled"
        }

        let readback = DemoActionReadback(
            key: "presentation.admission_rejection",
            actualValue: reason,
            revision: revision,
            spokenText: spoken
        )
        let snapshot = PresentationSnapshot(
            traceID: traceID,
            runtimeOutcome: DemoRuntimeOutcome(result: result, reason: reason),
            cards: cards,
            dialogText: spoken,
            readbacks: [readback],
            voiceState: .idle,
            orbState: .think,
            mutationCount: 0,
            proofClass: .localUnit,
            isTerminal: true
        )
        return RuntimePresentationPayload(
            snapshot: snapshot,
            turnID: traceID,
            eventID: "\(traceID):admission-rejection:\(reason)",
            reconciliation: PresentationReconciliation(
                status: .notApplicable,
                safeReason: reason
            )
        )
    }
}

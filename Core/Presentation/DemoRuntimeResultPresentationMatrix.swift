import Foundation

enum PresentationMotionKind: String, CaseIterable, Equatable, Sendable {
    case stateCommit
    case clarificationPulse
    case refusalShake
    case safetyPulse
    case steadyAcknowledge
    case staticError
    case cancellationFade
    case partialResult
}

struct DemoRuntimeResultPresentationEntry: Equatable, Sendable {
    let resultKind: DemoRuntimeResultKind
    let visualState: DemoVisualState
    let dialogText: String
    let motionKind: PresentationMotionKind
    let ttsState: PresentationVoiceState
    let proofClass: StagePresentationProofClass
}

enum RuntimePresentationErrorClass: String, CaseIterable, Equatable, Sendable {
    case unsupported
    case unmounted
    case safety
    case clarify
    case crash
    case noMatch = "no_match"

    var t5Fault: T5RuntimePresentationFault {
        switch self {
        case .unsupported: return .unsupported
        case .unmounted: return .unmounted
        case .safety: return .safetyRefusal(cardKey: "__matrix_related_card__")
        case .clarify: return .clarify
        case .crash: return .crash
        case .noMatch: return .noMatch
        }
    }
}

struct RuntimePresentationErrorEntry: Equatable, Sendable {
    var errorClass: RuntimePresentationErrorClass
    var resultKind: DemoRuntimeResultKind
    var visualState: DemoVisualState
    var dialogText: String
    var motionKind: PresentationMotionKind
    var receiptKind: String
}

enum DemoRuntimeResultPresentationMatrix {
    static var allEntries: [DemoRuntimeResultPresentationEntry] {
        DemoRuntimeResultKind.allCases.map { entry(for: $0) }
    }

    static var allErrorEntries: [RuntimePresentationErrorEntry] {
        RuntimePresentationErrorClass.allCases.map { errorEntry(for: $0) }
    }

    static func errorEntry(for errorClass: RuntimePresentationErrorClass) -> RuntimePresentationErrorEntry {
        let t5Row = T5RuntimeErrorVisualMapper.map(errorClass.t5Fault)
        switch errorClass {
        case .unsupported:
            return RuntimePresentationErrorEntry(
                errorClass: errorClass,
                resultKind: resultKind(for: t5Row),
                visualState: t5Row.visualState,
                dialogText: "这个功能当前演示环境暂不支持",
                motionKind: motionKind(for: t5Row),
                receiptKind: t5Row.receiptKind
            )
        case .unmounted:
            return RuntimePresentationErrorEntry(
                errorClass: errorClass,
                resultKind: resultKind(for: t5Row),
                visualState: t5Row.visualState,
                dialogText: "这个功能当前还没有挂载到演示车控",
                motionKind: motionKind(for: t5Row),
                receiptKind: t5Row.receiptKind
            )
        case .safety:
            return RuntimePresentationErrorEntry(
                errorClass: errorClass,
                resultKind: resultKind(for: t5Row),
                visualState: t5Row.visualState,
                dialogText: "为了安全，当前状态下不能这样操作",
                motionKind: motionKind(for: t5Row),
                receiptKind: t5Row.receiptKind
            )
        case .clarify:
            return RuntimePresentationErrorEntry(
                errorClass: errorClass,
                resultKind: resultKind(for: t5Row),
                visualState: t5Row.visualState,
                dialogText: "需要确认具体位置后我再执行",
                motionKind: motionKind(for: t5Row),
                receiptKind: t5Row.receiptKind
            )
        case .crash:
            return RuntimePresentationErrorEntry(
                errorClass: errorClass,
                resultKind: resultKind(for: t5Row),
                visualState: t5Row.visualState,
                dialogText: "刚才处理失败，请重试",
                motionKind: motionKind(for: t5Row),
                receiptKind: t5Row.receiptKind
            )
        case .noMatch:
            return RuntimePresentationErrorEntry(
                errorClass: errorClass,
                resultKind: resultKind(for: t5Row),
                visualState: t5Row.visualState,
                dialogText: "这个我先记下来，稍后帮您处理",
                motionKind: motionKind(for: t5Row),
                receiptKind: t5Row.receiptKind
            )
        }
    }

    private static func resultKind(for row: T5ErrorVisualReceiptRow) -> DemoRuntimeResultKind {
        switch row.scope {
        case .globalRetryableCrash:
            return .runtimeError
        case .unsupportedLocked:
            return .refusalNoAvailableTool
        case .clarify:
            return .clarifyMissingSlot
        case .relatedCardOnly:
            return .refusalSafetyOrPolicy
        case .ttsDegraded:
            return .partialAcceptPartialRefuse
        }
    }

    private static func motionKind(for row: T5ErrorVisualReceiptRow) -> PresentationMotionKind {
        switch row.scope {
        case .globalRetryableCrash:
            return .staticError
        case .unsupportedLocked:
            return .refusalShake
        case .clarify:
            return .clarificationPulse
        case .relatedCardOnly:
            return .safetyPulse
        case .ttsDegraded:
            return .partialResult
        }
    }

    static func entry(for kind: DemoRuntimeResultKind) -> DemoRuntimeResultPresentationEntry {
        switch kind {
        case .acceptedToolCall:
            return DemoRuntimeResultPresentationEntry(
                resultKind: kind,
                visualState: .satisfied,
                dialogText: "已完成",
                motionKind: .stateCommit,
                ttsState: .speaking,
                proofClass: .localMock
            )
        case .clarifyMissingSlot:
            return DemoRuntimeResultPresentationEntry(
                resultKind: kind,
                visualState: .blocked_with_alternative,
                dialogText: "需要确认具体位置后我再执行",
                motionKind: .clarificationPulse,
                ttsState: .speaking,
                proofClass: .localMock
            )
        case .refusalNoAvailableTool:
            return DemoRuntimeResultPresentationEntry(
                resultKind: kind,
                visualState: .blocked_hard,
                dialogText: "这个功能当前演示环境暂不支持",
                motionKind: .refusalShake,
                ttsState: .speaking,
                proofClass: .localMock
            )
        case .refusalSafetyOrPolicy:
            return DemoRuntimeResultPresentationEntry(
                resultKind: kind,
                visualState: .unsafe,
                dialogText: "为了安全，当前状态下不能这样操作",
                motionKind: .safetyPulse,
                ttsState: .speaking,
                proofClass: .localMock
            )
        case .alreadyStateNoop:
            return DemoRuntimeResultPresentationEntry(
                resultKind: kind,
                visualState: .satisfied,
                dialogText: "已经是这个状态了",
                motionKind: .steadyAcknowledge,
                ttsState: .speaking,
                proofClass: .localMock
            )
        case .runtimeError:
            return DemoRuntimeResultPresentationEntry(
                resultKind: kind,
                visualState: .unknown,
                dialogText: "刚才处理失败，请重试",
                motionKind: .staticError,
                ttsState: .speaking,
                proofClass: .localMock
            )
        case .cancelled:
            return DemoRuntimeResultPresentationEntry(
                resultKind: kind,
                visualState: .normal,
                dialogText: "已取消",
                motionKind: .cancellationFade,
                ttsState: .speaking,
                proofClass: .localMock
            )
        case .partialAcceptPartialRefuse:
            return DemoRuntimeResultPresentationEntry(
                resultKind: kind,
                visualState: .blocked_with_alternative,
                dialogText: "已完成可执行部分，其余部分暂不能执行",
                motionKind: .partialResult,
                ttsState: .speaking,
                proofClass: .localMock
            )
        }
    }
}

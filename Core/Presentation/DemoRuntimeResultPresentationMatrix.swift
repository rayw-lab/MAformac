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

enum DemoRuntimeResultPresentationMatrix {
    static var allEntries: [DemoRuntimeResultPresentationEntry] {
        DemoRuntimeResultKind.allCases.map { entry(for: $0) }
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

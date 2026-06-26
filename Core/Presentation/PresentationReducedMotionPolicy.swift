import Foundation

enum PresentationReducedMotionFeedback: String, CaseIterable, Codable, Equatable, Sendable {
    case staticState = "static_state"
    case staticThinking = "static_thinking"
    case staticWarning = "static_warning"
    case staticError = "static_error"
}

enum PresentationReducedMotionPolicy {
    static func feedback(for orbState: PresentationOrbState) -> PresentationReducedMotionFeedback {
        switch orbState {
        case .idle, .listen, .speak:
            return .staticState
        case .think:
            return .staticThinking
        }
    }

    static func feedback(for motionKind: PresentationMotionKind) -> PresentationReducedMotionFeedback {
        switch motionKind {
        case .stateCommit, .steadyAcknowledge, .cancellationFade:
            return .staticState
        case .clarificationPulse, .partialResult:
            return .staticWarning
        case .refusalShake, .safetyPulse, .staticError:
            return .staticError
        }
    }

    static func allowsContinuousAnimation(reduceMotion: Bool) -> Bool {
        !reduceMotion
    }

    static func allowsParticles(reduceMotion: Bool) -> Bool {
        !reduceMotion
    }
}

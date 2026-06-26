import Foundation

enum PresentationInteractionSource: String, CaseIterable, Equatable, Sendable {
    case userTouch = "user_touch"
    case mock
    case forceState = "force_state"
    case voice
    case snapshotRefresh = "snapshot_refresh"
}

enum PresentationHapticIntent: String, CaseIterable, Equatable, Sendable {
    case none
    case selection
    case success
    case impactSoft = "impact_soft"
}

enum PresentationHapticPlatform: String, CaseIterable, Equatable, Sendable {
    case iOS
    case macOS
}

enum PresentationHapticPolicy {
    static func intent(
        for interactionSource: PresentationInteractionSource,
        visualState: DemoVisualState,
        platform: PresentationHapticPlatform
    ) -> PresentationHapticIntent {
        guard platform == .iOS else { return .none }
        guard interactionSource == .userTouch else { return .none }

        switch visualState {
        case .normal, .changing:
            return .selection
        case .satisfied:
            return .success
        case .blocked_with_alternative, .blocked_hard, .unsafe, .unknown:
            return .impactSoft
        }
    }
}

import Foundation

/// App-owned containment composition. It deliberately has no runner/default-production binding.
@MainActor
final class FrontstageRuntimeComposition {
    let session: FrontstageVoiceSession
    private(set) var currentTurnID: String?

    init(session: FrontstageVoiceSession = FrontstageVoiceSession()) {
        self.session = session
    }

    func markCurrent(_ turn: FrontstageVoiceTurn) {
        currentTurnID = turn.turnID
    }

    func isCurrentTurn(_ turn: FrontstageVoiceTurn) -> Bool {
        currentTurnID == turn.turnID
    }
}

import Foundation

/// Stable deny-first boundary for customer-frontstage voice submissions.
///
/// This type intentionally does not know about tool frames, planners, runners, or state stores.
/// Positive admission remains blocked on the T03/T04 interface cut.
public final class FrontstageVoiceSession {
    public let sessionID: String
    private var latestSequence = 0

    public init(sessionID: String = UUID().uuidString.lowercased()) {
        precondition(!sessionID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        self.sessionID = sessionID
    }

    public func submitContainment(utterance: String) -> FrontstageVoiceTurn {
        latestSequence += 1
        return FrontstageVoiceTurn(
            sessionID: sessionID,
            sequence: latestSequence,
            turnID: UUID().uuidString.lowercased(),
            eventID: UUID().uuidString.lowercased(),
            utterance: utterance.trimmingCharacters(in: .whitespacesAndNewlines),
            outcome: DemoRuntimeOutcome(
                result: .refusalNoAvailableTool,
                reason: "not_available_in_demo"
            ),
            proofClass: .localUnit,
            stateMutation: false,
            readbacks: []
        )
    }
}

public struct FrontstageVoiceTurn: Equatable, Sendable {
    public let sessionID: String
    public let sequence: Int
    public let turnID: String
    public let eventID: String
    public let utterance: String
    public let outcome: DemoRuntimeOutcome
    public let proofClass: PresentationProofClass
    public let stateMutation: Bool
    public let readbacks: [DemoActionReadback]

    public init(
        sessionID: String,
        sequence: Int,
        turnID: String,
        eventID: String,
        utterance: String,
        outcome: DemoRuntimeOutcome,
        proofClass: PresentationProofClass,
        stateMutation: Bool,
        readbacks: [DemoActionReadback]
    ) {
        self.sessionID = sessionID
        self.sequence = sequence
        self.turnID = turnID
        self.eventID = eventID
        self.utterance = utterance
        self.outcome = outcome
        self.proofClass = proofClass
        self.stateMutation = stateMutation
        self.readbacks = readbacks
    }
}

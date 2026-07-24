import Foundation

/// Typed fail-closed errors for frontstage voice session issuance.
public enum FrontstageVoiceSessionError: Error, Equatable, Sendable {
    /// `latestSequence` cannot advance further (`addingReportingOverflow` reported overflow).
    case sequenceExhausted
}

/// Stable deny-first boundary for customer-frontstage voice submissions.
///
/// This type intentionally does not know about tool frames, planners, runners, or state stores.
/// Positive admission remains blocked on the T03/T04 interface cut.
public final class FrontstageVoiceSession {
    public let sessionID: String
    private var latestSequence: Int

    public init(
        sessionID: String = UUID().uuidString.lowercased(),
        startingSequence: Int = 0
    ) {
        precondition(!sessionID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        precondition(startingSequence >= 0)
        self.sessionID = sessionID
        self.latestSequence = startingSequence
    }

    public func submitContainment(utterance: String) throws -> FrontstageVoiceTurn {
        let request = try issueIngressRequest(.init(source: .voiceTranscript, rawText: utterance))
        return makeContainmentTurn(request: request, utterance: utterance)
    }

    public func issueIngressRequest(_ input: FrontstageIngressInput) throws -> FrontstageIngressRequest {
        let (next, overflowed) = latestSequence.addingReportingOverflow(1)
        guard !overflowed else {
            throw FrontstageVoiceSessionError.sequenceExhausted
        }
        latestSequence = next
        return FrontstageIngressRequest(
            source: input.source,
            rawText: input.rawText,
            sessionID: sessionID,
            sequence: latestSequence,
            turnID: UUID().uuidString.lowercased(),
            eventID: UUID().uuidString.lowercased()
        )
    }

    public func makeContainmentTurn(request: FrontstageIngressRequest, utterance: String) -> FrontstageVoiceTurn {
        precondition(request.sessionID == sessionID)
        return FrontstageVoiceTurn(
            sessionID: sessionID,
            sequence: request.sequence,
            turnID: request.turnID,
            eventID: request.eventID,
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

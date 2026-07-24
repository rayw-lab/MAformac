import Foundation
@testable import MAformacCore

// MARK: - K1 schema-core fixtures (F01, F02, F03, F09, F10, F11 only)
//
// Immutable inputs + expected outcomes. No shared static mutable lifecycle state.
// Production types live in Core/Lifecycle/* (GREEN); this file only names fixture IDs and tables.
//
// Parent/child non-claim: K1 schema-core has no child registry / cancel fan-out / fence-join APIs.
// These fixtures exercise parent session lifecycle only.

enum SessionLifecycleFixtures {
    // MARK: Shared immutable identity material (value constants, not mutable state)

    static let ownerA = SessionOwnerAuthority(rawValue: "k1.owner.a")
    static let ownerB = SessionOwnerAuthority(rawValue: "k1.owner.b")

    static let sessionAlpha = SessionID(rawValue: "session-alpha")
    static let sessionBeta = SessionID(rawValue: "session-beta")

    static let generation1 = SessionGeneration(value: 1)
    static let generation2 = SessionGeneration(value: 2)
    static let generationUnknown = SessionGeneration(value: 99)

    // MARK: F01 — wrong authority → rejected; snapshot / generation / revision unchanged

    enum F01 {
        static let id = "F01"
        static let liveOwner = SessionLifecycleFixtures.ownerA
        static let nonOwner = SessionLifecycleFixtures.ownerB
        static let sessionID = SessionLifecycleFixtures.sessionAlpha
        static let generation = SessionLifecycleFixtures.generation1

        static func startEvent() -> SessionLifecycleEvent {
            .start(sessionID: sessionID, generation: generation)
        }
    }

    // MARK: F02 — illegal transitions (ready→terminal, recoveryReady, new-generation) → zero mutation

    enum F02 {
        static let id = "F02"
        static let owner = SessionLifecycleFixtures.ownerA
        static let sessionID = SessionLifecycleFixtures.sessionAlpha
        static let generation = SessionLifecycleFixtures.generation1

        /// ready → terminal is not an executable K1 edge (only ready→active, active→terminal).
        static func readyToTerminalEvent() -> SessionLifecycleEvent {
            .terminal(
                sessionID: sessionID,
                generation: generation,
                disposition: .cancelled,
                cause: .operatorCancel,
                outcomeClass: .cancelled
            )
        }

        static func recoveryReadyEvent() -> SessionLifecycleEvent {
            .recoveryReady(sessionID: sessionID, generation: generation)
        }

        static func newGenerationEvent() -> SessionLifecycleEvent {
            .newGeneration(sessionID: sessionID, generation: SessionLifecycleFixtures.generation2)
        }
    }

    // MARK: F03 — compound start+cancel batch; order-independent; one commit / one final snapshot

    enum F03 {
        static let id = "F03"
        static let owner = SessionLifecycleFixtures.ownerA
        static let sessionID = SessionLifecycleFixtures.sessionAlpha
        static let generation = SessionLifecycleFixtures.generation1

        static func startEvent() -> SessionLifecycleEvent {
            .start(sessionID: sessionID, generation: generation)
        }

        static func cancelTerminalEvent() -> SessionLifecycleEvent {
            .terminal(
                sessionID: sessionID,
                generation: generation,
                disposition: .cancelled,
                cause: .operatorCancel,
                outcomeClass: .cancelled
            )
        }

        static func batchStartThenCancel() -> [SessionLifecycleEvent] {
            [startEvent(), cancelTerminalEvent()]
        }

        static func batchCancelThenStart() -> [SessionLifecycleEvent] {
            [cancelTerminalEvent(), startEvent()]
        }

        static let expectedState: SessionLifecycleState = .terminal
        static let expectedDisposition: SessionTerminalDisposition = .cancelled
        static let expectedCause: SessionTerminalCause = .operatorCancel
        static let expectedOutcomeClass: SessionLifecycleOutcomeClass = .cancelled
    }

    // MARK: F09 — first cause immutable; later terminal duplicate/rejected

    enum F09 {
        static let id = "F09"
        static let owner = SessionLifecycleFixtures.ownerA
        static let sessionID = SessionLifecycleFixtures.sessionAlpha
        static let generation = SessionLifecycleFixtures.generation1

        static func startEvent() -> SessionLifecycleEvent {
            .start(sessionID: sessionID, generation: generation)
        }

        static func firstTerminalEvent() -> SessionLifecycleEvent {
            .terminal(
                sessionID: sessionID,
                generation: generation,
                disposition: .completed,
                cause: .completedNormally,
                outcomeClass: .accepted
            )
        }

        /// Distinct second cause/disposition that MUST NOT overwrite first settlement.
        static func secondTerminalEvent() -> SessionLifecycleEvent {
            .terminal(
                sessionID: sessionID,
                generation: generation,
                disposition: .cancelled,
                cause: .operatorCancel,
                outcomeClass: .cancelled
            )
        }

        static let firstDisposition: SessionTerminalDisposition = .completed
        static let firstCause: SessionTerminalCause = .completedNormally
    }

    // MARK: F10 — unknown / cross-session / unknown generation → fail-closed, zero mutation

    enum F10 {
        static let id = "F10"
        static let owner = SessionLifecycleFixtures.ownerA
        static let liveSessionID = SessionLifecycleFixtures.sessionAlpha
        static let liveGeneration = SessionLifecycleFixtures.generation1

        static func crossSessionStart() -> SessionLifecycleEvent {
            .start(
                sessionID: SessionLifecycleFixtures.sessionBeta,
                generation: liveGeneration
            )
        }

        static func unknownGenerationStart() -> SessionLifecycleEvent {
            .start(
                sessionID: liveSessionID,
                generation: SessionLifecycleFixtures.generationUnknown
            )
        }

        static func crossSessionTerminal() -> SessionLifecycleEvent {
            .terminal(
                sessionID: SessionLifecycleFixtures.sessionBeta,
                generation: liveGeneration,
                disposition: .cancelled,
                cause: .operatorCancel,
                outcomeClass: .cancelled
            )
        }
    }

    // MARK: F11 — refused / cancelled / unsupported / timeout / failure → non-success facts

    enum F11 {
        static let id = "F11"
        static let owner = SessionLifecycleFixtures.ownerA
        static let sessionID = SessionLifecycleFixtures.sessionAlpha
        static let generation = SessionLifecycleFixtures.generation1

        struct Row: Equatable, Sendable {
            let label: String
            let disposition: SessionTerminalDisposition
            let cause: SessionTerminalCause
            let outcomeClass: SessionLifecycleOutcomeClass
        }

        /// Table of non-success outcome classes only (schema-level; no UI strings).
        static let nonSuccessRows: [Row] = [
            Row(label: "refused", disposition: .refused, cause: .policyRefused, outcomeClass: .refused),
            Row(label: "cancelled", disposition: .cancelled, cause: .operatorCancel, outcomeClass: .cancelled),
            Row(label: "unsupported", disposition: .failed, cause: .unsupportedRequest, outcomeClass: .unsupported),
            Row(label: "timeout", disposition: .failed, cause: .deadlineTimeout, outcomeClass: .timeout),
            Row(label: "failure", disposition: .failed, cause: .internalFailure, outcomeClass: .failure),
        ]

        static func startEvent() -> SessionLifecycleEvent {
            .start(sessionID: sessionID, generation: generation)
        }

        static func terminalEvent(for row: Row) -> SessionLifecycleEvent {
            .terminal(
                sessionID: sessionID,
                generation: generation,
                disposition: row.disposition,
                cause: row.cause,
                outcomeClass: row.outcomeClass
            )
        }
    }
}

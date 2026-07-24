import Foundation

// MARK: - K1 schema-core single-owner lifecycle coordinator
//
// Synchronous final class; no Task/actor/MainActor; no global shared; no UI.
// Executable transitions only: ready→active, active→terminal.
// recoveryReady / newGeneration: reject with zero mutation.
// Batch: canonicalize (start before terminal) → scratch whole-batch → one-shot commit.
// Parent session only: no child registry / fan-out / fence join.

/// Single-owner authoritative parent-session lifecycle state machine (schema-core).
public final class SessionLifecycleCoordinator {
    private let ownerAuthority: SessionOwnerAuthority
    private let liveSessionID: SessionID
    private let liveGeneration: SessionGeneration

    /// Authoritative published snapshot (immutable value; mutated only via controlled apply).
    private var authoritative: SessionLifecycleSnapshot

    /// Current immutable published snapshot.
    public var snapshot: SessionLifecycleSnapshot {
        authoritative
    }

    public init(
        ownerAuthority: SessionOwnerAuthority,
        sessionID: SessionID,
        generation: SessionGeneration
    ) {
        self.ownerAuthority = ownerAuthority
        self.liveSessionID = sessionID
        self.liveGeneration = generation
        self.authoritative = SessionLifecycleSnapshot(
            state: .ready,
            sessionID: sessionID,
            generation: generation,
            revision: 0,
            firstTerminalDisposition: nil,
            firstTerminalCause: nil
        )
    }

    // MARK: - Public apply API (unique single + unique batch; no submit/commit dual)

    /// Apply one lifecycle event under owner authority.
    public func apply(
        _ event: SessionLifecycleEvent,
        authority: SessionOwnerAuthority
    ) -> SessionLifecycleApplyResult {
        guard authority == ownerAuthority else {
            return reject(.wrongAuthority, fact: nil)
        }

        switch event {
        case .recoveryReady:
            return reject(.recoveryNotExecutable, fact: nil)
        case .newGeneration:
            return reject(.newGenerationNotExecutable, fact: nil)
        case .start, .terminal:
            break
        }

        if let identityReason = identityRejection(for: event) {
            return reject(identityReason, fact: nil)
        }

        switch step(on: authoritative, event: event) {
        case .mutated(let next, let fact):
            let committed = withRevision(next, revision: authoritative.revision &+ 1)
            authoritative = committed
            return SessionLifecycleApplyResult(status: .applied, snapshot: committed, fact: fact)
        case .duplicate:
            return SessionLifecycleApplyResult(
                status: .duplicate,
                snapshot: authoritative,
                fact: nil
            )
        case .rejected(let reason):
            return reject(reason, fact: nil)
        }
    }

    /// Apply a compound batch: canonicalize → scratch whole-batch → one-shot commit.
    public func apply(
        batch: [SessionLifecycleEvent],
        authority: SessionOwnerAuthority
    ) -> SessionLifecycleApplyResult {
        guard authority == ownerAuthority else {
            return reject(.wrongAuthority, fact: nil)
        }

        if batch.isEmpty {
            return SessionLifecycleApplyResult(
                status: .applied,
                snapshot: authoritative,
                fact: nil
            )
        }

        let ordered = Self.canonicalize(batch)
        var scratch = authoritative
        var lastFact: SessionLifecycleFact?
        var didMutate = false

        for event in ordered {
            // Non-executable event kinds fail the whole batch.
            switch event {
            case .recoveryReady, .newGeneration:
                return reject(.batchInvalid, fact: nil)
            case .start, .terminal:
                break
            }

            if identityRejection(for: event) != nil {
                return reject(.batchInvalid, fact: nil)
            }

            switch step(on: scratch, event: event) {
            case .mutated(let next, let fact):
                scratch = next
                if let fact {
                    lastFact = fact
                }
                didMutate = true
            case .duplicate:
                // Observed only; no overwrite of first cause/disposition on scratch.
                continue
            case .rejected:
                return reject(.batchInvalid, fact: nil)
            }
        }

        guard didMutate else {
            return SessionLifecycleApplyResult(
                status: .applied,
                snapshot: authoritative,
                fact: nil
            )
        }

        // One-shot authoritative commit: revision increments exactly once from pre-batch baseline.
        let committed = withRevision(scratch, revision: authoritative.revision &+ 1)
        authoritative = committed
        return SessionLifecycleApplyResult(
            status: .applied,
            snapshot: committed,
            fact: lastFact
        )
    }

    // MARK: - Canonical batch order

    /// Fixed total order: start before terminal; relative order within class preserved.
    /// recoveryReady / newGeneration trail (and fail closed during simulation).
    private static func canonicalize(_ events: [SessionLifecycleEvent]) -> [SessionLifecycleEvent] {
        var starts: [SessionLifecycleEvent] = []
        var terminals: [SessionLifecycleEvent] = []
        var others: [SessionLifecycleEvent] = []
        for event in events {
            switch event {
            case .start:
                starts.append(event)
            case .terminal:
                terminals.append(event)
            case .recoveryReady, .newGeneration:
                others.append(event)
            }
        }
        return starts + terminals + others
    }

    // MARK: - Identity

    private func identityRejection(for event: SessionLifecycleEvent) -> SessionLifecycleRejectionReason? {
        let (sid, gen) = Self.eventIdentity(event)
        if sid != liveSessionID {
            return .crossSession
        }
        if gen != liveGeneration {
            return .unknownGeneration
        }
        return nil
    }

    private static func eventIdentity(
        _ event: SessionLifecycleEvent
    ) -> (SessionID, SessionGeneration) {
        switch event {
        case .start(let sessionID, let generation):
            return (sessionID, generation)
        case .terminal(let sessionID, let generation, _, _, _):
            return (sessionID, generation)
        case .recoveryReady(let sessionID, let generation):
            return (sessionID, generation)
        case .newGeneration(let sessionID, let generation):
            return (sessionID, generation)
        }
    }

    // MARK: - Terminal consistency table (fail-closed)

    /// Hard-closed consistent triples only; any other combination is inconsistent.
    private static func isConsistentTerminal(
        disposition: SessionTerminalDisposition,
        cause: SessionTerminalCause,
        outcomeClass: SessionLifecycleOutcomeClass
    ) -> Bool {
        switch (disposition, cause, outcomeClass) {
        case (.completed, .completedNormally, .accepted):
            return true
        case (.refused, .policyRefused, .refused):
            return true
        case (.cancelled, .operatorCancel, .cancelled):
            return true
        case (.failed, .unsupportedRequest, .unsupported):
            return true
        case (.failed, .deadlineTimeout, .timeout):
            return true
        case (.failed, .internalFailure, .failure):
            return true
        default:
            return false
        }
    }

    // MARK: - Pure step on a snapshot (scratch or live)

    private enum StepResult {
        case mutated(SessionLifecycleSnapshot, fact: SessionLifecycleFact?)
        case duplicate
        case rejected(SessionLifecycleRejectionReason)
    }

    private func step(
        on snapshot: SessionLifecycleSnapshot,
        event: SessionLifecycleEvent
    ) -> StepResult {
        switch event {
        case .start:
            guard snapshot.state == .ready else {
                return .rejected(.illegalTransition)
            }
            let next = SessionLifecycleSnapshot(
                state: .active,
                sessionID: snapshot.sessionID,
                generation: snapshot.generation,
                revision: snapshot.revision,
                firstTerminalDisposition: nil,
                firstTerminalCause: nil
            )
            return .mutated(next, fact: nil)

        case .terminal(_, _, let disposition, let cause, let outcomeClass):
            guard Self.isConsistentTerminal(
                disposition: disposition,
                cause: cause,
                outcomeClass: outcomeClass
            ) else {
                return .rejected(.inconsistentTerminalOutcome)
            }

            // First terminal already settled: observe duplicate; never overwrite cause/disposition.
            if snapshot.state == .terminal {
                return .duplicate
            }

            guard snapshot.state == .active else {
                return .rejected(.illegalTransition)
            }

            let next = SessionLifecycleSnapshot(
                state: .terminal,
                sessionID: snapshot.sessionID,
                generation: snapshot.generation,
                revision: snapshot.revision,
                firstTerminalDisposition: disposition,
                firstTerminalCause: cause
            )
            let fact = SessionLifecycleFact(outcomeClass: outcomeClass)
            return .mutated(next, fact: fact)

        case .recoveryReady:
            return .rejected(.recoveryNotExecutable)

        case .newGeneration:
            return .rejected(.newGenerationNotExecutable)
        }
    }

    // MARK: - Helpers

    private func reject(
        _ reason: SessionLifecycleRejectionReason,
        fact: SessionLifecycleFact?
    ) -> SessionLifecycleApplyResult {
        SessionLifecycleApplyResult(
            status: .rejected(reason),
            snapshot: authoritative,
            fact: fact
        )
    }

    private func withRevision(
        _ snapshot: SessionLifecycleSnapshot,
        revision: UInt
    ) -> SessionLifecycleSnapshot {
        SessionLifecycleSnapshot(
            state: snapshot.state,
            sessionID: snapshot.sessionID,
            generation: snapshot.generation,
            revision: revision,
            firstTerminalDisposition: snapshot.firstTerminalDisposition,
            firstTerminalCause: snapshot.firstTerminalCause
        )
    }
}

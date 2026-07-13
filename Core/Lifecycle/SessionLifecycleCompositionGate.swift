import Foundation

// MARK: - K3 composition gate (frontstage parent start→active only)
//
// Private owner authority + single K1 coordinator.
// Executable surface: ensureActive only (ready→start once; active idempotent).
// Non-active non-ready states fail closed via default branch (no terminal/recovery API).

/// Typed fail-closed errors for the frontstage composition gate.
public enum SessionLifecycleCompositionGateError: Error, Equatable {
    case sessionMismatch(expected: SessionID, received: SessionID)
    case activationRejected(SessionLifecycleRejectionReason)
    case unexpectedState(SessionLifecycleState)
}

/// Frontstage composition gate: sole authority for parent ready→active on the
/// production-shaped routeDemoSlice path. App never receives owner token.
@MainActor
public final class SessionLifecycleCompositionGate {
    private let ownerAuthority: SessionOwnerAuthority
    private let boundSessionID: SessionID
    private let boundGeneration: SessionGeneration
    private let coordinator: SessionLifecycleCoordinator

    /// Immutable published snapshot (read-only consumer view).
    public var snapshot: SessionLifecycleSnapshot {
        coordinator.snapshot
    }

    public init(
        sessionID: SessionID,
        generation: SessionGeneration = SessionGeneration(value: 0)
    ) {
        let authority = SessionOwnerAuthority(
            rawValue: "session-lifecycle-composition-gate.\(sessionID.rawValue)"
        )
        self.ownerAuthority = authority
        self.boundSessionID = sessionID
        self.boundGeneration = generation
        self.coordinator = SessionLifecycleCoordinator(
            ownerAuthority: authority,
            sessionID: sessionID,
            generation: generation
        )
    }

    /// Ensure the bound parent session is active for `expectedSessionID`.
    ///
    /// Order:
    /// 1. identity mismatch → throw, zero mutation
    /// 2. ready → apply `.start` once; require applied + active identity match
    /// 3. active → return same snapshot (idempotent; no revision bump)
    /// 4. any other state → unexpectedState (fail-closed)
    public func ensureActive(expectedSessionID: SessionID) throws -> SessionLifecycleSnapshot {
        guard expectedSessionID == boundSessionID else {
            throw SessionLifecycleCompositionGateError.sessionMismatch(
                expected: boundSessionID,
                received: expectedSessionID
            )
        }

        let current = coordinator.snapshot
        switch current.state {
        case .ready:
            let result = coordinator.apply(
                .start(sessionID: boundSessionID, generation: boundGeneration),
                authority: ownerAuthority
            )
            switch result.status {
            case .applied:
                let applied = result.snapshot
                guard applied.state == .active,
                      applied.sessionID == boundSessionID,
                      applied.generation == boundGeneration
                else {
                    throw SessionLifecycleCompositionGateError.unexpectedState(applied.state)
                }
                return applied
            case .rejected(let reason):
                throw SessionLifecycleCompositionGateError.activationRejected(reason)
            case .duplicate:
                throw SessionLifecycleCompositionGateError.unexpectedState(result.snapshot.state)
            }

        case .active:
            return current

        default:
            throw SessionLifecycleCompositionGateError.unexpectedState(current.state)
        }
    }
}

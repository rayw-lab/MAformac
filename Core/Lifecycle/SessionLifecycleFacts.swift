import Foundation

// MARK: - K1 schema-core events, facts, snapshots, apply results
//
// CREATE-only surface. No Coordinator, no owner mutation, no UI/presentation imports.
// Fact classification is fail-closed: only `.accepted` is success; refused/cancelled/
// unsupported/timeout/failure never upgrade to success.

// MARK: Outcome classification (F11)

/// Explicit lifecycle fact outcome classes (schema-level; no UI strings).
public enum SessionLifecycleOutcomeClass: String, Equatable, Hashable, Sendable {
    /// Successful accepted terminal (happy path).
    case accepted
    /// Policy / authority refused.
    case refused
    /// Operator or parent-session cancel disposition.
    case cancelled
    /// Request shape not supported by schema-core executable subset.
    case unsupported
    /// Deadline / timeout class failure.
    case timeout
    /// Internal or unclassified failure.
    case failure
}

// MARK: Events (inputs only; apply semantics live on Coordinator)

/// Parent-session lifecycle events. Values may be constructed by any party;
/// authoritative mutation requires owner authority at apply time (Coordinator).
public enum SessionLifecycleEvent: Equatable, Sendable {
    case start(sessionID: SessionID, generation: SessionGeneration)
    case terminal(
        sessionID: SessionID,
        generation: SessionGeneration,
        disposition: SessionTerminalDisposition,
        cause: SessionTerminalCause,
        outcomeClass: SessionLifecycleOutcomeClass
    )
    /// Named for base observability; K1 must reject apply with zero mutation.
    case recoveryReady(sessionID: SessionID, generation: SessionGeneration)
    /// Named for base recovery path; K1 must reject apply with zero mutation.
    case newGeneration(sessionID: SessionID, generation: SessionGeneration)
}

// MARK: Immutable published fact

/// Schema-only lifecycle fact. `isSuccess` is derived fail-closed from `outcomeClass`.
public struct SessionLifecycleFact: Equatable, Sendable {
    public let outcomeClass: SessionLifecycleOutcomeClass

    public init(outcomeClass: SessionLifecycleOutcomeClass) {
        self.outcomeClass = outcomeClass
    }

    /// Fail-closed success flag: only `.accepted` is success.
    /// refused / cancelled / unsupported / timeout / failure → false.
    public var isSuccess: Bool {
        switch outcomeClass {
        case .accepted:
            return true
        case .refused, .cancelled, .unsupported, .timeout, .failure:
            return false
        }
    }
}

// MARK: Immutable published snapshot

/// Immutable parent-session lifecycle snapshot (published truth).
/// First terminal disposition/cause are optional until first successful terminal write.
public struct SessionLifecycleSnapshot: Equatable, Sendable {
    public let state: SessionLifecycleState
    public let sessionID: SessionID
    public let generation: SessionGeneration
    /// Monotonic revision of authoritative commits (Coordinator bumps on applied mutation).
    public let revision: UInt
    public let firstTerminalDisposition: SessionTerminalDisposition?
    public let firstTerminalCause: SessionTerminalCause?

    public init(
        state: SessionLifecycleState,
        sessionID: SessionID,
        generation: SessionGeneration,
        revision: UInt,
        firstTerminalDisposition: SessionTerminalDisposition? = nil,
        firstTerminalCause: SessionTerminalCause? = nil
    ) {
        self.state = state
        self.sessionID = sessionID
        self.generation = generation
        self.revision = revision
        self.firstTerminalDisposition = firstTerminalDisposition
        self.firstTerminalCause = firstTerminalCause
    }
}

// MARK: Apply result envelope

/// Status of a single-event or batch apply attempt.
public enum SessionLifecycleApplyStatus: Equatable, Sendable {
    case applied
    case rejected(SessionLifecycleRejectionReason)
    /// Duplicate terminal/cancel after first settlement (observed; no overwrite).
    case duplicate
}

/// Result of an apply (single or batch): status, published snapshot, optional fact.
public struct SessionLifecycleApplyResult: Equatable, Sendable {
    public let status: SessionLifecycleApplyStatus
    public let snapshot: SessionLifecycleSnapshot
    public let fact: SessionLifecycleFact?

    public init(
        status: SessionLifecycleApplyStatus,
        snapshot: SessionLifecycleSnapshot,
        fact: SessionLifecycleFact? = nil
    ) {
        self.status = status
        self.snapshot = snapshot
        self.fact = fact
    }
}

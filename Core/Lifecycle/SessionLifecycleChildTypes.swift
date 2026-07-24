import Foundation

// MARK: - K2 delivery: closed child disposition set + fan-out receipt + fence-join outcome
//
// CREATE-only surface (implement-t09-session-lifecycle-child-registry-and-recovery).
// Value types only; no coordinator, no owner mutation, no UI imports.
// K2 composes K1 (SessionLifecycleCoordinator public class); K1 four files zero MODIFY.
//
// Isolation model = Swift `actor` (chosen in AD-K2-1). K2 runtime types live in
// SessionLifecycleChildRegistry.swift / SessionLifecycleRecoveryCoordinator.swift.
// This file names only Sendable value types + closed-set enums.

// MARK: Child identity

/// Opaque child identity. Equality is value equality on the raw token.
public struct SessionChildID: Equatable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

// MARK: Closed child disposition set

/// Closed set for K2 child disposition (proposal AD-K2-3).
/// SHALL be exactly these five members; any classification outside this set MUST be
/// rejected fail-closed (see `SessionK2RejectionReason.dispositionOutsideClosedSet`).
public enum SessionChildDisposition: String, Equatable, Hashable, Sendable, CaseIterable {
    /// Registered but not yet settled.
    case pending
    /// Cancellation intent applied; child cancelled.
    case cancelled
    /// Child reached a terminal outcome under owner authority.
    case terminal
    /// Child reported unsupported request.
    case unsupported
    /// Child failed to acknowledge before the per-child fence deadline; parent-fenced.
    case timedOutFenced
}

// MARK: Child registration record (immutable value snapshot per child)

/// Immutable child registration record published by the child registry.
/// K2 registry mutates internal storage under actor isolation; consumers observe
/// value-equal snapshots.
public struct SessionChildRegistration: Equatable, Sendable {
    public let childID: SessionChildID
    public let disposition: SessionChildDisposition
    public let generation: SessionGeneration

    public init(
        childID: SessionChildID,
        disposition: SessionChildDisposition,
        generation: SessionGeneration
    ) {
        self.childID = childID
        self.disposition = disposition
        self.generation = generation
    }
}

// MARK: Cancel fan-out receipt

/// Value snapshot returned from `SessionLifecycleChildRegistry.cancelAll(...)`.
/// Records the four settlement classes observed at the moment cancelAll fans out.
/// Late callbacks after this receipt are handled by staleLateCallbackObserved().
public struct SessionCancelFanoutReceipt: Equatable, Sendable {
    /// Children whose disposition transitioned into `.cancelled` by fan-out.
    public let cancelledChildren: [SessionChildID]
    /// Children who acknowledged terminal/unsupported before fan-out entry.
    public let ackedChildren: [SessionChildID]
    /// Children fenced by timeout before fan-out entry.
    public let timedOutFencedChildren: [SessionChildID]
    /// Children still `pending` at fan-out time (awaiting later ack or fence).
    public let stillPendingChildren: [SessionChildID]

    public init(
        cancelledChildren: [SessionChildID],
        ackedChildren: [SessionChildID],
        timedOutFencedChildren: [SessionChildID],
        stillPendingChildren: [SessionChildID]
    ) {
        self.cancelledChildren = cancelledChildren
        self.ackedChildren = ackedChildren
        self.timedOutFencedChildren = timedOutFencedChildren
        self.stillPendingChildren = stillPendingChildren
    }
}

// MARK: Fence-join outcome (3-state, no `unknown` per AD-K2-3)

/// K2 fence-join outcome. Any state outside these three MUST NOT be constructed;
/// the enum is exhaustive by design. `.pending` is fail-closed default when any child
/// remains `pending`; it MUST block recoveryReady evaluation.
public enum SessionFenceJoinOutcome: String, Equatable, Hashable, Sendable {
    /// Every registered child acknowledged a settled disposition.
    case allAcked
    /// Every registered child is settled but at least one via `.timedOutFenced`.
    case timedOutFenced
    /// At least one child remains `.pending`; recoveryReady MUST be denied.
    case pending
}

// MARK: K2 rejection reasons (fail-closed; never implies mutation)

/// Why a K2 registry or coordinator call was rejected.
public enum SessionK2RejectionReason: String, Equatable, Hashable, Sendable {
    /// Authority provided does not match owner authority.
    case wrongAuthority
    /// Ack disposition value is outside the closed set.
    case dispositionOutsideClosedSet
    /// Event or ack carries a `SessionGeneration` strictly less than current generation.
    case staleGeneration
    /// Child ID referenced is not registered.
    case unknownChild
    /// Child ID is already registered under a settled or pending record.
    case alreadyRegistered
    /// Attempted rotation to a new generation whose value is not strictly greater.
    case nonMonotonicGeneration
    /// Attempted ack transition from a settled disposition (only `.pending` may transition).
    case childAlreadySettled
}

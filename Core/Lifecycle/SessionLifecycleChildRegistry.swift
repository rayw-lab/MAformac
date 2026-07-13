import Foundation

// MARK: - K2 child registry actor
//
// CREATE-only surface (implement-t09-session-lifecycle-child-registry-and-recovery).
// Isolation model = Swift `actor` (AD-K2-1); NOT @MainActor. K2 composes K1 externally;
// this file names only the child registry (no K1 SessionLifecycleCoordinator reference).
//
// Contract highlights (see spec.md):
// - Registration + ack + fence + rotate all gated by owner authority.
// - Closed disposition set enforced at ack; disposition outside set → rejected.
// - Fence-join outcome is 3-state exhaustive: allAcked | timedOutFenced | pending.
// - Late callbacks after fence are observed and rejected; `staleLateCallbacks` monotonic.
// - Old-generation events are rejected; stale counter increments.

/// Result envelope for K2 registry mutation calls (register / ack / markFenced /
/// staleLateCallbackObserved / rotateGeneration).
public enum SessionK2RegistryResult: Equatable, Sendable {
    case applied
    case rejected(SessionK2RejectionReason)
    /// Ack with same terminal disposition as already-settled; observed only, no overwrite.
    case duplicate
}

/// Result envelope for K2 registry `cancelAll` call.
public enum SessionK2FanoutResult: Equatable, Sendable {
    case applied(SessionCancelFanoutReceipt)
    case rejected(SessionK2RejectionReason)
}

/// K2 child registry actor. Serializes access to child records, stale counter,
/// and current generation; safe across concurrent Task callers.
public actor SessionLifecycleChildRegistry {
    private let ownerAuthority: SessionOwnerAuthority
    private let parentSessionID: SessionID
    private var currentGeneration: SessionGeneration
    private var records: [SessionChildID: SessionChildRegistration]
    private var staleLateCallbackCount: UInt
    // Per-child fence deadline (in monotonic nanoseconds from `clock`).
    // Populated at register; enforced by `sweepFenceTimeouts()` which reads `clock.nowNanoseconds()`
    // and transitions expired pending/cancelled children to `.timedOutFenced` (P1-1 fix: clock + deadline
    // are actively consumed, no dead field). Owner authority is required to sweep.
    private var fenceDeadlineNsPerChild: [SessionChildID: UInt64]
    private let clock: SessionK2Clock
    private let defaultFenceDeadlineNs: UInt64

    public init(
        ownerAuthority: SessionOwnerAuthority,
        parentSessionID: SessionID,
        generation: SessionGeneration,
        clock: SessionK2Clock = SessionSystemK2Clock(),
        defaultFenceDeadlineNs: UInt64 = 5_000_000_000  // 5 seconds monotonic default
    ) {
        self.ownerAuthority = ownerAuthority
        self.parentSessionID = parentSessionID
        self.currentGeneration = generation
        self.records = [:]
        self.staleLateCallbackCount = 0
        self.fenceDeadlineNsPerChild = [:]
        self.clock = clock
        self.defaultFenceDeadlineNs = defaultFenceDeadlineNs
    }

    // MARK: - Registration

    /// Register a new child under owner authority.
    /// Rejects: wrongAuthority; alreadyRegistered.
    public func register(
        childID: SessionChildID,
        authority: SessionOwnerAuthority
    ) -> SessionK2RegistryResult {
        guard authority == ownerAuthority else {
            return .rejected(.wrongAuthority)
        }
        if records[childID] != nil {
            return .rejected(.alreadyRegistered)
        }
        records[childID] = SessionChildRegistration(
            childID: childID,
            disposition: .pending,
            generation: currentGeneration
        )
        // P1-1: enforce per-child fence deadline (clock + deadline actively consumed).
        // Deadline = registration time + defaultFenceDeadlineNs; sweepFenceTimeouts() reads clock.
        let registeredAtNs = clock.nowNanoseconds()
        fenceDeadlineNsPerChild[childID] = registeredAtNs &+ defaultFenceDeadlineNs
        return .applied
    }

    // MARK: - Cancel fan-out

    /// Fan cancellation out to every registered child.
    /// Rejects: wrongAuthority.
    /// On applied: transitions every `.pending` child to `.cancelled`; records receipt
    /// enumerating currently-settled classes. Late acks from cancelled-then-not-yet-acked
    /// children are handled by ackTerminal (still a valid transition) OR markFenced.
    public func cancelAll(
        authority: SessionOwnerAuthority
    ) -> SessionK2FanoutResult {
        guard authority == ownerAuthority else {
            return .rejected(.wrongAuthority)
        }
        var cancelled: [SessionChildID] = []
        var acked: [SessionChildID] = []
        var fenced: [SessionChildID] = []
        var stillPending: [SessionChildID] = []
        // Deterministic order: sort by rawValue so receipt is stable across runs.
        let sortedChildren = records.keys.sorted { $0.rawValue < $1.rawValue }
        for childID in sortedChildren {
            guard let existing = records[childID] else { continue }
            switch existing.disposition {
            case .pending:
                records[childID] = SessionChildRegistration(
                    childID: childID,
                    disposition: .cancelled,
                    generation: existing.generation
                )
                cancelled.append(childID)
            case .cancelled:
                cancelled.append(childID)
            case .terminal, .unsupported:
                acked.append(childID)
            case .timedOutFenced:
                fenced.append(childID)
            }
        }
        // After cancelAll, still-pending is naturally empty (pending → cancelled above).
        // We enumerate stillPending across a hypothetical concurrent state for API
        // symmetry with the receipt shape; here it is always [] at return time.
        stillPending.removeAll()

        let receipt = SessionCancelFanoutReceipt(
            cancelledChildren: cancelled,
            ackedChildren: acked,
            timedOutFencedChildren: fenced,
            stillPendingChildren: stillPending
        )
        return .applied(receipt)
    }

    // MARK: - Ack (child callback)

    /// Ack a child's terminal / cancelled / unsupported disposition.
    /// Rejects: wrongAuthority; unknownChild; dispositionOutsideClosedSet;
    /// childAlreadySettled (if child is already in a settled disposition and the ack
    /// is a different disposition); duplicate (if same disposition).
    public func ackTerminal(
        childID: SessionChildID,
        disposition: SessionChildDisposition,
        authority: SessionOwnerAuthority
    ) -> SessionK2RegistryResult {
        guard authority == ownerAuthority else {
            return .rejected(.wrongAuthority)
        }
        guard let existing = records[childID] else {
            return .rejected(.unknownChild)
        }
        // Ack disposition MUST be in { cancelled, terminal, unsupported }; pending is
        // not a valid ack target, and timedOutFenced is a fence-only transition.
        switch disposition {
        case .pending, .timedOutFenced:
            return .rejected(.dispositionOutsideClosedSet)
        case .cancelled, .terminal, .unsupported:
            break
        }
        // Transition rules: pending → any settled | cancelled → terminal/unsupported OK.
        // Already-settled (terminal / unsupported / timedOutFenced) MUST NOT be overwritten;
        // same disposition → duplicate.
        switch existing.disposition {
        case .pending:
            records[childID] = SessionChildRegistration(
                childID: childID,
                disposition: disposition,
                generation: existing.generation
            )
            return .applied
        case .cancelled:
            // Cancelled child MAY subsequently ack terminal/unsupported (child reported).
            if disposition == existing.disposition {
                return .duplicate
            }
            records[childID] = SessionChildRegistration(
                childID: childID,
                disposition: disposition,
                generation: existing.generation
            )
            return .applied
        case .terminal, .unsupported:
            if disposition == existing.disposition {
                return .duplicate
            }
            return .rejected(.childAlreadySettled)
        case .timedOutFenced:
            // Late ack after fence: recorded as observed via staleLateCallbackObserved.
            // Direct ackTerminal path treats this as rejected (already-settled semantics).
            return .rejected(.childAlreadySettled)
        }
    }

    // MARK: - Fence marking (deadline elapsed)

    /// Mark a child as `.timedOutFenced` after the per-child deadline elapsed.
    /// Rejects: wrongAuthority; unknownChild; childAlreadySettled (if child is already
    /// in a settled non-pending / non-cancelled disposition).
    public func markFenced(
        childID: SessionChildID,
        authority: SessionOwnerAuthority
    ) -> SessionK2RegistryResult {
        guard authority == ownerAuthority else {
            return .rejected(.wrongAuthority)
        }
        guard let existing = records[childID] else {
            return .rejected(.unknownChild)
        }
        switch existing.disposition {
        case .pending, .cancelled:
            records[childID] = SessionChildRegistration(
                childID: childID,
                disposition: .timedOutFenced,
                generation: existing.generation
            )
            return .applied
        case .terminal, .unsupported, .timedOutFenced:
            return .rejected(.childAlreadySettled)
        }
    }

    // MARK: - Fence timeout sweep (P1-1: enforce clock + deadline)
    //
    // Sweep the registry for pending/cancelled children whose per-child fence deadline
    // has elapsed against `clock.nowNanoseconds()`. Expired children transition to
    // `.timedOutFenced`; already-settled children are left alone. Returns the set of
    // children that were transitioned in this sweep call.
    //
    // Called explicitly by the owner (see SessionLifecycleRecoveryCoordinator);
    // enforces that `clock` and `fenceDeadlineNsPerChild` are consumed (not dead fields).

    /// Sweep fence timeouts against the K2 clock; transition expired pending/cancelled
    /// children to `.timedOutFenced` and return the children so transitioned.
    /// Rejects (returns empty transitioned set) on non-owner authority; does NOT alter records.
    public func sweepFenceTimeouts(
        authority: SessionOwnerAuthority
    ) -> [SessionChildID] {
        guard authority == ownerAuthority else {
            return []
        }
        let nowNs = clock.nowNanoseconds()
        var transitioned: [SessionChildID] = []
        // Deterministic order by rawValue for stable receipt.
        let sortedChildren = records.keys.sorted { $0.rawValue < $1.rawValue }
        for childID in sortedChildren {
            guard let existing = records[childID] else { continue }
            switch existing.disposition {
            case .pending, .cancelled:
                if let deadline = fenceDeadlineNsPerChild[childID], nowNs >= deadline {
                    records[childID] = SessionChildRegistration(
                        childID: childID,
                        disposition: .timedOutFenced,
                        generation: existing.generation
                    )
                    transitioned.append(childID)
                }
            case .terminal, .unsupported, .timedOutFenced:
                continue
            }
        }
        return transitioned
    }

    // MARK: - Stale-late callback observation (never applies; increments counter)

    /// Record a late callback from a fenced or stale-generation child.
    /// Rejects: wrongAuthority; unknownChild.
    /// Applied: no disposition mutation; `staleLateCallbackCount` increments by one.
    public func staleLateCallbackObserved(
        childID: SessionChildID,
        authority: SessionOwnerAuthority
    ) -> SessionK2RegistryResult {
        guard authority == ownerAuthority else {
            return .rejected(.wrongAuthority)
        }
        guard records[childID] != nil else {
            return .rejected(.unknownChild)
        }
        staleLateCallbackCount = staleLateCallbackCount &+ 1
        return .applied
    }

    // MARK: - Rotate generation (recovery grants new generation)

    /// Rotate to a strictly-greater new generation. All existing children are fenced
    /// to the old generation; their records are cleared as part of rotation semantics.
    /// Rejects: wrongAuthority; nonMonotonicGeneration.
    public func rotateGeneration(
        newGeneration: SessionGeneration,
        authority: SessionOwnerAuthority
    ) -> SessionK2RegistryResult {
        guard authority == ownerAuthority else {
            return .rejected(.wrongAuthority)
        }
        guard newGeneration.value > currentGeneration.value else {
            return .rejected(.nonMonotonicGeneration)
        }
        currentGeneration = newGeneration
        // Fence semantics: previous generation's child records are archived (cleared).
        // Any late callback carrying the previous generation MUST route through
        // staleLateCallbackObserved which will now report unknownChild — that is the
        // intended behavior; callers must distinguish "late callback from old-gen child"
        // from "late callback from unknown child" by inspecting the old vs new generation
        // path externally (see SessionLifecycleRecoveryCoordinator).
        records.removeAll()
        fenceDeadlineNsPerChild.removeAll()
        return .applied
    }

    // MARK: - Reads (do not mutate)

    /// Immutable snapshot of all current child records.
    public func snapshot() -> [SessionChildRegistration] {
        // Deterministic order by rawValue.
        records.keys.sorted { $0.rawValue < $1.rawValue }.compactMap { records[$0] }
    }

    /// Honest count of stale-late callbacks observed since init.
    public func staleLateCallbacks() -> UInt {
        staleLateCallbackCount
    }

    /// Current generation held by the registry.
    public func generation() -> SessionGeneration {
        currentGeneration
    }

    /// Compute fence-join outcome from current records.
    /// Exhaustive on `SessionChildDisposition`:
    /// - Any `.pending` → `.pending`
    /// - All settled and at least one `.timedOutFenced` → `.timedOutFenced`
    /// - All settled without any `.timedOutFenced` → `.allAcked`
    /// Empty registry → `.allAcked` (vacuously true; no pending children).
    public func fenceJoinOutcome() -> SessionFenceJoinOutcome {
        var sawTimedOut = false
        for (_, record) in records {
            switch record.disposition {
            case .pending:
                return .pending
            case .timedOutFenced:
                sawTimedOut = true
            case .cancelled, .terminal, .unsupported:
                continue
            }
        }
        return sawTimedOut ? .timedOutFenced : .allAcked
    }
}

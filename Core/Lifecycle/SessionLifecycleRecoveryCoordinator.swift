import Foundation

// MARK: - K2 recovery coordinator actor
//
// CREATE-only surface (implement-t09-session-lifecycle-child-registry-and-recovery).
// Isolation model = Swift `actor` (AD-K2-1); NOT @MainActor. Owns:
// - one `SessionLifecycleCoordinator` (K1 public class) via composition;
// - one `SessionLifecycleChildRegistry` (K2 actor) via composition;
// - stable checkpoint + pending plan account (separated per AD-K2-4);
// - stale-late-callback counter for old-generation events (AD-K2-5).
//
// K1 four files are zero MODIFY: K2 uses only K1 public init + `apply(_:authority:)`.

/// K2 recovery coordinator actor.
public actor SessionLifecycleRecoveryCoordinator {
    private let ownerAuthority: SessionOwnerAuthority
    private let parentSessionID: SessionID
    // K1 K3-style single-owner coordinator, composed (not modified).
    private let k1Coordinator: SessionLifecycleCoordinator
    // K2 child registry (owned by this coordinator, actor-serialized).
    private let childRegistry: SessionLifecycleChildRegistry
    // Recovery source separation.
    private var stableCheckpoint: SessionStableCheckpoint?
    private var pendingPlan: SessionPendingPlan?
    // Stale-late old-generation counter (separate from child registry's stale counter).
    private var oldGenerationStaleCount: UInt
    // Coordinator-tracked current generation (mirrors K1 init generation until rotate).
    private var currentGeneration: SessionGeneration

    public init(
        ownerAuthority: SessionOwnerAuthority,
        sessionID: SessionID,
        generation: SessionGeneration,
        clock: SessionK2Clock = SessionSystemK2Clock()
    ) {
        self.ownerAuthority = ownerAuthority
        self.parentSessionID = sessionID
        self.k1Coordinator = SessionLifecycleCoordinator(
            ownerAuthority: ownerAuthority,
            sessionID: sessionID,
            generation: generation
        )
        self.childRegistry = SessionLifecycleChildRegistry(
            ownerAuthority: ownerAuthority,
            parentSessionID: sessionID,
            generation: generation,
            clock: clock
        )
        self.stableCheckpoint = nil
        self.pendingPlan = nil
        self.oldGenerationStaleCount = 0
        self.currentGeneration = generation
    }

    // MARK: - K1 parent apply pass-through (composition, no shadow snapshot)

    /// Read the immutable K1 snapshot. Reflects K1 first-cause immutability.
    public func snapshot() -> SessionLifecycleSnapshot {
        k1Coordinator.snapshot
    }

    /// Delegate a single parent-lifecycle event to K1 apply under owner authority.
    /// Old-generation events are rejected at the K2 boundary before touching K1.
    public func apply(
        _ event: SessionLifecycleEvent,
        authority: SessionOwnerAuthority
    ) -> SessionLifecycleApplyResult {
        // K2 boundary: old-generation guard first.
        if let ev = eventGeneration(event), ev.value < currentGeneration.value {
            oldGenerationStaleCount = oldGenerationStaleCount &+ 1
            return SessionLifecycleApplyResult(
                status: .rejected(.unknownGeneration),
                snapshot: k1Coordinator.snapshot,
                fact: nil
            )
        }
        return k1Coordinator.apply(event, authority: authority)
    }

    /// Delegate a compound batch to K1 apply under owner authority.
    /// Old-generation events anywhere in the batch reject the whole batch.
    public func apply(
        batch: [SessionLifecycleEvent],
        authority: SessionOwnerAuthority
    ) -> SessionLifecycleApplyResult {
        for event in batch {
            if let ev = eventGeneration(event), ev.value < currentGeneration.value {
                oldGenerationStaleCount = oldGenerationStaleCount &+ 1
                return SessionLifecycleApplyResult(
                    status: .rejected(.unknownGeneration),
                    snapshot: k1Coordinator.snapshot,
                    fact: nil
                )
            }
        }
        return k1Coordinator.apply(batch: batch, authority: authority)
    }

    // MARK: - Child registry pass-through (async, actor-crossing)

    public func registerChild(
        childID: SessionChildID,
        authority: SessionOwnerAuthority
    ) async -> SessionK2RegistryResult {
        await childRegistry.register(childID: childID, authority: authority)
    }

    public func cancelAllChildren(
        authority: SessionOwnerAuthority
    ) async -> SessionK2FanoutResult {
        await childRegistry.cancelAll(authority: authority)
    }

    public func ackChild(
        childID: SessionChildID,
        disposition: SessionChildDisposition,
        authority: SessionOwnerAuthority
    ) async -> SessionK2RegistryResult {
        await childRegistry.ackTerminal(
            childID: childID,
            disposition: disposition,
            authority: authority
        )
    }

    public func markChildFenced(
        childID: SessionChildID,
        authority: SessionOwnerAuthority
    ) async -> SessionK2RegistryResult {
        await childRegistry.markFenced(childID: childID, authority: authority)
    }

    public func observeStaleLateChildCallback(
        childID: SessionChildID,
        authority: SessionOwnerAuthority
    ) async -> SessionK2RegistryResult {
        await childRegistry.staleLateCallbackObserved(
            childID: childID,
            authority: authority
        )
    }

    public func childSnapshot() async -> [SessionChildRegistration] {
        await childRegistry.snapshot()
    }

    public func fenceJoinOutcome() async -> SessionFenceJoinOutcome {
        await childRegistry.fenceJoinOutcome()
    }

    public func childStaleLateCallbacks() async -> UInt {
        await childRegistry.staleLateCallbacks()
    }

    // MARK: - Recovery source account (checkpoint vs pending plan separation)

    /// Record a stable checkpoint under owner authority.
    /// Returns true if applied; false if authority mismatch.
    public func recordStableCheckpoint(
        _ checkpoint: SessionStableCheckpoint,
        authority: SessionOwnerAuthority
    ) -> Bool {
        guard authority == ownerAuthority else {
            return false
        }
        stableCheckpoint = checkpoint
        return true
    }

    /// Record a pending plan under owner authority.
    /// Returns true if applied; false if authority mismatch.
    /// A pending plan MUST NOT be treated as a recovery source (see AD-K2-4).
    public func recordPendingPlan(
        _ plan: SessionPendingPlan,
        authority: SessionOwnerAuthority
    ) -> Bool {
        guard authority == ownerAuthority else {
            return false
        }
        pendingPlan = plan
        return true
    }

    /// Current stable checkpoint (nil if none recorded).
    public func currentStableCheckpoint() -> SessionStableCheckpoint? {
        stableCheckpoint
    }

    /// Current pending plan (nil if none recorded).
    public func currentPendingPlan() -> SessionPendingPlan? {
        pendingPlan
    }

    // MARK: - Recovery request (three-condition truth table + generation rotate)

    /// Evaluate the three-condition truth table and, on grant, rotate the child registry
    /// and internal generation to `newGeneration`. K1 parent snapshot is NOT mutated by
    /// this call; recovery only advances K2-owned generation and clears child records.
    /// Exhaustive per AD-K2-4; no default fallback branch.
    public func requestRecovery(
        newGeneration: SessionGeneration,
        newSessionID: SessionID,
        authority: SessionOwnerAuthority
    ) async -> SessionRecoveryOutcome {
        guard authority == ownerAuthority else {
            return .deniedAuthority
        }
        // Condition 1: K1 must be terminal.
        let k1 = k1Coordinator.snapshot
        guard k1.state == .terminal else {
            return .deniedTerminalIncomplete
        }
        // Condition 2: recovery source separation.
        //   - stableCheckpoint present → satisfies checkpoint condition
        //   - stableCheckpoint absent, pendingPlan present → deniedPendingPlanOnly
        //   - both absent → deniedCheckpointMissing
        if stableCheckpoint == nil {
            if pendingPlan != nil {
                return .deniedPendingPlanOnly
            }
            return .deniedCheckpointMissing
        }
        // Condition 3: fence-join outcome must be allAcked or timedOutFenced.
        let fence = await childRegistry.fenceJoinOutcome()
        switch fence {
        case .pending:
            return .deniedChildJoinIncomplete
        case .allAcked, .timedOutFenced:
            break
        }
        // Generation monotonic check.
        guard newGeneration.value > currentGeneration.value else {
            return .deniedStaleGeneration
        }
        // Grant: rotate child registry + advance K2 generation.
        // K1 parent snapshot is NOT mutated; K1 remains terminal with first cause intact.
        let rotate = await childRegistry.rotateGeneration(
            newGeneration: newGeneration,
            authority: ownerAuthority
        )
        switch rotate {
        case .applied:
            currentGeneration = newGeneration
            return .granted(newGeneration: newGeneration, newSessionID: newSessionID)
        case .rejected, .duplicate:
            // Defensive: rotate under the same authority must succeed here since we
            // just validated monotonicity. If it does not, we treat it as a denial
            // rather than crash. Report as staleGeneration to keep the caller safe.
            return .deniedStaleGeneration
        }
    }

    // MARK: - Old-generation guard reads

    public func oldGenerationStaleCallbackCount() -> UInt {
        oldGenerationStaleCount
    }

    public func generation() -> SessionGeneration {
        currentGeneration
    }

    // MARK: - Helpers

    /// Extract the SessionGeneration of an event (K1 events all carry generation).
    private func eventGeneration(_ event: SessionLifecycleEvent) -> SessionGeneration? {
        switch event {
        case .start(_, let gen):
            return gen
        case .terminal(_, let gen, _, _, _):
            return gen
        case .recoveryReady(_, let gen):
            return gen
        case .newGeneration(_, let gen):
            return gen
        }
    }
}

import Foundation

// MARK: - K2 delivery: checkpoint / pending plan / recovery outcome / interleaving profile / clock seam
//
// CREATE-only surface (implement-t09-session-lifecycle-child-registry-and-recovery).
// Value types + protocol seam only. No coordinator, no owner mutation, no UI imports.
// K2 recovery source is last reconciled stable checkpoint only; pending plan MUST NOT
// upgrade to recovery source (AD-K2-4).

// MARK: Stable checkpoint (recovery source)

/// Immutable last reconciled stable checkpoint for a parent session.
/// K2 recovery coordinator MUST use this as the ONLY recovery source; a pending plan
/// MUST NOT satisfy the recovery source condition (see `SessionRecoveryOutcome.deniedPendingPlanOnly`).
public struct SessionStableCheckpoint: Equatable, Sendable {
    public let sessionID: SessionID
    public let generation: SessionGeneration
    public let terminalDisposition: SessionTerminalDisposition
    public let terminalCause: SessionTerminalCause
    /// Opaque ledger identity for provenance; verifiable independently by consumers.
    public let ledgerDigest: String

    public init(
        sessionID: SessionID,
        generation: SessionGeneration,
        terminalDisposition: SessionTerminalDisposition,
        terminalCause: SessionTerminalCause,
        ledgerDigest: String
    ) {
        self.sessionID = sessionID
        self.generation = generation
        self.terminalDisposition = terminalDisposition
        self.terminalCause = terminalCause
        self.ledgerDigest = ledgerDigest
    }
}

// MARK: Pending plan (observed only; NEVER a recovery source)

/// Immutable pending plan marker. K2 SHALL preserve this as observed material
/// but MUST NOT treat it as recovery source under any condition.
public struct SessionPendingPlan: Equatable, Sendable {
    public let sessionID: SessionID
    public let generation: SessionGeneration
    /// Opaque description; K2 does not interpret content.
    public let planLabel: String

    public init(
        sessionID: SessionID,
        generation: SessionGeneration,
        planLabel: String
    ) {
        self.sessionID = sessionID
        self.generation = generation
        self.planLabel = planLabel
    }
}

// MARK: Recovery outcome (three-condition truth table per AD-K2-4)

/// Result of `SessionLifecycleRecoveryCoordinator.requestRecovery(...)`.
/// Cases are exhaustive; no default fallback branch is allowed at the switch site
/// (derivation-layer-discipline: `default` MUST NOT double-serve legitimate fallback
/// and silent misconfig swallow).
public enum SessionRecoveryOutcome: Equatable, Sendable {
    /// Recovery granted; new generation allocated strictly greater than previous.
    case granted(newGeneration: SessionGeneration, newSessionID: SessionID)
    /// K1 snapshot is not `.terminal`.
    case deniedTerminalIncomplete
    /// No stable checkpoint recorded (and no pending plan).
    case deniedCheckpointMissing
    /// Pending plan is recorded but no stable checkpoint exists.
    /// Distinct from `deniedCheckpointMissing` to prevent silent "pending plan → recovery" upgrade.
    case deniedPendingPlanOnly
    /// One or more registered children remain `.pending`.
    case deniedChildJoinIncomplete
    /// Caller authority is not owner authority.
    case deniedAuthority
    /// Requested new generation is not strictly greater than current generation.
    case deniedStaleGeneration
}

// MARK: Deterministic interleaving profile (010a; claim class = profile_only)

/// Deterministic interleaving profile record. This value is ONLY a profile receipt;
/// it MUST NOT be reported as `proof_runtime`, `W8 DONE`, `operator-pass`, `V-PASS`,
/// `C5 V-PASS`, `C6 acceptance`, `mobile`, `true-device`, or `live proof`.
public struct SessionLifecycleInterleavingProfile: Equatable, Sendable {
    public let seed: UInt64
    /// Ordered schedule of event tags (opaque strings; identity + order-critical).
    public let schedule: [String]
    /// SHA-256 hex over the canonical schedule serialization; consumers verify independently.
    public let ledgerDigest: String
    /// Honest count of stale-late callbacks observed during the profile run.
    /// MUST NOT be hard-wired to zero; the profile receipt records the exact number.
    public let staleMutationCount: UInt

    public init(
        seed: UInt64,
        schedule: [String],
        ledgerDigest: String,
        staleMutationCount: UInt
    ) {
        self.seed = seed
        self.schedule = schedule
        self.ledgerDigest = ledgerDigest
        self.staleMutationCount = staleMutationCount
    }
}

// MARK: K2 clock seam (protocol + FakeClock; AD-K2-6)

/// Monotonic clock seam for K2 fence deadline evaluation. Production uses
/// `SessionSystemK2Clock`; deterministic tests use `SessionK2FakeClock` inline.
/// No external dependency (`swift-clocks` NOT introduced; Package.swift no-touch).
public protocol SessionK2Clock: Sendable {
    /// Monotonic nanoseconds. K2 does not require wall-clock semantics.
    func nowNanoseconds() -> UInt64
}

/// Production implementation using `DispatchTime.now().uptimeNanoseconds`.
public struct SessionSystemK2Clock: SessionK2Clock {
    public init() {}
    public func nowNanoseconds() -> UInt64 {
        DispatchTime.now().uptimeNanoseconds
    }
}

/// Deterministic test clock. Manual tick advancement; NOT thread-safe by itself
/// (K2 tests use it inside actor isolation, which serializes access).
public final class SessionK2FakeClock: SessionK2Clock, @unchecked Sendable {
    // K2 tests hold a reference and mutate `current` from a single actor context.
    // @unchecked Sendable is documented here as a test-seam only; production K2 uses
    // SessionSystemK2Clock which is a value type and unconditionally Sendable.
    private var current: UInt64

    public init(startNanoseconds: UInt64 = 0) {
        self.current = startNanoseconds
    }

    public func nowNanoseconds() -> UInt64 {
        current
    }

    public func advance(by delta: UInt64) {
        current = current &+ delta
    }
}

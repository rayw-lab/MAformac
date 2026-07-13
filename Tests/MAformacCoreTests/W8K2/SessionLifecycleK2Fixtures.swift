import Foundation
@testable import MAformacCore

// MARK: - K2 delivery fixtures (F04, F05, F06, F07, F08, F12)
//
// Value constants only. No shared mutable state.
// Identity values are distinct from K1 fixture set (SessionLifecycleFixtures.*)
// to prevent accidental coupling.

enum SessionLifecycleK2Fixtures {
    // Shared immutable identity material for K2 tests.
    static let ownerA = SessionOwnerAuthority(rawValue: "k2.owner.a")
    static let ownerB = SessionOwnerAuthority(rawValue: "k2.owner.b")

    static let parentSessionAlpha = SessionID(rawValue: "k2.parent.alpha")
    static let parentSessionBeta = SessionID(rawValue: "k2.parent.beta")

    static let generation1 = SessionGeneration(value: 1)
    static let generation2 = SessionGeneration(value: 2)
    static let generation0 = SessionGeneration(value: 0)

    static let childA = SessionChildID(rawValue: "child.a")
    static let childB = SessionChildID(rawValue: "child.b")
    static let childC = SessionChildID(rawValue: "child.c")

    // MARK: F04 — child register, cancel fan-out, ack, fence

    enum F04 {
        static let id = "F04"
        static let owner = SessionLifecycleK2Fixtures.ownerA
        static let parentSession = SessionLifecycleK2Fixtures.parentSessionAlpha
        static let generation = SessionLifecycleK2Fixtures.generation1
        static let expectedClosedSetCount = 5   // pending, cancelled, terminal, unsupported, timedOutFenced
        static let expectedSettledSetCountFromDefineT09 = 4  // cancelled, terminal, unsupported, timedOutFenced
    }

    // MARK: F05 — fence join half-fail (some ack, some fence)

    enum F05 {
        static let id = "F05"
        static let owner = SessionLifecycleK2Fixtures.ownerA
        static let parentSession = SessionLifecycleK2Fixtures.parentSessionAlpha
        static let generation = SessionLifecycleK2Fixtures.generation1
    }

    // MARK: F06 — recovery three-condition truth table

    enum F06 {
        static let id = "F06"
        static let owner = SessionLifecycleK2Fixtures.ownerA
        static let sessionAtRecovery = SessionLifecycleK2Fixtures.parentSessionAlpha
        static let initialGeneration = SessionLifecycleK2Fixtures.generation1
        static let newSessionID = SessionID(rawValue: "k2.recovered.beta")
        static let newGeneration = SessionLifecycleK2Fixtures.generation2

        static let checkpointLedgerDigest = "F06-checkpoint-ledger-hex"

        static func completedTerminalEvent() -> SessionLifecycleEvent {
            .terminal(
                sessionID: sessionAtRecovery,
                generation: initialGeneration,
                disposition: .completed,
                cause: .completedNormally,
                outcomeClass: .accepted
            )
        }

        static func startEvent() -> SessionLifecycleEvent {
            .start(sessionID: sessionAtRecovery, generation: initialGeneration)
        }

        static func stableCheckpoint() -> SessionStableCheckpoint {
            SessionStableCheckpoint(
                sessionID: sessionAtRecovery,
                generation: initialGeneration,
                terminalDisposition: .completed,
                terminalCause: .completedNormally,
                ledgerDigest: checkpointLedgerDigest
            )
        }

        static func pendingPlan() -> SessionPendingPlan {
            SessionPendingPlan(
                sessionID: sessionAtRecovery,
                generation: initialGeneration,
                planLabel: "F06-pending-plan"
            )
        }
    }

    // MARK: F07 — old-generation stale reject

    enum F07 {
        static let id = "F07"
        static let owner = SessionLifecycleK2Fixtures.ownerA
        static let parentSession = SessionLifecycleK2Fixtures.parentSessionAlpha
        static let currentGeneration = SessionLifecycleK2Fixtures.generation2
        static let oldGeneration = SessionLifecycleK2Fixtures.generation1

        static func oldGenerationTerminalEvent() -> SessionLifecycleEvent {
            .terminal(
                sessionID: parentSession,
                generation: oldGeneration,
                disposition: .completed,
                cause: .completedNormally,
                outcomeClass: .accepted
            )
        }

        static func oldGenerationStartEvent() -> SessionLifecycleEvent {
            .start(sessionID: parentSession, generation: oldGeneration)
        }
    }

    // MARK: F08 — deterministic interleaving profile (seed A)

    enum F08 {
        static let id = "F08"
        static let seed: UInt64 = 42
        static let scheduleEvents: [String] = [
            "register:a",
            "register:b",
            "cancelAll",
            "ack:a:terminal",
            "fence:b",
            "rotate:2",
            "stale-late:b"
        ]
        // canonical_serialization used to derive the SHA-256 digest.
        // Matches contracts/fixtures/w8-k2/interleaving-profile-seed-A.json.
        static let canonicalSerialization =
            "seed=42;schedule=register:a|register:b|cancelAll|ack:a:terminal|fence:b|rotate:2|stale-late:b"
        // Hard-coded expected digest (independently computed via shasum -a 256 outside test).
        static let expectedLedgerDigestHex =
            "017311631c4c637188f43fb53a81fef53cdcb4384fb7faa20a818bd33ffc748e"
        static let expectedStaleMutationCount: UInt = 1
        static let claimClass = "profile_only"
    }

    // MARK: F12 — stable checkpoint vs pending plan separation

    enum F12 {
        static let id = "F12"
        static let owner = SessionLifecycleK2Fixtures.ownerA
        static let sessionID = SessionLifecycleK2Fixtures.parentSessionAlpha
        static let generation = SessionLifecycleK2Fixtures.generation1

        static func stableCheckpoint() -> SessionStableCheckpoint {
            SessionStableCheckpoint(
                sessionID: sessionID,
                generation: generation,
                terminalDisposition: .completed,
                terminalCause: .completedNormally,
                ledgerDigest: "F12-checkpoint-hex"
            )
        }

        static func pendingPlan() -> SessionPendingPlan {
            SessionPendingPlan(
                sessionID: sessionID,
                generation: generation,
                planLabel: "F12-pending-plan"
            )
        }
    }
}

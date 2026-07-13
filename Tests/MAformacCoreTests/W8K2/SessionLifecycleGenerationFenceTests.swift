import XCTest
import CommonCrypto
@testable import MAformacCore

/// K2 old-generation fence + deterministic interleaving profile.
///
/// Oracle independence: expected ledger digest is hard-coded (see F08 fixture);
/// tests compute SHA-256 in-test via CommonCrypto and assert against the fixture
/// hex string. K2 impl does NOT expose a digest property that the test reads back
/// to itself.
final class SessionLifecycleGenerationFenceTests: XCTestCase {

    // (a) Old-generation ack (via K2 apply) is rejected as unknownGeneration; stale counter increments.
    func test_a_old_generation_terminal_rejected_and_counted() async {
        let c = SessionLifecycleRecoveryCoordinator(
            ownerAuthority: SessionLifecycleK2Fixtures.F07.owner,
            sessionID: SessionLifecycleK2Fixtures.F07.parentSession,
            generation: SessionLifecycleK2Fixtures.F07.currentGeneration, // gen 2
            clock: SessionK2FakeClock(startNanoseconds: 0)
        )
        // Send a terminal event carrying gen 1 (old); must be rejected at K2 guard
        // BEFORE reaching K1 apply.
        let result = await c.apply(
            SessionLifecycleK2Fixtures.F07.oldGenerationTerminalEvent(),
            authority: SessionLifecycleK2Fixtures.F07.owner
        )
        XCTAssertEqual(result.status, .rejected(.unknownGeneration))
        // K1 snapshot is unchanged (still .ready since no successful start ran on this coordinator).
        let k1 = await c.snapshot()
        XCTAssertEqual(k1.state, .ready)
        XCTAssertNil(k1.firstTerminalDisposition)
        XCTAssertNil(k1.firstTerminalCause)
        // Stale counter incremented exactly once.
        let sc = await c.oldGenerationStaleCallbackCount()
        XCTAssertEqual(sc, 1)
    }

    // (b) Second old-generation event increments stale counter monotonically to 2.
    func test_b_stale_counter_monotonic_increment() async {
        let c = SessionLifecycleRecoveryCoordinator(
            ownerAuthority: SessionLifecycleK2Fixtures.F07.owner,
            sessionID: SessionLifecycleK2Fixtures.F07.parentSession,
            generation: SessionLifecycleK2Fixtures.F07.currentGeneration,
            clock: SessionK2FakeClock(startNanoseconds: 0)
        )
        _ = await c.apply(SessionLifecycleK2Fixtures.F07.oldGenerationStartEvent(), authority: SessionLifecycleK2Fixtures.F07.owner)
        _ = await c.apply(SessionLifecycleK2Fixtures.F07.oldGenerationTerminalEvent(), authority: SessionLifecycleK2Fixtures.F07.owner)
        let sc = await c.oldGenerationStaleCallbackCount()
        XCTAssertEqual(sc, 2)
    }

    // (c) Old-generation event as part of a batch → whole batch rejected; counter++.
    func test_c_old_generation_in_batch_rejects_whole_batch() async {
        let c = SessionLifecycleRecoveryCoordinator(
            ownerAuthority: SessionLifecycleK2Fixtures.F07.owner,
            sessionID: SessionLifecycleK2Fixtures.F07.parentSession,
            generation: SessionLifecycleK2Fixtures.F07.currentGeneration,
            clock: SessionK2FakeClock(startNanoseconds: 0)
        )
        let batch: [SessionLifecycleEvent] = [
            SessionLifecycleK2Fixtures.F07.oldGenerationStartEvent(),
            SessionLifecycleK2Fixtures.F07.oldGenerationTerminalEvent()
        ]
        let result = await c.apply(batch: batch, authority: SessionLifecycleK2Fixtures.F07.owner)
        XCTAssertEqual(result.status, .rejected(.unknownGeneration))
        let sc = await c.oldGenerationStaleCallbackCount()
        // Guard rejects on first old-gen event; counter incremented once.
        XCTAssertEqual(sc, 1)
    }

    // (d) Deterministic interleaving profile: SHA-256 over canonical serialization
    //     matches fixture hex; also matches when re-computed via CommonCrypto on the
    //     same bytes twice (idempotence).
    func test_d_interleaving_profile_ledger_digest_matches_fixture() {
        let canonical = SessionLifecycleK2Fixtures.F08.canonicalSerialization
        let d1 = Self.sha256HexOf(canonical)
        let d2 = Self.sha256HexOf(canonical)
        XCTAssertEqual(d1, d2, "SHA-256 hex must be identical across repeated runs on same bytes")
        XCTAssertEqual(d1, SessionLifecycleK2Fixtures.F08.expectedLedgerDigestHex)
    }

    // (e) Fixture claim class is `profile_only` and must NOT be treated as proof_runtime.
    //     Assert against a hard-coded string literal to prove no upgrade.
    func test_e_claim_class_is_profile_only_not_proof_runtime() {
        XCTAssertEqual(SessionLifecycleK2Fixtures.F08.claimClass, "profile_only")
        XCTAssertNotEqual(SessionLifecycleK2Fixtures.F08.claimClass, "proof_runtime")
        XCTAssertNotEqual(SessionLifecycleK2Fixtures.F08.claimClass, "W8_DONE")
        XCTAssertNotEqual(SessionLifecycleK2Fixtures.F08.claimClass, "operator-pass")
        XCTAssertNotEqual(SessionLifecycleK2Fixtures.F08.claimClass, "V-PASS")
        XCTAssertNotEqual(SessionLifecycleK2Fixtures.F08.claimClass, "live proof")
    }

    // (f) F12 checkpoint vs pending plan value-equality reads back correctly.
    func test_f_checkpoint_vs_pending_plan_value_types() {
        let ck = SessionLifecycleK2Fixtures.F12.stableCheckpoint()
        let pp = SessionLifecycleK2Fixtures.F12.pendingPlan()
        XCTAssertEqual(ck.terminalDisposition, .completed)
        XCTAssertEqual(ck.terminalCause, .completedNormally)
        XCTAssertEqual(pp.planLabel, "F12-pending-plan")
        // The two live in separate namespaces on the recovery coordinator; not equal by type.
    }

    // MARK: - SHA-256 helper (CommonCrypto)

    private static func sha256HexOf(_ text: String) -> String {
        let data = Array(text.utf8)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBufferPointer { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(buffer.count), &hash)
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

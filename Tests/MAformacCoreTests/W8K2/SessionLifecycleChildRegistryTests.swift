import XCTest
@testable import MAformacCore

/// K2 child registry: registration, cancel fan-out, ack, fence, stale-late, disposition-outside-set,
/// non-owner rejection, and fence-join outcome under three-state exhaustiveness.
///
/// Oracle independence: expected values are hard-coded here; not read back from
/// SessionChildDisposition.allCases enumeration (that would be self-referential).
final class SessionLifecycleChildRegistryTests: XCTestCase {

    private func makeRegistry() -> SessionLifecycleChildRegistry {
        SessionLifecycleChildRegistry(
            ownerAuthority: SessionLifecycleK2Fixtures.F04.owner,
            parentSessionID: SessionLifecycleK2Fixtures.F04.parentSession,
            generation: SessionLifecycleK2Fixtures.F04.generation,
            clock: SessionK2FakeClock(startNanoseconds: 0)
        )
    }

    // (a) register + list snapshot returns two children in deterministic order.
    func test_a_register_two_children_list_snapshot_deterministic() async {
        let r = makeRegistry()
        let r1 = await r.register(childID: SessionLifecycleK2Fixtures.childA, authority: SessionLifecycleK2Fixtures.F04.owner)
        let r2 = await r.register(childID: SessionLifecycleK2Fixtures.childB, authority: SessionLifecycleK2Fixtures.F04.owner)
        XCTAssertEqual(r1, .applied)
        XCTAssertEqual(r2, .applied)
        let snap = await r.snapshot()
        XCTAssertEqual(snap.count, 2)
        XCTAssertEqual(snap[0].childID, SessionLifecycleK2Fixtures.childA)
        XCTAssertEqual(snap[0].disposition, .pending)
        XCTAssertEqual(snap[1].childID, SessionLifecycleK2Fixtures.childB)
        XCTAssertEqual(snap[1].disposition, .pending)
        let fence = await r.fenceJoinOutcome()
        // Two pending children → fence-join MUST be .pending fail-closed.
        XCTAssertEqual(fence, .pending)
    }

    // (b) cancelAll fan-out receipt reflects both children as cancelled.
    func test_b_cancelAll_fanout_receipt_lists_two_cancelled() async {
        let r = makeRegistry()
        _ = await r.register(childID: SessionLifecycleK2Fixtures.childA, authority: SessionLifecycleK2Fixtures.F04.owner)
        _ = await r.register(childID: SessionLifecycleK2Fixtures.childB, authority: SessionLifecycleK2Fixtures.F04.owner)
        let out = await r.cancelAll(authority: SessionLifecycleK2Fixtures.F04.owner)
        guard case .applied(let receipt) = out else {
            XCTFail("Expected applied fan-out receipt; got: \(out)")
            return
        }
        XCTAssertEqual(receipt.cancelledChildren, [SessionLifecycleK2Fixtures.childA, SessionLifecycleK2Fixtures.childB])
        XCTAssertTrue(receipt.ackedChildren.isEmpty)
        XCTAssertTrue(receipt.timedOutFencedChildren.isEmpty)
        XCTAssertTrue(receipt.stillPendingChildren.isEmpty)
    }

    // (c) After cancelAll + two acks, fenceJoinOutcome becomes .allAcked
    //     (both children transitioned from .cancelled → .terminal via ackTerminal).
    func test_c_ack_terminal_reaches_allAcked() async {
        let r = makeRegistry()
        _ = await r.register(childID: SessionLifecycleK2Fixtures.childA, authority: SessionLifecycleK2Fixtures.F04.owner)
        _ = await r.register(childID: SessionLifecycleK2Fixtures.childB, authority: SessionLifecycleK2Fixtures.F04.owner)
        _ = await r.cancelAll(authority: SessionLifecycleK2Fixtures.F04.owner)
        let a1 = await r.ackTerminal(childID: SessionLifecycleK2Fixtures.childA, disposition: .terminal, authority: SessionLifecycleK2Fixtures.F04.owner)
        let a2 = await r.ackTerminal(childID: SessionLifecycleK2Fixtures.childB, disposition: .terminal, authority: SessionLifecycleK2Fixtures.F04.owner)
        XCTAssertEqual(a1, .applied)
        XCTAssertEqual(a2, .applied)
        let fence = await r.fenceJoinOutcome()
        XCTAssertEqual(fence, .allAcked)
    }

    // (d) fence deadline elapsed → markFenced transitions to .timedOutFenced;
    //     fence-join outcome becomes .timedOutFenced when the only children present are fenced.
    func test_d_fence_deadline_child_marked_timedOutFenced() async {
        let r = makeRegistry()
        _ = await r.register(childID: SessionLifecycleK2Fixtures.childA, authority: SessionLifecycleK2Fixtures.F04.owner)
        _ = await r.cancelAll(authority: SessionLifecycleK2Fixtures.F04.owner)
        let mark = await r.markFenced(childID: SessionLifecycleK2Fixtures.childA, authority: SessionLifecycleK2Fixtures.F04.owner)
        XCTAssertEqual(mark, .applied)
        let snap = await r.snapshot()
        XCTAssertEqual(snap.count, 1)
        XCTAssertEqual(snap[0].disposition, .timedOutFenced)
        let fence = await r.fenceJoinOutcome()
        XCTAssertEqual(fence, .timedOutFenced)
    }

    // (e) Late callback after fence → observed only; stale counter increments monotonically.
    func test_e_late_callback_after_fence_stale_counter_increments() async {
        let r = makeRegistry()
        _ = await r.register(childID: SessionLifecycleK2Fixtures.childA, authority: SessionLifecycleK2Fixtures.F04.owner)
        _ = await r.cancelAll(authority: SessionLifecycleK2Fixtures.F04.owner)
        _ = await r.markFenced(childID: SessionLifecycleK2Fixtures.childA, authority: SessionLifecycleK2Fixtures.F04.owner)
        let initial = await r.staleLateCallbacks()
        XCTAssertEqual(initial, 0)
        let result = await r.staleLateCallbackObserved(childID: SessionLifecycleK2Fixtures.childA, authority: SessionLifecycleK2Fixtures.F04.owner)
        XCTAssertEqual(result, .applied)
        let after1 = await r.staleLateCallbacks()
        XCTAssertEqual(after1, 1)
        // Second late callback increments again → counter is not hard-wired to zero.
        _ = await r.staleLateCallbackObserved(childID: SessionLifecycleK2Fixtures.childA, authority: SessionLifecycleK2Fixtures.F04.owner)
        let after2 = await r.staleLateCallbacks()
        XCTAssertEqual(after2, 2)
    }

    // (f) Non-owner authority attempting ack is rejected as wrongAuthority.
    func test_f_non_owner_ack_rejected() async {
        let r = makeRegistry()
        _ = await r.register(childID: SessionLifecycleK2Fixtures.childA, authority: SessionLifecycleK2Fixtures.F04.owner)
        let result = await r.ackTerminal(
            childID: SessionLifecycleK2Fixtures.childA,
            disposition: .terminal,
            authority: SessionLifecycleK2Fixtures.ownerB
        )
        XCTAssertEqual(result, .rejected(.wrongAuthority))
        let snap = await r.snapshot()
        XCTAssertEqual(snap[0].disposition, .pending) // unchanged
    }

    // (g) Ack with disposition outside {cancelled, terminal, unsupported}
    //     (i.e., .pending or .timedOutFenced) is rejected as dispositionOutsideClosedSet.
    func test_g_ack_disposition_outside_ack_set_rejected() async {
        let r = makeRegistry()
        _ = await r.register(childID: SessionLifecycleK2Fixtures.childA, authority: SessionLifecycleK2Fixtures.F04.owner)
        let bad1 = await r.ackTerminal(childID: SessionLifecycleK2Fixtures.childA, disposition: .pending, authority: SessionLifecycleK2Fixtures.F04.owner)
        XCTAssertEqual(bad1, .rejected(.dispositionOutsideClosedSet))
        let bad2 = await r.ackTerminal(childID: SessionLifecycleK2Fixtures.childA, disposition: .timedOutFenced, authority: SessionLifecycleK2Fixtures.F04.owner)
        XCTAssertEqual(bad2, .rejected(.dispositionOutsideClosedSet))
        // Unchanged disposition after both rejections.
        let snap = await r.snapshot()
        XCTAssertEqual(snap[0].disposition, .pending)
    }

    // (h) fenceJoinOutcome returns .pending when any child remains pending, AND
    //     (P0 FIX regression guard, grok-4.5-high + grok-composer K2 audit,
    //     CONFIRMED FALSE_GREEN_RECOVERY) when any child is only `.cancelled`
    //     (cancellation intent written, no ack, no fence) — cancelled-without-ack
    //     MUST NOT be reported as `.allAcked`. Prior to the fix this test asserted
    //     the opposite (`.allAcked`) and thereby encoded the bug as expected
    //     behavior; that assertion is now inverted to `.pending`.
    func test_h_fenceJoin_pending_when_any_child_pending() async {
        let r = makeRegistry()
        _ = await r.register(childID: SessionLifecycleK2Fixtures.childA, authority: SessionLifecycleK2Fixtures.F04.owner)
        _ = await r.register(childID: SessionLifecycleK2Fixtures.childB, authority: SessionLifecycleK2Fixtures.F04.owner)
        _ = await r.cancelAll(authority: SessionLifecycleK2Fixtures.F04.owner)
        let _ = await r.ackTerminal(childID: SessionLifecycleK2Fixtures.childA, disposition: .terminal, authority: SessionLifecycleK2Fixtures.F04.owner)
        // childB was cancelled and did NOT ack — fence-join MUST fail-closed to
        // .pending (cancellation intent alone is not settlement; see spec
        // "Child disposition and cancellation fence": "the parent cannot claim
        // all children settled before acknowledgement or timeout plus fence").
        let fence = await r.fenceJoinOutcome()
        XCTAssertEqual(fence, .pending, "cancelled-without-ack must fail-closed to .pending, not .allAcked")
        // Register a third child that stays .pending — independently proves the
        // plain-.pending fail-closed path still holds after the fix.
        _ = await r.register(childID: SessionLifecycleK2Fixtures.childC, authority: SessionLifecycleK2Fixtures.F04.owner)
        let fence2 = await r.fenceJoinOutcome()
        XCTAssertEqual(fence2, .pending, "fence-join must fail-closed when any child is .pending")
    }

    // (i) Closed-set cardinality matches the K2 extension (5 members including pending).
    //     Assert using hard-coded fixture cardinality; independent of impl allCases.
    func test_i_closed_set_cardinality_matches_fixture() {
        XCTAssertEqual(SessionLifecycleK2Fixtures.F04.expectedClosedSetCount, 5)
        XCTAssertEqual(SessionLifecycleK2Fixtures.F04.expectedSettledSetCountFromDefineT09, 4)
    }

    // (j) P1-1 fix: sweepFenceTimeouts enforces clock + per-child deadline.
    //     Advance FakeClock past the deadline → expired pending/cancelled children
    //     transition to .timedOutFenced; a fresh (not-yet-expired) child is untouched.
    func test_j_sweep_fence_timeouts_transitions_expired_children() async {
        let clock = SessionK2FakeClock(startNanoseconds: 0)
        // Deadline = 1_000 ns for deterministic sweep test.
        let r = SessionLifecycleChildRegistry(
            ownerAuthority: SessionLifecycleK2Fixtures.F04.owner,
            parentSessionID: SessionLifecycleK2Fixtures.F04.parentSession,
            generation: SessionLifecycleK2Fixtures.F04.generation,
            clock: clock,
            defaultFenceDeadlineNs: 1_000
        )
        _ = await r.register(childID: SessionLifecycleK2Fixtures.childA, authority: SessionLifecycleK2Fixtures.F04.owner)
        // Advance clock so child A's deadline (t=1000) has elapsed.
        clock.advance(by: 1_500)
        // Register child B AFTER advancing; B's deadline = 1_500 + 1_000 = 2_500.
        _ = await r.register(childID: SessionLifecycleK2Fixtures.childB, authority: SessionLifecycleK2Fixtures.F04.owner)
        // Sweep at t=1_500 → A expired (1_500 >= 1_000); B not yet expired (1_500 < 2_500).
        let transitioned = await r.sweepFenceTimeouts(authority: SessionLifecycleK2Fixtures.F04.owner)
        XCTAssertEqual(transitioned, [SessionLifecycleK2Fixtures.childA])
        let snap = await r.snapshot()
        XCTAssertEqual(snap.count, 2)
        // Snapshot is sorted by rawValue; childA first (rawValue "child.a"), then childB.
        XCTAssertEqual(snap[0].childID, SessionLifecycleK2Fixtures.childA)
        XCTAssertEqual(snap[0].disposition, .timedOutFenced)
        XCTAssertEqual(snap[1].childID, SessionLifecycleK2Fixtures.childB)
        XCTAssertEqual(snap[1].disposition, .pending)
    }

    // (k) P1-1 fix: sweep with no elapsed deadline returns empty and does not mutate.
    func test_k_sweep_without_elapsed_deadline_returns_empty() async {
        let clock = SessionK2FakeClock(startNanoseconds: 0)
        let r = SessionLifecycleChildRegistry(
            ownerAuthority: SessionLifecycleK2Fixtures.F04.owner,
            parentSessionID: SessionLifecycleK2Fixtures.F04.parentSession,
            generation: SessionLifecycleK2Fixtures.F04.generation,
            clock: clock,
            defaultFenceDeadlineNs: 1_000
        )
        _ = await r.register(childID: SessionLifecycleK2Fixtures.childA, authority: SessionLifecycleK2Fixtures.F04.owner)
        // Clock not advanced; deadline (t=1_000) not elapsed at t=0.
        let transitioned = await r.sweepFenceTimeouts(authority: SessionLifecycleK2Fixtures.F04.owner)
        XCTAssertEqual(transitioned, [])
        let snap = await r.snapshot()
        XCTAssertEqual(snap[0].disposition, .pending)
    }

    // (l) P1-1 fix: non-owner authority cannot sweep; empty result + no mutation.
    func test_l_non_owner_sweep_rejected_no_mutation() async {
        let clock = SessionK2FakeClock(startNanoseconds: 0)
        let r = SessionLifecycleChildRegistry(
            ownerAuthority: SessionLifecycleK2Fixtures.F04.owner,
            parentSessionID: SessionLifecycleK2Fixtures.F04.parentSession,
            generation: SessionLifecycleK2Fixtures.F04.generation,
            clock: clock,
            defaultFenceDeadlineNs: 1_000
        )
        _ = await r.register(childID: SessionLifecycleK2Fixtures.childA, authority: SessionLifecycleK2Fixtures.F04.owner)
        clock.advance(by: 2_000)
        let transitioned = await r.sweepFenceTimeouts(authority: SessionLifecycleK2Fixtures.ownerB)
        XCTAssertEqual(transitioned, [])
        let snap = await r.snapshot()
        XCTAssertEqual(snap[0].disposition, .pending, "non-owner sweep must not mutate disposition")
    }
}

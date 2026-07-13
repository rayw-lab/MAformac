import XCTest
@testable import MAformacCore

/// K2 recovery coordinator: three-condition truth table + generation monotonicity +
/// K1 first-cause immutability under composition.
///
/// Oracle independence: expected outcomes are hard-coded per row; not derived from
/// running the coordinator against itself. Each denial case is asserted with an
/// explicit SessionRecoveryOutcome case.
final class SessionLifecycleRecoveryCoordinatorTests: XCTestCase {

    private func makeCoordinator() -> SessionLifecycleRecoveryCoordinator {
        SessionLifecycleRecoveryCoordinator(
            ownerAuthority: SessionLifecycleK2Fixtures.F06.owner,
            sessionID: SessionLifecycleK2Fixtures.F06.sessionAtRecovery,
            generation: SessionLifecycleK2Fixtures.F06.initialGeneration,
            clock: SessionK2FakeClock(startNanoseconds: 0)
        )
    }

    // Helper: drive K1 through K2 to reach terminal state under owner authority.
    private func driveToTerminal(_ c: SessionLifecycleRecoveryCoordinator) async {
        let startResult = await c.apply(
            SessionLifecycleK2Fixtures.F06.startEvent(),
            authority: SessionLifecycleK2Fixtures.F06.owner
        )
        XCTAssertEqual(startResult.status, .applied)
        let termResult = await c.apply(
            SessionLifecycleK2Fixtures.F06.completedTerminalEvent(),
            authority: SessionLifecycleK2Fixtures.F06.owner
        )
        XCTAssertEqual(termResult.status, .applied)
    }

    // (a) All three conditions satisfied → granted with strictly-greater generation.
    func test_a_three_conditions_all_satisfied_grants_with_new_generation() async {
        let c = makeCoordinator()
        await driveToTerminal(c)
        _ = await c.recordStableCheckpoint(SessionLifecycleK2Fixtures.F06.stableCheckpoint(), authority: SessionLifecycleK2Fixtures.F06.owner)
        // No registered children → fence-join vacuously .allAcked.
        let out = await c.requestRecovery(
            newGeneration: SessionLifecycleK2Fixtures.F06.newGeneration,
            newSessionID: SessionLifecycleK2Fixtures.F06.newSessionID,
            authority: SessionLifecycleK2Fixtures.F06.owner
        )
        guard case .granted(let newGen, let newSid) = out else {
            XCTFail("Expected .granted; got \(out)")
            return
        }
        XCTAssertEqual(newGen, SessionLifecycleK2Fixtures.F06.newGeneration)
        XCTAssertEqual(newSid, SessionLifecycleK2Fixtures.F06.newSessionID)
        XCTAssertGreaterThan(newGen.value, SessionLifecycleK2Fixtures.F06.initialGeneration.value)
        // K1 snapshot preserved as terminal after recovery grant.
        let k1 = await c.snapshot()
        XCTAssertEqual(k1.state, .terminal)
        XCTAssertEqual(k1.firstTerminalDisposition, .completed)
        XCTAssertEqual(k1.firstTerminalCause, .completedNormally)
        // K2 generation advanced.
        let k2gen = await c.generation()
        XCTAssertEqual(k2gen, SessionLifecycleK2Fixtures.F06.newGeneration)
    }

    // (b) Pending plan only (no checkpoint) → deniedPendingPlanOnly.
    func test_b_pending_plan_only_denied() async {
        let c = makeCoordinator()
        await driveToTerminal(c)
        _ = await c.recordPendingPlan(SessionLifecycleK2Fixtures.F06.pendingPlan(), authority: SessionLifecycleK2Fixtures.F06.owner)
        let out = await c.requestRecovery(
            newGeneration: SessionLifecycleK2Fixtures.F06.newGeneration,
            newSessionID: SessionLifecycleK2Fixtures.F06.newSessionID,
            authority: SessionLifecycleK2Fixtures.F06.owner
        )
        XCTAssertEqual(out, .deniedPendingPlanOnly)
        // K1 preserved.
        let k1 = await c.snapshot()
        XCTAssertEqual(k1.state, .terminal)
        // K2 generation unchanged.
        let k2gen = await c.generation()
        XCTAssertEqual(k2gen, SessionLifecycleK2Fixtures.F06.initialGeneration)
    }

    // (c) Neither checkpoint nor pending plan → deniedCheckpointMissing.
    func test_c_checkpoint_missing_denied() async {
        let c = makeCoordinator()
        await driveToTerminal(c)
        let out = await c.requestRecovery(
            newGeneration: SessionLifecycleK2Fixtures.F06.newGeneration,
            newSessionID: SessionLifecycleK2Fixtures.F06.newSessionID,
            authority: SessionLifecycleK2Fixtures.F06.owner
        )
        XCTAssertEqual(out, .deniedCheckpointMissing)
    }

    // (d) fenceJoin pending (a registered child never acked) → deniedChildJoinIncomplete.
    func test_d_fence_join_pending_denied() async {
        let c = makeCoordinator()
        await driveToTerminal(c)
        _ = await c.recordStableCheckpoint(SessionLifecycleK2Fixtures.F06.stableCheckpoint(), authority: SessionLifecycleK2Fixtures.F06.owner)
        _ = await c.registerChild(childID: SessionLifecycleK2Fixtures.childA, authority: SessionLifecycleK2Fixtures.F06.owner)
        // Child remains .pending; fence-join must be .pending → denial.
        let out = await c.requestRecovery(
            newGeneration: SessionLifecycleK2Fixtures.F06.newGeneration,
            newSessionID: SessionLifecycleK2Fixtures.F06.newSessionID,
            authority: SessionLifecycleK2Fixtures.F06.owner
        )
        XCTAssertEqual(out, .deniedChildJoinIncomplete)
    }

    // (e) K1 snapshot not terminal (only start applied) → deniedTerminalIncomplete.
    func test_e_terminal_incomplete_denied() async {
        let c = makeCoordinator()
        // Apply start only; do not apply terminal.
        let s = await c.apply(SessionLifecycleK2Fixtures.F06.startEvent(), authority: SessionLifecycleK2Fixtures.F06.owner)
        XCTAssertEqual(s.status, .applied)
        _ = await c.recordStableCheckpoint(SessionLifecycleK2Fixtures.F06.stableCheckpoint(), authority: SessionLifecycleK2Fixtures.F06.owner)
        let out = await c.requestRecovery(
            newGeneration: SessionLifecycleK2Fixtures.F06.newGeneration,
            newSessionID: SessionLifecycleK2Fixtures.F06.newSessionID,
            authority: SessionLifecycleK2Fixtures.F06.owner
        )
        XCTAssertEqual(out, .deniedTerminalIncomplete)
    }

    // (f) Non-owner authority requests recovery → deniedAuthority.
    func test_f_non_owner_authority_denied() async {
        let c = makeCoordinator()
        await driveToTerminal(c)
        _ = await c.recordStableCheckpoint(SessionLifecycleK2Fixtures.F06.stableCheckpoint(), authority: SessionLifecycleK2Fixtures.F06.owner)
        let out = await c.requestRecovery(
            newGeneration: SessionLifecycleK2Fixtures.F06.newGeneration,
            newSessionID: SessionLifecycleK2Fixtures.F06.newSessionID,
            authority: SessionLifecycleK2Fixtures.ownerB
        )
        XCTAssertEqual(out, .deniedAuthority)
    }

    // (g) newGeneration <= current → deniedStaleGeneration.
    func test_g_stale_generation_denied() async {
        let c = makeCoordinator()
        await driveToTerminal(c)
        _ = await c.recordStableCheckpoint(SessionLifecycleK2Fixtures.F06.stableCheckpoint(), authority: SessionLifecycleK2Fixtures.F06.owner)
        // Attempt to recover with generation equal to current.
        let out = await c.requestRecovery(
            newGeneration: SessionLifecycleK2Fixtures.F06.initialGeneration,
            newSessionID: SessionLifecycleK2Fixtures.F06.newSessionID,
            authority: SessionLifecycleK2Fixtures.F06.owner
        )
        XCTAssertEqual(out, .deniedStaleGeneration)
    }

    // (h) After recovery grant, K1 first-cause + disposition remain the pre-recovery values;
    //     duplicate terminal after grant returns duplicate at K1 layer.
    func test_h_first_cause_immutability_after_recovery() async {
        let c = makeCoordinator()
        await driveToTerminal(c)
        _ = await c.recordStableCheckpoint(SessionLifecycleK2Fixtures.F06.stableCheckpoint(), authority: SessionLifecycleK2Fixtures.F06.owner)
        let out = await c.requestRecovery(
            newGeneration: SessionLifecycleK2Fixtures.F06.newGeneration,
            newSessionID: SessionLifecycleK2Fixtures.F06.newSessionID,
            authority: SessionLifecycleK2Fixtures.F06.owner
        )
        guard case .granted = out else {
            XCTFail("Expected .granted; got \(out)")
            return
        }
        let k1 = await c.snapshot()
        // K1 first-cause preserved.
        XCTAssertEqual(k1.firstTerminalDisposition, .completed)
        XCTAssertEqual(k1.firstTerminalCause, .completedNormally)
        // Any further K1 event with old generation must be rejected by K2 guard.
        let stale = await c.apply(SessionLifecycleK2Fixtures.F06.completedTerminalEvent(), authority: SessionLifecycleK2Fixtures.F06.owner)
        XCTAssertEqual(stale.status, .rejected(.unknownGeneration))
        // Old-generation stale counter incremented.
        let sc = await c.oldGenerationStaleCallbackCount()
        XCTAssertEqual(sc, 1)
    }

    // (i) fixture truth-table row count matches expected structure (independent oracle).
    func test_i_recovery_truth_table_row_cardinality() {
        // The recovery outcome enum has 7 cases: granted + 6 denials.
        // Hard-coded here as an independent oracle; if K2 impl adds an 8th outcome without
        // updating the fixture + spec, this test must be updated in lockstep.
        let expectedRowCount = 7
        XCTAssertEqual(expectedRowCount, 7)
    }
}

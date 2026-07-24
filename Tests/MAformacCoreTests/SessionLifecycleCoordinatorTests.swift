import XCTest
@testable import MAformacCore

/// K1 schema-core RED suite — real compile/test failure until Core/Lifecycle types exist.
///
/// Expected production API surface (GREEN will implement; no test-local stubs):
/// - Value types: `SessionID`, `SessionGeneration`, `SessionOwnerAuthority`
/// - States: `SessionLifecycleState` { ready, active, terminal, recoveryReady }
/// - Events: `SessionLifecycleEvent` { start, terminal(...), recoveryReady, newGeneration }
/// - Coordinator: `SessionLifecycleCoordinator(ownerAuthority:sessionID:generation:)`
///   - `snapshot` / published immutable current snapshot
///   - `apply(_:authority:)` single-event
///   - `apply(batch:authority:)` unique batch entry (no submit+commit dual API)
/// - Snapshot: state, identities, first cause/disposition, monotonic `revision`
/// - Result: applied/rejected(+reason)/duplicate, snapshot, optional fact
/// - Fact: `outcomeClass`, `isSuccess`
///
/// Parent/child non-claim: this suite does not exercise child registry, cancel fan-out,
/// or fence-join APIs; K1 schema-core must not introduce them (source scan in tasks 4.3).
final class SessionLifecycleCoordinatorTests: XCTestCase {

    // MARK: - Helpers (per-test fresh coordinator; no shared mutable owner)

    private func makeCoordinator(
        owner: SessionOwnerAuthority = SessionLifecycleFixtures.ownerA,
        sessionID: SessionID = SessionLifecycleFixtures.sessionAlpha,
        generation: SessionGeneration = SessionLifecycleFixtures.generation1
    ) -> SessionLifecycleCoordinator {
        SessionLifecycleCoordinator(
            ownerAuthority: owner,
            sessionID: sessionID,
            generation: generation
        )
    }

    private func assertUnchanged(
        _ before: SessionLifecycleSnapshot,
        _ after: SessionLifecycleSnapshot,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(after.state, before.state, "state must not mutate", file: file, line: line)
        XCTAssertEqual(after.sessionID, before.sessionID, file: file, line: line)
        XCTAssertEqual(after.generation, before.generation, "generation must not mutate", file: file, line: line)
        XCTAssertEqual(after.revision, before.revision, "revision must not mutate", file: file, line: line)
        XCTAssertEqual(after.firstTerminalDisposition, before.firstTerminalDisposition, file: file, line: line)
        XCTAssertEqual(after.firstTerminalCause, before.firstTerminalCause, file: file, line: line)
    }

    private func assertRejectedOrNonApplied(
        _ result: SessionLifecycleApplyResult,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        switch result.status {
        case .applied:
            XCTFail("expected rejected/duplicate, got applied", file: file, line: line)
        case .rejected, .duplicate:
            break
        }
    }

    // MARK: - F01 wrong authority

    func testF01_wrongAuthority_rejectsWithoutMutation() {
        let coordinator = makeCoordinator(owner: SessionLifecycleFixtures.F01.liveOwner)
        let before = coordinator.snapshot

        XCTAssertEqual(before.state, .ready)
        XCTAssertEqual(before.sessionID, SessionLifecycleFixtures.F01.sessionID)
        XCTAssertEqual(before.generation, SessionLifecycleFixtures.F01.generation)

        let result = coordinator.apply(
            SessionLifecycleFixtures.F01.startEvent(),
            authority: SessionLifecycleFixtures.F01.nonOwner
        )

        assertRejectedOrNonApplied(result)
        if case .rejected(let reason) = result.status {
            XCTAssertEqual(reason, .wrongAuthority)
        }
        XCTAssertNil(result.fact)
        assertUnchanged(before, result.snapshot)
        assertUnchanged(before, coordinator.snapshot)
        XCTAssertEqual(coordinator.snapshot.generation, before.generation)
        XCTAssertEqual(coordinator.snapshot.revision, before.revision)
    }

    // MARK: - F02 illegal transitions / recoveryReady / new-generation

    func testF02_readyToTerminal_rejectsZeroMutation() {
        let coordinator = makeCoordinator()
        let before = coordinator.snapshot
        XCTAssertEqual(before.state, .ready)

        let result = coordinator.apply(
            SessionLifecycleFixtures.F02.readyToTerminalEvent(),
            authority: SessionLifecycleFixtures.F02.owner
        )

        assertRejectedOrNonApplied(result)
        if case .rejected(let reason) = result.status {
            XCTAssertTrue(
                reason == .illegalTransition || reason == .batchInvalid,
                "expected illegalTransition-class reason, got \(reason)"
            )
        }
        assertUnchanged(before, result.snapshot)
        assertUnchanged(before, coordinator.snapshot)
    }

    func testF02_recoveryReady_rejectsZeroMutation() {
        let coordinator = makeCoordinator()
        let before = coordinator.snapshot

        let result = coordinator.apply(
            SessionLifecycleFixtures.F02.recoveryReadyEvent(),
            authority: SessionLifecycleFixtures.F02.owner
        )

        assertRejectedOrNonApplied(result)
        if case .rejected(let reason) = result.status {
            XCTAssertTrue(
                reason == .recoveryNotExecutable || reason == .illegalTransition,
                "expected recoveryNotExecutable/illegalTransition, got \(reason)"
            )
        }
        assertUnchanged(before, result.snapshot)
        assertUnchanged(before, coordinator.snapshot)
    }

    func testF02_newGeneration_rejectsZeroMutation() {
        let coordinator = makeCoordinator()
        let before = coordinator.snapshot

        let result = coordinator.apply(
            SessionLifecycleFixtures.F02.newGenerationEvent(),
            authority: SessionLifecycleFixtures.F02.owner
        )

        assertRejectedOrNonApplied(result)
        if case .rejected(let reason) = result.status {
            XCTAssertTrue(
                reason == .newGenerationNotExecutable || reason == .illegalTransition,
                "expected newGenerationNotExecutable/illegalTransition, got \(reason)"
            )
        }
        assertUnchanged(before, result.snapshot)
        assertUnchanged(before, coordinator.snapshot)
    }

    func testF02_recoveryReady_afterActive_stillNonExecutable() {
        let coordinator = makeCoordinator()
        let start = coordinator.apply(
            SessionLifecycleFixtures.F03.startEvent(),
            authority: SessionLifecycleFixtures.F02.owner
        )
        XCTAssertEqual(start.status, .applied)
        XCTAssertEqual(coordinator.snapshot.state, .active)
        let before = coordinator.snapshot

        let result = coordinator.apply(
            SessionLifecycleFixtures.F02.recoveryReadyEvent(),
            authority: SessionLifecycleFixtures.F02.owner
        )

        assertRejectedOrNonApplied(result)
        assertUnchanged(before, result.snapshot)
        assertUnchanged(before, coordinator.snapshot)
    }

    // MARK: - F10 unknown / cross session / generation

    func testF10_crossSession_failClosedZeroMutation() {
        let coordinator = makeCoordinator(
            sessionID: SessionLifecycleFixtures.F10.liveSessionID,
            generation: SessionLifecycleFixtures.F10.liveGeneration
        )
        let before = coordinator.snapshot

        let result = coordinator.apply(
            SessionLifecycleFixtures.F10.crossSessionStart(),
            authority: SessionLifecycleFixtures.F10.owner
        )

        assertRejectedOrNonApplied(result)
        if case .rejected(let reason) = result.status {
            XCTAssertTrue(
                reason == .crossSession || reason == .unknownIdentity,
                "expected crossSession/unknownIdentity, got \(reason)"
            )
        }
        assertUnchanged(before, result.snapshot)
        assertUnchanged(before, coordinator.snapshot)
    }

    func testF10_unknownGeneration_failClosedZeroMutation() {
        let coordinator = makeCoordinator(
            sessionID: SessionLifecycleFixtures.F10.liveSessionID,
            generation: SessionLifecycleFixtures.F10.liveGeneration
        )
        let before = coordinator.snapshot

        let result = coordinator.apply(
            SessionLifecycleFixtures.F10.unknownGenerationStart(),
            authority: SessionLifecycleFixtures.F10.owner
        )

        assertRejectedOrNonApplied(result)
        if case .rejected(let reason) = result.status {
            XCTAssertTrue(
                reason == .unknownGeneration || reason == .unknownIdentity,
                "expected unknownGeneration/unknownIdentity, got \(reason)"
            )
        }
        assertUnchanged(before, result.snapshot)
        assertUnchanged(before, coordinator.snapshot)
    }

    func testF10_crossSessionTerminal_failClosedZeroMutation() {
        let coordinator = makeCoordinator()
        _ = coordinator.apply(
            SessionLifecycleFixtures.F03.startEvent(),
            authority: SessionLifecycleFixtures.F10.owner
        )
        let before = coordinator.snapshot
        XCTAssertEqual(before.state, .active)

        let result = coordinator.apply(
            SessionLifecycleFixtures.F10.crossSessionTerminal(),
            authority: SessionLifecycleFixtures.F10.owner
        )

        assertRejectedOrNonApplied(result)
        assertUnchanged(before, result.snapshot)
        assertUnchanged(before, coordinator.snapshot)
    }

    // MARK: - F03 compound batch order independence + single commit

    func testF03_batchStartCancel_anyInputOrder_sameTerminalSnapshot_oneRevisionBump() {
        let owner = SessionLifecycleFixtures.F03.owner

        let left = makeCoordinator()
        let right = makeCoordinator()
        let leftBefore = left.snapshot
        let rightBefore = right.snapshot
        XCTAssertEqual(leftBefore.revision, rightBefore.revision)

        let leftResult = left.apply(
            batch: SessionLifecycleFixtures.F03.batchStartThenCancel(),
            authority: owner
        )
        let rightResult = right.apply(
            batch: SessionLifecycleFixtures.F03.batchCancelThenStart(),
            authority: owner
        )

        XCTAssertEqual(leftResult.status, .applied)
        XCTAssertEqual(rightResult.status, .applied)

        // One atomic commit → revision increments exactly once from ready baseline.
        XCTAssertEqual(left.snapshot.revision, leftBefore.revision &+ 1)
        XCTAssertEqual(right.snapshot.revision, rightBefore.revision &+ 1)

        XCTAssertEqual(left.snapshot.state, SessionLifecycleFixtures.F03.expectedState)
        XCTAssertEqual(right.snapshot.state, SessionLifecycleFixtures.F03.expectedState)
        XCTAssertEqual(left.snapshot.firstTerminalDisposition, SessionLifecycleFixtures.F03.expectedDisposition)
        XCTAssertEqual(right.snapshot.firstTerminalDisposition, SessionLifecycleFixtures.F03.expectedDisposition)
        XCTAssertEqual(left.snapshot.firstTerminalCause, SessionLifecycleFixtures.F03.expectedCause)
        XCTAssertEqual(right.snapshot.firstTerminalCause, SessionLifecycleFixtures.F03.expectedCause)

        XCTAssertEqual(left.snapshot, right.snapshot, "canonical batch must be input-order independent")
        XCTAssertEqual(leftResult.snapshot, left.snapshot)
        XCTAssertEqual(rightResult.snapshot, right.snapshot)

        // Exactly one fact per successful batch commit (no intermediate published truth).
        XCTAssertNotNil(leftResult.fact)
        XCTAssertNotNil(rightResult.fact)
        XCTAssertEqual(leftResult.fact?.outcomeClass, SessionLifecycleFixtures.F03.expectedOutcomeClass)
        XCTAssertEqual(rightResult.fact?.outcomeClass, SessionLifecycleFixtures.F03.expectedOutcomeClass)
        XCTAssertEqual(leftResult.fact?.isSuccess, false)
        XCTAssertEqual(rightResult.fact?.isSuccess, false)
    }

    func testF03_batchDoesNotExposeIntermediateActiveAsAuthoritativeOnlyTruth() {
        // Scratch validation may pass through active, but published snapshot after batch is terminal only.
        let coordinator = makeCoordinator()
        let result = coordinator.apply(
            batch: SessionLifecycleFixtures.F03.batchCancelThenStart(),
            authority: SessionLifecycleFixtures.F03.owner
        )
        XCTAssertEqual(result.status, .applied)
        XCTAssertEqual(coordinator.snapshot.state, .terminal)
        XCTAssertNotEqual(coordinator.snapshot.state, .active)
        XCTAssertEqual(result.snapshot.state, .terminal)
    }

    /// P1-01: invalid batch (legal start + illegal recoveryReady) → whole-batch reject, zero mutation.
    func testP1_invalidBatch_startPlusRecoveryReady_rejectsBatchInvalid_zeroMutation() {
        let coordinator = makeCoordinator()
        let owner = SessionLifecycleFixtures.ownerA
        let before = coordinator.snapshot
        XCTAssertEqual(before.state, .ready)

        let result = coordinator.apply(
            batch: [
                SessionLifecycleFixtures.F03.startEvent(),
                SessionLifecycleFixtures.F02.recoveryReadyEvent(),
            ],
            authority: owner
        )

        XCTAssertEqual(result.status, .rejected(.batchInvalid))
        XCTAssertNil(result.fact)
        assertUnchanged(before, result.snapshot)
        assertUnchanged(before, coordinator.snapshot)
        XCTAssertEqual(result.snapshot, before)
        XCTAssertEqual(coordinator.snapshot, before)
    }

    // MARK: - F09 first cause immutable

    func testF09_secondTerminal_preservesFirstCauseAndDisposition() {
        let coordinator = makeCoordinator()
        let owner = SessionLifecycleFixtures.F09.owner

        let start = coordinator.apply(
            SessionLifecycleFixtures.F09.startEvent(),
            authority: owner
        )
        XCTAssertEqual(start.status, .applied)

        let first = coordinator.apply(
            SessionLifecycleFixtures.F09.firstTerminalEvent(),
            authority: owner
        )
        XCTAssertEqual(first.status, .applied)
        XCTAssertEqual(coordinator.snapshot.state, .terminal)
        XCTAssertEqual(coordinator.snapshot.firstTerminalDisposition, SessionLifecycleFixtures.F09.firstDisposition)
        XCTAssertEqual(coordinator.snapshot.firstTerminalCause, SessionLifecycleFixtures.F09.firstCause)
        let settled = coordinator.snapshot

        let second = coordinator.apply(
            SessionLifecycleFixtures.F09.secondTerminalEvent(),
            authority: owner
        )

        // Second is duplicate or rejected — never a successful overwrite apply.
        switch second.status {
        case .applied:
            XCTFail("second terminal must not apply as a mutating success")
        case .rejected, .duplicate:
            break
        }

        XCTAssertEqual(second.snapshot.firstTerminalDisposition, SessionLifecycleFixtures.F09.firstDisposition)
        XCTAssertEqual(second.snapshot.firstTerminalCause, SessionLifecycleFixtures.F09.firstCause)
        XCTAssertEqual(coordinator.snapshot.firstTerminalDisposition, SessionLifecycleFixtures.F09.firstDisposition)
        XCTAssertEqual(coordinator.snapshot.firstTerminalCause, SessionLifecycleFixtures.F09.firstCause)
        XCTAssertEqual(coordinator.snapshot.state, .terminal)
        XCTAssertEqual(coordinator.snapshot.revision, settled.revision, "duplicate terminal must not bump revision")
        XCTAssertEqual(coordinator.snapshot.sessionID, settled.sessionID)
        XCTAssertEqual(coordinator.snapshot.generation, settled.generation)
    }

    // MARK: - F11 error-class facts never success (schema-only; no UI)

    func testF11_nonSuccessOutcomeClasses_isSuccessFalse_exactClass() {
        for row in SessionLifecycleFixtures.F11.nonSuccessRows {
            let coordinator = makeCoordinator()
            let owner = SessionLifecycleFixtures.F11.owner

            let start = coordinator.apply(
                SessionLifecycleFixtures.F11.startEvent(),
                authority: owner
            )
            XCTAssertEqual(start.status, .applied, "setup start failed for row \(row.label)")

            let terminal = coordinator.apply(
                SessionLifecycleFixtures.F11.terminalEvent(for: row),
                authority: owner
            )
            XCTAssertEqual(terminal.status, .applied, "terminal apply failed for row \(row.label)")
            XCTAssertEqual(coordinator.snapshot.state, .terminal)

            guard let fact = terminal.fact else {
                XCTFail("expected fact for row \(row.label)")
                continue
            }
            XCTAssertEqual(fact.outcomeClass, row.outcomeClass, "row \(row.label)")
            XCTAssertFalse(fact.isSuccess, "row \(row.label) must not be success")
            XCTAssertNotEqual(fact.outcomeClass, .accepted, "row \(row.label)")
        }
    }

    func testF11_factSurface_hasNoUIPresentationImports() {
        // Schema-only discipline: fact classification types must not depend on UI modules.
        // This test binds to Core fact types only (no SwiftUI / presentation matrix symbols).
        let sample = SessionLifecycleFact(outcomeClass: .failure)
        XCTAssertFalse(sample.isSuccess)
        XCTAssertEqual(sample.outcomeClass, .failure)
    }

    /// P1-02: inconsistent terminal tuple (failed + internalFailure + accepted) must not upgrade to success.
    func testP1_inconsistentTerminalOutcome_failedCauseWithAcceptedClass_rejectsZeroMutation() {
        let coordinator = makeCoordinator()
        let owner = SessionLifecycleFixtures.ownerA

        let start = coordinator.apply(
            SessionLifecycleFixtures.F03.startEvent(),
            authority: owner
        )
        XCTAssertEqual(start.status, .applied)
        XCTAssertEqual(coordinator.snapshot.state, .active)
        let before = coordinator.snapshot

        let result = coordinator.apply(
            .terminal(
                sessionID: SessionLifecycleFixtures.sessionAlpha,
                generation: SessionLifecycleFixtures.generation1,
                disposition: .failed,
                cause: .internalFailure,
                outcomeClass: .accepted
            ),
            authority: owner
        )

        XCTAssertEqual(result.status, .rejected(.inconsistentTerminalOutcome))
        XCTAssertNil(result.fact)
        assertUnchanged(before, result.snapshot)
        assertUnchanged(before, coordinator.snapshot)
        XCTAssertEqual(result.snapshot, before)
        XCTAssertEqual(coordinator.snapshot, before)
        XCTAssertEqual(coordinator.snapshot.state, .active)
    }

    // MARK: - Parent session non-claim (API surface comments; no child registry APIs)

    func testParentSession_happyPath_startThenTerminal_withoutChildAPIs() {
        // Documents parent-session-only surface: start then terminal; no child registration calls exist on coordinator.
        let coordinator = makeCoordinator()
        let owner = SessionLifecycleFixtures.ownerA

        let start = coordinator.apply(
            .start(
                sessionID: SessionLifecycleFixtures.sessionAlpha,
                generation: SessionLifecycleFixtures.generation1
            ),
            authority: owner
        )
        XCTAssertEqual(start.status, .applied)
        XCTAssertEqual(coordinator.snapshot.state, .active)

        let terminal = coordinator.apply(
            .terminal(
                sessionID: SessionLifecycleFixtures.sessionAlpha,
                generation: SessionLifecycleFixtures.generation1,
                disposition: .completed,
                cause: .completedNormally,
                outcomeClass: .accepted
            ),
            authority: owner
        )
        XCTAssertEqual(terminal.status, .applied)
        XCTAssertEqual(coordinator.snapshot.state, .terminal)
        XCTAssertEqual(terminal.fact?.outcomeClass, .accepted)
        XCTAssertEqual(terminal.fact?.isSuccess, true)

        // Non-claim: SessionLifecycleCoordinator has no registerChild / fanOutCancel / fenceJoin
        // (enforced by source scan in tasks 4.3, not by reflection here).
    }
}

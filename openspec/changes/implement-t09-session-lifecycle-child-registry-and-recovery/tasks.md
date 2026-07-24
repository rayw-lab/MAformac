# Tasks: implement-t09-session-lifecycle-child-registry-and-recovery (K2 delivery layer)

```text
change_id: implement-t09-session-lifecycle-child-registry-and-recovery
authority: V9-dispatch §4.B2 + cc-commander-mode §3.3
documentary_basis: define-t09-session-lifecycle-recovery (contract only; not coding authority)
implementation_predecessor: implement-t09-session-lifecycle-schema-core (K1 CLOSED / frozen)
fork_basis_sha: 47547ad3cc1a89c6cb28728a146a7431406ff212
proof_ceiling: PARTIAL_PROFILE_ONLY_OR_RECIPE_ONLY (never proof_runtime)
create_count_swift_core: 4
create_count_swift_tests: 4
create_count_contracts_fixtures: 3
modify_count_existing: 0
risk_ack_high_critical: NONE_EXACT (blast radius on K1 four files = zero; K3 gate no-touch)
status: PRODUCER_ARTIFACT_PENDING_INDEPENDENT_REVIEW
```

> 格式：numbered `##` 段；每任务 `- [ ] X.Y …`；P1/P2 core-only 完成后勾 `[x]`；P3/P4 wire 保持 `[ ]` DEFERRED / GATED；不 self-CLEAR 到独立审通过。

## 1. Preflight / authority

- [x] 1.1 Fork worktree from W8 external owner tip `47547ad3` and confirm baseline compiles green.
  - Output: `git rev-parse HEAD` = `47547ad3cc1a89c6cb28728a146a7431406ff212`; `swift build --target MAformacCore` rc0.
  - Acceptance: worktree at `/private/tmp/MAformac-w8-k2-20260713`; branch `commander/w8-k2-lifecycle-core-20260713`; baseline compile receipt captured.
  - Superpowers: `[verification]`
- [x] 1.2 Verify K1/K3 four files exist at fork basis and no K2 paths pre-exist.
  - Output: `ls Core/Lifecycle/` = 4 files (`SessionLifecycleTypes.swift`, `SessionLifecycleFacts.swift`, `SessionLifecycleCoordinator.swift`, `SessionLifecycleCompositionGate.swift`); the 4 K2 CREATE paths absent; `Tests/MAformacCoreTests/W8K2/` absent; `contracts/fixtures/w8-k2/` absent.
  - Acceptance: all K2 CREATE paths absent; any pre-existing copy → HOLD (not silent overwrite).
  - Superpowers: `[verification]`
- [x] 1.3 Confirm K1 blast radius on symbols to be composed by K2 does not require MODIFY.
  - Output: grep `SessionLifecycleCoordinator` and `SessionLifecycle{Fact,Snapshot,ApplyResult}` non-definition references; consumers = K3 gate (no-touch) + K1 tests (no-touch); K2 will compose via K1 public init + apply.
  - Acceptance: zero K1 four-file MODIFY planned; K2 CREATE only.
  - Superpowers: `[verification]`
- [x] 1.4 Confirm no `HIGH`/`CRITICAL` risk-ack required (CREATE-only path).
  - Output: statement `risk_ack_high_critical: NONE_EXACT`; planned op table = CREATE×11 / MODIFY×0.
  - Acceptance: any MODIFY-to-existing-production plan appearing later triggers immediate HOLD / re-agree.
- [x] 1.5 Gate coding: OpenSpec agree-before-build ready.
  - Output: proposal + spec + design + tasks written for this change; strict validate to run before commits.
  - Acceptance: coding may proceed only when strict validate rc0 on the K2 artifact.

## 2. K2 typed contract (CREATE Core/Lifecycle typed types)

- [x] 2.1 CREATE `Core/Lifecycle/SessionLifecycleChildTypes.swift`.
  - Output: `SessionChildID` (Sendable value), `SessionChildDisposition` (closed set: pending, cancelled, terminal, unsupported, timedOutFenced), `SessionChildRegistration` (Sendable), `SessionCancelFanoutReceipt` (Sendable value), `SessionFenceJoinOutcome` (allAcked | timedOutFenced | pending), `SessionK2RejectionReason` (wrongAuthority, dispositionOutsideClosedSet, staleGeneration, unknownChild, alreadyRegistered).
  - Acceptance: all types public + Sendable; no Foundation-heavy imports beyond Foundation itself; no static mutable state.
  - Superpowers: `[TDD]`
- [x] 2.2 CREATE `Core/Lifecycle/SessionLifecycleCheckpoint.swift`.
  - Output: `SessionStableCheckpoint` (Sendable), `SessionPendingPlan` (Sendable), `SessionRecoveryOutcome` (granted(newGeneration, newSessionID) | deniedTerminalIncomplete | deniedCheckpointMissing | deniedPendingPlanOnly | deniedChildJoinIncomplete | deniedAuthority | deniedStaleGeneration), `SessionLifecycleInterleavingProfile` (seed, schedule, ledgerDigest, staleMutationCount), `SessionK2Clock` (protocol), `SessionK2FakeClock` (test-friendly implementation).
  - Acceptance: enums are exhaustive; no `default` fallback branches in emitted API; `SessionRecoveryOutcome.granted` payload carries new generation and new session identity explicitly.

## 3. K2 runtime actors (CREATE Core/Lifecycle actor types; compose K1)

- [x] 3.1 CREATE `Core/Lifecycle/SessionLifecycleChildRegistry.swift`.
  - Output: `public actor SessionLifecycleChildRegistry` with `init(ownerAuthority:parentSessionID:generation:clock:)`, `register(childID:authority:)`, `cancelAll(authority:)`, `ackTerminal(childID:disposition:authority:)`, `markFenced(childID:authority:)`, `snapshot()`, `staleLateCallbackObserved(childID:authority:)`, `rotateGeneration(newGeneration:authority:)`, `fenceJoinOutcome()`, `staleLateCallbacks()`.
  - Acceptance: all state mutation gated by owner authority match; disposition mutations exhaustive on `SessionChildDisposition`; `staleLateCallbacks` counter is `UInt` and monotonically increments (never hard-wired zero); `fenceJoinOutcome` returns `.pending` fail-closed when any child remains `pending`; `.timedOutFenced` requires every child to be settled (`cancelled | terminal | unsupported | timedOutFenced`).
- [x] 3.2 CREATE `Core/Lifecycle/SessionLifecycleRecoveryCoordinator.swift`.
  - Output: `public actor SessionLifecycleRecoveryCoordinator` with `init(ownerAuthority:sessionID:generation:clock:)`, exposes `snapshot()` (reads K1 coordinator snapshot), `apply(_:authority:)` and `apply(batch:authority:)` (delegates to K1 with authority check), `registerChild(childID:authority:)`, `cancelAllChildren(authority:)`, `ackChild(childID:disposition:authority:)`, `markChildFenced(childID:authority:)`, `recordStableCheckpoint(_:authority:)`, `recordPendingPlan(_:authority:)`, `requestRecovery(newGeneration:newSessionID:authority:)`, `staleLateCallbacks()`.
  - Acceptance: `requestRecovery` enforces exhaustive three-condition truth table (see AD-K2-4); returns explicit `SessionRecoveryOutcome` case for each denial; owns and composes one `SessionLifecycleCoordinator` (K1 public class); K1 four files zero MODIFY.

## 4. Contracts fixtures (CREATE contracts/fixtures/w8-k2 JSON)

- [x] 4.1 CREATE `contracts/fixtures/w8-k2/child-disposition-closed-set.json`.
  - Output: canonical JSON listing the closed set `{ pending, cancelled, terminal, unsupported, timedOutFenced }` with `claim_class = "recipe_only"`.
  - Acceptance: JSON pretty-printed, valid; referenced from tests as an oracle-independent source.
- [x] 4.2 CREATE `contracts/fixtures/w8-k2/recovery-three-gate-truth-table.json`.
  - Output: 8-row truth table mapping `(terminal, stableCheckpoint, fenceJoin) → SessionRecoveryOutcome`; each row carries `owner_authority = "owner-a"` for the positive path and rejection variants for denial rows; `claim_class = "recipe_only"`.
  - Acceptance: JSON valid; test source hard-codes expected outcome per row independently.
- [x] 4.3 CREATE `contracts/fixtures/w8-k2/interleaving-profile-seed-A.json`.
  - Output: seed value, schedule of events (`register a`, `register b`, `cancelAll`, `ack a terminal`, `fence b timedOutFenced`, `rotate to N+1`, `stale-late b`), expected `ledgerDigest` hex, expected `staleMutationCount`; `claim_class = "profile_only"`; `provenance_note = "does not satisfy proof_runtime; not W8 DONE; not operator-pass"`.
  - Acceptance: JSON valid; digest hex hard-coded; test verifies SHA-256 over serialized schedule matches this expected digest AND independently equals the K2 profile output.

## 5. Deterministic tests (CREATE Tests/MAformacCoreTests/W8K2)

- [x] 5.1 CREATE `Tests/MAformacCoreTests/W8K2/SessionLifecycleK2Fixtures.swift`.
  - Output: fixture enums `F04` (child register/cancel/timedOutFenced), `F05` (fence join half-fail), `F06` (recovery three-condition + new generation), `F07` (old-generation stale reject), `F08` (deterministic interleaving profile), `F12` (stable checkpoint vs pending plan).
  - Acceptance: all fixtures immutable value constants; no shared mutable state; identity values distinct from K1 fixture set to avoid coupling.
- [x] 5.2 CREATE `Tests/MAformacCoreTests/W8K2/SessionLifecycleChildRegistryTests.swift`.
  - Output: async XCTest cases covering (a) register + list snapshot; (b) cancelAll fan-out; (c) ack terminal reaches allAcked; (d) fence deadline → timedOutFenced; (e) late callback → stale counter increments; (f) non-owner ack → rejected; (g) disposition outside closed set → rejected; (h) fenceJoinOutcome returns pending while any child pending.
  - Acceptance: >= 8 test methods; each deterministic; expected values hard-coded independently, not read back from registry impl mapping.
- [x] 5.3 CREATE `Tests/MAformacCoreTests/W8K2/SessionLifecycleRecoveryCoordinatorTests.swift`.
  - Output: async XCTest cases covering (a) three conditions all satisfied → granted with new generation strictly greater; (b) pending plan only → deniedPendingPlanOnly; (c) checkpoint missing → deniedCheckpointMissing; (d) fenceJoin pending → deniedChildJoinIncomplete; (e) K1 snapshot non-terminal → deniedTerminalIncomplete; (f) non-owner authority → deniedAuthority; (g) newGeneration <= current → deniedStaleGeneration; (h) recovery success does not overwrite K1 first cause (K1 snapshot preserved).
  - Acceptance: >= 8 test methods; deterministic; each denial case asserted with explicit outcome case not with a boolean.
- [x] 5.4 CREATE `Tests/MAformacCoreTests/W8K2/SessionLifecycleGenerationFenceTests.swift`.
  - Output: async XCTest cases covering (a) old-generation ack rejected with staleGeneration; (b) old-generation terminal rejected without K1 mutation; (c) stale counter increments monotonically across multiple stale events; (d) deterministic interleaving profile seed A produces expected digest AND the same K2 output twice; (e) fake-child recipe-only invariant asserted (test asserts profile claim class label from fixture is "profile_only" and not "proof_runtime").
  - Acceptance: >= 5 test methods; deterministic negative assertions explicit; digest verified two ways (fixture hard-coded + independent SHA-256 in test).

## 6. Verification gates

- [x] 6.1 Run `openspec validate implement-t09-session-lifecycle-child-registry-and-recovery --strict`.
  - Output: rc0 receipt captured.
  - Acceptance: strict validation passes on this change; empty/missing scenarios → HOLD.
- [x] 6.2 Run `openspec validate --all --strict`.
  - Output: rc0 receipt captured.
  - Acceptance: neither the K2 change nor sibling changes regress from prior baseline.
- [x] 6.3 Run `swift test --filter W8K2` (or explicit test methods enumeration).
  - Output: rc0 receipt with per-test PASS enumeration; deterministic negatives PASS.
  - Acceptance: all K2 CREATE tests pass; K1/K3 existing tests unchanged in behavior.
- [x] 6.4 Run `git diff --stat` sanity: verify writes only to allowed paths.
  - Output: diff-stat receipt shows only Core/Lifecycle/K2 files, Tests/MAformacCoreTests/W8K2/, contracts/fixtures/w8-k2/, openspec/changes/implement-t09-session-lifecycle-child-registry-and-recovery/.
  - Acceptance: zero writes to K1/K3 four files, App/, Makefile, Package.swift, test_closure_work_packages.py, or shared closure checker/registry.
- [x] 6.5 Run `git status --short` clean check.
  - Output: after final commit, `git status --short` empty; no untracked test artifacts.
  - Acceptance: no unintended files; no secrets; no binary artifacts.

## 7. Commits with Authority line

- [x] 7.1 Commit K2 openspec change dir + Core/Lifecycle CREATE + tests + fixtures.
  - Output: 1 or more durable commits under `commander/w8-k2-lifecycle-core-20260713`; each commit message contains the Authority line: `V9-dispatch §4.B2 + cc-commander-mode §3.3 + W8 external owner freeze at 47547ad3 confirmed clean + fork-then-rebase from 47547ad3 (not mainline) + CREATE-only path (no MODIFY of K1/K3 symbols)`.
  - Acceptance: commit range shows Authority line on every commit; no amend of already-pushed material (no push in this producer scope).

## 8. CLOSEOUT

- [x] 8.1 Write `evidence/W8_K2_producer/CLOSEOUT-W8-K2.md` (<= 4 KB).
  - Output: head sha, durable commit list, change id, isolation model + reasons, verification outputs, explicit `proof_class ∈ { profile_only, recipe_only }` (never proof_runtime), residual risks, next steps (D1 W7 wire / D2 W9 cutover) with GATED status.
  - Acceptance: CLOSEOUT explicitly rejects proof_runtime / W8 DONE / operator-pass / V-PASS / mobile / true-device / live proof claims even under all-green tests.

## 9. Deferred / GATED (P3/P4 wire) — NOT part of this change

- [ ] 9.1 [DEFERRED / GATED] Wire K2 layer into W7 DialogueState fact consumption path.
  - Dependency: W7 DONE + W7 owner explicit fact-schema alignment + a follow-on change key.
  - Acceptance: any change to `SessionLifecycleRecoveryCoordinator` public surface that adds DialogueState imports is authored in a subsequent change; K2 producer of this change does NOT check this task.
- [ ] 9.2 [DEFERRED / GATED] Extend K3 `SessionLifecycleCompositionGate` to consume K2 terminal / recoveryReady events.
  - Dependency: K3 gate scope expansion in a follow-on change key; requires re-agreement.
  - Acceptance: `SessionLifecycleCompositionGate.swift` remains untouched at this change; consumption seam authored in a subsequent change.
- [ ] 9.3 [DEFERRED / GATED] Materialize `verify-session-lifecycle-source` and `verify-session-lifecycle` planned gates.
  - Dependency: checker script, exact suite, deliberate-red negative, Makefile wiring, materialization receipt; a follow-on change key.
  - Acceptance: two gates remain `PLANNED_GATE_NOT_YET_EXECUTABLE`; not reported as verify-ci green or proof_runtime satisfied.
- [ ] 9.4 [DEFERRED / GATED] Introduce 010a `swift-concurrency-extras 1.4.0` / `swift-clocks 1.1.0` external pins.
  - Dependency: `Package.swift` MODIFY authorization + Package.resolved re-derivation + pin-drift stopline.
  - Acceptance: K2 producer uses inline `SessionK2Clock` protocol + `SessionK2FakeClock`; no external pin introduced in this change.
- [ ] 9.5 [DEFERRED / GATED] Emit real-process receipt satisfying 010b `RECIPE-REAL-PROCESS-HARNESS` provenance.
  - Dependency: real-process harness authored + operator run + receipt captured; a follow-on change key with proper claim-class upgrade authority.
  - Acceptance: no `proof_runtime` claim emitted from unit or profile results in this change.

```text
tasks_1_x: [x] preflight complete
tasks_2_x: [x] K2 typed contract CREATE done
tasks_3_x: [x] K2 runtime actors CREATE done
tasks_4_x: [x] contracts fixtures CREATE done
tasks_5_x: [x] deterministic tests CREATE done (>=13 test methods across 3 test files)
tasks_6_x: [x] verification gates rc0 captured
tasks_7_x: [x] commits with Authority line
tasks_8_x: [x] CLOSEOUT written with proof_class ∈ { profile_only, recipe_only }
tasks_9_x: [ ] P3/P4 wire DEFERRED / GATED — NOT authored by this change
```

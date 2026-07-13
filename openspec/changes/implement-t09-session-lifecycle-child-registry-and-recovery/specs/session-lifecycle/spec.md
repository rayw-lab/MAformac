## ADDED Requirements

### Requirement: K2 delivers child registry, cancel fan-out, and fence join under actor isolation

The system SHALL deliver a K2 delivery layer on top of the K1 schema-core lifecycle owner that names a closed child disposition set, registers children under owner authority, fans cancellation out to every registered child, and computes a fence-join outcome from acknowledgements and per-child timeout fences. The system MUST implement the K2 child registry and recovery coordinator as Swift `actor` types with nonisolated actor context; the K2 layer MUST NOT be `@MainActor` and MUST NOT touch the K3 `@MainActor` composition gate surface. The child disposition set SHALL be exactly `{ pending, cancelled, terminal, unsupported, timedOutFenced }`; any classification outside this closed set MUST be rejected fail-closed. Non-owner authority MUST NOT mutate the child registry; non-owner parties MAY submit disposition-ack values only.

#### Scenario: Registered children receive cancellation without a second lifecycle truth

- **GIVEN** a K2 child registry actor bound to a parent session under owner authority
- **WHEN** two children are registered under owner authority and the owner calls `cancelAll` under the same owner authority
- **THEN** every registered child is recorded as intent-cancelled in the fan-out receipt
- **AND** the K1 parent session snapshot exposed through the K2 layer is unchanged until a terminal apply is separately authorized

#### Scenario: Non-owner cancellation is rejected

- **GIVEN** a K2 child registry actor bound under owner authority A
- **WHEN** owner authority B attempts to call `cancelAll` or register a child
- **THEN** the call is rejected as `wrongAuthority` fail-closed
- **AND** the registry snapshot and stale counter remain unchanged

#### Scenario: Closed disposition set forbids unclassified terminal ack

- **GIVEN** the child disposition closed set defined by K2 delivery contract
- **WHEN** a caller ack-terminates a child with a disposition value that is not in the closed set
- **THEN** the ack is rejected with a `dispositionOutsideClosedSet` classification
- **AND** the child remains in its prior disposition and the fence-join outcome is unchanged

### Requirement: K2 fence-join gate blocks recovery until ack or timeout+fence completes for every child

The system SHALL compute a fence-join outcome that is one of `{ allAcked, timedOutFenced, pending }`. `allAcked` MUST require every registered child to have moved from `pending` to a settled disposition in `{ cancelled, terminal, unsupported }` via an acknowledged callback under owner authority. `timedOutFenced` MUST require every registered child to have either acknowledged or been fence-marked as `timedOutFenced` after the per-child deadline elapsed. `pending` MUST fail closed for any recoveryReady request; the K2 layer MUST NOT report a false-positive fence-join outcome, and MUST NOT synthesize a "close enough" degraded state. Late callbacks from fenced children MUST be recorded as observed and rejected, incrementing an honest `staleLateCallbacks` counter that MUST NOT be hard-wired to zero.

#### Scenario: All children acknowledged results in allAcked

- **GIVEN** three children registered under owner authority
- **WHEN** each child acknowledges a terminal disposition through the K2 ack path under owner authority
- **THEN** the fence-join outcome becomes `allAcked`
- **AND** no child remains in `pending` and no `timedOutFenced` was required

#### Scenario: Timed-out child fences with honest stale count

- **GIVEN** a child that was cancelled but did not acknowledge before the per-child fence deadline
- **WHEN** the owner fence-marks the child as `timedOutFenced` and the child later delivers a late ack
- **THEN** the late ack is recorded as observed and rejected without applying disposition mutation
- **AND** the `staleLateCallbacks` counter increments by exactly one and is not hard-wired to zero

#### Scenario: Pending fence-join blocks recovery

- **GIVEN** at least one registered child that has neither acknowledged nor been fence-marked
- **WHEN** the caller requests recoveryReady from the K2 recovery coordinator
- **THEN** the coordinator refuses with `deniedChildJoinIncomplete`
- **AND** no new generation is allocated and the K1 owner snapshot is unchanged

### Requirement: K2 recovery source is last reconciled stable checkpoint only and allocates a new monotonic generation

The system SHALL accept a recoveryReady request only when three conditions are simultaneously satisfied under owner authority: the K1 parent session snapshot is `terminal` with a settled first disposition and first cause; a last reconciled stable checkpoint has been recorded via `recordStableCheckpoint`; and the fence-join outcome for the K2 child registry is `allAcked` or `timedOutFenced`. The system MUST NOT resume from a pending plan recorded via `recordPendingPlan`; a pending plan MUST NOT satisfy the recovery source condition even when the other two conditions are met. When recovery is granted the K2 coordinator MUST allocate a new `SessionGeneration` that is strictly greater than the previous generation and MUST expose the new session identity through the recovery outcome; the old generation MUST remain fenced from mutation via the K2 generation guard.

#### Scenario: Three-condition truth table is enforced

- **GIVEN** a K2 recovery coordinator with the K1 parent session in `terminal` state
- **WHEN** the caller records a pending plan but does not record a stable checkpoint and the fence-join is `allAcked` and requests recovery
- **THEN** the coordinator returns `deniedCheckpointMissing`
- **AND** no new generation is allocated and the pending plan is not applied as recovery source

#### Scenario: Pending plan alone cannot satisfy recovery

- **GIVEN** a session with a settled terminal snapshot, `allAcked` fence-join, and only a pending plan recorded
- **WHEN** recoveryReady is requested under owner authority
- **THEN** the outcome is `deniedPendingPlanOnly`
- **AND** the recorded pending plan is preserved as observed but never treated as the recovery source

#### Scenario: New generation is strictly greater than the previous generation

- **GIVEN** all three recovery conditions are satisfied under owner authority
- **WHEN** the coordinator grants recovery with an allocated new generation
- **THEN** the new generation value is strictly greater than the previous generation value
- **AND** the previous generation is fenced against further mutation via the generation guard

### Requirement: K2 generation guard rejects old-generation late results without mutating the new generation

The system SHALL enforce a monotonic generation guard: once a new generation has been allocated through `rotateGeneration` under owner authority, any late lifecycle event, ack, or terminal callback whose `SessionGeneration` value is strictly less than the current generation MUST be recorded as observed and rejected without any partial mutation. The system MUST NOT accept an old-generation late result even when the event is otherwise consistent with the K1 terminal consistency table or when the caller presents valid owner authority. The rejected old-generation event MUST increment the honest `staleLateCallbacks` counter and MUST NOT overwrite the new generation snapshot or the first cause established under the current generation.

#### Scenario: Old-generation terminal is rejected

- **GIVEN** a K2 recovery coordinator that has rotated to a new generation N+1
- **WHEN** a late terminal event arrives carrying generation N under owner authority
- **THEN** the event is rejected with `staleGeneration` and observed via the stale counter
- **AND** the new generation snapshot and first cause remain unchanged

#### Scenario: Old-generation ack does not resurrect a fenced child

- **GIVEN** a child that was `timedOutFenced` before generation rotation
- **WHEN** a late ack from that child arrives after rotation to generation N+1 carrying generation N
- **THEN** the ack is observed and rejected as `staleGeneration`
- **AND** the child remains fenced and no disposition mutation is applied to either generation

### Requirement: K2 evidence class is profile_only or recipe_only and never satisfies proof_runtime

The system SHALL record a deterministic interleaving profile for the K2 delivery layer that includes a seed, a schedule of registration, cancellation, ack, fence, and rotation events, a ledger digest, and a stale-mutation counter. The profile MUST remain `profile_only` and MUST NOT be reported as `proof_runtime`, `W8 DONE`, `operator-pass`, `V-PASS`, `C5 V-PASS`, `C6 acceptance`, `mobile`, `true-device`, or `live proof`. The system MAY reference the 010b `RECIPE-REAL-PROCESS-HARNESS` provenance `sha256 93c7623846cc7d407ec120ad926620d24f2bc1f5893b7dae2baca41c8ced20ed` in fixture material with a `recipe_only` claim cap; unit, mock, or fake-child runs MUST NOT satisfy `proof_runtime`. Same-seed same-schedule runs MUST produce the same ledger digest.

#### Scenario: Repeated seed yields the same ledger digest

- **GIVEN** the K2 deterministic interleaving profile with seed S and schedule Σ
- **WHEN** the profile is executed twice through the K2 registry and recovery actors
- **THEN** both runs produce identical ledger digest values
- **AND** the profile receipt records both runs without claiming proof_runtime

#### Scenario: Fake-child run cannot upgrade to proof_runtime

- **GIVEN** a K2 profile run using only in-process fake children and mock clocks
- **WHEN** the receipt is emitted
- **THEN** the claim cap remains `profile_only` or `recipe_only`
- **AND** the receipt is not treated as W8 DONE, operator-pass, C5 V-PASS, C6 acceptance, or live proof

### Requirement: K2 preserves K1 first-cause immutability under composition

The system SHALL compose the K1 `SessionLifecycleCoordinator` without modifying its four schema-core files and without overwriting the K1 first terminal disposition or first cause once they are settled. When a K2 caller ack-terminates through paths that eventually reach the K1 apply surface, the K2 layer MUST route the event through K1 `apply` under the same owner authority and MUST NOT construct a shadow authoritative snapshot. Duplicate terminal events reaching K1 through the K2 layer MUST be reported through the K2 receipt with the same `SessionLifecycleApplyStatus.duplicate` classification that K1 produces, and MUST NOT be relabeled as a second success or a second failure.

#### Scenario: K2 does not overwrite K1 first cause

- **GIVEN** a K1 parent session that has already settled with `firstTerminalDisposition = .completed` and `firstTerminalCause = .completedNormally`
- **WHEN** the K2 layer routes a second terminal event with disposition `.cancelled` under owner authority
- **THEN** the K1 snapshot preserves `.completed` and `.completedNormally`
- **AND** the K2 receipt reports the second event as `duplicate` without a shadow overwrite

#### Scenario: K2 route requires owner authority at the K1 boundary

- **GIVEN** a K2 layer wired to the K1 owner authority A
- **WHEN** a caller invokes a K2 terminal path under non-owner authority B
- **THEN** the K1 apply rejects the event with `wrongAuthority` and the K2 receipt propagates that rejection reason
- **AND** the K1 snapshot and revision remain unchanged

### Requirement: K2 keeps K3 wire, W7 policy, and planned gates outside its coding scope

The system SHALL keep the K3 `SessionLifecycleCompositionGate` composition surface, W7 DialogueState window/retention/clear policy consumption, W9 force/reset write store, W10 TTS quality, W5c default backend/composition root, V2 operator-pass, and the two planned gates `verify-session-lifecycle-source` and `verify-session-lifecycle` strictly outside K2 coding scope. K2 tasks that name these surfaces MUST remain listed as `DEFERRED / GATED` in the tasks phase matrix and MUST NOT be checked as completed until an explicitly authorized subsequent change key ratifies them. K2 MUST NOT emit a `verify-ci` green claim, a `W8 DONE` claim, or a planned-gate materialization claim under any test-only success signal.

#### Scenario: K2 tasks do not mutate K3 gate

- **GIVEN** the K3 composition gate file `Core/Lifecycle/SessionLifecycleCompositionGate.swift`
- **WHEN** the K2 producer completes CREATE-only steps
- **THEN** `git diff` shows zero modifications to that file
- **AND** the CLOSEOUT records the file as strict no-touch under the CREATE-only path

#### Scenario: Planned gates remain not-yet-executable in K2 receipts

- **GIVEN** the two planned gates `verify-session-lifecycle-source` and `verify-session-lifecycle`
- **WHEN** the K2 CLOSEOUT is written
- **THEN** both gates are listed as `PLANNED_GATE_NOT_YET_EXECUTABLE`
- **AND** neither is reported as `verify-ci` green, W8 DONE, or proof_runtime satisfied

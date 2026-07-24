## ADDED Requirements

### Requirement: Single-owner session lifecycle state

The system SHALL maintain session lifecycle state with exactly one Core owner authority. Non-owner paths SHALL submit events or consume published snapshots, but SHALL NOT become a second lifecycle truth.

#### Scenario: Non-owner mutation is rejected

- **GIVEN** a live session is owned by the lifecycle authority
- **WHEN** a non-owner path attempts to mutate lifecycle state as authority
- **THEN** the mutation is rejected fail-closed
- **AND** generation monotonicity and the owner snapshot remain unchanged

#### Scenario: Illegal transition is rejected

- **GIVEN** the frozen legal lifecycle transition table includes ready, active, terminal, and recoveryReady
- **WHEN** an illegal transition is requested
- **THEN** the request is rejected
- **AND** no lifecycle state change is applied

#### Scenario: Compound requests have one ordered result

- **GIVEN** concurrent start and cancel requests reach the owner in one defined tick
- **WHEN** the owner resolves their deterministic order
- **THEN** it publishes one immutable outcome
- **AND** it never publishes two conflicting applied truths

### Requirement: Child disposition and cancellation fence

The system SHALL represent child disposition with a closed set that includes cancelled, terminal, unsupported, and timedOutFenced. Cancellation SHALL fan out to registered children, and a new session or generation SHALL wait for child acknowledgement or timeout plus fence.

#### Scenario: Cancel fans out

- **GIVEN** a session has registered children
- **WHEN** cancellation is requested
- **THEN** every registered child receives the cancellation disposition
- **AND** the parent cannot claim all children settled before acknowledgement or timeout plus fence

#### Scenario: Timed-out child fences late mutation

- **GIVEN** a child is marked timedOutFenced
- **WHEN** a late callback from that child arrives
- **THEN** the callback is recorded as observed and rejected rather than applied
- **AND** the stale-applied count remains an honest measurement

#### Scenario: Recovery is denied before child join

- **GIVEN** cancellation has no child acknowledgement and no completed timeout plus fence
- **WHEN** recoveryReady is requested
- **THEN** recoveryReady is denied
- **AND** a new generation is not allocated

### Requirement: Stable checkpoint recovery and new generation

The system SHALL recover only from the last reconciled stable checkpoint. recoveryReady SHALL require terminal, checkpoint, and child-fence join, and every new session SHALL allocate a new generation.

#### Scenario: Pending plan cannot resume

- **GIVEN** a pending plan exists without an approved authoritative stable checkpoint
- **WHEN** resume or recovery is requested
- **THEN** the system refuses recoveryReady
- **AND** it does not apply the pending plan as recovered state

#### Scenario: New generation is monotonic

- **GIVEN** terminal, checkpoint, and child-fence join has completed
- **WHEN** a new session is created
- **THEN** the new generation is strictly newer than the previous generation
- **AND** the previous generation remains fenced from mutation

#### Scenario: Old generation is fenced

- **GIVEN** a new generation exists after terminal join
- **WHEN** an event from the old generation arrives
- **THEN** the event is observed and rejected
- **AND** it cannot mutate the new generation state

### Requirement: First-cause and terminal identity remain stable

The system SHALL preserve session identity, generation identity, terminal disposition, and first terminal cause once they are settled. A later terminal event SHALL NOT overwrite the first cause.

#### Scenario: Duplicate terminal is rejected

- **GIVEN** a session has a settled terminal disposition and first cause
- **WHEN** a second terminal event arrives
- **THEN** the second event is recorded as a duplicate or rejected event
- **AND** the original terminal disposition and first cause remain unchanged

#### Scenario: Unknown identity fails closed

- **GIVEN** an event has an unknown session or generation identity
- **WHEN** the lifecycle authority receives the event
- **THEN** it rejects the event
- **AND** it does not treat unknown identity as the current session

### Requirement: Deterministic interleaving profile is not runtime proof

The system MAY record a deterministic interleaving profile with seed, schedule, terminal hash, generation result, and stale-mutation result. A passing profile SHALL remain profile_only or stress_profile_only and SHALL NOT satisfy proof_runtime.

#### Scenario: Repeated seed is reproducible

- **GIVEN** the same seed and schedule definition are run twice
- **WHEN** both profile runs complete
- **THEN** they produce the same terminal hash and ledger identity
- **AND** the profile receipt records both runs without claiming runtime proof

#### Scenario: Profile cannot upgrade proof

- **GIVEN** the deterministic profile passes
- **WHEN** a consumer evaluates the evidence claim
- **THEN** the claim remains profile_only or stress_profile_only
- **AND** it is not treated as proof_runtime, W8 DONE, or operator-pass

### Requirement: Real-process recipe remains capped until receipt

The system SHALL keep the real-process recipe versioned with its provenance. Unit, mock, or fake-child runs SHALL NOT satisfy proof_runtime, and claim_cap SHALL remain recipe_only until a real process receipt exists.

#### Scenario: Recipe provenance is retained

- **GIVEN** a recipe is used to describe the future real-process proof shape
- **WHEN** the carrier records that recipe
- **THEN** it preserves RECIPE-REAL-PROCESS-HARNESS provenance sha256 93c7623846cc7d407ec120ad926620d24f2bc1f5893b7dae2baca41c8ced20ed or an explicit superseding chain
- **AND** it keeps recipe_only distinct from proof satisfied

#### Scenario: Fake child cannot satisfy proof

- **GIVEN** a run uses only unit, mock, or fake-child participants
- **WHEN** the evidence claim is evaluated
- **THEN** the run is rejected as proof_runtime evidence
- **AND** the claim remains recipe_only

### Requirement: Offline mock demonstration and safe error semantics

The system SHALL support the MAformac offline demonstration boundary with mock vehicle state, visible card/readback behavior, and TTS-compatible terminal outcomes. Errors, refusals, cancellation, and unsupported outcomes SHALL NOT be presented as successful actions.

#### Scenario: Offline mock action is read back

- **GIVEN** the demonstration runs without a network and uses mock vehicle state
- **WHEN** an accepted action reaches a terminal outcome
- **THEN** the visible mock state and readback reflect the accepted outcome
- **AND** the result remains an offline demonstration proof rather than real vehicle control

#### Scenario: Error is not success

- **GIVEN** an action is refused, cancelled, unsupported, timed out, or fails
- **WHEN** the terminal outcome is presented
- **THEN** the outcome is rendered as its error or refusal class
- **AND** it does not claim an accepted action or successful state mutation

### Requirement: W8 owner boundaries and planned gates stay explicit

The system SHALL keep W7 window/retention/clear policy, W9 force/reset write store, W10 TTS quality, W5c default backend/composition, and V2 operator-pass outside the W8 lifecycle owner. Source and exit gates SHALL remain planned and not yet executable until their declared checker, wiring, negative, and materialization evidence exist.

#### Scenario: W8 does not own W7 policy

- **GIVEN** lifecycle facts are published for a consumer
- **WHEN** a consumer evaluates DialogueState window, retention, or clear policy
- **THEN** those policies remain owned outside W8
- **AND** W8 does not declare context cleared as child settled

#### Scenario: Exit gate stays out of source-free CI

- **GIVEN** the exit/runtime gate has not materialized its real process checker and receipt
- **WHEN** gate status is reported
- **THEN** it remains PLANNED_GATE_NOT_YET_EXECUTABLE
- **AND** it is not reported as verify-ci green or proof_runtime satisfied

#### Scenario: Missing gate evidence blocks green claim

- **GIVEN** a declared checker, exact suite, negative, wiring, or materialization receipt is missing
- **WHEN** a gate claim is evaluated
- **THEN** the gate remains blocked or planned
- **AND** no W8 DONE or gate green claim is emitted

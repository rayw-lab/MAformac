## ADDED Requirements

### Requirement: W7 consumes W8 typed lifecycle facts without owning lifecycle

The system SHALL apply W8-owned typed lifecycle facts to DialogueState through one versioned W7 effect boundary. W7 SHALL own only DialogueState field effects and SHALL NOT define session lifecycle identities, event ordering, terminal ownership, generation fencing, checkpoint timing, or recovery state-machine policy.

#### Scenario: A supported W8 fact produces one deterministic effect

- **GIVEN** a W8-owned typed lifecycle fact has supported identity and schema version
- **WHEN** W7 consumes the fact
- **THEN** exactly one versioned mapping determines effects on focus, last readback, active window, unpaired group, and terminal audit
- **AND** the same fact is not consumed twice

#### Scenario: Unknown W8 fact fails closed

- **GIVEN** a W8 fact is absent, unknown, or version-incompatible
- **WHEN** W7 attempts to compute an effect
- **THEN** the consumption is rejected
- **AND** W7 does not create a private session, generation, or terminal authority to continue

#### Scenario: Cancellation becomes audit-only context

- **GIVEN** W8 reports cancellation after a user record but before assistant completion
- **WHEN** W7 reduces the event
- **THEN** the group becomes terminal audit-only
- **AND** it is excluded from active window, focus, last readback, and new session context

### Requirement: Dialogue window envelope is typed versioned finite and bounded

The system SHALL expose a bounded DialogueState window envelope with carrier-frozen identity fields, supported schema version, finite group disposition, and explicit rejection of missing or unknown identity and unsupported version. The envelope SHALL remain short-term and SHALL NOT authorize long-lived memory.

#### Scenario: Supported envelope round-trips

- **GIVEN** an envelope uses supported identity and schema version
- **WHEN** it is encoded and decoded
- **THEN** group disposition, active and audit partition, focus validity, readback validity, and source references round-trip exactly
- **AND** the envelope remains read-only to its consumer

#### Scenario: Missing identity fails closed

- **GIVEN** an envelope is missing required identity, has unknown disposition, or uses an unsupported version
- **WHEN** a source or consumer validates it
- **THEN** it is rejected as context-invalid
- **AND** no focus, readback, or window mutation occurs

#### Scenario: Retention remains bounded

- **GIVEN** accepted groups exceed the carrier-frozen window bound
- **WHEN** the next group is appended
- **THEN** the oldest active owner window is evicted deterministically
- **AND** eviction does not create cross-session or long-lived context

### Requirement: Group completeness and field validity are independent

The system SHALL represent each group as paired or unpaired with a finite reason covering user-only, assistant-cancelled, and consecutive-user supersession. Focus and last-readback validity SHALL be recorded independently with reason, source-group reference, and schema version. Array length SHALL NOT determine group completeness.

#### Scenario: Consecutive user messages are not a fake pair

- **GIVEN** two consecutive user messages have no assistant completion between them
- **WHEN** groups are formed
- **THEN** the earlier group is unpaired with consecutive-user supersession
- **AND** the later group remains an independent user-only group

#### Scenario: Focus validity does not imply readback validity

- **GIVEN** focus and last readback originate from different groups or validity reasons
- **WHEN** the envelope is consumed
- **THEN** each field is evaluated only from its own validity record
- **AND** neither field inherits validity from the other

#### Scenario: Assistant cancellation remains explicit

- **GIVEN** a user message is recorded and W8 reports cancellation before assistant completion
- **WHEN** the group is closed
- **THEN** the group retains an assistant-cancelled disposition for audit
- **AND** it is not counted as a paired round

### Requirement: Context restore requires an authoritative checkpoint

The system SHALL restore active DialogueState context only from an authoritative checkpoint whose schema/version, session/generation owner, digest, and restore disposition are valid. Restored UI text alone SHALL NOT prove context availability. Legacy snapshots SHALL use explicit one-time migration and SHALL NOT cross a session fence.

#### Scenario: Display text does not restore context

- **GIVEN** UI text is restored after restart but no approved authoritative checkpoint is available
- **WHEN** a resolver asks for dialogue context
- **THEN** the result is typed no-context or clarify
- **AND** mutation is false

#### Scenario: Legacy ambiguous snapshot is explicit

- **GIVEN** a legacy message snapshot cannot establish exact pairing
- **WHEN** one-time migration runs
- **THEN** each ambiguous group receives a legacy-unpaired or context-invalid disposition
- **AND** migration does not treat the snapshot as complete paired rounds

#### Scenario: Checkpoint identity mismatch fails closed

- **GIVEN** a checkpoint session or generation does not match the current W8-owned identity
- **WHEN** restore is attempted
- **THEN** active context remains empty or invalid
- **AND** the checkpoint is not rebound to the current session

### Requirement: Focus expires with its owner window and force visual state is not a focus source

The system SHALL bind focus validity to an owner window and explicit expiry or revocation reason. Eviction, terminal clear, session clear, or identity fence SHALL invalidate focus according to the effect matrix. Unpaired groups SHALL NOT renew focus. Force visual state SHALL NOT create focus. Future explicit focus injection SHALL remain disabled until a separate authority and proof contract is ratified.

#### Scenario: Owner-window eviction invalidates focus

- **GIVEN** focus belongs to a window evicted at an unpaired-group boundary
- **WHEN** a consumer resolves an entity
- **THEN** focus is invalid
- **AND** the consumer returns typed no-context or clarify with mutation false

#### Scenario: Force visual state cannot create focus

- **GIVEN** a presentation surface forces a visual state
- **WHEN** DialogueState is read
- **THEN** no focus entity is created or renewed from that visual state
- **AND** existing focus validity remains governed by its owner window

#### Scenario: Unauthorised focus injection is rejected

- **GIVEN** a caller attempts focus injection without separately ratified owner, source identity, expiry, receipt, and negative proof
- **WHEN** W7 validates the input
- **THEN** injection fails closed
- **AND** existing focus remains unchanged

### Requirement: Clear effects are versioned field-granular and audit-isolated

The system SHALL define one versioned effect matrix from W8-owned typed facts to focus, lastReadback, activeWindow, unpairedGroup, and terminalAudit with finite effects equivalent to clear, retain, or audit-only. Active context and terminal audit SHALL use separate interfaces. Terminal audit SHALL NOT be readable as resolver context.

#### Scenario: Transient clear does not impersonate session clear

- **GIVEN** a transient clear invalidates focus and last readback while the active window remains valid
- **WHEN** the effect matrix is applied
- **THEN** the active window is preserved according to its explicit effect
- **AND** the receipt does not claim session context was cleared

#### Scenario: Session clear isolates audit

- **GIVEN** a session clear follows a terminal event
- **WHEN** the effect matrix is applied
- **THEN** active focus, last readback, active window, and unpaired active group are cleared as specified
- **AND** terminal audit may be retained without re-entering active context

#### Scenario: Effect version mismatch fails closed

- **GIVEN** a typed fact and effect matrix use incompatible versions or an unrecognized effect
- **WHEN** reduction is attempted
- **THEN** the operation fails closed
- **AND** no partial field mutation occurs

### Requirement: W7 proof and gate claims remain capped

The system SHALL keep source and consumption verification gates planned until their declared checker, exact suite, negative, official wiring, fresh result, and materialization receipt exist. Strict carrier validation SHALL NOT by itself make a gate green, prove implementation, or satisfy runtime proof.

#### Scenario: Missing materialization evidence blocks green

- **GIVEN** any required checker, exact suite, negative, wiring, or materialization receipt is missing
- **WHEN** gate status is evaluated
- **THEN** the gate remains PLANNED_GATE_NOT_YET_EXECUTABLE
- **AND** no gate green, W7 DONE, or implementation-complete claim is emitted

#### Scenario: Consumption gate follows source gate

- **GIVEN** the source gate has no fresh materialization receipt
- **WHEN** consumption gate status is evaluated
- **THEN** consumption remains blocked
- **AND** it cannot be reported as integration green

### Requirement: Offline mock demonstration errors do not become success

The system SHALL preserve the MAformac offline demonstration boundary with mock vehicle state, visible readback semantics, and terminal outcomes. Refusal, cancellation, unsupported, timeout, and error outcomes SHALL NOT be presented as accepted actions or successful state mutation.

#### Scenario: Offline mock readback is bounded

- **GIVEN** the demonstration runs without a network and uses mock vehicle state
- **WHEN** a semantic effect reaches a terminal outcome
- **THEN** visible state and readback reflect only the accepted mock effect
- **AND** the evidence remains an offline demonstration proof rather than real vehicle control

#### Scenario: Error is not success

- **GIVEN** an effect is refused, cancelled, unsupported, timed out, or failed
- **WHEN** the terminal outcome is presented
- **THEN** it remains its error or refusal class
- **AND** it does not claim accepted action or successful state mutation

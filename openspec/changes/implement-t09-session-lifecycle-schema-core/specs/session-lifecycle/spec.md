## ADDED Requirements

### Requirement: K1 schema-core applies only the authorized lifecycle subset

The system SHALL deliver a schema-core lifecycle owner that treats ready, active, terminal, and recoveryReady as observable states while executing only the transitions ready→active and active→terminal. The system MUST reject any recoveryReady entry, any new-generation request, and any other transition outside that executable subset with zero applied lifecycle mutation. Parent session lifecycle MUST remain separate from child turn registration: the schema-core subset MUST NOT register children, MUST NOT fan out cancellation to children, and MUST NOT perform child-fence join. Non-owner authority MUST NOT apply lifecycle mutation; non-owner parties MAY construct or submit event values only. Unknown session identity, cross-session identity, and unknown generation MUST fail closed with zero partial mutation.

#### Scenario: Authorized start then terminal succeeds

- **GIVEN** a schema-core lifecycle owner whose session is ready under the correct owner authority
- **WHEN** an authorized start is applied and then an authorized terminal is applied
- **THEN** the published state becomes active after start and terminal after terminal
- **AND** exactly one immutable snapshot reflects each successful authorized apply without a second lifecycle truth

#### Scenario: Non-owner mutation is rejected without change

- **GIVEN** a live session owned by the lifecycle authority
- **WHEN** a non-owner authority attempts to apply a lifecycle mutation
- **THEN** the attempt is rejected fail-closed
- **AND** the published snapshot and generation remain unchanged

#### Scenario: Forbidden transition applies zero mutation

- **GIVEN** a session whose current state makes a requested source→target pair unauthorized for schema-core
- **WHEN** that forbidden transition is requested under owner authority
- **THEN** the request is rejected
- **AND** no lifecycle state change is applied

#### Scenario: RecoveryReady and new-generation requests are non-executable

- **GIVEN** a schema-core owner that may name recoveryReady as an observable state
- **WHEN** recoveryReady entry or a new-generation activation is requested
- **THEN** the request is rejected with zero applied mutation
- **AND** the claim ceiling remains schema-only rather than recovery completeness

#### Scenario: Unknown or cross-session identity fails closed

- **GIVEN** an event whose session or generation identity is unknown or does not match the live session
- **WHEN** the lifecycle owner receives that event for authoritative apply
- **THEN** the event is rejected fail-closed
- **AND** no partial lifecycle mutation is applied

### Requirement: K1 compound requests settle atomically and deterministically

The system SHALL accept a compound lifecycle request batch that may include start and terminal-or-cancel intents for one parent session through a single `apply(batch:)` entry. The system MUST first canonicalize the batch so that start precedes terminal or cancel regardless of input order or wall-clock time, MUST validate the entire batch by simulating events in that canonical order on a scratch snapshot (not by judging each event independently against the initial state alone), MUST commit the authoritative snapshot or fact only after the whole batch is valid, MUST apply the batch atomically, and MUST publish exactly one final immutable outcome snapshot with no intermediate applied truth and no intermediate snapshot exposure. Cancel MUST map to a terminal disposition and cause at the parent session layer without registering or notifying children and without fan-out.

#### Scenario: Start and cancel in one batch yield one ordered outcome

- **GIVEN** a ready parent session under owner authority and a single logical batch containing both start and cancel intents
- **WHEN** the batch is applied via `apply(batch:)` with intents in any input order
- **THEN** the owner publishes exactly one immutable final outcome whose logical order is start before cancel-as-terminal
- **AND** it never publishes two conflicting applied truths or any intermediate applied snapshot

#### Scenario: Invalid batch applies nothing

- **GIVEN** a compound batch that fails whole-batch validation on the scratch simulation path
- **WHEN** the owner processes the batch through `apply(batch:)`
- **THEN** no lifecycle mutation is applied
- **AND** the prior immutable snapshot remains the only published truth

### Requirement: K1 terminal identity and first cause remain immutable

The system SHALL, on the first successful transition into terminal, write terminal disposition and first terminal cause once. After terminal settlement the system MUST preserve session identity, generation identity, terminal disposition, and first cause. A later terminal or cancel-class event MUST be observed as duplicate or rejected and MUST NOT overwrite the first cause or disposition.

#### Scenario: Duplicate terminal preserves the first cause

- **GIVEN** a session that has already settled terminal disposition and first cause
- **WHEN** a second terminal or cancel-class event arrives for the same settled session
- **THEN** the second event is recorded as duplicate or rejected
- **AND** the original terminal disposition and first cause remain unchanged in the published snapshot

### Requirement: K1 fact classification never upgrades errors to success

The system SHALL classify lifecycle facts with explicit non-success classes that include at least refused, cancelled, unsupported, timeout, and failure where those outcomes occur. The system MUST NOT present those classes as accepted or successful action facts. Fact classification MUST remain schema-level only: schema-core MUST NOT require UI strings, UI imports, or presentation rendering. Error and refusal outcomes MUST stay distinguishable from success. Schema-core fact types MUST NOT detect or branch on runtime mock versus real vehicle-control context.

#### Scenario: Error-class facts stay non-success

- **GIVEN** a terminal outcome whose semantic class is refused, cancelled, unsupported, timeout, or failure
- **WHEN** the lifecycle fact is published
- **THEN** the fact is classified as that non-success class
- **AND** it is not upgraded to an accepted or successful action fact

#### Scenario: Fact schema does not claim UI rendering

- **GIVEN** schema-core has published a non-success or success fact
- **WHEN** a consumer evaluates presentation readiness
- **THEN** the fact remains schema classification only
- **AND** UI rendering remains outside schema-core delivery

### Requirement: K1 evidence remains schema-only

The system SHALL keep schema-core evidence capped at partial schema-only proof. Passing schema-core unit checks, OpenSpec validation, or fixture tables MUST NOT satisfy runtime proof, operator-pass, gate green, or full session-lifecycle done claims. Schema-only evidence MUST NOT authorize real vehicle control and MUST NOT be classified as a claim of real vehicle control success; this is **evidence claim classification**, not runtime mock/real context detection by schema types. Deferred surfaces—including child registry behavior, cancel fan-out, fence join, executable recoveryReady, deterministic interleaving profile proof, real-process recipe satisfaction, and planned gate materialization—MUST remain unimplemented by schema-core and MUST NOT be claimed complete by schema-core evidence.

#### Scenario: Green schema-core tests do not become runtime proof

- **GIVEN** schema-core authorized fixtures for owner rejection, illegal transition, compound order, duplicate terminal, unknown identity, and error-class facts all pass
- **WHEN** an evidence consumer evaluates the claim class
- **THEN** the claim remains partial schema-only
- **AND** it is not treated as runtime proof, operator-pass, gate green, or full lifecycle done
- **AND** the evidence is not classified as authorization of real vehicle control or as a real vehicle-control success claim

#### Scenario: Deferred recovery and child surfaces stay out of schema-core claims

- **GIVEN** base lifecycle contracts still describe child disposition, recoveryReady join, profile, recipe, and planned gates
- **WHEN** schema-core delivery is reported
- **THEN** those surfaces remain deferred or documentary relative to schema-core
- **AND** schema-core does not claim they are implemented or proven

#### Scenario: Schema-only evidence stays non-authorization of real vehicle control

- **GIVEN** only schema-core unit checks, OpenSpec validation, or fixture tables are available as evidence
- **WHEN** an evidence consumer classifies what that evidence may claim
- **THEN** the evidence remains claim-class schema-only
- **AND** it does not authorize real vehicle control
- **AND** it is not reclassified as a real vehicle-control success claim
- **AND** this classification does not require schema types to detect runtime mock versus real context

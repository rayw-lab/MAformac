## ADDED Requirements

### Requirement: Customer frontstage SHALL use one typed ingress facade

Visible text, future ASR transcripts, and shortcuts SHALL enter one facade. Identity SHALL be assigned before exactly-once validation.

#### Scenario: Visible text is submitted

- **GIVEN** the customer frontstage is visible
- **WHEN** valid text is submitted
- **THEN** it SHALL receive stable session, turn, and event identity
- **AND** validation SHALL run exactly once.

### Requirement: Invalid or unavailable ingress SHALL be side-effect free

Nil transcript, blank text, oversized input, and unavailable ASR SHALL return typed rejection with zero mutation and zero readback.

#### Scenario: MicDock has no ASR provider

- **GIVEN** no ASR provider is installed
- **WHEN** MicDock submits
- **THEN** the result SHALL be typed unavailable
- **AND** no state mutation or readback SHALL occur.

### Requirement: Stale and correlation rejection SHALL be W6-gated

Until W6 lands the typed route-result and trace identity contracts, T04a SHALL track stale session/turn/event and correlation-mismatch rejection as deferred and SHALL NOT claim those typed outcomes as implemented. After those W6 types land, stale identity and correlation mismatch SHALL return typed rejection with zero mutation and zero readback.

#### Scenario: W6 route identity types are not available

- **GIVEN** the W6 typed route-result and trace identity contracts have not landed
- **WHEN** T04a reports its implementation status
- **THEN** stale and correlation typed rejection SHALL remain explicitly deferred
- **AND** the current ingress facade SHALL NOT be described as satisfying those outcomes.

#### Scenario: W6 route identity types become available

- **GIVEN** the W6 typed route-result and trace identity contracts have landed
- **WHEN** a stale identity or correlation mismatch reaches ingress validation
- **THEN** the result SHALL be a typed rejection
- **AND** no state mutation or readback SHALL occur.

### Requirement: T04a SHALL not extend runtime or receipt ownership

T04a SHALL consume the existing presentation bridge and int-v5b receipt without changing receipt/schema/checker/launch ABI or binding a production runner/backend/default composition.

#### Scenario: T04a closes locally

- **WHEN** ingress and correlation tests pass
- **THEN** the maximum claim SHALL be local/unit/integration construction
- **AND** T04b, runtime/operator/action-success, and V-PASS SHALL remain unclaimed.

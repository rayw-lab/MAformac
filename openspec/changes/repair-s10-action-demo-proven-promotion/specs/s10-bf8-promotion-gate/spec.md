## ADDED Requirements

### Requirement: BF-8 promotion authorization blocks actionDemoProven

The system SHALL treat human BF-8 promotion as a fifth same-cell basis input (`bf8_promotion`) distinct from `readbackProbePass`. `actionDemoProven=true` SHALL require `bf8_promotion.observed=true` with a machine-checkable BF-8 receipt binding subject SHA and matrix scope. Probe basis green alone SHALL NOT promote `actionDemoProven`.

#### Scenario: Probe green without BF-8 keeps proven false

- **GIVEN** matrix_id=4 has all four non-promotion basis sources observed including valid `readbackProbePass` proof
- **AND** `bf8_promotion.observed` is false
- **WHEN** the capability matrix is materialized or checked
- **THEN** `actionDemoProven` SHALL be false for matrix_id=4
- **AND** the checker SHALL NOT emit `E_ACTION_DEMO_PROVEN_MANUAL_OVERRIDE` for that state

#### Scenario: BF-8 receipt authorizes single-cell promotion

- **GIVEN** matrix_id=4 has valid readback probe proof and a BF-8 receipt binding the same subject SHA
- **WHEN** `bf8_promotion.observed` becomes true from that receipt
- **THEN** materialize MAY set `actionDemoProven=true` only for matrix_id=4
- **AND** no other matrix cell SHALL flip from this receipt alone

### Requirement: BF-8 receipt is human-gated evidence

BF-8 promotion evidence SHALL reference E3/WP0-7/M0 human ceremony artifacts. Agent-generated prose or test-only fixtures SHALL NOT satisfy `bf8_promotion`.

#### Scenario: Missing BF-8 receipt blocks promotion

- **GIVEN** readback probe proof is valid
- **AND** no BF-8 receipt is registered for the subject SHA
- **WHEN** governance evaluates promotion
- **THEN** `bf8_promotion.observed` SHALL remain false

# rejection-demo-proven Specification

## Purpose

Define the `rejectionDemoProven` field for tracking rejection/fail-closed demonstration coverage separately from `actionDemoProven`, establish the rejection utterance contract for m5/m6, and enforce that rejection capabilities SHALL NOT be counted toward execution coverage metrics.

## ADDED Requirements

### Requirement: rejectionDemoProven field isolation

The system SHALL provide a `rejectionDemoProven` boolean field in `demo-capability-matrix.json` that mirrors the shape of `actionDemoProven` but is semantically isolated. The field SHALL default to `false` and SHALL be flipped to `true` only after a scoped rejection BF-8 authorization. Rejection capabilities (`primary_class=fast_path_no_match_fallback` or explicitly listed rejection classes) MUST NOT be written into `actionDemoProven`.

#### Scenario: rejectionDemoProven defaults to false

- **WHEN** a new matrix row is created for a rejection capability (m5 or m6)
- **THEN** the `rejectionDemoProven` field SHALL default to `false`
- **AND** the `actionDemoProven` field SHALL also be `false`

#### Scenario: Checker rejects rejection in actionDemoProven

- **GIVEN** a matrix row has `primary_class=fast_path_no_match_fallback`
- **WHEN** `check_capability_matrix.py` validates the matrix
- **THEN** the checker SHALL reject any row where `actionDemoProven=true`
- **AND** the checker SHALL report the violation with matrix_id and reason

#### Scenario: rejectionDemoProven flip requires BF-8 receipt

- **GIVEN** a rejection capability (m5 or m6) has passed readback validation
- **WHEN** the operator attempts to flip `rejectionDemoProven` to `true`
- **THEN** the system SHALL require a scoped BF-8 receipt with `matrix_ids=[5,6]` or equivalent
- **AND** the flip SHALL NOT proceed without the receipt

### Requirement: m5+m6 联合 BF-8 口径

The system SHALL treat matrix_id=5 (委婉表达 rejection) and matrix_id=6 (能否问句 rejection) as two register surfaces of the same rejection capability. A single BF-8 authorization MAY cover both `matrix_ids=[5,6]` simultaneously. The BF-8 receipt MUST declare `subject` as rejection-related (not execution) and MUST NOT be reused from execution BF-8 receipts (e.g., matrix_id=4).

#### Scenario: Single BF-8 authorizes m5 and m6 together

- **GIVEN** a BF-8 receipt declares `matrix_ids=[5,6]` and `subject` contains rejection semantics
- **WHEN** the receipt is applied to the capability matrix
- **THEN** both matrix_id=5 and matrix_id=6 SHALL have `rejectionDemoProven=true`
- **AND** both SHALL remain `actionDemoProven=false`

#### Scenario: Execution BF-8 receipt cannot flip rejection proven

- **GIVEN** an execution BF-8 receipt exists for matrix_id=4 with `subject=adjust_ac_temperature_to_number execution`
- **WHEN** the operator attempts to reuse this receipt for matrix_id=5 or matrix_id=6
- **THEN** the system SHALL reject the reuse
- **AND** SHALL require a separate rejection BF-8 receipt

### Requirement: Rejection utterance contract for m5 (委婉表达)

The system SHALL recognize utterances expressing indirect thermal discomfort (e.g., "有点冷", "太热了", "感觉闷") as rejection candidates for matrix_id=5. These utterances SHALL be routed to `fast_path_no_match_fallback` with `reason_kind=not_available_in_demo`. The system SHALL NOT produce state mutations for these utterances and SHALL provide fail-closed readback (e.g., "当前演示不支持该功能").

#### Scenario: 委婉 utterance triggers rejection

- **WHEN** the user says "有点冷"
- **THEN** the system SHALL classify it as rejection for matrix_id=5
- **AND** SHALL NOT call any execution tool (e.g., `adjust_ac_temperature_to_number`)
- **AND** SHALL NOT mutate mock state

#### Scenario: Rejection readback contains fail-closed message

- **GIVEN** a 委婉 utterance ("太热了") is classified as rejection
- **WHEN** the system generates readback
- **THEN** the readback SHALL contain a fail-closed message (e.g., "当前演示不支持该功能" or "抱歉,演示模式下无法处理")
- **AND** SHALL NOT contain success language (e.g., "已调整")

### Requirement: Rejection utterance contract for m6 (能否问句)

The system SHALL recognize polite request patterns with modal verbs (e.g., "能调到24度吗", "可以开空调吗", "请问能不能调温") as rejection candidates for matrix_id=6. These utterances SHALL be routed to `fast_path_no_match_fallback` with `reason_kind=not_available_in_demo`. The system SHALL NOT produce state mutations for these utterances and SHALL provide fail-closed readback.

#### Scenario: 能否问句 triggers rejection

- **WHEN** the user says "能调到24度吗"
- **THEN** the system SHALL classify it as rejection for matrix_id=6
- **AND** SHALL NOT call any execution tool
- **AND** SHALL NOT mutate mock state

#### Scenario: Direct command does not trigger m6 rejection

- **GIVEN** the user says a direct command "调到24度" (without modal/polite framing)
- **WHEN** the system classifies the utterance
- **THEN** the system SHALL NOT route it to matrix_id=6 rejection
- **AND** MAY route it to an execution path if available

### Requirement: Rejection capabilities do not mutate state

The system SHALL enforce that any capability marked with `rejectionDemoProven=true` (or pending rejection BF-8) MUST NOT produce observable state mutations in the mock vehicle state. Readback probes for rejection capabilities SHALL verify `no_state_mutation`.

#### Scenario: Rejection readback probe verifies no state change

- **GIVEN** a rejection utterance for m5 or m6 is processed
- **WHEN** the readback probe runs
- **THEN** the probe SHALL verify that no state cells changed
- **AND** SHALL verify that the TTS/readback contains fail-closed language
- **AND** SHALL fail if any state mutation occurred

### Requirement: Schema and checker enforcement

The system SHALL extend `demo-capability-matrix.json` schema to include `rejectionDemoProven: boolean`. The checker (`check_capability_matrix.py`) SHALL enforce:
- `primary_class=fast_path_no_match_fallback` rows MUST NOT have `actionDemoProven=true`
- `rejectionDemoProven` field MUST exist for all matrix rows
- BF-8 receipts for rejection MUST declare appropriate `matrix_ids` and MUST NOT overlap with execution receipts

#### Scenario: Schema validation requires rejectionDemoProven field

- **GIVEN** a matrix row in `demo-capability-matrix.json`
- **WHEN** the schema validator runs
- **THEN** the validator SHALL require the `rejectionDemoProven` field
- **AND** SHALL reject rows missing this field

#### Scenario: Checker detects rejection/execution mixing

- **GIVEN** a matrix row has `primary_class=fast_path_no_match_fallback` and `actionDemoProven=true`
- **WHEN** `check_capability_matrix.py` runs
- **THEN** the checker SHALL report an error
- **AND** SHALL identify the matrix_id and the conflicting fields

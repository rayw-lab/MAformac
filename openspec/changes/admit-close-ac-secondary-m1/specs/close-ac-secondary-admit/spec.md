# close-ac-secondary-admit Specification

## Purpose

Define the frozen T2 contract for the mounted secondary tool `close_ac`: exact customer-text admission, Frame 甲 typed binding, canonical typed receipt and matrix-sibling shapes, and fail-closed behavior while the capability remains unproven. Product code implements the negative mechanics for tasks 2/3/4, and this delta records their gate-observed behavior; it does not claim positive proof or whole-change completion.

## T2 Gate Evidence

Tasks 2/3/4 negative mechanics are implementation-complete only. Strict OpenSpec validation and Wave1 py_compile passed; Wave1 had 97 Python tests (receipt 36, matrix 61), the three `make verify-*` gates, and `DemoCapabilityMatrixGeneratedTests` passed. Wave2 passed `DemoSliceAdmissionCatalogTests` 12, `DemoSliceProductBehaviorGateTests` 32, `RuntimeTurnReceiptDigestTests` 6, `RuntimeTurnReceiptSchemaTests` 6, `DemoSliceClassificationTests` 29, `DemoSliceRouteTests` 7, and `FahrenheitAdmissionTests` 11. Structural facts remain 120 cells, primary `[4]=1/120`, root-sibling `secondary_tools.close_ac` mounted/customer_admitted true/proven false, and canonical m4-only registry. No positive proof, positive e2e, BF8 ceremony, m1/archive work, or `proven=true` is claimed.

## ADDED Requirements

### Requirement: Exact Customer Admission

The system SHALL admit only the exact customer phrase `关闭空调`. Alias, fuzzy, indirect, ambiguous, and compound utterances SHALL fail closed without invoking `close_ac`.

#### Scenario: Exact phrase is the only eligible input

- **WHEN** the input is exactly `关闭空调`
- **THEN** the admission contract SHALL identify the `close_ac` secondary tool
- **AND** any non-exact spelling or additional text SHALL NOT be identified as `close_ac`

#### Scenario: Alias or compound input fails closed

- **WHEN** the input is `关空调`, `关掉空调`, or a compound/multi-intent utterance
- **THEN** the admission contract SHALL refuse or fall back without invoking `close_ac`

---

### Requirement: Frame 甲 Typed Binding

The semantic binding SHALL be Frame 甲 `set_vehicle_control / power_off` with value `off`. T2 SHALL describe the binding without executing a runtime action or adding runtime-action-readback v2 behavior.

#### Scenario: Binding is represented without execution

- **WHEN** the T2 contract is materialized
- **THEN** its action frame SHALL be `set_vehicle_control/power_off`
- **AND** its value SHALL be `off`
- **AND** no state mutation, success readback, or runtime runner action SHALL be claimed by T2

---

### Requirement: Typed Identity and Canonical Receipt Root

Identity SHALL be the union `primaryMatrix(Int) | secondaryTool(String)`. For `close_ac`, identity SHALL be `secondaryTool("close_ac")` and its `matrixID` SHALL be nil. Sentinel IDs `0`, `1`, and `121` SHALL be rejected.

The canonical typed receipt root SHALL use snake-case `subject_type` and `subject_id`. A primary receipt SHALL use an integer `subject_id` and singleton integer `matrix_ids`. A secondary receipt SHALL use string `subject_id: "close_ac"` and SHALL omit `matrix_ids`; a null `matrix_ids` is invalid. Nested subject aliases and alternate/camel fields (`subjectType`, `subjectID`, `secondary_tool_id`) SHALL be rejected. The exact m4 discriminator-less path+bytes form SHALL remain the sole legacy exception.

#### Scenario: Secondary identity cannot acquire a fake matrix ID

- **WHEN** a `close_ac` identity is checked
- **THEN** it SHALL be `secondaryTool("close_ac")` with nil `matrixID`
- **AND** values `0`, `1`, and `121` SHALL fail validation

#### Scenario: Receipt root shape is canonical

- **WHEN** a typed secondary receipt is checked
- **THEN** it SHALL use root `subject_type` and string `subject_id: "close_ac"`
- **AND** it SHALL omit `matrix_ids`
- **AND** nested subjects, camel aliases, `secondary_tool_id`, and null `matrix_ids` SHALL fail validation

#### Scenario: Legacy exception remains narrow

- **WHEN** a receipt uses the discriminator-less m4 path+bytes form
- **THEN** that exact form MAY remain accepted
- **AND** no other discriminator-less or alias form SHALL be accepted

---

### Requirement: Matrix Root Sibling Invariants

The capability matrix SHALL represent `secondary_tools.close_ac` only as a root sibling with `mounted_status: mounted`, `customer_admitted: true`, `proven: false`, and a pending BF8-shape `proven_basis`. It SHALL NOT be placed inside cells or summary data. The matrix SHALL retain 120 cells and primary `[4]=1/120` unchanged.

#### Scenario: Secondary sibling remains unproven

- **WHEN** the matrix shape is checked during T2
- **THEN** `secondary_tools.close_ac.mounted_status` SHALL be `mounted`
- **AND** `customer_admitted` SHALL be `true`
- **AND** `proven` SHALL be `false`
- **AND** `proven_basis` SHALL remain pending BF8 shape

#### Scenario: Primary matrix is not altered

- **WHEN** `close_ac` is materialized
- **THEN** it SHALL NOT occupy a matrix cell or summary field
- **AND** the matrix SHALL still contain 120 cells with primary `[4]=1/120`
- **AND** no secondary `matrixID` or primary counter increment SHALL be produced

---

### Requirement: T2 Unproven Refusal

When `secondary_tools.close_ac.proven` is false or missing/unknown, the system SHALL return a typed refusal before target projection, already-state handling, runner, store, revision, and TTS. T2 SHALL emit no positive secondary receipt, probe, BF8 ceremony, positive readback, archive, m1 claim, or `proven=true`.

#### Scenario: Unproven secondary action is stopped before side effects

- **GIVEN** `secondary_tools.close_ac.proven` is false, missing, or unknown
- **WHEN** the exact phrase would otherwise select `close_ac`
- **THEN** the system SHALL return a typed refusal
- **AND** runner, store, revision, and TTS SHALL remain untouched
- **AND** the secondary matrix ID SHALL remain nil

#### Scenario: T2 does not claim proof

- **WHEN** T2 artifacts are reviewed
- **THEN** no positive secondary receipt, probe result, BF8 ceremony, positive readback, archive, m1 work, or `proven=true` SHALL be present

---

### Requirement: Implemented Projection and F4 Guard

Wave1 SHALL include the implemented and gate-observed generated Swift top-level `secondaryTools` projection for T2 negative mechanics. Wave2 SHALL include the implemented and gate-observed F4 read of `secondaryTools[close_ac].proven`, treating missing/unknown as false before target projection, already-state handling, and runner. Only task 5 positive E2E and tasks 6.1/6.2/6.3 m1/BF8/secondary ceremony/archive/proven flip work SHALL remain unchecked and block-labeled; T2 SHALL NOT perform them.

#### Scenario: Later work remains blocked

- **WHEN** task status is inspected after this amendment
- **THEN** task 5 and tasks 6.1, 6.2, and 6.3 SHALL remain unchecked and explicitly later/block-labeled
- **AND** no positive implementation, ceremony completion, whole-change completion, release, archive, m1, positive E2E/proof, BF8 ceremony, runtime-action-readback v2 expansion, or `proven=true` SHALL be inferred from this change

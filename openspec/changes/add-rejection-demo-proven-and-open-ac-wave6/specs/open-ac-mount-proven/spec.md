# open-ac-mount-proven Specification

## Purpose

Define the observable behavior for mounting `open_ac` (matrix_id=1) from unmounted to proven state, including catalog registration, matrix manifest updates, admission routing, scoped readback validation, and independent BF-8 authorization for execution coverage.

## ADDED Requirements

### Requirement: open_ac catalog mount

The system SHALL register `open_ac` in `DDomainMountedToolCatalog.mountedToolNames`. The catalog mount MUST precede manifest materialization. The catalog SHALL be the source of truth for which tools are available for routing.

#### Scenario: Catalog contains open_ac

- **WHEN** `DDomainMountedToolCatalog.swift` is read
- **THEN** the `mountedToolNames` set SHALL contain `"open_ac"`
- **AND** SHALL NOT contain window/ambient/seat tool names (后三族禁)

#### Scenario: Catalog mount precedes manifest update

- **GIVEN** `open_ac` is not yet in `DDomainMountedToolCatalog`
- **WHEN** the manifest materialization script runs
- **THEN** the script SHALL fail or warn if `open_ac` is marked `mounted_status=mounted` in the matrix but absent from the catalog
- **AND** SHALL NOT silently succeed with inconsistent state

### Requirement: open_ac manifest mounted status

The system SHALL update `demo-capability-matrix.json` matrix_id=1 to `mounted_status="mounted"` and `mounted_or_approved_action.observed=true`. The manifest update MUST include a `basis` field documenting the materialization source (script name, commit SHA, or manual-with-justification). Hand-editing the generated manifest without updating the basis or re-running the script is forbidden.

#### Scenario: matrix_id=1 mounted status reflects catalog

- **GIVEN** `open_ac` is present in `DDomainMountedToolCatalog`
- **WHEN** the manifest materialization process completes
- **THEN** matrix_id=1 SHALL have `mounted_status="mounted"`
- **AND** SHALL have `mounted_or_approved_action.observed=true`
- **AND** SHALL have `basis` field documenting the source

#### Scenario: Hand-edit of manifest is rejected

- **GIVEN** `demo-capability-matrix.json` is marked as generated or has a materialization basis
- **WHEN** a developer manually edits matrix_id=1 without re-running the script
- **THEN** the verify gate SHALL detect the inconsistency (catalog vs manifest)
- **AND** SHALL fail the check

### Requirement: open_ac admission routing

The system SHALL route the utterance "打开空调" (and equivalent direct power-on commands) to matrix_id=1 via `DemoSliceAdmissionCatalog`. The admission logic SHALL already exist (observed at `DemoSliceAdmissionCatalog.swift:178-180` as `powerOnAdmission`). The system SHALL accept the tool call for `open_ac` and SHALL NOT reject it as unmounted after catalog/manifest updates are complete.

#### Scenario: 打开空调 routes to open_ac

- **GIVEN** `open_ac` is mounted in catalog and manifest
- **WHEN** the user says "打开空调"
- **THEN** the admission catalog SHALL classify it as `powerOnAdmission` for matrix_id=1
- **AND** SHALL produce a tool call candidate for `open_ac`

#### Scenario: Admission accepts mounted open_ac

- **GIVEN** the admission logic produces a tool call for `open_ac`
- **WHEN** the tool execution gate evaluates the call
- **THEN** the system SHALL accept it (not reject as unmounted)
- **AND** SHALL proceed to tool execution

### Requirement: open_ac readback probe validation

The system SHALL provide an e2e readback probe for matrix_id=1 that verifies:
1. Utterance "打开空调" is accepted by admission
2. Tool call `open_ac` is executed
3. Mock state changes to AC power-on (observable state delta)
4. Readback/TTS contains success language (e.g., "已打开空调" or equivalent)

The probe SHALL use hard assertions (not soft warnings). The probe MUST pass before BF-8 authorization for matrix_id=1.

#### Scenario: open_ac readback probe passes

- **WHEN** the e2e probe runs with utterance "打开空调"
- **THEN** the system SHALL accept the utterance via admission
- **AND** SHALL execute tool `open_ac`
- **AND** SHALL mutate mock AC state to power-on
- **AND** SHALL generate readback containing success language
- **AND** the probe SHALL pass with all assertions green

#### Scenario: Probe detects missing state delta

- **GIVEN** the tool `open_ac` is called
- **WHEN** the readback probe checks mock state
- **THEN** if no state delta occurred, the probe SHALL fail
- **AND** SHALL report the failure reason (e.g., "expected AC power-on state change, observed none")

### Requirement: open_ac independent BF-8 authorization

The system SHALL require an independent BF-8 receipt for matrix_id=1 before flipping `actionDemoProven=true`. The receipt MUST declare `matrix_ids=[1]` and `subject` containing execution semantics (e.g., "open_ac execution"). The receipt MUST NOT reuse the matrix_id=4 execution receipt. The BF-8 MAY only proceed after:
1. Catalog mount complete
2. Manifest updated to `mounted`
3. Readback probe passes
4. Remote Verify green at tip

#### Scenario: BF-8 requires scoped receipt for matrix_id=1

- **GIVEN** matrix_id=1 readback probe passes and remote Verify is green
- **WHEN** the operator initiates BF-8 for `open_ac`
- **THEN** the system SHALL require a new receipt with `matrix_ids=[1]`
- **AND** SHALL NOT accept the matrix_id=4 receipt as a substitute

#### Scenario: actionDemoProven flip requires BF-8 completion

- **GIVEN** BF-8 for matrix_id=1 has not yet been authorized
- **WHEN** the operator attempts to flip `actionDemoProven=true` for matrix_id=1
- **THEN** the system SHALL reject the flip
- **AND** SHALL require BF-8 completion first

### Requirement: open_ac does not unblock 后三族

The system SHALL limit this change to Phase1 AC capabilities only. Mounting `open_ac` MUST NOT unblock window, ambient, or seat capabilities (后三族). The catalog, manifest, and admission updates SHALL explicitly exclude 后三族 tool names.

#### Scenario: Catalog excludes 后三族

- **GIVEN** `open_ac` is added to `DDomainMountedToolCatalog`
- **WHEN** the catalog is validated
- **THEN** the catalog SHALL NOT contain window/ambient/seat tool names
- **AND** 后三族 SHALL remain in `personaAvoidListToolNames` or candidate-only state

#### Scenario: Matrix materialize does not scan 后三族

- **GIVEN** the manifest materialization script runs
- **WHEN** it scans for mounted tools
- **THEN** it SHALL only scan Phase1 AC tools (open_ac, close_ac, adjust_ac_*)
- **AND** SHALL NOT mount window/ambient/seat tools

### Requirement: open_ac proven state is observable

The system SHALL make the proven state of matrix_id=1 machine-verifiable. After BF-8 completion, `demo-capability-matrix.json` matrix_id=1 SHALL have `actionDemoProven=true`. The system SHALL provide a checker or query that can report "matrix_id=1 is execution-proven" without manual inspection.

#### Scenario: Proven state is queryable

- **GIVEN** matrix_id=1 has `actionDemoProven=true`
- **WHEN** a governance checker or CLI tool queries proven execution capabilities
- **THEN** the tool SHALL report matrix_id=1 as proven
- **AND** SHALL include representative_tool=open_ac in the output

#### Scenario: Proven count includes matrix_id=1

- **GIVEN** matrix_id=1 and matrix_id=4 both have `actionDemoProven=true`
- **WHEN** the system calculates execution coverage
- **THEN** the coverage SHALL be 2/120 (or equivalent based on total matrix size)
- **AND** SHALL NOT mix rejection proven into this count

### Requirement: Three-gate observability (catalog, manifest, readback)

The system SHALL provide independent verification for each of the three gates:
1. **Catalog gate**: `DDomainMountedToolCatalog.mountedToolNames` contains `"open_ac"`
2. **Manifest gate**: `demo-capability-matrix.json` matrix_id=1 has `mounted_status="mounted"`
3. **Readback gate**: e2e probe for "打开空调" passes with state delta and success readback

Each gate SHALL be verifiable via automated checks (unit test, integration test, or governance checker). Manual inspection SHALL NOT be the primary verification method.

#### Scenario: Catalog gate is verifiable

- **WHEN** a unit test or checker validates the catalog gate
- **THEN** it SHALL parse `DDomainMountedToolCatalog.swift`
- **AND** SHALL confirm `"open_ac"` is in the `mountedToolNames` set
- **AND** SHALL pass or fail based on this check alone

#### Scenario: Manifest gate is verifiable

- **WHEN** a checker validates the manifest gate
- **THEN** it SHALL parse `demo-capability-matrix.json`
- **AND** SHALL confirm matrix_id=1 has `mounted_status="mounted"`
- **AND** SHALL verify `basis` field is populated

#### Scenario: Readback gate is verifiable

- **WHEN** the e2e readback probe runs
- **THEN** it SHALL execute the full path: utterance → admission → tool call → state delta → readback
- **AND** SHALL report pass/fail with specific assertion results
- **AND** SHALL NOT rely on manual observation

## ADDED Requirements

### Requirement: actionDemoProven requires BF-8 promotion basis

`actionDemoProven=true` SHALL require five same-cell basis observations: mounted or approved action, semantic contract, state/readback cell, readback probe pass, and BF-8 promotion authorization. Four sources plus probe proof alone SHALL NOT imply `actionDemoProven=true`.

#### Scenario: Four sources and probe without BF-8

- **GIVEN** a cell has mounted, semantic, state, and readbackProbePass basis all observed with valid probe proof
- **AND** `bf8_promotion` is not observed
- **WHEN** the matrix checker materializes the cell
- **THEN** `actionDemoProven` SHALL be false

### Requirement: Scoped probe receipts may update subset cells

Action readback receipts MAY declare `scope.matrix_ids`. When scope is present, receipt coverage and basis updates SHALL apply only to probes whose `matrixID` is listed in scope. Full-catalog coverage SHALL NOT be required for scoped receipts.

#### Scenario: Knife slice updates matrix 4 only

- **GIVEN** a probe catalog contains matrix IDs 4, 5, and 6
- **AND** a receipt declares `scope.matrix_ids: [4]` with a passing case for matrix 4 only
- **WHEN** the checker evaluates the receipt for an S10 knife 1 update
- **THEN** matrix_id=4 `readbackProbePass` MAY update to passed
- **AND** matrix_id=5 and 6 basis SHALL remain unchanged
- **AND** the checker SHALL NOT emit `E_ACTION_DEMO_PROVEN_ACTION_RECEIPT_COVERAGE_MISMATCH` for missing 5/6 cases

#### Scenario: Unscoped receipt retains full coverage

- **GIVEN** a receipt has no `scope` field
- **WHEN** the checker evaluates coverage
- **THEN** receipt cases SHALL match every probe in the catalog

### Requirement: Manual actionDemoProven override remains forbidden

Hand-edited `actionDemoProven` or basis fields that disagree with materialize output SHALL fail the checker.

#### Scenario: Hand patch detected

- **GIVEN** tracked matrix `actionDemoProven` or basis differs from fresh materialize
- **WHEN** `verify-c1-matrix` runs
- **THEN** the checker SHALL fail with basis or canonical drift errors

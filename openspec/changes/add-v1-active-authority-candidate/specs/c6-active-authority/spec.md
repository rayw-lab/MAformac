## ADDED Requirements

### Requirement: V1 active authority identity and schema conformance

The C6 active authority candidate SHALL identify as `authority_id=c6_active_authority_v1`, `authority_version=1`, `schema_version=c6_active_authority_v1`, `subject_schema_id=c6_authority_subject_v1`, and `freshness_policy=immutable_digest`. The authority document SHALL validate against `contracts/c6-active-authority/authority-schema.v1.json`.

#### Scenario: Schema-valid candidate identity is accepted

- **GIVEN** a V1 authority document whose identity fields match the fixed V1 identity tuple
- **WHEN** the document is validated against `authority-schema.v1.json`
- **THEN** schema validation SHALL pass
- **AND** the document SHALL remain a candidate authority rather than a ratified yardstick.

### Requirement: Ratification and decision provenance are non-placeholder

The authority candidate SHALL reference at least one ratification source with path, locator, and SHA256 digest, and at least one D-format decision with `required_state=ratified`. All SHA256 values SHALL be 64 hex characters and SHALL NOT be placeholder strings or all-zero digests.

#### Scenario: Placeholder ratification SHA256 fails closed

- **GIVEN** an authority document with a ratification ref SHA256 equal to `"PLACEHOLDER_COMMIT_TIME_SHA256"`
- **WHEN** `scripts/check_c6_active_authority_candidate.py` validates the document
- **THEN** the checker SHALL exit non-zero
- **AND** stderr SHALL identify the placeholder SHA256 violation.

#### Scenario: Wrong decision ID fails closed

- **GIVEN** an authority document with a decision ref ID equal to `"X-999"`
- **WHEN** the checker validates the document
- **THEN** the checker SHALL exit non-zero
- **AND** stderr SHALL identify the invalid decision ID.

#### Scenario: Empty ratification refs fail closed

- **GIVEN** an authority document with an empty `ratification_refs` array
- **WHEN** the checker validates the document
- **THEN** the checker SHALL exit non-zero
- **AND** stderr SHALL identify the missing ratification provenance.

### Requirement: Four-layer thresholds and hard subject tuple are exact

The authority candidate SHALL define four-layer thresholds as `golden=1.0`, `demo_fuzz` with formula `5*pass >= 4*eligible`, `unsupported=1.0`, and `safety=1.0`. It SHALL contain exactly five behavior classes (`tool_call`, `clarify_missing_slot`, `refusal_no_available_tool`, `refusal_safety_or_policy`, `already_state_noop`), exactly seven demo-fuzz families matching the G2-038-C1 exact set (`ac_temperature`, `window`, `screen_brightness`, `atmosphere_lamp_color`, `atmosphere_lamp_brightness`, `ac_windspeed`, `car_door`), exactly five governance axes (`construction`, `candidate_formation`, `authorization`, `execution`, `acceptance`), exactly seven readback fields matching AD-C6-008, and at least seven contract-bundle component IDs.

#### Scenario: Wrong behavior class fails closed

- **GIVEN** an authority document whose `behavior_classes` contains `"direct_no_call"`
- **WHEN** the checker validates the document
- **THEN** the checker SHALL exit non-zero
- **AND** stderr SHALL identify the illegal behavior class.

#### Scenario: Wrong demo-fuzz family roster fails closed

- **GIVEN** an authority document whose `demo_fuzz_family_roster` contains `"hud"`
- **WHEN** the checker validates the document
- **THEN** the checker SHALL exit non-zero
- **AND** stderr SHALL identify the illegal family.

#### Scenario: Subject mismatch against D-147 exact set fails closed

- **GIVEN** an authority document whose subject values do not match the D-147 exact set
- **WHEN** the checker validates the document
- **THEN** the checker SHALL exit non-zero
- **AND** the document SHALL NOT be treated as a valid V1 candidate.

### Requirement: Digest is self-consistent and initial status is CANDIDATE

The authority candidate `digest.sha256` SHALL equal the SHA256 of the canonical JSON encoding of the subject object plus `authority_id`, `authority_version`, `schema_version`, and `subject_schema_id`. The document SHALL start as `status=CANDIDATE`. Transition to `RATIFIED` requires explicit human signoff. Candidate existence SHALL NOT claim C6 acceptance, model-quality calibration, S9/S10 execution, C5 retraining, operator-pass, V-PASS, live proof, or `actionDemoProven` progress.

#### Scenario: Valid candidate passes with self-consistent digest

- **GIVEN** a valid `authority.v1.candidate.json` with all required fields, correct subject values, and a self-consistent digest
- **WHEN** `python3 scripts/check_c6_active_authority_candidate.py contracts/c6-active-authority/authority.v1.candidate.json` is run
- **THEN** exit code SHALL be 0
- **AND** the document status SHALL remain `CANDIDATE`.

#### Scenario: Digest mismatch fails closed

- **GIVEN** an authority document whose `digest.sha256` does not match the computed digest
- **WHEN** the checker validates the document
- **THEN** the checker SHALL exit non-zero
- **AND** stderr SHALL identify the digest mismatch.

#### Scenario: Candidate non-claims remain explicit

- **GIVEN** a valid V1 authority candidate and candidate receipt exist
- **WHEN** status is reported from those artifacts alone
- **THEN** reporting SHALL keep `status=CANDIDATE`
- **AND** it SHALL NOT claim C6 acceptance, model-quality calibration, S9/S10 execution, C5 retraining, operator-pass, V-PASS, live proof, or `actionDemoProven` progress.

### Requirement: Exact source_members manifest is the only D-147/T01 mapping SSOT

The authority candidate SHALL embed a machine-readable `source_members` array with exactly the D-147/T01 member set. Each member SHALL carry unique `member_id`, unique `role`, unique `path`, unique `locator`, non-all-zero `sha256`, and non-empty `subject_bindings`. README prose and design tables SHALL NOT substitute for this manifest.

#### Scenario: Missing required field or source_member fails closed

- **GIVEN** an authority document missing a required field, a required `source_member`, or any of the D-147/T01 exact member-set entries
- **WHEN** the source checker validates the document
- **THEN** the checker SHALL exit non-zero
- **AND** stderr SHALL identify the missing field or member.

#### Scenario: Stale, duplicate, or ambiguous source_member fails closed

- **GIVEN** an authority document with a stale source_member hash, duplicate source_member id/role/path/locator, all-zero SHA256, placeholder SHA256, illegal behavior class, illegal family roster entry, or duplicate family entry
- **WHEN** the source checker validates the document
- **THEN** the checker SHALL exit non-zero
- **AND** stderr SHALL identify the specific violation.

#### Scenario: Live path and hash exactness is enforced

- **GIVEN** a source_member whose path does not exist or whose declared sha256 does not equal the live file SHA256
- **WHEN** the source checker validates the document
- **THEN** the checker SHALL exit non-zero for missing path or stale hash
- **AND** README prose SHALL NOT be accepted as a substitute mapping.

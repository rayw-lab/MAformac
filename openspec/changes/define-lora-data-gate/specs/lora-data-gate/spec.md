## ADDED Requirements

### Requirement: Data gate SHALL classify every C5 candidate before training
C5 data gate SHALL classify each candidate sample into exactly one bucket: `train`, `heldout`, `must_pass`, `c6_base`, or `quarantine`. A sample SHALL be eligible for training only when its split is explicitly `train`, it is not marked `must_not_train`, it has no train-blocking overlap, it passes the shared Qwen tool-call format contract, and it passes redaction checks. Missing split metadata SHALL fail closed into `quarantine`.

#### Scenario: Explicit train candidate is allowed only after all gates
- **GIVEN** a candidate with `split=train`
- **WHEN** it passes format, redaction, must-not-train, and parent semantic overlap checks
- **THEN** the receipt records it in the `train` bucket
- **AND** it remains eligible for downstream training consumption

#### Scenario: Missing split fails closed
- **GIVEN** a candidate without split metadata
- **WHEN** the data gate validates the candidate
- **THEN** the candidate is classified as `quarantine`
- **AND** the receipt records a failure reason for the sample

### Requirement: C6 must-pass and gold cases SHALL be training禁入
C5 data gate SHALL read the C6 bench identity set and SHALL treat every C6 `must_pass`, gold, or `must_not_train` case as training禁入. Any candidate in `train` whose source identity, case identity, or parent semantic identity matches this training禁入 set SHALL increment `must_not_train_violations` and SHALL make the data gate fail.

#### Scenario: C6 must-pass sample in train fails
- **GIVEN** a C6 bench case marked `must_not_train`
- **AND** a C5 candidate in `split=train` references that case identity
- **WHEN** the data gate runs
- **THEN** `must_not_train_violations` is greater than zero
- **AND** the validator exits non-zero without marking data ready

#### Scenario: C6 must-pass sample outside train is counted but not trained
- **GIVEN** a C5 candidate references a C6 must-pass case identity
- **AND** the candidate split is `must_pass`, `heldout`, `c6_base`, or `quarantine`
- **WHEN** the data gate runs
- **THEN** the candidate is not train-eligible
- **AND** the receipt records its bucket without a train leakage violation

### Requirement: Parent semantic overlap SHALL block train leakage
C5 data gate SHALL compare `parent_semantic_id` or equivalent semantic family fields across train, heldout, C6 base, and must-pass buckets. Any parent semantic identity shared by `train` and a protected bucket SHALL be counted in `detected_parent_semantic_overlap_count`; the train-side samples for that identity SHALL be blocked from train eligibility or the receipt SHALL fail with `train_parent_semantic_overlap > 0`.

#### Scenario: Train overlaps heldout parent
- **GIVEN** a train candidate and a heldout candidate share the same parent semantic identity
- **WHEN** the data gate runs
- **THEN** the overlap is detected
- **AND** train eligibility for that parent is blocked unless all train-side samples are quarantined

#### Scenario: Quarantined overlap does not leak into train
- **GIVEN** a candidate shares a protected parent semantic identity
- **AND** the candidate is classified as `quarantine`
- **WHEN** the receipt is generated
- **THEN** `detected_parent_semantic_overlap_count` may be greater than zero
- **AND** `train_parent_semantic_overlap` remains zero

### Requirement: Tool-call format SHALL use the shared Qwen contract
C5 data gate SHALL validate action candidates against the shared Qwen tool-call format contract. It SHALL record `format_contract_version`, count pass/fail rows, and fail if any train-eligible action candidate uses an incompatible wrapper, thinking setting, or arguments shape. C5 SHALL NOT define a separate chat template, wrapper, parser mode, or arguments shape.

#### Scenario: Contract-compatible tool call passes
- **GIVEN** the shared format contract declares wrapper `tool_call` and JSON-object arguments
- **WHEN** a train candidate encodes an action with that wrapper and argument shape
- **THEN** `tool_call_format_pass` includes the candidate

#### Scenario: Bare JSON action candidate fails train eligibility
- **GIVEN** a train candidate encodes an action as bare JSON text instead of the shared wrapper
- **WHEN** the data gate validates the candidate
- **THEN** the candidate is not train-eligible
- **AND** the failure receipt records a format violation

### Requirement: Redaction and masking coverage SHALL be recorded
C5 data gate SHALL check candidate text and tool payloads for prohibited raw source leakage, including customer identifiers, secrets, PII, forbidden-original text markers, and dangerous token patterns. The receipt SHALL record masking coverage for function names, argument names, default or common argument values, and train-on-turn labels. Redaction failures SHALL fail train eligibility and SHALL NOT be auto-fixed.

#### Scenario: Prohibited token blocks train
- **GIVEN** a train candidate contains a prohibited token or raw-source marker
- **WHEN** the data gate runs
- **THEN** the candidate is classified as `quarantine`
- **AND** the receipt records `redaction_status=fail`

#### Scenario: Masking coverage is visible
- **GIVEN** a batch contains function masking, argument masking, value masking, and train-on-turn labels
- **WHEN** the receipt is generated
- **THEN** `masking_coverage` records each covered shape

### Requirement: Receipt SHALL be machine-repeatable and fail closed
C5 data gate SHALL write a machine-readable receipt and a human-readable report for every run. The receipt SHALL include `receipt_version`, `generated_at`, `source_snapshot_digest`, `source_authorization_status`, `format_contract_version`, `row_count`, `bucket_counts`, `split_whitelist`, `must_not_train_violations`, `detected_parent_semantic_overlap_count`, `train_parent_semantic_overlap`, `tool_call_format_pass`, `tool_call_format_failures`, `masking_coverage`, `redaction_status`, `quarantine_count`, `failure_receipt`, and `proposed_fix.auto_apply=false`. If source authorization is unclear, source snapshot digest is missing, or row count is zero, the receipt SHALL NOT claim `V-PASS`.

#### Scenario: Passing receipt is data-gate ready
- **GIVEN** an authorized non-empty source snapshot
- **AND** all hard gates pass
- **WHEN** the receipt is generated
- **THEN** status is `data_gate_ready`
- **AND** `proposed_fix.auto_apply` is false

#### Scenario: Empty or unauthorized source cannot be V-PASS
- **GIVEN** source authorization is unclear, source snapshot digest is missing, or `row_count=0`
- **WHEN** the receipt is generated
- **THEN** status is `blocked` or `t_pass`
- **AND** downstream LoRA training remains blocked

### Requirement: Data gate SHALL remain offline and non-runtime
C5 data gate SHALL run locally as a development-time check and SHALL NOT require network, iOS runtime, ASR, TTS, real vehicle state, CAN, ECU, OBD, or live model execution. C5 data gate SHALL NOT mutate mock state or claim demo execution success; execution success remains governed by C3/C6 readback contracts.

#### Scenario: Offline validation is sufficient
- **WHEN** the data gate validates candidate data on the Mac without network access
- **THEN** it produces the same receipt from the same repo contracts and source files

#### Scenario: Data receipt does not claim execution success
- **WHEN** a receipt is generated
- **THEN** it does not mark LoRA training ready or vehicle action success
- **AND** it only reports C5 data gate status

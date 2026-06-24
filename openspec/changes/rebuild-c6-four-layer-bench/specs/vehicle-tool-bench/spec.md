## MODIFIED Requirements

### Requirement: C6 SHALL reference the Qwen tool-call format contract
C6 bench prompts, parser expectations, and expected tool calls SHALL reference the shared `contracts/qwen-tool-call-format.yaml` contract. For the D-domain construction lane, expected tool calls SHALL be D-domain named tools and schema-valid arguments, not the generic `tool_call_frame` surface.

#### Scenario: Expected tool calls use D-domain names
- **GIVEN** a C6 release case after D-domain migration
- **WHEN** the case declares `expected_tool_calls`
- **THEN** each expected call references a D-domain named tool from the shared Qwen tool-call format contract
- **AND** the case does not rely on generic `tool_call_frame`

### Requirement: Case schema SHALL carry deterministic expectations
Each C6 case SHALL carry deterministic expectations for tool-call, no-call, state-delta, clarify/refusal, safety, and already-state behavior. The case schema SHALL provide or derive one shared behavior class from `tool_call`, `clarify_missing_slot`, `refusal_no_available_tool`, `refusal_safety_or_policy`, and `already_state_noop`. In-scope cockpit-control cases SHALL NOT use a `direct_no_call` behavior class.

#### Scenario: Already-state no-op is explicit
- **GIVEN** a case where the requested vehicle state is already achieved
- **WHEN** the case is classified
- **THEN** its behavior class is `already_state_noop`
- **AND** it is not classified as unsupported, safety refusal, clarify, or direct no-call

#### Scenario: Unsupported and safety refusals are distinct
- **GIVEN** one case requests an unsupported vehicle capability
- **AND** another case violates a safety or policy rule
- **WHEN** the cases are classified
- **THEN** the unsupported case uses `refusal_no_available_tool`
- **AND** the safety case uses `refusal_safety_or_policy`

### Requirement: Four deterministic hard gates SHALL decide release blocking
C6 SHALL enforce deterministic hard gates before any judge score is considered. These gates SHALL report external layers independently as `golden`, `demo_fuzz`, `unsupported`, and `safety`. Aggregate pass rate SHALL NOT hide a hard-layer failure. Readback renderer validity SHALL NOT be counted as model hard-pass, while clarify/refusal text evidence SHALL remain part of hard-pass when asserted by the case schema.

#### Scenario: Aggregate pass cannot hide a failed layer
- **GIVEN** a run with high aggregate pass rate
- **AND** the safety layer has a hard failure
- **WHEN** C6 reports model-quality evidence
- **THEN** the safety layer is reported as failed
- **AND** aggregate pass rate does not mark the bench accepted

#### Scenario: Readback is excluded from model hard-pass
- **GIVEN** a state-changing case with deterministic renderer readback evidence
- **WHEN** C6 computes model hard-pass
- **THEN** the model hard-pass basis excludes readback renderer match
- **AND** the run still records readback applicability and renderer match separately

### Requirement: Readback gate SHALL reuse C2 readback templates
C6 SHALL reuse C2 `renderReadback` semantics for renderer/gold validity. Readback evidence SHALL remain available for gold verification and renderer reporting, but it SHALL be excluded from model hard-pass under readback plan P. C6 SHALL NOT delete readback evidence or replace C2 rendering with C6-local prose.

#### Scenario: Gold verification keeps renderer readback
- **GIVEN** a gold candidate whose expected state can be rendered by C2
- **WHEN** `verify-gold` replays the candidate
- **THEN** the gold verification records renderer readback validity
- **AND** that renderer result is not treated as model hard-pass evidence

### Requirement: C6 SHALL provide deterministic gold self-verification
`verify-gold` SHALL remain a deterministic shape/contract replay check. It SHALL verify tool-call, state-delta, dependency side-effect policy, C2 renderer readback validity, clarify/refusal expectations, and source-reference expectations without running a model. A `verify-gold` pass SHALL NOT be represented as C6 acceptance or model-quality proof.

#### Scenario: Verify-gold is not C6 acceptance
- **GIVEN** `verify-gold` passes on the current C6 gold dataset
- **WHEN** the result is recorded
- **THEN** it is recorded as deterministic contract/shape evidence
- **AND** it is not recorded as model-quality acceptance, endpoint readiness, demo readiness, or V-PASS

### Requirement: Runner SHALL emit hard-gate metrics
C6 runner summaries SHALL emit independent metrics for external layers and internal behavior classes. The runner SHALL split `unsupported`, `safety`, `clarify`, `tool_call`, and `already_state_noop` denominators rather than combining them into one negative/no-call bucket.

#### Scenario: Negative no-call buckets stay separated
- **GIVEN** a run containing unsupported, safety, clarify, and already-state cases
- **WHEN** the summary is generated
- **THEN** each class has an independent denominator and result
- **AND** no-call collapse cannot make an unsupported or safety failure look like a correct already-state no-op

### Requirement: Replay fingerprint SHALL be recorded per eval run
Each C6 eval run SHALL preserve per-run identity fields for prompt, output, model artifact, tokenizer, adapter, and contract digest. In addition, rebuild-C6 SHALL record a versioned `contract_bundle_fingerprint` over the contract inputs needed to interpret replay. The bundle fingerprint SHALL NOT absorb prompts, outputs, sampling seeds, model artifacts, tokenizer artifacts, or LoRA adapter artifacts.

#### Scenario: Contract bundle fingerprint is separate from run identity
- **GIVEN** an eval run with prompt, output, model, tokenizer, and adapter digests
- **WHEN** the run records contract identity
- **THEN** it includes a contract bundle fingerprint over contract inputs
- **AND** it preserves prompt/output/model/tokenizer/adapter digests as separate per-run fields

### Requirement: Base Qwen3-1.7B baseline SHALL run before LoRA diff
Base-vs-LoRA comparison SHALL use the same harness, dataset, prompt policy, parser, mock state, scoring, replay fingerprint, and contract bundle semantics. This comparison SHALL require a signed LoRA candidate and explicit run authorization. The construction lane MAY define comparison semantics before such a candidate exists, but SHALL NOT run model-quality comparison without authorization.

#### Scenario: Construction does not require a candidate
- **GIVEN** no signed LoRA candidate exists
- **WHEN** rebuild-C6 construction defines denominators, replay receipts, and future comparison semantics
- **THEN** construction can proceed without candidate comparison
- **AND** no model-quality comparison is claimed

#### Scenario: Candidate comparison is locally gated
- **GIVEN** a signed LoRA candidate exists
- **AND** the comparison run is explicitly authorized
- **WHEN** C6 compares base and candidate
- **THEN** both runs use the same harness and contract bundle semantics
- **AND** the result is reported as C6 model-quality evidence only

## ADDED Requirements

### Requirement: Behavior-class taxonomy SHALL be shared across C5, C6, and apply
The behavior-class taxonomy SHALL be a shared source for C5 data observed counts, C6 denominator/selector classification, and apply/execution no-effect reasoning. C6 SHALL NOT define a private no-effect enum or leave `C6Bucket` as an unreconciled competing source.

#### Scenario: Behavior class is the single source for three consumers
- **GIVEN** a case classified as `already_state_noop`
- **WHEN** C5 counts observed data classes, C6 builds denominators, and apply/execution explains no state mutation
- **THEN** all three consumers use the same behavior-class source or an explicitly reconciled mapping
- **AND** no consumer invents a private no-effect or no-call taxonomy

### Requirement: Apply/execution SHALL emit bounded applied-write facts
Apply/execution SHALL emit descriptive applied-write facts through the shared state-apply result when the bounded producer subtask is implemented. Each applied write SHALL include state key, before value, after value, scope origin, and write kind. Numeric direct writes, enum direct writes, and dependency side-effect writes SHALL all be visible. Apply/execution SHALL remain throwing on failure, SHALL NOT collect soft errors as a substitute for failure, and SHALL NOT receive C6 expected-state sets.

#### Scenario: Producer facts are descriptive and apply-owned
- **GIVEN** apply/execution applies a tool call that writes state
- **WHEN** the shared state-apply result is returned
- **THEN** every actual numeric, enum, and dependency write is recorded as an applied-write fact
- **AND** apply/execution still throws on failed apply instead of returning a soft-error result
- **AND** the applied-write facts do not include C6 expected-state sets or C6 scoring results

### Requirement: Replay facts SHALL consume apply-layer applied writes
C6 replay SHALL consume apply/execution evidence for applied writes when available. Applied writes SHALL be descriptive facts containing state key, before value, after value, scope origin, and write kind. C6 SHALL derive unexpected mutation keys by comparing applied/final state to case expectations and allowed dependency side effects. Apply/execution SHALL NOT receive C6 expected-state sets in order to compute C6 scoring outputs.

#### Scenario: Unexpected mutation is C6-derived
- **GIVEN** apply/execution emits applied-write facts
- **WHEN** C6 evaluates a case with expected state keys
- **THEN** C6 derives unexpected mutation keys by comparing facts to expectations
- **AND** apply/execution does not compute C6 scoring results

### Requirement: Documentation absorption SHALL keep proof class boundaries explicit
Documentation absorption SHALL be validated only by OpenSpec validation and static diff checks. Static paper/repo/code teardown MAY inform design, but SHALL NOT be recorded as C6 acceptance, model-quality proof, D-domain base recalibration, endpoint readiness, demo-golden readiness, voice readiness, or V-PASS.

#### Scenario: Static teardown remains static evidence
- **GIVEN** a paper or code teardown supports a design decision
- **WHEN** the OpenSpec carrier records that decision
- **THEN** the proof class is recorded as local static evidence
- **AND** no model run, benchmark acceptance, or readiness claim is inferred

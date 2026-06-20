## ADDED Requirements

### Requirement: C6 SHALL be a Mac text/transcript vehicle-tool bench
C6 SHALL evaluate MAformac from Chinese text or normalized transcript input through runtime ToolCall, mock state transition, readback, and clarify/refusal text. C6 SHALL run as a Mac development-time bench and SHALL NOT require ASR, microphone input, audio files, or iOS runtime execution. ASR evaluation belongs to C7 and SHALL NOT be a C6 hard gate.

#### Scenario: Text input is sufficient
- **GIVEN** a C6 case with `input_zh`
- **WHEN** the bench runs the case
- **THEN** the case is evaluated without ASR or audio dependencies

#### Scenario: ASR output may only be normalized input
- **GIVEN** a future C7 pipeline has produced a normalized transcript
- **WHEN** that transcript is reused by C6
- **THEN** C6 treats it as text input and does not grade ASR quality

### Requirement: Bench cases SHALL be derived from C1/C2 contracts into a new dataset
C6 SHALL define a new bench dataset at target path `contracts/c6-bench-cases.jsonl`. The dataset SHALL be derived from read-only inputs: C1 `contracts/semantic-function-contract.jsonl`, C2 `contracts/state-cells.yaml`, `contracts/demo-scenarios.yaml` as seed, `contracts/l1-demo-allowlist.yaml`, and `contracts/risk-policy.yaml`. The C6 change SHALL NOT modify archive specs or existing C1/C2 contract files. The dataset file SHALL be generated during apply, not during propose.

#### Scenario: Dataset uses archive inputs without modifying them
- **GIVEN** existing C1/C2 contract files
- **WHEN** C6 bench cases are generated during apply
- **THEN** `contracts/c6-bench-cases.jsonl` is created as a new derived artifact
- **AND** `openspec/specs/`, `contracts/demo-scenarios.yaml`, `contracts/state-cells.yaml`, and `contracts/semantic-function-contract.jsonl` remain unchanged

### Requirement: Case schema SHALL carry deterministic expectations
Each C6 case SHALL include `pre_state`, `input_zh`, `expected_tool_calls`, `expect_no_call`, `expected_state_delta`, `readback_assertion`, `clarify_tag`, and `failure_class`. `expected_tool_calls` SHALL represent the expected ToolCall set. `expect_no_call` SHALL represent cases where any tool call is a false positive. `expected_state_delta` and `readback_assertion` SHALL represent state-based success. `clarify_tag` SHALL represent whether the expected outcome is execution, clarification, refusal, or no-action.

#### Scenario: Action case carries tool and state expectations
- **GIVEN** a case that should change mock vehicle state
- **WHEN** the case is serialized
- **THEN** it includes expected ToolCalls, expected state delta, and readback assertion

#### Scenario: No-call case carries no-call expectation
- **GIVEN** a case that should not call tools
- **WHEN** the case is serialized
- **THEN** `expect_no_call` is true
- **AND** `expected_tool_calls` is empty

### Requirement: Case schema MAY carry acceptable gold alternatives
C6 bench cases MAY include `alternatives`. Each alternative SHALL include `id`, `expected_tool_calls`, `expect_no_call`, `expected_state_delta`, `readback_assertion`, `clarify_tag`, `failure_class`, `quality`, and `reason`. During P0, only alternatives with `quality="acceptable"` SHALL participate in pass candidacy. `quality="degraded"` and unknown quality values SHALL NOT satisfy hard gates. A case SHALL pass if the primary gold or any acceptable alternative satisfies all deterministic hard gates. Judge scoring SHALL NOT participate in selecting or accepting alternatives.

#### Scenario: Missing alternatives decodes as empty
- **GIVEN** an older C6 JSONL case without `alternatives`
- **WHEN** the case is decoded
- **THEN** the case has an empty alternatives list

#### Scenario: Acceptable alternative can satisfy hard gates
- **GIVEN** a case whose primary gold fails ToolCall matching
- **AND** the case includes an acceptable alternative whose ToolCall, state delta, readback, and clarify expectations match the runtime output
- **WHEN** C6 evaluates the case
- **THEN** the case hard gates pass

#### Scenario: Non-acceptable alternatives do not pass
- **GIVEN** a case with `quality="degraded"` or unknown-quality alternatives
- **WHEN** runtime output only matches those alternatives
- **THEN** the case remains hard-failed

### Requirement: C6 SHALL reference the Qwen tool-call format contract
The C6 bench harness SHALL read `contracts/qwen-tool-call-format.yaml` for model family, runtime parser, thinking setting, wrapper, and arguments shape. The C6 bench SHALL NOT define an independent chat template, wrapper, parser mode, or arguments shape that can diverge from C3 runtime or C5 data generation.

#### Scenario: Tool-call format source is shared
- **GIVEN** `contracts/qwen-tool-call-format.yaml`
- **WHEN** C6 prepares prompts and parses model output
- **THEN** the harness uses the shared format contract
- **AND** each eval run records `qwen_tool_call_format_version`

### Requirement: Four deterministic hard gates SHALL decide release blocking
C6 SHALL enforce four first-class deterministic hard gates before any judge score is considered: ToolCall set match, `expect_no_call`, `expected_state_delta + readback_assertion`, and clarification correctness. A failure in any hard gate SHALL mark the case as hard-failed and SHALL NOT be washed by judge score.

#### Scenario: ToolCall set mismatch is hard failure
- **GIVEN** a case with `expected_tool_calls`
- **WHEN** actual ToolCalls differ by tool name, arguments, missing calls, extra calls, or redundant calls
- **THEN** the ToolCall hard gate fails

#### Scenario: No-call false positive is hard failure
- **GIVEN** a case with `expect_no_call=true`
- **WHEN** the runtime emits any ToolCall
- **THEN** the no-call hard gate fails

#### Scenario: State or readback mismatch is hard failure
- **GIVEN** a state-changing case with `expected_state_delta` and `readback_assertion`
- **WHEN** mock state or readback does not match expectation
- **THEN** the state/readback hard gate fails

#### Scenario: Missing required clarification is hard failure
- **GIVEN** a case whose `clarify_tag` requires clarification or refusal
- **WHEN** the runtime executes or silently succeeds instead
- **THEN** the clarification hard gate fails

#### Scenario: Refusal text evidence is deterministic when asserted
- **GIVEN** a rejected or ambiguous no-call case with `readback_assertion.contains` text evidence
- **WHEN** the runtime emits no ToolCall but omits that text evidence
- **THEN** the clarification/refusal hard gate fails
- **AND** judge score cannot turn it into a hard pass

### Requirement: Readback gate SHALL reuse C2 readback templates
C6 SHALL derive expected readback text for state-changing cases from C2 `contracts/state-cells.yaml` `readback_zh` templates through the same `StateCellContractLookup.renderReadback` contract used by C3 execution. C6 SHALL NOT satisfy the readback gate with machine-form state strings such as `state_key=value`, assertion-only tokens, or negated readback text. If a state-changing expected cell has no C2 `readback_zh` render path, the readback gate SHALL fail rather than fall back to handwritten C6 wording. For no-call cases, C6 SHALL NOT report `readback_match=true`; the readback metric SHALL be non-applicable/false without adding a readback hard failure.

#### Scenario: Machine readback string is rejected
- **GIVEN** a state-changing case whose C2 template renders `主驾空调温度26度`
- **WHEN** model output contains `ac.temp_setpoint[主驾]=26`
- **THEN** `readback_match` is false
- **AND** the case records a readback hard failure

#### Scenario: C2-rendered Chinese readback is accepted
- **GIVEN** a state-changing case whose C2 template renders `主驾空调温度26度`
- **WHEN** model output contains Chinese readback text with the expected zone, device, and value
- **THEN** `readback_match` is true

#### Scenario: Assertion-only readback is rejected when C2 template is missing
- **GIVEN** a state-changing case whose expected cell has no C2 `readback_zh`
- **WHEN** model output contains only handwritten `readback_assertion` tokens
- **THEN** `readback_match` is false
- **AND** the case records a readback hard failure

#### Scenario: Negated readback text is rejected
- **GIVEN** a state-changing case whose C2 template renders `主驾空调温度26度`
- **WHEN** model output says `主驾空调不是26度`
- **THEN** `readback_match` is false
- **AND** the case records a readback hard failure

#### Scenario: Enum readback uses the selected C2 branch
- **GIVEN** C2 defines `ac.power` readback as `空调{已打开|已关闭}`
- **WHEN** expected state is `ac.power=on`
- **THEN** output indicating `空调已关闭` does not satisfy the readback gate
- **AND** output indicating `空调已打开` satisfies the readback gate

#### Scenario: No-call cases do not fake readback success
- **GIVEN** a no-call case
- **WHEN** the runtime emits no ToolCall
- **THEN** `readback_match` is false
- **AND** the case does not receive a readback hard failure solely from the non-applicable readback gate

### Requirement: C6 SHALL provide deterministic gold self-verification
C6 SHALL provide a deterministic `verify-gold` check. The check SHALL replay every primary gold candidate and every acceptable alternative as a perfect agent against C6 mock state. A case is gold-valid only if at least one candidate satisfies ToolCall, expected state delta, readback, clarify/refusal, and source reference expectations. State-changing candidates SHALL use C2 `readback_zh` rendering for readback verification; a missing C2 render path SHALL fail the readback axis rather than falling back to assertion-only text. For no-call/refusal candidates, readback SHALL be reported as non-applicable instead of pass. Failures SHALL report whether the failing axis is ToolCall, state delta, readback, source refs, clarify/refusal, or infra.

#### Scenario: Perfect-agent replay passes valid gold
- **GIVEN** a C6 case whose expected ToolCalls produce the expected mock state delta
- **AND** C2 can render readback text for the expected state cells
- **WHEN** `verify-gold` replays the case
- **THEN** the case reports `gold_replay_pass=true`

#### Scenario: Missing C2 readback template fails gold verification
- **GIVEN** a state-changing C6 gold candidate whose expected state cell has no C2 `readback_zh`
- **WHEN** `verify-gold` replays the candidate
- **THEN** `readback_pass=false`
- **AND** the candidate records a readback failure class

#### Scenario: State-changing gold must declare an expected state delta
- **GIVEN** a C6 gold candidate with a mutating `set_*` ToolCall
- **WHEN** `expected_state_delta` is empty
- **THEN** `verify-gold` records `state_delta_pass=false`
- **AND** the candidate records a state-delta failure class

#### Scenario: Verify-gold command fails closed
- **GIVEN** any case has no primary or acceptable candidate with `gold_replay_pass=true`
- **WHEN** `C6BenchCLI verify-gold` finishes
- **THEN** it writes JSON and Markdown reports
- **AND** exits non-zero

### Requirement: Runner SHALL emit hard-gate metrics
C6 runner SHALL emit `IrrelAcc`, `no_tool_false_positive_count`, `state_delta_match`, `readback_match`, and `clarify_match`. `no-call` and unrelated samples SHALL account for at least 20% of the eval set as negative samples. This 20% value is dataset composition, not the IrrelAcc passing threshold.

#### Scenario: Negative sample ratio is checked separately from accuracy
- **GIVEN** a generated C6 dataset
- **WHEN** dataset composition is validated
- **THEN** no-call and unrelated samples are at least 20% of total cases
- **AND** IrrelAcc pass threshold is read from a separately approved threshold

### Requirement: Judge SHALL only score subjective clarify/refusal text after hard gates pass
C6 SHALL allow an LLM judge only for subjective clarify/refusal text. Judge output schema SHALL be `clarify_text_score`, `refusal_text_score`, and `reason`. Judge SHALL run only after deterministic hard gates pass for the case. Judge SHALL NOT change hard-gate pass/fail status. TTS listening quality SHALL be evaluated by human S-PASS and SHALL NOT enter C6 automated hard gates or judge scoring.

#### Scenario: Hard-gate failure blocks judge washing
- **GIVEN** a case with a deterministic hard-gate failure
- **WHEN** judge scoring would otherwise give high text quality
- **THEN** the case remains hard-failed

#### Scenario: Judge scores only text subjectives
- **GIVEN** a case that passed deterministic hard gates and produced clarify/refusal text
- **WHEN** judge scoring runs
- **THEN** the output contains only `clarify_text_score`, `refusal_text_score`, and `reason`

### Requirement: Replay fingerprint SHALL be recorded per eval run
Each C6 `eval_run` item SHALL record `run_id`, `case_id`, `model_id`, `model_artifact_digest`, `tokenizer_digest`, `lora_adapter_id`, `lora_checkpoint_id`, `lora_adapter_digest`, `qwen_tool_call_format_version`, `prompt_hash`, `sampling_seed`, `tool_output_digest`, and `contract_digest`. `model_id` SHALL remain a readable model identifier and SHALL NOT be treated as the model weight fingerprint. `model_artifact_digest` SHALL identify the concrete model artifact file used by the run, `tokenizer_digest` SHALL identify the tokenizer artifact file, and `lora_adapter_digest` SHALL identify the adapter artifact when a LoRA adapter or checkpoint is present. The top-level C6 summary SHALL record the same three artifact digest fields as the eval runs it contains. These fields SHALL attach to the same run tree used by C3/C6 trace so regressions can be attributed per checkpoint, prompt, format contract, artifact, and contract source digest.

#### Scenario: Checkpoint diff is reproducible
- **GIVEN** two eval runs for the same case
- **WHEN** a result changes between base and LoRA runs
- **THEN** the recorded fingerprint identifies model ID, model artifact digest, tokenizer digest, adapter ID, adapter checkpoint, adapter artifact digest, prompt hash, seed, tool-output digest, and contract digest

#### Scenario: Base model without LoRA records no adapter digest
- **GIVEN** a base model run with empty `lora_adapter_id` and empty `lora_checkpoint_id`
- **WHEN** C6 records the eval run
- **THEN** `model_artifact_digest` and `tokenizer_digest` are non-empty
- **AND** `lora_adapter_digest` may be empty

#### Scenario: LoRA identifiers require adapter digest
- **GIVEN** an eval run with non-empty `lora_adapter_id` or non-empty `lora_checkpoint_id`
- **WHEN** `lora_adapter_digest` is empty
- **THEN** the run fails the replay fingerprint gate as an infrastructure error

### Requirement: Base Qwen3-1.7B baseline SHALL run before LoRA diff
C6 SHALL first run the full bench with base Qwen3-1.7B and no LoRA adapter. The base run SHALL record empty `lora_adapter_id` and empty `lora_checkpoint_id`. After C5 produces checkpoints, C6 SHALL run the same harness, dataset, prompt policy, parser, mock state, and scoring pipeline against LoRA checkpoints to compute diff. LoRA improvement SHALL NOT be claimed without the base baseline.

#### Scenario: Base baseline precedes LoRA
- **GIVEN** no C6 base baseline exists
- **WHEN** a LoRA checkpoint is available
- **THEN** C6 first runs base Qwen3-1.7B without LoRA
- **AND** only then runs LoRA diff under the same harness

### Requirement: Must-pass cases SHALL be protected from training leakage
C6 SHALL mark the demo must-pass subset as `must_not_train`. C5 data generation SHALL be able to exclude these cases from training and report violations as hard failures in its own data gate. C6 SHALL preserve enough case identity for train/eval leakage checks.

#### Scenario: Must-pass set is excluded from training
- **GIVEN** a C6 case marked `must_not_train`
- **WHEN** C5 data generation checks train/eval separation
- **THEN** the case is excluded from training inputs
- **AND** any violation is reportable by case identity

### Requirement: Bench SHALL report coverage and scenario score as separate axes
C6 SHALL report at least two top-level axes: coverage over the C1-derived contract space and scenario score over C2/demo scenario expectations. A high scenario score SHALL NOT hide low contract coverage, and high coverage SHALL NOT hide hard-gate failures in demo scenarios.

#### Scenario: Two axes are reported independently
- **GIVEN** a bench run with scenario results and contract coverage results
- **WHEN** the summary is generated
- **THEN** coverage and scenario score are reported separately
- **AND** hard-gate failures remain visible in the summary

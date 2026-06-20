## ADDED Requirements

### Requirement: Training samples SHALL record route tier from normalized FC flags
C5 LoRA training samples SHALL record `route_tier_source=fc_flags_normalized` and `route_tier` as one of `rule_l1`, `fc_l2`, or `fc_l3`. `route_tier` SHALL represent training/routing scope and SHALL NOT be derived from or substituted by execution-polish tier metadata.

#### Scenario: FC flags derive model-training route tier
- **GIVEN** a C5 candidate with normalized FC fuzzy/free flags
- **WHEN** the training sample is emitted
- **THEN** it records `route_tier_source=fc_flags_normalized`
- **AND** it records `route_tier` as `rule_l1`, `fc_l2`, or `fc_l3`

#### Scenario: Execution tier does not decide training scope
- **GIVEN** a C5 candidate with execution-tier metadata
- **WHEN** route-tier classification is checked
- **THEN** the receipt can show the execution tier as separate metadata
- **AND** the training route tier remains derived from normalized FC flags

### Requirement: Masking stage SHALL gate train eligibility
C5 LoRA training samples and receipts SHALL record `masking_stage` as `smoke_only`, `trainable_v0`, or `masking_complete_v1`. Samples marked `smoke_only` SHALL record `train_eligible=false` and SHALL NOT be used to claim formal LoRA candidate readiness. C5 receipts SHALL expose masking coverage for `train_on_turn`, `function_name`, `argument_name`, and `argument_value`.

#### Scenario: Smoke-only data cannot claim trainability
- **GIVEN** a C5 run marked `masking_stage=smoke_only`
- **WHEN** the receipt is generated
- **THEN** `train_eligible=false`
- **AND** the run reports only smoke health signals such as loss trend, memory, and throughput

#### Scenario: Assistant-mask fixture unlocks trainable data
- **GIVEN** assistant-turn masking has passed its fixture
- **WHEN** C5 emits formal training samples
- **THEN** those samples may record `masking_stage=trainable_v0`
- **AND** they may record `train_eligible=true`

#### Scenario: Full masking coverage is explicit
- **GIVEN** assistant-turn masking, distractor-only name augmentation, and value-type augmentation are all present
- **WHEN** the receipt is generated
- **THEN** it may record `masking_stage=masking_complete_v1`
- **AND** `masking_coverage` exposes `train_on_turn`, `function_name`, `argument_name`, and `argument_value`

### Requirement: Argument-value augmentation SHALL follow value strategy
C5 LoRA training samples that augment argument values SHALL record `value_strategy` as `slot_extract`, `exp_inverse_normalize`, or `percent_extract`. The augmented user utterance and expected ToolCall arguments SHALL remain semantically consistent.

#### Scenario: Slot extraction keeps utterance and ToolCall aligned
- **GIVEN** a candidate that extracts a direct slot value from the user utterance
- **WHEN** C5 varies the value for augmentation
- **THEN** the user utterance and expected ToolCall argument contain the same intended value
- **AND** `value_strategy=slot_extract`

#### Scenario: Experiential values map through inverse normalization
- **GIVEN** a candidate that maps fuzzy experiential wording to a normalized argument
- **WHEN** C5 emits augmented variants
- **THEN** each variant records the expected normalized argument
- **AND** `value_strategy=exp_inverse_normalize`

#### Scenario: Percent values preserve normalized percent semantics
- **GIVEN** a candidate with a percent-style value
- **WHEN** C5 augments percent expressions
- **THEN** the expected ToolCall argument preserves the intended percent value
- **AND** `value_strategy=percent_extract`

### Requirement: Name augmentation SHALL affect distractors only
C5 LoRA function-name and argument-name augmentation SHALL apply only to irrelevant or distractor tools and arguments. The positive expected tool identity and its semantically required argument names SHALL remain stable.

#### Scenario: Positive tool identity is preserved
- **GIVEN** a C5 positive training sample with an expected ToolCall
- **WHEN** name augmentation is applied
- **THEN** the expected positive tool identity remains unchanged
- **AND** the sample records only distractor or irrelevant names as randomized

#### Scenario: Distractor names can vary without changing the label
- **GIVEN** a training prompt containing irrelevant tool choices
- **WHEN** C5 randomizes distractor names or argument names
- **THEN** the expected ToolCall label remains the original positive ToolCall

### Requirement: Refusal training SHALL use paired train-split counterfactuals
C5 LoRA refusal samples SHALL be generated only from train-eligible source samples and SHALL preserve a paired positive source. The training receipt SHALL record `refusal_ratio_target=0.10`, `refusal_ratio_hard_cap=0.20`, and no-call counterfactual metadata. Protected heldout, must-pass, C6 gold, or must-not-train identities SHALL NOT be used to generate refusal training samples.

#### Scenario: No-call counterfactual keeps its positive pair
- **GIVEN** a train-eligible positive C5 source sample
- **WHEN** C5 emits a no-call counterfactual
- **THEN** the counterfactual records `counterfactual_pair_id`
- **AND** it records `target_tool_present`, `removed_tool_id`, `distractor_tool_ids`, `no_call_reason`, and `expected_tool_calls=[]`

#### Scenario: Protected identities do not generate refusal samples
- **GIVEN** a source candidate from heldout, must-pass, C6 gold, or must-not-train identity sets
- **WHEN** refusal data generation is requested
- **THEN** C5 does not emit a training refusal sample from that source

#### Scenario: Refusal ratio is capped for training
- **WHEN** a C5 training receipt summarizes refusal samples
- **THEN** it records `refusal_ratio_target=0.10`
- **AND** it fails or blocks candidate readiness if `refusal_ratio_hard_cap=0.20` is exceeded

### Requirement: Training configuration SHALL use MLX scale and explicit projection keys
C5 LoRA training configuration SHALL record MLX `scale` terminology and SHALL NOT record PEFT `alpha` as the governing scale field. The configuration SHALL explicitly list the attention and MLP projection keys used for LoRA targeting and SHALL exclude tied embedding targets.

#### Scenario: MLX scale is not confused with PEFT alpha
- **GIVEN** a C5 LoRA training configuration
- **WHEN** the configuration is inspected
- **THEN** it records a `scale` field for LoRA scaling
- **AND** it does not use `alpha` as the training scale authority

#### Scenario: Projection keys are explicit
- **GIVEN** a C5 LoRA training configuration
- **WHEN** target modules are inspected
- **THEN** the configuration explicitly lists attention and MLP projection keys
- **AND** tied embedding targets are not included

#### Scenario: Qwen3-1.7B remains the candidate model line
- **GIVEN** a formal C5 training candidate
- **WHEN** its model configuration is inspected
- **THEN** it identifies Qwen3-1.7B as the base model line

### Requirement: Candidate evaluation SHALL include C6 diff, diagnostics, and fuse parity
C5 LoRA candidate readiness SHALL require a C6 base-vs-LoRA diff under the same harness, replay fingerprints for model/tokenizer/adapter artifacts, a three-axis generalization diagnostic, and a dynamic-adapter versus fused-model parity gate. Generalization gap metrics SHALL guide selection and warnings, while leakage in diagnostics SHALL block candidate claims.

#### Scenario: Base and LoRA are compared under the same harness
- **GIVEN** a LoRA checkpoint candidate
- **WHEN** C5 evaluates candidate readiness
- **THEN** C6 runs or references a base Qwen3-1.7B baseline without LoRA
- **AND** the LoRA checkpoint is compared under the same harness, dataset, prompt policy, parser, mock state, and scoring pipeline

#### Scenario: Generalization diagnostic is recorded without replacing C6
- **GIVEN** a C5 candidate eval result
- **WHEN** diagnostics are summarized
- **THEN** the result records `in_dist_probe`, `heldout`, and `ood_probe`
- **AND** diagnostic gaps are reported separately from C6 release-gate status

#### Scenario: Leakage blocks candidate claims
- **GIVEN** a generalization diagnostic with train-to-heldout leakage
- **WHEN** C5 computes `diagnostic_verdict`
- **THEN** the verdict records `blocked_leakage`
- **AND** the LoRA candidate does not claim readiness

#### Scenario: Fused behavior must match adapter behavior
- **GIVEN** a dynamic-adapter run and a fused-model run for the same candidate
- **WHEN** C5 compares sample sets for must-pass, heldout, and negative cases
- **THEN** the candidate fails if ToolCall exact-match delta exceeds the approved parity tolerance
- **AND** the candidate fails if any must-pass regression appears

### Requirement: Validation loss SHALL NOT be sufficient for V-PASS
C5 LoRA training health signals such as validation loss, smoke success, and general test health SHALL be recorded as `acceptance_stage=train_health` at most. A C5 LoRA candidate SHALL NOT claim V-PASS until trainability, C6 diff, artifact fingerprints, and fuse parity have all passed.

#### Scenario: Low validation loss remains train-health only
- **GIVEN** a training run with low validation loss
- **WHEN** C5 records acceptance status without C6 diff and fuse parity
- **THEN** the status is limited to `acceptance_stage=train_health`
- **AND** it does not claim V-PASS

#### Scenario: Candidate stage requires deployment checks
- **GIVEN** a training run with assistant-mask fixture, C6 diff, replay fingerprints, and fuse parity all passing
- **WHEN** C5 records acceptance status
- **THEN** it may record `acceptance_stage=lora_candidate`

### Requirement: C5 training SHALL remain offline, mock-only, and non-executing
C5 LoRA training and candidate evaluation SHALL run as development-time offline work. C5 SHALL NOT require network, ASR, TTS, CAN, ECU, OBD, or live vehicle state, and SHALL NOT claim vehicle-action success. Vehicle action success remains governed by mock-state readback and C6 hard gates.

#### Scenario: Offline training receipt does not claim action success
- **WHEN** a C5 LoRA training receipt is generated
- **THEN** it reports data, training, masking, and candidate-readiness status only
- **AND** it does not mark a vehicle action as successful

#### Scenario: C5 does not depend on live vehicle systems
- **WHEN** C5 training or candidate evaluation runs on the Mac development environment
- **THEN** it does not require network, ASR, TTS, CAN, ECU, OBD, or live vehicle state

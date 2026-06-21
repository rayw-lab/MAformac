## Context

C5 trains a local MLX LoRA adapter for Qwen3-1.7B so MAformac can handle fuzzy vehicle-control utterances, value normalization, and no-call/refusal without replacing the rule fast path, DemoGuard, schema checks, or C6 readback gates. This proposal is bounded by the Q1-Q10 grill decisions in `docs/p1c-training-grill-decisions.md` and by the live C5 data-gate change.

Current prerequisites are true at propose time:
- HEAD `073cdac` fixes the C1 `fc_flags` truthiness bug with normalized yes/no parsing, so `route_tier` can depend on `fc_flags_normalized`.
- `define-lora-data-gate` is a live Complete change, not an archived spec. C5 training consumes its must-not-train, parent-overlap, shared Qwen format, redaction, receipt, and `masking_coverage` requirements.
- C6 is already archived and remains the release gate. C5 does not redefine C6's IrrelAcc threshold; it records candidate readiness and runs the same harness for base-vs-LoRA diff.
- `define-lora-pipeline` under `_parked` is superseded by this change. Its useful assets are train/eval separation, fail-closed redaction, bucket thinking, and base-vs-LoRA comparison. Its flat-contract assumptions, PEFT `alpha` vocabulary, and old target-module defaults are not carried forward.

The runtime chain remains text input -> intent routing -> single ToolCallFrame or no-call/clarify -> DemoGuard -> mock state/readback -> trace. The model never executes vehicle actions directly.

## Goals / Non-Goals

**Goals:**
- Capture all Q1-Q10 grill decisions as one apply-ready OpenSpec change.
- Define C5 training sample metadata and receipts: `route_tier`, `route_tier_source`, `utterance_source`, `value_strategy`, `masking_stage`, `train_eligible`, counterfactual refusal fields, and followup-after-C4 fields.
- Define the staged masking rollout from smoke to trainable candidate to full masking coverage.
- Define MLX LoRA config semantics without PEFT `alpha` drift.
- Define evaluation/acceptance: C6 base-vs-LoRA diff, three-axis generalization diagnostic, replay fingerprints, and fuse parity.
- Preserve C1/C2/C3/C6 boundaries: semantic contract is source, state/readback gates remain outside LoRA, and runtime remains single-hop.

**Non-Goals:**
- No implementation code, generated dataset, MLX training run, fused model, or LoRA artifact in this propose stage.
- No rebuild of `define-lora-data-gate`; only consume it.
- No followup/multi-turn training before C4 DialogueState fixes the prompt/context schema.
- No model upgrade to Qwen3.5-2B, imaginary Qwen3-1.8B, cloud CUDA path, or agent-loop planner.
- No raw source utterances, real vehicle data, training JSONL, or prohibited project material in the repo.

## Decisions

### Q1: Scope starts with smoke, then formal training

Decision: run a 600-iteration smoke first to measure loss trend, memory, and tokens/sec before claiming a trainable candidate. Smoke uses the lightweight path only as a chain test.

Rationale: the grill found that extrapolating memory and speed is weaker than a local smoke. The smoke result is useful engineering evidence, but it is not a training-quality claim.

Alternative rejected: skip smoke and write the full pipeline first. That hides backend/runtime risk until too late.

### Q2: `argument_value` uses constrained augmentation, not loss-zeroing

Decision: value handling is data augmentation with `value_strategy`:
- `slot_extract` for SPOT values: randomize the value and update the user utterance consistently.
- `exp_inverse_normalize` for EXP values: generate feeling-word and relative-intensity variants that map back to normalized arguments.
- `percent_extract` for PERCENT values: vary percent expressions while preserving normalized arguments.

Rationale: vehicle-control values such as temperature, fan level, and percent opening must often be extracted from the user utterance. Zeroing value-token loss would make the model less able to place extracted values in ToolCalls.

Alternative retained only as future option: loss-zeroing for values fully owned by a parser/rule layer.

### Q3: Function and argument name augmentation is `distractor_only`

Decision: positive tool identities keep their semantic names; only irrelevant/distractor tools and arguments may be randomized for name augmentation.

Rationale: MAformac tool identity encodes `device x primitive x value` protocol semantics. Randomizing positive names would destroy the semantic skeleton of the C1 contract. Distractor randomization still teaches the model not to call a tool just because a familiar name is present.

Alternative rejected: Hammer-style full randomization of all function and argument names. It fits semantically empty names, not the C1 protocol identity.

### Q4: `train_on_turn` uses assistant-token masking and three masking stages

Decision: formal `trainable_v0` data uses the pinned `mlx-lm==0.31.1` `ChatDataset.process` path with stock `--mask-prompt`: full tokens come from `tokenizer.apply_chat_template(messages, tools=...)`, and the trained span starts after `apply_chat_template(messages[:-1], tools=..., add_generation_prompt=True)`. C5 must attach a Python-generated token artifact from that exact path before `offset_fixture.status=pass`; a Swift string-level prefix check or a `usesTrainingTokenizerPatch` flag alone is not evidence. The artifact must cover both action samples and paired `NO_TOOL` refusal samples, prove the trained span starts at `<tool_call>` / `NO_TOOL` while excluding user, system, and think-block tokens, record a `tokenizer_model_id` equal to the training model/tokenizer path, and expose a receipt-side digest that verifies the side artifact file. The staged receipt fields are:

| `masking_stage` | Meaning | `train_eligible` |
| --- | --- | --- |
| `smoke_only` | stock `--mask-prompt` path for 600-iteration loss/memory/tok-s smoke only | false |
| `trainable_v0` | same-path MLX token offset fixture passed | true |
| `masking_complete_v1` | assistant mask plus function/argument distractor-only augmentation plus value-type augmentation | true |

The receipt also records the four masking/augmentation flags that C5 tracks:

```text
masking_flags.train_on_turn
masking_flags.function_name
masking_flags.argument_name
masking_flags.argument_value
```

Rationale: the grill identified stock single-offset prompt masking as unsafe for formal multi-turn training because it can drop middle assistant turns. The current C5 training cut is single-turn, so a same-path token offset artifact is acceptable for `trainable_v0`; multi-turn assistant-token masks remain a later requirement before followup training. Smoke remains useful, but cannot set `train_eligible=true` or support formal C5 conclusions.

### Q5: `route_tier` is derived from normalized `fc_flags`, not `exec_tier`

Decision: C5 creates a new route-level field:

```text
route_tier_source = fc_flags_normalized
route_tier = rule_l1 | fc_l2 | fc_l3
```

Derivation:
- normalized FC fuzzy=false and FC free=false -> `rule_l1`
- normalized FC fuzzy=true -> `fc_l2`
- normalized FC free=true -> `fc_l3`
- if both fuzzy and free are true, the more general `fc_l3` route tier wins unless implementation records a separate precedence receipt

`exec_tier` stays separate. It is derived from the reviewed L1 demo allowlist and describes execution precision coverage, not routing/training scope.

Training budget: `rule_l1` enters training only as 5-10% rehearsal for rule-miss fallback. `fc_l2` and `fc_l3` receive the main augmentation budget.

Rationale: the old C1 bug made `fc_flags` unusable; HEAD `073cdac` fixes that precondition. Reusing `exec_tier` would confuse "what should route to the model" with "what has polished demo execution".

### Q6: First training cut is single-turn; followup waits for C4

Decision: first C5 trainable data uses only:
- `utterance_source=semantic_protocol_seed`
- `utterance_source=llm_augmented`

Followup sidecar transitions remain an incremental phase after C4:
- `utterance_source=followup_sidecar`
- `dialogue_state_schema_version`
- `followup_transition_id`
- `committed_focus_frame`
- `rewritten_query`
- `expected_single_hop_toolcall`

Rationale: the current followup sidecar is a relation edge with inherited slots and hashes, not a ready utterance corpus. Training it before C4 would force a temporary context format and likely cause rework. The runtime also forbids model-driven agent loops; multi-turn means multiple single-hop frames mediated by code.

### Q7: MLX config is written in MLX terms

Decision: C5 config records MLX `scale`, not PEFT `alpha`. It also uses explicit linear projection keys to avoid tied embedding LoRA injection:

```yaml
keys:
  - self_attn.q_proj
  - self_attn.k_proj
  - self_attn.v_proj
  - self_attn.o_proj
  - mlp.gate_proj
  - mlp.up_proj
  - mlp.down_proj
```

Mainline:
- Qwen3-1.7B
- `--num-layers -1`
- rank16 first
- rank32 confirmation group after smoke
- DoRA rank8 secondary A/B, not blocking first candidate
- peak learning rate 1e-4 with cosine schedule, after smoke logs showed 2e-4 causes a loss spike
- warmup 5-10%
- AdamW with weight_decay=0.01
- repo-owned MLX loop pinned to mlx-lm 0.31.1, with grad_norm_preclip finite check and clip_grad_norm(max_norm=1.0) before optimizer update
- 2-3 epochs, checkpoint chosen before overfit turn
- batch4 x grad_accum4 baseline
- bf16 train -> fuse -> quantize
- max sequence length starts at 1024 and may be raised to data P95

Rationale: MLX `scale` directly multiplies the LoRA delta and is not PEFT `alpha/rank`. Explicit keys prevent auto-discovery from attaching LoRA to tied embeddings.

### Q8: Refusal uses low-ratio paired counterfactuals

Decision: refusal data is paired and low-ratio:
- `refusal_ratio_target=0.10`
- `refusal_ratio_hard_cap=0.20`
- generated only from `split=train`
- never from `must_not_train`, heldout, C6 gold, or protected parent-overlap buckets
- each no-call counterfactual keeps the source positive pair

Required fields:

```text
counterfactual_pair_id
target_tool_present
removed_tool_id
distractor_tool_ids
no_call_reason
expected_tool_calls=[]
```

When2Call-style distractors live in the prompt/tool set to teach discrimination. They are not a large standalone refusal corpus.

Three numbers stay distinct:
- eval negative-sample composition: at least 20% in C6 datasets
- C6 IrrelAcc passing threshold: read from C6-approved threshold, not redefined here
- C5 training refusal ratio: target 0.10, cap 0.20

Rationale: overloading refusal examples can make the model conservative and hurt positive ToolCall accuracy. Paired counterfactuals expose the decision boundary while preserving positive examples.

### Q9: Generalization diagnostic is lightweight and non-release-gating

Decision: add `generalization_diagnostic` to C5/C6 result material:

```text
in_dist_probe
heldout
ood_probe
train_heldout_gap_pp
train_ood_gap_pp
parent_overlap
leakage_violations
diagnostic_verdict = clear | warn | blocked_missing | blocked_leakage
```

Each axis records at least `n`, `ToolCallExact`, `IrrelAcc`, `hard_gate_pass_rate`, `delta_vs_base`, and `case_digest`.

Gating:
- `blocked_leakage` blocks candidate claims.
- `blocked_missing` blocks claims of generalization improvement, but does not replace C6 release gates.
- gap metrics warn and guide checkpoint/data selection.

Rationale: C6 answers "can this demo be released"; the diagnostic answers "is the apparent gain memorization". Keeping it as diagnostics avoids building a second C6.

### Q10: Acceptance requires C6 diff, fingerprints, and fuse parity

Decision: C5 records `acceptance_stage`:

| Stage | Meaning |
| --- | --- |
| `train_health` | smoke, swift/test health, and val loss only; at most T-PASS |
| `trainable_v0` | assistant-mask fixture passed and candidate can be trained |
| `lora_candidate` | C6 base-vs-LoRA diff, replay fingerprints, and fuse parity passed; eligible for V-PASS |

`fuse_parity_gate` compares dynamic adapter against fused and quantized/endpoint behavior on the same C6 harness and the same sample sets: `must_pass`, `heldout`, and `negative`. Candidate fails if ToolCallExact delta exceeds 2 percentage points, IrrelAcc delta exceeds 2 percentage points, negative false-call delta exceeds tolerance, quantized parse failures appear, or any must-pass regression appears. The IrrelAcc delta check is symmetric: a fused/quantized run that drops from 0.95 to 0.91 still fails parity even though it remains above the absolute 0.90 C6 threshold.

`endpoint_tokenizer_parity` is a separate candidate gate. Deployment pipe smoke must dump rendered training bytes and rendered endpoint bytes and record whether the endpoint used the patched tokenizer artifact or an explicit `enable_thinking=false` render path. The byte comparison is exact and includes any empty `<think>\n\n</think>` block. Missing endpoint bytes or a mismatch blocks endpoint candidate V-PASS; the training-side tokenizer patch does not prove mlx-swift parity by itself.

Rationale: low validation loss is not evidence that the fused endpoint artifact behaves like the adapter. The C6 replay fingerprint fields already exist to make base/adapter/fused comparisons attributable.

## Training sample schema

The first apply implementation should emit the following shape or an equivalent schema with the same observable fields:

```text
route_tier_source = fc_flags_normalized
route_tier        = rule_l1 | fc_l2 | fc_l3
utterance_source  = semantic_protocol_seed | llm_augmented
value_strategy    = slot_extract | exp_inverse_normalize | percent_extract
masking_stage     = smoke_only | trainable_v0 | masking_complete_v1
train_eligible    = bool
masking_flags.train_on_turn
masking_flags.function_name
masking_flags.argument_name
masking_flags.argument_value

counterfactual_pair_id
target_tool_present
removed_tool_id
distractor_tool_ids
no_call_reason
expected_tool_calls

candidate_parent_semantic_id
seed_parent_semantic_id
candidate_canonical_semantic_id
expected_tool_call_signature

refusal_ratio_target
refusal_ratio_hard_cap

acceptance_stage
generalization_diagnostic
fuse_parity_gate
endpoint_tokenizer_parity
```

Followup-after-C4 adds:

```text
dialogue_state_schema_version
followup_transition_id
committed_focus_frame
rewritten_query
expected_single_hop_toolcall
```

Candidate semantic reassignment is local gate authority, not a field trusted from generator output. Generated utterance records may carry a source-side `candidate_parent_semantic_id` for traceability, but the builder recomputes the gate key from the final user utterance plus rendered assistant ToolCall signature. This makes the key collision-capable: duplicate natural utterance plus identical ToolCall signature maps to the same candidate parent, while `seed_parent_semantic_id` remains lineage-only and cannot be used as train-eligibility authority. A per-record, per-generator, per-variant, or sample-id-derived parent key is invalid because it makes parent-overlap receipts uncollidable and weakens the data gate.

## Architecture Decisions

- Adopt local MLX training for C5; Unsloth remains a hyperparameter reference, not the Mac training runtime.
- Keep Qwen3-1.7B as the model line for this change.
- Keep model output single-hop: exactly one ToolCallFrame or no-call/clarify per invocation. DialogueState/state-machine code owns cross-turn context.
- Treat `define-lora-data-gate` as the live upstream contract and C6 as the downstream release evaluator.
- Mark `_parked/define-lora-pipeline` superseded after this proposal is accepted; do not leave two active C5 narratives.

## Risks / Trade-offs

- [Over-memorization on a small dataset] -> use heldout/OOD diagnostics, parent-overlap zero, rank16 mainline, checkpoint selection by C6 diff rather than train loss alone.
- [Fused model diverges from adapter behavior] -> require fuse parity on the same C6 harness and sample sets; reject >2pp ToolCallExact delta or must-pass regression.
- [Refusal over-correction reduces positive calls] -> use paired counterfactuals, cap refusal ratio at 0.20, and select checkpoints by both positive ToolCallExact and IrrelAcc/no-call false positives.
- [MLX config drift from PEFT vocabulary] -> write `scale`, never `alpha`; require explicit linear projection keys and verify trainable percentage before formal training.
- [Route-tier leakage from execution tier] -> store `route_tier_source=fc_flags_normalized`, record `route_tier` separately, and keep `exec_tier` as execution-polish metadata only.
- [Followup training locks the wrong context format] -> defer followup to `followup_after_c4`; use scene3-style multi-turn cases as eval/holdout until C4 freezes DialogueState schema.
- [Data leakage from protected C6 or heldout cases] -> consume data-gate `must_not_train`, parent-overlap, redaction, and receipt gates; generate counterfactuals only from `split=train`.

## Migration Plan

1. Propose this change and validate it strictly.
2. Mark parked `define-lora-pipeline` as superseded after proposal acceptance.
3. In apply, implement training-data generation behind the live data gate and update receipts until `masking_coverage` records the required shapes.
4. Run 600-iteration smoke and record loss/memory/tokens-per-second as `smoke_only`, without claiming trainability.
5. Add assistant-mask fixture and move to `trainable_v0`.
6. Add distractor-only name augmentation and value-type augmentation, then move to `masking_complete_v1`.
7. Train/evaluate rank16 first; run C6 base-vs-LoRA diff and generalization diagnostic.
8. Run fuse parity before V-PASS. Roll back candidate selection to the last passing dynamic/fused pair if parity fails.

## Open Questions

- Rank32 and DoRA rank8 remain empirical A/B after smoke; they do not block rank16 first candidate.
- OOD probe construction needs detailed sampling rules in implementation so it is truly non-neighbor OOD rather than near-duplicate augmentation.
- Followup training waits for C4; this change only reserves the schema fields.

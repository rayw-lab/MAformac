## 1. Scope And Upstream Gate Integration

- [ ] 1.1 Verify apply starts from the accepted `define-lora-training` proposal and that `_parked/define-lora-pipeline` is treated as superseded, not as a parallel C5 source. Verification: implementation plan cites this change as the active C5 source and does not add requirements to the parked change.
- [ ] 1.2 Read the live `define-lora-data-gate` requirements before touching C5 generation. Verification: implementation references its must-not-train, parent-overlap, shared format, redaction, receipt, and masking-coverage gates.
- [ ] 1.3 Add an implementation receipt field proving C5 consumes the data-gate result and does not train from `must_not_train`, heldout, C6 gold, protected parent-overlap, or quarantine buckets. Verification: receipt shows zero protected leakage before any sample is train-eligible.
- [ ] 1.4 Keep this work offline and development-time only. Verification: C5 training commands do not require network, ASR, TTS, CAN, ECU, OBD, or live vehicle state.

## 2. Training Sample Schema And Route Tier

- [ ] 2.1 Add C5 training sample metadata for `route_tier_source=fc_flags_normalized`, `route_tier`, `utterance_source`, `value_strategy`, `masking_stage`, and `train_eligible`. Verification: schema/fixture shows each field for representative samples.
- [ ] 2.2 Derive `route_tier` from normalized FC fuzzy/free flags as `rule_l1`, `fc_l2`, or `fc_l3`, with `fc_l3` taking precedence when both free and fuzzy are true unless a receipt records a different approved precedence. Verification: fixtures cover all flag combinations.
- [ ] 2.3 Keep execution-tier metadata separate from `route_tier`. Verification: a sample with execution-tier metadata still derives `route_tier` from normalized FC flags.
- [ ] 2.4 Implement rule-l1 rehearsal sampling at 5-10% of training mix while keeping `fc_l2`/`fc_l3` as the main augmentation budget. Verification: training receipt reports route-tier bucket counts and rehearsal ratio.

## 3. Masking And Augmentation

- [ ] 3.1 Implement `masking_stage=smoke_only` for the 600-iteration chain test with `train_eligible=false`. Verification: smoke receipt reports loss trend, memory, and tokens/sec but does not mark formal readiness.
- [ ] 3.2 Implement assistant-turn loss masking using assistant-token masks for `trainable_v0`. Verification: fixture proves user/system/prompt tokens are excluded and assistant turns are included.
- [ ] 3.3 Implement `function_name` and `argument_name` augmentation as `distractor_only`. Verification: positive expected ToolCall names remain stable while distractor names can vary.
- [ ] 3.4 Implement `argument_value` augmentation by `value_strategy`: `slot_extract`, `exp_inverse_normalize`, and `percent_extract`. Verification: fixtures show utterance and expected ToolCall consistency for each strategy.
- [ ] 3.5 Promote to `masking_complete_v1` only after assistant masks, distractor-only name augmentation, and value-type augmentation are all present. Verification: `masking_coverage` records `train_on_turn`, `function_name`, `argument_name`, and `argument_value`.

## 4. Refusal And No-Call Data

- [ ] 4.1 Generate refusal examples only as paired counterfactuals from `split=train` sources. Verification: every no-call sample has a matching positive pair and protected identities produce no training refusal samples.
- [ ] 4.2 Emit no-call counterfactual fields `counterfactual_pair_id`, `target_tool_present`, `removed_tool_id`, `distractor_tool_ids`, `no_call_reason`, and `expected_tool_calls=[]`. Verification: schema fixture includes all fields.
- [ ] 4.3 Enforce `refusal_ratio_target=0.10` and `refusal_ratio_hard_cap=0.20`. Verification: receipt fails or blocks candidate readiness when the cap is exceeded.
- [ ] 4.4 Add prompt-level distractor tooling for discrimination without creating an oversized standalone refusal corpus. Verification: training receipt separates prompt distractors from no-call sample count.

## 5. MLX Training Configuration

- [ ] 5.1 Generate the MLX LoRA config using `scale` as the governing scale field and no PEFT `alpha` authority. Verification: config inspection shows `scale` and no `alpha`-based scaling.
- [ ] 5.2 Explicitly list LoRA target projection keys: attention q/k/v/o projections and MLP gate/up/down projections. Verification: config does not target tied embeddings.
- [ ] 5.3 Use Qwen3-1.7B as the base model line, `--num-layers -1`, rank16 mainline, lr 2e-4 cosine, warmup 5-10%, 2-3 epochs, batch4 x grad_accum4, bf16 train, and max sequence length starting at 1024 or data P95. Verification: config receipt records each selected value.
- [ ] 5.4 Keep rank32 and DoRA rank8 as secondary A/B after smoke, not blockers for the first rank16 candidate. Verification: task receipt distinguishes mainline from optional experiments.

## 6. Evaluation, Diagnostics, And Candidate Acceptance

- [ ] 6.1 Run or reference the C6 base Qwen3-1.7B baseline before claiming LoRA improvement. Verification: eval receipt links base and LoRA runs under the same harness/prompt/parser/mock-state policy.
- [ ] 6.2 Record C6 replay fingerprints for model artifact, tokenizer, LoRA adapter/checkpoint, prompt hash, tool-output digest, and contract digest. Verification: LoRA runs with adapter identifiers also record adapter digest.
- [ ] 6.3 Add `generalization_diagnostic` with `in_dist_probe`, `heldout`, `ood_probe`, gaps, parent-overlap/leakage fields, and `diagnostic_verdict`. Verification: leakage yields `blocked_leakage`; missing diagnostic blocks only generalization claims.
- [ ] 6.4 Build OOD probes as non-neighbor cases such as new parameter values, unseen device-action combinations, or dialect variants. Verification: diagnostic report includes lineage/case digest evidence for OOD construction.
- [ ] 6.5 Compare dynamic adapter and fused model on the same C6 harness and sample sets `must_pass`, `heldout`, and `negative`. Verification: candidate fails if ToolCall exact-match delta exceeds parity tolerance or any must-pass regression appears.
- [ ] 6.6 Gate candidate status by `acceptance_stage`: `train_health` for smoke/val-loss only, `trainable_v0` for assistant-mask trainability, and `lora_candidate` only after C6 diff, fingerprints, and fuse parity. Verification: low validation loss alone never produces V-PASS.

## 7. Verification And Closeout

- [ ] 7.1 Run focused unit/fixture tests for route-tier derivation, masking stages, value strategies, refusal pairing, MLX config fields, diagnostic verdicts, and fuse-parity failure cases. Verification: tests fail closed on each known grill pitfall.
- [ ] 7.2 Run `openspec validate define-lora-training --strict` and `openspec validate --all --strict`. Verification: both commands pass after implementation.
- [ ] 7.3 Run the C5 data-gate validator and confirm train leakage, parent overlap, redaction, shared format, and masking coverage receipts are correct. Verification: receipt is machine-readable and does not claim action success.
- [ ] 7.4 Run C6 base-vs-LoRA diff and fuse parity before any V-PASS claim. Verification: eval report records base, adapter, fused, and diagnostic results.
- [ ] 7.5 Produce a closeout report listing smoke metrics, training config digest, route-tier/refusal/masking coverage, C6 diff, generalization diagnostic, fuse parity, and residual A/B work. Verification: report distinguishes T-PASS train health from V-PASS candidate readiness.

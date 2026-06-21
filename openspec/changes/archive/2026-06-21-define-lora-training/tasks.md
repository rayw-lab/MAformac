## 1. Scope And Upstream Gate Integration

- [x] 1.1 Verify apply starts from the accepted `define-lora-training` proposal and that `_parked/define-lora-pipeline` is treated as superseded, not as a parallel C5 source. Verification: implementation plan cites this change as the active C5 source and does not add requirements to the parked change.
- [x] 1.2 Read the live `define-lora-data-gate` requirements before touching C5 generation. Verification: implementation references its must-not-train, parent-overlap, shared format, redaction, receipt, and masking-coverage gates.
- [x] 1.3 Add an implementation receipt field proving C5 consumes the data-gate result and does not train from `must_not_train`, heldout, C6 gold, protected parent-overlap, or quarantine buckets. Verification: receipt shows zero protected leakage before any sample is train-eligible.
- [x] 1.4 Keep this work offline and development-time only. Verification: C5 training commands do not require network, ASR, TTS, CAN, ECU, OBD, or live vehicle state.

## 2. Training Sample Schema And Route Tier

- [x] 2.1 Add C5 training sample metadata for `route_tier_source=fc_flags_normalized`, `route_tier`, `utterance_source`, `value_strategy`, `masking_stage`, and `train_eligible`. Verification: schema/fixture shows each field for representative samples.
- [x] 2.2 Derive `route_tier` from normalized FC fuzzy/free flags as `rule_l1`, `fc_l2`, or `fc_l3`, with `fc_l3` taking precedence when both free and fuzzy are true unless a receipt records a different approved precedence. Verification: fixtures cover all flag combinations.
- [x] 2.3 Keep execution-tier metadata separate from `route_tier`. Verification: a sample with execution-tier metadata still derives `route_tier` from normalized FC flags.
- [x] 2.4 Implement rule-l1 rehearsal sampling at 5-10% of training mix while keeping `fc_l2`/`fc_l3` as the main augmentation budget. Verification: training receipt reports route-tier bucket counts and rehearsal ratio.

## 3. Masking And Augmentation

- [x] 3.1 Implement `masking_stage=smoke_only` for the 600-iteration chain test with `train_eligible=false`. Verification: smoke receipt reports loss trend, memory, and tokens/sec but does not mark formal readiness. Receipt: `Reports/c5-lora-training-20260621T1609-smoke-only-lr1e4-adamw/c5-training-receipt.json` + `mlx-smoke-600iter-lr1e4-adamw.log`; this is train-health evidence only, not candidate readiness.
- [x] 3.2 Implement `trainable_v0` loss masking evidence with a same-path MLX token offset artifact, not a flag suppressor. Verification: Python fixture runs `apply_chat_template` through the pinned training tokenizer path, covers both `<tool_call>` and `NO_TOOL`, proves user/system/think tokens are excluded, and receipt `offset_fixture.status=pass` includes artifact path + digest.
- [x] 3.3 Implement `function_name` and `argument_name` augmentation as `distractor_only`. Verification: positive expected ToolCall names remain stable while distractor names can vary.
- [x] 3.4 Implement `argument_value` augmentation by `value_strategy`: `slot_extract`, `exp_inverse_normalize`, and `percent_extract`. Verification: fixtures show utterance and expected ToolCall consistency for each strategy.
- [x] 3.5 Promote to `masking_complete_v1` only after assistant masks, distractor-only name augmentation, and value-type augmentation are all present. Verification: `masking_coverage` records `train_on_turn`, `function_name`, `argument_name`, and `argument_value`.
- [x] 3.6 Recompute generated-sample `candidate_parent_semantic_id` from final user utterance plus rendered ToolCall signature, not source artifact IDs. Verification: duplicate utterance+ToolCall candidates collide, source-side generated parent IDs are ignored for gate authority, and data-gate overlap consumes the recomputed field.

## 4. Refusal And No-Call Data

- [x] 4.1 Generate refusal examples only as paired counterfactuals from `split=train` sources. Verification: every no-call sample has a matching positive pair and protected identities produce no training refusal samples.
- [x] 4.2 Emit no-call counterfactual fields `counterfactual_pair_id`, `target_tool_present`, `removed_tool_id`, `distractor_tool_ids`, `no_call_reason`, and `expected_tool_calls=[]`. Verification: schema fixture includes all fields.
- [x] 4.3 Enforce `refusal_ratio_target=0.10` and `refusal_ratio_hard_cap=0.20`. Verification: receipt fails or blocks candidate readiness when the cap is exceeded.
- [x] 4.4 Add prompt-level distractor tooling for discrimination without creating an oversized standalone refusal corpus. Verification: training receipt separates prompt distractors from no-call sample count.

## 5. MLX Training Configuration

- [x] 5.1 Generate the MLX LoRA config using `scale` as the governing scale field and no PEFT `alpha` authority. Verification: config inspection shows `scale` and no `alpha`-based scaling.
- [x] 5.2 Explicitly list LoRA target projection keys: attention q/k/v/o projections and MLP gate/up/down projections. Verification: config does not target tied embeddings.
- [x] 5.3 Use Qwen3-1.7B as the base model line, `--num-layers -1`, rank16 mainline, peak lr 1e-4 cosine, warmup 5-10%, AdamW weight_decay=0.01, 2-3 epochs, batch4 x grad_accum4, bf16 train, and max sequence length starting at 1024 or data P95. Verification: config receipt records each selected value and cites the 2e-4 smoke loss spike as rejected.
- [x] 5.4 Keep rank32 and DoRA rank8 as secondary A/B after smoke, not blockers for the first rank16 candidate. Verification: task receipt distinguishes mainline from optional experiments.

## 6. Evaluation, Diagnostics, And Candidate Acceptance

- [x] 6.1 Tombstoned to `run-lora-candidate-training`: run or reference the C6 base Qwen3-1.7B baseline before claiming LoRA improvement. Verification in this change: `Reports/c5-pr2pr4pr5-20260621T235213/pr4-closeout/c5-remediation-closeout.md` records this as `deferred_to_PR5`; no LoRA improvement claim is made here.
- [x] 6.2 Tombstoned to `run-lora-candidate-training`: record C6 replay fingerprints for model artifact, tokenizer, LoRA adapter/checkpoint, prompt hash, tool-output digest, and contract digest. Verification in this change: PR4 closeout records this as `deferred_to_PR5`; adapter/checkpoint fingerprints require the PR5 candidate artifact.
- [x] 6.3 Add `generalization_diagnostic` with `in_dist_probe`, `heldout`, `ood_probe`, gaps, parent-overlap/leakage fields, and `diagnostic_verdict`. Verification: leakage yields `blocked_leakage`; missing diagnostic blocks only generalization claims.
- [x] 6.4 Tombstoned to `run-lora-candidate-training`: build OOD probes as non-neighbor cases such as new parameter values, unseen device-action combinations, or dialect variants. Verification in this change: PR4 closeout records this as `deferred_to_PR5`; OOD probe lineage belongs to the PR5 candidate eval pack.
- [x] 6.5 Tombstoned to `run-lora-candidate-training`: compare dynamic adapter, fused model, and quantized/endpoint behavior on the same C6 harness and sample sets `must_pass`, `heldout`, and `negative`. Verification in this change: PR4 closeout records this as `deferred_to_PR5`; no dynamic/fused/quantized parity claim is made here.
- [x] 6.6 Gate candidate status by `acceptance_stage`: `train_health` for smoke/val-loss only, `trainable_v0` for assistant-mask trainability, and `lora_candidate` only after C6 diff, fingerprints, fuse parity, and endpoint tokenizer byte parity. Verification: low validation loss alone never produces V-PASS.
- [x] 6.7 Add endpoint tokenizer byte-parity receipt fields for deployment pipe smoke. Verification: candidate V-PASS blocks unless endpoint render bytes match training render bytes exactly and the endpoint render source records patched tokenizer or explicit `enable_thinking=false`.

## 7. Verification And Closeout

- [x] 7.1 Run focused unit/fixture tests for route-tier derivation, masking stages, value strategies, refusal pairing, MLX config fields, diagnostic verdicts, and fuse-parity failure cases. Verification: tests fail closed on each known grill pitfall.
- [x] 7.2 Run `openspec validate define-lora-training --strict` and `openspec validate --all --strict`. Verification: both commands pass after implementation.
- [x] 7.3 Run the C5 data-gate validator and confirm train leakage, parent overlap, redaction, shared format, and masking coverage receipts are correct. Verification: receipt is machine-readable and does not claim action success.
- [x] 7.4 Tombstoned to `run-lora-candidate-training`: run C6 base-vs-LoRA diff, fuse parity, and endpoint tokenizer byte parity before any V-PASS claim. Verification in this change: PR4 closeout records this as `deferred_to_PR5`; V-PASS remains unsigned.
- [x] 7.5 Produce a closeout report listing smoke metrics, training config digest, route-tier/refusal/masking coverage, C6 diff, generalization diagnostic, fuse parity, and residual A/B work. Verification: report distinguishes T-PASS train health from V-PASS candidate readiness.

## 8. Remediation Truth Gates

| gate | PR4 disposition | PR5 owner |
| --- | --- | --- |
| task-truth count | The task list remains exactly 34 checkbox rows; PR4 closeout contains a 34-row truth table. | none |
| 3.1 smoke-only | Completed as train-health/smoke-chain evidence only; it does not authorize candidate readiness. | none |
| 3.5 masking coverage | Kept checked because receipts prove `train_on_turn`, `function_name`, `argument_name`, and `argument_value`. | none |
| C6 base-vs-LoRA diff | Tombstoned, not run in `define-lora-training`. | `run-lora-candidate-training` |
| replay fingerprints | Tombstoned until a candidate adapter/checkpoint exists. | `run-lora-candidate-training` |
| OOD probes | Tombstoned into candidate eval pack construction. | `run-lora-candidate-training` |
| dynamic/fused/quantized parity | Tombstoned; no parity or V-PASS claim is made by this change. | `run-lora-candidate-training` |
| endpoint byte/device V-PASS | Tombstoned/blocked until PR5 candidate and physical endpoint validation. | `run-lora-candidate-training` |

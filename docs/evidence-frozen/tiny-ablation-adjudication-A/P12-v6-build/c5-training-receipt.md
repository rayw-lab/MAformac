# C5 LoRA training receipt

status: blocked
receipt_version: c5-lora-training.v1
generated_at: 2026-07-02T17:03:55Z
acceptance_stage: trainable_v0
fit_proof_level: mechanism_true
consumer: Tools/C5TrainingCLI/c5_mlx_train_loop.py --require-maformac-loss-mask
consumed_artifact: mlx-data JSONL loss_objective_profile + loss_mask.trainable_spans + loss_mask.masked_think_spans
sufficiency_evidence: prepare emits objective-separated loss records; preflight fails closed on missing objectives unless --allow-legacy-loss-objective is explicit; repo training loop converts spans to token labels before loss
residual_gap: prepare receipt does not claim live training, C6 model-quality V-PASS, endpoint byte parity, or true-device acceptance

## Data
- row_count: 44
- train_eligible_count: 44
- smoke_chain_record_count: 0
- dev_selection_count: 0
- route_tier_counts: fc_l2=31, fc_l3=10, rule_l1=3
- masking_stage_counts: trainable_v0=44
- rehearsal_ratio: 0.0682
- refusal_ratio_observed: 0.0000
- refusal_ratio_target: 0.0
- refusal_ratio_hard_cap: 0.0
- prompt_distractor_count: 132

## Gates
- data_gate_status: data_gate_ready
- offset_fixture: pass
- offset_fixture_artifact: /Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/P12-v6-build/offset-fixture/mlx-mask-offset-fixture.json
- offset_fixture_artifact_sha256: 367d5610c47c28231aa94a081305825734f35f9eb7ee0529ea036683fd1b35b8
- offset_artifact_authority: pass
- offset_artifact_authority_mode: regenerated_same_path
- offset_artifact_authority_approved_sha256: c71ffb059610b337cd22350f9883eadb699c2d0d825bcd38b8cdf2752420a1a9
- offset_artifact_authority_observed_sha256: 367d5610c47c28231aa94a081305825734f35f9eb7ee0529ea036683fd1b35b8
- offset_artifact_authority_observed_path: /Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/P12-v6-build/offset-fixture/mlx-mask-offset-fixture.json
- offset_artifact_same_path_regeneration_required: true
- offset_artifact_same_path_regeneration_observed: true
- generator_orchestration: dry_run_only
- validator_layer1: pass
- validator_layer2: blocked_missing
- lineage_reassignment: pass
- scale_authority: pass
- scale_first_candidate: 20.0
- scale_observed: 20.0
- scale_source_ref: docs/p1c-training-grill-decisions.md:61
- scale_deferred_ab: 32.0
- candidate_data_quality: fail
- candidate_max_variants_per_seed: 8
- candidate_max_observed_variants_per_seed: 1
- candidate_variant_cap: pass
- candidate_diversity: fail
- candidate_unique_utterance_ratio: 0.7500
- candidate_ambiguous_duplicate_count: 0
- candidate_lineage_parent_overlap: 0
- candidate_epoch_exposure_max: 3
- masking_coverage: train_on_turn=true, function_name=true, argument_name=true, argument_value=false
- supervision_coverage: pass
- supervision_parser_critical: pass
- supervision_ratio: 1.0000 (threshold >= 0.9)
- supervision_prompt_user_system_leakage: prompt=0, user=0, system=0
- supervision_think_leakage: 0
- diagnostic_verdict: blocked_missing
- fuse_parity_gate: fail
- fuse_toolcall_exact_delta_pp: 0.0000
- fuse_IrrelAcc_delta_pp: missing
- endpoint_tokenizer_parity: blocked
- endpoint_render_source: missing
- endpoint_byte_parity: false
- endpoint_first_mismatch_byte: none

## Config
- model: /Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/P12-v6-build/qwen3-1_7b-training-tokenizer-patched
- fine_tune_type: lora
- rank: 16
- scale: 20.0
- optimizer: adamw
- weight_decay: 0.01
- grad_clip_norm: 1.0
- training_loop: maformac_c5_repo_loop_mlx_lm_0_31_1
- learning_rate: 0.0001
- lr_schedule: cosine
- lr_schedule_step_unit: optimizer_update
- schedule_decay_steps: 600
- warmup_steps: 48
- optimizer_update_steps: 150
- rendered_schedule_decay_steps: 150
- rendered_warmup_steps: 12
- max_seq_length: 8192
- keys: self_attn.q_proj, self_attn.k_proj, self_attn.v_proj, self_attn.o_proj, mlp.gate_proj, mlp.up_proj, mlp.down_proj

## Environment
- seed: 0
- mlx_version: 0.31.2
- mlx_lm_version: 0.31.1
- transformers_version: 5.6.1
- hardware: Mac17,2; Apple M5; mem_bytes=34359738368
- dtype: bf16_lora_on_4bit_base
- base_model_commit_sha: 3b1b1768f8f8cf8351c712464f906e86c2b8269e
- repo_commit_sha: f4af8ccfc7d5f9249db53491d64648948aea03ca
- gradient_clip_status: tracked_unverified_repo_loop_clip_grad_norm_max_1.0_nonfinite_stop_fallback_lr_5e-5
- training_loop_source_state: tracked_unverified
- training_loop_source_sha256: ed3bfbdfd0b80b9150c1bbf8461490cda54e53fbf37f7db1dc817900d2d511b9
- training_loop_verification_status: verification_marker_sha_mismatch
- training_loop_verification_ref: Reports/c5-pr2pr4pr5-20260621T235213/pr2-2b-equivalence/evidence-summary.md

## Training curve
- metrics_jsonl_ref: metrics.jsonl
- training_log_ref: planned_maformac_c5_repo_loop_stdout_log
- best_checkpoint_policy: dev_selection_val_loss_then_C6_final_only
- note: prepare receipt only; parse the MLX log after smoke/train to populate curve metrics

## Failure receipt
- training_loop_source_unverified
- cloud_multi_source_generator_not_run
- multi_source_generator_diversity_missing
- cross_vendor_semantic_judge_not_run
- masking_complete_augmentation_not_implemented
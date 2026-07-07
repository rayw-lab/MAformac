# C5 LoRA training receipt

status: step2_dry_run_ready
receipt_version: c5-lora-training.v1
generated_at: 2026-07-03T14:47:54Z
acceptance_stage: trainable_v0

## Data
- row_count: 4500
- train_eligible_count: 4100
- smoke_chain_record_count: 0
- dev_selection_count: 400
- route_tier_counts: fc_l2=2845, fc_l3=948, rule_l1=307
- masking_stage_counts: trainable_v0=4500
- rehearsal_ratio: 0.0749
- refusal_ratio_observed: 0.0000
- refusal_ratio_target: 0.0
- refusal_ratio_hard_cap: 0.0
- prompt_distractor_count: 13500

## Gates
- data_gate_status: data_gate_ready
- offset_fixture: pass
- offset_fixture_artifact: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/samples-rerendered/offset-fixture/mlx-mask-offset-fixture.json
- offset_fixture_artifact_sha256: 2cd27663d769a101d719a19b849e38357d02cf8f2a845ad2210762dce9e7425e
- offset_artifact_authority: not_configured
- offset_artifact_authority_mode: not_configured
- offset_artifact_authority_approved_sha256: missing
- offset_artifact_authority_observed_sha256: 2cd27663d769a101d719a19b849e38357d02cf8f2a845ad2210762dce9e7425e
- offset_artifact_authority_observed_path: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/samples-rerendered/offset-fixture/mlx-mask-offset-fixture.json
- offset_artifact_same_path_regeneration_required: false
- offset_artifact_same_path_regeneration_observed: false
- generator_orchestration: dry_run_only
- validator_layer1: pass
- validator_layer2: blocked_missing
- lineage_reassignment: pass
- scale_authority: pass
- scale_first_candidate: 20.0
- scale_observed: 20.0
- scale_source_ref: docs/p1c-training-grill-decisions.md:61
- scale_deferred_ab: 32.0
- candidate_data_quality: pass
- candidate_max_variants_per_seed: 8
- candidate_max_observed_variants_per_seed: 7
- candidate_variant_cap: pass
- candidate_diversity: pass
- candidate_unique_utterance_ratio: 0.9658
- candidate_ambiguous_duplicate_count: 0
- candidate_lineage_parent_overlap: 0
- candidate_epoch_exposure_max: 21
- masking_coverage: train_on_turn=true, function_name=true, argument_name=true, argument_value=true
- diagnostic_verdict: blocked_missing
- fuse_parity_gate: fail
- fuse_toolcall_exact_delta_pp: 0.0000
- fuse_IrrelAcc_delta_pp: missing
- endpoint_tokenizer_parity: blocked
- endpoint_render_source: missing
- endpoint_byte_parity: false
- endpoint_first_mismatch_byte: none

## Config
- model: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/samples-rerendered/qwen3-1_7b-training-tokenizer-patched
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
- max_seq_length: 1024
- keys: self_attn.q_proj, self_attn.k_proj, self_attn.v_proj, self_attn.o_proj, mlp.gate_proj, mlp.up_proj, mlp.down_proj

## Environment
- seed: 0
- mlx_version: 0.31.2
- mlx_lm_version: 0.31.1
- transformers_version: 5.6.1
- hardware: Mac17,2; Apple M5; mem_bytes=34359738368
- dtype: bf16_lora_on_4bit_base
- base_model_commit_sha: 3b1b1768f8f8cf8351c712464f906e86c2b8269e
- repo_commit_sha: 548a6f4bd6511fd01434f564c7c2e00eae804165
- gradient_clip_status: verified_repo_loop_clip_grad_norm_max_1.0_nonfinite_stop_fallback_lr_5e-5
- training_loop_source_state: verified
- training_loop_source_sha256: 5400641044144746f8d4ddc424b8b49f66e650e6511d94843ccd64f12895e0f7
- training_loop_verification_status: pass
- training_loop_verification_ref: Reports/c5-pr2pr4pr5-20260621T235213/pr2-2b-equivalence/evidence-summary.md

## Training curve
- metrics_jsonl_ref: metrics.jsonl
- training_log_ref: planned_maformac_c5_repo_loop_stdout_log
- best_checkpoint_policy: dev_selection_val_loss_then_C6_final_only
- note: prepare receipt only; parse the MLX log after smoke/train to populate curve metrics

## Failure receipt
- cloud_multi_source_generator_not_run
- multi_source_generator_diversity_missing
- cross_vendor_semantic_judge_not_run
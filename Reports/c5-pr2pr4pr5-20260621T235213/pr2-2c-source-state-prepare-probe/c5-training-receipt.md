# C5 LoRA training receipt

status: trainable_v0_ready
receipt_version: c5-lora-training.v1
generated_at: 2026-06-21T16:44:22Z
acceptance_stage: trainable_v0

## Data
- row_count: 4956
- train_eligible_count: 4556
- smoke_chain_record_count: 0
- dev_selection_count: 400
- route_tier_counts: fc_l2=2845, fc_l3=948, rule_l1=307
- masking_stage_counts: trainable_v0=4956
- rehearsal_ratio: 0.0749
- refusal_ratio_observed: 0.1001
- refusal_ratio_target: 0.1
- refusal_ratio_hard_cap: 0.2
- prompt_distractor_count: 9912

## Gates
- data_gate_status: data_gate_ready
- offset_fixture: pass
- offset_fixture_artifact: /Users/wanglei/workspace/MAformac/Reports/c5-pr2pr4pr5-20260621T235213/pr2-2c-source-state-prepare-probe/offset-fixture/mlx-mask-offset-fixture.json
- offset_fixture_artifact_sha256: 99eb15e574278f9dd0af9b5417ecf7887bb65b4b1eb4e3e7977b2e8eea0d4afa
- generator_orchestration: pass
- validator_layer1: pass
- validator_layer2: pass
- lineage_reassignment: pass
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
- model: /Users/wanglei/workspace/MAformac/Reports/c5-pr2pr4pr5-20260621T235213/pr2-2c-source-state-prepare-probe/qwen3-1_7b-training-tokenizer-patched
- fine_tune_type: lora
- rank: 16
- scale: 32.0
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
- repo_commit_sha: eba82183f2acc0c6ff25a40e514e12100a9090aa
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

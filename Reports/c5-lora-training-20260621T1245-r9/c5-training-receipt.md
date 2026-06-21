# C5 LoRA training receipt

status: step2_dry_run_ready
receipt_version: c5-lora-training.v1
generated_at: 2026-06-21T05:11:27Z
acceptance_stage: trainable_v0

## Data
- row_count: 4956
- train_eligible_count: 4556
- dev_selection_count: 400
- route_tier_counts: fc_l2=2845, fc_l3=948, rule_l1=307
- rehearsal_ratio: 0.0749
- refusal_ratio_observed: 0.1001
- refusal_ratio_target: 0.1
- refusal_ratio_hard_cap: 0.2
- prompt_distractor_count: 9912

## Gates
- data_gate_status: data_gate_ready
- offset_fixture: pass
- generator_orchestration: dry_run_only
- validator_layer1: pass
- validator_layer2: blocked_missing
- lineage_reassignment: blocked_missing
- masking_coverage: train_on_turn=true, function_name=true, argument_name=true, argument_value=true
- diagnostic_verdict: blocked_missing
- fuse_parity_gate: fail

## Failure receipt
- cloud_multi_source_generator_not_run
- multi_source_generator_diversity_missing
- cross_vendor_semantic_judge_not_run
- candidate_semantic_reassignment_not_run
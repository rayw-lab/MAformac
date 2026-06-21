# PR5 5c C6 Evaluation Evidence Summary

Verdict: C6_HARD_FAIL_BLOCKED

This run proves the candidate can be loaded by the SpikeE3 MLX Swift harness after adapter-config normalization, but it fails C6 candidate evaluation. It does not sign model-quality V-PASS, endpoint V-PASS, or candidate readiness.

## Harness
- base_results: `Reports/c5-pr2pr4pr5-20260621T235213/pr5-5c-c6-base-full/spike-e3-results.json`
- lora_results: `Reports/c5-pr2pr4pr5-20260621T235213/pr5-5c-c6-lora-full/spike-e3-results.json`
- base_summary: `Reports/c5-pr2pr4pr5-20260621T235213/pr5-5c-c6-base-full-summary/c6-summary.json`
- lora_summary: `Reports/c5-pr2pr4pr5-20260621T235213/pr5-5c-c6-lora-full-summary/c6-summary.json`
- model_artifact_digest: `0e86d9677e519323849eac1bc272caae88567a481ff188c431f70be543d9995f`
- tokenizer_digest: `aeb13307a71acd8fe81861d94ad54ab689df773318809eed3cbe794b4492dae4`
- adapter_digest: `a8b5a50ca08bd3f96b37411f40718568625606985935d09d18eedd88e45b86fc`
- normalized_adapter_config_digest: `d230d0fb1f6c606bd402514bb83e8f1d7c7b660a5be8a5ed75e3cda26a6f503a`
- original_adapter_config_digest: `f025da20d5b9338356271183dfbf25e628274a68bf85bcd5a9e4bed520f8d592`
- normalized_adapter_weights_symlink_target: `/Users/wanglei/workspace/MAformac/Reports/c5-pr2pr4pr5-20260621T235213/pr5-5b-candidate-prepare-clean/adapters-rank16/adapters.safetensors`
- qwen_tool_call_format_version: `630281ed49f2acb7a04a1823909fd907031b7ba29d606e88f326c1e0bb93d53b`
- contract_digest: `f8067fb64fab5bb768d5746b8484be7134a6c93f29ef16de2228a0217ec95180`

## Results
| Metric | Base | LoRA | Delta |
| --- | ---: | ---: | ---: |
| hard_failure_count | 50 | 42 | -8 |
| IrrelAcc | 0.739 | 0.957 | 0.217 |
| positive_expected_tool_hits | 25/34 | 0/34 | -25 |
| no_tool_false_positive_count | 6 | 1 | -5 |
| average_elapsed_ms | 575.0 | 2032.7 | 1457.7 |

## Blocking Diagnosis
- LoRA observed tool names: `tool_call`.
- Training outer tool name set: `tool_call_frame`.
- C6 expected tool names: `query_cabin_comfort`, `set_cabin_ac`, `set_cabin_ambient_light`, `set_cabin_fan`, `set_cabin_screen_brightness`, `set_cabin_window`.
- Tool-surface verdict: `fail_training_target_uses_tool_call_frame_but_c6_expects_set_cabin_tools`.
- Adapter config normalization: `normalized` (-1 -> 28).

## Diagnostic Axes
- all_c6_release: cases=57, base_pass=7/57, lora_pass=15/57
- heldout_must_not_train: cases=42, base_pass=0/42, lora_pass=1/42
- vehicle_action_positive: cases=34, base_pass=0/34, lora_pass=0/34
- ood_no_call_negative: cases=9, base_pass=7/9, lora_pass=9/9
- trap_cases: cases=12, base_pass=0/12, lora_pass=0/12
- coverage_ambiguous: cases=7, base_pass=0/7, lora_pass=6/7
- leakage: exact_input_overlap=0, train_parent_overlap=0
- near_neighbor: `exact_input_no_overlap_only_not_semantic_near_neighbor_proof` (residual gate; not complete)

## Verdict
The candidate is blocked before parity or endpoint V-PASS. The next corrective step is not to sign or tune thresholds; it is to reconcile the training target tool surface with the C6/runtime parser surface, then retrain or introduce a scored bridge and rerun C6.

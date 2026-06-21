# PR5 5b Candidate Training Evidence Summary

Verdict: TRAIN_HEALTH_PASS_ONLY

This receipt proves the PR5 scale-20 LoRA training run completed without training-health blockers. It does not sign model-quality V-PASS, endpoint V-PASS, C6 improvement, parity, or final candidate readiness.

## Inputs
- prepare_receipt: `Reports/c5-pr2pr4pr5-20260621T235213/pr5-5b-candidate-prepare-clean/c5-training-receipt.json`
- prepare_receipt_sha256: `4b9221774e983a93888f9ab054cc866875b63d2014f4e8b35ac89cd15d90df8e`
- clean_data_jsonl: `Reports/c5-pr2pr4pr5-20260621T235213/pr5-5b-data-cleaning/generated-utterances-pr5-clean.jsonl`
- clean_data_sha256: `009d1017740fe266d66485a7d325476de795e522e59c1534e3ec4463a9cac858`
- ambiguous_records_removed: 82 across 40 groups
- train_jsonl_sha256: `8fdffb150c56be2a80fa23716d2e723042d09e23402bec9c50456b9e969159c0`
- mlx_config_sha256: `6ec089a0c5a2d9dd0de26b3da1019749c0949a4d9fd4f333e2ba9e0ed5dc459e`
- receipt_amendment: 5b audit r1 found stale `define-lora-training` active-change authority in the prepare receipt. Prepare was regenerated after the code fix; train/config/log/adapter hashes remained unchanged, and the run receipt records the amendment explicitly.

## Gates
- prepare_status: `trainable_v0_ready`
- training_method_contract_authority: `pass`; active spec `openspec/specs/lora-training/spec.md` sha256 `018ce75047ef16647179d781525dcfe837e4f0c5576542a202b59c6fb63b4639`; archived change `openspec/changes/archive/2026-06-21-define-lora-training`; archived spec sha256 `16073248326acfa3011f610b4a8a7f81044f8e56f6220b5f2e864ffd273f2a34`
- scale: `20`; scale_authority: `pass`
- offset_artifact_authority: `pass` / `regenerated_same_path`; observed artifact sha256 `c1429379994a47155dc9ac83ce22e6b4e5b72b3e996503383a081460ee90bf03`
- candidate_data_quality: `pass`; ambiguous_duplicate_count=0; unique_utterance_ratio=0.9658
- training_loop_source_state: `verified`
- training_loop_source_sha256: `5400641044144746f8d4ddc424b8b49f66e650e6511d94843ccd64f12895e0f7`

## Training Run
- train_iterations: 600
- optimizer_updates: 150
- clip_enabled_updates: 150
- clip_applied_updates: 131
- max_grad_norm_preclip: 224.837479
- nonfinite_count: 0
- learning_rate_peak_observed: 0.000100000005
- first_val_loss: 5.4974751472473145
- final_val_loss: 0.6388351321220398
- final_train_loss: 0.599856185913086
- peak_memory_gb: 11.56215772

## Artifacts
- metrics_jsonl: `Reports/c5-pr2pr4pr5-20260621T235213/pr5-5b-candidate-prepare-clean/metrics.jsonl` sha256 `bb15bafdd63da29a7b9d4ca97e1ab9ddd99cee96100ac41a8f1c4ca4cafecd5e`
- training_log: `Reports/c5-pr2pr4pr5-20260621T235213/pr5-5b-candidate-prepare-clean/train.log` sha256 `49130fab704299524217654e3dc3a3e2ead064983b4bde682630b705b4939131`
- source_snapshot: `Reports/c5-pr2pr4pr5-20260621T235213/pr5-5b-candidate-prepare-clean/c5_mlx_train_loop.snapshot.py` sha256 `5400641044144746f8d4ddc424b8b49f66e650e6511d94843ccd64f12895e0f7`
- final_adapter: `Reports/c5-pr2pr4pr5-20260621T235213/pr5-5b-candidate-prepare-clean/adapters-rank16/adapters.safetensors` sha256 `a8b5a50ca08bd3f96b37411f40718568625606985935d09d18eedd88e45b86fc`
- adapter_config: `Reports/c5-pr2pr4pr5-20260621T235213/pr5-5b-candidate-prepare-clean/adapters-rank16/adapter_config.json` sha256 `f025da20d5b9338356271183dfbf25e628274a68bf85bcd5a9e4bed520f8d592`

## Residual Gates
- C6 same-harness base-vs-LoRA eval: PENDING
- heldout/OOD diagnostics: PENDING
- dynamic/fused/quantized parity: PENDING
- endpoint tokenizer byte parity: PENDING
- physical endpoint V-PASS: PENDING
- GPT Pro final audit: PENDING

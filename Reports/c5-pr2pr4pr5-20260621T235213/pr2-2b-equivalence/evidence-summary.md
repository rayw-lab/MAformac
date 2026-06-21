# PR2 2b Stock-Equivalence Evidence

Status: ready_for_independent_audit

Scope: clip-off equivalence between stock-style optimizer update inside the compiled step and repo-loop optimizer update outside the compiled step. This subphase does not claim clip-enabled candidate quality or PR5 readiness.

## Compared Runs

| Lane | Directory | Loop Semantics | Clip |
| --- | --- | --- | --- |
| stock-semantics baseline | `Reports/c5-pr2pr4pr5-20260621T235213/pr2-2b-stock-semantics-128-v2` | `stock_update_inside_compile` | disabled |
| repo no-clip | `Reports/c5-pr2pr4pr5-20260621T235213/pr2-2b-repo-noclip-128-v2` | `repo_update_outside_compile` | disabled |

Both runs used:

- Training script sha256: `5400641044144746f8d4ddc424b8b49f66e650e6511d94843ccd64f12895e0f7`
- Model/tokenizer: `Reports/c5-remediation-wave-20260621T2013-pr3-full/prepare-final-v3/qwen3-1_7b-training-tokenizer-patched`
- MLX data: `Reports/c5-remediation-wave-20260621T2013-pr3-full/prepare-final-v3/mlx-data`
- Config: `Reports/c5-remediation-wave-20260621T2013-pr3-full/prepare-final-v3/mlx-lora-config.yaml`
- Seed: 0
- Iterations: 128
- Batch size: 4
- Grad accumulation: 4
- Optimizer updates: 32
- Learning rate: 0.0001 with the rendered MLX schedule from the config
- Source snapshot: `c5_mlx_train_loop.snapshot.py` in each run directory

## Receipts

| Artifact | stock-semantics sha256 | repo no-clip sha256 |
| --- | --- | --- |
| `metrics.jsonl` | `cde9e52ea844fb4febec3112f49b44dd5c3662b01858960a0aa02d983038abe9` | `8932ba2488e780f824900beb72cb650cfd73e0be112ffbb9b4e94cbea622aca6` |
| `train.log` | `6928322d1291eb75efa708cd92c25705a28d67af37a5296bbd4ac065706d6f97` | `76874f422afd202268b4cb78017aa6435bcc1b60a90c5c733e3d3f659546d770` |
| final `adapters.safetensors` | `54edc5fb6c3762f1ea41601dabeddaa789290d0fc2bccc2ae42209c3505cfda5` | `54edc5fb6c3762f1ea41601dabeddaa789290d0fc2bccc2ae42209c3505cfda5` |
| script snapshot | `5400641044144746f8d4ddc424b8b49f66e650e6511d94843ccd64f12895e0f7` | `5400641044144746f8d4ddc424b8b49f66e650e6511d94843ccd64f12895e0f7` |

## Delta Summary

- Event counts: stock 67, repo 67
- `optimizer_update` events: stock 32, repo 32
- `train_report` events: stock 32, repo 32
- `val` events: stock 2, repo 2
- Max absolute optimizer-update loss delta: 0.0
- Max absolute optimizer-update `grad_norm_preclip` delta: 0.0
- Max absolute train-report loss delta: 0.0
- Max absolute validation loss delta: 0.0
- Final train loss: 1.3175506591796875 in both lanes
- Final validation loss: 1.389992117881775 in both lanes
- Final adapter sha256: identical in both lanes
- Nonfinite events: 0 in both lanes

## LR Receipt Note

The two modes mutate optimizer state at different points relative to the `optimizer_update` metrics write. Therefore `optimizer_update.learning_rate` is not used as the parity field. The comparable post-update LR appears in the corresponding `train_report` events and matches at final iteration: 0.00009683993994258344 in both lanes.

## Local Verdict

PR2 2b satisfies the dispatch equivalence requirement for this 128-iteration, 32 optimizer-update clip-off run: stock-semantics and repo no-clip lanes match exactly on loss, preclip gradient norm, validation loss, and final adapter weights. PR2 clip-enabled proof remains the separate 2a artifact; PR5 candidate readiness remains open.

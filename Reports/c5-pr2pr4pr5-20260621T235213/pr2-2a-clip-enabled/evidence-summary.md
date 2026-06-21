# PR2 2a Clip-Enabled Repo Loop Evidence

Status: ready_for_independent_audit

Run directory: `Reports/c5-pr2pr4pr5-20260621T235213/pr2-2a-clip-enabled`

Command class: repo-local `Tools/C5TrainingCLI/c5_mlx_train_loop.py`, clip enabled, `--grad-clip-norm 1.0`, 128 micro-iterations, batch size 4, grad accumulation 4, 32 optimizer updates.

## Inputs

- Model/tokenizer: `Reports/c5-remediation-wave-20260621T2013-pr3-full/prepare-final-v3/qwen3-1_7b-training-tokenizer-patched`
- MLX data: `Reports/c5-remediation-wave-20260621T2013-pr3-full/prepare-final-v3/mlx-data`
- Config: `Reports/c5-remediation-wave-20260621T2013-pr3-full/prepare-final-v3/mlx-lora-config.yaml`
- Training script sha256 before this run: `b5b1bde0630593e82891914e7a23f46666b2442afb6262a2c47cab0739255a71`

## Receipts

- `metrics.jsonl` sha256: `1e30ae4531cdedf9298898138a13c2d37546a69e4b5a2b970cc303703e98c7e5`
- `train.log` sha256: `1d11f5c70d82f714d2b29ec64ae8ad4e46545d8dcfa3b0e84fe62e4ba18afb4e`
- Final `adapters.safetensors` sha256: `d3b3f1449b4bf15ba6890f38bc5fd8d51a48d9c1134b755e2a82facca12ef8c7`

## Metrics

- Total events: 47
- `optimizer_update` events: 32
- Clip enabled count: 32
- Clip applied count: 32
- `grad_norm_preclip > 1.0` count: 32
- `grad_norm_preclip` range: 5.628432750701904 to 486.4022521972656
- Nonfinite events: 0
- First optimizer update: iteration 4, update step 1, learning rate 0.0, preclip norm 236.28070068359375
- Last optimizer update: iteration 128, update step 32, learning rate 0.00009683993994258344, preclip norm 5.628432750701904
- Final train report: iteration 128, train loss 0.8179646730422974, peak memory 11.56215772 GB
- Final validation: iteration 128, val loss 0.889543890953064

## Local Verdict

PR2 2a clip-enabled lane satisfies the dispatch receipt shape for a real repo-loop clip run: at least 32 optimizer updates, all updates clip-enabled, all updates clip-applied, and final adapter weights saved. This does not prove stock-loop equivalence; PR2 2b remains open.

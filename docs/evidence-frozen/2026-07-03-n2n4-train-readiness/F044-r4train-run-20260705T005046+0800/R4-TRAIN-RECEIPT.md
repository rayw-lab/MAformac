# R4 SHORTTRAIN TRAIN RECEIPT

status: DONE_R4_SHORTTRAIN_TRAIN_HEALTH_LOCAL_METRICS_SCAN
proof_class: local/metrics_jsonl_firsthand_scan
artifact_kind: operational_train_receipt
created_at: 2026-07-05T03:48:56+08:00
run_dir: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-r4train-run-20260705T005046+0800`
claim_boundary: train-health only; no behavior gate, no eval verdict, no C6/V-PASS, no product acceptance.

## Basis Binding

| lane | value | source | verdict |
|---|---|---|---|
| code | PR38 train loop sha `9714f6f2700a4c0f77be6bfdc005d291a894e858606a87a1a3838fd9a8f71748`; mlx-lm `0.31.1` | `metrics.jsonl` run_metadata | bound |
| command | `SHORTTRAIN_MLX_DATA_DIR=$PWD/wave2-fix/r4-trainpack/mlx-data SYSTEM_MEMORY_FAIL_GB=999 PROCESS_PEAK_FAIL_GB=22.34 WATCHDOG_INTERVAL_SECONDS=15 bash f044-r4-run.sh` + formal watchdog night `free<2.0GB/180s`, `memory_pressure_free_pct<4`, peak `22.34GB` | launch baseline + watchdog config | bound |
| data samples | `wave2-fix/r4-trainpack/c5-training-samples.jsonl`; rows `5653`; sha `9d4bc2d25ae77325e23fd985a4b556627ac85fb53c53a2e7f2e816b5c96d1782` | receipt + sha256 | bound |
| rendered MLX | train `5253`, valid `400`, test `128`; train sha `a9ee9e8536bce74396d307e4f845c549f97191eaf1a628792b7e056745b0a414` | wc + sha256 | bound |
| train preflight | records `5781`; trainable_tokens `135013`; ignored_tokens `18843918`; max_token_length `7530` | `metrics.jsonl` preflight | bound |
| adapter | `adapters-rank16/adapters.safetensors`; sha `ee5791271735eaa5cf53f310f7bdc7d3893936e4c1cb06f8584727c637a980e0` | sha256 | final adapter saved |
| config | iters `600`; optimizer updates `150`; token_budget `8192`; grad_checkpoint `true`; rank `16`; trainable params `17.433M/1720.575M` | train.log + metrics | bound |
| source snapshot | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-r4train-run-20260705T005046+0800/c5_mlx_train_loop.snapshot.py` | `metrics.jsonl` run_metadata | exists |
| watchdog | heartbeat `EXECUTOR-FORMAL-WATCHDOG-HEARTBEAT.jsonl`; sha `7df0bd9c74fd827265ab8e2cacf3b04729793fd007551737ee5825567a3130cb` | formal watchdog | armed night mode |

## Training Health Full Scan

| metric | value | source | verdict |
|---|---:|---|---|
| final iteration | `600/600` | train.log + metrics | completed |
| optimizer_update events | `150/150` | metrics full scan | expected |
| train_report records | `60` | metrics full scan | expected |
| nonfinite loss/grad | `0` | metrics NaN/Inf scan | MUST_BE_0 |
| val loss trajectory | iter 1: loss 2.932663, time 65.966s; iter 200: loss 0.098876, time 64.579s; iter 400: loss 0.058201, time 58.223s; iter 600: loss 0.005396, time 59.779s | metrics full scan | recorded |
| final train loss | `0.082623684406` | final train_report | recorded |
| final trained/supervised tokens | `25174` | final train_report | recorded |
| peak_memory_gb | `19.029863148` | metrics peak | below process stopline `22.34GB` |
| wall_clock_seconds | `10617.545` | run start to final adapter mtime | recorded |
| adapter checkpoints | `0000100_adapters.safetensors, 0000200_adapters.safetensors, 0000300_adapters.safetensors, 0000400_adapters.safetensors, 0000500_adapters.safetensors, 0000600_adapters.safetensors, adapters.safetensors` | checkpoint listing | expected 100-step ckpts + final |
| final save line | `Saved final weights ... adapters.safetensors` | train.log tail | present |

## Resource / Efficiency Columns

| wall_clock_seconds | peak_memory_gb | supervised_tok_per_sec | ignored_trainable_ratio | verdict |
|---:|---:|---:|---:|---|
| `10617.545` | `19.029863148` | `2.370981` | `139.571138` | populated |

Formula binding:

```text
supervised_tok_per_sec = final trained_tokens / wall_clock_seconds = 25174 / 10617.545 = 2.370981
ignored_trainable_ratio = ignored_tokens / trainable_tokens = 18843918 / 135013 = 139.571138
```

## Stopline Review

- [x] No OOM / Metal abort / process abort observed.
- [x] No manual kill, timeout kill, or watchdog kill in R4 run.
- [x] No NaN / Inf / nonfinite loss or grad.
- [x] Optimizer update appeared in first expected window: first update at iteration 4.
- [x] Final adapter exists and sha is recorded.
- [x] Required checkpoints exist: 100/200/300/400/500/600 plus final.
- [x] Source snapshot exists in run dir.
- [x] Peak memory `19.029863148GB` stayed below process stopline `22.34GB`.
- [x] Runtime free redline did not fire under night mode.
- [x] `supervised_tok_per_sec` and `ignored_trainable_ratio` populated.
- [x] Trainer process exit and memory release snapshot recorded: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-r4train-run-20260705T005046+0800/R4-POSTTRAIN-PROCESS-MEMORY-SNAPSHOT.json`.

Stopline verdict:

```text
NO_STOPLINE_HIT_IN_R4_RUN
```

## Post-Train Process / Memory Snapshot

| field | value |
|---|---|
| captured_at | `2026-07-05T03:48:56+08:00` |
| trainer/watchdog/probe matches | `0` |
| free+speculative+purgeable+inactive | `27.065GB` |
| swapusage | `vm.swapusage: total = 5120.00M  used = 3642.25M  free = 1477.75M  (encrypted)` |
| snapshot | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-r4train-run-20260705T005046+0800/R4-POSTTRAIN-PROCESS-MEMORY-SNAPSHOT.json` |

## SHA256 Bindings

| artifact | sha256 |
|---|---|
| `F044-r4train-run-20260705T005046+0800/EXECUTOR-FORMAL-WATCHDOG-HEARTBEAT.jsonl` | `7df0bd9c74fd827265ab8e2cacf3b04729793fd007551737ee5825567a3130cb` |
| `F044-r4train-run-20260705T005046+0800/R4-POSTTRAIN-PROCESS-MEMORY-SNAPSHOT.json` | `125edccc0f33d7384ba3b68dca5849a14afcef8237236fd67033b88381247a39` |
| `F044-r4train-run-20260705T005046+0800/adapters-rank16/adapters.safetensors` | `ee5791271735eaa5cf53f310f7bdc7d3893936e4c1cb06f8584727c637a980e0` |
| `F044-r4train-run-20260705T005046+0800/formal-watchdog-armed-night-r4-config.json` | `a09ab36e791ccf10096c49be5f8d361063239731a17e671940a0f2e642cbbefa` |
| `F044-r4train-run-20260705T005046+0800/metrics.jsonl` | `9cc3e2f37f8fdf09042e45b8123564ae8a5e00b7773380ab643298f307e15b99` |
| `F044-r4train-run-20260705T005046+0800/train.log` | `bf6f96bf7b925bd536030c2c28ef4e2850b8048b6fc459419cf5544bec3c04c3` |
| `f044-r4-run.sh` | `3542fa65a9e76e6bd521f8c0c364c9b3fed6b6cd8ceab45d33e604a560a91eba` |
| `formal-watchdog-draft.py` | `e8257fab45d60a486aeed17558632f346c87baa7a68fca850fc5eb9d09ade8ed` |
| `wave2-fix/r4-trainpack/F044-R4-DATA-READY-RECEIPT.md` | `5d4ac607b3e44cfd763a3db1004f6d603d8833474abc4e213cc2512aeb1f4a72` |
| `wave2-fix/r4-trainpack/c5-training-samples.jsonl` | `9d4bc2d25ae77325e23fd985a4b556627ac85fb53c53a2e7f2e816b5c96d1782` |
| `wave2-fix/r4-trainpack/mlx-data/test.jsonl` | `ed7a78567156468e7fb951e84073e852cbdfe8f859fe43544a1b8f0a006cdcc2` |
| `wave2-fix/r4-trainpack/mlx-data/train.jsonl` | `a9ee9e8536bce74396d307e4f845c549f97191eaf1a628792b7e056745b0a414` |
| `wave2-fix/r4-trainpack/mlx-data/valid.jsonl` | `df1e356d210e9658918aceb65a1c8f1c0e813412ac63ce830ed80f9362eab897` |
| `wave2-fix/r4-trainpack/strict-preflight.metrics.jsonl` | `2d961654bd4340391fa31f7a80c3e923637726608098d253f7d7a6f99d99d756` |


## Non-Claims

This receipt only claims local shorttrain train-health completion for R4. It does not claim behavior PASS/FAIL, formal launch readiness, endpoint readiness, mobile/true-device/live proof, or product acceptance. Those belong to the separate W52-style eval/verdict lane.

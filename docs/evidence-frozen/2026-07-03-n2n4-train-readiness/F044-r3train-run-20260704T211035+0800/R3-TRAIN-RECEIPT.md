# R3 SHORTTRAIN TRAIN RECEIPT

status: DONE_R3_SHORTTRAIN_TRAIN_HEALTH_LOCAL_METRICS_SCAN
proof_class: local/metrics_jsonl_firsthand_scan
artifact_kind: operational_train_receipt
created_at: 2026-07-05T00:15:43+08:00
run_dir: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-r3train-run-20260704T211035+0800`
claim_boundary: train-health only; no behavior gate, no eval verdict, no C6/V-PASS, no product acceptance.

## Basis Binding

| lane | value | source | verdict |
|---|---|---|---|
| code | PR38 train loop sha `9714f6f2700a4c0f77be6bfdc005d291a894e858606a87a1a3838fd9a8f71748`; mlx-lm `0.31.1` | `metrics.jsonl` run_metadata | matched expected train loop sha |
| command | `SHORTTRAIN_MLX_DATA_DIR=$PWD/wave2-fix/r3-trainpack/mlx-data SYSTEM_MEMORY_FAIL_GB=999 PROCESS_PEAK_FAIL_GB=22.34 WATCHDOG_INTERVAL_SECONDS=15 bash f044-r3-run.sh` + D-101 night watchdog redline `2.0GB/180s`, manual `<4%` pressure line | user D-101/director order + watchdog config | bound |
| data samples | `wave2-fix/r3-trainpack/c5-training-samples.jsonl`; rows `5653`; sha `7c8c6b6f8b58b9c2fb0cb7a9319e82c92cd275645830d25cc67421a0b719fdf3` | `wc -l` + sha256 | bound |
| rendered MLX | train `5253`, valid `400`, test `128`; train sha `b7cc3485663432a33527ab901bd904d9b049ab632c12471b63d830cae52dd5bd` | `wc -l` + sha256 | bound |
| train preflight | records `5781`; trainable_tokens `135013`; ignored_tokens `18387823`; max_token_length `7196` | `metrics.jsonl` preflight | bound |
| adapter | `adapters-rank16/adapters.safetensors`; sha `4e278f1843d391b81c3a6201c760a7cd0eb45a2ee214741b32c998efd17c7847` | sha256 | final adapter saved |
| config | iters `600`; optimizer updates `150`; token_budget `8192`; grad_checkpoint `true`; rank `16`; trainable params `17.433M/1720.575M` | train.log + metrics | bound |
| source snapshot | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-r3train-run-20260704T211035+0800/c5_mlx_train_loop.snapshot.py` | `metrics.jsonl` run_metadata | exists |
| watchdog | heartbeat `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-r3train-run-20260704T211035+0800/EXECUTOR-FORMAL-WATCHDOG-HEARTBEAT.jsonl`; sha `28b0877501af958ffa4a24877923f0c39c5201ef254ae30544f5c65fe1c35eba` | watchdog config + sha256 | armed D-101 night mode |
| manual pressure monitor | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-r3train-run-20260704T211035+0800/EXECUTOR-D101-MANUAL-MEMORY-PRESSURE.jsonl`; sha `8c6308db743eb7d1d4f22785f6c767cf74004785b5178ec47dbb73af1bef0ab4` | manual heartbeat | `<4%` pressure supplement recorded |

## Training Health Full Scan

| metric | value | source | verdict |
|---|---:|---|---|
| final iteration | `600/600` | train.log + metrics | completed |
| optimizer_update events | `150/150` | metrics full scan | expected |
| train_report records | `60` | metrics full scan | expected |
| nonfinite loss/grad | `0` | metrics NaN/Inf scan | MUST_BE_0 |
| val loss trajectory | iter 1: loss 2.382514, time 69.402s; iter 200: loss 0.298330, time 59.792s; iter 400: loss 0.031110, time 64.663s; iter 600: loss 0.023611, time 62.389s | metrics full scan | recorded |
| final train loss | `0.010606060922` | final train_report | recorded |
| final trained/supervised tokens | `26190` | final train_report | recorded |
| peak_memory_gb | `17.97416001` | metrics peak | below process stopline `22.34GB` |
| wall_clock_seconds | `10860.722` | run start to final adapter mtime | recorded |
| adapter checkpoints | `0000100_adapters.safetensors, 0000200_adapters.safetensors, 0000300_adapters.safetensors, 0000400_adapters.safetensors, 0000500_adapters.safetensors, 0000600_adapters.safetensors, adapters.safetensors` | checkpoint listing | expected 100-step ckpts + final |
| final save line | `Saved final weights ... adapters.safetensors` | train.log tail | present |

## Resource / Efficiency Columns

| wall_clock_seconds | peak_memory_gb | supervised_tok_per_sec | ignored_trainable_ratio | verdict |
|---:|---:|---:|---:|---|
| `10860.722` | `17.97416001` | `2.411442` | `136.192981` | populated |

Formula binding:

```text
supervised_tok_per_sec = final trained_tokens / wall_clock_seconds = 26190 / 10860.722 = 2.411442
ignored_trainable_ratio = ignored_tokens / trainable_tokens = 18387823 / 135013 = 136.192981
```

## Stopline Review

- [x] No OOM / Metal abort / process abort observed.
- [x] No manual kill, timeout kill, or watchdog kill in this third run.
- [x] No NaN / Inf / nonfinite loss or grad.
- [x] Optimizer update appeared in first expected window: first update at iteration 4.
- [x] Final adapter exists and sha is recorded.
- [x] Required checkpoints exist: 100/200/300/400/500/600 plus final.
- [x] Source snapshot exists in run dir.
- [x] Peak memory `17.97416001GB` stayed below process stopline `22.34GB`.
- [x] Runtime free redline did not fire under D-101 night mode `2.0GB/180s` plus manual `<4%` pressure line.
- [x] `supervised_tok_per_sec` and `ignored_trainable_ratio` populated.
- [x] Trainer process exit and memory release snapshot recorded: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-r3train-run-20260704T211035+0800/R3-POSTTRAIN-PROCESS-MEMORY-SNAPSHOT.json`.

Stopline verdict:

```text
NO_STOPLINE_HIT_IN_FINAL_THIRD_RUN
```

## Post-Train Process / Memory Snapshot

| field | value |
|---|---|
| captured_at | `2026-07-05T00:15:43+08:00` |
| trainer/watchdog/probe matches | `0` |
| free+speculative+purgeable+inactive | `25.963GB` |
| swapusage | `vm.swapusage: total = 4096.00M  used = 2886.56M  free = 1209.44M  (encrypted)` |
| snapshot | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-r3train-run-20260704T211035+0800/R3-POSTTRAIN-PROCESS-MEMORY-SNAPSHOT.json` |

## SHA256 Bindings

| artifact | sha256 |
|---|---|
| `F044-r3train-run-20260704T211035+0800/EXECUTOR-D101-MANUAL-MEMORY-PRESSURE.jsonl` | `8c6308db743eb7d1d4f22785f6c767cf74004785b5178ec47dbb73af1bef0ab4` |
| `F044-r3train-run-20260704T211035+0800/EXECUTOR-FORMAL-WATCHDOG-HEARTBEAT.jsonl` | `28b0877501af958ffa4a24877923f0c39c5201ef254ae30544f5c65fe1c35eba` |
| `F044-r3train-run-20260704T211035+0800/R3-POSTTRAIN-PROCESS-MEMORY-SNAPSHOT.json` | `c411f5c56d25bc7f618d4f540ca600ee88b1463298a7057cd535a59257c2da31` |
| `F044-r3train-run-20260704T211035+0800/adapters-rank16/adapters.safetensors` | `4e278f1843d391b81c3a6201c760a7cd0eb45a2ee214741b32c998efd17c7847` |
| `F044-r3train-run-20260704T211035+0800/metrics.jsonl` | `037b33cd3677ddd228beccca9f73705bc713d06d8ade96392702b9918c376f7a` |
| `F044-r3train-run-20260704T211035+0800/train.log` | `92b739f5e6a1f146aa65ad17d4b4b86eb142622b98b6a9aa8b0003c2fe4d68e2` |
| `r3-host-baseline-d101-thirdrun-20260704T211031+0800.json` | `c3bf85b5ece9246be62a5669a3989cabcfc0087b22c0244accfe4a05f27946d8` |
| `wave2-fix/r3-trainpack/SHA256SUMS.txt` | `6f3981fd641f82820761b965b8eed5b9871dc34b2c298a71ca0e97e44f6395f0` |
| `wave2-fix/r3-trainpack/assembly_receipt.json` | `bd144bd3ff9bdaf99125bdc646109e9c413dfb82d53ec2106d57d58fec740eda` |
| `wave2-fix/r3-trainpack/c5-training-samples.jsonl` | `7c8c6b6f8b58b9c2fb0cb7a9319e82c92cd275645830d25cc67421a0b719fdf3` |
| `wave2-fix/r3-trainpack/mlx-data/test.jsonl` | `ed7a78567156468e7fb951e84073e852cbdfe8f859fe43544a1b8f0a006cdcc2` |
| `wave2-fix/r3-trainpack/mlx-data/train.jsonl` | `b7cc3485663432a33527ab901bd904d9b049ab632c12471b63d830cae52dd5bd` |
| `wave2-fix/r3-trainpack/mlx-data/valid.jsonl` | `df1e356d210e9658918aceb65a1c8f1c0e813412ac63ce830ed80f9362eab897` |
| `wave2-fix/r3-trainpack/strict-preflight.metrics.jsonl` | `03663879c22a53d877f787838d402b5f077da384063449a2692b6556328d6a6b` |


## Non-Claims

This receipt only claims local shorttrain train-health completion for R3 run `F044-r3train-run-20260704T211035+0800`. It does not claim behavior PASS/FAIL, formal launch readiness, endpoint readiness, mobile/true-device/live proof, or product acceptance. Those belong to the separate W52 eval/verdict lane.

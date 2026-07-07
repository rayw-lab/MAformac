# F044-R2B-TRAIN-RECEIPT — run155204 短训训练健康收据

status: r2b_shorttrain_train_health_pass
proof_class: local/metrics_jsonl_firsthand_scan + runtime/watchdog_log_scan
artifact_kind: authoritative_train_health_receipt_for_run155204
created_at: 2026-07-04T19:05:55+0800
run_dir: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-shorttrain-run-20260704T155204+0800`
claim_boundary: 本收据只声称 R2b shorttrain 训练管线健康完成；不声称 behavior gate、formal eval verdict、C6 acceptance、V-PASS、endpoint/demo/mobile/live acceptance。T-D eval/verdict 另行落盘。

## Basis 绑定

| lane | value | 一手 source | 判 |
|---|---|---|---|
| code | CODE-2026-07-03-PR38 pin `26678346`; train loop sha `9714f6f2700a4c0f77be6bfdc005d291a894e858606a87a1a3838fd9a8f71748` | `metrics.jsonl` run_metadata + `c5_mlx_train_loop.snapshot.py` sha | PASS |
| data samples | `wave2-fix/r2b-trainpack/c5-training-samples.jsonl`; rows `5499`; sha `3b76d49767e650b2cf5d41a3dd6b527932c1e2e2500bb249ac917303380f84e0` | `wc -l` + `shasum -a 256` | PASS |
| rendered MLX train file | `wave2-fix/r2b-trainpack/mlx-data/train.jsonl`; rows `5099`; sha `9e1e12a829edca751b50dd2d48532f9cf994ff71417ae3694d6d0fad73859546` | `wc -l` + `shasum -a 256` | PASS |
| strict preflight | records `5627`; trainable `133692`; ignored `18133767`; split train/valid/test `5099/400/128`; max token length `7196`; sha `b9e47d2f40ceadbc82aa5fe4f8927de5591fdce1c06f31fc44e792cebad2b701` | run `metrics.jsonl` preflight + `strict-preflight.metrics.jsonl` | PASS |
| assembly | status `pass_with_commander_accepted_replay_shortfall`; counts `4750 substrate + 647 candidate + 102 replay = 5499`; sha `5c1f6625617f1b42643aa1e49447daa19cbc7d2123eea78d4deb1cde3635f19d` | `assembly_receipt.json` | PASS |
| adapter | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-shorttrain-run-20260704T155204+0800/adapters-rank16/adapters.safetensors`; final sha `0d9b712b3fb10218873797b6e6389b9c3ef02c594dcea5d8b7bf725b56c295f4`; checkpoint `0000600` sha `0d9b712b3fb10218873797b6e6389b9c3ef02c594dcea5d8b7bf725b56c295f4` | final adapter + checkpoint shasum | PASS |
| config | iters `600`; optimizer updates target `150`; batch `4`; grad_accum `4`; token_budget `8192`; grad_checkpoint `true`; rank `16`; lr cosine `1e-4 -> 1e-5`; seed `0` | `f044-r2b-run.sh`, config, `metrics.jsonl` | PASS |
| command | `SHORTTRAIN_MLX_DATA_DIR=$PWD/wave2-fix/r2b-trainpack/mlx-data SYSTEM_MEMORY_FAIL_GB=999 PROCESS_PEAK_FAIL_GB=22.34 WATCHDOG_INTERVAL_SECONDS=15 bash f044-r2b-run.sh` | executor launch log + user command | PASS |

## 训练健康（metrics.jsonl 全量扫描，非抽样）

| 指标 | 值 | source | 判 |
|---|---:|---|---|
| iterations | **600/600** | final train_report iteration | PASS |
| optimizer_update events | **150/150** | metrics scan | PASS |
| train_report records | **60** | metrics scan | PASS |
| nonfinite loss/grad | **0** | metrics scan for NaN/Inf/nonfinite | PASS |
| val loss trajectory | `2.583877`(it1) -> `0.217143`(200) -> `0.126110`(400) -> `0.009583`(600) | metrics scan | PASS |
| val time trajectory | `69.703s` -> `68.176s` -> `60.622s` -> `59.686s` | metrics scan | PASS |
| final train loss | `0.013090269` | iter 600 train_report | PASS |
| final optimizer loss | `0.011685925` | update_step 150 | PASS |
| peak_memory_gb | **`17.974435016`** < stopline `22.34` | metrics scan + watchdog stdout | PASS |
| wall_clock_seconds | **`11336`** (`2026-07-04T15:52:04+0800` -> `2026-07-04T19:01:00+0800`) < stopline `42375` | f044 start epoch + adapter mtime | PASS |
| adapter checkpoints | `0000100_adapters.safetensors, 0000200_adapters.safetensors, 0000300_adapters.safetensors, 0000400_adapters.safetensors, 0000500_adapters.safetensors, 0000600_adapters.safetensors` + final `adapters.safetensors` | adapter dir listing | PASS |
| source snapshot | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-shorttrain-run-20260704T155204+0800/c5_mlx_train_loop.snapshot.py` | run dir listing + sha `9714f6f2700a4c0f77be6bfdc005d291a894e858606a87a1a3838fd9a8f71748` | PASS |
| ckpt50/100 quick probes | **CANCELLED_BY_COMMANDER_RESOURCE_PRESSURE**; no model-loading midprobe executed after cancellation | tmux `%0` override during run; no `ProbeHarness` process at trigger checks | NOT_TRAIN_HEALTH_FAIL |

## 资源/效率四列（R2b 首用）

| wall_clock_seconds | peak_memory_gb | supervised_tok_per_sec | ignored_trainable_ratio | 判 |
|---:|---:|---:|---:|---|
| `11336` | `17.974435016` | `2.257763` | `135.638385:1` | PASS |

Formula:

```text
supervised_tok_per_sec = final trained_tokens / wall_clock_seconds = 25594 / 11336 = 2.257763
ignored_trainable_ratio = ignored_tokens / trainable_tokens = 18133767 / 133692 = 135.638385:1
train_split_ignored_trainable_ratio = 16554474 / 121697 = 136.030255:1
```

## Watchdog / 心跳链

| monitor | records/samples | span | min free+reclaimable | max consecutive `<3GB` | final free+reclaimable | 判 |
|---|---:|---|---:|---:|---:|---|
| `EXECUTOR-MEMORY-MONITOR.jsonl` | `111` / `110` | `2026-07-04T15:52:06+0800` -> `2026-07-04T16:19:50+0800` | `1.600GB` | `92s` | `3.2GB` | PASS `<120s` |
| `EXECUTOR-MEMORY-MONITOR-NOPROBE.jsonl` | `642` / `640` | `2026-07-04T16:21:21+0800` -> `2026-07-04T19:03:12+0800` | `1.920GB` | `76s` | `27.84GB` | PASS `<120s` |
| `f044-r2b-launch-20260704T155204+0800.log` | `756` watchdog-ok lines | start -> process-exit | n/a | n/a | watchdog complete | PASS |

Watchdog tail:

```text
F044 watchdog ok elapsed=11306.7s metrics_records=216 optimizer_update_seen=True process_peak_memory_gb=17.97 system_memory_used_gb=31.56
F044 watchdog ok elapsed=11321.7s metrics_records=218 optimizer_update_seen=True process_peak_memory_gb=17.97 system_memory_used_gb=9.31
F044 watchdog ok elapsed=11336.7s metrics_records=220 optimizer_update_seen=True process_peak_memory_gb=17.97 system_memory_used_gb=23.09
F044 watchdog complete: process exited and adapter exists
```

## 曝光记账（pack-level frozen; run-local row exposure boundary）

| bucket | prelaunch row count | source | effective shorttrain exposure count | verdict |
|---|---:|---|---:|---|
| repair candidates kept after downsample | `647` | `assembly_receipt.json.candidate_envelope.candidate_total_after` | `RUN_LOCAL_ROW_IDS_NOT_LOGGED`; supervised token progress `25594` only | BOUNDARY_RECORDED |
| repair candidate action rows | `503` before no-call downsample | `assembly_receipt.json.candidate_envelope.action_rows_before` | `RUN_LOCAL_ROW_IDS_NOT_LOGGED` | BOUNDARY_RECORDED |
| candidate no-call rows kept | `56` kept / `126` dropped | `assembly_receipt.json.candidate_envelope` | `RUN_LOCAL_ROW_IDS_NOT_LOGGED` | BOUNDARY_RECORDED |
| query tool-call rows | `137` final total | `assembly_receipt.json.counts.query_tool_call_rows` | `RUN_LOCAL_ROW_IDS_NOT_LOGGED` | BOUNDARY_RECORDED |
| physical replay rows | `102`; ratio vs kept candidates `0.157651` | `assembly_receipt.json.replay` | `RUN_LOCAL_ROW_IDS_NOT_LOGGED` | BOUNDARY_RECORDED |
| replay already_state/unsupported analogs | `0/10`; accepted shortfall | `assembly_receipt.json.replay.slices.already_state_unsupported_analogs` | shortfall carried, not silently filled | PASS_BOUNDARY |

Exposure note: this run's metrics do not emit per-row IDs/order, so bucket-level effective exposure cannot be reconstructed from run-local evidence. This is an exposure-accounting limitation, not a train-health failure. Formal successor must carry `R2B-REPLAY-SHORTFALL-01` and add row-id/order logging if bucket exposure is a hard gate.

## 停线复核清单

- [x] No OOM / Metal abort / process abort in `train.log`, `metrics.jsonl`, or launch watchdog log.
- [x] No manual kill, timeout kill, or watchdog kill of trainer; stale stopped outer monitor was killed only after final adapter and trainer exit to reap wrapper zombie.
- [x] No NaN / Inf / nonfinite loss or grad.
- [x] Optimizer update appears in first expected window and reaches `150/150`.
- [x] Final adapter exists and sha is recorded.
- [x] Required checkpoints `100/200/300/400/500/600` exist; ckpt50/100 behavior probes were cancelled by commander resource stopline.
- [x] Source snapshot exists in run dir.
- [x] Peak memory below active stopline `22.34GB`.
- [x] Wall clock below active stopline `42375s`.
- [x] Train preflight data binding matches `wave2-fix/r2b-trainpack/strict-preflight.metrics.jsonl`.
- [x] `supervised_tok_per_sec` and `ignored_trainable_ratio` populated.
- [x] Seed/shuffle strategy recorded as config seed `0`; mount shuffle frozen as seeded shuffle in data-ready receipt.
- [x] Repair/replay/protected/no-call/query pack counts recorded; run-local row exposure IDs are not logged and are bounded above.
- [x] R2B-REPLAY-SHORTFALL-01 carried forward; no silent replay rebalance.
- [x] Checkpoint quick-probe cancellation is carried to eval/verdict lane; no hidden PASS claim.

Stopline verdict:

```text
NO_STOPLINE_HIT_FOR_TRAIN_HEALTH; OPERATOR_MEMORY_REDLINE_NOT_HIT_CONTINUOUS_120S
```

## 断点说明

- 初始 outer monitor included now-cancelled midprobe branch; after `%0` resource override, that monitor was `STOP`ped before any ProbeHarness process ran.
- Replacement monitor `EXECUTOR-MEMORY-MONITOR-NOPROBE.jsonl` enforced `free+reclaimable <3GB for 120s => kill/pause` with no midprobe/model load.
- Wrapper process became zombie because the stopped outer monitor parent was holding it; after final weights and trainer exit, parent was killed only to release the zombie. Training evidence is bound to `train.log`, `metrics.jsonl`, final adapter sha, and watchdog complete line.

## Proof-Class / Non-Claims

| lane | proof class | allowed claim in this receipt | explicit non-claim | paired artifact |
|---|---|---|---|---|
| train-health | `local/metrics_jsonl_firsthand_scan` + `runtime/watchdog_log_scan` | Shorttrain run155204 completed with finite training, final adapter, and stoplines clear. | Not behavior PASS. | This receipt. |
| T-D eval | `local_model_eval_run` after separate eval execution | No verdict here; only handoff trigger. | Not implied by finite loss or saved adapter. | `TD-eval-run155204-ready/` eval receipt. |
| product/demo | future endpoint/desktop/mobile/live proof | No claim here. | Not endpoint, demo-golden, mobile, true-device, or live acceptance. | Future receipt. |

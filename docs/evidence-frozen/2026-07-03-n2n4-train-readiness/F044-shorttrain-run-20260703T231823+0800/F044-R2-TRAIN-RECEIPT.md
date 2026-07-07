# F044-R2-TRAIN-RECEIPT — round-2 短训训练健康收据

status: r2_shorttrain_train_health_pass
proof_class: local/metrics_jsonl_firsthand_scan
scanned_by: claude-commander（接手会话，2026-07-04 晨；上个指挥官会话 f35d9026 在 Iter 90 轮询时掉登录，本收据为断点补账）
claim_boundary: 本收据只声称【训练管线健康 PASS】；不声称 behavior gate、train-ready、C6 acceptance、V/S/U-PASS。behavior 判定见同目录 F044-R2-VERDICT.md。

## Basis 绑定（全部本会话亲算/亲核）

| lane | value | 一手 source |
|---|---|---|
| code | CODE-2026-07-03-PR38 pin `26678346`；train loop sha `9714f6f2700a4c0f77be6bfdc005d291a894e858606a87a1a3838fd9a8f71748` | run `metrics.jsonl` run_metadata.training_loop_source_sha256（亲读） |
| data | wave2-fix/r2-data-ready（mount-rollback 版）：samples sha `59f2f74e6798bc3e3cf62c3fe21858ca0804c69814ffe07b859423f1bd4c6467`；mlx train sha `67bffb9efdf9788424f1e584d44d7a37fa9616f77c7a42c4cb9e2a821ad538f8` | 本会话 shasum 亲算，与 F044-R2-MOUNT-ROLLBACK-READY-RECEIPT.md 逐字一致 |
| data 绑定证明 | run train.log preflight `trainable_tokens=119571 / ignored_tokens=17028936 / max_token_length=7196` 与 r2-data-ready/strict-preflight.metrics.jsonl **逐数一致**（round1 数据为 119579/7684359≠，排除误挂） | train.log:6 + strict-preflight.metrics.jsonl（亲读比对） |
| ⚠️ 注意 | F044-R2-DATA-READY-RECEIPT.md 所载 samples sha `5d00ff81…` 为 mount-rollback **之前**的旧版（23:13 被 rollback 版替换）；R2 verdict 一律绑 `59f2f74e…`，勿引旧 sha | 两收据比对 + 磁盘 sha 亲算 |
| adapter | `adapters-rank16/adapters.safetensors` sha `62ba5f6657504af13190301e56bb45cf0a7eaecdeccc8a9904df09d894379b9a`（=checkpoint 600 final） | 本会话 shasum 亲算 |
| config | t1d-d2combo-r2-config-smoke.yaml：iters 600 / optimizer updates 150 / batch 4 / grad_accum 4 / token_budget 8192 / grad_checkpoint / rank16 | metrics.jsonl run_metadata + train.log:2 |

## 训练健康（metrics.jsonl 全量扫描，非抽样）

| 指标 | 值 | 判 |
|---|---|---|
| optimizer_update 事件 | **150/150**（=配置满額） | PASS |
| train_report | 60（每 10 iter 一条，满 600） | PASS |
| nonfinite loss/grad | **0** | PASS |
| val loss 轨迹 | 3.026(it1) → 0.164(200) → 0.050(400) → **0.0247(600)** | 单调收敛 |
| final train loss | 0.0646（iter 600） | — |
| peak_memory | **17.974 GB**（< 停线 22.34；与 T1D-D2combo 包络一致） | PASS |
| wall clock | 23:18:23 起（dir 名）→ 02:57:21 adapter 落盘（mtime）≈ **13,138s (3h39m)** < 停线 42,375s | PASS |
| adapter checkpoints | 0000100–0000600 全存 + final adapters.safetensors | PASS |
| source snapshot | c5_mlx_train_loop.snapshot.py 在 run dir | PASS |

## 停线复核

§6.2 停止条件逐条：无 OOM/abort/手杀、无 NaN/Inf、optimizer_update 首窗内出现、adapter 存在、snapshot 存在、峰值未越线、墙钟未越线 → **无一命中**。
watchdog 环境（上会话 D-083 起跑记录）：`PROCESS_PEAK_FAIL_GB=22.34 / SYSTEM_MEMORY_FAIL_GB=999(辅助阈按 M.16 教训禁用) / INTERVAL=15`；上会话轮询三次 watchdog ok（814s/1425s 处，metrics_records 递增、optimizer_update_seen=True）。

## 断点说明（诚实记录）

上个指挥官会话在 23:52（Iter 90）后掉登录卡死，训练由 nohup+watchdog 无人值守跑完（02:57）；无 eval/verdict 产物遗留——T8 由本会话接手执行。

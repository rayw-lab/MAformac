# R2B-SHORTTRAIN-TRAIN-RECEIPT — template

status: FILL_AFTER_RUN__r2b_shorttrain_train_health_{pass|fail|partial}
proof_class: local/metrics_jsonl_firsthand_scan
artifact_kind: operational_receipt_template
authority: template_only_not_training_verdict
created_for: R2b shorttrain receipt, fill within 5 minutes after training completion
claim_boundary: This filled receipt may only claim shorttrain pipeline health. It must not claim behavior gate, train-ready, formal-train readiness, C6 acceptance, V-PASS, or product acceptance. Behavior/eval verdict belongs in the eval verdict receipt.

## Source Pattern

| source | role | live-verified note |
|---|---|---|
| `F044-shorttrain-run-20260703T231823+0800/F044-R2-TRAIN-RECEIPT.md` | receipt structure baseline | basis binding -> health scan -> stopline review -> breakpoint note |
| `docs/c5-training-readiness-grill/training-efficiency-deepdive-2026-07-04.md §4` | efficiency-column authority | `supervised_tok_per_sec` + `ignored_trainable_ratio` enter train receipt from R2b |
| `wave2-fix/r2b-trainpack/SHA256SUMS.txt` | data anchor | `c5-training-samples.jsonl` sha `02fda1f01dc85dfa1a3c202ce7a1b0c66603a9bb5b5832ec8b5d2bf497f1c71c` |
| `wave2-fix/r2b-trainpack/assembly_receipt.json` | data assembly proof | status `pass_with_commander_accepted_replay_shortfall`, effective rows 5499 |
| `wave2-fix/r2b-trainpack/strict-preflight.metrics.jsonl` | expected pre-run token basis | current strict preflight: trainable `123096`, ignored `17577760`, max token length `7196` |

## Fill Rules

- Replace every `FILL_AFTER_*` before declaring PASS.
- If any hard field is unavailable, keep status `partial` or `fail`; do not silently delete the row.
- If code pin, train loop sha, data sha, or scorer/eval basis differs from this template, mark `BASIS_CHANGED_REQUIRES_REVIEW`.
- `ignored_trainable_ratio` is data/preflight level: `ignored_tokens / trainable_tokens`.
- `supervised_tok_per_sec` is training-run level: final supervised/trained token count divided by wall-clock seconds.

## Basis 绑定（训后 5 分钟内补齐）

| lane | value | 一手 source | 判 |
|---|---|---|---|
| code | CODE-2026-07-03-PR38 pin `26678346`; expected train loop sha `9714f6f2700a4c0f77be6bfdc005d291a894e858606a87a1a3838fd9a8f71748` | run `metrics.jsonl` `run_metadata.training_loop_source_sha256`; compare to expected | FILL_AFTER_RUN |
| data samples | `wave2-fix/r2b-trainpack/c5-training-samples.jsonl`; rows `5499`; sha `02fda1f01dc85dfa1a3c202ce7a1b0c66603a9bb5b5832ec8b5d2bf497f1c71c` | `SHA256SUMS.txt` + `wc -l` | FILL_AFTER_RUN |
| data assembly | `assembly_receipt.json` sha `3f1c563ae6070d4ceafbd061b14cc8d0a8a0e366f1f5b27225b055cb82f30f0c`; status `pass_with_commander_accepted_replay_shortfall`; counts `4750 substrate + 647 candidate + 102 replay = 5499` | `assembly_receipt.json` + `SHA256SUMS.txt` | FILL_AFTER_RUN |
| rendered MLX train file | FILL_AFTER_RENDER__path_and_sha256 | `shasum -a 256 <rendered mlx train jsonl>` | FILL_AFTER_RENDER |
| data binding proof | train preflight `trainable_tokens=FILL_AFTER_RUN / ignored_tokens=FILL_AFTER_RUN / max_token_length=FILL_AFTER_RUN`; expected current strict-preflight is `123096 / 17577760 / 7196` unless renderer changed | train.log or `metrics.jsonl` preflight + `strict-preflight.metrics.jsonl` compare | FILL_AFTER_RUN |
| adapter | FILL_AFTER_RUN__adapter_path; sha `FILL_AFTER_RUN__adapter_sha256`; checkpoint `FILL_AFTER_RUN__checkpoint_id` | `shasum -a 256`; checkpoint directory listing | FILL_AFTER_RUN |
| config | FILL_AFTER_RUN__config_path; iters `FILL_AFTER_RUN`; optimizer updates target `FILL_AFTER_RUN`; batch `FILL_AFTER_RUN`; grad_accum `FILL_AFTER_RUN`; token_budget `8192`; grad_checkpoint `true`; rank `16`; lr `FILL_AFTER_RUN` | config file + run metadata | FILL_AFTER_RUN |
| command | FILL_AFTER_RUN__exact_shorttrain_command | shell history / runbook / train.log header | FILL_AFTER_RUN |
| run dir | FILL_AFTER_RUN__absolute_run_dir | filesystem + mtime | FILL_AFTER_RUN |

## 训练健康（metrics.jsonl 全量扫描，非抽样）

| 指标 | 值 | source | 判 |
|---|---:|---|---|
| optimizer_update events | FILL_AFTER_RUN / FILL_AFTER_RUN target | metrics scan | FILL_AFTER_RUN |
| train_report records | FILL_AFTER_RUN | metrics scan | FILL_AFTER_RUN |
| nonfinite loss/grad | FILL_AFTER_RUN | metrics scan for NaN/Inf/nonfinite | MUST_BE_0 |
| val loss trajectory | FILL_AFTER_RUN__first_mid_final | metrics scan | FILL_AFTER_RUN |
| final train loss | FILL_AFTER_RUN | metrics final train report | FILL_AFTER_RUN |
| peak_memory_gb | FILL_AFTER_RUN | metrics scan / watchdog | FILL_AFTER_RUN |
| wall_clock_seconds | FILL_AFTER_RUN | run start/end timestamps or adapter mtime | FILL_AFTER_RUN |
| adapter checkpoints | FILL_AFTER_RUN__expected_vs_actual | checkpoint directory listing | FILL_AFTER_RUN |
| source snapshot | FILL_AFTER_RUN__snapshot_path | run dir listing | FILL_AFTER_RUN |
| checkpoint 50 behavior quick probe | FILL_AFTER_RUN__pass_fail_counts_or_NA | R2B-7 quick-probe output | FILL_AFTER_RUN |
| checkpoint 100 behavior quick probe | FILL_AFTER_RUN__pass_fail_counts_or_NA | R2B-7 quick-probe output | FILL_AFTER_RUN |

## 资源/效率四列（M.15 扩展，R2b 首用）

| wall_clock_seconds | peak_memory_gb | supervised_tok_per_sec | ignored_trainable_ratio | 判 |
|---:|---:|---:|---:|---|
| FILL_AFTER_RUN | FILL_AFTER_RUN | FILL_AFTER_RUN__final_supervised_tokens_div_wall_clock_seconds | FILL_AFTER_RUN__ignored_tokens_div_trainable_tokens | FILL_AFTER_RUN |

Formula checklist:

```text
supervised_tok_per_sec = final_supervised_or_trained_tokens / wall_clock_seconds
ignored_trainable_ratio = ignored_tokens / trainable_tokens
```

Expected preflight ratio if R2b trainpack basis is unchanged:

```text
ignored_trainable_ratio = 17577760 / 123096 = 142.796:1
```

## 曝光记账（W27 T7 起跑前冻结 + 训后填写）

Purpose: make data order and replay/protected exposure reconstructable. This section is included here because R2b shorttrain is the source basis for formal-train exposure accounting.

### Prelaunch Frozen Data Basis

| field | frozen value | source | fill rule |
|---|---|---|---|
| trainpack samples | `wave2-fix/r2b-trainpack/c5-training-samples.jsonl`; rows `5499`; sha `3b76d49767e650b2cf5d41a3dd6b527932c1e2e2500bb249ac917303380f84e0` | `F044-R2B-DATA-READY-RECEIPT.md`; `formal-eval-manifest.json` | Must match before using this template as formal basis. |
| trainpack SHA256SUMS | sha `c29763ce9c028493a4f8c79635a67b38e9086f5e97dcb7cdb01e67dbef154269` | `wave2-fix/r2b-trainpack/SHA256SUMS.txt` | Record if regenerated. |
| assembly receipt | sha `5c1f6625617f1b42643aa1e49447daa19cbc7d2123eea78d4deb1cde3635f19d`; status `pass_with_commander_accepted_replay_shortfall` | `assembly_receipt.json` | No silent reassembly. |
| strict preflight | records `5627`; trainable `133692`; ignored `18133767`; split `5099/400/128`; sha `b9e47d2f40ceadbc82aa5fe4f8927de5591fdce1c06f31fc44e792cebad2b701` | `strict-preflight.metrics.jsonl` | If changed, mark `BASIS_CHANGED_REQUIRES_REVIEW`. |
| mount shuffle | `seeded_shuffle`; seed formula `sha256(sample_id|tool_name)`; rows reordered `363` | `F044-R2B-DATA-READY-RECEIPT.md` | Preserve or explain successor. |
| dataloader shuffle seed | FILL_AFTER_RUN__seed_and_shuffle_policy | config + run metadata | Must be printed or reconstructable. |

### Row Exposure Buckets

| bucket | prelaunch row count | source | effective shorttrain exposure count | verdict |
|---|---:|---|---:|---|
| repair candidates kept after downsample | `647` | `assembly_receipt.json.candidate_envelope.candidate_total_after` | FILL_AFTER_RUN__repair_rows_seen_or_reconstructable | FILL_AFTER_RUN |
| repair candidate action rows | `503` before no-call downsample | `assembly_receipt.json.candidate_envelope.action_rows_before` | FILL_AFTER_RUN | FILL_AFTER_RUN |
| candidate no-call rows kept | `56` of `182` before; dropped `126`; target ratio `0.1`; final total no-call `56` | `assembly_receipt.json.candidate_envelope`; `counts.no_call_rows` | FILL_AFTER_RUN__no_call_rows_seen | FILL_AFTER_RUN |
| query tool-call rows | `88` candidate after; final total `137`; excluded from no-call denominator | `assembly_receipt.json.candidate_envelope`; `counts.query_tool_call_rows` | FILL_AFTER_RUN__query_rows_seen | FILL_AFTER_RUN |
| physical replay rows | `102`; ratio vs kept candidates `0.157651`; band `within_10_20pct_band` | `assembly_receipt.json.replay` | FILL_AFTER_RUN__physical_replay_rows_seen | FILL_AFTER_RUN |
| replay clean positives | `44/44` | `assembly_receipt.json.replay.slices.clean_positives` | FILL_AFTER_RUN | FILL_AFTER_RUN |
| replay D-axis same-shape protected analogs | `30/30` | `assembly_receipt.json.replay.slices.d_axis_same_shape` | FILL_AFTER_RUN | FILL_AFTER_RUN |
| replay open-close polarity protected analogs | `16/16` | `assembly_receipt.json.replay.slices.open_close_polarity` | FILL_AFTER_RUN | FILL_AFTER_RUN |
| replay query read-only analogs | `12/12` | `assembly_receipt.json.replay.slices.query_readonly_analogs` | FILL_AFTER_RUN | FILL_AFTER_RUN |
| replay already_state/unsupported analogs | `0/10`; shortfall `10` | `assembly_receipt.json.replay.slices.already_state_unsupported_analogs` | FILL_AFTER_RUN__shortfall_carried_not_filled | MUST_NOT_SILENTLY_REBALANCE |

Replay shortfall carryover:

```text
R2B-REPLAY-SHORTFALL-01 accepted: substrate lacks already_state/unsupported analog replay sources; 102/647 remains inside the 10-20% band. Any formal successor must carry this ruling forward or explicitly reopen it before launch.
```

Formula checklist:

```text
effective_row_exposure_count(bucket) = run-local sampler/order evidence for that bucket, not pack-level count alone
if data pack changes after R2b verdict: condition #4 invalidates and this receipt must remain partial
```

## 停线复核清单

- [ ] No OOM / Metal abort / process abort.
- [ ] No manual kill, timeout kill, or watchdog kill.
- [ ] No NaN / Inf / nonfinite loss or grad.
- [ ] Optimizer update appears in first expected window.
- [ ] Final adapter exists and sha is recorded.
- [ ] Required checkpoints exist or missing checkpoint is explained.
- [ ] Source snapshot exists in run dir.
- [ ] Peak memory is below the active stopline threshold: `FILL_AFTER_RUN__threshold_gb`.
- [ ] Wall clock is below the active stopline threshold: `FILL_AFTER_RUN__threshold_seconds`.
- [ ] Train preflight data binding matches `wave2-fix/r2b-trainpack/strict-preflight.metrics.jsonl`, or the delta is explicitly explained.
- [ ] `supervised_tok_per_sec` and `ignored_trainable_ratio` are populated.
- [ ] Seed/shuffle strategy and trainpack digest are recorded.
- [ ] Repair/replay/protected/no-call/query exposure counts are printed or reconstructable.
- [ ] R2B-REPLAY-SHORTFALL-01 is carried forward; no silent replay rebalance.
- [ ] Any checkpoint 50/100 quick-probe FAIL is carried to the eval/verdict lane; it is not hidden by train-health PASS.

Stopline verdict:

```text
FILL_AFTER_RUN__NO_STOPLINE_HIT_OR_EXACT_STOPLINE_HIT
```

## 断点说明（诚实记录）

FILL_AFTER_RUN__operator_session_breakpoints_watchdog_notes_login_drop_or_NONE

## Proof-Class 四分隔 / Non-Claims

| lane | proof class | allowed claim in this filled receipt | explicit non-claim | required paired artifact |
|---|---|---|---|---|
| train-health | `local/metrics_jsonl_firsthand_scan` | Shorttrain run completed/failed/partial with health evidence. | Not F044 behavior PASS. | This receipt. |
| F044 formal behavior | `local_model_eval_run` only after separate eval execution | No claim here; handoff only. | Not implied by finite loss or saved adapter. | `formal-eval-manifest.json` + filled eval/verdict receipt. |
| future C6 model-quality | `future_c6_bench` | No claim here. | Not C6 acceptance, not model-quality V-PASS. | Future C6 receipt. |
| endpoint/demo | `future_endpoint_or_desktop_or_mobile` | No claim here. | Not endpoint readiness, not demo-golden, not mobile/true-device/live proof. | Future endpoint/demo receipt. |

## Closeout Boundary

This receipt is DONE only when all basis rows, health rows, efficiency columns, and stopline checkboxes are filled from run-local evidence. If any one is missing, final status must remain `partial`.

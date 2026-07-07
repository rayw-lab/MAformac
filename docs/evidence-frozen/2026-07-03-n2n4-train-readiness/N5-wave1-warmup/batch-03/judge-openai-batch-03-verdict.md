# OpenAI Judge Verdict - warmup-batch-03

verdict: PASS
batch_id: warmup-batch-03
lane_id: subcc-3
candidate_count_denominator: 50
candidate_pool_sha256: 85f8067c5c040bad2bcf38f88b569b2c90c991f7aa09d6e9f5cb7abd59a0fa9b
batch_order_sha256: 9d1f5394839a293df7e28aab162eb365522e081580681a3c6c6a27b43b4ed4ce
main_pin_sha: b33d8eba152e5326f69bbe85fc356b73419ee9c3
sample_size_formula_version: judge_sampling_rev2.1_family_min50_max20_10pct
sample_row_ids: N5E-wb03-subcc3-0012, N5E-wb03-subcc3-0025, N5E-wb03-subcc3-0014, N5E-wb03-subcc3-0003, N5E-wb03-subcc3-0011, N5E-wb03-subcc3-0020, N5E-wb03-subcc3-0023, N5E-wb03-subcc3-0024, N5E-wb03-subcc3-0006, N5E-wb03-subcc3-0007, N5E-wb03-subcc3-0026, N5E-wb03-subcc3-0047, N5E-wb03-subcc3-0043, N5E-wb03-subcc3-0029, N5E-wb03-subcc3-0042, N5E-wb03-subcc3-0040, N5E-wb03-subcc3-0030, N5E-wb03-subcc3-0038, N5E-wb03-subcc3-0032, N5E-wb03-subcc3-0050
sample_sample_ids: warmup-batch-03-subcc-3-0012, warmup-batch-03-subcc-3-0025, warmup-batch-03-subcc-3-0014, warmup-batch-03-subcc-3-0003, warmup-batch-03-subcc-3-0011, warmup-batch-03-subcc-3-0020, warmup-batch-03-subcc-3-0023, warmup-batch-03-subcc-3-0024, warmup-batch-03-subcc-3-0006, warmup-batch-03-subcc-3-0007, warmup-batch-03-subcc-3-0026, warmup-batch-03-subcc-3-0047, warmup-batch-03-subcc-3-0043, warmup-batch-03-subcc-3-0029, warmup-batch-03-subcc-3-0042, warmup-batch-03-subcc-3-0040, warmup-batch-03-subcc-3-0030, warmup-batch-03-subcc-3-0038, warmup-batch-03-subcc-3-0032, warmup-batch-03-subcc-3-0050
mechanical_full_coverage: D5/D6/D7/D9/A10/A11/A12 = 50/50
semantic_sample_coverage: D1/D2/D3/D4/D8 = 20/50
family_judge_status: accepted_sampled
hard_mechanical_failures: none
sampled_semantic_failures: 0
warnings: none
claim_tier: full_mechanical + sampled_semantic
proof_class: local/openai-family-judge

## Verdict Summary

B03 is **accepted with tiered claims**. Full mechanical/provenance dimensions D5/D6/D7/D9/A10/A11/A12 were evaluated over all 50 rows. The deterministic stratified 20-row semantic sample covers 10 `window` and 10 `door` rows and includes the repaired rows `warmup-batch-03-subcc-3-0012` and `warmup-batch-03-subcc-3-0025` as required.

The accepted-pool candidate sha for this judge is `85f8067c5c040bad2bcf38f88b569b2c90c991f7aa09d6e9f5cb7abd59a0fa9b`. B03 gates v2 reports `status=mechanical_gates_pass_local`, DataGate `status=data_gate_ready`, diversity `status=PASS`, and C6 leakage `status=pass`. Independent D3 position scan: window position phrase rows=14, residual failures=0; entity-word rows not requiring `position`=23 (tailgate/back-trunk/fuel-cap/comfortable-entry wording is routed by tool/entity, not by a position slot).

## Mechanical Full-Run Result

| dimension | coverage | status | evidence |
|---|---:|---|---|
| D5 leakage / training-boundary | 50/50 | PASS | no leakage regex hit in training-facing fields; C6 leakage v2 status=`pass`, intersections=0 |
| D6 redaction / safety hygiene | 50/50 | PASS | `raw_source_redacted=true`, `raw_text_absent=true`; refusal rows 0; DataGate redaction_status=`pass` |
| D7 surface-field consistency | 50/50 | PASS | row-level recipe/quota shas match manifest; `candidate_row_sha` recomputed; SHA256SUMS exact 5-file set current |
| D9 ledger and provenance | 50/50 | PASS | ledger closed 50/50; `schema_check=pass`; candidate row sha aligned; all B03 rows carry registration ids, with `value_changed` determined by actual `args_diff` |
| A10 hash recipe integrity | 50/50 | PASS | `prompt_hash=sha256(input_zh)`, `expected_tool_call_signature=sha256(rendered_tool_call)`, row sha recomputed |
| A11 quota and manifest conformance | 50/50 | PASS | quota actual 50; family counts `window=25`, `door=25`; refusal 0; manual override false |
| A12 parent-value / args-diff audit | 50/50 | PASS | `template_args` vs `canary_args` recomputed; `args_diff` and `value_changed` flag match actual row arguments |

## Sampled Semantic Result

| dimension | sampled coverage | status | evidence |
|---|---:|---|---|
| D1 natural Chinese | 20/50 | PASS | sampled utterances are natural/demo-usable; no protocol string or template echo |
| D2 target surface correctness | 20/50 | PASS | sampled tools stay inside B03 mounted `window` / `door` surfaces; `door` includes mounted tailgate, fuel cap, and comfortable-entry tools from the controller subset |
| D3 expected tool-call correctness | 20/50 | PASS | tool names, schema keys/enums, optional position/value slots, and parsed rendered tool calls match sampled utterances; repair rows 0012/0025 have correct `position` slots |
| D4 value-change semantic legitimacy | 20/50 | PASS | sampled value changes are registered and semantically justified by `input_zh`; false-change rows have empty `args_diff` |
| D8 diversity and non-slop | 20/50 | PASS | diversity-v2 PASS; near_duplicate_warning_count=0; sample covers repaired rows, short/long edges, open/close polarity, changed/unchanged paths |

### Semantic Sample Rows

| row_id | family | sample_reason | input_zh | tool_name | arguments |
|---|---|---|---|---|---|
| N5E-wb03-subcc3-0012 | window | repair_required | 主驾窗户开小一点透透气 | `open_window_little` | `{"position": "主驾", "value": "LITTLE"}` |
| N5E-wb03-subcc3-0025 | window | repair_required | 后排窗户收一点点 | `close_window_little` | `{"position": "后排", "value": "LITTLE"}` |
| N5E-wb03-subcc3-0014 | window | length_short_edge | 关车窗 | `close_window` | `{}` |
| N5E-wb03-subcc3-0003 | window | length_long_edge | 麻烦帮我把全车的窗户都降下来透透气 | `open_window` | `{"position": "全车"}` |
| N5E-wb03-subcc3-0011 | window | value_unchanged_representative | 车窗开一条缝 | `open_window_little` | `{"value": "LITTLE"}` |
| N5E-wb03-subcc3-0020 | window | value_changed_representative | 车窗往上收百分之二十 | `close_window_by_number` | `{"value": "20"}` |
| N5E-wb03-subcc3-0023 | window | close_polarity | 车窗关小一点 | `close_window_little` | `{"value": "LITTLE"}` |
| N5E-wb03-subcc3-0024 | window | hash_fill | 把窗户稍微往上关一点 | `close_window_little` | `{"value": "LITTLE"}` |
| N5E-wb03-subcc3-0006 | window | hash_fill | 主驾这边窗户开到百分之七十 | `open_window_to_number` | `{"position": "主驾", "value": "70"}` |
| N5E-wb03-subcc3-0007 | window | hash_fill | 帮我把后排两侧的车窗全部都放下来 | `open_window_to_number` | `{"position": "后排", "value": "100"}` |
| N5E-wb03-subcc3-0026 | door | length_short_edge | 打开尾门 | `open_tailgate` | `{}` |
| N5E-wb03-subcc3-0047 | door | length_long_edge | 马上就要加油了，帮我把加油口盖打开 | `open_fuel_tank_cap` | `{}` |
| N5E-wb03-subcc3-0043 | door | value_unchanged_representative | 关掉上下车的舒适进出 | `close_comfortable_entry_exit` | `{}` |
| N5E-wb03-subcc3-0029 | door | open_polarity | 尾门升起来 | `open_tailgate` | `{}` |
| N5E-wb03-subcc3-0042 | door | close_polarity | 取消舒适进出功能 | `close_comfortable_entry_exit` | `{}` |
| N5E-wb03-subcc3-0040 | door | hash_fill | 关闭舒适进出 | `close_comfortable_entry_exit` | `{}` |
| N5E-wb03-subcc3-0030 | door | hash_fill | 开启行李箱盖 | `open_tailgate` | `{}` |
| N5E-wb03-subcc3-0038 | door | hash_fill | 帮我把座椅的上下车舒适进出功能打开 | `open_comfortable_entry_exit` | `{}` |
| N5E-wb03-subcc3-0032 | door | hash_fill | 把后备箱关上 | `close_tailgate` | `{}` |
| N5E-wb03-subcc3-0050 | door | hash_fill | 油箱盖关好 | `close_fuel_tank_cap` | `{}` |

### Sampled Semantic Failures

| row_id | dimension | input_zh | tool_name | arguments | evidence |
|---|---|---|---|---|---|
| none | none | none | none | none | none |

## Artifact Binding

| artifact | sha256 |
|---|---|
| JUDGE-SPEC-batch-03.md | 210ddc0b8b2d20fb1047e24b53329d4fd997bc725e2b10f0a9d31a8231227421 |
| B03-GATES-RECEIPT-v2.md | a3e89a8c1869339a85f57685fef3983a5edefc08834180ba6d39c98e51ec1eee |
| B03-GATES-RECEIPT-v2.json | a4ba03d58f500fda67b060cfdab83946995af33b115a740374bbd82d077ac179 |
| candidates.jsonl | 85f8067c5c040bad2bcf38f88b569b2c90c991f7aa09d6e9f5cb7abd59a0fa9b |
| value_change_ledger.jsonl | 8e92bf306eeeb68656565f7a91db10135e2a3471ad4b94e4de3b96788be3b01d |
| batch_manifest.json | a40c3cc139d33cb3ab47e539c68d4edcdb17d258426c607e9b9849ed265167e3 |
| SHA256SUMS.txt | 9c864db462bbeb8422d2254bc06cf6835b011ba4802ef56123d5793990ebf6e8 |
| judge-openai-batch-03-row-scores.jsonl | 5558f2b4ad0cdeb9390594670f74feb5ce902f9431acb7c1068222a33260d491 |
| judge-openai-batch-03-mechanical-audit.json | 35a3aa615aa781dab9ebfd78ce1496ae2056974c6fade485c7601731389058bc |

## Claim Discipline

Tier 1, full mechanical claim: For warmup-batch-03, mechanical judge dimensions D5/D6/D7/D9/A10/A11/A12 were evaluated over all 50 candidate rows from lane subcc-3. The claim is full-run only for those mechanical/provenance dimensions and is bound to candidate_pool_sha256=85f8067c5c040bad2bcf38f88b569b2c90c991f7aa09d6e9f5cb7abd59a0fa9b, batch_order_sha256=9d1f5394839a293df7e28aab162eb365522e081580681a3c6c6a27b43b4ed4ce, and main_pin_sha=b33d8eba152e5326f69bbe85fc356b73419ee9c3.

Tier 2, sampled semantic confidence claim: For warmup-batch-03, semantic judge dimensions D1/D2/D3/D4/D8 were reviewed on a deterministic stratified sample of 20 rows out of the 50-row candidate pool, using sample_size_formula_version=judge_sampling_rev2.1_family_min50_max20_10pct and sample_row_ids=N5E-wb03-subcc3-0012, N5E-wb03-subcc3-0025, N5E-wb03-subcc3-0014, N5E-wb03-subcc3-0003, N5E-wb03-subcc3-0011, N5E-wb03-subcc3-0020, N5E-wb03-subcc3-0023, N5E-wb03-subcc3-0024, N5E-wb03-subcc3-0006, N5E-wb03-subcc3-0007, N5E-wb03-subcc3-0026, N5E-wb03-subcc3-0047, N5E-wb03-subcc3-0043, N5E-wb03-subcc3-0029, N5E-wb03-subcc3-0042, N5E-wb03-subcc3-0040, N5E-wb03-subcc3-0030, N5E-wb03-subcc3-0038, N5E-wb03-subcc3-0032, N5E-wb03-subcc3-0050. This supports only a sampled-confidence semantic claim for the batch; it must not be phrased as all 50 rows passing semantic review.

Forbidden upgrades observed: no train-ready, C6 acceptance, model-quality V-PASS, or all-50 semantic pass claim is made here.

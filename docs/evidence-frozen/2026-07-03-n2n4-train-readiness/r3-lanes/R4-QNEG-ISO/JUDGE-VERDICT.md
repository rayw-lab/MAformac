# R4-QNEG-ISO JUDGE-VERDICT

日期: 2026-07-05
角色: R4 scoped judge
对象: `r3-lanes/R4-QNEG-ISO/candidates.jsonl`
artifact_kind: experimental judge receipt, not project SSOT
proof_class: local static audit + structured JSONL diff; no model load, no training

## 0. Verdict

**PASS_WITH_NOTES / 可进入 scoped assemble + shorttrain 前置链。**

无 P0。R4-QNEG-ISO 的核心变换成立: 154 行总数不变, 144 行 transformed, 10 行 query guard passthrough; 108 no-call + 36 positive controls 的 `tools` 已替换为同族 eval-probe mount 或其 token-budget 截断版, 诱惑工具保留, positive expected tool 保留或补挂; `messages/input_zh/expected_tool_calls/class/class_id/nn_group` 等 protected fields 对 R3 原行无漂移。

但有三个必须带入后续 receipt 的 notes:

1. **door 16 行是 set-isomorphic, 非 strict order-isomorphic**: 48-tool eval source 被裁到 42-tool, 工具集合等于 source minus 6 个 trimmed tail/settings 工具, 且 `open_tailgate` 与 expected tool 在场; 但顺序被固定工具策略调整, 不等于原 source 顺序。若指挥官把“同构”定义为严格顺序同构, 这 16 行应回脚本重跑; 当前机械门和 D-103 语义看的是 cardinality/composition, 我不把它列 P0。
2. **light/screen/volume 本身不是 >=15 mount**: 它们的 eval-probe source 只有 2/8/8 个工具, 所以不能同时满足“同族 eval 探针同构”和“每 family >=15”。我把 15 行主抽样放在大挂载 family 上; 小 mount family 作为 source fidelity 补核通过。
3. **8 条 positive control 是 source mount + expected tool append**: seat/light/screen/volume 有 expected tool 不在对应 query eval source mount 内, 脚本补挂 expected tool。这个处理保护 positive control 合法性, 但它不是纯 source-only mount; 后续报告不能写成 144 行全部“只替换为原样 eval source mount”。

## 1. Authority And Inputs

- D-103 authority: `docs/commander-log/decisions.md:768-772` 明确 R4 为机械变换, 即 108 负例 + 36 对照行 tools 字段替换为同族 eval 探针同构挂载, 话术/expected 不动。
- R3 source lane: `r3-lanes/R3-QNEG/candidates.jsonl`, 154 行; `r3-lanes/R3-QNEG/LANE-REPORT.md:5-16` 记录 108 unsupported + 36 positive + 10 true-query guards。
- R4 candidate: `r3-lanes/R4-QNEG-ISO/candidates.jsonl`, 154 行。
- R4 mechanical receipt: `MOUNT-ISO-RECEIPT.md:3-26`, `mount_isomorphize_receipt.json`.
- R4 v2 gates: `GATES-REPORT-v2.json`, `mount_validity_report.json`, `supervision-summary-v2.json`, `query-shape-v2.json`.

## 2. Mechanical Gate Readback

| Check | Result |
| --- | --- |
| input_rows / output_rows | 154 / 154 |
| transformed_rows | 144 |
| guard_passthrough_rows | 10 |
| unsupported / positive / query_guard | 108 / 36 / 10 |
| family_transform_counts | 9 families x 16 rows |
| trimmed_rows / trimmed_tool_total | 16 / 96 |
| token_limit / max_prompt_token_count | 7600 / 7530 |
| mount_validity_report | PASS, violation_count=0 |
| supervision scanner | pass_no_contradictions, contradiction_row_count=0 |
| query_shape audit | pass, failure_count=0, no_tool_rows=108, query_tool_call_rows=10 |

## 3. Protected Field Diff

I compared all 154 rows against `R3-QNEG/candidates.jsonl` by `sample_id`.

Protected fields checked:

`input_zh`, `messages`, `expected_tool_calls`, `class`, `class_id`, `family_id`, `semantic_family`, `nn_group_id`, `near_neighbor_group_id`, `contrastive_pair_id`, `pair_group_id`, `query_reclass_reason_for_unsupported_query_style`.

Result:

```text
ROWS 154 154
PROTECTED_FAIL_COUNT 0
GUARD_FULL_DIFF_COUNT 0
```

Interpretation: 话术、assistant `NO_TOOL` / tool-call supervision、class、expected、pair/nn metadata 与 R3 原行保持一致。10 条 guard 行是 full-row exact unchanged, 不只是 protected fields unchanged。

## 4. 15-Line Mount Correctness Sample

主抽样覆盖 >=15 mounted-tool context 的 large-mount families: seat/window/door/wiper/sunroof/sunshade。每行核: source case、before->after count、诱惑工具在场、positive expected tool 在场、token count、trim notes。

| sample_id | family | class | count | source_case | lure present | expected present | prompt_tokens | note |
| --- | --- | --- | ---: | --- | --- | --- | ---: | --- |
| r3-qneg-seat-neg-001 | seat | unsupported | 4->23 | R2B-Q-SEAT-001Q | open_seat_heat yes | n/a | 7216 | full source |
| r3-qneg-seat-pos-001 | seat | positive | 4->24 | R2B-Q-SEAT-001Q | open_seat_heat yes | open_seat_ventilation yes | 7530 | expected appended |
| r3-qneg-window-neg-001 | window | unsupported | 4->27 | R2B-Q-WINDOW-001Q | open_window yes | n/a | 6179 | full source |
| r3-qneg-window-pos-003 | window | positive | 4->27 | R2B-Q-WINDOW-001Q | open_window yes | open_window_to_number yes | 6201 | full source |
| r3-qneg-door-neg-001 | door | unsupported | 4->42 | R2B-Q-DOOR-001Q | open_tailgate yes | n/a | 7495 | trimmed 6 |
| r3-qneg-door-pos-001 | door | positive | 4->42 | R2B-Q-DOOR-001Q | open_tailgate yes | open_car_door yes | 7508 | trimmed 6 |
| r3-qneg-wiper-neg-001 | wiper | unsupported | 4->27 | R2B-Q-WIPER-001Q | open_wiper yes | n/a | 4181 | full source |
| r3-qneg-wiper-pos-003 | wiper | positive | 4->27 | R2B-Q-WIPER-001Q | open_wiper yes | raise_wiper_speed_by_number yes | 4198 | full source |
| r3-qneg-sunroof-neg-001 | sunroof | unsupported | 4->30 | R2B-Q-SUNROOF-001Q | open_sunroof yes | n/a | 4183 | full source |
| r3-qneg-sunroof-pos-001 | sunroof | positive | 4->30 | R2B-Q-SUNROOF-001Q | open_sunroof yes | open_sunroof yes | 4195 | full source |
| r3-qneg-sunshade-neg-001 | sunshade | unsupported | 4->30 | R2B-Q-SUNSHADE-001Q | open_sunshade yes | n/a | 4184 | full source |
| r3-qneg-sunshade-pos-001 | sunshade | positive | 4->30 | R2B-Q-SUNSHADE-001Q | open_sunshade yes | open_sunshade yes | 4196 | full source |
| r3-qneg-door-neg-012 | door | unsupported | 4->42 | R2B-Q-DOOR-001Q | open_tailgate yes | n/a | 7497 | trimmed 6 |
| r3-qneg-seat-neg-012 | seat | unsupported | 4->23 | R2B-Q-SEAT-001Q | open_seat_heat yes | n/a | 7215 | full source |
| r3-qneg-window-neg-012 | window | unsupported | 4->27 | R2B-Q-WINDOW-001Q | open_window yes | n/a | 6180 | full source |

Sample verdict: **PASS**。15 行全部保留同族 lure, positive 行保留 expected tool, 且 mounted count 均 >=23。

## 5. Small-Mount Family Cross-Check

Source eval probes for these families are smaller than 15 tools:

| family | source mounted_count | source lure |
| --- | ---: | --- |
| light | 2 | open_atmosphere_lamp |
| screen | 8 | adjust_screen_brightness_to_number |
| volume | 8 | none recorded in qzero source |

These rows cannot satisfy `>=15` without inventing tools beyond the eval source. I treat this as **not a transform failure** because D-103 says same-family eval-probe isomorphism; adding arbitrary extra tools would create a second variable.

Append rows:

```text
r3-qneg-light-pos-003 -> switch_atmosphere_lamp_color
r3-qneg-light-pos-004 -> adjust_atmosphere_lamp_brightness_to_number
r3-qneg-screen-pos-001 -> switch_screen_content
r3-qneg-screen-pos-002 -> close_screen_content
r3-qneg-volume-pos-004 -> volume_mute
```

这些 append 是为了让 positive expected tool 在 mount 内, 与 supervision scanner 的零矛盾结果一致。

## 6. Token Cap / Trim Review

裁剪只发生在 door family 16 行:

- eval source: 48 tools
- R4 after trim: 42 tools
- pre_trim_prompt_token_count: 8837-8851
- prompt_token_count after trim: 7495-7509
- max_prompt_token_count whole lane: 7530, below token_limit 7600

每条 door row 被裁掉同一组 6 个工具:

```text
set_tailgate_opening_upper_limit
set_maximum_of_door_opening_to_number
set_glove_compartment_password
set_door_speed_to_number
set_door_speed_to_gear
raise_tailgate_height_little
```

Reasonableness:

- `open_tailgate` lure retained.
- positive expected tools retained: `open_car_door`, `close_car_door`, `lock_door`, `unlock_door`.
- dropped tools are mostly settings/password/speed/limit tail tools; `raise_tailgate_height_little` is still door/tailgate-related, but it is not the observed lure and not a positive expected tool.

Verdict: **acceptable for token cap**, with the order-isomorphism note from §0.

## 7. Guard 10 Rows

Full-row exact unchanged against R3 source:

| line | sample_id | family | expected |
| ---: | --- | --- | --- |
| 145 | r3-qguard-ac_temperature-001 | ac_temperature | query_ac_temperature |
| 146 | r3-qguard-ac_temperature-002 | ac_temperature | query_ac_temperature |
| 147 | r3-qguard-ac_windspeed-001 | ac_windspeed | query_ac_windspeed |
| 148 | r3-qguard-ac_windspeed-002 | ac_windspeed | query_ac_windspeed |
| 149 | r3-qguard-current_volume-001 | volume | query_current_volume |
| 150 | r3-qguard-current_volume-002 | volume | query_current_volume |
| 151 | r3-qguard-amount_of_fragrance-001 | fragrance | query_amount_of_fragrance |
| 152 | r3-qguard-amount_of_fragrance-002 | fragrance | query_amount_of_fragrance |
| 153 | r3-qguard-mode_of_fragrance-001 | fragrance | query_mode_of_fragrance |
| 154 | r3-qguard-mode_of_fragrance-002 | fragrance | query_mode_of_fragrance |

Guard verdict: **PASS**。

## 8. Residual Risk / Stop Conditions

No judge-side P0 found.

P1 notes to carry forward:

- If downstream owner requires strict tool order isomorphism, door rows must be regenerated; current R4 is composition-isomorphic after trim, not source-order-isomorphic.
- If `>=15 mounted context` is promoted to all-family hard rule, light/screen/volume need a new design decision because the eval source itself is smaller than 15.
- R4 shorttrain still must obey W55 hard stop: post-train qa cross-track must reach `adapter_out=0`; true query guard and A/B/D must not regress. This static judge does not claim model behavior pass.

## 9. Validation Commands

```text
git status --short
wc -l R4-QNEG-ISO/candidates.jsonl R3-QNEG/candidates.jsonl
jq '{status,input_rows,output_rows,transformed_rows,guard_passthrough_rows,trimmed_rows,trimmed_tool_total,max_prompt_token_count,token_limit}' mount_isomorphize_receipt.json
jq '.' mount_validity_report.json supervision-summary-v2.json query-shape-v2.json
python3 structured diff: R3 vs R4 protected fields, guard full-row equality, mount/lure/expected presence sample
```

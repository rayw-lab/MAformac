# R2b S2 Batch1 Lane-D 生成回执 (generation_receipt)

- artifact_kind: r2b_s2_lane_d_generation_receipt
- status: generated_generation_stage
- proof_class: local/pre_training_batch_generation_stage
- created_at: 2026-07-04

## Generator

| 字段 | 值 |
|---|---|
| lane_id | r2b-s2-lane-d |
| lane_vendor / generator_source_vendor | anthropic |
| generator_model_id | claude-opus-4-8 |
| judge_source_vendor_required | openai（same-vendor judge 禁止）|
| generator instance note | 断流替补实例（前任零产出，从头生成）|

## 输入 SSOT（逐份精读，照做）

- `wave2-negatives/batch-package/lane-prompt-package.md#S2 Batch1 Addendum: lane-c / lane-d`（S1 全铁律 + lane-d 合同）
- `wave2-negatives/batch-package/r2b-s2-batch1-order.json`（lane-d 机器可读 quota）
- `wave2-negatives/batch-package/MECHANICAL-GATES-r2b-s1.md`（自检门）
- `N5-canary/BATCH-CONTRACT-rev2.md`（行 schema 契约）
- `W9-R2B-CONTRASTIVE-PAIR-SPEC.md` + `MAformac/contracts/semantic-function-contract.jsonl`（pair 取材一手源）
- 行格式基线：`wave2-negatives/r2b-s1-lane-b/candidates.jsonl` + `wave2-negatives/r2b-s2-lane-c/candidates.jsonl`（S2 同批参考，49-key uniform schema）

## 一手源核验（claim-vs-reality）

- 23 个用到的 intent/tool 名 + arg schema 已对 `MAformac/contracts/semantic-function-contract.jsonl`（3990 行）逐条核（device/action_primitive/slot_keys/range 全 OK），非仅信 lane-c。
- Hash 配方逆向验证并与 lane-c 一致：prompt_hash=sha256(input_zh)；expected_tool_call_signature=sha256(`<tool_call>{...}</tool_call>`) 或 sha256(`NO_TOOL`)；tool_schema_digest=sha256(compact tools)；source_template_sha=sha256(template_sample_id)。
- 挂载工具 schema 直接复用 lane-c 契约派生对象（`_scratch/lane-c-tool-schemas.json`，36 tools），保证与契约一致。

## 生成方式

- 确定性脚本 `_scratch/gen_lane_d.py`（可重跑，防断流；脚本即产物）。规格逐行内联，展开 → candidates.jsonl + value_change_ledger.jsonl。
- 自检 `_scratch/audit_lane_d.py`（fail-closed，逐行全量跑所有门）。

## 交付账（family × class）

| family | total | positive | query | refusal | already_state | unsupported | followup |
|---|---:|---:|---:|---:|---:|---:|---:|
| ac | 30 | 9 | 15 | 2 | 1 | 2 | 1 |
| screen | 30 | 19 | 0 | 2 | 3 | 3 | 3 |
| window | 15 | 9 | 0 | 1 | 2 | 2 | 1 |
| **total** | **75** | **37** | **15** | **5** | **6** | **7** | **5** |

query 分桶：query_ac_temperature=7，query_ac_windspeed=8（对齐 lane-d query_bucket_quota）。

## Mandatory-continuation + screen 两簇 + pair floor 触达

| floor | fresh pair groups | pair_group_ids | 说明 |
|---|---:|---|---|
| set_interface_vs_defog | 3 | sivd_5, sivd_6, sivd_7 | mandatory_continuation；行 1-6（near top）；mfoi 9..14 续接 lane-c 1..8；≥3 达标 |
| screen_little_vs_number | 1 | scr_lvn_2 | 与 lane-c scr_lvn_1 累计 2（batch1_cumulative≥2 达标）|
| screen_gear_min_max_vs_number | 1 | scr_gmn_2 | 与 lane-c scr_gmn_1 累计 2（batch1_cumulative≥2 达标）|
| window_repair_after_F1 | 2 | wrf1_3, wrf1_4 | ≥2 达标；numeric_value_constant=true（F1 修复）|

pair 行合计 14（7 组×2）。lane-c pair_group_id 冲突 = 0（续编号，无碰撞）。

## F1 数值持恒（F1 lesson）

- wrf1_3：absolute-target(开到,open_window_to_number) vs relative-delta(往上再开,open_window_by_number)，value=3 两 mate 恒定，polarity=open held → 单 cue=target-vs-delta，numeric_value_constant=true。
- wrf1_4：polarity(降到=close_window_to_number vs 升到=open_window_to_number)，value=5 两 mate 恒定 → 单 cue=polarity，numeric_value_constant=true。
- screen little/gear pair：cue=numeral-presence（little/extremum mate 无数值），数字本身即被测 cue，与 lane-c scr_lvn_1/scr_gmn_1 "the numeral is the discriminating cue" 框架一致。

## R2B-NVC-01 结构化字段（收尾热修，lane-c FAIL_MECHANICAL 先例）

8 个值型 pair 行补结构化字段 `numeric_value_constant`（判据看 pair floor，非仅 prose）：
- screen_little_vs_number(d-031/032) + screen_gear_min_max_vs_number(d-033/034) = `"value_is_cue"`（数值差异即被测线索；prose 同步 numeric_value_constant=value_is_cue）
- window_repair_after_F1(d-061/062 双 3挡 / d-063/064 双 5挡) = `true`（数值两 mate 恒定，commander 已亲核 3=3、5=5）
- set_interface_vs_defog(d-001..006) 非值型 pair → **字段缺省，不加**
- 补字段后 candidate_row_sha 已含该字段重算，value_change_ledger 的 candidate_row_sha 同步（crs_synced=True 逐行核）。自检门加 R2B_NVC gate（8 行值正确 + 非值型行无 stray 字段），仍 0 fail。

## Blocked / Waived 行

- generation_blocked_* = **0**（无 Stop Condition 命中：无 query 需渲染为 action、无 no-call 缺 metadata、无 near-parallel 只能 style rewrite、无挂载面缺声称 shape、无字段缺 controller authority）。
- class_ratio no-call 0.30 > 0.20 → **waiver_required（candidate_pool_oversample_allowed_train_pack_downsample_required，order.json 声明，非 generation blocker）**。批级合计 35/120=0.2917（= 声明值）。

## 自检门逐项结果

`_scratch/audit_lane_d.py`：**FAILS=0 / WARNS=0 → ALL_GATES_PASS**。
gates: A10 / A11 / A12 / D5 / D6 / D7 / D9 / R2B class shape / R2B pair ledger / R2B near-parallel / R2B position scan / R2B digest authority / D-087 boundary / mandatory_continuation / F1 numeric constancy / length breadth。

## Artifact SHA256（generation-stage）

- candidates.jsonl : `b98756f038c063b13a37a7bcb9f3168d109681276ee6378544cca248ac187573`
- value_change_ledger.jsonl : `34c66516d91462126eae01f7f4f0801b59e875959b329886fd260e93583441b5`
- 其余见 `SHA256SUMS.txt`（写完全部文件后计算）。

## Controller-pending（本 lane 不填，交 controller/prepare pipeline）

- `main_pin_sha` = PENDING_COMMANDER_MAIN_PIN_N5E006
- `recipe_manifest_sha` / `quota_config_sha` = PENDING_CONTROLLER_*_S2_BATCH1（quota SSOT = Gate7RecipeQuotaConfig 派生，lane 不手写）
- `tool_schema_digest` / `prompt_hash` / `expected_tool_call_signature` / `candidate_row_sha`：generation-stage 已按真实配方逐行算，`hash_recomputed_by_pipeline=false`，controller normalization 后重算并重签。

## 不声称

generation-stage only。不声称 train-ready / candidate-ready / V-PASS / run-auth / 语义全过 / gated / judged。未训练、未改仓内代码、未改 quota、未绕 DataGate。

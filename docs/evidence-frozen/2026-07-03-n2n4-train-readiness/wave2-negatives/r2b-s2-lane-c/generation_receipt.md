# R2b S2 Batch1 Lane-C 生成 receipt (generation_receipt)

- artifact_kind: r2b_s2_lane_c_generation_receipt
- status: generated_generation_stage
- proof_class: local/pre_training_batch_generation_stage
- generator_source_vendor: anthropic
- generator_model_id: claude-opus-4-8
- generation_lane_id: r2b-s2-lane-c
- prompt_package: `wave2-negatives/batch-package/lane-prompt-package.md`（§S2 Batch1 Addendum lane-c 块 + 继承 S1 六条铁律）
- batch_order: `wave2-negatives/batch-package/r2b-s2-batch1-order.json`（lane-c 块，D-088 accepted）
- row_schema_contract: `N5-canary/BATCH-CONTRACT-rev2.md`（rev2.1_locked_aligned）
- mechanical_gates_ref: `wave2-negatives/batch-package/MECHANICAL-GATES-r2b-s1.md`（S2 沿用）
- contrastive_pair_spec: `W9-R2B-CONTRASTIVE-PAIR-SPEC.md`
- contract_ssot（grep 核对）: `/Users/wanglei/workspace/MAformac/contracts/semantic-function-contract.jsonl`（3990 行，逐 device 抽取 intent/slot_keys/value）
- 工具 schema 来源: 复用 S1 lane-a + lane-b 已过机械门的 D-domain 工具定义（173 个 verbatim；description 常量 "D-domain vehicle-control tool (intent==tool name) derived from semantic contract."）；未新造工具、未伪造 query 工具

## 数据面口径

- 行数: 75 / 目标 75（ac=30, screen=30, window=15）
- class_totals: positive 38 / query 15 / refusal 4 / already_state 6 / unsupported 7 / followup 5（逐字对齐 order.json lane-c class_quota）
- 生成格式: 自然中文 user + system + assistant(`<tool_call>` 包裹 / `NO_TOOL`)；**全部自然中文**，无 `device=`/`primitive=`/`action=`/`slots=`/JSON/协议片段（RER-6 clean），无协议 seed 行
- hash 配方（对齐 live code + 逆向 S1 lane-a 复现，0 mismatch/75 行）:
  - `prompt_hash = sha256(input_zh utf8)`
  - `expected_tool_call_signature = sha256(stripped assistant render utf8)`；no-call 行 = `sha256("NO_TOOL")`
  - renderToolCall = `<tool_call>{"name":NAME,"arguments":ARGS}</tool_call>`
  - `tool_schema_digest = sha256(compact-sorted tools json)`
  - `candidate_row_sha = sha256(compact-sorted row 去 candidate_row_sha)`
- hash_recomputed_by_pipeline = false（generation-stage）；controller 注入 recipe_manifest_sha/quota_config_sha 后必须重算 candidate_row_sha + 刷新 SHA256SUMS.txt
- main_pin_sha = PENDING_COMMANDER_MAIN_PIN_N5E006；recipe_manifest_sha/quota_config_sha = generation-stage placeholder（controller 权威注入）

## Mandatory-First: set_interface_vs_defog（lane-c 首位铁律）

- **fresh pair groups: 4（sivd_1..sivd_4），要求 ≥4，达标**
- 排位: lane-c **前 8 行**（sample_id r2b-s2-c-001..008），先于任何其他 family
- `mandatory_first_order_index_for_set_interface_vs_defog` = 1..8（逐行递增）
- `s2_carry_tag = S2_CARRY`；`tool_pair_floor_id = set_interface_vs_defog`
- near-parallel: 每组仅 device referent（空调设置界面 vs 除雾模式）单一 cue 变化，polarity 组内持恒，无 slots，长度类持恒；numeric_value_constant=n/a（无数值）
- lane-d 承接 ≥3 additional fresh pair groups → full750 target ≥8

## Screen 高优先 floor（batch1 起）

- `screen_little_vs_number`: 1 fresh pair group（scr_lvn_1）；lane-d 补齐 → batch1 cumulative ≥2
- `screen_gear_min_max_vs_number`: 1 fresh pair group（scr_gmn_1）；lane-d 补齐 → batch1 cumulative ≥2

## Window F1 numeric-constancy 修复（window_repair_after_F1）

- **2 fresh pair groups（wrf1_1, wrf1_2），要求 ≥2，达标**
- wrf1_1（target-vs-delta）: 车窗升到四挡(open_window_to_number value=4) ↔ 车窗往上升四挡(open_window_by_number value=4)；**数值 4 两侧持恒**，仅 absolute-vs-delta cue 变；numeric_value_constant=true
- wrf1_2（polarity）: 车窗降到两挡(close_window_to_number value=2) ↔ 车窗升到两挡(open_window_to_number value=2)；**数值 2 两侧持恒**，仅 polarity cue 变；numeric_value_constant=true
- F1 教训执行: 无任何 pair 同时改 polarity + 数值；值型 pair 数值仅在"数值本身即被测线索"时才变（screen little-vs-number / gear-vs-number）

## D-087 query 边界（R2B-QUERY-RECLASS-01）

- **query 行仅 ac 族**: query_ac_temperature 8 行 + query_ac_windspeed 7 行 = 15（对齐 lane-c query_bucket_quota 8/7）
- **screen/window 无 C1 query intent**: query 式话术全部 = `unsupported` + `NO_TOOL` + `no_call.reason=no_available_query_tool` + `target_tool_present=false`
  - screen query-style reclass 行: r2b-s2-c-055, r2b-s2-c-056（`query_reclass_reason_for_unsupported_query_style` 已标）
  - window query-style reclass 行: r2b-s2-c-073
- **伪造 query_screen_* / query_window_* expected 工具数 = 0**（D-087 hard fail 项，零命中）

## 自检门结果（tools/run_lane_gates.py 权威 orchestrator，实跑）

| gate | 结果 |
|---|---|
| pair_ledger_check | **pass**（pair_rows 16 / complete 16 / groups 8 / incomplete 0 / failures 0，pair_completeness 100%）|
| query_shape_audit | **pass**（query_rows 15 / query_tool_call 15 / no_call 17 / failures 0）|
| supervision_consistency_scanner (--fail-on-contradiction) | **pass_no_contradictions**（contradiction_groups 0 / rows 0；mount_order pass）|
| density_report | **pass** |
| class_ratio_report | fail(rc2) → **D-087 waived_not_blocking**（见下）|

- candidate_row_sha / prompt_hash / expected_tool_call_signature / tool_schema_digest 逐行自验重算 = **0 mismatch / 75**
- ledger 75 行，逐行 sample_id 唯一，candidate_row_sha 与候选行一致（0 mismatch）

## Stopped / Waived / Deviation 项（如实报，不填充）

1. **no-call 占比 28.33%（17/60，train-pack cap 20%）→ class_ratio_report fail，D-087 / R2B-QUERY-RECLASS-01 豁免**：20% cap 是 train-pack 门非候选池门；候选池允许超采（`candidate_pool_oversample_allowed_train_pack_downsample_required`，对齐 order.json batch1_self_check_targets），%45 组装器训练前下采样。如实标，不算假绿。run_lane_gates class_ratio_waiver 命中 decision_ledger_ref=D-087 + commander_ref=R2B-QUERY-RECLASS-01。
2. **screen/window query-style → unsupported 改判 3 行（D-087 已授已记账）**：screen/window 契约无 readonly query_* 工具（cite-verify 一手 contract），query 式话术改判 unsupported + NO_TOOL + no_available_query_tool + target_tool_present=false；绝不伪造 query 工具。
3. **main_pin_sha = PENDING_COMMANDER_MAIN_PIN_N5E006**：N5E-006 pending_leige，controller 注入真实 pin 后重算 candidate_row_sha。
4. **recipe_manifest_sha / quota_config_sha = generation-stage placeholder**：controller 权威注入（Gate7RecipeQuotaConfig 派生）后重算 candidate_row_sha + 刷新 SHA256SUMS.txt；hash_recomputed_by_pipeline 翻 true。

无以下 Stop Condition 命中: query 渲染成 action(0) / no-call 缺 no_call metadata(0) / near-parallel 只靠 style 改写(0) / mounted surface 缺声称 shape(0) / 契约缺失字段被填充(0) / generation_blocked_*(0)。

## Non-Claims

- 不 train-ready / 不 candidate-ready / 不 V-PASS / 不 run-authorized
- class_ratio 豁免不使批次 train-ready
- 语义维 D1/D2/D3/D4/D8 + R2B_NEAR_PARALLEL + R2B_F1_NUMERIC_CONSTANCY 仍由 OpenAI-family judge 抽样裁决（本 receipt 不声称语义全过）

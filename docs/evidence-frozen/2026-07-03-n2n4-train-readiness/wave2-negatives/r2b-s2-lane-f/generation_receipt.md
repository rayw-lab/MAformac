# R2b S2 Batch2 lane-f Generation Receipt

status: generated_pending_controller_gates
artifact_kind: lane_generation_receipt
proof_class: local/pre_training_batch_candidate
created_by: r2b-s2-lane-f (Anthropic generation lane)
created_at: 2026-07-04

## 1. Lane 身份

| field | value |
|---|---|
| `batch_id` | `r2b-s2-batch2` |
| `batch_type` | `negative_repair_controlled_repair_s2_batch2` |
| `lane_id` | `r2b-s2-lane-f` |
| `state_machine_state` | `generated`（等 controller SHA 注入 + 机械门 + judge）|
| `target_count` | 75（实产 75）|
| families | `atmosphere_lamp=30`, `volume=30`, `wiper=15` |
| `generator_source_vendor` | `anthropic` |
| `generator_model_id` | `claude-opus-4-8` |
| `judge_source_vendor_required` | `openai`（跨厂商，异源）|

## 2. Prompt package / SSOT 溯源

- 合同：`wave2-negatives/batch-package/lane-prompt-package.md`（S1 铁律 + S2 Batch1 delta + §S2 Batch2 Addendum: lane-e/lane-f）
- 批 order：`wave2-negatives/batch-package/r2b-s2-batch2-order.json`（lane-f 块，D-088 accepted full750）
- 机械门：`wave2-negatives/batch-package/MECHANICAL-GATES-r2b-s1.md`
- 批合同：`N5-canary/BATCH-CONTRACT-rev2.md`
- 对比对 spec：`W9-R2B-CONTRASTIVE-PAIR-SPEC.md`
- 契约 SSOT：`/Users/wanglei/workspace/MAformac/contracts/semantic-function-contract.jsonl`
- 行格式黄金样例：`wave2-negatives/r2b-s2-lane-d/candidates.jsonl`（批1 已全 PASS 的 S2 字段面）

## 3. 工具面（D-domain 具名工具，intent==tool name）

工具 schema **不自造**：从权威 D-domain 目录 `F044-shorttrain-eval-prep/generated/D_domain.tools.demo.json`（562 工具，derived from semantic contract）按 family 的 semantic-group 抽取，并剥离 `_domain/_ir/_sg` 包裹键，保持与 lane-c/d 完全一致的 `{"function":..,"type":"function"}` 形态。抽取脚本 `_scratch/extract_tool_schemas.py` → `_scratch/lane-f-tool-schemas.json`（44 工具）。

- atmosphere_lamp semantic-groups：`atmosphere_lamp` / `_brightness` / `_change_speed` / `_color` / `_mode`
- volume semantic-groups：`volume` / `current_volume`(query_current_volume) / `volume_mute` / `volume_unmute`
- wiper semantic-groups：`wiper` / `wiper_speed` / `wiper_mode` / `the_rain_sensor` / `wiper_wash`

## 4. 生成方式（确定性 + 分段 flush）

- 脚本化确定性生成，`_scratch/gen_lane_f.py`；可重跑，同输入 100% 同输出。
- **Permanent Stream-Flush Discipline（batch2 起常设）**：15 行一段，按 family 块对齐 → 5 段（atmos 15+15 / volume 15+15 / wiper 15）。
- 每段先落 `_segments/candidates.segment-0N.jsonl` + `value_change_ledger.segment-0N.jsonl` + `segment_manifest-0N.json` + 累积 `segment_SHA256SUMS.txt`，再由确定性 merge 校验（sample_id 唯一 / 行数 / ledger parity / hash 存在 / candidate_row_sha parity）后合并为最终 `candidates.jsonl` / `value_change_ledger.jsonl`。中断可从最后一段 manifest 恢复。

## 5. Hash / 签名字段（generation-stage 值；controller 重算）

本 lane 按黄金 recipe 生成 generation-stage 派生字段：
- `prompt_hash = sha256(input_zh)`
- `expected_tool_call_signature = sha256("<tool_call>{...}</tool_call>")` 或 `sha256("NO_TOOL")`
- `tool_schema_digest = sha256(compact-json(tools))`
- `candidate_row_sha = sha256(compact-json(core-subset))`（own recipe）
- `hash_recomputed_by_pipeline=false`（等 controller/prepare 管道按真实配方逐行重算）
- `recipe_manifest_sha` / `quota_config_sha` / `main_pin_sha` = `PENDING_*`（controller 注入）
- `hash_recipe_ref` 指向 `C5DerivedHashRecipe.promptHash / .expectedToolCallSignature / C6Hash.sha256Hex`

**controller 注入 `recipe_manifest_sha` / `quota_config_sha` 后必须重算 `candidate_row_sha` 并刷新 ledger + SHA256SUMS。**

## 6. D-087 query 边界

- 仅 `volume` 有 query 行：`query_current_volume` **12 行**（lane-f 配额）。
- `atmosphere_lamp` / `wiper` **无 C1 query intent**：query-式话术一律 `unsupported` + `NO_TOOL` + `no_call.reason=no_available_query_tool` + `target_tool_present=false` + `deviation_ref=D-087`。命中：`r2b-s2-f-026`（氛围灯现在是什么颜色来着）、`r2b-s2-f-073`（雨刮现在开到几档了）。
- 全 lane **未挂载/未 expect** 任何非 `query_current_volume` 的 `query_*` 工具。

## 7. R2B-NVC-01（值型对结构化字段）

按 floor 分派 `numeric_value_constant`（floor-based，镜像 lane-d NVC_EXPECT）：
- `atmos_little_vs_number` / `atmos_gear_min_max_vs_number` → `value_is_cue`（数字有无本身是判别 cue）
- `volume_relative_vs_absolute` / `wiper_relative_vs_absolute` → `true`（可见数值跨对保持恒定，判别 cue 仅相对/绝对）
- `volume_query_current_vs_adjust` → **行为边界对（查询 vs 动作），非值型**，不带 `numeric_value_constant` 字段（与 lane-d 的 set_interface_vs_defog 处理一致）

F1 教训遵守：所有 `true` 型对（vra/wra）跨对 mate 可见数值恒定（3=3 / 5=5 / 2=2 / 1=1 / 2=2），单 cue = 相对(by,ref=CUR) vs 绝对(to,ref=ZERO)；`near_parallel_evidence` 显式写 `numeric_value_constant=true`。

## 8. Stopped / Waived items

- **Stopped rows**：0。无 query-需-渲染成动作、无 no-call-缺 metadata、无近平行需靠 style-rewrite、无挂载面缺声称形态、无缺 controller 授权字段的情形。
- **Waived**：`refusal_no_call_envelope_status = waiver_required`（见 §9）——这是 **candidate 池**的观察值，非 lane 阻断；order `batch_self_check.candidate_no_call_ratio_note` 明示 candidate 池可超 20%，由 assembler 下采样/分层或 commander waiver 处理。**本 lane 不做训练授权、不做 train-pack 比例声称。**

## 9. no-call envelope（candidate 级观察）

```
candidate_no_call_rows        = 16   (refusal 4 + already_state 6 + unsupported 6)
candidate_query_tool_call_rows= 12
candidate_no_call_ratio(excl query) = 16/63 = 0.2540
projected_train_refusal_no_call_ratio = TBD by assembler downsample/stratify
refusal_no_call_envelope_status = waiver_required   # candidate-pool only, not a lane block
```

## 10. 声称纪律

本 receipt 只声称：lane-f 已生成 75 候选行 + 六件套 + 通过 lane 自审机械门（`_scratch/audit_lane_f.py` = ALL_GATES_PASS）。**不声称** gate-pass（controller 未跑）、judge-pass、train-ready、candidate-ready、V-PASS、run-auth。半语义门（D1-D4/D8/R2B_NEAR_PARALLEL）留跨厂商 OpenAI judge 抽样。

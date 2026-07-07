# R2b S1 Lane A 生成 receipt (generation_receipt)

- artifact_kind: r2b_s1_lane_a_generation_receipt
- status: generated_generation_stage
- proof_class: local/pre_training_batch_generation_stage
- generator_source_vendor: anthropic
- generator_model_id: claude-opus-4-8
- generation_lane_id: r2b-s1-lane-a
- prompt_package: `wave2-negatives/batch-package/lane-prompt-package.md` (Lane A block)
- batch_order: `wave2-negatives/batch-package/r2b-s1-batch-order.json`
- row_schema_contract: `N5-canary/BATCH-CONTRACT-rev2.md` (rev2.1_locked_aligned)
- mechanical_gates_ref: `wave2-negatives/batch-package/MECHANICAL-GATES-r2b-s1.md`
- contrastive_pair_spec: `W9-R2B-CONTRASTIVE-PAIR-SPEC.md`
- contract_ssot (grep 核对): `/Users/wanglei/workspace/MAformac/contracts/semantic-function-contract.jsonl` (3990 行)
- 工具 schema 来源: 真实 corpus D-domain 契约渲染 (`F044-shorttrain-data-ready/samples/c5-training-samples.jsonl` 的 tools 全集逐 verbatim 复用；description 常量 "D-domain vehicle-control tool (intent==tool name) derived from semantic contract.")

## 数据面口径

- 行数: 75 / 目标 75
- 生成格式: 自然中文 user + system + assistant(tool_call 包裹 / NO_TOOL)；**未产出协议 seed 行**（全部自然中文，RER-6 clean，避免协议片段泄漏）
- hash 配方 (对齐 live code `Core/Training/C5LoRATraining.swift`):
  - prompt_hash = C6Hash.sha256Hex(utterance.utf8)  (utterance = user message content)
  - expected_tool_call_signature = C6Hash.sha256Hex(renderedToolCall.utf8) ；no-call 行 = sha256("NO_TOOL")
  - renderToolCall = `<tool_call>{"name":NAME,"arguments":ARGS}</tool_call>`，ARGS 用 C5 canonical JSON（arg 键排序）
  - candidate_row_sha = generation-stage provisional（over 授权 core 字段），**controller 注入 recipe_manifest_sha/quota_config_sha 后必须重算**
- hash_recomputed_by_pipeline = false（generation-stage；交 controller 重算翻 true）

## Stopped / Waived / Deviation 项 (如实报，不填充)

1. **query→unsupported 改判 8 行 (commander waiver R2B-QUERY-RECLASS-01 / D-087 已授已记账)**：seat/window/door/atmosphere_lamp 契约无 readonly query 工具（cite-verify 一手 contract）。授权 `WAVE2-GENERATOR-HARDENING.md#3.1`。改判行: r2b-s1-a-025, r2b-s1-a-026, r2b-s1-a-040, r2b-s1-a-041, r2b-s1-a-055, r2b-s1-a-056, r2b-s1-a-070, r2b-s1-a-071。每行标 intended_class=query + reclass_authority。绝不伪造 query 工具（target_tool_present=false）。ac 2 query 槽 = query_ac_temperature(MP-029 病例保护性正例) + query_ac_windspeed 各 1（commander 指定）。commander 新事实收录：door 族无通用车门工具（仅 tailgate/fuel_tank_cap/window_lock），unsupported query 话术按实际工具面写。
2. 🔴 **set_interface_vs_defog 第二 near-neighbor pair = MANDATORY_FIRST_IN_NEXT_BATCH (S2/full-750 强制首位，不得再 carry)**：commander 收稿意见——它是 A 轴残余 + B 轴全部失败的头号 cluster，S1 仅 got1/req2，第二 pair **必须** S2 首位补齐，禁止再顺延。ac 9-positive 预算被 cooling(4)+heating(2)+defog(2)+set_interface(1)+adjust 超订致 S1 只出 1 pair。
   - `set_interface_vs_defog_second_pair.mandatory_first_in_next_batch: true`
   - `set_interface_vs_defog_second_pair.carryable_again: false`
3. **ac_heating_open_close / defog_open_close 第二 pair group 顺延 S2**：与 batch-order `s2_floor_carry_forward_required` 一致。
4. **no-call 占比 31.5% (train-pack cap 20%) → status=candidate_pool_oversample_downsampled_pretrain**：commander R2B-QUERY-RECLASS-01 确认 20% cap 是 train-pack 门非候选池门；候选池允许超采，%45 组装器训练前下采样。如实标，不算假绿。
5. **main_pin_sha = PENDING_COMMANDER_MAIN_PIN_N5E006**：N5E-006 pending_leige，controller 注入真实 pin。

无以下 Stop Condition 命中: query 渲染成 action(0) / no-call 缺 no_call metadata(0) / near-parallel 只靠 style 改写(0) / mounted surface 缺声称 shape(0，改判已处理) / 契约缺失字段被填充(0)。

## 高危 floor 覆盖

| floor | required | delivered | status |
|---|--:|--:|---|
| ac_cooling_open_close | 2 | 2 | MET |
| ac_heating_open_close | 1 | 1 | MET |
| defog_open_close | 1 | 1 | MET |
| set_interface_vs_defog | 2 | 1 | PARTIAL_S2_CARRY |
| query_ac_temperature_vs_adjust | 2 | 2 | MET |
| window_to_number_open_close | 1 | 1 | MET |
| window_by_number_open_close | 1 | 1 | MET |
| window_little_open_close | 1 | 1 | MET |
| window_simple_open_close | 1 | 1 | MET |
| atmos_little_vs_number | 3 | 3 | MET |
| atmos_gear_min_max_vs_number | 3 | 3 | MET |

## 交付物 (6 件)

- candidates.jsonl (75 行)
- value_change_ledger.jsonl (75 行)
- batch_manifest.json
- batch_self_audit.md
- generation_receipt.md
- SHA256SUMS.txt

## 非声称

not train-ready / not candidate-ready / not V-PASS / not run-auth。派生 hash 为 generation-stage provisional，须 controller 重算。生成方仅出候选数据与硬产出，不训练、不改仓内代码、不改 quota SSOT、不绕 DataGate。

# R2b S2 Batch3 lane-h Generation Receipt

- batch_id: `r2b-s2-batch3`
- batch_type: `negative_repair_controlled_repair_s2_batch3`
- lane_id: `r2b-s2-lane-h`
- generator_source_vendor: **anthropic**
- generator_model_id: **claude-opus-4-8**
- generation mode: scripted deterministic + segmented flush (`_scratch/gen_lane_h.py`)
- proof_class: local/pre_training_batch_candidate
- created_at: 2026-07-04

## 1. Authority / SSOT Inputs (照做,非参考)

| input | path |
|---|---|
| lane prompt package | `wave2-negatives/batch-package/lane-prompt-package.md#S2-Batch3-Addendum-lane-g-lane-h`（lane-h 合同逐字执行） |
| batch order | `wave2-negatives/batch-package/r2b-s2-batch3-order.json#lanes[r2b-s2-lane-h]` |
| mechanical gates | `wave2-negatives/batch-package/MECHANICAL-GATES-r2b-s1.md` |
| batch contract | `N5-canary/BATCH-CONTRACT-rev2.md` |
| contrastive pair spec | `W9-R2B-CONTRASTIVE-PAIR-SPEC.md` |
| recipe rev3 §2 | `W10-R2B-RECIPE-REV3.md#section-2` |
| golden format reference | `wave2-negatives/r2b-s2-lane-f/candidates.jsonl`（批2已收稿全绿黄金样例） |
| **tool surface source (authoritative, NOT self-forged)** | `F044-shorttrain-eval-prep/generated/D_domain.tools.demo.json`（562-tool D-domain catalog, intent==tool name） |
| contract SSOT | `/Users/wanglei/workspace/MAformac/contracts/semantic-function-contract.jsonl` |

## 2. Deterministic Pipeline

1. `_scratch/extract_tool_schemas_h.py` — 从权威 D-domain catalog 抽 seat+door 全部 139 工具 schema（剥 `_domain/_ir/_sg` wrapper，得 `{"function":..,"type":"function"}`），写 `_scratch/lane-h-tool-schemas.json`。**工具 schema 未自造，逐字节等于 catalog。**
2. `_scratch/gen_lane_h.py` — 75 条显式 spec（seat 45 / door 30）→ 分段 flush（5 × 15 行,对齐 family block）→ 段清单 + 段 SHA → 确定性合并（校验 sample_id 唯一/ledger 对齐/派生 hash 非空/candidate_row_sha 对齐）→ `candidates.jsonl` + `value_change_ledger.jsonl`。
3. `_scratch/audit_lane_h.py` — fail-closed 机械自审（镜像 MECHANICAL-GATES + batch3 order + Addendum）→ **ALL_GATES_PASS**。
4. 独立对抗核验（cross-check）：mounted 工具逐字节等于 catalog；pair mate 共享同一 mounted 面；target 均在 mounted 面且为 catalog 工具；no_call `target_tool_present` 语义正确；独立 position-lexeme 复扫；零重复 input_zh。→ **零真实缺陷**（distractor_tool_ids 顺序差异=seeded_shuffle 重排,set 成员一致,与黄金 lane-f 同款）。
5. `_scratch/finalize.py` — batch_manifest.json + SHA256SUMS.txt。

## 3. Hash Recipes (mirror lane-f)

```text
prompt_hash                  = sha256(input_zh)
expected_tool_call_signature = sha256("<tool_call>{...compact...}</tool_call>") | sha256("NO_TOOL")
tool_schema_digest           = sha256(compact-json(mounted tools))
source_template_sha          = sha256(template_sample_id)
candidate_row_sha            = sha256(compact-json(core-subset))
hash_recomputed_by_pipeline  = false   # controller/prepare pipeline recomputes per real repo recipe
hash_recipe_ref              = repo:Core/Training/C5LoRATraining.swift#C5DerivedHashRecipe.promptHash(utterance:);
                               repo:Core/Training/C5LoRATraining.swift#C5DerivedHashRecipe.expectedToolCallSignature(renderedToolCall:);
                               repo:Core/Bench/C6VehicleToolBench.swift#C6Hash.sha256Hex
```

派生 hash 由本 lane 按上述配方自算并写入；controller/prepare 管道在注入 `main_pin_sha`/`recipe_manifest_sha`/`quota_config_sha` 后须重算并刷新 `candidate_row_sha` + `SHA256SUMS.txt`（`hash_recomputed_by_pipeline` 现为 false）。

## 4. Delivered Composition

- rows: 75（seat 45 + door 30）
- class totals: positive 51 / query 0 / refusal 5 / already_state 7 / unsupported 7 / followup 5
- pair groups: 12（seat 6 + door 6）,paired rows 24
- pair floors: seat_heat/vent/posture query_style_and_already_state ×1 each,seat_default_scope_position ×3,door_query_style_unsupported ×3,door_lock_open_confusion_negative ×3
- D-087 query-style reclass rows: 6（seat h-001/003/005 + door h-046/048/050）
- R2B-NVC-01 `numeric_value_constant=true` rows: 6（seat_default_scope_position 三 pair 各 2 mate）

## 5. Contract Fact Reconciliation (door open/lock)

lane-a S1 note「door 族无通用车门工具、主驾车门打开=unsupported」与 batch3 order（door 需 20 positive）+ D-domain catalog（含 `open_car_door`/`close_car_door`/`lock_door`/`unlock_door`/`open_door_little`/`open_tailgate`/`open_fuel_tank_cap` 等 action 工具）冲突。分诊为**事实型**并 cite-verify 到一手：
- C1 契约 `semantic-function-contract.jsonl` 含 `car_door open_car_door`(power_on)、`door lock_door/unlock_door`、`door open_door_little/open_door_by_number`。
- 权威 tool surface = D-domain catalog，`open_car_door`/`lock_door`/`unlock_door` 均在其中（本 receipt 独立核验 present=True）。
- batch3 order lane-h door 配额需 20 positive，且 `door_lock_open_confusion_negative` 明确以 lock-vs-open 为 boundary → order（D-088 accepted）SSOT 认定 door 有 open/lock action 工具。
- 结论：door positive 使用 catalog 的 door action 工具；lane-a note 视为其特定窄 subset 语境下的读数，不适用于 lane-h 的授权 tool surface。judge 逐行按 mounted tool surface 评判，`open_car_door` 在这些行的 mounted 面内 → 语义正确。

## 6. Stop Conditions

- 无停行。无 `generation_blocked_bad_chinese`（所有 refusal/already_state/unsupported 均为自然中文 + `NO_TOOL`,无协议碎片 device=/primitive=/action=/slots=）。
- 无 `generation_blocked_*`。无因缺 controller authority 无法填的字段（controller-injected 字段留 PENDING 占位）。
- 无伪造 query 工具；seat/door query-style 全改判 unsupported（D-087）。

## 7. Waived / Pending

- `refusal_no_call_envelope_status=waiver_required`：候选池 no-call ratio=0.2533>0.20（与 order batch_self_check 一致）。这是候选池比例,assembler 训练前须下采样/分层或取 commander waiver;**非 lane block,非 train-pack 声称**。
- controller-injected 字段占位：`main_pin_sha=PENDING_COMMANDER_MAIN_PIN_N5E006`、`recipe_manifest_sha`/`quota_config_sha`=PENDING_CONTROLLER_*_S2_BATCH3；`hash_recomputed_by_pipeline=false`。

## 8. Non-Claims

not gate-passed by controller · not judge-passed（OpenAI-family judge 未在本 lane 跑）· not train-ready · not candidate-ready · not V-PASS · not run-authorized。本 lane 仅生成候选数据 + 生成方硬产出 + 生成方自审留痕。

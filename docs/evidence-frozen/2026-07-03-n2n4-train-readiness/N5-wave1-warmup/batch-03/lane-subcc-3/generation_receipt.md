# generation_receipt — warmup-batch-03 / lane subcc-3 (Anthropic 生成 lane)

- batch_id `warmup-batch-03` type `standard_generation` lane `subcc-3`/Anthropic
- generator_source_vendor `anthropic` model `claude-opus`; judge 必 `openai` (跨厂商)
- main_pin_sha `b33d8eba152e5326f69bbe85fc356b73419ee9c3`; quota_source `intent_bug_scene_recovery` (Gate7RecipeQuotaConfig.wave1ConstructionAnchors, manual_override=false)
- proof_class local/pre_training_batch; claim: 生成方机械自检 only, NOT judged / train-ready / V-PASS / candidate-ready / run-auth

## 组成统计
| 项 | 值 |
|---|---|
| 总行数 | 50 |
| window (车窗 scene.scene3 mounted 8) | 25 |
| door (车门 single_group door mounted 48) | 25 |
| value_changed false / true | 33 / 17 |
| multi_call_pairing | 0 (WAIVED) |
| refusal 行 | 0 |
| value_type 分布 | {"STATE": 31, "PERCENT": 13, "EXP": 6} |

## 工具分布
{
  "open_window": 3,
  "open_window_to_number": 4,
  "open_window_by_number": 3,
  "open_window_little": 3,
  "close_window": 3,
  "close_window_to_number": 3,
  "close_window_by_number": 3,
  "close_window_little": 3,
  "open_tailgate": 5,
  "close_tailgate": 5,
  "open_comfortable_entry_exit": 4,
  "close_comfortable_entry_exit": 4,
  "open_fuel_tank_cap": 4,
  "close_fuel_tank_cap": 3
}

## 极性表 (open/close 对称)
| family | open | close |
|---|---|---|
| window | 13 | 12 |
| door | 13 | 12 |
| 合计 | 26 | 24 |
- open_close_polarity floor ≥1/方向/family: 满足 (window 13/12, door 13/12)

## 长度带宽 (length_breadth)
- unique_lengths 13 (≥5 ✅); p90-p10 9.2 (≥6 ✅, min 3/max 17); non_empty_buckets 4 (≥3 ✅)
- severe near-dup(≥0.92)=0 (=0 ✅); warn(≥0.85)=0; max_ratio 0.833 (pair ['warmup-batch-03-subcc-3-0004', 'warmup-batch-03-subcc-3-0017'])
- 混合长短句 (含 3 字短 command + 十余字口语长句); 未人工填充/凑长度

## surface 溯源 (一手)
- window: subset_group `scene.scene3`, subset_policy `e2-lite-v1`, mounted 8, tool_schema_digest `a4f5625c1ed642459907f00f027278d88b5fa7a24d3b82191ffda8f4335d6354`
  - digest 源 = subset-policy-manifest entries[scene.scene3].tool_schema_digest, 且 = batch-order target_surface_seed.tool_schema_digest (双源确认)
  - tools 数组 = batch-03 dry-run gate7-wave1-candidates.jsonl row0.tools (逐位 = manifest tool_ids_ordered)
- door: subset_group `door` (single_group), subset_policy `e2-lite-v1`, mounted 48, tool_schema_digest `ec94daea9a84aa738bea894e7b772186591f901dc67abd2c535d0717f26f8e6f`
  - digest 源 = subset-policy-manifest entries[door single_group].tool_schema_digest
  - tools 数组 = c5-train-00089.tools (逐位 = manifest tool_ids_ordered, 48/48)
- subset_policy_digest `c72329fce65678a72d95319d618570469ce3149cb96a092fe59e9a6cc7c0c530` = grouping-contract 常量 (batch-order seed + dry-run + batch-01 三源一致); 未映射进 tool_schema_digest (禁止项)

## 派生 hash (repo 真实配方逐行重算, 非克隆)
- prompt_hash=sha256(input_zh) mismatch 0 / 唯一 50; expected_tool_call_signature=sha256(rendered_tool_call) mismatch 0
- 配方自证: 复刻 batch-03 dry-run seed (open_window 空 args) 的 rendered/prompt_hash/sig 全对齐
- hash_recipe_ref `repo:Core/Training/C5LoRATraining.swift#C5DerivedHashRecipe.promptHash(utterance:);repo:Core/Training/C5LoRATraining.swift#C5DerivedHashRecipe.expectedToolCallSignature(renderedToolCall:);repo:Core/Bench/C6VehicleToolBench.swift#C6Hash.sha256Hex`

## 红线合规声明
- 未读 raw/Downloads; 无 raw 客户语料 / PII / 车型代号 / 供应商车厂真名 / 报价成本 / 密钥 / http / 禁外传标记内容; 50 行全新合成中文
- raw_source_redacted / raw_text_absent 逐行 true; 仅写 batch-03/lane-subcc-3/; 未改 main_pin_sha; 未手写 quota

## Artifact SHA 绑定 (gate 前必录)
- candidates_jsonl `sha256:763b5a707e5b76404cae57b132aff700c64a243593ea3768d25ce1e941bcc892`
- value_change_ledger_jsonl `sha256:64b39938d5e71de99700f4fcbc502452b2a450c4dac448dcbce8c9ccfa40fb4a`
- batch_manifest_json `sha256:e742affa7a9f1e0ba88fd64cdfdf7397f4e77910658e0b02ceff5b7bf6a0fe31`
- batch_self_audit_md `sha256:e21b333113d501cb23c8b2472ddde3d5ec5c3c1b44c9c398ed14de6ec589d248`
- generation_receipt_md: 见 SHA256SUMS.txt (自指哈希写入后算)
- 6 文件完整 sha 见 SHA256SUMS.txt; post-hash 编辑作废须全门重跑

## Residual / 未达标如实
1. recipe_manifest_sha/quota_config_sha 已由 controller 行级注入闭环：recipe_manifest_sha=`sha256:c7fef12fd2d3462065cd8e626388a632cbb09a33c892d372210db4b055923adb`; quota_config_sha=`sha256:011387d640046b0a5a77d6cbb702cc81548c652cc9ad04149c7af8601bf1de23`; candidate_row_sha 与 ledger 已重算，权威见 `controller-sha-injection-receipt.json` 与 `SHA256SUMS.txt`。
2. **multi_call_pairing floor(2) WAIVED** — 管道单 call 渲染器 + 0/4500 多意图先例; reason=pipeline_single_call_renderer_no_multi_recipe; 恢复=D-062 dev 项落地后
3. **door slice 目标工具收窄** — 门家族 48-tool surface 中仅 tailgate/comfortable_entry_exit/fuel_tank_cap (6 工具) 在 c5-training 有 parent 模板; car_door/lock_door/central_lock/child_lock 无模板, 用作 template_sample_id 会撞 ledger parent-registry 硬门, 故未纳入 (surface 仍完整挂 48 工具, 目标工具是其子集); 如需更宽门覆盖需 controller 提供更宽 parent 模板 registry
4. near-dup 用 char-level SequenceMatcher 本地代理 (max 0.833<0.92); controller diversity script 口径为准
5. generator_model_id family-level `claude-opus` (未伪造精确版本串)

## 生成方法
- 生成器 `batch-03/lane-subcc-3/generate_batch.py` (确定性无随机; repo 配方逐行重算 + 全门 fail-closed 自检); surface_tools.json = window(8)/door(48) tools 数组 provenance helper (一手取自 dry-run + c5-train-00089)


## D3 position 槽补齐修复 (Anthropic fix lane, post-controller)
- 缺陷来源: OpenAI judge D3 抓语义缺陷 + commander 全量扫描定界 — 话术含位置词=调用目标, 但 expected args 漏 `position` 槽
- 修法: input_zh 语义判定位置词为调用目标 → args/expected_tool_calls 补 `position` 槽 (槽名/合法值照同批 sibling schema, 未臆造); value 不变, value_type 保留
- 派生同步(SSOT 复刻 generate_batch.py): rendered_tool_call/assistant_text/messages[2]/expected_tool_call_signature/candidate_parent_semantic_id/candidate_row_sha 全重算
- candidate_row_sha: 用 SSOT 公式 `sha256(json.dumps(row-crs, sort_keys=True, ensure_ascii=False, sep=(",",":")))` (generate_batch.py:232) 重算; 已在本批 50 未改动行 100% 复现现存 sha (=controller 注入后口径, 非自造)
- 逐行处置:
  - `warmup-batch-03-subcc-3-0012` | input_zh=`主驾窗户开小一点透透气` | tool=`open_window_little` | 改: `{"value":"LITTLE"}` → `{"value":"LITTLE","position":"主驾"}` | position=调用目标(是) | new candidate_row_sha `9a8859bc6da81a21d35d7b9bace0af4aba0c548109f61872e20c2563ecf32954`
  - `warmup-batch-03-subcc-3-0025` | input_zh=`后排窗户收一点点` | tool=`close_window_little` | 改: `{"value":"LITTLE"}` → `{"value":"LITTLE","position":"后排"}` | position=调用目标(是) | new candidate_row_sha `e086421e84222c715dbdcaa999cbd9d58f5e9e1c301b4c3c3a228aad0644939d`
- 修复后文件 sha (权威, 已写入 SHA256SUMS.txt):
  - candidates.jsonl `sha256:85f8067c5c040bad2bcf38f88b569b2c90c991f7aa09d6e9f5cb7abd59a0fa9b`
  - value_change_ledger.jsonl `sha256:8e92bf306eeeb68656565f7a91db10135e2a3471ad4b94e4de3b96788be3b01d`
- 下游级联已由本轮 GATES-RERUN 刷新：controller receipt、batch_manifest.artifact_shas、DataGate/diversity/C6 gates 均以 `B03-GATES-RECEIPT-v2` supersede 旧版；repair_event=`judge_D3_position_slot_omission_fix`。
- Artifact SHA 绑定已刷新：batch_manifest.artifact_shas 记录非自指内容 artifact；batch_manifest.json 自身最终字节 sha 以 `SHA256SUMS.txt` 为权威。

## GATES-RERUN closure
- repair_event: `judge_D3_position_slot_omission_fix`
- fixed_sample_ids: `warmup-batch-03-subcc-3-0012`, `warmup-batch-03-subcc-3-0025`
- controller_receipt: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-03/lane-subcc-3/controller-sha-injection-receipt.json`
- gates_receipt: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-03/lane-subcc-3/gates/B03-GATES-RECEIPT-v2.md`
- supersedes: previous B03 gate receipts for this repair lane

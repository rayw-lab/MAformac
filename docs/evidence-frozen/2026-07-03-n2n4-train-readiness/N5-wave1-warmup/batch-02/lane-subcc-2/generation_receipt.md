# generation_receipt — warmup-batch-02 / lane subcc-2 (Anthropic 生成 lane)

- batch_id `warmup-batch-02` type `standard_generation` lane `subcc-2`/Anthropic
- generator_source_vendor `anthropic` model `claude-opus`; judge 必 `openai` (跨厂商)
- main_pin_sha `b33d8eba152e5326f69bbe85fc356b73419ee9c3`; quota_source `intent_bug_scene_recovery` (Gate7RecipeQuotaConfig.wave1ConstructionAnchors, manual_override=false)
- proof_class local/pre_training_batch; claim: 机械自检 only, NOT judged/train-ready/V-PASS/run-auth

## 组成 (座椅族 3 slice, 50 行纯单 call)
| slice | 行数 | subset_group (mounted) |
|---|---|---|
| seat_heat | 17 | seat.heat (23) |
| seat_ventilation | 17 | seat.ventilation (13) |
| seat_posture | 16 | seat.posture_base_leg (25) + seat.posture_back_head (20) |
| value_changed false / true | 35 / 15 | in-range 值多样化 + 部位/位置 scope, 均 enum 合法 |
| 极性 open / close | 5 / 5 (对称) | open/close seat_heat·heat_mode·ventilation·ventilation_mode·leg_support |
| refusal | 0 | refusal_zero_lock |
| multi_call | 0 (WAIVED) | pipeline_single_call_renderer_no_multi_recipe |

## Surface / digest / meta (SSOT 真值)
- subset_policy_id `e2-lite-v1`; subset_policy_digest `c72329fce65678a72d95319d618570469ce3149cb96a092fe59e9a6cc7c0c530` (grouping_contract_digest 常量)
- tool_schema_digest **逐 subset_group 取 manifest entries[].tool_schema_digest** (≠ subset_policy_digest, batch-01 血泪 patch):
  - seat.heat `f3622f75cb1fd25c0c143226a60f60a3bc6b0dcb6f49651575cdb7942385bbf3`
  - seat.ventilation `fa080432ceb1c6ec5e6fc202a9e1243007ffa6dafb094a080ed6d4f7a8001b60`
  - seat.posture_base_leg `f193a931dac853b24d4b017b7648c01ec7f8186cc6b9327c21e5f3e0cadb1b20`
  - seat.posture_back_head `151fccab52888b688ace3e63ca3264982974de267ba19c8466b48e411b3a86db`
- tools 数组按 manifest tool_ids_ordered 从 D_domain catalog(sha 22613d49… 核对)构建, 与 digest 同源

## 派生 hash (repo 真实配方逐行重算, 非克隆)
- prompt_hash=sha256(input_zh) mismatch 0 唯一 50; sig=sha256(rendered_tool_call) mismatch 0
- 自检复现 batch-02 dry seed (raise_seat_heat_temperature_by_number): prompt_hash/sig/render 全 True
- hash_recipe_ref `repo:Core/Training/C5LoRATraining.swift#C5DerivedHashRecipe.promptHash(utterance:);repo:Core/Training/C5LoRATraining.swift#C5DerivedHashRecipe.expectedToolCallSignature(renderedToolCall:);repo:Core/Bench/C6VehicleToolBench.swift#C6Hash.sha256Hex`

## 长度带宽
- unique_lengths 12 (≥5✅); p90-p10 6.1 (≥6✅, min 4/max 16); buckets 4 (≥3✅)
- severe near-dup(≥0.92)=0 (=0✅); warn(≥0.85)=0; max_ratio 0.842 (pair ['warmup-batch-02-subcc-2-0020', 'warmup-batch-02-subcc-2-0022'])

## 红线合规声明
- 未读 raw/Downloads; 无 PII/车型代号/供应商车厂真名/报价/http/禁外传; 50 行全新合成中文; raw_source_redacted/raw_text_absent 逐行 true
- 仅写 lane-subcc-2/; 未改 main_pin_sha; 未手写 quota

## Artifact SHA 绑定 (gate 前必录)
- candidates_jsonl `sha256:d7a752e4c74c69c341d1a88dee9d8edd77220c57e6424367fb479dfa6d79038a`
- value_change_ledger_jsonl `sha256:3883e49d7c148a4fb1b4a45d6d79c3be160d1ba5bbaf94aede9bf95ed3b775fb`
- batch_manifest_json `sha256:a35e852f63d8a40ed093196aa741eb59e4bd43dc25baea9b2e94b5ccb12593af`
- batch_self_audit_md `sha256:49b594651cb93045fc368c8997d32a77ed85b001bd40c6c3419d985d73aade6d`
- generation_receipt_md: 见 SHA256SUMS.txt (自指哈希写入后算)
- 6 文件完整 sha 见 SHA256SUMS.txt; post-hash 编辑作废须全门重跑

## Residual / 未达标如实
1. recipe_manifest_sha/quota_config_sha 已由 controller 行级注入闭环：recipe_manifest_sha=`sha256:1f03268d8520404e0420d3e1f19a34386ac5ee5ae1191152c9286a571c106d1d`; quota_config_sha=`sha256:011387d640046b0a5a77d6cbb702cc81548c652cc9ad04149c7af8601bf1de23`; candidate_row_sha 与 ledger 已重算，权威见 `controller-sha-injection-receipt.json` 与 `SHA256SUMS.txt`。
2. **belt 加热 deferred**: seat_belt_heat* 工具 PR31 registry 无 parent template; seat_heat slice 用 seat_heat_temperature 工具全覆盖
3. **multi_call_pairing floor(2) WAIVED** — 管道单 call 渲染器 + 0/4500 先例; 恢复于 multi-call 支持落地后
4. near-dup 用 char-level SequenceMatcher 本地代理 (max 0.842<0.92); controller diversity script 口径为准
5. generator_model_id family-level `claude-opus` (未伪造精确版本串)

## 生成方法
- 生成器 `lane-subcc-2/generate_batch.py` (确定性无随机; SSOT=manifest+catalog+PR31 registry; repo 配方重算 + 全门 fail-closed 自检); 单次运行 <3s


## D3 position 槽补齐修复 (Anthropic fix lane, post-controller)
- 缺陷来源: OpenAI judge D3 抓语义缺陷 + commander 全量扫描定界 — 话术含位置词=调用目标, 但 expected args 漏 `position` 槽
- 修法: input_zh 语义判定位置词为调用目标 → args/expected_tool_calls 补 `position` 槽 (槽名/合法值照同批 sibling schema, 未臆造); value 不变, value_type 保留
- 派生同步(SSOT 复刻 generate_batch.py): rendered_tool_call/assistant_text/messages[2]/expected_tool_call_signature/candidate_parent_semantic_id/candidate_row_sha 全重算
- candidate_row_sha: 用 SSOT 公式 `sha256(json.dumps(row-crs, sort_keys=True, ensure_ascii=False, sep=(",",":")))` (generate_batch.py:232) 重算; 已在本批 50 未改动行 100% 复现现存 sha (=controller 注入后口径, 非自造)
- 逐行处置:
  - `warmup-batch-02-subcc-2-0007` | input_zh=`主驾座椅加热帮我直接开到三挡吧` | tool=`adjust_seat_heat_temperature_to_number` | 改: `{"value":"3"}` → `{"value":"3","position":"主驾"}` | position=调用目标(是) | new candidate_row_sha `201f3fd80330d3d81d6ee4a2ed9f8ad9e8b2d68ffdb37a409c04318a4b371c72`
  - `warmup-batch-02-subcc-2-0023` | input_zh=`主驾这边座椅通风麻烦开到三挡` | tool=`adjust_seat_ventilation_windspeed_to_number` | 改: `{"value":"3"}` → `{"value":"3","position":"主驾"}` | position=调用目标(是) | new candidate_row_sha `4e4fce7d4a5036de73600285d21c21aa2e6da97dba0c0e85e3ba8acec8f65d0c`
- 修复后文件 sha (权威, 已写入 SHA256SUMS.txt):
  - candidates.jsonl `sha256:2b75ba96e17553141a12bb3bf4ea890c2df2eabbb83d39ef9fd0ecc2a82d6a14`
  - value_change_ledger.jsonl `sha256:3fe88e927b3a9728e270293558df1b07750968d6bb2f8a35798b3dc370dd9269`
- 下游级联已由本轮 GATES-RERUN 刷新：controller receipt、batch_manifest.artifact_shas、DataGate/diversity/C6 gates 均以 `B02-GATES-RECEIPT-v4` supersede 旧版；repair_event=`judge_D3_position_slot_omission_fix`。
- Artifact SHA 绑定已刷新：batch_manifest.artifact_shas 记录非自指内容 artifact；batch_manifest.json 自身最终字节 sha 以 `SHA256SUMS.txt` 为权威。

## GATES-RERUN closure
- repair_event: `judge_D3_position_slot_omission_fix`
- fixed_sample_ids: `warmup-batch-02-subcc-2-0007`, `warmup-batch-02-subcc-2-0023`
- controller_receipt: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/controller-sha-injection-receipt.json`
- gates_receipt: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/gates/B02-GATES-RECEIPT-v4.md`
- supersedes: previous B02 gate receipts for this repair lane

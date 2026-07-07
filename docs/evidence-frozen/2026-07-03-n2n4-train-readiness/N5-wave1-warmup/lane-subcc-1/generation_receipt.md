# generation_receipt — warmup-batch-01 / lane subcc-1 (rev3 最终)

- batch_id `warmup-batch-01` type `standard_generation` lane `subcc-1`/Anthropic
- generator_source_vendor `anthropic` model `claude-opus`; judge 必 `openai`
- main_pin_sha `b33d8eba152e5326f69bbe85fc356b73419ee9c3`; quota_source `intent_bug_scene_recovery` (Gate7RecipeQuotaConfig, manual_override=false)
- proof_class local/pre_training_batch; claim: 机械自检 only, NOT judged/train-ready/V-PASS

## rev 历史
- rev1 首版; rev2 三改 (补 multi + digest 克隆 + TODO); **rev3 最终: multi 回退 + WAIVER**

## rev3 改动清单 (+原因)
1. **0049/0050 回退单 call canonical** (原 rev2 的 2 行多意图): ['warmup-batch-01-subcc-1-0049', 'warmup-batch-01-subcc-1-0050']
   - 全新口语「空调制冷，主驾这块儿调到22度」「主驾我要制冷二十二度，谢谢啦」→ 均 adjust_ac_temperature_to_number(主驾/制冷/22℃), value_changed=false
   - 风格避开被删候选 ([('驾驶位空调调到22度制冷', 0.846), ('驾驶位空调帮我整到22度制冷', 0.846)]); near-dup 无回升 (max 0.815)
   - 原因: 训练渲染器单 call + 0 多意图先例, 管道消费不了多 call 行
2. **multi_call_pairing floor(2) WAIVED for batch-01**, reason=`pipeline_single_call_renderer_no_multi_recipe`
3. 保留 rev2#2 tool_schema_digest 克隆 `f3a9c49109ffb33b06d233038787ca1fdad8a750d7f7d9f917738c4a83878f61` (PR31 01156/01045/01047 权威链值) + rev2#3 recipe/quota sha `sha256:TODO` (controller 注入)

## multi_call_pairing WAIVER (证据)
- `C5DerivedHashRecipe.renderToolCall` 单 call (Core/Training/C5LoRATraining.swift:2839); `assistant="\n\n"+单 renderedToolCall` (:3574-3575)
- PR31 底座 4500 训练样本 **0 行** expected_tool_calls>1 (全量扫描)
- residual: multi-call 支持 = 正式 dev 项后补 (渲染器 + 派生签名配方 + DataGate 多意图语义); multi_call floor 恢复于该项落地后的批次

## 组成统计
| 项 | 值 |
|---|---|
| 总行数 | 50 |
| adjust_ac_temperature_to_number | 44 |
| open_ac / close_ac | 3 / 3 |
| multi_call_pairing | 0 (WAIVED) |
| value_changed false / true | 34 / 16 |
| refusal 行 | 0 |

## 极性表
| 方向 | tool | 计数 |
|---|---|---|
| open (+) | open_ac | 3 |
| close (-) | close_ac | 3 |
| 对称 | — | 是 |

## 长度带宽
- unique_lengths 14 (≥5✅); p90-p10 9.0 (≥6✅, min 4/max 21); buckets 5 (≥3✅)
- severe near-dup(≥0.92)=0 (=0✅); warn(≥0.85)=0; max_ratio 0.815 (pair ['warmup-batch-01-subcc-1-0019', 'warmup-batch-01-subcc-1-0022'])

## 派生 hash (repo 真实配方逐行重算, 非克隆)
- prompt_hash=sha256(input_zh) mismatch 0 唯一 50; sig=sha256(rendered_tool_call) mismatch 0
- hash_recipe_ref `repo:Core/Training/C5LoRATraining.swift#C5DerivedHashRecipe.promptHash(utterance:);repo:Core/Training/C5LoRATraining.swift#C5DerivedHashRecipe.expectedToolCallSignature(renderedToolCall:);repo:Core/Bench/C6VehicleToolBench.swift#C6Hash.sha256Hex`; 自证对齐 dry-run seed + 真实样本

## 红线合规声明
- 未读 raw/Downloads; 无 PII/车型代号/供应商车厂真名/报价/http/禁外传; 50 行全新合成中文; raw_source_redacted/raw_text_absent 逐行 true
- 仅写 lane-subcc-1/; 未改 main_pin_sha; 未手写 quota

## Artifact SHA 绑定 (gate 前必录)
- candidates_jsonl `sha256:17f8dbe24d07fdb0b8fea7bcceb0101eb9f23cf87a88196b117974a102450e10`
- value_change_ledger_jsonl `sha256:5832fecb5d61a0eba4ee9f971d6cd0e088eb53fc781415abe153cb3f7f5d3bf1`
- batch_manifest_json `sha256:f0008f05af71502c2497f26029bed939e0893148d7b77e7ed40b80b43a046417`
- batch_self_audit_md `sha256:be4df5ea294e1dc88b87fc8ee6b1ae8bddf04f8e1dc96a0a752533e110bcbb2f`
- generation_receipt_md: 见 SHA256SUMS.txt (自指哈希写入后算)
- 5 文件完整 sha 见 SHA256SUMS.txt; post-hash 编辑作废须全门重跑

## Residual / 未达标如实
1. recipe_manifest_sha/quota_config_sha=`sha256:TODO` (controller-pending §4.1, N5E-006 后注入)
2. **multi_call_pairing floor(2) WAIVED** — 管道单 call 渲染器 + 0/4500 先例; multi-call 支持=正式 dev 项后补, floor 恢复于该项落地后的批次
3. near-dup 用 char-level SequenceMatcher 本地代理; controller diversity script 口径为准 (本地 max 0.815<0.92)
4. generator_model_id family-level `claude-opus` (未伪造精确版本串)

## 生成方法
- 生成器 `lane-subcc-1/generate_batch.py` (确定性无随机; repo 配方重算 + 全门 fail-closed 自检); 单次运行 <2s

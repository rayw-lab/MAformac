# generation_receipt — warmup-batch-05 / lane subcc-5 (Anthropic)

- batch_id `warmup-batch-05` type `standard_generation` lane `subcc-5`/Anthropic
- generator_source_vendor `anthropic` model `claude-opus`; judge 必 `openai`
- main_pin_sha `b33d8eba152e5326f69bbe85fc356b73419ee9c3`; quota_source `intent_bug_scene_recovery` (Gate7RecipeQuotaConfig, manual_override=false)
- proof_class local/pre_training_batch; claim: 机械自检 only, NOT controller-generated/judged/train-ready/V-PASS/run-auth

## 配额轮转 (order SSOT, 不 lane 自改)
| family slice | subset_group | device | count | mounted | tool_schema_digest |
|---|---|---|---|---|---|
| wiper | ac+wiper_speed | wiper_speed | 17 | 12 | 351d0f54635755bd… |
| sunroof | sunroof | sunroof/sunshade/blocking_glass | 17 | 30 | 9b2ecbac2d86b857… |
| fragrance | fragrance | fragrance/fragrance_intensity | 16 | 16 | 702077e8d76819ae… |

- **wiper**: 底座 4500 无 wiper_speed 正例 -> warmup 构造填补; 面=控制器 ac+wiper_speed 种子(order target_surface_seed, dry-run DataGate ready)
- **sunroof / fragrance**: 逐字克隆 PR31-final-n4a-recipe-build/samples 同 subset_group 真实模板 surface/tools[]/meta

## digest 处理 (batch-01 血泪对齐)
- tool_schema_digest 逐组 = manifest entries[].tool_schema_digest 权威值 (禁自派生 / 禁用 subset_policy_digest 值; 逐行断言 !=)
- subset_policy_digest `c72329fce65678a72d95319d618570469ce3149cb96a092fe59e9a6cc7c0c530` = subset-grouping.yaml sha (控制器/order/dry-run 约定; 非 PR31 模板 f3a9c491)
- recipe_manifest_sha / quota_config_sha `sha256:TODO` (controller 行级注入)

## 组成统计
| 项 | 值 |
|---|---|
| 总行数 | 50 |
| wiper / sunroof / fragrance | 17 / 17 / 16 |
| 极性 open / close | 10 / 10 (对称 是) |
| 极性 up / down | 10 / 10 (对称 是) |
| value_changed false / true | 39 / 11 |
| multi_call | 0 (WAIVED) |
| refusal | 0 |

## 长度带宽
- unique_lengths 14 (≥5✅); p90-p10 12.1 (≥6✅, min 4/max 21); buckets 5 (≥3✅)
- severe near-dup(≥0.92)=0 (=0✅); warn(≥0.85)=0; max_ratio 0.833 (pair ['warmup-batch-05-subcc-5-0039', 'warmup-batch-05-subcc-5-0043'])

## 派生 hash (repo 真实配方逐行重算, 非克隆)
- prompt_hash=sha256(input_zh) mismatch 0 唯一 50; sig=sha256(rendered_tool_call) mismatch 0
- 自证对齐: 复算 batch-05 dry-run seed 的 prompt_hash / sig / rendered PASS
- hash_recipe_ref `repo:Core/Training/C5LoRATraining.swift#C5DerivedHashRecipe.promptHash(utterance:);repo:Core/Training/C5LoRATraining.swift#C5DerivedHashRecipe.expectedToolCallSignature(renderedToolCall:);repo:Core/Bench/C6VehicleToolBench.swift#C6Hash.sha256Hex`

## 红线合规声明
- 未读 raw/Downloads; 无 PII/车型代号/供应商车厂真名/报价/密钥/http/禁外传; 50 行全新合成中文
- raw_source_redacted / raw_text_absent 逐行 true; 仅写 lane-subcc-5/; 未改 main_pin_sha; 未手写 quota
- fragrance 仅开关+浓度, 不写指定香型 positive (order 警示遵守)

## Artifact SHA 绑定 (gate 前必录)
- candidates_jsonl `sha256:50a862c8796e1989e48c6333b7f0928231a00aa3396fcee7c7f25b99c81509ab`
- value_change_ledger_jsonl `sha256:02848af6cf86c93143d587df51813e5e63755f9f312b6a3915cb21b9cdc8a245`
- batch_manifest_json `sha256:a3624a983461be7e3fa23ceea6addfb01c721b7f0f3b321a6b32e5798f3d12e6`
- batch_self_audit_md `sha256:60b81fc82814e047de26415c89e5bbbda6324a38e71750a3ddd980ae4d12d477`
- generation_receipt_md: 见 SHA256SUMS.txt (自指哈希写入后算)
- 5 内容文件完整 sha 见 SHA256SUMS.txt; post-hash 编辑作废须全门重跑

## Residual / 未达标如实
1. recipe_manifest_sha/quota_config_sha=`sha256:TODO` (controller 行级注入后 candidate_row_sha 需重算 + ledger 对齐 + SHA256SUMS 刷新)
2. **wiper 灵敏度/清洗 (sensitivity/wash) 未含**: order wiper scope 含"速度/灵敏度/清洗", 但控制器仅种子 `ac+wiper_speed`(speed-only)面; sensitivity/wash 需 subset_group `wiper`(27工具)面, 控制器未在本批种子提供 -> 本批 wiper 聚焦 speed(在 scope 内), sensitivity/wash 留待控制器另seed批次 (不自铸控制器未提供的面)
3. multi_call_pairing floor(2) WAIVED (renderToolCall 单 call + 0/4500 先例)
4. near-dup 用 char-level SequenceMatcher 本地代理; controller diversity script 口径为准 (本地 max 0.833<0.92)
5. generator_model_id family-level `claude-opus` (未伪造精确版本串)

## 生成方法
- 生成器 `lane-subcc-5/generate_batch.py` (确定性无随机; 面/digest 逐字对齐 manifest+dry-run+PR31 模板; repo hash 配方重算; 全门 fail-closed 自检)

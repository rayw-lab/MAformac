# generation_receipt — R2b S1 lane B (r2b-s1-lane-b)

- batch_id `r2b-s1-negatives-calibration-01` type `negative_repair_calibration` lane `r2b-s1-lane-b`/Anthropic
- generator_source_vendor `anthropic` model `claude-opus-4-8`（Claude Opus 4.8）；judge 必 `openai`
- prompt package: `wave2-negatives/batch-package/lane-prompt-package.md`（Lane B 块逐字执行）
- main_pin_sha `266783468ac38542574ea4787bec650d16ba6b02`（CODE-2026-07-03-PR38）
- proof_class local/pre_training_batch；claim: 机械自检 only，NOT judged / candidate-ready / train-ready / V-PASS
- 可复现生成器 `generate_lane_b.py`（确定性无随机，全门 fail-closed；`WRITE=1 python3 generate_lane_b.py`）

## 组成（75 = 5 family × 15）
- 每族 9 positive；非-positive 按 class 分布见下
- class_counts: {"positive": 45, "unsupported": 11, "refusal": 5, "already_state": 5, "followup": 5, "query": 4}
- family × class: {"fragrance/already_state": 1, "fragrance/followup": 1, "fragrance/positive": 9, "fragrance/query": 2, "fragrance/refusal": 1, "fragrance/unsupported": 1, "screen/already_state": 1, "screen/followup": 1, "screen/positive": 9, "screen/refusal": 1, "screen/unsupported": 3, "sunroof_sunshade/already_state": 1, "sunroof_sunshade/followup": 1, "sunroof_sunshade/positive": 9, "sunroof_sunshade/refusal": 1, "sunroof_sunshade/unsupported": 3, "volume/already_state": 1, "volume/followup": 1, "volume/positive": 9, "volume/query": 2, "volume/refusal": 1, "volume/unsupported": 1, "wiper/already_state": 1, "wiper/followup": 1, "wiper/positive": 9, "wiper/refusal": 1, "wiper/unsupported": 3}

## ✅ class quota 偏离（approved 选项 A，commander ref R2B-QUERY-RECLASS-01）
- batch-order 每族 2 query（Lane B 共 10）；亲核契约 semantic-function-contract.jsonl（3990 行）：query_* intent 仅 volume→query_current_volume、fragrance→query_amount_of_fragrance/query_mode_of_fragrance；**screen/wiper/sunroof_sunshade 无 query intent**（team-lead 亲核坐实：全契约 query intent 仅 ac_temperature/ac_windspeed/current_volume/amount_of_fragrance/mode_of_fragrance）
- 处置：按 `WAVE2-GENERATOR-HARDENING §3.1` 末条「query 无 mounted query_* → 改判 unsupported」+ lane-package 类形态铁律，6 query 槽（screen2/wiper2/sunroof2）改判 unsupported，用 query 式话术→NO_TOOL（target_tool_present=false，不留不存在的 query 工具于 mounted；服务 MP-029 query->actuation 零容忍）
- delivered: query 4 / unsupported 11（screen3+wiper3+sunroof3+volume1+fragrance1）；每改判行记 `class_reclassified_from=query`
- commander ref `R2B-QUERY-RECLASS-01` approved（选项 A）；manifest.class_quota_deviation = {"deviation":"query_quota_reclassified_to_unsupported","families":["screen","wiper","sunroof_sunshade"],"commander_ref":"R2B-QUERY-RECLASS-01","evidence":"contract has no query intent for these families"}

## 派生 hash（repo 真实配方逐行重算，非克隆）
- prompt_hash=sha256(input_zh) mismatch 0 / 唯一 75；expected_tool_call_signature=sha256(rendered_tool_call) mismatch 0（no-call 行 rendered=`NO_TOOL`）
- candidate_row_sha=sha256(canonical row bytes) 逐行；ledger 同步
- hash_recipe_ref `repo:Core/Training/C5LoRATraining.swift#C5DerivedHashRecipe.promptHash(utterance:);repo:Core/Training/C5LoRATraining.swift#C5DerivedHashRecipe.expectedToolCallSignature(renderedToolCall:);repo:Core/Bench/C6VehicleToolBench.swift#C6Hash.sha256Hex`
- tool_schema_digest=sha256(canonical mounted tools bytes) 逐族（模板-surface 权威；非 subset_policy_digest/自铸/stale）

## pair / floor
- total pair groups 16；floor: {"screen_little_vs_number": 2, "screen_gear_min_max_vs_number": 2, "volume_relative_vs_absolute": 3, "wiper_relative_vs_absolute": 3, "wiper_open_close": 1, "sunroof_open_close": 3, "fragrance_open_close_or_strength": 2}
- W10 §2：≥N pair groups=R2b 全量(S1+S2)，S1 只需触达；全 6 floor 已触达，volume/wiper/sunroof/fragrance 达 ≥N，screen 两 floor 各 2（9 positive 物理上限）→ s2_floor_carry_forward
- 🔴 **priority_in_full750=high**（team-lead D-087）：`screen_little_vs_number` 对应 **D 轴 MP-003 退化 cluster**（raise_screen_brightness_little->adjust_screen_brightness_to_min），full-750 **必须补满 ≥4 pair groups**；`screen_gear_min_max_vs_number` 同 priority=high（min/max 吞 little 风险），full-750 ≥4。S2 补量 owner 请优先排这两 cluster。

## no-call envelope
- candidate no-call 21 / query 4 / ratio 0.2958（status waiver_required, cap 0.20）；训练前下采样（非生成门）

## 长度/多样性
- unique_lengths 17 / p90-p10 9.6 / buckets 5 / severe(≥0.92) 0 / warn(≥0.85) 0 / max_ratio 0.833

## 红线合规
- 未读 raw/Downloads；无 PII/车型代号/供应商车厂真名/报价/禁外传；75 行全新合成中文；raw_source_redacted/raw_text_absent 逐行 true
- 仅写 lane-subcc dir；未改 main_pin_sha；未手写 quota

## Residual / 未达标如实
1. recipe_manifest_sha/quota_config_sha=`sha256:CONTROLLER_PENDING`（§4.1 controller 注入）
2. **class quota 偏离**（query→unsupported 6 行）approved 选项 A，commander ref `R2B-QUERY-RECLASS-01`（已过 A11 quota 门）
3. tool_schema_digest 为生成方按 mounted tools bytes 计算；若 controller canonical 配方不同则 re-derive（已登记 recipe）
4. no-call candidate ratio 0.2958 > 0.20 target/cap → 训练前必须下采样（candidate pool 允许）
5. screen 两 high-risk floor S1 各 2 pair groups（<批 order target 4），受 9 positive 物理上限，余量 s2_floor_carry_forward；🔴 priority_in_full750=high（screen_little_vs_number↔MP-003 退化 cluster，full-750 必须补满 ≥4）
6. near-parallel/D1-D4/D8 语义维度留 openai judge 抽样（本 receipt 只作机械自检 claim）

## Artifact SHA 绑定（gate 前必录）
- candidates_jsonl `sha256:9895f7a900e168d5b01e74334a1a1e9fa702ba76fa278638156006055bbf457d`
- value_change_ledger_jsonl `sha256:021c4fd6d01596c14245645a2519532f106a310613f901b757013e859f279dae`
- batch_manifest_json `sha256:b1d8ef9543e0281bae1961f409d320e4c6d550545076c4df82f6dab9e8364065`
- batch_self_audit_md `sha256:0699f7f33a4e714d84ecdb10963cab0db360f789df365858c29a62c4aa92188c`
- generation_receipt_md: 见 SHA256SUMS.txt（自指哈希写入后算）

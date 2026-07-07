# wave-1 warmup batch-04 生成 receipt（lane subcc-4）

## 生成方

- 厂商: Anthropic（D-044/D-045/D-050 授权：只生成不训练）
- 模型: Claude Opus 4.8（`generator_model_id=claude-opus-4.8`）
- lane: `subcc-4` / `generation_lane_id=subcc-4` / `generator_source_vendor=anthropic`
- judge 厂商要求: OpenAI（跨厂商，非同厂）
- 生成时刻: 交付即 `generated`（未跑 DataGate / judge）

## 组成（50 行）

| 维度 | 明细 |
|---|---|
| 家族切片 | light 18 / screen 16 / volume 16 = 50 |
| 类别 | 全 positive（refusal=0，硬锁） |
| 值策略 | 值克隆模板 42 行 + 登记改值 8 行（全值域内 1-10 档，args_diff/why_changed/schema_check=pass 齐备） |
| 极性 | raise 13 / lower 12；to_max 6 / to_min 5（平衡） |
| 工具型覆盖 | light 触及 atmosphere_lamp 10 型；screen 8 型全触及；volume 8 型全触及（含 position/name/mode/screen_type/tag slot 变体） |
| 长度带宽 | 唯一长度 13 种；p90-p10=7.1 字；长度桶 短13/中32/长5；字数范围 5–19 |
| 近重复 | severe(≥0.92)=0；WARN(0.85–0.92)=0 |

## Surface / digest（全部复制自真源，零自铸）

真源 = `generated/subset-policy-manifest.json entries[].tool_schema_digest`（`tool_schema_digest_controller_injected` 条款点名）。

| family | subset_group_id | mounted_tool_count | tool_schema_digest |
|---|---|---|---|
| light | scene.scene2（order seed） | 20 | ab0d8bb7…8de232a4 |
| screen | screen_brightness | 8 | 39b34fe1…0af0cfaa |
| volume | volume | 8 | 5691ff99…174ddbc8 |

- subset_policy_id=e2-lite-v1；subset_policy_digest=c72329…（= subset_grouping.yaml sha，与 seed+batch-01 一致）。
- 详见 `batch_self_audit.md §2` 的 surface 决策与 controller 复核请求。

## 派生 hash（自算，配方双向验证）

- prompt_hash = `C6Hash.sha256Hex(input_zh utf8)` — 50/50 逐行重算命中。
- expected_tool_call_signature = `C6Hash.sha256Hex(<tool_call>{"name":..,"arguments":..}</tool_call> utf8)`（compact `,:` 分隔 + ensure_ascii=False + 参数键序保留）— 50/50 命中。
- 配方 `hash_recipe_ref` 已在 PR31-final sample（ce2fdc…/33e6b7…）与 batch-01 lane 行（b9b276…/f4ef92…）双向核对通过。
- `hash_recomputed_by_pipeline=true`；无克隆模板 hash（每唯一话术→唯一 hash）。

## controller 待注入

- `recipe_manifest_sha` / `quota_config_sha`：全行 `sha256:TODO`（controller 注入）。
- 注入后须按 `row_level_controller_sha_injection` 重算每行 `candidate_row_sha` + 回写 ledger + 刷新 SHA256SUMS。

## 红线合规

- 无 PII / 车型代号（AH8/T19/E0Y 等）/ 供应商·车厂真名 / 报价·成本 / 密钥 / raw 原文语料。
- `raw_source_redacted=true`，`raw_text_absent=true`。
- 未写训练输入、未改配额、未改 main_pin_sha。

## 产出文件

- candidates.jsonl（50 行）
- value_change_ledger.jsonl（50 行）
- batch_manifest.json
- batch_self_audit.md
- generation_receipt.md
- SHA256SUMS.txt（绑定上述 5 内容 artifact 字节）

## 非声称

生成方硬产出。不主张 generated-passed / train-ready / candidate-ready / V-PASS / run-auth。下游门：controller 行级 sha 注入 → DataGate（须 `data_gate_ready`）→ OpenAI 跨厂商 family judge。

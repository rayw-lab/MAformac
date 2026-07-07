# N5 Canary 生成 Receipt（Anthropic 厂商生成器）

- **scope**: `N5 canary generation only; no training, no model-quality claim, no cloud API`
- **模型 ID**: `claude-opus-4-8`（Claude Opus 4.8，Anthropic subagent）
- **生成时间**: 2026-07-03 09:02:59 CST
- **产出文件**:
  - `canary-anthropic-opus.jsonl` — 60 行 / `sha256 = 3ef37e02de67c9f8697a816e7d679c3d9a5246b7c1ef388a57597220a7070d78`（**re-judge 修复轮 rev2**，旧 rev1 sha `9045d9c8…b772b8b9` 已失效）
  - 🔴 `canary-value-ledger.jsonl` — **逐行 value-changed 溯源表**（60 行，machine-readable，D9/A12 门要求）/ `sha256 = 3b248cc8dc52b1fd7fda62016c1f69affcc309bca8ca644c57b4a7d185f81249`
- **可复现生成器**: `_gen_canary.py`（本目录，内嵌 60 行手写规格 + 逐行 schema 校验；同一 pass 产出 canary jsonl + ledger jsonl，`python3 _gen_canary.py` 可复跑）
- **shape 模板来源**: `../n4a-wave1-proto-build/samples/c5-training-samples.jsonl`（4500 行 / 55 subset group）
- **契约核范围来源**: `/Users/wanglei/workspace/MAformac-p5w-wave1-bridge/contracts/semantic-function-contract.jsonl`（只读参考）

---

## 1. 组成统计表（每 group：行数 / 极性计数）

| # | subset_group_id | 行数 | 极性计数 | 极性对称 |
|---|---|---|---|---|
| 1 | `seat.massage_force_time`（E-2 降档组） | 6 | open 1 / close 1 / raise 2 / lower 2 | ✅ open=close, raise=lower |
| 2 | `ac_temperature`（空调温度） | 8 | raise 2 / lower 2 / to_max 1 / to_min 1 / neutral 2 | ✅ raise=lower, max=min |
| 3 | `ac_windspeed`（风量） | 6 | raise 1 / lower 1 / to_max 1 / to_min 1 / neutral 2 | ✅ raise=lower, max=min |
| 4 | `ac_cooling_mode`（制冷开关） | 4 | open 2 / close 2 | ✅ open=close |
| 5 | `window`（车窗） | 6 | open 3 / close 3 | ✅ open=close |
| 6 | `atmosphere_lamp_color`（氛围灯颜色） | 6 | switch 6 | — 无开关极性 |
| 7 | `atmosphere_lamp`（氛围灯开关） | 4 | open 2 / close 2 | ✅ open=close |
| 8 | `sunroof`（天窗） | 6 | open 3 / close 3 | ✅ open=close |
| 9 | `volume`（音量） | 6 | raise 2 / lower 2 / to_max 1 / to_min 1 | ✅ raise=lower, max=min |
| 10 | `seat.heat`（座椅加热） | 4 | open 1 / close 1 / raise 1 / lower 1 | ✅ open=close, raise=lower |
| 11 | `fragrance`（香氛） | 4 | open 1 / close 1 / raise 1 / lower 1 | ✅ open=close, raise=lower |
| — | **合计** | **60** | **11 组** | **极性对称失败：无** |

> 🔴 **open/close 极性对称**（wave-1 配方锚，B 轴四败中 2 条为 close→open 极性翻转）：所有含开/关的 group `#open == #close` 全部相等；升/降类同步保证 `#raise == #lower`、`#to_max == #to_min`。机器校验结果 = **0 失败**。

## 2. value 分布（arguments 值 token）

- `value=LITTLE` × 12（EXP 相对量，来自 `_little` 类工具）
- `adjustment_mode=摄氏度` × 4；`direction=主驾` × 3；`mode=制冷` × 3；`direction=副驾` × 2；`position=全车` × 2；`value=50` × 2
- 各 1 次：`minute=5/3`、`temperature=2/3/24/26`、`mode=制热`、`fanSpeed=3/6`、`position=主驾/副驾/前排/后排`、`value=30/20/2/3/MAX/MIN`、`color=冷蓝色`、氛围灯颜色 value（冰蓝色/天蓝色/冷白色/琥珀色/姹紫嫣红/万紫千红；`品色`已 D1 修复为 `琥珀色`）、`name=门板氛围灯/轮廓氛围灯`
- **数值范围核对（契约门）**：空调温度绝对值 24/26 ∈ [18,32] ✅；风量 3/6 ∈ [1,10] ✅；车窗/天窗百分比 50/30/20 ∈ [0,100] ✅。相对增量（温度 2/3 度、音量 2/3 格、按摩时间 3/5 分钟）与 EXP token（LITTLE/MAX/MIN）沿用契约既有形态。

## 3. 方法声明（保证机械正确性，非手造 surface 字段）

1. **字段模板来源**：每行克隆 shape 模板中**同 `subset_group_id` + 同 tool_name** 的真实样本行（`copy.deepcopy`），所有 **surface / digest / meta / tools 字段逐字保留**：`bucket`/`route_tier`/`split`/`subset_policy_id`/`subset_policy_digest`/`tool_schema_digest`/`prompt_hash`/`expected_tool_call_signature`/`masking`/`masking_stage`/`acceptance_stage`/`tools`/`parent_semantic_id`/`candidate_*`/`lineage_group_id` 等原样不动（spot-check 抽样 5 行与模板同组一致）。
2. **只改 4 类字段**：
   - `sample_id` → `canary-anth-0001`…`canary-anth-0060` 递增；
   - `input_zh` → **全新自然口语中文**（同时写入顶层 `input_zh` 字段 + `messages[user].content`）——模糊/口语/委婉/长短句变体，L2 慢路风格（如「腰有点酸，按摩帮我按重一点」「车窗开条缝透透气」「屁股有点凉，座椅再热一点」）；
   - `tool_call` 的 `arguments` 值 → 与 `input_zh` 语义一致、且经**模板 tool schema 逐行校验**（enum 成员合法 / key 是 properties 子集 / 数值在契约范围）；`expected_tool_calls` 与 `messages[assistant]` 的 `<tool_call>` 同步一致（arguments key 按字母序规范化，对齐模板 canonical 形态）；
   - generator 三族 → `generator_source = anthropic_subagent_cc`、`generator_source_vendor = anthropic`、`generator_model_id = claude-opus-4-8`（另 `generator_call_id` 更新为 `anthropic-subagent-cc-canary-<sample_id>`，其余 judge 字段不动）。
3. **tool NAME 不改**（决定极性/正确性），仅改 arguments 值；自然口语必与 tool 语义一致。
4. **机械校验结果**（`python3 _gen_canary.py` 生成时 + 独立复核脚本）：
   - 60 行全部 `json.loads` 可解析（parse_err = 0）；
   - `sample_id` 唯一（60/60）；`input_zh` 唯一，近重复对（SequenceMatcher ≥ 0.85）= **0**；
   - 顶层 `input_zh == messages[user].content`、`messages[assistant] == expected_tool_calls`（一致性问题 = 0）；
   - 每行 arguments 再校验 ⊆ 该行 `tools[].parameters.properties` 且 enum 成员合法（schema 问题 = 0）；
   - generator 三族字段全部命中（问题 = 0）。

## 4. 红线合规声明

- ✅ **未读** `~/workspace/raw/`、`~/Downloads/`（原始座舱语料只读区全程未访问）。
- ✅ **未复制原文语料**：`input_zh` 为本模型全新撰写的自然口语车控指令，非搬运源语料；surface/digest 字段来自 wave-1 shape 模板（工程派生物，非原始中文语料）。
- ✅ **生成文本红线扫描 = 全清**：关键词命中（讯飞/iflytek/奇瑞/chery/AH8/T19/E0Y/某车厂）= 无；疑似车型代号 regex（`[A-Z]{1,3}\d{1,3}`）= 无；手机号 = 无；邮箱 = 无。
- ✅ **写盘范围**：仅写 `runs/2026-07-03-n2n4-train-readiness/N5-canary/`，未碰任何 git 仓工作区文件；仓库仅只读参考。

## 5. 已知既定口径（供下游 DataGate / judge 知悉）

- `prompt_hash` / `expected_tool_call_signature` 等 digest 字段为**克隆模板原值，未随新 `input_zh`/新 arguments 重算**——遵 team-lead「surface/digest/meta 字段逐字保留」指令。若下游 DataGate 对 canary 做 hash 一致性校验，此为 canary 探针的**既定属性**（本生成器不掌握原始 hashing 配方，重算风险高于诚实保留，故不重算）。
- `utterance_source` / `value_strategy` 等 meta 字段保留模板原值（如 `semantic_protocol_seed`），与新自然口语 `input_zh` 的语义标注可能不自洽——同属「meta 逐字保留」既定口径。

## 6. value-changed 登记表（commander 补充约束，grill corner case）

> **约束背景**（commander 2026-07-03 补，立即生效）：tool_call arguments 值**优先不改**（只改 input_zh 说法），因每行 `parent_semantic_id`/`case_id` 复制自模板行，改值可能造成 parent 语义行 ↔ tool_call 错配（DataGate 的 axis-overlap 检查用 parent id 关联）。若确需改值：值必须仍在契约范围内，且逐行登记。已生成行按此补登记，不重生成（judge 会带 parent 一致性维度核）。

共 **31 行**改值（60 行中，其余 **29 行** tool_call 值与克隆源模板一致 → parent_semantic_id ↔ tool_call 一致）。全部新值经 schema + enum + 契约数值范围校验通过（rule #2「值必须仍在契约范围内」达标）。改值主因：**多数源模板值为合成占位符/通用样例值**（`fanSpeed_value_1`/`*_value_N`/`value:"1"`/`temperature:"22"`），换成契约内真实值/相对量以贴合自然口语 input_zh。

🔴 **parent 一致性影响提示（供 judge/DataGate）**：31 行改值行的 `parent_semantic_id`/`candidate_*`/`case_id` 仍为克隆源模板原值（未随新 args 调整）——若 axis-overlap 用 parent id 关联原始 args 语义，这 31 行会呈现 parent(原 args) ↔ tool_call(新 args) 差异。属改值的既定副作用，逐行如下：

| # | sample_id | 克隆源模板行 | tool | input_zh | 模板原值 | 新值 | 为什么改 |
|---|---|---|---|---|---|---|---|
| 1 | `canary-anth-0005` | `c5-train-01437` | `raise_seat_massage_time_by_number` | 按摩时间再给我加五分钟 | `{"hour": "hour_value_1"}` | `{"minute": "5"}` | 源模板值为合成占位符 token（`*_value_N`）→ 换契约范围内真实值（风量1-10档 / 时间分钟数） |
| 2 | `canary-anth-0006` | `c5-train-01453` | `lower_seat_massage_time_by_number` | 按摩时间缩短三分钟吧 | `{"minute": "minute_value_1"}` | `{"minute": "3"}` | 源模板值为合成占位符 token（`*_value_N`）→ 换契约范围内真实值（风量1-10档 / 时间分钟数） |
| 3 | `canary-anth-0007` | `c5-train-00035` | `raise_ac_temperature_by_exp` | 主驾这边有点凉，空调调高一点 | `{"temperature": "22"}` | `{"direction": "主驾"}` | by_exp 为相对量：源仅带通用温度样例值(22)，去绝对数值改用 direction/mode enum，贴合 input_zh 相对说法 |
| 4 | `canary-anth-0008` | `c5-train-00043` | `lower_ac_temperature_by_exp` | 车里太闷热了，空调再凉快点 | `{"temperature": "22"}` | `{"mode": "制冷"}` | by_exp 为相对量：源仅带通用温度样例值(22)，去绝对数值改用 direction/mode enum，贴合 input_zh 相对说法 |
| 5 | `canary-anth-0009` | `c5-train-01145` | `raise_ac_temperature_by_number` | 空调帮我往上调两度 | `{"adjustment_mode": "摄氏度", "temperature": "22"}` | `{"adjustment_mode": "摄氏度", "temperature": "2"}` | 源为通用样例数值(1/22)→ 换与 input_zh 一致的契约内数值（温度18-32绝对/相对增量、风量1-10、窗天窗百分比0-100、音量档） |
| 6 | `canary-anth-0010` | `c5-train-01149` | `lower_ac_temperature_by_number` | 温度给我往下降三度 | `{"adjustment_mode": "摄氏度", "temperature": "22"}` | `{"adjustment_mode": "摄氏度", "temperature": "3"}` | 源为通用样例数值(1/22)→ 换与 input_zh 一致的契约内数值（温度18-32绝对/相对增量、风量1-10、窗天窗百分比0-100、音量档） |
| 7 | `canary-anth-0011` | `c5-train-01153` | `adjust_ac_temperature_to_number` | 空调就设到二十四度吧 | `{"adjustment_mode": "摄氏度", "temperature": "22"}` | `{"adjustment_mode": "摄氏度", "temperature": "24"}` | 源为通用样例数值(1/22)→ 换与 input_zh 一致的契约内数值（温度18-32绝对/相对增量、风量1-10、窗天窗百分比0-100、音量档） |
| 8 | `canary-anth-0012` | `c5-train-01154` | `adjust_ac_temperature_to_number` | 副驾这边空调调到二十六度 | `{"adjustment_mode": "摄氏度", "direction": "主驾", "temperature": "22"}` | `{"adjustment_mode": "摄氏度", "direction": "副驾", "temperature": "26"}` | 源为通用样例数值(1/22)→ 换与 input_zh 一致的契约内数值（温度18-32绝对/相对增量、风量1-10、窗天窗百分比0-100、音量档） |
| 9 | `canary-anth-0013` | `c5-train-01161` | `adjust_ac_temperature_to_max` | 空调直接开到最热 | `{"temperature": "22"}` | `{"mode": "制热"}` | to_max/to_min 无需数值：去通用温度样例值(22)，改用 mode enum(制冷/制热) 与 input_zh 一致 |
| 10 | `canary-anth-0014` | `c5-train-01165` | `adjust_ac_temperature_to_min` | 空调给我拉到最低温 | `{"temperature": "22"}` | `{"mode": "制冷"}` | to_max/to_min 无需数值：去通用温度样例值(22)，改用 mode enum(制冷/制热) 与 input_zh 一致 |
| 11 | `canary-anth-0015` | `c5-train-00019` | `raise_ac_windspeed_by_exp` | 风开大一点 | `{"fanSpeed": "fanSpeed_value_1"}` | `{"mode": "制冷"}` | 源模板值为合成占位符 token（`*_value_N`）→ 换契约范围内真实值（风量1-10档 / 时间分钟数） |
| 12 | `canary-anth-0016` | `c5-train-00027` | `lower_ac_windspeed_by_exp` | 风太猛了，小一点 | `{"fanSpeed": "fanSpeed_value_1"}` | `{}` | 源模板值为合成占位符 token（`*_value_N`）→ 换契约范围内真实值（风量1-10档 / 时间分钟数） |
| 13 | `canary-anth-0017` | `c5-train-01125` | `adjust_ac_windspeed_to_number` | 风量调到三档 | `{"fanSpeed": "fanSpeed_value_1"}` | `{"fanSpeed": "3"}` | 源模板值为合成占位符 token（`*_value_N`）→ 换契约范围内真实值（风量1-10档 / 时间分钟数） |
| 14 | `canary-anth-0018` | `c5-train-01126` | `adjust_ac_windspeed_to_number` | 主驾出风调到六档 | `{"direction": "主驾", "fanSpeed": "fanSpeed_value_1"}` | `{"direction": "主驾", "fanSpeed": "6"}` | 源模板值为合成占位符 token（`*_value_N`）→ 换契约范围内真实值（风量1-10档 / 时间分钟数） |
| 15 | `canary-anth-0019` | `c5-train-01133` | `adjust_ac_windspeed_to_max` | 风量开到最大 | `{"fanSpeed": "fanSpeed_value_1"}` | `{}` | 源模板值为合成占位符 token（`*_value_N`）→ 换契约范围内真实值（风量1-10档 / 时间分钟数） |
| 16 | `canary-anth-0020` | `c5-train-01137` | `adjust_ac_windspeed_to_min` | 风量调到最小档 | `{"fanSpeed": "fanSpeed_value_1"}` | `{}` | 源模板值为合成占位符 token（`*_value_N`）→ 换契约范围内真实值（风量1-10档 / 时间分钟数） |
| 17 | `canary-anth-0024` | `c5-train-01058` | `close_ac_cooling_mode` | 副驾的制冷关了吧 | `{"direction": "主驾"}` | `{"direction": "副驾"}` | slot 维度多样化：改为契约 enum 内其他合法成员（direction/position/name/color），语义与 input_zh 说法一致 |
| 18 | `canary-anth-0026` | `c5-train-01169` | `open_window_to_number` | 主驾车窗开到一半 | `{"value": "1"}` | `{"position": "主驾", "value": "50"}` | 源为通用样例数值(1/22)→ 换与 input_zh 一致的契约内数值（温度18-32绝对/相对增量、风量1-10、窗天窗百分比0-100、音量档） |
| 19 | `canary-anth-0029` | `c5-train-01187` | `close_window_to_number` | 副驾车窗关到三成 | `{"value": "1"}` | `{"position": "副驾", "value": "30"}` | 源为通用样例数值(1/22)→ 换与 input_zh 一致的契约内数值（温度18-32绝对/相对增量、风量1-10、窗天窗百分比0-100、音量档） |
| 20 | `canary-anth-0031` | `c5-train-01712` | `switch_atmosphere_lamp_color` | 氛围灯给我换成冰蓝色 | `{}` | `{"value": "冰蓝色"}` | slot 维度多样化：改为契约 enum 内其他合法成员（direction/position/name/color），语义与 input_zh 说法一致 |
| 21 | `canary-anth-0032` | `c5-train-01713` | `switch_atmosphere_lamp_color` | 门板的氛围灯调成天蓝色 | `{"position": "主驾"}` | `{"name": "门板氛围灯", "value": "天蓝色"}` | slot 维度多样化：改为契约 enum 内其他合法成员（direction/position/name/color），语义与 input_zh 说法一致 |
| 22 | `canary-anth-0033` | `c5-train-01714` | `switch_atmosphere_lamp_color` | 灯光颜色换成冷白色吧 | `{"name": "面发光氛围灯"}` | `{"value": "冷白色"}` | slot 维度多样化：改为契约 enum 内其他合法成员（direction/position/name/color），语义与 input_zh 说法一致 |
| 23 | `canary-anth-0034` | `c5-train-01715` | `switch_atmosphere_lamp_color` | 前排氛围灯调成琥珀色 | `{"name": "面发光氛围灯", "position": "主驾"}` | `{"position": "前排", "value": "琥珀色"}` | slot 维度多样化 + **D1 修复**：色词 `品色`→自然口语色 `琥珀色`（属 atmosphere_lamp color enum63、未与其他行重复），position 主驾→前排随 input_zh |
| 24 | `canary-anth-0035` | `c5-train-01716` | `switch_atmosphere_lamp_color` | 氛围灯来个姹紫嫣红的感觉 | `{"value": "1"}` | `{"value": "姹紫嫣红"}` | 源为通用样例数值(1/22)→ 换与 input_zh 一致的契约内数值（温度18-32绝对/相对增量、风量1-10、窗天窗百分比0-100、音量档） |
| 25 | `canary-anth-0036` | `c5-train-01717` | `switch_atmosphere_lamp_color` | 轮廓灯整成万紫千红 | `{"position": "主驾", "value": "1"}` | `{"name": "轮廓氛围灯", "value": "万紫千红"}` | 源为通用样例数值(1/22)→ 换与 input_zh 一致的契约内数值（温度18-32绝对/相对增量、风量1-10、窗天窗百分比0-100、音量档） |
| 26 | `canary-anth-0038` | `c5-train-00093` | `open_atmosphere_lamp` | 开个氛围灯，调成冷蓝色 | `{"position": "主驾"}` | `{"color": "冷蓝色"}` | slot 维度多样化：改为契约 enum 内其他合法成员（direction/position/name/color），语义与 input_zh 说法一致 |
| 27 | `canary-anth-0040` | `c5-train-01703` | `close_atmosphere_lamp` | 后排的氛围灯关了 | `{"position": "主驾"}` | `{"position": "后排"}` | slot 维度多样化：改为契约 enum 内其他合法成员（direction/position/name/color），语义与 input_zh 说法一致 |
| 28 | `canary-anth-0042` | `c5-train-01223` | `open_sunroof_to_number` | 天窗开到一半 | `{"value": "1"}` | `{"position": "全车", "value": "50"}` | 源为通用样例数值(1/22)→ 换与 input_zh 一致的契约内数值（温度18-32绝对/相对增量、风量1-10、窗天窗百分比0-100、音量档） |
| 29 | `canary-anth-0045` | `c5-train-01241` | `close_sunroof_to_number` | 天窗关到两成 | `{"value": "1"}` | `{"position": "全车", "value": "20"}` | 源为通用样例数值(1/22)→ 换与 input_zh 一致的契约内数值（温度18-32绝对/相对增量、风量1-10、窗天窗百分比0-100、音量档） |
| 30 | `canary-anth-0049` | `c5-train-01838` | `raise_volume_by_number` | 音量往上调两格 | `{"value": "1"}` | `{"value": "2"}` | 源为通用样例数值(1/22)→ 换与 input_zh 一致的契约内数值（温度18-32绝对/相对增量、风量1-10、窗天窗百分比0-100、音量档） |
| 31 | `canary-anth-0050` | `c5-train-01850` | `lower_volume_by_number` | 音量降低三格 | `{"value": "1"}` | `{"value": "3"}` | 源为通用样例数值(1/22)→ 换与 input_zh 一致的契约内数值（温度18-32绝对/相对增量、风量1-10、窗天窗百分比0-100、音量档） |

> **未改值的 29 行**（parent 一致，无需登记）：sample_id `0001-0004`、`0021-0023`、`0025`、`0027-0028`、`0030`、`0037`、`0039`、`0041`、`0043-0044`、`0046-0048`、`0051-0060`——tool_call args 与克隆源模板逐字一致（多为 `{}` 无槽开关/开关类，或 `{"value":"LITTLE"}` 等与源一致的相对量）。
>
> **可选更清方案（供 commander 定夺，未执行）**：若要把改值行降到最低以最大化 parent 一致性，可重生成——对每个 SPEC entry 优先选「args 已等于目标值」的模板行克隆（0 改值）、并反向按模板真实 args 写 input_zh。代价：会使 placeholder 值（`fanSpeed_value_1` 等）进入 canary tool_call（偏离自然口语），且会打断已在消费当前文件的 judge/diversity 产出。默认遵 rule #3 不重生成。

## 7. re-judge 修复轮（rev2，CANARY_FAIL → 修复）

首轮正式 judge（`%43`，`canary-judge-verdict.md`）= **CANARY_FAIL**，主败因为**溯源不是内容**（DataGate/diversity 均 PASS）。按 judge 修复单逐条处置，只改必要行，60 行总数 / 极性对称 / 未改行内容全部不变：

### 7.1 D9 + A12（主 blocker，43 非空 args 行不可审）→ 新增机械溯源账本
- 产出 🔴 `canary-value-ledger.jsonl`（60 行，machine-readable），每行字段：`sample_id` / `template_sample_id`（精确 N4A 模板行 sample_id）/ `subset_group_id` / `tool_name` / `value_changed`(bool) / `args_diff`（逐字段 `{字段:{old,new}}`，删/增字段用 `null`）/ `template_args` / `canary_args` / `why_changed` / `schema_check`。
- **方法（机械推导，非凭记忆）**：ledger 由 `_gen_canary.py` 在**同一生成 pass** 内产出——克隆模板行前捕获其 `sample_id` + 原始 `expected_tool_calls.arguments`，与写入的 canary args 逐字段 diff。`template_sample_id` 全部经校验 ∈ N4A 样本文件真实 sample_id 集合；`ledger.canary_args` 与 canary jsonl 每行 args 交叉核对 100% 一致。
- 统计：60 行全覆盖；`value_changed=true` **31 行**、`false` 29 行（29 行 args 与模板逐字一致 → parent 天然一致）。

### 7.2 D1（`canary-anth-0034` 色词非自然）→ 已修
- `品色` → `琥珀色`（自然口语暖色，属 atmosphere_lamp `color` enum63「值域内」，且未与其他行颜色重复）；input_zh `前排氛围灯弄成品色` → `前排氛围灯调成琥珀色`。value 仍为 free-form SPOT（schema 合法）。

### 7.3 D8（10 行精确 L1 短令 > 15% 校准帽=9）→ 转 3 行为 L2 模糊说法
从 judge 标记的 10 行（`0001/0021/0025/0028/0037/0039/0041/0044/0053/0057`）中转 **3 行**（tool/args/极性**不变**，仅 input_zh 加状态铺垫转口语）：

| sample_id | tool（不变） | 旧 input_zh（L1 短令） | 新 input_zh（L2 口语） |
|---|---|---|---|
| `canary-anth-0025` | `open_window` `{}` | 把车窗打开 | 帮我把车窗降下来透口气 |
| `canary-anth-0044` | `close_sunroof` `{}` | 天窗关上 | 有点冷了，天窗合上吧 |
| `canary-anth-0057` | `open_fragrance` `{}` | 把香氛打开 | 车里味儿闷，来点香氛吧 |

转后 L1 锚点 10→7（≤ 校准帽 9）；保留 7 行 L1 锚点作极性锚（judge 认可其为「useful polarity anchors」）。

### 7.4 rev2 复校（全绿）
60 行可解析 / sid 唯一 / input_zh 唯一 + 近重复(≥0.85)=0 / 一致性(input_zh==user、assistant==expected_tool_calls)=0 / schema+enum=0 / 极性对称失败=0 / 红线扫描全清；ledger 60 行、template_sample_id 全真实、canary_args 与 jsonl 100% 一致。

---
*生成器：Anthropic subagent（Claude Opus 4.8）· 2026-07-03 · N5 canary only · §6 登记表补于 commander 补充约束后 · §7 rev2 修复于 %43 CANARY_FAIL 后（D9/A12 ledger + D1 + D8）*

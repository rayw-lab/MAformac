# home-llm 蓝本 teardown（数据管线）— C5 LoRA 训练数据配方

> 接 `2026-06-19-home-llm-teardown.md`（runtime 层）。本文 = **数据管线层**：home-llm 怎么从 CSV piles 生成 LoRA 训练集。逐文件读全（generate_data 873 / prompting 64 / devices 308 + utils/tools/synthesize 摘要），带行号。
> **核心结论**：home-llm 的 C5 配方 = **5 类样本生成器（覆盖 MAformac 6 维度）+ 模板化随机参数填充（1 模板→N 样本）+ distractor 设备（落域训练）+ train_on_turn masking（只训正确输出）+ 配比 factors（templated 最重）+ LLM 增广**。MAformac 3990 协议→templated，12000 bug→failures+refusals，raw→variants，直接套。

## §1 总览：piles(CSV seed) → 5 生成器 → ShareGPT jsonl

`generate_sft_file`（`generate_data.py:698-771`）：每 persona × 每 pile 条目 × factor → 调对应生成器 → `format_example_sharegpt` → jsonl。`run_factor_times`（:720）：factor≥1 生 int(factor) 份，<1 概率生。

## §2 5 类样本生成器（映射 MAformac 6 维度）

| 生成器 | pile | 产出结构 | MAformac 维度映射 |
|---|---|---|---|
| `generate_static_example`（:32-173） | specific_actions | 2 turn：response+[tool_call] → confirm | 明确指令 + 参数 |
| `generate_templated_example`（:181-368） | templated_actions | **多设备多 tool_call**（`device_type="light\|climate"` split），"and words" 拼接 | **多意图（同垂域多执行）** + 参数泛化 |
| `generate_status_request`（:370-466） | status_requests | **单 turn 无 tool_call**，从 prompt 里设备态读回答 | **状态感知读回**（查空调温度→读回） |
| `generate_tool_failure_example`（:468-561） | failed_tool_calls | **3 turn**：错设备 call+error(**train_on_turn=False**)→retry 正确设备→confirm | **错误恢复** |
| `generate_refusal_example`（:563-599） | refusals | 单 turn 无 call，`reason_type`: `already_state`(设备已在目标态→拒) / `not_available`(设备不在列表→拒) | **状态感知拒识**(关空调已关→"已经关了") + **OOD/不存在拒识** |

## §3 模板化算法（1 模板 → N 样本，泛化数据量来源）
`generate_static/templated_example` 里（:80-140, :276-353）：模板含 `<brightness>/<color>/<temp_f>/<temp_c>/<humidity>/<hvac_mode>/<fan_mode>/<duration>/<todo>` 占位 → `generate_random_parameter` 填随机值 → **同步替换 question + answer + tool_args 三处**。一条模板话术 + 随机参数 = 大量泛化样本。
→ MAformac：一条炸点说法模板（"空调调到\<温度>度"）+ 随机温度值/挡位/颜色/车窗开度 → N 训练样本。

## §4 distractor 设备（落域/消歧训练）`devices.py:250-308`
`random_device_list`：目标设备插进 2~max 个随机设备里（随机位置）→ 模型必须从一堆设备中挑对的（落域训练）。**相似度过滤**（:262 `SequenceMatcher ratio<0.4`）：distractor 不能和目标名太像（防混淆near-duplicate）。
→ MAformac：prompt 列全 cabin 设备，模型挑对的；distractor 不与目标混淆。

## §5 train_on_turn masking（只训正确 assistant 输出）`format_example_sharegpt:601-696`
每 message 带 `train_on_turn`：system/user=False，assistant=True，**但失败 turn=False**（`:542` 错误 call 那轮不训，只展示让模型学"恢复"不学"产生错误"）。训练配置 `roles_to_train: [assistant]`（runtime config 已见）。
→ MAformac C5：只训正确 ToolCall 输出；错误恢复样本里的"错误那步"masking 掉。**这就是 oracle 说的 Hammer/GOAT masking 思想的工程化**。

## §6 配比 factors（数据混比，`generate_data.py:850-863`）
| size | static | **templated** | status | refusal | failure |
|---|---|---|---|---|---|
| small | 1 | **10** | 8 | 3 | 1 |
| medium | 5 | **15** | 12 | 5 | 1 |
| large | 5 | **20** | 15 | 6 | 1 |
| xl | 7 | **25** | 18 | 8 | 2 |
→ **templated（参数/多意图泛化）权重最高(10-25x)** > status(状态读回 8-18x) > refusals(拒识 3-8x) > failures(错误恢复 1-2x) ≈ static。MAformac C5 数据混比直接参考。

## §7 device 抽象（= capabilities.yaml 结构）`devices.py:39-247`
`DeviceType` = `possible_states`(加权，如 light on/off 50/50、vacuum docked 60%) + `get_all_tools`(条件，light 有 brightness 才加 TOOL_LIGHT_SET) + `get_random_parameter`。复合态串（climate: `hvac;fan;temp;humidity`）。`SUPPORTED_DEVICES` dict 注册。
→ MAformac：cabin device = state-cells(加权初始态) + tools(条件) + execution_range/exp_step(params)。已有，对齐；可加"加权初始态"做数据生成。

## §8 LLM 增广 `synthesize.py`（896，摘要 from data/README）
`python synthesize.py --language X --model gpt-oss-120b --failed-tool-calls 25 --refusals 25 --actions 100`：调 LLM 生成新 pile 行，写回 per-language CSV。→ MAformac：用大模型从 3990 种子增广更多说法变体 + ASR-noisy 变体（对齐 ASR 研究的"音近增强双流"）+ refusals/failures 负样本。

## §9 MAformac C5 数据映射（直接套）
| home-llm | MAformac C5 数据源 | 动作 |
|---|---|---|
| pile_of_templated_actions | **3990 协议**（device×primitive×槽 + col23-25 L1/L2/L3 句式） | 模板化随机参数 → 泛化样本 |
| pile_of_failed_tool_calls | **12000 bug**（真实错误案例） | 错误恢复样本（train_on_turn=False 失败步） |
| pile_of_refusals (already_state/not_available) | **12000 bug**（状态拒识/不存在）+ raw | 拒识负样本（IrrelAcc≥20% gate） |
| pile_of_status_requests | state-cells + 协议 | 状态感知读回 |
| 模板化 + 随机参数 | exp_step/execution_range（18-32/1-10） | 参数泛化 |
| distractor + 相似度过滤 | 全 cabin 设备 | 落域/消歧 |
| train_on_turn masking | C5 训练 | 只训正确输出 |
| 配比 factors | C5 混比 | templated 最重 |
| ASR-noisy 增广（接 ASR 研究） | 音近变体 | 慢路鲁棒 |

## §10 home-llm 自承未做（TODO `:800-805`，MAformac 注意）
澄清/反问样本、非暴露服务拒识、随机化设备名、多 thing 同时状态、房间/组（"关厨房所有灯"）、时间/天气/日历。→ MAformac 的"澄清反问"（对齐拒识体系）home-llm 也没做，需自建。

## §11 元洞察（C5 配方）
让小模型可靠的训练数据不是"堆话术"，是 **5 类结构化样本（正例+状态读回+两类负例+错误恢复）× 模板随机参数泛化 × distractor 落域 × masking 只训对的 × 配比**。负例（refusals/failures）和 masking 是"防记死、会拒识、会恢复"的关键——正是 oracle 3 HIGH（防死记/防假提升/防手痒 IrrelAcc）的数据侧落地。

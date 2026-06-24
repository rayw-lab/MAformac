# L15 — home-llm 完整代码链路再 teardown（从代码链路学，非只学结论）

> 维度：home-llm 完整代码链路再 teardown（磊哥点名最大肩膀，端到端完整流程）。P1。
> 蓝本：`/Users/wanglei/workspace/raw/05-Projects/MAformac/ref-repos/home-llm`（acon96/home-llm，**1364★ / pushedAt 2026-06-11 / 139 forks**，>1000 不降级吸收）
> 本机 scout：mlx-lm **0.31.1** 已装（site-packages `~/Library/Python/3.13`）/ 内存 **32GB**（hw.memsize=34359738368）/ Python 3.13.13 / **无 N 卡**。
> 严守 Phase0 边界：纯搜证 + 假想验证 + 蓝本拆解，**绝不执行训练/真实评测/数据生成/voice/受限解码/runtime 改动**。治理类落 docs/research。

## 0. 核心结论（summary）

home-llm 完整链路再拆，揭示三个 **post-roadmap / MEMORY teardown 系列未覆盖** 的重大延伸：

1. **训练后端已迁移**：从旧自建 HF SFTTrainer/`train.py` → **Axolotl（Docker/k8s）+ Gemma-3-270m / FunctionGemma-270m 示例基座**。masking 从 `train_on_turn` 字段升级为 Axolotl `roles_to_train:[assistant]` + content-parts 双轨。MEMORY 记的 home-llm teardown 是旧后端时代，本拆解坐实新形态。
2. **数据链路是教科书级两阶段**：seed CSV piles → `synthesize.py`（LLM 填**种子**，structured response_format，bad_device 显式 mutation 策略）→ `generate_data.py`（**确定性 templating 展开**，`multiplier` 加权）→ distractor 设备/工具注入 → 5 类样本。这恰是 Web 多源（futureagi/premai 2026 guide）证实的 **seed→expand→distractor→validate** 最佳实践 = home-llm 作蓝本的**最强背书**。
3. **generic-tool surface = MAformac 0/34 的 generic frame**：home-llm 用 **19 个 generic intent 工具**（`HassTurnOn` 等，device 在 `name` arg）。它在 270m-1B 能 work 是因 **封闭词表小（19 工具/11 device type）+ 每例工具子集化收窄判定面 + 重 distractor/failure 训练**。MAformac 562 intent 砸 generic frame → 判定面爆炸 → **A2 改 D-domain 具名工具是正解**（Web 证实：Qwen3.5-2B BFCL 仅 43.6%，named-tool≈小标签空间分类 vs generic-tool≈组合 JSON 填充）。

---

## 1. 逐文件 file:line 拆解（端到端完整链路）

### 1.1 数据生成主控 `data/generate_data.py`（873 行）

**五个生成器**（对应五类样本）：
- `generate_static_example`（:32-173）：精确指令（service+device），单 toolcall + 双 turn（response_starting 带 call / final_answer 确认）。参数（温度/亮度/颜色/时长/todo）按 service_action 注入 tool_args。
- `generate_templated_example`（:181-368）：模板化多设备，支持 `<device_name1>`/`<device_name2>` 多意图，`and_words` 拼接多 answer，多 toolcall。
- `generate_status_request`（:370-466）：读回类，无 toolcall，answer 直接报状态（温度/湿度/亮度/颜色/音量/媒体/时长/剩余）。
- `generate_tool_failure_example`（:468-561）：**3-turn 失败恢复** —— 第一 turn 错误调用 `bad_device`（`train_on_turn=False`，loss-mask 防学坏调用）+ tool_results 真实 `MatchFailedError` → 第二 turn 重试正确 device → 第三 turn 确认。
- `generate_refusal_example`（:563-599）：拒识，单 turn 无 toolcall，按 `reason_type`（not_available / already_state）出拒绝话术。

**格式化** `format_example_sharegpt`（:601-696）：**content-parts 格式**（`content:[{type:text,text:...}]` per turn）+ **`train_on_turn` per-message masking**（system/user/tool/失败第一turn=False）+ tools=`HASS_TOOLS`(19) 或 `SERVICE_TOOLS`(37)。

**配比 per-size**（`generate_sft_file` :698-771 + main :850-863，本地实读）：
| size | static | template | status | refusal | failure |
|---|---|---|---|---|---|
| small | 1 | 10 | 8 | 3 | 1 |
| medium | 5 | 15 | 12 | 5 | 1 |
| large | 5 | 20 | 15 | 6 | 1 |
| xl | 7 | 25 | 18 | 8 | 2 |
（templated 最重，10-25x；这是 MEMORY 已记的配比，本拆解坐实当前值）

### 1.2 LLM 填种子 `data/synthesize.py`（896 行）

- LLM 端点（:14）`https://ai.cloud.alexoconnell.net/v1/chat/completions`，模型 gpt-oss-120b（OpenAI 兼容）。
- `_chat_completion`（:46-66）用 **structured response_format**（`{"type":"json_object"}`）保 schema。
- `generate_failed_tool_call_entry`（:277-331）：**bad_device 显式 mutation 策略** —— prompt 明令 "truncation, mutation, transposition, or inclusion of an extra suffix/prefix. **Avoid simple typos**"（:297），error_result 用真实 HA `MatchFailedError` 格式（:17-18,329）。
- `generate_refusal_entry`（:333-386）：双 reason_type（not_available / already_state），`_ensure_placeholder` 强保 `<device_name>` 占位（:374-376）。
- `sample_context`（:388-487）：混真实 piles + synthetic devices，per-domain service 表，light 30% 概率加 brightness/color（:470-478）。
- `_append_rows_to_csv`（:138-150）：LLM 产物**追加进 CSV piles，不直接产训练 jsonl** —— 关键：LLM 只填种子，确定性 templating 再展开，**避免 LLM 幻觉直接进训练集**。

### 1.3 评测 `train/evaluate.py`（368 行）

eval 口径（:141-206，本地实读）：
- **集合匹配**：toolcall 解析成 json → `json_output in expected_service_calls` → `.pop()`（集合精确匹配，:186-188）。
- **拒识=空匹配**：无 expected 且无 found → correct（:160-164）。
- **extra-response 陷阱**：无 expected 却 found → fail（:165-166，即"该拒不拒"= Web 证实的小模型头号失败模式）。
- **no_response_found**：有 expected 却无 found → fail（:169-171）。
- **invalid_json**：解析失败 → fail（:177-181）。
- **rgb 容差**：rgb 不等但其余等 → 计对（:189-199）。
- **逐 checkpoint**：`--all-checkpoints` 对每个 checkpoint 跑（:343-365）。
- 评测生成配置：max_new_tokens=128/temp0.1/top_k40/rep_penalty1.15（:296-307）。

### 1.4 工具表 `data/tools.py`（830 行）+ `data/devices.py`（308 行）

- **19 个 generic intent 工具**（HASS_TOOLS，python 实算）：HassTurnOn/HassTurnOff/HassToggle/HassSetPosition/HassLightSet/HassClimateSetTemperature/...
- `SERVICE_TO_TOOL_MAP`（tools.py:27-60）：**37 个 HA service 折叠到 19 个 generic 工具** —— `open_cover`→HassTurnOn / `lock`→HassTurnOn / `increase_speed`→HassTurnOn。**device 与 value 全在 arguments** = generic frame。
- **每例工具子集化**（devices.py `get_all_tools` per device_type，:49-234）：单例只暴露上下文出现的设备类型对应工具（去重），light 仅在有 brightness/rgb 时追加 HassLightSet —— **判定面从全集收窄到本例相关**。
- 三档 tool format（docs/Model Prompting.md:88-96）：Minimal（python 风格 `climate.set_hvac_mode(hvac_mode)`，最省 token）/ Reduced（name+desc+params）/ Full（OpenAI schema，默认）。

### 1.5 训练后端 `train/configs/gemma3-270m.yml`（Axolotl）

实测超参（本地 cat）：`learning_rate: 0.0002`(2e-4) / `num_epochs: 1` / `optimizer: adamw_bnb_8bit` / `warmup_ratio: 0.1` / `weight_decay: 0.0` / `sample_packing: true` / `sequence_len: 4096` / `gradient_accumulation_steps: 16`+`micro_batch_size: 1`(eff batch16) / `roles_to_train: [assistant]` / **全量微调（非 LoRA）**。chat_template 把 tools 渲染成 `name(param_keys): description` 单行。

### 1.6 utils.py 数据结构（259 行）

- `PileOfTemplatedActionType.multiplier`（:99-104）+ 加载时**物理复制行**（:170-182）= 加权采样实装。
- `PileOfRefusalsType`（:128-135）：`reason_type` + `desired_state`（双 reason）。
- `PileOfFailedToolcallType`（:118-125）：`error_result` + `retry_prompt`（失败恢复）。
- 种子池规模（本地 python 实算）：specific_actions 600 / templated 264（multiplier 1:176/2:20/8:68）/ status 272 / refusals **123（not_available 87 + already_state 36）** / failed 124 / personas 3（assistant/pirate/robot）/ 5 语言（en/fr/de/pl/es）。

---

## 2. 五类 → MAformac 四类完整 delta 表 + 工程智慧 adopt/adapt/drop

| home-llm 五类 / 工程智慧 | 机制（file:line） | MAformac 四类对应 | adopt / adapt / drop + 理由 |
|---|---|---|---|
| **static（精确指令）** | generate_static_example:32-173 单toolcall | positive（L1精确） | **ADOPT** 种子=D-domain 562契约,确定性展开 |
| **templated（多设备/多意图）** | :181-368 多toolcall+and拼接 | positive + followup(多意图) | **ADOPT** multiplier 加权;多意图对齐 MAformac 连续两句 splitter |
| **status_request（读回）** | :370-466 无toolcall报状态 | （readback 走方案P端renderer） | **ADAPT** MAformac C6 recovery 锁 readback 走端 renderer 不计 hard_pass;数据层可借状态报话术,但 surface 是端确定性生成非模型 |
| **failure（3-turn失败恢复）** | :468-561 第一turn train_on_turn=False + HA MatchFailedError | （错误恢复类待拍砍/纳入） | **ADAPT** 借 loss-mask 内核(防学坏调用),砍完整HA错误链→澄清式followup(demo轻治理);纳入与否=retrain-c5 propose 待拍 |
| **refusal（双reason）** | :563-599 not_available/already_state | unsupported + safety | **ADOPT** not_available≈unsupported(族外/设备不存在);already_state(已是目标态)MAformac 当前四类未显式覆盖→建议纳入 |
| train_on_turn loss-mask | format:634-639 per-message train flag | C5 masking | **ADOPT** → mlx-lm `--mask-prompt`(roles_to_train assistant≈mask-prompt) |
| multiplier 加权采样 | utils.py:170-182 物理复制 | C5 加权采样非笛卡尔积 | **ADOPT** 10族高频族(空调/座椅/车窗)加权;配比 C11-C12 hypothesis 待 spike |
| LLM填种子→确定性展开 两阶段 | synthesize.py→generate_data.py | C5 云generator | **ADOPT** 避免LLM直接产jsonl(C5 superaudit '0条自然中文'解药);云generator填D-domain自然中文种子+异源judge+契约定标签 |
| distractor 设备/工具注入 | random_device_list per example | C5 distractor | **ADOPT** 近似device + 族外工具作 distractor |
| 集合匹配+空匹配拒识+extra-response陷阱+rgb容差 eval | evaluate.py:141-206 | C6 four-layer 门 | **ADOPT** 强占优;extra-response 陷阱=抓小模型头号失败模式必含轴 |
| 逐 checkpoint 评测 | evaluate.py:343-365 | C6 / superaudit | **ADOPT** 对应 superaudit '所有checkpoint实测' |
| 每例工具子集化 | devices.py get_all_tools | （A2 D-domain 之外） | **ADAPT/标记** 运行时只暴露当前10族工具(retrain/runtime阶段,Phase0不碰contracts) |
| **19 generic intent 工具 surface** | tools.py + SERVICE_TO_TOOL_MAP | （A2 已迁 D-domain） | **DROP** = MAformac 0/34 根因,A2 D-domain 具名工具已替代,**绝不照搬** |
| Axolotl/CUDA/Gemma-270m 后端 | train/configs/gemma3-270m.yml | （MAformac 守 Qwen3-1.7B + mlx-lm） | **DROP 载体留配方** Mac无N卡;镜像masking/warmup/adamw 但 **LR 守 1e-4**(home-llm 2e-4 在270m全量可行,1.7B LoRA 会发散——MAformac实测过) |
| Gemma-270m 基座 | base_model: google/gemma-3-270m-it | （守 Qwen3-1.7B） | **DROP** 不同硬件/目标的合理分歧,非落后 |

---

## 3. 假想验证（磊哥点名重点）

**假想：把 home-llm 五类完整链路（含 Axolotl/Gemma 后端 + LLM 填种子 + generic-tool surface）原样搬到 MAformac 真实场景（1.7B+LoRA+D-domain 562 intent+端侧 8GB+mlx）会怎样？**

预测 = 【部分 better、关键 worse、surface 层 catastrophic】，分三层：

**(1) 数据链路（seed→templating expand→distractor→validate）→ better / 直接 adopt。**
依据：Web 多源（futureagi/premai 2026 guide）证实这正是教科书最佳实践，且 home-llm 在 270m 用纯合成数据能 work。MAformac D-domain 562 intent 契约 SSOT 天然是优质种子，multiplier 加权 + distractor 注入 + 集合匹配 eval 几乎零改可用。
失败模式：若直接照搬 home-llm 的 generic-tool **数据格式**（device 在 name arg），会重蹈 0/34。必须改成 D-domain 具名工具的样本格式（A2 已做 name=seed.intent）。

**(2) 训练后端（Axolotl/CUDA/Gemma-270m）→ worse / 不适用，drop 载体留配方。**
依据：本机 scout 坐实无 N 卡（32GB / mlx-lm 0.31.1 已装），Axolotl 要 CUDA。
失败模式：照搬 Axolotl=训不起来。修法：镜像其 masking 配方到 mlx-lm（roles_to_train:[assistant] ≈ `--mask-prompt`；warmup_ratio 0.1/adamw+wd support rank16Mainline），但 **LR 必守 MAformac 已踩坑的 1e-4**（home-llm 2e-4 在 270m 全量可行，1.7B LoRA 会发散——MAformac 本机实测 1e-4 iter30=1.069 vs 2e-4 iter80=32）。

**(3) generic-tool surface（19 generic intent 工具，device 在 arg）→ catastrophic 若照搬，但反向印证 A2。**
依据：Web 证实「1.7B 上 generic 单工具=组合 JSON 填充判定面爆炸，named-tool=小标签空间分类」（Qwen3.5-2B BFCL 仅 43.6%）；MAformac 0/34 正是 562 intent 砸 generic `tool_call_frame`。
失败模式：home-llm 工具少（19）+ 每例工具子集化所以 generic 行，MAformac 工具/intent 多照搬 generic 必爆。修法=A2 已做的 D-domain 具名工具（value 编码进名）；home-llm 的「每例工具子集化」是另一种判定面收窄手段，可作 A2 之外补充工程（端侧只暴露当前场景相关工具）。

**总判**：home-llm 是真蓝本，但要【借数据链路 + masking 配方 + eval 口径（adopt）】【改后端到 mlx-lm + 守 LR 1e-4（adapt）】【弃 generic-tool surface，A2 D-domain 已是正解（drop/印证）】。

---

## 4. Pre-mortem 三分类

### 🐯 Tigers（明确威胁 + 验证清单）
1. **照搬 home-llm generic-tool 数据格式（device/value 在 arguments）会直接重蹈 MAformac C5 0/34** —— 562 intent 砸 generic frame 判定面爆炸。home-llm 这套是它链路核心，最易被无脑 adopt。验证：grep MAformac C5 样本生成器确认 surface 已是 D-domain 具名工具（name=seed.intent，A2 PR#3 已迁）；任何借 home-llm generate_data.py 的样本格式时，核对 tool_call.name 是 D-domain 具名工具而非 generic HassTurnOn 形态；eval expected 也须 D-domain。Web 证实 Qwen3.5-2B BFCL 43.6% / named-tool≈小标签空间分类。
2. **照搬 home-llm Axolotl config 的 learning_rate=2e-4 到 MAformac 1.7B LoRA → loss 发散**（MAformac 已踩坑：峰值 LR 2e-4 过冲，本机实测 1e-4 iter30=1.069 vs 2e-4 iter80=32）。验证：任何引 home-llm 训练超参时，LR 必守 MAformac rank16Mainline 的 1e-4（grep C5LoRATraining.swift rank16Mainline）；warmup/adamw/weight_decay 可借（support）；epochs home-llm=1 vs MAformac=3，按 LoRA 收敛实测定。配方写任何数字前 grep MAformac 工厂方法 SSOT（claim-vs-reality §铁律1）。
3. **把 home-llm 失败恢复 3-turn（真实 HA MatchFailedError 错误链 + 第一turn loss-mask）完整搬进 MAformac demo → 过度工程化**（量产全链路形态进 demo，违 blueprint-teardown demo 双向冲动铁律）。验证：核对 MAformac demo 是否真需要完整 HA 风格失败恢复链；按"借可靠性内核(loss-mask 防学坏调用)+砍全链路(完整 HA 错误格式)"判：adapt 为澄清式 followup（端态 mock 判'设备不存在'→拒识/澄清）而非照搬 HA MatchFailedError；错误恢复类纳入与否是 retrain-c5 propose 待拍 hypothesis，非本调研拍死。

### 🐯📄 Paper-tigers（看似威胁实际安全 + 证据）
1. **「home-llm 100% 合成数据 → MAformac 也合成 → 必 model collapse 降 8-15%」**：Web（Characterizing Model Behavior Under Synthetic Data Training, arxiv 2510.05133）证实 >30% 合成数据降 8-15%、≤20% 安全 —— 但前提是【自由 LLM 生成的合成数据】会 collapse。home-llm/MAformac 的合成是【确定性 templating 展开真实种子（3990 协议/HA service）】，种子锚真实工程料、展开确定可控，不是 LLM 自由幻觉，collapse 风险被确定性 + 真实种子锚定大幅压低。home-llm 在 270m 用此法 work 即活证据。paper-tiger：不是「合成就 collapse」，是「自由 LLM 合成 + 无真实锚才 collapse」。
2. **「home-llm 迁到 Axolotl/Gemma-270m 意味着 MAformac 的 mlx-lm/Qwen3-1.7B 路线落后了」**：home-llm 换 270m 是为它自己「极致端侧轻量（270m 跑树莓派级）」目标；MAformac 北极星是 Mac+iPhone demo，1.7B 在 8GB 端侧可行（MEMORY 已锁 8GB≤2B），且 1.7B>270m 容量更适合 562 intent 泛化；后端 mlx-lm 是 Mac 唯一可行（无 N 卡）。两者是不同硬件/目标的合理选择，非落后。paper-tiger：不必因 home-llm 换基座而动摇 MAformac 已锁的 1.7B+mlx-lm。

### 🐘 Elephants（没人提但该提）
1. **home-llm 的 generic-tool surface 在 270m-1B【能 work】这件事本身，是对 MAformac 'generic frame 1.7B 学不会' 诊断的一个 confounder** —— 必须诚实承认：home-llm 证明 generic frame 在小模型【可以】work，只是需要【封闭词表小（19 工具）+ 每例工具子集化 + 重 distractor/failure 训练】三个前提。MAformac 0/34 的真因是【562 intent 砸 generic frame 判定面爆炸 + masking 446 假删 + train/eval surface 异源】，不全是 'generic frame 本身不行'。A2 D-domain 是正解，但 'generic frame 学不会' 的措辞应精确为 '未做判定面收窄（工具子集化/具名拆分）的 generic frame 在 562 规模学不会'。这个 nuance 若不点破，会让人误以为 generic frame 是绝对禁区（实际 home-llm 用得好好的）。
2. **home-llm 每例【工具子集化（get_all_tools per device_type + 去重）】是一个 post-roadmap/A2 都没显式提的判定面收窄手段** —— MAformac A2 已用 D-domain 具名工具收窄，但运行时是否对每个 demo 场景【只暴露当前 10 族相关工具子集】（而非全 191 device/全工具表）？若运行时仍暴露全工具，小模型每例判定面仍偏大。这是 A2 之外可叠加的工程（端侧 prompt 只渲染当前场景工具），值得 retrain-c5 / runtime 阶段考虑，但本调研 Phase0 边界=不碰 runtime contracts，只标记。
3. **home-llm 的 synthesize.py 用【外部 LLM 端点 gpt-oss-120b】填种子，MAformac C5 superaudit 已标 '训练集 0 条自然中文' 是北极星缺口** —— home-llm 的两阶段（LLM 填种子→确定性展开）正好是解药，但 MAformac 须确认【用云 generator 填 D-domain 自然中文种子 + 异源 judge + 契约定标签 + 原文 oracle 非训练集】（范式翻案 C1 四类数据已定此路线）。这条 home-llm 链路细节为 MAformac 的'云 generator 自然中文'提供了具体工程模板，但落地是 retrain-c5（DEFERRED 独立立项），本调研只供弹药。

---

## 5. must_answer 5 答

1. **prevents_0_34**：**yes**（反向印证 + 警戒方式）。坐实 home-llm generic-tool 能 work 的三前提，反推 MAformac 0/34 真因→A2 D-domain 正解（防再犯）；坐实 LR 2e-4 / 失败恢复完整链 / 100%合成 三个照搬会再炸的坑，供 propose gate 写防再犯条款。
2. **vs_rank16mainline**：**support**（主体）；局部 oppose 仅在 home-llm LR 2e-4（MAformac 已改 1e-4，须显式守 rank16Mainline）。masking/warmup0.1/adamw+wd/逐checkpoint eval/集合匹配全 support。
3. **requires_a2_surface_change**：**no** —— 反而支持/印证 A2 已完成的 D-domain 具名工具决策。generic-tool surface 不可照搬（会重蹈 0/34），A2 改 D-domain 正确。
4. **introduces_deferred**：**yes（标记不越界）** —— 失败恢复纳入/四类配比hypothesis/云generator自然中文种子/失败3-turn masking/工具子集化运行时实装 全属 retrain-c5/rebuild-c6/runtime（DEFERRED 独立立项）。本调研严守 Phase0=纯搜证+假想验证+蓝本拆解，只产 propose 弹药，治理类落 docs/research。
5. **priority_self**：**P1**（surface 教训 + model-collapse 警戒 + 数据链路蓝本，是 propose 弹药而非可直接阻止 0/34 的 P0 gate；A2 已做 surface 收窄，本路是巩固 + 延伸）。

---

## 6. 一手锚 + source 清单（版本/数字 cutoff 敏感，可复核）

- 本机蓝本：`/Users/wanglei/workspace/raw/05-Projects/MAformac/ref-repos/home-llm`（develop 分支，git log 最新 2026-06-04）
- gh 实查（2026-06-24）：star=1364 / pushedAt=2026-06-11T12:17:17Z / forks=139
- 本机 scout：mlx-lm 0.31.1 / 32GB / Python 3.13.13 / 无 N 卡
- WebSearch（2026-06-24）：huggingface.co/acon96/Home-FunctionGemma-270m / docs.axolotl.ai 几篇 / dev.to small-llm-fail-tool-calling / gorilla.cs.berkeley.edu BFCL V4 / github.com/MikeVeerman/tool-calling-benchmark / arxiv 2510.05133（model collapse）/ futureagi+premai 2026 synthetic data guide / github.com/ml-explore/mlx-lm LORA.md / techcommunity.microsoft.com fine-tuning-slm-function-calling（Qwen3.5 BFCL 数字二手转引，待主线程核）

> **防编造声明**：external_claims 段列出所有需主线程 gh/WebSearch 复核的精确数字/arxiv ID（尤其 Qwen3.5 BFCL 系列数字 + arxiv 2510.05133 是 WebSearch 二手转引，非官方页直读；本地 file:line 数字均 python/cat 实算可仓内复核）。
# hassil 蓝本 工程/算法 teardown — MAformac C4(上下文门 / 落域 / 拒识)直接抄的设计

> **缘起**：磊哥要求深扒 `OHF-Voice/hassil`（Home Assistant Intent Language 解析器，Apache-2.0，HA 语音助手 Assist 的规则 NLU 引擎本体）——MAformac **C4 三层路由**里 **L1 规则快路 + 意图收缩 + 落域(多轮锁域) + 拒识(ambiguous→unmatched)** 的现成工程蓝本。clone 在 `~/workspace/raw/05-Projects/MAformac/ref-repos/hassil`（CLAUDE §6：只读参考，不进仓）。
> **License**：Apache-2.0（宽松，可自由研究方法）。但仍遵项目红线——**只翻译设计思想为 Swift，不 import/不照搬代码**。Python `recognize.py` / `string_matcher.py` 的算法 → MAformac Swift `RuleRouter` / `ContextGate` 设计。
> **本文 = 上下文门 + 落域 + 拒识 + 确定性消歧逐文件拆**（带行号锚点）。
> **核心结论**：hassil 把"**多轮对话状态 = 一个 `intent_context` dict**"做到了极致——意图候选过滤、必需上下文校验、上下文拷成 slot、排他上下文，全部围绕这一个 dict 展开，**纯确定性、零模型、可证伪**。这正是 MAformac L1 规则路由该抄的：**落域/锁域不是隐式记忆，是显式 context 字典；安全是 excludes_context 这种代码门，不是 prompt**。另一半（`fuzzy.py` n-gram + `fuzzy_matching.md`）给 C4 的**消歧与拒识安全学说**——"两意图分数接近 → 判 unmatched"，正是车控不丢脸的防误触发护栏。

---

## §0 全局架构：hassil 是什么 + 它的"大脑 = 一个 context dict"

hassil 在 HA Assist 里是 **LLM 之前的规则 NLU 快路**（= MAformac L1）。输入一句话 + 一组 `slot_lists`（设备名/区域名/范围）+ 一个 `intent_context` dict → 输出 `RecognizeResult`（intent 名 + entities + 更新后的 context）。两条匹配通道：

1. **strict 模板匹配**（`recognize.py` + `string_matcher.py`）= L1 精确指令快路，模板穷举 + 确定性。
2. **fuzzy n-gram 匹配**（`fuzzy.py`，order-4 Kneser-Ney）= 模板外泛化兜底，**仍零神经网络**（统计语言模型）。

MAformac 对应：通道 1 = L1 规则快路（秒回不碰模型）；通道 2 的"多解 + slot 组合约束 + 拒识"思想 = 意图收缩/落域的设计参照（但 MAformac 用 LoRA 替代 n-gram 走慢路）。

**最关键的一眼洞察**：整个多轮/落域/锁域机制，没有任何"对话历史对象"、没有 session store、没有向量库——就是 **`intent_context: Dict[str, Any]` 一个普通字典**在 recognize 调用间传递。状态在调用方 code，hassil 每次 recognize 无状态。这与 home-llm "状态在 code，模型无状态" 同构，是 MAformac DialogueState 该守的纪律。

---

## §1 `recognize.py`（738 行）— 上下文门的全链路（本次深扒主锚点）

### §1.1 两阶段上下文过滤：先用 context **剪枝候选意图**（line 184-229）

`recognize_all` 在真正跑昂贵的 string 匹配**之前**，先用 `intent_context` 把不可能的意图剪掉：

- **关键词剪枝**（line 187-191）：`intent_data.required_keywords.isdisjoint(text_keywords)` → 句子里一个必需关键词都没有，整个 intent_data 跳过。**便宜的集合 disjoint 先行，贵的匹配后置**。
- **🔴 requires_context 预剪枝**（line 199-206）：`check_required_context(..., allow_missing_keys=True)`。注意 `allow_missing_keys=True` 的精妙——"context 可以在匹配中后续补充，所以现在只对**已存在的 key** 下结论"（line 196-198 注释）。即：**已知矛盾才剪，未知不剪**（保守剪枝，不误杀）。
- **excludes_context 预剪枝**（line 208-213）：已存在的排他 key 命中 → 直接跳过。

> **MAformac 抄点**：L1 规则路由分两阶段——(a) 廉价剪枝（关键词集合 + 当前域 context）先把候选规则缩到几条；(b) 再跑精确槽位匹配。`allow_missing_keys` 的"保守剪枝"是落域的灵魂：**当前在「空调域」，但 context 还没锁死域时，不要误杀跨域候选**。

### §1.2 🔴 `_copy_and_check_required_context`（line 517-626）— required context 拷成 slot（任务点名机制）

这是 hassil 落域/锁域的**核心算法**，也是任务明确点名要拆的"required context 拷成 slot"。逐分支拆：

**入口形态（line 524-542）**：`requires_context` 的每个 `(context_key, context_value)`。context_value 可以是裸值，也可以是 dict：
```
<context_key>:
  value: ...          # 要求的值（None = "只要有就行"）
  slot: true / "name" # 是否把这个 context 值拷成一个 slot；字符串 = 拷到不同名 slot
```
`copy_to_slot` 解析（line 534-540）：`slot: true` → 拷到同名 slot；`slot: "foo"` → 拷到 `foo` slot。

**实际值解包（line 544-552）**：从 `intent_context` 取 `actual_value`，若它是 dict 则解包出 `value`/`text`/`metadata`（context 值本身可带文本和元数据）。

**四种匹配判定 + 拷贝（line 554-604）**：
1. `allow_unmatched_entities` 且 actual 为空 → 去 unmatched_entities 里找补（line 554-561，错误恢复路径）。
2. **精确相等**（line 563-574）：`actual_value == context_value` → 若 `copy_to_slot` 则 `append MatchEntity(name=copy_to_slot, value=actual_value, text, metadata)`。
3. **存在即可**（line 576-587）：`context_value is None and actual_value is not None` → 任意值都算匹配，照样拷 slot。
4. **集合包含**（line 589-604）：`context_value` 是非字符串集合且 `actual_value in context_value` → 匹配 + 拷 slot。
5. **都不满足**：`allow_unmatched_entities` 时造一个 `UnmatchedTextEntity(MISSING_ENTITY)`（line 606-621，供错误提示）；否则 `return False`（line 622-624，**整个匹配作废**）。

> **🔴 MAformac 落域核心抄点**：这就是"**上下文(域/上一轮锁定的设备)直接变成本轮 ToolCall 的 slot**"的现成实现。场景：用户说「打开空调」→ context 写 `domain=climate, last_device=空调`；下一句「调高一点」→ 规则模板 `调高{delta}` 的 `requires_context: {domain: {value: climate, slot: true}}` 命中，**把 `domain=climate` 拷成 slot 填进 ToolCall**，无需用户重说"空调"。**这正是 D 系列"多轮锁域"的确定性实现，零模型**。MAformac Swift：`ContextGate.resolveSlots(rule, dialogueState) -> [Slot]`，把 DialogueState 里锁定的域/设备拷进 ToolCall slot。

### §1.3 排他门 = 安全护栏（line 387-394, 208-213）

`excludes_context` 在**两个时点**校验：候选剪枝时（§1.1）+ 匹配完成后再验一次（line 387-394 `_process_match_contexts`）。这是"**双重确认**"——预剪枝可能因 context 后续变化而失准，所以匹配完落地前**再过一次排他门**。

> **MAformac 抄点**：安全门(R0-R3 risk-policy / forbidden)是**代码门双查**，不是 prompt。`excludes_context` 的形态 = MAformac "**某状态下禁止某动作**"的声明式表达（如 `excludes: {gear: drive}` → 行车中禁开门）。**且匹配前剪 + 落地前再验 = MAformac DemoGuard 该有的"提交前最后一道门"**。

### §1.4 固定 slot + context slot 的合并顺序（line 417-428）

匹配成功后填 slot 的优先级（关键的"不覆盖"语义）：
1. 先收集文本里匹配出的 `entities`（line 418 建 `entity_names` 集合）。
2. **固定 slot**（line 419-423）：`intent_data.slots` 里写死的值，**仅当该名字没被文本匹配占用时**才加（`if slot_name not in entity_names`）。
3. **context slot**（line 426-428）：§1.2 拷出来的 `slots_from_context`，同样**仅当未被占用**才加。

> **MAformac 抄点**：slot 来源优先级 = **用户本轮明说 > 意图默认值 > 上下文继承**。immutable 累加、不互相覆盖（与全局 coding-style §Immutability 同源）。MAformac：本轮 ASR 听到的槽位 > 规则默认 > DialogueState 继承域，三层不打架。

### §1.5 🔴 `recognize_best` + `_get_result_score`（line 629-738）— 确定性消歧（不丢脸的根）

strict 匹配会产生**多个候选 RecognizeResult**（同句多模板命中）。`recognize_best` 是把多解收敛到一个的**纯确定性排序**，三级优先级：

1. **metadata 优先**（line 666-682）：带特定 `best_metadata_key` 的结果一旦出现，**清空之前所有非 metadata 结果**（line 679-681）→ 强信号一票否决弱信号。
2. **slot 质量优先**（line 684-707）：带目标 slot 且 slot 文本更长的胜（`slot_quality = len(entity.text)`，line 700），更长文本 = 更具体匹配。
3. **字面匹配最多**（line 712-738 `_get_result_score`）：三元组 `(num_wildcards, -text_chunks_matched, wildcard_text_len)` 升序排——**通配符越少 > 字面匹配越多 > 通配符吞的文本越少**。line 726-730 注释举例：`play track Yesterday` 应解析成 `media_class=track, query=Yesterday`，而非让通配符吞掉 "track"。

> **🔴 MAformac 抄点（不丢脸的根）**：当 L1 多条规则都命中，**用确定性 score 收敛，不掷骰子、不靠模型**。"字面匹配越多越优先 + 通配符越少越优先" = MAformac "**精确指令优先于模糊兜底**"的排序律。绑定到具体设备/槽的解析 > 让通配符/L2 吞掉 = L1 优先于 L2 的体现。**这是可单测的纯函数**（输入候选集 → 输出唯一胜者），MAformac 该照做：`RuleRouter.pickBest([Candidate]) -> Candidate` 纯排序。

### §1.6 wildcard/unmatched 收尾（line 362-385）

`_process_match_contexts` 收尾：把剩余文本灌进开放的 unmatched-entity 或 wildcard（line 364-381）。**未完全匹配（结尾还剩文本）→ `continue` 丢弃**（line 383-385）。

> **MAformac 抄点**：L1 规则**必须吃光整句**才算命中（`is_match` = 剩余文本去标点后为空，§3.1）。**剩字 = 不是干净 L1 命中 → 交给意图收缩/L2**。这是"多一字少一字靠泛化不靠堆规则"的执行端体现：L1 只接**严格干净**的命中，脏的下放慢路。

---

## §2 `string_matcher.py`（1037 行）— context 的产生侧 + 严格匹配引擎

`recognize.py` 是 context 的**消费侧**（§1）；`string_matcher.py` 是 context 的**产生侧**——匹配 slot 值时把值携带的 context 灌进 `intent_context`。

### §2.1 `MatchContext`（line 85-183）= 匹配期可变状态包

一个 dataclass 装着匹配进行中的全部状态：`text`(剩余待匹配文本) / `entities`(已匹配实体) / `intent_context`(line 95，**对内对外的 context 都在这**) / `text_chunks_matched`(line 110，字面匹配计数，喂给 §1.5 score) / `captures` 等。

- **🔴 `is_match` 属性（line 142-161）= 严格命中判据**：剩余文本去标点 strip 后**必须为空**（line 145-147）；且 wildcard 不能空（line 150-152）、unmatched 不能空（line 155-159）。**这是 L1"吃光整句"的硬定义**。
- `get_open_wildcard` / `get_open_entity`（line 163-183）：只看最后一个实体是否还开放 → 通配符是"贪婪但可被后续字面 chunk 截断"的。

### §2.2 🔴 slot 值匹配时的 context 注入 + 早剪枝（line 530-672）

匹配一个 `{list_name}` 时遍历 `TextSlotList.values`，每个候选值 `slot_value` 可带自己的 `context`（line 92-96 `TextSlotValue.context` = "命中此值则加入 context 的项"）。关键：

- **🔴 用 required/excluded context 早剪 slot 候选值**（line 544-558）：对每个候选值，先 `check_required_context(required, slot_value.context, allow_missing_keys=True)` 和 `check_excluded_context`——**值层面就过上下文门**，矛盾的值根本不进匹配。比在结果层面过滤更早、更省。
- **长度预剪**（line 560-564）：剩余文本比候选值文本还短 → 跳过（廉价剪枝）。
- **🔴 命中则 merge context**（line 635-655）：`intent_context = {**context.intent_context, **slot_value.context}` → **匹配一个 slot 值会把它的 context 灌进全局 context**。这就是 §1.2 消费的 context 的**来源**：上一轮匹配「空调」这个 name 值时，它的 `context: {domain: climate}` 被灌进 context，下一轮 requires_context 就能用。
- **value_out 映射**（line 620-623）：`slot_value.value_out` = 输入文本 → 输出值的归一化（「打开」「开」「启动」三个 text_in → 同一 value_out）。**= MAformac value 四件套的 in/out 归一化**。

> **🔴 MAformac 落域闭环抄点（这是最关键的横切）**：**"匹配设备名 → 该名字携带的 domain 灌进 context → 下一轮规则用 context 锁域拷 slot"** 构成 hassil 落域的**完整闭环**，全在 dict merge，零模型、零隐式记忆。MAformac：`Capability` 的每个 device 别名（text_in）带 `context: {domain, device_id}`，匹配命中即写 DialogueState，下一轮 `ContextGate` 读它锁域。**value 四件套（text_in / value_out / context / metadata）= TextSlotValue 的四字段（line 86-96）一一对应**——这是 C1 语义契约该抄的 slot 值数据形状。

### §2.3 范围 slot + 数字归一化（line 522-528 + intents.py RangeSlotList）

`{18..32:temperature}` 内联范围（`INLINE_RANGE_PATTERN`，expression.py line 10）+ `RangeSlotList`（intents.py line 50-79）带 `type(number/percentage/temperature)` / `step` / `multiplier` / `fraction_type(halves/tenths)`。`get_numbers`（intents.py line 70-79）按步长 + 分数枚举所有合法值。

> **MAformac 抄点**：空调 18-32℃ step 1 / 风量 1-10 档 / 车窗 0-100% step——**直接用范围 slot 表达，超范围 = 不在枚举 = 不命中 = 交澄清**（对齐 C2 execution_range 权威 + clarifyTag）。`fraction_type` 对应"调高半度"这类半档。**范围即白名单**：18-32 之外的温度天然落空，不需额外校验。

---

## §3 `intents.py`（498 行）— 声明式契约的数据模型（= MAformac C1 该长的样子）

### §3.1 `IntentData`（line 197-268）= 一个意图块的全契约

frozen dataclass（line 197 `@dataclass(frozen=True)` = immutable 契约）。字段即 MAformac C1 字段映射：
- `sentence_texts`（line 201）= 模板句（L1 规则语料）。
- `slots`（line 204）= 命中即假定的固定 slot（= 默认值）。
- `requires_context` / `excludes_context`（line 210-214）= **落域门 + 安全门**（§1 消费）。
- `expansion_rules` / `slot_lists`（line 216-219）= **局部**规则/列表（intent 内覆盖全局，line 215-223 of recognize.py 的 `{**global, **local}` merge）。
- `required_keywords`（line 228）= 廉价剪枝关键词。
- `metadata`（line 225）= 透传给结果（§1.5 消歧用）。

### §3.2 🔴 wildcard 句子排序（line 234-268）— 贪婪通配符的确定性

`sentences` cached_property（line 234-253）：解析后**按 `_sentence_order` 排序**——带通配符的句子里，**字面 chunk 多的先处理**（line 255-266，`return -text_chunk_count`）。注释举例（line 243-251）：`play {album} by {artist} in {room}` 排在 `play {album} by {artist}` **之前**，避免短模板的通配符贪婪吞掉 "in living room"。

> **MAformac 抄点**：规则模板装载顺序影响贪婪匹配 → **更具体（字面多）的模板优先**。这是 L1 规则集的**装载期确定性**保障，避免"打开主驾车窗"被"打开{x}"先吞。**契约 SSOT 派生规则时，按字面 chunk 数排序**。

### §3.3 加载 + 合并（line 312-409 `from_dict` / line 36-55 merge_dict）

`merge_dict`（util.py line 36-55）递归合并 YAML（dict 深合 / list 拼接 / 标量覆盖）→ 多文件契约可分片维护后合并。`from_dict` 把 YAML → 强类型对象。

> **MAformac 抄点**：契约可分片（airControl / carControl / cmd 三源各一文件）→ codegen 合并成单一 SSOT。`merge_dict` 的"list extend / dict deep-merge / scalar overwrite"语义 = 合并策略参照。

---

## §4 `util.py`（283 行）— context 校验纯函数 + 中文相关归一化

### §4.1 🔴 `check_required_context` / `check_excluded_context`（line 82-168）= 可单测的门函数

纯函数，无副作用。`check_required_context`（line 82-129）逐 key 校验，支持：dict 解包取 `value`（line 104-108）、集合包含（line 119-124 `actual_value not in required_value`）、`allow_missing_keys`（line 96-102 保守模式）。`check_excluded_context`（line 132-168）对偶——**命中排他值 → return False**。

> **MAformac 抄点**：上下文门 = **独立纯函数**（输入 context + 要求 → bool），与匹配引擎解耦 → **极易单测**（risk-policy / 落域门各写一组 table-driven 测试，对齐全局 testing 金融/安全 100% 覆盖）。

### §4.2 🔴 中文友好的标点/空白归一化（line 21-31, 68-74, 237-252）

- `PUNCTUATION_STR`（line 21）**显式含中文全角标点**：`。，？！；：` 等 → `remove_punctuation`（line 237-252）剥词首尾全角标点。
- `normalize_text`（line 68-74）：NFC unicode 归一 + 弯引号→直引号。
- `INITIALISM_DOTS_AT_END`（line 33）：保护 "A.C." 缩写的末尾点不被误删。

> **🔴 MAformac 抄点（中文 demo 关键）**：ASR 出来的中文常带全角标点/空格噪声，**L1 匹配前必须先归一化**（NFC + 去全角标点 + 折叠空白），否则"打开空调。"的句号会让严格匹配剩字而 miss。这是 §1.6 "吃光整句"的前置卫生。MAformac `TextNormalizer`：NFC + 全角标点剥离 + 空白折叠，**ASR→L1 之间必经**。

### §4.3 skip-words 的"双路尝试"（recognize.py line 142-160, 326-332）

去 skip-words（"请"、"帮我"、"ok"）后若文本变了，**同时保留带 skip-words 的原句一起尝试匹配**（line 326-332 `match_texts.insert(0, with_skip_words)`），且**字面原句优先**（注释 line 328-330："用户实际说的优先于被当填充词丢掉的"）。

> **MAformac 抄点**：客套词剥离要**可逆/双路**——"我想看电视"里"我想"是填充词，但"set the want to..."里 want 是真词。**剥了再匹配 + 保留原句也匹配，原句优先**。避免过度剥离误伤。

---

## §5 `fuzzy.py`(576) + `fuzzy_matching.md` — 模板外泛化 + 拒识安全学说（C4 消歧 / C7 ASR 的设计参照）

`fuzzy.py` 是 order-4 Kneser-Ney n-gram 统计匹配（**非神经网络**），把现有模板当训练料，匹配模板外的句子。MAformac 用 LoRA 慢路替代 n-gram，但 `fuzzy_matching.md` 的**学说**直接抄：

- **🔴 多解 + slot 组合约束剪枝**（doc line 28-49）：一句话生成多个 slot 填充解释 → 用"合法 slot 组合"+"实体域(domain)"剪掉不可能解。例：`{area}{domain}to{position}` 因 position 只对 cover/valve 有效而被剪。
  > MAformac：意图收缩时，**用 device×动作原语×槽三元的合法组合剪枝**（C1 契约里就有的三元约束）——"给座椅设温度"无效组合直接剪，不进慢路。
- **🔴 OOV 惩罚 + 判别词加权**（doc line 57）：词不在某 intent 词表 → OOV 惩罚；且**该词在别的 intent 里越常见，惩罚越重**（判别力强的词更该归对意图）。
  > MAformac：拒识打分时，**跨意图判别词**（"空调"几乎只属 climate）应强化归类，弱判别词（"打开"到处都有）不强归。
- **🔴 不丢脸的双护栏（doc line 61）= 车控防误触发的根**：
  1. **`{name}` 整句永远判 unmatched**——只有设备名、没有动词的句子，**绝不执行**。
  2. **两意图分数太接近 → 整句判 unmatched**——"避免 n-gram 微小概率差导致设备被开/关"。doc 原话举例 "garage door" / "the garage door" / "garage door the" 不该做不同的事。
  > **🔴 MAformac C4 拒识铁律抄点**：**置信接近 = 拒识澄清，不猜**。L2/慢路两个候选意图分数差 < 阈值 → 不执行，发 clarifyTag 问澄清（"您是要开空调还是开车窗？"）。**这是车控不丢脸/不误触发的算法级护栏**，比"模型大概率对"可靠得多。对齐 D37 clarifyTag + C2 safety。
- **skip/stop words 训练对齐**（doc line 63）：每个 n-gram 模型首尾埋 `<skip>` 特殊词，匹配时"请帮我"折成单个 `<skip>`；stop words("this"/"that")惩罚较轻。
  > MAformac：LoRA 数据也该埋客套词/口水词变体（对齐 teardown-data §5 templated 泛化），让慢路对填充词鲁棒。

---

## §6 cross-cutting pattern（横切设计思想 — 拆完才看见的真智慧）

1. **🔴 多轮 = 一个显式 context dict，不是隐式记忆**：落域/锁域/继承全靠 `intent_context` dict 在 recognize 调用间传递，hassil 本体无状态。→ MAformac DialogueState 该是**显式可序列化字典**，不是黑盒记忆；可打印、可单测、可在 trace 里看见。
2. **🔴 上下文是双向的：匹配产生 context（§2.2）→ 后续匹配消费 context（§1.2）**：匹配设备名灌 domain → 下轮规则读 domain 锁域拷 slot。**落域闭环全在 dict merge**。
3. **🔴 廉价剪枝层层前置**：关键词集合 disjoint（§1.1）→ context 预剪（§1.1）→ 值层 context 剪（§2.2）→ 长度剪（§2.2）→ 才跑贵的字符匹配。**最便宜的过滤器永远在最前**（= L1 秒回的工程基础）。
4. **🔴 安全/落域是声明式代码门，不是 prompt**：requires/excludes_context 是 YAML 声明 + 纯函数校验（§4.1），匹配前剪 + 落地前双查（§1.3）。
5. **🔴 多解收敛靠确定性 score，不靠模型/随机**：recognize_best 三级排序（§1.5）+ wildcard 句序（§3.2）+ fuzzy 双护栏（§5）全是可证伪的纯排序律。**"精确 > 模糊、字面多 > 通配符多、置信接近 → 拒识"**。
6. **🔴 in→out 归一化是契约一等公民**：TextSlotValue 的 text_in/value_out（§2.2）+ 范围 slot（§2.3）+ 中文标点归一（§4.2）——**模型/规则在表层别名工作，code 归一到机器值**（与 home-llm 双向单位归一化同源横切）。
7. **immutable 累加不覆盖**：slot 来源优先级（§1.4）、frozen IntentData（§3.1）、context merge 用新 dict（§2.2 `{**a, **b}`）——全程不就地改（对齐全局 coding-style）。

---

## §7 adopt / adapt / drop 映射 → MAformac C4(上下文门) 为主

| # | hassil 形态(file:line) | 动作 | 服务 C 层 | MAformac 落地 |
|---|---|---|---|---|
| 1 | `intent_context` dict 跨调用传递（recognize.py 80, MatchContext.intent_context 95） | **copy概念** | C4 | DialogueState = 显式可序列化字典，recognize 间传递，hassil 本体无状态 |
| 2 | `_copy_and_check_required_context` 上下文拷成 slot（recognize.py 517-626） | **copy概念** | C4 | `ContextGate.resolveSlots(rule, state)`：锁定的 domain/device 拷进 ToolCall slot，落域不重说 |
| 3 | requires/excludes_context 两阶段剪枝 + 落地双查（recognize.py 199-213, 387-394） | **copy概念** | C4 + C2(safety) | 上下文门匹配前剪 + DemoGuard 提交前再验；excludes = "某态禁某动作"声明 |
| 4 | `recognize_best` + `_get_result_score` 确定性消歧（recognize.py 629-738） | **copy概念** | C4 | `RuleRouter.pickBest`：精确>模糊、字面多>通配符多，纯函数可单测 |
| 5 | slot 值匹配灌 context（string_matcher.py 635-655）+ value_out 归一（620-623） | **copy概念** | C4 + C1 | Capability 别名带 context{domain,device_id}，命中写 DialogueState 形成落域闭环 |
| 6 | `is_match` = 吃光整句严格判据（string_matcher.py 142-161） | **copy概念** | C4 | L1 必须吃光整句才命中；剩字 → 下放意图收缩/L2 |
| 7 | check_required/excluded_context 纯函数（util.py 82-168） | **copy概念** | C4 + C6 | 上下文门为独立纯函数，table-driven 单测（risk-policy/落域门 100% 覆盖） |
| 8 | 中文全角标点 + NFC 归一（util.py 21-31, 68-74, 237-252） | **copy概念** | C7 + C4 | `TextNormalizer`：ASR→L1 间必经 NFC + 全角标点剥 + 空白折叠 |
| 9 | RangeSlotList 范围即白名单（intents.py 50-79）+ 内联 `{18..32}`（expression.py 10） | **copy概念** | C2 + C1 | 空调18-32/风量1-10/车窗0-100 用范围 slot；超范围天然落空→clarifyTag |
| 10 | wildcard 句子按字面 chunk 排序（intents.py 234-268） | **adapt** | C4 | 规则集装载按字面多优先，避免短模板贪婪误吞；codegen 派生时排序 |
| 11 | skip-words 双路尝试 + 原句优先（recognize.py 326-332） | **adapt** | C4 | 客套词剥离可逆：剥了匹配 + 原句也匹配，原句优先，防过度剥离 |
| 12 | fuzzy 双护栏：纯name判unmatched + 分数接近判unmatched（fuzzy_matching.md 61） | **copy概念** | C4 + C2 | 置信接近=拒识澄清不猜；纯设备名无动词绝不执行（车控不丢脸铁律） |
| 13 | fuzzy 多解 + slot 组合约束剪枝（fuzzy_matching.md 28-49） | **adapt** | C4 + C1 | 意图收缩用 device×原语×槽三元合法组合剪不可能解 |
| 14 | fuzzy OOV + 判别词加权（fuzzy_matching.md 57） | **adapt** | C4 | 跨意图强判别词强化归类；不靠 n-gram，思想移植到 LoRA/打分 |
| 15 | merge_dict 契约分片合并（util.py 36-55） | **adapt** | C1 | 契约三源分片维护，codegen merge 成单一 SSOT |
| 16 | fuzzy.py n-gram / Kneser-Ney / trie / FST 引擎本体（fuzzy.py, ngram.py, fst.py, trie.py） | **drop** | — | 统计 NLU 引擎整体不移植；MAformac 慢路用 Qwen3+LoRA。只借**学说**(#12-14)不借实现 |
| 17 | Python 运行时 / PyYAML / regex 引擎（全仓） | **drop** | — | Python 零进 iOS（CLAUDE 铁律）；翻译成 Swift 设计，非 import |
| 18 | filter_with_regex 把模板编译成正则预筛（recognize.py 231-259, expression.py 202-255） | **adapt** | C4 | 可选：L1 规则预编译成快速前筛器；但 demo 规则量小，未必需要，记为 backlog |

---

## §8 一句话

> hassil 教 MAformac 的不是"怎么匹配句子"，而是 **"多轮对话/落域/锁域/安全/拒识，全可以是一个显式 context 字典 + 一组纯函数门 + 确定性 score 排序——零模型、零隐式记忆、全可单测"**：上下文匹配时产生(设备名灌 domain)、下轮消费(域拷成 slot 不重说)，安全是 excludes_context 这种代码门、不是 prompt，多解靠"精确>模糊、字面多>通配符、置信接近就拒识"的可证伪排序律收敛。这正是 MAformac C4 L1 规则快路 + 落域 + 拒识不丢脸该长的样子——**而让它可靠的智慧(双向 context 闭环 / 廉价剪枝前置 / 拒识双护栏 / 中文标点归一)全在代码里、不在 README**。

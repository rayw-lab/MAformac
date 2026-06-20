# Teardown: pipecat-ai/pipecat — 服务 C7（对话上下文管理）

> blueprint-teardown（巨人肩膀深拆）。日期 2026-06-20。拆者：CC subagent。
> 参考仓只读：`~/workspace/raw/05-Projects/MAformac/ref-repos/pipecat`（**不进仓**）。License = BSD-2-Clause（宽松，但本拆**只抽设计思想译成 Swift**，不复制代码）。
> repo HEAD `6725945`（2026-06-19，1 天前，极活跃）；⭐ 量大、语音 agent 框架事实标准。

---

## 0. 缘起 / 为什么拆它（硬结论先行）

MAformac 是**单轮为主、车控 mock、纯端侧**的演示助手。pipecat 是**多轮、流式、可中断**的语音 agent 编排框架——表面上比我们重得多。但它在**「对话上下文怎么入史、怎么压缩、怎么在中断/函数调用未完成时保持一致」**这件事上，把所有「README 看不到、却让多轮语音 demo 不崩」的工程都写进了代码。这正是 MAformac C7（语音/对话回合）+ C3（执行契约层 DialogueState）会踩、但还没系统想清楚的坑。

**一句话**：pipecat 的 context aggregator 不是「数据结构」，是一套**「只把实际发生的事写进历史」的状态机**——中断只入已播出的、函数调用未回结果就不准压缩、stale 结果按 request_id 丢弃。MAformac 的 DialogueState 应该 adopt 这套**「实际播出才入史 + 未完成序列保护 + request_id 防错配」**的纪律，而**不是** adopt 它的 token 自动摘要/异步工具/多 provider 翻译那一层（演示 demo 用不上）。

**三个直接威胁我们 demo 的坑，pipecat 已给出解药**：
1. 用户在 TTS 播报到一半打断 → 历史里应只有「已说出的半句」，不是「模型生成的整段」。否则下一轮模型基于「它以为说了但其实没说」的历史推理，答非所问。
2. 函数调用（车控 ToolCall）刚发出、mock 结果还没回写，这时若做任何上下文裁剪 → 留下一个「孤儿 tool_call 没有 tool_result」→ 多数 chat 模板/API 直接报错或模型行为崩坏。
3. 异步动作（如「等空调降到 22 度」这类需要时间的）回来的结果，可能对应的是**上一轮**的请求 → 不校验 request_id 就把旧结果当新结果应用。

---

## 1. 摸规模 + 读序

| 文件 | 行数 | 角色 | 读序 |
|---|---|---|---|
| `aggregators/llm_response_universal.py` | 2179 | **核心状态机**（user/assistant aggregator + 函数调用生命周期 + 中断） | 1（先） |
| `utils/context/llm_context_summarization.py` | 642 | **压缩算法**（token 估算 + 未完成序列保护 + 消息选择） | 2 |
| `aggregators/llm_context_summarizer.py` | 477 | **摘要触发器**（双阈值 + stale guard + request_id 校验） | 3 |
| `aggregators/llm_context.py` | 527 | 上下文数据模型（消息/工具/截断大值） | 4 |
| `aggregators/gated_llm_context.py` | 77 | 上下文门（notifier 控制释放） | 5 |
| `aggregators/gated.py` | 86 | 通用帧门（open/close fn + system frame 永不阻塞） | 6 |

runtime/算法核心先，数据/门控后。下面逐文件拆到底。

---

## 2. 逐文件拆解（行号锚点）

### 2.1 `llm_response_universal.py` — 「只把实际发生的事写进历史」状态机

整个文件围绕一个原则：**上下文 = 发生事实的账本，不是模型意图的账本**。三个 class：`LLMContextAggregator`（基类）/ `LLMUserAggregator`（用户半）/ `LLMAssistantAggregator`（助手半），加 `LLMContextAggregatorPair`（成对工厂）。

#### 关键决策 A：助手聚合「流式累加 → 边界提交」，中断即提交已累加的（`_handle_text` L1894 + `_handle_interruptions` L1609 + `push_aggregation` L1563）

- 助手文本不是一次性写入，而是 `TextFrame` 逐帧 `_aggregation.append(...)`（L1911）。框架约定**把 assistant aggregator 放在 pipeline 的 `transport.output()` 之后**——于是只有**实际流过 output（≈ 实际播出）**的 TextFrame 才进 `_aggregation`。
- 中断来时 `_handle_interruptions`（L1609-1611）：先 `_trigger_assistant_turn_stopped(interrupted=True)` 把**当前已累加的**提交进 `_context.add_message({"role":"assistant","content":aggregation})`（L1571），再 `reset()`。
- **效果**：用户打断时，历史里只有「已说出的半句」，模型生成但没播出的尾巴**不入史**。`AssistantTurnStoppedMessage.interrupted`（L341）还标记了这次是否被打断，下游可观测。
- L1565-1566 防御：`if not self._aggregation: return ""` —— 中断在任何 token 之前到达（被秒打断）→ 提交空串而非崩。

> 🔑 **这是 MAformac demo 最该抄的一条**：方案经理现场连说两句、打断 TTS 是高频操作。若历史写的是「模型生成的整段」而非「实际播出的半句」，下一轮就基于幻觉历史推理。

#### 关键决策 B：函数调用生命周期——「未完成」用占位符显式占位（`_handle_function_call_in_progress` L1624）

发起一个 ToolCall（车控）时，**立刻**往上下文写两条：
1. `{"role":"assistant","tool_calls":[{id, function:{name, arguments}}]}`（L1630-1644）——记录「助手发了这个调用」。
2. **同步调用**：`{"role":"tool","content":"IN_PROGRESS","tool_call_id":id}`（L1650-1656）——一个**占位 tool 结果**。
3. **异步调用**（`cancel_on_interruption=False`）：写一个 `async_tool` started marker（L1648），结构 `{"type":"async_tool","status":"running",...}`。

结果回来时（`_handle_function_call_finished` L1777）：同步路径用 `_update_function_call_result`（L1996）**就地把 IN_PROGRESS 替换成真结果**；异步路径**追加**一条 finished developer 消息（不改原占位）。

> 🔑 **为什么是占位符而不是「等结果再写」**：保证上下文里 `tool_calls` 永远有配对的 `tool` 结果（哪怕是 IN_PROGRESS）。任何时刻做上下文截断/喂模型，都不会出现「孤儿 tool_call」。这是 chat 模板/FC 不崩的硬约束。MAformac 的 mock 车控也该这么做：发 ToolCall 立刻占位，mock state 回写时就地替换。

#### 关键决策 C：函数结果后「何时重跑推理」三态延迟（`_maybe_push_context_after_function_result` L1728）

收到 tool 结果不立刻重跑 LLM，而是三态判断：
- **还有同批结果排队**（`has_queued_frame(FunctionCallResultFrame)` L1739）→ 不推，等最后一个，**多结果合并成一次推理**（防 N 个工具回来跑 N 次 → N 段重复回复）。
- **bot 还在说话**（`self._bot_speaking` L1747）→ 置 `_push_context_on_bot_stopped_speaking=True` 延迟，等 `BotStoppedSpeakingFrame`（L1519）再推；多个结果在说话窗口内累积，**只推一次**。
- 否则立刻推（L1757）。
- 还有 `group_id` 兄弟调用全完成才重跑的逻辑（L1703-1712）。

> 🔑 **「合并多结果为单次推理」**直接对应 MAformac 多意图（「打开空调并升温」拆成两个 ToolCall）：两个 mock 结果回来应合并一次出 TTS，不是各回一句。

#### 关键决策 D：成对工厂 + 用户消息先于助手消息落史（`LLMContextAggregatorPair` L2090 + realtime flush L1867）

user/assistant 两半**共享同一个 `LLMContext`**（L2090 注释）。realtime 模式下助手 `LLMFullResponseStartFrame` 来时先 flush 配对的 user aggregator（L1867-1868），保证**用户消息在助手消息之前**进上下文（顺序正确性）。`_validate_realtime_pairing`（L1538）在 start 时校验配对一致，配置错直接 `RuntimeError` 早炸。

### 2.2 `llm_context_summarization.py` — 未完成函数调用序列保护（最精华算法）

#### 关键决策 E：压缩前扫描「未解析的函数调用」，在它之前停手（`_get_earliest_function_call_not_resolved_in_range` L420）

要把老消息压成摘要时，不能盲目切——若把一个 `tool_calls` 切进摘要、但它的 `tool` 结果留在「保留区」→ 孤儿，API 报错。算法：
- 扫 `[start_idx, summary_end)`，用 `pending_tool_calls: dict[tool_call_id, msg_index]` 跟踪（L448）。
- 见 assistant 的 `tool_calls` → 登记 pending（L461-468）。
- 见 `tool` 结果且**不是 pending 占位**（`_is_tool_message_pending` L391 判 `IN_PROGRESS` / async `started`）→ 出列（L473-480）。
- 见 developer 的 `async_tool status=finished` → 出列（L485-498）。
- 最后若还有 pending，返回**最早**那个的 index（L503-504）。

`get_messages_to_summarize`（L508）拿到这个 index 后**把 summary_end 退到它之前**（L558-566），「未完成的函数调用对永远不被压进摘要」。

> 🔑 **MAformac C3 DialogueState 若做任何「只保留最近 N 轮」裁剪，必须抄这条**：裁剪边界要避开「ToolCall 发了但 mock 结果还没回」的窗口。否则裁出孤儿 → 喂给 Qwen 的 chat 模板崩。

#### 关键决策 F：token 估算是纯字符启发式（L304-388）

`estimate_tokens = len(text)//4`（`CHARS_PER_TOKEN=4` L33），逐消息加 `TOKEN_OVERHEAD_PER_MESSAGE=10`（L34/L352）、图片 `IMAGE_TOKEN_ESTIMATE=500`（L35）、tool_calls 的 name+arguments（L372-382）。**不依赖真 tokenizer**——阈值检查/预算够用，注释明说「要精确用模型 tokenizer」（L312-313）。

> 🔑 端侧无 tokenizer 也能算「上下文大概多大」，纯字符比例，零依赖。MAformac demo 真要管上下文长度（多轮锁域累积）时可直接用。

#### 关键决策 G：保留首条 system + 最近 N 条（L532-577）

`summary_start = 1 if 首条是 system else 0`（L544）——**只有 messages[0] 当系统前导保留**，其它位置的 system 视为中途注入、纳入压缩（L532-535 注释）。`summary_end = len - min_messages_to_keep`（L547）保最近 N。重建 = `[system] + [summary] + [recent]`（summarizer `_apply_summary` L417-455）。摘要消息写成 **user 角色**（L447-448 注释：摘要是「给助手的上下文」不是「助手说的话」）。

### 2.3 `llm_context_summarizer.py` — 双阈值触发 + stale guard + request_id 校验

#### 关键决策 H：token OR 消息数双阈值，任一超就触发（`_should_summarize` L209）

`token_limit_exceeded`（`max_context_tokens` 默认 8000）**或** `message_threshold_exceeded`（`max_unsummarized_messages` 默认 20，L243 `messages_since_summary = len-1`）任一为真就触发（L257）。配置层 `__post_init__`（L150）强制「至少一个阈值非 None」，单 None 关掉那条。日志带「触发原因」（L263-269）。

#### 关键决策 I：request_id 防错配（stale summary guard）（`_handle_summary_result` L360）

摘要是异步的（可能用单独 LLM，L305）。每次请求生成 `uuid4` request_id（L286）存 `_pending_summary_request_id`。结果回来先比对（L374）：`if frame.request_id != self._pending_summary_request_id: 丢弃 stale`（L375）。**防止：上一轮请求的摘要结果，错配到这一轮上下文**。

#### 关键决策 J：应用前二次校验上下文未变（`_validate_summary_context` L394）

even 通过 request_id，应用前还检查：`last_summarized_index` 仍在范围内、保留区够 `min_messages`（L403-415）。摘要生成期间上下文可能被改（用户又说话了）→ 任一不满足就**跳过应用**（L387-389），宁可不压缩也不污染。

#### 关键决策 K：中断时取消进行中摘要，但保留 request_id 收尾（`_handle_interruption` L193）

中断把 `_summarization_in_progress=False`（允许新请求），但**保留** `_pending_summary_request_id`——因为 result frame 是 uninterruptible 的、还会到达，留着 id 才能正确丢弃/处理它（L196-200 注释）。

### 2.4 `llm_context.py` — 上下文数据模型 + 大值脱敏

- 通用格式（OpenAI 形状）作为「自有类型恰好与 OpenAI 重合」（L40-48 注释），各 provider 用 adapter 即时翻译。
- **关键决策 L：`_truncate_large_values_from_messages`（L281）** —— 日志/调试时把 base64 图片/音频替换成 `"data:image/..."` 占位、长字符串截断（L334 `_truncate_long_strings` max 100 chars）。`get_messages(truncate_large_values=True)`（L244）按需深拷贝脱敏，**不污染原上下文**（immutable 友好）。
- `LLMSpecificMessage`（L80）—— provider 专属消息（thinking block 等）用 `llm` 字段标记，`get_messages(llm_specific_filter=...)` 过滤掉不属于本 LLM 的（L266-274），过滤掉就 `logger.error` 报错（防误用）。
- 工具规范化 `_normalize_and_validate_tools`（L485）：list → ToolsSchema，空 → NOT_GIVEN，类型不对早 `TypeError`（L524）。

### 2.5 `gated_llm_context.py` + `gated.py` — 门控（背压/时序）

- `GatedLLMContextAggregator`（L14）：扣住 LLMContextFrame，**只保留最后一个**（L56 `_last_context_frame = frame` 覆盖式），notifier 触发才放（L74）。`start_open` 让首帧直通（L52）。用于「等某条件满足再让上下文进 LLM」。
- `GatedAggregator`（L20）：通用 open/close fn 累积帧。**关键决策 M：`SystemFrame` 永不被门阻塞**（L61-63）——控制类帧（中断/start/cancel）必须穿过，不能被业务门卡住。

> 🔑 「system frame 永不阻塞」是 MAformac barge-in 包裹层该守的纪律：打断信号不能被任何业务门/队列延迟。

---

## 3. Cross-cutting patterns（横切设计思想）

1. **上下文 = 事实账本，非意图账本**：只写「实际播出 / 实际发生」。中断只提交已说出的（A）、函数占位先于结果（B）。这是整个框架的灵魂。
2. **未完成序列保护贯穿始终**：函数调用发出即占位（B），压缩绕开未解析对（E），中断保留 request_id 收尾（K）。处处防「孤儿 tool_call / 半截状态」。
3. **异步结果按 id 防错配 + 应用前二次校验**：request_id（I）+ context 未变校验（J）。异步世界里「这个结果是不是我现在要的」要显式问两次。
4. **延迟 + 合并以避免重复推理**：多结果合并单次（C）、说话中延迟到说完（C）、最后一个兄弟调用才重跑（C）。
5. **早炸 + 显式校验**：配对不一致 RuntimeError（D）、工具类型不对 TypeError、过滤到不兼容消息 logger.error。配置/契约错在 start 就炸，不留运行时雷。
6. **零依赖估算 + 按需脱敏**：token 纯字符比例（F）、大值日志占位深拷贝不污染原数据（L）。端侧/调试友好。
7. **system frame 永不阻塞**：控制信号优先级高于业务门（M）。barge-in 必守。

---

## 4. adopt / adapt / drop 映射 → MAformac

| pipecat 形态（file:line） | 动作 | 服务 C 层 | 为什么 |
|---|---|---|---|
| 助手「流式累加→中断即提交已播出的」（A，response_universal L1609/L1894/L1563） | **copy概念** | C7+C3 | demo 高频打断；历史必须是「实际说出的」非「模型生成的」。译成 Swift：assistant turn 放 TTS 输出之后，interrupt 时把已发声片段写 DialogueState，丢未发声尾巴 |
| 函数调用「发出即写 IN_PROGRESS 占位，结果就地替换」（B，L1624/L1996） | **copy概念** | C3 | mock 车控发 ToolCall 立刻占位，mock state 回写就地替换 → 上下文永无孤儿 tool_call，喂 Qwen chat 模板不崩 |
| 压缩前「未解析函数调用序列保护」（E，summarization L420/L508） | **adapt** | C3 | 我们不做 LLM 摘要，但 DialogueState 若「只留最近 N 轮」裁剪，必须抄「裁剪边界避开 ToolCall 未回结果窗口」的扫描逻辑（pending_tool_calls dict）。adapt：去掉 async/developer 分支，留 tool_call↔tool_result 配对检查 |
| 多函数结果「合并为单次推理」+ group_id 兄弟全完成才重跑（C，L1728/L1703） | **adapt** | C3+C4 | 多意图（「开空调并升温」）两个 mock 结果合并出一次 TTS，非各回一句。adapt 成：同批 ToolCall 全部 mock 完成再触发慢路/回复 |
| request_id stale guard + 应用前 context 未变二次校验（I/J/K，summarizer L360/L394/L193） | **adapt** | C3+C7 | 异步动作（「等降到22度」）结果按 id 防错配到旧轮。adapt：DialogueState 给每个异步 mock 任务带 turn_id，回写前校验 turn 仍 active |
| token 纯字符估算 `len//4`+逐消息 overhead（F，summarization L304-388） | **copy概念** | C7 | 端侧无 tokenizer 也要知道上下文多大（多轮锁域累积）；零依赖直接用 |
| 大值日志脱敏深拷贝不污染原数据（L，context L281/L334） | **copy概念** | C3+C7 | trace 埋点（D1「LoRA Day1 埋 trace」）打 DialogueState 时，长 arguments/base64 截断成占位，原 state 不动（immutable 纪律） |
| 成对工厂 user/assistant 共享 context + 用户消息先落史（D，L2090/L1867） | **adapt** | C7 | 单个 DialogueState 被「理解侧写入用户话」和「执行侧写入助手/工具结果」共享；保证顺序 user→assistant→tool |
| system frame 永不被业务门阻塞（M，gated L61） | **copy概念** | C7 | barge-in 打断信号不能被任何队列/门延迟，控制帧优先级最高 |
| 配置不一致 start 时 RuntimeError 早炸（D，L1538/L150） | **copy概念** | C3 | 契约 SSOT 精神：配置/契约错在初始化就炸，不留运行时雷 |
| GatedLLMContextAggregator notifier 释放上下文（gated_llm_context 全文） | **drop** | — | 我们无「等外部条件放行上下文」的背压场景，单端侧单轮主导 |
| 异步工具 `async_tool` 三态消息协议（async_tool_messages.py） | **drop** | — | demo mock 车控基本同步即时回，无需长跑异步工具协议（真要等的「降到22度」用更轻的 turn_id 校验即可，见上 adapt） |
| LLM 自动摘要触发器整套（summarizer 触发→请求→应用闭环） | **drop** | — | 单轮为主 + 5 分钟 demo，上下文不会长到需 LLM 压缩；只取其「未完成序列保护」算法（E）+「id 防错配」纪律（I），不要触发器本体 |
| 多 provider universal context + adapter 翻译（context L40-48） | **drop** | — | 端侧单一 Qwen，无多 provider；统一 Tool schema 已由 C1 契约 SSOT 承担 |
| 图片/音频入上下文（context create_image/audio_message） | **drop** | — | demo 纯文本+语音指令，无多模态入史需求 |

---

## 5. 一句话

pipecat 的 context aggregator 教给 MAformac 的不是「怎么存对话」，而是**「上下文是实际发生事实的账本」这条铁律下的一整套防御**：中断只入已播出的、函数调用未回结果就占位/不裁剪、异步结果按 id 防错配——这三条**直接译成 Swift 进 DialogueState（C3/C7）**就能让多轮+打断+mock 车控的 demo 不崩；而它的 LLM 自动摘要/异步工具协议/多 provider 翻译那一层，对「单轮为主、5 分钟炸场」的演示助手是过度复杂度，**drop**。

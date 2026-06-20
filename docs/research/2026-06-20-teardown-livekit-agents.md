# livekit/agents 蓝本 工程/算法 teardown — 服务 MAformac C7（打断 + 短时上下文）

> **缘起**：磊哥要求按 blueprint-teardown（巨人肩膀深拆 8 步）深扒 `livekit/agents`（⭐ 高、活跃，2026-06-20 clone `--depth 1`）——MAformac **C7 voice（barge-in 打断 + 短时上下文/history）** 的成熟蓝本。clone 在 `~/workspace/raw/05-Projects/MAformac/ref-repos/livekit-agents`（CLAUDE §6：只读参考，**不进仓**）。
> **本文 = 打断 + 上下文层逐文件拆解**（带行号锚点）。LiveKit 是云端实时 SIP/WebRTC agent 框架，体量巨大（agent_activity.py 4072 行）；本拆解**只读 C7 相关锚点**（chat_context / speech_handle / agent_activity 的打断决策 + 上下文提交段 / turn 检测协议），不全读。
> **不降级吸收（磊哥铁律）**：LiveKit 的**设计形态/工程智慧全量吸收**，只 drop 真不适用载体（WebRTC/room_io 分布式实时栈、realtime server 端 truncate、RemoteChatContext 链表 diff 同步）。Python → 翻译成 Swift 设计思想，非 import。
> **核心结论**：让语音 agent「打断不崩、history 忠实、不被误打断」的可靠性**全在外围工程**——① 打断写史只写**已播出的那一截 + `interrupted=True`**（issue #3760 默认行为）；② **pause-not-kill + false-interruption timer**（误打断能 resume，不是一刀切 kill）；③ **min_duration + min_words 双门**防 VAD/单字误触发；④ **truncate 保 system + 不以 function_call 开头** + LLM 摘要压缩保结构项；⑤ **read-only chat_ctx + temp mutable copy + is_equivalent 失配护栏**。全是 README 看不到、拆到代码底才得的智慧。

---

## §0 一句话硬结论（给赶时间的未来 session）

MAformac C7 **直接抄三件套**：
1. **打断写史 = 已播出截断文本 + `interrupted` 标记**（不写完整生成文本）—— issue #3760 实证这是「对的默认」。
2. **DialogueState/VoiceTurnContext 用 LiveKit 的 ChatItem 五型 + `created_at` 时序插入 + `truncate(max_items)` 保 system 不以 fc 开头**。
3. **barge-in 决策门 = min_duration（VAD 时长）∩ min_words（STT 词数）双门**；首版按钮打断（D13）可先只抄「已播出截断写史」，VAD/词数门留 C7 第二刀。
**Drop**：WebRTC/room 实时栈、realtime server `truncate` RPC、RemoteChatContext 链表（这些是云端实时多端同步基建，MAformac 端侧单进程不需要）。

---

## §1 `llm/chat_context.py`（1008 行）— 短时上下文的事实源（C7/C4 直接映射）

MAformac 的 **DialogueState / 短时 history 合同**就该长这样。逐段拆：

### §1.1 ChatItem 五型（line 392-395）— 上下文不只是「消息列表」
```
ChatItem = ChatMessage | FunctionCall | FunctionCallOutput | AgentHandoff | AgentConfigUpdate
```
- `ChatMessage`（line 316-338）：`role`(developer/system/user/assistant) + `content` 列表 + **`interrupted: bool`（line 321，打断写史的关键字段）** + `transcript_confidence`（line 322，ASR 置信，可驱动澄清）+ `metrics` + `created_at`。
- `FunctionCall`（line 344-357）：`call_id` + `name` + `arguments`(str) + **`group_id`（并行工具调用分组）**。
- `FunctionCallOutput`（line 360-367）：`call_id` + `output` + **`is_error: bool`（错误结果回喂，呼应 home-llm `as_tool_messages`）**。
- `AgentHandoff`（line 370-375）：`old_agent_id → new_agent_id`，**多 agent/落域切换的史记项**（C4「分发垂域 + 多轮锁域」可借）。
- `AgentConfigUpdate`（line 378-389）：运行中改 instructions/加减 tools 也作为一条 ChatItem 入史 → **配置变更可追溯**。
- **判别器 `Field(discriminator="type")`（line 393）**：pydantic 按 `type` 字段反序列化 = 强类型上下文，不是裸 dict。MAformac Swift 侧 = enum with associated values。

### §1.2 `truncate(max_items)`（line 530-563）— 🔴 保 system + 不以 fc 开头（防御截断）
```python
def truncate(self, *, max_items: int) -> ChatContext:
    if len(self._items) <= max_items: return self
    instructions = next((item for item in self._items
        if item.type == "message" and item.role in ("system","developer")), None)  # line 541-548
    new_items = self._items[-max_items:]                                            # line 550 取尾 N
    while new_items and new_items[0].type in ["function_call","function_call_output"]:
        new_items.pop(0)                                                            # line 553-557 防半截 fc 开头
    if instructions and not any(item.id == instructions.id for item in new_items):
        new_items.insert(0, instructions)                                          # line 559-560 把 system 加回头
```
**三道防御**：① 保第一条 system/developer（不丢人设/安全约束）；② 取最近 N 项滑窗；③ **新窗口绝不以 `function_call`/`function_call_output` 开头**（否则 LLM 看到「孤儿工具输出没有对应调用」会崩/幻觉）。→ **MAformac DialogueState 裁剪必抄这三条**，尤其第③条是 home-llm「remember_num_interactions*2」没覆盖的边界。

### §1.3 `_summarize(keep_last_turns=2)`（line 739-864）— LLM 摘要压缩长 history
- **预算 walk-back**（line 750-764）：从尾倒走，只数 user/assistant ChatMessage 计入 `keep_last_turns*2` 预算；中间夹的 FunctionCall/Output **原样保留在尾部**（不打散工具调用对）。
- **结构项不被摘要吞**（line 842-850）：head 里的 system message / AgentHandoff / AgentConfigUpdate / **既有 summary（`extra.is_summary` 防摘要套摘要，line 777）** 全部 `preserved` 保留；只有可摘要的 user/assistant + fc 被替换成一条摘要。
- **XML 渲染喂摘要 LLM**（line 789-826）：`<user>…</user>` / `<function_call name=…>` / `<error>…</error>` 结构化喂给压缩 LLM，prompt 明确「把工具输出学到的*信息*蒸馏进摘要，别提调过工具」（line 816-817）。
- **摘要插回时序正确**（line 852-862）：`created_at_hint = tail[0].created_at - 1e-6`，保证摘要排在被压缩内容之后、尾部之前。
- → MAformac demo **短对话用不上 LLM 摘要（over-engineering，drop runtime）**；但「**结构项不被压缩 + 摘要标 `is_summary` 防套娃 + 时序插入**」的形态值得记，C7 第二刀若做长 session 再 adapt。

### §1.4 `_ReadOnlyChatContext`（line 923-948）— 🔴 防意外原地改史
```python
agent.chat_ctx → _ReadOnlyChatContext(self._chat_ctx.items)   # agent.py:163
# _ImmutableList: append=extend=pop=remove=clear=sort=reverse=__setitem__=...=_raise_error
```
暴露给开发者的 `chat_ctx` 是**只读包装**，任何 mutating 方法抛 `RuntimeError`「请用 .copy() + update_chat_ctx()」（line 926-929）。→ **直接落 coding-style.md 的 immutability 铁律**：MAformac DialogueState 对外只读，改史走 copy-on-write。

### §1.5 `find_insertion_index` + `insert`（line 453-459, 716-727）— 按 `created_at` 时序插入
倒序扫，找到第一个 `created_at <=` 目标的位置后插入 → **乱序到达的项（ASR 延迟出的 transcript、异步工具结果）也能按时间正确归位**。MAformac ASR 流式 transcript 异步落史时直接用。

### §1.6 `is_equivalent`（line 881-920）— 上下文等价比较（驱动投机执行护栏）
逐项比 id/type + 消息比 role/interrupted/content + fc 比 name/call_id/arguments + output 比 output/is_error，**忽略时间戳/metadata**。用途见 §3.4 投机生成失配检测。

---

## §2 打断的可靠性内核 —— §2.1 写史 / §2.2 SpeechHandle / §2.3 barge-in 决策门

### §2.1 🔴 issue #3760：打断只写「已播出的那一截」+ `interrupted=True`（C7 必抄）
**GitHub issue #3760 实证默认行为**（用户原话）：`session.say()` 允许打断时，用户打断 → **消息只把「已念出来的部分」加进 history**，不是完整生成文本。这是 LiveKit 的**默认设计**（用户当时觉得意外，但这恰是对的）。代码两条路径：

**Pipeline（STT-LLM-TTS，MAformac 主路径）—— `agent_activity.py:2573-2611`**：
```python
forwarded_text = text_out.text if text_out else ""                       # line 2574 默认=已转发文本
if speech_handle.interrupted and audio_output is not None:               # line 2575 被打断
    playback_ev = await audio_output.wait_for_playout()
    if (audio 已播首帧):
        if playback_ev.synchronized_transcript is not None:
            forwarded_text = playback_ev.synchronized_transcript          # line 2583-2584 用「实际播出对齐的转写」
    else:
        forwarded_text = ""                                               # line 2585-2586 没播出过=空，不写史
if forwarded_text and add_to_chat_ctx:
    msg = self._agent._chat_ctx.add_message(role="assistant",
            content=forwarded_text, interrupted=speech_handle.interrupted, ...)  # line 2604-2609 带 interrupted 标
    speech_handle._item_added([msg]); self._session._conversation_item_added(msg) # line 2610-2611 发事件
```
**关键智慧**：用 **`synchronized_transcript`（音频播放器回报的、真正播到用户耳朵的那截转写）** 写史，不是 LLM 生成的全文。→ MAformac mock TTS 也要回报「播到第几个字」，被打断时只把那截 + `interrupted=true` 写 DialogueState。**否则 history 会撒谎**（写了用户没听到的话，下一轮模型/澄清逻辑全错）。

**Realtime（speech-to-speech）路径 —— `agent_activity.py:3601-3629`**：`played ∈ {"skipped","partial",full}`；`partial → msg_interrupted=True`（line 3606）；若模型支持 `message_truncation`，调 server `truncate(audio_end_ms, audio_transcript=forwarded_text)`（line 3609-3616）**让服务端 KV/对话状态也对齐到用户实听位置**。→ server truncate 是云端特性，MAformac **drop**；但「partial 标记 + 截断到实听位置」概念 **copy**。

### §2.2 `voice/speech_handle.py`（292 行）— 打断的状态机 + 死锁/卡死护栏
- **打断 = future 置位（line 141-154, 211-216）**：`interrupt(force)` → `_cancel()` → `_interrupt_fut.set_result(None)`；`interrupted` 属性 = `_interrupt_fut.done()`（line 106-107）。**打断是一个不可逆信号位**，不是命令。
- **🔴 `INTERRUPTION_TIMEOUT = 5.0`（line 14）+ 兜底 arbitrary cancel（line 218-229）**：打断后若 speech 5s 内没正常收尾，强制 `task.cancel() + _mark_done()` → **任何卡住的语音任务都不会永久挂起**（demo 现场最怕卡死）。MAformac barge-in 包裹必抄这个超时兜底。
- **打断后不能反悔（line 127-130）**：已 interrupted 不允许把 `allow_interruptions` 设回 False。状态单调。
- **`_item_added` 回调扇出（line 239-247）**：写一条 ChatItem → 同步触发所有监听者（trace/UI 卡片刷新）。MAformac UI 卡片亮暗可挂这。
- **`wait_for_playout` 防循环死锁（line 156-182）**：在「拥有本 speech 的 function tool」内部 await 自己的 playout → 抛错（循环等待自检）。设计纪律级护栏。

### §2.3 🔴 barge-in 决策门 —— `agent_activity.py` 的 min_duration ∩ min_words 双门（防误打断核心）
**`on_vad_inference_done`（line 1919-1944）= VAD 时长门**：
```python
active_speech = ev.speech_duration >= options.interruption["min_duration"]   # line 1924 时长门
if active_speech and (turn_detection != "stt" or not stt_eos_received or ev.raw_accumulated_silence == 0):
    self._interrupt_by_audio_activity()                                      # line 1934 才触发打断
```
**`_interrupt_by_audio_activity`（line 1790-1854）= STT 词数门 + pause/interrupt 分流**：
```python
if stt and options["min_words"] > 0 and audio_recognition:
    text = audio_recognition.current_transcript
    if len(split_words(text, split_character=True)) < options["min_words"]:  # line 1808-1812 词数不够→不打断
        return
...
if self._pause_enabled():            # line 1837 可暂停→走 pause-not-kill（§2.4）
    audio_output.pause(); _update_paused_speech(...); _start_false_interruption_timer
else:
    self._current_speech.interrupt()  # line 1854 真打断
```
**双门智慧**：① VAD 说「有人说话超过 X 秒」（滤掉短咳嗽/碰撞）；② STT 说「转写出来够 N 个词」（滤掉「嗯/啊」单字 backchannel）。**两门都过才打断**。→ MAformac 首版按钮打断（D13）可不要这两门；但**做语音自动打断时必抄**，否则现场客户一个「嗯」就把 agent 打断了 = 丢脸。

### §2.4 🔴 pause-not-kill + false-interruption timer（line 1837-1849, 3820-3870）— 误打断能 resume
**最精妙的可靠性设计**：检测到疑似打断时**先 pause 音频**（不 kill），启 `false_interruption_timer`：
```python
def _on_false_interruption():                                    # line 3833
    if paused_speech is None or current_speech is not paused_speech.handle:
        return                                                   # 已有新语音→放弃恢复
    if resume_false_interruption and audio_output.can_pause and not paused_speech.handle.done():
        audio_output.resume(); resumed = True                    # line 3856-3857 恢复被误打断的语音
    emit("agent_false_interruption", AgentFalseInterruptionEvent(resumed=resumed))  # line 3860
```
若超时内确认用户**真的在说有意义的话** → 转真打断；若是误报（咳嗽/背景音/犹豫的「呃…」）→ timer 到点 **resume 原语音继续念**。→ 这是「快路径打断 + 慢确认回滚」的语音版。MAformac C7 第二刀（VAD 自动打断）该 adapt：**疑似打断先压低 TTS 音量/暂停，确认是有效指令再真停**，否则一刀切 kill 体验差。

---

## §3 上下文「更新完成」的语义 —— §3.1 history 暴露 / §3.2 提交时机 / §3.3 RAG 钩子 / §3.4 投机护栏

### §3.1 history 是 session 级单一事实源（`agent_session.py:565-566`）
```python
@property
def history(self) -> llm.ChatContext: return self._chat_ctx     # line 565-566
```
**单一 `_chat_ctx` 贯穿整个 session**（agent_session 持有），打断/工具/handoff 全往这一个 ctx 写。MAformac DialogueState 同样应是 session 单例。

### §3.2 提交时机（谁、何时往 history 写）
- **user 消息**：`on_user_turn_completed` 之后、调 LLM 之前提交（`agent_activity.py:2807-2809` 在 speech 真被调度后才 insert + 发 `conversation_item_added`）。**未真生成回复的投机用户消息不污染史**。
- **assistant 消息**：§2.1，**TTS 播完/被打断后**才写（写的是实播文本）。
- **closing 兜底**（line 2205-2207, 2239-2241）：session 关闭时即便跳过回复，也把 user 消息补进史 → 不丢转写。
- → 提交时机原则：**「已发生的事实」才入史**（用户实说的、agent 实念的），投机/未发生的不入。MAformac mock 闭环验收「读回 mock 态」同此哲学。

### §3.3 `on_user_turn_completed(turn_ctx, new_message)`（`agent.py:260-268`）— RAG / 改写注入点
开发者钩子：用户说完、LLM 还没应答的窗口，可**改写 new_message / 往 turn_ctx 注入检索结果**。MAformac 的「意图收缩澄清 / 落域上下文注入 / clarifyTag 旁路」可挂这个钩子（C4）。

### §3.4 🔴 temp mutable copy + `is_equivalent` 失配护栏（`agent_activity.py:2210-2268`）— 投机生成的正确性保证
```python
temp_mutable_chat_ctx = self._agent.chat_ctx.copy()              # line 2213 给钩子一份可改的副本
await self._agent.on_user_turn_completed(temp_mutable_chat_ctx, new_message=user_message)  # 钩子改副本
...
if preemptive := self._preemptive_generation:                   # 之前已投机起跑的回复
    if (preemptive.chat_ctx.is_equivalent(temp_mutable_chat_ctx) and tools 一致 ...):  # line 2248-2253
        speech_handle = preemptive.speech_handle                # 没变→用投机结果（省延迟）
    else:
        preemptive.speech_handle._cancel()                      # line 2268 钩子改了上下文→作废投机回复
```
**投机执行 + 校验回滚**：为省延迟提前起跑 LLM；若 RAG 钩子改了上下文/工具，`is_equivalent` 检出分叉就**作废投机结果重跑**，绝不用「基于旧上下文的抢跑回复」。→ 与 §2.4 同构（快路径 + 校验回滚）。MAformac 若做「规则快路 + 模型慢路并行抢跑」，这个失配护栏是防错答的关键。

---

## §4 turn 检测协议（`voice/turn.py:36-51`）— 语义端点 ≠ 静音端点
```python
class _TurnDetector(Protocol):
    async def predict_end_of_turn(self, chat_ctx, *, timeout=None) -> float: ...   # 返回 EOT 概率
    async def unlikely_threshold(self, language) -> float | None: ...
    async def supports_language(self, language) -> bool: ...
```
`TurnDetectionEvent`（line 22-33）带 `end_of_turn_probability` + **`backchannel_probability`（适不适合此刻插话）**。→ **端点检测是一个吃 chat_ctx 的语义模型，不只是 VAD 静音**（用户停顿 ≠ 说完）。MAformac demo 首版可只用 VAD 静音（轻），但 `EndpointingBackend` 协议形态值得照 `ASRBackend`/`LLMBackend` 抄（D14 抽象同源）—— 语义端点留二期。

---

## §5 Cross-cutting patterns（横切设计思想，跨文件提炼）

| # | Pattern | 在哪 | 一句话 |
|---|---|---|---|
| CC1 | **写史只写「已发生的事实」** | §2.1 #3760 / §3.2 | 打断只写实播文本、user 只写实说转写；投机/生成全文不入史 → history 不撒谎 |
| CC2 | **快路径动作 + 慢确认回滚** | §2.4 false-interruption / §3.4 投机 is_equivalent | 先 pause/抢跑（低延迟），慢确认错了就 resume/作废（不一刀切） |
| CC3 | **多门 AND 才触发不可逆动作** | §2.3 min_duration ∩ min_words | 打断 = VAD 时长门 ∩ STT 词数门，滤掉咳嗽/单字 backchannel |
| CC4 | **截断/裁剪带结构防御** | §1.2 truncate / §1.3 summarize | 保 system、不以孤儿 fc 开头、结构项不被压缩、防摘要套娃 |
| CC5 | **对外只读 + copy-on-write 改史** | §1.4 ReadOnly / §3.4 temp copy | 上下文对外只读，改走 copy + update，杜绝意外原地 mutate（immutability） |
| CC6 | **强类型上下文项（判别联合）** | §1.1 ChatItem 五型 | 史是 message/fc/output/handoff/config 五型联合，不是裸 dict；按 type 反序列化 |
| CC7 | **超时兜底防永久挂起** | §2.2 INTERRUPTION_TIMEOUT=5.0 | 打断后卡住的任务 5s 强制收尾 → 现场不死锁 |
| CC8 | **能力即协议（可换后端）** | §4 _TurnDetector / LLMBackend / ASRBackend | STT/EOT/LLM 全是 Protocol，端侧实现可换（同 MAformac D14 抽象） |

---

## §6 adopt / adapt / drop 映射（→ MAformac C7 为主，旁及 C4/C6）

> 见结构化 schema 的 `adopt_map`。要点：**copy概念**=思想直接落 Swift；**adapt**=形态借用但改实现；**drop**=云端实时载体不适用端侧 demo。

**最高优先三抄（C7 首版即用）**：
1. `interrupted` 标记 + 实播文本写史（#3760）→ DialogueState 打断写史合同。
2. ChatItem 五型 + truncate 三防御 → VoiceTurnContext / 短时 history 裁剪。
3. INTERRUPTION_TIMEOUT 超时兜底 → barge-in 包裹防卡死。

**C7 第二刀（语音自动打断时）**：min_duration∩min_words 双门 + pause-not-kill false-interruption resume。

**Drop（端侧 demo 不需要）**：WebRTC/room_io 实时栈、realtime server `truncate` RPC、RemoteChatContext 链表 diff 同步、`_summarize` LLM 摘要 runtime（短对话用不上）、preemptive 投机生成 runtime（demo 延迟够用，但 §3.4 的 is_equivalent 护栏思想留作 C4 并行抢跑参考）。

---

## §7 元洞察

README 给「LiveKit 是实时语音 agent 框架」；拆到底给「**让语音打断不崩、history 忠实的可靠性全在外围工程**」——`synchronized_transcript` 写实播文本、min_duration∩min_words 双门、pause-not-kill + false-interruption resume、truncate 不以孤儿 fc 开头、INTERRUPTION_TIMEOUT 兜底、is_equivalent 投机护栏——**没一条在 README，全在 voice/agent_activity.py 的打断分支里**。和 home-llm teardown 同结论：**让小组件可靠的不是模型/SDK 本身，是解析/归一化/截断防御/超时兜底/快慢路回滚这些外围工程**。MAformac C7 抄这些工程，比抄任何「打断 API 名字」都值钱。

> 拆解锚点文件（只读，不进仓）：`llm/chat_context.py`(1008) / `voice/speech_handle.py`(292) / `voice/agent_activity.py`(4072，只读打断+提交段) / `voice/agent_session.py`(1834，history/interrupt/say) / `voice/agent.py`(read-only ctx + on_user_turn_completed) / `voice/turn.py`(EOT 协议) / `llm/remote_chat_context.py`(链表 diff，drop) / GitHub issue #3760（打断写史默认行为实证）。

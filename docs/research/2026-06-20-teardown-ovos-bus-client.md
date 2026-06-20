# ovos-bus-client teardown — 生产级「每会话短时对话状态机」蓝本 → MAformac C4(结构化 session)

> **缘起**：磊哥要求深扒 `OpenVoiceOS/ovos-bus-client`（OVOS=Mycroft 继任的开源端侧语音助手生态的「神经系统」客户端，Apache 2.0，pushedAt 2026-05-24 活跃，⭐3 但是生产级核心组件——价值是**久经实战的 per-session 对话状态机范式**，非 star）。服务 MAformac **C4(三层路由 / DialogueState 贯穿 / 锁域多轮继承 / barge-in)**。clone 在 `~/workspace/raw/05-Projects/MAformac/ref-repos/ovos-bus-client`（CLAUDE §6：只读参考，不进仓）。
> **本文 = session 层逐文件拆解**（session.py 777 / message.py 456 / client.py 506 / collector.py 172 / waiter.py 65 全读，带行号）。Python/websocket runtime **drop**，**翻译成 Swift 设计思想**（非 import）。
> **核心结论**：ovos 的对话多轮可靠性来自一套**纯数据、可序列化、随每条消息传播的 Session 对象 + 单例 SessionManager 统一读写 + 显式 active_skills/utterance_states 状态机 + IntentContextManager 帧栈带时间衰减**——这正是 MAformac SRD 要的「**DialogueState 贯穿 + 锁域多轮继承 + is_speaking 驱动 barge-in + 端态自包含**」的**现成生产实现**，且印证「**对话状态在 code（确定性、可序列化），不在模型**」的架构铁律（SRD §5.1 实现回潮硬约束）。

---

## §0 一句话硬结论（先看这个）

| # | 让多轮对话可靠的核心设计 | MAformac 直接吸收为 |
|---|---|---|
| 1 | **Session = 纯数据 + 全程 serialize/deserialize**（无行为、无 LLM、无网络）| `DialogueState` 是 `Codable` struct，可存档/回放/喂模型 |
| 2 | **SessionManager 单例统一读写**（in-process，downstream 禁自持）| `DialogueStore` actor 唯一权威源，UI/路由/mock 都从它读 |
| 3 | **session 随每条消息 context 自动注入**（emit 时挂、on_message 时鲸吞）| ToolCallFrame/StateTransition/每轮都带 `state_revision` 快照 |
| 4 | **active_skills 栈 + 时间戳 = 锁域**（最近激活在栈顶，过期淘汰）| 多轮锁域：进空调域后「再高一点」锁在空调（passthrough）|
| 5 | **utterance_states(INTENT/RESPONSE) = 显式两态机**（谁在等用户回答）| 反问澄清（clarifyTag=ambiguous）的「等待回答」态 |
| 6 | **is_speaking/is_recording 由 record/audio 事件驱动**（状态由事件机驱动）| barge-in：TTS 播报中标 is_speaking，按钮打断读这个 |
| 7 | **IntentContextManager 帧栈 + TTL + 置信度按深度衰减 + 最新优先**| 短时上下文：指代继承「再高一点」拿上轮槽位，旧帧降权 |
| 8 | **TTL/expired() 软过期**（5 分钟超时清栈，但不删 session）| demo 5 分钟短场：超时清锁域上下文，避免串台 |
| 9 | **MessageWaiter「先挂监听再发」防 same-tick 丢回包**| 异步 mock 执行→读回态的请求/响应配对（防竞态）|
| 10 | **default session 命名空间保护**（只有 core 能改 "default"）| 单一 demo 主 session，防误改全局态 |

> **元洞察**：home-llm 教「让小模型可靠靠 code 工程（解析/归一化/白名单/预热）」；ovos-bus-client 教「**让多轮对话可靠靠 code 状态机（可序列化 Session + 单例读写 + 帧栈衰减 + 事件驱动状态位）**」。两者同源——**模型只产单跳，所有跨轮/编排/状态在确定性 code**。ovos 是这条铁律在**对话状态维度**的生产背书。

---

## §1 `session.py`（777 行）— 对话状态机心脏（C4 主蓝本）

### 1.1 `Session` 数据类（line 263-565）— 纯数据、全可序列化

- **构造即纯数据**（line 264-348）：所有字段是 str/list/dict/bool 基本类型，**无方法持有 LLM/网络/线程**。`session_id`(line 311) UUID，`expiration_seconds`(line 329) TTL（`-1`=永不过期）。
- **🔴 全程 serialize/deserialize**（line 441-534）：`serialize()` 产出「safe for json dumping」的纯 dict（注释 line 464）；`deserialize()` 静态重建。→ **session 可存盘、可传输、可回放、可 diff**。这是 MAformac「state_revision 快照 + trace 回放」的范式来源。
- **`active` 属性**（line 360-367）：`len(active_skills) > 0` → 「有没有技能正持有对话焦点」。MAformac 落域：「当前是否锁在某垂域」。
- **`touch()`**（line 369-374）：更新 `touch_time` **并写回 SessionManager**（`SessionManager.update(self)`）——**任何状态变更都刷新存活时间 + 回写单例**。状态变更与持久化耦合成一个动作（防忘写回）。
- **`expired()` 软过期**（line 376-382）：`now - touch_time > expiration_seconds`。注意 `from_message`(line 563) 见到过期只 **log 「unexpiring」不删**——**软过期**：过期触发清理逻辑但 session 对象仍在（避免多轮中途丢上下文炸掉）。

### 1.2 锁域状态机 = active_skills 栈（line 403-439）

- **🔴 `activate_skill`**（line 403-412）：**先 deactivate 再 insert(0)** → 「最近激活的永远在栈顶」。带 `[skill_id, time.time()]` 时间戳。
- `deactivate_skill`(line 414-423) / `is_active`(line 425-432) / `clear`(line 434-439)。
- **→ MAformac 锁域多轮继承**（SRD §3）：进入空调域 = `activate("aircon")` 推栈顶；「再高一点」省略说法 → 读栈顶域 = 空调（`passthrough`）。栈结构天然给「最近域优先 + 多域历史保留」。

### 1.3 反问澄清两态机 = utterance_states（line 387-401）

- **`UtteranceState` 枚举**（line 14-16）：`INTENT`（含 converse）/ `RESPONSE`。
- `enable_response_mode(skill_id)`(line 387-393) 标该 skill 为 `RESPONSE`（在等用户回答）；`disable_response_mode`(line 395-401) 恢复 `INTENT`。
- **→ MAformac**：clarifyTag=`ambiguous` 触发反问（「您是说主驾还是副驾车窗？」）→ 进 `RESPONSE` 态，下一句用户输入直接喂回澄清逻辑而非重新路由。**显式两态，不靠模型记得自己问过**。

### 1.4 状态位由事件驱动 = is_speaking/is_recording（line 747-773）

- **🔴 SessionManager 监听 recognizer/audio 事件改 session 标志位**：
  - `handle_recording_start/end`（line 747-759）→ `is_recording`
  - `handle_audio_output_start/end`（line 761-773）→ `is_speaking`
- **`wait_while_speaking(timeout=15)`**（line 680-713）：注册 `audio_output_end` 一次性监听 + `Event().wait(timeout)`，**按 session_id 过滤**（line 704-706 只有同 session 的 end 才 set）→ 等本会话播报结束。
- **→ MAformac barge-in**（D13 按钮打断）：TTS 播报时 `is_speaking=true`；用户按打断键 → 读 `is_speaking` 决定是「打断当前播报」还是「正常新指令」。**barge-in 判据是状态位不是 timer**。`wait_while_speaking` 给「等播报完再执行下一步」的现成范式（mock 多阶顺序播报）。

### 1.5 IntentContextManager（line 83-260）— 短时上下文帧栈（指代继承核心）

- **帧栈结构**（line 107）：`frame_stack: List[(IntentContextManagerFrame, timestamp)]`，新帧 `insert(0)`（line 188）→ 栈顶最新。
- **TTL 配置**（line 98-99）：默认 `context.timeout = 2 分钟`；`max_frames = 3`（line 104-105）→ 最多回看 3 帧。
- **🔴 `inject_context`**（line 165-190）：新实体进栈——**元数据匹配则 merge 进栈顶帧，否则新建帧**（line 183-188）。→ 同一话题的实体聚到一帧，话题切换开新帧。
- **🔴 `get_context` 置信度按深度衰减 + 仅取最新**（line 208-260）：
  - 只取**未过期**帧（line 223-224 `time.time() - frame[1] < timeout`）。
  - **`confidence / (2.0 + depth)`**（line 237-238）：越老的帧实体置信度越低——**时间衰减**，新上下文压过旧上下文。
  - `_strip_result`（line 192-206）：**每个 keyword 只留最新一个**（去重保最新）。
- **`merge_context`**（line 68-80）：append 实体 + 只补 metadata 缺的键（不覆盖已有）。
- **→ MAformac 指代继承**（SRD T7 坑：「再高一点」丢上文 = 66% 多步失败根因）：用户说「空调 24 度」→ inject `{device:aircon, temp:24}` 进帧；下句「再高一点」→ `get_context` 拿栈顶最新槽位补全成「空调温度调高」。**衰减 + 去重保最新** = 「同一槽位多次说以最后一次为准」的现成算法。

### 1.6 SessionManager（line 568-777）— 单例统一读写（唯一权威源）

- **类级单例**（line 568-573）：`sessions: Dict[str, Session]` + `__lock` + `default_session`。**downstream 禁自持 session**（docs/session.md 明示）——所有读写过 SessionManager 保进程内一致。
- **🔴 `get(message)`**（line 637-660）：从 message 取 session，非 default 的注册进 dict 返回；无 message/无 session context → default。
- **`update(sess, make_default)`**（line 617-635）：写回 registry。`make_default=True` 强制 `session_id="default"` 并提升为默认。**注释 line 629-631 安全红线**：`serialize()` 可能含密码/access key，**绝不 log session 全文**（被注释钉死防重新引入）——MAformac 同理：DialogueState 可能含车型/位置脱敏信息，trace 落盘要过脱敏门。
- **`from_message`**（line 536-565）：取 `message.context["session"]` 反序列化；缺失则 default + warn。
- **`default` 命名空间保护**（line 652 / client.py:225）：`"default"` 是 ovos-core 保留，**只有 core 能改**，其它 client 改了会被忽略。→ MAformac：demo 单主 session，防 mock/UI 误改全局态。
- **bus 同步**（line 575-590）：`connect_to_bus` 注册 recognizer/session 事件监听 + 立即 push default session。

---

## §2 `message.py`（456 行）— 状态随消息传播（context propagation）

- **🔴 session 不是带外存储，是挂在 message.context 上随消息流动**（docs/concepts.md:135「context 里最重要的字段 = session」）。
- **`dig_for_message`**（line 173-193）：**栈帧回溯**找最近的 Message 位置参数（line 185-192）——handler 没直接收到 Message 也能拿到上下文（用于 `Session.from_message` 兜底）。MAformac 不需要这种 Python 栈魔法（Swift 显式传参），**drop 实现、留思想**：「任何处理点都能拿到当前对话状态」。
- **`reply` / `forward` / `response` 自动保 context**（CollectionMessage line 300-352 / GUIMessage line 416-456）：
  - `forward`：deepcopy context 换 topic（**不改路由方向**）。
  - `reply`：deepcopy context + **source/destination 互换**（line 332-338）→ 回包知道发回给谁。
  - **docs/concepts.md:142「用 forward/reply，别手搓 context 传播」**。
- **`Message.publish` 已废弃**（line 71-116）→ 用 forward/reply。教训：**context 传播要走统一 API，手搓会漏字段**。
- **→ MAformac**：每个 `ToolCallFrame` / `StateTransition` 携带 `state_revision`（当时端态快照 id）。code 派生的 state features（comfort_state/active_zone/last_action）跟着每轮流转（SRD §12.1 C4「模型只看 code 派生 state features，非全量态自推」）。**reply 互换 source/dst** = mock 执行回包对应到发起的那次 ToolCall。

---

## §3 `client.py`（506 行）— 传播的执行边（drop runtime，留两个设计点）

- **🔴 emit 时自动注入 session**（line 246-249）：`if "session" not in message.context: message.context["session"] = sess.serialize()`——**开发者不用手挂 session，发消息时框架自动带上当前态**。这是「状态随消息走」零样板的关键。MAformac：路由层产 ToolCallFrame 时自动盖上当前 `state_revision`，业务代码不显式传。
- **🔴 on_message 时鲸吞 + default 保护**（line 213-228）：收到消息 → 反序列化 → `Session.from_message` → **非 default 才 update**（line 225）。→ 进站状态自动合并进单例，且全局默认态受保护。
- **websocket/AES 加密/重连**（line 41-211, 451-507）：**全 drop**（MAformac 无后端、无 websocket、纯端侧进程内）。AES 层本身已被原作者 deprecated（line 28-36 「key-setup 半边从未实现」）——**反面教训**：没做完的安全机制不如不做，留着是误导。
- **`collect_responses` / `on_collect` / `wait_for_*` 包装**（line 270-369）：见 §4。

---

## §4 `collector.py`(172) + `waiter.py`(65) — 请求/响应配对 + 多手柄汇聚

### 4.1 MessageWaiter（waiter.py 全文）— 单回包等待

- **🔴 「先挂监听再发消息」防 same-tick 丢回包**（构造即 `bus.once(msg, handler)` line 36-37；`wait(timeout)` 才阻塞 line 44）——docs/waiter_and_collector.md 明示：**先建 waiter 再 emit**，否则同 tick 回包会丢。`wait_for_response`(client.py:343-369) 已正确封装这个顺序。
- 超时清理监听（line 54-64）防泄漏。
- **→ MAformac**：mock 异步执行（改 state-cell + TTS 模拟）→ 读回态确认。「发 ToolCall 前先挂状态变更监听」防竞态（验收以读回 mock 态为准，铁律）。demo 多为同步可简化，但**异步多阶/语音链路**这个顺序是对的。

### 4.2 MessageCollector（collector.py 全文）— 多手柄 collect（demo 暂不需，留二期）

- **collect 协议**（docs/waiter_and_collector.md + line 68-166）：caller 带 `__collect_id__` 发查询 → 每个 handler 先回 `.handling` ack 注册（line 68-80）+ 算完回 `.response`（line 82-101）→ collector 等「至少 min_timeout、至多 max_timeout，每 ack 后续等」（line 142-166）。
- **🔴 `direct_return_func` 早返回**（line 41, 96）：任一回包满足条件（如 conf≥0.99）立即返回，不等齐所有 handler。
- `extend`(message.py:276) handler 可续时；`failure`(line 260) 可弃权。
- **→ MAformac**：一期单域 cabin.* **不需要多 handler 仲裁**（drop）。**二期 MCP 多域**（导航/音乐/外卖竞答同一句）→ 这套 collect + 早返回 + 超时仲裁是现成范式。**adapt 概念存档**，二期解冻。

---

## §5 Cross-cutting patterns（横切设计思想）

1. **状态即数据，行为在管理器**：`Session` 是哑数据（serialize/deserialize/字段），所有「怎么管生命周期」逻辑在 `SessionManager`（line 87 注释明示「生命周期管理不在 Session 里」）。→ MAformac：`DialogueState` 是 `Codable` struct（哑），`DialogueStore` actor 管转移/过期/锁。**数据可测可回放，逻辑可单测。**
2. **单一权威源 + 命名空间保护**：SessionManager 唯一读写口 + `default` 只有 core 能改。→ MAformac 唯一 DialogueStore + demo 主 session 保护（§7 单写者，对齐 codex-meta §7）。
3. **状态随载体传播，框架自动注入**：session 挂 message.context，emit 自动盖、on_message 自动吞。→ state_revision 跟 ToolCallFrame 走，业务不手传。
4. **时间衰减 + 软过期 + 最新优先**：帧置信度按深度衰减、TTL 清栈但不删 session、每 keyword 留最新。→ 短时记忆三件套（衰减/TTL/去重保最新）治指代与串台。
5. **事件驱动状态位**：is_speaking/is_recording 由 record/audio 事件机改，不靠轮询。→ barge-in/录音指示读状态位。
6. **显式小态机优于隐式**：UtteranceState 两态、active_skills 栈——**对话「现在该干嘛」写成显式枚举/栈，不靠模型/隐式约定记**。← 直接背书 SRD §5.1「编排/多步 state 必须在 code」。
7. **统一 API 防手搓漏字段**：reply/forward 自动保 context，publish 废弃。→ 状态传播走统一构造器，不散落手拼。

---

## §6 adopt / adapt / drop 映射 → MAformac C4（结构化 session）

| ovos-bus-client 设计 | MAformac 落点 | 动作 | C 层 | 为什么 |
|---|---|---|---|---|
| `Session` 纯数据 + serialize/deserialize 全程 | `DialogueState: Codable` struct | **copy概念** | C4 | 状态可存档/回放/喂模型/diff；trace 与 state_revision 的载体 |
| `SessionManager` 单例统一读写 + downstream 禁自持 | `DialogueStore` actor 唯一权威源 | **copy概念** | C4 | 进程内一致、单写者；UI/路由/mock 都从它读，防态分叉 |
| `active_skills` 栈（activate=先删再 insert(0) + 时间戳）| 锁域栈：最近垂域栈顶 | **adapt** | C4 | 多轮锁域继承（passthrough）；「再高一点」读栈顶域 |
| `utterance_states`(INTENT/RESPONSE) 两态机 | 反问澄清「等待回答」态（clarifyTag=ambiguous）| **adapt** | C4 | 显式记「我问过了，下句是答案」，不靠模型记 |
| `IntentContextManager` 帧栈 + TTL + 置信度按深度衰减 + 留最新 | 短时上下文：指代继承槽位补全 + 旧帧降权 | **adapt** | C4 | 治 T7 指代失败（66% 多步失败根因）；衰减/去重保最新是现成算法 |
| `is_speaking`/`is_recording` 事件驱动 + `wait_while_speaking` | barge-in 判据 + 多阶顺序播报等待 | **copy概念** | C4/C7 | D13 按钮打断读 is_speaking；mock 多阶等播报完再下一步 |
| TTL/`expired()` 软过期（清栈不删 session）| demo 5 分钟短场超时清锁域上下文 | **adapt** | C4 | 短场防上下文串台，又不中途丢 session 炸掉 |
| session 随 message.context 自动注入（emit 盖/on_message 吞）| state_revision 跟 ToolCallFrame 自动流转 | **copy概念** | C4 | 模型只看 code 派生 state features；业务不手传态 |
| `reply` source/dst 互换保 context | mock 执行回包对应发起的 ToolCall | **copy概念** | C3/C4 | 异步读回态配对到正确请求 |
| `default` 命名空间保护（只 core 能改）| demo 主 session 保护 | **copy概念** | C4 | 防 mock/UI 误改全局态 |
| `MessageWaiter`「先挂监听再发」防 same-tick 丢 | 发 ToolCall 前先挂状态变更监听 | **adapt** | C3/C4 | 异步 mock 执行→读回态防竞态（验收以读回态为准）|
| 安全红线：禁 log session 全文（密码/key）| DialogueState trace 落盘过脱敏门 | **copy概念** | C4 | 脱敏铁律（§6）；可能含车型/位置 |
| `MessageCollector` 多 handler collect + 早返回 + 续时仲裁 | 二期 MCP 多域竞答仲裁 | **adapt（二期）** | C4 | 一期单域不需要；二期导航/音乐竞答现成范式 |
| websocket / AES 加密 / 重连 / pyee EventEmitter | — | **drop** | — | 纯端侧进程内、无后端、无 websocket；AES 原作者已 deprecated |
| `dig_for_message` 栈帧回溯找 Message | — | **drop（留思想）** | — | Python 栈魔法；Swift 显式传参更干净 |
| OVOS pipeline 阶段列表 / blacklisted_skills/intents | demo 不需要复杂 pipeline 黑名单 | **drop** | — | demo 单一路由器，无多 skill 仲裁/黑名单治理 |

---

## §7 关键工程洞察（for C4 实装）

1. **「DialogueState 贯穿」有生产范式**：MAformac SRD 反复说「DialogueState/state machine 全在确定性 code」（§5.1 铁律），ovos-bus-client 是这条铁律在对话状态维度的**久经实战实现**——纯数据 Session + 单例 + 帧栈衰减。**不是赌，是抄成熟范式。**
2. **锁域 = 时间戳栈，不是模型记忆**：activate 先删再推顶 + 时间戳，天然给「最近域优先 + 历史保留 + 可淘汰」。MAformac「再高一点锁空调」直接用这结构，不靠 LLM 记得上轮聊空调。
3. **指代继承有现成算法**：帧栈 + 置信度按深度衰减 + 每 keyword 留最新 = 「同槽多次说以最后为准 + 旧上下文降权」。直接治 SRD T7（66% 多步失败=用未建立变量）。
4. **barge-in 判据是状态位**：is_speaking 由 audio 事件驱动 + wait_while_speaking 按 session 过滤。D13 按钮打断读状态位，不靠 timer 猜播报有没有结束。
5. **软过期不是硬删**：TTL 到了清上下文栈但保 session 对象（from_message line 563「unexpiring」）——5 分钟 demo 中途超时不会丢整个会话炸掉，只清锁域上下文。demo 健壮性细节。
6. **状态序列化 = trace/回放/state_revision 的地基**：Session 全程 serialize → MAformac state_revision 快照、LoRA Day1 埋 trace、C6 eval 的 expected_state_delta，全靠「状态可序列化」这个前提。ovos 印证这值得 Day1 就做对。
7. **安全：状态可能含敏感信息，禁全文 log**（line 629-631 被注释钉死）——MAformac DialogueState trace 落盘前过脱敏门（车型代号 private 可、PII/位置必脱）。这是「可序列化」的代价，要配套。

---

## §8 一句话

ovos-bus-client 给 MAformac C4 的不是代码（Python/websocket 全 drop），是一套**生产验证过的「对话状态在 code」的具体形状**——`DialogueState`(纯数据可序列化) + `DialogueStore`(单例权威源) + 锁域时间戳栈 + 指代帧栈(衰减/TTL/留最新) + 事件驱动 is_speaking(barge-in) + 软过期——把 SRD 写了一年的「DialogueState 贯穿 / 锁域多轮继承 / barge-in 包裹」从口号变成有成熟范式背书的工程清单，且与架构铁律「编排/多步 state 必须在 code，模型只产单跳」同源互证。

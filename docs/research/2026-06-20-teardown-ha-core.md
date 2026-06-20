# home-assistant/core 会话态 teardown — MAformac C7（DialogueState/会话态）蓝本

> **缘起**：深扒 `home-assistant/core`（⭐80k+，每周发版，2026-06 活跃），服务 MAformac **C7（会话态 / DialogueState）+ C4（三层路由）**。HA Assist 的语音助手栈是工业级「ASR→意图→TTS 多轮会话」参考实现，被 home-llm（已 teardown）作为承载平台 —— 即 home-llm 跑在 HA 这套会话态机制上。clone 在 `~/workspace/raw/05-Projects/MAformac/ref-repos/ha-core`（CLAUDE §6：只读参考，**不进仓**；Apache-2.0 但仍只抄设计思想、**翻成 Swift 不 import Python**）。
> **本文 = 会话态/路由层逐文件拆解**（chat_session/chat_log/models/pipeline + default_agent 路由缓存，带行号）。
> **核心结论**：HA 把「多轮会话」拆成 **三层正交对象**——`ChatSession`（生命周期+5min TTL）/ `ChatLog`（内容历史，4 种 Content 类型）/ `PipelineConversationData`（跨轮路由状态）；用 **conversation_id 一根线穿 ASR→意图→TTS**；用 **cleanup-callback 链** 让一个 TTL 到期级联释放所有派生态；用 **空轮回滚 + copy-on-write + 幂等重入守卫** 防会话历史损坏；路由是 **trigger→本地意图(规则)→LLM agent** 三层分诊 + **LRU 缓存 + 分级匹配**。逐条都是 MAformac C7/C4 该抄的工程，且印证「状态在 code、模型每轮无状态」架构。

---

## §1 `helpers/chat_session.py`（163 行）— 会话生命周期核心（最小最关键）

整个多轮会话的「容器 + 过期机制」只有 163 行，是 C7 的骨架。

- **🔴 5min TTL 常量**（line 28）：`CONVERSATION_TIMEOUT = timedelta(minutes=5)`。会话不靠「显式结束」靠「静默超时」——demo 友好（用户走开自动收尾，无须挂断按钮）。
- **`ChatSession` 数据类**（line 36-59）：只有 `conversation_id` + `last_updated` + `_cleanup_callbacks` 三字段。`async_updated()` 刷新时间戳；`async_on_cleanup(cb)` 注册清理回调；`async_cleanup()` 触发全部回调再清空。**= 一个会话 ID + 一串「我过期时该释放谁」的回调**。
- **🔴 惰性批量清理 `SessionCleanup._cleanup`**（line 93-109）：不是每会话一个定时器，而是**单个 `async_call_later`（TTL+1s）扫全表**，过期的 `del + async_cleanup()`；还有会话就再排一次（line 107-109）。注释 line 99-100 解释为何 mutate 原对象（当前命令可能正基于它 yield）。→ **O(1) 定时器开销，不随会话数膨胀**。
- **🔴 ContextVar 重入守卫 `async_get_chat_session`**（line 118-128）：用 `current_session` ContextVar 探测「已有活动会话」。若同 ID → 直接复用（**不刷新时间戳**，line 121-123）；若不同 ID → **强制开新会话**（line 125-128），注释解释：可能是「会话 agent 调工具、工具又在跟另一个 LLM 说话」——**防嵌套调用串台**。
- **🔴 ULID 防陈旧守卫**（line 142-151）：传进来的 conversation_id 若是合法 ULID（旧的）→ **生成全新 ULID**（line 147-149），表示「这是一段新对话」；若是用户自定义的非 ULID → 尊重它（line 150-151，用户想追踪一段长对话）。→ **「旧 ID 自动开新会话、自定义 ID 持续追踪」两套语义共存**。
- **退出时落表**（line 161-163）：context manager 退出 → 刷新 `last_updated`、写回 all_sessions、`schedule()` 排清理。

## §2 `components/conversation/chat_log.py`（785 行）— 会话内容历史 + 工具执行（C7 主体）

会话「记什么、怎么记、坏了怎么办」全在这。

- **🔴 4 种 Content 类型**（line 198-311，全 `@dataclass(frozen=True)` = 不可变）：
  - `SystemContent`（系统 prompt，role 固定 "system"）/ `UserContent`（用户话 + 可选 `attachments`）/ `AssistantContent`（`content` + `thinking_content`(剥<think>) + `tool_calls` + `native`）/ `ToolResultContent`（`tool_call_id` + `tool_name` + `tool_result`(JsonObject)）。每个带 `created` 时间戳 + `as_dict()`。
  - `type Content = 四者 Union`（line 311）。→ **会话历史 = 不可变 Content 的有序 list**，与磊哥全局「immutability」规则同构。
- **🔴 系统 prompt 永占 slot[0]**（line 339 默认 `[SystemContent(content="")]`；line 762 `self.content[0] = SystemContent(content=prompt)`）：历史无论怎么长，**索引 0 永远是 system**，刷新只替换 [0] 不丢。← 与 home-llm「截断保 system[0]」同源，HA 用「固定槽位」实现。
- **🔴 幂等重入去重**（line 82-96）：同 conversation_id 已活动 → 检查最后一条若不是「同样的 user 文本」才补加（line 89-93），**防同一句话被记两遍**。
- **🔴 copy-on-write 隔离**（line 106）：取已有 log 时 `replace(chat_log, content=chat_log.content.copy())` —— **复制 content list**，让并发命令不互相污染历史。
- **🔴 空轮回滚**（line 131-143）：context manager 退出时若「最后一条 still 是进入时的 last_message」（= 没产出 assistant 回复）→ **不持久化**，且若是新 log 还 fire DELETED 清理（line 136-142）。→ **失败/空转的轮次不留垃圾历史**。
- **🔴 continue_conversation 多语言启发式**（line 355-373）：最后一条 assistant 文本 strip 后以 `?` / Greek `;` / **中文 `？`** 结尾 → 返回 True（该继续听）。**内建中文问号识别** —— MAformac 直接受益。
- **`unresponded_tool_results` 守卫**（line 375-378）：最后一条是 tool_result → 有未回应的工具结果（防止半截轮次）。
- **🔴 工具执行 + 错误反馈**（`async_add_assistant_content` line 416-483）：
  - **并发起 task**（line 445-450）：所有非 external tool_call `async_create_task` 并发跑。
  - **逐工具 try/except → error 字典**（line 460-465）：`HomeAssistantError | vol.Invalid` → `{"error": type(e).__name__, "error_text": str(e)}`，包成 `ToolResultContent` 喂回历史（line 468-474）→ 模型下一轮能看到错误纠正。← 与 home-llm `as_tool_messages` 同源。
  - external tool 守卫（line 402-407）：`async_add_assistant_content_without_tools` 拒绝非 external 工具调用（边界检查在 code）。
- **流式增量装配 `async_add_delta_content_stream`**（line 485-623）：跨 delta 拼 content/thinking/tool_calls，遇 `role` key 收一条消息；**工具调用一知道就起 task**（line 530-539，不等整条消息完）。→ demo 非流式可大幅简化（home-llm teardown 已结论「demo 用非流式」）。
- **system prompt 组装**（`async_provide_llm_data` line 673-778）：prompt_parts = 指令 + api_prompt + （无 GetDateTime 工具时）日期时间 + extra_system_prompt，`"\n".join` 写进 [0]；记 `llm_input_provided_index = len(content)`（line 759，标记「LLM 数据从这条之后才算」）；写 trace（line 773-778）。
- **订阅广播**（line 37-68 + ChatLogEventType `CREATED/UPDATED/DELETED/CONTENT_ADDED/INITIAL_STATE`，const.py line 43-50）：会话态每次变更 fire 事件给订阅者（debug UI / trace）。← MAformac trace 可借这个事件模型。
- **⚠️ 注意：ChatLog 本身不截断历史**（无 max-history trim；截断留给各 LLM backend，如 home-llm 的 `remember_num_interactions`）。→ MAformac 在 backend 侧做「保 system[0] + 最近 N 轮」截断（沿用 home-llm 做法）。

## §3 `components/conversation/models.py`（107 行）— 会话 I/O 契约

- **`ConversationInput`**（line 22-71，`@dataclass(slots=True)`）：`text` + `context` + `conversation_id` + `device_id` + `satellite_id` + `language` + `agent_id` + `extra_system_prompt`。`as_llm_context()`（line 63-71）转 LLMContext。→ **会话入口的统一输入契约**（MAformac 对应「文本/ASR → 意图」入口 DTO）。
- **🔴 `ConversationResult`**（line 74-88）：`response` + `conversation_id` + **`continue_conversation: bool`**。→ 出口契约带「是否继续多轮」信号 —— 落域/多轮锁的关键返回值。
- `AbstractConversationAgent`（line 91-107）：`supported_languages` + `async_process(input)→result` —— **agent 抽象接口**（= MAformac `LLMBackend`/路由层应实现的协议形态）。

## §4 `components/assist_pipeline/pipeline.py`（2245 行，只读关键段）— conversation_id 穿 ASR→意图→TTS

- **🔴 单 session 绑定整条 pipeline**（`PipelineInput.session` line 1661）：一条 pipeline run 持一个 `ChatSession`，`execute()`（line 1688-1816）里 WAKE→STT→INTENT→TTS 全程用 `self.session.conversation_id`（line 1697-1701, 1797）。→ **一根 conversation_id 线穿全栈**。
- **🔴 三层分诊路由**（`recognize_intent` line 1235-1276，**= MAformac C4 三层路由的工业参考**）：
  1. **sentence_triggers**（line 1237-1249）：用户自定义整句触发，**最高优先**覆盖 LLM agent。
  2. **本地意图（规则 NLU）**（line 1262-1276）：`prefer_local_intents` 开关下先试 `async_handle_intents` —— 命中即 `processed_locally=True`、agent=HOME_ASSISTANT_AGENT。**= L1 规则快路**。
  3. **LLM agent 兜底**（line 1294-1306）：本地没命中才 `async_converse` 走 LLM。**= L2-5 慢路**。
  - **🔴 intent_filter**（line 1251-1259）：当 LLM 有 CONTROL 能力时，过滤掉「会干扰 LLM 的句子」再做本地匹配 —— **规则层主动让权给模型**（= MAformac「意图收缩」思想：NLU 弃权模糊说法）。
- **🔴 continue_conversation 落域机制**（line 1044-1058 + 1345-1346）：上轮若 `continue_conversation=True` → 存 `continue_conversation_agent`；**下轮 `prepare_recognize_intent` 直接锁到该 agent**（`_intent_agent_only=True`，line 1058），**跳过本地意图分诊**。→ **多轮锁域**（追问/澄清回合不再走规则快路，直奔上轮 LLM agent）。← MAformac「落域 + 多轮锁域」的现成实现形态。
- **🔴 wake-word 冷却去重**（line 1739-1757）：`WAKE_WORD_COOLDOWN` 内重复唤醒 → `DuplicateWakeUpDetectedError`。→ MAformac push-to-talk/barge-in 防双触发可借。
- **🔴 skip-TTS 延迟优化**（line 1800-1804）：无 speech 文本且无目标 → 直接 END 跳过 TTS。
- **🔴 acknowledge 媒体**（line 1808-1813 + `_get_all_targets_in_satellite_area` line 1350+）：所有目标都在本地区域 → 播一声「确认 beep」代替整段 TTS。→ **「执行成功但不必啰嗦」的低延迟反馈**（MAformac mock 车控「叮」一声 + 卡片亮 可借）。
- **🔴 流式 TTS 阈值**（line 1155-1207）：累计字符 > `STREAM_RESPONSE_CHARS` 或「已有文本又来工具调用」才启动流式 TTS（短回复不流式、可缓存）。
- **🔴 cleanup-callback 链**（`PipelineConversationData` line 2214-2245）：跨轮路由态（`continue_conversation_agent`）挂 `session.async_on_cleanup(do_cleanup)`（line 2242）。→ **5min TTL 一到，级联释放 chat_log + pipeline 路由态**，一个生命周期管所有派生态。

## §5 `components/conversation/default_agent.py`（1733 行，只读路由/缓存段）— 规则 NLU 层（C4 L1 参考）

- **🔴 LRU 意图缓存 `IntentCache`**（line 156-186，capacity=128）：`OrderedDict` 实现 LRU（`move_to_end` + `popitem(last=False)`）。`IntentCacheKey`=（text+language+satellite_id）（line 131-142），`IntentCacheValue`=（result + **stage**）（line 145-153）。意图变更时 `clear()`（line 266-267）。→ **重复的 L1 指令秒回（命中缓存不重算）**。
- **🔴 分级匹配 + 缓存短路 `_recognize`**（line 628-756）：三阶 escalation，每阶单独缓存：
  1. `EXPOSED_ENTITIES_ONLY`（line 658-679）：只匹配「暴露给语音的实体」，strict，最快；命中即返回。
  2. `UNEXPOSED_ENTITIES`（line 698-728）：扩到全部实体（含未暴露），用于「该设备存在但没暴露」的报错。
  3. `UNKNOWN_NAMES`（line 730-749）：连名字都不认识 → best-guess/报错。
  - **缓存记录命中阶段**（line 647-656 等）：上次在某阶失败的 key，重试时**直接跳过该阶之前的所有阶**（`skip_exposed_match`/`skip_unexposed_entities_match`）。→ **「失败也缓存」省重复计算**。
- **slot-list 失效监听**（line 294-317）：实体/区域/暴露状态变化 → `_async_clear_slot_list`（缓存的可匹配名单失效重建）。→ MAformac mock 态变化时，L1 可匹配设备名单应同步失效。
- **trie 过滤暴露名**（line 335-341）：`_exposed_names_trie.find(text)` 先用前缀树筛出输入里出现的实体名，缩小 slot list。→ **大词表下的快速候选缩减**（MAformac 全集设备名匹配可借）。
- **trigger > 意图 分诊**（`_async_handle_message` line 431-449）：先试 sentence_trigger，再试意图 —— 与 §4 pipeline 层分诊一致（双层都先 trigger）。

---

## §6 cross-cutting pattern（横切设计思想）

1. **三层正交对象拆会话态**：`ChatSession`（生命周期/TTL）⊥ `ChatLog`（内容历史）⊥ `PipelineConversationData`（跨轮路由态）。各管一摊、用 conversation_id 关联、用 cleanup-callback 链聚合。→ MAformac C7 的 DialogueState **别做成一个大对象**，拆这三层。
2. **conversation_id 是唯一关联键**：一根 ULID 线穿 ASR→意图→TTS→工具→历史→trace；所有跨轮状态都挂这个 key 上的 dict。
3. **状态在 code、模型每轮无状态**（与 home-llm 同结论）：历史/路由态/落域全在 HA 这层维护，LLM 每轮收完整 prompt（system[0] + 历史 + 当前），无内部记忆。
4. **生命周期单点 + 级联释放**：唯一 5min TTL 定时器 → cleanup-callback 链 → 所有派生态自动释放。**不给每种态各写一套过期逻辑**。
5. **防御性会话写入**：幂等去重（防重记）+ copy-on-write（防并发污染）+ 空轮回滚（防垃圾历史）+ ContextVar 重入守卫（防嵌套串台）。→ 让「多轮历史」这个共享可变态可靠。
6. **分级路由 + 失败缓存**：trigger → 规则快路 → LLM 慢路；规则层分 exposed/unexposed/unknown 三阶，每阶缓存（含失败阶），重复指令秒回。
7. **不可变内容 + 固定系统槽**：Content 全 frozen dataclass；system 永占 [0]，刷新替换不丢；与磊哥 immutability 规则同构。
8. **延迟优化三件套**：wake 冷却去重 / skip-TTS / acknowledge-beep —— 「不必要的环节直接跳，成功执行用最轻反馈」。

---

## §7 MAformac adopt / adapt / drop 映射（→ C7 会话态 / C4 路由）

| ha-core 工程（file:line） | MAformac 形态 | 动作 | 服务层 |
|---|---|---|---|
| 三层正交：`ChatSession`/`ChatLog`/`PipelineConversationData`（chat_session.py L36 / chat_log.py L333 / pipeline.py L2214） | `DialogueState` 拆 3 子对象（会话生命周期 / 内容历史 / 跨轮路由态） | **copy概念** | C7 |
| 5min TTL + 惰性批量清理（chat_session.py L28,93-109） | 会话静默超时自动收尾（无挂断键），单定时器扫表 | **adapt**（Swift `Task`/`DispatchSource` 等效；demo 可调短） | C7 |
| cleanup-callback 链级联释放（chat_session.py L49-59 + pipeline.py L2242） | 一个 TTL 到期级联清 history+路由态 | **copy概念** | C7 |
| 4 种 frozen Content + system 永占 slot[0]（chat_log.py L198-311,762） | `DialogueTurn` enum（system/user/assistant/toolResult），system 固定首位 | **copy概念**（Swift enum + struct，immutable） | C7 |
| 幂等去重 + copy-on-write + 空轮回滚 + 重入守卫（chat_log.py L82-143 + chat_session.py L118-128） | 会话写入防御：去重/隔离/回滚/防串台 | **copy概念**（小模型畸形/并发更需要） | C7 |
| continue_conversation 中文 `？` 启发式（chat_log.py L355-373） | 助手回复以 `？` 结尾 → 自动续听 | **直接抄**（中文问号已内建） | C7 |
| 工具执行 error→`{"error":type}` 喂回历史（chat_log.py L460-474） | DemoGuard 工具失败 → error 帧回历史，下轮可纠正 | **copy概念**（= home-llm `as_tool_messages` 二次印证） | C3/C7 |
| 三层分诊 trigger→本地意图→LLM（pipeline.py L1235-1306） | C4 三层路由：规则快路 → 意图收缩 → Qwen+LoRA 慢路 | **copy概念**（架构铁律工业背书） | C4 |
| intent_filter 规则层让权（pipeline.py L1251-1259） | 「意图收缩」：NLU 弃权模糊说法 → 路由慢路 | **copy概念** | C4 |
| continue_conversation_agent 多轮锁域（pipeline.py L1044-1058,1345） | 追问/澄清回合锁上轮 agent，跳规则分诊（落域） | **copy概念**（落域 + 多轮锁域现成形态） | C4/C7 |
| LRU IntentCache(128) + 分级匹配 + 失败缓存（default_agent.py L156-186,628-756） | L1 规则指令缓存秒回 + exposed/unexposed/unknown 三阶 | **adapt**（按全集词表规模调 capacity） | C4 |
| slot-list 失效监听 + trie 名筛（default_agent.py L294-341） | mock 态变化失效可匹配名单 + 大词表前缀筛 | **adapt** | C4 |
| ConversationInput/Result DTO + continue_conversation 字段（models.py L22-88） | 路由层 I/O 契约带 continue 信号 | **copy概念**（Swift struct） | C4/C7 |
| wake 冷却 / skip-TTS / acknowledge-beep（pipeline.py L1739,1800,1808） | barge-in 防双触发 / 跳 TTS / mock「叮」轻反馈 | **adapt** | C7 |
| 流式 delta 装配 + STREAM_RESPONSE_CHARS（chat_log.py L485-623 + pipeline.py L1155-1207） | demo 用非流式即可 | **drop**（流式复杂，home-llm 已结论 demo 非流式） | — |
| HA 实体/区域/satellite/wake-word/HassKey/Event bus/config_flow/多 backend | — | **drop**（HA 平台特有，Python runtime 不进 iOS） | — |
| ChatLog 不自截断（截断留 backend，chat_log.py 无 trim） | 截断在 LLMBackend 侧「保 system[0]+最近 N 轮」 | **adapt**（沿用 home-llm `remember_num_interactions`） | C7 |

---

## §8 关键工程洞察（for MAformac C7/C4 demo）

1. **会话态拆三层、用 ID 串、cleanup 链聚** 是 HA 这套能稳的根 —— MAformac DialogueState 别堆成单一大对象，照 `ChatSession`/`ChatLog`/`PipelineConversationData` 三分，conversation_id 关联，单 TTL 级联清。
2. **「多轮锁域」有现成实现**：`continue_conversation_agent` —— 上轮要求续聊就把下轮锁到该 agent、跳过规则分诊。MAformac 的「落域/多轮锁域」直接对标这个状态字段，不必新发明。
3. **三层路由 = HA 工业实践**：trigger → 本地意图(规则) → LLM agent，且规则层有 `intent_filter` 主动让权 —— 与 MAformac C4「L1 规则快路 + 意图收缩 + L2-5 慢路」逐条对应，架构铁律再获一个 80k★ 项目背书。
4. **共享可变态的可靠靠 code 防御**：幂等去重 + copy-on-write + 空轮回滚 + 重入守卫，全在 code 层。1.7B 小模型畸形输出/并发更需要这套 —— 与 home-llm「让小模型可靠靠 code」同一哲学，这里落在「会话历史」维度。
5. **中文问号 `？` 续听已内建**（chat_log.py L370）—— MAformac 现场中文演示直接受益，不必自己补。
6. **延迟三件套**（wake 冷却 / skip-TTS / acknowledge-beep）对「现场 5 分钟惊艳」直接相关：成功执行用最轻反馈（叮 + 卡片亮），不每次都整段 TTS 啰嗦。
7. **HA 不在会话层截断历史**（留给 backend）—— 与 home-llm 互补：MAformac 在 `LLMBackend` 做「保 system[0] + 最近 N 轮」，会话层只管完整记录 + 防御。

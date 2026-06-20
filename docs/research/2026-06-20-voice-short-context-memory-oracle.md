# 语音链路短时上下文记忆 oracle repo 扫描（2026-06-20）

状态：`state=candidate-source-pack`

任务范围：为 MAformac 车控 demo 的语音链路“短时上下文记忆”找近 3 个月仍活跃的开源 repo / 项目，避免只看 HomeLLM。

新鲜度门：以 `pushed_at` / repo 更新 / issue 活动 >= 2026-03-20 为候选门。以下候选的活跃日期均在 2026-03-20 之后；`rhasspy/rhasspy` 已查但因最近 push 为 2025-04-22 且最新 issue 未达门槛，列入排除项。

检索日期：2026-06-20。

## 检索关键词

- `voice assistant memory`
- `local voice agent context`
- `Home Assistant conversation history`
- `hassil context`
- `livekit agents session history`
- `pipecat context aggregator`
- `openvoiceos context`
- `rhasspy dialogue manager`
- `semantic kernel chat history reducer`
- `langgraph short-term memory`
- `mem0 voice agent`
- `local llm home assistant tool calling`

## 关键结论

1. 只用 raw chat history 不够。LiveKit / Pipecat / Home Assistant 都把 user / assistant / tool result 放进同一条会话日志，但强项目会额外处理截断、摘要、工具调用完整性和 interruption。
2. 车控 demo 更适合“结构化短时状态 + 最近 raw turn”的混合：`conversation_id` / `session_id` 绑定，另存 `domain_lock`、`focus_entity`、`pending_slot`、`last_tool_observation`、`last_mock_state`，再拼最近 2-4 轮原文。
3. 对小模型最有价值的是 Pipecat / LiveKit / Semantic Kernel / LangGraph 的窗口管理：保留系统提示和最近 turn，不截断半个工具调用，必要时摘要旧消息。
4. Home Assistant / HassIL / OVOS / Wyoming 说明传统语音助手不依赖长聊天记忆，而是靠 context object、active skill、intent slot、pipeline event 传递状态。这对车控“别跨域串台”更可靠。
5. ASR 噪声不能直接写入长期或短时核心状态。候选里更稳的做法是把 transcript 先作为候选观测，只有经过 intent/tool readback 后才更新 authoritative state。

## 候选 repo / 项目

| 项目 | 活跃证据 | 相关证据 URL | 短时记忆 / 上下文做法 | 对 MAformac 的 adopt / adapt / drop |
|---|---:|---|---|---|
| [home-assistant/core](https://github.com/home-assistant/core) | `pushed_at=2026-06-20T05:22:51Z` | [`conversation/chat_log.py`](https://github.com/home-assistant/core/blob/dev/homeassistant/components/conversation/chat_log.py), [`conversation/models.py`](https://github.com/home-assistant/core/blob/dev/homeassistant/components/conversation/models.py), [`openai_conversation/conversation.py`](https://github.com/home-assistant/core/blob/dev/homeassistant/components/openai_conversation/conversation.py), [`assist_pipeline/pipeline.py`](https://github.com/home-assistant/core/blob/dev/homeassistant/components/assist_pipeline/pipeline.py) | `ChatLog` 以 `conversation_id` 保存 `SystemContent` / `UserContent` / `AssistantContent` / `ToolResultContent`；LLM API 注入工具；工具结果回写到同一 log。默认更像 raw history + tool observation，没有看到内置摘要 / TTL。 | **Adopt**：`conversation_id` + tool result 入史 + `continue_conversation` 判断。**Adapt**：MAformac 必须另加小窗口 trim 和结构化 `MockVehicleState readback`。**Drop**：不要把完整 HA 复杂 LLM API 搬进 iOS demo。风险：工具执行结果和 mock 状态不同步时，chat log 会显得“已执行”，必须以读回状态为准。 |
| [OHF-Voice/hassil](https://github.com/OHF-Voice/hassil) | `pushed_at=2026-06-15T20:56:42Z` | [`hassil/recognize.py`](https://github.com/OHF-Voice/hassil/blob/main/hassil/recognize.py), [`hassil/intents.py`](https://github.com/OHF-Voice/hassil/blob/main/hassil/intents.py) | Intent recognition 支持 `intent_context`、`requires_context`、`excludes_context`、slot copy、metadata；不是聊天记忆，而是规则意图解析的结构化上下文门。 | **Adopt**：`requires_context/excludes_context` 可转成车控 `domain_lock` / `pending_slot` / `focus_entity`。**Adapt**：只抽象设计，不引 Python 到 iOS。风险：过度依赖上下文会把上一域 slot 带到新域，需域切换时清空。 |
| [OHF-Voice/intents](https://github.com/OHF-Voice/intents) | `pushed_at=2026-06-19T05:22:31Z` | [`sentences/`](https://github.com/OHF-Voice/intents/tree/main/sentences), [`sentences/en/HassTurnOn`](https://github.com/OHF-Voice/intents/tree/main/sentences/en/HassTurnOn), [`responses/`](https://github.com/OHF-Voice/intents/tree/main/responses) | 规则句式、slot list、response 分离；本身不提供会话记忆，但提供“短句直接定 intent”的确定性层。 | **Adopt**：MAformac 的 80% rule path 应做成能力词表 + slot 模板。**Adapt**：中文车控要加 ASR 音近词和状态读回。风险：模板命中会遮蔽真实歧义，低置信时必须进澄清而非继承旧 slot。 |
| [acon96/home-llm](https://github.com/acon96/home-llm) | `pushed_at=2026-06-11T12:17:17Z` | [`conversation.py`](https://github.com/acon96/home-llm/blob/develop/custom_components/llama_conversation/conversation.py), [`generic_openai.py`](https://github.com/acon96/home-llm/blob/develop/custom_components/llama_conversation/backends/generic_openai.py), [`docs/Model Prompting.md`](https://github.com/acon96/home-llm/blob/develop/docs/Model%20Prompting.md) | 可配置 `remember_conversation`；若开启，用 HA `chat_log.content` 作为 message history；`remember_num_interactions` 按交互轮数裁剪；工具调用迭代写回 history；支持 malformed tool call 转 tool messages。 | **Adopt**：记忆开关、最大交互轮数、malformed tool call 防御。**Adapt**：C7 语音链路应默认小窗口 2-4 轮，而不是无限记忆。风险：ASR 噪声若直接进入 history，会污染后续指代；需要“低置信 transcript 不入 authoritative state”。 |
| [skye-harris/hass_local_openai_llm](https://github.com/skye-harris/hass_local_openai_llm) | `pushed_at=2026-06-20T01:51:32Z` | [`README.md`](https://github.com/skye-harris/hass_local_openai_llm/blob/master/README.md), [`custom_components/local_openai/entity.py`](https://github.com/skye-harris/hass_local_openai_llm/blob/master/custom_components/local_openai/entity.py) | README 明确有“trim conversation history”以适配 context window；`entity.py` 里 `_trim_history` 保留 system prompt 和最近消息，遇到开头是 `tool` 会删除，避免没有对应 tool call 的孤立 tool result。RAG 注入只作用当前 turn，不跨 turn。 | **Adopt**：保留 system + 最近 N 轮、禁止孤立 tool result、RAG/current-context 不进短时记忆。**Adapt**：车控状态要从 mock readback 注入，不从 LLM 自述注入。风险：并行工具调用和消息裁剪容易拆散 call/result 配对。 |
| [livekit/agents](https://github.com/livekit/agents) | `pushed_at=2026-06-20T01:04:05Z` | [`llm/chat_context.py`](https://github.com/livekit/agents/blob/main/livekit-agents/livekit/agents/llm/chat_context.py), [`voice/agent_session.py`](https://github.com/livekit/agents/blob/main/livekit-agents/livekit/agents/voice/agent_session.py), [`session_close_callback.py`](https://github.com/livekit/agents/blob/main/examples/voice_agents/session_close_callback.py), [issue #3760](https://github.com/livekit/agents/issues/3760) | `AgentSession.history` 是全局 `ChatContext`；items 包括 message、function_call、function_call_output、agent_handoff；`truncate(max_items)` 保留 system/developer 并避免以 function call/output 开头；有摘要逻辑把旧 message 和 function output 压缩成 summary；issue #3760 讨论 interrupted `say` 是否加入 chat context。 | **Adopt**：conversation item 类型化、截断时保护工具调用完整性、interruption 标记。**Adapt**：MAformac 不需要实时 RTC，但需要 `interrupted` / `asr_final` / `tool_observed` 事件类型。风险：barge-in 半句入史会造成上下文腐烂，必须只让 final transcript 或明确 interrupted turn 入记忆。 |
| [pipecat-ai/pipecat](https://github.com/pipecat-ai/pipecat) | `pushed_at=2026-06-19T18:00:08Z` | [`llm_context.py`](https://github.com/pipecat-ai/pipecat/blob/main/src/pipecat/processors/aggregators/llm_context.py), [`gated_llm_context.py`](https://github.com/pipecat-ai/pipecat/blob/main/src/pipecat/processors/aggregators/gated_llm_context.py), [`llm_context_summarizer.py`](https://github.com/pipecat-ai/pipecat/blob/main/src/pipecat/processors/aggregators/llm_context_summarizer.py), [`context-summarization-google.py`](https://github.com/pipecat-ai/pipecat/blob/main/examples/context-summarization/context-summarization-google.py) | `LLMContext` 管理 messages/tools/tool_choice；gated aggregator 可按通知释放最后一个 context frame；自动摘要按 token 或消息数触发，保留最近消息，应用 summary 前校验 request id 和 context state，避免 stale summary。示例强调保留未完成 function call 序列。 | **Adopt**：token/message 双阈值、summary in progress guard、stale summary 防护、gated context。**Adapt**：MAformac 小模型可先不用 LLM 摘要，改用 deterministic state summary。风险：摘要本身会丢车控状态细节，必须以 structured state 为权威。 |
| [OpenVoiceOS/ovos-bus-client](https://github.com/OpenVoiceOS/ovos-bus-client) | `pushed_at=2026-05-24T20:15:10Z` | [`ovos_bus_client/session.py`](https://github.com/OpenVoiceOS/ovos-bus-client/blob/dev/ovos_bus_client/session.py), [`docs/session.md`](https://github.com/OpenVoiceOS/ovos-bus-client/blob/dev/docs/session.md) | `Session` 持有 `session_id`、`active_skills`、`utterance_states`、`IntentContextManager`、`site_id`、pipeline、blacklist、TTL；session 随 message.context 传递，`SessionManager` 统一读写。 | **Adopt**：结构化 session object、TTL、active skill、utterance response mode。**Adapt**：车控可做 `active_domain` + `pending_response_mode` + `site/cabin_zone`。风险：跨域串台来自 active skill 未及时失效；TTL 和域切换清理必须是代码。 |
| [OpenVoiceOS/ovos-workshop](https://github.com/OpenVoiceOS/ovos-workshop) | `pushed_at=2026-06-07T05:31:22Z` | [`skills/converse.py`](https://github.com/OpenVoiceOS/ovos-workshop/blob/dev/ovos_workshop/skills/converse.py), [`docs/skill-interaction.md`](https://github.com/OpenVoiceOS/ovos-workshop/blob/dev/docs/skill-interaction.md) | `ConversationalSkill` 支持 skill activation/deactivation、converse timeout、`can_converse` 判断、skill-specific converse intents；`ask_yesno` / `ask_selection` 把追问转为结构化 yes/no 或选项 slot。 | **Adopt**：追问后的 response mode、限定选项澄清、converse timeout。**Adapt**：车控二轮指代如“调高一点/关了它”应只在 active_domain 内生效。风险：若所有 utterance 都给 active skill，会吞掉新域指令。 |
| [OHF-Voice/wyoming](https://github.com/OHF-Voice/wyoming) | `pushed_at=2026-06-12T15:34:31Z` | [`README.md`](https://github.com/OHF-Voice/wyoming/blob/main/README.md), [`wyoming/intent.py`](https://github.com/OHF-Voice/wyoming/blob/main/wyoming/intent.py), [`wyoming/asr.py`](https://github.com/OHF-Voice/wyoming/blob/main/wyoming/asr.py) | 语音服务 peer-to-peer JSONL + PCM 协议；ASR / intent / handle 事件有 `context` 字段，可把 previous interaction context 和 next interaction context 在管线中传递。 | **Adopt**：事件协议里的 `context` 字段和 ASR->intent->handle 分层。**Adapt**：MAformac 内部 event bus 可借形态，不需要 TCP。**Drop**：不要把 protocol 当 memory framework。风险：context 字段太自由，必须 schema 化。 |
| [langchain-ai/langgraph](https://github.com/langchain-ai/langgraph) | `pushed_at=2026-06-19T10:05:20Z` | [Memory docs](https://docs.langchain.com/oss/python/langgraph/add-memory), [`libs/checkpoint`](https://github.com/langchain-ai/langgraph/tree/main/libs/checkpoint), [`libs/prebuilt/langgraph/prebuilt/tool_node.py`](https://github.com/langchain-ai/langgraph/blob/main/libs/prebuilt/langgraph/prebuilt/tool_node.py) | 短时记忆是 thread-level state + checkpointer；`thread_id` 绑定会话；长上下文方案包括 trim messages、delete messages、summarize messages、checkpoint history。docs 示例用 `summary` key 并保留最近 2 条消息。 | **Adopt**：thread/session id、state reducer 思路、summary + recent messages。**Adapt**：MAformac 不上 LangGraph，只借 `State{messages, summary, vehicle_state}`。风险：若只按 token trim，可能删掉关键 slot 来源或工具结果。 |
| [microsoft/semantic-kernel](https://github.com/microsoft/semantic-kernel) | `pushed_at=2026-06-19T23:42:11Z` | [Chat history docs](https://learn.microsoft.com/en-us/semantic-kernel/concepts/ai-services/chat-completion/chat-history), [`chat_history_truncation_reducer.py`](https://github.com/microsoft/semantic-kernel/blob/main/python/semantic_kernel/contents/history_reducer/chat_history_truncation_reducer.py), [`chat_history_summarization_reducer.py`](https://github.com/microsoft/semantic-kernel/blob/main/python/semantic_kernel/contents/history_reducer/chat_history_summarization_reducer.py) | `ChatHistoryTruncationReducer` 和 `ChatHistorySummarizationReducer`，按 target/threshold 触发，保留 system message；Python reducer 可自动 reduce。 | **Adopt**：`target_count + threshold_count`，system prompt 永保留。**Adapt**：车控摘要要结构化，不要自然语言摘要替代状态。风险：工具调用 pair 若 reducer 不理解，可能产生孤立 tool result；需额外配对检查。 |
| [mem0ai/mem0](https://github.com/mem0ai/mem0) | `pushed_at=2026-06-19T10:51:26Z` | [Voice companion cookbook](https://docs.mem0.ai/cookbooks/companions/voice-companion-openai), [`mem0ai/mem0`](https://github.com/mem0ai/mem0) | Voice cookbook 用 OpenAI Agents SDK voice pipeline + Mem0；提供 `save_memories` 和 `search_memories` function tools；按 `user_id` 存取，`top_k` + threshold 检索相关记忆。 | **Adapt**：只借“记忆作为工具，不自动注入全部历史”的模式。**Drop**：车控 demo 的短时上下文不需要向量长期记忆。风险：ASR 噪声或误解若直接 `add`，会变成持久错误；MAformac 应禁止自动长期写入。 |
| [LAION-AI/agent-bud-e](https://github.com/LAION-AI/agent-bud-e) | `pushed_at=2026-04-12T12:36:04Z` | [`README.md`](https://github.com/LAION-AI/agent-bud-e/blob/main/README.md) | 设计为 voice/multimodal companion；三类文件记忆：episodic / semantic / procedural；Context Constructor Agent 先按 pointer、时间带、频率、二阶关系、search 组装上下文；Main Agent 可发 memory write request；语音被动日志需后续 consolidation。 | **Adapt**：Context Constructor 可转成 MAformac 的 deterministic context assembler。**Drop**：三类长期记忆和被动音频日志超出 demo。风险：设计文档型 repo，代码实现少；只能当架构灵感，不能当可复用 runtime。 |
| [agentscope-ai/QwenPaw](https://github.com/agentscope-ai/QwenPaw) | `pushed_at=2026-06-18T09:59:55Z` | [`README.md`](https://github.com/agentscope-ai/QwenPaw/blob/main/README.md), [memory docs](https://qwenpaw.agentscope.io/docs/memory/), [context docs](https://qwenpaw.agentscope.io/docs/context), [release notes](https://qwenpaw.agentscope.io/release-notes) | 个人 AI assistant，支持本地部署、多渠道、Whisper voice input、memory、context management、magic commands；README 说明 config/memory/skills 存在本地 volume。 | **Adapt**：本地数据目录 + memory/context 明确分层、magic command 控制状态。**Drop**：不是车控 voice pipeline，不能照搬。风险：多渠道 assistant 容易把历史个人助手记忆误用于窄域车控；MAformac 要默认无长期个性记忆。 |

## Failure modes 汇总

| Failure mode | 证据来源 | MAformac 防线 |
|---|---|---|
| context rot：旧聊天自然语言残留影响新指令 | HomeLLM raw history、HA chat_log、LangGraph trim docs | 保留最近 2-4 轮 + structured state；域切换清空 inherited slot。 |
| 指代继承失败：它 / 这个 / 再高一点找错对象 | HassIL context、OVOS active skill、HA conversation_id | `focus_entity` 只在同域 + TTL 内有效；低置信要求澄清。 |
| ASR 噪声污染记忆 | Voice pipeline 类项目普遍风险；Mem0 自动 add 风险最高 | ASR transcript 先入 `candidate_observation`；只有 intent parse 或 tool readback 后写 authoritative state。 |
| 跨域串台 | OVOS active skill / response mode、HassIL requires/excludes context | `active_domain` + `domain_lock` + explicit domain switch clear。 |
| 工具执行结果和状态不同步 | HA / LiveKit / Pipecat 都把 tool result 入史 | 车控响应必须读回 `MockVehicleState`；LLM tool result 不是权威状态。 |
| 小模型上下文挤爆 | Pipecat summarizer、Semantic Kernel reducer、hass_local_openai trim、LangGraph trim | `max_turns`、`max_tokens`、工具 pair 原子保留、状态摘要替代自然语言长史。 |
| 半句 / interrupted 语音入史 | LiveKit issue #3760、barge-in 类语音链路 | 仅 final transcript 入核心记忆；interrupted turn 标记且默认不继承。 |

## 建议给 MAformac 的最小方案

```yaml
VoiceShortContext:
  conversation_id: string
  ttl_seconds: 90
  active_domain: climate | seat | window | light | media | nav | unknown
  focus_entity:
    domain: string
    entity_id: string
    confidence: 0.0-1.0
    expires_at: timestamp
  pending_slot:
    intent: string
    slot_name: string
    allowed_values: [string]
    expires_at: timestamp
  recent_turns:
    max_user_assistant_pairs: 3
    include_only: [final_asr, assistant_text, tool_call, tool_result]
  last_tool_observation:
    tool_name: string
    args: object
    result: object
    is_error: boolean
  authoritative_vehicle_state:
    source: MockVehicleState.readback
    state: object
```

采用规则：

- **adopt**：`conversation_id/session_id`、structured session、tool observation、response mode、max turn trim、tool call/result 配对保护、state readback。
- **adapt**：摘要改成 deterministic state summary，不让 LLM 自己总结车控权威状态。
- **drop**：长期人格记忆、向量长期记忆、被动音频日志、完整框架 runtime。

## 冲突与不确定性

- `rhasspy/rhasspy` 是关键词命中的重要历史项目，但不满足 2026-03-20 活跃门；不列为候选。
- `LAION-AI/agent-bud-e` 更像论文式 README / 架构说明，最近活跃达门槛，但可复用性低于 LiveKit / Pipecat。
- `Semantic Kernel` 的 chat history docs 页面显示 last updated 2025-01-31，但 repo 本身 2026-06-19 仍活跃；该候选用于 reducer pattern，不用于语音 runtime。
- QwenPaw 的 memory/context docs 页面可访问性不稳定，本次主要用 README 和 release notes 取证；建议后续若要采用其机制，再单独深挖源代码实现。

## 下一步建议

1. C7 voice design 里新增 `VoiceShortContext` contract，直接吸收上面的最小 schema。
2. C6 eval 加 6 类短时记忆负样本：ASR 噪声、半句 interrupted、跨域串台、tool result stale、指代错继承、长上下文挤爆。
3. 实装前优先读：Pipecat `llm_context_summarizer.py`、LiveKit `chat_context.py`、HA `chat_log.py`、OVOS `session.py`、hass_local `_trim_history`。

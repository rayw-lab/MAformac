# MAformac voice short-term memory oracle — 2026-06-20

> 状态: `state=candidate`。本文件归档本轮 `pre-mortem` scout + oracle 调研,服务 C4 三层路由 / C7 voice / C6 bench。它不是 OpenSpec 契约;进入实现前仍需写入对应 change 的 `design.md` 和 spec。

## 0. 结论

MAformac 语音链路里的短时记忆,不应做成“把最近聊天历史塞给 Qwen”。第一版应做成 **结构化会话态（DialogueState / VoiceTurnContext）+ 极短消息窗口**:

- **结构化态是权威**: 当前域、焦点设备、可继承槽位、上一轮执行、mock state 读回、pending 澄清、安全环境、barge-in/中断状态。
- **消息历史只做 trace 和少量补充**: 给模型的上下文最多放最近 1-2 个用户短句 + 结构化摘要,不喂整段 raw ASR 历史。
- **写入时机必须保守**: 只有 `ASR final -> normalizer -> intent/result -> DemoGuard -> mock readback -> TTS/UX committed` 后,才把本轮提升为可继承焦点;被打断、未完成、低置信、未读回成功的轮次只能进 trace,不能进下一轮指代。
- **短时记忆只活在 demo 会话内**: 默认 5 分钟内、单用户、单 cabin 域;长期偏好/画像/跨天记忆不进首版。

一句话: 短时记忆是 **路由和执行的状态机**,不是“记忆系统产品”。

## 1. 本仓 scout

### 1.1 已锁架构

`docs/srd-three-layer-intent-routing.md` 已锁: L1 精确指令走规则快路;L2-L5 模糊、多意图、记忆、状态感知才走慢路。`passthrough` 是带上下文延续的路由标记,锁域多轮继承是 C4 消费的能力。

本轮本仓证据:

- `contracts/demo-scenarios.yaml` scene3 已把“打开车窗 -> 开大点”定义为记忆多轮,绑定 `followup_transition: trans_1dfefae41fa915f5`。
- `contracts/l1-demo-allowlist.yaml` 把 `ac_temperature` 和 `window` 的 `required_followup_transitions` 写进 L1 精做完整性,不是单轮动作。
- `CONTEXT.md` 定义“二次交互关系”为 C1 sidecar,由 C4 路由消费;“L1 多轮完整性”要求 query rewrite / 槽位继承进入 L1 完整性。
- C3 当前重点是执行契约 + `DemoVehicleStateStore` + readback trace;真正的 `DialogueState` / 多轮锁域属于 C4/C7 要补的层。

### 1.2 对 MAformac 的直接形态

建议落一个 `DialogueState` 或等价结构,字段最少包括:

```yaml
session:
  conversation_id: string
  started_at: timestamp
  last_updated_at: timestamp
  ttl_seconds: 300
  source: push_to_talk

voice_turn:
  turn_id: string
  raw_asr_text: string
  normalized_text: string
  asr_confidence: number
  rewrite_rules: []
  is_final_asr: bool
  interruption_state: none|user_interrupted|assistant_interrupted|false_interrupt

focus:
  domain: cabin
  device: window|ac_temperature|screen_brightness|...
  scope: driver|passenger|rear_left|rear_right|all|unknown
  slots:
    value_ref: EXP|SPOT|ZERO|...
    direction: increase|decrease|open|close|none
  followup_transition_id: string|null
  expires_at: timestamp

last_execution:
  tool_call_frame_id: string
  canonical_semantic_id: string
  guard_status: ok|needs_confirmation|unsafe_action|blocked_by_state|parse_error
  state_delta: {}
  readback_cells: {}
  readback_ok: bool
  tts_committed_text: string|null

pending_clarification:
  expected_slots: []
  question_zh: string|null
  allowed_answers: []
  expires_at: timestamp|null
```

送给 Qwen 的慢路上下文不应是上面全量,而是裁剪后的 `ModelContextSnapshot`:

```yaml
model_context_snapshot:
  current_domain: cabin
  current_focus: "window.position 主驾, last=opened_default"
  current_mock_state: {window.position: 40, vehicle.speed: 0}
  last_committed_user_turns: ["打开车窗"]
  allowed_followups: ["increase_by_exp", "decrease_by_exp", "by_percent"]
  risk_context: {vehicle.speed: 0, gear: P}
  forbidden: ["free multi-step agent loop", "use raw ASR as authority"]
```

## 2. Oracle repo scan

检索窗口: 最近 3 个月活跃,即 `pushed_at >= 2026-03-20`。本轮用 `gh repo view` 核过活跃度;GitHub 搜索 API 中途限流后,改为直接读 raw 文件和官方文档。

| 项目 | 最近活跃证据 | 相关发现 | MAformac 处理 |
|---|---:|---|---|
| [livekit/agents](https://github.com/livekit/agents) | `pushed_at=2026-06-20` | `AgentSession` 是语音 app 编排器;内部有全局 `ChatContext` 和 `history`;`interrupt()` 明确等到 chat context 更新完成;issue #3760 暴露“被打断时只把已说出半句写入上下文”的真实坑。见 [AgentSession docs](https://docs.livekit.io/agents/logic/sessions/) 和 [issue #3760](https://github.com/livekit/agents/issues/3760)。 | adopt 中断后再提交上下文;不要把未播出的 assistant 文本写成已发生事实。 |
| [pipecat-ai/pipecat](https://github.com/pipecat-ai/pipecat) | `pushed_at=2026-06-19` | `LLMContextAggregatorPair` 把用户/助手上下文作为 pipeline 节点管理;官方要求 assistant aggregator 放在 `transport.output()` 之后,保证上下文匹配用户实际听到的 TTS;支持未完成用户轮次过滤和上下文摘要。见 [context management](https://docs.pipecat.ai/pipecat/learn/context-management)、[context summarization](https://docs.pipecat.ai/pipecat/fundamentals/context-summarization)。 | adopt “实际播出才入 assistant context”;adapt 摘要策略,首版只保留最近 1-2 轮 + 结构化态。 |
| [home-assistant/core](https://github.com/home-assistant/core) | `pushed_at=2026-06-20` | `ChatSession` 有 `conversation_id` 和 5 分钟清理;`ChatLog` 按会话存 user/assistant/tool_result;pipeline 把 `conversation_id`、chat log、continue agent 贯穿 ASR->intent->TTS。见 [chat_session.py](https://github.com/home-assistant/core/blob/dev/homeassistant/helpers/chat_session.py)、[chat_log.py](https://github.com/home-assistant/core/blob/dev/homeassistant/components/conversation/chat_log.py)、[pipeline.py](https://github.com/home-assistant/core/blob/dev/homeassistant/components/assist_pipeline/pipeline.py)。 | adopt 5 分钟会话 TTL + conversation_id;tool result / readback 必须进入短时态。 |
| [OHF-Voice/hassil](https://github.com/OHF-Voice/hassil) + [OHF-Voice/intents](https://github.com/OHF-Voice/intents) | `pushed_at=2026-06-15` / `2026-06-19` | intent template 支持 `requires_context` / `excludes_context`;recognizer 会把 required context 拷成 slot。见 [Home Assistant template sentence docs](https://developers.home-assistant.io/docs/voice/intent-recognition/template-sentence-syntax/) 和 [hassil recognize.py](https://github.com/OHF-Voice/hassil/blob/main/hassil/recognize.py)。 | adopt 轻量上下文门: “再高一点”只有在 focus 可解析时才 match;否则澄清/拒识。 |
| [acon96/home-llm](https://github.com/acon96/home-llm) | `pushed_at=2026-06-11` | 本仓已拆: 小模型采用单发 ToolCall、历史裁剪、状态在 code、KV 预热、防御解析。 | keep as C3/C5 蓝本,但不能只看它;它不是语音打断语义的完整答案。 |
| [langchain-ai/langgraph](https://github.com/langchain-ai/langgraph) | `pushed_at=2026-06-19` | 官方把短期记忆定义为 thread 级状态;checkpointer 存 graph state;可扩展 `AgentState`,并提供 trim/delete/summarize。见 [short-term memory](https://docs.langchain.com/oss/python/langchain/short-term-memory)、[persistence](https://docs.langchain.com/oss/python/langgraph/persistence)。 | adapt “thread state + custom fields”,不要引入 LangGraph runtime。 |
| [microsoft/semantic-kernel](https://github.com/microsoft/semantic-kernel) | `pushed_at=2026-06-19` | `ChatHistoryReducer` 支持按阈值截断或摘要,并配置目标保留消息数。见 [Microsoft Learn chat history](https://learn.microsoft.com/en-us/semantic-kernel/concepts/ai-services/chat-completion/chat-history)。 | adapt reducer 思路;首版不做 LLM 摘要,只做确定性裁剪。 |
| [mem0ai/mem0](https://github.com/mem0ai/mem0) | `pushed_at=2026-06-19` | 文档区分短期记忆、工作记忆、注意上下文与长期记忆;Pipecat 示例把 Mem0 放进语音 agent 作持久个性化。见 [Mem0 memory types](https://docs.mem0.ai/core-concepts/memory-types) 和 [Pipecat mem0 example](https://github.com/pipecat-ai/pipecat/blob/main/examples/rag/rag-mem0.py)。 | drop 首版 runtime;只借术语分层。车控 demo 不需要跨天画像。 |
| [letta-ai/letta](https://github.com/letta-ai/letta) | `pushed_at=2026-05-14` | memory blocks / archival memory 是长期状态化 agent 方案。见 [stateful agents](https://docs.letta.com/guides/core-concepts/stateful-agents/) 和 [memory blocks](https://docs.letta.com/guides/core-concepts/memory/memory-blocks/)。 | drop 首版;未来个人偏好/长期画像再看。 |
| [LAION-AI/agent-bud-e](https://github.com/LAION-AI/agent-bud-e) | `pushed_at=2026-04-12` | 论文式 README 提出 episodic / semantic / procedural 文件记忆,Context Constructor 负责预算内装配。 | adapt 为二期长期记忆参考;首版只保留“当前 episode + pointers”的思想。 |
| [OpenVoiceOS/ovos-core](https://github.com/OpenVoiceOS/ovos-core) / [leon-ai/leon](https://github.com/leon-ai/leon) | `pushed_at=2026-06-06` / `2026-06-18` | 活跃,但本轮未深读到足够代码级上下文证据。 | `candidate_only`;不写进 C4 决策依据。 |

## 3. Pre-mortem 分类

### 3.1 Tiger

1. **raw ASR 污染记忆**  
   失败方式: “座椅通分/巡逻/分为灯”这类 ASR 错词被提升为下一轮焦点,后续越改越歪。  
   mitigation: `raw_asr_text` 只入 trace;`normalized_text + rewrite_rules + confidence` 才进路由;低置信轮次不得更新 `focus`。

2. **打断导致上下文与用户实际听到的不一致**  
   失败方式: assistant 没说出口的内容被写入 history,下一轮以为用户已经听过;或半句被写入导致重复答旧问题。LiveKit issue #3760 和 Pipecat aggregator placement 都在打这个点。  
   mitigation: assistant context 以 `tts_committed_text` 为准;被打断时标 `interrupted=true`,只允许已播出片段进入 trace,不进入下一轮承诺事实。

3. **锁域串台 / 过期焦点**  
   失败方式: “打开车窗 -> 开大点”后,用户换到“屏幕太暗了”,再说“再大点”却沿用车窗焦点。  
   mitigation: focus TTL;显式新设备/新域清空旧 focus;`requires_context` 不满足则澄清,不猜。

4. **模型看到旧状态,执行用新状态**  
   失败方式: Qwen 基于旧 `window.position=20` 规划 +20%,执行前状态已变成 60%,readback 不一致。  
   mitigation: `state_revision` 随 mock state 增长;ToolCallFrame 带输入 revision;执行前检查 revision,不一致则重建 snapshot 或走 code 侧增量。

5. **1.7B 被聊天历史拖入 context rot**  
   失败方式: 5 分钟演示内多轮工具结果、TTS 文本、ASR raw 堆积,小模型注意力漂移,慢路误调用。  
   mitigation: 模型上下文固定为结构化 snapshot + 最近 1-2 轮;禁止全量历史回灌;如果未来需要摘要,先写 C6 eval 再启用。

6. **二次交互关系被 C4 重新发明**  
   失败方式: 运行时靠字符串规则临时写“再高一点”,绕开 C1 followup sidecar,导致合同与实现漂移。  
   mitigation: `followup_transition_id` 必须来自 C1 sidecar;无 transition 不继承。

7. **安全门被记忆覆盖**  
   失败方式: 用户前面说“打开车门”,后面行驶中说“继续”,系统继承危险动作。  
   mitigation: `risk_context` 每轮实时读 C2 safety cells;安全门优先级高于 focus / memory。

### 3.2 Paper-tiger

- **“必须上长期记忆 / vector DB / Mem0 才像智能”**: 对 MAformac 首版是 paper-tiger。demo 的智能来自“短域焦点 + 端态读回 + followup”,不是跨天画像。
- **“需要保留完整 chat history 才能多轮”**: 对本项目是 paper-tiger。Hassil 的 context gate、Home Assistant 的 `conversation_id`、LangGraph 的 custom state 都说明结构化状态比全量历史更稳。
- **“必须 LLM 摘要”**: 5 分钟车控 demo 里先不需要。摘要会引入新模型调用和事实压缩错误;先做确定性窗口裁剪。

### 3.3 Elephant

- C4 `DialogueState` 还没落实现;C3 只是执行闭环。若不把短时记忆作为 C4 一等合同,后续很容易被临时字符串规则吞掉。
- C7 ASR/Normalizer 未落时,短时记忆无法判断“该继承的是口语意图还是 ASR 错误”。Normalizer trace 必须和 DialogueState 同步设计。
- 现场演示里“看似多轮”的失败通常不是模型不懂,而是 commit 时机错、状态读回错、TTL 没清、打断没处理。这些都不是 LoRA 能解决的。

## 4. 建议进入 C4/C7 的合同点

1. `DialogueState` SHALL store only committed, readback-verified execution focus for follow-up resolution.
2. ASR final + normalizer output SHALL be separated from raw ASR trace; raw ASR SHALL NOT be used as authoritative memory.
3. Follow-up resolution SHALL require one of: explicit device in current utterance, valid `followup_transition_id`, or active pending clarification.
4. A focus SHALL expire after inactivity TTL or explicit domain/device switch.
5. Assistant messages SHALL be committed to short-term context only after TTS playback has reached the user-visible committed boundary.
6. Interrupted / incomplete user turns SHALL NOT update focus, unless a completion strategy marks them complete.
7. DemoGuard readback SHALL be the only source that updates executable last state.
8. Safety cells SHALL be read fresh on every follow-up; memory SHALL NOT bypass `risk-policy.yaml`.

## 5. C6 must-pass seeds

| Case | Given | When | Then |
|---|---|---|---|
| window follow-up | `window.position=0`, focus empty | “打开车窗” then “开大点” | turn2 inherits `window.position`, emits +exp, readback increases |
| ac follow-up | `ac.power=on,temp=24` | “再高一点” after AC turn | inherits `ac.temp_setpoint`, not window |
| focus switch | window turn then “屏幕太暗了” then “再亮点” | turn3 inherits screen, not window |
| stale focus | after focus TTL | “再高一点” | asks clarification or rejects ambiguous, no tool call |
| interrupted assistant | assistant reply interrupted before action confirmation | next turn | no assumption that user heard full confirmation |
| unsafe inheritance | `vehicle.speed=30`, prior parked door action exists | “继续打开” | safety拒识, no inherited dangerous action |
| ASR low confidence | raw misrecognizes vehicle noun | normalizer confidence low | no focus update; ask clarification |

## 6. Adopt / adapt / drop

**Adopt now**
- Home Assistant style `conversation_id + TTL cleanup + chat_log/tool_result`.
- Hassil style `requires_context/excludes_context`.
- Pipecat style “context reflects spoken TTS, not generated text”.
- LiveKit style “interrupt future completes only after context update”.
- HomeLLM style “模型单发;状态/单位/白名单在 code”。

**Adapt**
- LangGraph checkpointer/custom state -> 本地 in-memory `DialogueStateStore`,不引 LangGraph。
- Semantic Kernel reducer -> 本地 deterministic trim,不引摘要模型。
- Pipecat summarization -> future only;先不启。

**Drop for first demo**
- Mem0/Letta/Agent Bud-E 的长期画像、archival memory、跨 session personal memory。
- OpenVoiceOS/Leon 作为第一刀依据;保留候选,不做决策源。

## 7. 下一步

1. C4 `define-intent-routing` 的 design 增加 `Short-Term Memory Contract` 段,引用本文件。
2. C7 voice 设计把 `VoiceTurnContext` 和 normalizer trace 字段与 `DialogueState` 接口打通。
3. C6 demo scenarios 把 scene3 扩成上表 7 个 must-pass。
4. 写一个最小 Swift 结构: `DialogueState`, `FocusFrame`, `CommittedTurn`, `ContextSnapshotBuilder`。

## 8. 已知限制

- Codex web researcher subagent `019ee37e-f5e1-74d3-b33a-4a686beebe43` 在首次 120s 等待内未返回;本版主要基于主线程 web + GitHub raw + 本仓 scout。若子 agent 后续返回新证据,补 v2。
- GitHub code search API 中途限流,已改用 `gh repo view` 活跃度核验 + raw 文件定向读取;未深读的活跃项目明确标 `candidate_only`。

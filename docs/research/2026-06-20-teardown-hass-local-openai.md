# hass_local_openai_llm teardown — 流式三态切分 / 历史裁剪 / per-turn RAG / 注入与缓存旋钮（服务 C4 路由 + C7 voice 裁剪）

> **缘起**：磊哥要求 blueprint-teardown 深扒 `skye-harris/hass_local_openai_llm`（⭐ 活跃，2026-06-20 当天有 commit `0ce9b53`，Apache-2.0）——MAformac 的 **C4 三层路由 runtime（流式提取 + 历史/上下文裁剪 + 注入）+ C7 voice（TTS 流式 / barge-in 衔接 / per-turn 上下文）** 参考蓝本。clone 在 `~/workspace/raw/05-Projects/MAformac/ref-repos/hass-local-openai`（CLAUDE §6：只读参考，**不进仓**；Apache-2.0 = 方法可 adopt，但**翻译成 Swift 设计思想，不 import Python**）。
> **本文 = 全仓 8 个 runtime/test 文件逐行拆**（`entity.py` 767 / `config_flow.py` 747 关键段 / `weaviate.py` 285 / `ai_task.py` 256 / `llama_cpp.py` 177 / `conversation.py` 115 / `deepseek.py` 114 / `const.py` 90 + 4 test）。
> **与 home-llm 的分工**：home-llm 是「**训练自有小模型 + code 侧重解析/归一化/白名单/KV 预热**」的蓝本（teardown 已落）；本 repo 是「**OpenAI-compatible 传输层 + 上下文卫生 + 多引擎兼容垫片**」的蓝本——它**不训模型、不做安全门**，但把「**流式 token 流如何被可靠地切成 thinking/speech/toolcall 三态**」「**短上下文窗口如何裁剪不破坏 role 交替**」「**RAG 只作用当前 turn 不污染后续**」「**注入角色 / KV slot / 采样参数怎么暴露成旋钮**」做到了生产级。这几样正是 C4 路由 runtime + C7 voice 衔接的硬骨头，README 完全看不到，只在代码里。
>
> **硬结论（一句话）**：本 repo 给 MAformac 的不是「又一个 agent loop」，而是 **5 个可靠性垫片**——① 流式三态切分器（跨 chunk 边界 + 多引擎 tool-call ID/index 怪癖兜底）② 保 system + 删孤立 tool result 的历史裁剪 ③ per-turn-only RAG（非长期记忆，正好对 demo 短时记忆边界）④ 注入角色三选项（date/RAG 不进 system prompt 以保 KV 缓存）⑤ slot 固定 + strict JSON-Schema 强约束输出。**全是 code 侧外围工程，与「模型只产单跳、可靠性在 runtime」架构同源。**

---

## §0 工程链路鸟瞰（一次 turn 的数据走向）

```
user_input(text/voice→text)
  → conversation._async_handle_message       # C4 入口：装 system_prompt + llm_apis + parallel_tool_calls
  → entity._async_handle_chat_log            # 核心环：组消息 → 裁剪 → 注入 → 调模型 → 流式提取 → 回灌
      ├─ _convert_content_to_chat_message     # 每条 Content → OpenAI message（user/assistant/tool/system）
      ├─ _trim_history                        # 短上下文裁剪：保 system[0] + 最近 N 轮，删孤立 tool result
      ├─ [RAG] WeaviateClient.hybrid_search   # per-turn 检索（仅当前 user 文本，不跨 turn）
      ├─ _inject_content                      # date/time + RAG 结果 → 注入到「最后一条 user 之前」（非 system）
      ├─ [structured] _format_structured_output / _adjust_schema  # strict JSON-Schema 全字段 required
      └─ for _ in range(MAX_TOOL_ITERATIONS): # 多步 loop（demo 应钳成单发）
           result_stream = client.chat.completions.create(stream=True)
           async for chunk in _transform_stream(...)   # 🔴 流式三态切分器（本 repo 精华）
           if not unresponded_tool_results: break       # 单发出口
```

- **状态在 code（HA `ChatLog`），模型每轮无状态**（line 460-678 全程把 `ChatLog.content` 转 messages 再调）→ 与 MAformac「DialogueState 贯穿、模型单跳」一致。
- **`MAX_TOOL_ITERATIONS=10`（`entity.py:77`）= 多步 ReAct 默认开**。这是与 home-llm（默认单发 `MAX_TOOL_CALL_ITERATIONS=0`）的关键差异——**MAformac demo 必须钳回单发**（见 adopt-map drop 项）。

---

## §1 `entity.py`（767 行）— 核心 runtime，MAformac 最该抄的两块

### 🔴 1.1 流式三态切分器 `_transform_stream`（line 317-458）= 本 repo 最高价值

把 OpenAI streaming chunk 流可靠地切成 **thinking / speech(content) / tool_calls** 三态，且**容忍跨 token 边界与多引擎怪癖**。逐机制：

- **`<think>` 跨 chunk 兜底**（line 398-423）：不假设 `<think>`/`</think>` 是独立 token——`if "<think>" in content` 进 think 态、`if "</think>" in content` 用 `content.split("</think>", 1)` 切出 before/after，**残段累进 `pending_think`**。→ 思考块**不会泄进 TTS speech**。这是 C7 voice 的硬需求（思考内容绝不能被念出来）。
- **`seen_visible` 闸门**（line 425-429）：只有出现过非空可见 content 才开始 yield `chunk["content"]`，**避免前导空白/思考残留进语音**。
- **reasoning_content 字段名兼容**（line 376-380）：`getattr(delta,"reasoning_content") or getattr(delta,"reasoning")`——不同 vLLM/引擎字段名不一（注释直引 vllm#27755）。**防御性 getattr 双名兜底**。
- **🔴 多引擎 tool-call 累积怪癖兜底**（line 347-372）：流式 tool call 的 args 分多 chunk 到达，但各引擎对 `id`/`index`/`name` 处理不同：
  - llama.cpp：只有首个 chunk 带 `id`，后续 args chunk 无 id（line 350）→ `tool_call_id = tool_call.id or tool_call_id` 粘住。
  - Ollama：并行 tool call **共享同一 `index`=0**（line 351）。
  - 某 OpenRouter 引擎：并行调用**共享同一 id 和 index**（line 354）→ 于是用 `tool_key = tool_call_id + tool_call_name` 复合键区分（line 361）。
  - **教训**：流式 FC 的「同一个调用的多个 args 分片」与「多个并行调用」边界，**不能只靠 id 或 index 判断，要复合键**。MAformac 即便单发，只要走流式 FC 就会踩这个坑。
- **args 收尾解析**（line 439-449）：`finish_reason` 时才 `json.loads(tool_call["args"])`，空 args → `{}`（line 444-446）。**累积完整再解析，不边到边解**。
- **timings 旁路**（line 431-437）：`event.timings`（llama.cpp 扩展）塞 `extra_state_attributes` → 首 token 延迟/吞吐可观测。`try/except` 包住（非标准字段）。

### 🔴 1.2 历史裁剪 `_trim_history`（line 680-711）= 短上下文窗口的正确姿势

```
保系统 prompt[0] 永不删 → 留最近 2*max_messages+1 条 → 若 messages[1] 是孤立 tool result 则删
```

- **`num_previous_rounds = sum(role=="assistant") - 1`**（line 695，减当前进行中轮）→ **按「轮」而非「条」计数**（一轮 = user+assistant 对）。
- **保 system[0]**（line 702-705）：`[messages[0], *messages[drop_index:]]`——系统 prompt（工具定义 + 角色）**永不被裁掉**。这是小模型不丢工具定义的关键。
- **🔴 删孤立 tool result**（line 707-709）：裁剪后若 `messages[1]["role"]=="tool"` 就删——**「某些模型不接受没有配对 tool_call 请求的孤立 tool result」**（注释原文）。这是 chat template role-alternation 的硬约束，错了直接 500/拒答。C4 多轮裁剪必抄。
- 注释明示「Logic borrowed from the Ollama integration」——本身也是 adopt 来的久经考验逻辑。

### 1.3 消息转换 `_convert_content_to_chat_message`（line 189-272）

- **tool result 非 JSON 兜底**（line 195-207）：`json.dumps(tool_result, default=log_and_str)`——`default` 回调把非序列化值 `str()` 化**并打 warning**。**永不因 tool 返回怪类型而崩**。
- **role 三分支**（system/user/assistant），user 支持图片附件（base64 data-url，line 219-240，仅 `image/` mime，否则抛 `unsupported_attachment_type`）。
- assistant 的 tool_calls 回灌（line 255-269）：历史里的 assistant tool call 转回 OpenAI 格式 `arguments=json.dumps(tool_args)`——**多轮 FC 历史完整性**。

### 1.4 注入与缓存友好（line 505-582）

- **🔴 date/time 不进 system prompt**（line 505-509 注释）：「HA 不再把日期注入 system prompt，因为**负面影响缓存**」——动态内容进 system prompt 会让 KV 前缀缓存每次失效。改为注入到消息链末尾。**这是 KV 缓存友好的第一性原则**（与 home-llm「静态在前、变化态在末尾」同源）。
- **`_inject_content` 三角色**（line 274-315）：date+RAG 内容可作 `tool`/`assistant`/`user` role 插到**倒数第二位**（`insert(-1)`，即最后一条 user 之前，line 291/302/311），避免连续两条 user 破坏 role 交替。前缀固定提示「不要复述本消息」（line 281-283）防模型把上下文念回去。
- **注入时移除 GetDateTime 工具**（line 576-582）：若已注入 date，就从 tools 里删掉 `*GetDateTime` 工具——**避免模型多此一举调工具问时间**。小聪明，省一轮往返。

### 1.5 strict 结构化输出 `_adjust_schema` / `_format_structured_output`（line 87-136）

- **全字段强制 required + nullable**（line 102-107）：OpenAI strict 模式要求所有 property 在 `required` 里；本来 optional 的字段改成 `type=[原type,"null"]` 再加进 required。→ **递归把 voluptuous schema 压成 strict-JSON-Schema**。
- **删 `allOf/anyOf/oneOf`**（line 87-91）：tool schema 里这些组合关键字很多引擎不支持 → 直接 pop。**防御性兼容垫片**。
- 与 C6/C7 受限解码呼应：MLX 端用 outlines/xgrammar 时，**同样要把 schema 压平 + 全 required** 才能稳定约束 1.7B。

---

## §2 `weaviate.py`（285 行）+ README §RAG — per-turn-only RAG（正好是 demo 短时记忆边界）

- **🔴 RAG 只作用当前 turn，不跨 turn**（README line 234-235 + `entity.py:524`）：`if weaviate_host and user_input and user_input.text` 才查，**只用当前 user 文本检索**，结果注入当前 turn，**不carry forward**。README 明示「This is **not** a general-purpose memory」。
  - **对 MAformac 的价值**：这正是磊哥定的 demo 边界——**短时上下文记忆，非长期向量记忆**。本 repo 给了「检索增强但有界」的现成形态：检索物 = `{query, content}` 双字段，`query` 被向量化、`content` 是要喂给模型的料（line 236-238）。MAformac 若要做「设备别名/同义词/话术召回」可借这个**双字段 + per-turn** 形态，但**载体换成内存 dict/封闭词表，不要 Weaviate**（见 drop）。
- **hybrid_search + threshold 过滤**（line 75-124）：`alpha` 平衡向量/BM25（0=纯文本匹配，1=纯向量），返回后**再按 score≥threshold 客户端过滤**（line 117-121）——**双层过滤防低质召回**。默认 `threshold=0.9 / max_results=2 / alpha=0.5`（const.py:81-83）——**召回保守**（宁缺毋滥），适合 demo「不丢脸」基调。
- **RAG 异常吞掉不中断**（`entity.py:559-562`）：`except Exception: _LOGGER.exception(...)`——**RAG 挂了主链路照走**，不让检索故障毁掉对话。优雅降级。
- **⚠️ GraphQL 字符串拼接注入风险**（line 44-62/80-100）：`concepts: ["{query}"]` 直接 f-string 拼 user query——**SQL/GraphQL 注入隐患**。MAformac 若借检索逻辑**必须参数化**，这是 paper-tiger 提醒。

---

## §3 多引擎兼容垫片 `llama_cpp.py`(177) + `deepseek.py`(114) + `config_flow.py` 关键段 — `LLMBackend` 协议的现成形态

MAformac 已锁 `LLMBackend` 协议（主 mlx-swift / 备 llama.swift）。本 repo 用 **mixin + entity_map 派发** 实现「按 server_type 切后端特化逻辑」，是该协议的现成参考形态：

- **🔴 后端派发 `entity_map`**（`conversation.py:29-43` / `ai_task.py:43-54`）：`{deepseek: ..., llama_cpp: ..., 默认: 通用}` dict 派发 + **懒加载 import**（`# noqa: PLC0415` 函数内 import 避免循环依赖）。→ MAformac `LLMBackend` 多实现选择的同款 registry 形态。
- **mixin 叠加特化**（`llama_cpp.py:120-177`）：`LlamaCppMixin` 只覆写 `_get_extra_body_args`（采样参数 + chat_template_kwargs）和 `_convert_content_to_chat_message`（回灌 prior thinking），**通用逻辑全继承**。→ 后端差异**只覆写差异点**，不重写全链路。
- **🔴 KV slot 固定 `id_slot`**（`llama_cpp.py:131-133` + README line 131-133）：「Pins requests to a specific llama.cpp slot for **prompt-cache reuse**」——把请求钉在固定 slot 复用前缀缓存。**= home-llm KV 预热的另一面（缓存命中靠 slot 一致性）**。MLX 端等效 = 复用同一 KV cache 句柄。
- **prior thinking 回灌可配**（`llama_cpp.py:154-169` + `deepseek.py:67-82`）：`include_prior_thinking` 旋钮——**有些推理模型要求回灌自己的 thinking，有些要求剥掉**（README line 126-129：Gemma 拒绝 prior reasoning）。**模型族差异 → 暴露成布尔旋钮，不写死**。这是 MAformac 切 Qwen3 thinking 模式时的直接经验。
- **🔴 model id 防御解析 `strip_model_pathing`**（`config_flow.py:351-355`）：`re.search(r"([^\/]*)\.gguf$", name)` 从 `/path/to/Qwen3-1.7B.gguf` 抽出干净名。`_resolve_model_name`（line 153-164）：**优先 server alias，回退剥路径的 id**。→ 与 home-llm 防御解析同源：**外部给的脏字符串先归一再用**。
- **采样参数 schema 化 + 边界校验**（`llama_cpp.py:49-107` + test_schema.py）：top_p/top_k/min_p/repeat_penalty/presence_penalty 全部 `NumberSelectorConfig(min,max,step)` 带范围，test 覆盖**边界值通过 + 越界拒绝 + 类型转换**（test_schema.py:98-167）。→ **旋钮即契约**，越界在配置层就拒，不到推理层炸。MAformac C7 暴露 ASR/采样旋钮可抄这套「带范围 + 测边界」。
- **`models.list()` 启动连通性探针**（`__init__.py:94-102`）：setup 时 `with_options(timeout=10).models.list()` 探一下，401→`ConfigEntryError`，其它 OpenAIError→`ConfigEntryNotReady`（可重试）。**区分「配置错」与「暂时不可用」**——MAformac 端侧加载 mlx 模型同理（模型缺失 vs 加载中）。

---

## §4 `ai_task.py`（256 行）— 结构化数据 + 错误分类（C6 bench 输出解析借鉴）

- **structured vs 自由文本分流**（line 153-167）：无 `task.structure` → 直接返回文本；有 → `json_loads(text)` 解析，**`JSONDecodeError` 转 `HomeAssistantError("Error with structured response")`**（line 158-162）。**结构化输出解析失败 = 明确错误，不静默**。
- **last content 类型守卫**（line 147-149）：取结果前断言 `chat_log.content[-1]` 是 `AssistantContent`，否则抛错——**防止把 tool result 当最终答案**。C6 评测提取 ToolCall 时同样要守「最后一条是不是 assistant」。
- 图片生成走 Images API（line 169-256），与车控 demo 无关，**drop**。

---

## §5 Cross-Cutting Patterns（横切设计思想）

1. **上下文卫生是第一性，不是 nice-to-have**：date/RAG **绝不进 system prompt**（保 KV 缓存）、注入到 user 前一位（保 role 交替）、裁剪保 system + 删孤立 tool result（保 chat template 合法）。**「往哪放、什么时候放、放成什么 role」三连决定小模型/缓存能不能稳**——比 prompt 措辞更要命。
2. **流式提取必须容忍碎片与引擎怪癖**：`<think>` 跨 chunk、tool args 分片、并行 call 共享 id/index、reasoning 字段双名——**没有一个能假设"一个语义单元 = 一个 token/chunk"**。复合键 + 残段累进 + getattr 兜底是标配。
3. **模型族差异 = 旋钮，不是 if-else 写死**：thinking 开关、prior-thinking 回灌、注入角色、采样参数、slot id——全暴露成带范围校验的配置。**"哪个 work 用哪个" + 测边界**，把不确定性外置给配置层。
4. **降级优于中断**：RAG 异常吞掉、tool result 非 JSON 转 str+warning、timings try/except、models.list 区分错类——**外围故障不毁主链路**。
5. **registry + mixin 做后端多态**：dict 派发 + 懒加载 import + mixin 只覆写差异点 = `LLMBackend` 协议的轻量实现形态，**通用逻辑零重复**。
6. **检索有界**：RAG = per-turn-only 检索增强，**显式不做长期记忆**。正好契合 demo「短时上下文记忆」边界，且优雅匹配「不丢脸」的保守召回（高 threshold + 双层过滤 + max=2）。

---

## §6 Adopt / Adapt / Drop 映射 → MAformac C4 / C7（裁剪）

| 形态（file:line） | 动作 | C 层 | 为什么 |
|---|---|---|---|
| 流式三态切分器 `_transform_stream`（entity.py:317-458）：`<think>` 跨 chunk 累进 + seen_visible 闸门 + thinking 绝不进 speech | **copy概念** | C7 | TTS 绝不能念思考内容；voice 流式衔接的硬需求。Swift 重写 ThinkSpeechToolSplitter（按 `<think>`/`</think>` 分隔 + 残段缓冲），不 import Python |
| 多引擎 tool-call 累积复合键（entity.py:347-372）：`tool_key=id+name`、args 分片累积、`id or prev_id` 粘连 | **copy概念** | C4 | 走流式 FC 必踩「args 分片 vs 并行调用」边界；单发也要正确累积一个完整 ToolCall。复合键 + 收尾解析是现成解 |
| 历史裁剪 `_trim_history`（entity.py:680-711）：保 system[0] + 最近 N 轮 + 删孤立 tool result | **adapt** | C4 | demo 短上下文窗口裁剪正确姿势；删孤立 tool result 防 chat template role 报错。MAformac 按「轮」裁 DialogueState，保系统 prompt（工具定义）永不删 |
| 注入位置/角色（entity.py:505-582）：date/RAG 不进 system prompt、注入到 user 前一位、注入则删 GetDateTime 工具 | **copy概念** | C4 | KV 缓存友好第一性 + role 交替合法性；「动态内容进 system = 缓存每次失效」是必须内化的硬约束 |
| per-turn-only RAG 形态（weaviate.py + README:234-235）：双字段 {query,content}、仅当前 user 文本检索、不跨 turn、高 threshold + 双层过滤 + 异常吞掉 | **adapt** | C7 | demo 短时记忆/同义词召回的有界形态。**载体换成内存 dict/封闭词表（capabilities.yaml 派生），不要 Weaviate**；借「有界检索 + 优雅降级 + 保守召回」思想 |
| strict JSON-Schema 压平 `_adjust_schema`（entity.py:87-136）：全字段 required + nullable + 删 allOf/anyOf/oneOf | **copy概念** | C4/C7 | MLX 端 outlines/xgrammar 受限解码同样需「schema 压平 + 全 required」才能稳约束 1.7B 输出 ToolCall |
| `LLMBackend` registry + mixin（conversation.py:29-43 / llama_cpp.py:120-177）：dict 派发 + 懒加载 + mixin 只覆写差异点 | **adapt** | C4 | MAformac 已锁 `LLMBackend` 协议的现成实现形态；后端差异只覆写 extra_body/采样/thinking 回灌 |
| prior-thinking 回灌旋钮（llama_cpp.py:154-169 + README:126-129）：模型族差异暴露成布尔，不写死 | **copy概念** | C4/C7 | Qwen3 切 thinking 模式时直接经验：有的模型要回灌自己 thinking，有的拒绝（Gemma）。暴露旋钮不写死 |
| KV slot 固定 `id_slot`（llama_cpp.py:131-133）：钉 slot 复用前缀缓存 | **adapt** | C4 | 与 home-llm KV 预热互补（缓存命中靠 slot/句柄一致）。MLX 端 = 复用同一 KV cache 句柄 |
| model id 防御解析 `strip_model_pathing`（config_flow.py:351-355）：剥路径 + `.gguf` 扩展名 | **copy概念** | C4 | 外部脏字符串先归一再用；与 home-llm 防御解析同源 |
| 采样旋钮带范围 schema + 测边界（llama_cpp.py:49-107 + test_schema.py） | **adapt** | C7 | 「旋钮即契约」：越界在配置层拒，不到推理层炸；C7 暴露 ASR/采样参数可抄「带范围 + 测边界」 |
| 启动连通性探针 `models.list()` 区分错类（__init__.py:94-102） | **copy概念** | C4 | 端侧 mlx 模型加载同理：区分「模型缺失/配置错」vs「加载中/暂不可用」，给用户对的提示 |
| tool result 非 JSON 兜底（entity.py:195-207）：`json.dumps(default=str)` + warning | **copy概念** | C4 | mock 车控返回怪类型也永不崩；记录可观测 |
| `MAX_TOOL_ITERATIONS=10` 多步 ReAct loop（entity.py:77/647-678） | **drop** | — | demo 必须**单发**（同 home-llm `MAX_TOOL_CALL_ITERATIONS=0`）。多步循环 = 延迟 + 崩点，钳成 1 |
| Weaviate 向量 DB + Docker + NodeJS WebApp（weaviate/ 全目录） | **drop** | — | 纯端侧离线、轻治理：不引向量 DB / Docker / Node。检索用内存 dict/封闭词表 |
| HA `ConfigFlow` UI 全套（config_flow.py 747 行 UI 部分） | **drop** | — | HA 专属 runtime 载体；MAformac 是 SwiftUI 无后端。只取 §3 的 model-id 解析与 server-type 派发思想 |
| Images API 图片生成（ai_task.py:169-256） | **drop** | — | 与车控 demo 无关 |
| GraphQL/检索 query f-string 拼接（weaviate.py:44-62） | **drop**（反面教材） | — | 注入隐患；MAformac 若借检索逻辑必须参数化，**别照抄拼接** |

---

## §7 一句话

> home-llm 教 MAformac「**模型只产单跳 + code 侧解析/归一化/白名单/KV 预热**」；hass_local_openai_llm 补上「**那条单跳在 OpenAI-compatible 流里如何被可靠地切成 thinking/speech/toolcall 三态、短上下文窗口如何裁剪不破坏 chat template、动态上下文如何注入才不毁 KV 缓存、检索如何有界到当前 turn**」——**5 个上下文卫生 + 流式提取垫片**，直接服务 C4 路由 runtime 与 C7 voice 衔接，且全程印证「可靠性在 runtime 外围工程、不在模型本身」的反转架构。**drop 掉 Weaviate/Docker/Node/HA UI/多步 loop 这些不适用载体，吸收全部上下文卫生与流式提取的工程智慧。**

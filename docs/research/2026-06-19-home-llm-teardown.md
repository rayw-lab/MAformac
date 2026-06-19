# home-llm 蓝本 工程/算法 teardown — MAformac 直接抄的现成实现

> **缘起**：磊哥要求深扒 home-llm（acon96/home-llm，⭐1365，2026-06-11 活跃）——MAformac 的 **runtime（推理集成）+ C5 LoRA 数据** 双蓝本。clone 在 `~/workspace/raw/05-Projects/MAformac/ref-repos/home-llm`（CLAUDE §6：只读参考，不进仓）。
> **本文 = runtime 层逐文件拆解**（5 文件全读，带行号）。数据管线（generate_data/tools/synthesize）见后续 teardown-data 续篇。
> **核心结论**：home-llm 的 TRAINED 小模型（home-1b/3b）用 **单发（MAX_TOOL_CALL_ITERATIONS=0）+ 三重白名单 + 防御性解析 + 双向单位归一化 + KV 缓存预热**——逐条都是 MAformac 该抄的工程，且印证"模型只产单跳、编排/归一化/安全在 code"的架构。

---

## §1 控制环 `conversation.py`（250 行）— agent 主循环

- **入口 `async_process`**：用 HA `chat_session`/`chat_log` 维护历史（line 92-96）→ **状态在 code，模型每轮无状态调用**。
- **历史裁剪**（line 131-134）：保系统 prompt[0] + 最近 `remember_num_interactions*2` 轮 → 显式上下文窗口管理。
- **🔴 核心旋钮 `max_tool_call_iterations`**（line 156-220，注释 line 157）：
  - **=0/1 → 单发**：模型一次生成 NL 回复 + ToolCall，code 执行，完事。**无模型多步循环**（= MAformac"模型单次只产单跳 ToolCallFrame"硬约束）。
  - **>1 → ReAct 多步**：模型调工具→看结果→再调（风险模式）。
- **错误反馈重试**（line 191-194）：`MalformedToolCallException → err.as_tool_messages()` 把 `{"error":...}` 喂回历史 → 模型下一轮看到错误可纠正。
- **回复抽取**（line 235-242）：倒序找最后 AssistantContent，`strip_thinking_blocks` 剥 `<think>` → TTS speech。

## §2 防御性解析 `utils.py`（654 行）— 让小模型可靠的核心工程

- **🔴 三层防御性解析 `parse_raw_tool_call`**（line 495-579）：
  1. **多格式解析**：标准 JSON / gemma `call:Fn{k:<escape>v<escape>}` 正则（line 503-516）。
  2. **`fuzzy_json` 修复兜底**（`parse_json_with_repair_fallback` line 591-599）= jsonrepair 零成本兜底。
  3. **双 schema 校验**（line 520-547）：标准 `{name, arguments}` / home_llm 原生 `{service, target_device, brightness, temperature, rgb_color...}`，都失败才抛 MalformedToolCall。
- **🔴 值归一化在 code（关键减负）**（line 565-571）：`brightness` 0-1→×255；`rgb_color` "(r,g,b)" 字符串→list。**模型输出近似值，code 归一到实际范围**。
- **三重白名单 `get_home_llm_tools`**（line 457-493）：DOMAIN ∩ `SERVICE_TOOL_ALLOWED_DOMAINS` × SERVICE ∩ `SERVICE_TOOL_ALLOWED_SERVICES` × ARG ∩ `ALLOWED_SERVICE_CALL_ARGUMENTS`。安全边界是 code。
- **enum 白名单**（`custom_custom_serializer` line 132-136）：`vol.In → {"enum":[...]}` 进 schema → 受限解码 enforce。
- **`to_say` 嵌 args**（line 573）= NL 回复 + ToolCall 同出的一种实现。
- **错误反馈** `as_tool_messages`（line 68-76）：畸形调用 → 造 error tool result 喂回。

## §3 prompt 构建 + 工具提取 `entity.py`（711 行）

- **🔴 双向单位归一化（最关键减负）**：
  - prompt 侧 `expose_attributes`（line 564-592）：端态转人类可读喂模型——brightness 128→"50%"、temp→"22 C"(>50 猜 F)、rgb→最近命名色、volume→"vol=50%"、humidity→"%"。
  - 解析侧 `parse_raw_tool_call`：人类单位转回机器值（%→255）。
  - → **模型在人类单位工作，code 做单位换算**。1.7B 不必输出精确机器值。
- **🔴 system prompt 算法 `_generate_system_prompt`**（line 556-653）：Jinja 模板注入 = 工具列表 `name(params)` + 当前设备态（归一化，按 area 分组）+ ICL 示例。
- **ICL 动态少样本 `_generate_icl_examples`**（line 489-554）：从 CSV（type/request/tool/response）按域筛 + 随机填真实设备/区域/亮度/色 → few-shot。**base 模型（未 LoRA）路径用**。
- **工具提取**：
  - 流式 `_async_stream_parse_completion`（line 229-381）：跨 token 边界分隔符匹配（`cur_match_length` 缓冲被切碎的 `<tool_call>`）+ thinking/speech/tool 三态分离 + 末尾未闭合 flush。**复杂**。
  - 非流式 `_async_parse_completion`（line 382-433）：regex 抽取 tool 块 + 剥 thinking + 解析。**demo 用这个就够**。

## §4 推理后端 `llamacpp.py`（579 行）— GBNF 挂载 + 冷启动解药

- **🔴 GBNF 挂载**：`_load_grammar`（line 219-230）`LlamaGrammar.from_string(读 .gbnf)` → `self.grammars[model]`；生成时 `create_chat_completion(..., grammar=grammar)`（line 495,555）。**llama.cpp 采样层 enforce**。MLX 需等效（outlines/xgrammar）。
- **两种受限解码**：GBNF grammar 或 `response_format={"type":"json_object","schema":...}`（line 477-483）。
- **🔴 冷启动解药 = KV 缓存预热 `_cache_prompt`**（line 366-448）：`create_chat_completion(系统prompt, max_tokens=1)` 只生 1 token 丢弃，**把系统 prompt（工具+态）灌进 KV cache**。启动 5s 后预热 + **监听状态变化重预热**（cooldown 防抖 line 372-382）。→ 用户首句只处理新 token。**= oracle 的 prewarm，现成实现**。
- **🔴 缓存友好排序 `_async_get_exposed_entities`**（line 300-322）：实体按更新时间排，**静态在前（命中缓存）、变化态在末尾**。
- 模型加载：GGUF via `Llama(n_ctx, n_batch, n_threads, flash_attn)` + 磁盘 KV cache（line 196-202）。

## §5 边界 + 配置 `const.py`（365 行）

- **三重白名单**（= capabilities.yaml）：`ALLOWED_DOMAINS`(line 9: light/switch/fan/cover/lock/climate/...) × `ALLOWED_SERVICES`(line 8: turn_on/off/set_temperature/...) × `ALLOWED_SERVICE_CALL_ARGUMENTS`(line 142: brightness/temperature/rgb_color/...)。
- **DEFAULT_PROMPT 结构**（line 65-89）：`<persona>` + `<devices>`(按 area 分组列 "id 'name' = state;attrs") + `<current_date>` + ICL_EXTRAS(response_examples)。
- **默认采样**（line 93-104）：max_tokens 512, top_k 40, **temperature 0.1**(确定性), context 8192。
- **🔴 per-model 配置 `option_overrides`**（line 242-362）：
  - **trained `home-1b/3b-v3`**（line 264-317）：`MAX_TOOL_CALL_ITERATIONS: 0`(**单发**) + ICL 关 + `tool_call_prefix/suffix = ```homeassistant / ``` ` + legacy tool calling。← **TRAINED 小模型实证：单发 + 不需 ICL**。
  - **🔴 `qwen3`**（line 318-322）：`temperature 0.6, top_k 20, top_p 0.95`(Qwen 官方采样) + 原生 tool calling。← MAformac Qwen3-1.7B 采样直接参考。
  - `home-functiongemma`：`<start_function_call>/<end_function_call>`, temp 1.0。
- GBNF 默认 opt-in（line 157-158, file `output.gbnf`）。remember 5 轮 / refresh prompt per turn。

## §6 output.gbnf — 受限解码语法（直接可改用）
```
root ::= (tosay "\n")+ functioncalls?              # NL 回复行 + 可选工具块
functioncalls ::= "```homeassistant\n" (object ws)* "```"   # JSON 对象在 fenced 块
object/array/string/number ::= 标准 JSON 文法
```
→ 强制输出 = **TTS 回复文本 + ```块{ToolCall JSON}```**。MAformac 改成中文回复 + 中控块 + 限定 enum 即可。

---

## §7 MAformac adopt / adapt / drop 映射

| home-llm 工程 | MAformac | 动作 |
|---|---|---|
| `MAX_TOOL_CALL_ITERATIONS=0` 单发 | 模型单次产单跳 ToolCallFrame | **直接抄**（架构铁律实证） |
| 三层防御性解析（多格式+fuzzy_json+双schema） | DemoGuard 解析层 | **直接抄**（防 1.7B 畸形输出） |
| 值归一化在 code（%→255 等） | exp_step/execution_range 归一化，读 mock 态 | **直接抄**（1.7B 工作在人类单位） |
| 三重白名单（domain×service×arg）+ enum | capabilities.yaml（8 cabin.* + 97 enum） | **已有，对齐** |
| GBNF 受限解码（output.gbnf） | 中文回复 + 中控块 + enum 约束语法 | **改用**（中文化 + cabin enum） |
| KV 缓存预热（启动+状态变化重热） | app 启动预热 Qwen + mock 态变化重热 | **直接抄**（冷启动解药） |
| 缓存友好排序（静态前/动态后） | 系统 prompt：capabilities 前 + state-cells 后 | **直接抄** |
| 双向单位归一化 prompt | 端态归一化喂模型 + readback | **直接抄** |
| ICL 动态少样本 | base 模型（spike E3 对照组）用 | **可选**（LoRA 后关，对齐 trained 模型） |
| qwen3 采样 temp0.6/topk20/topp0.95 | Qwen3-1.7B 采样起点 | **直接抄**（spike E3 调） |
| 非流式 `_async_parse_completion` | demo 解析 | **抄**（流式复杂，demo 不需） |
| HA 实体/服务体系、多 backend、config_flow | — | **drop**（HA 特有） |

## §8 关键工程洞察（for demo）
1. **单发是 TRAINED 小模型的实证默认**——home-1b/3b 全 `MAX_ITER=0`。MAformac 1.7B+LoRA 走单发，架构铁律有参考实现背书。
2. **"让小模型可靠"靠 code 不靠模型**：三层防御解析 + 值归一化 + 白名单 + KV 预热，全在 code。模型只做"模糊说→意图+近似参数"，精确/安全/格式 code 兜。
3. **冷启动有现成解**：KV 缓存预热（启动+状态变化），首句快。
4. **temp 张力**：home-llm trained 默认 0.1（确定性）vs qwen3 推荐 0.6——FC 确定性想低温，Qwen3 低于推荐可能降质 → spike E3 测 temp。
5. **GBNF 是 opt-in 保险**：trained 模型可能不需（格式已学会），但 1.7B 上 GBNF 保格式底座（XGrammar-2 实证 1B schema 22%→100%）。
</content>

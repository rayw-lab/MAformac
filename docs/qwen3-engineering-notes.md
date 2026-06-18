# Qwen3-1.7B 端侧工程硬约束与参考

> **定位**:Qwen3-1.7B + MLX 端侧工具调用的工程教训 + 外网经验 + 38 repo 肩膀。是 `define-execution-contract` / `define-capability-contract` / `define-lora-pipeline` / `define-vehicle-tool-bench` 的**权威输入**(propose 时引用)。
> **来源**:Codex 调研(2026-06-18,外网 + 38 repo 交叉)+ CC Step1 实证(见 `project/brainstorm-2026-06-17-demo-mvp.md §5 模块1`)。
> **核心判断**:Qwen3-1.7B 值得用、不降级 是对的;但「能吐工具格式」是**入场券不是终点**——真正要工程化的是 **restraint / parser hygiene / context budget / LoRA 样本边界**。

## 0. 结论:主线不降级(三方印证)

**Qwen3-1.7B + MLX + `enable_thinking=false` + 原生 `<tool_call>` 解析** = 对的。外网经验 + 本地 38 repo + Step1 实证三方一致。0.6B / FoundationModels / llama.cpp 仅备选 / 对照,不作默认(lessons B13)。

## 1. 「能 tool call」是表层信号 —— 真正的 4 个隐藏层(CC 内化框架)

格式对只过最外层;validate 和「能 tool call」都抓不到下面 4 层,这才是 change 3-6 的真骨头:

| 隐藏层 | 真问题 | 涉及教训 |
|---|---|---|
| **restraint(判断)** | 该调时调、该忍时忍 | 教训 1 |
| **parser hygiene(解析)** | malformed / think_leak / 多轮历史炸模板,皆常态非边缘 | 教训 2 / 4 / 5 |
| **context budget(资源)** | 标称 32K ≠ 能用 32K,KV cache 暴涨杀性能 | 教训 7 |
| **LoRA 样本边界(数据)** | LoRA 值钱在「约束行为」非「补知识」 | 教训 8 |

两条横切硬约束:`enable_thinking=false`(教训 2)、禁 ReAct stopword(教训 3);两条基础:schema 完整性(教训 6)、Release 真机验(教训 10)。

## 2. 十条工程教训(Codex 深挖,按杀伤力排序)

### 教训 1 — 工具调用是「判断问题」不是「格式问题」
模型会不会**该调用时调用、该忍住时忍住**才是核心。Qwen3:1.7B 20-run 拿 sub-2B 第一(Agent Score 0.960),但均 10.7s。**3 次样本不够,边界 prompt 至少 10-20 次才稳**。
→ `vehicle-tool-bench` 加 **restraint 用例**:「不要开空调」「天气已给别查」「已 26 度别再调」。
来源:https://github.com/MikeVeerman/tool-calling-benchmark

### 教训 2 — `enable_thinking=false` 是执行链硬约束(非偏好)
thinking 不只慢,还**破坏 tool parser**:LM Studio thinking tags 致解析失败;vLLM enable reasoning 后 `<tool_call>` 被塞进 content、不进 `tool_calls`。与 Step1 实证对上。
→ `define-execution-contract` 写 **MUST**:控制路径禁 thinking;输出含 `<think>` → trace 记 `think_leak`,eval 失败或降级澄清。
来源:https://github.com/lmstudio-ai/lmstudio-bug-tracker/issues/827 、https://github.com/vllm-project/vllm/issues/19513

### 教训 3 — 不用 ReAct stopword 模板
Qwen 官方:reasoning model **不建议基于 stopword 的 ReAct 工具模板**(thought 里可能出 stopword 触发意外工具)。
→ 不搞 ReAct;顺原生 `<tool_call>` → 解析 → 内部 `ToolCallFrame`。
来源:https://github.com/QwenLM/Qwen3/blob/main/docs/source/framework/function_call.md

### 教训 4 — 多轮工具历史炸 chat template
XML tool call 转 OpenAI-compatible 历史时,assistant 消息可能只有 `tool_calls` 没 `content`,模板读 `message.content` 会 500。
→ 内部**不存外部 message 原样历史**,存自己的 `DialogueTurn`,渲染成 runtime 需要的 prompt;assistant tool turn 补 `content: ""`。
来源:https://www.reddit.com/r/LocalLLaMA/comments/1klltt4/the_qwen3_chat_template_is_still_bugged/

### 教训 5 — malformed tool call 当常态防
TRL:Qwen3-1.7B 会产缺 `name` / `arguments` 的 `<tool_call>{}</tool_call>`。
→ `ToolCallDecoder` 区分错误枚举:缺 name / 缺 arguments / unknown capability / 参数类型错 / 参数越界。
来源:https://github.com/huggingface/trl/issues/4881

### 教训 6 — 工具 schema 不完整模型会犹豫
Step1 已踩:只给 `set_ac_temperature`(只温度),模型纠结「打开空调怎么 open」。
→ `capabilities.yaml` 是 prompt 质量的一半。`cabin.ac` 必须有 `power` + `target_temperature` + `delta`(或明确 action enum)。

### 教训 7 — context 是端侧性能杀手
OpenClaw Pi5:`num_ctx=16384` KV cache 暴涨不可用;cap 4096 + `think:false` + 短 system prompt 才稳。
→ 不因标称 32K 放大 prompt。候选工具收窄、system prompt 短、history 小、状态走结构化 store。
来源:https://github.com/mcleo-d/openclaw-pi-oss/blob/main/docs/05-ollama-model-research.md

### 教训 8 — LoRA 最值钱是「约束行为」非「补知识」
HomeDock:1000 条手写样本 + LoRA 保持极窄风格和边界;重点是**样本设计**。think traces 别算进 loss。
→ LoRA 数据主攻「中文口语 → 工具帧」「拒识 / 澄清」「边界 / unsafe」「readback 不一致不播成功」,非泛聊天。
来源:https://www.homedock.cloud/blog/self-hosting/how-we-fine-tuned-a-1-7b-llm-to-talk-like-a-ghost/ 、https://www.reddit.com/r/LocalLLaMA/comments/1kkl39r/findings_from_lora_finetuning_for_qwen3/

### 教训 9 — RL/tool training 奖励设计可借(非 MVP 必做)
AWS agent-training-kit tau2:reward = format + correctness,**correctness 权重 > 格式**。
→ MVP 不做 GRPO,但 `vehicle-tool-bench` 评分借此:格式对只 1 分,工具名 / 参数 key / 参数值才主体。
来源:https://github.com/awslabs/agent-training-kit/blob/main/examples/tau2/README.md

### 教训 10 — MLX/Apple 路线对,但 Swift 仍要单独验
本地 `mlx-swift-lm` 内置 `mlx-community/Qwen3-1.7B-4bit`;iOS benchmark:Qwen3-1.7B Release 下 MLX Swift 42.1 tok/s、load 0.68s,TTFT 不如 llama.cpp。
→ Python `mlx_lm.server`(Step1)只证原生格式,**不替代 Swift parser / Release / 真机**。Step2 同批 prompt 回归。

## 3. 外网经验(确认主线)

- Qwen3-1.7B = Apache 2.0 dense,32K context,thinking / non-thinking 双模式,agent + MCP;官方支持 `enable_thinking=False`(速度优先控制链)。https://qwenlm.github.io/blog/qwen3/ 、https://huggingface.co/Qwen/Qwen3-1.7B
- 工具调用:Qwen-Agent(官方)+ NimbleEdge(Android 实测 Qwen3 1.7B JSON + `<tool_call>` XML 多步)。https://github.com/QwenLM/Qwen-Agent 、https://github.com/NimbleEdge/deliteAI/pull/165
- MLX 生态:`mlx-community/Qwen3-1.7B-4bit` 可直接跑;Strands-MLX 给了 Qwen3-1.7B + tool + LoRA 完整模式。https://huggingface.co/mlx-community/Qwen3-1.7B-4bit 、https://strandsagents.com/docs/community/model-providers/mlx/ 、https://github.com/cagataycali/strands-mlx
- LoRA 配置:rank 8/16、alpha 16/32、dropout 0.05,target 从 `q_proj/v_proj` 起步、必要时扩 `q/k/v/o/gate/up/down`;坑:学习率太高过拟合、thinking traces 污染行为、拒答/边界样本必进。

## 4. 38 repo 巨人肩膀

- `ml-explore/mlx-swift-lm`:内置 `qwen3_1_7b_4bit`,直接对应 mlx-community 模型(Swift 主线 backend)。
- `wizcheu/iOSLLMFrameworkBenchmark`:实测 Qwen3-1.7B,**Release** 下 MLX Swift ~42 tok/s、内存 ~1.4GB;**性能必须 Release 测,不看 Debug**。
- `ggml-org/llama.cpp`:GGUF / 对照 runtime,非主线。
- `gorilla` / `tiny-tool-bench`:eval 思路(tool call + 多工具选择)。
- `Hammer` / MCP Swift SDK:二期 agent / MCP 预留。

## 5. 值得跟进的外部项目(储备)

- **Qwen-Agent**:官方 agent / tool calling / MCP cookbooks(parser + 工具模板参考)。
- **cagataycali/strands-mlx** ⭐:Apple Silicon 本地 agent + Qwen3-1.7B + LoRA pipeline,**和 MAformac 最贴近**。
- **NimbleEdge/deliteAI PR#165**:Android Qwen3 1.7B tool calling(移动端多步 + XML tag 解析)。
- **AndreyGermanov/qwen3_scientific_summarization**:Qwen3-1.7B-Base + PEFT/QLoRA 训练范例。
- **lixinyu66666/Qwen3-1.7b_finetune_sharegpt**:直接的 1.7B LoRA 脚本参考。

## 6. 落进后续 OpenSpec change 的硬约束

| change | 硬约束 |
|---|---|
| `define-execution-contract` | `enable_thinking=false`(MUST)、禁 ReAct、解析 `<tool_call>{json}</tool_call>`、错误枚举(缺 name/缺 args/unknown/类型错/越界)、`think_leak` trace、不存外部 message 原样历史(存 DialogueTurn、assistant tool turn 补 `content:""`) |
| `define-capability-contract` | 每 capability 完整 schema:description / required / enum / 边界 / readback;`cabin.ac` 含 power + target_temperature + delta |
| `define-lora-pipeline` | 数据集分桶:positive / ambiguity / unsafe / readback / no_think_formatting;约束行为非补知识;think traces 不算 loss;负样本必进 |
| `define-vehicle-tool-bench` | 每 case 跑 10-20 次;评分分层 format / tool_name / params / **restraint** / readback;**必含反关键词触发用例**;Release 真机延迟 / 断网无遥测 / 格式解析 / readback mismatch=0 |

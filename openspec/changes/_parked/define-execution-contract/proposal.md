## Why

模型输出是**不可信候选**,必须经「解析 → 校验 → 安全门 → mock 执行 → 读回」才能变成动作。`define-execution-contract` 锁这条执行链的**行为契约 + 错误枚举**,是「安全是代码不是 prompt、模型不直接执行」的落点。change1 walking skeleton 已立骨架(`DemoGuard` 单条放行占位、`ToolCallFrame.arguments` 用 `[String:String]` 占位),本 change 把它升级成完整执行链 + 严格错误处理。

**关键前提(pre-mortem 实证,见 `docs/execution-pre-mortem-2026-06-18.md`)**:`mlx-swift-lm` 已内置整套 tool-call parser(`ToolCallProcessor`/`JSONToolCallParser`/`ToolCall`,arguments 已是 `[String:JSONValue]`)——本 change **不自建 `<tool_call>` 解析器**,而是 adopt 上游 parser、`ToolCallFrame` 站其上做薄校验层。

## What Changes

- **E1 adopt 薄层**:`ToolCallFrame` = `mlx-swift-lm.ToolCall` 之上的内部契约层(加 enum + validator 二次校验),**不替代上游 parser**。
- **显式锁 format**(T2):load 后锁 `.json`,不依赖 `ToolCallFormat.infer()`(防 model_type 失配致 tool call 静默漏进普通文本)。
- **错误枚举三态区分**(T3):自写 `throws` decoder,把「无 tool call / malformed JSON / schema 不符」映射成不同枚举,供 `decode_failed → 澄清`。
- **arguments 全类型归一**(T5):string / object / 数组 / 标量都接,不限 `[String:Any]`;`ToolCallFrame.arguments` 从 change1 占位 `[String:String]` 升级为 `[String:JSONValue]`。
- **enum 严格解码**(T4):面向模型输出的 enum 手写 `init(from:)`(未知值落 `unknown` / 转 `decode_failed`),**全链路禁 `try!` / `try?`**。
- **两层 decode 边界**(E2):enum/validator 严格校验门挂第②层(`execute()` 前的 `decode(Input.self)`),非宽松 parser 层。
- **DemoGuard 完整代码门**:R0–R3(unknown tool / schema / 范围枚举 / writable / 风险等级 / 确认策略 / 互斥 bus / 前置条件),升级 change1 的协议位占位。
- **enable_thinking=false(MUST)**:控制路径禁 thinking;输出含 `<think>` → trace 记 `think_leak`,eval 失败或降级澄清。
- **TraceLogger 五段**:decode/plan/guard/execute/readback,显式记 `toolCalls.count` + `stopReason`(T2 指纹)。

## Capabilities

### New Capabilities
- `tool-execution`:模型候选 → 解析 → 严格 decode(错误枚举)→ DemoGuard 代码门 → mock 执行 → readback → trace 的行为契约。

### Modified Capabilities
(无)

## Non-goals

- ❌ 不实现 LLM 推理本身(`LLMBackend` 协议在 change1,具体 backend 留 runtime/voice change)。
- ❌ **不自建 `<tool_call>` parser**(adopt `mlx-swift-lm` 上游)。
- ❌ 不做 ASR / TTS(voice change)。
- ❌ 不降级(Qwen3-1.7B 主线;llama grammar 仅对照)。
- ❌ 不做 ReAct stopword 模板(reasoning model 不适用)。

## Success Criteria(可验收)

- **E3 spike 前置门**(第一个 task):用 `mlx-swift-lm` 喂 Qwen3-1.7B,量化 `.toolCall` 事件触发率;**收到 `.toolCall` 事件而非 `.chunk` 含 `<tool_call>` 原文**(T2 失配指纹)。
- **错误枚举**:「无 tool call / malformed / schema 不符(unknown tool / 缺 required / 类型错 / 越界)」各有测试,`decode_failed` 可达。
- `Unsafe false pass = 0`;unknown tool / 越界 / 缺字段 / 非法 enum **均拒执行**,不修正不猜测。
- **arguments**:string / object / 数组 / 标量 fixture 全过(T5)。
- `enable_thinking=false`;含 `<think>` → trace `think_leak` + 降级澄清。
- 全链路**无 `try!` / `try?`**;面向模型输出的 enum 手写 `init(from:)`。
- `readback mismatch = 0`(读回 mock 态才算成功)。

## Impact

- 升级 change1:`DemoGuard` 协议位 → 完整 R0–R3;`ToolCallFrame.arguments` `[String:String]` → `[String:JSONValue]`。
- 依赖 change2 `capabilities.yaml`(tool schema / demo_guard 规则 / 范围枚举的事实源)。
- 下游:`define-lora-pipeline`(训练数据 `expected_tool_call` 引本 frame)/ `define-vehicle-tool-bench`(eval format/tool_name/params/restraint 评分)。
- **对齐清单**(change1 审计 catch):visualState 枚举 + cell key 命名在 change2 对齐;arguments 类型本 change 升级。

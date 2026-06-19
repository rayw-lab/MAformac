## Context

`define-execution-contract` 升级 change1 walking skeleton(`DemoGuard` 协议位占位 → 完整门;`ToolCallFrame.arguments` `[String:String]` → `[String:JSONValue]`)。pre-mortem(`docs/execution-pre-mortem-2026-06-18.md`,oracle **直读 `mlx-swift-lm` 源码**)定了根架构:**adopt 上游 parser**。依赖 change2 `capabilities.yaml`(tool schema / demo_guard 规则 / 范围枚举的事实源)。

## Goals / Non-Goals

**Goals:** 执行链行为契约 + 错误枚举三态 + adopt 薄层 + DemoGuard 完整 R0–R3 + enable_thinking=false。
**Non-Goals:** 不自建 `<tool_call>` parser;不实现 LLM 推理(LLMBackend 具体 backend 留 runtime);不降级;不做 ReAct stopword 模板。

## Decisions

### 根架构决策 E1:ToolCallFrame = 薄校验层(adopt,非自建)
`mlx-swift-lm` 已有 `ToolCallProcessor` / `JSONToolCallParser` / `ToolCall`(arguments 已是 `[String:JSONValue]`,streaming 出 `.chunk`/`.toolCall`/`.info` 三态事件)。`ToolCallFrame` **站其上**:消费 `.toolCall` 事件 → enum/validator 二次校验 → 内部 frame。**不自建 XML/JSON parser**(自建 = 重造更差的轮子 + 与上游打架)。源码锚点:`Libraries/MLXLMCommon/Tool/{ToolCallFormat,JSONToolCallParser,ToolCallProcessor,ToolCall}.swift`。

### 审计回流决策 E1a:裸 JSON content-fallback = 候选修复,非 parser fork
spike E3 cross-vendor 审计把 G2 拆开:raw `.toolCall` 触发率是 31/40=77.5%,但 9 条 content 伪工具 100% 是裸 JSON(无 `<tool_call>` 标签),其中 7/9 工具名与参数语义可恢复;base 工具意图正确率应按 `28 raw expected hits + 7 recoverable bare JSON = 35/40 = 87.5%` 看。上游 `.json` parser 的格式样例是 `<tool_call>{"name":...,"arguments":...}</tool_call>`,stream processor 对 tagged format 不 fallback 裸 JSON,所以这是**格式通道问题 > 意图问题**。

落法:只加**窄 content-fallback 候选层**。当 `.chunk` 是单个裸 `{"name": "...", "arguments": {...}}` 形态时,正则/JSON decode 只产 `ToolCallCandidate(source: contentFallback, rawContent: ...)`;它**不得直接执行**,也不得重建 `<tool_call>` parser 或吞其它混排文本。候选必须进入同一第②层 `decode(Input.self)` 严格校验,再进 DemoGuard(R0–R3,含 restraint allowlist/deny rule),全部通过后才变成可执行 `ToolCallFrame`。

为什么不能裸接:spike 负例里也出现 2 条裸 JSON(`不要开空调`→`set_cabin_ac off`;`已经26度了,不要再调`→`query_cabin_comfort`)。如果 fallback 直接执行,G3 会从 1/15 恶化到最多 3/15;如果候选统一过 restraint/DemoGuard,positive 可恢复,negative 被代码门挡住,G3 不应恶化。

指标口径必须分开:
- **raw trigger**:只统计上游 `.toolCall` 事件,本次 31/40=77.5%。
- **fallback candidate trigger**:`.toolCall` + 裸 JSON candidate,positive 可接近 40/40,但仍只是候选。
- **expected tool intent hit**:工具名语义正确率,本次 35/40=87.5%。
- **G3 false execution**:只统计 guard 后实际会执行的误调;fallback 必须在 DemoGuard 前置下不恶化。

生死线裁决:GO。base 1.7B 意图够用,缺的是稳定 `<tool_call>` 包裹;change3 继续做 guard-first 的薄 fallback,change5 再用 LoRA 修格式稳定性。

### 两层 decode 边界 E2(validator 门挂对层)
- **第①层(上游 parser,宽松)**:arguments 解成 `[String:JSONValue]`,只校验 name + 结构。
- **第②层(`execute()` 前 `decode(Input.self)`,严格)**:enum / required / 类型 / 范围校验 = **`decode_failed` 错误枚举的产出处**。validator 门**必须挂第②层**(挂第①层 enum 校验根本不触发)。

### 升级后执行链(强制明确)
```
Qwen3 .toolCall 事件(mlx-swift-lm;load 后显式锁 format=.json,不靠 infer())
  or `.chunk` 裸 JSON content-fallback → ToolCallCandidate(source=contentFallback)
 → ToolCallFrame(薄层:第②层 decode(Input.self) 严格校验;fallback 只是候选)
 → 错误枚举三态:ok / no_tool_call / malformed / schema_invalid(unknown_tool|missing_field|type_mismatch|out_of_range)
 → retry≤1(仅 malformed)/ decode_failed → 澄清
 → DemoGuard 完整门 R0–R3(规则源 = capabilities.yaml.demo_guard)
 → DemoActionExecutor.applyMockTransition(唯一写入口)
 → DemoVehicleStateStore → readback(读回 actualValue 才算成功)
 → TraceLogger 五段 + 显式记 toolCalls.count / stopReason(T2 指纹)
```
**安全铁律**:DemoGuard 是代码门;模型只产候选;`pending/failed/unknown` 不播「已完成」。

### 关键决策表
| 决策 | 选 | 不选(原因) |
|---|---|---|
| parser | **adopt mlx-swift-lm 上游** | 自建(重造更差 + 打架) |
| content fallback | 裸 JSON 只产候选,过第②层 decode + DemoGuard 才执行 | 裸接 JSON / 重建 `<tool_call>` parser(放大误执行 + 违 adopt 薄层) |
| format | 显式锁 `.json` | `infer()`(model_type 失配 → tool call 静默漏进文本) |
| 错误 | `throws` decoder 三态枚举 | `parse()->nil`(无区分信号,decode_failed 不可达) |
| enum | 手写 `init(from:)` + `unknown` | 默认合成(未知值抛 `dataCorrupted`) |
| try | `do/catch` + 错误枚举 | `try!`(崩,违「不崩」)/ `try?`(吞 DecodingError) |
| arguments | `[String:JSONValue]` 全类型归一 | `[String:String]` / `[String:Any]`(丢数组/标量) |
| thinking | `enable_thinking=false`(MUST) | 开(破坏 tool parser) |
| validator 门 | 第②层 `execute()` 前 | 第①层 parser(enum 校验不触发) |

## Risks / Trade-offs(pre-mortem 实证,带来源)

- [T1 上游 parser 与自建职责重叠] → adopt 薄层(本 design AD)。源:`mlx-swift-lm` `ToolCallProcessor.swift` 源码。
- [T2 `infer()` 精确匹配 model_type → tool call 静默漏进 `.chunk` 文本、`stopReason=.stop`] → 显式锁 `.json` + smoketest 断言收 `.toolCall` 事件。源:[mlx-swift-lm #259](https://github.com/ml-explore/mlx-swift-lm/issues/259) / [mlx-lm #984](https://github.com/ml-explore/mlx-lm/issues/984) / [#1293](https://github.com/ml-explore/mlx-lm/issues/1293)。
- [T3 `parse()` 全失败归一 `nil`,无区分信号] → 自写 `throws` decoder 三态枚举。源:`JSONToolCallParser.swift`(`try?` 吞 DecodingError)。
- [T4 enum 加 `unknown` 不够,合成 decoder 仍抛 `dataCorrupted`] → 手写 `init(from:)` + 全链路禁 `try!`/`try?`。源:[sarunw decode enums](https://sarunw.com/posts/how-to-decode-enums-ignoring-case-in-swift-codable/) / [Vapor #1736](https://github.com/vapor/vapor/issues/1736)。
- [T5 arguments string-vs-object,上游只救 `[String:Any]`,数组/标量静默丢] → 自己全类型归一。源:[llama.cpp #20198](https://github.com/ggml-org/llama.cpp/issues/20198) / [qwen-code #379](https://github.com/QwenLM/qwen-code/issues/379)/[#783](https://github.com/QwenLM/qwen-code/issues/783)。
- [E3 Qwen3-1.7B base tool-call 可靠性未验证(小模型可能吐文本不吐 call)= 整链前置生死线] → spike 量化触发率。源:[mlx-swift-examples #221](https://github.com/ml-explore/mlx-swift-examples/issues/221) / [mlx-lm #1293](https://github.com/ml-explore/mlx-lm/issues/1293)。
- [E3 审计回流:裸 JSON fallback 会同时恢复 positive 和放大 negative] → fallback 只产候选,必须过第②层 decode + DemoGuard/restraint 才执行;trace 分开记 raw `.toolCall`、fallback candidate、guard 后实际执行。源:`dev/spike-e3/Reports/spike-e3-results.json` cross-vendor 审计。
- [P2 mlx-swift-lm 3.x breaking] → `Package.swift` pin exact tag,升级走 change。
- [change1 占位漂移对齐] → visualState 枚举 + store cell 集已在 change2 对齐(2026-06-18);**arguments `[String:String]`→`[String:JSONValue]` 经 change2 pre-mortem 确认归本 change**——提前到 change2 会因 `import MLXLMCommon` 拖入整个 mlx-swift Metal 栈 + swift-syntax,且绑死未经 E3 spike 验证的 adopt 路径(HIGH no-go)。切换时 `typealias` 指向上游 `Libraries/MLXLMCommon/Tool/Value.swift`(public 7-case enum:null/bool/int/double/string/array/object/null,Codable+Hashable+Sendable),**不自造**。源:[Value.swift](https://github.com/ml-explore/mlx-swift-lm/blob/main/Libraries/MLXLMCommon/Tool/Value.swift)。

## Migration Plan

升级 change1 产物:`DemoGuard` 协议位 → 完整 R0–R3 门;`ToolCallFrame.arguments` `[String:String]` → `[String:JSONValue]`;新增错误枚举 + 两层 decode。pin `mlx-swift-lm` exact tag。回滚 git revert。

## Open Questions

- content-fallback guard 后的真实 false execution rate 需在 change6 正式 benchmark 扩负例验证;当前 15 负例偏少。
- `decode_failed` / guard deny 的澄清话术(→ voice / capability change)。

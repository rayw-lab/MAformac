# define-execution-contract Pre-Mortem(2026-06-18)

> pre-mortem 第二战产物(scout `qwen3-engineering-notes`/GitNexus/Codex 02/Step1 + oracle CC subagent **直读 `mlx-swift-lm` 源码** + GitHub issue 实证)。供 change3 实装**直读源码锚点**。机制见 `~/.claude/skills/learned/pre-mortem.md`。
>
> **磊哥拍板(2026-06-18)**:E1 = adopt 上游薄层 ✅;E3 = spike 起手 ✅。
> **总判断**:执行链架构对,但 3 个认知偏差会炸——(a)「Swift 解析」其实 `mlx-swift-lm` 已内置整套 parser,要 **adopt 不自建**;(b)上游 parser 全失败归 `nil`,`decode_failed` 拿不到区分信号;(c)严格校验在 `execute()` 第二次 decode,validator 门要挂那层。

## 🐯 Tiger(直读源码 + issue 实证)
| # | 坑 | 来源 | mitigation |
|---|---|---|---|
| T1 | `mlx-swift-lm` 已有 parser,自建职责重叠/打架 | `ToolCallProcessor.swift` 源码 | **adopt 薄层**(ToolCallFrame 站 ToolCall 之上) |
| T2 | `infer()` 精确匹配 model_type → Qwen3 可能静默失配(tool call 漏进 `.chunk` 文本、`stopReason=.stop`) | [mlx-swift-lm #259](https://github.com/ml-explore/mlx-swift-lm/issues/259) / [mlx-lm #984](https://github.com/ml-explore/mlx-lm/issues/984) / [#1293](https://github.com/ml-explore/mlx-lm/issues/1293) | 显式锁 `.json` + smoketest 断言收 `.toolCall` 事件 |
| T3 | `parse()` 全失败归 `nil`,无区分信号(`decode_failed` 不可达) | `JSONToolCallParser.swift`(`try?` 吞 DecodingError) | 自写 `throws` decoder 三态 |
| T4 | enum 加 `unknown` 不够,合成 decoder 仍抛 `dataCorrupted` | [sarunw decode enums](https://sarunw.com/posts/how-to-decode-enums-ignoring-case-in-swift-codable/) / [Vapor #1736](https://github.com/vapor/vapor/issues/1736) | 手写 `init(from:)` + 禁 `try!`/`try?` |
| T5 | arguments string-vs-object,上游只救 `[String:Any]`,数组/标量静默丢 | [llama.cpp #20198](https://github.com/ggml-org/llama.cpp/issues/20198) / [qwen-code #379](https://github.com/QwenLM/qwen-code/issues/379) / [#783](https://github.com/QwenLM/qwen-code/issues/783) | 全类型归一 `[String:JSONValue]` |

## 🐅 Paper-tiger(基本被上游兜住 / 小影响)
- **P1** 流式 partial / 多 call / 夹文本 → 上游 `ToolCallProcessor` 4 态状态机已兜(复用,不自写)
- **P2** `mlx-swift-lm` 3.x breaking → 新项目 pin exact tag(无迁移痛)
- **P3** `@Observable`+`@MainActor` 并发 → 标 `@MainActor @Observable` + 禁 `Task.detached` 碰 store

## 🐘 Elephant(结构性)
- **E1** adopt vs 自建 = 根决策 → **adopt 薄层(磊哥拍)**;30min spike 验
- **E2** 两层 decode(parser 宽松 / `execute()` 严格)→ validator 门挂**第②层**
- **E3** Qwen3-1.7B base tool-call 可靠性**未验证** = 前置生死线 → spike 量化触发率(磊哥拍 spike 起手)

## 源码锚点(Codex 实装直读)
`mlx-swift-lm/Libraries/MLXLMCommon/Tool/`:
- `ToolCallFormat.swift`(`infer` + `createParser`;锁 `.json` 在此)
- `JSONToolCallParser.swift`(`normalizedToolCallData` 只救 `[String:Any]`;全失败归 `nil`)
- `ToolCallProcessor.swift`(4 态流式状态机 + bare-JSON 32KB fallback)
- `ToolCall.swift`(`arguments=[String:JSONValue]`;`execute()` 第二次 decode = 严格校验层)

## 落点(已进 change3)
proposal What Changes + design Decisions/Risks + tasks:spike `0.1` 起手 / 锁 `.json` `1.1` / arguments 归一 `1.2` / 两层 decode `1.3` / 错误枚举三态 `2.1` / 手写 init+禁 try! `2.2` / DemoGuard R0-R3 `3.1` / think_leak `3.2` / T2 指纹 trace `4.1`。

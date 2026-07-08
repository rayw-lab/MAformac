# INDEX — 2026-07-08 macOS UIUE 开发方法论调研归档包

> workflow `wf_41662345-ab4`(Claude Code Workflow 工具,14 agent 全 opus/medium)| 归档规矩 = `archive-research-pack` 三层一手性(README 二手派生 ⊋ lens 一手结构化 ⊋ transcript 最一手)。
> 脱敏:transcript 全量 grep `raw/|禁外传|/Downloads/` **零命中** → 可入仓,无仓外指针。

## 文件清单

| 文件 | 层 | 说明 |
|---|---|---|
| `README.md` | 二手派生 | 归档头(核验矩阵 + P0/P1/P2 分级 + grill 弹药)+ 综合官报告全文 |
| `lens01-apple-official.md` | 一手结构化 | Apple 官方:HIG/Liquid Glass/WWDC(13 findings + 核验 CLEAN) |
| `lens02-swiftui-arch.md` | 一手结构化 | SwiftUI 工程:架构/Previews/tokens/scene(14 findings + 核验 MINOR_ISSUES) |
| `lens03-design-process.md` | 一手结构化 | 设计流程:design system/Figma handoff/流程裁剪(13 findings + 核验 MINOR_ISSUES,UXPin 统计被戳穿) |
| `lens04-usability-review.md` | 一手结构化 | 可用性评审:Nielsen/macOS 维度/可访问性(15 findings + 核验 MINOR_ISSUES,2 处剔除) |
| `lens05-benchmark-apps.md` | 一手结构化 | 业界标杆:Raycast/Linear/Things 原生感(14 findings + 核验 CLEAN) |
| `lens06-ai-assisted.md` | 一手结构化 | AI 辅助 UI:截图闭环/幻觉/漂移(13 findings + 核验 CLEAN) |
| `lens07-local-baseline.md` | 一手结构化 | 本地基线(不联网):仓内资产 + 已锁决策 + 缺口(12 findings,file:line 可复核) |
| `transcripts/` | 最一手 | 见下表 |

## lens ↔ agent 映射(transcripts/agent-<id>.jsonl)

| lens | finder agent | 核验 agent |
|---|---|---|
| lens01 apple-official | `a4e896065ed42e9bf` | `ad8d232a52ce0ec15` |
| lens02 swiftui-arch | `ad1f39ed18932c6d7` | `a7e4f25c2bd15d91d` |
| lens03 design-process | `acc6ec755e5b49df9` | `a17dc8eedfdc3b1fe` |
| lens04 usability-review | `af1a59a80d14a80b4` | `a9044201502e2df6f` |
| lens05 benchmark-apps | `aa80a28a3bcfb1aa8` | `a274383dc8fbbfcd8` |
| lens06 ai-assisted | `a7d401f4344af01cc` | `a38869f6b9862e398` |
| lens07 local-baseline | `ae708b7ec7e67d8b7` | —(本地 file:line 自复核) |
| 综合官 | `a2941ddb8a46288c8` | — |

## transcripts/ 内容

- `agent-<id>.jsonl` ×14 — 各 agent 完整搜证过程(最一手)
- `journal.jsonl` — workflow 逐 agent 返回值账本
- `workflow-final.output` — workflow 最终返回(含截断前全文)
- `workflow-script.js` — 本次调研的 workflow 编排脚本(可复现)

原始运行落点(session 目录,可能随清理消失,以本目录拷贝为准):
`/Users/wanglei/.claude/projects/-Users-wanglei-workspace-MAformac/afad8683-e087-4112-99a2-ad5cda015a20/subagents/workflows/wf_41662345-ab4/`

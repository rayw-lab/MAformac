---
type: pre-mortem-archive-index
date: 2026-06-24
note: 归档清单 + agent↔topic 映射 + 脱敏说明 + transcript 指针。三层一手性见下。
---

# INDEX — 锁 iOS26 + Phase3 D7 pre-mortem 归档

## 文件清单（三层一手性）
| 层 | 文件 | 一手性 | 内容 |
|---|---|---|---|
| 综合（二手派生） | `README.md` | 二手综合 | pre-mortem 报告：3 加强核验 + 三分类 + HIGH + 级联清单 + §7 引用规范防呆 |
| 一手结构化 | `oracle-findings.md` | 一手（agent full return 原文）| 4 路 oracle full return，保 source URL+日期 |
| 最一手 | Agent transcript（见下指针） | 最一手（搜证全过程）| 各 agent 完整 WebSearch/WebFetch/curl 调用链 |

## agent ↔ topic 映射 + 搜证统计
| oracle | topic | agentId | 搜证 |
|---|---|---|---|
| 1 | Liquid Glass 官方边界 | `ad3b5d8134b9d8a50` | 7 WebSearch + 4 WebFetch + 1 curl（Apple materials.json HTTP200 坐实）|
| 2 | SwiftUI API 引入版本 | `a00368a613b1fb4f0` | 7 WebSearch + 1 WebFetch + 定向补证 |
| 3 | Xcode26 SPM deployment bug | `a22b9ec67faba9ea9` | 5 WebSearch + 3 WebFetch |
| 4 | iOS26 稳定性 + 截图管线 | `a2c1cbdf77fd7df63` | 8 WebSearch |
| 合计 | — | — | **28 WebSearch + 8 WebFetch + 1 curl** |

## transcript 指针（最一手）
- 本次用 **Agent tool**（subagent_type=claude）非 Workflow，transcript 落 `~/.claude/projects/<proj>/subagents/`（agentId 见上，可 SendMessage 续问）。
- full return（一手结构化）已落 `oracle-findings.md`——含各 agent 自报搜证次数 + source URL + 日期，可溯源；如需逐次工具调用全过程（最一手）按 agentId 翻 subagents transcript。

## 脱敏（§6 红线检查）
- ✅ **可入仓**：内容全为**公开技术信息**（Apple 官方文档 / SwiftUI API / Xcode bug / 社区文章），无 raw vault 引用 / 无 PII / 无报价成本 / 无车型代号 / 无禁外传语料。grep `raw/01-Wiki|raw/02-Raw|Downloads|禁外传` 零命中。
- 与 demo 演示无关的纯调研一手料，符合 §6 放宽（private 仓内部调研档可入）。

## 引用约定
- 写 spec/design/hig 引「Apple 官方边界」时，**必引 `oracle-findings.md 节1` 的 Apple verbatim 4 段**（带 materials.json URL），**严禁固化社区措辞**（"exclusively/best reserved for"）当 Apple 原话——见 README §7 防呆规范。

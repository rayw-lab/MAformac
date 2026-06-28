---
type: archive-index
date: 2026-06-26
topic: 2026 iOS 前端趋势 × MAformac 适配性筛选
commander: claude-commander (ma-ios-research tmux session)
---

# 归档清单

| 文件 | 层 | 内容 |
|---|---|---|
| `README.md` | 二手综合 | ⭐主报告：执行结论 + UIUE 树现状(file:line) + 三方提炼 + pre-mortem + **适配性矩阵(6列)** + 我的结论 + sources |
| `codex-repo-raw.md` | 一手 | codex-repo 原文（main 树 iOS/UI 结构盘点）⚠️审的是 main 树落后于 UIUE |
| `codex-web-raw.md` | 一手 | codex-web 原文（2026 趋势 + source list）⚠️版本以 oracle 核实为准 |
| `hermes-critic-raw.md` | 一手 | hermes-critic 原文（调研计划批判 + 6 列硬门建议）|
| `oracle-liquid-glass-firsthand.md` | 一手 | 我方 scout#1：Liquid Glass 5 tiger（投屏/对比度 HIGH）+ 版本核实 |
| `oracle-shell-nav-reorder-firsthand.md` | 一手 | 我方 scout#2：resizable/toolbar/reorder/TCA 坑 + 过度工程化判定 |

## 协作来源（ma-ios-research tmux session）
- codex-repo = pane %13（Codex CLI v0.142.2, gpt-5.5 high）
- codex-web = pane %11（Codex CLI v0.142.2, gpt-5.5 high, web search）
- hermes-critic = pane %12（Hermes TUI, glm-latest xhigh, Nous Research）
- oracle scout #1/#2 = CC 主线程后台 premortem-scout subagent（Claude, WebSearch/WebFetch）

## 关联既有档（本仓已有，本报告 cite 不重复）
- `docs/research/2026-06-24-ios26-lock-d7-premortem/` — iOS26 锁定 + D7 视觉消费 premortem（28 搜证 + Apple verbatim + 截图管线 HIGH）
- `docs/research/2026-06-25-portrait-interaction/` — 竖屏三屏空间分配 6-lens 调研（AD-12）
- 决策 SSOT：`openspec/changes/ui-presentation/design.md`（AD-1~AD-13）+ `docs/grill-tournament/grill-decisions-master.md`

## 边界
authority = research_not_ssot。本归档是调研综合，不是决策事实源。A1-A7 hardening spike 是否排期由磊哥拍。

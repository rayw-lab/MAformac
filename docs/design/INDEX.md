---
type: visual-ssot-index
status: DRAFT v1（视觉 SSOT 三件套入口；7 态色 + 视觉锚点 PNG 待磊哥审冻结）
date: 2026-06-23
owner: UIUE 链路A（worktree uiue/visual-ssot-state-consume）
---

# MAformac 视觉 SSOT（Single Source of Truth）入口

> 🔴 **agent 生成任何 UI（SwiftUI view / 卡片 / orb / 对话流）前，必读本目录**。
> 这是范式 C（纯 agent+skill+visual SSOT，不接 Figma，probe 结论）的视觉真源——把「深空辉光暗底科幻车机风」冻结成 agent 可读的色卡库 + 约束剧本 + 视觉锚点，压住 LLM 视觉方差（不锁→每次 prompt 漂移→「ChatGPT 默认蓝」模板，范式失败）。

## 视觉方向（已三路认证，非从零定）
**深空辉光暗底 + 三屏分层**（语音 orb 顶 / 对话流中 / 车控卡片下）。被 UIUE ultracode lens3/7/8 三路独立认证（对标 Polestar4/EQS + 2025 车控多模态共识 + iOS HIG，`raw/.../2026-06-22-uiue-ultracode/README.md:23`）。**Phase 0 不是从零定方向，是确认 + 冻结防漂移。**

## 三件套路由

| 文件 | 职责 | 何时读 |
|---|---|---|
| **`tokens.md`** | 色/字/间/动效**值**（锁 scheme1 一手 + U11/U2 拍板 + 7 态色映射） | 取任何色值/字号/间距/动效参数前 |
| **`hig-liquid-glass-rules.md`** | HIG **约束规则**（Liquid Glass functional-layer-only / iOS18 #available 守卫 / shader 氛围层 / 动效坑 / 5 Gate） | 写任何 SwiftUI view 前 |
| **`visual-anchors/`** | 2-3 张视觉锚点 PNG + 「学什么/不学什么」注 | 判断「长得对不对」时对照 |
| **`uiue-skill-playbook.md`** | 「什么 Phase/任务用什么 skill + 抄什么 ref-repos 代码 + 避什么坑」三列索引（Tools/skills teardown + lens5 adopt 清单 + pre-mortem 坑映射） | **实装任何 UIUE 任务前**，定位该调哪个 skill / 抄哪段代码 |

## 一手溯源
- 色值真源：`prototypes/scheme1-deep-space-interactive.html:8-83`（深空辉光交互概念稿）
- 决策真源：`docs/grill-tournament/grill-decisions-master.md §3`（U2/U5/U7/U10/U11/U19/U30）
- 调研真源：`raw/.../2026-06-22-uiue-ultracode/{README,GRILL-MASTER}.md`（8 lens / 79 findings）

## agent 使用约定（范式 C 核心）
1. **生成 UI 前**：读 `tokens.md` + `hig-liquid-glass-rules.md`（本 INDEX 路由）。
2. **取值**：色/字/间/动效**只从 tokens.md 取**，禁手填 hex / 禁 prompt 即兴。
3. **守规则**：Liquid Glass 只 functional layer、iOS18+ API 必 #available、关键态双通道（hig-rules）。
4. **验收**：交付前跑 5 Gate（hig-rules §6）+ **还原真实查看环境逐张 Read**（Mac/投影/iPhone，非看自己导出高清图）。
5. **新视觉决策**：先回写 SSOT（tokens/rules），再写 view（SSOT 单源，禁文档代码双源漂移）。

## 状态 / 待磊哥审冻结
- ✅ `tokens.md` 色/字/间/动效（锁 scheme1 一手）+ `hig-liquid-glass-rules.md`（锁 U 拍板）
- ⏳ **7 态色映射**（tokens §2，CC0 基于 scheme1 色板 + U10 四态语义设计）→ 待磊哥审 → 转 FROZEN
- ⏳ **visual-anchors/*.png**（playwright 截 scheme1 概念稿 3 视图，待生成）→ 待磊哥审「看着惊艳」确认 → 冻结防漂移

## 引用约定（建议级联进 CLAUDE.md / AGENTS.md）
> 在 `CLAUDE.md` 加一行（UIUE 合并时统一落，避免跨 worktree CLAUDE 冲突）：
> `- 🔴 生成任何 UI 前先读 docs/design/INDEX.md（视觉 SSOT，禁 prompt 即兴）`

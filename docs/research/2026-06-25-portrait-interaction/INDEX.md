# 竖屏全局 iOS 交互 ultracode 调研 — 归档 INDEX（2026-06-25）

> 6-lens finder + 综合官（workflow `ws21sjclj` / runId `wf_0973d78e-928`），承接 D1-D6 grill + 8-lens ultracode，补全局 iOS 交互 + 深化竖屏。Phase 4 全体（4a/4b/4c/Phase5）交互一体。

## 文件清单（三层一手性）

| 文件 | 层 | 内容 |
|---|---|---|
| `README.md` | 二手综合 | 综合官 full_report_markdown（鸟瞰+决策+4a影响） |
| `synth-structured.json` | 二手综合 | 综合官全字段（consolidated_design/cc_recommendation/task_4a_impact/open_questions/external_claims） |
| `00-grill-baseline-承接.md` | 主线程承接 | CC 读 D1-D6+Phase4 grill+8-lens 整理的已决框架（亲核参照基线） |
| `lens1-*.md` ~ `lens6-*.md` | 一手 finder | 各路 finder full_markdown（⚠️ lens2 竖屏布局 full_markdown 空，存结构化 findings/candidates 兜底） |
| 🔴 transcript（最一手） | 仓外 | `~/workspace/raw/05-Projects/MAformac/research/2026-06-25-portrait-interaction-transcripts/`（9 jsonl + workflow-result.output，3.3M；脱敏命中 raw 路径→归仓外，禁入仓） |

## lens ↔ 主题映射

| lens | agentType | 主题 | 一手档质量 |
|---|---|---|---|
| lens1 | doc-research-finder | 承接已决框架 + 4a gap map（28 findings） | ✅ 6695ch |
| lens2 | general-purpose | 竖屏布局形态横向候选 | ⚠️ full_markdown 空（findings/candidates 有） |
| lens3 | general-purpose | 全局 iOS 手势+微交互+层级（11 findings） | ✅ 7812ch |
| lens4 | general-purpose | ref-repos 代码范式+SwiftUI 动态布局（10 findings） | ✅ 4805ch |
| lens5 | general-purpose | 三者联动+微交互编排+层级巧思（10 findings） | ✅ 9675ch |
| lens6 | premortem-scout | 坑点 oracle+本机 pt+5min 体验流（14 findings） | ✅ 10191ch |

## 决策落点

- **Phase 4 全体竖屏交互设计** → `openspec/changes/ui-presentation/design.md AD-12`（承接稿）。
- **核心结论**：① 承接 grill 零推翻 ② 4a 与 grill 全对齐（Grid 双端统一非分歧）③ 竖屏 = 固定全景 idle + 活跃族原地放大 hero + ScrollViewReader 自动滚（修正 CC 自拍的「动态分配」）④ 三 zone/活跃置顶/触发聚焦 = Phase 5。

## cite-verify 状态（主线程亲核）

- ✅ `metasidd/Orb 422★ 2024-11-11 stale` + `CherryHQ/hanlin-ai 230★ 2026-05-31 活跃`（gh 坐实，synth 421/229 准确未编造）。
- ⏳ `symbolEffect repeatForever offscreen ~30% CPU`（lens 估值，4b breathe→TimelineView 前 Instruments 实测）。
- ✅ matchedGeometry/navigationTransition.zoom/geometryGroup 版本 = Apple 标准事实（grill D5 已坐实）。

## 后续

体验审计（subagent CC 用户演绎体验视角，进行中）→ 辩证收 → 4a 收口 + push + gptpro。

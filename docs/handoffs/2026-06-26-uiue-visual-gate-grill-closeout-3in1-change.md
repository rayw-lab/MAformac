# Handoff 2026-06-26 — UIUE 视觉门 grill 收口 + grill 体系规范统一 + 3合一 change artifact

> 🔴 **下个会话指挥官 = Codex**。worktree `MAformac-uiue`，分支 `uiue/phase4-default-scope-presentation`，HEAD `d535b7b`。本会话 = CC 主窗口，做了 codex 长跑审计 + UIUE 视觉门 grill 全收口 + grill 规范统一 + 3合一 change artifact 落地 + commit。**未碰 Swift/UI 代码**（全 grill/文档/change artifact 层）。
> **Codex 起手读链**：本文 → `docs/grill-tournament/GRILL-SYSTEM.md`（grill 规范+索引）→ `docs/grill-tournament/uiue-visual-gate-harden-grill-decisions.md`（U32-U37 决策 SSOT）→ `openspec/changes/ui-presentation/{design.md AD-15, tasks.md 8.G}`（你要 apply 的）。

## 本次完成（详细回顾）

### ① codex ~15h 长跑审计（磊哥让审计上一个 codex 长跑）
- jsonl `~/.codex/sessions/2026/06/25/rollout-...019eff79...jsonl`（492M/15111 行）。~15h / 2895 cmd / 35 compaction；**33× swift test + 151× xcodebuild + 3× make verify-all**（真跑）。**无 git reset/revert**——"23 M 文件"committed 成 `98f7c57`（+4290 行）没丢。
- verdict 诚实坐实 PARTIAL，8.A/8.C2 open，danger grep 空（无 fake-green）。CC 独立重跑 `swift test` 245/0 + `make verify` exit0 ✓。
- 🔴 **病灶 = Phase 2 像素 RMSE 死循环**：55× `phase2_zone_compare.py` + 241× magick + 截图 v1→v72 不收敛 → 磊哥叫停。这触发了本次"优化流程/机制/方法"。

### ② UIUE 视觉门 grill U32-U37（决策 SSOT = `grill-decisions-master.md §3` + `uiue-visual-gate-harden-grill-decisions.md`）
- **U32 视觉门四层 L0-L3（门/证据定位）**：L0 runtime-truth 真门（必 on-screen simctl 禁 off-screen ImageRenderer）/ L1 sentinel 有限机械门（只挡塌陷）/ L2 OCR+contrast 硬门 + SSIM 证据 / L3 人工 5-gate 唯一审美终裁。核心 frame = **L0/L3 真门 + L1/L2 哨兵证据，禁 L2 绿当 L3 pass**。
- **U33 zone_compare 降级**：RMSE → PASS/WARN/FAIL + long-run stop-rule（2 轮无新 proof-class 收口）。
- **U34 L2 指标**：SSIM+OCR+WCAG contrast；**LPIPS 不上**。
- **U35 negative-space**：进门只 Reduce Motion；投屏 DELETE（C0）；Dynamic Type/中文截断/多语言/RTL/晕动 DEFERRED。
- **U36 取证按控件动作分**：tap_step/toggle/badge_cycle 自动化 tap；continuous_drag（仅 AC hero ThermalRangeBar）operator-pass/真机；force_state=terminal_visual_only **禁当过程 proof**；代表族矩阵防单样本外推。
- **U37 一进两出 contract**：复用 `PresentationSnapshot`（不新建三类）；presentation derivation 只读 snapshot（mutation 层写 store 必回灌下一帧）；8 态 VUI 矩阵穷尽测试无 default。
- pre-mortem oracle：8 技术断言全核实（Applitools/SSIM/LPIPS/swift-snapshot/ImageRenderer-glass/WCAG/HIG），主线程亲核 ISO15008/7mm 无编造。

### ③ U11-U31 一把过收口 + 投屏 C0 删级联（catch 3 处遗漏全补）
- U11-U31 残余活跃组全 ⭐（U12-19/U26/U27/U30）；voice U21/U22/U28+U29 DEFERRED；二期 U20/U25。banner 在 master §3。
- **投屏 C0 删级联**：V10(`uiue-storyboard-grill-decisions.md:326`) + U23/U24 + `ui-presentation/tasks.md:112` 8.C2 全标 SUPERSEDED/DELETE。

### ④ grill 体系规范统一（磊哥要：全局规范 + 一个目录）
- 建 `docs/grill-tournament/GRILL-SYSTEM.md`（编号系列 Q/SD/RPB/U/V/AD/CC/D/E/G + canonical 目录 grill-tournament/ + 命名 + 全系列登记 + 分工）。
- 升级全局 `~/.claude/skills/grill-with-docs/SKILL.md`（加通用 Step 0「落档前探测现有 grill 体系→沿用/新开」，专属编号留项目内）。**注：skill 在 ~/.claude 不在本仓 commit**。
- 脏区 ignore：`.gitignore` 加 shots/zone-compare-v*（Phase2 死循环产物 687M 不入仓）。

### ⑤ 3合一 change artifact（磊哥拍 ABC 揉进现有 `ui-presentation` change，非新建，防分叉）
- `design.md AD-15`（视觉门 hardening 架构，承接 U32-U37）。
- `tasks.md 8.C2`（投屏 stale → L0-L3 验收口径）。
- `tasks.md 8.G`（ABC 9 实施 task）。`openspec validate ui-presentation --strict` = valid，34/74 tasks。

### ⑥ commit `d535b7b`（20 文件，pre-commit 三门全过）+ stale 修正
- 🔴 pre-commit `contentview-wiring` 暴露 **8.G5/D5 C22 stale**：ContentView 已 `Grid+GridRow`（`App/ContentView.swift:1504`），零 LazyVGrid → codex 长跑已做。已标 ✅已实装 + master D5 C22 supersede。

## 🔴 下一步 = Codex apply 8.G（内联决策+file:line，不必翻 grill 原文）

> **A-2 边界**：仍 PARTIAL，8.A/8.C2 视觉门 open。8.G 是视觉门 hardening + 代码，守 **mock 前台边界**（不接真 NLU/ASR/TTS/LoRA/backend）。

**B 流程（文档，先做，快）**：
- **8.G3** 回写 `docs/superpowers/plans/2026-06-25-a2-step2-uipresentation.md` 的 `## heavy-work harness 管控` 段 + 全局 `~/.claude/skills/heavy-work/SKILL.md`：加 **long-run stop-rule（2 轮无新 proof-class 强制收口）** + **截图链路纪律（必 on-screen `simctl io screenshot`，禁 off-screen ImageRenderer）** + **proof-class budget**。把"codex 烧 15h 追 RMSE 死循环"教训固化防复发。

**C 代码**：
- **8.G4** `Tools/checks/phase2_zone_compare.py:87`（`def rmse`）→ 输出改 **PASS/WARN/FAIL**（下限塌陷报警，禁输出 score 逼近分）+ stop-rule。【U33】
- **8.G6** `contracts/state-cells.yaml` 加 `ui_value_type` 派生字段（dial/percent/stepper/toggle/badge）——映射已在 `Core/Presentation/UIValueTypeMapper.swift:306`（mapping 已禁 default+闭合测试，**复用别另造**）；清残留 `hvac.*`（核 `contracts/function-spec-full-v0.yaml`/`capabilities.yaml`/`Core/State/DemoVehicleStateStore.swift` 哪些是活的 vs v0 历史）。【D3 C11】
- **8.G2** 8 态 VUI 矩阵测试：`DemoRuntimeResultKind`（`Core/Presentation/PresentationSnapshot.swift:3-11`，8 态 CaseIterable）allCases 每态有 视觉态+话术+动效+是否TTS+proof，**禁 default 吞**；复用 `FamilyDisplaysTests` 闭合模式。【U37】
- **8.G7** 取证 receipt 加 `evidence_kind` enum（tap_step/toggle/badge_cycle/continuous_drag/terminal_visual_only）；`terminal_visual_only`（force-state）**禁当过程 proof**；补代表族自动化样本矩阵（风量 stepper/座椅 stepper/车窗 percent/灯光 toggle 各 1 条 tap 样本）。【U36】
- **8.G8** Reduce Motion 降级路径（粒子/氛围灯/orb）+ **禁动效态也跑 L3 5gate**（防塌成白板）+ 静态「在思考」反馈（禁动效后客户不能以为卡死）。【U35】
- **8.G9** U14-U18 实装：Mac AnyLayout 并排不用 SplitView(U14) / HTML+Preview 都补 4 类反例[拒识/安全门](U15) / iPhone 触觉 Mac 不做(U16) / snapshot+黄金路径 XCUITest(U17，衔接 U32-U37 视觉门) / 客户物料不上架(U18)。
- **8.G1** L0-L3 门定义落 spec（`openspec/changes/ui-presentation/specs/ui-presentation/spec.md` 加 visual-acceptance Requirement）。
- **8.G5** ✅ 已做（ContentView Grid 固定列，跳过）。

## 关键约束 / 验收门（Codex 必守）
- **设备**：仿真 **iPhone 17 Pro / Pro Max**（主验收）；真机 **iPhone 15 Pro Max**（延后不急）。
- **scheme**：`MAformacMac` / `MAformacIOS`（🔴 不是 `MAformac`，codex 曾用错）。
- **验收门**：`swift test`（245/0）+ `make verify-all` + pre-commit 三门（no-binary-visualstate/platform-vs-version-guard/contentview-wiring）。
- **L3 人工 5-gate / continuous_drag operator-pass = 磊哥给**，机器/codex 不能签 V-PASS。
- **不降级原则**：取证手段可换（force-state/operator-pass），但视觉/交互/体验绝不降级。
- `.xcodebuildmcp/` profile=ios，simulator=iPhone 17 Pro Max；`session_show_defaults` 起手。

## 坑点
- 投屏已全删（C0），任何"投屏环境/⌃P/1080p 投屏"是 stale，别再实现。
- master §3 表旧 🔴/🟡 状态列以「U11-U31 一把过 banner」为准。
- 改 `contracts/` / codegen → 必跑 `make verify`（cross-section 段间一致门）。
- grill 决策引用走 GRILL-SYSTEM.md 导航；新 grill 接现有编号系列不另起（grill-with-docs Step 0）。

## 剩余 untracked（本轮未入仓，23 个）
phase6 证据图（zone-compare-phase6-capsule/route-spike）+ 漏网迭代目录（visual-diff-v45/zone-compare-main-stage-v1，建议加 .gitignore）。本轮里程碑 commit 只含 grill+change+规范文档。

## 下次第一步（Codex）
读起手链 → apply **8.G3（B 流程回写，快）** → 8.G4/8.G6（zone_compare/ui_value_type，机械）→ 8.G2/8.G7（VUI 矩阵/evidence_kind 测试）→ 8.G8/8.G9（Reduce Motion/U14-18，需 simctl 验收 + 磊哥 5-gate）。每 step 守验收门 + 分 commit。

> ✅ **AGREED（2026-06-24 磊哥审 spec agree，正式 propose 通过；B 严格 OpenSpec gate 解除）**：proposal/design/tasks/spec 已填实（**5 Req / 29 Scenario**，`openspec validate --strict` 绿）+ subagent CC 前端专项审计 CLEAR（2 P1 修复）。Phase 4 契约（R5 default_scope 消费 + 裂缝⑤⑥④）**文档先行**写定。
> 🔴 **apply 状态（claim-vs-reality）**：Phase 1b 工程前置 ✅ done（mic/speech/deployment 锁 iOS26/2 gate 已挂/tokens 冻结/截图管线）；**Phase 3 D7 7 态消费已 apply（commit `6a3e3f9`，审计 CLEAR）**；Phase 4 卡片 apply 待后端 `default_scope` 落 main（防返工）。
> **agree-before-build：spec 已 agree ✅；Phase 4 代码 apply 仅待后端 default_scope 交汇产物。** 决策权威源见下。
>
> 🟢 **非 DEFERRED（区别于 `define-demo-golden-run-and-voice`）**：本 change = **UIUE 链路 A 前端视觉/状态消费契约**，是与 A2/LoRA（链路 B）**并行活跃**的轨（worktree `uiue/visual-ssot-state-consume`），**不延后**。A2 只产 D-domain 后端 surface，本 change 管「看得见摸得着」那一层。Fork2 已拍：UIUE 视觉/卡片/7 态消费**拆独立 capability**（非塞进 demo-golden-run）。

## Why

demo 现役前端有三处现役债 + 范式翻案后的新缺口，目前散落草案/raw 档，无正式契约：

1. 🔴 **7 态压二值（头号现役债）**：`App/.../ContentView.swift:122/:126` 把 `DemoVisualState` 7 态压成 `visualState == .satisfied ? green : gray` 绿/灰二值；producer 已 ready（`Core/State/DemoVehicleStateStore.swift:17-25` 有 7 态枚举），consumer 没消费 → demo 的「智能拒识/澄清/安全门」卖点全渲成一坨灰，clarify（卖点）和 crash（真崩）分不开。
2. **视觉无 SSOT**：`docs/design/` 视觉 token 已落（本会话 Phase 1a），但「agent 生成 view 必读 + 7 态色/Liquid Glass 用法/卡片渲染」缺契约约束 → LLM 生成 view 视觉方差大、范式漂移。
3. **卡片渲染无 value.type 派生**：`contracts/state-cells.yaml` 有数据 `type`，但 UI 渲染要的 `ui_value_type`（dial/toggle/stepper/percent...）是另一维度（数据 type≠UI value.type），缺派生 → 卡片渲染靠 AnyView 散落，类型 diff 破、渲染慢。

D1-D7 二次深 grill（CC 5×⭐ + Codex 物理化 + 辩证 check）+ 30 决策盲评 3 轮 + 11 复议已收口决策，需把拍板物理化进 capability 契约，否则 UI 翻车（万能红字混 / 七态压二值 / 视觉漂移）。

本 change = **A2 之后/并行**新建 `ui-presentation` capability（UIUE 视觉/状态消费契约 SSOT），**依赖** `migrate-d-domain-tool-surface`（D-domain surface + state-cells 10 族，A2 已产）但**不依赖 LoRA 训练**（消费的是端态枚举不是模型）。

**决策权威源**：
- **D1-D7 决策晶体**：`docs/grill-tournament/grill-decisions-master.md §3`（U1-U31 + D1-D7 表 + 11 复议调整）
- **D1-D6 一手 grill**：`docs/grill-tournament/uiue-d1-d6-grill.md`
- **盲评 30 决策 + 复议**：`docs/loop-competition/uiue-grill-scoring/final-list.md`
- **视觉 SSOT**：`docs/design/{tokens.md,hig-liquid-glass-rules.md,INDEX.md}`（base #121212 / 7 态色 / surface_role）
- **路线图**：`docs/uiue-roadmap-2026-06-23.md`（7 Phase + 依赖图 + 合并策略）

## What Changes

> 以下指向已拍决策，**具体逐文件改法 = 各 Phase 落地 + `docs/grill-tournament/grill-decisions-master.md §3` 决策晶体的 A2 影响列**。

- **新建 `ui-presentation` capability**：`openspec/specs/ui-presentation`，吸收 D1-D7 + U1-U31 视觉/状态消费决策。
- **🔴 D7 7 态逐态视觉消费（头号刀）**：`ContentView` 绿/灰二值 → `DemoVisualState` 7 态**穷尽 switch**（实现 = `CardAppearance.of()` 值 switch + view 消费 appearance，无 default 吞态，编译器强制穷尽）；**四态分开**（`blocked_with_alternative` 琥珀 clarify ≠ `blocked_hard` 灰 unsupported ≠ `unsafe` 红 safety ≠ `unknown` 灰 crash）；消费 trace `guardReason/readbackResult`。
- **D3 卡片渲染 value.type 消费侧派生**（U26）：`ui_value_type` 在 **UI 消费侧从 `cell.key` 派生**（数据 type≠UI value.type；**不写回 `state-cells.yaml`、不给 Core struct 加字段**，对齐 design AD-2 / spec R2 consumer-side，防裂缝④第二份 SSOT）；`enum + switch(ui_value_type)` 穷尽渲染（**非 AnyView**）；FamilyCardLayout 按 10 族 `family_card_id`（U13，非 191 格）。
- **D5 状态切换动效 + 布局**：`Grid` 固定列（**非 `LazyVGrid(.adaptive)`**，C22）；`matchedGeometry` 状态切换（macOS 可用，非跨栈 zoom）按 promotion_criteria 5 条 gated upgrade（默认 opacityScale 兜底）。
- **D1 多调用编排**：boot_phase 7 态 enum + MultiCallSequencer(stagger_delay_ms=220) + MAX_CONCURRENT_HIGHLIGHTS=1 + VisualStateTransport。
- **D4 双端**：Mac+iPhone 两独立纯端侧 demo 实例（iPhone 脱机独立全功能接语音）；TransportKind{none,bonjour}（删 sharedFile 镜像）。
- **U2 Liquid Glass surface_role**：`control_glass`（mic/顶栏功能层）/ `content_glow`（内容卡自研 glow 非 system glass）；禁全局主题开关式 glass。
- **U7 native SwiftUI translation**：保 scheme1 深空辉光方向 ≠ 保现状代码；视觉值只从 tokens.md 取（base #121212）。
- **C8 高频代理**：卡片优先级用 A2 产 `generated/family-device-allowlist.json` 的 `row_count`（产品约定收窄，量产 priority 字段砍）。
- **🔴 D8 默认主驾 + default_scope 消费（R5，2026-06-24 grill 收口）**：卡片读 per-cell `default_scope`（G25 SSOT）锚定默认 scope（座位→主驾等），不弹区域 clarify；scope 呈现单一规则（默认淡显角标 / 非默认显式 / 全车 fan-out 聚合卡+badge / 多轮升级聚合范围词），卡片·TTS·readback 三处同源。依赖后端 `default_scope` 字段（独立 `define-demo-default-scope` change）。
- spec ADDED：`ui-presentation`（新 capability，5 Req / 29 Scenario）。

## Capabilities

- **ui-presentation**（new）：UIUE 视觉/状态消费契约 SSOT — DemoVisualState 7 态消费 + 卡片 value.type 渲染 + **default_scope 消费与 scope 呈现（默认主驾/淡显/聚合）** + Liquid Glass surface_role + 视觉 token 约束 + 双端展示 + 多调用编排。

## Files to modify（Phase 4a 卡片 scope 呈现摘要层，2026-06-25）

- `openspec/changes/ui-presentation/design.md`（AD-9/10/11 + 纠 AD-2 stale 路径）
- `Core/Presentation/FamilyCardIDMapper.swift`（new — device base→10 族派生，optional 返回，AD-9）
- `Core/Presentation/FamilyPrimaryCellMapper.swift`（new — 族→主 cell base，AD-10）
- `Core/Presentation/UIValueTypeMapper.swift`（加 `familyCardID` + `badgeStyle: BadgeRenderStyle` + `familyDisplays(from:catalog:)` 10 族常驻；复用 scope 聚合:54-129 不重写）
- `App/ContentView.swift`（vehicleCards `LazyVGrid`→`Grid` 渲 familyDisplays + scope 角标 + numericText + breathe + ambient 色块；三屏分层下层布局）
- `App/DebugGallery.swift`（force-state gallery 同步 family_card）
- `Tools/checks/check-contentview-uses-display-catalog.sh`（new — 接线 enforce gate，strip 注释 + 验真调用）
- `Tests/MAformacCoreTests/{FamilyCardIDMapperTests,FamilyPrimaryCellMapperTests}.swift`（new）+ 扩 `VehicleCardDisplayTests.swift`

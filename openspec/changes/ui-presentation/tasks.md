<!--
DRAFT SKELETON (2026-06-23) — tasks 占位待细化，人审定 propose 时展开为可验收逐项。
依赖序：本 change = UIUE 前端，依赖 migrate-d-domain([1] D-domain surface + state-cells 10 族，A2 已产) 但不依赖 LoRA 训练。
incremental（每 Phase 一个小 PR），禁大爆炸。Phase 映射见 docs/uiue-roadmap-2026-06-23.md。
-->

## 1. 前置依赖

- [ ] 1.1 确认 `migrate-d-domain-tool-surface` 已 archive / 或 UIUE worktree rebase main 拿到 A2 产物（`generated/family-device-allowlist.json` / `D_domain.tools.*` / state-cells 10 族）。
- [ ] 1.2 视觉 SSOT 三件套已落（`docs/design/{tokens.md,hig-liquid-glass-rules.md,INDEX.md}`，base #121212）✅ 已 done。

## 2. 工程前置硬门（Phase 1b，U6 demo-blocker，❌不依赖 A2）

- [ ] 2.1 `App/Info.plist`（NSMicrophoneUsageDescription）+ `App/MAformac.entitlements`（increased-memory-limit）。
- [ ] 2.2 `Availability.swift`（iOS18 `#available` 守卫封装，U19/U30）。
- [ ] 2.3 snapshot baseline（swift-snapshot-testing + ImageRenderer，视觉回归门）。

## 3. ui-presentation capability — 状态消费（Phase 3，🔴 D7 头号刀）

- [ ] 3.1 `ContentView` 绿/灰二值 → `DemoVisualState` 7 态穷尽 `@ViewBuilder switch`（DRAFT 待细化）。
- [ ] 3.2 四态分开（clarify 琥珀 / unsupported 灰 / safety 红 / crash 灰），色值从 tokens.md §2 取。
- [ ] 3.3 消费 trace `guardReason / readbackResult`。
- [ ] 3.4 每 view snapshot baseline。

## 4. 卡片渲染（Phase 4，部分依赖 A2 产物）

- [ ] 4.1 `state-cells.yaml` 加 `ui_value_type` 派生字段（数据 type≠UI value.type）。
- [ ] 4.2 `enum + switch(ui_value_type)` 穷尽渲染（非 AnyView）+ FamilyCardLayout 按 10 族 family_card_id。
- [ ] 4.3 `Grid` 固定列（非 LazyVGrid.adaptive，C22）。
- [ ] 4.4 卡片高频排序用 family-device-allowlist `row_count`（C8 复议#7）。
- [ ] 4.5 命名清债收尾（残留 2 处 `hvac.*` → ac.* — 确认是 A2 还是 UIUE 收，避免双写）。

## 5. 动效 + 双端（Phase 3/5）

- [ ] 5.1 `matchedGeometry` 状态切换 gated upgrade（promotion_criteria 5 条，默认 opacityScale 兜底）。
- [ ] 5.2 多调用编排（MultiCallSequencer stagger 220ms / MAX_CONCURRENT_HIGHLIGHTS=1 / FocusController）。
- [ ] 5.3 双端两独立实例 + TransportKind{none,bonjour}（D4）。

## 6. 验收

- [ ] 6.1 `swift test`（含 snapshot 回归）绿。
- [ ] 6.2 7 态各自有独立渲染分支（无 == .satisfied 二值压缩）。
- [ ] 6.3 视觉值全从 tokens.md 取（grep 无硬编 hex）。
- [ ] 6.4 spec ADDED `ui-presentation` 经 `openspec validate --strict`。

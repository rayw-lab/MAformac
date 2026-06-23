<!--
DRAFT SKELETON (2026-06-23) — delta 占位待补，人审定 propose 时细化 Requirement/Scenario。
本 delta ADDED 新 capability `ui-presentation`（target: openspec/specs/ui-presentation/spec.md，new_file）。
方向锚（grill-master §3 D1-D7 + U1-U31 + 11 复议 + design.md AD-1~AD-7）：
  - AD-1 7 态穷尽 switch + 四态分开（U10/D7）。
  - AD-2 ui_value_type 派生 + enum+switch 非 AnyView（D3/U26）。
  - AD-3 Grid + matchedGeometry gated（D5）。
  - AD-5 双端两独立实例 + TransportKind{none,bonjour}（D4）。
  - AD-6 Liquid Glass surface_role + tokens base #121212（U2/U7/U11）。
消费端态枚举 DemoVisualState（DemoVehicleStateStore:17-25），不碰模型/LoRA。
-->

## ADDED Requirements

### Requirement: ContentView SHALL render all 7 DemoVisualState cases distinctly with four-state separation

UI SHALL 对 `DemoVisualState` 7 态（normal/satisfied/changing/blocked_with_alternative/blocked_hard/unsafe/unknown）穷尽 `@ViewBuilder switch`，每态独立渲染分支；SHALL NOT 用 `== .satisfied ? a : b` 把 7 态压成二值；四态 SHALL 分开渲染（`blocked_with_alternative` 琥珀 clarify ≠ `blocked_hard` 灰 unsupported ≠ `unsafe` 红 safety ≠ `unknown` 灰 crash）；色值 SHALL 从 `docs/design/tokens.md §2` 取。

> DRAFT 占位 — Requirement/Scenario 待人审 propose 时按 grill-master §3 D7 + design.md AD-1 填实。

#### Scenario: seven states render distinctly (placeholder)
- **GIVEN** DRAFT 骨架（占位 Scenario，待 propose 填实）
- **WHEN** 人审定 propose
- **THEN** 在此填实 Scenario（7 态各有可区分视觉、clarify 不渲成 red、unsupported 不渲成 crash、消费 guardReason/readbackResult）

### Requirement: card rendering SHALL derive ui_value_type and use static enum switch

卡片渲染 SHALL 用 `ui_value_type`（数据 `type` 的派生字段，数据 type≠UI value.type）经 `enum + switch` 穷尽渲染；SHALL NOT 用 `AnyView`；卡片 SHALL 按 10 族 `family_card_id` 布局（非 191 格）；高频排序 SHALL 用 `generated/family-device-allowlist.json` 的 `row_count`（产品约定收窄）。

> DRAFT 占位 — 待 propose 时按 design.md AD-2 + C8/C11 复议填实（ui_value_type 候选 dial/toggle/stepper/percent/badge 的派生规则 + spike 实测 AnyView 性能）。

#### Scenario: cards render via ui_value_type switch (placeholder)
- **GIVEN** DRAFT 骨架
- **WHEN** 人审定 propose
- **THEN** 在此填实 Scenario（ui_value_type 派生映射、enum switch 穷尽、10 族布局、row_count 排序）

### Requirement: layout and transitions SHALL use Grid and macOS-available matchedGeometry with availability guards

布局 SHALL 用 `Grid` 固定列（非 `LazyVGrid(.adaptive)`）；状态切换动效 SHALL 用 `matchedGeometryEffect`（macOS 可用）而非 `navigationTransition.zoom`（macOS unavailable）；`matchedGeometry` SHALL 作 gated upgrade（默认 `opacityScale` 兜底，按 promotion_criteria 升级）；iOS18 API（含 MeshGradient）SHALL 用 `#available` + iOS17 fallback。

> DRAFT 占位 — 待 propose 时按 design.md AD-3 + D5 promotion_criteria 5 条填实。

#### Scenario: Grid layout and gated transition (placeholder)
- **GIVEN** DRAFT 骨架
- **WHEN** 人审定 propose
- **THEN** 在此填实 Scenario（Grid 固定列、matchedGeometry gated、availability 守卫、低端机 opacityScale 兜底）

### Requirement: presentation SHALL run as two independent on-device instances with token-driven visuals

demo SHALL 作 Mac + iPhone 两独立纯端侧实例（iPhone 脱机独立全功能）；transport SHALL 为 `TransportKind { none, bonjour }`（无 sharedFile 镜像）；视觉值 SHALL 只从 `docs/design/tokens.md` 取（base `#121212`，禁手填 hex）；Liquid Glass SHALL 只用功能层 `control_glass`（mic/顶栏），内容卡 SHALL 用 `content_glow` 自研 glow（非 system glass）。

> DRAFT 占位 — 待 propose 时按 design.md AD-5/AD-6 + D4 + U2/U7/U11 填实。

#### Scenario: two independent instances, token-driven (placeholder)
- **GIVEN** DRAFT 骨架
- **WHEN** 人审定 propose
- **THEN** 在此填实 Scenario（iPhone 脱机独立演示、TransportKind 切换、视觉值单源 tokens、Liquid Glass 仅功能层）

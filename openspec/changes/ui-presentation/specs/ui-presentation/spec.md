<!--
PROPOSE-READY (2026-06-24) — Scenario 已填实（磊哥拍 A：晶体化 D1-D7 已拍决策，不引入新决策；CC0）。
本 delta ADDED 新 capability `ui-presentation`（target: openspec/specs/ui-presentation/spec.md, new_file）。
边界：只消费端态枚举 DemoVisualState（Core/State/DemoVehicleStateStore.swift:17-25）+ UI 消费侧派生，不碰模型/LoRA/producer 契约。
色值：引 docs/design/tokens.md §2 的「色彩语义分类」（satisfied/changing/clarify/unsupported/safety/crash 语义角色），不锁具体 hex（hex 留 Phase 3 实渲微调冻结）。
方向锚：grill-master §3 D1-D7 + U1-U31 + 11 复议 + design.md AD-1~AD-7。
-->

## ADDED Requirements

### Requirement: ContentView SHALL render all 7 DemoVisualState cases distinctly with four-state separation

UI SHALL 对 `DemoVisualState` 7 态（normal/satisfied/changing/blocked_with_alternative/blocked_hard/unsafe/unknown）**穷尽 switch**（实现自由：值 switch 如 `CardAppearance.of()` / `@ViewBuilder` view-switch 均可，**SHALL 无 default 吞态**=编译器强制穷尽），每态独立渲染分支；SHALL NOT 用 `== .satisfied ? a : b` 把 7 态压成二值，SHALL NOT 用 `default:` 兜底吞态；四态 SHALL 分开渲染（`blocked_with_alternative` 琥珀 clarify ≠ `blocked_hard` 灰 unsupported ≠ `unsafe` 红 safety ≠ `unknown` 灰 crash）；色彩语义 SHALL 从 `docs/design/tokens.md §2` 取（语义分类，不锁 hex）。

#### Scenario: normal renders dim idle card
- **GIVEN** 一张卡片 `visualState == .normal`
- **WHEN** ContentView 渲染该卡片
- **THEN** 渲染为「灰蓝静默」（tokens.md §2 `normal` 语义：未激活中性），无辉光、无脉冲、无告警色

#### Scenario: satisfied renders glow breathing card
- **GIVEN** `visualState == .satisfied`
- **WHEN** 渲染
- **THEN** 渲染「青紫辉光 + 呼吸动效」（tokens.md §2 `satisfied` 语义：已激活强调）
- **AND** 视觉区别于 `changing` 的不停脉冲（呼吸=稳定已完成，脉冲=执行中）

#### Scenario: changing renders pulsing card
- **GIVEN** `visualState == .changing`
- **WHEN** 渲染
- **THEN** 渲染「cyan 脉冲」（tokens.md §2 `changing` 语义：执行中过渡）
- **AND** 表达「正在执行」而非「已完成」，不与 `satisfied` 坍缩

#### Scenario: blocked_with_alternative renders amber clarify (card-level blocked+alternative, demo 少用态)
- **GIVEN** `visualState == .blocked_with_alternative`（**卡片级 blocked+替代**，如「空调调到16度」超 min18 → 「最低18℃，已调到18」；D8.2 demo 少用态：能自动替代即 satisfied，此态主线几乎不触发）
- **WHEN** 渲染
- **THEN** 渲染「琥珀提示」（tokens.md §2 clarify 语义色）+ 替代值/原因（消费 guardReason/readbackResult）
- **AND** SHALL NOT 渲染成 `unsafe` 的红 或 `unknown`(crash) 的灰错误 —— clarify 是卖点不是错误
- **AND** SHALL NOT 用于区域歧义（D8.1 区域默认主驾不澄清）或对话级歧义（「打开」开什么 → orb `think` 层非卡片态）

#### Scenario: blocked_hard renders gray lock unsupported, never red
- **GIVEN** `visualState == .blocked_hard`（unsupported 优雅拒识）
- **WHEN** 渲染
- **THEN** 渲染「灰锁」（tokens.md §2 unsupported 语义）
- **AND** SHALL NOT 渲染成红 或 琥珀 —— 不支持是优雅拒识，不是告警/澄清

#### Scenario: unsafe renders red safety boundary as the only red state
- **GIVEN** `visualState == .unsafe`（安全门拒识）
- **WHEN** 渲染
- **THEN** 渲染「警示红描边」（tokens.md §2 safety 语义）
- **AND** 红 SHALL 仅用于此态——安全门是唯一该用红的态

#### Scenario: unknown renders neutral gray crash, distinct from unsafe
- **GIVEN** `visualState == .unknown`（crash/真错误）
- **WHEN** 渲染
- **THEN** 渲染「中性灰 + 错误图标」（tokens.md §2 crash 语义）
- **AND** SHALL NOT 渲染成 `unsafe` 的安全红 —— 系统错误区别于安全拒识

#### Scenario: exhaustive switch, no default fallback, no binary collapse
- **GIVEN** ContentView 消费 `DemoVisualState`
- **WHEN** 编译与渲染
- **THEN** 用穷尽 switch（值 switch `CardAppearance.of()` 或 `@ViewBuilder`，无 default），7 态各有独立 case 分支
- **AND** SHALL NOT 有 `default:` 兜底吞态，SHALL NOT 用 `== .satisfied ? a : b` 把 7 态压成二值

#### Scenario: four result states are pairwise visually distinct
- **GIVEN** clarify(`blocked_with_alternative`) / unsupported(`blocked_hard`) / safety(`unsafe`) / crash(`unknown`) 四个结果态
- **WHEN** 渲染
- **THEN** 四态两两视觉可区分（琥珀 ≠ 灰锁 ≠ 红 ≠ 中性灰）
- **AND** SHALL NOT 任意两态坍缩到同一渲染

#### Scenario: consume trace fields for reason text
- **GIVEN** store 提供 reason（来源 = 统一 `reasons:[String:String]` @Observable map，cell 无 reason 字段符 DA1；E 组 E7）
- **WHEN** 渲染 clarify/unsupported/safety/crash 态的提示文案
- **THEN** UI 消费 `store.reason(for: cell.key)` 呈现原因（VehicleStateCard.reason），SHALL NOT 硬编码文案
- **AND** reason **主承载 guardReason（blocked 态原因）**；satisfied 的 readback 归 **orb（E2 handoff）非卡片**（E 组 E7）。DA0 deny→态来源 = store `applyGuardBlock`（E5）+ reason→态映射（E6）= **Phase 5 执行链路接入**（详见 grill-master §3 E 组）

#### Scenario: zone scope defaults to driver, no clarify interruption (D8.1)
- **GIVEN** 区域 scope 功能点（空调温度/座椅/车窗等，main:state-cells.yaml scope=[主驾,副驾,...]）用户未指定区域
- **WHEN** 渲染卡片
- **THEN** 卡片默认锚定默认 scope 态（座位→主驾 / 屏类→中控屏 / 前后→前·前排），渲染 satisfied/changing
- **AND** SHALL NOT 渲「请选区域」空态/占位，SHALL NOT 弹 clarify 澄清打断（scope 默认值执行逻辑 = NLU/Core，UIUE 只展示默认态）

### Requirement: card value rendering SHALL derive ui_value_type on the consumer side and use a static enum switch

卡片值渲染 SHALL 在 UI 消费侧从 `ui_value_type`（enum: dial/toggle/stepper/percent/badge）派生显示形态，SHALL NOT 解析 unit string（如 "℃"/"档"/"%"）决定渲染；SHALL 用 `enum + switch(ui_value_type)` 穷尽渲染，SHALL NOT 用 `AnyView`；卡片 SHALL 按 10 族 `family_card_id` 布局（非 191 格）。本 capability 是消费契约，SHALL NOT 要求 producer/contract 新增字段。

#### Scenario: ui_value_type derived on consumer side without reading unit string
- **GIVEN** 一张 state cell（含 value + unit 原始数据）
- **WHEN** UI 决定渲染形态
- **THEN** 从消费侧 `ui_value_type` enum 派生显示形态，SHALL NOT 解析 unit string 决定渲染
- **AND** 派生逻辑在 ContentView 上层消费侧，producer/契约不被本 capability 约束、不新增字段

#### Scenario: each ui_value_type has a dedicated render branch
- **GIVEN** `ui_value_type ∈ {dial, toggle, stepper, percent, badge}`
- **WHEN** 渲染卡片值
- **THEN** 每个 ui_value_type 有独立渲染分支（dial=环形仪表连续值 / toggle=开关 / stepper=档位 / percent=百分比 / badge=状态徽章）

#### Scenario: static enum switch, no AnyView
- **GIVEN** 卡片值渲染
- **WHEN** 编译
- **THEN** 用 `enum + switch(ui_value_type)` 保静态类型与高效 diff
- **AND** SHALL NOT 用 `AnyView`（破类型 diff / 渲染慢）

#### Scenario: cards laid out by 10-family family_card_id with row_count ordering
- **GIVEN** 10 族卡片
- **WHEN** 布局排序
- **THEN** 卡片按 10 族 `family_card_id` 布局（非 191 格 / 非旧 102）
- **AND** 高频排序用 `generated/family-device-allowlist.json` 的 `row_count`（A2 产物，UIUE rebase main 读；产品约定收窄，不引入量产 priority 字段）

### Requirement: layout and transitions SHALL use Grid and macOS-available matchedGeometry with availability guards

布局 SHALL 用 `Grid` 固定列（SHALL NOT 用 `LazyVGrid(.adaptive)`）；状态切换动效 SHALL 用 `matchedGeometryEffect`（macOS 可用）而非 `navigationTransition.zoom`（macOS unavailable）；`matchedGeometryEffect` SHALL 作 gated upgrade（默认 `opacityScale` 兜底，按 promotion_criteria 升级）。demo App target deployment 锁 **iOS26/macOS26**，MeshGradient(iOS18)/glassEffect(iOS26)/matchedGeometry(iOS14) 引入版本均 ≤ deployment，故 SHALL NOT 加 `#available` 版本守卫；`navigationTransition.zoom`（macOS unavailable）SHALL 用**平台守卫 `#if !os(macOS)`**（非版本守卫，因 macOS 缺该类型）。

#### Scenario: fixed-column Grid, not adaptive LazyVGrid
- **GIVEN** 卡片网格布局
- **WHEN** 布局
- **THEN** 用 `Grid` 固定列
- **AND** SHALL NOT 用 `LazyVGrid(.adaptive(...))`（避免列数随窗口漂移破视觉稳定）

#### Scenario: matchedGeometry as gated upgrade with opacityScale fallback
- **GIVEN** 状态切换动效
- **WHEN** 默认渲染
- **THEN** 默认用 `opacityScale` 兜底动画
- **AND** `matchedGeometryEffect` 仅作 gated upgrade，按 promotion_criteria 满足才升级；低端机/低电量回落 opacityScale，态仍可读

#### Scenario: locked to iOS26/macOS26 — version guards dropped, platform/a11y guards kept
- **GIVEN** demo App target deployment = iOS26/macOS26（Package.swift Core 仍 v17/v14 隔离）
- **WHEN** 用 MeshGradient / glassEffect / matchedGeometry
- **THEN** SHALL NOT 加 `#available(iOS 17/18, *)` 版本守卫（deployment 已 ≥ 各 API 引入版本）
- **AND** `navigationTransition.zoom` SHALL 用 `#if !os(macOS)` 平台守卫（非版本）；ReduceMotion/低电量 SHALL 保留双通道（a11y 非版本守卫）

#### Scenario: navigationTransition.zoom not used because macOS unavailable
- **GIVEN** 跨视图缩放过渡需求
- **WHEN** 选 API
- **THEN** 用 macOS 可用的 `matchedGeometryEffect`
- **AND** SHALL NOT 用 `navigationTransition.zoom`（macOS unavailable）

### Requirement: presentation SHALL run as two independent on-device instances with token-driven visuals and functional-layer-only Liquid Glass

demo SHALL 作 macOS（MAformacMac）+ iOS（MAformacIOS）两独立纯端侧实例，iPhone 脱机独立全功能；transport SHALL 为 `TransportKind { none, bonjour }`（无 sharedFile 镜像）；两端核心展示语义（7 态 + 卡片）SHALL 统一、SHALL NOT 为 macOS 单独豁免（动效/glass 层按 ReduceMotion/低电量**双通道降级 = a11y 非版本豁免**；平台差异 API 如 `navigationTransition.zoom` 用 `#if !os(macOS)` 平台守卫）；视觉值 SHALL 只从 `docs/design/tokens.md` 取（色彩语义分类，禁手填 hex）；Liquid Glass SHALL 只用功能层 `control_glass`（mic/顶栏，Apple 官方：floats above the content layer），内容卡 SHALL 用 `content_glow` 自研 glow（Apple 官方：Don't use Liquid Glass in the content layer）；例外 = 内容层 transient 交互控件（slider/toggle）激活时 MAY 用 glass（Apple 官方点名正确用法）。

#### Scenario: both macOS and iOS targets render all 7 states (core semantics not waived)
- **GIVEN** macOS target (MAformacMac) AND iOS target (MAformacIOS)
- **WHEN** 各自渲染
- **THEN** 两端都渲染全 7 态 + 卡片核心展示语义
- **AND** SHALL NOT 为 macOS 单独豁免某态/某卡片（双端展示语义统一）

#### Scenario: motion degrades via ReduceMotion/low-power dual-channel, not core waiver
- **GIVEN** ReduceMotion / 低电量模式开启，或平台差异 API（`navigationTransition.zoom` macOS unavailable）
- **WHEN** 动效不可用/被禁
- **THEN** 关键态用颜色/数值/图标承载（双通道），动画只锦上添花，态语义仍可读
- **AND** 这是 a11y/平台降级，SHALL NOT 当核心展示语义豁免；锁 iOS26 后无版本 fallback 分支

#### Scenario: iPhone runs standalone offline
- **GIVEN** iPhone 实例
- **WHEN** 断网 / 无 Mac
- **THEN** iPhone 脱机独立全功能（端态自包含），transport = `TransportKind { none, bonjour }`，无 sharedFile 镜像
- **AND** `bonjour` 仅可选联动，非脱机独立的必需依赖

#### Scenario: visual values come from tokens semantic classes, not hardcoded hex
- **GIVEN** 任一视觉渲染
- **WHEN** 取色/字/间距
- **THEN** 只从 `docs/design/tokens.md` 取（引「色彩语义分类」：satisfied/changing/clarify/unsupported/safety/crash 语义角色）
- **AND** SHALL NOT 在 view 里手填 hex；具体 hex 由 tokens.md 单源提供，Phase 3 实渲可微调冻结，本 spec 不锁死 hex

#### Scenario: Liquid Glass only on functional control layer
- **GIVEN** Liquid Glass 用法
- **WHEN** 决定 surface_role
- **THEN** 仅功能层 `control_glass`（mic 按钮/顶栏）用 Liquid Glass，内容卡用 `content_glow`（自研 cyan/violet glow，非 system glass）
- **AND** SHALL NOT 用全局主题开关式 glass（内容层 glass = 整屏糊 + HIG 违规）
- **AND** 例外：内容层 transient 交互控件（slider/toggle）激活时 MAY 用 glass（Apple 官方点名正确用法，车控温度滑块/风量 toggle 适用）

### Requirement: card SHALL consume per-cell default_scope and render scope per the single display rule

卡片 SHALL 读 per-cell `default_scope`（G25 SSOT 字段，磊哥拍字段名）锚定默认 scope 态，SHALL NOT 手写默认值（防裂缝④第二份 SSOT），SHALL NOT 渲染「请选区域」空态；scope 呈现 SHALL 遵循**单一规则**：默认 scope = 淡显角标（低对比）/ 非默认 scope = 显式呈现；显式全车 fan-out SHALL 渲染 **1 聚合卡 + 范围 badge**（不分裂 N 张，不违反 `MAX_CONCURRENT_HIGHLIGHTS=1`）；多轮叠加 scope SHALL 升级聚合成范围词；卡片 / TTS / readback 三处 scope 呈现 SHALL 同源（裂缝⑤）。本 Requirement 依赖后端 `default_scope` 字段（Phase 4，UIUE rebase main 拿到后 apply）。

> 文档先行（agree-before-build B 流程）：本 Requirement = Phase 4 契约，Scenario 现在锁定，代码 apply 待后端 `default_scope`/fan-out 落 main（防返工）。决策源 = grill-master §3 D8 裂缝小节（⑤B淡显/⑥c badge/④a聚合，2026-06-24 用户故事全拍）+ design AD-8.7。

#### Scenario: default scope renders dim badge (裂缝⑤ B 淡显)
- **GIVEN** 区域 scope cell 用户未指定（如「打开车窗」→ 读 `default_scope`=主驾）
- **WHEN** 渲染卡片
- **THEN** 渲染「车窗 100%」+ **淡角标「主驾」**（低对比，客户知范围但不打断）
- **AND** SHALL NOT 完全省略（客户分不清主驾/全车）、SHALL NOT 默认就显式啰嗦；卡片/TTS/readback 三处同源（默认都淡显）

#### Scenario: explicit non-default scope renders explicit (副驾)
- **GIVEN** 用户显式非默认 scope（如「打开副驾车窗」）
- **WHEN** 渲染
- **THEN** 卡片「副驾车窗 100%」+ TTS「副驾车窗已打开」+ readback「副驾车窗开度100%」三处**都显式「副驾」**

#### Scenario: explicit all-vehicle fan-out renders one aggregate card with range badge (裂缝⑥ c)
- **GIVEN** 用户显式全车（如「打开全车车窗」，后端 fan-out N cell）
- **WHEN** 渲染
- **THEN** 渲染 **1 张聚合卡 + 「全车」范围 badge**（青标签）
- **AND** SHALL NOT 分裂成 N 张卡、SHALL NOT 违反 `MAX_CONCURRENT_HIGHLIGHTS=1`（聚合 1 卡 = 单点高亮）

#### Scenario: multi-turn scope accumulation upgrades to range word (故事④ a)
- **GIVEN** 「打开车窗」(主驾) 后「副驾也打开」(G20 显式二轮 passthrough)
- **WHEN** 渲染
- **THEN** 卡片**升级聚合成范围词**「前排车窗 100%」（跟全车聚合同逻辑）
- **AND** SHALL NOT 渲成主驾/副驾双角标（多 scope 都聚合成范围词，视觉一致）

#### Scenario: default_scope consumed from SSOT, not hardcoded (裂缝④)
- **GIVEN** 卡片决定默认 scope
- **WHEN** 取默认值
- **THEN** 读 state-cells `default_scope`（G25 单一 SSOT）
- **AND** SHALL NOT 在 UIUE 手写 per-cell 默认表（座位→主驾等仅决策举例非权威值）

### Requirement: UIUE demo interactions SHALL remain mock-frontstage and SHALL NOT claim runtime readiness

完整 demo 交互（触摸调节 / 语音推理 / 演绎控制台 force / 氛围灯炸场）SHALL 全 **mock 前台**（mock store 写 + mock snapshot 切 + mock 预设响应），SHALL NOT 接真 NLU/ASR/TTS/LoRA/runtime backend，SHALL NOT claim endpoint-ready/voice-ready/model-quality/V·S·U-PASS readiness。storyboard SD7「UIUE 边界放宽碰 Core/State 完整链路」SHALL 解读为 **mock 实现**（等后续接线，见 SD7 amendment）。

#### Scenario: interactions are mock, not real backend
- **GIVEN** 触摸调节 / 语音推理 / 控制台 force 任一交互
- **WHEN** 交互发生
- **THEN** 写 mock `DemoVehicleStateStore` / 切 mock snapshot / 出 mock 预设响应
- **AND** SHALL NOT 调用真 NLU/ASR/TTS/LoRA，SHALL NOT claim runtime readiness（proof_class = localMock/staticPreview）

### Requirement: expanded-card controls SHALL update mock state and presentation only

展开卡（4b composite）数值控件（dial/percent/stepper/toggle/badge）SHALL 写 mock `DemoVehicleStateStore`（via `applyMockTransition`）并刷新 `PresentationSnapshot`；摘要卡 SHALL 只读（点高亮+tooltip 无调节，SD23 7.F1）；touch-driven value source SHALL 标 `ui_touch`/mock source；value 调节 SHALL 复用 `ValueRangeMapper` clamp/cycle 逻辑（dial 18-32 / percent 0-100 / stepper 离散档 / toggle on-off / badge 8 色循环），SHALL NOT 在 view 重写 range 逻辑（防与 mapper 漂移）。mock transition SHALL 产生 changing/satisfied 视觉态（值真变化即非 `.normal`，非只 `"on"` 触发）。

#### Scenario: expanded control writes mock store and refreshes snapshot
- **GIVEN** 展开卡 dial/stepper/toggle/badge 被触摸调节
- **WHEN** 控件回调触发
- **THEN** 调 `store.applyMockTransition(DemoMockTransition(key:desiredValue:source:.user))` → snapshot 刷新 → 卡片 + numericText 联动
- **AND** 摘要卡 SHALL 只读（不调 store），SHALL NOT 在 view 硬写 state key/value

#### Scenario: value change produces non-normal visual state
- **GIVEN** 触摸调温度（24→26）/ 百分比 / 档位（desiredValue 非 `"on"`）
- **WHEN** `applyMockTransition` 应用
- **THEN** 该 cell `visualState` SHALL = `.changing`/`.satisfied`（值真变化产生激活态）
- **AND** SHALL NOT 落 `.normal`（否则触控联动视觉假绿，卡片不亮）

### Requirement: demo control panel SHALL force mock context/state for presentation only

演绎控制台（方案经理幕后工具）SHALL force mock context/state：整车（speed/gear）+ 环境（weather/time_period）via bridge **force-context**（AD-RPB-014 context 四维，SHALL NOT 碰 state-cells.yaml 契约）+ NormalRunPreset 常态复位（= DemoReset）+ AllStateSheet（33 base 按 10 族分组）；控制台视觉 SHALL 对齐 10 族卡（iOS26 glass 功能层 + material 模块卡）；SHALL NOT 接真 runtime backend，SHALL NOT customer-facing（`#if DEMO_MODE` 隔离）。

#### Scenario: control panel forces mock context not real backend
- **GIVEN** 演绎控制台 segmented 选「高速/雨天/夜晚」
- **WHEN** force
- **THEN** mutate mock bridge context（vehicle.speed/environment.weather 经 force-context event）驱动 capsule + 安全 guard mock
- **AND** SHALL NOT 写 state-cells.yaml 契约，SHALL NOT 当客户面可达（DEMO_MODE 隔离）

### Requirement: ambient edge burst SHALL be presentation-only and non-blocking

氛围灯边缘爆发 SHALL 纯呈现层（5s burst phaseAnimator → fade out）+ `allowsHitTesting(false)`（不挡 mic/controls/卡片交互）+ 仅 `ambient.color` delta 触发（非 always-on）；SHALL 守 U30（Vortex Canvas 粒子非 layerEffect 折射 shader，不抢 mlx GPU）；SHALL NOT 阻塞主线程/抢 mic 交互。

#### Scenario: burst is non-blocking overlay triggered by ambient color change
- **GIVEN** 氛围灯指令成功（`ambient.color` delta）
- **WHEN** 爆发渲染
- **THEN** 屏幕边缘 5s 闪烁+Canvas 粒子爆发 → fade，`allowsHitTesting(false)` 不挡交互
- **AND** SHALL NOT always-on（仅 color delta 触发），SHALL NOT 用 Inferno layerEffect 折射（守 U30）

### Requirement: visual acceptance SHALL use L0-L3 proof gates and SHALL NOT auto-upgrade simulator proof to V-PASS

8.C2 visual acceptance SHALL remain open until the evidence package contains all four proof layers: L0 runtime-truth capture, L1 sentinel result, L2 readability/regression evidence, and L3 human 5-gate verdict. L0 SHALL record `device`, `launchArg`, `theme`, `ui_tree_evidence`, `screenshot_path`, and `proof_class`; screenshots counting as L0 SHALL be on-screen `simctl io screenshot` captures. Off-screen `ImageRenderer`, SwiftUI preview, static snapshot, or other non-composited render output SHALL NOT count as L0 evidence. Machine/local/mock/simulator proof SHALL NOT be upgraded to `V-PASS`.

#### Scenario: L0 requires on-screen runtime-truth fields
- **GIVEN** a visual-acceptance evidence item
- **WHEN** it is submitted as L0 evidence
- **THEN** it SHALL include `device`, `launchArg`, `theme`, `ui_tree_evidence`, `screenshot_path`, and `proof_class`
- **AND** `screenshot_path` SHALL point to an on-screen `simctl io screenshot` capture
- **AND** off-screen `ImageRenderer`, SwiftUI preview, static snapshot, or non-composited render output SHALL NOT satisfy L0

#### Scenario: L1 sentinel blocks collapse without chasing RMSE
- **GIVEN** zone or anchor comparison runs as L1
- **WHEN** it reports a result
- **THEN** the result SHALL be one of `PASS`, `WARN`, or `FAIL`
- **AND** `FAIL` SHALL block visual acceptance for collapse/regression
- **AND** L1 SHALL NOT chase RMSE score improvements and SHALL NOT sign aesthetic quality

#### Scenario: L2 readability uses OCR and contrast as hard gates, SSIM as evidence
- **GIVEN** L2 machine evidence is produced
- **WHEN** text/readability and visual regression are evaluated
- **THEN** OCR and contrast SHALL be readability hard gates
- **AND** SSIM MAY be recorded as regression evidence
- **AND** LPIPS SHALL NOT be a required or accepted L2 gate for this change
- **AND** L2 passing SHALL NOT substitute for L3 human aesthetic acceptance

#### Scenario: L3 human 5-gate is the only V-PASS authority
- **GIVEN** L0, L1, and L2 evidence exists
- **WHEN** final visual acceptance is decided
- **THEN** L3 SHALL record a human 5-gate verdict enum of `V-PASS`, `V-PASS_WITH_NOTES`, `PARTIAL`, or `FAIL`
- **AND** only 磊哥 MAY sign `V-PASS`
- **AND** automated validators, local proof, mock proof, or simulator proof SHALL NOT mark A-2 complete or claim product `V-PASS`

### Requirement: post-8.C2 interaction integrity SHALL use a scoped proof matrix and SHALL NOT create a third value SSOT

Post-8.C2 Interaction Integrity SHALL be proven with a matrix that distinguishes `family`, `ui_value_type`, `gesture`, `writeback`, `summary_readback`, and `proof_class`. Any `StateCellInteractionPolicy` or equivalent consumer projection SHALL derive value ranges, enum/options, readback, and affordance state from existing contract/mapper sources; it SHALL NOT become a third value/range/enum SSOT in the view layer. A future `verify-uiue-interactions` gate MAY exist only as a UIUE-scoped gate candidate until a separate grill decision promotes it; it SHALL NOT be added directly to global `make verify-all`.

#### Scenario: interaction matrix records gesture, writeback, readback, and proof class
- **GIVEN** an expanded-card control is claimed as interactively covered
- **WHEN** Interaction Integrity evidence is produced
- **THEN** the evidence SHALL identify `family`, `ui_value_type`, `gesture`, `writeback`, `summary_readback`, and `proof_class`
- **AND** a control that lacks real mock writeback or summary readback SHALL NOT be claimed as covered

#### Scenario: consumer projection does not become a third SSOT
- **GIVEN** UIUE needs to decide whether a value is controllable, read-only, ranged, discrete, or option-backed
- **WHEN** that decision is rendered in SwiftUI
- **THEN** the view SHALL consume existing mapper/contract-derived policy
- **AND** SHALL NOT define independent value ranges, enum option lists, or readback formatting in the view layer

#### Scenario: UIUE interaction gate remains scoped until separately decided
- **GIVEN** a `verify-uiue-interactions` or equivalent gate is proposed
- **WHEN** it is added to project automation
- **THEN** it SHALL first be UIUE-scoped and documented with owner, runtime cost, failure ownership, and false-positive handling
- **AND** SHALL NOT be added directly to global `make verify-all` without a separate accepted grill decision

### Requirement: post-8.C2 structural visual gates SHALL stay separate from L3 aesthetic acceptance

Layout Integrity and Visual Spacing gates SHALL evaluate structural defects only: overlap, blank/white-edge leakage, zone budget, safe-area violations, right-side button placement, capsule centering, orb spacing, and mic dock occlusion. These gates SHALL report structural evidence such as PASS/WARN/FAIL, `overlap_pairs`, `min_gaps`, `zone_budget`, and `safe_area_violations`; they SHALL NOT sign aesthetic quality or replace L3 human review. Capsule/VPA evidence SHALL keep context/data proof, layout proof, and diorama aesthetic/L3 proof separate.

#### Scenario: layout and spacing gates block structural defects only
- **GIVEN** the top capsule, VPA/orb, vehicle cards, or mic dock layout changes
- **WHEN** Layout Integrity or Visual Spacing evidence is produced
- **THEN** it SHALL evaluate overlap, blank/white-edge leakage, zone budget, safe-area violations, right-side button placement, capsule centering, orb spacing, and mic dock occlusion
- **AND** it SHALL NOT claim premium aesthetics, animation quality, or L3 acceptance

#### Scenario: capsule and VPA proof is split by concern
- **GIVEN** capsule or VPA/orb evidence is submitted
- **WHEN** the evidence is classified
- **THEN** context/data proof, layout proof, and diorama aesthetic/L3 proof SHALL be recorded separately
- **AND** GPT Image 2 or anchor images SHALL be treated as direction and aesthetic bar, not as implementation structure or final acceptance authority

#### Scenario: structural gates cannot close visual acceptance
- **GIVEN** Layout Integrity and Visual Spacing gates pass
- **WHEN** final 8.C2 visual acceptance is decided
- **THEN** `8.C2` SHALL still require the L0-L3 evidence package and the L3 human 5-gate verdict
- **AND** structural gate success SHALL NOT be upgraded to `V-PASS`, `mobile`, `true_device`, or `A-2 complete`

### Requirement: D17 UIUE consumer authority SHALL consume only main-owned stable payload/config/force-state surfaces

D17 UIUE consumer work SHALL consume only D15 presentation-safe Runtime -> Presentation payload fields and D16 stable main-owned Core config, scene macro, and force-context names. UIUE SHALL NOT invent shared fields, enum values, proof classes, Core config truth, force-state truth, or private adapter payload names. This authority does not implement consumer code by itself.

#### Scenario: D17 consumes D15 payload and D16 stable names only
- **GIVEN** D16 Gate4R has opened `d17_release_gate`
- **WHEN** UIUE defines or implements D17 consumer mapping
- **THEN** it SHALL consume only main-owned D15 payload envelope/content/reconciliation/proof fields and D16 stable config, scene macro, and force-context names
- **AND** it SHALL NOT infer additional shared fields from UIUE docs, receipts, test helpers, private adapter names, raw runtime state, or local mock implementation details

#### Scenario: unknown values fail closed
- **GIVEN** a payload or config input contains an unknown schema, proof class, reconciliation status, mismatch class, config key, scene macro name, force-context dimension, or unexpected presentation field
- **WHEN** UIUE validates that input
- **THEN** the consumer SHALL fail closed
- **AND** it SHALL NOT render the input as a supported successful shared feature

#### Scenario: private runtime and force-state construction surfaces remain forbidden
- **GIVEN** UIUE parses or maps a presentation payload
- **WHEN** it encounters names from `DemoRuntimeAdapter*`, `RuntimeAdapterBox`, `requestFingerprint`, `parentRequestFingerprint`, `failureLedger`, ledger internals, settled parent plan internals, raw runtime store, raw model output, training receipt, adapter-local private names, or `DemoForceStateContext` decode/constructor surfaces
- **THEN** UIUE SHALL reject those names as non-consumer authority
- **AND** it SHALL NOT mirror them into local shared DTOs or UIUE-owned enums

#### Scenario: D17 proof cap is not readiness
- **GIVEN** D17 UIUE consumer authority, local/unit tests, or simulator smoke passes
- **WHEN** status is reported
- **THEN** the proof SHALL remain capped to local/unit/simulator_mock as applicable
- **AND** it SHALL NOT claim UIUE merge, runtime-ready, mobile, true-device, live API, V-PASS, S-PASS, U-PASS, A-2 readiness, voice-ready, model-ready, golden-ready, or endpoint-ready

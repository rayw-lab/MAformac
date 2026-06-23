<!--
DRAFT SKELETON (2026-06-23) — 技术设计/ARCH 决策（=实现侧 design.md，区别于项目根 docs/design/ 视觉 SSOT）。
本档承接 D1-D7 grill 决策晶体 + U1-U31，是 ui-presentation capability 的实现架构锚。
人审定 propose 时按此细化 spec.md Scenario + tasks 逐项。
-->

# ui-presentation 技术设计（Architecture Decisions）

> 范围：UIUE 链路 A 前端「看得见摸得着」层。**消费端态枚举（`DemoVisualState`）+ D-domain surface（A2 已产），不碰模型/LoRA**。
> 一手决策源：`docs/grill-tournament/grill-decisions-master.md §3`（D1-D7 + U1-U31 + 11 复议）。

## AD-1 状态消费：7 态穷尽 switch（D7 头号刀）

**决策**：`ContentView` 用 `@ViewBuilder` 对 `DemoVisualState` 7 态**穷尽 switch**，每态独立渲染分支，**禁** `== .satisfied ? a : b` 二值压缩。

- **7 态**：`normal`（灰蓝静默）/ `satisfied`（青紫辉光呼吸）/ `changing`（cyan 脉冲）/ `blocked_with_alternative`（🟡琥珀 clarify）/ `blocked_hard`（灰锁 unsupported）/ `unsafe`（🔴红描边 safety）/ `unknown`（灰 crash）。
- **🔴 四态分开铁律**（U10）：clarify（琥珀）≠ unsupported（灰）≠ safety（红）≠ crash（灰）；**clarify/unsupported 是 demo 卖点（智能拒识），绝不渲成 unsafe/crash 的红**。色值单源 = `docs/design/tokens.md §2`。
- 消费 trace 字段 `guardReason / readbackResult`（来自 `DemoVehicleStateStore`）。
- **A2 影响**：A2 不碰视觉；本 AD 在 UIUE 链路实装；producer（7 态枚举）A2 之前已存在。

## AD-2 卡片渲染：ui_value_type 消费侧派生 + enum+switch（D3/U26）

**决策**：UI 渲染维度 `ui_value_type` 在**消费侧**派生（spec.md 锁 consumer-side，不写回 producer/contract）；用 `enum + switch(ui_value_type)` 穷尽渲染，**禁 AnyView**。

🔴 **2026-06-24 级联修正（producer→consumer）+ 签名 cite-verify 纠正**：原文「`ui_value_type` 是 `state-cells.yaml` 数据 `type` 的派生字段」=producer 侧，与 spec.md 锁的 consumer 侧矛盾，已改。**且消费侧渲染的 `DemoVehicleStateCell`（`App/ContentView.swift:90` `VehicleStateCard.cell`）无 `type/values/unit` 字段**（仅 key/actualValue(String)/desiredValue/availability/timestamp/source/revision/visualState；`type/values/unit` 是 `contracts/state-cells.yaml` 的 producer 字段）→ 消费侧派生源 = **`cell.key`**（稳定语义键，不读 unit string）。

- **物理化**：`App/Rendering/UIValueTypeMapper.swift`，签名 `func uiValueType(for cell: DemoVehicleStateCell) -> UIValueType`，从 `cell.key` 派生（如 `ac.temp_setpoint`→`.dial` / `ac.power`→`.toggle` / `ac.fan_speed`→`.stepper` / `window.driver`→`.percent` / 多值 enum→`.badge`）；**不写回 `contracts/state-cells.yaml`，不给 `DemoVehicleStateCell`（Core/producer 域）加字段**。
- `enum UIValueType { dial, toggle, stepper, percent, badge }`（消费侧 Swift enum，非模型/非 contract）。
- key→UIValueType 映射表（10 族全集）+ 单测（各族 key × UIValueType 映射断言）填充留 **Phase 4**（rebase main 拿 A2 的 10 族 key 后；本 worktree 现 state-cells.yaml 仅 4 族）。
- **理由**：AnyView 破类型 diff → SwiftUI 渲染慢；enum+switch 保静态类型 + diff 高效（C11 solid / C12 strong 印证）。
- ⚠️ DRY tradeoff：key→type 映射与 yaml 的 `type/unit` 部分重复（yaml 已有 `ac.temp_setpoint` type:int unit:celsius）；demo 轻治理可接受（key 映射比解析 actualValue String 稳健）。若未来 store 构造 cell 时带 dataType（放宽「producer 不新增字段」），可简化——留 Phase 4 spike，不预拍。
- **FamilyCardLayout**：卡片按 10 族 `family_card_id`（U13，非 191 格/非旧 102）；高频排序用 A2 `generated/family-device-allowlist.json` 的 `row_count`（C8 复议#7）。
- ⚠️ 局部中立（盲评 Q3.5#1 事实型）：AnyView vs enum 的性能差需 **spike 实测坐实**（C3 weak），但方向锁 enum+switch。

## AD-3 布局与动效：Grid + matchedGeometry gated（D5）

**决策**：用 `Grid` 固定列（**非 `LazyVGrid(.adaptive)`**）；状态切换动效用 `matchedGeometryEffect`（macOS 可用，**非跨栈 navigationTransition.zoom**，zoom macOS unavailable，WebSearch 坐实）。

- **gated upgrade**（C25）：默认 `opacityScale` 兜底动画，`matchedGeometry` 作 gated upgrade，按 `promotion_criteria` 5 条（D5）才升级；`ripple↔validation_gate` 循环依赖用 ungate 解（D5 Q5.3#1）。
- **SwiftUI API 版本门（demo 锁 iOS26/macOS26，App target deployment；oracle2 Apple 文档坐实，见 docs/research/2026-06-24-ios26-lock-d7-premortem/）**：`matchedGeometryEffect`=iOS14/macOS11 / `Grid`=iOS16/macOS13 / `Gauge.accessoryCircular`=iOS16/macOS13 / `MeshGradient`=iOS18/macOS15 / `.glassEffect()`=**iOS26/macOS26**（🔴 纠正：原误归 iOS18）—— 引入版本均 ≤ deployment 26，故 **SHALL NOT 加 `#available` 版本守卫**；`navigationTransition.zoom`=iOS18/**macOS unavailable** → 用 `#if !os(macOS)` 平台守卫（非版本，磊哥原写 `#if os(macOS)` 方向反，已纠）。Core Package.swift 留 v17/v14 隔离（加强3）。
- **A2 影响**：`ContentView:40` 现仍 `LazyVGrid(.adaptive(minimum:160))`，A2 不碰视觉，本 AD 在 UIUE 改 Grid。

## AD-4 多调用编排与并发上限（D1）

**决策**：boot_phase 7 态 enum 驱动开机序列；`MultiCallSequencer`（stagger_delay_ms=220）串行多意图高亮；`MAX_CONCURRENT_HIGHLIGHTS=1` / `MAX_CONCURRENT_EXPANSIONS=1`（防同时多卡抢视觉）；`FocusController` 单点聚焦。

- 多意图**序列化非并发**（C2 strong），消费源 = A2 `generated/D_domain.tools.*` + `d_domain_ir_map.json`。
- `VisualStateTransport` 抽象状态投递；`validation_gate` 由 D5 gated（ripple ungate 回写）。

## AD-5 双端：两独立纯端侧实例（D4，磊哥纠正推翻镜像）

**决策**：Mac + iPhone = **两独立纯端侧 demo 实例**，iPhone 脱机独立全功能（接语音），**非** Mac 镜像投屏。

- `TransportKind { none, bonjour }`（删 sharedFile 镜像方案，D1.Q1.4 SUPERSEDED-BY D4）；`bonjour` 仅可选联动（C17），两端各自端态自包含（共享 A2 的 D-domain IR + state-cells，无后端）。
- **演示介质灵活**（11 复议#1）：iPhone 真机 或 Mac iOS 模拟器（Retina）都能演，Retina/真机规避 1920×1080 投影 8bit banding；外接投屏才走有线+dither 兜底（非默认门）。

## AD-6 Liquid Glass 用法 + 视觉 token 约束（U2/U7/U11）

**决策**：Liquid Glass **只**功能层 `control_glass`（mic/顶栏）；内容卡用 `content_glow`（自研 cyan/violet box-shadow glow，非 system glass）；禁全局主题开关式 glass（内容层用 glass=整屏糊+HIG 违规）。

> 🔴 **Apple 官方边界 verbatim**（oracle1 curl `materials.json` HTTP200 坐实，**严禁用社区措辞 "exclusively/best reserved for" 冒充 Apple 原话**，见 README §七防呆）：
> - *"Liquid Glass forms a distinct functional layer for controls and navigation elements — like tab bars and sidebars — that floats above the content layer."*
> - *"Don't use Liquid Glass in the content layer... use standard materials for elements in the content layer, such as app backgrounds."*
> - **例外（利好）**：*"...controls in the content layer with a transient interactive element like sliders and toggles... the element takes on a Liquid Glass appearance to emphasize its interactivity when a person activates it."* → 车控温度滑块/风量 toggle 激活态用 glass = Apple 点名正确用法。
> - `.glassEffect()`=iOS26，锁 deployment 26 无需 `#available`（旧机发热坑对锁最新设备 demo 不适用）。

- 视觉值**只从** `docs/design/tokens.md` 取（base **#121212** 软黑，D2#2 复议上抬；辉光雾 `.10-.14` 降一档防 halation），禁手填 hex / 禁 prompt 即兴。
- 保 scheme1 深空辉光**方向** ≠ 保现状代码（U7）：native SwiftUI translation，非 HTML 交付、非重开审美。

## AD-7 双通道降级 + 稳定优先（D6/C30 升横切）

**决策**：关键状态必用「颜色/数值/图标」承载，动画只锦上添花（双通道）；低电量/ReduceMotion 静默禁 `withAnimation`，惊艳归零但态可读。**C30 稳>炸升为整组横切纪律**（撞「不崩」北极星）。

## 不做（demo 轻治理 / DEFERRED 边界）

- ❌ 量产全链路（FC→NLU→DS→DM）/ 真车控 / 跨 session 视觉一致性纪律（demo=同一台 build）。
- ❌ Figma 订阅 / DTCG 工具链（markdown+PNG 视觉 SSOT 功能等价）。
- ⏳ **golden-run 合同回放 + voice ASR/TTS** = `define-demo-golden-run-and-voice` change（**DEFERRED**），不在本 ui-presentation change。
- ⏳ 卡片数据若需 D-domain 工具数精确关联 → 等 A2 archive + UIUE rebase main 拿产物。

## 待 spike 实证（不预拍）

- AnyView vs enum+switch 性能差（AD-2，C3 局部中立）。
- GPU 预算/帧率（C13 GPU~50% = ESTIMATE，Instruments 实测坐实）。
- matchedGeometry 动效在低端机帧率（promotion_criteria 门的实测锚）。

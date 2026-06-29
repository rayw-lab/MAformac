<!--
PROPOSE-ACTIVE (2026-06-24, 磊哥拍 B 严格 OpenSpec) — 技术设计/ARCH 决策（=实现侧 design.md，区别于项目根 docs/design/ 视觉 SSOT）。
承接 D1-D8 grill 决策晶体 + U1-U31 + 用户故事 grill（裂缝④⑤⑥），是 ui-presentation capability 的实现架构锚。
AD-1~AD-8 全拍；Phase 4 契约（AD-8.7 scope 呈现）文档先行，代码 apply 待后端 default_scope。
-->

# ui-presentation 技术设计（Architecture Decisions）

> 范围：UIUE 链路 A 前端「看得见摸得着」层。**消费端态枚举（`DemoVisualState`）+ D-domain surface（A2 已产），不碰模型/LoRA**。
> 一手决策源：`docs/grill-tournament/grill-decisions-master.md §3`（D1-D7 + U1-U31 + 11 复议）。

## AD-1 状态消费：7 态穷尽 switch（D7 头号刀）

**决策**：`ContentView` 对 `DemoVisualState` 7 态**穷尽 switch**，每态独立渲染分支，**禁** `== .satisfied ? a : b` 二值压缩。实现 = `DesignTokens.swift CardAppearance.of()` **值 switch**（`func -> CardAppearance`，无 default 编译器强制穷尽）+ view 消费 appearance（非 @ViewBuilder view-switch，穷尽性等价；spec R1 措辞不锁实现）。

- **7 态**：`normal`（灰蓝静默）/ `satisfied`（青紫辉光呼吸）/ `changing`（cyan 脉冲）/ `blocked_with_alternative`（🟡琥珀 clarify）/ `blocked_hard`（灰锁 unsupported）/ `unsafe`（🔴红描边 safety）/ `unknown`（灰 crash）。
- **🔴 四态分开铁律**（U10）：clarify（琥珀）≠ unsupported（灰）≠ safety（红）≠ crash（灰）；**clarify/unsupported 是 demo 卖点（智能拒识），绝不渲成 unsafe/crash 的红**。色值单源 = `docs/design/tokens.md §2`。
- 消费 trace 字段 `guardReason / readbackResult`（来自 `DemoVehicleStateStore`）。
- **A2 影响**：A2 不碰视觉；本 AD 在 UIUE 链路实装；producer（7 态枚举）A2 之前已存在。

## AD-2 卡片渲染：ui_value_type 消费侧派生 + enum+switch（D3/U26）

**决策**：UI 渲染维度 `ui_value_type` 在**消费侧**派生（spec.md 锁 consumer-side，不写回 producer/contract）；用 `enum + switch(ui_value_type)` 穷尽渲染，**禁 AnyView**。

🔴 **2026-06-24 级联修正（producer→consumer）+ 签名 cite-verify 纠正**：原文「`ui_value_type` 是 `state-cells.yaml` 数据 `type` 的派生字段」=producer 侧，与 spec.md 锁的 consumer 侧矛盾，已改。**且消费侧渲染的 `DemoVehicleStateCell`（`App/ContentView.swift:90` `VehicleStateCard.cell`）无 `type/values/unit` 字段**（仅 key/actualValue(String)/desiredValue/availability/timestamp/source/revision/visualState；`type/values/unit` 是 `contracts/state-cells.yaml` 的 producer 字段）→ 消费侧派生源 = **`cell.key`**（稳定语义键，不读 unit string）。

- **物理化**：`Core/Presentation/UIValueTypeMapper.swift`（🔴 2026-06-25 纠 stale 路径 `App/Rendering/`→实际 `Core/Presentation/`，可单测 MAformacCore；Core/Presentation 与 Core/State 同 module，「禁碰 Core/State」是目录约定非 build 隔离），签名 `func uiValueType(for cell: DemoVehicleStateCell) -> UIValueType`，从 `cell.key` 派生（如 `ac.temp_setpoint`→`.dial` / `ac.power`→`.toggle` / `ac.fan_speed`→`.stepper` / `window.driver`→`.percent` / 多值 enum→`.badge`）；**不写回 `contracts/state-cells.yaml`，不给 `DemoVehicleStateCell`（Core/producer 域）加字段**。
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

## AD-8 默认主驾 + L3+ 思考链路 + 交互边界（D8，2026-06-24 grill 收口）

> 一手 = grill-master §3 D8（磊哥拍 + CC/GLM 辩证演绎 + 核源 cite-verify）。本 AD 是 D8 决策的实现架构。

- **AD-8.1 默认主驾不澄清**（D8.1 + G25）：区域 scope 用户未指定 → 卡片**默认锚定 per-cell `default_scope` 态**（🔴 **G25 SSOT 字段，磊哥 2026-06-24 拍字段名 `default_scope`**；座位→主驾 / 屏类→中控屏 / 前后→前·前排 = 举例**非权威值**，权威读 state-cells `default_scope`，防裂缝④第二份 SSOT），渲染 satisfied/changing，**不渲「请选区域」空态、不弹 clarify 打断**。⚠️ `default_scope` 字段定义 + 填槽逻辑 = 契约/NLU/Core（**非 UIUE**；C3/Compiler/C6/C5 + UIUE 全派生此**单一 SSOT**，消除 codex 后端三处裂缝 + CC 裂缝④）；UIUE **读 `default_scope`** 展示默认态。核源 = `main:contracts/state-cells.yaml`。
- **AD-8.2 clarify(`blocked_with_alternative`) = demo 少用态**（D8.2）：本义 = **某张已确定卡操作 blocked + 替代**（非对话级歧义）。demo「不打断」下能自动替代即 satisfied+提示（不 block）→ 主线几乎不触发。force-state 示例 = `DemoVehicleStateCell(key:"ac.temp_setpoint", actualValue:"已调到18", visualState:.blocked_with_alternative)` + reason「最低18℃」（值超范围+替代，卡片级非区域）。SHALL NOT 用于区域歧义/对话级歧义（「打开」→orb）。
- **AD-8.3 L3+ 思考链路（假 COT）= 对话级 orb `think` 态**（D8.3）：「思考中→调用中→方案」是**对话级 orb 演出（未定卡）= 非卡片态 → DemoVisualState 7 态不动**。归 **Phase 5 orb TimelineView 四态 idle/`think`/speak/listen**（hig-rules:56 已留位）。前端假 COT(~3s) + 场景宏确定性查表[demo,范式§175]/LoRA[后续]。可视化三层路由（L1 秒回不演 / L3+ 演思考）。**不在本 change 实装（Phase 5 后续），本 AD 仅锚定归属防漂移**。
- **AD-8.4 触摸 = 极简查看**（D8.4，✅ P1=B 拍）：卡片**只读状态展示（非手动控制器）**，点卡→高亮+tooltip，无调节逻辑。demo 语音主线，触摸防"死图片"。✅ 磊哥 2026-06-24「可能会戳，不确定」→ B 落实（戳了有反馈保险）。
- **AD-8.5 多卡时序守 D1 级联**（D8.5）：复用 AD-4（stagger 220ms 快速渐次 + MAX_CONCURRENT_HIGHLIGHTS=1 序列化非并发），**不同时炸**（已 grill 拍 C2 strong 22.5）。
- **AD-8.6 UIUE 边界**（D8.6）：UIUE 的活 = ①卡片默认主驾展示 ②思考链路 orb 演出(后续) ③clarify 少用态 ④多轮/读回展示。**边界外(非 UIUE)**：TTS 话术省略=Core readback `{温区}` 模板+voice DEFERRED / scope 填槽=NLU / 继承范围记忆=DialogueState(3轮) / 触摸调节=砍 / L3+ 触发判定=NLU / LoRA 超时兜底=Core（demo 场景宏即时无超时；后续真 LoRA 用 γ 3s 固定+规则兜底）。
- **AD-8.7 scope 呈现 + fan-out + 多轮（用户故事 grill，2026-06-24 全拍；裂缝⑤⑥④）**：用车窗用户故事定卡片/TTS/readback 三处 scope 呈现（Phase 4 卡片实现按此，**依赖后端 `default_scope`/fan-out**）：
  - **裂缝⑤ scope 呈现 = B 淡显**：默认 scope（"打开车窗"→主驾）= 卡片「车窗 100%」+ **淡角标「主驾」**（低对比，客户知范围不打断）；非默认（"打开副驾车窗"）= 卡片/TTS/readback **三处都显式「副驾」**。**单一规则三处同源**（默认淡显 / 非默认显式），后端 readback 策略按此（默认淡显非完全省略——防客户分不清主驾/全车）。
  - **裂缝⑥ 全车 fan-out = c 聚合卡+badge**：显式全车（"打开全车车窗"，后端 fan-out 4 cell）= **1 聚合卡（不分裂 4 张）+「全车」范围 badge**（青标签，范围一眼可见）。聚合 1 卡=单点，**不违反** D8.5 `MAX_CONCURRENT_HIGHLIGHTS=1`。
  - **用户故事④ 多轮叠加 = a 升级聚合**：「打开车窗」(主驾)→「副驾也打开」(G20 显式二轮 passthrough) = 卡片**升级聚合成范围词**「前排车窗 100%」（非主驾/副驾双角标，跟全车聚合同逻辑：多 scope 都聚合成范围词 前排/全车，视觉一致）。
  - 实现锚：UIValueTypeMapper 旁加 scope 呈现派生（读 `default_scope` 判默认/非默认 → 淡角标/显式/聚合 badge）；**Phase 4 卡片 + 后端 readback 策略同源**（裂缝⑤）。

## AD-9 family_card_id 消费侧派生（FamilyCardIDMapper）+ 10 族全景常驻（Phase 4a，2026-06-25）

spec.md:83 / R2 锁「10 族 family_card 全景常驻」，但 producer 0 字段（`contracts/state-cells.yaml` 无 `family_card_id`）→ 消费侧从 `cell.key` 前缀派生（同 `ui_value_type` 派生纪律，不写回 yaml / 不给 Core struct 加字段）。

- `enum FamilyCardID: String, CaseIterable { ac, seat, window, screen, ambient, door, volume, wiper, sunroofShade, fragrance }`（10 控制族）+ `FamilyCardIDMapper.familyCardID(forBase:) -> FamilyCardID?` 穷尽 switch，**optional 返回**（`vehicle.*` 车辆仪表 + 未知 base → `nil`，禁 `default→.ac` 静默错归；P0-1 审计 catch + claim-vs-reality 核 `DemoVehicleStateStore.swift:181` vehicle.speed/gear 在 presentationCells）。
- 🔴 **10 族全景常驻（遍历固定序，非从 cells 反推）**：`familyDisplays` **遍历 `FamilyCardID.displayOrder`（= allCases 10 族全覆盖 + row_count 降序排，codex 跨厂商审 P2 纠：代码用 displayOrder 非 allCases，二者覆盖同 10 族）**，每族查 `presentationCells` 属该族的 cells——有 → 主 cell 摘要态（AD-10）；**无 → `CardAppearance.normal` 占位卡**（族显示名 +「待命」就绪态，体验审计 P0-1 改自「未激活」）。冷启动 10 族骨架常驻（spec「全景常驻」），语音点亮哪族哪族变态。**claim-vs-reality**：A2 `defaultCells()` 现只 5-6 族有 cell（过滤 vehicle 后 5：ac/window/screen/ambient/seat），从 `presentationCells` 反推=空屏不惊艳（lens 已否决纯动态浮现作主形态）→ Presentation 层补全到 spec 要的 10 族（**不碰 Core/State store**，守 A2 边界）。
- **族排序固定**（常驻骨架稳定性，pre-mortem elephant）：按 `generated/family-device-allowlist.json` `row_count` 降序（C8 高频代理）兜底 `FamilyCardID` enum 序，**不按 `revision` 降序**（现有 `displays()` 按 revision 排，常驻骨架沿用=激活族跳位破「常驻」视觉）。

## AD-10 族卡摘要主 cell（FamilyPrimaryCellMapper）+ 族态 occupancy 聚合（Phase 4a）

二级模型摘要层每族显 1 主状态 cell（信息量优先，AD-11）：ac→`temp_setpoint` / seat→`heat_level` / window→`position` / screen→`brightness` / ambient→`color` / volume→`level` / wiper→`power` / door→`central_lock` / sunroofShade→`position` / fragrance→`power`。独立 SSOT（`FamilyPrimaryCellMapper.primaryCellBase(for:)` 穷尽 switch，不复用 readback[0]——ac readback[0]=power 但主 cell=temp_setpoint，顺序不一致）。

- 🔴 **族态 occupancy 聚合**（pre-mortem elephant）：族卡 `title`/`valueText`/`scopeBadge` 取主 cell base 的现有 display（**复用 `individualDisplay`/`aggregateDisplay`:54-129 不重写**，含 scope 角标 dim/emphasized/范围词），但族卡 `visualState` = 族内**所有 cell 的 `dominantVisualState`**——否则「打开空调」动 `ac.power`（satisfied）而主 cell `temp_setpoint`（normal）→ 族卡死寂。**族态看全族（任意 cell 激活族卡亮），value/title 看主 cell**。

## AD-11 二级摘要+展开模型（调研 5 路锁）+ 三屏分层下层（Phase 4a）

4a 摘要层（10 族 family_card 全景常驻 Grid + 每族主 cell at-a-glance + scope 角标 + 7 态 + 占位卡）→ 4b 展开层（触发聚焦 + value.type 异构控件 + 族内 composite）→ 4c 错峰。摘要层不放完整 slider/picker（族卡空间不够，local F10）。

- 🔴 **value.type 在 4a vs 4b 的归属**（Task5 审计 frame-check，防 spec R2 「each ui_value_type has dedicated render branch (dial=环形仪表…)」claim-vs-reality drift）：**4a 摘要卡消费 `ui_value_type` 做【值文本格式化】**（`UIValueTypeMapper.valueText`：dial→`24℃` / percent→`80%` / stepper→`2挡` / toggle→`开/关` / badge→色块 swatch），**at-a-glance 文本形态**；spec R2 Scenario 的【图形控件视觉形态】（dial=Gauge 环形仪表 / toggle=开关图形 / stepper=分段控件）= **4b 展开卡**（AD-11 二级模型，摘要层族卡空间不够）。spec ADDED capability 在 **4c archive 时完整满足**（incremental apply：4a 摘要文本形态 / 4b 异构图形控件 / 4c 错峰）。

- 🔴 **三屏分层归属**（磊哥 2026-06-25「10 族在三层架构下方，思考好布局」）：10 族 family_card Grid = 深空辉光三屏分层的**下方车控层**（语音 orb 顶 / 对话流中 / 车控卡片下，`docs/design/tokens.md`/`INDEX.md` visual-ssot）。4a 卡片层布局须**预留上方**给 Phase 5 orb + 对话流（当前 `commandBar` 临时输入，Phase 5 换 orb+语音）；**不做成顶满屏卡片墙**（防 Phase 5 布局返工）。
- ✅ **竖屏三屏空间分配 = 6-lens ultracode 调研已收口（2026-06-25，承接 D1-D6+8-lens，零推翻 grill）**，方案见 **AD-12**：核心 = 外层固定三 zone（D4 orb120/content440/mic80，Phase 5 落）+ content zone **固定全景 idle（守 spatial memory）+ 活跃族原地放大成 hero 不物理重排 + ScrollViewReader 自动滚激活族入视野**（优于物理置顶零重排破坏）。我之前自拍的「动态分配」被调研修正为「固定全景 + hero 放大」。**4a 车控层（10 族常驻+Grid+scope/态/炸场）经 6 路一致确认与 grill 全对齐（Grid 双端统一非分歧）**；三 zone/活跃置顶/触发聚焦归 Phase 5（4a 不实装 orb）。调研全档 `docs/research/2026-06-25-portrait-interaction/`。

## AD-12 Phase 4 全体竖屏全局 iOS 交互设计（2026-06-25，6-lens ultracode 承接 D1-D6+8-lens，零推翻）

> 承接 D1-D8 + DA0-DA8 + E0-E8 已 grill 框架，6-lens 调研补全局 iOS 交互 + 深化竖屏。全档 `docs/research/2026-06-25-portrait-interaction/`（README 综合官 + lens1-6 一手 + synth-structured.json）。**6 路一致：零推翻已锁决策，新调研全映射到已锁决策的实装细化。**

### 一、骨架不变（已 grill 锁，承接巩固）
全景常驻 10 族 + 触发聚焦（D1）/ 二级下钻（D2）/ value.type 穷尽 switch（D3）/ Mac+iPhone 双独立（D4）/ opacityScale 默认+mge gated（D5）/ wow 4 段（D6）/ scope SSOT + 裂缝④⑤⑥（D8）/ 事件驱动 orb 三屏联动（E0-E8）。

### 二、竖屏布局（深化 D4，Phase 5 落）
- **外层固定三 zone**：orb 120 / content 440 / mic 80，VStack `.frame(height:)` 禁 GeometryReader（D4 锁）；态切套 `geometryGroup()`(iOS17/macOS14) 防子视图抖；mic bar `safeAreaInset(.bottom)` 钉 home indicator 上 + `ignoresSafeArea(.bottom)` 填手势条。
- **content zone 内层 = 固定全景 idle + 活跃族原地放大 hero（bento spatial-weight）**：守 spatial memory（固定 placement 建 mental map），活跃族放大成 hero **不移位**（优于物理置顶，零重排破坏）；竖屏 2 列放不下 10 族常驻 → 配 **ScrollViewReader 自动滚激活族入视野**（`onChange(activeFamily){ withAnimation{ proxy.scrollTo(family.rawValue, anchor:.center) } }`，`DispatchQueue.main.async` 延一帧避同帧 layout jump，卡 id 锚 `family.rawValue` 跨 scope 稳定=滑移非重建）。🔴 **修正我之前自拍的「动态分配」**（被调研改为「固定全景+hero 放大」）。

### 三、全局手势（三层定调，承接 D2 voice 主 tap 辅；HMI 学术共识 gesture 不 scale）
- **tap = 聚焦/激活（主）**：走 `FocusController.toggle(family)` 单入口（4b 实装选 toggle 语义=再点同族收起/点别族切换；codex P2-1 catch 原文 `expand(trigger:.tap)` 与实现不符已纠，typed trigger provenance 留 Phase 5 补）；scroll 内必 `.onTapGesture`（非 simultaneousGesture 干扰滚动）。
- **long-press = 操作员调试快捷（辅，客户不见，maximumDistance 调小防误触）** / **swipe/drag/pinch = 全禁绑值调节**（连续值交语音，触摸无免视觉优势+增疲劳+抢语音控制权）/ 竖滚只用 ScrollView 自带。
- **barge-in（U21）**：新输入调用点直接改 state（不只靠 delegate，didCancel 静默不触发）+ `stopSpeaking(at:.immediate)`。

### 四、微交互编排（端侧独有，单 trigger 同步）
- **单 trigger 同驱三层**：`visualState→satisfied` 一处变更同时触发 `symbolEffect(.bounce)`（态图标 discrete）+ `numericText`（4a 已对）+ `sensoryFeedback(.success/.impact(.soft))`（触感，仅 iPhone 真机；Mac/iPad 静默靠颜色/数值/图标双通道）。
- **symbolEffect 按态**：satisfied→.bounce / changing→.pulse(indefinite) / unsafe→无动效靠红描边 / `.wiggle` 禁常驻；don't-over-animate（每效果答「marks what moment」答不出砍）。
- **多步动效分流**：boot reveal/wow 4 段 = `phaseAnimator(trigger:)`（离散全属性齐动）；orb 四态多维 = `keyframeAnimator`/`TimelineView`（E1 已锁）。sequencer 220ms 单驱动法（单点串行 schedule，ease-out 快起慢收）。

### 五、层级（竖屏聚焦展开，Phase 4b/4c）
- **ZStack overlay + 显式稳定 zIndex（不用 sheet/presentationDetents）**：sheet 系统模态打断对话流 + 盖 orb 三屏（759pt 紧张）；ZStack 原地放大保三屏常驻可见；展开卡 zIndex 显式高于 grid（动态 add/remove SwiftUI 会画错）。
- **单层 ultraThinMaterial dim/blur（禁逐卡 blur）**：blur 矩形插 grid 与聚焦卡之间（中间 zIndex），`blur_radius:12`（D2 锁）+ Reduce Transparency→`solid_overlay:0.65`。
- **mge gated upgrade（D5）**：默认 opacityScale；mge 在 ZStack overlay 两端（isSource 显式 + mge 必在 .frame 之前 + 对称渲染）；🔴 `navigationTransition.zoom` macOS **unavailable（编译错）必 `#if !os(macOS)`**。

### 六、三屏联动（E0-E8 事件驱动官方路径，Phase 5）
`@Observable` 单源 store + `phaseAnimator(trigger:)`/`withAnimation`（事件回调内）：`store.cardsDidStartChanging` 一信号 → orb think→speak + 10 族卡 stagger 高亮并行（非 timer）。orb 四态 ↔ 卡片高亮同步（2026 多模态 VUI 标配，HA Voice Satellite 对标）。think 两语义：analyzing（持续到事件，掩盖后端场景宏）/ 安全拒识（固定 ~1.0s phaseAnimator 单次）。orb 主体自建 MeshGradient（零第三方/零 Metal），思考文字流光 adopt hanlin-ai LoadingGradientText。

### 七、对 Phase 4a 已实装影响（synth task_4a_impact，全自动 CC 自决）
- **全 keep**：FamilyCardIDMapper/FamilyPrimaryCellMapper/familyDisplays/BadgeRenderStyle/occupancy/scope 聚合/Grid 双端统一/numericText/ambient 色块/enforce gate/14 张截图——6 路确认与 grill 全对齐，执行态完成。
- **minor_adjust@4b（非 4a 回炉）**：① breathe `repeatForever`→`TimelineView(.animation(paused:))` sin 驱动 + 生命周期 pause（lens5/8 catch offscreen 不停 + shadow 逐帧贵；4a 已守 glowActive gate 压低风险，故 4b 硬化非回炉，tokens motion.breathe 3.4s 不变只换机制）② scope badge `.caption2` 9pt 投屏可读性进 5-gate 人工 checklist（不进 pre-commit）。
- **defer Phase 5**：深空三屏 VStack（临时占位）→ D4 三 zone（依赖 orb/mic 未实装）/ 活跃置顶 ScrollViewReader（依赖 content zone）/ 触发聚焦展开（4b/4c）。

### 八、cite-verify TODO（主线程亲核，4b/Phase5 实装前核）
- `symbolEffect/breathe repeatForever offscreen 不 pause ~30% CPU`（lens5/8 估值，驱动 breathe→TimelineView，4b 前 Instruments 实测坐实）。
- ✅ `metasidd/Orb 422★ pushedAt 2024-11-11(19月 stale)` + `CherryHQ/hanlin-ai 230★ 2026-05-31 活跃`（2026-06-25 主线程 gh 坐实，synth 421/229 准确未编造）→ orb 自建 MeshGradient 非引第三方 holds，adopt hanlin LoadingGradientText OK。
- `iOS26.1 Menu 进 GlassEffectContainer break morph`（驱动 Phase 5 orb 容器禁嵌，核 26.0 vs 26.1 行为差）。

### 九、用户演绎体验审计收口（subagent CC，2026-06-25，verdict=CONDITIONAL-PASS）
工程层 SOLID（实跑非假绿），呈现语义层 catch「代码/高清图看不出、只客户现场视角才暴露」的真缺口，辩证收：
- ✅ **P0-1 4a 修**：占位卡「未激活」（客户读成 demo 没做完撞惊艳门）→「**待命**」（10 系统就绪态）。`UIValueTypeMapper.placeholderDisplay` + 测试。
- ✅ **P0-2 4a 修**：补真实冷启动截图（`Reports/uiue-phase4a-proof/ios-coldstart-real.png`，无 force-state）——验证真实开场非「满屏灰broken」（待命骨架+值全显），**惊艳开场归 Phase 5 boot reveal**（idle 态「静默≠死灰」由 boot reveal/微辉光承载，本 AD §二 content zone idle）。
- ✅ **P1-2 4a 修**：scope dim 角标 `caption2` 9pt→`caption.semibold`+细边框+提对比（投屏可读，**裂缝⑤「淡」量化 = 淡≠隐形**，弱于 emphasized 但可辨）。
- 🔴 **P1-1 升级 + 4a 台本约定**：竖屏 2 列低排位族（如香氛 row_count32 在第 5 行）激活滚出视野客户跟丢 = **Phase 5 头号 spike**（ScrollViewReader 自动滚 vs 固定全景 spatial memory 在 2 列竖屏张力真实，调研 §二已识别）；🔴 **4a/4b 演示台本先约定「首屏可见族优先演」**（与「现场只说 10 族」轻治理同源，进一步收窄首屏前 6 族），不赌客户跟滚找；Phase 5 spike 定降级保底（激活临时置顶 vs 台本约定）。
- 🔒 **P1-3 steelman 不自改，上抛磊哥/AD-1 review**：blocked_hard 灰锁🔒 客户易误读「坏了/锁死」非「智能拒识」——但**撞 D7 FROZEN 色映射**（tokens §2 磊哥审签 灰=unsupported，改琥珀撞 clarify）→ 色不自改；icon（🔒→ℹ️？）/reason 文案（更助手感）可议，待磊哥拍。
- ⏳ **P1-4/P2-2 defer 4b**：changing 视觉强度（一闪而过客户跟不上执行）/ ambient 红色块增强（偏小偏淡）。
- 📝 **P2-1/P2-3/P2-4 记录**：force-state 脚手架 normal/satisfied 大图坍缩（README 措辞已修）/ readback 占上方 Phase 5 三 zone 解 / 默认淡角标 vs 非默认 title scope 呈现不一致（grill 裂缝⑤已锁）。
- **方法论**：force-state 14 张是「满屏丰富视觉」5-gate 脚手架，**不代表真实台本时刻**（真实冷启动/单族激活/低排位滚动从未被 force-state 截图验证）→ 补 cold-start 真实截图（claim-vs-reality 第10变体：脚手架图≠用户真实看到）。

### 十、codex 跨厂商终审收口（OpenAI vs Anthropic，2026-06-25，verdict=V-CONDITIONAL）
gptpro 异源审屏幕锁屏卡死 + hermes-xhigh 端点挂/hermes-doubao async 不可取 → codex(OpenAI CLI 不依赖屏幕) 兜底真 cross-vendor。**无 P0**；claim-vs-reality a/b/c/d 全成立（codex python 实算 displayOrder=row_count 降序 sum=2159 / 复用 displays():230 不重写 / vehicle→nil / 10族主cell）。
- ✅ **P2 已修**：design.md 说遍历 allCases 实际 displayOrder（已纠 AD-9，二者覆盖同 10 族非功能 bug）。
- 🔴 **P1（跨厂商独抓 Claude 同家族盲点，真 finding 亲核坐实）= state-cells.yaml 未 bundle 化**：`StateCellPresentationCatalog.loadStateCellsYAML()`（`UIValueTypeMapper.swift:395`）bundle 查不到（**打包 .app Resources phase 空 `files=()`（pbxproj:158）+ SPM exclude contracts（Package.swift:21）→ 真无 yaml**）→ 退 `#filePath`(`:404`) host 源路径。**Mac/模拟器（demo 主路径，lens1 ⭐Mac主设备）工作**（#filePath 在 host 解析）；**真 iPhone standalone（D4 加分）该路径不存在 → catalog 空 → `defaultScope=nil` → 裂缝⑤淡显退化成全 scope 进 title + `aggregateScopeLabel=nil` 无全车/前排聚合**。Claude 3 轮聚焦 Presentation 逻辑 + 跑 swift test(用 #filePath dev 态)，**隐式认为 dev/模拟器=真机发布态**，codex 从 Package.swift+pbxproj 两线交叉坐实真 P1。
  - **辩证收（steelman defer）**：① **pre-existing**（前任孤立模块 loadStateCellsYAML，非本次 4a 回归）② **demo 主路径 Mac/模拟器工作**（CLAUDE §4 Mac主/iPhone加分 + lens1 ⭐Mac主设备）③ **修需碰共享 Xcode infra（pbxproj bundling）或 codegen typed catalog 管线**，全自动磊哥睡时不擅动 ④ **属打包/部署关注**（Phase 6 现场 SOP / shipping，iPhone standalone target）。
  - **fix path（待磊哥/打包阶段，修后升 V-PASS）**：① app target Resources phase 加 `contracts/state-cells.yaml`（bundle 化）**或** ② codegen typed Swift catalog（编译进 Core/Presentation，零运行时文件依赖，最 robust，对齐 SSOT codegen 纪律）③ 加 bundle 存在性测试/pre-commit grep pbxproj 防回归。**真机 demo 前必修**（否则 iPhone 脱机 scope 呈现退化）。

## AD-13 UIUE = Presentation Contract 三层（gptpro 产品架构意见吸收，2026-06-25，磊哥定）

> 一手 = gptpro 对 PR #6（Phase 4a）的产品架构意见（`/Users/wanglei/Downloads/gptpro意见.md`，8 点）。磊哥拍：能沉淀的沉淀（元认知 rule + 本 AD），第 5 点不采纳。元认知 rule = `~/.claude/rules/derivation-layer-discipline.md`（派生层/语义呈现层纪律）。

### 一、核心论点：UIUE 是「语义呈现层」非「UI 改版」
Phase 4a 起，UIUE 把 **C2 端态协议 + scope 语义 + 族级信息架构 + 演示叙事 + 视觉状态机** 压缩成秒懂界面——**这层错的不是 UI，是系统语义**。优先级 = **语义安全带（聚合 resolver / 穷尽 enforce / 契约闭合测试 / 数字单源）> 视觉动画 / 表现打磨**。心智从「画卡片」切到「固化一层 Derivation Contract」。

### 二、三层 contract（正确抽象不是 View）
```
C2 DemoVehicleStateCell → Presentation Derivation → FamilyCardDisplay Model → SwiftUI Rendering
  Derivation 层（消费侧派生器，本 AD 锚）：
    B1 FamilyCardIDMapper        （device base → 10 族；vehicle.*→nil）   ✅ AD-9
    B2 FamilyPrimaryCellMapper   （族 → 主 cell；第二份 SSOT）            ✅ AD-10 + 契约存在性测试
    B3 UIValueTypeMapper         （base → 控件类型；mapping 字典闭合）     ✅ 闭合 hardening
    B4 ScopeAggregationResolver  （base-aware scope 聚合）               ✅ 本次提取（gptpro 第8点）
    B5 dominantVisualState       （族态 occupancy 聚合）                ✅ AD-10
```

### 三、gptpro 8 点吸收落地（逐点 + 状态，2026-06-25 收口）
| # | gptpro 点 | 处置 | 落点 |
|---|---|---|---|
| 1 | scope 聚合 domain-aware（非硬编码全车） | ✅ 已修(数据驱动)+补 ambient/sunroof 测试 | `ScopeAggregationResolverTests`(11) + `FamilyDisplaysTests`(wiper/screen P0) |
| 2 | `default:.badge` 吞错（4b Gauge 追查灾难） | ✅ mapping 字典 SSOT + `assertionFailure` + contract 闭合测试；🔴 **修出真 bug：`window.lock` 被 default 吞成 badge，实为 toggle** | `UIValueTypeMapper.mapping`(33 base) + `UIValueTypeMappingTests`(4) |
| 3 | wiring gate 进 CI + 强 grep | ✅ 已进 CI(`verify-contentview-wiring`)+升级 grep `displays:familyDisplays` | `Makefile` + `check-contentview-uses-display-catalog.sh` |
| 4 | claim 数字手写打架 | ✅ 收口统一 PR body/docs/handoff 从实跑核 | 收口 receipt |
| 5 | 第三方 skills/vendor 拆 PR | 🔴 **不采纳（磊哥拍）**：仓 private(`rayw-lab/MAformac`+内网)，非外部供应链；solo demo 轻治理下拆 PR 增协调成本无收益 | — |
| 6 | FamilyPrimaryCellMapper 第二 SSOT 静默漂移 | ✅ 契约存在性强测试（primary base ∈ yaml + isMapped + family 一致） | `FamilyPrimaryCellMapperTests`(+2) |
| 7 | deferred 注释散落难追踪 | ✅ 建 phase matrix（下方四） | 本 AD §四 |
| 8 | 下一刀补 ScopeAggregationResolver 非动画 | ✅ 已提取 base-aware resolver | `Core/Presentation/ScopeAggregationResolver.swift` |

### 四、phase matrix（gptpro 第7点；deferred 单一处可查，防 reviewer 误判 deferred=缺失）
| Capability | 4a | 4b | 4c | Phase5 |
|---|---|---|---|---|
| 10 族常驻 Grid | ✅ | harden | harden | harden |
| value.type **文本格式化** | ✅ | — | — | — |
| value.type **图形控件**（Gauge/toggle/stepper） | deferred | ✅ | harden | harden |
| 座椅 composite（5 cell 行分 3 类） | deferred | ✅ | harden | harden |
| 触发聚焦展开（ZStack overlay+opacityScale/mge） | deferred | ✅ | harden | harden |
| scope 聚合（ScopeAggregationResolver） | ✅ | harden | harden | harden |
| UIValueType 契约闭合 | ✅ | harden | — | — |
| multi-intent stagger（220ms/MAX=1） | deferred | deferred | ✅ | event-driven |
| orb 四态（idle/think/speak/listen） | deferred | deferred | deferred | ✅ |
| 三 zone / 活跃置顶 ScrollViewReader | deferred | deferred | deferred | ✅ |
| state-cells **bundle 化（真机 standalone）** | deferred（Mac/模拟器 #filePath OK） | — | — | 打包阶段 |
| value.type 控件（ValueControlView 5 类 Gauge/分段/toggle/badge） | deferred | ✅ spike 验 | harden | harden |
| ValueRangeMapper（execution_range 委托 A2 lookup） | — | ✅ | harden | — |
| catalog → A2 `StateCellContractLookup` 委托（消 title/scope/defaultScope 重复解析 SSOT） | execution_range 已委托 | harden（上抛磊哥重构范围） | — | — |

### 五、元洞察（工程分水岭）
继续按「UI 改版」做派生层 → 越做越玄学（聚合靠全局 if、控件靠 default 吞、deferred 靠记忆）；按「语义呈现层」做 → 撑得住 4b/4c/Phase5。**下一刀优先补派生器语义正确性，不是表现层动画**——本次 4a 收口正是先 hardening B3/B4 语义层（闭合+resolver）再进 4b 控件。

## AD-14 — 完整产品形态：连续舞台 + context capsule diorama + 三屏交互（SD18-25 consolidated，2026-06-25）

> 承接 grill SSOT `docs/uiue-storyboard-grill-decisions.md` **SD18-25**（视觉块 V1-V12 / corner case CC / 制冷热 SD20 / 层级滚动 SD22 / 边界态 SD23 / context capsule diorama SD24-25）+ `docs/grill-checklist/uiue-grill-定档-2026-06-25.md`（作废清单 S1-S10）。**消费 A-1 `define-runtime-presentation-bridge` 契约（磊哥 2026-06-25 accepted，mock snapshot 即可不依赖 mainline runtime）**。本 AD = 这些决策落 ui-presentation 的架构锚点；细节在 SD/grill SSOT，不在此重复。

### 一、连续舞台（无 divider，信息架构非三块边框，SD18 V7 硬约束）
三屏分层靠留白+material+卡片群自然成块，**禁 divider 黑线**。顶部 context band（context capsule + 设置/刷新右上 standalone，**品牌去掉**）/ orb / 对话流 / 车控 / mic dock floating。视觉 tokens 落 `tokens.md §3.1/§6/§7/§8`（8pt 间距 / 5 级 type scale / 22 圆角 0.5pt hairline 无黑框 / theme 强制色 ivory 默认不跟随系统 V6）。

### 二、顶部 context capsule = 「活体迷你窗」diorama（SD24/25）
会动的分层迷你世界（天空/车/路/天气/玻璃折射），表达 **context 四维**（消费 bridge `context{vehicle:{speed,gear}, environment:{weather,time_period}}`，AD-RPB-014）。route 留 **A-2 spike**（A 视频 loop vs C-lite；🔴 项目 U30「layerEffect 与 mlx 抢 GPU -50%」→ 砍重折射 shader；U31 spike 不预拍）。adopt Vortex（粒子 尾气/雨/雪/星）+ native `.glassEffect`（壳）。图标在 capsule 外（守 SD24，gpt 图非权威仅视觉灵感）。

### 三、7 态 + 制冷热 + corner case（消费 bridge）
7 态色 D7（已 apply commit 6a3e3f9）+ **制冷热 sibling**（SD20，消费 bridge `sibling_cells`，`ac.mode` 驱动蓝/红 + range bar + mode 图标）。CC1 **activeCell**（非 normal 态主值切本次变化 cell，消费 bridge `active_cell`）+ partial-deny（消费 `per_action_results`）+ already_state（satisfied+ack 视觉，不塌 unsupported/safety）。

### 四、层级 + 滚动（SD22）
z-order：氛围 overlay（`allowsHitTesting(false)`）> mic dock > orb > 聚焦 dim > 滚动内容；mic dock 始终居前 + 车控 scroll 底 `contentInset`。滚动：orb/mic 钉，对话/车控内部滚；**手动滚暂停自动 scrollTo**；**fade 按 active 非屏幕位置**（防滚动闪烁）。

### 五、边界态（SD23）
**纯语音 push-to-talk（移除 ContentView TextField）** / iPhone 锁竖屏 / 文案 max ~30 字 `.truncationMode(.tail)` / ASR 二分（empty 静默回 idle / no-match → unsupported）/ 族外 blocked_hard 兜底。

### 六、消费 bridge（A-1 accepted）边界
UIUE 消费 `PresentationSnapshot`（**mock snapshot 即可，不依赖 mainline runtime**）：cards{visual_state/scope_origin/sibling_cells/active_cell}/ context 四维 / orb_state / dialog。**UIUE visual_only，bridge 契约定数据 shape，runtime 实现 DEFERRED**。

### 实装 order（A-2 内部，文档先行；🔴 范围扩到完整 demo 交互，全 mock 前台，磊哥 2026-06-25 SD7 amendment）
1. **连续舞台核心**（不卡 capsule）：ContentView 四 zone 重构 + mic dock + 对话流 + tokens hex 定稿 + 7态/制冷热 sibling + 层级滚动 + 边界态 + 氛围灯卡片渐变 + 设置/刷新。
2. **触控 + state 联动 + 语音推理（全 mock，SD6/SD7）**：展开卡数值控件→mock store 写→卡片联动 + `applyMockTransition` visualState 修复（值变化→changing 非只 "on"）+ mock 预设语音推理。
3. **演绎控制台（全 mock force，SD13-15/SD8）**：DemoControlPanel 三大块 + AllStateSheet 33base + force mock context（AD-RPB-014 四维）+ 设置主题切/场景宏 force。
4. **氛围灯炸场（SD4）**：AmbientEdgeBurst 边缘 5s 爆发（Vortex Canvas 守 U30）。
5. **context capsule**（spike-gated）：route spike → 资产 → ContextCapsule view。
6. 验收：swift test + xcodebuild 两端 + simctl + **visual-acceptance（L0-L3，手持环境；投屏 DELETE C0）+ anchor 像素对比 + 每 Phase codex 审计**。

🔴 **全 mock 边界**（落 spec 4 个 mock-frontstage Requirement）：触控/语音推理/控制台 force 全 mock（mock store/mock snapshot/mock 预设响应），不接真 NLU/ASR/TTS/LoRA/runtime backend（后续接线 DEFERRED），不改 state-cells.yaml 契约语义。完整实施计划 = `docs/superpowers/plans/2026-06-25-a2-step2-uipresentation.md` v3；adopt 巨人肩膀（DSWaveformImage/exyte-Chat/axiom/Vortex/Inferno/IceCubesApp/Orb）。

## 不做（demo 轻治理 / DEFERRED 边界）

- ❌ 量产全链路（FC→NLU→DS→DM）/ 真车控 / 跨 session 视觉一致性纪律（demo=同一台 build）。
- ❌ Figma 订阅 / DTCG 工具链（markdown+PNG 视觉 SSOT 功能等价）。
- ⏳ **golden-run 合同回放 + voice ASR/TTS** = `define-demo-golden-run-and-voice` change（**DEFERRED**），不在本 ui-presentation change。
- ⏳ 卡片数据若需 D-domain 工具数精确关联 → 等 A2 archive + UIUE rebase main 拿产物。

## AD-15 — 视觉验收门 hardening + 长跑流程机制（U32-U37，2026-06-26，codex ~15h 长跑复盘）

> 决策 SSOT = `docs/grill-tournament/uiue-visual-gate-harden-grill-decisions.md`（U32-U37）+ `grill-decisions-master.md` §3。背景：codex A-2 长跑 Phase 2 像素 RMSE 截图 v1→v72 死循环不收敛（磊哥叫停）。设备：仿真 iPhone 17 Pro/Pro Max（主验收），真机 iPhone 15 Pro Max（延后不急）。范围 = ABC 揉进本 change（A 契约 + B 流程 + C 代码，磊哥 2026-06-26）。

**视觉验收门四层（U32，门 vs 证据；核心 frame = L0/L3 真门 / L1/L2 哨兵证据，禁 L2 绿当 L3 pass）**：
- **L0 runtime-truth = 🚪真门**：截图绑 device/launchArg/theme/UItree/proof_class，**必 on-screen `simctl io screenshot`，禁 off-screen `ImageRenderer`**（防 glass/material 失真，oracle 坐实 swift-snapshot-testing #242/#612）。缺 L0 不进评分。
- **L1 sentinel（U33）= 🚪有限机械门（只挡塌陷）**：`Tools/checks/phase2_zone_compare.py` 输出 RMSE → **PASS/WARN/FAIL**（非逼近分）+ **long-run stop-rule**（2 轮无新 proof-class 收口）。
- **L2（U34）= OCR+contrast 🚪可读性硬门 + SSIM 📋退化证据**（LPIPS 不上：PyTorch 依赖 + 对 UI 小元素不准）。
- **L3 人工 5-gate = 🚪唯一审美终裁**：aesthetic-first 5-gate + verdict enum（V-PASS/V-PASS_WITH_NOTES/PARTIAL/FAIL），只能磊哥给。

**一进两出 contract（U37，防 fake-green）**：`PresentationSnapshot`（`Core/Presentation/PresentationSnapshot.swift:59`）唯一一进容器，**不新建 Visual/Verbal Model**；**presentation derivation 只读 snapshot**（非「ContentView 全程只读」——mutation 层 `App/ContentView.swift:271-283` 可写 store 但必回灌下一帧 snapshot）；`DemoRuntimeResultKind` 8 态 VUI 矩阵穷尽测试无 default（复用 `FamilyDisplaysTests` 闭合模式）。

**取证策略（U36，按控件动作分非按族）**：`tap_step/toggle/badge_cycle` 自动化 tap 取证（state 写入+snapshot 回灌+视觉刷新）；`continuous_drag`（仅 AC hero `ThermalRangeBar`，`App/ContentView.swift:2105`）过程证 operator-pass/真机（idb touch-move iOS26 破）；`force_state = terminal_visual_only` 禁当过程 proof；**代表族矩阵防单样本外推**（风量/座椅/车窗/灯光各 1 条自动化样本）。

**negative-space（U35）**：进门只加 **Reduce Motion**（粒子/氛围灯/orb 降级 + 禁动效态跑 5gate + 静态思考反馈）；**投屏 DELETE**（C0，supersede V10/U23/U24）；Contrast→L2 / 字体→L3 覆盖；Dynamic Type/中文截断/多语言/RTL/晕动 DEFERRED（demo 固定设备 + 控话术）。

## 待 spike 实证（不预拍）

- AnyView vs enum+switch 性能差（AD-2，C3 局部中立）。
- GPU 预算/帧率（C13 GPU~50% = ESTIMATE，Instruments 实测坐实）。
- matchedGeometry 动效在低端机帧率（promotion_criteria 门的实测锚）。

## AD-16 — D17 main-owned payload/config/force-state consumer boundary（2026-06-29）

> Authority chain: main D15 `define-runtime-presentation-bridge` payload contract, main D16 `define-core-config-force-state-authority`, Gate4R release receipt `d17_release_gate: open`, and this UIUE Gate5 authority. This AD authorizes UIUE consumer authority only; implementation and fail-closed tests belong to Gate6.

### 一、UIUE 可消费的 main-owned stable surface

UIUE MAY consume only the following main-owned stable surfaces:

- D15 payload envelope fields: `schemaVersion`, `traceID`, `turnID`, `eventID`, `isTerminal`.
- D15 payload content fields: `outcome`, `proofClass`, `cards`, `cardSemantics`, `readbacks`, `reconciliation`, `traceEnvelope`, only as presentation-safe values.
- D15 reconciliation surface: `PresentationReconciliation.status`, `readbackKey`, `mismatchClass`, and `safeReason`.
- D15 finite proof classes as labels for proof cap only, not readiness promotion.
- D16 Core config names: `scene_macro_registry.version`, `scene_macro_registry.stable_names`, `d17.consumer_authority`.
- D16 scene macro names: `scene1.human_language_comfort`, `scene2.multi_intent_comfort`, `scene3.followup_window_memory`, `scene4.driver_window_generalization`, `scene5.driving_safety_refusal`.
- D16 force-context dimensions as names only when carried by main-owned presentation payload/context authority: `vehicle.speed`, `vehicle.gear`, `environment.weather`, `environment.time_period`.

### 二、UIUE 不拥有的 surface

UIUE SHALL NOT consume, map, serialize, or infer shared fields from `DemoRuntimeAdapter*`, `RuntimeAdapterBox`, `requestFingerprint`, `parentRequestFingerprint`, `failureLedger`, success/failure ledger internals, settled parent plan internals, raw runtime store, raw model output, training receipt, adapter-local private names, or any `DemoForceStateContext` decode/constructor surface. Gate4R closed the `DemoForceStateContext` external `Decodable` construction bypass; UIUE must treat that type as non-consumer authority and must not re-open it through local DTO mirroring.

### 三、fail-closed and proof cap

Unknown schema, proof class, reconciliation status, mismatch class, config key, scene macro name, force-context dimension, or unexpected presentation field SHALL fail closed in UIUE consumer mapping. Gate6 implementation must prove this with local/unit tests before any consumer code is called complete.

The proof ceiling for D17 UIUE remains `local`, `unit`, and optional `simulator_mock`. D17 SHALL NOT claim UIUE merge, runtime-ready, mobile, true-device, live API, V-PASS, S-PASS, U-PASS, A-2 readiness, voice-ready, model-ready, golden-ready, or endpoint-ready.

### 四、claim-vs-proof correction

D15 created main payload authority but did not implement UIUE consumption. D16 Gate4R opened the D17 release gate after repairing the force-state construction bypass, but it did not provide runtime/mobile/live proof. Therefore Gate5 is authority only: it defines the consumer boundary and forbids UIUE invented shared fields before Gate6 code/tests.

## AD-17 — D19 durability guard authority（2026-06-29）

> Authority chain: main D18 Gates 1-4 local durable adapter/C3 authority, Gate4 private payload boundary verifier commit `b6a793755cfb7438c0f3e5edecb6cd32d5524336`, D17 UIUE consumer deny-list, and this UIUE Gate5 authority. D19 consumes D18 only as proof-governance and deny-list guardrails; it does not consume durable runtime rows as presentation data.

### 一、UIUE may consume only guardrail semantics

UIUE MAY treat D18 as authority for these guardrail facts only:

- local durability proof is capped to `local`, `unit`, `integration`, `static`, `OpenSpec`, or `GitNexus` evidence as applicable;
- durable runtime internals are main-owned implementation details, not UIUE shared fields;
- presentation payloads must remain D15/D17 stable surfaces and must reject private durability names;
- unknown durability/proof/readiness names fail closed rather than becoming UIUE display labels.

### 二、D18 durability names remain forbidden

UIUE SHALL NOT consume, map, serialize, display, or infer shared fields from durable ledger, persistent ledger, adapter ledger, `local_durable_adapter_ledger`, `requestFingerprint`, `parentRequestFingerprint`, success ledger, failure ledger, `settledParentPlan`, settled parent plan internals, raw runtime store markers including `rawRuntimeStore`, raw model output, training receipt, adapter-local private names, or D18 storage path/schema internals.

### 三、proof cap and merge boundary

D19 UIUE durability guard work is consumer-boundary and governance work only. It SHALL NOT claim UIUE merge, runtime-ready, production durable runtime, mobile, true-device, live API, V-PASS, S-PASS, U-PASS, A-2 readiness, voice-ready, model-ready, golden-ready, endpoint-ready, or R5 completion.

Gate6 implementation may add local/unit fail-closed tests for the deny-list and proof-cap semantics, but those tests still do not prove runtime/mobile/live readiness.

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
- 🔴 **10 族全景常驻（遍历 allCases，非从 cells 反推）**：`familyDisplays` **遍历 `FamilyCardID.allCases`(10)**，每族查 `presentationCells` 属该族的 cells——有 → 主 cell 摘要态（AD-10）；**无 → `CardAppearance.normal` 占位卡**（族显示名 + 未激活灰态）。冷启动 10 族骨架常驻（spec「全景常驻」），语音点亮哪族哪族变态。**claim-vs-reality**：A2 `defaultCells()` 现只 5-6 族有 cell（过滤 vehicle 后 5：ac/window/screen/ambient/seat），从 `presentationCells` 反推=空屏不惊艳（lens 已否决纯动态浮现作主形态）→ Presentation 层补全到 spec 要的 10 族（**不碰 Core/State store**，守 A2 边界）。
- **族排序固定**（常驻骨架稳定性，pre-mortem elephant）：按 `generated/family-device-allowlist.json` `row_count` 降序（C8 高频代理）兜底 `FamilyCardID` enum 序，**不按 `revision` 降序**（现有 `displays()` 按 revision 排，常驻骨架沿用=激活族跳位破「常驻」视觉）。

## AD-10 族卡摘要主 cell（FamilyPrimaryCellMapper）+ 族态 occupancy 聚合（Phase 4a）

二级模型摘要层每族显 1 主状态 cell（信息量优先，AD-11）：ac→`temp_setpoint` / seat→`heat_level` / window→`position` / screen→`brightness` / ambient→`color` / volume→`level` / wiper→`power` / door→`central_lock` / sunroofShade→`position` / fragrance→`power`。独立 SSOT（`FamilyPrimaryCellMapper.primaryCellBase(for:)` 穷尽 switch，不复用 readback[0]——ac readback[0]=power 但主 cell=temp_setpoint，顺序不一致）。

- 🔴 **族态 occupancy 聚合**（pre-mortem elephant）：族卡 `title`/`valueText`/`scopeBadge` 取主 cell base 的现有 display（**复用 `individualDisplay`/`aggregateDisplay`:54-129 不重写**，含 scope 角标 dim/emphasized/范围词），但族卡 `visualState` = 族内**所有 cell 的 `dominantVisualState`**——否则「打开空调」动 `ac.power`（satisfied）而主 cell `temp_setpoint`（normal）→ 族卡死寂。**族态看全族（任意 cell 激活族卡亮），value/title 看主 cell**。

## AD-11 二级摘要+展开模型（调研 5 路锁）+ 三屏分层下层（Phase 4a）

4a 摘要层（10 族 family_card 全景常驻 Grid + 每族主 cell at-a-glance + scope 角标 + 7 态 + 占位卡）→ 4b 展开层（触发聚焦 + value.type 异构控件 + 族内 composite）→ 4c 错峰。摘要层不放完整 slider/picker（族卡空间不够，local F10）。

- 🔴 **value.type 在 4a vs 4b 的归属**（Task5 审计 frame-check，防 spec R2 「each ui_value_type has dedicated render branch (dial=环形仪表…)」claim-vs-reality drift）：**4a 摘要卡消费 `ui_value_type` 做【值文本格式化】**（`UIValueTypeMapper.valueText`：dial→`24℃` / percent→`80%` / stepper→`2挡` / toggle→`开/关` / badge→色块 swatch），**at-a-glance 文本形态**；spec R2 Scenario 的【图形控件视觉形态】（dial=Gauge 环形仪表 / toggle=开关图形 / stepper=分段控件）= **4b 展开卡**（AD-11 二级模型，摘要层族卡空间不够）。spec ADDED capability 在 **4c archive 时完整满足**（incremental apply：4a 摘要文本形态 / 4b 异构图形控件 / 4c 错峰）。

- 🔴 **三屏分层归属**（磊哥 2026-06-25「10 族在三层架构下方，思考好布局」）：10 族 family_card Grid = 深空辉光三屏分层的**下方车控层**（语音 orb 顶 / 对话流中 / 车控卡片下，`docs/design/tokens.md`/`INDEX.md` visual-ssot）。4a 卡片层布局须**预留上方**给 Phase 5 orb + 对话流（当前 `commandBar` 临时输入，Phase 5 换 orb+语音）；**不做成顶满屏卡片墙**（防 Phase 5 布局返工）。
- 🔴 **竖屏三屏空间分配「动态非固定三等分」**（磊哥 2026-06-25 pre-mortem：iPhone 竖屏 ~874pt，10 族 2 列×5 行 ~390pt，叠 orb~220+对话流~240=850pt 顶满挤压）→ Phase 5 实装按 **orb 四态弹性伸缩**（与 Phase 5 orb idle/think/speak/listen 语义对齐）：
  - **idle 待命**：orb 收为顶部小球/底部 mic（~80pt），车控层主体 ~70%，10 族全景常驻一眼看全（保 spec「全景常驻不空屏」）。
  - **语音交互（think/speak）**：orb 放大顶 ~220pt + 对话流浮现中 ~200pt + 车控层下沉底部 ~45%（ScrollView 内滚 + **激活族自动滚入视野+高亮**=「语音点亮哪族哪族变」延伸）。
  - 横屏（macOS 5 列/iPad 4 列）宽屏无挤压，三屏可分区。**4a 不实装 orb**（agree-before-build，Phase 5 grill 细化收缩/下沉比例）；4a 车控层本身（10 族常驻+Grid+scope/态/炸场）已验证正确。

## 不做（demo 轻治理 / DEFERRED 边界）

- ❌ 量产全链路（FC→NLU→DS→DM）/ 真车控 / 跨 session 视觉一致性纪律（demo=同一台 build）。
- ❌ Figma 订阅 / DTCG 工具链（markdown+PNG 视觉 SSOT 功能等价）。
- ⏳ **golden-run 合同回放 + voice ASR/TTS** = `define-demo-golden-run-and-voice` change（**DEFERRED**），不在本 ui-presentation change。
- ⏳ 卡片数据若需 D-domain 工具数精确关联 → 等 A2 archive + UIUE rebase main 拿产物。

## 待 spike 实证（不预拍）

- AnyView vs enum+switch 性能差（AD-2，C3 局部中立）。
- GPU 预算/帧率（C13 GPU~50% = ESTIMATE，Instruments 实测坐实）。
- matchedGeometry 动效在低端机帧率（promotion_criteria 门的实测锚）。

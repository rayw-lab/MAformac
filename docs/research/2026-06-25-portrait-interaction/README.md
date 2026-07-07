# UIUE 竖屏全局 iOS 交互综合设计报告（综合官，2026-06-25）

> 6 路 finder（lens1 grill 承接 + 竖屏布局横扫 + lens3 全局交互 + lens5 ref-repos 代码范式 + lens7 三屏联动 + lens8 坑点 oracle）收敛。承接 D1-D6/D8/E0-E8 已 grill 锁框架，融合新调研补全局 iOS 交互 + 竖屏深化，**零推翻**。

## 0. 关键事实纠正（驱动全报告）

🔴 **Phase 4a 已执行态完成（非计划态）**：起手以为「4a 缺 enforce gate / 14 张待跑」，本机核码推翻——Tasks 1-6 全 done：
- `Core/Presentation/{FamilyCardIDMapper,FamilyPrimaryCellMapper,UIValueTypeMapper}.swift` 独立文件齐（commit `aaa1288/73104ac/f177727`）
- `Tests/MAformacCoreTests/VehicleCardDisplayTests.swift` 87 行 TDD
- `Tools/checks/check-contentview-uses-display-catalog.sh` enforce gate（三场景自验，commit `1dbd70d`）
- `Reports/uiue-phase4a-proof/` force-state 14 张（iOS 7 态 + Mac 7 态 + README，5-gate 全过，commit `6c1cefb`）
- 撞车已解：current branch `ef2ccc3` = rebased main `6f03b62` scoped-state，ContentView 已走 `store.presentationCells`

→ task_4a_impact 从「评估要不要补」翻转为「4a 收口，下一步 push+审 + 4b/5 前向」。

## 1. 承接框架（已 grill 锁，巩固非推翻）

| 决策 | 内容 | 4a 对齐 |
|---|---|---|
| D1 | 全景常驻 + 触发聚焦 + boot reveal + MultiCallSequencer(220ms,MAX=1) | 摘要骨架✅；reveal/sequencer→Phase5 |
| D2 | 族内二级下钻 + voice主tap辅 ExpandIntent单入口 + blur分级 | scope角标✅；触发聚焦→4c |
| D3 | UIValueType 5类穷尽switch + GPUBudgetCoordinator | enum✅；异构控件→4b |
| D4 | Mac+iPhone双独立实例 + 竖屏三zone(orb120/content440/mic80) | Grid双端统一✅；三zone→Phase5 |
| D5 | opacityScale默认 + mge gated(macOS passed) + Grid非LazyVGrid | Grid✅；mge升级→4c spike |
| D6 | wow 4段 + 双通道降级 | numericText/breathe基础✅；wow→Phase5 |
| D8 | default_scope SSOT + 裂缝④⑤⑥ + touch read-only | dim badge✅（main已落default_scope） |
| E0-E8 | 事件驱动orb三屏联动 + think两语义 + 场景宏 | 契约ready；实装→Phase5 |

**Grid 双端统一非分歧**（6 路一致）：D5/C22 锁定，早期 Mac-Grid+iPhone-LazyVGrid 分离已 SUPERSEDED。

## 2. 竖屏布局形态深化

- **外层固定三 zone**（D4）：tokens 钉死 orb120/content440/mic80，禁 GeometryReader，态切套 geometryGroup() 防抖，mic bar safeAreaInset(.bottom)。
- **content zone 内层 = 固定全景 idle + 活跃族 bento spatial-weight 原地放大**（守 spatial memory）+ ScrollViewReader 活跃置顶（`sorted{revision>}` 已实装 + withAnimation 滑移 + family.rawValue 锚 id + scrollTo anchor:.center DispatchQueue 延帧）。
- 🔴 张力（Phase5 spike）：原地放大 vs 物理置顶 vs spatial memory 三者竖屏共存需专门验（放大撑卡触发 Grid 重排）。

## 3. 全局手势体系（三层，承接 D2）

tap=聚焦/激活(主,走 FocusController 单入口,scroll 内用 onTapGesture) / long-press=操作员调试(辅,客户不见) / swipe/drag/pinch=禁绑值调节(交语音) / barge-in=调用点直改 state。

⚠️ frame 注记：lens3 用车控 HMI 学术（gesture 不 scale/增疲劳/touch 失免视觉）论证禁手势，但那是【量产驾驶安全】frame，本 demo 是【现场看屏销售】非真驾驶，真理由是「语音炸场 + tap 够用 + 不增实装风险」非驾驶安全。

## 4. 微交互编排（端侧独有，单 trigger 同步）

`visualState→satisfied` 单 trigger 同驱 symbolEffect(.bounce) + numericText(已对) + sensoryFeedback(仅 iPhone)。symbolEffect 按态精准（satisfied→.bounce/changing→.pulse/unsafe→红描边/.wiggle 禁）。boot/wow→phaseAnimator(离散全属性) / orb→keyframeAnimator/TimelineView(独立轨道)。sequencer 220ms 单驱动 ease-out 曲线。iOS26 .glassEffect.interactive() 仅 transient 控件激活态(Apple 点名,不撞 U2)。

🔴 catch：4a breathe `repeatForever` offscreen 不停 + shadow:213-214 逐帧贵 → 4b 换 TimelineView(.animation(paused:)) sin + 三层 pause（已守 glowActive gate 压低风险，非回炉）。

## 5. 层级管理（竖屏聚焦）

ZStack overlay + 显式稳定 zIndex（不用 sheet/presentationDetents，模态打断对话流+盖 orb）+ 单层 ultraThinMaterial dim（禁逐卡 blur）+ mge gated（isSource 显式/mge 在 .frame 前/对称渲染，macOS zoom unavailable 必 #if !os(macOS)）。

## 6. 三屏联动（E0-E8 官方实装路径）

@Observable 单源 store + phaseAnimator(trigger:)（事件回调内）：cardsDidStartChanging 一信号 → orb think→speak + 卡片 stagger 并行（非 timer）。orb 四态↔卡片高亮=2026 多模态 VUI 标配（HA Voice Satellite 对标）。orb 自建 MeshGradient（零第三方/零 Metal），文字流光 adopt hanlin-ai LoadingGradientText。

## 7. CC 决策与 4a 影响

详见 cc_recommendation + task_4a_impact：4a 8 项 7 keep + 1 minor_adjust(@4b breathe/badge字号) + 三屏布局 defer_to_4b/5。**Grid 双端统一 keep（非分歧）/ 活跃置顶/三zone/触发聚焦 Phase5 补（4a 边界外，非现在补）。**

## 8. 前向计划

- **4b**（独立小 PR）：value.type 异构控件（spike rgb/seat）+ breathe TimelineView 硬化 + 触发聚焦 spike（竖屏 mge）。
- **Phase5**（大 PR）：orb 实体（E1 MeshGradient）+ 三屏联动事件驱动 + 三 zone 全量重构 ContentView + wow 4 段。
- 各 Phase 小 PR 并 main（避大爆炸 + 两线频繁同步）。

## 9. 上抛磊哥（仅 1 条，合并粒度偏好）

4a 是否现在 push 小 PR 并 main（⭐A，已执行态完成）vs 攒到 4b/Phase5 大 PR。其余大体思路 OK CC 自决（Grid 统一/三zone defer/原生不引库/breathe@4b/badge字号进checklist）。

## 10. 待 cite-verify（主线程亲核）

mge macOS11+/zoom macOS unavailable/geometryGroup iOS17+/glassEffect Menu 26.1 break/repeatForever 30%CPU/hanlin-ai 229★活跃/Orb 421★stale——见 external_claims_to_verify。
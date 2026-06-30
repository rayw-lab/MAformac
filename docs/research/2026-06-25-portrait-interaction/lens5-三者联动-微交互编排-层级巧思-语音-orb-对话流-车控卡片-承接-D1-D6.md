# 三者联动 + 微交互编排 + 层级巧思（语音 orb ↔ 对话流 ↔ 车控卡片，承接 D1/D6 wow + Phase5 E0-E8 事件驱动）

> 一手 finder full_markdown（ultracode 三层一手性）

# UIUE Phase4/5 竖屏交互调研 · lens=三者联动+微交互编排+层级巧思

> 承接 D1/D6 wow + Phase5 E0-E8 事件驱动；**不推翻已 grill 决策**，本档=承接巩固 + 物化补全 + catch 4a 两处真分歧。≥8 联网搜证 + 本机 grill/ref-repos 承接。核 2026-06-25。

## Summary（核心结论）
三者联动的契约骨架已在 **Phase5 E0-E8 grill 深锁**（事件驱动非计时：orb think analyzing 掩盖后端→`cardsDidStartChanging` 事件=handoff→orb speak readback 与卡片 stagger 级联并行）。我的调研**承接 + 物化 + catch 4a 实装质量**：
1. **联动** = `@Observable` 单源 + `phaseAnimator(trigger:)`/`withAnimation` 事件驱动（WWDC23），一个 store 信号点亮 N 视图 = E8 官方实装路径。
2. **微交互编排** = 单 trigger state 同时驱动 `symbolEffect(.bounce)`+`sensoryFeedback(.impact)`+`withAnimation` 弹簧（iOS17 canonical，三层从同一 state 变更=完美同步），承接 D6 wow 4 段。
3. **层级** = 显式 `zIndex`（动画必显式值否则画错）+ 单层 `ultraThinMaterial` dim（禁逐卡 blur）+ `matchedGeometryEffect` 配 `isSource`+ZStack3层+placeholder（4c，但 D5 已锁 opacity 默认，mge 是 spike 升级项）。

🔴 **catch 4a 两处真分歧**（非推翻 grill，是实装质量）：
- **(A) 性能**：4a breathe 用 `repeatForever` + 逐帧 `.shadow` = offscreen 卡仍烧 CPU（无原生 pause）+ shadow 逐帧最贵 → 应改 `TimelineView(.animation(paused:))` sin 驱动 + 三层 pause。
- **(B) 编排**：`displays().sorted{revision>}` 已做活跃置顶（D1），但 ContentView 用 Grid 未包 `withAnimation` → 重排跳变，需 withAnimation + 稳定 Identifiable id。

🟡 竖屏三zone（orb120/content440/mic80 固定 `.frame` 非 GeometryReader）D1 已锁但 4a 未实装（deferred Phase5）。

## Findings（每条带 source）

### F1【联动·承接E8/E2】@Observable 单源 + phaseAnimator(trigger:) = 事件驱动跨视图协调官方路径
Apple WWDC23『Wind your way through advanced animations』定调：把『事件』当 @Observable 属性变更，用 `phaseAnimator(trigger:)`/`keyframeAnimator(trigger:)` 在事件发生时触发，彻底解耦 timer。共享一个 @Observable store（@Environment 注入），一属性变更传播到所有观察视图。→ 正是 E2/E8 实装骨干：store 发 `cardsDidStartChanging`/`triggered_macro_id` 信号，orb 切 think→speak + 10 族卡片同 transaction stagger 高亮。E8『think 两语义』映射 = analyzing 持续到事件到达（掩盖）vs 安全拒识固定 phaseAnimator 单次。
- source: WebSearch『Observable state-driven coordinated animation event driven not timer 2025』→ developer.apple.com/videos/play/wwdc2023/10157 + elamir.medium.com（@Animatable macro 2025）

### F2【微交互编排·承接D6】单 trigger state 同驱 symbolEffect.bounce + sensoryFeedback + withAnimation = iOS17 canonical 配方
HWS/Sarunw/AppCoda 一致：`.symbolEffect(.bounce)` discrete 一次性（不改 layout 不打架），`.sensoryFeedback(.impact)` 同 trigger-driven，二者+`withAnimation(.spring)` 全部从同一 @State 变更触发=完美同步。canonical：`isActivated.toggle()` 一处同时点燃 bounce + .replace 图标 morph + impact 触感。→ 喂 D6 wow『点亮 bounce+breathe+numericText 滚动+scope 角标淡显+ambient 色块+ripple』：每族卡 visualState→satisfied 事件=单 trigger 同驱多层，+`sensoryFeedback` 一行补触觉（端侧加分）。⚠️ bounce/haptic 仅真机响，模拟器/force-state 截图验不到。
- source: WebSearch『symbolEffect bounce sensoryFeedback haptic iOS 17 2025』→ hackingwithswift.com/quick-start/swiftui/how-to-animate-sf-symbols + sarunw.com + useyourloaf.com/blog/swiftui-sensory-feedback

### F3🔴【4a 真分歧 A·性能】repeatForever + 逐帧 shadow → 改 TimelineView(paused:) sin 驱动
4a `ContentView.swift:213-214 .shadow(radius: breathe?18:9)` + `:264 repeatForever(autoreverses:true)`。Apple 文档：repeatForever『for the lifespan of the view』绑生命周期非可见性，滚出视口不自动暂停；多卡 offscreen pass 持续烧 CPU（单个 ~30% 实测），且 shadow/blur 逐帧最贵。正解：`TimelineView(.animation(minimumInterval:1/60, paused: !isVisible || !isActive))` + sin 驱动，自带 paused + onAppear/onDisappear/scenePhase 三层 gate 真停。或退一步动 opacity/scaleEffect 不动 shadow。承接 D1『仅激活态』（4a 已守 glowActive gate ✅）+ tokens motion.breathe 3.4s 不变只换驱动。
- source: WebSearch『repeatForever breathing performance offscreen CPU 2025』+『TimelineView paused vs repeatForever』→ developer.apple.com/documentation/swiftui/animation/repeatforever + sarunw.com + developer.apple.com/documentation/swiftui/timelineschedule/animation(minimuminterval:paused:)；本机 App/ContentView.swift:213-214,264

### F4🔴【4a 真分歧 B·编排】sorted{revision>} 活跃置顶未包 withAnimation → 跳变
`UIValueTypeMapper.swift:58-60 .sorted{ lhs.revision > rhs.revision }` = D1 活跃置顶已实装于 model 层。但 4a VehicleCardsGrid 喂 Grid 无 `withAnimation` 包数据变更 + display 数组变更位置突变。铁律：SwiftUI 默认不动画 reorder，重排必 `withAnimation` + 稳定 Identifiable（聚合卡 id=`aggregate|key|key` 拼接，scope 变=被当新卡 insert/remove 非 move）。修法：familyDisplays 变更包 withAnimation(.snappy) + 同族卡 id 锚 family.rawValue 跨 scope 稳定（否则置顶=闪建非滑移）。
- source: WebSearch『ScrollView reorder animate move to top reflow jarring 2025』→ 21zerixpm.medium.com + developer.apple.com/forums/thread/731271；本机 UIValueTypeMapper.swift:58-60,132

### F5【层级·4c锚点】显式 zIndex + 单层 ultraThinMaterial dim + mge 配 isSource/ZStack3层/placeholder
fatbobman/HWS：动态 add/remove 视图不显式设 zIndex 会画错（聚焦卡升 z 必显式）。focus『全景 blur+dim 退后』正解=单层 Color.black.opacity()/ultraThinMaterial 插 grid 与聚焦卡之间（中间 zIndex），禁逐卡 blur（内存贵旧机掉帧）。mge 在 Grid 冲突解（SwiftUI Lab 3层 ZStack）：聚焦卡 isSource + grid 项换 placeholder + 顶层 ZStack mge 联动。→ 喂 4c。⚠️ D5 已锁 ExpansionAnimation 默认 opacityScale + mge gated upgrade（macOS zoom unavailable 事实坑），4c 走 opacity 默认是已决策、mge 是 spike 升级项，本调研承接不翻。
- source: WebSearch『zIndex blur focus card dim 2025』+『matchedGeometryEffect Grid conflict 2026』→ fatbobman.com/en/posts/zindex + swiftui-lab.com/matchedgeometryeffect-part1；本机 uiue-d1-d6-grill.md:167（D5 锁 opacity）

### F6【三者联动·业界基准】voice orb 四态 ↔ 卡片高亮同步=2026 多模态共识默认
2026 VUI：纯语音罕见，语音+配对视觉=多模态默认。HA Voice Satellite 最贴 demo：orb live state sync（idle/listening/processing/responding）+ mini card 文字显示 + 9 皮肤 + activity bar 音频电平。ElevenLabs/assistant-ui orb=thinking/listening/talking，color：idle 灰/connecting 琥珀脉冲/listening+speaking 绿/muted 红 300ms。VUI 铁律『silence is the enemy』=说话必立即视觉确认（E3-D orb listen 100ms 微亮已守）。错误恢复『失败两次第三步屏幕兜底』映射 clarify/unsupported 态。承接 E0-E8 orb 四态契约不推翻。
- source: WebSearch『voice orb listening thinking speaking card highlight sync automotive 2025』→ fuselabcreative.com/voice-user-interface-design-guide-2026 + github.com/jxlarrea/voice-satellite-card-integration + ui.elevenlabs.io/docs/components/orb

### F7【编排·节奏】sequencer 220ms 错峰 = staggered 单驱动法（承接 D1/D8.5 MAX=1）
objc.io/SwiftUISnippets：staggered 两法——逐项 `.animation(.delay)` 易搭难控时序 vs 单驱动 timeline 全控。delay 曲线：linear/ease-out `pow(idx/max,2)*0.5`（快起慢收）/bounce。→ D1 MultiCallSequencer + D8.5 MAX_CONCURRENT_HIGHLIGHTS=1 = 单驱动法（单点入口串行），合『单驱动 timeline 精控』，逐项 delay 无法保证 MAX=1。承接 D1/D8.5；炸场『唰唰唰』建议 ease-out 曲线比 linear 高级。
- source: WebSearch『staggered animation choreography 2025 2026』→ talk.objc.io/episodes/S01E330-staggered-animations + swiftuisnippets.wordpress.com/2026/05/20

### F8【层级·竖屏三zone】759pt 三zone 固定 .frame（D1 锁）+ mic bar safeAreaInset 避手势条
D1 锁：tokens iphone 759pt（orb120/content440/mic80/gap119），IPhoneLayout VStack `.frame(height:tokens)`，禁 GeometryReader，pre-commit `check:iphone-zone-height-from-tokens`。业界补：mic bar 用 `safeAreaInset(edge:.bottom)` 钉 home indicator 上（控件守安全区），仅背景 `ignoresSafeArea(.bottom)` 填手势条无缝隙，底边手势 `defersSystemGestures(on:.vertical)`。🔴 4a 未实装三zone（双端统一 Grid 2/4/5 列，无 orb zone/mic bar）= deferred Phase5。承接 D1 标 4a-vs-D1 范围 gap（非分歧）。
- source: WebSearch『iPhone portrait fixed zone safe area mic bar 2025』→ swiftuifieldguide.com/layout/safe-area + alejandromp.com/blog/swiftui-footers-ctas-and-safe-areas；本机 uiue-d1-d6-grill.md:132,144,156

### F9【联动·ref-repos 现成料】本机三件可抄
本机 ref-repos（只读，adopt>build）：(1) ShipSwift/SWThinkingIndicator.swift:54 `TimelineView(.periodic(by:0.3))` 三点错峰 bounce『零生命周期』=orb think typing dots + 印证 TimelineView 自管（呼应 F3）。(2) open-swiftui-animations/Thinking.swift `phaseAnimator([false,true]){ .symbolEffect(.breathe.byLayer) }` + 文字 hueRotation 流光=orb think 慢漂参考。(3) Orb/RotatingGlowView/WavyBlobView=E1 自建 MeshGradient orb 分层结构参考。(4) hanlin-ai LoadingGradientText:24-67（E1 引）。承接 lens5 adopt + E1/E2。
- source: 本机 Bash find + Read ShipSwift SWThinkingIndicator.swift:54 + open-swiftui-animations Thinking.swift；ref-repos 在 ~/workspace/raw/05-Projects/MAformac/ref-repos/

### F10【编排纪律】ReduceMotion 双通道铁律（4a 已守 ✅）
tokens motion §4：低电量/ReduceMotion 禁 withAnimation→惊艳归零，关键态必颜色/数值/图标承载。标准 symbolEffect 自动 respect ReduceMotion；自定义需 `@Environment(\\.accessibilityReduceMotion)` gate。4a 已守（updateBreathe() guard !reduceMotion ✅ + a11yState 七态文案 ✅）。磊哥已定『低电量不考虑』（DA2 砍），只守 ReduceMotion 一条。编排 checklist：每加微交互问『ReduceMotion 退化成什么静态』。
- source: 本机 tokens.md motion §4 + lens8.md pre-mortem + grill-master DA2；App/ContentView.swift:261

## Candidates（竖屏交互编排候选）

### ⭐方案1（推荐）：事件驱动单源联动 + 单trigger微交互 + 显式z层级
- **pros**：100% 承接 E8/D6/D1（@Observable store 单信号点亮全屏 / 单 trigger 同驱 bounce+numericText+haptic 完美同步 / sequencer 单驱动法精控 MAX=1）；修 4a 两分歧不动契约（TimelineView paused + withAnimation 置顶滑移）；4c 走 D5 opacity 默认 + 显式 zIndex + 单层 dim；全守 ReduceMotion。
- **cons**：TimelineView 改造多 ~1 视图重构（ShipSwift 有现成范式，成本低）；置顶滑移需聚合卡 id 跨 scope 稳定（小改 id 锚）；haptic/bounce 真机才响需彩排。
- **竖屏适配 9/10**：三屏联动是『语音点亮哪族哪族变』灵魂，事件驱动最稳（无 timer 竞态、无固定时长撞快慢后端）；扣 1 分=竖屏三zone+orb 实物 4a 未覆盖待 Phase5。

### 方案2：保 4a repeatForever + 逐项 delay + opacity（最小改动）
- pros：零重构；逐项 delay 易搭；opacity 坑最低。
- cons🔴：repeatForever offscreen 烧 CPU + shadow 逐帧最贵（10 卡叠加掉帧/发热，lens8 tiger）；逐项 delay 无法保证 D8.5 MAX=1（撞 D1 sequencer）；置顶不包 withAnimation=跳变；违 claim-vs-reality（把 repeatForever 当 0 风险）。
- **竖屏适配 4/10**：能跑但性能+时序竞态风险，撞已锁 D1/D8.5。不推荐作最终。

### 方案3：激进全 Metal/Canvas 自绘联动（追极致炫）
- pros：统一 shader 做 orb→卡片能量流动；TimelineView+Canvas 性能可控；how-did-they-do-that 级。
- cons🔴：撞 U30 铁律（Metal shader 仅氛围层，与 mlx 抢 GPU 掉 50%）；工作量爆炸违轻治理；真机依赖验收难；过度工程化冲动。
- **竖屏适配 3/10**：炫度天花板高但撞 U30 GPU 红线（反应慢违『反应快』）+ 风险失衡。不推荐。

## Gaps vs grill/4a
- 🔴 **4a 分歧 A**：breathe repeatForever+逐帧 shadow → TimelineView(paused:) sin 驱动 + 三层 pause（ShipSwift 范式可抄）。
- 🔴 **4a 分歧 B**：sorted{revision>}（D1 活跃置顶）未包 withAnimation → 跳变；需 withAnimation + 同族卡 id 锚 family.rawValue 稳定。
- 🟡 **4a-vs-D1 范围 gap**：竖屏三zone（759pt 固定 .frame）+ orb zone + mic bar safeAreaInset，4a 未实装（deferred Phase5，非推翻）。
- 🟢 **承接确认**：E0-E8 三屏联动契约 + D6 wow + sequencer 220ms + 聚焦 opacity（D5）+ ReduceMotion 双通道全部承接，@Observable+phaseAnimator 是 E8 官方实装骨干。
- 🟢 **MEMORY 警示已守**：无新增 4-enum adapter；方案3（Metal 全自绘）已自我否决（撞 U30 + 过度工程化），承接 demo 轻治理。

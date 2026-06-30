# 全局 iOS 交互（手势体系 + 微交互 + 层级管理）

> 一手 finder full_markdown（ultracode 三层一手性）

# UIUE Phase 4 全局 iOS 交互 lens 一手调研（手势体系 + 微交互 + 层级管理）

> lens = 全局 iOS 交互（不局限已 grill）。承接 D2(tap affordance/blur)/D5(mge gated)/D6(symbolEffect/shaders)/E1(orb)。10 次联网搜证 + 本机 grill 承接 + 4a cite-verify。日期 2026-06-25。

## Summary（核心结论）

竖屏 5min 语音演示 demo 的全局 iOS 交互三支柱：

1. **手势体系** —— 承接 D2「voice 主 tap 辅」，全局补三层定调：**tap=展开/激活(主)、long-press=操作员调试快捷(辅,客户不见)、swipe/drag/pinch 禁用于值调节**。最强发现 = **车控 HMI 学术共识直接支持此取舍**（gesture 不 scale + 增疲劳延迟、touch 失免视觉优势、voice 适深菜单），且 tap 与 voice 走同一 ExpandIntent(D2 已锁单入口)天然无冲突。

2. **微交互**（全端侧独有,web 无）—— `symbolEffect`(.bounce 值触发/.pulse changing/禁 .wiggle 常驻)、`sensoryFeedback`(.success/.impact/.selection,iPad/Mac 无触感需降级)、`contentTransition(.numericText)`(必 withAnimation,4a 已对)、`phaseAnimator`(离散多步:boot/wow) vs `keyframeAnimator`(独立轨道:orb)。发现 iOS26 `.glassEffect(.regular.interactive())` 给激活态 transient 控件 shimmer 是 Apple 点名正确用法（不撞 U2 仅功能层）。

3. **层级** —— 竖屏触发聚焦用 **ZStack overlay + 显式稳定 zIndex**（不用 sheet/presentationDetents,因系统模态打断对话流+盖 orb 三屏分层）；承接 D5「opacityScale 默认 + mge gated upgrade」，坐实 `navigationTransition.zoom` macOS unavailable = D5 选 mge 不选 zoom 是对的；Grid(非 LazyVGrid,C22)天然规避 mge laziness 冲突。

关键 gap：4a 当前**零手势 handler、无三-zone 竖屏、force-state 走 launch argument**，全是承接 grill 已规划但 4a 未实装项（4a 边界=接线+scope角标+低风险炸场），**非分歧**。

---

## Findings（带 source，每条标承接/补充/分歧）

### F1 [最强] 车控 HMI 学术共识强支持「语音为主 / tap 只聚焦激活 / 手势绝不做连续值调节」
驾驶舱多模态研究三结论直接落地：①gesture 不 scale（eyes-free gesture 随功能增多迅速复杂难记；touch 相关显示内容则失去免视觉优势）；②gesture 增疲劳/延迟/安全权衡；③voice 适深菜单（VUI 帮用户绕 feature overload）。映射：10 族×191 device 深层意图正是 feature overload → 语音为主是学术正解；tap 只做聚焦/激活(relates to displayed content 可接受)，绝不做 swipe 调温/drag 调风量。市场侧 multimodal 2024 USD2.8B→CAGR21%，核心设计挑战=输入优先级与冲突解决，本 demo 已被 D2 ExpandIntent 单入口解决。
- source: Pfleging 2012 (LMU) / arXiv 2210.12493 / gminsights multimodal market (2026-06-25)

### F2 手势三层定调：tap(主) / long-press(操作员调试) / swipe·drag·pinch 禁绑值调节
SwiftUI：.onTapGesture 主力最简；.onLongPressGesture(minimumDuration/maximumDistance/onPressingChanged 按压中反馈)适操作员长按进 debug；Button 叠手势用 .simultaneousGesture。落点：tap→D2 FocusController.expand(trigger:.tap,单入口不漂移)；long-press→操作员/调试(maximumDistance 小防滚动误触)；swipe/drag/pinch 不绑(值调节交语音)，竖滚用 ScrollView 自带。tap affordance D2 已锁(alpha 0.18 + accessibilityHint)。
- source: hackingwithswift gestures + 本机 uiue-d1-d6-grill.md:54-55 (2026-06-25)

### F3 symbolEffect 按态精准用（端侧独有）
iOS18/SF6 三新效果 Wiggle/Rotate/Breathe；三触发(值/isActive/transition)；三行为类(discrete/indefinite/transition)；iOS26 仅细化。don't over-animate,每效果标记一个具体时刻。映射 7 态图标：satisfied→.bounce(值触发一次)/changing→.pulse(indefinite)/unsafe→无动效靠红描边(双通道)/wiggle 禁用(编辑态语义);态图标切换走 .contentTransition(.symbolEffect(.replace))。
- source: createwithswift symbol-effect + blakecrosley vocabulary + donnywals (2026-06-25)

### F4 sensoryFeedback 触感(iOS17+)——iPad/Mac 无触感需双通道
.sensoryFeedback(_:trigger:) 触发式;预定义 success/selection/impact 等;.impact 可选 weight/flexibility+intensity;condition 闭包细控。caveat:iPad 不支持触感 + Mac 无硬件 → 只 iPhone 真震,态靠颜色/数值/图标(双通道)。落点:iPhone .selection(聚焦)/.success(满足)/.impact(.soft)(点亮)。
- source: hackingwithswift sensory-feedback + useyourloaf (2026-06-25)

### F5 [4a 已对齐] numericText 必 withAnimation 包裹
iOS17 数字滚动三步;铁律 content transition 只在 Animation transaction 内生效,不包则退化 fade。4a ContentView.swift:193-194 已正确实装=对齐 grill D6/tokens.md:98/F-LB2。变体 .numericText(value:/countsDown:)。
- source: createwithswift numeric-text + Apple docs + 本机 ContentView.swift:193-194 (2026-06-25)

### F6 phaseAnimator vs keyframeAnimator
phaseAnimator:离散状态序列全属性齐动→boot reveal(D1.Q1.1)/wow 4 段(D6);keyframeAnimator:独立 per-property 轨道→orb 多维(E1 已锁 TimelineView 替代)。纪律:简单态切换别上 keyframe(过度)。
- source: hackingwithswift phase-animators + WWDC23 #10157 + appcoda keyframeanimator (2026-06-25)

### F7 [补充] iOS26 .glassEffect(.regular.interactive()) = Apple 点名激活态正确用法
.interactive() 给 glass tap 时 shimmer+scale+bounce;GlassEffectContainer+glassEffectID+@Namespace 三件套 morph;.glassEffectTransition(.materialize)。守 U2:内容卡片仍 content_glow(SHALL NOT system glass);mic/顶栏 + 激活态 transient 控件(4b 温度滑块)可用 glass。坑:iOS26.1 Menu 破 morph;形状偶回 Capsule(用 .buttonStyle(.glass))。
- source: Apple glassEffect docs + donnywals + conorluddy/LiquidGlassReference + 本机 hig-rules:30,39 (2026-06-25)

### F8 层级:竖屏聚焦用 ZStack overlay + 显式稳定 zIndex,不用 sheet
presentationDetents(iOS16)+iOS18 presentationSizing 是系统 sheet 范式,但本 demo 不适用(sheet 模态打断+盖 orb 三屏分层+给不了 hero morph+遮挡对话流)。ZStack overlay+条件视图+显式稳定 zIndex(坑:不显式设则加/删视图 zIndex 变,转场错乱)。承接 D2 blur 分级 token。
- source: createwithswift bottom-sheets + fatbobman zindex + balzsorbn zstack-transition + 本机 uiue-d1-d6-grill.md:58,65-67 (2026-06-25)

### F9 mge grid 展开两大坑——D5「Grid 非 LazyVGrid」正好规避
①frame 顺序陷阱(mge 必在 .frame 前,加 flexible base,=D5.Q5.2 lens6 Tiger2);②laziness 冲突(LazyVGrid 只渲可见 cell,源滚出屏=snap)→ZStack overlay 两端共存。D5 已锁 Grid(C22)规避坑②+ZStack overlay 双保险。只插值 size/position;id 用 model id 非 index。D5 promotion:mge macOS26 passed,剩 ReduceMotion+snapshot focus_expand_10 验。
- source: chris.eidhof mge + Apple forums 669115 + bhumibhuva masterclass + 本机 uiue-d1-d6-grill.md:59,167 (2026-06-25)

### F10 navigationTransition.zoom macOS unavailable 坐实——印证 D5 选 mge 对
iOS18 zoom 比 mge 简单+跨 sheet/push,但 ZoomNavigationTransition macOS 当前 SDK unavailable(协议在/子类型不可用)→必 #if os(iOS) 守卫+macOS plain push 回退。映射 D4 双独立端侧:zoom 在 Mac 没退路;mge macOS26 可用+不依赖导航栈→D5 选 mge(opacityScale 默认+mge gated)对。本 demo 单屏 ZStack overlay 不用 NavigationStack→zoom 本不适用。
- source: Apple ZoomNavigationTransition docs + theswift.dev + douglashill + 本机 uiue-d1-d6-grill.md:59 (2026-06-25)

### F11 Mac 端 onHover/hoverEffect 补 tap affordance(指针特有)
macOS/iPad(接指针)onHover(布尔自定义)+hoverEffect(.automatic/.highlight/.lift)+onContinuousHover(坐标跟随)。Mac 投影演示触控板可补 hoverEffect(.highlight)/onHover scale 1.02。边界:iPhone 触屏无 hover(双端分化同源 FocusController);macOS onHover clear-background bug→卡片 content_glow 背景非 clear 天然规避。轻治理:Mac hover 加分非必须。
- source: hackingwithswift onhover + Apple hovereffect docs + 本机 uiue-d1-d6-grill.md:55 (2026-06-25)

---

## Candidates（4 候选 + ⭐推荐 + 竖屏适配评分）

### ⭐C1 手势体系（fit 9/10）
tap=聚焦/激活(主,D2 FocusController) + long-press=操作员调试 + swipe/drag/pinch 全禁值调节 + 触感 .selection/.success/.impact 仅 iPhone。
- pros:学术共识强支持;与 D2+ExpandIntent 零冲突;触感增手持信心;不抢语音控制权
- cons:swipe 切族/drag 调值被砍(学术=正确取舍);触感 Mac/iPad 无效需双通道

### ⭐C2 微交互（fit 10/10）
symbolEffect 按态精准(.bounce/.pulse/.replace,禁 wiggle 常驻) + numericText 必 withAnimation(4a 已对) + boot/wow phaseAnimator + orb keyframeAnimator/TimelineView + iOS26 .glassEffect.interactive() 仅功能层/激活态。
- pros:全端侧独有炸场;每效果标记具体时刻(don't-over-animate);承接 D6/E1/tokens/hig-rules;4a numericText 可直接验收
- cons:需克制;.glassEffect.interactive() iOS26.1 已知坑需绕

### ⭐C3 层级（fit 9/10）
竖屏聚焦=ZStack overlay+显式稳定 zIndex+9 族 blur 分级(D2) + opacityScale 默认+mge gated(D5) + 不用 sheet。
- pros:保住 orb 三屏分层常驻;Grid 规避 mge laziness;显式 zIndex 防错乱;macOS26 mge 可用双端同源;承接 D2/D5
- cons:手写多管 zIndex/opacity/blur(轻治理可控);mge 两端同存需 spike 验(竖屏 2 列滚动态)

### C4 Mac hover 补充（fit 6/10,低优先）
Mac 加 onHover scale 1.02+hoverEffect(.highlight)给指针 affordance。
- pros:Mac 触控板时哪些卡可点一眼可见;content_glow 背景规避 onHover bug
- cons:纯加分非必须(iPhone 主路径 tap 无 hover);对竖屏直接贡献小

---

## Gaps vs grill/4a

1. **[4a gap·非分歧]** 4a 零手势 handler(grep 确认),全景卡纯展示不可 tap——承接 D2 已规划,4a 边界外(tap 聚焦归 4b/4c)。
2. **[4a gap·非分歧]** 无竖屏三-zone(orb120/content440/mic80,D1 锁)+无活跃置顶——D1.Q1.4/D4 已规划未实装,层级候选依赖三-zone 先落。
3. **[4a 对齐·正面]** 4a numericText 已 withAnimation(193-194)+breathe 仅激活态(213-216)+7态穷尽 switch+scope 角标——对齐 grill。
4. **[工具 gap]** force-state 走 launch argument 非 URL scheme;MEMORY 提的 simctl openurl 降本未实装;建议与 long-press 操作员调试入口联动。
5. **[与 GPT 分歧·承接 MEMORY]** 守别引第三方过度工程化:手势/微交互/层级全用 SwiftUI 原生(onTap/onLongPress/symbolEffect/phaseAnimator/glassEffect/ZStack+zIndex),adopt 原生>引库。
6. **[需 4b/4c spike]** mge 在 2 列竖屏 Grid+ScrollView 滚动态下源滚出屏会 snap——D5 snapshot focus_expand_10 抖闪验在竖屏需专门跑(横屏 Mac 10 张不滚不暴露);建议 4c 触发聚焦 spike 必含竖屏 2 列+活跃置顶后 mge 是否稳。

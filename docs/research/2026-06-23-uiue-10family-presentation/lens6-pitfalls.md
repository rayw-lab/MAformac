## summary

本 lens = **经典 issue / 坑点 oracle（pre-mortem）**,聚焦 10 族多卡片【展示/呈现】在 SwiftUI(macOS 主舞台 + iOS 加分,iOS26 Liquid Glass 时代,target macosx26.0)的失败模式。结论一句话:**scheme1 的 2×2 静态网格撑不住 10 族不是孤立问题——它和「深空暗底辉光 + 全景↔聚焦 matchedGeometry + 投屏 + 多意图联动」叠加后,有 7 个会在客户现场炸场的坑,其中 3 个是 HIGH(必停下让磊哥拍)。**

核心结论(对「主视图形态 A/B/C」三候选):
- **Form B(纯动态浮现)= 最高坑密度**:动态插入卡片必触发 layout reflow 跳动(SwiftUI 已知行为非 bug) + matchedGeometryEffect 在 LazyVGrid 里的「multiple-source 运行时冲突 + 懒渲染源不存在」+ Reduce Motion 下浮现动画被剥离 → 卡片瞬切。
- **Form C(静态全网格)= 信息过载坑**:10 族 > Miller 7±2 短期记忆上限 + 语音驱动场景客户不浏览,10 卡同时喊话反而抢走「这一句指令改了什么」的注意力。
- **Form A(全景常驻 + 触发聚焦)= 结构最安全但仍有 2 坑**:全景常驻消除 reflow 跳动,但「聚焦过渡」若用 matchedGeometryEffect 仍踩 LazyVGrid 冲突;低电量/Reduce Motion 下需非动画 fallback,否则「全景聚焦失效」。

本机 scout 坐实:主显示器 1920×1080 FHD(投屏 8bit banding 风险面真实存在);Swift 6.3.2 / Xcode 26.5 / macosx26.0(Liquid Glass `glassEffect` 三 offscreen texture 代价适用);当前 baseline `ContentView.swift:40` = `LazyVGrid(.adaptive(minimum:160))` 无 max + 绿/灰二值 8 卡,**已踩坑#1(adaptive 无 max → window resize 重排)**。

---

## findings(逐条带 source)

### Tiger 1 — 大网格滚动卡顿 / 重建(per-cell 复杂度,非数量)
- **机理**:SwiftUI lazy 容器长期已知性能问题。Apple 早期 bug **FB8436070**(openradar)实测:Apple TV 上 SwiftUI lazy stack/grid 滚动远逊于 UICollectionView,**20×20 这种小数据量就能看出卡顿**,LazyHGrid/LazyVGrid 同病。
- **本项目的真实风险点**:我们只有 **10 族卡片(数量小)→ 数量不是问题**;真正的杀手是 **per-cell 复杂度**——每卡叠 blur + 辉光 + shadow + 值动效。坑#1的「滚动卡顿」会变形为「**重建/动效卡顿**」。
- **验证清单**:① Xcode 「Color Offscreen-Rendered Yellow」看每卡是否触发 offscreen 黄;② Instruments SwiftUI template 看 body 重算次数;③ 目标 ≥60fps(iPhone 120fps)。
- **vs baseline**:**worse**——baseline 是纯文字卡(简单),加辉光后 per-cell 复杂度暴涨。
- source: [openradar FB8436070](https://openradar.appspot.com/FB8436070) / [Wesley Matlock - Tuning Lazy Stacks and Grids](https://medium.com/@wesleymatlock/tuning-lazy-stacks-and-grids-in-swiftui-a-performance-guide-2fb10786f76a)(2026-06-23 检索)

### Tiger 2(HIGH)— matchedGeometryEffect 全景↔聚焦 在 LazyVGrid 里抖动/失效
- **机理(LazyVGrid 专属 gotcha)**:① **multiple-source 运行时冲突**——LazyVGrid 多 cell 用同一 id+namespace 时,SwiftUI 要求「只能一个 source」,多 source 会运行时报错;② **懒渲染时序**——LazyVGrid 只渲染可见 cell,聚焦时源 cell 可能还没创建;③ 标准修法是「match 后在 onAppear 里 unmatch」的 hack。
- **额外坑**:modifier 顺序错(`.matchedGeometryEffect` 必须在 `.frame` **之前**)/ 没有用 `withAnimation` 包状态变更 / source-destination 没有条件渲染对称 → 闪烁、视图重复、单向无动画。
- **🔴 macOS 主舞台叠加**:`navigationTransition(.zoom)` / `ZoomNavigationTransition`(iOS18 那套更省心的替代)**在 macOS 上不可用**(只有 `NavigationTransition` 协议在 macOS 15,`ZoomNavigationTransition` 类型标 unavailable on macOS)——**所以 Mac 主舞台被迫只能用更易踩坑的 matchedGeometryEffect,不能用更稳的 zoom transition**。
- **验证清单**:① 全景→聚焦→返回 来回 10 次看是否抖/闪/重复;② 控制台是否有 multiple-source 警告;③ 聚焦一个尚未滚入视野的 cell 是否无动画。
- **vs baseline**:**unknown→worse**(baseline 无聚焦态,引入聚焦即引入此坑)。
- source: [Apple Forums - matchedGeometryEffect in LazyVGrid #669115](https://developer.apple.com/forums/thread/669115) / [Apple Forums #689053](https://developer.apple.com/forums/thread/689053) / [SwiftUI Lab matchedGeometryEffect Part2](https://swiftui-lab.com/matchedgeometryeffect-part2/) / macOS unavailable: [createwithswift zoom transition](https://www.createwithswift.com/using-the-zoom-navigation-transition-in-swiftui/) + [hmlongco/Navigator issue #25](https://github.com/hmlongco/Navigator/issues/25)(CLOSED, 2025-01-29,确认 zoom 需传 @Namespace 的框架摩擦)

### Tiger 3(HIGH)— 动态浮现卡片布局跳动(Form B 核心杀手)
- **机理**:SwiftUI 条件插入/删除视图(`if`)→ **兄弟视图必然 reflow 让位**(官方确认这是 valid behavior 非 bug)。无动画时 = 瞬间跳;即便有动画,LazyVGrid `.adaptive` 在 item 数变化时**列数会重算 → 整网格 reflow 跳位**。
- **当前 baseline 已踩**:`ContentView.swift:40` 用 `GridItem(.adaptive(minimum: 160))` **无 maximum** → ① item 数变化重排 ② **Mac window resize / 投屏分辨率切换时,两阶段布局算法(proposed vs reported width)重算列宽 → 跳动**。
- **修法**:① 单一列类型(别混 adaptive + fixed);② adaptive 的 min/max 设接近 / 或直接 `.flexible()` 固定列数数组;③ 预留占位(Spacer/固定 frame)消跳;④ `withAnimation` + asymmetric transition 让 reflow 平滑;⑤ cell 标 Equatable 防全网格重算。
- **vs baseline**:Form B **worse than 静态网格**(静态网格无插入即无 reflow);Form A 全景常驻 **better**(无插入)。
- source: [Apple Tutorial - add/remove views with transition](https://www.hackingwithswift.com/quick-start/swiftui/how-to-add-and-remove-views-with-a-transition) / [swiftyplace LazyVGrid adaptive reflow](https://www.swiftyplace.com/blog/swiftui-lazyvgrid-and-lazyhgrid) / [SwiftUI Field Guide LazyVGrid 两阶段布局](https://www.swiftuifieldguide.com/layout/lazyvgrid/)(2026-06-23 检索)

### Tiger 4(HIGH)— 深空暗底 10+ 卡片对比度 / halation 辉光过载
- **机理**:① **halation(光晕效应)**——暗底 + 亮文字/辉光在散光人群(约 47% 人有不同程度散光)眼里产生光晕,阅读吃力甚至刺痛;**纯黑 #000000 最严重**(我们用 #0a0b12 接近纯黑);② **饱和霓虹色会「视觉震动」**——cyan #00e5ff + violet #7b5cff 这种高饱和即便**对比度数学达标也会 vibrate**,在暗底上引起不适/闪烁感;③ WCAG AA 暗色主题仍需 4.5:1(正文)/3:1(大字/非文字),**单纯反色或加辉光常 fail**。
- **🔴 与项目自身教训直接撞车**:这正是磊哥飞书白皮书「**全部都太丑、看不清**」打脸的同一根因(审美压过实用 + 深空暗底对比度低 + 字小)。aesthetic-first rule 验收纪律明确要求「还原用户实际查看环境 + 浅色高对比优先」。
- **验证清单**:① 每卡文字/数值对 #0a0b12 实测对比度 ≥4.5:1;② 用 #121212 级软黑替代纯黑级 #0a0b12 看 halation 是否减轻;③ 辉光降饱和(desaturate accent);④ **逐张 Read 检测,不抽查**;⑤ 投屏后(非高清导出图)看得清吗。
- **vs baseline**:baseline 绿/灰对比保守安全;深空辉光 **worse on 可读性,better on 视觉冲击** → demo「惊艳 vs 看得清」张力。
- source: [Smashing - Inclusive Dark Mode(halation + 47% 散光)](https://www.smashingmagazine.com/2025/04/inclusive-dark-mode-designing-accessible-dark-themes/) / [accessibilitychecker 纯黑 #121212 vs #000](https://www.accessibilitychecker.org/blog/dark-mode-accessibility/) / [BOIA 提供暗色≠满足 WCAG](https://www.boia.org/blog/offering-a-dark-mode-doesnt-satisfy-wcag-color-contrast-requirements)(2026 检索)

### Tiger 5 — 投屏 8bit banding(深空渐变 + 高对比投影放大)
- **机理**:8bit 暗部渐变 → 近黑色阶不足 → 可见条带;**深空暗底大面积低对比渐变正是 banding 高发区**;关键反直觉——**高对比投影(激光投影/perfect black)让 banding 更糟不是更好**;无线 AirPlay 投屏的实时编码进一步压坏渐变。
- **本机坐实**:主显示器 1920×1080 FHD,投屏场景真实存在。
- **修法**:① **Interleaved Gradient Noise(IGN)抖动**——GPU 友好、噪声几乎不可见(SwiftUIShaders 的 layerEffect 可叠);② 渐变加极轻 grain;③ **现场优先有线 HDMI/USB-C 投屏,不用无线 AirPlay**(见 Tiger 6)。
- **vs baseline**:baseline 纯色卡无渐变 → 无 banding;深空渐变 **worse**。
- source: [KTC - 面板 bit depth 导致暗部 banding](https://us.ktcplay.com/blogs/technology-hub/monitor-bit-depth-causes-banding) / [BlurBusters - 激光投影更易见 banding](https://forums.blurbusters.com/viewtopic.php?t=927) / [frost.kiwi - IGN GPU dither 正解](https://blog.frost.kiwi/GLSL-noise-and-radial-gradient/)(2026 检索)

### Tiger 6 — AirPlay 无线投屏动画掉帧 / 微卡顿
- **机理**:无线投屏需实时采样+压缩+传输+解压,**静态屏好处理、动画/快速运动必掉帧 + 微停顿 + 光标/动画 choppy**;A 系列 GPU tiled deferred 渲染本身 ~2 帧延迟 + AirPlay 压缩叠加。
- **修法**:① **有线 HDMI/USB-C 投屏**(多个来源确认有线消除卡顿);② 5GHz Wi-Fi + 关 Apple TV 蓝牙 + 关后台 app;③ 关键动画时刻倾向静态揭示而非连续动画。
- **现场含义**:demo「反应快/不崩」北极星 → **必须有线投屏**写进现场 checklist。
- **vs baseline**:与方案无关,是现场环境坑;但**辉光连续动画 + 投屏 = 复合放大**,baseline 静态卡更耐投屏。
- source: [MacRumors - AirPlay 镜像延迟根因](https://forums.macrumors.com/threads/any-way-to-cut-the-lag-in-screen-mirroring-over-airplay.1883579/) / [airdroid - laggy AirPlay 11 fixes](https://www.airdroid.com/screen-mirror/laggy-airplay/)(2026 检索)

### Tiger 7 — 低电量/Reduce Motion 禁动画后全景聚焦失效
- **机理**:① **Reduce Motion 不会自动剥离你的自定义动画**——matchedGeometryEffect 是「需要你自己处理」的位移型 hero 动画(系统 zoom transition 会自动 fallback,**但 matchedGeometry 不会**);若 Reduce Motion 下不给 `.opacity` 交叉淡入 fallback → 聚焦变瞬切跳。② **Low Power Mode 也不自动禁动画**——需自己测 `ProcessInfo.processInfo.isLowPowerModeEnabled`,且**LPM 是 iPhone 专属,iPad/Mac 永远返回 false**。③ iOS26 **Reduce Transparency** 把 Liquid Glass 换成不透明背景——自定义 glass 卡若无不透明 fallback → 看起来 broken/不可读;iOS26.1 Increase Contrast + Dark mode 还有对比度 bug。
- **现场含义**:客户的 iPhone 加分屏可能开了 LPM/Reduce Motion/Reduce Transparency → 全景聚焦动画消失 / glass 卡崩样式。Mac 主舞台不吃 LPM(返回 false)但吃 Reduce Motion/Transparency。
- **验证清单**:① 开 Reduce Motion 看聚焦是否仍以 opacity fallback 完成(非瞬切);② 开 Reduce Transparency 看 glass 卡是否有不透明 fallback;③ iPhone 开 LPM 测动效降级;④ 三开关在 Light/Dark 都测。
- **vs baseline**:baseline 无 glass/无聚焦动画 → 不吃这坑;深空 glass 聚焦方案 **worse**,必须显式 fallback。
- source: [hackingwithswift - Reduce Motion withOptionalAnimation + matchedGeometry 需自处理](https://www.hackingwithswift.com/quick-start/swiftui/how-to-reduce-animations-when-requested) / [BleepingSwift - LPM 检测](https://bleepingswift.com/blog/detect-low-power-mode-swiftui) / [MacRumors - iOS26 Reduce Transparency 换不透明](https://www.macrumors.com/how-to/ios-reduce-transparency-liquid-glass-effect/) / [Apple Community - 26.1 Dark mode 对比度 bug](https://discussions.apple.com/thread/256181202)(2026 检索)

### Paper-Tiger 1 — 「10 族 = 10 卡片太多会卡」
- **看似威胁实际安全**:10 数量远低于 lazy grid 性能拐点(FB8436070 是 20×20=400 才明显)。**数量根本不是性能坑**——真正坑是 per-cell 辉光复杂度(Tiger 1)。别因「怕卡」砍卡片数,要砍的是每卡的 offscreen 层数。
- 证据:[FB8436070](https://openradar.appspot.com/FB8436070)(20×20 才显)。

### Paper-Tiger 2 — 「Liquid Glass 卡片很贵,demo 会卡死」
- **半真半假需给证据**:Apple 文档确认每个 `glassEffect` 需 **3 个 offscreen texture**,「too many containers/effects degrades performance」、且「glass-on-glass」要避免(glass 无法采样其他 glass)。但——**Mac 主舞台 GPU 强**,3-4 个 glass 元素同帧在所有平台实测 smooth;真正风险在 iPhone 加分屏 + 10 卡全 glass。修法:① 用 `GlassEffectContainer` 把多卡 glass 合进一个 CALayer;② glass 只用在导航/功能层不用在内容层;③ 限制同屏 glass 数。**注意 iOS26.1 已知 bug:Menu 放进 GlassEffectContainer 会破坏 morphing 动画。**
- 证据:[Apple Docs - Applying Liquid Glass to custom views(限制同屏数)](https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views) / [juniperphoton - 3 offscreen texture + GlassEffectContainer](https://juniperphoton.substack.com/p/adopting-liquid-glass-experiences) / [blakecrosley - 3-4 glass smooth 实测 + 26.1 Menu bug](https://blakecrosley.com/blog/liquid-glass-swiftui-patterns)。

### Elephant 1(没人提该提)— 10 族 > Miller 7±2,语音场景静态全网格反成噪声
- **被忽略的真相**:坑#6「信息过载」不只是「看着乱」,有认知科学硬约束——**Miller's Law 短期记忆 ~7±2**,10 族同屏超上限;Hick's Law 选项越多决策越慢。**更关键:这是语音驱动 demo,客户不是在浏览菜单**——方案经理说「打开空调」,客户要看的是「空调卡亮了」这一个反馈,**Form C 静态全网格把 10 卡同时喊话 = 抢走对「这句指令改了什么」的注意力**。渐进披露(Form A 聚焦活跃卡)> 静态全网格。
- source: [Laws of UX - Miller's Law / Hick's Law](https://lawsofux.com/hicks-law/) / [Smashing - Reducing Cognitive Overload](https://www.smashingmagazine.com/2016/09/reducing-cognitive-overload-for-a-better-user-experience/)。

### Elephant 2(没人提该提)— 多意图连续两句改 2+ 卡:注意力只能追一个,别同时闪
- **被忽略的真相**:多意图(连续两句)会同时改 2+ 卡片。in-car voice assistant 研究 + **Single-Item-Template 假说**:**视觉工作记忆同一时刻只能有一个 attentional template 主动引导注意力,其余被屏蔽**——所以同时高亮多卡会过载,**客户的眼睛追不过来**。修法:**多意图改多卡时用「序列化/优先级高亮」(一卡亮完再亮下一卡,带 ~150-300ms 错峰),不要两卡同时闪**。这条直接决定「多意图联动」怎么演才不丢脸。
- source: [bioRxiv - Single-Item-Template 假说](https://www.biorxiv.org/content/10.1101/629378.full.pdf) / [ResearchGate - 车载语音助手视觉反馈用 ambient lighting 引导注意力](https://www.researchgate.net/publication/390695746_Visual_feedback_for_in-car_voice_assistants)。

### Elephant 3(没人提该提)— 异构值形态卡片做不到「一卡懂卡卡懂」会加重认知负担
- **被忽略的真相**:10 族值形态异构(温度连续 18-32℃ / 风量档 1-10 / RGB 颜色 / 开度 0-100% / 座椅多维 / 开关 / 香氛浓度)。UX 研究强调「**卡片设计一致 → 懂一张懂全部**」;但异构值若每族用完全不同的可视化(滑条 vs 色块 vs 档位 vs 开关),客户每张都要重新解析 = 认知负担叠加 Miller 上限。U13 已拍「value.type 三分动效」是对的方向,但要保证**卡片骨架统一(标题位/数值位/状态位同位置同字号),只让「值可视化区」按 type 变**,而非整卡形态各异。
- source: [accessibilitychecker - 卡片一致性「懂一张懂全部」](https://www.accessibilitychecker.org/blog/dark-mode-accessibility/)(card consistency 段) + 项目 U13 决策。

---

## pre-mortem(三分类汇总)

- **Tigers(明确威胁,带验证清单)**:T1 per-cell 辉光 offscreen 卡顿 / **T2(HIGH)matchedGeometry 在 LazyVGrid 抖动+macOS 无 zoom transition 退路** / **T3(HIGH)动态浮现/adaptive 无 max 的 reflow 跳动(baseline 已踩)** / **T4(HIGH)深空暗底 halation+饱和霓虹震动+对比度 fail(撞磊哥飞书白皮书同坑)** / T5 投屏 8bit banding(高对比投影更糟)/ T6 AirPlay 无线投屏动画掉帧 / T7 Reduce Motion+LPM+Reduce Transparency 三开关下聚焦动画/glass 失效。
- **Paper-tigers(看似威胁实际可控,给了证据)**:PT1「10 卡太多会卡」(数量非瓶颈,20×20 才显)/ PT2「Liquid Glass 会卡死」(3 offscreen/glass 但 GlassEffectContainer + 限同屏数可控,3-4 glass 实测 smooth)。
- **Elephants(没人提该提)**:E1 10 族 > Miller 7±2 且语音场景静态全网格反成注意力噪声 / E2 多意图改多卡时注意力只能追一个 template → 必须序列化高亮不同时闪 / E3 异构值卡片须骨架统一只变值区,否则认知负担叠加。

---

## adopt 候选

- **krispuckett/SwiftUIShaders**(184★,pushedAt 2026-06-01,**22 天 fresh**,已 clone `ref-repos/SwiftUIShaders`):用 `[[stitchable]]` Metal `layerEffect` + `visualEffect` + `TimelineView(.animation)` 自驱。**adopt 用途**:① IGN/dither 抖动消投屏 banding(T5);② 辉光/aurora 效果(`bcs_aurora`/`bcs_etherealAura`/`bcs_plasma`/`bcs_neonEdge` @ `Sources/SwiftUIShaders/Shaders/SwiftUIShaders.metal`)。**坑提示**:`TimelineView(.animation)` 自驱 = 持续 GPU draw,iPhone 加分屏须配 Reduce Motion/LPM 降级(T7)。
- **conorluddy/LiquidGlassReference**(307★,pushedAt 2026-03-08,**~107 天 偏旧**):iOS26 Liquid Glass 最佳实践参考文档(非组件)。**adopt 用途**:GlassEffectContainer 用法 + 限同屏数 + glass-on-glass 规避(PT2)。按 github-first 60 天硬约束 = **borderline,作参考不作依赖**。
- **metasidd/Orb**(422★,pushedAt 2024-11-11,**~19 月 STALE**):语音 orb 组件。**🔴 按 github-first 新鲜度硬约束应淘汰**(半年没动直接淘汰不管 star)——若要 orb 自己手搓或找更新的,**不建议直接 adopt 这个**。
- **方法论 adopt(非 repo)**:① adaptive→固定 `.flexible()` 列数 + Equatable cell(T1/T3 修法);② matchedGeometry 的「onAppear unmatch」hack + isSource 显式指定(T2 修法);③ `withOptionalAnimation` wrapper 统一 Reduce Motion + LPM 降级(T7 修法);④ 序列化高亮替代同时闪(E2 修法)。

---

## presentation_options(本 lens 对「10 族怎么展示」的建议)

1. **⭐ 倾向 Form A(全景常驻 + 触发聚焦),但聚焦过渡别用 matchedGeometryEffect**:全景常驻消除 T3 reflow 跳动(最致命且 baseline 已踩的坑);聚焦改用「常驻卡原地放大/边框辉光强化 + 内容淡入」的 opacity/scale 组合(避开 T2 的 LazyVGrid matchedGeometry 冲突 + macOS 无 zoom transition 退路)。这是坑密度最低的形态。
2. **网格用固定列数 `.flexible()`(如 5×2 或 2×5),不用 `.adaptive(minimum:)`**:直接修掉 baseline `ContentView.swift:40` 的坑#1——window resize / 投屏分辨率切换不重排;cell 标 Equatable。
3. **卡片骨架统一,只有「值可视化区」按 value.type 三态变(U13)**:标题/数值/状态同位置同字号(E3 修法 + 飞书白皮书一致性教训),客户「懂一张懂全部」。
4. **多意图改多卡 = 序列化高亮,不同时闪**(E2):一卡亮完(~150-300ms)再亮下一卡,配错峰的 ambient 辉光引导注意力;别两卡同时跳。
5. **配色:深空暗底从 #0a0b12(近纯黑)上抬到 #121212 级软黑,accent 辉光降饱和**(T4):保留科幻感但减 halation/震动;文字/数值对底实测 ≥4.5:1;**逐张 Read + 还原投屏环境验收,不抽查不看高清导出图**(磊哥飞书白皮书教训)。
6. **渐变区叠 IGN dither(SwiftUIShaders)消投屏 banding**(T5)+ **现场强制有线 HDMI/USB-C 投屏写进 checklist**(T6)。
7. **三开关 fallback 必做**(T7):Reduce Motion → opacity 交叉淡入聚焦;Reduce Transparency → glass 卡不透明 fallback(否则 broken);iPhone 加分屏检测 LPM 降级动效。Mac 主舞台不吃 LPM(返 false)可不测但仍吃 Reduce Motion/Transparency。
8. **避免 Form B(纯动态浮现)作主形态**:它独占 T3(reflow 跳)+ T2(懒渲染源不存在)+ T7(Reduce Motion 浮现被剥离瞬切)三坑,坑密度最高;Form C(静态全网格)踩 E1 信息过载/语音场景注意力噪声。
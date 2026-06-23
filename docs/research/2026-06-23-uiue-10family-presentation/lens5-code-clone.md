## summary

调研 lens = 「成熟框架代码链路 clone 深扒」。结论:**没有任何高 star + 近活跃的 SwiftUI「车控/座舱 HMI」专用 repo 可直接 adopt**(Tesla-app 类全是 0★ 玩具,2021-2023 死掉)——10 族展示方案只能用「通用 dashboard 网格 + 成熟动画/shader 组件」拼装。但好消息:本机已 clone 的 ref-repos + 1 个新 clone(Inferno) + iOS 原生 API 足够覆盖全部需求,且 file:line 级可抄的代码模式都已坐实。

**10 族展示的根本信息架构问题** = scheme1 只画 4-6 张同质卡片(2×2),撑不住 10 族 + 异构值形态(温度连续/风量档位/RGB/开度/座椅多维)。解法 = **全景自适应网格(10 族卡)→ 点击/语音聚焦 matchedGeometry 展开成详情面板(异构值控件)→ 背景 dim/blur**。这套「网格→聚焦展开」是 SwiftUI 业界最成熟的 hero 模式,本机 DaVinci(sliding pill) + IceCubes(grid→navigate) 已有半套,完整 expand-in-place 需用 SwiftUI Lab 范式补齐。

核心代码模式全部坐实可抄:
- **自适应网格**: `ContentView.swift:40` 现已用 `.adaptive(minimum:160)`(✅已对);iPhone 用 `.flexible()`×2 固定列、Mac/投屏 `.adaptive(minimum:200)` 自适应列。
- **matchedGeometry 聚焦展开**: ZStack overlay + 同 `id`+`@Namespace` + `Color.clear` 占位 + `withAnimation(.spring)`(SwiftUI Lab);导航式则 `matchedTransitionSource`+`.navigationTransition(.zoom)`(iOS18 需 `#available`)。
- **异构值控件**: 连续值(温度/风量/开度)= 原生 `Gauge(.accessoryCircular)`+ gradient tint(iOS16,零依赖);档位 = DaVinci `DSSegmentedControl` 的 `matchedGeometryEffect(id:"selectedSegment")` 滑块;数字滚动 = ShipSwift `SWKPICard` 的 `.contentTransition(.numericText())`。
- **激活辉光/呼吸/水波**: scheme1 box-shadow breathe(已有)+ Orb `RotatingGlowView`(纯代码 Circle+blur mask,iOS17 fallback)+ Inferno `Water.metal`(炸场水波,对齐 U5 已锁决策)。

## findings(逐条带 source)

### F1 — 本机已 clone ref-repos 实况(scout 坐实,非猜)
- 已 clone 36 个 ref-repos 在 `~/workspace/raw/05-Projects/MAformac/ref-repos/`,含 SwiftUI 相关:IceCubesApp / Orb / hanlin-ai / mlx-swift-examples / fullmoon-ios / itsyhome-macos / open-swiftui-animations / SwiftUIShaders / ShipSwift / DaVinci / exyte-Chat / MLX-Outil。
- 本机:屏幕 **1920×1080 FHD**(投屏基线,8bit banding 风险确认);Swift 6.3.2 / Xcode 26.5 / SDK iOS26.5。source: 本机 `system_profiler` + `swift --version`,2026-06-23。
- 🔴 **关键空白**:36 repo 里**没有一个是 SwiftUI 车控/座舱 HMI**。itsyhome-macos 是 menubar 智能家居(非 SwiftUI tile 网格)。需从通用 dashboard 拼装。source: `find itsyhome-macos -name *.swift`(全是 macOSBridge/MenuBuilder),2026-06-23。

### F2 — 「网格→点击聚焦展开」canonical 模式(本机 DaVinci 半套 + 业界补齐)
- **DaVinci `DSSegmentedControl.swift:60,119`**:`@Namespace private var animation` + 选中态 fill 上 `.matchedGeometryEffect(id:"selectedSegment", in:animation)` + `withAnimation(theme.motion.snappy)`——这是**档位控件滑块**的完整可抄范式(风量1-10/座椅档位)。source: `ref-repos/DaVinci/Sources/DaVinciComponents/DSSegmentedControl.swift:60,87-126`,DaVinci 含 `DaVinciTokens` 主题系统。
- **IceCubesApp `AccountDetailMediaGridView.swift:26-92`**(7005★,pushed 2026-06-09,极新):`LazyVGrid(columns:[.flexible(minimum:100)×3])` + 每格 `GeometryReader` 做正方形 + `.aspectRatio(1,.fit)` + `.onTapGesture{navigate}`。但它是**导航式**(navigate 到 detail),非 in-place expand。source: 该文件 file:line,star/pushedAt 经 `gh repo view Dimillian/IceCubesApp` 核实。
- **完整 expand-in-place 范式**(none 本机有完整版,业界补):ZStack 内 grid 卡与展开 detail 用同 `id`+`@Namespace`,选中时 grid 位置放 `Color.clear` 占位、detail overlay 浮现,`withAnimation(.spring())` 切换 `selectedItem`。source: [SwiftUI Lab matchedGeometryEffect Part1/2](https://swiftui-lab.com/matchedgeometryeffect-part1/) + [Swift with Majid hero animations](https://swiftwithmajid.com/2020/12/17/hero-animations-in-swiftui/),2020-2024 范式仍现行。
- **导航式 zoom(iOS18+)**:`CardView().matchedTransitionSource(id:"card",in:ns)` + `DetailView().navigationTransition(.zoom(sourceID:"card",in:ns))`——**必 `#available(iOS18)` 守卫**(对齐 hig-rules U19)。source: 同上 Majid 文 + WebSearch 2026-06-23。

### F3 — 自适应网格列(10 族跨 iPhone/Mac/投屏)
- `.flexible()` = **固定列数**(每列等分),`.adaptive(minimum:)` = **系统决定列数**(真跨设备响应)。🔴 **caution: 别把 adaptive 与 flexible 混用**。source: [Sarunw LazyVGrid](https://sarunw.com/posts/swiftui-lazyvgrid-lazyhgrid/) + [Medium @abdulkarimkhaan grid items](https://medium.com/@abdulkarimkhaan/swiftui-grid-items-flexible-adaptive-and-fixed-swiftui-api-2-3e3a3091196d),WebSearch 2026-06-23。
- **MAformac 落地**:iPhone(窄)用 `[.flexible(),.flexible()]` 2 列(10 族=5 行);Mac/投屏(宽)用 `[.adaptive(minimum:200)]` 自适应 4-5 列。现状 `ContentView.swift:40` 已用 `.adaptive(minimum:160)`(✅方向对,只需按设备调 minimum)。
- 对比基线:`.adaptive` vs scheme1 的写死 2×2 CSS grid = **better**(自动适应 Mac 主舞台 + iPhone 加分屏 + 投屏 1920×1080),证据 = adaptive 是多平台官方推荐。

### F4 — 异构值可视化控件(每族值形态 1:1 映射)
- **连续值(温度18-32℃/风量1-10/车窗0-100%/香氛浓度)** = 原生 `Gauge(value:in:){label}.gaugeStyle(.accessoryCircular).tint(Gradient(...))`,iOS16+ **零依赖**,iOS 锁屏天气 widget 同款环。source: [Apple docs accessoryCircular](https://developer.apple.com/documentation/swiftui/gaugestyle/accessorycircular) + [Sarunw Gauge](https://sarunw.com/posts/swiftui-gauge/) + [devtechie 温度环示例](https://www.devtechie.com/community/public/posts/154041-new-in-swiftui-4-gauge-view),2026-06-23。
- **数字滚动(温度从 24→26 morph)** = ShipSwift `SWKPICard.swift:135` 的 `.contentTransition(.numericText())`,值变更必 `withAnimation(.spring)` 包裹(否则不动,对齐 tokens motion.spring + README:47)。source: `ref-repos/ShipSwift/.../SWKPICard.swift:131-135`。
- **档位/离散值(座椅加热0-3/风量档位)** = DaVinci `DSSegmentedControl`(F2,滑块 matchedGeometry)。
- **多维控件(座椅=加热×通风×按摩)** = 展开面板内堆 3 个独立子控件(toggle+gauge),无单一组件,用 VStack 组合。⚠️ 本机无现成多维座椅控件,需自建(elephant,见 pre-mortem)。
- **RGB 氛围灯颜色** = 展开面板内色环/色块预览;Inferno `Sinebow.metal`/`AnimatedGradientFill.metal` 可做流动色带氛围。source: `ref-repos/Inferno/Sources/Inferno/Shaders/Generation/Sinebow.metal` + `Transformation/AnimatedGradientFill.metal`。
- **开关族(车门/天窗/雨刮)** = 卡片直接亮暗态(scheme1 已有 on/off),不需展开。

### F5 — 激活辉光/呼吸/炸场水波(对齐已锁 tokens + U5)
- **激活辉光呼吸** = scheme1 `breathe` keyframe(box-shadow 3.4s,已有)→ SwiftUI 落 `content_glow` 自研 box-shadow(**非 system glass**,U2 铁律)。source: tokens.md:80 + hig-rules:19。
- **纯代码 glow(iOS17 fallback / 不依赖 PNG)** = Orb `RotatingGlowView.swift:42-61`:`Circle().fill(color).mask{Circle().blur + Circle().blendMode(.destinationOut)}.rotationEffect`——零 asset、纯代码旋转辉光环,可做 idle orb + 激活卡 glow。source: `ref-repos/Orb/Sources/OrbView/Subviews/RotatingGlowView.swift:42-61`(Orb 422★ 但 2024-11 旧 + 主体依赖 PNG,**只抄 RotatingGlowView 这个纯代码子件**)。
- **炸场水波(U5 一期)** = Inferno `Water.metal`(2879★,pushed **2026-05-17 新**):`[[stitchable]] float2 water(... speed strength frequency)`,文档明示 `strength3/freq10` 起手——**与 hig-rules U5「adopt twostraws/Inferno strength3/freq10」逐字对齐**。已 clone 进 ref-repos。source: `ref-repos/Inferno/Sources/Inferno/Shaders/Transformation/Water.metal:28-44` + hig-rules:64。
- **Metal aurora/breathe glow** = SwiftUIShaders(pushed 2026-06-01 新)`.bcsEtherealAura`(「cover BREATHES,edges warp and glow」)/`.bcsAurora`,氛围层可点缀(U30:shader 仅氛围层,别常驻抢 GPU)。source: `ref-repos/SwiftUIShaders/Sources/SwiftUIShaders/ShaderEffects.swift:50,199`。

### F6 — 状态消费链路(UI 必须绑 7 态,现状只绑了 2 态)
- 状态源 = `Core/State/DemoVehicleStateStore.swift:17-25` 的 `DemoVisualState` 7 态枚举(normal/satisfied/changing/blocked_with_alternative/blocked_hard/unsafe/unknown)+ `DemoVehicleStateCell`(key/actualValue/desiredValue)。UI 消费 = `DemoWalkingSkeleton.swift:42-46` 的 `readback.key`+`readback.actualValue`+`readback.spokenText`。source: file:line 坐实。
- 🔴 **现状 bug(vs 现状基线的关键缺陷)**:`ContentView.swift:122,126` 把 7 态压成 `visualState==.satisfied ? .green : .gray`——正是 tokens.md:64 + hig-rules U10 警告的「7 态压成绿/灰二值」翻车点。展示方案必须按 tokens.md:54-62 七态色表 1:1 映射(clarify=琥珀/unsupported=灰锁/unsafe=红/crash=中性灰)。source: `App/ContentView.swift:122,126` grep 坐实 2026-06-23。

### F7 — 组件库新鲜度交叉验证(github-first 硬约束)
| repo | star | pushedAt | 判定 |
|---|---|---|---|
| IceCubesApp | 7005 | 2026-06-09 | ✅新,grid 范式可抄 |
| Inferno(新 clone) | 2879 | 2026-05-17 | ✅新,U5 已锁 adopt |
| SwiftUIShaders | (本机) | 2026-06-01 | ✅新,aurora glow |
| amosgyamfi/open-swiftui-animations | 5517 | 2026-06-16 | ✅新(但多为 spring 教程,非 dashboard) |
| buh/CompactSlider | 550 | 2025-11-22 | 🟡边界(~7月),跨平台 slider 参考 |
| exyte/Grid | 2086 | 2025-02-28 | 🔴淘汰(>60天),原生 LazyVGrid 已够 |
| Orb | 422 | 2024-11-11 | 🔴主体淘汰(旧+依赖 PNG),只抄 RotatingGlowView 纯代码子件 |
source: 逐个 `gh repo view --json stargazerCount,pushedAt` 2026-06-23。

## pre-mortem(三分类)

见 schema pre_mortem 字段。

## adopt 候选

见 schema adopt_candidates 字段。
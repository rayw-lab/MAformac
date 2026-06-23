# Lens 4 — 巨人肩膀：SwiftUI 展示组件 + skill（adopt>build）

> 主线程亲调（workflow w3q9qdisd 本路 rate-limited，磊哥令亲自补）。本机 ref-repos scout（file:line 已核）+ WebSearch 外部（URL+日期）。focus = 10 族车控前端展示的现成 SwiftUI 组件。

## summary

10 族展示所需的四类组件——**自适应网格 / 卡片 / 全景↔聚焦过渡 / 异构值可视化**——SwiftUI 原生 + 本机已 clone repo **全覆盖**，无需新造。关键：① 双屏自适应网格用 `LazyVGrid(.adaptive)`（本机 MLX-Outil 已是范式）② 全景网格→族卡聚焦展开用 `matchedGeometryEffect`（iOS17 状态切换）/ `matchedTransitionSource`+`.navigationTransition(.zoom)`（iOS18 跨栈，需 #available）③ 连续值（温度/开度）用原生 `Gauge .accessoryCircular`（iOS16+，无需 #available）。

## findings（逐条带 source）

### F1. 双屏自适应网格 = `LazyVGrid(.adaptive)`（本机已是范式，直接抄）
- **MLX-Outil `ToolsGridView.swift:39-59`**（本机 ref-repos，last commit **2026-05-23** git 核）：`LazyVGrid(columns: adaptiveColumns, spacing:16)` + `adaptiveColumns` 计算属性——Mac/iPad 用 `GridItem(.adaptive(minimum:280))`（自动多列），iPhone 用 2 列 `GridItem(.flexible(minimum:140), spacing:12)`。👉 **10 族卡片 + Mac/iPhone 双屏自适应的直接范式**：同一套 LazyVGrid，列数随屏宽自动变（Mac 全显 / iPhone 2 列滚动）。解 fork4（双屏）。
- hanlin-ai `QuickToolsView.swift:777-779`（2026-01-24，>60天临界）：`LazyVGrid(columns: Array(repeating: GridItem(.flexible(),spacing:10), count:3))` 固定 3 列网格（备选）。

### F2. 卡片 = 泛型可复用（本机 ShipSwift）
- **ShipSwift `SWKPICard.swift:75`**（2026-06-08 git 核活跃）：`struct SWKPICard<Trailing: View>` 泛型卡片（title/value/icon/tint + trailing slot）+ `SWKPIDeltaTag`（状态变化角标）+ `SWAnimatedMeshGradient`（卡片辉光动效）。👉 10 族卡片可按此泛型范式：`FamilyCard<Detail>`（族名/图标/状态值/tint=tokens 7 态色 + 展开 detail slot）。

### F3. 全景↔聚焦过渡 = `matchedGeometryEffect`（10 族网格点击展开核心交互）
- 模式（[swiftui-lab/swiftui-hero-animations](https://github.com/swiftui-lab/swiftui-hero-animations) + [SwiftUI Lab matchedGeometryEffect Part1](https://swiftui-lab.com/matchedgeometryeffect-part1/)）：`@Namespace` + 缩略卡与展开态同 `id`+namespace → SwiftUI 自动 morph 位置/尺寸/圆角。`withAnimation(.spring(response:0.6))` 切 `isExpanded`。
- ZStack 三层架构（全景聚焦标准）：L1 grid（zIndex1）/ L2 backdrop blur（zIndex2，聚焦时虚化全景）/ L3 modal 展开卡（zIndex3）。
- `properties:.size` / `.position` 可限制只动尺寸或位置（纯 zoom 用 .size）。
- 🔴 **iOS18 跨 NavigationStack**：matchedGeometryEffect 不跨栈；iOS18 用 `matchedTransitionSource(id:in:)` + `.navigationTransition(.zoom(...))`（Apple 推荐，**必 #available(iOS18) + iOS17 fallback** 退状态切换 matchedGeometryEffect）。
- 👉 解主视图形态 A（全景常驻+触发聚焦）：10 族 dim 网格 → 语音/点击触发 → 该族卡 matchedGeometry morph 放大展开（环形仪表/多维细节），背景全景 blur。

### F4. 异构值可视化 = 原生 `Gauge`（连续值，iOS16+ 无需守卫）
- [Apple Gauge 文档](https://developer.apple.com/documentation/swiftui/gauge) + [Sarunw](https://sarunw.com/posts/swiftui-gauge/) + [Use Your Loaf](https://useyourloaf.com/blog/swiftui-gauges/)：
  - **温度（连续值 18-32℃）** → `Gauge(value:cur, in:18...32){...} currentValueLabel:{Text("\(cur)℃")}.gaugeStyle(.accessoryCircular).tint(Gradient([青→琥珀→红]))` 开环+中心值+marker。
  - **开度/音量（0-100%）** → `.accessoryCircularCapacity` 闭环填充 + 中心 %。
  - 动态色：computed `gaugeColor` switch（值区间→tokens 色）。
  - iOS16+ 全平台可用（iOS17/18 都行，**不需 #available**）；自定义环用 `GaugeStyle` protocol + `Circle().trim`（配深空辉光环）。
- ⚠️ `.circular`/`.linear` 仅 watchOS，iOS 用 `.accessoryCircular`/`.accessoryCircularCapacity`。

### F5. mesh 辉光 / 动效（本机）
- ShipSwift `SWAnimatedMeshGradient.swift` + open-swiftui-animations `WWDC25Animation.swift`（**2026-06-16** 很活跃）= 卡片激活辉光 / orb 范式（配 tokens breathe）。
- itsyhome-macos `BatteryBadge.swift` = 状态徽章范式（族卡状态角标）。

## presentation_options（本 lens 对"10 族怎么展示"）
1. **主网格**：`LazyVGrid(.adaptive(min:280))` Mac 自适应多列 / iPhone 2 列（MLX-Outil:39 直接抄）—— 10 族卡片一套代码双屏。
2. **族卡**：泛型 `FamilyCard<Detail>`（ShipSwift SWKPICard 范式）+ tint=tokens 7 态色 + SWAnimatedMeshGradient 激活辉光。
3. **全景→聚焦**：matchedGeometryEffect（iOS17）/ matchedTransitionSource（iOS18 #available）—— 语音触发族卡 morph 展开，背景 blur。
4. **族内值**：温度/开度/音量用 Gauge `.accessoryCircular`/`.accessoryCircularCapacity`（连续值）；档位/多维/RGB 见 lens7（recipe-boundary）。

## pre-mortem
- **tiger**：matchedGeometryEffect 跨 NavigationStack 不工作（必 iOS18 matchedTransitionSource + #available，否则聚焦动画失效）→ 验证：iOS17 部署机实测全景→聚焦是否 morph。
- **tiger**：LazyVGrid 大量卡片（10 族×展开 detail）滚动重建掉帧 → 验证：限可见卡 + 稳定 id（见 lens6 坑）。
- **paper_tiger**：Gauge 自定义环复杂 → 实际原生 `.accessoryCircular` 两行够，自定义只在要深空辉光环时（GaugeStyle protocol 成熟）。
- **elephant**：本机 ref-repos 已有现成网格/卡片（MLX-Outil/ShipSwift），别从零写 —— 直接 adopt file:line，省一整轮。

## adopt 候选（star/日期，本机已 clone）
- `MLX-Outil/Views/ToolsGridView.swift:39-59`（本机，2026-05-23 活跃）—— LazyVGrid adaptive 双屏网格 ⭐直接抄
- `ShipSwift/.../SWKPICard.swift:75` + `SWAnimatedMeshGradient.swift`（本机，2026-06-08）—— 泛型卡片 + mesh 辉光
- `open-swiftui-animations/.../WWDC25Animation.swift`（本机，2026-06-16）—— WWDC25 最新动效
- `swiftui-lab/swiftui-hero-animations`（GitHub，matchedGeometryEffect 全景聚焦示例，[待核 star]）
- 原生 `Gauge`（iOS16+）+ `matchedTransitionSource`（iOS18）—— Apple 官方零依赖

## 🔴 主线程 gh cite-verify 坐实（adopt 新鲜度门，2026-06-23）
- ✅ **本机活跃可 adopt**（git log 核）：MLX-Outil 2026-05-23 / ShipSwift 2026-06-08 / open-swiftui-animations 2026-06-16
- 🔴 `swiftui-lab/swiftui-hero-animations` ⭐249 / pushed **2020-07-06**（gh 核，**stale 6 年，失新鲜度门**）→ **仅 matchedGeometryEffect 概念/代码读法参考，不作 SPM 依赖**
- 🔴 **结论（adopt 反转）**：全景↔聚焦优先 **原生** `matchedGeometryEffect`(iOS14) / `matchedTransitionSource`(iOS18 #available) + `Gauge`(iOS16)——Apple 原生零依赖零弃坑，stale 第三方只读概念不依赖。本机活跃 repo（MLX-Outil/ShipSwift）的网格/卡片代码可直抄。
- matchedTransitionSource=iOS18 / Gauge=iOS16 / matchedGeometryEffect=iOS14（Apple 文档，[版本待落地二次核]）

## sources
- 本机：MLX-Outil ToolsGridView:39-59 / ShipSwift SWKPICard:75 / hanlin-ai QuickToolsView:777 / open-swiftui-animations（git log 核日期）
- [SwiftUI Lab matchedGeometryEffect Part1](https://swiftui-lab.com/matchedgeometryeffect-part1/) / [swiftui-hero-animations repo](https://github.com/swiftui-lab/swiftui-hero-animations)
- [Apple Gauge 文档](https://developer.apple.com/documentation/swiftui/gauge) / [Sarunw Gauge](https://sarunw.com/posts/swiftui-gauge/) / [Use Your Loaf Gauges](https://useyourloaf.com/blog/swiftui-gauges/)

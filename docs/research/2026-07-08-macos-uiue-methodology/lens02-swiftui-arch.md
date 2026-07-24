# lens02 — SwiftUI macOS 工程方法:架构选型 / Previews / tokens / scene

> 一手结构化 finder 档 | workflow `wf_41662345-ab4` agent `ad1f39ed18932c6d7` | 2026-07-08 | opus/medium
> 角度原文: SwiftUI macOS 工程方法——UI 层架构选型(纯 MV / MVVM / TCA)、Xcode Previews 预览驱动开发、组件化与 design tokens、macOS 特有 UI 结构(多窗口/菜单栏/Settings scene/Liquid Glass)的实践与争论

## 摘要

2024-2026 的 SwiftUI macOS 工程共识正在从「UIKit 搬来的 MVVM」向「拥抱 SwiftUI 原生数据流」迁移:Apple 官方从未推荐 MVVM,社区(以 Thomas Ricouard 为代表)明确主张纯 MV——用 @Observable 模型 + @State/@Environment 直接驱动 View,不再强制 ViewModel;Apple 自身随 Observation 框架推动从 @StateObject/@ObservedObject/@EnvironmentObject 迁移到 @State/@Bindable/@Environment(Type.self),核心是「每份数据单一事实源」。TCA 在大型/强测试需求项目有市场,但对大型 macOS app 有明确性能代价(全量 state 下发,Arc 浏览器案例 5 行文本耗 9 秒 CPU),官方 FAQ 也承认小屏幕应回退到 plain State。Xcode 15 的 #Preview 宏 + Xcode 16 的 @Previewable 宏把预览升级为核心开发工作流,支持内联 @State、交互式预览、UIKit/AppKit 预览。Design tokens 落地成熟范式为三层(primitive→semantic→component),语义命名映射到 Asset Catalog Color 自动处理明暗/无障碍,主题经 Environment 注入以支持预览期多主题验证。macOS 特有结构上,SwiftUI 提供 WindowGroup/Window/Settings/MenuBarExtra/DocumentGroup 可组合的 scene 体系,Settings 自动接管 ⌘, 菜单项,但存在真实坑(SettingsLink 在 MenuBarExtra 里不可靠)。macOS 26 Tahoe 的 Liquid Glass 通过 Xcode 26 重编译自动生效,提供 glassEffect()/GlassEffectContainer/.glass 按钮样式,但需用 Reduce Transparency 测试且部分开发者对标题栏内容模糊持保留意见。对 MAformac(纯端侧演示助手、主演示面 macOS)而言,轻量 MV + @Observable + Environment 注入的方案最贴合其 solo demo 轻治理定位,预览驱动 + design tokens 能加速 UIUE 前置化,而 Liquid Glass 是「惊艳」现场的低成本自动增益。

## Findings

### 02.1 SwiftUI in 2025: Forget MVVM. Let me tell you why — Thomas Ricouard

- **声称**: Apple 官方从未为 SwiftUI 提供推荐架构,本质是「去掉 C 的 MVC」;社区代表人物 Thomas Ricouard(Ice Cubes 作者)在《SwiftUI in 2025: Forget MVVM》中明确主张「你不需要 ViewModel,过去不需要、将来也不需要」,把 MVVM 归为开发者从 UIKit 带来的包袱(MVVM Trap),并援引 WWDC19『Data Flow Through SwiftUI』作为权威依据。
- **来源**: <https://dimillian.medium.com/swiftui-in-2025-forget-mvvm-262ff2bbd2ed> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: WebFetch 只取到文章头部,核心论点已确认;完整方案(具体 @State/@Environment 组织)正文未加载,故其架构落地细节以其它 @Observable 迁移源交叉佐证。

### 02.2 iOS 17+ SwiftUI State Management: An Updated Comprehensive Guide (2025) — YLabZ

- **声称**: 现代 SwiftUI 状态管理的官方迁移路径:模型类 ObservableObject→@Observable(去掉 @Published);View 内持有实例 @StateObject→@State(保持单一事实源实例);只读子视图去掉 wrapper 直接传对象;需双向绑定用 @Bindable;全局注入 @EnvironmentObject→@Environment(MyType.self) 配 .environment(obj)。Environment 应保留给 app 设置/用户会话/导航等横切关注点,局部数据用更显式的状态。
- **来源**: <https://zoewave.medium.com/new-swiftui-state-management-3a6c9b737724> (仅搜索摘要, 采集日 2026-07-08)
- **备注**: 来自搜索摘要;与多份 2025 资料一致(Observation 框架 @Observable macro,Swift 5.9 引入,pull-based 精确失效)。这是纯 MV 路线的技术基座。

### 02.3 The Composable Architecture: How Architectural Design Decisions Influence Performance — swiftyplace

- **声称**: TCA(The Composable Architecture)适用于跨多屏 state/行为、需严肃测试与可扩展性的场景;但对小型自包含屏幕官方 FAQ 建议回退到 ObservableObject/plain State/Binding。它对大型 macOS app 有明确性能代价:每个视图(无论多深)都收到整个 app state struct(设计使然),与 SwiftUI 高效更新机制冲突——Swift Heroes 2023 演示 Arc 浏览器(macOS)中处理仅 5 行文本耗费约 9 秒 CPU 时间。学习曲线陡峭(reducer/store/scoping)。
- **来源**: <https://www.swiftyplace.com/blog/the-composable-architecture-performance> (仅搜索摘要, 采集日 2026-07-08)
- **备注**: 搜索摘要;pointfreeco 官方 FAQ(pointfree.co/blog/posts/141)佐证「小屏幕用 plain State」。对 MAformac 这类 solo demo,TCA 属过度工程化。

### 02.4 MV vs MVVM in SwiftUI (2025): Which Architecture Should You Use? — DEV Community

- **声称**: MV vs MVVM 的 2025 争论核心:SwiftUI 的 struct View + @Observable macro 削弱了独立 ViewModel 的必要性,趋势从「分层分离」转向「单向数据流」;但 MVVM 阵营认为其数据绑定与 SwiftUI 契合,仍是许多团队默认。结论是无单一官方答案,按 app 复杂度/团队经验/项目需求选。
- **来源**: <https://dev.to/yossabourne/mv-vs-mvvm-in-swiftui-2025-which-architecture-should-you-use-video-26nb> (仅搜索摘要, 采集日 2026-07-08)
- **备注**: 搜索摘要;与 Apple Developer Forums『Stop using MVVM for SwiftUI』(thread/699003)长期争论呼应。

### 02.5 #Preview SwiftUI Views using Macros — SwiftLee

- **声称**: Xcode 15 + Swift 5.9 起用 #Preview 宏取代 PreviewProvider 协议(不再需要 static computed property),单行即可在视图声明旁添加预览,可放多个 #Preview,并支持为 UIKit/AppKit 视图定义预览,还有可选 traits 参数(如朝向)。到 Xcode 26 时预览已从「nice-to-have」变为「核心开发工作流」,大幅缩短 UI 迭代反馈时间。
- **来源**: <https://www.avanderlee.com/xcode/preview-swiftui-uikit-appkit-views/> (仅搜索摘要, 采集日 2026-07-08)
- **备注**: 搜索摘要;多源一致(AppCoda、Swift with Majid、Medium『Mastering #Previews in Xcode 26』)。

### 02.6 @Previewable: Dynamic SwiftUI Previews Made Easy — SwiftLee

- **声称**: Xcode 16 引入 @Previewable 宏,允许在 #Preview 块内内联使用 @State 等动态属性,无需再包一个容器 struct。用法如 `#Preview{ @Previewable @State var isOn=false; Toggle("...",isOn:$isOn) }`。它内部生成隐藏 wrapper 视图(__P_Previewable_Transform_Wrapper),标记的声明成为 wrapper 属性、其余语句构成 body。好处是消除样板、支持交互式预览、状态直接 scope 到预览块。
- **来源**: <https://www.avanderlee.com/swiftui/previewable-macro-usage-in-previews/> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: 已 WebFetch 确认;文章未涉及 mock data 注入的具体指引(诚实标注)。

### 02.7 SwiftUI Design Tokens & Theming System (Production-Scale) — DEV Community

- **声称**: 生产级 SwiftUI design token/主题系统采用三层结构:①primitive/foundational(Spacing 枚举 xs/sm/md/lg/xl、Radius sm/md/lg/card 等原始数值)②semantic(AppColor 意图命名如 background/surface/accent/textPrimary,AppFont 角色化如 title/headline/body/caption,Motion 动效时长,Elevation 阴影/材质)③component 级直接经 modifier 应用(.padding(Spacing.md)、.font(AppFont.title))。语义色映射到 Asset Catalog 的 Color("Background"),把明暗/无障碍交给 SwiftUI 原生系统;主题经 .environment(\.theme, currentTheme) 注入,支持 ThemeKind(light/dark/highContrast)动态切换与预览期跨主题测试。
- **来源**: <https://dev.to/sebastienlato/swiftui-design-tokens-theming-system-production-scale-b16> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: 已 WebFetch 确认;核心原则『语义命名优先于视觉数值』便于换肤与集中一致性。

### 02.8 SwiftUI Design System Considerations: Semantic Colors — magnuskahr

- **声称**: Design token 的语义色命名应基于角色而非 RGB(如 .text(.primary)、.background(.secondary)、.shadow(.strong));token 分层为 global(无语义常量友好名,如 grey64=#A3A3A3)→alias(赋语义、由 global 派生)→control(用 alias 描述控件如何绘制)。Color 初始化器可按当前外观解析明暗值,一个属性承载明暗两套值。ColorTokensKit 等库用 OKLCH/CIELab LCH 感知均匀色空间,选一个 hue 即可自动生成整套调色板。
- **来源**: <https://www.magnuskahr.dk/posts/2025/06/swiftui-design-system-considerations-semantic-colors/> (仅搜索摘要, 采集日 2026-07-08)
- **备注**: 搜索摘要;global/alias/control 三层命名与微软 fluentui-apple 的 Design Tokens wiki 口径一致(github.com/metasidd/ColorTokensKit-Swift 提供 OKLCH 实现)。

### 02.9 Scenes types in a SwiftUI Mac app — Nil Coalescing

- **声称**: SwiftUI macOS scene 体系可组合:WindowGroup(多实例窗口,支持 tab 化与标准窗口命令,每窗口独立 State)、Window(单一唯一窗口,作为唯一主 scene 时关闭即退出 app,不支持自动分组/tab,适合工具面板)、Settings(自动启用 app 的 Settings 菜单项并接管 ⌘, ,配 @AppStorage)、MenuBarExtra(macOS-only,label 常驻系统菜单栏,内容以菜单或窗口锚定,支持 .menuBarExtraStyle(.window))、DocumentGroup(文档型 app,配 FileDocument,集成最近文件/新建菜单)。可在一个 app 内 WindowGroup+Settings+MenuBarExtra 组合。
- **来源**: <https://nilcoalescing.com/blog/ScenesTypesInASwiftUIMacApp/> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: 已 WebFetch 确认;对 MAformac 演示助手,MenuBarExtra 常驻 + 主 WindowGroup 是自然结构。

### 02.10 Showing Settings from macOS Menu Bar Items: A 5-Hour Journey — Peter Steinberger

- **声称**: macOS 特有实操坑:SettingsLink 在 MenuBarExtra 中不可靠工作,官方文档未提示此限制(它假定 app 已 active 且有正确窗口管理上下文)——从菜单栏项打开 Settings 是知名难点(Peter Steinberger 记录『5 小时之旅』)。
- **来源**: <https://steipete.me/posts/2025/showing-settings-from-macos-menu-bar-items> (仅搜索摘要, 采集日 2026-07-08)
- **备注**: 搜索摘要确认限制;若 MAformac 用菜单栏入口设置面板需预留此坑的 workaround 时间。

### 02.11 SwiftUI for Mac 2025 — TrozWare

- **声称**: SwiftUI on macOS 2025 的真实能力边界(TrozWare 亲测):富文本编辑已可用 SwiftUI(TextEditor+AttributedString,AttributedString 是 Codable 便于 JSON 持久化)从『必须用 AppKit』移出;List 已能流畅处理 1 万条(绘制/滚动/选择 snappy,实用上限约 2 万,5 万条渲染需数分钟);原生 WebView 无需再包 NSViewRepresentable+WKWebView。仍弱:TextEditor 无编程式换字体、拼写检查边打字边查不可靠。Swift 6 默认 MainActor 隔离已自然。
- **来源**: <https://troz.net/post/2025/swiftui-mac-2025/> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: 已 WebFetch 确认;honest tradeoffs,直接指导 macOS 演示 app 何处用 SwiftUI、何处仍需 AppKit。

### 02.12 Build a SwiftUI app with the new design — WWDC25 Session 323

- **声称**: macOS 26 Tahoe 的 Liquid Glass 采用极低成本:用 Xcode 26 SDK 重编译即自动获得增强,标准控件(按钮/滑块/菜单)自动适配。自定义视图用 .glassEffect()(默认 capsule 形,可 .glassEffect(in:.rect(cornerRadius:16))、.tint 仅表达含义、.interactive());多个玻璃元素必须包进 GlassEffectContainer(玻璃无法采样另一块玻璃),并用 glassEffectID+@Namespace 实现流动形变;新增 .buttonStyle(.glass)/.glassProminent;背景延展用 .backgroundExtensionEffect()。无障碍上必须用 Reduce Transparency 开启测试——若开启后 app 崩坏,那就不是 Liquid Glass 而只是装饰。
- **来源**: <https://developer.apple.com/videos/play/wwdc2025/323/> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: 已 WebFetch 确认,含大量具体 API(ToolbarSpacer、tabViewBottomAccessory、matchedTransitionSource/navigationTransition(.zoom())、.containerConcentric 圆角同心、.controlSize(.small) 高密度)。

### 02.13 SwiftUI for Mac 2025 — TrozWare

- **声称**: Liquid Glass 采用的务实批评与 macOS 细节:开发者对『内容在工具栏/标题栏后模糊』持保留态度,认为常看起来像布局错误(TrozWare);macOS 上 mini/small/medium 按钮保留圆角矩形以维持横向密度,控件默认略高以增大点击目标,菜单图标现在也在 macOS 显示(此前 macOS 无图标),高密度布局(inspector/popover)用 .controlSize(.small),滚动边缘效果用 .scrollEdgeEffectStyle(.hard)。
- **来源**: <https://troz.net/post/2025/swiftui-mac-2025/> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: 批评性观点与 WWDC25 323 的 macOS 控件细节结合;提醒 MAformac 别为玻璃而玻璃,现场惊艳要克制。

### 02.14 How I Built Glassmorphism on macOS 14 While Apple Requires macOS 26 — Klarity Blog

- **声称**: 在 macOS 26 尚未普及时,可在旧系统(如 macOS 14)手搓 glassmorphism 近似效果以兼容,但 Apple 真正的 Liquid Glass API(glassEffect 等)要求 macOS 26/Tahoe——即真材质的折射反射能力与向后兼容的手写模糊有本质差异。
- **来源**: <https://www.klaritydisk.com/blog/building-liquid-glass-ui-macos> (仅搜索摘要, 采集日 2026-07-08)
- **备注**: 搜索摘要;对部署目标(最低 macOS 版本)决策有参考——若 MAformac 需支持旧 macOS 演示机,Liquid Glass 需降级方案。

## 引用核验(独立核验员)

> agent `a7e4f25c2bd15d91d` | verdict: **MINOR_ISSUES**

- ✅ <https://dimillian.medium.com/swiftui-in-2025-forget-mvvm-262ff2bbd2ed> — 可达,内容强支持。标题《SwiftUI in 2025: Forget MVVM》正确。文中明确「You don't need ViewModels in SwiftUI. You never did. You never will.」,把 MVVM 归为 UIKit baggage / MVVM Trap,并援引 WWDC19『Data Flow Through SwiftUI』。作者 Thomas Ricouard(Ice Cubes)身份属实。仅『Apple 本质是去掉 C 的 MVC / 从未提供推荐架构』这句精确措辞未在抓取内容中逐字出现,但整体主张一致,不影响支持度。
- ✅ <https://zoewave.medium.com/new-swiftui-state-management-3a6c9b737724> — 可达,内容全面支持。标题《iOS 17+ SwiftUI State Management: An Updated Comprehensive Guide (2025)》by YLabZ 正确。系统覆盖 ObservableObject→@Observable(去 @Published)、@StateObject→@State、只读子视图去 wrapper、@Bindable 双向绑定、@EnvironmentObject→@Environment(Type.self)+.environment(obj),并讨论 Environment 用于跨切面共享(app settings/session/主题)。声称与页面吻合。
- ✅ <https://www.swiftyplace.com/blog/the-composable-architecture-performance> — 可达,主体内容支持但有一处子声称对不上。标题正确(作者 Karin Prater,2025-03-24)。确认:引用 Krzysztof Zabłocki 的 Swift Heroes 2023 talk『Arc 浏览器(macOS)处理 5 行文本耗 9 秒 CPU』;『每个视图无论多深都收到整个 app state struct,by design』;reducer/store/scoping 复杂度。但声称中『官方 FAQ 建议小型自包含屏幕回退到 ObservableObject/plain State/Binding』一句,页面并未提及该 FAQ 内容——此子声称在本文中无出处(该点属 TCA 官方文档,非本文)。
- ✅ <https://dev.to/yossabourne/mv-vs-mvvm-in-swiftui-2025-which-architecture-should-you-use-video-26nb> — 可达,标题《MV vs MVVM in SwiftUI (2025): Which Architecture Should You Use? [Video]》正确,主题对得上(MV vs MVVM 2025 之争、模式选择)。但这是视频贴,页面正文仅为提纲/teaser(What's in an iOS app / MV pattern / MVVM pattern / Choosing between MV and MVVM),声称中关于 @Observable 削弱 ViewModel、单向数据流趋势、无单一官方答案等细节主要在视频内,抓取的文字页面无法逐条印证——主题成立,具体论点不可从页面文字复核。

无 dead_or_fabricated。

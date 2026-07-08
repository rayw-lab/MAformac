# lens01 — Apple 官方视角:HIG / Liquid Glass / Design Resources / WWDC

> 一手结构化 finder 档 | workflow `wf_41662345-ab4` agent `a4e896065ed42e9bf` | 2026-07-08 | opus/medium
> 角度原文: Apple 官方视角:macOS HIG 最新结构与核心原则 + Liquid Glass 设计语言(适用范围/迁移) + Apple Design Resources 模板 + 2024-2026 WWDC 中 macOS App 设计/SwiftUI 关键 session 要点

## 摘要

Apple 于 2025 年 6 月 WWDC25 发布 Liquid Glass,是覆盖 iOS 26 / iPadOS 26 / macOS Tahoe 26 / watchOS 26 / tvOS 26 五平台的统一设计语言,也是 Apple 迄今最大规模的软件设计更新。核心思想:Liquid Glass 是一层"浮在内容之上的功能性导航层",用半透明动态材质带来结构与层级,但不抢内容焦点。官方最重要的落地纪律是"用得克制"——只用在导航层,不要放进内容层,不要 glass 叠 glass。新设计系统的三大原则被 Apple 表述为 Hierarchy(层级)、Harmony(和谐/与硬件同心圆)、Consistency(一致/跨窗口尺寸自适应),仍建立在 HIG 长期的 Clarity/Deference/Depth 之上。macOS 侧有具体变化:控件尺寸新增 X-Large、Large 改胶囊形、Mini/Small/Medium 保留圆角矩形用于高密度检查器面板;工具栏浮于内容之上并按功能自动分组;系统色与排版为配合 Liquid Glass 做了调整(更粗、左对齐)。工程侧,SwiftUI 提供 glassEffect / GlassEffectContainer / glassEffectID / ToolbarSpacer 等 API,AppKit 提供 NSGlassEffectView / NSGlassEffectContainerView;标准组件自动获得 Liquid Glass 与无障碍适配(Reduce Transparency / Increased Contrast / Reduce Motion)。Apple Design Resources 已更新 Figma/Sketch 模板(2026-06 又发布 macOS 27 版含 macOS Dark Mode),配套 Icon Composer 制作最多 4 层的 Liquid Glass 分层图标。对 MAformac 这类纯端侧 macOS SwiftUI 演示助手,官方结论是:优先用标准组件让系统自动上 Liquid Glass,把 glass 留给导航/工具层,内容卡片保持清晰,并务必在打开无障碍开关下验证可读性。

## Findings

### 01.1 Apple introduces a delightful and elegant new software design — Apple Newsroom

- **声称**: Liquid Glass 是 Apple 在 2025-06-09 WWDC25 发布的统一设计语言,覆盖 iOS 26 / iPadOS 26 / macOS Tahoe 26 / watchOS 26 / tvOS 26 五个平台,是 Apple 迄今最大规模的软件设计更新,作用于 controls、navigation、app icons、widgets 等。
- **来源**: <https://www.apple.com/newsroom/2025/06/apple-introduces-a-delightful-and-elegant-new-software-design/> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: 官方 newsroom。macOS Tahoe 26 特有:透明菜单栏、可自定义桌面/Dock、light/dark/tinted/clear 多种外观。

### 01.2 Meet Liquid Glass — WWDC25 Session 219

- **声称**: 官方核心纪律:Liquid Glass 最好只保留给'浮在内容之上的导航层(navigation layer)',不要到处用;不要把内容层做成 Liquid Glass(会与其他元素争抢、搞乱层级),也不要 glass 叠 glass(界面会显得杂乱混乱)。
- **来源**: <https://developer.apple.com/videos/play/wwdc2025/219/> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: 原文:'it is best reserved for the navigation layer that floats above the content of your app';明确点名 content layer 与 glass-on-glass 反例。

### 01.3 Meet Liquid Glass — WWDC25 Session 219

- **声称**: Liquid Glass 有两种变体且绝不可混用:Regular(最通用、自适应、任何尺寸/任何内容上都保证可读,默认首选)与 Clear(永久更透明、无自适应、需加 dimming layer,仅当'覆盖媒体丰富内容 + 内容层不受变暗影响 + 上方元素粗且亮'三条件同时满足时才用)。
- **来源**: <https://developer.apple.com/videos/play/wwdc2025/219/> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: 原文 'They should never be mixed'。对 demo:默认用 Regular 即可。

### 01.4 Liquid Glass: Redefining design through Hierarchy, Harmony and Consistency — Create with Swift

- **声称**: 新设计系统的三大原则被 Apple 表述为 Hierarchy(控件抬升并衬托其下内容)、Harmony(与硬件的同心圆设计对齐,界面与设备融为一体)、Consistency(采用平台惯例,随窗口尺寸/显示器持续自适应);仍建立在 HIG 长期的 Clarity/Deference/Depth 之上。
- **来源**: <https://www.createwithswift.com/liquid-glass-redefining-design-through-hierarchy-harmony-and-consistency/> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: 三原则引自 Apple HIG 新页面;Clarity/Deference/Depth 为 HIG 长期基础原则(见 designing-for-macos)。

### 01.5 Get to know the new design system — WWDC25 Session 356

- **声称**: macOS 控件尺寸变化:Mini/Small/Medium 继续用圆角矩形(适合检查器面板等高密度紧凑布局),Large 改为胶囊形,并新增 X-Large 尺寸利用 Liquid Glass 在更宽敞区域提供强调;组合使用以在复杂桌面布局中建立层级与平衡。
- **来源**: <https://developer.apple.com/videos/play/wwdc2025/356/> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: macOS 专属规则,对 MAformac 桌面卡片/工具区选控件尺寸直接相关。

### 01.6 Get to know the new design system — WWDC25 Session 356

- **声称**: 同心圆(concentric)设计:系统用三种形状构建嵌套布局——fixed(固定半径)、capsule(半径=容器高度一半)、concentric(半径=父容器半径减内边距);玻璃控件应完美嵌入窗口圆角,全程保持同心。排版改为更粗、左对齐以提升 alert/onboarding 可读性;系统色跨 Light/Dark/Increased Contrast 微调以配合 Liquid Glass 并改善色相区分。
- **来源**: <https://developer.apple.com/videos/play/wwdc2025/356/> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: concentric 是本次设计核心几何原则;工具栏项按功能与频率分组、不要把符号与文字混为一组。

### 01.7 Build a SwiftUI app with the new design — WWDC25 Session 323 (WWDCNotes)

- **声称**: SwiftUI 采用 Liquid Glass 的关键 API:自定义视图用 .glassEffect()(默认胶囊形,支持 .interactive() 与 .tint());多个玻璃元素必须包进 GlassEffectContainer(玻璃无法采样另一块玻璃,不同容器会导致视觉不一致);配合 @Namespace 用 .glassEffectID() 实现形变过渡;工具栏项自动上玻璃并分组,用 ToolbarSpacer(.fixed/.flexible) 分隔。tint 仅用于传达含义,不要纯装饰。
- **来源**: <https://wwdcnotes.com/documentation/wwdc25-323-build-a-swiftui-app-with-the-new-design/> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: 第三方转录(WWDCNotes),但 API 名与 Apple 官方一致。含 tabViewBottomAccessory / .backgroundExtensionEffect / .scrollEdgeEffectStyle。

### 01.8 Build an AppKit app with the new design — WWDC25 Session 310 (WWDCNotes)

- **声称**: macOS/AppKit 采用 Liquid Glass:用 NSGlassEffectView(设 contentView 让系统自动保证可读,可调 cornerRadius/tintColor),多块相邻玻璃用 NSGlassEffectContainerView 分组以避免视觉伪影并提升性能;工具栏与侧边栏改为浮在内容之上的玻璃面板,旧的 NSVisualEffectView 侧栏可移除,必要时用 NSBackgroundExtensionView 让内容延伸到边缘。
- **来源**: <https://wwdcnotes.com/documentation/wwdc25-310-build-an-appkit-app-with-the-new-design/> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: MAformac 若走纯 SwiftUI 可不碰这些,但若需 AppKit 桥接工具栏时相关。

### 01.9 Adopting Liquid Glass — Apple Developer Documentation

- **声称**: Liquid Glass 的无障碍适配对标准组件是自动的:Reduce Transparency 会让玻璃更磨砂、遮住更多背景;Increased Contrast 让元素基本变纯黑/白并加对比边框;Reduce Motion 降低特效强度并禁用弹性属性。Apple 与独立审计共识:模糊后文本/背景对比应达 4.5:1,关闭透明时提示/控件需在纯色背景上仍可见——发布前必须在这些开关下测试。
- **来源**: <https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass> (仅搜索摘要, 采集日 2026-07-08)
- **备注**: Apple 官方页为 SPA 未能直接抓正文;无障碍开关行为由 Session 219 确认(已 fetch),4.5:1 数字来自搜索摘要引第三方审计,需注意非 Apple 原话。

### 01.10 Design kits for iOS, iPadOS, and macOS 27 are here — Apple Developer News (2026-06-23)

- **声称**: Apple Design Resources 已为新设计更新 Figma/Sketch 模板;2026-06-23 又发布 iOS/iPadOS/macOS 27 版设计套件,含 Liquid Glass 更新、组件与状态扩展、命名向代码对齐、更好的缩放,并为 macOS 新增 Dark Mode。官方模板下载入口:developer.apple.com/design/resources。
- **来源**: <https://developer.apple.com/news/?id=e2lxw9l1> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: 说明 Apple 每年随新系统更新官方 Figma/Sketch 库;macOS 设计模板要用最新版。

### 01.11 Icon Composer — Apple Developer

- **声称**: Icon Composer 是 Apple 新工具,从单一设计生成 iPhone/iPad/Mac/Apple Watch 通用的分层 Liquid Glass 图标:导入图层后可调 specular highlights、refraction、translucency、shadows;默认 1 层,最多 4 层(Apple 认为这是图标视觉复杂度的合理上界);外观模式重命名为 default/dark/mono;系统自动上圆角矩形遮罩,推到角落的元素有被裁风险。
- **来源**: <https://developer.apple.com/icon-composer/> (仅搜索摘要, 采集日 2026-07-08)
- **备注**: 细节交叉自 WWDC25 Session 361 与 newsroom(已 fetch);对 MAformac 若要做演示 app 图标相关。

### 01.12 Designing for macOS — Apple Human Interface Guidelines

- **声称**: macOS 平台设计取向(HIG designing-for-macOS):Mac 强调指针+键盘、允许高密度信息展示、应充分使用菜单栏/工具栏/键盘快捷键、窗口可精确缩放与全屏;工具栏应去掉自定义背景色,靠布局与分组表达层级而非装饰,按功能与使用频率组织栏项,用 tint 让主操作突出。
- **来源**: <https://developer.apple.com/design/human-interface-guidelines/designing-for-macos> (仅搜索摘要, 采集日 2026-07-08)
- **备注**: HIG 长期 macOS 原则,搜索摘要确认;对 MAformac 桌面演示界面的菜单/工具栏/快捷键布局有指导意义。

### 01.13 Get to know the new design system — WWDC25 Session 356

- **声称**: 内容感知(content-aware)是新系统的功能取向:界面随内容与用户操作实时调整,导航与控件在需要时支持交互、不需要时保持不显眼(unobtrusive);相关操作被智能分组以形成更引导式的体验;材质与动效服务于功能(表达深度、反馈、上下文变化)而非装饰。Action Sheet 现在从触发操作本身弹出而非固定屏幕底部。
- **来源**: <https://developer.apple.com/videos/play/wwdc2025/356/> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: 原句 'support interaction where needed, and remain unobtrusive when it is not';对 demo 的即时反应/不抢焦点诉求契合。

## 引用核验(独立核验员)

> agent `ad8d232a52ce0ec15` | verdict: **CLEAN**

- ✅ <https://www.apple.com/newsroom/2025/06/apple-introduces-a-delightful-and-elegant-new-software-design/> — 可达。Apple Newsroom 原文确证:Liquid Glass 是 WWDC25 发布的统一新设计,首次跨 iOS 26/iPadOS 26/macOS Tahoe 26/watchOS 26/tvOS 26 五平台;Alan Dye 原话 'This is our broadest software design update ever';作用于 controls、navigation、app icons、widgets。声称完全成立。
- ✅ <https://developer.apple.com/videos/play/wwdc2025/219/> — 可达。'Meet Liquid Glass' Session 219 原文确证:'best reserved for the navigation layer that floats above the content';反例 tableview 若做成 Liquid Glass 会 compete/muddy hierarchy,应留在 content layer;'always avoid glass on glass'。纪律声称完全成立。
- ✅ <https://developer.apple.com/videos/play/wwdc2025/219/> — 可达(同 Session 219)。原文确证两变体 Regular 与 Clear 'should never be mixed';Regular 最通用默认;Clear 永久更透明、无自适应、需 dimming layer,且仅当三条件(over media-rich content + 内容层不受 dimming 负面影响 + 上方元素 bold and bright)同时满足才用。声称完全成立。
- ✅ <https://www.createwithswift.com/liquid-glass-redefining-design-through-hierarchy-harmony-and-consistency/> — 可达。文章确证三原则 Hierarchy(控件抬升衬托其下内容)、Harmony(与硬件同心圆设计对齐)、Consistency(采用平台惯例、随窗口尺寸/显示器持续自适应),并明确追溯建立在旧 HIG 的 clarity/deference/depth 之上。声称成立。

无 dead_or_fabricated。

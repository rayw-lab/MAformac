# macOS App 前端 UIUE 开发方法论调研（归档包总入口）

> **归档元数据**:2026-07-08 | workflow `wf_41662345-ab4`(14 agent: 7 finder + 6 引用核验 + 1 综合官,全部 opus/medium)| 669k subagent tokens | 0 agent 失败
> **三层一手性**:本 README = 二手派生(综合官);`lens01–07` = 一手结构化 finder 档(每条 finding 带 source URL + 采集日);`transcripts/` = 最一手过程(jsonl,脱敏 grep `raw/|禁外传|/Downloads/` 零命中,可入仓)。
> **引用纪律**:每路联网 finder 配独立核验员 WebFetch 实访 top 引用;下文已剔除 3 处 dead_or_fabricated(明细见 §核验矩阵 + 各 lens 尾部)。

## 核验矩阵(lens ↔ verdict)

| lens | 角度 | findings | 核验 verdict | 剔除项 |
|---|---|---|---|---|
| [lens01](lens01-apple-official.md) | Apple 官方:HIG / Liquid Glass / WWDC | 13 | CLEAN | — |
| [lens02](lens02-swiftui-arch.md) | SwiftUI 工程:MV vs MVVM vs TCA / Previews / tokens | 14 | MINOR_ISSUES(无造假) | — |
| [lens03](lens03-design-process.md) | 设计流程:design system / Figma handoff / 流程裁剪 | 13 | MINOR_ISSUES | 🔴 UXPin 指南 34%/47%/3.5月 统计页面查无出处 |
| [lens04](lens04-usability-review.md) | 可用性评审:Nielsen / macOS 维度 / 可访问性 | 15 | MINOR_ISSUES | 🔴 发现率百分比误挂 severity 页;🔴 HIG drag-and-drop 旧路径 302 失效 |
| [lens05](lens05-benchmark-apps.md) | 业界标杆:Raycast/Linear/Things/Sketch 原生感 | 14 | CLEAN | — |
| [lens06](lens06-ai-assisted.md) | AI 辅助 UI:截图闭环 / 幻觉 API / 风格漂移 | 13 | CLEAN | — |
| [lens07](lens07-local-baseline.md) | 本地基线(不联网):仓内资产 + 已锁决策 + 缺口 | 12 | 本地 file:line 可直接复核 | — |

## 对 MAformac 适配建议的 P0/P1/P2 分级(综合官 8 条建议 → 优先级)

| 级 | 建议(详见下文 §对 MAformac 的适配建议) | 依据 |
|---|---|---|
| **P0** | ③ Liquid Glass 只给三处导航层 + Regular 变体 + 三无障碍开关走查(接 U44) | 低成本惊艳 × 投影风险最大 |
| **P0** | ⑥ UI 生成走开发期 Xcode agentic(RenderPreview MCP + 编译门),不交端侧 Qwen3-1.7B | 小模型幻觉 API 风险,与项目分工铁律一致 |
| **P0** | ⑦ Nielsen 0–4 severity + macOS 专属维度 + 可访问性门 → 落成 Line D 验收门 | roadmap Line D 正需要验收维度表 |
| **P1** | ① 纯 MV 架构(`@Observable`+`@Environment`),拒 TCA | 已有代码基本同向,防漂移 |
| **P1** | ② tokens.md 落成 enum SSOT + 冻结只读(防 AI 风格漂移"the file is the floor") | 现役债 ContentView 二值压缩待补 |
| **P1** | ⑤ 惊艳集中打磨开场 + 1–2 招牌微交互,不平摊 | 北极星 5 分钟炸场 |
| **P2** | ④ 感知性能范式(动画只动 transform/opacity、0.1/0.25/0.35s、非对称节奏) | mock 本就 local-first,增量小 |
| **P2** | ⑧ 外部缺口三块的补法(版本坑清单/交互语义转换/炸场样例) | 待 D1 UIUE 专场消化 |

## Grill 弹药(待磊哥/主刀拍,本报告不自拍)

1. **aesthetic-first 5 Gate 引用悬空**:五门定义在仓内未见独立成文 → 补立或明确出处。
2. **Liquid Glass 采用度**:三处导航层是否本轮就上,还是 Line D 高保真样张后再上?(TrozWare/AppleInsider 对比度/卡顿争议 vs 低成本惊艳)
3. **snapshot 门范围**:swift-snapshot-testing(SSIM/感知 diff)纳入 `swift test` 门的范围——只 7 态视觉,还是全组件?(接 U17/U32–U37)
4. **部署目标**:真 Liquid Glass API 要求 macOS 26;演示机系统版本需确认,否则只能手搓近似。

---

# 以下为综合官报告全文(未删改)

# macOS App 前端 UIUE 开发方法论调研

> 综合官报告 · 2026-07-08 · 7 路调研收口(6 路联网 + 1 路本地基线)
> 引用纪律:已剔除被核验标记为 dead_or_fabricated 的 URL 与数字(uxpin `create-design-system-guide` 的 34%/47%/3.5 月统计、Nielsen severity 页被误挂的发现率百分比、已 302 失效的 Apple HIG drag-and-drop 旧路径)。

## TL;DR(≤10 行)

1. **原生感的大头是"行为对"不是"外观像"**——Raycast 明言自己是"用 web 做 UI 的原生应用",工程重心在消除 web 约定泄露(无 `cursor:pointer`、无网页式 hover 高亮、popover 走原生窗口)([Raycast](https://www.raycast.com/blog/a-technical-deep-dive-into-the-new-raycast))。
2. **架构去 ViewModel 化**:社区(Ricouard)主张纯 MV + `@Observable` + `@Environment`,Apple 从未推荐 MVVM;TCA 对 solo demo 属过度工程化([Forget MVVM](https://dimillian.medium.com/swiftui-in-2025-forget-mvvm-262ff2bbd2ed))。
3. **Liquid Glass(macOS 26 Tahoe)只用于导航层**,禁 glass-on-glass、文字落实心层、Reduce Transparency 下必测——是低成本惊艳,也是可访问性风险点([WWDC25 Session 219](https://developer.apple.com/videos/play/wwdc2025/219/))。
4. **感知性能可设计**:Linear 用 local-first + optimistic update 消灭 spinner,动画只动 transform/opacity,时长 0.1/0.25/0.35s,出现即时/消失约 150ms 非对称([performance.dev](https://performance.dev/how-is-linear-so-fast-a-technical-breakdown))。
5. **Design token 三层(global→alias/semantic→component)是 SSOT**,SwiftUI 落地 = enum + Asset Catalog + `.environment(\.theme)` + Preview 验证([UXPin](https://www.uxpin.com/studio/blog/what-are-design-tokens/) / [DEV](https://dev.to/sebastienlato/swiftui-design-tokens-theming-system-production-scale-b16))。
6. **AI 辅助的核心机制是"截图对照闭环 + 编译门"**,Xcode 26.3 已把它产品化(RenderPreview MCP + 20 工具),让 agent 亲眼看 UI 迭代([Apple](https://www.apple.com/newsroom/2026/02/xcode-26-point-3-unlocks-the-power-of-agentic-coding/))。
7. **AI 两大坑=幻觉 API + 风格漂移**,对策是机械门(编译 fail-closed + 冻结 token SSOT + 截图对照),不靠 prompt 自律([Superdesign](https://superdesign.dev/blog/ai-design-system-drift))。
8. **评审用 Nielsen 十启发式 + 0–4 severity(≥3 人独立打分取均值)** + macOS 专属维度(菜单栏/快捷键/hover/键盘全通路)+ VoiceOver + WCAG 对比度门([NN/g](https://www.nngroup.com/articles/ten-usability-heuristics/))。
9. **本地已有厚资产**:Codex `build-macos-apps` 5 个 UI skill + 项目 240+ 条 UIUE grill 决策;外部缺口=macOS 26 版本坑清单 + iPhone→macOS 交互语义转换范例 + 桌面级炸场样例。

---

## 方法论全景

### 一、设计原则(design principles)

**长期底盘不变**。Apple HIG 的 Clarity / Deference / Depth 与 Nielsen 十大可用性启发式仍是通用底座;后者自 1994 年起 30 年基本未变,官方主张跨桌面/移动/Web 通用,对 5 分钟炸场演示最相关的是①系统状态可见(反应快看得见)、⑧美学与极简、⑨错误恢复(不崩/优雅兜底)([NN/g 十启发式](https://www.nngroup.com/articles/ten-usability-heuristics/))。

**macOS 26 Tahoe 新增 Liquid Glass 设计语言**(WWDC25 2025-06 发布,首次统一 iOS 26/iPadOS 26/macOS Tahoe 26/watchOS 26/tvOS 26 五平台)([Apple Newsroom](https://www.apple.com/newsroom/2025/06/apple-introduces-a-delightful-and-elegant-new-software-design/))。三原则:
- **Hierarchy(层级)**:控件抬升并衬托其下内容,靠间距/尺寸/自适应而非纯颜色特效;
- **Harmony(和谐)**:与硬件同心圆(concentric)几何对齐——玻璃控件半径 = 父容器半径减内边距,完美嵌入窗口圆角;
- **Consistency(一致)**:遵循平台惯例并随窗口尺寸/显示器持续自适应([Create with Swift](https://www.createwithswift.com/liquid-glass-redefining-design-through-hierarchy-harmony-and-consistency/) / [WWDC25 Session 356](https://developer.apple.com/videos/play/wwdc2025/356/))。

**用玻璃的铁律(Apple 官方 + 社区一致)**:
- 只保留给"浮在内容之上的导航层"(toolbar/sidebar/菜单栏/sheet/popover),**绝不给内容层(list/card/滚动内容)或全屏背景加玻璃**;
- **永远避免 glass-on-glass 堆叠**;
- 两变体 **Regular(默认,任何尺寸/内容上保证可读)与 Clear(永久更透明、需 dimming、仅富媒体之上)绝不混用**;
- **tint 只承载语义(主操作),不做装饰**;文字永远落在实心层([WWDC25 Session 219](https://developer.apple.com/videos/play/wwdc2025/219/) / [DEV Best Practices](https://dev.to/diskcleankit/liquid-glass-in-swift-official-best-practices-for-ios-26-macos-tahoe-1coo))。

**macOS 平台取向**:为 power user 设计(键盘快捷键+高效路径)、指针+键盘驱动、允许高密度信息、充分使用菜单栏/工具栏、工具栏去掉自定义背景色靠布局分组表达层级([Designing for macOS HIG](https://developer.apple.com/design/human-interface-guidelines/designing-for-macos))。

> ⚠️ **冲突并列(惊艳 vs 保守)**:Liquid Glass 是低成本惊艳来源,但也有务实批评——TrozWare 认为"内容在工具栏/标题栏后模糊常看起来像布局错误",macOS Tahoe 桌面大屏/非触控输入适配不如 iOS,遭遇对比度与卡顿争议([TrozWare](https://troz.net/post/2025/swiftui-mac-2025/) / [AppleInsider](https://appleinsider.com/articles/25/06/11/liquid-glass-is-more-than-skin-deep-on-macos-tahoe))。结论:现场投影场景应保守,别为玻璃而玻璃。

### 二、设计流程(design process)

**Design system 从零建的公认序**(7 步,solo 可省"团队认同"):①盘存/审计现有 UI 记录不一致 →②(团队认同)→③定色板(附 HEX/RGBA/HSL 与用法)→④定排版(字号/字重/行高/间距规则)→⑤汇总图形资产 →⑥建 pattern 库(带代码片段+文档)→⑦集中沉淀便于原型与 handoff;**基础层(色/字/间距)先于 pattern 库**([UXPin 7 步](https://www.uxpin.com/studio/blog/build-a-design-system-from-scratch-in-7-steps/))。关键定性:**design system 是持续迭代物不是一次性交付,pattern 库要一个一个建、无"完成态"**([UXPin 指南](https://www.uxpin.com/create-design-system-guide/))。

**Token 化 = SSOT**:业界三层 global(原始 hex/px)→alias/semantic(意图命名如 color-primary)→component(组件作用域);token 是"命名的语义值,表达意图而非实现"([UXPin tokens](https://www.uxpin.com/studio/blog/what-are-design-tokens/))。

**Figma→SwiftUI handoff 两条路**:
- **AI 生成(Builder Visual Copilot/Locofy/Codia/Anima)**:只加速"布局搭建"(约占 App 开发 10–20%),**Auto Layout 是决定导入质量的单一最关键动作**;需预留 20–50% 人工精修([Builder.io](https://www.builder.io/blog/figma-to-swiftui) / [7 Tools Compared](https://theswiftk.it.com/blog/figma-to-swiftui-tools-compared-2026))。
- **Code Connect 反向**:用 `@FigmaString`/`@FigmaBoolean`/`@FigmaEnum` 把真实 SwiftUI 组件挂到 Figma 组件,Dev Mode 显示活代码——代码是真实源([Figma Docs](https://developers.figma.com/docs/code-connect/swiftui/))。

> ⚠️ **冲突并列(要不要 Figma 中间层)**:越来越多 solo 主张**跳过 Figma、直接在 SwiftUI 里做可交互原型**(灌假数据、上真机/TestFlight),因为复杂交互(横向滚动列表等)在代码里几行就能真实验证([Mike Barker](https://www.mike-barker.com/writing/swiftui-design-prototype))。这与 Figma-first 并存,取决于交互复杂度;对 MAformac 这类"要现场演真交互"的 solo demo,代码即原型更划算。

**过程框架都要裁但不能砍到 0**:
- 低保真→高保真的转场判据 = "你能明确说出正在测的问题、且该问题需要更高保真才能答"([Miro](https://miro.com/prototyping/low-fidelity-vs-high-fidelity-prototypes/));
- **Double Diamond** 对 solo 可压到几天,但 Discover/Define 只能"轻量化"不能整段跳过,并锁死决策日期([Dovetail](https://dovetail.com/product-development/what-is-the-double-diamond-design-process/));
- **Design Sprint** 单人可压到 3–4 天,但"**不做原型+测试就不叫 sprint**",2024 新变体是用 AI(如 Claude)在 Day 4 把手绘转可交互原型([Voltage Control](https://voltagecontrol.com/blog/do-shorter-design-sprints-work/))。

### 三、工程实现(engineering)

**UI 层架构选型(2024–2026 趋势)**:
- **纯 MV** = 主流方向:`@Observable` 模型 + `@State`/`@Bindable`/`@Environment(Type.self)` 直接驱动 View,核心是"每份数据单一事实源"。迁移路径:`ObservableObject`→`@Observable`(去 `@Published`)、`@StateObject`→`@State`、只读子视图去 wrapper、双向绑定用 `@Bindable`、`@EnvironmentObject`→`@Environment` 配 `.environment(obj)`([Forget MVVM](https://dimillian.medium.com/swiftui-in-2025-forget-mvvm-262ff2bbd2ed) / [State Management 2025](https://zoewave.medium.com/new-swiftui-state-management-3a6c9b737724))。
- **TCA** 有市场但对 solo demo 过度:大型 macOS app 有性能代价(全量 state 下发,Arc 浏览器案例处理 5 行文本耗约 9 秒 CPU),学习曲线陡([swiftyplace](https://www.swiftyplace.com/blog/the-composable-architecture-performance))。
- **MVVM 阵营仍在**:认为数据绑定与 SwiftUI 契合;结论是无单一官方答案,按复杂度选([MV vs MVVM 2025](https://dev.to/yossabourne/mv-vs-mvvm-in-swiftui-2025-which-architecture-should-you-use-video-26nb))。

**Design token 落 SwiftUI 的成熟范式**:分类(spacing/radius/typography/colors/elevation/animation)用 enum 承载(禁 `Color.blue`,改 `enum AppColor { static let background = Color("Background") }` 交 Asset Catalog 自动处理明暗/无障碍),主题经 `.environment(\.theme, currentTheme)` 注入,Xcode Preview 即时验证。示例值 spacing xs4/sm8/md16/lg24/xl32,radius sm6/md12/lg20/card16,animation fast0.15/standard0.25/slow0.45s([DEV Production-Scale](https://dev.to/sebastienlato/swiftui-design-tokens-theming-system-production-scale-b16))。

**Preview 驱动开发**:Xcode 15 `#Preview` 宏取代 `PreviewProvider`([SwiftLee](https://www.avanderlee.com/xcode/preview-swiftui-uikit-appkit-views/));Xcode 16 `@Previewable` 宏允许在 `#Preview` 块内联 `@State`,支持交互式预览、消除样板([SwiftLee @Previewable](https://www.avanderlee.com/swiftui/previewable-macro-usage-in-previews/))。

**macOS 特有 scene 结构**:`WindowGroup`(多实例)/`Window`(唯一窗口,适合工具面板)/`Settings`(自动接管 ⌘,)/`MenuBarExtra`(macOS-only 常驻菜单栏)/`DocumentGroup` 可组合。已知坑:`SettingsLink` 在 `MenuBarExtra` 里不可靠([Nil Coalescing](https://nilcoalescing.com/blog/ScenesTypesInASwiftUIMacApp/) / [steipete](https://steipete.me/posts/2025/showing-settings-from-macos-menu-bar-items))。

**Liquid Glass 工程 API(极低成本)**:用 Xcode 26 SDK 重编译,标准控件(Toolbar/Sidebar/菜单栏/NSPopover/Sheets)自动获得 Liquid Glass;自定义视图用 `.glassEffect()`(默认 capsule,可 `.tint`/`.interactive()`),多块玻璃必须包进 `GlassEffectContainer`(玻璃无法采样另一块玻璃),用 `glassEffectID`+`@Namespace` 做形变过渡,按钮 `.buttonStyle(.glass/.glassProminent)`,工具栏用 `ToolbarSpacer(.fixed/.flexible)` 分组([WWDC25 Session 323](https://developer.apple.com/videos/play/wwdc2025/323/))。**无障碍自动降级无需额外代码**:Reduce Transparency→更磨砂、Increase Contrast→黑白带边框、Reduce Motion→禁弹性([DEV Best Practices](https://dev.to/diskcleankit/liquid-glass-in-swift-official-best-practices-for-ios-26-macos-tahoe-1coo))。**部署目标注意**:真 Liquid Glass API 要求 macOS 26,旧系统只能手搓 glassmorphism 近似([Klarity](https://www.klaritydisk.com/blog/building-liquid-glass-ui-macos))。

**SwiftUI on macOS 2025 能力边界(亲测)**:富文本编辑、List(约 1 万条流畅、2 万可接受、超 5 万秒级延迟)、原生 WebView 已可用;仍弱:`TextEditor` 无编程式换字体、拼写检查边打字边查不可靠([TrozWare](https://troz.net/post/2025/swiftui-mac-2025/))。**AppKit 桥接原则**:选最小桥接阶梯(纯 SwiftUI→`NSViewRepresentable`→`NSViewControllerRepresentable`→直接 `NSWindow`),SwiftUI 保持 source of truth;"别跟框架对抗"([Sketch/Tower](https://www.git-tower.com/blog/developing-for-the-desktop-sketch))。

**感知性能是独立可设计属性**(Linear 标杆):local-first(IndexedDB)+ optimistic update 消灭 spinner;动画只动合成属性(transform/opacity),绝不动触发布局的 width/height/margin;标准时长 0.1/0.25/0.35s;非对称节奏(出现即时、消失约 150ms);把最快路径压到键盘/单键([performance.dev](https://performance.dev/how-is-linear-so-fast-a-technical-breakdown))。

### 四、评审验收(review & acceptance)

**评审骨架 = Nielsen 十启发式 + 0–4 severity**:0=非问题/1=仅外观/2=次要/3=主要必改/4=灾难发布前必修;严重度由 frequency×impact×persistence 三因素综合。**用≥3 名评审员独立打分取均值**(单人评级不可靠)([NN/g 严重度](https://www.nngroup.com/articles/how-to-rate-the-severity-of-usability-problems/))。
> 注:本轮核验发现"1 人 35%/3 人 75%/5 人 85%"这组发现率数字被误挂在 severity 页,实出自 Nielsen 另一篇文章,未在本轮核实,故不作为决策数字引用。

**macOS 专属交互验收维度**(移动端没有、必须专门走查):
- 菜单栏标准菜单齐全 + 默认顺序(App/File/Edit/View/Window/Help)+ 标准快捷键(⌘C/⌘S/⌘Z);
- 每个可交互元素有可见 hover 悬停态、响应右键;
- 键盘全通路(Tab 顺序跟随视觉布局、焦点始终可见);
- 拖放反馈([Designing for macOS HIG](https://developer.apple.com/design/human-interface-guidelines/designing-for-macos))。
> 注:原调研中"所有元素必须有可见 hover"曾引一条已 302 失效的 HIG drag-and-drop 旧路径,该 URL 已剔除;hover/指针维度以 Designing for macOS 与 Raycast 露馅清单为准。

**可访问性验收工具链**:
- **VoiceOver 手测**:Cmd-F5 开关,VO=Ctrl+Option,VO+方向键导航,Ctrl+Option+U 开 Rotor;查焦点顺序、标签唯一有意义、状态播报([Netguru](https://www.netguru.com/blog/voiceover-accessibility-testing-macos));
- **Xcode Accessibility Inspector Audit** 自动扫 label/contrast/hit region/clipped text,`performAccessibilityAudit(for:_:)` 可挂进 UITests 做机械门(含 Dynamic Type 维度),但仅覆盖屏上元素,必须配人工 VoiceOver + 大字号([Create with Swift](https://www.createwithswift.com/testing-you-apps-accessibilty-with-the-accessibility-inspector/));
- **WCAG 2.2 对比度硬门**:正文 4.5:1、大字(18pt/14pt bold)3:1、非文本 UI 组件/焦点环 3:1(SC 1.4.11),Liquid Glass 半透明尤其易踩([W3C WAI](https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html))。

**UI 走查 checklist 化**:覆盖 typography/color/spacing/alignment/组件状态(hover/focus/disabled/error)/响应式,并做"首印象测试"([OverlayQA](https://overlayqa.com/blog/what-is-design-qa/))。

**"惊艳感"可拆成可评维度**:打开瞬间 gut reaction/vibe、视觉 wow 与精致质感、情感共鸣与信任感;且 **wow moment 要来得快**(首因效应,onboarding 早期出现)([UXM](https://www.uxforthemasses.com/creating-wow-moments/))。

**原生感验收清单(标杆综合)**:①行为对齐(无 `cursor:pointer`/无 web 式 hover 高亮/原生 sheet+popover/无出现闪烁)②系统控件优先(自动获得 Liquid Glass + 无障碍)③键盘一等公民 ④感知性能(乐观更新去 spinner、只动 transform/opacity、动画 100–350ms)⑤材质克制(玻璃只在导航层、禁 glass-on-glass、文字落实心层)⑥亮暗各自设计非反色 ⑦集中打磨开场 + 1–2 个招牌微交互([native-feel-skill](https://github.com/yetone/native-feel-skill) / [Raycast](https://www.raycast.com/blog/a-technical-deep-dive-into-the-new-raycast))。数值基线参考(注:社区 web 语境近似值,SwiftUI 里应尽量用系统语义值):8px 网格、窗口圆角 10px/卡片 8px/按钮 6px、动画 fast 150ms/standard 250ms、深色模式不能简单反色([macos-design-skill](https://github.com/ceorkm/macos-design-skill))。

### 五、AI 辅助(AI-assisted workflow)

**核心机制 = 截图对照闭环 + 编译门**:
- **Apple UICoder** 自监督循环证明该闭环有效——每份生成代码先过 Swift 编译器,再由 GPT-4V 对照 UI 描述判优,迭代 5 轮得约 99.6 万份 SwiftUI 程序,编译通过率超 GPT-4([9to5Mac](https://9to5mac.com/2025/08/14/apple-trained-an-llm-to-teach-itself-good-interface-design-in-swiftui/));
- **Xcode 26.3 已产品化**:新增 **RenderPreview MCP 工具**让外部 agent 直接抓 SwiftUI Preview 截图"亲眼看 UI",配 20 个 MCP 工具(BuildProject/RunAllTests/DocumentationSearch 含 WWDC transcript/ExecuteSnippet REPL 等),实现"改颜色→看截图→迭代"不出 agent 工作流;直接集成 Claude Agent 与 OpenAI Codex([DEV Xcode 26.3](https://dev.to/arshtechpro/xcode-263-use-ai-agents-from-cursor-claude-code-beyond-4dmi) / [Apple Newsroom](https://www.apple.com/newsroom/2026/02/xcode-26-point-3-unlocks-the-power-of-agentic-coding/))。Apple 建议放 `AGENTS.md`/`CLAUDE.md` 在仓根给 agent 上下文。
- **视觉反馈闭环三阶段**:截图捕获 → 上下文富化(不只给图,附 console 日志/DOM/失败 network)→ 迭代精修(具体指出"按钮字号过大"而非笼统抱怨)([Tweag Handbook](https://tweag.github.io/agentic-coding-handbook/WORKFLOW_VISUAL_FEEDBACK/))。

**已知坑一:幻觉 API**(编造不存在的 modifier/属性名,端侧小模型还倾向老 iOS 15 写法)。对策=文档接地(RAG/DAG 检索真实 API)+ 编译门 fail-closed([arXiv 2407.09726](https://arxiv.org/pdf/2407.09726))。⚠️ 对 MAformac 的 Qwen3-1.7B 端侧脑警示更强:小模型 SwiftUI 新 API 覆盖差,**UI 生成不宜交给端侧脑,应走 Xcode agentic + 文档接地的开发期工作流**。

**已知坑二:风格漂移**——session 内漂移(同组件三处三种 padding)、跨 session 失忆(新对话编造不同 token)、token 编造、静默破坏(组件 prop 改名仍用旧名)。对策 = context engineering:①**一个冻结的 token 参考文件,agent 只读不再生成**(铁律:token 不存在就停下问,不要发明)②约束装配真实组件而非现造 ③渲染截图对比参考图 ④lint 阻断 raw hex。金句:"The file is the floor. The loop is the fix."([Superdesign](https://superdesign.dev/blog/ai-design-system-drift))。

**中间表示抑制幻觉**:Athena 用三层 IR(Storyboard→Data Model→GUI Skeleton)分级脚手架,每阶段约束 LLM 能生成什么;用户研究显示导航流上 100% 偏好([arXiv 2508.20263](https://arxiv.org/html/2508.20263))。

**snapshot 测试作回归安全网**:pointfreeco `swift-snapshot-testing` 以 `assertSnapshot` 录参考图,覆盖 `.colorScheme`/`.sizeCategory`/多设备,可作 AI 改动后的 ground truth 对照门([DEV Snapshot Guide](https://dev.to/swift_pal/stop-shipping-visual-bugs-complete-ios-snapshot-testing-guide-for-uikit-swiftui-4i5o))。AI 视觉回归 QA 工作流用 SSIM/感知 diff(非逐像素)+ 稳定点截图 + 动态区屏蔽([AutonomyAI](https://autonomyai.io/technology/building-a-qa-workflow-with-ai-agents-to-catch-ui-regressions/))。

**Design-to-code 工具成熟但非省略开发**:五类始终手工——状态管理、导航、网络、持久化、无障碍([7 Tools Compared](https://theswiftk.it.com/blog/figma-to-swiftui-tools-compared-2026))。

---

## 对 MAformac 的适配建议

结合本地基线(纯端侧 macOS SwiftUI demo、solo 轻治理、北极星=现场 5 分钟惊艳不崩;已锁 Q2=C iOS 冻结、TTS=AVSpeechSynthesizer 进硬门、7 态视觉四态分色、主刀铁律=commander 亲笔精 grill + codex 只做机械接线):

**1. 架构:直接用纯 MV,别引 ViewModel/TCA**。`@Observable` DialogueState + `@Environment` 注入 DemoVisualState,契合 solo 轻治理与"每份数据单一事实源";TCA 对本项目属过度工程化,与宪法"能取巧的运行时灵活取巧"一致。

**2. Token 做成机器可读 SSOT,和契约 SSOT 同构**。项目已有 `tokens.md`(7 态色映射 + V 系列间距/字体/圆角)——建议落成 enum + Asset Catalog + `.environment(\.theme)`,**冻结成 agent 只读文件**(呼应宪法"安全门是代码不是 prompt / 契约 SSOT 派生")。这正是防 AI 风格漂移的"the file is the floor"。四态分色(clarify 琥珀/unsupported 灰/safety 红/crash 灰)应进 semantic token 层,而非散落在 View 里(现役债:`ContentView:122/:126` 的 `satisfied?green:gray` 二值压缩待补成 7 态穷尽 switch)。

**3. Liquid Glass 是低成本惊艳杠杆,但严格克制 + 保守投影**:
- 只给已 inventory 的三处导航层(MicDock/ContextCapsule/DemoControlPanel,对应 U44 hardening spike),内容卡片保持清晰实心;
- 三处相邻玻璃必须共用一个 `GlassEffectContainer`(视觉正确性硬规则);
- **现场无投屏/投影对比度不足** → 默认 Regular 变体,别用 Clear;演示前在 Reduce Transparency/Increase Contrast/Reduce Motion 三开关下各走查一遍(U44 正指向此);
- 承接"稳>炸"(D6 横切)与双通道降级(关键态靠颜色/数值/图标承载,动画只锦上添花)。

**4. 感知性能 = 北极星"反应快"的直接抓手**:借 Linear 范式——mock 车控本就是 local-first,天然无 spinner;动画只动 transform/opacity、时长压到 0.1/0.25/0.35s、出现即时/消失约 150ms;把演示最快路径压到键盘/单键(push-to-talk 已是按住录音)。matchedGeometry gated 过渡符合此原则。

**5. 惊艳集中打磨,不平摊**(Arc/Things 范式):北极星"5 分钟炸场"应集中在**开场 idle 全景态 + 1–2 个招牌微交互**(如语音识别→卡片点亮的形变过渡),而非每个界面平均用力。SD 台本"开场默认 idle 全景态、Theme 默认 .ivory 米白跟随系统"已是正确方向。

**6. AI 辅助工作流:UI 生成走开发期 Xcode agentic,不交端侧脑**。这条对项目尤其关键——Qwen3-1.7B 端侧脑负责语义理解,**不应让它生成 SwiftUI**。UIUE 主刀(commander/Claude)应:
- 用 Xcode 26.3 RenderPreview MCP + `CLAUDE.md`(项目已有,天然契合)做截图对照闭环;
- 幻觉 API 靠编译门 fail-closed(项目已有 `swift test` + `make verify`)+ DocumentationSearch 文档接地;
- **把 snapshot 断言加进现有 `swift test` 门**(对应 U17 snapshot + U32-U37 XCUITest 衔接),用 SSIM/感知精度而非逐像素,把 7 态视觉纳入机械回归。
- 与"codex 只做机械接线"边界一致:AI 生成的是脚手架,状态/导航/无障碍/审美决策归主刀。

**7. 评审验收:把方法论落成 Line D 验收门**:
- Nielsen 0–4 severity + ≥3 视角独立打分,可对应 aesthetic-first 5 Gate(⚠️ 该 5 Gate 具体门内容在仓内 `~/.claude/rules` 未见独立成文,建议本轮明确其五门定义或补立,消除引用悬空);
- macOS 专属维度进门:菜单栏/快捷键/hover/键盘全通路(iPhone→macOS 需把触摸模型转成点击/悬停/右键/键盘,已决 U14 用 `AnyLayout` 不用 SplitView、U16 macOS 触觉永远 `.none`);
- VoiceOver 手测 + `performAccessibilityAudit` 挂 UITests + WCAG 对比度门(4.5:1/3:1),对 Liquid Glass 半透明尤其把关。

**8. 外部缺口的补法**:本地 SKILL 给的是原则与 guardrail,缺的三块——(a) macOS 26 Tahoe 版本坑清单 → 本报告已补(TrozWare/AppleInsider 的对比度/卡顿争议 + Reduce Transparency 降级路径);(b) iPhone→macOS 交互语义转换范例 → 本报告 macOS 专属维度 + Raycast 露馅清单可直接转 checklist;(c) 桌面级炸场样例 → Arc 开场动画 + Things Magic Plus + Linear 微交互范式,建议主刀在 D1 UIUE 专场落成高保真样张后进 snapshot。

---

## 关键来源清单

**Apple 官方(CLEAN)**
- [Apple Newsroom — 新软件设计发布](https://www.apple.com/newsroom/2025/06/apple-introduces-a-delightful-and-elegant-new-software-design/)
- [WWDC25 Session 219 — Meet Liquid Glass](https://developer.apple.com/videos/play/wwdc2025/219/)
- [WWDC25 Session 356 — Get to know the new design system](https://developer.apple.com/videos/play/wwdc2025/356/)
- [WWDC25 Session 323 — Build a SwiftUI app with the new design](https://developer.apple.com/videos/play/wwdc2025/323/)
- [Designing for macOS — Apple HIG](https://developer.apple.com/design/human-interface-guidelines/designing-for-macos)
- [Design kits for iOS/iPadOS/macOS 27](https://developer.apple.com/news/?id=e2lxw9l1)
- [Xcode 26.3 agentic coding — Apple Newsroom](https://www.apple.com/newsroom/2026/02/xcode-26-point-3-unlocks-the-power-of-agentic-coding/)

**SwiftUI 架构与工程(CLEAN / MINOR_ISSUES 无造假)**
- [SwiftUI in 2025: Forget MVVM — Thomas Ricouard](https://dimillian.medium.com/swiftui-in-2025-forget-mvvm-262ff2bbd2ed)
- [iOS 17+ SwiftUI State Management (2025)](https://zoewave.medium.com/new-swiftui-state-management-3a6c9b737724)
- [TCA Performance — swiftyplace](https://www.swiftyplace.com/blog/the-composable-architecture-performance)
- [Scenes types in a SwiftUI Mac app — Nil Coalescing](https://nilcoalescing.com/blog/ScenesTypesInASwiftUIMacApp/)
- [SwiftUI for Mac 2025 — TrozWare](https://troz.net/post/2025/swiftui-mac-2025/)
- [@Previewable macro — SwiftLee](https://www.avanderlee.com/swiftui/previewable-macro-usage-in-previews/)
- [SwiftUI Design Tokens & Theming (Production-Scale) — DEV](https://dev.to/sebastienlato/swiftui-design-tokens-theming-system-production-scale-b16)
- [Showing Settings from Menu Bar — steipete](https://steipete.me/posts/2025/showing-settings-from-macos-menu-bar-items)

**设计流程(CLEAN / MINOR_ISSUES;stats 已剔除)**
- [Build a Design System from Scratch in 7 Steps — UXPin](https://www.uxpin.com/studio/blog/build-a-design-system-from-scratch-in-7-steps/)
- [Design Systems Step-by-Step Guide — UXPin](https://www.uxpin.com/create-design-system-guide/)
- [What Are Design Tokens — UXPin](https://www.uxpin.com/studio/blog/what-are-design-tokens/)
- [Connecting SwiftUI components — Figma Code Connect](https://developers.figma.com/docs/code-connect/swiftui/)
- [Figma to SwiftUI — Builder.io](https://www.builder.io/blog/figma-to-swiftui)
- [Prototyping with SwiftUI — Mike Barker](https://www.mike-barker.com/writing/swiftui-design-prototype)
- [Low vs High Fidelity Prototypes — Miro](https://miro.com/prototyping/low-fidelity-vs-high-fidelity-prototypes/)
- [Double Diamond design process — Dovetail](https://dovetail.com/product-development/what-is-the-double-diamond-design-process/)
- [Do shorter Design Sprints work — Voltage Control](https://voltagecontrol.com/blog/do-shorter-design-sprints-work/)
- [Liquid Glass: Hierarchy/Harmony/Consistency — Create with Swift](https://www.createwithswift.com/liquid-glass-redefining-design-through-hierarchy-harmony-and-consistency/)

**可用性与评审(CLEAN / MINOR_ISSUES;drag-drop 死链与误挂百分比已剔除)**
- [10 Usability Heuristics — NN/g](https://www.nngroup.com/articles/ten-usability-heuristics/)
- [Severity Ratings for Usability Problems — NN/g](https://www.nngroup.com/articles/how-to-rate-the-severity-of-usability-problems/)
- [Liquid Glass Official Best Practices — DEV](https://dev.to/diskcleankit/liquid-glass-in-swift-official-best-practices-for-ios-26-macos-tahoe-1coo)
- [VoiceOver Accessibility Testing on macOS — Netguru](https://www.netguru.com/blog/voiceover-accessibility-testing-macos)
- [Testing accessibility with Accessibility Inspector — Create with Swift](https://www.createwithswift.com/testing-you-apps-accessibilty-with-the-accessibility-inspector/)
- [Understanding SC 1.4.11 Non-text Contrast — W3C WAI](https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html)
- [What Is Design QA — OverlayQA](https://overlayqa.com/blog/what-is-design-qa/)
- [Creating wow moments — UXM](https://www.uxforthemasses.com/creating-wow-moments/)
- [Liquid Glass on macOS Tahoe — AppleInsider](https://appleinsider.com/articles/25/06/11/liquid-glass-is-more-than-skin-deep-on-macos-tahoe)

**标杆拆解与原生感(CLEAN)**
- [Technical Deep Dive into the New Raycast](https://www.raycast.com/blog/a-technical-deep-dive-into-the-new-raycast)
- [native-feel-skill — GitHub yetone](https://github.com/yetone/native-feel-skill)
- [How's Linear so fast — performance.dev](https://performance.dev/how-is-linear-so-fast-a-technical-breakdown)
- [Developing an Industry-Standard Design App (Sketch) — Tower](https://www.git-tower.com/blog/developing-for-the-desktop-sketch)
- [macos-design-skill — GitHub ceorkm](https://github.com/ceorkm/macos-design-skill)

**AI 辅助(CLEAN)**
- [Apple UICoder self-taught SwiftUI — 9to5Mac](https://9to5mac.com/2025/08/14/apple-trained-an-llm-to-teach-itself-good-interface-design-in-swiftui/)
- [Xcode 26.3 AI Agents — DEV](https://dev.to/arshtechpro/xcode-263-use-ai-agents-from-cursor-claude-code-beyond-4dmi)
- [Why AI Breaks Your Design System (Drift) — Superdesign](https://superdesign.dev/blog/ai-design-system-drift)
- [Athena: IR for Iterative Scaffolded App Generation — arXiv 2508.20263](https://arxiv.org/html/2508.20263)
- [Figma to SwiftUI: 7 Tools Compared 2026](https://theswiftk.it.com/blog/figma-to-swiftui-tools-compared-2026)
- [QA Workflow with AI Agents for UI Regressions — AutonomyAI](https://autonomyai.io/technology/building-a-qa-workflow-with-ai-agents-to-catch-ui-regressions/)
- [Visual Feedback Loop — Tweag Agentic Coding Handbook](https://tweag.github.io/agentic-coding-handbook/WORKFLOW_VISUAL_FEEDBACK/)
- [Complete iOS Snapshot Testing Guide — DEV](https://dev.to/swift_pal/stop-shipping-visual-bugs-complete-ios-snapshot-testing-guide-for-uikit-swiftui-4i5o)

**本地基线资产(项目内,相对路径需拼接 `/Users/wanglei/workspace/MAformac/`)**
- `Tools/agent-platform-plugin-refs/build-macos-apps-skills/`(swiftui-patterns / liquid-glass / window-management / view-refactor / appkit-interop 五个 SKILL.md + references)
- `docs/grill-tournament/grill-decisions-master.md`(UIUE grill 决策 SSOT,U1–U31/V1–V12/D1–D7/E 系列/U44)
- `docs/UIUE-checklist.md` / `docs/uiue-storyboard-grill-decisions.md`(SD1–25 台本)
- `docs/roadmap-2026-07-07-macos-closure-baseline.md`(Line D scope 与验收维度)
- `docs/commander-log/decisions.md`(D-121 主刀铁律立项)

> **引用悬空待确认点**:aesthetic-first 5 Gate 的具体五门定义在仓内 `~/.claude/rules` 未见独立成文(可能在 memory/skill 中),建议本轮明确或补立。

> **未采信数字(核验剔除)**:uxpin 指南的"快 34%/bug 减 47%/文档化 3.5 月"、Nielsen 发现率"35%/75%/85%/74–87%"(误挂 severity 页)、Percy"40%/3x"与"幻觉降至 96%"等聚合数字均未在本轮核实,不作决策依据。

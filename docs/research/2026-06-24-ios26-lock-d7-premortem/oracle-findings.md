---
type: pre-mortem-oracle-firsthand
status: 一手结构化（4 路 CC subagent full return 原文，保 source URL+日期；最一手 = transcript 见 INDEX）
date: 2026-06-24
note: 这是 4 路 oracle agent 的 full return 原文（一手），README.md 是据此的二手综合。每节带 agentId + 搜证次数。
---

# Oracle 一手发现（4 路）

---

## 节 1 — Liquid Glass 官方边界（agentId ad3b5d8134b9d8a50，14 tool_uses = 7 WebSearch+4 WebFetch+1 curl）

证据充分。7 次 WebSearch + 4 次 WebFetch + 1 次 Bash curl 坐实 Apple 官方 JSON data 端点原话。重要发现：**iOS 26.1 引入了官方「Tinted」toggle**，这是适用于 demo 的关键坑——纯 Clear glass 默认可读性差，Apple 自己都加了变浑选项。

**断言核验 = CONFIRMED（实质方向）/ 措辞 PARTIAL**：边界本身是 Apple 官方 HIG 明确规则（非社区解读），但磊哥引用的 "exclusively/best reserved for" 是社区转述，Apple 原话用 "floats above the content layer" + 明确禁令 "Don't use Liquid Glass in the content layer"。

### Apple 官方原话（curl `developer.apple.com/tutorials/data/design/human-interface-guidelines/materials.json` HTTP200 grep 坐实）
> "Liquid Glass forms a distinct functional layer for controls and navigation elements — like tab bars and sidebars — that floats above the content layer, establishing a clear visual hierarchy between functional elements and content."

> "Don't use Liquid Glass in the content layer. Liquid Glass works best when it provides a clear distinction between interactive elements and content, and including it in the content layer can result in unnecessary complexity and a confusing visual hierarchy. Instead, use standard materials for elements in the content layer, such as app backgrounds."

> "An exception to this is for controls in the content layer with a transient interactive element like sliders and toggles; in these cases, the element takes on a Liquid Glass appearance to emphasize its interactivity when a person activates it."

> "Use Liquid Glass effects sparingly... Limit these effects to the most important functional elements in your app."

- 来源：https://developer.apple.com/design/human-interface-guidelines/materials（官方 doc，2025 WWDC25 后随 iOS 26 更新）

### 措辞归属纠正
| 磊哥断言措辞 | 归属 |
|---|---|
| "exclusively for the navigation layer that floats above app content" | 🟡 社区措辞（conorluddy；Apple 原话 "floats above the content layer"，无 "exclusively"）|
| "content cards/full-screen backgrounds SHALL NOT use system glass" | 🟢 方向=Apple 官方（"Don't use Liquid Glass in the content layer... such as app backgrounds"）；"SHALL NOT" 是 RFC 化转述，Apple 用命令式 "Don't use"（强度等同明确禁令）|
| "best reserved for the navigation layer" | 🟡 社区转述（Apple JSON 里 grep 不到 "best reserved"）|

### iOS26 Liquid Glass 已知坑（最新设备适用的）
- 可读性是 Apple 自承认的真坑：iOS 26.1 新增 Settings→Display&Brightness→Liquid Glass→Clear/Tinted 开关（"Tinted increases the opacity... adds more contrast"）。来源 https://www.macrumors.com/how-to/ios-26-1-reduce-liquid-glass-effects/
- NN/g 系统批评：text-over-image 对比度差、"text on top of text creates an illegible mess"、浮动半透明控件抢注意力、过度动画。来源 https://www.nngroup.com/articles/liquid-glass/（2025-10-10）
- glass-on-glass 禁叠：glass 无法 sample 另一层 glass → 多 glass 必包 `GlassEffectContainer`。来源 https://developer.apple.com/videos/play/wwdc2025/323/
- content-layer 误用：conorluddy 把 `ContentView().glassEffect()` 标 WRONG，CORRECT = `ZStack{ ContentView()(无glass); HeaderView().glassEffect() }`。来源 https://github.com/conorluddy/LiquidGlassReference

### 三分类
- 🐯 tiger：① 默认 Clear glass 投屏可读性差（验证：设备设 Tinted/高 opacity + 核心读数绝不放 glass 上 + 投影强光逐张核）② 状态卡做成 glass = 踩 "Don't use in content layer"（验证：盘点所有 `.glassEffect()` 逐个判导航层 vs 内容层；状态卡=内容层=standard material）。
- 📄 paper-tiger：旧机发热/GPU——对我们不适用（锁最新设备 + 5min 短演示；坑全来自旧机长时使用语境）。
- 🐘 elephant：① 把社区措辞当 Apple 官方原话固化进 spec → 下游拿伪官方引文做权威（建议引 verbatim 4 段 + 标社区措辞为我方表述）② Apple "transient 控件例外"（slider/toggle 激活可用 glass）正好车控高频形态（温度滑块/风量 toggle）= Apple 点名正确用法，利好该写进 spec。

---

## 节 2 — SwiftUI API 引入版本（agentId a00368a613b1fb4f0，9 tool_uses = 7 WebSearch+1 WebFetch+定向补证）

ZoomNavigationTransition macOS unavailable 被 4 独立来源一致印证（Apple 文档 + Douglas Hill + theswift.dev + sagarunagar.com）。

### API 版本核验表
| API | 引入 iOS | 引入 macOS | source | 锁 iOS26+macOS26 后需 `#available`? |
|---|---|---|---|---|
| MeshGradient | iOS 18.0 | macOS 15.0 | https://developer.apple.com/documentation/swiftui/meshgradient | No（26≥18/15）|
| `.glassEffect()`/GlassEffectContainer | iOS 26.0 | macOS 26.0 | https://developer.apple.com/documentation/swiftui/glasseffectcontainer | No（26=26 刚好满足）|
| matchedGeometryEffect | iOS 14.0 | macOS 11.0 | https://developer.apple.com/documentation/swiftui/view/matchedgeometryeffect(id:in:properties:anchor:issource:) | No（26≫14/11）|
| navigationTransition(.zoom)/ZoomNavigationTransition | iOS 18.0 | **macOS unavailable** | https://developer.apple.com/documentation/swiftui/zoomnavigationtransition | iOS 侧 No；macOS 需平台守卫 `#if !os(macOS)` |
| Gauge.accessoryCircular | iOS 16.0 | macOS 13.0 | https://developer.apple.com/documentation/swiftui/gaugestyle/accessorycircular | No（26≫16/13）|

### 磊哥推论核验 = 完全正确
1. MeshGradient/matchedGeometry/glassEffect 无需 `#available` ✅（deployment 26 ≥ 各引入版本；glassEffect 边界情形 26=26 仍满足）。
2. zoom 需平台守卫非版本守卫 ✅——macOS 根本无 `ZoomNavigationTransition` 类型（`@available(macOS, unavailable)`），引用即编译报错，与版本无关。
3. 🔴 守卫写法纠正：磊哥写 `#if os(macOS)` 方向反了——正解 `#if !os(macOS)`（或 `#if os(iOS)`），要「非 macOS 才编译」。判断（要平台守卫非版本守卫）对，符号反。

补充坑：zoom 在 tvOS/watchOS/visionOS「可编译但无效果」；Mac Catalyst「Scaled to Match iPad」zoom 有效、「Optimize for Mac」退化 push、纯原生 macOS 完全 unavailable。

---

## 节 3 — Xcode26 SPM deployment bug（agentId a22b9ec67faba9ea9，9 tool_uses = 5 WebSearch+3 WebFetch）

结论：**thread 81601 真实存在，但描述的不是「Package.swift 被改写抬高」，而是 unified build 编译期 deprecation 警告——隔离方案安全，几乎零风险。**

### ① bug 核验
- URL：https://forums.swift.org/t/minimum-deployment-target-being-ignored-for-swiftpm-packages-in-xcode-26/81601
- 标题「Minimum Deployment target being ignored for SwiftPM packages in Xcode 26?」（Package Manager 板块）
- 发帖 2025-08-11（sasouth），唯一回复 OP 自己 2025-08-14（怀疑 StoreKit 专属）
- 状态：**无 Apple 工程师回复、无 radar、未确认 bug、未标 fixed**。零回复孤帖，发于 Xcode 26 Beta 5。
- 实际症状 = deployment 设 iOS17 仍收 `SKProductsRequestDelegate is deprecated: first deprecated in iOS 18.0` **deprecation 警告**，非「.iOS(.v17) 被覆盖成 v26」。
- SE-0236 原文背书（非新 bug）：「In theory, SwiftPM can use the top-level package's deployment version to compile the entire package graph... but it also means that the users might start seeing a lot of warnings due to use of a higher version.」https://github.com/swiftlang/swift-evolution/blob/main/proposals/0236-package-manager-platform-deployment-settings.md
- → bug 真实（警告层面）；「声明被改写导致 import 失败」无证据，不存在。

### ② 对隔离方案影响
- 「别处 import Core 炸」= **paper-tiger，不会发生**。Package.swift `.iOS(.v17)` 是源码级元数据，不被 app target pbxproj 持久回写。CLI/A2 用 swift CLI 消费 Core 时 graph 里没那个 iOS26 app target，编译用 v17，import 正常。
- 唯一真影响：MAformacIOS/Mac(v26) graph 编 Core 时 Core 可能按 iOS26 编 → 若 Core 用了 iOS18-26 间废弃 API 冒 deprecation 警告。默认只警告不阻断；除非开 warnings-as-errors。
- demo（mock 车控/Qwen+LoRA/SwiftUI）基本不碰 StoreKit 高频废弃面，命中概率低。

### ③ workaround + 核验命令
1. 首选：什么都不做 + 别开 warnings-as-errors。
2. 若 Core 冒警告想压：swift-tools-version 升 6.2 + `-Wwarning DeprecatedDeclaration`（别用 unsafeFlags，破 portable）。
3. 硬隔离：给 Core target 挂 xcconfig 显式锁 `IPHONEOS_DEPLOYMENT_TARGET=17.0/MACOSX_DEPLOYMENT_TARGET=14.0`。
- 核验：`xcodebuild -showBuildSettings -scheme MAformacCore -sdk iphoneos | grep DEPLOYMENT_TARGET`（期望 17.0）；纯 Package 可 `swift build --triple arm64-apple-ios17.0 -Xswiftc -print-target-info`。

### ④ 三分类
- paper-tiger：「Xcode26 把 Core 抬到 iOS26 → import 炸」（隔离方案本身即正解）。
- tiger：Core 在 v26 graph 冒 deprecation 警告（验证：showBuildSettings 看 Core resolved deployment + 编 MAformacIOS 看有无 `[DeprecatedDeclaration]` + 确认没开 warnings-as-errors）。
- 🐘 elephant：真正挡构建的是 toolchain 错配 + warnings-as-errors（swift#84379「Swift 6.1 OSS toolchain cannot build packages when Xcode 26 installed」/ spm#9517）→ **别在 Core 的 Package.swift 硬塞全局 warnings-as-errors**。

sources：forums.swift.org/t/.../81601（2025-08-11）；SE-0236；forums.swift.org/t/.../76810；hackingwithswift.com/swift/6.1/diagnostic-groups；github.com/swiftlang/swift/issues/84379；github.com/swiftlang/swift-package-manager/issues/9517

---

## 节 4 — iOS26 稳定性 + 截图管线（agentId a2c1cbdf77fd7df63，10 tool_uses = 8 WebSearch）

🔴 致命：① ImageRenderer 渲染 material/blur/Liquid Glass 会缺失（Core Animation 合成内容不进 raster）= ImageRenderer 截不出 Liquid Glass。② simctl 在无 host app 的 snapshot test 黑屏，但启动整 app 后截图正常。

### ① iOS26/macOS26 稳定性 tiger（带 URL+日期）
| # | tiger | 来源 |
|---|---|---|
| T1 | TabBar 启动崩溃（A18 Pro/iPhone17）：原生 tab release 构建 0.15s SIGABRT | github.com/software-mansion/react-native-screens/issues/3940（2026）|
| T2 | SwiftData 迁移崩溃 `Cannot use staged migration with an unknown model version`（134504）模拟器+真机 | developer.apple.com/forums/tags/swiftui |
| T3 | Menu label 点开消失（需 FixedMenu wrapper） | medium.com/@mezhevikin/fixing-ios-26-menu-label-bug-in-swiftui（2025）|
| T4 | Liquid Glass glass-on-glass 采样错乱（必 GlassEffectContainer） | dev.to/diskcleankit/liquid-glass-in-swift-official-best-practices（2025）|
| T5 | `.glassProminent`+`.circle` 渲染伪影（加 `.clipShape(Circle())` 绕） | dev.to/diskcleankit（2025）|
| T6 | Menu morphing 动画断裂（iOS26.1 Menu 进 GlassEffectContainer 断 morphing） | medium.com/@madebyluddy/overview（2025）|
| T7 | Liquid Glass 性能/电量退化+偶发崩溃 | marcgg.com/blog/2025/07/07/ios26-beta-so-far（2025-07-07）/ news.ycombinator.com/item?id=45544044（2025-10）|
| T8 | Tahoe 可读性塌陷（菜单/窗口标题看不清，Light Aqua 窗口背景纯白） | mjtsai.com/blog/2025/12/29/liquid-glass-disbelief（2025-12-29）|
| T9 | Instruments SwiftUI 模板静默吞数据 | SwiftUI 论坛 |

逃生口：iOS Info.plist `UIDesignRequiresCompatibility=YES` 全局退出 Liquid Glass（stopgap，未来可能丢硬件加速）；macOS `defaults write -g com.apple.SwiftUI.DisableSolarium -bool YES` 后重启。

### ② 截图管线推荐
**结论：iOS 用法1（simctl 启动整 App 后截图）最稳；ImageRenderer（法2）不能用于 Liquid Glass demo 审美验收——截不出 glass。**
| 法 | 批量无人值守 | 坑 |
|---|---|---|
| 法1 `xcrun simctl io <udid> screenshot` ⭐ iOS 推荐 | ✅ 最稳：截真实合成画面，Liquid Glass/material/blur 全在 | 用 explicit UDID 别用 booted；截前 `simctl bootstatus <udid> -b` 轮询；要驱动到第 N 态；黑屏只发生在无 host app 的 SPM snapshot test（启动整 App 即避，swift-snapshot-testing#1058）|
| 法2 ImageRenderer 单 view→PNG | ⚠️ 审美验收**不可用** | material/blur/Liquid Glass 全缺失（Apple 官方：合成内容不进 raster，developer.apple.com/documentation/swiftui/imagerenderer）|
| 法3 macOS screencapture | ⚠️ 最弱 | 默认截壁纸；截窗口要 `-l <windowid>`（无官方拿 windowid 法，需 GetWindowID）；Terminal 需屏幕录制权限（无人值守首次卡权限弹窗）|

### ③ ImageRenderer 渲染 @Observable view 注意点
1. 必须 re-inject 环境（`.environment(model)`，否则 No ObservableObject found）2. 必须 @MainActor 3. 必须设 `renderer.scale=displayScale` 4. 用 default 环境（颜色可能与 App 不一致）5. 取 PNG 要 `uiImage.pngData()` 6. @Observable+@State 重建坑 7. iOS26 Observations「只读到的属性才更新」by design 8. 🔴 即使全注入对，仍截不出 Liquid Glass（故法2 不可用）。

### ④ 三分类
- tiger：ImageRenderer 截不出 Liquid Glass（最致命，假绿）/ simctl `booted` 多机抓错（用 explicit UDID）/ 截太早抓启动中间态（bootstatus 轮询）/ TabBar release iPhone17 启动崩溃。
- paper-tiger：simctl 黑屏（只在无 host app SPM snapshot test，启动整 App 避）/ @EnvironmentObject 渲染崩（一行 re-inject 解）/ glass 渲染伪影（clipShape 绕）。
- 🐘 elephant：macOS scre截图管线脆弱（windowid+权限，建议 iOS 模拟器全自动+macOS 少量手动）/ **「态导航」才是无人值守真难点（70%）非截图本身** / 模拟器 vs 真机 Liquid Glass 渲染差异（关键态真机补截）/ 退出 Liquid Glass 逃生口=丢"惊艳"卖点。

来源见各行内联 URL。

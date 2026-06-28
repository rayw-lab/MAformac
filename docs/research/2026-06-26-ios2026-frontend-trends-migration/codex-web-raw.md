---
type: vendor-research-firsthand
agent: codex-web (Codex CLI v0.142.2, gpt-5.5 high, web search)
role: web researcher
date: 2026-06-26
scope: 只读联网调研（结论基于 2026-06-26 实时检索）
⚠️ caveat: source 出现 iOS 26 / iOS 27 / WWDC26 混用。版本事实以本目录 `oracle-liquid-glass-firsthand.md`（我方 oracle 核实）+ UIUE 树已有 premortem 为准：**glassEffect=iOS 26.0/macOS 26.0（WWDC2025 引入）**；codex-web 列的多数"新 API"（toolbar visibilityPriority/overflow、reorderContainer、resizable interactive API）实为 **iOS 27/WWDC26**，UIUE 树锁 iOS 26 → 默认 Watch。
---

# codex-web 一手回稿（2026 iOS 前端趋势）

**status：DONE / read-only research**。未改文件。Web search 已用，结论基于 2026-06-26 实时检索。

## Source List（带日期）
- Apple Developer News, 2026-06-23：iOS/iPadOS/macOS 27 设计套件，Liquid Glass 更新、组件状态扩展、命名贴近代码、改进 resizing。https://developer.apple.com/news/?id=e2lxw9l1
- WWDC26 "Platforms State of the Union", 2026-06：Liquid Glass 在 27 releases 中增强可读性、边缘高光、用户 tint slider、accessibility 适配；Xcode 27 后旧设计 opt-out 将移除。https://developer.apple.com/videos/play/wwdc2026/102/
- WWDC26 "What's new in SwiftUI", 2026-06：toolbar 优先级、overflow、topBarPinnedTrailing、滚动最小化、Document API、reorderable、任意 view swipe actions、ContentBuilder。https://developer.apple.com/videos/play/wwdc2026/269/
- WWDC26 "Modernize your UIKit app", 2026-06：iPhone app 在 iPad / iPhone Mirroring 中 fully resizable；scene lifecycle、trait/size-class、UIKit bars/menus 新 API。https://developer.apple.com/videos/play/wwdc2026/278/
- WWDC26 "Code-along: Build powerful drag and drop in SwiftUI", 2026-06：reorderable、drag container、多项拖拽、drag/drop configuration。https://developer.apple.com/videos/play/wwdc2026/271/
- WWDC26 "What's new in Xcode 27", 2026-06：Device Hub、resize mode、accessibility settings、Liquid Glass / SwiftUI hitch metrics。https://developer.apple.com/videos/play/wwdc2026/258/
- Apple HIG / docs：Liquid Glass materials、tab bars、UIKit UINavigationController Liquid Glass 注意事项、SwiftUI glassEffect / GlassEffectContainer。https://developer.apple.com/design/human-interface-guidelines/materials
- Explore SwiftUI, 2026-06-26 crawled：WWDC26 / iOS 27 SwiftUI visual examples。https://exploreswiftui.com/
- Point-Free swift-navigation / swift-composable-architecture（current GitHub）：状态驱动导航与可测试架构仍是高质量工程候选，但不是 Apple 原生趋势本身。https://github.com/pointfreeco/swift-navigation

## 关键趋势
1. **SwiftUI 继续是主线**，不是"UI 框架百花齐放"。Apple 新 UI 能力明显优先落在 SwiftUI：Liquid Glass、toolbar 重排、Document API、drag/drop、lazy stack、Preview/Device Hub 验证链路都围绕 SwiftUI 展开。
2. **Liquid Glass 已从视觉特效变成系统层 UI 规则**。正确用法不是自定义毛玻璃，而是标准组件优先，必要时才用 glassEffect / GlassEffectContainer；品牌色应更多进入内容层，导航和动作层保持平台熟悉感。https://developer.apple.com/videos/play/wwdc2026/251/
3. **2026 后重点从"好看"转向"可变尺寸 + 可访问性 + 性能"**。iPhone app 在 iPad 和 iPhone Mirroring 中可 resize，不能再假设固定设备、固定方向、固定宽度。
4. **交互封装更原生化**：toolbar priority/overflow、tab prominent role、任意 view swipe actions、reorderable、drag container、多项拖拽，减少手写 gesture state machine。
5. **UIKit 不是淘汰，而是现代化压力增大**。旧 app lifecycle、UIScreen.main、idiom/orientation 判断会成为适配债；混合 UIKit/SwiftUI 项目要主动清理。
6. **第三方组件库趋势是"补兼容层/设计 token/导航状态化"**，但 Liquid Glass 这类系统视觉不宜被第三方库吞掉。优先用 Apple API，最多封一层 MAformac 自己的 design tokens。

## MAformac 候选技术（codex-web 原始建议）
- **高优先级**：SwiftUI 原生 Liquid Glass wrapper。封装 GlassSurface / GlassActionButton / GlassToolCard，内部 `#available(iOS 26, *)`，旧系统 fallback 到 Material。不要引入外部 Liquid Glass UI 库。
- **高优先级**：Resizable-first app shell。MAformac iOS 演示端必须按动态尺寸、横竖屏、iPhone Mirroring、iPad window 测；不要写死 iPhone 单尺寸。
- **高优先级**：Toolbar/Tab 原生模式。车控演示的"主操作"适合 topBarPinnedTrailing / prominent action；低频调试项进 overflow，不要堆满自定义按钮。
- **中优先级**：SwiftUI reorderable / drag container。适合 UIUE 或演示编排里的"场景卡片排序、能力卡片重排、demo playlist"。
- **中优先级**：Point-Free Swift Navigation。若 MAformac 需要复杂 enum-driven routing，可作为候选；但先评估与现有 SwiftUI NavigationStack 是否足够，别为 demo app 过度架构化。
- **暂不建议**：React Native / Flutter / Expo UI。它们可以追 Liquid Glass 外观，但 MAformac 当前项目宪法锁定纯端侧 SwiftUI/iOS/macOS，混入跨端框架会增加验证和视觉一致性风险。

---
type: vendor-research-firsthand
agent: codex-repo (Codex CLI v0.142.2, gpt-5.5 high)
role: repo/context researcher
date: 2026-06-26
scope: 只读静态检查（proof class = local_static）
tree_studied: /Users/wanglei/workspace/MAformac （main 分支 codex/rebuild-c6-doc-absorption-20260624 @ de79c65）
⚠️ caveat: codex-repo 审的是 **main 主树**（落后于 UIUE 隔离树）。其「LazyVGrid.adaptive / fast-path skeleton / 升级切入点」描述的是 main 现状；UIUE 树（uiue/phase4-default-scope-presentation）多数切入点**已落地**（见 README §UIUE 树现状）。本档保留为一手原文。
---

# codex-repo 一手回稿（main 树 iOS/UI 结构盘点）

**status = DONE / local_static**。只读完成，未改文件，未跑 build/simulator。

## 关键结论
当前 main app 是 **SwiftUI + Observation 骨架，不是 UIKit**。Xcode 有两个 app target：`MAformacMac` 和 `MAformacIOS`，都吃 `App/Core/Features` 同一套源码；iOS target 锁 `IPHONEOS_DEPLOYMENT_TARGET = 26.0`，SwiftPM Core 仍声明 `.iOS(.v17)` / `.macOS(.v14)` 用于库层隔离。证据：`MAformac.xcodeproj/project.pbxproj:72`、`Package.swift:7`。

## 关键文件路径
- `App/ContentView.swift:3`：主 UI，NavigationStack、命令栏、LazyVGrid 卡片、trace panel。
- `App/DesignTokens.swift:3`：Swift 侧视觉 token + `CardAppearance.of()` 7 态映射。
- `App/DebugGallery.swift:4`：DEBUG 视觉验收脚手架，force-state + 7 态 gallery。
- `Core/State/DemoVehicleStateStore.swift:17`：`DemoVisualState`、`DemoVehicleStateCell`、`@Observable @MainActor DemoVehicleStateStore`。
- `Core/Execution/C3ExecutionPipeline.swift:36`：执行管线、guard、readback、scope origin、mock transition。
- `Features/VehicleControl/DemoWalkingSkeleton.swift:3`：当前交互封装，文本 → fast path → guard → mock transition → TTS。

## 当前 UI 技术栈
- 前端框架：SwiftUI。未发现 UIKit/UIView/UIViewController 使用。
- 状态管理：Swift Observation，`DemoVehicleStateStore` 是 `@Observable @MainActor`，视图用 `@Bindable` 注入 store。
- 视觉组件层：`VehicleStateCard` + `DesignTokens` + `CardAppearance`。7 态已做穷尽 switch，颜色/边框/SF Symbols/呼吸或脉冲动效都在 token 层集中。
- 动画：只有 `withAnimation(...repeatForever...)` 的卡片辉光/脉冲；已读取 `accessibilityReduceMotion`，但未见低电量 gate、matchedGeometry、MeshGradient、glassEffect。
- 布局：当前主界面和 debug gallery 都还是 `LazyVGrid(.adaptive(...))`，不是 ui-presentation spec 里要求的固定 Grid。
- 交互封装：`ContentView.runCommand()` 每次创建 `DemoWalkingSkeleton`；fast path 只识别"打开空调"，后续完整执行管线在 `C3ExecutionPipeline`，但主 UI 当前没有直接接上完整 C3 pipeline。
- 语音：TTS 用 AVSpeechSynthesizer，见 `Core/Voice/SpeechSynthesisEngine.swift:1`。

## 可升级切入点（main 树视角）
1. `LazyVGrid(.adaptive)` → 固定 Grid / family-card 布局。当前 `App/ContentView.swift:39`，spec 明确要求固定列、禁 adaptive，见 `openspec/changes/ui-presentation/specs/ui-presentation/spec.md:108`。
2. 从"state cell 平铺"升级为"10 族 family card"。spec 要 `family_card_id` + row_count 排序，见 `spec.md:81`。
3. 补 reason/blocked 来源链。`VehicleStateCard.reason` 已有参数，但 `store.reason(for:)` 尚未落；spec 要从 store 消费 reason，不硬编码，见 `spec.md:69`。
4. 主 UI 接完整 `C3ExecutionPipeline`，不要停留在 fast path skeleton。证据 `Core/Execution/C3ExecutionPipeline.swift:57`。
5. scope 展示同源化。spec 要 default_scope、显式 scope、fan-out 聚合 badge、TTS/readback/card 同源，见 `spec.md:171`。

## 2026 新技术调研重点对照维度
- SwiftUI 2026 API：Grid 稳定布局、matchedGeometryEffect 的 iOS/macOS 行为、glassEffect() 的正确层级边界、MeshGradient/Shader 是否只做氛围层。
- 可用性而非炫技：Reduce Motion、低电量、投屏 1080p/Retina、暗底 cyan halation、文字可读性。
- 数据边界：Runtime → Presentation bridge 是否有 stable IDs、reason、scopeOrigin、family_card_id、visualState、readback metadata。
- 双端证明：iOS 真机/模拟器、macOS app、离线独立运行，不能把 macOS local 截图升格成 iPhone V-PASS。
- 组件抽象：`VehicleStateCard` 是否拆成 family card、value renderer、scope badge、reason strip、orb/command layer，而不是继续堆在 `ContentView.swift`。
- 性能验证：同屏 10 族、辉光/玻璃/shader、matchedGeometry、trace panel 更新对 diff 和帧率的影响，必须 Instruments 或 simulator screenshot proof。

**Residual**：这次是只读静态研究，没有验证运行效果、截图、构建或真机表现。

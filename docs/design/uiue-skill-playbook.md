---
type: uiue-skill-playbook
status: ACTIVE v1（2026-06-24 建；Tools/skills teardown + lens5 adopt 清单 + UIUE Phase 映射）
date: 2026-06-24
owner: UIUE 链路 A（worktree MAformac-uiue）
关联基建:
  - docs/uiue-roadmap-2026-06-23.md（7 Phase SSOT，本 playbook 按 Phase 索引）
  - docs/design/INDEX.md（视觉 SSOT 入口，写 view 前必读）
  - docs/grill-tournament/grill-decisions-master.md §3（D1-D8/裂缝⑤⑥④ 决策晶体）
  - Tools/skills/INDEX.md（skill 源索引，1b IMPORT 段）
---

# UIUE Skill & Adopt Playbook —「什么 Phase/任务，用什么 skill + 抄什么代码 + 避什么坑」

> 🔴 **UIUE 开发起手读本表**：定位当前任务 → 三列（调哪个 skill / 抄哪段 ref-repos 代码 / pre-mortem 必避的坑）。
> 两类资产互补：**Tools/skills/ = 知识 skill**（怎么写/验收/测，刚装 2026-06-24）；**ref-repos/ = 可抄代码**（lens5 adopt 清单，star>1000 不降级，已 clone `~/workspace/raw/05-Projects/MAformac/ref-repos/`，只读不入仓）。

## 0. 两类资产清单

### A. Tools/skills（知识 skill，项目级激活，30 个）
| 类 | skill | 一句话能力 |
|---|---|---|
| **SwiftUI 核心** | `axiom-swiftui` | views/nav/layout/**containers(Grid)**/animation/gestures/previews/perf；主路由表 + sub-skill + auditor agent |
| **视觉/HIG** | `axiom-design` | HIG 决策树/**Liquid Glass**(functional-only)/SF Symbols/typography/app-composition；**design FIRST 决 what → swiftui 做 how** |
| **双端 macOS** | `axiom-macos` | 窗口/菜单/sandbox/AppKit 桥/ScreenCaptureKit |
| **测试** | `axiom-testing` | Swift Testing(@Test/#expect)/XCUITest/snapshot/UI recording；testing-auditor agent |
| **性能** | `axiom-performance` + `ios-ettrace-performance` | Instruments/memory/帧率/retain cycle；ETTrace launch/runtime profile |
| **并发** | `axiom-concurrency` | async/actor/@Observable/Sendable/data race |
| **媒体语音** | `axiom-media` | AVFoundation/camera/audio/**haptics**/AVSpeechSynthesizer/CarPlay |
| **AI** | `axiom-ai` | Foundation Models/@Generable（baseline/逃生口） |
| **a11y** | `axiom-accessibility` | VoiceOver/Dynamic Type/对比/触控目标 |
| **API 查询** | `axiom-apple-docs` | Apple framework API/Swift 编译错误/Xcode 文档 |
| **build/调试** | `axiom-build` + `ios-debugger-agent` | build 失败诊断(env-first)/simulator build-install-launch-logs-screenshots |
| **视觉验收** | `ios-simulator-skill` | **29 scripts**：simctl 启动+截图/语义 UI 导航/a11y 树/hang/性能 |
| 其余 axiom | swift/uikit/data/networking/security/integration/shipping/graphics/games/health/payments/vision/watchos/xcode-mcp/tools | 按 description 触发，UIUE 弱相关 |

### B. ref-repos adopt 清单（lens5 可抄代码，已 clone）
| 资产 | file:line（ref-repos/）| star/新鲜度 | 抄什么 | 用于 |
|---|---|---|---|---|
| MLX-Outil | `MLX-Outil/Views/ToolsGridView.swift:39-59` | 本机 2026-05-23 活跃 | 自适应网格（Mac 多列/iPhone 2 列）| Phase 4 卡片网格 |
| ShipSwift | `ShipSwift/.../SWKPICard.swift:75,135` | 本机 2026-06-08 | 泛型卡 `SWKPICard<Trailing>` + `.contentTransition(.numericText())` | Phase 4 卡片骨架 |
| DaVinci | `DaVinci/.../DSSegmentedControl.swift:60,87-126` | 本机活跃 | `@Namespace`+matchedGeometry 滑块 | Phase 4 档位控件（风量/座椅档）|
| hanlin-ai | `hanlin-ai/.../ChatViewComponents.swift:24-67` | 229★ 2026-05-31 | TimelineView 流光思考微光 | Phase 5 think 态 |
| hanlin-ai | `hanlin-ai/.../VoiceInputView.swift:202-239,347,159` | 229★ | RMS 波形+触觉+玻璃 | Phase 5 录音 UI |
| Orb（仅纯代码子件）| `Orb/.../RotatingGlowView.swift:42-61` | 422★ stale，主体 fork vendor | 纯代码辉光环（零 asset）| Phase 5 orb idle/卡 glow |
| Inferno | `Inferno/.../Water.metal:28-44` | 2879★ 2026-05-17 | `water(speed,strength,frequency)` shader（strength3/freq10 起手）| Phase 5 炸场水波（U5）|
| SwiftUIShaders | `SwiftUIShaders/.../ShaderEffects.swift:50,199` | 本机 2026-06-01 | IGN dither 消投屏 8bit banding | Phase 5/6 投屏防 banding |
| mlx-swift-examples | LLMEval（联网，非 clone）| 2608★ Apple 官方 | `@Published output + displayEveryNTokens` 流式 UI | Phase 5 对话流 |

> **淘汰（新鲜度门，借鉴不依赖）**：metasidd/Orb 主体（19月stale）/ CompactSlider(7月)/ exyte/Grid(原生够)/ swiftui-hero-animations(6年)/ Inxel/hendriku/Priva28（全>半年）。

## 1. 按 Phase × 任务索引（核心表）

### Phase 1b 工程前置硬门（🔜next，不依赖后端）
| 任务 | 用 skill | 抄代码 | pre-mortem 坑 |
|---|---|---|---|
| Info.plist/entitlements | `axiom-macos`(sandbox-and-file-access) | — | V9 Core 不塞 warnings-as-errors（v26 graph deprecation 阻断 build）|
| snapshot baseline | `axiom-testing`(swift-testing) + `ios-simulator-skill`(visual_diff.py) | — | 🔴 **ImageRenderer 截不出 Liquid Glass=假绿** → 必 `xcrun simctl io <udid> screenshot` 启动整 app |
| Availability 守卫 | `axiom-apple-docs` / `axiom-swift` | — | `#if !os(macOS)` zoom 守卫方向（写 `os(macOS)` 反=崩）|

### Phase 4 卡片 scope 呈现（🔴 当前，从 0 重做）
| 任务 | 用 skill | 抄代码 | pre-mortem 坑 |
|---|---|---|---|
| 卡片 Grid 5×2 常驻（10 族 family_card）| `axiom-swiftui`(containers-ref) | MLX-Outil `ToolsGridView:39-59` | T3 adaptive 无 max → resize 跳动；Mac 用固定 `Grid`、iPhone `LazyVGrid`+`.scrollClipDisabled()`（防 glow 裁切）|
| value.type 异构控件 | `axiom-swiftui` + `axiom-design`(sf-symbols) | ShipSwift `SWKPICard:75` / DaVinci `DSSegmentedControl:60` / 原生 `Gauge(.accessoryCircular/.accessoryCircularCapacity)` | F-LB2 `numericText` 必 `withAnimation` 包裹否则不动；`.circular` 是 watchOS 专属 iOS 用 `.accessoryCircular` |
| scope 淡角标（裂缝⑤⑥④）| `axiom-design`(hig) | — | 角标用 `content_glow`（standard material）**非** glass；别用 GPT 4-enum adapter |
| 7 态视觉（✅ D7 已 apply main）| — | — | 已 done（CardAppearance.of 穷尽 switch）|
| breathe glow（仅激活态）| `axiom-swiftui`(animation-ref) | Orb `RotatingGlowView:42-61` | F-LB3 不用裸 Timer（CPU 100%）用 `.repeatForever`；T1 只激活态 breathe（10 张同屏=10 offscreen pass）|
| 单测 | `axiom-testing`(swift-testing) | — | 测 display model 纯函数**还要测接线**（绿≠UI 用了 model）|
| 视觉验收 ⭐⭐ | `ios-simulator-skill`(simctl 截图 + force-state) | — | 🔴 还原投屏实查不看高清导出图；7 态 gallery 满屏单态 5-gate |
| 性能（Grid 流畅）| `axiom-swiftui`(swiftui-performance) → `axiom-performance` | — | 先 swiftui 域修（5min）不行再 profiling |

### Phase 5 语音 orb + 思考链路 + 炸场（grill 已拍 DA0-DA8/E0-E8）
| 任务 | 用 skill | 抄代码 | pre-mortem 坑 |
|---|---|---|---|
| orb MeshGradient 四态 | `axiom-swiftui`(animation) | Orb `RotatingGlowView` + 自建 MeshGradient | 第三方 orb 库全 stale 自建 |
| think 态思考微光 | `axiom-swiftui` | hanlin-ai `ChatViewComponents:24-67` | 整段直抄 gradientColors 改深空青 |
| 语音态机（VoiceState 五态）| `axiom-concurrency`(@Observable) + `axiom-media`(AVFoundation) | hanlin-ai `VoiceInputView` | F-LB5 barge-in `didCancel` utterance 边界静默 → 调用点直接改态 |
| 中文 TTS | `axiom-media`(AVSpeechSynthesizer) | — | 锁普通话 premium 音色 |
| 触觉 RMS 波形 | `axiom-media`(haptics) | hanlin-ai `VoiceInputView:347,159` | — |
| Metal 水波炸场 | `axiom-graphics` + `axiom-swiftui` | Inferno `Water.metal:28-44` | U30 shader 仅氛围层 |
| 帧率验证 | `axiom-performance` + `ios-ettrace-performance` | — | MeshGradient/shader 别掉帧 |

### Phase 6 现场 SOP（收口）
| 任务 | 用 skill | pre-mortem 坑 |
|---|---|---|
| 双端 Mac 主 | `axiom-macos` | Mac 规避 7 天证书 + jetsam tiger |
| 真机部署 | `axiom-shipping` + `axiom-build` | T-CRASH1 原生 tab release iPhone17 SIGABRT（demo 不用复杂 tab 可避）|
| 投屏防 banding | — | SwiftUIShaders IGN dither + 有线 HDMI/USB-C（非 AirPlay 掉帧）|

## 2. 横切（任何 Phase 最常用，⭐ 标高频）
- ⭐⭐ **视觉验收 = `ios-simulator-skill`**（UIUE 每次改 UI 必跑：simctl 启动整 app + 截图 + force-state 14 张 5-gate）
- ⭐ **build 失败 = `axiom-build`**（env-first 诊断）
- ⭐ **写任何 view 前 = `axiom-design`**（先决 what）**+ 读 `docs/design/INDEX.md`**（视觉 SSOT，禁 prompt 即兴）
- **Apple API 不确定 = `axiom-apple-docs`**（别凭记忆，尤其 iOS26 glassEffect/MeshGradient）
- **a11y = `axiom-accessibility`**（D7 双通道 a11y label）

## 3. axiom 自带 auditor agent（收口审计可用）
- `liquid-glass-auditor`（/axiom:audit liquid-glass）— 检 content-layer 误用 glass + 采样嵌套 + availability gate
- `swiftui-performance-analyzer` / `swiftui-architecture-auditor` / `swiftui-layout-auditor` / `ux-flow-auditor`
- `testing-auditor`（/axiom:audit testing）— 测试覆盖 shape + flaky + 未测关键路径

## 4. 维护
- 新装 skill / 新 adopt 资产 → 回写本表 + `Tools/skills/INDEX.md`。
- UIUE Phase 推进 → 对应行的「坑」命中实证回写。
- 本 playbook 是 **adopt-deep 第四腿**（找 skill → adopt 清单 → 怎么用映射），与 blueprint-teardown 同源。

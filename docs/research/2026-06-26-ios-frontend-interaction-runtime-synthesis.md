---
type: research-synthesis
topic: iOS 前端交互开发流程(视觉/动效/互动/层级/工程化) × 后端 runtime 握手
date: 2026-06-26
authority: research_not_ssot
sources: [GLM probe-ios-...20260626.md (standard depth), 本会话 4 finder fan-out (维度 A 工程流程 / B runtime 握手实操 / C 视觉动效前沿 / D 测试验收性能无障碍本地化)]
verify_status: load-bearing 声称已抽样核 (见 §核对账); finder D "MAformac 已用 swift-snapshot-testing" 假设已证伪
---

# iOS 前端交互开发流程 × runtime 握手 — 广泛调研综合

> 5 路调研（GLM 1 + CC 4 finder）跨源综合。受众=磊哥（座舱语音/前端老兵），跳科普，直接机制/成本/对 MAformac 的 load-bearing 决策。**多路独立收敛 = 高可信**；finder 凭印象的假设已 catch 纠正。

## TL;DR — 跨源强收敛的 5 个 load-bearing 结论

1. **像素 RMSE 硬门 = 已被业界证伪的反模式**（GLM H3 + Finder D 双独立证）。🔴 **MAformac 当前 `Tools/checks/phase2_zone_compare.py:87 def rmse` 正是纯像素 RMSE 本身**，plan `:109` 把"anchor 像素对比"当硬门——codex 本轮已实证陷入 v39→v66 ~28 版微调死循环（RMSE 在 controls 区卡 0.16-0.18 下不去）。正解：像素门降级为**单向下限哨兵**（只判"是否明显逊于 anchor"，过线即停不追更低）+ **感知级 diff**（perceptualPrecision/Delta E，比像素快 90%+）+ **格式塔 5-gate**（层级/对齐/遮挡/可读/重量）判"好不好"。
2. **runtime 接线正解 = 单向不可变 snapshot + "一进两出"状态机**（GLM + Finder B 收敛，本调研对 MAformac 最 load-bearing）。MAformac `PresentationSnapshot` + `MockProvider` + `DemoRuntimeResultKind` 方向**完全正确**，接线路径清晰：① 中间态（ASR volatile 转写 / LLM token 流 / 思考链 `<think>`）走**旁路 effect 通道，绝不打进 snapshot**；最终结果（8 类结果枚举）才回 durable snapshot ② MockProvider 升级成**协议契约** `RuntimeProvider`，真实现隔离到 `@globalActor` 端侧引擎，**逐能力 strangler 切真**（不大爆炸）③ `DemoRuntimeResultKind` 用**冻结枚举 + 穷尽 switch 禁 default**，加结果类型时编译器强制所有消费点更新（= `derivation-layer-discipline` 铁律 1 的 Swift 编译期 enforce）。
3. **视觉质量验收必真机**（Finder C）：iOS26 Liquid Glass 镜面高光/动态响应 + Metal shader 在**模拟器根本不渲染/走软件翻译路径**。plan "模拟器验收/真机 DEFERRED" 分层方向对，但要明确：模拟器只能验**布局/逻辑/色值/`-forceVisualState` 截图**，**质感/GPU 帧率/玻璃光效 = 真机才可信**（这也是像素门反模式的另一根因——拿模拟器截图逐像素逼近，连真机长什么样都不知道）。
4. **工程内循环可大升级**（Finder A）：① **Inject/InjectionIII 热重载**（近实时反映代码改动，远胜慢且不稳的 `#Preview`，production 自动 NO-OP）② **preview-as-snapshot**（把 `DebugGallery.swift` force-state 升级成 Prefire/SnapshotPreviews 快照门，零重复代码，原型预览直接变视觉回归门）。
5. **negative space 维度**（plan 未覆盖，Finder D + GLM）：① **投屏可读性**（车机演示核心场景）有 arc-minute 量化法（文字占视野 15-20 弧分）+ ISO 15008 + CarPlay HIG，**设计阶段就能反推最小字号**，不必等截图 ② **多语言文字膨胀**（25+ 语言战场，非英语普遍 +30%、德语最狠、阿拉伯 RTL）有伪本地化早测 + String Catalog 编译期门 + `ViewThatFits`/`minimumScaleFactor` 防溢出三招 ③ **`performAccessibilityAudit(for:[.contrast,.textClipped])`**（iOS17+）可 CI 自动抓"投屏看不清"两大客观成因（对比不足 + 字被截）。

---

## 一、五维分层全景（整合 5 路）

```
设计系统层  Design Tokens(primitive→semantic→[component])   ← Style Dictionary 编译 / Figma Dev Mode MCP + Code Connect
视觉层      Layout/Type/Color/Material                       ← SwiftUI + .glassEffect(iOS26) / GlassEffectContainer
动效层      状态转移(withAnimation/phaseAnimator/matchedGeo) | 连续渲染(Canvas+TimelineView/Metal shader)  ← 两栈互斥,混用掉帧
互动层      Gesture(simultaneous/UIGestureRecognizerRep WWDC24) + Haptics(.sensoryFeedback / CoreHaptics)
层级层      ZStack+zIndex(同容器作用域) / overlay(无视zIndex) / compositingGroup(正确性) / drawingGroup(性能) / allowsHitTesting(false)
数据流层    Unidirectional State ← Snapshot ← Runtime         ← @Observable + async/await ★这层=与后端握手的接缝
```

**工程流程（Finder A）**：design token 实践只用两层（primitive+semantic）够，component 层 demo 别建（过度工程化）；token 以 Git 为 SSOT、Style Dictionary 编译成 Swift、CI 跑 + PR lint 防裸值绕过（= MAformac 已有 codegen-diff 门精神）。开发循环 = Inject 热重载 + preview-as-snapshot。模块化 = SPM feature module（接口/实现分离）+ Tuist 编排。pipeline 硬门：2026-04-28 起 App Store 强制 iOS26 SDK。

**动效双栈边界（Finder C，硬数字）**：`ForEach` 500 个 Circle = iPhone 13 上 **12 FPS**（单源实测，方向高可信）→ 大量元素必须直接在 `Canvas` 的 `GraphicsContext` 画，不用 ForEach of shapes。`drawingGroup()` 是"实测掉帧才用"（flatten 成单 CALayer，会破坏 per-layer 动画）；`compositingGroup()` 修 blend/opacity 正确性（子层独立）——二者别预防性加（都有离屏 pass 开销）。

---

## 二、🔴 对 MAformac 的 load-bearing 发现（按主题，每条标"挑战当前 plan 什么"）

### A. 视觉验收：像素门反模式（→ 待磊哥拍口径）
- **现状**：plan `:109` "anchor 像素对比 = 硬门（必须超过 anchor）"；codex 审计跑 `magick compare -metric RMSE` + `phase2_zone_compare.py`（纯像素）。
- **双源诊断**：RMSE 无法区分"大面积细微差（无感知）"vs"小面积剧烈差（真 bug）"——99.5% precision 会放过文字/颜色明显变化、却被无感知背景色变化卡红。像素法奖励 1:1 抄袭、惩罚创新，陷入微调死循环（本轮 28 版铁证）。
- **正解（三层分工）**：① 像素门 → **单向下限哨兵**（只判"明显塌否"，过线即停）② 感知级 diff（`swift-snapshot-testing` 的 `perceptualPrecision`，CIE94 Delta E，深色区表现差需下调）③ 格式塔 5-gate + 投屏 V10 判"好不好"。深色座舱主题注意感知 diff 深色 caveat。
- **流程**：锁渲染环境（pin simulator+OS+字体）+ mask 动态区（波形/orb/numericText/scope 角标）+ 基线审批作 PR gate（套现有"≥3 厂商终审 + subagent 仲裁"）。

### B. runtime 接线：mock→真的工程路径（→ DEFERRED 范围，但范式现在定）
- **"一进两出"状态机**（Finder B 最 load-bearing）：1 输入流（ViewSignal=触摸/语音/force）→ 2 输出（durable snapshot=最终 8 类结果 / 旁路 effect=流式中间态）。原则"分页失败不清屏、书签失败不重置列表"——**中间态不污染已渲染 snapshot**。
- **流式接 UI**：ASR `SpeechAnalyzer/SpeechTranscriber`(iOS26) 显式 `volatile` vs `final` 双态（`isFinal` 标志），天然映射"旁路 vs 回 snapshot"；LLM token 流 `AsyncThrowingStream` + `@MainActor @Observable`，yield 前过滤 `<think>` 分流思考链；进度类用 `.bufferingNewest(1)` 折叠。🔴 caveat：MAformac 锁系统 **SFSpeechRecognizer 主**（D14），SpeechAnalyzer 缺 Custom Vocabulary 但 MAformac 靠拼音 fuzzy/封闭词表/LoRA 音近不靠热词 → 影响小，volatile/final 范式哪个后端都适用。
- **契约 strangler**：drop OpenAPI/HTTP（runtime 是进程内引擎非网络后端），adopt"协议契约 + DI"内核——`protocol RuntimeProvider` 出 `AsyncThrowingStream<RuntimeEvent,RuntimeError>`，Mock 与真实现都 conform，逐能力切真，编译器强制契约一致（= A2 "incremental，大爆炸=红旗"）。
- **barge-in 坑**：AsyncStream 取消时**消费侧停但生产侧不自动停**——按钮打断要在引擎 actor 里 `Task.isCancelled` + 主动停 token 生成/释放 KV，别只取消消费侧。Swift 无原生 timeout → `TaskGroup` race `Task.sleep`。
- **状态架构**：保持 native `@Observable` MVVM，**不引入 TCA**（学习曲线 + 2 人维护的第三方依赖风险；MAformac 确定性已在更下层 DemoFlow/契约 SSOT 保证）。
- **参考案例（adopt 前必 clone 核）**：fullmoon-ios（纯 SwiftUI MLX chat 骨架）/ mlx-serve（显式 thinking-token 流式 UI，对应思考链 orb）/ Apple MLXChatExample（iOS+macOS 双端）。

### C. 视觉前沿：glass 采样约束 + 验收必真机（→ 强化 plan 玻璃分层 + 验收认知）
- 🔴 **"Glass 不能采样 Glass"**：多块玻璃必进 `GlassEffectContainer(spacing:)`（共享采样区 + 合并形状 + 启用 morph + 减冗余 pass），否则 artifact + 多余 GPU pass；morph 用 `glassEffectID` + `@Namespace`（物理形变非 fade）。玻璃**只给导航/控件层不给内容卡满屏**（每 row 玻璃 = 读不清 + GPU 过载失败模式）。
- 🔴 **验收必真机**：镜面高光/动态响应模拟器不渲染；Metal shader 模拟器走软件翻译不反映真机 GPU。必测 **Reduce Transparency + Reduce Motion** fallback（"开了该设置 app 崩 = 你做的是装饰不是 Liquid Glass"）。
- **氛围灯炸场最省路径** = iOS18 原生 `MeshGradient`（"渲染极快"）+ `TimelineView(.animation)` 动内部点（固定边缘点）；需能量爆发质感再上 `layerEffect` Metal shader（iOS18 `compile()` 预编译避首帧卡顿，uniform CPU 预算，`half4` 存色）；Vortex 现成快路（开发内循环够，极致性能 DEFERRED Canvas+Metal）。
- **capsule 2.5D diorama** = `visualEffect` + `rotation3DEffect(anchorZ:perspective:)`（深度 = Scale + 景深 Blur + 滞后 parallax offset 三连），**不要视频 loop**（占内存/不可交互/与态驱动割裂）；`shadow()` 放 `visualEffect` 块外。
- **orb 思考链路** = `layerEffect`（唯一能采样邻域做 blur/warp）+ `TimelineView` 喂时间戳，态切换用 shader uniform 不重建 view。

### D. 工程内循环升级（→ 纯收益，不碰生产代码）
- **Inject 热重载**：body 末 `.enableInjection()` + `@ObserveInjection var inject`（production NO-OP）。🔴 Xcode 16.3+/26 头号坑：先设 `EMIT_FRONTEND_COMMAND_LINES=YES` + `-Xlinker -interposable`（否则 "Could not locate compile command"）。远胜 `#Preview`（尤其 PresentationSnapshot 状态流转 + 联动动画时 #Preview 不可靠）。
- **preview-as-snapshot**：DebugGallery force-state（已有）→ Prefire/EmergeTools SnapshotPreviews 自动转 golden-image 快照测试，纳入 `make verify-all`——精确解决"gallery 内循环 vs 14 张 5-gate 验收"的二选一伪命题（gallery 内循环 + 快照做回归 + 5-gate 做审美）。先 non-blocking 引入防 flaky。
- **token pipeline**：design token 收两层 JSON SSOT → Style Dictionary 生成 `DesignTokens.swift` → 纳入 `make verify` codegen-diff 门（同 contracts 派生纪律）。

### E. negative space（→ plan 缺的维度，纳入哪些待拍）
- **投屏可读性**（车机演示核心，最该早验却最被忽略）：arc-minute 法（文字占视野 15-20 弧分）+ eye-to-display 60cm 时字号 ≥5.3-6mm + ISO15008 + CarPlay HIG（禁全大写/斜体、高对比应对烈日夜驾）→ 给团队可算的"投屏字够大否"硬数字，补进 5-gate 字体 gate。
- **多语言文字膨胀**（25+ 语言）：伪本地化早测（+30%+重音+RTL，单伪语言同测膨胀+RTL）+ String Catalog 编译期门（缺翻译 build error）+ SwiftUI 防溢出（角标/按钮 `.lineLimit(1).minimumScaleFactor` / 多行 `.fixedSize(h:false,v:true)` / 本地化最适 `ViewThatFits`；🔴 `fixedSize` 与 `minimumScaleFactor` 冲突别同贴）。真机测实际译文（Preview 比真机宽容）。
- **a11y/性能门**：`performAccessibilityAudit(for:[.contrast,.dynamicType,.textClipped])` CI 自动审；触控目标 iOS 用 44pt（比 WCAG 24px 严）；MetricKit 收线上 launch/hitch；adopt CVS Health `a11y-check`（36 规则/19 WCAG2.2/自带 SKILL.md 可入 ~/.claude/skills）。⚠️ Instruments 26 SwiftUI instrument 有静默不录 + Cause&Effect Graph 致内核 panic 的 2026 实测 bug，用前小范围验。
- **选型纠偏**：UI 自动化必须 **XCUITest**（Swift Testing 不做 UI 测）；交互元素显式 `.accessibilityIdentifier`（一次喂 XCUITest 稳定 + VoiceOver + audit 三处）。

---

## 三、核对账（claim-vs-reality / verify-external-claims）

| 声称 | 状态 |
|---|---|
| 🔴 finder D "MAformac 已用 swift-snapshot-testing" | **已证伪**（grep：实为 `phase2_zone_compare.py` PIL 纯像素 RMSE + magick compare）。但核心洞察反而**加强**——MAformac 当前门正是反模式本身。建议措辞改为"引入感知级 diff 替代现有纯像素 RMSE" |
| iOS26 glass API（glassEffect/glassEffectID/GlassEffectContainer）| 高可信（引 WWDC25 323 官方） |
| SpeechAnalyzer/SpeechTranscriber volatile/final（iOS26）| 高可信（引 WWDC25 277 + 官方文档） |
| MeshGradient(iOS18) / shader 三入口(iOS17+) / compile()(iOS18) | 高可信（官方文档 + WWDC） |
| perceptualPrecision（pointfree swift-snapshot-testing）| 高可信（pointfree 知名功能，CIE94 Delta E；PR#628 未亲核但功能真实存在） |
| Vortex star ~1543 | finder C 标"约/GitHub 实证"；adopt 前 `gh repo view` 核 pushedAt<60 天 |
| 500 shape=12FPS@iPhone13 / Tuist 77% 缓存 / METR 慢19% / Figma×Claude 2026-02 / drift-guard | 单源/二手，**未亲核**，作方向性论据非硬数字；驱动决策前核 |
| fullmoon-ios/mlx-serve 等参考 repo 活跃度+thinking-token 实现 | **未核**，blueprint-teardown 前必 clone 核实现，不凭二手 adopt |

---

## 四、给磊哥的决策弹药（grill 议题，每条带 plan 锚点）

1. **像素门口径**（plan `:109` + `phase2_zone_compare.py`）：anchor 像素 RMSE 硬门 → 降级为下限哨兵 + 感知级 diff + 5-gate 分层？（GLM H3 裁决"部分成立置信 82"+ Finder D 双证 + 本轮 28 版死循环铁证）
2. **runtime 接线范式**（DEFERRED 但范式现定）：定 `RuntimeProvider` 协议 + 一进两出（中间态旁路）+ 冻结枚举穷尽 switch？写进 A-1 bridge / spec 防后续接线返工？
3. **验收策略**：明确"模拟器验布局/逻辑/色值，真机验质感/GPU/玻璃光效"分层，避免逐像素逼近模拟器截图（连真机样子都不知道）？
4. **工程内循环**：引入 Inject 热重载（先扫 Xcode26 坑）+ DebugGallery→快照门？
5. **negative space 纳入**：投屏可读性 arc-minute 量化门 / 多语言文字膨胀 / a11y audit —— 哪些纳入 A-2，哪些 DEFERRED？

---

## Source（5 路 URL 汇总，按维度）
- **视觉/glass/动效**：WWDC25 [323](https://developer.apple.com/videos/play/wwdc2025/323/) glass / [306](https://developer.apple.com/videos/play/wwdc2025/306/) Instruments / WWDC26 [322](https://developer.apple.com/videos/play/wwdc2026/322/) shader / [MeshGradient 文档](https://developer.apple.com/documentation/swiftui/meshgradient) / [Inferno](https://github.com/twostraws/Inferno) / [Vortex](https://github.com/twostraws/Vortex) / [LiquidGlassReference](https://github.com/conorluddy/LiquidGlassReference)
- **runtime 握手**：[One AsyncStream In/One State Out](https://medium.com/@rohitagrawal1233/a-modern-swiftui-architecture-with-one-asyncstream-in-and-one-state-stream-out-5d86aaeffd75) / [SpeechAnalyzer WWDC25 277](https://developer.apple.com/videos/play/wwdc2025/277/) / [mlx-swift-lm](https://github.com/ml-explore/mlx-swift-lm) / [fullmoon-ios](https://github.com/mainframecomputer/fullmoon-ios) / [Swift OpenAPI Generator](https://www.swift.org/blog/introducing-swift-openapi-generator/) / [Task Cancellation (Majid)](https://swiftwithmajid.com/2025/02/11/task-cancellation-in-swift-concurrency/)
- **工程流程**：[Figma Dev Mode MCP](https://help.figma.com/hc/en-us/articles/32132100833559-Guide-to-the-Dev-Mode-MCP-Server) / [Style Dictionary→SwiftUI](https://www.swiftforjs.dev/blog/style-dictionary-colours-swiftui) / [Inject](https://github.com/krzysztofzablocki/Inject) / [PreviewSnapshots(DoorDash)](https://careersatdoordash.com/blog/how-to-speed-up-swiftui-development-and-testing-using-previewsnapshots/) / [Tuist](https://www.runway.team/blog/getting-started-with-tuist-for-xcode-project-generation-and-modularization-on-ios)
- **测试/验收/a11y/i18n**：[swift-snapshot-testing PR#628 perceptualPrecision](https://github.com/pointfreeco/swift-snapshot-testing/pull/628) / [performAccessibilityAudit](https://developer.apple.com/documentation/xctest/xcuiapplication/4191487-performaccessibilityaudit) / [CarPlay HIG](https://developer.apple.com/design/human-interface-guidelines/carplay) / [String Catalog](https://developer.apple.com/documentation/xcode/localizing-and-varying-text-with-a-string-catalog) / [CVS a11y-check](https://github.com/cvs-health/ios-swiftui-accessibility-techniques) / [Pseudolocalization](https://simplelocalize.io/blog/posts/pseudo-localization-guide/)
- **GLM probe（standard depth，本仓）**：`docs/research/probe-ios-frontend-interaction-runtime-handshake-20260626.md`

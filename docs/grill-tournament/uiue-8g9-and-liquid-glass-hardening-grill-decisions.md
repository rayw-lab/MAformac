---
type: uiue-8g9-and-liquid-glass-hardening-grill-decisions
status: CLOSED（U38-U45 已拍；8.G9a/8.G9b 已由后续 scoped implementation commits 落地；本文保留为决策/provenance 源）
date: 2026-06-27
owner: UIUE 链路 A（worktree MAformac-uiue, 分支 uiue/phase4-default-scope-presentation）
方法: grill-with-docs + grill-me interactive mode + repo/doc live probe + pre-mortem
编号: U38+（续 UIUE U 系列；挂 Q32/Q34/Q35/Q37/Q38）
关联:
  - docs/grill-tournament/GRILL-SYSTEM.md
  - docs/grill-tournament/grill-decisions-master.md
  - docs/grill-tournament/uiue-visual-gate-harden-grill-decisions.md
  - docs/grill-checklist/uiue-a2-grill-coverage-index.md
  - openspec/changes/ui-presentation/tasks.md
---

# UIUE 8.G9 拆包 + Liquid Glass hardening — grill decisions（U38+）

> 本档承接 U32-U37 视觉门 hardening 后的互动 grill。范围是 **决策/文档存档**，不是 Swift 实施；任何 `8.G9` 任务勾选、XCUITest target、Liquid Glass 代码改动都必须走后续 scoped plan。
>
> proof class：`docs` + `local repo-probe`。不得据此声明 `runtime` / `mobile` / `true_device` / `V-PASS`；A-2 总体验收仍保持 PARTIAL，`8.A/8.C2/6.4` 仍 open。

## 后续实施 provenance（2026-06-27）

- `4401f79 test(uiue): close 8g9a contracts and hardening`：闭合 `8.G9a` local/unit 范围（U14/U15/U16/U18/U44），不声明 `8.C2` / L3 / V-PASS。
- `780447c test(uiue): close 8g9b xcuitest l0 harness`：按 `docs/superpowers/plans/2026-06-27-uiue-8g9b-u17-xcuitest-l0.md` 闭合 `8.G9b/U17` simulator L0 smoke；receipt 为 `docs/research/2026-06-27-uiue-8g9b-u17-l0/README.md`。
- 本 provenance 收口不 amend `780447c`，只把 U38-U45 决策档与 8.G9b scoped plan 纳入可检索账本。

## 起手真态（2026-06-27）

- `openspec/changes/ui-presentation/tasks.md:154` 当前把 `8.G9` 写成一个未完成包：Mac AnyLayout 并排 / HTML+Preview 4 类反例 / iPhone 触觉 / snapshot+黄金路径 XCUITest / 客户物料不上架。
- `docs/grill-tournament/uiue-visual-gate-harden-grill-decisions.md:3` 记录 8.G1-G8 已落，8.G9 未落，8.C2/L3 仍 open；同档 `:18-19` 明确设计态不等于验收态，不得写成 V-PASS。
- `docs/grill-tournament/grill-decisions-master.md:145-149` 原 U14-U18 表仍列五项，`:178` banner 已把 U14-U18 作为活跃组拍定；所以本轮不是重投票，而是决定工程拆法和证据边界。
- U14 并非空白：`App/ContentView.swift:136-150` 已有 Mac 宽窗 `AnyLayout(HStackLayout)` + `VehicleCardsGrid(... layout: .macPanorama)`；`App/ContentView.swift:634-639` 以 macOS 宽度断点启用；`App/ContentView.swift:1575-1578` 用 `Grid + GridRow`。
- U17 风险明显更高：`MAformac.xcodeproj/project.pbxproj:78-128` 仅有 `MAformacMac` / `MAformacIOS` 两个 app target；未发现现成 UI test target。当前 `Tests/MAformacCoreTests/DemoExperienceAcceptanceScaffoldTests.swift:3-14` 只是 runnable scaffold skip，不是 XCUITest/golden path。

## 调研吸收（research_not_ssot）

- 新增前端趋势调研 `docs/research/2026-06-26-ios2026-frontend-trends-migration/INDEX.md:30-31` 自标 `research_not_ssot`；它是输入，不是决策源。
- 该调研核心结论不是“前端迁移”：`docs/research/2026-06-26-ios2026-frontend-trends-migration/README.md:24-31` 认为 UIUE 已在 SwiftUI/iOS26 前沿，真正 actionable 是对已落地 Liquid Glass 做 hardening，并把 iOS27 新 API Watch/Reject。
- 其投屏建议 `docs/research/2026-06-26-ios2026-frontend-trends-migration/README.md:117-118` 被本项目 C0/U23/U24 supersede：`docs/grill-tournament/grill-decisions-master.md:154-155` 已删除投屏维度；本轮吸收 GlassEffectContainer、低亮度/Reduce Transparency/版本锁等 hardening 输入，不把投屏拉回验收门。
- 旧 UIUE 10 族调研 `docs/research/2026-06-23-uiue-10family-presentation/README.md:1-8` 已收敛到全景常驻骨架 + 语音触发聚焦；`docs/research/2026-06-23-uiue-10family-presentation/README.md:69-78` 明确从旧 4 卡平铺重构为 10 族 family_card、7 态映射和值控件分发。
- iOS26/D7 pre-mortem `docs/research/2026-06-24-ios26-lock-d7-premortem/README.md:13-23` 确认 Liquid Glass 官方边界和 transient 控件例外；`:46-54` 确认 `.glassEffect()` 是 iOS26/macOS26，锁最新设备无需版本守卫，但 `navigationTransition.zoom` 需平台守卫。
- 竖屏交互调研 `docs/research/2026-06-25-portrait-interaction/README.md:20-35` 承接 D1-D8/E0-E8，结论是零推翻；`:38-48` 把固定三 zone、全景 idle、活跃族原地放大和 ScrollViewReader 放到 Phase 5/后续，而不是要求重开 8.G9。
- context capsule 技术调研 `docs/research/2026-06-25-context-capsule-2.5d-tech/README.md:1-8` 把 capsule 定位为 A 视频 loop vs C-lite 的后续真机 spike；`:70-82` 记录 U30 GPU 约束下重 shader 是 tiger，C-lite 或视频 loop 才是合理候选。它支持 Liquid Glass hardening 需要单独 spike，不支持把 8.G9 拖成大重构。

## U38 — 8.G9 拆包，不把 U17 拖住 U14/U15/U16/U18

**结论（磊哥 2026-06-27 拍）**：`8.G9` 拆成低风险项 + U17 单独小计划。

- `8.G9a`：先闭合 U14/U15/U16/U18 的低风险工程/契约项。U14 以已落地 AnyLayout/Grid 真态为前提，优先补契约/测试/receipt；U15/U18 以 fixture/checklist/README/contract 方式防漂移；U16 仅限 iPhone 加分、Mac no-op，不为触觉扩大 runtime 边界。
- `8.G9b` 或独立 scoped plan：U17 `snapshot + 黄金路径 XCUITest` 单独处理。原因是当前无 UI test target，直接做会触碰 Xcode project、launch args、golden path、L0-L3 证据边界，风险高于其他四项。
- 仍 amend 现有 `ui-presentation` change，不新建第二套 OpenSpec SSOT；`docs/grill-tournament/uiue-visual-gate-harden-grill-decisions.md:101-112` 已定 `8.G` 落在同一个 change 内。

**反方观点 / 隐藏假设**

- 反方：U14-U18 已被 `docs/grill-tournament/grill-decisions-master.md:178` banner 一把过拍定，继续一包做能减少任务碎片。
- 隐藏假设：同一行 `8.G9` 内五项风险相同。repo 真态反证：U14 已有实现骨架，U17 缺 UI test target，风险不是一个量级。

**pre-mortem**

- tiger：U17 需要 UI test target/launch args/golden path 入口，可能拖住 U14/U15/U16/U18，导致 8.G9 长期 open。
- paper-tiger：拆包不是推翻 “ABC 揉一个 `ui-presentation` change”；只是同一 change 内的实施分层，避免 false green。
- elephant：若不拆，后续 agent 容易用 unit/local 或 SwiftUI preview/snapshot 冒充 XCUITest/golden path；这会撞 `openspec/changes/ui-presentation/specs/ui-presentation/spec.md:252-261` 的 L0 on-screen runtime-truth 规则。

**physical landing**

- 决策存档：本档 U38 + `docs/grill-tournament/grill-decisions-master.md` U38 索引 + `docs/grill-checklist/uiue-a2-grill-coverage-index.md` canonical input。
- 后续实施计划：更新或新增 scoped plan，将 `8.G9a` 与 `8.G9b/U17` 分开；只有实施通过后才能改 `openspec/changes/ui-presentation/tasks.md:154`，不能在本 grill 存档中勾选。
- U17 计划必须显式声明：是否创建 UI test target、golden path launch args、最小截图/L0 证据、以及哪些仍只是 local/unit。

**proof boundary**

- 当前 proof class：`docs` + `local repo-probe`。
- 不得升级为 `runtime` / `simulator L0` / `mobile` / `true_device` / `V-PASS`。
- 不得关闭 `8.C2` 或 A-2 总体验收；`docs/grill-tournament/uiue-visual-gate-harden-grill-decisions.md:18-19` 的 PARTIAL 边界继续有效。

## U39 — U17 拆成入口契约（U17a）与最小 XCUITest/L0 证据（U17b）

**结论（磊哥 2026-06-27 拍）**：U17 拆成 `U17a` / `U17b`，但 `U17b` 不允许无限 deferred。

- `U17a`：冻结已有入口与黄金路径契约，只做 `golden_path_manifest` / existing launch args contract / unit matrix。入口包括已有 `-mockSnapshot`、`-forceVisualState`，以及新增或明确的 `golden_path_id` 映射。它证明“黄金路径可被稳定选择和枚举”，不证明 UI 自动化或 L0 截图。
- `U17b`：单独建 UI test target + 最小黄金路径 XCUITest + on-screen `simctl io screenshot` L0 截图包。它证明最小 UI smoke 和 L0 runtime-truth，但仍不等于 L3/V-PASS。
- `8.G9` 不因 `U17a` 单测变绿而整体勾选；最多允许 `8.G9a` 关闭 U14/U15/U16/U18 低风险项。U17b 必须进入后续 scoped plan，并给出不无限延期的 owner/stop gate。

**证据**

- `openspec/changes/ui-presentation/tasks.md:154` 仍把 `8.G9` 写成一行混包。
- `MAformac.xcodeproj/project.pbxproj:78-128` 只有 `MAformacMac` / `MAformacIOS` 两个 app target，未见 UI test target。
- `Tests/MAformacCoreTests/DemoExperienceAcceptanceScaffoldTests.swift:3-14` 只是 `XCTSkip` acceptance scaffold，不是 XCUITest/golden path。
- `docs/research/2026-06-26-ios2026-frontend-trends-migration/README.md:24-31` 支持“UIUE 不是迁移命题，真正要做 hardening”。
- `docs/research/2026-06-26-ios-frontend-interaction-runtime-synthesis.md:73` 明确 UI 自动化必须 XCUITest，Swift Testing 不做 UI 测，交互元素需稳定 `.accessibilityIdentifier`。

**反方观点 / 隐藏假设**

- 反方：U17 原文就是 `snapshot + 黄金路径 XCUITest`，如果现在只做 U17a，可能继续拖真正的现场防炸场自动化。
- 隐藏假设：所有黄金路径证据必须一次性落完才有价值。这个假设不成立；入口契约先稳定，可以减少后续 XCUITest target 引入时的不确定性，但它不能替代 XCUITest。

**pre-mortem**

- tiger：SwiftPM/unit 或 manifest 绿后，被误写成“U17 已闭合 / 黄金路径 XCUITest 已闭合”。
- paper-tiger：U17a 不是降级；它是给 U17b 准备稳定启动入口和 case 枚举，减少 UI test target 引入时的漂移。
- elephant：U17b 若没有明确 stop gate，会被“单独小计划”包装成无限 deferred，最后 8.G9a 绿但 UI smoke 长期缺席。

**physical landing**

- `U17a` 后续实施形态：`golden_path_manifest`（可为 docs/OpenSpec 或 Core presentation test fixture）+ existing launch args contract（`-mockSnapshot` / `-forceVisualState` / `golden_path_id`）+ 单测矩阵，锁住每条 golden path 的 snapshot/result/readback/proof intent。
- `U17b` 后续实施形态：Xcode UI test target + 最小 XCUITest smoke + stable `.accessibilityIdentifier` + on-screen `simctl io screenshot` L0 evidence package。
- `openspec/changes/ui-presentation/tasks.md:154` 不因 U17a 单测绿而勾选；若拆出 `8.G9a/8.G9b`，`8.G9b` 必须保留 open 直到 U17b 证据到位。

**proof boundary**

- `U17a` proof class：`docs` + `local` + `unit`。
- `U17b` proof class：`simulator` + L0 runtime-truth（on-screen `simctl io screenshot`），仍不是 `mobile` / `true_device` / `V-PASS`。
- 任何 SwiftPM/unit、SwiftUI preview、off-screen snapshot 都不得冒充 XCUITest 或 L0。

## U40 — U14 不继续改 Mac 布局本体，只补契约/测试/receipt

**结论（磊哥 2026-06-27 拍）**：U14 不继续改 Mac 布局本体；只补契约、测试和 receipt。

- 现态已经满足 U14 的核心实现形态：`App/ContentView.swift:136-150` 走 `stageBody -> usesMacSplit -> AnyLayout(HStackLayout)` 并将 `VehicleCardsGrid` 切到 `.macPanorama`；`App/ContentView.swift:634-639` 用 macOS 宽度断点 `size.width >= 820`；`App/ContentView.swift:1575-1578` 使用 `Grid + GridRow`。
- `docs/research/2026-06-26-ios2026-frontend-trends-migration/README.md:24-29` 支持“UIUE 已经较前沿，不是迁移命题”；U14 要做的是固化已有前沿形态，不是再重构。
- gate 必须收窄：不能全仓禁 `sizeClass`。`App/ContentView.swift:1406-1419` 仍在非 macOS `phoneScroll` 分支用 `horizontalSizeClass`，这是当前 iPhone 列数逻辑；U14 只禁止 **Mac split path** 由 `sizeClass` 驱动。

**U14 gate（后续实施的机械约束）**

- Mac split path 必须保留 `stageBody -> usesMacSplit(size:) -> AnyLayout(HStackLayout) -> VehicleCardsGrid(layout: .macPanorama)`。
- `usesMacSplit` 必须由 macOS 宽度断点或等价 `GeometryReader size` 驱动，不得由 `horizontalSizeClass` 驱动。
- 不得引入 `NavigationSplitView` / `SplitView` 作为 U14 解法；U14 原结论是 AnyLayout 并排，不用 SplitView。
- 车辆卡片网格不得回退到 adaptive `LazyVGrid`；Mac panorama 和当前 compact grid 都必须继续走 `Grid + GridRow` 或等价固定列策略。
- 允许保留非 macOS `phoneScroll` 的 `horizontalSizeClass` 列数逻辑；该逻辑不属于 U14 Mac split 禁线。

**反方观点 / 隐藏假设**

- 反方：当前实现只是“有并排”，未必代表 Mac 宽窗体验已经高级；极宽/窄窗口仍可能露出视觉缺口。
- 隐藏假设：既然有视觉缺口风险，就应继续改布局本体。这个假设过强；U14 的 scope 是锁“并排策略和禁 SplitView”，视觉高级感应由 L0-L3/8.C2 或后续 layout polish 验，不应把 U14 拉成大重构。

**pre-mortem**

- tiger：继续改 Mac 布局本体会重开 Phase 5 三 zone / ScrollViewReader / Mac polish，把 8.G9a 拖成视觉重构。
- paper-tiger：只补 contract/test/receipt 不是降级；实现骨架已存在，当前缺的是防回退约束。
- elephant：如果 gate 写成全仓禁 `sizeClass`，会误伤 iPhone `phoneScroll` 现有列数逻辑，制造无谓返工。

**physical landing**

- 后续实施形态：新增 `U14MacLayoutContractTests`，覆盖 Mac split contract 的结构性入口；新增一个本地 grep/check 脚本，锁禁 `NavigationSplitView` / adaptive `LazyVGrid` / Mac split path 由 sizeClass 驱动；写 U40 receipt。
- 不继续改 `App/ContentView.swift` 布局本体，除非后续 L0-L3 或人工 5-gate 发现具体缺口并另开 layout polish。
- `openspec/changes/ui-presentation/tasks.md:154` 不因 U40 文档存档而勾选；只有后续 scoped implementation 跑过测试/检查后，才能计入 `8.G9a`。

**proof boundary**

- proof class：`docs` + `local repo-probe`；后续测试实现可升到 `unit/local`。
- 不关 `8.C2`，不声明 Mac runtime、simulator L0、mobile、true_device 或 V-PASS。

## U41 — U15 反例以 Preview/DebugGallery 为主入口，HTML 只做同 fixture 静态镜像

**结论（磊哥 2026-06-27 拍）**：U15 的主可见入口必须是 Preview / DebugGallery；HTML 只能是同 fixture 的静态镜像，不是第二套演示 UI。

- U15 的证明对象不是“HTML 页面”，而是“反例场景能否从同一 snapshot/matrix 被 SwiftUI 呈现”。
- 主链已有 `DemoRuntimeResultKind.allCases -> entry(for:)` 8 态 presentation matrix：`Core/Presentation/DemoRuntimeResultPresentationMatrix.swift:23-29`；测试已锁无 default fallback：`Tests/MAformacCoreTests/DemoRuntimeResultPresentationMatrixTests.swift:42-48`。
- `PresentationSnapshot` 已是一进容器，含 `dialogText` / `readbacks` / `resultKind` / `proofClass`：`Core/Presentation/PresentationSnapshot.swift:59-71`。
- 历史 HTML 是 C5 未冻结前的低保真并行层，且原文明确“不碰代码”：`docs/c5-recovery-2026-06-22/roadmap.md:89-93`。现在 UIUE 树已是 SwiftUI 前沿，缺口是 hardening 而非再造 HTML 主路径：`docs/research/2026-06-26-ios2026-frontend-trends-migration/README.md:24-29`。
- spec 已锁 UIUE 是 mock 前台，不接真 NLU/ASR/TTS/LoRA/runtime backend：`openspec/changes/ui-presentation/specs/ui-presentation/spec.md:206-214`。

**四类 customer-visible 反例**

- `clarifyMissingSlot`
- `refusalNoAvailableTool`
- `refusalSafetyOrPolicy`
- `partialAcceptPartialRefuse`

`alreadyStateNoop` / `runtimeError` / `cancelledByUser` 继续由 8 态矩阵覆盖，不硬塞进 U15 “四类”；否则 U15 会膨胀成 8 态全演示。

**反方观点 / 隐藏假设**

- 反方：U15 原文写“HTML/Preview 都补 4 类反例”，HTML 若只做静态镜像，是否弱化了原拍板。
- 隐藏假设：“HTML/Preview 都补”意味着 HTML 和 SwiftUI 各自实现一套逻辑。这个假设应纠偏；HTML 只能引用同名 fixture/id，不能拥有独立状态机、独立视觉判断或独立文案。

**pre-mortem**

- tiger：HTML 被做成第二套演示 UI，与 `PresentationSnapshot` / matrix 分叉，后续 SwiftUI 已修但 HTML 仍展示旧反例。
- paper-tiger：不接真 NLU/ASR/TTS/LoRA 不是降级；U15 验的是 presentation 反例可见性，不是真后端推理。
- elephant：把 already/runtime/cancelled 硬塞进“四类”会把 U15 膨胀成 8 态全演示，拖住 8.G9a。

**physical landing**

- 后续实施形态：新增 `U15CounterexampleFixtures`，每条含 `id` / `resultKind` / `snapshot` / `dialogText` / `proofIntent`。
- `DebugGallery` 增 `CounterexampleGallery` + Preview，消费这些 `PresentationSnapshot`；这是主可见入口。
- HTML 若保留，只能落 `prototypes/u15-counterexamples.html` 这类静态索引/说明，数据来自同一 fixture 或手动列同名 id；禁止写独立状态机、独立视觉判断、独立文案。
- 单测锁：每个 fixture 覆盖 `DemoRuntimeResultPresentationMatrix`，无 default；`alreadyStateNoop` / `runtimeError` / `cancelledByUser` 仍由 8 态矩阵测试覆盖。

**proof boundary**

- proof class：`docs` + `local` + `unit` + `staticPreview`。
- 不升级为 `runtime` / L0 / `mobile` / `true_device` / `V-PASS`。

## U42 — U16 加 iOS-only 触觉 policy，Mac 永远 no-op，不做真机触觉验收门

**结论（磊哥 2026-06-27 拍）**：加 iOS-only 触觉 policy，但不做 true-device haptic acceptance gate。

- U16 已拍 “iPhone 加分、Mac 不做”；现在最合适的是小 policy 锁边界，而不是接入真机验收门。
- iOS 用户动作触发 haptic intent；macOS 永远 `.none`。
- 触觉只能是辅助反馈，不能成为唯一反馈；视觉/数值/图标/文案仍是主通道。
- mock / force-state / voice 自动刷新不得凭空震动，避免后台状态切换制造虚假触觉。
- `openspec/changes/ui-presentation/design.md:130` 已把 sensoryFeedback 定位为仅 iPhone 真机、Mac/iPad 静默且靠双通道承载；本 U42 把它收窄成可测试 policy。

**interaction source 边界**

- `interactionSource == .userTouch` 才允许 `.selection` / `.success` / `.impactSoft` 等 haptic intent。
- `interactionSource == .mock` / `.forceState` / `.voice` / `.snapshotRefresh` 必须返回 `.none`。
- macOS 分支必须返回 `.none`，不得引入触觉 API 或 build-time 条件污染。

**pre-mortem**

- tiger：Mac 也触发 haptic API，或 mock/force-state 刷新导致凭空震动。
- paper-tiger：没有 true-device haptic proof 就不能写 policy。实际本轮只需 `docs/local/unit` 证明边界，不声明手感。
- elephant：触觉若成为唯一反馈，Reduce Motion/辅助功能/设备不可用时会丢状态语义。

**physical landing**

- 后续实施形态：新增 `PresentationHapticPolicy` + `U16HapticPolicyTests`。
- policy 输出 haptic intent，不直接等同硬件震动通过。
- App 接入时必须仍以颜色/数值/图标/文案表达状态；haptic 只做 optional sensory feedback。

**proof boundary**

- proof class：`docs` + `local` + `unit`。
- 不声明 `true_device` haptic pass，不关 `8.C2` / `V-PASS`。

## U43 — U18 降为自用 demo 分发边界护栏，不做 release-governance 大件

**结论（磊哥 2026-06-27 拍）**：U18 不做 release checklist / customer showcase checklist；只做轻量 distribution boundary guard。

- 当前分发边界：`personal/internal self-use only`。
- 禁止：App Store、TestFlight、external customer package、release readiness claim。
- 不生成：App Store screenshots、privacy nutrition、store description、release notes、customer-facing claims。
- 这不是降级，而是更准确：目前不会对外发，也不是 App Store/TestFlight/客户交付包；做 release-governance 三层大件会过度工程化，并暗示项目进入对外包装阶段。

**反方观点 / 隐藏假设**

- 反方：U18 原文“客户展示物料不上架”，是否至少要 customer checklist。
- 隐藏假设：不上架也等于正在准备对外客户物料。磊哥已修正当前是自用/内部跑，故 U18 目标是防 fake scope，不是管理 release。

**pre-mortem**

- tiger：后续 agent 误做 App Store/TestFlight/对外材料，或把 mock-frontstage 包装成 release-ready。
- paper-tiger：因为不上架，所以完全不用记录边界。实际仍需一句硬边界防 scope creep。
- elephant：客户展示 checklist 会反向制造“对外包装阶段”暗示，诱导更多 release 物料。

**physical landing**

- 本档记录分发边界。
- `openspec/changes/ui-presentation/tasks.md` 加一句轻量 non-goal/task note：`U18 closes by documenting no-submission/no-release boundary; no App Store assets are produced.`
- 不新增 `docs/demo-customer-showcase-checklist.md`，除非后续真的准备客户现场材料。
- 后续 implementation prompt 必须写禁线：不得生成 App Store screenshots / privacy nutrition / store description / release notes / customer-facing claims。

**proof boundary**

- proof class：`docs` + `local`。
- 不声明 release readiness、external/customer acceptance、App Store/TestFlight readiness。

## U44 — 新增不含投屏的 Liquid Glass hardening spike

**结论（磊哥 2026-06-27 拍）**：新增 Liquid Glass hardening spike，但严格不把投屏拉回来。

- 现有 glass 点位少，适合 hardening，不适合重构：`App/ContentView.swift:974` MicDock、`App/ContextCapsule.swift:67`、`App/DemoControlPanel.swift:315`。
- 吸收新 iOS2026 调研的方向：UIUE 不是迁移命题，缺口是 hardening；但 `docs/research/2026-06-26-ios2026-frontend-trends-migration/README.md:117-118` 的投屏建议被 C0/U23/U24 删除，不进入 U44。
- 内容卡继续禁 `.glassEffect()`，保持 `App/ExpandedFamilyCard.swift:5` 的 content_glow 边界。

**hardening scope**

- 建 glass inventory：MicDock / ContextCapsule / DemoControlPanel 三处 `.glassEffect()`。
- 检查是否需要 `GlassEffectContainer`，但 **不一刀切强制**。只有同层多个 glass siblings、性能/一致性证据成立，或具体视觉/性能问题被证实时才加。
- 检查 Reduce Transparency fallback、低亮/对比度、iOS 26.x 行为锁。
- 内容卡继续禁 `.glassEffect()`；禁止把 glass 铺到卡背或全局主题。
- 不做投屏/AirPlay/1080p 外屏验收，不重开 U23/U24。

**pre-mortem**

- tiger：hardening spike 偷偷变成前端迁移、视觉重构或投屏验收回流。
- paper-tiger：UIUE 已前沿，所以 glass 不用管。实际 `.glassEffect()` 点位虽少，但 reduce transparency/低亮/版本行为仍需边界。
- elephant：`GlassEffectContainer` 一刀切可能破坏已稳定的少量裸点，或引入 iOS 26.x 行为差异。

**physical landing**

- 后续实施形态：`LiquidGlassHardeningPlan` / inventory + 轻量 policy/tests；必要时加 `GlassEffectPolicy` 或 fallback tests。
- 先不新 OpenSpec change，继续 amend `ui-presentation`；只有后续变成新的行为 requirement 时再升级 spec/design。
- 不碰投屏，不声明 L0/L3 视觉通过。

**proof boundary**

- proof class：`docs` + `local` + `unit` + `staticPreview`。
- 无 L0/L3 前不得写 visual pass；不升级为 `runtime` / `mobile` / `true_device` / `V-PASS`。

## U45 — 单一 U38+ 决策源收口，产 scoped implementation prompt 防假绿

**结论（磊哥 2026-06-27 拍）**：继续同一个 U38+ 文档，不新第二 SSOT，也不新 Q。

- U42-U44 追加进本档；`grill-decisions-master.md` 只加索引行；coverage index 继续指向 U38+。
- U44 先不新 OpenSpec change，除非后续变成新的行为 requirement。
- 文档存档不等于 `8.G9` 完成，不关 `8.C2` / `V-PASS`。
- 必须产 scoped implementation prompt：`8.G9a` 做 U14/U15/U16/U18 + U44 轻量 hardening；`8.G9b` 单独做 U17 XCUITest/L0。

**pre-mortem**

- tiger：多文档、多 master 或新 Q 分叉，后续 agent 不知道哪个是 SSOT。
- paper-tiger：新增 U 号不等于扩大实现 scope；实现仍要 scoped plan。
- elephant：不产 implementation prompt，后续 agent 可能把 docs 决策当作任务完成，或把 U17a/unit 绿写成 U17b/L0 绿。

**physical landing**

- 本档作为 U38-U45 一手决策源。
- `docs/grill-tournament/grill-decisions-master.md` 挂 U42-U45 索引。
- `docs/grill-checklist/uiue-a2-grill-coverage-index.md` 继续通过 U38+ 文档覆盖本组，不新 tracking SSOT。
- 最终输出 paste-ready implementation prompt 给主控窗口。

**proof boundary**

- proof class：`docs`。
- 不关 `8.G9`、`8.C2`、A-2、V-PASS。

## Open Questions（继续 grill）

- 本批 U38-U45 已拍完。下一步不继续 grill，转 scoped implementation prompt / plan。

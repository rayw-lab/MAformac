<!--
PROPOSE-ACTIVE (2026-06-24, 磊哥拍 B 严格 OpenSpec·文档先行防返工) — proposal/design/tasks/spec 已填实(5 Req/29 Scenario, validate 绿)。锁 iOS26/macOS26(那轮拍 A, pre-mortem 坐实)。
依赖序：本 change = UIUE 前端，依赖 migrate-d-domain([1] A2 已并 main PR#3) 但不依赖 LoRA 训练。
apply 状态: Phase 1b ✅done / Phase 3 D7 已 apply(commit 6a3e3f9 追认) / Phase 4 契约文档先行, 代码 apply 待后端 default_scope 落 main。
incremental（每 Phase 一个小 PR），禁大爆炸。Phase 映射见 docs/uiue-roadmap-2026-06-23.md。
锁 iOS26 决策 + pre-mortem 一手见 docs/research/2026-06-24-ios26-lock-d7-premortem/。
-->

## 1. 前置依赖

- [ ] 1.1 确认 A2（`migrate-d-domain-tool-surface`）已并 main（✅ PR#3 fd2220b）/ UIUE worktree rebase main 拿 A2 产物（`generated/family-device-allowlist.json` / state-cells 10 族）。**仅 Phase 4 需要**（Phase 1b/3 不依赖）。
- [ ] 1.3 🔴 **新交汇契约 `default_scope`（G25，磊哥拍字段名）**：后端 state-cells.yaml 每个有 scope 的 cell 加 `default_scope` 字段（C3/Compiler/C6/C5 + UIUE 全派生单一 SSOT）→ UIUE rebase main 拿到后**读 `default_scope`** 渲染默认 scope 卡片（G28）。✅ change 归属拍：**独立 `define-demo-default-scope` change**（G24，default_scope 跨多方依赖单一职责）。**仅 Phase 4 卡片需要**（G22：UIUE 不进后端 blocker）。
- [x] 1.2 视觉 SSOT 三件套已落（`docs/design/{tokens.md,hig-liquid-glass-rules.md,INDEX.md}`，base #121212）✅ done。

## 2. 工程前置硬门（Phase 1b，U6 demo-blocker，❌不依赖 A2）

- [x] 2.1 麦克风 + 语音识别权限串 ✅ done（2026-06-24）：4 build config `GENERATE_INFOPLIST_FILE=YES` → `INFOPLIST_KEY_NSMicrophoneUsageDescription` + `INFOPLIST_KEY_NSSpeechRecognitionUsageDescription`（非物理 Info.plist；plutil OK + xcodebuild BUILD SUCCEEDED）。
- [x] 2.2 **App target deployment 锁 iOS26/macOS26** ✅ done（2026-06-24）：pbxproj 4 config IPHONEOS=26.0 / MACOSX=26.0；**Package.swift 留 `.iOS(.v17)/.macOS(.v14)` 不动**（Core/CLI portable，加强3 隔离）。**isolation spike receipt**（一次性验，非 pre-commit，[[precommit-triage-recurring-vs-spike]]）：`xcodebuild -showBuildSettings -scheme MAformacIOS|grep IPHONEOS_DEPLOYMENT_TARGET`=26.0 / `-scheme MAformacMac|grep MACOSX_`=26.0 / Package.swift=v17/v14。pre-mortem 坐实 Xcode26 SPM thread 81601 是 deprecation 警告非声明改写=paper-tiger，隔离安全；🔴 **别在 Core Package.swift 塞全局 warnings-as-errors**（swift#84379/spm#9517）。
- [ ] 2.3 entitlements（`increased-memory-limit`）**DEFERRED → 模型集成时**（iOS jetsam 要它，但模型未集成 + CODE_SIGN_ENTITLEMENTS 需 provisioning，现加引签名风险）。
- [ ] 2.4 `Availability.swift` **锁 iOS26 后版本守卫不需要**（MeshGradient iOS18/glassEffect iOS26/matchedGeometry iOS14 均 ≤ deployment 26）→ 仅封装 **平台守卫**（`navigationTransition.zoom` 用 `#if !os(macOS)`）+ **ReduceMotion/低电量双通道**（a11y 非版本）。随 Phase 3 用到时建。
- [x] 2.5 截图管线 ✅ done（D7 建 gallery+force-state simctl）—— （替代旧 snapshot baseline）：🔴 **ImageRenderer 不可用**（截不出 Liquid Glass/material/blur，Apple 官方：Core Animation 合成不进 raster，oracle4 坐实）→ 用 `simctl` 启动整 app 截图。分层（磊哥拍 ①）：**(a) `#if DEBUG` 7 态 gallery 视图**（一屏 7 态，D7 内循环用，simctl 截 2 张/端快速 iterate）+ **(b) `#if DEBUG` force-state URL scheme**（`maformac://debug/force-state/<态>`）→ `simctl openurl` 一行一态，**14 张满屏单态（mac7+iOS7）供 5-gate 验收**。
- [x] 2.6 🔴 **补强1 pre-commit gate `Tools/checks/check-no-binary-visualstate.sh`** ✅ 建好未启用（启用时机=3.6 D7 改完后）。
- [x] 2.7 🔴 **加强2 pre-commit gate `Tools/checks/check-platform-vs-version-guard.sh`**（建，反复违反风险 [[precommit-triage-recurring-vs-spike]]）：`git grep -nE '#available\(iOS (17|18)' -- 'App/'` 命中即 exit 1（锁 iOS26 后不该有版本守卫）；白名单允许 `#if !os(macOS)` / `if reduceMotion` / `isReduceMotionEnabled`（a11y/平台非版本）。同 2.6 暂不启用 hooksPath，并入 3.6 启用。
- [x] 2.8 🔴 **补强3 tokens §2 语义分类审签冻结** ✅ 2026-06-24 磊哥审签（琥珀=clarify/灰锁=unsupported/红=safety/中性灰=crash），`tokens.md:3` 语义分类 FROZEN v1.0；hex 仍 DRAFT，Phase 3 实渲后复核（3.7）。

## 3. ui-presentation capability — 状态消费（Phase 3，🔴 D7 头号刀 ✅已 apply commit 6a3e3f9；force-state launch arg 同批次）

- [x] 3.0 ✅apply(6a3e3f9) `App/DesignTokens.swift`：Swift 镜像 tokens.md（色/字/动效 token + 7 态 `CardAppearance` 穷尽 switch），view 只从此取（禁手填 hex，spec R4）。
- [x] 3.1 ✅apply `ContentView` 绿/灰二值（`:122/:126`）→ `DemoVisualState` 7 态穷尽 `@ViewBuilder switch`（spec R1，无 default 兜底）。
- [x] 3.2 ✅apply 四态分开（clarify 琥珀 / unsupported 灰锁 / safety 红 / crash 中性灰），色值从 `DesignTokens`（镜像 tokens.md §2）。
- [x] 3.3 ✅apply 消费 trace `guardReason`/`readbackResult`（spec R1；`Core/Trace/TraceLogger.swift:37-38` 已有字段）。
- [x] 3.4 ✅apply `#if DEBUG` 7 态 gallery 视图（2.5a）+ force-state **launch argument**（`-forceVisualState <态>`，ProcessInfo.arguments）—— 🔴 修正：实现用 launch arg 非 URL scheme（GENERATE_INFOPLIST_FILE=YES 下 CFBundleURLTypes 难设，launch arg 同目的更简，App/DebugGallery.swift）。
- [ ] 3.5 `Availability.swift`（2.4）随本 Phase zoom/ReduceMotion 用到时建（仅平台守卫+a11y，无版本守卫）。
- [ ] 3.6 🔴 **启用 pre-commit gate**（2.6+2.7）：D7 改完（ContentView 无 binary + 无 `#available(iOS17/18)`）→ `git config core.hooksPath .githooks` + 验两脚本绿 + 故意写回各验 exit 1。
- [ ] 3.7 5-gate 验收 + hex 冻结：simctl 出 14 张满屏单态 → 磊哥审美 5 gate（任一态 FAIL=返工非小瑕疵）→ hex DRAFT→FROZEN（2.8 留尾）。

## 4. 卡片渲染（Phase 4，部分依赖 A2 产物）

- [ ] 4.1 🔴 **补强2 ui_value_type 消费侧派生**（spec R2）：`App/Rendering/UIValueTypeMapper.swift`，`func uiValueType(for cell: DemoVehicleStateCell) -> UIValueType` 从 `cell.key` 派生（无 type/values/unit 字段，那是 yaml producer）；`enum UIValueType { dial, toggle, stepper, percent, badge }`；**不写回 state-cells.yaml、不给 Core struct 加字段**。key→UIValueType 映射表（10 族）+ 单测。
- [ ] 4.2 `ContentView` 卡片值 `enum + switch(ui_value_type)` 穷尽渲染（非 AnyView，spec R2）+ FamilyCardLayout 按 10 族 family_card_id。
- [ ] 4.3 `Grid` 固定列（非 LazyVGrid.adaptive，C22，spec R3）。
- [ ] 4.4 卡片高频排序用 family-device-allowlist `row_count`（C8 复议#7，spec R2）。
- [ ] 4.5 命名清债（`App/ContentView.swift:107-119` title switch 仍 `hvac.*`/旧 key；确认 A2 还是 UIUE 收）。

## 5. 动效 + 双端（Phase 3/5）

- [ ] 5.1 `matchedGeometryEffect` 状态切换 gated upgrade（promotion_criteria，默认 opacityScale 兜底，spec R3；锁 iOS26 无需 `#available`）。
- [ ] 5.2 多调用编排（MultiCallSequencer stagger 220ms / MAX_CONCURRENT_HIGHLIGHTS=1 / FocusController）。
- [ ] 5.3 双端两独立实例 + TransportKind{none,bonjour}（D4，spec R4）；transient 控件（温度滑块/风量 toggle）激活态可用 `.glassEffect()`（Apple 官方例外）。

## 6. 验收

- [ ] 6.1 `swift test`（含 UIValueTypeMapper 单测）+ `xcodebuild` 两端 BUILD SUCCEEDED。
- [ ] 6.2 7 态各自独立渲染分支（无 `== .satisfied` 二值 / 无 default 吞态）—— `check-no-binary-visualstate.sh` 机械保证。
- [ ] 6.3 视觉值全从 DesignTokens/tokens.md 取（grep 无硬编 hex）；无 `#available(iOS17/18)` 版本守卫—— `check-platform-vs-version-guard.sh` 机械保证。
- [ ] 6.4 5-gate：simctl 14 张满屏单态（**非 gallery 缩略**，gallery 只内循环）→ 磊哥审美 5 gate 全 PASS。
- [ ] 6.5 spec ADDED `ui-presentation` 经 `openspec validate --strict`（✅ 2026-06-24 绿）。

## 7. D8 默认主驾 + L3+ 思考链路 + 交互边界（2026-06-24 grill 收口，grill-master §3 D8）

### 7.A 默认主驾展示（卡片层纯 UIUE，部分依赖 A2 scope 数据）
- [ ] 7.A1 卡片默认锚定 **per-cell `default_scope` 态**（🔴 读 state-cells `default_scope` G25 SSOT，**非手写**；座位→主驾/屏→中控/前后→前排 = 举例非权威，防裂缝④）；不渲「请选区域」空态
- [ ] 7.A2 多 scope 聚合卡（显式「全车」才 fan-out）✅**裂缝⑥拍 c**：全车 = **1 聚合卡（不分裂 N 张）+「全车」范围 badge**（青标签）；不违反 D8.5 MAX_CONCURRENT_HIGHLIGHTS=1（聚合=单点）｜依赖 A2 scope 数据
- [ ] 7.A3 scope 呈现 ✅**裂缝⑤拍 B 淡显**：**默认 scope = 淡显角标**（「车窗 100%」+ 淡「主驾」低对比，知范围不打断）/ **非默认（副驾/全车）= 三处显式**；卡片角标 / readback `{位置}` / TTS 三处同源（默认淡显非省略）
- [ ] 7.A4 多轮叠加 scope ✅**用户故事④拍 a 升级聚合**：「打开车窗」→「副驾也打开」→ 卡片升级聚合成范围词「前排车窗」（非双角标，跟全车聚合同逻辑）｜D1 继承 + G20 passthrough

### 7.B 思考链路演出（对话级 orb `think` 态，Phase 5 后续，**不在本 change 实装**）
- [ ] 7.B1 orb `think` 假 COT phase 机（思考中→调用中→方案，~3s）｜对话级非卡片态
- [ ] 7.B2 多变文案序列 / 7.B3 手机视觉占位 / 7.B4 接 NLU L3+ 信号触发 / 7.B5 兜底态展示
- 归属：Phase 5 orb TimelineView idle/`think`/speak/listen（hig-rules:56 已留位）；demo 场景宏即时（范式§175），后续真 LoRA 用 γ（3s 固定+规则兜底）

### 7.C clarify 态（少用，已定）
- [x] 7.C1 clarify 枚举保留、主线少用 ✅（D7 7 态含 blocked_with_alternative）
- [x] 7.C2 ✅done D7 force-state 示例改「调到16度→最低18℃」（值超范围+替代，去区域「主驾还是全车」）

### 7.D 多轮/读回展示（承接 Core 结果，UIUE 只展示）
- [ ] 7.D1 多轮继承展示（「再调高」继承默认主驾态，不弹区域）
- [ ] 7.D2 状态读回展示（「现在多少度」读默认主驾值）

### 🚫 7.E 边界外（非 UIUE，归其他分支，不在本 change）
- TTS 话术 scope 省略/明示 = Core readback `{温区}` 模板 + voice 分支（DEFERRED）
- scope 默认值填槽 = NLU/Core ｜ 多轮继承范围/记忆性 = DialogueState（3 轮范式）
- 触摸调节 = 砍（卡片只读非控制器）｜ L3+ 触发判定 = NLU ｜ LoRA 超时兜底逻辑 = Core

### 7.F 触摸交互（✅ 已拍）
- [x] 7.F1 P1 触摸 = **B 极简查看** ✅（磊哥 2026-06-24「可能会戳，不确定」→ B 落实：点卡高亮+tooltip，无调节逻辑，卡片只读非控制器，戳了有反馈保险）

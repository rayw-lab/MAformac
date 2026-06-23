<!--
PROPOSE-READY (2026-06-24) — proposal/design/tasks/spec 已填实，磊哥 agree + 锁 iOS26/macOS26 拍 A（pre-mortem 坐实）。
依赖序：本 change = UIUE 前端，依赖 migrate-d-domain([1] A2 已并 main PR#3) 但不依赖 LoRA 训练。
incremental（每 Phase 一个小 PR），禁大爆炸。Phase 映射见 docs/uiue-roadmap-2026-06-23.md。
锁 iOS26 决策 + pre-mortem 一手见 docs/research/2026-06-24-ios26-lock-d7-premortem/。
-->

## 1. 前置依赖

- [ ] 1.1 确认 A2（`migrate-d-domain-tool-surface`）已并 main（✅ PR#3 fd2220b）/ UIUE worktree rebase main 拿 A2 产物（`generated/family-device-allowlist.json` / state-cells 10 族）。**仅 Phase 4 需要**（Phase 1b/3 不依赖）。
- [x] 1.2 视觉 SSOT 三件套已落（`docs/design/{tokens.md,hig-liquid-glass-rules.md,INDEX.md}`，base #121212）✅ done。

## 2. 工程前置硬门（Phase 1b，U6 demo-blocker，❌不依赖 A2）

- [x] 2.1 麦克风 + 语音识别权限串 ✅ done（2026-06-24）：4 build config `GENERATE_INFOPLIST_FILE=YES` → `INFOPLIST_KEY_NSMicrophoneUsageDescription` + `INFOPLIST_KEY_NSSpeechRecognitionUsageDescription`（非物理 Info.plist；plutil OK + xcodebuild BUILD SUCCEEDED）。
- [x] 2.2 **App target deployment 锁 iOS26/macOS26** ✅ done（2026-06-24）：pbxproj 4 config IPHONEOS=26.0 / MACOSX=26.0；**Package.swift 留 `.iOS(.v17)/.macOS(.v14)` 不动**（Core/CLI portable，加强3 隔离）。**isolation spike receipt**（一次性验，非 pre-commit，[[precommit-triage-recurring-vs-spike]]）：`xcodebuild -showBuildSettings -scheme MAformacIOS|grep IPHONEOS_DEPLOYMENT_TARGET`=26.0 / `-scheme MAformacMac|grep MACOSX_`=26.0 / Package.swift=v17/v14。pre-mortem 坐实 Xcode26 SPM thread 81601 是 deprecation 警告非声明改写=paper-tiger，隔离安全；🔴 **别在 Core Package.swift 塞全局 warnings-as-errors**（swift#84379/spm#9517）。
- [ ] 2.3 entitlements（`increased-memory-limit`）**DEFERRED → 模型集成时**（iOS jetsam 要它，但模型未集成 + CODE_SIGN_ENTITLEMENTS 需 provisioning，现加引签名风险）。
- [ ] 2.4 `Availability.swift` **锁 iOS26 后版本守卫不需要**（MeshGradient iOS18/glassEffect iOS26/matchedGeometry iOS14 均 ≤ deployment 26）→ 仅封装 **平台守卫**（`navigationTransition.zoom` 用 `#if !os(macOS)`）+ **ReduceMotion/低电量双通道**（a11y 非版本）。随 Phase 3 用到时建。
- [ ] 2.5 截图管线（替代旧 snapshot baseline）：🔴 **ImageRenderer 不可用**（截不出 Liquid Glass/material/blur，Apple 官方：Core Animation 合成不进 raster，oracle4 坐实）→ 用 `simctl` 启动整 app 截图。分层（磊哥拍 ①）：**(a) `#if DEBUG` 7 态 gallery 视图**（一屏 7 态，D7 内循环用，simctl 截 2 张/端快速 iterate）+ **(b) `#if DEBUG` force-state URL scheme**（`maformac://debug/force-state/<态>`）→ `simctl openurl` 一行一态，**14 张满屏单态（mac7+iOS7）供 5-gate 验收**。
- [ ] 2.6 🔴 **补强1 pre-commit gate `Tools/checks/check-no-binary-visualstate.sh`** ✅ 建好未启用（启用时机=3.6 D7 改完后）。
- [ ] 2.7 🔴 **加强2 pre-commit gate `Tools/checks/check-platform-vs-version-guard.sh`**（建，反复违反风险 [[precommit-triage-recurring-vs-spike]]）：`git grep -nE '#available\(iOS (17|18)' -- 'App/'` 命中即 exit 1（锁 iOS26 后不该有版本守卫）；白名单允许 `#if !os(macOS)` / `if reduceMotion` / `isReduceMotionEnabled`（a11y/平台非版本）。同 2.6 暂不启用 hooksPath，并入 3.6 启用。
- [x] 2.8 🔴 **补强3 tokens §2 语义分类审签冻结** ✅ 2026-06-24 磊哥审签（琥珀=clarify/灰锁=unsupported/红=safety/中性灰=crash），`tokens.md:3` 语义分类 FROZEN v1.0；hex 仍 DRAFT，Phase 3 实渲后复核（3.7）。

## 3. ui-presentation capability — 状态消费（Phase 3，🔴 D7 头号刀；force-state URL scheme 同批次）

- [ ] 3.0 `App/DesignTokens.swift`：Swift 镜像 tokens.md（色/字/动效 token + 7 态 `CardAppearance` 穷尽 switch），view 只从此取（禁手填 hex，spec R4）。
- [ ] 3.1 `ContentView` 绿/灰二值（`:122/:126`）→ `DemoVisualState` 7 态穷尽 `@ViewBuilder switch`（spec R1，无 default 兜底）。
- [ ] 3.2 四态分开（clarify 琥珀 / unsupported 灰锁 / safety 红 / crash 中性灰），色值从 `DesignTokens`（镜像 tokens.md §2）。
- [ ] 3.3 消费 trace `guardReason`/`readbackResult`（spec R1；`Core/Trace/TraceLogger.swift:37-38` 已有字段）。
- [ ] 3.4 `#if DEBUG` 7 态 gallery 视图（2.5a）+ force-state URL scheme handler（2.5b，CFBundleURLTypes + onOpenURL）。
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

<!--
PROPOSE-ACTIVE (2026-06-24, 磊哥拍 B 严格 OpenSpec·文档先行防返工) — proposal/design/tasks/spec 已填实(5 Req/29 Scenario, validate 绿)。锁 iOS26/macOS26(那轮拍 A, pre-mortem 坐实)。
依赖序：本 change = UIUE 前端，依赖 migrate-d-domain([1] A2 已并 main PR#3) 但不依赖 LoRA 训练。
apply 状态: Phase 1b ✅done / Phase 3 D7 已 apply(commit 6a3e3f9 追认) / A-2 Phase 3/4/5/6 simulator/mock proof 已落锚；Phase 2 visual acceptance `8.A/8.C2` 暂缓且保持 open。旧 `default_scope` 依赖仍按 1.3 独立 carrier，不再阻塞 A-2 mock-frontstage Phase 4 receipt。
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
- [x] 3.6 ✅ **启用 pre-commit gate**（2.6+2.7，2026-06-24 审计 P1-1 修）：`git config core.hooksPath .githooks` 已挂；两 gate PASS；回归验证坐实 = staged 二值 → check-no-binary exit 1 拦。D7 已改完（ContentView 无 binary + 无 `#available(iOS17/18)`）。
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

- [x] 6.1 `swift test`（含 UIValueTypeMapper 单测）+ `xcodebuild` 两端 BUILD SUCCEEDED（receipt: `docs/research/2026-06-25-a2-execution/a2-mechanical-verification-receipt.md`）。
- [x] 6.2 7 态各自独立渲染分支（无 `== .satisfied` 二值 / 无 default 吞态）—— `check-no-binary-visualstate.sh` 机械保证（2026-06-26 rerun pass）。
- [x] 6.3 视觉值全从 DesignTokens/tokens.md 取（grep 无硬编 hex）；无 `#available(iOS17/18)` 版本守卫—— `check-platform-vs-version-guard.sh` 机械保证（2026-06-26 grep + gate pass）。
- [ ] 6.4 5-gate：simctl 14 张满屏单态（**非 gallery 缩略**，gallery 只内循环）→ 磊哥审美 5 gate 全 PASS。
- [x] 6.5 spec ADDED `ui-presentation` 经 `openspec validate --strict`（2026-06-26 `openspec validate ui-presentation --strict` pass）。

## 7. D8 默认主驾 + L3+ 思考链路 + 交互边界（2026-06-24 grill 收口，grill-master §3 D8）

### 7.A 默认主驾展示（卡片层纯 UIUE，部分依赖 A2 scope 数据）
- [ ] 7.A1 卡片默认锚定 **per-cell `default_scope` 态**（🔴 读 state-cells `default_scope` G25 SSOT，**非手写**；座位→主驾/屏→中控/前后→前排 = 举例非权威，防裂缝④）；不渲「请选区域」空态
- [ ] 7.A2 多 scope 聚合卡（显式「全车」才 fan-out）✅**裂缝⑥拍 c**：全车 = **1 聚合卡（不分裂 N 张）+「全车」范围 badge**（青标签）；不违反 D8.5 MAX_CONCURRENT_HIGHLIGHTS=1（聚合=单点）｜依赖 A2 scope 数据
- [ ] 7.A3 scope 呈现 ✅**裂缝⑤拍 B 淡显**：**默认 scope = 淡显角标**（「车窗 100%」+ 淡「主驾」低对比，知范围不打断）/ **非默认（副驾/全车）= 三处显式**；卡片角标 / readback `{位置}` / TTS 三处同源（默认淡显非省略）
- [ ] 7.A4 多轮叠加 scope ✅**用户故事④拍 a 升级聚合**：「打开车窗」→「副驾也打开」→ 卡片升级聚合成范围词「前排车窗」（非双角标，跟全车聚合同逻辑）｜D1 继承 + G20 passthrough

### 7.B 思考链路演出（对话级 orb `think` 态，Phase 5 后续，**不在本 change 实装**）—— 🔴 **E 组 grill 收口（E0-E8，详见 grill-master §3 E 组）**
- [ ] 7.B1 orb `think` 假 COT **事件驱动**（E2 非计时：analyzing 掩盖后端→**后端卡片跳动 `cardsDidStartChanging` 事件**=handoff→speak readback，3s 虚数）｜对话级非卡片态
- [ ] 7.B2 orb 实现 E1（自建多层 MeshGradient+breathing+hanlin 文字+可选 Canvas 粒子，零 metasidd/零 Inferno）/ 7.B3 think 两语义 E8（思考链路掩盖动态 vs 安全拒识演出固定 1.0s）/ 7.B4 触发 E3（Core SceneMacroMatcher→macro_id 信号+force 长按 orb 1.5s+L1 listen 微亮+barge-in U21）/ 7.B5 场景宏 E4（首批4宏+narration 2字段+trigger_tags 10同义词，Core scenario-macros.yaml）
- 🔴 **DA0 deny→态 E5-E7**（执行链路，Phase 5）：store `applyGuardBlock(key:String,态,reason)` 非throw + reason→态映射 E6 + 统一 `reasons` map E7 + `systemFailure` 真异常；**主流程 DemoFastPathGuard 占位（只演打开空调），安全拒识 deny 体系要扩 guard 接 C3**
- 归属：思考链路 orb+SceneMacroMatcher=Core/Features+UIUE（Phase 5）；DA0 deny→态影响本 change R1（7态消费+reason）；voice 音频/炸场 DEFERRED

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

## 8. 完整 demo 交互原型实装（A-2，SD18-25 + 触控/控制台/氛围灯 consolidated AD-14，全 mock 前台，consumes A-1 bridge accepted）

> 🔴 **范围扩到完整 demo 交互**（磊哥 2026-06-25，SD7 amendment）：视觉 + 触摸 + 语音 + state 联动 + 演绎控制台 + 氛围灯炸场 + capsule，**全 mock 前台**（不接真 NLU/ASR/TTS/LoRA/runtime backend，后续接线 DEFERRED）。消费 A-1 bridge（mock snapshot）。落 spec 4 个 mock-frontstage Requirement（mock interaction / expanded controls mock state / demo control panel / ambient edge burst）。实装 order：8.A 连续舞台 → **8.D 触控+state 联动+语音推理 mock** → **8.E 演绎控制台 mock** → **8.F 氛围灯炸场** → 8.B capsule → 8.C 验收。完整实施计划 = `docs/superpowers/plans/2026-06-25-a2-step2-uipresentation.md` v3（含巨人肩膀 adopt + 每 Phase codex 审计 + anchor 像素对比）。

### 8.A 连续舞台核心（直接做，不依赖 capsule spike）
- [ ] 8.A1 ContentView 三屏连续舞台重构（**去 divider 黑线** / 去品牌 MAformac / 设置刷新右上 standalone / orb-对话-车控-mic 四 zone，SD18 V7）
- [ ] 8.A2 tokens.md hex 定稿（米白 / 7态亮底加深 / 制冷热）DRAFT→FROZEN + `DesignTokens.swift` 同步（间距 §6/字体 §3.1/圆角 §7/theme §8）
- [ ] 8.A3 制冷热 sibling 渲染（消费 bridge `sibling_cells`，`ac.mode`→蓝/红 + range bar + mode 图标，SD20）+ `SemanticColorMapper` 契约存在性
- [ ] 8.A4 CC1 activeCell 主值切（非 normal 态取 bridge `active_cell` 优先 primary，SD19）+ 契约存在性测试
- [ ] 8.A5 层级 + 滚动（z-order / mic dock `contentInset` / 手动滚暂停 scrollTo / fade 按 active 非位置，SD22）
- [ ] 8.A6 边界态（**移除 ContentView TextField 纯语音** / portrait lock / 文案 30 字 truncate / 族外 blocked_hard，SD23）
- [ ] 8.A7 注意力优先级 + 次要族 fade（V8）+ V9 `FamilyIconMapper`（全 SF Symbols 契约存在性）

> 2026-06-26 v72 PARTIAL evidence: `docs/research/2026-06-25-a2-execution/phase-2-main-stage-receipt.md#additional-v72-atmosphere--ac-scrub-pass` records iPhone screenshots, 4-zone anchor compare, AC fixed hero, toned standby typography, particle/halo atmosphere, and `ThermalRangeBar` scrub code. Runtime UI snapshot sees `vehicle-card-family.ac` with `25℃`; automated drag proof remains blocked by simulator tooling (`FBSimulatorHIDEvent` no touch-move, `idb` absent). Keep 8.A and 8.C2 unchecked until visual-acceptance 5-gate plus anchor-level human review passes.

### 8.B context capsule diorama（spike-gated，SD24/25）
- [x] 8.B1 🔴 capsule route spike（🔴 **模拟器观感对比** A 视频 loop vs C-lite，量观感 + 像不像 anchor；**GPU/帧率真机验证 DEFERRED → 真机阶段**，磊哥 2026-06-25 拍「不真机用 iOS 模拟器」；模拟器不渲染 glass 折射/specular[paper-tiger]→route A 视频 photoreal 不打折/C-lite glass 质感打折；**U31 实证不预拍 / U30 砍重折射 shader**）
- [x] 8.B2 capsule 资产（route 定后：C-lite 分层 stills/CoreML 深度 或 A video loop）
- [x] 8.B3 `ContextCapsule` view（消费 bridge `context` 四维 + crossfade 切换 + **预加载防卡顿** + 图标在 capsule 外）
- [x] 8.B4 adopt Vortex（`.smoke` 尾气 / `.rain` 雨 / `.snow` 雪 / 星光）+ native `.glassEffect` 壳（守 U30，不在 always-on capsule 跑 Inferno 折射 shader）

### 8.C 验收（A-2 收口）
- [x] 8.C1 swift test 0fail + `xcodebuild -scheme MAformacMac/MAformacIOS` 两端绿 + `make verify-all` exit0
- [ ] 8.C2 visual-acceptance **L0-L3**（AD-15/U32-U37）：L0 on-screen simctl 真截图 + L1 zone sentinel PASS/WARN/FAIL + L2 OCR/contrast（SSIM 证据）+ **L3 人工 5-gate（米白/深空，~~投屏环境 V10~~ → 手持环境，投屏 DELETE C0）** + anchor-set 对比（连续舞台无黑线 / 制冷热 / capsule diorama）。当前保持 open；既有 P2/P3 证据只强化局部 simulator/local proof，不关闭 L3 human 5-gate。

> 2026-06-26 P2 outer-ring validation reran `swift test`, macOS `xcodebuild`, and `make verify-all`: all PASS. This reinforces `8.C1` only. `8.C2` stays open because visual-acceptance 5-gate and anchor-level human review are not closed. Closeout ledger: `docs/research/2026-06-25-a2-execution/a2-phase-closeout-receipt.md`.

### 8.D 触控 + state 联动 + 语音推理（全 mock，SD6/SD7，plan Phase 3）
- [x] 8.D1 `ValueControlView` 交互回调（dial/percent ± 步进 / stepper 段位 / toggle 切 / badge 循环 → `ValueControlActions`；adopt **axiom-swiftui** binding/gesture + **IceCubesApp** 交互参考）
- [x] 8.D2 `ExpandedFamilyCard`/`ExpandedCellRowView` 接回调 → mock store（`store.applyMockTransition(DemoMockTransition(key:desiredValue:source:.user))` → snapshot 刷新 → 卡片+numericText 联动）
- [x] 8.D3 🔴 `applyMockTransition` visualState 修复（值真变化→`.changing`/`.satisfied`，非只 `"on"`→`.normal`；否则触控联动假绿）+ clamp/cycle **复用 `ValueRangeMapper`**（dial 18-32/percent 0-100/stepper 档/badge 8 色，防漂移）+ 测试
- [x] 8.D4 语音推理 mock 预设（「26→冷了→升温」mock 响应读当前 mock 态；摘要卡只读 SD23 7.F1；静默无 TTS）

> 2026-06-26 P2 inner-loop evidence: Phase 3 receipt records simulator tap `AC card -> expanded increase`, with UI tree changing `空调 26℃` to `空调 27℃`. This closed the stepper/mock-state path for 8.D1-8.D3 and SD6; at that point 8.D4/SD7 stayed open pending voice-reasoning mock and drag/operator-pass evidence.

> 2026-06-26 P3 follow-up evidence: `MicDock` now exposes a mock submit route and `applyMockVoiceColdIntent` reads the current AC mock cell before applying `26℃ -> 28℃` through `DemoVehicleStateStore`. Simulator UI tree proves `按住说话` tap changes `空调 26℃` to `空调 28℃` and appends `我有点冷了 / 当前 26℃，已为您升到 28℃` without connecting true ASR/TTS/LoRA/backend. Drag remains `operator-pass pending`, not automated V-PASS.

### 8.E 演绎控制台（全 mock force，SD13-15/SD8，plan Phase 4）
- [x] 8.E1 `DemoControlPanel` 控制中心式竖排模块卡（常态/整车/环境/座舱；adopt **axiom-design** HIG control center + **IceCubesApp/ShipSwift**；iOS26 glass 功能层 + material）
- [x] 8.E2 整车/环境 force **mock context**（speed/gear segmented + weather/time_period 互斥 → bridge force-context AD-RPB-014，不碰 state-cells.yaml）
- [x] 8.E3 常态卡 + `AllStateSheet`（33 base 按 10 族分组网格弹窗）+ `NormalRunPreset` 一键复位（=DemoReset）
- [x] 8.E4 SD8 设置面板（主题切 deepSpace↔ivory 实时 + 场景宏 force `#if DEMO_MODE`）+ 刷新复位

> 2026-06-26 P1/P2 reconciliation: Phase 4 commit `564d0c0` anchored the control-panel receipt and screenshots, matching coverage SD13/SD14/SD15/RPB-52. At that point the P2 simulator probe opened the settings sheet, but tapping `演绎控制台` returned to the main stage instead of presenting `DemoControlPanel`, so 8.E4 stayed open until the P3 follow-up below.

> 2026-06-26 P3 follow-up evidence: commit `fix(uiue): close phase4 settings control route` queues the demo-control sheet after settings dismiss; simulator UI tree proves settings→control-panel route, deepSpace theme tab switch, rain macro state mutation, and reset back to idle. Receipt: `docs/research/2026-06-25-a2-execution/phase-4-control-panel-receipt.md#p3-follow-up-settings-route--theme--macro--reset-closure`.

### 8.F 氛围灯炸场（SD4，plan Phase 5）
- [x] 8.F1 `AmbientCardGradient` 卡片渐变（P2 已含 8.A 氛围灯卡）+ `AmbientEdgeBurst` 边缘 5s 爆发（adopt **Vortex** Canvas 粒子 + **SwiftUIShaders/open-swiftui-animations**；`allowsHitTesting(false)` 守 U30 不跑 Inferno 折射）

### 8.G 视觉验收门 hardening + 长跑流程机制（AD-15 / U32-U37，2026-06-26 codex ~15h 长跑复盘）

**A 视觉门契约**：
- [x] 8.G1 visual-acceptance **L0-L3 门定义**（L0 runtime-truth 字段 / L1 sentinel PASS/WARN/FAIL / L2 OCR+contrast+SSIM / L3 人工 5-gate enum）落 spec + 8.C2 验收口径（AD-15）
- [x] 8.G2 一进两出 **8 态 VUI 矩阵测试**（U37）：`DemoRuntimeResultKind.allCases` 每态 视觉态+话术+动效+TTS+proof，禁 default 吞，复用 `FamilyDisplaysTests` 闭合模式

**B 流程机制**（回写流程文档，非本 change spec）：
- [x] 8.G3 `plan v3 heavy-work 段` + 全局 `heavy-work` skill 回写：long-run stop-rule（2 轮无新 proof-class 收口）/ 截图链路纪律（必 on-screen simctl 禁 off-screen ImageRenderer）/ proof-class budget

**C 代码**：
- [x] 8.G4 `Tools/checks/phase2_zone_compare.py` 输出 RMSE → PASS/WARN/FAIL + stop-rule（U33）
- [x] 8.G5 ContentView Grid 固定列 ✅ **已实装**（2026-06-26 核：codex 长跑 `VehicleCardsGrid` 用 `Grid + GridRow`（`App/ContentView.swift:1504`），零 LazyVGrid，pre-commit `contentview-wiring` 实跑确认；D5 C22「:40 仍 LazyVGrid」= stale 已 supersede）
- [x] 8.G6 `state-cells` 的 `ui_value_type` 消费侧派生 projection（复用 `UIValueTypeMapper`，不写回 producer contract，守 spec R2/AD-2）+ 清 active Core/Tests 残留 `hvac.*` 命名债（历史 v0/capabilities refs 保留为 archived/historical）
- [x] 8.G7 取证 receipt `evidence_kind` enum（tap_step/toggle/badge_cycle/continuous_drag/terminal_visual_only，U36）+ 代表族自动化样本矩阵（风量/座椅/车窗/灯光各 1 条）
- [x] 8.G8 Reduce Motion 降级路径（U35）：粒子/氛围灯/orb 降级 + 禁动效态跑 5gate + 静态「在思考」反馈
- [x] 8.G9 UIUE 工程项实装（U14-U18）：Mac AnyLayout 并排 / HTML+Preview 4 类反例 / iPhone 触觉 / snapshot+黄金路径 XCUITest / 客户物料不上架
  - [x] 8.G9a local/unit（U14/U15/U16/U18/U44）：U14 Mac split 只加契约测试和本地检查；U15 反例 fixture + DebugGallery 静态镜像；U16 触觉 policy 仅允许 iOS userTouch；U18 distribution boundary guard 仅允许 personal/internal self-use；U44 无投屏 Liquid Glass inventory 锁 MicDock/ContextCapsule/DemoControlPanel 三处 glass surface，内容卡继续禁 glass。
  - [x] 8.G9b（U17）：已新增 `MAformacIOSUITests` UI test target + 最小黄金路径 XCUITest + on-screen `simctl io screenshot` L0 截图包；proof class 限 simulator L0 smoke，不关 `8.C2` / L3 / V-PASS。

### 8.H post-8.C2 formal grill amendment cascade（2026-06-27，docs-only gate boundary）

> Authority: `docs/grill-tournament/uiue-r0-r2-grill-decisions-2026-06-27.md`。本节只把人审通过的 R0-R2 canonical groups 级联成 OpenSpec 可观察 gate / proof boundary，不搬 70 条 Cxx 原文，不授权实现，不关闭 `8.C2`。

- [ ] 8.H1 R1 Interaction Integrity 前置门：后续若声明交互真值通过，必须有 `family` / `ui_value_type` / `gesture` / `writeback` / `summary_readback` / `proof_class` 矩阵；只读/过程态不得显示假 affordance。
- [ ] 8.H2 `StateCellInteractionPolicy` / consumer projection 边界：可点性、range、enum/options、readback 必须从现有 mapper/contract 派生，SHALL NOT 在 view 内新增第三份 value/range/enum SSOT。
- [ ] 8.H3 `verify-uiue-interactions` 仅为 UIUE 专门门候选；进入长期 gate 前必须另有 grill 决策，SHALL NOT 直接塞入全局 `make verify-all`。
- [ ] 8.H4 R2 视觉重跑前置：R1 交互矩阵、R2b Layout Integrity / Visual Spacing、VPA 四态、capsule asset governance 均需有明确 owner/proof/defer 状态；本任务不勾 `8.C2`。
- [ ] 8.H5 R2b Layout Integrity / Visual Spacing 只挡结构 bug：遮挡、留白、zone budget、safe-area、右侧按钮外置、胶囊居中、mic dock 不遮卡片；SHALL NOT 作为审美或 L3 裁判。
- [ ] 8.H6 Capsule/VPA proof split：context/data proof、layout proof、diorama aesthetic/L3 proof 分层记录；GPT Image 2 / anchor 只作方向，不作工程结构或最终验收 authority。

### 8.I D17 UIUE Runtime -> Presentation consumer train（2026-06-29，D15/D16 main authority consumer）

> Authority: main D15 payload contract, main D16 Core config / force-state authority, Gate4R `d17_release_gate: open`. Proof cap remains local/unit/simulator_mock. No UIUE merge, runtime-ready, mobile, true-device, live API, V-PASS, S-PASS, U-PASS, or A-2 claim.

- [x] 8.I1 Gate5 authority: define UIUE consumer boundary for D15 `RuntimePresentationPayload` / `PresentationReconciliation` and D16 stable Core config / SceneMacroRegistry / force-context names.
- [x] 8.I2 Gate5 forbid UIUE-invented shared fields, enum values, proof classes, Core config truth, force-state truth, private adapter fields, raw runtime/model/training fields, and `DemoForceStateContext` decode/constructor surfaces.
- [x] 8.I3 Gate6 implement UIUE consumer mapping and local/unit fail-closed tests for unknown schema/proof/reconciliation/config/macro/force-context/presentation names.
- [x] 8.I4 Gate7 run UIUE consumer verifier and optional simulator/local visual smoke under proof cap.
- [ ] 8.I5 Gate8 reconcile dual repo route map, burndown, grill/ledger cascade, final Claude Code adversarial audit, and exact-path commits.

### 8.J D19 UIUE durability guard train（2026-06-29，D18 proof-governance / deny-list consumer）

> Authority: main D18 local durable adapter/C3 authority and Gate4 private payload boundary verifier. D19 consumes D18 only as proof-governance and deny-list guardrails. No UIUE durable ledger consumption, UIUE merge, runtime-ready, mobile, true-device, live API, V-PASS, S-PASS, U-PASS, A-2, voice/model/golden/endpoint, or R5 complete claim.

- [x] 8.J1 Gate5 authority: define UIUE durability guard boundary for D18 proof-governance and deny-list semantics only.
- [x] 8.J2 Gate5 forbid UIUE consumption of durable ledger, persistent ledger, adapter ledger, `local_durable_adapter_ledger`, request/parent fingerprints, success/failure ledger, settled parent plan, raw runtime store, raw model output, training receipt, adapter-local private names, and D18 storage/schema internals.
- [x] 8.J3 Gate6 implement UIUE local/unit fail-closed guard tests for D18 durable/private names and readiness/proof-cap non-promotion.
- [x] 8.J4 Gate7 update route/burndown/reconcile docs under proof cap.
- [ ] 8.J5 Gate8 final reconcile and blind audits across D18+D19 Gates1-8.

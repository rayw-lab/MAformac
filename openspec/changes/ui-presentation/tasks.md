<!--
PROPOSE-READY (2026-06-24) — proposal/design/tasks/spec 已填实，磊哥 agree。
依赖序：本 change = UIUE 前端，依赖 migrate-d-domain([1] D-domain surface + state-cells 10 族，A2 已并 main) 但不依赖 LoRA 训练。
incremental（每 Phase 一个小 PR），禁大爆炸。Phase 映射见 docs/uiue-roadmap-2026-06-23.md。
-->

## 1. 前置依赖

- [ ] 1.1 确认 `migrate-d-domain-tool-surface` 已并 main / UIUE worktree rebase main 拿到 A2 产物（`generated/family-device-allowlist.json` / `D_domain.tools.*` / state-cells 10 族）。**仅 Phase 4 需要**（Phase 1b/3 不依赖）。
- [x] 1.2 视觉 SSOT 三件套已落（`docs/design/{tokens.md,hig-liquid-glass-rules.md,INDEX.md}`，base #121212）✅ done。

## 2. 工程前置硬门（Phase 1b，U6 demo-blocker，❌不依赖 A2）

- [x] 2.1 麦克风 + 语音识别权限串 ✅ done（2026-06-24）：`MAformac.xcodeproj` 4 build config（Mac/iOS × Debug/Release）`GENERATE_INFOPLIST_FILE=YES` → 走 `INFOPLIST_KEY_NSMicrophoneUsageDescription` + `INFOPLIST_KEY_NSSpeechRecognitionUsageDescription`（**非物理 Info.plist**；plutil OK + xcodebuild -list 解析通过）。⚠️ 修正：原写「App/Info.plist」物理文件不适用本工程；原漏 `NSSpeechRecognition`（SFSpeechRecognizer 必需，D14/U28）已补。
- [ ] 2.2 entitlements（`increased-memory-limit`）**DEFERRED → 模型集成时**：iOS jetsam 限制要这个，但模型未集成 + `CODE_SIGN_ENTITLEMENTS` 需配 provisioning（现加引 iOS 签名风险）。非当下 U6 blocker。
- [ ] 2.3 `Availability.swift`（iOS18 `#available` 守卫封装，U19/U30）**随 Phase 3 建**：现无 iOS18 API 消费者（MeshGradient/glassEffect 在 Phase 3/5 才用），现建是 orphan 脚手架。
- [ ] 2.4 snapshot baseline（swift-snapshot-testing + ImageRenderer）**随 Phase 3 建**：现 ContentView 绿灰二值 Phase 3 全要重写，现拍 baseline 是废功；有 7 态 view 时再拍。
- [ ] 2.5 🔴 **补强1 pre-commit gate**：建 `Tools/checks/check-no-binary-visualstate.sh`（`git grep -E 'visualState\s*==\s*\.\w+\s*\?' -- 'App/*.swift'` 命中即 exit 1 + 第二行 grep `default:` 吞 VisualState/ViewBuilder）+ `.githooks/pre-commit` 调用它。**建好但暂不 `git config core.hooksPath`**（现 `ContentView.swift:122/:126` 未修，启用会拦死所有 commit）→ 启用时机 = 3.6（D7 改造完成后）。grep 路径修正为 `App/*.swift`（app 源只在 `App/`，无 `MAformacIOS/`/`MAformacMac/` 目录）。
- [x] 2.6 🔴 **补强3 tokens §2 语义分类审签冻结** ✅ 语义分类 2026-06-24 磊哥审签（确认：琥珀=clarify / 灰锁=unsupported / 红=safety / 中性灰=crash）→ `tokens.md:3` status 语义分类列 FROZEN v1.0；**hex 仍 DRAFT**（实渲微调），Phase 3 实渲后复核冻结 hex（见 3.7）。

## 3. ui-presentation capability — 状态消费（Phase 3，🔴 D7 头号刀）

- [ ] 3.1 `ContentView` 绿/灰二值（`:122/:126`）→ `DemoVisualState` 7 态穷尽 `@ViewBuilder switch`（spec R1）。
- [ ] 3.2 四态分开（clarify 琥珀 / unsupported 灰锁 / safety 红 / crash 中性灰），色值从 `tokens.md §2` 取（spec R1）。
- [ ] 3.3 消费 trace `guardReason / readbackResult`（spec R1）。
- [ ] 3.4 每 view snapshot baseline（含 2.4 的 snapshot 基建一并建）。
- [ ] 3.5 `Availability.swift` 随本 Phase iOS18 API 用时建（2.3）。
- [ ] 3.6 🔴 **启用 pre-commit gate**（2.5）：D7 改造完成（ContentView 已无 binary visualState）→ `git config core.hooksPath .githooks` + 验证 hook 绿（grep 0 命中）+ 故意写回 binary 验 hook exit 1。
- [ ] 3.7 tokens.md §2 hex 实渲微调后复核冻结（2.6 留尾）：halation/对比度实机看，hex DRAFT → FROZEN。

## 4. 卡片渲染（Phase 4，部分依赖 A2 产物）

- [ ] 4.1 🔴 **补强2 ui_value_type 消费侧派生**（spec R2，2026-06-24 级联 producer→consumer + 签名纠正）：建 `App/Rendering/UIValueTypeMapper.swift`，签名 `func uiValueType(for cell: DemoVehicleStateCell) -> UIValueType`，**从 `cell.key` 派生**（`DemoVehicleStateCell` 无 type/values/unit 字段，那是 yaml producer 字段）；`enum UIValueType { dial, toggle, stepper, percent, badge }`；**不写回 `state-cells.yaml`、不给 `DemoVehicleStateCell`（Core）加字段**。key→UIValueType 映射表（10 族全集）+ 单测（各族 key × UIValueType 断言）。
- [ ] 4.2 `ContentView` 卡片值用 `enum + switch(ui_value_type)` 穷尽渲染（非 AnyView，spec R2）+ FamilyCardLayout 按 10 族 family_card_id。
- [ ] 4.3 `Grid` 固定列（非 LazyVGrid.adaptive，C22，spec R3）。
- [ ] 4.4 卡片高频排序用 family-device-allowlist `row_count`（C8 复议#7，spec R2）。
- [ ] 4.5 命名清债收尾（`App/ContentView.swift:107-119` title switch 仍用 `hvac.*`/旧 key；确认是 A2 还是 UIUE 收，避免双写）。

## 5. 动效 + 双端（Phase 3/5）

- [ ] 5.1 `matchedGeometry` 状态切换 gated upgrade（promotion_criteria，默认 opacityScale 兜底，spec R3）。
- [ ] 5.2 多调用编排（MultiCallSequencer stagger 220ms / MAX_CONCURRENT_HIGHLIGHTS=1 / FocusController）。
- [ ] 5.3 双端两独立实例 + TransportKind{none,bonjour}（D4，spec R4）。

## 6. 验收

- [ ] 6.1 `swift test`（含 snapshot 回归 + UIValueTypeMapper 单测）绿。
- [ ] 6.2 7 态各自有独立渲染分支（无 `== .satisfied` 二值压缩 / 无 default 吞态）—— pre-commit gate（2.5）机械保证。
- [ ] 6.3 视觉值全从 tokens.md 取（grep 无硬编 hex）。
- [ ] 6.4 spec ADDED `ui-presentation` 经 `openspec validate --strict`（✅ 2026-06-24 已绿）。

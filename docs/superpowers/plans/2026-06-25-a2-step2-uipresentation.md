# UIUE A-2 (step2) — 完整 demo 交互原型 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development 或 executing-plans 逐 task 执行。Steps 用 checkbox（`- [ ]`）。
>
> 🔴 **执行方 = CC 主窗口主持**（磊哥定）。任何执行方**必先读「§0 背景决策包」+ 每 Phase 后回读基线文档**（防自拍已决决策）。
>
> 🟢 **v3 定稿（2026-06-25）**：经 subagent CC（adversarial）+ codex-rescue + GLM-5.2 **三路审计**辩证收 + 磊哥拍多项：① A+ bridge（PresentationSnapshot vocabulary 容器/卡片复用 VehicleCardDisplay）② **范围扩到完整 demo 交互**（视觉+触摸+语音+state 联动+演绎控制台，**全 mock 前台**）③ 氛围灯 SD4 补 ④ 演绎控制台 SD13-15 进本 §8 ⑤ SD7 触摸调节实现（mock）⑥ 每 phase 派 codex 审计 + anchor 像素对比。

**Goal:** 把 UIUE 从临时态重构成**完整 demo 交互原型**——10 族卡片连续舞台 + 触摸调节 + 语音对话流 + state 联动 + 氛围灯炸场 + 演绎控制台（方案经理 force 端状态）+ context capsule，**全 mock 前台**，在 iOS 模拟器视觉质量**达到或超过 anchor 锚点集**（anchor 像素对比硬门，非 1:1 复刻——grill 创新点要比 anchor 更惊艳）。

**Architecture:** 七层分 Phase，全 mock 前台（`MockPresentationSnapshotProvider` 是核心，所有交互切 mock 展示）。① bridge mock vocabulary 容器 → ② 语义派生层（含氛围灯 8 色）→ ③ 连续舞台 visual（四 zone + 设置/刷新）→ ④ 触摸调节 + state 联动 + 语音推理（mock）→ ⑤ 演绎控制台（mock force）→ ⑥ 氛围灯炸场 → ⑦ context capsule → 验收。

**Tech Stack:** SwiftUI（iOS26/macOS26）、**XCTest**（与现有 222 测试一致）、`simctl`（force-state 截图）、Vortex（粒子）、native `.glassEffect`。

**🔴 分层开发 convention：**
- **语义派生层 / bridge mock / 契约存在性 task** → **TDD step**（failing test → run fail → 实装 → run pass → commit），plan 内给完整 XCTest + 实装代码。
- **View / 触摸 / 演绎控制台 / 氛围灯 / capsule task** → **5-gate + anchor 像素对比验收 step**（实装[约束] → 双端 build → simctl 截图 → anchor 像素对比 + 5-gate → commit），给精确 interface + 约束 + 验收门，不写死每行（视觉/交互迭代）。

---

## §0 🔴 背景决策包（执行前必读 + 每 Phase 后回读）

**必读基线（起手 + 每 Phase 后回读）：**
1. `CLAUDE.md` + `docs/lessons-learned.md`（K 段）。
2. `docs/uiue-storyboard-grill-decisions.md` — **SD1-SD25 全集**（开场/push-to-talk/对话流/**氛围灯 SD4**/玻璃分层/**点卡展开 SD6**/**触摸调节 SD7**/**刷新设置 SD8**/拒识/多意图/米白/**演绎控制台 SD13-15**/orb/视觉块 SD18/corner SD19/制冷热 SD20/gptPRO SD21/层级滚动 SD22/边界 SD23/capsule SD24-25）。
3. `docs/grill-checklist/uiue-grill-定档-2026-06-25.md` — 作废清单 S1-S10。
4. `openspec/changes/define-runtime-presentation-bridge/design.md` — A-1 bridge AD-RPB-001~015。
5. `openspec/changes/ui-presentation/design.md` AD-13/AD-14 + `tasks.md §8`。
6. `docs/design/tokens.md`（视觉 SSOT，制冷热色在 **§1**）+ `docs/design/INDEX.md`。
7. `docs/design/gptimage2-anchor-set/`（anchor prompt）+ `docs/design/anchors/`（anchor PNG，本地 gitignored，**像素对比基准**）。
8. `docs/research/2026-06-25-context-capsule-2.5d-tech/README.md`（capsule 依赖栈）。
9. **本 plan 配套索引** `docs/grill-checklist/uiue-a2-grill-coverage-index.md`（grill 全集 × Phase 映射，随推进消减）。

**🔴 边界（磊哥 2026-06-25 终定，正式落点 = storyboard SD7 amendment + spec 4 个 mock-frontstage Requirement，非本 plan 私自覆盖 SSOT）：**
- UIUE A-2 = **完整 demo 交互呈现**（前端视觉 + 触摸 + 语音 + state 联动 + 演绎控制台），**全 mock 前台**。
- 🔴 **SD7 行 121「边界放宽碰 Core/State 完整链路」已正式 amend** → **全 mock**（触摸/语音推理/联动/force 全 mock 展示，**等后续接线**真后端）；正式落点 = `docs/uiue-storyboard-grill-decisions.md` SD7 AMENDMENT + `openspec/changes/ui-presentation/specs/ui-presentation/spec.md` mock-frontstage Requirement，执行方以此为准（非 plan 字面）。
- 可碰 `DemoVehicleStateStore`（现有 **mock** 车控 store，D16 全 mock）展示触摸联动；**不接真后端**（NLU/语音推理/LoRA/ASR-TTS → 后续接线 DEFERRED）；**不改 state-cells.yaml 契约语义/codegen**；§6 红线（密钥/PII/报价）不变。
- 语音推理「26 度→冷了→升温」= **mock 预设响应**（不真 NLU），演绎控制台 force = **mock context/state 切换**。

**已拍死的关键决策（不自拍）：**
- default_scope 已落 main（`17ae332`，state-cells 11 处）→ 读 `default_scope` SSOT 不手写。
- A+ bridge：PresentationSnapshot vocabulary 容器 / 卡片复用 `VehicleCardDisplay`+`familyDisplays(from:)` 不造平行 SnapshotCard。
- scope 淡显角标（SD23 裂缝⑤，`caption semibold` 非 caption2 9pt）/ 全车 1 聚合卡（裂缝⑥）。
- 7 态穷尽 switch 无 default（机械门 `check-no-binary-visualstate.sh`）。
- 纯语音 push-to-talk（移 TextField → mic dock，SD18 V7 72-80pt glass）。
- 物理置顶作废（S5/S6）→ AD-12 原地放大 hero + ScrollViewReader。
- **触摸调节真实完整**（SD7：dial/percent ± 步进 / stepper 段位 / toggle 切 / badge 循环，走 **mock store**，语音读当前态推理，联动 10 族，静默无 TTS）；摘要卡触摸只读（SD23 7.F1）、展开卡（composite）才有数值控件调（SD6）。
- 演绎控制台（SD13-15）= iPhone 控制中心式竖排模块卡（常态/整车/环境/座舱）+ 常态卡 [查看全部] AllStateSheet（33 base）+ segmented 互斥 + 视觉对齐 10 族卡 iOS26 glass；时段 ⊥ 主题正交。
- capsule route 不拍死（U31 spike 模拟器观感，GPU 真机 DEFERRED）+ U30 砍折射 shader。
- orb / 思考链路 = Phase 5 DEFERRED（mic dock/对话流/氛围灯不跟 orb defer）。
- gpt anchor 图非权威（只借视觉灵感 + 像素对比基准，布局以 SD/AD 为准）。

---

## Global Constraints

- **平台锁**：App iOS26.0/macOS26.0；Core `Package.swift` `.iOS(.v17)/.macOS(.v14)` 不动。禁 `#available(iOS 17|18)`（`check-platform-vs-version-guard.sh`）；平台差异 `#if !os(macOS)`，a11y `if reduceMotion`。
- **全 mock 前台**：依赖后端的交互（触摸 state 联动/语音推理/演绎控制台 force）全用 mock（mock store 写 + mock snapshot 切 + mock 预设响应）；不接真 NLU/语音/LoRA/ASR-TTS；不改 state-cells.yaml 契约语义。
- 🔴 **wiring gate（`check-contentview-uses-display-catalog.sh`）**：ContentView body 必字面 `familyDisplays(from:` + `VehicleCardsGrid(displays: familyDisplays` + 禁 LazyVGrid。A+ 弥合：`familyDisplays` computed 从 `snapshot.storeCells` 算，字面接线不破。
- **U30 GPU**：capsule/氛围灯不跑 Inferno 折射 layerEffect；只 native `.glassEffect` + Vortex 粒子（Canvas）+ image `.offset`。
- **视觉 SSOT**：色/字/间距/圆角全从 tokens.md → DesignTokens.swift 取，禁硬编 hex；制冷热色落 tokens **§1**（`semantic.cool/warm`）。
- **7 态穷尽**：DemoVisualState 7 态独立分支无二值/无 default 吞（`check-no-binary-visualstate.sh`）。
- **测试 = XCTest**（禁 Swift Testing `@Test`）；夹具真实 init `DemoVehicleStateCell(key:actualValue:revision:visualState:)`（**非 key:value:**，`Core/State/DemoVehicleStateStore.swift:39`，含 `visualState` 字段）。
- **Grid 固定列**（非 LazyVGrid.adaptive）：iPhone 2/iPad 4/Mac 5。
- **iOS 模拟器验收不真机**：5-gate/截图/anchor 像素对比走 simctl；capsule GPU 真机 DEFERRED。
- **demo 轻治理**：语义安全带（契约存在性/穷尽/聚合 resolver）不省；量产全链路/真后端砍。

---

## heavy-work harness 管控（每 Phase）

1. **每 Phase = 执行线 + Phase gate**。
2. **Phase gate**：`swift test` 0 fail + 碰共享 App/Core 的 Phase **双端 build**（`MAformacIOS`+`MAformacMac` BUILD SUCCEEDED）+ pre-commit 机械门绿（no-binary-visualstate/platform-vs-version-guard/wiring）+ 主线程亲核 + 分 commit。
3. 🔴 **每 Phase 结束派 subagent codex 审计**（磊哥 2026-06-25 定）：
   - **agent**：`codex:codex-rescue`，**`run_in_background=true`**，**每次 ~20 分钟预算**。
   - **多维度**（类似 gptPRO 代码审计，每条 P0/P1/P2 + file:line）：① 🔴 **anchor 像素级对比（重点）** ② spec/grill 覆盖（该 Phase SD/AD 硬约束全实现）③ 接口/契约一致性 + wiring gate ④ 5-gate 审美 ⑤ mock 边界（不接真后端）⑥ 代码质量（穷尽 switch/无 default 吞/不破 222 测试）⑦ 迁移安全（strangler）。
   - 🔴 **anchor 像素对比 = 硬门（磊哥 2026-06-25：必须超过 anchor）**：codex Bash `simctl` 截图 → `magick compare -metric AE/RMSE` 或 PIL 逐区域 diff，量化偏差（布局错位 px / 色值 ΔE / 字号比 / 留白比 / 视觉重量）。🔴 **判定标准 = 实装视觉质量【达到或超过】anchor**（**非 1:1 复刻**——grill 有很多创新点[连续舞台/制冷热/氛围灯炸场/capsule diorama]，实装应比 anchor **更惊艳/更高级**，不是低于 anchor）：anchor = 视觉质量**下限基准**，**任一区域明显逊于 anchor（视觉重量/层级/质感/留白塌）= FAIL 返工**；布局/创新以 SD/AD 为准（可不同于 anchor 布局，但视觉质量必须 ≥ anchor）。截图先尺寸归一 + crop/mask 动态区域（粒子/numericText 滚动/breathe）排噪声，静态布局/色值/质感/视觉重量逐区域过硬门。anchor PNG = `docs/design/anchors/`（本地 25 张）。
   - 审计报告落 `docs/research/2026-06-25-a2-execution/phase-N-codex-audit.md`。
4. **主线程亲核** > 信 codex（claim-vs-reality 第10变体）：load-bearing 数字/像素偏差独立核。
5. 🔴 **每 Phase 后回顾基线（derived-tracking-writeback gate）**：回读 §0 + 更新配套索引（消减该 Phase 的 grill 项）+ landing matrix。
6. **沉淀（不攒）**：坑→lessons K / 元认知→rules / 技能→Tools/skills；adopt>build（Vortex/axiom）。
7. **整体收口**：loopaudit（≥3 subagent 至无 P0/P1）+ 全 phase anchor 像素对比汇总 + closeout receipt。

---

## File Structure

**新建：**
- `Core/Presentation/PresentationSnapshot.swift` — A+ vocabulary 容器 + `MockPresentationSnapshotProvider` + `store→snapshot` adapter（纯 Foundation，命名带 Mock）。
- `Core/Presentation/SemanticColorMapper.swift` / `FamilyIconMapper.swift` / `AmbientBurstColorMapper.swift`（氛围灯 8 色混合）。
- `App/MicDock.swift`（SD18 V7）/ `App/DialogueStream.swift`（SD3）/ `App/SettingsRefreshControls.swift`（SD8）/ `App/AmbientEdgeBurst.swift`（SD4）/ `App/ContextCapsule.swift`（SD24-25）。
- `App/DemoControlPanel.swift`（SD13-15 演绎控制台）+ `App/AllStateSheet.swift`（33 base 弹窗）。
- `Tests/MAformacCoreTests/{PresentationSnapshot,SemanticColorMapper,FamilyIconMapper,AmbientBurstColorMapper}Tests.swift`（XCTest）。

**修改：**
- `App/ContentView.swift`（连续舞台四 zone）/ `App/DesignTokens.swift` + `docs/design/tokens.md`（制冷热 §1 + 氛围灯 + hex FROZEN）。
- `Core/Presentation/UIValueTypeMapper.swift`（VehicleCardDisplay 加 activeCell/siblingCells + familyDisplays(from:activeCells:)）。
- `App/ExpandedFamilyCard.swift` + `App/ValueControlView.swift`（SD7 触摸调节回调 → mock store 写）。
- `Core/State/DemoVehicleStateStore.swift`（🔴 `applyMockTransition:138` visualState 值变化→changing，codex P0-3；守 222 测试）。
- `MAformac.xcodeproj/project.pbxproj`（portrait lock `UISupportedInterfaceOrientations`=Portrait + Vortex package ref，GLM P1-3/P1-4）。

**Tracking（每 Phase 消减，GLM P2-3）：**
- `docs/grill-checklist/uiue-a2-grill-coverage-index.md` — phase coverage burn-down tracker（每 Phase 后 `- [ ]`→`- [x]`，Phase 7 grep 统计未消减）。

**🔴 巨人肩膀 adopt（不手搓，development-workflow §0 + blueprint-teardown；本机 ref-repos/skills）：**
- mic dock 波形 → **DSWaveformImage** / 对话流 DialogueBubble → **exyte-Chat** / 触控 binding·手势 → **axiom-swiftui** + **IceCubesApp** / 演绎控制台 control center → **axiom-design**(HIG) + **IceCubesApp·ShipSwift** / 氛围灯·capsule 粒子 → **Vortex** + **SwiftUIShaders·open-swiftui-animations** / capsule glass → **Inferno** + native `.glassEffect`(LiquidGlassReference github-first 实装前 clone) / orb(Phase5) → **Orb** / build·验收 → **ios-simulator-skill** + `build-ios-apps-skills` + **axiom-build·axiom-testing**。
- ref-repos: `~/workspace/raw/05-Projects/MAformac/ref-repos/{Vortex,Inferno,exyte-Chat,DSWaveformImage,IceCubesApp,Orb,SwiftUIShaders,open-swiftui-animations,ShipSwift}`（只读不入仓）；skills: `Tools/skills/{axiom,ios-simulator-skill}`；plugins: `Tools/agent-platform-plugin-refs/build-{ios,macos}-apps-skills`。**实装前先读对应 SKILL.md**（CLAUDE §73 纪律）。

---

## Phase 0 — bridge mock vocabulary 容器（TDD）

### Task 0.1: PresentationSnapshot A+ 容器 + adapter（@MainActor）

**Files:** Create `Core/Presentation/PresentationSnapshot.swift` + Test `Tests/MAformacCoreTests/PresentationSnapshotTests.swift`

**Produces:** `DemoRuntimeResultKind`(8 类) / `PresentationProofClass` / `DemoContext`(四维 vehicle{speed,gear}+environment{weather,timePeriod}) / `PresentationSnapshot{traceId, storeCells:[DemoVehicleStateCell], activeCells:[FamilyCardID:String], refusedCell:String?, context, orbState, dialogText, readbacks, resultKind, proofClass}`（携带 storeCells+activeCells 供 ContentView 调 familyDisplays，**不放平行卡片 model**）/ `MockPresentationSnapshotProvider`（coldStart/acStarted/coolingMode/safetyRefusal…）/ `@MainActor extension PresentationSnapshot.from(store:activeCells:context:resultKind:)`（GLM P1-2）。

- [ ] **Step 1: 写 failing test（XCTest，契约闭合非烟雾，GLM P0-1: 不调 activeCells；coldStart cells 明确）**

```swift
import XCTest
@testable import MAformacCore

final class PresentationSnapshotTests: XCTestCase {
    func testResultKindHasAllEightCases() {
        let all: [DemoRuntimeResultKind] = [.acceptedToolCall, .clarifyMissingSlot,
            .refusalNoAvailableTool, .refusalSafetyOrPolicy, .alreadyStateNoop,
            .runtimeError, .cancelled, .partialAcceptPartialRefuse]
        XCTAssertEqual(Set(all).count, 8)
    }
    func testContextFourDimensions() {
        let s = MockPresentationSnapshotProvider.coldStart()
        XCTAssertGreaterThanOrEqual(s.context.vehicle.speed, 0)
        XCTAssertFalse(s.context.vehicle.gear.isEmpty)
        XCTAssertFalse(s.context.environment.weather.isEmpty)
        XCTAssertFalse(s.context.environment.timePeriod.isEmpty)
    }
    // GLM P0-1: 用现有 familyDisplays(from:) 不带 activeCells（activeCells 留 Task 1.2）
    func testColdStartTenFamiliesViaFamilyDisplays() {
        let s = MockPresentationSnapshotProvider.coldStart()
        let cards = VehicleCardDisplay.familyDisplays(from: s.storeCells)
        XCTAssertEqual(Set(cards.compactMap { $0.familyCardID }).count, FamilyCardID.allCases.count)
    }
    func testMockProofClassIsLocalMock() {
        XCTAssertEqual(MockPresentationSnapshotProvider.coldStart().proofClass, .localMock)
    }
}
```

- [ ] **Step 2: run fail** → FAIL（类型未定义；夹具真实 API 不先爆）。
- [ ] **Step 3: 实装**（4 vocabulary 类型 + provider；🔴 **GLM P2-3: `coldStart()` 用 `storeCells: []` 靠 `familyDisplays` placeholder 出 10 族「待命」**——idle 全景态 SD1，不造 `family.ac` 假 key + context mock `speed:0,gear:"P",weather:"晴",timePeriod:"日间"` + adapter `@MainActor`）。
- [ ] **Step 4: run pass** → PASS。
- [ ] **Step 5: commit** `feat(uiue): A+ PresentationSnapshot 容器+adapter (AD-RPB-015)`

### Phase 0 gate + codex 审计（20min，anchor 像素对比此 phase 无 UI 跳过像素对比，验 vocabulary 完整性/契约闭合/@MainActor）+ 基线回顾（不勾 OpenSpec，更新索引 Phase 0 done）。

---

## Phase 1 — 语义派生层（TDD，含氛围灯 8 色）

### Task 1.1: SemanticColorMapper 制冷热（SD20，token §1）
**Produces:** `enum ThermalTint{cooling,heating,neutral}` + `acThermalTint(siblingCells:)`。
- [ ] TDD（XCTest，init `actualValue:`）：制冷→cooling/制热→heating/**无 mode→neutral 不吞错**；实装（无 `default` 吞）；commit `feat(uiue): SemanticColorMapper 制冷热 (SD20)`

### Task 1.2: 扩 VehicleCardDisplay + familyDisplays 透传 + siblingCells 填充（GLM P0-2/P1-1）
**Files:** Modify `UIValueTypeMapper.swift` + Test `VehicleCardDisplayTests.swift`（XCTestCase 追加）
**约束（GLM 修复）：**
- `VehicleCardDisplay` 加 `activeCell:String?=nil` + `siblingCells:[DemoVehicleStateCell]=[]`（默认值向后兼容）。
- `familyDisplays(from:activeCells:[FamilyCardID:String]=[:])`（默认空，现有调用不破 strangler）。
- 🔴 **GLM P0-2**：`summaryDisplay` 必设 `siblingCells: familyCells`（否则制冷热假绿）。
- 🔴 **GLM P1-1**：非 normal 态（族 dominant visualState ≠ normal）+ activeCells 命中 → 主值切 activeCell base。

- [ ] **Step 1: 写 failing test（GLM P0-2 siblingCells + P1-1 visualState:.changing + normal negative）**

```swift
func testAcDisplayCarriesModeSiblingForThermalTint() {  // GLM P0-2
    let cells = [
        DemoVehicleStateCell(key: "ac.temp_setpoint[主驾]", actualValue: "24", revision: 1),
        DemoVehicleStateCell(key: "ac.mode", actualValue: "制冷", revision: 1)
    ]
    let ac = VehicleCardDisplay.familyDisplays(from: cells).first { $0.familyCardID == .ac }
    XCTAssertEqual(ac?.siblingCells.contains { $0.key == "ac.mode" }, true)
}
func testActiveCellOverridesPrimaryOnlyWhenNonNormal() {  // GLM P1-1
    let cells = [
        DemoVehicleStateCell(key: "seat.heat_level", actualValue: "0", revision: 1),
        DemoVehicleStateCell(key: "seat.backrest_angle", actualValue: "30", revision: 2, visualState: .changing)
    ]
    let seat = VehicleCardDisplay.familyDisplays(from: cells, activeCells: [.seat: "seat.backrest_angle"])
        .first { $0.familyCardID == .seat }
    XCTAssertEqual(seat?.valueText.contains("30"), true)
}
func testActiveCellDoesNotOverrideWhenNormal() {  // GLM P1-1 negative
    let cells = [DemoVehicleStateCell(key: "seat.heat_level", actualValue: "0", revision: 1, visualState: .normal),
                 DemoVehicleStateCell(key: "seat.backrest_angle", actualValue: "30", revision: 1, visualState: .normal)]
    let seat = VehicleCardDisplay.familyDisplays(from: cells, activeCells: [.seat: "seat.backrest_angle"])
        .first { $0.familyCardID == .seat }
    XCTAssertEqual(seat?.valueText.contains("30"), false)  // normal 态不切
}
```

- [ ] Step 2 run fail → Step 3 实装（summaryDisplay 填 siblingCells + 非 normal activeCells 切）→ Step 4 run pass（含 222 不回归）→ Step 5 commit `feat(uiue): VehicleCardDisplay activeCell+siblingCells 填充 (CC1 SD19/SD20, GLM P0-2/P1-1)`

### Task 1.3: FamilyIconMapper（V9，GLM P2-1 curated allowlist）
**Produces:** `sfSymbol(for:FamilyCardID)->String`。
- [ ] TDD：10 族全非空 + **GLM P2-1: 注释 curated allowlist 表（每族 symbol 名 + 选 Apple 稳定符号避冷门）**；实装穷尽 switch 无 default；commit `feat(uiue): FamilyIconMapper V9 (10 族 curated SF Symbol)`

### Task 1.4: AmbientBurstColorMapper 氛围灯 8 色混合（SD4）
**Produces:** `enum AmbientBurstColorMapper{ static func burstGradient(for color:String)->[String] }`（8 单色→该色为主混合：紫→紫金/红→红橙/青→青紫/绿→绿青/蓝→蓝青/白→白金/橙→橙金/黄→黄金，SD4:69；色名查 tokens §1.4）。
- [ ] TDD：8 色全有混合映射（契约存在性无 default 吞）；实装穷尽；commit `feat(uiue): AmbientBurstColorMapper 8 色混合 (SD4)`

### Phase 1 gate + codex 审计（20min：契约存在性/无 default 吞/222 不回归 + anchor 此 phase 无 UI）+ 基线回顾（索引消减 SD20/SD19/SD4-mapper/V9）。

---

## Phase 2 — 连续舞台 visual（5-gate + anchor 像素对比）

> View task = 实装[约束] → 双端 build → simctl 截图 → **anchor 像素对比 + 5-gate** → commit。

- [ ] **Task 2.1** ContentView 消费 snapshot + 去品牌/TextField + 设置刷新右上（SD23/24）：`familyDisplays` computed 从 `snapshot.storeCells` 算（保 wiring gate 字面）；删 brandHeader/TextField；`#if DEBUG` 触发按钮切 mock snapshot。anchor 对比 `anchor-01`。
- [ ] **Task 2.2** mic dock floating glass capsule（SD18 V7：72-80pt，左状态点/中「按住说话」/右波形，`safeAreaInset(.bottom)` 钉底）。anchor 对比 mic dock 区域。
- [ ] **Task 2.3** DialogueBubble 对话流替 readbackPanel（SD3：user 右/assistant 左 ScrollView 累积 + scrollTo(last)）。anchor 对比对话区。
- [ ] **Task 2.4** tokens hex FROZEN + 制冷热 §1 + 制冷热渲染 + SD5 摘要卡 `.regularMaterial` + SD21 hero range bar（ac 卡按 ThermalTint 蓝/红，grep 无硬编 hex）。anchor 对比制冷/制热卡。
- [ ] **Task 2.5** 层级 z-order + 滚动（SD22：氛围 overlay allowsHitTesting(false) > mic dock > orb > dim > 内容；手动滚暂停 scrollTo；fade 按 active；ScrollViewReader 激活族滚入 AD-12）。
- [ ] **Task 2.6** 边界态 + 注意力（SD23/V8：文案 30 字 truncate/ASR 二分 mock/族外 blocked_hard；激活族重量≥次要 1.5x + 次要 fade + FamilyIcon）。
- [ ] **Task 2.6a** portrait lock（GLM P1-4）：Modify `MAformac.xcodeproj/project.pbxproj` iOS `INFOPLIST_KEY_UISupportedInterfaceOrientations`=Portrait（**非只 SwiftUI #if**）；验证 simctl 旋转后仍竖屏。
- [ ] **Task 2.7** 氛围灯卡片渐变 AmbientCardGradient（SD4 动作1：氛围灯卡 colorSwatch 升级**渐变该色**常驻，消费 ambient.color）。anchor 对比氛围灯卡。
- [ ] **Task 2.8** SD8 设置/刷新功能：`SettingsRefreshControls` 补功能——↻ 刷新=DemoReset 归 idle（切 coldStart snapshot）+ ⚙️ 设置面板（**主题切换 deepSpace↔ivory 实时** + 占位场景宏 force 入口 `#if DEMO_MODE`，连 Phase 4）。anchor 对比右上控件。

每 task：Step 实装 → 双端 build → simctl 截图 → **codex anchor 像素对比 + 5-gate** → commit。

### Phase 2 gate + codex 审计（20min，🔴 anchor 像素对比为重点：连续舞台/四 zone/制冷热/氛围灯卡 vs anchor 逐区域偏差）+ 14 张 simctl 5-gate + 勾 OpenSpec §8.A + 索引消减 SD3/5/18/22/23/24-顶栏/V8/V9/SD4-卡片/SD8-部分。

---

## Phase 3 — 触摸调节 + state 联动 + 语音推理（全 mock，SD6/SD7，触控状态链细化到可实现级）

> 全 mock 前台：触摸→mock store 写→snapshot 刷新→卡片联动；语音推理→mock 预设响应。**不接真 NLU/语音**。落 spec Requirement「expanded-card controls SHALL update mock state」。
> 🔴 **亲核现状（codex P0-3 + GLM P1-2 坐实）**：① `ValueControlView`（`App/ValueControlView.swift:14-22`）= 纯展示控件**无交互回调** ② `applyMockTransition`（`Core/State/DemoVehicleStateStore.swift:138`）`cell.visualState = desiredValue=="on" ? .satisfied : .normal`——**温度/百分比/stepper 值变化落 `.normal` → 触控联动不亮 = 假绿** ③ mock 写 API 存在：`applyMockTransition(DemoMockTransition(key:desiredValue:source:))`。
> adopt **axiom-swiftui**（binding/gesture/state）+ **IceCubesApp**（成熟交互参考），不手搓。

### Task 3.1a: ValueControlView 交互回调（5-gate；clamp/cycle 复用 ValueRangeMapper）
**约束:** 加 `struct ValueControlActions { var increment, decrement, toggle, cycleBadge: (() -> Void)? }`；`ValueControlView` 加 `var actions = ValueControlActions()`，dial/percent/stepper ± 接 increment/decrement，toggle 接 toggle，badge 接 cycleBadge。**值 clamp/cycle 复用 `ValueRangeMapper`**（dial 18-32 / percent 0-100 / stepper 离散档 0-3·1-10 / badge 8 色循环），**SHALL NOT 在 view 重写 range 逻辑**（防与 mapper 漂移）。
- [ ] 实装 → build → simctl(展开卡控件可点) → commit `feat(uiue): ValueControlView 交互回调 (SD7, adopt axiom-swiftui)`

### Task 3.1b: ExpandedFamilyCard 接 callback → nextValue（5-gate）
**约束:** `ExpandedFamilyCard`/row 加 `let onMockTransition: (String, String) -> Void`（key, nextValue）；控件 actions 经 `ValueRangeMapper` 算 nextValue（clamp/cycle）→ `onMockTransition(row.key, nextValue)`。
- [ ] 实装 → build → simctl → commit `feat(uiue): ExpandedFamilyCard onMockTransition callback (SD7)`

### Task 3.1c: ContentView overlay 持 store 写 + snapshot refresh（5-gate）
**约束:** expanded overlay `onMockTransition` → `store.applyMockTransition(DemoMockTransition(key:key, desiredValue:nextValue, source:.user))` → `snapshot = PresentationSnapshot.from(store:store, activeCells:[family:key], context:snapshot.context, resultKind:.acceptedToolCall)` → 卡片+numericText 联动。**摘要卡触摸只读**（SD23 7.F1，不调 store）。**静默无 TTS**。
- [ ] 实装 → build → simctl 录屏(调温度卡片联动) → commit `feat(uiue): ContentView 触控→store→snapshot 链路 (SD7)`

### Task 3.1d: 🔴 applyMockTransition visualState 语义修复（TDD，codex P0-3 核心）
**Files:** Modify `Core/State/DemoVehicleStateStore.swift:138` + Test
**约束:** mock transition **值真变化** → `.changing`/`.satisfied`（非只 `"on"`→satisfied / 其它→`.normal`）；toggle `"on"/"off"` 仍 satisfied/normal。🔴 **守现有 222 测试不破**（先 grep `applyMockTransition` 现有测试断言，确认改 visualState 不破）。
- [ ] **Step 1: failing test**
```swift
func testValueChangeProducesNonNormalVisualState() {  // codex P0-3
    let store = DemoVehicleStateStore(cells: [DemoVehicleStateCell(key:"ac.temp_setpoint[主驾]", actualValue:"24")])
    _ = store.applyMockTransition(DemoMockTransition(key:"ac.temp_setpoint[主驾]", desiredValue:"26", source:.user))
    XCTAssertNotEqual(store.cell(for:"ac.temp_setpoint[主驾]")?.visualState, .normal)
}
```
- [ ] Step 2 run fail → Step 3 实装（`visualState = transition.desiredValue == oldValue ? cell.visualState : (.changing)`；toggle off→normal 保留）→ Step 4 run pass（含 222 不回归）→ Step 5 commit `fix(core): applyMockTransition 值变化→changing 非 normal (codex P0-3)`

### Task 3.2: state 联动展示（SD7）
触摸调任意族 → mock store 写 → 10 族卡片联动（mock 预设联动，如开空调动 `ac.power`+`ac.temp`）。实装 → build → simctl → commit。

### Task 3.3: 语音推理 mock 预设（SD7 卖点）
mock 预设「手动调 26 → store=26 → 语音『我有点冷了』→ mock 读当前态 `store.cell(for:)` → 升温 → 输出 28/27 → 对话流显示」；`#if DEBUG` 触发，**mock 预设响应非真 NLU**。实装 → build → simctl 录屏 → commit。

### Phase 3 gate + codex 审计（20min，多维 + 交互链路正确性 + mock 边界 + anchor 像素对比展开卡）+ 索引消减 SD6/SD7。

---

## Phase 4 — 演绎控制台（全 mock force，SD13/14/15/8）

> 方案经理幕后工具，force mock context/state。视觉对齐 10 族卡 iOS26 glass（SD15）。

- [ ] **Task 4.1** `DemoControlPanel`（SD14）：iPhone 控制中心式竖排模块卡（常态/整车/环境/座舱），iOS26 glass 功能层 + material 模块卡 + segmented iOS picker 风格。从设置入口进（SD8）。anchor 对比控制台（若 anchor 有；无则对齐 10 族卡视觉体系 SD15）。
- [ ] **Task 4.2** 整车 + 环境 force（SD13/14）：整车 时速 segmented[静态/泊车/城市/高速] + 挡位[P/R/N/D] / 环境 天气[晴/雨] + 时段[白天/夜晚] **互斥单选** → force **mock bridge context**（AD-RPB-014 context 四维切换，驱动 capsule + 安全 guard mock）。
- [ ] **Task 4.3** 常态运行卡 + AllStateSheet（SD13/14）：常态卡 ● 当前常态 + [查看全部≣] → `AllStateSheet`（33 base 按 10 族分组网格弹窗，顺序铺开 SD15）+ [⟲ 一键复位常态]=DemoReset（mock NormalRunPreset 默认值集）。
- [ ] **Task 4.4** 座舱场景宏 force（SD14/8）：场景宏库[上车/离车/雨天/困了] → force mock 预设（`#if DEMO_MODE`）+ 设备端态链 10 族卡片调（SD7）。

每 task：实装 → 双端 build → simctl 截图 → **codex 审计（20min，多维 + anchor 像素对比：控制台模块卡 vs anchor/10 族卡视觉体系 + force mock 正确性）** → commit。

### Phase 4 gate + codex 审计 + 索引消减 SD8/13/14/15。

---

## Phase 5 — 氛围灯炸场 AmbientEdgeBurst（SD4 动作2）

- [ ] **Task 5.1** `AmbientEdgeBurst`（SD4）：屏幕边缘混合发光（消费 AmbientBurstColorMapper 8 色，Task 1.4）+ **仅氛围灯指令触发** → 闪烁 + **Vortex Canvas 粒子爆发 5s** phaseAnimator → fade out；`allowsHitTesting(false)`（氛围层不挡交互）；深空暗底主场（米白亮底弱，SD 行 187 pre-mortem）。

实装 → 双端 build → simctl 录屏（氛围灯爆发 5s）→ **codex 审计（20min + anchor 对比边缘发光 vs anchor 氛围图）** → commit `feat(uiue): AmbientEdgeBurst 边缘炸场 (SD4)`

### Phase 5 gate + codex 审计 + 索引消减 SD4-炸场。

---

## Phase 6 — context capsule diorama（route spike，GLM P1-3 Vortex App target）

- [ ] **Task 6.1** capsule route spike（模拟器观感 A 视频 loop vs C-lite，U31 不预拍）。🔴 **GLM P1-3 + codex P1 Vortex 可复现接法（写死 URL/tag/fallback）**：App 是 Xcode project 非 SPM → Modify `MAformac.xcodeproj/project.pbxproj` 加 Vortex package reference（URL `https://github.com/twostraws/Vortex`，**pin 到最新 stable release tag**：实装 `git ls-remote --tags https://github.com/twostraws/Vortex` 查具体 tag → 锁 `Package.resolved` 入仓）+ product dependency 加 MAformacIOS·MAformacMac target。🔴 **fallback 写死**：Xcode SPM 集成失败/不可复现 → 降级**纯 SwiftUI `Canvas` 粒子 placeholder**（C-lite spike 不卡，先验观感，Vortex 单独 task 接）。验证 `xcodebuild -scheme MAformacIOS build` 能 `import Vortex`。spike-result.md 记观感（route 磊哥拍）。
- [ ] **Task 6.2** `ContextCapsule` 实装（route 定后）：消费 `snapshot.context` 四维 + crossfade（glassEffectID morph）+ 预加载 + 图标在 capsule 外（SD24）。

每 task：实装 → 双端 build → simctl → **codex 审计（20min + anchor 像素对比 capsule vs anchor-00-diorama）** → commit。

### Phase 6 gate + codex 审计 + 索引消减 SD24/25。

---

## Phase 7 — 验收收口

- [ ] **Task 7.1** 全量门：`swift test` 0 fail + 双端 `xcodebuild` SUCCEEDED + `make verify-all` exit0 **+ 另跑** `bash Tools/checks/{check-no-binary-visualstate,check-platform-vs-version-guard,check-contentview-uses-display-catalog}.sh` 全绿（GLM P2 口径：make verify-all 含 wiring+swift test，两 shell gate 另跑）。
- [ ] **Task 7.2** 全 phase anchor 像素对比汇总 + visual-acceptance【用户演绎体验视角】（方案经理 5min 台本 + 客户旁观 + corner case，还原投屏 V10，逐张 Read）+ 14 张满屏单态 5-gate。
- [ ] **Task 7.3** loopaudit（≥3 subagent 至无 P0/P1）+ **基线级联回写**（grill-定档/landing matrix/tasks.md §8/CLAUDE §9）+ **coverage 索引消减统计（GLM P2-3）**：`grep -c '\- \[ \]' docs/grill-checklist/uiue-a2-grill-coverage-index.md` 统计未消减项，A-2 实装项应全 `- [x]`（DEFERRED ⏳ 不计）+ 沉淀（坑→lessons / 元认知→rules / 技能）+ closeout receipt + handoff。

---

## 附录 A — simctl 截图 + anchor 像素对比命令模板（GLM P2-2）

```bash
# 1. boot + install + launch (force-state)
xcrun simctl boot "iPhone 17 Pro Max" 2>/dev/null || true
xcodebuild -scheme MAformacIOS -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  -derivedDataPath .build/dd build
xcrun simctl install booted .build/dd/Build/Products/Debug-iphonesimulator/MAformacIOS.app
xcrun simctl launch booted lab.rayw.MAformac.ios -forceVisualState <态>   # DebugGallery launch arg
# 2. screenshot
xcrun simctl io booted screenshot docs/research/2026-06-25-a2-execution/shots/phase<N>-<态>.png
# 3. anchor 像素对比 (codex 审计跑)
magick compare -metric RMSE docs/research/.../shots/phase<N>-<态>.png \
  docs/design/anchors/anchor-<NN>.png /tmp/diff-<N>.png 2>&1   # 量化偏差; 区域 diff 用 PIL crop
```

> codex 审计逐区域报：布局错位 px / 色值 ΔE / 字号比 / 留白比 / 视觉重量偏 anchor 多少。

---

## Self-Review — 三路审计修复 + grill 覆盖对照

**三路审计修复（subagent CC + codex-rescue + GLM）：** A+ bridge / XCTest+init(actualValue) / wiring gate 弥合 / mic dock+对话流四 zone / phase gate 不勾 OpenSpec / strangler / siblingCells 填充(GLM P0-2) / activeCell visualState 测试(GLM P1-1) / Task 0.1 测试不带 activeCells(GLM P0-1) / @MainActor adapter(GLM P1-2) / Vortex App target(GLM P1-3) / portrait pbxproj(GLM P1-4) / FamilyIcon allowlist + simctl 模板 + coldStart cells(GLM P2) / 制冷热 §1 / 双端 build / Vortex pin。

**grill 覆盖（详见配套索引 `uiue-a2-grill-coverage-index.md`）：** SD1(P0 coldStart)/SD2(P2 mic dock UI,ASR DEFERRED)/SD3(P2)/SD4(P1.4+P2.7+P5)/SD5(P2.4)/SD6+SD7(P3)/SD8(P2.8+P4)/SD9(P2.6 部分)/SD10(现有 4b)/SD11(P2.4)/SD12(Phase5 宏 DEFERRED)/SD13-15(P4)/SD16(orb Phase5 DEFERRED)/SD17(散)/SD18-25(P0-2,6)。

**Type 一致性：** PresentationSnapshot/DemoRuntimeResultKind(8)/DemoContext(四维)/ThermalTint/AmbientBurstColorMapper 跨 Phase 一致；VehicleCardDisplay 扩 activeCell/siblingCells + familyDisplays(from:activeCells:) 跨 0.1/1.2/2.x 一致；夹具全 `DemoVehicleStateCell(key:actualValue:revision:visualState:)`。

> ⚠️ spike 不预拍：capsule route 由 Task 6.1 模拟器观感 spike → 磊哥拍。

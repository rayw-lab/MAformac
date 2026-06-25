# UIUE A-2 (step2) ui-presentation §8 完整产品形态 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development 或 superpowers:executing-plans 逐 task 执行。Steps 用 checkbox（`- [ ]`）。
>
> 🔴 **执行方 = CC 主窗口主持**（磊哥 2026-06-25 定「定稿后不丢 codex」）。任何执行方**必先读「§0 背景决策包」+ 每 Phase 后回读基线文档**（防自拍已决决策）。
>
> 🟢 **v2 定稿（2026-06-25）**：经 subagent CC（adversarial）+ codex-rescue 两路审计辩证收 + 磊哥拍 **A+**（PresentationSnapshot 保 bridge vocabulary 容器 / 卡片渲染复用现有 `VehicleCardDisplay`+`familyDisplays(from:)`，不造平行 SnapshotCard）。修复了：测试框架/init API、wiring gate、mic dock+对话流、phase gate 假绿、token §1、strangler、双端 build、Vortex pin、契约回写。

**Goal:** 把 `App/ContentView.swift` 从临时态（TextField 输入 + 「MAformac」品牌字 + 直接消费 store）重构成**完整产品形态连续舞台**——消费 A+ bridge mock `PresentationSnapshot`（vocabulary 容器），落地 7 态/制冷热 sibling/activeCell/mic dock+对话流四 zone/层级滚动/边界态/context capsule diorama，**在 iOS 模拟器**验收到接近 anchor 锚点集的视觉。

**Architecture（A+，磊哥拍）:** 四层分刀。① **bridge mock vocabulary 容器**（`PresentationSnapshot` 携带 cells + context 四维 + activeCells map + orb/dialog/readbacks + resultKind 8 类 + proofClass + refusedCell，AD-RPB-001~015 vocabulary freeze；**卡片渲染复用现有 `VehicleCardDisplay`，不造平行 SnapshotCard**）→ ② **语义派生层**（SemanticColorMapper 制冷热 / 扩 `VehicleCardDisplay` 加 activeCell·siblingCells + familyDisplays 透传 / FamilyIconMapper，**TDD XCTest**）→ ③ **连续舞台 View 重构**（ContentView 四 zone + mic dock + 对话流，**simctl 5-gate 视觉验收**）→ ④ **context capsule diorama**（route spike A vs C-lite **模拟器观感**，gated）。

**Tech Stack:** SwiftUI（iOS26/macOS26 锁）、**XCTest**（与现有 25 文件/222 测试一致）、`simctl`（force-state 截图）、Vortex（粒子 adopt，pin commit）、native `.glassEffect`（capsule 壳 + mic dock）。

**🔴 分层开发 convention（磊哥定）：**
- **语义派生层 / bridge mock / 契约存在性 task** → 标准 **TDD step**（写 failing test → run fail → 实装 → run pass → commit），plan 内给**完整 XCTest + 实装代码**。
- **View 层 task（ContentView / mic dock / 对话流 / capsule）** → **5-gate 验收 step**（实装[约束] → `xcodebuild` 双端 build → `simctl` 截图 → visual-acceptance 5-gate 对比 anchor → commit），plan 内给**精确 interface + 关键代码骨架 + 验收门**，不写死整个 view 每一行（SwiftUI view 视觉迭代）。

---

## §0 🔴 背景决策包（执行前必读 + 每 Phase 后回读）

> 执行方不一定在今天的 grill 现场。以下是**已拍死的背景决策**，承接不自拍；冲突念头 = 停，回读对应基线（`grill-recall-decisions-first` + `goal-dispatch-trace-to-source`）。

**必读基线文档（起手 + 每 Phase 后回读）：**
1. `CLAUDE.md` + `docs/lessons-learned.md`（**K 段 = 本 UIUE session 教训**）。
2. `docs/uiue-storyboard-grill-decisions.md` — **SD3（对话流 DialogueBubble）/ SD5（摘要卡 material）/ SD18-25**（视觉块 V1-V12 / 制冷热 SD20 / hero range bar SD21 / 层级滚动 SD22 / 边界态 SD23 / context capsule SD24-25）。
3. `docs/grill-checklist/uiue-grill-定档-2026-06-25.md` — **作废清单 S1-S10**（引决策前查作废 registry）。
4. `openspec/changes/define-runtime-presentation-bridge/design.md` — **A-1 bridge AD-RPB-001~015**（4 对象 vocabulary；AD-RPB-015 = bridge 是 cross-artifact 单一权威）。
5. `openspec/changes/ui-presentation/design.md` **AD-13/AD-14** + `tasks.md §8`。
6. `docs/design/tokens.md`（视觉 SSOT，**写任何 UI 前必读**；🔴 制冷热语义色在 **§1**，非 §2[§2 是 7 态色]）+ `docs/design/INDEX.md`。
7. `docs/research/2026-06-25-context-capsule-2.5d-tech/README.md`（capsule 依赖栈 + Vortex/Inferno teardown）。

**已拍死的关键决策（不自拍）：**
- **default_scope 已落 main**（`17ae332 feat(c2): add default scope to state cells`，state-cells.yaml 11 处 default_scope）→ scope 卡片读 `default_scope` SSOT，**不手写**「座位→主驾」。
- 🔴 **state-cells.yaml 已是 10 族全集（实况 31 base）**；`openspec/changes/ui-presentation/design.md:29`「仅 4 族」是 **stale 注释**，以 yaml 实况为准。
- **A+ bridge 形态**（磊哥 2026-06-25）：`PresentationSnapshot` 保 vocabulary 容器，**卡片渲染复用现有 `VehicleCardDisplay`/`familyDisplays(from:)`，不造平行 SnapshotCard 展示模型**。
- **scope 呈现 = 淡显角标**（SD23 裂缝⑤拍 B，体验审计 P1-2 已纠 `caption2 9pt`→`caption semibold` 提对比，淡≠隐形）/ **全车 = 1 聚合卡 + 青 badge**（裂缝⑥拍 c）。
- **7 态穷尽 switch 无 default**（D7 apply `6a3e3f9`；机械门 `check-no-binary-visualstate.sh`）。
- **纯语音 push-to-talk**（SD23 移除 TextField → 换 **mic dock**，SD18 V7：72-80pt floating glass capsule）。
- **物理置顶作废**（S5/S6）→ AD-12 原地放大 hero + `ScrollViewReader` 滚入视野。
- **capsule route 不拍死**（U31 spike 实证不预拍，**模拟器观感**对比）+ **U30 layerEffect 与 mlx 抢 GPU -50%**→砍重折射 shader，capsule 只 native glass + Vortex 粒子 + image offset。
- **orb / 思考链路 = Phase 5 DEFERRED**（E0-E8 grill 收口但不在本 §8）；🔴 **但 mic dock + 对话流是本 §8.A1「orb-对话-车控-mic 四 zone」组成，不跟 orb defer**。
- **gpt anchor 图非权威**（磊哥「不以 gpt 为准」）：只借视觉灵感/对比基准，布局以 SD/AD 为准。

---

## Global Constraints

> 每个 task 隐含包含本节。verbatim 自 spec/grill SSOT。

- **平台锁**：App target iOS26.0 / macOS26.0；Core `Package.swift` 留 `.iOS(.v17)/.macOS(.v14)` 不动。**禁 `#available(iOS 17|18)`**（机械门 `check-platform-vs-version-guard.sh`）；平台差异用 `#if !os(macOS)`，a11y 用 `if reduceMotion`。
- **A2 边界（code-only Presentation 层）**：**不改 Core 契约 / state-cells.yaml / DemoVehicleStateStore 语义 / C1-C6 codegen**；不训练/不评测/不生成语料。bridge mock 是 **UIUE 侧 not-a-contract preview 层**（AD-RPB-002）。扩 `VehicleCardDisplay` 字段（加默认值，向后兼容）+ 扩 `familyDisplays(from:activeCells:)` 可选参数（默认空，现有调用不破）= 渲染层非契约层，不算碰 Core 契约。
- 🔴 **wiring gate（`check-contentview-uses-display-catalog.sh`，必守）**：ContentView body **必字面调用** `familyDisplays(from:` + `VehicleCardsGrid(displays: familyDisplays`（注释 strip 后真接线）+ **禁 LazyVGrid**。`Makefile verify`/`verify-ci` 都跑 `verify-contentview-wiring`。→ **A+ 弥合**：ContentView 保 `familyDisplays` computed property（内部从 `snapshot.cells` 算），实参字面仍是 `familyDisplays`，gate 不破。
- **U30 GPU**：context capsule 不跑 Inferno 折射 layerEffect；只 native `.glassEffect`（壳/mic dock）+ Vortex 粒子（Canvas）+ image `.offset`。
- **视觉 SSOT**：色/字/间距/圆角/动效全从 `docs/design/tokens.md → App/DesignTokens.swift` 取，禁硬编 hex。🔴 制冷热语义色落 **tokens.md §1**（`semantic.cool`/`semantic.warm`，SD20:417），非 §2。
- **7 态穷尽**：`DemoVisualState` 7 态（normal/satisfied/changing/blocked_with_alternative/blocked_hard/unsafe/unknown）各独立分支，**无二值/无 `default:` 吞态**（`check-no-binary-visualstate.sh`）。
- **测试框架 = XCTest**（与现有 25 文件/222 测试一致，**禁 Swift Testing `@Test`**——现仓 0 个 `import Testing`，混入会发现失败）。夹具用真实 init `DemoVehicleStateCell(key:actualValue:revision:)`（**非 `key:value:`**，`Core/State/DemoVehicleStateStore.swift:39`）。
- **Grid 固定列**（非 `LazyVGrid.adaptive`）：iPhone 2 / iPad 4 / Mac 5（C22，已实装 `VehicleCardsGrid`）。
- **iOS 模拟器验收，不真机**（磊哥 2026-06-25）：5-gate/截图走 `simctl`；**capsule GPU/帧率真机验证 DEFERRED**（tasks.md §8.B1 已回写）。
- **make verify-all 口径**：当前 `Makefile verify-all` = `verify`(含 `verify-contentview-wiring`) + `swift-test`；**`check-no-binary-visualstate.sh` / `check-platform-vs-version-guard.sh` 由 pre-commit hooksPath 跑，不在 make verify-all 内**（Phase gate 明确「make verify-all + 两 shell gate 另跑」，不把口径写大）。

---

## heavy-work harness 管控（每 Phase）

> 沉淀自 `~/.claude/skills/heavy-work/SKILL.md`。

1. **每 Phase = 执行线 + 审计线（subagent CC `run_in_background=true`）+ 主线程亲核 + Phase gate**。
2. **Phase gate**：`swift test` 0 fail + 🔴 **触碰共享 `App/*`/`Core/Presentation/*` 的 Phase 必双端 build**（`xcodebuild -scheme MAformacIOS -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max'` **和** `-scheme MAformacMac -destination 'platform=macOS'` 都 BUILD SUCCEEDED，macOS 回归不拖到 Phase 4）+ pre-commit 两 shell gate 绿 + wiring gate 绿 + 本 Phase 一轮审无 P0/P1 + 主线程亲核 + 分 commit。
3. 🔴 **phase gate 用 plan-local marker，不勾 OpenSpec active task（防 completion-claim 假绿，codex P0-4）**：tasks.md §8.A1/A3/A4/A7 等 active task **只在该 task 的 view/render/proof 全做完（含 orb 落地的部分留 Phase5）才勾**；plan 内 Phase 进度用本 plan 的 `- [ ]` checkbox 追踪，不提前勾 OpenSpec。
4. 🔴 **每 Phase 结束回顾基线文档（derived-tracking-writeback gate）**：回读 §0 清单，问「本 Phase 推翻/坐实了哪些？landing matrix / grill-定档 要不要回写」→ 逐个回写不攒。`grep` 载力事实点段间一致。
5. **截图对比**：每 View Phase 后 `simctl` 截图 → 对比 `docs/design/gptimage2-anchor-set/`（anchor 视觉目标非像素终态）。
6. **中途沉淀（不攒）**：新坑→`docs/lessons-learned.md K`；通用 recognition 元认知→`~/.claude/rules/`；可复用动作→`Tools/skills/`；**adopt > build**（Vortex/LiquidGlassReference/axiom skills）。
7. **整体收口**：loopaudit（≥3 subagent 至无 P0/P1）+ 14 张 simctl 5-gate + closeout receipt。

---

## File Structure

**新建：**
- `Core/Presentation/PresentationSnapshot.swift` — A+ vocabulary 容器（`PresentationSnapshot` + `DemoContext`/`VehicleContext`/`EnvironmentContext` 四维 + `DemoRuntimeResultKind` 8 类 + `PresentationProofClass`）+ `MockPresentationSnapshotProvider`（force-state mock）+ `store→snapshot` adapter。**纯 `import Foundation`**（与 Core/Presentation 现有 8 文件一致）。命名带 `Mock` 前缀显式标 not-a-contract（codex P2-1）。
- `Core/Presentation/SemanticColorMapper.swift` — 制冷热 sibling（`ac.mode`→cooling/heating/neutral，SD20）。
- `Core/Presentation/FamilyIconMapper.swift` — V9 族图标（SF Symbols 契约存在性）。
- `App/MicDock.swift` — mic dock floating glass capsule（SD18 V7：72-80pt，左状态点/中「按住说话」/右波形，按住扩张发光）。
- `App/DialogueStream.swift` — `DialogueBubble`（user 右/assistant 左）+ ScrollView 累积对话流（SD3，替 readbackPanel trace 列表）。
- `App/ContextCapsule.swift` — context capsule diorama（消费 `context` 四维，spike-gated）。
- `App/SettingsRefreshControls.swift` — 右上 standalone 设置/刷新（SD24，capsule 外）。
- `Tests/MAformacCoreTests/{PresentationSnapshotTests,SemanticColorMapperTests,FamilyIconMapperTests}.swift` — 语义层 TDD（**XCTest**）。

**修改：**
- `App/ContentView.swift` — 连续舞台重构（去品牌/去 TextField → mic dock + 对话流 / `familyDisplays` 从 snapshot.cells 算保 wiring gate / 层级滚动 / 边界态）。
- `App/DesignTokens.swift` + `docs/design/tokens.md` — 制冷热 token 落 §1 + hex DRAFT→FROZEN。
- `Core/Presentation/UIValueTypeMapper.swift`（`VehicleCardDisplay`）— 加 `activeCell:String?=nil` + `siblingCells:[DemoVehicleStateCell]=[]`（默认值向后兼容）+ `familyDisplays(from:activeCells:)` 扩可选参数透传（默认 `[:]` 现有调用不破，strangler）。
- `Tests/MAformacCoreTests/VehicleCardDisplayTests.swift`（XCTestCase，追加 `func test...`）。

---

## Phase 0 — bridge mock vocabulary 容器（前置卡口，TDD XCTest）

### Task 0.1: PresentationSnapshot A+ 容器 + adapter + MockProvider

**Files:**
- Create: `Core/Presentation/PresentationSnapshot.swift`
- Test: `Tests/MAformacCoreTests/PresentationSnapshotTests.swift`

**Interfaces:**
- Consumes: `DemoVisualState`（7 态）、`DemoVehicleStateCell`（`key`/`actualValue`/`revision`）、`FamilyCardID`（10 族）、`VehicleCardDisplay`（现有渲染模型）、`ScopeOrigin`（`Core/Execution/ScopeResolution.swift`，defaulted/explicit/fanout）。
- Produces（A+ vocabulary 容器，**卡片不另造 model**）：
  - `enum DemoRuntimeResultKind { case acceptedToolCall, clarifyMissingSlot, refusalNoAvailableTool, refusalSafetyOrPolicy, alreadyStateNoop, runtimeError, cancelled, partialAcceptPartialRefuse }`（8 类，AD-RPB-005/008/012 禁裸 rejected）
  - `enum PresentationProofClass { case localMock, staticPreview, externalReview }`（finite，AD-RPB-006）
  - `struct VehicleContext { let speed: Int; let gear: String }` / `struct EnvironmentContext { let weather: String; let timePeriod: String }` / `struct DemoContext { let vehicle: VehicleContext; let environment: EnvironmentContext }`（四维，AD-RPB-014）
  - `struct PresentationSnapshot { let traceId: String; let storeCells: [DemoVehicleStateCell]; let activeCells: [FamilyCardID: String]; let refusedCell: String?; let context: DemoContext; let orbState: String; let dialogText: String; let readbacks: [String]; let resultKind: DemoRuntimeResultKind; let proofClass: PresentationProofClass }`（🔴 携带 `storeCells` + `activeCells` map 供 ContentView 调 `familyDisplays(from:activeCells:)` 出 `[VehicleCardDisplay]`，**容器不放 cards 平行 model**）
  - `enum MockPresentationSnapshotProvider { static func coldStart() -> PresentationSnapshot; static func acStarted() -> PresentationSnapshot; static func coolingMode() -> PresentationSnapshot; static func safetyRefusal() -> PresentationSnapshot; ... }`
  - `extension PresentationSnapshot { static func from(store: DemoVehicleStateStore, activeCells: [FamilyCardID:String], context: DemoContext, resultKind: DemoRuntimeResultKind) -> PresentationSnapshot }`（store→snapshot adapter，strangler）

- [ ] **Step 1: 写 failing test（XCTest，契约闭合非烟雾测试，codex P1-3）**

```swift
import XCTest
@testable import MAformacCore

final class PresentationSnapshotTests: XCTestCase {
    // result_kind 8 类全在（不塌成裸 rejected，AD-RPB-005/008/012）
    func testResultKindHasAllEightCases() {
        let all: [DemoRuntimeResultKind] = [
            .acceptedToolCall, .clarifyMissingSlot, .refusalNoAvailableTool,
            .refusalSafetyOrPolicy, .alreadyStateNoop, .runtimeError,
            .cancelled, .partialAcceptPartialRefuse
        ]
        XCTAssertEqual(Set(all).count, 8)
    }
    // context 四维全验（非抽两列烟雾，codex P1-3：gear/timePeriod 缺也要 fail）
    func testContextFourDimensions() {
        let s = MockPresentationSnapshotProvider.coldStart()
        XCTAssertGreaterThanOrEqual(s.context.vehicle.speed, 0)
        XCTAssertFalse(s.context.vehicle.gear.isEmpty)
        XCTAssertFalse(s.context.environment.weather.isEmpty)
        XCTAssertFalse(s.context.environment.timePeriod.isEmpty)
    }
    // coldStart 10 族常驻（经 familyDisplays 出卡，displayOrder）
    func testColdStartTenFamiliesViaFamilyDisplays() {
        let s = MockPresentationSnapshotProvider.coldStart()
        let cards = VehicleCardDisplay.familyDisplays(from: s.storeCells, activeCells: s.activeCells)
        XCTAssertEqual(Set(cards.compactMap { $0.familyCardID }).count, FamilyCardID.allCases.count)
    }
    // proofClass 是 localMock（force-state mock 不冒充 endpoint-ready，AD-RPB-006）
    func testMockProofClassIsLocalMock() {
        XCTAssertEqual(MockPresentationSnapshotProvider.coldStart().proofClass, .localMock)
    }
}
```

- [ ] **Step 2: run fail** — `swift test --filter PresentationSnapshotTests` → FAIL（类型未定义；夹具用真实 API 不先爆）。
- [ ] **Step 3: 实装** `PresentationSnapshot.swift`：4 vocabulary 类型 + `MockPresentationSnapshotProvider`（`coldStart()` 遍历 `FamilyCardID.displayOrder` 出 cells 全 normal + context mock `speed:0,gear:"P",weather:"晴",timePeriod:"日间"` + `activeCells:[:]` + `resultKind:.acceptedToolCall` + `proofClass:.localMock`）+ `from(store:...)` adapter。Task 1.2 落地后 `familyDisplays(from:activeCells:)` 可用。
- [ ] **Step 4: run pass** → PASS。
- [ ] **Step 5: commit** — `git commit -m "feat(uiue): A+ PresentationSnapshot vocabulary 容器 + adapter (AD-RPB-015, 卡片复用 VehicleCardDisplay)"`

### 🔴 Phase 0 gate + 基线回顾
- `swift test` 0 fail + 双端 build（碰 Core/Presentation）+ 审计线 1 轮 + 回读 §0 #4（A-1 vocabulary 对齐）+ **不勾 OpenSpec task**（Phase 0 是 plan 内前置）。

---

## Phase 1 — 语义派生层（TDD XCTest，bug 藏身处）

### Task 1.1: SemanticColorMapper 制冷热 sibling（SD20，token §1）

**Files:** Create `Core/Presentation/SemanticColorMapper.swift` + Test `Tests/MAformacCoreTests/SemanticColorMapperTests.swift`

**Interfaces:** Produces `enum ThermalTint: Equatable { case cooling, heating, neutral }` + `enum SemanticColorMapper { static func acThermalTint(siblingCells: [DemoVehicleStateCell]) -> ThermalTint }`（View 层映射 tokens §1 `semantic.cool`/`semantic.warm`）。

- [ ] **Step 1: 写 failing test（XCTest + 真实 init `actualValue:`）**

```swift
import XCTest
@testable import MAformacCore

final class SemanticColorMapperTests: XCTestCase {
    func testCoolingMode() {
        let cells = [DemoVehicleStateCell(key: "ac.mode", actualValue: "制冷", revision: 1)]
        XCTAssertEqual(SemanticColorMapper.acThermalTint(siblingCells: cells), .cooling)
    }
    func testHeatingMode() {
        let cells = [DemoVehicleStateCell(key: "ac.mode", actualValue: "制热", revision: 1)]
        XCTAssertEqual(SemanticColorMapper.acThermalTint(siblingCells: cells), .heating)
    }
    func testNoModeIsNeutralNotSwallowedToCooling() {
        XCTAssertEqual(SemanticColorMapper.acThermalTint(siblingCells: []), .neutral)
    }
}
```

- [ ] **Step 2: run fail** → FAIL。
- [ ] **Step 3: 实装**（`siblingCells.first { $0.key == "ac.mode" }` → switch actualValue：制冷→cooling/制热→heating/其它→**neutral（不 `default` 吞成 cooling）**；无 sibling→neutral）。
- [ ] **Step 4: run pass** → PASS。
- [ ] **Step 5: commit** — `git commit -m "feat(uiue): SemanticColorMapper 制冷热 (SD20, neutral 不吞错)"`

### Task 1.2: 扩 VehicleCardDisplay 加 activeCell/siblingCells + familyDisplays 透传（CC P1-1，改现有非造单数）

**Files:** Modify `Core/Presentation/UIValueTypeMapper.swift`（`VehicleCardDisplay` + `familyDisplays`）+ Test `Tests/MAformacCoreTests/VehicleCardDisplayTests.swift`（XCTestCase 追加）

**Interfaces:**
- `VehicleCardDisplay` 加 `var activeCell: String? = nil` + `var siblingCells: [DemoVehicleStateCell] = []`（默认值，向后兼容）。
- `familyDisplays(from: cells)` 扩为 `familyDisplays(from: cells, activeCells: [FamilyCardID: String] = [:])`（**可选参数默认空，现有调用不破，strangler**）；非 normal 态且该族在 `activeCells` 有值 → summary 主值切到 activeCell base（对齐 SD19/AD-9，**改现有 `summaryDisplay` 分支，不造单数 `familyDisplay`**）。

- [ ] **Step 1: 写 failing test（追加到现有 VehicleCardDisplayTests XCTestCase）**

```swift
func testActiveCellOverridesPrimaryInChangingState() {
    // seat 族 primary=heat_level，本次改 backrest → activeCells 指 backrest，changing 态主值显 backrest
    let cells = [
        DemoVehicleStateCell(key: "seat.heat_level", actualValue: "0", revision: 1),
        DemoVehicleStateCell(key: "seat.backrest_angle", actualValue: "30", revision: 2)
    ]
    let displays = VehicleCardDisplay.familyDisplays(
        from: cells, activeCells: [.seat: "seat.backrest_angle"]
    )
    let seatCard = displays.first { $0.familyCardID == .seat }
    XCTAssertEqual(seatCard?.valueText.contains("30"), true)  // 显 backrest 非 heat_level
}
func testFamilyDisplaysBackwardCompatibleNoActiveCells() {
    // 现有调用 familyDisplays(from:) 默认空 activeCells，行为不变（strangler）
    let cells = [DemoVehicleStateCell(key: "ac.temp_setpoint[主驾]", actualValue: "24", revision: 1)]
    XCTAssertFalse(VehicleCardDisplay.familyDisplays(from: cells).isEmpty)
}
```

- [ ] **Step 2: run fail** → FAIL（`familyDisplays(from:activeCells:)` 未定义 / activeCell 字段无）。
- [ ] **Step 3: 实装**（`VehicleCardDisplay` 加两字段；`familyDisplays` 加 `activeCells` 可选参数，`summaryDisplay` 内非 normal 态 + activeCells 命中 → 主 cell 取 activeCell base；保留旧入口语义）。
- [ ] **Step 4: run pass** → PASS（含现有 222 测试不回归）。
- [ ] **Step 5: commit** — `git commit -m "feat(uiue): VehicleCardDisplay 扩 activeCell/siblingCells + familyDisplays 透传 (CC1 SD19, strangler)"`

### Task 1.3: FamilyIconMapper（V9 SF Symbols 契约存在性）

**Files:** Create `Core/Presentation/FamilyIconMapper.swift` + Test `Tests/MAformacCoreTests/FamilyIconMapperTests.swift`

**Interfaces:** Produces `enum FamilyIconMapper { static func sfSymbol(for family: FamilyCardID) -> String }`。

- [ ] **Step 1: 写 failing test（XCTest，契约存在性 10 族全映射无 default 吞）**

```swift
import XCTest
@testable import MAformacCore

final class FamilyIconMapperTests: XCTestCase {
    func testEveryFamilyHasNonEmptyIcon() {
        for family in FamilyCardID.allCases {
            XCTAssertFalse(FamilyIconMapper.sfSymbol(for: family).isEmpty, "family \(family) 无图标")
        }
    }
}
```

- [ ] **Step 2: run fail** → FAIL。
- [ ] **Step 3: 实装**（`switch family` **穷尽 10 族**每族显式 SF Symbol，**无 `default:`**；读 `axiom-design/sf-symbols` 确认 symbol 名存在）。
- [ ] **Step 4: run pass** → PASS。
- [ ] **Step 5: commit** — `git commit -m "feat(uiue): FamilyIconMapper V9 (10 族穷尽 SF Symbol)"`

### 🔴 Phase 1 gate + 基线回顾
- `swift test` 0 fail（含 3 新 suite + 现有 222 不回归）+ 双端 build + 审计线 1 轮 + 回读 derivation-layer rule + **不勾 OpenSpec task**（mapper done 但 View 未渲，plan-local marker 记进度）。

---

## Phase 2 — 连续舞台 View 重构（5-gate 验收，四 zone 含 mic dock+对话流）

> View 层 5-gate step：实装[约束] → **双端 build** → simctl 截图 → visual-acceptance 5-gate 对比 anchor → commit。

### Task 2.1: ContentView 消费 snapshot + 去品牌/去 TextField（保 wiring gate）

**Files:** Modify `App/ContentView.swift` + Create `App/SettingsRefreshControls.swift`

**Interfaces:** Consumes `MockPresentationSnapshotProvider`（Task 0.1）。

**约束（verbatim）：**
- ContentView 持 `@State snapshot: PresentationSnapshot = MockPresentationSnapshotProvider.coldStart()`；`#if DEBUG` 触发按钮切 `acStarted()/coolingMode()/safetyRefusal()` 驱动态变化（mock，非 demo 输入）。
- 🔴 **保 wiring gate**：`familyDisplays` computed property 改为 `VehicleCardDisplay.familyDisplays(from: snapshot.storeCells, activeCells: snapshot.activeCells)`；body 仍 `VehicleCardsGrid(displays: familyDisplays, ...)`（字面接线不破 `check-contentview-uses-display-catalog.sh`）。
- 删 `Text("MAformac")` brandHeader（SD24）+ 删 `commandBar` TextField（SD23）。
- 设置/刷新 = `SettingsRefreshControls` 右上 standalone（capsule 外）。
- runCommand/DemoWalkingSkeleton 旧链路：**本 §8 mock snapshot 驱动视觉，runCommand 真链路 strangler 保留**（`#if DEBUG` 触发按钮可调，不删；真 NLU→store 链路是更大范围，本 change defer）。

- [ ] Step 1 实装 → Step 2 **双端 build** → Step 3 simctl 截图 → Step 4 5-gate（无品牌/无 TextField/设置右上/wiring gate 绿 `bash Tools/checks/check-contentview-uses-display-catalog.sh`）对比 anchor-01 → Step 5 commit `feat(uiue): ContentView 消费 snapshot + 去品牌/TextField (保 wiring gate, SD23/24)`

### Task 2.2: mic dock floating glass capsule（SD18 V7，四 zone 之一）

**Files:** Create `App/MicDock.swift` + 接 ContentView 底部

**约束（SD18 V7:333）：** 72-80pt floating glass capsule（native `.glassEffect(.regular, in:.capsule)`），左状态点/中「按住说话」/右波形·mic symbol，按住 capsule 扩张发光；`safeAreaInset(edge:.bottom)` 钉底（SD22 D6 滚动边界）。

- [ ] Step 1 实装 → Step 2 双端 build → Step 3 simctl（mic dock idle/按住态截图）→ Step 4 5-gate（mic dock 居前不被遮挡 = 真有对象可验，对比 SD18 V7 规格）→ Step 5 commit `feat(uiue): mic dock floating glass capsule (SD18 V7)`

### Task 2.3: DialogueBubble 对话流替 readbackPanel（SD3，四 zone 之一）

**Files:** Create `App/DialogueStream.swift` + Modify ContentView（readbackPanel → DialogueStream）

**约束（SD3:47/51）：** `DialogueBubble{role:.user|.assistant, text}` user 右气泡/assistant 左气泡，`ScrollView` 累积 + `scrollTo(last)`；消费 `snapshot.dialogText`/`readbacks`（mock 多轮）。

- [ ] Step 1 实装 → Step 2 双端 build → Step 3 simctl（多轮对话截图）→ Step 4 5-gate（user 右/assistant 左/累积滚动，对比 SD3）→ Step 5 commit `feat(uiue): DialogueBubble 对话流 (SD3)`

### Task 2.4: tokens hex 定稿 + 制冷热 token §1 + 制冷热/activeCell 渲染（§8.A2/A3/A4）

**Files:** Modify `docs/design/tokens.md`（制冷热 token 落 **§1** `semantic.cool/warm` + hex DRAFT→FROZEN）+ `App/DesignTokens.swift` + `App/ContentView.swift`（`VehicleStateCard` 接 `SemanticColorMapper`）

**约束：** ac 卡背景/边框按 `ThermalTint` 取 tokens §1 蓝/红（neutral 走原 appearance）+ SD21 hero range bar + mode 图标（FamilyIconMapper/❄️）；activeCell 已在 mapper 层（Task 1.2），View 消费 `display.valueText`；SD5 摘要卡背景升 `.regularMaterial`。

- [ ] Step 1 实装 → Step 2 双端 build → Step 3 simctl（制冷/制热/7态 gallery 截图，grep 无硬编 hex）→ Step 4 5-gate（制冷蓝/制热红 SD20 + material SD5 + 投屏 V10）→ Step 5 commit + tokens.md FROZEN `feat(uiue): 制冷热渲染+token §1 FROZEN+material (SD20/SD5/§8.A2)`

### Task 2.5: 层级 + 滚动（§8.A5 / SD22）

**约束（SD22）：** z-order：氛围 overlay（`allowsHitTesting(false)`）> mic dock > orb 占位 > 聚焦 dim > 滚动内容；orb/mic 钉、对话/车控内部滚；**手动滚暂停自动 `scrollTo`**；**fade 按 active 非位置**；`ScrollViewReader` 激活族滚入视野（AD-12）。

- [ ] Step 1 实装 → Step 2 双端 build → Step 3 simctl（滚动态）→ Step 4 5-gate（mic dock 不被遮挡 + 激活族滚入）→ Step 5 commit `feat(uiue): 层级 z-order+滚动 (SD22)`

### Task 2.6: 边界态 + 注意力优先级（§8.A6/A7 / SD23 / V8）

**约束：** iPhone 锁竖屏（`#if !os(macOS)`）/ 文案 max ~30 字 `.truncationMode(.tail)` / ASR 二分（empty→idle / no-match→unsupported，mock）/ 族外 blocked_hard；激活族视觉重量 ≥ 次要 1.5x + 次要族 `.opacity` fade（按 active）+ 族图标 `FamilyIconMapper`。

- [ ] Step 1 实装 → Step 2 双端 build → Step 3 simctl（长文案 truncate + 族外 blocked_hard + 单族激活其余 fade）→ Step 4 5-gate（视觉层级 Gate1/重量 Gate5）→ Step 5 commit `feat(uiue): 边界态+注意力优先级+族图标 (SD23/V8/V9)`

### 🔴 Phase 2 gate + 基线回顾
- 两端 build SUCCEEDED + `swift test` 0 fail + pre-commit 两 shell gate + wiring gate 绿 + 审计线 1 轮 + **simctl 14 张满屏单态初轮 5-gate** + 回读 SD3/SD5/SD18-23 无自拍 + **此时可勾 OpenSpec §8.A1/A3/A4/A5/A6/A7**（view/render 全做完，orb 部分留 Phase5 注明）+ 回写 landing「§8.A done」。

---

## Phase 3 — context capsule diorama（route spike 模拟器观感 + 实装，gated）

> gated 在 Phase 2 后。**模拟器观感 spike**（不真机，tasks.md §8.B1 已回写）：route A 视频 loop 模拟器 photoreal 不打折；C-lite native glass 模拟器渲染不全（玻璃质感打折）。GPU/帧率真机 DEFERRED。

### Task 3.1: capsule route spike（模拟器观感 A vs C-lite，不预拍）

**Files:** Create `App/ContextCapsule.swift`（两 spike 变体）+ 记录 `docs/research/2026-06-25-context-capsule-2.5d-tech/spike-result.md`

**约束：** 两变体真跑模拟器对比观感（U31 不预拍）：A 视频 loop（5 anchor diorama 图 AI 动 2-3s seamless，`AVPlayerLooper`）；C-lite（native `.glassEffect` 壳 + **Vortex 粒子 pin commit** `.smoke`/`.rain`/`.snow` + 分层 stills `.offset`）。**不跑 Inferno layerEffect**（U30）。🔴 **Vortex 单一集成路径**：SPM 依赖 pin 到 commit（`Package.swift` `.package(url:"https://github.com/twostraws/Vortex", revision:"<pin>")`），不二选一拷 source（codex P2-2）。

- [ ] Step 1 建两变体（Vortex SPM pin）→ Step 2 双端 build → Step 3 simctl 截图/录屏对比 `anchor-00-diorama-*` → Step 4 spike-result.md 记观感（**route 磊哥拍，不自拍**）→ Step 5 commit `spike(uiue): capsule route A vs C-lite 模拟器观感 (U31)`

### Task 3.2: ContextCapsule 实装（route 定后）

**Files:** Modify `App/ContextCapsule.swift` + 接 ContentView 顶 context band（替 Task 2.1 占位）

**Interfaces:** Consumes `PresentationSnapshot.context`（四维，Task 0.1）。

**约束：** crossfade（`glassEffectID` morph）+ 预加载防卡顿 + 图标在 capsule 外（SD24）。route 按 3.1 磊哥拍。

- [ ] Step 1 实装 → Step 2 双端 build → Step 3 simctl（夜/雨/行驶 context 切换）→ Step 4 5-gate 对比 anchor-00 → Step 5 commit `feat(uiue): ContextCapsule diorama (SD24/25)`

### 🔴 Phase 3 gate + 基线回顾
- 两端 build + capsule+卡片同屏 simctl + 回读 2.5D 调研/U30/U31 + 勾 OpenSpec §8.B + 回写 landing「§8.B done + route 定」。

---

## Phase 4 — 验收收口（A-2 收口）

### Task 4.1: 全量验收门
- [ ] Step 1 `swift test` → 0 fail（贴输出）。
- [ ] Step 2 `xcodebuild -scheme MAformacMac -destination 'platform=macOS' build` + `-scheme MAformacIOS -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build` → 两端 SUCCEEDED。
- [ ] Step 3 `make verify-all` → exit 0 **+ 另跑** `bash Tools/checks/check-no-binary-visualstate.sh` + `check-platform-vs-version-guard.sh` + `check-contentview-uses-display-catalog.sh` 全绿（口径：make verify-all 含 wiring gate+swift test，两 shell gate 另跑）。
- [ ] Step 4 commit（若 fix）。

### Task 4.2: 5-gate 视觉验收 + anchor 对比
- [ ] Step 1 `simctl` 14 张满屏单态（mac7+iOS7）+ capsule 三 context。
- [ ] Step 2 visual-acceptance agent【用户演绎体验视角】（方案经理 5min 台本 + 客户旁观 + corner case，还原投屏 V10，逐张 Read 不抽查）。
- [ ] Step 3 对比 `docs/design/gptimage2-anchor-set/`（神似非像素复刻）；任一态 5-gate FAIL = 返工。
- [ ] Step 4 截图归档 + 对比报告。

### Task 4.3: loopaudit 收口 + 基线回写 + 沉淀
- [ ] Step 1 loopaudit（≥3 subagent 至无 P0/P1，留痕 round-NN）。
- [ ] Step 2 **基线文档级联回写**（grill-定档/landing matrix/tasks.md §8 勾选/CLAUDE §9）。
- [ ] Step 3 **沉淀**（坑→lessons K / 元认知→rules / 技能→Tools/skills；adopt Vortex 记录）。
- [ ] Step 4 closeout receipt + handoff。

---

## Self-Review（writing-plans 自检 + 两路审计修复对照）

**1. Spec 覆盖（tasks.md §8 逐条）：** §8.A1 去 divider/品牌/TextField/右上+四 zone → Task 2.1/2.2/2.3 ✅（mic dock+对话流补齐，修 CC P1-4/codex P0-4）；§8.A2 tokens → 2.4 ✅；§8.A3 制冷热 → 1.1+2.4 ✅；§8.A4 activeCell → 1.2+2.4 ✅；§8.A5 层级滚动 → 2.5 ✅；§8.A6 边界态 → 2.6 ✅；§8.A7 注意力+FamilyIcon → 1.3+2.6 ✅；§8.B1 spike（模拟器观感，契约已回写）→ 3.1 ✅；§8.B2-4 capsule+Vortex → 3.1/3.2 ✅；§8.C 验收 → 4.1/4.2 ✅；前置 bridge mock → Task 0.1 ✅。

**2. 两路审计 P0/P1 修复对照：**
- 双 SSOT（CC P0-1+codex P1-1）→ **A+**：snapshot 容器保 vocabulary + 卡片单一 VehicleCardDisplay + adapter + strangler ✅
- 测试 API（codex P0-2+CC P1-2）→ 全 XCTest + `init(key:actualValue:revision:)` ✅
- wiring gate（CC P0-2）→ Global Constraints 列 + `familyDisplays` computed 字面接线弥合 ✅
- phase gate 假绿+四 zone（codex P0-4+CC P1-4）→ plan-local marker 不勾 OpenSpec + mic dock/对话流 task ✅
- bridge vocabulary（codex P0-1/P1-3）→ Task 0.1 契约闭合 RED（8 类/四维/proofClass）✅
- 真机 spike 契约（codex P0-3）→ tasks.md §8.B1 已回写 ✅
- familyDisplay 签名（CC P1-1）→ 改现有 familyDisplays 接 activeCells 非造单数 ✅
- 制冷热 token §1（CC P1-3）/ 双端 build（codex P1-2）/ Vortex pin（codex P2-2）/ preview 命名 Mock（codex P2-1）/ SD5 material+range bar（CC P2-2）/ displayOrder（CC P2-3）/ make verify-all 口径（codex P2-3）/ design.md:29 stale（CC P2-4）✅
- CC P2-4 commit hash 092c473 = 审计误报（`17ae332` 我对，未改）。

**3. Type 一致性：** `PresentationSnapshot`/`DemoRuntimeResultKind`(8)/`DemoContext`(四维)/`PresentationProofClass`/`ThermalTint` 跨 Task 0.1→1.1→2.4 一致；`VehicleCardDisplay` 扩 `activeCell/siblingCells` + `familyDisplays(from:activeCells:)` 跨 0.1/1.2/2.1 一致；`FamilyCardID.allCases`(10)/`displayOrder` 跨 0.1/1.3 一致；夹具全 `DemoVehicleStateCell(key:actualValue:revision:)`。

> ⚠️ spike 项不预拍：capsule route（A vs C-lite）由 Task 3.1 模拟器观感 spike → 磊哥拍。

# Phase 4 卡片 scope 呈现 Implementation Plan（CC 从 0 重做）

> **For agentic workers:** REQUIRED SUB-SKILL: 用 superpowers:subagent-driven-development（推荐）或 superpowers:executing-plans 逐 task 实现。Steps 用 checkbox（`- [ ]`）追踪。
> **authority:** `implementation_plan_not_ssot`（计划非 SSOT；契约 SSOT = `openspec/changes/ui-presentation/specs/`，决策 SSOT = `docs/grill-tournament/uiue-phase4-grill-decisions.md`）。
> **retire/expiry:** Phase 4c 收口并 main + ui-presentation archive 后本计划退役。

**Goal:** 把 10 族车控状态在前端按 spec 渲染——10 族 family_card 摘要网格 + scope 淡角标/聚合 + value.type 异构控件 + 低风险炸场，接线机械 enforce（防前任「接线丢失」重演）。

**Architecture:** ⭐C'' 二级摘要+展开模型（调研 5 路锁）= **4a 摘要层**（10 族 family_card + 每族 1 主 cell + scope 角标 + 7态 + 低风险炸场）→ **4b 展开层**（触发聚焦 + value.type 异构控件 + 座椅 composite）→ **4c 错峰**（多意图序列化）。走 `ui-presentation` change 的 incremental apply，**一个计划文件、内部分阶段 commit/验收**（4a 绿再 4b）。

**Tech Stack:** SwiftUI（iOS26/macOS26 lock）+ 现有 `DemoVehicleStateStore`（@Observable 7态 store）+ `CardAppearance`（D7 7态外观）+ `VehicleCardDisplay`/`UIValueTypeMapper`（前任孤立模块 405 行，幸存可复用）+ 原生 `Gauge`。

---

## Global Constraints（每 task 隐含包含，verbatim）

### 边界（A2 链路 B owned，UIUE 链路 A 禁碰）
- 🔴 **UIUE 只改**：`App/`（view）+ `Core/Presentation/`（消费侧派生层，可单测 MAformacCore，区别于数据层）+ `openspec/changes/ui-presentation/`（spec/design/tasks）+ `docs/`。
- 🔴 **禁碰（A2 owned）**：`Core/State/`（数据层 DemoVehicleStateStore）+ `contracts/`（producer 契约）+ `generated/`（A2 产物，只读消费）。hvac.*→ac.* 命名清债 = A2 独立票（hvac.* 在 4 文件全 A2 owned，ContentView 已 ac.* 不碰）。
- 🔴 **不新建 OpenSpec change**：Phase 4 契约已在 ui-presentation spec 锁全（value.type spec.md:83 + scope 角标 spec.md:171）→ incremental apply 非 propose。

### spec 硬约束（spec R2/R3 verbatim + pre-mortem tiger）
- value.type **5 类穷尽 switch**（dial/toggle/stepper/percent/badge）+ **禁 AnyView** + **禁 producer 新增字段**（消费侧从 `cell.key` 派生）。
- 卡片按 **10 族 family_card_id**（非 191 device 平铺）；**Grid 固定列非 LazyVGrid.adaptive**（C22）。
- **内容层卡片禁 `.glassEffect()`**（HIG，oracle 坐实）；scope 角标用 `content_glow`(standard material) 非 glass；transient 控件（温度滑块/风量 toggle）激活态可 glass（Apple 例外）。
- `.contentTransition(.numericText())` **必 `withAnimation` 包裹**否则静默不动（pre-mortem F-LB2 silent-fail tiger）。
- breathe glow **仅激活态** + `.repeatForever` 非裸 Timer（pre-mortem F-LB3/T1，10 张同屏=10 offscreen pass）。
- 视觉值全从 `DesignTokens`/`tokens.md` 取（grep 无硬编 hex）；锁 iOS26 无需 `#available`。

### 元认知（本计划承载，写进 worker 必读）
- **claim-vs-reality 铁律**（前任接线丢失根因）：① 写任何数字/file:line 前 grep 核一手源，不凭 mapper case/记忆推（P4-D2 我犯过：凭 mapper 推 seat 4 cell，实 5）② **单测绿 ≠ 接线完成**（测 display model 纯函数 ≠ ContentView 真调用它，proof 图丢失正因此）→ pre-commit gate 机械堵。
- **enforce 非 declare**：接线契约写进 pre-commit（grep ContentView 必 call displays），不靠自觉。
- **completion-claim-triage**：「接线写了」是计划态，「pre-commit 绿 + force-state 截图验」才是执行态。
- **dispute-triage**：事实型（cell 数/file:line）grep 核；口径型（聚焦过渡）已 D5 锁，不重拍。

### 🔴 经验教训习惯（magnet 铁律，每 task 遵守）
- **随时记录**：本计划执行中**每遇坑/纠错/意外**，**当场**追加到 `docs/lessons-learned.md`（不攒到最后）。格式：`## [日期] Phase 4 <坑名>` + 现象 + 根因 + 修法。
- 每 task 末尾自问「这 task 有没有踩到 pre-mortem 清单外的新坑」→ 有则回写 lessons + 本计划对应 task 的「坑」栏。

---

## 文档级联清单（magnet 铁律：计划含级联，收口逐个回写）

| 文档 | 级联动作 | 时机 |
|---|---|---|
| `openspec/changes/ui-presentation/design.md` | 加 **AD-9**（FamilyCardIDMapper 派生）/**AD-10**（FamilyPrimaryCellMapper 摘要主 cell）/**AD-11**（二级摘要+展开模型）；接现有 AD-8；🔴 **P1-1 纠 AD-2 `:27` 路径** `App/Rendering/UIValueTypeMapper`→`Core/Presentation/UIValueTypeMapper`（实际位置，可单测 MAformacCore；Core/Presentation 与 Core/State 同 module，「禁碰」是目录约定非 build 隔离）| 4a 起手（Task 1）|
| `openspec/changes/ui-presentation/proposal.md` | `Files to modify` 显式列 `design.md` + 新建 mapper（防假跟随只列 tasks）| 4a 起手 |
| `openspec/changes/ui-presentation/tasks.md` | 勾选 4.1-4.5/7.A；🔴 **P1-1 纠 4.1 `:39` 路径** `App/Rendering`→`Core/Presentation`；🔴 **P1-4 纠 4.5 `:43` stale**（「ContentView:107-119 hvac.*」错——实 title switch 在 `:142`-`:163` 且已 `ac.*`，hvac 仅在 4 个 A2 owned 文件）→ 4.5 标 done/废（UIUE 不碰）| 每 task 完成即勾 |
| `docs/grill-tournament/uiue-phase4-grill-decisions.md` | 每阶段收口补「实装态」+ 新坑回写 | 每阶段末 |
| `docs/grill-tournament/grill-decisions-master.md §3` | Phase 4 指针更新「实装中→done」 | 整体收口 |
| `docs/design/uiue-skill-playbook.md` | 命中的坑/实证回写对应行 | 遇坑即写 |
| `docs/lessons-learned.md` | 新坑当场追加（经验教训习惯）| 实时 |
| `docs/CURRENT.md` | Phase 4 状态/下一步更新 | 阶段转换 |

## Tools/skills 点名（每 task 调哪个，来源 `docs/design/uiue-skill-playbook.md`）

| 任务类 | 调用 skill | 用途 |
|---|---|---|
| 写任何 SwiftUI view（Grid/卡片/动画）| `axiom-swiftui`（containers-ref/animation-ref）| 布局/动效正确姿势 |
| 视觉值/HIG/Liquid Glass/SF Symbols | `axiom-design`（hig/liquid-glass/sf-symbols）| 决 what 再 swiftui 做 how |
| 写单测（Swift Testing）| `axiom-testing`（swift-testing）| @Test/#expect |
| value.type 控件（Gauge/SF Symbols）| `axiom-swiftui` + `axiom-design`(sf-symbols)| 4b |
| ⭐⭐ **视觉验收（每阶段必跑）** | `ios-simulator-skill`（simctl 启动+截图+force-state）| 5-gate 14 张满屏单态 |
| build 失败诊断 | `axiom-build`（env-first）| 全程 |
| 帧率（breathe/炸场）| `axiom-performance` + `ios-ettrace-performance` | 别掉帧 |
| Apple API 不确定（iOS26）| `axiom-apple-docs` | 别凭记忆 |
| 收口审计 | `axiom-swiftui` auditor agent（liquid-glass-auditor）| 可选 |

> **起手必做**：写第一个 view 前 `Skill(axiom-design)` + 读 `docs/design/INDEX.md`（视觉 SSOT，禁 prompt 即兴）。

## 权限（magnet 已授）
- 🟢 **依赖安装授权**：实装需要的 SPM 依赖/工具（如 pointfreeco swift-snapshot-testing，或 ref-repos 抄代码所需）→ 直接装，给一切权限。
- 🟢 **视觉检查授权**：`ios-simulator-skill` simctl 启动 app + 截图 + force-state + 5-gate，给一切权限（boot simulator / xcrun / screenshot）。macOS 截图注意隐私（留干净屏幕，memory `macos-gui-screenshot-privacy`）。

---

## File Structure（UIUE 改/建）

- **Create** `Core/Presentation/FamilyCardIDMapper.swift` — device base → 10 族 FamilyCardID 派生（消费层，同 UIValueTypeMapper 体例，可单测）
- **Create** `Core/Presentation/FamilyPrimaryCellMapper.swift` — FamilyCardID → 1 主状态 cell base（摘要层显哪个 cell）
- **Modify** `Core/Presentation/UIValueTypeMapper.swift` — 加 `BadgeRenderStyle` 二级 enum（ambient.color 色块特化）+ family 分组（VehicleCardDisplay.displays 增 family 维度）
- **Modify** `App/ContentView.swift` — `vehicleCards` 从 `ForEach(presentationCells)` device 级 → 10 族 family_card Grid 摘要；`VehicleStateCard` 接 display model + scope 角标 + numericText + breathe
- **Modify** `App/DebugGallery.swift` — force-state gallery 同步 family_card
- **Create** `Tests/MAformacCoreTests/FamilyCardIDMapperTests.swift` + `FamilyPrimaryCellMapperTests.swift` + 扩 `VehicleCardDisplayTests.swift`
- **Create** `Tools/checks/check-contentview-uses-display-catalog.sh` — 接线 enforce gate（🔴 P0-2：放 `Tools/checks/` 与现役 check 同目录，非 `.githooks/checks/`）
- **Modify** `openspec/changes/ui-presentation/{design.md,proposal.md,tasks.md}` — AD-9/10/11 + 文档级联

---

## Phase 4a — 摘要层接线 + scope 角标 + 低风险炸场（must，4a 绿才进 4b）

### Task 1: 文档先行 — design.md AD-9/10/11 + 级联（agree-before-build）

**Files:**
- Modify: `openspec/changes/ui-presentation/design.md`（接 AD-8 加 AD-9/10/11）
- Modify: `openspec/changes/ui-presentation/proposal.md`（Files to modify 列 design.md + 2 mapper）

**Interfaces:** Produces: AD-9/10/11 编号供后续 task 注释引用。

- [ ] **Step 1: 写 design.md AD-9/10/11**（Architecture 决策进 design 非 tasks checkbox，OpenSpec 三件套）

```markdown
### AD-9: family_card_id 消费侧派生（FamilyCardIDMapper）
spec.md:83 锁「10 族 family_card_id 布局」但 producer 0 字段（state-cells.yaml grep=0）→ 消费侧从 cell.key 派生（同 ui_value_type 派生纪律，不写回 yaml/Core）。`enum FamilyCardID{ac,seat,window,screen,ambient,door,volume,wiper,sunroofShade,fragrance}` 10 族 + `familyCardID(forBase:)->FamilyCardID` 穷尽 switch。数据源 generated/family-device-allowlist.json（families/row_count 排序，只读）。

### AD-10: 族卡摘要主 cell（FamilyPrimaryCellMapper）
二级模型摘要层每族显 1 主状态 cell（信息量优先非 readback[0]）：ac→temp_setpoint / seat→heat_level / window→position / ambient→color / screen→brightness / volume→level / wiper→power / door→central_lock / sunroofShade→position / fragrance→power。独立 SSOT（readback_cell_group 顺序不一致，如 ac readback[0]=power 但主 cell=temp），不复用 readback[0]。

### AD-11: 二级摘要+展开模型（调研 5 路锁）
4a 摘要层（10 族 family_card 全景常驻 Grid + 每族主 cell at-a-glance + scope 角标 + 7态）→ 4b 展开层（触发聚焦 + value.type 异构控件 + 族内 composite）→ 4c 错峰。摘要层不放完整 slider/picker（族卡空间不够，local F10）。
```

- [ ] **Step 2: proposal.md Files to modify 显式列**（防假跟随）

```markdown
## Files to modify
- openspec/changes/ui-presentation/design.md (AD-9/10/11)
- Core/Presentation/FamilyCardIDMapper.swift (new)
- Core/Presentation/FamilyPrimaryCellMapper.swift (new)
- Core/Presentation/UIValueTypeMapper.swift (BadgeRenderStyle + family)
- App/ContentView.swift, App/DebugGallery.swift
```

- [ ] **Step 3: 验证 + Commit**

Run: `openspec validate ui-presentation --strict`
Expected: PASS
```bash
git add openspec/changes/ui-presentation/
git commit -m "docs(uiue): Phase 4a AD-9/10/11 文档先行（family_card 派生+主cell+二级模型）"
```

### Task 2: FamilyCardIDMapper（device base → 10 族，TDD）

**Files:**
- Create: `Core/Presentation/FamilyCardIDMapper.swift`
- Test: `Tests/MAformacCoreTests/FamilyCardIDMapperTests.swift`

**Interfaces:**
- Consumes: `ScopedStateKey(key).base`（UIValueTypeMapper.swift:184 已有）
- Produces: `enum FamilyCardID`（10 case）+ `FamilyCardIDMapper.familyCardID(forBase: String) -> FamilyCardID`

> 🔴 **P0-1 修复（审计 catch）**：`presentationCells` 实含 **12 个 base prefix**（ac/ambient/door/fragrance/screen/seat/sunroof/sunshade/**vehicle**/volume/window/wiper，已核 `DemoVehicleStateStore.swift:181` vehicle.speed/gear + :153 legacy 过滤集不含 vehicle）。FamilyCardIDMapper 必须 **optional 返回**（无 vehicle 族 → `nil`，禁 `default→.ac` 静默错归），familyDisplays 显式过滤未归族 cell。
> ✅ **vehicle.* 归属决策（magnet 2026-06-24 拍：不渲）**：摘要层**不渲** vehicle.speed/gear（车辆仪表非 10 控制族，spec 锁 10 族不含 vehicle）→ FamilyCardIDMapper 返 nil + familyDisplays 过滤。**不加第 11 族**（spec 10 族不动）。

- [ ] **Step 1: 写 failing test**（含 vehicle.* 归属断言，非 happy-case 假绿）

```swift
import XCTest
@testable import MAformacCore

final class FamilyCardIDMapperTests: XCTestCase {
    func testDeviceBaseMapsToFamily() {
        XCTAssertEqual(FamilyCardIDMapper.familyCardID(forBase: "ac.temp_setpoint"), .ac)
        XCTAssertEqual(FamilyCardIDMapper.familyCardID(forBase: "seat.heat_level"), .seat)
        XCTAssertEqual(FamilyCardIDMapper.familyCardID(forBase: "window.position"), .window)
        XCTAssertEqual(FamilyCardIDMapper.familyCardID(forBase: "ambient.color"), .ambient)
        XCTAssertEqual(FamilyCardIDMapper.familyCardID(forBase: "sunroof.position"), .sunroofShade)
        XCTAssertEqual(FamilyCardIDMapper.familyCardID(forBase: "sunshade.position"), .sunroofShade)
        XCTAssertEqual(FamilyCardIDMapper.familyCardID(forBase: "fragrance.power"), .fragrance)
    }
    // 🔴 P0-1：vehicle.* 不归任何控制族（返 nil，⭐ 摘要层过滤）
    func testVehicleNotMappedToControlFamily() {
        XCTAssertNil(FamilyCardIDMapper.familyCardID(forBase: "vehicle.speed"))
        XCTAssertNil(FamilyCardIDMapper.familyCardID(forBase: "vehicle.gear"))
        XCTAssertNil(FamilyCardIDMapper.familyCardID(forBase: "unknown.foo"))
    }
    func testAllTenFamiliesReachable() {
        XCTAssertEqual(FamilyCardID.allCases.count, 10)  // 不含 vehicle（控制族）
    }
}
```

- [ ] **Step 2: Run test 验证 fail** — Run: `swift test --filter FamilyCardIDMapperTests` Expected: FAIL（FamilyCardID 未定义）

- [ ] **Step 3: 写 minimal 实现**（optional 返回，禁 default 静默错归）

```swift
import Foundation

enum FamilyCardID: String, CaseIterable, Equatable {
    case ac, seat, window, screen, ambient, door, volume, wiper, sunroofShade, fragrance
}

enum FamilyCardIDMapper {
    /// 返回 nil = 不属任何 10 控制族（如 vehicle.* 车辆仪表 / 未知 base）→ 摘要层过滤
    static func familyCardID(forBase base: String) -> FamilyCardID? {
        let prefix = base.split(separator: ".").first.map(String.init) ?? base
        switch prefix {
        case "ac": return .ac
        case "seat": return .seat
        case "window": return .window
        case "screen": return .screen
        case "ambient": return .ambient
        case "door": return .door
        case "volume": return .volume
        case "wiper": return .wiper
        case "sunroof", "sunshade": return .sunroofShade
        case "fragrance": return .fragrance
        default: return nil  // vehicle.* + 未知 → 不归族（P0-1：禁 .ac 静默错归）
        }
    }
}
```

- [ ] **Step 4: Run test 验证 pass** — Run: `swift test --filter FamilyCardIDMapperTests` Expected: PASS（含 vehicle→nil 断言）

- [ ] **Step 5: Commit** — `git commit -m "feat(uiue): FamilyCardIDMapper device base→10族派生（AD-9）"`

### Task 3: FamilyPrimaryCellMapper（族 → 主 cell base，TDD）

**Files:** Create `Core/Presentation/FamilyPrimaryCellMapper.swift` + Test `Tests/MAformacCoreTests/FamilyPrimaryCellMapperTests.swift`

**Interfaces:** Produces: `FamilyPrimaryCellMapper.primaryCellBase(for: FamilyCardID) -> String`

- [ ] **Step 1: failing test**（AD-10 主 cell 表）

```swift
import XCTest
@testable import MAformacCore
final class FamilyPrimaryCellMapperTests: XCTestCase {
    func testPrimaryCell() {
        XCTAssertEqual(FamilyPrimaryCellMapper.primaryCellBase(for: .ac), "ac.temp_setpoint")
        XCTAssertEqual(FamilyPrimaryCellMapper.primaryCellBase(for: .seat), "seat.heat_level")
        XCTAssertEqual(FamilyPrimaryCellMapper.primaryCellBase(for: .ambient), "ambient.color")
    }
    func testAllFamiliesHavePrimary() {
        for f in FamilyCardID.allCases {
            XCTAssertFalse(FamilyPrimaryCellMapper.primaryCellBase(for: f).isEmpty)
        }
    }
}
```

- [ ] **Step 2: Run fail** — `swift test --filter FamilyPrimaryCellMapperTests` Expected: FAIL
- [ ] **Step 3: 实现**（AD-10 表穷尽 switch）

```swift
import Foundation
enum FamilyPrimaryCellMapper {
    static func primaryCellBase(for family: FamilyCardID) -> String {
        switch family {
        case .ac: return "ac.temp_setpoint"
        case .seat: return "seat.heat_level"
        case .window: return "window.position"
        case .screen: return "screen.brightness"
        case .ambient: return "ambient.color"
        case .door: return "door.central_lock"
        case .volume: return "volume.level"
        case .wiper: return "wiper.power"
        case .sunroofShade: return "sunroof.position"
        case .fragrance: return "fragrance.power"
        }
    }
}
```

- [ ] **Step 4: Run pass** — Expected: PASS
- [ ] **Step 5: Commit** — `git commit -m "feat(uiue): FamilyPrimaryCellMapper 族→主cell（AD-10）"`

### Task 4: VehicleCardDisplay 加 family 分组 + BadgeRenderStyle（TDD，复用前任 405 行）

**Files:** Modify `Core/Presentation/UIValueTypeMapper.swift`（21-129 displays + 11 ScopeBadgeStyle 旁加 BadgeRenderStyle）+ 扩 Test `VehicleCardDisplayTests.swift`

**Interfaces:**
- Consumes: FamilyCardIDMapper / FamilyPrimaryCellMapper（Task 2/3）
- Produces: `VehicleCardDisplay.familyDisplays(from:catalog:) -> [VehicleCardDisplay]`（10 族摘要，每族 1 卡显主 cell）+ `enum BadgeRenderStyle { plain, colorSwatch(String), mode(String) }` + `VehicleCardDisplay.badgeStyle: BadgeRenderStyle`

- [ ] **Step 1: failing test**（10 族摘要 + ambient 色块 badge）

```swift
func testFamilyDisplaysOnePerFamilyShowingPrimaryCell() {
    let displays = VehicleCardDisplay.familyDisplays(
        from: [
            DemoVehicleStateCell(key: "ac.temp_setpoint[主驾]", actualValue: "24", revision: 1, visualState: .satisfied),
            DemoVehicleStateCell(key: "ac.power", actualValue: "on", revision: 1, visualState: .satisfied),
            DemoVehicleStateCell(key: "ambient.color", actualValue: "红色", revision: 1, visualState: .satisfied)
        ],
        catalog: .load()
    )
    // ac 族 1 卡显主 cell temp_setpoint（非 power）
    let ac = displays.first { $0.familyCardID == .ac }
    XCTAssertEqual(ac?.title, "空调")
    XCTAssertEqual(ac?.valueText, "24℃")
    // ambient 族 badge = colorSwatch
    let amb = displays.first { $0.familyCardID == .ambient }
    if case .colorSwatch(let name) = amb?.badgeStyle { XCTAssertEqual(name, "红色") }
    else { XCTFail("ambient should be colorSwatch") }
}
```

- [ ] **Step 2: Run fail** — Expected: FAIL（familyDisplays/badgeStyle 未定义）
- [ ] **Step 3: 实现**
  - 🔴 **P1-3（审计 catch）：scope 角标聚合逻辑已在 `UIValueTypeMapper.swift:54`–`:129`**（individualDisplay dim badge `:65`-`:67` / aggregateDisplay 全车 emphasized `:110`-`:112` / 前排后排 `:230`-`:238`），且现有 5 测试已覆盖裂缝⑤⑥④ → **familyDisplays 必须【复用】这些不重写**（重写会回归，真新增仅 BadgeRenderStyle + family 维度）。
  - 加 `familyCardID: FamilyCardID` 字段 + `badgeStyle: BadgeRenderStyle` 派生（badge 分支二级穷尽 switch：`ambient.color`→colorSwatch / `seat.massage_mode`→mode / 余 plain，守 spec.md:83 禁 AnyView）
  - `familyDisplays(from:catalog:)`：① 按 `FamilyCardIDMapper.familyCardID(forBase:)` 分组，**🔴 P0-1 过滤 `nil`（vehicle.*/未知 不渲摘要层）**；② 每族取 `FamilyPrimaryCellMapper.primaryCellBase` 主 cell，复用现有 individualDisplay/aggregateDisplay 出摘要 + scope 角标。
  - **注：worker 按 Interfaces 写，现有 5 测试场景行为不变（防重构破坏聚合）**

- [ ] **Step 4: Run pass** + 全量 `swift test`（🔴 现有 `VehicleCardDisplayTests` 仍 **5 passed** 不破，实跑锚非计数声称）— Expected: PASS
- [ ] **Step 5: Commit** — `git commit -m "feat(uiue): VehicleCardDisplay family 分组 + BadgeRenderStyle 色块（AD-10/11）"`

### Task 5: ContentView 接线 + Grid + scope 角标 + numericText + breathe（TDD-view + 视觉验收）

**Files:** Modify `App/ContentView.swift`（vehicleCards 39-45 + VehicleStateCard 83-196）+ `App/DebugGallery.swift`

**Interfaces:** Consumes: `VehicleCardDisplay.familyDisplays`（Task 4）

- [ ] **Step 1: 接线**——`vehicleCards` 改 `Grid`（非 LazyVGrid，C22）渲 `VehicleCardDisplay.familyDisplays(from: store.presentationCells)`；`VehicleStateCard` 接 `display: VehicleCardDisplay`（title/valueText/scopeBadge/badgeStyle/visualState），删硬编码 title switch（142-163）。scope 角标渲 `display.scopeBadge`（dim/emphasized，content_glow 非 glass）。
- [ ] **Step 2: numericText**——值 `Text(display.valueText).contentTransition(.numericText())`，态变 `withAnimation(.snappy){ }`（**F-LB2 必包裹**）。
- [ ] **Step 3: breathe（仅激活态）**——`appearance.breathing` 时 `.repeatForever`（**非裸 Timer**，已有 onAppear 逻辑复用）。
- [ ] **Step 4: ambient 色块**——`switch display.badgeStyle { case .colorSwatch(let c): 卡边光/背景染 c }`（炸场，只读 D8.4）。
- [ ] **Step 5: build 两端** — Run: `Skill(ios-simulator-skill)` → `xcodebuild` macOS + iOS SUCCEEDED；遇错 `Skill(axiom-build)`。
- [ ] **Step 6: 🔴 视觉验收（must）** — `ios-simulator-skill` simctl 启动 iOS app + 截图：确认 10 族 family_card Grid（非 device 平铺）+ scope 淡角标 + ambient 色块 + 数字动效。**还原投屏实查不看高清图**（claim-vs-reality 第10坑）。存 `Reports/uiue-phase4a-proof/`。
- [ ] **Step 7: Commit**（带截图 artifact）— `git commit -m "feat(uiue): Phase 4a ContentView 接 family 摘要+scope角标+numericText+breathe"`

### Task 6: pre-commit 接线 enforce gate + force-state artifact（防接线丢失重演）

**Files:** Create `Tools/checks/check-contentview-uses-display-catalog.sh`（🔴 P0-2：放 `Tools/checks/` 与现役 check-no-binary-visualstate/check-platform-vs-version 一致，非 `.githooks/checks/`）+ Modify `.githooks/pre-commit`（引用 + 纠 stale 注释）

**Interfaces:** enforce「ContentView body **真调用** familyDisplays（非注释/字符串提及）」。

> 🔴 **P0-2 修复（审计 catch 三重失效）**：① 原 `grep VehicleCardDisplay` 一行注释即骗过（`echo "// VehicleCardDisplay" | grep -q` 实跑命中）→ strip 注释 + 验真调用 `familyDisplays(from:`；② 现役 check 在 `Tools/checks/`（`.githooks/pre-commit` 实引此目录），原计划放 `.githooks/checks/` 会不被跑；③ `.githooks/pre-commit` 注释 stale 说「hooksPath 未配置」，实核 `git config core.hooksPath`=`.githooks` 已生效，需纠注释。**🔴 grep 是辅助门，真 anti-claim 主门 = force-state 截图 artifact（Step 4 升为 PR 硬门）。**

- [ ] **Step 1: 写 check 脚本**（strip 注释 + 验真调用）

```bash
#!/usr/bin/env bash
# 接线 enforce：ContentView body 必须【真调用】familyDisplays(from:)（防前任「接线丢失、单测绿、注释里有词、以为做完」重演）
# 注：grep 是辅助门，主门 = force-state 截图 artifact（PR 强制）
set -euo pipefail
CV="App/ContentView.swift"
[ -f "$CV" ] || { echo "❌ $CV 不存在"; exit 1; }
# strip 行注释（防 `// VehicleCardDisplay` 假绿）
CODE=$(grep -vE '^[[:space:]]*//' "$CV")
# 必须真调用 familyDisplays(from:（非仅出现 VehicleCardDisplay 字符串/注释）
echo "$CODE" | grep -qE 'familyDisplays\(from:' \
  || { echo "❌ $CV body 未真调用 VehicleCardDisplay.familyDisplays(from:)（接线缺失/仅注释提及）"; exit 1; }
# Grid 固定列（C22），禁 LazyVGrid
echo "$CODE" | grep -q 'LazyVGrid' \
  && { echo "❌ $CV 仍有 LazyVGrid（spec C22 要求 Grid 固定列）"; exit 1; } || true
echo "✅ contentview-uses-display-catalog（真调用 familyDisplays + Grid）"
```

- [ ] **Step 2: 接进 `.githooks/pre-commit`**（与现役 check 同体例引 `Tools/checks/`）+ `chmod +x` + 🔴 纠 pre-commit stale 注释（删「hooksPath 未配置/待 Phase 3」，实已 `core.hooksPath=.githooks`）
- [ ] **Step 3: 验证 enforce 真有效**——① 临时把 ContentView 的 `familyDisplays(from:` 调用注释掉 → commit 被 reject ✓；② 临时加 `// familyDisplays(from:` 纯注释 → 仍 reject（strip 生效）✓；③ 恢复 → 通过。
- [ ] **Step 4: 🔴 force-state 截图 = PR 硬门（主 anti-claim 防线）**——`ios-simulator-skill` force-state 跑 7 态 × 关键场景 14 张，存 `Reports/uiue-phase4a-proof/`；PR template 加「无 14 张 force-state artifact 不准 merge」硬段（截图存在性可加 CI check）。
- [ ] **Step 5: Commit** — `git commit -m "chore(uiue): Phase 4a 接线 enforce gate（真调用验证）+ force-state artifact 硬门"`

### Phase 4a 验收门（4a 绿才进 4b）
- [ ] `swift test` 全绿（含 3 个新 mapper/display 测试 + 前任 **5** 测试不破，实跑锚 `swift test --filter VehicleCardDisplayTests`=**5 passed**）
- [ ] `xcodebuild` macOS + iOS SUCCEEDED 0 warning
- [ ] `make verify` exit 0（若 contracts 未碰应 N/A，跑确认）
- [ ] pre-commit gate 拦得住「删接线」
- [ ] `ios-simulator-skill` 5-gate：14 张满屏单态截图，**还原投屏实查**，magnet 审美 PASS
- [ ] 文档级联：tasks.md 4.1-4.4/7.A 勾 + design.md AD-9/10/11 + lessons 新坑回写
- [ ] **小 PR 并 main**（4a 独立可演 = 恢复并超越 proof 图态）

---

## Phase 4b — 展开层 + value.type 异构控件 + 座椅 composite（4a 绿后）

> 含 spike（Gauge `.accessoryCircular` 验 + 座椅 composite 字号投屏验），细节 spike 后展开。

### Task 7: value.type 异构控件（dial=Gauge / stepper=DSSegmentedControl / percent=Gauge.capacity）
- **skill**：`axiom-swiftui` + `axiom-design`(sf-symbols)；抄 ShipSwift `SWKPICard.swift:135`（numericText，P2-2 纠 :75→:135）+ DaVinci `DSSegmentedControl.swift:60`
- 🔬 **spike step**：`Gauge(.accessoryCircular)` iOS 渲染验（**非 watchOS `.circular`**，F-LB 坑）+ 投屏字号 ≥24pt
- TDD：每 value.type 渲染分支测 + 穷尽 switch（禁 AnyView）

### Task 8: 座椅 composite 卡（5 cell 行分 3 类，P4-D2②）
- 🔬 **spike**：composite 多行分段卡 = stepper(heat/vent/massage_force) + **enum chip 横滑(massage_mode 6 模式)** + percent 横条(backrest)；投屏字号验（lens7 七级分段）
- 抄 lens7 七级分段范式

### Task 9: 触发聚焦展开（D5 已锁 opacityScale 默认 + mge gated upgrade）
- **skill**：`axiom-swiftui`(animation-ref)
- opacityScale 默认（D5 锁）；mge gated upgrade = A2 编译验证 macOS matchedGeometry 在 Grid 可用后升（注：D5 锁 Grid 非 LazyVGrid，验证 Grid 里 mge）
- 320ms duration token（D5.Q5.4）

### Phase 4b 验收门：swift test + build + 5-gate 截图（含 value.type 控件 + 座椅 composite）+ spike 结论回写 lessons + 小 PR 并 main

---

## Phase 4c — 多意图错峰编排（4b 绿后，D8.5 已锁）

### Task 10: MultiCallSequencer 错峰（stagger 220ms + MAX_CONCURRENT_HIGHLIGHTS=1）
- D8.5 已锁，lens3 时序；FocusController 单点入口
- TDD：多意图序列化非并发，错峰 220ms

### Phase 4c 验收门：多意图 demo 截图 + 整体收口 loopaudit + 文档级联 grill-master §3 指针 done

---

## Self-Review（writing-plans 要求，CC 已自查）

**1. spec 覆盖**：spec.md:83 value.type→Task 4/7 ✓ / spec.md:171 scope 角标→Task 5 ✓ / 10 族 family_card→Task 2/4 ✓ / Grid 非 LazyVGrid→Task 5+gate ✓ / 7态→已 D7（4a 复用 CardAppearance）✓ / 聚焦过渡→Task 9（D5 锁）✓ / 多意图→Task 10 ✓。
**2. placeholder 扫描**：4a Task 1-6 完整代码；4b **Task 7/8 真 spike**（Gauge.accessoryCircular iOS 渲染验 / 座椅 composite 投屏字号验，有明确验证动作非 placeholder）；🔴 P2-5 **Task 9（聚焦过渡）+ Task 10（错峰）是 D5/D8.5 已锁实装非 spike**（措辞「已锁实装」非 spike-gated）。
**3. 类型一致**：FamilyCardID（Task 2 定义）→ Task 3/4 引用一致 / BadgeRenderStyle（Task 4）→ Task 5 消费一致 / familyDisplays（Task 4）→ Task 5 consumes 一致。
**4. 边界一致**：UIUE 改 App/+Core/Presentation/+ui-presentation/，禁碰 Core/State/+contracts/+generated/（全 task 守）。

## Execution Handoff
- 推荐 **subagent-driven-development**（fresh subagent/task + 两阶段 review）。
- 🔴 **magnet 指令：本计划稳健写好后，先派 subagent cc 审计本计划**（再执行 task）。

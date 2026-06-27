---
status: pre_ui_preparation
artifact_kind: interaction_integrity_matrix
date: 2026-06-27
repo: /Users/wanglei/workspace/MAformac-uiue
branch: uiue/phase4-default-scope-presentation
parent_authority: docs/grill-tournament/uiue-r0-r2-grill-decisions-2026-06-27.md
proof_class: local/docs-only
non_claims:
  - no 8.C2 closure
  - no V-PASS
  - no mobile
  - no true_device
  - no runtime-ready
  - no voice-ready
  - no A-2 complete
---

# UIUE R1 Interaction Integrity Matrix

## Verdict

本文件是 UI 改动前的 R1 Interaction Integrity 准备工件。它把 live code 中已存在的 mapper / contract / view writeback / UI test 证据串成矩阵，作为后续实现和审计的入口。它不授权 UI 实现，不关闭 `8.C2`，也不把 simulator/local proof 升格为 L3 或产品验收。

`StateCellInteractionPolicy` 当前不是 Swift 实体；live repo 里只在 formal authority / OpenSpec / roadmap 文档中出现。若后续需要落地，只能做 consumer-side read-only projection，派生自既有 contract / mapper / catalog / store，不得在 view 层新增第三份 value / range / enum / readback SSOT。

`verify-uiue-interactions` 仍只是 UIUE scoped gate candidate。它不得直接进入全局 `make verify-all`；进入长期 gate 前必须另有 grill 决策，说明 owner、runtime cost、failure ownership 和 false-positive policy。

## Source Map

| signal | source_file_line | live fact |
|---|---|---|
| family derivation | `Core/Presentation/FamilyCardIDMapper.swift:13` | `cell.key` base 前缀派生 10 族；未知 / `vehicle.*` 返回 nil。 |
| family primary base | `Core/Presentation/FamilyPrimaryCellMapper.swift:9` | 每族摘要 baseline primary cell 的消费侧映射，无 default。 |
| UI value type | `Core/Presentation/UIValueTypeMapper.swift:335` | `UIValueTypeMapper.mapping` 是显式映射；未知 base fail-closed。 |
| projector precedent | `Core/Presentation/UIValueTypeMapper.swift:379` | 已有 `StateCellUIValueTypeProjector` 证明 projection 可做 read-only 派生。 |
| enum/options | `Core/Presentation/UIValueTypeMapper.swift:311` | `BadgeOptionMapper` 只给 interactive mode bases 和 `ambient.color` 暴露 options。 |
| catalog enum/readback/range | `Core/Presentation/UIValueTypeMapper.swift:445`, `Core/Presentation/UIValueTypeMapper.swift:452`, `Core/Presentation/UIValueTypeMapper.swift:460` | `enumValues`、`renderReadback`、`executionRange` 均从 catalog / contract lookup 取。 |
| contract fields | `Core/Contracts/ContractLookups.swift:108`, `Core/Contracts/ContractLookups.swift:169`, `Core/Contracts/ContractLookups.swift:251` | `StateCellDefinition` 承载 type / values / executionRange / readback；parser 读取 YAML。 |
| range / snap / clamp | `Core/Presentation/ValueRangeMapper.swift:21`, `Core/Presentation/ValueRangeMapper.swift:50`, `Core/Presentation/ValueRangeMapper.swift:58` | range、valueString、snappedValue 均委托 `StateCellPresentationCatalog.executionRange`。 |
| ring gesture math | `Core/Presentation/ValueRangeMapper.swift:106` | `CircularControlGestureMapper` 只做坐标到 progress / signed delta 映射。 |
| expanded row projection | `Core/Presentation/ExpandedFamilyDisplay.swift:36`, `Core/Presentation/ExpandedFamilyDisplay.swift:53` | 展开层 row 从 family、UI value type、range、displayText、badgeStyle 派生。 |
| control gesture surface | `App/ValueControlView.swift:36`, `App/ValueControlView.swift:414`, `App/ValueControlView.swift:481` | `ValueControlView` 按 type 穷尽 switch；stepper/ring overlay 承接 tap/drag/a11y adjustable。 |
| writeback bridge | `App/ExpandedFamilyCard.swift:91`, `App/ExpandedFamilyCard.swift:102`, `App/ExpandedFamilyCard.swift:114`, `App/ExpandedFamilyCard.swift:127`, `App/ExpandedFamilyCard.swift:135` | `ValueControlActions` 把 numeric/toggle/badge 操作写回 `onMockTransition`。 |
| mock transition | `App/ContentView.swift:309` | `applyMockTransition` 写 store、append readback、设置 `proofClass: .simulatorMock`。 |
| store readback | `Core/State/DemoVehicleStateStore.swift:127`, `Core/State/DemoVehicleStateStore.swift:229` | `applyMockTransition` 更新 cell，`spokenText` 优先走 catalog `renderReadback`。 |
| proof class enum | `Core/Presentation/PresentationSnapshot.swift:14`, `Core/Presentation/PresentationSnapshot.swift:152` | `PresentationProofClass` 有 `localMock/staticPreview/simulatorMock/operatorReview`；snapshot 默认 local mock。 |
| mapping tests | `Tests/MAformacCoreTests/UIValueTypeMappingTests.swift:29`, `Tests/MAformacCoreTests/UIValueTypeMappingTests.swift:79`, `Tests/MAformacCoreTests/UIValueTypeMappingTests.swift:104`, `Tests/MAformacCoreTests/UIValueTypeMappingTests.swift:123` | 单测守 mapping 闭合、options 来自 contract、只读 badge 不暴露假 options、语义对齐。 |
| range tests | `Tests/MAformacCoreTests/ValueRangeMapperTests.swift:10`, `Tests/MAformacCoreTests/ValueRangeMapperTests.swift:48`, `Tests/MAformacCoreTests/ValueRangeMapperTests.swift:53`, `Tests/MAformacCoreTests/ValueRangeMapperTests.swift:71` | 单测守 range、snap、ring zone、toggle enum cycle。 |
| UI coverage | `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift:82`, `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift:313`, `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift:335`, `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift:359`, `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift:385`, `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift:409`, `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift:440`, `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift:464` | UI test 覆盖 10 族代表 touch、ring/stepper 空间语义、mode options、summary readback。 |

## Consumer Projection Shape

后续如实现 `StateCellInteractionPolicy`，字段应是 read-only projection，不是新的业务源：

| field | derive from | forbidden |
|---|---|---|
| `family` | `FamilyCardIDMapper.familyCardID(forBase:)` | 在 view 内按字符串另写 family 表。 |
| `state_key/base` | `ScopedStateKey` + `DemoVehicleStateCell.key` | 把 scoped key 和 base 拆分规则复制到各 View。 |
| `primary_cell` | `FamilyPrimaryCellMapper.primaryCellBase(for:)` | 让 UI test 或 layout 代码定义 primary。 |
| `ui_value_type` | `UIValueTypeMapper.uiValueType(forBase:)` | 新增 view-local default。 |
| `range/step/snap` | `ValueRangeMapper` + `StateCellPresentationCatalog.executionRange` | 第二套 min/max/step 或格式化。 |
| `enum/options` | `StateCellPresentationCatalog.enumValues` + `BadgeOptionMapper.options` | 第二套枚举列表；把只读/process badge 渲染成假选择器。 |
| `gesture` | `ValueControlView` gesture layers | 让 gesture 决定 contract 值域或 enum 语义。 |
| `writeback_path` | `ExpandedFamilyCard` actions -> `ContentView.applyMockTransition` -> `DemoVehicleStateStore.applyMockTransition` | 绕开 mock store 或只改本地 UI state。 |
| `summary_readback` | `VehicleCardDisplay.familyDisplays` + `DemoVehicleStateStore.spokenText` | view 内拼另一份 readback。 |
| `proof_class` | `PresentationSnapshot.proofClass` | 用 UI test 或截图自动升级到 L3。 |

## Representative Matrix

| family | state_key/base | primary_cell | ui_value_type | range/step/snap | enum/options | gesture | writeback_path | summary_readback | proof_class | test_coverage | gap | source_file_line |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| ac | `ac.temp_setpoint` | `ac.temp_setpoint` | `dial` | 18...32 / step 1 / `ValueRangeMapper.valueString` snap | n/a | ring tap inc/dec, ring drag, a11y adjustable | `ValueControlView.StepperLikeShell` -> `ExpandedFamilyCard.setNumeric/stepped` -> `ContentView.applyMockTransition` -> store | outer summary expected `空调 27℃`; store readback uses `readback_zh` when available | `simulatorMock` when UI action writes snapshot | 10-family primary touch covers tap; unit covers range/snap; ring drag proof uses window percent, not ac dial | no ac-specific drag UI test; multi-scope AC rows not fully matrixed | `Core/Presentation/FamilyPrimaryCellMapper.swift:12`; `contracts/state-cells.yaml:55`; `App/ValueControlView.swift:48`; `App/ExpandedFamilyCard.swift:102`; `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift:83` |
| seat | `seat.heat_level` | `seat.heat_level` | `stepper` | 0...3 / step 1 / clamp + snap | n/a | stepper left/right tap, drag implemented, a11y adjustable | `StepperBarGestureLayer` -> `ExpandedFamilyCard.stepped/setNumeric` -> `applyMockTransition` | outer summary expected `座椅 3挡` | `simulatorMock` when UI action writes snapshot | 10-family primary touch covers tap; stepper spatial tap covers left/right; unit covers stepCount | stepper drag implementation has no UI test; seat vent/massage_force rows not full matrix | `Core/Presentation/FamilyPrimaryCellMapper.swift:13`; `contracts/state-cells.yaml:183`; `App/ValueControlView.swift:93`; `App/ValueControlView.swift:414`; `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift:91` |
| window | `window.position` | `window.position` | `percent` | 0...100 / step 1 / clamp + snap | n/a | ring lower tap dec, upper-left tap inc, drag clockwise/counter-clockwise, a11y adjustable | `CircularAdjustmentGestureLayer` -> `ExpandedFamilyCard.setNumeric/stepped` -> `applyMockTransition` | outer summary expected `车窗 61%` | `simulatorMock` when UI action writes snapshot | 10-family primary touch, percent ring spatial tap, percent ring drag | ring drag across zero boundary and other percent bases not fully covered | `Core/Presentation/FamilyPrimaryCellMapper.swift:14`; `contracts/state-cells.yaml:95`; `App/ValueControlView.swift:70`; `App/ValueControlView.swift:481`; `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift:99` |
| screen | `screen.brightness` | `screen.brightness` | `percent` | 0...100 / step 1 / clamp + snap | n/a | ring tap/drag path inherited from percent control | same percent writeback path -> store -> summary | outer summary expected `屏幕 66%` | `simulatorMock` when UI action writes snapshot | 10-family primary touch covers a tap | no screen-specific spatial tap/drag UI test; multi-screen scopes not fully matrixed | `Core/Presentation/FamilyPrimaryCellMapper.swift:15`; `contracts/state-cells.yaml:131`; `App/ValueControlView.swift:70`; `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift:107` |
| ambient | `ambient.brightness` for representative touch; baseline primary is `ambient.color` | `ambient.color` | `percent` for brightness; `badge` for color | brightness 0...100 / step 1; color has no range | color options are 8 canonical colors; brightness has none | brightness ring tap/drag path; color palette select path | brightness writes through numeric path; color writes through `selectBadge` / `cycleBadge` | representative summary expected `氛围灯 63%` after active cell changes; color mode has separate picker test | `simulatorMock` when UI action writes snapshot | ambient brightness circle UI test; 10-family representative touch; color picker test | baseline primary and representative touch differ by design; needs explicit R1 decision whether active-cell summary can supersede `FamilyPrimaryCellMapper` primary | `Core/Presentation/FamilyPrimaryCellMapper.swift:16`; `Core/Presentation/UIValueTypeMapper.swift:320`; `contracts/state-cells.yaml:151`; `contracts/state-cells.yaml:159`; `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift:115`; `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift:313` |
| door | `door.central_lock` | `door.central_lock` | `toggle` | no numeric range | enum `[locked, unlocked]` from contract | button tap, a11y button | `ValueControlView.toggleVisual` -> `ExpandedFamilyCard.toggle` -> `ValueRangeMapper.toggledValue(current:forBase:)` -> store | outer summary expected `车门 开` | `simulatorMock` when UI action writes snapshot | 10-family primary touch covers tap; unit covers enum toggle cycle | `door.child_lock` and `door.car_door` affordance/read-only policy not fully UI-covered | `Core/Presentation/FamilyPrimaryCellMapper.swift:17`; `contracts/state-cells.yaml:251`; `App/ValueControlView.swift:133`; `App/ExpandedFamilyCard.swift:127`; `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift:139` |
| volume | `volume.level` | `volume.level` | `percent` | 0...100 / step 1 / clamp + snap | mode options derive only for `volume.mode` | ring tap/drag path inherited from percent control | numeric writeback path -> store -> summary | outer summary expected `音量 39%` | `simulatorMock` when UI action writes snapshot | 10-family primary touch covers tap; unit covers percent range semantics indirectly | no volume-specific drag UI test; `volume.mode` option picker not specifically UI-covered | `Core/Presentation/FamilyPrimaryCellMapper.swift:18`; `contracts/state-cells.yaml:283`; `Core/Presentation/UIValueTypeMapper.swift:315`; `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift:123` |
| wiper | `wiper.speed` for representative touch; baseline primary is `wiper.power` | `wiper.power` | `stepper` for speed; `toggle` for power | speed 1...4 / step 1 / clamp + snap; power no range | mode options derive only for `wiper.mode` | speed stepper tap/drag path; power toggle path | speed writes through numeric path; power writes through toggle path | representative summary expected `雨刮 2挡` after active cell changes | `simulatorMock` when UI action writes snapshot | 10-family representative touch covers `wiper.speed`; stepper spatial tap semantics covered on seat | baseline primary and representative touch differ; no wiper-specific drag/toggle UI test; active-cell override needs explicit matrix treatment | `Core/Presentation/FamilyPrimaryCellMapper.swift:19`; `contracts/state-cells.yaml:314`; `contracts/state-cells.yaml:322`; `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift:131` |
| sunroofShade | `sunroof.position` | `sunroof.position` | `percent` | 0...100 / step 1 / clamp + snap | motion badge has no interactive options | ring tap/drag path inherited from percent control | numeric writeback path -> store -> summary | outer summary expected `天窗遮阳 1%` | `simulatorMock` when UI action writes snapshot | 10-family primary touch covers tap | `sunshade.position` is same family but not representative-covered; no sunroof-specific drag UI test | `Core/Presentation/FamilyPrimaryCellMapper.swift:20`; `Core/Presentation/FamilyCardIDMapper.swift:29`; `contracts/state-cells.yaml:347`; `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift:147` |
| fragrance | `fragrance.power` | `fragrance.power` | `toggle` | no numeric range | `fragrance.mode` options derive from contract; power enum `[on, off]` | button tap for power; mode palette / intensity stepper separate | power toggle path -> store -> summary | outer summary expected `香氛 开` | `simulatorMock` when UI action writes snapshot | 10-family primary touch covers power toggle | `fragrance.mode` option picker and `fragrance.intensity` stepper not UI-covered in 8.C2 tests | `Core/Presentation/FamilyPrimaryCellMapper.swift:21`; `contracts/state-cells.yaml:385`; `contracts/state-cells.yaml:393`; `contracts/state-cells.yaml:400`; `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift:155` |

## Coverage Gaps Before Claiming R1

| gap_id | scope | why it matters | recommended next action |
|---|---|---|---|
| R1-GAP-001 | `StateCellInteractionPolicy` / equivalent projection | No Swift entity exists yet; implementing it incorrectly could create a third value/range/enum SSOT. | If implemented, make it a pure read-only projection over the source map above; unit test it against catalog/mapper outputs. |
| R1-GAP-002 | active-cell vs baseline primary | `ambient` and `wiper` representative touch uses an active cell different from `FamilyPrimaryCellMapper` baseline primary. This is valid in live code via `VehicleCardDisplay.summaryDisplay`, but must be explicit in the matrix. | Record both `primary_cell` and `state_key/base`; add tests for active-cell summary override if R1 claims full integrity. |
| R1-GAP-003 | stepper drag | `StepperBarGestureLayer.setValue` implements drag, but current UI tests cover only left/right tap. | Add UI test or unit-level gesture mapping proof before claiming stepper drag coverage. |
| R1-GAP-004 | ring edge cases | Ring tap and one drag path are covered, but cross-zero boundary and all percent/dial bases are not. | Add focused unit tests for `CircularControlGestureMapper.signedProgressDelta` plus at least one boundary UI smoke. |
| R1-GAP-005 | read-only/process badge affordance | Unit tests prevent fake options for several read-only bases, but UI affordance screenshots/matrix are not complete. | Include read-only/process rows in the future matrix receipt and ensure no primary touch target is exposed for them. |
| R1-GAP-006 | proof class escalation | UI test proof is simulator/local; no human L3 or product acceptance comes from this matrix. | Keep all closeouts explicit: `local/unit/simulator` only until L3 signs. |
| R1-GAP-007 | `verify-uiue-interactions` automation | No Makefile target exists and no gate decision has been signed. | Draft UIUE-only gate decision before adding automation; do not modify global `make verify-all` by default. |

## Pre-UI Checklist

- Any new control affordance must have a row in this matrix before claiming coverage.
- Any row with `range/step/snap` must cite `ValueRangeMapper` / `StateCellPresentationCatalog.executionRange`, not View constants.
- Any row with `enum/options` must cite `StateCellPresentationCatalog.enumValues` or `BadgeOptionMapper`; process/read-only badge options must stay empty unless explicitly decided.
- Any writeback claim must prove the path reaches `DemoVehicleStateStore.applyMockTransition` and summary readback updates.
- Any `proof_class` must match the evidence layer; simulator UI tests do not imply L3, mobile, true device, runtime readiness, or V-PASS.
- `8.C2` remains open until the L0-L3 evidence package and human 5-gate verdict close it.

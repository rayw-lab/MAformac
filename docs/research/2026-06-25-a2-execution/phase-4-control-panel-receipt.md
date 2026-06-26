# Phase 4 Demo Control Panel Receipt

Date: 2026-06-26
Status: DONE for the A-2 Phase 4 simulator/mock interaction scope; not product V-PASS
Proof class: local + unit + simulator mock

## Scope

Implemented the Phase 4 mock-frontstage demo control panel:

- Demo control panel with NormalRun, vehicle context, environment context, and cabin macro modules.
- Settings sheet route to the demo control panel.
- All-state sheet grouped by vehicle, environment, and the 10 family display order.
- Control panel context writes only mock `PresentationSnapshot` / `DemoVehicleStateStore` state; no true NLU, ASR, LoRA, live API, or real vehicle backend is connected.
- DEBUG-only launch harness for repeatable simulator screenshots of the control panel and all-state sheet.

## Authority

- Grill SD13-SD15 define the control panel blocks, iPhone control-center layout, AllStateSheet grouping, and visual alignment.
- ui-presentation spec mock-frontstage requirement requires force context/state to remain mock-only.
- Tools/skills teardown used:
  - `Tools/skills/ios-simulator-skill/SKILL.md` for simulator workflow.
  - `Tools/skills/axiom/skills/axiom-design/SKILL.md` and `hig.md` / `liquid-glass.md` for functional glass/material layering.
  - `Tools/skills/axiom/skills/axiom-swiftui/skills/layout.md` for container-responsive SwiftUI layout.
  - `Tools/agent-platform-plugin-refs/build-ios-apps-skills/swiftui-ui-patterns/references/sheets.md` for sheet routing pattern.
- Reference repo teardown informed structure only, not copied implementation:
  - IceCubes `SettingsTab.swift`: NavigationStack/Form/sheet destination pattern.
  - ShipSwift `SettingView.swift` / `ComponentView.swift`: settings module entry pattern.

## Code Evidence

- `App/DemoControlPanel.swift:3` defines speed presets, gear, weather, time period, and cabin scene macros.
- `App/DemoControlPanel.swift:97` implements `DemoControlPanel`.
- `App/DemoControlPanel.swift:157` implements NormalRun and AllStateSheet entry.
- `App/DemoControlPanel.swift:181` implements vehicle speed/gear segmented force controls.
- `App/DemoControlPanel.swift:188` implements weather/time-period segmented force controls.
- `App/DemoControlPanel.swift:195` implements cabin scene macro buttons.
- `App/DemoControlPanel.swift:373` implements `AllStateSheet`.
- `App/DemoControlPanel.swift:443` groups all-state entries by vehicle, environment, then `FamilyCardID.displayOrder`.
- `App/DemoControlPanel.swift:460` builds all-state entries from `StateCellPresentationCatalog.shared.cellDefinitions`.
- `App/DemoControlPanel.swift:521` uses a 7-state exhaustive switch for all-state cell stroke opacity; no binary `visualState == .normal ? ...` compression.
- `App/ContentView.swift:68` routes settings/demo-control sheets by enum.
- `App/ContentView.swift:223` writes forced vehicle context into mock snapshot state.
- `App/ContentView.swift:231` applies NormalRun defaults.
- `App/ContentView.swift:243` applies cabin scene macros to mock store cells.
- `App/ContentView.swift:300` rebuilds `PresentationSnapshot` with `.simulatorMock`.
- `Core/Presentation/UIValueTypeMapper.swift:383` exposes contract default values to the control panel.
- `Core/Presentation/UIValueTypeMapper.swift:387` exposes the 33 state-cell definitions for AllStateSheet.
- `App/MAformacApp.swift:22` adds DEBUG-only `-showDemoControlPanel` screenshot harness.
- `App/MAformacApp.swift:24` adds DEBUG-only `-showDemoAllStates` screenshot harness.

## Test Evidence

- `Tests/MAformacCoreTests/VehicleCardDisplayTests.swift:16` asserts the control panel catalog exposes 33 state-cell definitions and contract defaults.

## Runtime Evidence

- Main stage still launches on iPhone 17 Pro Max simulator:
  `docs/research/2026-06-25-a2-execution/shots/phase4-main-before-control.png`
- Demo control panel screenshot:
  `docs/research/2026-06-25-a2-execution/shots/phase4-demo-control-panel.png`
- All-state sheet screenshot:
  `docs/research/2026-06-25-a2-execution/shots/phase4-all-states-sheet.png`

## Validation

- `swift test` PASS: 243 tests, 3 skipped, 0 failures.
- `xcodebuild -project MAformac.xcodeproj -scheme MAformacIOS -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -derivedDataPath .build/dd-ios build` PASS.
- `xcodebuild -project MAformac.xcodeproj -scheme MAformacMac -destination 'platform=macOS' -derivedDataPath .build/dd-mac build` PASS.
- Mechanical scan `rg -n "visualState == \\.normal|== \\.normal \\?|\\? .*: .*appearance\\.border|NavigationSplitView|SplitView|LazyVGrid" App Core Tests` found only a test assertion, no UI binary visual-state branch or SplitView/LazyVGrid violation.

## Coverage Index

Current checked off:

- SD13: control panel blocks implemented.
- SD14: iPhone control-center layout and AllStateSheet based on 33 state cells implemented.
- SD15: control panel visual alignment and time-period/theme separation implemented.
- SD8: settings/refresh route has simulator proof for theme switching, scene macro force, and reset.
- SD12: scene macro + terminal state module flow has simulator proof for the rain macro.
- RPB-52: forced vehicle/environment context exposed through segmented mock controls.

Historical P0/P2 gap, superseded by the P3 follow-up below:

- SD8 and SD12 were initially left open because settings-entry/macro route proof had not been captured. The P3 follow-up records the serial simulator route and closes them for A-2 simulator/mock scope only.

## Residual Risks

- True-device proof and customer-facing demo acceptance are not claimed.
- Historical `idb`/`computer-use` navigation gaps are retained below as P2 context; the current Phase 4 closure uses XcodeBuildMCP serial simulator UI tree, tap, and screenshot proof.

## P2 Inner-Loop Settings Route Probe

Date: 2026-06-26

Status: Historical P2 blocker for 8.E4 / SD8 route closure, resolved by the P3 follow-up below.

Observed serial simulator actions:

- From main stage, `tap(settings)` first dismissed the expanded card overlay and did not open the settings sheet.
- After refreshing and tapping settings again, the settings sheet opened. Runtime UI tree exposed theme tabs, `演绎控制台`, `复位`, `制冷`, `制热`, and `安全拒识`.
- `tap(演绎控制台)` succeeded as a UI action, but the refreshed UI tree returned to the main stage instead of presenting `DemoControlPanel`.
- Screenshot after the failed route: `docs/research/2026-06-25-a2-execution/shots/phase4-settings-control-route-failed-v1.jpg`.

Interpretation:

- Settings entry itself had simulator proof.
- The nested `SettingsPanel` → `DemoControlPanel` sheet route was not closed at P2. This likely reflected the then-current single `presentedSheet` host dismissing/replacing the settings sheet without presenting the second sheet in the next transaction.
- This P2 blocker is superseded by the P3 follow-up, which closes `8.E4`, SD8, and SD12 for A-2 simulator/mock scope.

## P0 Commit Anchor: Phase 4 control-panel proof slice

Commit subject: `docs(uiue): anchor phase4 control-panel proof slice`

This commit anchors the Phase 4 receipt and the three simulator screenshots cited above. The implementation files (`DemoControlPanel.swift`, `ContentView.swift`, `MAformacApp.swift`, `UIValueTypeMapper.swift`, and the dependent test) are already anchored in shared scaffold commit `98f7c57` because the sheet route and DEBUG harness are compile-linked with the continuous-stage shell.

Not anchored in the P0 proof-slice commit: SD8 settings-entry physical tap proof, SD12 full cabin macro interaction recording, or product V-PASS.

P0 claim boundary at that commit: `PARTIAL / local+simulator-pass` in the isolated UIUE worktree, mock-frontstage only, not mainline proof and not live/backend proof.

The serial settings-route and macro-interaction evidence was gathered later in the P3 follow-up below.

## P3 Follow-up: Settings Route + Theme + Macro + Reset Closure

Date: 2026-06-26

Status: DONE for the A-2 Phase 4 simulator/mock interaction scope. Proof remains local/simulator only, not true-device, not mainline proof, not product V-PASS.

Code change:

- `ContentView` now queues `.demoControl` while dismissing the current `.settings` sheet, then presents the queued sheet from the root `.sheet(item:onDismiss:)` handler after dismissal. This preserves the single enum-driven sheet router and fixes the nested settings-to-control-panel route.
- `SettingsPanel` still owns the visible settings action and dismisses itself after requesting the queued route.
- `DemoControlPanel` now exposes `accessibilityIdentifier("demo-control-panel")` for stable runtime proof.

Serial simulator evidence:

- `build_run_sim` with `-mockTheme ivory -mockSnapshot cooling`: PASS on iPhone 17 Pro Max simulator.
- Tap `设置` (`e62`/`e63`) -> settings sheet opened and exposed theme tabs plus `演绎控制台`.
- Tap `演绎控制台` (`e97`) -> route opened `DemoControlPanel`; UI tree exposed `Mock Force`, `方案经理幕后工具`, `整车运行`, `环境情境`, and `座舱场景`.
- Screenshot: `docs/research/2026-06-25-a2-execution/shots/phase4-settings-route-control-panel-fixed-v1.jpg`.
- Scroll control panel (`e82`) -> tap `执行雨天场景宏` (`e124`) -> UI tree changed main-stage mock state to `车窗 0% 执行中`, `雨刮 开 执行中`, `天窗遮阳 0% 执行中`, and dialogue `已 force 雨天 场景`.
- Screenshot: `docs/research/2026-06-25-a2-execution/shots/phase4-cabin-macro-rainy-result-v1.jpg`.
- Tap theme `深空` (`e89`) -> UI tree changed theme tabs from `米白|1 / 深空|0` to `米白|0 / 深空|1`.
- Screenshot: `docs/research/2026-06-25-a2-execution/shots/phase4-settings-theme-deepspace-v1.jpg`.
- Tap settings `复位` (`e125`) -> UI tree returned to idle reset state: dialogue `我在听...`, `车窗 60% 已满足`, `雨刮 开 待命`, `天窗遮阳 0% 待命`.
- Screenshot: `docs/research/2026-06-25-a2-execution/shots/phase4-settings-reset-result-v1.jpg`.

What this closes:

- OpenSpec `8.E4`: settings panel route, theme toggle, scene macro force, and reset proof are all simulator-proven.
- SD8: settings/refresh route now has simulator proof for theme, macro force, and reset.
- SD12: scene macro + terminal state module flow now has simulator proof for at least the rain macro.

Residual risks:

- This does not claim true-device proof or customer-facing demo acceptance.
- It does not close Phase 2 visual acceptance.

## P3 Follow-up Commit Anchor: Phase 4 settings-route closure

Commit subject: `fix(uiue): close phase4 settings control route`

This commit anchors the nested sheet router fix, the stable control-panel accessibility identifier, the four runtime screenshots above, and the tasks/coverage/closeout receipt reconciliation for `8.E4`, SD8, and SD12.

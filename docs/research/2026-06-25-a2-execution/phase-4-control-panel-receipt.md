# Phase 4 Demo Control Panel Receipt

Date: 2026-06-26
Status: PARTIAL / local+simulator-pass
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

Checked off:

- SD13: control panel blocks implemented.
- SD14: iPhone control-center layout and AllStateSheet based on 33 state cells implemented.
- SD15: control panel visual alignment and time-period/theme separation implemented.
- RPB-52: forced vehicle/environment context exposed through segmented mock controls.

Not checked off:

- SD8: Settings route exists in code, but physical settings-entry tap proof was not captured.
- SD12: Cabin macro code exists, but full macro interaction recording was not captured.

## Residual Risks

- `ios-simulator-skill` semantic navigation was blocked by missing `idb`; screenshot proof uses DEBUG-only launch harness instead of recorded tap navigation through Settings.
- `computer-use` could not attach to Simulator (`cgWindowNotFound`), and System Events click failed with `-25200`, so no physical tap chain is claimed.
- The control panel screenshot shows the top modules; the cabin macro module is lower in the scroll and is covered by code evidence rather than a scrolled screenshot in this receipt.

## P2 Inner-Loop Settings Route Probe

Date: 2026-06-26

Status: BLOCKER for 8.E4 / SD8 route closure.

Observed serial simulator actions:

- From main stage, `tap(settings)` first dismissed the expanded card overlay and did not open the settings sheet.
- After refreshing and tapping settings again, the settings sheet opened. Runtime UI tree exposed theme tabs, `演绎控制台`, `复位`, `制冷`, `制热`, and `安全拒识`.
- `tap(演绎控制台)` succeeded as a UI action, but the refreshed UI tree returned to the main stage instead of presenting `DemoControlPanel`.
- Screenshot after the failed route: `docs/research/2026-06-25-a2-execution/shots/phase4-settings-control-route-failed-v1.jpg`.

Interpretation:

- Settings entry itself now has simulator proof.
- The nested `SettingsPanel` → `DemoControlPanel` sheet route is not closed. This likely reflects the current single `presentedSheet` host dismissing/replacing the settings sheet without presenting the second sheet in the next transaction.
- Keep `8.E4`, SD8, and SD12 open. Do not promote Phase 4 beyond `PARTIAL`.

## P0 Commit Anchor: Phase 4 control-panel proof slice

Commit subject: `docs(uiue): anchor phase4 control-panel proof slice`

This commit anchors the Phase 4 receipt and the three simulator screenshots cited above. The implementation files (`DemoControlPanel.swift`, `ContentView.swift`, `MAformacApp.swift`, `UIValueTypeMapper.swift`, and the dependent test) are already anchored in shared scaffold commit `98f7c57` because the sheet route and DEBUG harness are compile-linked with the continuous-stage shell.

Not anchored here: SD8 settings-entry physical tap proof, SD12 full cabin macro interaction recording, or product V-PASS.

Claim boundary: `PARTIAL / local+simulator-pass` in the isolated UIUE worktree, mock-frontstage only, not mainline proof and not live/backend proof.

Next: gather serial settings-route and macro-interaction evidence before checking SD8/SD12 or promoting the Phase 4 receipt.

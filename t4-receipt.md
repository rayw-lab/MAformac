# T4 Mac Interaction Contract Receipt

- task: T4-Mac交互契约（D1a）
- date: 2026-07-08
- worktree: `/Users/wanglei/workspace/MAformac-d1a-t4`
- branch: `uiue/d1a-t4-interaction-20260708`
- base: main worktree HEAD `bdd40892`
- proof_class: `local` + `unit` + `build`; not `desktop_operator_equivalent`, not `true_device`, not `V-PASS`

## Inputs Read

- `Tools/agent-platform-plugin-refs/build-macos-apps-skills/swiftui-patterns/SKILL.md`
- `Tools/agent-platform-plugin-refs/build-macos-apps-skills/build-run-debug/SKILL.md`
- `Tools/agent-platform-plugin-refs/build-macos-apps-skills/test-triage/SKILL.md`
- `Tools/agent-platform-plugin-refs/build-macos-apps-skills/appkit-interop/SKILL.md`
- `Tools/agent-platform-plugin-refs/build-macos-apps-skills/swiftui-patterns/references/commands-menus.md`
- `Tools/agent-platform-plugin-refs/build-macos-apps-skills/appkit-interop/references/responder-menus.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-08-daywork/ios-uiue-motion-inventory.md` T4 section
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-08-daywork/D0-GRILL-INDEX.md` D0G-029/D0G-030/D0G-031/D0G-033/D0G-034

## Changed Files

- `App/ContentView.swift`
- `Tests/MAformacCoreTests/T4MacInteractionContractTests.swift`
- `MAformacIOSUITests/T4MacInteractionUITests.swift`

## Contract Mapping

- D0G-029: `VehicleStateCard` now has `.onHover`, hover lift/outline, 800ms dwell tooltip, and no `visualState` mutation. Business `display.visualState` remains the source of card appearance.
- D0G-030: card click path remains `onTap(family)` only. It expands/view-selects and does not call TTS, runtime control, store mutation, or mock vehicle execution.
- D0G-031: cards are `.focusable(true)`, keyboard focus has a dedicated outline/lift, and `hoverActive = isHovered && !isKeyboardFocused` makes keyboard focus win over hover.
- D0G-033: `MicDock` no longer uses click toggle or long-press gesture. It uses mouse down/up via zero-distance drag, Option+Space via `NSEvent` local key monitor, drag-out cancel, and focus-loss cancel.
- D0G-034: Esc routes to cancel through macOS `.onExitCommand` and the key monitor. Listening/speaking/cancel labels are separated. Mic permission preflight is a stub guidance seam, not a live permission claim.

## Validation

- `gitnexus impact VehicleStateCard --repo MAformac-r5-main-current --direction upstream --file App/ContentView.swift --depth 2 --summary-only` -> LOW, impactedCount 8, processes_affected 0.
- `gitnexus impact MicDock --repo MAformac-r5-main-current --direction upstream --file App/ContentView.swift --depth 2 --summary-only` -> LOW, impactedCount 4, processes_affected 0.
- `gitnexus impact ContentView --repo MAformac-r5-main-current --direction upstream --file App/ContentView.swift --depth 2 --summary-only` -> HIGH, impactedCount 140, direct 3, processes_affected 0. Meaning: `ContentView` is a shared large view file with broad structural blast radius; this is not a claim that the T4 leaf changes themselves are high-risk.
- TDD red run before implementation: `swift test --filter T4MacInteractionContractTests` -> 13 expected failures.
- `swift test --filter T4MacInteractionContractTests` -> passed, 3 tests, 0 failures.
- `swift build` -> passed. SwiftPM emitted existing unhandled-file warnings for repository files/test artifacts.
- `xcodebuild -project MAformac.xcodeproj -scheme MAformacMac -configuration Debug -destination 'platform=macOS' build` -> `** BUILD SUCCEEDED **`.
- First concurrent iOS build-for-testing attempt hit DerivedData `build.db` lock; sequential retry below passed.
- `xcodebuild -project MAformac.xcodeproj -scheme MAformacIOS -configuration Debug -destination 'generic/platform=iOS Simulator' build-for-testing` -> `** TEST BUILD SUCCEEDED **`.
- `xcodebuild -project MAformac.xcodeproj -scheme MAformacIOS -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' test -only-testing:MAformacIOSUITests/T4MacInteractionUITests` -> `** TEST SUCCEEDED **`, 1 UI test executed as authored skip under iOS host, 0 failures.
- T4F fresh `gitnexus detect-changes --repo MAformac-r5-main-current --scope working` after the P1 fixes -> 2 files, 12 symbols, 0 affected processes, risk low.

## XCUITest Status

- status: `authored_pending_mac_host_run`
- resource_window: current run validated compile and iOS-host executable skip before 23:30; a true macOS UI host/scheme is not present in this worktree, so desktop interaction execution remains pending.
- non_claim: iOS-host skipped XCUITest is not evidence that Tab/Enter/Option+Space worked in a live macOS app window.

## Non Claims

- No push.
- No main-tree writes.
- No microphone permission runtime prompt was exercised.
- No desktop operator equivalent proof or visual review was performed.

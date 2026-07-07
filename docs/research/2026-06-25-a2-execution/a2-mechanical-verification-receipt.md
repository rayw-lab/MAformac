# UIUE A-2 Mechanical Verification Receipt

Captured at: 2026-06-26 04:33:42 CST

Status: DONE for `8.C1` mechanical/local gates.

Proof class: local + unit. This does not prove visual acceptance, simulator anchor parity, mobile true-device behavior, live ASR/NLU/TTS, LoRA, or backend wiring.

## Scope

- Verify the current A-2 implementation can pass the local hard gates required by OpenSpec task `8.C1`.
- Repair only the gate harness if it gives a demonstrably false negative.
- Do not mark Phase 2 visual/anchor quality or true-device acceptance as complete.

## Change Made During Verification

- `Tools/checks/check-contentview-uses-display-catalog.sh`
  - Replaced `printf "$CODE" | grep -qE ...` with `grep -qE ... <<< "$CODE"`.
  - Reason: the script uses `set -o pipefail`; `grep -q` can exit early after a match, causing the upstream `printf` to receive `SIGPIPE` and making a real match look like a failed gate.
  - The original rules remain unchanged: `ContentView` must call `VehicleCardDisplay.familyDisplays(from:)`, must not use `LazyVGrid`, and `VehicleCardsGrid` must consume `familyDisplays`.

## Validation

| Command | Proof class | Result |
|---|---|---|
| `Tools/checks/check-contentview-uses-display-catalog.sh` | local | PASS: `ContentView` true-calls `familyDisplays(from:)`, `VehicleCardsGrid` consumes `familyDisplays`, no `LazyVGrid` |
| `make verify-all` | local + unit | PASS exit 0; includes source snapshot check, generation diff gate, reference checks, default-scope checks, ContentView wiring gate, and Swift tests |
| `swift test` via `make verify-all` | unit | PASS: 245 tests executed, 3 skipped, 0 failures |
| `xcodebuild -project MAformac.xcodeproj -scheme MAformacIOS -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -derivedDataPath .build/dd-ios build` | local | PASS: `** BUILD SUCCEEDED **` |
| `xcodebuild -project MAformac.xcodeproj -scheme MAformacMac -destination 'platform=macOS' -derivedDataPath .build/dd-mac build` | local | PASS: `** BUILD SUCCEEDED **` |

## Open Items Not Claimed

- `8.C2` remains open: visual-acceptance 5-gate and anchor-set comparison are not completed by this receipt.
- Phase 2 receipt remains `PARTIAL`: anchor parity and user visual acceptance still need closure.
- Phase 3 receipt remains `PARTIAL`: mock touch chain is code/test supported, but physical UI tap acceptance is still not claimed.
- Phase 4 receipt remains `PARTIAL`: settings/control-panel simulator evidence exists, but no broader product V-PASS is claimed.
- Phase 6 route A video loop is simulator evidence only; true-device GPU/FPS remains deferred.

## P2 Inner/Outer Ring Validation Update

Captured at: 2026-06-26 12:41:20 CST

Status: P2 proof gates refreshed. This update strengthens `8.C1` and the Phase 3/4 receipts, but it does not close `8.C2`, SD7, SD8, SD12, true-device, or product V-PASS.

| Gate | Proof class | Result |
|---|---|---|
| iOS simulator `build_run_sim` with `-mockTheme ivory -mockSnapshot cooling` | runtime/simulator | PASS; app launched on iPhone 17 Pro Max simulator |
| Phase 3 AC expanded stepper tap | runtime/simulator | PASS; UI tree changed `空调 26℃` to `空调 27℃`, screenshot `shots/phase3-touch-after-increment-v2.jpg` |
| Phase 4 settings route probe | runtime/simulator | PARTIAL/BLOCKER; settings sheet opened, but tapping `演绎控制台` returned to main stage instead of presenting `DemoControlPanel`, screenshot `shots/phase4-settings-control-route-failed-v1.jpg` |
| `swift test` | unit | PASS: 245 tests executed, 3 skipped, 0 failures |
| `xcodebuild -project MAformac.xcodeproj -scheme MAformacMac -destination 'platform=macOS' -derivedDataPath .build/dd-mac build` | local | PASS: `** BUILD SUCCEEDED **` |
| `make verify-all` | local + unit | PASS exit 0; includes source snapshot, generation, refs, cross-section, surface consistency, and Swift tests |

Inner/outer split held: simulator screenshot/UI-tree proof was collected serially before broad outer gates, and no status-bar override or screenshot capture was run in parallel.

## P0 Commit Anchor: phase2-6 shared scaffold

Commit subject: `feat(uiue): anchor phase2-6 shared presentation scaffold`

This commit anchors the shared SwiftUI presentation scaffold that cannot be safely split by phase without breaking compile-time references: `ContentView` stage shell, theme tokens, debug launch arguments, control-panel sheet route, ambient burst hook, context capsule route, Vortex package wiring, portrait orientation, presentation catalog defaults, and the dependent unit-test expectations.

It serves Phase 2 through Phase 6 because `ContentView.swift`, `App/MAformacApp.swift`, `App/DesignTokens.swift`, and `MAformac.xcodeproj/project.pbxproj` currently carry cross-phase seams. Hunk-splitting them into pure phase commits would strand references to `DemoControlPanel`, `AmbientEdgeBurst`, `ContextCapsuleView`, `ValueControlActions`, `ThermalRangeBar`, and `DemoVehicleStateStore.replaceCells`.

Not anchored here: generated screenshots, generated zone-compare directories, Phase-specific receipts, capsule media assets, and coverage/task completion claims. Those remain separate so Phase 2-6 can be reconciled against their own evidence.

Proof boundary: isolated UIUE worktree local scaffold anchor, not mainline proof, not true-device proof, not visual V-PASS.

Next: create the Phase 2 commit for `phase2_zone_compare.py` plus Phase 2 receipt/evidence, then Phase 3-6 commits for their dedicated code/proof assets where still unstaged.

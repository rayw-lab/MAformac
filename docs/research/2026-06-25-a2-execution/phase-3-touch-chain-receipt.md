# Phase 3 Touch Chain Receipt

Date: 2026-06-26
Status: PARTIAL / local-pass
Proof class: local + unit + simulator runtime

## Scope

Implemented Phase 3.1a-d mock-frontstage touch chain:

- `ValueControlView` exposes `ValueControlActions` for increment, decrement, toggle, and badge cycling.
- `ExpandedFamilyCard` maps expanded-row controls to mock transitions through `ValueRangeMapper`.
- `ContentView` applies those transitions through `DemoVehicleStateStore`, refreshes `PresentationSnapshot`, and preserves current dialogue/orb/voice context.
- `DemoVehicleStateStore.applyMockTransition` no longer collapses every non-`on` value to `.normal`; changed scalar values now become non-normal `.changing`.

No true NLU, ASR, TTS, LoRA, live API, or real vehicle backend was connected. This remains all mock frontstage per SD7 amendment and ui-presentation mock-frontstage requirements.

## Code Evidence

- `App/ValueControlView.swift:14` adds `ValueControlActions`.
- `App/ValueControlView.swift:44` and `App/ValueControlView.swift:62` render dial/percent with decrement/increment affordances.
- `App/ValueControlView.swift:82` renders stepper bars with minus/plus hit targets.
- `App/ValueControlView.swift:110` and `App/ValueControlView.swift:127` make toggle/badge controls actionable.
- `App/ExpandedFamilyCard.swift:88` builds row actions.
- `App/ExpandedFamilyCard.swift:97` uses `ValueRangeMapper.steppedValue`.
- `App/ExpandedFamilyCard.swift:110` toggles on/off values.
- `App/ExpandedFamilyCard.swift:117` cycles badge values.
- `App/ContentView.swift:162` passes `onMockTransition` into `ExpandedFamilyCard`.
- `App/ContentView.swift:185` seeds the store from current snapshot, applies the mock transition, and rebuilds snapshot/readbacks.
- `Core/Presentation/ValueRangeMapper.swift:39` clamps next stepped value to contract execution range.
- `Core/State/DemoVehicleStateStore.swift:123` adds `replaceCells`.
- `Core/State/DemoVehicleStateStore.swift:158` returns `.changing` for changed scalar values instead of binary `.normal`.

## Test Evidence

- `Tests/MAformacCoreTests/ValueRangeMapperTests.swift:41` covers clamped stepped values.
- `Tests/MAformacCoreTests/ValueRangeMapperTests.swift:48` covers toggle and badge cycling.
- `Tests/MAformacCoreTests/VehicleStateStoreContractTests.swift:55` covers scalar value changes producing non-normal visual state.
- `Tests/MAformacCoreTests/VehicleStateStoreContractTests.swift:67` covers toggle off returning `.normal`.
- `Tests/MAformacCoreTests/VehicleStateStoreContractTests.swift:79` covers seeding mock presentation store via `replaceCells`.

## Runtime Evidence

- Main stage still launches on iPhone 17 Pro Max simulator:
  `docs/research/2026-06-25-a2-execution/shots/phase3-touch-before.png`
- Expanded controls render without visible overflow on iPhone 17 Pro Max simulator:
  `docs/research/2026-06-25-a2-execution/shots/phase3-expanded-controls-v1.png`

`computer-use` could not attach to Simulator (`cgWindowNotFound`), and `System Events` did not expose a Simulator front window. Therefore this receipt does not claim physical tap acceptance.

## Validation

- `bash Tools/checks/check-no-binary-visualstate.sh` PASS
- `bash Tools/checks/check-contentview-uses-display-catalog.sh` PASS
- `bash Tools/checks/check-platform-vs-version-guard.sh` PASS
- `swift test` PASS: 242 tests, 3 skipped, 0 failures
- `xcodebuild -project MAformac.xcodeproj -scheme MAformacIOS -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -derivedDataPath .build/dd-ios build` PASS
- `xcodebuild -project MAformac.xcodeproj -scheme MAformacMac -destination 'platform=macOS' -derivedDataPath .build/dd-mac build` PASS

## Coverage Index

`docs/grill-checklist/uiue-a2-grill-coverage-index.md` was not checked off for SD6/SD7 in this receipt. Rationale: 3.1a-d has local/unit/simulator proof, but no recorded physical UI tap chain or product-level visual acceptance. Keep V-PASS withheld.

## Residual Risks

- Badge option lists are currently local to `ExpandedFamilyCard` row logic, not derived from a shared allowed-values catalog.
- Initial runtime proof only showed expanded control rendering; the P2 update below adds simulator tap mutation proof for the AC stepper path, but not drag or voice-reasoning proof.
- Phase 3 is still mock-frontstage only; true voice/NLU/backend wiring remains explicitly out of scope.

## P2 Inner-Loop Touch Evidence Update

Date: 2026-06-26

Status: PARTIAL improved from local-pass to simulator touch-stepper-pass for the expanded AC stepper path.

Commands/actions:

- `build_run_sim` with `-mockTheme ivory -mockSnapshot cooling`: PASS.
- `snapshot_ui`: main stage exposed `e15|tap|button|空调 26℃ 执行中|26℃|vehicle-card-family.ac`.
- `tap(e15)`: PASS; refreshed snapshot exposed expanded AC controls including `e69` reduce, `e71` increase, and `e78` option cycle.
- `tap(e71)`: PASS; refreshed snapshot exposed `e15|tap|button|空调 27℃ 执行中|27℃|vehicle-card-family.ac` and text `27`, proving the expanded stepper path mutates mock state and refreshes the family card.
- Screenshot: `docs/research/2026-06-25-a2-execution/shots/phase3-touch-after-increment-v2.jpg`.

What this closes:

- `8.D1`: `ValueControlActions` stepper callback is exercised through a real simulator tap.
- `8.D2`: expanded card callback reaches `ContentView` mock transition and refreshes snapshot/card numeric text.
- `8.D3`: value mutation remains non-normal (`执行中`) after changing `26℃ -> 27℃`.
- SD6: tap card expands composite controls and numeric stepper works in simulator runtime.

What this still does not close:

- `8.D4`: voice-reasoning mock presets and read-current-state voice flow are still not proven by runtime evidence.
- SD7: full touch-adjust → mock store → voice reasoning + silent/no-TTS behavior remains partial because the drag scrubber path and voice mock path are not both proven.
- Drag automation: still `operator-pass pending`; no idb/manual/true-device drag evidence exists.

## P0 Commit Anchor: Phase 3 touch-chain proof slice

Commit subject: `docs(uiue): anchor phase3 touch-chain proof slice`

This commit anchors the Phase 3 receipt and the two simulator screenshots cited above. The corresponding implementation files (`ValueControlView.swift`, `ExpandedFamilyCard.swift`, `ValueRangeMapper.swift`, `DemoVehicleStateStore.swift`, `ContentView.swift`, and related tests) are already anchored in the required shared scaffold commit `98f7c57` because hunk-splitting those references would break the compiled presentation shell.

Not anchored here: a new physical tap/drag proof, SD6/SD7 coverage burn-down, or product V-PASS. The drag/tap automation blocker remains downgraded to `operator-pass pending` until manual, idb, or true-device evidence is recorded.

Claim boundary: `PARTIAL / local-pass` in the isolated UIUE worktree, not mainline proof and not live/backend proof.

Next: close the missing touch proof gate with serial simulator/manual evidence before checking SD6/SD7 in coverage.

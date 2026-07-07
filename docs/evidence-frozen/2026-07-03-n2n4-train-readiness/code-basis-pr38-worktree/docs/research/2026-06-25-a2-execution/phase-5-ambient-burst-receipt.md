# Phase 5 Ambient Burst Receipt

Date: 2026-06-26
Status: DONE / local+simulator-pass
Proof class: local + unit + simulator mock runtime

## Scope

Implemented the Phase 5 ambient light burst surface:

- `AmbientEdgeBurst` full-viewport non-interactive overlay with timed edge glow and Canvas particles.
- Trigger policy fires only on normalized `ambient.color` deltas, not brightness or same-color aliases.
- 5s duration is tokenized through `DesignTokens.ambientBurstDuration`.
- DEBUG-only simulator harness allows deterministic screenshot/recording without connecting real NLU, ASR, LoRA, live API, or vehicle backend.

## Authority

- Plan Phase 5 requires edge mixed glow, Vortex-style Canvas particles, 5s fade, `allowsHitTesting(false)`, dark stronger/ivory weaker, and anchor-06 comparison.
- Spec `ui-presentation` requires ambient edge burst to be presentation-only, triggered only by `ambient.color` delta, non-blocking, and no Inferno/layerEffect shader path.
- Grill SD4 / U4 / U30 require ambient light as a visual high point while preserving mic hit testing and avoiding heavy shader misuse.
- Reference teardown used:
  - `Tools/skills/ios-simulator-skill/SKILL.md` for simulator launch/screenshot/recording.
  - `Tools/skills/axiom/skills/axiom-swiftui/SKILL.md` for SwiftUI layout/animation discipline.
  - `raw/05-Projects/MAformac/ref-repos/Vortex` for TimelineView + Canvas particle structure.
  - `raw/05-Projects/MAformac/ref-repos/open-swiftui-animations/Gists_To_Try/GeminiFireworksAnimation.swift` for lightweight burst timing pattern.
  - `raw/05-Projects/MAformac/ref-repos/SwiftUIShaders` was inspected but not used because U30 forbids the heavy shader path here.

## Code Evidence

- `App/AmbientEdgeBurst.swift:15` defines the overlay component.
- `App/AmbientEdgeBurst.swift:217` defines the timed edge glow.
- `App/AmbientEdgeBurst.swift:324` defines the Canvas particle layer.
- `Core/Presentation/AmbientBurstColorMapper.swift:47` gates triggering to `ambient.color` normalized deltas.
- `App/ContentView.swift:220` triggers burst from touch/mock transitions after readback refresh.
- `App/ContentView.swift:326` triggers burst from cabin macro ambient color changes.
- `App/ContentView.swift:383` supports DEBUG initial burst for repeatable runtime proof.
- `App/MAformacApp.swift:89` defines the DEBUG ambient-burst harness.
- `Tests/MAformacCoreTests/AmbientBurstColorMapperTests.swift:29` covers trigger-on-delta and no false trigger for aliases/non-color keys.

## Runtime Evidence

- Final simulator screenshot:
  `docs/research/2026-06-25-a2-execution/shots/phase5-ambient-burst-ivory-v7-090s.png`
- Final 5s simulator recording:
  `docs/research/2026-06-25-a2-execution/shots/phase5-ambient-burst-ivory-v7-5s.mov`
- Iteration evidence kept:
  - v4: first visible edge burst, but bottom safe-area/dock coverage was weak.
  - v5: bottom coverage fixed, but center was overexposed.
  - v6: readability recovered, but pixel metrics showed purple under-indexed vs anchor-06.
  - v7: purple-dominant gradient reorder reached/exceeded anchor-06 edge-zone purple ratio while keeping content readable.

## Anchor Compare

Four edge zones were measured against `docs/design/anchors/anchor-06-ambient-burst.png`.

| Image | Top violet | Right violet | Bottom violet | Left violet | Whitewash risk |
|---|---:|---:|---:|---:|---|
| anchor-06 | 0.483 | 0.598 | 0.386 | 0.555 | 0.068-0.169 |
| phase5 v7 0.9s | 0.595 | 0.915 | 0.604 | 0.938 | 0.000-0.131 |

Interpretation: v7 exceeds anchor-06 purple edge energy in all four zones. It is brighter than the anchor, but remains readable in the center content and mic dock.

## Validation

- `swift test` PASS: 245 tests, 3 skipped, 0 failures.
- `xcodebuild -project MAformac.xcodeproj -scheme MAformacIOS -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -derivedDataPath .build/dd-ios build` PASS.
- `xcodebuild -project MAformac.xcodeproj -scheme MAformacMac -destination 'platform=macOS' -derivedDataPath .build/dd-mac build` PASS.
- Mechanical scan `rg -n "visualState == \\.normal|== \\.normal \\?|\\? .*: .*appearance\\.border|NavigationSplitView|SplitView|layerEffect|Inferno" App Core Tests` found only a normal test assertion; no implementation hit for forbidden binary state compression, SplitView, layerEffect, or Inferno.

## Coverage Index

Checked off:

- OpenSpec `8.F1`.
- Grill coverage SD4.

Not checked off:

- SD16 orb four-state visual polish remains Phase 5+ follow-up.
- Physical iPhone/mobile acceptance is not claimed; proof is simulator mock runtime.

## Residual Risks

- The final runtime evidence uses a DEBUG harness to force the visual burst. The production/mock trigger chain is covered by unit tests and ContentView code paths, but not by a recorded physical tap on an expanded ambient card.
- The v7 visual intentionally exceeds anchor-06 saturation; if later Phase 7 readability review finds projection glare, tune edge opacity down without changing trigger semantics.

## P0 Commit Anchor: Phase 5 ambient-burst proof slice

Commit subject: `docs(uiue): anchor phase5 ambient-burst proof slice`

This commit anchors the Phase 5 DONE/local+simulator-pass receipt and the final v7 screenshot/5s recording cited above. The implementation files (`AmbientEdgeBurst.swift`, `AmbientBurstColorMapper.swift`, `DesignTokens.swift`, `ContentView.swift`, `MAformacApp.swift`, and related tests) are already anchored in shared scaffold commit `98f7c57` because the overlay, trigger policy, tokens, and DEBUG harness are compile-linked with the main presentation shell.

Not anchored here: historical v1-v6 screenshots/recordings, app-state capture directory, physical tap proof from an expanded ambient card, true-device GPU/FPS proof, or live/backend wiring.

Claim boundary: DONE for the A-2 simulator/mock Phase 5 scope only, in the isolated UIUE worktree. It is not mainline proof, not true-device proof, and not product V-PASS.

Next: during P1/P2, map only the currently proven SD4/OpenSpec 8.F1 rows; do not auto-check SD16 or physical acceptance rows.

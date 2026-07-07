# Phase 6 Context Capsule Receipt

Date: 2026-06-26

Status: DONE for A-2 simulator scope

Proof class: local + mock + iOS Simulator runtime

## Scope

- Implemented the C-lite route for `ContextCapsule`: native glass shell, static diorama base asset, context-driven SwiftUI/Vortex overlays, and low-weight continuous animation.
- Implemented an A-route video-loop spike behind a DEBUG route flag, using `AVQueuePlayer + AVPlayerLooper`.
- Wired capsule rendering to `snapshot.context` and DEBUG launch overrides for simulator visual evidence.
- Added Vortex to both app targets through the Xcode project package graph and pinned the resolved version.
- Captured simulator screenshots and manual capsule ROI comparisons against the diorama anchor.

Non-goals for this receipt:

- No true-device GPU/FPS validation was run.
- No live ASR/NLU/TTS/backend wiring; this remains mock-frontstage per the A-2 scope.

## Authority Read

- Plan Phase 6 quick reference: `docs/superpowers/plans/2026-06-25-a2-step2-uipresentation.md:95`
- Plan Task 6.1/6.2: `docs/superpowers/plans/2026-06-25-a2-step2-uipresentation.md:335`
- SD24 context capsule: `docs/uiue-storyboard-grill-decisions.md:519`
- SD25 diorama final direction: `docs/uiue-storyboard-grill-decisions.md:553`
- OpenSpec 8.B: `openspec/changes/ui-presentation/tasks.md:102`

## Implemented

- `App/ContextCapsule.swift`
  - `ContextCapsuleView(theme:context:)` consumes `DemoContext`.
  - Supports `ContextCapsuleRoute.cLite` and `ContextCapsuleRoute.videoLoop`.
  - Uses `Image("ContextCapsule")` as the base diorama layer.
  - Adds rain, smoke, road motion, night stars, headlight cone, scene tint, and glass highlight.
  - Uses `TimelineView(.animation)` for always-alive motion and `accessibilityReduceMotion` fallbacks.
  - Uses Vortex `.rain` and `.smoke` systems without Inferno/layerEffect.
- `App/ContextCapsuleVideoLoop.swift`
  - Provides a control-free `AVPlayerLayer` bridge for iOS/macOS.
  - Loops `App/ContextCapsuleLoop.mp4` with `AVPlayerLooper`.
- `App/ContentView.swift`
  - Replaces the old inline capsule with the standalone `ContextCapsuleView`.
  - Keeps refresh/settings outside the capsule.
  - Tunes iPhone top placement to avoid Dynamic Island overlap while staying close to the anchor top band.
- `App/MAformacApp.swift`
  - Adds DEBUG context injection via `CONTEXT_SPEED`, `CONTEXT_GEAR`, `CONTEXT_WEATHER`, `CONTEXT_TIME_PERIOD` and matching launch args.
  - Adds `CONTEXT_CAPSULE_ROUTE` / `-contextCapsuleRoute` for route A vs C-lite runtime comparison.
- `App/Assets.xcassets/ContextCapsule.imageset/context-capsule.png`
  - C-lite diorama base asset.
- `App/ContextCapsuleLoop.mp4`
  - A-route H.264 loop spike asset generated from the current diorama base still.
- `MAformac.xcodeproj/project.pbxproj`
  - Adds Vortex package/product dependency to `MAformacIOS` and `MAformacMac`.
- `MAformac.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`
  - Pins `https://github.com/twostraws/Vortex` to version `1.0.4`, revision `9d9d9016ceace579455f01f8e0bd59facae7d252`.

## Visual Evidence

Screenshots:

- `docs/research/2026-06-25-a2-execution/shots/phase6-context-idle-day-v3.png`
- `docs/research/2026-06-25-a2-execution/shots/phase6-context-rainy-night-v3.png`
- `docs/research/2026-06-25-a2-execution/shots/phase6-context-city-driving-v3.png`

Manual capsule ROI comparison:

- `docs/research/2026-06-25-a2-execution/zone-compare-phase6-capsule/phase6-capsule-manual-crop-strip.png`
- `docs/research/2026-06-25-a2-execution/zone-compare-phase6-capsule/phase6-capsule-manual-metrics.json`
- `docs/research/2026-06-25-a2-execution/phase-6-capsule-route-spike-result.md`
- `docs/research/2026-06-25-a2-execution/zone-compare-phase6-route-spike/route-spike-capsule-strip.png`
- `docs/research/2026-06-25-a2-execution/shots/phase6-route-a-video-loop-v1.mov`

Key manual ROI metrics:

- Anchor in-situ capsule bbox rel: `[0.1148, 0.0610, 0.8055, 0.1884]`
- Implementation capsule bbox rel: `[0.0795, 0.0614, 0.7894, 0.1796]`
- Idle vs anchor RMSE: `37.55`
- Idle vs rainy-night RMSE: `82.45`
- Idle vs city-driving RMSE: `22.70`

Interpretation:

- The implemented capsule top Y and height are close to the in-situ anchor band.
- Rain/night produces a large visual state delta.
- Driving remains intentionally lower-weight than rain/night, consistent with SD24's lowest ambient priority.

## Validation

- `swift test`
  - Result: 245 tests, 3 skipped, 0 failures.
- `xcodebuild -project MAformac.xcodeproj -scheme MAformacIOS -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -derivedDataPath .build/dd-ios build`
  - Result: `** BUILD SUCCEEDED **`
  - Log confirms Vortex resolved at `1.0.4`.
- `xcodebuild -project MAformac.xcodeproj -scheme MAformacMac -destination 'platform=macOS' -derivedDataPath .build/dd-mac build`
  - Result: `** BUILD SUCCEEDED **`
  - Log confirms Vortex resolved at `1.0.4`.
- `rg -n "visualState == \.normal|== \.normal \?|\? .*: .*appearance\.border|NavigationSplitView|SplitView|layerEffect|Inferno" App Core Tests`
  - Result: only one legitimate test assertion in `Tests/MAformacCoreTests/FamilyDisplaysTests.swift`.
  - No App/Core binary visualState, SplitView, layerEffect, or Inferno match.
- `git diff --check`
  - Result: pass.

## Residual Risk

- True-device GPU/FPS remains deferred; current proof is simulator/runtime only.
- Base diorama asset includes baked visual details, so not every smoke-like pixel is procedural.
- A-route uses a generated spike loop from the same still, not final photoreal route-A art.
- Glass specular behavior may differ on real device, consistent with the plan's simulator caveat.

## P0 Commit Anchor: Phase 6 capsule proof slice

Commit subject: `feat(uiue): anchor phase6 context-capsule proof slice`

This commit anchors the Phase 6 simulator-scope capsule assets and proof: `ContextCapsule` image asset, `ContextCapsuleLoop.mp4`, SwiftPM `Package.resolved`, Phase 6 receipt, route-spike result, v3 simulator screenshots, route A/C screenshots and recording, and the selected ROI strip/metrics artifacts cited above. The Swift implementation files are already anchored in shared scaffold commit `98f7c57` because `ContextCapsuleView`, `ContextCapsuleVideoLoopView`, `ContentView`, `MAformacApp`, and pbxproj Vortex wiring are compile-linked.

Not anchored here: all intermediate crop images, v1/v2 screenshots, generated route-spike frame crops, true-device GPU/FPS proof, or final photoreal route-A art.

Claim boundary: DONE for the A-2 simulator capsule scope in the isolated UIUE worktree. It is not mainline proof, not true-device proof, not visual V-PASS, and not live/backend proof.

Next: in P1/P2, only reconcile simulator-scope Phase 6 tasks/coverage; keep true-device GPU/FPS and final route-A art deferred.

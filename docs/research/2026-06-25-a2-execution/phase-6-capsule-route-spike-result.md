# Phase 6 Capsule Route Spike Result

Date: 2026-06-26

Status: DONE for A-2 simulator route spike

Proof class: local + iOS Simulator runtime

## Question

Compare SD25 route A video loop against C-lite in the same top context capsule zone, without claiming true-device GPU/FPS acceptance.

## Inputs

- C-lite route: `ContextCapsuleView(route: .cLite)` with native glass, base diorama still, Vortex particles, SwiftUI Canvas overlays.
- A route: `ContextCapsuleView(route: .videoLoop)` with `AVQueuePlayer + AVPlayerLooper` playing `App/ContextCapsuleLoop.mp4` under the same capsule shell and overlays.
- Anchor reference: `docs/design/anchors/anchor-00-diorama-5-fullscreen-insitu.png`

## Implementation

- Added debug route flag:
  - `-contextCapsuleRoute cLite`
  - `-contextCapsuleRoute videoLoop`
  - `CONTEXT_CAPSULE_ROUTE=cLite|videoLoop`
- Added `ContextCapsuleRoute`.
- Added `ContextCapsuleVideoLoopView`, backed by an `AVPlayerLayer` wrapper on iOS/macOS.
- Generated `App/ContextCapsuleLoop.mp4` from the current diorama base still:
  - H.264, 650 x 210, 2 seconds, no audio, about 45 KB.
  - Generated with `ffmpeg` using a subtle loop pan.

## Runtime Evidence

Screenshots:

- C-lite: `docs/research/2026-06-25-a2-execution/shots/phase6-route-c-lite-v1.png`
- A-video: `docs/research/2026-06-25-a2-execution/shots/phase6-route-a-video-loop-v1.png`

Recording:

- A-video runtime recording: `docs/research/2026-06-25-a2-execution/shots/phase6-route-a-video-loop-v1.mov`
- `ffprobe` reports H.264, 1320 x 2868, duration `2.905000`, avg frame rate about 48.88 fps.

ROI artifacts:

- `docs/research/2026-06-25-a2-execution/zone-compare-phase6-route-spike/route-spike-capsule-strip.png`
- `docs/research/2026-06-25-a2-execution/zone-compare-phase6-route-spike/a-video-frame-motion-strip.png`

## Metrics

Capsule ROI RMSE:

- C-lite vs anchor: `9366.67 (0.142926)`
- A-video vs anchor: `10012.5 (0.152781)`
- A-video vs C-lite: `6250.5 (0.0953766)`
- A-video frame 0.35s vs 1.55s: `6220.85 (0.0949241)`

Interpretation:

- A-video is a real AVPlayer loop in simulator runtime, not a static fallback.
- C-lite is currently closer to the anchor by this ROI metric.
- A-video has lower code/runtime overlay complexity but is only as good as the pre-rendered source video.
- C-lite remains the better A-2 default because it preserves context compositing and reacts to weather/night/driving without needing one video per scene.

## Decision

- Keep C-lite as the default Phase 6 product route.
- Keep A-video route as a debug/runtime spike path for future higher-quality pre-rendered loops.
- Do not claim true-device GPU/FPS acceptance; that remains a later proof class.

## Validation

- iOS simulator build copied `ContextCapsuleLoop.mp4` into `MAformacIOS.app`.
- iOS simulator launched both:
  - `-contextCapsuleRoute cLite`
  - `-contextCapsuleRoute videoLoop`
- Screenshots and recording were captured from iPhone 17 Pro Max simulator.

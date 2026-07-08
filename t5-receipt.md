# T5 Runtime Presentation Receipt

status: DONE_LOCAL_VERIFIED
artifact_kind: d1a_t5_runtime_presentation_receipt
worktree: `/Users/wanglei/workspace/MAformac-d1a-t5`
branch: `uiue/d1a-t5-runtime-20260708`
base_head: `c4dfb2476159da15ac215d1e447898610f211524`
captured_at_local: `2026-07-08T19:48:56+0800`
proof_class: `local/unit`
non_claims: not visual approval; not operator-pass; not true-device; not C6 acceptance; no app foreground launch

## Scope Delivered

- D0G-041: six runtime/TTS error classes mapped to visual receipt rows:
  - timeout / empty / malformed -> `.unknown`, retryable crash receipt
  - unknown tool -> `.blocked_hard`, unsupported locked receipt
  - safety -> `.unsafe`, related-card-only scope
  - TTS fail -> `.blocked_with_alternative`, degraded non-crash receipt
- D0G-039: presentation orchestrator with first-frame idle panorama, `DEMO_FORCE` marker for force-state, and runtime event precedence over force-state.
- D0G-025: card-change scheduler merging all simultaneous changes to the latest readback id, staggering non-critical cards from 120-220ms, and applying unsafe/crash immediately.
- D0G-038: readback/TTS coordinator uses shared text id and cancels prior TTS when a newer readback arrives.
- D0G-037: TTS preflight records synthesizer availability, preferred/fallback voice route, output-muted warning, and missing premium voice as warning not failure.

## Files

- `Core/Presentation/T5RuntimePresentation.swift`
- `Tests/MAformacCoreTests/T5RuntimePresentationTests.swift`

## TDD Evidence

- RED: `swift test --filter T5RuntimePresentationTests` failed before implementation with missing T5 API/type errors (`/tmp/t5-red.log`, rc=1).
- GREEN target: `swift test --filter T5RuntimePresentationTests` passed 6/6 (`/tmp/t5-green2.log`, rc=0).

## Validation

- `swift build`: rc0; completed before 24:00 resource window. SwiftPM emitted existing unhandled-file warnings only.
- `swift test`: rc0; 611 tests, 3 skipped, 0 failures; completed at 2026-07-08 19:47:42 +0800.
- `xcodebuild -project MAformac.xcodeproj -scheme MAformacMac -configuration Debug -destination 'platform=macOS' -derivedDataPath /tmp/maformac-d1a-t5-derived build`: rc0; build only, no app launch.
- GitNexus staged detect: `changed_files=2`, `risk_level=low`, no indexed existing symbol hits because both files are new.

## Commit

- Commit hash source: run `git -C /Users/wanglei/workspace/MAformac-d1a-t5 rev-parse HEAD`; this receipt is included in that HEAD commit.

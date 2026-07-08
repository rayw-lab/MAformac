# T5 Runtime Presentation Receipt

status: DONE_LOCAL_VERIFIED
artifact_kind: d1a_t5_runtime_presentation_receipt
worktree: `/Users/wanglei/workspace/MAformac-d1a-t5`
branch: `uiue/d1a-t5-runtime-20260708`
base_head: `c4dfb2476159da15ac215d1e447898610f211524`
captured_at_local: `2026-07-08T20:05:02+0800`
proof_class: `local/unit`
non_claims: not visual approval; not operator-pass; not true-device; not C6 acceptance; no app foreground launch

## Scope Delivered

- D0G-041: six runtime/TTS error classes mapped to visual receipt rows:
  - timeout / empty / malformed -> `.unknown`, retryable crash receipt
  - unknown tool -> `.blocked_hard`, unsupported locked receipt
  - safety -> `.unsafe`, related-card-only scope
  - TTS fail -> `.blocked_with_alternative`, degraded non-crash receipt
- D0G-039: presentation orchestrator with first-frame idle panorama, `DEMO_FORCE` marker for force-state, runtime event precedence over force-state, and explicit `T5PresentationResolving` protocol seam for later App/runtime mount.
- D0G-025: card-change scheduler merging all simultaneous changes to the latest readback id with deterministic tie-break (`revision`, then `readbackEpoch`, then input order), staggering non-critical cards from 120-220ms, and applying unsafe/crash immediately.
- D0G-038: readback/TTS coordinator uses shared text id, cancels prior TTS when a newer readback arrives, and exposes a same-id pending badge while TTS/readback are briefly unsynchronized.
- D0G-037: TTS preflight records synthesizer availability, preferred/fallback voice route, output-muted warning, and missing premium voice as warning not failure.

## Files

- `Core/Presentation/T5RuntimePresentation.swift`
- `Tests/MAformacCoreTests/T5RuntimePresentationTests.swift`

## TDD Evidence

- RED: `swift test --filter T5RuntimePresentationTests` failed before implementation with missing T5 API/type errors (`/tmp/t5-red.log`, rc=1).
- GREEN target: `swift test --filter T5RuntimePresentationTests` passed 6/6 (`/tmp/t5-green2.log`, rc=0).
- T5F RED: `swift test --filter T5RuntimePresentationTests` failed with missing pending badge / readback epoch / resolver protocol APIs (`/tmp/t5f-red.log`, rc=1).
- T5F GREEN target: `swift test --filter T5RuntimePresentationTests` passed 7/7 (`/tmp/t5f-target.log`, rc=0).

## Validation

- `swift build`: rc0; completed before 24:00 resource window. SwiftPM emitted existing unhandled-file warnings only.
- `swift test`: rc0; 611 tests, 3 skipped, 0 failures; completed at 2026-07-08 19:47:42 +0800.
- `xcodebuild -project MAformac.xcodeproj -scheme MAformacMac -configuration Debug -destination 'platform=macOS' -derivedDataPath /tmp/maformac-d1a-t5-derived build`: rc0; build only, no app launch.
- GitNexus T5F pre-edit check: `detect_changes(scope=compare, base_ref=3212474301d6fb0ee32578fe7e0f27b59953fdc2, worktree=/Users/wanglei/workspace/MAformac-d1a-t5)` returned `changed_count=0`, `risk_level=none`; previous staged LOW claim is not reused as hard evidence because the adversarial rerun showed GitNexus did not map this worktree diff reliably.
- T5F `swift build`: rc0 (`/tmp/t5f-swift-build.log`); existing unhandled-file warnings only.
- T5F `swift test`: rc0; 612 tests, 3 skipped, 0 failures (`/tmp/t5f-swift-test.log`).
- T5F `xcodebuild -project MAformac.xcodeproj -scheme MAformacMac -configuration Debug -destination 'platform=macOS' -derivedDataPath /tmp/maformac-d1a-t5f-derived build`: rc0; build only, no app launch (`/tmp/t5f-xcodebuild.log`).
- T5F GitNexus post-change: `detect_changes(scope=all, worktree=/Users/wanglei/workspace/MAformac-d1a-t5)` returned `changed_files=3`, `risk_level=low`, no indexed existing symbol/process hits.

## T5F P1 Closure

- P1-1 pending badge: `T5ReadbackSpeechCoordinator.handle` now returns `T5ReadbackSpeechUpdate` with `T5ReadbackPendingBadge(readbackID: same id)`; `markSpeechSynchronized(textID:)` clears it only for active id.
- P1-2 latest readback tie/race: `T5CardChange` now carries `readbackEpoch`; latest readback selection is deterministic by `revision`, `readbackEpoch`, then input order.
- P1-3 resolver mount seam: `T5PresentationResolving` names the App/runtime boundary without wiring T2/App.
- P1-4 GitNexus claim: receipt downgraded to fresh tool output + limitation note, not a hard LOW claim.

## Commit

- Commit hash source: run `git -C /Users/wanglei/workspace/MAformac-d1a-t5 rev-parse HEAD`; this receipt is included in that HEAD commit.

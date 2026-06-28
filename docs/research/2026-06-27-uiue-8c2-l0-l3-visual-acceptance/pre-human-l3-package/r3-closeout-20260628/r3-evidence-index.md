---
status: r3_evidence_index
artifact_kind: evidence_index_not_ssot
date: 2026-06-28
proof_classes:
  - simulator_l0_runtime_truth
  - simulator_debug_override
  - simulator_ui_test
  - local_pixel_metric
non_claims:
  - no V-PASS
  - no mobile
  - no true_device
  - no runtime-ready
  - no voice-ready
  - no A-2 complete
---

# UIUE 8.C2 R3 Evidence Index

## L3 Verdict

磊哥 human review truth: `PASS_WITH_NOTES` / human review passed with notes.

Notes retained as residual/non-claims, not R3 blockers: R2b white-edge threshold not formalized, capsule final-art remains post-R3 polish, simulator proof is not mobile/true_device, and this package does not claim runtime/voice/model readiness.

## Reduce Motion

`simctl ui` on this runtime does not expose a Reduce Motion toggle; it exposes only `appearance`, `increase_contrast`, and `content_size`. R3 therefore uses the DEBUG launch override `-forceReduceMotion` to force the presentation code path. Proof class is `simulator_debug_override`, not true-device system setting proof.

| Evidence | Path | sha256 / result |
|---|---|---|
| Screenshot | `screenshots/reduce-motion/reduce_motion_think_ivory.png` | `3c6157419e6b684049fdb516638d1edf018e38c442d74da0d10714433304e8cc` |
| Launch log | `Reports/uiue-8c2-r3-closeout-20260628/logs/reduce-motion-reduce_motion_think_ivory.launch.log` | app pid `70176` |
| Screenshot log | `Reports/uiue-8c2-r3-closeout-20260628/logs/reduce-motion-reduce_motion_think_ivory.screenshot.log` | simctl screenshot command output |
| Unit policy | `Tests/MAformacCoreTests/PresentationReducedMotionPolicyTests.swift` | `swift test --filter PresentationReducedMotionPolicyTests` |

## VPA / Orb Four-State Proof

| State | Launch args | Screenshot | sha256 | UI/test proof |
|---|---|---|---|---|
| idle | `-mockSnapshot coldStart -mockTheme ivory` | `screenshots/orb-four-state/orb_idle_ivory.png` | `eda86d4e54d6406ba5c4b7f197ff2acd01f9c12636e849178678fcc4a051296c` | targeted UI test checks `随时待命` |
| listen | `-mockSnapshot listening -mockTheme ivory` | `screenshots/orb-four-state/orb_listen_ivory.png` | `c2e75d76812d192ccf77701159d2d41b4ca794726317f0d8e4df45ddf5bcaaa6` | targeted UI test checks `我在听...` |
| think | `-mockSnapshot safetyRefusal -mockTheme ivory` | `screenshots/orb-four-state/orb_think_ivory.png` | `0fc081221337709404b817c8f847a9edebe9950655dc2e8e48ab87c9cb88778b` | targeted UI test checks `让我确认下...` |
| speak | `-mockSnapshot cooling -mockTheme ivory` | `screenshots/orb-four-state/orb_speak_ivory.png` | `6c334f268e71a1e546edb904cb9eaa826aab269e943992ba44c8fd7330f2ac33` | targeted UI test checks `正在回应` and orb containment |

Validation log: `/Users/wanglei/Library/Developer/XcodeBuildMCP/workspaces/MAformac-71f6fc684d4b/logs/test_sim_2026-06-28T00-47-46-596Z_pid65027_2cf02463.log`.

Boundary: this proves presentation/mock snapshot state binding only:

```text
SnapshotPreset -> PresentationSnapshot.orbState -> DemoOrbView caption/visual
```

It does not prove runtime-driven state binding from ASR, LLM, intent routing, safety checks, clarification, or tool execution. Complex reasoning should drive `think` only after the runtime presentation bridge maps backend/router states to `PresentationOrbState` and that path is verified separately.

## Recapture Sync

Use `../recaptures/20260628-l3-temp-pass-sync-r2/l0-l2-evidence-index.json` as the latest L0/L2 recapture source. `../recaptures/20260628-l3-temp-pass-sync/` is superseded for review because it reused a running app pid across multiple launch-argument cases.

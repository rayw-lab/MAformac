---
status: l0_l2_index_with_20260628_recapture_sync
artifact_kind: evidence_index_not_ssot
date: 2026-06-27
non_claims:
  - no final L3 PASS
  - L3 temporary pass only
  - no V-PASS
  - no 8.C2 closure
---

# L0-L2 Evidence Index

## 2026-06-28 Recapture Sync After L3 Temporary Pass

Human input recorded in the L3 packet: `L3 通过了暂时`.

Use this latest recapture for review alignment with the current visual state:

| Evidence | Path | Proof class | Result / boundary |
|---|---|---|---|
| Recapture index | `recaptures/20260628-l3-temp-pass-sync-r2/l0-l2-evidence-index.json` | simulator_l0_runtime_truth_recapture + local_pixel_metric | Latest source for ivory/deepSpace, cooling/heating, capsule diorama, continuous stage |
| Recaptured screenshots | `recaptures/20260628-l3-temp-pass-sync-r2/screenshots/l0-simctl/*.png` | simulator_l0_runtime_truth_recapture | Captured after terminating app before each launch; avoids stale launch-argument state |
| Recaptured metrics | `recaptures/20260628-l3-temp-pass-sync-r2/metrics/l2-visual-metrics.json` | local_pixel_metric | Regression/readability metrics only; not aesthetic verdict |
| Continuous-stage strip | `recaptures/20260628-l3-temp-pass-sync-r2/crops/anchor-strip-continuous-stage-no-black-line-recapture-r2.png` | local crop from L0 recapture | Human-review aid |
| Cooling/heating strip | `recaptures/20260628-l3-temp-pass-sync-r2/crops/anchor-strip-cooling-vs-heating-recapture-r2.png` | local crop from L0 recapture | Human-review aid; cooling/heating visibly separated |
| Capsule strip | `recaptures/20260628-l3-temp-pass-sync-r2/crops/anchor-strip-capsule-diorama-recapture-r2.png` | local crop from L0 recapture | Human-review aid |
| Deep-space heating edge follow-up | `Reports/uiue-8c2-deep-space-heating-edge-20260628/screenshots/deep-space-heating-gold-gray-edge-xcodebuildmcp.jpg` | simulator screenshot follow-up | sha256 `4979033017593bd0b571eab16fa5db0a717179ffa92121ef4ba379c6feb449be` |

Superseded for review: `recaptures/20260628-l3-temp-pass-sync/` reused one running app pid across launch-argument cases and is retained only as provenance. The original 2026-06-27 screenshots remain historical/supporting evidence for cases not recaptured here, especially `safety_refusal_ivory`, `cold_start_ivory`, and `u17_golden_path_deep_space`.

## L0 On-Screen Simulator Screenshots

All screenshots were captured with `xcrun simctl io 9E9EC0D0-E4EF-4D29-AAE5-911EB3F02D6D screenshot ...`.

| case_id | screenshot | theme/state | proof_class |
|---|---|---|---|
| `main_cooling_ivory` | `screenshots/l0-simctl/main_cooling_ivory.png` | ivory / cooling | simulator_l0_runtime_truth |
| `main_cooling_deep_space` | `screenshots/l0-simctl/main_cooling_deep_space.png` | deepSpace / cooling | simulator_l0_runtime_truth |
| `main_heating_ivory` | `screenshots/l0-simctl/main_heating_ivory.png` | ivory / heating | simulator_l0_runtime_truth |
| `safety_refusal_ivory` | `screenshots/l0-simctl/safety_refusal_ivory.png` | ivory / safety refusal | simulator_l0_runtime_truth |
| `capsule_video_loop_deep_space` | `screenshots/l0-simctl/capsule_video_loop_deep_space.png` | deepSpace / capsule video loop | simulator_l0_runtime_truth |
| `cold_start_ivory` | `screenshots/l0-simctl/cold_start_ivory.png` | ivory / cold start | simulator_l0_runtime_truth |
| `u17_golden_path_deep_space` | `screenshots/l0-simctl/u17_golden_path_deep_space.png` | deepSpace / U17 golden path | simulator_l0_runtime_truth |

Metadata: `metrics/screenshot-metadata.json`.

## L1 UI Tree / Layout / Interaction

| Evidence | Path | Result |
|---|---|---|
| UI tree cases | `ui-trees/*.txt` | Extracted from `UIC2VisualAcceptanceUITests` log |
| Full UI test log | `Reports/uiue-8c2-pre-human-l3-20260627-231348/logs/UIC2VisualAcceptanceUITests.xcodebuild.log` | 16 tests / 0 failures |
| Fresh layout checker | `metrics/l1-r2b-layout-spacing-fresh-receipt.json` | `WARN`; missing identifiers = 0, overlap fail = 0, safe-area fail = 0 |
| Checker negative fixture | `../r1-r2b-implementation/layout-spacing-missing-target-receipt.json` | `FAIL`; missing `demo-orb`, fail-closed retained |

## L2 Metrics

| Metric | Path | Result boundary |
|---|---|---|
| dark-line / contrast proxy | `metrics/l2-visual-metrics.json`; `metrics/l2-visual-metrics-manifest.json` | all 7 cases `continuous_black_line_scan=PASS`; manifest records source screenshot hashes |
| SSIM/MSE | `metrics/l2-visual-metrics.json` | `ac-card-cooling-vs-heating` SSIM 0.8784; `capsule-top-band-cLite-vs-videoLoop` SSIM 0.9056 |
| OCR equivalent | `ui-trees/*.txt` + UI test expected text | XCUITest text checks passed; local OCR engine unavailable |

These metrics are regression/readability aids only. They do not determine premium aesthetics, human taste, or L3 verdict.

## Anchor Crops

| Anchor | Path | Human attention |
|---|---|---|
| continuous stage no black line | `crops/anchor-strip-continuous-stage-no-black-line.png` | verify no visible black divider, coherent top/orb/cards/mic continuity |
| cooling / heating | `crops/anchor-strip-cooling-vs-heating.png` | verify cold/warm color semantics and card readability |
| capsule diorama | `crops/anchor-strip-capsule-diorama.png` | verify capsule feels like a centered context diorama without baked chrome/white edge artifacts |

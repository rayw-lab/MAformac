---
status: l3_temporary_pass_evidence_synced
artifact_kind: followup_receipt
date: 2026-06-28
repo: /Users/wanglei/workspace/MAformac-uiue
branch: uiue/phase4-default-scope-presentation
head: 4a4aabbacf0736e5ff6f137be4de6cf5c6d37cb5
non_claims:
  - no final L3 PASS
  - no 8.C2 closure
  - no V-PASS
  - no mobile
  - no true_device
  - no runtime-ready
  - no voice-ready
  - no A-2 complete
---

# UIUE 8.C2 L3 Temporary Pass Evidence Sync

## Human Input

磊哥反馈：`L3 通过了暂时`.

Interpretation: this is a temporary L3 human spot-review pass. It is not a final project V-PASS, not mobile proof, not true-device proof, not runtime/voice/model readiness, and does not authorize closing `8.C2`.

## Evidence Synced

| Evidence | Path | Proof class | Notes |
|---|---|---|---|
| L3 packet update | `../l3-human-review-packet.md` | human_review_trace | Adds temporary pass input and keeps final verdict manual. |
| README update | `../README.md` | package_index | Adds recapture sync and non-claims. |
| L0/L2 index update | `../l0-l2-evidence-index.md` | package_index | Points review to r2 recapture. |
| r2 recapture index | `../recaptures/20260628-l3-temp-pass-sync-r2/l0-l2-evidence-index.json` | simulator_l0_runtime_truth_recapture + local_pixel_metric | Latest review source. |
| r2 screenshots | `../recaptures/20260628-l3-temp-pass-sync-r2/screenshots/l0-simctl/*.png` | simulator_l0_runtime_truth_recapture | App terminated before each launch to avoid stale launch args. |
| r2 metrics | `../recaptures/20260628-l3-temp-pass-sync-r2/metrics/l2-visual-metrics.json` | local_pixel_metric | Regression/readability aid only. |
| r2 anchor strips | `../recaptures/20260628-l3-temp-pass-sync-r2/crops/*-recapture-r2.png` | local crop from L0 recapture | Human-review aids for continuous stage, cooling/heating, capsule. |
| deep-space heating edge follow-up | `Reports/uiue-8c2-deep-space-heating-edge-20260628/screenshots/deep-space-heating-gold-gray-edge-xcodebuildmcp.jpg` | simulator screenshot follow-up | sha256 `4979033017593bd0b571eab16fa5db0a717179ffa92121ef4ba379c6feb449be`. |

## Superseded Evidence

`../recaptures/20260628-l3-temp-pass-sync/` is superseded for review. The first recapture reused one running app pid across multiple launch-argument cases, so cooling/heating launch arguments were stale. It remains provenance only.

The original 2026-06-27 package remains historical/supporting evidence for cases not recaptured here: `safety_refusal_ivory`, `cold_start_ivory`, `u17_golden_path_deep_space`, UI tree logs, and R2b checker receipt.

## Commands

```bash
cd /Users/wanglei/workspace/MAformac-uiue
xcrun simctl terminate 9E9EC0D0-E4EF-4D29-AAE5-911EB3F02D6D lab.rayw.MAformac.ios
xcrun simctl launch 9E9EC0D0-E4EF-4D29-AAE5-911EB3F02D6D lab.rayw.MAformac.ios -mockSnapshot cooling -mockTheme ivory
xcrun simctl io 9E9EC0D0-E4EF-4D29-AAE5-911EB3F02D6D screenshot docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/pre-human-l3-package/recaptures/20260628-l3-temp-pass-sync-r2/screenshots/l0-simctl/main_cooling_ivory.png
```

Same terminate-launch-screenshot pattern was repeated for:

- `main_cooling_ivory`
- `main_cooling_deep_space`
- `main_heating_ivory`
- `main_heating_deep_space`
- `capsule_video_loop_deep_space`

Launch/screenshot logs are in `Reports/uiue-8c2-l3-temp-pass-sync-20260628/logs/r2-*.log`.

## 8.C2 Status

`openspec/changes/ui-presentation/tasks.md:112` remains unchecked: `[ ] 8.C2 visual-acceptance ...`.

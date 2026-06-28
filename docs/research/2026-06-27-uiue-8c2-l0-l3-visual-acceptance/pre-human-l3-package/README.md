---
status: l3_temporary_pass_evidence_synced
artifact_kind: evidence_package_not_ssot
date: 2026-06-27
repo: /Users/wanglei/workspace/MAformac-uiue
branch: uiue/phase4-default-scope-presentation
base_head: 4a4aabbacf0736e5ff6f137be4de6cf5c6d37cb5
proof_classes:
  - local
  - unit
  - simulator_l0_runtime_truth
  - simulator_ui
  - local_pixel_metric
non_claims:
  - L3 PASS_WITH_NOTES only
  - 8.C2 closure is R3 scoped only
  - no V-PASS
  - no mobile
  - no true_device
  - no runtime-ready
  - no voice-ready
  - no A-2 complete
---

# UIUE 8.C2 Pre-Human L3 Package

## Verdict

`PASS_WITH_NOTES / R3_8C2_visual_acceptance` candidate：本包已准备 L0/L1/L2 机器证据、anchor 对比、R2b fresh checker receipt、U44 blocker 修复证据和 L3 5-gate 人审表；2026-06-28 已追加磊哥 L3 `PASS_WITH_NOTES` human review truth，并用最新代码重新 recapture 关键 L0/L2 证据。

这不是 V-PASS，也不是 mobile/true_device/runtime/voice/model readiness。`8.C2` closure 只允许表示 R3 simulator/mock visual-acceptance scope 关闭，不表示 A-2 complete 或 R1/R2b/runtime 完成。

## 2026-06-28 L3 Temporary Pass Sync

Human input: `L3 通过了暂时` / `我通过了`.

Boundary: L3 `PASS_WITH_NOTES` authorizes R3 closure only after proof/leave-trace/burndown/double-audit gates. It does not authorize V-PASS/mobile/true_device/runtime/voice/model/A-2 complete.

Latest synced evidence:

- L3 packet update: `l3-human-review-packet.md`
- Follow-up receipt: `followups/l3-temporary-pass-evidence-sync-20260628.md`
- Recapture index: `recaptures/20260628-l3-temp-pass-sync-r2/l0-l2-evidence-index.json`
- Recaptured screenshots: `recaptures/20260628-l3-temp-pass-sync-r2/screenshots/l0-simctl/*.png`
- Recaptured anchor strips: `recaptures/20260628-l3-temp-pass-sync-r2/crops/*-recapture-r2.png`
- Gold-gray edge reference: `Reports/uiue-8c2-deep-space-heating-edge-20260628/screenshots/deep-space-heating-gold-gray-edge-xcodebuildmcp.jpg`
- Gold-gray edge sha256: `4979033017593bd0b571eab16fa5db0a717179ffa92121ef4ba379c6feb449be`

Superseded for review: `recaptures/20260628-l3-temp-pass-sync/` was the first same-day recapture attempt, but it reused the same running app pid across launch-argument cases. It remains provenance only; use `20260628-l3-temp-pass-sync-r2` for review.

## Evidence Index

| Layer | Evidence | Path | Proof class | Result |
|---|---|---|---|---|
| L0/L2 follow-up | 2026-06-28 recapture after L3 temporary pass | `recaptures/20260628-l3-temp-pass-sync-r2/l0-l2-evidence-index.json` | simulator_l0_runtime_truth_recapture + local_pixel_metric | covers ivory/deepSpace, cooling/heating, capsule diorama, continuous-stage strips; supersedes first 2026-06-28 recapture attempt |
| L0 | on-screen simulator screenshots | `screenshots/l0-simctl/*.png` | simulator_l0_runtime_truth | 7 cases captured by `xcrun simctl io ... screenshot`, including U17 golden path |
| L1 | UI tree / identifiers / text / frame assertions | `ui-trees/*.txt`; `Reports/uiue-8c2-pre-human-l3-20260627-231348/logs/UIC2VisualAcceptanceUITests.xcodebuild.log` | simulator_ui | 16 UI tests / 0 failures |
| L1 | R2b layout spacing checker on fresh UI tree | `metrics/l1-r2b-layout-spacing-fresh-receipt.json` | input_source=simulator_ui_tree; evaluation_proof_class=local_checker | `WARN`; no missing identifiers, no overlap fail, no safe-area fail; white-edge threshold remains blocked |
| L2 | screenshot metadata | `metrics/screenshot-metadata.json` | local from simulator screenshots | 7 screenshots, 1320x2868 |
| L2 | pixel metrics | `metrics/l2-visual-metrics.json`; `metrics/l2-visual-metrics-manifest.json` | local_pixel_metric | dark-line scan PASS for 7 cases; SSIM/MSE recorded with source screenshot hashes |
| L2 | OCR-equivalent text/readability evidence | `ui-trees/*.txt`; UI test log | simulator_ui | UI tree text checks passed; tesseract OCR not available locally |
| Anchor | continuous stage no black line strip | `crops/anchor-strip-continuous-stage-no-black-line.png` | local crop from L0 | for human review only |
| Anchor | cooling/heating strip | `crops/anchor-strip-cooling-vs-heating.png` | local crop from L0 | for human review only |
| Anchor | capsule diorama strip | `crops/anchor-strip-capsule-diorama.png` | local crop from L0 | for human review only |
| L3 | human review packet | `l3-human-review-packet.md` | human pending | empty verdict fields for 磊哥 |

## Commands

```bash
cd /Users/wanglei/workspace/MAformac-uiue
swift test --filter U44LiquidGlassHardeningInventoryTests
swift test --filter StateCellInteractionPolicyTests
swift test
python3 -m py_compile Tools/checks/check-uiue-layout-spacing.py
Tools/checks/check-uiue-layout-spacing.py --ui-tree docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/pre-human-l3-package/metrics/main_cooling_deep_space-ui-tree-frames.json --screenshot-metadata docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/pre-human-l3-package/metrics/main_cooling_deep_space-screenshot-metadata.json --crop-dir docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/pre-human-l3-package/crops --output docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/pre-human-l3-package/metrics/l1-r2b-layout-spacing-fresh-receipt.json
xcodebuild test -scheme MAformacIOS -destination 'platform=iOS Simulator,id=9E9EC0D0-E4EF-4D29-AAE5-911EB3F02D6D' -only-testing:MAformacIOSUITests/UIC2VisualAcceptanceUITests
openspec validate ui-presentation --strict
rg -n '^- \[[ x]\] 8\.C2' openspec/changes/ui-presentation/tasks.md
git diff --check
```

L0 screenshot capture used the already installed simulator app:

```bash
xcrun simctl launch 9E9EC0D0-E4EF-4D29-AAE5-911EB3F02D6D lab.rayw.MAformac.ios -mockSnapshot cooling -mockTheme ivory -contextCapsuleRoute cLite
xcrun simctl io 9E9EC0D0-E4EF-4D29-AAE5-911EB3F02D6D screenshot docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/pre-human-l3-package/screenshots/l0-simctl/main_cooling_ivory.png
```

## Case Coverage

| Case | Theme | State | Key coverage |
|---|---|---|---|
| `main_cooling_ivory` | ivory | cooling/speak | continuous stage, no-black-line scan, cooling card |
| `main_cooling_deep_space` | deepSpace | cooling/speak | deep-space theme, UI tree, fresh R2b checker input |
| `main_heating_ivory` | ivory | heating/speak | heating mode/card and warm semantic color |
| `safety_refusal_ivory` | ivory | safety/think | safety refusal, orb think caption, D gear context |
| `capsule_video_loop_deep_space` | deepSpace | cooling/speak | capsule diorama route `videoLoop` |
| `cold_start_ivory` | ivory | idle | orb idle / cold-start state |
| `u17_golden_path_deep_space` | deepSpace | golden path AC success | U17 golden-path L0 screenshot plus UI tree coverage |

Reduce Motion is covered by `PresentationReducedMotionPolicyTests` and UI code paths that read `accessibilityReduceMotion`; this run did not change the simulator global accessibility setting. Treat Reduce Motion as `local/unit covered, simulator visual not captured`.

## Non-Claims

- Machine L0/L1/L2 evidence does not sign L3.
- R2b checker `WARN` is not a visual/aesthetic pass; it keeps white-edge threshold unresolved.
- UI tests are simulator proof, not mobile/true-device proof.
- Mock writeback proof is not runtime/voice/LLM readiness.
- `8.C2` remains open.

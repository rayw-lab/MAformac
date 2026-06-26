# A-2 P1 Phase Ledger

Date: 2026-06-26

Status: P1 reconciliation ledger after P0 commit anchors.

Proof boundary: isolated UIUE worktree. This ledger reconciles current code, receipts, tasks, coverage, and evidence. It is not mainline proof, not true-device proof, and not product V-PASS.

| Phase | Code implemented? | Receipt status | tasks.md checked? | Coverage index checked? | Screenshot/runtime evidence exists? | Residual blocker |
|---|---|---|---|---|---|---|
| Phase 2 continuous stage | Yes, in shared scaffold `98f7c57`; proof slice `3ae2349` | PARTIAL | `8.A` open; `8.C2` open; `8.C1` checked for mechanical gates only | SD18/SD22/SD23 and visual rows open | Yes: v72 screenshots + v59/v72 TSVs | Visual-acceptance 5-gate and anchor-level human review |
| Phase 3 touch chain | Yes, in shared scaffold `98f7c57`; proof slice `0a3b26f`; P2 stepper evidence added | PARTIAL / simulator touch-stepper-pass | `8.D1-8.D3` checked; `8.D4` open | SD6 checked; SD7 open | Yes: expanded control screenshots + AC `26℃ -> 27℃` tap mutation screenshot | Voice-reasoning mock and drag/operator-pass evidence |
| Phase 4 demo control panel | Yes, in shared scaffold `98f7c57`; proof slice `564d0c0`; P2 route probe added; P3 route fix added | DONE for A-2 simulator/mock interaction scope | `8.E1-8.E4` checked | SD8/SD12/SD13/SD14/SD15 and RPB-52 checked | Yes: control panel, all-state, settings route, theme toggle, rain macro, reset screenshots/UI tree | No true-device/product V-PASS; customer-facing acceptance not claimed |
| Phase 5 ambient burst | Yes, in shared scaffold `98f7c57`; proof slice `0db244c` | DONE for local+simulator mock scope | `8.F1` checked | SD4 checked; SD16 open | Yes: v7 screenshot + 5s simulator recording | Physical ambient-card tap proof and true-device readability/FPS |
| Phase 6 context capsule | Yes, in shared scaffold `98f7c57`; proof slice `4d42bcb` | DONE for A-2 simulator scope | `8.B1-8.B4` checked | SD24/SD25 checked | Yes: v3 context screenshots, route A/C evidence, ROI metrics | True-device GPU/FPS and final route-A photoreal art |

## Reconciliation Actions

- Update `openspec/changes/ui-presentation/tasks.md` so Phase 4 subtask status matches receipt/coverage: check `8.E1-8.E3`, keep `8.E4` open.
- Keep Phase 2 visual rows open until visual-acceptance 5-gate passes.
- Keep Phase 3 SD7 open until voice-reasoning mock and drag/operator-pass evidence exist.
- Keep Phase 5 and Phase 6 simulator-scope DONE boundaries explicit; do not promote them to true-device or V-PASS.

## P2 Proof Refresh

Captured at: 2026-06-26 12:41:20 CST

| Gate | Status | Ledger effect |
|---|---|---|
| iOS simulator launch | PASS | Confirms current shared scaffold still runs in simulator |
| Phase 3 AC expanded stepper tap | PASS | Supports `8.D1-8.D3` and SD6 only; SD7 still open |
| Phase 4 settings route probe | PASS after P3 route fix | Closes `8.E4`, SD8, and SD12 for simulator/mock interaction scope only |
| `swift test` | PASS: 245 tests, 3 skipped, 0 failures | Supports `8.C1` only |
| macOS `xcodebuild` | PASS | Supports `8.C1` only |
| `make verify-all` | PASS exit 0 | Supports `8.C1` only |

No coverage row was checked from code existence alone. Each checked row has a matching task row, receipt statement, and local/simulator evidence.

## P3 Phase 4 Route Closure

Captured at: 2026-06-26 13:08 CST

`8.E4` is now checked because serial simulator evidence proves settings route, theme switch, rain macro force, and reset. This updates only Phase 4; Phase 2 visual acceptance and Phase 3 SD7 remain open.

---
status: r3_8c2_closeout_burndown
artifact_kind: grill_burndown_ledger
date: 2026-06-27
repo: /Users/wanglei/workspace/MAformac-uiue
branch: uiue/phase4-default-scope-presentation
source_matrix: docs/loop-competition/2026-06-27-uiue-r0-r2-grill-matrix/final-grill-matrix.md
canonical_authority: docs/grill-tournament/uiue-r0-r2-grill-decisions-2026-06-27.md
implementation_receipt: docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/README.md
proof_classes:
  - local
  - unit
non_claims:
  - 8.C2 closed only after R3 audit gates
  - no V-PASS
  - no mobile
  - no true_device
  - no runtime-ready
  - no voice-ready
  - no A-2 complete
---

# UIUE R0-R2 Grill Burndown - 2026-06-27 R1/R2b First Slice

## Verdict

本账本只消减本轮实际实现和验证触达的 Cxx / canonical groups。原始 70 条 source matrix 保持 evidence/audit input，不删除、不改写。`resolved_with_proof` 只用于同时具备实现、proof path、proof class、validation command 的项；其余保持 `partially_resolved`、`deferred`、`still_open` 或 `not_touched`。

## 2026-06-28 R3 Closeout Delta

磊哥 human review truth: `PASS_WITH_NOTES` / human review passed with notes. Notes are not R3 blockers, but remain residual/non-claims: R2b white-edge threshold not formalized, capsule final-art polish deferred, simulator proof is not mobile/true_device, and this closeout is not runtime/voice/model readiness.

### R3 Added Proof Index

| proof_id | path | proof_class | validation_command | result |
|---|---|---|---|---|
| P-R3-L3-PASS-WITH-NOTES | `docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/pre-human-l3-package/l3-human-review-packet.md` | human_review | repo-visible human review record | `PASS_WITH_NOTES`; reviewer 磊哥; notes retained |
| P-R3-RECAPTURE-R2 | `docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/pre-human-l3-package/recaptures/20260628-l3-temp-pass-sync-r2/l0-l2-evidence-index.json` | simulator_l0_runtime_truth_recapture + local_pixel_metric | terminate-launch-screenshot r2 flow; `python3 -m json.tool ...` | latest L0/L2 source; first 2026-06-28 recapture superseded due stale pid |
| P-R3-REDUCE-MOTION | `docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/pre-human-l3-package/r3-closeout-20260628/screenshots/reduce-motion/reduce_motion_think_ivory.png` | simulator_debug_override | `xcrun simctl launch ... -mockSnapshot safetyRefusal -mockTheme ivory -forceReduceMotion`; `swift test --filter PresentationReducedMotionPolicyTests` | screenshot sha256 `3c6157419e6b684049fdb516638d1edf018e38c442d74da0d10714433304e8cc`; not true-device setting proof |
| P-R3-ORB-FOUR-STATE | `docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/pre-human-l3-package/r3-closeout-20260628/screenshots/orb-four-state/*.png`; `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift` | simulator_l0_runtime_truth + simulator_ui_test | XcodeBuildMCP `test_sim -only-testing:MAformacIOSUITests/UIC2VisualAcceptanceUITests/testOrbPresetStatesExposeDistinctCaptionsAndStayContained` | 1 test / 0 failures; idle/listen/think/speak screenshots captured |
| P-R3-BUG-ICEBERG | `Reports/uiue-8c2-r3-closeout-20260628/bug-iceberg-stale-recapture-and-reduce-motion.md` | local/governance | image spot-check + pid/log review | stale recapture generalized and fixed by r2 freshness invariant |

### R3 Cxx Delta

| Cxx / group | previous status | R3 status | proof | proof_class | validation / note |
|---|---|---|---|---|---|
| C13 / G-R2B-VPA-ORB-STATES | partially_resolved | resolved_with_proof_for_8c2_presentation; runtime_binding_deferred_post_r3 | P-R3-ORB-FOUR-STATE | simulator_l0_runtime_truth + simulator_ui_test | four orb states have presentation/mock snapshot path and screenshots; runtime-driven intent/route state binding is not proven here |
| C14 / G-R2B-VPA-ORB-STATES | partially_resolved | resolved_with_proof_for_8c2_presentation; runtime_binding_deferred_post_r3 | P-R3-ORB-FOUR-STATE | simulator_l0_runtime_truth + simulator_ui_test | `idle/listen/think/speak` mock binding has targeted UI test proof; complex-reasoning -> think must be verified later through runtime presentation bridge |
| C38 / G-R1-A11Y-TESTABILITY | not_touched | accepted_with_notes_for_r3 | P-R3-REDUCE-MOTION | simulator_debug_override + unit | simulator lacks `simctl ui reduce_motion`; DEBUG override screenshot accepted for R3, not true-device proof |
| C51/C52/C53 / G-R2-CASE-MATRIX | partially_resolved | accepted_with_notes_for_r3 | P-R3-RECAPTURE-R2; P-R3-L3-PASS-WITH-NOTES | simulator_l0_runtime_truth_recapture + human_review | required 8.C2 anchor-set covered; full 10-family matrix deferred post-R3 |
| C56/C57/C58 / G-R2B-LAYOUT-SPACING | resolved/partial | accepted_with_notes_for_r3 | P-L1-R2B-FRESH; P-R3-L3-PASS-WITH-NOTES | local_checker + human_review | checker remains `WARN`; white-edge threshold not formalized but no longer R3 blocker by user decision |
| C59/C60 / G-R2-EVIDENCE-GATES | partially_resolved | resolved_with_proof | P-R3-RECAPTURE-R2 | simulator_l0_runtime_truth_recapture + local_pixel_metric | L0/L2 recapture synced to latest visual state; first recapture superseded |
| C62/C63/C68 / G-R2B-CAPSULE-ANCHOR-ASSET | partial/deferred | accepted_with_notes_for_r3 | P-R3-RECAPTURE-R2; P-R3-L3-PASS-WITH-NOTES | simulator_l0_runtime_truth_recapture + human_review | capsule final-art/white-edge retained as residual, not R3 blocker |
| C64/C65 / G-R2B-VPA-ORB-STATES | still_open/partial | accepted_with_notes_for_r3; runtime_binding_deferred_post_r3 | P-R3-ORB-FOUR-STATE; P-R3-L3-PASS-WITH-NOTES | simulator_l0_runtime_truth + simulator_ui_test + human_review | four-state presentation proof added; deep-space halo budget remains visual residual with L3 notes; backend intent-routing/state-driver proof remains post-R3 |
| C66/C67 / G-R2-L3-PUNCHLIST | partially_resolved | resolved_with_proof | P-R3-L3-PASS-WITH-NOTES | human_review | L3 verdict recorded as `PASS_WITH_NOTES`; authorization allows `8.C2` closure after audit gates |
| C23-C50 / R1 interaction/a11y matrix | mixed partial/open | deferred_post_r3 except C38 noted above | P-R1-UNIT where existing | unit/local/docs | broader R1 completeness remains outside 8.C2 R3 closure; no fake full R1 pass |

### R3 Residual / Deferred Post-R3

- R2b white-edge threshold remains `WARN`, not checker clean PASS.
- Capsule final-art polish remains post-R3.
- Full mobile/true-device proof remains absent.
- Runtime/voice/model readiness remains absent.
- Runtime-driven VPA/orb binding remains deferred: this R3 only proves presentation/mock snapshot state binding, not ASR/LLM/intent-router/tool-execution state driving. Complex reasoning should map to `think` only after runtime presentation bridge verification.
- Long-press 1.5s -> 演绎控制台 is not implemented/proven in R3. Live code shows `演绎控制台` only as a Settings panel button, while `MicDock` long press uses `minimumDuration: 0.05` only for press feedback. Keep this as `deferred_post_r3` under R1 interaction residual; do not count it as 8.C2 closure proof.
- Broader R1 matrix debt remains post-R3; only the pieces needed for 8.C2 R3 closeout are resolved or accepted with notes.

## Proof Index

| proof_id | path | proof_class | validation_command | result |
|---|---|---|---|---|
| P-R1-UNIT | `Tests/MAformacCoreTests/StateCellInteractionPolicyTests.swift` | unit | `swift test --filter StateCellInteractionPolicyTests` | pass, 5 tests / 0 failures |
| P-R1-PROJECTION | `Core/Presentation/StateCellInteractionPolicy.swift` | local | `swift test --filter StateCellInteractionPolicyTests` | pass, projection compiles and derives from existing mappers/catalog/store |
| P-R2B-CHECKER | `Tools/checks/check-uiue-layout-spacing.py` | local | `Tools/checks/check-uiue-layout-spacing.py --help` | pass |
| P-R2B-RECEIPT | `docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/layout-spacing-receipt.json` | local | `Tools/checks/check-uiue-layout-spacing.py --ui-tree docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/fixtures/layout-ui-tree.json --screenshot-metadata docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/fixtures/layout-screenshot-metadata.json --crop-dir docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/crops --output docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/layout-spacing-receipt.json` | exit 0, receipt status `WARN` with white-edge `BLOCKED_FOR_THRESHOLD` |
| P-R2B-MISSING-TARGET | `docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/layout-spacing-missing-target-receipt.json` | local | `Tools/checks/check-uiue-layout-spacing.py --ui-tree docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/fixtures/layout-ui-tree-missing-target.json --screenshot-metadata docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/fixtures/layout-screenshot-metadata.json --crop-dir docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/crops --output docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/layout-spacing-missing-target-receipt.json; code=$?; test "$code" -eq 1` | pass as fail-closed check: command exits 1, receipt status `FAIL`, missing `demo-orb` recorded |

## Resolved-With-Proof Exact Commands

| Cxx | canonical_group | proof_path | proof_class | validation_command |
|---|---|---|---|---|
| C21 | G-R1-INTERACTION-SSOT | `Core/Presentation/StateCellInteractionPolicy.swift`; `Tests/MAformacCoreTests/StateCellInteractionPolicyTests.swift` | unit | `swift test --filter StateCellInteractionPolicyTests` |
| C22 | G-R1-INTERACTION-SSOT | `Tests/MAformacCoreTests/StateCellInteractionPolicyTests.swift` | unit | `swift test --filter StateCellInteractionPolicyTests` |
| C56 | G-R2B-LAYOUT-SPACING | `Tools/checks/check-uiue-layout-spacing.py`; `docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/layout-spacing-receipt.json`; `docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/layout-spacing-missing-target-receipt.json` | local | `Tools/checks/check-uiue-layout-spacing.py --help`; `Tools/checks/check-uiue-layout-spacing.py --ui-tree docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/fixtures/layout-ui-tree.json --screenshot-metadata docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/fixtures/layout-screenshot-metadata.json --crop-dir docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/crops --output docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/layout-spacing-receipt.json`; `Tools/checks/check-uiue-layout-spacing.py --ui-tree docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/fixtures/layout-ui-tree-missing-target.json --screenshot-metadata docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/fixtures/layout-screenshot-metadata.json --crop-dir docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/crops --output docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/layout-spacing-missing-target-receipt.json; code=$?; test "$code" -eq 1` |

## R1 Burndown

| Cxx | canonical_group | status | proof | proof_class | validation | note |
|---|---|---|---|---|---|---|
| C21 | G-R1-INTERACTION-SSOT | resolved_with_proof | P-R1-PROJECTION | unit | `swift test --filter StateCellInteractionPolicyTests` | `StateCellInteractionPolicy` is a consumer-side projection, not a new producer SSOT. |
| C22 | G-R1-INTERACTION-SSOT | resolved_with_proof | P-R1-UNIT | unit | `swift test --filter StateCellInteractionPolicyTests` | Projection derives family/type/range/options from existing mappers/catalog. |
| C23 | G-R1-MATRIX-PROOF | partially_resolved | P-R1-UNIT | unit | `swift test --filter StateCellInteractionPolicyTests` | Fields exist and representative rows are tested; full 10-family matrix receipt remains open. |
| C24 | G-R1-INTERACTION-SSOT | partially_resolved | P-R1-UNIT | unit | `swift test --filter StateCellInteractionPolicyTests` | Family/value type/gesture fields are separated; full coverage counts are not complete. |
| C25 | G-R1-READONLY-AFFORDANCE | partially_resolved | P-R1-UNIT | unit | `swift test --filter StateCellInteractionPolicyTests` | Projection prevents fake options/writeback for read-only/process cells; UI visual affordance proof remains open. |
| C26 | G-R1-VALUE-CONTROL-SEMANTICS | partially_resolved | P-R1-UNIT | unit | `swift test --filter StateCellInteractionPolicyTests` | Ring cross-zero delta and representative dial/percent writeback covered; full tap/drag/a11y UI proof remains open. |
| C27 | G-R1-VALUE-CONTROL-SEMANTICS | partially_resolved | P-R1-UNIT | unit | `swift test --filter StateCellInteractionPolicyTests` | Stepper representative writeback/readback covered; drag scrub UI proof remains open. |
| C28 | G-R1-VALUE-CONTROL-SEMANTICS | partially_resolved | P-R1-UNIT | unit | `swift test --filter StateCellInteractionPolicyTests` | Toggle representative path covered; full enum-pair UI matrix remains open. |
| C29 | G-R1-VALUE-CONTROL-SEMANTICS | partially_resolved | P-R1-UNIT | unit | `swift test --filter StateCellInteractionPolicyTests` | Badge options derive from `BadgeOptionMapper`; full preset/options UI coverage remains open. |
| C30 | G-R1-VALUE-CONTROL-SEMANTICS | partially_resolved | P-R1-UNIT | unit | `swift test --filter StateCellInteractionPolicyTests` | Ambient color writeback/summary covered; outer color visual sync and expanded row visual proof remain open. |
| C31 | G-R1-READONLY-AFFORDANCE | deferred | none | local/docs | none | Summary direct-control boundary remains a product/pre-mortem decision; this slice does not change it. |
| C32 | G-R1-VALUE-CONTROL-SEMANTICS | still_open | none | none | none | Overlay hit-testing was not changed or verified in this slice. |
| C33 | G-R1-A11Y-TESTABILITY | not_touched | none | none | none | Accessibility identifier uniqueness remains future debt. |
| C34 | G-R1-VALUE-CONTROL-SEMANTICS | partially_resolved | P-R1-UNIT | unit | `swift test --filter StateCellInteractionPolicyTests` | Representative store writebacks and summary refresh are covered; full `ExpandedFamilyCard -> ContentView.applyMockTransition -> DemoVehicleStateStore.applyMockTransition` UI bridge proof remains open. |
| C35 | G-R1-MATRIX-PROOF | partially_resolved | P-R1-UNIT | unit | `swift test --filter StateCellInteractionPolicyTests` | Store + summary/readback covered for representative rows; color visual/dialogue layers remain open. |
| C36 | G-R1-STABILITY-DEBT | not_touched | none | none | none | Sequencer wait strategy not touched. |
| C37 | G-R1-MATRIX-PROOF | partially_resolved | P-R1-UNIT | unit | `swift test --filter StateCellInteractionPolicyTests` | Gesture enum separates ring/stepper/toggle/badge; long-press/a11y proof remains open. |
| C38 | G-R1-A11Y-TESTABILITY | not_touched | none | none | none | Reduce Motion/Transparency interaction proof not touched. |
| C39 | G-R1-A11Y-TESTABILITY | still_open | none | none | none | 44pt target proof remains open. |
| C40 | G-R1-A11Y-TESTABILITY | not_touched | none | none | none | VoiceOver/a11y alternate entry proof not touched. |
| C41 | G-R1-UIUE-VERIFY-GATE | deferred | none | local/docs | none | No make target added; separate grill decision still required. |
| C42 | G-R1-UIUE-VERIFY-GATE | deferred | none | local/docs | none | Gate boundary preserved: no global `make verify-all` integration. |
| C43 | G-R1-A11Y-TESTABILITY | not_touched | none | none | none | Pro Max UI frame diagnostics not touched. |
| C44 | G-R1-A11Y-TESTABILITY | partially_resolved | P-R1-UNIT | unit | `swift test --filter StateCellInteractionPolicyTests` | Added negative read-only/process and ring-boundary assertions; not every future interaction test has a negative pair yet. |
| C45 | G-R1-MATRIX-PROOF | partially_resolved | implementation receipt Bug Iceberg Teardown | local/docs | `swift test --filter StateCellInteractionPolicyTests`; checker fixture command; stale-status grep; clean-baseline full-test comparison | Teardown executed for checker/test/stale-spec/dirty-provenance bugs; permanent automated trigger remains open. |
| C46 | G-R1-READONLY-AFFORDANCE | partially_resolved | P-R1-UNIT | unit | `swift test --filter StateCellInteractionPolicyTests` | Process/read-only fake options are blocked in projection; changing-state visual affordance remains open. |
| C47 | G-R1-VALUE-CONTROL-SEMANTICS | partially_resolved | P-R1-UNIT | unit | `swift test --filter StateCellInteractionPolicyTests` | Projection records catalog readback; full Chinese title/id mapping proof remains open. |
| C48 | G-R0-PROOF-STATUS-BOUNDARY | partially_resolved | P-R1-UNIT; this ledger | local + unit | `swift test --filter StateCellInteractionPolicyTests` | Proof class is recorded for this slice; every future interaction proof still needs explicit class. |
| C49 | G-R1-INTERACTION-SSOT | partially_resolved | P-R1-PROJECTION | local + unit | `swift test --filter StateCellInteractionPolicyTests` | Projection avoids view-local ranges/options; no grep/code-review gate added. |
| C50 | G-R1-STABILITY-DEBT | partially_resolved | this ledger | local/docs | none | Debt now has status labels here; owner/defer/trigger still needs future durable debt ledger if scope grows. |

## R2b Burndown

| Cxx | canonical_group | status | proof | proof_class | validation | note |
|---|---|---|---|---|---|---|
| C11 | G-R2B-CAPSULE-ANCHOR-ASSET | deferred | none | local/docs | none | Asset governance not touched; current capsule asset remains outside this slice. |
| C12 | G-R2B-CAPSULE-ANCHOR-ASSET | deferred | none | local/docs | none | Placeholder/final-art boundary must remain in closeout; no final art claim. |
| C13 | G-R2B-VPA-ORB-STATES | still_open | none | none | none | Halo hierarchy needs screenshot/crop/L3 punchlist, not this fixture. |
| C14 | G-R2B-VPA-ORB-STATES | still_open | none | none | none | Orb four-state binding proof not produced. |
| C15 | G-R2B-LAYOUT-SPACING | partially_resolved | P-R2B-RECEIPT | local | checker fixture command | Fixture covers settings/refresh vs capsule gaps; no fresh simulator frame proof yet. |
| C16 | G-R2B-LAYOUT-SPACING | still_open | none | none | none | Left/right status-column first-row alignment not represented in fixture identifiers. |
| C56 | G-R2B-LAYOUT-SPACING | resolved_with_proof | P-R2B-CHECKER; P-R2B-RECEIPT; P-R2B-MISSING-TARGET | local | `Tools/checks/check-uiue-layout-spacing.py --help`; `Tools/checks/check-uiue-layout-spacing.py --ui-tree docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/fixtures/layout-ui-tree.json --screenshot-metadata docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/fixtures/layout-screenshot-metadata.json --crop-dir docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/crops --output docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/layout-spacing-receipt.json`; `Tools/checks/check-uiue-layout-spacing.py --ui-tree docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/fixtures/layout-ui-tree-missing-target.json --screenshot-metadata docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/fixtures/layout-screenshot-metadata.json --crop-dir docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/crops --output docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/layout-spacing-missing-target-receipt.json; code=$?; test "$code" -eq 1` | Checker emits `missing_identifiers`, `overlap_pairs`, `min_gaps`, `zone_budget`, `safe_area_violations`, and `threshold_source`; missing required target frame fails closed. |
| C57 | G-R2B-LAYOUT-SPACING | partially_resolved | P-R2B-RECEIPT | local | checker fixture command | Pair coverage exists for fixture identifiers; fresh simulator UI tree/capsule/orb/cards/dock proof remains open. |
| C58 | G-R2B-LAYOUT-SPACING | partially_resolved | P-R2B-RECEIPT | local | checker fixture command | Receipt emits PASS/WARN/FAIL status and crop path placeholders; real crop artifacts remain open. |
| C59 | G-R2-EVIDENCE-GATES | not_touched | none | none | none | This slice did not rerun L0 screenshots; on-screen simctl remains required for 8.C2. |
| C60 | G-R2-EVIDENCE-GATES | not_touched | none | none | none | This slice did not change L0 harness fields. |
| C61 | G-R2-EVIDENCE-GATES | not_touched | none | none | none | R2 evidence checker mutability not changed. |
| C62 | G-R2B-CAPSULE-ANCHOR-ASSET | deferred | none | local/docs | none | Capsule 5-context proof remains future simulator/L3 work. |
| C63 | G-R2B-CAPSULE-ANCHOR-ASSET | partially_resolved | R2b checker spec update | local/docs | none | Proof split is documented; no capsule context/data or diorama proof was produced. |
| C64 | G-R2B-VPA-ORB-STATES | still_open | none | none | none | Four-state UI tree proof remains open. |
| C65 | G-R2B-VPA-ORB-STATES | still_open | none | none | none | Ivory/deepSpace halo budget proof remains open. |
| C66 | G-R2-L3-PUNCHLIST | still_open | none | none | none | L3 punchlist template/review not run. |
| C67 | G-R2-L3-PUNCHLIST | still_open | none | none | none | Human review order remains open. |
| C68 | G-R2B-CAPSULE-ANCHOR-ASSET | partially_resolved | this ledger and implementation receipt | local/docs | none | Closeout now records final-art-deferred boundary; asset brief/proof remains open. |

## Still Blocking R1 / R2 / R2b

- R1 cannot claim complete while C23/C24/C25/C26/C27/C30/C32/C35/C37/C39/C42/C48/C49 are not fully proven with the relevant UI/unit/simulator matrix.
- R2b cannot claim ready while C13/C14/C16/C57/C58/C64/C65/C66/C67 remain open and no fresh simulator screenshot/crop/L3 package exists.
- R2 cannot rerun/close `8.C2` from this slice; C59/C60 and the L0-L3 package remain separate.
- `8.C2` remains open.

## Next Required Grill / Pre-Mortem

- C31: summary direct-control boundary.
- C41/C42: whether and how to promote a UIUE-only `verify-uiue-interactions` gate.
- C62/C63/C68: capsule final asset/proof split and placeholder boundary.
- C13/C14/C64/C65: VPA/orb state driver, halo budget, and theme proof.
- C66/C67: L3 punchlist and review order.

## 2026-06-27 Pre-Human L3 Evidence Update

本节是 2026-06-27 pre-human L3 历史段，已被上方 `2026-06-28 R3 Closeout Delta` supersede。原始语境下 `8.C2` 仍 open、没有磊哥 L3 verdict；现在 R3 已记录 L3 `PASS_WITH_NOTES` 并关闭 `8.C2`，但仍不得写 V-PASS、mobile、true_device、runtime-ready、voice-ready 或 A-2 complete。

### Added Proof Index

| proof_id | path | proof_class | validation_command | result |
|---|---|---|---|---|
| P-U44-MAIN-GREEN | `Tests/MAformacCoreTests/U44LiquidGlassHardeningInventoryTests.swift` | unit + local | `swift test --filter U44LiquidGlassHardeningInventoryTests`; `swift test` | U44 targeted 5 tests / 0 failures; main worktree full suite 315 tests / 0 failures / 3 skipped |
| P-L0-SIMCTL | `docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/pre-human-l3-package/screenshots/l0-simctl/*.png` | simulator_l0_runtime_truth | `xcrun simctl io 9E9EC0D0-E4EF-4D29-AAE5-911EB3F02D6D screenshot ...` | 7 on-screen simulator screenshots captured, including U17 golden path |
| P-L1-UITEST | `Reports/uiue-8c2-pre-human-l3-20260627-231348/logs/UIC2VisualAcceptanceUITests.xcodebuild.log`; `pre-human-l3-package/ui-trees/*.txt` | simulator_ui | `xcodebuild test -scheme MAformacIOS -destination 'platform=iOS Simulator,id=9E9EC0D0-E4EF-4D29-AAE5-911EB3F02D6D' -only-testing:MAformacIOSUITests/UIC2VisualAcceptanceUITests` | 16 tests / 0 failures |
| P-L1-R2B-FRESH | `pre-human-l3-package/metrics/l1-r2b-layout-spacing-fresh-receipt.json` | input_source=simulator_ui_tree; evaluation_proof_class=local_checker | `Tools/checks/check-uiue-layout-spacing.py --ui-tree pre-human-l3-package/metrics/main_cooling_deep_space-ui-tree-frames.json --screenshot-metadata pre-human-l3-package/metrics/main_cooling_deep_space-screenshot-metadata.json --crop-dir pre-human-l3-package/crops --output pre-human-l3-package/metrics/l1-r2b-layout-spacing-fresh-receipt.json` | `WARN`; missing identifiers 0, overlap fail 0, safe-area fail 0; white-edge threshold unresolved |
| P-L2-METRICS | `pre-human-l3-package/metrics/l2-visual-metrics.json`; `pre-human-l3-package/metrics/l2-visual-metrics-manifest.json` | local_pixel_metric | generated from L0 screenshots with PIL/numpy; manifest records source screenshot hashes | dark-line scan PASS for 7 cases; SSIM/MSE recorded as regression evidence |
| P-L3-PACKET | `pre-human-l3-package/l3-human-review-packet.md` | human_review_pending | human review not run by agent | template ready; verdict fields blank |

### Delta Against Cxx / Canonical Groups

| Cxx / group | previous status | updated status | proof | note |
|---|---|---|---|---|
| C13/C14 / G-R2B-VPA-ORB-STATES | still_open | partially_resolved | P-L0-SIMCTL; P-L1-UITEST | idle/speak/think captions and containment have simulator proof; human halo/theme judgement still open. |
| C16/C57/C58 / G-R2B-LAYOUT-SPACING | still_open / partially_resolved | partially_resolved | P-L1-R2B-FRESH | Fresh UI tree checker no longer has missing/overlap/safe-area failure; remains `WARN` due white-edge threshold. |
| C59/C60 / G-R2-EVIDENCE-GATES | not_touched | partially_resolved | P-L0-SIMCTL; P-L1-UITEST; P-L2-METRICS | L0 screenshots and metadata exist; OCR is UI-tree equivalent, not true OCR. |
| C51/C52/C53 / G-R2-CASE-MATRIX | local/docs-only | partially_resolved | P-L0-SIMCTL; P-L1-UITEST | Cooling/deepSpace, heating/ivory, safety, cold-start, capsule videoLoop, U17 golden path covered; full 10-family x theme x a11y matrix remains open. |
| C66/C67 / G-R2-L3-PUNCHLIST | still_open at 2026-06-27 pre-human stage | superseded_by_R3_PASS_WITH_NOTES | P-L3-PACKET; P-R3-L3-PASS-WITH-NOTES | Punchlist template existed pre-human; 2026-06-28 R3 records human verdict `PASS_WITH_NOTES`. |
| G-R0-CURRENT-BLOCKERS | hard_gate | partially_resolved | P-U44-MAIN-GREEN; P-L1-UITEST | U44 hard gate is fixed; visual L3 findings still require human review. |

### Still Open / Not Resolved

- Superseded: L3 human verdict was not run at 2026-06-27 pre-human stage; 2026-06-28 R3 now records 磊哥 `PASS_WITH_NOTES`.
- R2b white-edge pixel threshold is not formalized; checker result is `WARN`, not `PASS`.
- Reduce Motion has local/unit policy coverage but no simulator accessibility screenshot in this package.
- Full mobile/true-device proof is absent.
- Runtime/voice/model readiness is absent.

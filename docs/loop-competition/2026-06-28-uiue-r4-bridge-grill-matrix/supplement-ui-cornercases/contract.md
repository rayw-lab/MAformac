# UIUE R4 Bridge Supplemental Grill Contract - UI Corner Cases

- Date: 2026-06-28
- Parent matrix: `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r4-bridge-grill-matrix/final-grill-matrix.md`
- Supplemental IDs: `C31-C50`
- Mode: fixed blind-set / six-persona grill matrix
- Output language: Chinese
- Proof class: planning / audit checklist only

## Objective

Supplement the R4 bridge grill matrix with UIUE interaction and stage-corner cases that were under-specified by the first 30-item matrix.

The first matrix covered bridge authority, proof class, result/snapshot/readback, R4/R5 split, and mainline route discipline. This supplement focuses on whether those contracts are concrete enough to explain real UIUE surfaces:

- zone topology and per-zone ownership.
- cross-zone animation and attention sequencing.
- top context capsule / vehicle-style switching driven by endpoint state.
- long-press thinking and演绎控制台 route.
- touch, drag, scroll, overlay, and sheet gesture arbitration.
- reduce motion, accessibility, z-order, and evidence capture.
- macro / force-context / reset lifecycles.

## Non-Goals

- Do not implement Swift, assets, tests, scripts, checkers, or OpenSpec changes.
- Do not re-score `C01-C30`.
- Do not close `8.C2`.
- Do not claim V-PASS, mobile pass, true-device pass, runtime-ready, voice-ready, model-ready, golden-ready, endpoint-ready, or A-2 complete.
- Do not treat UI animation proof as runtime proof.
- Do not let presentation details silently expand the R4 bridge schema beyond MAformac-owned contracts.

## Source Pool

Reviewers may read these files:

- `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r4-bridge-grill-matrix/final-grill-matrix.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r4-bridge-grill-matrix/supplement-ui-cornercases/deductive-gap-analysis.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/grill-checklist/uiue-grill-定档-2026-06-25.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/grill-checklist/uiue-landing-matrix-2026-06-25.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/uiue-storyboard-grill-decisions.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r0-r2-grill-burndown-2026-06-27.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-27-uiue-r0-r2-grill-matrix/final-grill-matrix.md`
- `/Users/wanglei/workspace/MAformac-uiue/Core/Presentation/PresentationSnapshot.swift`
- `/Users/wanglei/workspace/MAformac-uiue/Core/Presentation/PresentationReducedMotionPolicy.swift`
- `/Users/wanglei/workspace/MAformac-uiue/Core/Presentation/StateCellInteractionPolicy.swift`
- `/Users/wanglei/workspace/MAformac-uiue/App/ContentView.swift`
- `/Users/wanglei/workspace/MAformac-uiue/App/ContextCapsule.swift`
- `/Users/wanglei/workspace/MAformac-uiue/App/DemoControlPanel.swift`
- `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/define-runtime-presentation-bridge/design.md`
- `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/define-runtime-presentation-bridge/specs/ui-presentation/spec.md`

If code and older docs disagree, use live code as current implementation truth and docs/OpenSpec as intended contract truth. Mark the mismatch rather than smoothing it over.

## Round Structure

Round 01 blind reviewers:

- `RED`: failure auditor, fake-green and proof-class hunter.
- `GREEN`: implementation coordinator, owner/test/sequence reviewer.
- `BLUE`: HMI and interaction reviewer.

Round 02 blind reviewers:

- `PURPLE`: systems architect, SSOT and contract-boundary reviewer.
- `ORANGE`: test and harness engineer.
- `BLACK`: skeptical product / ontology judge.

Round 02 reviewers must not read Round 01 outputs or judge files.

## Reviewer Output Contract

Each reviewer must write one Chinese Markdown file to its assigned path.

Each reviewer file must include:

- `## Persona`
- `## Scope Read`
- `## Keep`
- `## Delete`
- `## Merge`
- `## Rewrite`
- `## Missing Risks`
- `## Scores`
- `## Candidate Notes`
- `## Residual Risk`

`## Scores` and `## Candidate Notes` must both cover `C31-C50`.

Score scale:

- `5`: essential R4 supplemental grill item.
- `4`: strong, should keep.
- `3`: useful but needs rewrite or merge.
- `2`: weak, redundant, or too broad.
- `1`: delete unless no better coverage exists.

## Final Output

The controller must write:

- `round-01/judge.md`
- `round-02/judge.md`
- `final-supplement-matrix.md`
- parent `../final-grill-matrix-v2.md`, combining `C01-C30` and accepted supplemental `C31-C50`.

## Controller Verification

Before closeout, verify:

- Six supplemental reviewer markdown files exist.
- Each reviewer file contains `C31-C50`.
- `final-supplement-matrix.md` contains exactly 20 supplemental rows unless a candidate is explicitly dropped with rationale.
- `final-grill-matrix-v2.md` contains the original 30 rows plus the final supplemental rows.
- No final artifact claims V-PASS, mobile, true-device, runtime-ready, voice-ready, model-ready, golden-ready, endpoint-ready, or `8.C2` closure.


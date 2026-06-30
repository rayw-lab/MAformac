# UIUE R4 Bridge Grill Matrix Loop Competition Contract

- Date: 2026-06-28
- Repo: `/Users/wanglei/workspace/MAformac-uiue`
- Branch observed by controller: `uiue/phase4-default-scope-presentation`
- Mainline repo observed by controller: `/Users/wanglei/workspace/MAformac`
- Mode: fixed blind-set / six-persona grill matrix
- Output language: Chinese
- Proof class: planning / audit checklist only; no implementation proof

## Objective

Create a high-quality 30-item R4 bridge grill checklist for the UIUE -> mainline Runtime-Presentation bridge transition.

The checklist must pressure-test R4 as a bridge node between:

- R1 interaction and action integrity.
- R2/R2b layout, capsule, orb, and evidence discipline.
- R3 8.C2 visual acceptance evidence and notes.
- R4 bridge contract and mainline co-authorship.
- R5 runtime / voice / model split.
- Mainline post-C6 roadmap, runtime backend, C5 retrain, C6 acceptance, demo-golden, and UIUE integration sequencing.

## Non-Goals

- Do not implement Swift, assets, scripts, tests, or OpenSpec changes.
- Do not edit R3 visual evidence, 8.C2 tasks, or existing R0-R2B burndown files.
- Do not close `8.C2`.
- Do not claim V-PASS, mobile pass, true-device pass, runtime-ready, voice-ready, model-ready, golden-ready, endpoint-ready, or A-2 complete.
- Do not create a second bridge change in mainline.
- Do not treat Liquid4All or any external H5/FastAPI bridge as authority.

## Authority And Source Pool

Reviewers may read these files, and should cite file paths when a point depends on repo evidence:

- `/Users/wanglei/workspace/MAformac-uiue/docs/uiue-roadmap-2026-06-27-post-8c2-baseline.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/CURRENT.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/grill-checklist/uiue-runtime-bridge-decisions-2026-06-25.md`
- `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/define-runtime-presentation-bridge/proposal.md`
- `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/define-runtime-presentation-bridge/design.md`
- `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/define-runtime-presentation-bridge/tasks.md`
- `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/define-runtime-presentation-bridge/specs/ui-presentation/spec.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-27-uiue-r0-r2-grill-matrix/final-grill-matrix.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r0-r2-grill-burndown-2026-06-27.md`
- `/Users/wanglei/workspace/MAformac/docs/CURRENT.md`
- `/Users/wanglei/workspace/MAformac/docs/README.md`
- `/Users/wanglei/workspace/MAformac/docs/roadmaps/`
- `/Users/wanglei/workspace/MAformac/openspec/changes/`

If files disagree, use this precedence:

1. Live repo files and OpenSpec under the target repo.
2. Dated roadmaps / closeouts / receipts.
3. Subagent prose and prior chat context.

Known live tension to pressure-test: UIUE `docs/CURRENT.md` says `define-runtime-presentation-bridge` is accepted for mock visual consumption with mainline co-author review pending; mainline `docs/CURRENT.md` still routes post-C6 work toward proposing or accepting a thin bridge carrier and still lists runtime/backend/UIUE/voice/golden work as deferred. The grill should expose this as a coordination risk, not silently smooth it over.

## Fixed Blind Candidates

All reviewers must evaluate exactly the 30 candidates in `candidates-blind.md`.

Candidates are question-only. Reviewers must not assume the controller's intended priority or final recommendation.

## Round Structure

Round 01 blind reviewers:

- `RED`: failure auditor, proof-class and overclaim hunter.
- `GREEN`: implementation coordinator, sequencing and ownership reviewer.
- `BLUE`: HMI / presentation reviewer, user-visible and evidence-shape reviewer.

Round 02 blind reviewers:

- `PURPLE`: systems architect, cross-repo contract and SSOT reviewer.
- `ORANGE`: test and harness engineer, validation matrix reviewer.
- `BLACK`: skeptical product judge, roadmap and decision-quality reviewer.

Round 02 reviewers must remain blind to Round 01 reviewer outputs. The controller may read Round 01 outputs to write `round-01/judge.md`, but must not feed those conclusions into Round 02 prompts.

## Required Reviewer Output

Each reviewer must write one Chinese Markdown file to its assigned path.

Each reviewer file must include these sections:

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

`## Scores` must include exactly one row for every candidate `C01` through `C30`.

Score scale:

- `5`: essential hard grill item.
- `4`: strong, should keep.
- `3`: useful but needs rewrite or merge.
- `2`: weak, redundant, or too broad.
- `1`: delete unless no better coverage exists.

`## Candidate Notes` must also cover every candidate `C01` through `C30`, even if the note is short.

## Final Matrix Requirements

The controller must produce `final-grill-matrix.md` with exactly 30 final rows.

Columns:

- `ID`
- `Stage`
- `Grill question`
- `RED`
- `GREEN`
- `BLUE`
- `PURPLE`
- `ORANGE`
- `BLACK`
- `Avg`
- `Priority`
- `Route`
- `Action`
- `Recommendation`

Priority vocabulary:

- `P0`: must resolve before R4 exit.
- `P1`: should resolve during R4 before R5 active implementation.
- `P2`: track or defer with explicit owner.

Route vocabulary:

- `R4-contract`
- `R4-mainline-coauthor`
- `R4-evidence`
- `R4-test-harness`
- `R5-runtime`
- `R5-voice`
- `R5-model`
- `Mainline-roadmap`

Action vocabulary:

- `keep`
- `rewrite`
- `merge`
- `defer`

Final recommendations must be actionable and must preserve proof-class boundaries.

## Controller Verification

Before closeout, the controller must mechanically verify:

- Six reviewer markdown files exist.
- Each reviewer file contains `C01` through `C30`.
- Final matrix contains exactly 30 final candidate rows.
- No final file claims V-PASS, mobile pass, true-device pass, runtime-ready, voice-ready, model-ready, golden-ready, endpoint-ready, or `8.C2` closure.


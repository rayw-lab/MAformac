# Phase 0 Materialization Index

## Purpose

This folder holds the first seven Phase 0 materialization skeletons accepted after the 24-question loop competition.

These files are not implementation, not OpenSpec archive, and not permission to start retrain, real evaluation, endpoint-ready claims, demo-golden-run, voice, or UIUE merge.

## Source Of Decision

- Acceptance archive: `docs/loop-competition/2026-06-24-phase0-grill/acceptance-archive.md`
- Final synthesis: `docs/loop-competition/2026-06-24-phase0-grill/final-list.md`
- Grill SSOT: `docs/grill-tournament/grill-decisions-master.md`
- A2 post-roadmap input: `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md`

## Execution Order

| Order | Candidate | File | Purpose |
|---:|---|---|---|
| 1 | C02 + C01 | `c02-authority-matrix.schema.yaml` | Stop dual-SSOT drift and classify roadmap/research/OpenSpec/UIUE artifacts. |
| 2 | C03 | `c03-full-demo-artifact-matrix.schema.yaml` | Record full/demo derivation, generated proof, and `demo subset_of full` check. |
| 3 | C04 | `c04-archived-spec-disposition.schema.yaml` | Decide per Requirement/Scenario disposition for all archived specs. |
| 4 | C05 | `c05-pocock-stage-matrix.schema.yaml` | Block premature retrain/apply via stage and `forbidden_next_action`. |
| 5 | C07 | `c07-decision-lifecycle-manifest.schema.yaml` | Mark touched D1-D37/MASTER decisions without reopening all decisions. |
| 6 | C06 | `c06-runtime-outcome-enum-skeleton.schema.yaml` | Define top-level runtime/outcome/refusal/readback enum frame with placeholders. |
| 7 | C24 | `c24-status-vocabulary-graph.schema.yaml` | Define directed status vocabulary skeleton and forbidden claim implications. |

## Boundaries

- Put governance and route-control skeletons under `docs/project/phase0/`, not `contracts/`.
- Use skeleton fields and placeholders here; concrete values belong in later OpenSpec proposal/tasks or dedicated manifests.
- C06 and C24 must remain skeletons until C09/C10/C13-C22 settle downstream value domains, thresholds, endpoint evidence, and golden-run IDs.
- UIUE visual work remains outside mainline blockers unless it touches state/C3-C6/golden contracts.
- Filled Markdown manifests in this folder must include status/authority/retire metadata; they are route-control artifacts, not permanent SSOT.

## Execution Plans

- `docs/superpowers/plans/2026-06-24-phase0-d1-d10-openspec-gates.md` is the current implementation plan for converting D1-D10 and stop-the-train gates into OpenSpec-ready design/tasks. It is not a source of truth and must be retired or superseded after closeout.
- `docs/superpowers/plans/2026-06-24-phase0-d1-d10-openspec-gates-audit.md` is a same-vendor Codex pre-check record, not the R-L17 heterogeneous deframing review.
- Baseline status: accepted as baseline with open items, not final baseline. D1-D10 user decisions are accepted; R-L17 heterogeneous deframing, OpenSpec proposal acceptance, physical evidence gates, and UIUE worktree pinning remain visible blockers for execution or readiness claims.

## D1-D10 Gate Pack

- `d1-d10-lora-zero-failure-decision-pack.md` lists the accepted D1-D9 plus D10 `already_state/state-noop` user verdicts.
- `d1-d10-fast-pick-verdict-2026-06-24.md` archives the fast-pick table, cross-decision discipline, default-scope constraints, and extra stop-the-train gates used to clear the D1-D10 pending gate.
- `phase0-d1-d10-user-decision-record.md` is the only local record for user verdict status. Its `pending_user_decision` list is currently empty.
- `stop-the-train-openspec-carrier-map.md` preserves the original first-tier R-L09/R-L02/R-L03/R-L05/R-L04/R-L07/R-L17/R-L11 rows and maps them into OpenSpec draft carriers.
- `r-l17-human-review-evidence/` contains R-L17 deframing evidence templates. R-L17 remains unsigned until G1-G5 pass; same-vendor Codex/Claude reviews are pre-check only.
- `c5-recovery-roadmap-disposition.md` records which roadmaps are historical versus live carriers.
- `phase0-d1-d10-closeout.md` records current closeout status; it is accepted for D1-D10 user decisions but still partial until heterogeneous review and OpenSpec carriers are accepted.
- `phase0-d1-d10-cascade-audit-codex-2026-06-24.md` records the Codex same-vendor cascade pre-check and main-thread absorption.
- `rebuild-c6-documentation-absorption-closeout-2026-06-24.md` records the documentation-only closeout for `rebuild-c6-four-layer-bench`. It is approved for human OpenSpec propose review, not apply/implementation.
- `r-l17-human-review-evidence/route-deframing-prep-2026-06-24.md` prepares R-L17 route deframing and the heterogeneous judge prompt. It is not route signoff.

## Demo Default Scope Gate Pack

- `docs/grill-tournament/demo-default-scope-grill-decisions-2026-06-24.md` records the accepted G01-G28 default-scope grill decisions.
- Scope: non-UIUE mainline C2/C3/C5/C6/readback/demo-scenario semantics. G28 is retained as a UIUE merge check only, not a mainline blocker unless state/C3-C6/golden contracts conflict.
- This pack is separate from D1-D10. It has become the active OpenSpec carrier `openspec/changes/define-demo-default-scope/` and is accepted for apply. It still blocks retrain-c5/rebuild-c6 acceptance until the default_scope semantics are physically implemented and verified.
- Phase -1 closeout: `phase-minus-one-default-scope-closeout.md`.
- Apply plan: `docs/superpowers/plans/2026-06-24-default-scope-apply.md`. This is a Superpowers implementation plan after Phase -1 closeout, not a Phase 0 route-control artifact. It is governed by Phase 0/G01-G28 decisions and retires after default-scope apply closeout.
- Apply-plan audit: `default-scope-apply-plan-audit-codex-2026-06-24.md` records the Codex same-vendor pre-check (`CLEAR_WITH_FIXES`) and absorbed fixes. It does not close R-L17.
- UIUE worktree pinning: external worktree `/Users/wanglei/workspace/MAformac-uiue`, current recorded HEAD `17f2af1` as of 2026-06-24. This remains an unverified external reference; reconfirm current UIUE files before citing UIUE file:line evidence.

## Current State

- Status: skeletons created; D1-D10 route-control pack accepted by user verdict; default-scope G01-G28 decisions accepted and materialized as an active OpenSpec carrier; default-scope apply is authorized, same-vendor plan audit is absorbed, but physical implementation has not started.
- Next step: execute `docs/superpowers/plans/2026-06-24-default-scope-apply.md`. Do not start retrain-c5, rebuild-c6 acceptance, demo-golden-run, voice, or UIUE merge before the physical default-scope apply gates pass.

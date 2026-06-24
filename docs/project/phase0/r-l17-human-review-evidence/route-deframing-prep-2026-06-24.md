---
status: route_deframing_prep_not_signoff
artifact_kind: r_l17_route_deframing_prep
authority: preparation_receipt_not_pass
review_lane: human_owner_plus_heterogeneous_judge
route_deframing_verdict: pending
candidate_signoff_verdict: unsigned
proof_class:
  - local
  - local_static_teardown
retire_trigger: "Retire after R7 final route deframing signoff is completed or this prep is superseded."
expires: "2026-07-15"
---

# R-L17 Route Deframing Prep

## Purpose

Prepare the R-L17 route-deframing review after `rebuild-c6-four-layer-bench` documentation absorption.

This file is not R-L17 signoff. It does not close route deframing, candidate signoff, C6 acceptance, C5 training, golden-run, voice, endpoint readiness, UIUE merge, or V/S/U-PASS.

## Current Route Question

Should MAformac proceed from documentation absorption into `rebuild-c6-four-layer-bench` construction first, with `retrain-c5-lora-d-domain` and candidate comparison kept downstream?

Current prepared answer: yes, pending R-L17 route signoff and OpenSpec propose acceptance.

The route remains:

```text
rebuild-c6 construction -> retrain-c5 candidate -> rebuild-c6 candidate comparison
```

## Evidence Available For Human Review

| Evidence | Path | Status |
|---|---|---|
| OpenSpec documentation closeout | `docs/project/phase0/rebuild-c6-documentation-absorption-closeout-2026-06-24.md` | ready for human propose review |
| Non-UIUE action list | `docs/project/phase0/non-uiue-pre-code-action-list-2026-06-24.md` | route-control input |
| Paper absorption ledger | `docs/project/phase0/paper-to-skill-gate-absorption-ledger-2026-06-24.md` | Q2 rows reviewed; partial C5 owners retained |
| Rebuild-C6 grill ledger | `docs/project/phase0/rebuild-c6-precode-grill-ledger-2026-06-24.md` | Q3/Q4 rows reviewed; human review PASS |
| OpenSpec carrier | `openspec/changes/rebuild-c6-four-layer-bench/` | 4/4 artifacts complete; strict validation pass |
| UIUE Phase4A dispatch | `/Users/wanglei/workspace/MAformac-uiue/docs/dispatches/2026-06-24-phase4a-cc-window-dispatch.md` | no current blocker; see impact check below |
| Heterogeneous deframing audit | `docs/project/phase0/r-l17-human-review-evidence/heterogeneous-deframing-audit-glm-2026-06-25.md` | PASS input received; not human-owner signoff |

## G1-G5 Current State

| Gate | Current State | Evidence | Verdict |
|---|---|---|---|
| G1 D1-D10 verdicts accepted | Accepted. | `docs/project/phase0/phase0-d1-d10-user-decision-record.md` and `docs/project/phase0/phase0-d1-d10-closeout.md` | ready |
| G2 R1-R7 artifacts complete | Not complete. R1-R7 are mostly evidence stubs. | `docs/project/phase0/r-l17-human-review-evidence/R1-first-50-sample-read.md` through `R7-final-route-deframing-signoff.md` | pending |
| G3 heterogeneous deframing audit exists | GLM PASS input received. Human owner must decide whether this satisfies G3 or whether another non-Claude-family judge is required. | `heterogeneous-deframing-audit-glm-2026-06-25.md` | received_pending_human_owner |
| G4 consistent PASS did not bypass human review | Guarded in docs; not yet human signed. | `R7-final-route-deframing-signoff.md` | pending |
| G5 disagreements escalated to human owner | Procedure exists; no final review yet. | `README.md` and `R7-final-route-deframing-signoff.md` | pending |

## Required Next Inputs For R7

Before R7 can be signed, collect:

1. Human-owner review notes for the documentation closeout and Q4.15 row-level pointers.
2. Human-owner decision on whether the GLM heterogeneous PASS satisfies G3 or whether another non-Claude-family judge is required. Same-vendor Codex/Claude pre-checks remain useful but insufficient.
3. A decision on whether R1-R6 must be fully populated before route signoff, or whether route signoff can explicitly limit itself to "documentation-to-construction route" while leaving candidate signoff unsigned.
4. Any disagreement table from the heterogeneous judge, with human-owner resolution.
5. Confirmation that route signoff unlocks only rebuild-C6 construction, not C6 acceptance, retrain-C5, candidate comparison, golden-run, voice, endpoint readiness, UIUE merge, or V/S/U-PASS.

## UIUE Phase4A Impact Check

Source checked: `/Users/wanglei/workspace/MAformac-uiue/docs/dispatches/2026-06-24-phase4a-cc-window-dispatch.md`.

Verdict: no current decision change for R-L17 route deframing.

Why:

- Phase4A is an isolated UIUE worktree dispatch.
- It targets 10-family card scope presentation summary UI.
- It allows `App/`, `Core/Presentation/`, `openspec/changes/ui-presentation/`, and `docs/`.
- It explicitly forbids `Core/State/`, `contracts/`, and `generated/`, which are the relevant shared contract/state surfaces for rebuild-C6 route decisions.
- It has its own UIUE validation and PR/GPT Pro audit path.

Intersection to recheck later:

- If Phase4A changes scope-origin presentation metadata consumed by C6 receipts or readback evidence.
- If it changes golden-run IDs, UIUE card family IDs that become C6 output requirements, or shared state/C3-C6 contracts.
- If UIUE PR status is cited as current truth. Live git/PR state must be reconfirmed then.

## Proposed Heterogeneous Judge Prompt

Use a non-Claude-family judge. The judge should assume the route is wrong until proven otherwise.

Current status: one GLM audit has been received and archived in `heterogeneous-deframing-audit-glm-2026-06-25.md`. Reuse the prompt below only if the human owner asks for another heterogeneous judge.

```text
You are an R-L17 heterogeneous deframing judge for MAformac.

Read:
- /Users/wanglei/workspace/MAformac/docs/project/phase0/rebuild-c6-documentation-absorption-closeout-2026-06-24.md
- /Users/wanglei/workspace/MAformac/docs/project/phase0/non-uiue-pre-code-action-list-2026-06-24.md
- /Users/wanglei/workspace/MAformac/docs/project/phase0/paper-to-skill-gate-absorption-ledger-2026-06-24.md
- /Users/wanglei/workspace/MAformac/docs/project/phase0/rebuild-c6-precode-grill-ledger-2026-06-24.md
- /Users/wanglei/workspace/MAformac/openspec/changes/rebuild-c6-four-layer-bench/proposal.md
- /Users/wanglei/workspace/MAformac/openspec/changes/rebuild-c6-four-layer-bench/design.md
- /Users/wanglei/workspace/MAformac/openspec/changes/rebuild-c6-four-layer-bench/tasks.md
- /Users/wanglei/workspace/MAformac/openspec/changes/rebuild-c6-four-layer-bench/specs/vehicle-tool-bench/spec.md

Question:
Does the route "rebuild-c6 construction first, retrain-c5 second, candidate comparison third" still hold?

Check:
1. Any stale dependency that still makes retrain-C5 candidate a construction prerequisite.
2. Any BehaviorClass SSOT split across C5/C6/apply.
3. Any static teardown proof promoted into C6 acceptance/model-quality proof.
4. Any accidental authorization of training, C6 acceptance, D-domain base recalibration, golden-run, voice, endpoint readiness, UIUE merge, or R-L17 closure.
5. Any UIUE Phase4A dispatch intersection that should block route signoff.

Output:
- verdict: PASS / PASS_WITH_FIXES / BLOCK
- blocking findings with file:line evidence
- non-blocking risks
- what the human owner must decide
```

## Forbidden Claims

- Do not mark `route_deframing_verdict` signed from this prep file.
- Do not mark `candidate_signoff_verdict` signed.
- Do not treat OpenSpec validation as R-L17 pass.
- Do not treat UIUE Phase4A progress as mainline merge proof.
- Do not start training, C6 acceptance, base recalibration, golden-run, voice, endpoint readiness, or UIUE merge.

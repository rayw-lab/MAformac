# R-L17 Heterogeneous Deframing Audit Dispatch

## 0. Routing Metadata

- **TO**: Non-Claude-family heterogeneous judge. Prefer non-GPT-family if available; GPT Pro is acceptable if it is the available non-Claude-family reviewer.
- **FROM**: MAformac mainline controller.
- **MODE / MODEL**: Read-only deframing audit.
- **PRIORITY**: P0 route-control blocker.
- **Deliverable**: A route-deframing verdict for whether `rebuild-c6-four-layer-bench` construction can proceed before `retrain-c5-lora-d-domain`, with blocking findings grounded in file:line evidence.

## 1. Cold-Start Background

MAformac is an offline macOS/iOS cockpit-control demo assistant. It is not production vehicle control.

Current route under review:

```text
rebuild-c6 construction -> retrain-c5 candidate -> rebuild-c6 candidate comparison
```

This dispatch exists because R-L17 requires heterogeneous deframing before high-stakes C5/C6 route claims can move. Same-vendor Codex/Claude checks are useful pre-checks only and do not count as R-L17 pass.

## 2. Task

Read the files below and challenge the route. Assume the route is wrong until the evidence proves otherwise.

Question:

Can MAformac proceed from documentation absorption into `rebuild-c6-four-layer-bench` construction first, while keeping `retrain-c5-lora-d-domain` and candidate comparison downstream?

Required checks:

1. Look for any stale dependency that still makes retrain-C5 candidate availability a construction prerequisite.
2. Look for any BehaviorClass SSOT split across C5 `data_class_observed_count`, C6 `C6Bucket` / selectors, and apply/execution `no_effect_reason`.
3. Look for any static teardown or OpenSpec validation proof promoted into C6 acceptance, model-quality proof, endpoint readiness, demo readiness, or V-PASS.
4. Look for accidental authorization of training, C6 acceptance, D-domain base recalibration, golden-run, voice, endpoint readiness, UIUE merge, or R-L17 closure.
5. Check whether UIUE Phase4A dispatch creates a blocking intersection with this route.
6. Identify any missing evidence that must be resolved before the human owner signs R7.

## 3. Prerequisite Check

Run only read-only/static commands:

```bash
cd /Users/wanglei/workspace/MAformac
git status --short --branch
openspec status --change rebuild-c6-four-layer-bench
openspec validate rebuild-c6-four-layer-bench --strict
openspec validate --all --strict
git diff --check
```

Do not run Swift tests, `make verify`, model evaluation, training, C6 bench acceptance, D-domain base recalibration, golden-run, voice, or endpoint checks.

## 4. Boundaries

Forbidden actions:

- Do not edit files.
- Do not sign R-L17.
- Do not mark `route_deframing_verdict` signed.
- Do not mark `candidate_signoff_verdict` signed.
- Do not treat OpenSpec validation as C6 acceptance or model-quality proof.
- Do not treat UIUE Phase4A progress as mainline merge proof.
- Do not run training, C6 acceptance, D-domain base recalibration, golden-run, voice, endpoint readiness checks, UIUE merge, or model evaluation.

Proof-class discipline:

- OpenSpec validation is `local` structural proof only.
- Paper/code teardown is `local_static_teardown` only.
- No local/static proof can be promoted to C6 acceptance, endpoint readiness, mobile/true-device proof, V-PASS, S-PASS, or U-PASS.

## 5. Required Files

Read these first:

1. `/Users/wanglei/workspace/MAformac/docs/project/phase0/rebuild-c6-documentation-absorption-closeout-2026-06-24.md`
2. `/Users/wanglei/workspace/MAformac/docs/project/phase0/r-l17-human-review-evidence/route-deframing-prep-2026-06-24.md`
3. `/Users/wanglei/workspace/MAformac/docs/project/phase0/non-uiue-pre-code-action-list-2026-06-24.md`
4. `/Users/wanglei/workspace/MAformac/docs/project/phase0/paper-to-skill-gate-absorption-ledger-2026-06-24.md`
5. `/Users/wanglei/workspace/MAformac/docs/project/phase0/rebuild-c6-precode-grill-ledger-2026-06-24.md`
6. `/Users/wanglei/workspace/MAformac/openspec/changes/rebuild-c6-four-layer-bench/proposal.md`
7. `/Users/wanglei/workspace/MAformac/openspec/changes/rebuild-c6-four-layer-bench/design.md`
8. `/Users/wanglei/workspace/MAformac/openspec/changes/rebuild-c6-four-layer-bench/tasks.md`
9. `/Users/wanglei/workspace/MAformac/openspec/changes/rebuild-c6-four-layer-bench/specs/vehicle-tool-bench/spec.md`
10. `/Users/wanglei/workspace/MAformac/docs/project/phase0/r-l17-human-review-evidence/R7-final-route-deframing-signoff.md`
11. `/Users/wanglei/workspace/MAformac-uiue/docs/dispatches/2026-06-24-phase4a-cc-window-dispatch.md`

## 6. Acceptance Criteria

Your output must include:

- `status`: `PASS` / `PASS_WITH_FIXES` / `BLOCK`
- `route_verdict`: one of:
  - `route_can_proceed_to_human_R7`
  - `route_needs_nonblocking_fixes_before_R7`
  - `route_blocked`
- `evidence_table`: file:line evidence for every major claim.
- `blocking_findings`: ordered by severity, with exact file:line references.
- `nonblocking_risks`: including any UIUE Phase4A intersection.
- `human_owner_decisions_needed`: exact items the human owner must decide in R7.
- `forbidden_actions_confirmed_not_run`: yes/no plus commands actually run.

## 7. Output Format

Use this shape:

```text
status: PASS | PASS_WITH_FIXES | BLOCK
route_verdict: ...

evidence_table:
| Claim | Evidence | Notes |
|---|---|---|

blocking_findings:
1. ...

nonblocking_risks:
1. ...

human_owner_decisions_needed:
1. ...

forbidden_actions_confirmed_not_run: yes/no
commands_run:
- ...

final_note:
...
```

If blocked, state the smallest file/path/evidence needed to unblock. Do not propose training, C6 acceptance, base recalibration, golden-run, voice, or UIUE merge as an unblocker.

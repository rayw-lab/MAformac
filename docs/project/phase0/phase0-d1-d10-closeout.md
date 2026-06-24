---
status: accepted_user_decisions_partial_closeout
artifact_kind: phase0_closeout
authority: closeout_record_not_ssot
retire_trigger: "Retire after D1-D10 are accepted/rejected by user verdict and OpenSpec carriers are either accepted, superseded, or archived."
expires: "2026-07-15"
---

# Phase 0 D1-D10 Closeout

## Verdict

Partial closeout with D1-D10 user decisions accepted. The baseline cascade has been materialized enough to prevent old-roadmap and task-checkbox drift, and the D1-D10 user-decision gate is no longer pending. `define-demo-default-scope` Phase -1 carrier is accepted for apply, and its apply-plan same-vendor pre-check has been absorbed. The remaining blockers are R-L17 heterogeneous deframing, non-default-scope OpenSpec proposal acceptance, physical evidence gates, and later implementation/validation.

Closeout hard rule: if `phase0-d1-d10-user-decision-record.md` later regains a non-empty `pending_user_decision` list or any verdict row contains `| pending |`, this file must revert to a pending closeout status. A passing `openspec validate --all --strict` result is necessary structural evidence only; it is not permission to mark Phase 0 complete.

## Completed In This Pass

- Added or updated Phase 0 status/authority/retire metadata for route-control Markdown artifacts.
- Added historical banners and historical-instruction markers to:
  - `docs/roadmap-2026-06-20-from-c6-done.md`
  - `docs/c5-recovery-2026-06-22/roadmap.md`
- Registered `docs/project/phase0/` and `docs/superpowers/plans/` in the doc map and constitution.
- Routed Architecture Decisions into:
  - `openspec/changes/retrain-c5-lora-d-domain/design.md`
  - `openspec/changes/rebuild-c6-four-layer-bench/design.md`
- Kept executable/evidence work in `tasks.md`, with AD references instead of ADs hidden only in checkboxes.
- Preserved the original first-tier stop-the-train rows R-L09/R-L02/R-L03/R-L05/R-L04/R-L07/R-L17/R-L11.
- Recorded Codex subagent audit as same-vendor pre-check only, not R-L17 heterogeneous deframing review.

## Open Items

| Item | Status | Blocking effect |
|---|---|---|
| D1-D10 user verdicts | accepted | Unblocks Phase 0 decision pending gate only; does not authorize execution. |
| R-L17 G1 D1-D10 user verdicts | accepted | Satisfies only the user-verdict prerequisite. |
| R-L17 G2 R1-R7 evidence files | pending | Blocks R-L17 high-stakes signoff. Evidence stubs live under `r-l17-human-review-evidence/`. |
| R-L17 G3 heterogeneous deframing audit | pending | Blocks R-L17 high-stakes signoff; Codex/Claude same-vendor pre-check is not enough. |
| R-L17 G4 consistent-PASS deframing | pending | Blocks route signoff if four-model agreement bypasses human-owner review. |
| R-L17 G5 disagreement escalation | pending | Blocks route signoff if any judge disagreement is resolved by majority vote rather than human-owner review. |
| Filled manifests from the seven skeleton schemas | pending | Blocks full Phase 0 materialization claim. |
| OpenSpec proposal acceptance | partial | `define-demo-default-scope` is accepted for apply; retrain-c5, rebuild-c6, golden-run, and R-L17-related acceptance remain pending and still block training/evaluation/readiness claims. |
| Default-scope apply plan | pre-check absorbed | `default-scope-apply-plan-audit-codex-2026-06-24.md`; physical implementation still not started. |

## Mechanical Gate Check

```bash
rg -n "\| pending \|" docs/project/phase0/phase0-d1-d10-user-decision-record.md && exit 65 || true
rg -n "pending_user_decision:" docs/project/phase0 openspec/changes/retrain-c5-lora-d-domain openspec/changes/rebuild-c6-four-layer-bench
```

If the first command finds any pending row, do not describe this closeout as accepted-user-decisions. Even with no pending rows, do not describe Phase 0 as complete until the other open items above are closed.

## Verification Ledger

Main-thread verification on 2026-06-24 after absorbing Codex cascade audit findings:

```bash
openspec validate retrain-c5-lora-d-domain --strict
openspec validate rebuild-c6-four-layer-bench --strict
openspec validate --all --strict
git diff --check
```

Result: pass. `openspec validate --all --strict` reported 13 passed, 0 failed; `git diff --check` produced no output.

## Commit Boundary

This closeout may be committed as a route-control baseline only. It must not be described as:

- R-L17 complete.
- Phase 0 fully complete.
- retrain-c5 apply-ready.
- rebuild-c6 apply-ready.
- model-quality, endpoint, demo, voice, or UIUE readiness.

---
status: draft_needs_human_propose
typed_status:
  lifecycle_status: draft_needs_human_propose
  c08_disposition: NEW_CHANGE
  previous_wait: none
  wait_resolution: {}
  next_status_recommendation: run_opsx_propose_and_obtain_human_review
  status_action_this_change: keep_draft_needs_human_propose
  propose_performed_this_change: false
  implementation_authorized_this_change: false
---

# Add V1 Active Authority Candidate

> DRAFT. This change creates the minimal, machine-readable, durable local authority candidate for the C6 measurement yardstick (T01). It implements the V1 work package from the closure registry (`contracts/closure-work-packages.v1.yaml` package_id=V1). It does **not** perform C6 acceptance, model-quality calibration, S9/S10 execution, or C5 retraining.

## Why

D-147 ratified the 32-pool decision set, including G2 wave closure for T01. The V1 package (`contracts/closure-work-packages.v1.yaml:419-434`) defines the C6 active authority as a hard-scope closure package with `immutable_digest` freshness policy. Before V1 can transition from `planned` to `ready`, the authority schema, candidate instance, source checker, entry/exit checkers, and candidate receipt must exist as dedicated files.

This change produces the V1 active authority candidate — the durable local artifact that future C6 acceptance, S10 verdict, and model-quality runs will reference as their measurement authority.

## What Changes

### New files (writable set)

| Path | Purpose |
|------|---------|
| `contracts/c6-active-authority/authority-schema.v1.json` | JSON Schema for the V1 authority document |
| `contracts/c6-active-authority/authority-subject.v1.schema.json` | Subject tuple schema for closure-package-exit-envelope consumption |
| `contracts/c6-active-authority/authority.v1.candidate.json` | The V1 authority candidate instance (status=CANDIDATE) |
| `Tools/C6ActiveAuthority/README.md` | Authority identity, mapping from D-147 T01 exact set to live source files |
| `scripts/check_c6_active_authority_candidate.py` | Source checker: validates authority schema, subject integrity, ratification refs, decision refs, subject values, and digest |
| `scripts/test_check_c6_active_authority_candidate.py` | Positive and negative regression tests for the checker |
| `closure/candidates/V1/V1.v1.candidate-receipt.json` | Candidate receipt with migration/fan-in instructions |
| `openspec/changes/add-v1-active-authority-candidate/proposal.md` | This proposal |
| `openspec/changes/add-v1-active-authority-candidate/design.md` | Design decisions |
| `openspec/changes/add-v1-active-authority-candidate/tasks.md` | Task checklist |
| `openspec/changes/add-v1-active-authority-candidate/specs/c6-active-authority/spec.md` | Behavior contract delta for capability `c6-active-authority` |

### No-touch

- `Makefile` — not modified
- `Tests/**` — not modified (existing tests unchanged)
- `Core/**` — not modified
- `contracts/closure-work-packages.v1.yaml` — not modified (V1 entry remains `planned`)
- `openspec/changes/rebuild-c6-four-layer-bench/**` — not modified
- Shared registry, canonical receipts — not modified

## Decision Sources

- `docs/commander-log/decisions.md` D-147 (pool32 ratification)
- `docs/commander-log/decisions.md` D-144 (G2 partial basis)
- `contracts/closure-work-packages.v1.yaml` V1 entry
- `docs/roadmap-2026-07-11-v6-closure-baseline.md` V1 row
- `openspec/changes/rebuild-c6-four-layer-bench/proposal.md` AD-C6-001 through AD-C6-016
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-11-ma14/reports/RATIFICATION-RECEIPT-pool32.md`

## Non-Goals

- No C6 acceptance, model-quality calibration, or model run
- No S9/S10 execution
- No C5 retraining or LoRA candidate
- No modification of existing OpenSpec carriers, specs, or registry entries
- No `baseline_activation` flip (remains `PENDING_CASCADE`)
- No `actionDemoProven` claim (remains 0/120)
- No operator-pass, V-PASS, or C6 acceptance claim

## Success Criteria

- `openspec validate add-v1-active-authority-candidate --strict` passes
- `openspec validate --all --strict` passes
- `python3 scripts/check_c6_active_authority_candidate.py contracts/c6-active-authority/authority.v1.candidate.json` exits 0
- `python3 scripts/test_check_c6_active_authority_candidate.py` exits 0
- All JSON schemas validate against their instances
- Git diff touches only the writable set

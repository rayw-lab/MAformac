## Context

S10 knife 1 for `matrix_id=4` failed with honest probe evidence (`refusal_no_available_tool`) while a worker incorrectly hand-patched `readbackProbePass=passed`. Root cause is proof-contract mismatch, not executor error. Run-root design [`PHASE2-S10-PROOF-CONTRACT-REPAIR-DESIGN.md`](../../../../Projects/agent-tmux-stack-research/runs/2026-07-17-s8-s9-successor-c-longrun/PHASE2-S10-PROOF-CONTRACT-REPAIR-DESIGN.md) and磊哥 `APPROVE_ALL` (2026-07-23) lock decisions **P-A** (BF-8 promotion basis) and **R-A** (scoped receipt).

Current checker (`Tools/checks/check_capability_matrix.py`) derives `actionDemoProven` from four basis keys plus probe proof only; requires full catalog receipt coverage (`:358-359`). Probe test harness uses `default_runtime` without product route assertions (`RuntimeActionReadbackProbeTests`).

## Goals / Non-Goals

**Goals:**

- Machine-checkable separation of **probe basis green** vs **`actionDemoProven` promotion**.
- Scoped probe receipts for single-cell knife slices (matrix_id=4).
- Product acceptance route + hard assertions for action readback probes.
- Three implementation slices (I1/I2/I3) with explicit gates before knife 1 re-authorization.

**Non-Goals:**

- FastPath expansion without separate ratification.
- Knife 1 retry, manual matrix patch, or `actionDemoProven>0` in this change.
- BF-8 ceremony execution, knife 2 utterance suite, row167/`close_ac`/rear-three scope.
- Real vehicle actions; mock state + readback only.

## Decisions

### D-001 — P-A: Fifth basis `bf8_promotion`

Add `actionDemoProven_basis.bf8_promotion` (name TBD in schema; stable in contracts):

```text
actionDemoProven :=
  mounted_or_approved_action.observed
  AND semantic_contract.observed
  AND state_readback_cell.observed
  AND readbackProbePass.observed (with valid probe proof)
  AND bf8_promotion.observed
```

- Default: `observed=false`, `status=pending_human_bf8` until BF-8 receipt binds subject SHA + matrix_id scope.
- Materialize sets `actionDemoProven=true` only when all five are observed with valid proof.
- Replaces implicit “four sources ⇒ proven” for S10 cells.

**Alternatives rejected:** manual latch file only (P-C) — lacks symmetry with other basis fields; splitting fields without fifth basis (P-B) — higher drift risk.

### D-002 — R-A: Scoped receipt v2.1

Extend `runtime_action_readback_receipt_v2` with optional:

```json
"scope": { "matrix_ids": [4], "knife": "s10_knife1" }
```

Checker rules:

- When `scope` present: coverage check uses `scope.matrix_ids` subset of catalog probes only.
- Materialize updates `readbackProbePass` only for scoped matrix IDs.
- Receipt without scope retains legacy full-catalog semantics (backward compatible).

### D-003 — Product acceptance route

Define `acceptanceRouteID` on probe cases (e.g. `product.frontstage.text.v1`):

- Harness MUST enter through the same frontstage text route used in demo behavior gates (`DemoNLURouter` / admission chain), not injection-only `DDomainToolPlanBackend`.
- `pathKind` values: `product_acceptance_route` | `diagnostic_default_runtime` (diagnostic never satisfies S10 knife pass).
- Tests MUST assert catalog expected delta/readback; writing receipt without assertions is insufficient.

**FastPath discipline:** expanding `FastPathIntentEngine` requires a separate OpenSpec change +磊哥 approval; this change MUST NOT include FastPath edits.

### D-004 — Implementation slices

| Slice | Owner focus | Gate |
|---|---|---|
| I1 | Schema + checker promotion basis | materialize: probe green, promotion false → `actionDemoProven=false` |
| I2 | Scoped receipt schema + checker | matrix 4 only update, no coverage mismatch |
| I3 | Acceptance route harness + assertions | probe FAIL on refusal; PASS on accepted 24→26 |

Knife 1 re-auth: commander only after I1+I2+I3 green on same `SUBJECT_SHA`.

## Risks / Trade-offs

| Risk | Mitigation |
|---|---|
| Fifth basis breaks existing materialize tests | Update fixtures in same slice; `verify-c1-matrix` as gate |
| Scoped receipts hide failing probes for other cells | Scope only on knife manifests; full catalog diagnostic job remains in CI |
| Acceptance route undefined while model chain offline | Document proof ceiling `local_unit`; route = frontstage+rules path available today, not LLM injection |
| Accidental FastPath scope creep | Explicit non-goal + code review gate on `FastPathIntentEngine` diffs |

## Migration Plan

1. Land I1+I2+I3 on feature branch; no `actionDemoProven` flip.
2. Regenerate matrix via `materialize` after probe green with scoped receipt.
3. Commander re-authorizes knife 1; run closeout checklist from GPT56 plan.
4. Rollback: revert change; matrix stays `conditional_pending` on readback probe.

## Open Questions

- Exact `acceptanceRouteID` registry location (contracts vs generated bundle).
- Whether BF-8 receipt lives in run-root only or also `contracts/governance/` machine file (recommend latter for checker).

# Rebuild-C6 Scoring Foundation Closeout - 2026-06-25

## Verdict

status: external-pass-with-absorbed-fixes
proof_class:
- local_static_contract
- local_unit
- local_receipt_consistency

optional_baseline_check:
- local_shape_no_model_baseline_unchanged

This is not C6 acceptance, not model-quality evaluation, not retrain-C5, not golden-run, not voice, not endpoint readiness, not UIUE merge, and not R-L17 candidate signoff.

External audit status: GPT Pro PASS_WITH_FIXES received; P0 empty; P1 fixes absorbed locally in follow-up commits.

## Scope

Implemented Long-run 1 scoring foundation:
- shared behavior taxonomy
- two-axis C6 reporting
- denominator selector shell
- apply descriptive write facts
- C6 replay consumption of applied writes
- dependency-write provenance
- readback split from model hard pass

Deferred to later long-runs:
- contract_bundle_fingerprint aggregation
- D-domain C6 JSONL shape migration
- Section 4 candidate comparison
- thresholds and base anchors

## Commits

| Commit | Purpose |
|---|---|
| 839c917 | Shared behavior taxonomy and C6 behavior class compatibility. |
| ae45962 | Two-axis C6 reporting for external layer and behavior class. |
| 0f3a850 | Denominator selector shell without thresholds or base anchors. |
| d96c163 | Apply/execution descriptive `StateWrite` facts. |
| 47b9300 | C6 consumption of applied writes, dependency provenance, and readback split. |

## Commands

| Command | Exit | Evidence |
|---|---:|---|
| `swift test --filter C6VehicleToolBenchTests` | 0 | `docs/project/phase0/rebuild-c6-scoring-foundation-evidence-excerpt-2026-06-25.md` |
| `swift test --filter ToolContractCompilerTests` | 0 | `docs/project/phase0/rebuild-c6-scoring-foundation-evidence-excerpt-2026-06-25.md` |
| `make verify-surface` | 0 | `docs/project/phase0/rebuild-c6-scoring-foundation-evidence-excerpt-2026-06-25.md` |
| `openspec validate rebuild-c6-four-layer-bench --strict` | 0 | `docs/project/phase0/rebuild-c6-scoring-foundation-evidence-excerpt-2026-06-25.md` |
| `openspec validate --all --strict` | 0 | `docs/project/phase0/rebuild-c6-scoring-foundation-evidence-excerpt-2026-06-25.md` |
| `git diff --check` | 0 | `docs/project/phase0/rebuild-c6-scoring-foundation-evidence-excerpt-2026-06-25.md` |

Tracked branch-source evidence excerpt: `docs/project/phase0/rebuild-c6-scoring-foundation-evidence-excerpt-2026-06-25.md`.

## GPT Pro Verdict Handling

verdict: PASS_WITH_FIXES
source: `docs/project/phase0/rebuild-c6-scoring-foundation-gptpro-audit-2026-06-25.md`

P0:
- none

P1:
- P1-1: Closeout evidence was not complete in branch source truth because it pointed only to ignored `Reports/.../VERIFY.md`.
- P1-2: Legacy thresholded `summary.status` could be mistaken for C6 acceptance.

absorption:
- P1-1: added tracked evidence excerpt with high-signal stdout snippets and exit codes for every L3 local gate.
- P1-2: changed `C6Summary.status` to `local_construction_report` and added a regression test proving it is not threshold-driven; `IrrelAccThreshold` remains a compatibility field only.

final_external_audit_status: external-pass-with-absorbed-fixes

## Subagent Audits

| Phase | Verdict | Residual Risk |
|---|---|---|
| Phase 1A | PASS | Audit covered taxonomy only; later phases still required. |
| Phase 1B | PASS after PASS_WITH_FIXES recheck | Initial fix was missing durable lesson; resolved before commit. |
| Phase 1C | PASS | Selector shell only; thresholds/base anchors remain deferred. |
| Phase 2 | PASS | Audit did not certify Phase 3 C6 consumption or any model/runtime acceptance. |
| Phase 3 | PASS | `C6GoldVerifier` still uses `.readback` for deterministic gold validation, not runtime model failure classes. |
| GPT Pro P1 absorption | PASS_WITH_FIXES before final staging | Content and code fixes passed; auditor required exact-path Git tracking for the evidence excerpt and GPT Pro report copy before final claim. |

## UIUE Impact

uiue_impact_check: not_triggered

Reason: diff from `6751be4942ebba079abb3e80c5e827c79fb43a77` to `47b9300` includes C6 scoring code/tests and apply evidence structs only. It does not edit `contracts/state-cells.yaml`, `generated/D_domain.tools.demo.json`, `contracts/c6-bench-cases.jsonl`, readback templates, or UI-visible state contracts.

## Residual Risk

- Current C6 JSONL rows may still lack explicit `behavior_class`; D-domain shape migration remains deferred.
- Legacy `IrrelAcc` and `IrrelAccThreshold` remain for compatibility but are not active four-layer acceptance gates and no longer drive `C6Summary.status`.
- Thresholds, base anchors, candidate comparison, and model-quality acceptance remain unauthorized.
- `local_shape_no_model_baseline_unchanged` means surface shape was checked as an unchanged-baseline guard only; D-domain C6 JSONL shape migration remains deferred.
- GPT Pro returned PASS_WITH_FIXES. P0 was empty. P1 fixes are absorbed in branch source truth and covered by command evidence.

---
retire_trigger: "Retire when superseded by archived OpenSpec specs or explicit user decision."
expires: "2026-08-15"
---

# Rebuild-C6 Identity Shape GPT Pro Absorption Ledger - 2026-06-25

## Verdict

status: external-pass-with-absorbed-fixes
audit_source: `docs/project/phase0/rebuild-c6-identity-shape-gptpro-audit-2026-06-25.md`
audited_pr: `https://github.com/rayw-lab/MAformac/pull/7`
audited_head: `f6b6a15d8d898f53f4fc76783c238da3d57aacfa`
audit_verdicts:
- round_1: `PASS_WITH_FIXES`
- round_2: `PASS_WITH_FIXES`

This ledger only covers Long-run 2 rebuild-C6 identity + behavior-shape local closeout. It is not C6 acceptance, not model-quality evaluation, not retrain-C5, not candidate comparison, not D-domain base recalibration, not golden-run, not voice or endpoint readiness, not UIUE merge, not R-L17 candidate signoff, and not V/S/U-PASS.

Post-closeout architecture absorption note: a later focused patch further tightened `contract_bundle_fingerprint` by exposing `component_versions` and including component versions in `bundle_hash`. That follow-up is tracked in `docs/project/phase0/post-c6-roadmap-gptpro-architecture-absorption-ledger-2026-06-25.md`; it does not upgrade this Long-run 2 proof class.

## Finding Classification

| ID | Severity | Source Lines | Disposition | Absorption |
|---|---|---:|---|---|
| P0 | P0 | audit lines 45-47 and 383-385 | none | No P0 was reported in either GPT Pro round. |
| P1-1 | P1 | audit lines 51-120 and 387-423 | absorbed | Added bidirectional no-call/`expect_no_call` checks in `scripts/check_c6_case_shape.py`; added Python negative tests; added Swift validation mismatch guard; made legacy resolver stop inferring no-call classes when `expectNoCall=false`. |
| P2-1 | P2 | audit lines 124-144 | absorbed | Downgraded string-returning `C6ContractBundleFingerprint.fingerprint(...)` helpers from public API to internal module helpers. |
| P2-2 | P2 | audit lines 147-166 and 427-441 | absorbed | Added typed fail-closed errors for duplicate component IDs, unexpected component IDs, and unsupported manifest versions; added Swift regression tests. Canonical record raw-init expansion was not added because current receipt construction paths already recompute from validated manifests and adding a new public factory would expand API surface. |
| P2-3 | P2 | audit lines 169-185 | absorbed | Renamed checker output from `external_layer_candidate_counts` to `shape_diagnostic_candidate_counts`. |
| P2-4 | P2 | audit lines 445-462 | absorbed | Kept `behaviorClass` optional for legacy in-memory compatibility, but encoding now throws if it is nil, so programmatic JSONL emission cannot silently omit `behavior_class`. |
| P2-5 | P2 | audit lines 465-478 | operational gate | Local gates are rerun after absorption; GitHub head-bound CI must be checked on the pushed commit before claiming CI proof. |

## Validation Plan

Required post-absorption local gates:
- `.venv/bin/python scripts/test_check_c6_case_shape.py`
- `.venv/bin/python scripts/check_c6_case_shape.py contracts/c6-bench-cases.jsonl generated/D_domain.tools.demo.json`
- `swift test --filter C6VehicleToolBenchTests`
- `swift test --filter ToolContractCompilerTests`
- `make verify-surface`
- `openspec validate rebuild-c6-four-layer-bench --strict`
- `openspec validate --all --strict`
- `git diff --check`

`make test` now includes `scripts/test_check_c6_case_shape.py`, so source-free Python gates cover the GPT Pro P1 regression during local `make verify` and CI `make verify-ci`.

## Residual Boundary

If all gates pass, the strongest truthful claim is `external-pass-with-absorbed-fixes` for the Long-run 2 identity + behavior-shape local closeout scope only. It still does not authorize retrain-C5, C6 acceptance, model-quality comparison, candidate comparison, golden-run, voice, endpoint readiness, UIUE merge, or any V/S/U-PASS claim.

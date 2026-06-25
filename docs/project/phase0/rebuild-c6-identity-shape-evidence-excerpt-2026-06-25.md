# Rebuild-C6 Identity Shape Evidence Excerpt - 2026-06-25

## Verdict

status: tracked_evidence_excerpt
source_scratch: Reports/rebuild-c6-identity-shape-20260624T234832Z/VERIFY.md
base_sha: ebc7933ed96123818aa781c2bb317baf769cd32e
head_before_closeout_docs: 229e9b3a4ffdad0a9e9e2a7ac34ac4de2a30cce1

This file exists because `Reports/` is ignored scratch. It records branch-source-truth excerpts for the local gates used by the identity+shape closeout. It is not C6 acceptance, not model-quality evaluation, not retrain-C5, not candidate comparison, not golden-run, not voice, not endpoint readiness, not UIUE merge, and not R-L17 candidate signoff.

## Commands

### `swift test --filter C6VehicleToolBenchTests`

exit_code: 0

```text
Test Suite 'C6VehicleToolBenchTests' passed at 2026-06-25 08:49:31.854.
         Executed 62 tests, with 0 failures (0 unexpected) in 3.199 (3.201) seconds
Test Suite 'MAformacPackageTests.xctest' passed at 2026-06-25 08:49:31.854.
         Executed 62 tests, with 0 failures (0 unexpected) in 3.199 (3.201) seconds
Test Suite 'Selected tests' passed at 2026-06-25 08:49:31.854.
         Executed 62 tests, with 0 failures (0 unexpected) in 3.199 (3.202) seconds
```

### `swift test --filter ToolContractCompilerTests`

exit_code: 0

```text
Test Suite 'ToolContractCompilerTests' passed at 2026-06-25 08:49:33.110.
         Executed 21 tests, with 0 failures (0 unexpected) in 0.362 (0.364) seconds
Test Suite 'MAformacPackageTests.xctest' passed at 2026-06-25 08:49:33.110.
         Executed 21 tests, with 0 failures (0 unexpected) in 0.362 (0.364) seconds
Test Suite 'Selected tests' passed at 2026-06-25 08:49:33.110.
         Executed 21 tests, with 0 failures (0 unexpected) in 0.362 (0.364) seconds
```

### `python3 scripts/check_c6_case_shape.py contracts/c6-bench-cases.jsonl generated/D_domain.tools.demo.json`

exit_code: 0

```text
rows=57
behavior_class_counts={"already_state_noop": 1, "clarify_missing_slot": 9, "refusal_no_available_tool": 8, "refusal_safety_or_policy": 5, "tool_call": 34}
external_layer_candidate_counts={"clarify": 2, "demo_fuzz": 7, "golden": 35, "safety": 5, "unsupported": 8}
```

### `make verify-surface`

exit_code: 0

```text
.venv/bin/python scripts/surface_consistency.py contracts/c6-bench-cases.jsonl generated/D_domain.tools.demo.json
{"consistent": true, "missing_in_generated": []}
.venv/bin/python scripts/verify_gold.py contracts/c6-bench-cases.jsonl generated/D_domain.tools.demo.json
{"gold_apply_100": true, "total_cases": 57, "violation_count": 0, "violations": []}
```

### `openspec validate rebuild-c6-four-layer-bench --strict`

exit_code: 0

```text
Change 'rebuild-c6-four-layer-bench' is valid
```

### `openspec validate --all --strict`

exit_code: 0

```text
Totals: 15 passed, 0 failed (15 items)
```

### `git diff --check`

exit_code: 0

```text
```

## Commit Range

Implementation commits in this long-run local pass:

```text
229e9b3 feat(c6): migrate bench cases to explicit behavior shape
728137a feat(c6): add contract bundle fingerprint
```

Range: `ebc7933..229e9b3`

## Subagent Audit Excerpts

### Phase 4

verdict: `PASS_WITH_FIXES`

high-signal:
- `contract_bundle_fingerprint` receipt now exposes `schema_version / bundle_hash / component_digests`.
- public `manifest/receipt/fingerprint` entry points share one fail-closed validator.
- existing per-run identity fields remain preserved.

### Phase 5

verdict: `PASS_WITH_FIXES`

high-signal:
- tracked JSONL, decode, generator, and validation now all use explicit `behavior_class`.
- `verify-c6-shape` is wired into the local `verify` gate.
- checker remains source-free and UIUE stayed read-only.
- `clarify` external candidate count is kept as plan-mandated diagnostic output, not runtime-layer SSOT.

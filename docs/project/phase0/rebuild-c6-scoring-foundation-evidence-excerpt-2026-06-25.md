---
retire_trigger: "Retire when superseded by archived OpenSpec specs or explicit user decision."
expires: "2026-08-15"
---

# Rebuild-C6 Scoring Foundation Evidence Excerpt - 2026-06-25

## Verdict

status: tracked_evidence_excerpt
source_scratch: Reports/rebuild-c6-scoring-foundation-20260624T173024Z/VERIFY.md
base_sha: 6751be4942ebba079abb3e80c5e827c79fb43a77
head_before_gptpro_p1_fixes: 5a5021133b6453035660ffa45856ebe71078bb0b

This file exists because `Reports/` is ignored scratch. It records branch-source-truth excerpts for the local gates used by the closeout. It is not C6 acceptance, not model-quality evaluation, not retrain-C5, not golden-run, not voice, not endpoint readiness, not UIUE merge, and not R-L17 candidate signoff.

## Commands

### `swift test --filter C6VehicleToolBenchTests`

exit_code: 0

```text
Test Suite 'C6VehicleToolBenchTests' passed at 2026-06-25 02:03:09.776.
	 Executed 52 tests, with 0 failures (0 unexpected) in 2.588 (2.590) seconds
Test Suite 'MAformacPackageTests.xctest' passed at 2026-06-25 02:03:09.776.
	 Executed 52 tests, with 0 failures (0 unexpected) in 2.588 (2.590) seconds
Test Suite 'Selected tests' passed at 2026-06-25 02:03:09.776.
	 Executed 52 tests, with 0 failures (0 unexpected) in 2.588 (2.591) seconds
```

### `swift test --filter ToolContractCompilerTests`

exit_code: 0

```text
Test Suite 'ToolContractCompilerTests' passed at 2026-06-25 02:03:11.145.
	 Executed 21 tests, with 0 failures (0 unexpected) in 0.329 (0.330) seconds
Test Suite 'MAformacPackageTests.xctest' passed at 2026-06-25 02:03:11.145.
	 Executed 21 tests, with 0 failures (0 unexpected) in 0.329 (0.330) seconds
Test Suite 'Selected tests' passed at 2026-06-25 02:03:11.145.
	 Executed 21 tests, with 0 failures (0 unexpected) in 0.329 (0.331) seconds
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
- Validating...
✓ change/define-demo-default-scope
✓ change/define-demo-golden-run-and-voice
✓ change/define-lora-data-gate
✓ spec/demo-experience
✓ spec/lora-training
✓ change/migrate-d-domain-tool-surface
✓ change/rebuild-c6-four-layer-bench
✓ change/retrain-c5-lora-d-domain
✓ change/run-lora-candidate-training
✓ spec/scenario-state-protocol
✓ spec/semantic-function-contract
✓ spec/tool-execution
✓ change/ui-presentation
✓ spec/vehicle-capabilities
✓ spec/vehicle-tool-bench
Totals: 15 passed, 0 failed (15 items)
```

### `git diff --check`

exit_code: 0

```text
```

## GPT Pro P1 Fix Red Test

Before neutralizing the legacy thresholded summary status, the P1 regression test failed as expected:

```text
command: swift test --filter C6VehicleToolBenchTests/testSummaryStatusIsConstructionReportNotThresholdAcceptance
XCTAssertEqual failed: ("hard_fail") is not equal to ("local_construction_report")
exit_code=1
```

## GPT Pro P1 Fix Verification

After absorbing P1-1 and P1-2:

```text
command: swift test --filter C6VehicleToolBenchTests/testSummaryStatusIsConstructionReportNotThresholdAcceptance
Test Suite 'C6VehicleToolBenchTests' passed at 2026-06-25 02:32:07.035.
	 Executed 1 test, with 0 failures (0 unexpected) in 0.003 (0.003) seconds
exit_code=0

command: swift test --filter C6VehicleToolBenchTests
Test Suite 'C6VehicleToolBenchTests' passed at 2026-06-25 02:32:10.773.
	 Executed 53 tests, with 0 failures (0 unexpected) in 2.662 (2.664) seconds
exit_code=0

command: swift test --filter ToolContractCompilerTests
Test Suite 'ToolContractCompilerTests' passed at 2026-06-25 02:32:12.093.
	 Executed 21 tests, with 0 failures (0 unexpected) in 0.431 (0.432) seconds
exit_code=0

command: make verify-surface
{"consistent": true, "missing_in_generated": []}
{"gold_apply_100": true, "total_cases": 57, "violation_count": 0, "violations": []}
exit_code=0

command: openspec validate rebuild-c6-four-layer-bench --strict
Change 'rebuild-c6-four-layer-bench' is valid
exit_code=0

command: openspec validate --all --strict
Totals: 15 passed, 0 failed (15 items)
exit_code=0

command: git diff --check
exit_code=0
```

## GPT Pro P1 Absorption Subagent Audit

Read-only subagent audit verdict: `PASS_WITH_FIXES`.

High-signal findings:
- P1-1 content is present: closeout points local gates to this tracked evidence excerpt.
- P1-2 is mechanically non-acceptance: `C6Summary.status` is `local_construction_report`, and the regression test proves `IrrelAcc=0` no longer drives `summary.status`.
- Route-only boundary preserved: no evidence of retrain-C5, C6 acceptance, model eval, golden-run, voice, endpoint, UIUE, R-L17 candidate signoff, or V/S/U-PASS work in the audited diff.
- Required final fix before claiming P1-1 absorbed: exact-path Git tracking for this evidence excerpt and the GPT Pro audit report copy.

Resolution condition: the final P1 absorption commit must include:
- `docs/project/phase0/rebuild-c6-scoring-foundation-evidence-excerpt-2026-06-25.md`
- `docs/project/phase0/rebuild-c6-scoring-foundation-gptpro-audit-2026-06-25.md`

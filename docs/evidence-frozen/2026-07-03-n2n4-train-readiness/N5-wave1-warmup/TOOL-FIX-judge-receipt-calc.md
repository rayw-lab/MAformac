# TOOL-FIX - judge_sampling_receipt.py

status: tool_fix_done  
artifact_kind: tool_fix_receipt  
proof_class: local_script_validation_plus_fixture_recalc  
scope: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/tools/judge_sampling_receipt.py`  
source_audit: `TOOL-AUDIT-judge-receipt-calc.md`

## Verdict

TOOL-FIX complete. The receipt calculator is now fail-closed on the accepted-candidate-pool boundary, emits the full rev2 §9 mechanical/semantic field surface, validates judge sample ids against the accepted pool and optional sample manifest, and no longer uses the misleading `FULL_RUN_MECHANICAL_PASS` prefix when mechanical receipts are not asserted by this tool.

This does not run judge acceptance for batch-01. It only prepares the calculator; formal batch-01 receipt still waits for `%43` judge rows.

## Findings Closed

| Audit item | Status | Evidence |
|---|---|---|
| P1-1 denominator boundary | closed | `--accepted-pool-summary` now required unless explicit fixture-only `--allow-derived-accepted-pool-summary`; summary count/hash must match local accepted projection. Anchors: `tools/judge_sampling_receipt.py:154`, `:669`. |
| P1-2 schema completeness | closed | `mechanical` now includes `row_count`, `warning_row_count`, `warning_by_class`, `d5_true_hits`, `d6_true_hits`, D9 mismatch counts, and `c6_exact_intersections`; uncomputed fields carry explicit `assertion_status`/`source_required`. `semantic_sample.strata_counts` always emitted. Anchors: `tools/judge_sampling_receipt.py:337`, `:355`, `:816`. |
| P1-3 sample id membership | closed | judge row ids must be inside accepted pool; optional sample manifest must match exactly unless `--allow-approved-oversample`. Anchors: `tools/judge_sampling_receipt.py:292`, `:684`. |
| P2-1 claim prefix | closed | mechanical claim prefix changed to `FULL_RUN_MECHANICAL_NOT_ASSERTED`. Anchor: `tools/judge_sampling_receipt.py:751`. |

## Changed/Generated Artifacts

| Artifact | sha256 |
|---|---|
| `tools/judge_sampling_receipt.py` | `15e2a23db1be2b1fb8160289ffa0f423ba76dd0212d18c2a785e8941014a7ffa` |
| `judge-sampling-canary-accepted-pool-summary.json` | `4957ed7c5893f565cf9c8bf78afa4aea01730468f8c2116b71f8cfbc0f9cd65f` |
| `judge-sampling-canary-sample-manifest.json` | `77ed72b7e35ae1ea289473fe2504443eed172286fe4bf9ba167703a75558ae88` |
| `judge-sampling-canary-fixture-receipt.json` | `5c8a21be77631bcd09f0cb91680b4199ff46a42cebba0511c3a3b77692b3a82a` |
| `lane-subcc-1/gates/batch-01-accepted-pool-summary-v3.json` | `483e0ba78f01c2d92b840cbdc7e22eff6822a1a6e1dc81fcc6e21e234697312f` |
| `lane-subcc-1/gates/judge-sampling-dry-run-v3.json` | `7efc41c9a8cca793ac9ee774032eaa8cc4af35ab09a0298341e241e10a2307bd` |

## Positive Validation

Syntax:

```bash
python3 -m py_compile tools/judge_sampling_receipt.py
```

Canary fixture recompute:

```bash
python3 tools/judge_sampling_receipt.py \
  --judge-rows /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-canary/canary-judge-rows.jsonl \
  --batch-manifest batch-01-order.json \
  --candidate-pool /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-canary/canary-judge-rows.jsonl \
  --accepted-pool-summary judge-sampling-canary-accepted-pool-summary.json \
  --sample-manifest judge-sampling-canary-sample-manifest.json \
  --family-id canary-60-judge-fixture \
  --summary-seq canary-60-fixture-001 \
  --sample-seed ffca877983381a73 \
  --output judge-sampling-canary-fixture-receipt.json
```

Result:

| Field | Value |
|---|---|
| `family_judge_status` | `stopped_precision` |
| `candidate_count_denominator` | 60 |
| `candidate_count_denominator_basis` | `controller_summary_boundary:accepted_candidate_pool` |
| `reviewed_count` | 60 |
| `accepted_count` | 7 |
| `family_precision` | 0.116667 |
| `wilson95_lower` | 0.057676 |
| `sample_membership.status` | `valid` |
| `sample_membership.sample_manifest_status` | `validated_exact_order` |
| `mechanical.assertion_status` | `not_asserted_by_this_tool` |
| `semantic_sample.strata_counts` | present; `strata_source_status=not_provided` |
| `claim_lines.full_run_mechanical` | starts with `FULL_RUN_MECHANICAL_NOT_ASSERTED` |

Batch-01 v3 accepted pool dry-run:

```bash
python3 tools/judge_sampling_receipt.py \
  --dry-run-no-judge \
  --batch-manifest batch-01-order.json \
  --candidate-pool lane-subcc-1/candidates.jsonl \
  --accepted-pool-summary lane-subcc-1/gates/batch-01-accepted-pool-summary-v3.json \
  --family-id scene.scene1 \
  --summary-seq warmup-batch-01:judge-summary-001 \
  --mechanical-receipt lane-subcc-1/gates/datagate-v3/c5-data-gate-receipt.json \
  --output lane-subcc-1/gates/judge-sampling-dry-run-v3.json
```

Result:

| Field | Value |
|---|---|
| `family_judge_status` | `judge_rows_required` |
| `candidate_count_denominator` | 50 |
| `candidate_count_denominator_basis` | `controller_summary_boundary:accepted_candidate_pool` |
| `accepted_pool_boundary.status` | `validated` |
| `accepted_pool_boundary.denominator_source` | `B01-GATES-RECEIPT-v3:C5DataGate data_gate_ready accepted_candidate_pool` |
| `sample_membership.status` | `valid` |
| `mechanical.assertion_status` | `partial_from_mechanical_receipt_missing_fields` |
| `semantic_sample.strata_counts` | present; `strata_source_status=not_provided` |
| `claim_lines.sampled_semantic_confidence` | starts with `SAMPLED_SEMANTIC_NOT_ASSERTED` |

## Fail-Closed Validation

| Case | Expected | Observed |
|---|---|---|
| missing `--accepted-pool-summary` | fail | exit 1: summary required for controller accepted-pool boundary |
| bad summary hash | fail | exit 1: `accepted_candidate_pool_sha256 mismatch` |
| sample manifest mismatch | fail | exit 1: judge ids do not exactly match sample manifest |
| judge row id outside accepted pool | fail | exit 1: `judge sample row ids are outside accepted_candidate_pool` |

## Stop Condition

The tool is ready for `%43` judge rows. Next formal command should use batch-01 candidate pool, `lane-subcc-1/gates/batch-01-accepted-pool-summary-v3.json`, and the actual judge JSONL/sample manifest when provided.

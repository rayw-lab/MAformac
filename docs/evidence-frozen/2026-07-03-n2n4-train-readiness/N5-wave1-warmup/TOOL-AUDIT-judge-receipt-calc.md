# TOOL-AUDIT - judge_sampling_receipt.py

status: REQUEST_CHANGES_P1
artifact_kind: tool_audit_report
proof_class: local_static_review_plus_fixture_recalc
reviewer: "%43"
reviewed_at: 2026-07-03

Target:

- Tool: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/tools/judge_sampling_receipt.py`
- Spec: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-canary/JUDGE-SAMPLING-rev2.md`
- Fixture receipt: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/judge-sampling-canary-fixture-receipt.json`

## Verdict

`REQUEST_CHANGES_P1`.

No P0 found. The Wilson math, threshold state machine, `shouldStopFamily(0.8)` edge behavior, fixture recomputation, and two-layer claim text are directionally correct. However, three P1 gaps block using this as the authoritative family receipt calculator without a wrapper/fix:

1. The denominator is not actually bound to the controller summary boundary `accepted_candidate_pool`.
2. The emitted receipt is not schema-complete against rev2 §9 and omits mechanical/warning/strata fields that downstream tooling may reasonably require.

## Findings

### P1-1 - Denominator is a row-filter approximation, not controller-bound `accepted_candidate_pool`

Spec requires `candidate_count` to be "current Gate7 family accepted_candidate_pool size at the controller summary boundary" after schema/redaction/diversity/DataGate/quarantine/quota gates and before LLM judge (`JUDGE-SAMPLING-rev2.md:21`, `:79-83`).

The tool computes the denominator by reading `--candidate-pool` JSONL, filtering rows with a local heuristic, and counting the survivors:

- `is_accepted_candidate()` excludes `must_not_train`, some status strings, `quarantine`, and `unsupported_drop` (`judge_sampling_receipt.py:78-101`).
- `candidate_count = len(accepted_candidate_rows)` (`judge_sampling_receipt.py:344-345`).
- `candidate_pool_sha256 = sha256_file(candidate_path)` hashes the entire input file, not a canonical accepted-pool projection (`judge_sampling_receipt.py:346`).

Impact: if the controller summary boundary differs from row-local flags, the receipt can carry a plausible but wrong denominator and pool hash. This matters exactly at the gate boundary: DataGate/quarantine/quota decisions may live in controller/gate receipts, not in each candidate row.

Required fix: add a required controller summary/gate receipt input or manifest field that explicitly provides `accepted_candidate_pool_count` and a canonical accepted-pool hash, then fail closed if it disagrees with the candidate JSONL projection. The receipt should say which boundary artifact supplied the denominator.

### P1-2 - Receipt schema is not complete against rev2 §9

Spec §9 requires mechanical fields such as `row_count`, `warning_row_count`, `warning_by_class`, `d5_true_hits`, `d6_true_hits`, D9 mismatch counts, and `c6_exact_intersections`, plus semantic `strata_counts` (`JUDGE-SAMPLING-rev2.md:364-406`).

The tool emits only a reduced mechanical block:

- `hard_fail_count`, `hard_fail_by_reason`, `warning_upper_limit_exceeded`, and a note (`judge_sampling_receipt.py:439-444`).
- semantic block omits `strata_counts` (`judge_sampling_receipt.py:445-459`).

Fixture schema diff:

```text
missing_mechanical = row_count, warning_row_count, warning_by_class,
  d5_true_hits, d6_true_hits, d9_ledger_missing,
  d9_args_diff_mismatch, d9_template_mismatch, c6_exact_intersections
missing_semantic = strata_counts
```

Impact: a downstream reader cannot tell from this receipt whether the full-run mechanical layer is absent, zero, deferred, or externally satisfied unless it parses prose. This weakens CG45-P0-1 claim stratification.

Required fix: emit the full rev2 §9 field set. If the calculator does not compute a field, require the corresponding mechanical receipt input or set an explicit structured status such as `not_asserted_by_this_tool` with `source_required`, not silent omission.

### P1-3 - Judge row ids are not validated as a subset of the accepted candidate pool

The tool collects `sample_row_ids` from judge rows (`judge_sampling_receipt.py:226-235`, `:353-355`) but does not check that those ids are present in the accepted candidate pool, belong to the same family, or match a prior stratified sample manifest.

Spec requires sampled row ids to be receipt-bearing evidence for the family sample (`JUDGE-SAMPLING-rev2.md:152-162`, `:203-207`, `:372-375`). A clean LLM sample also must not be used to claim unreviewed semantic rows are all correct (`JUDGE-SAMPLING-rev2.md:53-56`).

Impact: a wrong judge JSONL file, duplicated file from another family, or mixed-family sample could still produce `accepted_sampled` if its rows have high PASS rate.

Required fix: fail closed unless every judge row id is in the accepted candidate pool and, when a sample manifest exists, exactly matches that manifest or is explicitly marked as approved oversample.

### P2-1 - Mechanical claim prefix is easy to misread as a pass

The tool emits:

```text
FULL_RUN_MECHANICAL_PASS: NOT_ASSERTED_BY_JUDGE_RECEIPT; ...
```

The content is conservative, but the prefix begins with `FULL_RUN_MECHANICAL_PASS` (`judge_sampling_receipt.py:392-396`; fixture `claim_lines.full_run_mechanical`). Spec reserves full mechanical pass wording for full-run scripted/mechanical dimensions (`JUDGE-SAMPLING-rev2.md:316-324`).

Recommendation: rename the line prefix to `FULL_RUN_MECHANICAL_NOT_ASSERTED` or split it into `mechanical_claim_status=not_asserted_by_this_tool` plus a separate explanatory string.

## Positive Checks

### Required top-level receipt fields

The fixture contains the core top-level fields required by the user's patch lane:

```text
candidate_count_denominator
candidate_pool_sha256
sample_row_ids
sample_size_formula_version
```

It also includes `family_id`, `candidate_count`, `mechanical`, `semantic_sample`, `family_judge_status`, `next_action`, and `claim_class`.

### Wilson lower bound

Formula implementation matches rev2 §5.2 (`judge_sampling_receipt.py:238-247` vs `JUDGE-SAMPLING-rev2.md:139-150`).

Manual checks:

| accepted/reviewed | precision | Wilson lower 95 | tool / expected |
|---:|---:|---:|---|
| 7/60 | 0.116667 | 0.057676 | matches fixture |
| 18/20 | 0.900000 | 0.698962 | matches hand calc |
| 8/10 | 0.800000 | 0.490157 | boundary case |
| 45/50 | 0.900000 | 0.786395 | below Wilson stop line |

### State machine and `shouldStopFamily(0.8)`

The status function matches the next-action table for the tested edges (`judge_sampling_receipt.py:260-326`; spec `JUDGE-SAMPLING-rev2.md:173-189`):

| case | observed status | shouldStopFamily |
|---|---|---|
| reviewed=0 | `stopped_precision` | true |
| 7/10 precision 0.7 | `stopped_precision` | true |
| 8/10 precision 0.8 | `cross_judge_pending` | false |
| 9/10 precision 0.9 with low Wilson | `needs_more_review` | false |
| 46/50 precision 0.92, Wilson 0.811615 | `accepted_sampled` | false |
| mechanical hard fail | `mechanical_blocked` | true |
| warning upper limit exceeded | `paused_warning` | false |

This is consistent with `shouldStopFamily(threshold:0.8)`: below 0.8 stops; equal 0.8 does not accept and requires cross judge.

### Claim layering

The tool separates sampled semantic confidence from mechanical receipts:

- sampled line says unreviewed rows are not semantic PASS (`judge_sampling_receipt.py:384-390`);
- mechanical line says this calculator does not assert full-run mechanical pass (`judge_sampling_receipt.py:392-395`).

This is conceptually aligned with CG45-P0-1, subject to P2-1 prefix cleanup and P1-2 schema completion.

### Fixture recomputation

Command rerun:

```bash
cd /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup
python3 tools/judge_sampling_receipt.py \
  --judge-rows /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-canary/canary-judge-rows.jsonl \
  --batch-manifest batch-01-order.json \
  --candidate-pool /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-canary/canary-judge-rows.jsonl \
  --family-id canary-60-judge-fixture \
  --summary-seq canary-60-fixture-001 \
  --output /tmp/judge-receipt-recalc.json
```

Result: stable fields match `judge-sampling-canary-fixture-receipt.json`; only `generated_at` differs.

Fixture values confirmed:

```text
candidate_count_denominator=60
reviewed_count=60
accepted_count=7
family_precision=0.116667
wilson95_lower=0.057676
family_judge_status=stopped_precision
shouldStopFamily=true
sample_size_formula_version=gate7_family_min50_max20_10pct_v1
```

Syntax check:

```text
python3 -m py_compile tools/judge_sampling_receipt.py
py_compile_exit=0
```

## Verdict Details

| Severity | Count | Items |
|---|---:|---|
| P0 | 0 | none |
| P1 | 3 | denominator boundary, schema completeness, judge-row membership validation |
| P2 | 1 | mechanical claim prefix clarity |

Recommended next action: fix P1 before using this tool as the authoritative family receipt for warmup or expansion. It is acceptable as a local calculator/helper only if a controller wrapper supplies and verifies the missing boundary/mechanical/sample-manifest inputs.

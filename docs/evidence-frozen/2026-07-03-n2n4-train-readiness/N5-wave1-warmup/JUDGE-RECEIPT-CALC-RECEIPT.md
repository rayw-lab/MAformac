# JUDGE-RECEIPT-CALC Receipt

status: DONE_LOCAL_TOOL_SELFTEST_PASS  
proof_class: local/pre-training receipt calculator  
generated_at: 2026-07-03  
artifact_kind: run-directory tool + fixture receipt  

## Scope

Implemented:

- `tools/judge_sampling_receipt.py`
- canary fixture output: `judge-sampling-canary-fixture-receipt.json`

This tool computes the JUDGE-SAMPLING-rev2 family sample receipt from:

1. judge per-row JSONL,
2. batch manifest JSON,
3. candidate pool JSONL.

It does not run LLM judging, DataGate, training, or full-run mechanical scanners.

## Contract Coverage

Receipt fields emitted:

- `family_id`
- `summary_seq`
- `candidate_count_denominator`
- `candidate_pool_sha256`
- `sample_seed`
- `sample_row_ids`
- `sample_size_formula_version`
- `reviewed_count`
- `accepted_count`
- `family_precision`
- `wilson95_lower`
- `family_judge_status`
- `shouldStopFamily`
- layered `claim_lines`

Denominator basis:

- `candidate_count_denominator = accepted_candidate_pool`
- implemented as candidate rows after excluding `quarantine`, `unsupported_drop`, and `must_not_train` rows.

State machine:

- `precision < 0.8` => `stopped_precision`, `shouldStopFamily=true`
- `precision == 0.8` => `cross_judge_pending`, not accepted
- `0.8 < precision < 0.9` => `cross_judge_pending`
- `precision >= 0.9 && wilson95_lower < 0.8` => `needs_more_review`
- `precision >= 0.9 && wilson95_lower >= 0.8` => `accepted_sampled`

Claim layering:

- mechanical line is explicitly `NOT_ASSERTED_BY_JUDGE_RECEIPT`
- sampled semantic line uses `SAMPLED_SEMANTIC_CONFIDENCE`

## Self-Test

Fixture:

```bash
/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-canary/canary-judge-rows.jsonl
```

Command:

```bash
python3 tools/judge_sampling_receipt.py \
  --judge-rows /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-canary/canary-judge-rows.jsonl \
  --batch-manifest batch-01-order.json \
  --candidate-pool /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-canary/canary-judge-rows.jsonl \
  --family-id canary-60-judge-fixture \
  --summary-seq canary-60-fixture-001 \
  --output judge-sampling-canary-fixture-receipt.json
```

Result:

```text
candidate_count_denominator=60
reviewed_count=60
accepted_count=7
family_precision=0.116667
wilson95_lower=0.057676
family_judge_status=stopped_precision
shouldStopFamily=true
```

Field assertion:

```bash
jq -e 'has("family_id") and has("summary_seq") and has("candidate_count_denominator") and has("candidate_pool_sha256") and has("sample_seed") and has("sample_row_ids") and has("sample_size_formula_version") and has("reviewed_count") and has("accepted_count") and has("family_precision") and has("wilson95_lower") and has("family_judge_status") and has("shouldStopFamily") and has("claim_lines") and (.candidate_count_denominator == 60) and (.reviewed_count == 60) and (.accepted_count == 7) and (.family_judge_status == "stopped_precision") and (.shouldStopFamily == true) and (.sample_size_formula_version == "gate7_family_min50_max20_10pct_v1") and (.claim_lines.sampled_semantic_confidence | startswith("SAMPLED_SEMANTIC_CONFIDENCE:"))' judge-sampling-canary-fixture-receipt.json
```

Output:

```text
true
```

Syntax check:

```bash
python3 -m py_compile tools/judge_sampling_receipt.py
```

Output:

```text
exit 0
```

Threshold edge assertion:

```bash
python3 - <<'PY'
import importlib.util
from pathlib import Path
p = Path('tools/judge_sampling_receipt.py')
spec = importlib.util.spec_from_file_location('judge_sampling_receipt', p)
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)
assert mod.evaluate_status(10, 7, 10, mod.wilson_lower_95(7, 10), 0, False)[0:3] == ('stopped_precision', 'stop_family_no_further_generation_for_family', True)
assert mod.evaluate_status(10, 8, 10, mod.wilson_lower_95(8, 10), 0, False)[0:3] == ('cross_judge_pending', 'second_judge_or_expanded_sample_before_continuing', False)
print('threshold_semantics_ok')
PY
```

Output:

```text
threshold_semantics_ok
```

## Paths

- Tool: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/tools/judge_sampling_receipt.py`
- Fixture receipt: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/judge-sampling-canary-fixture-receipt.json`
- This receipt: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/JUDGE-RECEIPT-CALC-RECEIPT.md`

## Residual Risk

This is calculator-level validation only. Real warmup acceptance still needs actual warmup judge rows plus separate full-run mechanical receipts.

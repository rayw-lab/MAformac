# OpenAI Judge Verdict - warmup-batch-01

verdict: PASS
batch_id: warmup-batch-01
lane_id: subcc-1
candidate_count_denominator: 50
candidate_pool_sha256: eee76baf662cb41ae32b2a6f8c49c3d1fcf2b25b850001a5541822d27602016c
ledger_sha256: a1ed5e688a15f9a95b04a93ee0f79fa14ced47f3bcd9f455f65a6d2b2965ab81
sample_size_formula_version: judge_sampling_rev2.1_family_min50_max20_10pct
sample_row_ids: warmup-batch-01-subcc-1-0029, warmup-batch-01-subcc-1-0030, warmup-batch-01-subcc-1-0031, warmup-batch-01-subcc-1-0032, warmup-batch-01-subcc-1-0033, warmup-batch-01-subcc-1-0034, warmup-batch-01-subcc-1-0035, warmup-batch-01-subcc-1-0036, warmup-batch-01-subcc-1-0037, warmup-batch-01-subcc-1-0038, warmup-batch-01-subcc-1-0039, warmup-batch-01-subcc-1-0040, warmup-batch-01-subcc-1-0041, warmup-batch-01-subcc-1-0042, warmup-batch-01-subcc-1-0045, warmup-batch-01-subcc-1-0048, warmup-batch-01-subcc-1-0043, warmup-batch-01-subcc-1-0046, warmup-batch-01-subcc-1-0047, warmup-batch-01-subcc-1-0004
mechanical_full_coverage: D5/D6/D7/D9/A10/A11/A12 = 50/50
semantic_sample_coverage: D1/D2/D3/D4/D8 = 20/50
claim_tier: full_mechanical + sampled_semantic

## Verdict Summary

PASS after scoped D7 re-judge @v4. The initial B01 blocker was D7 surface/provenance field consistency: at v3, all 50 candidate rows still had `recipe_manifest_sha=sha256:TODO` and `quota_config_sha=sha256:TODO`. The v4 repair stamps the manifest-bound values on all 50 rows, recomputes `candidate_row_sha`, aligns ledger row shas, refreshes SHA256SUMS, and keeps C5DataGate v4 at `data_gate_ready`.

Content dimensions were not re-reviewed in the v4 scoped pass because the repair scope was provenance/hash closure only. The prior content result still stands: D5/D6/D9/A10/A11/A12 full mechanical checks passed, and the 20-row semantic sample passed D1/D2/D3/D4/D8.

## Mechanical Results

| dimension | coverage | result | note |
|---|---:|---|---|
| D5 leakage / training-boundary | 50/50 | PASS | no leakage regex hit in visible generated/user/tool-call fields; synthetic authorization present |
| D6 redaction / safety hygiene | 50/50 | PASS | `raw_source_redacted=true`, `raw_text_absent=true`, refusal rows 0, DataGate redaction pass |
| D7 surface-field consistency | 50/50 | PASS | v4 stamps manifest-bound `recipe_manifest_sha` and `quota_config_sha` on all rows; `candidate_row_sha` and ledger shas close 50/50 |
| D9 ledger and provenance | 50/50 | PASS | ledger closed 50/50; `candidate_row_sha`, `args_diff`, `template_args`, `canary_args`, `schema_check=pass` recompute clean |
| A10 hash recipe integrity | 50/50 | PASS | `prompt_hash=sha256(input_text)`, `expected_tool_call_signature=sha256(rendered_tool_call)`, `candidate_row_sha` recomputed |
| A11 quota and manifest conformance | 50/50 | PASS | quota 50, actual 50, refusal 0/0, no manual override; multi-call waiver documented |
| A12 parent-value / args-diff audit | 50/50 | PASS | unchanged rows equal template args; changed rows are exactly explained by `args_diff` |

## Semantic Sample Results

The deterministic semantic sample contains all 16 value-changed rows plus unchanged open/close and length-edge rows. All 20 sampled rows passed D1/D2/D3/D4/D8.

- value_changed sampled: 16/16
- open/close polarity sampled: `open_ac` 2 rows, `close_ac` 3 rows
- sampled family distribution: {'ac_temperature': 15, 'ac': 5}
- D8 warning/fail count: 0/20, below cap 3/20

## Warnings

- `family_distribution_mismatch`: candidates use semantic families `ac_temperature=44`, `ac=6`, not the single quota family label in the SPEC. I recomputed allocation rather than treating it as a hard mechanical fail.
- `trigger_sha_mismatch`: the initial trigger cited candidates `17f8dbe2...` and ledger `5832fecb...`; the final verdict uses disk-bound v4 artifacts and SHA256SUMS: candidates `eee76baf662cb41ae32b2a6f8c49c3d1fcf2b25b850001a5541822d27602016c`, ledger `a1ed5e688a15f9a95b04a93ee0f79fa14ced47f3bcd9f455f65a6d2b2965ab81`.

## Claim Discipline

For warmup-batch-01, mechanical judge dimensions D5/D6/D7/D9/A10/A11/A12 were evaluated over all 50 candidate rows from lane subcc-1. The claim is full-run only for those mechanical/provenance dimensions and is bound to candidate_pool_sha256=eee76baf662cb41ae32b2a6f8c49c3d1fcf2b25b850001a5541822d27602016c, batch_order_sha256=31106d6e8719d08cdbb9637dc1d1d4f268095d4b46b9d7eb6840a923843bed9f, and main_pin_sha=b33d8eba152e5326f69bbe85fc356b73419ee9c3.

For warmup-batch-01, semantic judge dimensions D1/D2/D3/D4/D8 were reviewed on a deterministic stratified sample of 20 rows out of the 50-row candidate pool, using sample_size_formula_version=judge_sampling_rev2.1_family_min50_max20_10pct and sample_row_ids=warmup-batch-01-subcc-1-0029, warmup-batch-01-subcc-1-0030, warmup-batch-01-subcc-1-0031, warmup-batch-01-subcc-1-0032, warmup-batch-01-subcc-1-0033, warmup-batch-01-subcc-1-0034, warmup-batch-01-subcc-1-0035, warmup-batch-01-subcc-1-0036, warmup-batch-01-subcc-1-0037, warmup-batch-01-subcc-1-0038, warmup-batch-01-subcc-1-0039, warmup-batch-01-subcc-1-0040, warmup-batch-01-subcc-1-0041, warmup-batch-01-subcc-1-0042, warmup-batch-01-subcc-1-0045, warmup-batch-01-subcc-1-0048, warmup-batch-01-subcc-1-0043, warmup-batch-01-subcc-1-0046, warmup-batch-01-subcc-1-0047, warmup-batch-01-subcc-1-0004. This supports only a sampled-confidence semantic claim for the batch; it must not be phrased as all 50 rows passing semantic review.

## Output Artifacts

- row_score_ledger: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/judge-openai-batch-01-row-scores.jsonl`
- mechanical_audit_summary: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/judge-openai-batch-01-mechanical-audit.json`

## Stop / Repair Scope

Repair scope should be limited to D7 provenance field closure unless the generator/controller policy changes content. After repair, re-run D7 and candidate-row sha/ledger sha closure over all 50 rows; content dimensions only need re-review if row text, tool calls, or arguments change.

## Re-judge D7 @v4

Verdict: PASS. Scoped re-judge covered only D7/provenance hash closure; content dimensions were not re-reviewed because v4 changed provenance fields and hashes, not row text, tool calls, or arguments.

Evidence:

- B01-GATES-RECEIPT-v4 sha256: `2499ff8e7c0b1c7b17ccc781c5887688d7a52994501e6ea2857daca55b2af782`
- `recipe_manifest_sha` row value = manifest value `sha256:83e8ad6a387d88e9d8f78adeedb878ac4e6a033ca6ee40538663fee4ac4a953f` on 50/50 rows.
- `quota_config_sha` row value = manifest value `sha256:011387d640046b0a5a77d6cbb702cc81548c652cc9ad04149c7af8601bf1de23` on 50/50 rows.
- `candidate_row_sha` recomputed from canonical row payload and matched stored row value on 50/50 rows.
- Ledger `candidate_row_sha` matched candidate row shas on 50/50 rows.
- SHA256SUMS matched current `candidates.jsonl`, `value_change_ledger.jsonl`, and `batch_manifest.json`.
- `candidates.jsonl` file sha256: `eee76baf662cb41ae32b2a6f8c49c3d1fcf2b25b850001a5541822d27602016c`.
- `value_change_ledger.jsonl` sha256: `a1ed5e688a15f9a95b04a93ee0f79fa14ced47f3bcd9f455f65a6d2b2965ab81`.
- Accepted candidate pool canonical sha256 at judge receipt boundary: `34270ae1e07c84e7c232b787431c6bae8d3966a1f91c23f56018f3a31458b187`.
- DataGate v4 status: `data_gate_ready`, row_count=50, surface_field_pass=50, redaction_status=pass.

Final claim wording remains tiered: full-run PASS only for mechanical/provenance dimensions D5/D6/D7/D9/A10/A11/A12 over 50/50 rows; semantic dimensions D1/D2/D3/D4/D8 retain only the prior deterministic 20/50 sampled-confidence PASS claim.

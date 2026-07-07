# JUDGE VERDICT — R2b S1 lane-b

verdict: **PASS_WITH_NOTES**
judge_owner: `%43` OpenAI-family judge
proof_class: local/pre_training_batch_judge
spec: `wave2-negatives/JUDGE-SPEC-r2b-s1-lane-b.md`
candidate_pool_sha256: `ec7e5762ae19be73a40a746f748fa3394082f5fc66f89ec770cde71f9ee7af9b`
candidate_count_denominator: `75`
semantic_sample_size: `20`
sample_size_formula_version: `judge_sampling_rev2.1_family_min50_max20_10pct`
claim_boundary: full mechanical claims are 75/75; semantic claims are sampled 20/75 only and must not be promoted to full semantic pass.

## Basis

| item | result |
|---|---|
| candidates sha | matched user-provided sha and current bytes |
| row counts | `candidates.jsonl=75`, `value_change_ledger.jsonl=75` |
| SHA256SUMS | all listed lane artifacts matched current bytes |
| D-087 deviation | manifest/receipt/self-audit cite `R2B-QUERY-RECLASS-01`; legal |
| class distribution | `45 positive / 4 query / 5 refusal / 5 already_state / 11 unsupported / 5 followup` |
| DataGate/mechanical context | commander reported green; local lane gate reports pass except class-ratio candidate-pool cap warning covered by D-087 train-pack waiver |

## Full Mechanical Verdict

| gate | verdict | evidence |
|---|---|---|
| D5/D6 leakage/redaction | PASS | lane self-audit records 75/75 pass; sampled review found no raw/PII/secret leak |
| D7 required fields | PASS | 75/75 rows have row/provenance sha fields used by controller injection |
| D9 ledger closure | PASS | 75/75 ledger rows; `candidate_row_sha` matches candidate rows |
| A10 hash integrity | PASS | `hash_recipe_ref` / `hash_recomputed_by_pipeline` present on candidate rows |
| A11 quota | PASS_WITH_D087_DEVIATION | final distribution matches D-087, not original stale query quota |
| A12 args/parent audit | PASS | ledger closed; sampled rows have expected args/value shape |
| R2B class shape | PASS | query rows are read-only `query_*`; refusal/unsupported/already_state rows are `NO_TOOL` with non-null `no_call` |
| R2B query reclass | PASS | no-query families reclass query-like requests to unsupported/no-call; manifest binds D-087 |
| R2B pair ledger | PASS | `pair_group_count=16`, `pair_rows=32`, `pair_completeness=100%` |
| R2B query shape report | PASS | `query_rows=4`, `no_call_rows=21`, `failure_count=0` |
| class-ratio cap | WARNING_WAIVED | candidate no-call ratio `29.5775%`; D-087/receipt says 20% cap is train-pack gate, not candidate-pool gate |

## Semantic Sample

Sample row ids:

```text
r2b-s1-lane-b-0001
r2b-s1-lane-b-0002
r2b-s1-lane-b-0005
r2b-s1-lane-b-0006
r2b-s1-lane-b-0010
r2b-s1-lane-b-0016
r2b-s1-lane-b-0017
r2b-s1-lane-b-0025
r2b-s1-lane-b-0026
r2b-s1-lane-b-0031
r2b-s1-lane-b-0032
r2b-s1-lane-b-0040
r2b-s1-lane-b-0046
r2b-s1-lane-b-0047
r2b-s1-lane-b-0055
r2b-s1-lane-b-0061
r2b-s1-lane-b-0062
r2b-s1-lane-b-0063
r2b-s1-lane-b-0070
r2b-s1-lane-b-0071
```

Coverage:

- screen little/number and gear/min/max: covered.
- volume relative/absolute and volume query: covered.
- wiper relative/absolute and no-query unsupported: covered.
- sunroof open/close and no-query unsupported: covered.
- fragrance open/close/strength and fragrance query: covered.
- Complete contrastive pairs sampled: `screen_SLN_1`, `screen_SGM_1`, `volume_VRA_1`, `wiper_WRA_1`, `sunroof_SOC_1`, `fragrance_FOC_1`.

## Findings

No sampled semantic FAIL found.

Observed notes:

- D-087 query reclassification is correctly reflected: screen/wiper/sunroof query-like rows are `unsupported` + `NO_TOOL`; volume/fragrance query rows use mounted read-only `query_*`.
- Sampled contrastive pairs differ by the intended boundary cue: relative-vs-absolute, min/max-vs-number, or open-vs-close.
- Candidate-pool no-call ratio exceeds 20%, but this is not a lane-b judge fail because D-087/receipt scopes the cap to train-pack assembly.

## Output Artifacts

| artifact | path |
|---|---|
| row score ledger | `r2b-s1-lane-b/judge-openai-r2b-s1-lane-b-row-scores.jsonl` |
| mechanical audit summary | `r2b-s1-lane-b/judge-openai-r2b-s1-lane-b-mechanical-audit.json` |

## Final

```text
verdict: PASS_WITH_NOTES
blocking_failure: none in full mechanical gates or sampled semantic review
mechanical_claim: full 75/75 mechanical gates pass except class-ratio candidate-pool warning waived by D-087 train-pack cap ruling
semantic_claim: sampled 20/75 pass; not a full semantic pass
next_action: lane-b may proceed to controller aggregation/full-pack path, subject to cross-lane handling of lane-a sampled semantic failure
```

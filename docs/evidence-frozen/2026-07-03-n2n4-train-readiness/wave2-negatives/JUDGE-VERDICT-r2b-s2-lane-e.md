# JUDGE VERDICT — R2b S2 lane-e

verdict: **PASS_WITH_NOTES**
judge_owner: `%43` OpenAI-family judge
proof_class: local/pre_training_batch_judge
spec: `wave2-negatives/JUDGE-SPEC-r2b-s2-lane-e.md`
candidate_pool_sha256: `a0800339c9da7082488a7fd188a9221a3ee9f05dc6bd297d1fafca14afb1a0be`
semantic_reviewed_count: `20`
claim_boundary: full mechanical claims are 75/75; semantic claims are sampled 20/75 only and must not be promoted to full semantic pass.

## Basis

| item | result |
|---|---|
| candidates sha | PASS: `a0800339c9da7082488a7fd188a9221a3ee9f05dc6bd297d1fafca14afb1a0be` |
| SHA256SUMS 5/5 | PASS |
| row counts | PASS: candidates `75`, ledger `75` |
| quota | PASS: `45 positive / 8 query / 4 refusal / 7 already_state / 5 unsupported / 6 followup` |
| query bucket | PASS: `query_current_volume=8` |
| row hash / ledger closure | PASS: 75/75 candidate row hashes recompute; 75/75 ledger row hashes match |
| gate context | PASS: gate report status `pass`, failed gates `[]`; class-ratio warning is waived by D-087 gate policy |

## Mechanical Verdict

| gate | verdict | evidence |
|---|---|---|
| R2B-DEVREF-01 | PASS | lane-e uses batch-level row stamping: `D-087` on 75/75 rows; legal by ruling |
| R2B-NVC-01 | PASS | `true=12`, `value_is_cue=14`; `volume_query_current_vs_adjust` has no NVC and is legal behavior-boundary default |
| query shape | PASS | 8/8 query rows call `query_current_volume`; no mutating query leakage |
| no-call shape | PASS | refusal/already_state/unsupported rows have empty expected calls and non-null `no_call` |
| pair ledger | PASS | `pair_rows=30`, `pair_group_count=15`, `pair_completeness=100%` |
| position slot | PASS | explicit position/screen/device rows carry corresponding argument or are legal no-call |

## Semantic Sample

Reviewed rows:

```text
r2b-s2-e-001,r2b-s2-e-002,r2b-s2-e-003,r2b-s2-e-004,
r2b-s2-e-009,r2b-s2-e-010,r2b-s2-e-011,r2b-s2-e-012,
r2b-s2-e-031,r2b-s2-e-032,r2b-s2-e-037,r2b-s2-e-038,
r2b-s2-e-061,r2b-s2-e-062,r2b-s2-e-063,r2b-s2-e-064,
r2b-s2-e-025,r2b-s2-e-057,r2b-s2-e-073,r2b-s2-e-075
```

Semantic verdict:

- PASS: window repair rows hold visible numeric values where required.
- PASS: window and atmosphere `value_is_cue` rows use little/number or extremum/number as the tested cue, not random drift.
- PASS: volume query-vs-adjust rows separate read-only query from mutating action; NVC absent is legal.
- PASS: sampled no-call rows are coherent unsupported/refusal envelopes.
- PASS: sampled followup row remains an explicit lower-volume action.

## Output Artifacts

| artifact | path |
|---|---|
| row score ledger | `r2b-s2-lane-e/judge-openai-r2b-s2-lane-e-row-scores.jsonl` |
| mechanical audit summary | `r2b-s2-lane-e/judge-openai-r2b-s2-lane-e-mechanical-audit.json` |

## Final

```text
verdict: PASS_WITH_NOTES
blocking_failure: none
mechanical_claim: full 75/75 mechanical gates pass; class-ratio candidate-pool warning remains waived by gate orchestrator
semantic_claim: sampled 20/75 pass; not a full semantic pass
```

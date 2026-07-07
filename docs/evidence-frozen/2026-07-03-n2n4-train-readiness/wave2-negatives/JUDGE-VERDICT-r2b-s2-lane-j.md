# JUDGE VERDICT R2b S2 lane-j

status: PASS_WITH_W19_WATCH
artifact_kind: openai_judge_verdict
judge_owner: `%43`
proof_class: local/pre_training_batch_judge
spec: `wave2-negatives/JUDGE-SPEC-r2b-s2-lane-j.md`

## Verdict

`r2b-s2-lane-j` passes this judge round.

The full mechanical checks close over 75/75 rows. The semantic sample is 50/75 per the instantiated spec mandatory coverage. No sampled semantic FAIL was found.

## Binding

| artifact | value |
|---|---|
| candidates | `r2b-s2-lane-j/candidates.jsonl` |
| candidates sha256 | `b9485a771dabe04e8372b7ff3b4331c2cac3af3682948fd1557b74b1ba9f7294` |
| value ledger sha256 | `0dee17751889879f3afed398ca3e6a90b7497780d87b65fd10d59ab9d9df6a4a` |
| SHA256SUMS sha256 | `4eb469d5f473891eeaea038ef3efa2e4f691a304b4b0de257c5ef3b3fc20c852` |
| contract sha256 | `a242ba0c62fecda08f860e583176b99e13ca4c6708e0313f1d76cb98f77d0814` |
| gate report | `r2b-s2-lane-j/gates-v2-report.json` |
| mechanical audit | `r2b-s2-lane-j/judge-openai-r2b-s2-lane-j-mechanical-audit.json` |
| row scores | `r2b-s2-lane-j/judge-openai-r2b-s2-lane-j-row-scores.jsonl` |

`shasum -a 256 -c SHA256SUMS.txt` passed for `candidates.jsonl`, `value_change_ledger.jsonl`, `batch_manifest.json`, `batch_self_audit.md`, and `generation_receipt.md`.

## Mechanical Checks

| check | result |
|---|---|
| candidate sha matches assigned final sha | PASS |
| row count / ledger count | PASS, 75/75 |
| `candidate_row_sha` recompute | PASS, 75/75 |
| ledger `candidate_row_sha` parity | PASS, 75/75 |
| quota | PASS, `34/20/5/5/6/5` |
| family allocation | PASS, sunroof_sunshade 15 / fragrance 60 |
| query contract | PASS, `query_amount_of_fragrance=10` and `query_mode_of_fragrance=10`; all query rows are fragrance-only and non-mutating |
| no-call envelope | PASS |
| NVC `R2B-NVC-01` | PASS |
| DEVREF `R2B-DEVREF-01` | PASS |
| gates v2 | PASS; `class_ratio_report` waived under D-087 as candidate-pool-only |
| tool contract existence | PASS, expected and mounted tool names all exist in `contracts/semantic-function-contract.jsonl` |

## Semantic Sample

Sample row ids:

```text
r2b-s2-j-001,r2b-s2-j-002,r2b-s2-j-003,r2b-s2-j-004,r2b-s2-j-016,r2b-s2-j-017,r2b-s2-j-018,r2b-s2-j-019,r2b-s2-j-020,r2b-s2-j-021,r2b-s2-j-022,r2b-s2-j-023,r2b-s2-j-024,r2b-s2-j-025,r2b-s2-j-026,r2b-s2-j-027,r2b-s2-j-028,r2b-s2-j-029,r2b-s2-j-030,r2b-s2-j-031,r2b-s2-j-032,r2b-s2-j-033,r2b-s2-j-034,r2b-s2-j-035,r2b-s2-j-036,r2b-s2-j-037,r2b-s2-j-038,r2b-s2-j-039,r2b-s2-j-040,r2b-s2-j-041,r2b-s2-j-042,r2b-s2-j-043,r2b-s2-j-044,r2b-s2-j-045,r2b-s2-j-046,r2b-s2-j-047,r2b-s2-j-048,r2b-s2-j-049,r2b-s2-j-050,r2b-s2-j-051,r2b-s2-j-052,r2b-s2-j-053,r2b-s2-j-054,r2b-s2-j-055,r2b-s2-j-056,r2b-s2-j-057,r2b-s2-j-058,r2b-s2-j-059,r2b-s2-j-060,r2b-s2-j-061
```

Result: 50/50 sampled rows PASS.

Sample class mix: `{'positive': 27, 'query': 20, 'followup': 3}`.

Coverage:

| focus | result |
|---|---|
| `sunroof_sunshade_tail_completion` | PASS, 4 sampled rows |
| `fragrance_query_amount_vs_adjust` | PASS, 20 sampled rows |
| `fragrance_query_mode_vs_adjust` | PASS, 20 sampled rows |
| `fragrance_open_close_strength_boundary` | PASS, 6 sampled rows |

## Notes

- W19 fragrance mode query diversity watch is informational: sampled mode-query rows are tool-correct and non-mutating; close paraphrases are not treated as a defect because mechanical near-dup gates passed.
- Lane-j batch_manifest artifact_shas.candidates_jsonl is pre-injection stale; direct shasum, SHA256SUMS.txt, and the assigned candidate_pool_sha256 bind the final candidate pool.

Claim boundary: this is a pre-training batch judge verdict. It is not train-ready, V-PASS, C6 acceptance, or a full semantic claim over every row.

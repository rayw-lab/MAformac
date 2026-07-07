# JUDGE VERDICT R2b S2 lane-i

status: PASS_WITH_NOTES
artifact_kind: openai_judge_verdict
judge_owner: `%43`
proof_class: local/pre_training_batch_judge
spec: `wave2-negatives/JUDGE-SPEC-r2b-s2-lane-i.md`

## Verdict

`r2b-s2-lane-i` passes this judge round.

The full mechanical checks close over 75/75 rows. The semantic sample is 30/75 per the instantiated spec mandatory coverage. No sampled semantic FAIL was found.

## Binding

| artifact | value |
|---|---|
| candidates | `r2b-s2-lane-i/candidates.jsonl` |
| candidates sha256 | `e411de63c62db74bab8408ff9395d421b7fb1ff36a4d72dd966032f724e5890d` |
| value ledger sha256 | `0da8c5d312835887fa13038c968c2a5c064bf90b812a71adb69e558e1426c16b` |
| SHA256SUMS sha256 | `f7986a747c47d23068d514da0ed8af24948b8efd98add8c236e0862181b51882` |
| contract sha256 | `a242ba0c62fecda08f860e583176b99e13ca4c6708e0313f1d76cb98f77d0814` |
| gate report | `r2b-s2-lane-i/gates-v2-report.json` |
| mechanical audit | `r2b-s2-lane-i/judge-openai-r2b-s2-lane-i-mechanical-audit.json` |
| row scores | `r2b-s2-lane-i/judge-openai-r2b-s2-lane-i-row-scores.jsonl` |

`shasum -a 256 -c SHA256SUMS.txt` passed for `candidates.jsonl`, `value_change_ledger.jsonl`, `batch_manifest.json`, `batch_self_audit.md`, and `generation_receipt.md`.

## Mechanical Checks

| check | result |
|---|---|
| candidate sha matches assigned final sha | PASS |
| row count / ledger count | PASS, 75/75 |
| `candidate_row_sha` recompute | PASS, 75/75 |
| ledger `candidate_row_sha` parity | PASS, 75/75 |
| quota | PASS, `52/0/4/7/6/6` |
| family allocation | PASS, door 30 / sunroof_sunshade 45 |
| query contract | PASS, no `class_id=query`, no expected `query_*`, no mounted `query_*` |
| no-call envelope | PASS |
| NVC `R2B-NVC-01` | PASS |
| DEVREF `R2B-DEVREF-01` | PASS |
| gates v2 | PASS; `class_ratio_report` waived under D-087 as candidate-pool-only |
| tool contract existence | PASS, expected and mounted tool names all exist in `contracts/semantic-function-contract.jsonl` |

## Semantic Sample

Sample row ids:

```text
r2b-s2-i-005,r2b-s2-i-006,r2b-s2-i-007,r2b-s2-i-008,r2b-s2-i-009,r2b-s2-i-010,r2b-s2-i-001,r2b-s2-i-002,r2b-s2-i-003,r2b-s2-i-004,r2b-s2-i-031,r2b-s2-i-032,r2b-s2-i-033,r2b-s2-i-034,r2b-s2-i-035,r2b-s2-i-036,r2b-s2-i-037,r2b-s2-i-038,r2b-s2-i-039,r2b-s2-i-040,r2b-s2-i-041,r2b-s2-i-042,r2b-s2-i-043,r2b-s2-i-044,r2b-s2-i-045,r2b-s2-i-046,r2b-s2-i-047,r2b-s2-i-048,r2b-s2-i-049,r2b-s2-i-050
```

Result: 30/30 sampled rows PASS.

Sample class mix: `{'positive': 26, 'unsupported': 4}`.

Coverage:

| focus | result |
|---|---|
| `door_lock_open_confusion_negative` | PASS, 6 sampled rows |
| `door_query_style_unsupported` | PASS, 4 sampled rows |
| `sunroof_sunshade_open_close_separation` | PASS, 16 sampled rows |
| `sunroof_sunshade_unsupported_edge` | PASS, 4 sampled rows |

## Notes

- Door-family assertions use contract existence by tool name under R2B-DOOR-ERRATA-01; no hand-written door allowlist is used.
- Rows r2b-s2-i-001/r2b-s2-i-002 carry stale near_parallel prose mentioning no generic car-door open/close surface; expected/mounted tool names are contract-present and the query-vs-action labels remain coherent, so this is receipt metadata debt, not a data FAIL.

Claim boundary: this is a pre-training batch judge verdict. It is not train-ready, V-PASS, C6 acceptance, or a full semantic claim over every row.

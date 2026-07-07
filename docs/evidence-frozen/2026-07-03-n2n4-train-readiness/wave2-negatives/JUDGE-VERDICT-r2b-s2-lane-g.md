# JUDGE VERDICT R2b S2 lane-g

status: PASS_WITH_NOTES
artifact_kind: openai_judge_verdict
judge_owner: `%43`
proof_class: local/pre_training_batch_judge
spec: `wave2-negatives/JUDGE-SPEC-r2b-s2-lane-g.md`

## Verdict

`r2b-s2-lane-g` passes this judge round.

The full mechanical checks close over 75/75 rows. The semantic sample is intentionally oversampled to 22/75, because batch3 mandatory focus floors require full coverage of volume, wiper front/rear position, wiper unsafe refusal, and seat unsupported/already-state pairs.

## Binding

| artifact | value |
|---|---|
| candidates | `r2b-s2-lane-g/candidates.jsonl` |
| candidates sha256 | `368bde0e31d4f178af3e30a1a06ddbff75c356806fd5d4d80684893b40dc78b5` |
| value ledger sha256 | `a69e2dd68404d8eae61d3c7ad9040ca9bb02911686713b4ad4926e3e357ac03b` |
| gate report | `r2b-s2-lane-g/gates-v2-report.json` |
| mechanical audit | `r2b-s2-lane-g/judge-openai-r2b-s2-lane-g-mechanical-audit.json` |
| row scores | `r2b-s2-lane-g/judge-openai-r2b-s2-lane-g-row-scores.jsonl` |

`shasum -a 256 -c SHA256SUMS.txt` passed for `candidates.jsonl`, `value_change_ledger.jsonl`, `batch_manifest.json`, `batch_self_audit.md`, and `generation_receipt.md`.

## Mechanical Checks

| check | result |
|---|---|
| candidate sha matches assigned final sha | PASS |
| row count / ledger count | PASS, 75/75 |
| `candidate_row_sha` recompute | PASS, 75/75 |
| ledger `candidate_row_sha` parity | PASS, 75/75 |
| quota | PASS, `50/0/5/8/6/6` |
| family allocation | PASS, volume 15 / wiper 45 / seat 15 |
| zero query | PASS, no `class_id=query`, no expected `query_*`, no mounted `query_*` |
| no-call envelope | PASS |
| NVC `R2B-NVC-01` | PASS |
| DEVREF `R2B-DEVREF-01` | PASS |
| gates v2 | PASS; `class_ratio_report` waived under D-087 as candidate-pool-only |

## Semantic Sample

Sample row ids:

```text
r2b-s2-g-001,r2b-s2-g-002,r2b-s2-g-003,r2b-s2-g-004,
r2b-s2-g-005,r2b-s2-g-006,
r2b-s2-g-016,r2b-s2-g-017,r2b-s2-g-018,r2b-s2-g-019,
r2b-s2-g-020,r2b-s2-g-021,r2b-s2-g-022,r2b-s2-g-023,
r2b-s2-g-024,r2b-s2-g-025,r2b-s2-g-026,r2b-s2-g-027,
r2b-s2-g-061,r2b-s2-g-062,r2b-s2-g-063,r2b-s2-g-064
```

Result: 22/22 sampled rows PASS.

Coverage:

| focus | result |
|---|---|
| `volume_relative_vs_absolute` | PASS, numeric value held constant |
| `volume_already_state_noop` | PASS |
| `wiper_front_rear_position_slot` | PASS, front/rear is the only slot cue; values held |
| `wiper_unsafe_refusal` | PASS |
| `seat_query_style_unsupported` | PASS |
| `seat_already_state_noop` | PASS |

## Notes

`batch_manifest.json` has stale `artifact_shas.candidates_jsonl` values from before controller injection. This is not used as the final binding here: direct `shasum`, `SHA256SUMS.txt`, and controller receipt `after.sha256sums_after` bind the final candidate pool. Keep this as a receipt-quality wart for future cleanup, not as a blocking defect for lane-g.

Claim boundary: this is a pre-training batch judge verdict. It is not train-ready, V-PASS, or a full semantic claim over every row.

# JUDGE VERDICT — R2b S2 lane-f

verdict: **PASS_WITH_NOTES**
judge_owner: `%43` OpenAI-family judge
proof_class: local/pre_training_batch_judge
spec: `wave2-negatives/JUDGE-SPEC-r2b-s2-lane-f.md`
candidate_pool_sha256: `d32bdedc2cf418703464a1f0986b82eb00d65a395f26fb8e6b267a01932cd0d7`
semantic_reviewed_count: `20`
claim_boundary: full mechanical claims are 75/75; semantic claims are sampled 20/75 only and must not be promoted to full semantic pass.

## Basis

| item | result |
|---|---|
| candidates sha | PASS: `d32bdedc2cf418703464a1f0986b82eb00d65a395f26fb8e6b267a01932cd0d7` |
| SHA256SUMS 5/5 | PASS |
| row counts | PASS: candidates `75`, ledger `75` |
| quota | PASS: `43 positive / 12 query / 4 refusal / 6 already_state / 6 unsupported / 4 followup` |
| query bucket | PASS: `query_current_volume=12` |
| row hash / ledger closure | PASS: 75/75 candidate row hashes recompute; 75/75 ledger row hashes match |
| gate context | PASS: gate report status `pass`, failed gates `[]`; class-ratio warning is waived by D-087 gate policy |

## Mechanical Verdict

| gate | verdict | evidence |
|---|---|---|
| R2B-DEVREF-01 | PASS | lane-f uses affected-row-only stamping: `D-087` on 2/75 rows, null on 73/75; legal by ruling |
| R2B-NVC-01 | PASS | `true=10`, `value_is_cue=10`; `volume_query_current_vs_adjust` has no NVC and is legal behavior-boundary default |
| query shape | PASS | 12/12 query rows call `query_current_volume`; no mutating query leakage |
| no-call shape | PASS | refusal/already_state/unsupported rows have empty expected calls and non-null `no_call` |
| pair ledger | PASS | `pair_rows=26`, `pair_group_count=13`, `pair_completeness=100%` |
| position slot | PASS | explicit position/device rows carry corresponding argument or are legal no-call |

## Semantic Sample

Reviewed rows:

```text
r2b-s2-f-001,r2b-s2-f-002,r2b-s2-f-005,r2b-s2-f-006,
r2b-s2-f-031,r2b-s2-f-032,r2b-s2-f-033,r2b-s2-f-034,
r2b-s2-f-037,r2b-s2-f-038,r2b-s2-f-039,r2b-s2-f-040,
r2b-s2-f-061,r2b-s2-f-062,r2b-s2-f-063,r2b-s2-f-064,
r2b-s2-f-026,r2b-s2-f-055,r2b-s2-f-073,r2b-s2-f-043
```

Semantic verdict:

- PASS: atmosphere little/number and gear/number rows use `value_is_cue` correctly.
- PASS: volume relative/absolute rows hold numeric values where required.
- PASS: volume query-vs-adjust rows separate read-only query from mutating action; NVC absent is legal.
- PASS: wiper relative/absolute rows hold position/value and vary only relative-vs-absolute cue.
- PASS: sampled no-call rows are coherent safety or unsupported-query envelopes, including both row-level `D-087` affected rows.
- PASS: standalone volume query row is read-only.

## Output Artifacts

| artifact | path |
|---|---|
| row score ledger | `r2b-s2-lane-f/judge-openai-r2b-s2-lane-f-row-scores.jsonl` |
| mechanical audit summary | `r2b-s2-lane-f/judge-openai-r2b-s2-lane-f-mechanical-audit.json` |

## Final

```text
verdict: PASS_WITH_NOTES
blocking_failure: none
mechanical_claim: full 75/75 mechanical gates pass; class-ratio candidate-pool warning remains waived by gate orchestrator
semantic_claim: sampled 20/75 pass; not a full semantic pass
```

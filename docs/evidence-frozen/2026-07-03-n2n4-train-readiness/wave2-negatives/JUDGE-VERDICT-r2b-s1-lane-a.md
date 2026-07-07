# JUDGE VERDICT — R2b S1 lane-a

verdict: **FAIL_SAMPLED_SEMANTIC**
judge_owner: `%43` OpenAI-family judge
proof_class: local/pre_training_batch_judge
spec: `wave2-negatives/JUDGE-SPEC-r2b-s1-lane-a.md`
candidate_pool_sha256: `2f08215d702afff1816c1dcba00b8c6176d5273d8daec2563e1891d277be5bd5`
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
| class distribution | `45 positive / 2 query / 5 refusal / 5 already_state / 13 unsupported / 5 followup` |
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
| R2B pair ledger | PASS | `pair_group_count=14`, `pair_rows=28`, `pair_completeness=100%` |
| R2B query shape report | PASS | `query_rows=2`, `no_call_rows=23`, `failure_count=0` |
| class-ratio cap | WARNING_WAIVED | candidate no-call ratio `31.5068%`; D-087/receipt says 20% cap is train-pack gate, not candidate-pool gate |

## Semantic Sample

Sample row ids:

```text
r2b-s1-a-001
r2b-s1-a-002
r2b-s1-a-005
r2b-s1-a-006
r2b-s1-a-007
r2b-s1-a-008
r2b-s1-a-009
r2b-s1-a-010
r2b-s1-a-011
r2b-s1-a-016
r2b-s1-a-017
r2b-s1-a-025
r2b-s1-a-031
r2b-s1-a-032
r2b-s1-a-033
r2b-s1-a-035
r2b-s1-a-037
r2b-s1-a-040
r2b-s1-a-055
r2b-s1-a-070
```

Coverage:

- AC query and query-vs-action surface: covered.
- AC open/close and set_interface/defog: covered.
- Window to/by/little/simple: covered.
- No-query-family D-087 unsupported examples: seat/window/door/atmosphere covered.
- Complete contrastive pairs sampled: `ac_cool_1`, `ac_heat_1`, `ac_defog_1`, `seat_massage_1`, `win_to_1`.

## Finding

**F1 — sampled semantic FAIL: `win_to_1` is not a valid near-parallel pair.**

Rows:

| row | input | expected |
|---|---|---|
| `r2b-s1-a-031` | `把车窗开到三挡` | `open_window_to_number(value=3)` |
| `r2b-s1-a-032` | `车窗关到一挡` | `close_window_to_number(value=1)` |

Why this fails:

- The pair differs by open/close polarity and by numeric target `3 -> 1`.
- `R2B_NEAR_PARALLEL` requires sampled pair rows to differ only by the boundary cue, not by a random slot/value.
- The row's own `near_parallel_evidence` admits `+ number differ`, so the issue is visible in the artifact, not an inference from hidden context.

Impact:

- This does not invalidate all lane-a rows.
- It does invalidate the sampled semantic claim for lane-a.
- The right repair is to regenerate/fix the pair so the numeric value is held constant, for example `开到三挡` vs `关到三挡`, or remove the pair from near-parallel/pair-ledger claims if that is not semantically intended.

## Output Artifacts

| artifact | path |
|---|---|
| row score ledger | `r2b-s1-lane-a/judge-openai-r2b-s1-lane-a-row-scores.jsonl` |
| mechanical audit summary | `r2b-s1-lane-a/judge-openai-r2b-s1-lane-a-mechanical-audit.json` |

## Final

```text
verdict: FAIL_SAMPLED_SEMANTIC
blocking_failure: R2B_NEAR_PARALLEL sampled fail on win_to_1 rows r2b-s1-a-031/r2b-s1-a-032
mechanical_claim: full 75/75 mechanical gates pass except class-ratio candidate-pool warning waived by D-087 train-pack cap ruling
semantic_claim: sampled 20/75; not a full semantic pass
next_action: repair lane-a win_to_1 near-parallel value drift, refresh candidates/ledger/sha, rerun scoped judge on changed pair + hash closure
```

## RE-JUDGE @F1 repair

current_verdict: **PASS_AFTER_F1_REPAIR**
scope: scoped re-judge only; original verdict findings outside F1 were not reopened.
candidate_pool_sha256_after_repair: `bd38bdbf57a998313b7db93b489e3fe6f9b276fcd860731bbc1c09a3727d341b`
repair_receipt: `r2b-s1-lane-a/F1-REPAIR-RECEIPT.md`
proof_class: local/scoped_rejudge_no_training_no_full_rescore

### Bound Checks

| check | result |
|---|---|
| candidates sha | PASS: current `candidates.jsonl` sha matches `bd38bdbf57a998313b7db93b489e3fe6f9b276fcd860731bbc1c09a3727d341b` |
| SHA256SUMS 5/5 | PASS: `candidates.jsonl`, `value_change_ledger.jsonl`, `batch_manifest.json`, `batch_self_audit.md`, `generation_receipt.md` all match current bytes |
| repair receipt | PASS: records target row `r2b-s1-a-032`, old/new values, row sha update, pair ledger pass, supervision scanner pass |
| byte-scope proof | PASS: independent compare against `_scratch/f1-repair-before-20260704/` shows only line 32 changed in `candidates.jsonl` and `value_change_ledger.jsonl`; non-target 74/75 lines are byte-identical |

### F1 Pair Re-check

| row | input | expected |
|---|---|---|
| `r2b-s1-a-031` | `把车窗开到三挡` | `open_window_to_number(value=3)` |
| `r2b-s1-a-032` | `车窗关到三挡` | `close_window_to_number(value=3)` |

Verdict:

- PASS: the repaired `win_to_1` pair now holds the numeric target constant at `3`.
- PASS: the only semantic boundary cue in the actual row fields is now open vs close: `开到` vs `关到`.
- PASS: `value_change_ledger.jsonl` row `r2b-s1-a-032` is updated to `value=3` and has matching `candidate_row_sha=7e8c19929b8b811157a5613c8842f17c9da468cbc5909b9d274da25d82a820e4`.

Non-blocking note:

- `r2b-s1-a-031` was intentionally not edited to preserve 74/75 byte scope. Its `near_parallel_evidence` text still says `+ number differ`, which is now stale relative to the repaired actual fields. I do not treat this as an F1 blocker because the scoped failure was the actual pair value drift, and the actual pair now satisfies the single-cue requirement. Clean this text before any process that treats `near_parallel_evidence` prose as an executable semantic assertion.

### Scoped Final

```text
verdict: PASS_AFTER_F1_REPAIR
reopened_scope: F1 only, rows r2b-s1-a-031/r2b-s1-a-032 + repair receipt/binding
non_reopened_scope: all other lane-a judge findings and lane-a coverage remain as previously recorded
blocking_failure: none in scoped F1 repair
residual_note: row 031 evidence prose is stale but non-blocking for this scoped re-judge
```

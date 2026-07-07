# JUDGE VERDICT — R2b S2 lane-c

verdict: **PASS_WITH_NOTES**
judge_owner: `%43` OpenAI-family judge
proof_class: local/pre_training_batch_judge
spec: `wave2-negatives/JUDGE-SPEC-r2b-s2-lane-c.md`
commander_ruling: `R2B-NVC-01`
candidate_pool_sha256: `0c1c9326aafd80a3770b57b65980175e669984f9b19f44e87e95b0fe9a2572f9`
candidate_count_denominator: `75`
semantic_sample_size_formula: `judge_sampling_rev2.1_family_min50_max20_10pct`
semantic_sample_size_nominal: `20`
semantic_reviewed_count: `21`
claim_boundary: full mechanical claims are 75/75; semantic claims are sampled 21/75 only and must not be promoted to full semantic pass.

## Basis

| item | result |
|---|---|
| candidates sha | PASS: `0c1c9326aafd80a3770b57b65980175e669984f9b19f44e87e95b0fe9a2572f9` |
| value ledger sha | PASS: `7f5d4e50b1c035536eb7e3f4aa11c5788a5051400053373616ef7643d34cfc04` |
| SHA256SUMS sha | PASS: `5698d0abdcf8f104fcac989c7a9fbbd24a7c164103d4932e79e3231a9424c311` |
| row counts | PASS: `candidates.jsonl=75`, `value_change_ledger.jsonl=75` |
| SHA256SUMS entries | PASS: listed `candidates.jsonl`, `value_change_ledger.jsonl`, `batch_manifest.json`, `batch_self_audit.md`, `generation_receipt.md` all match current bytes |
| D-087 deviation | not required for lane-c; delivered quota matches order |
| class distribution | PASS: `38 positive / 15 query / 4 refusal / 6 already_state / 7 unsupported / 5 followup` |
| row hash closure | PASS: 75/75 `candidate_row_sha` recompute matches; 75/75 ledger `candidate_row_sha` matches candidates |

## Re-judge Context

Initial lane-c judge failed mechanically because all numeric focus rows lacked a machine-readable `numeric_value_constant` field.

Commander ruling `R2B-NVC-01` refined the assertion:

- `numeric_value_constant=true` is required when the numeric value should be held constant across mates.
- `numeric_value_constant=value_is_cue` is legal when the numeric difference itself is the tested cue, for example little-vs-number or extremum-vs-number.
- Missing field still fails.

The repaired candidates now satisfy that rule:

| rows | value | meaning |
|---|---|---|
| `r2b-s2-c-031..034` | `value_is_cue` | screen little-vs-number and extremum-vs-number pairs |
| `r2b-s2-c-061..064` | `true` | window numeric pairs with target values held constant |

## Full Mechanical Verdict

| gate | verdict | evidence |
|---|---|---|
| D5/D6 leakage/redaction | PASS | lane gate context has no failed gates |
| D7 required fields | PASS | NVC field present with legal values on all 8 numeric focus rows |
| D9 ledger closure | PASS | 75/75 ledger rows; `candidate_row_sha` matches candidate rows |
| A10 hash integrity | PASS | row hash recipe recomputed locally with zero mismatches |
| A11 quota | PASS | delivered quota exactly matches lane-c order; no D-087 deviation dependency |
| A12 args/parent audit | PASS | ledger schema passes and ledger tool names match expected tool calls |
| R2B class shape | PASS | query rows are read-only `query_*`; refusal/unsupported/already_state rows are `NO_TOOL` with non-null `no_call` |
| R2B mandatory_first | PASS | rows `001-008` are `set_interface_vs_defog`, four groups `sivd_1..sivd_4`, order indexes `1..8` |
| R2B pair ledger | PASS | `pair_rows=16`, `pair_group_count=8`, `pair_completeness=100%` |
| R2B query shape report | PASS | `query_rows=15`, `no_call_rows=17`, `failure_count=0` |
| R2B no-call envelope | WARNING_WAIVED | class-ratio report says `28.3333%` candidate-pool no-call ratio; gate orchestrator records waiver and `status=pass` |
| R2B numeric_value_constant | PASS_UNDER_R2B_NVC_01 | legal values found on all numeric focus rows |

## Semantic Sample

Nominal rev2.1 sample size is 20. I reviewed 21 rows because the explicit coverage constraints add up to 21: mandatory-first 8 + NVC rows 8 + AC temperature/windspeed query 2 + no-call rows from ac/screen/window 3.

Sample row ids:

```text
r2b-s2-c-001
r2b-s2-c-002
r2b-s2-c-003
r2b-s2-c-004
r2b-s2-c-005
r2b-s2-c-006
r2b-s2-c-007
r2b-s2-c-008
r2b-s2-c-010
r2b-s2-c-018
r2b-s2-c-025
r2b-s2-c-050
r2b-s2-c-071
r2b-s2-c-031
r2b-s2-c-032
r2b-s2-c-033
r2b-s2-c-034
r2b-s2-c-061
r2b-s2-c-062
r2b-s2-c-063
r2b-s2-c-064
```

Coverage:

- Mandatory-first set-interface-vs-defog block: covered all 8 rows.
- AC query intents: covered `query_ac_temperature` and `query_ac_windspeed`.
- No-call envelope: covered ac refusal, screen refusal, and window refusal.
- NVC addendum: covered all `value_is_cue` screen rows and all `true` window rows.
- Complete contrastive pairs sampled: `sivd_1..4`, `scr_lvn_1`, `scr_gmn_1`, `wrf1_1`, `wrf1_2`.

Semantic verdict:

- PASS: set-interface/defog rows differ by the intended device-referent cue and keep polarity/slot shape stable inside pairs.
- PASS: query rows are read-only information requests, not hidden actuation.
- PASS: no-call rows are valid refusal envelopes with explicit reasons.
- PASS: screen NVC rows correctly use `value_is_cue`; the numeric/max/little distinction is the tested cue rather than random slot drift.
- PASS: window NVC rows hold numeric values constant where required: `4` for `wrf1_1`, `2` for `wrf1_2`.

## Output Artifacts

| artifact | path |
|---|---|
| row score ledger | `r2b-s2-lane-c/judge-openai-r2b-s2-lane-c-row-scores.jsonl` |
| mechanical audit summary | `r2b-s2-lane-c/judge-openai-r2b-s2-lane-c-mechanical-audit.json` |

## Final

```text
verdict: PASS_WITH_NOTES
blocking_failure: none after R2B-NVC-01 repair
mechanical_claim: full 75/75 mechanical gates pass; class-ratio candidate-pool warning remains waived by gate orchestrator
semantic_claim: sampled 21/75 pass; not a full semantic pass
next_action: lane-c can proceed as judge-accepted subject to normal cross-lane aggregation and train-pack gate discipline
```

## Re-judge @R2B-NVC-01

current_verdict: **PASS_WITH_NOTES**
scope: lane-c re-judge after `%45` NVC field repair and commander ruling `R2B-NVC-01`.
candidate_pool_sha256_after_repair: `0c1c9326aafd80a3770b57b65980175e669984f9b19f44e87e95b0fe9a2572f9`
proof_class: local/pre_training_batch_judge

### Bound Checks

| check | result |
|---|---|
| candidates sha | PASS: current `candidates.jsonl` sha matches `0c1c9326aafd80a3770b57b65980175e669984f9b19f44e87e95b0fe9a2572f9` |
| SHA256SUMS 5/5 | PASS: `candidates.jsonl`, `value_change_ledger.jsonl`, `batch_manifest.json`, `batch_self_audit.md`, `generation_receipt.md` all match current bytes |
| NVC field legality | PASS: `031-034=value_is_cue`, `061-064=true`; no numeric focus row missing/illegal |
| row hash closure | PASS: 75/75 `candidate_row_sha` recompute matches and ledger row hashes match |
| quota | PASS: `38/15/4/6/7/5`, no D-087 deviation required |
| mandatory_first | PASS: rows `001-008` are `set_interface_vs_defog`, four fresh groups `sivd_1..sivd_4` |

### Semantic Re-check

Reviewed rows: 21/75. Nominal formula gives 20, with one addendum row to satisfy all explicit coverage constraints.

Verdict:

- PASS: mandatory-first set-interface/defog rows preserve the intended referent boundary.
- PASS: AC query rows are read-only `query_*`, not hidden actuation.
- PASS: ac/screen/window no-call rows have coherent refusal envelopes.
- PASS: `value_is_cue` rows use numeric/max/little as the tested cue, not random drift.
- PASS: `true` rows hold the numeric value constant where required.

### Re-judge Final

```text
verdict: PASS_WITH_NOTES
blocking_failure: none after R2B-NVC-01 repair
mechanical_claim: full 75/75 mechanical gates pass; class-ratio warning remains gate-waived
semantic_claim: sampled 21/75 pass; not a full semantic pass
```

# JUDGE VERDICT — R2b S2 lane-d

verdict: **PASS_WITH_NOTES**
judge_owner: `%43` OpenAI-family judge
proof_class: local/pre_training_batch_judge
spec: `wave2-negatives/JUDGE-SPEC-r2b-s2-lane-d.md`
commander_ruling: `R2B-NVC-01`
candidate_pool_sha256: `108653259f808e9e1e8b051b252561c09c40c78f147d563d2d05455ee3dad06a`
candidate_count_denominator: `75`
semantic_sample_size_formula: `judge_sampling_rev2.1_family_min50_max20_10pct`
semantic_reviewed_count: `20`
claim_boundary: full mechanical claims are 75/75; semantic claims are sampled 20/75 only and must not be promoted to full semantic pass.

## Basis

| item | result |
|---|---|
| candidates sha | PASS: `108653259f808e9e1e8b051b252561c09c40c78f147d563d2d05455ee3dad06a` |
| value ledger sha | PASS: `0af8b90cef42e02da05128721bf0a80f9a6a55648babbc4da127558e39f46a80` |
| SHA256SUMS sha | PASS: `9a286bfc333a7b403e4aa71e97b695d3824b8c5b57a37f168331645e724f9927` |
| row counts | PASS: `candidates.jsonl=75`, `value_change_ledger.jsonl=75` |
| SHA256SUMS entries | PASS: listed `candidates.jsonl`, `value_change_ledger.jsonl`, `batch_manifest.json`, `batch_self_audit.md`, `generation_receipt.md` all match current bytes |
| class distribution | PASS: `37 positive / 15 query / 5 refusal / 6 already_state / 7 unsupported / 5 followup` |
| query buckets | PASS: `query_ac_temperature=7`, `query_ac_windspeed=8` |
| row hash closure | PASS: 75/75 `candidate_row_sha` recompute matches; 75/75 ledger `candidate_row_sha` matches candidates |

## Full Mechanical Verdict

| gate | verdict | evidence |
|---|---|---|
| D5/D6 leakage/redaction | PASS | lane gate context has no failed gates |
| D7 required fields | PASS | NVC field present with legal values on all 8 numeric focus rows |
| D9 ledger closure | PASS | 75/75 ledger rows; `candidate_row_sha` matches candidate rows |
| A10 hash integrity | PASS | row hash recipe recomputed locally with zero mismatches |
| A11 quota | PASS | delivered quota exactly matches lane-d order; no D-087 deviation dependency |
| A12 args/parent audit | PASS | ledger schema passes and ledger tool names match expected tool calls |
| R2B class shape | PASS | query rows are read-only `query_*`; refusal/unsupported/already_state rows are `NO_TOOL` with non-null `no_call` |
| R2B mandatory_continuation | PASS | rows `001-006` are `set_interface_vs_defog`, groups `sivd_5..7`, mfoi `9..14`, continuing lane-c `1..8` |
| R2B pair ledger | PASS | `pair_rows=14`, `pair_group_count=7`, `pair_completeness=100%` |
| R2B position slot | PASS | 16 explicit-position rows checked; no missing `direction` / `screen_type` / `position` slot on tool-call rows |
| R2B query shape report | PASS | `query_rows=15`, `no_call_rows=18`, `failure_count=0` |
| R2B no-call envelope | WARNING_WAIVED | class-ratio report says `30.0%` candidate-pool no-call ratio; gate orchestrator records D-087 waiver and `status=pass` |
| R2B numeric_value_constant | PASS_UNDER_R2B_NVC_01 | `031-034=value_is_cue`; `061-064=true`; no missing/illegal NVC focus row |

## Semantic Sample

Sample row ids:

```text
r2b-s2-d-001
r2b-s2-d-002
r2b-s2-d-003
r2b-s2-d-004
r2b-s2-d-005
r2b-s2-d-006
r2b-s2-d-010
r2b-s2-d-017
r2b-s2-d-025
r2b-s2-d-050
r2b-s2-d-070
r2b-s2-d-031
r2b-s2-d-032
r2b-s2-d-033
r2b-s2-d-034
r2b-s2-d-061
r2b-s2-d-062
r2b-s2-d-063
r2b-s2-d-064
r2b-s2-d-075
```

Coverage:

- Mandatory continuation set-interface-vs-defog block: covered all 6 lane-d rows.
- AC query intents: covered `query_ac_temperature` and `query_ac_windspeed`.
- No-call envelope: covered ac refusal, screen refusal, and window refusal.
- NVC addendum: covered all `value_is_cue` screen rows and all `true` window rows.
- Complete contrastive pairs sampled: `sivd_5..7`, `scr_lvn_2`, `scr_gmn_2`, `wrf1_3`, `wrf1_4`.
- Followup: covered window followup row `075`.

Semantic verdict:

- PASS: mandatory-continuation rows preserve the intended interface-vs-defog referent boundary and continue mfoi after lane-c.
- PASS: query rows are read-only information requests, not hidden actuation.
- PASS: no-call rows are valid refusal envelopes with explicit reasons.
- PASS: screen NVC rows correctly use `value_is_cue`; little/number and extremum/number are the intended cue.
- PASS: window NVC rows hold numeric values constant where required: `3` for `wrf1_3`, `5` for `wrf1_4`.
- PASS: followup row `075` remains a clear close-to-number action.

## Output Artifacts

| artifact | path |
|---|---|
| row score ledger | `r2b-s2-lane-d/judge-openai-r2b-s2-lane-d-row-scores.jsonl` |
| mechanical audit summary | `r2b-s2-lane-d/judge-openai-r2b-s2-lane-d-mechanical-audit.json` |

## Final

```text
verdict: PASS_WITH_NOTES
blocking_failure: none
mechanical_claim: full 75/75 mechanical gates pass; class-ratio candidate-pool warning remains waived by gate orchestrator
semantic_claim: sampled 20/75 pass; not a full semantic pass
next_action: lane-d can proceed as judge-accepted subject to normal cross-lane aggregation and train-pack gate discipline
```

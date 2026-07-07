# JUDGE VERDICT R2b S2 lane-h

status: PASS_AFTER_R2B_DOOR_ERRATA_01
artifact_kind: openai_judge_verdict
judge_owner: `%43`
proof_class: local/pre_training_batch_judge
spec: `wave2-negatives/JUDGE-SPEC-r2b-s2-lane-h.md`

## Verdict

Current verdict after `R2B-DOOR-ERRATA-01`: `r2b-s2-lane-h` passes this judge round.

The earlier `FAIL_DOOR_CONTRACT` was a judge-spec false positive caused by an unverified inline assertion that the door family has no generic car-door actuator surface. Contract grep shows the lane-h door tools are real contract intents.

## Binding

| artifact | value |
|---|---|
| candidates | `r2b-s2-lane-h/candidates.jsonl` |
| candidates sha256 | `508a5bb039de418d109b60cd87e63a5a050a4bc6b2c312f6a4d1acf070528594` |
| value ledger sha256 | `26c6a29bdd9064e4b4bd18543899ecdf1a99a47231abe08894814e2ef52a1a74` |
| gate report | `r2b-s2-lane-h/gates-v2-report.json` |
| mechanical audit | `r2b-s2-lane-h/judge-openai-r2b-s2-lane-h-mechanical-audit.json` |
| row scores | `r2b-s2-lane-h/judge-openai-r2b-s2-lane-h-row-scores.jsonl` |

`shasum -a 256 -c SHA256SUMS.txt` passed for `candidates.jsonl`, `value_change_ledger.jsonl`, `batch_manifest.json`, `batch_self_audit.md`, and `generation_receipt.md`.

## Mechanical Checks

| check | result |
|---|---|
| candidate sha matches assigned final sha | PASS |
| row count / ledger count | PASS, 75/75 |
| `candidate_row_sha` recompute | PASS, 75/75 |
| ledger `candidate_row_sha` parity | PASS, 75/75 |
| quota | PASS, `51/0/5/7/7/5` |
| family allocation | PASS, seat 45 / door 30 |
| zero query | PASS, no `class_id=query`, no expected `query_*`, no mounted `query_*` |
| no-call envelope | PASS |
| NVC `R2B-NVC-01` | PASS |
| DEVREF `R2B-DEVREF-01` | PASS |
| gates v2 | PASS; `class_ratio_report` waived under D-087 as candidate-pool-only |
| door contract existence assertion | PASS, all expected and mounted tool names exist in `contracts/semantic-function-contract.jsonl` |

## Superseded Finding

### Superseded: Original P1 was a false positive

This section is retained as audit history only. `R2B-DOOR-ERRATA-01` supersedes it because the cited door tools are contract-present.

Original evidence from full candidate scan:

| line | sample_id | bad expected tool | input |
|---:|---|---|---|
| 53 | `r2b-s2-h-053` | `open_car_door` | `到地方了把车门打开` |
| 55 | `r2b-s2-h-055` | `open_car_door` | `我要下车，车门先给我开一下` |
| 57 | `r2b-s2-h-057` | `open_car_door` | `车门帮我打开透透气` |
| 58 | `r2b-s2-h-058` | `close_car_door` | `把车门关上` |
| 64 | `r2b-s2-h-064` | `open_door_little` | `车门开大一点` |
| 65 | `r2b-s2-h-065` | `adjust_door_to_number` | `车门开到一半就行` |
| 68 | `r2b-s2-h-068` | `set_door_speed_to_number` | `车门开合速度调到2挡` |

Mounted generic door tool surfaces also appear on 16 rows, including lines 46, 47, 52-59, 64, 65, 68, 69, 71, and 74. Examples include `open_car_door`, `close_car_door`, `open_door_little`, `open_door_by_number`, `adjust_door_to_number`, `set_door_speed_to_gear`, and `set_door_speed_to_number`.

Why this no longer fails: each cited tool name exists in `contracts/semantic-function-contract.jsonl`. The correct hard assertion is contract existence by tool name, not a hand-written allowlist of tailgate/fuel/lock only.

Revised repair scope:

- No lane data repair is required for the cited door rows.
- The judge spec is repaired to require `semantic-function-contract.jsonl` existence checks.
- Future judge should fail missing or misspelled tool names, not contract-present generic door surfaces.

## Semantic Sample

Mandatory focus sample size is 24/75, because the required seat and door pair floors exceed the base 20-row formula.

Initial result was 16/24 sampled rows PASS and 8/24 false-positive FAIL. After `R2B-DOOR-ERRATA-01`, all 24/24 sampled rows PASS.

Previously failing sampled rows, now reclassified PASS by contract existence:

```text
r2b-s2-h-046,r2b-s2-h-047,
r2b-s2-h-052,r2b-s2-h-053,r2b-s2-h-054,r2b-s2-h-055,r2b-s2-h-056,r2b-s2-h-057
```

Passing sampled coverage:

| focus | result |
|---|---|
| `seat_heat_query_style_unsupported_and_already_state` | PASS |
| `seat_vent_query_style_unsupported_and_already_state` | PASS |
| `seat_posture_query_style_unsupported_and_already_state` | PASS |
| `seat_default_scope_position` | PASS |
| `door_query_style_unsupported` tailgate/fuel examples | PASS where real faces are used |

## Notes

`batch_manifest.json` has stale `artifact_shas.candidates_jsonl` values from before controller injection. Direct `shasum`, `SHA256SUMS.txt`, and controller receipt `after.sha256sums_after` bind the final candidate pool.

Claim boundary: this is a pre-training batch judge verdict. It is not train-ready, V-PASS, or a full semantic claim over every row.

## RE-JUDGE @R2B-DOOR-ERRATA-01

Verdict: `PASS_AFTER_R2B_DOOR_ERRATA_01`.

Errata basis:

- `contracts/semantic-function-contract.jsonl` sha256: `a242ba0c62fecda08f860e583176b99e13ca4c6708e0313f1d76cb98f77d0814`.
- The MAformac-uiue, MAformac, and PR38 code-basis copies of the contract have the same sha256.
- The originally flagged tools all exist in the contract: `open_car_door`, `close_car_door`, `open_door_little`, `open_door_by_number`, `adjust_door_to_number`, `set_door_speed_to_gear`, and `set_door_speed_to_number`.
- Full lane-h scan: expected tool names 42/42 contract-present; mounted tool names 71/71 contract-present; door expected names 14/14 contract-present; door mounted names 22/22 contract-present.

Re-judged rows:

```text
r2b-s2-h-046,r2b-s2-h-047,
r2b-s2-h-052,r2b-s2-h-053,r2b-s2-h-054,r2b-s2-h-055,r2b-s2-h-056,r2b-s2-h-057
```

All eight rows pass under the corrected contract rule. The prior failure was caused by the judge spec, not by lane-h data.

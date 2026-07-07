# JUDGE VERDICT R2b S2 supplement AC locked

status: PASS
artifact_kind: openai_judge_verdict
judge_owner: `%43`
proof_class: local/pre_training_batch_judge
scope: `r2b-s2-supplement-ac-locked` full micro-batch semantic review, 23/23 rows

## Verdict

`r2b-s2-supplement-ac-locked` passes this judge round.

The micro-batch is small enough for full semantic review, so this verdict covers all 23 rows, not a sample. Mechanical gates are already green and were locally cross-checked here; the semantic review found no blocking issue in the AC supplement gap repair.

## Binding

| artifact | value |
|---|---|
| candidates | `r2b-s2-supplement-ac-locked/candidates.jsonl` |
| candidates sha256 | `74e8c08c1083fe28825493d5e402e9fee6d0c9c436c2877c4995cf295e76aa5f` |
| value ledger sha256 | `60833196f33a779fd453df2ee8f000c831f9609a16b95c937b7ab9af5bc1d423` |
| SHA256SUMS sha256 | `e7487d87c6b21e4e1c0277711dfd708743372d67a9f8d7ef9db467ef4867f0dc` |
| gates report sha256 | `eea45e0f4d8a1f1005b546ec3e82d80dc9b7b2c2620334c0029882063bdbfac5` |
| batch manifest sha256 | `493bbcc43231f7310af08cdd9c9cae9e3309c62409c9b3c2ecec5f2c6328d42d` |
| contract sha256 | `a242ba0c62fecda08f860e583176b99e13ca4c6708e0313f1d76cb98f77d0814` |

`shasum -a 256 -c SHA256SUMS.txt` passed for all listed supplement artifacts.

## Mechanical Checks

| check | result |
|---|---|
| assigned candidate sha | PASS, exact match |
| artifact sha closure | PASS, `SHA256SUMS.txt` all OK |
| gates v2 | PASS, no failed gates and no waived gates |
| row count | PASS, 23/23 |
| class shape | PASS, positive 11 / query 12 |
| family shape | PASS, AC-only 23 |
| pair ledger | PASS, 7/7 pair groups complete, 14/14 pair rows |
| supervision consistency | PASS, no contradictions |
| query shape | PASS, 12/12 query rows are query-tool calls |
| tool contract existence | PASS, expected 8/8 and mounted 11/11 tool names exist in `semantic-function-contract.jsonl` |
| value ledger parity | PASS, 23/23 `sample_id` and `candidate_row_sha` parity with candidates |

## Full Semantic Review

### Set Interface vs Defog

| group | rows | verdict |
|---|---|---|
| `sup_ac_sivd_8` | `001` / `002` | PASS, fresh group 8: `open_ac_set_interface` vs `open_defog_mode(direction=前)` is a clean interface-vs-defog contrast |

### Airoutlet / Wind Direction / Windspeed

| group | rows | verdict |
|---|---|---|
| `sup_ac_aw_1` | `003` / `004` | PASS, physical outlet open vs wind-direction switch |
| `sup_ac_aw_2` | `005` / `006` | PASS, `direction=主驾` held; outlet open vs windspeed query |
| `sup_ac_aw_3` | `007` / `008` | PASS, `direction=后排` held; outlet close vs wind-direction switch |
| `sup_ac_aw_4` | `009` / `010` | PASS, `direction=副驾` held; outlet close vs windspeed query |
| `sup_ac_aw_5` | `011` / `012` | PASS, `direction=前排` held; wind-direction switch vs windspeed query |
| `sup_ac_aw_6` | `013` / `014` | PASS, W20 fix present: `014` uses `adjust_ac_windspeed_no_value(direction=全车)`, not a value-bearing windspeed tool |

Near-parallel purity: PASS 6/6. No temperature, defog, or interface cue leaks into the airoutlet/wind groups. Direction slots are held where present.

### Query Strictness

| row set | verdict |
|---|---|
| windspeed query rows `006,010,012` | PASS, all use `query_ac_windspeed`, `has_action=false`, `expected_state_delta={}` |
| temperature query rows `015-023` | PASS, 9/9 use `query_ac_temperature`, `has_action=false`, `expected_state_delta={}` |
| mutating lure handling | PASS, mounted `adjust_ac_temperature_to_number` lures are not selected by the 9 temperature query rows |

## Claim Boundary

This is a local, pre-training batch judge verdict for the 23-row AC supplement micro-batch. It does not claim train-ready, V-PASS, C6 acceptance, or runtime model behavior.

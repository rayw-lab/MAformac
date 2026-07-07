# Scoped D3 Re-judge - warmup-batch-02 @ gates v4

verdict: PASS
batch_id: warmup-batch-02
lane_id: subcc-2
scope: scoped_d3_only_D-070
candidate_count_denominator: 50
candidate_pool_sha256: 2b75ba96e17553141a12bb3bf4ea890c2df2eabbb83d39ef9fd0ecc2a82d6a14
ledger_sha256: 3fe88e927b3a9728e270293558df1b07750968d6bb2f8a35798b3dc370dd9269
gate_receipt: B02-GATES-RECEIPT-v4
mechanical_reference: B02-GATES-RECEIPT-v4 status=mechanical_gates_pass_local
semantic_rejudge_scope: D3 only; repair rows 0007/0023 plus full-batch positive position-word residual scan
unchanged_semantic_reference: original B02 judge D1/D2/D4/D8 sampled PASS; not re-reviewed
proof_class: local/openai-family-scoped-rejudge

## Result

B02 scoped D3 re-judge **PASS**. The two repaired rows now include the explicit `position=主驾` argument required by their Chinese utterances, and their ledger `args_diff` records the new position slot. A full-batch positive position-word scan found 5 position-bearing rows and 0 residual misses.

Mechanical dimensions D5/D6/D7/D9/A10/A11/A12 are not re-judged here; they are referenced from `B02-GATES-RECEIPT-v4`, which reports `mechanical_gates_pass_local`, DataGate v4 `data_gate_ready`, diversity v4 `PASS`, and C6 leakage v4 `pass`.

## Repaired Rows

| row_id | input_zh | tool_name | arguments | ledger args_diff | D3 status |
|---|---|---|---|---|---|
| N5E-wb02-subcc2-0007 | `主驾座椅加热帮我直接开到三挡吧` | `adjust_seat_heat_temperature_to_number` | `{"value": "3", "position": "主驾"}` | `{"position": {"old": null, "new": "主驾"}, "value": {"old": "1", "new": "3"}}` | PASS |
| N5E-wb02-subcc2-0023 | `主驾这边座椅通风麻烦开到三挡` | `adjust_seat_ventilation_windspeed_to_number` | `{"value": "3", "position": "主驾"}` | `{"position": {"old": null, "new": "主驾"}, "value": {"old": "1", "new": "3"}}` | PASS |

## Full-Batch Position Residual Scan

| row_id | input_zh | tool_name | arguments | marker | actual position |
|---|---|---|---|---|---|
| N5E-wb02-subcc2-0003 | `主驾座椅加热升一档` | `raise_seat_heat_temperature_by_number` | `{"value": "1", "position": "主驾"}` | 主驾 | 主驾 |
| N5E-wb02-subcc2-0007 | `主驾座椅加热帮我直接开到三挡吧` | `adjust_seat_heat_temperature_to_number` | `{"value": "3", "position": "主驾"}` | 主驾 | 主驾 |
| N5E-wb02-subcc2-0023 | `主驾这边座椅通风麻烦开到三挡` | `adjust_seat_ventilation_windspeed_to_number` | `{"value": "3", "position": "主驾"}` | 主驾 | 主驾 |
| N5E-wb02-subcc2-0028 | `副驾座椅通风调到两挡` | `adjust_seat_ventilation_windspeed_to_number` | `{"value": "2", "position": "副驾"}` | 副驾 | 副驾 |
| N5E-wb02-subcc2-0029 | `后排座椅通风加一档` | `raise_seat_ventilation_windspeed_by_number` | `{"value": "1", "position": "后排"}` | 后排 | 后排 |

Residual misses:

| row_id | input_zh | tool_name | arguments | marker | actual position |
|---|---|---|---|---|---|
| none | none | none | none | none | none |

## Claim Discipline

- Full mechanical claim: referenced only from B02 gates v4, not re-executed by this scoped judge.
- D3 scoped claim: full-batch scan over all 50 current rows for explicit position words, plus row-level review of the 2 repaired rows.
- Other semantic dimensions: D1/D2/D4/D8 keep the original B02 sampled PASS evidence from `judge-openai-batch-02-row-scores.jsonl`; they were not re-reviewed in this scoped pass.
- No train-ready, C6 acceptance, model-quality V-PASS, or all-50 semantic PASS claim is made beyond this scoped D3 closure.

## Artifact Binding

| artifact | sha256 |
|---|---|
| JUDGE-SPEC-batch-02.md | 63700f2c63a932e52ef4025b7dd05713e41d7602c2de51494eff2d7fbfe11dc2 |
| B02-GATES-RECEIPT-v4.md | bcc0b85d95e8f5a3858ceb1104407075b64bf637b11511b3d5f3e02c5667ffb7 |
| B02-GATES-RECEIPT-v4.json | 2dc3c16903db8d1c1234e12f8310bf89a5652a49230a28e153fcfc251eb0eeeb |
| candidates.jsonl | 2b75ba96e17553141a12bb3bf4ea890c2df2eabbb83d39ef9fd0ecc2a82d6a14 |
| value_change_ledger.jsonl | 3fe88e927b3a9728e270293558df1b07750968d6bb2f8a35798b3dc370dd9269 |
| SHA256SUMS.txt | 8d8818e7f2c3fbb0bb291ac26a7cb9a37323d34cd22b975dfe06737d78b9c89b |
| original judge-openai-batch-02-verdict.md | dc588544e200e0c9c45566cbec040a170c920fb0ef4af08ff50a79378dbd0ed7 |
| original judge-openai-batch-02-row-scores.jsonl | 3225315f07fc91f273fc61c53202da99a29ffd386bdb2b06323ebbe27463afdb |

original_sample_row_ids: N5E-wb02-subcc2-0002, N5E-wb02-subcc2-0003, N5E-wb02-subcc2-0005, N5E-wb02-subcc2-0007, N5E-wb02-subcc2-0011, N5E-wb02-subcc2-0012, N5E-wb02-subcc2-0013, N5E-wb02-subcc2-0019, N5E-wb02-subcc2-0021, N5E-wb02-subcc2-0023, N5E-wb02-subcc2-0028, N5E-wb02-subcc2-0029, N5E-wb02-subcc2-0030, N5E-wb02-subcc2-0032, N5E-wb02-subcc2-0036, N5E-wb02-subcc2-0038, N5E-wb02-subcc2-0040, N5E-wb02-subcc2-0041, N5E-wb02-subcc2-0045, N5E-wb02-subcc2-0047

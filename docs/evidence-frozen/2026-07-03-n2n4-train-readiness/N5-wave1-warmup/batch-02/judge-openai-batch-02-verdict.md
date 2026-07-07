# OpenAI Judge Verdict - warmup-batch-02

verdict: FAIL
batch_id: warmup-batch-02
lane_id: subcc-2
candidate_count_denominator: 50
candidate_pool_sha256: d35af94f802993c7b460d69f84f0a6de75a0c248181239a0b82538c110b59d17
batch_order_sha256: 396dc97b97e4fb9a2a148af4ddb4c9d393dc3cd424120ab6f6902d9c03747827
main_pin_sha: b33d8eba152e5326f69bbe85fc356b73419ee9c3
sample_size_formula_version: judge_sampling_rev2.1_family_min50_max20_10pct
sample_row_ids: N5E-wb02-subcc2-0002, N5E-wb02-subcc2-0013, N5E-wb02-subcc2-0007, N5E-wb02-subcc2-0003, N5E-wb02-subcc2-0005, N5E-wb02-subcc2-0012, N5E-wb02-subcc2-0011, N5E-wb02-subcc2-0028, N5E-wb02-subcc2-0029, N5E-wb02-subcc2-0019, N5E-wb02-subcc2-0023, N5E-wb02-subcc2-0021, N5E-wb02-subcc2-0032, N5E-wb02-subcc2-0030, N5E-wb02-subcc2-0036, N5E-wb02-subcc2-0040, N5E-wb02-subcc2-0047, N5E-wb02-subcc2-0045, N5E-wb02-subcc2-0038, N5E-wb02-subcc2-0041
sample_sample_ids: warmup-batch-02-subcc-2-0002, warmup-batch-02-subcc-2-0013, warmup-batch-02-subcc-2-0007, warmup-batch-02-subcc-2-0003, warmup-batch-02-subcc-2-0005, warmup-batch-02-subcc-2-0012, warmup-batch-02-subcc-2-0011, warmup-batch-02-subcc-2-0028, warmup-batch-02-subcc-2-0029, warmup-batch-02-subcc-2-0019, warmup-batch-02-subcc-2-0023, warmup-batch-02-subcc-2-0021, warmup-batch-02-subcc-2-0032, warmup-batch-02-subcc-2-0030, warmup-batch-02-subcc-2-0036, warmup-batch-02-subcc-2-0040, warmup-batch-02-subcc-2-0047, warmup-batch-02-subcc-2-0045, warmup-batch-02-subcc-2-0038, warmup-batch-02-subcc-2-0041
mechanical_full_coverage: D5/D6/D7/D9/A10/A11/A12 = 50/50
semantic_sample_coverage: D1/D2/D3/D4/D8 = 20/50
family_judge_status: needs_more_review
hard_mechanical_failures: none
sampled_semantic_failures: 2
warnings: none
claim_tier: full_mechanical + sampled_semantic
proof_class: local/openai-family-judge

## Verdict Summary

B02 is **not accepted for expansion** because sampled semantic dimension D3 failed on 2 of the deterministic 20 sampled rows. The full mechanical/provenance audit is clean: D5/D6/D7/D9/A10/A11/A12 all pass over all 50 rows, including SHA256SUMS closure, row hash recomputation, ledger `args_diff` closure, and DataGate v3 `data_gate_ready`.

The semantic failure is an expected-tool-call mismatch, not a ledger/hash failure: two sampled rows mention explicit `主驾` location in Chinese, but the expected arguments omit `position: "主驾"`. This is enough to block a sampled semantic confidence claim for B02.

## Mechanical Full-Run Result

| dimension | coverage | status | evidence |
|---|---:|---|---|
| D5 leakage / training-boundary | 50/50 | PASS | no leakage regex hit in training-facing fields; C6 leakage v3 status=`pass`, intersections=0 |
| D6 redaction / safety hygiene | 50/50 | PASS | `raw_source_redacted=true`, `raw_text_absent=true`; refusal rows 0; DataGate redaction `pass` |
| D7 surface-field consistency | 50/50 | PASS | row-level recipe/quota shas match manifest; `candidate_row_sha` recomputed; SHA256SUMS exact 5-file set current |
| D9 ledger and provenance | 50/50 | PASS | ledger closed 50/50; `schema_check=pass`; row shas aligned |
| A10 hash recipe integrity | 50/50 | PASS | `prompt_hash=sha256(input_zh)`, `expected_tool_call_signature=sha256(rendered_tool_call)`, row sha recomputed |
| A11 quota and manifest conformance | 50/50 | PASS | quota actual 50; family counts `seat_heat=17`, `seat_ventilation=17`, `seat_posture=16`; refusal 0; manual override false |
| A12 parent-value / args-diff audit | 50/50 | PASS | unchanged rows equal template args; changed rows exactly match recomputed `args_diff` |

## Sampled Semantic Result

| dimension | sampled coverage | status | evidence |
|---|---:|---|---|
| D1 natural Chinese | 20/50 | PASS | sampled utterances are natural/demo-usable; no protocol string or template echo |
| D2 target surface correctness | 20/50 | PASS | sampled tools stay inside B02 mounted seat heat/ventilation/posture surfaces |
| D3 expected tool-call correctness | 20/50 | FAIL | 2 sampled rows omit explicit `position=主驾` while `input_zh` says `主驾` |
| D4 value-change semantic legitimacy | 20/50 | PASS | registered value changes themselves match utterances; missing position is recorded under D3 |
| D8 diversity and non-slop | 20/50 | PASS | diversity-v3 PASS; near_duplicate_warning_count=0; sampled rows cover changed/unchanged and short-edge cases |

### D3 Failure Evidence

| row_id | dimension | input_zh | tool_name | arguments | evidence |
|---|---|---|---|---|---|
| N5E-wb02-subcc2-0007 | D3_expected_tool_call_correctness | `主驾座椅加热帮我直接开到三挡吧` | `adjust_seat_heat_temperature_to_number` | `{"value": "3"}` | input_zh says 主驾座椅加热, but arguments only include value=3; position=主驾 is omitted while same batch uses position for explicit 主驾/副驾/后排 rows. |
| N5E-wb02-subcc2-0023 | D3_expected_tool_call_correctness | `主驾这边座椅通风麻烦开到三挡` | `adjust_seat_ventilation_windspeed_to_number` | `{"value": "3"}` | input_zh says 主驾这边座椅通风, but arguments only include value=3; position=主驾 is omitted while same batch uses position for explicit 主驾/副驾/后排 rows. |

Full-pool scan for the same explicit-position omission found exactly these 2 rows (`0007`, `0023`), both already inside the semantic sample.

## Artifact Binding

| artifact | sha256 |
|---|---|
| JUDGE-SPEC-batch-02.md | 63700f2c63a932e52ef4025b7dd05713e41d7602c2de51494eff2d7fbfe11dc2 |
| B02-GATES-RECEIPT-v1.md | 819a64735e5de7c551935c9fb2c070a54f42d5db86988158d500ad8845c2a1db |
| B02-GATES-RECEIPT-v3.json | 301b3a457659ddcb7568b54fd6a2898c6401ba305528b117c88068e7e8415b45 |
| candidates.jsonl | d35af94f802993c7b460d69f84f0a6de75a0c248181239a0b82538c110b59d17 |
| value_change_ledger.jsonl | 0f9f6355a9059912f91950e1a346ad4c134f12b8562d408d13cf20b3f06eb437 |
| batch_manifest.json | 12c33d944ed33993f7caf0cece4ecad07997b63570db0f4c851747628c05bc67 |
| SHA256SUMS.txt | d15360e2590c9671e1626daa1d026fbba3b275e870956291361cadbaf3b122ce |
| judge-openai-batch-02-row-scores.jsonl | 3225315f07fc91f273fc61c53202da99a29ffd386bdb2b06323ebbe27463afdb |
| judge-openai-batch-02-mechanical-audit.json | 3fbe05bf06df4dc244753583ba12b52ecc593c69a2a593672ad273eb938549aa |

Note: user-triggered `B02-GATES-RECEIPT-v1.md` sha is bound above. Its JSON basis references an older candidate sha; the current accepted-pool boundary for this judge is v3, which binds `candidates.jsonl` sha `d35af94f802993c7b460d69f84f0a6de75a0c248181239a0b82538c110b59d17` and keeps DataGate/diversity/C6 green.

## Claim Discipline

Tier 1, full mechanical claim: For warmup-batch-02, mechanical judge dimensions D5/D6/D7/D9/A10/A11/A12 were evaluated over all 50 candidate rows from lane subcc-2. The claim is full-run only for those mechanical/provenance dimensions and is bound to candidate_pool_sha256=d35af94f802993c7b460d69f84f0a6de75a0c248181239a0b82538c110b59d17, batch_order_sha256=396dc97b97e4fb9a2a148af4ddb4c9d393dc3cd424120ab6f6902d9c03747827, and main_pin_sha=b33d8eba152e5326f69bbe85fc356b73419ee9c3.

Tier 2, sampled semantic claim: No PASS sampled-confidence semantic claim is issued for B02 because D3 failed on the deterministic 20-row stratified sample. Semantic repair should update the two affected rows and then run scoped re-judge over changed rows plus D3/D4/A12 as applicable.

Forbidden upgrades observed: no train-ready, C6 acceptance, model-quality V-PASS, or all-50 semantic pass claim is made here.

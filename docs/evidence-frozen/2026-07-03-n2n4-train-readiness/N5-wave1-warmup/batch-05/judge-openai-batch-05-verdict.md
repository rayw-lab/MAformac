# OpenAI Judge Verdict - warmup-batch-05

verdict: PASS
batch_id: warmup-batch-05
lane_id: subcc-5
candidate_count_denominator: 50
candidate_pool_sha256: 90398f5cb3f35761f6e56d589b722e4cf3abbd70b83d8f5752327721fa96d029
batch_order_sha256: 67890208fab032760a7287fcfd3d5adfd0ffbdff696065c9e6aac75cf58d7cd0
main_pin_sha: b33d8eba152e5326f69bbe85fc356b73419ee9c3
sample_size_formula_version: judge_sampling_rev2.1_family_min50_max20_10pct
sample_row_ids: N5E-wb05-subcc5-0014, N5E-wb05-subcc5-0008, N5E-wb05-subcc5-0013, N5E-wb05-subcc5-0017, N5E-wb05-subcc5-0002, N5E-wb05-subcc5-0015, N5E-wb05-subcc5-0006, N5E-wb05-subcc5-0019, N5E-wb05-subcc5-0023, N5E-wb05-subcc5-0018, N5E-wb05-subcc5-0032, N5E-wb05-subcc5-0025, N5E-wb05-subcc5-0034, N5E-wb05-subcc5-0027, N5E-wb05-subcc5-0040, N5E-wb05-subcc5-0044, N5E-wb05-subcc5-0048, N5E-wb05-subcc5-0047, N5E-wb05-subcc5-0039, N5E-wb05-subcc5-0035
sample_sample_ids: warmup-batch-05-subcc-5-0014, warmup-batch-05-subcc-5-0008, warmup-batch-05-subcc-5-0013, warmup-batch-05-subcc-5-0017, warmup-batch-05-subcc-5-0002, warmup-batch-05-subcc-5-0015, warmup-batch-05-subcc-5-0006, warmup-batch-05-subcc-5-0019, warmup-batch-05-subcc-5-0023, warmup-batch-05-subcc-5-0018, warmup-batch-05-subcc-5-0032, warmup-batch-05-subcc-5-0025, warmup-batch-05-subcc-5-0034, warmup-batch-05-subcc-5-0027, warmup-batch-05-subcc-5-0040, warmup-batch-05-subcc-5-0044, warmup-batch-05-subcc-5-0048, warmup-batch-05-subcc-5-0047, warmup-batch-05-subcc-5-0039, warmup-batch-05-subcc-5-0035
mechanical_full_coverage: D5/D6/D7/D9/A10/A11/A12 = 50/50
semantic_sample_coverage: D1/D2/D3/D4/D8 = 20/50
family_judge_status: accepted_sampled
hard_mechanical_failures: none
sampled_semantic_failures: 0
warnings: gate v1 `basis.candidate_sha256` is stale after controller injection; current candidate pool is bound by resource envelope, SHA256SUMS, and recomputed file sha.
claim_tier: full_mechanical + sampled_semantic
proof_class: local/openai-family-judge

## Verdict Summary

B05 is **accepted with tiered claims**. Full mechanical/provenance dimensions D5/D6/D7/D9/A10/A11/A12 pass over all 50 rows. The deterministic stratified 20-row semantic sample passes D1/D2/D3/D4/D8 with no sampled semantic failures.

The accepted-pool candidate sha for this judge is `90398f5cb3f35761f6e56d589b722e4cf3abbd70b83d8f5752327721fa96d029`. `B05-GATES-RECEIPT-v1.json` has a stale `basis.candidate_sha256` from before controller injection, but its `resource_envelope.files.candidates`, lane `SHA256SUMS.txt`, and this judge recomputation all bind the current candidate file.

## Mechanical Full-Run Result

| dimension | coverage | status | evidence |
|---|---:|---|---|
| D5 leakage / training-boundary | 50/50 | PASS | no leakage regex hit in training-facing fields; C6 leakage v1 status=`pass`, intersections=0 |
| D6 redaction / safety hygiene | 50/50 | PASS | `raw_source_redacted=true`, `raw_text_absent=true`; refusal rows 0; DataGate redaction `pass` |
| D7 surface-field consistency | 50/50 | PASS | row-level recipe/quota shas match manifest; `candidate_row_sha` recomputed; SHA256SUMS exact 5-file set current |
| D9 ledger and provenance | 50/50 | PASS | ledger closed 50/50; `schema_check=pass`; changed rows have registration id; unchanged rows have empty diff |
| A10 hash recipe integrity | 50/50 | PASS | `prompt_hash=sha256(input_zh)`, `expected_tool_call_signature=sha256(rendered_tool_call)`, row sha recomputed |
| A11 quota and manifest conformance | 50/50 | PASS | quota actual 50; family counts `wiper=17`, `sunroof=17`, `fragrance=16`; refusal 0; manual override false |
| A12 parent-value / args-diff audit | 50/50 | PASS | unchanged rows equal template args; changed rows exactly match recomputed `args_diff` |

## Sampled Semantic Result

| dimension | sampled coverage | status | evidence |
|---|---:|---|---|
| D1 natural Chinese | 20/50 | PASS | sampled utterances are natural/demo-usable; no protocol string or template echo |
| D2 target surface correctness | 20/50 | PASS | sampled tools stay inside B05 mounted wiper/sunroof/fragrance surfaces, including child allocation sunroof=7/fragrance=6 |
| D3 expected tool-call correctness | 20/50 | PASS | tool names, schema keys/enums, optional slots, value phrases, and parsed rendered tool calls match sampled utterances |
| D4 value-change semantic legitimacy | 20/50 | PASS | all sampled value changes are registered and semantically justified by `input_zh` |
| D8 diversity and non-slop | 20/50 | PASS | diversity-v1 PASS; near_duplicate_warning_count=0; sample covers changed/unchanged and short/long edges |

### Sampled Semantic Failures

| row_id | dimension | input_zh | tool_name | arguments | evidence |
|---|---|---|---|---|---|
| none | none | none | none | none | none |

## Artifact Binding

| artifact | sha256 |
|---|---|
| JUDGE-SPEC-batch-05.md | fd57d295b86c7a631002f7baa506f1b596cae64231c4054aca2e39691ed2f402 |
| B05-GATES-RECEIPT-v1.md | ba1eae406a86842eae66c9be4e8e1cad8334a16ddcb3a4ed244fc0aae088336c |
| B05-GATES-RECEIPT-v1.json | 5244579228e6b83cf8fe91bd3e31e9d7613bc92faa0c72f1e2513d4cd3d56d13 |
| candidates.jsonl | 90398f5cb3f35761f6e56d589b722e4cf3abbd70b83d8f5752327721fa96d029 |
| value_change_ledger.jsonl | 1a8ee78e1d55bf8ccb2e71eb4ccf7ce859a1ec21ff10acaa9dc542dd87c04f6a |
| batch_manifest.json | da9963f700098e43a7c12667379c531f789852b5593a9b6c64633d9c64527e76 |
| SHA256SUMS.txt | 1f03c8a26e053cdd5abc4d00e317582d9b8d333b1b56bce4288a224e611bc5dd |
| judge-openai-batch-05-row-scores.jsonl | 8c3e4977ad56cacdd68482b4cfbf26948b3e8f1135010f4057617945838fd5c7 |
| judge-openai-batch-05-mechanical-audit.json | 7dac0c6242c6f32816aba0184ad90693dd4e32670d4e98605c6b1d7046d9c716 |

## Claim Discipline

Tier 1, full mechanical claim: For warmup-batch-05, mechanical judge dimensions D5/D6/D7/D9/A10/A11/A12 were evaluated over all 50 candidate rows from lane subcc-5. The claim is full-run only for those mechanical/provenance dimensions and is bound to candidate_pool_sha256=90398f5cb3f35761f6e56d589b722e4cf3abbd70b83d8f5752327721fa96d029, batch_order_sha256=67890208fab032760a7287fcfd3d5adfd0ffbdff696065c9e6aac75cf58d7cd0, and main_pin_sha=b33d8eba152e5326f69bbe85fc356b73419ee9c3.

Tier 2, sampled semantic confidence claim: For warmup-batch-05, semantic judge dimensions D1/D2/D3/D4/D8 were reviewed on a deterministic stratified sample of 20 rows out of the 50-row candidate pool, using sample_size_formula_version=judge_sampling_rev2.1_family_min50_max20_10pct and sample_row_ids=N5E-wb05-subcc5-0014, N5E-wb05-subcc5-0008, N5E-wb05-subcc5-0013, N5E-wb05-subcc5-0017, N5E-wb05-subcc5-0002, N5E-wb05-subcc5-0015, N5E-wb05-subcc5-0006, N5E-wb05-subcc5-0019, N5E-wb05-subcc5-0023, N5E-wb05-subcc5-0018, N5E-wb05-subcc5-0032, N5E-wb05-subcc5-0025, N5E-wb05-subcc5-0034, N5E-wb05-subcc5-0027, N5E-wb05-subcc5-0040, N5E-wb05-subcc5-0044, N5E-wb05-subcc5-0048, N5E-wb05-subcc5-0047, N5E-wb05-subcc5-0039, N5E-wb05-subcc5-0035. This supports only a sampled-confidence semantic claim for the batch; it must not be phrased as all 50 rows passing semantic review.

Forbidden upgrades observed: no train-ready, C6 acceptance, model-quality V-PASS, or all-50 semantic pass claim is made here.

# OpenAI Judge Verdict - warmup-batch-04

verdict: PASS
batch_id: warmup-batch-04
lane_id: subcc-4
candidate_count_denominator: 50
candidate_pool_sha256: bbdae53e301bd8cb1b867f2a10ee15d7cb2672bd2ea66681b8d2f247562b5027
batch_order_sha256: c2a3a6cab26a40d104e335658e972afbac4c3ec68688024c4dafb1db863057e6
main_pin_sha: b33d8eba152e5326f69bbe85fc356b73419ee9c3
sample_size_formula_version: judge_sampling_rev2.1_family_min50_max20_10pct
sample_row_ids: N5E-wb04-subcc4-0005, N5E-wb04-subcc4-0006, N5E-wb04-subcc4-0001, N5E-wb04-subcc4-0009, N5E-wb04-subcc4-0011, N5E-wb04-subcc4-0016, N5E-wb04-subcc4-0003, N5E-wb04-subcc4-0034, N5E-wb04-subcc4-0024, N5E-wb04-subcc4-0023, N5E-wb04-subcc4-0028, N5E-wb04-subcc4-0020, N5E-wb04-subcc4-0031, N5E-wb04-subcc4-0030, N5E-wb04-subcc4-0039, N5E-wb04-subcc4-0038, N5E-wb04-subcc4-0049, N5E-wb04-subcc4-0042, N5E-wb04-subcc4-0036, N5E-wb04-subcc4-0046
sample_sample_ids: warmup-batch-04-subcc-4-0005, warmup-batch-04-subcc-4-0006, warmup-batch-04-subcc-4-0001, warmup-batch-04-subcc-4-0009, warmup-batch-04-subcc-4-0011, warmup-batch-04-subcc-4-0016, warmup-batch-04-subcc-4-0003, warmup-batch-04-subcc-4-0034, warmup-batch-04-subcc-4-0024, warmup-batch-04-subcc-4-0023, warmup-batch-04-subcc-4-0028, warmup-batch-04-subcc-4-0020, warmup-batch-04-subcc-4-0031, warmup-batch-04-subcc-4-0030, warmup-batch-04-subcc-4-0039, warmup-batch-04-subcc-4-0038, warmup-batch-04-subcc-4-0049, warmup-batch-04-subcc-4-0042, warmup-batch-04-subcc-4-0036, warmup-batch-04-subcc-4-0046
mechanical_full_coverage: D5/D6/D7/D9/A10/A11/A12 = 50/50
semantic_sample_coverage: D1/D2/D3/D4/D8 = 20/50
family_judge_status: accepted_sampled
hard_mechanical_failures: none
sampled_semantic_failures: 0
warnings: gate v1 `basis.candidate_sha256` is stale after controller injection; current candidate pool is bound by resource envelope, SHA256SUMS, and recomputed file sha.
claim_tier: full_mechanical + sampled_semantic
proof_class: local/openai-family-judge

## Verdict Summary

B04 is **accepted with tiered claims**. Full mechanical/provenance dimensions D5/D6/D7/D9/A10/A11/A12 pass over all 50 rows. The deterministic stratified 20-row semantic sample passes D1/D2/D3/D4/D8 with no sampled semantic failures.

The accepted-pool candidate sha for this judge is `bbdae53e301bd8cb1b867f2a10ee15d7cb2672bd2ea66681b8d2f247562b5027`. `B04-GATES-RECEIPT-v1.json` has a stale `basis.candidate_sha256` from before controller injection, but its `resource_envelope.files.candidates`, lane `SHA256SUMS.txt`, and this judge recomputation all bind the current candidate file. Unchanged rows carry empty `value_change_registration_id`; changed rows are the registration-required path, and all 8 changed rows have non-empty registration ids plus closed `args_diff`.

## Mechanical Full-Run Result

| dimension | coverage | status | evidence |
|---|---:|---|---|
| D5 leakage / training-boundary | 50/50 | PASS | no leakage regex hit in training-facing fields; C6 leakage v1 status=`pass`, intersections=0 |
| D6 redaction / safety hygiene | 50/50 | PASS | `raw_source_redacted=true`, `raw_text_absent=true`; refusal rows 0; DataGate redaction `pass` |
| D7 surface-field consistency | 50/50 | PASS | row-level recipe/quota shas match manifest; `candidate_row_sha` recomputed; SHA256SUMS exact 5-file set current |
| D9 ledger and provenance | 50/50 | PASS | ledger closed 50/50; `schema_check=pass`; changed rows have registration id; unchanged rows have empty diff |
| A10 hash recipe integrity | 50/50 | PASS | `prompt_hash=sha256(input_zh)`, `expected_tool_call_signature=sha256(rendered_tool_call)`, row sha recomputed |
| A11 quota and manifest conformance | 50/50 | PASS | quota actual 50; family counts `light=18`, `screen=16`, `volume=16`; refusal 0; manual override false |
| A12 parent-value / args-diff audit | 50/50 | PASS | unchanged rows equal template args; changed rows exactly match recomputed `args_diff` |

## Sampled Semantic Result

| dimension | sampled coverage | status | evidence |
|---|---:|---|---|
| D1 natural Chinese | 20/50 | PASS | sampled utterances are natural/demo-usable; no protocol string or template echo |
| D2 target surface correctness | 20/50 | PASS | sampled tools stay inside B04 mounted light/screen/volume surfaces |
| D3 expected tool-call correctness | 20/50 | PASS | tool names, schema keys/enums, optional slots, and parsed rendered tool calls match sampled utterances |
| D4 value-change semantic legitimacy | 20/50 | PASS | all sampled value changes are registered and semantically justified by `input_zh` |
| D8 diversity and non-slop | 20/50 | PASS | diversity-v1 PASS; near_duplicate_warning_count=0; sample covers changed/unchanged and short/long edges |

### Sampled Semantic Failures

| row_id | dimension | input_zh | tool_name | arguments | evidence |
|---|---|---|---|---|---|
| none | none | none | none | none | none |

## Artifact Binding

| artifact | sha256 |
|---|---|
| JUDGE-SPEC-batch-04.md | 31d537c2167e128e6a3874cbe6aa60d4e92f812cb8c9414d8d5e07f9a8805026 |
| B04-GATES-RECEIPT-v1.md | a8dab0eb424b1f8f8a7440389a53ccc9799658de80104846b8fd5512abdbfa35 |
| B04-GATES-RECEIPT-v1.json | ce30461d0be1dd7926cdf3a4e7d4b732abf594d40e25ca86ef7aca758a1c57d6 |
| candidates.jsonl | bbdae53e301bd8cb1b867f2a10ee15d7cb2672bd2ea66681b8d2f247562b5027 |
| value_change_ledger.jsonl | 77d7322e5e7827cf35009ec802720261637b9a1a082866cee642ec62583a14e4 |
| batch_manifest.json | dfd5f82397a060a176a69bb2fc6d83b8dd073fb52a1e667f9fbbef0e52cf2d55 |
| SHA256SUMS.txt | 2dc88b1905325073b420e55c569abd199c734af3641429b68f6718b46b7d413c |
| judge-openai-batch-04-row-scores.jsonl | 122fae6c9dc6cf987663b16be6460110fbe7379cb79f5598f0980e8e427ec308 |
| judge-openai-batch-04-mechanical-audit.json | 2355d4685056aca70f37b34535de2a946c6045e54ce5f21d3afb008f243983a6 |

## Claim Discipline

Tier 1, full mechanical claim: For warmup-batch-04, mechanical judge dimensions D5/D6/D7/D9/A10/A11/A12 were evaluated over all 50 candidate rows from lane subcc-4. The claim is full-run only for those mechanical/provenance dimensions and is bound to candidate_pool_sha256=bbdae53e301bd8cb1b867f2a10ee15d7cb2672bd2ea66681b8d2f247562b5027, batch_order_sha256=c2a3a6cab26a40d104e335658e972afbac4c3ec68688024c4dafb1db863057e6, and main_pin_sha=b33d8eba152e5326f69bbe85fc356b73419ee9c3.

Tier 2, sampled semantic confidence claim: For warmup-batch-04, semantic judge dimensions D1/D2/D3/D4/D8 were reviewed on a deterministic stratified sample of 20 rows out of the 50-row candidate pool, using sample_size_formula_version=judge_sampling_rev2.1_family_min50_max20_10pct and sample_row_ids=N5E-wb04-subcc4-0005, N5E-wb04-subcc4-0006, N5E-wb04-subcc4-0001, N5E-wb04-subcc4-0009, N5E-wb04-subcc4-0011, N5E-wb04-subcc4-0016, N5E-wb04-subcc4-0003, N5E-wb04-subcc4-0034, N5E-wb04-subcc4-0024, N5E-wb04-subcc4-0023, N5E-wb04-subcc4-0028, N5E-wb04-subcc4-0020, N5E-wb04-subcc4-0031, N5E-wb04-subcc4-0030, N5E-wb04-subcc4-0039, N5E-wb04-subcc4-0038, N5E-wb04-subcc4-0049, N5E-wb04-subcc4-0042, N5E-wb04-subcc4-0036, N5E-wb04-subcc4-0046. This supports only a sampled-confidence semantic claim for the batch; it must not be phrased as all 50 rows passing semantic review.

Forbidden upgrades observed: no train-ready, C6 acceptance, model-quality V-PASS, or all-50 semantic pass claim is made here.

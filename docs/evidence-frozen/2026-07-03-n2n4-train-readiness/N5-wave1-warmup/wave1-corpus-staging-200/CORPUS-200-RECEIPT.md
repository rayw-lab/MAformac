# CORPUS-200 Receipt

status: partial_corpus_staging_ready
artifact_kind: wave1_corpus_consolidation_receipt
rows: 200
manifest: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/wave1-corpus-staging-200/wave1-corpus-manifest.json`
manifest_sha256: `628fd7f5c4f0d8d789a856e93691d4ab3979bfa4f41242110802b7149feaa10b`
corpus_jsonl: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/wave1-corpus-staging-200/wave1-corpus.jsonl`
corpus_sha256: `cec1f7cf304e960517e4295b879d411c8d4a3ebde372db502121efcd48e2fc16`

## Basis

- warmup_generation_pin: `b33d8eba152e5326f69bbe85fc356b73419ee9c3` (historical_effective_warmup_generation_pin)
- CODE-PR38 training/code basis: `266783468ac38542574ea4787bec650d16ba6b02`; data basis `DATA-WAVE1-SUBSTRATE-v3 / PR38-final-n4a-recipe-build/`
- relationship: corpus rows preserve warmup batch provenance from `b33d8eba`; PR38 is a later training/code basis. This receipt is corpus staging only, not train-ready and not V-PASS.

## Included Batches

| batch | rows | candidate_pool_sha256 | judge | verdict pointer | gates pointer | mechanical claim | semantic claim |
|---|---:|---|---|---|---|---|---|
| B01 | 50 | eee76baf662cb41ae32b2a6f8c49c3d1fcf2b25b850001a5541822d27602016c | PASS | /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/judge-openai-batch-01-verdict.md | /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/B01-GATES-RECEIPT-v8.json | D5/D6/D7/D9/A10/A11/A12 = 50/50 | D1/D2/D3/D4/D8 = 20/50 |
| B02 | 50 | 2b75ba96e17553141a12bb3bf4ea890c2df2eabbb83d39ef9fd0ecc2a82d6a14 | PASS | /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/judge-openai-batch-02-scoped-d3-verdict.md | /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/gates/B02-GATES-RECEIPT-v4.json | see verdict claim discipline | see scoped verdict claim discipline |
| B04 | 50 | bbdae53e301bd8cb1b867f2a10ee15d7cb2672bd2ea66681b8d2f247562b5027 | PASS | /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-04/judge-openai-batch-04-verdict.md | /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-04/lane-subcc-4/gates/B04-GATES-RECEIPT-v1.json | D5/D6/D7/D9/A10/A11/A12 = 50/50 | D1/D2/D3/D4/D8 = 20/50 |
| B05 | 50 | 90398f5cb3f35761f6e56d589b722e4cf3abbd70b83d8f5752327721fa96d029 | PASS | /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-05/judge-openai-batch-05-verdict.md | /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-05/lane-subcc-5/gates/B05-GATES-RECEIPT-v1.json | D5/D6/D7/D9/A10/A11/A12 = 50/50 | D1/D2/D3/D4/D8 = 20/50 |

## Claim Discipline

- Full mechanical claims are only the dimensions and coverage written by each batch verdict/gates receipt.
- Semantic claims remain sampled or scoped exactly as written by the judge verdicts.
- B02 uses `judge-openai-batch-02-scoped-d3-verdict.md`: scoped D3 repaired rows plus full-batch explicit-position residual scan; other semantic dimensions are referenced from original sampled evidence, not re-reviewed here.
- No all-50 semantic PASS, train-ready, C6 acceptance, model-quality V-PASS, or run authorization is claimed.

## Totals

- included_batches: 4
- included_rows: 200
- expected_remaining_rows: 50
- remaining_unselected_batches: 1 (B03 pending judge verdict at this receipt boundary)

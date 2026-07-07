# CORPUS-250-FINAL Receipt

status: corpus_ready
artifact_kind: wave1_corpus_consolidation_receipt
rows: 250
manifest: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/wave1-corpus-final/wave1-corpus-manifest.json`
manifest_sha256: `b07e0a9bc76b3140a41c1402e714aac6fb6944294900084b18c73416c45d6a10`
corpus_jsonl: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/wave1-corpus-final/wave1-corpus.jsonl`
corpus_sha256: `e6ff61cb87d90cfbc6fdcc73c0da063b69c49f6a9d09f50064ec8f1c9b9f3afb`

## Basis

- warmup_generation_pin: `b33d8eba152e5326f69bbe85fc356b73419ee9c3` (historical_effective_warmup_generation_pin)
- CODE-PR38 training/code basis: `266783468ac38542574ea4787bec650d16ba6b02`; data basis `DATA-WAVE1-SUBSTRATE-v3 / PR38-final-n4a-recipe-build/`
- relationship: warmup candidate rows retain their generation pin `b33d8eba`; PR38 is the later training/code basis. This receipt does not migrate generation provenance, and does not claim train-ready or V-PASS.

## Included Batches

| batch | rows | candidate_pool_sha256 | judge | verdict pointer | gates pointer | mechanical claim | semantic claim |
|---|---:|---|---|---|---|---|---|
| B01 | 50 | eee76baf662cb41ae32b2a6f8c49c3d1fcf2b25b850001a5541822d27602016c | PASS | /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/judge-openai-batch-01-verdict.md | /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/B01-GATES-RECEIPT-v8.json | D5/D6/D7/D9/A10/A11/A12 = 50/50 | D1/D2/D3/D4/D8 = 20/50 |
| B02 | 50 | 2b75ba96e17553141a12bb3bf4ea890c2df2eabbb83d39ef9fd0ecc2a82d6a14 | PASS | /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/judge-openai-batch-02-scoped-d3-verdict.md | /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/gates/B02-GATES-RECEIPT-v4.json | see verdict claim discipline | see scoped verdict claim discipline |
| B03 | 50 | 85f8067c5c040bad2bcf38f88b569b2c90c991f7aa09d6e9f5cb7abd59a0fa9b | PASS | /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-03/judge-openai-batch-03-verdict.md | /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-03/lane-subcc-3/gates/B03-GATES-RECEIPT-v2.json | D5/D6/D7/D9/A10/A11/A12 = 50/50 | D1/D2/D3/D4/D8 = 20/50 |
| B04 | 50 | bbdae53e301bd8cb1b867f2a10ee15d7cb2672bd2ea66681b8d2f247562b5027 | PASS | /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-04/judge-openai-batch-04-verdict.md | /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-04/lane-subcc-4/gates/B04-GATES-RECEIPT-v1.json | D5/D6/D7/D9/A10/A11/A12 = 50/50 | D1/D2/D3/D4/D8 = 20/50 |
| B05 | 50 | 90398f5cb3f35761f6e56d589b722e4cf3abbd70b83d8f5752327721fa96d029 | PASS | /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-05/judge-openai-batch-05-verdict.md | /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-05/lane-subcc-5/gates/B05-GATES-RECEIPT-v1.json | D5/D6/D7/D9/A10/A11/A12 = 50/50 | D1/D2/D3/D4/D8 = 20/50 |

## Claim Discipline

- Full mechanical claims are only the dimensions and coverage written by each batch verdict/gates receipt.
- Semantic claims remain sampled or scoped exactly as written by the judge verdicts.
- B02 uses `judge-openai-batch-02-scoped-d3-verdict.md`: scoped D3 repaired rows plus full-batch explicit-position residual scan; other semantic dimensions are referenced from original sampled evidence, not re-reviewed here.
- B03 uses `judge-openai-batch-03-verdict.md`: full mechanical 50/50 plus sampled semantic 20/50; repaired rows 0012/0025 are in the semantic sample.
- No all-50 semantic PASS, train-ready, C6 acceptance, model-quality V-PASS, or run authorization is claimed.

## Totals

- included_batches: 5
- included_rows: 250
- expected_remaining_rows: 0
- remaining_unselected_batches: 0

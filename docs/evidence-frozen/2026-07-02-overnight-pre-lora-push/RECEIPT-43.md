# RECEIPT-43

status: DONE
worker: codex pane %43
repo: `/Users/wanglei/workspace/MAformac-grill`
branch: `c5grill/dim11-dim5-deepen`
proof_class: local/unit/docs

## changed files

1. `/Users/wanglei/workspace/MAformac-grill/docs/c5-training-readiness-grill/worker-commander-dim11-premortem-deepen.md`
   - `:1-5` scope/header: dim11 pre-mortem deepen, R7-safe.
   - `:11-31` decision rows `F-055~F-075`, 21 rows.
   - Coverage: enforcement挂点 for false-delete/false-green, surface/scorer split, loss-vs-model-quality split, positive dilution, receipt-only audit, plus 3 missing modes: same-family generator/judge leak, sparse family bug<10 floor, clarify-axis collapse. F-047 think/no-think split expanded into train render, loss span, endpoint parity, eval prompt rows.

2. `/Users/wanglei/workspace/MAformac-grill/docs/c5-training-readiness-grill/worker-2-algo-dim5-papers-deepen.md`
   - `:1-5` scope/header: dim5 paper grounding, arxiv discipline, BFCL no-arxiv guard.
   - `:11-27` decision rows `A-134~A-150`, 17 rows.
   - Coverage: GOAT/function path, Hammer/function masking, GOAT+Hammer order, LR Matters, When2Call, SemDeDup, LLM-decontaminator, tau2-bench, BFCL no-arxiv discipline + C6 category absorption, Hybrid Thinking/no-think, Instruct-SkillMix checkpoint, ALTO early stop, tiny ablation, agent eval receipt, external-claim verification.

## validation

Commands run from `/Users/wanglei/workspace/MAformac-grill`:

| command | exit | evidence |
|---|---:|---|
| `rg -c '^\\| F-' docs/c5-training-readiness-grill/worker-commander-dim11-premortem-deepen.md` | 0 | output `21` |
| `rg -c '^\\| A-' docs/c5-training-readiness-grill/worker-2-algo-dim5-papers-deepen.md` | 0 | output `17` |
| `git diff --check` | 0 | no whitespace errors |
| `swift test --filter C5LoRATraining` | 0 | 39 tests, 0 failures, 0 unexpected |
| `git status --short --branch` | 0 | only the two new grill docs are untracked in repo scope at validation time |

## external claim checks

WebSearch-checked load-bearing arxiv IDs used in the dim5 paper rows:

- GOAT: `2510.12218`
- Hammer: `2410.04587`
- LR Matters: `2602.04998`
- When2Call: `2504.18851`
- SemDeDup: `2303.09540`
- LLM-decontaminator: `2311.04850`
- tau2-bench: `2506.07982`
- Hybrid Thinking: `2510.12680`
- Instruct-SkillMix: `2408.14774`
- ALTO: `2604.05426`

BFCL v3: WebSearch found Gorilla/leaderboard/OpenReview/PMLR anchors, but no arxiv ID. The dim5 matrix intentionally marks BFCL arxiv as `TODO-no-arxiv-found`; no BFCL arxiv ID was fabricated.

## R7 boundary proof

- No true training was run.
- No data generation was run.
- No C6 acceptance / true eval / golden / candidate / voice work was run.
- Only documentation artifacts were added under `docs/c5-training-readiness-grill/`, plus this run receipt.
- The Swift command was local/unit validation only and did not invoke mlx-lm training or C6 acceptance.

## residual risk

- All rows are `proposed`; they are not locked until commander absorbs them into landing/spec/code gates.
- External paper IDs were WebSearch-checked at the ID/title level. Detailed paper-section claims should still go through the later `verify-external-claims` gate before becoming locked implementation requirements.

# R4 Eval Receipt

status: raw_numbers_only_no_verdict
proof_class: local_model_eval_run_adapter_only_against_prebuilt_base_anchors
created_at: 2026-07-05T03:55:08+08:00
eval_dir: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/TD-eval-r4train-ready`
adapter: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-r4train-run-20260705T005046+0800/adapters-rank16`
adapter_sha256: `ee5791271735eaa5cf53f310f7bdc7d3893936e4c1cb06f8584727c637a980e0`
train_receipt: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-r4train-run-20260705T005046+0800/R4-TRAIN-RECEIPT.md`
claim_boundary: no PASS/FAIL/verdict; commander owns verdict.

## Execution Notes

- Original gate v3 base anchor was not rerun; copied from `TD-eval-run155204-ready/original-gate-v3/probe-output-abd/base`.
- Expanded base anchor was not rerun; read from `L6-eval-bundle-r2b-expansion/base-anchor/probe-output-expanded-base-anchor/base`.
- R4 adapter legs used `probe_harness_expanded.py --adapter-only`; original v3 kept `--min-prompt-tokens 300`, expanded used W52 waiver `--min-prompt-tokens 100`.

## Original Gate v3 Numbers

| arm | A | B | D |
|---|---:|---:|---:|
| base_anchor | 3/15 | 14/15 | 18/34 |
| R4 adapter | 15/15 | 15/15 | 21/34 |

Report: `TD-eval-r4train-ready/original-gate-v3/R4-ORIGINAL-GATE-V3-PAIRED-REPORT.md`

## Expanded Side Track Numbers

| arm | B-neighbor | Q | TOTAL |
|---|---:|---:|---:|
| base_anchor | 15/26 | 14/27 | 29/53 |
| R4 adapter | 24/26 | 16/27 | 40/53 |

Report: `TD-eval-r4train-ready/expanded/R4-EXPANDED-ANCHOR-ADAPTER-REPORT.md`

## QA Cross-Track Rescan

| total | adapter | base | original_v3 |
|---:|---:|---:|---:|
| 12 | 10 | 2 | 0 |

Report: `TD-eval-r4train-ready/query-zero-tolerance-cross-track-r4-v3.json`

## W47 T1 Over-Refusal Probe

| probe | exact | failure_count |
|---|---:|---:|
| true_query_guard | 7/10 | 3 |
| action_question_control | 15/18 | 3 |

W47 failure rows are listed in `TD-eval-r4train-ready/over-refusal-t1/` assertion JSON files.

## Mount Validity

| surface | status | checked | violations |
|---|---|---:|---:|
| original_v3_bundle | PASS | 64 | 0 |
| original_v3_probe_output | PASS | 128 | 0 |

## Process Release Check

Residual model/probe/watchdog processes after eval: 0

## SHA Bindings

See `TD-eval-r4train-ready/EVAL-COMMON-SHA256SUMS.txt` and `TD-eval-r4train-ready/EVAL-ARTIFACT-SHA256SUMS.txt`.

## Non-Claims

This receipt reports raw local eval numbers only. It does not claim R4 PASS/FAIL, formal launch readiness, product acceptance, endpoint readiness, or V-PASS.

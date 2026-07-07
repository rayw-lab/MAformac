# R3 Eval Receipt

status: raw_numbers_only_no_verdict
proof_class: local_model_eval_run_adapter_only_against_prebuilt_base_anchors
created_at: 2026-07-05T00:21:12+08:00
eval_dir: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/TD-eval-r3train-ready`
adapter: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-r3train-run-20260704T211035+0800/adapters-rank16`
adapter_sha256: `4e278f1843d391b81c3a6201c760a7cd0eb45a2ee214741b32c998efd17c7847`
train_receipt: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-r3train-run-20260704T211035+0800/R3-TRAIN-RECEIPT.md`
claim_boundary: no PASS/FAIL/verdict; commander owns verdict.

## Execution Notes

- Original gate v3 base anchor was not rerun; copied from `TD-eval-run155204-ready/original-gate-v3/probe-output-abd/base`.
- Expanded base anchor was not rerun; read from `L6-eval-bundle-r2b-expansion/base-anchor/probe-output-expanded-base-anchor/base`.
- R3 adapter legs used `probe_harness_expanded.py --adapter-only`; original v3 kept `--min-prompt-tokens 300`, expanded used W52 waiver `--min-prompt-tokens 100`.

## Original Gate v3 Numbers

| arm | A | B | D |
|---|---:|---:|---:|
| base_anchor | 3/15 | 14/15 | 18/34 |
| R3 adapter | 14/15 | 15/15 | 23/34 |

Report: `TD-eval-r3train-ready/original-gate-v3/R3-ORIGINAL-GATE-V3-PAIRED-REPORT.md`

## Expanded Side Track Numbers

| arm | B-neighbor | Q | TOTAL |
|---|---:|---:|---:|
| base_anchor | 15/26 | 14/27 | 29/53 |
| R3 adapter | 25/26 | 17/27 | 42/53 |

Report: `TD-eval-r3train-ready/expanded/R3-EXPANDED-ANCHOR-ADAPTER-REPORT.md`

## QA Cross-Track Rescan

| total | adapter | base | original_v3 |
|---:|---:|---:|---:|
| 10 | 8 | 2 | 0 |

Report: `TD-eval-r3train-ready/query-zero-tolerance-cross-track-r3-v3.json`

## W47 T1 Over-Refusal Probe

| probe | exact | failure_count |
|---|---:|---:|
| true_query_guard | 10/10 | 0 |
| action_question_control | 17/18 | 1 |

W47 action-question failure rows are listed in `TD-eval-r3train-ready/over-refusal-t1/action-question-control-assertion.json`.

## Mount Validity

| surface | status | checked | violations |
|---|---|---:|---:|
| original_v3_bundle | PASS | 64 | 0 |
| original_v3_probe_output | PASS | 128 | 0 |

## SHA Bindings

See `TD-eval-r3train-ready/EVAL-COMMON-SHA256SUMS.txt` and `TD-eval-r3train-ready/EVAL-ARTIFACT-SHA256SUMS.txt`.

## Non-Claims

This receipt reports raw local eval numbers only. It does not claim R3 PASS/FAIL, formal launch readiness, product acceptance, endpoint readiness, or V-PASS.

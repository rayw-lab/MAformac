# TD Eval Receipt — run155204

status: td_eval_executed_raw_counts_only
proof_class: local_model_eval_run
created_at: 2026-07-04T19:18:41+0800
claim_boundary: raw counts only; no PASS/FAIL/verdict claim. Verdict is reserved for `%0` and F044-R2B-VERDICT-TEMPLATE.md.

## Binding

| item | value |
|---|---|
| train_receipt | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-shorttrain-run-20260704T155204+0800/F044-R2B-TRAIN-RECEIPT.md` |
| train_receipt_sha256 | `6d17b197e6ca4db297650bfb01c85fde570d3949eb6a813515300ab757969fc1` |
| adapter | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-shorttrain-run-20260704T155204+0800/adapters-rank16/adapters.safetensors` |
| adapter_sha256 | `0d9b712b3fb10218873797b6e6389b9c3ef02c594dcea5d8b7bf725b56c295f4` |
| formal_eval_manifest_sha256 | `f0d36b0a44e58869e36da4436e991d9728bbd01e24ced0b57af27709b2f49807` |
| original_probe_harness_sha256 | `2d904aa0d33eb8d2fb68656cb9a381d1a4e7b4ee789eeb0b1271811d88df354a` |
| expanded_probe_harness_sha256 | `f41017fbf6df281538fd58b3316f7a3a955ab8019c5135bd17d11c1dc567ef4a` |
| scorer_sha256 | `d66bd9f6882221d2b957e8324165d8690b2e98ba80b30d310d1395d044f6aa4c` |
| original_cases_sha256 | `43ff434b0688aeff38ca11aafde6892c34c76b82d1eb78ba3813f31b4b43ba51` |
| expanded_cases_sha256 | `987c3ba4f45e673881cc02295a7243685ac5a95499d352ef82e156d13b00703b` |
| expanded_base_anchor_recount_sha256 | `824e508e7df396949edfb081149b803b41056a1275fb61fa370560a1d48076ef` |

## Original Gate Raw Counts

| arm | A | B | D |
|---|---:|---:|---:|
| base | 3/15 | 9/15 | 18/34 |
| adapter | 10/15 | 9/15 | 19/34 |

## Expanded Side-Track Raw Counts

| arm | B-neighbor | Q-hard |
|---|---:|---:|
| base_anchor | 15/26 | 14/27 |
| adapter | 25/26 | 17/27 |

## Query Zero-Tolerance

| scanned_records | failure_count | report |
|---:|---:|---|
| 30 | 11 | `query-zero-tolerance-cross-track.json` |

## A-Axis Diff vs R2a

| current fail count | current fail case_ids | same as R2a | new regression | fixed from R2a |
|---:|---|---|---|---|
| 5 | `P3D-A-011, P3D-A-012, P3D-A-013, P3D-A-014, P3D-A-015` | `P3D-A-011, P3D-A-012, P3D-A-013, P3D-A-014, P3D-A-015` | `NONE` | `NONE` |

## Waiver

- `probe_harness_expanded.py` is a copied harness used only for expanded diagnostic.
- Change: `--min-prompt-tokens` CLI parameter; default remains `300`; expanded run used `100`.
- Other prompt guards remained active: mounted tool count >0, tools section, empty-think skeleton, assistant tail.
- Prompt diagnostic: `LEGAL_SMALL_MOUNT`, 3 trigger cases (`R2B-Q-FRAGRANCE-AMOUNT-001Q`, `R2B-Q-FRAGRANCE-MODE-001Q`, `R2B-Q-FRAGRANCE-MODE-001L`), token counts `187/187/202`, tool section complete.

## Artifacts

| artifact | path |
|---|---|
| original paired report | `TD-eval-run155204-ready/original-gate/R2B-ORIGINAL-GATE-PAIRED-REPORT.md` |
| expanded raw report | `TD-eval-run155204-ready/expanded/R2B-EXPANDED-ANCHOR-ADAPTER-REPORT.md` |
| prompt diagnostic | `TD-eval-run155204-ready/expanded/EXPANDED-PROMPT-TOKEN-DIAGNOSTIC.md` |
| raw counts | `TD-eval-run155204-ready/TD-EVAL-RAW-COUNTS.json` |
| query scan | `TD-eval-run155204-ready/query-zero-tolerance-cross-track.json` |
| A diff | `TD-eval-run155204-ready/original-gate/A-AXIS-FAIL-DIFF-vs-R2a.json` |

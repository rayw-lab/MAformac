# RECEIPT-V61-TRAIN-PROBE

status: local_train_and_paired_probe_complete
proof_class: local
scope: tiny v6.1 retrain plus paired four-axis probe replication
verdict: not asserted

## Inputs

- Data build: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/P12-v61-build`
- Base model/tokenizer: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/P12-v61-build/qwen3-1_7b-training-tokenizer-patched`
- Train JSONL: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/P12-v61-build/mlx-data/train.jsonl`
- Probe cases: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v6/probe-cases.jsonl`
- Decode contract: `/Users/wanglei/workspace/MAformac-p3h-probe/Tools/ProbeHarness/decode-contract.greedy.json`

## Train Evidence

- Command artifact: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v61/train-command.txt`
- Log: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v61/train-v61.log`
- Metrics: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v61/metrics-v61.jsonl`
- Snapshot: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v61/snapshot.py`
- Adapter output: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v61/adapters-rank16/adapters.safetensors`

Training exited 0. Preflight reported `records=44`, `trainable_records=44`, `trainable_tokens=808`, `ignored_tokens=45744`. Final report at iteration 600: train loss `0.03553819358348846`, LR `9.487915667705238e-05`, trained tokens `11031`, peak memory `11.668406004 GB`. Wall clock from `/usr/bin/time`: `real 1663.50`.

## Probe Evidence

- Command artifact: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v61/probe-command.txt`
- Log: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v61/probe-v61.log`
- Output dir: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v61/probe-output`
- Harness receipt: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v61/probe-output/receipt.md`

Probe exited 0. Wall clock from `/usr/bin/time`: `real 117.93`.

## Harness Hotfix During Probe

The first v61 probe attempt crashed on `C6-TRAP-LURE-001` because `parse_tool_calls` assumed JSON payloads after `<tool_call>` were objects. The model emitted non-object JSON fragments inside repeated tool-call text, causing `AttributeError: 'str' object has no attribute 'get'`.

Fix applied in `/Users/wanglei/workspace/MAformac-p3h-probe`: non-object JSON payloads are now recorded as `tool_call_payload_not_object` parse errors and skipped, preserving fail-closed per-case behavior instead of crashing the full run. Regression test added for `<tool_call>"open_window"</tool_call>`.

Pushed commit: `e6a8849f Fix probe parser for non-object tool payloads` on `codex/p3h-probe-harness-20260702`.

Validation:

- `/opt/homebrew/opt/python@3.13/bin/python3.13 -m py_compile Tools/ProbeHarness/probe_harness.py Tests/ProbeHarnessTests/test_probe_harness.py`
- `/opt/homebrew/opt/python@3.13/bin/python3.13 -m unittest Tests/ProbeHarnessTests/test_probe_harness.py` -> 17 tests OK

Remote PR #26 checks after push did not start because GitHub Actions reported account payment/spending-limit gating. This is recorded as remote CI unavailable, not a code-test failure.

## Expected-Match Summary

Match rule: `observed_tool_names == expected_tool_calls names`, exact and order-sensitive.

| axis | arm | total | empty | non_empty | expected_match | expected_mismatch |
|---|---:|---:|---:|---:|---:|---:|
| A | base | 15 | 12 | 3 | 3 | 12 |
| A | adapter | 15 | 0 | 15 | 15 | 0 |
| B | base | 15 | 2 | 13 | 12 | 3 |
| B | adapter | 15 | 0 | 15 | 11 | 4 |
| C | base | 4 | 0 | 4 | 4 | 0 |
| C | adapter | 4 | 1 | 3 | 2 | 2 |
| D | base | 34 | 2 | 32 | 18 | 16 |
| D | adapter | 34 | 3 | 31 | 5 | 29 |

Artifacts:

- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v61/paired-axis-expected-match-summary.json`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v61/paired-axis-expected-match-summary.md`

## v6-probe2 Diff

Delta rule: v6.1 minus v6-probe2.

| axis | arm | v6_match | v61_match | delta_match | v6_empty | v61_empty | delta_empty |
|---|---:|---:|---:|---:|---:|---:|---:|
| A | base | 3 | 3 | 0 | 12 | 12 | 0 |
| A | adapter | 15 | 15 | 0 | 0 | 0 | 0 |
| B | base | 12 | 12 | 0 | 2 | 2 | 0 |
| B | adapter | 11 | 11 | 0 | 0 | 0 | 0 |
| C | base | 4 | 4 | 0 | 0 | 0 | 0 |
| C | adapter | 4 | 2 | -2 | 0 | 1 | 1 |
| D | base | 18 | 18 | 0 | 2 | 2 | 0 |
| D | adapter | 8 | 5 | -3 | 0 | 3 | 3 |

Artifacts:

- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v61/v6-probe2-diff-summary.json`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v61/v6-probe2-diff-summary.md`

## Raw Generation Stop Comparison

Character-level proxy over saved `raw_generation`; harness does not emit generation token counts.

| run | arm | cases | raw_max | repeated_start_cases | repeated_end_cases | tail_cases | parse_error_cases | parse_error_total |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| v6-probe2 | base | 68 | 144 | 0 | 0 | 0 | 0 | 0 |
| v6-probe2 | adapter | 68 | 768 | 0 | 68 | 68 | 0 | 0 |
| v61 | base | 68 | 144 | 0 | 0 | 0 | 0 | 0 |
| v61 | adapter | 68 | 802 | 1 | 1 | 2 | 4 | 10 |

v61 adapter parse-error case IDs: `P3D-C-002`, `C6-MP-011`, `C6-MP-019`, `C6-TRAP-LURE-001`.
v61 adapter repeated `<tool_call>`/`</tool_call>` case ID: `C6-TRAP-LURE-001`.

Artifacts:

- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v61/raw-generation-stop-comparison.json`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v61/raw-generation-stop-comparison.md`

## Parse Error Drilldown

Source artifacts: v61 and v6-probe2 adapter per-case JSON under `probe-output/adapter`. Full raw text remains in those JSON files; table snippets below are shape evidence only.

| case_id | v6-probe2 shape | v61 shape | v61 parse_error | delta note |
|---|---|---|---|---|
| `P3D-C-002` | Parseable first call `open_defog_mode`; raw repeated the same call tail (`end_count=12`, `tail=true`). | Single partial call, no closing `</tool_call>`; raw ends inside arguments: `{"direction":"前除雾`. | `json_decode` at offset 0. | parse_error appears in v61 only; v6 already had repeat-tail instability but still extracted expected tool. |
| `C6-MP-011` | Parseable first call `switch_atmosphere_lamp_color`; raw repeated same call tail (`end_count=9`, `tail=true`). | Malformed JSON string in arguments: `"arguments":{"}}`; has closing `</tool_call>` but payload is invalid. | `json_decode` at offset 0. | parse_error appears in v61 only; output changed from parseable repeated tail to malformed single call. |
| `C6-MP-019` | Parseable first call `open_window_to_number`; raw repeated same call tail (`end_count=12`, `tail=true`). | Malformed nested arguments: `{"position":"主驾车窗","arguments":{"position":"主驾车窗"}` then closes; JSON is incomplete before `</tool_call>`. | `json_decode` at offset 0. | parse_error appears in v61 only; v6 had repeat-tail instability but still extracted expected tool. |
| `C6-TRAP-LURE-001` | Parseable first call `open_ac_temperature_to_exp` but mismatched expected `lower_ac_temperature_by_exp`; raw repeated same call tail (`end_count=11`, `tail=true`). | Long malformed/nested tool-call text; first object is unterminated, then later JSON strings contain literal `<tool_call>` / `</tool_call>` keys and decode as non-object payloads. | `json_decode` at offset 0 plus six `tool_call_payload_not_object` errors. | residual repeat persists in v61 (`start_count=7`, `end_count=6`, `tail=true`); v6 also repeated, but v61 changed into parse-failing nested/repeated form. |

Interpretation for this receipt: the four parse errors are observed only in v61 under the same harness/parser artifact comparison, while all four corresponding v6-probe2 cases already showed repeated-tail generation. Therefore the EOS supervision increment strongly reduced global repetition counts, but these residual failures are not a clean new-vs-old binary: v61 introduced parse-failing malformed forms on cases that already had v6 repeated-tail instability.

## Residual Risk

- This receipt reports local train/probe evidence only and does not assert a product verdict.
- EOS supervision reduced repeated raw tool-call tails versus v6-probe2, but did not eliminate them in this tiny run.
- C/D expected-match moved down versus v6-probe2 under the same probe harness; this is data for adjudication, not a causal conclusion by this worker.
- Harness parser hotfix was required mid-run to keep malformed non-object tool-call payloads fail-closed instead of crashing the run.
- PR #26 remote CI is blocked by GitHub Actions billing/spending-limit at job start; local harness tests are the available proof for the parser hotfix in this run.

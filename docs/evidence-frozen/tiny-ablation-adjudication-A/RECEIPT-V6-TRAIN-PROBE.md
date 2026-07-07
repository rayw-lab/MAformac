# RECEIPT-V6-TRAIN-PROBE

status: DONE_FOR_SPEC_PCD_LOCAL_RUNTIME
proof_class: local_runtime
captured_at: 2026-07-03T01:05:00+08:00
scope: tiny v6 600-iter MLX LoRA training + paired base/adapter four-axis probe only
non_claims: no C6 acceptance, no candidate comparison, no model-quality verdict, no demo-golden, no V/S/U-PASS

## Authority

- Spec: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/SPEC-PCD-v6-train-probe.md`
- Run auth: `/Users/wanglei/workspace/MAformac/docs/project/phase0/r-l17-human-review-evidence/v6-overnight-run-auth-2026-07-02.md`
- Harness worktree: `/Users/wanglei/workspace/MAformac-p3h-probe`
- Training script: `/Users/wanglei/workspace/MAformac-p12-loss-contract/Tools/C5TrainingCLI/c5_mlx_train_loop.py`
- Build/data/tokenizer: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/P12-v6-build/`
- Output dir: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v6/`

## Commands

Exact commands are persisted for replay:

- Case build: `/opt/homebrew/opt/python@3.13/bin/python3.13 /Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v6/build_probe_cases.py`
- Preflight: `preflight-v6.log` recorded the same P12 build/model/config with `--preflight-loss-mask-only --require-maformac-loss-mask`.
- Training: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v6/train-command.txt`
- Probe: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v6/probe-command.txt`
- Expected-match postprocess: `/opt/homebrew/opt/python@3.13/bin/python3.13 /Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v6/summarize_paired_probe.py`

Frozen training args used from SPEC/v5 surface: `--iters 600`, `--learning-rate 0.0001`, `--grad-clip-norm 1.0`, `--num-layers -1`, config rank/scale unchanged, no sample expansion.

## Training Evidence

| gate | result | evidence |
|---|---:|---|
| preflight records | 44/44 | `metrics-v6.jsonl` event `maformac_loss_mask_preflight`: `records=44`, `trainable_records=44` |
| trainable ratio | 1.0 | `supervision_coverage_digest.min_trainable_non_think_ratio=1.0` |
| max sequence length | 5120 | official training metrics preflight `max_seq_length=5120` |
| NONFINITE events | 0 | metrics scan found `nonfinite_events=0` |
| iterations complete | 600 | final train report `iteration=600`; train log `exit_code=0` |
| adapter output | present | `v6/adapters-rank16/adapters.safetensors` plus checkpoints `0000100`...`0000600`; adapter dir size `480M` |
| elapsed | 1772 seconds | `train-v6.log`: `started_at=2026-07-03T00:30:18+08:00`, `finished_at=2026-07-03T00:59:50+08:00` |

Loss curve from `metrics-v6.jsonl` train reports:

| point | iteration | train_loss | learning_rate | peak_memory_gb |
|---|---:|---:|---:|---:|
| first | 10 | 4.159137725830078 | 0.0 | 3.07269392 |
| mid | 310 | 0.22862179279327394 | 0.00009975348075386137 | 11.668406648 |
| tail | 600 | 0.07226860523223877 | 0.00009487915667705238 | 11.668406648 |

Final log excerpt:

```text
Iter 600: Train loss 0.072, Learning Rate 9.488e-05, It/sec 0.290, Tokens/sec 4.761, Trained Tokens 10431, Peak mem 11.668 GB, Grad Norm Preclip 0.000000
Iter 600: Saved adapter weights to /Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v6/adapters-rank16/adapters.safetensors and /Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v6/adapters-rank16/0000600_adapters.safetensors.
Saved final weights to /Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v6/adapters-rank16/adapters.safetensors.
exit_code=0
```

## Case Set Evidence

`probe-cases.jsonl` was built by `v6/build_probe_cases.py`.

| axis | source | count |
|---|---|---:|
| A | P12-v6-build `mlx-data/train.jsonl`, `c5-train-00001~13,18,19`, protocol user strings | 15 |
| B | `docs/c5-training-readiness-grill/v6-probe-design/b-axis-natural-chinese-checklist.md` §2 natural Chinese table | 15 |
| C | `docs/c5-training-readiness-grill/v6-probe-design/probe-axis-set.md` §3 | 4 |
| D | `contracts/c6-bench-cases.jsonl`, `behavior_class=tool_call` | 34 |
| total | single harness input jsonl | 68 |

Each case has `behavior_class=tool_call`, `input_zh`, `expected_tool_calls`, and `tags.bucket` set to `A/B/C/D` for harness axis grouping.

## Paired Probe Evidence

- Harness: `/Users/wanglei/workspace/MAformac-p3h-probe/Tools/ProbeHarness/probe_harness.py`
- Decode contract: `/Users/wanglei/workspace/MAformac-p3h-probe/Tools/ProbeHarness/decode-contract.greedy.json`
- Decode settings: temperature `0`, max tokens `160`, prompt skeleton `qwen3_patched_no_think_chat_template`, thinking `no_think_block`, parser `p3h_tool_call_json_ordered_v2`, cardinality `ordered_multi_call`.
- Mode: paired mode with `--adapter /Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v6/adapters-rank16`; no `--base-only-smoke`.
- Output: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v6/probe-output/`
- Elapsed: 193 seconds; `probe-v6.log` exit_code=0.
- Per-case raw artifacts: `probe-output/base/*.json` and `probe-output/adapter/*.json`, 68 records per arm, each with `prompt`, `raw_generation`, `truncated_output`, `observed_tool_names`, and parse metadata.
- Prompt skeleton spot check: first base and adapter records both contain `<think>\n\n</think>`; raw generations did not start with `<think>`.

Expected-match rule: `observed_tool_names == expected_tool_calls[].name`, exact and order-sensitive.

| axis | arm | total | empty | non_empty | expected_match | expected_mismatch |
|---|---:|---:|---:|---:|---:|---:|
| A | base | 15 | 15 | 0 | 0 | 15 |
| A | adapter | 15 | 15 | 0 | 0 | 15 |
| B | base | 15 | 15 | 0 | 0 | 15 |
| B | adapter | 15 | 15 | 0 | 0 | 15 |
| C | base | 4 | 4 | 0 | 0 | 4 |
| C | adapter | 4 | 4 | 0 | 0 | 4 |
| D | base | 34 | 34 | 0 | 0 | 34 |
| D | adapter | 34 | 34 | 0 | 0 | 34 |

Machine-readable summary: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v6/paired-axis-expected-match-summary.json`

## Touched Paths

Repo code changed in this task: none.

Run artifacts written:

- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v6/build_probe_cases.py`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v6/summarize_paired_probe.py`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v6/probe-cases.jsonl`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v6/train-command.txt`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v6/train-v6.log`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v6/metrics-v6.jsonl`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v6/adapters-rank16/`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v6/probe-command.txt`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v6/probe-v6.log`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v6/probe-output/`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v6/paired-axis-expected-match-summary.{json,md}`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/RECEIPT-V6-TRAIN-PROBE.md`

## Residual Risks

- This receipt intentionally does not interpret all-zero expected-match results; commander owns the verdict and any threshold discussion.
- This is local MLX runtime proof, not mobile, true-device, demo-golden, C6 acceptance, candidate comparison, or V/S/U-PASS.
- B/C axis source rows were mechanically encoded into `build_probe_cases.py` from the referenced docs; if those docs change, rerun after updating the script.
- Adapter weights and probe raw outputs are local run artifacts outside git; they were not pushed into the PR.

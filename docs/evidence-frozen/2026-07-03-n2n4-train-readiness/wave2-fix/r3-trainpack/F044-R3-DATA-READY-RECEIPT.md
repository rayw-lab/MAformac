# F044 R3 Data Ready Receipt

status: r3_data_ready_static_gates_pass_no_train
proof_class: local_static_assembly_render_datagate_preflight
authority: R3-ASSEMBLY-PLAN.md + user GO 2026-07-04

## Verdict

PASS: R3 trainpack assembled by byte-preserving append and passed locked floors, render row conservation, supervision scanner, DataGate, and strict preflight. No training optimizer update was run and no adapter was saved.

## Inputs

| input | rows | sha256 |
| --- | ---: | --- |
| R2b combined pack | 5499 | `3b76d49767e650b2cf5d41a3dd6b527932c1e2e2500bb249ac917303380f84e0` |
| R3-QNEG candidates | 154 | `1115558026384fc30889a6879f8002fdb7edcb47e7385704f1b4ca58b0dcbd7d` |

R3-COMBO is excluded.

## Output

| artifact | value |
| --- | --- |
| combined samples | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r3-trainpack/c5-training-samples.jsonl` |
| combined sha256 | `7c8c6b6f8b58b9c2fb0cb7a9319e82c92cd275645830d25cc67421a0b719fdf3` |
| samples copy | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r3-trainpack/samples/c5-training-samples.jsonl` |
| MLX data dir | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r3-trainpack/mlx-data` |
| assembly receipt | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r3-trainpack/assembly_receipt.json` |

## Assembly Counts

| metric | value |
| --- | ---: |
| effective rows | 5653 |
| train split | 5253 |
| dev_selection split | 400 |
| action rows | 5342 |
| query tool rows | 147 |
| no-call rows | 164 |
| no-call denominator | 5506 |
| no-call ratio | 2.9786% |

M.22 row conservation: `5499 + 154 = 5653` PASS.

## Static Gates

| gate | verdict | key evidence |
| --- | --- | --- |
| locked floors monotonic | `GREEN` | blocking_red `0`, green `13`, advisory red `4` |
| render + row conservation | `pass` | input `5653`; train+valid `5653`; missing `0`; mount set diff `0/0` |
| supervision scanner | `pass_no_contradictions` | rows `5653`; contradictions `0/0`; mount_order `pass` |
| DataGate | `data_gate_ready` | row_count `5653`; buckets train `5253`, dev_selection `400`; quarantine `0`; must_not_train `0`; redaction `pass` |
| strict preflight | `pass` | records `5781`; train/valid/test `5253/400/128`; trainable_tokens `135013`; ignored_tokens `18387823`; max_token_length `7196`; length_violations `0` |

## Non-Claims

- No training run was started.
- No optimizer update was run.
- No adapter was saved.
- This is not model quality, eval PASS, V-PASS, or candidate signoff.

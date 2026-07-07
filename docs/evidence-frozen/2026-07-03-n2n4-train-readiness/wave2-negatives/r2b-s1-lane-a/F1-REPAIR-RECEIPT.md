# R2B Lane-A F1 Repair Receipt

status: REPAIR_COMPLETE_PENDING_SCOPED_REJUDGE
proof_class: local/repair-lane
lane: `r2b-s1-lane-a`
target_row: `r2b-s1-a-032`
judge_finding: `F1 win_to_1 near-parallel pair had two discriminating cues: polarity and numeric value`
commander_repair: `032 value held constant to 3; 031 untouched`

## Files

| artifact | path |
| --- | --- |
| candidates | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-s1-lane-a/candidates.jsonl` |
| ledger | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-s1-lane-a/value_change_ledger.jsonl` |
| SHA256SUMS | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-s1-lane-a/SHA256SUMS.txt` |
| before snapshot | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-s1-lane-a/_scratch/f1-repair-before-20260704/` |
| pair ledger report | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-s1-lane-a/pair-ledger-f1-repair.json` |
| supervision summary | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-s1-lane-a/supervision-summary-f1-repair.json` |
| supervision contradictions | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-s1-lane-a/supervision-contradictions-f1-repair.jsonl` |

## Edit

Only target row `r2b-s1-a-032` was modified.

| field | before | after |
| --- | --- | --- |
| `input_zh` | `车窗关到一挡` | `车窗关到三挡` |
| assistant tool | `close_window_to_number(value=1)` | `close_window_to_number(value=3)` |
| `expected_tool_calls[0].arguments.value` | `1` | `3` |
| `near_parallel_evidence` | `to-number close; pair mate open_window_to_number; only polarity 关到 vs 开到 + value differ` | `to-number close; pair mate open_window_to_number; only polarity 关到 vs 开到 differs` |
| ledger `args_diff/template_args/canary_args` | `value=1` | `value=3` |
| ledger `why_changed` | `关到一挡 -> value=1` | `关到三挡 -> value=3(SPOT 挡位)` |

Row `r2b-s1-a-031` was intentionally not edited per repair instruction.

## Row SHA

Controller recipe/quota SHA values were preserved:

- `recipe_manifest_sha=sha256:35de977aef3f2459366dfb3a5434348c1c88ef5fcb8def1d0f3a708ed316f293`
- `quota_config_sha=sha256:20199f039d797df4ec20e5a0cd6565639dd38129bf2377bedb29cbfe3a50f6b0`

Target row hash:

| item | sha |
| --- | --- |
| old `candidate_row_sha` | `6053f8d76d88cce2d6f6dd08e1e6bf22706f98e457138289a6da811586258d54` |
| new `candidate_row_sha` | `7e8c19929b8b811157a5613c8842f17c9da468cbc5909b9d274da25d82a820e4` |

Ledger row `r2b-s1-a-032` was updated to the same new `candidate_row_sha`.

## Byte-Scope Proof

Before snapshot:

`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-s1-lane-a/_scratch/f1-repair-before-20260704/`

Line-level byte compare:

| file | changed lines | unchanged lines | total |
| --- | --- | ---: | ---: |
| `candidates.jsonl` | `[32]` | 74 | 75 |
| `value_change_ledger.jsonl` | `[32]` | 74 | 75 |

This satisfies repair-lane scope: target row only; non-target rows byte-identical.

## Gates

Pair ledger:

```bash
python3 /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/tools/pair_ledger_check.py \
  /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-s1-lane-a/candidates.jsonl \
  --output /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-s1-lane-a/pair-ledger-f1-repair.json
```

Result: `exit=0`, `status=pass`, `pair_completeness_percent=100.0`, `failures=[]`.

Supervision scanner:

```bash
python3 /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/tools/supervision_consistency_scanner.py \
  --input /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-s1-lane-a/candidates.jsonl \
  --output /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-s1-lane-a/supervision-contradictions-f1-repair.jsonl \
  --summary-json /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-s1-lane-a/supervision-summary-f1-repair.json \
  --mount-order-report-json /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-s1-lane-a/mount-order-report-f1-repair.json \
  --fail-on-contradiction
```

Result: `exit=0`, `status=pass_no_contradictions`, `contradiction_group_count=0`, `contradiction_row_count=0`, `supervision-contradictions-f1-repair.jsonl` is empty.

Note: mount-order report still records existing `mount_order_unbalanced`; this command did not enable `--fail-on-mount-order`, and that is outside F1 scope.

## Final SHA

| artifact | sha256 |
| --- | --- |
| `candidates.jsonl` | `bd38bdbf57a998313b7db93b489e3fe6f9b276fcd860731bbc1c09a3727d341b` |
| `value_change_ledger.jsonl` | `021c2eb74b70823f1bb680ce4517e2f217abf59a7658b73369eb2c603731e67b` |
| `SHA256SUMS.txt` | `3b8e0b88477fef10d7cc8e88c7f8e4c560aaa7c2277d37b687d4f400049443a8` |
| `pair-ledger-f1-repair.json` | `b49088978b1288e7e8706b2119e0ab313f047d23558132a188b21d76dd83dff5` |
| `supervision-summary-f1-repair.json` | `2e81e4057f403bd0cb986df8bd0cda0262ad81711dded551de275da83391adc1` |
| `supervision-contradictions-f1-repair.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |

`shasum -a 256 -c SHA256SUMS.txt` result:

```text
candidates.jsonl: OK
value_change_ledger.jsonl: OK
batch_manifest.json: OK
batch_self_audit.md: OK
generation_receipt.md: OK
```

## Non-Claims

- No judge re-run in this pane.
- No training assembly.
- No DataGate or full gate rerun.
- This receipt is local repair evidence for scoped re-judge.

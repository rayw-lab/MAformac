---
status: LAUNCH_HOLD_FIRST_REAL_LR_INSUFFICIENT_DISTINGUISHING_POINTS_RC65
artifact_kind: formal_1800_launch_hold_receipt
created_at: 2026-07-05T23:27:00+08:00
repo: /Users/wanglei/workspace/MAformac
launch_root: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch
formal_run_dir: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T232357+0800
proof_class: runtime_launch_attempt
authority_class: launch_hold_receipt
command_sha256: 1cee23449ee2b3402212346dbc435b5ae47e71c6b008f5f0d5a2abc45d8243ac
---

# Formal 1800 Launch Hold Receipt

## Conclusion

Fresh retry used a new `FORMAL_RUN_DIR` and successfully reached trainer pid proof plus armed watchdog proof, but failed the third L-J launch proof: first-real LR.

Final status: `LAUNCH_HOLD_FIRST_REAL_LR_INSUFFICIENT_DISTINGUISHING_POINTS_RC65`.

Command exited rc `65`. No trainer/watchdog process remains after exit.

## Gate Results

| L-J gate | Result | Evidence |
|---|---|---|
| trainer pid proof | `PASS` | `trainer-pid-proof.txt` identified python trainer pid `97598` running `c5_mlx_train_loop.py` |
| watchdog armed proof | `PASS` | `formal-watchdog-heartbeat.jsonl` / `formal-watchdog-armed-proof-tail.txt` included `armed=true` and `shadow=false` |
| first-real LR | `HOLD` | `lr-schedule-verify-real-metrics.json` status `INSUFFICIENT_DISTINGUISHING_POINTS` |

Because all three proofs are required before calling this launched, the run is held rather than launch-signed.

## Command Result

```text
FORMAL_RUN_DIR=/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T232357+0800
COMMAND_RC=65
```

The command printed the LR verifier JSON and exited after failing to find `FORMAL_450_MATCH`.

## LR Verifier Evidence

File: `lr-schedule-verify-real-metrics.json`

Key fields:

| Field | Value |
|---|---|
| status | `INSUFFICIENT_DISTINGUISHING_POINTS` |
| point_count | `1` |
| point_source | `metrics.jsonl:5:optimizer_update` |
| last_point.iteration | `4` |
| last_point.raw_step | `1` |
| last_point.lr | `0.0` |
| formal.matches | `1` |
| formal.distinguishing_points | `0` |
| stale.matches | `1` |
| stale.distinguishing_points | `0` |

Interpretation: the first optimizer update exists and has `learning_rate=0.0`; this matches both formal and stale schedules, so the verifier cannot distinguish the 450 schedule from stale alternatives yet. The scripted gate requires `FORMAL_450_MATCH`, so it held.

## Process State After Exit

Checked after command rc `65`:

```text
ps -p 97598,97602,97608 ...
```

No output.

```text
pgrep -af '[c]5_mlx_train_loop.py|[m]lx_lm|[m]lx_lm.lora|[F]044-formal'
```

No output.

## Non-Claims

- not launch-signed
- not formal completed
- not eval
- not behavior pass
- not candidate signoff
- not C6/UIUE/voice/V-PASS
- not `adapter_learned_qa=true`

## Residual Risk

This is a strict gate timing/design issue, not a trainer-pid or watchdog-armed failure. A later LR check with additional optimizer updates may become distinguishable, but this command exited at the first insufficient point and the trainer is no longer running.

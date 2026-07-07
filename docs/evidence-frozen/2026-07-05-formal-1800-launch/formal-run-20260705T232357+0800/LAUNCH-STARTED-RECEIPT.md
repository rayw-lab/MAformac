---
status: FORMAL_RUN_STARTED__TRAINER_PID_PROOF_PASS__WATCHDOG_ARMED_PASS__FIRST_REAL_LR_PENDING
artifact_kind: formal_1800_launch_started_receipt
created_at: 2026-07-05T23:24:00+08:00
repo: /Users/wanglei/workspace/MAformac
launch_root: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch
formal_run_dir: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T232357+0800
proof_class: runtime_launch_started
authority_class: launch_started_receipt_not_completion
command_sha256: 1cee23449ee2b3402212346dbc435b5ae47e71c6b008f5f0d5a2abc45d8243ac
---

# Formal 1800 Launch Started Receipt

## Status

`FORMAL_RUN_STARTED__TRAINER_PID_PROOF_PASS__WATCHDOG_ARMED_PASS__FIRST_REAL_LR_PENDING`

This is an early launch-start receipt. It proves the trainer process and armed watchdog are live, but it does not prove formal completion, behavior pass, candidate signoff, C6, UIUE, voice, or V-PASS.

Per L-J, the three launch proofs are:

| Gate | Current status | Evidence |
|---|---|---|
| trainer pid proof | `PASS` | `trainer-pid-proof.txt` identifies python trainer leaf pid `97598` running `c5_mlx_train_loop.py` |
| watchdog armed heartbeat | `PASS` | `formal-watchdog-heartbeat.jsonl` and `formal-watchdog-armed-proof-tail.txt` include `armed=true` and `shadow=false` |
| first-real LR | `PENDING` | `metrics.jsonl` currently has metadata/preflight rows only; no `FORMAL_450_MATCH` receipt yet |

## Launch Command

Executed with fresh run dir:

```bash
export FORMAL_EXECUTOR_CLASS=high-codex-worker
export HOST_BASELINE_STATUS=PASS
export FORMAL_RUN_DIR=/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T232357+0800
export MODE=night
bash /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/launch/COMMAND-CANDIDATES-v2.txt
```

Command is still running in the executor session.

## Process Proof

Trainer:

```text
97598 97588 R+   /opt/homebrew/opt/python@3.13/bin/python3.13 .../c5_mlx_train_loop.py --train ... --iters 1800 ... --metrics-jsonl .../formal-run-20260705T232357+0800/metrics.jsonl
```

Watchdog:

```text
97602 97588 S+   bash .../watchdog-command-template.sh
97608 97602 S+   .../Python .../formal-watchdog-draft.py --run-dir .../formal-run-20260705T232357+0800 --pid 97598 ... --armed
```

## Watchdog Evidence

Files present:

- `formal-watchdog-config.json`
- `formal-watchdog-shas.txt`
- `formal-watchdog-heartbeat.jsonl`
- `formal-watchdog-armed-proof-tail.txt`

Armed heartbeat excerpts include:

```json
{"armed": true, "pid": 97598, "shadow": false, "metrics_record_count": 0}
{"armed": true, "pid": 97598, "shadow": false, "last_event": "run_metadata", "metrics_record_count": 1}
```

Note: `formal-watchdog-config.json` retains the template status string `READY_TO_ARM_TEMPLATE_NOT_ARMED`, but the live heartbeat and process command show the watchdog was invoked with `--armed`.

Watchdog script shas:

```text
e8257fab45d60a486aeed17558632f346c87baa7a68fca850fc5eb9d09ade8ed  formal-watchdog-draft.py
a67f0ed0750c4f9c6578ce9190f5923b1b88c3c5a4b37767e864ba8d9da2620a  formal-watchdog-modes.json
```

## Metrics / LR State

`metrics.jsonl` currently contains:

- `run_metadata`
- `maformac_loss_mask_preflight`

No first optimizer-update LR row had appeared at receipt time, so first-real LR remains `PENDING`.

## Non-Claims

- not formal completed
- not eval
- not behavior pass
- not candidate signoff
- not C6/UIUE/voice/V-PASS
- not `adapter_learned_qa=true`

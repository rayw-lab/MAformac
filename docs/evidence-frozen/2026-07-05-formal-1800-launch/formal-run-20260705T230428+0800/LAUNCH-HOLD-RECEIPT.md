---
status: LAUNCH_HOLD_PRETRAIN_WATCHDOG_TEMPLATE_NOT_EXECUTABLE
artifact_kind: formal_1800_launch_hold_receipt
created_at: 2026-07-05T23:04:28+08:00
repo: /Users/wanglei/workspace/MAformac
launch_root: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch
formal_run_dir: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T230428+0800
proof_class: local_runtime_launch_attempt
authority_class: launch_attempt_receipt
---

# Formal 1800 Launch Hold Receipt

## Conclusion

`COMMAND-CANDIDATES-v2.txt` was executed with the commander-specified environment, but exited before trainer launch.

Final status: `LAUNCH_HOLD_PRETRAIN_WATCHDOG_TEMPLATE_NOT_EXECUTABLE`.

No trainer pid was created, no watchdog was armed, no first-real LR gate ran, no formal completion/candidate/C6/V-PASS is claimed.

## Command Environment

```bash
export FORMAL_EXECUTOR_CLASS=high-codex-worker
export HOST_BASELINE_STATUS=PASS
export FORMAL_RUN_DIR=/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T230428+0800
export MODE=night
bash /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/launch/COMMAND-CANDIDATES-v2.txt
```

Command result:

| Field | Value |
|---|---|
| started_at | `2026-07-05T23:04:28+08:00` |
| ended_at | `2026-07-05T23:04:28+08:00` |
| rc | `1` |
| trainer launched | no |
| watchdog armed | no |
| first-real LR gate | not reached |

## Preflight Evidence

| Check | Result |
|---|---|
| command file sha256 | `b0c92bb3e2345356c24a1027babe992569aa692fe289ae9c1a5854096c02d259` |
| `bash -n COMMAND-CANDIDATES-v2.txt` | rc `0` |
| host PASS receipt | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/host/host-baseline-after-gui-close-pass.md` |
| host status | `HOST_BASELINE_PASS_AFTER_GUI_CLOSE` |
| host chosen memory-pressure basis | `26.11340115968GB >= 21GB` |
| swap | about `0.289GB <= 1GB` |

## Failure Point

The command passed the trainpack sha check:

```text
/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r3-trainpack/c5-training-samples.jsonl: OK
```

Then it exited during the static executable checks before launching the trainer.

Diagnostic check:

| Path | Mode / result |
|---|---|
| `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/tools/verify_formal_lr_schedule.py` | executable: yes |
| `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/watchdog/watchdog-command-template.sh` | executable: no |

Observed file mode:

```text
-rw-r--r--@ ... /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/watchdog/watchdog-command-template.sh
```

The launch script requires:

```bash
test -x "$WATCHDOG_TEMPLATE"
```

Therefore the launch held before trainer start. I did not chmod, patch, or otherwise change the command/template/config.

## Files Created By Attempt

| Path | Status |
|---|---|
| `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T230428+0800/` | created |
| `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T230428+0800/adapters-rank16/` | created |
| `trainer-pid-proof.txt` | absent |
| `train.log` | absent |
| `metrics.jsonl` | absent |
| watchdog config/shas/heartbeat | absent |

## Stopline Applied

This is a pretrain launch-surface failure. Per L-A stoplines, I held and did not patch config or permission state.

Minimum next action is commander-authorized repair of the watchdog template executable bit or a v3 command/template receipt, then rerun the same formal launch gate sequence from a fresh `FORMAL_RUN_DIR`.

## Non-Claims

- not launched
- no trainer pid
- no watchdog armed
- no first-real LR gate
- no formal completion
- no eval
- no candidate signoff
- no C6/UIUE/voice/V-PASS

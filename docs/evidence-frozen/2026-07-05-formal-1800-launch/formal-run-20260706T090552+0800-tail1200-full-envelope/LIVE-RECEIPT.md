---
status: TRAINER_LIVE_NON_PREFLIGHT_600ITER_NO_AUTO_WATCHDOG
created_at: 2026-07-06T09:05:52+08:00
updated_at: 2026-07-06T09:11:13+08:00
formal_run_dir: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260706T090552+0800-tail1200-full-envelope
proof_class: runtime_launch_receipt
mode: full_envelope_no_auto_watchdog
trajectory: checkpoint1200_weight_init_new_trajectory
trainer_pid: 42505
tmux_session: L_BL_tail1200_090552
eta: 3h10m-3h40m from launch
---

# L-BL Live Receipt

## Status

`TRAINER_LIVE_NON_PREFLIGHT_600ITER_NO_AUTO_WATCHDOG`.

This run is authorized by L-BL as full-envelope/no-auto-watchdog checkpoint1200 weight-init tail. It is not true optimizer/RNG/iteration resume and not a frozen formal completion claim.

## L-BL-ADDENDUM

User explicitly accepts `checkpoint1200 -> 1800` adapter-weight-init NEW TRAJECTORY. This run does not wait for true `1692` resume proof. Receipt status remains: not true optimizer/RNG/iteration resume, no auto watchdog interrupt, no candidate, no C6, no V-PASS.

## L-BL Status Poke

At `2026-07-06T09:11:13+08:00`, process check disagreed with the claim that there was no live non-preflight trainer. PID `42505` is alive and its command includes `--train --iters 600 --resume-adapter-file ...0001200_adapters.safetensors --metrics-jsonl .../metrics.jsonl`. `metrics.jsonl` has left preflight and contains `optimizer_update` at `iteration=4`, `update_step=1`, `learning_rate=4.350494418758899e-05`. No duplicate trainer was launched, because starting a second 600-iter run against the same run dir would create competing metrics/adapters.

## Launch Evidence

| Item | Evidence |
| --- | --- |
| trainer pid | `trainer.pid`, `trainer-pid-proof.txt` |
| tmux session | `L_BL_tail1200_090552` |
| trainpack sha | `trainpack-sha-check.txt` |
| trainpack rows | `trainpack-row-count.txt` |
| adapter input sha | `resume-adapter-sha.txt` |
| launch/config shas | `launch-shas.txt` |
| log | `train.log` |
| metrics | `metrics.jsonl` |
| watchdog | no auto watchdog armed |

## Non-Claims

- not candidate
- not C6/UIUE/voice/V-PASS
- not behavior pass
- not `adapter_learned_qa=true`
- no auto watchdog armed

## ETA

User-provided basis: 600 iter from checkpoint1200, prior median `17.1-17.4 sec/iter`, plus final val/save/startup = about `3h10m-3h40m`.

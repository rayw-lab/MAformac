---
status: HOST_WAIVER_RECORDED_LIMITED_SCOPE__FORMAL_NOT_COMPLETE
artifact_kind: host_waiver_receipt
created_at: 2026-07-05T23:45:32+08:00
run_root: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch
formal_run_dir: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800
proof_class: commander_user_scope_receipt + run_dir_file_evidence
authority_class: secretary_memory_receipt_not_launch_auth
---

# Host Waiver Receipt: user 2026-07-05 memory-more-ok

## Status

`HOST_WAIVER_RECORDED_LIMITED_SCOPE__FORMAL_NOT_COMPLETE`

The current fresh run is `formal-run-20260705T234208+0800`. It has started, with trainer pid `16315` and watchdog armed. This receipt records the limited host waiver scope only.

## Waiver Scope

The waiver covers acceptance of host swap/free-memory envelope risk for this evidence run.

It means the earlier swap/free blocker is not, by itself, a secretary stop reason for this run.

It does not mean training is complete. It does not mean candidate, C6, UIUE, voice, or V-PASS.

## Explicit Non-Waived Gates

| Gate | Waived? | Note |
|---|---:|---|
| watchdog `memory_pressure_free_pct < 4.0` kill | no | must remain armed |
| watchdog `process_peak > 22.34GB` kill | no | must remain armed |
| first-real LR | no | `FORMAL_450_MATCH` still required |
| trainpack sha | no | frozen sha gate remains |
| trainpack row count | no | frozen row-count gate remains |
| nonfinite/train-health stops | no | runtime health gates remain |
| proof-class discipline | no | evidence-run-only until separate signoff |

## Evidence Table

| Evidence | File / command | Key fact |
|---|---|---|
| fresh run started | `formal-run-20260705T234208+0800/LAUNCH-STARTED-RECEIPT.md:2-7` | status started; trainer pid `16315`; watchdog pid `16319` |
| trainer proof | `trainer-pid-proof.txt:1` | python trainer command includes `--iters 1800` and run dir metrics/adapters |
| watchdog armed | `formal-watchdog-armed-proof-tail.txt:1-2` | `armed=true`, `shadow=false` |
| post-hold host blocker | `host/post-hold-host-swap-recovery-sampler.md:14-27` | prior retry readiness held because swap stayed >1GiB |
| redteam waiver boundary | `monitor/post-hold-opus-redteam.md:67-91` | memory/swap waiver is legal only if runtime kill and LR gates remain non-waived |
| live memory sample | `formal-watchdog-heartbeat.jsonl` tail | free 5-9% and swap about 3.4-3.7GiB while watchdog armed |

## Residual Risk

- Swap/free waiver accepts operational risk; it does not remove the risk.
- The runtime kill thresholds are the safety backstop and remain non-waivable.
- A first optimizer LR point at `0.0` is not enough to prove the 450-update LR schedule.
- This receipt is a memory/status artifact, not launch authority.

## Non-Claims

- no formal completion
- no eval
- no behavior pass
- no candidate signoff
- no C6/UIUE/voice/V-PASS
- no `adapter_learned_qa=true`

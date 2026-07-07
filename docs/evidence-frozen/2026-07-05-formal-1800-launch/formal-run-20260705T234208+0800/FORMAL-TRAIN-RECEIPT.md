---
status: FORMAL_TRAIN_HOLD_TRAINER_RC_143
created_at: 2026-07-06T08:16:56+08:00
formal_run_dir: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800
trainer_rc: 143
proof_class: runtime_formal_train
adapter_sha_basis: 3f90a5cd939fa85b7062c2282f2ddf0cf550a4d1e74b2467e8a8e04e1dcd5f78
candidate_status: unsigned
adapter_learned_qa: false
---

# Formal Train Receipt

## Status

`FORMAL_TRAIN_HOLD_TRAINER_RC_143`

## Proof Table

| Gate | Result | Evidence |
|---|---|---|
| executor high-mode | PASS | `preflight-proof.txt`; commander L-T assignment |
| trainpack sha | PASS | `trainpack-sha-check.txt` |
| trainpack rows | PASS | `trainpack-row-count.txt` |
| trainer pid proof | PASS | `trainer-pid-proof.txt` |
| watchdog armed proof | PASS | `formal-watchdog-armed-proof-tail.txt` |
| first real LR | PASS | `lr-schedule-verify-real-metrics.json` status `FORMAL_450_MATCH` |
| trainer rc | `143` | `train.log`, `metrics.jsonl` |
| adapter sha basis | `3f90a5cd939fa85b7062c2282f2ddf0cf550a4d1e74b2467e8a8e04e1dcd5f78` | `adapter-file-shas.txt` if present |

## Train Health

Runtime formal training reached trainer exit rc `143`. Behavior/eval gates are TODO unless separate receipts are produced.

## Non-Claims

- candidate_status remains unsigned
- adapter_learned_qa=false
- no C6/UIUE/voice/V-PASS
- no behavior pass unless separately evaluated

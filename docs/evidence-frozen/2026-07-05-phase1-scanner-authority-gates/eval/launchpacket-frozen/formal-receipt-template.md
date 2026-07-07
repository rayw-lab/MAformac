# Formal Train Receipt Template - Frozen

status: `FROZEN_STATIC_TEMPLATE`
authority: `SPEC-freeze-launchpacket.md`
phase1_commit: `6a4b6b827257acaf8195b40a5ea67469448aec94`
recipe: `R3-QNEG-clean`

## Header

| field | value |
| --- | --- |
| formal_run_dir | `FILL_AFTER_RUN` |
| code_head | `FILL_AFTER_RUN` |
| formal_basis | `R3-QNEG-clean` |
| phase1_clean_trainpack_path | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r3-trainpack/c5-training-samples.jsonl` |
| phase1_clean_trainpack_sha256 | `fa5690400f67db9ef237dabdb489f58d1ab69961f14d6733d79f9bd7cad33823` |
| phase1_clean_trainpack_rows | `5653` |
| adapter_learned_qa | `false` |
| adapter_qa_gate | `fail_accepted_under_B` |
| runtime_qa_safety_gate | `FILL_CANDIDATE_SIGNOFF_ONLY` |
| candidate_status | `unsigned` |

## Proof Classes

| gate | proof class | required fill |
| --- | --- | --- |
| data identity | `local_static` | sha/row/path guard output |
| host baseline | `runtime_at_launch` | fresh D-094/D-102 snapshot, not older packet data |
| watchdog | `runtime_at_launch` | real pid, armed proof, heartbeat path |
| LR schedule static fixture | `local_static` | freeze packet rc0 command/output |
| LR schedule formal runtime | `runtime_after_launch` | first formal `metrics.jsonl` or `train.log` verifier rc |
| model_behavior_gate | `local_eval_after_run` | A/B/D + T1 counts and verdict |
| adapter_qa_gate | `local_scanner_after_run` | qa counts under B; do not claim learned qa |
| runtime_qa_safety_gate | `runtime_candidate_signoff` | separate candidate receipt only |

## Required Filled Verdict Fields

```yaml
formal_train_health: FILL_AFTER_RUN
model_behavior_gate: FILL_AFTER_RUN
t1_gate: FILL_AFTER_RUN
adapter_qa_gate: fail_accepted_under_B
adapter_learned_qa: false
runtime_qa_safety_gate: FILL_CANDIDATE_SIGNOFF_ONLY
candidate_status: unsigned
v_pass: false
```

## Non-Claims

- Formal train completion is not candidate signoff.
- `adapter_qa_gate=fail_accepted_under_B` is not runtime qa safety.
- `adapter_learned_qa=false` remains fixed unless a separate proof explicitly overturns it.
- This template must not be used to claim mobile, true-device, live-api, or V-PASS proof.

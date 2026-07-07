# formal-receipt-template — v2 draft

status: `FILL_AFTER_FORMAL_RUN`
artifact_kind: `formal_train_receipt_template_v2_draft`
target_basis: `B_D108_D110_plus_R3_QNEG_clean`
proof_class: `template_only_not_training_verdict`
claim_boundary: Formal receipt may claim train-health and model behavior gate results only after evidence is filled. Candidate signoff is a separate downstream receipt.

## Required Top-Level Fields

| field | value |
|---|---|
| formal_run_id | `FILL_AFTER_RUN` |
| formal_adapter_sha256 | `FILL_AFTER_RUN` |
| formal_basis | `R3-QNEG-clean` |
| phase1_clean_trainpack_sha256 | `<PENDING_PHASE1_CLEAN_SHA>` |
| model_behavior_gate | `FILL_AFTER_EVAL__PASS_FAIL_PARTIAL` |
| t1_gate | `FILL_AFTER_EVAL__PASS_FAIL_PARTIAL` |
| adapter_qa_gate | `fail_accepted_under_B` |
| runtime_qa_safety_gate | `NOT_RUN_FOR_FORMAL_START` |
| adapter_learned_qa | `false` |
| runtime_guard_implemented | `FILL_AFTER_CANDIDATE_GATE__true_false` |
| candidate_status | `unsigned` |

## Non-Claims

- not adapter-learned qa
- not runtime qa safety pass unless `runtime_qa_safety_gate=PASS` is separately proven
- not candidate signoff
- not C6 acceptance
- not endpoint readiness
- not mobile proof
- not true-device proof
- not V-PASS

## Basis Binding

| lane | value | source | verdict |
|---|---|---|---|
| code | `FILL_AFTER_RUN__code_head_and_training_loop_sha` | run metadata | `FILL_AFTER_RUN` |
| data | `R3-QNEG-clean`; sha `<PENDING_PHASE1_CLEAN_SHA>` | Phase 1 data freeze | `FILL_AFTER_RUN` |
| config | rank16, LR 1e-4, horizon 450, warmup 36, iters 1800, updates 450 | formal config + run metadata | `FILL_AFTER_RUN` |
| watchdog | `FILL_AFTER_RUN__watchdog_config_sha_and_heartbeat_path` | watchdog receipt | `FILL_AFTER_RUN` |
| host baseline | `FILL_AFTER_RUN__host_baseline_sha_and_verdict` | host baseline snapshot | `FILL_AFTER_RUN` |

## Train-Health Scan

| metric | value | source | verdict |
|---|---|---|---|
| optimizer_update events | `FILL_AFTER_RUN` | metrics full scan | `FILL_AFTER_RUN` |
| nonfinite loss/grad | `FILL_AFTER_RUN` | metrics full scan | `MUST_BE_0` |
| peak_memory_gb | `FILL_AFTER_RUN` | metrics/watchdog | `FILL_AFTER_RUN` |
| wall_clock_seconds | `FILL_AFTER_RUN` | run timestamps | `FILL_AFTER_RUN` |
| final adapter exists | `FILL_AFTER_RUN` | filesystem + sha | `FILL_AFTER_RUN` |

## Behavior Eval Summary

| gate | result | proof class | note |
|---|---|---|---|
| A | `FILL_AFTER_EVAL` | `local/runtime_eval` | model behavior |
| B | `FILL_AFTER_EVAL` | `local/runtime_eval` | model behavior |
| D | `FILL_AFTER_EVAL` | `local/runtime_eval` | model behavior |
| T1 | `FILL_AFTER_EVAL` | `local/runtime_eval` | true-query/action-question |
| adapter qa | `fail_accepted_under_B` | `local/scanner` | must report counts, not candidate safety |
| runtime qa safety | `NOT_RUN_FOR_FORMAL_START` | `none` | candidate signoff gate |

## Stop Lines

- If train-health fails, receipt status is `FAIL` or `PARTIAL`; do not run candidate signoff.
- If A/B/D/T1 fail, candidate status remains `blocked`.
- If runtime qa safety is not proven, candidate status remains `unsigned` even if formal train-health passes.

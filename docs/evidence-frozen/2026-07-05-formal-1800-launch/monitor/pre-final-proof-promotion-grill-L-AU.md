---
status: PASS_PRE_FINAL_PROOF_PROMOTION_MATRIX_READY__NO_OVERCLAIM_FOUND__CANDIDATE_STILL_BLOCKED
artifact_kind: pre_final_proof_promotion_grill
created_at: 2026-07-06T06:48:00+08:00
run_root: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch
formal_run_dir: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800
proof_class: runtime_readonly_audit_plus_acceptance_matrix
authority_class: monitor_grill_not_training_receipt_not_candidate_receipt
---

# L-AU Pre-Final Proof-Promotion Grill / Acceptance Matrix

## Verdict

`PASS_PRE_FINAL_PROOF_PROMOTION_MATRIX_READY__NO_OVERCLAIM_FOUND__CANDIDATE_STILL_BLOCKED`.

当前 live truth：L-AS 已级联 iter1400；active run 仍在训练中；`FORMAL-TRAIN-RECEIPT.md` 和 current-run `LAUNCH-HOLD-RECEIPT.md` 在 `2026-07-06T06:46:14+08:00` sample 均不存在；trainer pid `16315`、watchdog pids `16319/16325` 仍 live。pre-final docs sampled 未发现把 val1000/val1400 或 future 1800 completion 升格成 behavior/candidate/C6/V-PASS。

核心结论：即使 1800 以漂亮 val loss 完成，也只能进入 `formal_train_done` 证据层；candidate signoff、C6/V-PASS/behavior 仍是独立硬门。val1000/val1400 是 lure，不是 proof。

## Evidence Table

| Source | Checked evidence | Audit result |
| --- | --- | --- |
| `COMMANDER-LIVE-STATUS.md` | L-AS records iter1400 `val_loss=0.0008021390531212091`, `train_loss=0.02105362117290497`, trainer/watchdog live, LR receipt present, no formal/HOLD receipt, and explicitly says val1400 is telemetry only. | PASS |
| `monitor/iter1400-receipt-consistency-audit-L-AT.md` | L-AT verifies iter1400 metrics/log, LR retained, live trainer/watchdog, no FORMAL/HOLD receipt, and no overclaim in sampled docs. | PASS |
| `monitor/post-checkpoint1200-opus-adversarial-audit-L-AR.md` | L-AR says checkpoint1200 reduces risk but val loss is structurally blind to A/B/D behavior, qa safety, and base forgetting; 1800 must remain separate from candidate. | PASS |
| `docs/CURRENT.md` | Current stoplines prohibit promoting train_health to behavior pass, candidate pass, C6 acceptance, or V-S-U-PASS; C6 acceptance/comparison, demo-golden, voice/live-loop require candidate signoff and proof-class evidence. | PASS |
| `docs/baseline-roadmap-2026-07-05-c5-d106.md` | Phase 5 formal is evidence-run-only; post-run success requires formal receipt, frozen-manifest behavior eval, A/B/D pass, qa(B) layering, adapter sha/basis/non-claims, and separate candidate receipt. | PASS |
| live run sample | `FORMAL_RC:1`, `HOLD_RC:1`; metrics tail progressed past 1400 to 1436; pids `16315/16319/16325` live. | RUNNING_NOT_FINAL |

## Reduction Matrix

| Proposed claim after 1800 | Minimum sufficient evidence | What it proves | What remains blocked |
| --- | --- | --- | --- |
| `C5_FORMAL_TRAIN_DONE` | `FORMAL-TRAIN-RECEIPT.md`; final adapter/checkpoint present; no current-run HOLD; metrics/train.log show expected final 1800 completion; watchdog did not trip redlines; adapter sha/basis/config/trainpack rows recorded. | The frozen formal training run completed with train-health evidence. | Does not prove behavior, qa safety, candidate, C6, UIUE, voice, demo, or V-PASS. |
| `C5_MODEL_BEHAVIOR_PASS` | Frozen manifest eval after training; A/B/D pass against locked gates; tool-name hallucination and T1/query regression checked; exact adapter basis bound. | Model behavior on the eval gate is acceptable. | Does not prove runtime qa safety, candidate signoff, C6 acceptance, UIUE, voice, or V-PASS. |
| `C5_RUNTIME_QA_SAFETY_PASS` | RuntimeQueryGuard path proof with qa cross-track cases, T1 true_query/action_question, readback/runtime path evidence, and `runtime-gated qa safety=0`. | Runtime safety layer blocks qa actuation under Phase 4 B semantics. | Does not prove adapter learned qa; must keep `adapter_learned_qa=false/unknown` unless adapter-only qa=0 has independent proof. |
| `C5_ADAPTER_QA_PASS` | Adapter-only qa expected-empty gate returns 0 any_tool_call_fail under hardened scanner. | Adapter prompt path itself stopped qa actuation. | Not currently proven; cannot be inferred from formal completion or low val loss. |
| `C5_CANDIDATE_SIGNED` | Candidate receipt with adapter sha, basis, frozen eval results, model_behavior_gate, adapter_qa_gate/runtime_qa_safety_gate, W34 final-head rerun, base-vs-LoRA comparison, checkpoint comparison, non-claims, and R-L17 candidate-level signoff. | A C5 LoRA candidate is accepted for downstream comparison/use. | Does not itself prove C6/UIUE/voice/V-PASS; those remain downstream gates. |
| `C6_COMPARISON_OR_ACCEPTANCE` | Signed candidate + explicit C6 run authorization + C6 four-layer comparison/acceptance results with denominator/scorer/replay/readback/fingerprint bound. | C6-specific comparison/acceptance result. | Cannot be started from route-only R7, formal receipt, L6 seed, or low val telemetry alone. |
| `V-PASS` / demo readiness / voice readiness | Product-defined acceptance proof at matching proof class: runtime/mobile/true-device/live_api as applicable, plus C6/voice/UIUE gates. | Only the corresponding product gate. | Not unlocked by formal training or candidate signoff alone. |

## 600/1200/1800 Checkpoint Comparison

Required before choosing a candidate: **yes**.

Rationale:
- L-AR flags the val-min/checkpoint mismatch: val bottom was observed around iter1000, while saved checkpoints are 600/1200/1800.
- Formal run must not be interrupted or cherry-picked mid-train, but post-run candidate selection must not default to 1800 merely because it is final.
- Candidate choice needs at least 600 vs 1200 vs 1800 comparison on the acceptance gates: A/B/D, qa(B) layering, T1/query safety, base-vs-LoRA regression/forgetting, and manifest-bound behavior evidence.
- Low val loss may rank training telemetry; it cannot rank candidate fitness by itself.

## Hard NO-CLAIMS List

Forbidden unless the matching artifact exists:

- `candidate_status=signed`
- `adapter_learned_qa=true`
- `behavior pass`
- `qa safety pass`
- `C6 acceptance`
- `C6 comparison pass`
- `UIUE merge ready`
- `voice ready`
- `demo-golden ready`
- `mobile pass`
- `true-device pass`
- `live_api pass`
- `V-PASS`, `S-PASS`, or `U-PASS`
- `C5 done` if used to imply candidate/product readiness
- `1800 best checkpoint` before 600/1200/1800 comparison
- `base forgetting clear` without base-vs-LoRA comparison

Allowed wording if final receipt is complete:

- `formal 1800 training completed`
- `formal_train_done`
- `train_health evidence collected`
- `candidate_status=unsigned`
- `adapter_qa_gate=fail_accepted_under_B` unless adapter-only qa=0 is independently proven
- `runtime qa safety pending` until RuntimeQueryGuard proof exists

## Final-Receipt Checklist

Secretary/commander docs should not mark formal complete until all items below are visible in the active run dir:

1. `FORMAL-TRAIN-RECEIPT.md` exists and records status, created_at, proof_class, non-claims, adapter sha/basis, trainpack rows/sha, config, run dir, trainer pid, watchdog pid, and LR receipt reference.
2. No current-run `LAUNCH-HOLD-RECEIPT.md` exists after the final receipt, or any HOLD is explicitly resolved by newer authority.
3. `metrics.jsonl` and `train.log` contain final 1800 completion evidence, not only a pre-final validation window.
4. Final adapter/checkpoint artifacts exist and are hashable; 600/1200/1800 checkpoint inventory is preserved for comparison.
5. Watchdog heartbeat/proof shows `armed=true`, `shadow=false`, no kill redline, and terminal evidence consistent with trainer completion.
6. Receipt explicitly separates `formal_run_status`, `model_behavior_gate`, `adapter_qa_gate`, `runtime_qa_safety_gate`, `candidate_status`, and downstream C6/UIUE/voice/V-PASS non-claims.
7. Receipt does not use val loss, train loss, LR, or checkpoint existence as a proxy for behavior/candidate/product acceptance.

## Exact Stop Conditions For Secretary / Commander Docs

Treat the doc cascade as invalid and rewrite/hold if any of these appears:

- A shared status doc says or implies `candidate signed`, `C6 accepted`, `V-PASS`, `behavior pass`, `adapter learned qa`, `base forgetting clear`, `voice ready`, or `UIUE ready` based only on formal completion or loss telemetry.
- Final status is updated before `FORMAL-TRAIN-RECEIPT.md` exists.
- A future `FORMAL-TRAIN-RECEIPT.md` lacks non-claims, adapter sha/basis, frozen manifest/eval plan references, or separates neither behavior nor qa gates.
- A checkpoint is selected as candidate without 600/1200/1800 comparison and base-vs-LoRA regression/forgetting check.
- Route-only R7 is reused as candidate signoff.
- W34 final-head rerun is skipped before candidate promotion.
- RuntimeQueryGuard proof is conflated with adapter learning.
- Host waiver is reused to waive completion proof, watchdog redlines, behavior gates, or candidate/C6/V-PASS proof.

Recommended doc-cascade status before final receipt:

`TRAINING_CONTINUES__FORMAL_NOT_COMPLETE__PRE_FINAL_PROOF_PROMOTION_MATRIX_READY__CANDIDATE_UNSIGNED`.

Recommended doc-cascade status immediately after a valid formal receipt, before eval/signoff:

`FORMAL_TRAIN_DONE__BEHAVIOR_EVAL_PENDING__CANDIDATE_UNSIGNED__NO_C6_VPASS`.

## Residual Risks

- Active run can still fail after this sample; this grill is pre-final, not a terminal receipt.
- Very low val loss increases human proof-promotion pressure.
- 1800 may not be the best candidate checkpoint; comparison is required.
- Base forgetting is not measured by train/val telemetry.
- RuntimeQueryGuard and W34 final-head rerun remain candidate-promotion gates, not formal-run evidence.

## Touched Paths

Written:
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/monitor/pre-final-proof-promotion-grill-L-AU.md`

Read/probed:
- `/Users/wanglei/workspace/MAformac/CLAUDE.md`
- `/Users/wanglei/workspace/MAformac/docs/CURRENT.md`
- `/Users/wanglei/workspace/MAformac/docs/baseline-roadmap-2026-07-05-c5-d106.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/COMMANDER-LIVE-STATUS.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/secretary/STATUS-BOARD.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/secretary/EVIDENCE-INDEX.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/monitor/iter1400-receipt-consistency-audit-L-AT.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/monitor/post-checkpoint1200-opus-adversarial-audit-L-AR.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800/metrics.jsonl`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800/train.log`
- Runtime sample: `ps -p 16315,16319,16325`; receipt probes for `FORMAL-TRAIN-RECEIPT.md` and `LAUNCH-HOLD-RECEIPT.md`.

## Confidence

High for proof-promotion boundaries, current non-overclaim state, L-AS/L-AT/L-AR consistency, and required separation between formal completion and candidate/C6/V-PASS.

Medium for live run status because training continues and can produce new terminal artifacts after this sample.

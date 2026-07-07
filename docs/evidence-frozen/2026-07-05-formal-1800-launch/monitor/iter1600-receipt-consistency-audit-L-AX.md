---
status: PASS_LIVE_ITER1600_VERIFIED__L_AW_NOT_AVAILABLE__DOCS_CONSERVATIVE_STALE__NO_OVERCLAIM
artifact_kind: iter1600_receipt_consistency_audit
created_at: 2026-07-06T07:38:00+08:00
run_root: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch
formal_run_dir: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800
proof_class: runtime_readonly_audit
authority_class: monitor_note_not_training_receipt_not_candidate_receipt
---

# L-AX Iter1600 Receipt Consistency Audit

## Verdict

`PASS_LIVE_ITER1600_VERIFIED__L_AW_NOT_AVAILABLE__DOCS_CONSERVATIVE_STALE__NO_OVERCLAIM`.

Iter1600 telemetry is live-verified in `metrics.jsonl` and `train.log`; trainer and watchdog were still live at sample; LR gate PASS is retained; `FORMAL-TRAIN-RECEIPT.md` and current-run `LAUNCH-HOLD-RECEIPT.md` were absent. Sampled shared docs did not show L-AW/iter1600 cascade yet and still described "no iter1600 milestone yet"; this is conservative stale wording, not proof-promotion.

Iter1600 is telemetry only. It is not formal completion, not a checkpoint, not behavior pass, not candidate signoff, not C6, and not V-PASS. L-AU remains controlling: future 1800 completion can prove only `formal_train_done` until downstream eval/signoff gates exist.

## Evidence Table

| Check | Evidence | Result |
| --- | --- | --- |
| Iter1600 validation metric | `metrics.jsonl:577` has `event=val`, `iteration=1600`, `val_loss=0.011357142589986324`, `val_time=59.3215444170055`. | PASS |
| Iter1600 train report | `metrics.jsonl:580` has `event=train_report`, `iteration=1600`, `train_loss=0.05441714525222778`, `learning_rate=1.8228482076665387e-05`, `peak_memory=17.9742714`, `trained_tokens=68488`. | PASS |
| Iter1600 optimizer point | `metrics.jsonl:581` has `event=optimizer_update`, `iteration=1604`, `update_step=401`, `learning_rate=1.8228482076665387e-05`. | PASS |
| Train log corroboration | `train.log:188` confirms `Iter 1600: Val loss 0.011, Val took 59.322s`; `train.log:189` confirms `Iter 1600: Train loss 0.054`, `Learning Rate 1.823e-05`, `Trained Tokens 68488`, `Peak mem 17.974 GB`. | PASS |
| Trainer live at sample | `ps -p 16315` at `2026-07-06T07:36:45+08:00` showed python leaf trainer pid `16315`, state `S`, elapsed `07:54:37`, running the formal `c5_mlx_train_loop.py --iters 1800 ...` command for this run dir. | PASS |
| Watchdog live at sample | `ps -p 16319,16325` showed watchdog wrapper `16319` and armed watchdog child `16325` for the same run dir. | PASS |
| Watchdog heartbeat | Latest heartbeat tail sampled after iter1600 showed `armed=true`, `shadow=false`, `pid=16315`, `latest_peak_memory_gb=17.9742714`, free pct about `9-11`, swap about `4.535-4.552GiB`, and metrics count advancing to `584`. | PASS |
| LR retained | `LR-GATE-PASS-RECEIPT.md:2-10` has `status=FIRST_REAL_LR_FORMAL_450_MATCH` and says the existing verifier returned `FORMAL_450_MATCH`; `lr-schedule-verify-real-metrics.json:104` retains `FORMAL_450_MATCH`. | PASS |
| Formal completion receipt absence | `test -f FORMAL-TRAIN-RECEIPT.md` returned rc `1`; only `LAUNCH-STARTED-RECEIPT.md` and `LR-GATE-PASS-RECEIPT.md` were present as run-root receipts. | PASS |
| Current-run HOLD absence | `test -f LAUNCH-HOLD-RECEIPT.md` returned rc `1`. | PASS |
| L-AW cascade availability | `COMMANDER-LIVE-STATUS.md`, `secretary/STATUS-BOARD.md`, and `secretary/EVIDENCE-INDEX.md` had no `L-AW` hit and still described no iter1600 milestone yet. | P2_CONSERVATIVE_STALE |
| L-AU controlling matrix | `monitor/pre-final-proof-promotion-grill-L-AU.md` says 1800 completion proves only `formal_train_done`; candidate requires eval + RuntimeQueryGuard/W34/base-vs-LoRA + 600/1200/1800 comparison + R-L17 signoff. | PASS |
| Proof-promotion scan | Sampled shared docs continue to say no behavior pass, no candidate signoff, no C6/UIUE/voice/V-PASS, final1800 not proven, and candidate unsigned. | PASS |

## Findings

- Severity: none for live iter1600 receipt consistency.
- Severity: P2 non-blocking stale cascade: L-AW/iter1600 shared-doc cascade was not visible at sample; docs still mention "no iter1600 milestone yet". This is stale relative to live metrics, but conservative and not proof-promotion.
- No evidence that iter1600 telemetry was promoted to formal completion, checkpoint, behavior pass, candidate, C6, or V-PASS.

## Proof-Class Boundary

This audit proves only:

- runtime telemetry reached iter1600 with the exact metrics above;
- trainer/watchdog were live at the sample;
- LR receipt remained `FORMAL_450_MATCH`;
- no formal completion or current-run HOLD receipt existed at the sample;
- sampled docs did not overclaim downstream proof.

This audit does not prove:

- formal 1800 completion;
- checkpoint1600 existence;
- adapter quality or learned QA behavior;
- model behavior pass;
- candidate signoff;
- C6 comparison/acceptance;
- UIUE merge readiness;
- voice/demo readiness;
- product-level V-PASS.

## Touched Paths

Written:

- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/monitor/iter1600-receipt-consistency-audit-L-AX.md`

Read/probed:

- `/Users/wanglei/.codex/skills/smux/SKILL.md`
- `/Users/wanglei/workspace/MAformac/docs/CURRENT.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/COMMANDER-LIVE-STATUS.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/secretary/STATUS-BOARD.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/secretary/EVIDENCE-INDEX.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/monitor/pre-final-proof-promotion-grill-L-AU.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800/metrics.jsonl`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800/train.log`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800/formal-watchdog-heartbeat.jsonl`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800/LR-GATE-PASS-RECEIPT.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800/lr-schedule-verify-real-metrics.json`
- Runtime process sample via `ps -p 16315,16319,16325`.
- Receipt absence probes via `test -f FORMAL-TRAIN-RECEIPT.md` and `test -f LAUNCH-HOLD-RECEIPT.md`.

## Confidence

High for iter1600 metrics/log consistency, LR retained, live process sample, heartbeat state, and receipt absence at sample.

Medium for L-AW cascade state because shared docs can be updated by another worker after this audit; at this sample it was not visible.

## Residual Risks

- The active run can still fail before 1800 or produce a later HOLD/terminal receipt.
- No checkpoint exists at iter1600; checkpoint1800/final receipt remains pending.
- High swap/free-memory telemetry remains a runtime host risk, though not a proof of current training failure.
- Iter1600 loss telemetry does not establish behavior quality, qa safety, base-forgetting safety, candidate readiness, C6, or V-PASS.
- Shared docs may lag live training; output-file and active-run evidence remain stronger than pane prose or stale status wording.

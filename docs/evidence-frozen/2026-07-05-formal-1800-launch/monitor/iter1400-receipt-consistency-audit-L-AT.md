---
status: PASS_LIVE_ITER1400_VERIFIED__L_AS_CASCADE_PENDING__NO_OVERCLAIM
artifact_kind: iter1400_receipt_consistency_audit
created_at: 2026-07-06T06:41:00+08:00
formal_run_dir: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800
proof_class: runtime_readonly_audit
authority_class: monitor_note_not_training_receipt
---

# L-AT Iter1400 Receipt Consistency Audit

## Verdict

PASS_LIVE_ITER1400_VERIFIED__L_AS_CASCADE_PENDING__NO_OVERCLAIM.

Iter1400 telemetry is live-verified against `metrics.jsonl` and `train.log`; LR gate PASS is retained; trainer and watchdog were live at sample; `FORMAL-TRAIN-RECEIPT.md` and `LAUNCH-HOLD-RECEIPT.md` were absent. No candidate/C6/V-PASS/behavior/formal-complete overclaim was found in the sampled run-root status docs.

The very low val1400 loss is telemetry only. It is not a behavior pass, not candidate signoff, not C6/UIUE/voice/V-PASS, and not formal completion.

## Evidence Table

| Check | Evidence | Result |
| --- | --- | --- |
| Iter1400 validation metric | `metrics.jsonl:505` has `event=val`, `iteration=1400`, `val_loss=0.0008021390531212091`, `val_time=64.6022017080104`. | PASS |
| Iter1400 train report | `metrics.jsonl:508` has `train_loss=0.02105362117290497`, `learning_rate=2.931788912974298e-05`, `peak_memory=17.974245174`, `trained_tokens=60005`. | PASS |
| Train log corroboration | `train.log:166` confirms `Iter 1400: Val loss 0.001, Val took 64.602s`; `train.log:167` confirms `Train loss 0.021`, `Learning Rate 2.932e-05`, `Trained Tokens 60005`, `Peak mem 17.974 GB`. | PASS |
| Training progressed beyond 1400 | `metrics.jsonl:511-513` and `train.log:168` show iteration 1410/1412 records after iter1400. | PASS |
| Trainer live at sample | `ps -p 16315` at `2026-07-06T06:40:05+08:00` showed python leaf trainer pid `16315`, elapsed `06:57:57`, state `S`, running `c5_mlx_train_loop.py ... --iters 1800 ...`. | PASS |
| Watchdog live at sample | `ps -p 16319,16325` showed watchdog wrapper `16319` and watchdog child `16325`, child command `formal-watchdog-draft.py ... --armed`. | PASS |
| Heartbeat armed, non-shadow | `formal-watchdog-heartbeat.jsonl:1661-1670` all show `armed=true`, `shadow=false`, `pid=16315`; latest peak memory around `17.974245174`. | PASS |
| Host telemetry caveat | Latest heartbeat tail shows `memory_pressure_free_pct` about `9-12`, free/reclaimable about `2.88-3.84GB`, and swap about `4.49-4.58GB`. This is runtime telemetry, not a launch-blocking finding after run is already in progress. | OBSERVED |
| LR gate retained | `LR-GATE-PASS-RECEIPT.md` exists with `status=FIRST_REAL_LR_FORMAL_450_MATCH`, `created_at=2026-07-05T23:47:59+08:00`; `lr-schedule-verify-real-metrics.json` has `status=FORMAL_450_MATCH` and `point_count=3`. | PASS |
| No formal completion receipt yet | `test -f FORMAL-TRAIN-RECEIPT.md` returned rc `1`. | PASS |
| No hold receipt in active run | `test -f LAUNCH-HOLD-RECEIPT.md` returned rc `1`. | PASS |
| Secretary L-AS cascade | `COMMANDER-LIVE-STATUS.md`, `secretary/STATUS-BOARD.md`, `secretary/EVIDENCE-INDEX.md`, and `secretary/METACOGNITION-GRILL-REDUCTION-MATRIX.md` were sampled. L-AP/checkpoint1200 cascade is present and conservative; no L-AS/iter1400 cascade was visible at sample. | PENDING_NOT_INCONSISTENT |
| Proof-promotion scan | Sampled run-root docs repeatedly state no formal completion/candidate/C6/UIUE/voice/V-PASS/behavior claim. No iter1400 proof promotion found. | PASS |

## Findings

- Severity: none. No blocking receipt inconsistency found for iter1400.
- Observation: L-AS cascade was not visible in sampled shared status docs at audit time. This is not a contradiction because this audit is its own monitor artifact and does not require shared status edits.
- Observation: val1400 is unusually low (`0.0008021390531212091`) and therefore carries proof-promotion risk. Current docs sampled do not promote it beyond telemetry.

## Proof-Class Boundary

This audit proves only:

- runtime telemetry reached iter1400 with the exact metrics above;
- trainer/watchdog were live at the sample;
- LR receipt retained `FORMAL_450_MATCH`;
- no formal/hld terminal receipt existed in the active run at sample;
- sampled docs did not overclaim candidate/C6/V-PASS/behavior/formal completion.

This audit does not prove:

- formal 1800 completion;
- adapter quality or learned QA behavior;
- candidate signoff;
- C6 comparison/acceptance;
- UIUE merge readiness;
- voice/demo readiness;
- product-level V-PASS.

## Touched Paths

Written:

- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/monitor/iter1400-receipt-consistency-audit-L-AT.md`

Read/probed:

- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/COMMANDER-LIVE-STATUS.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/secretary/STATUS-BOARD.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/secretary/EVIDENCE-INDEX.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/secretary/METACOGNITION-GRILL-REDUCTION-MATRIX.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800/metrics.jsonl`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800/train.log`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800/formal-watchdog-heartbeat.jsonl`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800/LR-GATE-PASS-RECEIPT.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800/lr-schedule-verify-real-metrics.json`
- Runtime process sample via `ps -p 16315,16319,16325`.
- Receipt absence probes via `test -f FORMAL-TRAIN-RECEIPT.md` and `test -f LAUNCH-HOLD-RECEIPT.md`.

## Confidence

High for iter1400 metrics/log consistency, LR retained, live process sample, heartbeat state, and receipt absence at sample.

Medium for L-AS cascade state because shared status docs were sampled once and may be updated by another worker after this audit.

## Residual Risks

- The active run can still fail before 1800 or produce a later HOLD/terminal receipt.
- High swap/free-memory telemetry remains a runtime host risk, even though it is not itself a proof of training failure.
- Loss telemetry does not establish behavior quality; behavior gates and candidate signoff remain unsigned.
- Shared secretary docs may lag live training progress; output-file truth remains stronger than pane/ACK prose.

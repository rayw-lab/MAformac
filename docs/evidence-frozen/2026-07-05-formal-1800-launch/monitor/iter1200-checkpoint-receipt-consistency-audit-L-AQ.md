---
status: PASS_LIVE_ITER1200_CHECKPOINT_VERIFIED__STATUS_DOCS_STALE_PENDING_CASCADE__NO_OVERCLAIM
artifact_kind: iter1200_checkpoint_receipt_consistency_audit
created_at: 2026-07-06T05:40:00+08:00
formal_run_dir: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800
proof_class: runtime_readonly_audit
authority_class: monitor_note_not_training_receipt
---

# L-AQ Iter1200 Checkpoint Receipt Consistency Audit

## Verdict

`PASS_LIVE_ITER1200_CHECKPOINT_VERIFIED__STATUS_DOCS_STALE_PENDING_CASCADE__NO_OVERCLAIM`

Live files verify the iter1200 validation/train/checkpoint milestone:

- `metrics.jsonl:433` records val iteration `1200`, `val_loss=0.022533632814884186`, `val_time=60.57943300000625`.
- `metrics.jsonl:436` records train iteration `1200`, `train_loss=0.020123106241226197`, learning_rate `4.350494418758899e-05`, peak_memory `17.974245174`, trained_tokens `51360`.
- `train.log:143-145` confirms iter1200 val/train and saved adapter weights to `adapters.safetensors` and `0001200_adapters.safetensors`.
- `adapters-rank16/adapters.safetensors` and `adapters-rank16/0001200_adapters.safetensors` both exist, each `69772950` bytes, mtime `Jul 6 05:36:13 2026`.
- Trainer pid `16315` and watchdog pids `16319/16325` were live at the L-AQ sample `2026-07-06T05:39:10+08:00`.
- LR receipt and verifier retain `FORMAL_450_MATCH`.
- No current-run `FORMAL-TRAIN-RECEIPT.md` or `LAUNCH-HOLD-RECEIPT.md` exists.
- No candidate/C6/V-PASS/behavior/formal-complete overclaim was found.

Run-root status docs had not yet cascaded the iter1200/checkpoint1200 milestone at the L-AQ sample. Several status files still say checkpoint1200 is not observed/proven; those lines are now stale relative to live files and need a secretary/status cascade if commander wants run-root memory to match live evidence.

## Evidence Table

| Check | Live evidence | Reading |
|---|---|---|
| Status docs cascade | `COMMANDER-LIVE-STATUS.md:41,72,134-136`, `secretary/STATUS-BOARD.md:34,68,108-110`, `secretary/EVIDENCE-INDEX.md:35,74`, and matrix line `53` still record through iter1000 or say checkpoint1200/final1800 not proven. | Status docs are stale/pending cascade for checkpoint1200. |
| Iter1200 val exact value | `metrics.jsonl:433` is `{"event":"val","iteration":1200,"val_loss":0.022533632814884186,"val_time":60.57943300000625}`. | Exact required value matches. |
| Iter1200 train report | `metrics.jsonl:436` records `train_loss=0.020123106241226197`, learning_rate `4.350494418758899e-05`, peak_memory `17.974245174`, trained_tokens `51360`. | Exact required values match. |
| Train log confirmation | `train.log:143` says `Iter 1200: Val loss 0.023, Val took 60.579s`; `train.log:144` says `Iter 1200: Train loss 0.020 ... Peak mem 17.974 GB`; `train.log:145` records saved adapter weights to both checkpoint paths. | Confirms metrics and checkpoint save in log. |
| Checkpoint1200 files | `adapters-rank16/adapters.safetensors` and `adapters-rank16/0001200_adapters.safetensors` exist, each `69772950` bytes; `ls -lhT` displays both as `67M`, mtime `Jul 6 05:36:13 2026`. | Checkpoint1200 saved. |
| Previous checkpoint retained | `adapters-rank16/0000600_adapters.safetensors` still exists, size `69772950`, mtime `Jul 6 02:40:07 2026`. | Recovery checkpoint history retained. |
| Current progress beyond iter1200 | `metrics.jsonl:437-439` and `train.log:146` show progress beyond iter1200. | Iter1200 is a true milestone snapshot, not current tail. |
| Trainer/watchdog live sample | `ps -p 16315,16319,16325` at `2026-07-06T05:39:10+08:00` showed trainer pid `16315`, watchdog wrapper `16319`, watchdog child `16325`. | Live at sample. |
| Watchdog heartbeat | `formal-watchdog-heartbeat.jsonl:1420-1427` shows `armed=true`, `shadow=false`, `pid=16315`, free pct `8-14`, free GB `2.56-4.48`, swap about `5.12-5.32GiB`, latest peak `17.974245174GB`. | Watchdog live; swap remains high; peak remains below `22.34GB`. |
| LR retained | `LR-GATE-PASS-RECEIPT.md` status is `FIRST_REAL_LR_FORMAL_450_MATCH`; `lr-schedule-verify-real-metrics.json:104` status is `FORMAL_450_MATCH`, `point_count=3`. | LR gate PASS retained. |
| FORMAL/HOLD absence | `test -f FORMAL-TRAIN-RECEIPT.md` returned rc `1`; `test -f LAUNCH-HOLD-RECEIPT.md` returned rc `1`; no current-run paths were printed for those receipt names. | Formal completion not proven; no current HOLD receipt. |
| No proof-class overclaim | Claim scan found only negative/non-claim statements for behavior, candidate, C6, V-PASS, formal completion, and `adapter_learned_qa=true`. | No overclaim found. |

## Findings

### P2: Status docs stale on checkpoint1200

Live files prove checkpoint1200 exists, but run-root status docs still contain stale statements that checkpoint1200 is not observed/proven. This is a documentation cascade gap, not a training or checkpoint failure.

Examples:

- `secretary/EVIDENCE-INDEX.md:35` says `checkpoint1200 | false / not observed yet`.
- `secretary/EVIDENCE-INDEX.md:74` says checkpoint1200 and final1800 are not yet proven.
- `COMMANDER-LIVE-STATUS.md:136` and `secretary/STATUS-BOARD.md:110` still list checkpoint1200 as not proven.
- `secretary/METACOGNITION-GRILL-REDUCTION-MATRIX.md:53` says no checkpoint1200/final1800 evidence observed in the matrix.

Audit reading: update/cascade should reclassify checkpoint1200 as saved while preserving that final1800, formal completion, candidate, C6/UIUE/voice/V-PASS, and behavior gates remain unproven.

## Proof-Class Boundary

Allowed from this audit:

- iter1200 validation window passed in live metrics/log;
- iter1200 train report observed;
- checkpoint1200 saved;
- trainer/watchdog live at L-AQ sample;
- LR `FORMAL_450_MATCH` retained;
- formal run still in progress at sample, not completed.

Not allowed from this audit:

- formal training completed;
- behavior pass;
- candidate signoff;
- C6/UIUE/voice/V-PASS;
- `adapter_learned_qa=true`;
- final1800 success.

## Touched Paths

Wrote:

- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/monitor/iter1200-checkpoint-receipt-consistency-audit-L-AQ.md`

Read:

- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/COMMANDER-LIVE-STATUS.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/secretary/STATUS-BOARD.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/secretary/EVIDENCE-INDEX.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/secretary/METACOGNITION-GRILL-REDUCTION-MATRIX.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800/metrics.jsonl`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800/train.log`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800/formal-watchdog-heartbeat.jsonl`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800/LR-GATE-PASS-RECEIPT.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800/lr-schedule-verify-real-metrics.json`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800/adapters-rank16/`

Runtime probes:

- `ps -p 16315,16319,16325 -o ...`
- `test -f FORMAL-TRAIN-RECEIPT.md`
- `test -f LAUNCH-HOLD-RECEIPT.md`

No repo source, shared status files, trainer, watchdog, model, adapter, or command candidate was modified.

## Residual Risk

- This is a live sample at `2026-07-06T05:39:10+08:00`; the run can still fail later.
- Swap remains high in heartbeat samples, though no watchdog hard kill was observed in this audit.
- Checkpoint1200 is saved, but final1800 is not yet proven.
- Iter1200 loss/telemetry and checkpoint files are not behavior evidence and do not sign a candidate.
- Run-root status docs need a separate cascade if commander wants checkpoint1200 reflected there.
- The audit did not evaluate model behavior, candidate quality, C6 comparison, UIUE merge readiness, or voice/demo readiness.

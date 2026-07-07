---
status: PASS_WITH_MINOR_STALE_WORDING_FINDINGS
artifact_kind: checkpoint600_receipt_consistency_audit
created_at: 2026-07-06T02:53:00+08:00
formal_run_dir: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800
proof_class: runtime_readonly_audit
authority_class: monitor_note_not_training_receipt
---

# L-AJ Checkpoint600 Receipt Consistency Audit

## Verdict

`PASS_WITH_MINOR_STALE_WORDING_FINDINGS`

L-AG and L-AH checkpoint600 claims are consistent with live files:

- `metrics.jsonl:217` records iter-600 validation with `val_loss=0.08106060326099396`.
- `train.log:76-78` confirms iter-600 val/train and saved adapter weights.
- `adapters-rank16/adapters.safetensors` and `adapters-rank16/0000600_adapters.safetensors` exist, each `69772950` bytes / displayed as `67M`, mtime `Jul 6 02:40:07 2026`.
- Trainer pid `16315` and watchdog pids `16319/16325` were live at the L-AJ sample `2026-07-06T02:52:29+08:00`.
- LR proof remains `FORMAL_450_MATCH`.
- No current-run `FORMAL-TRAIN-RECEIPT.md` or `LAUNCH-HOLD-RECEIPT.md` exists.
- No candidate/C6/V-PASS/behavior-gate overclaim was found in the audited files.

Minor consistency finding: some status/index text still phrases the old `iter<600 no checkpoint` risk as live/retained, even though nearby later text correctly says checkpoint600 exists and the prior iter<600 risk is resolved from this point forward.

## Evidence Table

| Check | Live evidence | Reading |
|---|---|---|
| L-AG status claim | `COMMANDER-LIVE-STATUS.md:37` claims iter-600 val pass, checkpoint files, heartbeat, live pids, and FORMAL/HOLD absence. | Confirmed by live files below. |
| L-AH status claim | `watchdog/live-host-watchdog-monitor-L-AH.md:17,23-35` claims iter-600 val pass, checkpoint saved, trainer/watchdog live, LR retained, no FORMAL/HOLD receipt. | Confirmed; L-AH was a 02:47 sample, while L-AJ sampled later at 02:52. |
| Secretary status | `secretary/STATUS-BOARD.md:30,52-57` records iter-600 val, checkpoint600, watchdog state, no completion, no hold. | Consistent with live files. |
| Evidence index | `secretary/EVIDENCE-INDEX.md:30-35,76-80` records iter-600 pass, checkpoint600 saved, candidate/C6/V-PASS false, current receipts false for FORMAL/HOLD. | Consistent with live files. |
| Iter-600 val exact value | `metrics.jsonl:217` is `{"event":"val","iteration":600,"val_loss":0.08106060326099396,"val_time":62.59783783300372}`. | Exact required value matches. |
| Iter-600 train/log confirmation | `train.log:76` says `Iter 600: Val loss 0.081, Val took 62.598s`; `train.log:78` records saved adapter weights to both checkpoint paths. | Confirms human-readable training log. |
| Checkpoint600 files | `adapters-rank16/adapters.safetensors` and `adapters-rank16/0000600_adapters.safetensors` both exist, size `69772950`, mtime `Jul 6 02:40:07 2026`; `ls -lhT` displays both as `67M`. | L-AG/L-AH checkpoint file claim verified. |
| Continued progress beyond L-AG | `metrics.jsonl:226-227` matches L-AG's iter-620 claim; L-AJ tail also saw progress through iteration `644`, update_step `161`, and train report at iteration `640`. | L-AG progress sample is stale but true; run continued beyond it. |
| Trainer/watchdog live sample | `ps -p 16315,16319,16325` at `2026-07-06T02:52:29+08:00` showed trainer pid `16315`, watchdog wrapper `16319`, watchdog child `16325`, all state `S`. | Live at sample. |
| Watchdog heartbeat | heartbeat tail at L-AJ sample showed `armed=true`, `shadow=false`, `pid=16315`, `latest_peak_memory_gb=17.974159996`, free pct `10.0`, free GB `3.2`, swap `4.80029296875GiB`. | Watchdog remains armed; swap remains high but no hard kill seen. |
| LR retained | `LR-GATE-PASS-RECEIPT.md` status is `FIRST_REAL_LR_FORMAL_450_MATCH`; `lr-schedule-verify-real-metrics.json:104` status is `FORMAL_450_MATCH`, `point_count=3`. | LR gate PASS retained. |
| FORMAL/HOLD absence | `test -f FORMAL-TRAIN-RECEIPT.md` returned rc `1`; `test -f LAUNCH-HOLD-RECEIPT.md` returned rc `1`; `find` for those names in current run printed no paths. | Formal completion not proven; no current HOLD receipt. |
| No overclaim | Claim scan found only negative/non-claim statements: `candidate signed false`, `C6/UIUE/voice/V-PASS false`, `not behavior pass`, `not formal completed`, `adapter_learned_qa=false` or not true. | Proof-class ceiling preserved. |

## Findings

### P2: Stale iter<600 risk wording still appears in status/index text

The hard evidence is fine, but some live status files still retain old wording as if the pre-checkpoint risk were current:

- `COMMANDER-LIVE-STATUS.md:50` says L-X live risk warns `iter<600 has no checkpoint`; `COMMANDER-LIVE-STATUS.md:113` says the same risk remains live.
- `secretary/STATUS-BOARD.md:44` and `secretary/STATUS-BOARD.md:89` say `iter<600 has no saved adapter checkpoint` / risk remains.
- `secretary/EVIDENCE-INDEX.md:49` and `secretary/EVIDENCE-INDEX.md:67` retain the same risk wording.

Nearby corrections exist:

- `COMMANDER-LIVE-STATUS.md:117-118` says iter-600 passed and the prior iter<600 risk is resolved from this point forward.
- `secretary/STATUS-BOARD.md:93-94` says checkpoint600 exists and prior iter<600 risk is resolved.
- `secretary/EVIDENCE-INDEX.md:92-93` says iter-600 passed and first checkpoint saved.

Audit reading: this is a wording consistency issue, not a launch/training blocker. The old risk should be treated as historical or superseded for the specific "no checkpoint before iter600" claim. Future checkpoint-gap risk may still exist until checkpoint1200, but it should be worded differently.

## Proof-Class Boundary

Allowed from this audit:

- checkpoint600 saved;
- iter-600 validation observed;
- trainer/watchdog live at L-AJ sample;
- LR `FORMAL_450_MATCH` retained;
- formal run still in progress at sample, not completed.

Not allowed from this audit:

- formal training completed;
- behavior pass;
- candidate signoff;
- C6/UIUE/voice/V-PASS;
- `adapter_learned_qa=true`;
- future checkpoint or final 1800 success.

## Touched Paths

Wrote:

- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/monitor/checkpoint600-receipt-consistency-audit-L-AJ.md`

Read:

- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/COMMANDER-LIVE-STATUS.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/secretary/STATUS-BOARD.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/secretary/EVIDENCE-INDEX.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/watchdog/live-host-watchdog-monitor-L-AH.md`
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

- This is a live sample at `2026-07-06T02:52:29+08:00`; the run can still fail later.
- Swap remains high in heartbeat samples, though not a hard kill under the current watchdog thresholds.
- Checkpoint1200 and final 1800 are not yet proven by this audit.
- The audit did not evaluate model behavior, candidate quality, C6 comparison, UIUE merge readiness, or voice/demo readiness.

---
status: PARTIAL_HOLD_TRUTH_VERIFIED__P1_ADAPTER_SHA_BASIS_FIELD_MISLEADING__NO_PROOF_PROMOTION
artifact_kind: final_hold_receipt_consistency_audit
created_at: 2026-07-06T08:37:00+08:00
run_root: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch
formal_run_dir: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800
proof_class: runtime_readonly_audit
authority_class: monitor_note_not_training_receipt_not_candidate_receipt
---

# L-AZ Final HOLD Receipt Consistency Audit

## Verdict

`PARTIAL_HOLD_TRUTH_VERIFIED__P1_ADAPTER_SHA_BASIS_FIELD_MISLEADING__NO_PROOF_PROMOTION`.

The final receipt truth is HOLD, not completion: `FORMAL-TRAIN-RECEIPT.md` has `status=FORMAL_TRAIN_HOLD_TRAINER_RC_143` and `trainer_rc=143`. `FORMAL_WATCHDOG_STOP.md/json` has `status=FORMAL_WATCHDOG_PARTIAL_STOP`, reason `train_report_freshness_cap_missed`, and `kill_actions=["SIGTERM"]`. Training stopped before 1800: metrics end at optimizer update `iteration=1692`, `update_step=423`, and `train.log` ends after iter1690 plus a Python `resource_tracker` warning.

P1 finding: `adapter_sha_basis=3f90a5cd...` is not an adapter file sha. It is the sha256 of `adapter-file-shas.txt`. The actual saved adapter files are `40348545...` for checkpoint600 and `f594e5e50...` for checkpoint1200 plus rolling `adapters.safetensors`. This does not invalidate the HOLD status, but it blocks any downstream adapter-basis/candidate consumption until the receipt is clarified or amended.

## Evidence Table

| Check | Evidence | Result |
| --- | --- | --- |
| Final receipt status | `FORMAL-TRAIN-RECEIPT.md:2` has `status: FORMAL_TRAIN_HOLD_TRAINER_RC_143`; line 5 has `trainer_rc: 143`. | PASS_HOLD_NOT_COMPLETION |
| Non-claims in final receipt | `FORMAL-TRAIN-RECEIPT.md:8-9` has `candidate_status: unsigned`, `adapter_learned_qa: false`; lines 37-40 say unsigned, no adapter learned qa, no C6/UIUE/voice/V-PASS, no behavior pass unless separately evaluated. | PASS |
| Watchdog stop receipt | `FORMAL_WATCHDOG_STOP.md:1-2` and `FORMAL_WATCHDOG_STOP.json:32-33` show `FORMAL_WATCHDOG_PARTIAL_STOP`, reason `train_report_freshness_cap_missed`. | PASS |
| Watchdog kill action | `FORMAL_WATCHDOG_STOP.md` and `.json` contain `kill_actions: ["SIGTERM"]`. | PASS |
| Stop reason telemetry | Watchdog stop evidence has `last_optimizer_update_record_index=612`, `last_train_report_record_index=611`, `metrics_record_count=612`, `last_train_report_age_s=1051.6596491336823`, `optimizer_fresh=false`, and `no_progress_evidence=true`. | PASS |
| Metrics terminal point | `metrics.jsonl` has 612 lines; final line is optimizer update `iteration=1692`, `update_step=423`, `learning_rate=1.4692969671159517e-05`, `loss=0.0`. | PASS |
| No 1800 metric/log | Search for `iteration=1800` / `Iter 1800` found no completion point; `train.log:9` only records requested `iters: 1800`. | PASS_HOLD |
| Train log terminal point | `train.log` ends after `Iter 1690: Train loss 0.020...` followed by `resource_tracker: There appear to be 1 leaked semaphore objects...`. | PASS |
| No live trainer/watchdog | At `2026-07-06T08:34:51+08:00`, pids `16315`, `16319`, and `16325` were absent; process pattern scan for trainer/watchdog/MLX returned no match. | PASS |
| LR retained | `LR-GATE-PASS-RECEIPT.md:2` has `FIRST_REAL_LR_FORMAL_450_MATCH`; `lr-schedule-verify-real-metrics.json:104` has `FORMAL_450_MATCH`; `point_count=3`. | PASS |
| Trainpack sha | `trainpack-sha-check.txt` says `c5-training-samples.jsonl: OK`; `trainpack-sha-check.input` records `fa5690400f67db9ef237dabdb489f58d1ab69961f14d6733d79f9bd7cad33823`. | PASS |
| Trainpack rows | `trainpack-row-count.txt` records `5653` rows for `c5-training-samples.jsonl`. | PASS |
| Adapter file shas | `adapter-file-shas.txt` and direct `shasum -a 256` agree: `0000600_adapters.safetensors=40348545...`; `0001200_adapters.safetensors=f594e5e50...`; rolling `adapters.safetensors=f594e5e50...`. | PASS |
| Adapter sha basis field | `FORMAL-TRAIN-RECEIPT.md:7` says `adapter_sha_basis=3f90a5cd...`; direct `shasum -a 256 adapter-file-shas.txt` returns that same `3f90a5cd...`. | P1_MISLEADING_FIELD |
| Shared docs overclaim scan | Sampled `COMMANDER-LIVE-STATUS.md`, `secretary/STATUS-BOARD.md`, and `secretary/EVIDENCE-INDEX.md` still had stale pre-final wording, but retained non-claims: not behavior, not candidate, not C6/UIUE/voice/V-PASS. | PASS_NO_OVERCLAIM_WITH_STALE_STATUS |
| Historical final-hold file naming | `secretary/status-cascade-final-hold-update.md` and `watchdog/post-hold-process-residue-audit.md` refer to older `formal-run-20260705T232357+0800`, not the current `formal-run-20260705T234208+0800`. | P2_HISTORICAL_DO_NOT_CONSUME_AS_CURRENT |

## Findings

### P1: `adapter_sha_basis` is a manifest-file sha, not adapter file sha

`FORMAL-TRAIN-RECEIPT.md` presents `adapter_sha_basis=3f90a5cd...` and points to `adapter-file-shas.txt` as evidence. Direct hashing confirms `3f90a5cd...` is the sha256 of `adapter-file-shas.txt` itself.

Actual adapter file shas are:

- `0000600_adapters.safetensors`: `40348545f68d352228bbc98b88f964a10f1d39fb39c43a0df50df7e654e0b511`
- `0001200_adapters.safetensors`: `f594e5e50c328119ab071800020474f144bfe133be68b24efe918ae5e6dee753`
- rolling `adapters.safetensors`: `f594e5e50c328119ab071800020474f144bfe133be68b24efe918ae5e6dee753`

Impact: this does not change the HOLD truth, because the run did not complete and candidate remains unsigned. It does block any downstream use of `adapter_sha_basis` as if it identified the adapter bytes. Recommended future correction is to separate fields:

- `adapter_sha_manifest=3f90a5cd...`
- `adapter_0000600_sha=40348545...`
- `adapter_0001200_sha=f594e5e50...`
- `adapter_rolling_sha=f594e5e50...`

### P2: Shared status docs lag the final HOLD

At sample, `COMMANDER-LIVE-STATUS.md`, `secretary/STATUS-BOARD.md`, and `secretary/EVIDENCE-INDEX.md` still described the run as pre-final or final not yet observed. This is stale after `FORMAL-TRAIN-RECEIPT.md` exists. It is conservative stale state, not proof-promotion, because the docs still prohibit candidate/C6/V-PASS/behavior claims.

### P2: Historical final-hold receipts can be confused with the active run

`secretary/status-cascade-final-hold-update.md` and `watchdog/post-hold-process-residue-audit.md` are named like current final-hold artifacts but are for stale run `formal-run-20260705T232357+0800` and rc65 LR timing history. They must not be consumed as the current `234208+0800` final HOLD truth.

## Proof-Class Boundary

This audit proves:

- current active formal run ended in HOLD/partial stop, not 1800 completion;
- trainer exit code was `143`;
- watchdog killed with SIGTERM after `train_report_freshness_cap_missed`;
- metrics ended at `iteration=1692`, `update_step=423`;
- no trainer/watchdog/MLX process remained at the process sample;
- LR gate remained `FORMAL_450_MATCH`;
- trainpack sha and row checks pass;
- saved adapter files are checkpoint600 and checkpoint1200/rolling only, with shas listed above;
- sampled docs did not promote the run to candidate/C6/V-PASS/behavior.

This audit does not prove:

- formal 1800 completion;
- checkpoint1800 existence;
- model behavior pass;
- adapter learned qa;
- candidate signoff;
- C6 comparison/acceptance;
- UIUE merge readiness;
- voice/demo readiness;
- product-level V-PASS.

## Touched Paths

Written:

- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/monitor/final-hold-receipt-consistency-audit-L-AZ.md`

Read/probed:

- `/Users/wanglei/.codex/skills/smux/SKILL.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/COMMANDER-LIVE-STATUS.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/secretary/STATUS-BOARD.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/secretary/EVIDENCE-INDEX.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/secretary/status-cascade-final-hold-update.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/watchdog/post-hold-process-residue-audit.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800/FORMAL-TRAIN-RECEIPT.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800/FORMAL_WATCHDOG_STOP.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800/FORMAL_WATCHDOG_STOP.json`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800/metrics.jsonl`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800/train.log`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800/adapter-file-shas.txt`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800/trainpack-sha-check.txt`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800/trainpack-row-count.txt`
- Runtime process samples via `ps`, `pgrep`, and `shasum -a 256`.

## Confidence

High for HOLD status, rc143, watchdog stop reason, no-1800 metrics/log endpoint, process absence, LR retained, trainpack sha/rows, and adapter file shas.

High that `3f90a5cd...` is the sha256 of `adapter-file-shas.txt`.

Medium for sampled shared-doc state because another secretary cascade may update after this audit.

## Residual Risks

- Existing shared status docs may remain stale until explicitly updated to the current rc143 HOLD.
- The receipt field `adapter_sha_basis` may be misread by downstream workers unless amended or accompanied by this audit.
- The run stopped at 1692, so there is no checkpoint1800 and no formal completion evidence.
- No behavior/C6/candidate evaluation was run; candidate remains unsigned.

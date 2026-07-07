# C5 PR2/PR4/PR5 Superdispatch Closeout Handoff

> ⚠️ **HISTORICAL 快照（T5）—— 文档级联 banner（2026-07-07 B4b）**
> 本文是 `docs/grill-tournament/cascade-inventory.md §T5` 标记的历史快照，当前仅保留溯源/交接价值；supersede 指针以 `docs/grill-tournament/cascade-inventory.md` 的 T5 账本为准。
> **活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md` + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` + `docs/grill-tournament/cascade-inventory.md`。正文保留供溯源，勿据此推进。

Date: 2026-06-22

Full closeout: `Reports/c5-pr2pr4pr5-20260621T235213/final-closeout.md`

Audit index: `Reports/c5-pr2pr4pr5-20260621T235213/audits/INDEX.md`

Final verdict: `PASS_FOR_BLOCKED_CLOSEOUT`

Candidate signing verdict: `UNSIGNED / BLOCKED`

## Summary

PR2 and PR4 are complete. PR5 produced a train-health-pass LoRA adapter and loaded it through SpikeE3 with eval-time adapter-config normalization, but C6 hard-failed. The candidate must not be signed.

Primary blocker:
- LoRA positive expected tool hits: `0/34`
- Training target outer tool: `tool_call_frame`
- LoRA observed tool: `tool_call`
- C6 expected tools: `set_cabin_*` / `query_cabin_comfort`

The current closeout is intentionally blocked/partial:
- Task 3.3 remains open because semantic near-neighbor proof is incomplete.
- Task 4.1 remains open-blocked because dynamic/fused/quantized parity was not run after C6 failed.
- Task 4.2 remains open-blocked because endpoint byte parity was not run after C6 failed and no target physical iOS device receipt exists.
- Task 4.3 is checked only because two-layer V-PASS status was recorded as blocked.

GPT Pro final audit:
- `Reports/c5-pr2pr4pr5-20260621T235213/audits/gptpro-final-audit.md`
- Verdict: `PASS_FOR_BLOCKED_CLOSEOUT`
- Candidate verdict: `UNSIGNED / BLOCKED`

## Next Required Gates

1. Fix the training/eval/runtime tool-surface mismatch or introduce a scored bridge.
2. Retrain/rerun the candidate path.
3. Rerun same-harness C6.
4. Complete semantic near-neighbor proof.
5. Run dynamic/fused/quantized parity only after C6 passes.
6. Run endpoint byte parity on a target physical iOS device only after model-quality gates pass.
7. Run a fresh heterogeneous final audit before any future candidate signing.

# C5 PR2/PR4/PR5 Superdispatch Closeout

Date: 2026-06-22

Run root: `Reports/c5-pr2pr4pr5-20260621T235213`

Final verdict: `PASS_FOR_BLOCKED_CLOSEOUT`

Candidate signing verdict: `UNSIGNED / BLOCKED`

## Executive Result

PR2 and PR4 are complete. PR5 produced a train-health-pass LoRA adapter, loaded it in the SpikeE3 MLX Swift harness after adapter-config normalization, and ran same-harness base-vs-LoRA C6 evaluation. The candidate is not signed because C6 hard-failed: LoRA collapsed positive action tool exactness to `0/34` and emitted `tool_call` while C6 expects cabin tools (`set_cabin_*` / `query_cabin_comfort`).

This is an honest blocked/partial closeout, not a model-quality or endpoint-ready candidate.

## PR2 Result

Status: complete.

Evidence:
- Clip-enabled repo-loop run: `pr2-2a-clip-enabled/evidence-summary.md`
- Stock equivalence run: `pr2-2b-equivalence/evidence-summary.md`
- Source-state gate evidence: `pr2-2c-source-state/evidence-summary.md`
- Verified training loop source: `Tools/C5TrainingCLI/c5_mlx_train_loop.py`
- Verification marker: `Tools/C5TrainingCLI/c5_mlx_train_loop.verification.json`

Key result:
- Repo-loop clip was exercised in a real run.
- Stock parity was proven for clip-off equivalence.
- Formal training now records and gates on verified training-loop source state.

## PR4 Result

Status: complete.

Evidence:
- PR4 closeout: `pr4-closeout/c5-remediation-closeout.md`
- Archive path: `openspec/changes/archive/2026-06-21-define-lora-training`
- Active method spec: `openspec/specs/lora-training/spec.md`

Key result:
- `define-lora-training` was tombstoned/archive-ready and archived.
- Active `lora-training` spec was repaired after archive so it does not retain placeholder Purpose text.

## PR5 Result

Status: blocked/partial closeout accepted; candidate unsigned.

Training:
- Clean prepare receipt: `pr5-5b-candidate-prepare-clean/c5-training-receipt.json`
- Training run receipt: `pr5-5b-candidate-training/c5-training-run-receipt.json`
- Training status: `train_health_pass`
- Scale: `20`
- Rank: `16`
- Final adapter sha256: `a8b5a50ca08bd3f96b37411f40718568625606985935d09d18eedd88e45b86fc`
- Training-health limitation: this does not imply model-quality V-PASS.

C6:
- C6 receipt: `pr5-5c-c6-eval/c6-eval-receipt.json`
- C6 verdict: `C6_HARD_FAIL_BLOCKED`
- Candidate signing status: `not_signed_c6_hard_fail_tool_surface_mismatch`
- LoRA positive expected tool hits: `0/34`
- LoRA observed tool names: `tool_call`
- Training outer tool names: `tool_call_frame`
- C6 expected tool names: `query_cabin_comfort`, `set_cabin_ac`, `set_cabin_ambient_light`, `set_cabin_fan`, `set_cabin_screen_brightness`, `set_cabin_window`

Diagnostics:
- Exact input overlap and lineage overlap were recorded.
- Semantic near-neighbor proof is still incomplete.
- Task 3.3 remains open-blocked.

Parity/V-PASS:
- 5d receipt: `pr5-5d-parity-vpass/parity-vpass-receipt.json`
- Dynamic/fused/quantized parity: `blocked_not_run`
- Endpoint tokenizer byte parity: `blocked_not_run`
- Model-quality V-PASS: `blocked`
- Physical endpoint V-PASS: `blocked`
- Device probe found no target physical iOS device; simulator evidence is insufficient.

## Audit Chain

Index: `audits/INDEX.md`

Codex subagent audits:
- PR2: 2a, 2b, 2c passed with notes.
- PR4: truth table, tombstones, archive passed with notes.
- PR5 5a passed with notes.
- PR5 5b r1 failed, r2 passed with notes after method-contract authority fixes.
- PR5 5c r1 passed with notes but caught 3.3 over-check and missing normalization byte fingerprints; r2 passed after fixes.
- PR5 5d passed; 4.1/4.2 correctly remain open-blocked and 4.3 correctly records blocked V-PASS split.

GPT Pro final audit:
- Report: `audits/gptpro-final-audit.md`
- Verdict: `PASS_FOR_BLOCKED_CLOSEOUT`
- Candidate verdict: `UNSIGNED / BLOCKED`
- It explicitly rejects candidate signing until C6, near-neighbor, parity, endpoint byte parity, physical endpoint, and fresh final-audit gates all pass.

## Verification

Latest local verification:
- `openspec validate run-lora-candidate-training --strict`: pass
- `openspec validate --all --strict`: 9 passed, 0 failed
- `git diff --check`: pass
- `swift build --product spike-e3 -c release` from `dev/spike-e3`: pass
- `swift test`: 112 passed, 3 skipped, 0 failures

## Git And Redline Hygiene

Do not stage or commit:
- `*.safetensors`
- `Reports/**/mlx-data/*.jsonl`
- `Reports/**/samples/*.jsonl`
- tokenizer/model artifact directories
- raw external dispatch/research source files

Committed evidence should be limited to source changes, OpenSpec contract/archive files, training-loop source/verification marker, text receipts, audit reports, summaries, and closeout files.

## Required Next Gates

1. Reconcile training target tool surface with runtime/C6 expected cabin tool surface, or introduce a scored bridge.
2. Retrain or rerun the candidate path after the tool-surface fix.
3. Rerun C6 base-vs-LoRA under the same harness.
4. Complete semantic near-neighbor proof before claiming heldout/OOD generalization.
5. Run dynamic adapter vs fused bf16 vs fused quantized/endpoint parity only after C6 passes.
6. Run endpoint tokenizer byte parity on a target physical iOS device only after model-quality gates pass.
7. Run a fresh heterogeneous GPT Pro final audit before any future candidate signing.

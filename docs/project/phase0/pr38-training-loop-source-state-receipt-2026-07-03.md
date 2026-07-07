---
artifact_kind: local_verification_receipt
authority: local_receipt_not_ssot
status: pass_pr38_training_loop_source_marker_refreshed
proof_class: local_unit_formal_prepare_probe
created_at: 2026-07-03 15:02:21 CST
pr: 38
branch: codex/t1d-repoize-d2combo-20260703
head_under_test: 2f71a4ad5506c8223df42fb7f660f44cc5364e2e
review_source: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/REVIEW-PR38.md
retire_trigger: "Retire when superseded by archived OpenSpec specs or explicit user decision."
expires: "2026-08-15"
---

# PR38 Training Loop Source-State Receipt

## Verdict

PASS for the PR38 marker-refresh scope. `Tools/C5TrainingCLI/c5_mlx_train_loop.verification.json` now binds to the PR38 training loop sha and the real `C5TrainingCLI prepare` path reads the loop source as `verified/pass`.

This is not a train-ready, candidate-acceptance, C6 acceptance, or V-PASS claim. It only closes PR38 review P1: stale source marker after modifying `Tools/C5TrainingCLI/c5_mlx_train_loop.py`.

## Source-State Contract

Formal prep is fail-closed by design:

- `Tools/C5TrainingCLI/main.swift:375-391` hashes `Tools/C5TrainingCLI/c5_mlx_train_loop.py`, returns `tracked_unverified` on missing marker, sha mismatch, or non-`verified/pass`, and returns `verified` only when the marker sha matches the actual file.
- `Core/Training/C5LoRATraining.swift:673-675` defines formal verification as `trainingLoopSourceState == "verified" && trainingLoopVerificationStatus == "pass" && !trainingLoopSourceSHA256.isEmpty`.
- `Core/Training/C5LoRATraining.swift:2974-2976` appends `training_loop_source_unverified` for non-smoke stages when that formal verification is absent.

## Marker Refresh

The marker was regenerated mechanically from the current PR38 file bytes; the sha was not hand typed into the JSON.

```text
9714f6f2700a4c0f77be6bfdc005d291a894e858606a87a1a3838fd9a8f71748  Tools/C5TrainingCLI/c5_mlx_train_loop.py
d9ba51d8ed4b07d7d2672293dda3a7c8995e3f1bcec8388b86930f3cb25090b4  Tools/C5TrainingCLI/c5_mlx_train_loop.verification.json
```

Marker fields after refresh:

```text
source_state=verified
script_sha256=9714f6f2700a4c0f77be6bfdc005d291a894e858606a87a1a3838fd9a8f71748
verification_status=pass
verification_ref=docs/project/phase0/pr38-training-loop-source-state-receipt-2026-07-03.md
verified_at=2026-07-03T15:00:15+08:00
```

Historical note: the prior marker was bound to `5400641044144746f8d4ddc424b8b49f66e650e6511d94843ccd64f12895e0f7` and the 2026-06-22 PR2 evidence chain. That proof is historical for the old loop source and is not used as the live marker reference for PR38.

## Validation Commands

Python source checks:

```bash
/opt/homebrew/opt/python@3.13/bin/python3.13 -m py_compile Tools/C5TrainingCLI/c5_mlx_train_loop.py
/opt/homebrew/opt/python@3.13/bin/python3.13 Tools/C5TrainingCLI/c5_mlx_train_loop.py --self-test-token-budget-batches
/opt/homebrew/opt/python@3.13/bin/python3.13 Tools/C5TrainingCLI/c5_mlx_train_loop.py --self-test-loss-mask
```

Observed:

```text
py_compile exit=0
token_budget_batch_self_test status=pass groups=[[5,0,1],[2],[6],[4],[3]] longest_row_single=true padded_totals=[4803,6209,7201,7201,7201]
loss_mask_self_test status=pass trainable_tokens=2 zero_token_fail_closed_guard=finite_loss_zero_ntoks
```

Formal prepare source-state probe:

```bash
RUN=/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR38-marker-fix-9714f6f2
OUT="$RUN/prepare-probe"
swift run C5TrainingCLI prepare \
  --output-dir "$OUT" \
  --target-positive 4500 \
  --dev-selection 400 \
  --masking-stage trainable_v0 \
  --theta-alpha-positive-only \
  --scope demo \
  --surface d_domain
```

Observed:

```text
exit=0
status=step2_dry_run_ready
rows=4500
train_eligible=4100
dev_selection=400
refusal_ratio=0.000
```

Receipt environment fields:

```text
training_loop_source_state=verified
training_loop_source_sha256=9714f6f2700a4c0f77be6bfdc005d291a894e858606a87a1a3838fd9a8f71748
training_loop_verification_status=pass
training_loop_verification_ref=docs/project/phase0/pr38-training-loop-source-state-receipt-2026-07-03.md
```

Prepare artifacts:

```text
/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR38-marker-fix-9714f6f2/prepare-probe/c5-training-receipt.json
/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR38-marker-fix-9714f6f2/prepare-probe/c5-training-receipt.md
/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR38-marker-fix-9714f6f2/prepare-probe-final.log
```

Artifact hashes:

```text
5fd99c05beca374e8079008bad7e4ad5479391e2085520d730f8fe390805c589  c5-training-receipt.json
2c36f1be8d1af797b3ad526341c13e9d856ea0eeeffed31fce966b47cbaac4c4  c5-training-receipt.md
32ea19182fb8982442849a880b8d867c35a47f19f2d9afe250622068e0de1ab4  prepare-probe-final.log
```

## Boundaries

- The prepare probe proves the formal source-state gate accepts the PR38 loop marker.
- The prepare status remains `step2_dry_run_ready`, not training authorization.
- The receipt still records broader non-training failures/debt: `cloud_multi_source_generator_not_run`, `multi_source_generator_diversity_missing`, and `cross_vendor_semantic_judge_not_run`.
- Real T1D config-smoke, full candidate training, F-044, C6 acceptance, and owner run-auth remain outside this PR38 marker fix.

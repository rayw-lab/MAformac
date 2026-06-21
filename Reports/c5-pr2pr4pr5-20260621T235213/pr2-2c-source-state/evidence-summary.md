# PR2 2c Source-State Gate Evidence

Status: ready_for_independent_audit

Scope: source-state wiring after PR2 clip and equivalence proof. This subphase verifies that formal C5 preparation reads a machine-checkable training-loop verification marker and blocks unverified loop sources before candidate training.

## Code Receipts

- Verification marker: `Tools/C5TrainingCLI/c5_mlx_train_loop.verification.json`
- Marker sha256: `676cfd12c44d022f3abcaceba957ec1937dc8ed2a46d56d6031d2101f6e0bbb8`
- Current training loop sha256: `5400641044144746f8d4ddc424b8b49f66e650e6511d94843ccd64f12895e0f7`
- Marker `script_sha256`: `5400641044144746f8d4ddc424b8b49f66e650e6511d94843ccd64f12895e0f7`
- Marker `verification_ref`: `Reports/c5-pr2pr4pr5-20260621T235213/pr2-2b-equivalence/evidence-summary.md`
- Marker audit refs:
  - `Reports/c5-pr2pr4pr5-20260621T235213/audits/codex-audit-pr2-2a-clip-enabled-r1.md`
  - `Reports/c5-pr2pr4pr5-20260621T235213/audits/codex-audit-pr2-2b-equivalence-r1.md`

## Prepare Probe

Directory: `Reports/c5-pr2pr4pr5-20260621T235213/pr2-2c-source-state-prepare-probe`

Command: `swift run C5TrainingCLI prepare` with original cached Qwen3-1.7B-4bit tokenizer snapshot as `--base-model-dir` and PR3 final generated utterances.

Receipts:

- `c5-training-receipt.json` sha256: `2e50c9cdaf012ce4eab5fc2bbd5acfd979e5e7234586874b9e7b635dfe22f018`
- `mlx-train-command.txt` sha256: `f80744fe36aaaa63949f919a6e3a04cf2e7d626f4a488a16ff7f9a6ef0267037`
- Receipt status: `trainable_v0_ready`
- Failure receipt: empty
- Train-eligible count: 4556
- Offset fixture status: `pass`
- Offset fixture artifact sha256: `99eb15e574278f9dd0af9b5417ecf7887bb65b4b1eb4e3e7977b2e8eea0d4afa`
- `gradient_clip_status`: `verified_repo_loop_clip_grad_norm_max_1.0_nonfinite_stop_fallback_lr_5e-5`
- `training_loop_source_state`: `verified`
- `training_loop_source_sha256`: `5400641044144746f8d4ddc424b8b49f66e650e6511d94843ccd64f12895e0f7`
- `training_loop_verification_status`: `pass`
- `training_loop_verification_ref`: `Reports/c5-pr2pr4pr5-20260621T235213/pr2-2b-equivalence/evidence-summary.md`
- Rendered train command contains `--source-snapshot-output .../c5_mlx_train_loop.snapshot.py`.

## Test Receipts

- `swift test --filter C5LoRATrainingTests`: 19 tests, 0 failures.
- `swift test`: 107 tests, 3 skipped, 0 failures.
- `openspec validate --all --strict`: 8 passed, 0 failed.
- `git diff --check`: passed.

## Local Verdict

PR2 2c source-state wiring is in place: formal `trainable_v0` builds block when the training loop source is unverified, and the real CLI prepare path reads the verification marker as `verified` only when the marker sha matches the current training loop. This does not sign PR5 candidate quality or GPT Pro final pass.

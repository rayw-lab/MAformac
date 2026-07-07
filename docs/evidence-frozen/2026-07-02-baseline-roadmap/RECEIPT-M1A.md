# RECEIPT-M1A

status: DONE
proof_class: local + ci
task: M1-alpha g2-mask reverse guard PR

## Scope

- worktree: `/Users/wanglei/workspace/MAformac-g2-mask`
- branch: `c5gate/g2-masking-enforce`
- PR: https://github.com/rayw-lab/MAformac/pull/13
- head_sha: `96a4b264d2847e0f95a04a2676b18e4fdc1cdba6`
- merge: not merged

## Changed Files

- `Tools/C5TrainingCLI/c5_mlx_train_loop.py`
- `Tests/MAformacCoreTests/C5LoRATrainingTests.swift`

## Guard Evidence

- reverse guard implementation: `Tools/C5TrainingCLI/c5_mlx_train_loop.py:610`
- fail-closed reason: `Tools/C5TrainingCLI/c5_mlx_train_loop.py:625` -> `loss_mask_present_but_flag_missing`
- guard call before MLX runtime/model load: `Tools/C5TrainingCLI/c5_mlx_train_loop.py:959`
- MLX runtime is lazy-loaded after guard: `Tools/C5TrainingCLI/c5_mlx_train_loop.py:962`
- behavior test: `Tests/MAformacCoreTests/C5LoRATrainingTests.swift:980`

## Validation

- `swift test --filter C5LoRATrainingTests`
  - result: pass
  - count: 46 tests, 0 failures
- `PATH="/opt/homebrew/opt/python@3.13/libexec/bin:/opt/homebrew/opt/python@3.13/bin:/opt/homebrew/bin:$PATH" python3 Tools/C5TrainingCLI/c5_mlx_train_loop.py --self-test-loss-mask`
  - result: pass
  - output: `{"event":"loss_mask_self_test","status":"pass","trainable_tokens":2,...}`
- source-free reverse guard probe with `/usr/bin/python3`
  - result: pass
  - observed: `LOSS_MASK_PREFLIGHT_FAILED loss_mask_present_but_flag_missing`, exit `66`
- `git diff --check`
  - result: pass
- GitNexus `detect_changes(scope=all)`
  - result: low risk
  - affected_processes: empty
- push command used proxy-unset env:
  - `env -u HTTP_PROXY -u HTTPS_PROXY -u http_proxy -u https_proxy -u ALL_PROXY -u all_proxy git push --force-with-lease origin c5gate/g2-masking-enforce`

## CI

- workflow: Verify
- run: https://github.com/rayw-lab/MAformac/actions/runs/28560391206
- job: https://github.com/rayw-lab/MAformac/actions/runs/28560391206/job/84676686084
- conclusion: SUCCESS
- CI count: 479 tests, 4 skipped, 0 failures
- PR merge state after CI: CLEAN

## Non-Goals Honored

- no training run
- no data generation
- no model download
- no merge

## Residual Risk

- CI proves source-free gates and local targeted guard behavior. It is not a LoRA quality, training, model-download, runtime demo, mobile, or true-device acceptance proof.

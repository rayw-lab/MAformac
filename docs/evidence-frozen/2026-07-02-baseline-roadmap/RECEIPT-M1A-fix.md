# RECEIPT-M1A-fix

status: DONE
artifact_kind: authoritative_fix_receipt
proof_class: local + ci
task: P0 fix for XAUDIT-alpha §2.2/§3 test split reverse guard gap

## Scope

- worktree: `/Users/wanglei/workspace/MAformac-g2-mask`
- branch: `c5gate/g2-masking-enforce`
- PR: https://github.com/rayw-lab/MAformac/pull/13
- head_sha: `04199f2efd7b28a9723ba7aef44450e1430bb830`
- commit: `04199f2e fix gate2 guard test split loss mask`
- merge: not merged

## Fix

- `guard_stock_loader_rejects_loss_mask` now scans `train`, `valid`, and `test`.
- Added behavior coverage for `test.jsonl` containing `loss_mask` with `--test` and no `--require-maformac-loss-mask`: must exit `66`.
- Added no-mask stock `--test` negative control: must not exit `66` and must not emit `LOSS_MASK_PREFLIGHT_FAILED` or `loss_mask_present_but_flag_missing`.

## File Evidence

- split scan: `Tools/C5TrainingCLI/c5_mlx_train_loop.py:610-625`
- test split behavior test: `Tests/MAformacCoreTests/C5LoRATrainingTests.swift:1008-1035`
- no-mask negative control: `Tests/MAformacCoreTests/C5LoRATrainingTests.swift:1037-1063`

## Local Validation

- `swift test --filter C5LoRATrainingTests`
  - result: pass
  - count: 48 tests, 0 failures
- `/opt/homebrew/opt/python@3.13/bin/python3.13 Tools/C5TrainingCLI/c5_mlx_train_loop.py --self-test-loss-mask`
  - result: pass
  - output status: `pass`
- adversarial fixture 1: `train.jsonl` contains `loss_mask`, no flag, `--train`
  - result: `TRAIN_MASK_STATUS=66`
  - stderr contains: `LOSS_MASK_PREFLIGHT_FAILED loss_mask_present_but_flag_missing`
- adversarial fixture 2: `test.jsonl` contains `loss_mask`, no flag, `--test`
  - result: `TEST_MASK_STATUS=66`
  - stderr contains: `LOSS_MASK_PREFLIGHT_FAILED loss_mask_present_but_flag_missing`
- adversarial fixture 3: no `loss_mask` in `train/valid/test`, no flag, `--test`
  - result: `NO_MASK_STATUS=1`
  - not exit `66`
  - no preflight marker emitted
- `git diff --check`
  - result: pass
- GitNexus impact/detect changes
  - `run` impact: LOW
  - `detect_changes(scope=all)`: LOW, affected_processes empty

## CI

- workflow: Verify
- run: https://github.com/rayw-lab/MAformac/actions/runs/28561058862
- job: https://github.com/rayw-lab/MAformac/actions/runs/28561058862/job/84678634028
- conclusion: SUCCESS
- CI full suite: 481 tests, 4 skipped, 0 failures
- PR merge state after CI: CLEAN

## Push

- push command used proxy-unset env:
  - `env -u HTTP_PROXY -u HTTPS_PROXY -u http_proxy -u https_proxy -u ALL_PROXY -u all_proxy git push --force-with-lease origin c5gate/g2-masking-enforce`

## Notes

- Local bare `swift test` was also attempted. It failed only in `RuntimePresentationPayloadFixtureConsumerTests.testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable` because the local sibling `/Users/wanglei/workspace/MAformac` fixture corpus hashes differ from this worktree. That is outside this P0 guard scope. The source-free PR CI full suite is green on head `04199f2e`.
- No training, data generation, model download, or PR merge was performed.

## Residual Risk

- This receipt proves the P0 guard gap and its regression coverage. It is not LoRA quality, training, runtime demo, mobile, or true-device acceptance evidence.

# RECEIPT-P2C6

verdict: READY_FOR_REVIEW_LOCAL_PASS_WITH_SIBLING_ENV_RESIDUAL
date: 2026-07-02
worktree: `/Users/wanglei/workspace/MAformac-p2c6`
branch: `fix/c6-subset-dead-fields`
base: `1d822961`
commit: `6a360e78 Fix C6 subset accounting dead fields`
pr: https://github.com/rayw-lab/MAformac/pull/23
merge_status: not merged

## Scope

- touched code only under `Core/Bench` and `Tests`.
- changed files:
  - `Core/Bench/C6SubsetContext.swift`
  - `Tests/MAformacCoreTests/C6SubsetContextTests.swift`

## What Changed

- `expected_unsupported_class` is now consumed by the existing C6 subset evaluation path:
  - `C6BenchRunner.evaluate(subsetCase:)` passes `subsetCase.expectedUnsupportedClass` into `C6SubsetGateClassifier.classify`.
  - classifier derives actual unsupported class from subset mount/accounting state and compares it with expected.
  - mismatch is emitted as `subset_failure_class = unsupported_class_mismatch`.
- `isModelFailure` is no longer always false:
  - `missing_expected_in_mounted` remains non-model failure.
  - mounted target with wrong model output uses base C6 `gate_result.model_hard_failed` and emits `is_model_failure = true`.
  - `actual_not_in_allowed` is model failure when expected target is mounted.
- `C6SubsetEvalRun` now encodes/decodes `is_model_failure`, defaulting old receipts to false.
- subset summary now blocks on any non-`none` subset failure class, including `unsupported_class_mismatch`.

## Consumption Proof

Behavior tests prove runner-level consumption, not decode-only:

- `Tests/MAformacCoreTests/C6SubsetContextTests.swift:208`
  - constructs a subset case with `expectedUnsupportedClass = .groupOutOfMount`.
  - mounted/allowed contains `set_cabin_ac`; model output succeeds.
  - asserts C6 runner output changes to `subsetFailureClass == .unsupportedClassMismatch`.
- `Tests/MAformacCoreTests/C6SubsetContextTests.swift:237`
  - expected target is mounted.
  - model omits the tool call.
  - asserts base C6 gate hard-fails and subset run emits `isModelFailure == true`.
- `Tests/MAformacCoreTests/C6SubsetContextTests.swift:182`
  - expected target is not mounted.
  - asserts `missingExpectedInMounted` and `isModelFailure == false`.
- `Tests/MAformacCoreTests/C6SubsetContextTests.swift:283`
  - proves unsupported-class mismatch blocks summary status via existing summary path.

Consumption points:

- `Core/Bench/C6SubsetContext.swift:180` passes expected unsupported class and base model hard-fail into the classifier.
- `Core/Bench/C6SubsetContext.swift:190` writes classifier accounting back into `C6SubsetEvalRun`.
- `Core/Bench/C6SubsetContext.swift:243` compares expected unsupported class to derived class.
- `Core/Bench/C6SubsetContext.swift:260` emits true model-failure accounting from base model failure / actual-not-allowed.
- `Core/Bench/C6SubsetContext.swift:271` derives `group_out_of_mount`.
- `Core/Bench/C6SubsetContext.swift:274` derives `mvp_unsupported` from existing `refusalNoAvailableTool`.

## Validation

- PASS: `swift test --filter C6SubsetContextTests`
  - 13 tests, 0 failures.
- PASS: `swift test` in `/tmp/MAformac-p2c6-isolated`
  - 505 tests, 4 skipped, 0 failures.
- FAIL, classified residual: `swift test` in `/Users/wanglei/workspace/MAformac-p2c6`
  - 505 tests, 3 skipped, 5 failures.
  - all 5 failures are `RuntimePresentationPayloadFixtureConsumerTests.testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable`.
  - failure reason is sibling `../MAformac` UIUE fixture digest mismatch, outside touched C6 files.
  - C6SubsetContextTests and C6VehicleToolBenchTests pass in this run.
- PASS: `git diff --check`.
- GitNexus:
  - pre-edit impact on `C6BenchRunner`: HIGH risk, affected processes include `Tools/C6BenchCLI/main.swift`.
  - final `detect_changes(scope=all, worktree=/Users/wanglei/workspace/MAformac-p2c6)`: low, changed files 2, changed symbols 0.

## Residual Risk

- `global_unsupported` has no independent actual-side signal in current C6 behavior enum. Current classifier fail-closed mismatches an expected `global_unsupported` unless future C6 data carries an actual global-vs-MVP distinction.
- No PR merge was performed.

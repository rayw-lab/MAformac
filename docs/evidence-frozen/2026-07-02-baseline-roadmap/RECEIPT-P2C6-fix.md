# RECEIPT-P2C6-fix

verdict: DONE_LOCAL_UNIT_PASS_WITH_KNOWN_SIBLING_FIXTURE_RESIDUAL
date: 2026-07-02
worker: pane %43
worktree: `/Users/wanglei/workspace/MAformac-p2c6`
branch: `fix/c6-subset-dead-fields`
base: `origin/main@a8fcd245`
commit: `c608658b0ef9393f6609001b7dafdfec863584de`
pr: https://github.com/rayw-lab/MAformac/pull/23
scope: R7 construction only; no training, no data generation, no merge.

## Changed Files

- `Core/Bench/C6SubsetContext.swift`
- `Tests/MAformacCoreTests/C6SubsetContextTests.swift`

## Fixes

- HIGH: `global_unsupported` now has a reachable success path through explicit `actualUnsupportedClass` passed into subset evaluation/classifier. Existing behavior-class fallback still maps legacy `refusalNoAvailableTool` to `mvp_unsupported`, but parser/NO_TOOL reason can now distinguish `mvp_unsupported` from `global_unsupported`.
- HIGH regression coverage: added three positive runner tests for `group_out_of_mount`, `mvp_unsupported`, and `global_unsupported`, plus a mvp/global mismatch test.
- MEDIUM: `C6SubsetFailureStats` now includes `unsupported_class_mismatch_count`, summary increments it, and old stats JSON decodes missing field as `0`.

## Validation

- PASS: `env -u HTTP_PROXY -u HTTPS_PROXY -u http_proxy -u https_proxy -u ALL_PROXY -u all_proxy git fetch origin`
- PASS: `env -u HTTP_PROXY -u HTTPS_PROXY -u http_proxy -u https_proxy -u ALL_PROXY -u all_proxy git rebase origin/main`
- PASS: `swift test --filter C6SubsetContextTests`
  - 18 tests, 0 failures.
- PASS: `git diff --check`
- PASS: `mcp__gitnexus.detect_changes(scope=all, worktree=/Users/wanglei/workspace/MAformac-p2c6)`
  - reported `risk_level=low`, changed files=2, affected processes=0.
  - caveat: pre-edit GitNexus impact could not resolve the new C6 subset symbols in the stale index, so tests are the load-bearing proof.
- PARTIAL full-suite: `swift test`
  - 513 tests, 3 skipped, 5 failures.
  - all failures are `RuntimePresentationPayloadFixtureConsumerTests.testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable`, digest mismatch for sibling UIUE fixture files outside touched C6 subset files.
  - C6SubsetContextTests and C6VehicleToolBenchTests passed during the run.
- PASS: `env -u HTTP_PROXY -u HTTPS_PROXY -u http_proxy -u https_proxy -u ALL_PROXY -u all_proxy git push --force-with-lease origin fix/c6-subset-dead-fields`
  - remote updated `6a360e78...c608658b`.

## Proof Class

- local/unit for C6 subset behavior.
- no runtime, no mobile, no true-device, no live API, no V-PASS claimed.

## Residual Risk

- `actualUnsupportedClass` is an evaluation input for the future parser/NO_TOOL outlet reason. Current C6 runtime output still does not itself carry NO_TOOL reason; that parser mapping remains downstream construction work.
- Full `swift test` in this worktree remains blocked by sibling UIUE fixture digest mismatch, already unrelated to this C6 subset patch.

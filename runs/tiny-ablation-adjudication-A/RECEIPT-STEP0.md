# RECEIPT-STEP0

status: DONE-STEP0
branch: fix/tiny-ablation-real-unlock
base: origin/main @ aac84de90b9acabb7cb934237e010796f4ef9724
worktree: /Users/wanglei/workspace/.step0/MAformac-step0-tiny
proof_class: local + unit

## Scope

Step 0 only: unlock the C5 tiny-ablation harness for a signed real metric reference.

No training, no data generation, no real ablation execution, no merge.

## Run Authorization Inputs

- run plan: /Users/wanglei/workspace/MAformac/docs/project/phase0/r-l17-human-review-evidence/tiny-ablation-run-plan-adjudication-A.md
- signed authorization: /Users/wanglei/workspace/MAformac/docs/project/phase0/r-l17-human-review-evidence/R7-renewal-and-tiny-ablation-run-auth-DRAFT.md
- signed marker reviewed: B.3 `signed_run_authorized`, approved sample count 40.

## Changed Files

- Core/Training/C5TinyAblationHarness.swift
- Tests/MAformacCoreTests/C5TinyAblationHarnessTests.swift
- runs/tiny-ablation-adjudication-A/RECEIPT-STEP0.md

## Behavior Implemented

- Added `C5TinyAblationMetricSource.real`.
- Added companion `runAuthorizationReference`.
- `.real` is only eligible when `runAuthorizationReference` equals the signed authorization document path above.
- Missing or wrong real-run reference remains blocked.
- `.realBlocked` remains blocked by default.
- Sample count gate remains `20...50`.
- Empty tool-call output gate remains strict `< 5`; `N=4` passes and `N=5` blocks.

## Validation

- `swift test --filter C5TinyAblationHarnessTests`
  - passed: 9 tests, 0 failures.
- `swift test`
  - passed: 518 tests, 4 skipped, 0 failures.
  - SwiftPM warning observed for 3 unhandled test/doc files; no failure.
- `git diff --check`
  - passed with no output.
- GitNexus `detect_changes(scope: all, worktree: /Users/wanglei/workspace/.step0/MAformac-step0-tiny)`
  - changed_files: 2
  - changed_symbols: 0
  - affected_processes: 0
  - risk_level: low
  - caveat: GitNexus did not map the Swift harness symbol in this index, so live diff and tests are the controlling proof.

## Notes

- The worktree was moved under `/Users/wanglei/workspace/.step0/` before final full test to avoid unrelated sibling-repo fixture comparison noise.
- The first full-test attempt after moving worktree hit a local `.build` module-cache absolute-path mismatch; removing only the moved worktree `.build` and rerunning `swift test` produced the passing result above.

REPORT Step0 DONE-STEP0: C5TinyAblationHarness real metric gate unlocked behind exact signed run-auth reference; targeted and full Swift tests pass locally; no training/data generation/run execution claimed.

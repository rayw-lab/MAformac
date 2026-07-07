---
retire_trigger: "Retire when superseded by archived OpenSpec specs or explicit user decision."
expires: "2026-08-15"
---

# XSWAP-23 Fix Delta Re-Verification

- verdict: HIGH-RESOLVED
- target: PR 23 update commit `c608658b0ef9393f6609001b7dafdfec863584de`
- tested_worktree: `/Users/wanglei/workspace/MAformac-p2c6`
- branch: `fix/c6-subset-dead-fields`
- mode: read-only delta verification; no implementation files edited
- proof_class: local/unit

## Truth

```text
$ git show --no-patch --format='%H%n%D%n%s%n%ci' c608658b
c608658b0ef9393f6609001b7dafdfec863584de
origin/fix/c6-subset-dead-fields, fix/c6-subset-dead-fields
Fix C6 subset accounting dead fields
2026-07-02 18:09:43 +0800
```

```text
$ pwd && git status --short && git rev-parse HEAD && git rev-parse --abbrev-ref HEAD
/Users/wanglei/workspace/MAformac-p2c6
c608658b0ef9393f6609001b7dafdfec863584de
fix/c6-subset-dead-fields
```

Delta touched only:

```text
$ git show --stat --oneline --decorate HEAD
c608658b (HEAD -> fix/c6-subset-dead-fields, origin/fix/c6-subset-dead-fields) Fix C6 subset accounting dead fields
 Core/Bench/C6SubsetContext.swift                   | 121 +++++++++--
 Tests/MAformacCoreTests/C6SubsetContextTests.swift | 222 ++++++++++++++++++++-
 2 files changed, 323 insertions(+), 20 deletions(-)
```

## L.4 Checks

### 1. Original `global_unsupported` Fixture

Requirement: base C6 already-correct global refusal must now be reachable as successful classification, not mismatch.

```text
$ swift test --filter C6SubsetContextTests/testRunnerAllowsGlobalUnsupportedClassWhenNoToolReasonMatches
Test Case '-[MAformacCoreTests.C6SubsetContextTests testRunnerAllowsGlobalUnsupportedClassWhenNoToolReasonMatches]' passed (0.005 seconds).
Test Suite 'Selected tests' passed
Executed 1 test, with 0 failures (0 unexpected)
```

Evidence anchors:
- `Tests/MAformacCoreTests/C6SubsetContextTests.swift:290` constructs `expectedUnsupportedClass: .globalUnsupported`.
- `Tests/MAformacCoreTests/C6SubsetContextTests.swift:297` passes `actualUnsupportedClass: .globalUnsupported`.
- `Tests/MAformacCoreTests/C6SubsetContextTests.swift:305` asserts `modelHardFailed == false`.
- `Tests/MAformacCoreTests/C6SubsetContextTests.swift:306` asserts `subsetFailureClass == .none`.
- `Tests/MAformacCoreTests/C6SubsetContextTests.swift:307` asserts `isModelFailure == false`.

Conclusion: PASS. Original HIGH path is resolved for `global_unsupported`.

### 2. Three Positive Unsupported Classes

#### `group_out_of_mount`

```text
$ swift test --filter C6SubsetContextTests/testRunnerAllowsGroupOutOfMountUnsupportedClassWhenExpectedToolIsNotMounted
Test Case '-[MAformacCoreTests.C6SubsetContextTests testRunnerAllowsGroupOutOfMountUnsupportedClassWhenExpectedToolIsNotMounted]' passed (0.003 seconds).
Test Suite 'Selected tests' passed
Executed 1 test, with 0 failures (0 unexpected)
```

Evidence: `Tests/MAformacCoreTests/C6SubsetContextTests.swift:252-268`.

#### `mvp_unsupported`

```text
$ swift test --filter C6SubsetContextTests/testRunnerAllowsMVPUnsupportedClassWhenNoToolReasonMatches
Test Case '-[MAformacCoreTests.C6SubsetContextTests testRunnerAllowsMVPUnsupportedClassWhenNoToolReasonMatches]' passed (0.003 seconds).
Test Suite 'Selected tests' passed
Executed 1 test, with 0 failures (0 unexpected)
```

Evidence: `Tests/MAformacCoreTests/C6SubsetContextTests.swift:270-287`.

#### `global_unsupported`

```text
$ swift test --filter C6SubsetContextTests/testRunnerAllowsGlobalUnsupportedClassWhenNoToolReasonMatches
Test Case '-[MAformacCoreTests.C6SubsetContextTests testRunnerAllowsGlobalUnsupportedClassWhenNoToolReasonMatches]' passed (0.002 seconds).
Test Suite 'Selected tests' passed
Executed 1 test, with 0 failures (0 unexpected)
```

Evidence: `Tests/MAformacCoreTests/C6SubsetContextTests.swift:290-307`.

Conclusion: PASS. Three positive classes are individually green.

### 3. `unsupported_class_mismatch` Block And Stats

Requirement: mismatch fixture must block, and `subset_failure_stats.unsupported_class_mismatch_count` must count consistently.

```text
$ swift test --filter C6SubsetContextTests/testRunnerSubsetSummaryBlocksOnUnsupportedClassMismatch
Test Case '-[MAformacCoreTests.C6SubsetContextTests testRunnerSubsetSummaryBlocksOnUnsupportedClassMismatch]' passed (0.004 seconds).
Test Suite 'Selected tests' passed
Executed 1 test, with 0 failures (0 unexpected)
```

Evidence anchors:
- `Tests/MAformacCoreTests/C6SubsetContextTests.swift:376` constructs expected unsupported class mismatch summary case.
- `Tests/MAformacCoreTests/C6SubsetContextTests.swift:403` asserts `summary.status == "construction_subset_blocked"`.
- `Tests/MAformacCoreTests/C6SubsetContextTests.swift:404-406` asserts missing/actual counts stay `0`, and `unsupportedClassMismatchCount == 1`.

Conclusion: PASS. MEDIUM accounting gap is resolved for this delta fixture.

### 4. Previously Verified Regression Points

#### expected mismatch interception

```text
$ swift test --filter C6SubsetContextTests/testRunnerConsumesExpectedUnsupportedClassMismatch
Test Case '-[MAformacCoreTests.C6SubsetContextTests testRunnerConsumesExpectedUnsupportedClassMismatch]' passed (0.003 seconds).
Test Suite 'Selected tests' passed
Executed 1 test, with 0 failures (0 unexpected)
```

Evidence: `Tests/MAformacCoreTests/C6SubsetContextTests.swift:223-249`.

#### explicit mvp/global mismatch rejection

```text
$ swift test --filter C6SubsetContextTests/testRunnerRejectsMVPGlobalUnsupportedClassMismatch
Test Case '-[MAformacCoreTests.C6SubsetContextTests testRunnerRejectsMVPGlobalUnsupportedClassMismatch]' passed (0.002 seconds).
Test Suite 'Selected tests' passed
Executed 1 test, with 0 failures (0 unexpected)
```

Evidence: `Tests/MAformacCoreTests/C6SubsetContextTests.swift:310-327`.

#### `isModelFailure == true` on mounted target wrong output

```text
$ swift test --filter C6SubsetContextTests/testRunnerMarksModelFailureWhenMountedTargetProducesWrongOutput
Test Case '-[MAformacCoreTests.C6SubsetContextTests testRunnerMarksModelFailureWhenMountedTargetProducesWrongOutput]' passed (0.002 seconds).
Test Suite 'Selected tests' passed
Executed 1 test, with 0 failures (0 unexpected)
```

Evidence: `Tests/MAformacCoreTests/C6SubsetContextTests.swift:330-343`.

#### `isModelFailure == false` on mount accounting failure

```text
$ swift test --filter C6SubsetContextTests/testRunnerSubsetEvaluationConsumesMountedSetAndEmitsSubsetFailureClass
Test Case '-[MAformacCoreTests.C6SubsetContextTests testRunnerSubsetEvaluationConsumesMountedSetAndEmitsSubsetFailureClass]' passed (0.002 seconds).
Test Suite 'Selected tests' passed
Executed 1 test, with 0 failures (0 unexpected)
```

Evidence: `Tests/MAformacCoreTests/C6SubsetContextTests.swift:207-220`.

Conclusion: PASS. Previously verified mismatch and `isModelFailure` behavior did not regress.

## Local Regression Sweep

```text
$ swift test --filter C6SubsetContextTests
Test Suite 'C6SubsetContextTests' passed
Executed 18 tests, with 0 failures (0 unexpected)
Test Suite 'Selected tests' passed
Executed 18 tests, with 0 failures (0 unexpected)
```

## Final Verdict

HIGH-RESOLVED.

The original HIGH finding is resolved because `global_unsupported` expected/actual alignment now reaches `.none` instead of `unsupported_class_mismatch`. The MEDIUM stats gap is resolved because mismatch summary blocks and increments `unsupportedClassMismatchCount == 1` while other subset stats remain zero.

Residual risk: this is local/unit proof only. I did not run full `swift test`, `make verify`, CI, live model, or C6 acceptance. SwiftPM emitted the pre-existing unhandled-file warning for `MAformacIOSUITests/*.swift` and `UBIQUITOUS_LANGUAGE.md` on the first targeted run; targeted tests still passed.

DONE-XS23F

REPORT XSWAP-23-fix verdict=HIGH-RESOLVED commit=c608658b proof=local/unit targeted=PASS c6_subset_context=18/18 residual="no full make verify or CI"

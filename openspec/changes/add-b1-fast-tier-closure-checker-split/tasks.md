## 1. OpenSpec carrier

- [x] 1.1 Add proposal, design, tasks, and delta spec under `openspec/changes/add-b1-fast-tier-closure-checker-split/`.
- [x] 1.2 Run `openspec validate add-b1-fast-tier-closure-checker-split --strict`.

## 2. Classifier (TDD)

- [x] 2.1 Add bounded N1-N11 classifier negatives plus staged/unstaged/untracked/manifest union coverage.
- [x] 2.2 Implement three-tier pure logic plus explicit-base/subject, NUL-safe read-only git adapter and CLI.

## 3. Closure pytest partition

- [x] 3.1 Preserve the exact four git-clone/history-sensitive tests as a stable-name heavy roster without custom pytest markers.
- [x] 3.2 Keep the source split at exactly 20 functions (16 static + four heavy) and add wiring coverage without adding source tests to the closure module.

## 4. Makefile

- [x] 4.1 Add `verify-closure-work-packages-static` and `verify-closure-work-packages-local-fast`.
- [x] 4.2 Keep `verify-closure-work-packages` and `verify-ci` on full target.

## 5. Verification

- [x] 5.1 Run classifier unit tests and selected closure wiring tests.
- [x] 5.2 Probe all three classifier tiers and run the explicit static closure target with the real checker.
- [x] 5.3 Run the unchanged full closure target to completion.
- [x] 5.4 Validate OpenSpec strict, diff/EOF/scope, and GitNexus changed scope.

## Residual

- Source-static is a semantic partition, not a latency promise. A previous local run measured about 152 seconds; FT1 makes no wall-clock speed claim and adds no cache-key behavior.

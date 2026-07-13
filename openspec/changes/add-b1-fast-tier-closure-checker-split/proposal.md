> status: `planned_executable`
> execution_state: `implemented_local`
> proof_cap: `local_static_classifier_and_makefile_wiring`
> gate: `openspec_validate_strict_plus_pytest_classifier_and_closure_partition`

## Why

O1/O2 closure verification currently runs one full pytest roster on every local iteration. Four git-clone and history-sensitive cases dominate wall time while the remainder are deterministic static contracts. FT1 needs a production-shaped CI delta: keep remote `verify-ci` on the full closure target, add a fail-closed path classifier and explicit static/local-fast Make surfaces for solo iteration.

## What Changes

- Add deterministic three-tier `closure_path_classifier`: changed paths → `ordinary_docs`, `closure_authority`, or `full`; empty/unknown input and incomplete git history fail closed to `full`.
- Split closure pytest into static roster (all closure tests except four named heavy cases) versus full roster (unchanged behavior).
- Add `verify-closure-work-packages-static` and `verify-closure-work-packages-local-fast` Make targets; preserve `verify-closure-work-packages` and `verify-ci` full dependency.

## Non-goals

- Do not weaken `verify-ci`, remove checker execution on fast paths, or skip schema/registry validation on static tier.
- Do not claim W8 runtime-spine DONE, operator-pass, mobile, true-device, or live proof.
- Do not add third-party dependencies or change closure registry semantics.

## Success Criteria

- `openspec validate add-b1-fast-tier-closure-checker-split --strict` passes.
- Classifier and Makefile wiring tests pass; closure partition preserves the exact 20 source functions as 16 static + four heavy by stable-name deselection (no custom pytest marker).
- `verify-ci` still lists `verify-closure-work-packages` (full), not local-fast.

## Capabilities

### Modified Capabilities

- `closure-work-packages`: local-fast classification and static/full pytest partition without changing O1/O2 checker outcomes on full runs.

## Impact

- Touch: `scripts/closure_path_classifier.py`, classifier tests, `Tests/test_closure_work_packages.py` wiring assertion, and `Makefile` targets only.

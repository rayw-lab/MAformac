# Tasks — repair-s10-action-demo-proven-promotion

> Run-root authority: `PHASE2-S10-PROOF-CONTRACT-REPAIR-磊哥-APPROVAL-RECEIPT.md`
> Knife 1 retry **blocked** until I1+I2+I3 gates below are all green.

## I1 — BF-8 promotion basis (P-A)

- [x] 1.1 Add `bf8_promotion` to matrix basis schema + `demo-capability-matrix.json` template defaults (`observed=false`)
- [x] 1.2 Update `compute_action_demo_proven()` to require fifth basis; add `E_ACTION_DEMO_PROVEN_BF8_NOT_AUTHORIZED` if needed
- [x] 1.3 Define BF-8 receipt schema stub in `contracts/governance/` (subject SHA + matrix_ids + ceremony refs)
- [x] 1.4 Extend `check_capability_matrix.py` materialize/check for fifth basis
- [x] 1.5 Update `scripts/test_check_capability_matrix.py` fixtures: probe green + promotion false → `actionDemoProven=false`
- [x] 1.6 Gate: `make verify-c1-matrix` green on I1-only branch

## I2 — Scoped probe receipt (R-A)

- [x] 2.1 Extend `runtime-action-readback-receipt-v2` schema with optional `scope.matrix_ids`
- [x] 2.2 Update `evaluate_action_probe_receipt()` coverage rule for scoped vs full receipts
- [x] 2.3 Materialize: apply `readbackProbePass` updates only for scoped IDs
- [x] 2.4 Document knife manifest field in run-root / contract comments
- [x] 2.5 Tests: scoped receipt `[4]` passes checker without matrix 5/6 cases
- [x] 2.6 Gate: `make verify-c1-matrix` + receipt schema validation

## I3 — Product acceptance route + hard assertions

- [x] 3.1 Register `acceptanceRouteID` for matrix 4 probe (frontstage text path — **no FastPath expansion in this slice**)
- [x] 3.2 Refactor or add probe test harness using product acceptance route
- [x] 3.3 Add hard `XCTAssert` for delta 24→26, readback 26, single tool call, accepted result
- [x] 3.4 Set receipt `pathKind=product_acceptance_route` on pass; keep diagnostic path for negative tests only
- [x] 3.5 Gate: probe test FAIL on current refusal evidence; PASS only when route contract satisfied
- [x] 3.6 Sub-grill if acceptance route cannot be defined without FastPath — **STOP**, do not expand FastPath here

## Closeout (after I1+I2+I3)

- [x] 4.1 Commander re-authorize knife 1 (update `PHASE2-S10-KNIFE1-COMMANDER-STOPLINE.md`)
- [x] 4.2 Re-run knife 1: scoped receipt → materialize → `verify-c1-matrix` + `verify-e2e`
- [x] 4.3 Run-root closeout receipt; **still** `actionDemoProven=0/120` until BF-8

## Knife 2 — matrix 4 exact utterance (BF-8 readiness, no flip)

- [x] K2-A direct command admitted (`testS10_matrix4_exactUtterance_directCommand_admitted`)
- [x] K2-B polite question admitted (`testS10_matrix4_exactUtterance_politeQuestion_admitted`)
- [x] K2-C fail closed variants rejected (`testS10_matrix4_failClosedVariants_rejected`)
- [x] K2-D no global question suffix strip (`testS10_matrix4_noGlobalQuestionSuffixStrip`)
- [x] K2-E verify via make verify-c1-action-probes
- [x] K2-F manifest in closeout
- [x] K2-G routing align (`matchCommandTemperature` templates cleaned)

## F2 — `--bf8-receipt` implementation (P-A machine consumption)

- [x] 2.1 Add `--bf8-receipt` optional arg to `materialize` and `check` subcommands in `Tools/checks/check_capability_matrix.py`
- [x] 2.2 Implement `evaluate_bf8_promotion_receipt()` validating receipt JSON against schema, path authority, content match, and git HEAD binding
- [x] 2.3 Implement `observed_bf8_promotion_basis()` helper and scoped application in `materialize_matrix()` and `validate_matrix()`
- [x] 2.4 Add `valid_bf8_receipt()` helper and unit tests covering schema rejection, authority bounds, git SHA mismatch, scoped promotion, and CLI options in `scripts/test_check_capability_matrix.py`
- [x] 2.5 Gate: `python3 -m unittest scripts/test_check_capability_matrix.py` (46 tests green, tracked matrix actionDemoProven=0/120)

## Wave4 F2 — `--bf8-receipt` consumer in capability matrix checker (no flip)

- [x] F2.1 Implement `--bf8-receipt <path>` in `Tools/checks/check_capability_matrix.py` (materialize & check subcommands)
- [x] F2.2 Only cells in `receipt.matrix_ids` get `bf8_promotion.observed=true`
- [x] F2.3 Without receipt: default all cells `bf8_promotion.observed=false`
- [x] F2.4 Add unittest fixtures and tests in `scripts/test_check_capability_matrix.py` (`test_f2_no_bf8_receipt_all_cells_bf8_observed_false`, `test_f2_bf8_receipt_matrix_4_only_cell_4_promoted`, `test_f2_bf8_receipt_with_scoped_probe_receipt`)
- [x] F2.5 Gate green: `python3 -m unittest scripts/test_check_capability_matrix.py` exit code 0, tracked matrix `actionDemoProven` count stays 0

## Non-claims

- Tasks checked ≠ knife 1 green
- No `actionDemoProven>0` until BF-8 after knives complete
- No FastPath edits unless separate approved change

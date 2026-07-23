## Why

S10 knife 1 (`readbackProbePass` for `matrix_id=4`) cannot close honestly under the current proof contract: the capability-matrix checker auto-derives `actionDemoProven=true` when four basis sources plus probe proof are green, while S10/BF-8 require promotion only after human BF-8; probe receipts must cover the entire catalog even when a knife slice targets a single cell; and the probe harness records evidence on a non-product default-runtime path without hard post-run assertions. This change repairs those contract gaps so knife 1 can pass without manual matrix patches or unauthorized FastPath expansion.

## What Changes

- Add **BF-8 promotion authorization** as a formal fifth basis input to `actionDemoProven` derivation in the capability-matrix checker and schema (**BREAKING** for materialize semantics: four green bases + probe proof no longer imply `actionDemoProven=true`).
- Add **scoped probe receipt** support so a knife slice may update a declared `matrix_ids` subset without full-catalog receipt coverage mismatch.
- Define **product acceptance route** requirements for action readback probes and require hard post-run assertions (state delta, readback, accepted tool call) — observation receipts alone are insufficient.
- Explicit **non-goal**: do not expand `FastPathIntentEngine` as a shortcut to pass probes until FastPath is ratified as a formal product entry (separate decision).
- Split implementation into three slices (I1 promotion basis, I2 scoped receipt, I3 acceptance route + assertions); **knife 1 retry remains blocked** until all three are green.

## Capabilities

### New Capabilities

- `s10-bf8-promotion-gate`: BF-8 human promotion authorization as machine-checkable basis blocking `actionDemoProven` flip until authorized.

### Modified Capabilities

- `demo-capability-governance` (delta under `add-c1-demo-capability-governance`): `actionDemoProven` derivation, probe receipt scope policy, matrix basis schema for `bf8_promotion`.
- `tool-execution`: product acceptance route identity for local runtime readback probes; hard assertion requirements vs evidence-only receipts.

## Impact

- `Tools/checks/check_capability_matrix.py` — derive/check `actionDemoProven`, scoped receipt evaluation, new error codes.
- `contracts/demo-capability-matrix.json` schema — fifth basis field; scoped receipt fields.
- `contracts/runtime-action-readback-probes.json` / receipt schema — `scope.matrix_ids`, `pathKind=product_acceptance_route`.
- `Tests/MAformacCoreTests/RuntimeActionReadbackProbeTests.swift` (or successor) — hard assertions.
- Run-root S10 artifacts remain authoritative for knife sequencing; this change does **not** flip `actionDemoProven` or unfreeze Phase2.

## Non-goals

- No immediate FastPath expansion to pass matrix 4 probe.
- No knife 1 re-execution, manual matrix patch, or `actionDemoProven>0` as part of this change.
- No BF-8 human ceremony execution, knife 2 utterance tests, or row167 / `close_ac` / rear-three-family scope.
- No real vehicle control; mock state + readback only.

## Success criteria

| Gate | Observable |
|---|---|
| I1 | With probe proof green and `bf8_promotion.observed=false`, materialize keeps `actionDemoProven=false` for matrix_id=4 without manual override errors. |
| I2 | Scoped receipt for `matrix_ids:[4]` updates only matrix 4 basis; no `E_ACTION_DEMO_PROVEN_ACTION_RECEIPT_COVERAGE_MISMATCH`. |
| I3 | Probe/acceptance tests FAIL on `refusal_no_available_tool`; PASS only with accepted tool call, 24→26 delta, readback=26 on declared product acceptance route. |
| Knife 1 unlock | Commander may re-authorize knife 1 only after I1+I2+I3 gates are green on the same subject SHA. |

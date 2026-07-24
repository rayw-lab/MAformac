# Proposal: admit-close-ac-secondary-m1

## Why

`close_ac` is mounted as a secondary tool, and the T2 contract defines its customer-text admission boundary and fail-closed behavior. Product code now implements the T2 negative mechanics for tasks 2, 3, and 4; this change records their gate-observed contract while the secondary capability remains unproven.

The historical task-1 scaffold is retained as provenance. T2 does not authorize a positive secondary receipt, a probe, a BF8 ceremony, a proven flip, or any primary-matrix change.

## T2 Status

T2 negative mechanics for tasks 2, 3, and 4 are implementation-complete against observed gates; this change is not whole-change complete or released. Strict OpenSpec validation passed. Wave1 py_compile passed; Python suites passed (97 total: receipt 36, matrix 61); `make verify-bf8-receipt-set`, `make verify-c1-matrix`, `make verify-c1-matrix-canonical`, and `DemoCapabilityMatrixGeneratedTests` passed. Wave2 passed: `DemoSliceAdmissionCatalogTests` 12, `DemoSliceProductBehaviorGateTests` 32, `RuntimeTurnReceiptDigestTests` 6, `RuntimeTurnReceiptSchemaTests` 6, `DemoSliceClassificationTests` 29, `DemoSliceRouteTests` 7, and `FahrenheitAdmissionTests` 11. Structural facts remain 120 cells, primary `actionDemoProven` IDs `[4]`, root-sibling `secondary_tools.close_ac` mounted/customer_admitted true/proven false, and canonical m4-only registry; no positive `close_ac` proof, BF8 ceremony, m1/archive work, or `proven=true` is claimed.

## What Changes

- Admit only the exact customer phrase `关闭空调`; aliases, fuzzy matches, indirect wording, and compound intents fail closed.
- Define Frame 甲 as `set_vehicle_control / power_off` with value `off`.
- Define typed identity as `primaryMatrix(Int) | secondaryTool(String)`. For `close_ac`, `matrixID` is nil; no `0`, `1`, or `121` sentinel is valid.
- Define the canonical typed receipt root with snake-case fields `subject_type` and `subject_id`. A primary receipt has an integer `subject_id` and singleton integer `matrix_ids`; a secondary receipt would have string `subject_id=close_ac` and no `matrix_ids` field (null is invalid). Nested subject aliases and alternate/camel fields are invalid.
- Preserve the exact m4 discriminator-less path+bytes route as the sole legacy exception.
- Define the matrix root sibling `secondary_tools.close_ac` fields: `mounted_status=mounted`, `customer_admitted=true`, `proven=false`, and `proven_basis` pending BF8 shape. It is never placed inside matrix cells or summary data; 120 cells and primary `[4]=1/120` remain unchanged.
- Specify T2 negative mechanics: unproven secondary admission is refused before runner/store/revision/TTS, with no secondary receipt, probe, BF8 ceremony, positive readback, or `proven=true`.

## Capabilities

### New Capabilities

- `close-ac-secondary-admit`: exact-phrase admission boundary, Frame 甲 typed binding, canonical typed receipt and matrix-sibling shape, and T2 fail-closed behavior.

### Modified Capabilities

- Wave1 implemented and gate-observed the generated Swift top-level `secondaryTools` projection; Wave2 implemented and gate-observed F4 consumption of `secondaryTools[close_ac].proven`, with missing/unknown treated as false before target projection, already-state handling, and runner. Later ownership is limited to task 5 positive E2E and tasks 6.1/6.2/6.3 m1/BF8/secondary ceremony/archive/proven flip work.

## Impact

The OpenSpec artifacts document the gate-observed behavior of the product implementation for T2 tasks 2/3/4. No additional schema, generated-file, runtime-catalog, or unrelated product changes are claimed here.

## Non-goals

- No additional Core/Swift, schema, generated-file, Makefile, or runtime work beyond the implemented T2 negative mechanics for tasks 2/3/4.
- No positive secondary receipt, probe, BF8 ceremony, `proven=true`, archive, m1 work, or BF8 ceremony claim.
- No runtime-action-readback v2 expansion and no m1 matrix change.
- No nested subject, alternate/camel receipt fields, fake matrix IDs, or matrix `1/121` sentinel.
- No changes to the 120 primary cells, primary `[4]=1/120`, candidate families, or unrelated documentation.

## Success criteria

| Gate | Observable |
|---|---|
| S1 Exact admission | Only `关闭空调` is admissible; aliases, fuzzy, indirect, and compound inputs fail closed. |
| S2 Typed contract | Frame 甲 is `set_vehicle_control/power_off` with value `off`; identity and receipt roots use the stated typed snake-case shapes. |
| S3 Matrix shape | `secondary_tools.close_ac` is a root sibling with mounted/admitted/false-pending fields; no cell or summary pollution occurs. |
| S4 T2 refusal | With `proven=false`, execution returns typed refusal before runner/store/revision/TTS and emits no positive receipt, probe, ceremony, or readback claim. |
| S5 Scope | Task 1 provenance remains checked; tasks 2/3/4 are negative-only; task 5 and 6.1/6.2/6.3 remain later unchecked/block-labeled. |

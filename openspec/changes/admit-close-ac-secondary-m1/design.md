# Design: admit-close-ac-secondary-m1

## Context

`close_ac` is a mounted secondary tool. T2 fixes its admission and accounting contract, and product code implements the negative mechanics for tasks 2/3/4 without proving the capability. The prior task-1 scaffold is historical provenance, not evidence of positive runtime execution.

## T2 Gate Evidence

Tasks 2/3/4 negative mechanics are implementation-complete against observed gates only; task 5 and 6.1/6.2/6.3 remain blocked and later-owned. Strict OpenSpec validation and Wave1 py_compile passed. Wave1 recorded 97 Python tests (receipt 36, matrix 61), `make verify-bf8-receipt-set`, `make verify-c1-matrix`, `make verify-c1-matrix-canonical`, and `DemoCapabilityMatrixGeneratedTests` passed. Wave2 recorded `DemoSliceAdmissionCatalogTests` 12, `DemoSliceProductBehaviorGateTests` 32, `RuntimeTurnReceiptDigestTests` 6, `RuntimeTurnReceiptSchemaTests` 6, `DemoSliceClassificationTests` 29, `DemoSliceRouteTests` 7, and `FahrenheitAdmissionTests` 11 passed. Structural facts are 120 cells, primary `actionDemoProven` IDs `[4]`, root-sibling `secondary_tools.close_ac` mounted/customer_admitted true/proven false, and canonical m4-only registry. These gates establish no positive proof, BF8 ceremony, m1/archive work, or `proven=true`.

## Goals / Non-Goals

### Goals

1. Make admission literal and fail closed: only `关闭空调` is eligible.
2. Bind the action to Frame 甲 `set_vehicle_control / power_off`, value `off`.
3. Fix typed identity, receipt root, and matrix-sibling shapes.
4. Record the implemented negative mechanics while `secondary_tools.close_ac.proven=false`.
5. Record that Wave1 implemented and gate-observed the generated Swift top-level `secondaryTools` projection, and Wave2 implemented and gate-observed F4 consumption of `secondaryTools[close_ac].proven` with missing/unknown treated as false before target projection, already-state handling, and runner. Later ownership is limited to task 5 positive E2E and tasks 6.1/6.2/6.3 m1/BF8/secondary ceremony/archive/proven flip work.

### Non-Goals

- Any additional product, schema, generated Swift, runner, store, revision, or TTS work beyond the implemented T2 negative mechanics for tasks 2/3/4.
- Any positive receipt, probe, BF8 ceremony, archive, m1 work, or `proven=true`.
- Any runtime-action-readback v2 expansion or primary matrix change.

## Key Decisions

### D-001: Exact admission

The only admissible customer phrase is the exact string `关闭空调`. Aliases (`关空调`, `关掉空调`), fuzzy matches, indirect wording, and compound or multi-intent text MUST fail closed without invoking `close_ac`.

### D-002: Frame 甲 binding

The semantic frame is `set_vehicle_control / power_off` with value `off`. T2 specifies the binding only; it does not execute a state mutation or emit a success readback.

### D-003: Typed identity

Identity is the discriminated union `primaryMatrix(Int) | secondaryTool(String)`. For this capability, the identity is `secondaryTool("close_ac")`; `matrixID` is nil. `0`, `1`, and `121` are invalid sentinels. A primary identity uses an integer ID and may carry exactly one integer `matrix_ids` value.

### D-004: Canonical typed receipt root

The canonical root uses snake-case `subject_type` and `subject_id`:

- primary: integer `subject_id` plus singleton integer `matrix_ids`;
- secondary: string `subject_id` equal to `close_ac`, with `matrix_ids` absent (a null field is invalid).

`subjectType`, `subjectID`, `secondary_tool_id`, nested subject aliases, and other alternate/camel fields are invalid. The exact m4 discriminator-less path+bytes form remains the sole legacy exception.

### D-005: Matrix sibling and invariants

The matrix root contains a sibling object:

```json
"secondary_tools": {
  "close_ac": {
    "mounted_status": "mounted",
    "customer_admitted": true,
    "proven": false,
    "proven_basis": "pending BF8 shape"
  }
}
```

This object is never inside cells or summary data. The matrix remains 120 cells; primary `[4]=1/120` is unchanged. T2 does not mint or validate a positive secondary receipt.

### D-006: T2 negative mechanics

When the secondary capability is unproven, the admission path returns a typed refusal and stops before target projection, already-state handling, runner, store, revision, or TTS. It emits no secondary receipt, probe, BF8 ceremony, positive readback, or `proven=true`. The secondary matrix ID remains nil.

### D-007: Implemented projection and guard; later ceremony

Wave1 implemented and gate-observed generated Swift projection of top-level `secondaryTools`. Wave2 implemented and gate-observed F4 consumption of `secondaryTools[close_ac].proven`, treating missing/unknown as false before target projection, already-state handling, and runner. Only task 5 positive E2E and tasks 6.1/6.2/6.3 m1/BF8/secondary ceremony/archive/proven flip work remain unchecked and blocked/later-owned.

## Risks & Trade-offs

| Risk | Mitigation |
|---|---|
| Admission broadens accidentally | Exact literal comparison; all aliases, fuzzy, and compound inputs fail closed. |
| Secondary identity contaminates primary accounting | Typed union, nil secondary matrix ID, root-sibling placement, and unchanged 120-cell primary matrix. |
| A refusal is mistaken for proof | T2 forbids receipts, probes, ceremonies, readbacks, and proven flips. |
| Legacy receipts are over-generalized | Keep only the exact m4 discriminator-less path+bytes exception. |

## Migration & Implementation Plan

1. Task 1 remains the completed historical OpenSpec scaffold provenance.
2. Tasks 2/3/4 implement only T2 negative mechanics; their behavior is gate-observed and recorded here.
3. Task 5 and tasks 6.1/6.2/6.3 remain later, unchecked, block-labeled owners; they are not performed by T2.

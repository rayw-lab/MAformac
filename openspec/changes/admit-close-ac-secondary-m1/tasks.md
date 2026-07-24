# Tasks: admit-close-ac-secondary-m1

- [x] **1. OpenSpec Spec & Design Scaffold (historical provenance)** <!-- id: 0 -->
  - [x] 1.1 Preserve the original scaffold provenance for `proposal.md`, including the exact phrase boundary, Frame 甲 intent, and secondary-accounting isolation <!-- id: 1 -->
  - [x] 1.2 Preserve the original `design.md` decision record as the source history while amending it to the frozen T2 contract <!-- id: 2 -->
  - [x] 1.3 Preserve the original delta-spec artifact path and rewrite its requirements to the frozen T2 GIVEN/WHEN/THEN contract <!-- id: 3 -->
  - [x] 1.4 Validate change structure with strict OpenSpec validation <!-- id: 4 -->

- [x] **2. Receipt Shape Negative Mechanics (T2 only; implementation gates observed)** <!-- id: 5 -->
  - [x] 2.1 Reject nested subject objects and alternate/camel fields (`subjectType`, `subjectID`, `secondary_tool_id`) <!-- id: 6 -->
    - Evidence: OpenSpec strict validate passed; Wave1 py_compile passed; Python suites passed (97 total: receipt 36, matrix 61); `make verify-bf8-receipt-set`, `make verify-c1-matrix`, and `make verify-c1-matrix-canonical` passed.
  - [x] 2.2 Enforce typed identity `primaryMatrix(Int) | secondaryTool(String)`; reject a secondary `matrixID` and all `0`/`1`/`121` sentinel IDs <!-- id: 7 -->
    - Evidence: Wave2 `DemoSliceAdmissionCatalogTests` 12, `DemoSliceProductBehaviorGateTests` 32, `RuntimeTurnReceiptDigestTests` 6, and `RuntimeTurnReceiptSchemaTests` 6 passed; typed identity is `primaryMatrix(Int)|secondaryTool(String)` with secondary `matrixID` nil.
  - [x] 2.3 Enforce canonical root snake fields: primary integer `subject_id` plus singleton integer `matrix_ids`; secondary string `subject_id=close_ac` with `matrix_ids` absent, where null is invalid <!-- id: 8 -->
    - Evidence: Wave1 receipt/matrix gates passed; canonical root uses snake `subject_type`/`subject_id`, primary singleton integer `matrix_ids`, and secondary `subject_id=close_ac` with `matrix_ids` absent.
  - [x] 2.4 Preserve the exact m4 discriminator-less path+bytes route as the sole legacy exception; emit no positive secondary receipt, BF8 ceremony, or proven flip <!-- id: 9 -->
    - Evidence: Structural and Wave2 gates passed; registry is canonical m4 only, with no positive `close_ac` proof, m1, archive, BF8 ceremony, or `proven=true`.

- [x] **3. Secondary Matrix Negative Mechanics (T2 only; implementation gates observed)** <!-- id: 10 -->
  - [x] 3.1 Keep `secondary_tools.close_ac` as a matrix-root sibling with `mounted_status=mounted`, `customer_admitted=true`, `proven=false`, and pending BF8-shape basis <!-- id: 11 -->
    - Evidence: Structural facts show `secondary_tools.close_ac` mounted/customer_admitted true/proven false with pending BF8-shape basis.
  - [x] 3.2 Reject placement inside cells or summary data; preserve 120 cells and primary `[4]=1/120` unchanged <!-- id: 12 -->
    - Evidence: Structural facts show 120 cells and primary `actionDemoProven` IDs `[4]`, with no secondary placement in cells or summary data.
  - [x] 3.3 Keep secondary `matrixID` nil and reject any attempt to increment or derive primary `actionDemoProven` from `close_ac` <!-- id: 13 -->
    - Evidence: Structural facts and `DemoCapabilityMatrixGeneratedTests` passed; secondary `matrixID` is nil and primary `[4]=1/120` remains unchanged.
    - Wave1 generated Swift top-level `secondaryTools` projection was implemented and gate-observed.

- [x] **4. Admission and Execution Refusal Mechanics (T2 only; implementation gates observed)** <!-- id: 14 -->
  - [x] 4.1 Admit only exact `关闭空调`; aliases, fuzzy, indirect, and compound utterances fail closed without invoking `close_ac` <!-- id: 15 -->
    - Evidence: Wave2 `DemoSliceClassificationTests` 29, `DemoSliceRouteTests` 7, and `FahrenheitAdmissionTests` 11 passed; only exact `关闭空调` is admitted.
  - [x] 4.2 Bind the specified Frame 甲 semantics (`set_vehicle_control/power_off`, value `off`) without executing a runtime action or expanding runtime-action-readback v2 <!-- id: 16 -->
    - Evidence: Wave2 `DemoSliceAdmissionCatalogTests` 12 and `DemoSliceProductBehaviorGateTests` 32 passed; Frame 甲 binding is `set_vehicle_control/power_off`, value `off`.
  - [x] 4.3 When `proven=false`, return typed refusal before target projection, already-state handling, runner, store, revision, and TTS; emit no positive receipt, probe, BF8 ceremony, readback, or `proven=true` <!-- id: 17 -->
    - Evidence: Wave2 `RuntimeTurnReceiptDigestTests` 6, `RuntimeTurnReceiptSchemaTests` 6, and `FahrenheitAdmissionTests` 11 passed; refusal remains negative-only with no positive receipt/probe/BF8 ceremony/readback or `proven=true`.
    - Wave2 F4 read of `secondaryTools[close_ac].proven` was implemented and gate-observed; missing/unknown is false before target projection, already-state handling, and runner.

- [ ] **5. Scoped E2E Probe for `close_ac` (BLOCKED; later owner unchanged)** <!-- id: 18 -->
  - [ ] 5.1 Create `probe.action.close_ac.zh-CN` end-to-end probe <!-- id: 19 -->
  - [ ] 5.2 Write the probe program to assert text admission → `close_ac` invocation → `ac.power` OFF → readback confirmation <!-- id: 20 -->

- [ ] **6. Ceremonial Sequence & BF-8 Verification (OPEN-Q1=A; BLOCKED; later owner unchanged)** <!-- id: 21 -->
  - [ ] 6.1 Confirm matrix_id=1 (`open_ac`) E1 probe and BF-8 authorization ceremony are complete <!-- id: 22 -->
  - [ ] 6.2 Sign the independent `bf8_promotion_receipt_v1` for `close_ac` with the canonical typed secondary subject <!-- id: 23 -->
  - [ ] 6.3 Verify `secondary_tools.close_ac.proven` flips to true while `actionDemoProven` remains isolated <!-- id: 24 -->

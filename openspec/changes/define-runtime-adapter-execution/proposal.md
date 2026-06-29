## Why

D11 left `C061` as a future runtime adapter boundary and `C005` as current local mock executor/store ownership only. D12 added standalone Runtime Adapter V0 local/unit code-backed proof, but it did not put the adapter on the `C3ExecutionPipeline` execution path.

This change creates the mainline Runtime Adapter V0 execution authority for stable command identity, in-memory idempotency ledger behavior, adapter-owned mock writes, retry replay, proof-class limits, and the D13 C3 integration boundary. The C3 integration is still local/unit proof only.

D18 extends that authority to a local file-backed durability slice for adapter ledger reconstruction. The D18 slice may prove `local_durable_adapter_ledger` only when local tests reconstruct successful adapter/C3 replay state across a new adapter or pipeline using deterministic temporary-directory storage. It is not production durable runtime proof.

## What Changes

- Add a `runtime-adapter-execution` capability for local/unit Runtime Adapter V0.
- Define a stable command identity and request fingerprint contract.
- Define an in-memory retry/idempotency ledger for demo/local scope.
- Define adapter-owned mock writes through `DemoVehicleStateStore.applyMockTransition`.
- Define first execution, retry replay, already-state no-op, parameter mismatch, and failed command behavior.
- Define trace/readback provenance for first execution, replay, and already-state outcomes.
- Define how `C3ExecutionPipeline` routes planned mock transitions through Runtime Adapter V0.
- Define per-transition command identity derivation from an existing parent `ToolCallFrame.id` without editing `ToolCallFrame`.
- Define that C3 may construct adapter-local `set_vehicle_control` frames from planned transitions, while keeping adapter provenance internal to main.
- Define the D14 residual slice: session-scoped ledger boundary, exact stale retry ordering, failure ledger taxonomy, readback reconciliation, and `RuntimeAdapterBox` concurrency boundary.
- Define the D18 durability slice: file-backed local ledger storage, cross-adapter/cross-pipeline reconstruction, corrupt/unknown-entry fail-closed behavior, partial/failure replay semantics, and private-ledger no-leak boundary.
- Preserve local/unit/OpenSpec proof cap and non-claims.

## Capabilities

### New Capabilities

- `runtime-adapter-execution`: deterministic local runtime adapter boundary for mock writes and retry/idempotency proof.

### Modified Capabilities

- None. The existing `runtime-presentation-bridge` remains presentation/snapshot authority, not the execution adapter.

## Impact

- Affected OpenSpec:
  - `openspec/changes/define-runtime-adapter-execution/`
- Intended future Swift surfaces for Gate 2:
  - `Core/Execution/C3ExecutionPipeline.swift`
  - `Tests/MAformacCoreTests/DemoRuntimeAdapterTests.swift`
  - `Tests/MAformacCoreTests/C3ExecutionPipelineTests.swift`
- Existing candidate surfaces:
  - `Core/Execution/DemoRuntimeAdapter.swift`
  - `Core/Execution/DemoActionExecutor.swift`
  - `Core/State/DemoVehicleStateStore.swift`
  - `Core/Routing/ToolCallFrame.swift`
- No UIUE code.
- No production runtime adapter, persistent ledger, cloud sync, mobile proof, true-device proof, UIUE merge, V-PASS, S-PASS, U-PASS, or A-2 claim.
- No UIUE consumption of durable ledger rows, request fingerprints, parent fingerprints, failure ledgers, success ledger internals, settled parent-plan internals, raw private payload, adapter-local provenance, raw runtime store, raw model output, or training receipts.

## Non-goals

- Do not implement Swift in Gate 1.
- Do not edit `ToolCallFrame` for D13 C3 integration.
- Do not expose Runtime Adapter V0 provenance or private fields as a UIUE-facing payload contract.
- Do not define `C018` SceneMacroRegistry/Core config.
- Do not implement `C052` production force-state.
- Do not create persistent database/cloud idempotency storage.
- Do not claim session-scoped ledger behavior as durable/persistent ledger proof.
- Do not claim D18 local file-backed storage as production durable runtime, mobile, true-device, live, cloud, or cross-device proof.
- Do not expose durable ledger internals as presentation payload fields or UIUE shared fields.
- Do not expose new UIUE shared fields in Gate 1.
- Do not create a UIUE-facing runtime presentation payload contract in D14.
- Do not claim runtime-ready, mobile-ready, true-device-ready, voice-ready, model-ready, golden-ready, endpoint-ready, merge-ready, or R5 complete.

## Success Criteria

- `openspec validate define-runtime-adapter-execution --strict` passes.
- `openspec validate --all --strict` passes.
- `git diff --check` passes.
- Gate 2 can reduce Runtime Adapter residuals with local/unit or local/integration tests for session-scoped ledger reset, exact stale retry ordering, failure ledger taxonomy, readback reconciliation, and `RuntimeAdapterBox` concurrency boundary.
- D18 Gate 2 can prove local file-backed adapter ledger reconstruction across a new `DemoRuntimeAdapter` using temporary-directory storage, deterministic fixtures, fail-closed corrupt-entry handling, and no UIUE/private-payload exposure.
- D18 Gate 3 can prove local C3 cross-pipeline reconstruction only after Gate 2 exists, without exposing `RuntimeAdapterBox`, fingerprints, durable ledger rows, or failure ledgers outside main.
- The receipt records pre-mortem, local/web cross-search, iceberg teardown, GitNexus impact expectations for later Swift gates, audit cadence, and D18 proof caps.

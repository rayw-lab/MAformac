## Why

D11 left `C061` as a future runtime adapter boundary and `C005` as current local mock executor/store ownership only. Main now needs a minimal contract authority before Swift implementation so D12 can add code-backed local/unit proof without turning it into production runtime readiness.

This change creates the mainline Runtime Adapter V0 execution authority for stable command identity, in-memory idempotency ledger behavior, adapter-owned mock writes, retry replay, and proof-class limits.

## What Changes

- Add a `runtime-adapter-execution` capability for local/unit Runtime Adapter V0.
- Define a stable command identity and request fingerprint contract.
- Define an in-memory retry/idempotency ledger for demo/local scope.
- Define adapter-owned mock writes through `DemoVehicleStateStore.applyMockTransition`.
- Define first execution, retry replay, already-state no-op, parameter mismatch, and failed command behavior.
- Define trace/readback provenance for first execution, replay, and already-state outcomes.
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
  - `Core/Execution/DemoRuntimeAdapter.swift`
  - `Tests/MAformacCoreTests/DemoRuntimeAdapterTests.swift`
- Existing candidate surfaces:
  - `Core/Execution/DemoActionExecutor.swift`
  - `Core/Execution/C3ExecutionPipeline.swift`
  - `Core/State/DemoVehicleStateStore.swift`
- No UIUE code.
- No production runtime adapter, persistent ledger, cloud sync, mobile proof, true-device proof, UIUE merge, V-PASS, S-PASS, U-PASS, or A-2 claim.

## Non-goals

- Do not implement Swift in Gate 1.
- Do not define `C018` SceneMacroRegistry/Core config.
- Do not implement `C052` production force-state.
- Do not create persistent database/cloud idempotency storage.
- Do not expose new UIUE shared fields in Gate 1.
- Do not claim runtime-ready, mobile-ready, true-device-ready, voice-ready, model-ready, golden-ready, endpoint-ready, merge-ready, or R5 complete.

## Success Criteria

- `openspec validate define-runtime-adapter-execution --strict` passes.
- `openspec validate --all --strict` passes.
- `git diff --check` passes.
- Gate 2 can implement Runtime Adapter V0 with local/unit tests for command identity, retry replay, failed command behavior, and adapter-owned mock write path.
- The receipt records pre-mortem, local/web cross-search, iceberg teardown, and D12 proof caps.

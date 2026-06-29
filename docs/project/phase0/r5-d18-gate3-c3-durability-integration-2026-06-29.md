# R5 D18 Gate 3 C3 Durability Integration

Date: 2026-06-29
Label: `D18_GATE_3_C3_RECONSTRUCTION_INTEGRATION_TESTS`
Repo: `/Users/wanglei/workspace/MAformac`
Proof class: `local` / `unit` / `integration` / `static`
Status: `DONE_PENDING_COMMIT_AND_HERMES_ROUND_1`

## Conclusion

Gate 3 connects the Gate2 local durable adapter ledger to C3 enough to prove local cross-pipeline reconstruction. A reconstructed `C3ExecutionPipeline` can replay a settled stale parent request from explicit local durable state without mutating the store.

This is still `local_durable_adapter_ledger` proof only. It is not production durable runtime, mobile, true-device, live API, UIUE merge, V-PASS, S-PASS, U-PASS, A-2, voice/model/golden/endpoint readiness, or R5 completion proof.

## Scope Contract

| Item | Contract |
| --- | --- |
| Goal | Prove C3 local cross-pipeline settled parent replay using explicit durable local storage. |
| Non-goals | No UIUE writes, no presentation payload expansion, no public durable API, no production runtime readiness. |
| Scope in | `C3ExecutionPipeline.swift`, C3 tests, OpenSpec task ledger, this receipt. |
| Scope out | UIUE repo, dispatch source docs, D19 consumer guard, production/mobile/live surfaces. |
| Writable paths | Gate3 owned paths only. |
| Stop conditions | Unexplained GitNexus HIGH/CRITICAL, target tests fail, stale changed requests mutate state, corrupt/missing durable rows replay, private fields leak to presentation/UIUE. |

## Implementation

- Added private schema-versioned `C3SettledPlanSnapshot` for settled parent-plan reconstruction.
- Added private file-backed C3 settled plan store, separated from the adapter ledger file.
- Added internal C3 initializer that accepts `localDurableLedgerDirectory` and wires:
  - `adapter/` to `FileBackedDemoRuntimeAdapterLedgerStore`;
  - `c3/` to private `FileBackedC3SettledPlanStore`.
- Kept public `C3ExecutionPipeline` initializer behavior unchanged.
- Kept `RuntimeAdapterBox` private and `@unchecked Sendable`, with adapter resolution still inside `@MainActor` execution.
- If C3 settled-plan durable state is corrupt/unsupported, C3 declines stale replay and falls back to the existing stale-state guard.

## Tests Added

- `testC3DurableReconstructionReplaysSettledParentWithoutSecondWrite`
- `testC3DurableChangedParentFingerprintFallsBackToStaleGuardBeforeMutation`
- `testC3DurableMissingAdapterEntryFailsClosedBeforeMutation`
- `testC3DurableCorruptAdapterEntryFailsClosedBeforeMutation`
- `testC3DurableReadbackDriftFailsClosedWithoutRepairWrite`

## GitNexus

| Probe | Result |
| --- | --- |
| `node .gitnexus/run.cjs analyze` | PASS; index refreshed, 28,201 nodes / 50,068 edges / 300 flows. |
| `context(C3ExecutionPipeline)` | Found `Core/Execution/C3ExecutionPipeline.swift`; direct test helper callers. |
| `impact(C3ExecutionPipeline, upstream, includeTests)` | `MEDIUM`: 32 impacted, 4 direct, modules `MAformacCoreTests` and `Execution`. |
| `context(RuntimeAdapterBox)` | Found private class in `C3ExecutionPipeline.swift`; constructed by C3 init. |
| `impact(RuntimeAdapterBox, upstream, includeTests)` | `CRITICAL`: 55 direct, 0 affected processes reported. |
| `impact(DemoRuntimeAdapter, upstream, includeTests)` | `CRITICAL`: 96 impacted, 69 direct, affected process `replaySettledStaleRequestIfAvailable`. |
| `detect_changes(scope=staged)` | `medium`: 43 changed symbols, 5 affected replay processes, 4 changed files. |

Interpretation: the CRITICAL results are expected because Gate3 intentionally edits the private C3 adapter reuse/replay boundary. Mitigation is internal-only injection, unchanged public initializer behavior, explicit fail-closed tests, and no UIUE/presentation schema changes.

## Local Repo Cross-Search

| Evidence | Finding |
| --- | --- |
| Existing C3 stale replay tests | D14 semantics already require exact parent fingerprint and readback reconciliation before stale replay. |
| `DemoRuntimeAdapterTests` | Gate2 already proves cross-adapter durable replay and corrupt/unknown schema fail-closed. |
| `RuntimePresentationBridgeTests` | Private adapter markers stay redacted from presentation payload. |
| `C3ExecutionPipeline.swift` | `RuntimeAdapterBox` remains private; public C3 initializer remains unchanged. |

## Pre-Mortem

Gate3 can fail by reconstructing parent plans without matching parent fingerprint, by replaying from C3 state when adapter durable rows are missing, by treating corrupt adapter rows as absence and then mutating through a stale request, by repairing readback drift with a write, or by exposing C3 parent fingerprints/settled plans to UIUE.

The actual pitfall hit was a Swift explicit return omission in `settledPlan(parentID:)`; it was caught by the first compile and fixed before validation.

## Iceberg Teardown

| Layer | Finding |
| --- | --- |
| Visible symptom | C3 stale replay was previously confined to one pipeline/box lifetime. |
| Underlying class | Parent-plan replay authority and adapter replay authority must both survive reconstruction, or stale replay becomes either unavailable or unsafe. |
| Same-class risk map | main: C3 parent plan outlives adapter rows; UIUE: parent fingerprints leak; runtime: drifted store is overwritten; proof: local durable proof becomes production claim; governance: CRITICAL graph risk ignored. |
| Immediate fix | Separate schema-versioned C3 settled plan store plus adapter durable store, both explicit and local. |
| Class-level fix | Tests cover reconstructed replay, changed parent request, missing/corrupt adapter rows, readback drift, and D14 stale replay regressions. |
| Governance fix | Hermes round 1 audits Gates 1-3 before D19 can start. |

## Metacognitive Reflection

The key reasoning trap is to persist only the adapter ledger and assume C3 can recompute the same parent plan later. That fails for stale/current-relative requests where the current store would change the plan. Gate3 therefore persists only the parent settled plan needed for replay, while still requiring adapter fingerprint and readback reconciliation.

## Goal-Drift Check

Gate3 stayed main-only and C3/local-integration scoped. It did not write UIUE, change presentation payload fields, expose private durable names, or claim runtime/mobile/live readiness.

## Claim vs Proof

| Claim | Evidence | Proof cap |
| --- | --- | --- |
| Reconstructed C3 pipeline can replay settled parent request without mutation | `testC3DurableReconstructionReplaysSettledParentWithoutSecondWrite` PASS | `local/integration` |
| Changed parent fingerprint fails before mutation | `testC3DurableChangedParentFingerprintFallsBackToStaleGuardBeforeMutation` PASS | `local/integration` |
| Missing adapter durable row does not authorize stale replay | `testC3DurableMissingAdapterEntryFailsClosedBeforeMutation` PASS | `local/integration` |
| Corrupt adapter durable row fails closed | `testC3DurableCorruptAdapterEntryFailsClosedBeforeMutation` PASS | `local/integration` |
| Readback drift is not repaired by write | `testC3DurableReadbackDriftFailsClosedWithoutRepairWrite` PASS | `local/integration` |
| Production durable runtime works | Not claimed. | none |

## Non-Claims

- no production durable ledger proof
- no runtime/mobile/true-device/live proof
- no UIUE merge or UIUE runtime consumer proof
- no V-PASS, S-PASS, U-PASS, A-2, voice-ready, model-ready, golden-ready, endpoint-ready, or R5 complete claim
- no new UIUE shared fields

## Boundary Check

C3 durable settled parent plans, parent fingerprints, adapter request fingerprints, adapter ledger rows, durable paths, failure ledgers, raw private payloads, raw runtime store markers, raw model output, and training receipts remain private main implementation details. UIUE may only consume later deny-list/proof-governance authority, not these internals.

## Self-Question

If this were wrong, `Tests/MAformacCoreTests/C3ExecutionPipelineTests.swift` would show stale changed requests mutating, missing/corrupt adapter rows replaying, readback drift being repaired by write, or `Core/Execution/C3ExecutionPipeline.swift` would expose parent fingerprints through a public/UIUE-facing type.

## Post-Audit Correction Rule

Hermes round 1 must audit Gates 1-3 after this gate. P0/P1 findings block D19 until fixed and revalidated. Any fail-fixed evidence must be recorded as fail-fixed, not clean Hermes PASS.

## Validation

| Command | Result | Proof class |
| --- | --- | --- |
| `git diff --check` | PASS | `local/static` |
| `swift test --filter 'DemoRuntimeAdapterTests|C3ExecutionPipelineTests|VehicleStateStoreContractTests|RuntimePresentationBridgeTests'` | PASS: 62 tests, 0 failures | `local/unit/integration` |
| `openspec validate define-runtime-adapter-execution --strict` | PASS: change is valid | `local/OpenSpec` |
| `openspec validate --all --strict` | PASS: 18 passed, 0 failed | `local/OpenSpec` |
| `git diff --cached --check` | PASS | `local/static` |
| GitNexus `detect_changes(scope=staged)` | PASS with expected `medium` risk: 43 changed symbols, 5 affected replay processes, 4 changed files | `local/static/graph` |

## Dirty Split

Expected preserved main dirty remains excluded:

- `AGENTS.md`
- `CLAUDE.md`
- `docs/CURRENT.md`
- `docs/README.md`
- `.xcodebuildmcp/`
- `Tools/agent-platform-plugin-refs/`

Owned Gate3 paths:

- `Core/Execution/C3ExecutionPipeline.swift`
- `Tests/MAformacCoreTests/C3ExecutionPipelineTests.swift`
- `openspec/changes/define-runtime-adapter-execution/tasks.md`
- `docs/project/phase0/r5-d18-gate3-c3-durability-integration-2026-06-29.md`

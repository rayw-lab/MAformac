---
retire_trigger: "Retire when superseded by archived OpenSpec specs or explicit user decision."
expires: "2026-08-15"
---

# R5 D13 Gate 2 - C3 Runtime Adapter Integration Code

Date: 2026-06-29
Gate: 2 of 4
Label: `D13_GATE_2_C3_INTEGRATION`
Proof class: `local` / `unit` / `OpenSpec` / `GitNexus`
Scope: main `C3ExecutionPipeline` integration and targeted tests

## Verdict

Candidate status after local validation and before Hermes: `LOCAL_READY_FOR_HERMES`.

Gate 2 wires Runtime Adapter V0 into the main `C3ExecutionPipeline` local execution path for supported planned mock transitions. This is local/unit proof only. It does not create persistent ledger proof, mobile proof, true-device proof, UIUE payload contract, UIUE merge, or readiness/pass-label claims.

## Dirty Split Before Gate 2 Writes

Main repo after Gate 1 commit:

```text
## codex/rebuild-c6-doc-absorption-20260624...origin/codex/rebuild-c6-doc-absorption-20260624 [ahead 11]
 M AGENTS.md
 M CLAUDE.md
 M docs/CURRENT.md
 M docs/README.md
?? .xcodebuildmcp/
?? Tools/agent-platform-plugin-refs/
HEAD 199a12c1596579866eb09f21ab2601869322deea
```

UIUE repo remained read-only for Gate 2:

```text
## uiue/phase4-default-scope-presentation...origin/uiue/phase4-default-scope-presentation [ahead 75]
?? docs/dispatches/2026-06-29-uiue-r5-d12-runtime-adapter-v0-code-train-dispatch.md
?? docs/dispatches/2026-06-29-uiue-r5-d13-c3-runtime-adapter-integration-dispatch.md
HEAD e47a16355bf5f1fb3dfc15cd2bfa79522cc00d7c
```

No preserve-unowned main paths were edited.

## Gate 1 Authority Reconfirmed

Gate 1 committed `199a12c1596579866eb09f21ab2601869322deea` with Hermes anchor `HERMES_R5_D13_GATE_1_C3_AUTHORITY_VERDICT: PASS` and `findings_P0_P1: []`.

Relevant Gate 1 decisions applied here:

- `ToolCallFrame.id` is the parent identity, not the adapter ledger identity for every transition.
- C3 derives per-transition adapter ids as `<ToolCallFrame.id>#<transition.key>`.
- C3 constructs adapter-local `set_vehicle_control` frames with `state_key` and `target_state`.
- D13 does not edit `ToolCallFrame`.
- Adapter provenance remains internal to main.

## GitNexus And Impact

GitNexus was refreshed after Gate 1 commit:

```text
Repository indexed successfully
27,665 nodes | 48,732 edges | 990 clusters | 300 flows
indexed HEAD 199a12c1596579866eb09f21ab2601869322deea
```

Pre-edit impact:

| target | touched | risk | result |
| --- | --- | --- | --- |
| `C3ExecutionPipeline` | yes | LOW | 25 impacted symbols, 0 affected processes. |
| `DemoRuntimeAdapter` | no | CRITICAL from Gate 1 | Not edited. Existing adapter API used as-is. |
| `DemoVehicleStateStore.applyMockTransition` | no | MEDIUM from Gate 1 | Not edited. |
| `ToolCallFrame` | no | HIGH from Gate 1 | Not edited. Existing `ToolCallFrame(arguments:)` initializer used. |

No extra subagent audit was required for Gate 2 because no HIGH/CRITICAL symbol was touched.

## Code Changes

Changed Swift files:

- `Core/Execution/C3ExecutionPipeline.swift`
- `Tests/MAformacCoreTests/C3ExecutionPipelineTests.swift`

Implementation summary:

- Added private `RuntimeAdapterBox` inside `C3ExecutionPipeline.swift`.
- `RuntimeAdapterBox` lazily creates and reuses `DemoRuntimeAdapter` on `MainActor`, preserving adapter ledger state across repeated `pipeline.execute` calls without making the public C3 initializer `@MainActor`.
- C3 execution loop now derives `commandID = "<parent frame id>#<transition.key>"`.
- C3 creates adapter-local `ToolCallFrame(arguments:)` with `toolName = "set_vehicle_control"`, `state_key`, and `target_state`.
- C3 calls `DemoRuntimeAdapter.execute(...)` for the write side effect, then keeps C2 readback verification and C2 readback text rendering.
- Execute trace message now includes adapter provenance internally; `C3ExecutionResult` remains unchanged.
- No `ToolCallFrame`, `DemoRuntimeAdapter`, or store semantics were edited.

## Test Coverage Added

New `C3ExecutionPipelineTests` coverage:

- C3 retry replay uses adapter ledger without second write.
- Same command identity with changed request fails closed.
- Per-transition identity lets fanout execute without ledger conflicts.
- Adapter failure for missing store cell does not create fake success ledger; retry after repairing store can execute.

The existing C3 already-state test still passes and continues to prove no revision bump for already-state behavior.

## Local Validation

```text
swift test --filter 'C3ExecutionPipelineTests|DemoRuntimeAdapterTests|VehicleStateStoreContractTests|RuntimePresentationBridgeTests'
PASS
Executed 43 tests, with 0 failures.

git diff --check
PASS

openspec validate define-runtime-adapter-execution --strict
Change 'define-runtime-adapter-execution' is valid

openspec validate --all --strict
Totals: 17 passed, 0 failed (17 items)
```

## Harness

Lesson learned: wiring the adapter by putting `DemoRuntimeAdapter` directly in `C3ExecutionPipeline.init` made the initializer `@MainActor` and broke existing nonisolated test helpers. The corrected shape keeps initialization nonisolated and resolves the adapter on `MainActor` only inside execution.

Goal-drift check: Gate 2 implements C3 local/unit integration only. It does not define UIUE fields, persistent ledger, or runtime/mobile/true-device proof.

Authority check: Gate 2 follows Gate 1 OpenSpec: per-transition identities, adapter-local frames, no `ToolCallFrame` schema edit, and internal provenance.

Claim-vs-proof: proof class is local/unit/OpenSpec/GitNexus only.

Boundary check: UIUE is read-only. Main preserve-unowned dirty files remain untouched. `DemoRuntimeAdapter`, `ToolCallFrame`, and store semantics are not edited.

Self-question: Could the test pass while C3 still writes directly to store? The new conflict and retry tests depend on adapter ledger semantics. Direct store writes would not throw `DemoRuntimeAdapterError.idempotencyConflict` for reused command identity with changed desired value.

Post-Hermes correction rule: if Hermes returns any P0/P1, missing anchor, timeout, or evidence gap, Gate 2 is not done. If Hermes returns P2/lower, run pitfall loop and update candidate content only when needed, then rerun validation and Hermes if the candidate changes.

## Pitfall Loop

### Pitfall: MainActor Initializer Drift

Trigger: first targeted test run failed to compile after the first implementation made `C3ExecutionPipeline.init` `@MainActor`.

Local search:

- `DemoRuntimeAdapter` is `@MainActor` because it writes `DemoVehicleStateStore`.
- `C3ExecutionPipeline` existing initializer is used by multiple test helpers in `C3ExecutionPipelineTests`, `C3ReadbackTemplateTests`, `C3AllowlistPrimitiveGateTests`, and `C3TraceAttributesTests`.
- `C3ExecutionPipeline` is currently `Sendable`, so a reusable adapter reference needs an explicit concurrency boundary.

Web cross-search:

- Apple Swift `Sendable` documentation notes that types with nonsendable stored properties can require `@unchecked Sendable`: `https://developer.apple.com/documentation/swift/sendable`.
- Swift Evolution SE-0327 clarifies actor initializer isolation boundaries: `https://github.com/apple/swift-evolution/blob/main/proposals/0327-actor-initializers.md`.

Iceberg teardown:

- Visible symptom: `call to main actor-isolated initializer ... in a synchronous nonisolated context`.
- Underlying class: integrating a MainActor-bound execution component can leak actor isolation into unrelated construction paths.
- Immediate fix: use a private `RuntimeAdapterBox` with MainActor-isolated adapter resolution inside `execute`.
- Class fix: keep MainActor effects at execution boundary, not construction boundary, unless the public API deliberately changes.
- Governance fix: Gate 2 tests must include compile/build proof, not only code review.

Candidate change required: yes; implemented `RuntimeAdapterBox` and reran targeted tests successfully.

### Pitfall: Unstaged GitNexus Detect Noise

Trigger: Hermes Gate 2 first pass returned PASS with empty P0/P1, but noted a P2 where `detect_changes(scope=unstaged)` can report HIGH because pre-existing preserve-unowned dirty files are present in the worktree.

Local search:

- `git status --short --branch` shows pre-existing dirty `AGENTS.md`, `CLAUDE.md`, `docs/CURRENT.md`, `docs/README.md`, `.xcodebuildmcp/`, and `Tools/agent-platform-plugin-refs/`.
- Candidate-owned Gate 2 paths are limited to `Core/Execution/C3ExecutionPipeline.swift`, `Tests/MAformacCoreTests/C3ExecutionPipelineTests.swift`, `openspec/changes/define-runtime-adapter-execution/tasks.md`, and this receipt.
- Candidate-owned runtime diff does not include `DemoRuntimeAdapter`, `ToolCallFrame`, `DemoVehicleStateStore`, or `DemoActionExecutor`.

Web cross-search:

- Git documentation defines pathspec-based staging and supports selecting exact files for index content: `https://git-scm.com/docs/git-add`.
- Git documentation defines cached diff checks against the index, which is the relevant pre-commit surface here: `https://git-scm.com/docs/git-diff`.

Iceberg teardown:

- Visible symptom: unstaged graph detect can report high risk from unrelated dirty state.
- Underlying class: dirty worktree risk can be confused with candidate risk when a gate uses broad unstaged analysis.
- Immediate fix: use exact pathspec staging and `detect_changes(scope=staged)` before commit.
- Class fix: Gate receipts must split candidate-owned changes from preserve-unowned dirty state.
- Governance fix: no `git add .`; commit only exact Gate 2 pathspecs.

Candidate change required: no code change. The staged detect is the authoritative pre-commit graph check for Gate 2.

Staged GitNexus detect result after exact pathspec staging:

```text
scope: staged
changed_files: 4
changed_count: 27
affected_count: 6
risk_level: high
affected_processes:
  - PlanTransitions -> Slots
  - PlanTransitions -> ScopeResolution
  - PlanTransitions -> IsCollectionAlias
  - PlanTransitions -> ExecutableScopes
  - PlanTransitions -> Entry
  - PlanTransitions -> DeviceCellMap
```

Interpretation: this HIGH is meaningful but expected because Gate 2 intentionally changes the C3 execution loop around planned transitions. It is not evidence of accidental edits to `ToolCallFrame`, `DemoRuntimeAdapter`, store semantics, or UIUE. A Codex native verifier audit was triggered before final Hermes rerun because the staged detect risk is HIGH.

Codex native verifier result:

- `status: DONE`
- P0/P1: none found.
- Verdict: staged GitNexus HIGH is real but expected and should not stop Gate 2 by itself.
- Evidence: staged code routes C3 planned transitions through `DemoRuntimeAdapter`; staged diff does not edit `ToolCallFrame`, `DemoRuntimeAdapter`, `DemoVehicleStateStore`, or `DemoActionExecutor`; targeted tests pass 43/43.
- P2 handled: staged receipt lagged behind worktree after adding the staged GitNexus HIGH paragraph. This was corrected by restaging the receipt before final checks.
- Residual: `RuntimeAdapterBox: @unchecked Sendable` remains acceptable for local/unit proof but must stay a broader runtime concurrency residual.

### Pitfall: Exact Stale Retry Remains Future

Trigger: Hermes Gate 2 first pass returned a P3 noting that C3 retry replay is proven only when the second attempt passes the C3 stale-state guard and reaches the adapter.

Local search:

- Gate 1 OpenSpec explicitly bounds retry replay proof to attempts that satisfy existing C3 safety gates before adapter execution.
- `testC3RetryReplayUsesAdapterLedgerWithoutSecondWrite` reuses the parent id with refreshed `stateRevision`.
- C3 stale-state guard still runs before transition planning and adapter execution.

Web cross-search:

- AWS safe retry guidance warns that late-arriving retries need explicit idempotency semantics and lifecycle decisions: `https://aws.amazon.com/builders-library/making-retries-safe-with-idempotent-APIs/`.
- IETF Idempotency-Key guidance treats idempotency as request-replay handling, but this gate remains local/unit and does not alter C3 stale-state policy: `https://datatracker.ietf.org/doc/html/draft-ietf-httpapi-idempotency-key-header`.

Iceberg teardown:

- Visible symptom: retry replay proof can be overread as exact stale retry support.
- Underlying class: one local/unit retry path can be mistaken for full retry lifecycle semantics.
- Immediate fix: keep exact stale retry in residual risks.
- Class fix: future persistent ledger/readback reconciliation work must decide ordering between stale-state checks and idempotent replay.
- Governance fix: no runtime-ready or retry-ready claim from this gate.

Candidate change required: no code change. The limitation is documented as a residual risk.

## Access Gaps And Residual Risks

- Adapter ledger remains in-memory and process-local.
- Exact stale retry replay can still be blocked before adapter execution by C3 stale-state checks; Gate 1 marked this future work.
- No runtime app run, simulator, mobile, true-device, or live proof was performed.
- UIUE still does not consume adapter private fields and still has no D13 payload contract.

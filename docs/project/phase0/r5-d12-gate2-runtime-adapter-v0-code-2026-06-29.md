---
status: DONE
artifact_kind: r5_d12_gate2_runtime_adapter_v0_code_receipt
created_at: 2026-06-29
gate: R5-D12-gate-2
openspec_change: define-runtime-adapter-execution
proof_class_ceiling: local_unit + local_static + openspec_contract
hermes_output: /Users/wanglei/workspace/MAformac/Reports/r5-d12-gate2-runtime-adapter-v0-20260629T105430/hermes-output.txt
non_claims:
  - no R5 complete
  - no runtime-ready
  - no mobile proof
  - no true_device proof
  - no voice-ready
  - no model-ready
  - no golden-ready
  - no endpoint-ready
  - no UIUE merge
  - no V-PASS
  - no S-PASS
  - no U-PASS
  - no A-2
  - no A-2 ready
  - no A-2 complete
retire_trigger: "Retire when superseded by archived OpenSpec specs or explicit user decision."
expires: "2026-08-15"
---

# R5 D12 Gate 2 - Runtime Adapter V0 Code

## Scope

Gate 2 adds the smallest mainline Runtime Adapter V0 code-backed proof for `C005` and `C061`.

The implemented boundary is local/unit only:

- stable command identity is supplied by caller as `commandID`;
- deterministic request fingerprint binds the write-affecting request shape;
- successful first execution writes through `DemoVehicleStateStore.applyMockTransition`;
- retry replay of the same `commandID` and fingerprint returns recorded readback without a second write;
- same `commandID` with a different fingerprint fails closed;
- unsupported or invalid inputs do not create successful ledger entries;
- already-state requests preserve no-op readback semantics.

## Metacognitive Harness

| check | result |
|---|---|
| Pre-mortem | Gate 2 could fake green by testing direct store mutation, by conflating already-state no-op with retry idempotency, by caching failures as successful replay, or by editing high-blast-radius symbols without authority. The implementation avoids those by adding a dedicated adapter and focused tests. |
| Lessons learned reflection | Gate 1 authority made the core mistake explicit: `C005` and `C061` needed a code boundary, not another receipt. The runtime V0 is deliberately narrow so it can be audited before integration into `C3ExecutionPipeline`. |
| Local + web cross-search | Local search found `C3ExecutionPipeline`, `DemoActionExecutor`, `DemoVehicleStateStore.applyMockTransition`, and `ToolCallFrame` as related surfaces; no existing command-id/retry ledger adapter was found. Web cross-search kept the request-identity pattern aligned with Stripe idempotency, AWS safe retries, and the IETF Idempotency-Key fingerprint pattern. |
| Iceberg teardown | Visible symptom: no adapter proof. Underlying risk: execution identity was implicit, so retries and UI readback could drift into ad hoc behavior. Same-class risks: retry double-write, stale readback replay, parameter-mismatch replay, fake success after failure, UIUE inventing shared fields. Fix: local/unit adapter plus explicit residual gates. |
| Goal-drift check | Goal: main Runtime Adapter V0 code and local/unit proof. Non-goals: production runtime, persistence, mobile/true-device proof, C018 config authority, C052 simulator force-state, UIUE implementation, merge/PR/push. |
| Authority check | Authority order for Gate 2: D12 dispatch, Gate 1 OpenSpec change, live code/tests, GitNexus impact/detect output, Hermes audit. Dated receipts remain context only. |
| Claim-vs-proof check | Claims are capped to local/unit + local_static + OpenSpec contract. No runtime-ready, mobile, true-device, V/S/U-PASS, A-2, or UIUE merge claim is made. |
| Boundary/no-touch check | Written paths are only `Core/Execution/DemoRuntimeAdapter.swift`, `Tests/MAformacCoreTests/DemoRuntimeAdapterTests.swift`, and this receipt. Existing preserve-unowned dirty paths stay unstaged. |
| Self-question before Hermes | If Gate 2 is wrong, either target tests should fail on retry/failure/no-op cases, OpenSpec should not validate, GitNexus staged detect should show unexpected blast radius, or Hermes should find proof overclaim. |
| Post-Hermes correction rule | If Hermes reports P0/P1, if validation/pathspec state changes after Hermes, or if any file changes after Hermes, stop Gate 2 and rerun validation plus Hermes before commit. |

## Pitfall Trigger Record

| trigger | result |
|---|---|
| `ToolCallFrame` GitNexus impact returned HIGH risk | Treated as a pitfall. I did not edit `ToolCallFrame`; the adapter consumes the existing type. The same class of risk was generalized as "shared frame/schema changes can silently affect routing, verification, and UIUE-facing assumptions." Gate 2 remains a new boundary plus tests. |
| GitNexus index staleness | `MAformac-r5-main-current` is behind recent docs/OpenSpec commits. The Swift baseline is still adequate for impact lookup on existing symbols, but Gate 2 records staged detect output before commit rather than claiming a fresh whole-repo graph refresh. |

## GitNexus Impact

| target | file | direction | result | decision |
|---|---|---|---|---|
| `applyMockTransition` | `Core/State/DemoVehicleStateStore.swift` | upstream | MEDIUM, 24 impacted, 7 direct, 1 process | Not edited; adapter calls existing API. |
| `ToolCallFrame` | `Core/Routing/ToolCallFrame.swift` | upstream | HIGH, 40 impacted, 11 direct, 3 processes | Not edited; no shared frame schema change. |
| `DemoActionExecutor` | `Core/Execution/DemoActionExecutor.swift` | upstream | LOW, 1 impacted, 1 direct | Not edited; kept current helper untouched. |

## Implemented Paths

- `/Users/wanglei/workspace/MAformac/Core/Execution/DemoRuntimeAdapter.swift`
- `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/DemoRuntimeAdapterTests.swift`

## Behavior Covered

| behavior | proof |
|---|---|
| First execution writes through adapter-owned mock path | `DemoRuntimeAdapterTests.testFirstExecutionWritesThroughAdapterOwnedMockPath` |
| Retry replay does not double-write | `DemoRuntimeAdapterTests.testRetryReplayReturnsReadbackWithoutSecondWrite` |
| Already-state remains no-op with readback | `DemoRuntimeAdapterTests.testAlreadyStateReturnsNoopProvenanceWithoutMutation` |
| Same command identity with different request fails closed | `DemoRuntimeAdapterTests.testSameCommandIDWithDifferentRequestFailsClosed` |
| Unsupported command does not create fake success ledger | `DemoRuntimeAdapterTests.testFailedCommandDoesNotCreateSuccessfulLedgerEntry` |
| Missing state cell does not create fake success ledger | `DemoRuntimeAdapterTests.testMissingStateCellDoesNotCreateSuccessfulLedgerEntry` |

## Validation

PASS before Hermes:

- `swift test --filter 'DemoRuntimeAdapterTests|C3ExecutionPipelineTests|VehicleStateStoreContractTests|RuntimePresentationBridgeTests'` -> PASS, 39 tests, 0 failures.
- `git diff --check` -> PASS.
- `openspec validate define-runtime-adapter-execution --strict` -> PASS.
- `openspec validate --all --strict` -> PASS, 17 passed / 0 failed.

Required before commit:

- `git diff --cached --name-only` must include only Gate 2 exact paths.
- `git diff --cached --check` must pass.
- GitNexus `detect_changes(scope=staged)` must be reviewed before commit.

PASS before Hermes:

- `git diff --cached --name-only` -> exactly:
  - `Core/Execution/DemoRuntimeAdapter.swift`
  - `Tests/MAformacCoreTests/DemoRuntimeAdapterTests.swift`
  - `docs/project/phase0/r5-d12-gate2-runtime-adapter-v0-code-2026-06-29.md`
- `git diff --cached --check` -> PASS.
- GitNexus `detect_changes(repo="MAformac-r5-main-current", scope="staged", worktree="/Users/wanglei/workspace/MAformac")` -> `risk_level: low`, `changed_files: 3`, `changed_count: 0`, `affected_count: 0`, `affected_processes: []`.

GitNexus staged detect caveat: `changed_count: 0` is expected for new unindexed files plus a docs receipt under the current stale index; this is not treated as proof that the new adapter has no future callers. It is only proof that staged changes did not touch indexed existing symbols or known execution flows.

## Hermes

First run PASS, then receipt was updated with audit outcome, so Gate 2 intentionally reruns validation and Hermes before commit.

- first output: `/Users/wanglei/workspace/MAformac/Reports/r5-d12-gate2-runtime-adapter-v0-20260629T104738/hermes-output.txt`
- first required verdict anchor: `HERMES_R5_D12_GATE_2_RUNTIME_ADAPTER_V0_VERDICT: PASS`
- first findings_P0_P1: none
- first findings_P2_or_lower:
  - GitNexus index is stale for new files; use as graph-visible no-touch evidence only.
  - Runtime Adapter V0 remains local/unit only with no C3 wiring or durable ledger.
- rerun output: `/Users/wanglei/workspace/MAformac/Reports/r5-d12-gate2-runtime-adapter-v0-20260629T105430/hermes-output.txt`
- required verdict anchor: `HERMES_R5_D12_GATE_2_RUNTIME_ADAPTER_V0_VERDICT: PASS`
- unresolved P0/P1 must be empty before commit and before Gate 3.

## Exact Pathspec Candidate

```bash
git add -- \
  Core/Execution/DemoRuntimeAdapter.swift \
  Tests/MAformacCoreTests/DemoRuntimeAdapterTests.swift \
  docs/project/phase0/r5-d12-gate2-runtime-adapter-v0-code-2026-06-29.md
```

## Residual Risks

- Runtime Adapter V0 is not wired into `C3ExecutionPipeline`.
- The in-memory ledger is not persistent across process restarts.
- Retry replay returns the recorded readback for the adapter-owned ledger entry; future production reconciliation may require re-verification against live state.
- The request fingerprint covers write-affecting frame fields, not attempt metadata.
- `C018`, `C052`, final-art, and white-edge are not implemented by Gate 2.
- UIUE must not infer stable consumer fields from this internal main adapter before Gate 3 guard/reconcile.

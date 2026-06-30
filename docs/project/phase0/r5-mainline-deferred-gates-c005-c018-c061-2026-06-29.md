---
status: DONE
artifact_kind: r5_d9_stage2_mainline_deferred_gates_receipt
created_at: 2026-06-29
stage: R5-D9-stage-2
rows:
  C005: covered_for_current_mock_executor_write_path
  C018: deferred_owner_decision
  C061: partial_covered_for_already_state_no_double_write
proof_class_ceiling: docs/local + local_static + local_unit + openspec_contract
hermes_output: /Users/wanglei/workspace/MAformac/Reports/r5-d9-stage2-20260629T090700/hermes-output.txt
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
---

# R5 D9 Stage 2 - Mainline C005/C018/C061 Receipt

## Scope

This receipt records the Stage 2 mainline bounded lane only. It advances the current mock executor/store path and already-state no-double-write behavior without inventing UIUE shared fields or a production runtime adapter.

## Live Truth

| repo | observed state |
|---|---|
| UIUE prerequisite | Stage 1 finished as DONE and commit `cfcf2fd3b312b4ab63c3a35cc56828e13e7c8e8f` exists before switching to main. |
| main | branch `codex/rebuild-c6-doc-absorption-20260624`, start HEAD `d332db736a0c47eb3b8dc09c80fb907a0f43e29e`. |
| preserve-unowned | `AGENTS.md`, `CLAUDE.md`, `docs/CURRENT.md`, `docs/README.md`, `.xcodebuildmcp/`, and `Tools/agent-platform-plugin-refs/` remain unstaged and out of scope. |

## GitNexus Impact

Before editing `DemoVehicleStateStore.applyMockTransition`, GitNexus impact was run:

- repo: `MAformac-r5-main-current`
- target: `applyMockTransition`
- direction: upstream
- risk: `MEDIUM`
- summary: 7 direct callers, 1 affected process (`App/ContentView.swift:runCommand`), 1 affected module (`MAformacCoreTests`)

## Row Dispositions

| row | disposition | evidence | boundary |
|---|---|---|---|
| `C005` | `covered_for_current_mock_executor_write_path` | `Tests/MAformacCoreTests/VehicleStateStoreContractTests.swift:78-98` proves `DemoActionExecutor` writes through `DemoVehicleStateStore.applyMockTransition` and returns readback; `Core/Execution/DemoActionExecutor.swift:13-23` is the existing executor path. | This is current local mock executor/store ownership only. It is not a production runtime adapter or mobile/runtime proof. |
| `C018` | `deferred_owner_decision` | `openspec/changes/define-runtime-presentation-bridge/tasks.md:63` keeps SceneMacroRegistry/Core config deferred until mainline owns a future OpenSpec/Core authority. | No `SceneMacroRegistry` or hidden shared config is invented in Stage 2. |
| `C061` | `partial_covered_for_already_state_no_double_write` | `Core/State/DemoVehicleStateStore.swift:133-140` returns readback for already-state without mutation; `Tests/MAformacCoreTests/VehicleStateStoreContractTests.swift:54-76` proves store revision/timestamp do not change; `Tests/MAformacCoreTests/C3ExecutionPipelineTests.swift:81-106` proves repeated C3 command does not double-write revision. | Retry semantics and full runtime adapter idempotency remain future work. This receipt does not close those deferred parts. |

## Validation

Completed before Hermes:

- `swift test --filter 'C3ExecutionPipelineTests|VehicleStateStoreContractTests'` -> PASS, 18 tests, 0 failures.
- `git diff --check` -> PASS.
- `openspec validate define-runtime-presentation-bridge --strict` -> PASS (`Change 'define-runtime-presentation-bridge' is valid`).
- `openspec validate --all --strict` -> PASS, 16 passed, 0 failed.
- `swift test --filter RuntimePresentationBridgeTests` -> PASS, 15 tests, 0 failures.

## Hermes

PASS:

- output: `/Users/wanglei/workspace/MAformac/Reports/r5-d9-stage2-20260629T090700/hermes-output.txt`
- required verdict anchor: `HERMES_R5_D9_STAGE_2_VERDICT: PASS`
- elapsed_seconds: 89
- findings_P0_P1: none

## Touched Paths

- `/Users/wanglei/workspace/MAformac/Core/State/DemoVehicleStateStore.swift`
- `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/C3ExecutionPipelineTests.swift`
- `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/VehicleStateStoreContractTests.swift`
- `/Users/wanglei/workspace/MAformac/docs/project/phase0/r5-mainline-deferred-gates-c005-c018-c061-2026-06-29.md`

## Exact Pathspec Candidate

```bash
git add -- \
  Core/State/DemoVehicleStateStore.swift \
  Tests/MAformacCoreTests/C3ExecutionPipelineTests.swift \
  Tests/MAformacCoreTests/VehicleStateStoreContractTests.swift \
  docs/project/phase0/r5-mainline-deferred-gates-c005-c018-c061-2026-06-29.md
```

## Residual Risks

- `C061` retry behavior remains unimplemented and deferred.
- `C005` is covered only for the current local mock executor/store path, not a production runtime adapter.
- `C018` remains deferred until mainline creates a real SceneMacroRegistry/Core config authority.

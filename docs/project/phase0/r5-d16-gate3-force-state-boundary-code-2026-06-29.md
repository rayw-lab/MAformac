# R5 D16 Gate 3 - Force-State Boundary Code Receipt

Date: 2026-06-29
Gate: `D16_GATE_3_FORCE_STATE_BOUNDARY_CODE_TESTS`
Repo: `/Users/wanglei/workspace/MAformac`
Scope: main-owned C052 local/unit boundary only

## Verdict

`DONE`

Gate 3 adds a main-owned force-state boundary that creates a local demo/debug context only when all of these are true:

- build isolation reports `DEBUG || DEMO_MODE`;
- caller declares `.debug` or `.demoMode`, not `.customerFacing`;
- provenance is an existing `DemoInteractionEvent` with `.demoHarness`, non-empty `eventID`, and non-empty `traceID`;
- requested context dimensions are finite and non-duplicated.

It does not write `DemoVehicleStateStore`, does not alter state-cell contracts, and does not enter the runtime adapter or C3 execution path.

## Live Truth

- Start HEAD after Gate 2: `d00023afa15ea37f39d8a5c20bf645355571c551`
- Branch: `codex/rebuild-c6-doc-absorption-20260624`
- Preserve-unowned dirty remains: `AGENTS.md`, `CLAUDE.md`, `docs/CURRENT.md`, `docs/README.md`, `.xcodebuildmcp/`, `Tools/agent-platform-plugin-refs/`
- Gate 3 owned writes:
  - `Core/Config/DemoForceStateBoundary.swift`
  - `Tests/MAformacCoreTests/DemoForceStateBoundaryTests.swift`
  - `openspec/changes/define-core-config-force-state-authority/tasks.md`
  - `docs/project/phase0/r5-d16-gate3-force-state-boundary-code-2026-06-29.md`

## Harness

| Item | Result |
| --- | --- |
| Lesson learned / metacognitive reflection | C052 can look deceptively like a UI screenshot convenience. The safer primitive is a Core DTO boundary that never writes store state and never claims runtime readiness. |
| Pre-mortem | Main risks were accidentally creating a production force-state path, reusing runtime adapter internals, or letting UIUE infer new shared fields. |
| Local repo cross-search | `rg` found existing `#if DEBUG` gallery force-state UI in `App/DebugGallery.swift` and existing provenance DTOs in `RuntimePresentationBridge.swift`; no C052 production boundary existed. |
| Necessary web cross-search | Not used. Gate 3 is repo-local Swift boundary work and does not depend on external API behavior. |
| Iceberg teardown | Visible symptom: deferred force-state proof. Underlying class: demo-only controls can leak into production semantics. Same-class risk map: launch args, debug gallery, UIUE consumer names, runtime adapter internals. Immediate fix: finite boundary + fail-closed tests. Class-level fix: keep force-state as context DTO, not a store writer. Governance fix: D17 consumes only Gate4-released names. |
| Goal drift check | No UIUE write, no app UI change, no runtime/mobile/true-device claim. |
| Authority | `openspec/changes/define-core-config-force-state-authority/specs/core-config-force-state/spec.md` C052 requirements; prior D16 Gate1 authority receipt. |
| Claim-vs-proof | Claims are local/unit only. `DEBUG || DEMO_MODE` behavior is compile-condition local proof under SwiftPM test build, not production Release binary proof. |
| Boundary | Does not touch `DemoRuntimeAdapter*`, `RuntimeAdapterBox`, fingerprints, ledgers, raw runtime store, raw model output, or training receipts. |
| If wrong, what proves it | `Core/Config/DemoForceStateBoundary.swift`, `Tests/MAformacCoreTests/DemoForceStateBoundaryTests.swift`, `swift test --filter DemoForceStateBoundaryTests`, and `rg -n "DemoForceState|force-state|customerFacing" Core App Tests`. |
| Post-audit correction | Hermes single pass returned anchored FAIL with P0 empty and P1 on `DemoForceStateContext.public init` bypass. Per operator override, no Hermes rerun; the initializer was made internal so external consumers cannot mint force-state contexts outside `DemoForceStateBoundary.accept`. |

## GitNexus

- `npx gitnexus analyze`: PASS after Gate2, index refreshed to current pre-Gate3 HEAD.
- `context(SceneMacroRegistry)`: PASS; no execution processes.
- `context(DemoInteractionEvent)`: tool returned `LadybugDB not initialized for repo "/Users/wanglei/workspace/MAformac/.gitnexus/lbug"`. This is recorded as a tool blocker for that symbol lookup, not treated as authority.
- `detect_changes(scope=staged)`: low risk, 4 staged files, 0 affected processes. Limitation: graph mapped only the OpenSpec tasks section, not the newly added Swift public API, so source/test review remains load-bearing.
- Gate 3 does not edit existing Swift symbols; it adds new public types and tests.

## Hermes Audit

- Prompt: `Reports/r5-d16-gate3-20260629T1757/hermes-prompt.txt`
- Transcript: `Reports/r5-d16-gate3-20260629T1757/hermes-output.txt`
- Anchor: `HERMES_R5_D16_GATE_3_FORCE_STATE_BOUNDARY_CODE_VERDICT: FAIL`
- P0: Empty.
- P1: `DemoForceStateContext` was publicly constructible and bypassed boundary checks.
- P2: Release/prod false branch is statically present but not independently exercised by a Release-mode test.
- Absorbed fix: `DemoForceStateContext.init(...)` is now internal, so external/customer-facing code cannot construct a force-state context without calling `DemoForceStateBoundary.accept(...)`.
- Rerun policy: No Hermes rerun for Gate1-Gate7 per operator override on 2026-06-29; post-fix local validation is required before Gate3 is marked DONE.

## Validation

| Command | Result | Proof class |
| --- | --- | --- |
| `swift test --filter DemoForceStateBoundaryTests` | PASS, 5 tests / 0 failures | local/unit |
| `swift test --filter 'DemoForceStateBoundaryTests\|SceneMacroRegistryTests\|RuntimePresentationBridgeTests'` | PASS, 27 tests / 0 failures | local/unit |
| `git diff --check` | PASS | local/static |
| `openspec validate define-core-config-force-state-authority --strict` | PASS | local/OpenSpec |
| `openspec validate --all --strict` | PASS, 18 items / 0 failed | local/OpenSpec |
| `rg -n "DemoRuntimeAdapter\|RuntimeAdapterBox\|requestFingerprint\|parentRequestFingerprint\|failureLedger\|rawRuntimeStore\|rawModelOutput\|trainingReceipt\|DemoForceState\|force-state\|customerFacing" Core/Config Tests/MAformacCoreTests/DemoForceStateBoundaryTests.swift docs/project/phase0/r5-d16-gate3-force-state-boundary-code-2026-06-29.md openspec/changes/define-core-config-force-state-authority` | PASS for expected mentions; forbidden runtime/private names appear only in negative tests/docs/spec deny lists, not in boundary production API. | local/static |
| `swift test --filter DemoForceStateBoundaryTests` after Hermes correction | PASS, 5 tests / 0 failures | local/unit |
| `swift test --filter 'DemoForceStateBoundaryTests\|SceneMacroRegistryTests\|RuntimePresentationBridgeTests'` after Hermes correction | PASS, 27 tests / 0 failures | local/unit |
| `git diff --check` after Hermes correction | PASS | local/static |
| `openspec validate define-core-config-force-state-authority --strict && openspec validate --all --strict` after Hermes correction | PASS; full OpenSpec 18 items / 0 failed | local/OpenSpec |
| `rg -n "public init\\(" Core/Config/DemoForceStateBoundary.swift` after Hermes correction | PASS for the P1 issue: `DemoForceStateContext` has no public initializer; remaining public initializers are `DemoForceStateValue` and `DemoForceStateBoundary`. | local/static |

## Gate 3 Closeout

Gate 3 is DONE for local/unit scope because the P1 bypass identified by Hermes was removed and post-correction validation passed. This remains capped at local/unit + local/static + OpenSpec proof. It does not prove a Release binary, runtime execution, simulator, mobile, true-device, live API, or production customer-facing behavior.

## Non-Claims

- Not production-ready.
- Not runtime-ready.
- Not mobile, true-device, live API, V-PASS, S-PASS, U-PASS, or UIUE merge proof.
- Not a vehicle-control execution path.
- Not a permission for UIUE to invent shared fields.

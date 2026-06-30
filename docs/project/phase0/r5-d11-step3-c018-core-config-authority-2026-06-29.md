---
status: DONE
artifact_kind: r5_d11_step3_c018_core_config_authority_receipt
created_at: 2026-06-29
step: R5-D11-step-3
disposition:
  C018: openspec_contract_owner_proposal_first
proof_class_ceiling: docs/local + local_static + local_unit + openspec_contract
hermes_output: /Users/wanglei/workspace/MAformac/Reports/r5-d11-step3-c018-20260629T100732/hermes-output.txt
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

# R5 D11 Step 3 - C018 SceneMacroRegistry / Core Config Authority

## Scope

This Step 3 receipt formalizes the mainline authority disposition for `C018`. It does not implement `SceneMacroRegistry`, add Core config fields, change UIUE, or claim merge readiness.

## Metacognitive Harness

| check | result |
|---|---|
| Pre-mortem | Fake green risks: treating `contracts/demo-scenarios.yaml` as a typed Core registry; letting UIUE define shared scene fields first; implementing a Swift registry without OpenSpec owner semantics and tests. |
| Goal-drift check | Goal: decide C018 authority path. Non-goals: C061 retry work, C005 write ownership, UIUE field invention, merge readiness, runtime/mobile/true-device proof. |
| Authority check | Live code/OpenSpec beat prior prose. Current OpenSpec says C018 is deferred until a future mainline OpenSpec/Core authority exists. |
| Claim-vs-proof check | This receipt provides docs/local + OpenSpec-contract disposition only; no runtime/config implementation proof is claimed. |
| Boundary check | Main writes only this receipt. UIUE does not define shared config. No preserve-unowned path is touched. |
| Self-question before Hermes | If this were wrong, `rg SceneMacroRegistry Core Tests openspec contracts` would reveal a current Core type/API or OpenSpec requirement implementing registry ownership. It does not. |
| Post-Hermes correction rule | If any file/pathspec/validation state changes after Hermes PASS, rerun Step 3 local validation and Hermes before commit. |

## Live Repo Truth

| repo | truth |
|---|---|
| main | `/Users/wanglei/workspace/MAformac`; branch `codex/rebuild-c6-doc-absorption-20260624`; HEAD `3722cb95666806b9eb3cf94ed3e9ab949e196e6c`; preserve-unowned dirty only plus this Step 3 receipt before commit. |
| UIUE | Step 1 completed as `7825c1f`; UIUE is read-only for Step 3. |

## C018 Classification

| candidate | evidence | C018 disposition |
|---|---|---|
| current Core `SceneMacroRegistry` type/API | `rg` finds no Swift `SceneMacroRegistry` implementation in `Core/` or `Tests/`. | Not present. |
| current demo scenario data | `contracts/demo-scenarios.yaml` has scene rows, and `contracts/semantic-function-contract.jsonl` has `scene_mode` semantic rows. | Data/provenance only; not a Core config authority API. |
| current Runtime -> Presentation bridge | `openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md` defines bridge snapshot/result semantics. | Not a scene macro registry contract. |
| OpenSpec task authority | `openspec/changes/define-runtime-presentation-bridge/tasks.md:63` defers C018 until mainline owns a future OpenSpec/Core authority. | Mainline must propose contract owner first. |

## Authority Decision

`C018` disposition for D11 Step 3 is `openspec_contract_owner_proposal_first`.

Meaning:

- UIUE must not create or consume hidden `SceneMacroRegistry` shared fields.
- Mainline should open a future OpenSpec change before adding Swift/API surface.
- Existing `contracts/demo-scenarios.yaml` and `scene_mode` semantic rows may be cited as inputs, not as the registry authority.
- A future implementation must be minimal, typed, and testable before UIUE can treat it as shared config.

## Future Contract Skeleton

A future C018 OpenSpec/Core lane should define:

| contract point | required future decision |
|---|---|
| registry name and module | Whether the Core owner is exactly `SceneMacroRegistry` or a different typed config API. |
| data inputs | Which scenario sources are canonical and how raw/material-candidate rows are filtered. |
| typed scene id | Stable scene identifiers, display names, and provenance; no UIUE-only ids. |
| allowed tool mapping | Explicit relation from scene macro to approved D-domain tools/state cells. |
| safety and proof metadata | Whether each macro is planned-only, local-unit-proven, runtime-proven, or deferred. |
| trace shape | How a macro decision appears in trace/readback without raw source leakage. |
| tests | Unit/OpenSpec tests for loading, filtering, no duplicate ids, no hidden UIUE fields, and no proof promotion. |

## Validation

PASS before Hermes:

- `git diff --check` -> PASS.
- `openspec validate define-runtime-presentation-bridge --strict` -> PASS.
- `openspec validate --all --strict` -> PASS.
- `swift test --filter RuntimePresentationBridgeTests` -> PASS.
- `git status --short` -> preserve-unowned dirty remains unstaged; only this Step 3 receipt is owned by D11.

No Swift symbols are edited in Step 3, so GitNexus impact and `detect_changes(scope=staged)` are not required.

## Hermes

PASS:

- output: `/Users/wanglei/workspace/MAformac/Reports/r5-d11-step3-c018-20260629T100732/hermes-output.txt`
- required verdict anchor: `HERMES_R5_D11_STEP_3_C018_VERDICT: PASS`
- findings_P0_P1: none

## Touched Paths

- `/Users/wanglei/workspace/MAformac/docs/project/phase0/r5-d11-step3-c018-core-config-authority-2026-06-29.md`

## Exact Pathspec Candidate

```bash
git add -- docs/project/phase0/r5-d11-step3-c018-core-config-authority-2026-06-29.md
```

## Residual Risks

- C018 still has no Swift/Core implementation.
- UIUE cannot treat scene macro config as shared truth until a future mainline OpenSpec/Core lane lands.
- This receipt does not prove runtime, mobile, true-device, or merge readiness.

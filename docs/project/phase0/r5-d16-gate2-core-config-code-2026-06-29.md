---
status: HERMES_PASS_PENDING_COMMIT
artifact_kind: r5_d16_gate2_core_config_code_receipt
created_at: 2026-06-29
repo: /Users/wanglei/workspace/MAformac
gate: D16_GATE_2_CORE_CONFIG_CODE_TESTS
proof_class: local_unit + OpenSpec + GitNexus
non_claims:
  - no runtime-ready
  - no mobile
  - no true_device
  - no live_api
  - no voice-ready
  - no model-ready
  - no golden-ready
  - no endpoint-ready
  - no UIUE merge
  - no V-PASS
  - no S-PASS
  - no U-PASS
  - no A-2
---

# R5 D16 Gate 2 - Core Config / SceneMacroRegistry Code

## Conclusion

Local validation, GitNexus staged `detect_changes`, and Hermes hard audit passed. First Hermes pass had a P2 hardening note, which was absorbed. A second Hermes pass was run before the operator clarified that Gate1-Gate7 do not require rerun for P2; it also passed with P0/P1/P2 empty. Exact-path commit is still pending.

Gate 2 adds a main-owned Core config / `SceneMacroRegistry` local/unit proof. It does not implement force-state runtime behavior and does not open D17 by itself.

## Live Repo Truth

Start HEAD after Gate 1: `16860c8c5b6f6b3471c240d3773ec7ab353c67df`.

Preexisting preserve-unowned dirty remains excluded:

```text
AGENTS.md
CLAUDE.md
docs/CURRENT.md
docs/README.md
.xcodebuildmcp/
Tools/agent-platform-plugin-refs/
```

## GitNexus Pre-Change Impact

GitNexus index was stale after Gate 1, so controller ran:

```text
npx gitnexus analyze
```

Result: repository indexed successfully; 27,956 nodes, 49,280 edges, 993 clusters, 300 flows.

Before editing code, impact was checked for `SceneMacroRegistry`:

```text
mcp__gitnexus.impact(repo: MAformac-r5-main-current, target: SceneMacroRegistry, direction: upstream)
```

Result: target not found, impactedCount `0`, risk `UNKNOWN`. Interpretation: this is a new isolated Core API rather than an edit to an existing symbol. Actual impact must be verified after implementation with tests and GitNexus `detect_changes`.

## Owned Paths

```text
Core/Config/SceneMacroRegistry.swift
Tests/MAformacCoreTests/SceneMacroRegistryTests.swift
openspec/changes/define-core-config-force-state-authority/tasks.md
docs/project/phase0/r5-d16-gate2-core-config-code-2026-06-29.md
```

## Implementation Summary

- `SceneMacroRegistry` defines finite stable config keys and scene macro names owned by main.
- Known macro definitions map to existing `contracts/demo-scenarios.yaml` scene IDs `scene1` through `scene5`.
- Unknown config and macro names throw `SceneMacroRegistryError` and fail closed.
- `d17ConsumableNames` contains only stable config keys and scene macro names, not private adapter/debug/proof-promotion names.
- Definitions expose fixed `PresentationProofClass.localUnit`, whose display caps are empty. The proof class is not caller-injectable.

## Harness

| check | result |
| --- | --- |
| Lesson learned / metacognitive reflection | Adding a registry is not runtime wiring. The safest Gate 2 slice is an isolated finite vocabulary with fail-closed tests. |
| Pre-mortem | Failure modes: arbitrary names drift from demo scenarios, unknown names render as supported, private adapter names sneak into D17 vocabulary, or local/unit proof is promoted. |
| Local repo cross-search | Checked existing Core files, demo scenarios, allowlist, bridge tests, and previous C018/C052 receipts. No existing `SceneMacroRegistry` implementation exists. |
| Web cross-search | Not run because this is local authority/code shape, not an external SDK/API decision. |
| Iceberg visible symptom | C018 lacked code-backed owner surface. |
| Iceberg underlying class | Downstream consumers need finite names; otherwise UIUE invents shared config. |
| Iceberg same-class risk map | main duplicate registry; UIUE hidden config; runtime proof promotion; D17 premature release. |
| Iceberg immediate fix | Add finite registry and fail-closed tests. |
| Iceberg class-level fix | Gate 4 must verify UIUE has not consumed D16 names before release. |
| Iceberg governance fix | Keep D17 blocked until Gate 4 writes `d17_release_gate: open`. |
| Goal-drift check | No force-state runtime code, no UIUE writes, no source dispatch staging, no push/PR/merge. |
| Authority check | Gate 1 OpenSpec and live demo scenario IDs are the authority for this slice. |
| Claim-vs-proof check | Proof is local/unit only after tests pass; no runtime/mobile/true-device/live proof. |
| Boundary check | D17 consumable names are finite and exclude private adapter/debug/proof-promotion names. |
| Self-question | If this is wrong, `SceneMacroRegistryTests` unknown-name assertions, GitNexus detect, or UIUE grep in Gate 4 should expose drift. |
| Post-audit correction rule | Any validation failure, Hermes P0/P1, forbidden claim, staged no-touch path, or proof promotion blocks DONE. |

## Validation Evidence

Local validation passed:

```text
swift test --filter SceneMacroRegistryTests: PASS (4 tests, 0 failures)
swift test --filter 'SceneMacroRegistryTests|RuntimePresentationBridgeTests': PASS (22 tests, 0 failures)
git diff --check: PASS
openspec validate define-core-config-force-state-authority --strict: PASS
openspec validate --all --strict: PASS (18 passed, 0 failed)
```

SwiftPM warning:

```text
warning: 'maformac': found 1 file(s) which are unhandled; explicitly declare them as resources or exclude from the target
/Users/wanglei/workspace/MAformac/UBIQUITOUS_LANGUAGE.md
```

This warning preexists the Gate 2 slice and did not fail the focused tests.

GitNexus evidence:

```text
pre-change impact target SceneMacroRegistry: target not found; impactedCount 0; risk UNKNOWN
npx gitnexus analyze: PASS, repository indexed successfully
detect_changes(scope=all): polluted by preserve-unowned dirty files; not used as precise Gate 2 impact proof
detect_changes(scope=staged): risk_level low; changed_files 4; affected_processes []
```

Interpretation: `SceneMacroRegistry` is a new isolated Core API, not a modification of an existing execution symbol. GitNexus did not report affected execution flows for the staged Gate 2 diff.

## Hermes Evidence

First Hermes run:

```text
output_path: Reports/r5-d16-gate2-20260629T174453/hermes-output.txt
anchor: HERMES_R5_D16_GATE_2_CORE_CONFIG_CODE_VERDICT: PASS
P0: []
P1: []
P2: SceneMacroDefinition public mutable fields and caller-injectable proofClass could be hardened before broader D17 consumption.
```

P2 absorption:

```text
SceneMacroDefinition fields changed to let constants.
proofClass changed to fixed computed .localUnit, not an initializer argument.
Gate1-Gate7 operator update later clarified Hermes rerun is not required for P2 absorption; this gate already had a rerun before that clarification.
```

Second Hermes run:

```text
output_path: Reports/r5-d16-gate2-r2-20260629T174850/hermes-output.txt
anchor: HERMES_R5_D16_GATE_2_CORE_CONFIG_CODE_VERDICT: PASS
P0: []
P1: []
P2: []
confidence: high
```

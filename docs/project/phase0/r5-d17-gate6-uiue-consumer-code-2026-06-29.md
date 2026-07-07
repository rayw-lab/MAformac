---
artifact_kind: r5_d17_gate6_uiue_consumer_code_receipt
gate: D17_GATE_6_UIUE_CONSUMER_CODE_TESTS
repo: /Users/wanglei/workspace/MAformac-uiue
status: DONE
proof_class: local_unit + local_static + openspec_local
created_at: 2026-06-29
retire_trigger: "Retire when superseded by archived OpenSpec specs or explicit user decision."
expires: "2026-08-15"
---

# R5 D17 Gate6 - UIUE Consumer Code And Tests

## Verdict

`DONE`

Gate6 extends `RuntimePresentationConsumerMapping` with a D17 consumer boundary for main-owned D15 payload names and D16 config/macro/force-context names. It uses explicit raw-name allow lists and throw-on-unknown validators because UIUE must not import or mirror main private runtime/force-state DTOs.

This does not parse live runtime payloads, does not connect production runtime/mobile/true-device surfaces, and does not claim UIUE merge, V-PASS, S-PASS, U-PASS, A-2 readiness, runtime-ready, mobile, true-device, live API, voice-ready, model-ready, golden-ready, or endpoint-ready.

## Owned Paths

- `Core/Presentation/RuntimePresentationConsumerMapping.swift`
- `Tests/MAformacCoreTests/RuntimePresentationConsumerMappingTests.swift`
- `docs/project/phase0/r5-d17-gate6-uiue-consumer-code-2026-06-29.md`
- `openspec/changes/ui-presentation/tasks.md`

## Implementation

- Added D15 payload schema, envelope field, content field, proof-class, reconciliation status, and reconciliation mismatch allow lists.
- Added D16 Core config, scene macro, and force-context dimension allow lists.
- Added fail-closed validators for unknown schema, presentation field, proof class, reconciliation status/mismatch, config key, scene macro name, and force-context dimension.
- Added private-name rejection for adapter, fingerprint, ledger, raw runtime/model, training receipt, and `DemoForceStateContext` construction surfaces.
- Added local/unit tests for known stable names, unknown names, forbidden private names, and proof-cap non-promotion.

## Harness

| item | result |
|---|---|
| Lesson learned / metacognitive reflection | Gate5 showed stale UIUE wording can overclaim proof even when new D17 text is correct. Gate6 therefore keeps validators narrow and tests both allow and deny paths. |
| Pre-mortem | The code could accidentally create a second shared schema, accept `RuntimeAdapterBox`/fingerprint names as payload fields, or treat proof labels as readiness. |
| Local repo cross-search | Checked existing `RuntimePresentationConsumerMapping` and tests, UIUE Gate5 authority, and main D15/D16 stable names. |
| Web cross-search | Not needed; this gate consumes repo-local main authority, not external APIs. |
| Iceberg teardown | Visible symptom: UIUE needs D17 consumer code. Underlying class: contract-name drift between provider and consumer. Same-class risk map: invented field, private-field leak, proof promotion, force-state constructor bypass. Immediate fix: explicit allow/deny sets and fail-closed validators. Class-level fix: Gate7 verifier greps and smoke checks. Governance fix: Gate8 Claude Code adversarial audit covers Gate1-Gate8 plus Gate4R/Gate5 post-audit fixes. |
| Goal-drift check | Gate6 is local/unit code/test proof only. It does not run simulator visual smoke or dual-repo reconcile. |
| Authority | Main D15 payload contract, main D16 Core config / force-state authority, Gate4R release, UIUE Gate5 authority. |
| Claim-vs-proof | Local/unit tests prove mapping and fail-closed behavior only; no runtime/mobile/live proof. |
| Boundary | UIUE uses raw stable names as consumer contract keys; main remains owner of payload/config/force-state truth. |
| If wrong, what proves it | `Core/Presentation/RuntimePresentationConsumerMapping.swift`, `Tests/MAformacCoreTests/RuntimePresentationConsumerMappingTests.swift`, main `RuntimePresentationBridge.swift`, main `SceneMacroRegistry.swift`, main `DemoForceStateBoundary.swift`, and Gate5 Hermes transcript. |
| Post-audit correction | Hermes single pass returned anchored PASS with P0/P1 empty. P2 asks Gate7 to probe both `runtimeStore` and `rawRuntimeStore`; Gate6 already fail-closes `runtimeStore` as an unknown presentation field and rejects `rawRuntimeStore` as forbidden. Gate7 verifier must include both names explicitly. |

## Validation

| command | result | proof class |
|---|---|---|
| `swift test --filter RuntimePresentationConsumerMappingTests` | PASS, 13 tests / 0 failures | local/unit |
| `git diff --check` | PASS | local/static |
| `openspec validate ui-presentation --strict` | PASS | local/OpenSpec |
| main read-only `openspec validate define-runtime-presentation-bridge --strict` | PASS | local/OpenSpec |
| main read-only `openspec validate define-core-config-force-state-authority --strict` | PASS | local/OpenSpec |
| GitNexus `impact(RuntimePresentationConsumerMapping, upstream)` | LOW risk, 0 direct callers, 0 affected processes | local/static |
| GitNexus `detect_changes(scope: unstaged)` | LOW risk, 0 affected processes | local/static |
| one Hermes audit pass | PASS; P0/P1 none; P2 Gate7 runtimeStore/rawRuntimeStore probe requirement | audit |

## Gate6 Audit

- Auditor: Hermes GLM-5.2 code.
- Prompt: `Reports/r5-d17-gate6-20260629T1840/hermes-prompt.txt`
- Transcript: `Reports/r5-d17-gate6-20260629T1840/hermes-output.txt`
- Anchor: `HERMES_R5_D17_GATE_6_UIUE_CONSUMER_CODE_TESTS_VERDICT: PASS`
- P0: none.
- P1: none.
- P2: Gate7 should explicitly probe both `runtimeStore` and `rawRuntimeStore` to avoid wording drift.
- Controller decision: proceed to Gate7 under proof cap. Gate6 remains local/unit/static/OpenSpec proof only.

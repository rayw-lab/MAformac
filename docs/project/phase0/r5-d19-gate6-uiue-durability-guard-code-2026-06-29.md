---
artifact_kind: r5_d19_gate6_uiue_durability_guard_code_receipt
gate: D19_GATE_6_UIUE_DURABILITY_GUARD_CODE_TESTS
repo: /Users/wanglei/workspace/MAformac-uiue
status: DONE_BEFORE_HERMES_ROUND2
proof_class: local_unit + local_static + openspec_local
created_at: 2026-06-29
---

# R5 D19 Gate6 - UIUE Durability Guard Code And Tests

## Verdict

`DONE_BEFORE_HERMES_ROUND2`

Gate6 extends the existing UIUE `RuntimePresentationConsumerMapping` deny-list so D18 durable/private runtime names fail closed and cannot become presentation fields, proof labels, proof caps, or readiness claims.

This remains local/unit/static guard proof only. It does not parse main runtime payloads, durable ledger files, C3 durable stores, adapter ledger rows, or storage schemas. It does not claim UIUE merge, runtime-ready, production durable runtime, mobile, true-device, live API, V-PASS, S-PASS, U-PASS, A-2 readiness, voice-ready, model-ready, golden-ready, endpoint-ready, or R5 completion.

## Scope

- UIUE write paths:
  - `Core/Presentation/RuntimePresentationConsumerMapping.swift`
  - `Tests/MAformacCoreTests/RuntimePresentationConsumerMappingTests.swift`
  - `openspec/changes/ui-presentation/tasks.md`
  - `docs/project/phase0/r5-d19-gate6-uiue-durability-guard-code-2026-06-29.md`
- Main read-only authority:
  - D18 local durable adapter/C3 authority and Gate4 private payload boundary verifier
  - `define-runtime-adapter-execution`
  - `define-runtime-presentation-bridge`
- No-touch:
  - UIUE App visuals/assets/simulator/true-device/voice/model/golden surfaces
  - source dispatch docs
  - UIUE pre-existing untracked research
  - main repo writes

## Implementation

- Added D18 private durability names to `RuntimePresentationConsumerMapping.forbiddenPrivateNames`:
  - `durableLedger`
  - `persistentLedger`
  - `adapterLedger`
  - `local_durable_adapter_ledger`
  - `runtimeStore`
- Preserved existing D17 private-name rejection for adapter names, request/parent fingerprints, success/failure ledger, settled parent plan, `rawRuntimeStore`, raw model output, training receipt, and `DemoForceStateContext`.
- Added `testD19DurabilityPrivateNamesFailClosedWithoutBecomingPresentationOrProofLabels`.
- Strengthened proof cap tests so `production_durable_runtime` and `local_durable_adapter_ledger` cannot be proof caps.

## GitNexus

| probe | result |
|---|---|
| `node .gitnexus/run.cjs analyze` | PASS; refreshed UIUE index before edits, 28,775 nodes / 44,865 edges / 300 flows. |
| `context(RuntimePresentationConsumerMapping)` | Found `Core/Presentation/RuntimePresentationConsumerMapping.swift`; no process membership. |
| `impact(RuntimePresentationConsumerMapping, upstream, includeTests)` | `LOW`; 0 direct, 0 affected processes. |
| `detect_changes(scope=staged)` | `low`: 13 changed symbols, 4 changed files, 0 affected processes. |

## Harness

| item | result |
|---|---|
| Lesson learned / metacognitive reflection | A deny-list that covers D17 adapter fields can still miss D18 durability nouns. Guard code must track exact new private terms, not rely on old generic "ledger" wording. |
| Pre-mortem | Gate6 could fail by adding durable names to allow-lists, returning unknown instead of explicit forbidden for private presentation fields, or allowing `local_durable_adapter_ledger` to become a proof label. |
| Local repo cross-search | Checked Gate5 authority, UIUE D17 mapping/tests, main Gate4 private payload verifier, and D18 dispatch Gate6 requirements. |
| Web cross-search | Not needed. The code behavior is local OpenSpec/test authority, not external API behavior. |
| Iceberg teardown | Visible symptom: D19 requires new deny-list coverage. Underlying class: provider-side implementation nouns become consumer labels unless exact guard tests exist. Same-class risk map: durable ledger as payload field, local durable proof as readiness, raw runtime store as display label, storage schema as DTO. Immediate fix: explicit deny-list and local/unit tests. Class-level fix: Gate7/Gate8 reconcile and audits carry proof caps. Governance fix: Hermes round2 over Gates4-6, followed later by final blind audits. |
| Goal-drift check | Gate6 stayed UIUE mapping/test only. It did not read or parse durable files, add runtime payload fields, change App visuals, or claim runtime/mobile/live proof. |
| Authority | D19 Gate5 UIUE authority, main D18 Gates1-4, and UIUE D17 consumer guard. |
| Claim-vs-proof | Local/unit tests prove fail-closed validation only. They do not prove production durability, UIUE merge, runtime readiness, mobile/true-device/live, or A-2. |
| Boundary | UIUE may reject D18 private names; it may not consume them as stable shared fields or proof/readiness truth. |
| If wrong, what proves it | `Core/Presentation/RuntimePresentationConsumerMapping.swift` would include D18 durable names in allow-lists, `Tests/MAformacCoreTests/RuntimePresentationConsumerMappingTests.swift` would allow them as fields/proof labels, or `openspec/changes/ui-presentation/specs/ui-presentation/spec.md` would authorize UIUE durable data consumption. |
| Post-audit correction | Hermes round2 will audit Gates4-6 after Gate6 commit. Under the operator cadence, run it once; if it finds owned P0/P1/P2 issues, fix and rerun local validation without calling the original audit PASS unless the original anchor is PASS. |

## Validation

| command | result | proof class |
|---|---|---|
| `swift test --filter RuntimePresentationConsumerMappingTests` | PASS: 14 tests, 0 failures | local/unit |
| `git diff --check` | PASS | local/static |
| `openspec validate ui-presentation --strict` | PASS | local/OpenSpec |
| main read-only `openspec validate define-runtime-adapter-execution --strict` | PASS | local/OpenSpec |
| main read-only `openspec validate define-runtime-presentation-bridge --strict` | PASS | local/OpenSpec |
| `git diff --cached --check` | PASS before commit | local/static |

## Dirty Split

Expected UIUE source artifacts remain excluded:

- D12-D18 source dispatch docs under `docs/dispatches/`
- `docs/research/2026-06-29-visual-acceptance-standard/`

Gate6 exact owned paths:

- `Core/Presentation/RuntimePresentationConsumerMapping.swift`
- `Tests/MAformacCoreTests/RuntimePresentationConsumerMappingTests.swift`
- `openspec/changes/ui-presentation/tasks.md`
- `docs/project/phase0/r5-d19-gate6-uiue-durability-guard-code-2026-06-29.md`

No `git add .` was used. Source dispatch docs were not staged.

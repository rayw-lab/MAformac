---
artifact_kind: r5_d17_gate5_uiue_consumer_authority_receipt
gate: D17_GATE_5_UIUE_CONSUMER_AUTHORITY
repo: /Users/wanglei/workspace/MAformac-uiue
status: DONE_UNDER_AUDIT_FAIL_FIXED_POST_AUDIT
proof_class: docs_local + openspec_local
created_at: 2026-06-29
retire_trigger: "Retire when superseded by archived OpenSpec specs or explicit user decision."
expires: "2026-08-15"
---

# R5 D17 Gate5 - UIUE Consumer Authority

## Verdict

`DONE under audit_fail_fixed_post_audit`

Gate5 defines UIUE authority for consuming main D15 Runtime -> Presentation payload fields and main D16 stable Core config / SceneMacroRegistry / force-context names. It does not implement UIUE Swift consumer code, does not run simulator acceptance, and does not claim UIUE merge, runtime-ready, mobile, true-device, live API, V-PASS, S-PASS, U-PASS, A-2 readiness, voice-ready, model-ready, golden-ready, or endpoint-ready.

## Scope

- UIUE write paths:
  - `openspec/changes/ui-presentation/proposal.md`
  - `openspec/changes/ui-presentation/design.md`
  - `openspec/changes/ui-presentation/specs/ui-presentation/spec.md`
  - `openspec/changes/ui-presentation/tasks.md`
  - `docs/project/phase0/r5-d17-gate5-uiue-consumer-authority-2026-06-29.md`
- Main read-only authority:
  - D15 `define-runtime-presentation-bridge`
  - D16 `define-core-config-force-state-authority`
  - Gate4R receipt with `d17_release_gate: open`
- No-touch:
  - UIUE Swift code
  - UIUE source dispatch files
  - UIUE research artifacts
  - main repo writes

## Authority Chain

| source | status | Gate5 use |
|---|---:|---|
| Main D15 payload contract | committed main authority | Defines `RuntimePresentationPayload`, `PresentationReconciliation`, finite schema/proof/reconciliation fields, and forbidden private runtime/adapter exposure. |
| Main D16 Core config / force-state authority | committed main authority | Defines stable config keys, scene macro names, force-context dimensions, proof cap, and D17 consumer boundary. |
| Main Gate4R | `d17_release_gate: open` | Repairs `DemoForceStateContext` external `Decodable` construction bypass before D17 starts. |
| UIUE Gate5 OpenSpec | this receipt | Defines UIUE consumer authority only, before Gate6 code/tests. |

## Consumer Boundary

UIUE MAY consume only:

- D15 payload envelope fields: `schemaVersion`, `traceID`, `turnID`, `eventID`, `isTerminal`.
- D15 presentation-safe content fields: `outcome`, `proofClass`, `cards`, `cardSemantics`, `readbacks`, `reconciliation`, `traceEnvelope`.
- D15 reconciliation fields: `status`, `readbackKey`, `mismatchClass`, `safeReason`.
- D16 Core config stable names: `scene_macro_registry.version`, `scene_macro_registry.stable_names`, `d17.consumer_authority`.
- D16 scene macro stable names: `scene1.human_language_comfort`, `scene2.multi_intent_comfort`, `scene3.followup_window_memory`, `scene4.driver_window_generalization`, `scene5.driving_safety_refusal`.
- D16 force-context dimension names only when carried by main-owned presentation/context authority: `vehicle.speed`, `vehicle.gear`, `environment.weather`, `environment.time_period`.

UIUE SHALL NOT consume or invent:

- `DemoRuntimeAdapter*`, `RuntimeAdapterBox`, `requestFingerprint`, `parentRequestFingerprint`, `failureLedger`, ledger internals, settled parent plan internals, raw runtime store, raw model output, training receipt, or adapter-local private names.
- `DemoForceStateContext` decode/constructor surfaces.
- UIUE-owned shared fields, enum values, proof classes, Core config truth, or force-state truth.

Unknown schema, proof class, reconciliation status, mismatch class, config key, scene macro name, force-context dimension, or unexpected presentation field must fail closed in Gate6 tests.

## Harness

| item | result |
|---|---|
| Lesson learned / metacognitive reflection | D15 contract definition, D16 release gate, and UIUE consumption are separate phases. Consuming stable names requires a UIUE authority receipt before code, because otherwise UIUE could silently turn docs vocabulary into a second shared schema. |
| Pre-mortem | Gate5 could accidentally bless UIUE-invented fields, treat D16 local/unit force-state proof as runtime proof, or reopen the Gate4R `DemoForceStateContext` construction surface through local DTO mirroring. |
| Local repo cross-search | Checked UIUE OpenSpec, prior D12-D15 UIUE guard/reconcile receipts, and main D15/D16 specs/code for stable names and forbidden private fields. |
| Web cross-search | Not needed. The authority is local repo OpenSpec/code/receipt truth, not external API behavior. |
| Iceberg teardown | Visible symptom: UIUE needs to consume D15/D16 names. Underlying class: consumer/provider ownership drift. Same-class risk map: invented schema fields, enum drift, proof promotion, private adapter leakage, force-state constructor bypass. Immediate fix: docs/OpenSpec authority with allow/deny lists. Class-level fix: Gate6 fail-closed consumer tests. Governance fix: Gate8 final Claude Code adversarial audit covers Gate1-Gate8 plus Gate4R. |
| Goal-drift check | Gate5 is authority only. It does not implement consumer mapping, simulator smoke, route-map reconcile, or final dual-repo closeout. |
| Authority | Main D15 payload contract, main D16 Core config / force-state authority, Gate4R release receipt, UIUE `ui-presentation` OpenSpec. |
| Claim-vs-proof | Docs/OpenSpec authority only. No Swift implementation, runtime/mobile/true-device/live proof, UIUE merge, V-PASS, S-PASS, U-PASS, A-2, voice-ready, model-ready, golden-ready, or endpoint-ready claim. |
| Boundary | UIUE consumes stable main-owned names only; main remains owner of payload/config/force-state truth. |
| If wrong, what proves it | `openspec/changes/ui-presentation/specs/ui-presentation/spec.md`, `openspec/changes/ui-presentation/design.md`, main `RuntimePresentationBridge.swift`, main `SceneMacroRegistry.swift`, main `DemoForceStateBoundary.swift`, and Gate4R receipt. |
| Post-audit correction | Hermes single pass returned anchored FAIL with P0 empty and P1 on stale `8.C2` task wording that could be read as A-2 / L3 / V-PASS closure. The task was changed back to open with an explicit note that P2/P3 evidence only strengthens local/simulator proof and does not close L3 human 5-gate. No Hermes rerun per operator one-pass policy; this receipt records `audit_fail_fixed_post_audit`, not Hermes PASS. |

## Validation

| command | result | proof class |
|---|---|---|
| `git diff --check` | PASS | local/static |
| `openspec validate ui-presentation --strict` | PASS | local/OpenSpec |
| main read-only `openspec validate define-runtime-presentation-bridge --strict` | PASS | local/OpenSpec |
| main read-only `openspec validate define-core-config-force-state-authority --strict` | PASS | local/OpenSpec |
| GitNexus `detect_changes(repo: MAformac-r5-uiue-current, scope: unstaged)` | LOW risk, 0 affected processes for mapped docs diff. Limitation: index is 13 commits behind and did not map the new untracked receipt. | local/static |

## Gate5 Audit

- Auditor: Hermes GLM-5.2 code.
- Prompt: `Reports/r5-d17-gate5-20260629T1834/hermes-prompt.txt`
- Transcript: `Reports/r5-d17-gate5-20260629T1834/hermes-output.txt`
- Anchor: `HERMES_R5_D17_GATE_5_UIUE_CONSUMER_AUTHORITY_VERDICT: FAIL`
- P0: none.
- P1: stale checked `8.C2 visual-acceptance L0-L3` task under A-2 wording could be read as proof promotion.
- P2: receipt validation/status was stale relative to controller validation.
- Controller action: fixed P1/P2 in owned docs and reran local validation. No Hermes rerun. Status is `audit_fail_fixed_post_audit`.

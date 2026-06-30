---
artifact_kind: r5_d17_gate7_uiue_consumer_verifier_visual_smoke_receipt
gate: D17_GATE_7_UIUE_CONSUMER_VERIFIER_VISUAL_SMOKE
repo: /Users/wanglei/workspace/MAformac-uiue
status: DONE
proof_class: local_unit + local_static + openspec_local
created_at: 2026-06-29
---

# R5 D17 Gate7 - UIUE Consumer Verifier And Optional Visual Smoke

## Verdict

`DONE`

Gate7 verifies the D17 UIUE consumer boundary added in Gate6. It keeps proof capped to local/unit/static/OpenSpec. Simulator visual smoke is skipped because Gate6 added raw-name consumer validators and tests, not a user-facing visual route; a booted simulator exists, but launching a UI visual smoke would not prove D17 payload consumer correctness and would risk proof-class drift.

## Validation And Evidence

| check | command | result | proof class |
|---|---|---|---|
| Targeted consumer tests | `swift test --filter RuntimePresentationConsumerMappingTests` | PASS, 13 tests / 0 failures | local/unit |
| UIUE diff/OpenSpec | `git diff --check && openspec validate ui-presentation --strict` | PASS | local/static + local/OpenSpec |
| Forbidden private token grep | `rg -n "DemoRuntimeAdapter|RuntimeAdapterBox|requestFingerprint|parentRequestFingerprint|failureLedger|successLedger|settledParentPlan|runtimeStore|rawRuntimeStore|rawModelOutput|trainingReceipt|DemoForceStateContext" Core App Tests --glob '*.swift' -S` | Expected hits only in Gate6 deny-list/tests. No App hits. | local/static |
| Readiness claim grep | `rg -n "runtime-ready|runtime_ready|mobile|true-device|true_device|live API|live_api|UIUE merge|V-PASS|S-PASS|U-PASS|A-2|voice-ready|voice_ready|model-ready|model_ready|golden-ready|golden_ready|endpoint-ready|endpoint_ready" Core App Tests openspec/changes/ui-presentation docs/project/phase0/r5-d17-gate5-uiue-consumer-authority-2026-06-29.md docs/project/phase0/r5-d17-gate6-uiue-consumer-code-2026-06-29.md --glob '*.swift' --glob '*.md' -S` | Hits are non-claim/spec guard/test negative strings or older UIUE visual scope wording; Gate5/Gate6 receipts explicitly deny readiness claims. | local/static |
| Gate6 P2 runtime-store wording probe | Static review of `RuntimePresentationConsumerMapping.validatePresentationField`: `runtimeStore` is absent from `payloadFieldNames` and fails closed as `unknownPresentationField`; `rawRuntimeStore` is present in `forbiddenPrivateNames` and rejects as `forbiddenPrivateName`. | PASS | local/static |
| Simulator availability | `xcrun simctl list devices booted` | Booted iPhone 17 Pro Max found. App visual smoke skipped as not probative for Gate6 consumer validators. | simulator availability only, no acceptance proof |
| main read-only OpenSpec | Gate6 already reran `openspec validate define-runtime-presentation-bridge --strict` and `openspec validate define-core-config-force-state-authority --strict`; no main writes since. | PASS carried forward | local/OpenSpec |

## Grep Classification

Forbidden private token grep produced only these classes:

- `Core/Presentation/RuntimePresentationConsumerMapping.swift`: explicit deny-list and validator implementation.
- `Tests/MAformacCoreTests/RuntimePresentationConsumerMappingTests.swift`: negative tests proving rejection or fail-closed behavior.
- No `App/` hits and no consumer rendering path uses private adapter, ledger, raw runtime/model, training receipt, or `DemoForceStateContext` names.

Readiness claim grep produced only these classes:

- Gate5/Gate6 receipts and D17 tasks: explicit non-claims.
- UIUE OpenSpec visual acceptance sections: guard language saying simulator/local proof does not close `8.C2`, L3, or V-PASS.
- Tests/guard code: negative proof-governance vocabulary.
- Historical/older design wording still contains `A-2` as the existing UIUE visual lane name; Gate5 fixed the stale checked `8.C2` item and current tasks say Phase 2 visual acceptance remains open.

## Harness

| item | result |
|---|---|
| Lesson learned / metacognitive reflection | A verifier must classify grep hits, not merely count them. Negative tests and deny lists intentionally contain forbidden strings. |
| Pre-mortem | Gate7 could overclaim simulator availability as visual acceptance, miss a private token because it appears only in tests, or treat old A-2 visual lane wording as D17 readiness. |
| Local repo cross-search | Ran bounded Swift and OpenSpec grep across `Core`, `App`, `Tests`, `openspec/changes/ui-presentation`, and D17 receipts. |
| Web cross-search | Not needed; verifier is repo-local contract and proof-class evidence. |
| Iceberg teardown | Visible symptom: forbidden strings appear in the repo. Underlying class: negative evidence can be mistaken for consumer usage. Same-class risk map: private-field leak, proof promotion, stale visual acceptance wording. Immediate fix: classify hits by context. Class-level fix: Gate8 final audit must include Gate5 P1 and Gate6 P2. Governance fix: keep simulator smoke optional and proof-capped. |
| Goal-drift check | No new Swift code, no simulator acceptance, no visual V-PASS. Gate7 only verifies Gate6 and records optional smoke decision. |
| Authority | UIUE Gate5/Gate6 receipts, main D15/D16 specs/code, Gate4R release. |
| Claim-vs-proof | Local/unit/static/OpenSpec only. No runtime/mobile/true-device/live/UIUE merge/V-PASS/S-PASS/U-PASS/A-2/voice-ready/model-ready/golden-ready/endpoint-ready claim. |
| Boundary | UIUE consumer mapping remains raw stable-name validation; main remains owner of payload/config/force-state truth. |
| If wrong, what proves it | The grep commands above, `RuntimePresentationConsumerMapping.swift`, `RuntimePresentationConsumerMappingTests.swift`, and Hermes Gate6 P2 transcript. |
| Post-audit correction | Hermes single pass returned anchored PASS with P0/P1 empty. P2 requires Gate8 to keep explicit `runtimeStore` / `rawRuntimeStore` negative probes in the final dual-repo route map because `runtimeStore` is protected by generic fail-closed absence rather than a named unit assertion. |

## Audit

- Auditor: Hermes GLM-5.2 code.
- Prompt: `Reports/r5-d17-gate7-20260629T1848/hermes-prompt.txt`
- Transcript: `Reports/r5-d17-gate7-20260629T1848/hermes-output.txt`
- Anchor: `HERMES_R5_D17_GATE_7_UIUE_CONSUMER_VERIFIER_VISUAL_SMOKE_VERDICT: PASS`
- P0: none.
- P1: none.
- P2: Gate8 must repeat explicit negative probes for both `runtimeStore` and `rawRuntimeStore`.
- Controller decision: proceed to Gate8 under local/unit/static/OpenSpec proof cap.

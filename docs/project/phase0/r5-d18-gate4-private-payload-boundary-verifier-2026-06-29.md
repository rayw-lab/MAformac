# R5 D18 Gate 4 Private Payload Boundary Verifier

Date: 2026-06-29
Label: `D18_GATE_4_PRIVATE_PAYLOAD_BOUNDARY_VERIFIER`
Repo: `/Users/wanglei/workspace/MAformac`
UIUE repo: `/Users/wanglei/workspace/MAformac-uiue`
Proof class: `local` / `unit` / `static` / `OpenSpec` / `GitNexus`
Status: `DONE`

## Conclusion

Gate4 verified the private payload boundary between main runtime durability internals and the UIUE presentation consumer. UIUE remains read-only in this gate and does not consume D18 durable ledger names.

The verifier found and fixed one main-owned boundary gap: `rawRuntimeStore` was already forbidden by presentation authority and UIUE deny-list, but main presentation sanitization only redacted `runtimeStore`. The fix adds `rawRuntimeStore` to the main sanitizer and regression tests.

This is local/static/unit boundary proof only. It is not runtime, mobile, true-device, live API, UIUE merge, V-PASS, S-PASS, U-PASS, A-2, voice/model/golden/endpoint readiness, production durable runtime, or R5 completion proof.

## Scope Contract

| Item | Contract |
| --- | --- |
| Goal | Verify and harden that D18 private durable/runtime payload names do not become UIUE-consumable presentation contract. |
| Non-goals | No UIUE writes, no new shared fields, no runtime adapter schema exposure, no production durable runtime proof. |
| Scope in | Main presentation sanitizer/test fix, Gate4 receipt, OpenSpec task ledger, bounded read-only UIUE grep/tests/OpenSpec validation. |
| Scope out | UIUE implementation changes, source dispatch docs, main preserve-unowned dirty, runtime adapter/C3 behavior changes. |
| Writable paths | `Core/Presentation/RuntimePresentationBridge.swift`, `Tests/MAformacCoreTests/RuntimePresentationBridgeTests.swift`, `openspec/changes/define-runtime-adapter-execution/tasks.md`, this receipt. |
| Stop conditions | UIUE consumes D18 durable names, main encoded payload leaks private markers, OpenSpec validation fails, GitNexus reports unexplained HIGH/CRITICAL, staged diff includes no-touch/source dispatch paths. |

## Gate Inputs

| Input | Live truth |
| --- | --- |
| main HEAD before Gate4 | `d61b3c71c590d7caec71c537fdd16858a0740e32` |
| main branch | `codex/rebuild-c6-doc-absorption-20260624` |
| UIUE HEAD | `b588e78199cb88007da8ed8a595d26dc8c836b3f` |
| UIUE branch | `uiue/phase4-default-scope-presentation` |
| Hermes round 1 truth | `HERMES_R5_D18_GATES_1_3_RUNTIME_DURABILITY_VERDICT: FAIL`; P1/P2 fixed post-audit; no rerun by operator override. |

## Verifier Findings

| Probe | Finding | Disposition |
| --- | --- | --- |
| main `RuntimePresentationBridge.swift` private marker grep | Sanitizer covered `runtimeStore`, `rawModelOutput`, `trainingReceipt`, adapter/private ledger names; it did not explicitly cover `rawRuntimeStore`. | Fixed in main sanitizer and tests. |
| main bridge OpenSpec grep | `define-runtime-presentation-bridge` forbids raw runtime store markers and durable/private ledger internals in encoded payloads. | Authority supports the fix. |
| UIUE consumer mapping grep | UIUE deny-list explicitly rejects `rawRuntimeStore`, adapter-private names, fingerprints, ledger internals, raw model output, and training receipts. | Read-only confirmation. |
| UIUE durable-term grep | No matches for `durableLedger`, `persistentLedger`, `adapterLedger`, or `local_durable_adapter_ledger` in UIUE `Core`, `App`, `Tests`, or `openspec`. | UIUE has not started D19 durable guard consumption yet. |

## Implementation

- Added `rawRuntimeStore` to `PresentationPayloadSanitizer.redactedTokens`.
- Added `rawRuntimeStore` to `TraceEnvelope.presentationSafe` default redaction tokens.
- Extended `RuntimePresentationBridgeTests` to assert encoded snapshots, trace messages, trace attributes, and runtime presentation payloads do not leak `rawRuntimeStore`.

This did not add a presentation field, UIUE shared name, runtime adapter field, durable ledger field, or C3 parent-plan field.

## GitNexus

| Probe | Result |
| --- | --- |
| `node .gitnexus/run.cjs analyze` | PASS; refreshed index before edits, 28,298 nodes / 50,329 edges / 300 flows. |
| `context(PresentationPayloadSanitizer)` | Found private enum at `Core/Presentation/RuntimePresentationBridge.swift`; no process membership. |
| `impact(PresentationPayloadSanitizer, upstream, includeTests)` | `LOW`: 0 impacted, 0 affected processes. |
| `impact(TraceEnvelope.presentationSafe#2, upstream, includeTests)` | `LOW`: 12 impacted, 2 direct, 0 affected processes, Presentation module only. |
| `detect_changes(scope=staged)` | `low`: 12 changed symbols, 4 changed files, 0 affected processes. |

## Local Repo Cross-Search

| Scope | Evidence |
| --- | --- |
| main presentation bridge | Private markers appear in sanitizer, tests, and OpenSpec authority; payload tests now include `rawRuntimeStore`. |
| main execution internals | D18 durable ledger names remain under execution implementation/tests/receipts, not UIUE-facing payload contract. |
| UIUE consumer | Forbidden names are deny-list/negative tests/OpenSpec only. |
| UIUE D18 durable terms | No durable ledger term matches in UIUE `Core`, `App`, `Tests`, or `openspec`. |

No web cross-search was needed: Gate4 is a local code/spec boundary verifier, not an external standard or dependency question.

## Pre-Mortem

Gate4 could fail by treating grep hits as leaks without classifying context, by missing case-sensitive near-variants such as `rawRuntimeStore`, by allowing UIUE to consume durable ledger implementation names, or by upgrading local/static proof into runtime/mobile/live acceptance.

The actual pitfall was the near-variant gap: `runtimeStore` was redacted, but `rawRuntimeStore` was separately named in UIUE and authority. A substring assumption would be wrong because the token uses a capital `R`.

## Iceberg Teardown

| Layer | Finding |
| --- | --- |
| Visible symptom | `rawRuntimeStore` was forbidden by authority/UIUE but absent from main redaction token lists. |
| Underlying class | Boundary deny-lists drift when adjacent repos use semantically equivalent but not byte-identical private names. |
| Same-class risk map | main: new private marker variants bypass sanitizer; UIUE: deny-list becomes stronger than upstream authority; docs: "raw runtime store markers" hides exact token drift; tests: only old token is asserted. |
| Immediate fix | Add `rawRuntimeStore` to main sanitizer and tests. |
| Class-level fix | Gate4 receipt records exact token classification and requires future D19 guard to consume only stable authority, not private implementation names. |
| Governance fix | Keep Hermes round 2 over Gates 4-6 and final Claude Code/Codex blind audits covering false proof promotion and private-name leakage. |

## Metacognitive Reflection

The tempting shortcut is to say `runtimeStore` redaction covers raw runtime store. It does not prove that for camel-case private tokens. The safer verifier posture is to compare exact forbidden names across main authority, main sanitizer, UIUE deny-list, and tests.

## Goal-Drift Check

Gate4 stayed main-owned with UIUE read-only verification. It did not start D19, did not add UIUE consumer fields, did not expose durable ledger internals, and did not claim any live/runtime/mobile acceptance.

## Claim vs Proof

| Claim | Evidence | Proof cap |
| --- | --- | --- |
| Main encoded presentation payload redacts `rawRuntimeStore` | `RuntimePresentationBridgeTests` updated and passing | `local/unit` |
| UIUE does not consume D18 durable ledger names before D19 | Bounded UIUE grep no matches for durable terms in `Core`, `App`, `Tests`, `openspec` | `local/static` |
| UIUE rejects private runtime/payload names | `RuntimePresentationConsumerMappingTests` passing and UIUE deny-list grep | `local/unit/static` |
| Production durable runtime is safe | Not claimed. | none |

## Non-Claims

- no production durable runtime proof
- no runtime/mobile/true-device/live API proof
- no UIUE merge or UIUE runtime consumer proof
- no V-PASS, S-PASS, U-PASS, A-2, voice-ready, model-ready, golden-ready, endpoint-ready, or R5 complete claim
- no new shared payload fields, enum values, proof classes, adapter fields, or UIUE-owned runtime truth

## Boundary Check

UIUE must not consume `DemoRuntimeAdapter*`, `RuntimeAdapterBox`, `requestFingerprint`, `parentRequestFingerprint`, `failureLedger`, `successLedger`, `settledParentPlan`, raw runtime store markers, raw model output markers, training receipts, durable ledger internals, C3 settled parent-plan internals, raw model output, or adapter-local private names. Gate4 only verifies and hardens rejection/redaction.

## Self-Question

If this were wrong, the proof would be in `Core/Presentation/RuntimePresentationBridge.swift` missing an exact private token, `Tests/MAformacCoreTests/RuntimePresentationBridgeTests.swift` allowing encoded private markers, or UIUE `Core`/`Tests`/`openspec` containing D18 durable ledger consumption names.

## Post-Audit Correction Rule

Hermes round 2 will audit Gates 4-6 once Gate6 completes. If Hermes round 2 finds P0/P1, do not call this gate Hermes PASS. Fix owned issues, rerun local validation, and continue only under the operator no-rerun cadence if no hard blocker remains.

## Validation

| Command | Result | Proof class |
| --- | --- | --- |
| `swift test --filter RuntimePresentationBridgeTests` | PASS: 18 tests, 0 failures | `local/unit` |
| UIUE `swift test --filter RuntimePresentationConsumerMappingTests` | PASS: 13 tests, 0 failures | `local/unit` |
| UIUE `rg -n "durableLedger|persistentLedger|adapterLedger|local_durable_adapter_ledger" Core App Tests openspec` | PASS: no matches | `local/static` |
| `openspec validate define-runtime-adapter-execution --strict` | PASS | `local/OpenSpec` |
| `openspec validate define-runtime-presentation-bridge --strict` | PASS | `local/OpenSpec` |
| `openspec validate --all --strict` | PASS: 18 passed, 0 failed | `local/OpenSpec` |
| UIUE `openspec validate ui-presentation --strict` | PASS | `local/OpenSpec` |
| `git diff --check` | PASS | `local/static` |
| `git diff --cached --check` | PASS | `local/static` |

## Dirty Split

Expected preserved main dirty remains excluded:

- `AGENTS.md`
- `CLAUDE.md`
- `docs/CURRENT.md`
- `docs/README.md`
- `.xcodebuildmcp/`
- `Tools/agent-platform-plugin-refs/`

Expected UIUE untracked coordination/source artifacts remain read-only and unstaged:

- D12-D18 dispatch docs under `docs/dispatches/`
- `docs/research/2026-06-29-visual-acceptance-standard/`

Gate4 exact owned paths:

- `Core/Presentation/RuntimePresentationBridge.swift`
- `Tests/MAformacCoreTests/RuntimePresentationBridgeTests.swift`
- `openspec/changes/define-runtime-adapter-execution/tasks.md`
- `docs/project/phase0/r5-d18-gate4-private-payload-boundary-verifier-2026-06-29.md`

No `git add .` was used. Source dispatch docs were not staged.

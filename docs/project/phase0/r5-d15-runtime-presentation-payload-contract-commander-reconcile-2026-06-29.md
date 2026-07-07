---
retire_trigger: "Retire when superseded by archived OpenSpec specs or explicit user decision."
expires: "2026-08-15"
---

# R5 D15 - Runtime Presentation Payload Contract Commander Reconcile

Date: 2026-06-29
Label: `D15_GATE_4_UIUE_RECONCILE`
Proof class: `docs/local` + `local_static` + `local_unit` + `OpenSpec` + `GitNexus` + `CC substitute verifier`
Scope: UIUE reconcile receipt, route map, and burndown only

## Verdict

D15 is reconciled under proof cap. Main now defines a stable presentation-safe Runtime -> Presentation payload/readback/reconciliation contract with local/unit proof. UIUE did not implement consumer integration, did not invent shared fields, and did not consume main private adapter fields.

Operator override note: after Gate 3 pitfall absorption, the operator explicitly superseded remaining Hermes audits with CC substitute audit. D15 Gate 3 and Gate 4 therefore do not claim Hermes PASS. CC substitute audit is recorded as reviewer evidence only and does not upgrade proof to runtime/mobile/true-device/live.

## Live Repo Truth

| repo | HEAD before Gate 4 writes | status before Gate 4 writes |
| --- | --- | --- |
| main | `1d9b67412b7fa11fbce5f7b5f52be6f2586c475d` | preserve-unowned dirty only: `AGENTS.md`, `CLAUDE.md`, `docs/CURRENT.md`, `docs/README.md`, `.xcodebuildmcp/`, `Tools/agent-platform-plugin-refs/`; cached empty |
| UIUE | `3bab4c80ee8d360cb7ebdfcfcb8869d6ababb2d7` | untracked D12/D13/D14/D15 source dispatch docs plus `docs/research/2026-06-29-visual-acceptance-standard/`; cached empty |

Gate 4 writable paths:

```text
docs/project/phase0/r5-d15-runtime-presentation-payload-contract-commander-reconcile-2026-06-29.md
docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md
docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/burndown-dispatch-plan.md
```

No UIUE Swift code, source dispatch file, or visual research artifact is staged by this gate.

## Main Evidence Reconciled

| Gate | Main evidence | Interpretation |
| --- | --- | --- |
| Gate 1 | `c212863` and receipt `r5-d15-gate1-runtime-presentation-payload-contract-authority-2026-06-29.md` | OpenSpec defines main-owned stable payload categories and forbidden private-field exposure. |
| Gate 2 | `ab9a682` and receipt `r5-d15-gate2-runtime-presentation-payload-contract-code-2026-06-29.md` | Main adds `RuntimePresentationPayload`, `PresentationReconciliation`, sanitizer, and local/unit tests. |
| Gate 3 | `1d9b674` and receipt `r5-d15-gate3-runtime-presentation-payload-contract-verifier-2026-06-29.md` | Clean-worktree verifier, refreshed GitNexus, UIUE full Swift grep, and CC substitute hard audit PASS after operator override. |

D15 payload exposes stable presentation-safe categories: schema version, trace/turn/event identity after sanitization, terminal flag, outcome, proof class, cards, card semantics, readbacks, reconciliation status, presentation-safe trace, and timestamp.

Forbidden as payload/consumer fields: `DemoRuntimeAdapter*`, `RuntimeAdapterBox`, `requestFingerprint`, `parentRequestFingerprint`, `failureLedger`, success/failure ledger internals, settled parent-plan internals, raw runtime store, raw model output, training receipt, or adapter-local private names.

## UIUE Boundary

UIUE remains a guarded future consumer:

- D15 does not add UIUE Swift code.
- D15 does not parse `RuntimePresentationPayload` in UIUE.
- D15 does not create UIUE-owned shared fields.
- D15 does not claim UIUE merge or D17 consumer integration.
- D17 remains the future UIUE consumer integration lane against the main-owned stable payload contract.

Full UIUE Swift-code grep recorded in Gate 3 found no D15 payload/private adapter token consumption.

## Burndown Disposition

| row | D15 disposition | residual |
| --- | --- | --- |
| `C003` | `covered_by_D15_payload_contract_local_unit`: main-owned payload schema/field carrier. | UIUE consumer integration remains D17. |
| `C024` | `covered_by_D15_payload_contract_local_unit`: presentation-safe trace redaction including identity side channels. | Runtime/mobile/true-device proof remains future. |
| `C062` | `covered_by_D15_payload_contract_local_unit`: raw model/store/training/private markers redacted from encoded payload. | Live model/runtime proof remains future. |
| `C097` | `covered_by_D15_payload_contract_local_unit`: finite proof class surface and proof-cap non-claims. | UIUE fail-closed consumer proof remains D17. |
| `C138` | `covered_by_D15_payload_contract_local_unit`: stable `isTerminal` payload field derived from presentation snapshot. | Runtime adapter private state remains hidden. |
| `C150` | `covered_by_D15_payload_contract_local_unit`: unknown schema/proof/reconciliation decoding fails closed in main tests. | UIUE consumer fail-closed tests remain D17. |
| `C005` | D14 execution ownership proof remains local/unit; D15 removes stale "payload contract future" wording but does not add UIUE consumption. | Durable persistence, production runtime, mobile/true-device/live proof, UIUE payload consumption, and UIUE merge remain future. |
| `C061` | D14 retry/reconciliation proof remains local/unit; D15 exposes presentation-safe reconciliation status only. | Durable retry ledger, production runtime, mobile/true-device/live proof, UIUE payload consumption, and UIUE merge remain future. |

Conservative burndown accounting: strict proof-closed rows move to about `36/215` if the six D15 payload-contract rows are counted. This is still docs/local + local/unit proof only and not runtime/mobile/true-device readiness.

## Harness

Pre-mortem:
Gate 4 could falsely imply UIUE consumer readiness, count D15 as runtime proof, hide the Hermes override, or leave stale D14 wording saying the payload contract is still future.

Lesson learned:
Defining a payload contract and consuming it are separate gates. D15 creates the main-owned vocabulary; D17 must separately prove UIUE parsing, fail-closed behavior, and proof cap.

Local cross-search:
Reviewed D14 reconcile receipt, D15 main receipts, route map D14 snapshot, and burndown rows `C003`, `C005`, `C024`, `C061`, `C062`, `C097`, `C138`, and `C150`.

Iceberg teardown:

| field | finding |
| --- | --- |
| visible symptom | D15 completed the payload contract lane. |
| underlying class | Contract definition can be mistaken for consumer integration or runtime readiness. |
| same-class risk map | UIUE invents fields; UIUE parses private adapter names; map counts local proof as runtime; route order skips D17. |
| immediate fix | Map and burndown explicitly separate D15 payload contract from D17 consumer integration. |
| class-level fix | Future consumer gates must start from main-owned payload names and fail closed on unknown values. |
| governance fix | Stop conditions and non-claims remain in route map and final verdict. |

Goal-drift check:
Gate 4 writes docs only. No UIUE Swift, no main code, no source dispatch, no push, no PR, no merge.

Authority check:
Live main commits `c212863`, `ab9a682`, and `1d9b674`, D15 receipts, OpenSpec validation, tests, GitNexus verifier, and CC substitute audits supersede D14 route prose.

Claim-vs-proof:
D15 proof is docs/local + local_static + local_unit + OpenSpec/GitNexus + CC substitute verifier. It is not runtime, mobile, true-device, live API, UIUE merge, V/S/U-PASS, or A-2 readiness.

Boundary check:
UIUE writable paths are exactly this receipt, the R5 route map, and burndown plan. D12/D13/D14/D15 dispatch source files remain untracked and unstaged.

Self-question:
If this reconcile were wrong, route map or burndown would say UIUE consumed the payload, private adapter fields became public, or D15 proved runtime/mobile readiness. They do not.

Post-audit correction rule:
Any CC substitute high/P0/P1 finding, staged source dispatch/UIUE Swift/no-touch path, proof promotion, or missing local validation blocks Gate 4.

## Validation Evidence

```text
git diff --check: PASS
openspec validate ui-presentation --strict: PASS
git diff --cached --name-status: exactly 3 UIUE docs
git diff --cached --check: PASS
CC substitute hard audit: PASS
findings_high_P0_P1: []
findings_P2_lower: []
confidence: high
```

## Non-Claims

- no R5 complete
- no runtime-ready
- no mobile proof
- no true_device proof
- no voice-ready
- no model-ready
- no golden-ready
- no endpoint-ready
- no production runtime proof
- no durable ledger proof
- no live API proof
- no UIUE merge
- no UIUE runtime consumer integrated
- no D17 complete
- no V-PASS / S-PASS / U-PASS
- no A-2 ready / complete

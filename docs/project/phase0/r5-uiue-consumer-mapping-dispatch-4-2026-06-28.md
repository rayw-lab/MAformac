---
retire_trigger: "Retire when superseded by archived OpenSpec specs or explicit user decision."
expires: "2026-08-15"
---

# UIUE R5 Dispatch 4 Consumer Mapping Receipt

Date: 2026-06-28
Label: `UIUE_R5_DISPATCH_4_UIUE_CONSUMER_MAPPING`
Status: `PASS_WITH_NOTES`

## Scope Contract

- Goal: map UIUE presentation consumers against stable mainline Runtime-Presentation names without defining shared runtime payloads.
- Non-goals: no mainline edits, no runtime adapter wiring, no production force-state behavior, no mobile/true-device/live proof, no UIUE merge claim.
- Writable paths used:
  - `/Users/wanglei/workspace/MAformac-uiue/Core/Presentation/RuntimePresentationConsumerMapping.swift`
  - `/Users/wanglei/workspace/MAformac-uiue/Tests/MAformacCoreTests/RuntimePresentationConsumerMappingTests.swift`
  - `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-uiue-consumer-mapping-dispatch-4-2026-06-28.md`
- No-touch paths: `/Users/wanglei/workspace/MAformac/**`; existing untracked dispatch/map docs were read but not modified.
- Validation gates: focused Swift tests, OpenSpec validation for `ui-presentation`, `git diff --check`, Codex native subagent audit.
- Stop condition: any unresolved P0/P1 from Codex subagent audit keeps final status below DONE.

## Mapping Table

| surface | mainline_name_or_semantics | UIUE_consumer_path | proof_path | proof_class | status | residual |
| --- | --- | --- | --- | --- | --- | --- |
| event kind | `text_input`, `mic_start`, `mic_end`, `card_tap`, `cancel`, `interruption`; `timeout` excluded | `/Users/wanglei/workspace/MAformac-uiue/Core/Presentation/RuntimePresentationConsumerMapping.swift` | `/Users/wanglei/workspace/MAformac-uiue/Tests/MAformacCoreTests/RuntimePresentationConsumerMappingTests.swift` | `local_unit` | consumed | UIUE does not parse runtime event payloads yet. |
| event source | `user`, `system`, `demo_harness`, `runtime_adapter` | same | same | `local_unit` | consumed | Kept separate from `ScopeOrigin.defaulted/explicit/fanout`. |
| runtime result | `accepted_tool_call` -> `.acceptedToolCall` -> `.satisfied` / `.stateCommit` | same | same | `local_unit` | consumed | Presentation-only projection. |
| runtime result | `clarify_missing_slot` -> `.clarifyMissingSlot` -> `.blocked_with_alternative` / `.clarificationPulse` | same | same | `local_unit` | consumed | No Chinese display-copy parsing. |
| runtime result | `refusal_no_available_tool` -> `.refusalNoAvailableTool` -> `.blocked_hard` / `.refusalShake` | same | same | `local_unit` | consumed | Presentation-only projection. |
| runtime result | `refusal_safety_or_policy` -> `.refusalSafetyOrPolicy` -> `.unsafe` / `.safetyPulse` | same | same | `local_unit` | consumed | Presentation-only projection. |
| runtime result | `already_state_noop` -> `.alreadyStateNoop` -> `.satisfied` / `.steadyAcknowledge` | same | same | `local_unit` | consumed | Presentation-only projection. |
| runtime result | `runtime_error` -> `.runtimeError` -> `.unknown` / `.staticError` | same | same | `local_unit` | consumed | Also covers terminal `timeout`; `timeout` is not minted as a result or event. |
| runtime result | `cancelled` -> `.cancelled` -> `.normal` / `.cancellationFade` | same | same | `local_unit` | consumed | Presentation-only projection. |
| runtime result | `interrupted` -> source name preserved, UIUE visual surface reuses `.cancelled` | same | same | `local_unit` | consumed_with_note | No new UIUE/shared enum minted for a separate interrupted visual. |
| proof cap | `docs_local`, `local_unit`, `simulator_mock` | same | same | `local_unit` | consumed | UIUE proof cap only; no promotion beyond local/simulator. |
| terminal stop | `timeout` -> `runtime_error`; `interrupted/backgrounding` -> `interrupted` | same | same | `local_unit` | consumed | Terminal result mapping only, not event-kind mapping. |
| C034 Reduce Motion | non-animation/static feedback channel | `/Users/wanglei/workspace/MAformac-uiue/Core/Presentation/PresentationReducedMotionPolicy.swift` | `/Users/wanglei/workspace/MAformac-uiue/Tests/MAformacCoreTests/PresentationReducedMotionPolicyTests.swift` | `local_unit` | consumed | UIUE local presentation policy only. |

## Row Disposition Table

| row_id | before | after | disposition | proof_path | proof_class | validation | remaining_gap_or_next_owner |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `C012` | covered_for_dispatch_1 | consumable by UIUE mapping | stable terminal snapshot DTO semantics consumed | `RuntimePresentationConsumerMappingTests` | `local_unit` | focused Swift tests | Future runtime adapter proof stays mainline. |
| `C060` | covered_for_dispatch_1 | consumable by UIUE mapping | terminal stop semantics consumed | same | `local_unit` | focused Swift tests | No UIUE runtime proof. |
| `C017` | covered_for_dispatch_1 | consumable by UIUE mapping | partial/denial result projection consumes existing matrix; no new shared enum | same | `local_unit` | focused Swift tests | Composite runtime behavior remains mainline. |
| `C022` | covered_for_dispatch_1 | consumable by UIUE mapping | terminal snapshot/readback semantics treated as source fields, not display parsing | same | `local_unit` | focused Swift tests | No runtime adapter wiring. |
| `C006` | accepted_dispatch_2 | consumed for stable event kind list | consumer mapping row | same | `local_unit` | focused Swift tests | Runtime event ingestion not implemented. |
| `C007` | accepted_dispatch_2 | consumed for stable event source list | consumer mapping row | same | `local_unit` | focused Swift tests | Event source not conflated with scope origin. |
| `C024` | accepted_dispatch_2 | consumed for runtime result names | consumer mapping row | same | `local_unit` | focused Swift tests | No shared enum minted in UIUE. |
| `C029` | accepted_dispatch_2 | consumed for trace/snapshot proof cap policy | proof cap row | same | `local_unit` | focused Swift tests | No trace runtime proof. |
| `C030` | accepted_dispatch_2 | consumed for presentation-safe projection policy | structured-source row | same | `local_unit` | focused Swift tests | No raw model/store/training leak introduced. |
| `C143` | accepted_dispatch_2 | consumed as append-only/monotonic trace contract note only | proof cap row | same | `local_unit` | focused Swift tests | Mainline trace behavior proof remains mainline-owned if expanded. |
| `C034` | UIUE mapping target | local policy covered | local UIUE Reduce Motion policy | `PresentationReducedMotionPolicyTests` | `local_unit` | focused Swift tests | No mobile/true-device accessibility proof. |
| `C155` | accepted product policy candidate | local policy only | local UIUE wording/affordance policy | receipt | `docs_local` | receipt + grep | No shared field or runtime payload. |
| `C172` | accepted product policy candidate | local policy only | local UIUE wording/affordance policy | receipt | `docs_local` | receipt + grep | No shared field or runtime payload. |
| `C194` | accepted product policy candidate | local policy only | local UIUE wording/affordance policy | receipt | `docs_local` | receipt + grep | No shared field or runtime payload. |
| `C005` | deferred gate | still deferred | `deferred_mainline_owner` | `RuntimePresentationConsumerMappingTests` | `local_unit` | focused Swift tests | mainline runtime adapter write ownership. |
| `C018` | deferred gate | still deferred | `deferred_mainline_owner` | same | `local_unit` | focused Swift tests | mainline Core config / SceneMacroRegistry authority. |
| `C052` | deferred gate | still deferred | `deferred_mainline_owner` | same | `local_unit` | focused Swift tests | mainline force-state lane. |
| `C061` | deferred gate | still deferred | `deferred_mainline_owner` | same | `local_unit` | focused Swift tests | mainline retry/idempotency/no-double-write execution tests. |
| `C082` | K1 spike ledger | unchanged | `spike_before_implementation` | `RuntimePresentationConsumerMappingTests` | `local_unit` | focused Swift tests | future spike. |
| `C083` | K1 spike ledger | unchanged | `spike_before_implementation` | same | `local_unit` | focused Swift tests | future spike. |
| `C096` | K1 spike ledger | unchanged | `spike_before_implementation` | same | `local_unit` | focused Swift tests | future spike. |
| `C117` | K1 spike ledger | unchanged | `spike_before_implementation` | same | `local_unit` | focused Swift tests | future spike. |
| `C182` | K1 spike ledger | unchanged | `spike_before_implementation` | same | `local_unit` | focused Swift tests | future spike. |
| `C197` | K1 spike ledger | unchanged | `spike_before_implementation` | same | `local_unit` | focused Swift tests | future spike. |
| `C207` | K1 spike ledger | unchanged | `spike_before_implementation` | same | `local_unit` | focused Swift tests | future spike. |
| `C208` | K1 spike ledger | unchanged | `spike_before_implementation` | same | `local_unit` | focused Swift tests | future spike. |

## Deferred Gates

| gate | status | next owner |
| --- | --- | --- |
| `C005` | still `deferred_mainline_owner` | mainline runtime adapter |
| `C018` | still `deferred_mainline_owner` | mainline Core config / SceneMacroRegistry authority |
| `C052` | still `deferred_mainline_owner` | mainline force-state lane |
| `C061` | still `deferred_mainline_owner` | mainline retry/idempotency/no-double-write execution tests |

## K1 Status

Untouched spike ledger: yes.

Rows preserved as `spike_before_implementation`: `C082`, `C083`, `C096`, `C117`, `C182`, `C197`, `C207`, `C208`.

## Validation

| command | result | proof_class |
| --- | --- | --- |
| `swift test --filter RuntimePresentationConsumerMappingTests` | PASS: 9 tests, 0 failures | `local_unit` |
| `swift test --filter PresentationReducedMotionPolicyTests` | PASS: 7 tests, 0 failures | `local_unit` |
| `swift build` | PASS: build complete; SwiftPM reported two pre-existing unhandled UI test resource warnings | `local` |
| `openspec validate define-runtime-presentation-bridge --strict` in `/Users/wanglei/workspace/MAformac` | PASS: mainline bridge change valid; read-only reference check | `docs_local` |
| `openspec validate ui-presentation --strict` | PASS: `ui-presentation` is valid | `docs_local` |
| `git diff --check` | PASS: no whitespace errors | `local` |
| Codex native subagent audit | PASS_WITH_NOTES: no P0/P1 findings; P2 validation wording fixed in this receipt | `local` |

## Non-Claims

This receipt does not claim R5 completion, runtime readiness, mobile proof, true-device proof, voice readiness, model readiness, golden readiness, endpoint readiness, UIUE merge, V/S/U proof, or A-2 completion.

## Residual Risks

- UIUE has no separate local visual enum for `interrupted`; current mapping preserves the mainline result name and renders with the existing cancellation surface.
- UIUE has not implemented runtime payload parsing, runtime adapter wiring, production force-state behavior, or mobile/true-device accessibility proof.
- Subagent residual P3: this lane had no `lsp_diagnostics` tool surface; focused Swift tests and SwiftPM build diagnostics covered compile/type checks for the touched files.

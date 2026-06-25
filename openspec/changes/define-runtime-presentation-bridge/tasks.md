> 🔴 **Planning-artifact vs implementation-task status**: proposal/design/spec are **authored and strict-validated** (so `openspec status` reports artifacts complete / `isComplete=true`). The checkboxes below are **downstream contract-implementation/review tasks**; unchecked items are NOT execution authorization and do NOT imply Swift implementation is complete. `0/N tasks` here means "contract authored, implementation not started", not "work missed".
>
> ✅ **Accepted by 磊哥 2026-06-25**: the contract is stable enough for **A-2 ui-presentation visual consumption via mock snapshots**. This acceptance is NOT a runtime-readiness/V-PASS claim; mainline runtime-side implementation review is still pending.

## 1. Proposal validation

- [x] 1.1 Validate this change with `openspec validate define-runtime-presentation-bridge --strict`. (pass, 2026-06-25)
- [x] 1.2 Validate all OpenSpec with `openspec validate --all --strict`. (16 passed, 0 failed)
- [x] 1.3 Run `git diff --check`. (clean, exit 0)

## 2. Contract fields — events

- [ ] 2.1 Define `DemoInteractionEvent` event kinds: text input, mic start, mic end, ASR text, ASR empty, card tap, value adjust, reset, force-macro, **force-context-state (demo-mode)**, cancel, interruption, timeout.
- [ ] 2.2 Define `DemoInteractionEvent` payload: family id, cell key, action kind, raw value, display value, scope, `scope_origin`, **`source` (provenance, distinct from `scope_origin`)**, revision, trace id, initiator.

## 3. Contract fields — results

- [ ] 3.1 Define `DemoRuntimeResult.result_kind`: `accepted_tool_call`, `clarify_missing_slot`, `refusal_no_available_tool`, `refusal_safety_or_policy`, `already_state_noop`, `runtime_error`, `cancelled`, **`partial_accept_partial_refuse`**. A display-layer `rejected` aggregate is allowed only if it also carries a machine-readable `rejection_class`.
- [ ] 3.2 Define `already_state_noop` as distinct (not unsupported/safety), with renderer-owned already-state readback and no store mutation.
- [ ] 3.3 Define `partial_accept_partial_refuse` with `per_action_results[]` so one combined snapshot carries mixed per-card outcomes plus one composite readback.
- [ ] 3.4 Define `active_cell` and `refused_cell` on the result/snapshot, distinct from a family primary cell.

## 4. Contract fields — snapshot

- [ ] 4.1 Define `PresentationSnapshot` fields: `trace_id`, `cards`, `dialog_text`, `readbacks`, `scope_origin`, `voice_state`, `orb_state`, **`context{vehicle:{speed,gear}, environment:{weather,time_period}}` 四维**（diorama composite，见 4.3；optional `resolved_scene`）, and finite-enum `proof_class` with display caps and unknown-value fail-closed behavior.
- [ ] 4.2 Define the card schema: family id, cell id, title, value, unit, visual state, `scope_origin`, **`sibling_cells` (for semantic styling: cooling/heating mode + active-cell substitution)**, `active_cell`, reason, available actions, last update.
- [ ] 4.3 Define `context` as **distinct dimensions** `vehicle{speed, gear}` + `environment{weather, time_period}` (NOT a single pre-resolved scene; the SD24 diorama capsule composites them, e.g. night⊕driving⊕rain layered) + force-context provenance; an optional `resolved_scene` name MAY be offered for convenience; weather/time are context inputs and display facts, not device cards.

## 5. Contract fields — trace + gates

- [ ] 5.1 Define `TraceEnvelope` as a presentation-safe view over C3 decode, plan, guard, execute, and readback stages.
- [ ] 5.2 Define event-driven thinking gates: `cards_did_start_changing`, `readback_ready`, `tts_start`, `tts_end`, `timeout`, `fallback`.
- [ ] 5.3 Define the two thinking semantics: analyzing think (event-driven, backend-masking) vs safety-refusal think (legitimate fixed short display) — the gates MUST NOT delete the fixed safety display.
- [ ] 5.4 Define minimal runtime boundary behavior: off-main execution for runtime work, terminal snapshots for cancel/interruption/timeout, and no persistence, cloud sync, or long-lived user memory (3-turn dialogue context excepted).

## 6. Red lines

- [ ] 6.1 Do not implement Swift in this contract-only change.
- [ ] 6.2 Do not modify UIUE or Core Swift code in this change (contract docs only).
- [ ] 6.3 Do not claim runtime/backend/model/voice/endpoint/golden-run readiness or V/S/U-PASS from contract validation.
- [ ] 6.4 Do not redefine C2/C3 semantics; reuse existing Core concepts (`DemoVehicleValueSource`, `DemoActionReadback`, `DemoVehicleStateCell`, `C3ExecutionResult`, `TraceEntry`, `DemoVisualState`, `ScopeResolution`).

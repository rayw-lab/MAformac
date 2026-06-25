# Runtime-Presentation Bridge Design

> Authority: design rationale for `define-runtime-presentation-bridge` (contract-only).
> Source decisions: `docs/grill-checklist/uiue-runtime-bridge-decisions-2026-06-25.md` (RPB-01~53), `docs/uiue-storyboard-grill-decisions.md` (SD18-24), parent roadmap Task 2.
> AD-RPB-001~007 build on the roadmap draft; AD-RPB-008~014 add the RPB decision-table enrichments (partial-deny, active/refused cells, sibling cells, source vs scope_origin, already-state, thinking gates, force-state context).

## AD-RPB-001: Contract-first, implementation-later

The bridge defines event/result/snapshot/trace vocabulary before runtime backend or UIUE merge work. Allowed before model/C6 gates because it does not execute a model, train data, wire an endpoint, or claim readiness. Implementation (mainline runtime projection + UIUE consumption) is downstream.

## AD-RPB-002: UIUE consumes snapshots, not stores

UIUE SHALL consume a `PresentationSnapshot`. It SHALL NOT depend directly on `DemoVehicleStateStore`, raw trace arrays, model output, or training receipts. (Evidence: uiue `Core/Presentation/*` already imports only Foundation/Observation and consumes `[DemoVehicleStateCell]` as input — RPB-04.) Pure preview/spike may read the store behind a debug flag, marked as not-a-contract.

## AD-RPB-003: Scope origin is single-source

Every readback and presentation scope label SHALL carry `scope_origin` from Core scope resolution (`ScopeResolution.origin`). UIUE may choose visual emphasis (defaulted = low-emphasis / elided per G18), but it MUST NOT infer defaulted/explicit/fanout/missing from display strings — RPB-08.

## AD-RPB-004: Voice and orb are presentation state, not proof of voice readiness

The bridge may expose `voice_state` and `orb_state` for UI choreography. These fields do not imply ASR/TTS functional readiness, demo-golden-run pass, endpoint readiness, or V-PASS — RPB-23/RPB-33.

## AD-RPB-005: Runtime result vocabulary preserves refusal class

The bridge SHALL NOT expose a bare `rejected` result as the only runtime outcome. It MUST preserve at least unsupported/no-tool refusal and safety/policy refusal as distinct machine-readable values — RPB-09/RPB-10. (D7 four-state separation: clarify ≠ unsupported ≠ safety ≠ crash.)

## AD-RPB-006: Presentation proof classes are finite and display-capped

`PresentationSnapshot.proof_class` SHALL use a finite project vocabulary. Unknown values fail closed, and local/static/external-review proof MUST never be displayed as endpoint-ready, voice-ready, C6-ready, or V/S/U-PASS — RPB-25/RPB-36.

## AD-RPB-007: Minimal endpoint runtime boundaries

Runtime work feeding the bridge SHALL avoid blocking the main thread, SHALL emit a terminal snapshot on cancel/interruption/timeout, and SHALL NOT introduce persistence, cloud sync, or long-lived user memory (short-lived 3-turn dialogue context excepted) — RPB-22/RPB-37/RPB-38.

---

## AD-RPB-008: Result vocabulary includes partial-accept-partial-refuse

The runtime result vocabulary SHALL include `partial_accept_partial_refuse` for mixed-outcome turns (e.g. "open window and open tailgate while moving" → window satisfied + tailgate refused). The bridge SHALL carry per-action outcomes so presentation renders one combined snapshot with mixed per-card states and one composite readback — RPB-17/CC-A4. (Roadmap draft omitted this; mainline C3 currently throws on first guard denial, so partial-deny is a contract gap to fill.)

## AD-RPB-009: Snapshot carries active cell and refused cell

`PresentationSnapshot` SHALL carry, per turn, an `active_cell` (the cell this turn changed/focuses) and, for refusals, a `refused_cell` (the cell that was denied). These are distinct from a family's primary cell. Rationale: a family's summary primary cell may not be the cell that changed or was refused — RPB-29/RPB-51, CC1 (seat backrest/vent changed but primary is heat_level), CC-B1 (tailgate refused but primary is central_lock). Presentation MAY let a refused cell or active cell outrank the satisfied/primary cell for visual priority.

## AD-RPB-010: Card schema carries sibling cells for semantic styling

A snapshot card SHALL be able to carry, alongside its displayed cell, the family's relevant **sibling cells** (or at least the styling-driving cell). Rationale: cooling-blue / heating-red styling (SD20) reads `ac.mode` alongside `ac.temp_setpoint`; active-cell substitution (CC1) reads the changed sibling. Without sibling carriage, semantic value coloring and active-cell display cannot render from the snapshot alone — RPB-30/RPB-51. (This corrects the earlier classification of cooling/heating color as pure `visual_only`: the rendering logic is visual_only, but it depends on `shared_bridge_contract` sibling carriage.)

## AD-RPB-011: Value provenance and scope resolution are two orthogonal fields

The bridge SHALL distinguish two fields that must never be merged — RPB-08:
- `source` = value provenance (who/what set the value): reuse `DemoVehicleValueSource{mock, user, system}` (`Core/State/DemoVehicleStateStore.swift`), extended for bridge input with `ui_touch` and `voice`. Internal provenance; not customer-facing.
- `scope_origin` = scope resolution (how the 温区 scope was determined): reuse the existing `ScopeOrigin` enum (`Core/Execution/ScopeResolution.swift`, field `ScopeResolution.origin`), **current values `defaulted, explicit, fanout`**. Customer-facing structured metadata (AD-RPB-003).

(Clarification — RPB-08 / parent roadmap were imprecise about where the enum lives: the value-provenance enum is `DemoVehicleValueSource` (in the store); the scope-resolution enum is `ScopeOrigin` (in `ScopeResolution`). They are two distinct enums, no naming collision. 🔴 A `missing` scope-origin value (scope unresolvable / absent) is a **bridge-proposed future addition, NOT a current Core value** — current `ScopeOrigin` has only `defaulted/explicit/fanout`; if `missing` is adopted it requires extending `ScopeOrigin` or a separate presentation scope enum, to be settled at mainline co-authorship.)

## AD-RPB-012: Already-state is a distinct result mapped to a satisfied presentation

The bridge SHALL classify a no-op-because-already-true outcome as `already_state_noop`, distinct from accepted/unsupported/safety/clarify and never collapsed into them (c06 schema `already_state_must_not_be_collapsed_into_unsupported_or_safety`) — RPB-14. Presentation reuses the `satisfied` visual but distinguishes it from a fresh change: no revision bump, no numeric-roll, an acknowledgment cue, and an already-state readback. The bridge does NOT require an 8th `DemoVisualState`; the **result vocabulary** keeps `already_state_noop` separate while the **visual state** maps to `satisfied`.

## AD-RPB-013: Event-driven thinking gates with two thinking semantics

The bridge SHALL expose event-driven gates rather than fixed visual delays — RPB-21: `cards_did_start_changing` (handoff signal), `readback_ready`, `tts_start`, `tts_end`, plus `timeout` and `fallback`. Thinking has **two semantics** that MUST be distinguishable — RPB-53:
- **analyzing think** = event-driven, masks backend work, ends on `cards_did_start_changing`.
- **safety-refusal think** = a legitimate fixed short display (≈1.0s) that is NOT a backend-masking delay.

A blanket "no fixed delays" rule MUST NOT delete the legitimate safety-refusal fixed display.

## AD-RPB-014: Demo-mode force-state context input feeds a context surface (four dimensions, not one scene)

Demo-mode console force-state (driving speed/gear, weather, time period) SHALL be expressed as a force-context event that mutates runtime context **through a bridge event** (not a direct store write), so the safety guard reading `vehicle.speed` has traceable provenance — RPB-52. 🔴 The bridge SHALL expose the **full context as distinct dimensions** — `vehicle{speed, gear}` + `environment{weather, time_period}` — **NOT a single pre-resolved scene name**, because the presentation context surface (SD24 diorama「活体迷你窗」capsule) **composites** these dimensions into one animated mini-scene (e.g. night ⊕ driving ⊕ rain rendered as layered sky + moving car + rain overlay together). A presentation-side priority-resolved scene name MAY be offered as a convenience, but the four dimensions are the contract. Weather/time are context inputs and display facts, not device cards — RPB-19. Force-state is demo-mode-isolated and MUST NOT be reachable in a customer-facing build.

## Object summary (proposed names; freeze in spec/tasks)

- `DemoInteractionEvent` — text input / mic start / mic end / ASR text / ASR empty / card tap / value adjust / reset / force-macro / force-context-state / cancel / interruption / timeout; payload: family id, cell key, action kind, raw value, display value, scope, `scope_origin`, `source`, revision, trace id, initiator.
- `DemoRuntimeResult` — `result_kind ∈ {accepted_tool_call, clarify_missing_slot, refusal_no_available_tool, refusal_safety_or_policy, already_state_noop, runtime_error, cancelled, partial_accept_partial_refuse}`; `active_cell`, `refused_cell`, `reason`, `readback`, `per_action_results[]`.
- `PresentationSnapshot` — `trace_id`, `cards[]{family_id, cell_id, title, value, unit, visual_state, scope_origin, sibling_cells, active_cell, reason, available_actions, last_update}`, `dialog_text`, `readbacks`, `voice_state`, `orb_state`, `context{vehicle:{speed, gear}, environment:{weather, time_period}}` (four dimensions for the diorama capsule; optional `resolved_scene` convenience), finite-enum `proof_class`.
- `TraceEnvelope` — presentation-safe view over C3 decode/plan/guard/execute/readback stages: trace id, event id, request text, normalized intent, guard result, transitions, readbacks, proof class, timestamps, redactions.

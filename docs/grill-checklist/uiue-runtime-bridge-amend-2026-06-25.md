# UIUE Runtime Bridge Grill Amend - 2026-06-25

---
status: amend_checklist
artifact_kind: runtime_grill_amend
authority: discussion_input_not_ssot
owner_lane: UIUE isolation tree
created_at: 2026-06-25
mainline_repo: /Users/wanglei/workspace/MAformac
mainline_head_live_verified: de79c653685ff4835cc74b04106120b6e785e491
uiue_repo: /Users/wanglei/workspace/MAformac-uiue
uiue_head_live_verified: 9cf1af2b503af9f7980b7bffbce85914f8fcaf42
proof_class: local_repo_doc_truth
---

## Purpose

This amend file adds runtime-facing grill bullets for the UIUE commander. It is a companion to `docs/grill-checklist/UIUE-checklist.md` and the current UIUE design docs. It does not replace `docs/grill-tournament/grill-decisions-master.md`, OpenSpec, or any future Runtime-Presentation Bridge proposal.

The visual and interaction grill has mostly converged. The remaining risk is that UIUE is no longer a pure visual prototype: the storyboard now crosses touch controls, current vehicle state, voice text, runtime refusal, unsafe context, scene macros, and readback. Those areas need a bridge contract before UIUE hardens code that later conflicts with the non-UIUE mainline.

## Live Head Baseline

### Mainline repo

- Repo: `/Users/wanglei/workspace/MAformac`
- Branch: `codex/rebuild-c6-doc-absorption-20260624`
- Live HEAD: `de79c653685ff4835cc74b04106120b6e785e491`
- Dirty state at capture:
  - modified: `CLAUDE.md`
  - modified: `docs/CURRENT.md`
  - untracked: `Tools/agent-platform-plugin-refs/`
- Current roadmap stance:
  - Runtime-Presentation Bridge is intended but not yet proposed.
  - Runtime backend is deferred, not absent.
  - UIUE stays isolated unless state, C3-C6, readback, golden, or bridge fields intersect.
  - No training, no C6 acceptance, no golden-run, no voice endpoint, no UIUE merge from this amend.

### UIUE isolation repo

- Repo: `/Users/wanglei/workspace/MAformac-uiue`
- Branch: `uiue/phase4-default-scope-presentation`
- Live HEAD: `9cf1af2b503af9f7980b7bffbce85914f8fcaf42`
- Dirty state at capture:
  - modified: `CLAUDE.md`
  - modified: `docs/CURRENT.md`
  - modified: `docs/design/tokens.md`
  - untracked: `Tools/agent-platform-plugin-refs/`
  - untracked: `docs/UIUE-checklist.md`
  - untracked: `docs/design/anchors/`
  - untracked: `docs/design/gptimage2-anchor-set/`
  - untracked: `docs/uiue-storyboard-grill-decisions.md`
  - untracked: `docs/uiue-todo-and-grill-upgrade-2026-06-25.md`

## Mainline Runtime Truth To Respect

- `Core/State/DemoVehicleStateStore.swift` already has `DemoVisualState`, `ScopeOrigin`, and `DemoActionReadback`, but the current mock transition mostly lands `satisfied` or `normal`. It does not yet expose a full reason map, active cell map, or guard-block application API.
- `Core/Execution/C3ExecutionPipeline.swift` returns `C3ExecutionResult(traceID, readbacks)`. Guard denials currently throw `ToolExecutionError.guardDenied`; they are not yet projected into a presentation-safe refusal snapshot.
- `Core/Intent/FastPathIntentEngine.swift` is still narrow. The current fast path recognizes only the exact text `打开空调`.
- `Core/Trace/TraceLogger.swift` records stage events and attributes, but there is no frozen `TraceEnvelope` object for UIUE.
- `docs/project/phase0/c06-runtime-outcome-enum-skeleton.schema.yaml` is a skeleton only. It seeds `already_state` and `already_state_readback`, but does not freeze downstream UIUE result enums.
- The parent roadmap proposes a bridge shape around `DemoInteractionEvent`, `DemoRuntimeResult`, `PresentationSnapshot`, and `TraceEnvelope`, but that shape is not yet an accepted OpenSpec change.

## Runtime Necessity

If UIUE hardens runtime behavior without an explicit bridge, five bad outcomes become likely:

- UIUE invents result words that do not match C3/C6 proof classes.
- UI cards read or mutate store internals directly, making later backend routing brittle.
- Safety refusal, unsupported, clarify, already-state, and runtime error collapse into one visual "rejected" bucket.
- Voice/orb animation is mistaken for backend or model readiness.
- Touch-control demos look complete while the runtime contract for trace, readback, cancellation, and partial-deny remains undefined.

The practical goal is not to over-engineer. The goal is a thin contract that lets UIUE present rich state while mainline owns runtime truth.

## Requirement To UIUE Commander

For each grill bullet below, return a decision row with:

- `question_id`
- `decision`: `accept_contract`, `prototype_allowance`, `defer_to_bridge`, or `reject`
- `evidence`: exact file and line reference
- `owner`: UIUE, mainline runtime, shared bridge, or later training
- `landing_target`: doc, OpenSpec proposal, code prototype, or no-op
- `allowed_before_bridge`: yes or no
- `validation_gate`: local test, simulator runtime, screenshot, trace receipt, or none
- `residual_risk`

Do not claim external pass, C6 acceptance, model quality, retrain readiness, golden-run readiness, voice readiness, endpoint readiness, or V-PASS from this amend. This file is for contract discussion and UIUE grill completion only.

## Grill Bullets

### P0 - Must Decide Before Runtime-Dependent UIUE Code Freezes

- [ ] RPB-01 - Boundary override: `docs/uiue-storyboard-grill-decisions.md` still contains an older "do not touch Core/Contracts" stance, while SD7 relaxes the boundary toward shared backend mock state. Which rule is current for Phase 4/5 UIUE work?
- [ ] RPB-02 - Three-lane split: classify every runtime-related UIUE change as `visual_only`, `prototype_adapter`, or `shared_bridge_contract`. Do not let prototype adapters silently become mainline runtime.
- [ ] RPB-03 - Bridge object names: confirm whether the discussion baseline remains `DemoInteractionEvent`, `DemoRuntimeResult`, `PresentationSnapshot`, and `TraceEnvelope`, or choose different names before code spreads alternatives.
- [ ] RPB-04 - Store ownership: should UIUE consume snapshots only, or may it read `DemoVehicleStateStore` directly for certain preview/prototype surfaces?
- [ ] RPB-05 - Write ownership: should touch controls write through the same runtime executor path as voice, or may they call the store directly with a separate `ui_touch` source?
- [ ] RPB-06 - Interaction events: enumerate the allowed event set: text input, mic start, mic end, ASR text, ASR failure, card tap, value adjust, reset, force macro, scene macro, cancel, interruption, timeout.
- [ ] RPB-07 - Event payload: define required fields for card and touch events: family id, cell key, action kind, raw value, display value, scope, `ScopeOrigin`, source, revision, trace id, and initiator.
- [ ] RPB-08 - Scope origin display: decide how `defaulted`, `explicit`, `fanout`, and `missing` appear in cards, dialogue, and TTS readback. UI must not infer scope from Chinese copy alone.
- [ ] RPB-09 - Result enum: distinguish at least `accepted_tool_call`, `clarify_missing_slot`, `unsupported_no_tool`, `refusal_safety_or_policy`, `already_state_noop`, `runtime_error`, `cancelled`, and `partial_accept_partial_refuse`.
- [ ] RPB-10 - Refusal vocabulary: forbid bare `rejected` unless the machine-readable source is also present. `unsupported`, `safety`, `clarify`, and `already_state` are not interchangeable.
- [ ] RPB-11 - Visual state mapping: map every runtime result to `DemoVisualState` or a new presentation state. Confirm whether current states are enough: `normal`, `satisfied`, `changing`, `blocked_with_alternative`, `blocked_hard`, `unsafe`, `unknown`.
- [ ] RPB-12 - Guard denial path: current C3 guard denial throws. Decide whether UIUE needs a presentation-safe `applyGuardBlock` or a bridge-level refusal snapshot before unsafe demos.
- [ ] RPB-13 - Unsafe R2 example: for high-speed tailgate or door refusal, decide the exact active cell, refused cell, reason copy, icon, TTS copy, and trace result. Do not show speed as a controllable vehicle cell if it is only context.
- [ ] RPB-14 - Already-state behavior: for "空调已经开着", decide whether the card pulses, stays satisfied, increments revision, emits readback, or writes no store mutation.
- [ ] RPB-15 - Clamp behavior: for out-of-range values, decide whether the runtime clamps and succeeds, asks clarify, or refuses. Specify displayed value, spoken value, and trace reason.
- [ ] RPB-16 - Multi-intent splitter: decide whether Phase 4/5 requires a real splitter, a force-state macro, or a storyboard-only sequencing adapter. Current handoff says multi-intent runtime is still a gap.
- [ ] RPB-17 - Partial-deny terminal state: for "open window and lock child lock" style mixed outcomes, define whether UIUE shows one combined snapshot or multiple per-action snapshots.
- [ ] RPB-18 - Scene macro ownership: decide whether `SceneMacroRegistry` is UIUE-only, shared runtime config, or later model/router input. It must not become a hidden planner without trace.
- [ ] RPB-19 - Environment context: weather and `time_period` can affect copy and scene presets. Decide whether they are store cells, context inputs, or UI-only display facts.
- [ ] RPB-20 - Normal run preset: define what reset actually clears: vehicle state, desired state, reasons, dialogue, trace, orb state, voice state, context, and macro queue.
- [ ] RPB-21 - Event-driven thinking: replace fixed visual delays with event-driven gates. Define `cardsDidStartChanging`, `readbackReady`, `ttsStart`, `ttsEnd`, timeout, and fallback.
- [ ] RPB-22 - Cancellation and interruption: define terminal snapshots for cancel, barge-in, ASR abort, timeout, and app backgrounding. Stale async updates must not mutate cards after cancellation.
- [ ] RPB-23 - ASR/TTS boundary: UIUE can show microphone and TTS feedback, but backend contract receives text. Decide what proof is required before any doc says voice is ready.
- [ ] RPB-24 - Trace envelope: define minimum fields: trace id, event id, request text, normalized intent, guard result, transitions, readbacks, proof class, timestamps, redactions.
- [ ] RPB-25 - Proof class cap: UIUE screenshots and simulator runs can prove presentation behavior, not C6 acceptance, model quality, voice endpoint readiness, or true-device V-PASS.

### P1 - Should Decide Before Merge Planning

- [ ] RPB-26 - Current-state reasoning: for "我有点冷了/热了", decide whether Phase 4/5 uses rule-based relative steps, current store lookup, LoRA intent output, or a fixed macro.
- [ ] RPB-27 - Reuse C3 normalization: C3 already has relative `EXP` normalization against current store state. Decide whether UIUE reuses it through a bridge or duplicates logic.
- [ ] RPB-28 - Range source: UIUE range controls must not duplicate default-scope range rules. Decide whether `ValueRangeMapper` delegates to A2/default-scope lookup.
- [ ] RPB-29 - Active cell priority: when state is `changing`, `unsafe`, or `blocked`, define which card is visually primary and whether refused cells can outrank satisfied cells.
- [ ] RPB-30 - Snapshot card schema: define the UI-facing card model: family id, cell id, title, value, unit, visual state, scope origin, reason, available actions, and last update.
- [ ] RPB-31 - Family coverage: confirm whether the 10-family demo surface is still the only required scope for UIUE runtime work, or whether scene/weather/time adds a separate non-vehicle family.
- [ ] RPB-32 - Dialogue ownership: decide which copy belongs to runtime readback, which belongs to assistant presentation, and which is TTS-only. Avoid hardcoding runtime proof in bubble text.
- [ ] RPB-33 - Orb state source: decide whether orb state follows ASR/TTS lifecycle, C3 execution lifecycle, card transition lifecycle, or a composite presentation state.
- [ ] RPB-34 - Low-power and reduce-motion: every visual state needs a non-animation channel: color, icon, label, value, or reason. Motion-only state is not acceptable for proof.
- [ ] RPB-35 - Mac/iOS parity: decide which runtime bridge fields must be identical across macOS and iOS, and which are layout-only differences.
- [ ] RPB-36 - True-device gap: iOS simulator screenshots do not prove true-device audio, performance, or thermal behavior. Mark the first real-device gate separately.
- [ ] RPB-37 - Offline bundle rule: confirm that UIUE runtime demos must run without network and without Python libraries inside iOS, consistent with project constitution.
- [ ] RPB-38 - Persistence boundary: decide whether UIUE keeps any session memory. Mainline roadmap says no persistence, cloud, or long memory for the bridge.
- [ ] RPB-39 - Error state copy: define runtime error versus crash versus unsupported. `crash` visual state must not be used for normal unsupported/refusal paths.
- [ ] RPB-40 - Settings and reset: SD8 includes settings/reset/theme/scene macro. Decide which settings are presentation-only and which affect runtime input.

### P2 - Can Defer, But Must Not Disappear

- [ ] RPB-41 - Golden-run relation: mark which UIUE scripted runs could later become golden-run candidates, while making clear they are not golden-run evidence now.
- [ ] RPB-42 - Candidate comparison relation: UIUE visuals should not choose model candidates. Any model-routing or candidate-comparison evidence belongs to later mainline work.
- [ ] RPB-43 - Training implication: identify UIUE copy or runtime cases that might later produce training examples, but do not write training data from UIUE storyboard text without a separate data contract.
- [ ] RPB-44 - Accessibility copy: define VoiceOver labels and state announcement mapping for the same runtime result states.
- [ ] RPB-45 - Screenshot anchor naming: require anchor images to include platform, state, proof class, and source doc reference so future agents do not treat sketches as runtime proof.
- [ ] RPB-46 - Receipt format: every UIUE runtime demo receipt should list command, device/simulator, proof class, touched files, and residual risk.
- [ ] RPB-47 - Merge-readiness marker: define a label for "UIUE runtime contract aligned but not merged" so PR/closeout does not imply mainline integration.
- [ ] RPB-48 - No stale SHA review: any external reviewer must be told the live UIUE HEAD and mainline HEAD above. Old handoff SHAs are historical write points only.
- [ ] RPB-49 - UIUE grill carry-forward: unresolved P0/P1 items must be copied into the next UIUE closeout, not buried in prose.
- [ ] RPB-50 - OpenSpec landing: decide which accepted items must become a thin `define-runtime-presentation-bridge` OpenSpec proposal, and which remain UIUE implementation notes.

## Expected Output From UIUE Commander

Return a compact decision table. For P0/P1, do not answer with "later" unless the row is explicitly classified as `defer_to_bridge` and includes the owner and landing target. For any prototype allowance, state how the prototype will be prevented from becoming accidental contract.

Minimum acceptable response:

- P0 rows RPB-01 through RPB-25 have decisions.
- P1 rows RPB-26 through RPB-40 have decisions or justified deferrals.
- Any accepted bridge field names are listed in one summary block.
- Any code-facing change proposal names the exact file or module it would touch.
- Any unresolved runtime risk is copied to the next UIUE closeout checklist.


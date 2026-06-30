# Deductive Gap Analysis - R4 UI Corner Cases

- Date: 2026-06-28
- Scope: R4 bridge grill supplement
- Method: 演绎推导, not prompt-only brainstorming

## Premises

1. R4 is a bridge stage. It must explain how runtime/presentation state crosses into UIUE without claiming R5 runtime, voice, model, endpoint, mobile, or true-device readiness.
2. UIUE is not one card. It is a staged surface with top context capsule, orb/thinking, dialogue/readback, vehicle controls, mic dock, overlays, sheets, and macro/demo controls.
3. A bridge contract that cannot explain each zone's state source, interaction owner, animation policy, and evidence proof is under-specified even if its high-level schema exists.
4. UI details must not back-propagate into runtime as hidden requirements. Some presentation rules belong in explicit visual policy, not bridge schema.
5. Human review can pass with notes, but notes do not close proof classes or runtime readiness.

## Observed Source Anchors

- `docs/uiue-storyboard-grill-decisions.md` locks continuous-stage thinking, zone budget, attention priority, z-order, independent scrolling, context capsule, and diorama context mapping.
- `docs/grill-checklist/uiue-grill-定档-2026-06-25.md` revises top bar into centered context capsule plus standalone settings/refresh.
- `docs/grill-tournament/uiue-r0-r2-grill-burndown-2026-06-27.md` records orb four-state and layout gates as partial/open around runtime binding, halo/theme proof, and fresh simulator evidence.
- `Core/Presentation/PresentationSnapshot.swift` currently carries `context`, `orbState`, `voiceState`, `dialogText`, `readbacks`, `activeCells`, `refusedCell`, `proofClass`, and `resultKind`, but not an explicit zone manifest, attention sequence, or gesture route field.
- `App/ContentView.swift` currently routes settings -> `DemoControlPanel`, has mic press visual feedback, card tap/drag, scroll behavior, expanded overlay, top context capsule, and safe-area mic dock. These are meaningful R4 consumer surfaces, even when not all should become bridge schema fields.

## Gap Classes

| Gap | Why original C01-C30 was insufficient | Supplemental coverage |
| --- | --- | --- |
| Zone topology | C25 said layout/orb/capsule broadly, but did not ask for per-zone ownership and state source. | C31-C33 |
| Gesture routes | Original matrix did not distinguish long press, mic press, card tap, scrub drag, scroll, overlay dismiss, and settings route. | C34-C37 |
| Top vehicle/context style | C13 covered force-context as fixture, but not top visual style switching and priority. | C38-C40 |
| Macro lifecycle | Original result/mixed-outcome items did not require macro/force/reset stale-state clearing. | C41-C42 |
| Scroll/focus/overlay | R0-R2 covered layout, but R4 did not connect it to bridge evidence and snapshot-driven focus. | C43-C45 |
| Accessibility/reduce motion | C25 mentioned reduce motion broadly, not per-zone parity and gesture alternatives. | C46-C47 |
| Platform/evidence | Original evidence gates were general, not zone-by-zone video/crop/timing proof. | C48-C50 |

## Deductive Verdict

There are real R4 supplemental gaps. They are not all new implementation tasks, but they are required grill questions because R4 is the transition where UIUE presentation details either become explicit consumer policy or accidentally become hidden runtime contract.


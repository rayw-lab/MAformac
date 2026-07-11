## Why

The current customer MicDock callback reaches `MockVoicePresetPlanner`, which is a simulator-only presentation path. D-142 / V6-N7 requires a deny-first containment seam before any production-runner or T04 interface cut is ratified.

## What Changes

- Add a stable typed `FrontstageVoiceSession` containment facade. Each customer submission returns only `refusal_no_available_tool`, no readback, no state mutation, and `local_unit` proof.
- Route both customer MicDock call sites through an App composition object that owns the stable session. The containment composition SHALL NOT create or bind `DemoRuntimeSessionRunner`.
- Add a latest-turn-only frontstage receipt with the five-key run-identity ABI. It records deny facts and current-turn identity only; it is not a ledger or action-success proof.

## Non-goals

- No production runner binding, default composition, positive admission, resolver, action execution, or customer facade that depends on the T03/T04 interface cut.
- No mounted catalog, matrix, S8, model, LoRA, iOS, operator, mobile, or V-PASS change.

## Success Criteria

- A customer MicDock submission cannot call `MockVoicePresetPlanner` and cannot mutate vehicle state.
- Repeated submissions preserve one session identity and receive sequences 1 then 2.
- Foreign receipt mode is all-or-nothing for the five ABI keys and only writes the mandated latest-turn path.

## Impact

- `ContentView` is a HIGH GitNexus surface. This change limits its delta to the two customer MicDock callback expressions and the typed containment presentation handoff; its gate-strength delta is a new source-contract negative that rejects a callback path to the mock planner.

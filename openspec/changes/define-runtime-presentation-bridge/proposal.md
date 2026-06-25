# define-runtime-presentation-bridge

## Summary

Define a thin Runtime → Presentation bridge contract so UIUE presentation, iOS/macOS runtime backend, golden-run, and voice work consume the same event / result / snapshot / trace vocabulary. The bridge lets UIUE present rich state (7-state cards, refusal, partial-deny, already-state, scope origin, context) while mainline owns runtime truth, preventing divergent field invention as either side hardens code.

## Motivation

UIUE has crossed from pure visual prototype into runtime-touching territory: touch controls, current vehicle state, voice text, runtime refusal, unsafe context, scene macros, readback, multi-intent sequencing, and a context-mapping capsule. The mainline runtime today exposes pieces (`DemoVehicleStateStore` with `DemoVisualState`/`DemoVehicleValueSource`/`DemoActionReadback`, `C3ExecutionResult`, `ScopeResolution`, `TraceEntry`, `DemoVisualState`) but **no named UI-facing bridge**:

- C3 guard denial currently `throw`s `ToolExecutionError.guardDenied` (`Core/Execution/C3ExecutionPipeline.swift` mainline `de79c653`), not projected into a presentation-safe refusal snapshot.
- The store has no active-cell map, no refused-cell map, and no already-state result.
- The snapshot has no sibling-cell carriage, so semantic styling (cooling-blue / heating-red driven by `ac.mode`) and active-cell substitution cannot render.

Without a contract, backend and UIUE will grow divergent fields for scope, readback, result kind, trace, voice, and orb state. The UIUE grill (RPB-01~53, `docs/grill-checklist/uiue-runtime-bridge-decisions-2026-06-25.md`) already made the contract decisions; this change freezes them as a thin vocabulary.

## Scope

- Define observable **event / result / snapshot / trace** field requirements and ownership boundaries between Core runtime and UIUE presentation.
- Reuse existing Core concepts (do not redefine): `DemoVehicleValueSource`, `DemoActionReadback`, `DemoVehicleStateCell`, `C3ExecutionResult`, `TraceEntry`, `DemoVisualState`, `ScopeResolution`.
- Freeze the runtime-result vocabulary including **partial-accept-partial-refuse** and **already-state-noop** as distinct machine-readable values.
- Define **active-cell / refused-cell** carriage and **sibling-cell** carriage so presentation can render active-cell substitution and semantic value coloring without reading raw stores.
- Distinguish **value provenance** (`source`) from **scope resolution** (`scope_origin`) as two orthogonal fields.
- Define event-driven thinking gates and the two thinking semantics (analyzing vs fixed safety display).
- Define demo-mode force-state context input (driving/weather/time) feeding a context-presentation surface.

## Non-goals

- No Swift implementation in this contract-only change (vocabulary + behavior contract only).
- No C5 data generation or training; no C6 acceptance, model-quality evaluation, D-domain base recalibration, or candidate comparison.
- No demo-golden-run execution; no ASR/TTS readiness claim; no endpoint readiness claim.
- No mainline runtime backend wiring (FastPath expansion, multi-intent splitter, SceneMacroRegistry implementation are deferred downstream of model/C6 gates).
- No UIUE merge; no V-PASS, S-PASS, or U-PASS.

## Coordination

This change is authored in the UIUE isolation worktree (`MAformac-uiue`) because the RPB-01~53 grill decisions live here, and fulfills the parent roadmap Task 2 (`docs/superpowers/plans/2026-06-25-post-c6-backend-training-uiue-roadmap.md`). It is a **shared contract** for mainline review/co-authorship. Mainline SHALL NOT independently create a second `define-runtime-presentation-bridge` change. The contract is docs-only; it modifies no UIUE or Core Swift code.

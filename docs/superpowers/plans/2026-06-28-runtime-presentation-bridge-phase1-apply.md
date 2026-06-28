---
status: implemented
artifact_kind: implementation_plan_not_ssot
date: 2026-06-28
label: MA-P1-MAINLINE-RUNTIME-CONTRACT-GRILL-APPLY-20260628
authority: docs/project/phase0/runtime-presentation-bridge-phase1-grill-2026-06-28.md
proof_class: docs/local + openspec_contract + local_unit
---

# Runtime Presentation Bridge Phase1 Apply Plan - 2026-06-28

## Goal

Give UIUE and future runtime backend one typed mainline bridge consumption target without implementing runtime backend behavior.

## Scope In

- `Core/Presentation/RuntimePresentationBridge.swift`
- `Tests/MAformacCoreTests/RuntimePresentationBridgeTests.swift`
- `openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md`
- `openspec/changes/define-runtime-presentation-bridge/tasks.md`
- `docs/project/phase0/runtime-presentation-bridge-phase1-grill-2026-06-28.md`

## Scope Out

- Runtime backend loop
- ASR/TTS or voice readiness
- C5 retrain
- C6 acceptance/comparison
- Golden-run execution
- Endpoint readiness
- UIUE worktree edits or merge
- Mobile/true-device proof
- `ScopeOrigin.missing`

## Phase1 Slice

1. Define bridge DTOs:
   - `DemoInteractionEvent`
   - `DemoRuntimeResult`
   - `DemoRuntimeOutcome`
   - `PresentationSnapshot`
   - `TraceEnvelope`
   - `PresentationProofClass`
2. Preserve C6 source vocabulary by mapping `VehicleToolBehaviorClass.toolCall` to bridge `accepted_tool_call` through `behaviorClassSource`.
3. Carry missing/unresolved scope through `scopeFailureReason`, `reason`, or `missingSlot`, not `ScopeOrigin.missing`.
4. Make proof-class decoding finite and fail-closed by enum decoding.

## Validation Gates

- `openspec validate define-runtime-presentation-bridge --strict`
- `openspec validate --all --strict`
- `git diff --check`
- `swift test --filter RuntimePresentationBridgeTests`

## Stop Conditions

- Any change requires UIUE writes.
- Any code touches runtime backend execution loop.
- Any proof class grants readiness claims.
- Any Core `ScopeOrigin.missing` case is proposed.

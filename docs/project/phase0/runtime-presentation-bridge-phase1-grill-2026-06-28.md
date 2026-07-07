---
status: PASS_WITH_NOTES
artifact_kind: phase1_runtime_contract_grill_receipt
date: 2026-06-28
label: MA-P1-MAINLINE-RUNTIME-CONTRACT-GRILL-APPLY-20260628
repo: /Users/wanglei/workspace/MAformac
branch: codex/rebuild-c6-doc-absorption-20260624
start_head: 9ba609a13fdf311546f20561081c4a9bb858d0fc
proof_class: docs/local + openspec_contract + local_unit
non_claims:
  - no runtime backend loop
  - no C5 retrain
  - no C6 acceptance or candidate comparison
  - no voice-ready
  - no golden-ready
  - no endpoint-ready
  - no mobile
  - no true_device
  - no UIUE merge
  - no V-PASS
retire_trigger: "Retire when superseded by archived OpenSpec specs or explicit user decision."
expires: "2026-08-15"
---

# Runtime Presentation Bridge Phase1 Grill - 2026-06-28

## Verdict

`PASS_WITH_NOTES`

Phase1 可以做一个最小 Runtime/Contract slice：主线提供稳定 Swift bridge contract types + focused unit tests + OpenSpec wording 补强。不得接 runtime backend loop，不得把 UIUE/local/mock 证明升格成 runtime/mobile/model/voice/golden proof。

## Live Truth

- start HEAD: `9ba609a13fdf311546f20561081c4a9bb858d0fc`
- route board: `docs/CURRENT.md` records `Runtime-Presentation bridge | proposed_active_contract_only`.
- Phase0 carrier: `openspec/changes/define-runtime-presentation-bridge/`
- Existing Core symbols:
  - `ScopeOrigin`: `Core/Execution/ScopeResolution.swift:3`
  - `DemoVisualState` and `DemoVehicleStateCell`: `Core/State/DemoVehicleStateStore.swift:17`, `Core/State/DemoVehicleStateStore.swift:27`
  - `DemoActionReadback.scopeOrigin`: `Core/State/DemoVehicleStateStore.swift:72`
  - `C3ExecutionResult`: `Core/Execution/C3ExecutionPipeline.swift:3`
  - `TraceEntry`: `Core/Trace/TraceLogger.swift:57`
  - `VehicleToolBehaviorClass`: `Core/Contracts/VehicleToolBehaviorClass.swift:3`
- Missing current production symbols before Phase1:
  - `PresentationSnapshot`
  - `DemoRuntimeResult`
  - `TraceEnvelope`
  - `DemoInteractionEvent`

## Q1. Minimal Authoritative Phase1 Contract Surface

Decision: staged combination, not docs-only and not runtime implementation. Phase1 should land Swift contract types under `Core/Presentation/RuntimePresentationBridge.swift`, focused tests under `Tests/MAformacCoreTests/RuntimePresentationBridgeTests.swift`, and a short apply plan. Evidence: `Package.swift:18` includes `Core` as the library source root, while Phase0 says no backend implementation in `openspec/changes/define-runtime-presentation-bridge/proposal.md:36`. Tiger: UIUE otherwise invents field names. Paper-tiger: docs-only strict validation looks green but gives no typed consumption target. Elephant: future runtime adapter still needs separate implementation. Stop condition: if Swift types require runtime execution, model output, UIUE code, or Core enum expansion, stop.

## Q2. Shared Bridge Authority vs UIUE-Local Display Concerns

Decision: shared authority fields are `traceID`, `runtimeOutcome.result`, `runtimeOutcome.behaviorClassSource`, `cards`, `readbacks`, `scopeOrigin`, `scopeFailureReason`, `proofClass`, `traceEnvelope`, `isTerminal`, and optional `voiceState/orbState` display state. UIUE-local concerns are layout, animation, glyphs, color tokens, tooltip copy, and any presentation-only unresolved-scope label. Evidence: Phase0 design requires UIUE consumes mapped snapshots, not raw runtime stores (`openspec/changes/define-runtime-presentation-bridge/design.md:19`), and D8 says UIUE reads `default_scope` but scope fill belongs to Core (`docs/grill-tournament/grill-decisions-master.md:202`). Tiger: field drift. Paper-tiger: UIUE color/layout choices. Elephant: UIUE still needs local adapters after this. Stop condition: any UIUE-local label being treated as Core truth.

## Q3. C3/Result/Readback Outcome Mapping

Decision: bridge uses `DemoRuntimeResult` values `accepted_tool_call`, `clarify_missing_slot`, `refusal_no_available_tool`, `refusal_safety_or_policy`, `already_state_noop`, `runtime_error`, `cancelled`, `interrupted`. Existing C6/C5 behavior class `tool_call` maps to bridge `accepted_tool_call` through `behaviorClassSource`, not by renaming the source enum. Evidence: `VehicleToolBehaviorClass.toolCall` is `tool_call` at `Core/Contracts/VehicleToolBehaviorClass.swift:4`; C3 success currently returns only `traceID/readbacks` at `Core/Execution/C3ExecutionPipeline.swift:3`. Tiger: `tool_call` vs `accepted_tool_call` dual naming. Paper-tiger: enum name aesthetics. Elephant: C3 thrown errors still need future adapter classification. Stop condition: if someone proposes replacing C6 `tool_call` with `accepted_tool_call` globally in this slice.

## Q4. Missing/Unresolved Scope Without `ScopeOrigin.missing`

Decision: keep `ScopeOrigin` as `defaulted/explicit/fanout`; unresolved scope travels as `scopeFailureReason`, `runtimeOutcome.reason`, or `runtimeOutcome.missingSlot`. Evidence: `ScopeOrigin` has only three cases at `Core/Execution/ScopeResolution.swift:3`, and missing default scope currently throws `semanticInvalid("missing_default_scope")` at `Core/Execution/ScopeResolution.swift:46`. Tiger: backdoor Core enum expansion. Paper-tiger: UI label text saying "missing". Elephant: future runtime adapter must map thrown errors deterministically. Stop condition: any Core `case missing`.

## Q5. Snapshot Shape UIUE Can Safely Consume

Decision: `PresentationSnapshot` should be a presentation-safe DTO: `traceID`, `runtimeOutcome`, `cards`, `dialogText`, `readbacks`, `scopeOrigin`, `scopeFailureReason`, optional `voiceState`, optional `orbState`, finite `proofClass`, optional `TraceEnvelope`, `isTerminal`, `timestamp`. It must not include raw model output, training receipts, raw runtime store accessors, or mutable store references. Evidence: Phase0 spec says snapshot must contain trace identity/card/dialog/readback/scope/proof fields without UI reading raw stores (`openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md:65`). Tiger: raw-store dependency. Paper-tiger: optional `dialogText` wording. Elephant: card aggregation semantics remain UIUE adapter work. Stop condition: snapshot contains model transcript or store reference.

## Q6. Proof Class Vocabulary And Display Caps

Decision: Phase1 finite enum is `docs_local`, `openspec_contract`, `local_static_contract`, `local_unit`, `local_shape_no_model`, `local_receipt_consistency`, `simulator_mock`, `external_gptpro_review`; all readiness claims are display-capped to empty for now. Evidence: CURRENT lists proof classes such as `external_gptpro_review`, `local_static_contract`, `local_unit`, `local_shape_no_model`, `local_receipt_consistency` in `docs/CURRENT.md:39`, and Phase0 spec forbids local/static proof being displayed as readiness (`openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md:77`). Tiger: UI copy upgrading proof. Paper-tiger: naming case. Elephant: future true-device/live proof enum may need an explicit later change. Stop condition: unknown proof class decodes as success or grants readiness.

## Q7. Explicit Out-of-Scope Work

Decision: out of scope: runtime backend execution loop, ASR/TTS, C5 retrain, C6 acceptance/comparison, candidate comparison, model-quality eval, golden-run execution, endpoint readiness, UIUE merge, mobile/true-device proof, and V/S/U-PASS. Evidence: Phase0 receipt preserves these non-claims at `docs/project/phase0/mainline-runtime-presentation-bridge-unblock-2026-06-28.md:10`, and CURRENT locks those gates at `docs/CURRENT.md:82`. Tiger: fake green. Paper-tiger: writing optional display enum for voice/orb. Elephant: separate child plans still required. Stop condition: any implementation reaches model, voice, endpoint, UIUE worktree, or C6 run.

## Q8. Validation Gates

Decision: docs-only Phase1 requires `openspec validate define-runtime-presentation-bridge --strict`, `openspec validate --all --strict`, and `git diff --check`. Swift type/test slice additionally requires targeted `swift test --filter RuntimePresentationBridgeTests`; full `swift test` is optional unless shared runtime behavior is touched. Evidence: package test target exists at `Package.swift:48`; Phase0 validated OpenSpec strict successfully in `docs/project/phase0/mainline-runtime-presentation-bridge-unblock-2026-06-28.md:104`. Tiger: uncompiled public API. Paper-tiger: running expensive unrelated model gates. Elephant: future runtime adapter will need broader C3 tests. Stop condition: targeted Swift test cannot compile.

## Q9. UIUE Wait vs Parallel Work

Decision: UIUE must wait for committed Phase1 contract types/field names before treating shared snapshot/result/proof fields as stable. UIUE can proceed in parallel on local layout, animations, visual tokens, interaction affordance polish, and adapters that consume the stable DTO without writing shared authority. Evidence: CURRENT says UIUE is isolated unless bridge fields conflict (`docs/CURRENT.md:105`), and D8.6 scopes UIUE work to card/orb/readback display while keeping scope fill and TTS/core outside UIUE (`docs/grill-tournament/grill-decisions-master.md:207`). Tiger: UIUE inventing shared fields. Paper-tiger: local visual polish. Elephant: adapter conformance must be verified in UIUE later. Stop condition: UIUE writes a second bridge SSOT or treats simulator/mock proof as runtime proof.

## Implementation Scope Authorized By This Grill

- Add `Core/Presentation/RuntimePresentationBridge.swift`.
- Add `Tests/MAformacCoreTests/RuntimePresentationBridgeTests.swift`.
- Add `docs/superpowers/plans/2026-06-28-runtime-presentation-bridge-phase1-apply.md`.
- Add one OpenSpec scenario/task note for `tool_call` source mapping to `accepted_tool_call`.

No P0/P1 blocker remains inside this limited scope.

## Validation

| Command | Result |
|---|---|
| `openspec validate define-runtime-presentation-bridge --strict` | PASS: `Change 'define-runtime-presentation-bridge' is valid` |
| `openspec validate --all --strict` | PASS: `Totals: 16 passed, 0 failed (16 items)` |
| `git diff --check` | PASS |
| `swift test --filter RuntimePresentationBridgeTests` | PASS: 4 tests, 0 failures |

## Notes

- The first targeted Swift compile exposed that `DemoActionReadback` was not `Codable`; Phase1 fixed this by adding `Codable` conformance only, so `PresentationSnapshot` can be encoded without inventing a parallel readback DTO.
- This slice still does not classify thrown C3 errors into `DemoRuntimeOutcome`; that belongs to a later runtime adapter implementation.

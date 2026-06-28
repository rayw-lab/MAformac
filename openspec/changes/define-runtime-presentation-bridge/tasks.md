## 1. Carrier validation

- [x] 1.1 Create the mainline-visible carrier under `openspec/changes/define-runtime-presentation-bridge/`.
- [x] 1.2 Record HR-01/HR-02/HR-03 in the carrier wording.
- [x] 1.3 Record C01/C03/C06/C18 as dispatch-readiness dispositions, not runtime/mobile proof.
- [x] 1.4 Keep this change contract-only; do not implement Swift.

## 2. Contract fields

- [x] 2.1 Define Runtime -> Presentation authority mapping and no-second-SSOT rule.
- [x] 2.2 Define runtime result vocabulary covering accepted tool calls, clarify/missing slot, unsupported refusal, safety/policy refusal, already-state no-op, runtime error, and cancelled/interrupted.
- [x] 2.3 Define presentation snapshot requirements for trace identity, cards, dialog/readbacks, scope origin, optional voice/orb display state, and finite proof class.
- [x] 2.4 Define `ScopeOrigin` disposition: no Core `missing`; missing/unresolved scope uses result/presentation metadata or explicit failure reason.
- [x] 2.5 Define proof-class display caps so docs/local proof cannot be upgraded by UI copy.

## 3. Document cascade

- [x] 3.1 Update `docs/CURRENT.md` so bridge state is no longer `not_proposed`.
- [x] 3.2 Update `docs/README.md` with the carrier and unblock receipt.
- [x] 3.3 Update/supersede `docs/project/phase0/uiue-r4-mainline-coauthor-receipt-2026-06-28.md` without claiming runtime proof.
- [x] 3.4 Create `docs/project/phase0/mainline-runtime-presentation-bridge-unblock-2026-06-28.md` with dirty ownership and validation receipt.

## 4. Red lines

- [x] 4.1 Do not edit `/Users/wanglei/workspace/MAformac-uiue`.
- [x] 4.2 Do not start UIUE R5 implementation.
- [x] 4.3 Do not claim runtime-ready, voice-ready, model-ready, golden-ready, endpoint-ready, mobile, true_device, V-PASS, S-PASS, U-PASS, or UIUE merge.

## 5. Validation

- [x] 5.1 Run `openspec validate define-runtime-presentation-bridge --strict`.
- [x] 5.2 Run `openspec validate --all --strict`.
- [x] 5.3 Run `git diff --check`.

## 6. Phase1 typed bridge contract

- [x] 6.1 Add `DemoInteractionEvent`, `DemoRuntimeResult`, `DemoRuntimeOutcome`, `PresentationSnapshot`, `TraceEnvelope`, and finite `PresentationProofClass` as mainline Core contract types.
- [x] 6.2 Preserve upstream `VehicleToolBehaviorClass.toolCall` while mapping it to bridge `accepted_tool_call`.
- [x] 6.3 Carry missing/unresolved scope through explicit reason metadata, not `ScopeOrigin.missing`.
- [x] 6.4 Add focused unit tests for behavior mapping, scope-missing disposition, proof-class fail-closed behavior, and snapshot codability.

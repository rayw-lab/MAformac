## Why

D15 已经把 Runtime -> Presentation payload 合同收在 main，但 R5 route map 仍把 `C018` Core config / `SceneMacroRegistry` 和 `C052` production/runtime force-state 留作 deferred owner lanes。D17 如果在没有 main-owned authority 的情况下继续，会被迫让 UIUE 猜 shared config、force-state 名称和 proof 边界，形成第二事实源。

## What Changes

- Define a main-owned Core config / scene macro authority for `C018`, including stable names, ownership, unknown-name fail-closed behavior, and UIUE non-authority.
- Define a main-owned demo force-state boundary for `C052`, including demo/debug isolation, bridge event provenance, no customer-facing production path, and no direct state-cell contract mutation.
- Define what a future UIUE consumer may consume: only stable main-owned names and D15/D16 presentation-safe authority under proof cap.
- Define what a future UIUE consumer must not consume: UIUE-invented shared fields, debug-only force-state internals, private runtime adapter fields, raw runtime store, raw model output, training receipts, and ledger internals.
- Preserve D15 proof cap: this change is authority/docs only in Gate 1 and does not prove runtime, mobile, true-device, live API, model, voice, golden, endpoint, UIUE merge, or V/S/U-PASS readiness.

## Non-goals

- Do not implement Swift Core config, `SceneMacroRegistry`, force-state code, runtime adapter wiring, UIUE consumer parsing, or simulator/mobile validation in Gate 1.
- Do not expose `DemoRuntimeAdapter*`, `RuntimeAdapterBox`, request fingerprints, parent request fingerprints, failure ledger, settled parent plan internals, raw runtime store, raw model output, or training receipt as shared UIUE vocabulary.
- Do not treat the existing UIUE `RuntimePresentationConsumerMapping` as authority for `C018` or `C052`.
- Do not promote debug-only force-state screenshots or local/unit proof to production/runtime/mobile/true-device/live proof.

## Capabilities

### New Capabilities

- `core-config-force-state`: Main-owned authority for `C018` Core config / scene macro names and `C052` demo force-state boundary.

### Modified Capabilities

- `runtime-presentation-bridge`: Narrows the previously deferred `C018` and `C052` bridge rows by pointing them to this main-owned authority without changing D15 payload fields.

## Impact

- OpenSpec authority only in Gate 1.
- Future Gate 2 may add Core config / scene macro code and local/unit tests.
- Future Gate 3 may add demo/debug-isolated force-state code and local/unit tests.
- Future D17 UIUE work may consume only the stable names defined by this main-owned authority, under UIUE local/unit/simulator proof cap.

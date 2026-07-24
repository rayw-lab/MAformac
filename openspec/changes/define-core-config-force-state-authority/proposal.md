本 amend 增量覆盖 D-152 M16-011/012（cite INDEX v3.1:82-83）。
既有 tasks.md 中 Gate1–4R 的 [x] 仅为 D16 历史证据（HISTORICAL_CHECKBOX_ONLY），
不等于 M16-011 catalog/migration 已满足，不等于 production force write path 已 enforce
（DemoForceStateBoundary.accept production CALLS 以 GitNexus/live 为准，当前 CALLS=0）。
D-150/D-152 RATIFIED 不自动 apply 本 change。

status: `active_contract_carrier`
status_source: `D-115/N4 + D-152 M16-011/012`
status_updated: `2026-07-12`
v6_package_ids: [W9,O5]
relation_type: owns
blocked_on: G3/T08 RATIFIED + Gate4 P0/P1=0
proof_cap: local_static_contract_only
amend_scope: W9_M16-011_M16-012_only
shared_plan: `CARRIER-PLAN-W9-V2-v2-by-w5g.md` remains `DRAFT_PENDING_CARRIER_KEY` until V2 is paired

## Why

D16 已经把 Core config / scene macro 与 demo force-state 的 main-owned boundary 写成 authority，但 D-152 M16-011/012 的 carrier 增量尚未进入该既有 change。当前 live carrier 的历史 Gate 勾选不能代替单一物理 catalog、digest、exact migration ledger，亦不能代替 boundary → Core applier → projection-only 的唯一写 owner。

W9-amend 将这些缺口写进同一 `core-config-force-state` contract，同时保留 D16 的 demo/debug 隔离、D17 消费边界和 proof cap。它不把当前 `DemoForceStateBoundary.accept` 的本地存在或 `CALLS=0` 误写成 production enforce。

## What Changes

- Amend the existing `core-config-force-state` carrier for M16-011/M16-012; do not create a parallel W9 change.
- Add one physical Core catalog with two explicit `debug`/`demo` kind-and-namespace values, stable identity, declared digest metadata, and fail-closed unknown/duplicate handling.
- Add a deterministic catalog digest contract and an exact, evidence-backed migration ledger; fuzzy or inferred `4↔5` mapping is forbidden.
- Amend force-state ownership to the observable chain `boundary validator → Core applier → projection-only`; App/UI direct mutation and customer-facing force paths are deletion-negative cases.
- Preserve W8 lifecycle/fence ownership: W9 may consume typed terminal/fence acknowledgements when a later implementation phase provides them, but does not define the lifecycle state machine.
- Keep `verify-force-state-source` and `verify-force-state-authority` explicitly `PLANNED_GATE_NOT_YET_EXECUTABLE` until their targets, wiring, independent checkers, behavior tests, and deliberate-red negatives materialize.
- Keep existing D16/D17 requirements, with notes that the main-owned vocabulary is not itself the M16-011 dual-namespace catalog and that local structure validation is not production authority proof.

## Non-goals

- Do not implement Swift Core config, a catalog, migration code, a Core applier, force-state code, runtime adapter wiring, UIUE consumer parsing, or simulator/mobile validation in this carrier writeback.
- Do not apply, code, merge, package, flip a registry/package state, or write the W9/V2 shared plan to `SUPERSEDED_BY_CARRIER` in this W9-only transaction.
- Do not expose `DemoRuntimeAdapter*`, `RuntimeAdapterBox`, request fingerprints, parent request fingerprints, failure ledger, settled parent plan internals, raw runtime store, raw model output, training receipts, or ledger internals as shared UIUE vocabulary.
- Do not treat the existing UIUE `RuntimePresentationConsumerMapping` as authority for `C018` or `C052`.
- Do not promote debug-only force-state screenshots, local/unit proof, or OpenSpec strict validation to production/runtime/mobile/true-device/live proof, operator-pass, V-PASS, or W9 DONE.

## Capabilities

### New Capabilities

- `core-config-force-state`: Existing carrier capability amended with the M16-011 catalog/digest/migration contract and the M16-012 single-write-owner contract.

### Modified Capabilities

- `runtime-presentation-bridge`: Narrows the previously deferred `C018` and `C052` bridge rows by pointing them to this main-owned authority without changing D15 payload fields.

## Success Criteria

- The four W9 amend artifacts are self-consistent and `openspec validate define-core-config-force-state-authority --strict` returns rc 0.
- The spec contains the three M16-011 additions, the M16-012 owner/deletion-negative contract, and the full amended force-state boundary without turning historical checkboxes into current proof.
- The W9 pair receipt binds the exact plan SHA, key receipt, change-file SHAs, current repo HEAD, W9 strict result, and the unchanged shared-plan status.
- No implementation, apply, runtime, operator, mobile, true-device, live API, V-PASS, or package-state claim is made.

## Impact

- OpenSpec authority only in the W9 carrier transaction; implementation paths remain untouched.
- Future Gate 2 may add catalog/migration code and local/unit tests after an independent apply key.
- Future Gate 3 may add demo/debug-isolated force-state code and local/unit tests, if the build configuration can prove demo/debug isolation and the W8 acknowledgement stopline is satisfied.
- Future D17 UIUE work may consume only the stable names and projections defined by this main-owned authority, under UIUE local/unit/simulator proof cap.

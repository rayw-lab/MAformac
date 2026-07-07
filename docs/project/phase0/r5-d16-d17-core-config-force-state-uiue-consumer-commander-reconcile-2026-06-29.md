---
artifact_kind: r5_d16_d17_core_config_force_state_uiue_consumer_main_reconcile
repo: /Users/wanglei/workspace/MAformac
status: LOCAL_VALIDATION_PASS_PENDING_AUDIT
proof_class: docs_local + local_static + local_unit + openspec_local
created_at: 2026-06-29
retire_trigger: "Retire when superseded by archived OpenSpec specs or explicit user decision."
expires: "2026-08-15"
---

# R5 D16+D17 Main-Side Reconcile

D16 is complete under proof cap and D17 has consumed the stable authority in UIUE. Main owns the D16 Core config / `SceneMacroRegistry` and force-state boundary truth; UIUE owns only consumer mapping against stable names.

## Main Commit Ledger

| gate | commit | result |
|---|---|---|
| D16 Gate1 | `16860c8` | OpenSpec authority for C018/C052 |
| D16 Gate2 | `d00023a` | `SceneMacroRegistry` local/unit code and tests |
| D16 Gate3 | `47c5e9c` | force-state boundary local/unit code and tests; Hermes FAIL/P1 explicit init fixed post-audit, not Hermes PASS |
| D16 Gate4 | `e4f2559` | release gate closed after Hermes FAIL/P1 Codable bypass |
| D16 Gate4R | `ac1569f` | removed `DemoForceStateContext` `Codable`/`Decodable`; Hermes PASS P0/P1 empty; release gate open |
| D16 Gate4R doc fix | `1175a1f` | committed final Gate4R receipt/tasks after commander mismatch intake |

## UIUE Consumption Summary

- Gate5 UIUE commit `50d2a74`: D17 consumer authority; Hermes FAIL/P1 stale visual proof wording fixed post-audit, not Hermes PASS.
- Gate6 UIUE commit `f55a80e`: local/unit raw-name consumer mapping and fail-closed tests; Hermes PASS P0/P1 empty.
- Gate7 UIUE commit `87173b1`: verifier and optional visual smoke decision; Hermes PASS P0/P1 empty.
- Gate8 UIUE commit `466873d`: route map, burndown, and reconcile receipt cascade; Hermes FAIL/P1 stale route-map wait-gate wording fixed post-audit, not Hermes PASS.

## Non-Claims

- no production runtime force-state proof
- no durable ledger or persistent retry proof
- no mobile or true-device proof
- no live API proof
- no UIUE merge
- no visual L3 / V-PASS
- no S-PASS or U-PASS
- no A-2 readiness or completion
- no voice/model/golden/endpoint readiness

## Validation

Passed local validation:

- main `git diff --check`: PASS.
- main `openspec validate define-core-config-force-state-authority --strict`: PASS.
- main `openspec validate define-runtime-presentation-bridge --strict`: PASS.
- main `openspec validate --all --strict`: PASS, 18/18.
- main `swift test --filter 'DemoForceStateBoundaryTests|SceneMacroRegistryTests|RuntimePresentationBridgeTests'`: PASS, 28 tests / 0 failures.

Gate8 UIUE staged GitNexus detect_changes was LOW risk with no affected processes. Gate8 Hermes audit returned FAIL/P1 for stale route-map wait-gate wording on `C018`/`C052`; UIUE fixed it post-audit and revalidated locally. This main receipt is an exact-path docs discoverability commit. Final Claude Code adversarial audit remains pending from UIUE Gate8.

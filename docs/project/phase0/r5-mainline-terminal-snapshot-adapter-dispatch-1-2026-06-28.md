---
status: DONE
artifact_kind: mainline_dispatch_receipt
dispatch_label: UIUE_R5_DISPATCH_1_MAINLINE_TERMINAL_SNAPSHOT_ADAPTER
date: 2026-06-28
repo: /Users/wanglei/workspace/MAformac
proof_class: local/unit + openspec_contract
can_UIUE_consume_terminal_behavior: yes
non_claims:
  - no R5 complete
  - no runtime-ready
  - no mobile proof
  - no true_device proof
  - no voice-ready
  - no model-ready
  - no golden-ready
  - no endpoint-ready
  - no UIUE merge
  - no V-PASS
  - no S-PASS
  - no U-PASS
  - no A-2
  - no A-2 ready
  - no A-2 complete
retire_trigger: "Retire when superseded by archived OpenSpec specs or explicit user decision."
expires: "2026-08-15"
---

# R5 Mainline Terminal Snapshot Adapter Dispatch 1 Receipt

## Verdict

`DONE`

Mainline now has a minimal terminal snapshot adapter behavior proof for `C012`, `C060`, `C017`, and `C022`. This is a local/unit + OpenSpec contract proof for terminal presentation snapshots. It is not a runtime backend loop, not model/voice/golden/mobile proof, and not UIUE merge proof.

## Repo Truth

| Item | Value |
|---|---|
| main branch | `codex/rebuild-c6-doc-absorption-20260624` |
| start HEAD | `0a2ff0f7d30d6caf2d48f018f6b874828fb70c03` |
| UIUE baseline checked | `/Users/wanglei/workspace/MAformac-uiue` HEAD `926dec8311c63a7b51cd1a1a5f633009e25cf7d2` |
| dirty strategy | owned paths only; preserve preexisting main dirty; UIUE read-only |

## Owned Paths

- `Core/Presentation/RuntimePresentationBridge.swift`
- `Tests/MAformacCoreTests/RuntimePresentationBridgeTests.swift`
- `openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md`
- `openspec/changes/define-runtime-presentation-bridge/tasks.md`
- `Reports/r5-terminal-snapshot-adapter-20260628T191309/hermes-r5-terminal-snapshot-audit-prompt.md`
- `Reports/r5-terminal-snapshot-adapter-20260628T191309/hermes-audit-output.txt`
- `docs/project/phase0/r5-mainline-terminal-snapshot-adapter-dispatch-1-2026-06-28.md`

## Preserve Unowned

- `AGENTS.md`
- `CLAUDE.md`
- `docs/CURRENT.md`
- `docs/README.md`
- `.xcodebuildmcp/`
- `Tools/agent-platform-plugin-refs/`

## Implemented Behavior

| Row | Behavior | Evidence | Proof class |
|---|---|---|---|
| `C012` | Guard denial maps to terminal presentation-safe `refusal_safety_or_policy` snapshot with safe reason, trace identity, proof class, and no raw model/store/training fields. | `RuntimePresentationBridge.swift:368`; `RuntimePresentationBridgeTests.swift:88`; `spec.md:95` | local/unit + openspec_contract |
| `C060` | Thrown adapter/runtime failure maps to terminal `runtime_error` snapshot with trace identity and safe reason instead of silent failure. | `RuntimePresentationBridge.swift:393`; `RuntimePresentationBridgeTests.swift:112`; `spec.md:103` | local/unit + openspec_contract |
| `C017` | Partial accept/refuse maps to terminal snapshot with accepted readbacks plus mixed accepted/refused card state. | `RuntimePresentationBridge.swift:416`; `RuntimePresentationBridgeTests.swift:125`; `spec.md:111` | local/unit + openspec_contract |
| `C022` | Cancel, interruption, timeout, and backgrounding produce terminal snapshots with trace identity, result class, proof class, and reason metadata. | `RuntimePresentationBridge.swift:440`; `RuntimePresentationBridgeTests.swift:153`; `spec.md:118` | local/unit + openspec_contract |

## Grill Burndown

| row_id | before | after | proof_path | proof_class | validation | remaining_gap |
|---|---|---|---|---|---|---|
| `C012` | `remaining`: guard denial to terminal refusal snapshot not proven. | `covered_for_dispatch_1` | `Tests/MAformacCoreTests/RuntimePresentationBridgeTests.swift:88` | local/unit | `swift test --filter RuntimePresentationBridgeTests` PASS | Future runtime backend must wire real guard-denial execution into this adapter. |
| `C060` | `remaining`: thrown C3/adapter failure could be silent from presentation contract view. | `covered_for_dispatch_1` | `Tests/MAformacCoreTests/RuntimePresentationBridgeTests.swift:112` | local/unit | `swift test --filter RuntimePresentationBridgeTests` PASS | Factory proof only; future C3 do/catch wrapper remains later runtime work. |
| `C017` | `remaining`: partial accept/refuse composite snapshot/readback unproven. | `covered_for_dispatch_1` | `Tests/MAformacCoreTests/RuntimePresentationBridgeTests.swift:125` | local/unit | `swift test --filter RuntimePresentationBridgeTests` PASS | Full multi-effect runtime adapter semantics remain future runtime/backend scope. |
| `C022` | `remaining`: cancel/interruption/timeout/backgrounding terminal snapshot behavior boundary-only. | `covered_for_dispatch_1` | `Tests/MAformacCoreTests/RuntimePresentationBridgeTests.swift:153` | local/unit | `swift test --filter RuntimePresentationBridgeTests` PASS | App lifecycle integration remains later runtime/client work. |

## K1 Status

`untouched_spike_ledger: yes`

K1 rows remain a spike-before-implementation ledger. This dispatch did not implement or promote K1 items.

## Validation

| Command | Result | Proof class |
|---|---|---|
| `openspec validate define-runtime-presentation-bridge --strict` | PASS: `Change 'define-runtime-presentation-bridge' is valid` | openspec_contract |
| `git diff --check` | PASS | local/static |
| `swift test --filter RuntimePresentationBridgeTests` | PASS: 15 tests, 0 failures | local/unit |

## Codex Native Subagent Audit

| Item | Result |
|---|---|
| status | PASS |
| findings_P0_P1 | none |
| disposition | no_unresolved_P0_P1 |
| evidence | Subagent `019f0deb-4862-7430-b82a-448e78d65a7e` reviewed dispatch, diff, OpenSpec, Swift carrier, tests, validation, dirty split, and returned no P0/P1. |

## Hermes/GLM Audit

| Item | Result |
|---|---|
| status | PASS |
| elapsed_minutes | about 3.5 |
| findings_P0_P1 | none |
| disposition | no_unresolved_P0_P1 |
| run_dir | `Reports/r5-terminal-snapshot-adapter-20260628T191309/` |
| output | `Reports/r5-terminal-snapshot-adapter-20260628T191309/hermes-audit-output.txt` |

Hermes residuals are P2/P3 only: factory-level proof is not integrated C3 runtime do/catch wiring; reason taxonomy can be stricter later; raw leak tests check forbidden field names rather than arbitrary sensitive reason content. These do not block Dispatch 1.

## Residual Risks

- This is not full runtime backend execution. It is a mainline terminal snapshot adapter/factory proof with unit tests.
- Future runtime work must connect real C3 thrown paths, guard-denial paths, cancel/interruption/timeout/backgrounding lifecycle paths, and multi-effect runtime execution to this adapter.
- No UIUE code was changed by Dispatch 1; UIUE can consume terminal behavior names and snapshot semantics, but still must implement consumer mapping under its own local/simulator proof caps.

## Next Step

UIUE may consume the covered terminal behavior semantics for R5 consumer mapping, while preserving proof-class caps and non-claims. Commander may proceed to the next serial dispatch without treating this as runtime-ready or R5 complete.

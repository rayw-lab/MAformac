---
status: DONE
artifact_kind: mainline_dispatch_receipt
dispatch_label: UIUE_R5_DISPATCH_2_MAINLINE_CONTRACT_TEST_HARDENING
date: 2026-06-28
repo: /Users/wanglei/workspace/MAformac
proof_class: docs/local + openspec_contract + local_unit
can_UIUE_start_consumer_mapping: yes
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
---

# R5 Mainline Contract/Test Hardening Dispatch 2 Receipt

## Verdict

`DONE`

Dispatch 2 converts `C005`, `C006`, `C007`, `C018`, `C024`, `C029`, `C030`, `C052`, `C061`, and `C143` out of vague `needs-validation`. Rows inside current bridge authority are covered by OpenSpec + Swift contract + focused unit tests. Rows that require runtime wiring, production force-state behavior, or SceneMacroRegistry ownership are explicitly deferred with owner and next validator. Hermes/GLM first pass found P1 issues; Hermes rerun stalled and was superseded by user-authorized Codex equivalent audit. All P1 findings were fixed, local validation passed, and final Codex P0/P1 audit returned PASS.

## Repo Truth

| Item | Value |
|---|---|
| main branch | `codex/rebuild-c6-doc-absorption-20260624` |
| main HEAD | `0a2ff0f7d30d6caf2d48f018f6b874828fb70c03` |
| UIUE reference HEAD | `926dec8311c63a7b51cd1a1a5f633009e25cf7d2` |
| dirty strategy | preserve preexisting dirty and Dispatch 1 existing owned changes; Dispatch 2 edits only owned mainline paths |

## Owned Paths

- `Core/Presentation/RuntimePresentationBridge.swift`
- `Tests/MAformacCoreTests/RuntimePresentationBridgeTests.swift`
- `openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md`
- `openspec/changes/define-runtime-presentation-bridge/tasks.md`
- `docs/project/phase0/r5-mainline-contract-test-hardening-dispatch-2-2026-06-28.md`

## Dispatch 1 Existing Owned

- `Core/Presentation/RuntimePresentationBridge.swift`
- `Tests/MAformacCoreTests/RuntimePresentationBridgeTests.swift`
- `openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md`
- `openspec/changes/define-runtime-presentation-bridge/tasks.md`
- `docs/project/phase0/r5-mainline-terminal-snapshot-adapter-dispatch-1-2026-06-28.md`

## Preserve Unowned

- `AGENTS.md`
- `CLAUDE.md`
- `docs/CURRENT.md`
- `docs/README.md`
- `.xcodebuildmcp/`
- `Tools/agent-platform-plugin-refs/`

## Row Disposition Table

| row_id | before | after | disposition | proof_path | proof_class | validation | remaining_gap_or_next_owner |
|---|---|---|---|---|---|---|---|
| `C005` | Write ownership through executor/runtime adapter not behavior-proven. | Explicitly deferred to runtime adapter wiring; bridge remains snapshot/event contract-only. | `deferred_with_owner` | `openspec/changes/define-runtime-presentation-bridge/tasks.md:62` | docs/local | Stage 2 local validation PASS; runtime proof deferred | Owner: future mainline runtime adapter. Next validator: runtime adapter tests proving no direct UI/store mutation outside executor path. |
| `C006` | Event set closure ambiguous if timeout is required as event kind. | Timeout is terminal stop/result outcome, not a user interaction event kind. | `covered` | `RuntimePresentationBridgeTests.swift:186`; `spec.md:125`; `tasks.md:54` | openspec_contract + local_unit | `swift test --filter RuntimePresentationBridgeTests` PASS: 15 tests, 0 failures | None for Dispatch 2. Future runtime lifecycle wiring remains outside this row. |
| `C007` | Event-level provenance vs scope split not fully locked. | Event source/provenance is explicit; scope origin remains snapshot/readback/outcome metadata. | `covered` | `RuntimePresentationBridge.swift:12`; `RuntimePresentationBridgeTests.swift:199`; `spec.md:132`; `tasks.md:55` | openspec_contract + local_unit | `swift test --filter RuntimePresentationBridgeTests` PASS: 15 tests, 0 failures | None for Dispatch 2. UIUE must not infer scope from event text. |
| `C018` | `SceneMacroRegistry` absent in live mainline Core; UIUE docs only candidate/historical. | Deferred; UIUE cannot treat SceneMacroRegistry as shared runtime config until mainline creates future OpenSpec/Core owner. | `deferred_with_owner` | `openspec/changes/define-runtime-presentation-bridge/tasks.md:63` | docs/local | Stage 2 local validation PASS; runtime/config proof deferred | Owner: future mainline scenario/macro config lane. Next validator: OpenSpec + tests for Core config, trace, allowed tools, and no hidden planner. |
| `C024` | TraceEnvelope shape exists but redaction lock/test absent. | Presentation-safe trace envelope redacts raw model output, training receipt, and raw runtime store markers across reason, message, and string-bearing trace attributes; terminal snapshot boundary sanitizes traceEnvelope before exposure. | `covered` | `RuntimePresentationBridge.swift:192`; `RuntimePresentationBridge.swift:490`; `RuntimePresentationBridge.swift:496`; `RuntimePresentationBridge.swift:509`; `RuntimePresentationBridgeTests.swift:222`; `RuntimePresentationBridgeTests.swift:277`; `spec.md:139`; `tasks.md:56` | openspec_contract + local_unit | `swift test --filter RuntimePresentationBridgeTests` PASS: 15 tests, 0 failures | Reason taxonomy can become stricter later; no Dispatch 2 blocker. |
| `C029` | Active/refused priority semantics unproven. | Rewritten and covered: refused/unsafe cards can outrank satisfied cards deterministically. | `covered` | `RuntimePresentationBridge.swift:281`; `RuntimePresentationBridgeTests.swift:333`; `spec.md:146`; `tasks.md:57` | openspec_contract + local_unit | `swift test --filter RuntimePresentationBridgeTests` PASS: 15 tests, 0 failures | UIUE visual styling remains local presentation work. |
| `C030` | Card schema DTO capacity exists but scope/reason/active/sibling semantics not locked. | Machine-readable card semantics cover role, active state, sibling keys, reason, and scope origin. | `covered` | `RuntimePresentationBridge.swift:315`; `RuntimePresentationBridgeTests.swift:333`; `spec.md:146`; `tasks.md:58` | openspec_contract + local_unit | `swift test --filter RuntimePresentationBridgeTests` PASS: 15 tests, 0 failures | UIUE copy/layout remains presentation-only. |
| `C052` | Force-state context gate lacks mainline proof. | Rewritten and deferred; no production force-state behavior is created in Dispatch 2. | `deferred_with_owner` | `openspec/changes/define-runtime-presentation-bridge/tasks.md:60` | docs/local | Stage 2 local validation PASS; force-state proof deferred | Owner: future demo tooling or K1 spike lane. Next validator: prove DEMO_MODE gating, trace provenance, and no production path. |
| `C061` | Retry/idempotency no-double-write/no-swallowed-no-op proof absent. | Rewritten and deferred; belongs to future runtime adapter execution tests, not passive bridge DTO. | `deferred_with_owner` | `openspec/changes/define-runtime-presentation-bridge/tasks.md:61` | docs/local | Stage 2 local validation PASS; runtime execution proof deferred | Owner: future mainline runtime adapter. Next validator: execution tests for retry/no duplicate write/no swallowed no-op. |
| `C143` | `TraceEnvelope.entries` append-only/time monotonic semantics not locked. | TraceEnvelope `traceID` is immutable, entries are `private(set)`, failable init/append/Codable decode require matching trace identity and monotonic timestamps. | `covered` | `RuntimePresentationBridge.swift:155`; `RuntimePresentationBridge.swift:176`; `RuntimePresentationBridge.swift:212`; `RuntimePresentationBridge.swift:233`; `RuntimePresentationBridgeTests.swift:222`; `RuntimePresentationBridgeTests.swift:264`; `RuntimePresentationBridgeTests.swift:305`; `spec.md:139`; `tasks.md:59` | openspec_contract + local_unit | `swift test --filter RuntimePresentationBridgeTests` PASS: 15 tests, 0 failures | Distributed/concurrent tracing remains future runtime/client work. |

## Rewrite Receipts

| row_id | rewritten assertion | disposition |
|---|---|---|
| `C006` | Timeout is a terminal stop/result outcome and SHALL NOT require adding `timeout` to the user interaction event kind set. | `covered` |
| `C029` | Refused/unsafe card states can outrank satisfied card states in deterministic presentation ordering. | `covered` |
| `C052` | Production force-state behavior is not created here; any future force-state context must prove DEMO_MODE gating, trace provenance, and no production path before implementation. | `deferred_with_owner` |
| `C061` | Retry/idempotency no-double-write/no-swallowed-no-op belongs to future runtime adapter execution tests; bridge contract hardening cannot fake runtime execution proof. | `deferred_with_owner` |

## K1 Status

`untouched_spike_ledger: yes`

K1 remains a spike-before-implementation ledger. Dispatch 2 did not promote or implement K1 rows.

## Validation

| Command | Result | Proof class |
|---|---|---|
| `openspec validate define-runtime-presentation-bridge --strict` | PASS: `Change 'define-runtime-presentation-bridge' is valid` | openspec_contract |
| `openspec validate --all --strict` | PASS: 16 items passed, 0 failed | openspec_contract |
| `git diff --check` | PASS | local/static |
| `swift test --filter RuntimePresentationBridgeTests` | PASS: 15 tests, 0 failures | local/unit |

## Audits

| Audit | Status |
|---|---|
| Codex native subagent P0/P1 audit | PASS after fixes: no unresolved P0/P1 |
| Hermes/GLM P0/P1 audit | First pass FAIL with P1 on `C024`/`C143`; findings fixed. Rerun stalled and was superseded by user-authorized Codex equivalent audit. |
| Codex equivalent audit after Hermes stall | PASS: no unresolved P0/P1 |

## Residual Risks

- `C005` and `C061` are deliberately deferred because direct write ownership and retry/idempotency require runtime adapter execution tests.
- `C018` is deliberately deferred because no live mainline `SceneMacroRegistry` owner exists yet.
- `C052` is deliberately deferred to avoid creating production force-state behavior under a presentation bridge dispatch.
- This receipt does not claim runtime-ready, UIUE merge, mobile/true-device, voice/model/golden, endpoint, A-2/A-2 ready/A-2 complete, or V/S/U pass.

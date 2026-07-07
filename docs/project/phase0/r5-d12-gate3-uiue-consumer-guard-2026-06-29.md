---
status: DONE
artifact_kind: r5_d12_gate3_uiue_consumer_guard_receipt
created_at: 2026-06-29
gate: R5-D12-gate-3
proof_class_ceiling: docs/local + local_static + openspec_contract
hermes_output: /Users/wanglei/workspace/MAformac-uiue/Reports/r5-d12-gate3-uiue-consumer-guard-20260629T1110/hermes-output.txt
uiue_code_changed: false
main_code_changed_in_gate3: false
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

# R5 D12 Gate 3 - UIUE Consumer Guard

## Scope Decision

Gate 3 is docs-only.

Main Gate 2 created local/unit Runtime Adapter V0 code in main:

- `/Users/wanglei/workspace/MAformac/Core/Execution/DemoRuntimeAdapter.swift`
- `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/DemoRuntimeAdapterTests.swift`
- main commit `451c699 feat(main): add r5 d12 runtime adapter v0`

Those types are main internal execution proof surfaces, not stable UIUE-facing DTO fields or a presentation payload contract. UIUE therefore must not add Swift consumer parsing, new shared fields, or mapping names for `commandID`, `requestFingerprint`, `DemoRuntimeAdapterResult`, `DemoRuntimeAdapterProvenance`, `first_execution`, `retry_replay`, or `already_state_noop` beyond its existing presentation result mapping.

## Metacognitive Harness

| check | result |
|---|---|
| Pre-mortem | Gate 3 could fake green by treating main internal Swift types as a UIUE contract, by changing UIUE mapping rows to claim C005/C061 closure, or by promoting local/unit adapter proof into runtime-ready proof. |
| Lessons learned reflection | D9-D11 repeatedly separated UIUE consumer mapping from main execution ownership. Gate 2 moved C005/C061 only to main local/unit code-backed proof; it did not publish a UIUE payload contract. |
| Local + web cross-search | Local search found existing UIUE consumer mapping and row dispositions, but no `DemoRuntimeAdapter` consumer surface. Web cross-search used Google AIP-180, Azure API versioning guidance, and Confluent schema compatibility docs: consumers should rely on stable provider contracts and compatibility rules, not infer private producer fields. |
| Iceberg teardown | Visible symptom: main now has new adapter types. Iceberg class: provider-internal execution proof can be mistaken for consumer API. Same-class risks: field-name drift, enum drift, proof promotion, and UIUE merge pressure. Immediate fix: docs-only guard. Class-level fix: require explicit main-owned presentation contract before UIUE Swift mapping. Governance fix: Gate 4 map/burndown must separate main local/unit progress from UIUE consumer readiness. |
| Goal-drift check | Goal: prevent UIUE field invention. Non-goals: UIUE implementation, visual redesign, simulator proof, runtime-ready proof, merge/PR/push. |
| Authority check | Live main Gate 2 commit, Gate 1 OpenSpec, UIUE code, and validation commands beat older receipts. |
| Claim-vs-proof check | This receipt claims only docs/local + local_static + openspec_contract guard proof. It does not claim UIUE consumes Runtime Adapter V0. |
| Boundary/no-touch check | UIUE code remains unchanged. Main is read-only in Gate 3. D12 source dispatch remains untracked and unstaged. |
| Self-question before Hermes | If this were wrong, `rg` would show UIUE code consuming `DemoRuntimeAdapter` fields or main Gate 2 would contain a stable UIUE-facing presentation contract. |
| Post-Hermes correction rule | If this receipt changes after Hermes PASS, rerun `git diff --check`, `openspec validate ui-presentation --strict`, and Gate 3 Hermes before commit/no-commit. |

## Live Truth

| repo | truth |
|---|---|
| UIUE | `/Users/wanglei/workspace/MAformac-uiue`; branch `uiue/phase4-default-scope-presentation`; HEAD `b97752d7e12a87ff64441d29a0765f9f8b123ad7`; dirty only D12 dispatch plus this Gate 3 receipt before commit. |
| main | `/Users/wanglei/workspace/MAformac`; Gate 2 commit `451c699`; main preserve-unowned dirty remains outside Gate 3 scope. |

## Local Search Notes

Command:

```bash
rg -n "DemoRuntimeAdapter|RuntimeAdapter|runtime adapter|commandID|requestFingerprint|retryReplay|alreadyStateNoop|idempotency|idempotent|ledger|set_vehicle_control|vehicle_control" Core Tests docs openspec
```

Findings:

- `Core/Presentation/RuntimePresentationConsumerMapping.swift` already consumes stable presentation result names and proof caps, not the new main Gate 2 adapter fields.
- Existing row disposition for `C005`/`C061` remains a UIUE-side statement that UIUE consumer mapping itself is not execution proof.
- No UIUE code consumes `DemoRuntimeAdapter`, `DemoRuntimeAdapterResult`, `requestFingerprint`, or retry ledger fields.

## Web Cross-Search Notes

These external references are non-load-bearing context only. Gate 3's operative proof remains local/OpenSpec: main Gate 2 did not publish a UIUE-facing payload contract, and UIUE did not add consumer fields.

| source | note |
|---|---|
| Google AIP-180, `https://google.aip.dev/180` | Stable APIs require source and wire compatibility; consumers should not rely on unstated/private shape changes. |
| Azure API versioning guidance, `https://learn.microsoft.com/en-us/azure/developer/intro/azure-service-sdk-tool-versioning` | Versioned contracts exist so clients can continue to work while services evolve. |
| Confluent schema evolution docs, `https://docs.confluent.io/platform/current/schema-registry/fundamentals/schema-evolution.html` | Compatibility must define whether old/new consumers can read old/new producer schemas; this supports waiting for explicit schema ownership. |

## Pitfall Trigger Record

| trigger | result |
|---|---|
| Hermes P2: web cross-search notes were not required inside proof cap | Treated as a D12 pitfall trigger. Local search and OpenSpec remain the authoritative proof. The web notes are retained only as non-load-bearing context for the general consumer/provider compatibility risk class. |

## Guard Decision

| item | disposition |
|---|---|
| `DemoRuntimeAdapter` | main internal execution boundary; not UIUE-facing. |
| `DemoRuntimeAdapterResult` | main local/unit result type; not a UIUE presentation payload contract. |
| `DemoRuntimeAdapterProvenance.firstExecution/retryReplay/alreadyStateNoop` | main execution provenance; not newly consumed by UIUE in Gate 3. |
| `commandID` | adapter caller identity; not a UIUE shared field. |
| `requestFingerprint` | adapter idempotency implementation detail; not a UIUE shared field. |
| `C005` | main moved to local/unit code-backed adapter-owned mock write proof; UIUE still cannot prove execution ownership. |
| `C061` | main moved to local/unit code-backed in-memory retry/idempotency proof; UIUE still cannot claim runtime readiness. |
| `C018` | unchanged; future main Core config authority lane. |
| `C052` | unchanged; future force-state lane. |

## Validation

Required Gate 3 docs-only validation:

- `git diff --check`
- `openspec validate ui-presentation --strict`

Swift validation and GitNexus impact/detect are not required because no UIUE Swift symbol is changed.

## Hermes

Gate 3 hard gate:

- output: `/Users/wanglei/workspace/MAformac-uiue/Reports/r5-d12-gate3-uiue-consumer-guard-20260629T1110/hermes-output.txt`
- required verdict anchor: `HERMES_R5_D12_GATE_3_UIUE_CONSUMER_GUARD_VERDICT: PASS`
- unresolved P0/P1 must be empty before commit/no-commit and before Gate 4.

## Exact Pathspec Candidate

```bash
git add -- docs/project/phase0/r5-d12-gate3-uiue-consumer-guard-2026-06-29.md
```

Do not stage:

- `docs/dispatches/2026-06-29-uiue-r5-d12-runtime-adapter-v0-code-train-dispatch.md`
- `Reports/`

## Residual Risks

- Gate 3 does not create or test a UIUE runtime adapter consumer because main did not publish a UIUE-facing payload contract.
- Existing UIUE row dispositions still express UIUE's consumer boundary; Gate 4 should update commander map/burndown to reflect main Gate 2 code-backed local/unit progress.
- Future UIUE Swift mapping must wait for a main-owned presentation contract or explicit integration dispatch.

---
retire_trigger: "Retire when superseded by archived OpenSpec specs or explicit user decision."
expires: "2026-08-15"
---

# R5 D13 Gate 3 - UIUE C3 Adapter Boundary Guard

Date: 2026-06-29
Gate: 3 of 4
Label: `D13_GATE_3_UIUE_BOUNDARY`
Proof class: `docs/local` / `local_static` / `OpenSpec`
Scope: UIUE docs-only guard

## Verdict

Candidate status after local validation and before Hermes: `LOCAL_READY_FOR_HERMES`.

Gate 3 confirms that D13 Gate 2 main C3 integration does not create a UIUE-facing payload contract and does not authorize UIUE to consume Runtime Adapter V0 private fields. UIUE remains a guarded consumer. No UIUE Swift code is changed.

## Dirty Split Before Gate 3 Writes

Main repo after Gate 2:

```text
HEAD 612e0dfafc4fea1b07e8f3c7001c99621a423a1c
preserve-unowned dirty remains:
 M AGENTS.md
 M CLAUDE.md
 M docs/CURRENT.md
 M docs/README.md
?? .xcodebuildmcp/
?? Tools/agent-platform-plugin-refs/
```

UIUE repo before Gate 3 writes:

```text
## uiue/phase4-default-scope-presentation...origin/uiue/phase4-default-scope-presentation [ahead 75]
?? docs/dispatches/2026-06-29-uiue-r5-d12-runtime-adapter-v0-code-train-dispatch.md
?? docs/dispatches/2026-06-29-uiue-r5-d13-c3-runtime-adapter-integration-dispatch.md
HEAD e47a16355bf5f1fb3dfc15cd2bfa79522cc00d7c
```

Gate 3 writable path is this receipt only.

## Inputs Reconfirmed

- Main Gate 1 commit: `199a12c1596579866eb09f21ab2601869322deea`.
- Main Gate 2 commit: `612e0dfafc4fea1b07e8f3c7001c99621a423a1c`.
- Gate 2 proof class: local/unit/OpenSpec/GitNexus/Hermes.
- Gate 2 non-claims: no runtime-ready, no persistent ledger, no mobile proof, no true-device proof, no UIUE payload contract, no UIUE merge, no V/S/U-PASS, no A-2 claim.
- D12 Gate 3 guard remains valid: main adapter types are main internal execution proof surfaces, not UIUE DTO fields.

## Targeted Grep Classification

Command:

```bash
rg -n "DemoRuntimeAdapter|DemoRuntimeAdapterResult|DemoRuntimeAdapterProvenance|commandID|requestFingerprint|first_execution|retry_replay|already_state_noop|state_key|target_state" Core Tests docs --glob '!docs/dispatches/**'
```

Classification:

| hit class | representative hits | owner/context | D13 disposition |
| --- | --- | --- | --- |
| `DemoRuntimeAdapter*` | D12 Gate 3 receipt only | Historical guard doc, not code consumer. | Allowed evidence reference. No UIUE consumer field. |
| `commandID`, `requestFingerprint`, `first_execution`, `retry_replay` | D12 Gate 3 receipt only | Historical guard doc, not code consumer. | Allowed negative guard vocabulary. |
| `already_state_noop` in `Core/Presentation/RuntimePresentationConsumerMapping.swift`, `PresentationSnapshot.swift`, and tests | Existing runtime presentation result vocabulary from RPB work. | Existing bridge/presentation contract, not D13 adapter provenance. |
| `state_key`, `target_state` in `ToolCallFrame`, `DemoActionExecutor`, `FastPathIntentEngine`, `DemoGuard` | Existing routing/tool-frame/execution vocabulary. | Existing UIUE local demo code, not new D13 adapter payload fields. |
| `state_key` in docs/research/repo-intelligence | Historical/research docs. | Not consumer implementation. |

No UIUE Swift code consumes `DemoRuntimeAdapter`, `DemoRuntimeAdapterResult`, `DemoRuntimeAdapterProvenance`, `requestFingerprint`, or adapter ledger state. Existing `already_state_noop`, `state_key`, and `target_state` hits predate D13 and must not be reclassified as D13 adapter payload consumption.

## Guard Decision

| item | Gate 3 decision |
| --- | --- |
| Runtime Adapter V0 provenance (`first_execution`, `retry_replay`, `already_state_noop`) | Internal main execution evidence unless and until a future main-owned presentation payload contract publishes it. Existing UIUE `already_state_noop` mapping remains presentation vocabulary only. |
| `commandID` | Main adapter caller identity, not a UIUE shared field. |
| `requestFingerprint` | Main idempotency implementation detail, not a UIUE shared field. |
| `DemoRuntimeAdapterResult` | Main local/unit result type, not UIUE DTO. |
| C3 trace execute message provenance | Internal main trace detail, not UIUE payload. |
| `C005` / `C061` after Gate 2 | Can be described as C3-path local/unit code-backed in main, still not runtime-ready and not UIUE consumer-ready. |

## Harness

Pre-mortem: Gate 3 could fail by string-matching `already_state_noop`, `state_key`, or `target_state` and falsely claiming UIUE consumes D13 adapter private fields. It could also overcorrect by deleting existing presentation vocabulary that is already owned by bridge work.

Lesson learned: D12 already showed that provider-internal execution proof and consumer presentation contract are separate. D13 strengthens main execution path but still does not publish UIUE payload fields.

Local + web cross-search: local grep classified hits by owner/context. External references reinforce that APIs and schemas are consumer contracts only when explicitly published and compatibility-managed:

- Google AIP-180: `https://google.aip.dev/180`
- Azure service/API versioning policy: `https://learn.microsoft.com/en-us/azure/developer/intro/azure-service-sdk-tool-versioning`
- Confluent schema evolution: `https://docs.confluent.io/platform/current/schema-registry/fundamentals/schema-evolution.html`

Iceberg teardown: visible symptom is overlapping field names across routing, presentation, and adapter layers. Underlying class is ownership drift: a string can be stable in one layer and private in another. Immediate fix is docs-only guard with owner/context classification. Class-level fix is to require explicit main-owned presentation payload contract before UIUE Swift consumption. Governance fix is to keep Gate 4 map/burndown proof classes separate.

Goal-drift check: Gate 3 does not create a payload contract, does not edit UIUE Swift, and does not update map/burndown; those belong to later gates.

Authority check: live main Gate 2 commit and UIUE grep beat older prose. D13 dispatch forbids UIUE shared field invention.

Claim-vs-proof: docs/local + local_static + OpenSpec validation only.

Boundary check: main read-only in Gate 3. UIUE writable path is this receipt only. Existing untracked dispatch files remain unstaged.

Self-question: If this guard were wrong, `rg` would show new UIUE code consuming `DemoRuntimeAdapter*`, `requestFingerprint`, or adapter ledger/provenance as a DTO field. It does not.

Post-Hermes correction rule: if Hermes returns P0/P1, missing anchor, timeout, or evidence gap, Gate 3 is not done. If Hermes returns P2/lower, run pitfall loop and update candidate content only when needed, then rerun local validation and Hermes if content changes.

## Local Validation

```text
git diff --check
PASS

openspec validate ui-presentation --strict
Change 'ui-presentation' is valid
```

## Access Gaps And Residual Risks

- UIUE GitNexus index remains stale; this gate relies on live grep and OpenSpec validation.
- No UIUE runtime/simulator/mobile/true-device proof.
- No UIUE payload contract is defined; future UIUE consumption still requires a separate main-owned presentation contract.
- Existing `already_state_noop` UIUE presentation vocabulary remains in scope for bridge work, but not D13 adapter provenance consumption.

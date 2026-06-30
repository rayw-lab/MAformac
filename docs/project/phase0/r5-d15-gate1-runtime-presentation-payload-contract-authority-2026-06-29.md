# R5 D15 Gate 1 - Runtime Presentation Payload Contract Authority

Date: 2026-06-29
Gate: 1 of 4
Label: `D15_GATE_1_PAYLOAD_CONTRACT_AUTHORITY`
Proof class: `docs/local` / `local_static` / `OpenSpec`
Scope: main OpenSpec authority and Gate 1 receipt only

## Verdict

Final Gate 1 status: `DONE`.

Codex native subagent audit `019f1271-9e0b-7f72-8039-16022f0802cc`: `PASS`, `findings_P0_P1: []`, `findings_P2_lower: []`.

Hermes audit transcript: `/tmp/r5-d15-gate1-hermes-audit.txt`.

Hermes anchor:

```text
HERMES_R5_D15_GATE_1_PAYLOAD_CONTRACT_AUTHORITY_VERDICT: PASS
findings_P0_P1: []
findings_P2_lower: []
```

D15 Gate 1 defines the main-owned Runtime -> Presentation payload/readback/reconciliation contract boundary after D14 adapter semantics. It authorizes stable presentation-safe field categories only. It does not implement Swift code, does not create a UIUE consumer, and does not expose adapter-private fields.

Hermes hard-gate note: D15 requires an anchored Hermes PASS for every gate. If Hermes times out, lacks quota, lacks the required anchor, or reports P0/P1, this gate is not DONE and the train stops unless commander/operator explicitly overrides D15.

## Dirty Split Before Gate 1 Writes

Main repo:

```text
HEAD 66dda258052a5f29b397db0a554eda5b6dabce5f
branch codex/rebuild-c6-doc-absorption-20260624
preserve-unowned dirty:
 M AGENTS.md
 M CLAUDE.md
 M docs/CURRENT.md
 M docs/README.md
?? .xcodebuildmcp/
?? Tools/agent-platform-plugin-refs/
cached: empty
```

UIUE repo:

```text
HEAD 3bab4c80ee8d360cb7ebdfcfcb8869d6ababb2d7
branch uiue/phase4-default-scope-presentation
untracked source artifacts:
?? docs/dispatches/2026-06-29-uiue-r5-d12-runtime-adapter-v0-code-train-dispatch.md
?? docs/dispatches/2026-06-29-uiue-r5-d13-c3-runtime-adapter-integration-dispatch.md
?? docs/dispatches/2026-06-29-uiue-r5-d14-runtime-adapter-residual-train-dispatch.md
?? docs/dispatches/2026-06-29-uiue-r5-d15-runtime-presentation-payload-contract-dispatch.md
?? docs/research/2026-06-29-visual-acceptance-standard/
cached: empty
```

No duplicate D15 receipt was present in either repo before Gate 1 writes.

## Authority Inputs

- D15 dispatch source: `/Users/wanglei/workspace/MAformac-uiue/docs/dispatches/2026-06-29-uiue-r5-d15-runtime-presentation-payload-contract-dispatch.md`.
- Main authority: `AGENTS.md`, `CLAUDE.md`, `docs/CURRENT.md`, `docs/README.md`.
- Active main OpenSpec: `openspec/changes/define-runtime-presentation-bridge/`.
- D14 receipts:
  - `docs/project/phase0/r5-d14-gate1-runtime-adapter-residual-openspec-authority-2026-06-29.md`
  - `docs/project/phase0/r5-d14-gate2-runtime-adapter-residual-code-2026-06-29.md`
  - `docs/project/phase0/r5-d14-gate3-runtime-adapter-residual-verifier-2026-06-29.md`
  - `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-d14-runtime-adapter-residual-commander-reconcile-2026-06-29.md`
- UIUE route and burndown, read-only:
  - `/Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md`
  - `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/burndown-dispatch-plan.md`

Live repo truth supersedes D14 prose and memory. D14 ended with session-scoped local/unit adapter proof and no UIUE-facing payload contract.

## Gate 1 Decisions

1. The payload contract is main-owned. UIUE may not define shared Runtime -> Presentation fields in D15.
2. Stable field categories are envelope identity, outcome, cards, readbacks, reconciliation status, proof class, and presentation-safe trace.
3. Reconciliation is exposed as presentation-safe status or mismatch class, not raw adapter ledger, C3 parent request fingerprint, or store internals.
4. The contract explicitly forbids exposing `DemoRuntimeAdapter*`, `RuntimeAdapterBox`, `requestFingerprint`, `parentRequestFingerprint`, `failureLedger`, success/failure ledger internals, settled parent-plan internals, private provenance, adapter-local names, raw runtime store, raw model output, or training receipts as UIUE-facing/presentation payload fields.
5. D15 Gate 1 does not change Swift code. Gate 2 owns implementation and tests.
6. Proof remains capped at docs/local, local_static, OpenSpec, and later local_unit/GitNexus/Codex/Hermes only when those gates pass. This is not runtime/mobile/true-device/live proof.

## OpenSpec Edits

Owned files changed:

```text
openspec/changes/define-runtime-presentation-bridge/proposal.md
openspec/changes/define-runtime-presentation-bridge/design.md
openspec/changes/define-runtime-presentation-bridge/tasks.md
openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md
docs/project/phase0/r5-d15-gate1-runtime-presentation-payload-contract-authority-2026-06-29.md
```

No Swift, UIUE, source dispatch, preserve-unowned, or OpenSpec archived spec path was edited.

## Local And Web Cross-Search

Local cross-search:

- `RuntimePresentationBridge.swift` already owns `PresentationSnapshot`, `TraceEnvelope`, finite `PresentationProofClass`, and existing trace redaction surfaces.
- `C3ExecutionPipeline.swift` and `DemoRuntimeAdapter.swift` contain readback/reconciliation and adapter-private fields that must not become payload schema.
- UIUE route map names D15 as main-owned payload contract and D17 as future UIUE consumer integration.
- Burndown rows `C005` and `C061` remain proof-strengthened, not newly closed by payload contract prose.

External method references, used only as pitfalls:

- Google AIP-180 backward compatibility: `https://google.aip.dev/180`
- Google AIP-185 versioning: `https://google.aip.dev/185`
- OWASP Logging Cheat Sheet, data to exclude: `https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html`

Repo truth remains authoritative. These sources support the general pattern of stable compatibility markers and excluding sensitive/internal implementation detail from externally consumed records.

## Harness

Pre-mortem:
D15 can fail by making adapter-private implementation names look like stable UIUE fields, by treating reconciliation ledger rows as payload data, by letting UIUE invent field names before main owns them, or by turning local/unit proof into runtime readiness.

Lesson learned / metacognitive reflection:
D14 reduced real execution residuals, but the next boundary is a vocabulary boundary, not a runtime-readiness boundary. A stable payload contract must be smaller and less revealing than the adapter implementation.

Iceberg teardown:

| field | finding |
| --- | --- |
| visible symptom | UIUE needs a future runtime payload it can safely consume. |
| underlying class | Public consumer contract pressure tends to leak private runtime, idempotency, and ledger internals when no explicit payload boundary exists. |
| same-class risk map | main code leaks adapter names; UIUE invents fields; receipt prose promotes local proof; reconciliation exposes raw ledger; trace includes raw model/training/store markers. |
| immediate fix | Gate 1 OpenSpec defines stable field categories and forbidden private fields before code. |
| class-level fix | Gate 2 must encode/build the payload from presentation-safe surfaces and add negative tests for forbidden names. |
| governance fix | Gate 3/Gate 4 must run forbidden-field grep and keep D17 as the UIUE consumer lane. |

Goal-drift check:
Gate 1 is authority only. It does not implement Swift, run UIUE consumer integration, touch Core config/SceneMacroRegistry, or upgrade proof class.

Authority check:
Current main OpenSpec and live D14 commits are stronger than older route-board wording. UIUE route map is read-only evidence until Gate 4.

Claim-vs-proof:
Gate 1 proves only docs/local OpenSpec authority after local validation and required audits. It does not prove runtime/mobile/true-device/live behavior.

Boundary check:
No `DemoRuntimeAdapter*`, `RuntimeAdapterBox`, fingerprints, ledger internals, raw store, raw model output, or training receipt are allowed as payload fields. Their appearances in Gate 1 are negative/forbidden documentation only.

Self-question:
If this authority is wrong, `openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md` would permit private adapter names in encoded payload, or UIUE route map would contradict D15/D17 ownership.

Post-audit correction rule:
If Codex or Hermes returns P0/P1, missing PASS anchor, timeout, or quota failure, Gate 1 is not DONE. Candidate changes must be repaired, local validation rerun, and both audits rerun if content changes. Under D15 rules, Hermes unavailable means `BLOCKED_HERMES_UNAVAILABLE` unless a D15-specific commander/operator override is received.

## Validation Before Commit

```text
git diff --check: PASS
openspec validate define-runtime-presentation-bridge --strict: PASS
openspec validate --all --strict: PASS, 17 passed, 0 failed
git diff --cached --name-status: PASS, exactly 5 Gate 1 owned paths
git diff --cached --check: PASS
Codex native subagent audit: PASS, P0/P1/P2 empty
Hermes audit: PASS anchor present, P0/P1/P2 empty
```

## Non-Claims

- no R5 complete
- no runtime-ready
- no mobile proof
- no true_device proof
- no voice-ready
- no model-ready
- no golden-ready
- no endpoint-ready
- no production runtime proof
- no durable ledger proof
- no live API proof
- no UIUE merge
- no UIUE runtime consumer integrated
- no V-PASS / S-PASS / U-PASS
- no A-2 ready / complete

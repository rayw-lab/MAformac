---
status: DONE
artifact_kind: r5_d12_gate1_runtime_adapter_v0_openspec_authority_receipt
created_at: 2026-06-29
gate: R5-D12-gate-1
openspec_change: define-runtime-adapter-execution
proof_class_ceiling: docs/local + local_static + openspec_contract
hermes_output: /Users/wanglei/workspace/MAformac/Reports/r5-d12-gate1-openspec-authority-20260629T103726/hermes-output.txt
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

# R5 D12 Gate 1 - Runtime Adapter V0 OpenSpec Authority

## Scope

Gate 1 creates the mainline OpenSpec authority for Runtime Adapter V0 before any Swift implementation. It authorizes only the smallest local/unit execution adapter slice for `C005` and `C061`.

## Metacognitive Harness

| check | result |
|---|---|
| Pre-mortem | Fake green risks: treating store already-state no-op as retry idempotency; writing Swift before OpenSpec authority; recording a ledger success before side-effect/readback success. |
| Lessons learned reflection | D9/D10 showed `C005` was current mock executor/store only; D11 showed `C061` needs a real adapter boundary and `C018` stays separate. D12 must not repeat docs-only deferral in Gate 2. |
| Local + web cross-search | Local `rg` found writes in `C3ExecutionPipeline`, `DemoActionExecutor`, and `DemoVehicleStateStore`, but no command-id/retry ledger adapter. Web references: Stripe idempotency docs, AWS Builders Library idempotent APIs, IETF Idempotency-Key draft. |
| Iceberg teardown | Visible symptom: no retry adapter proof. Iceberg: execution ownership and idempotency identity were implicit. Same-class risks: double-write retry, parameter-mismatch replay, fake success ledger, UIUE field pressure. Fix: OpenSpec authority now; local/unit tests next; proof caps retained. |
| Goal-drift check | Goal: OpenSpec authority for Runtime Adapter V0. Non-goals: Swift implementation, UIUE code, C018, C052, production runtime, mobile/true-device proof. |
| Authority check | Live repo, OpenSpec, tests, and validation outputs beat dated receipts and audit prose. |
| Claim-vs-proof check | Gate 1 claims docs/local + OpenSpec contract only; no code-backed proof yet. |
| Boundary/no-touch check | Only main OpenSpec/docs paths are written. Main preserve-unowned paths and UIUE are not edited. |
| Self-question before Hermes | If this were wrong, `openspec validate define-runtime-adapter-execution --strict` would fail or live code would already contain a stable command-id/retry ledger adapter. |
| Post-Hermes correction rule | If any file/pathspec/validation state changes after Hermes PASS, rerun Gate 1 validation and Hermes before commit. |

## Live Repo Truth

| repo | truth |
|---|---|
| UIUE | `/Users/wanglei/workspace/MAformac-uiue`; branch `uiue/phase4-default-scope-presentation`; HEAD `b97752d7e12a87ff64441d29a0765f9f8b123ad7`; clean except D12 source dispatch may be untracked. |
| main | `/Users/wanglei/workspace/MAformac`; branch `codex/rebuild-c6-doc-absorption-20260624`; HEAD `a048dd92ef6769b7ce1a2543b9ba46cb5d4a8cb7`; preserve-unowned dirty only before Gate 1 edits. |

## D11 Intake

| row/topic | D11 truth | Gate 1 effect |
|---|---|---|
| `C005` | Current local mock executor/store path only; not production runtime adapter proof. | Runtime Adapter V0 OpenSpec will make adapter-owned mock write path testable in Gate 2. |
| `C061` | Boundary defined but no code. Retry/full idempotency remains future. | OpenSpec defines command identity, fingerprint, in-memory ledger, replay, and failed command rules. |
| `C018` | OpenSpec/Core owner proposal first; no SceneMacroRegistry implementation. | Out of Gate 1 scope. |
| `C052` | Debug-only bounded spike; production force-state future. | Out of Gate 1 scope. |
| final-art / white-edge | Future human/art and threshold gates. | Out of Gate 1 scope. |

## Local Search Notes

Command:

```bash
rg -n "DemoActionExecutor|C3ExecutionPipeline|applyMockTransition|ToolCallFrame|RuntimePresentationTerminalSnapshotAdapter|retry|idempot|command identity|ledger" Core Tests openspec docs
```

Findings:

- `Core/Execution/C3ExecutionPipeline.swift` plans transitions and calls `store.applyMockTransition`, but has no command identity or ledger.
- `Core/Execution/DemoActionExecutor.swift` owns a current simple frame-to-store write helper.
- `Core/State/DemoVehicleStateStore.swift` already preserves revision on already-state no-op, but this is not retry identity.
- `RuntimePresentationTerminalSnapshotAdapter` is presentation/snapshot behavior, not an execution retry adapter.

## Web Cross-Search Notes

| source | note |
|---|---|
| Stripe idempotent requests, `https://docs.stripe.com/api/idempotent_requests` | Idempotency keys preserve the first result for retried requests and compare parameters to reject accidental key reuse. |
| AWS Builders Library, `https://aws.amazon.com/builders-library/making-retries-safe-with-idempotent-APIs/` | Safe retries need caller request identity and must handle duplicate/late-arriving requests intentionally. |
| IETF Idempotency-Key draft, `https://datatracker.ietf.org/doc/html/draft-ietf-httpapi-idempotency-key-header` | Idempotency-Key plus request fingerprint is a standardizing pattern for non-idempotent retry protection. |

## OpenSpec Artifacts

- `/Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-adapter-execution/proposal.md`
- `/Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-adapter-execution/design.md`
- `/Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-adapter-execution/tasks.md`
- `/Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-adapter-execution/specs/runtime-adapter-execution/spec.md`

## Validation

PASS before Hermes:

- `git diff --check` -> PASS.
- `openspec validate define-runtime-adapter-execution --strict` -> PASS.
- `openspec validate --all --strict` -> PASS.
- `git status --short` -> Gate 1 owned paths plus existing preserve-unowned dirty only.
- `git diff --name-only` -> existing preserve-unowned tracked dirty only because Gate 1 OpenSpec/receipt files are new untracked paths before exact staging; `git status --short` is the dirty-path authority for Gate 1.

No Swift files changed in Gate 1; no Swift test is required.

## Hermes

PASS:

- output: `/Users/wanglei/workspace/MAformac/Reports/r5-d12-gate1-openspec-authority-20260629T103726/hermes-output.txt`
- required verdict anchor: `HERMES_R5_D12_GATE_1_OPENSPEC_AUTHORITY_VERDICT: PASS`
- findings_P0_P1: none

## Touched Paths

- `/Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-adapter-execution/.openspec.yaml`
- `/Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-adapter-execution/proposal.md`
- `/Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-adapter-execution/design.md`
- `/Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-adapter-execution/tasks.md`
- `/Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-adapter-execution/specs/runtime-adapter-execution/spec.md`
- `/Users/wanglei/workspace/MAformac/docs/project/phase0/r5-d12-gate1-runtime-adapter-v0-openspec-authority-2026-06-29.md`

## Exact Pathspec Candidate

```bash
git add -- \
  openspec/changes/define-runtime-adapter-execution/.openspec.yaml \
  openspec/changes/define-runtime-adapter-execution/proposal.md \
  openspec/changes/define-runtime-adapter-execution/design.md \
  openspec/changes/define-runtime-adapter-execution/tasks.md \
  openspec/changes/define-runtime-adapter-execution/specs/runtime-adapter-execution/spec.md \
  docs/project/phase0/r5-d12-gate1-runtime-adapter-v0-openspec-authority-2026-06-29.md
```

## Residual Risks

- No Swift code-backed proof exists until Gate 2.
- In-memory ledger is local/unit only and not production persistence.
- `C018`, `C052`, final-art, and white-edge remain future gates.

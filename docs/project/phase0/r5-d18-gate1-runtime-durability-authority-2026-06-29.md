# R5 D18 Gate 1 Runtime Durability Authority

Date: 2026-06-29
Label: `D18_GATE_1_RUNTIME_DURABILITY_AUTHORITY`
Repo: `/Users/wanglei/workspace/MAformac`
Proof class: `local` / `OpenSpec` / `docs`
Status: `DONE`

## Conclusion

Gate 1 defines main-owned D18 runtime durability authority for `C005` / `C061` residual reduction. The new authority permits only `local_durable_adapter_ledger` proof: explicit local file-backed adapter/C3 ledger reconstruction using deterministic temporary-directory storage and local tests.

This does not claim production runtime durability, mobile, true-device, live API, voice/model/golden/endpoint readiness, UIUE merge, V-PASS, S-PASS, U-PASS, A-2 readiness, A-2 completion, or R5 completion.

## Scope Contract

| Item | Contract |
| --- | --- |
| Goal | Define D18 local durable adapter ledger authority before Swift implementation. |
| Non-goals | No Swift implementation, no UIUE writes, no production durable runtime, no presentation payload expansion. |
| Scope in | `define-runtime-adapter-execution` proposal/design/tasks/spec and this receipt. |
| Scope out | UIUE consumer code, `RuntimePresentationPayload`, private adapter fields as shared fields, production vehicle control, voice, model, golden, endpoint, mobile, true-device, push/PR/merge. |
| Writable paths | OpenSpec runtime adapter files and this receipt only. |
| No-touch paths | main preserve-unowned dirty paths; UIUE files except read-only grep; source dispatch docs. |
| Stop conditions | Extra owned dirty, OpenSpec failure not fixable in authority docs, proof wording promotes local proof to production/runtime/mobile/live, or UIUE field invention pressure. |

## Authority Chain

- D14 authority kept adapter/C3 ledger state session-scoped and explicitly left durable persistent ledger storage as future work.
- D15 presentation payload authority forbids exposing `DemoRuntimeAdapter*`, `RuntimeAdapterBox`, `requestFingerprint`, `parentRequestFingerprint`, `failureLedger`, success/failure ledger internals, settled parent-plan internals, raw runtime store, raw model output, and training receipts.
- D16+D17 final reconcile kept `C005` / `C061` durable/persistent/runtime/mobile/true-device/live residuals open under proof cap.
- D18 Gate 1 now narrows the next residual slice to local file-backed durable reconstruction owned by main only.

## What Changed

- Added D18 scope to `proposal.md`.
- Added `AD-RAE-020` through `AD-RAE-025` to `design.md` for explicit local durable ledger storage, success-after-readback persistence, cross-adapter reconstruction, private failure taxonomy, C3 cross-pipeline reconstruction, and UIUE/presentation no-leak boundary.
- Added spec requirements for local durable adapter ledger boundary, durable success replay reconstruction, durable failure ledger semantics, and C3 local durable reconstruction.
- Added D18 Gate 1-Gate 3 task rows in `tasks.md`.

## Local Repo Cross-Search

| Evidence | Finding |
| --- | --- |
| `openspec/changes/define-runtime-adapter-execution/design.md` | Existing D14 authority says ledger is session-scoped and durable storage is future work. |
| `openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md` | Presentation payload forbids request fingerprints, failure ledger internals, raw runtime store, raw model output, and training receipts. |
| `Core/Presentation/RuntimePresentationBridge.swift` | Existing deny-list contains `DemoRuntimeAdapter`, `RuntimeAdapterBox`, `requestFingerprint`, `parentRequestFingerprint`, and `failureLedger`. |
| UIUE D16+D17 reconcile receipt | `C005` / `C061` durable/persistent/runtime/mobile/live residuals remain open after D17. |

## External Cross-Search

| Source | D18 lesson |
| --- | --- |
| Stripe idempotent requests docs: `https://docs.stripe.com/api/idempotent_requests` | Same key with different parameters must error; results are saved only after endpoint execution begins. D18 mirrors this with fingerprint conflict and success-after-readback persistence. |
| AWS Builders Library, "Making retries safe with idempotent APIs": `https://aws.amazon.com/builders-library/making-retries-safe-with-idempotent-APIs/` | Caller intent/request identity is central to safe retries. D18 keeps command identity explicit and separates parent C3 identity from per-transition adapter identity. |
| IETF HTTP Idempotency-Key draft: `https://datatracker.ietf.org/doc/html/draft-ietf-httpapi-idempotency-key-header-04` | Request fingerprints can qualify idempotency keys. D18 requires fingerprint match before durable replay. |

## Pre-Mortem

D18 can fail by naming local file-backed storage "production durability", by persisting success before readback reconciliation, by decoding corrupt durable rows permissively, by letting failure records masquerade as success replay, by replaying changed C3 parent requests, or by letting UIUE consume `requestFingerprint`, `failureLedger`, durable ledger rows, or adapter-local provenance as stable payload fields.

## Iceberg Teardown

| Layer | Finding |
| --- | --- |
| Visible symptom | `C005` / `C061` still have durable/persistent ledger residuals after D14-D17. |
| Underlying class | Retry/idempotency proof can drift from execution ownership into storage wording or consumer schema pressure. |
| Same-class risk map | main: local storage overclaims production; UIUE: private durable names enter allow-lists; runtime: corrupt rows replay writes; proof: local/unit becomes runtime/mobile/live; governance: dirty/staged source dispatch mixes with owned files. |
| Immediate fix | Define local durable authority and forbidden fields before Swift. |
| Class-level fix | Gate2/Gate3 tests must prove reconstruction, conflict, corrupt-entry, failure, and readback fail-closed behavior. |
| Governance fix | Exact pathspec commits, no `git add .`, and three batched audits instead of every-gate audit. |

## Metacognitive Reflection

The tempting shortcut is to treat "file-backed" as the same word as "durable". That is not rigorous enough here. The authority must specify what survives, under which local fixture, which identities qualify replay, and which proof classes remain unproven.

## Goal-Drift Check

Gate 1 stayed documentation/OpenSpec only. It did not implement Swift, alter payload schema, write UIUE code, or reopen D16+D17 results.

## Claim vs Proof

| Claim | Proof available after Gate 1 | Proof cap |
| --- | --- | --- |
| D18 authority exists for local durable adapter ledger | OpenSpec proposal/design/spec/tasks updated and validated locally. | `local` / `OpenSpec` |
| UIUE cannot consume durable/private fields from this gate | Authority forbids field exposure; D15 bridge spec remains separate authority. | `local` / `docs` |
| Local durable reconstruction works | Not claimed in Gate 1; deferred to Gate2/Gate3 tests. | none yet |
| Production durable runtime works | Not claimed. | none |

## Non-Claims

- no Swift implementation in Gate 1
- no runtime/mobile/true-device/live proof
- no production durable ledger proof
- no UIUE merge or UIUE runtime consumer proof
- no V-PASS, S-PASS, U-PASS, A-2, voice-ready, model-ready, golden-ready, endpoint-ready, or R5 complete claim
- no new UIUE shared fields

## Boundary Check

D18 durable ledger internals remain main-private. The Runtime -> Presentation bridge may expose only presentation-safe adapter-agnostic fields already owned by main authority. UIUE must treat durable ledger, persistent ledger, adapter ledger, fingerprints, failure ledgers, success ledger internals, settled parent-plan internals, raw private payload, raw runtime store, raw model output, and training receipts as deny-list or documentation-only negative examples unless a later main-owned contract says otherwise.

## Self-Question

If this were wrong, `openspec/changes/define-runtime-adapter-execution/specs/runtime-adapter-execution/spec.md` would permit changed fingerprints or corrupt rows to replay, `openspec/changes/define-runtime-adapter-execution/design.md` would call local file-backed storage production durable runtime, or `openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md` would expose private durable fields as payload.

## Post-Audit Correction Rule

Hermes round 1 will run after Gates 1-3. If Hermes finds P0/P1 in Gate1 authority, owned docs/code must be fixed and affected local validation rerun before D19 starts. Any fail-fixed result must be recorded as fail-fixed, not as a clean Hermes PASS.

## Validation

| Command | Result | Proof class |
| --- | --- | --- |
| `git diff --check` | PASS | `local/static` |
| `openspec validate define-runtime-adapter-execution --strict` | PASS: change is valid | `local/OpenSpec` |
| `openspec validate define-runtime-presentation-bridge --strict` | PASS: change is valid | `local/OpenSpec` |
| `openspec validate --all --strict` | PASS: 18 passed, 0 failed | `local/OpenSpec` |

## Dirty Split

Expected preserved main dirty remains excluded:

- `AGENTS.md`
- `CLAUDE.md`
- `docs/CURRENT.md`
- `docs/README.md`
- `.xcodebuildmcp/`
- `Tools/agent-platform-plugin-refs/`

Owned Gate1 paths:

- `openspec/changes/define-runtime-adapter-execution/proposal.md`
- `openspec/changes/define-runtime-adapter-execution/design.md`
- `openspec/changes/define-runtime-adapter-execution/tasks.md`
- `openspec/changes/define-runtime-adapter-execution/specs/runtime-adapter-execution/spec.md`
- `docs/project/phase0/r5-d18-gate1-runtime-durability-authority-2026-06-29.md`

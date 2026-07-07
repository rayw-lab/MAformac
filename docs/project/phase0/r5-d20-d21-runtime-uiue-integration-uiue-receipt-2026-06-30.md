---
retire_trigger: "Retire when superseded by archived OpenSpec specs or explicit user decision."
expires: "2026-08-15"
---

# R5 D20/D21 Runtime UIUE Integration UIUE Receipt

Status: post-GPT-Pro fixed-post-audit receipt for `UIUE_R5_D20_D21_RUNTIME_UIUE_INTEGRATION_PR_SUPERTRAIN`.

## Scope

- UIUE adds a local presentation-safe JSON fixture consumer that maps main public `RuntimePresentationPayload` JSON into `PresentationSnapshot`.
- UIUE stores the same public runtime presentation fixture set and manifest hashes as main.
- UIUE route-control and `ui-presentation` tasks are updated under proof cap.
- GPT Pro PR-pair audit returned `REQUEST_CHANGES`; UIUE-side P0/P1 items were fixed locally or in the existing PR body without rerunning GPT Pro.

## Changed UIUE Paths

- `Core/Presentation/RuntimePresentationPayloadFixtureConsumer.swift`
- `Core/Presentation/RuntimePresentationConsumerMapping.swift`
- `Tests/MAformacCoreTests/RuntimePresentationPayloadFixtureConsumerTests.swift`
- `Tests/MAformacCoreTests/RuntimePresentationConsumerMappingTests.swift`
- `Tests/MAformacCoreTests/R5ProofGovernanceStaticChecksTests.swift`
- `Tests/Fixtures/RuntimePresentationPayload/ac_power_public_payload.v1.json`
- `Tests/Fixtures/RuntimePresentationPayload/refusal_safety_public_payload.v1.json`
- `Tests/Fixtures/RuntimePresentationPayload/runtime_error_public_payload.v1.json`
- `Tests/Fixtures/RuntimePresentationPayload/reconciliation_mismatch_public_payload.v1.json`
- `Tests/Fixtures/RuntimePresentationPayload/partial_accept_refuse_public_payload.v1.json`
- `Tests/Fixtures/RuntimePresentationPayload/manifest.json`
- `openspec/changes/ui-presentation/tasks.md`
- `docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md`
- `docs/project/phase0/r5-shared-proof-governance-dispatch-3-2026-06-28.md`

## Gate Evidence

- Gate1: main-side runtime entry gate; UIUE read-only.
- Gate2: Hermes PASS with P0/P1/P2 empty for the UIUE payload fixture consumer.
- Gate3: Hermes FAIL/P1 on untracked fixture packaging; fixed by exact-path staging and local validation only. Audit truth is `hermes_fail_fixed_post_audit`.
- Gate4: Hermes final reconcile PASS. Claude Code final audit PASS with P2 docs nits fixed locally without rerun. GPT Pro PR-pair audit returned `REQUEST_CHANGES`; UIUE-side fixes are recorded as `gptpro_request_changes_fixed_post_audit`, not GPT Pro PASS.
- GPT Pro UIUE-side fixes: PR #6 body changed legacy `V-PASS` wording into explicit historical/non-claim wording; `local_unit` now maps explicitly to `.localMock`; CI self-invalidating live-head check now verifies a dispatch-time 40-hex branch head instead of the transient PR merge ref; private/durable marker rejection is now case/diacritic-insensitive.
- Post-commander blind audit/GPT Pro stale-head cross-check fix: UIUE now decodes the shared refusal safety, runtime error, reconciliation mismatch, and partial-accept/refuse fixtures; `partial_accept_partial_refuse` is mapped to the existing UIUE result kind; proofClass bridging is explicit for every allowed main proof label and has no default downgrade.

## Validation Snapshot

- `swift test --filter 'RuntimePresentationPayloadFixtureConsumerTests|RuntimePresentationConsumerMappingTests'`: PASS, 22 tests.
- Full CI gate: `make verify-ci`: PASS, 345 tests, 3 skipped.
- Post-GPT-Pro targeted regression before this post-commander fixture expansion: `swift test --filter 'RuntimePresentationPayloadFixtureConsumerTests|RuntimePresentationConsumerMappingTests|R5ProofGovernanceStaticChecksTests'`: PASS, 29 tests.
- Post-GPT-Pro marker regression before this post-commander fixture expansion: `swift test --filter 'RuntimePresentationPayloadFixtureConsumerTests|RuntimePresentationConsumerMappingTests'`: PASS, 21 tests.
- Post-commander fixture/proof regression: `swift test --filter 'RuntimePresentationPayloadFixtureConsumerTests|RuntimePresentationConsumerMappingTests'`: PASS, 22 tests.
- `git diff --check` and `git diff --cached --check`: PASS after exact-path staging.
- `openspec validate ui-presentation --strict`: PASS.
- Fixture manifest covers 5 sha256 entries: `ac_power_public_payload`, `refusal_safety_public_payload`, `runtime_error_public_payload`, `reconciliation_mismatch_public_payload`, and `partial_accept_refuse_public_payload`.

## Proof Cap

Proof is limited to local/unit/static/OpenSpec/audit evidence. This receipt does not claim production runtime readiness, mobile, true-device, live API, UIUE merge, V/S/U-PASS, A-2 completion, R5 completion, or voice/model/golden/endpoint readiness.

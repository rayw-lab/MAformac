# R5 D20/D21 Runtime UIUE Integration Main Receipt

Status: pre-push local receipt for `UIUE_R5_D20_D21_RUNTIME_UIUE_INTEGRATION_PR_SUPERTRAIN`.

## Scope

- Main app command entry moved from `DemoWalkingSkeleton` to `DemoRuntimeSessionRunner`.
- App-facing command text now reaches `C3ExecutionPipeline` / runtime adapter / `RuntimePresentationPayload`.
- Main owns deterministic public runtime presentation fixture JSON and manifest under `Tests/Fixtures/RuntimePresentationPayload/`.

## Changed Main Paths

- `App/ContentView.swift`
- `Core/Execution/DemoRuntimeSessionRunner.swift`
- `Core/Execution/DemoActionExecutor.swift`
- `Core/Intent/FastPathIntentEngine.swift`
- `Tests/MAformacCoreTests/DemoRuntimeSessionRunnerTests.swift`
- `Tests/MAformacCoreTests/RuntimePresentationPayloadPublicFixtureTests.swift`
- `Tests/Fixtures/RuntimePresentationPayload/ac_power_public_payload.v1.json`
- `Tests/Fixtures/RuntimePresentationPayload/manifest.json`
- `openspec/changes/define-runtime-adapter-execution/tasks.md`
- `openspec/changes/define-runtime-presentation-bridge/tasks.md`
- `docs/superpowers/plans/2026-06-25-post-c6-backend-training-uiue-roadmap.md`

## Gate Evidence

- Gate1: Hermes PASS; non-blocking P2 default-runner test gap fixed locally without rerun.
- Gate2: UIUE-side gate, main OpenSpec bridge validation PASS.
- Gate3: Hermes FAIL/P1 on untracked fixture packaging; fixed by exact-path staging and local validation only. Audit truth is `hermes_fail_fixed_post_audit`.
- Gate4: final local validation, Hermes final reconcile, Claude Code final audit, push, and GPT Pro PR-pair audit are intentionally not claimed in this pre-push receipt.

## Validation Snapshot

- `swift test --filter 'DemoRuntimeSessionRunnerTests|DemoRuntimeAdapterTests|C3ExecutionPipelineTests|RuntimePresentationBridgeTests|VehicleStateStoreContractTests|RuntimePresentationPayloadPublicFixtureTests'`: PASS, 73 tests.
- `git diff --check` and `git diff --cached --check`: PASS after exact-path staging.
- `openspec validate define-runtime-adapter-execution --strict`: PASS.
- `openspec validate define-runtime-presentation-bridge --strict`: PASS.
- Fixture sha256: `57951e0811bbb75f9a21516df41295ed1619e18ee6d804ac1ef1b21055cdff8f`.

## Proof Cap

Proof is limited to local/unit/integration/static/OpenSpec/GitNexus/audit evidence. This receipt does not claim production runtime readiness, mobile, true-device, live API, UIUE merge, V/S/U-PASS, A-2 completion, R5 completion, or voice/model/golden/endpoint readiness.

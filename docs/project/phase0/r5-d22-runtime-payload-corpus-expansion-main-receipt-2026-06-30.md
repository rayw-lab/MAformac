# R5 D22 Runtime Payload Corpus Expansion Main Receipt

Status: Gate1-Gate4 local closure passed; Hermes gate audits 1-4 passed with P0/P1 empty. First GPT Pro PR-pair audits returned `REQUEST_CHANGES`; owned fixes are applied post-audit and a user-requested post-fix GPT Pro rerun is pending after push.

## Scope

- Main expands the public runtime-presentation payload fixture corpus from the D20/D21 5-fixture set to a 9-fixture set.
- Existing D20/D21 bridge-contract fixtures are preserved and classified as `bridge_contract_fixture`.
- D22 adds local runtime-generated fixtures for window position, screen brightness, ambient brightness, and window already-state/noop coverage.
- Runtime-generated fixtures are produced through local tests using `DemoRuntimeSessionRunner -> C3ExecutionPipeline -> runtime adapter -> C2 readback -> RuntimePresentationPayload` public projection.
- This receipt does not claim production runtime, runtime-ready status, mobile, true-device, live API, UIUE merge, V/S/U-PASS, A-2, R5 complete, voice/model/golden, or endpoint readiness.

## Changed Main Paths

- `Core/Presentation/RuntimePresentationBridge.swift`
- `Tests/MAformacCoreTests/RuntimePresentationBridgeTests.swift`
- `Tests/MAformacCoreTests/RuntimePresentationPayloadPublicFixtureTests.swift`
- `Tests/Fixtures/RuntimePresentationPayload/manifest.json`
- `Tests/Fixtures/RuntimePresentationPayload/window_position_runtime_public_payload.v1.json`
- `Tests/Fixtures/RuntimePresentationPayload/screen_brightness_runtime_public_payload.v1.json`
- `Tests/Fixtures/RuntimePresentationPayload/ambient_brightness_runtime_public_payload.v1.json`
- `Tests/Fixtures/RuntimePresentationPayload/window_position_noop_runtime_public_payload.v1.json`
- `openspec/changes/define-runtime-adapter-execution/tasks.md`
- `openspec/changes/define-runtime-presentation-bridge/tasks.md`
- `docs/project/phase0/r5-d22-runtime-payload-corpus-expansion-main-receipt-2026-06-30.md`

## Gate Evidence

- Gate1: manifest now carries D22 governance metadata for all fixture entries: `caseID`, `fixtureClass`, `result`, `familyCoverage`, and `proofClass`. Existing D20/D21 fixture JSON hashes remain unchanged.
- Gate1 audit: `HERMES_R5_D22_GATE_1_MAIN_RUNTIME_CORPUS_AUTHORITY_AND_GENERATOR_VERDICT: PASS`; P2 carry-forward was to update UIUE manifest decoder/tests in Gate3.
- Gate2: local test generation added accepted multi-family payloads for `window.position`, `screen.brightness`, `ambient.brightness`, plus noop coverage for `window.position` with `already_state_noop` manifest family coverage.
- Gate2 audit: `HERMES_R5_D22_GATE_2_MAIN_MULTI_FAMILY_PAYLOAD_EXECUTION_VERDICT: PASS`; P2 carry-forward was that fixture JSON alone is not standalone runtime provenance. Provenance is the main local generator test plus trace/readback assertions.
- Gate3: UIUE copied the 9-fixture public corpus, asserted manifest metadata, decoded expanded fixtures into `PresentationSnapshot`, and kept proof to local fixture consumer evidence.
- Gate3 audit: `HERMES_R5_D22_GATE_3_UIUE_EXPANDED_CORPUS_CONSUMPTION_VERDICT: PASS`; P2 observation was that noop is currently represented by `accepted_tool_call` plus `familyCoverage: already_state_noop` and revision/readback evidence, not by a UIUE-only result promotion.
- Gate4: docs were cascaded into main receipt/OpenSpec tasks and UIUE receipt/OpenSpec route map under exact staging/no-touch plan.
- Gate4 audit: `HERMES_R5_D22_GATE_4_DOC_CASCADE_PR_RECONCILE_VERDICT: PASS`; P0/P1/P2 empty. This covers doc cascade, dirty split, exact-path staging plan, PR #7/#6 update plan, and proof wording before the post-gate commit/push path.
- Claude Code final audit: skipped by direct user override after Gate4 (`不需要安排claudecode审计了`). D22 closeout must not claim the original six-node audit budget was executed.
- First GPT Pro PR-pair audits: `/Users/wanglei/Downloads/pr_audit_7(5).md` and `/Users/wanglei/Downloads/pr_audit_7(6).md` both returned `GPTPRO_R5_D22_PR_PAIR_AUDIT_VERDICT: REQUEST_CHANGES`.
- GPT Pro P1 fixed post-audit: main now includes `DemoRuntimeResult.partialAcceptPartialRefuse = "partial_accept_partial_refuse"`, `RuntimePresentationTerminalSnapshotAdapter.partialAcceptRefuse` emits that result, bridge tests assert it, and `RuntimePresentationPayloadPublicFixtureTests` decodes all 9 public fixtures through main public vocabulary types so manifest `result` values cannot drift away from typed result enums.
- GPT Pro P2/P1-process handling: PR #6 large historical/reviewability surface will be handled by PR-body whitelist rather than splitting, because D22 operator constraints require updating existing PR #6/#7 only with no new PR and no merge. Runtime-generated proof wording remains limited to accepted/noop local generator fixtures; non-happy fixtures remain `bridge_contract_fixture`.

## Fixture Corpus

| Fixture | Class | Result | Coverage | sha256 |
|---|---|---|---|---|
| `ac_power_public_payload.v1.json` | `bridge_contract_fixture` | `accepted_tool_call` | `ac.power` | `57951e0811bbb75f9a21516df41295ed1619e18ee6d804ac1ef1b21055cdff8f` |
| `refusal_safety_public_payload.v1.json` | `bridge_contract_fixture` | `refusal_safety_or_policy` | `door.lock`, `safety_refusal` | `1e6d704e92d3e4c513e29b42e8184df4e0dbe0dd7b1403319de6d37ecddc2a43` |
| `runtime_error_public_payload.v1.json` | `bridge_contract_fixture` | `runtime_error` | `ac.power`, `runtime_error` | `db65c8c97f11cefdb45d82da90b21a9653056d53f5762fc8a2602c7d50aa889f` |
| `reconciliation_mismatch_public_payload.v1.json` | `bridge_contract_fixture` | `accepted_tool_call` | `ac.power`, `reconciliation_mismatch` | `6baee090729ac3c3db7e5d9041cd186d4a7eb993398aae4b2319cd059688f423` |
| `partial_accept_refuse_public_payload.v1.json` | `bridge_contract_fixture` | `partial_accept_partial_refuse` | `ac.power`, `door.lock`, `partial_accept_partial_refuse` | `4e7de740715634a34c7d5c73ccd94f9161a62e85612b3066cac6dea9aa818649` |
| `window_position_runtime_public_payload.v1.json` | `runtime_generated_fixture` | `accepted_tool_call` | `window.position` | `6705d11f4a9a95bdba4ff40870fca36694efd276460a0461d574cca89abd4bad` |
| `screen_brightness_runtime_public_payload.v1.json` | `runtime_generated_fixture` | `accepted_tool_call` | `screen.brightness` | `353b82b0296de88f50f7df99aeee96b522011eeae52f525c5b91307ff00ad4a2` |
| `ambient_brightness_runtime_public_payload.v1.json` | `runtime_generated_fixture` | `accepted_tool_call` | `ambient.brightness` | `627831b05009ab264a2d948fe6be438bc0169ea291b38d540b14c2fdce867488` |
| `window_position_noop_runtime_public_payload.v1.json` | `runtime_generated_fixture` | `accepted_tool_call` | `window.position`, `already_state_noop` | `ea30e51535fb552da30ca9ca522198b35f69babf804852c0ab40cafb59794112` |

## Validation Snapshot

- `swift test --filter RuntimePresentationPayloadPublicFixtureTests`: PASS, 7 tests after post-GPT-Pro vocabulary regression.
- `swift test --filter 'DemoRuntimeSessionRunnerTests|DemoRuntimeAdapterTests|C3ExecutionPipelineTests|RuntimePresentationBridgeTests|VehicleStateStoreContractTests|RuntimePresentationPayloadPublicFixtureTests'`: PASS, 79 tests.
- Post-GPT-Pro P1 regression: `swift test --filter 'RuntimePresentationBridgeTests|RuntimePresentationPayloadPublicFixtureTests'`: PASS, 25 tests.
- `xcodebuild -scheme MAformacMac -destination 'platform=macOS' build`: PASS.
- `openspec validate define-runtime-adapter-execution --strict`: PASS.
- `openspec validate define-runtime-presentation-bridge --strict`: PASS.
- `openspec validate --all --strict`: PASS, 18/18.
- `git diff --check`: PASS.

## Grill Disposition

D22 does not rewrite or globally close the UIUE 215-row runtime-presentation grill matrix. It changes the D22-relevant disposition only by adding bounded local evidence:

- `implement_now`: main public manifest authority, runtime-generated fixture corpus, UIUE fixture consumer expansion.
- `guard_now`: proof/no-claim ladder, fixture class split, private/durable/raw marker boundary, exact path staging.
- `defer_lane`: human/product review, voice/model/golden/mobile/true-device/live/endpoint lanes.
- `already_covered`: D20/D21 app runtime entry and UIUE base fixture consumer are preserved as prior receipts.
- `out_of_scope`: production runtime readiness, live API, mobile/true-device proof, UIUE merge, V/S/U-PASS, A-2/R5 completion.

## Superpowers And Risk Ledger

- `using-superpowers`: process governance for gate order, audit-node budget, no-touch boundaries, and proof caps; not a proof class.
- `openspec-apply-change`: used for strict local OpenSpec validation and task cascade.
- `gitnexus-impact-analysis` / `gitnexus-cli`: used before symbol/test edits and before commit-stage detect; GitNexus did not override live tests or OpenSpec.
- `bug-iceberg-teardown`: applied to manifest/schema drift, no-op semantics, and proof-class inflation risks.
- `pre-mortem`: local-first check; no web search was used for D22 code because the failure classes were repo-local Swift/JSON fixture contracts rather than external API behavior.
- `hermes-cli-glm52-code`: used for exactly one audit node per gate.
- `gptpro` / `finishing-a-development-branch`: used for the post-commit/push PR-pair audit path. Claude Code final audit is skipped by direct user override, not counted as an executed audit node.

## Lessons Learned

- Public projection is not the same shape as the full runtime DTO. D22 public fixtures intentionally strip volatile `timestamp` fields, so the right regression is a public-vocabulary typed envelope test, not forcing stripped JSON back through a full `RuntimePresentationPayload` decode.
- Manifest strings are contract only when main typed vocabulary and producer adapters can express them. The `partial_accept_partial_refuse` gap existed because manifest/UIUE agreed while main `DemoRuntimeResult` and `partialAcceptRefuse` still spoke refusal-only truth.
- Multiple GPT Pro audits must be merged by finding union, not by assuming identical P0/P1/P2. The second report added PR-level reviewability risk that the first report only treated as metadata drift.
- Exact-path staging and PR-level reviewability are different proof layers. D22 can stage only owned files while PR #6 still needs a PR-body whitelist for historical/report/tooling artifacts already in the long-lived branch.
- GitHub Git Data API push-equivalent can create a remote commit SHA different from a local commit with the same tree/parent/message because the serialized commit object is not byte-identical. For network-blocked pushes, remote PR head/tree verification is the authority; local `@{u}` can be stale if the remote object cannot be fetched.
- First audit truth must remain first audit truth. A `REQUEST_CHANGES` result fixed post-audit is not retroactively a PASS; a later user-requested GPT Pro rerun is a separate post-fix audit node.

## Dirty Split

- `owned_by_D22`: changed runtime bridge, test, fixture, OpenSpec task, and D22 receipt paths listed above.
- `preserve_unowned_dirty`: `AGENTS.md`, `CLAUDE.md`, `docs/CURRENT.md`, `docs/README.md`, `.xcodebuildmcp/`, and `Tools/agent-platform-plugin-refs/`.
- `source_dispatch_trace_artifact`: D20/D21 and D22 dispatch files under `docs/dispatches/`; not staged unless separately authorized.
- `generated_or_report_only`: none staged by D22.
- `no_touch`: preserve-unowned paths above and source dispatch artifacts.

## Proof Cap

Proof is limited to local unit/static/integration/OpenSpec/GitNexus/GitHub-check/audit evidence. D22 does not claim production runtime readiness, runtime-ready status, mobile, true-device, live API, UIUE merge, V/S/U-PASS, A-2 completion, R5 completion, voice/model/golden, or endpoint readiness.

---
artifact_kind: commander_dispatch
label: UIUE_R5_D20_D21_RUNTIME_UIUE_INTEGRATION_PR_SUPERTRAIN
d_range: D20_D21
status: DISPATCH_DRAFT_REQUIRES_CODEX_SUBAGENT_AUDIT_BEFORE_SEND
created_at: 2026-06-29
target_thread: 019f13bc-ce36-7fe2-bc3f-49f703c0a81b
proof_class_ceiling: local_integration + local_unit + local_static + openspec_local + gitnexus_static + hermes_one_pass_or_codex_subagent_fallback + claude_code_final_audit + gptpro_pr_audit
---

# UIUE R5 D20+D21 Runtime/UIUE Integration PR Supertrain Dispatch

## 0. Commander Preamble

Read this file first. Do not rely on chat prose alone.

This is a four-gate supertrain for large-scale coding across two repos:

- main: `/Users/wanglei/workspace/MAformac`
- UIUE: `/Users/wanglei/workspace/MAformac-uiue`

Target execution thread: `019f13bc-ce36-7fe2-bc3f-49f703c0a81b`.

This dispatch does not merge UIUE into main. It does authorize implementation, exact-path commits, pushing the two existing branches to their existing GitHub PRs after final reconciliation, and GPT Pro cloud PR audit after push. It does not authorize merge.

This file must pass a read-only Codex subagent pre-send audit before commander sends it. If the worker receives this dispatch without a commander note saying the pre-send audit passed, stop and ask the commander to provide the audit verdict.

## 1. Live Truth Candidates To Re-Probe

These values were live-verified at dispatch drafting time. They are not immutable. Re-probe before editing and before every push.

| repo | path | branch | HEAD | upstream delta | PR |
|---|---|---|---|---|---|
| main | `/Users/wanglei/workspace/MAformac` | `codex/rebuild-c6-doc-absorption-20260624` | `ae0f3e717d9ebc0bf0be2edab0364f314bb41ef0` | `0 34` from `@{u}...HEAD` | existing draft PR #7, `https://github.com/rayw-lab/MAformac/pull/7` |
| UIUE | `/Users/wanglei/workspace/MAformac-uiue` | `uiue/phase4-default-scope-presentation` | `bde4f783cac1950c4c802fd1133f0d1e934e25f6` | `0 92` from `@{u}...HEAD` | existing PR #6, `https://github.com/rayw-lab/MAformac/pull/6` |

Current dirty split to preserve:

- main preserve-unowned dirty: `AGENTS.md`, `CLAUDE.md`, `docs/CURRENT.md`, `docs/README.md`, `.xcodebuildmcp/`, `Tools/agent-platform-plugin-refs/`.
- UIUE preserve-unowned untracked: existing source dispatch docs D12-D19 under `docs/dispatches/`, plus `docs/research/2026-06-29-visual-acceptance-standard/`.
- This dispatch file is commander-owned: `/Users/wanglei/workspace/MAformac/docs/dispatches/2026-06-29-uiue-r5-d20-d21-runtime-uiue-integration-pr-supertrain-dispatch.md`.
- The D20/D21 route-control update is commander-owned: `/Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md`.

Before editing, run and record:

```bash
git -C /Users/wanglei/workspace/MAformac status --short --branch
git -C /Users/wanglei/workspace/MAformac rev-parse HEAD
git -C /Users/wanglei/workspace/MAformac rev-list --left-right --count @{u}...HEAD
gh -R rayw-lab/MAformac pr view 7 --json number,title,headRefName,baseRefName,state,url,isDraft,mergeStateStatus

git -C /Users/wanglei/workspace/MAformac-uiue status --short --branch
git -C /Users/wanglei/workspace/MAformac-uiue rev-parse HEAD
git -C /Users/wanglei/workspace/MAformac-uiue rev-list --left-right --count @{u}...HEAD
gh -R rayw-lab/MAformac pr view 6 --json number,title,headRefName,baseRefName,state,url,isDraft,mergeStateStatus
```

If branch/PR truth differs, continue only if the new truth still maps to the same two existing PRs. Otherwise stop with `blocked at Gate 0 after repo/PR reconciliation; only missing updated branch/PR authority`.

## 2. Authority And Hard Boundaries

Read first:

1. main `CLAUDE.md`.
2. main `docs/CURRENT.md`.
3. main `docs/README.md`.
4. UIUE `CLAUDE.md`.
5. UIUE `docs/CURRENT.md`.
6. UIUE `docs/README.md`.
7. UIUE `docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md`.
8. main `docs/project/phase0/r5-d18-d19-runtime-durability-uiue-guard-commander-reconcile-2026-06-29.md`.
9. UIUE `docs/project/phase0/r5-d18-d19-runtime-durability-uiue-guard-commander-reconcile-2026-06-29.md`.
10. main `openspec/changes/define-runtime-adapter-execution/`.
11. main `openspec/changes/define-runtime-presentation-bridge/`.
12. UIUE `openspec/changes/ui-presentation/`.

Hard boundaries:

- No UIUE/main merge.
- No new PR. Update existing PR #7 and #6 only.
- No `git add .`.
- No revert, clean, or overwrite preserve-unowned dirty.
- No staging existing untracked UIUE D12-D19 source dispatch files.
- No staging `Reports/` unless a gate explicitly says a report artifact is tracked. Default is ignored/report-only.
- No C5/C6 model-quality lane, LoRA training, candidate comparison, golden-run, voice, mobile, true-device, live API, endpoint readiness, V/S/U-PASS, A-2, or R5 complete claim.
- No UIUE consumption of main private or durable names.
- No local/unit/fixture/simulator proof promoted into production runtime, mobile, true-device, live, merge, or readiness proof.

## 2A. Using-Superpowers Execution Chain

Use the `using-superpowers` chain to drive the whole supertrain, but do not let it override the user's explicit instructions, repo authority, OpenSpec, GitNexus, dirty-tree boundaries, or the six-node audit budget.

At task start:

1. Invoke/use `using-superpowers` before implementation work.
2. Re-check applicable skills before each gate and before each materially different branch of work.
3. In Codex, map skill actions to Codex-native equivalents: shell for read/search/run, `apply_patch` for edits, `update_plan` for task tracking, subagents only for bounded independent review/verification slices, and exact-path git commands for staging/commits.
4. Record in the gate receipt which skills were used, why they applied, which obvious skills were intentionally skipped, and what repo evidence constrained them.

Minimum expected skill routing:

- OpenSpec changes or spec truth: use the relevant `openspec-*` skill before editing OpenSpec files.
- GitNexus impact/change analysis: use `gitnexus-*` guidance before symbol edits and before commits.
- Bugs, validation failures, audit findings, retry/idempotency ambiguity, or proof drift: use `bug-iceberg-teardown` or equivalent iceberg teardown discipline.
- PR push/finish work: use GitHub/branch finishing guidance compatible with the exact existing PR #7/#6 rule.
- GPT Pro PR audit: use `$gptpro` / GPT Pro automation guidance exactly once for the combined PR-pair audit node.

Do not claim "using-superpowers complete" as a proof class. It is process governance only. The final YAML must include a `superpowers_chain` ledger with skills used and any conflict resolution.

## 3. Secondary Teardown-Cite Absorption

Hermes's supplemental critique is accepted only after these local cites and adjustments:

| issue | local cite | absorbed rule |
|---|---|---|
| App user path still runs old skeleton. | main `App/ContentView.swift:65-76` constructs `DemoWalkingSkeleton`; `Features/VehicleControl/DemoWalkingSkeleton.swift:29-46` decodes via `FastPathIntentEngine` and applies `DemoActionExecutor.applyMockTransition`. | D20 must physically replace the app command entry with a new main-owned runtime session/controller path. A sidecar harness is insufficient. |
| C3/adapter path exists and must become the app path. | main `Core/Execution/C3ExecutionPipeline.swift:259-280` supports local durable ledger injection; `:282-384` runs semantic/allowlist/risk checks, runtime adapter execution, C2 readback verification, and settled-plan recording. | D20 must execute through `C3ExecutionPipeline.execute` and emit `RuntimePresentationPayload`. |
| UIUE already has names/guards but not a real payload adapter. | UIUE `Core/Presentation/RuntimePresentationConsumerMapping.swift:38-63` defines payload schema/fields; `:112-130` denies private/durable names; `:149-153` proof caps. `PresentationSnapshot.swift:59-99` is the frontstage state container. `App/ContentView.swift:50-68` renders from snapshot. | D21 must add a UIUE-local JSON fixture consumer that maps presentation-safe payload JSON into `PresentationSnapshot`; it must not import main Swift private types. |
| PR push is high-blast-radius because both branches are far ahead and already have PRs. | main PR #7 and UIUE PR #6 are open; live local ahead counts were main `0 34`, UIUE `0 92`; dirty splits exist. | Gate 4 must run dirty/ahead/open-PR reconciliation before push; no new PR; no merge; exact pathspec commits only. |

One correction to Hermes wording: main should not import or expose UIUE's `PresentationSnapshot`. If main needs an intermediate object, keep it main-owned and subordinate to `RuntimePresentationPayload`.

## 4. Topology

Strict serial topology, four long gates:

1. `D20_GATE_1_MAIN_APP_RUNTIME_ENTRY`
2. `D21_GATE_2_UIUE_PAYLOAD_FIXTURE_CONSUMER`
3. `D20_D21_GATE_3_CROSS_REPO_FIXTURE_CONTRACT`
4. `D20_D21_GATE_4_FINAL_AUDIT_PR_PUSH_GPTPRO`

Execution audit-node budget is exactly six:

| node | auditor | scope | rerun policy |
|---:|---|---|---|
| 1 | Hermes preferred; Codex subagent fallback only if Hermes unavailable | Gate 1 | one pass only; no rerun |
| 2 | Hermes preferred; Codex subagent fallback only if Hermes unavailable | Gate 2 | one pass only; no rerun |
| 3 | Hermes preferred; Codex subagent fallback only if Hermes unavailable | Gate 3 | one pass only; no rerun |
| 4 | Hermes preferred; Codex subagent fallback only if Hermes unavailable | Gate 4 | one pass only; no rerun |
| 5 | Claude Code | full train after Gate 4 | one pass only; no rerun inside this dispatch |
| 6 | GPT Pro | cloud audit of existing PR #7 and PR #6 after push | one combined PR-pair audit only; no rerun inside this dispatch |

The commander pre-send Codex subagent audit for this dispatch file is outside the execution audit-node budget.

Each gate gets exactly one gate audit node after local validation. Default engine is Hermes. If Hermes is unavailable after a concrete self-check, use one read-only Codex subagent audit as the fallback for that same node. The fallback consumes the same audit-node slot; it does not create a seventh node and does not authorize a later Hermes rerun for the same gate. Record the actual engine as `hermes` or `codex_subagent_fallback`. If the gate audit finds issues, fix owned issues, rerun local validation/static checks, and record the gate as `hermes_fail_fixed_post_audit` or `codex_subagent_fail_fixed_post_audit`. If the fix cannot be proven locally or the finding is a boundary violation, stop as `blocked`.

After all four gates, run one full-range Claude Code adversarial audit. If Claude Code returns P0/P1/train-blocking findings, fix owned issues and rerun local validation/static checks, but do not rerun Claude Code inside this dispatch. Record the final status as `claude_code_fail_fixed_post_audit` when applicable, not Claude Code PASS. Any extra audit would require a separate commander dispatch outside this supertrain.

After final local/Claude closure and exact-path commits, push existing branches to update PR #7 and PR #6, then run one combined GPT Pro cloud PR-pair audit with a 20-minute watcher cap. If GPT Pro reports P0/P1/train-blocking issues, fix, validate, commit, and push again, but do not rerun GPT Pro inside this dispatch. Record the final status as `gptpro_fail_fixed_post_audit` when applicable, not GPT Pro PASS. Any extra GPT Pro audit would require a separate commander dispatch outside this supertrain.

## 5. Required Harness For Every Gate

Every gate receipt must include:

- using-superpowers ledger: skills used, why, skipped skills, conflicts, and repo evidence that constrained them;
- lessons learned / metacognitive reflection;
- pre-mortem;
- local repo search for same-class evidence;
- web cross-search for current external pitfalls when the issue is not purely local;
- iceberg teardown: visible symptom, underlying class, same-class risk map, immediate fix, class-level fix, governance fix;
- goal-drift check;
- authority check;
- claim-vs-proof check;
- boundary check;
- self-question: "If this were wrong, what file/line/command would prove it?";
- post-audit correction rule.

Trigger local/web cross-search plus iceberg teardown whenever any of these appear:

- validation failure;
- GitNexus HIGH/CRITICAL or stale index;
- Hermes, Codex subagent fallback, Claude Code, or GPT Pro finding;
- dirty split mismatch;
- staged path mismatch;
- evidence conflict;
- retry/idempotency ambiguity;
- readback ambiguity;
- SwiftUI state/presentation mismatch;
- strict JSON decode / unknown-key ambiguity;
- pressure to invent shared fields;
- PR/GitHub/gh/GPT Pro automation surprise.

For unfamiliar Swift/SwiftUI/GitHub/ChatGPT-automation behavior, use local docs first, then web search or official docs/issues. Record source URLs and captured_at. Do not cite memory or model recall as proof.

## 6. Gate 1 - D20 Main App Runtime Entry

Label: `D20_GATE_1_MAIN_APP_RUNTIME_ENTRY`

Repo: main only, `/Users/wanglei/workspace/MAformac`.

Goal:

Replace the app's user-facing command execution path so it no longer executes through `DemoWalkingSkeleton -> DemoActionExecutor.applyMockTransition`. The app command path must route:

```text
text input -> ToolCallFrame -> C3ExecutionPipeline.execute -> runtime adapter/C2 readback -> RuntimePresentationPayload
```

Expected implementation direction:

- Add a main-owned `DemoRuntimeSessionRunner`, `RuntimeInteractionController`, or similarly named runtime entry surface.
- Reuse existing decode components only as text-to-`ToolCallFrame` adapters if they produce valid current `ToolCallFrame`.
- Use `C3ExecutionPipeline.execute` for execution.
- Emit sanitized `RuntimePresentationPayload` with stable schema `r5_runtime_presentation_payload_v1`.
- Update `App/ContentView.swift` so `runCommand()` depends only on the new runtime entry surface, not direct `DemoWalkingSkeleton`.
- Keep old `DemoWalkingSkeleton` only as legacy/test helper if needed, but not as the app entry.
- Do not import UIUE Swift code or UIUE `PresentationSnapshot` into main.

Likely writable paths:

- `/Users/wanglei/workspace/MAformac/Core/Execution/`
- `/Users/wanglei/workspace/MAformac/Core/Presentation/`
- `/Users/wanglei/workspace/MAformac/App/ContentView.swift`
- `/Users/wanglei/workspace/MAformac/App/MAformacApp.swift`
- `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/`
- main OpenSpec files only if behavior must be clarified before implementation.
- main gate receipt under `/Users/wanglei/workspace/MAformac/docs/project/phase0/`.

No-touch:

- main preserve-unowned dirty listed in section 1.
- UIUE repo.
- C5/C6/model/voice/golden/mobile/true-device files.

Before editing any symbol:

- Run GitNexus impact/context for the symbol(s) to be modified, especially `ContentView.runCommand`, `C3ExecutionPipeline`, `RuntimePresentationPayload`, and any new runtime entry integration points.
- If GitNexus returns HIGH/CRITICAL, stop and report before editing unless the finding is only docs/unindexed noise and you can justify it with local evidence.

Required validation:

```bash
git -C /Users/wanglei/workspace/MAformac diff --check
cd /Users/wanglei/workspace/MAformac && swift test --filter 'DemoRuntimeSessionRunnerTests|RuntimePresentationBridgeTests|C3ExecutionPipelineTests|VehicleStateStoreContractTests'
cd /Users/wanglei/workspace/MAformac && openspec validate define-runtime-adapter-execution --strict
cd /Users/wanglei/workspace/MAformac && openspec validate define-runtime-presentation-bridge --strict
cd /Users/wanglei/workspace/MAformac && openspec validate --all --strict
```

Gate-specific assertions:

- `App/ContentView.swift` no longer constructs `DemoWalkingSkeleton` in `runCommand()`.
- A targeted test proves command text reaches `C3ExecutionPipeline.execute`.
- A targeted test proves the resulting payload is presentation-safe and redacts private/durable markers.
- A targeted test proves `C005`/`C061` local durable replay/readback behavior still passes under the new app-facing entry.

Gate audit:

- Run one Hermes deep audit over Gate 1 changes after local validation.
- If Hermes is unavailable after concrete self-check, run one read-only Codex subagent fallback audit for Gate 1 instead.
- Required anchor: `HERMES_R5_D20_GATE_1_MAIN_APP_RUNTIME_ENTRY_VERDICT: PASS|FAIL` or `CODEX_SUBAGENT_R5_D20_GATE_1_MAIN_APP_RUNTIME_ENTRY_VERDICT: PASS|FAIL`.
- If FAIL/P0/P1/P2, fix locally, rerun local validation only, and record `hermes_fail_fixed_post_audit` or `codex_subagent_fail_fixed_post_audit` unless unfixable.

Brief verdict label:

`D20_GATE_1_MAIN_APP_RUNTIME_ENTRY brief`

## 7. Gate 2 - D21 UIUE Payload Fixture Consumer

Label: `D21_GATE_2_UIUE_PAYLOAD_FIXTURE_CONSUMER`

Repo: UIUE only, `/Users/wanglei/workspace/MAformac-uiue`.

Goal:

Add a UIUE-local presentation-safe JSON consumer that maps a D15/D20 `RuntimePresentationPayload` JSON fixture into UIUE `PresentationSnapshot`.

Expected implementation direction:

- Add `RuntimePresentationPayloadFixtureConsumer` or equivalent under UIUE `Core/Presentation/`.
- Define UIUE-local Codable mirror structs only for presentation-safe payload fields. Do not import main Swift types.
- Accept only `schemaVersion`, `traceID`, `turnID`, `eventID`, `isTerminal`, `outcome`, `proofClass`, `cards`, `cardSemantics`, `readbacks`, `reconciliation`, and `traceEnvelope`.
- Reject unknown envelope/content fields, unknown enum values, unknown proof class, and any forbidden private/durable marker from `RuntimePresentationConsumerMapping.forbiddenPrivateNames`.
- Map valid payloads into `PresentationSnapshot` fields: `traceId`, `storeCells`, `activeCells`, `refusedCell`, `scopeOrigins`, `orbState`, `voiceState`, `dialogText`, `readbacks`, `resultKind`, `proofClass`.
- Optional UI debug/sample wiring may exist only behind local/simulator/debug flags and must not be described as runtime/mobile/live proof.

Likely writable paths:

- `/Users/wanglei/workspace/MAformac-uiue/Core/Presentation/`
- `/Users/wanglei/workspace/MAformac-uiue/App/ContentView.swift` only if debug/sample consumer entry is needed.
- `/Users/wanglei/workspace/MAformac-uiue/Tests/MAformacCoreTests/`
- `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/` if the consumer behavior needs task/spec cascade.
- UIUE gate receipt under `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/`.

No-touch:

- existing UIUE source dispatch docs D12-D19 unless exact current gate owns a new D20/D21 dispatch/receipt path.
- `/Users/wanglei/workspace/MAformac-uiue/docs/research/2026-06-29-visual-acceptance-standard/`.
- main repo except read-only OpenSpec validation.
- UIUE visual L3, true-device, voice, model, golden, endpoint, merge lanes.

Required validation:

```bash
git -C /Users/wanglei/workspace/MAformac-uiue diff --check
cd /Users/wanglei/workspace/MAformac-uiue && swift test --filter 'RuntimePresentationPayloadFixtureConsumerTests|RuntimePresentationConsumerMappingTests'
cd /Users/wanglei/workspace/MAformac-uiue && openspec validate ui-presentation --strict
cd /Users/wanglei/workspace/MAformac && openspec validate define-runtime-presentation-bridge --strict
```

Gate-specific assertions:

- A valid public payload fixture maps to `PresentationSnapshot`.
- Unknown top-level fields fail closed.
- Unknown nested payload fields fail closed where the consumer owns decoding.
- Unknown schema/proof/outcome/reconciliation values fail closed.
- Forbidden terms such as `DemoRuntimeAdapter`, `RuntimeAdapterBox`, `durableLedger`, `persistentLedger`, `adapterLedger`, `local_durable_adapter_ledger`, `requestFingerprint`, `parentRequestFingerprint`, `failureLedger`, `successLedger`, `settledParentPlan`, `runtimeStore`, `rawRuntimeStore`, `rawModelOutput`, `trainingReceipt`, and `DemoForceStateContext` fail closed.
- These names do not become `payloadFieldNames`, `d15ProofClassNames`, or `proofCaps`.

Gate audit:

- Run one Hermes deep audit over Gate 2 changes after local validation.
- If Hermes is unavailable after concrete self-check, run one read-only Codex subagent fallback audit for Gate 2 instead.
- Required anchor: `HERMES_R5_D21_GATE_2_UIUE_PAYLOAD_FIXTURE_CONSUMER_VERDICT: PASS|FAIL` or `CODEX_SUBAGENT_R5_D21_GATE_2_UIUE_PAYLOAD_FIXTURE_CONSUMER_VERDICT: PASS|FAIL`.
- If FAIL/P0/P1/P2, fix locally, rerun local validation only, and record `hermes_fail_fixed_post_audit` or `codex_subagent_fail_fixed_post_audit` unless unfixable.

Brief verdict label:

`D21_GATE_2_UIUE_PAYLOAD_FIXTURE_CONSUMER brief`

## 8. Gate 3 - Cross-Repo Fixture Contract

Label: `D20_D21_GATE_3_CROSS_REPO_FIXTURE_CONTRACT`

Repos: main + UIUE, no merge.

Goal:

Create a stable cross-repo fixture contract proving that main can produce a sanitized public runtime presentation payload and UIUE can consume the same public JSON shape into `PresentationSnapshot`.

Expected implementation direction:

- In main, add deterministic fixture generation or committed public JSON fixture(s) under a test fixture path such as `Tests/Fixtures/RuntimePresentationPayload/`.
- In UIUE, add matching fixture(s) or fixture-copy receipt with source commit/hash.
- Record sha256 for each public fixture.
- Add tests on both repos:
  - main encodes sanitized payload fixture(s);
  - UIUE decodes the fixture(s) and maps expected snapshot state;
  - private/durable marker grep is zero.
- Keep the fixture public and presentation-safe. Do not include adapter ledger contents, request fingerprints, parent fingerprints, failure/success ledger, settled parent plan internals, raw runtime store, raw model output, or training receipts.

Likely writable paths:

- main `Tests/Fixtures/RuntimePresentationPayload/`
- main `Tests/MAformacCoreTests/`
- main receipt under `docs/project/phase0/`
- UIUE `Tests/Fixtures/RuntimePresentationPayload/` or equivalent test fixture path
- UIUE `Tests/MAformacCoreTests/`
- UIUE receipt under `docs/project/phase0/`
- UIUE route-control/doc cascade files if status changes.

Required validation:

```bash
git -C /Users/wanglei/workspace/MAformac diff --check
git -C /Users/wanglei/workspace/MAformac-uiue diff --check
cd /Users/wanglei/workspace/MAformac && swift test --filter 'DemoRuntimeSessionRunnerTests|RuntimePresentationBridgeTests|C3ExecutionPipelineTests'
cd /Users/wanglei/workspace/MAformac-uiue && swift test --filter 'RuntimePresentationPayloadFixtureConsumerTests|RuntimePresentationConsumerMappingTests'
cd /Users/wanglei/workspace/MAformac && openspec validate define-runtime-presentation-bridge --strict
cd /Users/wanglei/workspace/MAformac && openspec validate define-runtime-adapter-execution --strict
cd /Users/wanglei/workspace/MAformac-uiue && openspec validate ui-presentation --strict
```

Private marker scan:

```bash
rg -n 'DemoRuntimeAdapter|RuntimeAdapterBox|durableLedger|persistentLedger|adapterLedger|local_durable_adapter_ledger|requestFingerprint|parentRequestFingerprint|failureLedger|successLedger|settledParentPlan|runtimeStore|rawRuntimeStore|rawModelOutput|trainingReceipt|DemoForceStateContext' \
  /Users/wanglei/workspace/MAformac/Tests/Fixtures \
  /Users/wanglei/workspace/MAformac-uiue/Tests/Fixtures
```

Expected result: no hits, unless the test is an explicitly named negative fixture under UIUE fail-closed tests. Negative fixtures must not be used as public contract fixtures.

Gate audit:

- Run one Hermes deep audit over Gate 3 cross-repo fixture contract after local validation.
- If Hermes is unavailable after concrete self-check, run one read-only Codex subagent fallback audit for Gate 3 instead.
- Required anchor: `HERMES_R5_D20_D21_GATE_3_CROSS_REPO_FIXTURE_CONTRACT_VERDICT: PASS|FAIL` or `CODEX_SUBAGENT_R5_D20_D21_GATE_3_CROSS_REPO_FIXTURE_CONTRACT_VERDICT: PASS|FAIL`.
- If FAIL/P0/P1/P2, fix locally, rerun local validation only, and record `hermes_fail_fixed_post_audit` or `codex_subagent_fail_fixed_post_audit` unless unfixable.

Brief verdict label:

`D20_D21_GATE_3_CROSS_REPO_FIXTURE_CONTRACT brief`

## 9. Gate 4 - Final Audit, PR Push, GPT Pro Audit

Label: `D20_D21_GATE_4_FINAL_AUDIT_PR_PUSH_GPTPRO`

Repos: main + UIUE.

Goal:

Reconcile code/docs/receipts, run final local validation, run Gate 4 Hermes once, run full-train Claude Code audit after all four gates, then update existing PR #7 and PR #6, run GPT Pro cloud PR audit, fix findings, commit, and push again if needed.

Document cascade requirements:

- Update UIUE living route-control map:
  - `/Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md`
- Update main parent route note if D20/D21 supersedes older "backend after model/C6" wording:
  - `/Users/wanglei/workspace/MAformac/docs/superpowers/plans/2026-06-25-post-c6-backend-training-uiue-roadmap.md`
- Update D20/D21 receipts under both repos.
- Update OpenSpec task files touched by implementation:
  - main `openspec/changes/define-runtime-adapter-execution/tasks.md`
  - main `openspec/changes/define-runtime-presentation-bridge/tasks.md`
  - UIUE `openspec/changes/ui-presentation/tasks.md`
- Update burndown/dispatch-plan artifacts only when they already contain D20/D21-relevant rows. Do not change artifact type to force an update.
- Grep for stale `D20/D21 pending`, `Gate4 pending`, false `Hermes PASS`, false `Codex PASS`, `runtime-ready`, `mobile`, `true-device`, `live`, `UIUE merge`, `V-PASS`, `S-PASS`, `U-PASS`, `A-2`, `R5 complete`.

Gate 4 local validation before Hermes:

```bash
git -C /Users/wanglei/workspace/MAformac diff --check
git -C /Users/wanglei/workspace/MAformac-uiue diff --check
cd /Users/wanglei/workspace/MAformac && swift test --filter 'DemoRuntimeSessionRunnerTests|DemoRuntimeAdapterTests|C3ExecutionPipelineTests|RuntimePresentationBridgeTests|VehicleStateStoreContractTests'
cd /Users/wanglei/workspace/MAformac-uiue && swift test --filter 'RuntimePresentationPayloadFixtureConsumerTests|RuntimePresentationConsumerMappingTests'
cd /Users/wanglei/workspace/MAformac && openspec validate define-runtime-adapter-execution --strict
cd /Users/wanglei/workspace/MAformac && openspec validate define-runtime-presentation-bridge --strict
cd /Users/wanglei/workspace/MAformac && openspec validate --all --strict
cd /Users/wanglei/workspace/MAformac-uiue && openspec validate ui-presentation --strict
```

Gate audit:

- Run one Hermes deep audit over Gate 4 final reconcile before Claude Code.
- If Hermes is unavailable after concrete self-check, run one read-only Codex subagent fallback audit for Gate 4 instead.
- Required anchor: `HERMES_R5_D20_D21_GATE_4_FINAL_RECONCILE_VERDICT: PASS|FAIL` or `CODEX_SUBAGENT_R5_D20_D21_GATE_4_FINAL_RECONCILE_VERDICT: PASS|FAIL`.
- If FAIL/P0/P1/P2, fix locally, rerun local validation only, and record `hermes_fail_fixed_post_audit` or `codex_subagent_fail_fixed_post_audit` unless unfixable.

Full-train Claude Code final audit:

- Scope: Gate 1 through Gate 4, both repos, all commits, all receipts, all post-Hermes fixes, route-control and document cascade, dirty split, PR reconciliation, proof wording, and consumer-boundary violations.
- Required anchor: `CLAUDE_CODE_R5_D20_D21_FINAL_FULL_TRAIN_AUDIT_VERDICT: PASS|FAIL`.
- Run exactly one Claude Code final audit pass under the six-node audit budget.
- P0/P1/train-blocking findings require fix and fresh local validation/static checks. Continue only as `claude_code_fail_fixed_post_audit`; do not rewrite the audit as PASS.
- P2 may be fixed with local validation and recorded residual risk.
- Do not rerun Claude Code inside this dispatch. Any extra audit requires a separate commander dispatch outside this supertrain.

Exact-path staging and commits:

- Use `git add -- <exact paths>` only.
- Run `git diff --cached --check` before every commit.
- Run GitNexus `detect_changes` on staged or all owned changes before every commit.
- Commit main-owned changes in main.
- Commit UIUE-owned changes in UIUE.
- Do not stage preserve-unowned dirty, existing UIUE source dispatch docs, unrelated research, or `Reports/` by default.

PR reconciliation before push:

```bash
git -C /Users/wanglei/workspace/MAformac status --short --branch
git -C /Users/wanglei/workspace/MAformac rev-list --left-right --count @{u}...HEAD
gh -R rayw-lab/MAformac pr view 7 --json number,title,headRefName,baseRefName,state,url,isDraft,mergeStateStatus

git -C /Users/wanglei/workspace/MAformac-uiue status --short --branch
git -C /Users/wanglei/workspace/MAformac-uiue rev-list --left-right --count @{u}...HEAD
gh -R rayw-lab/MAformac pr view 6 --json number,title,headRefName,baseRefName,state,url,isDraft,mergeStateStatus
```

Push rule:

- Push current main branch to update PR #7 only after all prior gates are satisfied.
- Push current UIUE branch to update PR #6 only after all prior gates are satisfied.
- Do not create a new PR.
- Do not merge either PR.
- If push fails for credentials, network, branch protection, non-fast-forward, or changed remote state, stop and report `blocked at Gate 4 after PR push reconciliation; only missing <minimal blocker>`.

GPT Pro PR audit after push:

Prerequisite:

```bash
curl -sf http://127.0.0.1:9222/json/version >/dev/null && echo "CDP alive" || echo "CDP down"
```

If CDP is down:

```bash
bash /Users/wanglei/workspace/tools/chatgpt-automation-mcp/start-chrome-automation.sh
```

Run exactly one GPT Pro audit node after both PRs are pushed. The GPT Pro prompt must audit the PR pair together: existing main PR #7 as producer/runtime-entry PR and existing UIUE PR #6 as consumer/fixture PR. Do not run separate main/UIUE GPT Pro audits inside this dispatch.

Combined PR-pair audit:

```bash
cd /Users/wanglei/workspace/tools/chatgpt-automation-mcp && \
  uv run python audit_pr.py "https://github.com/rayw-lab/MAformac/pull/7" \
    --extra-instruction "Primary task: audit the R5 D20/D21 PR pair as one system. Primary PR: https://github.com/rayw-lab/MAformac/pull/7. Companion PR: https://github.com/rayw-lab/MAformac/pull/6. Check that main App/ContentView no longer executes through DemoWalkingSkeleton, C3ExecutionPipeline/RuntimePresentationPayload is the app path, UIUE consumes only presentation-safe JSON fixtures into PresentationSnapshot, UIUE does not import main private Swift types or durable/runtime internals, private/durable markers are redacted or fail-closed, proof classes are not promoted, existing PR #7/#6 remain separate branches, no new PR/merge/runtime/mobile/live/V/S/U/A-2/R5-complete claim is made. This is one combined GPT Pro audit node; do not split the review into separate audit requests." && \
  nohup uv run python /Users/wanglei/workspace/tools/chatgpt-automation-mcp/watch_and_download.py \
    --max-wait 1200 --min-text-len 2000 --stable-cycles 4 \
    > /tmp/r5-d20-d21-pr-pair-gptpro-watch-$(date +%Y%m%d-%H%M%S).log 2>&1 &
```

GPT Pro completion discipline:

- Watcher logs are not enough if the result is short or ambiguous.
- Before any retry/follow-up/re-dispatch, confirm the ChatGPT page is not still generating via screenshot or equivalent visible-state proof.
- Record output directory and downloaded `pr_audit_*.md` or message files.
- If GPT Pro returns P0/P1/train-blocking findings, fix, validate, exact-path commit, and push again. Continue only as `gptpro_fail_fixed_post_audit`; do not rewrite the audit as PASS.
- Do not rerun GPT Pro inside this dispatch. Any extra GPT Pro audit requires a separate commander dispatch outside this supertrain.
- If GPT Pro tool/browser/session fails after self-recovery attempts, stop as `PARTIAL/BLOCKED`; do not replace GPT Pro with Hermes in this dispatch.

Brief verdict label:

`D20_D21_GATE_4_FINAL_AUDIT_PR_PUSH_GPTPRO brief`

## 10. Expected Final YAML

The final verdict must be a YAML block with at least:

```yaml
label: UIUE_R5_D20_D21_RUNTIME_UIUE_INTEGRATION_PR_SUPERTRAIN
status: DONE|PARTIAL|BLOCKED|DONE_UNDER_PROOF_CAP_WITH_AUDIT_FAIL_FIXED_POST_AUDIT
completed_at: 2026-06-29
repo_truth:
  main:
    path: /Users/wanglei/workspace/MAformac
    branch: <branch>
    head: <sha>
    upstream_delta: <left_right_count>
    cached: <empty_or_paths>
    dirty_preserved:
      - AGENTS.md
      - CLAUDE.md
      - docs/CURRENT.md
      - docs/README.md
      - .xcodebuildmcp/
      - Tools/agent-platform-plugin-refs/
    pr: https://github.com/rayw-lab/MAformac/pull/7
  uiue:
    path: /Users/wanglei/workspace/MAformac-uiue
    branch: <branch>
    head: <sha>
    upstream_delta: <left_right_count>
    cached: <empty_or_paths>
    dirty_preserved:
      - docs/dispatches/2026-06-29-uiue-r5-d12-runtime-adapter-v0-code-train-dispatch.md
      - docs/dispatches/2026-06-29-uiue-r5-d13-c3-runtime-adapter-integration-dispatch.md
      - docs/dispatches/2026-06-29-uiue-r5-d14-runtime-adapter-residual-train-dispatch.md
      - docs/dispatches/2026-06-29-uiue-r5-d15-runtime-presentation-payload-contract-dispatch.md
      - docs/dispatches/2026-06-29-uiue-r5-d16-d17-core-config-force-state-uiue-consumer-supertrain-dispatch.md
      - docs/dispatches/2026-06-29-uiue-r5-d18-d19-runtime-durability-uiue-guard-dispatch.md
      - docs/research/2026-06-29-visual-acceptance-standard/
    pr: https://github.com/rayw-lab/MAformac/pull/6
commits:
  main: []
  uiue: []
changed_paths:
  main: []
  uiue: []
gate_results:
  gate1:
    status: <DONE|...>
    gate_audit_engine: <hermes|codex_subagent_fallback>
    gate_audit_anchor: <HERMES_or_CODEX_SUBAGENT_anchor>
    audit_truth: <audit_pass|hermes_fail_fixed_post_audit|codex_subagent_fail_fixed_post_audit|blocked>
  gate2:
    status: <DONE|...>
    gate_audit_engine: <hermes|codex_subagent_fallback>
    gate_audit_anchor: <HERMES_or_CODEX_SUBAGENT_anchor>
    audit_truth: <audit_pass|hermes_fail_fixed_post_audit|codex_subagent_fail_fixed_post_audit|blocked>
  gate3:
    status: <DONE|...>
    gate_audit_engine: <hermes|codex_subagent_fallback>
    gate_audit_anchor: <HERMES_or_CODEX_SUBAGENT_anchor>
    audit_truth: <audit_pass|hermes_fail_fixed_post_audit|codex_subagent_fail_fixed_post_audit|blocked>
  gate4:
    status: <DONE|...>
    gate_audit_engine: <hermes|codex_subagent_fallback>
    gate_audit_anchor: <HERMES_or_CODEX_SUBAGENT_anchor>
    audit_truth: <audit_pass|hermes_fail_fixed_post_audit|codex_subagent_fail_fixed_post_audit|blocked>
    claude_code_anchor: <anchor>
    gptpro_audit:
      pr_pair: <PASS|FAIL|BLOCKED|not_run>
      primary_pr: https://github.com/rayw-lab/MAformac/pull/7
      companion_pr: https://github.com/rayw-lab/MAformac/pull/6
      audit_truth: <audit_pass|gptpro_fail_fixed_post_audit|blocked>
superpowers_chain:
  used_skills: []
  skipped_obvious_skills: []
  conflict_resolution: []
validation:
  main:
    git_diff_check: <PASS|FAIL|not_run>
    git_diff_cached_check: <PASS|FAIL|not_run>
    swift_targeted: <PASS|FAIL|not_run>
    openspec_define_runtime_adapter_execution_strict: <PASS|FAIL|not_run>
    openspec_define_runtime_presentation_bridge_strict: <PASS|FAIL|not_run>
    openspec_all_strict: <PASS|FAIL|not_run>
    gitnexus_detect_changes: <low|medium|high|critical|not_run>
  uiue:
    git_diff_check: <PASS|FAIL|not_run>
    git_diff_cached_check: <PASS|FAIL|not_run>
    swift_targeted: <PASS|FAIL|not_run>
    openspec_ui_presentation_strict: <PASS|FAIL|not_run>
    gitnexus_detect_changes: <low|medium|high|critical|not_run>
proof_class:
  maximum: local_integration + local_unit + local_static + openspec_local + gitnexus_static + hermes_one_pass_or_codex_subagent_fallback + claude_code_final_audit + gptpro_pr_audit
  non_claims:
    - no production durable runtime proof
    - no runtime-ready claim
    - no mobile proof
    - no true-device proof
    - no live API proof
    - no UIUE merge
    - no V-PASS
    - no S-PASS
    - no U-PASS
    - no A-2 readiness or completion
    - no R5 complete
    - no voice/model/golden/endpoint readiness
residual_risks: []
no_new_pr: true
no_merge: true
source_dispatch_staged: false
exact_pathspec_staging: true
```

## 11. Stop Conditions

Stop immediately if:

- live repo truth no longer matches existing PR #7/#6 and there is no updated commander authority;
- `ContentView` cannot be moved off `DemoWalkingSkeleton` without larger product decisions;
- UIUE consumer requires main private/durable types to pass tests;
- public fixture needs private runtime/durable fields to be useful;
- Hermes/Claude/GPT Pro reports an unfixable P0/P1 or boundary violation;
- GitNexus reports HIGH/CRITICAL and the blast radius cannot be narrowed;
- push would require new PR, force-push, merge, branch rewrite, or staging no-touch paths;
- GPT Pro cannot be run after push.

Blocked wording must be precise:

`blocked at Gate N after attempts A/B/C; only missing X`

Do not use generic "environment incomplete" wording.

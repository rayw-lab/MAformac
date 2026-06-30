---
artifact_kind: commander_dispatch
label: UIUE_R5_D22_RUNTIME_PAYLOAD_CORPUS_EXPANSION_SUPERTRAIN
d_range: D22
status: DISPATCH_DRAFT_REQUIRES_CODEX_SUBAGENT_AUDIT_BEFORE_SEND
created_at: 2026-06-30
target_thread: 019f13bc-ce36-7fe2-bc3f-49f703c0a81b
commander_receipt_target: commander_current_thread
proof_class_ceiling: local_integration + local_unit + local_static + openspec_local + gitnexus_static + github_check + hermes_one_pass_or_codex_subagent_fallback + claude_code_final_audit + gptpro_pr_audit
---

# UIUE R5 D22 Runtime Payload Corpus Expansion Supertrain Dispatch

## 0. Commander Preamble

Read this file first. Do not rely on chat prose alone.

This is a four-gate D22 supertrain for expanding the D20/D21 runtime-presentation bridge from a single-command happy path into a multi-case public payload corpus across two repos:

- main: `/Users/wanglei/workspace/MAformac`
- UIUE: `/Users/wanglei/workspace/MAformac-uiue`

Target execution thread: `019f13bc-ce36-7fe2-bc3f-49f703c0a81b`.

This dispatch authorizes local implementation, exact-path commits, existing PR branch pushes, GitHub check monitoring, and one combined GPT Pro PR-pair audit after push. It does not authorize merge, new PRs, runtime-ready claims, mobile/true-device/live claims, UIUE/main merge, or product readiness claims.

This file must pass a read-only Codex subagent pre-send audit before commander sends it. If the worker receives this dispatch without a commander note saying the pre-send audit passed, stop and ask the commander to provide the audit verdict.

D22 follows D20/D21's process shape but not its scope. D20 moved the app entry onto C3/payload; D21 added a UIUE-local payload fixture consumer. D22 must expand the corpus and runtime-presentation coverage without pretending that local fixtures are production runtime, mobile, true-device, live API, merge, or R5 completion proof.

## 1. Live Truth Candidates To Re-Probe

These values were live-verified at dispatch drafting time. They are not immutable. Re-probe before editing, before committing, and before every push.

| repo | path | branch | HEAD | upstream delta | PR |
|---|---|---|---|---|---|
| main | `/Users/wanglei/workspace/MAformac` | `codex/rebuild-c6-doc-absorption-20260624` | `d78f89046774b75138639f688d8c208312d40d78` | `0 0` from `@{u}...HEAD` | existing draft PR #7, `https://github.com/rayw-lab/MAformac/pull/7`, current state expected CLEAN |
| UIUE | `/Users/wanglei/workspace/MAformac-uiue` | `uiue/phase4-default-scope-presentation` | `cf50fab297f9c392290ea5750ab9e2093b57c274` | `0 0` from `@{u}...HEAD` | existing PR #6, `https://github.com/rayw-lab/MAformac/pull/6`, current state expected CLEAN |

Current dirty split to preserve:

- main preserve-unowned dirty: `AGENTS.md`, `CLAUDE.md`, `docs/CURRENT.md`, `docs/README.md`, `.xcodebuildmcp/`, `Tools/agent-platform-plugin-refs/`.
- main source dispatch artifact already untracked: `docs/dispatches/2026-06-29-uiue-r5-d20-d21-runtime-uiue-integration-pr-supertrain-dispatch.md`.
- this D22 dispatch file is commander-owned source artifact: `/Users/wanglei/workspace/MAformac/docs/dispatches/2026-06-30-uiue-r5-d22-runtime-payload-corpus-expansion-supertrain-dispatch.md`. Treat it as a trace artifact unless a later gate explicitly owns staging it.
- UIUE preserve-unowned dirty: `AGENTS.md`, `CLAUDE.md`.
- UIUE preserve-unowned source/research artifacts: existing D12-D19 source dispatch docs under `docs/dispatches/`, plus `docs/research/2026-06-29-visual-acceptance-standard/`.

Before editing, run and record:

```bash
git -C /Users/wanglei/workspace/MAformac status --short --branch
git -C /Users/wanglei/workspace/MAformac rev-parse HEAD
git -C /Users/wanglei/workspace/MAformac rev-list --left-right --count @{u}...HEAD
gh -R rayw-lab/MAformac pr view 7 --json number,title,headRefName,headRefOid,baseRefName,state,url,isDraft,mergeStateStatus,statusCheckRollup

git -C /Users/wanglei/workspace/MAformac-uiue status --short --branch
git -C /Users/wanglei/workspace/MAformac-uiue rev-parse HEAD
git -C /Users/wanglei/workspace/MAformac-uiue rev-list --left-right --count @{u}...HEAD
gh -R rayw-lab/MAformac pr view 6 --json number,title,headRefName,headRefOid,baseRefName,state,url,isDraft,mergeStateStatus,statusCheckRollup
```

If branch/PR truth differs, continue only if the new truth still maps to the same two existing PRs and the dirty split remains separable. Otherwise stop with:

`blocked at Gate 0 after repo/PR reconciliation; only missing updated branch/PR authority`.

## 2. Authority And Hard Boundaries

Read first:

1. main `CLAUDE.md`.
2. main `docs/CURRENT.md`.
3. main `docs/README.md`.
4. main `docs/project/phase0/r5-d20-d21-runtime-uiue-integration-main-receipt-2026-06-30.md`.
5. main `openspec/changes/define-runtime-adapter-execution/`.
6. main `openspec/changes/define-runtime-presentation-bridge/`.
7. UIUE `CLAUDE.md`.
8. UIUE `docs/CURRENT.md`.
9. UIUE `docs/README.md`.
10. UIUE `docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md`.
11. UIUE `docs/project/phase0/r5-d20-d21-runtime-uiue-integration-uiue-receipt-2026-06-30.md`.
12. UIUE `openspec/changes/ui-presentation/`.

Hard boundaries:

- No UIUE/main merge.
- No new PR. Update existing PR #7 and #6 only.
- No `git add .`.
- No revert, clean, overwrite, or format pass over preserve-unowned work.
- No staging existing untracked source dispatch files except D22 files explicitly owned by a gate.
- No staging `Reports/` unless a gate explicitly marks the report as tracked. Default is ignored/report-only.
- No C5/C6 model-quality lane, LoRA training, candidate comparison, golden-run, voice, mobile, true-device, live API, endpoint readiness, product acceptance, A-2 completion, or R5 complete claim.
- No UIUE consumption of main private Swift types, durable ledgers, raw runtime store, raw model output, training receipts, adapter-local private names, request fingerprints, or settled plan internals.
- No new shared payload field from UIUE alone. Main owns the public `RuntimePresentationPayload` schema; UIUE consumes only presentation-safe JSON.
- No local/unit/fixture/simulator/GitHub-check/audit proof promoted into production runtime, mobile, true-device, live, merge, or readiness proof.

## 2A. Using-Superpowers Execution Chain

Use the `using-superpowers` chain to drive the whole D22 supertrain, but do not let it override the user's explicit instructions, repo authority, OpenSpec, GitNexus, dirty-tree boundaries, or the audit budget.

At task start:

1. Invoke/use `using-superpowers` before implementation work.
2. Re-check applicable skills before each gate and before each materially different branch of work.
3. In Codex, map skill actions to Codex-native equivalents: shell for read/search/run, `apply_patch` for edits, `update_plan` for task tracking, subagents only for bounded read-only review/verification slices, and exact-path git commands for staging/commits.
4. Record in every gate receipt which skills were used, why they applied, which obvious skills were intentionally skipped, and what repo evidence constrained them.

Minimum expected skill routing:

- OpenSpec changes or spec truth: use the relevant `openspec-*` skill before editing OpenSpec files.
- GitNexus impact/change analysis: use `gitnexus-*` guidance before symbol edits and before commits.
- Bugs, validation failures, audit findings, retry/idempotency ambiguity, readback ambiguity, fixture/schema drift, proof drift, or surprising UIUE grill conflict: use `bug-iceberg-teardown` or equivalent iceberg teardown discipline.
- Before a materially risky branch, use `pre-mortem` discipline: local scout first, then Codex-native oracle/subagent/web search only when the issue is not purely local or current external pitfalls matter.
- PR push/finish work: use GitHub/branch finishing guidance compatible with the exact existing PR #7/#6 rule.
- GPT Pro PR audit: use `$gptpro` / GPT Pro automation guidance exactly once for the combined PR-pair audit node.

Do not claim `using-superpowers complete` as a proof class. It is process governance only. The final YAML must include a `superpowers_chain` ledger with skills used and any conflict resolution.

## 2B. Bounded UIUE Grill Retrospective And Range Review

D22 must widen the review range before coding. This is not a new gate and not a new audit node; it is a required Gate 0/Gate 1 intake artifact that prevents D22 from treating D20/D21 as the whole world.

UIUE has a large accumulated grill surface, including the R5 215-row runtime-presentation pack plus earlier UIUE/R0-R4/Phase0 grill and loop-competition assets. Do not claim you closed every historical row. Do produce a bounded crosswalk showing which rows are relevant to D22 and which are explicitly out of scope.

Minimum files to inspect and cite:

- `/Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r5-runtime-presentation-grill-pack-2026-06-28.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/final-grill-matrix.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/burndown-dispatch-plan.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/final-grill-list.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/grill-decisions-master.md`
- Current UIUE route map and D20/D21 receipts listed above.

Minimum live probes:

```bash
wc -l /Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/final-grill-matrix.md \
  /Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/burndown-dispatch-plan.md \
  /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r5-runtime-presentation-grill-pack-2026-06-28.md

rg -n "runtime|presentation|fixture|payload|snapshot|consumer|proof|private|durable|ledger|sibling|active|refused|mismatch|partial|terminal|timeout|cancel|interrupted|golden|voice|mobile|true-device|live|V-PASS" \
  /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament \
  /Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review
```

Minimum D22-relevant grill rows to explicitly classify in the intake or Gate 1 receipt:

- `G1 Mainline DTO / snapshot authority`
- `G2 UIUE consumer mapping`
- `G3 Terminal fixture manifest`
- `G4 Proof-class / no-claim ladder`
- `G5 Human/product policy`
- rows around RPB-01..RPB-14, RPB-17, RPB-22..RPB-25, RPB-30, RPB-34..RPB-36, RPB-44..RPB-52;
- rows around CE-011..CE-024, CE-032, CE-044..CE-052, CE-076, CE-080..CE-082;
- rows around UC-001..UC-004, UC-012..UC-018, UC-020;
- rows around PV-002..PV-004, PV-009, PV-012..PV-014, PV-018, PV-022;
- rows around MVG-004, MVG-016, MVG-017.

For each cluster, classify:

| cluster | D22 handling |
|---|---|
| `implement_now` | Directly inside one of the four D22 gates. |
| `guard_now` | D22 must add proof/no-claim/deny-list/test guard, but not implement the future lane. |
| `defer_lane` | Voice/model/golden/mobile/true-device/live/human-product lane; preserve as non-claim guard only. |
| `already_covered` | Covered by D18-D21 evidence; cite file/command/commit and do not rewrite. |
| `out_of_scope` | Not D22; cite why and carry forward if P0/P1. |

If the retrospective finds a real P0/P1 contradiction with the proposed D22 scope, use iceberg teardown and stop before coding if it changes the gate shape. If it only creates a P2/P3 hardening item, keep D22 moving and record the carry-forward.

GitNexus is an auxiliary lens in this retrospective. Use it actively for code symbol impact and process graph risk, but do not let stale index prose override live file content, tests, OpenSpec, or current receipts.

## 3. D22 Scope: What Is New

D22's job is to expand D20/D21, not to repeat them.

D20/D21 current truth:

- main app text entry is on `DemoRuntimeSessionRunner -> C3ExecutionPipeline -> RuntimePresentationPayload`.
- main public fixture manifest currently covers 5 presentation-safe payload fixtures: AC happy path, refusal safety, runtime error, reconciliation mismatch, and partial accept/refuse.
- UIUE has a local JSON fixture consumer into `PresentationSnapshot`, strict field/schema/proof/outcome/reconciliation validation, private marker rejection, explicit `partial_accept_partial_refuse`, and explicit proofClass bridging.
- PR #7/#6 are pushed and GitHub verify checks passed after the D20/D21 post-commander fix.

D22 must expand the real coverage surface in three dimensions:

1. Multi-family accepted payloads grounded in existing main C1/C2/runtime contract rows, not invented display-only fields.
2. Result-boundary payloads for refusal, runtime error, mismatch, already-state/noop, and partial accept/refuse with active/refused/sibling semantics preserved.
3. UIUE consumption and presentation projection for the expanded corpus, still using only public JSON fixtures.

The tempting shortcut is to add more hand-written JSON fixtures and call the job done. That is not enough. D22 must require either generated-from-main payload evidence or an explicit receipt-level split between `runtime_generated_fixture` and `bridge_contract_fixture`. Synthetic bridge fixtures are allowed only for contract states that main C3 does not yet produce end-to-end, and the receipt must not mislabel them as runtime execution proof.

## 4. Topology And Audit Budget

Strict serial topology, four long gates:

1. `D22_GATE_1_MAIN_RUNTIME_CORPUS_AUTHORITY_AND_GENERATOR`
2. `D22_GATE_2_MAIN_MULTI_FAMILY_PAYLOAD_EXECUTION`
3. `D22_GATE_3_UIUE_EXPANDED_CORPUS_CONSUMPTION`
4. `D22_GATE_4_DOC_CASCADE_PR_RECONCILE_GPTPRO`

Execution audit-node budget is exactly six:

| node | auditor | scope | rerun policy |
|---:|---|---|---|
| 1 | Hermes preferred; Codex subagent fallback only if Hermes unavailable | Gate 1 | one pass only; no rerun |
| 2 | Hermes preferred; Codex subagent fallback only if Hermes unavailable | Gate 2 | one pass only; no rerun |
| 3 | Hermes preferred; Codex subagent fallback only if Hermes unavailable | Gate 3 | one pass only; no rerun |
| 4 | Hermes preferred; Codex subagent fallback only if Hermes unavailable | Gate 4 | one pass only; no rerun |
| 5 | Claude Code | full D22 train after Gate 4 local closure | one pass only; no rerun inside this dispatch |
| 6 | GPT Pro | cloud audit of existing PR #7 and PR #6 after push | one combined PR-pair audit only; no rerun inside this dispatch |

The commander pre-send Codex subagent audit for this dispatch file is outside the execution audit-node budget.

Each gate gets exactly one gate audit node after local validation. Default engine is Hermes. If Hermes is unavailable after a concrete self-check, use one read-only Codex subagent fallback audit for that same node. The fallback consumes the same audit-node slot; it does not create a seventh node and does not authorize a later Hermes rerun for the same gate. Record the actual engine as `hermes` or `codex_subagent_fallback`.

If a gate audit returns FAIL/P0/P1/P2:

1. Fix owned issues locally.
2. Rerun relevant local validation/static checks.
3. Do not rerun the same auditor inside this dispatch.
4. Record `hermes_fail_fixed_post_audit` or `codex_subagent_fail_fixed_post_audit`, not auditor PASS.
5. Stop as blocked if the finding cannot be fixed/proven locally or violates no-touch/proof boundaries.

After all four gates, run one full-range Claude Code adversarial audit over D22. If Claude Code returns P0/P1/train-blocking findings, fix owned issues and rerun local validation/static checks, but do not rerun Claude Code inside this dispatch. Record `claude_code_fail_fixed_post_audit` when applicable, not Claude Code PASS.

After Claude closure, exact-path commit/push existing PR branches, monitor GitHub checks, then run one combined GPT Pro cloud PR-pair audit with a 20-minute watcher cap. If GPT Pro reports P0/P1/train-blocking issues, fix, validate, commit, and push again, but do not rerun GPT Pro inside this dispatch. Record `gptpro_request_changes_fixed_post_audit` or `gptpro_fail_fixed_post_audit` when applicable, not GPT Pro PASS.

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
- strict JSON decode / unknown-key ambiguity;
- schema/fixture hash drift;
- SwiftUI snapshot/display mismatch;
- pressure to invent shared fields;
- PR/GitHub/gh/GPT Pro automation surprise.

For unfamiliar Swift/SwiftUI/GitHub/ChatGPT-automation behavior, use local docs first, then web search or official docs/issues. Record source URLs and captured_at. Do not cite memory or model recall as proof.

## 6. Gate 1 - Main Runtime Corpus Authority And Generator

Label: `D22_GATE_1_MAIN_RUNTIME_CORPUS_AUTHORITY_AND_GENERATOR`

Repo: main only, `/Users/wanglei/workspace/MAformac`.

Goal:

Create a main-owned, deterministic D22 runtime-presentation payload corpus authority/generator so future fixture expansion is not a hand-written JSON drift surface.

Expected implementation direction:

- Add or refactor a main test/support fixture generator that can produce public `RuntimePresentationPayload` JSON objects from main-owned payload/snapshot builders.
- Clearly classify every fixture as one of:
  - `runtime_generated_fixture`: produced by a real local C3/runtime adapter/session path.
  - `bridge_contract_fixture`: deterministic bridge-level fixture for a public contract state that main C3 does not yet produce end-to-end.
- Preserve the existing 5 D20/D21 fixtures and their public/private boundary guarantees unless a deliberate migration updates both repos and receipts.
- Add D22 fixture metadata to manifest entries, including `caseID`, `fixtureClass`, `result`, `familyCoverage`, and `proofClass`, if this can be done without breaking the existing strict UIUE consumer. If manifest schema changes, UIUE must be updated in Gate 3.
- Do not add UIUE-owned names into main payload schema.
- Do not add private/durable/raw fields to public payload.
- Do not call bridge-contract fixtures runtime proof.

Likely writable paths:

- `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/`
- `/Users/wanglei/workspace/MAformac/Tests/Fixtures/RuntimePresentationPayload/`
- `/Users/wanglei/workspace/MAformac/Core/Presentation/` only if public payload encoding/projection needs production hardening.
- main OpenSpec tasks/specs only if public contract behavior needs explicit clarification.
- main gate receipt under `/Users/wanglei/workspace/MAformac/docs/project/phase0/`.

No-touch:

- main preserve-unowned dirty listed in section 1.
- UIUE repo.
- D20/D21 source dispatch artifact unless explicitly documenting D22 relationship in this dispatch's receipt.
- C5/C6/model/voice/golden/mobile/true-device files.

Before editing any symbol:

- Run GitNexus impact/context for `RuntimePresentationPayload`, `PresentationSnapshot`, `PresentationReconciliation`, `TraceEnvelope`, and any new generator entry point.
- If GitNexus index is stale, run the repo-local analyze command or record why stale index is acceptable only for docs/fixture-only work.
- If GitNexus returns HIGH/CRITICAL, stop and report before editing unless the finding is unindexed docs/test noise and local evidence proves it.

Required validation:

```bash
git -C /Users/wanglei/workspace/MAformac diff --check
cd /Users/wanglei/workspace/MAformac && swift test --filter RuntimePresentationPayloadPublicFixtureTests
cd /Users/wanglei/workspace/MAformac && openspec validate define-runtime-presentation-bridge --strict
```

Gate-specific assertions:

- Every manifest fixture has a matching file and sha256.
- Every public fixture has only public top-level fields.
- Private/durable markers are rejected case-insensitively.
- Fixture class is explicit; synthetic bridge fixtures are not reported as runtime-generated.
- Existing D20/D21 fixtures still decode and hash correctly.

Gate audit:

- Run one Hermes deep audit over Gate 1 changes after local validation.
- If Hermes is unavailable after concrete self-check, run one read-only Codex subagent fallback audit for Gate 1 instead.
- Required anchor: `HERMES_R5_D22_GATE_1_MAIN_RUNTIME_CORPUS_AUTHORITY_AND_GENERATOR_VERDICT: PASS|FAIL` or `CODEX_SUBAGENT_R5_D22_GATE_1_MAIN_RUNTIME_CORPUS_AUTHORITY_AND_GENERATOR_VERDICT: PASS|FAIL`.

Brief verdict label:

`D22_GATE_1_MAIN_RUNTIME_CORPUS_AUTHORITY_AND_GENERATOR brief`

## 7. Gate 2 - Main Multi-Family Payload Execution

Label: `D22_GATE_2_MAIN_MULTI_FAMILY_PAYLOAD_EXECUTION`

Repo: main only, `/Users/wanglei/workspace/MAformac`.

Goal:

Expand main local runtime payload coverage beyond the single AC command. D22 should prove multiple existing contract-backed families can produce presentation-safe payloads through the main C3/runtime/session path where feasible, and separately keep bridge-only result-boundary fixtures honest where full runtime execution is not yet implemented.

Expected implementation direction:

- Expand the default/local demo runtime bundle or session-test bundle from `singleCommandDemoDefault` toward a D22 multi-command demo bundle only using existing C1/C2 supported contracts.
- Add text-to-frame support only for commands grounded in current contracts. Do not invent C1/C2 rows or new shared fields just to satisfy D22.
- Recommended minimum accepted runtime-generated cases, subject to live C1/C2 truth:
  - AC accepted command.
  - Window accepted command.
  - Screen, ambient, or seat accepted command.
  - Already-state/noop for at least one supported command.
- Add deterministic public payload fixtures for the runtime-generated accepted/noop cases.
- Keep refusal, runtime_error, reconciliation mismatch, and partial accept/refuse fixtures if they remain bridge-contract fixtures; upgrade any of them to runtime-generated only if the actual local runtime path produces them end-to-end.
- If implementing partial accept/refuse end-to-end, do it as an explicit scoped feature with tests for per-action outcomes, active/refused cells, readbacks, and reconciliation. Do not fake partial by stitching unrelated payloads without marking it bridge-contract-only.
- Preserve C005/C061 durable/replay/readback semantics from D18/D20.

Likely writable paths:

- `/Users/wanglei/workspace/MAformac/Core/Execution/`
- `/Users/wanglei/workspace/MAformac/Core/Intent/`
- `/Users/wanglei/workspace/MAformac/Core/Presentation/`
- `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/`
- `/Users/wanglei/workspace/MAformac/Tests/Fixtures/RuntimePresentationPayload/`
- main OpenSpec tasks/specs if D22 clarifies runtime result or fixture class semantics.
- main gate receipt under `/Users/wanglei/workspace/MAformac/docs/project/phase0/`.

No-touch:

- UIUE repo.
- main preserve-unowned dirty.
- unrelated C5/C6/model/golden/voice/mobile/live files.

Before editing any symbol:

- Run GitNexus impact/context for `DemoRuntimeSessionRunner`, `DemoRuntimeContractBundle`, `FastPathIntentEngine.decode`, `C3ExecutionPipeline`, `DemoRuntimeAdapter`, `RuntimePresentationPayload`, and any touched tests/helpers.
- Record blast radius and affected processes in the Gate 2 receipt.

Required validation:

```bash
git -C /Users/wanglei/workspace/MAformac diff --check
cd /Users/wanglei/workspace/MAformac && swift test --filter 'DemoRuntimeSessionRunnerTests|DemoRuntimeAdapterTests|C3ExecutionPipelineTests|RuntimePresentationBridgeTests|VehicleStateStoreContractTests|RuntimePresentationPayloadPublicFixtureTests'
cd /Users/wanglei/workspace/MAformac && xcodebuild -scheme MAformacMac -destination 'platform=macOS' build
cd /Users/wanglei/workspace/MAformac && openspec validate define-runtime-adapter-execution --strict
cd /Users/wanglei/workspace/MAformac && openspec validate define-runtime-presentation-bridge --strict
cd /Users/wanglei/workspace/MAformac && openspec validate --all --strict
```

Gate-specific assertions:

- `App/ContentView.swift` still uses `DemoRuntimeSessionRunner` or its successor; no regression to `DemoWalkingSkeleton`.
- At least three contract-backed families have runtime-generated payload tests or an explicit documented reason why one is deferred.
- Already-state/noop and C2 readback verification remain covered.
- No fixture or payload leaks adapter/durable/private markers.
- Any bridge-contract fixture is labeled as such and not counted as runtime execution proof.

Gate audit:

- Run one Hermes deep audit over Gate 2 changes after local validation.
- If Hermes is unavailable after concrete self-check, run one read-only Codex subagent fallback audit for Gate 2 instead.
- Required anchor: `HERMES_R5_D22_GATE_2_MAIN_MULTI_FAMILY_PAYLOAD_EXECUTION_VERDICT: PASS|FAIL` or `CODEX_SUBAGENT_R5_D22_GATE_2_MAIN_MULTI_FAMILY_PAYLOAD_EXECUTION_VERDICT: PASS|FAIL`.

Brief verdict label:

`D22_GATE_2_MAIN_MULTI_FAMILY_PAYLOAD_EXECUTION brief`

## 8. Gate 3 - UIUE Expanded Corpus Consumption

Label: `D22_GATE_3_UIUE_EXPANDED_CORPUS_CONSUMPTION`

Repo: UIUE primary, main read-only for fixture/hash comparison.

Goal:

Update UIUE to consume the expanded D22 public fixture corpus into `PresentationSnapshot` without importing main private Swift types, without consuming durable/runtime internals, and without promoting local fixture proof.

Expected implementation direction:

- Start from the bounded grill retrospective in Section 2B. Gate 3 must include a UIUE D22 grill crosswalk receipt section that maps relevant R5 runtime-presentation rows/clusters to `implement_now`, `guard_now`, `defer_lane`, `already_covered`, or `out_of_scope`.
- Pay special attention to rows/clusters for UIUE consumer mapping, terminal fixture manifest, proof/no-claim ladder, active/refused/sibling cell semantics, runtime error/refusal/already-state/partial outcomes, unknown proofClass fail-closed behavior, and UIUE screenshot/visual proof no-promotion.
- If a row says UIUE can move fast only under local/fixture proof, keep the speed but preserve the proof cap. If a row requires mainline DTO/runtime authority, do not let UIUE invent a shared field or consume a private type to unblock itself.
- Copy/sync the D22 public fixture corpus from main into UIUE only after main Gate 2 has validated it.
- Extend UIUE fixture manifest expectations and tests to cover all D22 cases.
- If manifest schema changed in Gate 1, update the UIUE manifest decoder/tests strictly and fail closed on unknown critical fields only when appropriate. Do not silently ignore governance fields that are part of proof boundaries.
- Assert UIUE mappings for:
  - accepted multi-family payloads;
  - already-state/noop;
  - refusal safety/policy and `refusedCell`;
  - runtime error;
  - reconciliation mismatch;
  - partial accept/refuse;
  - active cells and scope origins;
  - sibling cell semantics when present;
  - proofClass downgrade/cap behavior.
- Keep `RuntimePresentationConsumerMapping.forbiddenPrivateNames` synchronized with any new private marker discovered in main. Do not add private markers to payload fields, proof labels, proof caps, or display names.
- Do not wire UIUE live frontstage to main runtime. This gate is public JSON fixture consumer proof only.

Likely writable paths:

- `/Users/wanglei/workspace/MAformac-uiue/Core/Presentation/RuntimePresentationPayloadFixtureConsumer.swift`
- `/Users/wanglei/workspace/MAformac-uiue/Core/Presentation/RuntimePresentationConsumerMapping.swift`
- `/Users/wanglei/workspace/MAformac-uiue/Tests/MAformacCoreTests/RuntimePresentationPayloadFixtureConsumerTests.swift`
- `/Users/wanglei/workspace/MAformac-uiue/Tests/MAformacCoreTests/RuntimePresentationConsumerMappingTests.swift`
- `/Users/wanglei/workspace/MAformac-uiue/Tests/Fixtures/RuntimePresentationPayload/`
- `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/tasks.md`
- UIUE gate receipt under `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/`.

No-touch:

- UIUE preserve-unowned `AGENTS.md`, `CLAUDE.md`.
- UIUE D12-D19 source dispatch docs.
- UIUE visual acceptance research directory.
- main repo, except read-only fixture/hash comparison and OpenSpec validation.

Before editing any symbol:

- Run GitNexus impact/context for `RuntimePresentationPayloadFixtureConsumer`, `RuntimePresentationConsumerMapping`, `PresentationSnapshot`, `VehicleCardDisplay.familyDisplays`, and any touched tests.
- If GitNexus returns HIGH/CRITICAL, stop and report before editing.

Required validation:

```bash
git -C /Users/wanglei/workspace/MAformac-uiue diff --check
cd /Users/wanglei/workspace/MAformac-uiue && swift test --filter 'RuntimePresentationPayloadFixtureConsumerTests|RuntimePresentationConsumerMappingTests|PresentationSnapshotTests|VehicleCardDisplayTests|SemanticColorMapperTests'
cd /Users/wanglei/workspace/MAformac-uiue && openspec validate ui-presentation --strict
cd /Users/wanglei/workspace/MAformac-uiue && make verify-ci
cd /Users/wanglei/workspace/MAformac && openspec validate define-runtime-presentation-bridge --strict
```

Gate-specific assertions:

- Gate 3 receipt includes the Section 2B grill crosswalk with cited file/line or command evidence for every D22-relevant cluster it claims.
- UIUE fixture hash/manifest matches main for every copied public fixture.
- Consumer rejects unknown fields and private/durable markers after any schema/manifest expansion.
- UIUE does not import main Swift modules/types.
- `PresentationSnapshot` output preserves active/refused/sibling/proof/result semantics without inventing new shared fields.
- UIUE proof remains local/unit/static/fixture consumer only.

Gate audit:

- Run one Hermes deep audit over Gate 3 changes after local validation.
- If Hermes is unavailable after concrete self-check, run one read-only Codex subagent fallback audit for Gate 3 instead.
- Required anchor: `HERMES_R5_D22_GATE_3_UIUE_EXPANDED_CORPUS_CONSUMPTION_VERDICT: PASS|FAIL` or `CODEX_SUBAGENT_R5_D22_GATE_3_UIUE_EXPANDED_CORPUS_CONSUMPTION_VERDICT: PASS|FAIL`.

Brief verdict label:

`D22_GATE_3_UIUE_EXPANDED_CORPUS_CONSUMPTION brief`

## 9. Gate 4 - Doc Cascade, Dirty Cleanup, PR Reconcile Prep

Label: `D22_GATE_4_DOC_CASCADE_PR_RECONCILE_GPTPRO`

The label keeps the D20/D21-compatible `GPTPRO` suffix because this gate prepares the PR/GPT Pro closure path. Execution order is still strict: finish all four gate audits first, then run Section 10 Claude Code final audit, then push/update existing PRs and run the one combined GPT Pro PR-pair audit. Do not run GPT Pro before Claude Code.

Repos: main and UIUE.

Goal:

Reconcile D22 into durable project docs, prepare clean exact-path commits in both repos, prepare existing PR branch updates for #7/#6, and verify that the post-Claude PR/GPT Pro path is safe. Actual PR push, GitHub check monitoring, and the one combined GPT Pro PR-pair audit happen only after Section 10 Claude Code final audit closure.

Required doc cascade:

Main:

- Add/update main D22 receipt under `/Users/wanglei/workspace/MAformac/docs/project/phase0/`.
- Update `/Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-adapter-execution/tasks.md` if runtime execution coverage changed.
- Update `/Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-presentation-bridge/tasks.md` if payload/corpus/schema/fixture contract changed.
- Record whether D22 changed the disposition of any R5 runtime-presentation grill clusters; if not, say so explicitly in the main receipt.
- Update only relevant docs; do not churn `docs/CURRENT.md` or `docs/README.md` unless current route authority truly requires it and preserve-unowned ownership is resolved.

UIUE:

- Add/update UIUE D22 receipt under `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/`.
- Update `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/tasks.md`.
- Update `/Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md` with D22 status and residuals.
- Update relevant burndown/loop-competition docs only if D22 changes row disposition; otherwise explicitly record no-update reason in the D22 receipt.
- Preserve the larger UIUE grill corpus as decision provenance. D22 may close or carry forward D22-relevant rows/clusters, but must not claim full historical grill closure.
- Do not rewrite the 215-row matrix just to make D22 look broader.

Dirty cleanup and exact-path staging:

- Before staging, print and record:

```bash
git -C /Users/wanglei/workspace/MAformac status --short
git -C /Users/wanglei/workspace/MAformac diff --name-only
git -C /Users/wanglei/workspace/MAformac-uiue status --short
git -C /Users/wanglei/workspace/MAformac-uiue diff --name-only
```

- Split every path into:
  - `owned_by_D22`;
  - `preserve_unowned_dirty`;
  - `source_dispatch_trace_artifact`;
  - `generated_or_report_only`;
  - `no_touch`.
- Use exact pathspec staging only.
- Run `git diff --cached --check`.
- Run GitNexus staged `detect_changes` for both repos before commit.
- If staged detect shows HIGH/CRITICAL or unexpected affected processes, stop unless the gate receipt gives a concrete local reason and commander/user explicitly allows continuation.
- After commit, run `git diff --check HEAD~1..HEAD`.
- After push, verify `git rev-list --left-right --count @{u}...HEAD` is `0 0`.
- Do not clean preserve-unowned dirty.

PR/GitHub flow:

- Update existing PR #7 and PR #6 only.
- Do not create a new PR.
- Do not merge.
- PR body/title may be updated to reflect D22 proof truth and non-claims.
- Push only after Gate 4 local validation, Section 10 Claude Code final audit closure, and exact-path commits.
- After push, monitor:

```bash
gh -R rayw-lab/MAformac pr checks 7 --watch --interval 10
gh -R rayw-lab/MAformac pr checks 6 --watch --interval 10
```

- If checks fail, fix owned issue, validate, commit, push. Record final status as GitHub check fixed-post-push if applicable.

GPT Pro node:

- After Section 10 Claude Code final audit closure, PR push, and green/fixed GitHub checks, run exactly one combined GPT Pro PR-pair audit over PR #7 and PR #6.
- Use a 20-minute watcher cap.
- Do not rerun GPT Pro inside this dispatch.
- If GPT Pro returns REQUEST_CHANGES/FAIL/P0/P1, fix owned issues, rerun local validation/GitHub checks, commit/push, and record `gptpro_request_changes_fixed_post_audit` or `gptpro_fail_fixed_post_audit`, not GPT Pro PASS.

Required validation:

Main:

```bash
cd /Users/wanglei/workspace/MAformac && swift test --filter 'DemoRuntimeSessionRunnerTests|DemoRuntimeAdapterTests|C3ExecutionPipelineTests|RuntimePresentationBridgeTests|VehicleStateStoreContractTests|RuntimePresentationPayloadPublicFixtureTests'
cd /Users/wanglei/workspace/MAformac && xcodebuild -scheme MAformacMac -destination 'platform=macOS' build
cd /Users/wanglei/workspace/MAformac && openspec validate define-runtime-adapter-execution --strict
cd /Users/wanglei/workspace/MAformac && openspec validate define-runtime-presentation-bridge --strict
cd /Users/wanglei/workspace/MAformac && openspec validate --all --strict
cd /Users/wanglei/workspace/MAformac && git diff --check
```

UIUE:

```bash
cd /Users/wanglei/workspace/MAformac-uiue && swift test --filter 'RuntimePresentationPayloadFixtureConsumerTests|RuntimePresentationConsumerMappingTests|PresentationSnapshotTests|VehicleCardDisplayTests|SemanticColorMapperTests'
cd /Users/wanglei/workspace/MAformac-uiue && make verify-ci
cd /Users/wanglei/workspace/MAformac-uiue && openspec validate ui-presentation --strict
cd /Users/wanglei/workspace/MAformac-uiue && git diff --check
```

Gate audit:

- Run one Hermes audit over Gate 4 doc cascade, dirty split, exact-path staging plan, PR update plan, and proof wording before push.
- If Hermes is unavailable after concrete self-check, run one read-only Codex subagent fallback audit for Gate 4 instead.
- Required anchor: `HERMES_R5_D22_GATE_4_DOC_CASCADE_PR_RECONCILE_VERDICT: PASS|FAIL` or `CODEX_SUBAGENT_R5_D22_GATE_4_DOC_CASCADE_PR_RECONCILE_VERDICT: PASS|FAIL`.

Brief verdict label:

`D22_GATE_4_DOC_CASCADE_PR_RECONCILE_GPTPRO brief`

## 10. Final Claude Code Audit

After Gate 4 local closure and before final closeout, run one full-range Claude Code adversarial audit over D22.

Audit scope:

- all D22 commits and exact changed paths in both repos;
- all D22 receipts and any post-audit fixes;
- main runtime/session/payload corpus semantics;
- UIUE fixture consumer and presentation snapshot semantics;
- fixture class truth: `runtime_generated_fixture` vs `bridge_contract_fixture`;
- private/durable/raw marker boundary;
- exact-path staging and source dispatch exclusion;
- doc cascade consistency across receipts, OpenSpec tasks, route map, and PR bodies;
- proof-class ceilings and forbidden readiness/merge claims;
- dirty split and preserved unowned paths.

Required anchor:

`CLAUDE_CODE_R5_D22_RUNTIME_PAYLOAD_CORPUS_FINAL_AUDIT_VERDICT: PASS|FAIL`

One pass only inside this dispatch. If it reports P0/P1/train-blocking findings, fix owned issues and rerun local validation/static checks, but do not rerun Claude Code. Record fail-fixed truth honestly.

## 11. Final YAML Verdict Required

At closeout, send a final YAML verdict back to the commander thread that sent this dispatch. Do not only leave it in local files.

Required shape:

```yaml
label: UIUE_R5_D22_RUNTIME_PAYLOAD_CORPUS_EXPANSION_SUPERTRAIN
status: DONE_UNDER_PROOF_CAP | DONE_UNDER_PROOF_CAP_WITH_AUDIT_FAIL_FIXED_POST_AUDIT | PARTIAL | BLOCKED
completed_at: "<timestamp with timezone>"
repos:
  main:
    path: "/Users/wanglei/workspace/MAformac"
    branch: "<branch>"
    head: "<sha>"
    upstream_delta: "<left right>"
    pr: "https://github.com/rayw-lab/MAformac/pull/7"
    pr_state: "<OPEN draft/non-draft, CLEAN/UNSTABLE/etc>"
    github_checks: "<summary>"
  uiue:
    path: "/Users/wanglei/workspace/MAformac-uiue"
    branch: "<branch>"
    head: "<sha>"
    upstream_delta: "<left right>"
    pr: "https://github.com/rayw-lab/MAformac/pull/6"
    pr_state: "<OPEN draft/non-draft, CLEAN/UNSTABLE/etc>"
    github_checks: "<summary>"
commits:
  main:
    - "<sha> <subject>"
  uiue:
    - "<sha> <subject>"
changed_files:
  main:
    - "<absolute path>"
  uiue:
    - "<absolute path>"
corpus:
  fixture_count: <n>
  runtime_generated_fixtures:
    - "<case id>"
  bridge_contract_fixtures:
    - "<case id>"
  families_covered:
    - "<family>"
  result_kinds_covered:
    - "<result_kind>"
grill_retrospective:
  files_inspected:
    - "<absolute path>"
  clusters:
    - id: "<G1/G2/G3/G4/G5/G6 or row id>"
      handling: "<implement_now|guard_now|defer_lane|already_covered|out_of_scope>"
      evidence: "<file:line or command>"
      residual: "<none or carry-forward>"
  not_claimed:
    - "no full historical UIUE grill closure"
    - "no product/human/voice/model/golden/mobile/true-device/live lane closure"
audit_nodes:
  - id: D22_GATE_1_MAIN_RUNTIME_CORPUS_AUTHORITY_AND_GENERATOR
    engine: Hermes | Codex_Subagent_Fallback
    anchor: "<anchor>"
    verdict: "<PASS | FAIL -> fixed-post-audit | unavailable fallback>"
  - id: D22_GATE_2_MAIN_MULTI_FAMILY_PAYLOAD_EXECUTION
    engine: Hermes | Codex_Subagent_Fallback
    anchor: "<anchor>"
    verdict: "<...>"
  - id: D22_GATE_3_UIUE_EXPANDED_CORPUS_CONSUMPTION
    engine: Hermes | Codex_Subagent_Fallback
    anchor: "<anchor>"
    verdict: "<...>"
  - id: D22_GATE_4_DOC_CASCADE_PR_RECONCILE_GPTPRO
    engine: Hermes | Codex_Subagent_Fallback
    anchor: "<anchor>"
    verdict: "<...>"
  - id: FINAL_FULL_TRAIN_AUDIT
    engine: Claude_Code
    anchor: "CLAUDE_CODE_R5_D22_RUNTIME_PAYLOAD_CORPUS_FINAL_AUDIT_VERDICT: PASS|FAIL"
    verdict: "<...>"
  - id: COMBINED_PR_PAIR_AUDIT
    engine: GPT_Pro
    verdict: "<PASS | REQUEST_CHANGES -> fixed-post-audit | FAIL -> fixed-post-audit>"
validation:
  main:
    - "<command>: PASS/FAIL summary"
  uiue:
    - "<command>: PASS/FAIL summary"
gitnexus:
  main:
    impact: "<summary>"
    staged_detect: "<risk/affected processes>"
  uiue:
    impact: "<summary>"
    staged_detect: "<risk/affected processes>"
dirty_split:
  main_preserve_unowned:
    - "AGENTS.md"
    - "CLAUDE.md"
    - "docs/CURRENT.md"
    - "docs/README.md"
    - ".xcodebuildmcp/"
    - "Tools/agent-platform-plugin-refs/"
    - "docs/dispatches/2026-06-29-uiue-r5-d20-d21-runtime-uiue-integration-pr-supertrain-dispatch.md"
    - "docs/dispatches/2026-06-30-uiue-r5-d22-runtime-payload-corpus-expansion-supertrain-dispatch.md"
  uiue_preserve_unowned:
    - "AGENTS.md"
    - "CLAUDE.md"
    - "pre-existing D12-D19 dispatch docs"
    - "docs/research/2026-06-29-visual-acceptance-standard/"
proof_class:
  accepted:
    - local
    - unit
    - integration
    - static
    - OpenSpec
    - GitNexus
    - GitHub CI check
    - audit evidence
  not_claimed:
    - production runtime
    - runtime-ready
    - mobile
    - true-device
    - live
    - UIUE merge
    - product acceptance-pass
    - A-2
    - R5 complete
    - voice/model/golden/endpoint readiness
superpowers_chain:
  used:
    - "<skill/process>"
  skipped:
    - "<skill/process and reason>"
residual_risks:
  - "<risk>"
source_dispatch_staged: false
exact_pathspec_staging: true
no_new_pr: true
no_merge: true
```

## 12. Stop Conditions

Stop and report `BLOCKED` or `PARTIAL` if:

- repo/PR truth no longer maps to existing PR #7/#6;
- dirty split cannot be separated safely;
- GitNexus returns HIGH/CRITICAL on a code symbol and no commander/user approval exists;
- a gate requires a new shared payload field and OpenSpec authority is not updated first;
- UIUE needs main private Swift types, durable/runtime internals, raw payloads, or adapter-local names to pass;
- local validation cannot prove an audit finding fix;
- Hermes/Codex fallback/Claude/GPT Pro evidence is missing but the gate tries to claim PASS;
- GitHub checks fail and cannot be fixed in owned scope;
- any artifact claims production runtime, runtime-ready, mobile, true-device, live, UIUE merge, product acceptance-pass, A-2, R5 complete, voice/model/golden/endpoint readiness.

## 13. First Worker Response

When you receive this dispatch, first reply with a short intake:

- live repo truth for main/UIUE;
- D22 goal in one sentence;
- owned/no-touch dirty split;
- bounded UIUE grill retrospective plan, including the files from Section 2B and proof that this is not a claim to close all historical grill rows;
- planned audit node budget;
- explicit statement that final YAML verdict will be returned to the commander thread.

Then start Gate 0/Gate 1 without waiting for another confirmation unless live truth blocks execution.

---
artifact_kind: commander_dispatch
label: UIUE_R5_D23_SHARED_SCHEMA_CHECKER_PR_HYGIENE_SUPERTRAIN
d_range: D23
status: SEND_READY_CODEX_SUBAGENT_AUDIT_PASS
created_at: 2026-06-30
target_thread: 019f13bc-ce36-7fe2-bc3f-49f703c0a81b
commander_receipt_target: commander_current_thread
proof_class_ceiling: docs_local + local_static + local_unit + local_integration + openspec_local + gitnexus_static + github_api + github_check
audit_policy: operator_selected_advisory_review_only_not_gate
---

# UIUE R5 D23 Shared Schema/Checker And PR Hygiene Supertrain Dispatch

## 0. Commander Preamble

Read this file first. Do not rely on chat prose alone.

Target execution thread: `019f13bc-ce36-7fe2-bc3f-49f703c0a81b`.

Repos:

- main: `/Users/wanglei/workspace/MAformac`
- UIUE: `/Users/wanglei/workspace/MAformac-uiue`

D23 follows the established commander workflow: live-probe both repos, preserve dirty split, implement only owned paths, validate locally, exact-path stage, update existing PR #7/#6 only when needed, monitor GitHub checks, and return final YAML to commander. It supersedes any old wording that treats heterogeneous/external review as a formal gate: the user selects any advisory review source, and source identity has no gate or proof-class property.

This dispatch authorizes local implementation and exact-path commits/pushes to the existing PR branches if the D23 code/docs changes validate. It does not authorize merge, new PRs, runtime-ready claims, mobile/true-device/live claims, UIUE/main merge, or product readiness claims.

The commander pre-send Codex subagent audit for this dispatch file is outside D23 execution scope. If the worker receives this dispatch without a commander note saying the pre-send audit passed, stop and ask the commander to provide the audit verdict.

## 1. Live Truth Candidates To Re-Probe

These were live-verified at dispatch drafting time. Re-probe before editing, before committing, before push, and before final YAML.

| repo | path | branch | local HEAD | local upstream delta | remote PR truth |
|---|---|---|---|---|---|
| main | `/Users/wanglei/workspace/MAformac` | `codex/rebuild-c6-doc-absorption-20260624` | `9e2f0a77ed976baf02dff89c70504018a4bbbf22` | `0 2` from local `@{u}...HEAD` | PR #7 OPEN draft/CLEAN, head `3e716020eef958b3f18e90b2ab9df3f3b53bdc31`, remote tree `b0f706af6cfbaba0a78547d384cba2c7a6e4afee`, `verify` success x2 |
| UIUE | `/Users/wanglei/workspace/MAformac-uiue` | `uiue/phase4-default-scope-presentation` | `dcd7ad0b046eabc8e5685e05476b3365bf4d1978` | `0 2` from local `@{u}...HEAD` | PR #6 OPEN non-draft/CLEAN, head `1c66467ee7485ea08200624f7bd6843999905f12`, remote tree `610154e7eaee384eb610abd4f2ed2b593166f4d1`, `verify` success x1 |

Important remote-truth rule: local upstream counters can be stale because D22 used GitHub API ref updates when normal GitHub 443 git transport failed. For PR truth, prefer `gh pr view`, `gh api repos/rayw-lab/MAformac/git/commits/<sha>`, and GitHub check rollups over local `origin/*` until a normal fetch succeeds.

Current dirty split to preserve:

- main preserve-unowned dirty: `AGENTS.md`, `CLAUDE.md`, `docs/CURRENT.md`, `docs/README.md`, `.xcodebuildmcp/`, `Tools/agent-platform-plugin-refs/`.
- main source dispatch trace artifacts: D20/D21 dispatch, D22 dispatch, this D23 dispatch.
- main commander verdict artifact: `/Users/wanglei/workspace/MAformac/docs/project/phase0/r5-d22-runtime-payload-corpus-expansion-commander-verdict-2026-06-30.md`.
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

If PR truth no longer maps to existing PR #7/#6, stop with:

`blocked at Gate 0 after repo/PR reconciliation; only missing updated PR authority`

## 2. Authority And Hard Boundaries

Read first:

1. main `CLAUDE.md`.
2. main `docs/CURRENT.md`.
3. main `docs/README.md`.
4. main `docs/project/phase0/r5-d22-runtime-payload-corpus-expansion-main-receipt-2026-06-30.md`.
5. main `docs/project/phase0/r5-d22-runtime-payload-corpus-expansion-commander-verdict-2026-06-30.md`.
6. main `openspec/changes/define-runtime-presentation-bridge/`.
7. main `openspec/changes/define-runtime-adapter-execution/`.
8. UIUE `CLAUDE.md`.
9. UIUE `docs/CURRENT.md`.
10. UIUE `docs/README.md`.
11. UIUE `docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md`.
12. UIUE `docs/project/phase0/r5-d22-runtime-payload-corpus-expansion-uiue-gate3-receipt-2026-06-30.md`.
13. UIUE `openspec/changes/ui-presentation/`.

Hard boundaries:

- No UIUE/main merge.
- No new PR. Update existing PR #7 and #6 only if D23 changes are committed.
- No `git add .`.
- No revert, clean, overwrite, or format pass over preserve-unowned work.
- No staging existing source dispatch files or commander verdicts unless D23 explicitly marks them owned.
- No staging `Reports/` unless a gate explicitly marks the report as tracked. Default is ignored/report-only.
- No C5/C6 model-quality lane, LoRA training, candidate comparison, golden-run, voice, mobile, true-device, live API, endpoint readiness, product acceptance, A-2 completion, or R5 complete claim.
- No UIUE consumption of main private Swift types, durable ledgers, raw runtime store, raw model output, training receipts, adapter-local private names, request fingerprints, or settled plan internals.
- No UIUE-invented shared field. Main owns public `RuntimePresentationPayload` and any public fixture schema/checker authority. UIUE consumes only published public JSON/schema/checker artifacts.
- No local/unit/fixture/simulator/GitHub-check/advisory-review proof promoted into production runtime, mobile, true-device, live, merge, or readiness proof.

## 2A. Using-Superpowers Execution Chain

Use the `using-superpowers` chain to drive the whole D23 train, but do not let it override the user's newest instructions, repo authority, OpenSpec, GitNexus, dirty-tree boundaries, proof caps, or the advisory-review policy.

At task start:

1. Invoke/use `using-superpowers` before implementation work.
2. Re-check applicable skills before each gate and before each materially different branch of work.
3. In Codex, map skill actions to Codex-native equivalents: shell for read/search/run, `apply_patch` for edits, `update_plan` for task tracking, subagents only for bounded read-only review/verification slices, and exact-path git commands for staging/commits.
4. Record in every gate receipt which skills were used, why they applied, which obvious skills were intentionally skipped, and what repo evidence constrained them.

Minimum expected skill routing:

- OpenSpec changes or spec truth: use the relevant `openspec-*` skill before editing OpenSpec files.
- GitNexus impact/change analysis: use `gitnexus-*` guidance before symbol edits and before commits.
- Bugs, validation failures, advisory findings, retry/idempotency ambiguity, readback ambiguity, fixture/schema drift, proof drift, or surprising UIUE route/grill conflict: use `bug-iceberg-teardown` or equivalent iceberg teardown discipline.
- Before a materially risky branch, use `pre-mortem` discipline: local scout first, then Codex-native oracle/subagent/web search only when the issue is not purely local or current external pitfalls matter.
- PR push/finish work: use GitHub/branch finishing guidance compatible with the exact existing PR #7/#6 rule.

Do not claim `using-superpowers complete` as a proof class. It is process governance only. The final YAML must include a `superpowers_chain` ledger with skills used, skills skipped, and any conflict resolution.

## 2B. D23 Range Review And D22 Truth Preservation

D23 must not treat "shared schema/checker" as a narrow test-only cleanup if live evidence shows a provider/consumer contract drift. Gate 0/Gate 1 must include a bounded range review before edits.

D23 must preserve these D22 commander-truth facts in its intake and final receipts, not only cite the commander verdict file:

- D22 commander verdict is `DONE_UNDER_PROOF_CAP / PASS_WITH_NOTES`.
- Claude Code final audit was skipped by direct user override after Gate4 and must not be counted as an executed D22 audit node.
- The first GPT Pro PR-pair audits returned `REQUEST_CHANGES`; owned issues were fixed post-audit. Later post-fix review is separate advisory evidence and does not rewrite first-audit truth.
- Heterogeneous/external/advisory review source is user-selected and has no gate/proof-class property.

Minimum files to inspect and cite:

- `/Users/wanglei/workspace/MAformac/docs/project/phase0/r5-d22-runtime-payload-corpus-expansion-main-receipt-2026-06-30.md`
- `/Users/wanglei/workspace/MAformac/docs/project/phase0/r5-d22-runtime-payload-corpus-expansion-commander-verdict-2026-06-30.md`
- `/Users/wanglei/workspace/MAformac/Tests/Fixtures/RuntimePresentationPayload/manifest.json`
- `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/RuntimePresentationPayloadPublicFixtureTests.swift`
- `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-d22-runtime-payload-corpus-expansion-uiue-gate3-receipt-2026-06-30.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md`
- `/Users/wanglei/workspace/MAformac-uiue/Tests/Fixtures/RuntimePresentationPayload/manifest.json`
- `/Users/wanglei/workspace/MAformac-uiue/Tests/MAformacCoreTests/RuntimePresentationPayloadFixtureConsumerTests.swift`

Minimum live probes:

```bash
diff -qr /Users/wanglei/workspace/MAformac/Tests/Fixtures/RuntimePresentationPayload \
  /Users/wanglei/workspace/MAformac-uiue/Tests/Fixtures/RuntimePresentationPayload

rg -n "schemaVersion|caseID|fixtureClass|result|familyCoverage|proofClass|timestamp|partial_accept_partial_refuse|runtime_generated_fixture|bridge_contract_fixture|private|durable|raw" \
  /Users/wanglei/workspace/MAformac/Tests/Fixtures/RuntimePresentationPayload \
  /Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/RuntimePresentationPayloadPublicFixtureTests.swift \
  /Users/wanglei/workspace/MAformac-uiue/Tests/Fixtures/RuntimePresentationPayload \
  /Users/wanglei/workspace/MAformac-uiue/Tests/MAformacCoreTests/RuntimePresentationPayloadFixtureConsumerTests.swift
```

Classify every discovered D23-relevant item as:

| class | D23 handling |
|---|---|
| `implement_now` | Directly inside Gate 1 or Gate 2. |
| `guard_now` | Add checker/test/proof/no-claim guard, but do not implement future runtime/UI lanes. |
| `defer_lane` | Future runtime/mobile/true-device/live/human/product/voice/model/golden/endpoint or merge lane. Preserve as non-claim guard only. |
| `already_covered` | Covered by D22 evidence; cite file/command/commit and do not rewrite. |
| `out_of_scope` | Not D23; cite why and carry forward if P0/P1. |

If the range review finds a real P0/P1 contradiction with D23 scope, use iceberg teardown and stop before coding if it changes gate shape. If it only creates a P2/P3 hardening item, keep D23 moving and record the carry-forward.

## 3. D23 Goal And Non-goals

Goal: turn D22's 9-fixture public runtime-presentation corpus into a lower-drift dual-repo contract by adding a shared public fixture schema/checker lane, then reconcile PR #7/#6 remote truth and reviewability hygiene under the existing proof cap.

Non-goals:

- Do not expand the runtime feature corpus beyond D22's 9 fixtures unless a checker test needs a negative fixture generated in test code.
- Do not make UIUE a runtime schema authority.
- Do not re-open D22 implementation unless the checker exposes a concrete P0/P1 drift.
- Do not close PR #6 long-branch reviewability as merge-ready.
- Do not run or claim mobile, true-device, live API, voice/model/golden, endpoint, V/S/U/A-2, or R5 completion.

## 4. Audit And Review Policy

D23 inherits old commander mechanics but overrides old gate wording:

- Implementation gates close on repo evidence: tests, static checks, OpenSpec validation, GitNexus impact/change checks, PR API/check truth, and receipt consistency.
- Heterogeneous/external/advisory review source is selected by the user/operator. Source identity is not a gate, not a proof class, and not readiness evidence.
- If Hermes, Claude Code, GPT Pro, Codex subagent, or another source is used, record it as `advisory_review_user_selected`. Its findings can create fixes, residuals, or blockers, but its PASS does not promote proof and its absence does not by itself make a local gate fail unless the user explicitly says this D23 run requires that review.
- A failed advisory review that is fixed afterward must remain `advisory_request_changes_fixed_post_review` or equivalent, not retroactive PASS.
- The commander pre-send Codex subagent audit checks dispatch completeness only. It is outside D23 execution and has no gate/proof property.

## 5. Topology

Strict serial topology, four implementation gates:

1. `D23_GATE_1_MAIN_SHARED_PUBLIC_FIXTURE_SCHEMA_CHECKER`
2. `D23_GATE_2_UIUE_SCHEMA_CHECKER_ADOPTION_AND_PARITY`
3. `D23_GATE_3_PR_REMOTE_TRUTH_AND_REVIEWABILITY_HYGIENE`
4. `D23_GATE_4_DOC_CASCADE_FINAL_RECONCILE`

## 6. Required Harness For Every Gate

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
- post-advisory/post-audit correction rule.

Trigger local/web cross-search plus iceberg teardown whenever any of these appear:

- validation failure;
- GitNexus HIGH/CRITICAL or stale index;
- advisory review finding from Hermes, Claude Code, GPT Pro, Codex subagent, or any user-selected source;
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

For unfamiliar Swift/SwiftUI/GitHub/ChatGPT-automation behavior, use local docs first, then web search or official docs/issues. Record source URLs and `captured_at`. Do not cite memory or model recall as proof.

## 7. Pre-send And In-train Review Rules

### Commander Pre-send Dispatch Audit

Before commander sends this dispatch:

1. Run local static checks appropriate to a docs dispatch, at minimum `git diff --check`.
2. Spawn a read-only Codex subagent verifier.
3. Ask it to check dispatch completeness, D23 scope, no-touch/no-claim discipline, harness inheritance from D22, advisory-review non-gate wording, dirty split, validation, final YAML, and send-readiness.
4. If it returns P0/P1 or send-blocking findings, fix the dispatch and rerun the pre-send audit.
5. Send only after PASS/send_ready.

### In-train Advisory Review

D23 does not require a fixed Hermes/Claude/GPT Pro gate budget. If the worker or user chooses an advisory reviewer, use exactly the user-selected source and record it as non-gate. A reviewer finding may require a fix or residual, but:

- do not call the reviewer identity a proof class;
- do not call a skipped reviewer missing proof;
- do not rewrite `REQUEST_CHANGES`/FAIL into PASS after a post-review fix;
- do not use any advisory PASS to promote local proof into runtime/mobile/live/merge/readiness.

## 8. Gate 1: Main Shared Public Fixture Schema/Checker

Label: `D23_GATE_1_MAIN_SHARED_PUBLIC_FIXTURE_SCHEMA_CHECKER`

Goal: create or harden a main-owned checker/schema authority for the D22 public runtime-presentation fixture corpus so future main/UIUE drift is caught by code, not prose.

Writable paths:

- `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/RuntimePresentationPayloadPublicFixtureTests.swift`
- `/Users/wanglei/workspace/MAformac/Tests/Fixtures/RuntimePresentationPayload/`
- optional main-owned checker/schema path under `/Users/wanglei/workspace/MAformac/Tests/Fixtures/RuntimePresentationPayload/` or `/Users/wanglei/workspace/MAformac/Tests/Support/`
- main OpenSpec task files only if D23 acceptance needs a task entry
- main D23 receipt under `/Users/wanglei/workspace/MAformac/docs/project/phase0/`

Required behavior:

- Define a single public fixture schema/checker surface for:
  - manifest schema version;
  - fixture names and exact count;
  - `caseID`, `fixtureClass`, `result`, `familyCoverage`, `proofClass`;
  - allowed `fixtureClass` values: `bridge_contract_fixture`, `runtime_generated_fixture`;
  - allowed proof class ceiling: local/unit/static only for D22 public fixtures;
  - top-level public payload field set;
  - no top-level `timestamp`;
  - no `cards[].timestamp`;
  - trace-envelope timestamps allowed only inside trace entries;
  - result vocabulary must be expressible by main typed result enums;
  - private/durable/raw marker denial.
- Preserve all D22 fixture payload content unless a checker exposes an actual defect.
- Keep runtime-generated provenance tied to local generator/readback tests; do not relabel bridge fixtures as runtime-generated.

Validation:

```bash
swift test --filter RuntimePresentationPayloadPublicFixtureTests
swift test --filter 'RuntimePresentationBridgeTests|RuntimePresentationPayloadPublicFixtureTests'
openspec validate define-runtime-presentation-bridge --strict
git diff --check
```

GitNexus:

- Run `impact` before editing any Swift symbol.
- Run `detect_changes` before commit/staging closeout.
- If impact returns HIGH/CRITICAL on production symbols, stop unless the finding is limited to tests or the user/commander explicitly authorizes continuation.
- If GitNexus index is stale, run the repo-local analyze command or record why stale index is acceptable only for docs/fixture-only work.

Brief verdict fields:

```yaml
gate: D23_GATE_1_MAIN_SHARED_PUBLIC_FIXTURE_SCHEMA_CHECKER
status: DONE|PARTIAL|BLOCKED
proof_class: local_unit + local_static + openspec_local + gitnexus_static
changed_paths: []
validation: []
advisory_review:
  used: false
  source: null
  gate_property: false
harness:
  superpowers_chain: []
  lessons_learned: []
  premortem: []
  local_search: []
  web_search: []
  iceberg: []
  goal_drift_check: ""
  authority_check: ""
  claim_vs_proof_check: ""
  boundary_check: ""
  self_question: ""
residuals: []
```

## 9. Gate 2: UIUE Schema/Checker Adoption And Parity

Label: `D23_GATE_2_UIUE_SCHEMA_CHECKER_ADOPTION_AND_PARITY`

Goal: make UIUE consume the main-owned public fixture schema/checker without inventing fields, and prove main/UIUE fixture/schema parity locally.

Writable paths:

- `/Users/wanglei/workspace/MAformac-uiue/Core/Presentation/RuntimePresentationPayloadFixtureConsumer.swift`
- `/Users/wanglei/workspace/MAformac-uiue/Tests/MAformacCoreTests/RuntimePresentationPayloadFixtureConsumerTests.swift`
- `/Users/wanglei/workspace/MAformac-uiue/Tests/Fixtures/RuntimePresentationPayload/`
- optional UIUE-local copied checker/schema artifact only if it is explicitly tied to main digest/parity
- UIUE OpenSpec task file only if D23 acceptance needs a task entry
- UIUE D23 receipt under `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/`

Required behavior:

- UIUE must validate the same public manifest/schema expectations as main.
- UIUE must not accept a new public field unless main schema/checker owns it.
- UIUE must not accept `cards[].timestamp`; trace-entry timestamps remain allowed only as presentation-safe trace metadata.
- UIUE must continue mapping allowed main proof labels to `.localMock` or existing capped display proof, with no runtime-ready downgrade/default.
- Add an explicit parity check or digest check that fails if main/UIUE public fixture corpus or schema/checker drifts.
- If a copied schema/checker artifact is used, record its source path, digest, and update rule in the UIUE receipt.

Validation:

```bash
swift test --filter 'RuntimePresentationPayloadFixtureConsumerTests|RuntimePresentationConsumerMappingTests'
make verify-ci
openspec validate ui-presentation --strict
git -C /Users/wanglei/workspace/MAformac-uiue diff --check
```

GitNexus:

- Run `impact` before editing any Swift symbol.
- Run `detect_changes` before commit/staging closeout.
- If impact returns HIGH/CRITICAL on production UI symbols, stop unless the edit is test-only or the user/commander explicitly authorizes continuation.
- If GitNexus index is stale, run the repo-local analyze command or record why stale index is acceptable only for docs/fixture-only work.

Brief verdict fields:

```yaml
gate: D23_GATE_2_UIUE_SCHEMA_CHECKER_ADOPTION_AND_PARITY
status: DONE|PARTIAL|BLOCKED
proof_class: local_unit + local_static + openspec_local + gitnexus_static
changed_paths: []
validation: []
advisory_review:
  used: false
  source: null
  gate_property: false
harness:
  superpowers_chain: []
  lessons_learned: []
  premortem: []
  local_search: []
  web_search: []
  iceberg: []
  goal_drift_check: ""
  authority_check: ""
  claim_vs_proof_check: ""
  boundary_check: ""
  self_question: ""
residuals: []
```

## 10. Gate 3: PR Remote Truth And Reviewability Hygiene

Label: `D23_GATE_3_PR_REMOTE_TRUTH_AND_REVIEWABILITY_HYGIENE`

Goal: reconcile D23 changes against existing PR #7/#6 remote truth and make the reviewability state explicit without claiming merge readiness.

Writable paths:

- PR body/title for existing PR #7 and PR #6 if D23 changed code/docs.
- main/UIUE D23 receipts.
- No source dispatch staging unless explicitly owned in this dispatch.

Required behavior:

- Verify remote PR heads, trees, and GitHub checks with GitHub API.
- If normal `git push` works, use it. If normal git transport fails with GitHub 443/network issues, use the previously accepted GitHub API ref-update fallback only after local commit, then verify remote head/tree/checks.
- Keep PR #6 long-branch reviewability as residual unless D23 actually reduces it.
- If PR body has D22 whitelist/residuals, add D23-specific paths/checker summary without erasing D22 first-audit truth.
- Do not mark PR #6/#7 merge-ready.

Validation:

```bash
gh -R rayw-lab/MAformac pr view 7 --json number,title,headRefName,headRefOid,baseRefName,state,url,isDraft,mergeStateStatus,statusCheckRollup
gh -R rayw-lab/MAformac pr view 6 --json number,title,headRefName,headRefOid,baseRefName,state,url,isDraft,mergeStateStatus,statusCheckRollup
gh api repos/rayw-lab/MAformac/git/commits/<pr7_head> --jq '.tree.sha'
gh api repos/rayw-lab/MAformac/git/commits/<pr6_head> --jq '.tree.sha'
```

Brief verdict fields:

```yaml
gate: D23_GATE_3_PR_REMOTE_TRUTH_AND_REVIEWABILITY_HYGIENE
status: DONE|PARTIAL|BLOCKED
proof_class: github_api + github_check + local_static
pr_truth:
  pr7: {}
  pr6: {}
reviewability:
  pr6_long_branch_residual: true
advisory_review:
  used: false
  source: null
  gate_property: false
harness:
  superpowers_chain: []
  lessons_learned: []
  premortem: []
  local_search: []
  web_search: []
  iceberg: []
  goal_drift_check: ""
  authority_check: ""
  claim_vs_proof_check: ""
  boundary_check: ""
  self_question: ""
residuals: []
```

## 11. Gate 4: Doc Cascade And Final Reconcile

Label: `D23_GATE_4_DOC_CASCADE_FINAL_RECONCILE`

Goal: write durable receipts and route-control updates for D23, preserve D22 truth, and return final YAML to commander.

Writable paths:

- `/Users/wanglei/workspace/MAformac/docs/project/phase0/r5-d23-shared-schema-checker-pr-hygiene-main-receipt-2026-06-30.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-d23-shared-schema-checker-pr-hygiene-uiue-receipt-2026-06-30.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md`
- relevant OpenSpec task files if D23 touched them
- PR body/title updates if needed

Required behavior:

- Route map must record D22 commander verdict as `DONE_UNDER_PROOF_CAP / PASS_WITH_NOTES`.
- Route map and D23 receipts must preserve D22's Claude Code final audit skip and first GPT Pro `REQUEST_CHANGES fixed post-audit` facts.
- Route map must record the user rule: external/heterogeneous/advisory review source is user-selected and not a gate/proof-class source.
- D23 receipts must distinguish main schema/checker authority from UIUE adoption/parity.
- D23 final YAML must include changed paths, validations, PR truth, dirty split, proof cap, and non-claims.

Validation:

```bash
openspec validate define-runtime-presentation-bridge --strict
openspec validate ui-presentation --strict
git -C /Users/wanglei/workspace/MAformac diff --check
git -C /Users/wanglei/workspace/MAformac-uiue diff --check
```

## 12. Staging, Commit, Push, And GitHub Discipline

Before staging, print and record:

```bash
git -C /Users/wanglei/workspace/MAformac status --short
git -C /Users/wanglei/workspace/MAformac diff --name-only
git -C /Users/wanglei/workspace/MAformac-uiue status --short
git -C /Users/wanglei/workspace/MAformac-uiue diff --name-only
```

Split every path into:

- `owned_by_D23`;
- `preserve_unowned_dirty`;
- `source_dispatch_trace_artifact`;
- `commander_verdict_trace_artifact`;
- `generated_or_report_only`;
- `no_touch`.

Use exact pathspec staging only. Do not use `git add .`.

Required sequence:

1. Run `git diff --cached --check` after staging.
2. Run GitNexus staged `detect_changes` for both repos before commit.
3. If staged detect shows HIGH/CRITICAL or unexpected affected processes, stop unless the gate receipt gives a concrete local reason and commander/user explicitly allows continuation.
4. After commit, run `git diff --check HEAD~1..HEAD`.
5. Push only existing PR branches #7/#6 if D23 commits exist.
6. After push, verify PR head/tree and GitHub checks with GitHub API.
7. Do not clean preserve-unowned dirty.

PR/GitHub flow:

- Update existing PR #7 and PR #6 only.
- Do not create a new PR.
- Do not merge.
- PR body/title may be updated to reflect D23 schema/checker proof truth and non-claims.
- If GitHub checks fail, fix owned issue, validate, commit, push, and record fixed-post-push truth.

Suggested check watchers:

```bash
gh -R rayw-lab/MAformac pr checks 7 --watch --interval 10
gh -R rayw-lab/MAformac pr checks 6 --watch --interval 10
```

## 13. Final YAML Required

Return a final YAML verdict in the execution thread. If the worker can message commander directly, also send it back to commander. If not, set `commander_verdict_required: true`.

Required shape:

```yaml
label: UIUE_R5_D23_SHARED_SCHEMA_CHECKER_PR_HYGIENE_SUPERTRAIN
status: DONE_UNDER_PROOF_CAP|PARTIAL|BLOCKED
completed_at: "2026-06-30 Asia/Shanghai"
commander_verdict_required: true|false
proof_class:
  accepted: [docs_local, local_static, local_unit, local_integration, openspec_local, gitnexus_static, github_api, github_check]
  advisory_review_gate_property: false
  not_claimed:
    - production_runtime
    - runtime_ready
    - mobile
    - true_device
    - live_api
    - uiue_merge
    - v_pass
    - s_pass
    - u_pass
    - a_2
    - r5_complete
    - voice_model_golden_endpoint_readiness
repos:
  main:
    path: /Users/wanglei/workspace/MAformac
    branch: codex/rebuild-c6-doc-absorption-20260624
    head: "<sha>"
    upstream_delta: "<left right>"
    pr: "https://github.com/rayw-lab/MAformac/pull/7"
    pr_head: "<sha>"
    pr_tree: "<sha>"
    checks: []
  uiue:
    path: /Users/wanglei/workspace/MAformac-uiue
    branch: uiue/phase4-default-scope-presentation
    head: "<sha>"
    upstream_delta: "<left right>"
    pr: "https://github.com/rayw-lab/MAformac/pull/6"
    pr_head: "<sha>"
    pr_tree: "<sha>"
    checks: []
gates:
  - id: D23_GATE_1_MAIN_SHARED_PUBLIC_FIXTURE_SCHEMA_CHECKER
    status: DONE|PARTIAL|BLOCKED
    validation: []
  - id: D23_GATE_2_UIUE_SCHEMA_CHECKER_ADOPTION_AND_PARITY
    status: DONE|PARTIAL|BLOCKED
    validation: []
  - id: D23_GATE_3_PR_REMOTE_TRUTH_AND_REVIEWABILITY_HYGIENE
    status: DONE|PARTIAL|BLOCKED
    validation: []
  - id: D23_GATE_4_DOC_CASCADE_FINAL_RECONCILE
    status: DONE|PARTIAL|BLOCKED
    validation: []
advisory_reviews:
  policy: user_selected_non_gate_non_proof
  used: []
d22_commander_truth:
  commander_status: DONE_UNDER_PROOF_CAP / PASS_WITH_NOTES
  claude_code_final_audit: skipped_by_user_override
  first_gptpro_pr_pair_audit: REQUEST_CHANGES_fixed_post_audit
  later_post_fix_review: separate_advisory_evidence_not_rewrite_of_first_audit
harness:
  superpowers_chain:
    used: []
    skipped: []
    conflicts: []
  range_review:
    files_inspected: []
    classifications: []
  lessons_learned: []
  premortem: []
  local_search: []
  web_search: []
  iceberg: []
  goal_drift_check: ""
  authority_check: ""
  claim_vs_proof_check: ""
  boundary_check: ""
  self_question: ""
changed_files:
  main: []
  uiue: []
commits:
  main: []
  uiue: []
dirty_split:
  preserve_unowned_main: []
  preserve_unowned_uiue: []
residual_risks: []
no_new_pr: true
no_merge: true
```

## 14. Stop Conditions

Stop as `BLOCKED` or `PARTIAL` if:

- live PR truth no longer maps to #7/#6;
- D23 requires a new PR, merge, or product readiness decision;
- UIUE must invent a public field to pass;
- checker/schema work requires production runtime/mobile/live proof;
- GitNexus reports HIGH/CRITICAL on production symbols and no user/commander approval exists;
- validation cannot prove the fix locally;
- an advisory review finding is unfixable within D23 scope and affects D23's local proof.
- any artifact claims production runtime, runtime-ready, mobile, true-device, live, UIUE merge, product acceptance-pass, A-2, R5 complete, voice/model/golden/endpoint readiness.

## 15. First Response Required

Before Gate 1 edits, respond with short intake:

- live repo truth for main/UIUE;
- D23 goal in one sentence;
- owned/no-touch dirty split;
- how the shared schema/checker will be made main-owned and UIUE-adopted;
- explicit statement that advisory/external review source is user-selected and not a gate/proof-class source;
- explicit statement that D23 will include the D22-style harness fields in every gate receipt;
- final YAML will be returned to commander.

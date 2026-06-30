---
artifact_kind: commander_dispatch
label: UIUE_R5_D24_FULL_ABSORPTION_ROUTE_CONTROL_PR_MERGE_LONGRUN
d_range: D24
status: SEND_READY_HERMES_AUDIT_PASS_WITH_NOTES_P2_FIXED
created_at: 2026-06-30
target_thread: 019f173c-e34f-75d1-a764-992a9280891d
commander_receipt_target: commander_current_thread
execution_mode: executing_plans_long_task
proof_class_ceiling: local_static + docs_local + code_local + openspec_local + local_unit + local_ci_equivalent + github_api_remote_truth + github_checks + authorized_pr_merge_operation
merge_order: [PR_7_MAIN, PR_6_UIUE]
execution_audit_nodes: [post_D24G_subagentcodex_final_audit, post_D24G_github_cloud_audit]
pre_send_audit: hermes_one_pass_dispatch_audit_outside_execution_budget
pre_send_audit_verdict: HERMES_PASS_WITH_NOTES_NO_P0_NO_P1_P2_WORDING_FIXED
cloud_review_policy: new_pr_allowed_if_needed_for_github_cloud_audit_or_d24_review_surface
advisory_review_policy: user_selected_advisory_reviews_are_not_gates_and_not_proof_class
skills_execution_contract: executing-plans + pre-mortem + bug-iceberg-teardown + oracle + openspec + gitnexus + github
---

# UIUE R5 D24 Full Absorption + Route-Control + PR Merge Longrun Dispatch

## 0. Commander Preamble

Read this file first. Do not rely on chat prose alone.

Target execution thread: `019f173c-e34f-75d1-a764-992a9280891d`.

Repos:

- main: `/Users/wanglei/workspace/MAformac`
- UIUE: `/Users/wanglei/workspace/MAformac-uiue`

D24 is a long task. It is not a narrow docs patch and not a direct merge button. The job is to make local truth, cloud PR truth, and dual-repo project evidence converge:

1. Inventory and absorb UIUE project-effective content into a main-traceable surface.
2. Reconcile D20-D23, D22/D23 commander verdicts, route-control, `CURRENT.md`, `README.md`, and grill burndown.
3. Push final exact-path commits/checks to existing PR #7/#6, or create a new D24 review PR only if needed for the cloud GitHub audit/review surface.
4. Merge PR #7 first, then re-probe/update/check/merge PR #6.
5. Verify post-merge local single-surface truth.
6. After D24G, run exactly two execution audit nodes: subagentcodex final audit and GitHub cloud audit.

This dispatch authorizes local implementation, exact-path commits, push to existing PR branches, optional new D24 review PR creation if needed for GitHub cloud audit, GitHub check monitoring, PR #7 ready transition, and PR #7/#6 merge after gates pass. It does not authorize production deployment, branch deletion, tags/releases, runtime-ready claims, mobile/true-device/live claims, or product readiness claims.

The commander pre-send Hermes audit for this dispatch file is outside D24 execution scope and outside the two execution audit nodes. If the worker receives this dispatch without a commander note saying the Hermes pre-send audit passed, stop and ask the commander to provide the audit verdict.

## 0A. First Response Required

Return only this ack first, then start execution:

```yaml
ack:
  label: UIUE_R5_D24_FULL_ABSORPTION_ROUTE_CONTROL_PR_MERGE_LONGRUN
  status: RECEIVED
  mode: executing_plans
  will_reprobe_live_truth: true
  will_execute_D24A_to_D24G_without_mid_audit_nodes: true
  post_D24G_audit_nodes:
    - subagentcodex_final_audit
    - github_cloud_audit
  merge_order:
    - PR_7_MAIN
    - PR_6_UIUE
```

## 1. Operating Mode: Executing Plans

At task start, explicitly announce:

`I'm using the executing-plans skill to implement this plan.`

Then:

1. Load this dispatch as the written plan.
2. Review it critically once.
3. Create todos for D24A-D24G plus the two post-D24G audit nodes.
4. Execute continuously and quickly.
5. Stop only on the stop conditions in this dispatch.

D24A-D24G include quick self-checks, not separate audit nodes. Do not insert Hermes/Codex/GPT/Claude audit gates between A-G. The only execution audit nodes are after D24G:

1. `POST_D24G_AUDIT_1_SUBAGENTCODEX_FINAL_AUDIT`
2. `POST_D24G_AUDIT_2_GITHUB_CLOUD_AUDIT`

If a validation or self-check fails during A-G, fix it in scope and continue. If it cannot be fixed inside scope, stop with `PARTIAL` or `BLOCKED`; do not create an ad hoc audit node.

Risk-skill use during D24A-G is not an audit node. Use `pre-mortem`, `bug-iceberg-teardown`, oracle, OpenSpec and GitNexus as execution disciplines and keep moving unless they reveal an explicit stop condition.

## 1A. Required Skill Contract

The executor must use the following skills/processes explicitly. These are execution disciplines, not proof classes.

### Primary Driver: `executing-plans`

Use `executing-plans` as the top-level mode for the whole D24 run:

- Load this dispatch as the written plan.
- Review the plan once before starting.
- Create todos for D24A-D24G and the two post-D24G audit nodes.
- Mark each stage `in_progress` then `completed` as it finishes.
- Run the listed self-checks and validations.
- Stop only on explicit stop conditions.

Do not convert D24 into a discussion or planning-only task. D24 is execution unless blocked.

### Required Risk Skills: `pre-mortem` And `bug-iceberg-teardown`

Use `pre-mortem` at:

- D24A startup before inventory decisions.
- Before deciding whether broad surfaces such as `Tools/skills`, `Reports`, `.xcodebuildmcp`, `.githooks`, or `docs/research` are absorbed, summarized, dropped, or stopped for user decision.
- Before final PR #7/#6 merge.
- Whenever a step feels like "checks are green so we can proceed".

Use `bug-iceberg-teardown` at:

- Any stale route-control/CURRENT/README contradiction.
- Any docs-only fix that could hide code/CI drift.
- Any mismatch between PR truth, local dirty tree, and manifest truth.
- Any validation failure, PR check failure, stale branch, mergeability change, or GitHub API/push workaround.
- Any post-audit finding from subagentcodex or GitHub cloud audit.

Minimum output in receipts:

```yaml
risk_skills:
  pre_mortem:
    used: true
    tiger: []
    paper_tiger: []
    elephant: []
    mitigation: []
  iceberg_teardown:
    used: true
    visible_symptom: "<symptom>"
    deeper_cause: "<system/process cause>"
    same_class_risk: []
    fix: "<immediate/class/governance fix>"
```

### Oracle / External Truth

Use oracle-style external truth when the question depends on current external behavior or GitHub mechanics:

- GitHub draft PR readiness.
- PR files pagination.
- PR merge/update branch API.
- branch protection or check status behavior.
- merge method constraints.
- GitHub Git Data API push workaround.

Preferred sources:

- GitHub official docs.
- GitHub API response from `gh api`.
- Live PR/check data from `gh pr view`, `gh pr checks`, and paginated PR files API.

Do not use external sources to override local repo authority for project-specific decisions. External oracle answers "how GitHub works"; local repo truth answers "what MAformac/UIUE should do".

### OpenSpec Skills

Use OpenSpec guidance whenever editing or validating:

- `openspec/changes/define-runtime-presentation-bridge/`
- `openspec/changes/define-runtime-adapter-execution/`
- `openspec/changes/ui-presentation/`
- any `openspec/changes/*/tasks.md`

Validation is required after relevant edits:

```bash
openspec validate --all --strict
```

### GitNexus Skills

Use GitNexus before modifying Swift symbols or shared code paths:

- Run impact before editing a function/class/method when applicable.
- Run GitNexus `detect_changes` through the available MCP tool or CLI before commits that include source/test/config changes.
- If the local CLI syntax differs from examples, record the exact command/error and use the available MCP/CLI route.
- If GitNexus is unavailable, record exact error and fallback to `git diff --cached --stat`, targeted tests, and path review. Do not hide the gap.

### GitHub / Finishing Skills

Use GitHub/branch finishing discipline for:

- exact-path staging
- commit hygiene
- push or GitHub API push workaround
- PR #7 ready transition
- PR #7/#6 merge
- optional new D24 review PR for GitHub cloud audit

No `git add .`. No branch deletion.

### Subagent And Cloud Audit Skills

Do not spawn subagent audits during D24A-G. After D24G:

1. Run `subagentcodex` final audit over the whole D24 train.
2. Run GitHub cloud audit/review.

These two are the only execution audit nodes.

### Skill Ledger Requirement

Every D24A-D24G receipt and the final YAML must include:

```yaml
skills_ledger:
  executing_plans: used
  pre_mortem: used_when_triggered | used_at_stage_start | not_needed_with_reason
  bug_iceberg_teardown: used_when_triggered | not_needed_with_reason
  oracle_external_truth: used_for_github | not_needed_with_reason
  openspec: used | not_touched_with_reason
  gitnexus: used | unavailable_with_error | not_code_change
  github: used
  subagentcodex: post_D24G_only
  github_cloud_audit: post_D24G_only
```

## 2. Live Truth Candidates To Re-Probe

These values were live-observed by commander while drafting. They are candidates only. Re-probe before editing, before committing, before pushing, before merge, after #7 merge, and before final YAML.

| repo | path | branch | local HEAD candidate | cloud PR candidate |
|---|---|---|---|---|
| main | `/Users/wanglei/workspace/MAformac` | `codex/rebuild-c6-doc-absorption-20260624` | `f58c006` | PR #7 OPEN, draft=true, CLEAN, checks success, head `7c5c8a8a174da7d5e93ceef4adbae482efa0d5a2`, 139 files |
| UIUE | `/Users/wanglei/workspace/MAformac-uiue` | `uiue/phase4-default-scope-presentation` | `4c7da71` | PR #6 OPEN, draft=false, CLEAN, checks success, head `1b84af5f08bc0ac188c01b53ca888b0eb3d13c1c`, 1130 files |

Known local risk:

- Both worktrees are dirty and ahead of local upstream.
- Normal GitHub git transport has repeatedly timed out on port 443 in this lane; local `origin/*` and `@{u}` may be stale.
- PR #6 is broad and expected to become stale after #7 merges because #6 does not contain #7.
- PR #7/#6 overlap exists in docs, app, core state, fixtures/schema, and bridge spec/docs.

Before editing, run and record:

```bash
git -C /Users/wanglei/workspace/MAformac status --short --branch
git -C /Users/wanglei/workspace/MAformac rev-parse HEAD
git -C /Users/wanglei/workspace/MAformac log --oneline --decorate --max-count=12
gh -R rayw-lab/MAformac pr view 7 --json number,title,headRefName,headRefOid,baseRefName,baseRefOid,state,url,isDraft,mergeStateStatus,statusCheckRollup,updatedAt
gh -R rayw-lab/MAformac api repos/rayw-lab/MAformac/pulls/7/files --paginate --jq '.[].filename'

git -C /Users/wanglei/workspace/MAformac-uiue status --short --branch
git -C /Users/wanglei/workspace/MAformac-uiue rev-parse HEAD
git -C /Users/wanglei/workspace/MAformac-uiue log --oneline --decorate --max-count=12
gh -R rayw-lab/MAformac pr view 6 --json number,title,headRefName,headRefOid,baseRefName,baseRefOid,state,url,isDraft,mergeStateStatus,statusCheckRollup,updatedAt
gh -R rayw-lab/MAformac api repos/rayw-lab/MAformac/pulls/6/files --paginate --jq '.[].filename'
```

If PR truth no longer maps to #7/#6, stop with:

`blocked at D24A after repo/PR reconciliation; only missing updated PR authority`

## 3. Authority And Reading Order

Read first:

1. main `CLAUDE.md`
2. main `docs/CURRENT.md`
3. main `docs/README.md`
4. main `docs/project/phase0/r5-d24-local-cloud-dual-repo-full-absorption-merge-plan-2026-06-30.md`
5. main D20-D23 dispatches under `docs/dispatches/`
6. main D20-D23 receipts/verdicts under `docs/project/phase0/`
7. main `openspec/changes/define-runtime-presentation-bridge/`
8. main `openspec/changes/define-runtime-adapter-execution/`
9. UIUE `CLAUDE.md`
10. UIUE `docs/CURRENT.md`
11. UIUE `docs/README.md`
12. UIUE `docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md`
13. UIUE D12-D23 receipts/dispatches/research discovered by inventory
14. UIUE `openspec/changes/ui-presentation/`

If any authority file is missing, record `missing_file` in the D24A receipt and proceed only if adjacent live repo truth can safely replace it.

## 4. Goal And Non-Goals

### Goal

Complete D24A-D24G:

- Full UIUE absorption manifest and source manifest.
- Main-traceable disposition for UIUE code, tests, CI/CD, docs, route-control, research, reports, tooling, dispatches, and receipts.
- D20-D23 and D22/D23 commander verdict reconciliation.
- Final exact-path commits/pushes/checks for PR #7/#6 or optional new D24 review PR if needed for GitHub cloud audit.
- Merge PR #7 first, then post-#7 update/check/merge PR #6.
- Local post-merge verification.
- Two post-D24G audit nodes.
- Final YAML verdict returned to the commander thread.

### Non-Goals

- No K1 spike implementation.
- No C5/C6 model-quality lane, LoRA training, candidate comparison, golden-run, voice, endpoint, mobile, true-device, live API, production runtime, or product acceptance.
- No `R5_complete`, `A_2_complete`, `runtime_ready`, `V_PASS`, `S_PASS`, `U_PASS`, `voice_ready`, `model_ready`, `golden_ready`, or `endpoint_ready`.
- No branch deletion unless the user explicitly authorizes it later.
- No raw/customer/secret/PII/prohibited material copied into main.
- No fake green: checks green does not equal absorption complete, merge complete does not equal product complete.

## 5. Dirty Tree And Staging Rules

- No `git add .`.
- Stage exact paths only.
- Do not revert, clean, overwrite, or format unrelated dirty files.
- Do not silently absorb `AGENTS.md`/`CLAUDE.md` changes unless D24 explicitly owns them after reading diffs.
- Treat source dispatch drafts as trace artifacts unless D24 explicitly stages them.
- Treat `Reports/` as generated/drop by default unless a manifest row marks a specific file as trackable evidence.
- Treat `.xcodebuildmcp`, `Tools/agent-platform-plugin-refs`, `Tools/skills`, and `Tools/checks` as classify-before-stage surfaces.

Every commit must record:

```bash
git status --short
git diff --name-only
git add -- <exact paths>
git diff --cached --name-only
git diff --cached --check
```

## 6. Required Harness In Each D24A-D24G Receipt

Keep the receipt concise because A-G should move quickly, but every stage must include:

- `using_superpowers_ledger`: include `executing-plans`; include `pre-mortem` and `bug-iceberg-teardown` when used; include GitNexus/OpenSpec/GitHub guidance when relevant.
- `lessons_learned`: one D20-D23/D24 lesson.
- `metacognitive_check`: one unsafe assumption avoided.
- `pre_mortem`: main failure mode for the stage.
- `iceberg_teardown`: visible symptom vs deeper class.
- `local_search`: exact commands or files searched.
- `github_or_web_truth`: PR/API/GitHub docs probes if relevant.
- `goal_drift_check`: confirm no K1/C5/C6/voice/golden/runtime/product drift.
- `authority_check`: which repo docs or specs governed the stage.
- `claim_vs_proof_check`: every claim mapped to proof class.
- `boundary_check`: nonclaims/no-touch.
- `self_question`: "If this were wrong, what file/line/command would prove it?"
- `post_audit_correction_rule`: final audit findings after D24G must be fixed or recorded as residuals.

## 7. D24A-D24G Topology

Strict serial. Do not start D24F merge before D24A-E pass their self-checks.

### D24A - Freeze Truth And Full Inventory

Purpose: capture local/cloud truth and list all candidate content before deciding what to absorb.

Work:

- Re-probe both worktrees and PR #7/#6.
- Enumerate tracked, modified, untracked, and obvious ignored/generated candidates.
- Use GitHub PR files API for #7/#6; `gh pr diff 6` is insufficient because #6 exceeds normal diff limits.
- Build inventory grouped by:
  - code: `App/`, `Core/`
  - tests: `Tests/`, `MAformacIOSUITests/`
  - CI/CD/config: `.github/`, `.githooks/`, `Makefile`, `Package.swift`, `.xcodebuildmcp`, `MAformac.xcodeproj`
  - docs infra/cascade: `docs/CURRENT.md`, `docs/README.md`, `docs/project`, `docs/dispatches`, `docs/roadmaps`, `openspec`
  - research/report: `docs/research`, `Reports`
  - tooling: `Tools/skills`, `Tools/checks`, `Tools/agent-platform-plugin-refs`

Minimum output files:

- `/Users/wanglei/workspace/MAformac/docs/project/phase0/r5-d24-uiue-absorption-manifest-2026-06-30.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-d24-uiue-absorption-source-manifest-2026-06-30.md`

Disposition buckets:

```yaml
disposition:
  - absorb_full
  - absorb_summary_index
  - already_in_pr
  - historical_reference_only
  - generated_drop
  - raw_secret_no_touch
  - requires_user_decision
```

Fast self-check:

- Every changed/untracked UIUE project-effective candidate has a manifest row.
- `requires_user_decision` rows are separated from `raw_secret_no_touch`.
- No merge attempted.

Stop if material unresolved items remain and cannot be classified.

### D24B - Absorb Project-Effective Content Into Main-Traceable Surface

Purpose: make UIUE content discoverable and accountable from main after merge.

Work:

- For each `absorb_full`, land or prove it in PR #7/#6.
- For each `absorb_summary_index`, add a main-traceable index/summary and source pointer.
- For each `already_in_pr`, cite PR file/API evidence.
- For each `historical_reference_only`, cite why it is not current route truth.
- For `generated_drop`, cite ignore/generated rationale.
- For `raw_secret_no_touch`, do not copy. If the content is needed to prove D24, stop.

Default decisions unless evidence says otherwise:

- D20-D24 main dispatch/verdict/receipt docs: `absorb_full`.
- UIUE D12-D19 dispatch trace docs: `historical_reference_only` or `absorb_summary_index`.
- UIUE `docs/research/2026-06-29-visual-acceptance-standard/`: `absorb_summary_index` unless the user explicitly asks for full copy.
- `Reports/`: `generated_drop` unless a specific report is named as trackable evidence.
- `Tools/skills` / `Tools/checks`: classify before deciding; do not bulk stage blindly.

Fast self-check:

- Manifest has no material unresolved row.
- Main docs can locate the absorption manifest.
- No raw/secret/customer material copied.

### D24C - Route-Control, CURRENT/README, D20-D23, Grill Burndown

Purpose: remove stale route truth before cloud merge.

Work:

- Update or reconcile:
  - main `docs/CURRENT.md`
  - main `docs/README.md`
  - UIUE `docs/CURRENT.md`
  - UIUE `docs/README.md`
  - UIUE `docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md`
  - D24 closeout docs in both repos if needed
- Preserve D22 commander truth:
  - `DONE_UNDER_PROOF_CAP / PASS_WITH_NOTES`
  - Claude Code final audit skipped by user override
  - first GPT Pro `REQUEST_CHANGES` fixed post-audit
- Preserve D23 commander truth:
  - `DONE_UNDER_PROOF_CAP / PASS_WITH_NOTES`
  - Hermes/Claude skipped by user override for D23 when applicable
  - advisory review source is user-selected, not gate/proof class
- Fix stale wording such as:
  - pre-D23 blockers still presented as current
  - D20/D21 still presented as current commander route
  - advisory review as proof/gate
  - PR hygiene as merge readiness
  - R5/A-2/runtime/product completion overclaim

Grill accounting to preserve:

```yaml
runtime_grill:
  total_runtime_related_rows: 215
  proof_bearing_rows: 55
  merge_only_rows: 111
  human_decision_rows:
    total: 11
    accepted: 3
    backlog: 8
  k1_future_rows: 8
  f1_future_rows: 29
  drop: 1
```

Fast self-check:

```bash
rg -n "R5_PRECONDITIONS_BLOCKED|not_proposed|pre-D23|pre-D22|REQUEST_CHANGES unresolved|Claude Code final audit required|advisory.*gate|advisory.*proof_class|R5_complete|runtime_ready|V_PASS" \
  /Users/wanglei/workspace/MAformac/docs \
  /Users/wanglei/workspace/MAformac-uiue/docs || true
```

### D24D - Code / CI / OpenSpec Validation And Reconciliation

Purpose: avoid docs-only fake green.

Work:

- Compare and reconcile code/test/CI surfaces:
  - `App/`
  - `Core/`
  - `Tests/`
  - `MAformacIOSUITests/`
  - `MAformac.xcodeproj`
  - `Makefile`
  - `Package.swift`
  - `.github/workflows`
  - `.githooks`
  - `.xcodebuildmcp`
- Decide whether UIUE `verify-contentview-wiring` and main `verify-generated` both belong in the final main surface.
- If editing Swift symbols, run GitNexus impact before editing.
- If only docs changed, still run docs/static checks.

Validation:

```bash
cd /Users/wanglei/workspace/MAformac
git diff --check
openspec validate --all --strict
make verify-ci
swift test
gitnexus detect_changes --scope staged

cd /Users/wanglei/workspace/MAformac-uiue
git diff --check
openspec validate --all --strict
make verify-ci
swift test
gitnexus detect_changes --scope staged
```

If `make verify-ci` or `swift test` is too slow or fails for an unrelated environment reason, run the narrowest relevant commands, record the blocker, and do not overclaim.

Fast self-check:

- Changed code/tests/CI have a corresponding validation statement.
- Source edits have GitNexus or explicit unavailable fallback.
- No local proof promoted to runtime/mobile/live/product proof.

### D24E - Final Commits, Pushes, Checks, Optional D24 Review PR

Purpose: make cloud review/check truth current before merge.

Work:

- Exact-path stage D24-owned changes in each repo.
- Commit with clear subjects.
- Push to existing PR branches #7/#6 when changes belong there.
- If D24 absorption docs need a separate review surface, creating a new D24 PR is allowed. The new PR must be labelled as a review/audit surface and must not replace #7/#6 merge order unless the commander explicitly approves.
- If normal `git push` fails with GitHub 443 timeout, use GitHub Git Data API workaround only with complete before/after SHA evidence.
- Re-run and wait for checks.

Required before/after proof when using API push:

```yaml
api_push_proof:
  local_commit: "<sha>"
  local_tree: "<sha>"
  remote_head_before: "<sha>"
  remote_head_after: "<sha>"
  remote_tree_after: "<sha>"
  pr_head_after: "<sha>"
```

Fast self-check:

- `git diff --cached --name-only` contains exact D24-owned paths only.
- PR #7/#6 remote heads match intended commits.
- Checks green after final push.

### D24F - Cloud Merge: PR #7 Then PR #6

Purpose: execute user-authorized merge sequence.

Authorization:

- PR #7 then PR #6 merge is authorized after D24A-E self-checks pass.
- Branch deletion is not authorized.
- Merge commit is preferred to preserve archaeology. If merge commits are disabled, use squash only after recording the policy failure.

PR #7:

```bash
gh -R rayw-lab/MAformac pr view 7 --json number,state,isDraft,headRefOid,baseRefOid,mergeStateStatus,statusCheckRollup
gh -R rayw-lab/MAformac pr checks 7 --watch
gh -R rayw-lab/MAformac pr ready 7
gh -R rayw-lab/MAformac pr merge 7 --merge --delete-branch=false
gh -R rayw-lab/MAformac pr view 7 --json number,state,mergedAt,mergeCommit,headRefOid,baseRefName,url
gh -R rayw-lab/MAformac api repos/rayw-lab/MAformac/commits/main --jq '{sha:.sha,date:.commit.committer.date,message:.commit.message}'
```

If `--merge` is disabled:

```bash
gh -R rayw-lab/MAformac pr merge 7 --squash --delete-branch=false
```

PR #6 after #7:

```bash
gh -R rayw-lab/MAformac pr view 6 --json number,state,isDraft,headRefOid,baseRefOid,mergeStateStatus,statusCheckRollup
```

If #6 is stale, update by merging new base into the PR branch if clean. Prefer non-rewrite update. If GitHub update-branch API is used, include `expected_head_sha`.

Then:

```bash
gh -R rayw-lab/MAformac pr checks 6 --watch
gh -R rayw-lab/MAformac pr merge 6 --merge --delete-branch=false
gh -R rayw-lab/MAformac pr view 6 --json number,state,mergedAt,mergeCommit,headRefOid,baseRefName,url
gh -R rayw-lab/MAformac api repos/rayw-lab/MAformac/commits/main --jq '{sha:.sha,date:.commit.committer.date,message:.commit.message}'
```

Fast self-check:

- #7 state `MERGED`.
- #6 was re-probed after #7.
- #6 checks green after any required update.
- #6 state `MERGED`.
- No branch deletion.

### D24G - Local Post-Merge Single-Surface Verify And Receipts

Purpose: prove the local final surface is discoverable.

Preferred:

- Safely update `/Users/wanglei/workspace/MAformac` to merged main only if its worktree state is safe.

Fallback:

```bash
git -C /Users/wanglei/workspace/MAformac worktree add /Users/wanglei/workspace/MAformac-r5-postmerge-verify origin/main
```

Verify in the current main repo or fallback worktree:

- D24 absorption manifest exists.
- D24 route-control/merge closeout exists.
- D20-D23 and D22/D23 verdict facts are discoverable.
- UIUE code/docs/research/report/tooling dispositions are discoverable.
- No entry doc claims R5 complete, runtime ready, mobile, true-device, live API, V/S/U PASS, voice/model/golden/endpoint ready.

Write closeouts:

- `/Users/wanglei/workspace/MAformac/docs/project/phase0/r5-d24-route-control-pr-merge-closeout-2026-06-30.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-d24-route-control-pr-merge-closeout-uiue-2026-06-30.md` if UIUE receives D24 changes

Fast self-check:

- Local post-merge surface path recorded.
- Final closeout distinguishes absorption+merge from product readiness.
- Final YAML has exact commits, checks, merges, residuals, and nonclaims.

## 8. Post-D24G Audit Nodes

These are the only execution audit nodes.

### POST_D24G_AUDIT_1_SUBAGENTCODEX_FINAL_AUDIT

Run after D24G local receipt is written.

Scope:

- all D24 touched paths
- absorption manifests
- route-control/CURRENT/README
- code/CI validation evidence
- exact staged/committed/pushed paths
- PR #7/#6 merge evidence
- local post-merge verification
- no-claim discipline
- dirty split/no-touch

Output:

```yaml
codex_subagent_final_audit:
  verdict: PASS | PASS_WITH_NOTES | REQUEST_CHANGES | BLOCKED
  p0: []
  p1: []
  p2: []
  evidence:
    - "<path or command>"
```

If P0/P1 or `REQUEST_CHANGES`, fix owned issues if possible, rerun relevant local validation, and record `fixed_post_subagent_audit`. Do not invent a third audit node unless the commander asks.

### POST_D24G_AUDIT_2_GITHUB_CLOUD_AUDIT

Run after the subagentcodex audit and any owned fixes.

Allowed surfaces:

- Existing PR #7/#6 if GitHub still exposes useful review state.
- A new D24 review PR if needed to expose final D24 changes/receipts to cloud GitHub review. This new PR is allowed by user instruction, but must be labelled as D24 review/audit surface and must not silently change the #7 -> #6 merge order.
- GitHub API/check/PR review evidence on the merged base if #7/#6 are already merged.

Output:

```yaml
github_cloud_audit:
  verdict: PASS | PASS_WITH_NOTES | REQUEST_CHANGES | BLOCKED
  surface: PR_7 | PR_6 | NEW_D24_REVIEW_PR | MERGED_MAIN_API
  url: "<url>"
  p0: []
  p1: []
  p2: []
```

If GitHub cloud audit reports P0/P1, fix-forward with exact paths and push a follow-up PR or commit only if safe. If not safe, stop as `PARTIAL` with exact blockers.

## 9. GitHub And External Oracle Rules

Use GitHub official behavior as operational truth:

- Draft PRs cannot be merged until marked ready.
- PR files API is paginated; use `--paginate` for #6.
- Merge/update branch operations must guard expected head SHA when using API.
- `mergeStateStatus=CLEAN` before #7 does not prove #6 remains clean after #7.

Do not rely on local `origin/main` when fetch is failing.

## 10. Required Final YAML

Return final YAML to the commander thread and execution thread:

```yaml
label: UIUE_R5_D24_FULL_ABSORPTION_ROUTE_CONTROL_PR_MERGE_LONGRUN
status: DONE_UNDER_PROOF_CAP | PARTIAL | BLOCKED
verdict: PASS_WITH_NOTES | REQUEST_CHANGES | BLOCKED
completed_at: "<ISO-8601 with timezone>"
execution_mode: executing_plans

repos:
  main:
    path: /Users/wanglei/workspace/MAformac
    branch_before: codex/rebuild-c6-doc-absorption-20260624
    local_head_before: "<sha>"
    d24_commits:
      - "<sha> # <subject>"
    pr7:
      url: https://github.com/rayw-lab/MAformac/pull/7
      head_before: "<sha>"
      head_after_push: "<sha>"
      draft_before: true
      merged: true | false
      merge_method: merge | squash | none
      merge_commit: "<sha or null>"
      base_head_after_merge: "<sha or null>"
  uiue:
    path: /Users/wanglei/workspace/MAformac-uiue
    branch_before: uiue/phase4-default-scope-presentation
    local_head_before: "<sha>"
    d24_commits:
      - "<sha> # <subject>"
    pr6:
      url: https://github.com/rayw-lab/MAformac/pull/6
      head_before: "<sha>"
      head_after_push: "<sha>"
      stale_after_pr7: true | false
      updated_after_pr7: true | false
      checks_after_update: SUCCESS | FAIL | SKIPPED_WITH_REASON
      merged: true | false
      merge_method: merge | squash | none
      merge_commit: "<sha or null>"
      base_head_after_merge: "<sha or null>"

absorption:
  main_manifest: /Users/wanglei/workspace/MAformac/docs/project/phase0/r5-d24-uiue-absorption-manifest-2026-06-30.md
  uiue_source_manifest: /Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-d24-uiue-absorption-source-manifest-2026-06-30.md
  unresolved_material_items: []
  disposition_counts:
    absorb_full: 0
    absorb_summary_index: 0
    already_in_pr: 0
    historical_reference_only: 0
    generated_drop: 0
    raw_secret_no_touch: 0
    requires_user_decision: 0

stages:
  D24A_FREEZE_TRUTH_AND_FULL_INVENTORY:
    verdict: PASS | FAIL | SKIPPED
    evidence: []
  D24B_ABSORB_PROJECT_EFFECTIVE_CONTENT:
    verdict: PASS | FAIL | SKIPPED
    evidence: []
  D24C_ROUTE_CONTROL_AND_GRILL_RECONCILE:
    verdict: PASS | FAIL | SKIPPED
    evidence: []
  D24D_CODE_CI_OPENSPEC_VALIDATION:
    verdict: PASS | FAIL | SKIPPED
    evidence: []
  D24E_FINAL_COMMITS_PUSH_CHECKS_OPTIONAL_PR:
    verdict: PASS | FAIL | SKIPPED
    evidence: []
  D24F_CLOUD_MERGE_PR7_THEN_PR6:
    verdict: PASS | FAIL | SKIPPED
    evidence: []
  D24G_LOCAL_POSTMERGE_VERIFY:
    verdict: PASS | FAIL | SKIPPED
    evidence: []

post_D24G_audits:
  subagentcodex_final_audit:
    verdict: PASS | PASS_WITH_NOTES | REQUEST_CHANGES | BLOCKED
    p0: []
    p1: []
    p2: []
  github_cloud_audit:
    verdict: PASS | PASS_WITH_NOTES | REQUEST_CHANGES | BLOCKED
    surface: "<PR_7|PR_6|NEW_D24_REVIEW_PR|MERGED_MAIN_API>"
    url: "<url or null>"
    p0: []
    p1: []
    p2: []

validation:
  main:
    - command: "<command>"
      result: PASS | FAIL | SKIPPED_WITH_REASON
  uiue:
    - command: "<command>"
      result: PASS | FAIL | SKIPPED_WITH_REASON
  github:
    - command: "<command/API>"
      result: PASS | FAIL | SKIPPED_WITH_REASON

dirty_split:
  main_owned_for_d24: []
  main_preserve_unowned_dirty: []
  uiue_owned_for_d24: []
  uiue_preserve_unowned_dirty: []
  staging_rule: exact_paths_only_no_git_add_dot

grill_burndown:
  total_runtime_related_rows: 215
  proof_bearing_rows: 55
  merge_only_rows: 111
  human_decision_rows:
    total: 11
    accepted: 3
    backlog: 8
  k1_future_rows: 8
  f1_future_rows: 29
  drop: 1

non_claims:
  - no production_runtime
  - no runtime_ready
  - no mobile
  - no true_device
  - no live_api
  - no V_PASS
  - no S_PASS
  - no U_PASS
  - no A_2_complete
  - no R5_complete
  - no voice_ready
  - no model_ready
  - no golden_ready
  - no endpoint_ready
  - no branch_deletion
```

## 11. Stop Conditions

Stop with `PARTIAL` or `BLOCKED` if:

- Material `requires_user_decision` remains after D24B.
- A raw/secret/customer/no-touch file is needed to prove D24.
- Code/CI validation fails and cannot be fixed in D24 scope.
- PR #7 cannot be marked ready or merged.
- PR #6 cannot be cleanly updated/rechecked after #7.
- GitHub API/push/merge remote truth cannot be verified.
- Branch deletion, destructive history rewrite, or unrelated dirty overwrite would be required.
- Post-D24G subagentcodex or GitHub cloud audit reports P0/P1 that cannot be fixed safely.

Use exact blocker language:

`blocked at D24<stage> after attempts <A/B/C>; only missing <minimal external condition>`

## 12. Final Reminder

D24 success means absorption + route-control + cloud PR merge + local post-merge verification under proof cap. It does not mean R5 complete or runtime/product readiness. K1/F1/front-back-training-complete work remains future scope.

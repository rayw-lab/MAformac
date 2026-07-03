---
label: UIUE_R5_D24_FULL_ABSORPTION_ROUTE_CONTROL_PR_MERGE_SUPERTRAIN
status: DISPATCH_DRAFT_REQUIRES_CODEX_SUBAGENT_AUDIT_BEFORE_SEND
target_thread_id: 019f13bc-ce36-7fe2-bc3f-49f703c0a81b
created_at: "2026-06-30T15:25:00+08:00"
commander_mode: dispatch
proof_class_ceiling: local_static + docs_local + code_local + openspec_local + local_unit + local_ci_equivalent + github_api_remote_truth + github_checks + authorized_pr_merge_operation
merge_authorization: USER_AUTHORIZED_PR7_THEN_PR6_ONLY_AFTER_LOCAL_UIUE_ABSORPTION_PROOF
advisory_review_policy: user_selected_advisory_reviews_are_not_gates_and_not_proof_class
source_thread_scope: commander_dispatch_only
skills_required:
  - pre-mortem
  - bug-iceberg-teardown
---

# R5 D24 Full UIUE Absorption + Route-Control + PR Merge Supertrain Dispatch

接收线程：`019f13bc-ce36-7fe2-bc3f-49f703c0a81b`

## 0. First Response Required

收到后先只回一条 ack，不要立刻改文件：

```yaml
ack:
  label: UIUE_R5_D24_FULL_ABSORPTION_ROUTE_CONTROL_PR_MERGE_SUPERTRAIN
  status: RECEIVED
  will_reprobe_live_truth: true
  will_inventory_uiue_tracked_untracked_code_docs_reports_research_cicd: true
  will_not_merge_before_absorption_and_checks_green: true
  merge_order: [PR_7_MAIN, PR_6_UIUE]
```

然后按本派单执行。不要把旧 thread 记忆、旧 receipt、GPT/Claude/Codex 审计 prose 当成当前真态；每个 gate 都必须重新 probe repo、PR、checks、dirty tree、目标文件内容和 UIUE 本地未提交/未跟踪内容。

## 1. Objective

D24 不只是“最后合并”。D24 的核心目标是：

> 让本地 `/Users/wanglei/workspace/MAformac` 成为能够吸收 `/Users/wanglei/workspace/MAformac-uiue` 全量项目有效内容的单一主线工作面，并在云端按顺序合并 PR #7 与 PR #6。

必须同时覆盖：

1. **UIUE 全量吸收账本。**
   对 UIUE 的 tracked、modified、untracked 内容做全量盘点，分类为 code、tests、CI/CD、docs infra、docs cascade、reports、research、dispatch/receipt、generated/ignored、raw/secret/no-touch。项目有效内容不能因为“没有被 git 跟踪”而被遗漏。
2. **代码吸收。**
   UIUE 中属于 R5/route-control/bridge/runtime presentation 的代码、测试、配置、脚本、CI/CD 变化必须被纳入 PR #6 或被明确证明已经在 PR #7/remote main 中。涉及 symbol 修改时按 MAformac GitNexus 规则做 impact/detect_changes。
3. **文档与研究吸收。**
   UIUE 的 reports、research、文档基建、文档级联、roadmap、dispatch/receipt 中项目有效内容必须在 main repo 有归宿：直接纳入、迁移摘要、索引引用、或 no-touch/过期/drop 分类。不能 merge 后只剩线程口头记忆。
4. **D20-D23/D23 commander verdict/route-control/CURRENT.md 对齐。**
   把 D20-D23、D23 commander verdict、route-control、`CURRENT.md` 对齐，避免 merge 后真态散在两个 repo/线程里。
5. **最后 docs/code/CI commits + PR checks。**
   对 PR #7/#6 推最后一轮 exact-path commits；如果普通 `git push` 继续 `github.com:443` timeout，可以使用 GitHub Git Data API workaround，但必须验证 remote head/tree/checks。
6. **云端 PR merge。**
   顺序固定：先 PR #7 main，再 PR #6 UIUE。PR #7 先取消 draft。只有吸收账本、必要内容纳入、CI/checks 和 pre-merge audit 都绿之后才能 merge。

## 2. Updated Time Expectation

用户最初估算的 45-90 + 30-60 + 15-30 分钟只适用于“账本+最后 docs commit+merge”。现在 scope 扩展到 full UIUE absorption + code + CI/CD，因此 D24 要按风险分段：

- Gate 1 全量盘点：约 45-90 分钟。
- Gate 2 吸收与迁移：约 60-180 分钟，取决于 UIUE 未跟踪内容和 code/CI 差异。
- Gate 3 route-control/CURRENT 对齐：约 30-60 分钟。
- Gate 4 final commits/push/checks：约 30-90 分钟。
- Gate 5 merge：约 15-45 分钟。

如果 Gate 1/Gate 2 发现大量未纳入代码、CI/CD 或研究资产，不允许为了赶 merge 把它们标成“后续”。必须给出 `PARTIAL_ABSORPTION_INVENTORY_READY_NO_MERGE` 或明确的 backlog 分类与用户授权。

## 3. Non-Goals

D24 不做以下事项：

- 不实现 K1/F1/C5/C6 新功能，不做完整前后端+训练一体开发。
- 不把吸收/合并升格成 `R5_complete`、`A_2_complete`、`runtime_ready`、`voice_ready`、`golden_ready`、`mobile`、`true_device`、`live_api`、`V_PASS`、`S_PASS`、`U_PASS`。
- 不新开 PR，不关闭后重开 PR，不 merge 任何非 `#7/#6` PR。
- 不把用户指定的异源审计写成 gate、proof class 或 merge blocker；它只能是 advisory record，除非用户另行明确授权。
- 不复制 RAW、secret、PII、客户原文、禁止外传材料进仓。
- 不删除远端分支，除非用户另行明确授权。

## 4. Live Truth Baseline To Reprobe

下面是 commander dispatch 时的候选基线，只能作为待复核输入：

### main repo

- Path: `/Users/wanglei/workspace/MAformac`
- Branch: `codex/rebuild-c6-doc-absorption-20260624`
- Local HEAD observed by commander: `f58c006498766a49b607ed8cfb70c8ffb4ae9ac2`
- PR: <https://github.com/rayw-lab/MAformac/pull/7>
- PR #7 observed state:
  - `state: OPEN`
  - `isDraft: true`
  - `mergeStateStatus: MERGEABLE`
  - checks: success
  - remote head observed: `7c5c8a8a174da7d5e93ceef4adbae482efa0d5a2`
- Commander-observed dirty split:
  - Modified: `AGENTS.md`, `CLAUDE.md`, `docs/CURRENT.md`, `docs/README.md`
  - Untracked: `.xcodebuildmcp/`, `Tools/agent-platform-plugin-refs/`, D20-D24 dispatch trace docs, D22/D23 commander verdict docs

### UIUE repo

- Path: `/Users/wanglei/workspace/MAformac-uiue`
- Branch: `uiue/phase4-default-scope-presentation`
- Local HEAD observed by commander: `4c7da7167a64f79839327d9f11d633aa2948f171`
- PR: <https://github.com/rayw-lab/MAformac/pull/6>
- PR #6 observed state:
  - `state: OPEN`
  - `isDraft: false`
  - `mergeStateStatus: MERGEABLE`
  - checks: success
  - remote head observed: `1b84af5f08bc0ac188c01b53ca888b0eb3d13c1c`
- Commander-observed dirty split:
  - Modified: `AGENTS.md`, `CLAUDE.md`, `docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md`
  - Untracked: D12-D19 dispatch trace docs, `docs/research/2026-06-29-visual-acceptance-standard/`

You must re-run all probes before acting. If current truth differs, record the delta and proceed only if it still fits D24 scope.

## 5. Authority And Reading Order

Read in this order before editing:

1. `/Users/wanglei/workspace/MAformac/CLAUDE.md`
2. `/Users/wanglei/workspace/MAformac/docs/CURRENT.md`
3. `/Users/wanglei/workspace/MAformac/docs/README.md`
4. `/Users/wanglei/workspace/MAformac/docs/dispatches/2026-06-29-uiue-r5-d20-d21-runtime-uiue-integration-pr-supertrain-dispatch.md`
5. `/Users/wanglei/workspace/MAformac/docs/dispatches/2026-06-30-uiue-r5-d22-runtime-payload-corpus-expansion-supertrain-dispatch.md`
6. `/Users/wanglei/workspace/MAformac/docs/dispatches/2026-06-30-uiue-r5-d23-shared-schema-checker-pr-hygiene-dispatch.md`
7. `/Users/wanglei/workspace/MAformac/docs/project/phase0/r5-d22-runtime-payload-corpus-expansion-commander-verdict-2026-06-30.md`
8. `/Users/wanglei/workspace/MAformac/docs/project/phase0/r5-d23-shared-schema-checker-commander-verdict-2026-06-30.md`
9. `/Users/wanglei/workspace/MAformac-uiue/CLAUDE.md`
10. `/Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md`
11. UIUE all changed/untracked candidate files discovered by Gate 1 inventory

If any listed file is missing, do not invent its contents. Record `missing_file` in Gate 1 receipt and use live repo truth from adjacent files only.

## 6. Scope Contract

### Scope In

- UIUE full-content inventory across tracked, modified, untracked and ignored candidate artifacts.
- Migration/absorption manifest in main repo.
- Copy/move/summarize/index UIUE project-effective docs, reports, research, dispatches, receipts and documentation infrastructure into main repo or PR #6, with provenance.
- Code/test/config/CI/CD absorption where UIUE contains unique project-effective changes.
- Docs-only route-control and ledger alignment across D20-D23.
- D23 commander verdict reconciliation into current project routing docs.
- Final commits on existing branches for PR #7 and #6.
- PR #7 readiness transition from draft to ready after absorption and checks are green.
- Authorized merge operation for PR #7, then PR #6.
- Post-merge local verification that `/Users/wanglei/workspace/MAformac` or an explicitly named post-merge worktree contains the absorbed UIUE content. If only a separate worktree is verified, mark it explicitly and do not claim the current folder is updated unless it is.

### Scope Out

- New runtime feature work outside absorption.
- New model/training work.
- New OpenSpec semantic proposals unless absorption proves an existing spec/task must be updated to avoid a false route-control claim.
- Any merge outside PR #7/#6.

### Writable Paths

Only edit exact paths that are necessary for D24 absorption, route-control and closeout.

Main candidate paths:

- `/Users/wanglei/workspace/MAformac/docs/CURRENT.md`
- `/Users/wanglei/workspace/MAformac/docs/README.md`
- `/Users/wanglei/workspace/MAformac/docs/project/phase0/r5-d22-runtime-payload-corpus-expansion-commander-verdict-2026-06-30.md`
- `/Users/wanglei/workspace/MAformac/docs/project/phase0/r5-d23-shared-schema-checker-commander-verdict-2026-06-30.md`
- `/Users/wanglei/workspace/MAformac/docs/project/phase0/r5-d24-uiue-absorption-manifest-2026-06-30.md`
- `/Users/wanglei/workspace/MAformac/docs/project/phase0/r5-d24-route-control-pr-merge-closeout-2026-06-30.md`
- Project-effective copied/indexed UIUE docs/reports/research under the existing main docs structure
- Code/test/config/CI/CD paths only if Gate 1 proves they are unique UIUE project-effective content and GitNexus/impact checks have been run where applicable

UIUE candidate paths:

- `/Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-d24-uiue-absorption-source-manifest-2026-06-30.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-d24-route-control-pr-merge-closeout-uiue-2026-06-30.md`
- UIUE reports/research/dispatches/docs infra/code/test/CI files classified as project-effective and not already tracked in PR #6

### No-Touch Paths

- RAW/source materials, secrets, PII, customer-identifying content, prohibited internal originals.
- `.xcodebuildmcp/` unless current repo authority explicitly says it is intended for this PR.
- `Tools/agent-platform-plugin-refs/` unless classified as project-effective and safe to version.
- `AGENTS.md` and `CLAUDE.md` in both repos unless you can prove the dirty changes are D24-owned. Default is preserve unowned.
- Generated caches/build artifacts.
- Any external production setting, token, keychain, browser profile or device state.

## 7. Dirty Tree Rules

- No `git add .`.
- Stage exact paths only.
- Before staging, produce a dirty split:
  - `owned_for_D24_absorption`
  - `owned_for_D24_route_control`
  - `preserve_unowned_dirty`
  - `ignored_existing_untracked`
  - `no_touch_or_secret_excluded`
- Do not revert or overwrite user/other-agent edits.
- If an unowned dirty file is necessary to finish D24, stop and report the exact file and conflict. Do not silently absorb it.
- Before each commit, run `git diff --cached --name-only` and verify it contains only D24-owned paths.

## 8. Required Harness For Every Gate Receipt

Every gate receipt must include these sections, even if concise:

- `using_superpowers_ledger`: include `pre-mortem` and `bug-iceberg-teardown`; state if other skills/tools were not needed.
- `lessons_learned`: at least one D20-D23 or D24 lesson carried forward.
- `metacognitive_check`: what assumption was tempting but unsafe.
- `pre_mortem`: failure modes, tiger/paper-tiger/elephant, and mitigations.
- `local_search`: exact `rg`/file probes run.
- `web_or_github_search`: GitHub/API/PR probes run; web search is optional unless needed.
- `iceberg_teardown`: visible symptom vs deeper system/process issue.
- `goal_drift_check`: confirm the gate did not slide into new feature/training/future work.
- `authority_check`: current repo authority and stale candidate handling.
- `claim_vs_proof_check`: every claim mapped to proof class.
- `boundary_check`: nonclaims and no-touch confirmation.
- `self_question`: one hard question asked before declaring PASS.
- `post_audit_correction_rule`: if review finds P0/P1/send-blocking issue, fix and rerun affected validation before continuing.

## 9. Pre-Mortem: Known High-Risk Failure Modes

Treat these as live D24 risks, not generic boilerplate:

### Tiger

1. **Cloud merge green but local absorption incomplete.**
   PR checks can pass while UIUE local untracked research/reports/docs infra/code never enter main. Mitigation: Gate 1 inventory tracked + untracked + ignored candidates; Gate 2 absorption manifest; Gate 6 post-merge local verification.
2. **Docs-only route-control hides code/CI drift.**
   D24 could polish `CURRENT.md` while UIUE code, tests, Makefile, Package.swift, scripts or `.github/workflows` remain unique. Mitigation: code/CI diff map, GitNexus impact for symbol edits, local CI-equivalent tests before merge.
3. **PR #6 becomes stale after PR #7 merge.**
   PR #6 may be mergeable before #7 but conflict or require branch update after #7 lands. Mitigation: re-probe #6 after #7 merge, update only if clean, rerun checks, stop on conflict.
4. **Absorbing raw or prohibited material.**
   UIUE research/report folders may contain raw, customer, secret or internal-only material. Mitigation: classify before copy; only abstract/summarize safe content.
5. **False `R5 complete` upgrade.**
   Merge completion can be misread as runtime/product completion. Mitigation: nonclaims in every receipt and final YAML.

### Paper-Tiger Candidates To Prove Or Refute

- Existing PR checks may already cover all code/CI differences. Prove by listing workflows/checks and changed code paths.
- UIUE untracked dispatch/research may be historical evidence only. Prove by reading and classifying, not by ignoring.
- Main D22/D23 commander verdicts may already cover route-control. Prove by grep and file references.

### Elephant

The uncomfortable system issue is that R5 truth has been split across two local repos, two PRs, multiple dispatch threads, untracked docs/research artifacts, and advisory audits with non-gate status. D24 must repair the process by making a single absorption manifest and post-merge verification surface, not by adding one more prose summary.

## 10. Bug Iceberg Teardown Frame

Visible symptom:

```text
D20-D23 progress is scattered across MAformac, MAformac-uiue, commander verdicts, route-control docs, PR bodies and thread transcripts.
```

Expected chain:

```text
UIUE implementation/docs/research/code/CI evidence
→ classified absorption manifest
→ project-effective content committed to PR #6/#7
→ route-control/CURRENT/README point to the same truth
→ GitHub checks prove reviewable heads
→ PR #7 then PR #6 merge
→ local MAformac single surface verifies absorbed content
```

Observed risk:

```text
PRs may be green while local-only UIUE artifacts and code/CI deltas stay outside the eventual main surface.
```

Hidden seams:

- tracked vs untracked artifacts
- docs evidence vs code/test/CI reality
- route-control claim vs PR remote head truth
- advisory audit vs gate/proof-class
- local worktree truth vs cloud merge state

Same-class risk map:

| Direction | Risk | Required D24 Control |
|---|---|---|
| Code | Unique UIUE code/test/config not included in main | diff inventory + GitNexus/targeted tests |
| CI/CD | Workflow/build scripts diverge | `.github`, Makefile, Package, scripts comparison + CI checks |
| Docs infra | Docs map/CURRENT/README stale | route-control grep + docs cascade |
| Research/reports | Local evidence disappears after merge | absorption manifest + safe copy/index/drop rationale |
| PR operations | #6 stale after #7 merge | serial post-#7 probe + checks rerun |
| Claims | Merge becomes fake R5 complete | final YAML nonclaims |

## 11. Gate Topology

D24 is serial. Do not start merge before Gate 1-5 pass.

### D24_GATE_1_UIUE_FULL_INVENTORY_AND_CLASSIFICATION

Purpose: make every UIUE artifact visible before deciding what to absorb.

Required work:

- Inventory both repos:
  - tracked differences
  - modified tracked files
  - untracked files/directories
  - ignored/generated candidates, if any obvious project artifacts exist
- Classify every UIUE candidate as:
  - `absorb_code`
  - `absorb_tests`
  - `absorb_cicd`
  - `absorb_docs_infra`
  - `absorb_docs_cascade`
  - `absorb_report`
  - `absorb_research`
  - `absorb_dispatch_or_receipt`
  - `historical_reference_only`
  - `generated_or_cache_drop`
  - `raw_secret_no_touch`
  - `already_in_pr7_or_pr6`
  - `requires_user_decision`
- Produce the main absorption manifest:
  - `/Users/wanglei/workspace/MAformac/docs/project/phase0/r5-d24-uiue-absorption-manifest-2026-06-30.md`
- Produce UIUE source manifest if UIUE repo receives a commit:
  - `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-d24-uiue-absorption-source-manifest-2026-06-30.md`

Required probes:

```bash
cd /Users/wanglei/workspace/MAformac
git status --short --branch
git rev-parse HEAD
git ls-files
git ls-files --others --exclude-standard
find . -maxdepth 3 -type f | sed 's#^\./##' | sort > /tmp/maformac-files.txt

cd /Users/wanglei/workspace/MAformac-uiue
git status --short --branch
git rev-parse HEAD
git ls-files
git ls-files --others --exclude-standard
find . -maxdepth 3 -type f | sed 's#^\./##' | sort > /tmp/maformac-uiue-files.txt

comm -3 /tmp/maformac-files.txt /tmp/maformac-uiue-files.txt || true
```

Use `rg --files` as the faster default where possible; `find` is acceptable for an inventory file list.

Also compare known high-risk areas:

```bash
diff -qr /Users/wanglei/workspace/MAformac/.github /Users/wanglei/workspace/MAformac-uiue/.github || true
diff -qr /Users/wanglei/workspace/MAformac/Sources /Users/wanglei/workspace/MAformac-uiue/Sources || true
diff -qr /Users/wanglei/workspace/MAformac/Tests /Users/wanglei/workspace/MAformac-uiue/Tests || true
diff -qr /Users/wanglei/workspace/MAformac/docs /Users/wanglei/workspace/MAformac-uiue/docs || true
diff -qr /Users/wanglei/workspace/MAformac/openspec /Users/wanglei/workspace/MAformac-uiue/openspec || true
```

If a path does not exist, record it; do not fail solely for absence.

Pass condition:

- There is a manifest row for every UIUE changed/untracked project-relevant candidate.
- Code, tests, CI/CD, docs infra, docs cascade, reports, research and dispatch/receipt are explicitly classified.
- `raw_secret_no_touch` and `requires_user_decision` are separated.
- No merge is attempted in this gate.

### D24_GATE_2_UIUE_ABSORPTION_INTO_MAIN_SURFACE

Purpose: ensure project-effective UIUE content has a main-surface destination before merge.

Required work:

- For every Gate 1 item classified `absorb_*`, either:
  - commit it into PR #6, or
  - copy/index/summarize it into PR #7/main docs, or
  - prove it already exists in PR #7/PR #6 remote head, or
  - record `requires_user_decision` and stop before merge if it is material.
- For code/test/config/CI/CD absorption:
  - run GitNexus impact before editing symbols where applicable
  - preserve existing project patterns
  - add or rerun targeted tests
  - run `gitnexus detect_changes --scope staged` before commit
- For docs/research/report absorption:
  - preserve provenance
  - avoid raw/customer/secret content
  - use summaries/indexes if full copy is unsafe
  - update docs maps so future agents can find the material
- For CI/CD:
  - compare `.github/workflows`, Makefile, Package.swift, scripts and project config
  - if CI files changed, run the closest local equivalent and rely on GitHub checks after push

Required validation:

```bash
cd /Users/wanglei/workspace/MAformac
git diff --check
openspec validate --all --strict
gitnexus detect_changes --scope staged

cd /Users/wanglei/workspace/MAformac-uiue
git diff --check
openspec validate --all --strict
gitnexus detect_changes --scope staged
```

If Swift/source/tests changed, run the targeted Swift tests and then the broadest feasible local suite:

```bash
swift test
```

If `swift test` is too slow or blocked, record the exact blocker and run the most relevant `swift test --filter ...` targets. Do not claim code absorption complete without a validation statement.

Pass condition:

- Every project-effective UIUE item has a destination, proof of existing inclusion, or explicit stop-worthy decision record.
- Code/CI changes are validated with appropriate local and GitHub checks.
- No material `requires_user_decision` item remains if merge is to proceed.

### D24_GATE_3_ROUTE_CONTROL_AND_GRILL_BURNDOWN_ACCOUNTING

Purpose: make the project ledger coherent after absorption work.

Required work:

- Reconcile D20-D23 dispatch/verdict status into route-control and current docs.
- Ensure D23 commander verdict is represented as:
  - `status: DONE_UNDER_PROOF_CAP`
  - `verdict: PASS_WITH_NOTES`
  - advisory review is user-selected, not gate/proof class
  - Claude Code final audit skipped by user override
  - first GPT Pro `REQUEST_CHANGES` fixed post-audit
- Ensure D22 commander verdict remains:
  - `status: DONE_UNDER_PROOF_CAP`
  - `verdict: PASS_WITH_NOTES`
  - Claude Code final audit skipped by user override
  - first GPT Pro `REQUEST_CHANGES` fixed post-audit
- Align route-control language so D20-D23 are not split across stale thread claims.
- Align `CURRENT.md` so it points to the latest R5 truth and does not present pre-D23 blockers as current.
- Record R5 progress honestly:
  - D20-D23 are proof-capped docs/tests/schema/PR hygiene progress.
  - D24 adds full UIUE absorption and merge operations under proof cap.
  - PR #7/#6 merge readiness is not the same as R5 complete.
- Record grill burndown classification with current known numbers:
  - Total runtime-related grill rows: `215`
  - Proof-bearing rows: `55`
  - Merge-only rows: `111`
  - Human decision rows: `11` (`3` accepted, `8` backlog)
  - K1 future rows: `8`
  - F1 future rows: `29`
  - Drop: `1`
- Do not claim K1/F1 rows are resolved by D24 unless Gate 1/2 produced explicit proof.

Required probes:

```bash
cd /Users/wanglei/workspace/MAformac
rg -n "D20|D21|D22|D23|D24|PR #7|PR #6|route-control|CURRENT|R5|grill|215|DONE_UNDER_PROOF_CAP|PASS_WITH_NOTES|REQUEST_CHANGES|skipped by user override|advisory" docs openspec || true
rg -n "R5_PRECONDITIONS_BLOCKED|not_proposed|pre-D23|pre-D22|REQUEST_CHANGES unresolved|Claude Code final audit required|advisory.*gate|advisory.*proof_class" docs openspec || true

cd /Users/wanglei/workspace/MAformac-uiue
rg -n "D20|D21|D22|D23|D24|PR #7|PR #6|route-control|CURRENT|R5|grill|215|DONE_UNDER_PROOF_CAP|PASS_WITH_NOTES|REQUEST_CHANGES|skipped by user override|advisory" docs openspec || true
rg -n "R5_PRECONDITIONS_BLOCKED|not_proposed|pre-D23|pre-D22|REQUEST_CHANGES unresolved|Claude Code final audit required|advisory.*gate|advisory.*proof_class" docs openspec || true
```

Required validation:

```bash
cd /Users/wanglei/workspace/MAformac
git diff --check -- docs
openspec validate --all --strict

cd /Users/wanglei/workspace/MAformac-uiue
git diff --check -- docs
openspec validate --all --strict
```

Pass condition:

- Route-control and current docs no longer contradict D22/D23 commander verdicts.
- D20-D24 state is readable from repo docs without relying on ephemeral thread memory.
- Grill burn-down is classified without overstating K1/F1/future rows.
- Absorption manifest is linked from the appropriate route/current docs.

### D24_GATE_4_FINAL_COMMITS_PUSH_AND_CHECKS

Purpose: push final absorption/route-control commits to PR #7/#6 and verify remote truth.

Required work:

- Stage exact D24-owned paths only.
- Commit final absorption/docs/code/CI changes in main and UIUE if there are owned changes.
- Push to existing PR heads.
- If normal `git push` fails with `github.com:443` timeout, use the prior GitHub Git Data API push-equivalent workaround only after recording:
  - local commit SHA
  - local tree SHA
  - remote head before
  - remote head after
  - remote tree after
  - proof that remote PR head/tree match intended local commit/tree
- Re-run PR checks and wait for completion.
- Update PR bodies if absorption manifest or final route-control proof needs to be visible to reviewers.

Required staging pattern:

```bash
git diff --name-only
git status --short
git add -- <exact path 1> <exact path 2>
git diff --cached --name-only
git diff --cached --check
```

Required GitNexus/static check:

```bash
gitnexus detect_changes --scope staged
```

Required GitHub probes:

```bash
gh pr view 7 --repo rayw-lab/MAformac --json number,state,isDraft,headRefName,headRefOid,baseRefName,mergeStateStatus,reviewDecision,statusCheckRollup,url
gh pr checks 7 --repo rayw-lab/MAformac --watch
gh pr view 6 --repo rayw-lab/MAformac --json number,state,isDraft,headRefName,headRefOid,baseRefName,mergeStateStatus,reviewDecision,statusCheckRollup,url
gh pr checks 6 --repo rayw-lab/MAformac --watch
```

Pass condition:

- PR #7 and #6 remote heads include final D24 absorption/route-control commits, if any were required.
- Both PRs are open, mergeable or cleanly updateable, and checks success.
- PR #7 is still not merged at this gate; draft cancellation happens at the start of Gate 5.
- Dirty split remains explicit and exact.

### D24_GATE_5_PRE_MERGE_CODEX_SUBAGENT_AUDIT

Purpose: prevent a false green before irreversible merge.

Run a Codex subagent audit if available, read-only:

- Scope:
  - Gate 1 absorption manifest completeness
  - Gate 2 code/docs/research/CI/CD absorption decisions
  - Gate 3 route-control consistency
  - Gate 4 staged paths, commits, PR heads and checks
  - Whether Gate 5 merge is safe to proceed
- Output must include:
  - `verdict: PASS | PASS_WITH_NOTES | REQUEST_CHANGES | BLOCKED`
  - findings by severity
  - exact file/path/PR evidence
  - whether any issue blocks merge

If the audit returns `REQUEST_CHANGES` or any P0/P1/send-blocking issue, fix it and rerun affected validation before merge. If the user explicitly overrides an audit lane, record the override as advisory policy, not proof.

### D24_GATE_6_PR7_PR6_MERGE_SEQUENCE_AND_LOCAL_POSTMERGE_VERIFY

Purpose: execute the user-authorized merge sequence and prove local single-surface absorption.

Authorization:

- User has authorized merging PR #7 first, then PR #6.
- Authorization is conditioned on Gate 1-5 passing.
- This authorization does not extend to any other PR, branch deletion, production deploy, tag/release, or new PR.

Required merge sequence:

1. Re-probe PR #7.
2. If PR #7 is draft, mark ready:

   ```bash
   gh pr ready 7 --repo rayw-lab/MAformac
   ```

3. Re-run PR #7 checks/status after draft transition.
4. Merge PR #7.
5. Verify PR #7 state is `MERGED` and record merge method, merge commit/head SHA, base branch head after merge.
6. Re-probe PR #6 after PR #7 merge.
7. If PR #6 becomes stale or non-mergeable because PR #7 changed base, update/rebase/merge base only if GitHub/repo policy allows a clean update without conflicts; then rerun checks. If conflict appears, stop with `PARTIAL_BLOCKED_AT_GATE_6_PR6_REBASE_CONFLICT`.
8. Merge PR #6 only after it is mergeable and checks success.
9. Verify PR #6 state is `MERGED` and record merge method, merge commit/head SHA, base branch head after merge.

Merge method rule:

- Do not delete branches.
- Prefer the repository's enabled/default merge policy.
- If the CLI requires an explicit method and multiple methods are enabled with no repo policy visible, use `--merge --delete-branch=false` to preserve branch commit history. If merge commits are disabled, retry with `--squash --delete-branch=false` and record the fallback. If both are blocked, stop and report the exact GitHub error.

Required commands/probes:

```bash
gh pr view 7 --repo rayw-lab/MAformac --json number,state,isDraft,headRefOid,baseRefName,mergeStateStatus,reviewDecision,statusCheckRollup,autoMergeRequest,url
gh pr checks 7 --repo rayw-lab/MAformac --watch
gh pr ready 7 --repo rayw-lab/MAformac
gh pr merge 7 --repo rayw-lab/MAformac --merge --delete-branch=false
gh pr view 7 --repo rayw-lab/MAformac --json number,state,mergedAt,mergeCommit,headRefOid,baseRefName,url
gh api repos/rayw-lab/MAformac/commits/main --jq '{sha:.sha, date:.commit.committer.date, message:.commit.message}'

gh pr view 6 --repo rayw-lab/MAformac --json number,state,isDraft,headRefOid,baseRefName,mergeStateStatus,reviewDecision,statusCheckRollup,autoMergeRequest,url
gh pr checks 6 --repo rayw-lab/MAformac --watch
gh pr merge 6 --repo rayw-lab/MAformac --merge --delete-branch=false
gh pr view 6 --repo rayw-lab/MAformac --json number,state,mergedAt,mergeCommit,headRefOid,baseRefName,url
gh api repos/rayw-lab/MAformac/commits/main --jq '{sha:.sha, date:.commit.committer.date, message:.commit.message}'
```

If `--merge` is not allowed:

```bash
gh pr merge <number> --repo rayw-lab/MAformac --squash --delete-branch=false
```

Post-merge local absorption verification:

Preferred path:

```bash
cd /Users/wanglei/workspace/MAformac
git fetch origin main
git status --short --branch
```

If the current `/Users/wanglei/workspace/MAformac` worktree is clean or only contains D24-owned committed changes, update it to the merged base by the safest non-destructive route and verify the absorption manifest paths exist locally.

If the current worktree still contains no-touch/unowned dirty changes, do not overwrite it. Instead create a verification worktree:

```bash
git worktree add /Users/wanglei/workspace/MAformac-r5-postmerge-verify origin/main
```

Then verify the absorption manifest in that worktree. If using this fallback, final status can be `PASS_WITH_NOTES`, but must explicitly say current `/Users/wanglei/workspace/MAformac` was not destructively updated.

Pass condition:

- PR #7 state is `MERGED`.
- PR #6 state is `MERGED`.
- Base branch remote head is recorded after each merge.
- No branch deletion was performed.
- Absorption manifest paths are present in a local main surface.
- Final closeout states this is absorption+PR merge completion only, not product/runtime completion.

## 12. Final YAML Contract

Return the final result in one YAML block:

```yaml
label: UIUE_R5_D24_FULL_ABSORPTION_ROUTE_CONTROL_PR_MERGE_SUPERTRAIN
status: DONE_UNDER_PROOF_CAP | PARTIAL | BLOCKED
verdict: PASS_WITH_NOTES | REQUEST_CHANGES | BLOCKED
completed_at: "<ISO-8601 with timezone>"

repos:
  main:
    path: /Users/wanglei/workspace/MAformac
    branch: codex/rebuild-c6-doc-absorption-20260624
    local_head_before: "<sha>"
    local_commits_d24:
      - "<sha> # <subject>"
    remote_pr: https://github.com/rayw-lab/MAformac/pull/7
    remote_head_before_d24: "<sha>"
    remote_head_after_d24_push: "<sha>"
    merge_state_before_merge: "<state>"
    checks_before_merge: "<summary>"
    pr_state_after_merge: MERGED | NOT_MERGED
    merge_method: merge | squash | rebase | none
    merge_commit: "<sha or null>"
    base_head_after_merge: "<sha or null>"
    local_postmerge_surface: /Users/wanglei/workspace/MAformac | /Users/wanglei/workspace/MAformac-r5-postmerge-verify | none
  uiue:
    path: /Users/wanglei/workspace/MAformac-uiue
    branch: uiue/phase4-default-scope-presentation
    local_head_before: "<sha>"
    local_commits_d24:
      - "<sha> # <subject>"
    remote_pr: https://github.com/rayw-lab/MAformac/pull/6
    remote_head_before_d24: "<sha>"
    remote_head_after_d24_push: "<sha>"
    merge_state_before_merge: "<state>"
    checks_before_merge: "<summary>"
    pr_state_after_merge: MERGED | NOT_MERGED
    merge_method: merge | squash | rebase | none
    merge_commit: "<sha or null>"
    base_head_after_merge: "<sha or null>"

absorption:
  manifest_main: /Users/wanglei/workspace/MAformac/docs/project/phase0/r5-d24-uiue-absorption-manifest-2026-06-30.md
  source_manifest_uiue: "/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-d24-uiue-absorption-source-manifest-2026-06-30.md or null"
  inventory_counts:
    absorb_code: 0
    absorb_tests: 0
    absorb_cicd: 0
    absorb_docs_infra: 0
    absorb_docs_cascade: 0
    absorb_report: 0
    absorb_research: 0
    absorb_dispatch_or_receipt: 0
    historical_reference_only: 0
    generated_or_cache_drop: 0
    raw_secret_no_touch: 0
    already_in_pr7_or_pr6: 0
    requires_user_decision: 0
  material_unresolved_items: []

gates:
  D24_GATE_1_UIUE_FULL_INVENTORY_AND_CLASSIFICATION:
    verdict: PASS | FAIL | SKIPPED
    proof_class: local_static
    evidence:
      - "<path or command evidence>"
  D24_GATE_2_UIUE_ABSORPTION_INTO_MAIN_SURFACE:
    verdict: PASS | FAIL | SKIPPED
    proof_class: docs_local + code_local + local_unit + local_ci_equivalent
    evidence:
      - "<path or command evidence>"
  D24_GATE_3_ROUTE_CONTROL_AND_GRILL_BURNDOWN_ACCOUNTING:
    verdict: PASS | FAIL | SKIPPED
    proof_class: docs_local_static + openspec_local
    evidence:
      - "<path or command evidence>"
  D24_GATE_4_FINAL_COMMITS_PUSH_AND_CHECKS:
    verdict: PASS | FAIL | SKIPPED
    proof_class: git_local + github_api_remote_truth + github_checks
    evidence:
      - "<path or PR evidence>"
  D24_GATE_5_PRE_MERGE_CODEX_SUBAGENT_AUDIT:
    verdict: PASS | PASS_WITH_NOTES | REQUEST_CHANGES | BLOCKED | SKIPPED_WITH_REASON
    evidence:
      - "<audit evidence>"
  D24_GATE_6_PR7_PR6_MERGE_SEQUENCE_AND_LOCAL_POSTMERGE_VERIFY:
    verdict: PASS | FAIL | SKIPPED
    proof_class: authorized_pr_merge_operation + github_api_remote_truth + local_static
    evidence:
      - "<PR #7 merge evidence>"
      - "<PR #6 merge evidence>"
      - "<local postmerge absorption evidence>"

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
  merge_blocking_rows_remaining_after_d24: "<number with explanation>"
  notes:
    - "K1/F1/future rows are not resolved by D24 unless separately proven."

dirty_split:
  main_owned_for_d24:
    - "<path>"
  main_preserve_unowned_dirty:
    - "<path>"
  uiue_owned_for_d24:
    - "<path>"
  uiue_preserve_unowned_dirty:
    - "<path>"
  staging_rule: exact_paths_only_no_git_add_dot

validation:
  main:
    - command: "<command>"
      result: PASS | FAIL | SKIPPED_WITH_REASON
  uiue:
    - command: "<command>"
      result: PASS | FAIL | SKIPPED_WITH_REASON
  github:
    - command: "<command or API>"
      result: PASS | FAIL | SKIPPED_WITH_REASON

post_gate_reviews:
  codex_subagent_pre_merge:
    verdict: PASS | PASS_WITH_NOTES | REQUEST_CHANGES | BLOCKED | NOT_RUN_WITH_REASON
    p0: []
    p1: []
    p2: []
  final_self_audit:
    verdict: PASS | PASS_WITH_NOTES | REQUEST_CHANGES
    notes:
      - "<note>"

lessons_learned:
  - "<lesson>"

metacognitive_notes:
  - "<tempting assumption and correction>"

pre_mortem_resolved:
  - "<failure mode and prevention>"

iceberg_teardown:
  visible_symptom: "R5 truth and UIUE artifacts scattered across two repos, PRs, local dirty trees, and threads."
  deeper_cause: "<process/system cause>"
  repair: "<what D24 changed>"

next_surface_after_merge:
  - "Move post-merge work into one main repo folder/branch only after PR #7/#6 and local absorption verification are complete."
  - "K1/F1/front-back-training-complete work remains future scope and needs a separate dispatch."

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
  - no_new_pr
```

## 13. Stop Conditions

Stop with `PARTIAL` or `BLOCKED` instead of forcing green if:

- Gate 1 finds project-effective UIUE content that has no safe destination.
- Code/CI absorption produces failing tests or ambiguous conflicts.
- A no-touch/raw/secret/customer file appears necessary to finish D24.
- A no-touch or unowned dirty file is required and cannot be safely excluded.
- PR #7 or #6 checks fail after final commit and the failure is not D24-owned.
- PR #6 becomes conflicted/stale after PR #7 merge and cannot be cleanly updated.
- GitHub rejects merge because of required review, branch protection, disabled method, permissions, or draft/check status.
- Remote truth cannot be verified after API push workaround.
- Any command would delete branches, rewrite unrelated history, expose secrets, or touch production.

Use this exact blocker style:

`blocked at D24 Gate <N> after attempts <A/B/C>; only missing <minimal external condition>`

## 14. Dispatch Close

D24 is a full UIUE absorption + route-control + merge-operation dispatch under proof cap. It must make local and cloud truth converge. The merge is allowed only after project-effective UIUE code/docs/reports/research/docs-infra/CI/CD content has been inventoried and either absorbed, proven already present, safely dropped, or explicitly blocked for user decision.

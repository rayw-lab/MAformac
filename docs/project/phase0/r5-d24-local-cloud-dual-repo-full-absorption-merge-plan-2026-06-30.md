---
status: proposed_for_user_review
artifact_kind: d24_merge_plan_not_execution_receipt
authority: commander_planning_candidate
created_at: 2026-06-30
owner: commander
repos:
  main: /Users/wanglei/workspace/MAformac
  uiue: /Users/wanglei/workspace/MAformac-uiue
cloud_prs:
  main_pr: https://github.com/rayw-lab/MAformac/pull/7
  uiue_pr: https://github.com/rayw-lab/MAformac/pull/6
verdict: MERGE_AFTER_GATES
proof_class: local_static + github_api_remote_truth + github_docs_oracle
retire_when: "D24 execution receipt lands, PR #7/#6 are merged or superseded, or user chooses a different merge strategy."
retire_trigger: "Retire when superseded by archived OpenSpec specs or explicit user decision."
expires: "2026-08-15"
---

# R5 D24 本地 + 云端 + 双 Repo 全面吸收合并方案

## 0. 结论

当前不建议直接 merge。正确路线是 `MERGE_AFTER_GATES`：

1. 先把 UIUE 本地与 PR #6 的全量内容做吸收账本。
2. 再补双 repo route-control / `CURRENT.md` / `README.md` / closeout。
3. 再推 #7/#6 最后一轮 exact-path commits 并重跑 checks。
4. 最后按 `PR #7 -> PR #6` 顺序云端合并。
5. 合并后必须在本地验证 `/Users/wanglei/workspace/MAformac` 或干净 post-merge worktree 已能承接 UIUE 全量有效内容。

这里的“全面吸收”不是把 UIUE 全部文件无脑复制进 main，而是每个文件/目录必须有 disposition：`absorb_full`、`absorb_summary_index`、`already_in_pr`、`historical_reference_only`、`generated_drop`、`raw_secret_no_touch`、`requires_user_decision`。

## 1. 当前真态快照

### 1.1 本地 repo

main:

- Path: `/Users/wanglei/workspace/MAformac`
- Branch: `codex/rebuild-c6-doc-absorption-20260624`
- Local HEAD: `f58c006`
- Dirty:
  - modified: `AGENTS.md`, `CLAUDE.md`, `docs/CURRENT.md`, `docs/README.md`
  - untracked: `.xcodebuildmcp/`, `Tools/agent-platform-plugin-refs/`, D20-D24 dispatch 草稿/trace, D22/D23 commander verdict docs
- `git fetch origin main` 在本轮复现 `github.com:443` timeout；本地 `origin/main`/`@{u}` 不可作为最新云端真态。

UIUE:

- Path: `/Users/wanglei/workspace/MAformac-uiue`
- Branch: `uiue/phase4-default-scope-presentation`
- Local HEAD: `4c7da71`
- Dirty:
  - modified: `AGENTS.md`, `CLAUDE.md`, `docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md`
  - untracked: D12-D19 dispatch trace docs, `docs/research/2026-06-29-visual-acceptance-standard/`
- `git fetch origin main` 同样复现 `github.com:443` timeout。

### 1.2 云端 PR

PR #7:

- URL: https://github.com/rayw-lab/MAformac/pull/7
- State: `OPEN`
- Draft: `true`
- Head: `7c5c8a8a174da7d5e93ceef4adbae482efa0d5a2`
- Merge state: `CLEAN`
- Checks: `verify` success
- File count: `139`
- Top-level surface: `.claude`, `App`, `Core`, `Tests`, `Tools`, `contracts`, `docs`, `openspec`, `scripts`, `Makefile`, `CLAUDE.md`, `UBIQUITOUS_LANGUAGE.md`

PR #6:

- URL: https://github.com/rayw-lab/MAformac/pull/6
- State: `OPEN`
- Draft: `false`
- Head: `1b84af5f08bc0ac188c01b53ca888b0eb3d13c1c`
- Merge state: `CLEAN`
- Checks: `verify` success
- File count from GitHub PR files API: `1130`
- Top-level surface:
  - `docs`: `632`
  - `Tools`: `350`
  - `Tests`: `38`
  - `.claude`: `36`
  - `Core`: `24`
  - `Reports`: `16`
  - `App`: `14`
  - `openspec`: `8`
  - plus `.githooks`, `.gitignore`, `.xcodebuildmcp`, `AGENTS.md`, `CLAUDE.md`, `Makefile`, `MAformac.xcodeproj`, `MAformacIOSUITests`
- Local/remote analysis reports PR #7 and #6 diverged; #6 does not include #7 and is expected to become stale after #7 lands.
- Reported overlap: `32` files, including `CLAUDE.md`, `docs/CURRENT.md`, `docs/README.md`, `App/ContentView.swift`, `Core/State/DemoVehicleStateStore.swift`, runtime payload fixtures/schema, bridge spec/docs.

### 1.3 Existing D24 Drafts

Two D24 dispatch drafts exist as intermediate evidence only:

- First draft: too narrow; treated D24 mostly as route-control + docs commit + merge.
- Second draft: directionally closer; includes full UIUE absorption, code, CI/CD, pre-mortem and iceberg teardown, but was written before full diff evidence. It is not final dispatch and was not sent.

## 2. Go / No-Go

Current verdict: `NO_GO_FOR_IMMEDIATE_MERGE`.

Reason:

- PR #7 is still draft.
- Both local worktrees are dirty.
- PR #6 has 1130 files and broad surfaces; current checks green do not prove D24 local absorption is complete.
- PR #6 will require fresh post-#7 mergeability/checks because branches diverged.
- D24 absorption manifest and closeout docs do not exist yet.
- `CURRENT.md` / route-control docs are stale or internally mixed.

Recommended verdict: `MERGE_AFTER_GATES`.

This means the merge sequence is approved as a target, not as an immediate operation.

## 3. Merge Strategy

### 3.1 Recommended Topology

Use three surfaces:

| Surface | Role | Rule |
|---|---|---|
| Local main repo | commander-owned absorption and route-control plan | exact-path edits only; no `git add .`; preserve unowned dirty files |
| Local UIUE repo | source truth for UIUE code/docs/research/report/CI | classify all tracked/untracked project-effective content |
| GitHub PRs | cloud merge truth | #7 first, then #6; remote head/checks must be re-probed before each operation |

### 3.2 Merge Method

Prefer merge commit, not squash.

Reason:

- PR #7 has 139 files and a multi-commit lane.
- PR #6 has 1130 files and a long-lived branch.
- Squash would destroy useful archaeology for future route-control, bug tracing and provenance.

If merge commits are disabled by repo policy, retry with squash only after recording the policy failure. Do not delete branches.

### 3.3 Cloud Sequence

1. Finish D24 local gates.
2. Push final #7/#6 commits and wait for GitHub checks.
3. Mark PR #7 ready for review.
4. Re-probe PR #7:
   - `state`
   - `isDraft`
   - `headRefOid`
   - `baseRefOid`
   - `mergeStateStatus`
   - `statusCheckRollup`
5. Merge PR #7 with head SHA guard.
6. Re-probe PR #6 after #7 lands.
7. Update PR #6 against new `main` by merging base into the PR branch if clean.
8. Rerun PR #6 checks.
9. Merge PR #6 with head SHA guard.
10. Verify both PRs are `MERGED` and record base branch head after each merge.

## 4. Absorption Model

### 4.1 File Disposition Buckets

Every UIUE tracked, modified, untracked and ignored candidate must land in one bucket:

| Bucket | Meaning | Merge impact |
|---|---|---|
| `absorb_full` | Project-effective content should be carried into main as-is | must land before merge or be proven in PR |
| `absorb_summary_index` | Full content is too large/noisy, but project knowledge must be discoverable | create summary/index in main |
| `already_in_pr` | Already present in #7/#6 remote head | cite PR file/API proof |
| `historical_reference_only` | Useful for provenance, not current route truth | index or leave in UIUE source manifest |
| `generated_drop` | generated/cache/report output not meant for source control | do not absorb; record rationale |
| `raw_secret_no_touch` | raw/customer/secret/prohibited content | do not copy; stop if needed |
| `requires_user_decision` | Material but ambiguous | stop before merge |

### 4.2 Code/Test/CI/CD

Hard dimensions:

- `App/`
- `Core/`
- `Tests/`
- `MAformacIOSUITests/`
- `MAformac.xcodeproj/`
- `Makefile`
- `Package.swift`
- `.github/workflows/`
- `.githooks/`
- `.xcodebuildmcp/`

Known code/CI facts:

- PR #7 includes `App/ContentView.swift`, multiple `Core/Execution`, `Core/Presentation`, `Core/State`, `Tests`, `Makefile`, `scripts`, `openspec`.
- PR #6 includes 14 `App`, 24 `Core`, 38 `Tests`, 2 `MAformacIOSUITests`, `MAformac.xcodeproj`, `Makefile`, `.githooks`, `.xcodebuildmcp`.
- UIUE Makefile reportedly adds `verify-contentview-wiring`; main has `verify-generated`. D24 must decide whether they are complementary and whether both belong in final main surface.
- `.github/workflows/verify.yml` appears structurally aligned, but must be rechecked after final commits.

Code/CI gates:

```bash
git diff --name-status <base>...HEAD -- App Core Tests MAformacIOSUITests Makefile Package.swift .github .githooks .xcodebuildmcp MAformac.xcodeproj
make verify-ci
swift test
git diff --check
gitnexus detect_changes --scope staged
```

If any source symbol is edited during D24, run GitNexus impact before edit and detect_changes before commit.

### 4.3 Docs / Route-Control

Must update or create:

- `/Users/wanglei/workspace/MAformac/docs/CURRENT.md`
- `/Users/wanglei/workspace/MAformac/docs/README.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/CURRENT.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/README.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md`
- `/Users/wanglei/workspace/MAformac/docs/project/phase0/r5-d24-uiue-absorption-manifest-2026-06-30.md`
- `/Users/wanglei/workspace/MAformac/docs/project/phase0/r5-d24-route-control-pr-merge-closeout-2026-06-30.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-d24-uiue-absorption-source-manifest-2026-06-30.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-d24-route-control-pr-merge-closeout-uiue-2026-06-30.md`

Required facts to preserve:

- D22 commander verdict: `DONE_UNDER_PROOF_CAP / PASS_WITH_NOTES`
- D23 commander verdict: `DONE_UNDER_PROOF_CAP / PASS_WITH_NOTES`
- Claude Code final audit skipped by user override
- first GPT Pro `REQUEST_CHANGES` fixed post-audit
- user-selected advisory reviews are not gates and not proof class

Grill accounting to preserve:

- total runtime-related rows: `215`
- proof-bearing rows: `55`
- merge-only rows: `111`
- human decision rows: `11` (`3` accepted, `8` backlog)
- K1 future rows: `8`
- F1 future rows: `29`
- drop: `1`

### 4.4 Research / Reports / Tools

Do not absorb blindly.

Known broad surfaces:

- PR #6 includes `docs/research` with hundreds of files, including screenshots/media-style visual evidence from earlier UIUE/A2 work.
- PR #6 includes `Tools/skills` with 340 files and `Tools/checks` with 10 files.
- PR #6 includes `Reports` with 16 files.
- Local UIUE has untracked `docs/research/2026-06-29-visual-acceptance-standard/` with 10 markdown files.

Recommended handling:

| Surface | Default disposition | Reason |
|---|---|---|
| `docs/research/2026-06-29-visual-acceptance-standard/` | `absorb_summary_index` unless user requests full | valuable, but not all statements should become mainline truth |
| D12-D19 UIUE dispatch trace docs | `historical_reference_only` + summary index | provenance, not current D24 execution truth |
| D20-D24 main dispatch/verdict docs | `absorb_full` | current route-control evidence |
| `Reports/` | `generated_drop` unless explicitly cited as trackable evidence | report outputs often generated/large/noisy |
| `Tools/skills` / `Tools/checks` | classify before merge | may be project infra, but too large to absorb without ownership decision |
| `.xcodebuildmcp` | classify before merge | local build defaults may be useful, but can be environment-specific |

## 5. D24 Execution Gates

### Gate 0: Freeze Truth

Purpose: capture local/cloud state before any edits.

Required:

```bash
git -C /Users/wanglei/workspace/MAformac status --short --branch
git -C /Users/wanglei/workspace/MAformac-uiue status --short --branch
gh pr view 7 --repo rayw-lab/MAformac --json number,state,isDraft,headRefOid,baseRefOid,mergeStateStatus,statusCheckRollup,url
gh pr view 6 --repo rayw-lab/MAformac --json number,state,isDraft,headRefOid,baseRefOid,mergeStateStatus,statusCheckRollup,url
gh api repos/rayw-lab/MAformac/pulls/7/files --paginate --jq '.[].filename'
gh api repos/rayw-lab/MAformac/pulls/6/files --paginate --jq '.[].filename'
```

Do not trust local `@{u}` if Git fetch still fails.

### Gate 1: Full Absorption Manifest

Produce:

- main absorption manifest
- UIUE source manifest

Manifest must include:

- path
- source repo
- tracked/untracked/ignored
- file class
- disposition bucket
- destination
- proof
- owner
- merge blocker yes/no

Gate passes only if every material `requires_user_decision` item is either resolved or blocks merge.

### Gate 2: Code + CI Absorption

Required:

- Compare `App/Core/Tests/MAformacIOSUITests/Makefile/Package.swift/.github/.githooks/.xcodebuildmcp/MAformac.xcodeproj`.
- Decide if UIUE `verify-contentview-wiring` and main `verify-generated` both belong in final main.
- Run targeted Swift tests for changed code.
- Run `make verify-ci` if feasible.
- Use GitNexus impact/detect_changes for source edits.

If code/CI cannot be safely reconciled, stop before merge.

### Gate 3: Docs Cascade

Required:

- Update both repo entry docs.
- Fix stale route-control language.
- Link D24 absorption manifest.
- Preserve D22/D23 facts and advisory-review policy.
- Keep K1/F1/future rows as future, not resolved.

Validation:

```bash
openspec validate --all --strict
git diff --check -- docs
```

### Gate 4: Final Commits, Push, Checks

Rules:

- No `git add .`.
- Stage exact paths only.
- Separate owned D24 changes from unowned dirty files.
- If normal push fails on 443, use GitHub Git Data API only with local commit/tree and remote head/tree before/after recorded.
- Wait for PR checks after push.

### Gate 5: Pre-Merge Audit

Run Codex read-only audit over:

- absorption manifest completeness
- code/CI disposition
- docs cascade
- PR remote heads/checks
- no-claim discipline
- merge sequence safety

Any P0/P1 or `REQUEST_CHANGES` blocks merge.

### Gate 6: Cloud Merge

PR #7:

- mark ready only after Gates 0-5 pass
- re-probe
- merge with `merge` method and head SHA guard
- verify merged state and base head

PR #6:

- re-probe after #7 lands
- if stale, update branch by merging base HEAD into PR branch
- rerun checks
- inspect overlap files
- merge with `merge` method and head SHA guard
- verify merged state and base head

### Gate 7: Local Post-Merge Single Surface

Preferred:

- update `/Users/wanglei/workspace/MAformac` to merged `origin/main` only if safe and clean.

Fallback:

```bash
git worktree add /Users/wanglei/workspace/MAformac-r5-postmerge-verify origin/main
```

Verify:

- D24 absorption manifest exists.
- D24 closeout exists.
- UIUE code/docs/research/report/tooling dispositions are discoverable.
- No product/runtime readiness overclaim appears in entry docs.

## 6. Pre-Mortem

### Tiger

1. **Green PR checks create false confidence.**
   Current checks prove remote PR heads, not local untracked absorption.
2. **PR #6 is too broad for ordinary review.**
   1130 files span code, docs, reports, tools, project config and assets.
3. **#6 stale after #7.**
   Current `CLEAN` state is pre-#7; it must be recomputed.
4. **Research/report assets become fake truth.**
   Visual reports and generated evidence can be useful provenance but not automatically current acceptance.
5. **Dirty local worktrees pollute merge work.**
   Both repos have unowned modified/untracked files.

### Paper-Tiger

1. PR #7/#6 are currently `CLEAN` and checks green. This helps but only as Gate 4 input.
2. The large docs/research surface is not automatically bad. It is acceptable if classified and indexed.
3. Merge commit is not “messy” here; it preserves archaeology for a long-lived branch.

### Elephant

R5 truth is split across:

- two repos
- two PRs
- local dirty files
- untracked research/dispatches
- route-control docs
- commander/execution threads
- advisory audits that must not become proof class

D24 must repair the system by making absorption/disposition explicit, not by rushing to a green merge button.

## 7. Bug Iceberg Teardown

Visible symptom:

```text
PR #7/#6 are mergeable/checks green, but user correctly suspects local UIUE content may not be absorbed.
```

Expected chain:

```text
UIUE source truth
-> absorption manifest
-> code/docs/CI/research dispositions
-> final PR commits and checks
-> #7 merge
-> #6 update/recheck/merge
-> local main single surface verification
```

Observed break risk:

```text
Cloud merge could happen before local absorption and route-control truth converge.
```

System fix:

- Make D24 absorption manifest a hard merge prerequisite.
- Treat generated/research/report/tools as first-class classification surfaces.
- Use merge commit and SHA guards.
- Verify post-merge local main surface.

## 8. CI/CD Upgrade Considerations

Current CI evidence:

- `.github/workflows/verify.yml` appears aligned and runs `make verify-ci` plus `git diff --check`.
- PR #7 has two successful `verify` runs.
- PR #6 has one successful `verify` run.

Required upgrades for D24:

- Ensure `verify-ci` covers both main and UIUE expectations after merge.
- Reconcile `verify-generated` and `verify-contentview-wiring`.
- If `.githooks/pre-commit` is kept from UIUE, document whether it is advisory local hygiene or required project gate.
- If `.xcodebuildmcp` is kept, document simulator/profile ownership and whether it is environment-specific.
- Rerun checks after any branch update, especially #6 after #7.
- If branch protection cannot be inspected due 403, treat GitHub merge rejection as authoritative at Gate 6.

## 9. Cloud Operation Rules

GitHub docs/oracle constraints used for this plan:

- Draft PRs cannot be merged until marked ready.
- PR file list API is paginated, defaults to 30 files/page, max 3000 files.
- Merge API supports `sha` so the PR head must match before merge.
- Update branch API merges base HEAD into the PR branch and supports `expected_head_sha`.

Operational implications:

- Use paginated API for #6; `gh pr diff` is insufficient at this size.
- Use head SHA guards for merge and branch update.
- Do not rely on stale local refs while Git 443 is failing.
- Record API response status and resulting SHA for every remote operation.

References:

- https://docs.github.com/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests
- https://docs.github.com/en/rest/pulls/pulls
- https://docs.github.com/articles/merging-a-pull-request

## 10. Recommended D24 Split

I recommend splitting D24 execution into two internal stages, even if the final receipt remains one D24:

### D24A: Absorption And Route-Control

Exit criteria:

- manifests created
- code/CI/docs/research/report/tooling dispositions complete
- CURRENT/README/route map fixed
- exact-path commits pushed
- checks green
- pre-merge audit PASS/PASS_WITH_NOTES

### D24B: Cloud Merge And Local Post-Merge Verify

Exit criteria:

- #7 ready and merged
- #6 updated after #7 if needed
- #6 checks rerun green
- #6 merged
- local main or clean verification worktree proves absorption is discoverable
- final closeout states nonclaims

This split avoids treating merge as the same kind of work as absorption. Absorption is architecture/project hygiene; merge is an irreversible cloud operation.

## 11. Minimum Final Receipt

D24 final receipt must include:

```yaml
label: UIUE_R5_D24_FULL_ABSORPTION_ROUTE_CONTROL_PR_MERGE
status: DONE_UNDER_PROOF_CAP | PARTIAL | BLOCKED
verdict: PASS_WITH_NOTES | REQUEST_CHANGES | BLOCKED
merge_decision: MERGE_AFTER_GATES
local_surfaces:
  main: /Users/wanglei/workspace/MAformac
  uiue: /Users/wanglei/workspace/MAformac-uiue
  postmerge_verify: /Users/wanglei/workspace/MAformac | /Users/wanglei/workspace/MAformac-r5-postmerge-verify
cloud:
  pr7:
    state_before: OPEN
    draft_before: true
    merged: true | false
    merge_method: merge | squash | none
    head_sha_guard: "<sha>"
  pr6:
    state_before: OPEN
    stale_after_pr7: true | false
    updated_after_pr7: true | false
    checks_after_update: SUCCESS | FAIL | SKIPPED
    merged: true | false
    merge_method: merge | squash | none
    head_sha_guard: "<sha>"
absorption:
  manifest: /Users/wanglei/workspace/MAformac/docs/project/phase0/r5-d24-uiue-absorption-manifest-2026-06-30.md
  unresolved_material_items: []
validation:
  local:
    - git diff --check
    - openspec validate --all --strict
    - make verify-ci
    - swift test
  github:
    - gh pr checks 7
    - gh pr checks 6
non_claims:
  - no R5_complete
  - no A_2_complete
  - no runtime_ready
  - no mobile
  - no true_device
  - no live_api
  - no V_PASS
  - no voice_ready
  - no golden_ready
```

## 12. Commander Recommendation

Do not merge immediately.

Proceed with D24A first. If D24A produces a clean absorption manifest, route-control docs, final commits and checks, then execute D24B with PR #7 first and PR #6 second. If D24A finds material `requires_user_decision` items, stop before merge and ask for a decision with exact path evidence.

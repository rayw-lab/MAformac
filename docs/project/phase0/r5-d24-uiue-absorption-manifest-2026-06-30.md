---
status: d24a_inventory_live_verified  # ⚠️ RETIRED 2026-06-30 (A 文档收敛): retire_when 已满足 (PR#7/#6/#8 已并 origin/main 771f48a, merge evidence recorded)；本 manifest 转历史 receipt，当前 D24 收口见 docs/CURRENT.md
artifact_kind: uiue_absorption_manifest
authority: d24_execution_receipt
created_at: 2026-06-30
owner: codex_d24_executor
repos:
  main: /Users/wanglei/workspace/MAformac
  uiue: /Users/wanglei/workspace/MAformac-uiue
proof_class: local_static + github_api_remote_truth + docs_local
retire_when: "D24 closeout lands and PR #7/#6 merge evidence is recorded, or a newer D24 absorption manifest supersedes this file."
---

# R5 D24 UIUE Absorption Manifest

## 0. Verdict

This is the D24A live inventory and initial disposition manifest. It is not product readiness and not merge completion.

Current verdict: `PASS_FOR_D24A_CONTINUE`.

No material `requires_user_decision` item is identified at D24A. Broad surfaces still require D24B-D24D treatment before merge: `Tools/skills`, `Tools/checks`, `.xcodebuildmcp`, `.githooks`, `Reports`, `docs/research`, and route-control entry docs.

## 1. Live Truth Freeze

### Main

| Field | Live value |
|---|---|
| path | `/Users/wanglei/workspace/MAformac` |
| branch | `codex/rebuild-c6-doc-absorption-20260624` |
| local HEAD | `f58c006498766a49b607ed8cfb70c8ffb4ae9ac2` |
| local status | ahead of `origin/codex/rebuild-c6-doc-absorption-20260624` by 4; dirty |
| PR | `#7` `https://github.com/rayw-lab/MAformac/pull/7` |
| PR state | `OPEN`, draft `true`, `mergeStateStatus=CLEAN` |
| PR head | `7c5c8a8a174da7d5e93ceef4adbae482efa0d5a2` |
| PR base | `main` at `c1e7d58d281d0256d29034c1d120cefe0bf5a033` |
| checks | two `verify` check runs `SUCCESS` as of `2026-06-30T05:30:14Z` / `2026-06-30T05:29:53Z` |

Main dirty split:

| Path | state | D24 disposition |
|---|---|---|
| `AGENTS.md` | modified | `absorb_full`; D24 route entry update candidate, exact-path review before staging |
| `CLAUDE.md` | modified | `absorb_full`; project constitution cascade candidate, exact-path review before staging |
| `docs/CURRENT.md` | modified | `absorb_full`; stale route-control must be reconciled in D24C |
| `docs/README.md` | modified | `absorb_full`; D24 discoverability update in D24C |
| `.xcodebuildmcp/` | untracked | `absorb_summary_index`; local build-defaults surface, classify before staging |
| `Tools/agent-platform-plugin-refs/` | untracked | `absorb_summary_index`; local plugin-reference surface, classify before staging |
| `docs/dispatches/2026-06-29-uiue-r5-d20-d21-runtime-uiue-integration-pr-supertrain-dispatch.md` | untracked | `absorb_full`; current D20-D21 route evidence |
| `docs/dispatches/2026-06-30-uiue-r5-d22-runtime-payload-corpus-expansion-supertrain-dispatch.md` | untracked | `absorb_full`; current D22 route evidence |
| `docs/dispatches/2026-06-30-uiue-r5-d23-shared-schema-checker-pr-hygiene-dispatch.md` | untracked | `absorb_full`; current D23 route evidence |
| `docs/dispatches/2026-06-30-uiue-r5-d24-full-absorption-route-control-pr-merge-dispatch.md` | untracked | `absorb_full`; D24 execution authority |
| `docs/dispatches/2026-06-30-uiue-r5-d24-route-control-pr-merge-dispatch.md` | untracked | `historical_reference_only`; earlier D24 draft, do not treat as final authority |
| `docs/project/phase0/r5-d22-runtime-payload-corpus-expansion-commander-verdict-2026-06-30.md` | untracked | `absorb_full`; D22 commander verdict |
| `docs/project/phase0/r5-d23-shared-schema-checker-commander-verdict-2026-06-30.md` | untracked | `absorb_full`; D23 commander verdict |
| `docs/project/phase0/r5-d24-local-cloud-dual-repo-full-absorption-merge-plan-2026-06-30.md` | untracked | `absorb_full`; commander merge plan candidate, superseded by dispatch for execution details |

### UIUE

| Field | Live value |
|---|---|
| path | `/Users/wanglei/workspace/MAformac-uiue` |
| branch | `uiue/phase4-default-scope-presentation` |
| local HEAD | `4c7da7167a64f79839327d9f11d633aa2948f171` |
| local status | ahead of `origin/uiue/phase4-default-scope-presentation` by 4; dirty |
| PR | `#6` `https://github.com/rayw-lab/MAformac/pull/6` |
| PR state | `OPEN`, draft `false`, `mergeStateStatus=CLEAN` |
| PR head | `1b84af5f08bc0ac188c01b53ca888b0eb3d13c1c` |
| PR base | `main` at `c1e7d58d281d0256d29034c1d120cefe0bf5a033` |
| checks | one `verify` check run `SUCCESS` as of `2026-06-30T05:29:44Z` |

UIUE local dirty split:

| Path | state | D24 disposition |
|---|---|---|
| `AGENTS.md` | modified | `absorb_summary_index`; local route entry, reconcile with main authority before staging |
| `CLAUDE.md` | modified | `absorb_summary_index`; UIUE route constitution delta, reconcile in D24C |
| `docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md` | modified | `absorb_full`; current UIUE R5 route-control surface |
| `docs/dispatches/2026-06-29-uiue-r5-d12-runtime-adapter-v0-code-train-dispatch.md` | untracked | `historical_reference_only`; D12 provenance, index not current route authority |
| `docs/dispatches/2026-06-29-uiue-r5-d13-c3-runtime-adapter-integration-dispatch.md` | untracked | `historical_reference_only`; D13 provenance, index not current route authority |
| `docs/dispatches/2026-06-29-uiue-r5-d14-runtime-adapter-residual-train-dispatch.md` | untracked | `historical_reference_only`; D14 provenance, index not current route authority |
| `docs/dispatches/2026-06-29-uiue-r5-d15-runtime-presentation-payload-contract-dispatch.md` | untracked | `historical_reference_only`; D15 provenance, index not current route authority |
| `docs/dispatches/2026-06-29-uiue-r5-d16-d17-core-config-force-state-uiue-consumer-supertrain-dispatch.md` | untracked | `historical_reference_only`; D16-D17 provenance, index not current route authority |
| `docs/dispatches/2026-06-29-uiue-r5-d18-d19-runtime-durability-uiue-guard-dispatch.md` | untracked | `historical_reference_only`; D18-D19 provenance, index not current route authority |
| `docs/research/2026-06-29-visual-acceptance-standard/` | untracked | `absorb_summary_index`; valuable visual-acceptance research, summarize rather than copy full folder into main at D24B |

Ignored/generated candidates are preserved as no-touch by default. Examples observed: `.build/`, `.gitnexus/`, `.venv/`, `.playwright-mcp/`, `.DS_Store`, report run directories, simulator screenshot sets, and Python `__pycache__/`. They are `generated_drop` unless a later D24 stage names one as trackable evidence.

## 2. GitHub PR File Surface

PR #7 file API summary:

| top-level | count | initial disposition |
|---|---:|---|
| `.claude` | 6 | `already_in_pr` |
| `App` | 1 | `already_in_pr` |
| `CLAUDE.md` | 1 | `already_in_pr` |
| `Core` | 14 | `already_in_pr` |
| `Makefile` | 1 | `already_in_pr` |
| `Tests` | 21 | `already_in_pr` |
| `Tools` | 1 | `already_in_pr` |
| `UBIQUITOUS_LANGUAGE.md` | 1 | `already_in_pr` |
| `contracts` | 1 | `already_in_pr` |
| `docs` | 69 | `already_in_pr` |
| `openspec` | 20 | `already_in_pr` |
| `scripts` | 3 | `already_in_pr` |

PR #6 file API summary:

| top-level | count | initial disposition |
|---|---:|---|
| `.claude` | 36 | `already_in_pr` |
| `.githooks` | 1 | `already_in_pr`; D24D must classify advisory vs required local gate |
| `.gitignore` | 1 | `already_in_pr` |
| `.xcodebuildmcp` | 2 | `already_in_pr`; D24D must classify environment-specific defaults |
| `AGENTS.md` | 1 | `already_in_pr` |
| `App` | 14 | `already_in_pr` |
| `CLAUDE.md` | 1 | `already_in_pr` |
| `Core` | 24 | `already_in_pr` |
| `MAformac.xcodeproj` | 3 | `already_in_pr` |
| `MAformacIOSUITests` | 2 | `already_in_pr` |
| `Makefile` | 1 | `already_in_pr`; D24D must reconcile `verify-contentview-wiring` with main `verify-generated` |
| `Reports` | 16 | `already_in_pr`; treat as trackable evidence receipts only, not product proof |
| `Tests` | 38 | `already_in_pr` |
| `Tools` | 350 | `already_in_pr`; D24D must classify skills/checks before final merge |
| `docs` | 632 | `already_in_pr` |
| `openspec` | 8 | `already_in_pr` |

Key code/test/CI evidence from PR #6 includes:

- `App/ContentView.swift` plus 13 other `App/` presentation files.
- 24 `Core/Presentation` and `Core/State` files.
- 38 unit-test files and 2 `MAformacIOSUITests` files.
- `.githooks/pre-commit`, `.xcodebuildmcp/README.md`, `.xcodebuildmcp/config.yaml`, `MAformac.xcodeproj`, and `Makefile`.
- `Tools/checks/*` and `Tools/skills/INDEX.md` plus project-local skill payloads.

## 3. D24 Disposition Counts

Initial D24A local-dirty disposition counts:

```yaml
disposition_counts:
  absorb_full: 8
  absorb_summary_index: 5
  already_in_pr: 16
  historical_reference_only: 7
  generated_drop: 1
  raw_secret_no_touch: 0
  requires_user_decision: 0
```

Notes:

- `already_in_pr: 16` is counted by PR #7/#6 top-level buckets, not individual files.
- `generated_drop: 1` represents ignored/generated families, not one file.
- D24B may refine counts after route-control/doc updates.

## 4. Risk Skills And Iceberg Check

```yaml
risk_skills:
  pre_mortem:
    used: true
    tiger:
      - "PR checks green can hide local untracked absorption gaps."
      - "PR #6 is broad enough that docs/code/tools/reports can be misclassified."
      - "PR #6 CLEAN before PR #7 does not prove it stays clean after PR #7."
    paper_tiger:
      - "Large PR #6 file count is acceptable if every surface has disposition and post-#7 checks rerun."
    elephant:
      - "R5 truth is split across two repos, two PRs, untracked docs, local route boards, and advisory reviews."
    mitigation:
      - "Use manifests as hard prerequisites before merge."
      - "Keep #7 then #6 order and re-probe #6 after #7."
      - "Keep all readiness claims under proof cap."
  iceberg_teardown:
    used: true
    visible_symptom: "PRs are CLEAN/checks green while local absorption evidence is incomplete."
    deeper_cause: "Cloud PR state, local dirty state, route-control docs, and commander verdicts were not one discoverable surface."
    same_class_risk:
      - "docs-only fake green"
      - "advisory review promoted to gate/proof"
      - "generated report proof promoted to runtime/product proof"
    fix: "Make disposition manifests and route-control closeouts required before PR merge."
```

## 5. D24A Receipt Harness

```yaml
skills_ledger:
  executing_plans: used
  pre_mortem: used_at_stage_start
  bug_iceberg_teardown: used_when_triggered
  oracle_external_truth: used_for_github
  openspec: used
  gitnexus: not_code_change
  github: used
  subagentcodex: post_D24G_only
  github_cloud_audit: post_D24G_only
lessons_learned:
  - "D20-D23 show checks and advisory reviews must stay below product/runtime proof."
metacognitive_check:
  - "Did not treat dispatch candidate SHAs or local upstream refs as live truth."
pre_mortem:
  - "A clean PR can still be unsafe if local untracked docs/research/tooling are unclassified."
iceberg_teardown:
  visible_symptom: "CLEAN PR state"
  deeper_class: "multi-surface truth split"
local_search:
  - "git status --short --branch"
  - "git rev-parse HEAD"
  - "git log --oneline --decorate --max-count=12"
  - "git ls-files -m -o --exclude-standard"
  - "git status --ignored --short"
github_or_web_truth:
  - "gh pr view 7 --json number,title,headRefName,headRefOid,baseRefName,baseRefOid,state,url,isDraft,mergeStateStatus,statusCheckRollup,updatedAt"
  - "gh pr view 6 --json number,title,headRefName,headRefOid,baseRefName,baseRefOid,state,url,isDraft,mergeStateStatus,statusCheckRollup,updatedAt"
  - "gh api repos/rayw-lab/MAformac/pulls/7/files --paginate"
  - "gh api repos/rayw-lab/MAformac/pulls/6/files --paginate"
goal_drift_check:
  - "No K1/C5/C6/voice/golden/runtime/product work started."
authority_check:
  - "CLAUDE.md, docs/CURRENT.md, docs/README.md, D24 dispatch, D24 merge plan, UIUE CLAUDE.md/CURRENT/README."
claim_vs_proof_check:
  - "All claims are local_static, docs_local, or github_api_remote_truth."
boundary_check:
  - "No branch deletion, no raw/secret copying, no runtime/mobile/live/V-PASS claim."
self_question:
  - "If this manifest were wrong, the proving commands are git status, gh pr view, and paginated PR files API output."
post_audit_correction_rule:
  - "Post-D24G audit findings must be fixed if owned and safe, otherwise listed as residuals."
```

## 6. D24B Main-Traceable Absorption Index

This section makes UIUE project-effective content discoverable from main without bulk-copying raw/generated artifacts.

| Source surface | Disposition | Main-traceable handling | Proof / boundary |
|---|---|---|---|
| Main D20-D24 dispatches and D22/D23 commander verdicts | `absorb_full` | Stage exact files under `docs/dispatches/` and `docs/project/phase0/` after D24C/D24D validation. | Current route-control evidence; not product/runtime proof. |
| D24 full dispatch | `absorb_full` | Keep `docs/dispatches/2026-06-30-uiue-r5-d24-full-absorption-route-control-pr-merge-dispatch.md` as execution authority. | Pre-send Hermes audit was outside D24 execution budget. |
| Earlier D24 route-control-only draft | `historical_reference_only` | Keep as trace artifact only if staged; do not cite as execution authority. | Superseded by full D24 dispatch. |
| UIUE D12-D19 source dispatches | `historical_reference_only` | Summarized by this manifest and UIUE source manifest; not promoted to current D24 route authority. | Useful provenance for D12-D19 route history only. |
| UIUE visual acceptance research `docs/research/2026-06-29-visual-acceptance-standard/` | `absorb_summary_index` | Keep source in UIUE; main manifest records lens names and use as future visual-standard input. | No full copy to main at D24B; no visual/mobile/true-device proof claim. |
| PR #7 code/test/OpenSpec/docs surface | `already_in_pr` | Prove by GitHub PR files API and post-push/checks; merge PR #7 first if D24 gates pass. | PR #7 current state is open draft/CLEAN; must be marked ready before merge. |
| PR #6 UIUE code/test/UI/CI/docs surface | `already_in_pr` | Prove by GitHub PR files API and post-#7 re-probe/update/check; merge PR #6 second only if clean. | PR #6 current CLEAN does not survive #7 merge by assumption; must be recomputed. |
| PR #6 `Tools/checks` and `Tools/skills` | `already_in_pr` with D24D classification | Treat as project-local tool/check surface; D24D must record validation and ownership limits before merge. | No bulk endorsement of every skill as project authority. |
| PR #6 `.xcodebuildmcp` and `.githooks` | `already_in_pr` with D24D classification | Treat as local build/defaults/hygiene surface; D24D must distinguish advisory local defaults from CI/product gates. | No environment-specific overclaim. |
| PR #6 selected `Reports` files | `already_in_pr` as trackable evidence receipts | Keep as selected historical/receipt evidence if PR #6 remains otherwise valid. | Reports do not equal runtime/product acceptance. |
| Ignored local `Reports/*`, screenshots, `.build`, `.venv`, `.gitnexus`, `__pycache__` | `generated_drop` | Do not stage or copy. Cite curated evidence indexes instead of raw run folders. | If any generated/no-touch item becomes necessary, stop before merge. |
| Raw/customer/secret/PII/prohibited material | `raw_secret_no_touch` | None needed for D24A-D24B. | Stop condition if later required. |

D24B self-check:

```yaml
d24b_self_check:
  unresolved_material_rows: []
  main_docs_can_locate_manifest: true
  main_index: /Users/wanglei/workspace/MAformac/docs/project/phase0/README.md
  raw_or_secret_copied: false
  proof_cap: local_static + docs_local + github_api_remote_truth
```

Skills ledger update:

```yaml
skills_ledger:
  executing_plans: used
  pre_mortem: used_when_triggered
  bug_iceberg_teardown: used_when_triggered
  oracle_external_truth: used_for_github
  openspec: used
  gitnexus: not_code_change
  github: used
  subagentcodex: post_D24G_only
  github_cloud_audit: post_D24G_only
```

## 7. D24C Route-Control Reconciliation Receipt

D24C updated the current route-control/readme surfaces so D20-D23 and D24 are discoverable without proof promotion.

Changed/linked route surfaces:

- Main `docs/CURRENT.md`: D24 active route, PR #7/#6 live truth, fixed merge order, non-claims.
- Main `docs/README.md`: D24 absorption manifest in the current authority table.
- Main `docs/project/phase0/README.md`: D20-D24 absorption/merge-control pack index.
- UIUE `docs/CURRENT.md`: D24 source manifest, PR #6 live truth, PR #7-first dependency, non-claims.
- UIUE `docs/README.md`: D24 UIUE source manifest in the current authority table.
- UIUE `docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md`: D24 execution intake update before the D23 section.

Fast self-check:

```yaml
d24c_self_check:
  command: "rg -n \"R5_PRECONDITIONS_BLOCKED|not_proposed|pre-D23|pre-D22|REQUEST_CHANGES unresolved|Claude Code final audit required|advisory.*gate|advisory.*proof_class|R5_complete|runtime_ready|V_PASS\" <entry docs> || true"
  result: PASS_WITH_NOTES
  safe_hits:
    - "negative wording that advisory reviews are not gates/proof class"
    - "D24D TODO to classify .githooks advisory vs required local gate"
    - "pre-mortem statement about advisory review promotion risk"
  unsafe_current_route_hits: []
  grill_burndown_preserved:
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

Risk ledger:

```yaml
risk_skills:
  pre_mortem:
    used: true
    tiger:
      - "Route boards can make D20-D23 look like readiness instead of proof-capped local/cloud evidence."
    paper_tiger:
      - "Historical stale-wording hits are acceptable when they live in archived dispatches, handoffs, or negative checklist text."
    elephant:
      - "Current truth depends on entry docs pointing to manifests, not on buried dispatch prose."
    mitigation:
      - "Patch CURRENT/README/route-map entries and record D24 manifest paths."
  iceberg_teardown:
    used: true
    visible_symptom: "stale route-control grep hits"
    deeper_cause: "historical route prose and current route boards shared the same vocabulary without an entry-level D24 index"
    same_class_risk:
      - "old blocker treated as current"
      - "advisory review treated as proof"
      - "PR hygiene treated as merge/product readiness"
    fix: "entry docs now point to D24 manifests and non-claims; historical hits remain provenance."
```

## 8. D24D Validation Receipt

D24D validated the current local D24 doc/route-control changes and the two PR merge candidates without adding source/test/config edits in this stage.

Validation matrix:

```yaml
d24d_validation:
  main_repo:
    path: /Users/wanglei/workspace/MAformac
    local_head_at_validation: f58c006498766a49b607ed8cfb70c8ffb4ae9ac2
    local_d24_code_diff: none
    commands:
      git_diff_code_surface:
        command: "git diff --name-status -- App Core Tests MAformacIOSUITests Makefile Package.swift .github .githooks .xcodebuildmcp MAformac.xcodeproj"
        result: PASS_NO_OUTPUT
      git_diff_check:
        command: "git diff --check"
        result: PASS_NO_OUTPUT
      openspec:
        command: "openspec validate --all --strict"
        result: PASS_18_PASSED_0_FAILED
      swift_test:
        command: "swift test"
        result: PASS_269_TESTS_3_SKIPPED_0_FAILURES
      make_verify_ci:
        command: "make verify-ci"
        result: PASS_269_TESTS_3_SKIPPED_0_FAILURES
      gitnexus_pre_stage:
        command: "mcp__gitnexus.detect_changes(repo=MAformac-r5-main-current, scope=all)"
        result: LOW_RISK_AFFECTED_PROCESSES_0
        caveat: "pre-stage all-scope included pre-existing dirty AGENTS/CLAUDE/Tools docs; rerun staged after exact staging"
      gitnexus_staged:
        command: "mcp__gitnexus.detect_changes(repo=MAformac-r5-main-current, scope=staged)"
        result: LOW_RISK_AFFECTED_PROCESSES_0_CHANGED_FILES_11
  uiue_repo:
    path: /Users/wanglei/workspace/MAformac-uiue
    local_head_at_validation: 4c7da7167a64f79839327d9f11d633aa2948f171
    local_d24_code_diff: none
    commands:
      git_diff_code_surface:
        command: "git diff --name-status -- App Core Tests MAformacIOSUITests Makefile Package.swift .github .githooks .xcodebuildmcp MAformac.xcodeproj"
        result: PASS_NO_OUTPUT
      git_diff_check:
        command: "git diff --check"
        result: PASS_NO_OUTPUT
      openspec:
        command: "openspec validate --all --strict"
        result: PASS_16_PASSED_0_FAILED
      swift_test:
        command: "swift test"
        result: PASS_348_TESTS_3_SKIPPED_0_FAILURES
      make_verify_ci:
        command: "make verify-ci"
        result: PASS_348_TESTS_3_SKIPPED_0_FAILURES_AND_CONTENTVIEW_WIRING_PASS
      gitnexus_staged:
        command: "mcp__gitnexus.detect_changes(repo=MAformac-r5-uiue-current, scope=staged)"
        result: LOW_RISK_AFFECTED_PROCESSES_0_CHANGED_FILES_4
  github_oracle:
    gh_pr_merge_reference:
      source: https://cli.github.com/manual/gh_pr_merge
      applied_rule: "Use --match-head-commit and omit --delete-branch."
    github_update_branch_reference:
      source: https://docs.github.com/rest/pulls/pulls
      applied_rule: "If PR #6 becomes stale after PR #7 merge, update with expected_head_sha before rechecking."
```

CI/config classification:

```yaml
d24d_ci_classification:
  main_verify_ci:
    required_local_gate: true
    includes:
      - verify-refs
      - verify-cross-section
      - verify-surface
      - verify-c6-shape
      - verify-default-scope
      - diff
      - test
      - swift-test
    note: "verify-generated remains available but is not the sole D24 CI gate."
  uiue_verify_ci:
    required_local_gate: true
    complement_to_main: true
    adds:
      - verify-contentview-wiring
    wiring_result: "ContentView calls familyDisplays(from:), VehicleCardsGrid consumes display catalog, fixed-column Grid confirmed."
  hooks_and_local_defaults:
    githooks: "local hygiene surface, not product readiness proof"
    xcodebuildmcp: "local build/simulator defaults, not mobile/true_device proof"
    reports: "historical/receipt evidence only, not runtime/product acceptance"
```

Self-check:

```yaml
d24d_self_check:
  no_code_edit_in_d24_local_stage: true
  no_new_runtime_or_product_claim: true
  exact_staging_required_before_commit: true
  staged_gitnexus_rerun_required: false
  staged_gitnexus_rerun_result: PASS_LOW_RISK_AFFECTED_PROCESSES_0
```

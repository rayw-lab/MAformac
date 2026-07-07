---
status: blocked_at_d24e_github_actions_billing_live_verified
artifact_kind: d24e_uiue_source_closeout_receipt
authority: local_source_receipt_not_runtime_contract
created_at: 2026-06-30
repo: /Users/wanglei/workspace/MAformac-uiue
branch: uiue/phase4-default-scope-presentation
proof_class:
  - local
  - docs_local
  - github_api_remote_truth
nonclaims:
  - not_merge
  - not_github_cloud_check_pass
  - not_runtime
  - not_mobile
  - not_true_device
  - not_live_api
  - not_v_pass
---

# R5 D24 UIUE Source-Side Closeout

This file mirrors the D24E blocker proof for the UIUE source branch. The main closeout receipt is:

`/Users/wanglei/workspace/MAformac/docs/project/phase0/r5-d24-route-control-pr-merge-closeout-2026-06-30.md`

## Verdict

```yaml
d24_status: BLOCKED_AT_D24E_GITHUB_ACTIONS_BILLING
hubble_p1_001_fixed: true
hubble_p1_002_fixed: true
source_side_receipt: /Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-d24-route-control-pr-merge-closeout-uiue-2026-06-30.md
main_receipt: /Users/wanglei/workspace/MAformac/docs/project/phase0/r5-d24-route-control-pr-merge-closeout-2026-06-30.md
```

## Local State And Stale-Upstream Warning

```yaml
uiue_local_state:
  command: "git rev-parse HEAD && git rev-parse @{u} && git status -sb"
  local_head: 7392acd5d92ef7467fc696542608d2d88b7d6206
  local_upstream_ref: 2091dbde3a8d6a59a96a419826f5695ed93f9e22
  status_summary: "ahead 5; pre-existing dirty AGENTS.md, CLAUDE.md, D12-D19 dispatches, visual-acceptance research folder"
  conclusion: "local @{u} is stale_not_authoritative for D24E remote proof"
```

## GitHub API Proof

```yaml
pr_6_remote_ref:
  command: "gh api repos/rayw-lab/MAformac/git/ref/heads/uiue/phase4-default-scope-presentation --jq '{ref:.ref,sha:.object.sha,url:.object.url}'"
  ref: refs/heads/uiue/phase4-default-scope-presentation
  sha: 7f5d6c541fd941ac3bac4f6af1797269ef7b5a15
  url: https://api.github.com/repos/rayw-lab/MAformac/git/commits/7f5d6c541fd941ac3bac4f6af1797269ef7b5a15
pr_6_commit:
  command: "gh api repos/rayw-lab/MAformac/git/commits/7f5d6c541fd941ac3bac4f6af1797269ef7b5a15 --jq '{sha,message,tree:.tree.sha,parents:[.parents[].sha],author,committer}'"
  sha: 7f5d6c541fd941ac3bac4f6af1797269ef7b5a15
  message: "docs: record D24 UIUE absorption source manifest"
  parent: 1b84af5f08bc0ac188c01b53ca888b0eb3d13c1c
  tree: 0e62fc2fe96622206cc3d65dcdf80362794ee8b6
pr_6_current_truth:
  command: "gh pr view 6 --repo rayw-lab/MAformac --json number,state,isDraft,headRefOid,headRefName,baseRefOid,mergeStateStatus,statusCheckRollup"
  state: OPEN
  draft: false
  head: 7f5d6c541fd941ac3bac4f6af1797269ef7b5a15
  mergeStateStatus: UNSTABLE
  verify: FAILURE
  check_run_id: 84231014504
```

## Billing Annotation Proof

```yaml
command: "gh api repos/rayw-lab/MAformac/check-runs/84231014504/annotations --jq '.[] | {annotation_level,path,start_line,end_line,message}'"
failure_annotation:
  annotation_level: failure
  path: .github
  message: "The job was not started because recent account payments have failed or your spending limit needs to be increased. Please check the 'Billing & plans' section in your settings"
notice_annotation:
  annotation_level: notice
  path: .github
  message: "The macos-latest label will migrate to macOS 26 beginning June 15, 2026. For more information see https://github.com/actions/runner-images/issues/14167"
```

## Disposition

```yaml
pr_6_merge: NOT_RUN
reason: "PR #6 must wait for PR #7 merge first, and its own required verify check is failing/UNSTABLE."
post_d24g_audits: POST_D24G_TRIGGER_NOT_REACHED
nonclaims:
  - "No UIUE merge completed."
  - "No simulator/mock/local receipt is promoted to mobile/true_device/runtime/live_api/V-PASS."
```

## Commander Blind Remote Audit Addendum

```yaml
remote_blind_audit:
  verdict: BLOCKED
  go_no_go: NO_GO
  PR_6_P0:
    finding: "PR #6 is not merge-ready: Verify check is failing and it must not be merged before PR #7."
    evidence:
      head: 7f5d6c541fd941ac3bac4f6af1797269ef7b5a15
      isDraft: false
      mergeStateStatus: UNSTABLE
      verify: FAILURE
    required_fix: "After PR #7 merges, re-probe PR #6 against new main, update branch if needed with expected_head_sha, rerun Verify, then reassess."
  PR_7_dependency:
    finding: "PR #7 is still draft and failing Verify, so PR #6 cannot proceed."
    evidence:
      head: a0177b1d984b9a4b387a92534810f8341412e34d
      isDraft: true
      mergeStateStatus: UNSTABLE
      verify: FAILURE
  stale_snapshot_rule: "Treat docs/CURRENT.md D24 start snapshot as stale_candidate; live gh/API output controls merge decisions."
  project_gate_rule: "No merge unless Verify is green, even if GitHub branch protection would permit it."
  post_d24g_audits: POST_D24G_TRIGGER_NOT_REACHED
```

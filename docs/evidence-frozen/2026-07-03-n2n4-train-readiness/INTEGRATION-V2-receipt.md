# INTEGRATION-V2 Receipt

- worker: %44 Codex
- task: Build PR30 replacement integration branch
- date: 2026-07-03
- worktree: `/tmp/MAformac-integration-v2`
- branch: `commander-docs/20260703-integration-v2`
- base: `origin/main` = `f4af8ccfc7d5f9249db53491d64648948aea03ca`
- source: `origin/commander-docs/20260703-absorption-closeout@b824ee0b4ea7bc3e7d9878d554f72696ec29af61`
- adjudication table: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR30-integration-adjudication-table.md`
- commit: `e01aa7c36f89569da0d61a2ebf63ed91bd796741`
- PR: https://github.com/rayw-lab/MAformac/pull/32
- verdict: DONE_LOCAL_STATIC

## What Changed

Applied the PR30 adjudication table as a replacement integration branch:

- branch-only added docs: 26 files checked out from `b824ee0b`.
- take-branch: 4 files checked out from `b824ee0b`.
- union: 11 files merged at section level using `origin/main` as base plus branch D-040/D-042/D-043/N4/F-044 content.
- keep-main: 51 overlap files left untouched.

Final PR diff:

- changed files: 41
- added docs: 26
- modified files: 15
- forbidden dirs changed: 0 under `Core/`, `Tests/`, `openspec/`, `contracts/`

## Key Integration Notes

- `AGENTS.md` and `CLAUDE.md` preserve main operating-contract shell while carrying branch corrections:
  - GitNexus repo label is `MAformac-r5-main-current`.
  - main simulator name is `iPhone 17 Pro`.
  - tmux-bridge swarm entry remains present.
- `docs/CURRENT.md` carries `N4-ACCEPTED-LOCAL`, D-043, 4-key waiting state, and PR #30 replacement route.
- `docs/commander-log/decisions.md` carries D-040, D-042, and D-043.
- `docs/c5-training-readiness-grill/n4-train-readiness-acceptance-2026-07-03.md` exists and records N4 acceptance limits.
- `docs/c5-training-readiness-grill/f044-default-lock-and-wave1-recipe-anchors-2026-07-03.md` exists and records F-044 default lock plus wave-1 recipe anchors.

Note: the adjudication table text records an earlier compared branch head `ed90fbe9...`; the user order explicitly fixed the source to `b824ee0b`, which is the current remote branch head and was used for this integration.

## Validation

Commands run from `/tmp/MAformac-integration-v2`:

```bash
git diff --check origin/main..HEAD
```

Result: PASS, no output.

```bash
git diff --name-only origin/main..HEAD -- Core Tests openspec contracts | wc -l
```

Result: `0`.

```bash
git diff --name-only origin/main..HEAD | wc -l
git diff --name-status origin/main..HEAD | awk '$1=="A" && $2 ~ /^docs\// {c++} END{print c+0}'
git diff --name-status origin/main..HEAD | awk '$1=="M" {c++} END{print c+0}'
```

Result: `41`, `26`, `15`.

```bash
rg -n '^(<<<<<<<|=======|>>>>>>>|\|\|\|\|\|\|\|)' .
```

Result: PASS, no conflict markers.

```bash
gh pr view 32 --json number,title,url,baseRefName,headRefName,headRefOid,statusCheckRollup
gh pr diff 32 --name-only | wc -l
gh pr diff 32 --name-only | rg '^(Core|Tests|openspec|contracts)/' | wc -l
```

Result:

- PR #32 = https://github.com/rayw-lab/MAformac/pull/32
- base = `main`
- head = `commander-docs/20260703-integration-v2`
- head SHA = `e01aa7c36f89569da0d61a2ebf63ed91bd796741`
- PR diff files = `41`
- forbidden dirs in PR diff = `0`
- GitHub `verify` currently reports `FAILURE`; this receipt does not claim CI green.

GitNexus:

```text
detect_changes(repo=MAformac-r5-main-current, scope=all, worktree=/tmp/MAformac-integration-v2)
```

Result: low risk, 41 changed files, affected_processes=0.

## Proof Class

`local/static` + `GitHub PR metadata readback`.

No code, tests, OpenSpec contracts, runtime behavior, training, generation, C6 acceptance, candidate comparison, run-auth, merge-ready, CI-green, or V-PASS is claimed.

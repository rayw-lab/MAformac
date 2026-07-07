---
status: GITNEXUS_ANALYZE_RC0_UP_TO_DATE
artifact_kind: gitnexus_update_receipt
created: 2026-07-05
repo: /Users/wanglei/workspace/MAformac
run_dir: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-launch-doc-cascade
proof_class: local_runtime_tooling
authority_class: run_dir_receipt_not_project_docs
---

# GitNexus Update Receipt

## Conclusion

`node .gitnexus/run.cjs analyze` completed with rc `0`.

Post-run GitNexus status is `up-to-date`: indexed commit `6a4b6b8`, current commit `6a4b6b8`.

No MAformac business source or docs files were edited by this W-K4 receipt work. No training, watchdog arm, model process, git add, commit, or launch action was performed.

## Preconditions

| Check | Result |
|---|---|
| cwd | `/Users/wanglei/workspace/MAformac` |
| branch | `codex/rebuild-c6-doc-absorption-20260624` |
| dirty repo | yes; pre-existing dirty tree present |
| `.gitnexus` directory | present |
| project-local runner | `.gitnexus/run.cjs` present |
| fallback to `npx gitnexus analyze` | not used |

Pre-run `git status --short --branch` showed existing dirty files, including `Core/Training/C5LoRATraining.swift`, tests, docs, and untracked paths. W-K4 did not revert or modify those unrelated changes.

## Pre-Run GitNexus Status

Command:

```bash
date -Iseconds
node .gitnexus/run.cjs status
printf 'rc=%s\n' $?
```

Result summary:

| Field | Value |
|---|---|
| rc | `0` |
| timestamp | `2026-07-05T20:28:43+08:00` |
| repository | `/Users/wanglei/workspace/MAformac` |
| indexed at | `6/30/2026, 10:06:55 AM` |
| indexed commit | `d78f890` |
| current commit | `6a4b6b8` |
| status | stale; re-run analyze required |

Existing `.gitnexus/meta.json` before analyze reported:

| Metric | Value |
|---|---:|
| files | 1762 |
| nodes | 28497 |
| edges | 51005 |
| communities | 1006 |
| processes | 300 |
| embeddings | 0 |

## Analyze Command

Command:

```bash
START=$(date +%s)
echo "started_at=$(date -Iseconds)"
node .gitnexus/run.cjs analyze
rc=$?
END=$(date +%s)
echo "ended_at=$(date -Iseconds)"
echo "duration_seconds=$((END-START))"
echo "rc=$rc"
exit $rc
```

Result summary:

| Field | Value |
|---|---|
| rc | `0` |
| started_at | `2026-07-05T20:28:49+08:00` |
| ended_at | `2026-07-05T20:29:07+08:00` |
| duration_seconds | `18` |
| duration stop condition | not triggered; did not exceed 15 minutes |
| large-file handling | skipped 39 files over 512KB |
| incremental summary | changed `24`, added `117`, deleted `0`; preserved 1738 unchanged file rows |
| writable importers | `+53` importer(s), BFS depth <= 4 |
| parse cache | pruned 1 stale chunk entry |
| final analyzer stdout | repository indexed successfully |
| final stats | `30,002 nodes`, `52,715 edges`, `1019 clusters`, `300 flows` |

Index path printed by analyzer:

```text
/Users/wanglei/workspace/MAformac
```

No separate index ID was printed by the analyzer. The effective repo/index identity is the repo path plus `meta.json` last commit `6a4b6b827257acaf8195b40a5ea67469448aec94`.

## Post-Run GitNexus Status

Command:

```bash
date -Iseconds
node .gitnexus/run.cjs status
printf 'rc=%s\n' $?
```

Result summary:

| Field | Value |
|---|---|
| rc | `0` |
| timestamp | `2026-07-05T20:29:17+08:00` |
| repository | `/Users/wanglei/workspace/MAformac` |
| indexed at | `7/5/2026, 8:29:07 PM` |
| indexed commit | `6a4b6b8` |
| current commit | `6a4b6b8` |
| status | up-to-date |

Post-run `.gitnexus/meta.json` summary:

| Metric | Value |
|---|---:|
| files | 1879 |
| nodes | 30002 |
| edges | 52715 |
| communities | 1019 |
| processes | 300 |
| embeddings | 0 |
| graph provider | `ladybugdb`, available |
| full-text provider | `ladybugdb-fts`, available |
| vector search | unavailable, exact scan limit `10000` |

## Git Status For `.gitnexus`

Command:

```bash
git status --short -- .gitnexus
```

Result: no output.

Secretary interpretation: no tracked `.gitnexus` paths appear changed/generated to git. The analyze command refreshed the local GitNexus index state, but there is no `.gitnexus` git delta to add or commit.

## Non-Claims

- Not a code change receipt.
- Not a docs cascade content update.
- Not a training launch.
- Not watchdog armed.
- Not candidate signed.
- Not C6 acceptance or V-PASS.

## Residual Risk

- Repo working tree remains dirty from pre-existing unrelated files.
- `.gitnexus` local index is up-to-date for current commit `6a4b6b8`, but dirty working-tree changes are not a committed index identity.

---
artifact_kind: m2_tree_cleanup_receipt
status: done_after_salvage_closeout
owner: "%44"
created_at: 2026-07-03
proof_class: local_git_mutation
authority_input: D-050 user authorization
base_inventory: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/M2-TREE-CLEANUP-INVENTORY.md
repo: /Users/wanglei/workspace/MAformac
---

# M2 Tree Cleanup Receipt

## Conclusion

M2 cleanup executed with live `origin/main` ancestry, not stale inventory counts.

- Preflight: `git fetch --all --prune`.
- Per item live check: `git rev-list --count origin/main..<ref>` plus `git status --porcelain=v1 --untracked-files=all`.
- Rule applied: `unique==0` -> remove worktree and delete local/remote branch when branch exists; `unique>0` -> push backup to origin, then remove worktree and preserve local branch.
- No-touch honored: `/Users/wanglei/workspace/MAformac`, `/Users/wanglei/workspace/MAformac-uiue`, `/Users/wanglei/workspace/MAformac-p5w-wave1-bridge`.
- Dirty skip: `/Users/wanglei/workspace/MAformac-m1g` and `/Users/wanglei/workspace/.step0/MAformac-step0-tiny`.

## Per-Directory Actions

| path | ref/head | live unique vs origin/main | dirty | action | before/after evidence |
|---|---:|---:|---|---|---|
| `/Users/wanglei/workspace/MAformac` | `codex/rebuild-c6-doc-absorption-20260624` / `1e352d77` | 100 | yes | skipped protected main tree | before `git worktree list --porcelain`; after still present |
| `/private/tmp/archeo-bridge-schema-main` | detached `f4af8ccf` | 0 | no | `git worktree remove` | removed; no branch |
| `/private/tmp/maformac-d15-g3-verify` | detached `ab9a6820` | 0 | no | `git worktree remove` | removed; no branch |
| `/private/tmp/MAformac-integration-v2` | `commander-docs/20260703-integration-v2` / `e01aa7c3` | 1 | no | pushed `m2-backup/commander-docs-20260703-integration-v2-e01aa7c3`; removed worktree | branch preserved locally; remote backup visible in `git ls-remote --heads origin 'm2-backup/*'` |
| `/private/tmp/maformac-pr26-review.jxHqqy` | detached `3b081823` | 2 | no | created+pushed `m2-backup/detached-maformac-pr26-review.jxHqqy-3b081823`; removed worktree | backup branch preserved |
| `/private/tmp/maformac-pr3.L8SKRV` | detached `80dba834` | 0 | prunable | `git worktree prune --verbose` | pruned metadata: gitdir pointed to nonexistent location |
| `/private/tmp/maformac-xpr25-pr25` | detached `2b808a88` | 2 | no | created+pushed `m2-backup/detached-maformac-xpr25-pr25-2b808a88`; removed worktree | backup branch preserved |
| `/private/tmp/pr29-fix-871307d9` | `pr29-fix-head` / `871307d9` | 3 | no | pushed `m2-backup/pr29-fix-head-871307d9`; removed worktree | local branch retained |
| `/private/tmp/pr31-fix-f163eedf` | `pr31-fix-head` / `f163eedf` | 7 | no | pushed `m2-backup/pr31-fix-head-f163eedf`; removed worktree | local branch retained |
| `/private/tmp/pr32-integration-v2` | `pr32-head` / `e01aa7c3` | 1 | no | pushed `m2-backup/pr32-head-e01aa7c3`; removed worktree | local branch retained |
| `/private/tmp/rereview-pr26` | `pr26-head` / `e6a8849f` | 3 | no | pushed `m2-backup/pr26-head-e6a8849f`; removed worktree | local branch retained |
| `/private/tmp/rereview-pr26-fix` | `pr26-fix-head` / `edfc2198` | 4 | no | pushed `m2-backup/pr26-fix-head-edfc2198`; removed worktree | local branch retained |
| `/private/tmp/rereview-pr27` | `pr27-head` / `a400b01a` | 2 | no | pushed `m2-backup/pr27-head-a400b01a`; removed worktree | local branch retained |
| `/private/tmp/rereview-pr28` | `pr28-head` / `49fa0b9b` | 2 | no | pushed `m2-backup/pr28-head-49fa0b9b`; removed worktree | local branch retained |
| `/private/tmp/rereview-pr29` | `pr29-head` / `5c68f945` | 1 | no | pushed `m2-backup/pr29-head-5c68f945`; removed worktree | local branch retained |
| `/private/tmp/rereview-pr30` | `pr30-head` / `c5016f89` | 82 | no | pushed `m2-backup/pr30-head-c5016f89`; removed worktree | local branch retained |
| `/private/tmp/rereview-pr31` | `pr31-head` / `722644d4` | 4 | no | pushed `m2-backup/pr31-head-722644d4`; removed worktree | local branch retained |
| `/Users/wanglei/workspace/.d24-worktrees/main-postcloseout` | `codex/d24-postmerge-ci-whitespace-proof` / `cb687969` | 0 | no | removed worktree; `git branch -D`; `git push origin --delete` | local/remote branch removed |
| `/Users/wanglei/workspace/.d24-worktrees/pr6` | `codex/d24-pr6-selfhosted-ci` / `f15f473e` | 0 | no | removed worktree; `git branch -D` | remote already pruned by fetch |
| `/Users/wanglei/workspace/.d24-worktrees/pr7` | `codex/d24-pr7-selfhosted-ci` / `02f0722f` | 0 | no | removed worktree; `git branch -D` | remote already pruned by fetch |
| `/Users/wanglei/workspace/.d25-worktrees/k1-spike-ledger` | `codex/d25-k1-spike-ledger-20260630` / `dc5ef7ec` | 1 | no | pushed existing remote branch; removed worktree | local/remote branch retained |
| `/Users/wanglei/workspace/.step0/MAformac-step0-tiny` | `fix/tiny-ablation-real-unlock` / `714f1d6b` | 1 | yes | skipped dirty | dirty: `runs/tiny-ablation-adjudication-A/DONE-XSTEP0`, `XAUDIT-STEP0.md`; still present |
| `/Users/wanglei/workspace/.tiny-ablation/MAformac-tiny-ablation-A` | `run/tiny-ablation-adjudication-A` / `2b808a88` | 2 | no | pushed `m2-backup/run-tiny-ablation-adjudication-A-2b808a88`; removed worktree | local branch retained |
| `/Users/wanglei/workspace/MAformac-g2-mask` | `c5gate/g2-masking-enforce` / `04199f2e` | 4 | no | pushed existing remote branch; removed worktree | branch retained |
| `/Users/wanglei/workspace/MAformac-g5` | `c5gate/g5-multiaxis-heldout` / `24739321` | 2 | no | pushed existing remote branch; removed worktree | branch retained |
| `/Users/wanglei/workspace/MAformac-g6` | `c5gate/g6-c6-four-layer` / `6a392585` | 2 | no | pushed existing remote branch; removed worktree | branch retained |
| `/Users/wanglei/workspace/MAformac-g7` | `c5gate/g7-cloud-generator-design` / `f634422e` | 3 | no | pushed existing remote branch; removed worktree | branch retained |
| `/Users/wanglei/workspace/MAformac-g7a` | `c5gate/g7impl-a-manifest-grammar` / `e6499229` | 2 | no | pushed existing remote branch; removed worktree | branch retained |
| `/Users/wanglei/workspace/MAformac-g7b` | `c5gate/g7impl-b-c6schema-receipt` / `102987f6` | 1 | no | pushed existing remote branch; removed worktree | branch retained |
| `/Users/wanglei/workspace/MAformac-g7c` | `c5gate/g7impl-c-generator-pipeline` / `eaaa9101` | 1 | no | pushed existing remote branch; removed worktree | branch retained |
| `/Users/wanglei/workspace/MAformac-g7d` | `c5gate/g7impl-d-c5-builder-manifest` / `9a62d36b` | 1 | no | pushed existing remote branch; removed worktree | branch retained |
| `/Users/wanglei/workspace/MAformac-g8-tool` | `c5gate/g8-tool-count` / `64c6f62f` | 1 | no | pushed existing remote branch; removed worktree | branch retained |
| `/Users/wanglei/workspace/MAformac-grill` | `c5grill/dim11-dim5-deepen` / `f9e67901` | 8 | no | pushed `m2-backup/c5grill-dim11-dim5-deepen-f9e67901`; removed worktree | local branch retained |
| `/Users/wanglei/workspace/MAformac-hermes-audit` | detached `1d822961` | 0 | no | `git worktree remove` | removed; no branch |
| `/Users/wanglei/workspace/MAformac-m1g` | `main` / `aac84de9` | 0 | yes | skipped dirty; did not remove main mirror | dirty: `RECEIPT-HERMES-ROUND-acceptance.md`; still present; `main` branch/remote not touched |
| `/Users/wanglei/workspace/MAformac-p12-loss-contract` | `codex/p12-v61-eos-span-20260703` / `49fa0b9b` | 2 | no | pushed `m2-backup/codex-p12-v61-eos-span-20260703-49fa0b9b`; removed worktree | local branch retained; original remote branch had already been pruned |
| `/Users/wanglei/workspace/MAformac-p1fix` | `fix/g7d-policy-authority` / `ea8c909d` | 1 | no | pushed existing remote branch; removed worktree | branch retained |
| `/Users/wanglei/workspace/MAformac-p2c6` | `fix/c6-subset-dead-fields` / `c608658b` | 1 | no | pushed existing remote branch; removed worktree | branch retained |
| `/Users/wanglei/workspace/MAformac-p2g7` | `fix/g7c-noop-fields` / `dd4d44d4` | 1 | no | pushed existing remote branch; removed worktree | branch retained |
| `/Users/wanglei/workspace/MAformac-p3h-probe` | `codex/p3h-probe-harness-20260702` / `edfc2198` | 4 | no | pushed `m2-backup/codex-p3h-probe-harness-20260702-edfc2198`; removed worktree | local branch retained; original remote branch had already been pruned |
| `/Users/wanglei/workspace/MAformac-p5w-wave1-bridge` | `codex/p5w-e2-downgrade-valid-supervision-20260703` / `f163eedf` | 7 | yes | skipped protected | still present; active conflict/dirty tree not touched |
| `/Users/wanglei/workspace/MAformac-rat` | `docs/e2-ratification-route-refresh` / `127b4fdf` | 1 | no | pushed existing remote branch; removed worktree | branch retained |
| `/Users/wanglei/workspace/MAformac-uiue` | `uiue/phase4-default-scope-presentation` / `56b0b95a` | 6 | yes | skipped protected | still present |
| `/Users/wanglei/workspace/MAformac-w1` | `r5b/w1-runtime-entry` / `e894eb71` | 6 | no | pushed `m2-backup/r5b-w1-runtime-entry-e894eb71`; removed worktree | local branch retained |
| `/Users/wanglei/workspace/MAformac-w2` | `r5b/w2-docs-reconcile` / `e894eb71` | 6 | no | pushed `m2-backup/r5b-w2-docs-reconcile-e894eb71`; removed worktree | local branch retained |

## Remaining Worktrees

Post-check command: `git worktree list --porcelain`.

Remaining:

- `/Users/wanglei/workspace/MAformac` — protected main worktree.
- `/Users/wanglei/workspace/.step0/MAformac-step0-tiny` — skipped dirty.
- `/Users/wanglei/workspace/MAformac-m1g` — skipped dirty main mirror.
- `/Users/wanglei/workspace/MAformac-p5w-wave1-bridge` — protected active #31 conflict tree.
- `/Users/wanglei/workspace/MAformac-uiue` — protected M4 tree.

Post-check branch command:

- `git branch --list 'codex/d24-*'` returns no local d24 branches.
- `git ls-remote --heads origin 'codex/d24-*'` returns no remote d24 branches.
- `git ls-remote --heads origin 'm2-backup/*'` shows created backup refs for unique>0 trees that did not already have a usable origin backup.

## Residuals

- `MAformac-m1g` was not removed because it contains untracked `RECEIPT-HERMES-ROUND-acceptance.md`.
- `.step0/MAformac-step0-tiny` was not removed because it contains untracked `DONE-XSTEP0` and `XAUDIT-STEP0.md`.
- Main root remains dirty only with pre-existing untracked items; no tracked code files were edited by this cleanup.
- Branches for unique>0 trees are intentionally preserved locally; many also have origin backups under `m2-backup/*`.

## Salvage Closeout Addendum

Status after the follow-up closeout: `done_after_salvage_closeout`.

Authority: user authorized salvage of the two dirty-skipped worktrees, then removal under the same live `unique_vs_main` rule.

Pre-removal live checks:

- `/Users/wanglei/workspace/MAformac-m1g`: `git status --short --branch --untracked-files=all` showed only `?? RECEIPT-HERMES-ROUND-acceptance.md`; `git rev-list --count origin/main..HEAD` returned `0`; branch `main`; head `aac84de9`.
- `/Users/wanglei/workspace/.step0/MAformac-step0-tiny`: `git status --short --branch --untracked-files=all` showed only `DONE-XSTEP0` and `XAUDIT-STEP0.md`; `git rev-list --count origin/main..HEAD` returned `1`; branch `fix/tiny-ablation-real-unlock`; head `714f1d6b`.

Salvaged files:

| archived file | source | source sha256 | archived sha256 | note |
|---|---|---:|---:|---|
| `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/M2-salvaged-files/RECEIPT-HERMES-ROUND-acceptance.md` | `/Users/wanglei/workspace/MAformac-m1g/RECEIPT-HERMES-ROUND-acceptance.md` | `4c35a9295e23667046e2271b3a6636be13d4cfff55091736e5d3958712f74fe8` | `1f3cf6dca9012e4be0ba729cd33d5e6f806ba49fc77198aa1da8b73c47abe058` | original bytes prefix-verified; source note appended |
| `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/M2-salvaged-files/DONE-XSTEP0` | `/Users/wanglei/workspace/.step0/MAformac-step0-tiny/runs/tiny-ablation-adjudication-A/DONE-XSTEP0` | `c357051aa991162be6c10566d057429f1717d9b89b4f0bfcf9ca0daf812ebabc` | `5ba80e5f023f60710d3a3b6f71372f45812a8bff83b9fb19e92135a813bef0ca` | original bytes prefix-verified; source note appended |
| `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/M2-salvaged-files/XAUDIT-STEP0.md` | `/Users/wanglei/workspace/.step0/MAformac-step0-tiny/runs/tiny-ablation-adjudication-A/XAUDIT-STEP0.md` | `f2c24deaa77f2d8b002a29c80cd124a159312e12069aea7a250cb63dffb9875b` | `77b9002063c525110142eb9793b24cca60d4815e616ba66e469b422e7679a814` | original bytes prefix-verified; source note appended |

Closeout actions:

- `.step0` was `unique>0`, so `git push origin fix/tiny-ablation-real-unlock` was run first and returned `Everything up-to-date`; worktree then removed with `git worktree remove --force`.
- `MAformac-m1g` was `unique==0`, so its archived-dirty worktree was removed with `git worktree remove --force`; local branch `main` was deleted (`Deleted branch main (was aac84de9).`).
- `origin/main` was not deleted: it is the protected default branch, not an M2 cleanup branch. `git ls-remote --heads origin main` still returned `458820fa75de8138f985ba2519635f77856c4ea8 refs/heads/main`.

Final worktree list:

- `/Users/wanglei/workspace/MAformac` — protected main worktree.
- `/Users/wanglei/workspace/MAformac-p5w-wave1-bridge` — protected active #31 conflict tree.
- `/Users/wanglei/workspace/MAformac-uiue` — protected M4 tree.

Final verification:

- `test ! -e /Users/wanglei/workspace/MAformac-m1g` returned `m1g removed`.
- `test ! -e /Users/wanglei/workspace/.step0/MAformac-step0-tiny` returned `step0 worktree removed`.
- `git worktree list --porcelain` returned only the three protected worktrees listed above.

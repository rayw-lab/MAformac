# Reports migration plan

authority: `migration_plan_not_executed`
status: `PLAN_ONLY_NOT_EXECUTED`
date: `2026-07-07`
repo: `/Users/wanglei/workspace/MAformac`
head: `dc86b1c8c79454f03ef39c4e841f9c9f3d70bf9e`

## Headline

本文件只做 `Reports/` tracked evidence 的迁移计划与 digest 索引。

**本轮不执行退仓、不 `git rm`、不移动、不改写 `Reports/` 原件；是否执行退仓等待磊哥单独点头。**

口径：

- `Reports/` 当前 tracked: 32 files.
- `.gitkeep` 除外 force-add evidence: 31 files.
- `.gitignore:60-62` 明确 `Reports/*` ignored 且只放行 `!Reports/.gitkeep`。
- D-115 N3 锁定：本轮只落 migration plan，实际执行等磊哥单独点头（`docs/commander-log/decisions.md:1033-1038`）。
- D3 三层法：A no-touch 原件、B bundle 迁移候选、C 低风险候选；退仓仍上抛，第一轮只落 plan + digest 表（`out/grill-r2-partner-answers.md:21-25`）。

## Classification rules

| Layer | Meaning | Action in this round |
|---|---|---|
| A-no-touch | 外部 docs/OpenSpec/handoff/MANIFEST 引用，或作为 receipt/closeout 承重原件。 | 不退仓；只登记 digest 和引用。 |
| B-bundle迁移候选 | 低直接引用，但属于一个 proof bundle，不能拆单文件删。 | 只可在后续单独授权后整包迁移，并保留 digest index + restore path。 |
| C-低风险候选 | 0 外部引用、非 evidence_path、非承重 receipt，通常是 prompt/临时输入。 | 仍不执行；后续可优先退仓。 |

## File table

Refs count is fixed-string external reference count from `docs openspec CLAUDE.md README.md Makefile`, excluding references inside live `Reports/` files themselves.

| Path | sha256 | Refs | Referrers | Layer |
|---|---|---:|---|---|
| `Reports/default-scope-apply-20260624T155654/c6_generate_r1fix.log` | `b080253162ed23bfd1a1648d606fa24b4916dc36b711009c0bd5bb76d59cf9c8` | 1 | `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/Reports/default-scope-apply-20260624T155654/receipt.json:70` | B-bundle迁移候选 |
| `Reports/default-scope-apply-20260624T155654/c6_trap_migration_r1fix.log` | `cb601e90ca22c97193a46862ae9a6dfbeb9ad00d14ff3455134fb861434b9d19` | 1 | `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/Reports/default-scope-apply-20260624T155654/receipt.json:78` | B-bundle迁移候选 |
| `Reports/default-scope-apply-20260624T155654/final_c3_contract.log` | `562135ee8c0284b28d7fc59ded196c5adbc5c2d6583d273ecca1ac0842543716` | 1 | `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/Reports/default-scope-apply-20260624T155654/receipt.json:14` | B-bundle迁移候选 |
| `Reports/default-scope-apply-20260624T155654/final_c3_pipeline.log` | `0fc832a174cb9ee67c2349f2596c22e9959f2b53a5dfccb125d02984f7b877bd` | 1 | `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/Reports/default-scope-apply-20260624T155654/receipt.json:22` | B-bundle迁移候选 |
| `Reports/default-scope-apply-20260624T155654/final_c3_readback.log` | `09401811f1f68cd1004b711f00beb2fa0a32a574a7d59a3d7b0b7e1c88069f12` | 1 | `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/Reports/default-scope-apply-20260624T155654/receipt.json:30` | B-bundle迁移候选 |
| `Reports/default-scope-apply-20260624T155654/final_c5_lora.log` | `b9950fb383be62ed7db0546a586ff0e75b96a3fc206932f7e2964061584467fa` | 1 | `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/Reports/default-scope-apply-20260624T155654/receipt.json:46` | B-bundle迁移候选 |
| `Reports/default-scope-apply-20260624T155654/final_c6_bench.log` | `f6c83f23621a0015ea8af6b5384910e0cb7521927f0853612fcbf1180bc1d333` | 1 | `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/Reports/default-scope-apply-20260624T155654/receipt.json:54` | B-bundle迁移候选 |
| `Reports/default-scope-apply-20260624T155654/final_git_diff_check.log` | `fa77ab6dcf895a30623113e37b6ee812c6cd35b0cbb9693a0c18de550e6b1cf6` | 1 | `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/Reports/default-scope-apply-20260624T155654/receipt.json:118` | B-bundle迁移候选 |
| `Reports/default-scope-apply-20260624T155654/final_make_verify.log` | `1ed59c624d45e1b02fb148bb90dc4b5d8f66cd33244a5edb01abfd2fc7653c15` | 1 | `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/Reports/default-scope-apply-20260624T155654/receipt.json:86` | B-bundle迁移候选 |
| `Reports/default-scope-apply-20260624T155654/final_make_verify_all.log` | `c86588a5d4d6bba06ef5021c2938c88ad82fde3e021c2705cb8631411037ca6f` | 1 | `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/Reports/default-scope-apply-20260624T155654/receipt.json:94` | B-bundle迁移候选 |
| `Reports/default-scope-apply-20260624T155654/final_openspec_all.log` | `25361f2f372668e94d814fc9606c1a1bfeb54683d0019b528adec08100335d35` | 1 | `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/Reports/default-scope-apply-20260624T155654/receipt.json:110` | B-bundle迁移候选 |
| `Reports/default-scope-apply-20260624T155654/final_openspec_change.log` | `29b5d691b11038e9579f4f49b2b87aa9f8614ff838a5e1208a817887f7c27630` | 1 | `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/Reports/default-scope-apply-20260624T155654/receipt.json:102` | B-bundle迁移候选 |
| `Reports/default-scope-apply-20260624T155654/final_tool_contract.log` | `9c8e7b544860a973f94aca24c29625b3b4445bbba5d8238dee1b51cd728b35c5` | 1 | `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/Reports/default-scope-apply-20260624T155654/receipt.json:38` | B-bundle迁移候选 |
| `Reports/default-scope-apply-20260624T155654/final_verify_default_scope.log` | `801b9f5cf0dc86533b55f847b356aa0d9d5cfa306ec1c369777feb570aefa008` | 1 | `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/Reports/default-scope-apply-20260624T155654/receipt.json:62` | B-bundle迁移候选 |
| `Reports/default-scope-apply-20260624T155654/receipt.json` | `d3d9070ea991ee63704183445ab54a0a7f50dd0e31f521e5b1e765aa8e377435` | 1 | `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/MANIFEST.sha256:224` | B-bundle迁移候选 |
| `Reports/uiue-8c2-r3-closeout-20260628/closeout.md` | `798faff0b1db178cab8e6e28dc3ab897127202cfa654e4de26a02652e2439da4` | 5 | `docs/handoffs/2026-06-28-uiue-r4-burndown-commander-handoff.md:40`; `docs/grill-tournament/uiue-r3-residual-routing-to-r4-r5-2026-06-28.md:14`; `docs/grill-tournament/uiue-r3-residual-routing-to-r4-r5-2026-06-28.md:21`; `docs/grill-tournament/uiue-r3-residual-routing-to-r4-r5-2026-06-28.md:23`; `docs/grill-tournament/uiue-r4-human-review-packet-2026-06-28.md:29` | A-no-touch |
| `Reports/uiue-phase4a-proof/README.md` | `6de1b22f4488567c953ba31de0d853f2eb96dcac2e5b3d8dc083cff3e545ea20` | 0 | none | B-bundle迁移候选 |
| `Reports/uiue-phase4a-proof/ios-blocked_hard.png` | `4baf6d5303d4bec71aaf8d32681bbf5276c248880930c9a51497a215feb0afa3` | 0 | none | B-bundle迁移候选 |
| `Reports/uiue-phase4a-proof/ios-blocked_with_alternative.png` | `5eb9630a3831b4cd9f557fc0de321d446d30ff0b514cb683b9673c412b0b0732` | 0 | none | B-bundle迁移候选 |
| `Reports/uiue-phase4a-proof/ios-changing.png` | `57284e8929eb24186f0c9e4e5bcd9dea0979a9fcd4f8cbba4ef40c5b44049d44` | 0 | none | B-bundle迁移候选 |
| `Reports/uiue-phase4a-proof/ios-coldstart-real.png` | `81006da1314f9e21a156365fb328f8f11fffb75ff58ddafda6f596e9caec7f7d` | 1 | `openspec/changes/ui-presentation/design.md:155` | A-no-touch |
| `Reports/uiue-phase4a-proof/ios-normal.png` | `95fc113cf9c94997d296951e5b840e662218c74e76fd5c30631b35289f197ca2` | 0 | none | B-bundle迁移候选 |
| `Reports/uiue-phase4a-proof/ios-satisfied.png` | `17e95cf62a2d438c82f7f352711e744ff3ff16a5a8e8fc649f4092304ce5fcfa` | 0 | none | B-bundle迁移候选 |
| `Reports/uiue-phase4a-proof/ios-unknown.png` | `e9e1641e3392195a87392953cdf4ce838d9b1e4c57acaf37e3aa7e6b6a425416` | 0 | none | B-bundle迁移候选 |
| `Reports/uiue-phase4a-proof/ios-unsafe.png` | `37ea429a6e2db498c3c030f9ae7e4482abb2dda52065cd128ebdf601a185a410` | 0 | none | B-bundle迁移候选 |
| `Reports/uiue-r4-burndown-preimplementation-20260628/closeout.md` | `a57111a267a804dc27e2b25d35f60ec69285aedda3f943a649ac47040445fa21` | 1 | `docs/handoffs/2026-06-28-uiue-r4-burndown-commander-handoff.md:48` | A-no-touch |
| `Reports/uiue-r4-burndown-preimplementation-20260628/dirty-ownership-manifest.md` | `0b6769c760b56c9bc4fcf3c9df6de769cc1de13f8906e27d714a4f05b4a15abf` | 3 | `docs/handoffs/2026-06-28-uiue-r4-burndown-commander-handoff.md:50`; `docs/handoffs/2026-06-28-uiue-r4-burndown-commander-handoff.md:153`; `docs/grill-tournament/uiue-r4-burndown-2026-06-28.md:69` | A-no-touch |
| `Reports/uiue-r4-burndown-preimplementation-20260628/hermes-audit-prompt.md` | `08fc25888a59c1a39e2248940ee876ee64f6d421b63f5f6faedab13547827a51` | 0 | none | C-低风险候选 |
| `Reports/uiue-r4-burndown-preimplementation-20260628/hermes-audit.md` | `4647d54f985f6b95d45404475f2103534c3c791bb1333655cc73175367ca36d4` | 1 | `docs/handoffs/2026-06-28-uiue-r4-burndown-commander-handoff.md:49` | A-no-touch |
| `Reports/uiue-r4-burndown-preimplementation-20260628/validation-summary.md` | `33c3d5a2369571d00190fb17f658f1b62bc389ea1730ece72cc158ef960b34b9` | 1 | `docs/grill-tournament/uiue-r4-burndown-2026-06-28.md:69` | A-no-touch |
| `Reports/uiue-r4-implementation-slice1-20260628/receipt.md` | `9637d7ac25de34ff6605cef6f2bcd4cffc8107d298066da455daf6ecefe4fa51` | 3 | `docs/dispatches/2026-06-28-uiue-r4-exit-preconditions-longrun-dispatch.md:93`; `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/MANIFEST.sha256:225`; `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/Reports/uiue-r4-implementation-slice1-20260628/receipt.md:23` | A-no-touch |

## Layer summary

| Layer | Count | Paths |
|---|---:|---|
| A-no-touch | 7 | `uiue-8c2-r3-closeout/closeout.md`; `uiue-phase4a-proof/ios-coldstart-real.png`; `uiue-r4-burndown-preimplementation/{closeout.md,dirty-ownership-manifest.md,hermes-audit.md,validation-summary.md}`; `uiue-r4-implementation-slice1/receipt.md` |
| B-bundle迁移候选 | 23 | all 15 `default-scope-apply-20260624T155654/*`; `uiue-phase4a-proof/README.md`; 7 unreferenced phase4a screenshots |
| C-低风险候选 | 1 | `uiue-r4-burndown-preimplementation-20260628/hermes-audit-prompt.md` |

## Restore commands

For any single file after a future authorized migration/removal:

```bash
git restore --source dc86b1c8c79454f03ef39c4e841f9c9f3d70bf9e -- Reports/path/to/file
```

Restore all current tracked `Reports/` evidence except `.gitkeep`:

```bash
git restore --source dc86b1c8c79454f03ef39c4e841f9c9f3d70bf9e -- \
  Reports/default-scope-apply-20260624T155654 \
  Reports/uiue-8c2-r3-closeout-20260628 \
  Reports/uiue-phase4a-proof \
  Reports/uiue-r4-burndown-preimplementation-20260628 \
  Reports/uiue-r4-implementation-slice1-20260628
```

If a future approved migration removes files from git index but keeps local copies, restore tracking for one file:

```bash
git restore --staged -- Reports/path/to/file
git restore --source dc86b1c8c79454f03ef39c4e841f9c9f3d70bf9e -- Reports/path/to/file
```

## Future execution constraints

Do not execute these in B1a. They are future commands only after separate approval:

```bash
git rm --cached -- Reports/path/to/file
git rm --cached -r -- Reports/default-scope-apply-20260624T155654
```

Minimum future gate if磊哥 approves migration:

```bash
git status --short --branch
shasum -a 256 Reports/**/*
rg -n --fixed-strings "Reports/" docs openspec CLAUDE.md README.md Makefile
git diff --check
```

For B-bundle migration, require an additional bundle index that records:

- original path,
- sha256,
- old referrers,
- new bundle location,
- exact restore command,
- non-claim that proof class is unchanged.

## Validation used for this plan

```bash
git status --short --branch
git ls-files Reports
git ls-files Reports | wc -l
git ls-files Reports | grep -v '^Reports/.gitkeep$' | wc -l
shasum -a 256 <each Reports file>
rg -n --fixed-strings "<Reports path>" docs openspec CLAUDE.md README.md Makefile
```

Proof class: `local_repo_static`.

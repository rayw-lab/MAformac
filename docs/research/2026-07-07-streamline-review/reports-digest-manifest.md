---
artifact_kind: retire_digest_manifest
status: EXECUTION_PREP_ONLY_NOT_EXECUTED
batch: batch1_reports_retire
created_at: 2026-07-07
as_of_head: da0479b8
authority: physical_cleanup_execution_prep_not_ssot
source_plan: docs/research/2026-07-07-streamline-review/physical-cleanup-execution-pack.md
execution_script: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-07-ma-opt-refactor/out/batch1-reports-retire.sh
proof_class: local_git_ls_files + sha256_digest + existing_referrer_index
non_claims:
  - not_executed
  - not_git_rm_done
  - not_validation_pass_after_execution
---

# Reports Digest Manifest

Batch 1 prepares `Reports/` tracked retirement from 32 tracked files to 1 retained file. This manifest records the live tracked files, sha256, external referrers, and restore command. The execution script keeps `Reports/.gitkeep` and removes the other 31 tracked files.

Current worktree warning at generation time: unrelated modified files existed in `scripts/register_classifier.py`, `scripts/test_register_classifier_lib.py`, `scripts/test_register_classifier_golden.py`, and `Tests/Fixtures/register-golden/golden-set.jsonl`; this manifest does not touch them.

## Retain

| Path | sha256 | External referrers | Restore command |
|---|---|---|---|
| `Reports/.gitkeep` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | none | `git checkout da0479b8 -- Reports/.gitkeep` |

## Retire

| Path | sha256 | External referrers | Restore command |
|---|---|---|---|
| `Reports/default-scope-apply-20260624T155654/c6_generate_r1fix.log` | `b080253162ed23bfd1a1648d606fa24b4916dc36b711009c0bd5bb76d59cf9c8` | `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/Reports/default-scope-apply-20260624T155654/receipt.json:70` | `git checkout da0479b8 -- Reports/default-scope-apply-20260624T155654/c6_generate_r1fix.log` |
| `Reports/default-scope-apply-20260624T155654/c6_trap_migration_r1fix.log` | `cb601e90ca22c97193a46862ae9a6dfbeb9ad00d14ff3455134fb861434b9d19` | `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/Reports/default-scope-apply-20260624T155654/receipt.json:78` | `git checkout da0479b8 -- Reports/default-scope-apply-20260624T155654/c6_trap_migration_r1fix.log` |
| `Reports/default-scope-apply-20260624T155654/final_c3_contract.log` | `562135ee8c0284b28d7fc59ded196c5adbc5c2d6583d273ecca1ac0842543716` | `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/Reports/default-scope-apply-20260624T155654/receipt.json:14` | `git checkout da0479b8 -- Reports/default-scope-apply-20260624T155654/final_c3_contract.log` |
| `Reports/default-scope-apply-20260624T155654/final_c3_pipeline.log` | `0fc832a174cb9ee67c2349f2596c22e9959f2b53a5dfccb125d02984f7b877bd` | `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/Reports/default-scope-apply-20260624T155654/receipt.json:22` | `git checkout da0479b8 -- Reports/default-scope-apply-20260624T155654/final_c3_pipeline.log` |
| `Reports/default-scope-apply-20260624T155654/final_c3_readback.log` | `09401811f1f68cd1004b711f00beb2fa0a32a574a7d59a3d7b0b7e1c88069f12` | `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/Reports/default-scope-apply-20260624T155654/receipt.json:30` | `git checkout da0479b8 -- Reports/default-scope-apply-20260624T155654/final_c3_readback.log` |
| `Reports/default-scope-apply-20260624T155654/final_c5_lora.log` | `b9950fb383be62ed7db0546a586ff0e75b96a3fc206932f7e2964061584467fa` | `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/Reports/default-scope-apply-20260624T155654/receipt.json:46` | `git checkout da0479b8 -- Reports/default-scope-apply-20260624T155654/final_c5_lora.log` |
| `Reports/default-scope-apply-20260624T155654/final_c6_bench.log` | `f6c83f23621a0015ea8af6b5384910e0cb7521927f0853612fcbf1180bc1d333` | `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/Reports/default-scope-apply-20260624T155654/receipt.json:54` | `git checkout da0479b8 -- Reports/default-scope-apply-20260624T155654/final_c6_bench.log` |
| `Reports/default-scope-apply-20260624T155654/final_git_diff_check.log` | `fa77ab6dcf895a30623113e37b6ee812c6cd35b0cbb9693a0c18de550e6b1cf6` | `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/Reports/default-scope-apply-20260624T155654/receipt.json:118` | `git checkout da0479b8 -- Reports/default-scope-apply-20260624T155654/final_git_diff_check.log` |
| `Reports/default-scope-apply-20260624T155654/final_make_verify.log` | `1ed59c624d45e1b02fb148bb90dc4b5d8f66cd33244a5edb01abfd2fc7653c15` | `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/Reports/default-scope-apply-20260624T155654/receipt.json:86` | `git checkout da0479b8 -- Reports/default-scope-apply-20260624T155654/final_make_verify.log` |
| `Reports/default-scope-apply-20260624T155654/final_make_verify_all.log` | `c86588a5d4d6bba06ef5021c2938c88ad82fde3e021c2705cb8631411037ca6f` | `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/Reports/default-scope-apply-20260624T155654/receipt.json:94` | `git checkout da0479b8 -- Reports/default-scope-apply-20260624T155654/final_make_verify_all.log` |
| `Reports/default-scope-apply-20260624T155654/final_openspec_all.log` | `25361f2f372668e94d814fc9606c1a1bfeb54683d0019b528adec08100335d35` | `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/Reports/default-scope-apply-20260624T155654/receipt.json:110` | `git checkout da0479b8 -- Reports/default-scope-apply-20260624T155654/final_openspec_all.log` |
| `Reports/default-scope-apply-20260624T155654/final_openspec_change.log` | `29b5d691b11038e9579f4f49b2b87aa9f8614ff838a5e1208a817887f7c27630` | `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/Reports/default-scope-apply-20260624T155654/receipt.json:102` | `git checkout da0479b8 -- Reports/default-scope-apply-20260624T155654/final_openspec_change.log` |
| `Reports/default-scope-apply-20260624T155654/final_tool_contract.log` | `9c8e7b544860a973f94aca24c29625b3b4445bbba5d8238dee1b51cd728b35c5` | `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/Reports/default-scope-apply-20260624T155654/receipt.json:38` | `git checkout da0479b8 -- Reports/default-scope-apply-20260624T155654/final_tool_contract.log` |
| `Reports/default-scope-apply-20260624T155654/final_verify_default_scope.log` | `801b9f5cf0dc86533b55f847b356aa0d9d5cfa306ec1c369777feb570aefa008` | `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/Reports/default-scope-apply-20260624T155654/receipt.json:62` | `git checkout da0479b8 -- Reports/default-scope-apply-20260624T155654/final_verify_default_scope.log` |
| `Reports/default-scope-apply-20260624T155654/receipt.json` | `d3d9070ea991ee63704183445ab54a0a7f50dd0e31f521e5b1e765aa8e377435` | `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/MANIFEST.sha256:224` | `git checkout da0479b8 -- Reports/default-scope-apply-20260624T155654/receipt.json` |
| `Reports/uiue-8c2-r3-closeout-20260628/closeout.md` | `798faff0b1db178cab8e6e28dc3ab897127202cfa654e4de26a02652e2439da4` | `docs/handoffs/2026-06-28-uiue-r4-burndown-commander-handoff.md:40`; `docs/grill-tournament/uiue-r3-residual-routing-to-r4-r5-2026-06-28.md:14`; `docs/grill-tournament/uiue-r3-residual-routing-to-r4-r5-2026-06-28.md:21`; `docs/grill-tournament/uiue-r3-residual-routing-to-r4-r5-2026-06-28.md:23`; `docs/grill-tournament/uiue-r4-human-review-packet-2026-06-28.md:29` | `git checkout da0479b8 -- Reports/uiue-8c2-r3-closeout-20260628/closeout.md` |
| `Reports/uiue-phase4a-proof/README.md` | `6de1b22f4488567c953ba31de0d853f2eb96dcac2e5b3d8dc083cff3e545ea20` | none | `git checkout da0479b8 -- Reports/uiue-phase4a-proof/README.md` |
| `Reports/uiue-phase4a-proof/ios-blocked_hard.png` | `4baf6d5303d4bec71aaf8d32681bbf5276c248880930c9a51497a215feb0afa3` | none | `git checkout da0479b8 -- Reports/uiue-phase4a-proof/ios-blocked_hard.png` |
| `Reports/uiue-phase4a-proof/ios-blocked_with_alternative.png` | `5eb9630a3831b4cd9f557fc0de321d446d30ff0b514cb683b9673c412b0b0732` | none | `git checkout da0479b8 -- Reports/uiue-phase4a-proof/ios-blocked_with_alternative.png` |
| `Reports/uiue-phase4a-proof/ios-changing.png` | `57284e8929eb24186f0c9e4e5bcd9dea0979a9fcd4f8cbba4ef40c5b44049d44` | none | `git checkout da0479b8 -- Reports/uiue-phase4a-proof/ios-changing.png` |
| `Reports/uiue-phase4a-proof/ios-coldstart-real.png` | `81006da1314f9e21a156365fb328f8f11fffb75ff58ddafda6f596e9caec7f7d` | `openspec/changes/ui-presentation/design.md:155` | `git checkout da0479b8 -- Reports/uiue-phase4a-proof/ios-coldstart-real.png` |
| `Reports/uiue-phase4a-proof/ios-normal.png` | `95fc113cf9c94997d296951e5b840e662218c74e76fd5c30631b35289f197ca2` | none | `git checkout da0479b8 -- Reports/uiue-phase4a-proof/ios-normal.png` |
| `Reports/uiue-phase4a-proof/ios-satisfied.png` | `17e95cf62a2d438c82f7f352711e744ff3ff16a5a8e8fc649f4092304ce5fcfa` | none | `git checkout da0479b8 -- Reports/uiue-phase4a-proof/ios-satisfied.png` |
| `Reports/uiue-phase4a-proof/ios-unknown.png` | `e9e1641e3392195a87392953cdf4ce838d9b1e4c57acaf37e3aa7e6b6a425416` | none | `git checkout da0479b8 -- Reports/uiue-phase4a-proof/ios-unknown.png` |
| `Reports/uiue-phase4a-proof/ios-unsafe.png` | `37ea429a6e2db498c3c030f9ae7e4482abb2dda52065cd128ebdf601a185a410` | none | `git checkout da0479b8 -- Reports/uiue-phase4a-proof/ios-unsafe.png` |
| `Reports/uiue-r4-burndown-preimplementation-20260628/closeout.md` | `a57111a267a804dc27e2b25d35f60ec69285aedda3f943a649ac47040445fa21` | `docs/handoffs/2026-06-28-uiue-r4-burndown-commander-handoff.md:48` | `git checkout da0479b8 -- Reports/uiue-r4-burndown-preimplementation-20260628/closeout.md` |
| `Reports/uiue-r4-burndown-preimplementation-20260628/dirty-ownership-manifest.md` | `0b6769c760b56c9bc4fcf3c9df6de769cc1de13f8906e27d714a4f05b4a15abf` | `docs/handoffs/2026-06-28-uiue-r4-burndown-commander-handoff.md:50`; `docs/handoffs/2026-06-28-uiue-r4-burndown-commander-handoff.md:153`; `docs/grill-tournament/uiue-r4-burndown-2026-06-28.md:69` | `git checkout da0479b8 -- Reports/uiue-r4-burndown-preimplementation-20260628/dirty-ownership-manifest.md` |
| `Reports/uiue-r4-burndown-preimplementation-20260628/hermes-audit-prompt.md` | `08fc25888a59c1a39e2248940ee876ee64f6d421b63f5f6faedab13547827a51` | none | `git checkout da0479b8 -- Reports/uiue-r4-burndown-preimplementation-20260628/hermes-audit-prompt.md` |
| `Reports/uiue-r4-burndown-preimplementation-20260628/hermes-audit.md` | `4647d54f985f6b95d45404475f2103534c3c791bb1333655cc73175367ca36d4` | `docs/handoffs/2026-06-28-uiue-r4-burndown-commander-handoff.md:49` | `git checkout da0479b8 -- Reports/uiue-r4-burndown-preimplementation-20260628/hermes-audit.md` |
| `Reports/uiue-r4-burndown-preimplementation-20260628/validation-summary.md` | `33c3d5a2369571d00190fb17f658f1b62bc389ea1730ece72cc158ef960b34b9` | `docs/grill-tournament/uiue-r4-burndown-2026-06-28.md:69` | `git checkout da0479b8 -- Reports/uiue-r4-burndown-preimplementation-20260628/validation-summary.md` |
| `Reports/uiue-r4-implementation-slice1-20260628/receipt.md` | `9637d7ac25de34ff6605cef6f2bcd4cffc8107d298066da455daf6ecefe4fa51` | `docs/dispatches/2026-06-28-uiue-r4-exit-preconditions-longrun-dispatch.md:93`; `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/MANIFEST.sha256:225`; `docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/Reports/uiue-r4-implementation-slice1-20260628/receipt.md:23` | `git checkout da0479b8 -- Reports/uiue-r4-implementation-slice1-20260628/receipt.md` |

## Execution guard

After commander runs the script, expected tracked count:

```bash
git ls-files Reports | wc -l
git ls-files Reports
```

Expected result: count `1`, path `Reports/.gitkeep`.

# C5 PR2/PR4/PR5 Audit Index

Run root: `Reports/c5-pr2pr4pr5-20260621T235213`

## Audit Reports

| PR | Subphase | Round | Report | Verdict | Notes |
| --- | --- | ---: | --- | --- | --- |
| PR2 | 2a clip-enabled repo-loop evidence | 1 | `codex-audit-pr2-2a-clip-enabled-r1.md` | PASS_WITH_NOTES | Core clip proof passed; 2b equivalence remains open. Notes: update events lacked per-update loss, and 2a did not bundle script snapshot. |
| PR2 | 2b stock-equivalence clip-off evidence | 1 | `codex-audit-pr2-2b-equivalence-r1.md` | PASS_WITH_NOTES | Equivalence proof passed; LR observation nuance documented. |
| PR2 | 2c source-state formal-training gate | 1 | `codex-audit-pr2-2c-source-state-r1.md` | PASS_WITH_NOTES | Source-state gate passed; final closeout must include loop script + marker in git, and downstream automation must honor blocked receipt status/exit code over rendered command files. |
| PR4 | 4a closeout truth table | 1 | `codex-audit-pr4-4a-closeout-truth-table-r1.md` | PASS_WITH_NOTES | Truth table passed with all 34 tasks; 3.1 limited to smoke-only evidence, 3.5 kept checked, 6.x/7.4 deferred to PR5. Note: archive remains pending until tombstones reduce remaining tasks to 0. |
| PR4 | 4b task tombstones | 1 | `codex-audit-pr4-4b-task-tombstones-r1.md` | PASS_WITH_NOTES | Tombstones passed: checkbox count remains 34, instructions state is all_done, validates pass, and no C6/eval/parity work is overclaimed. Note fixed: this INDEX now registers the audit. |
| PR4 | 4d archive | 1 | `codex-audit-pr4-4d-archive-r1.md` | PASS_WITH_NOTES | Archive passed: active change removed, archive files present, archived tasks 34/0 open, main spec synced with non-placeholder Purpose, validate 8/8. Note fixed: this INDEX now registers the audit. |
| PR5 | 5a change chain and preconditions | 1 | `codex-audit-pr5-5a-change-chain-r1.md` | PASS_WITH_NOTES | Change chain passed: define-lora-training is archived, PR5 modifies active lora-training, validate 9/9, and tasks remain execution-ready. Note fixed: this INDEX now registers the audit. |
| PR5 | 5b candidate training | 1 | `codex-audit-pr5-5b-candidate-training-r1.md` | FAIL | Training-health evidence passed, but receipts still referenced the old active `define-lora-training` change path and missed archived method-contract authority. Fixed in code/receipts before r2. |
| PR5 | 5b candidate training | 2 | `codex-audit-pr5-5b-candidate-training-r2.md` | PASS_WITH_NOTES | R1 contract-authority blocker fixed: prepare and run receipts record active spec, archive path, archived spec digest, and no stale active-change dependency. P3 missing-authority negative test was fixed after audit; focused tests now 24/24. |
| PR5 | 5c C6 eval and diagnostics | 1 | `codex-audit-pr5-5c-c6-eval-r1.md` | PASS_WITH_NOTES | Same-harness C6 hard-fail evidence passed and no candidate/V-PASS overclaim was found. R1 required fixes: uncheck 3.3 because semantic near-neighbor proof remained residual, and add adapter-normalization byte replay fingerprints. |
| PR5 | 5c C6 eval and diagnostics | 2 | `codex-audit-pr5-5c-c6-eval-r2.md` | PASS | R1 fixes verified: 3.3 remains open with near-neighbor limitation, receipt records normalized/original adapter config digests, weights symlink target/digest, build/package/invocation fingerprints, and C6 hard fail still blocks parity, endpoint V-PASS, and candidate signing. |
| PR5 | 5d parity and V-PASS split | 1 | `codex-audit-pr5-5d-parity-vpass-r1.md` | PASS | Blocked parity/V-PASS evidence passed: 4.1/4.2 correctly remain open-blocked after C6 hard fail, 4.3 records model-quality and physical endpoint V-PASS as separate blocked states, live device probes found no target physical iOS device, and candidate signing remains blocked. |
| PR5 | GPT Pro final audit | 1 | `gptpro-final-audit.md` | PASS_FOR_BLOCKED_CLOSEOUT | Heterogeneous final audit passed only for honest blocked/partial closeout. It explicitly keeps candidate signing `UNSIGNED / BLOCKED` because C6 hard-failed, semantic near-neighbor proof is incomplete, parity/endpoint byte parity were not run, and no target physical iOS endpoint receipt exists. |

# PR4 4b Task Tombstones Audit

Verdict: PASS_WITH_NOTES

## Findings
- P3 `Reports/c5-pr2pr4pr5-20260621T235213/audits/INDEX.md:7`-`Reports/c5-pr2pr4pr5-20260621T235213/audits/INDEX.md:12` does not yet include this PR4 4b audit report. This is not a tombstone or archive blocker because this report did not exist before this audit run, but it is a process traceability gap under the audit-index requirement. Concrete fix required: after this report is accepted, add an INDEX row for `codex-audit-pr4-4b-task-tombstones-r1.md` with verdict `PASS_WITH_NOTES` and note that tombstones reduced `define-lora-training` to `34/34/0`.

## Checks Run
- `grep -cE '^\s*- \[' openspec/changes/define-lora-training/tasks.md` => `34`.
- `openspec instructions apply --change define-lora-training --json` => `total=34`, `complete=34`, `remaining=0`, `state=all_done`.
- `openspec validate define-lora-training --strict` => `Change 'define-lora-training' is valid`.
- `openspec validate --all --strict` => 8 passed, 0 failed.
- 3.1 smoke-only/candidate boundary checked:
  - `openspec/changes/define-lora-training/tasks.md:17` marks 3.1 complete only as `smoke_only`, `train_eligible=false`, train-health evidence, and explicitly says it is not candidate readiness.
  - `Reports/c5-pr2pr4pr5-20260621T235213/pr4-closeout/c5-remediation-closeout.md:11` limits the 600-iteration run to train-health/smoke-chain evidence, not candidate quality.
  - `Reports/c5-pr2pr4pr5-20260621T235213/pr4-closeout/c5-remediation-closeout.md:29` says the smoke receipt completes 3.1 only and makes no candidate claim.
  - `jq` check on `Reports/c5-lora-training-20260621T1609-smoke-only-lr1e4-adamw/c5-training-receipt.json` returned `acceptance_stage=train_health`, `status=smoke_only_ready`, `train_eligible_count=0`, and `masking_stage_counts={"smoke_only":4956}`.
- 6.1 / 6.2 / 6.4 / 6.5 / 7.4 tombstone boundary checked:
  - `openspec/changes/define-lora-training/tasks.md:40`, `:41`, `:43`, `:44`, and `:53` now keep the original task rows checked only as `Tombstoned to run-lora-candidate-training`.
  - The same task rows say PR4 does not claim LoRA improvement, replay fingerprints require a PR5 candidate artifact, OOD lineage belongs to PR5, no dynamic/fused/quantized parity claim is made here, and V-PASS remains unsigned.
  - `Reports/c5-pr2pr4pr5-20260621T235213/pr4-closeout/c5-remediation-closeout.md:63`-`:67` and `:73` record those rows as `deferred_to_PR5`, not completed C6/eval/parity work.
  - `Reports/c5-pr2pr4pr5-20260621T235213/pr4-closeout/c5-remediation-closeout.md:99`-`:101` explicitly disclaim PR5 candidate quality, C6 improvement, held-out generalization, fuse parity, endpoint byte parity, physical-device V-PASS, and GPT Pro final-audit replacement.
- §8 Remediation Truth Gates checked:
  - `openspec/changes/define-lora-training/tasks.md:56`-`:67` is a markdown table, not checkbox rows, so it does not alter the 34-row baseline.
  - The table records `3.1 smoke-only` as train-health only and tombstones C6 diff, replay fingerprints, OOD probes, dynamic/fused/quantized parity, and endpoint byte/device V-PASS to `run-lora-candidate-training`.
- Closeout/archive state checked:
  - `Reports/c5-pr2pr4pr5-20260621T235213/pr4-closeout/c5-remediation-closeout.md:5` says `PR4_TOMBSTONES_APPLIED_ARCHIVE_READY_PENDING_ARCHIVE_RUN`, which is consistent with the command state now reporting `remaining=0`.
  - `Reports/c5-pr2pr4pr5-20260621T235213/pr4-closeout/c5-remediation-closeout.md:87`-`:95` lists the remaining pre-archive mechanical checks; all command checks requested for 4b passed in this audit.

## Notes
- No P0/P1/P2 findings.
- No stale closeout overclaim found for candidate readiness or C6/parity completion.
- `git status --short` still shows the PR4 task file, reports, training loop, verification marker, and other PR2/PR4 artifacts as uncommitted/untracked. That is outside this 4b tombstone audit, but final archive/commit hygiene still needs to preserve the source-state marker and training loop script.

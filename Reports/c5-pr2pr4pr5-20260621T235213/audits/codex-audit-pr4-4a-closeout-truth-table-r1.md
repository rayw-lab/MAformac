# PR4 4a Closeout Truth Table Audit

Verdict: PASS_WITH_NOTES

## Findings
- P3 `Reports/c5-pr2pr4pr5-20260621T235213/pr4-closeout/c5-remediation-closeout.md:5` uses `PR4_READY_FOR_TASK_MIGRATION_AND_ARCHIVE`, while the live OpenSpec instruction state still reports 34 total / 28 complete / 6 remaining. This is not blocking for the 4a truth-table closeout because the same report explicitly records the 6-row migration scope at `Reports/c5-pr2pr4pr5-20260621T235213/pr4-closeout/c5-remediation-closeout.md:27` and the pre-archive `remaining=0` gate at `Reports/c5-pr2pr4pr5-20260621T235213/pr4-closeout/c5-remediation-closeout.md:88`. Concrete fix before archive: either apply the tombstones so `openspec instructions apply --change define-lora-training --json` reports `remaining=0`, or narrow the status string to `PR4_READY_FOR_TASK_MIGRATION; ARCHIVE_PENDING_TOMBSTONES`.

## Checks Run
- `grep -cE '^\s*- \[' openspec/changes/define-lora-training/tasks.md` => `34`.
- Truth-table extraction from `Reports/c5-pr2pr4pr5-20260621T235213/pr4-closeout/c5-remediation-closeout.md` found 34 task rows, each task id `1.1` through `7.5` exactly once. The table spans `Reports/c5-pr2pr4pr5-20260621T235213/pr4-closeout/c5-remediation-closeout.md:38`.
- `openspec instructions apply --change define-lora-training --json` => `total=34`, `complete=28`, `remaining=6`. This matches the closeout's migration-scope claim, not an archive-complete state.
- 3.1 smoke-only evidence checked:
  - `Reports/c5-lora-training-20260621T1609-smoke-only-lr1e4-adamw/c5-training-receipt.json:2` has `acceptance_stage=train_health`.
  - `Reports/c5-lora-training-20260621T1609-smoke-only-lr1e4-adamw/c5-training-receipt.json:269` has `status=smoke_only_ready`.
  - `Reports/c5-lora-training-20260621T1609-smoke-only-lr1e4-adamw/c5-training-receipt.json:270` has `train_eligible_count=0`.
  - `Reports/c5-lora-training-20260621T1609-smoke-only-lr1e4-adamw/mlx-smoke-600iter-lr1e4-adamw.log:78` and `:79` show final iter 600 val/train metrics. The closeout limits 3.1 to train-health/smoke-chain evidence at `Reports/c5-pr2pr4pr5-20260621T235213/pr4-closeout/c5-remediation-closeout.md:11` and `:48`.
- 3.5 masking coverage checked:
  - PR3 final receipt records all four `masking_coverage` fields true at `Reports/c5-remediation-wave-20260621T2013-pr3-full/prepare-final-v3/c5-training-receipt.json:184`.
  - PR2 2c prepare probe records all four fields true at `Reports/c5-pr2pr4pr5-20260621T235213/pr2-2c-source-state-prepare-probe/c5-training-receipt.json:189`.
  - This supports keeping 3.5 checked, consistent with dispatch guidance at `/Users/wanglei/workspace/raw/05-Projects/MAformac/dispatches/2026-06-21-c5-pr2-pr4-pr5-superdispatch.md:103`.
- 6.1 / 6.2 / 6.4 / 6.5 / 7.4 checked:
  - Current task file leaves these open at `openspec/changes/define-lora-training/tasks.md:40`, `:41`, `:43`, `:44`, and `:53`.
  - The closeout marks them `deferred_to_PR5`, not substantively complete, at `Reports/c5-pr2pr4pr5-20260621T235213/pr4-closeout/c5-remediation-closeout.md:62`, `:63`, `:65`, `:66`, and `:72`.
  - This matches the dispatch requirement to tombstone/migrate these C6/candidate tasks to `run-lora-candidate-training`, not delete or fake-complete them, at `/Users/wanglei/workspace/raw/05-Projects/MAformac/dispatches/2026-06-21-c5-pr2-pr4-pr5-superdispatch.md:106`.
- Local evidence refs named in the closeout were checked with `test -s`: PR2 2a/2b summaries, PR2 2c receipt/summary, audit index, smoke receipt/log, PR3 final receipt, verification marker, proposal/spec/code/test refs, and generated sample JSONL all exist and are nonempty.
- Source-state JSON path checked:
  - Closeout says receipt source-state is nested under `environment.training_loop_source_state` at `Reports/c5-pr2pr4pr5-20260621T235213/pr4-closeout/c5-remediation-closeout.md:20`.
  - `Reports/c5-pr2pr4pr5-20260621T235213/pr2-2c-source-state-prepare-probe/c5-training-receipt.json:81` confirms `training_loop_source_state=verified` under `environment`; top-level `training_loop_source_state`/`source_state` were null in `jq`.
  - `Tools/C5TrainingCLI/c5_mlx_train_loop.verification.json:2` separately stores the marker's top-level `source_state=verified`, which is consistent with the closeout distinction.
- `openspec validate define-lora-training --strict` passed. `openspec validate --all --strict` passed 8/8.

## Notes
- No P0/P1/P2 issues found in the 4a closeout truth table.
- No overclaim found for candidate readiness: the closeout states `PR5_BLOCKED`, disclaims C6 improvement / fuse parity / endpoint byte parity / physical-device V-PASS, and aligns with the T-PASS/V-PASS split in `docs/lessons-learned.md:34`.
- `git status --short` currently shows the PR4 closeout, audit directory, training loop, and verification marker as untracked. That is outside the 4a truth-table claim, but before final commit/archive the durability point in `docs/lessons-learned.md:52` still applies.

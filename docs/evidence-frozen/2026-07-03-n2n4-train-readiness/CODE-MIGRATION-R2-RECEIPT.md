---
artifact_kind: code_data_basis_migration_receipt
status: pass_local_registry_patch_emitted
proof_class: local/integration/diagnostic_smoke
created_at: 2026-07-03 16:15:00 CST
owner_lane: "%44"
scope: PR #38 CODE + PR38-final DATA coupled basis migration R2
---

# CODE-MIGRATION-R2-RECEIPT

## Verdict

`PASS_LOCAL_CODE_DATA_COUPLED_MIGRATION_R2`.

Registry patch emitted but not applied:

`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/CODE-basis-migration-r2-pr38-26678346/BASELINE-REGISTRY-CODE-DATA-PR38-R2.patch`

This is still not train-ready / not V-PASS. It proves the PR38 CODE pin and rebuilt DATA v3 pass the migration gates locally.

## Basis

| field | value |
|---|---|
| old_code_basis | `CODE-2026-07-03` / `b33d8eba152e5326f69bbe85fc356b73419ee9c3` |
| new_code_basis | `CODE-2026-07-03-PR38` / `266783468ac38542574ea4787bec650d16ba6b02` |
| old_data_basis | `DATA-WAVE1-SUBSTRATE-v2` / `PR31-final-n4a-recipe-build/` |
| new_data_basis | `DATA-WAVE1-SUBSTRATE-v3` / `PR38-final-n4a-recipe-build/` |
| worktree | `/tmp/maformac-code-basis-pr38-26678346` |
| run_dir | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/CODE-basis-migration-r2-pr38-26678346/` |
| registry_event_anchor | D-069 in `docs/commander-log/decisions.md` |

## DATA v3 Build

Prepare command matched PR31-final N4A recipe knobs:

```bash
swift run C5TrainingCLI prepare \
  --output-dir /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR38-final-n4a-recipe-build \
  --target-positive 4500 \
  --dev-selection 400 \
  --masking-stage trainable_v0 \
  --theta-alpha-positive-only \
  --scope demo \
  --surface d_domain
```

Prepare result:

| field | value |
|---|---:|
| exit | 0 |
| status | `step2_dry_run_ready` |
| row_count | 4500 |
| train_eligible_count | 4100 |
| dev_selection_count | 400 |
| refusal_ratio_target / hard_cap / observed | `0 / 0 / 0` |
| no_call_counterfactual_count | 0 |
| route_tier_counts | `fc_l2=2845`, `fc_l3=948`, `rule_l1=307` |
| masking_stage_counts | `trainable_v0=4500` |

Important lineage note: prepare-only output still omitted `hash_recipe_ref` and `hash_recomputed_by_pipeline` in sample JSON, although prompt/signature hashes were already present. I preserved the raw prepare output as:

`PR38-final-n4a-recipe-build/samples/c5-training-samples.prepare-raw.jsonl`

Then I ran a run-dir projection script that recomputed/validated prompt/signature values and added the two DataGate metadata fields. Projection report:

`CODE-basis-migration-r2-pr38-26678346/hash-field-projection-report.json`

Projection counts:

| field | value |
|---|---:|
| row_count | 4500 |
| changed_prompt_hash | 0 |
| changed_expected_tool_call_signature | 0 |
| added_hash_recipe_ref | 4500 |
| added_hash_recomputed_by_pipeline | 4500 |

## Gate Results

| gate | exit | verdict | key evidence |
|---|---:|---|---|
| DATA prepare | 0 | PASS | `step2_dry_run_ready`, 4500 rows, refusal 0/0/0. |
| hash-field projection | 0 | PASS | Added `hash_recipe_ref` and `hash_recomputed_by_pipeline=true` to 4500 rows; prompt/signature unchanged. |
| DataGate | 0 | PASS | `status=data_gate_ready`, row_count 4500, dev_selection 400, train 4100, quarantine 0, failure_count 0. |
| strict preflight | 0 | PASS | 4628 records / 4628 trainable, trainable_tokens 113745, `length_violations=[]`, ratio/parser critical pass. |
| T1D-D2combo repo-config smoke | 0 | PASS | repo loop source, `source_snapshot=null`, 2 optimizer updates, adapter saved, OOM absent, peak 17.868956778 GB. |
| Python/static filter | 0 | PASS | `py_compile`, token-budget self-test, loss-mask self-test, `git diff --check`. |
| Swift filter | 0 | PASS | `swift test --filter 'C5DataGateTests|C5LoRATrainingTests|Gate7GeneratorPipelineTests'`: 111 tests, 0 failures. |
| registry patch dry-run | 0 | PASS | `patch -p1 --dry-run` applied cleanly to a temp copy. |

## T1D Smoke Resource Envelope

| resource field | observed |
|---|---:|
| watchdog_seconds | 2100 |
| wall_clock | 2026-07-03T08:04:46Z -> 2026-07-03T08:12:18Z |
| optimizer_update_count | 2 |
| train_report_count | 1 |
| val_loss_iteration_1 | 2.914937734603882 |
| val_loss_iteration_8 | 3.095 |
| train_loss_iteration_8 | 2.9722046852111816 |
| max_peak_memory_gb | 17.868956778 |
| max_peak_memory_bytes_1e9 | 17868956778 |
| 32GB hard gate | PASS |
| adapter_sha256 | `d6abc4cf5bea5b6fa67c1e521d2da8f468e4c07e39228b59f4aec83c1895ec84` |

Metrics confirmed:

- `grad_checkpoint=true`
- `token_budget_per_batch=8192`
- `clear_cache_before_train=true`
- `source_snapshot=null`
- `training_loop_source_sha256=9714f6f2700a4c0f77be6bfdc005d291a894e858606a87a1a3838fd9a8f71748`

## Artifact Hashes

| artifact | sha256 |
|---|---|
| `PR38-final-n4a-recipe-build/samples/c5-training-samples.jsonl` | `cbd396d72921bb88001a09a4104586dc332215d6a30b4294156f5f1ad031153d` |
| `PR38-final-n4a-recipe-build/c5-training-receipt.json` | `ac14a52bb6eafc5d64266461f3fab08cc3006452da9a04a1956dbe88d6cfc943` |
| `PR38-final-n4a-recipe-build/mlx-lora-config.yaml` | `e8e2aee8cbc4c9b4e6fb950ceeb1a4d886f915eb22ac035a46804973cd2fd765` |
| `PR38-final-n4a-recipe-datagate/c5-data-gate-receipt.json` | `01bb4a1f4ab226181927cf2d951bd882d8697e25f89d23a78395852f1725fc97` |
| `strict-preflight.metrics.jsonl` | `3aeafcf2c812ae6d47187e5c9af7e8b6bda9163775cc17904ebcd430f4f3cbc6` |
| `t1d-d2combo-r2-config-smoke.metrics.jsonl` | `2499d2d49bdf1288092e54d77a8bfb92c008234d7947d4b526fb0f6793e123c2` |
| `t1d-d2combo-r2-adapters-rank16/adapters.safetensors` | `d6abc4cf5bea5b6fa67c1e521d2da8f468e4c07e39228b59f4aec83c1895ec84` |
| `BASELINE-REGISTRY-CODE-DATA-PR38-R2.patch` | `bd6b1509fb6a735cc959b4ab2290498170f9d570ce030dd95deda9fd55dd449c` |

## Registry Patch Summary

Patch file:

`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/CODE-basis-migration-r2-pr38-26678346/BASELINE-REGISTRY-CODE-DATA-PR38-R2.patch`

Changes:

1. Live CODE row migrates from `CODE-2026-07-03` to `CODE-2026-07-03-PR38`.
2. Live DATA row migrates from `DATA-WAVE1-SUBSTRATE-v2` to `DATA-WAVE1-SUBSTRATE-v3`.
3. Supersede history adds old CODE pin row.
4. Supersede history adds old DATA v2 row and records that v3 uses prepare + hash-field projection.

The patch was dry-run applied to a temp copy with exit 0. It was not applied to the main worktree.

---
artifact_kind: code_basis_migration_receipt
status: failed_no_registry_patch
proof_class: local/integration/diagnostic_smoke_attempt
created_at: 2026-07-03 15:51:57 CST
owner_lane: "%44"
scope: PR #38 merge-time CODE baseline migration rerun
---

# CODE-MIGRATION-RECEIPT

## Verdict

`FAIL_DATAGATE_AND_SMOKE_INCOMPLETE`.

Do not migrate `docs/BASELINE-REGISTRY.md` yet. Keep live CODE basis as `CODE-2026-07-03` / `b33d8eba152e5326f69bbe85fc356b73419ee9c3`.

Reason: checklist stop condition says any rerun gate failure keeps the old CODE row and writes a failure receipt. This run has two hard failures:

1. DataGate exit `65`, `status=blocked`, because PR31-final samples lack the now fail-closed derived hash fields.
2. T1D-D2combo repo-config smoke loaded the PR38 controls and reached one optimizer update, but did not complete final adapter weight save inside the 20 minute watchdog window.

`registry_patch_emitted=false`; no `BASELINE-REGISTRY` patch is safe to apply from this run.

## Basis

| field | value |
|---|---|
| old_code_basis_id | `CODE-2026-07-03` |
| old_code_pin | `b33d8eba152e5326f69bbe85fc356b73419ee9c3` |
| proposed_new_code_basis_id | `CODE-2026-07-03-PR38` |
| proposed_new_code_pin | `266783468ac38542574ea4787bec650d16ba6b02` |
| PR38 merge status | `MERGED`, merge commit `266783468ac38542574ea4787bec650d16ba6b02` |
| data_basis_id | `DATA-WAVE1-SUBSTRATE-v2` |
| data_baseline | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR31-final-n4a-recipe-build/` |
| isolated worktree | `/tmp/maformac-code-basis-pr38-26678346` |
| run artifacts | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/CODE-basis-migration-pr38-26678346/` |

Registry authority checked in the main worktree branch: `docs/BASELINE-REGISTRY.md:14` still binds `CODE-2026-07-03`; `docs/BASELINE-REGISTRY.md:30` requires decision log, registry update, and rerun checklist for migration.

## Gate Results

| gate | command artifact | exit | verdict | key evidence |
|---|---:|---:|---|---|
| PR38 trigger / pin | `pr38-after-merge.json`, `basis-pin.env` | 0 | PASS | `origin/main=266783468ac38542574ea4787bec650d16ba6b02`; PR38 merge commit matches. |
| strict preflight | `strict-preflight.log`, `strict-preflight.metrics.jsonl` | 0 | PASS | `records=4628`, `trainable_records=4628`, `trainable_tokens=113914`, `length_violations=[]`, script sha `9714f6f2700a4c0f77be6bfdc005d291a894e858606a87a1a3838fd9a8f71748`. |
| DataGate | `datagate/c5-data-gate-receipt.json`, `datagate.log` | 65 | FAIL | `status=blocked`, `row_count=4500`, `dev_selection=400`, `train=4100`, `must_not_train_violations=0`, `missing_surface_count=0`, `redaction_status=pass`; 9000 P0 failures from `hash_recomputed_by_pipeline_missing_or_false` and `hash_recipe_ref_missing`. |
| T1D-D2combo repo-config smoke | `t1d-d2combo-config-smoke.log`, `t1d-d2combo-config-smoke.metrics.jsonl` | no clean exit file | FAIL | `grad_checkpoint=true`, `token_budget_per_batch=8192`, `clear_cache_before_train=true`, `source_snapshot=null`; reached `optimizer_update` at iteration 4 with finite `loss=2.6636284589767456` and `grad_norm_preclip=184.70681762695312`; no `adapters.safetensors` saved. |
| Python filter/static | `filter-pycompile.log`, `filter-selftest-token-budget.log`, `filter-selftest-loss-mask.log`, `filter-diff-check.log` | 0 | PASS | `py_compile`, token-budget self-test, loss-mask self-test, and `git diff --check` all exit 0. |
| Swift filter tests | `filter-swift.log` | 0 | PASS | `swift test --filter 'C5DataGateTests|C5LoRATrainingTests|Gate7GeneratorPipelineTests'`: 111 tests, 0 failures. |

## Commands

Strict preflight:

```bash
/opt/homebrew/opt/python@3.13/bin/python3.13 \
  /tmp/maformac-code-basis-pr38-26678346/Tools/C5TrainingCLI/c5_mlx_train_loop.py \
  --train --preflight-only \
  --model /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR31-final-n4a-recipe-build/qwen3-1_7b-training-tokenizer-patched \
  --data /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR31-final-n4a-recipe-build/mlx-data \
  --config /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR31-final-n4a-recipe-build/mlx-lora-config.yaml \
  --require-maformac-loss-mask --max-seq-length 8192 \
  --metrics-jsonl "$RUN/strict-preflight.metrics.jsonl"
```

DataGate:

```bash
swift run C5DataGateCLI \
  --repo-root /tmp/maformac-code-basis-pr38-26678346 \
  --candidates /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR31-final-n4a-recipe-build/samples/c5-training-samples.jsonl \
  --source-digest-path /tmp/maformac-code-basis-pr38-26678346/contracts/semantic-function-contract.jsonl \
  --source-authorization authorized_c1_semantic_contract \
  --output-dir "$RUN/datagate"
```

T1D-D2combo repo-config smoke:

```bash
/opt/homebrew/opt/python@3.13/bin/python3.13 \
  /tmp/maformac-code-basis-pr38-26678346/Tools/C5TrainingCLI/c5_mlx_train_loop.py \
  --train \
  --model /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR31-final-n4a-recipe-build/qwen3-1_7b-training-tokenizer-patched \
  --data /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR31-final-n4a-recipe-build/mlx-data \
  --config "$RUN/t1d-d2combo-config-smoke.yaml" \
  --require-maformac-loss-mask --max-seq-length 8192 \
  --batch-size 4 --iters 8 --val-batches 25 \
  --token-budget-per-batch 8192 --grad-checkpoint --clear-cache-before-train \
  --adapter-path "$RUN/t1d-d2combo-adapters-rank16" \
  --metrics-jsonl "$RUN/t1d-d2combo-config-smoke.metrics.jsonl"
```

Filter/static:

```bash
/opt/homebrew/opt/python@3.13/bin/python3.13 -m py_compile Tools/C5TrainingCLI/c5_mlx_train_loop.py
/opt/homebrew/opt/python@3.13/bin/python3.13 Tools/C5TrainingCLI/c5_mlx_train_loop.py --self-test-token-budget-batches
/opt/homebrew/opt/python@3.13/bin/python3.13 Tools/C5TrainingCLI/c5_mlx_train_loop.py --self-test-loss-mask
git diff --check
swift test --filter 'C5DataGateTests|C5LoRATrainingTests|Gate7GeneratorPipelineTests'
```

## Resource Envelope

| stage | observed resource envelope | threshold status |
|---|---:|---|
| strict preflight | training not entered; no MLX peak gate applicable | PASS for preflight only |
| DataGate | Swift gate, no MLX training memory | FAIL for schema/hash gate, not resource |
| T1D smoke validation cache before boundary clear | `24,417,749,224` bytes cache before clear, `0` after `mx.clear_cache` | cache boundary control observed |
| T1D smoke train peak | not emitted; no `train_report` before watchdog/wrapper exit | FAIL to prove `peak<32GB` |
| T1D smoke optimizer update | one `optimizer_update` row at iteration 4 | partial runtime evidence only |
| T1D smoke adapter weights | `0` `*.safetensors` files; only `adapter_config.json` exists | FAIL |

## Artifact Hashes

| artifact | sha256 |
|---|---|
| `strict-preflight.metrics.jsonl` | `eadb78d2cc5a8db9f37b8f68c03ea93701b543e57e9cdb4652447cad3d9d21ba` |
| `datagate/c5-data-gate-receipt.json` | `bd585d44ac095805fecc7a92af8d0156423177f25c25aba0859926dd4aa2ba2d` |
| `t1d-d2combo-config-smoke.metrics.jsonl` | `880b7ef3186372b2526958420961d71578653e9d2c4006452615ea1af09088e4` |
| `t1d-d2combo-config-smoke.yaml` | `cd11fdb893fdeb20f5fdf2f6c44156a07ac25d49341b6bd5271b9316cc3e35ca` |
| `filter-swift.log` | `7afd29940e74ca2a51754df39c156783ae4d8ad88231554a3c4e23a4a5457edf` |

## Manifest Pin Backfill Values

Do not apply these into a selected candidate manifest yet. They are the values to use only after the DataGate hash-field issue is fixed and the migration gates rerun green.

```yaml
candidate_status: blocked_basis_migration
basis_id:
  code: CODE-2026-07-03-PR38
  data: DATA-WAVE1-SUBSTRATE-v2
code_pin: 266783468ac38542574ea4787bec650d16ba6b02
code_source: origin/main
training_loop_source: /tmp/maformac-code-basis-pr38-26678346/Tools/C5TrainingCLI/c5_mlx_train_loop.py
training_loop_source_sha256: 9714f6f2700a4c0f77be6bfdc005d291a894e858606a87a1a3838fd9a8f71748
data_baseline: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR31-final-n4a-recipe-build/
config_knobs:
  token_budget_per_batch: 8192
  grad_checkpoint: true
  clear_cache_before_train: true
gate_receipts:
  strict_preflight: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/CODE-basis-migration-pr38-26678346/strict-preflight.metrics.jsonl
  datagate: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/CODE-basis-migration-pr38-26678346/datagate/c5-data-gate-receipt.json
  smoke_metrics: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/CODE-basis-migration-pr38-26678346/t1d-d2combo-config-smoke.metrics.jsonl
```

## Next Required Fix Before Migration

Regenerate or repair the PR31-final sample corpus so DataGate sees pipeline-recomputed hash fields:

- `hash_recomputed_by_pipeline=true`
- `hash_recipe_ref=<repo-relative C5DerivedHashRecipe anchor>`

Then rerun this migration checklist from scratch on the same or newer CODE pin. A registry patch should be emitted only after DataGate and T1D smoke both pass.

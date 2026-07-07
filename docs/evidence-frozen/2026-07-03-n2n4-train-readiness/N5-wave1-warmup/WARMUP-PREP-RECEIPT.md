# WARMUP-PREP receipt

- status: DONE
- proof_class: local_order_plus_mock_dryrun
- repo: `/Users/wanglei/workspace/MAformac-p5w-wave1-bridge`
- base: `origin/main@266783468ac38542574ea4787bec650d16ba6b02`
- source_branch: `main`
- source_commit: `266783468ac38542574ea4787bec650d16ba6b02`
- p2_hash_ref_fix: already_on_origin_main `1526a26bab943d3aba0ae26bb430b74f6a60c4c2` (PR #37)

## P2 Fix

- `hash_recipe_ref` is repo-relative/symbolic: `repo:Core/Training/C5LoRATraining.swift#C5DerivedHashRecipe.promptHash(utterance:);repo:Core/Training/C5LoRATraining.swift#C5DerivedHashRecipe.expectedToolCallSignature(renderedToolCall:);repo:Core/Bench/C6VehicleToolBench.swift#C6Hash.sha256Hex`
- No worktree absolute path is present in the active hash recipe ref.
- DataGate validates the same anchor token set via `C5DerivedHashRecipe.hashRecipeAnchorTokens`.

## Warmup Batch Order

- order: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-01-order.json`
- order_sha256: `94784d4306227765588abdcd857cd966b721aa0b684456c0fb9df39028dc2118`
- lane_prompt_package: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-prompt-package.md`
- lane_prompt_package_sha256: `9b68b73faa8925f0824fa407e58eb8acf8e06d3f8f937345179268894f85c8e5`
- builder_manifest: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/builder-dryrun/wave1-warmup-batch-manifest.json`
- builder_manifest_sha256: `83e8ad6a387d88e9d8f78adeedb878ac4e6a033ca6ee40538663fee4ac4a953f`
- builder_manifest_dry_run: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/builder-dryrun/wave1-warmup-batch-manifest-dry-run.json`
- builder_manifest_dry_run_sha256: `557a476f9cc261dd1c1282110e543a733c4f06e60a45aff2551a57b5079df438`
- builder_dryrun_receipt: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/builder-dryrun/gate7-wave1-dry-run-receipt.json`
- builder_dryrun_receipt_sha256: `ecd2453ee3e1415b9379dd8bcbe2b78d1a0ec2ddef68db238d07676df2ccd84f`

## Key Fields

- batch_id: `warmup-batch-01`
- target_count: `50`
- warmup_phase: `true`
- main_pin_sha: `b33d8eba152e5326f69bbe85fc356b73419ee9c3`
- quota_config_source: `Gate7RecipeQuotaConfig.wave1ConstructionAnchors`
- quota_source: `intent_bug_scene_recovery`
- quota_manual_override: `false`
- refusal_ratio_target: `0`
- hash_recomputed_by_pipeline_required: `true`

## Dry-Run Evidence

- pipeline_status: `PASS`
- sample_count: `50`
- data_gate_status: `data_gate_ready`
- batch_manifest_dry_run_status: `pass`
- recipe_allocated_quota: `50`
- recipe_actual_sample_count: `50`
- data_gate_hard_failure: `false`
- data_gate_missing_surface_count: `0`

## Validation

```bash
swift run Gate7DryRunCLI --output-dir /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/builder-dryrun --limit 50 --batch-id warmup-batch-01 --lane-id subcc-1 --main-pin-sha b33d8eba152e5326f69bbe85fc356b73419ee9c3
# status=PASS samples=50 data_gate=data_gate_ready manifest=pass quarantine=1

jq empty /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-01-order.json
# pass

swift test --filter C5DataGateTests
# 27/27 passed

swift test --filter Gate7GeneratorPipelineTests
# 13/13 passed
```

## Boundary

- Order and prompt package only.
- Mock dry-run evidence only; no live generation, no judge pool, no training input writes.

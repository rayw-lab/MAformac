# F044 R2 Mount Rollback Ready Receipt

- artifact_kind: f044_r2_mount_rollback_data_ready_receipt
- status: mount_rollback_ready_preflight_pass_no_train
- captured_at: 2026-07-03T23:13:01+08:00
- proof_class: local + unit + data_preflight
- training_state: prep_only_no_train_no_optimizer_update
- render_format_version: r2_action_tagged_protocol_v1
- output_root: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r2-data-ready`

## Verdict

MOUNT-ROLLBACK-READY. R2 combined samples now keep the round1 `tools` mount set exactly by `sample_id`; the only intended R2 protocol-surface change retained is the `action=` user segment, plus deterministic seeded shuffle order inside the same mount set.

## Inputs

| Input | Path | sha256 |
|---|---|---|
| round1 mount truth samples | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-shorttrain-data-ready/samples/c5-training-samples.jsonl` | `ac23b7b4c8f463ef34fa279da9549985770bd27ed0b32f8e0682dd715ac78049` |
| R2 action-tagged protocol samples | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/samples-rerendered/samples/c5-training-samples.jsonl` | `67b7da15b17ab0515419a9dcd819f34a1bc7f14133c48754e79029665b14fc07` |
| wave-1 corpus 250 natural samples | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/wave1-corpus-final/wave1-corpus.jsonl` | `e6ff61cb87d90cfbc6fdcc73c0da063b69c49f6a9d09f50064ec8f1c9b9f3afb` |

## Generated Artifacts

| Artifact | Path | sha256 |
|---|---|---|
| combined samples | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r2-data-ready/samples/c5-training-samples.jsonl` | `59f2f74e6798bc3e3cf62c3fe21858ca0804c69814ffe07b859423f1bd4c6467` |
| mlx train | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r2-data-ready/mlx-data/train.jsonl` | `67bffb9efdf9788424f1e584d44d7a37fa9616f77c7a42c4cb9e2a821ad538f8` |
| mlx valid | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r2-data-ready/mlx-data/valid.jsonl` | `e9daec004b77baba514369ea01f164c36173b740dd513721f8b85a4d4697b795` |
| mlx test | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r2-data-ready/mlx-data/test.jsonl` | `edd91f5a12fe3bcb92bb527ef9416a1a5b76e7ba2e83a56dfbbe713d09ec98be` |
| mount rollback summary | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r2-data-ready/mount-rollback-generation-summary.json` | `717a6cd9b1e20daabec69ee9d9a3d69119d9d2e8a8738fa855fafbde9acd7325` |
| scanner summary | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r2-data-ready/supervision-consistency-summary.json` | `c73fe26beee65d5cb4cde04154adda33c0686b37f362f7c967dcffeff975eb9b` |
| DataGate receipt | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r2-data-ready/datagate/c5-data-gate-receipt.json` | `1f887b5e128407a54e40d02f4f5299c97b5a16956dd5262464bfe84f72148d6f` |
| strict preflight metrics | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r2-data-ready/strict-preflight.metrics.jsonl` | `6580e4ff3995d5fe1709f997dc2618e30e2011c006a9db53890b26e754d1f365` |

## Mechanical Assertions

| Check | Result |
|---|---|
| samples rows | 4750 |
| protocol rows | 4500 |
| corpus rows | 250 |
| protocol rows containing `action=` | 4500/4500 |
| corpus rows containing `action=` | 0/250 |
| mount count diff vs round1 | 0 rows |
| mount tool-name set diff vs round1 | 0 rows |
| average mount count old -> new | 13.850105263157895 -> 13.850105263157895 |
| mlx split records | train 4350 / valid 400 / test 128 |

Implementation note: `tools` were restored from round1 samples by exact `sample_id`, then shuffled with the existing deterministic `sha256(sample_id|tool_name)` order. This preserves the old mount set while removing fixed sibling order bias.

## Gates

| Gate | Command Surface | Result |
|---|---|---|
| supervision consistency scanner | `tools/supervision_consistency_scanner.py --fail-on-contradiction --fail-on-mount-order` | status=pass_no_contradictions; contradiction_group_count=0; mount_order_status=pass; open_first=830 close_first=815 |
| C5DataGate | `swift run C5DataGateCLI ...` | status=data_gate_ready; rows=4750; must_not_train_violations=0; train_parent_semantic_overlap=0 |
| strict preflight | `c5_mlx_train_loop.py --train --preflight-only --require-maformac-loss-mask ...` | exit0; records=4878; trainable_records=4878; trainable_tokens=119571; ignored_tokens=17028936; max_token_length=7196; length_violations=0 |
| Swift related tests | `swift test --filter C5LoRATrainingTests` | 44 tests, 0 failures |

Strict preflight run metadata: mlx-lm=0.31.1; script_sha256=9714f6f2700a4c0f77be6bfdc005d291a894e858606a87a1a3838fd9a8f71748; token_budget_per_batch=8192; grad_checkpoint=True; clear_cache_before_train=True; grad_clip_norm=1.0.

## R3 Proposal Only, Not Applied Tonight

The rejected sibling-focused mount reduction had a plausible R3 design motive: it reduces prompt token budget and makes the visible choice set concentrate on same-family polarity/value contrasts. That is a second variable for model behavior and eval comparability, so it is intentionally not in this R2 artifact. Any future use needs a separate R3 grill decision, a paired eval plan, and a baseline-vs-focused mount ablation.

## Stop Conditions Checked

- No train command beyond `--preflight-only` was run.
- No optimizer update was run.
- If mount count or tool-name set diff had been nonzero, this receipt would be BLOCKED; actual diff is zero.
- If scanner/DataGate/strict preflight had failed, R2 data would remain blocked; all three passed locally.

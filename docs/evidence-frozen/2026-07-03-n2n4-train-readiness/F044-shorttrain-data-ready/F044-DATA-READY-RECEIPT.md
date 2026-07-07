# F044 Data-Ready Receipt

status: data_ready_preflight_pass_no_train
artifact_kind: f044_shorttrain_data_ready_receipt
proof_class: local/data_preflight

## Scope

This receipt covers only DATA-WAVE1-SUBSTRATE-v3 plus the wave-1 250-row corpus rendered into a short-train MLX data directory. It does not run optimizer updates, save adapters, evaluate model quality, claim train-ready, or claim V-PASS.

## Inputs

| item | value |
|---|---|
| code basis | `CODE-2026-07-03-PR38` |
| code pin | `266783468ac38542574ea4787bec650d16ba6b02` |
| persistent worktree | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree` |
| base substrate | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR38-final-n4a-recipe-build/` |
| corpus manifest | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/wave1-corpus-final/wave1-corpus-manifest.json` |
| corpus manifest sha256 | `b07e0a9bc76b3140a41c1402e714aac6fb6944294900084b18c73416c45d6a10` |
| corpus jsonl | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/wave1-corpus-final/wave1-corpus.jsonl` |
| corpus jsonl sha256 | `e6ff61cb87d90cfbc6fdcc73c0da063b69c49f6a9d09f50064ec8f1c9b9f3afb` |
| corpus rows | `250` |

## Render Output

| item | value |
|---|---:|
| combined samples | `4750` |
| train MLX records | `4350` |
| valid MLX records | `400` |
| test MLX records | `128` |
| output dir | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-shorttrain-data-ready/` |
| rendered MLX data dir | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-shorttrain-data-ready/mlx-data` |
| render summary | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-shorttrain-data-ready/render-data-summary.json` |

## Gates

| gate | exit | verdict | key numbers |
|---|---:|---|---|
| DataGate | `0` | PASS / `data_gate_ready` | row_count `4750`; bucket_counts train `4350`, dev_selection `400`; failure_count `0`; must_not_train_violations `0`; train_parent_semantic_overlap `0` |
| strict preflight | `0` | PASS | records `4878`; trainable_records `4878`; trainable_tokens `119579`; length_violations `[]`; max_token_length `7186` |

## Evidence Files

| file | sha256 |
|---|---|
| `render-data-summary.json` | `76a9335146463aa4d2199e33db0252ec336387fbfbcf3b13a45fa84f0f251062` |
| `samples/c5-training-samples.jsonl` | `ac23b7b4c8f463ef34fa279da9549985770bd27ed0b32f8e0682dd715ac78049` |
| `mlx-data/train.jsonl` | `4f6166821fe67f7966c4305478dc72dce108fe75bbf1abf787b1eeff71d562e1` |
| `mlx-data/valid.jsonl` | `37c56bdcce83a43a39cec3762d7a432ff0d2f6960380059b7b7a6724d9ae175c` |
| `mlx-data/test.jsonl` | `7f3c85218cf61bd466dc4678a08877cc362a21e067a8a709829546e6ebfcb11b` |
| `datagate/c5-data-gate-receipt.json` | `437eb68c96f5024dc3aab7e1281d8805d913c0873606d8feff50bae16a5b8159` |
| `logs/datagate.log` | `d427289b386af0a8088f59b2540c766d2966a38c19f3fc7d876fbb7a0fae3326` |
| `logs/strict-preflight.log` | `437da148e6013129e3b357b4fbe97c4f9f7d4556113c29c63513a401416c626a` |
| `strict-preflight.metrics.jsonl` | `6db32b55ac4b313d274fc439642a245dccf473e062e9135b11eff74fcaedc17d` |

## Commands

DataGate:

```bash
swift run C5DataGateCLI \
  --repo-root /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree \
  --candidates /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-shorttrain-data-ready/samples/c5-training-samples.jsonl \
  --source-digest-path /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-shorttrain-data-ready/samples/c5-training-samples.jsonl \
  --source-authorization authorized_c1_semantic_contract_plus_authorized_synthetic_generation \
  --output-dir /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-shorttrain-data-ready/datagate
```

Strict preflight:

```bash
/opt/homebrew/opt/python@3.13/bin/python3.13 \
  /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/Tools/C5TrainingCLI/c5_mlx_train_loop.py \
  --train \
  --preflight-only \
  --model /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR38-final-n4a-recipe-build/qwen3-1_7b-training-tokenizer-patched \
  --data /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-shorttrain-data-ready/mlx-data \
  --config /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/CODE-basis-migration-r2-pr38-26678346/t1d-d2combo-r2-config-smoke.yaml \
  --require-maformac-loss-mask \
  --max-seq-length 8192 \
  --batch-size 4 \
  --grad-accumulation-steps 4 \
  --token-budget-per-batch 8192 \
  --grad-checkpoint \
  --clear-cache-before-train \
  --grad-clip-norm 1.0 \
  --metrics-jsonl /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-shorttrain-data-ready/strict-preflight.metrics.jsonl
```


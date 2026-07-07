# F044 R2 Data-Ready Receipt

status: r2_data_ready_preflight_pass_no_train
artifact_kind: f044_r2_data_ready_receipt
proof_class: local/data_preflight
render_format_version: r2_action_tagged_protocol_v1

## Scope

This receipt covers only the R2 rendered data substrate plus the existing wave-1 250-row natural-language corpus rendered into a short-train MLX data directory. It does not run optimizer updates, save adapters, evaluate model quality, claim train-ready, or claim V-PASS.

## Inputs

| item | value |
|---|---|
| rerendered substrate samples | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/samples-rerendered/samples/c5-training-samples.jsonl` |
| rerendered substrate samples sha256 | `67b7da15b17ab0515419a9dcd819f34a1bc7f14133c48754e79029665b14fc07` |
| render format version | `r2_action_tagged_protocol_v1` |
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
| protocol rows with `action=` | `4500` |
| protocol rows without `action=` | `0` |
| natural corpus rows with `action=` | `0` |
| natural corpus rows without `action=` | `250` |
| output dir | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r2-data-ready/` |
| rendered MLX data dir | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r2-data-ready/mlx-data` |
| render summary | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r2-data-ready/render-data-summary.json` |

## Gates

| gate | exit | verdict | key numbers |
|---|---:|---|---|
| supervision consistency scanner | `0` | PASS / `pass_no_contradictions` | row_count `4750`; contradiction_group_count `0`; contradiction_row_count `0`; mount_order_status `pass`; unbalanced_mount_order_pair_count `0`; open_first `334`; close_first `294` |
| action-tag assertion | `0` | PASS | protocol rows `4500/4500` have `action=`; corpus rows `0/250` have `action=` |
| DataGate | `0` | PASS / `data_gate_ready` | row_count `4750`; bucket_counts train `4350`, dev_selection `400`; must_not_train_violations `0`; train_parent_semantic_overlap `0`; quarantine `0`; failure_receipt empty |
| strict preflight | `0` | PASS | records `4878`; trainable_records `4878`; trainable_tokens `119571`; ignored_tokens `7684359`; length_violations `[]`; max_token_length `7128` |

## Token Delta Note

Old F044-DATA-READY strict preflight reported `trainable_tokens=119579`; R2 reports `119571` (`delta=-8`, `delta_ratio=-0.0067%`). This does not match the initial +2-4% expectation because the R2 `action=` segment is in the user prompt, while `trainable_tokens` counts assistant-supervised labels under the PR38 loss-mask contract. The prompt-side growth is reflected in `ignored_tokens`, not trainable assistant tokens.

## Evidence Files

| file | sha256 |
|---|---|
| `render-data-summary.json` | `156021749b945ff680d77a4e7ac3c15367e4702b7b0d9651baba0e31f6efea8b` |
| `samples/c5-training-samples.jsonl` | `5d00ff816bf91705a2bc8135033f390f43e894e1780e7ad66c8e651af72ed58a` |
| `mlx-data/train.jsonl` | `19e43c5ca4197651d2303245e9893f428b25f2666e1e43a78bf0af9fe8c04116` |
| `mlx-data/valid.jsonl` | `00f56ecb1f10d5eddb0b85ac00ff04af16d196ee71511fe577c416862597e7aa` |
| `mlx-data/test.jsonl` | `a10a0a39d4f7b24b2c06f5cb42c302542a77f963ccd5a7fc02918b5da8ad790c` |
| `supervision-consistency-summary.json` | `aa96d8b1fecb23d29f96b3321bf3d03958970b17dcef58e6fe885bc514adeb5c` |
| `mount-order-balance-report.json` | `c8a5693658b71fff038af3764ff4225a4d935f48fc2a16bd4a04ebe773323dd5` |
| `datagate/c5-data-gate-receipt.json` | `9252fcb4f42cb3a05809d571732a20f669a79936c8bbd518a522d2cfe3cc41a2` |
| `logs/datagate.log` | `70e68d7aa92e8d16997328ed358009943840cf706c20e84a258703494488fa30` |
| `logs/strict-preflight.log` | `cce221936be77106ba01cdb02ea5304ba7d2483aca7cef96b2c2857f7510686d` |
| `strict-preflight.metrics.jsonl` | `3e061da17105edb6fe3ce0bf734e204e269fa7f1c58efa66750e08b7afd32090` |

## Commands

Supervision consistency scanner:

```bash
/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/tools/supervision_consistency_scanner.py \
  --input /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r2-data-ready/samples/c5-training-samples.jsonl \
  --output /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r2-data-ready/supervision-consistency-contradictions.jsonl \
  --summary-json /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r2-data-ready/supervision-consistency-summary.json \
  --mount-order-report-json /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r2-data-ready/mount-order-balance-report.json \
  --fail-on-contradiction \
  --fail-on-mount-order
```

DataGate:

```bash
swift run C5DataGateCLI \
  --repo-root /Users/wanglei/workspace/MAformac \
  --candidates /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r2-data-ready/samples/c5-training-samples.jsonl \
  --source-digest-path /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r2-data-ready/samples/c5-training-samples.jsonl \
  --source-authorization authorized_c1_semantic_contract_plus_authorized_synthetic_generation \
  --output-dir /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r2-data-ready/datagate
```

Strict preflight:

```bash
/opt/homebrew/opt/python@3.13/bin/python3.13 \
  /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/Tools/C5TrainingCLI/c5_mlx_train_loop.py \
  --train \
  --preflight-only \
  --model /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR38-final-n4a-recipe-build/qwen3-1_7b-training-tokenizer-patched \
  --data /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r2-data-ready/mlx-data \
  --config /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/CODE-basis-migration-r2-pr38-26678346/t1d-d2combo-r2-config-smoke.yaml \
  --require-maformac-loss-mask \
  --max-seq-length 8192 \
  --batch-size 4 \
  --grad-accumulation-steps 4 \
  --token-budget-per-batch 8192 \
  --grad-checkpoint \
  --clear-cache-before-train \
  --grad-clip-norm 1.0 \
  --metrics-jsonl /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r2-data-ready/strict-preflight.metrics.jsonl
```

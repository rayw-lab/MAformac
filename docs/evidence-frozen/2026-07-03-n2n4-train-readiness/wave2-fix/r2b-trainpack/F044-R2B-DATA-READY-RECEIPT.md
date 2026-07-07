# F044 R2B Data-Ready Receipt

status: r2b_data_ready_preflight_pass_no_train
artifact_kind: f044_r2b_data_ready_receipt
proof_class: local/data_preflight
generated_at_utc: 2026-07-04T06:49:55Z
render_format_version: r2_action_tagged_protocol_v1

## Scope

This receipt covers only the R2B combined samples rendered into an MLX data directory and the pre-train gate chain. It did not run optimizer updates, save adapters, evaluate model quality, claim train-ready, or claim V-PASS.

## Inputs

| item | value |
|---|---|
| %45 combined samples jsonl | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r2b-trainpack/c5-training-samples.jsonl` |
| %45 combined samples sha256 | `3b76d49767e650b2cf5d41a3dd6b527932c1e2e2500bb249ac917303380f84e0` |
| %45 manifest / assembler receipt | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r2b-trainpack/assembly_receipt.json` |
| %45 manifest / assembler receipt sha256 | `5c1f6625617f1b42643aa1e49447daa19cbc7d2123eea78d4deb1cde3635f19d` |
| assembler effective row count | `5499` |
| assembler split guard | `pass; train=5099, dev_selection=400, missing_split_count=0, invalid_split_count=0` |
| render format version | `r2_action_tagged_protocol_v1` |
| mount order strategy | `seeded_shuffle` |
| mount order seed formula | `sha256(sample_id\|tool_name)` |
| split rule | `train=split train; valid=dev_selection; test=R2 128 sample_id projection` |
| R2 test projection source | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r2-data-ready/mlx-data/test.jsonl` |

## Render Output

| item | value |
|---|---:|
| combined samples | `5499` |
| mount order strategy | `seeded_shuffle` |
| mount order seed formula | `sha256(sample_id\|tool_name)` |
| mount rows reordered | `363` |
| mount count diff rows | `0` |
| mount tool-name set diff rows | `0` |
| protocol rows with `action=` | `4602` |
| natural/corpus/candidate rows without `action=` | `897` |
| row conservation status | `pass` |
| row conservation assertion | `input_samples_total == train_mlx_records + valid_mlx_records; test projection excluded` |
| row conservation input samples total | `5499` |
| row conservation train plus valid records | `5499` |
| row conservation missing split/unrendered rows | `0` |
| test projection records excluded from conservation | `128` |
| train MLX records | `5099` |
| valid MLX records | `400` |
| test MLX records | `128` |
| MLX record total | `5627` |
| output dir | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r2b-trainpack` |
| rendered samples jsonl | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r2b-trainpack/samples/c5-training-samples.jsonl` |
| rendered MLX data dir | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r2b-trainpack/mlx-data` |
| render summary | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r2b-trainpack/render-data-summary.json` |

## Gates

| gate | exit | verdict | key numbers |
|---|---:|---|---|
| render + row conservation | `0` | `pass` | input `5499`; train+valid `5499`; missing_split_or_unrendered_rows `0`; test_projection_excluded `128`; mount_count_diff_rows `0`; mount_tool_name_set_diff_rows `0` |
| supervision consistency scanner | `0` | `pass_no_contradictions` | row_count `5499`; contradiction_group_count `0`; contradiction_row_count `0`; mount_order_status `pass`; unbalanced_mount_order_pair_count `0`; open_first `905`; close_first `888` |
| DataGate | `0` | `data_gate_ready` | row_count `5499`; bucket_counts train `5099`, dev_selection `400`; quarantine `0`; must_not_train_violations `0`; train_parent_semantic_overlap `0`; tool_call_format_pass `5043`; tool_call_format_failures `0`; redaction_status `pass`; failures `none` |
| strict preflight | `0` | `pass` | records `5627`; trainable_records `5627`; trainable_tokens `133692`; ignored_tokens `18133767`; max_token_length `7196`; length_violations `0`; train/valid/test records `5099/400/128` |

## Strict Preflight Split Detail

| split | records | trainable_records | trainable_tokens | ignored_tokens | max_token_length |
|---|---:|---:|---:|---:|---:|
| train | `5099` | `5099` | `121697` | `16554474` | `7196` |
| valid | `400` | `400` | `9112` | `1251837` | `7191` |
| test | `128` | `128` | `2883` | `327456` | `7191` |

## Efficiency Columns

| metric | value | formula / source |
|---|---:|---|
| supervised_tok_per_sec | `TODO_after_train_log_or_shorttrain_receipt` | `trained_supervised_tokens / wall_clock_seconds`; required by `training-efficiency-deepdive-2026-07-04.md:55` |
| ignored_trainable_ratio | `TODO_after_train_log_or_shorttrain_receipt` | Training receipt should carry final efficiency accounting. Preflight raw counters are `ignored_tokens=18133767`, `trainable_tokens=133692`, raw ratio `135.638385`. |

## Evidence Files

| file | sha256 |
|---|---|
| `c5-training-samples.jsonl` | `3b76d49767e650b2cf5d41a3dd6b527932c1e2e2500bb249ac917303380f84e0` |
| `assembly_receipt.json` | `5c1f6625617f1b42643aa1e49447daa19cbc7d2123eea78d4deb1cde3635f19d` |
| `samples/c5-training-samples.jsonl` | `587c88a28002bf2fe61376d544f17e2687e2a7eae3223a58df3d3fd24699ce83` |
| `render-data-summary.json` | `7dc57a55359f4e09dedcd6a21db6b5d5904cfeb6b14b7c2436aed2b82469dc90` |
| `mlx-data/train.jsonl` | `9e1e12a829edca751b50dd2d48532f9cf994ff71417ae3694d6d0fad73859546` |
| `mlx-data/valid.jsonl` | `df1e356d210e9658918aceb65a1c8f1c0e813412ac63ce830ed80f9362eab897` |
| `mlx-data/test.jsonl` | `ed7a78567156468e7fb951e84073e852cbdfe8f859fe43544a1b8f0a006cdcc2` |
| `supervision-consistency-summary.json` | `7a721e095a62c581bbd7528284ccdfa6c0640d2da59e05803331eee1fda4a95f` |
| `mount-order-balance-report.json` | `666858be1bb777ff82a8913fa06a666438917a69de09ffa672dad413b519b88f` |
| `datagate/c5-data-gate-receipt.json` | `a98e290e3002b91e03afa99e3fdb79e76723c675ac833a92a20ef55aae1ddfca` |
| `strict-preflight.metrics.jsonl` | `b9e47d2f40ceadbc82aa5fe4f8927de5591fdce1c06f31fc44e792cebad2b701` |

## Commands

Commands were executed from `/Users/wanglei/workspace/MAformac` following `RENDER-AND-GATES-RUNBOOK.md` sections 1-4 with:

```bash
export RUN_ROOT=/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness
export REPO_ROOT=/Users/wanglei/workspace/MAformac
export R2B_TRAINPACK_DIR=$RUN_ROOT/wave2-fix/r2b-trainpack
export R2B_COMBINED_SAMPLES_JSONL=$R2B_TRAINPACK_DIR/c5-training-samples.jsonl
export R2B_SAMPLES_DIR=$R2B_TRAINPACK_DIR/samples
export R2B_SAMPLES_JSONL=$R2B_SAMPLES_DIR/c5-training-samples.jsonl
export R2B_MLX_DATA_DIR=$R2B_TRAINPACK_DIR/mlx-data
export R2B_RENDER_SUMMARY=$R2B_TRAINPACK_DIR/render-data-summary.json
export R2B_RECEIPT=$R2B_TRAINPACK_DIR/F044-R2B-DATA-READY-RECEIPT.md
export R2_TEST_JSONL=$RUN_ROOT/wave2-fix/r2-data-ready/mlx-data/test.jsonl
```

Stage 1 used the embedded Python renderer in `RENDER-AND-GATES-RUNBOOK.md §1`, preserving tool mount sets/counts, applying `seeded_shuffle`, and enforcing row conservation before writing the final receipt.

```bash
$RUN_ROOT/tools/supervision_consistency_scanner.py \
  --input "$R2B_SAMPLES_JSONL" \
  --output "$R2B_TRAINPACK_DIR/supervision-consistency-contradictions.jsonl" \
  --summary-json "$R2B_TRAINPACK_DIR/supervision-consistency-summary.json" \
  --mount-order-report-json "$R2B_TRAINPACK_DIR/mount-order-balance-report.json" \
  --fail-on-contradiction \
  --fail-on-mount-order
```

```bash
swift run C5DataGateCLI \
  --repo-root "$REPO_ROOT" \
  --candidates "$R2B_SAMPLES_JSONL" \
  --source-digest-path "$R2B_SAMPLES_JSONL" \
  --source-authorization authorized_c1_semantic_contract_plus_authorized_synthetic_generation \
  --output-dir "$R2B_TRAINPACK_DIR/datagate"
```

```bash
/opt/homebrew/opt/python@3.13/bin/python3.13 \
  "$RUN_ROOT/code-basis-pr38-worktree/Tools/C5TrainingCLI/c5_mlx_train_loop.py" \
  --train \
  --preflight-only \
  --model "$RUN_ROOT/PR38-final-n4a-recipe-build/qwen3-1_7b-training-tokenizer-patched" \
  --data "$R2B_MLX_DATA_DIR" \
  --config "$RUN_ROOT/CODE-basis-migration-r2-pr38-26678346/t1d-d2combo-r2-config-smoke.yaml" \
  --require-maformac-loss-mask \
  --max-seq-length 8192 \
  --batch-size 4 \
  --grad-accumulation-steps 4 \
  --token-budget-per-batch 8192 \
  --grad-checkpoint \
  --clear-cache-before-train \
  --grad-clip-norm 1.0 \
  --metrics-jsonl "$R2B_TRAINPACK_DIR/strict-preflight.metrics.jsonl"
```

## Stop Conditions

- No train command beyond `--preflight-only` was run.
- No optimizer update was run.
- No adapter was saved.
- Render, row conservation, scanner, DataGate, and strict preflight all exited `0`.
- `input_samples_total=5499` equals `train_mlx_records + valid_mlx_records = 5099 + 400`.
- `missing_split_or_unrendered_rows=0`.
- `mount_count_diff_rows=0` and `mount_tool_name_set_diff_rows=0`.
- `records=5627` equals `train + valid + test = 5099 + 400 + 128`.
- `length_violations=0`.

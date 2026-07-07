# RECEIPT N4A E-2 downgrade strict preflight

status: DONE
proof_class: local
captured_at_utc: 2026-07-02T23:24:55Z
worktree: /Users/wanglei/workspace/MAformac-p5w-wave1-bridge
branch: codex/p5w-e2-downgrade-valid-supervision-20260703

## Conclusion

N4a scope 内完成：E-2 违规组 `seat.massage_force_time` 已降级为 target + first sibling；valid/test MLX 数据保留 A+ 监督 loss mask，但不改变 dev_selection 的 DataGate `must_not_train` 语义；strict loss-mask preflight exit0。

不声称：没有真训练、没有云生成、没有模型质量结论、没有 CI green、没有 V-PASS。`prepare` receipt 仍为 `status: blocked`，原因是 broader training readiness gate 仍含 validator_layer2、candidate_data_quality、fuse parity、endpoint parity 等 N4a scope 外债务。

## Commits

- `20fab0f2` N4a implement E2 downgrade preflight contract
- `ac7774e0` N4a add loss-mask preflight-only gate

## Changed files

- `/Users/wanglei/workspace/MAformac-p5w-wave1-bridge/Core/Training/C5LoRATraining.swift`
- `/Users/wanglei/workspace/MAformac-p5w-wave1-bridge/Tools/C5TrainingCLI/main.swift`
- `/Users/wanglei/workspace/MAformac-p5w-wave1-bridge/Tools/C5TrainingCLI/c5_mlx_train_loop.py`
- `/Users/wanglei/workspace/MAformac-p5w-wave1-bridge/Tests/MAformacCoreTests/C5LoRATrainingTests.swift`

## Code evidence

- `Core/Training/C5LoRATraining.swift:416`: `supervisedEvaluationMLXRecord` projects dev_selection rows into supervised MLX eval records without changing original split gate fields.
- `Tools/C5TrainingCLI/main.swift:143`: train writes regular `mlxRecord`; `main.swift:144-145` writes valid/test via `supervisedEvaluationMLXRecord`.
- `Core/Training/C5LoRATraining.swift:3083`: mounted tools now pass through `degradedMountedEntriesIfNeeded`.
- `Core/Training/C5LoRATraining.swift:3181`: only `seat.massage_force_time` degrades; output is target plus first non-target sibling.
- `Core/Training/C5LoRATraining.swift:3089-3093`: degraded `prompt_distractor_tool_ids` are the actual mounted sibling, avoiding claim-vs-reality mismatch.
- `Tools/C5TrainingCLI/c5_mlx_train_loop.py:163`: added `--preflight-only`.
- `Tools/C5TrainingCLI/c5_mlx_train_loop.py:1068`: exits after strict MAformac loss-mask dataset validation, before training.
- `Tools/C5TrainingCLI/c5_mlx_train_loop.py:1071`: `--preflight-only` fails closed unless `--require-maformac-loss-mask` is set.

## Test evidence

- `Tests/MAformacCoreTests/C5LoRATrainingTests.swift:923`: dev_selection supervised eval projection keeps original not-train split semantics and adds trainable spans only for MLX eval export.
- `Tests/MAformacCoreTests/C5LoRATrainingTests.swift:996`: Python loop test locks `--preflight-only` parser and fail-closed guard.
- `Tests/MAformacCoreTests/C5LoRATrainingTests.swift:1325`: E-2 downgrade test locks target + first sibling and `mountedToolCount=2`.

Command:

```bash
swift test --filter C5LoRATrainingTests
```

Result: 55 tests, 0 failures.

## DataGate evidence

Command:

```bash
RUN_DIR=/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness
OUT_DIR="$RUN_DIR/n4a-wave1-proto-build"
swift run C5DataGateCLI \
  --repo-root /Users/wanglei/workspace/MAformac-p5w-wave1-bridge \
  --candidates "$OUT_DIR/samples/c5-training-samples.jsonl" \
  --source-digest-path /Users/wanglei/workspace/MAformac-p5w-wave1-bridge/contracts/semantic-function-contract.jsonl \
  --source-authorization authorized_c1_semantic_contract \
  --output-dir "$RUN_DIR/N4A-c5-data-gate"
```

Result log: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N4A-c5-data-gate.log`

Key receipt: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N4A-c5-data-gate/c5-data-gate-receipt.md`

- line 3: `status: data_gate_ready`
- line 11: `row_count: 4500`
- line 12: `bucket_counts: dev_selection=400, train=4100`
- line 21: `allow_legacy_missing_surface: false`
- line 22: `missing_surface_count: 0`
- line 24: `surface_field_pass: 4500`
- lines 27-31: masking coverage all true
- line 38: failures none

Sample surface probe:

```json
{"line":220,"sample_id":"c5-train-00220","split":"train","train_eligible":true,"mounted_tool_count":2,"subset_policy_id":"e2-lite-v1","subset_group_id":"seat.massage_force_time","prompt_distractor_tool_ids":["adjust_seat_massage_force_to_gear"],"tool_names":["open_seat_massage","adjust_seat_massage_force_to_gear"]}
```

## Strict preflight evidence

Command:

```bash
RUN_DIR=/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness
OUT_DIR="$RUN_DIR/n4a-wave1-proto-build"
PY=/opt/homebrew/opt/python@3.13/bin/python3.13
"$PY" /Users/wanglei/workspace/MAformac-p5w-wave1-bridge/Tools/C5TrainingCLI/c5_mlx_train_loop.py \
  --train \
  --preflight-only \
  --model "$OUT_DIR/qwen3-1_7b-training-tokenizer-patched" \
  --data "$OUT_DIR/mlx-data" \
  --config "$OUT_DIR/mlx-lora-config.yaml" \
  --require-maformac-loss-mask \
  --max-seq-length 8192 \
  --metrics-jsonl "$RUN_DIR/N4A-loss-mask-preflight.metrics.jsonl"
```

Result log: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N4A-loss-mask-preflight.strict.log`

- `loss_mask_preflight_exit=0`
- `records=4628`
- `trainable_records=4628`
- `trainable_tokens=44459`
- no training step after preflight-only return

Summary JSON: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N4A-loss-mask-preflight-summary.json`

- line 4: `length_violation_count: 0`
- line 7: `max_token_length: 7186`
- line 17: test `trainable_records: 128`
- line 25: train `trainable_records: 4100`
- line 33: valid `trainable_records: 400`
- line 37: `status: strict_loss_mask_preflight_exit0`

## M.8 split supervision table

| split | system/user | tools mount | assistant tool_call supervision | think | stop / labels | evidence |
| --- | --- | --- | --- | --- | --- | --- |
| train | real messages | d-domain manifest, E-2 violating group target + first sibling | function_name 4100, argument_name 7465, argument_value 4311 spans | no think markup observed | 4100 trainable records | preflight summary + span probe |
| valid | real messages from dev_selection projection | same surface policy as dev_selection export | function_name 400, argument_name 564, argument_value 229 spans | no think markup observed | 400 trainable records | `supervisedEvaluationMLXRecord` projection |
| test | first 128 dev_selection projection | same surface policy as dev_selection export | function_name 128, argument_name 179, argument_value 52 spans | no think markup observed | 128 trainable records | `supervisedEvaluationMLXRecord` projection |

## Premortem results

- Tiger 1, valid/test dead-field risk: fixed by exporting supervised eval MLX records; upstream mlx-lm `train()` passes custom `loss` and `iterate_batches` into `evaluate()`, so eval consumes the MAformac mask path when wired through this repo loop.
- Tiger 2, R7 accidental training risk: fixed by `--preflight-only`; strict validation can run with `--train` but exits before `train()`.
- Tiger 3, E-2 claim-vs-reality mismatch: fixed by making degraded distractor metadata match the actual mounted first sibling.
- Paper tiger: raising max length was not needed; `max_token_length` is 7186 under `max_seq_length` 8192.
- Elephant: broader train readiness remains blocked outside N4a, visible in prepare receipt lines 3, 35, 42, 53, 56.

## Residual risks

- local proof only; CI not run due billing constraint.
- no true training, no checkpoint, no model-quality or runtime acceptance claim.
- prepare command exits 65 because project-level readiness gates remain blocked outside this N4a contract; DataGate and strict loss-mask preflight are green.

## Push / PR

- pushed branch: `origin/codex/p5w-e2-downgrade-valid-supervision-20260703`
- PR: https://github.com/rayw-lab/MAformac/pull/31
- PR body verified after edit; it states local verification only, not CI.

# RECEIPT-45 — gate2 masking enforce / think-mask / LoRA keys

status: PASS_CONSTRUCTION_LOCAL
worker: codex pane %45
worktree: `/Users/wanglei/workspace/MAformac-g2-mask`
branch: `c5gate/g2-masking-enforce`
base_head: `ab355f6c`
artifact_kind: experimental construction receipt, not SSOT, not candidate signoff

## Scope

执行 DISPATCH-wave1 §C。仅改 C5 LoRA 训练构造代码、训练入口 preflight 与单测；未跑真训练、真数据生成、C6 acceptance、真评测、candidate、golden、voice。

## Changes

1. masking enforce 从 metadata/dry-run 变为 construction-level loss-mask record + fail-closed preflight：
   - `Core/Training/C5LoRATraining.swift:399` `mlxRecord` 现在写入 `lossMask`。
   - `Core/Training/C5LoRATraining.swift:408` `C5MLXRecord` 增加 JSON 字段 `loss_mask`。
   - `Core/Training/C5LoRATraining.swift:434` `C5MLXLossMask` 固定 `ignore_index=-100`，携带 `labels`、`trainable_spans`、`masked_think_spans`。
   - `Core/Training/C5LoRATraining.swift:1890` `C5LossMaskBuilder` 默认全 `-100`，只把 `function_name` / `argument_name` / `argument_value` / `NO_TOOL` 目标 span 置为 trainable label `0`。
   - `Core/Training/C5LoRATraining.swift:2523` builder 接入 `validateLossMaskEnforcement`，不再只看字段声明；缺 span 或 think span 未忽略会进入 failure receipt。
   - `Tools/C5TrainingCLI/main.swift:187` rendered train command 强制带 `--require-maformac-loss-mask`。
   - `Tools/C5TrainingCLI/c5_mlx_train_loop.py:528` 训练 loop 在加载模型前校验 `train/valid/test.jsonl` 的 `loss_mask.labels`、`ignore_index=-100`、ignored/trainable coverage；失败返回 `LOSS_MASK_PREFLIGHT_FAILED`（`Tools/C5TrainingCLI/c5_mlx_train_loop.py:712`）。

2. `<think>...</think>` loss-mask：
   - `Core/Training/C5LoRATraining.swift:2021` 检测 `<think>...</think>` span。
   - `Core/Training/C5LoRATraining.swift:1952` think span 强制回写 `ignore_index=-100`。
   - `Tests/MAformacCoreTests/C5LoRATrainingTests.swift:923` 测试确认 think 文本 label 为 `-100`，同时 tool-call function span 仍 trainable。

3. LoRA projection keys 7 层 coverage：
   - `Core/Training/C5LoRATraining.swift:1321` `defaultProjectionKeys` 为 q/k/v/o_proj + gate/up/down_proj。
   - `Core/Training/C5LoRATraining.swift:1353` `rank16Mainline` 消费 `defaultProjectionKeys`。
   - `Tests/MAformacCoreTests/C5LoRATrainingTests.swift:857` 测试断言 7 key 精确集合，且不是 mlx 默认 2 层。

## Tests

- `swift build`
  - exit code: 0
  - result: PASS
  - note: SwiftPM 仍提示 3 个既有 unhandled files warning（`UBIQUITOUS_LANGUAGE.md`, 2 个 `MAformacIOSUITests`），非本次新增。

- `swift test --filter C5LoRATrainingTests`
  - exit code: 0
  - result: PASS
  - executed: 44 tests, 0 failures

- `python3 -m py_compile Tools/C5TrainingCLI/c5_mlx_train_loop.py`
  - exit code: 0
  - result: PASS

- `git diff --check`
  - exit code: 0
  - result: PASS

## GitNexus

- pre-edit impact:
  - `C5TrainingSample`: LOW, impactedCount=3, affected process `makePositiveSample`.
  - `C5TrainingDatasetBuilder`: CRITICAL, impactedCount=33, direct tests + `Tools/C5TrainingCLI.prepare/main`.
  - `C5MLXLoRAConfig`: LOW, impactedCount=3.
  - `renderTrainCommand`: LOW, impactedCount=2, affected process `main`.
  - `Tools/C5TrainingCLI/c5_mlx_train_loop.py:run`: LOW, impactedCount=2.
- post-edit `detect_changes --repo MAformac-r5-main-current`:
  - result: high
  - changed: 4 files / 82 symbols
  - affected processes: 9, all `MakePositiveSample` related.

## R7 Proof

- 未执行 `C5TrainingCLI prepare`。
- 未执行 `c5_mlx_train_loop.py` 训练/inspect；仅 `py_compile` 做语法门。
- 未调用云 generator / judge。
- 未跑 C6 acceptance / 真 eval / candidate comparison。
- 本次 proof class: local + unit + construction_static。

## Residual Risk

- `loss_mask.labels` 已进入 `C5MLXRecord`、builder validation 和训练入口 preflight，但本轮按 R7 未跑真实 MLX 训练，因此未证明 mlx-lm runtime 已消费该字段产生真实 loss 差异。
- 后续若进入训练授权，需要在 R-L17 loss-mask print review 中 dump token/label 对齐，确认 token-level `-100` 被训练 loop 消费。

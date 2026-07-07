# RECEIPT-45-fix — gate2 P0 masking true token-loss fix

status: PASS_CONSTRUCTION_LOCAL
worker: codex pane %45
worktree: `/Users/wanglei/workspace/MAformac-g2-mask`
branch: `c5gate/g2-masking-enforce`
base_fix_commit: `87a3bbc9`
artifact_kind: experimental construction receipt, not SSOT, not candidate signoff

## Scope

修复 `AUDIT-adversarial.md` P0：上一版 `loss_mask.labels` 是 char-indexed dead field，训练 loop 仍走 stock `default_loss`/`--mask-prompt`。本轮只做 R7-safe construction：tokenize 后构造 token-level labels，让训练 loop 消费 `-100` mask，并加 synthetic loss 数学门。未跑真训练、真模型 batch dump、C6 acceptance、生成、云 judge、candidate/golden/voice。

## Changes

1. char-indexed `labels` 移除，改为 tokenizer 后生成 token labels：
   - `Core/Training/C5LoRATraining.swift:448` `loss_mask` 只声明 `token_label_source=runtime_tokenizer_offsets`。
   - `Core/Training/C5LoRATraining.swift:1950` enforcement 改为 `token_labels_enforced_after_tokenization_with_think_mask`。
   - `Core/Training/C5LoRATraining.swift:2539` receipt 文案改为训练 loop tokenize 后构造 token-level labels。
   - `Tests/MAformacCoreTests/C5LoRATrainingTests.swift:918` 断言 JSON 不再输出 `"labels"`，防 char-indexed field 回归。

2. 训练 loop 真消费 token-level mask：
   - `Tools/C5TrainingCLI/main.swift:186` rendered train command 保留 `--require-maformac-loss-mask`，移除 stock `--mask-prompt`。
   - `Tools/C5TrainingCLI/c5_mlx_train_loop.py:615` `build_maformac_token_labels` 在 tokenizer 后按 assistant token offsets 生成 labels；若发现旧 `loss_mask.labels` 直接 fail-closed：`char_indexed_loss_mask_labels_forbidden`（`:622`）。
   - `Tools/C5TrainingCLI/c5_mlx_train_loop.py:654` `maformac_masked_cross_entropy_from_logits` 用 `token_labels != -100` mask cross entropy。
   - `Tools/C5TrainingCLI/c5_mlx_train_loop.py:662` `maformac_masked_loss` 对 causal target labels 使用 `token_labels[:, 1:]`。
   - `Tools/C5TrainingCLI/c5_mlx_train_loop.py:669` `maformac_iterate_batches` 产出 `(batch_tokens, token_labels)`，不再产 stock `(batch, offsets)`。
   - `Tools/C5TrainingCLI/c5_mlx_train_loop.py:498` / `:512` train/eval 在 `--require-maformac-loss-mask` 下传入 `maformac_masked_loss` 和 `maformac_iterate_batches`。
   - `Tools/C5TrainingCLI/c5_mlx_train_loop.py:727` `load_maformac_loss_mask_datasets` 读取本地 `train/valid/test.jsonl` 并做 token-level preflight。

3. F-068 synthetic loss 数学门：
   - `Tools/C5TrainingCLI/c5_mlx_train_loop.py:94` 新增 `--self-test-loss-mask`。
   - `Tools/C5TrainingCLI/c5_mlx_train_loop.py:806` self-test 构造 synthetic logits/token-labels，masked token 置 `-100` 后对 loss 贡献为 0。
   - `Tests/MAformacCoreTests/C5LoRATrainingTests.swift:978` 锁 Python self-test 和 masked cross entropy symbol。

## Validation

- `python3 -m py_compile Tools/C5TrainingCLI/c5_mlx_train_loop.py`
  - exit code: 0
  - result: PASS

- `/opt/homebrew/opt/python@3.13/bin/python3.13 Tools/C5TrainingCLI/c5_mlx_train_loop.py --self-test-loss-mask`
  - exit code: 0
  - result: PASS
  - output: `{"event":"loss_mask_self_test","status":"pass","trainable_tokens":2,"masked_loss":0.0006704330444335938,"unmasked_loss":2.66733717918396}`

- `swift build`
  - exit code: 0
  - result: PASS
  - note: SwiftPM 仍提示 3 个既有 unhandled files warning（`UBIQUITOUS_LANGUAGE.md`, 2 个 `MAformacIOSUITests`），非本次新增。

- `swift test --filter C5LoRATrainingTests`
  - exit code: 0
  - result: PASS
  - executed: 45 tests, 0 failures

- `git diff --check`
  - exit code: 0
  - result: PASS

## GitNexus

- pre-fix impact:
  - `C5LossMaskBuilder`: target not found in stale index, risk UNKNOWN.
  - `Tools/C5TrainingCLI/c5_mlx_train_loop.py:run`: LOW, impactedCount=2.
  - `C5MLXLossMask`: target not found in stale index, risk UNKNOWN.
- post-fix `detect_changes --repo MAformac-r5-main-current`:
  - result: high
  - changed: 4 files / 32 symbols
  - affected processes: 9, all `MakePositiveSample` related.

## R7 Proof

- 未执行 `C5TrainingCLI prepare`。
- 未执行 `c5_mlx_train_loop.py --train` / `--test` / `--inspect-batches`。
- 未加载真实模型权重做 batch dump；`--self-test-loss-mask` 只跑 synthetic logits/token-labels 数学门。
- 未调用云 generator / judge。
- 未跑 C6 acceptance / 真 eval / candidate comparison。
- 本次 proof class: local + unit + construction_static。

## Residual Risk

- 已修正上一版 dead-field：训练入口在 `--require-maformac-loss-mask` 下不再依赖 stock `--mask-prompt` 连续 offset，loss path 改为 token-level `-100` mask。
- 仍未完成 real-model 集成 proof：R7 授权后需要 dump 一个真实 tokenizer/model batch 的 token-label 对齐和 masked-vs-unmasked loss 对照，证明真实 Qwen/MLX batch 与 synthetic 门一致。
- assistant standalone tokenization 与 chat-template full-token offset 已做 subsequence/offset fail-closed；真实 tokenizer path 的覆盖需在 R7 run-auth 的 batch dump 中最终确认。

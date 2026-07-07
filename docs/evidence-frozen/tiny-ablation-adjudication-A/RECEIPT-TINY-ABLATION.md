# RECEIPT-TINY-ABLATION

status: BLOCKED_VERDICT_EMPTY_34_OF_34
proof_class: local/runtime-preflight
run_id: tiny-ablation-adjudication-A
worktree: /Users/wanglei/workspace/.tiny-ablation/MAformac-tiny-ablation-A
base: origin/main @ 58ea217f65bb000526f42f9efc989d265e53b838
run_plan: /Users/wanglei/workspace/MAformac/docs/project/phase0/r-l17-human-review-evidence/tiny-ablation-run-plan-adjudication-A.md
run_auth: /Users/wanglei/workspace/MAformac/docs/project/phase0/r-l17-human-review-evidence/R7-renewal-and-tiny-ablation-run-auth-DRAFT.md

## 1. Preflight

- PR #24 unlock is merged into `origin/main` at `58ea217f65bb000526f42f9efc989d265e53b838`.
- R7 Part B is signed for `authorized_scope: adjudication_A_tiny_ablation_only`, `sample_count_approved: 40`.
- Fixed output directory exists: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/`.
- Worktree status remained clean after diagnostics; no repo code edits were made.
- `swift run C5TrainingCLI --help` is not supported and returned `unknown command: --help`; accepted values were therefore recorded from the live parser:
  - `--surface d_domain|frame`
  - `--masking-stage smoke_only|trainable_v0|masking_complete_v1`
- Chosen Step1 values:
  - `--scope demo`
  - `--surface d_domain`
  - `--target-positive 40`
  - `--masking-stage masking_complete_v1`

## 2. Manifest

Attempted v1 command:

```bash
swift run C5TrainingCLI prepare \
  --output-dir /Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/build \
  --scope demo \
  --surface d_domain \
  --target-positive 40 \
  --masking-stage masking_complete_v1
```

Generated partial artifacts:

- `build/c5trainingcli-help.txt`
- `build/step1-c5trainingcli-prepare.log`
- `build/samples/c5-training-samples.jsonl`
- `build/offset-fixture/mlx-mask-offset-fixture.json`
- `build/offset-fixture/manual-probe.json`
- `build/qwen3-1_7b-training-tokenizer-patched/tokenizer_config.json`

Addendum v2 command attempted after磊哥 authorized `prepare` + `--dev-selection 0`:

```bash
swift run C5TrainingCLI prepare \
  --output-dir /Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/build \
  --scope demo \
  --surface d_domain \
  --target-positive 40 \
  --dev-selection 0 \
  --masking-stage masking_complete_v1
```

Generated v2 artifacts:

- `build/c5-training-receipt.json`
- `build/c5-training-receipt.md`
- `build/mlx-data/train.jsonl`
- `build/mlx-lora-config.yaml`
- `build/mlx-train-command.txt`
- `build/offset-fixture/mlx-mask-offset-fixture.json`
- `build/step1-c5trainingcli-prepare-v2.log`

V1 missing required Step1 artifacts:

- `build/c5-training-receipt.json`
- `build/c5-training-receipt.md`
- `build/mlx-data/train.jsonl`
- `build/mlx-lora-config.yaml`
- `build/mlx-train-command.txt`

## 3. Train Health

Step2 was not started.

Reason: v1 did not produce the required green C5DataGate receipt or `build/mlx-train-command.txt`; v2 produced those files but the training receipt still has `status=blocked` and does not satisfy the v2 green counts.

No `--self-test-loss-mask` run was performed because Step1 is a hard prerequisite.

## 4. Probe

Step3 was not started.

No adapter exists and no 34-case probe outputs were generated.

## 5. Verdict

Step4 was not started.

No `verdict.json` was written because no `emptyToolCallOutputs` value can be produced without Step2 training and Step3 probe.

Observed Step1 blocker:

```text
rows 40
split {'dev_selection': 40}
train_eligible {False: 40}
loss_mask_present 0
expected_tool_calls_nonempty 40
train_expected_tool_calls 0
```

Observed Step1 v2 state:

```text
cli_exit=65
receipt_status=blocked
data_gate_status=data_gate_ready
offset_fixture=pass
samples=44
split={'train': 44}
train_eligible={True: 44}
mlx_train_rows=44
mlx_train_loss_mask_present=44
expected_tool_calls_nonempty=40
no_call=4
masking_coverage.argument_value=false
```

V2 failure receipt includes:

```text
training_loop_source_unverified
loss_mask_argument_name_span_missing_c5-train-00001
loss_mask_argument_value_span_missing_c5-train-00001
...
cloud_multi_source_generator_not_run
multi_source_generator_diversity_missing
cross_vendor_semantic_judge_not_run
masking_complete_augmentation_not_implemented
```

Offset fixture evidence:

```json
{
  "status": "fail",
  "sample_count": 0,
  "class_coverage": [],
  "failure_receipt": [
    "missing_tool_call_probe_row"
  ]
}
```

Root cause:

- `Tools/C5TrainingCLI/main.swift` defaults `devSelectionRows = 400`.
- The run plan command specifies `--target-positive 40` and does not specify `--dev-selection`.
- `C5TrainingDatasetBuilder.assignDevSelection` selects `min(devSelectionRows, samples.count)`.
- Therefore all 40 positive rows become `split=dev_selection`, `train_eligible=false`, with no train rows and no `loss_mask`.

Stop decision:

- Addendum v2 authorized adding `prepare` and `--dev-selection 0`; that was executed.
- Step1 still does not pass because the receipt is blocked and the v2 green counts say 40 train rows / train_eligible=40, while observed training rows are 44 due 4 no-call rows.
- Adding `--theta-alpha-positive-only`, changing masking stage, changing generator requirements, or editing code would be a new recipe change not present in Addendum v2.
- Therefore the run stopped at Step1 without training, probing, threshold changes, sample expansion, rerun, or wave-1 escalation.

## 6. Non Claims

- No real training was run.
- No adapter weights were produced.
- No 34-case probe was run.
- No `verdict.json` was produced.
- No C6 acceptance, candidate comparison, formal train, wave-1, UIUE merge, or V/S/U-PASS is claimed.

REPORT tiny-ablation BLOCKED_STEP1_DATA_BUILD: locked Step1 command on current main generates 40/40 rows as dev_selection because CLI default devSelectionRows=400 and run plan omits --dev-selection; C5DataGate receipt/train.jsonl/mlx-train-command are missing, so Step2-4 were not started. No code edits, no training, no threshold/sample/rerun deviation.

REPORT tiny-ablation BLOCKED_STEP1_V2_RECEIPT_NOT_GREEN: Addendum v2 command produced train.jsonl and mlx-train-command.txt, with DataGate `data_gate_ready`, but CLI exits 65 and receipt status remains `blocked`; observed train rows/train_eligible are 44 not v2 green gate 40 because 4 no-call rows are generated, masking_coverage.argument_value=false, and failure_receipt includes `masking_complete_augmentation_not_implemented` plus loss-mask span misses. Step2-4 not started; no code edits, no training, no recipe/threshold/sample/rerun deviation.

## Addendum v3 Execution

Addendum v3 was confirmed in the run plan §5. It supersedes the Step1 masking stage and green-count contract:

- `--masking-stage trainable_v0`
- positive 40 + automatic no-call 4 = total 44 rows
- `sampleCount=44` if Step4 is reached
- verdict/receipt must honestly mark no `argument_value` augmentation

V3 Step1 command executed:

```bash
swift run C5TrainingCLI prepare \
  --output-dir /Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/build \
  --scope demo \
  --surface d_domain \
  --target-positive 40 \
  --dev-selection 0 \
  --masking-stage trainable_v0
```

V3 Step1 green-gate evidence:

```text
samples=44
sample_split={'train': 44}
sample_train_eligible={True: 44}
mlx_train_rows=44
mlx_loss_mask_present=44
expected_tool_calls_nonempty=40
no_call=4
train_jsonl_exists=True
mlx_train_command_exists=True
data_gate_status=data_gate_ready
offset_fixture=pass
masking_coverage.argument_value=false
```

Note: `swift run C5TrainingCLI prepare` still returned exit 65 because the broader training receipt remained `status=blocked` for known formal gaps such as missing `argument_value` augmentation and generator/judge work. Addendum v3 explicitly scoped Step1 green to the builder's implemented `trainable_v0` shape above, so Step2 was started after these v3 gates passed.

Step2 self-test:

```text
{"event": "loss_mask_self_test", "masked_loss": 0.0006704330444335938, "status": "pass", "trainable_tokens": 2, "unmasked_loss": 2.66733717918396}
```

Rendered training command execution:

- command source: `build/mlx-train-command.txt`
- execution mode: verbatim via `bash build/mlx-train-command.txt`
- log: `build/step2-train.log`
- exit code: 66

Step2 blocker:

```text
LOSS_MASK_PREFLIGHT_FAILED
errors: train:1..25:'TokenizerWrapper' object is not callable
records=44
train.trainable_records=0
train.trainable_tokens=0
```

Training artifacts at this earlier pre-D-025 attempt:

- `build/metrics.jsonl` exists but contains only run metadata; no train-step metrics were emitted.
- `build/adapters-rank16/` does not exist.
- No adapter weights were produced.
- No NONFINITE stop occurred in this earlier attempt; it stopped at the loss-mask preflight.

Stop decision:

- This is the training loop's own `--require-maformac-loss-mask` preflight guard, called by the rendered command.
- The run plan requires the rendered command to be executed as-is and forbids hand-editing rendered parameters.
- Therefore Step3 and Step4 were not started.

REPORT tiny-ablation BLOCKED_STEP2_LOSS_MASK_PREFLIGHT: v3 Step1 gates passed and self-test-loss-mask passed, but executing `build/mlx-train-command.txt` verbatim stopped before training with exit 66 `LOSS_MASK_PREFLIGHT_FAILED`; all 44 train records failed with `'TokenizerWrapper' object is not callable`, trainable_records=0/trainable_tokens=0. No NONFINITE, no adapter, no probe, no verdict; no code edits or rendered-parameter changes.

## D-025 Mechanical Fix And Continue

D-025 authorized run-blocking mechanical bug fixes without stopping unless the fix touches threshold, sample count, recipe parameters, or scope boundary. The Step2 `TokenizerWrapper` callable failure was classified as mechanical and fixed in the run worktree.

Run worktree commit used for the continued run:

```text
2977c99d fix(c5): support mlx tokenizer wrapper offsets
```

Fix summary:

- `assistant_tokenization` keeps `apply_chat_template` on the mlx-lm wrapper.
- Offset tokenization now unwraps `getattr(tokenizer, "_tokenizer", tokenizer)` before calling the HF tokenizer with `return_offsets_mapping=True`.
- Added `scripts/test_c5_mlx_train_loop_tokenizer_wrapper.py` to cover the wrapper path.

Fix validation:

```text
python3 -m pytest scripts/test_c5_mlx_train_loop_tokenizer_wrapper.py
1 passed

swift test --filter C5LoRATrainingTests
53 tests, 0 failures
```

Backport PR:

```text
https://github.com/rayw-lab/MAformac/pull/25
```

Training command rerun:

- command source: `build/mlx-train-command.txt`
- execution mode: verbatim via `bash build/mlx-train-command.txt`
- log: `build/step2-train-after-tokenizer-wrapper-fix.log`
- rendered parameters unchanged.

Loss-mask preflight after fix:

```text
MAformac token loss_mask preflight records=44 trainable_records=44 trainable_tokens=209 ignored_tokens=46516
```

NONFINITE stop:

```text
NONFINITE_TRAINING_STOP {
  "event": "nonfinite_stop",
  "iteration": 2,
  "update_step": 0,
  "loss": NaN,
  "loss_finite": false,
  "grad_finite": true,
  "grad_norm_preclip": null,
  "fallback_recommendation": {
    "restart_learning_rate": 5e-05,
    "restart_reason": "nonfinite_loss_or_gradient"
  }
}
```

Artifacts after NONFINITE:

- `build/metrics.jsonl` contains run metadata, loss-mask preflight summary, and `nonfinite_stop`.
- `build/adapters-rank16/adapter_config.json` exists.
- No completed adapter weights were produced.
- Step3 probe and Step4 verdict were not started.

Stop decision:

- The run plan explicitly says NONFINITE fuse stops the run.
- Applying the fallback learning rate would change a recipe parameter, one of the four D-025 red lines.
- Therefore the run stops here with no LR change, no threshold change, no sample change, no rerun, no probe, and no verdict.

REPORT tiny-ablation BLOCKED_STEP2_NONFINITE_STOP: D-025 mechanical TokenizerWrapper fix landed in run commit `2977c99d` and PR #25; py wrapper test 1/0 and C5LoRATrainingTests 53/0 passed. Rerunning rendered `mlx-train-command.txt` verbatim passed loss-mask preflight (44 records, 209 trainable tokens), then stopped at iteration 2 with `NONFINITE_TRAINING_STOP loss=NaN`; no completed adapter, no probe, no verdict, no LR/parameter/rerun change.

## Addendum v4 Execution

Addendum v4 was confirmed in the run plan §6. It authorized exactly four changes:

1. Mechanical fail-closed guard for zero trainable tokens in `maformac_masked_cross_entropy_from_logits`.
2. Pre-train measured token-length gate.
3. Render `max_seq_length` from 1024 to 8192.
4. Continue the v4 run with sampleCount=44 and the same `<5` empty gate if training reaches probe/verdict.

Run worktree commit used for v4:

```text
2b808a88 fix(c5): fail closed loss mask length preflight
```

Backport PR:

```text
https://github.com/rayw-lab/MAformac/pull/25
head: 2b808a886f9589f33620015ac3d1a1431f5e62f1
```

V4 fix validation:

```text
/opt/homebrew/opt/python@3.13/bin/python3.13 -m pytest scripts/test_c5_mlx_train_loop_tokenizer_wrapper.py
3 passed

swift test --filter C5LoRATrainingTests
53 tests, 0 failures

/opt/homebrew/opt/python@3.13/bin/python3.13 Tools/C5TrainingCLI/c5_mlx_train_loop.py --self-test-loss-mask
status=pass, zero_token_fail_closed_guard=finite_loss_zero_ntoks
```

Rendered command evidence:

```text
--iters 600
--learning-rate 0.0001
--max-seq-length 8192
--grad-clip-norm 1.0
```

Unchanged recipe fields:

- rank: 16
- scale: 20
- learning rate: 0.0001
- grad clip norm: 1.0
- iters: 600
- sample shape: 40 positive + 4 no-call = 44

Measured token-length gate evidence:

```json
{
  "event": "maformac_loss_mask_preflight",
  "records": 44,
  "trainable_records": 44,
  "trainable_tokens": 209,
  "ignored_tokens": 46537,
  "max_seq_length": 8192,
  "max_token_length": 4992,
  "length_violations": []
}
```

This replaces the earlier character-count estimate. The logged previous `longest=1236` was from the 1024 run; the v4 true-token measurement for the regenerated 8192 run is `max_token_length=4992`.

V4 training command execution:

- command source: `build/mlx-train-command.txt`
- execution mode: verbatim via `bash build/mlx-train-command.txt`
- log: `build/step2-train-v4.log`

V4 blocker:

```text
libc++abi: terminating due to uncaught exception of type std::runtime_error:
[METAL] Command buffer execution failed: Insufficient Memory (00000008:kIOGPUCommandBufferCallbackErrorOutOfMemory)
```

Latest rerun per磊哥 continuation:

- command source: `build/mlx-train-command.txt`
- execution mode: verbatim
- log: `build/step2-train-v4-rerun-20260702T211227.log`
- result: same Metal OOM after loss-mask preflight and before any completed adapter weights.

```text
MAformac token loss_mask preflight records=44 trainable_records=44 trainable_tokens=209 ignored_tokens=46537
Training
Trainable parameters: 1.013% (17.433M/1720.575M)
Starting training..., iters: 600
libc++abi: terminating due to uncaught exception of type std::runtime_error: [METAL] Command buffer execution failed: Insufficient Memory (00000008:kIOGPUCommandBufferCallbackErrorOutOfMemory)
```

Artifacts after v4 OOM:

- `build/metrics.jsonl` contains run metadata and the measured length/loss-mask preflight summary.
- `build/adapters-rank16/adapter_config.json` exists.
- No completed adapter weights were produced.
- Step3 probe and Step4 verdict were not started.

Stop decision:

- The v4 length gate passed, proving no sample exceeded 8192 true tokenizer tokens.
- Continuing past Metal OOM would require changing memory-affecting recipe parameters such as max sequence length, batch size, accumulation, model shape, or hardware/runtime placement.
- D-025 red lines forbid changing recipe parameters without a new authorization.
- Therefore the run stops here with no parameter change, no rerun, no probe, and no verdict.

REPORT tiny-ablation BLOCKED_STEP2_METAL_OOM: D-025/v4 fixes landed in run commit `2b808a88` and PR #25; py tests 3/0, C5LoRATrainingTests 53/0, self-test pass. Regenerated command changed only `max_seq_length=8192`; measured preflight length gate passed (`max_token_length=4992`, `length_violations=[]`, 44 records/209 trainable tokens). Latest verbatim rerun `step2-train-v4-rerun-20260702T211227.log` again crashed with Metal OOM before completed adapter weights; Step3/4 not started; no LR/rank/scale/clip/iters/sample/threshold change.

## D-025 OOM Memory Adaptation

磊哥/commander stopped verbatim rerun after repeated v4 Metal OOM and authorized one memory-only adaptation:

- `batch_size`: 4 -> 1
- `grad_accumulation_steps`: 4 -> 16
- effective batch remains 16 because `4 * 4 == 1 * 16`
- unchanged: LR `0.0001`, rank `16`, scale `20`, clip `1.0`, iters `600`, max_seq_length `8192`, sample shape `44`

Adapted command file:

```text
build/mlx-train-command.batch1-grad16.txt
```

Adapted command execution:

- command source: `build/mlx-train-command.batch1-grad16.txt`
- log: `build/step2-train-v4-batch1-grad16-20260702T212310.log`
- exit: 134 / `Abort trap: 6`

Preflight evidence before adapted training:

```json
{
  "event": "maformac_loss_mask_preflight",
  "records": 44,
  "trainable_records": 44,
  "trainable_tokens": 209,
  "ignored_tokens": 46537,
  "max_seq_length": 8192,
  "max_token_length": 4992,
  "length_violations": []
}
```

Training progressed to the first report:

```text
Iter 10: Train loss 2.110, Learning Rate 0.000e+00, It/sec 0.351, Tokens/sec 1.893, Trained Tokens 54, Peak mem 8.173 GB, Grad Norm Preclip 0.000000
```

Adapted-run blocker:

```text
libc++abi: terminating due to uncaught exception of type std::runtime_error:
[METAL] Command buffer execution failed: Insufficient Memory (00000008:kIOGPUCommandBufferCallbackErrorOutOfMemory)
```

Artifacts after adapted OOM:

- `build/metrics.jsonl` contains run metadata, loss-mask/length preflight, and the iter-10 train report.
- `build/adapters-rank16/adapter_config.json` exists.
- No completed adapter weight file was produced.
- `probe/` contains 0 files.
- `verdict.json` is absent.

Stop decision:

- The authorized memory adaptation was exhausted at `batch_size=1`.
- Continuing would require changing a red-line item or external runtime condition, such as `max_seq_length`, model/layer shape, sample/threshold/recipe, or hardware/memory availability.
- Therefore Step3 and Step4 were not started, and no verdict can be produced from a completed adapter.

REPORT tiny-ablation BLOCKED_STEP2_METAL_OOM_BATCH1_GRAD16: adapted command batch 1 / grad_accum 16 preserved effective batch 16 and kept LR/rank/scale/clip/iters/max_seq unchanged; preflight passed (44 records, max_token_length=4992<=8192, 209 trainable tokens), training reached iter 10 loss 2.110 peak_mem 8.173GB, then Metal OOM; no completed adapter, probe 0, verdict absent; PR #25 head 2b808a88 clean/open.

## Mechanical Adaptation v5 And Final Verdict

Commander/磊哥 authorized a second mechanical OOM adaptation after diagnosing the remaining OOM as long-sequence attention backward activation peak:

1. `grad_checkpoint: true` added to `build/mlx-lora-config.yaml` and passed as `--grad-checkpoint`.
2. `max_seq_length` changed from `8192` to `5120`.
3. `batch_size=1` and `grad_accumulation_steps=16` retained.
4. Unchanged: LR `0.0001`, rank `16`, scale `20`, clip `1.0`, iters `600`, samples `44`, verdict threshold `<5`.

Adaptation rationale:

- Prior measured longest sample was `max_token_length=4992`.
- `5120` still admits the measured longest sample with `128` tokens of headroom.
- Reducing max sequence length from 8192 to 5120 reduces attention memory while preserving the true-token length gate.

V5 command/config artifacts:

- `build/mlx-lora-config.yaml`
- `build/mlx-train-command.v5-seq5120-gradckpt-batch1-grad16.txt`
- metrics: `build/metrics-v5-seq5120-gradckpt-batch1-grad16.jsonl`
- adapter: `build/adapters-rank16-v5-seq5120-gradckpt/adapters.safetensors`

V5 preflight evidence:

```json
{
  "event": "maformac_loss_mask_preflight",
  "records": 44,
  "trainable_records": 44,
  "trainable_tokens": 209,
  "ignored_tokens": 46537,
  "max_seq_length": 5120,
  "max_token_length": 4992,
  "length_violations": []
}
```

V5 train health:

```text
Iter 10: Train loss 2.110, Peak mem 3.073 GB
Iter 20: Train loss 1.642, Peak mem 8.129 GB
Iter 100: Saved adapter weights
Iter 200: Saved adapter weights
Iter 300: Saved adapter weights
Iter 400: Saved adapter weights
Iter 500: Saved adapter weights
Iter 600: Train loss 1.173, Learning Rate 9.488e-05, Peak mem 11.668 GB
Iter 600: Saved adapter weights
Saved final weights to build/adapters-rank16-v5-seq5120-gradckpt/adapters.safetensors
```

Step3 34-case probe:

- probe script: `build/probe_c6_tool_call_34_v5.py`
- raw dumps: `probe/01-C6-MP-002.json` through `probe/34-C6-TRAP-AMB-002.json`
- summary: `probe/summary.json`

Probe summary:

```json
{
  "case_count": 34,
  "empty_tool_call_outputs": 34,
  "non_empty_tool_call_outputs": 0
}
```

Representative raw output:

```json
{
  "case_id": "C6-MP-002",
  "input_zh": "有点冷",
  "raw_output": "NO_TOOL.NO_TOOL.NO_TOOL.NO_TOOL.NO_TOOL.NO_TOOL.NO_TOOL.NO_TOOL.NO_TOOL.NO_TOOL.NO_TOOL.NO_TOOL.NO_TOOL.NO_TOOL.NO_TOOL.NO_TOOL.NO_TOOL.NO_TOOL.NO_TOOL.NO_TOOL.NO_TOOL.NO_TOOL.NO_TOOL.NO_TOOL.NO_TOOL.NO_TOOL.NO_TOOL",
  "has_tool_call": false
}
```

Step4 harness verdict:

- command path: temporary Swift harness invocation linked against the built `MAformacCore` module.
- metrics: `sampleCount=44`, `emptyToolCallOutputs=34`, `metricSource=.real`, `runAuthorizationReference=/Users/wanglei/workspace/MAformac/docs/project/phase0/r-l17-human-review-evidence/R7-renewal-and-tiny-ablation-run-auth-DRAFT.md`
- output: `verdict.json`

Verdict:

```json
{
  "baseline_denominator" : 34,
  "baseline_empty_tool_call_outputs" : 28,
  "metric_source" : "real",
  "passed" : false,
  "reason" : "empty_tool_call_outputs_not_below_target",
  "run_authorization_reference" : "/Users/wanglei/workspace/MAformac/docs/project/phase0/r-l17-human-review-evidence/R7-renewal-and-tiny-ablation-run-auth-DRAFT.md",
  "status" : "blocked",
  "target_empty_tool_call_outputs_strictly_below" : 5
}
```

Final stop decision:

- Training completed with a real adapter after the authorized mechanical memory adaptation.
- The 34-case behavior probe produced `34/34` empty tool-call outputs.
- The code-locked success gate is `emptyToolCallOutputs < 5`; observed `34` fails the gate.
- Per run plan failure discipline, this stops at verdict. No threshold change, no sample expansion, no wave-1, and no further rerun is claimed.

REPORT tiny-ablation BLOCKED_VERDICT_EMPTY_34_OF_34: v5 mechanical adaptation completed training with grad_checkpoint=true and max_seq_length=5120 (longest measured token length 4992<=5120), batch1/grad16 effective batch 16 preserved and LR/rank/scale/clip/iters/sample/threshold unchanged; final adapter exists; Step3 probe dumped all 34 C6 behavior_class=tool_call cases; emptyToolCallOutputs=34/34; harness real verdict status=blocked reason=empty_tool_call_outputs_not_below_target; no wave-1/threshold/sample/rerun escalation.

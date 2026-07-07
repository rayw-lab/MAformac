---
artifact: T1-SMOKE-RECEIPT
status: FAIL
verdict: T1_SMOKE_FAIL_METAL_OOM_BEFORE_OPTIMIZER_UPDATE
proof_class: local_true_training_smoke_attempt
created_at_utc: 2026-07-03T03:46:00Z
main_pin_sha: b33d8eba152e5326f69bbe85fc356b73419ee9c3
code_worktree: /tmp/maformac-t1-smoke-b33d8eba
baseline_artifact: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR31-final-n4a-recipe-build
output_dir: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/T1-smoke
---

# T1 Smoke Receipt

## Conclusion

`T1_SMOKE_FAIL_METAL_OOM_BEFORE_OPTIMIZER_UPDATE`.

The run reached real model/data loading and completed the initial validation pass, then aborted with Metal out-of-memory before the first training optimizer update. T1 pass criteria were not met.

This is not a watchdog timeout and not a non-finite loss stop. No adapter weights were saved.

## Command Scope

User-authorized run:

- run-auth: D-050.
- merge-complete main pin: `b33d8eba152e5326f69bbe85fc356b73419ee9c3`.
- code source: detached `/tmp` worktree at the pin.
- data/config/tokenizer: `PR31-final-n4a-recipe-build`.
- smoke policy: `--iters 4` with `--grad-accumulation-steps 4`.
- watchdog: 20 minutes.

Pinned code verified before run:

```text
git -C /tmp/maformac-t1-smoke-b33d8eba rev-parse HEAD
b33d8eba152e5326f69bbe85fc356b73419ee9c3
```

The pinned worktree had no tracked dirty state before execution.

## Source Hashes

| Artifact | sha256 |
|---|---|
| training loop at pinned worktree | `fb4f1ab49ceb83ee8ca0e043c518e074d3cd0024f30effb1d863225eafef2c37` |
| PR31 baseline `mlx-lora-config.yaml` | `4d64ac3b2b36ffb861719ea030e4d942419576e9890b9f4505d4c15e2c3bc31c` |
| PR31 baseline `tokenizer_config.json` | `1388819a7641c1a5e6d5a5480add3d24552970d087cec6ff010c3b1b6e0c68c7` |

## Execution Evidence

Training log reached:

```text
MAformac C5 repo training loop (mlx-lm=0.31.1, script_sha256=fb4f1ab49ceb83ee8ca0e043c518e074d3cd0024f30effb1d863225eafef2c37, grad_clip_norm=1.0, clip_disabled=False, stock_update_inside_compile=False)
Loading pretrained model
Loading datasets
MAformac token loss_mask preflight records=4628 trainable_records=4628 trainable_tokens=113914 ignored_tokens=15802533
Training
Trainable parameters: 1.013% (17.433M/1720.575M)
Starting training..., iters: 4
```

Validation completed:

```json
{"event":"val","iteration":1,"val_loss":3.0813474655151367,"val_time":182.17417179211043}
```

Abort text from `train.log`:

```text
Iter 1: Val loss 3.081, Val took 182.174s
libc++abi: terminating due to uncaught exception of type std::runtime_error: [METAL] Command buffer execution failed: Insufficient Memory (00000008:kIOGPUCommandBufferCallbackErrorOutOfMemory)
Abort trap: 6
```

Observed shell result from `execute-with-watchdog.sh`: process exited with code `134`.

## Metrics Gate

`T1-smoke/metrics.jsonl` contains 3 rows:

1. `run_metadata`
2. `maformac_loss_mask_preflight`
3. `val`

Derived counts:

```text
metrics_rows=3
optimizer_update_count=0
nonfinite_stop_count=0
adapter_saved=false
validation_json_written=false
```

Validation script result:

```text
validation-exit-code: 1
validation-failure.log: FAIL: optimizer_update_count < 1
```

## Pass / Fail Checklist

| Gate | Result | Evidence |
|---|---:|---|
| pinned main SHA matches requested `b33d8eba...` | PASS | `/tmp/maformac-t1-smoke-b33d8eba` HEAD |
| PR31 baseline model/data/config used | PASS | `run-train.sh` paths point to `PR31-final-n4a-recipe-build` |
| `--iters 4` + `--grad-accumulation-steps 4` | PASS | `run-train.sh` |
| mlx-lm imports and training loop starts | PASS | `train.log`; `mlx-lm=0.31.1` |
| loss-mask preflight inside training loop passes | PASS | metrics row `maformac_loss_mask_preflight`; 4628 trainable records |
| validation pass completes | PASS | metrics row `val`, `val_loss=3.0813474655151367` |
| at least one optimizer update | FAIL | `optimizer_update_count=0` |
| loss and grad_norm finite on optimizer update | FAIL | no optimizer update row exists |
| adapter save succeeds | FAIL | `adapters-rank16/adapters.safetensors` absent |
| tokenizer hash matches PR31/N4A patched tokenizer | NOT_REACHED_BY_VALIDATION | tokenizer config hash was prechecked, but post-run validation stopped at missing optimizer update |
| watchdog timeout absent | PASS | no `watchdog_sigterm`; process aborted before timeout |

## Artifact Hashes

| Artifact | sha256 |
|---|---|
| `T1-smoke/run-train.sh` | `f5384f22a78ad0b6b00da86f5f85842c2d9785c4a5b86cf3d3d2faa5878bc613` |
| `T1-smoke/execute-with-watchdog.sh` | `eaa6309487e0088272679d2e7a7e1f94f5c14d213f71f6f03fee6561952aa113` |
| `T1-smoke/validate-t1-smoke.py` | `44c0cd5068eba6bc3d7997cdbfabc22e579962f42237667efeec2b10e7b8be68` |
| `T1-smoke/c5_mlx_train_loop.snapshot.py` | `fb4f1ab49ceb83ee8ca0e043c518e074d3cd0024f30effb1d863225eafef2c37` |
| `T1-smoke/metrics.jsonl` | `41097d29f7deb8e559ddc319aa7fd971e0c31b7aa9083143126a2340535e57be` |
| `T1-smoke/train.log` | `478cfc66c92d283f640e7a13ece47c1df95ea1af9522792e540bec451af3a44b` |
| `T1-smoke/watchdog.jsonl` | `24ca191f74073f52a1247b3645e6d698c02dae90beceeae557785c610ca7b544` |
| `T1-smoke/metadata.env` | `117c9e9c1a515526c62d57b350e5eef77efee57354cdc819cd31bd99f8f92c45` |
| `T1-smoke/validation-failure.log` | `f6b48a1bfd908db59070953cee38de70d598702835bc1f5a6211b111e1f70a7b` |
| `T1-smoke/validation-exit-code.txt` | `4355a46b19d348dc2f57c046f8ef63d4538ebb936000f3c9ee954a27460dd865` |
| `T1-smoke/adapters-rank16/adapter_config.json` | `f358756876ac005d86fd34e580005c8d8cb37820bba327d25cf5764bf797e5d8` |

## Residual State

- `T1-smoke/adapters-rank16/adapter_config.json` exists because the loop created the adapter directory and config before training.
- `T1-smoke/adapters-rank16/adapters.safetensors` does not exist.
- `T1-smoke/validation.json` does not exist because validation failed.
- No watchdog process sample exists because the watchdog did not fire; the process aborted before 20 minutes.
- `/tmp/maformac-t1-smoke-b33d8eba` remains available for immediate postmortem unless commander asks to remove it.

## Minimal Next Decision

Do not continue to formal training from this configuration. The first true smoke failed before optimizer update due Metal OOM after validation.

Likely next branch for commander decision:

1. Keep config fidelity and debug memory: capture `system_profiler` / Metal memory / process sample around initial validation and first train step, then decide whether validation cadence or memory limit must change.
2. If validation is not required for the smoke purpose, run a separately authorized diagnostic with validation disabled or reduced, explicitly marking it as a different proof class from this T1 smoke.
3. If preserving full validation is mandatory, reduce memory surface only after a signed config change; do not silently downgrade `max_seq_length`, LoRA modules, rank, or grad accumulation.

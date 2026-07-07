---
artifact_kind: t1d_d0_instrumentation_receipt
status: T1D_DIAGNOSTIC_PASS_FOR_D0_PROFILE_SAME_OOM
verdict: H-act
proof_class: diagnostic_not_candidate
basis_id:
  - CODE-2026-07-03
  - DATA-WAVE1-SUBSTRATE-v2
code_pin: b33d8eba152e5326f69bbe85fc356b73419ee9c3
data_baseline: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR31-final-n4a-recipe-build
run_dir: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/T1D-D0
owner: "%44"
---

# T1D-D0 Instrumentation Receipt

## Conclusion

D0 instrumentation run completed its diagnostic goal: it reproduced the same Metal OOM after successful validation, with memory profile and basis-bound artifacts.

Verdict: `H-act`.

Reason: validation completed with captured peak `9,909,110,888` bytes; after resetting the peak counter, the first train microstep entered with `batch_total_tokens=20036` and only `batch_supervised_tokens=96`, then aborted before `train_step1_forward_after` could be written. The sampled validation batches reached at most `batch_total_tokens=13236` and `batch_supervised_tokens=122`. The crash therefore tracks long batch activation pressure more strongly than supervised-token count.

Exact first-train-step peak delta is not numerically captured: the process died inside the first train `mx.eval(lvalue, toks)` before the post-forward profile line. The measured statement is categorical, not invented: `train_peak > captured_val_peak` enough to trigger Metal OOM after val peak reset; exact byte delta is indeterminate.

## Authority

- T1D grill lock cites the fixed basis and D0 staged sampling requirement: `docs/c5-training-readiness-grill/t1d-oom-grill-2026-07-03.md:6`, `:16-18`.
- Runbook fixed baseline and current fail mode: `docs/c5-training-readiness-grill/t1-oom-diagnostic-runbook-2026-07-03.md:24-34`.
- D0 is instrumentation-only and must leave hard artifacts: `docs/c5-training-readiness-grill/t1-oom-diagnostic-runbook-2026-07-03.md:47-72`.
- Baseline registry requires cited basis IDs; live values are `CODE-2026-07-03` and `DATA-WAVE1-SUBSTRATE-v2`: `docs/BASELINE-REGISTRY.md:12-15`, `:27-30`.

## Fixed Recipe

Changed knob: none. Instrumentation only.

Preserved recipe facts:

- `batch_size=4`
- `grad_accumulation_steps=4`
- `rank=16`
- target modules count `7`
- `max_seq_length=8192`
- `val_batches=25`
- Qwen3-1.7B + project MLX train loop

`run-train.sh` used the PR31 final data/config baseline and the pinned `/tmp` worktree. `--iters 600` is the formal command value; the OOM occurs before iteration count can affect training behavior.

## Validation

| gate | result |
|---|---|
| exit_code | `134` |
| watchdog_timeout | `false` |
| OOM present | `true` (`[METAL] Command buffer execution failed: Insufficient Memory`) |
| optimizer_update_count | `0` |
| adapter_saved | `false` |
| finite_loss_grad | `null` because no optimizer row was reached |
| val_loss | `3.0813474655151367` |
| val_time_seconds | `296.6614823329728` |

Resource envelope:

| peak_memory_bytes | wall_clock_seconds |
|---:|---:|
| `9909110888` | `397` |

## D0 Double-Hypothesis Evidence

| evidence | H-act | H-sup |
|---|---|---|
| Val sampled peak | val batch 25: `peak_bytes=9909110888`, `batch_total_tokens=12087`, `batch_supervised_tokens=75` | supervised small at val peak |
| First train entry | `batch_total_tokens=20036`, `batch_supervised_tokens=96`; OOM before forward-after profile | supervised is below sampled val max `122` and near val10 `99` |
| Crash position | after validation, immediately inside first train forward eval; no backward/optimizer profile rows | not aligned with a supervised-token spike |

Verdict: `H-act`.

Residual: because C++ Metal abort prevents post-crash in-process sampling, the first train step's exact peak bytes are not available. The next lower-risk diagnostic is D1b token-budget batching or D1 batch-size reduction under the locked T1D sequence.

## Artifacts

| artifact | sha256 / note |
|---|---|
| `run-train.sh` | `35aef8db8dfc4379f8843ea26419acd5442a3bb312eae353aeb166faaf10f2cc` |
| `config.yaml` | `4d64ac3b2b36ffb861719ea030e4d942419576e9890b9f4505d4c15e2c3bc31c` |
| `c5_mlx_train_loop.snapshot.py` | `6d0c455d516a1f07f495033768e5e393edf2abdb205ac2fc8e8659eef603213e` |
| `c5_mlx_train_loop.executed-source.py` | `6d0c455d516a1f07f495033768e5e393edf2abdb205ac2fc8e8659eef603213e` |
| `train.log` | stdout/stderr with val completion and Metal OOM |
| `metrics.jsonl` | `ba3343abb43076d6a78037c1ad2b357028cdbbb77802516579cf61f01f103cdc` |
| `memory-profile.jsonl` | `cd3cbd9524508245e2c279d58e6a4225cff85f7aaac0415456cd0a35faa67757` |
| `memory-profile.md` | human-readable profile summary |
| `validation.json` | `5e0a30a756580e94a55cb926f08c9cbadb3a44582df0fa01ee2a5fa18d1ef0f3` |
| `watchdog.jsonl` | start + complete; no timeout |
| `resource-envelope.tsv` | two-column resource envelope |

## Non-Claims

- Not train-ready.
- Not a candidate recipe.
- Not model-quality evidence.
- Not C6 acceptance.
- Not V/S/U-PASS.

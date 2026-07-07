---
artifact_kind: t1d_d7a_cache_clear_receipt
status: T1D_DIAGNOSTIC_FAIL_SAME_OOM_AFTER_CACHE_CLEAR
verdict: H-cache-excluded
proof_class: diagnostic_not_candidate
basis_id:
  - CODE-2026-07-03
  - DATA-WAVE1-SUBSTRATE-v2
code_pin: b33d8eba152e5326f69bbe85fc356b73419ee9c3
data_baseline: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR31-final-n4a-recipe-build
run_dir: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/T1D-D7a
owner: "%44"
---

# T1D-D7a Cache-Boundary Clear Receipt

## Conclusion

D7a tested the commander H-cache addendum with the cheapest cache-boundary intervention: `mx.clear_cache()` after validation and before the first train microstep.

Result: `H-cache-excluded`.

`mx.clear_cache()` worked mechanically: cache dropped from `24,302,364,612` bytes to `0`, and the first train step entered with `cache_bytes=0`. The run still reproduced the same Metal OOM before `train_step1_forward_after`, with `optimizer_update_count=0` and no adapter save.

Therefore, val cache carry-over is not sufficient to explain the failure. The D0 `H-act` diagnosis remains the stronger working hypothesis, and the next cheap branch is D1b token-budget batching.

## Authority

- T1D grill locked D0/D7 sequencing and basis discipline: `docs/c5-training-readiness-grill/t1d-oom-grill-2026-07-03.md:6`, `:16-18`.
- Runbook D7 names MLX memory/cache knobs as diagnostic-only evidence: `docs/c5-training-readiness-grill/t1-oom-diagnostic-runbook-2026-07-03.md:47-60`.
- Hard artifacts are required by runbook §4: `docs/c5-training-readiness-grill/t1-oom-diagnostic-runbook-2026-07-03.md:62-72`.
- Baseline registry live basis IDs: `docs/BASELINE-REGISTRY.md:12-15`; basis ID rule: `docs/BASELINE-REGISTRY.md:27-30`.

## Fixed Recipe

Training recipe changes: none.

Preserved recipe facts:

- `batch_size=4`
- `grad_accumulation_steps=4`
- `rank=16`
- target modules count `7`
- `max_seq_length=8192`
- `val_batches=25`
- `iters=600`

Cache policy:

- `cache_clear_api=mx.clear_cache`
- `cache_limit_bytes=null`
- `set_cache_limit` was intentionally not used to avoid mixing clear-only and cache-limit hypotheses.

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
| val_time_seconds | `195.88424933282658` |

Resource envelope:

| peak_memory_bytes | wall_clock_seconds |
|---:|---:|
| `9356512384` | `243` |

## H-Cache Evidence

| sample | cache_bytes | active_bytes | peak_bytes | note |
|---|---:|---:|---:|---|
| `val_end` | `24302364612` | `1037912148` | `9356512384` | validation completed |
| `cache_cleared_before_train` before | `24302364612` | `1037912148` | `9356512384` | clear input |
| `cache_cleared_before_train` after | `0` | `1037912148` | `9356512384` | clear output |
| `train_step_enter` | `0` | `1037912148` | `0` | first train step entered cache-free |

The crash remained after cache reached zero. This excludes the narrow claim that validation cache carry-over alone causes the first-train-step OOM.

## H-Act Carry-Forward

The train batch shape and supervision remained the same as D0:

- first train microstep `batch_total_tokens=20036`
- first train microstep `batch_supervised_tokens=96`
- sampled validation max `batch_total_tokens=13236`
- sampled validation max `batch_supervised_tokens=122`

This keeps pressure aligned with total sequence activation, not supervised-token count.

## Artifacts

| artifact | sha256 / note |
|---|---|
| `run-train.sh` | `b954e848a13f6e8a58e88c7d64bc550b42703ce0fb80f386f994aa366fcee08e` |
| `config.yaml` | `4d64ac3b2b36ffb861719ea030e4d942419576e9890b9f4505d4c15e2c3bc31c` |
| `cache-policy.json` | `1d3dcecd70eb57905082c4112048a37488f8095f66d6747a0ea94948c7048011` |
| `c5_mlx_train_loop.snapshot.py` | `9363c20e4e8af7e7365e3c476a4c6963b8423ec0c2e654f29c7101647bb4d370` |
| `c5_mlx_train_loop.executed-source.py` | `9363c20e4e8af7e7365e3c476a4c6963b8423ec0c2e654f29c7101647bb4d370` |
| `train.log` | stdout/stderr with val completion and Metal OOM |
| `metrics.jsonl` | `52c9c8e5ca3959cfe5e427f1348d97e02ba151df339a20065cf48e84fedb3b28` |
| `memory-profile.jsonl` | `0cbf0c7dd0a74ca68d28841b1ccd633df1e00c13113afe10268a00e5af8663df` |
| `memory-profile.md` | human-readable profile summary |
| `validation.json` | `adeb65da597b7491be26414508e7884cef744e9fa371ff13b54b8cefc8cde513` |
| `watchdog.jsonl` | start + complete; no timeout |
| `resource-envelope.tsv` | two-column resource envelope |

## Non-Claims

- Not train-ready.
- Not a candidate recipe.
- Not model-quality evidence.
- Not C6 acceptance.
- Not V/S/U-PASS.

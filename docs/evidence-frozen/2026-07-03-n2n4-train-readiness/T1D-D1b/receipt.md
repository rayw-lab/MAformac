# T1D-D1b Receipt - token-budget batching diagnostic

status: FAIL
verdict: T1D_DIAGNOSTIC_FAIL_D1b_TOKEN_BUDGET_8192_STILL_OOM
proof_class: diagnostic_not_candidate
created_at: 2026-07-03

## Basis

- basis_id: CODE-2026-07-03 + DATA-WAVE1-SUBSTRATE-v2
- code pin: `b33d8eba152e5326f69bbe85fc356b73419ee9c3`
- code worktree: `/tmp/maformac-t1d-d0-b33d8eba`
- data/config baseline: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR31-final-n4a-recipe-build/`
- authority: `docs/BASELINE-REGISTRY.md:14-15`, `docs/c5-training-readiness-grill/t1d-oom-grill-2026-07-03.md:17-18`, `docs/c5-training-readiness-grill/t1-oom-diagnostic-runbook-2026-07-03.md:62-72`

## Scope

D1b used a run-directory snapshot only. Main tree code was not edited. The pinned worktree remains tracked-clean.

Changed diagnostic knob: `maformac_token_budget_per_microbatch=8192`.

Recipe retained unless explicitly diagnostic: `batch-size 4` remains the max rows per micro-batch, `grad_accumulation_steps=4`, `max_seq_length=8192`, `val_batches=25`, rank/modules/config unchanged. `iters=8` was set for this diagnostic to allow at least one optimizer update if the first four micro-batches survived. D7a `mx.clear_cache()` boundary was retained before train.

Variable-size micro-batches change effective batch semantics. This is acceptable as diagnostic evidence only; candidateization requires a separate spec/signoff.

## Implementation Evidence

- Command line: `run-train.sh:16-24` has batch4, grad_accum4, iters8, max_seq8192, val_batches25, token budget8192.
- Snapshot batching: `c5_mlx_train_loop.snapshot.py:1191-1211` groups sorted rows by padded token budget and max row cap; `:1249-1256` enables budget grouping in `maformac_iterate_batches`.
- Cache boundary: `c5_mlx_train_loop.snapshot.py:488-517` clears cache and resets the train peak counter after validation.
- Per micro-batch profile: `c5_mlx_train_loop.snapshot.py:530-540` records `train_step_enter` with `batch_shape` and token counts before forward.
- Optimizer evidence semantics: `c5_mlx_train_loop.snapshot.py:605-628` writes `optimizer_update` only when an update is reached.

## Run Evidence

- `execute-with-watchdog.sh` completed in 115s; training exit code recorded as `134`.
- `metrics.jsonl:1` records snapshot sha `66b5b90787e4fdb9b4b46152bb89c99af5cf6a4ca08247d1acc2e19d693594d6` and token budget `8192`.
- `metrics.jsonl:2` records loss-mask preflight pass: 4628 records, max token length 7185, trainable_tokens 113914.
- `metrics.jsonl:3` records finite validation loss: `val_loss=3.1303274631500244`, `val_time=70.19909887481481`.
- `memory-profile.jsonl:8-9` records val cache `24392386792` bytes, then `mx.clear_cache()` reducing cache to `0`.
- `memory-profile.jsonl:11` records the first train micro-batch: `batch_shape=[1,6209]`, `batch_padded_tokens=6209`, `batch_total_tokens=6197`, `batch_supervised_tokens=24`, cache `0`.
- `train.log:16` records Metal OOM: `kIOGPUCommandBufferCallbackErrorOutOfMemory`.
- `metrics.jsonl` has no `optimizer_update` row; the run aborted before `forward_after` / `backward_after` / `optimizer_after` samples.
- `adapters-rank16/` contains only `adapter_config.json`; no adapter weights were saved.

## Gate

| Gate | Required | Observed | Result |
|---|---:|---:|---|
| optimizer_update_count | >=1 | 0 | FAIL |
| finite loss/grad | finite train/optimizer row | not evaluable; no train/optimizer row | FAIL |
| adapter save | adapter weights saved | false | FAIL |
| OOM absent | true | false | FAIL |

## Resource Envelope

See `resource-envelope.tsv`.

| Component | Peak memory bytes | Wall clock | Cache bytes | Evidence |
|---|---:|---:|---:|---|
| model_load_after | 968017928 | NA | 3644 | `memory-profile.jsonl:1` |
| validation_25_batches | 3854628976 | 70.199s | 24392386792 | `memory-profile.jsonl:8` |
| cache_clear_boundary | 3854628976 | 0.054s | 0 | `memory-profile.jsonl:9` |
| train_first_microbatch_enter | 0 after reset | 0.004s after clear | 0 | `memory-profile.jsonl:11` |

## Conclusion

D1b budget batching was active and reduced the first train micro-batch to `[1,6209]` / `6209` padded tokens with cache already zeroed. The run still hit Metal OOM before the first forward-after sample and before any optimizer update. Therefore D1b at budget 8192 does not satisfy the pass gate and must not be candidateized.

Interpretation: H-cache remains excluded; H-act remains dominant, but D1b budget=8192 is insufficient under the current rank16/7-module/8192 recipe. Next diagnostic should move to D2 gradient checkpointing or an explicitly signed lower token budget / max_seq diagnostic; do not claim formal-training-ready from this run.

## Artifacts

- `run-train.sh`
- `execute-with-watchdog.sh`
- `config.yaml`
- `batching-policy.json`
- `budget-dry-run.json`
- `c5_mlx_train_loop.snapshot.py`
- `c5_mlx_train_loop.executed-source.py`
- `train.log`
- `metrics.jsonl`
- `memory-profile.jsonl`
- `memory-profile.md`
- `validation.json`
- `resource-envelope.tsv`
- `watchdog.jsonl`
- `exit-code.txt`
- `adapters-rank16/adapter_config.json` only; no adapter weights

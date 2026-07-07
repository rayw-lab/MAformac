# T1D-D2combo Receipt - grad checkpoint + token-budget batching

status: PASS
verdict: T1D_DIAGNOSTIC_PASS_D2COMBO_GRAD_CHECKPOINT_TOKEN_BUDGET_8192_LONGEST_ROW_COVERED
proof_class: diagnostic_not_candidate
created_at: 2026-07-03

## Basis

- basis_id: CODE-2026-07-03 + DATA-WAVE1-SUBSTRATE-v2
- code pin: `b33d8eba152e5326f69bbe85fc356b73419ee9c3`
- code worktree: `/tmp/maformac-t1d-d0-b33d8eba`
- data/config baseline: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR31-final-n4a-recipe-build/`
- authority: `docs/BASELINE-REGISTRY.md:14-15`, `docs/c5-training-readiness-grill/t1d-oom-grill-2026-07-03.md:17-18`, `docs/c5-training-readiness-grill/t1-oom-diagnostic-runbook-2026-07-03.md:52-55`, `docs/c5-training-readiness-grill/t1-oom-diagnostic-runbook-2026-07-03.md:62-72`

## Scope

Run-directory snapshot only. Main tree was not edited. The pinned worktree remains tracked-clean at `b33d8eba152e5326f69bbe85fc356b73419ee9c3`.

This run changes two diagnostic knobs:

- D2: `--grad-checkpoint`
- D1b: `--maformac-token-budget-per-microbatch 8192`

It also uses `--maformac-token-budget-order length_desc_train_only` to satisfy the explicit longest-row coverage gate. This affects train order only; validation still uses the original iterator permutation. This is diagnostic-only and not a candidate recipe.

## Command

`run-train.sh:16-26` records: rank/modules/config unchanged, `batch-size 4`, `grad_accumulation_steps 4`, `iters 8`, `max_seq_length 8192`, `val_batches 25`, token budget `8192`, train order `length_desc_train_only`, and `--grad-checkpoint`.

## Grad Checkpoint Wiring

Verified on the training interpreter `/opt/homebrew/opt/python@3.13/bin/python3.13` with `mlx_lm_version=0.31.1`.

- `grad-checkpoint-introspection.txt:1-3` records version/interpreter/trainer file.
- `grad-checkpoint-introspection.txt:5-18` records the actual implementation: `grad_checkpoint(layer)` replaces `type(layer).__call__` with a wrapper that calls `mx.checkpoint(inner_fn)(model.trainable_parameters(), *args, **kwargs)`.
- `memory-profile.jsonl:3` records the snapshot applying that path to `TransformerBlock`.

## Longest Row Coverage

- `coverage-dry-run-final.json:2-14` proves max train token length `7185`, train index `3101`, final order `length_desc_train_only`, and microbatch 1 shape `[1,7201]`.
- `memory-profile.jsonl:12-14` proves that same longest-row microbatch entered train and survived checkpointed forward/backward.
- `validation.json:58-74` marks `longest_row_covered=true`.

## Gate Evidence

| Gate | Required | Observed | Evidence | Result |
|---|---:|---:|---|---|
| optimizer_update_count | >=1 | 2 | `metrics.jsonl:4`, `metrics.jsonl:6`; `validation.json:36-41` | PASS |
| finite loss/grad | true | update losses/grad finite | `metrics.jsonl:4`, `metrics.jsonl:6`; `validation.json:42-46` | PASS |
| adapter save | true | `adapters.safetensors` saved sha `514ac84c33fedfb80b7de168785f4b83cf556196aca7d815da1dc89781023cee` | `validation.json:47-52` | PASS |
| OOM absent | true | exit 0, no OOM text | `watchdog.jsonl:2`; `validation.json:30-35`, `validation.json:53-57` | PASS |
| longest-row-covered | true | `[1,7201]`, total tokens `7185`, forward/backward observed | `memory-profile.jsonl:12-14`; `validation.json:58-74` | PASS |

## Resource Envelope

See `resource-envelope.tsv` and `memory-profile.md`.

| Component | Peak memory bytes | Evidence |
|---|---:|---|
| model load | 968017928 | `memory-profile.jsonl:1` |
| validation before train | 3880214760 | `memory-profile.jsonl:9` |
| cache clear before train | cache 0 | `memory-profile.jsonl:10-11` |
| longest row forward | 4996672898 | `memory-profile.jsonl:13` |
| longest row backward | 10036316842 | `memory-profile.jsonl:14` |
| optimizer update 1 | 17834496076 | `memory-profile.jsonl:18-19` |
| optimizer update 2 | 17973956628 | `memory-profile.jsonl:32-33`, `metrics.jsonl:7` |

## D1b Comparison

D1b failed at `train_step_enter` for `[1,6209]` with cache cleared and no `forward_after` sample: `T1D-D1b/memory-profile.jsonl:9-11`.

A stopped random-order D2combo probe is archived at `permutation-probe-random-order-stopped/`. It is not the final gate run, but it provides the requested same-batch comparison: `[1,6209]` with grad checkpoint survived forward/backward in `permutation-probe-random-order-stopped/memory-profile.jsonl:12-14`.

Reason for stopping that probe: seed0 random order placed the true longest row at microbatch 759, which projected multi-hour runtime. The final gate run therefore used train-only length-desc order so the true longest row was covered at microbatch 1.

## Conclusion

D2combo passes the diagnostic gate. With gradient checkpointing plus 8192 padded-token budget and the D7a cache boundary clear, the run covered the true longest training row (`7185` tokens / `[1,7201]` padded), completed two optimizer updates, kept loss/grad finite, saved adapter weights, and avoided OOM.

Do not candidateize this as-is. The pass depends on diagnostic train-order control plus variable-size microbatches, so a formal candidate requires separate spec/signoff for order semantics, effective batch semantics, and full recipe acceptance.

## Artifacts

- `run-train.sh`
- `execute-with-watchdog.sh`
- `config.yaml`
- `combo-policy.json`
- `batching-policy.json`
- `longest-row-coverage-plan.json`
- `coverage-dry-run-final.json`
- `grad-checkpoint-introspection.txt`
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
- `adapters-rank16/adapters.safetensors`
- `adapters-rank16/adapter_config.json`
- `permutation-probe-random-order-stopped/` archived as non-final comparison evidence

# Learning Rate Matters: Vanilla LoRA May Suffice for LLM Fine-tuning

## Verdict

- Gate: `retrain_c5_input`
- Proof class: `web_verified`, `local_static_teardown`, `schema_validated`
- Boundary: future C5 training-method input only. No current LoRA run.

The paper is directly relevant to MAformac because C5 currently carries a single rendered `learning_rate` in its MLX LoRA config/receipt path. The main lesson is uncomfortable but important: a single learning-rate run cannot justify claims about LoRA method quality, adapter rank, or advanced LoRA variants.

## Paper Identity

- Title: Learning Rate Matters: Vanilla LoRA May Suffice for LLM Fine-tuning
- arXiv: https://arxiv.org/abs/2602.04998
- Official project repo: https://github.com/yuang-lee/lr-matters-lora
- Local clone: `Tools/paper-to-skill-gate/paper-repos/lr-matters-lora`
- Local HEAD: `a81dca9`

## Evidence Summary

| Claim | Evidence | Confidence | MAformac implication |
|---|---|---|---|
| Re-evaluates LoRA variants under broader hyperparameter searches | arXiv abstract says it searches learning rate, batch size, rank, and training duration across tasks/scales. | high | Future C5 should not compare adapter candidates from a single LR. |
| Proper LR tuning makes methods similar at peak | arXiv abstract says all methods achieve similar peak performance within 1-2% once LR is tuned. | high | Vanilla LoRA remains a strong baseline before adopting more complex adapters. |
| Hessian eigenvalue explains relative LR ranges | arXiv abstract and repo practical heuristics discuss maximum Hessian eigenvalue. | medium | Optional future diagnostic; too heavy for current local Mac acceptance path. |
| Official repo has code but low stars | `gh repo view yuang-lee/lr-matters-lora`: 7 stars, `pushedAt=2026-06-24`. | high | Use code as implementation evidence, not as high-community validation. |

## Official Repo Branch

Code mapping status: `CODE_CONFIRMED`

| Paper/repo mechanism | Local code anchor | Status | MAformac reading |
|---|---|---|---|
| PEFT variants and LoRA hyperparameters | `paper-repos/lr-matters-lora/run-lora/train.py:40` | CODE_CONFIRMED | Richer than MAformac's current MLX LoRA config; do not import wholesale. |
| Quantization and LoRA model build path | `paper-repos/lr-matters-lora/run-lora/train.py:210` | CODE_CONFIRMED | Useful comparison to MAformac `bf16_lora_on_4bit_base`. |
| LR sweep loop across seeds/rank/batch/task/peft | `paper-repos/lr-matters-lora/run-lora/scripts/qwen/math.sh:43` | CODE_CONFIRMED | Direct pattern for future C5 sweep ledger. |
| Per-run `perf.json` skip/pass evidence | `paper-repos/lr-matters-lora/run-lora/scripts/qwen/math.sh:113` | CODE_CONFIRMED | Similar to MAformac receipt discipline. |
| Lanczos Hessian estimate | `paper-repos/lr-matters-lora/run-hessian/lanczos.py:34` | CODE_CONFIRMED | Optional future diagnostic, not first C5 gate. |
| Practical heuristics prioritize LR tuning | `paper-repos/lr-matters-lora/practical-heuristics/README.md:13` | CODE_CONFIRMED | Should become a C5 method-gate note. |
| Rank increases still need LR retuning | `paper-repos/lr-matters-lora/practical-heuristics/README.md:122` | CODE_CONFIRMED | Prevents rank-only "fixes" without LR search. |

## Algorithm Traits

- Hyperparameter sensitivity is the central claim, not a side note.
- LR, batch size, rank, duration, and method must be recorded together.
- Peak comparison matters more than a fixed-config comparison.
- Hessian is useful for narrowing LR range, but not required for first-stage adoption.

## MAformac Insertion Points

| Path | Lane | Recommendation | Stop condition |
|---|---|---|---|
| `Core/Training/C5LoRATraining.swift` | `retrain_c5` | Add future receipt fields for LR grid, candidate sweep ID, best-val policy, and method comparison boundary. | No training-method schema changes before OpenSpec. |
| `Tools/C5TrainingCLI/main.swift` | `retrain_c5` | Future rendered command should support sweep packets, not just one `--learning-rate`. | No current CLI mutation. |
| `Tools/C5TrainingCLI/c5_mlx_train_loop.py` | `retrain_c5` | Existing metrics JSONL already logs LR and grad norm; future sweep can reuse it. | No current training. |
| `Core/Bench/C6VehicleToolBench.swift` | `rebuild_c6` | C6 final comparison should be after LR sweep, not one arbitrary adapter. | No C6 JSONL rewrite now. |

## OpenSpec Candidate Deltas

- `retrain-c5`: C5 candidate claim requires at least a minimal LR sweep or an explicit "single-LR train-health only" label.
- `retrain-c5`: Add `lr_grid`, `rank_grid`, `batch_size`, `seed_count`, `best_checkpoint_policy`, and `comparison_scope` to receipt schema.
- `retrain-c5`: `lora_candidate` cannot be promoted from one training run unless the OpenSpec defines that as acceptable.
- `rebuild-c6`: Adapter-vs-adapter C6 comparison must report the LR/rank/seed grid behind each adapter.

## Residual Risks

- Official repo has few stars and only six commits; code should be read, not trusted blindly.
- Paper experiments are on public reasoning/code/instruction tasks, not MAformac D-domain vehicle tool calls.
- Hessian diagnostics are likely too expensive for the Mac-first workflow unless scoped tightly.
- This does not prove MAformac's current LR is wrong; it proves single-LR confidence is weak.

## Deliverables

- Human report: `trial-runs/learning-rate-matters-vanilla-lora-may-suffice.md`
- Machine packet: `trial-runs/learning-rate-matters-vanilla-lora-may-suffice.gate.json`
- Official repo clone: `paper-repos/lr-matters-lora`

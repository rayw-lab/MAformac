# P0 Gate Pack: Function-Calling Data Generation

Generated: 2026-06-24T08:36:17Z

## Gate Verdict

Status: `retrain_c5_input`

Proof class: `web_verified`, `local_static_teardown`, `not_executed`, `schema_validated`

This pack combines APIGen, ToolACE, Hammer, and Magnet because the load-bearing question is not any single leaderboard number. The question is how MAformac should generate and verify function-calling data while preserving negative/irrelevance coverage and multi-turn trajectory shape.

## Source Manifest

| Paper / project | Evidence |
|---|---|
| APIGen `2406.18518` | `https://arxiv.org/abs/2406.18518` |
| APIGen NeurIPS PDF | `https://proceedings.neurips.cc/paper_files/paper/2024/file/61cce86d180b1184949e58939c4f983d-Paper-Datasets_and_Benchmarks_Track.pdf` |
| ToolACE `2409.00920` | `https://arxiv.org/abs/2409.00920` |
| Hammer `2410.04587` | `https://arxiv.org/abs/2410.04587` |
| Magnet `2503.07826` | `https://arxiv.org/abs/2503.07826` |
| Magnet ACL | `https://aclanthology.org/2025.acl-long.1566/` |
| xLAM/APIGen local repo | `Tools/paper-to-skill-gate/paper-repos/xLAM`, HEAD `a88aa3a` |
| Hammer local repo | `Tools/paper-to-skill-gate/paper-repos/Hammer`, HEAD `ff415d9` |

## Code Teardown

| Code anchor | What matters |
|---|---|
| `paper-repos/xLAM/README.md:44` | xLAM repo points to APIGen and the `xlam-function-calling-60k` dataset. |
| `paper-repos/xLAM/README.md:58` | xLAM standardizes heterogeneous agent trajectories into a unified loader. |
| `paper-repos/xLAM/actionstudio/src/data_pipeline/data_converters.py:41` | Data converter materializes per-source training data dictionaries. |
| `paper-repos/xLAM/actionstudio/examples/data_configs/data_mixture_config.yaml:9` | Config tracks ToolACE size. |
| `paper-repos/xLAM/actionstudio/examples/data_configs/data_mixture_config.yaml:17` | Config tracks `xlam-fc-60k` size. |
| `paper-repos/xLAM/actionstudio/examples/trainings/README.md:11` | Training docs recommend data verification before training. |
| `paper-repos/xLAM/actionstudio/examples/trainings/README.md:51` | Repo supports LoRA fine-tuning path. |
| `paper-repos/xLAM/actionstudio/examples/trainings/README.md:60` | Repo supports NF4 + LoRA path, but that is CUDA/DeepSpeed-style and not MAformac MLX permission. |
| `paper-repos/Hammer/README.md:20` | Hammer releases lightweight 0.5B/1.5B/3B/7B function-calling models. |
| `paper-repos/Hammer/README.md:261` | Hammer trains from xLAM 60k plus irrelevance 7.5k data. |
| `paper-repos/Hammer/train/data_processing.py:263` | Hammer reads xLAM positive function-call data and irrelevance data. |
| `paper-repos/Hammer/train/data_processing.py:283` | Hammer applies function masking ratio logic. |
| `paper-repos/Hammer/client/config.py:22` | Hammer instruction explicitly covers call, refuse, and missing-parameter behavior. |

## Ambiguity Audit

| Item | Classification | Notes |
|---|---|---|
| APIGen verifiable dataset idea | `SPECIFIED` | Paper and xLAM/HF dataset references are verified. |
| ToolACE method details | `PAPER_ONLY` | No official repo was cloned in this pass; source remains paper/HF-level. |
| Hammer function masking | `CODE_CONFIRMED` | Local code confirms positive+irrelevance data mixing and masking processing. |
| Magnet graph trajectory synthesis | `PAPER_ONLY` | ACL/arXiv verified; no official repo found in this pass. |
| MAformac data generation adoption | `PARTIALLY_SPECIFIED` | Needs C5 generator proposal; no training now. |

## MAformac Absorption

| Path | Lane | Recommendation |
|---|---|---|
| `Core/Training/C5LoRATraining.swift:597` | `retrain_c5` | Add future checks for data diversity, variant caps, lineage overlap, and negative composition. |
| `Tools/C5TrainingCLI/c5_mlx_train_loop.py:78` | `retrain_c5` | Keep MLX SFT loop as current substrate; do not import DeepSpeed/LLaMA-Factory assumptions. |
| `Core/Contracts/ToolContractCompiler.swift:62` | `tool_surface` | Use D-domain concrete tools as the function schema source for synthetic data, not generic frame. |
| `generated/D_domain.tools.demo.json` | `tool_surface` | Future generator should sample from the generated D-domain tool catalog and record source snapshot. |
| `Core/Bench/C6VehicleToolBench.swift:25` | `rebuild_c6` | Pair generated positives with irrelevance/no-call/clarify counterexamples. |

## Remediation Plan Candidate

1. Build a C5 data generation proposal with three streams: verified positive calls, irrelevance/no-call negatives, missing-slot clarification cases.
2. Require source snapshot digest and parent overlap checks before any generated data can be train-eligible.
3. Treat Hammer function masking as a candidate transformation, but test it against MAformac tool-surface mismatch first.
4. Treat Magnet as a multi-turn trajectory design reference only; second-turn memory needs MAformac's own boundary.

## Stop Conditions

- Do not run any trainer.
- Do not adopt LLaMA-Factory/DeepSpeed just because upstream uses it.
- Do not mix positive and irrelevance data without explicit ratio gates.
- Do not generate new C5 rows from private/raw customer material.
- Do not let generated trajectory data bypass family/template/semantic split checks.

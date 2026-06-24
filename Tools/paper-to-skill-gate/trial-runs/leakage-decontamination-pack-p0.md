# P0 Gate Pack: Leakage And Decontamination

Generated: 2026-06-24T08:36:17Z

## Gate Verdict

Status: `retrain_c5_input`

Proof class: `web_verified`, `local_static_teardown`, `not_executed`, `schema_validated`

This pack is P0 because C5/C6 can fake-green if train/eval leakage is only checked by exact IDs. The pack combines Rephrased Samples, SemDeDup, Leaner Training Lower Leakage, and LoRA-Leak. The immediate value is data gate and split hardening, not privacy research adoption.

## Source Manifest

| Paper / project | Evidence |
|---|---|
| Rephrased Samples `2311.04850` | `https://arxiv.org/abs/2311.04850` |
| llm-decontaminator local repo | `Tools/paper-to-skill-gate/paper-repos/llm-decontaminator`, HEAD `931834a` |
| SemDeDup `2303.09540` | `https://arxiv.org/abs/2303.09540` |
| SemDeDup local repo | `Tools/paper-to-skill-gate/paper-repos/SemDeDup`, HEAD `6b41945` |
| Leaner Training Lower Leakage `2506.20856` | `https://arxiv.org/abs/2506.20856` |
| LoRA-Leak `2507.18302` | `https://arxiv.org/abs/2507.18302` |

## Code Teardown

| Code anchor | What matters |
|---|---|
| `paper-repos/llm-decontaminator/README.md:7` | Tool quantifies rephrased samples relative to benchmark. |
| `paper-repos/llm-decontaminator/README.md:60` | End-to-end command compares train/test paths. |
| `paper-repos/llm-decontaminator/README.md:71` | README reports real dataset contamination table. |
| `paper-repos/llm-decontaminator/train/README.md:13` | Repo can tokenize rephrase samples for fine-tuning. |
| `paper-repos/llm-decontaminator/llm_detect.py:18` | LLM detector compares two question strings with an instruction. |
| `paper-repos/llm-decontaminator/llm_detect.py:107` | Detector counts rephrased test cases. |
| `paper-repos/SemDeDup/README.md:4` | SemDeDup targets semantic duplicates, not exact duplicates. |
| `paper-repos/SemDeDup/README.md:27` | Pipeline begins with pretrained embeddings. |
| `paper-repos/SemDeDup/README.md:60` | Then runs K-means clustering on embeddings. |
| `paper-repos/SemDeDup/semdedup.py:60` | Code computes pairwise cosine similarity inside clusters. |
| `paper-repos/SemDeDup/semdedup.py:78` | Removes examples whose similarity exceeds threshold. |
| `paper-repos/SemDeDup/extract_dedup_data.py:14` | Extracts kept/removed example paths after pruning. |

## Ambiguity Audit

| Item | Classification | Notes |
|---|---|---|
| Exact-ID decontamination insufficiency | `SPECIFIED` | Rephrased Samples source and repo both target paraphrase/translation style overlap. |
| Semantic duplicate removal algorithm | `CODE_CONFIRMED` | SemDeDup repo confirms embeddings, clustering, thresholding, path extraction. |
| LoRA leakage risk | `PAPER_ONLY` | LoRA-Leak paper verified; no official repo cloned. |
| LoRA reduces memorization vs full FT | `PAPER_ONLY` | Leaner Training paper verified; do not overstate as zero leakage. |
| MAformac split policy | `PARTIALLY_SPECIFIED` | Existing C5 gate has lineage/overlap hooks; semantic split still needs future hardening. |

## MAformac Absorption

| Path | Lane | Recommendation |
|---|---|---|
| `Core/Training/C5LoRATraining.swift:597` | `retrain_c5` | Extend candidate data quality gate with family/template/semantic overlap and leakage receipts. |
| `Tools/C5TrainingCLI/c5_mlx_train_loop.py:83` | `retrain_c5` | Training loop should emit source snapshot references; no hidden train/eval reuse. |
| `Core/Bench/C6VehicleToolBench.swift:98` | `rebuild_c6` | Future held-out cases should be protected from paraphrase/template leakage, not only row ID overlap. |
| `contracts/c6-bench-cases.jsonl` | `rebuild_c6` | Use family-level and template-level split metadata before C6 is used as a final gate. |

## Remediation Plan Candidate

1. Add semantic overlap scan as a future data-gate stage: embeddings or LLM-based near-duplicate detector over train vs C6 heldout.
2. Require a leakage receipt before any adapter is called a candidate.
3. Separate privacy risk from benchmark contamination: both matter, but C5/C6 fake green is the immediate MAformac risk.
4. Treat LoRA-Leak as a warning that LoRA is not leak-proof; do not use Leaner Training to claim safety.

## Stop Conditions

- Do not declare C5 train-ready from exact-ID split alone.
- Do not call LoRA privacy-safe just because it is parameter-efficient.
- Do not run OpenAI/API-based decontamination on private/raw data without explicit redaction and authorization.
- Do not move raw customer/source material into repo.

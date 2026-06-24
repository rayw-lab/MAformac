# P0 Gate: When2Call

Generated: 2026-06-24T08:36:17Z

## Gate Verdict

Status: `rebuild_c6_input`

Proof class: `web_verified`, `local_static_teardown`, `not_executed`, `schema_validated`

When2Call is P0 because it directly targets a current MAformac failure mode: models that can call tools still need to know when not to call, when to request missing information, and when to admit the tools cannot answer. This should shape C6 negative/clarification/refusal cases before it changes C5 training.

## Source Manifest

| Source | Evidence |
|---|---|
| arXiv `2504.18851` | `https://arxiv.org/abs/2504.18851` |
| Official repo | `https://github.com/NVIDIA/When2Call` |
| Local repo | `Tools/paper-to-skill-gate/paper-repos/When2Call`, HEAD `ecc8d42` |
| GitHub metadata | 64 stars, pushed `2025-04-29T00:12:04Z` |

## Code Teardown

| Code anchor | What matters |
|---|---|
| `paper-repos/When2Call/README.md:5` | Benchmark goal is when to call, request info, or cannot answer, not just tool-call accuracy. |
| `paper-repos/When2Call/README.md:22` | Gold labels are `direct`, `tool_call`, `request_for_info`, `cannot_answer`. |
| `paper-repos/When2Call/README.md:56` | SFT format has tools plus user/assistant messages. |
| `paper-repos/When2Call/README.md:80` | Preference format has chosen/rejected response pairs. |
| `paper-repos/When2Call/README.md:108` | Tool-call wrapper is model-template dependent and must be adapted, not copied. |
| `paper-repos/When2Call/synthetic_data_gen/create_raw_train_data.py:78` | Generates refusal examples by removing the correct tool. |
| `paper-repos/When2Call/synthetic_data_gen/create_raw_train_data.py:99` | Generates request-for-info examples by removing required parameters. |
| `paper-repos/When2Call/synthetic_data_gen/create_raw_train_data.py:122` | Generates positive tool-call examples. |
| `paper-repos/When2Call/synthetic_data_gen/convert_raw_train_data_to_pref.py:57` | Builds chosen/rejected preference pairs across behavior categories. |
| `paper-repos/When2Call/evaluation/mcq/lm_eval_harness/when2call/additional_metrics.py:21` | Defines tool hallucination rate when correct answer is cannot-answer and no tools are available. |
| `paper-repos/When2Call/evaluation/llm_as_a_judge/run_openai_judge.py:26` | LLM judge classifies behavior only; it is not judging factual answer quality. |

## Ambiguity Audit

| Item | Classification | Notes |
|---|---|---|
| Four behavior labels | `CODE_CONFIRMED` | README and judge code agree. |
| Preference training value | `CODE_CONFIRMED` | Repo has preference conversion script. |
| MAformac prompt wrapper | `PARTIALLY_SPECIFIED` | Repo explicitly says wrapper must be adapted to the target model template. |
| C6 judge shape | `PARTIALLY_SPECIFIED` | LLM-as-judge classifier is useful, but MAformac should prefer deterministic harness where possible. |
| Training adoption | `UNSPECIFIED` | No authorization to run RPO/DPO or add preference training. |

## MAformac Absorption

| Path | Lane | Recommendation |
|---|---|---|
| `Core/Bench/C6VehicleToolBench.swift:4` | `rebuild_c6` | Add first-class behavior classes: direct/no-call, tool-call, clarify, refusal. Existing `C6ClarifyTag` and `C6FailureClass` already have hooks. |
| `contracts/c6-bench-cases.jsonl` | `rebuild_c6` | Future case generation should include missing-required-slot, no-available-tool, and irrelevant-tool distractors. |
| `Core/Training/C5LoRATraining.swift:597` | `retrain_c5` | Candidate data quality gate should track negative/clarify/refusal ratio separately from positive tool exact-match. |
| `Tools/C5TrainingCLI/c5_mlx_train_loop.py:78` | `retrain_c5` | If preference-like data is ever adopted, it needs a separate proposal; current MLX SFT loop is not a DPO/RPO trainer. |

## Remediation Plan Candidate

1. Add a future C6 design section for four behavior labels.
2. Extend C5 data ledger with `correct_answer`-style label for no-call/refusal/clarify cases.
3. Keep preference optimization as a later escape hatch; do not smuggle it into SFT.

## Stop Conditions

- Do not run preference optimization.
- Do not import `<TOOLCALL>` wrappers unchanged; map to MAformac/Qwen template first.
- Do not treat LLM-as-judge classification as final product proof.
- Do not collapse refusal and clarification into one negative bucket.

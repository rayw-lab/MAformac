# Internalizing Tool Knowledge in Small Language Models via QLoRA Fine-Tuning

## Verdict

- Gate: `retrain_c5_input`
- Proof class: `web_verified`, `schema_validated`, `not_executed`
- Boundary: future C5 data/eval design input only. No QLoRA adoption, no training, no C6 rebuild.

This paper is relevant because MAformac has a large D-domain tool catalog and wants small-model function calling. Its central idea is to fine-tune a small model so tool names, server ownership, argument keys, and dependency patterns are internalized, allowing description-free inference. But the paper also reports retention degradation, especially for Qwen3-4B, so the right absorption is a guarded future experiment, not direct adoption.

## Paper Identity

- Title: Internalizing Tool Knowledge in Small Language Models via QLoRA Fine-Tuning
- arXiv HTML/PDF: https://arxiv.org/html/2605.17774
- Official repo: none found in this pass (`gh search repos "Internalizing Tool Knowledge" QLoRA` and `AssetOpsBench QLoRA tool knowledge` returned no candidates)

## Evidence Summary

| Claim | Evidence | Confidence | MAformac implication |
|---|---|---|---|
| Uses AssetOpsBench with MCP-style tools | arXiv HTML describes AssetOpsBench as 152 natural-language scenarios requiring server/tool/argument/order planning. | high | Similar to MAformac D-domain tool selection and C6 planning cases. |
| Teacher-student construction removes catalog at student inference | Paper states teacher sees full serialized catalog; student training/eval removes catalog from prompt. | high | Candidate comparison: full D-domain catalog vs retrieved subset vs internalized tool knowledge. |
| Config C has tool + plan examples | Paper says Config C uses 1,741 examples and broadest tool-knowledge coverage. | high | Future C5 data composition branch. |
| Prompt tokens reduced by 94.7% in description-free setting | Paper reports full prompt about 2,400 tokens and description-free prompt 128 tokens. | high | Attractive for on-device latency/context, but must prove tool accuracy. |
| Qwen3 retention risk | Paper reports Qwen3-4B retains only 61.3% of base performance in their retention benchmark. | high | MAformac must add retention/non-regression gate before adopting internalization. |
| No official repo found | Local GitHub search returned no matching repo. | medium | No code branch; packet remains paper-only for implementation details. |

## Official Repo Branch

Code mapping status: `NO_REPO`

No official GitHub repository was found in this pass. Therefore:

- No training script, data generator, judge prompt implementation, or eval harness was code-confirmed.
- All implementation details remain paper-derived.
- Any MAformac adoption must start as an OpenSpec-backed spike with its own reproducible scripts.

## Algorithm Traits

- Tool knowledge is treated as adapter-parametric memory.
- Training data splits into tool/server knowledge, question-to-plan, and execution-style traces.
- Inference can be description-free, but only after supervised internalization.
- Evaluation should include tool accuracy, argument quality, dependency correctness, and general capability retention.
- QLoRA/8-bit setup is not the same as MAformac's current MLX LoRA path.

## MAformac Insertion Points

| Path | Lane | Recommendation | Stop condition |
|---|---|---|---|
| `Core/Training/C5LoRATraining.swift` | `retrain_c5` | Future data categories: tool knowledge, query-to-plan, execution trace, retention probes. | No C5 dataset mutation now. |
| `Core/Contracts/ToolContractCompiler.swift` | `tool_surface` | Future compare: full 562 D-domain catalog vs retrieved subset vs no-catalog/internalized prompt. | No model-visible surface change now. |
| `Core/Bench/C6VehicleToolBench.swift` | `rebuild_c6` | Future C6 branch: description-free inference must pass tool selection, argument, dependency, state/readback, and retention gates. | No C6 JSONL rewrite now. |
| `Tools/C5TrainingCLI/c5_mlx_train_loop.py` | `retrain_c5` | QLoRA is not a drop-in MLX LoRA change; require backend compatibility spike first. | No QLoRA claim or dependency import now. |

## OpenSpec Candidate Deltas

- `retrain-c5`: add data composition fields for `tool_knowledge`, `question_to_plan`, and `execution_trace`.
- `retrain-c5`: add prompt-surface experiment comparing full catalog, retrieved catalog, and description-free/internalized prompt.
- `rebuild-c6`: add retention/non-regression checks before accepting tool-knowledge internalization.
- `research-paper-to-skill-gate`: when no official repo exists, gate packet must mark implementation details as paper-only.

## Residual Risks

- No code repo found; implementation details may be incomplete or not reproducible.
- Benchmark is industrial asset operations, not vehicle cockpit state control.
- Qwen3-4B retention degradation is a warning sign for MAformac's Qwen3 route.
- Their QLoRA setup and A100 cost profile do not directly map to MAformac MLX-on-Mac constraints.

## Deliverables

- Human report: `trial-runs/internalizing-tool-knowledge-in-slms-via-qlora.md`
- Machine packet: `trial-runs/internalizing-tool-knowledge-in-slms-via-qlora.gate.json`

# TinyAgent: Function Calling at the Edge

## Verdict

- Gate: `spike_only`
- Proof class: `web_verified`, `local_static_teardown`, `schema_validated`
- Boundary: research artifact only. No C3 multi-step planner, no D-domain retrieval runtime change, no LoRA training.

TinyAgent is highly relevant to MAformac because it targets function calling on small edge-deployed models and demonstrates a Mac assistant. It should not be adopted directly. The safe absorption route is a future `tool-surface-retrieval-spike` or `retrain-c5` proposal that tests D-domain tool subset retrieval and tool-call data construction without changing current runtime.

## Paper Identity

- Title: TinyAgent: Function Calling at the Edge
- Venue: EMNLP 2024 Demo
- Paper: https://aclanthology.org/2024.emnlp-demo.9/
- arXiv: https://arxiv.org/abs/2409.00608
- Official repo: https://github.com/SqueezeAILab/TinyAgent
- Local clone: `Tools/paper-to-skill-gate/paper-repos/TinyAgent`
- Local HEAD: `cc45c0e`

## Evidence Summary

| Claim | Evidence | Confidence | MAformac implication |
|---|---|---|---|
| Edge function-calling SLM framework | ACL abstract says TinyAgent trains/deploys task-specific SLM agents for function calling at the edge. | high | Fit with Qwen3 small-model + offline demo direction. |
| Uses LLMCompiler and curated data | ACL abstract states function calling is enabled via LLMCompiler and high-quality dataset curation. | high | Useful for C5 data construction and C6 failure taxonomy. |
| Tool retrieval reduces prompt length | ACL abstract mentions tool retrieval to reduce prompt length; repo describes ToolRAG. | high | Candidate for D-domain tool subset retrieval over 562 tools. |
| MacBook assistant demo | ACL abstract says local Siri-like MacBook app executes commands through text/voice. | high | Similar platform, but their desktop app tools are not vehicle-control safety gates. |
| Official repo is high-star but not recently code-pushed | `gh repo view SqueezeAILab/TinyAgent`: 486 stars, `pushedAt=2024-09-04`. | high | Do not treat it as a current active implementation baseline. |

## Official Repo Branch

Code mapping status: `CODE_CONFIRMED`

| Paper/repo mechanism | Local code anchor | Status | MAformac reading |
|---|---|---|---|
| Planner enumerates allowed tools and forces strict syntax | `paper-repos/TinyAgent/src/llm_compiler/planner.py:37` | CODE_CONFIRMED | Similar to D-domain named tool surface, but TinyAgent prompt is dynamically rebuilt. |
| Parser fails on unknown tool names | `paper-repos/TinyAgent/src/llm_compiler/output_parser.py:80` | CODE_CONFIRMED | Similar to C6 `parser/tool_call` failure separation; useful future failure class. |
| Controlled stop and correction on parse errors | `paper-repos/TinyAgent/src/llm_compiler/planner.py:185` | CODE_CONFIRMED | Candidate for future planner/judge loops, not current C3 execution. |
| Dependency graph and parallel scheduling | `paper-repos/TinyAgent/src/llm_compiler/task_fetching_unit.py:82` | CODE_CONFIRMED | Interesting but out-of-scope for current single-hop demo. |
| Tool enum has 16 Mac tools | `paper-repos/TinyAgent/src/tiny_agent/models.py:83` | CODE_CONFIRMED | MAformac has 562 D-domain tools; naive full prompt is riskier. |
| Classifier ToolRAG maps query to tool subset | `paper-repos/TinyAgent/src/tiny_agent/tool_rag/classifier_tool_rag.py:19` | CODE_CONFIRMED | Strongest absorption candidate: retrieve a small D-domain subset plus examples. |
| Runtime rebuilds planner prompt with retrieved tools/examples | `paper-repos/TinyAgent/src/tiny_agent/tiny_agent.py:129` | CODE_CONFIRMED | Good spike target for prompt-compression eval. |

## Algorithm Traits

- Function calling is treated as structured planning, not free-form chat.
- Tool surface is a closed enum.
- ToolRAG first selects relevant tools, then retrieves examples for those tools.
- Parser failure becomes a controlled replan signal, not silent fallback.
- Multi-step dependency execution is first-class; this is out-of-scope for current MAformac single-hop control.

## MAformac Insertion Points

| Path | Lane | Recommendation | Stop condition |
|---|---|---|---|
| `Core/Contracts/ToolContractCompiler.swift` | `tool_surface` | Future spike: retrieve subset of D-domain schemas/examples before model call. | Do not alter rendered tools without OpenSpec acceptance. |
| `Core/Training/C5LoRATraining.swift` | `retrain_c5` | Add future data rows for tool-subset prompts and distractor tools. | No C5 training until `retrain-c5` is authorized. |
| `Core/Bench/C6VehicleToolBench.swift` | `rebuild_c6` | Add retrieval-miss and parser-tool-name-miss failure classes in future C6 design. | Do not rewrite bench JSONL now. |
| `Core/Execution/C3ExecutionPipeline.swift` | `runtime_execution` | Keep TinyAgent multi-step planner as spike-only; C3 remains single-hop guarded execution. | No multi-step plan executor in default-scope apply. |

## OpenSpec Candidate Deltas

- New change candidate: `tool-surface-retrieval-spike`.
- Requirement candidate: Given a query, retrieved D-domain subset MUST contain gold tool for must-pass cases before the model is called.
- Requirement candidate: Tool retrieval MUST record false-negative and dangerous-distractor rates.
- Requirement candidate: Full 562-schema prompt, retrieved subset prompt, and no-catalog/internalized prompt MUST be compared separately.

## Residual Risks

- Official repo code is stale by `pushedAt`, despite current stars.
- TinyAgent tool set is Mac productivity tools, not vehicle state/readback controls.
- Their multi-step dependency planner could conflict with MAformac's safety-first single-hop mock execution.
- Reported model success rates are not MAformac C6 acceptance evidence.

## Deliverables

- Human report: `trial-runs/tinyagent-function-calling-at-the-edge.md`
- Machine packet: `trial-runs/tinyagent-function-calling-at-the-edge.gate.json`
- Official repo clone: `paper-repos/TinyAgent`

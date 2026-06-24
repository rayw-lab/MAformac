# MAformac Integration Map

This map is intentionally non-authoritative. It is a research-to-OpenSpec bridge for later work.

Current hard boundary: the active default-scope apply route does not authorize training, C6 rebuild, golden-run execution, voice work, or UIUE merge.

## Existing Code Insertion Points

### C5 Data And LoRA Training

Relevant files:

- `Core/Training/C5LoRATraining.swift:50` defines masking stages and train eligibility.
- `Core/Training/C5LoRATraining.swift:65` separates train-health, trainable-v0, and LoRA-candidate acceptance stages.
- `Core/Training/C5LoRATraining.swift:71` separates demo/full training scope.
- `Core/Training/C5LoRATraining.swift:77` separates D-domain surface from legacy frame surface.
- `Core/Training/C5LoRATraining.swift:479` declares training curve receipt fields.
- `Core/Training/C5LoRATraining.swift:506` evaluates training method authority against OpenSpec.
- `Core/Training/C5LoRATraining.swift:567` hard-codes current scale authority.
- `Core/Training/C5LoRATraining.swift:597` evaluates candidate data quality.
- `Core/Training/C5LoRATraining.swift:677` collects C5 training build options.
- `Tools/C5TrainingCLI/main.swift:25` fail-fast checks training scope before expensive work.
- `Tools/C5TrainingCLI/main.swift:175` renders the MLX training command.
- `Tools/C5TrainingCLI/c5_mlx_train_loop.py:48` pins `mlx-lm` version.
- `Tools/C5TrainingCLI/c5_mlx_train_loop.py:165` owns the clipped training loop.
- `Tools/C5TrainingCLI/c5_mlx_train_loop.py:324` stops on nonfinite loss or grad.
- `Tools/C5TrainingCLI/c5_mlx_train_loop.py:342` writes optimizer update metrics including learning rate and grad norm.
- `Tools/C5TrainingCLI/c5_mlx_train_loop.py:467` builds the optimizer schedule.

Absorption candidates:

- From `Learning Rate Matters`: add future C5 proposal text requiring a small LR sweep before declaring LoRA method quality. The current single `learning_rate` receipt is not enough for model-quality claims.
- From `Internalizing Tool Knowledge`: add future C5 data composition fields for `tool_knowledge`, `question_to_plan`, and `execution_trace`, but only under `retrain-c5`.
- From `TinyAgent`: add future C5/C6 tool-call data variants around retrieved D-domain tool subsets, not the full 562-tool prompt.

Stop condition:

- If a paper suggests changing rank, LR, adapter type, or dataset composition, it must enter a new or existing `lora-training` OpenSpec change. No direct training-run mutation from this folder.

### D-Domain Tool Surface

Relevant files:

- `Core/Contracts/ToolContractCompiler.swift:49` renders D-domain tool schemas.
- `Core/Contracts/ToolContractCompiler.swift:62` makes D-domain named tools the model-visible surface.
- `Core/Contracts/ToolContractCompiler.swift:158` normalizes tool calls.
- `Core/Contracts/ToolContractCompiler.swift:165` prioritizes D-domain IR map lookup.
- `Core/Contracts/ToolContractCompiler.swift:193` logs unclassified tool names instead of swallowing them.
- `Core/Contracts/ToolContractCompiler.swift:218` resolves primitives.
- `Core/Contracts/ToolContractCompiler.swift:233` builds heterogeneous value arguments into canonical value IR.

Absorption candidates:

- From `TinyAgent`: add a future tool retrieval proposal for selecting a small relevant subset of D-domain tools plus examples before Qwen inference.
- From `Internalizing Tool Knowledge`: add a future comparison branch: prompt-time schema catalog vs adapter-internalized tool knowledge vs retrieval-shortened schema.
- From `paper2code`: require every tool-surface modification to include `PAPER_ONLY / CODE_CONFIRMED / CODE_CONFLICT` mapping when derived from a paper.

Stop condition:

- No new generated tool catalog or prompt surface can be applied without OpenSpec acceptance and C5/C6 parity checks.

### C2/C3 Execution And Readback

Relevant files:

- `Core/Execution/ScopeResolution.swift:21` resolves omitted, explicit, and fan-out scope.
- `Core/Execution/ScopeResolution.swift:46` requires C2 `default_scope` for omitted scoped cells.
- `Core/Execution/C3ExecutionPipeline.swift:74` requires semantic row validity.
- `Core/Execution/C3ExecutionPipeline.swift:79` enforces L1 primitive allowlist.
- `Core/Execution/C3ExecutionPipeline.swift:89` gates implicit intent confirmation.
- `Core/Execution/C3ExecutionPipeline.swift:99` evaluates risk policy.
- `Core/Execution/C3ExecutionPipeline.swift:110` plans transitions.
- `Core/Execution/C3ExecutionPipeline.swift:117` executes, verifies readback, and records trace.
- `Core/Execution/C3ExecutionPipeline.swift:163` consumes C2 scope resolution.
- `Core/Execution/C3ExecutionPipeline.swift:191` normalizes values.

Absorption candidates:

- From `TinyAgent`: parser error should route into a controlled correction/failure class, not silent fallback.
- From `TinyAgent`: dependency planning and join semantics are interesting for multi-step vehicle plans, but MAformac current demo is single-hop mock control; keep this as spike-only.
- From `paper-qa`: robust JSON parsing is useful for future judge tools, not for safety-critical runtime control.

Stop condition:

- Do not add multi-step planner semantics to C3 during default-scope apply. It would expand scope beyond the accepted plan.

### C6 Bench

Relevant files:

- `Core/Bench/C6VehicleToolBench.swift:4` defines clarify tags.
- `Core/Bench/C6VehicleToolBench.swift:12` defines failure classes.
- `Core/Bench/C6VehicleToolBench.swift:25` defines buckets.
- `Core/Bench/C6VehicleToolBench.swift:98` defines source refs.
- `Core/Bench/C6VehicleToolBench.swift:158` defines bench case schema.
- `Core/Bench/C6VehicleToolBench.swift:248` defines dataset validation summary.
- `Core/Bench/C6VehicleToolBench.swift:257` requires negative ratio and must-pass checks.
- `Tools/C6BenchCLI/main.swift:82` requires LoRA adapter digest when model results carry LoRA identifiers.

Absorption candidates:

- From `TinyAgent`: add future failure classes or tags for tool-retrieval miss, parser tool-name miss, and dependency ordering miss.
- From `Internalizing Tool Knowledge`: add future C6 paired eval: full catalog prompt vs description-free/internalized prompt.
- From `Learning Rate Matters`: C6 final acceptance should compare adapter candidates after LR sweep, not one arbitrary run.

Stop condition:

- No `contracts/c6-bench-cases.jsonl` rewrite from this research tool unless a `rebuild-c6` OpenSpec change explicitly authorizes it.

## OpenSpec Insertion Options

### Option A: `research-paper-to-skill-gate`

Purpose: formalize this tool as a research artifact pipeline.

Candidate deltas:

- Add requirement: every external paper adoption proposal must include a gate packet.
- Add requirement: official repo code mapping is mandatory when a repo exists.
- Add requirement: proof class must separate paper evidence, code evidence, local static teardown, and executed validation.

Best timing: after default-scope apply closes, because this change is procedural and should not distract the current route.

### Option B: `retrain-c5`

Purpose: absorb LoRA and tool-knowledge papers into training method/data contracts.

Candidate deltas:

- Require LR sweep or justified LR range before candidate quality claims.
- Add data composition categories: tool knowledge, plan mapping, execution traces, no-call/refusal, state-aware cases.
- Add gate comparing full-schema prompt, retrieved-schema prompt, and internalized/no-schema prompt.

Hard boundary: this is not current authorization to train.

### Option C: `rebuild-c6`

Purpose: absorb tool-use eval/judge papers into C6 bench.

Candidate deltas:

- Add tool-retrieval and prompt-compression variants.
- Add description-free/internalized prompt eval branch.
- Add failure classes for schema absence, tool-selection miss, argument miss, dependency/order miss, and state/readback miss.

Hard boundary: no bench JSONL rewrite under current research-only work.

### Option D: `tool-surface-retrieval-spike`

Purpose: evaluate TinyAgent-style ToolRAG on 562 D-domain tools without changing model runtime.

Candidate deltas:

- Offline index of D-domain tool signatures and few-shot examples.
- Query-to-tool subset retrieval metric before model inference.
- C6 replay harness that measures whether retrieved subset contains gold tool and excludes dangerous distractors.

Hard boundary: spike-only until proven by local metrics and OpenSpec acceptance.

## Research Routing Rule

If a paper changes runtime behavior, route to OpenSpec first.

If a paper changes training method/data, route to `retrain-c5`.

If a paper changes evaluation, route to `rebuild-c6`.

If a paper only improves the research workflow, keep it in `Tools/paper-to-skill-gate`.

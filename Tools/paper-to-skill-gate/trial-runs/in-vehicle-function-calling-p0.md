# P0 Gate: Optimizing Small Language Models for In-Vehicle Function-Calling

Generated: 2026-06-24T08:36:17Z

## Gate Verdict

Status: `retrain_c5_input`

Proof class: `web_verified`, `local_static_teardown`, `not_executed`, `schema_validated`

This paper is P0 because it is the only currently verified paper in this pack that is explicitly about in-vehicle SLM function calling. It is not a direct implementation source for MAformac: no official repo was found in this pass, and the method leans on Phi-3 pruning/healing/quantization rather than MAformac's Qwen3 + LoRA baseline. The absorption target is therefore a C5/C6 planning gate, not training permission.

## Source Manifest

| Source | Evidence |
|---|---|
| arXiv `2501.02342` | `https://arxiv.org/abs/2501.02342` |
| arXiv HTML | `https://arxiv.org/html/2501.02342v1` |
| Author page / publication listing | `https://farris.github.io/` |
| Official repo | No official implementation repo verified in this pass. |

## What It Contributes

- Treat in-vehicle function calling as an edge deployment problem, not only a tool-calling accuracy problem.
- Separates domain-specific function-call fine-tuning from compression/deployment choices.
- Uses gRPC-style vehicle functions and specialized output tokens in the paper narrative; MAformac should translate this to its existing D-domain tool surface, not import the paper's interface.
- Latency and memory claims are useful as external pressure, but not directly comparable until MAformac runs its own Qwen3/MLX target.

## Ambiguity Audit

| Item | Classification | Notes |
|---|---|---|
| Vehicle domain relevance | `SPECIFIED` | Paper is explicitly in-vehicle function calling. |
| MAformac model parity | `UNSPECIFIED` | Paper uses Phi-family assumptions; MAformac is Qwen3-1.7B + LoRA. |
| Dataset schema | `PARTIALLY_SPECIFIED` | Paper describes in-vehicle function-call dataset; no official repo/data path verified. |
| Runtime target | `PARTIALLY_SPECIFIED` | Edge runtime is discussed; MAformac must re-measure on its own macOS/iOS path. |
| Safety/readback | `UNSPECIFIED` | Does not replace MAformac's code-level safety and mock readback contract. |

## MAformac Absorption

| Path | Lane | Recommendation |
|---|---|---|
| `Core/Training/C5LoRATraining.swift:71` | `retrain_c5` | Use as external justification for keeping the D-domain vehicle tool surface explicit in training data. |
| `Core/Contracts/ToolContractCompiler.swift:62` | `tool_surface` | Compare paper's vehicle function surface against MAformac's concrete D-domain rendered tools. |
| `Core/Bench/C6VehicleToolBench.swift:25` | `rebuild_c6` | Add future cases that distinguish in-vehicle function-call success from generic assistant phrasing. |
| `Core/Execution/C3ExecutionPipeline.swift:79` | `runtime_execution` | Keep execution safety/readback as MAformac-local truth; paper does not authorize bypassing guards. |

## Remediation Plan Candidate

1. Convert paper taxonomy into a C5 data review checklist: function surface, missing argument handling, no-call behavior, latency pressure, edge memory pressure.
2. Use the paper only to add review questions for C6: does a case require vehicle state change, no-call, clarification, or refusal?
3. Do not adopt Phi-3 pruning/healing unless a separate OpenSpec change explicitly scopes compression experiments.

## Stop Conditions

- Stop before training: no C5 run is authorized.
- Stop before C6 rewrite: this only proposes future case classes.
- Stop before runtime claims: paper latency does not transfer to MAformac.
- Stop if a later official repo is found: rerun the official-repo branch before citing implementation details.

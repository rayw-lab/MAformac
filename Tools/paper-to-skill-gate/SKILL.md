---
name: paper-to-skill-gate
description: Convert a paper into a MAformac absorption gate packet with paper evidence, optional official-repo teardown, algorithm traits, code insertion points, OpenSpec candidate deltas, and explicit no-training/no-C6 claim boundaries.
---

# paper-to-skill-gate

Use this skill when a paper might influence MAformac training, tool-use planning, C6 evaluation, or external tooling. The output is a gate packet, not implementation permission.

## Hard Boundaries

- Do not train LoRA.
- Do not run C6 golden/model-quality acceptance.
- Do not copy upstream code into MAformac runtime.
- Do not promote paper claims into product claims.
- Do not infer official-repo truth when no official repo is found.
- Do not touch raw customer material, private keys, PII, or source-controlled training data.
- For outputs generated at or after `2026-06-24T08:49:50Z`, write every narrative output in Chinese. Keep paper titles, arXiv IDs, URLs, repo names, file paths, enum values, and code tokens unchanged when needed. The 8 earlier trial outputs are legacy-exempt.

## Required Inputs

- Paper title or URL.
- MAformac target lane: `docs_only`, `retrain_c5`, `rebuild_c6`, `tool_surface`, `runtime_execution`, or `openspec_candidate`.
- Optional official GitHub repo URL.

## Pipeline

1. Resolve identity.
   - Record title, authors, venue/date, arXiv/DOI, PDF/HTML URL, and source confidence.
   - If the paper is time-sensitive or recently revised, live-verify the current version.

2. Parse and source bundle.
   - Prefer MinerU for PDF/complex layout extraction.
   - Use Docling MCP as conversion fallback or MCP-compatible document-key path.
   - Use DeepPaperNote-style source manifest and raw-section authority.
   - Preserve pages, sections, tables, formulas, appendix, and figure/table decision notes.

3. Retrieval and evidence QA.
   - Use MinerU Document Explorer or paper-qa style citation-grounded retrieval.
   - Every claim that changes MAformac planning needs a source pointer.
   - Mark unsupported claims as `UNSUPPORTED`, not as "obvious".

4. Algorithm and implementation audit.
   - Use paper2code's ambiguity categories: `SPECIFIED`, `PARTIALLY_SPECIFIED`, `UNSPECIFIED`.
   - Audit architecture, training, data, evaluation, metrics, deployment, hardware, and failure modes.
   - If adopting a paper idea into MAformac, list the exact evidence and the missing details.

5. Official-repo branch.
   - If an official repo exists, clone it under `Tools/paper-to-skill-gate/paper-repos/`.
   - Map paper claims to repo files and line ranges.
   - Classify each implementation fact as `PAPER_ONLY`, `CODE_CONFIRMED`, `CODE_CONFLICT`, or `UNSPECIFIED`.
   - Do not copy code. Extract patterns, contracts, tests, and failure modes.
   - If no official repo exists, record `repo_status=no_official_repo_found` and keep the result paper-only.

6. MAformac insertion map.
   - C5 data/training: `Core/Training/C5LoRATraining.swift`, `Tools/C5TrainingCLI/main.swift`, `Tools/C5TrainingCLI/c5_mlx_train_loop.py`.
   - Tool surface: `Core/Contracts/ToolContractCompiler.swift`, `generated/D_domain.tools.demo.json`, `generated/d_domain_ir_map.json`.
   - C2/C3 execution: `Core/Execution/ScopeResolution.swift`, `Core/Execution/C3ExecutionPipeline.swift`.
   - C6 bench: `Core/Bench/C6VehicleToolBench.swift`, `Tools/C6BenchCLI/main.swift`, `contracts/c6-bench-cases.jsonl`.
   - OpenSpec: add candidate deltas only after the current route permits them.

7. Gate verdict.
   - Choose one status from the README vocabulary.
   - Record proof class: `web_verified`, `local_static_teardown`, `schema_validated`, `not_executed`, or `blocked`.
   - Separate paper evidence, repo evidence, MAformac inference, and residual risk.
   - Enforce the Chinese output gate for all narrative fields and human-facing deliverables after the cutover.

8. Deliverables.
   - Human report: `trial-runs/<paper-slug>.md`.
   - Machine packet: `trial-runs/<paper-slug>.gate.json`.
   - Optional code map: embedded in report or `code-map/<paper-slug>.md`.
   - Optional OpenSpec candidate: embedded as non-authoritative proposal text.

## Completion Bar

The skill is complete only when:

- The paper identity is live-verified or explicitly marked stale/unverified.
- The official-repo status is recorded.
- At least three MAformac insertion points are named when the paper is relevant.
- Every adoption recommendation has an evidence source and a stop condition.
- `scripts/validate_gate_packet.py` passes for the `.gate.json` packet.
- For post-cutover packets, the validator's Chinese output gate passes.

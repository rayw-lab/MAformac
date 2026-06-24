# Reference Repos Ledger

Checked on: 2026-06-24

Filter used by this research pass: GitHub repos related to paper extraction, paper learning, paper internalization, or agent skills; `stars > 300`; `pushedAt >= 2026-03-24`.

All six repos below are cloned locally under `Tools/paper-to-skill-gate/reference-repos/` and ignored by git.

## Ranking For MAformac

This ranking is not raw stars. It is ordered by direct usefulness to MAformac's paper-to-skill gate and future C5/C6 planning.

| Rank | Repo | Stars | pushedAt | Local HEAD | Why it ranks here |
|---:|---|---:|---|---|---|
| 1 | `PrathamLearnsToCode/paper2code` | 1425 | 2026-04-03 | `fcffce7` | Strongest anti-hallucination protocol for turning papers into implementation constraints. |
| 2 | `917Dhj/DeepPaperNote` | 399 | 2026-06-10 | `3d3f58b` | Best evidence-first single-paper workflow and grounding lint discipline. |
| 3 | `Future-House/paper-qa` | 8754 | 2026-06-11 | `d7675d7` | Best citation-grounded scientific Q&A and robust LLM-output parsing. |
| 4 | `opendatalab/MinerU` | 68521 | 2026-06-22 | `3e60291` | Best parser substrate for PDFs, tables, formulas, scanned docs, and local/offline workflows. |
| 5 | `opendatalab/MinerU-Document-Explorer` | 589 | 2026-04-26 | `a7e9c6c` | Best persistent MCP deep-read/search/ingest pattern for multi-paper corpora. |
| 6 | `docling-project/docling-mcp` | 664 | 2026-06-15 | `43b3638` | Useful MCP conversion/cache wrapper and remote/local fallback branch. |

## Repo Teardown

### 1. paper2code

Role in fused pipeline: ambiguity audit and implementation discipline.

Code anchors:

- `reference-repos/paper2code/skills/paper2code/SKILL.md:34` starts staged paper acquisition and parsing.
- `reference-repos/paper2code/skills/paper2code/SKILL.md:54` makes ambiguity audit mandatory before code.
- `reference-repos/paper2code/skills/paper2code/SKILL.md:61` routes into code generation only after audit.
- `reference-repos/paper2code/skills/paper2code/pipeline/03_ambiguity_audit.md:28` defines the full checklist.
- `reference-repos/paper2code/skills/paper2code/pipeline/03_ambiguity_audit.md:128` uses official code to resolve ambiguity.
- `reference-repos/paper2code/skills/paper2code/guardrails/hallucination_prevention.md:11` defines the bright-line unspecified rule.
- `reference-repos/paper2code/skills/paper2code/pipeline/04_code_generation.md:47` requires citation anchoring for code.
- `reference-repos/paper2code/skills/paper2code/scripts/extract_structure.py:21` extracts sections.
- `reference-repos/paper2code/skills/paper2code/scripts/extract_structure.py:79` extracts algorithm boxes.
- `reference-repos/paper2code/skills/paper2code/scripts/extract_structure.py:107` extracts equations.
- `reference-repos/paper2code/skills/paper2code/scripts/extract_structure.py:158` extracts tables.

Algorithm traits:

- Strict stage order.
- Explicit `SPECIFIED / PARTIALLY_SPECIFIED / UNSPECIFIED` taxonomy.
- Official repo is useful but not absolute truth.
- Every implementation choice must be cited or flagged.

MAformac absorption:

- Use as the default audit format before any C5/C6 research-driven code change.
- Use its official-repo branch as the model for TinyAgent and future LoRA papers with code.

### 2. DeepPaperNote

Role in fused pipeline: evidence bundle, note plan, grounding gate.

Code anchors:

- `reference-repos/DeepPaperNote/SKILL.md:44` defines the full workflow.
- `reference-repos/DeepPaperNote/SKILL.md:91` requires evidence-first drafting from raw sections and synthesis bundle.
- `reference-repos/DeepPaperNote/SKILL.md:96` requires an explicit note plan.
- `reference-repos/DeepPaperNote/SKILL.md:97` requires grounding lint.
- `reference-repos/DeepPaperNote/SKILL.md:181` says final understanding belongs to the model, not scripts alone.
- `reference-repos/DeepPaperNote/SKILL.md:211` lists bundled scripts to reuse.

Algorithm traits:

- Source manifest and raw sections are canonical.
- No shallow abstract rewrite.
- Model-first synthesis, but with deterministic evidence structure.
- Fail closed when source quality is insufficient.

MAformac absorption:

- Use `note_plan` fields as the paper gate's human-readable reasoning skeleton.
- Borrow fail-closed language for weak PDF/source quality.

### 3. paper-qa

Role in fused pipeline: citation-grounded scientific Q&A and robust context parsing.

Code anchors:

- `reference-repos/paper-qa/README.md:105` describes PaperQA2 as agentic RAG for scientific papers.
- `reference-repos/paper-qa/README.md:110` requires grounded responses with in-text citations.
- `reference-repos/paper-qa/README.md:111` adds metadata-aware embeddings, reranking, and contextual summarization.
- `reference-repos/paper-qa/README.md:184` lists agentic workflows for paper search, evidence gathering, and answer generation.
- `reference-repos/paper-qa/README.md:201` notes newer support for tables, figures, non-English languages, and math equations.
- `reference-repos/paper-qa/src/paperqa/core.py:19` extracts JSON from noisy LLM output.
- `reference-repos/paper-qa/src/paperqa/core.py:136` distinguishes retryable bad JSON from non-retryable failures.
- `reference-repos/paper-qa/src/paperqa/core.py:178` maps source text into scored context objects.

Algorithm traits:

- RAG output is citation-bearing by default.
- JSON parsing is defensive against model output drift.
- Context generation can carry tables/media into summarization.

MAformac absorption:

- Use as the cross-check layer when a paper claim is ambiguous or disputed.
- Borrow robust JSON repair ideas for future judge/receipt parsing, not runtime vehicle control.

### 4. MinerU

Role in fused pipeline: document parsing substrate.

Code anchors:

- `reference-repos/MinerU/README.md:53` lists core parsing capabilities.
- `reference-repos/MinerU/README.md:55` supports DOCX/PPTX/XLSX parsing.
- `reference-repos/MinerU/README.md:56` converts formulas to LaTeX and tables to HTML.
- `reference-repos/MinerU/README.md:57` handles scanned docs, handwriting, multi-column layout, and cross-page tables.
- `reference-repos/MinerU/README.md:58` outputs human reading order.
- `reference-repos/MinerU/README.md:70` documents private/offline deployment.
- `reference-repos/MinerU/README.md:83` shows current 3.4 release notes.
- `reference-repos/MinerU/README.md:170` lists key features relevant to paper parsing.

Algorithm traits:

- Parser-first, layout-aware extraction.
- Useful for formulas, tables, multi-column papers, and scanned PDFs.
- Offers local/offline deployment path, matching MAformac's offline bias.

MAformac absorption:

- Make it the preferred parser option for future paper packets when source PDFs are complex.
- Keep it as external tooling only; no Python dependency enters iOS/macOS runtime.

### 5. MinerU Document Explorer

Role in fused pipeline: persistent agent-native retrieval/deep-read/ingest loop.

Code anchors:

- `reference-repos/MinerU-Document-Explorer/README.md:31` defines Retrieve, Deep Read, and Ingest suites.
- `reference-repos/MinerU-Document-Explorer/README.md:35` includes BM25, vector, hybrid, reranking, and query expansion.
- `reference-repos/MinerU-Document-Explorer/README.md:36` supports document TOC, section read, grep, and element extraction.
- `reference-repos/MinerU-Document-Explorer/README.md:48` describes a demo that reads arXiv papers and writes a survey.
- `reference-repos/MinerU-Document-Explorer/README.md:73` exposes 15 MCP tools.
- `reference-repos/MinerU-Document-Explorer/README.md:77` explains why persistent MCP is preferred over CLI reloads.
- `reference-repos/MinerU-Document-Explorer/README.md:173` points to an agent skill.

Algorithm traits:

- Persistent MCP process avoids repeated model reload cost.
- Combines document search and deep reading.
- Good for multi-paper survey and evolving knowledge bases.

MAformac absorption:

- Use when L01-L18 style ledgers grow into a larger paper corpus.
- Use as external research index, not app runtime.

### 6. docling-mcp

Role in fused pipeline: MCP conversion/cache fallback.

Code anchors:

- `reference-repos/docling-mcp/README.md:22` describes the service.
- `reference-repos/docling-mcp/README.md:24` converts PDFs into structured formats and caches results.
- `reference-repos/docling-mcp/README.md:28` introduces hybrid remote/local architecture.
- `reference-repos/docling-mcp/README.md:31` notes lightweight remote mode.
- `reference-repos/docling-mcp/README.md:33` documents local mode.
- `reference-repos/docling-mcp/README.md:34` documents remote-to-local fallback.
- `reference-repos/docling-mcp/README.md:86` lists conversion, generation, cache, local/URL sources, memory management, and RAG features.
- `reference-repos/docling-mcp/README.md:100` shows `uvx` server launch.

Algorithm traits:

- Agentic conversion service via MCP.
- Remote/local/hybrid mode decision.
- Cache-first document conversion.

MAformac absorption:

- Use as a fallback parser branch when MinerU is too heavy or MCP integration is the priority.
- Useful for future "paper packet as service" automation.

## Official Paper Repos Cloned During Trial

These do not all satisfy the `stars > 300 + pushedAt last 3 months` reference-repo filter; they are cloned because the trial papers reference them.

| Paper | Repo | Stars | pushedAt | Local HEAD | Trial status |
|---|---|---:|---|---|---|
| TinyAgent | `SqueezeAILab/TinyAgent` | 486 | 2024-09-04 | `cc45c0e` | Official repo exists, high-star but not recently code-pushed. |
| Learning Rate Matters | `yuang-lee/lr-matters-lora` | 7 | 2026-06-24 | `a81dca9` | Official repo exists, recent code push but low-star. |
| Internalizing Tool Knowledge via QLoRA | no official repo found | n/a | n/a | n/a | Paper-only gate; no repo branch evidence. |

## Cross-Repo Fusion Contract

The pipeline uses each repo for one thing it is good at:

- MinerU/docling-mcp: get clean document structure.
- DeepPaperNote: convert structure into an evidence-first paper note plan.
- paper-qa/MinerU Document Explorer: query and cross-check evidence at scale.
- paper2code: prevent implementation hallucination and force official-code mapping.
- MAformac-specific layer: route the result into C5, C6, D-domain tools, C2/C3 execution, or OpenSpec with proof-class boundaries.

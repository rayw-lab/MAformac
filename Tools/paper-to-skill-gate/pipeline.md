# Pipeline

This pipeline fuses the six cloned repos into one MAformac-specific decision gate.

## Stage 0: Intake And Scope

Inputs:

- Paper source: title, arXiv, DOI, PDF, ACL Anthology, OpenReview, or local file.
- Optional official repo URL.
- Target lane: `docs_only`, `retrain_c5`, `rebuild_c6`, `tool_surface`, `runtime_execution`, or `openspec_candidate`.

Outputs:

- `paper_identity`
- `claim_boundaries`
- `allowed_actions`
- `no_touch_paths`

MAformac defaults:

- Current default-scope route remains active.
- No training, C6 rebuild, golden-run, voice, UIUE merge, or V-PASS claim.
- Research output may become future OpenSpec input only.
- Chinese output gate applies to all outputs generated at or after `2026-06-24T08:49:50Z`; legacy 8 trial outputs are exempt.

## Stage 1: Document Parsing

Primary influence: MinerU and docling-mcp.

Process:

1. Prefer structured extraction that preserves reading order, formulas, tables, figures, and appendix.
2. Record extraction engine, version when known, source URL/path, and extraction confidence.
3. If the PDF is complex, scanned, or formula-heavy, prefer MinerU's higher-accuracy parsing path.
4. If the agent workflow needs MCP conversion or a lightweight local/remote fallback, use docling-mcp's conversion/cache model.

Gate questions:

- Are formulas and tables required for the algorithm?
- Was the appendix parsed?
- Are page/section anchors preserved enough for later audit?

## Stage 2: Evidence Bundle And Deep Note

Primary influence: DeepPaperNote.

Process:

1. Build a source manifest.
2. Build raw sections and a synthesis bundle.
3. Write a short `note_plan` before any long prose.
4. Run a grounding-style review: every substantive claim must point to a section, page, or repo line.
5. Keep "what the paper proves" separate from "what MAformac may do later".

Gate questions:

- Is this a method, benchmark, system, deployment, or training recipe paper?
- Which claims are central enough to affect MAformac?
- Which claims are negative or limiting?

## Stage 3: Retrieval And Cross-Document QA

Primary influence: paper-qa and MinerU Document Explorer.

Process:

1. Use citation-grounded Q&A for contested facts.
2. If handling a batch of papers, index them with persistent document search rather than re-reading everything into context.
3. Use retrieved evidence only as a pointer, not as final authority.

Gate questions:

- Does the answer cite exact text or only summarize?
- Are there conflicting sources?
- Is there a known related benchmark or official project page?

## Stage 4: Ambiguity Audit

Primary influence: paper2code.

Classify every implementation-relevant item:

- `SPECIFIED`: explicit in paper text, appendix, equation, table, footnote, or official repo.
- `PARTIALLY_SPECIFIED`: paper gestures at it but leaves detail ambiguous.
- `UNSPECIFIED`: missing. Do not hide this behind "standard".

Audit categories:

- Architecture and model surface.
- Training hyperparameters and data split.
- Prompt/schema/tool format.
- Evaluation metrics and judge protocol.
- Hardware, quantization, latency, memory, and deployment path.
- Failure modes and negative results.

## Stage 5: Official Repo Branch

Trigger when a paper has a corresponding GitHub repo.

Local clone:

```bash
git clone --depth 1 <repo-url> Tools/paper-to-skill-gate/paper-repos/<slug>
```

Teardown checklist:

- `README`, install path, license, pushed date, stars.
- Training scripts, data scripts, eval scripts, config files, model wrappers.
- Tool schema, output parser, planner, function-call format, or adapter surface.
- Test/benchmark scripts and skip conditions.
- Any divergence between paper and code.

Classification:

- `CODE_CONFIRMED`: paper claim is implemented in code and line-anchored.
- `PAPER_ONLY`: stated in paper, no matching code found.
- `CODE_ONLY`: useful behavior in repo, not claimed in paper.
- `CODE_CONFLICT`: code contradicts paper.
- `UNSPECIFIED`: neither paper nor code resolves the detail.

For MAformac, this branch must produce:

- `code_mapping`
- `absorption_options`
- `remediation_plan`
- `OpenSpec candidate deltas`
- `stop_conditions`

## Stage 6: MAformac Absorption Router

Map to the narrowest lane:

| Lane | Candidate output | Hard stop |
|---|---|---|
| `docs_only` | Reference ledger, research note, handoff text | Do not touch code paths. |
| `tool_surface` | D-domain schema/tool retrieval proposal | No generated tools without OpenSpec acceptance. |
| `retrain_c5` | Data, masking, LR, adapter, or tool-knowledge proposal | No actual training. |
| `rebuild_c6` | Evaluation case design, failure classes, judge rubric | No C6 JSONL rewrite unless authorized. |
| `runtime_execution` | Parser/readback/safety design candidate | No runtime edits without accepted change. |
| `openspec_candidate` | Proposal text and requirement deltas | No apply until accepted. |

## Stage 7: Gate Packet

Every paper ends with a `.gate.json` packet and a human `.md` report.

Language gate:

- Human-facing narrative must be Chinese.
- Machine packet narrative fields must be Chinese: `reference_repo_influences`, `algorithm_traits`, insertion `recommendation`, `openspec_candidates`, `gate.rationale`, `gate.stop_conditions`, and `residual_risks`.
- Preserve paper titles, URLs, arXiv IDs, repo names, file paths, enum values, and code tokens in original form when needed.
- The 8 pre-cutover trial packets remain legacy-exempt and must not be rewritten just to satisfy this gate.

Required packet sections:

- `paper`
- `sources`
- `official_repo`
- `reference_repo_influences`
- `algorithm_traits`
- `maformac_insertion_points`
- `openspec_candidates`
- `deliverables`
- `gate`
- `residual_risks`

## Stage 8: Audit

After the pipeline code and trial packets are written, arrange a Codex subagent audit with this scope:

- Verify no training/C6/runtime claim escalation.
- Check that the six reference repos are actually fused into the pipeline.
- Check that trial packets have source-backed gate verdicts.
- Check that MAformac insertion points cite real files.
- Check malformed packets fail validation.

Subagent output must include `status`, evidence table, confidence, touched paths, and residual risk.

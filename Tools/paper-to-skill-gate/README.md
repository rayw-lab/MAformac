# paper-to-skill-gate

`paper-to-skill-gate` is a local-only external research tool folder for MAformac. It turns a paper into a gated absorption packet: paper evidence, optional official-repo code mapping, MAformac insertion points, OpenSpec candidate deltas, and explicit stop conditions.

This folder is not part of the macOS/iOS runtime. It is not a training authorization, not a C6 rebuild authorization, and not a D1-D37 rewrite. Its output is proposal input for later `retrain-c5`, `rebuild-c6`, or a dedicated OpenSpec change.

## Inventory

| Path | Role |
|---|---|
| `SKILL.md` | Paste-ready agent skill contract. |
| `pipeline.md` | Fused pipeline from all six reference repos. |
| `reference-repos-ledger.md` | Local clone ledger, ranking, code anchors, and algorithm traits. |
| `maformac-integration-map.md` | MAformac code and OpenSpec insertion map. |
| `schemas/gate-packet.schema.json` | Lightweight schema for machine-checkable paper gate packets. |
| `scripts/validate_gate_packet.py` | Stdlib validator for `trial-runs/*.gate.json`. |
| `templates/gate-report.md` | Human report template for future papers. |
| `trial-runs/` | Trial packets for the three requested papers. |
| `reference-repos/` | Ignored local clones of the six surveyed repos. |
| `paper-repos/` | Ignored local clones of official paper repos when present. |

## Reference Repos

Live GitHub metadata was checked on 2026-06-24. All six reference repos meet the user's filter: `stars > 300` and `pushedAt >= 2026-03-24`.

1. `opendatalab/MinerU` — document parsing substrate.
2. `Future-House/paper-qa` — citation-grounded scientific RAG and answer verification.
3. `PrathamLearnsToCode/paper2code` — ambiguity audit and citation-anchored implementation discipline.
4. `docling-project/docling-mcp` — agentic document conversion via MCP.
5. `opendatalab/MinerU-Document-Explorer` — persistent MCP deep-read/search/ingest loop.
6. `917Dhj/DeepPaperNote` — evidence-first deep paper note workflow with grounding lint.

See `reference-repos-ledger.md` for HEADs, stars, pushed dates, and code anchors.

## Gate Status Vocabulary

Use these outcomes in every packet:

- `adopt_now`: can influence docs, scripts, or test planning without changing runtime behavior.
- `adopt_after_default_scope`: useful, but waits until the current default-scope apply closes.
- `retrain_c5_input`: eligible only as input to a future C5 proposal or training plan.
- `rebuild_c6_input`: eligible only as input to a future C6 proposal or bench rebuild.
- `spike_only`: useful research, but needs a contained spike before adoption.
- `defer`: insufficient fit, insufficient evidence, or blocked by current project route.
- `reject`: contradicted by MAformac constraints or not worth carrying.

## Chinese Output Gate

Cutover: `2026-06-24T08:49:50Z`.

All paper-to-skill-gate outputs generated at or after the cutover must be written in Chinese. Paper titles, arXiv IDs, URLs, repo names, file paths, enum values, and code tokens may remain in their original form, but narrative fields and human-facing reports must be Chinese.

The 8 existing trial packets generated before this cutover are legacy outputs and are exempt from this gate.

## Quick Validation

```bash
python3 Tools/paper-to-skill-gate/scripts/validate_gate_packet.py \
  Tools/paper-to-skill-gate/trial-runs/*.gate.json
```

The validator checks required fields, evidence links, MAformac insertion points, and trial-run status. It does not validate research truth by itself; it only fails closed on malformed gate packets.

# P0 Five-Pack Index

Generated: 2026-06-24T08:36:17Z

## Scope

This index records the five P0 paper-to-skill-gate groups opened on 2026-06-24.

Hard boundary: this is research and absorption routing only. It does not authorize LoRA training, C6 rebuild, runtime edits, golden-run, UIUE, voice work, or V-PASS claims.

## Deliverables

| Group | Human report | Gate packet | Status |
|---|---|---|---|
| In-vehicle function calling | `in-vehicle-function-calling-p0.md` | `in-vehicle-function-calling-p0.gate.json` | `retrain_c5_input` |
| When2Call | `when2call-tool-decision-p0.md` | `when2call-tool-decision-p0.gate.json` | `rebuild_c6_input` |
| ABC rigorous benchmarks | `abc-rigorous-agentic-benchmarks-p0.md` | `abc-rigorous-agentic-benchmarks-p0.gate.json` | `rebuild_c6_input` |
| Function-calling data generation pack | `function-calling-data-generation-pack-p0.md` | `function-calling-data-generation-pack-p0.gate.json` | `retrain_c5_input` |
| Leakage and decontamination pack | `leakage-decontamination-pack-p0.md` | `leakage-decontamination-pack-p0.gate.json` | `retrain_c5_input` |

## Priority Order

1. `in-vehicle-function-calling-p0`: strongest domain fit; paper-only until official repo appears.
2. `when2call-tool-decision-p0`: highest immediate C6 taxonomy value.
3. `abc-rigorous-agentic-benchmarks-p0`: highest fake-green prevention value.
4. `function-calling-data-generation-pack-p0`: highest C5 generation-method value, but must stay gated.
5. `leakage-decontamination-pack-p0`: highest train/eval split integrity value.

## Audit Target

The post-run subagent audit should verify:

- All five `.gate.json` packets validate.
- Reports do not claim training, C6 rebuild, runtime acceptance, mobile proof, or V-PASS.
- Local repo code anchors exist for cloned official repos.
- Paper-only groups are not falsely described as code-confirmed.
- MAformac insertion points cite existing files and stay proposal-only.

## Audit Round 1 Receipt

Status: `PASS_WITH_FINDINGS`, absorbed.

- Medium finding accepted: JSON validator is necessary but not sufficient; markdown claim anchors still require human or separate anchor-scan audit.
- Low finding fixed: multi-paper packs now mark root `official_repo` as `not_applicable` / `UNSPECIFIED`, so downstream automation cannot read a single cloned repo as code-confirming the entire pack.
- Residual: full PDF page/section locators remain a future OCR/deep-extraction pass, not part of this five-pack gate run.

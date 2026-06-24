# P0 Gate: ABC / Rigorous Agentic Benchmarks

Generated: 2026-06-24T08:36:17Z

## Gate Verdict

Status: `rebuild_c6_input`

Proof class: `web_verified`, `local_static_teardown`, `not_executed`, `schema_validated`

ABC is P0 because it is about benchmark validity rather than model architecture. For MAformac, the key value is preventing fake green: empty success, aggregate pass masking layer failure, reward bugs, and unclear task outcome validity.

## Source Manifest

| Source | Evidence |
|---|---|
| arXiv `2507.02825` | `https://arxiv.org/abs/2507.02825` |
| PDF | `https://arxiv.org/pdf/2507.02825` |
| Project page | `https://uiuc-kang-lab.github.io/agentic-benchmarks/` |
| Official repo | No official implementation repo verified in this pass. |

## What It Contributes

- Treats benchmark design as a source of false performance, not neutral infrastructure.
- Explicitly calls out outcome/reward design issues and examples where empty or insufficient behavior can be scored as success.
- Supports MAformac's existing discipline: C6 layer gates must not be aggregated into a single green number.

## Ambiguity Audit

| Item | Classification | Notes |
|---|---|---|
| Benchmark checklist concept | `SPECIFIED` | Paper/project page explicitly frames ABC as checklist guidance. |
| Empty-success concern | `SPECIFIED` | Verified via arXiv search snippet/PDF source; needs full section/page extraction in future OCR pass. |
| Direct MAformac implementation | `UNSPECIFIED` | No repo branch verified. |
| Harness metrics mapping | `PARTIALLY_SPECIFIED` | Must be translated to MAformac C6 buckets and failure classes. |

## MAformac Absorption

| Path | Lane | Recommendation |
|---|---|---|
| `Core/Bench/C6VehicleToolBench.swift:12` | `rebuild_c6` | Maintain explicit failure classes; add fake-green audit dimensions before any aggregate model-quality claim. |
| `Tools/C6BenchCLI/main.swift` | `rebuild_c6` | Future CLI output should separate parse/tool/no-call/readback/judge/infrastructure gates. |
| `contracts/c6-bench-cases.jsonl` | `rebuild_c6` | Cases should assert expected observable outcome, not just expected text shape. |
| `Core/Execution/C3ExecutionPipeline.swift:117` | `runtime_execution` | Readback must remain an execution proof, not a language-only success proxy. |

## Remediation Plan Candidate

1. Build a C6 fake-green checklist: empty output, no-op state delta, wrong tool but plausible text, missing readback, judge-only success, infrastructure skip.
2. Require future C6 reports to list per-layer pass/fail counts before any aggregate number.
3. Add `benchmark_design_risk` as an OpenSpec candidate note, not current implementation.

## Stop Conditions

- Do not mark C6 or demo ready from benchmark checklist alone.
- Do not use aggregate pass rate if any hard layer is red.
- Do not let judge text override state/readback truth.
- Do not rewrite C6 JSONL without an accepted OpenSpec change.

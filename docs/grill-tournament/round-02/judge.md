# Round 02 Judge

## Scope

Round 02 continued from the ledger after Round 01. It covered governance enforcement and SRD/CAS cascade: GOV3, GOV4, GOV5, GOV7, GOV8, GOV9, CAS1, CAS2, CAS3.

## Candidate Verdicts

| ID | Topic | Avg score | Verdict | Judge rationale |
|---|---|---:|---|---|
| R2-Q01 | GOV3 cross-section enforce | 23.0 | Keep, rewrite | Strong mechanical consistency question. Must state that cross-section gates catch drift, not source-level correctness. |
| R2-Q02 | GOV4 Pi long-task discipline | 17.75 | Keep only after rewrite | Brains correctly flagged that Pi forms are already partly adopted. Rewrite as enforcement-gap audit, not “should we adopt Pi?” |
| R2-Q03 | GOV5 Mastra contract shapes | 19.5 | Keep, rewrite | Not a framework adoption question. Keep as C4/C6/C3 schema-shape gap review with explicit non-adoption of Mastra runtime/agent loop. |
| R2-Q04 | GOV7 Pocock stage reset | 22.0 | Keep | High leverage because phase misclassification causes A2/G6-C/CAS抢跑. Needs per-mainline stage and forbidden-race list. |
| R2-Q05 | GOV8 OpenSpec change split | 23.25 | Keep | Distinct from Round 01 carrier question. This asks actual change granularity, dependency graph, observable behavior boundary, and archive criteria. |
| R2-Q06 | GOV9 ground-truth subagent policy | 23.0 | Keep, rewrite | This is the frame-breaking lesson from the D-domain flip. Needs cost/trigger boundary and “subagent evidence pack is not authority” guard. |
| R2-Q07 | CAS1 meta cascade inventory | 21.25 | Keep, split from R1-Q07 | Brains marked duplicate, but the judge separates it: R1-Q07 = stale-anchor grep debt; R2-Q07 = authority-file cascade inventory before edits. |
| R2-Q08 | CAS2 SRD FC泛化 rewrite | 23.75 | Keep | High-quality frame-correction question. It prevents SRD from retaining generic-frame wording after D-domain surface flip. |
| R2-Q09 | CAS3 L1/L2 route boundary | 24.5 | Keep | Strongest Round 02 item. It forces action-level route decisions from `fc_flags`, `value.type`, and demo latency/value constraints. |

## Final Round 02 Questions

9. **R2-Q01 Cross-section enforce**: Should `verify-cross-section` expand to C5 recovery and grill-decision docs? Define scanned document groups, drift anchors, SUPERSEDED marker rules, false-positive handling, and which claims still require source-level cite-verify because consistency does not prove correctness.
10. **R2-Q02 Pi enforcement gap**: Given `docs/project/collaboration-and-roles.md §4.5` already adopts Pi-style handoff/closure/gates, where has C5 recovery failed to enforce them physically? Output `mechanism / current_artifact / enforced_by / missing_gap / deferred_reason / no-runtime-boundary`.
11. **R2-Q03 Mastra contract-shape gap**: After C6 shifts to four-layer eval, which Mastra-like shapes are worth adopting only as contract forms: C4 `DemoFlow`, C6 `TrajectoryExpectation`, C3 trace spans? Output concrete file/field targets and explicit red lines: no Mastra runtime, no free agent loop.
12. **R2-Q04 Pocock stage reset**: After the D-domain flip, classify A2, B1, B2, C5 retrain, C6 four-layer eval, G6-C, and CAS/E2 cascade as S2/S3/S4/S5. For each, give evidence, exit condition, blocked-before rule, and forbidden-race item.
13. **R2-Q05 OpenSpec change split**: What is the minimum set of OpenSpec changes for A2 codegen, C5 retrain, C6 four-layer eval, B1 endpoint parser/whitelist, and B2 state-cells/tool-card map? For each: observable behavior boundary, preconditions, archive criteria, rollback/blocker, and why it must or must not merge with neighbors.
14. **R2-Q06 Ground-truth subagent policy**: Which decisions require a ground-truth subagent before being frozen? Define triggers such as model-visible surface changes, SSOT changes, eval gates, safety/PII boundaries, raw-derived numbers, or strong single-agent claims; output requirements must include cite-verify, discovery-gap review, raw redlines, and write-back locations in `CLAUDE.md`/collaboration docs.
15. **R2-Q07 CAS1 cascade inventory**: Before editing, produce a target inventory matrix for all files affected by the D-domain flip and first four grill batches: `source_decision / target_file / section / stale_claim / new_frame / action(change|supersede|no_change) / owner_change / verification_gate / superseded_marker`. Cover `CLAUDE`, SRD, baseline MASTER, integration-blueprint, roadmap, ADR, `CONTEXT.md`, and OpenSpec specs.
16. **R2-Q08 SRD FC泛化 rewrite**: How should SRD rewrite “L2 意图收缩 clarifyTag→FC 泛化” under D-domain surface? The answer must preserve three layers: `canonical_ir=device×action×value`, `model_visible_surface=D-domain named tools`, and `runtime_tier=10-family mock/unsupported/safety/refusal`.
17. **R2-Q09 L1/L2 boundary**: In the 10-family MVP, which actions/value types go rule fast path vs LoRA slow path? Produce an action-level routing table using §14 `fc_flags`, `value.type`, state dependency, safety/refusal needs, and 5-minute demo latency constraints; do not split only by device family.

## Merge And Dedupe Decisions

- **R2-Q07 not merged away** despite subagent concern. Judge correction: Round 01 R1-Q07 is narrowed to stale-anchor grep debt; R2-Q07 is CAS1 authority cascade inventory. Both survive because their physical outputs differ.
- **R2-Q02 rewritten** from “adopt Pi?” to “where is already-adopted Pi discipline not enforced?”
- **R2-Q03 rewritten** from “adopt Mastra?” to “which C4/C6/C3 contract fields need Mastra-like shape, while explicitly rejecting runtime adoption?”
- **R2-Q05 kept separate** from R1-Q03. R1-Q03 decides carrier/blocker; R2-Q05 decides actual change split.

## Remaining Gaps For Later Rounds

- CAS4-CAS8: runtime tier merge, 10-family landing/domain narrowing, D1-D37 supersede review, baseline MASTER, roadmap/ADR cascade.
- TRN1-TRN9 remain mostly open, especially recipe review, held-out split, generator/judge, mlx feasibility, and endpoint parity.
- B1/B2 runtime landing still needs direct questions.
- UIX group remains untouched.

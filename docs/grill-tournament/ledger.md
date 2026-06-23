# Grill Tournament Ledger

## Tournament Rules

- Source pool: `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` §15, especially GOV/CAS/TRN/UIX/AUD.
- Five rounds, nine candidates each.
- Four independent subagents review every round.
- Final list must keep exactly 41 effective grill questions after dedupe, merge, and trimming.
- Scoring dimensions: importance, verifiability, non-duplication, mainline decision leverage, risk revelation.

## Confirmed Grill Questions

| Canonical ID | Source | Status | Judge note |
|---|---|---|---|
| Q01 | R1-Q01 / AUD2,G2 | Confirmed | Tool count must be physically recalculated; `562=intent` (终拍权威，旧 534 已废), not tool count. |
| Q02 | R1-Q02 / AUD1 | Confirmed | `generated/` drift gate coverage is a hard A2 precondition. |
| Q03 | R1-Q03 / AUD3,GOV2 | Confirmed | Rewrite as OpenSpec carrier and dispatch-blocker rule. |
| Q04 | R1-Q04 / AUD4 | Confirmed | Demo/full codegen scopes need a shared-source artifact matrix. |
| Q05 | R1-Q05 / AUD5,TRN2 | Confirmed | Train/eval/runtime surface parity must be fail-closed. |
| Q06 | R1-Q06 + R1-Q09 / AUD5,GOV6,TRN3 | Confirmed merged | Mid-training C6 gates absorb process/superpowers gate concerns. |
| Q07 | R1-Q07 / AUD6 | Confirmed | Stale-anchor grep debt must adjudicate hits, not bulk replace. |
| Q08 | R1-Q08 / GOV1 | Confirmed | Archived specs impact must be judged by observable behavior. |
| Q09 | R2-Q01 / GOV3 | Confirmed | Cross-section gates should cover C5 recovery drift but must not be confused with source correctness. |
| Q10 | R2-Q02 / GOV4 | Confirmed rewritten | Already-adopted Pi discipline must be audited for physical enforcement gaps. |
| Q11 | R2-Q03 / GOV5 | Confirmed rewritten | Mastra value is contract shape only; runtime/agent-loop adoption is explicitly out. |
| Q12 | R2-Q04 / GOV7 | Confirmed | A2/G6-C/CAS need phase reset with exit conditions and forbidden-race items. |
| Q13 | R2-Q05 / GOV8 | Confirmed | Change split and dependency graph are distinct from the carrier question. |
| Q14 | R2-Q06 / GOV9 | Confirmed | Ground-truth subagent policy should be triggered only for frame-breaking/high-stakes decisions. |
| Q15 | R2-Q07 / CAS1 | Confirmed split | Authority-file cascade inventory is distinct from stale-anchor grep debt. |
| Q16 | R2-Q08 / CAS2 | Confirmed | SRD must preserve IR/surface/runtime tier separation. |
| Q17 | R2-Q09 / CAS3 | Confirmed | L1/L2 boundaries must be action-level and evidence-based, not family-level. |
| Q18 | R3-Q01 / CAS4 | Confirmed rewritten | Runtime outcome taxonomy must not flatten route/surface/execution layers. |
| Q19 | R3-Q02 / CAS5 | Confirmed rewritten | 10-family narrowing must be reflected in SRD, demo docs, and C6 unsupported cases. |
| Q20 | R3-Q03 / CAS6 | Confirmed | D1-D37 need an explicit status manifest after the D-domain flip. |
| Q21 | R3-Q04 / CAS7 | Confirmed rewritten | Baseline MASTER must preserve IR authority while adding derived surface-layer language. |
| Q22 | R3-Q05 / CAS8 | Confirmed | Progress SSOT must be singular before more dispatches. |
| Q23 | R3-Q06 / TRN1 | Confirmed rewritten | Recipe is frozen by default; only evidence can reopen it after surface/data causes are excluded. |
| Q24 | R3-Q07 / TRN4 | Confirmed | D-domain named tools require multi-axis held-out split beyond parent overlap. |
| Q25 | R3-Q08 / TRN5 | Confirmed rewritten | Refusal/IrrelAcc gates must split denominators and cannot hide behind aggregate pass rate. |
| Q26 | R3-Q09 / TRN6 | Confirmed rewritten | Generator/judge/oracle redlines must become data recipe fields and gates. |
| Q27 | R4-Q01 / TRN7 | Confirmed | Local mlx-lm feasibility needs resource estimates, preflight, and fallback triggers. |
| Q28 | R4-Q02 / TRN8 | Confirmed narrowed | Endpoint parity must be mlx-swift-specific and cannot assume GBNF. |
| Q29 | R4-Q03 / TRN9 | Confirmed rewritten | DoRA/complex reasoning are gated upgrades, not current recipe reopens. |
| Q30 | R4-Q04 / UIX1 | Confirmed rewritten | UIUE findings require source-pinned triage under 10-family scope. |
| Q31 | R4-Q05 / UIX2 | Confirmed | Mock cards must be backed by state-cells/tool-card mapping. |
| Q32 | R4-Q06 / UIX3 | Confirmed rewritten | Visual stance survives only as evidence-gated decision. |
| Q33 | R4-Q07 / UIX4 | Confirmed | Engineering hard preflight is a demo blocker, not UI polish. |
| Q34 | R4-Q08 / UIX5 | Confirmed | Onsite SOP is distinct from build/runtime preflight. |
| Q35 | R4-Q09 / UIX6 | Confirmed rewritten | Route/dialogue UI states must bind to trace and golden cases. |
| Q36 | R5-Q01 / UIX7 | Confirmed rewritten | Voice UI must be a trace-bound state machine, not decoration. |
| Q37 | R5-Q02 / UIX8 | Confirmed | Demo choreography must anchor to golden-run and C6 cases. |
| Q38 | R5-Q03 / UIX9 | Confirmed rewritten | Component adoption requires license/perf/offline/aesthetic/real-view gates. |
| Q39 | R5-Q06 / F1 | Confirmed | Safety remains code-gated; it must not become a model-visible executable tool. |
| Q40 | R5-Q07 / G6 | Confirmed rewritten | Scenario macros need schema/lint and cannot bypass mounted tools or state cells. |
| Q41 | R5-Q09 / final acceptance | Confirmed | Final acceptance ladder prevents train-health/model-quality/endpoint/demo/human PASS conflation. |

## Eliminated Or Merged

| Candidate | Decision | Reason |
|---|---|---|
| R1-Q09 | Merged into Q06 | Standalone form was process-label heavy and overlapped with training midpoint gates. |
| R2-Q02 original wording | Rewritten | “Adopt Pi?” repeated existing project discipline; retained as enforcement-gap audit. |
| R2-Q03 original wording | Rewritten | “Adopt Mastra?” risked framework drift; retained as contract-shape gap review. |
| R3-Q06 original wording | Rewritten | “Review recipe” risked reopening locked hyperparameters; retained as freeze/reopen evidence rule. |
| R4-Q02 broad wording | Narrowed | Broad train/eval/runtime parity already exists; retained as endpoint-specific parity. |
| R4-Q03 broad wording | Rewritten | Upgrade discussion retained only as forbidden-until/trigger policy. |
| R4-Q06 taste-only risk | Rewritten | Visual stance retained only with evidence gates. |
| R5-Q04 | Merged into Q28 | Endpoint parser/whitelist landing sharpens endpoint parity rather than adding a duplicate. |
| R5-Q05 | Merged into Q31 | State-cells/tool-card landing sharpens 10-family mock cards rather than adding a duplicate. |
| R5-Q08 | Merged into final closeout | A2 blocker ordering is synthesis over prior questions, not a standalone grill item. |

## Merge Records

| Merge | Result |
|---|---|
| R1-Q06 + R1-Q09 | Canonical Q06: checkpoint 50/100/150 C6 sampling, thresholds, early-stop/human-pause, and sign-or-block receipts. |
| R1-Q07 vs R2-Q07 | Split responsibilities: Q07 = stale-anchor grep debt; Q15 = authority cascade inventory matrix. |
| R4-Q02 + R5-Q04 | Canonical Q28: endpoint parity includes parser/whitelist landing details. |
| R4-Q05 + R5-Q05 | Canonical Q31: mock cards include state-cells expansion and tool-card map artifact. |
| R2-Q12/R2-Q13 + R5-Q08 | A2 blocker ordering retained as final synthesis, not canonical question. |

## Remaining Gaps

- CAS4-CAS8: runtime tier merge, 10-family narrowing, decisions D1-D37 supersede review, baseline, roadmap and ADR cascade.
- Final list complete: 41 confirmed questions.

## Next Round Focus

Final step: write `final-grill-list.md` with exactly 41 questions.

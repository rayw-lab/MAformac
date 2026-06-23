# Round 04 Judge

## Scope

Round 04 covered the remaining original §15 TRN questions and early UIX questions: TRN7-TRN9 and UIX1-UIX6.

## Candidate Verdicts

| ID | Topic | Avg score | Verdict | Judge rationale |
|---|---|---:|---|---|
| R4-Q01 | TRN7 mlx-lm feasibility | 24.0 | Keep | Physical feasibility gate for training. Distinct from mid-training C6 gate. |
| R4-Q02 | TRN8 endpoint parity | 22.0 | Keep, narrow | Must be endpoint-specific: mlx-swift render/parse/mounted whitelist. Not broad train/eval/runtime parity. |
| R4-Q03 | TRN9 DoRA/complex reasoning upgrade timing | 19.0 | Keep only after rewrite | Keep as forbidden-until/trigger matrix, not as recipe or DoRA re-litigation. |
| R4-Q04 | UIX1 UIUE findings triage | 23.25 | Keep, rewrite | Converts UIUE research into a scoped matrix under 10-family demo. Must pin exact finding source IDs. |
| R4-Q05 | UIX2 10-family mock cards | 24.25 | Keep | Critical UI/runtime bridge. Must land as state-cells/tool-card map, not just visuals. |
| R4-Q06 | UIX3 visual stance | 17.0 | Keep only after rewrite | Lowest score but still valid as an evidence-gated stance check. Delete if it becomes aesthetic preference debate. |
| R4-Q07 | UIX4 engineering hard preflight | 25.0 | Keep | Strongest Round 04 item. “Can run” hard blocker, not polish. |
| R4-Q08 | UIX5 onsite SOP pre-mortem | 23.25 | Keep | Distinct from hard preflight: live demo checklist and fallback operations. |
| R4-Q09 | UIX6 route UI states | 22.25 | Keep, rewrite | Necessary visible contract for route/dialogue/refusal states. Must bind to trace/route enum and golden cases. |

## Final Round 04 Questions

27. **R4-Q01 Mlx-lm feasibility**: Under four data classes, seed/variant volume, and checkpoint 50/100/150 cadence, can local `mlx-lm 0.31.1` train within acceptable wall-clock, memory, thermal, and disk budgets? Require `rows_by_class`, token/step estimate, preflight duration, peak memory/phys footprint, checkpoint write cost, env receipt, and fallback trigger.
28. **R4-Q02 Endpoint parity**: Does the mlx-swift endpoint actually match training/eval rendering and parsing? Treat endpoint GBNF/constrained decoding as unproven; require `render_parity_diff=0`, mounted whitelist, defensive JSON parsing, endpoint decode spike, and `tool_not_in_whitelist=0` before claiming endpoint candidate.
29. **R4-Q03 Upgrade trigger policy**: When are DoRA/QDoRA, recipe changes, or LoRA-learned complex reasoning allowed? Define `forbidden_before_g6c_vpass`, deterministic scene-macro boundary, allowed macro IDs, V-PASS-after trigger metrics, rollback gates, and recipe reopen conditions.
30. **R4-Q04 UIUE findings triage**: Which exact UIUE findings enter MVP demo, become irrelevant under 10-family scope, or are cut? First pin the source list, then output `finding_id/source / decision(demo|irrelevant_by_10family|cut) / why / landing_artifact / owner_gate / verification`.
31. **R4-Q05 10-family mock cards**: What state fields, card count, readback templates, icons, numeric displays,亮暗, and animations does each 10-family card need? Output `tool -> IR -> state_cell_id -> card_id -> patch`, require state-cells 10-family coverage, and prioritize by `value.type` and §14 distribution.
32. **R4-Q06 Visual stance evidence gate**: Does “deep-space glow dark three-screen + native SwiftUI bridge” still fit D-domain/10-family demo? Keep, restart, or locally adjust only through evidence gates: information architecture, SwiftUI feasibility, performance/Reduce Motion, projection/iPhone/Mac visibility, and aesthetic 5 Gate.
33. **R4-Q07 Engineering hard preflight**: Are Info.plist, entitlements, microphone permission, Release launch, memory/OOM, model loading, and main-thread freeze checks hard blockers before G6/A2/demo-golden-run? Define commands/logs/receipts and blocker levels; do not file these as UI polish.
34. **R4-Q08 Onsite SOP pre-mortem**: Which onsite risks are eliminated by Mac-primary demo and which still require SOP? Output `risk / eliminated_by_mac_primary / residual_demo_sop / preflight_check / fallback`, covering certificates, battery/Reduce Motion, projection, offline mode, model prewarm, crash logs, and scripted fallback.
35. **R4-Q09 Route UI states**: What minimum visible states prove L1 fast path, L2-L5 thinking, clarify, unsupported, safety refusal, followup resolved, and followup ambiguous? Bind `route_state / dialogue_state / visible_state / animation_budget / trace_field / golden_case` and validate with second-turn cases from ac/window/wiper/fragrance.

## Merge And Dedupe Decisions

- R4-Q02 survives only as endpoint parity; broad surface parity remains Q05.
- R4-Q03 survives only as upgrade trigger policy; recipe freeze remains Q23.
- R4-Q06 survives only as evidence gate; if later answers become taste-only, it should be trimmed.
- R4-Q07 and R4-Q08 stay separate: hard app preflight vs live onsite SOP.
- R4-Q05 and R4-Q09 stay separate: mock state/card contract vs route/dialogue visible states.

## Remaining Gaps For Round 05

- Original §15 UIX7-UIX9 remain.
- Cross-cut extras surfaced repeatedly by brains: B1 endpoint parser/whitelist, B2 state-cells/tool-card map, F1 risk-policy safety boundary, G6 scenario macro boundary, and final dedupe/integration ordering.

---
status: draft_pending_user_decision
artifact_kind: stop_the_train_carrier_map
authority: route_control_not_ssot
retire_trigger: "Retire after OpenSpec proposal/design/tasks are accepted and phase0-d1-d10-closeout.md records the final mapping."
expires: "2026-07-15"
---

# Stop-The-Train OpenSpec Carrier Map

## Purpose

This map preserves the original first-tier stop-the-train rows from `docs/research/2026-06-24-lora-zero-failure-deepdive/stop-the-train-matrix.md:11-18` and routes them into active OpenSpec draft carriers without reshaping them into the earlier Codex regrouping.

## Mapping

| Source row | Source risk | Primary carrier | Design AD | Task row | Evidence/fail action |
|---|---|---|---|---|---|
| R-L09 | Sample observability / fake tool removal | `openspec/changes/retrain-c5-lora-d-domain` | AD-C5-002 | 2.5.G1 | Compute from actual `tools`; any target-present no-call or label conflict blocks. |
| R-L02 | Train/eval/runtime surface source mismatch | `openspec/changes/retrain-c5-lora-d-domain` | AD-C5-001 | 2.5.G2 | Surface digest must derive from one A2 source; `tool_call_frame` residue blocks. |
| R-L03 | Chat-template byte parity / endpoint render gap | `openspec/changes/retrain-c5-lora-d-domain` | AD-C5-003 | 2.5.G3 | Endpoint render nil or byte mismatch is blocked, not pass. |
| R-L05 | Mid-training behavior gate | `openspec/changes/retrain-c5-lora-d-domain`; support in `rebuild-c6-four-layer-bench` | AD-C5-004; AD-C6-003 | 2.5.G4; 3.5.G3 | iter50/100/150 generation gate returns `continue/human_pause/early_stop/blocked`; C6 release cases are not checkpoint-selection oracle. |
| R-L04 | C6 denominator aggregation drift | `openspec/changes/rebuild-c6-four-layer-bench` | AD-C6-001 | 3.5.G1 | Denominators derive from case schema fields; aggregate pass-rate replacement is rejected. |
| R-L07 | Data recipe negative-class collapse | `openspec/changes/retrain-c5-lora-d-domain` | AD-C5-005 | 2.5.G5 | Four classes remain visible; ratio is hypothesis; IrrelAcc cannot regress below active base anchor. |
| R-L17 | Human review / cross-frame blind spot | both draft changes | AD-C5-007; AD-C6-005 | 2.5.G7; 3.5.G5 | Codex audit is same-vendor pre-check; high-stakes signoff needs heterogeneous deframing review or user waiver. |
| R-L11 | Gate integrity / anti-fake-green | both draft changes | AD-C5-006; AD-C6-004 | 2.5.G6; 3.5.G4 | Pass claims require first-hand artifacts; grader failure stays `UNSIGNED/BLOCKED`. |

## Linked But Not Replacing First-Tier Rows

- R-L08 leakage remains P0/P1 linked work for retrain data gates, but it does not replace or split the original R-L11+R-L08 fake-green concern in the source research.
- R-L10/R-L12/R-L18 are relevant to future data recipe/status/voice work, but they are not part of the first-tier eight-row carrier rewrite.

## Boundary

This map is a draft route-control artifact. It does not authorize data generation, training, base recalibration, evaluation, endpoint claims, demo-golden-run, voice, or UIUE merge.

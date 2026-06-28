---
status: r3_residual_routed_for_r4_r5
artifact_kind: docs_local_routing_table
date: 2026-06-28
proof_class: docs/local
non_claims: [no V-PASS, no mobile, no true_device, no runtime-ready, no voice-ready, no model-ready, no golden-ready, no endpoint-ready, no A-2 complete]
---

# UIUE R3 Residual Routing To R4/R5

Purpose: carry R3 residuals into R4 human review without fake-green. Implementation residuals generally do not block R4 human review, but they must be routed to R4 burndown, R5, or later owner before R4 exit.

Primary sources:
- `Reports/uiue-8c2-r3-closeout-20260628/closeout.md`
- `docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/pre-human-l3-package/r3-closeout-20260628/r3-evidence-index.md`
- `docs/grill-tournament/uiue-r0-r2-grill-burndown-2026-06-27.md`
- User/commander latest R4 instruction: L3 passed with notes; notes no longer block R3, but remain residual/non-claim.

| Residual | Current proof / source | R4 handling | R5 or later handling | Block R4 human review? | Block R4 exit? | Non-claim guardrail | Owner / route |
| --- | --- | --- | --- | --- | --- | --- | --- |
| runtime-driven orb binding | `Reports/uiue-8c2-r3-closeout-20260628/closeout.md` and R3 evidence index prove `SnapshotPreset -> PresentationSnapshot.orbState -> DemoOrbView`; they explicitly do not prove ASR/LLM/router/runtime binding. | Classify as bridge seam/evidence cap under C14/C17/C40; require snapshot field and proof-class guard, not runtime implementation. | Runtime adapter must map backend/router states to `PresentationOrbState` and produce logs/fixtures proving the path. | no | depends: no if seam and non-claim are accepted; yes if review demands runtime proof in R4. | No voice-ready, runtime-ready, endpoint-ready, or V-PASS from orb screenshots. | R4 bridge schema + R5 runtime/voice |
| 复杂推理 -> think | R3 notes say complex reasoning mapping to `think` remains deferred to runtime presentation bridge verification. | Answer C14/C15/C17: define presentation choreography and evidence cap; do not claim backend intent-router semantics. | Runtime/router must decide which intents are complex and emit thinking snapshot lifecycle. | no | depends: route must be explicit; implementation can defer. | Presentation `think` mock is not LLM reasoning proof. | R4 evidence checklist + R5 runtime/model |
| 长按 1.5 秒进入演绎控制台 | `Reports/uiue-8c2-r3-closeout-20260628/closeout.md` records this is not implemented/proven in R3; current control console exists as Settings panel button only. | Route through C34/C35/C36 as user decision + visual policy. Human review should decide whether the gesture exists and its a11y/reduce-motion alternative. | If approved, implement gesture arbitration, progress feedback, cancel radius, and non-gesture entry in a later implementation task. | no | depends: decision/routing must be recorded; code proof can defer. | No claim that long-press console works today. | user decision -> R4 visual policy -> later implementation |
| 44pt/VoiceOver | R0-R2 burndown keeps C39/C40 a11y proof open; R3 closeout only scoped to `8.C2` visual acceptance. | Route through C46 a11y checklist; require stable identifier/label/value and alternate paths as R4 evidence expectations. | Implement and verify full VoiceOver path and touch-target proof in dedicated a11y pass. | no | depends: checklist must be accepted or explicit post-R4 blocker. | No accessibility readiness claim from visual screenshots alone. | R4 test-harness/evidence checklist + later a11y implementation |
| 完整 10-family interaction matrix | R3 burndown says full 10-family matrix is deferred post-R3; only representative 8.C2 anchors were covered. | Route through C07/C24/C31/C32 as bridge observable interaction semantics, not local-only UI policy. | Complete family-by-family runtime/presentation fixtures and tests after R4 contract classification. | no | depends: R4 must define matrix artifact owner and proof class. | Do not claim full R1/R2 interaction readiness. | R4 bridge schema + evidence checklist; R5 implementation |
| summary direct-control / gear direct touch | Current R3/R0-R2 evidence does not close broader direct-control/gear interaction readiness; no R4 implementation proof is claimed here. | Treat as interaction semantics crossing bridge and visual policy ownership; classify under C07/C24/C35/C46 if it becomes a R4 question. | Implement direct-control affordance/touch/disabled/readback behavior with explicit safety and a11y tests. | no | depends: should be listed in R4 burndown if human review marks it P0. | No claim that summary or gear direct touch is complete. | R4 visual policy/evidence checklist -> later implementation |
| capsule final-art | R3 closeout retains capsule final-art/white-edge as residual/non-claim, not an R3 blocker. | Route as visual policy/evidence checklist, not bridge schema, unless a snapshot field is required for state source. | Finalize artwork/polish thresholds and recapture proof if visual review requires. | no | no if retained as notes; depends if human review elevates to P0 visual policy. | No final-art complete claim. | R4 visual policy + design/art lane |
| white-edge formal threshold | R3 closeout and burndown retain white-edge threshold as unformalized; checker remains WARN, not clean PASS. | Keep as evidence checklist residual. Do not convert `WARN` to `PASS` without threshold decision. | Formalize threshold or remove the checker assertion after design decision. | no | no if documented as accepted-with-notes; yes only if human review makes it R4 hard gate. | No checker-clean PASS claim. | R4 evidence checklist + later design/test decision |
| R2b white-edge WARN accepted-with-notes | `docs/grill-tournament/uiue-r0-r2-grill-burndown-2026-06-27.md` marks R2b white-edge WARN accepted-with-notes for R3. | Carry as residual note; only use it as proof of route/decision, not visual perfection. | Resolve threshold if R5 visual hardening requires a clean checker result. | no | no | `WARN` stays `WARN`; do not relabel as PASS. | evidence checklist |
| Reduce Motion proof class = simulator_debug_override, not true-device/system setting proof | R3 evidence index records `simctl ui` lacks Reduce Motion toggle and uses `-forceReduceMotion`; proof class `simulator_debug_override`. | Use as proof-class example in C09/C47/C48; require zone-wise reduce-motion evidence for new R4 claims. | If needed, collect true-device/system-setting proof separately. | no | no if proof-class cap is preserved; yes if review requires true-device proof. | No true-device accessibility proof claim. | R4 evidence checklist |

## R4 Human Review Interpretation

- `no` in `Block R4 human review?` means 磊哥 can review the R4 route/classification now; it does not mean the residual is implemented.
- `depends` in `Block R4 exit?` means R4 must explicitly choose route/owner/non-claim before exit, but may defer code proof to R5/later if accepted with notes.
- Any attempt to convert simulator/mock evidence into runtime/mobile/true-device proof must fail closed.


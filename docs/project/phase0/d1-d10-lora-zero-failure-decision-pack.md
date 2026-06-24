---
status: draft_pending_user_decision
artifact_kind: phase0_decision_pack
authority: route_control_not_ssot
retire_trigger: "Retire after phase0-d1-d10-closeout.md records all D1-D10 user verdicts and the accepted carrier map."
expires: "2026-07-15"
---

# D1-D10 LoRA Zero-Failure Decision Pack

## Purpose

This file turns the LoRA zero-failure research decisions into a user-reviewable Phase 0 pack. It is not an OpenSpec archive, not an accepted gate policy, and not permission to run data generation, LoRA training, model-quality evaluation, endpoint readiness, demo-golden-run, voice, or UIUE merge.

## Authority Boundary

- Source D1-D9: `docs/research/2026-06-24-lora-zero-failure-deepdive/decisions-and-grill-ammo.md:5-57`.
- Source D10 candidate: `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:77`, `:99`, `:119` plus `docs/research/2026-06-24-lora-zero-failure-deepdive/lens12-sft-vs-dpo-refusal.md:61-64`.
- Decision verdict source: `docs/project/phase0/phase0-d1-d10-user-decision-record.md`.
- OpenSpec carrier source: `docs/project/phase0/stop-the-train-openspec-carrier-map.md`.

Defaults below are recommendations for quick-pass review, not Codex decisions.

## Decision Table

| ID | Decision | Source | Recommended default | Review lane | Current verdict | OpenSpec carriers |
|---|---|---|---|---|---|---|
| D1 | C6 action `hard_pass` denominator | `decisions-and-grill-ammo.md:5-9` | A: derive four-layer denominators from case schema fields; old 10/23 is historical anchor until D-domain base rerun is authorized. | fast-pass | pending_user_verdict | `rebuild-c6-four-layer-bench` AD-C6-001/002 |
| D2 | Mid-training behavior gate four-state threshold | `decisions-and-grill-ammo.md:11-15` | A: iter50/100/150 behavioral generation gate with `continue/human_pause/early_stop/blocked`; infra-enforced, not loss-only. | high-attention | pending_user_verdict | `retrain-c5-lora-d-domain` AD-C5-004; `rebuild-c6-four-layer-bench` AD-C6-003 |
| D3 | Four-class data ratio and negative sample sweet spot | `decisions-and-grill-ammo.md:17-21` | C: run a ratio spike; start near A but do not freeze 24% into production. | high-attention | pending_user_verdict | `retrain-c5-lora-d-domain` AD-C5-005 |
| D4 | Refusal/safety/clarification training method | `decisions-and-grill-ammo.md:23-27` | A for demo phase plus C as future escape: SFT first; DPO deferred. | fast-pass | pending_user_verdict | `retrain-c5-lora-d-domain` proposal/tasks |
| D5 | Endpoint byte-parity gate | `decisions-and-grill-ammo.md:29-33` | C: write as OpenSpec gate task now; current endpoint render is blocked, not pass. | fast-pass | pending_user_verdict | `retrain-c5-lora-d-domain` AD-C5-003 |
| D6 | General Chinese mix and regression gate | `decisions-and-grill-ammo.md:35-39` | A as hypothesis: 5-25% mix plus zero-shot/general regression gate, ratio to spike. | high-attention | pending_user_verdict | future retrain recipe; not a Phase 0 executable gate |
| D7 | Failure/error-recovery class inclusion | `decisions-and-grill-ammo.md:41-45` | A+C: cut full failure chains for demo scope, keep minimal seed/loss-mask kernel. | high-attention | pending_user_verdict | retrain recipe; status vocabulary C09/C10 intersection |
| D8 | Endpoint constrained decoding engine | `decisions-and-grill-ammo.md:47-51` | A as P1 escape hatch: XGrammar first; grammar must include refusal/no-op/unsupported exits. | fast-pass | pending_user_verdict | endpoint/golden future carrier; not current retrain execution |
| D9 | Next OpenSpec change boundary | `decisions-and-grill-ammo.md:53-57` | C: write P0 gate tasks into retrain-c5 and rebuild-c6; do not run training/evaluation/voice now. | fast-pass | pending_user_verdict | both active OpenSpec draft changes |
| D10 | `already_state` / state-noop classification | `a2-post-roadmap-audit-vs-home-llm.md:77,99,119`; `lens12-sft-vs-dpo-refusal.md:61-64` | Treat as distinct from unsupported and safety. Default owner: code/readback renderer unless C6 evidence proves model training is required. | high-attention | pending_user_verdict | `retrain-c5-lora-d-domain` AD-C5-009; C06/C24 skeletons |

## Non-Decision Guardrails

- `train_health` does not imply `model_quality`, `lora_candidate`, endpoint readiness, V-PASS, or demo readiness.
- C6 model-quality evidence does not imply endpoint readiness, V-PASS, S-PASS, U-PASS, or UIUE acceptance.
- A Codex subagent audit is only same-vendor pre-check. It does not satisfy R-L17 heterogeneous deframing review.
- `a2-post-roadmap` remains a research/pre-propose checklist, not SSOT.

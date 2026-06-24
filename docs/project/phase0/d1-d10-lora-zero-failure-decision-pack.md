---
status: accepted_user_verdicts
artifact_kind: phase0_decision_pack
authority: route_control_not_ssot
retire_trigger: "Retire after phase0-d1-d10-closeout.md records all D1-D10 user verdicts and the accepted carrier map."
expires: "2026-07-15"
---

# D1-D10 LoRA Zero-Failure Decision Pack

## Purpose

This file turns the LoRA zero-failure research decisions into a user-reviewed Phase 0 pack. It is not an OpenSpec archive, not an apply-ready policy, and not permission to run data generation, LoRA training, model-quality evaluation, endpoint readiness, demo-golden-run, voice, or UIUE merge.

## Authority Boundary

- Source D1-D9: `docs/research/2026-06-24-lora-zero-failure-deepdive/decisions-and-grill-ammo.md:5-57`.
- Source D10 candidate: `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:77`, `:99`, `:119` plus `docs/research/2026-06-24-lora-zero-failure-deepdive/lens12-sft-vs-dpo-refusal.md:61-64`.
- Decision verdict source: `docs/project/phase0/phase0-d1-d10-user-decision-record.md`.
- OpenSpec carrier source: `docs/project/phase0/stop-the-train-openspec-carrier-map.md`.

Defaults below were reviewed by the user on 2026-06-24. The detailed verdict source is `phase0-d1-d10-user-decision-record.md`.

## Decision Table

| ID | Decision | Source | Recommended default | Review lane | Current verdict | OpenSpec carriers |
|---|---|---|---|---|---|---|
| D1 | C6 action `hard_pass` denominator | `decisions-and-grill-ammo.md:5-9` | A: derive four-layer denominators from case schema fields; old 10/23 is historical anchor until D-domain base rerun is authorized. | fast-pass | accepted_fast_pass | `rebuild-c6-four-layer-bench` AD-C6-001/002 |
| D2 | Mid-training behavior gate four-state threshold | `decisions-and-grill-ammo.md:11-15` | A: iter50/100/150 behavioral generation gate with `continue/human_pause/early_stop/blocked`; infra-enforced, not loss-only. | high-attention | accepted_human_reviewed | `retrain-c5-lora-d-domain` AD-C5-004; `rebuild-c6-four-layer-bench` AD-C6-003 |
| D3 | Four-class data ratio and negative sample sweet spot | `decisions-and-grill-ammo.md:17-21` | Start positive 20 / unsupported 6 / safety 3 / followup 2; spike 6.7% to 24% and freeze only after over-refusal bend evidence. | high-attention | accepted_hypothesis_not_frozen | `retrain-c5-lora-d-domain` AD-C5-005 |
| D4 | Refusal/safety/clarification training method | `decisions-and-grill-ammo.md:23-27` | SFT first; DPO deferred; reopen only if SFT plus natural Chinese data still leaves seven demo-critical refusal cases at 0/7. | fast-pass | accepted_fast_pass_with_reopen_condition | `retrain-c5-lora-d-domain` proposal/tasks |
| D5 | Endpoint byte-parity gate | `decisions-and-grill-ammo.md:29-33` | C: write as OpenSpec gate task now; current endpoint render is blocked, not pass. | fast-pass | accepted_fast_pass | `retrain-c5-lora-d-domain` AD-C5-003 |
| D6 | General Chinese mix and regression gate | `decisions-and-grill-ammo.md:35-39` | Start with 10-15% general Chinese within the 5-25% hypothesis range; candidate degradation over 5% versus raw Qwen3-1.7B is `UNSIGNED`. | high-attention | accepted_human_reviewed | `retrain-c5-lora-d-domain` AD-C5-010 |
| D7 | Failure/error-recovery class inclusion | `decisions-and-grill-ammo.md:41-45` | Cut full recovery chains; keep minimal seed only, factor <= 2, <= 50 rows, loss-masked failure turns. | high-attention | accepted_human_reviewed | `retrain-c5-lora-d-domain` AD-C5-005/006; status vocabulary C09/C10 intersection |
| D8 | Endpoint constrained decoding engine | `decisions-and-grill-ammo.md:47-51` | A as P1 escape hatch: XGrammar first; grammar must include refusal/no-op/unsupported exits. | fast-pass | accepted_fast_pass | endpoint/golden future carrier; not current retrain execution |
| D9 | Next OpenSpec change boundary | `decisions-and-grill-ammo.md:53-57` | C: write P0 gate tasks into retrain-c5 and rebuild-c6; do not run training/evaluation/voice now. | fast-pass | accepted_fast_pass_draft_only | both active OpenSpec draft changes |
| D10 | `already_state` / state-noop classification | `a2-post-roadmap-audit-vs-home-llm.md:77,99,119`; `lens12-sft-vs-dpo-refusal.md:61-64` | Independent fifth state class; default owner C3 + readback renderer; training only for answer templates unless C6 evidence shows FN > 20%. | high-attention | accepted_human_reviewed | `retrain-c5-lora-d-domain` AD-C5-009; C06/C24 skeletons; golden-run dedicated case |

## Accepted Cross-Decision Rules

- D3 ratio spike, D6 general Chinese mix, and D7 failure minimal seed must use the same LoRA candidate ID. Do not cherry-pick across candidates.
- D2 behavior gate, D3 spike, D6 regression, and D7 minimal-seed receipt remain `UNSIGNED` until physical evidence exists. Codex/Claude/metadata assertions are not pass evidence.
- D10 `already_state` must have one dedicated demo-golden-run case before golden-run IDs/readback are frozen.

## Non-Decision Guardrails

- `train_health` does not imply `model_quality`, `lora_candidate`, endpoint readiness, V-PASS, or demo readiness.
- C6 model-quality evidence does not imply endpoint readiness, V-PASS, S-PASS, U-PASS, or UIUE acceptance.
- A Codex subagent audit is only same-vendor pre-check. It does not satisfy R-L17 heterogeneous deframing review.
- `a2-post-roadmap` remains a research/pre-propose checklist, not SSOT.

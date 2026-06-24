---
status: user_decisions_accepted
artifact_kind: user_decision_record
authority: user_verdict_record_not_ssot
pending_user_decision: []
retire_trigger: "Retire after all D1-D10 rows are non-pending and phase0-d1-d10-closeout.md records the accepted final state."
expires: "2026-07-15"
---

# Phase 0 D1-D10 User Decision Record

## Boundary

This record exists to prevent Codex or any subagent from laundering defaults into user decisions. As of 2026-06-24, all D1-D10 rows below have explicit user verdicts. This accepts the Phase 0 decision content, but it does not authorize data generation, training, model-quality evaluation, endpoint readiness, demo-golden-run, voice, or UIUE merge.

## Verdicts

| ID | Decision | Recommended handling | User verdict | Notes |
|---|---|---|---|---|
| D1 | C6 action `hard_pass` denominator | Fast-pass default A | accepted_fast_pass | Four-layer denominator stays schema-derived. Old base 10/23 is historical only until a D-domain surface base rerun is authorized. |
| D2 | Mid-training behavior gate four-state threshold | Human review | accepted_human_reviewed | iter50/100/150; sample 5 end-to-end D-domain tool-call outputs; state machine `continue/human_pause/early_stop/blocked`; behavior-generation gate, not val-loss gate; `human_pause` requires human review of 50 sample outputs; generic-frame tool name at iter50 blocks progression. |
| D3 | Four-class data ratio | Human review | accepted_hypothesis_not_frozen | Start positive 20 / unsupported 6 / safety 3 / followup 2, about 15.4% negative. Spike 6.7% to 24% and freeze only after finding the over-refusal bend; IrrelAcc below active base 0.789 marks the bend. Negative samples and safety stay non-zero. |
| D4 | Refusal/safety/clarification method | Fast-pass SFT first, DPO deferred | accepted_fast_pass_with_reopen_condition | SFT first and DPO deferred. Reopen DPO only if SFT plus natural Chinese data still leaves the seven demo-critical refusal cases at 0/7. |
| D5 | Endpoint byte parity | Fast-pass OpenSpec task, current state blocked | accepted_fast_pass | Endpoint byte parity is a required gate, but current endpoint render bytes are blocked/nil, not pass. |
| D6 | General Chinese mix | Human review | accepted_human_reviewed | Mix 10-15% general Chinese as the starting hypothesis within the 5-25% range. Use raw Qwen3-1.7B as base; candidate degradation over 5% on C-Eval/CMMLU or equivalent Chinese regression is `UNSIGNED`. Include at least one non-tool-call task. |
| D7 | Failure/error-recovery inclusion | Human review | accepted_human_reviewed | Cut full HA-style three-turn recovery chains. Keep minimal seed only: factor <= 2, single-turn parser-failure to natural Chinese clarification, <= 50 rows in receipt. Failure turns use loss-mask kernel with `train_on_turn=false` to prevent learning bad calls. |
| D8 | Constrained decoding engine | Fast-pass P1 escape hatch | accepted_fast_pass | XGrammar remains a P1 escape hatch, not a Phase 0 blocker. Any future grammar must include refusal/no-op/unsupported exits. |
| D9 | Next OpenSpec boundary | Fast-pass C: two draft changes, no execution | accepted_fast_pass_draft_only | Only create/update draft OpenSpec carriers now. No training, evaluation, voice, endpoint-ready, UIUE merge, or demo-golden-run execution. |
| D10 | `already_state` / state-noop classification | Human review | accepted_human_reviewed | Independent fifth state class, peer to unsupported/safety/success/clarify. Default owner is C3 + readback renderer; training only learns natural-language answer templates unless C6 evidence shows natural-language `already_state` false-negative rate above 20%. Must distinguish defaulted/explicit/already_state scope origin. |

## Cross-Decision Rules

| Rule | Verdict |
|---|---|
| D3 ratio spike, D6 general Chinese mix, and D7 failure minimal seed must run on the same LoRA candidate. | accepted |
| D2 behavior gate, D3 spike, D6 regression, and D7 minimal-seed receipt remain `UNSIGNED` until physical evidence exists; metadata claims are not pass evidence. | accepted |
| D10 `already_state` must have one dedicated demo-golden-run case before golden-run IDs/readback are frozen. | accepted |

## Activation Rule

If any `User verdict` cell is `pending`, downstream documents may say `draft pending user decision` only. They must not say accepted gate policy, apply-ready, training-ready, model-quality-ready, endpoint-ready, demo-ready, or UIUE-ready.

Machine gate: `pending_user_decision` is now empty and no verdict row may contain `| pending |` before downstream OpenSpec task rewrites are treated as accepted gate policy. `openspec validate --all --strict` is structural validation only; it does not override OpenSpec acceptance, R-L17 heterogeneous review, or runtime evidence gates.

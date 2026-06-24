---
status: pending_user_decisions
artifact_kind: user_decision_record
authority: user_verdict_record_not_ssot
retire_trigger: "Retire after all D1-D10 rows are non-pending and phase0-d1-d10-closeout.md records the accepted final state."
expires: "2026-07-15"
---

# Phase 0 D1-D10 User Decision Record

## Boundary

This record exists to prevent Codex or any subagent from laundering defaults into user decisions. Until every required row below is non-pending, OpenSpec task rewrites in `retrain-c5-lora-d-domain` and `rebuild-c6-four-layer-bench` remain draft gate policy only.

## Verdicts

| ID | Decision | Recommended handling | User verdict | Notes |
|---|---|---|---|---|
| D1 | C6 action `hard_pass` denominator | Fast-pass default A | pending | Four-layer denominator stays schema-derived. |
| D2 | Mid-training behavior gate four-state threshold | Human review | pending | Thresholds and pause/stop ownership need explicit user approval. |
| D3 | Four-class data ratio | Human review | pending | Ratio is a spike hypothesis, not fixed production value. |
| D4 | Refusal/safety/clarification method | Fast-pass SFT first, DPO deferred | pending | DPO remains non-blocking. |
| D5 | Endpoint byte parity | Fast-pass OpenSpec task, current state blocked | pending | Endpoint render bytes not yet wired. |
| D6 | General Chinese mix | Human review | pending | Keep as hypothesis and regression gate. |
| D7 | Failure/error-recovery inclusion | Human review | pending | Cut full chain, keep minimal seed only if approved. |
| D8 | Constrained decoding engine | Fast-pass P1 escape hatch | pending | XGrammar not current Phase 0 blocker. |
| D9 | Next OpenSpec boundary | Fast-pass C: two draft changes, no execution | pending | No training/evaluation/voice/golden-run now. |
| D10 | `already_state` / state-noop classification | Human review | pending | Separate from unsupported and safety; default owner code/readback renderer. |

## Activation Rule

If any `User verdict` cell is `pending`, downstream documents may say `draft pending user decision` only. They must not say accepted gate policy, apply-ready, training-ready, model-quality-ready, endpoint-ready, demo-ready, or UIUE-ready.

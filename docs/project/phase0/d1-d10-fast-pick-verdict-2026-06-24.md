---
status: retired_pending_openspec_carriers
artifact_kind: phase0_fast_pick_archive
authority: archive_not_ssot
decision_source: docs/project/phase0/phase0-d1-d10-user-decision-record.md
retire_trigger: "Retire after Phase 0 D1-D10 closeout and OpenSpec carrier acceptance supersede this archive."
expires: "2026-07-15"
---


> **RETIRED-PENDING (2026-07-07)**: Phase 0 D1-D10 closeout recorded. OpenSpec carriers still `active_construction` — full retire deferred to carriers archived. See `physical-cleanup-execution-pack.md` batch 3.

# D1-D10 Fast-Pick Verdict Archive

This archive records the 2026-06-24 fast-pick table used to clear the D1-D10 user-decision gate. The authoritative local verdict record is `phase0-d1-d10-user-decision-record.md`.

## D1-D10 Verdict Table

| Category | ID | Decision | Verdict | Load-bearing condition | Landing |
|---|---:|---|---|---|---|
| fast-pass | D1 | C6 action `hard_pass` denominator | accepted | Denominators stay schema-derived; old base 10/23 is historical until a D-domain base rerun is authorized. | rebuild-c6 AD-C6-001/002 |
| human-reviewed | D2 | Mid-training behavior gate | accepted | iter50/100/150, five end-to-end D-domain samples, four states `continue/human_pause/early_stop/blocked`; behavior gate, not val-loss gate; generic-frame tool at iter50 blocks. | retrain-c5 AD-C5-004/tasks 2.5.G4 |
| human-reviewed | D3 | Four-class ratio | accepted hypothesis, not frozen | Start positive 20 / unsupported 6 / safety 3 / followup 2; scan 6.7% to 24%; IrrelAcc below active base 0.789 marks over-refusal bend. | retrain-c5 AD-C5-005/tasks 2.5.G5 |
| conditional fast-pass | D4 | Refusal/safety/clarification method | accepted with reopen condition | SFT first, DPO deferred; reopen DPO only if SFT plus natural Chinese data still leaves seven demo-critical refusal cases at 0/7. | retrain-c5 proposal/tasks |
| fast-pass | D5 | Endpoint byte parity | accepted | Gate required, but current endpoint render bytes are blocked/nil, not pass. | retrain-c5 AD-C5-003 |
| human-reviewed | D6 | General Chinese mix | accepted | Start 10-15% general Chinese; raw Qwen3-1.7B is base; >5% Chinese regression degradation leaves candidate `UNSIGNED`; include at least one non-tool-call task. | retrain-c5 AD-C5-010/tasks 2.5.G5a |
| human-reviewed | D7 | Failure/error-recovery inclusion | accepted | Cut HA-style three-turn chains; keep minimal seed only, factor <= 2, <= 50 rows; failure turns `train_on_turn=false`. | retrain-c5 AD-C5-005/006/tasks 2.5.G5b |
| fast-pass | D8 | Constrained decoding engine | accepted | XGrammar is P1 escape hatch; any future grammar must include refusal/no-op/unsupported exits. | future endpoint/golden carrier |
| fast-pass | D9 | Next OpenSpec boundary | accepted draft-only | Only create/update draft carriers now; no training/evaluation/voice/endpoint-ready/UIUE/demo-golden execution. | retrain-c5/rebuild-c6 |
| human-reviewed | D10 | `already_state` / state-noop | accepted | Independent fifth state class; default owner C3 + readback renderer; model trains only answer templates unless C6 shows already_state FN >20%. | retrain-c5 AD-C5-009, C06/C24, golden-run dedicated case |

## Cross-Decision Discipline

| Rule | Verdict | Landing |
|---|---|---|
| D3 ratio spike, D6 general Chinese mix, and D7 failure minimal seed must use the same LoRA candidate ID. | accepted | retrain-c5 tasks 2.5.G5/G5a/G5b/G6 |
| D2 behavior gate, D3 spike, D6 regression, and D7 minimal-seed receipt remain `UNSIGNED` until physical evidence exists. | accepted | retrain-c5 AD-C5-006 |
| D10 `already_state` must have one dedicated demo-golden-run case before golden IDs/readback freeze. | accepted | define-demo-golden-run-and-voice tasks 2.5 |

## Default-Scope Constraint Review

These are already accepted by G01-G28 and are not reopened here.

| Constraint | Verdict | Landing |
|---|---|---|
| C2 `default_scope` is the SSOT. | accepted | define-demo-default-scope Phase -1 carrier |
| Omitted scope is not `全车`. | accepted | C3/compiler/C6/default-scope carrier |
| Explicit all/fan-out remains explicit. | accepted | closed collection alias scenarios |
| Explicit non-default scope remains explicit. | accepted | explicit scope scenarios |
| Readback needs `scope_origin` metadata. | accepted | AD-DS-003, golden/C6/readback tasks |
| Legacy UI keys cannot remain a second truth source. | accepted | AD-DS-007 and later UI/state adapter test |
| UIUE remains isolated except state/C3-C6/golden intersections. | accepted | G28 merge check |
| Golden-run waits for stable default_scope semantics. | accepted | define-demo-golden-run-and-voice dependency |

## Extra Stop-The-Train Gates

| Gate | Nature | User review required | Handling |
|---|---|---|---|
| R-L09 sample observability | mechanical implementation gate | no | Write OpenSpec task; compute from actual tools/records, not metadata. |
| R-L11 anti-fake-green | mechanical implementation gate | no | Write OpenSpec task; pass requires physical artifact, computed source, fail-closed action. |
| R-L17 heterogeneous deframing | human/heterogeneous review gate | yes, strategy already retained open | Keep open until G1-G5 pass: D1-D10 accepted, R1-R7 evidence files complete, >=1 heterogeneous deframing audit, no consistent-PASS bypass, and any disagreement escalated to human-owner review. Codex/Claude same-vendor pre-check is not enough. |

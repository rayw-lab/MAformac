<!--
DRAFT TASKS (2026-06-24 Q1-Q4 文档吸收版)

Topology:
- §2/§3 = C6 Construction Lane. It does not depend on a retrain-C5 candidate.
- §4 = Candidate Comparison Lane. It requires a signed retrain-C5 candidate and explicit run authorization.

Unchecked future tasks are not apply authorization. This draft does not authorize D-domain base recalibration, C6 acceptance, model-quality evaluation, training, endpoint-ready claims, demo-golden-run, voice, UIUE merge, or R-L17 closure.
-->

## 0. Documentation Absorption Closeout

- [ ] 0.1 Validate docs-only absorption with `openspec validate rebuild-c6-four-layer-bench --strict`.
- [ ] 0.2 Validate workspace OpenSpec consistency with `openspec validate --all --strict`.
- [ ] 0.3 Run `git diff --check`.
- [ ] 0.4 Confirm the diff touches only documentation/ledger/OpenSpec paths for this absorption and does not modify Swift, C6 JSONL, Qwen tool format, model artifacts, training data, or voice files.

## 1. Construction Preconditions

- [ ] 1.1 Reconfirm target branch, `HEAD`, and `origin/main` before implementation. Q3 line numbers are evidence anchors, not current API proof.
- [ ] 1.2 Reconfirm load-bearing symbols in current `origin/main`: `ScopeOrigin`, `ScopeResolution.keys`, `ScopeResolution.resolvedScopes`, `C2ScopeResolver.scopedKey()`, and `ToolContractStateApplier.applyWithEvidence`. Halt and re-grill if semantics moved or disappeared. AD: `AD-C6-012`.
- [ ] 1.3 Confirm D-domain surface/default-scope status at current baseline before regenerating or freezing any C6 gold data. Do not redefine default-scope semantics inside this change.
- [ ] 1.4 Confirm R-L17 route-deframing status before apply/implementation. Route signoff may unlock construction only; candidate signoff remains separate. AD: `AD-C6-005`.
- [ ] 1.5 Confirm the BehaviorClass SSOT naming/reconciliation task is scheduled before any selector, active threshold, active base anchor, or apply no-effect label can be frozen. The concrete naming decision remains in §3.3-§3.4. AD: `AD-C6-007`. Decision cite: `D-144` partial G2 basis; `D-147` G2 wave closure; `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-11-ma14/reports/RATIFICATION-RECEIPT-pool32.md`.

## 2. D-Domain Expected-Tool Construction

- [ ] 2.1 Define C6 expected-tool semantics in terms of D-domain named tools, not generic `tool_call_frame`. Decision cite: `D-144` partial G2 basis; `D-147` G2 wave closure; `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-11-ma14/reports/RATIFICATION-RECEIPT-pool32.md`.
- [ ] 2.2 Map C6 release/trap cases to D-domain named tools and schema-valid arguments without copying raw/customer source text. Decision cite: `D-144` partial G2 basis; `D-147` G2 wave closure; `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-11-ma14/reports/RATIFICATION-RECEIPT-pool32.md`.
- [ ] 2.3 Verify expected-tool migration shape only with an authorized contract/shape check such as `archive-check verify-gold` when no model is run. This is not C6 acceptance. AD: `AD-C6-011`. Decision cite: `D-144` partial G2 basis; `D-147` G2 wave closure; `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-11-ma14/reports/RATIFICATION-RECEIPT-pool32.md`.
- [ ] 2.4 Keep C6 release cases final-only and unavailable for checkpoint selection. AD: `AD-C6-003`. Decision cite: `D-144` partial G2 basis; `D-147` G2 wave closure; `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-11-ma14/reports/RATIFICATION-RECEIPT-pool32.md`.

## 3. Four-Layer Bench Construction

- [ ] 3.1 Define four independent external layers: `golden`, `demo_fuzz`, `unsupported`, and `safety`. Aggregate pass rate must not hide any red hard layer. AD: `AD-C6-001`. Decision cite: `D-144` partial G2 basis; `D-147` G2 wave closure; `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-11-ma14/reports/RATIFICATION-RECEIPT-pool32.md`.
- [ ] 3.2 Define the five internal behavior classes: `tool_call`, `clarify_missing_slot`, `refusal_no_available_tool`, `refusal_safety_or_policy`, and `already_state_noop`. Do not add `direct_no_call` for in-scope cockpit-control commands. AD: `AD-C6-007`. Decision cite: `D-144` partial G2 basis; `D-147` G2 wave closure; `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-11-ma14/reports/RATIFICATION-RECEIPT-pool32.md`.
- [ ] 3.3 Reconcile C5 `data_class_observed_count`, C6 `C6Bucket` / selector denominators, apply/execution `no_effect_reason`, and external four-layer reporting to one behavior-class source before executable selectors, active thresholds, or active base anchors are frozen. AD: `AD-C6-007`. Decision cite: `D-144` partial G2 basis; `D-147` G2 wave closure; `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-11-ma14/reports/RATIFICATION-RECEIPT-pool32.md`.
- [ ] 3.4 Decide the SSOT naming shape: either rename `C6Bucket` to `BehaviorClass`, or leave `C6Bucket` as deprecated/typealias/mapped legacy with a deletion window. AD: `AD-C6-007`. Decision cite: `D-144` partial G2 basis; `D-147` G2 wave closure; `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-11-ma14/reports/RATIFICATION-RECEIPT-pool32.md`.
- [ ] 3.5 Derive layer denominators from case schema fields and behavior classification. `C6Bucket.no_call` must not be treated as `already_state_noop`, and broad `refusal` must split unsupported from safety. AD: `AD-C6-001`, `AD-C6-007`. Decision cite: `D-144` partial G2 basis; `D-147` G2 wave closure; `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-11-ma14/reports/RATIFICATION-RECEIPT-pool32.md`.
- [ ] 3.6 Define `future_d_domain_base_anchor_design` as deferred comparison semantics only. Do not run D-domain base recalibration and do not use old generic-frame 10/23 as an active D-domain threshold. AD: `AD-C6-002`. Decision cite: `D-144` partial G2 basis; `D-147` G2 wave closure; `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-11-ma14/reports/RATIFICATION-RECEIPT-pool32.md`.
- [ ] 3.7 Define readback plan P: model hard-pass excludes renderer readback; `verify-gold` keeps deterministic C2 renderer readback validity; clarify/refusal text evidence still counts when asserted. AD: `AD-C6-008`. Decision cite: `D-144` partial G2 basis; `D-147` G2 wave closure; `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-11-ma14/reports/RATIFICATION-RECEIPT-pool32.md`.
- [ ] 3.8 Define receipt fields for readback split: `model_hard_pass_basis`, `readback_applicable`, `readback_match`, and `readback_excluded_from_model_hard_pass`. AD: `AD-C6-008`. Decision cite: `D-144` partial G2 basis; `D-147` G2 wave closure; `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-11-ma14/reports/RATIFICATION-RECEIPT-pool32.md`.
- [ ] 3.9 Define the contract bundle manifest and fingerprint over contract inputs. Preserve existing per-run prompt/output/model/artifact digests as separate fields. AD: `AD-C6-009`. Decision cite: `D-144` partial G2 basis; `D-147` G2 wave closure; `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-11-ma14/reports/RATIFICATION-RECEIPT-pool32.md`.
- [ ] 3.9a Bounded upstream producer subtask: extend `ToolContractStateApplyResult` with `appliedWrites: [StateWrite]` as apply/execution-layer evidence carried by this change. AD: `AD-C6-010`. Decision cite: `D-144` partial G2 basis; `D-147` G2 wave closure; `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-11-ma14/reports/RATIFICATION-RECEIPT-pool32.md`.
- [ ] 3.9b Make `applyWithEvidence` emit numeric direct, enum direct, and dependency writes with state key, before value, after value, scope origin, and `writeKind`. AD: `AD-C6-010`. Decision cite: `D-144` partial G2 basis; `D-147` G2 wave closure; `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-11-ma14/reports/RATIFICATION-RECEIPT-pool32.md`.
- [ ] 3.9c Keep apply failure fail-closed: `applyWithEvidence` still throws on failure and must not return soft error collections as partial-pass evidence. AD: `AD-C6-010`. Decision cite: `D-144` partial G2 basis; `D-147` G2 wave closure; `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-11-ma14/reports/RATIFICATION-RECEIPT-pool32.md`.
- [ ] 3.9d Keep C6 as consumer: do not pass C6 expected-state sets into `applyWithEvidence`; C6 derives `unexpectedMutationKeys` from applied/final state versus expectations. AD: `AD-C6-010`. Decision cite: `D-144` partial G2 basis; `D-147` G2 wave closure; `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-11-ma14/reports/RATIFICATION-RECEIPT-pool32.md`.
- [ ] 3.10 Consume apply-layer applied-write evidence when available. C6 runtime/scorer code must not own the producer logic or a private apply engine; producer code belongs in apply/execution via §3.9a-d. AD: `AD-C6-010`. Decision cite: `D-144` partial G2 basis; `D-147` G2 wave closure; `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-11-ma14/reports/RATIFICATION-RECEIPT-pool32.md`.
- [ ] 3.11 Derive `unexpectedMutationKeys` in C6 replay from applied/final state versus expected keys and allowed dependency side effects. Do not pass C6 expected-state sets into `applyWithEvidence`. AD: `AD-C6-010`. Decision cite: `D-144` partial G2 basis; `D-147` G2 wave closure; `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-11-ma14/reports/RATIFICATION-RECEIPT-pool32.md`.
- [ ] 3.12 Enforce sign-or-block for pass^k, hardPassVariance, missing grader evidence, missing layer evidence, or receipt inconsistencies. AD: `AD-C6-004`. Decision cite: `D-144` partial G2 basis; `D-147` G2 wave closure; `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-11-ma14/reports/RATIFICATION-RECEIPT-pool32.md`.
- [ ] 3.13 Keep R-L17 route/candidate signoff as manual governance evidence in `docs/project/phase0/r-l17-human-review-evidence/`; do not add C24/runtime enums for those verdicts. Reserve future placeholder `add-route-verdict-verify-guard` for a lightweight bypass guard, but do not implement it here. AD: `AD-C6-005`. Decision cite: `D-144` partial G2 basis; `D-147` G2 wave closure; `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-11-ma14/reports/RATIFICATION-RECEIPT-pool32.md`.

## 4. Candidate Comparison Lane

- [ ] 4.1 Local precondition: a signed `retrain-c5-lora-d-domain` candidate exists and the comparison run is explicitly authorized. Decision cite: `D-144` partial G2 basis; `D-147` G2 wave closure; `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-11-ma14/reports/RATIFICATION-RECEIPT-pool32.md`.
- [ ] 4.2 Compare base and candidate with the same prompt, parser, mock-state, scoring, replay fingerprint, and contract bundle semantics. Decision cite: `D-144` partial G2 basis; `D-147` G2 wave closure; `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-11-ma14/reports/RATIFICATION-RECEIPT-pool32.md`.
- [ ] 4.3 Report C6 model-quality evidence without promoting it to endpoint readiness, demo-golden readiness, V-PASS, S-PASS, or U-PASS. AD: `AD-C6-006`. Decision cite: `D-144` partial G2 basis; `D-147` G2 wave closure; `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-11-ma14/reports/RATIFICATION-RECEIPT-pool32.md`.
- [ ] 4.4 Keep comparison final-only. Do not use release cases as checkpoint-selection oracle. AD: `AD-C6-003`. Decision cite: `D-144` partial G2 basis; `D-147` G2 wave closure; `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-11-ma14/reports/RATIFICATION-RECEIPT-pool32.md`.

## 5. Red Lines

- [ ] 5.1 Do not run training, C6 acceptance, D-domain base recalibration, golden-run, voice, endpoint readiness, or model-quality evaluation unless a later accepted task explicitly authorizes that proof class.
- [ ] 5.2 Do not modify Swift, C6 JSONL, Qwen tool format, model/data artifacts, or voice files during documentation absorption.
- [ ] 5.3 Do not import raw cockpit/customer text, PII, secrets, or "internal only" source material into bench cases.
- [ ] 5.4 Do not claim UIUE is merged or R-L17 is closed without live git/PR/state proof and the required human-owner evidence.
- [ ] 5.5 Apply-layer changes are limited to the §3.9a-d bounded upstream producer subtask. Any change beyond applied-write fact shape, such as new apply policy, soft errors, plan/validate/apply split, C6-private scorer logic, or `ScopedStateKey` struct promotion, requires a new accepted carrier or a new explicit grill decision.

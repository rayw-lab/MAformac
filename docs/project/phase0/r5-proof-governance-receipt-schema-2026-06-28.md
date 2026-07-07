---
retire_trigger: "Retire when superseded by archived OpenSpec specs or explicit user decision."
expires: "2026-08-15"
---

# UIUE R5 Proof-Governance Receipt Schema

Date: 2026-06-28
Status: `ACTIVE_FOR_R5_DISPATCH_RECONCILE`
Proof ceiling: `docs_local + receipt_consistency + local_static`

This schema is a UIUE receipt/checker contract for R5 governance receipts. It is not a mainline runtime schema, not a bridge payload, and not implementation authorization.

## Required Receipt Fields

Each R5 governance or reconcile receipt must include:

| field | rule |
| --- | --- |
| `command` | Every validation row records the exact command. |
| `surface_or_device` | Validation rows name the checked surface or use `non_device_docs_local` when no device was used. |
| `proof_class` | Allowed values for this dispatch are `docs_local`, `receipt_consistency`, and `local_static`. |
| `touched_paths` | Receipt lists owned paths and preserve-unowned paths separately. |
| `dirty_split` | UIUE dirty state and main reference dirty state are recorded separately. |
| `residual_risks` | Receipt carries unresolved risks or says `none_for_P0_P1`. |
| `live_HEAD` | UIUE branch/head and main reference branch/head are captured from live commands, not copied from stale dispatch text. |
| `non_claims_checkbox` | Receipt explicitly denies R5/runtime/mobile/true-device/voice/model/golden/endpoint/UIUE-merge/V/S/U/A-2 promotion. |
| `unresolved_P0_P1_carry_forward` | If any P0/P1 remains, it is listed with owner and next trigger. |

## Proof Promotion Checks

| check | falsifiable rule |
| --- | --- |
| `screenshot_no_promotion` | Any screenshot/simulator anchor can only be `docs_local`, `receipt_consistency`, `local_static`, or an explicitly lower visual proof. It cannot promote to runtime, mobile, true-device, V/S/U, or A-2 completion. |
| `forbidden_claim_grep` | Forbidden readiness phrases may appear only in a `non_claims`, `deny_list`, or explicit `does_not_claim` context. |
| `proof_enum_translation` | Internal proof enum/raw tokens must be mapped to UIUE-facing wording before customer-facing display. |
| `receipt_schema_required_fields` | Receipts must contain all fields in `Required Receipt Fields`. |
| `validation_gate_by_touched_paths` | Docs-only paths require OpenSpec/diff/schema checks; Swift/UIUE code paths require focused Swift tests; mainline reference requires separate read-only OpenSpec validation; simulator/runtime paths require explicit non-promotion wording. |
| `dual_repo_dirty_split` | UIUE dirty state and main dirty state are separate receipt fields; no mixed commit or staged path can combine both repos. |
| `live_head_required` | Receipt must record live UIUE and main heads from this run. |

## Validation Gate By Touched Paths

| touched path class | minimum gate |
| --- | --- |
| `docs_only` | `openspec validate ui-presentation --strict`, `git diff --check`, and receipt/schema checker. |
| `swift_uiue_code` | Focused `swift test --filter <touched-checker-or-feature-test>` plus `git diff --check`. |
| `mainline_read_only_reference` | `openspec validate define-runtime-presentation-bridge --strict` in `/Users/wanglei/workspace/MAformac`, recorded as read-only. |
| `openspec_touched` | Relevant `openspec validate <change> --strict`. |
| `simulator_or_screenshot_touched` | Screenshot/simulator evidence remains non-promoting and must not close runtime, mobile, true-device, V/S/U, or A-2 gates. |
| `runtime_or_device_touched` | Out of scope for this dispatch; stop or split to a future authorized lane. |

## Status Vocabulary

Allowed governance dispositions:

- `covered_by_governance_checker`
- `guarded_no_regression`
- `rewritten_as_falsifiable_rule`
- `deferred_to_mainline_owner`
- `spike_before_implementation`
- `merge_only_not_implemented`
- `human_review_only`
- `future_lane_non_claim`

Forbidden status promotion:

- `contract_aligned` does not mean merged.
- `consumer_mapping_ready` does not mean merged.
- Local/static/simulator evidence does not mean runtime, mobile, true-device, V/S/U, or A-2 acceptance.

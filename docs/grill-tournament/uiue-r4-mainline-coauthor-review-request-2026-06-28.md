---
status: pending_mainline_coauthor_receipt
artifact_kind: mainline_coauthor_review_request
date: 2026-06-28
uiue_repo: /Users/wanglei/workspace/MAformac-uiue
uiue_branch: uiue/phase4-default-scope-presentation
uiue_head: 4a4aabbacf0736e5ff6f137be4de6cf5c6d37cb5
mainline_repo: /Users/wanglei/workspace/MAformac
mainline_branch: codex/rebuild-c6-doc-absorption-20260624
mainline_head: de79c653685ff4835cc74b04106120b6e785e491
proof_class: docs/local + mainline_readonly_probe
non_claims: [no V-PASS, no mobile, no true_device, no runtime-ready, no voice-ready, no model-ready, no golden-ready, no endpoint-ready, no A-2 complete]
---

# UIUE R4 Mainline Co-Author Review Request

This is a request for mainline co-author review. It does **not** claim that mainline has accepted the UIUE bridge contract.

## Read-Only Mainline Probe

- Mainline cwd: `/Users/wanglei/workspace/MAformac`
- Mainline branch: `codex/rebuild-c6-doc-absorption-20260624`
- Mainline HEAD: `de79c653685ff4835cc74b04106120b6e785e491` (`de79c65`)
- Mainline bridge change dir `/Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-presentation-bridge/`: `missing`
- Mainline `docs/CURRENT.md` bridge route lines:

```text
75:2. If accepted, propose a thin `define-runtime-presentation-bridge` OpenSpec carrier before runtime/backend/UIUE implementation.
77:4. Keep full runtime/backend implementation after bridge contract acceptance and aligned with model/C6 proof.
78:5. Keep UIUE isolated unless state cells, C3-C6 fields, readback metadata, golden IDs, or bridge fields intersect.
96:| Runtime-Presentation bridge | not_proposed | Create and validate `openspec/changes/define-runtime-presentation-bridge/`; contract-only first. |
97:| C5 retrain | deferred | Requires accepted C5 child plan, physical entry gates, data generation authorization, and separate training proof. |
98:| C6 acceptance/comparison | deferred | Requires signed C5 candidate and explicit run authorization; Long-run 2 shape evidence is insufficient. |
99:| Runtime backend | deferred_but_not_absent | Thin bridge contract may proceed first; full backend implementation waits for accepted bridge plan and model/C6 alignment. |
100:| Voice/golden/UIUE | deferred | Requires stable state-cell/tool-card/C6/golden/readback IDs and separate proof classes. |
105:UIUE remains outside this mainline route unless state, C3-C6, readback, golden-run IDs, default-scope presentation contracts, or Runtime -> Presentation bridge fields conflict.
```

Interpretation: current mainline route truth remains `Runtime-Presentation bridge | not_proposed`; no mainline owner receipt was found in this run. Therefore C01/C03/C06/C18 remain `blocked_by_mainline_coauthor` in the R4 burndown ledger.

## UIUE Contract Source

- UIUE bridge change: `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/define-runtime-presentation-bridge/`
- Proposal states this is a shared contract for mainline review/co-authorship and mainline SHALL NOT independently create a second same-meaning bridge change.
- Design source references `docs/grill-checklist/uiue-runtime-bridge-decisions-2026-06-25.md` RPB-01~53 and AD-RPB-001~015.
- R4 classification table: `docs/grill-tournament/uiue-r4-pre-grill-classification-2026-06-28.md`.
- R4 burndown ledger: `docs/grill-tournament/uiue-r4-burndown-2026-06-28.md`.

## Co-Author Must Answer

1. Does mainline accept UIUE `define-runtime-presentation-bridge` as the shared contract authority?
2. Should mainline copy/migrate the same OpenSpec change, reference the UIUE bridge, or create a mainline proposal? If it creates a proposal, how does it avoid a second same-meaning SSOT?
3. If UIUE and mainline wording conflict, which file/change is SSOT and who resolves it?
4. If mainline does not accept the bridge, must UIUE R4 remain `blocked_by_mainline_coauthor` for C01/C03/C06/C18?
5. Does mainline accept the rule that it must not create a second synonym bridge SSOT?

## `scope_origin = missing` Decision State

Live-verified current source:

```swift
public enum ScopeOrigin: String, Codable, Equatable, Sendable {
    case defaulted
    case explicit
    case fanout
}
```

Bridge design says `missing` is bridge-proposed future addition, not current Core value. R4 options:

- Extend Core `ScopeOrigin` with `missing`.
- Create a presentation-only enum that can express missing/unresolvable while preserving Core enum.
- Delete bridge `missing` and express absent scope via existing origin plus explicit fail reason/result kind.
- Defer to R5 with non-claim and fail-closed rule.

Current decision: **pending / blocked_by_mainline_coauthor**. Without a mainline receipt, UIUE must not treat `missing` as locked.

## Current Request Status

- Mainline accepted: `no evidence found`.
- Current status: `pending_mainline_coauthor_receipt`.
- Ledger implication: related P0 rows are `blocked_by_mainline_coauthor`, not accepted.

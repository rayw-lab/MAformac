---
status: superseded_by_mainline_bridge_carrier
artifact_kind: mainline_coauthor_receipt
date: 2026-06-28
repo: /Users/wanglei/workspace/MAformac
branch: codex/rebuild-c6-doc-absorption-20260624
superseding_carrier: openspec/changes/define-runtime-presentation-bridge/
superseding_receipt: docs/project/phase0/mainline-runtime-presentation-bridge-unblock-2026-06-28.md
proof_class: docs/local + openspec_contract
authority: historical_receipt_superseded_by_mainline_visible_carrier
non_claims:
  - no runtime-ready
  - no mobile
  - no true_device
  - no voice-ready
  - no model-ready
  - no golden-ready
  - no endpoint-ready
  - no V-PASS
retire_trigger: "Retire when superseded by archived OpenSpec specs or explicit user decision."
expires: "2026-08-15"
---

# UIUE R4 Mainline Co-Author Receipt - Superseded

## 结论

这份 receipt 原本把 C01/C03/C06/C18 保持为 `deferred_with_owner_trigger`。2026-06-28 human review 已接受新的 unblock route，本 receipt 被主线 carrier 和 unblock receipt supersede：

- carrier: `openspec/changes/define-runtime-presentation-bridge/`
- unblock receipt: `docs/project/phase0/mainline-runtime-presentation-bridge-unblock-2026-06-28.md`

## Superseding Decision

- HR-01: accepted `create_mainline_visible_carrier_with_mapping`.
- HR-02: Core `ScopeOrigin` 不扩展 `missing`；missing/unresolved scope 通过 result/presentation metadata 或 explicit failure reason 表达。UI-local presentation-only label 只能作为展示 concern，不能变成 Core enum。
- HR-03: R5 只能在 bridge owner receipt/carrier 落主线后进入 dispatch readiness，不代表 runtime/mobile/model proof。

## C01 / C03 / C06 / C18 Disposition

| ID | Previous state | Superseding state | Proof ceiling |
|---|---|---|---|
| C01 | `deferred_with_owner_trigger` | closed for dispatch readiness by mainline-visible bridge carrier | docs/local + OpenSpec contract |
| C03 | `deferred_with_owner_trigger` | closed for dispatch readiness by no-second-same-meaning-SSOT mapping | docs/local + OpenSpec contract |
| C06 | `deferred_with_owner_trigger` | closed for dispatch readiness by no-Core-`missing` disposition | docs/local + OpenSpec contract |
| C18 | `deferred_with_owner_trigger` | closed for dispatch readiness by route-board move to proposed/active carrier | docs/local + OpenSpec contract |

## Non-Claims Preserved

This supersession does not claim runtime backend implementation, C5 retrain, C6 acceptance/comparison, model-quality evaluation, golden-run, voice readiness, endpoint readiness, mobile/true-device proof, UIUE merge, V-PASS, S-PASS, or U-PASS.

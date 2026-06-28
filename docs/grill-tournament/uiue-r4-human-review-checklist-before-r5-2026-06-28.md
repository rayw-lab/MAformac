---
status: human_review_decisions_recorded
artifact_kind: human_review_checklist
date: 2026-06-28
proof_class: docs/local
human_reviewed_by: leige
human_reviewed_at: 2026-06-28
---

# UIUE R4 Human Review Checklist Before R5

## Human Review Decision Receipt

2026-06-28 磊哥正式接受 HR-01/HR-02/HR-03 的 recommended unblock route:

- HR-01: accept `create_mainline_visible_carrier_with_mapping`.
- HR-02: reject direct Core enum expansion for `scope_origin=missing`; use `remove_missing_use_fail_reason` as the mainline/shared carrier route, with `presentation_only_enum` allowed only as a UI-local display concern if needed.
- HR-03: accept `allow_after_bridge_owner_receipt`.

This records human review direction only. It does not claim mainline implementation, mainline acceptance, R5 readiness, V-PASS, mobile, true_device, runtime-ready, voice-ready, model-ready, golden-ready, endpoint-ready, or A-2 complete.

## Post-Review Mainline Carrier Note

Mainline commit `9ba609a13fdf311546f20561081c4a9bb858d0fc` landed the accepted HR-01/HR-02/HR-03 route through `/Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-presentation-bridge/` and `/Users/wanglei/workspace/MAformac/docs/project/phase0/mainline-runtime-presentation-bridge-unblock-2026-06-28.md`. This changes HR-01/HR-02/HR-03 from R5 overall blockers to dispatch-readiness closed notes. HR-04 through HR-07 remain pending human/product review and remain non-blocking for overall R5.

| item id | source path | why human/L3 review is needed | available evidence | decision options | recommended default | effect if accepted | effect if rejected/deferred | whether it blocks R5 | non-claims to preserve |
|---|---|---|---|---|---|---|---|---|---|
| HR-01-mainline-bridge-authority | `/Users/wanglei/workspace/MAformac/docs/project/phase0/mainline-runtime-presentation-bridge-unblock-2026-06-28.md` | shared bridge authority needed mainline owner ratification | mainline `docs/CURRENT.md`; mainline unblock receipt; Step 4 ledger | `adopt_uiue_bridge` / `create_mainline_visible_carrier_with_mapping` / `reject_for_now` | `create_mainline_visible_carrier_with_mapping` accepted by human review | C01/C03 closed for dispatch readiness by mainline commit `9ba609a13fdf311546f20561081c4a9bb858d0fc` | R5 dispatch readiness can proceed with notes | no | UIUE docs are not mainline runtime acceptance |
| HR-02-scope-origin-missing | `/Users/wanglei/workspace/MAformac/docs/project/phase0/mainline-runtime-presentation-bridge-unblock-2026-06-28.md` | missing/unresolved scope needed an accepted shared route | mainline carrier spec; mainline unblock receipt | `extend_core` / `presentation_only_enum` / `remove_missing_use_fail_reason` / `defer_to_later` | no Core enum expansion; use `remove_missing_use_fail_reason`, with UI-local `presentation_only_enum` only if needed | C06 closed for dispatch readiness; Core `ScopeOrigin` remains `defaulted/explicit/fanout` | R5 dispatch readiness can proceed with notes | no | no claim that Core `missing` is accepted |
| HR-03-mainline-roadmap-alignment | `/Users/wanglei/workspace/MAformac/docs/project/phase0/mainline-runtime-presentation-bridge-unblock-2026-06-28.md` | mainline route board needed owner-visible proposed carrier state | mainline `docs/CURRENT.md`; mainline unblock receipt | `allow_after_bridge_owner_receipt` / `keep_blocked` | `allow_after_bridge_owner_receipt` accepted by human review | C18 closed for dispatch readiness after bridge owner receipt exists | R5 dispatch readiness can proceed with notes | no | no claim that runtime/mobile proof exists |
| HR-04-long-press-console | `/Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r1-r3-residual-disposition-before-r5-2026-06-28.md` | 属于产品/交互策略，不是单纯工程实现 | R3 residual disposition; existing Settings button behavior | `button_only` / `long_press_only` / `both` | `both` | 可定义后续 R5 local interaction lane | 仅阻塞该 lane，不阻塞整体 R5 once mainline clears | no | no claim that long-press works today |
| HR-05-summary-direct-touch | `/Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r1-r3-residual-disposition-before-r5-2026-06-28.md` | summary / gear 是否允许 direct touch 需要产品判断 | residual disposition; historical burndown | `display_only` / `direct_touch_with_guard` / `split_policy` | `split_policy` | 可定义后续 direct-touch implementation lane | 仅阻塞该 lane | no | no claim that direct touch is complete |
| HR-06-capsule-final-art | `/Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r1-r3-residual-disposition-before-r5-2026-06-28.md` | 审美判断，不应由 local proof 自动通过 | residual disposition; R3/R4 notes | `carry_notes` / `open_visual_polish_lane` | `open_visual_polish_lane` | 进入 later visual polish lane | 保持 notes，不阻塞整体 R5 | no | no final-art complete claim |
| HR-07-white-edge-threshold | `/Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r1-r3-residual-disposition-before-r5-2026-06-28.md` | 当前 checker 仍是 `WARN`，threshold 未 formalize | R0-R2 burndown; residual disposition | `formalize_threshold` / `keep_warn` / `remove_assertion_later` | `keep_warn` until threshold is explicit | 后续可把 visual lane 从 WARN 收敛 | 保持 WARN，不阻塞整体 R5 | no | WARN must not be relabeled PASS |

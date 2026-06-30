---
status: r4_exit_ledger_post_mainline_unblock
artifact_kind: docs_local_exit_burndown_ledger
date: 2026-06-28
repo: /Users/wanglei/workspace/MAformac-uiue
branch: uiue/phase4-default-scope-presentation
head_before_update: eed57f4109c851ea93a7ede7488cb50a0090c2f1
mainline_unblock_commit: 9ba609a13fdf311546f20561081c4a9bb858d0fc
proof_class: docs/local + local + unit + simulator/mock
non_claims: [no V-PASS, no mobile, no true_device, no runtime-ready, no voice-ready, no model-ready, no golden-ready, no endpoint-ready, no A-2 complete]
---

# UIUE R4 Exit Burndown Ledger

## 结论

这份 ledger 把历史 `uiue-r4-burndown-2026-06-28.md` 转成 R5 dispatch-readiness ledger。Step 1/2/3 已把主线 gate、local proof pack、R1-R3 residual disposition 收敛成本轮可复用的 proof/defer basis。2026-06-28 mainline commit `9ba609a13fdf311546f20561081c4a9bb858d0fc` 落地主线 carrier 后，C01/C03/C06/C18 只对 **dispatch readiness** 关闭。当前仍不得把任何 UIUE 文档或 simulator/mock 证明写成 mainline/runtime/mobile/true_device/V-PASS。

## Inputs

- Step 1 mainline co-author receipt: `/Users/wanglei/workspace/MAformac/docs/project/phase0/uiue-r4-mainline-coauthor-receipt-2026-06-28.md`
- Step 2 local proof receipt: `/Users/wanglei/workspace/MAformac-uiue/Reports/uiue-r4-exit-preconditions-20260628/step2-local-proof-receipt.md`
- Step 3 residual disposition: `/Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r1-r3-residual-disposition-before-r5-2026-06-28.md`
- Historical classification baseline: `/Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-pre-grill-classification-2026-06-28.md`
- Historical human review packet: `/Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-human-review-packet-2026-06-28.md`
- Mainline unblock receipt: `/Users/wanglei/workspace/MAformac/docs/project/phase0/mainline-runtime-presentation-bridge-unblock-2026-06-28.md`
- Mainline carrier spec: `/Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md`

## Mechanical Checks

- C01-C50 count: 50
- mainline co-author rows C01/C03/C06/C18 are `closed_for_dispatch_readiness` by commit `9ba609a13fdf311546f20561081c4a9bb858d0fc`
- R5 deferred rows stay `not_R5_blocker`; they define future lanes, not current completion claims
- `WARN` / `simulator_debug_override` boundaries are preserved through Step 3 disposition

## Ledger

| ID | Owner | Bucket | Exit status | Proof path or defer reason | Blocks R5 overall? |
|---|---|---|---|---|---|
| C01 | mainline commander / runtime contract owner | `mainline co-author` | closed_for_dispatch_readiness | /Users/wanglei/workspace/MAformac/docs/project/phase0/mainline-runtime-presentation-bridge-unblock-2026-06-28.md + mainline commit `9ba609a13fdf311546f20561081c4a9bb858d0fc` | no |
| C02 | evidence / receipt owner | `evidence checklist` | resolved_with_proof | /Users/wanglei/workspace/MAformac-uiue/Reports/uiue-r4-exit-preconditions-20260628/step2-local-proof-receipt.md | no |
| C03 | mainline commander / runtime contract owner | `mainline co-author` | closed_for_dispatch_readiness | /Users/wanglei/workspace/MAformac/docs/project/phase0/mainline-runtime-presentation-bridge-unblock-2026-06-28.md + mainline carrier `/Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-presentation-bridge/` | no |
| C04 | UIUE bridge contract owner | `bridge schema` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-pre-grill-classification-2026-06-28.md + /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-human-review-packet-2026-06-28.md | no |
| C05 | UIUE bridge contract owner | `bridge schema` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-pre-grill-classification-2026-06-28.md + /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-human-review-packet-2026-06-28.md | no |
| C06 | mainline commander / runtime contract owner | `mainline co-author` | closed_for_dispatch_readiness | /Users/wanglei/workspace/MAformac/docs/project/phase0/mainline-runtime-presentation-bridge-unblock-2026-06-28.md; no Core `missing` enum claim | no |
| C07 | UIUE bridge contract owner | `bridge schema` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-pre-grill-classification-2026-06-28.md + /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-human-review-packet-2026-06-28.md | no |
| C08 | UIUE bridge contract owner | `bridge schema` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-pre-grill-classification-2026-06-28.md + /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-human-review-packet-2026-06-28.md | no |
| C09 | evidence / receipt owner | `evidence checklist` | resolved_with_proof | /Users/wanglei/workspace/MAformac-uiue/Reports/uiue-r4-exit-preconditions-20260628/step2-local-proof-receipt.md | no |
| C10 | UIUE bridge contract owner | `bridge schema` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-pre-grill-classification-2026-06-28.md + /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-human-review-packet-2026-06-28.md | no |
| C11 | UIUE bridge contract owner | `bridge schema` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-pre-grill-classification-2026-06-28.md + /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-human-review-packet-2026-06-28.md | no |
| C12 | UIUE bridge contract owner | `bridge schema` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-pre-grill-classification-2026-06-28.md + /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-human-review-packet-2026-06-28.md | no |
| C13 | test harness owner | `evidence checklist` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/Reports/uiue-r4-exit-preconditions-20260628/step2-local-proof-receipt.md | no |
| C14 | R5 voice lane owner with explicit non-claim | `R5 deferred` | not_R5_blocker | /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r1-r3-residual-disposition-before-r5-2026-06-28.md | no |
| C15 | evidence / receipt owner | `evidence checklist` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/Reports/uiue-r4-exit-preconditions-20260628/step2-local-proof-receipt.md | no |
| C16 | UIUE bridge contract owner | `bridge schema` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-pre-grill-classification-2026-06-28.md + /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-human-review-packet-2026-06-28.md | no |
| C17 | R5 runtime lane owner with explicit non-claim | `R5 deferred` | not_R5_blocker | /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r1-r3-residual-disposition-before-r5-2026-06-28.md | no |
| C18 | mainline commander / roadmap owner | `mainline co-author` | closed_for_dispatch_readiness | /Users/wanglei/workspace/MAformac/docs/CURRENT.md records `Runtime-Presentation bridge | proposed_active_contract_only` after commit `9ba609a13fdf311546f20561081c4a9bb858d0fc` | no |
| C19 | R5 model lane owner with explicit non-claim | `R5 deferred` | not_R5_blocker | /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r1-r3-residual-disposition-before-r5-2026-06-28.md | no |
| C20 | evidence / receipt owner | `evidence checklist` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/Reports/uiue-r4-exit-preconditions-20260628/step2-local-proof-receipt.md | no |
| C21 | test harness owner | `evidence checklist` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/Reports/uiue-r4-exit-preconditions-20260628/step2-local-proof-receipt.md | no |
| C22 | mainline commander / roadmap owner | `mainline co-author` | accepted_with_notes | /Users/wanglei/workspace/MAformac/docs/project/phase0/uiue-r4-mainline-coauthor-receipt-2026-06-28.md | no |
| C23 | UIUE bridge contract owner | `bridge schema` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-pre-grill-classification-2026-06-28.md + /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-human-review-packet-2026-06-28.md | no |
| C24 | test harness owner | `evidence checklist` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/Reports/uiue-r4-exit-preconditions-20260628/step2-local-proof-receipt.md | no |
| C25 | evidence / receipt owner | `evidence checklist` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/Reports/uiue-r4-exit-preconditions-20260628/step2-local-proof-receipt.md | no |
| C26 | evidence / receipt owner | `evidence checklist` | resolved_with_proof | /Users/wanglei/workspace/MAformac-uiue/Reports/uiue-r4-exit-preconditions-20260628/step2-local-proof-receipt.md | no |
| C27 | UIUE bridge contract owner | `bridge schema` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-pre-grill-classification-2026-06-28.md + /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-human-review-packet-2026-06-28.md | no |
| C28 | test harness owner | `evidence checklist` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/Reports/uiue-r4-exit-preconditions-20260628/step2-local-proof-receipt.md | no |
| C29 | UIUE bridge contract owner | `bridge schema` | resolved_with_proof | /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-pre-grill-classification-2026-06-28.md + /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-human-review-packet-2026-06-28.md | no |
| C30 | mainline commander / roadmap owner | `mainline co-author` | accepted_with_notes | /Users/wanglei/workspace/MAformac/docs/project/phase0/uiue-r4-mainline-coauthor-receipt-2026-06-28.md | no |
| C31 | UIUE visual policy owner | `visual policy` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r1-r3-residual-disposition-before-r5-2026-06-28.md | no |
| C32 | UIUE bridge contract owner | `bridge schema` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-pre-grill-classification-2026-06-28.md + /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-human-review-packet-2026-06-28.md | no |
| C33 | UIUE visual policy owner | `visual policy` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r1-r3-residual-disposition-before-r5-2026-06-28.md | no |
| C34 | 磊哥 / product decision | `user decision` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r1-r3-residual-disposition-before-r5-2026-06-28.md | no |
| C35 | UIUE visual policy owner | `visual policy` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r1-r3-residual-disposition-before-r5-2026-06-28.md | no |
| C36 | evidence / receipt owner | `evidence checklist` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/Reports/uiue-r4-exit-preconditions-20260628/step2-local-proof-receipt.md | no |
| C37 | UIUE visual policy owner | `visual policy` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r1-r3-residual-disposition-before-r5-2026-06-28.md | no |
| C38 | evidence / receipt owner | `evidence checklist` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/Reports/uiue-r4-exit-preconditions-20260628/step2-local-proof-receipt.md | no |
| C39 | test harness owner | `evidence checklist` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r1-r3-residual-disposition-before-r5-2026-06-28.md | no |
| C40 | UIUE bridge contract owner | `bridge schema` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-pre-grill-classification-2026-06-28.md + /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-human-review-packet-2026-06-28.md | no |
| C41 | UIUE bridge contract owner | `bridge schema` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-pre-grill-classification-2026-06-28.md + /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-human-review-packet-2026-06-28.md | no |
| C42 | UIUE visual policy owner | `visual policy` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r1-r3-residual-disposition-before-r5-2026-06-28.md | no |
| C43 | UIUE visual policy owner | `visual policy` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r1-r3-residual-disposition-before-r5-2026-06-28.md | no |
| C44 | UIUE visual policy owner | `visual policy` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r1-r3-residual-disposition-before-r5-2026-06-28.md | no |
| C45 | test harness owner | `evidence checklist` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/Reports/uiue-r4-exit-preconditions-20260628/step2-local-proof-receipt.md | no |
| C46 | test harness owner | `evidence checklist` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r1-r3-residual-disposition-before-r5-2026-06-28.md | no |
| C47 | test harness owner | `evidence checklist` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/Reports/uiue-r4-exit-preconditions-20260628/step2-local-proof-receipt.md | no |
| C48 | evidence / receipt owner | `evidence checklist` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/Reports/uiue-r4-exit-preconditions-20260628/step2-local-proof-receipt.md | no |
| C49 | evidence / receipt owner | `evidence checklist` | accepted_with_notes | /Users/wanglei/workspace/MAformac-uiue/Reports/uiue-r4-exit-preconditions-20260628/step2-local-proof-receipt.md | no |
| C50 | UIUE bridge contract owner | `bridge schema` | resolved_with_proof | /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-pre-grill-classification-2026-06-28.md + /Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-human-review-packet-2026-06-28.md | no |

## Pending Human Review Rows

| Topic | Related rows | Owner | Decision needed | Options | Blocks R5 overall? |
|---|---|---|---|---|---|
| 长按 1.5 秒进入演绎控制台 | C34/C35/C36 | 磊哥 | 是否保留仅按钮入口，还是引入长按手势，或者两者并存 | `button_only` / `long_press_only` / `both` | no |
| summary direct-control / gear direct touch | C31/C35/C46 | 磊哥 | 是否开放 direct touch，还是保持仅展示/跳转 | `display_only` / `direct_touch_with_guard` / `split_summary_gear_policy` | no |
| capsule final-art | C33/C42/C43 | 磊哥 | 是否把 final-art 当 later visual polish lane 继续推进 | `carry_notes` / `open_visual_polish_lane` | no |
| white-edge formal threshold | C26/C36/C38/C48/C49 | 磊哥 | 是否 formalize threshold，或保留 WARN，不得写 PASS | `formalize_threshold` / `keep_warn` / `remove_assertion_later` | no |

## Carry-Forward Rules

1. Step 4 的历史 mainline blocker 已由后续 mainline unblock receipt supersede；本 ledger 只把 C01/C03/C06/C18 关闭到 dispatch readiness。
2. Step 4 不把 Step 2 local proof pack 升格成 runtime/mobile/true_device/mainline acceptance。
3. Step 4 不把 Step 3 residual 改写成“已完成”；只把它们变成后续 lane/backlog 的清晰入口。
4. 若 Step 5/6 要引用本 ledger，必须同时保留 proof class 与 non-claims。
5. Phase1 consumer grill receipt `/Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r5-phase1-consumer-grill-2026-06-28.md` 只新增 docs/local consumer mapping 与 lane classification；不改变本 ledger 的 runtime/mobile/true_device/V-PASS non-claims。

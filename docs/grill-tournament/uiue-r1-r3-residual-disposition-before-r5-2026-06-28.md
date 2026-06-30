---
status: residual_disposition_before_r5
artifact_kind: docs_local_disposition_table
date: 2026-06-28
repo: /Users/wanglei/workspace/MAformac-uiue
branch: uiue/phase4-default-scope-presentation
head: 5d3df555d80b949df4bd1bb23773e218dd95daf0
proof_class: docs/local + local + unit + simulator/mock
non_claims:
  - no V-PASS
  - no mobile
  - no true_device
  - no runtime-ready
  - no voice-ready
  - no model-ready
  - no golden-ready
  - no endpoint-ready
  - no A-2 complete
---

# UIUE R1-R3 Residual Disposition Before R5

## 结论

Step 3 的目标不是把 R1-R3 residual 做完，而是把它们从“历史 note”收敛成 **有 owner、有 proof gap、有 trigger、明确是否阻塞 R5 overall start** 的 disposition。结论是：在本轮已明确主线 blocker 仍留给 Step 1 的前提下，下面这些 R1-R3 residual **均不单独阻塞 R5 overall start**；它们要么定义 R5 lane，要么保留为 `accepted_with_notes` / `deferred_with_owner` / `pending_human_review`。

## Status Vocabulary Used Here

- `accepted_with_notes`: 已有 route 和 non-claim，允许带 note 进入下一步，不等于实现完成
- `deferred_with_owner`: 后续 lane/owner 明确，但当前不做
- `not_R5_blocker`: 这是 R5 要做的工作，不阻塞 R5 起步
- `resolved_with_proof`: 仅用于 residual 的 route/decision 已被当前证据足够证明
- `still_blocks_R5`: 当前表中无此项；若出现必须在 Step 6 继续阻断

## Disposition Table

| Residual | Primary source | Current proof / gap | Disposition status | `pending_human_review` | Blocks R5 overall? | Owner / next trigger | Recommended options / note |
|---|---|---|---|---|---|---|---|
| runtime-driven orb binding | `docs/grill-tournament/uiue-r3-residual-routing-to-r4-r5-2026-06-28.md:21` | 仅证明 `SnapshotPreset -> PresentationSnapshot.orbState -> DemoOrbView`，未证明 ASR/LLM/router/runtime binding | `not_R5_blocker` | no | no | R5 runtime/voice lane owner；Step 6 可把它列成 lane candidate | 保持 seam/non-claim；R5 再补 runtime adapter、logs、fixtures |
| 复杂推理 -> `think` | `docs/grill-tournament/uiue-r3-residual-routing-to-r4-r5-2026-06-28.md:22` | 当前只有 presentation `think` mock，未证明 backend intent-router semantics | `not_R5_blocker` | no | no | R5 runtime/model lane owner | 保持 “presentation think != LLM reasoning proof”；R5 再定义 thinking lifecycle |
| 长按 1.5 秒进入演绎控制台 | `docs/grill-tournament/uiue-r3-residual-routing-to-r4-r5-2026-06-28.md:23`; `docs/grill-tournament/uiue-r0-r2-grill-burndown-2026-06-27.md:65` | 现有 live code 只有 Settings panel button；长按手势未实现/未证明 | `deferred_with_owner` | yes, owner=`磊哥` | no | product/visual policy owner；若 R5 收进 lane，再由 implementation owner 接手 | 选项：1) 保持仅按钮入口 2) 增加 1.5s 长按 3) 两者并存；默认建议 `两者并存但不在本轮实现` |
| 44pt / VoiceOver | `docs/grill-tournament/uiue-r3-residual-routing-to-r4-r5-2026-06-28.md:24`; `docs/grill-tournament/uiue-r0-r2-grill-burndown-2026-06-27.md:108-109` | 只有 visual acceptance scope；44pt target proof 和 VoiceOver alternate entry 仍 open | `deferred_with_owner` | no | no | R5 true-device/mobile/a11y lane owner | 不从 visual screenshot 推 accessibility readiness；后续要真机/系统辅助功能 proof |
| 完整 10-family interaction matrix | `docs/grill-tournament/uiue-r3-residual-routing-to-r4-r5-2026-06-28.md:25`; `docs/grill-tournament/uiue-r0-r2-grill-burndown-2026-06-27.md:50`, `:182` | 代表性 anchor 已覆盖，full matrix 仍 open | `not_R5_blocker` | no | no | R5 implementation/evidence owner | 当前 route 已明；后续 family-by-family fixtures/tests 补齐 |
| summary direct-control / gear direct touch | `docs/grill-tournament/uiue-r3-residual-routing-to-r4-r5-2026-06-28.md:26`; `docs/grill-tournament/uiue-r0-r2-grill-burndown-2026-06-27.md:154` | broader direct-touch readiness 未关闭；当前只有 route，没有 proof | `deferred_with_owner` | yes, owner=`磊哥` | no | visual policy / product owner；若批准再进 R5 implementation lane | 选项：1) 保持只 summary 展示 2) 开 direct touch 但带 safety/disabled 3) gear/summary 分离；默认建议 `先明确 policy，再实现` |
| capsule final-art | `docs/grill-tournament/uiue-r3-residual-routing-to-r4-r5-2026-06-28.md:27`; `docs/grill-tournament/uiue-r0-r2-grill-burndown-2026-06-27.md:53` | 已明确是 residual/non-claim，不是 bridge schema blocker | `accepted_with_notes` | yes, owner=`磊哥` | no | design/art lane owner | 选项：1) 保持 notes 进入 R5 2) 提升为 R5 visual polish lane；默认建议 `进入 visual polish lane，不阻断 R5 start` |
| white-edge formal threshold | `docs/grill-tournament/uiue-r3-residual-routing-to-r4-r5-2026-06-28.md:28-29`; `docs/grill-tournament/uiue-r0-r2-grill-burndown-2026-06-27.md:51`, `:60`, `:189` | checker 仍是 `WARN`，threshold 未 formalize | `accepted_with_notes` | yes, owner=`磊哥` | no | evidence/design owner | 选项：1) formalize threshold 2) 保留 WARN 但禁止写 PASS 3) 移除该 checker assertion；默认建议 `保留 WARN + formalize threshold in later lane` |
| Reduce Motion true-device/system-setting proof | `docs/grill-tournament/uiue-r3-residual-routing-to-r4-r5-2026-06-28.md:30`; `docs/grill-tournament/uiue-r0-r2-grill-burndown-2026-06-27.md:49` | 当前 proof class 仅 `simulator_debug_override + unit`，非真机系统设置 | `deferred_with_owner` | no | no | R5 true-device/mobile/a11y lane owner | 维持 non-claim；如果 R5 要出真机/a11y lane，再单独补系统设置 proof |

## Explicit Non-Blocker Decision

- 上表 residual 都不是 “R5 不能开始” 的 blocker。
- 真正仍可能影响 R5 overall start 的，是 Step 1/Step 4/Step 5 里更高层的 mainline / ledger / closeout gate，而不是这些 residual 本身。
- 这些 residual 定义的是 **R5 要承接的 lane backlog**，不是 R5 前必须先完成的 gate。

## Human Review Queue Introduced By Step 3

| Item | Why human review is needed | Owner | Blocks R5 overall? | Recommended default |
|---|---|---|---|---|
| 长按 1.5 秒进入演绎控制台 | 属于产品入口设计，不是单纯技术实现 | 磊哥 | no | 两者并存：保留按钮入口，后续再决定是否加长按 |
| summary direct-control / gear direct touch | 触及 direct-control policy 和 affordance 边界 | 磊哥 | no | 先定 policy，再实现 |
| capsule final-art | 审美/设计判断，当前无技术 blocker | 磊哥 | no | 进入 later visual polish lane |
| white-edge formal threshold | 阈值需要设计/审美拍板，不能把 `WARN` 伪写成 `PASS` | 磊哥 | no | 保留 `WARN`，后续 formalize threshold |

## Carry-Forward Rules Into Step 4/5/6

1. `WARN` stays `WARN`; do not relabel as `PASS`.
2. `simulator_debug_override` stays simulator proof; do not relabel as true-device proof.
3. `pending_human_review` means decision still needed, not implementation complete.
4. Residual lane candidates may be listed in Step 6, but Step 6 must not claim those lanes are already solved.

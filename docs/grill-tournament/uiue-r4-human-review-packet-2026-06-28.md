---
status: r4_human_review_packet_ready
artifact_kind: human_review_packet
date: 2026-06-28
repo: /Users/wanglei/workspace/MAformac-uiue
branch: uiue/phase4-default-scope-presentation
head: 4a4aabbacf0736e5ff6f137be4de6cf5c6d37cb5
proof_class: docs/local
non_claims: [no V-PASS, no mobile, no true_device, no runtime-ready, no voice-ready, no model-ready, no golden-ready, no endpoint-ready, no A-2 complete]
---

# UIUE R4 Human Review Packet

This packet is for 磊哥 human review of the R4 pre-grill classification and routing work. It is not an R4 closeout and not a runtime/mobile readiness claim.

## Current Truth Summary

- Repo: `/Users/wanglei/workspace/MAformac-uiue`
- Branch: `uiue/phase4-default-scope-presentation`
- HEAD at packet creation: `4a4aabbacf0736e5ff6f137be4de6cf5c6d37cb5`
- `8.C2` is closed at `openspec/changes/ui-presentation/tasks.md:112` with single `[x]` row.
- R3 verdict: `PASS_WITH_NOTES / R3_8C2_closed`; proof scope is UIUE simulator/mock visual acceptance only.
- `8.A`, A-2 overall, R1/R2b full readiness, runtime bridge implementation, voice, model, mobile, true-device, golden, endpoint, and V-PASS remain separate.

## Source Pool

| Source | Role | Proof class / boundary |
| --- | --- | --- |
| `Reports/uiue-8c2-r3-closeout-20260628/closeout.md` | R3 closeout and non-claims | receipt; simulator/mock scope only |
| `docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/pre-human-l3-package/r3-closeout-20260628/r3-evidence-index.md` | R3 evidence index | simulator_l0_runtime_truth / simulator_debug_override / local metrics |
| `docs/loop-competition/2026-06-28-uiue-r4-bridge-grill-matrix/final-grill-matrix-v2.md` | R4 v2 50-question source matrix | planning / audit checklist only |
| `docs/grill-tournament/uiue-r4-pre-grill-classification-2026-06-28.md` | C01-C50 classification table | docs/local routing table |
| `docs/grill-tournament/uiue-r3-residual-routing-to-r4-r5-2026-06-28.md` | R3 residual routing table | docs/local routing table |
| `openspec/changes/define-runtime-presentation-bridge/design.md` + `tasks.md` + spec | Bridge contract design source | contract/design only; no Swift implementation claim |
| `docs/grill-tournament/uiue-r0-r2-grill-burndown-2026-06-27.md` | R0-R2/R3 residual and burndown history | local/docs + human_review notes |
| `docs/CURRENT.md` | Current route board | router only, not SSOT |
| external/mainline route truth | Mainline co-author context only if consulted | external to UIUE proof; not UIUE runtime proof |

## Human Review Instructions

Review:
- Whether every C01-C50 item is classified into exactly one allowed bucket.
- Whether P0 items have an acceptable R4 route, owner, artifact expectation, and fail-closed rule.
- Whether P1 items may carry notes without hiding a R4 blocker.
- Whether R3 residuals are routed without fake-green or proof-class overclaim.
- Whether C50 prevents UI details from bloating the bridge schema without classification.

Do not review as completed implementation:
- Runtime-driven orb binding, backend intent route, complex reasoning, voice, model, mobile, true-device, golden, endpoint, and full a11y readiness are not claimed here.
- Long-press 1.5s -> 演绎控制台 is not claimed implemented; it is routed as user decision / visual policy / later implementation.

## Review Questions

### P0

- C01: bucket `mainline co-author`, route `R4-mainline-coauthor`. Question: R4 是否已经锁定 Runtime-Presentation bridge 的单一合同权威，并把 UIUE 已接受 bridge change 与 mainline 路线牌仍写 `not_proposed` / `deferred` 的差异收敛成一个不再分叉的 SSOT？
- C02: bucket `evidence checklist`, route `R4-evidence`. Question: R3 8.C2 人审带 notes 通过后，R4 是否明确区分 `operator-pass with notes`、UIUE visual evidence、bridge contract acceptance、mainline runtime acceptance 和 R5 readiness？
- C03: bucket `mainline co-author`, route `R4-mainline-coauthor`. Question: mainline co-author review 是否有明确 owner、输入文件、输出 receipt、阻断条件和冲突处理路径，特别是 UIUE 已推进而 mainline 仍未吸收 bridge 路线时？
- C04: bucket `bridge schema`, route `R4-contract`. Question: `PresentationSnapshot` 的最小字段、可选字段、默认值和 `missing/unknown` fail-closed 行为是否足以驱动 UIUE 卡片、胶囊、orb、readback 与证据截图，而不是回退到 raw store 推断？
- C05: bucket `bridge schema`, route `R4-contract`. Question: `DemoRuntimeResult.result_kind` 是否用机器可读枚举覆盖 accepted、refused、partial accept/refuse、already-state no-op、cancelled、runtime error 等终态，并能映射到 mixed outcome UI？
- C06: bucket `mainline co-author`, route `R4-mainline-coauthor`. Question: `scope_origin` 当前 Core 三态与 bridge 提议的 `missing` 第四态是否有显式兼容策略，避免把 default scope、用户显式范围、fanout 和缺失范围混成一个 UI 状态？
- C08: bucket `bridge schema`, route `R4-contract`. Question: readback 的来源、proof class、scope、per-action result 和最终文案是否有单一数据路径，保证 UI 卡片、胶囊、TTS 文案和 evidence receipt 不各自重算？
- C09: bucket `evidence checklist`, route `R4-evidence`. Question: R4 是否定义有限 `proof_class` 枚举、显示上限和降级规则，明确 UIUE simulator/mock 截图不能被解释为 runtime、mobile、true-device、voice 或 V-PASS？
- C10: bucket `bridge schema`, route `R4-contract`. Question: mixed outcome 场景下，bridge 是否能同时表达 active cell、refused cell、sibling cells、per-action results 和 readback，避免 UI 只显示一个全局成功或失败？
- C16: bucket `bridge schema`, route `R4-contract`. Question: UIUE adapter 是否被限制为 mock snapshot/fixture 到 `PresentationSnapshot` 的消费端，禁止直接读取 runtime store、C3 trace、raw command 或 mainline backend 私有结构？
- C17: bucket `R5 deferred`, route `R5-runtime`. Question: mainline runtime 将来如何把 C3/C3ExecutionResult/TraceEntry 投影到 `DemoRuntimeResult` 是否有最小兼容草图，同时不让 R4 反向改写 C3 或 C6 行为合同？
- C18: bucket `mainline co-author`, route `Mainline-roadmap`. Question: R4 与 post-C6 identity/behavior-shape rebuild 的重叠是否拆清：bridge 只承载 presentation contract，不负责 C6 acceptance、behavior taxonomy 完成或模型质量判定？
- C19: bucket `R5 deferred`, route `R5-model`. Question: R4 是否明确 C5 retrain、LoRA candidate、demo golden、voice golden 和 endpoint readiness 都是 R5/mainline 后续门，不因 bridge schema 存在而自动解锁？
- C21: bucket `evidence checklist`, route `R4-test-harness`. Question: bridge 对 timeout、cancel、runtime_error、unsupported action、安全拒绝和部分拒绝是否都有 terminal snapshot 要求，避免异常路径只有成功态 UI 证据？
- C26: bucket `evidence checklist`, route `R4-evidence`. Question: R4 证据是否要求每份 receipt 标注 repo、branch、HEAD、dirty ownership 和 proof class，尤其在 UIUE 与 mainline worktree 同时推进时防止串证？
- C27: bucket `bridge schema`, route `R4-contract`. Question: bridge schema 是否有版本号、fixture 兼容策略和破坏性变更规则，能支持 R4 checklist、R5 runtime adapter 和后续 mainline tests 并行演进？
- C28: bucket `evidence checklist`, route `R4-test-harness`. Question: R4 测试计划是否拆成 schema、fixture、unit、simulator、evidence、contract validation 的最小门，并避免一个不可复跑的 `make verify-all` 式大一统门？
- C29: bucket `bridge schema`, route `R4-contract`. Question: R4 exit criteria 是否写清：哪些 P0/P1 grill 必须 burndown，哪些 notes 可以带入，哪些 runtime/voice/model lanes 必须另开任务而不能混在 R4？
- C31: bucket `visual policy`, route `R4-visual-policy`. Question: R4 是否需要一张 UIUE zone ownership/evidence 表，说明顶部 context/capsule、orb/thinking、dialogue/readback、vehicle controls、mic dock、overlay/sheet 各自消费哪些 snapshot 字段、哪些只属 visual policy、哪些需要 evidence，而不是把 zone manifest 升格成第二 bridge SSOT？
- C33: bucket `visual policy`, route `R4-visual-policy`. Question: 跨 zone 注意力链是否可验：卡片状态变化、readback/TTS 文案、orb thinking/speaking、context capsule ambient、edge burst 不能同时抢主焦点，且 reduce motion 下仍保留状态语义？
- C35: bucket `visual policy`, route `R4-visual-policy`. Question: mic 按住说话、长按思考、卡片 tap 展开、温度条 drag、车控区 scroll、对话区 scroll、overlay dismiss 和设置按钮之间是否有 gesture arbitration 规则，避免手势串扰？
- C36: bucket `evidence checklist`, route `R4-evidence`. Question: 演绎控制台入口是否被标明为 demo/operator surface，而不是用户车控能力；从 settings、长按或其他入口进入都不得改变 runtime/voice readiness 结论？
- C38: bucket `evidence checklist`, route `R4-evidence`. Question: context capsule 是否禁止展示 raw speed/gear 数字但允许展示行驶/雨/夜等语境，并用证据证明它守住 `vehicle.* not rendered as control` 的红线？
- C40: bucket `bridge schema`, route `R4-contract`. Question: 演绎控制台 force context、macro scene、reset normal 是否产生完整 snapshot lifecycle：context、activeCells、readbacks/dialogue、orb/voice state、proofClass 和 stale visual clearing 同步？
- C42: bucket `visual policy`, route `R4-visual-policy`. Question: reset/theme/preset 切换后，cards、orb、capsule、dialogue、mic dock 和 overlay 是否有 stale-state clearing 规则，防止上一轮 active/refused/thinking/pressing 视觉残留？
- C45: bucket `evidence checklist`, route `R4-test-harness`. Question: z-order/hit-testing 是否成为 R4 corner case：ambient burst 不挡交互，mic dock 不遮最后一行卡片，expanded overlay 拦截背景 tap，capsule invisible hit area 不吞 settings/refresh？
- C46: bucket `evidence checklist`, route `R4-test-harness`. Question: accessibility 是否按 zone 明确：每个可点/可调/可展开/可关闭区域有稳定 identifier、label/value、VoiceOver 路径，温度 scrub 有 adjustable 替代，long press 有非手势替代？
- C47: bucket `evidence checklist`, route `R4-test-harness`. Question: reduce motion 是否按 zone 出证据：orb、capsule、edge burst、waveform、card breathing、hero/fade、sheet transition 均降级为静态但可读状态，而不是只截一张图？
- C49: bucket `evidence checklist`, route `R4-evidence`. Question: 对动效时序、长按 progress、crossfade、stale clearing 等时间性声明，R4 evidence 是否需要视频/时间点/多帧截图，而不是只靠静态 screenshot 或 UI tree frame？
- C50: bucket `bridge schema`, route `R4-contract`. Question: 哪些 UI 细节进 bridge schema、哪些进 visual policy、哪些只进 evidence checklist 是否需要一张分类表，防止四区动效/车辆样式/演绎入口把 R4 bridge 膨胀成 UI 实现总表？

### P1

- C07: bucket `bridge schema`, route `R4-contract`. Question: R1/R2 的 `default_scope`、`scope_origin`、action availability、disabled reason 和可操作集合是否被 bridge 携带到 presentation，而不是只停留在 UIUE 本地 interaction policy 测试？
- C11: bucket `bridge schema`, route `R4-contract`. Question: 空调制冷/制热、座椅通风/加热、车窗等 sibling state 是否通过 bridge snapshot 表达互斥关系和当前态，避免视觉层继续硬编码推断？
- C12: bucket `bridge schema`, route `R4-contract`. Question: `source`、`scope_origin`、`scope`、`readback.source` 和 `trace_id` 的概念边界是否拆清，防止来源、范围解析、证据链和运行时 trace 在 R5 互相污染？
- C13: bucket `evidence checklist`, route `R4-test-harness`. Question: force-context 事件里的车速、挡位、天气、时间段等 demo 条件是否限定在 bridge event/fixture 范围内，并禁止被误读为真实车辆状态或 live API 输入？
- C14: bucket `R5 deferred`, route `R5-voice`. Question: `voice_state`、`orb_state`、thinking 或胶囊动画字段是否被定义为 presentation choreography，并明确不构成 ASR、TTS、voice golden、endpoint 或 voice-ready 证据？
- C15: bucket `evidence checklist`, route `R4-evidence`. Question: R4 是否解释 cards start changing、readback ready、TTS start/end、timeout/cancel 等两段 thinking 语义，避免 R5 把 UI 演出时序误当 runtime 执行时序？
- C20: bucket `evidence checklist`, route `R4-evidence`. Question: `trace_id`、`turn_id`、snapshot version 和 evidence receipt 是否稳定到足以让 UIUE 截图、unit fixture、simulator capture 和 mainline runtime logs 对同一轮 replay 对齐？
- C22: bucket `mainline co-author`, route `Mainline-roadmap`. Question: R4 是否保留 MAformac 离线、端侧、无云依赖、mock 车控边界和三轮记忆约束，不把 bridge 扩成线上 API、持久化服务或真实车控执行层？
- C23: bucket `bridge schema`, route `R4-contract`. Question: graph manifest、visual evidence manifest、capability IDs 和 route tables 是否被标明为 derived/index artefacts，而不是第二套 authority 或替代 bridge/OpenSpec 合同？
- C24: bucket `evidence checklist`, route `R4-test-harness`. Question: R1 interaction integrity 的 action availability、disabled reason、writeback 和 no-op 规则是否能通过 bridge 被 UI 观察，而不是只靠按钮本地禁用态实现？
- C25: bucket `evidence checklist`, route `R4-evidence`. Question: R2/R2b 的布局、胶囊、小圆球/orb、多主题和 reduce motion 状态是否能从 bridge presentation fields 或显式 visual policy 解释，而不是散落在主题分支逻辑中？
- C30: bucket `mainline co-author`, route `Mainline-roadmap`. Question: Liquid4All、外部 H5/FastAPI、旧 demo bridge 或参考实现是否全部限定为参考材料，并禁止把其字段、样式或 runtime 假设直接复制进 MAformac/UIUE 合同？
- C32: bucket `bridge schema`, route `R4-contract`. Question: 每个 zone 是否都有明确的状态来源：context capsule 读 `context`、orb 读 `orbState`、mic 读 `voiceState`、dialogue 读 `dialogText/readbacks`、cards 读 `storeCells/activeCells/refusedCell`，缺来源时 fail-closed？
- C34: bucket `user decision`, route `R4-user-decision`. Question: 若产品决定支持 1.5 秒长按进入思考/演绎控制台，R4 是否定义触发 zone、progress feedback、取消半径、松手行为、reduce motion/a11y 替代入口，并与 mic 按住说话区分？
- C37: bucket `visual policy`, route `R4-visual-policy`. Question: 顶部车辆样式/环境 capsule 跟随端状态时，speed/gear、weather、time_period、macro scene、reset normal、safety refusal 等冲突是否有显示优先级？
- C39: bucket `evidence checklist`, route `R4-test-harness`. Question: 顶部 capsule、设置、刷新、Dynamic Island/safe area 的布局是否需要固定 zone-pair evidence，证明其不遮挡、不吞手势、不进入 capsule 图像？
- C41: bucket `bridge schema`, route `R4-contract`. Question: macro 场景一次改变多个 family 时，bridge 是否表达 per-action active cells、per-action readbacks、ambient burst 触发和最终综合文案，避免一个 `accepted` 压扁多 zone 变化？
- C43: bucket `visual policy`, route `R4-visual-policy`. Question: 手动滚动与自动 scroll-to-active 是否有 R4 policy：用户正在滚 vehicle controls 或 dialogue 时不得被 active family 自动拉回，系统触发 active 且用户未滚时才滚入视野？
- C44: bucket `visual policy`, route `R4-visual-policy`. Question: active family hero/fade、expanded overlay、dismiss tap 和 card writeback 是否证明空间记忆不被破坏：不物理重排、不丢 activeCell、不把 overlay 局部 state 当全局 store？
- C48: bucket `evidence checklist`, route `R4-evidence`. Question: Mac panorama 与 iPhone portrait 的 zone topology 是否分别验收，同一 PresentationSnapshot 在两种布局下不产生 proof-class 互相替代？

## Stop / Pass Rules

Stop / return to executor if any of these are true:
- A C01-C50 row is missing, duplicated, or classified outside the allowed buckets.
- C50 is not accepted as the governance gate for UI detail classification.
- Any document claims V-PASS, mobile, true_device, runtime-ready, voice-ready, model-ready, golden-ready, endpoint-ready, or A-2 complete.
- A P0 item has no route/owner/artifact expectation or hides implementation debt as complete.
- `8.C2` status is no longer a single `[x]` row, or `8.A` is implied complete from `8.C2`.

Pass with notes is acceptable if:
- All 50 rows are present and routed.
- P0 items have explicit route/artifact/non-claim guardrails, even when implementation is deferred.
- P1 items are explicitly allowed to carry notes or are routed to R5/later.
- R3 residuals remain visible and are not relabeled as implemented.

## Non-Claims

- no V-PASS
- no mobile
- no true_device
- no runtime-ready
- no voice-ready
- no model-ready
- no golden-ready
- no endpoint-ready
- no A-2 complete


## Post-Review Result

磊哥 has human-reviewed this R4 packet and passed it for the next non-code preimplementation step: R4 burndown ledger setup. This does not authorize R4 implementation, R4 closeout, or any runtime/mobile/readiness claim.

Follow-up artifacts:

- `docs/grill-tournament/uiue-r4-burndown-2026-06-28.md`
- `docs/grill-tournament/uiue-r4-mainline-coauthor-review-request-2026-06-28.md`

## Next After Human Review

- If human review passes: create the R4 pending burndown list from accepted P0/P1 routes, keeping C50 as the gate.
- If human review is partial: mark blockers by Cxx ID and route them back to `bridge schema`, `visual policy`, `evidence checklist`, `mainline co-author`, `R5 deferred`, or `user decision` owner.
- Do not close additional OpenSpec tasks or declare any runtime/mobile/readiness milestone from this packet alone.


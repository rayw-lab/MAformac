# R4 Supplemental Round 01 BLUE Review - UI Corner Cases

## Persona

BLUE = HMI / interaction / visual-stage reviewer.

我的判断标准不是 bridge schema 越大越好，而是：R4 必须把客户现场能看见、摸到、误触到、被动效误导到的 UIUE 舞台风险说清楚；同时不能把纯视觉 policy 反向膨胀成 runtime 合同。

本轮 verdict：C31-C50 里没有应直接删除的题，但有多项需要合并或改写。最高优先保留的是 zone topology、gesture arbitration、context capsule 状态优先级/红线、stale clearing、scroll/overlay/z-order、reduce motion/a11y 和多帧 evidence。

## Scope Read

已完整读取指定输入：

- `supplement-ui-cornercases/contract.md`：116 行，确认本轮是 fixed blind-set，proof class 仅为 planning / audit checklist，禁止 claim V-PASS/mobile/true-device/runtime-ready 等。
- `supplement-ui-cornercases/candidates-blind.md`：33 行，覆盖 C31-C50。
- `supplement-ui-cornercases/deductive-gap-analysis.md`：38 行，确认 gap 来自 zone topology、gesture routes、context capsule、macro lifecycle、scroll/focus/overlay、a11y/reduce motion、platform/evidence。

按 contract source pool 读取的关键证据：

- `docs/loop-competition/2026-06-28-uiue-r4-bridge-grill-matrix/final-grill-matrix.md:19-44`：C01-C30 已覆盖 proof class、snapshot 字段、voice/orb choreography、R2/R2b visual policy，但 C25 仍偏总括。
- `docs/uiue-storyboard-grill-decisions.md:454-483`：SD22 已锁 z-order、双滚动、手动滚暂停 auto-scroll、mic dock inset；这些多数是 UIUE visual policy，不应全塞进 bridge schema。
- `docs/uiue-storyboard-grill-decisions.md:501-519`：a11y 曾被 deferred，mic short/long、barge-in、driving context、reset/theme crossfade 是客户现场 failure 风险。
- `docs/uiue-storyboard-grill-decisions.md:523-555`：SD24 已锁顶部居中 context capsule、设置/刷新外置、capsule 最低 ambient、行驶 > 雨 > 夜 > 常态优先级。
- `docs/uiue-storyboard-grill-decisions.md:559-588`：SD25 已锁 diorama、四维 context composite、A vs C-lite route、真机/FPS spike 不可由静态图替代。
- `openspec/changes/define-runtime-presentation-bridge/design.md:69-83`：AD-RPB-014 要求 force context 通过 bridge event，暴露 `vehicle{speed, gear}` + `environment{weather,time_period}`，但 demo-mode isolated。
- `Core/Presentation/PresentationSnapshot.swift:55-99`：当前 snapshot 有 `storeCells/activeCells/refusedCell/scopeOrigins/context/orbState/voiceState/dialogText/readbacks/resultKind/proofClass`，但没有 explicit zone manifest、attention sequence 或 gesture route。
- `Core/Presentation/PresentationReducedMotionPolicy.swift:3-37`：reduce motion policy 只有 orb/motion feedback 和 continuous/particles 开关，未形成 per-zone parity 表。
- `Core/Presentation/StateCellInteractionPolicy.swift:16-74`：已有 cell gesture/writeback/proofClass 投影，但不是跨 zone gesture arbitration。
- `App/ContentView.swift:70-137`、`:140-176`、`:179-193`：舞台实际分为背景/atmosphere、top capsule、orb、dialogue、vehicle cards、mic dock、overlay/sheet，且 Mac/iPhone topology 不同。
- `App/ContentView.swift:238-284`：capsule wrapper、mic safe-area、expanded overlay hit handling 已存在，但需要 R4 evidence 化。
- `App/ContentView.swift:402-510`：force context、normal reset、macro 会写 context/cards/dialogue/proofClass，但 readbacks/orb/voice/stale clearing 不完整。
- `App/ContentView.swift:894-935`、`:1546-1710`：dialogue 和 vehicle cards 都有手动滚动保护，但规则需要进入 R4 evidence，不能只靠代码存在。
- `App/ContentView.swift:1040-1083`、`:2318-2355`：mic long-press visual feedback、temperature scrub adjustable 已有，但没有 1.5s 思考/演绎入口合同。
- `App/ContextCapsule.swift:19-35`、`:323-329`：capsule 读 speed/gear/weather/time，且 accessibility label 当前暴露 raw speed/gear 数字。这是 C38 必须改写收紧的直接证据。
- `App/DemoControlPanel.swift:83-140`、`:184-230`：演绎控制台能 force speed/gear/weather/time 和 macro，必须被标为 operator/demo surface。

Source pool residual：contract 列出的 `openspec/changes/define-runtime-presentation-bridge/specs/ui-presentation/spec.md` 当前路径不存在；本评审未读取 `round-01/brain-1.md`、`round-01/brain-2.md`、`round-02/*` 或 judge 文件。

## Keep

- C31：必须保留。当前实现已有多 zone 舞台，但 snapshot 没有 zone manifest；R4 不定义 topology 会让 R5 接线只看字段、不看舞台 ownership。
- C33：必须保留。SD24 把 capsule 定为最低 ambient，卡片/TTS/orb/capsule 的注意力链必须可验，否则客户会看到多处同时抢戏。
- C35：必须保留。mic press、card tap、temperature drag、dialogue scroll、vehicle scroll、overlay dismiss、settings sheet 是真实并存手势，不是一条 interaction policy 能覆盖。
- C37/C38：必须保留且收紧。capsule 是客户理解安全拒识的舞台证据，但 raw speed/gear 不能客户可见；当前 `ContextCapsule` a11y label 暴露数字，是真实风险。
- C40/C42：必须保留。force context / macro / reset 如果不清 stale state，会把上一轮 active/refused/thinking/pressing 残留带进下一轮演示。
- C43/C45：必须保留。滚动和 z-order 是已锁设计点，也已有代码落点；R4 需要把它们变成 evidence checklist。
- C46/C47：必须保留。a11y 曾被 deferred，但 R4 至少要规定 demo minimum；reduce motion 不能只截一张图。
- C48/C49：必须保留。Mac panorama 与 iPhone portrait 不能互相替代；动效、long press progress、crossfade、clearing 需要多帧/时间点证据。
- C50：必须保留。它是防止 supplement 把 R4 bridge 变成 UI 实现总表的刹车。

## Delete

不建议直接删除任何 C31-C50。

最低分项也不应删，因为它们覆盖真实 HMI failure surface；问题是要合并或改写边界，而不是丢掉。

## Merge

- C31 + C32 可合并为一个「zone manifest + source map」门：C31 讲 zone ownership，C32 讲字段来源，分开容易重复。
- C40 + C41 可合并为「macro/force/reset lifecycle」组：C41 的 per-action active/readback 是 C40 lifecycle 的子要求。
- C43 + C44 可合并为「focus/scroll/spatial memory」组：都在问 active-driven focus 不破坏用户空间记忆。
- C39 可并入 C45 或 R2b evidence：顶部 capsule/settings/refresh/safe-area 的 pair 证据很重要，但它本质是 hit-testing/layout integrity，不该单独扩大 R4 schema。
- C46 可和 C34/C35 部分交叉：long press 替代入口、scrub adjustable、button labels 应在 gesture/a11y 矩阵里互相引用。

## Rewrite

- C34：把「长按 1.5 秒进入思考/演绎控制台」改成「若保留该入口，必须独立于 mic PTT，并证明 progress/cancel/a11y/operator-only」。当前代码只看到 mic 的 `onLongPressGesture(minimumDuration: 0.05)`，没有 1.5s 思考入口。
- C36：改写为「所有演绎控制台入口必须 operator-only 且不得进入 customer-facing proof」。现在设置页下有「演绎控制台」，必须防止客户现场误解为车辆能力。
- C38：必须显式包括 VoiceOver / accessibility text 也不得泄露 raw speed/gear 数字。当前视觉 wrapper 隐藏了 `ContextCapsuleView`，但 `ContextCapsuleView` 自身 label 暴露 speed/gear；后续谁若取消 hidden 会踩红线。
- C41：从「一个 accepted 压扁多 zone」改成「per-action result/readback/active family 的 evidence 表」，避免要求 UI 一定同时展示每个 action 的动画细节。
- C47：改成 per-zone reduce-motion parity checklist：orb、capsule、edge burst、waveform、card breathing、hero/fade、sheet transition 各自写静态语义，不要求所有细节进 bridge。
- C49：补上 proof class cap：视频/多帧只证明 UI choreography，不证明 runtime readiness、voice readiness 或真机 FPS。
- C50：要求分类表三列即可：bridge schema / visual policy / evidence checklist；不要把每个动画参数都合同化。

## Missing Risks

- 客户可见 demo failure：设置页里的演绎控制台和 force speed/gear 如果被客户看见，容易把 demo fixture 误读为真实车控能力；C36/C40 应提升语气。
- a11y 红线不只是合规：VoiceOver label、identifier、debug sheet、AllStateSheet 都可能暴露 raw vehicle state；C38/C46 应覆盖可访问文本和 operator sheet。
- Reduce motion 现在只有通用 policy，缺 zone-by-zone parity；单张 reduce-motion 截图无法证明 waveform、capsule、edge burst、hero/fade 都降级正确。
- Context capsule 的 source priority 与 composite 仍有文档分歧：SD24 写「优先级单显」，SD25/AD-RPB-014 写四维 composite/可叠加；C37 需要逼出 resolved scene policy。
- Macro 场景会一次改多 family，但当前 readbacks 没同步扩展；C41 如果不保留，客户看到多卡变化却只有一句泛文案。
- 现有 scroll protection 有 fixed sleep window；R4 evidence 应验证用户手动滚、系统 active、对话新消息三者时序，而不是只看代码有 flag。
- 多平台 proof 容易串证：Mac panorama 的左右分栏没有 mic safe-area 问题，iPhone portrait 有；C48 必须禁止互相替代。
- 动效 evidence 缺少时间轴：long press progress、0.4s capsule crossfade、320ms reset/theme fade、stale clearing 都需要时间点/多帧，不是静态 UI tree 可证明。

## Scores

| ID | Score | BLUE action |
| --- | ---: | --- |
| C31 | 5 | keep |
| C32 | 4 | merge with C31 |
| C33 | 5 | keep |
| C34 | 4 | rewrite |
| C35 | 5 | keep |
| C36 | 4 | rewrite |
| C37 | 5 | keep |
| C38 | 5 | rewrite |
| C39 | 3 | merge |
| C40 | 5 | keep |
| C41 | 4 | merge/rewrite |
| C42 | 5 | keep |
| C43 | 5 | keep |
| C44 | 4 | merge |
| C45 | 5 | keep |
| C46 | 4 | rewrite |
| C47 | 5 | rewrite |
| C48 | 5 | keep |
| C49 | 5 | keep/rewrite proof cap |
| C50 | 5 | keep/rewrite as table |

## Candidate Notes

| ID | BLUE note |
| --- | --- |
| C31 | Essential. Current UI has top capsule/orb/dialogue/cards/mic/overlay/sheet, and Mac/iPhone arrange them differently. R4 needs zone topology plus owner/proof class, not just "consume snapshot". |
| C32 | Strong but should merge with C31. Snapshot fields exist, but the useful artifact is a source map from zone to field/policy, including which zones are visual-only. |
| C33 | Essential. Attention priority is a customer-facing failure mode: card change, readback, orb speak/think, capsule ambient, edge burst cannot all be primary. Reduce motion must retain semantic priority. |
| C34 | Strong but needs rewrite. I found mic long press visual feedback at 0.05s, not the 1.5s thinking/演绎入口. If the 1.5s route remains, it needs a separate operator-only/a11y/cancel contract. |
| C35 | Essential. Existing code has button, long press, high-priority temperature drag, two ScrollViews, overlay tap dismiss, settings sheet. Without arbitration, HMI bugs will look like runtime flakiness. |
| C36 | Strong. DemoControlPanel is reachable through settings in debug/demo mode and can force context/macro. It must be labelled operator surface and cannot support runtime readiness claims. |
| C37 | Essential. SD24 says priority single-display while SD25/AD-RPB-014 say four-dimensional composite. R4 must force a resolved visual policy for conflicts: speed/gear/weather/time/macro/reset/refusal. |
| C38 | Essential and must be stricter. Visual stage should show "行驶/雨/夜" context, not raw speed/gear. Current capsule accessibility label includes speed and gear; candidate must cover accessible/customer-visible text, not just pixels. |
| C39 | Useful but too narrow as standalone. Top capsule/settings/refresh/safe-area pair evidence belongs under layout/hit-testing evidence and should merge with C45/R2b, with R4 only owning source/proof linkage. |
| C40 | Essential. Force context, macro, reset must produce lifecycle evidence across context/cards/dialogue/orb/voice/proofClass/clearing. Current reset/macro code updates only part of that surface. |
| C41 | Strong but should merge into C40. Macro multi-family changes need per-action active/readback evidence; avoid making UI show every action separately if one composite readback is the intended HMI. |
| C42 | Essential. Reset/theme/preset after active/refused/thinking/pressing is a classic demo failure. This should include sheet dismissal, mic pressing, ambient burst and expanded overlay stale state. |
| C43 | Essential. SD22 already states user scroll must pause auto-scroll. Current code has flags for dialogue/cards; R4 needs evidence across manual scroll + active update + new readback timing. |
| C44 | Strong but can merge with C43. Spatial memory is HMI-critical: hero/fade/expanded overlay must not physically reorder or turn overlay-local state into store truth. |
| C45 | Essential. z-order/hit-testing affects real touch success. Ambient burst uses allowsHitTesting(false), expanded overlay dismisses on background, mic dock uses safe-area; all need fixed evidence. |
| C46 | Strong and should be rewritten as demo-minimum a11y. Earlier docs deferred full VoiceOver, but current code already has identifiers/labels/adjustable scrub; long press alternative and stable labels still need a checklist. |
| C47 | Essential. Reduce motion is currently policy-level and partial. The item should require per-zone proof: orb/capsule/waveform/edge burst/card breathing/hero/sheet each maps to static readable state. |
| C48 | Essential. Mac panorama and iPhone portrait are different zone topologies. A Mac capture cannot prove iPhone mic dock/safe-area/scroll behavior; an iPhone capture cannot prove Mac split focus. |
| C49 | Essential with proof cap. Multi-frame/video/timepoint evidence is necessary for choreography, progress, crossfade and stale clearing, but it remains UI evidence only. |
| C50 | Essential. This is the guardrail against schema bloat. The accepted matrix should require a classification table: bridge schema vs visual policy vs evidence checklist. |

## Residual Risk

- This is a blind Round 01 BLUE review; I intentionally did not read other reviewer/judge outputs.
- I did not run UI tests or simulator; proof class remains planning / audit checklist only.
- The current worktree is dirty with many unrelated modified/untracked files; this review did not distinguish ownership beyond not touching them.
- One contract-listed source file path was missing, so any spec text that only exists there is not represented in this review.
- Because this is HMI-focused, scoring may overweight customer-visible demo failure versus backend/schema purity; controller should reconcile with RED/GREEN/PURPLE/ORANGE/BLACK.

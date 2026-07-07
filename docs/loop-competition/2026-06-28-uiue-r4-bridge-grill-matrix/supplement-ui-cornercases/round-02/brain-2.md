## Persona

ORANGE reviewer：test and harness engineer。我的盲评标准不是“问题听起来重要”，而是它能否被稳定、分层、可复跑地验证：UI tree frame、screenshot crop、多帧/视频、unit/fixture、a11y identifier、reduce-motion screenshot、negative path、simulator proof 与 true-device proof 必须各归其位。

结论：C31-C50 大体应该保留，但不能全部写成 bridge schema。最危险的确认偏误是把 UIUE 的舞台细节全塞进 R4 bridge；正确落点应拆成三类：bridge snapshot 字段、explicit visual policy、evidence checklist。

## Scope Read

- 已完整读取 `contract.md`、`candidates-blind.md`、`deductive-gap-analysis.md`。
- 按 source pool 读取并核对了 R4 原矩阵、R0-R2 矩阵、UIUE 定档/landing/storyboard、`PresentationSnapshot`、`PresentationReducedMotionPolicy`、`StateCellInteractionPolicy`、`ContentView`、`ContextCapsule`、`DemoControlPanel`、`define-runtime-presentation-bridge` design/spec。
- 未读取 `round-01/*`、`round-02/brain-1.md`、`round-02/brain-3.md` 或 judge 内容。
- 证据约束：本轮 proof class 仅为 planning / audit checklist；不能声明 V-PASS、mobile、true-device、runtime-ready、voice-ready、model-ready、golden-ready、endpoint-ready 或 `8.C2` closure。
- source pool 中列出的 `openspec/changes/define-runtime-presentation-bridge/specs/ui-presentation/spec.md` 当前不存在；实际存在的是 `specs/runtime-presentation-bridge/spec.md`。这应作为 source-pool hygiene residual，不影响本轮盲评。

## Keep

- C31、C33、C35、C38、C40、C42、C45、C46、C47、C49、C50 保留为核心项。
- C31/C33/C35 是 harness 的骨架：没有 zone topology、attention chain 和 gesture arbitration，就无法设计 UI tree、截图、多帧和 negative path 的最小验收矩阵。
- C38/C45/C46/C47 是 fake-green 防线：raw vehicle state、hit-testing、a11y、reduce motion 都容易被“看起来能跑”的 simulator 截图掩盖。
- C49/C50 是出站纪律：动画时序必须用多帧/视频或时间点证据，schema 与 visual policy 的分类表必须防止 R4 变成 UI 实现总表。

## Delete

- 不建议直接删除任何候选。
- 最接近删除的是 C39：它作为独立 R4 问题偏弱，容易重复 R2b layout checker；但 top capsule/settings/refresh/safe-area 的固定 zone pair 对 evidence manifest 仍有价值，应合并而非删除。

## Merge

- C31 + C32：合成“zone topology + state-source map”。C31 管 zone/owner/proof class，C32 管字段/visual policy 来源；避免两条都要求 bridge 字段。
- C34 + C35：长按思考、mic press、card tap、drag、scroll、overlay dismiss、settings route 应进入同一 gesture arbitration matrix，但 C34 保留独立 long-press 1.5s progress/a11y 替代检查。
- C37 + C38：context capsule 的优先级和 vehicle redline 可同组，但 C38 必须保留负例：UI tree/screenshot 不得渲染 raw speed/gear 为控制项。
- C40 + C41 + C42：force context / macro / reset normal 属于 snapshot lifecycle 组。C41 是 macro 多 action 的展开，C42 是 stale clearing negative path。
- C43 + C44 + C45：scroll/focus/overlay/z-order 属于 spatial integrity 组，但 C45 的 hit-testing 风险应保留为 P0 子门。
- C46 + C47：a11y 和 reduce motion 可以共用 zone matrix，但 proof 不同，不能互相替代。
- C48 + C49：平台拓扑和多帧/视频 evidence 可进入同一 evidence harness 章节，分别标注 simulator、desktop、mobile、true_device proof cap。

## Rewrite

- C32：改成“每个 zone 必须声明来源类别：bridge snapshot field / visual policy / evidence-only，而不是默认新增 bridge 字段”。
- C34：补上 negative path：未达到 1.5s、超出取消半径、与 mic 按住说话重叠时不得误进演绎控制台。
- C36：明确演绎控制台是 demo/operator surface；验证目标是 proof cap 和 route isolation，不是用户车控能力。
- C39：改写为“固定 zone pair evidence”：capsule vs settings/refresh、capsule vs safe area、Dynamic Island/safe area 只要求 UI tree frame + screenshot crop，不重开审美门。
- C41：要求 per-action active cell/readback 的 fixture，不要求所有 macro 视觉细节进入 schema。
- C47：不要写“一张 reduce-motion 图”；应按 orb/capsule/edge burst/waveform/card/sheet 分 zone 出静态语义 proof。
- C50：改为最终分类表 hard gate：schema / visual policy / evidence-only / deferred true-device 四列。

## Missing Risks

- 缺少“证据采样协议”：哪些候选用 UI tree 足够，哪些必须 crop，哪些必须多帧/视频。建议 C49 承接并强制分层。
- 缺少“negative path fixture”清单：timeout/cancel/refusal/unsupported/already-state、长按取消、gesture collision、stale clearing 都需要失败态样本。
- 缺少“a11y identifier uniqueness”门：R0-R2 已指出 identifier 查错元素风险，C46 应显式要求唯一性和 wrong-element guard。
- 缺少“reduce transparency”相邻风险：C47 只提 reduce motion，但玻璃/高光状态也可能在 reduce transparency 下丢语义。
- 缺少“true-device-only residual”标识：capsule video loop、glass/material、GPU/FPS、safe area/Dynamic Island 在 simulator 过了也不能写 true-device pass。
- 缺少“operator/demo controls 不污染 customer surface”的截图和 UI tree 负证据：C36/C40 应证明 settings/demo control 入口不改变 runtime readiness 结论。

## Scores

| ID | Score | Verdict |
| --- | ---: | --- |
| C31 | 5 | Keep |
| C32 | 4 | Merge/Rewrite |
| C33 | 5 | Keep |
| C34 | 4 | Merge/Rewrite |
| C35 | 5 | Keep |
| C36 | 4 | Rewrite |
| C37 | 4 | Merge |
| C38 | 5 | Keep |
| C39 | 3 | Merge |
| C40 | 5 | Keep |
| C41 | 4 | Merge/Rewrite |
| C42 | 5 | Keep |
| C43 | 4 | Keep |
| C44 | 4 | Keep |
| C45 | 5 | Keep |
| C46 | 5 | Keep |
| C47 | 5 | Keep |
| C48 | 4 | Keep |
| C49 | 5 | Keep |
| C50 | 5 | Keep |

## Candidate Notes

| ID | Note |
| --- | --- |
| C31 | 必留。`PresentationSnapshot` 有 context/orb/voice/dialog/readbacks/active/refused/proof 字段，但没有显式 zone manifest；harness 需要 zone -> owner -> source -> proof class 表。 |
| C32 | 强项但需合并 C31。验证方式应是 fixture + UI tree assertion：每个 zone 指向 snapshot 字段或 visual policy，不能用 View 本地推断冒充 bridge。 |
| C33 | 必留。注意力链需要多帧/视频和 reduce-motion 双版本；单张 screenshot 不能证明 card/readback/orb/capsule 没同时抢焦点。 |
| C34 | 保留但改写。长按思考的 1.5s progress、取消半径、松手语义、a11y 替代入口都应可测；当前 mic 是 0.05s long press visual feedback，容易和思考入口混淆。 |
| C35 | 必留。gesture arbitration 要用 negative path：mic press、long press、tap、drag scrub、dialogue scroll、vehicle scroll、overlay dismiss、settings sheet 互不吞事件。 |
| C36 | 保留为 proof-boundary 项。演绎控制台、settings、force context、macro 必须标为 demo/operator surface；测试应断言不产生 runtime-ready/voice-ready 文案。 |
| C37 | 有价值但和 C38 合组。context 优先级已有 storyboard 决策，harness 应覆盖 driving/rain/night/reset/safety refusal 的优先级 fixture。 |
| C38 | 必留。需要 UI tree + screenshot crop 负证据：可表达“行驶/雨/夜”语境，但不得把 `vehicle.speed/gear` 当可控卡片或 raw 数字展示。 |
| C39 | 弱独立项，合并到 fixed zone pair evidence。UI tree frame 足够覆盖 capsule/settings/refresh/safe-area gap，截图 crop 用于人眼确认，不应重开 R2b 审美门。 |
| C40 | 必留。force context、macro、reset normal 应产生完整 terminal snapshot lifecycle；unit fixture 可检查 context/active/readback/orb/voice/proof/stale clearing。 |
| C41 | 保留但合并 C40。macro 多 family 改动必须有 per-action active cells/readbacks；否则一个 `accepted` 会压扁多区变化。 |
| C42 | 必留。stale-state clearing 是高风险回归：reset/theme/preset 后 active/refused/thinking/pressing/overlay 都要 negative path proof。 |
| C43 | 保留。代码已有 `isUserScrolling` 抑制 auto scroll 的形态，测试应分别覆盖 user scroll 不拉回、system active 才 scroll-to-active。 |
| C44 | 保留。spatial memory 应用 screenshot crop + UI tree + fixture 验证：不物理重排、不丢 activeCell、overlay 局部 state 不写成全局 store。 |
| C45 | 必留。z-order/hit-testing 要用 UI test + frame/crop：ambient burst `allowsHitTesting(false)`、overlay 拦截背景、mic dock 不遮最后卡片、capsule hit area 不吞按钮。 |
| C46 | 必留。每个 zone 的 identifier/label/value/adjustable/close path 都是 harness 可测面；long press 必须有非手势替代，且 identifier 要查唯一性。 |
| C47 | 必留。reduce motion 应按 zone 产出静态但可读状态；orb/capsule/edge burst/waveform/card/sheet 各自证明，不能用一张总图替代。 |
| C48 | 保留。Mac panorama 与 iPhone portrait 的 topology 不可互相代证；同一 snapshot 应分别有 simulator/desktop proof，并显式标注非 mobile/true_device。 |
| C49 | 必留。动效时序、long-press progress、crossfade、stale clearing 需要多帧/视频/时间点；UI tree 只能证明结构，不证明时间行为。 |
| C50 | 必留为总闸。最终必须有 schema / visual policy / evidence-only / deferred true-device 分类表，防止 R4 bridge 被 UI 动效、车辆样式和演绎入口膨胀。 |

## Residual Risk

- 本轮没有运行测试，也不应运行实现验收；结论是盲评 planning/audit checklist。
- 没有读取被禁 round/judge 文件，因此无法判断其它 reviewer 是否已有相同意见；这是盲评要求带来的正常 residual。
- 当前评分偏向 testability：产品/本体论价值可能需要 BLACK/PURPLE 另行校正。
- 若 controller 后续合并矩阵，建议把每个 accepted item 附 proof recipe，否则 C31-C50 会变成“说得对但不可执行”的 checklist。

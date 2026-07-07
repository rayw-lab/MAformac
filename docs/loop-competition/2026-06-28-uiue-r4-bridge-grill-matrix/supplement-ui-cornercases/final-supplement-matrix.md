# R4 Supplemental Final Grill Matrix - UI Corner Cases

- Date: 2026-06-28
- Scope: supplemental `C31-C50`
- Verdict: `PASS_WITH_BOUNDARY_REWRITE`
- Proof class: planning / audit checklist only

## Matrix

| ID | Stage | Grill question | RED | GREEN | BLUE | PURPLE | ORANGE | BLACK | Avg | Priority | Route | Action | Recommendation |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- | --- | --- | --- |
| C31 | R4 | R4 是否需要一张 UIUE zone ownership/evidence 表，说明顶部 context/capsule、orb/thinking、dialogue/readback、vehicle controls、mic dock、overlay/sheet 各自消费哪些 snapshot 字段、哪些只属 visual policy、哪些需要 evidence，而不是把 zone manifest 升格成第二 bridge SSOT？ | 5 | 4 | 5 | 2 | 5 | 5 | 4.33 | P0 | R4-visual-policy | rewrite | 保留为 zone 分类表，不让 bridge schema 膨胀；输出应指向 C50 的三类分类。 |
| C32 | R4 | 每个 zone 是否都有明确的状态来源：context capsule 读 `context`、orb 读 `orbState`、mic 读 `voiceState`、dialogue 读 `dialogText/readbacks`、cards 读 `storeCells/activeCells/refusedCell`，缺来源时 fail-closed？ | 5 | 4 | 4 | 4 | 4 | 4 | 4.17 | P1 | R4-contract | merge | 与 C31/C50 结合；保留为 source mapping checklist，不单独扩 schema。 |
| C33 | R4 | 跨 zone 注意力链是否可验：卡片状态变化、readback/TTS 文案、orb thinking/speaking、context capsule ambient、edge burst 不能同时抢主焦点，且 reduce motion 下仍保留状态语义？ | 5 | 5 | 5 | 4 | 5 | 5 | 4.83 | P0 | R4-visual-policy | keep | 写入 visual policy；验证需要场景截图/多帧或明确时序 receipt。 |
| C34 | R4 | 若产品决定支持 1.5 秒长按进入思考/演绎控制台，R4 是否定义触发 zone、progress feedback、取消半径、松手行为、reduce motion/a11y 替代入口，并与 mic 按住说话区分？ | 5 | 3 | 4 | 3 | 4 | 3 | 3.67 | P1 | R4-user-decision | rewrite | 保留但不当作已实现；先让用户/产品拍入口，再进入 visual policy 或后续实现任务。 |
| C35 | R4 | mic 按住说话、长按思考、卡片 tap 展开、温度条 drag、车控区 scroll、对话区 scroll、overlay dismiss 和设置按钮之间是否有 gesture arbitration 规则，避免手势串扰？ | 5 | 5 | 5 | 5 | 5 | 4 | 4.83 | P0 | R4-visual-policy | keep | 作为核心交互门；至少要求手势冲突矩阵和负例 proof。 |
| C36 | R4 | 演绎控制台入口是否被标明为 demo/operator surface，而不是用户车控能力；从 settings、长按或其他入口进入都不得改变 runtime/voice readiness 结论？ | 5 | 5 | 4 | 4 | 4 | 5 | 4.50 | P0 | R4-evidence | rewrite | 要求 receipt 标注 operator surface；不能把控制台路径写成用户 runtime 功能。 |
| C37 | R4 | 顶部车辆样式/环境 capsule 跟随端状态时，speed/gear、weather、time_period、macro scene、reset normal、safety refusal 等冲突是否有显示优先级？ | 4 | 4 | 5 | 4 | 4 | 4 | 4.17 | P1 | R4-visual-policy | rewrite | 归 visual policy；定义 context display priority，不写 raw runtime 逻辑。 |
| C38 | R4 | context capsule 是否禁止展示 raw speed/gear 数字但允许展示行驶/雨/夜等语境，并用证据证明它守住 `vehicle.* not rendered as control` 的红线？ | 5 | 4 | 5 | 4 | 5 | 5 | 4.67 | P0 | R4-evidence | keep | 保留为车辆语境红线；截图/receipt 只证明语境表达，不证明真实车辆状态。 |
| C39 | R4 | 顶部 capsule、设置、刷新、Dynamic Island/safe area 的布局是否需要固定 zone-pair evidence，证明其不遮挡、不吞手势、不进入 capsule 图像？ | 3 | 3 | 3 | 2 | 3 | 2 | 2.67 | P1 | R4-test-harness | merge | 合并入 C31/C45 的 evidence checklist；不作为单独 schema gate。 |
| C40 | R4 | 演绎控制台 force context、macro scene、reset normal 是否产生完整 snapshot lifecycle：context、activeCells、readbacks/dialogue、orb/voice state、proofClass 和 stale visual clearing 同步？ | 5 | 4 | 5 | 5 | 5 | 5 | 4.83 | P0 | R4-contract | keep | 作为 bridge/snapshot 生命周期硬门；缺任何同步只可 `PARTIAL`。 |
| C41 | R4 | macro 场景一次改变多个 family 时，bridge 是否表达 per-action active cells、per-action readbacks、ambient burst 触发和最终综合文案，避免一个 `accepted` 压扁多 zone 变化？ | 4 | 5 | 4 | 4 | 4 | 4 | 4.17 | P1 | R4-contract | rewrite | 与 C10/C40 对齐；要求 multi-action fixture，而非单全局成功态。 |
| C42 | R4 | reset/theme/preset 切换后，cards、orb、capsule、dialogue、mic dock 和 overlay 是否有 stale-state clearing 规则，防止上一轮 active/refused/thinking/pressing 视觉残留？ | 5 | 3 | 5 | 4 | 5 | 5 | 4.50 | P0 | R4-visual-policy | keep | 与 C40 同组；需要负例/重置后截图或 UI tree proof。 |
| C43 | R4 | 手动滚动与自动 scroll-to-active 是否有 R4 policy：用户正在滚 vehicle controls 或 dialogue 时不得被 active family 自动拉回，系统触发 active 且用户未滚时才滚入视野？ | 4 | 4 | 5 | 4 | 4 | 4 | 4.17 | P1 | R4-visual-policy | keep | 保留为 scroll ownership policy；不要把它变成 runtime 字段。 |
| C44 | R4 | active family hero/fade、expanded overlay、dismiss tap 和 card writeback 是否证明空间记忆不被破坏：不物理重排、不丢 activeCell、不把 overlay 局部 state 当全局 store？ | 3 | 5 | 4 | 4 | 4 | 4 | 4.00 | P1 | R4-visual-policy | rewrite | 与 C43/C45 成组；验证空间记忆和 state ownership。 |
| C45 | R4 | z-order/hit-testing 是否成为 R4 corner case：ambient burst 不挡交互，mic dock 不遮最后一行卡片，expanded overlay 拦截背景 tap，capsule invisible hit area 不吞 settings/refresh？ | 4 | 5 | 5 | 5 | 5 | 4 | 4.67 | P0 | R4-test-harness | keep | 作为 UI test/checker/evidence gate；覆盖 hit-testing 与 z-order 负例。 |
| C46 | R4 | accessibility 是否按 zone 明确：每个可点/可调/可展开/可关闭区域有稳定 identifier、label/value、VoiceOver 路径，温度 scrub 有 adjustable 替代，long press 有非手势替代？ | 4 | 4 | 4 | 5 | 5 | 4 | 4.33 | P0 | R4-test-harness | rewrite | 细化为 a11y checklist；长按替代入口依赖 C34 产品决定。 |
| C47 | R4 | reduce motion 是否按 zone 出证据：orb、capsule、edge burst、waveform、card breathing、hero/fade、sheet transition 均降级为静态但可读状态，而不是只截一张图？ | 5 | 5 | 5 | 5 | 5 | 5 | 5.00 | P0 | R4-test-harness | keep | 升为补充 P0；需要 zone-wise receipt。 |
| C48 | R4 | Mac panorama 与 iPhone portrait 的 zone topology 是否分别验收，同一 PresentationSnapshot 在两种布局下不产生 proof-class 互相替代？ | 4 | 4 | 5 | 4 | 4 | 4 | 4.17 | P1 | R4-evidence | keep | 作为平台 proof split；Mac 不能替 iPhone，simulator 不能替 true-device。 |
| C49 | R4 | 对动效时序、长按 progress、crossfade、stale clearing 等时间性声明，R4 evidence 是否需要视频/时间点/多帧截图，而不是只靠静态 screenshot 或 UI tree frame？ | 5 | 5 | 5 | 4 | 5 | 3 | 4.50 | P0 | R4-evidence | rewrite | 只要求时间性 claim 用多帧/视频；静态布局仍可用 UI tree/crop。 |
| C50 | R4 | 哪些 UI 细节进 bridge schema、哪些进 visual policy、哪些只进 evidence checklist 是否需要一张分类表，防止四区动效/车辆样式/演绎入口把 R4 bridge 膨胀成 UI 实现总表？ | 5 | 5 | 5 | 5 | 5 | 5 | 5.00 | P0 | R4-contract | keep | 作为补充总闸；所有 C31-C49 必须归类后才能进入 R4 burndown。 |

## Classification Summary

| Bucket | Supplemental items |
| --- | --- |
| Bridge schema / snapshot lifecycle | C32, C40, C41, C50 |
| Visual policy | C31, C33, C34, C35, C37, C42, C43, C44 |
| Evidence checklist / harness | C36, C38, C39, C45, C46, C47, C48, C49 |

## Verdict

`PASS_WITH_BOUNDARY_REWRITE`.

All twenty supplemental risks are real. Some are merge-only, but none should be silently dropped because the original `C01-C30` matrix did not force these UIUE-specific corner cases to be classified.

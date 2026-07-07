# R4 Supplemental Blind Candidates - UI Corner Cases

- Date: 2026-06-28
- Mode: fixed blind set
- Count: 20
- IDs: C31-C50
- Language: Chinese

These are supplemental grill questions only. They do not encode final priority, route, action, or recommendation.

| ID | Stage | Grill question |
| --- | --- | --- |
| C31 | R4 | R4 是否需要定义 UIUE stage 的 zone topology：顶部 context/capsule、orb/thinking、dialogue/readback、vehicle controls、mic dock、overlay/sheet 各自的状态来源、写权限和 proof class，而不是只说“UI 消费 PresentationSnapshot”？ |
| C32 | R4 | 每个 zone 是否都有明确的 bridge/snapshot 字段或 explicit visual policy 来源，例如 context capsule 读 `context`、orb 读 `orbState`、mic 读 `voiceState`、dialogue 读 `dialogText/readbacks`、cards 读 `storeCells/activeCells/refusedCell`？ |
| C33 | R4 | 跨 zone 注意力链是否有可验规则：卡片状态变化、readback/TTS 文案、orb thinking/speaking、context capsule ambient、edge burst 不能同时抢主焦点，且 reduce motion 下仍保留状态语义？ |
| C34 | R4 | 长按 1.5 秒进入思考/演绎控制台的交互是否需要独立合同：触发 zone、progress feedback、取消半径、松手行为、reduce motion 表达、a11y 替代入口、以及与 mic 按住说话的区别？ |
| C35 | R4 | mic 按住说话、长按思考、卡片 tap 展开、温度条 drag、车控区 scroll、对话区 scroll、overlay dismiss 和设置按钮之间是否有 gesture arbitration 规则，避免一个 zone 的手势抢走另一个 zone 的意图？ |
| C36 | R4 | 演绎控制台入口是否必须被 bridge/evidence 标明为 demo/operator surface，而不是用户车控能力；从 settings、长按、或其他入口进入时是否都不得改变 runtime readiness 结论？ |
| C37 | R4 | 顶部车辆样式/环境 capsule 是否跟随端状态切换有明确优先级：speed/gear、weather、time_period、macro scene、reset normal、safety refusal 等冲突时显示哪一种 visual state？ |
| C38 | R4 | context capsule 的“车辆样式切换”是否禁止展示 raw speed/gear 数字但允许展示行驶/雨/夜等语境，且证据要证明它守住 `vehicle.* not rendered as control` 的红线？ |
| C39 | R4 | 顶部 capsule、设置、刷新、Dynamic Island/safe area 的布局是否需要作为 R4 bridge evidence 的固定 zone pair，而不是只归入 R2b layout checker 的通用 overlap/min-gap？ |
| C40 | R4 | 演绎控制台 force context、macro scene、reset normal 是否需要产生完整 snapshot lifecycle：context 变化、activeCells、readbacks/dialogue、orb/voice state、proofClass 和 stale visual clearing 同步？ |
| C41 | R4 | macro 场景一次改变多个 family 时，bridge 是否必须表达 per-action active cells、per-action readbacks、ambient burst 触发和最终综合文案，避免一个 `accepted` 把多 zone 变化压扁？ |
| C42 | R4 | reset/theme/preset 切换后，cards、orb、capsule、dialogue、mic dock 和 overlay 是否有 stale-state clearing 规则，防止上一轮 active/refused/thinking/pressing 视觉残留？ |
| C43 | R4 | 手动滚动与自动 scroll-to-active 是否需要 R4 证据：用户正在滚 vehicle controls 或 dialogue 时不得被 active family 自动拉回，系统触发 active 时才滚入视野？ |
| C44 | R4 | active family hero/fade、expanded overlay、dismiss tap 和 card writeback 是否要证明空间记忆不被破坏：不物理重排、不丢 activeCell、不把 overlay 局部 state 当成全局 store？ |
| C45 | R4 | z-order/hit-testing 是否需要成为 R4 corner case：ambient burst 必须不挡交互，mic dock/safe-area 不遮最后一行卡片，expanded overlay 应拦截背景 tap，capsule 的 invisible hit area 不吞 settings/refresh？ |
| C46 | R4 | accessibility 是否需要按 zone 明确：每个可点/可调/可展开/可关闭区域有稳定 identifier、label/value、VoiceOver 可达路径，温度 scrub 有 adjustable 替代，long press 有非手势替代？ |
| C47 | R4 | reduce motion 是否要按 zone 出证据：orb、capsule、edge burst、waveform、card breathing、hero/fade、sheet transition 全部降级为静态但可读状态，而不是只截一张 reduce-motion 图？ |
| C48 | R4 | Mac panorama 与 iPhone portrait 的 zone topology 是否需要分别验收：同一 PresentationSnapshot 在 Mac 左右分栏和 iPhone 竖屏多区布局下不产生 proof-class 互相替代？ |
| C49 | R4 | R4 evidence 是否需要视频/时间点/多帧截图来证明动效时序、长按 progress、crossfade、stale clearing，而不是只靠静态 screenshot 或 UI tree frame？ |
| C50 | R4 | 哪些 UI 细节应进入 bridge schema、哪些应进入 visual policy、哪些只进入 evidence checklist 是否需要一张分类表，防止四区动效/车辆样式/演绎入口把 R4 bridge 合同膨胀成 UI 实现总表？ |

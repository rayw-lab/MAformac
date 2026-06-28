# UIUE R4 Bridge Grill Candidates Blind Set

- Date: 2026-06-28
- Mode: fixed blind set
- Count: 30
- Language: Chinese

These are candidate grill questions only. They do not encode final priority, route, action, or recommendation.

| ID | Stage | Grill question |
| --- | --- | --- |
| C01 | R4 | R4 是否已经明确谁是 Runtime-Presentation bridge 的单一合同权威，并解释 UIUE 已接受的 bridge change 与 mainline 当前仍写 `not_proposed` / `deferred` 的路线牌差异，避免 mainline 再开第二份 bridge SSOT？ |
| C02 | R4 | R3 的 8.C2 人审带 notes 通过后，R4 是否有入口条件来区分 `operator-pass with notes`、`UIUE visual evidence`、`runtime proof` 和 `mainline acceptance`，防止把 R3 视觉通过升级成 R4/R5 ready？ |
| C03 | R4 | mainline co-author review 的 owner、输入、输出和阻断条件是否被写清，尤其是 UIUE 侧合同可继续推进但 mainline 路线牌尚未吸收时，谁负责收敛冲突？ |
| C04 | R4 | `PresentationSnapshot` 的最小字段、可选字段、默认值和 `missing/unknown` fail-closed 行为是否足以让 UIUE 卡片、胶囊、orb、readback 与证据截图一致消费，而不是回退到 raw store 猜测？ |
| C05 | R4 | `DemoRuntimeResult.result_kind` 是否覆盖 `accepted`、`refused`、`partial_accept_partial_refuse`、`already_state_noop`、`cancelled`、`runtime_error` 等终态，并能映射到 UIUE 的 mixed outcome 呈现？ |
| C06 | R4 | `scope_origin` 当前 Core 三态与 bridge 提议的 `missing` 第四态之间是否有显式兼容策略，避免 default-scope、用户显式范围、fallback 和缺失范围在 UI 上混成一个状态？ |
| C07 | R4 | R4 是否把 R1/R2 中的 `default_scope`、`scope_origin` 和可操作设备集合接入 bridge 语义，而不是只在 UIUE 本地测试中证明状态细胞可点击？ |
| C08 | R4 | readback 的来源、proof class、scope、per-action result 和最终文案是否有单一数据路径，防止 UI 卡片、胶囊、TTS 文案和证据 receipt 各自重算导致不一致？ |
| C09 | R4 | R4 是否定义了有限 `proof_class` 枚举和降级规则，并明确 UIUE simulator/mock 截图不能被解释为 runtime、mobile、true-device、voice 或 V-PASS？ |
| C10 | R4 | mixed outcome 场景下，bridge 是否能同时表达 `active_cell`、`refused_cell`、`sibling_cells`、`per_action_results` 和 readback，使 UI 不会只显示一个全局成功或失败？ |
| C11 | R4 | 对空调制冷/制热、座椅通风/加热、车窗等 sibling state，R4 是否规定 bridge snapshot 如何携带互斥关系和当前态，避免 UIUE 继续靠视觉层硬编码推断？ |
| C12 | R4 | `source`、`scope_origin`、`scope`、`readback.source` 和 `trace_id` 的边界是否被拆清，避免来源、范围、证据链和运行时 trace 在后续 R5 里互相污染？ |
| C13 | R4 | force-context 事件中的车速、挡位、天气、时间段等 demo 条件是否被限定在 bridge event / fixture 范围内，并禁止被误读为真实车辆状态或 live API 输入？ |
| C14 | R4 | `voice_state`、`orb_state`、`thinking` 或胶囊动画字段是否被定义为 presentation choreography，而不是 ASR/TTS/voice pipeline readiness 的证据？ |
| C15 | R4 | R4 是否解释两段 thinking 的语义边界，例如 cards start changing、readback ready、TTS start/end、timeout/cancel，以便 R5 不把 UI 动画时序当成 runtime 执行时序？ |
| C16 | R4 | UIUE adapter 是否被限制为 mock snapshot / fixture 到 `PresentationSnapshot` 的消费端，禁止直接读取 runtime store、C3 trace、raw command 或 mainline backend 私有结构？ |
| C17 | R4 | mainline runtime 将来如何把 C3/C3ExecutionResult/TraceEntry 映射到 `DemoRuntimeResult` 是否有最小兼容草图，而不会让 R4 反向改写 C3 或 C6 的行为合同？ |
| C18 | R4 | R4 与 post-C6 identity / behavior-shape rebuild 的重叠是否被拆清：bridge 只承载 presentation contract，不负责 C6 acceptance、behavior taxonomy 完成或模型质量判定？ |
| C19 | R4 | R4 是否明确 C5 retrain、LoRA candidate、demo golden、voice golden 和 endpoint readiness 都是 R5/mainline 后续门，不因 bridge schema 存在而自动解锁？ |
| C20 | R4 | `trace_id`、`turn_id`、snapshot version 和 evidence receipt 是否足够稳定，可让 UIUE 截图、unit fixture、simulator capture 和 mainline runtime logs 做同一轮 replay 对齐？ |
| C21 | R4 | bridge 对 timeout、cancel、runtime_error、unsupported action、安全拒绝和部分拒绝的 terminal snapshot 是否有统一要求，避免异常路径只有成功态 UI 证据？ |
| C22 | R4 | R4 是否保留 MAformac 的离线、端侧、无云依赖、mock 车控边界和三轮记忆约束，不把 bridge 扩成线上 API、持久化服务或真实车控执行层？ |
| C23 | R4 | graph manifest、visual evidence manifest、capability IDs 和 route tables 是否被标明为 derived/index artefacts，而不是第二套 authority 或替代 bridge/OpenSpec 合同？ |
| C24 | R4 | R1 interaction integrity 的 action availability、disabled reason、writeback 和 no-op 规则是否被 bridge 携带到 UI，而不是只靠按钮本地禁用态实现？ |
| C25 | R4 | R2/R2b 的布局、胶囊、小圆球/orb、多主题和 reduce motion 状态是否都能从 bridge presentation fields 或 explicit visual policy 得到解释，而不是变成各主题分支散落逻辑？ |
| C26 | R4 | R4 证据是否要求每份 receipt 标注 repo、branch、HEAD、dirty ownership 和 proof class，尤其在 UIUE worktree 与 mainline worktree 同时推进时防止串证？ |
| C27 | R4 | bridge schema 是否有版本号、fixture 兼容策略和破坏性变更规则，能支持 R4 checklist、R5 runtime adapter 和后续 mainline tests 并行演进？ |
| C28 | R4 | R4 的测试计划是否拆成 schema/fixture/unit/simulator/evidence/contract validation 的最小门，而不是要求一个不可运行的 `make verify-all` 式大一统门？ |
| C29 | R4 | R4 exit criteria 是否写清进入 R5 的条件：哪些 P0/P1 grill 必须 burndown，哪些 notes 可以带入，哪些 runtime/voice/model lanes 必须另开任务而不能混在 R4？ |
| C30 | R4 | Liquid4All、外部 H5/FastAPI、旧 demo bridge 或参考实现是否全部被限定为参考材料，并禁止把其字段、样式或 runtime 假设直接复制进 MAformac/UIUE 合同？ |

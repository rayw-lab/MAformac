# UIUE R4 Bridge Final Grill Matrix

- Date: 2026-06-28
- Source: fixed blind set plus six reviewer Markdown files.
- Reviewer files:
  - `round-01/brain-1.md` RED
  - `round-01/brain-2.md` GREEN
  - `round-01/brain-3.md` BLUE
  - `round-02/brain-1.md` PURPLE
  - `round-02/brain-2.md` ORANGE
  - `round-02/brain-3.md` BLACK
- Verdict: `PASS_WITH_REWRITE_NOTES`
- Scope: R4 bridge grill checklist only.

## Matrix

| ID | Stage | Grill question | RED | GREEN | BLUE | PURPLE | ORANGE | BLACK | Avg | Priority | Route | Action | Recommendation |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- | --- | --- | --- |
| C01 | R4 | R4 是否已经锁定 Runtime-Presentation bridge 的单一合同权威，并把 UIUE 已接受 bridge change 与 mainline 路线牌仍写 `not_proposed` / `deferred` 的差异收敛成一个不再分叉的 SSOT？ | 5 | 5 | 5 | 5 | 5 | 5 | 5.00 | P0 | R4-mainline-coauthor | keep | 作为 R4 第一项 burndown：指定 bridge authority、mainline co-author 结论和禁止第二桥的证据位置。 |
| C02 | R4 | R3 8.C2 人审带 notes 通过后，R4 是否明确区分 `operator-pass with notes`、UIUE visual evidence、bridge contract acceptance、mainline runtime acceptance 和 R5 readiness？ | 5 | 5 | 5 | 5 | 5 | 5 | 5.00 | P0 | R4-evidence | keep | 写成 proof-class cap：R3 人审可继续推进，但不得升级为 runtime、mobile、voice、V-PASS 或 `8.C2` 外延完成。 |
| C03 | R4 | mainline co-author review 是否有明确 owner、输入文件、输出 receipt、阻断条件和冲突处理路径，特别是 UIUE 已推进而 mainline 仍未吸收 bridge 路线时？ | 5 | 5 | 4 | 5 | 4 | 5 | 4.67 | P0 | R4-mainline-coauthor | rewrite | 要求 executor 给出 co-author checklist 和 stop condition；缺 owner 或缺输出时 R4 不得出站。 |
| C04 | R4 | `PresentationSnapshot` 的最小字段、可选字段、默认值和 `missing/unknown` fail-closed 行为是否足以驱动 UIUE 卡片、胶囊、orb、readback 与证据截图，而不是回退到 raw store 推断？ | 4 | 4 | 5 | 5 | 5 | 4 | 4.50 | P0 | R4-contract | rewrite | 把字段清单、未知值降级、fixture 样例和 UI consumption boundary 绑定成一个 contract gate。 |
| C05 | R4 | `DemoRuntimeResult.result_kind` 是否用机器可读枚举覆盖 accepted、refused、partial accept/refuse、already-state no-op、cancelled、runtime error 等终态，并能映射到 mixed outcome UI？ | 4 | 5 | 5 | 5 | 5 | 4 | 4.67 | P0 | R4-contract | rewrite | 对齐 OpenSpec 枚举命名，同时保留人类场景说明；要求 fixture 覆盖成功、拒绝、部分成功、no-op 和异常。 |
| C06 | R4 | `scope_origin` 当前 Core 三态与 bridge 提议的 `missing` 第四态是否有显式兼容策略，避免把 default scope、用户显式范围、fanout 和缺失范围混成一个 UI 状态？ | 5 | 5 | 4 | 5 | 4 | 5 | 4.67 | P0 | R4-mainline-coauthor | rewrite | 标注 `missing` 是 bridge-proposed future addition；mainline co-author 必须决定落点、迁移和 fail-closed 行为。 |
| C07 | R4 | R1/R2 的 `default_scope`、`scope_origin`、action availability、disabled reason 和可操作集合是否被 bridge 携带到 presentation，而不是只停留在 UIUE 本地 interaction policy 测试？ | 4 | 5 | 4 | 2 | 4 | 4 | 3.83 | P1 | R4-contract | rewrite | 缩窄为 interaction semantics crossing bridge；避免重复 R1 单测，要求 snapshot/fixture 可观察。 |
| C08 | R4 | readback 的来源、proof class、scope、per-action result 和最终文案是否有单一数据路径，保证 UI 卡片、胶囊、TTS 文案和 evidence receipt 不各自重算？ | 5 | 5 | 5 | 3 | 5 | 5 | 4.67 | P0 | R4-contract | keep | 要求 single-source readback fixture；任何 UI/TTS/receipt 派生都必须指回同一 snapshot/result 字段。 |
| C09 | R4 | R4 是否定义有限 `proof_class` 枚举、显示上限和降级规则，明确 UIUE simulator/mock 截图不能被解释为 runtime、mobile、true-device、voice 或 V-PASS？ | 5 | 5 | 5 | 5 | 5 | 5 | 5.00 | P0 | R4-evidence | keep | 作为 fake-green 总闸；最终 receipt 必须显示 proof class 且默认 fail-closed。 |
| C10 | R4 | mixed outcome 场景下，bridge 是否能同时表达 active cell、refused cell、sibling cells、per-action results 和 readback，避免 UI 只显示一个全局成功或失败？ | 4 | 4 | 5 | 5 | 5 | 4 | 4.50 | P0 | R4-contract | keep | 要求至少一个 mixed fixture 和截图/evidence 对齐；异常与拒绝路径不能只靠文案补丁。 |
| C11 | R4 | 空调制冷/制热、座椅通风/加热、车窗等 sibling state 是否通过 bridge snapshot 表达互斥关系和当前态，避免视觉层继续硬编码推断？ | 4 | 3 | 5 | 4 | 4 | 4 | 4.00 | P1 | R4-contract | merge | 与 C04/C10 同组 burndown；保留为 sibling-state 追问，要求字段或显式 visual policy 给出来源。 |
| C12 | R4 | `source`、`scope_origin`、`scope`、`readback.source` 和 `trace_id` 的概念边界是否拆清，防止来源、范围解析、证据链和运行时 trace 在 R5 互相污染？ | 5 | 4 | 4 | 5 | 4 | 5 | 4.50 | P1 | R4-contract | keep | 加入术语表和负例：UI touch source、scope resolution、value provenance、trace identity 不可互作替身。 |
| C13 | R4 | force-context 事件里的车速、挡位、天气、时间段等 demo 条件是否限定在 bridge event/fixture 范围内，并禁止被误读为真实车辆状态或 live API 输入？ | 4 | 4 | 4 | 4 | 4 | 4 | 4.00 | P1 | R4-test-harness | keep | 作为 demo-mode fixture guard；所有 receipt 标注 mock/context input，不得写 live truth。 |
| C14 | R4 | `voice_state`、`orb_state`、thinking 或胶囊动画字段是否被定义为 presentation choreography，并明确不构成 ASR、TTS、voice golden、endpoint 或 voice-ready 证据？ | 5 | 4 | 5 | 4 | 3 | 5 | 4.33 | P1 | R5-voice | rewrite | R4 可定义显示字段和证据 cap；voice pipeline readiness 必须留到 R5 独立 lane。 |
| C15 | R4 | R4 是否解释 cards start changing、readback ready、TTS start/end、timeout/cancel 等两段 thinking 语义，避免 R5 把 UI 演出时序误当 runtime 执行时序？ | 4 | 3 | 4 | 3 | 4 | 4 | 3.67 | P1 | R4-evidence | merge | 与 C14/C21 同组；保留为时序语义追问，重点是 evidence 表达边界。 |
| C16 | R4 | UIUE adapter 是否被限制为 mock snapshot/fixture 到 `PresentationSnapshot` 的消费端，禁止直接读取 runtime store、C3 trace、raw command 或 mainline backend 私有结构？ | 5 | 5 | 5 | 5 | 4 | 5 | 4.83 | P0 | R4-contract | keep | 写成 hard no-touch boundary；UIUE visual lane 只能消费 bridge contract。 |
| C17 | R4 | mainline runtime 将来如何把 C3/C3ExecutionResult/TraceEntry 投影到 `DemoRuntimeResult` 是否有最小兼容草图，同时不让 R4 反向改写 C3 或 C6 行为合同？ | 5 | 5 | 4 | 5 | 4 | 5 | 4.67 | P0 | R5-runtime | rewrite | 需要 projection sketch 和 non-goal 列表；R4 定 seam，不实现 runtime backend。 |
| C18 | R4 | R4 与 post-C6 identity/behavior-shape rebuild 的重叠是否拆清：bridge 只承载 presentation contract，不负责 C6 acceptance、behavior taxonomy 完成或模型质量判定？ | 5 | 5 | 4 | 4 | 3 | 5 | 4.33 | P0 | Mainline-roadmap | keep | 在路线图中标注 bridge 不替代 C6 acceptance/comparison；缺此项会把 post-C6 主线假绿。 |
| C19 | R4 | R4 是否明确 C5 retrain、LoRA candidate、demo golden、voice golden 和 endpoint readiness 都是 R5/mainline 后续门，不因 bridge schema 存在而自动解锁？ | 5 | 5 | 4 | 5 | 3 | 5 | 4.50 | P0 | R5-model | keep | 作为 R5 split guard；schema 存在只允许后续接线，不允许宣称 model/golden/voice ready。 |
| C20 | R4 | `trace_id`、`turn_id`、snapshot version 和 evidence receipt 是否稳定到足以让 UIUE 截图、unit fixture、simulator capture 和 mainline runtime logs 对同一轮 replay 对齐？ | 4 | 4 | 5 | 4 | 5 | 4 | 4.33 | P1 | R4-evidence | rewrite | 写成可复跑 identity 条件；不要求 R5 runtime log 已存在，但要能预留对齐键。 |
| C21 | R4 | bridge 对 timeout、cancel、runtime_error、unsupported action、安全拒绝和部分拒绝是否都有 terminal snapshot 要求，避免异常路径只有成功态 UI 证据？ | 4 | 5 | 5 | 5 | 5 | 5 | 4.83 | P0 | R4-test-harness | keep | 最小 negative fixture 必须覆盖；没有异常终态 snapshot 时 R4 不出站。 |
| C22 | R4 | R4 是否保留 MAformac 离线、端侧、无云依赖、mock 车控边界和三轮记忆约束，不把 bridge 扩成线上 API、持久化服务或真实车控执行层？ | 4 | 4 | 4 | 4 | 3 | 5 | 4.00 | P1 | Mainline-roadmap | keep | 作为项目宪法守门；若后续 runtime 需要扩展，必须另开 mainline change。 |
| C23 | R4 | graph manifest、visual evidence manifest、capability IDs 和 route tables 是否被标明为 derived/index artefacts，而不是第二套 authority 或替代 bridge/OpenSpec 合同？ | 5 | 4 | 3 | 5 | 4 | 5 | 4.33 | P1 | R4-contract | keep | 放入 SSOT hygiene；manifest 只能索引、校验或派生，不得反写合同。 |
| C24 | R4 | R1 interaction integrity 的 action availability、disabled reason、writeback 和 no-op 规则是否能通过 bridge 被 UI 观察，而不是只靠按钮本地禁用态实现？ | 4 | 5 | 5 | 4 | 5 | 4 | 4.50 | P1 | R4-test-harness | merge | 与 C07 同组；要求 fixture 证明 disabled/no-op/writeback 不只存在于本地 UI 代码。 |
| C25 | R4 | R2/R2b 的布局、胶囊、小圆球/orb、多主题和 reduce motion 状态是否能从 bridge presentation fields 或显式 visual policy 解释，而不是散落在主题分支逻辑中？ | 3 | 3 | 5 | 3 | 4 | 4 | 3.67 | P1 | R4-evidence | rewrite | 不强迫所有视觉规则进 schema；要求状态来源、policy 文件和截图 receipt 能互相指认。 |
| C26 | R4 | R4 证据是否要求每份 receipt 标注 repo、branch、HEAD、dirty ownership 和 proof class，尤其在 UIUE 与 mainline worktree 同时推进时防止串证？ | 5 | 5 | 4 | 4 | 5 | 5 | 4.67 | P0 | R4-evidence | keep | 作为所有 R4 closeout 的格式硬门；缺任一字段只能 `PARTIAL`。 |
| C27 | R4 | bridge schema 是否有版本号、fixture 兼容策略和破坏性变更规则，能支持 R4 checklist、R5 runtime adapter 和后续 mainline tests 并行演进？ | 4 | 5 | 4 | 5 | 5 | 5 | 4.67 | P0 | R4-contract | keep | 要求 schema version、fixture migration note 和 breaking-change gate；否则 R5 会踩 stale fixtures。 |
| C28 | R4 | R4 测试计划是否拆成 schema、fixture、unit、simulator、evidence、contract validation 的最小门，并避免一个不可复跑的 `make verify-all` 式大一统门？ | 4 | 5 | 4 | 4 | 5 | 4 | 4.33 | P0 | R4-test-harness | rewrite | 按 proof class 拆验证门，给每门 owner、命令或 receipt；没有全绿就按门级 partial 记录。 |
| C29 | R4 | R4 exit criteria 是否写清：哪些 P0/P1 grill 必须 burndown，哪些 notes 可以带入，哪些 runtime/voice/model lanes 必须另开任务而不能混在 R4？ | 5 | 5 | 4 | 5 | 5 | 5 | 4.83 | P0 | R4-contract | rewrite | 作为最终出站 gate；R4 closeout 必须列 burndown 表和 R5 lane split，不得用“可继续”替代。 |
| C30 | R4 | Liquid4All、外部 H5/FastAPI、旧 demo bridge 或参考实现是否全部限定为参考材料，并禁止把其字段、样式或 runtime 假设直接复制进 MAformac/UIUE 合同？ | 5 | 4 | 4 | 4 | 3 | 4 | 4.00 | P1 | Mainline-roadmap | rewrite | 写成 reference hygiene：可以借鉴问题形态，不复制字段、样式、部署或 runtime 架构。 |

## Priority Summary

- `P0`: C01, C02, C03, C04, C05, C06, C08, C09, C10, C16, C17, C18, C19, C21, C26, C27, C28, C29.
- `P1`: C07, C11, C12, C13, C14, C15, C20, C22, C23, C24, C25, C30.
- `P2`: none in this pass. Lower-scored items are retained as P1 because R4 is a transition node and the risk is mostly category collapse, not low-value noise.

## Burndown Guidance

Before R4 exit, burn down every P0 with file-backed evidence. P1 items may carry notes into R5 only if the R4 closeout explicitly names owner, route, and proof-class cap.

Do not close `8.C2`, claim V-PASS, claim mobile/true-device proof, or declare runtime/voice/model/golden/endpoint readiness from this checklist.


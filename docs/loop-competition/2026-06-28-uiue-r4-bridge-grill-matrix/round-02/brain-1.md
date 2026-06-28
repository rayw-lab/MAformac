# Round 02 PURPLE Reviewer

## Persona

- 角色：PURPLE，系统架构 / 跨 repo 合同与 SSOT reviewer。
- 视角：只看 bridge contract、OpenSpec 边界、UIUE/mainline 交汇、derived artifact 纪律和可维护分层。
- Architectural Status：`WATCH`
- 盲评约束：不读取 `round-01/*`、`round-02/brain-2.md`、`round-02/brain-3.md` 或 judge 文件；只基于 contract、候选盲表和 source pool 权威文件判断。

## Scope Read

已读并用于判断的文件：

- `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r4-bridge-grill-matrix/contract.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r4-bridge-grill-matrix/candidates-blind.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/CURRENT.md`
- `/Users/wanglei/workspace/MAformac/docs/CURRENT.md`
- `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/define-runtime-presentation-bridge/proposal.md`
- `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/define-runtime-presentation-bridge/design.md`
- `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/define-runtime-presentation-bridge/tasks.md`
- `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/grill-checklist/uiue-landing-matrix-2026-06-25.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/grill-checklist/uiue-grill-定档-2026-06-25.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r0-r2-grill-burndown-2026-06-27.md`

关键读法：

- UIUE 侧已把 `define-runtime-presentation-bridge` 记为可供 mock snapshot 消费，但 mainline runtime-side co-author 仍 pending，且 `8.C2` 不是 runtime/readiness proof。
- mainline 侧仍把 Runtime-Presentation bridge 标为 `not_proposed`，并把 runtime backend / C5 / C6 / voice / golden / UIUE 连接列为 deferred。
- bridge design 已把 `partial_accept_partial_refuse`、`already_state_noop`、`active_cell/refused_cell`、`sibling_cells`、`source` vs `scope_origin`、thinking gates 和 force-context 四维写进契约。
- 这组候选真正要抓的是：单一合同权威、主线 co-author 收敛机制、schema 演化、derived manifest、C3/C6/R5 seam、以及 UIUE/mainline 的 proof-class 分层。

## Keep

- `C01`：必须保留。单一 bridge SSOT 与 UIUE/mainline 路线牌分叉是这轮最核心的冲突。
- `C02`：必须保留。proof-class 不分层，后面所有“看起来可以了”都会被误升格。
- `C03`：必须保留。mainline co-author review 是当前冲突的唯一收敛点，不是礼貌流程。
- `C04`：必须保留。`PresentationSnapshot` 是桥的主合同对象，不定字段就一定会长出第二套语义。
- `C05`：必须保留。结果枚举必须把 mixed outcome 和 already-state 独立出来。
- `C09`：必须保留。finite proof class + fail-closed 是防止幻读 V-PASS 的硬门。
- `C10`：必须保留。mixed outcome 不能被压扁成全局成功/失败。
- `C12`：必须保留。source / scope_origin / trace 这三个边界一旦混用，后续 R5 一定污染。
- `C16`：必须保留。UIUE 只能吃 snapshot，不该直接读 store。
- `C17`：必须保留。mainline 到 bridge 的 C3/C6 映射是跨 repo 的真实 seam。
- `C19`：必须保留。C5 retrain、demo golden、voice golden、endpoint readiness 不能被桥合同偷开绿灯。
- `C21`：必须保留。timeout / cancel / runtime_error 的 terminal snapshot 是桥的必修边界。
- `C23`：必须保留。derived manifest 不能变第二套 authority。
- `C27`：必须保留。没有版本号和破坏性变更规则，bridge 只能靠人记忆，维护性会塌。
- `C29`：必须保留。R4 exit criteria 要把哪些门必须 burndown 说死，否则会把 R5 负担倒灌进来。
- `C30`：必须保留。外部实现只能 reference only，不能复制字段假设或 runtime 假设。

## Delete

- `C07`：建议删除为独立题，合并进 `C06` / `C24`。它本质上还是 default_scope / scope_origin / 可操作集合如何进入桥语义的问题，单独再问一遍会稀释主线。
- `C15`：建议删除为独立题，合并进 `C14` / `C21`。thinking 两段语义的真正问题已经在 gates 与 proof-class 上，单独再问时序容易变成动效题。

## Merge

- `C01 + C03`：可以合成一题，但要保留“单一 authority”与“co-author 收敛机制”两个子问，否则会丢掉责任归属。
- `C04 + C08 + C20`：可合并成“snapshot/readback/trace 的单一数据路径与 replay 对齐”。
- `C06 + C07 + C24`：可合并成“scope/default_scope/action availability 如何进入 bridge 语义与 UI 行为”。
- `C11 + C25`：可合并成“sibling/mutual-exclusion 与 layout/theme/reduce-motion 的 presentation policy”。
- `C14 + C15 + C21`：可合并成“orb/voice/thinking 的 choreography 只做 presentation，不偷跑 runtime proof”。
- `C26 + C27 + C28`：可合并成“receipt/manifest/version/test gate 的工程化维护套件”，但要保留版本与验证两个维度。

## Rewrite

- `C06`：改写成明确二选一或三选一的问题，要求 mainline co-author 明确决定 `missing` 是扩 `ScopeOrigin`、单独建 presentation enum，还是删掉桥里的 `missing`。
- `C08`：改写成“readback / trace / receipt 是否只允许单一路径派生”，不要泛泛问“不一致会不会发生”。
- `C13`：改写成“demo-mode force-context 只允许 bridge event / fixture 输入，禁止被误读为 live API 或真车状态”。
- `C14`：改写成“voice_state/orb_state 只是 presentation choreography，不得被 proof-class 升格”，把证明边界写死。
- `C18`：改写成“bridge 只承载 presentation contract，不承担 C6 acceptance、behavior taxonomy 或 model quality 判定”。
- `C20`：改写成“trace_id / turn_id / snapshot version / receipt ID 是否足以形成同轮 replay 对齐”，把‘稳定’变成可验证条件。
- `C22`：改写成“offline / on-device / mock car control 的边界是否会被 bridge 扩成服务化或真实执行层”，突出不可逆风险。
- `C25`：改写成“视觉 policy 是否由 bridge 字段或显式 policy 驱动，而不是每个主题分支各自推断”。
- `C28`：改写成分层门的问题，不要写成一个大一统 `make verify-all` 的反面描述。

## Missing Risks

- `spec` 路径存在 source-pool 不一致：contract 指向 `specs/ui-presentation/spec.md`，但实际文件是 `openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md`。这会影响机械验证和后续审计。
- mainline `docs/CURRENT.md` 仍把 Runtime-Presentation bridge 标成 `not_proposed`，而 UIUE `docs/CURRENT.md` 已把同一 change 记为 accepted for mock visual consumption。这个双态不是错误本身，但必须通过 mainline co-author 机制收敛，否则会演化成双 SSOT。
- `scope_origin` 的 `missing` 仍是桥提议未来值，不是当前 Core 值；如果不在 mainline co-author 层拍死，后续实现会出现 enum 分叉。
- `AD-RPB-015` 的 derived manifest 规则还需要版本化与退场规则，否则“derived”很容易被慢慢当成新的事实源。

## Scores

| ID | Score | 判断 |
|---|---:|---|
| C01 | 5 | 必保留，单一 authority 问题是第一优先级。 |
| C02 | 5 | 必保留，proof-class 分层是桥的护栏。 |
| C03 | 5 | 必保留，co-author 收敛机制必须明示。 |
| C04 | 5 | 必保留，snapshot 是桥的主合同对象。 |
| C05 | 5 | 必保留，result_kind 是 mixed outcome 的根。 |
| C06 | 5 | 必保留但要改写，`missing` 的落点必须拍死。 |
| C07 | 2 | 过度贴近 C06/C24，建议并入。 |
| C08 | 3 | 重要但与 C04/C20 重叠，宜改写成单一路径。 |
| C09 | 5 | 必保留，proof_class 的 fail-closed 是硬门。 |
| C10 | 5 | 必保留，mixed outcome 是桥的真实压力点。 |
| C11 | 4 | 有价值，补 sibling/互斥关系，但与 C04/C10 有 overlap。 |
| C12 | 5 | 必保留，source/scope_origin/trace 的边界很关键。 |
| C13 | 4 | 有价值，主要防 demo-mode 被误读成 live truth。 |
| C14 | 4 | 有价值，但应更强地绑定 proof boundary。 |
| C15 | 3 | 偏编排时序，和 C14/C21 合并更好。 |
| C16 | 5 | 必保留，UIUE 不能直接读 store。 |
| C17 | 5 | 必保留，主线投影到桥是 cross-repo seam。 |
| C18 | 4 | 有价值，避免桥偷跑到 C6 / taxonomy / model 判定。 |
| C19 | 5 | 必保留，R5 门不能被桥提前解锁。 |
| C20 | 4 | 有价值，但最好改成可验证 replay 对齐条件。 |
| C21 | 5 | 必保留，terminal snapshot 是桥的底线能力。 |
| C22 | 4 | 有价值，offline/端侧/mock 边界要持续锁住。 |
| C23 | 5 | 必保留，derived manifest 不可变成第二套 authority。 |
| C24 | 4 | 有价值，action availability / writeback 应进入桥语义。 |
| C25 | 3 | 方向对，但太偏 presentation policy，宜改写合并。 |
| C26 | 4 | 有价值，receipt 的 repo/HEAD/dirty/proof class 能防串证。 |
| C27 | 5 | 必保留，版本化和破坏变更规则决定可维护性。 |
| C28 | 4 | 有价值，分层门好于大一统 verify。 |
| C29 | 5 | 必保留，R4 exit criteria 必须写成 burndown 门。 |
| C30 | 4 | 有价值，外部参考只能 reference only。 |

## Candidate Notes

| ID | Note |
|---|---|
| C01 | 这是本轮最该前置的问题，直接决定是否会出现第二份 bridge SSOT。 |
| C02 | 这是 proof-class 的总闸，没有它，后面所有视觉/运行时结论都容易被抬高。 |
| C03 | 与 C01 相关，但重点是责任归属和冲突收敛机制，不是单纯谁先写。 |
| C04 | 这是桥的主 schema，少一个字段都会诱发 UIUE 或 mainline 自建字段。 |
| C05 | 这题抓住了 mixed outcome 的核心，尤其是 partial 与 already-state。 |
| C06 | 这题很关键，但必须把 `missing` 的落点说成明确决策，而不是模糊兼容。 |
| C07 | 它问得太像 C06 的延伸，建议并入 default_scope/scope_origin 的主问题。 |
| C08 | 价值在单一路径与 replay 对齐，别只盯“会不会不一致”这种泛问。 |
| C09 | proof_class 必须有限且 fail-closed，否则 display copy 会偷偷升级能力。 |
| C10 | mixed outcome 是桥存在的理由之一，不能只允许全局成功/失败。 |
| C11 | 这题适合保留，但最好绑定到 sibling_cells 和 active_cell 的具体字段。 |
| C12 | 这是防后续 R5 污染的边界题，source 和 scope_origin 一定不能混。 |
| C13 | demo-mode force-context 是特殊输入，不应被 UI 叙述成 live vehicle 状态。 |
| C14 | voice_state/orb_state 要明确是 choreography，不是 ASR/TTS ready 的证据。 |
| C15 | 这题与 C21/C14 重叠较多，单独保留会偏向动画顺序而非合同边界。 |
| C16 | UIUE 如果能直接读 store，bridge 就失去存在意义。 |
| C17 | 这是 mainline 侧真正要回答的 seam，尤其是 C3/C6 如何映射到桥。 |
| C18 | 要防的是 bridge 越界到 C6/model taxonomy，不是仅仅 UIUE 视觉越界。 |
| C19 | 这题非常重要：桥合同存在不等于 model/voice/golden 自动解锁。 |
| C20 | replay 对齐要依靠可验证 ID，而不是“看起来像同一轮”。 |
| C21 | timeout / cancel / runtime_error 的终态快照是异常路径的唯一防线。 |
| C22 | offline、端侧、mock car control 是项目红线，桥不能把边界慢慢软化掉。 |
| C23 | derived artifact 只要没有版本和退场规则，就会慢慢变成事实源。 |
| C24 | action availability 和 writeback 是 bridge 语义的一部分，不应只停在按钮层。 |
| C25 | 这题有用，但更像 presentation policy 题，建议与 sibling/theme 合并。 |
| C26 | 这题是治理题，能有效阻断 UIUE / mainline worktree 串证。 |
| C27 | schema versioning 是 bridge 长期维护的最低成本护栏。 |
| C28 | 验证门应该按 schema / fixture / unit / simulator / evidence 分层，不要一锅端。 |
| C29 | 这是 R4 的出口题，直接关系到哪些 P0/P1 必须先 burndown。 |
| C30 | 外部实现只能做 reference only，禁止字段和 runtime 假设直搬。 |

## Residual Risk

- 主要风险不是 bridge 思路本身，而是 UIUE/mainline 双态路由没有被一次性收敛成单一 co-author 流程。
- 另一个高风险点是 source-pool 里的 spec 路径不一致；如果不修正，后续 review/verify 会反复踩空。
- `scope_origin missing`、derived manifest、以及 proof-class 上限这三处若不在主线 co-author 里拍死，后续实现会出现“合同看似一致、落地各自发明”的分叉。
- 这 30 题整体方向正确，但最终 checklist 应该从“问题堆叠”收缩成“主线 seam + proof boundary + schema evolution + R4 exit”四层结构。

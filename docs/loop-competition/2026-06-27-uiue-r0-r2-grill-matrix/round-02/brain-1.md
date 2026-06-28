# Brain 1 - Round 02

Persona: PURPLE systems architect. Focus: SSOT, OpenSpec boundary, R0/R1/R2 coupling, proof-class discipline.

## Keep

| Candidate | Score | Reason |
|---|---:|---|
| C03 | 25 | 这是 R0 状态闸门，直接防止把 `UIC2VisualAcceptanceUITests` 绿灯误升格为 `8.C2` 或 A-2 收口。 |
| C08 | 25 | enum 合法写回、summary readback、store 值一致是交互真值门的核心，不是单一 UI bug。 |
| C24 | 25 | 把 family 覆盖、value type 覆盖、gesture 覆盖拆开，是防止“10 族都点过”假绿的系统闸门。 |
| C28 | 25 | toggle 必须按 contract enum pair 翻转，否则会产生跨族非法 state。 |
| C34 | 25 | 所有写回必须走 `DemoVehicleStateStore`，这是 presentation mock 与 runtime contract 的边界。 |
| C42 | 25 | 自动门只能跑稳定 local/unit/simulator 项，不能夹带 L3 或审美签核。 |
| C48 | 25 | 每个 interaction proof 必须标 proof class，防 proof narrative 膨胀。 |
| C49 | 25 | 禁止 View 层新增 range/enum formatter，是防第二套 SSOT 的硬门。 |
| C53 | 25 | 10 族代表交互矩阵必须前置到 L0 之前，否则 R2 会继续截图绿、交互假。 |
| C54 | 25 | L1 sentinel 只能挡塌陷和大位移，不能用 WARN/RMSE 推导审美。 |
| C56 | 25 | Layout Integrity Gate 是 R2b 的结构性缺口，能把遮挡/留白从人肉经验变成可复核门。 |
| C59 | 25 | L0 截图必须是 on-screen `simctl` runtime truth，不能让 Preview 或 attachment 冒充。 |
| C69 | 25 | R2 失败时只回写发现与返修，禁止勾任务或 coverage index，是防 fake green 的最终保险。 |
| C70 | 25 | R2 通过后仍需独立只读审计，尤其复核 proof boundary、dirty scope、tasks/docs 级联。 |

## Delete

| Candidate | Reason |
|---|---|
| None | 不建议硬删。70 项都能映射到 R0/R1/R2/R2b 的真实边界或验证风险；低分项更适合 merge 或 rewrite。 |

## Merge

| Candidates | Proposed canonical wording | Reason |
|---|---|---|
| C21 + C22 + C49 | `StateCellInteractionPolicy` 只能是 presentation consumer projection，必须从 `UIValueTypeMapper`、`ValueRangeMapper`、contract enum 派生；禁止 View 层建立第二套 range/enum formatter。 | 三项都在守同一个 SSOT 边界，分开保留会让后续 agent 误以为可以新建 policy contract。 |
| C23 + C24 + C37 + C48 | 交互矩阵每行必须含 family、cell、value type、gesture、writeback、summary/readback、proof class，并区分 tap、drag、long press、a11y adjustable。 | 这是 R1 的矩阵结构定义，应作为一条 canonical contract，而不是散落为多个 checklist。 |
| C28 + C29 + C30 + C47 | toggle、badge/options/preset、color swatch、display title/readback 都必须 contract-derived，且写回后同步 store、expanded row、summary、颜色语义。 | 这些都是 contract-derived value correctness；合并可减少重复但保留风险覆盖。 |
| C41 + C42 + C43 + C44 | `make verify-uiue-interactions` 先作为 UIUE 专门门，只跑稳定 unit/UI tests，固定 Pro Max 并输出 frame diagnostics，每个新增 test 带反例或边界断言。 | 这是同一个验证门的 scope、设备和诊断规则。 |
| C56 + C57 + C58 | Layout Integrity Gate 输出 `overlap_pairs`、`min_gaps`、`zone_budget`、`safe_area_violations` 和 crop，覆盖 capsule、orb、dialogue、cards、mic dock 之间的结构关系。 | R2b 结构门应合并成一个可实现的 checker spec。 |
| C59 + C60 + C61 | L0 evidence package 必须验证 launchArg、theme、route、device、UI tree、screenshot path、proof_class；checker 默认只读，显式 `--write-summary` 才写。 | 这些共同定义 evidence package 的写权限与字段合同。 |
| C45 + C66 + C67 | L3 punchlist 先看 current screenshot/crop，再看 UI tree/test result；发现一点必须 iceberg teardown 到同 value type、gesture family、proof path。 | 这是人工审查流程的 anti-anchor 和扩散规则。 |
| C62 + C63 + C68 | capsule proof 同时区分 context 四维输入正确、diorama 视觉质量、placeholder/final-art-deferred 状态。 | capsule 不能让数据 proof 冒充审美 proof，也不能把 placeholder 资产当 final art。 |

## Rewrite

| Candidate | Proposed wording | Reason |
|---|---|---|
| C21 | 是否需要定义 `StateCellInteractionPolicy` 为 presentation consumer projection，并明确它只消费现有 mapper/contract，不成为第三份 value/type/range SSOT？ | 原题的“policy”容易被误读成新 contract；应把 consumer projection 和 no-third-SSOT 写死。 |
| C31 | summary card 的 primary touch 是否必须默认只负责展开；若允许直接调节，是否必须先进入 `SHOULD_GRILL`，并逐 value type 定义 writeback/readback/proof？ | Summary 当前合同以只读摘要为主，开放直接调节会改变路线边界。 |
| C41 | 是否需要 `make verify-uiue-interactions` 作为 UIUE 专门门，并要求推进前完成 grill、pre-mortem、决策存档，禁止直接并入 `verify-all`？ | `SHOULD_GRILL` 不能被 make target 绕过。 |
| C52 | R2 L0 最小组合是否补充 `heating + ivory`、`safety_refusal + ivory`、`capsule videoLoop + deepSpace`、`U17 golden path`，并显式声明它们只是候选最小集，不构成审美或 A-2 收口？ | 防止最小 case 被写成最终 acceptance。 |
| C70 | R2 通过后是否必须由独立 read-only audit 复核 proof boundary、dirty scope、OpenSpec `tasks.md`、coverage index 与 docs 级联，再进入 R3 closeout；该审计仍不得声明 L3/V-PASS/mobile/true_device/A-2 complete？ | 需要把 proof 禁升格写进题面。 |

## Missing Risks

- Presentation policy 可能被误建成第三份 contract。R1 应明确只做 consumer projection，producer SSOT 仍是 OpenSpec、state-cells、mapper。
- `【SHOULD_GRILL】` 是路线决策候选，不是实现授权；任何推进必须先有 grill、pre-mortem、决策存档。
- Liquid4All 只能 `PARTIAL_ADOPT` / `RESEARCH_ONLY` / `reference only`；`functions.json`、H5 fullState、FastAPI、Liquid schema、LFM runner 都不能进入 MAformac SSOT。
- `vehicle.gear` 仍是演绎控制台 mock context 或只读仪表风险点；不能悄悄归入 10 族直接触摸完成。
- Evidence package 的 project path、scheme、simulator name/id、xcresult、proof_class 必须一起记录；否则 main/UIUE worktree 或 iPhone 17 Pro/Pro Max 漂移会污染 proof。
- `ContextCapsule` 资产治理要扩到“预烘焙 chrome 禁入内容资产”；否则 SwiftUI glass 叠 PNG 白壳会反复制造双层 artifact。
- L1/L2 机器结果必须保持结构/readability 语义，不得从 PASS/WARN、OCR、SSIM、RMSE 推导“高级感”。
- View 层 grep gate 不应只查新文件；应覆盖 `App/` 与 presentation mapper 调用边界，防局部 formatter 漂移。

## Scores

| Candidate | Importance | Verifiability | Non-duplication | Decision Leverage | Risk Revelation | Total |
|---|---:|---:|---:|---:|---:|---:|
| C01 | 5 | 5 | 4 | 5 | 5 | 24 |
| C02 | 4 | 4 | 4 | 4 | 4 | 20 |
| C03 | 5 | 5 | 5 | 5 | 5 | 25 |
| C04 | 5 | 5 | 4 | 5 | 5 | 24 |
| C05 | 5 | 4 | 4 | 5 | 5 | 23 |
| C06 | 5 | 5 | 4 | 5 | 5 | 24 |
| C07 | 5 | 5 | 4 | 4 | 5 | 23 |
| C08 | 5 | 5 | 5 | 5 | 5 | 25 |
| C09 | 5 | 4 | 5 | 5 | 5 | 24 |
| C10 | 4 | 5 | 4 | 4 | 4 | 21 |
| C11 | 5 | 4 | 5 | 4 | 5 | 23 |
| C12 | 4 | 4 | 4 | 4 | 4 | 20 |
| C13 | 5 | 4 | 5 | 5 | 5 | 24 |
| C14 | 4 | 5 | 5 | 4 | 4 | 22 |
| C15 | 4 | 5 | 4 | 4 | 4 | 21 |
| C16 | 4 | 5 | 4 | 4 | 4 | 21 |
| C17 | 5 | 5 | 4 | 5 | 5 | 24 |
| C18 | 5 | 5 | 4 | 5 | 5 | 24 |
| C19 | 4 | 4 | 5 | 4 | 4 | 21 |
| C20 | 5 | 5 | 4 | 5 | 5 | 24 |
| C21 | 5 | 4 | 5 | 5 | 5 | 24 |
| C22 | 5 | 5 | 4 | 5 | 5 | 24 |
| C23 | 5 | 5 | 4 | 5 | 5 | 24 |
| C24 | 5 | 5 | 5 | 5 | 5 | 25 |
| C25 | 5 | 4 | 5 | 5 | 5 | 24 |
| C26 | 5 | 5 | 4 | 5 | 5 | 24 |
| C27 | 4 | 5 | 4 | 4 | 4 | 21 |
| C28 | 5 | 5 | 5 | 5 | 5 | 25 |
| C29 | 5 | 5 | 4 | 5 | 5 | 24 |
| C30 | 5 | 5 | 4 | 5 | 5 | 24 |
| C31 | 4 | 3 | 5 | 5 | 4 | 21 |
| C32 | 4 | 4 | 5 | 4 | 5 | 22 |
| C33 | 4 | 5 | 4 | 4 | 4 | 21 |
| C34 | 5 | 5 | 5 | 5 | 5 | 25 |
| C35 | 5 | 5 | 4 | 5 | 5 | 24 |
| C36 | 4 | 4 | 4 | 4 | 4 | 20 |
| C37 | 4 | 5 | 4 | 4 | 4 | 21 |
| C38 | 4 | 4 | 4 | 4 | 4 | 20 |
| C39 | 4 | 5 | 4 | 4 | 4 | 21 |
| C40 | 4 | 4 | 4 | 4 | 4 | 20 |
| C41 | 4 | 4 | 4 | 5 | 4 | 21 |
| C42 | 5 | 5 | 5 | 5 | 5 | 25 |
| C43 | 4 | 5 | 4 | 4 | 4 | 21 |
| C44 | 4 | 5 | 4 | 4 | 4 | 21 |
| C45 | 5 | 4 | 5 | 5 | 5 | 24 |
| C46 | 4 | 4 | 5 | 4 | 4 | 21 |
| C47 | 5 | 5 | 4 | 5 | 5 | 24 |
| C48 | 5 | 5 | 5 | 5 | 5 | 25 |
| C49 | 5 | 5 | 5 | 5 | 5 | 25 |
| C50 | 4 | 4 | 5 | 4 | 4 | 21 |
| C51 | 5 | 4 | 4 | 5 | 5 | 23 |
| C52 | 4 | 4 | 4 | 4 | 4 | 20 |
| C53 | 5 | 5 | 5 | 5 | 5 | 25 |
| C54 | 5 | 5 | 5 | 5 | 5 | 25 |
| C55 | 4 | 4 | 4 | 4 | 4 | 20 |
| C56 | 5 | 5 | 5 | 5 | 5 | 25 |
| C57 | 5 | 5 | 4 | 5 | 5 | 24 |
| C58 | 4 | 5 | 4 | 4 | 4 | 21 |
| C59 | 5 | 5 | 5 | 5 | 5 | 25 |
| C60 | 5 | 5 | 4 | 5 | 5 | 24 |
| C61 | 4 | 5 | 4 | 4 | 4 | 21 |
| C62 | 4 | 4 | 4 | 4 | 4 | 20 |
| C63 | 5 | 4 | 5 | 5 | 5 | 24 |
| C64 | 5 | 5 | 4 | 5 | 5 | 24 |
| C65 | 5 | 4 | 4 | 5 | 5 | 23 |
| C66 | 5 | 4 | 5 | 5 | 5 | 24 |
| C67 | 5 | 4 | 5 | 5 | 5 | 24 |
| C68 | 5 | 5 | 4 | 5 | 5 | 24 |
| C69 | 5 | 5 | 5 | 5 | 5 | 25 |
| C70 | 5 | 5 | 5 | 5 | 5 | 25 |

## Candidate Notes

| Candidate | Note |
|---|---|
| C01 | Keep. R0 首要是 owned path 与 legacy dirty 隔离；否则 controller 无法判断本轮 proof 属于哪个 change。 |
| C02 | Merge with closeout hygiene. commit 拆分有价值，但应以 proof class 和 reviewability 分层，不应变成机械多 commit 要求。 |
| C03 | Keep. `8.C2` 在 L3 未签前必须 open；UI test pass 只能说明 local/unit/simulator 通过。 |
| C04 | Keep. MCP project path、scheme、simulator、xcresult 是防 main/UIUE 和 Pro/Pro Max 漂移的系统证据。 |
| C05 | Keep. `cooling + ivory` 是当前 L3 真实阻断，R0 若继续只看 deepSpace 会错过现行失败路径。 |
| C06 | Keep. 外层摘要颜色联动是 readback/presentation 同步问题，不是 expanded row 局部样式问题。 |
| C07 | Keep. 氛围灯 8 色崩溃应追到 contract alias 与 mapper，不应只修色板表层。 |
| C08 | Keep. badge/options/toggle 合法 enum、store 写回、summary readback 是同一个 SSOT 风险。 |
| C09 | Keep. `vehicle.gear` 当前不能被默认为 10 族直接触摸完成；它牵涉 context force 和只读仪表边界。 |
| C10 | Keep. 稳定 identifier 是 UI test 和人审复现的基础，但可与矩阵 proof 规则合并。 |
| C11 | Keep. 预烘焙白壳是资产治理问题，必须上升为“内容图不带 chrome”的规则。 |
| C12 | Rewrite/Merge. placeholder 边界重要，但应并入 C68 final-art-deferred 规则，避免单独低价值重复。 |
| C13 | Keep. VPA/orb 层级不是 frame height 阈值能证明的，必须纳入视觉层级和 L3 punchlist。 |
| C14 | Keep. 四态文案和 preset state 绑定是 SD16 的状态机问题，应防所有态落成 listen。 |
| C15 | Keep. settings/refresh 与 capsule 的遮挡/对齐属于 Layout Integrity Gate 的一类，应合并到 C56/C57。 |
| C16 | Keep. 左右列首行对齐、间距阈值也是 frame gate，不应只靠截图肉眼复核。 |
| C17 | Keep. closeout 最小门应分层列出 local/unit/simulator/OpenSpec，不得汇总成单个 green。 |
| C18 | Keep. 独立只读审计 pathspec 是 R0 防污染的必要 gate，尤其 dirty tree 已有多源改动。 |
| C19 | Keep. GPT Image 2 和 anchor 只能定义方向与审美 bar，不能逐像素反推工程结构。 |
| C20 | Keep. final capsule art、true-device GPU/FPS、完整 VPA 动效、L3 人审必须显式残留，不能被 R0 关闭。 |
| C21 | Rewrite. `StateCellInteractionPolicy` 必须是 consumer projection，不能成为第三份 value/type/range SSOT。 |
| C22 | Keep. 控件能力应从 `UIValueTypeMapper`、`ValueRangeMapper`、contract enum 派生，避免 View 硬编码行为。 |
| C23 | Keep. 10 族矩阵必须按 family、cell、value type、gesture、writeback、readback、proof case 分列。 |
| C24 | Keep. family 覆盖、value type 覆盖、gesture 覆盖是三张不同账，必须分开算。 |
| C25 | Keep. 只读或演示态必须去掉按钮形态和可点语义，否则会继续制造假 affordance。 |
| C26 | Keep. `.dial` 和 `.percent` 是本轮暴露的手势语义核心，ring tap、drag、cross-zero、snap、a11y 必须统一。 |
| C27 | Keep/Merge. stepper 空间语义已暴露，left/right、scrub、边界和 readback 应并入 value type gesture matrix。 |
| C28 | Keep. toggle 统一 `on/off` 会写非法 state，必须按 contract enum pair 翻转。 |
| C29 | Keep. badge/options/preset 只能来自 contract-derived options，不允许把当前文本当唯一 option。 |
| C30 | Keep. color swatch 必须同时证明 contract/semantic mapper、外层卡颜色、summary、expanded row 同步。 |
| C31 | Rewrite. summary primary touch 默认只展开；若要直接调节，必须先 grill 决策并补 proof。 |
| C32 | Keep. expanded row 的透明 primary overlay 可能遮挡同级控件，应纳入 hit-test 和 frame proof。 |
| C33 | Keep. 每个可点区域需要稳定 accessibility identifier，但应落入矩阵字段而非独立漂浮要求。 |
| C34 | Keep. 所有写回必须统一走 `DemoVehicleStateStore` 或 mock transition，View 层局部 state 是边界破坏。 |
| C35 | Keep. store、expanded row、summary、颜色语义、dialogue/readback 至少两层同步，是防“值变了但读回没变”的系统门。 |
| C36 | Keep. sequencer/stagger 可能造成 UI test 读中间态，需要稳定 marker 或等待策略。 |
| C37 | Merge. tap、long press、drag、a11y adjustable 属于矩阵 proof 维度，应与 C23/C24/C48 合并。 |
| C38 | Keep. Reduce Motion/Transparency 下状态仍需靠文本、图标、数值读回，不可只靠动画或玻璃高光。 |
| C39 | Keep. 44pt touch target 是交互门的底线，尤其 ring、swatch、segment、close、settings/refresh。 |
| C40 | Keep. VoiceOver/a11y 替代入口是避免空间手势成为唯一能力的架构问题。 |
| C41 | Rewrite. `verify-uiue-interactions` 可做，但必须先 grill，并先作为 UIUE 专门门。 |
| C42 | Keep. 自动门只能覆盖稳定 unit/UI tests，不能混入 L3、人审或审美截图判断。 |
| C43 | Keep. 固定 `iPhone 17 Pro Max` 和失败 frame 输出可减少设备漂移与遮挡定位成本。 |
| C44 | Keep. 反例或边界断言能防 happy path 假绿，尤其 interaction tests。 |
| C45 | Keep. L3 punchlist 发现一点必须 iceberg teardown 到同 value type、gesture family、proof path。 |
| C46 | Keep. changing 过程态不应展示假稳定控件，应进入 interaction policy。 |
| C47 | Keep. 中文 display title 与 contract id 映射必须验证，否则 UI text 兜底会掩盖非法 state。 |
| C48 | Keep. 每个 proof 记录 proof class，防 simulator UI test 被写成人工手感通过。 |
| C49 | Keep. 禁止 View 内新增第二套 range/enum formatter，应有 grep gate 或 review gate 固化。 |
| C50 | Keep. interaction debt 应 merge-only 挂到矩阵项，避免每个疑点都开新战线。 |
| C51 | Keep. R2 L0 必须吸收 `cooling + ivory` 这个真实 L3 失败，不应只继承旧 deepSpace 主 case。 |
| C52 | Rewrite. 组合边界有价值，但必须标为候选最小集，不构成最终验收充分条件。 |
| C53 | Keep. 10 族代表交互矩阵应是 R2 L0 前置，否则截图后才发现交互假绿。 |
| C54 | Keep. L1 sentinel 只挡塌陷和大位移，不能用 RMSE/WARN 推导审美结论。 |
| C55 | Keep. L2 OCR/contrast 应保留，但必须明示不能覆盖遮挡、留白、玻璃 artifact、手感和高级感。 |
| C56 | Keep. Layout Integrity Gate 是 R2b 最大结构缺口，应从 UI tree frame 算 overlap/gap/budget/safe area。 |
| C57 | Keep. Gate 覆盖关系必须包括 capsule、settings/refresh、orb、dialogue、cards、mic dock 的相互边界。 |
| C58 | Keep. Visual Spacing Sentinel 输出 PASS/WARN/FAIL 和 crop，才能避免“只给截图让人找”。 |
| C59 | Keep. L0 必须继续用 on-screen `xcrun simctl io booted screenshot`，禁止 Preview/ImageRenderer/XCTAttachment/H5 替代。 |
| C60 | Keep. L0 harness 必须验证 launchArg、theme、route、device、UI tree、screenshot path、proof_class 全字段。 |
| C61 | Keep. evidence checker 默认只读，显式 `--write-summary` 才写，是 read-only 审计可复跑的基础。 |
| C62 | Keep/Merge. 胶囊 5 context 状态 proof 重要，但应与 C63 的数据 proof vs 审美 proof 分层写。 |
| C63 | Keep. context 四维输入正确和 diorama 视觉好看必须分开，数据 proof 不能冒充审美 proof。 |
| C64 | Keep. VPA/orb 四态 L0/UI tree proof 对 SD16 非常关键，至少防 idle/listen/think/speak 文案混用。 |
| C65 | Keep. orb 米白/深空都要验，米白不能靠大外扩辉光抢层级。 |
| C66 | Keep. L3 模板必须覆盖遮挡、留白、层级、交互手感、玻璃 artifact、状态表达六栏。 |
| C67 | Keep. 人审应先看 current screenshot/crop，再看 UI tree/test result，防自动绿灯锚定。 |
| C68 | Keep. closeout 必须写 placeholder/final-art-deferred，尤其 `ContextCapsule` asset。 |
| C69 | Keep. R2 失败只能回写发现和下一轮返修，禁止把 `tasks.md` 或 coverage index 标完成。 |
| C70 | Keep. R2 后独立只读审计是进入 R3 的防线，重点复核 proof boundary、dirty scope、tasks/docs 级联。 |

## Rationale

我把 `openspec/changes/ui-presentation/specs/ui-presentation/spec.md` 作为本轮行为契约权威：它规定 `ui_value_type` 是消费侧派生而非 producer 新字段，见 `spec.md:81`；规定 Liquid Glass 只在功能层，内容卡用自研 glow，见 `spec.md:136`；规定 `default_scope` 读 SSOT 且 UIUE 不手写默认表，见 `spec.md:171`；规定 demo interactions 全是 mock-frontstage，不接真 runtime，见 `spec.md:206`；规定展开控件写 mock store 并复用 `ValueRangeMapper`，禁止 View 重写 range 逻辑，见 `spec.md:216`；规定 L0-L3 proof gates 且 simulator/local/mock 不得升级为 product pass，见 `spec.md:252`。

路线依赖上，`docs/uiue-roadmap-2026-06-27-post-8c2-baseline.md` 明确当前不是直接接 runtime，而是先 R0 收 8.C2 返修、R1 建交互真值门、R2 重跑 L0-L3，见 `roadmap:32`；`8.C2` 当前仍是 `PARTIAL_PENDING_L3`，见 `roadmap:39`；`SHOULD_GRILL` 只是后续决策点，不能直接当 OpenSpec SHALL 或完成证据，见 `roadmap:56`；L0 继续必须是 on-screen `simctl`，L3 只有磊哥能签，见 `roadmap:104`。

系统风险的中心不是“某个控件没修”，而是 SSOT 和 proof boundary 被 UI presentation 层悄悄扩权。Interaction retrospective 已指出：旧实现把“能写回”误当成“手感语义完整”，缺 value type x gesture x writeback x readback 矩阵，见 `interaction-retrospective:23`；它也明确 `spec.md` 才是 ui-presentation 行为契约权威，coverage index 不是 OpenSpec SSOT，见 `interaction-retrospective:48` 到 `interaction-retrospective:51`。

因此 Round 02 的 Purple 建议是：保留全部 70 项，但把重复项合并成少数 canonical hard gates。R0 守 dirty/proof/status，R1 守 interaction SSOT 和 no-fake-affordance，R2 守 L0-L3 proof 分层，R2b 守 layout/capsule/orb 结构门。任何 Liquid4All 或 runtime 借鉴都只能 `reference only`，不得把 UIUE simulator/mock proof 写成 mainline runtime、mobile、true_device、L3、V-PASS 或 A-2 收口。

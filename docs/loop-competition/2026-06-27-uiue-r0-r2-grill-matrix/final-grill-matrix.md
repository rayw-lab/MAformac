# UIUE R0/R1/R2 Final Grill Matrix

日期：2026-06-27
status：READY_FOR_HUMAN_REVIEW
candidate_count：70
reviewer_count：6（Round 01: RED/GREEN/BLUE；Round 02: PURPLE/ORANGE/BLACK）
proof_boundary：local / unit / simulator；不声明 L3 / V-PASS / mobile / true_device / A-2 complete

## Human Review Summary

- P0：41 项，建议先进入 R0/R1/R2 hard gate 或专项 grill。
- P1：18 项，建议作为同阶段 checklist / regression / evidence hygiene。
- P2：11 项，不删除；建议 rewrite 或 merge-only 挂账，避免低杠杆但真实风险丢失。
- 本矩阵不关闭 `8.C2`，不替代磊哥 L3 人审。

## Canonical Decision Groups

| Group | Candidates | Controller decision |
| --- | --- | --- |
| R0 closeout discipline | C01-C04, C17-C20 | pathspec、commit/proof 分层、8.C2 open、residual risks、read-only audit。 |
| Current product blockers | C05-C08, C13-C16 | `cooling + ivory`、外层颜色联动、8 色、VPA 光晕/四态、按钮/列对齐。 |
| R1 interaction matrix | C21-C50 | `family x value type x gesture x writeback x readback x proof`，禁止 View 第二 SSOT。 |
| R2 evidence gates | C51-C61 | pre-L0 interaction、on-screen L0、L1/L2 能力边界、只读 checker。 |
| R2b capsule/VPA/layout | C11-C16, C56-C68 | asset governance、Layout Integrity、Visual Spacing、capsule/VPA 状态和主题、人审 punchlist。 |
| R3 entry guard | C69-C70 | R2 fail 不写完成；R2 pass 后仍需独立 read-only audit。 |

## Six-Reviewer Matrix

| ID | Stage | Grill question | R1-RED | R1-GREEN | R1-BLUE | R2-PURPLE | R2-ORANGE | R2-BLACK | Avg | Priority | Route | Action | Recommendation |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- | --- | --- | --- |
| C01 | R0 | 当前 8.C2 返修 dirty diff 的 owned path 是否被精确列出，且与 commander docs、旧 evidence、roadmap/handoff dirty 完全隔离？ | 24 | 24 | 19 | 24 | 24 | 24 | 23.2 | P1 | R0 closeout / dirty scope | Keep | 保留为 hard gate；提交前列 owned/unowned/generated/no-touch pathspec。 |
| C02 | R0 | 当前 8.C2 返修是否需要拆成“交互修复”“胶囊/VPA视觉阻断”“docs lessons/baseline”多个 commit，避免一个 commit 混合不同 proof class？ | 21 | 24 | 18 | 20 | 20 | 21 | 20.7 | P2 | R0 commit strategy | Keep | 改写为按 ownership + proof class 拆 commit；不要强迫一次修复拆过细。 |
| C03 | R0 | `8.C2` closeout 是否必须显式保留 open 状态，禁止因为 `UIC2VisualAcceptanceUITests` 通过而勾 `tasks.md`？ | 25 | 25 | 23 | 25 | 25 | 25 | 24.7 | P0 | R0 proof boundary | Keep | P0 保留；任何自动化通过都不能勾 8.C2 或写 A-2 complete。 |
| C04 | R0 | R0 closeout 是否必须同时记录 MCP project path、scheme、simulator name/id、xcresult，防止 iPhone 17 Pro / Pro Max 或 main/UIUE worktree 漂移复发？ | 24 | 25 | 20 | 24 | 25 | 22 | 23.3 | P0 | R0 evidence attribution | Keep | P0 保留；receipt 必列 project/scheme/device/UDID 或 simulator name/xcresult。 |
| C05 | R0 | R0 是否必须把 `cooling + ivory` 作为当前人审阻断的第一 L0/L3 case，而不是继续只看 deepSpace 旧 case？ | 24 | 21 | 24 | 23 | 22 | 25 | 23.2 | P0 | R0/R2 current blocker | Keep | P0 保留；`cooling + ivory` 是 current blocker 第一 case。 |
| C06 | R0 | R0 是否必须把“空调制冷/制热外层摘要颜色联动”作为 hard regression，而不是只验证 expanded row 内部值变化？ | 23 | 21 | 24 | 24 | 23 | 24 | 23.2 | P0 | R0 product regression | Keep | P0 保留；外层 summary 颜色和 readback 必须随制冷/制热同步。 |
| C07 | R0 | R0 是否必须把氛围灯 8 色选择崩溃和 alias 映射纳入 contract-derived options 复核，而不是只修当前色板 UI？ | 23 | 21 | 21 | 23 | 23 | 23 | 22.3 | P1 | R0 contract options | Keep | 保留；从 contract/options/mapper 派生 8 色和 alias，测试崩溃 + readback。 |
| C08 | R0 | R0 是否必须把 badge/options/toggle 的合法 enum 写回和 summary readback 一起验证，避免“看起来换了但 store 非法/摘要不变”？ | 24 | 25 | 21 | 25 | 23 | 23 | 23.5 | P0 | R0/R1 enum writeback | Keep | P0 保留；badge/options/toggle 要验证合法 enum、store、summary。 |
| C09 | R0 | R0 是否必须明确 `vehicle.gear` 当前仍不是通用直接触摸控制，避免把演绎控制台 mock context 误写成 10 族直接交互完成？ | 24 | 20 | 20 | 24 | 22 | 22 | 22.0 | P1 | R1 SHOULD_GRILL / gear | Keep | 保留为 SHOULD_GRILL；明确 gear 仍非通用直接触控完成。 |
| C10 | R0 | R0 是否必须要求任何新增 accessibility identifier 不与已有 identifier 重复、遮蔽或造成 UI test 查错元素？ | 21 | 21 | 21 | 21 | 23 | 19 | 21.0 | P2 | R1 test identifiers | Keep | 保留；增加 identifier uniqueness / wrong-element guard。 |
| C11 | R0 | R0 是否必须把 `ContextCapsule` asset 的预烘焙白壳问题写成同类资产治理规则，而不是只裁当前 PNG？ | 21 | 18 | 24 | 23 | 19 | 23 | 21.3 | P2 | R2b asset governance | Merge/Keep | 保留并并入 asset governance；预烘焙 chrome 禁入内容资产。 |
| C12 | R0 | R0 是否必须确认胶囊图片是 placeholder，不把当前裁切尺寸和构图当 final art 决策？ | 19 | 18 | 22 | 20 | 17 | 21 | 19.5 | P2 | R2b placeholder boundary | Rewrite | Rewrite；标 placeholder/final-art-deferred，不把裁剪尺寸当 final。 |
| C13 | R0 | R0 是否必须把 VPA/orb 光晕过大列为视觉层级阻断，而不是只用 frame height 小于阈值证明“未遮挡”？ | 23 | 21 | 24 | 24 | 22 | 24 | 23.0 | P0 | R2b VPA hierarchy | Keep | P0 保留；用 halo budget + crop + L3 punchlist，不只看 frame。 |
| C14 | R0 | R0 是否必须确认 `DemoOrbView` 四态文案和 preset state 绑定不会把所有完成态都显示成 listen？ | 21 | 20 | 24 | 22 | 22 | 24 | 22.2 | P0 | R2b VPA state binding | Keep | P0 保留；四态文案/preset 绑定必须有 proof。 |
| C15 | R0 | R0 是否必须补一条“设置/刷新按钮不遮挡 capsule，且刷新与设置对齐”的 regression test，防止蓝框问题复发？ | 20 | 23 | 25 | 21 | 23 | 20 | 22.0 | P0 | R0/R2b top layout | Keep | P0 保留；settings/refresh 与 capsule frame gate，失败打印三者 frame。 |
| C16 | R0 | R0 是否必须补一条“端状态左右列首行对齐、间距在阈值内”的 regression test，防止黄框问题复发？ | 20 | 23 | 21 | 21 | 22 | 20 | 21.2 | P2 | R0/R2b status alignment | Keep | 保留；端状态列对齐进入 layout gate，输出 y 差/gap/crop。 |
| C17 | R0 | R0 是否必须将 `git diff --check`、目标 unit、OpenSpec strict、Pro Max UI test 都作为 closeout 最小门，并按 proof class 分层报告？ | 24 | 25 | 22 | 24 | 25 | 24 | 24.0 | P0 | R0 closeout gates | Keep | P0 保留；closeout 最小门按 proof class 分层。 |
| C18 | R0 | R0 是否必须要求 independent read-only audit 复核本轮提交 pathspec，防止旧 roadmap/CURRENT/handoff dirty 混入？ | 24 | 25 | 18 | 24 | 24 | 21 | 22.7 | P1 | R0 read-only audit | Keep | 保留；提交前 read-only audit 复核 pathspec 和 non-claims。 |
| C19 | R0 | R0 是否必须把 “GPT Image 2 / anchor 只当方向，不逐像素照抄” 写入后续 prompt/handoff，防止新 agent 再按锚点硬仿？ | 23 | 17 | 24 | 21 | 17 | 21 | 20.5 | P2 | Governance / prompt hygiene | Rewrite | Rewrite 为 prompt/handoff 规则；anchor 只作方向，不作像素规范。 |
| C20 | R0 | R0 是否必须定义“本轮不修”的剩余风险清单，尤其 final capsule art、true-device GPU/FPS、VPA 完整动效、L3 人审？ | 25 | 25 | 21 | 24 | 23 | 24 | 23.7 | P0 | R0 residual risks | Keep | P0 保留；列 final art/GPU/VPA 动效/L3 等未签风险。 |
| C21 | R1 | 是否需要将 `StateCellInteractionPolicy` 定义为 presentation consumer policy，而不是新建第三份 value/type/range SSOT？ | 24 | 24 | 18 | 24 | 23 | 21 | 22.3 | P1 | R1 policy boundary | Keep | 保留但改写；policy 只能是 presentation consumer projection。 |
| C22 | R1 | 是否应该从现有 `UIValueTypeMapper`、`ValueRangeMapper`、contract enum 推导交互能力，而不是在 View 层写硬编码控件行为？ | 25 | 24 | 21 | 24 | 24 | 24 | 23.7 | P0 | R1 mapper-derived controls | Keep | P0 保留；控件能力从 mapper/contract 派生。 |
| C23 | R1 | `10 族 x 关键交互 cell` 矩阵是否要按 family、cell、value type、gesture、writeback、summary readback、proof case 分列？ | 24 | 21 | 21 | 24 | 24 | 23 | 22.8 | P1 | R1 matrix schema | Keep | 保留；矩阵列固定为 family/cell/value/gesture/writeback/readback/proof。 |
| C24 | R1 | 10 族矩阵是否必须区分 family 覆盖、value type 覆盖、gesture 覆盖，防止“10族都点过”误当“所有手感语义都对”？ | 24 | 21 | 24 | 25 | 24 | 24 | 23.7 | P0 | R1 coverage taxonomy | Keep | P0 保留；family、value type、gesture 覆盖分别计数。 |
| C25 | R1 | 哪些 cell 应保持只读或演示态，且只读态 UI 是否必须去除按钮形态、hover/pressed 形态和可点光标语义？ | 24 | 19 | 24 | 24 | 23 | 24 | 23.0 | P0 | R1 read-only affordance | Keep | P0 保留；只读态必须移除可点击视觉语义。 |
| C26 | R1 | `.dial` 和 `.percent` 是否需要统一 ring tap zones、drag direction、cross-zero delta、step snap、a11y adjustable 规则？ | 25 | 25 | 25 | 24 | 25 | 25 | 24.8 | P0 | R1 ring controls | Keep | P0 保留；ring/percent/dial 空间语义、drag、snap、a11y 为硬门。 |
| C27 | R1 | `.stepper` 分段条是否需要定义 tap left/right、drag scrub、最小/最大边界、disabled segment 和 readback 规则？ | 25 | 25 | 25 | 21 | 25 | 23 | 24.0 | P0 | R1 stepper controls | Keep | P0 保留；stepper left/right、drag、边界和 readback 独立验。 |
| C28 | R1 | toggle 是否必须按 contract enum pair 翻转，而不是统一写 `on/off`？ | 24 | 25 | 21 | 25 | 23 | 22 | 23.3 | P0 | R1 toggle enum | Keep | P0 保留；toggle 从 contract enum pair 翻转。 |
| C29 | R1 | badge/options/preset 是否必须只暴露 contract-derived 可选值，且禁止默认把当前文本当唯一 option？ | 24 | 25 | 21 | 24 | 23 | 23 | 23.3 | P1 | R1 options/preset | Keep | 保留；preset/options 只暴露 contract-derived 值。 |
| C30 | R1 | color swatch 是否必须从 contract / semantic color mapper 派生，且点击 swatch 后外层卡片颜色、摘要和 expanded row 同步？ | 24 | 25 | 24 | 24 | 23 | 23 | 23.8 | P0 | R1 color swatch | Keep | P0 保留；swatch 写回后同步外层色、summary、expanded row。 |
| C31 | R1 | summary card 的 primary touch 是否应该只负责展开，还是允许直接调节部分 primary value？ | 21 | 20 | 24 | 21 | 21 | 20 | 21.2 | P2 | R1 summary touch | Rewrite | Rewrite；summary 默认只展开，直接调节需单独 grill。 |
| C32 | R1 | expanded row 的透明 primary overlay 是否会遮挡同级 `+/-`、chevron、swatch 或 close button？ | 24 | 24 | 24 | 22 | 25 | 23 | 23.7 | P0 | R1 overlay hit-testing | Keep | P0 保留；overlay hit-testing 防遮挡同级控件。 |
| C33 | R1 | 每个可点区域是否都需要稳定 accessibility identifier，用于坐标级 UI test 和人审复现？ | 21 | 25 | 21 | 21 | 23 | 20 | 21.8 | P1 | R1 accessibility ids | Keep | 保留；稳定 id + 查错元素 guard。 |
| C34 | R1 | 交互写回是否必须统一走 `DemoVehicleStateStore` / mock transition，而不是 View 内局部 state？ | 25 | 25 | 21 | 25 | 24 | 25 | 24.2 | P0 | R1 store writeback | Keep | P0 保留；所有写回走 DemoVehicleStateStore/mock transition。 |
| C35 | R1 | 写回后是否必须验证 store value、expanded row value、summary text、色彩语义和 dialogue/readback 至少两个层级同步？ | 24 | 25 | 24 | 24 | 24 | 24 | 24.2 | P0 | R1 readback sync | Keep | P0 保留；至少 store + expanded/summary/readback 两层同步。 |
| C36 | R1 | 多意图或连续操作时，sequencer / stagger 是否可能让 UI test 读到中间态而误判，需要等待策略或稳定 marker？ | 21 | 20 | 20 | 20 | 24 | 20 | 20.8 | P2 | R1 sequencer stability | Keep | 保留；加稳定 marker/wait strategy 防中间态误判。 |
| C37 | R1 | interaction test 是否要区分 tap、long press、drag、accessibility adjustable action 四类 proof？ | 25 | 25 | 25 | 21 | 24 | 21 | 23.5 | P0 | R1 gesture proof | Keep | P0 保留；tap/long press/drag/a11y proof 分开。 |
| C38 | R1 | Reduce Motion / Reduce Transparency 下，交互反馈是否仍能被读回，不能只靠动画或玻璃高光表达状态？ | 21 | 25 | 24 | 20 | 21 | 21 | 22.0 | P1 | R1 accessibility settings | Keep | 保留；Reduce Motion/Transparency 下不能靠动画/玻璃单通道。 |
| C39 | R1 | 44pt touch target 是否要成为矩阵硬门，尤其 ring、swatch、stepper segment、close、settings/refresh？ | 23 | 25 | 25 | 21 | 23 | 23 | 23.3 | P0 | R1 touch target | Keep | P0 保留；44pt touch target 做 HMI 底线。 |
| C40 | R1 | 是否需要单独验证 VoiceOver/a11y 替代入口，防止空间手势成为唯一能力？ | 19 | 20 | 20 | 20 | 20 | 18 | 19.5 | P2 | R1 a11y fallback | Rewrite | P2 rewrite；a11y fallback 作为替代入口 proof，不冒充完整 VO 人审。 |
| C41 | R1 | 是否需要 `make verify-uiue-interactions`，且先作为 UIUE 专门门而不是立刻塞进 `make verify-all`？ | 22 | 24 | 18 | 21 | 24 | 20 | 21.5 | P1 | R1 make target | Rewrite | P1 rewrite；先专门 gate，不直接并 verify-all，需 grill 决策。 |
| C42 | R1 | `verify-uiue-interactions` 是否应该只跑稳定 unit/UI tests，避免把人工 L3 或截图审美纳入自动门？ | 24 | 24 | 18 | 25 | 24 | 23 | 23.0 | P0 | R1 gate boundary | Keep | P0 保留；自动门只跑稳定 local/unit/simulator。 |
| C43 | R1 | UI test 是否必须固定 `iPhone 17 Pro Max`，并在失败信息中打印关键 frame，方便定位遮挡/留白问题？ | 24 | 25 | 21 | 21 | 25 | 22 | 23.0 | P1 | R1 UI test device | Keep | 保留；固定 Pro Max 并输出关键 frame。 |
| C44 | R1 | 对所有新增 interaction tests，是否需要同时有一个反例或边界断言，防止只测 happy path？ | 22 | 24 | 21 | 21 | 24 | 20 | 22.0 | P1 | R1 negative cases | Keep | 保留；新增 test 必有反例/边界断言。 |
| C45 | R1 | L3 punchlist 发现一个小交互 bug 后，是否强制触发 iceberg teardown 到同 value type、同 gesture family、同 proof path？ | 24 | 20 | 24 | 24 | 24 | 24 | 23.3 | P0 | R1 iceberg teardown | Keep | P0 保留；L3 小 bug 触发同 value/gesture/proof iceberg。 |
| C46 | R1 | 交互矩阵是否需要纳入“过程态/changing 态”规则，避免正在变化的卡片显示假稳定控件？ | 23 | 24 | 24 | 21 | 22 | 21 | 22.5 | P1 | R1 process state | Keep | 保留；changing 态不显示假稳定控件。 |
| C47 | R1 | summary/readback 是否需要验证中文 display title 与 contract id 的映射，防止 UI text 兜底掩盖非法 state？ | 23 | 25 | 21 | 24 | 23 | 22 | 23.0 | P1 | R1 display mapping | Keep | 保留；中文 display title 与 contract id 双向映射验证。 |
| C48 | R1 | 是否需要记录每个 interaction proof 的 proof class，禁止把 simulator UI test 写成人工手感通过？ | 25 | 25 | 22 | 25 | 24 | 24 | 24.2 | P0 | R1 proof class | Keep | P0 保留；每项 proof 明确 proof class。 |
| C49 | R1 | 是否需要禁止在 View 内新增第二套 range/enum formatter，并用 code review 或 grep gate 固化？ | 24 | 24 | 19 | 25 | 24 | 24 | 23.3 | P0 | R1 no duplicate formatter | Keep | P0 保留；禁止 View 内第二套 range/enum formatter，设 grep/code review gate。 |
| C50 | R1 | 是否需要定义 interaction debt 的 merge-only 规则：不是每个可疑点都开工，但必须挂到最近的矩阵项下不丢失？ | 21 | 19 | 18 | 21 | 21 | 17 | 19.5 | P2 | R1 debt tracking | Rewrite | P2 rewrite；debt 必带 owner/proof/defer reason/trigger，不能只说 merge-only。 |
| C51 | R2 | R2 L0 case 是否必须新增或替换为 `cooling + ivory`，覆盖本轮人审真实发现，而不是只保留旧 deepSpace 主 case？ | 23 | 25 | 24 | 23 | 22 | 25 | 23.7 | P0 | R2 current L0 case | Keep | P0 保留；R2 L0 第一 case 放 current blocker。 |
| C52 | R2 | R2 L0 是否应该补 `heating + ivory`、`safety_refusal + ivory`、`capsule videoLoop + deepSpace`、`U17 golden path` 的最小组合边界？ | 24 | 24 | 23 | 20 | 20 | 20 | 21.8 | P1 | R2 case matrix | Keep | 保留；补边界 case 但不得稀释 `cooling + ivory`。 |
| C53 | R2 | R2 是否需要把 10 族代表交互矩阵作为 L0 前置，而不是 L0 截图之后才发现交互假绿？ | 24 | 24 | 23 | 25 | 23 | 24 | 23.8 | P0 | R2 pre-L0 interaction | Keep | P0 保留；交互矩阵先于 L0 重跑。 |
| C54 | R2 | R2 的 L1 sentinel 是否需要明确“只挡塌陷/大位移”，并禁止用 RMSE/WARN 推导审美结论？ | 25 | 23 | 22 | 25 | 25 | 24 | 24.0 | P0 | R2 L1 boundary | Keep | P0 保留；L1 只挡塌陷/大位移，报告标 not aesthetic。 |
| C55 | R2 | R2 的 L2 OCR/contrast 是否需要继续保留，但明确不能覆盖遮挡、留白、玻璃 artifact、手感和高级感？ | 23 | 23 | 23 | 20 | 24 | 22 | 22.5 | P1 | R2 L2 boundary | Keep | 保留；L2 OCR/contrast 不覆盖遮挡/留白/手感/高级感。 |
| C56 | R2 | 是否需要新增 Layout Integrity Gate：从 UI tree frame 计算 `overlap_pairs`、`min_gaps`、`zone_budget`、`safe_area_violations`？ | 24 | 24 | 25 | 25 | 25 | 25 | 24.7 | P0 | R2b Layout Integrity | Keep | P0 保留；实现 Layout Integrity Gate。 |
| C57 | R2 | Layout Integrity Gate 是否应覆盖 capsule vs settings/refresh、orb vs capsule/dialogue、dialogue vs cards、cards vs mic dock？ | 24 | 24 | 25 | 24 | 24 | 24 | 24.2 | P0 | R2b layout pairs | Keep | P0 保留；覆盖 capsule/orb/dialogue/cards/dock pair。 |
| C58 | R2 | Visual Spacing Sentinel 是否应输出 PASS/WARN/FAIL 和可复现 crop，而不是仅输出一张截图让人肉找问题？ | 23 | 25 | 24 | 21 | 24 | 21 | 23.0 | P0 | R2b spacing sentinel | Keep | P0 保留；spacing sentinel 输出 PASS/WARN/FAIL + crop。 |
| C59 | R2 | L0 capture 是否必须继续使用 on-screen `xcrun simctl io booted screenshot`，禁止 Preview/ImageRenderer/XCTAttachment/H5 替代？ | 25 | 25 | 22 | 25 | 25 | 25 | 24.5 | P0 | R2 L0 capture | Keep | P0 保留；L0 必须 on-screen simctl screenshot。 |
| C60 | R2 | L0 harness 是否必须验证 launchArg、theme、route、device、UI tree evidence、screenshot path、proof_class 全字段？ | 24 | 25 | 21 | 24 | 25 | 24 | 23.8 | P0 | R2 manifest fields | Keep | P0 保留；manifest 校验 launchArg/theme/route/device/tree/screenshot/proof。 |
| C61 | R2 | R2 是否需要所有 evidence package checker 默认只读，只有显式 `--write-summary` 才允许改 summary？ | 22 | 24 | 19 | 21 | 25 | 21 | 22.0 | P1 | R2 checker mutability | Keep | 保留；checker 默认只读，写 summary 需显式 flag。 |
| C62 | R2 | R2 是否需要为胶囊 5 context 状态建立单独 proof：常态、行驶、泊车、下雨、夜晚？ | 20 | 21 | 23 | 20 | 20 | 20 | 20.7 | P2 | R2b capsule states | Keep | 保留；capsule 5 context 状态单独 proof。 |
| C63 | R2 | 胶囊 proof 是否要区分 “context 四维输入正确” 和 “diorama 视觉好看”，避免数据 proof 冒充审美 proof？ | 24 | 21 | 24 | 24 | 23 | 24 | 23.3 | P0 | R2b capsule proof split | Keep | P0 保留；context 数据 proof 与 diorama 审美 proof 分层。 |
| C64 | R2 | VPA/orb 是否需要四态 L0/UI tree proof，至少证明 idle/listen/think/speak 文案与 preset 不再混用？ | 23 | 24 | 25 | 24 | 22 | 24 | 23.7 | P0 | R2b VPA four states | Keep | P0 保留；idle/listen/think/speak 四态 UI tree/visual proof。 |
| C65 | R2 | VPA/orb 视觉 proof 是否需要米白/深空分别验，确保米白不再靠大外扩辉光抢层级？ | 22 | 24 | 24 | 23 | 20 | 24 | 22.8 | P0 | R2b VPA theme proof | Keep | P0 保留；米白/深空分别验 halo budget。 |
| C66 | R2 | L3 人审模板是否需要加入遮挡、留白、层级、交互手感、玻璃 artifact、状态表达六栏 punchlist？ | 24 | 24 | 24 | 24 | 24 | 24 | 24.0 | P0 | R2 L3 punchlist | Keep | P0 保留；L3 punchlist 六栏。 |
| C67 | R2 | L3 人审是否要要求 reviewer 先看 current screenshot/crop，再看 UI tree/test result，避免被自动绿灯锚定？ | 24 | 24 | 24 | 24 | 24 | 24 | 24.0 | P0 | R2 L3 review order | Keep | P0 保留；人审先看 current screenshot/crop 再看测试。 |
| C68 | R2 | R2 closeout 是否必须写明哪些项仍是 placeholder/final-art-deferred，尤其 `ContextCapsule` asset？ | 24 | 21 | 21 | 24 | 21 | 21 | 22.0 | P1 | R2 closeout placeholder | Keep | 保留；closeout 明确 placeholder/final-art-deferred。 |
| C69 | R2 | R2 如果失败，是否必须只回写发现和下一轮返修，禁止更新 `tasks.md` 或 coverage index 为完成？ | 25 | 21 | 23 | 25 | 25 | 25 | 24.0 | P0 | R2 failure closeout | Keep | P0 保留；R2 fail 只回写发现，不更新完成态。 |
| C70 | R2 | R2 通过后是否仍需独立 read-only audit 复核 proof boundary、dirty scope、tasks/docs 级联，才允许进入 R3 closeout？ | 25 | 24 | 22 | 25 | 25 | 24 | 24.2 | P0 | R3 entry audit | Keep | P0 保留；R3 前独立 read-only audit。 |

## Controller Notes

- 六位 reviewer 都建议不删除 70 项；最终保留全量，低优先级项按 rewrite/merge-only 处理。
- P0 不是实现授权；凡标为 `SHOULD_GRILL` 或新 gate 的项，下一步仍需要 grill / pre-mortem / 决策存档。
- Layout / spacing / UI tree frame gate 可以挡结构性问题，但不能签高级感、动效、玻璃质感或 L3。
- GPT Image 2 / anchor 只能作方向和审美 bar；后续资产必须正向分层设计，内容图不带预烘焙 capsule chrome。
- 所有 closeout 继续保持 proof class 分层：local/unit/simulator 不是 mobile、true_device、L3 或 V-PASS。

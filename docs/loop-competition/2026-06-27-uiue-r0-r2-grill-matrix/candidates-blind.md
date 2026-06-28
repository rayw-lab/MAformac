# UIUE R0/R1/R2 Fixed Grill Candidates - Blind Set

说明：本文件只列候选 grill 问题，不包含推荐答案、优先级或 judge 结论。Reviewer 需对全部 70 项评分。

| Candidate | Stage | Question |
|---|---|---|
| C01 | R0 | 当前 8.C2 返修 dirty diff 的 owned path 是否被精确列出，且与 commander docs、旧 evidence、roadmap/handoff dirty 完全隔离？ |
| C02 | R0 | 当前 8.C2 返修是否需要拆成“交互修复”“胶囊/VPA视觉阻断”“docs lessons/baseline”多个 commit，避免一个 commit 混合不同 proof class？ |
| C03 | R0 | `8.C2` closeout 是否必须显式保留 open 状态，禁止因为 `UIC2VisualAcceptanceUITests` 通过而勾 `tasks.md`？ |
| C04 | R0 | R0 closeout 是否必须同时记录 MCP project path、scheme、simulator name/id、xcresult，防止 iPhone 17 Pro / Pro Max 或 main/UIUE worktree 漂移复发？ |
| C05 | R0 | R0 是否必须把 `cooling + ivory` 作为当前人审阻断的第一 L0/L3 case，而不是继续只看 deepSpace 旧 case？ |
| C06 | R0 | R0 是否必须把“空调制冷/制热外层摘要颜色联动”作为 hard regression，而不是只验证 expanded row 内部值变化？ |
| C07 | R0 | R0 是否必须把氛围灯 8 色选择崩溃和 alias 映射纳入 contract-derived options 复核，而不是只修当前色板 UI？ |
| C08 | R0 | R0 是否必须把 badge/options/toggle 的合法 enum 写回和 summary readback 一起验证，避免“看起来换了但 store 非法/摘要不变”？ |
| C09 | R0 | R0 是否必须明确 `vehicle.gear` 当前仍不是通用直接触摸控制，避免把演绎控制台 mock context 误写成 10 族直接交互完成？ |
| C10 | R0 | R0 是否必须要求任何新增 accessibility identifier 不与已有 identifier 重复、遮蔽或造成 UI test 查错元素？ |
| C11 | R0 | R0 是否必须把 `ContextCapsule` asset 的预烘焙白壳问题写成同类资产治理规则，而不是只裁当前 PNG？ |
| C12 | R0 | R0 是否必须确认胶囊图片是 placeholder，不把当前裁切尺寸和构图当 final art 决策？ |
| C13 | R0 | R0 是否必须把 VPA/orb 光晕过大列为视觉层级阻断，而不是只用 frame height 小于阈值证明“未遮挡”？ |
| C14 | R0 | R0 是否必须确认 `DemoOrbView` 四态文案和 preset state 绑定不会把所有完成态都显示成 listen？ |
| C15 | R0 | R0 是否必须补一条“设置/刷新按钮不遮挡 capsule，且刷新与设置对齐”的 regression test，防止蓝框问题复发？ |
| C16 | R0 | R0 是否必须补一条“端状态左右列首行对齐、间距在阈值内”的 regression test，防止黄框问题复发？ |
| C17 | R0 | R0 是否必须将 `git diff --check`、目标 unit、OpenSpec strict、Pro Max UI test 都作为 closeout 最小门，并按 proof class 分层报告？ |
| C18 | R0 | R0 是否必须要求 independent read-only audit 复核本轮提交 pathspec，防止旧 roadmap/CURRENT/handoff dirty 混入？ |
| C19 | R0 | R0 是否必须把 “GPT Image 2 / anchor 只当方向，不逐像素照抄” 写入后续 prompt/handoff，防止新 agent 再按锚点硬仿？ |
| C20 | R0 | R0 是否必须定义“本轮不修”的剩余风险清单，尤其 final capsule art、true-device GPU/FPS、VPA 完整动效、L3 人审？ |
| C21 | R1 | 是否需要将 `StateCellInteractionPolicy` 定义为 presentation consumer policy，而不是新建第三份 value/type/range SSOT？ |
| C22 | R1 | 是否应该从现有 `UIValueTypeMapper`、`ValueRangeMapper`、contract enum 推导交互能力，而不是在 View 层写硬编码控件行为？ |
| C23 | R1 | `10 族 x 关键交互 cell` 矩阵是否要按 family、cell、value type、gesture、writeback、summary readback、proof case 分列？ |
| C24 | R1 | 10 族矩阵是否必须区分 family 覆盖、value type 覆盖、gesture 覆盖，防止“10族都点过”误当“所有手感语义都对”？ |
| C25 | R1 | 哪些 cell 应保持只读或演示态，且只读态 UI 是否必须去除按钮形态、hover/pressed 形态和可点光标语义？ |
| C26 | R1 | `.dial` 和 `.percent` 是否需要统一 ring tap zones、drag direction、cross-zero delta、step snap、a11y adjustable 规则？ |
| C27 | R1 | `.stepper` 分段条是否需要定义 tap left/right、drag scrub、最小/最大边界、disabled segment 和 readback 规则？ |
| C28 | R1 | toggle 是否必须按 contract enum pair 翻转，而不是统一写 `on/off`？ |
| C29 | R1 | badge/options/preset 是否必须只暴露 contract-derived 可选值，且禁止默认把当前文本当唯一 option？ |
| C30 | R1 | color swatch 是否必须从 contract / semantic color mapper 派生，且点击 swatch 后外层卡片颜色、摘要和 expanded row 同步？ |
| C31 | R1 | summary card 的 primary touch 是否应该只负责展开，还是允许直接调节部分 primary value？ |
| C32 | R1 | expanded row 的透明 primary overlay 是否会遮挡同级 `+/-`、chevron、swatch 或 close button？ |
| C33 | R1 | 每个可点区域是否都需要稳定 accessibility identifier，用于坐标级 UI test 和人审复现？ |
| C34 | R1 | 交互写回是否必须统一走 `DemoVehicleStateStore` / mock transition，而不是 View 内局部 state？ |
| C35 | R1 | 写回后是否必须验证 store value、expanded row value、summary text、色彩语义和 dialogue/readback 至少两个层级同步？ |
| C36 | R1 | 多意图或连续操作时，sequencer / stagger 是否可能让 UI test 读到中间态而误判，需要等待策略或稳定 marker？ |
| C37 | R1 | interaction test 是否要区分 tap、long press、drag、accessibility adjustable action 四类 proof？ |
| C38 | R1 | Reduce Motion / Reduce Transparency 下，交互反馈是否仍能被读回，不能只靠动画或玻璃高光表达状态？ |
| C39 | R1 | 44pt touch target 是否要成为矩阵硬门，尤其 ring、swatch、stepper segment、close、settings/refresh？ |
| C40 | R1 | 是否需要单独验证 VoiceOver/a11y 替代入口，防止空间手势成为唯一能力？ |
| C41 | R1 | 是否需要 `make verify-uiue-interactions`，且先作为 UIUE 专门门而不是立刻塞进 `make verify-all`？ |
| C42 | R1 | `verify-uiue-interactions` 是否应该只跑稳定 unit/UI tests，避免把人工 L3 或截图审美纳入自动门？ |
| C43 | R1 | UI test 是否必须固定 `iPhone 17 Pro Max`，并在失败信息中打印关键 frame，方便定位遮挡/留白问题？ |
| C44 | R1 | 对所有新增 interaction tests，是否需要同时有一个反例或边界断言，防止只测 happy path？ |
| C45 | R1 | L3 punchlist 发现一个小交互 bug 后，是否强制触发 iceberg teardown 到同 value type、同 gesture family、同 proof path？ |
| C46 | R1 | 交互矩阵是否需要纳入“过程态/changing 态”规则，避免正在变化的卡片显示假稳定控件？ |
| C47 | R1 | summary/readback 是否需要验证中文 display title 与 contract id 的映射，防止 UI text 兜底掩盖非法 state？ |
| C48 | R1 | 是否需要记录每个 interaction proof 的 proof class，禁止把 simulator UI test 写成人工手感通过？ |
| C49 | R1 | 是否需要禁止在 View 内新增第二套 range/enum formatter，并用 code review 或 grep gate 固化？ |
| C50 | R1 | 是否需要定义 interaction debt 的 merge-only 规则：不是每个可疑点都开工，但必须挂到最近的矩阵项下不丢失？ |
| C51 | R2 | R2 L0 case 是否必须新增或替换为 `cooling + ivory`，覆盖本轮人审真实发现，而不是只保留旧 deepSpace 主 case？ |
| C52 | R2 | R2 L0 是否应该补 `heating + ivory`、`safety_refusal + ivory`、`capsule videoLoop + deepSpace`、`U17 golden path` 的最小组合边界？ |
| C53 | R2 | R2 是否需要把 10 族代表交互矩阵作为 L0 前置，而不是 L0 截图之后才发现交互假绿？ |
| C54 | R2 | R2 的 L1 sentinel 是否需要明确“只挡塌陷/大位移”，并禁止用 RMSE/WARN 推导审美结论？ |
| C55 | R2 | R2 的 L2 OCR/contrast 是否需要继续保留，但明确不能覆盖遮挡、留白、玻璃 artifact、手感和高级感？ |
| C56 | R2 | 是否需要新增 Layout Integrity Gate：从 UI tree frame 计算 `overlap_pairs`、`min_gaps`、`zone_budget`、`safe_area_violations`？ |
| C57 | R2 | Layout Integrity Gate 是否应覆盖 capsule vs settings/refresh、orb vs capsule/dialogue、dialogue vs cards、cards vs mic dock？ |
| C58 | R2 | Visual Spacing Sentinel 是否应输出 PASS/WARN/FAIL 和可复现 crop，而不是仅输出一张截图让人肉找问题？ |
| C59 | R2 | L0 capture 是否必须继续使用 on-screen `xcrun simctl io booted screenshot`，禁止 Preview/ImageRenderer/XCTAttachment/H5 替代？ |
| C60 | R2 | L0 harness 是否必须验证 launchArg、theme、route、device、UI tree evidence、screenshot path、proof_class 全字段？ |
| C61 | R2 | R2 是否需要所有 evidence package checker 默认只读，只有显式 `--write-summary` 才允许改 summary？ |
| C62 | R2 | R2 是否需要为胶囊 5 context 状态建立单独 proof：常态、行驶、泊车、下雨、夜晚？ |
| C63 | R2 | 胶囊 proof 是否要区分 “context 四维输入正确” 和 “diorama 视觉好看”，避免数据 proof 冒充审美 proof？ |
| C64 | R2 | VPA/orb 是否需要四态 L0/UI tree proof，至少证明 idle/listen/think/speak 文案与 preset 不再混用？ |
| C65 | R2 | VPA/orb 视觉 proof 是否需要米白/深空分别验，确保米白不再靠大外扩辉光抢层级？ |
| C66 | R2 | L3 人审模板是否需要加入遮挡、留白、层级、交互手感、玻璃 artifact、状态表达六栏 punchlist？ |
| C67 | R2 | L3 人审是否要要求 reviewer 先看 current screenshot/crop，再看 UI tree/test result，避免被自动绿灯锚定？ |
| C68 | R2 | R2 closeout 是否必须写明哪些项仍是 placeholder/final-art-deferred，尤其 `ContextCapsule` asset？ |
| C69 | R2 | R2 如果失败，是否必须只回写发现和下一轮返修，禁止更新 `tasks.md` 或 coverage index 为完成？ |
| C70 | R2 | R2 通过后是否仍需独立 read-only audit 复核 proof boundary、dirty scope、tasks/docs 级联，才允许进入 R3 closeout？ |

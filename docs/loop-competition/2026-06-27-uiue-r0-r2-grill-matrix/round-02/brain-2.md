# Brain 2 - Round 02

persona：ORANGE test engineer
mode：只读评审；唯一写入本文件
proof boundary：local / unit / simulator；不声明 L3 / V-PASS / mobile / true_device / A-2 complete

## Keep
| Candidate | Score | Reason |
|---|---:|---|
| C04 | 25 | 设备、project path、scheme、simulator id、xcresult 是防 Pro/Pro Max 与 worktree 漂移的第一 hard gate；失败时也能复跑定位。 |
| C17 | 25 | closeout 最小门必须把 `git diff --check`、unit、OpenSpec strict、Pro Max UI test 分 proof class 串起来，能直接防 fake green。 |
| C43 | 25 | Pro Max 固定 + 关键 frame 打印是 UIUE 坐标级 proof 的核心，否则所有遮挡、留白、触摸区断言都可被设备漂移冲掉。 |
| C56 | 25 | Layout Integrity Gate 把“人眼黄框/蓝框问题”转成 frame 级结构证据，是 R2 自动化最有杠杆的新增门。 |
| C59 | 25 | L0 必须坚持 on-screen `simctl io booted screenshot`；这是防 Preview/ImageRenderer/XCTAttachment 冒充 runtime truth 的根门。 |
| C60 | 25 | L0 harness 全字段校验能把 launchArg/theme/device/UI tree/screenshot/proof_class 一次性钉死。 |
| C61 | 25 | checker 默认只读是 reviewer 可安全复跑的前提，尤其适合独立 read-only audit。 |
| C70 | 25 | R2 过后仍需 read-only audit 复核 proof boundary、dirty scope、tasks/docs 级联，否则最容易在 closeout 升格。 |
| C36 | 24 | sequencer/stagger 会制造中间态误读；需要稳定 marker 或等待策略，否则 UI test 假红/假绿都会出现。 |
| C37 | 24 | tap、long press、drag、a11y adjustable 必须分 proof；现有 ring/stepper bug 正是“tap 写回”不足以证明手感。 |
| C44 | 24 | 新 interaction tests 需要反例/边界断言，否则只证明 happy path 元素存在。 |
| C45 | 24 | L3 小 bug 强制 iceberg teardown 能把单点返修扩到同 value type、同 gesture、同 proof path。 |
| C57 | 24 | 明确 Layout Integrity 覆盖对，才能避免 gate 只测一个胶囊按钮 pair。 |
| C58 | 24 | PASS/WARN/FAIL + crops 是失败诊断最小包；只给整图会把复核成本推回人肉找图。 |
| C66 | 24 | L3 punchlist 六栏能把人工反馈变成可回写、可扩散、可复验的缺陷入口。 |

## Delete
| Candidate | Reason |
|---|---|
| None | 不建议直接删除。70 项里有重复和可合并项，但都对应 R0/R1/R2 的真实 proof gap 或边界风险；删除会丢失测试视角的反例入口。 |

## Merge
| Candidates | Proposed canonical wording | Reason |
|---|---|---|
| C21 + C22 + C49 | `StateCellInteractionPolicy` 必须是从现有 mapper/contract 派生的 presentation consumer policy，并加 grep/code-review gate 禁止 View 内新增 range/enum formatter。 | 三项都在防第三 SSOT；合并后更利于落一个 checker + unit test。 |
| C23 + C24 + C37 | 交互矩阵按 family、cell、value type、gesture、writeback、readback、proof class 分列，并分别统计 family/value/gesture 覆盖。 | “10 族覆盖”和“手势语义覆盖”必须拆表，但可由同一矩阵承载。 |
| C41 + C42 + C48 | `make verify-uiue-interactions` 先作为 UIUE 专门门，只跑稳定 unit/UI/checker，并在输出里标 proof class，禁止纳入人工 L3 或截图审美。 | 这三项共同定义 make gate 边界。 |
| C56 + C57 + C58 | 新增 Layout/Spacing checker：从 UI tree frame + screenshot metadata 输出 overlap/min_gap/zone_budget/safe_area 与 crops，按 PASS/WARN/FAIL 汇总。 | 一个 checker 应覆盖结构关系和诊断产物，避免工具碎片化。 |
| C66 + C67 | L3 模板要求 reviewer 先看 current screenshot/crop，再看 UI tree/test result，并按六栏 punchlist 输出。 | 防自动绿灯锚定和 punchlist 结构是同一人工验收流程。 |
| C11 + C12 + C68 | ContextCapsule asset 治理规则：当前图片是 placeholder，final art deferred；内容图不得预烘焙外壳，closeout 明确未签 final art。 | 资产治理、placeholder 边界、closeout 风险应作为同一证据项追踪。 |

## Rewrite
| Candidate | Proposed wording | Reason |
|---|---|---|
| C13 | R0/R2 是否必须用 frame + crop 证明 VPA/orb 不吞占 capsule/dialogue/cards zone，并把“高级感/层级”保留给 L3，而不是只用 orb height 阈值？ | 单一 height 阈值太弱，需加 overlap/zone budget/crop 诊断。 |
| C15 | R0 是否必须补 `capsule/settings/refresh` frame regression：按钮独立在 capsule 外、右边缘对齐、最小 gap 达标，并在失败时打印三者 frame？ | 把“蓝框问题”变成可复跑坐标断言。 |
| C16 | R0 是否必须补端状态两列 frame regression：首行 y 差、列间 gap、safe area、卡片宽度均输出，失败附 UI tree frame？ | 只写“左右列对齐”不够，失败诊断字段要前置。 |
| C35 | 写回后至少验证 store value + UI tree/readback 两层；涉及颜色语义时还要验证 summary text 与 semantic color source，而不是只查 expanded row。 | 让测试证明跨层同步，避免局部 state 假绿。 |
| C54 | L1 sentinel 是否只挡塌陷/大位移，并在报告中强制输出 `not_aesthetic_gate=true`，禁止 RMSE/WARN 被用于审美签核？ | 明确字段化 proof boundary，降低 closeout 误读。 |
| C64 | VPA/orb 四态 proof 是否应同时验证 caption、preset binding、frame budget 和主题差异，并输出 idle/listen/think/speak 的 UI tree evidence？ | 只测文案不足以证明四态不混用和不遮挡。 |

## Missing Risks
- 缺少统一的 `xcresult` 索引与保留策略：当前 receipt 有路径，但候选未明确失败时保存哪个 result bundle、如何链接到 case id。
- 缺少 failure diagnostics schema：UI test 失败应输出 device、UDID、scheme、case id、launch args、关键 element frame、screenshot/crop path、UI tree path，而不是只靠 XCTest 文本。
- 缺少 “唯一 booted simulator” 门的长期化：capture 脚本有检查，但 `make verify-uiue-interactions` 若不继承，会复发截图错设备。
- 缺少 flake 分类：等待中间态、滚动元素 offscreen、动画/Reduce Motion、XCUITest runner crash、app crash 应分不同 failure code。
- 缺少 per-candidate evidence index：R0/R1/R2 closeout 应能从每个 grill item 反查到 test/checker/receipt 或明确 `deferred`。
- 缺少坐标归一化约定：UI test normalized offset 应同时记录 element frame，防不同设备尺寸下“同一 offset”语义漂移。
- 缺少 crops 生成门：Layout/Spacing FAIL/WARN 应自动产出局部 crop，而不是让 reviewer 打开整屏 PNG 猜问题。
- 缺少只读 checker 的写入隔离：所有 checker 默认只读，写 summary 必须显式 flag，并在 audit 模式禁用。

## Scores
| Candidate | Importance | Verifiability | Non-duplication | Decision Leverage | Risk Revelation | Total |
|---|---:|---:|---:|---:|---:|---:|
| C01 | 5 | 5 | 4 | 5 | 5 | 24 |
| C02 | 4 | 4 | 4 | 4 | 4 | 20 |
| C03 | 5 | 5 | 5 | 5 | 5 | 25 |
| C04 | 5 | 5 | 5 | 5 | 5 | 25 |
| C05 | 5 | 4 | 4 | 4 | 5 | 22 |
| C06 | 5 | 5 | 4 | 4 | 5 | 23 |
| C07 | 5 | 5 | 4 | 4 | 5 | 23 |
| C08 | 5 | 5 | 4 | 4 | 5 | 23 |
| C09 | 4 | 4 | 5 | 4 | 5 | 22 |
| C10 | 5 | 5 | 4 | 4 | 5 | 23 |
| C11 | 4 | 4 | 4 | 3 | 4 | 19 |
| C12 | 3 | 3 | 4 | 3 | 4 | 17 |
| C13 | 5 | 4 | 4 | 4 | 5 | 22 |
| C14 | 4 | 5 | 5 | 4 | 4 | 22 |
| C15 | 5 | 5 | 4 | 4 | 5 | 23 |
| C16 | 4 | 5 | 4 | 4 | 5 | 22 |
| C17 | 5 | 5 | 5 | 5 | 5 | 25 |
| C18 | 5 | 5 | 4 | 5 | 5 | 24 |
| C19 | 3 | 3 | 4 | 3 | 4 | 17 |
| C20 | 5 | 4 | 4 | 5 | 5 | 23 |
| C21 | 5 | 4 | 4 | 5 | 5 | 23 |
| C22 | 5 | 5 | 4 | 5 | 5 | 24 |
| C23 | 5 | 5 | 4 | 5 | 5 | 24 |
| C24 | 5 | 5 | 4 | 5 | 5 | 24 |
| C25 | 4 | 4 | 5 | 5 | 5 | 23 |
| C26 | 5 | 5 | 5 | 5 | 5 | 25 |
| C27 | 5 | 5 | 5 | 5 | 5 | 25 |
| C28 | 5 | 5 | 4 | 4 | 5 | 23 |
| C29 | 5 | 5 | 4 | 4 | 5 | 23 |
| C30 | 5 | 5 | 4 | 4 | 5 | 23 |
| C31 | 4 | 4 | 4 | 5 | 4 | 21 |
| C32 | 5 | 5 | 5 | 5 | 5 | 25 |
| C33 | 5 | 5 | 4 | 4 | 5 | 23 |
| C34 | 5 | 5 | 4 | 5 | 5 | 24 |
| C35 | 5 | 5 | 4 | 5 | 5 | 24 |
| C36 | 5 | 5 | 4 | 5 | 5 | 24 |
| C37 | 5 | 5 | 5 | 4 | 5 | 24 |
| C38 | 4 | 4 | 5 | 4 | 4 | 21 |
| C39 | 5 | 5 | 4 | 4 | 5 | 23 |
| C40 | 4 | 3 | 4 | 4 | 5 | 20 |
| C41 | 5 | 5 | 4 | 5 | 5 | 24 |
| C42 | 5 | 5 | 4 | 5 | 5 | 24 |
| C43 | 5 | 5 | 5 | 5 | 5 | 25 |
| C44 | 5 | 5 | 4 | 5 | 5 | 24 |
| C45 | 5 | 4 | 5 | 5 | 5 | 24 |
| C46 | 4 | 4 | 5 | 4 | 5 | 22 |
| C47 | 4 | 5 | 5 | 4 | 5 | 23 |
| C48 | 5 | 5 | 4 | 5 | 5 | 24 |
| C49 | 5 | 5 | 4 | 5 | 5 | 24 |
| C50 | 4 | 4 | 5 | 4 | 4 | 21 |
| C51 | 5 | 4 | 4 | 4 | 5 | 22 |
| C52 | 4 | 4 | 4 | 4 | 4 | 20 |
| C53 | 5 | 4 | 4 | 5 | 5 | 23 |
| C54 | 5 | 5 | 5 | 5 | 5 | 25 |
| C55 | 5 | 5 | 5 | 4 | 5 | 24 |
| C56 | 5 | 5 | 5 | 5 | 5 | 25 |
| C57 | 5 | 5 | 4 | 5 | 5 | 24 |
| C58 | 5 | 5 | 4 | 5 | 5 | 24 |
| C59 | 5 | 5 | 5 | 5 | 5 | 25 |
| C60 | 5 | 5 | 5 | 5 | 5 | 25 |
| C61 | 5 | 5 | 5 | 5 | 5 | 25 |
| C62 | 4 | 4 | 4 | 4 | 4 | 20 |
| C63 | 4 | 4 | 5 | 5 | 5 | 23 |
| C64 | 4 | 5 | 5 | 4 | 4 | 22 |
| C65 | 4 | 4 | 4 | 4 | 4 | 20 |
| C66 | 5 | 4 | 5 | 5 | 5 | 24 |
| C67 | 5 | 4 | 5 | 5 | 5 | 24 |
| C68 | 4 | 4 | 4 | 4 | 5 | 21 |
| C69 | 5 | 5 | 5 | 5 | 5 | 25 |
| C70 | 5 | 5 | 5 | 5 | 5 | 25 |

## Candidate Notes
| Candidate | Note |
|---|---|
| C01 | 测试证据应先跑 `git status --short` + pathspec 清单，报告 owned/unowned/generated/no-touch；失败诊断要列出混入路径。 |
| C02 | 建议拆 commit，因为交互 UI test、视觉资产、docs lessons 的 proof class 不同；否则回滚和审计都会变粗。 |
| C03 | `UIC2VisualAcceptanceUITests` 通过只能证明 simulator/local；`tasks.md` 的 `8.C2` checkbox 必须等 L3 verdict，不然是假绿。 |
| C04 | closeout 必须记录 project path、scheme、device name/UDID、xcresult；Pro/Pro Max 漂移应作为 hard fail，而不是 note。 |
| C05 | `cooling + ivory` 来自当前人审真实阻断，应成为 L0/L3 主 case；旧 deepSpace 只能保留 smoke。 |
| C06 | 需要 UI test 先切 `ac.mode`，再断言 summary text 与色彩语义源同步；只看 expanded row 不够。 |
| C07 | 8 色选择应测 contract-derived button 全量存在、逐项点击不崩、store/summary readback 合法；alias unknown 应有反例。 |
| C08 | badge/options/toggle 必须测 enum 写回值在 contract 集合内，并测外层 summary 变更；防“按钮可点但值非法”。 |
| C09 | `vehicle.gear` 现阶段应有只读/演示 context proof，测试要防它被计入 10 族直接控制完成。 |
| C10 | 新 identifier 应跑唯一性/查错元素 smoke；UI test 失败信息要打印命中的 element count 和 frame。 |
| C11 | 资产治理应有视觉 diff/crop 和文件命名规则，但最终仍是 local/simulator evidence；不能签 final art。 |
| C12 | placeholder 边界应写入 closeout，并避免把当前尺寸作为 spec；测试只能证明没有遮挡，不能证明艺术定稿。 |
| C13 | orb 风险不能只看 height，应输出 orb/capsule/dialogue/cards 的 overlap、gap、zone budget 和 crop。 |
| C14 | 四态应至少测 idle/listen/think/speak caption 与 preset binding；失败时输出 launch args 和 UI tree markers。 |
| C15 | 这是典型 frame regression：capsule、settings、refresh 三者 frame + min gap + alignment 必须在失败文本里可见。 |
| C16 | 两列首行 y 差和 column gap 已适合 XCUITest；建议补 safe area 与 dynamic text 截断诊断。 |
| C17 | 最小 closeout 门应分层输出 local/unit/simulator，不允许一个 “tests pass” 覆盖 OpenSpec/Pro Max/UI test。 |
| C18 | 独立 read-only audit 应复核 pathspec 与 proof boundary；不改文件，只产 verdict。 |
| C19 | anchor/GPT Image 2 边界应写入 prompt lint 或 checklist；可验证性偏文档，但能防错误验收方向。 |
| C20 | 剩余风险必须列 proof class 缺口：final art、true-device GPU/FPS、VPA 动效、L3；否则 closeout 会过度承诺。 |
| C21 | policy 若存在，必须是 consumer projection；测试应证明它不新增第三份 value/type/range SSOT。 |
| C22 | 需要 unit + grep gate：View 层不得硬编码控件行为，能力从 mapper/contract enum 派生。 |
| C23 | 矩阵应落成可检查表，列 family/cell/value type/gesture/writeback/readback/proof case；否则“覆盖”不可审。 |
| C24 | 建议 coverage 输出三种计数：family、value type、gesture；10 族全点过不能替代 ring/stepper/a11y 语义。 |
| C25 | 只读态必须没有按钮形态和可点 cursor/a11y action；测试可用 identifier absence + isHittable/role 检查。 |
| C26 | `.dial/.percent` 是高优先级：unit 测 mapper 角度/cross-zero，UI test 测坐标 tap/drag/readback。 |
| C27 | `.stepper` 应测 left/right tap、边界 min/max、disabled segment、drag scrub；失败时输出 bar frame 和 tapped offset。 |
| C28 | toggle 必须按 contract enum pair；测试应覆盖 locked/unlocked、muted/unmuted 这类非 on/off。 |
| C29 | options/preset 要验证可选值来自 contract，不允许 current text 成为唯一 option；反例可断言旧“活力模式”不存在。 |
| C30 | swatch 应测颜色按钮存在、点击后 store/summary/expanded row/semantic color 同步；不能只测不崩。 |
| C31 | summary primary touch 的职责需拍板；测试要避免 summary tap 同时展开又写值造成非确定行为。 |
| C32 | overlay 遮挡是坐标级风险；应测同级 +/-、chevron、swatch、close 的 hittable frame 与 overlap。 |
| C33 | 每个可点区域稳定 identifier 是 UI test 可维护性基础；建议加 identifier inventory checker。 |
| C34 | 写回必须统一走 `DemoVehicleStateStore`/mock transition；测试可通过 store/readback 和 View 局部 state 禁用 grep 组合证明。 |
| C35 | 至少两层同步是底线；最佳是 store、expanded row、summary、readback/颜色语义分层断言。 |
| C36 | 需要稳定 marker 或 wait strategy，例如 wait until `visualState != changing` 或 summary text 最终态；固定 sleep 易 flaky。 |
| C37 | 四类 gesture 分 proof 输出；drag/operator-pass 不能被 tap proof 吞掉。 |
| C38 | Reduce Motion/Transparency 要有静态 readback proof；不能靠粒子、玻璃高光、动画表达唯一状态。 |
| C39 | 44pt touch target 可从 UI tree frame 验证；失败应列 target id、width、height、device。 |
| C40 | VoiceOver/a11y 替代入口建议至少有 adjustable action inventory；但真 VoiceOver 自动化成本高，先列为 simulator/local proof。 |
| C41 | `make verify-uiue-interactions` 值得保留，但应先只覆盖稳定 unit/UI/checker，不进全仓 `verify-all`。 |
| C42 | 自动门不能包含 L3 或审美；输出应明确 claims_not_made，避免 make 绿被写成 V-PASS。 |
| C43 | Pro Max 固定是 hard requirement；失败文本应打印 critical frames 和 `xcodebuild -destination`，并保存 xcresult。 |
| C44 | 每个新增 test 至少有边界或反例：min/max、非法 enum、offscreen scroll、overlay overlap、wrong device。 |
| C45 | 小 bug 后必须扩散到同 value type、gesture family、proof path；这应成为 report template 字段。 |
| C46 | changing/process 态控件容易假稳定；测试应证明过程态不暴露最终态按钮或有明确 disabled/readback。 |
| C47 | 中文 display title 与 contract id 映射要测；否则 UI text fallback 会掩盖非法 key/state。 |
| C48 | 每条 proof 都应带 proof_class；simulator UI test 只能写 simulator/local，不写人工手感通过。 |
| C49 | 第二 formatter 是长期漂移源；建议 grep gate + code review checklist 双保险。 |
| C50 | debt merge-only 规则适合作为 ledger，而非立即开工；测试侧要能把未做项挂到矩阵行避免丢。 |
| C51 | R2 L0 主 case 应包括 `cooling + ivory`，因为这是当前人审阻断真实复现入口。 |
| C52 | 组合边界有价值，但要防 case 爆炸；可分 L0 必跑和 UI/unit smoke 两层。 |
| C53 | 交互矩阵作为 L0 前置能防截图后才发现控件假绿；但它不替代 L3 视觉审美。 |
| C54 | L1 必须只挡塌陷/大位移；RMSE/WARN 要在报告里显式不可用于审美判断。 |
| C55 | L2 OCR/contrast 继续保留，但必须写清不能覆盖遮挡、留白、玻璃 artifact、手感、高级感。 |
| C56 | Layout Integrity Gate 应从 UI tree frame 算 overlap/min gaps/zone budget/safe area，给结构 hard fail。 |
| C57 | 覆盖 pairs 要写死：capsule-settings/refresh、orb-capsule/dialogue、dialogue-cards、cards-mic dock。 |
| C58 | sentinel 应输出 PASS/WARN/FAIL + crop 路径；整图截图不是诊断包。 |
| C59 | L0 截图必须是 on-screen `simctl io booted screenshot`；Preview/ImageRenderer/XCTAttachment 都只能当辅助，不能进 L0。 |
| C60 | L0 checker 必须校验 launchArg/theme/device/UI tree/screenshot/proof_class 全字段和 forbidden_sources_not_used。 |
| C61 | evidence checker 默认只读；`--write-summary` 必须显式，read-only audit 模式禁写。 |
| C62 | 胶囊 5 context 状态应单独 proof，但只证明 context 输入/路由/截图，不证明 diorama 好看。 |
| C63 | 必须把四维输入 proof 和视觉审美 proof 分开；数据正确不能冒充高级感。 |
| C64 | VPA/orb 四态应测文案、preset、frame budget、主题；米白/deepSpace 应分 case。 |
| C65 | 米白主题下 orb glow 易抢层级；自动化可测 frame/crop/contrast，审美仍留 L3。 |
| C66 | L3 模板六栏是把人工反馈转成返修任务的关键；每栏都应能挂 screenshot/crop。 |
| C67 | 先看 screenshot/crop 再看绿灯能降低自动化锚定；适合写进 L3 review protocol。 |
| C68 | placeholder/final-art-deferred 必须在 closeout 明确；ContextCapsule 当前 asset 不得被写成 final。 |
| C69 | 失败后只能回写发现和下一轮返修，不能更新 tasks/coverage 为完成；这是防假绿硬门。 |
| C70 | R2 后独立 audit 应复核 dirty scope、proof boundary、xcresult/evidence、tasks/docs 级联，才允许进 R3 closeout。 |

## Rationale

本轮 ORANGE 视角的结论很直接：优先级最高的候选不是“多加测试”，而是把 UIUE proof 链做成可复跑、可定位、不可升格的证据系统。现有材料已经证明 L0/L1/L2 机器证据有价值，但它们只能覆盖 runtime truth、结构塌陷、OCR/contrast 和部分 interaction writeback；L3 人审仍能发现玻璃质感、空间手感、胶囊白边、VPA 层级等问题。因此任何候选如果把机器绿灯当审美结论，都应被 rewrite 或合并到 proof-boundary gate。

测试落地的主线应是四层：第一，固定 UIUE worktree、project path、scheme、iPhone 17 Pro Max name/UDID 和 xcresult；第二，补 Interaction Integrity 的 value type × gesture × readback 矩阵；第三，新增 Layout/Spacing checker，从 UI tree frame 生成 overlap/min gap/zone budget/safe area 和 crops；第四，R2 closeout 前做独立 read-only audit，确保 `8.C2`、A-2、L3、V-PASS、mobile、true_device 没被误关或误签。

我不建议删除 70 项中的任何一项。它们有重复，但重复本身反映了 UIUE 当前最大风险：同一个假绿会从 commit scope、UI test、evidence package、L3 模板、OpenSpec tasks、coverage index 六个入口溢出。controller 可以合并措辞，但不应丢掉这些风险入口。

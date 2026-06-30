# Brain 3 - Round 02

persona: BLACK skeptical product judge
scope: R0/R1/R2/R2b grill matrix, 70 blind candidates
proof boundary: local / unit / simulator only; no L3, no V-PASS, no mobile, no true_device, no A-2 complete

## Keep
| Candidate | Score | Reason |
|---|---:|---|
| C03 | 25 | 这是防 fake green 的主闸；UI test 14/0 也不能关闭 8.C2。 |
| C05 | 25 | `cooling + ivory` 是本轮真实人审暴露的问题，比旧 deepSpace case 更贴近现场风险。 |
| C26 | 25 | 环形控件一按就露馅，是 L3 手感缺陷的典型 iceberg。 |
| C34 | 25 | 不统一写回 store，所有视觉和读回都可能是假 affordance。 |
| C51 | 25 | R2 必须把本轮真实 blocker 放进 L0，否则重跑仍锚定旧绿灯。 |
| C56 | 25 | Layout Integrity 能挡“截图一眼怪”的结构缺陷，但不能替代审美人审。 |
| C59 | 25 | L0 必须是真 on-screen simulator 截图；Preview/ImageRenderer 会假装漂亮。 |
| C69 | 25 | 失败只回写发现，不准勾 tasks/coverage，是防状态污染的底线。 |
| C01 | 24 | R0 closeout 第一风险是 dirty scope 混入，现场返修不能污染 roadmap/handoff。 |
| C06 | 24 | 外层摘要颜色不联动，客户不用点开就会觉得状态错。 |
| C13 | 24 | VPA 光晕抢层级会直接破坏演示焦点，frame 高度阈值不足以说明高级感。 |
| C14 | 24 | 四态都像 listen 会让“助手生命感”穿帮。 |
| C17 | 24 | closeout 必须按 proof class 分层，否则自动绿灯会被误写成人审。 |
| C20 | 24 | 剩余风险不列出，final art/GPU/L3 很容易被暗中关门。 |
| C22 | 24 | View 内硬编码交互行为会制造第二 SSOT 和后续状态错读。 |
| C24 | 24 | 10 族覆盖、value type 覆盖、gesture 覆盖必须拆开。 |
| C25 | 24 | 只读态不能长得像按钮，这是客户现场最容易被戳穿的假能力。 |
| C35 | 24 | store、expanded、summary、色彩、readback 不同步就是演示事故。 |
| C45 | 24 | L3 抓到一点必须扩到同 value type/gesture/proof path。 |
| C48 | 24 | proof class 标签本身是产品治理的一部分，防 simulator 伪装 L3。 |
| C49 | 24 | 第二套 formatter/range 是交互长期腐烂源。 |
| C53 | 24 | L0 之前先过交互矩阵，防截图漂亮但手一按穿帮。 |
| C54 | 24 | L1 sentinel 只能挡塌陷，不能签审美。 |
| C57 | 24 | 覆盖 capsule/orb/dialogue/cards/mic 的互相遮挡，正中现场可见问题。 |
| C60 | 24 | L0 manifest 字段完整是防设备/launchArg/树漂移的必要证据。 |
| C63 | 24 | context 输入正确不等于 capsule 好看，必须拆 proof。 |
| C64 | 24 | VPA 四态文案和 preset 绑定是产品可信度问题。 |
| C65 | 24 | 米白主题下 orb 外扩辉光抢层级，必须单独验。 |
| C66 | 24 | L3 punchlist 必须结构化，否则人工反馈会变成一句“感觉不行”。 |
| C67 | 24 | 人审先看图再看绿灯，避免被自动化锚定。 |
| C70 | 24 | R2 过后还要独立审 proof boundary 和 dirty scope，防 closeout 膨胀。 |

## Delete
| Candidate | Reason |
|---|---|
| None | 70 项都能映射到 R0/R1/R2/R2b 的真实风险；BLACK 视角不建议删除，只建议合并低杠杆重复项。 |

## Merge
| Candidates | Proposed canonical wording | Reason |
|---|---|---|
| C07 + C29 + C30 | Contract-derived options/swatch 必须只暴露合法值，并验证写回、外层语义色、summary/readback 同步。 | 三项都在防“选项看起来可点但非法/不同步”，可合成一个 contract-option 产品门。 |
| C15 + C16 + C56 + C57 | Layout Integrity Gate 应覆盖右上按钮、胶囊、orb、dialogue、cards、mic dock 的 overlap/min-gap/zone budget。 | C15/C16 是具体事故，C56/C57 是治理门；合并后更有执行抓手。 |
| C54 + C55 + C58 | L1/L2/sentinel 只输出结构化 PASS/WARN/FAIL 与 crop/evidence，禁止推导审美。 | 三项都是防机器指标越权，合并能减少重复口径。 |
| C62 + C63 | 胶囊 proof 拆为 context 四维输入正确、5 状态覆盖、diorama 视觉人审三层。 | 状态覆盖和审美 proof 不应混成一项。 |
| C66 + C67 | L3 模板必须先看 current screenshot/crop，再按六栏 punchlist 记录，不先看自动绿灯。 | 这两项一起定义人审顺序和表格内容。 |

## Rewrite
| Candidate | Proposed wording | Reason |
|---|---|---|
| C12 | R0 是否必须把 `ContextCapsule` 当前图片标为 placeholder，且明确 final art 只接受“内容图 + SwiftUI capsule/mask/glass 外壳”分层，不接受预烘焙白壳？ | 原题只说 placeholder，不够抓住本轮白边根因。 |
| C31 | Summary card 的 primary touch 是否只能展开；若允许直接调节，必须列出 value type、44pt target、writeback/readback 和 L3 手感 proof，否则默认禁止。 | BLACK 视角需要默认防假 affordance，而不是开放式讨论。 |
| C40 | 是否必须为所有空间手势提供 VoiceOver/a11y adjustable 或 button 替代入口，并证明 Reduce Motion 下仍可读回？ | 单独说 VoiceOver 太窄，应和空间手势、状态读回绑定。 |
| C50 | interaction debt 是否只能 merge 到最近矩阵项，且每项必须带 owner、proof class、defer reason 和重新触发条件？ | “merge-only”仍可能丢失，需补可追踪字段。 |
| C52 | R2 是否必须把 `heating + ivory`、`safety_refusal + ivory`、`capsule videoLoop + deepSpace`、`U17 golden path` 作为边界 smoke，并说明它们不替代 `cooling + ivory` 主 blocker？ | 防补充 case 反过来稀释真实阻断。 |

## Missing Risks
- 缺少“客户现场 30 秒演示路径”风险：即使单点 proof 通过，连续讲解路径中的焦点顺序、手势节奏和读回时机仍可能穿帮。
- 缺少“截图裁剪误导”风险：crop 能看清局部，但客户看到的是整屏层级；报告应要求 full-screen + focused crop 成对出现。
- 缺少“米白主题默认优先级”风险：路线写米白默认，但很多自动 case 和锚点仍偏 deepSpace，可能继续修错主题。
- 缺少“final art deferred 的停止线”风险：placeholder 可以存在，但必须定义何时不能再继续用 placeholder 进入下一阶段。
- 缺少“人审失败后的最小返修回路”风险：应要求每个 L3 FAIL/PARTIAL 绑定 owner、返修路径、重跑 case，而不是只写下一轮继续。

## Scores
| Candidate | Importance | Verifiability | Non-duplication | Decision Leverage | Risk Revelation | Total |
|---|---:|---:|---:|---:|---:|---:|
| C01 | 5 | 5 | 4 | 5 | 5 | 24 |
| C02 | 4 | 5 | 4 | 4 | 4 | 21 |
| C03 | 5 | 5 | 5 | 5 | 5 | 25 |
| C04 | 4 | 5 | 4 | 4 | 5 | 22 |
| C05 | 5 | 5 | 5 | 5 | 5 | 25 |
| C06 | 5 | 5 | 4 | 5 | 5 | 24 |
| C07 | 5 | 5 | 4 | 4 | 5 | 23 |
| C08 | 5 | 5 | 4 | 4 | 5 | 23 |
| C09 | 4 | 4 | 5 | 5 | 4 | 22 |
| C10 | 3 | 5 | 4 | 3 | 4 | 19 |
| C11 | 5 | 4 | 5 | 4 | 5 | 23 |
| C12 | 4 | 4 | 4 | 4 | 5 | 21 |
| C13 | 5 | 4 | 5 | 5 | 5 | 24 |
| C14 | 5 | 5 | 5 | 4 | 5 | 24 |
| C15 | 4 | 5 | 4 | 3 | 4 | 20 |
| C16 | 4 | 5 | 4 | 3 | 4 | 20 |
| C17 | 5 | 5 | 4 | 5 | 5 | 24 |
| C18 | 4 | 4 | 4 | 4 | 5 | 21 |
| C19 | 4 | 4 | 4 | 4 | 5 | 21 |
| C20 | 5 | 4 | 5 | 5 | 5 | 24 |
| C21 | 4 | 4 | 4 | 5 | 4 | 21 |
| C22 | 5 | 5 | 4 | 5 | 5 | 24 |
| C23 | 5 | 4 | 4 | 5 | 5 | 23 |
| C24 | 5 | 4 | 5 | 5 | 5 | 24 |
| C25 | 5 | 4 | 5 | 5 | 5 | 24 |
| C26 | 5 | 5 | 5 | 5 | 5 | 25 |
| C27 | 5 | 5 | 4 | 4 | 5 | 23 |
| C28 | 4 | 5 | 4 | 4 | 5 | 22 |
| C29 | 5 | 5 | 4 | 4 | 5 | 23 |
| C30 | 5 | 5 | 4 | 4 | 5 | 23 |
| C31 | 4 | 3 | 4 | 5 | 4 | 20 |
| C32 | 5 | 4 | 5 | 4 | 5 | 23 |
| C33 | 4 | 5 | 4 | 3 | 4 | 20 |
| C34 | 5 | 5 | 5 | 5 | 5 | 25 |
| C35 | 5 | 5 | 4 | 5 | 5 | 24 |
| C36 | 4 | 4 | 4 | 4 | 4 | 20 |
| C37 | 4 | 5 | 4 | 4 | 4 | 21 |
| C38 | 4 | 4 | 5 | 4 | 4 | 21 |
| C39 | 5 | 5 | 4 | 4 | 5 | 23 |
| C40 | 4 | 3 | 4 | 3 | 4 | 18 |
| C41 | 4 | 4 | 4 | 4 | 4 | 20 |
| C42 | 5 | 5 | 4 | 4 | 5 | 23 |
| C43 | 4 | 5 | 4 | 4 | 5 | 22 |
| C44 | 4 | 4 | 4 | 4 | 4 | 20 |
| C45 | 5 | 4 | 5 | 5 | 5 | 24 |
| C46 | 4 | 4 | 5 | 4 | 4 | 21 |
| C47 | 4 | 5 | 4 | 4 | 5 | 22 |
| C48 | 5 | 5 | 4 | 5 | 5 | 24 |
| C49 | 5 | 5 | 4 | 5 | 5 | 24 |
| C50 | 3 | 3 | 4 | 3 | 4 | 17 |
| C51 | 5 | 5 | 5 | 5 | 5 | 25 |
| C52 | 4 | 4 | 4 | 4 | 4 | 20 |
| C53 | 5 | 4 | 5 | 5 | 5 | 24 |
| C54 | 5 | 5 | 4 | 5 | 5 | 24 |
| C55 | 5 | 4 | 4 | 4 | 5 | 22 |
| C56 | 5 | 5 | 5 | 5 | 5 | 25 |
| C57 | 5 | 5 | 4 | 5 | 5 | 24 |
| C58 | 4 | 5 | 4 | 4 | 4 | 21 |
| C59 | 5 | 5 | 5 | 5 | 5 | 25 |
| C60 | 5 | 5 | 4 | 5 | 5 | 24 |
| C61 | 4 | 5 | 4 | 4 | 4 | 21 |
| C62 | 4 | 4 | 4 | 4 | 4 | 20 |
| C63 | 5 | 4 | 5 | 5 | 5 | 24 |
| C64 | 5 | 5 | 5 | 4 | 5 | 24 |
| C65 | 5 | 4 | 5 | 5 | 5 | 24 |
| C66 | 5 | 4 | 5 | 5 | 5 | 24 |
| C67 | 5 | 4 | 5 | 5 | 5 | 24 |
| C68 | 4 | 4 | 4 | 4 | 5 | 21 |
| C69 | 5 | 5 | 5 | 5 | 5 | 25 |
| C70 | 5 | 4 | 5 | 5 | 5 | 24 |

## Candidate Notes
| Candidate | Note |
|---|---|
| C01 | 产品风险是“本轮返修”混进旧 docs/handoff，导致 controller 以为 L3 blocker 已被连带解决。 |
| C02 | 建议拆 commit；交互、胶囊/VPA、docs baseline 的 proof class 不同，混提交会让现场问题追责困难。 |
| C03 | 必保留；`UIC2VisualAcceptanceUITests` 通过只证明 simulator 回归，不证明人审高级感。 |
| C04 | 设备/路径漂移已实发；Pro vs Pro Max 或 main/UIUE worktree 错位会让证据失效。 |
| C05 | `cooling + ivory` 是当前客户可见主 blocker；继续只看 deepSpace 是确认偏误。 |
| C06 | 外层摘要不随制冷/制热变色，客户不用进入 expanded row 就能看出状态错。 |
| C07 | 氛围灯 8 色崩溃是演示硬事故；不能只修色板，要追到 contract alias。 |
| C08 | badge/options/toggle 最大风险是假选择：看起来变了，store 或摘要没变。 |
| C09 | gear 不能被偷换成通用可控；演绎控制台 mock context 不是 10 族直接交互完成。 |
| C10 | identifier 查错元素会让 UI test 假绿；产品影响间接但验收影响大。 |
| C11 | 胶囊白边来自预烘焙白壳 + SwiftUI glass 双层叠加，是资产治理风险。 |
| C12 | 应改写为 placeholder + 分层资产规则；否则临时 PNG 会被当 final art。 |
| C13 | 光晕过大是层级问题，不是 frame 高度问题；客户会感到 orb 抢戏。 |
| C14 | idle/listen/think/speak 文案混用会让 VPA 失去“活着”的可信度。 |
| C15 | 蓝框类问题现场一眼可见；建议并入 Layout Integrity Gate。 |
| C16 | 左右列首行不齐会显得 low；建议并入 Layout Integrity Gate。 |
| C17 | closeout 最小门必须分层，不然 local/unit/simulator 会被误读成 L3。 |
| C18 | pathspec 独立审计必要；当前 dirty tree 多，容易把无关 docs 带入。 |
| C19 | anchor 只能是方向，不能像素照抄；否则会复发预烘焙白壳和内嵌图标。 |
| C20 | 剩余风险清单是防暗关门工具，尤其 final art、GPU/FPS、VPA 动效、L3。 |
| C21 | policy 可以有，但必须是 consumer projection，不能成为第三 SSOT。 |
| C22 | 从 mapper/contract 推导是正确产品路径；硬编码 View 行为会让后续状态读回漂移。 |
| C23 | 矩阵字段需要全列；否则“覆盖了”仍可能只覆盖 family 未覆盖手势。 |
| C24 | 族、value type、gesture 三种覆盖分开，才能防 10 族口号式假绿。 |
| C25 | 只读态去按钮形态是现场产品底线；假按钮比少一个功能更伤信任。 |
| C26 | 环形控件空间语义是本轮真实 L3 缺陷；必须作为高优先 grill。 |
| C27 | stepper 左右区域和边界态也会被用户直接试出来，不能只测增大 happy path。 |
| C28 | toggle 统一 `on/off` 会写非法 state；客户看到锁/静音类状态会不可信。 |
| C29 | 当前文本不能当唯一 option；这是 badge 假交互的来源。 |
| C30 | swatch 必须联动外层卡颜色和摘要，否则“点了颜色但舞台没变”。 |
| C31 | 需改写；默认 summary primary 只展开，直接调节必须另有强 proof。 |
| C32 | 透明 overlay 遮挡同级按钮是典型视觉看不出、手一按出事的 bug。 |
| C33 | 稳定 identifier 是 proof 工具，不是产品本身；重要但别过度膨胀。 |
| C34 | 写回必须走 store/mock transition；View local state 会制造演示孤岛。 |
| C35 | 至少两个层级同步还偏保守；BLACK 更希望 store+summary+readback+颜色全链路同步。 |
| C36 | stagger 中间态会让 UI test 和人审看到不同画面，需要稳定 marker。 |
| C37 | tap/long press/drag/a11y proof 分开有价值，但优先级低于真实视觉 blocker。 |
| C38 | Reduce Motion/Transparency 下不能只靠动画和玻璃表达状态；这会影响现场可读性。 |
| C39 | 44pt target 是基本手感门，尤其 ring/swatch/stepper/右上按钮。 |
| C40 | 需改写为手势替代入口 + 读回 proof；单纯 VoiceOver 过窄。 |
| C41 | 专门门有价值，但先不要塞全局 verify-all，避免把人工审美自动化。 |
| C42 | 必保留；人工 L3 和截图审美不能进入自动门变成假硬门。 |
| C43 | 固定 Pro Max 并打印 frame 是防漂移和快速定位的实用要求。 |
| C44 | 反例/边界断言能挡 happy-path-only，但产品杠杆中等。 |
| C45 | 人审小 bug 必须 iceberg teardown；这是 BLACK 视角最重要的流程修正之一。 |
| C46 | changing 态展示假稳定控件会误导客户继续操作。 |
| C47 | 中文 title 兜底可能掩盖非法 contract id，读回必须验证映射。 |
| C48 | proof class 必须逐项记录，防 simulator UI test 被写成手感通过。 |
| C49 | 禁第二套 range/enum formatter 是长期防腐点，直接影响演示一致性。 |
| C50 | 债务项需要 owner/proof/defer reason；只说 merge-only 不够。 |
| C51 | 必须新增/替换为 `cooling + ivory`；这是最新人审真 blocker。 |
| C52 | 补充边界 case 可以，但不能稀释 `cooling + ivory` 的优先级。 |
| C53 | 交互矩阵应前置；否则 R2 截图过了，客户一按仍穿帮。 |
| C54 | L1 只挡塌陷/大位移，这句话必须写死。 |
| C55 | L2 OCR/contrast 对留白、玻璃 artifact、手感无能为力，不能越权。 |
| C56 | Layout Integrity 是当前最需要的结构门，直接覆盖遮挡/间距/安全区。 |
| C57 | 覆盖对象准确：capsule、settings/refresh、orb、dialogue、cards、mic dock 都是现场焦点。 |
| C58 | sentinel 输出 crop 和 PASS/WARN/FAIL，能减少人肉找图成本。 |
| C59 | on-screen `simctl` 是 L0 真实性底线；任何 off-screen 都不能替代。 |
| C60 | launchArg/theme/device/UI tree/proof_class 字段不全，证据包就不可信。 |
| C61 | checker 默认只读很重要；否则 read-only audit 复跑会污染 summary。 |
| C62 | 胶囊 5 context 状态有用，但应和 diorama 审美 proof 拆开。 |
| C63 | 输入正确和好看是两件事；这题正中 capsule proof 混淆。 |
| C64 | VPA 四态必须有 L0/UI tree proof，防所有 preset 显示成 listen。 |
| C65 | 米白主题下必须单验 orb，深空好看不代表米白不抢层级。 |
| C66 | L3 六栏 punchlist 能把“感觉 low”转成可修复项。 |
| C67 | 人审顺序必须先图后绿灯；否则自动 PASS 会锚定判断。 |
| C68 | placeholder/final-art-deferred 必须写明，尤其 `ContextCapsule` 当前资产。 |
| C69 | R2 失败绝不能更新 tasks/coverage 为完成；只回写发现和返修。 |
| C70 | R2 通过后仍需独立审计，防 proof boundary、dirty scope、docs 级联漏项。 |

## Rationale
BLACK 判断标准很简单：客户现场不关心你的 `xcodebuild` 多绿，先看一眼是否高级，再按一下是否符合直觉，再听读回是否像真系统。当前 Source Pool 明确显示 `8.C2` 是 `PARTIAL_PENDING_L3`，L0/L1/L2 已经有证据但 L3 连续发现颜色语义、假交互、胶囊白边、VPA 光晕、设备/树漂移等问题；所以最高杠杆候选必须压住三类风险：一眼可见的布局/层级问题，一按就露馅的 affordance/gesture 问题，以及把 simulator/local 绿灯升级成人审通过的状态污染。

我不建议删除任何候选。低分项主要是因为表达不够强或可并入更大的治理门，不是因为风险不存在。controller 后续排序时应优先保留真实人审暴露过的问题：`cooling + ivory`、胶囊白边、VPA 四态/辉光、环形/stepper 空间手势、Layout Integrity、L3 punchlist、proof boundary。所有 `【SHOULD_GRILL】` 推进项仍必须单独 grill / pre-mortem / 决策存档，不能把本报告当拍板结论。

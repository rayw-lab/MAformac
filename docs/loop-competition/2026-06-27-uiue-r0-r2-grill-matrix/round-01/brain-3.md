# Brain 3 - Round 01

persona: BLUE UX/HMI designer
scope: fixed blind candidate set C01-C70
proof boundary: local / unit / simulator only; no L3 / V-PASS / mobile / true_device / A-2 complete claim

## Keep
| Candidate | Score | Reason |
|---|---:|---|
| C15 | 25 | 设置/刷新与 capsule 的关系是当前截图已暴露的结构性遮挡风险，必须成为回归门。 |
| C26 | 25 | ring tap zone、drag direction、cross-zero、step snap 是手指路径核心，不只是写回正确。 |
| C27 | 25 | stepper 左右区域语义直接决定座舱直觉，当前复盘已证明会漏。 |
| C37 | 25 | tap、long press、drag、a11y adjustable 四类 proof 分开，才能避免“能点”冒充“好用”。 |
| C39 | 25 | 44pt 触摸目标应作为 HMI 硬门，尤其 ring/swatch/stepper/close/settings/refresh。 |
| C56 | 25 | Layout Integrity Gate 是 BLUE 视角最该补的结构门，能挡遮挡、贴边、留白崩坏。 |
| C57 | 25 | 覆盖 capsule、orb、dialogue、cards、mic dock 的 pairwise 关系，命中真实层级风险。 |
| C64 | 25 | VPA/orb 四态 proof 防止状态文案坍缩和生命感失真，是视觉中枢风险。 |
| C05 | 24 | `cooling + ivory` 是已暴露的人审阻断，必须优先于旧 deepSpace 惯性 case。 |
| C06 | 24 | 外层摘要颜色联动是客户一眼看到的语义真值，不能只看展开行。 |
| C11 | 24 | 预烘焙白壳是资产治理问题，不是单张 PNG 裁剪问题。 |
| C13 | 24 | VPA 光晕过大即使 frame 未遮挡，也会抢走卡片层级和驾驶注意力。 |
| C14 | 24 | orb preset 四态绑定错误会直接破坏“活着”的助手感。 |
| C19 | 24 | GPT Image 2 / anchor 只能给方向，不能像素照抄；否则会把 artifact 固化成工程规则。 |
| C24 | 24 | family 覆盖、value type 覆盖、gesture 覆盖必须拆开算，正中交互假绿。 |
| C25 | 24 | 只读态不能保留按钮/hover/pressed 语义，这是假 affordance 的源头。 |
| C30 | 24 | color swatch 必须联动外层卡、摘要、expanded row，否则视觉语义断裂。 |
| C31 | 24 | summary primary touch 的职责要拍清，不然展开和直接调节会互相抢手指路径。 |
| C32 | 24 | 透明 overlay 容易遮住同级控件，是 SwiftUI 原型里高概率漏项。 |
| C35 | 24 | store、expanded、summary、色彩、dialogue/readback 同步是客户可感知闭环。 |
| C38 | 24 | Reduce Motion/Transparency 下仍要可读，不能靠动画和玻璃高光单通道表达。 |
| C45 | 24 | 小交互 bug 必须 iceberg 到同 value type / gesture / proof path。 |
| C46 | 24 | changing 态如果显示稳定控件，会制造“正在变化但像完成”的手感错觉。 |
| C51 | 24 | R2 L0 必须纳入 `cooling + ivory`，这是当前真实人审发现。 |
| C58 | 24 | spacing sentinel 需要 PASS/WARN/FAIL 和 crop，否则仍靠人肉找问题。 |
| C63 | 24 | context 输入正确不等于 diorama 好看，这个分层能防数据 proof 冒充审美 proof。 |
| C65 | 24 | 米白/深空分别验 orb，防止米白靠外扩辉光抢层级。 |
| C66 | 24 | L3 punchlist 六栏能把“好不好看”变成可复盘的人审输入。 |
| C67 | 24 | 先看 current screenshot/crop 再看绿灯，能降低自动化锚定。 |

## Delete
| Candidate | Reason |
|---|---|
| None | BLUE 视角无建议硬删。低分流程项仍可作为 controller 的审计护栏或 merge-only guardrail。 |

## Merge
| Candidates | Proposed canonical wording | Reason |
|---|---|---|
| C15 + C56 + C57 + C58 | 建立 Layout Integrity + Visual Spacing gate，覆盖 capsule/settings/refresh、orb/dialogue/cards、mic dock 与 safe-area，并输出 frame pairs、min gaps、crop 和 PASS/WARN/FAIL。 | 四项共同解决遮挡、留白、层级，不应分散成互不相干的小测试。 |
| C26 + C27 + C37 + C39 + C40 | 建立 value control interaction matrix：每类控件按 tap/drag/long press/a11y adjustable、44pt target、readback 分层验。 | 手指路径和替代入口必须一张矩阵管理。 |
| C11 + C12 + C19 + C63 + C68 | 建立 visual asset governance：anchor/GPT 图只作方向，asset 不带预烘焙 chrome，placeholder/final-art-deferred 在 closeout 标清。 | 防止锚点图、临时裁切、最终美术三者混淆。 |
| C13 + C14 + C64 + C65 | 建立 VPA/orb 四态与主题 proof：状态文案、视觉态、halo budget、米白/深空分别验。 | orb 是中枢注意力对象，状态与层级应合并治理。 |
| C23 + C24 + C35 + C48 | 10 族交互矩阵需同时列 family/value type/gesture/writeback/readback/proof class。 | 防止“10 族都点过”被误读为“所有手感语义都对”。 |

## Rewrite
| Candidate | Proposed wording | Reason |
|---|---|---|
| C03 | R0 closeout 是否必须保持 `8.C2 = PARTIAL_PENDING_L3`，并禁止用 `UIC2VisualAcceptanceUITests` 或 L0-L2 机器包勾 `tasks.md`？ | 强化 proof class，不把 UI test 绿写成人审完成。 |
| C12 | R0 是否必须声明当前 `ContextCapsule` asset 是 placeholder/final-art-deferred，且不得把现有裁切、白壳处理或构图当 final art？ | 明确 placeholder 与最终资产差异。 |
| C13 | R0 是否必须用层级预算和截图 crop 复核 VPA/orb halo，而不是只用 frame height 证明“未遮挡”？ | frame 不等于视觉层级。 |
| C25 | 哪些 cell 应保持只读/演示态，且只读态是否必须移除 button shape、pressed state、hover cursor、可点色块和 primary touch target？ | 假 affordance 不只来自按钮，也来自所有可点视觉语义。 |
| C31 | summary card primary touch 的唯一默认职责是否是展开；若允许直接调节，必须限定 value type、手势、44pt target、readback 和冲突优先级。 | 把二选一变成可执行边界。 |
| C56 | 是否需要新增 Layout Integrity Gate：从 UI tree frame 与 screenshot metadata 计算 overlap_pairs、min_gaps、zone_budget、safe_area_violations，并附可复现 crop？ | 加上 crop，便于人审和复跑。 |
| C66 | L3 人审模板是否必须先列遮挡、留白、层级、交互手感、玻璃 artifact、状态表达六栏 punchlist，再允许给总体 verdict？ | 防止一句“看着还行”吞掉具体风险。 |

## Missing Risks
- 缺少“mic dock 遮最后一行卡片”的显式候选；C57 提到 cards vs mic dock，但建议单独要求最后一行完整滚到 dock 上方，并用 bottom inset + crop 证明。
- 缺少“透明 hit layer / overlay zIndex 捕获手势”的专项候选；C32 覆盖 expanded row，但 main stage 的 context band、atmosphere overlay、ambient burst 也需要 hit-testing proof。
- 缺少“米白主题对低对比细字、hairline、浅玻璃边界”的专门候选；当前多聚焦 orb/capsule，卡片正文和辅助标签也会在 ivory 失真。
- 缺少“动态字体或中文最长文案挤压”的 UX 候选；SD18 V10 提到最长中文文案，但 70 项里没有独立 punch。
- 缺少“车载演示一手持姿态”的候选；thumb reach、底部 mic dock、右上设置/刷新是否适合单手拿 iPhone，没有被单独评分。

## Scores
| Candidate | Importance | Verifiability | Non-duplication | Decision Leverage | Risk Revelation | Total |
|---|---:|---:|---:|---:|---:|---:|
| C01 | 3 | 5 | 4 | 4 | 3 | 19 |
| C02 | 3 | 4 | 4 | 4 | 3 | 18 |
| C03 | 4 | 5 | 5 | 5 | 4 | 23 |
| C04 | 3 | 5 | 4 | 4 | 4 | 20 |
| C05 | 5 | 5 | 4 | 5 | 5 | 24 |
| C06 | 5 | 5 | 4 | 5 | 5 | 24 |
| C07 | 4 | 5 | 4 | 4 | 4 | 21 |
| C08 | 4 | 5 | 4 | 4 | 4 | 21 |
| C09 | 4 | 4 | 4 | 4 | 4 | 20 |
| C10 | 4 | 5 | 4 | 4 | 4 | 21 |
| C11 | 5 | 4 | 5 | 5 | 5 | 24 |
| C12 | 4 | 4 | 5 | 4 | 5 | 22 |
| C13 | 5 | 4 | 5 | 5 | 5 | 24 |
| C14 | 5 | 5 | 5 | 5 | 4 | 24 |
| C15 | 5 | 5 | 5 | 5 | 5 | 25 |
| C16 | 4 | 5 | 4 | 4 | 4 | 21 |
| C17 | 4 | 5 | 4 | 5 | 4 | 22 |
| C18 | 3 | 4 | 4 | 4 | 3 | 18 |
| C19 | 5 | 4 | 5 | 5 | 5 | 24 |
| C20 | 4 | 4 | 4 | 4 | 5 | 21 |
| C21 | 3 | 4 | 4 | 4 | 3 | 18 |
| C22 | 4 | 5 | 4 | 4 | 4 | 21 |
| C23 | 4 | 5 | 4 | 4 | 4 | 21 |
| C24 | 5 | 5 | 4 | 5 | 5 | 24 |
| C25 | 5 | 4 | 5 | 5 | 5 | 24 |
| C26 | 5 | 5 | 5 | 5 | 5 | 25 |
| C27 | 5 | 5 | 5 | 5 | 5 | 25 |
| C28 | 4 | 5 | 4 | 4 | 4 | 21 |
| C29 | 4 | 5 | 4 | 4 | 4 | 21 |
| C30 | 5 | 5 | 4 | 5 | 5 | 24 |
| C31 | 5 | 4 | 5 | 5 | 5 | 24 |
| C32 | 5 | 4 | 5 | 5 | 5 | 24 |
| C33 | 4 | 5 | 4 | 4 | 4 | 21 |
| C34 | 4 | 5 | 4 | 4 | 4 | 21 |
| C35 | 5 | 5 | 4 | 5 | 5 | 24 |
| C36 | 4 | 4 | 4 | 4 | 4 | 20 |
| C37 | 5 | 5 | 5 | 5 | 5 | 25 |
| C38 | 5 | 4 | 5 | 5 | 5 | 24 |
| C39 | 5 | 5 | 5 | 5 | 5 | 25 |
| C40 | 4 | 4 | 4 | 4 | 4 | 20 |
| C41 | 3 | 4 | 4 | 4 | 3 | 18 |
| C42 | 3 | 4 | 4 | 4 | 3 | 18 |
| C43 | 4 | 5 | 4 | 4 | 4 | 21 |
| C44 | 4 | 5 | 4 | 4 | 4 | 21 |
| C45 | 5 | 4 | 5 | 5 | 5 | 24 |
| C46 | 5 | 4 | 5 | 5 | 5 | 24 |
| C47 | 4 | 5 | 4 | 4 | 4 | 21 |
| C48 | 4 | 5 | 4 | 5 | 4 | 22 |
| C49 | 3 | 5 | 4 | 4 | 3 | 19 |
| C50 | 3 | 4 | 4 | 4 | 3 | 18 |
| C51 | 5 | 5 | 4 | 5 | 5 | 24 |
| C52 | 5 | 4 | 4 | 5 | 5 | 23 |
| C53 | 5 | 4 | 4 | 5 | 5 | 23 |
| C54 | 4 | 5 | 5 | 4 | 4 | 22 |
| C55 | 4 | 5 | 5 | 4 | 5 | 23 |
| C56 | 5 | 5 | 5 | 5 | 5 | 25 |
| C57 | 5 | 5 | 5 | 5 | 5 | 25 |
| C58 | 5 | 5 | 4 | 5 | 5 | 24 |
| C59 | 4 | 5 | 5 | 4 | 4 | 22 |
| C60 | 4 | 5 | 4 | 4 | 4 | 21 |
| C61 | 3 | 5 | 4 | 4 | 3 | 19 |
| C62 | 5 | 4 | 4 | 5 | 5 | 23 |
| C63 | 5 | 4 | 5 | 5 | 5 | 24 |
| C64 | 5 | 5 | 5 | 5 | 5 | 25 |
| C65 | 5 | 4 | 5 | 5 | 5 | 24 |
| C66 | 5 | 4 | 5 | 5 | 5 | 24 |
| C67 | 5 | 4 | 5 | 5 | 5 | 24 |
| C68 | 4 | 4 | 5 | 4 | 4 | 21 |
| C69 | 4 | 5 | 5 | 5 | 4 | 23 |
| C70 | 4 | 5 | 4 | 5 | 4 | 22 |

## Candidate Notes
| Candidate | Note |
|---|---|
| C01 | UX 间接项；重要在防旧 roadmap/handoff dirty 混入导致 reviewer 看错视觉状态。 |
| C02 | commit 分层能避免视觉修复、测试 proof、docs lesson 混成一坨，但不是一线 HMI 风险。 |
| C03 | 必保留 open；UI test 通过只能证明坐标/回读，不证明磊哥 L3 手感和高级感。 |
| C04 | 设备漂移会让同一布局在 Pro/Pro Max 上遮挡结论不同，closeout 必列 project/scheme/sim/xcresult。 |
| C05 | `cooling + ivory` 是米白主题真实暴露点，应作为第一 case 看低对比、冷色语义和 glass 质感。 |
| C06 | 外层摘要颜色是客户第一眼语义；制热后仍蓝就是 HMI 误导，不是小样式。 |
| C07 | 8 色崩溃是产品演示硬翻车；同时要看 swatch 尺寸、排布、触摸热区。 |
| C08 | enum 写回和 summary readback 是视觉可信度基础；否则色块/按钮只是装饰。 |
| C09 | gear 仍是演绎控制台 mock context，不能把只读仪表伪装成可触控车控。 |
| C10 | a11y id 重复会让坐标测试点错控件，进而制造假通过和错误遮挡诊断。 |
| C11 | ContextCapsule 白壳说明资产带 chrome 与 SwiftUI 再画 chrome 叠加，是资产治理风险。 |
| C12 | 当前 capsule 图只能 placeholder；最终 diorama、美术资产和布局规则不能由临时 crop 锁死。 |
| C13 | orb 光晕即使没有几何 overlap，也可能在米白主题抢层级、吞掉 dialogue/card 注意力。 |
| C14 | 四态 caption 与 preset 绑定是最小生命感 proof；完成态还显示 listen 会破坏座舱直觉。 |
| C15 | 右上设置/刷新必须在 capsule 外且对齐，避免按钮压图、贴边或把 capsule 挤歪。 |
| C16 | 左右列首行对齐和列间距是“工程栅格感”与“高级感”的分界，适合 frame gate。 |
| C17 | `git diff --check`、unit、OpenSpec、Pro Max UI test 都需要，但必须分 proof class 报告。 |
| C18 | read-only audit 对 BLUE 是外围护栏，能防旧 dirty 污染当前视觉结论。 |
| C19 | GPT Image 2/anchor 只能约束意图和 bar；逐像素硬仿会引入图标内嵌、预烘焙壳等错误。 |
| C20 | 必列 final capsule art、true-device GPU/FPS、完整 VPA 动效、L3 人审，不然 closeout 会假绿。 |
| C21 | policy 应是 presentation consumer，不应新建 value/type/range 第三 SSOT；UX 受益但偏架构。 |
| C22 | 从 mapper/contract 派生控件能力，才能保证视觉控件与真实值域一致。 |
| C23 | 矩阵列要能落到 proof case；仅列 family 不足以发现 ring/stepper 手感 bug。 |
| C24 | 这是本轮复盘核心：10 族覆盖不等于 value type 或 gesture 覆盖。 |
| C25 | 只读态必须视觉上像信息而非控件，避免用户自然去点却无响应。 |
| C26 | ring 的下方减小、左上增大、顺逆时针 drag 是身体直觉，必须 hard gate。 |
| C27 | stepper 点左/右增减是最基础空间语义，不能“点哪都增大”。 |
| C28 | toggle 写 `on/off` 会让锁/静音等语义非法，视觉状态也会错读。 |
| C29 | badge/options/preset 只暴露 contract-derived 选项，避免“当前文本=唯一选项”的假 palette。 |
| C30 | ambient swatch 要同步外层色、摘要和 expanded row；否则用户看到的是断裂状态。 |
| C31 | summary card 如果既展开又调节，会形成手势冲突；默认只展开更安全。 |
| C32 | 透明 primary overlay 很容易盖住 +/-、chevron、swatch、close，必须有 hit-testing 复核。 |
| C33 | 坐标级 UI test 与人审复现都依赖稳定 identifier，尤其 expanded row primary target。 |
| C34 | View 内局部 state 会造成控件变了但 mock store/readback 不变，直接破坏可信度。 |
| C35 | 至少两个层级同步仍偏低；BLUE 建议覆盖 summary color + dialogue/readback 的可见闭环。 |
| C36 | sequencer/stagger 会让 UI test 读中间态；视觉上也可能让用户误以为某卡没响应。 |
| C37 | 手势 proof 必须分 tap/long press/drag/a11y，不然“tap 可写回”会遮住 drag 缺失。 |
| C38 | Reduce Motion/Transparency 下要靠文字、数值、图标、色块双通道，不靠玻璃/动画单点。 |
| C39 | 44pt 是车载手持演示硬底线；ring、swatch、segment、close、settings/refresh 都要算。 |
| C40 | VoiceOver 不是当前 L3 核心，但 adjustable action 能证明手势能力不是唯一入口。 |
| C41 | 专门 gate 有价值，但 BLUE 更关心 gate 内容是否覆盖触摸/遮挡/层级。 |
| C42 | 自动门不能纳入人工 L3 或审美结论，否则会把局部稳定测试变成假验收。 |
| C43 | Pro Max 固定和失败 frame 打印能快速定位遮挡/留白，但还需当前 screenshot/crop。 |
| C44 | 反例/边界断言能防 happy path 假绿，例如点左减、点右增、贴边不遮挡。 |
| C45 | L3 发现一个小交互 bug，就必须扩到同 value type/gesture/proof path。 |
| C46 | changing 态应限制稳定控件的显示，防止用户在过程态继续戳造成状态错觉。 |
| C47 | 中文 display title 与 contract id 映射错误会被 UI text 兜底掩盖，影响人审判断。 |
| C48 | simulator UI test 只能写 simulator；proof class 标错会污染后续 L3 和 roadmap。 |
| C49 | 第二套 formatter 会让值域、单位、显示和触控步进漂移，UX 表现会不一致。 |
| C50 | interaction debt 可以 merge-only，但不能丢；否则小触摸问题会反复从截图里冒出来。 |
| C51 | R2 L0 若不含 `cooling + ivory`，就是绕开真实人审 bug 重新取证。 |
| C52 | `heating + ivory`、safety、videoLoop、U17 组合能覆盖主题、拒识、capsule、黄金路径边界。 |
| C53 | 先交互矩阵再 L0 截图，否则截图好看也可能是不可用控件。 |
| C54 | L1 只能挡塌陷/大位移，不能让 RMSE/WARN 变成审美结论。 |
| C55 | OCR/contrast 可保留，但遮挡、留白、玻璃 artifact、手感和高级感必须另验。 |
| C56 | Layout Integrity Gate 应机械输出 overlap/min gap/zone/safe area，挡结构性 UI bug。 |
| C57 | 必须覆盖 capsule vs settings/refresh、orb vs capsule/dialogue、dialogue/cards、cards/mic dock。 |
| C58 | Sentinel 应给 crop 和 PASS/WARN/FAIL，方便 controller 与磊哥复核而不是盯全屏找问题。 |
| C59 | L0 必须 on-screen simctl；Preview/ImageRenderer 会漏 Liquid Glass/material/合成真实表现。 |
| C60 | launchArg/theme/device/UI tree/screenshot/proof_class 字段齐全，才能证明截到的是目标态。 |
| C61 | checker 默认只读是审计卫生，对 UX 间接有利，避免取证包被复跑时改写。 |
| C62 | capsule 五 context 状态应单独 proof；常态/行驶/泊车/雨/夜的视觉语义不能混。 |
| C63 | context 四维输入正确只是数据 proof；diorama 是否高级、是否活体迷你窗仍需人审。 |
| C64 | orb idle/listen/think/speak 至少要 UI tree + visual proof，防文案和 preset 混用。 |
| C65 | 米白主题需要弱 halo/实色球，深空可更炫；两主题不能共享同一辉光预算。 |
| C66 | L3 punchlist 六栏能把 BLUE 风险结构化，尤其遮挡、留白、层级、玻璃 artifact。 |
| C67 | 人审先看 screenshot/crop 可避免被 “14 tests pass” 锚定，保留真实视觉判断。 |
| C68 | closeout 要标 placeholder/final-art-deferred，尤其 ContextCapsule，否则临时 art 会被继承。 |
| C69 | R2 失败只能回写发现和下一轮返修；不能更新 tasks 或 coverage 成完成。 |
| C70 | 进入 R3 前独立 audit 应复核 proof boundary、dirty scope、tasks/docs 级联，防假绿流入 closeout。 |

## Rationale

BLUE 评分把真实座舱体验里的三类问题权重拉高：一是手指路径和触摸热区，包括 ring、stepper、swatch、close、settings/refresh、mic dock；二是遮挡、留白和层级，包括 capsule 与右上按钮、orb 光晕、dialogue/card/mic dock 的 zone budget；三是视觉 proof 分层，包括 `cooling + ivory`、米白/深空主题、VPA 四态、capsule placeholder 和 GPT/anchor 误用。

当前证据显示 `8.C2` 仍是 `PARTIAL_PENDING_L3`：L0/L1/L2 和 14 条 Pro Max UI test 能证明 simulator/local 层的结构与部分交互回归，但不能证明 L3 人审、V-PASS、mobile、true_device 或 A-2 complete。后续 controller 若采纳 BLUE 建议，应把高分项优先落成 frame/crop/UI-tree/坐标 UI test + 人审 punchlist，而不是只增加截图数量。

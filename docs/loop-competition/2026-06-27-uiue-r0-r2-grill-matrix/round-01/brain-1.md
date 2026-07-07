# Brain 1 - Round 01

## Keep
| Candidate | Score | Reason |
|---|---:|---|
| C03 | 25 | RED 首要硬门：`8.C2` 仍 open，UI test 通过不能勾 `tasks.md`。 |
| C20 | 25 | 强制列出本轮不修，防止 final art、true-device GPU/FPS、L3 被 fake green。 |
| C22 | 25 | 直接打掉 View 层第二套 value/type/range SSOT。 |
| C26 | 25 | 已发生 ring 假 affordance；必须问空间点按、拖拽、跨 0、snap、a11y。 |
| C27 | 25 | 已发生 stepper 左右语义假绿；必须单列。 |
| C34 | 25 | 写回统一走 mock store 是防局部 state 假成功的根。 |
| C37 | 25 | 把 tap/long press/drag/a11y proof 分层，防“点过”冒充“手感完整”。 |
| C48 | 25 | proof class 审计是本轮 RED 核心，禁止 simulator 写成 L3/V-PASS。 |
| C54 | 25 | L1 sentinel 只能挡塌陷，不能签审美；必须显式锁。 |
| C59 | 25 | L0 必须 on-screen `simctl io screenshot`，不能被 Preview/ImageRenderer/XCTAttachment 偷换。 |
| C69 | 25 | R2 fail 时只回写发现，不得更新 tasks/coverage 为完成。 |
| C70 | 25 | 进入 R3 前必须独立审 proof boundary、dirty scope、docs 级联。 |

## Delete
| Candidate | Reason |
|---|---|
| None | 不建议删除。RED 视角下 70 项大多覆盖真实失败路径；重复项应 merge/rewrite，不应直接丢。 |

## Merge
| Candidates | Proposed canonical wording | Reason |
|---|---|---|
| C05 + C51 | `cooling + ivory` 必须作为 R0 返修与 R2 L0/L3 重跑的第一阻断 case，并在 closeout 中标明它来自本轮 L3 真实发现。 | 两项跨阶段重复，但风险高；建议保留 stage 归属，controller 可合并成一条跨阶段 hard gate。 |
| C11 + C12 + C68 | `ContextCapsule` 当前资产只能标 placeholder/final-art-deferred；禁止把预烘焙白壳、裁切尺寸或 GPT 图构图固化成 final art。 | 三项都在防 anchor/GPT Image 2 误用和 asset artifact 反向决定工程结构。 |
| C15 + C16 + C56 + C57 | Layout Integrity Gate 必须覆盖 capsule/settings/refresh、orb/capsule/dialogue、cards/mic dock、端状态列对齐和最小 gap。 | C15/C16 是具体现象，C56/C57 是机制；建议合成 gate，下挂回归 case。 |
| C23 + C24 + C37 | Interaction matrix 必须同时按 family、value type、gesture、writeback、readback、proof case 分列，并分别标 proof class。 | 防“10 族都点过”冒充 value type/gesture 全覆盖。 |
| C41 + C42 | `make verify-uiue-interactions` 只能跑稳定 local/unit/simulator 门；不得把 L3 人审或审美截图纳入自动绿灯。 | 一个问入口，一个问边界，合并后更像可执行门定义。 |
| C54 + C55 | L1/L2 机器门只挡塌陷/可读性/回归，不覆盖遮挡、留白、玻璃 artifact、手感、高级感或 V-PASS。 | 同属机器门能力边界，建议 canonical 化防误读。 |

## Rewrite
| Candidate | Proposed wording | Reason |
|---|---|---|
| C02 | R0 commit 是否必须按 proof class 和 ownership 拆分为“交互修复”“胶囊/VPA/Layout 返修”“docs/lessons/receipt”，并逐 commit 记录 local/unit/simulator 证据？ | 原句方向对，但要把 commit split 绑定 proof boundary，否则仍可能混 scope。 |
| C12 | R0 是否必须写明 capsule 当前图片是 placeholder，当前裁切只为去除 artifact，不构成 final art、最终尺寸或最终构图决策？ | “placeholder”需要防止被后续 closeout 错读成美术完成。 |
| C31 | Summary card 默认 primary touch 是否只能展开；若允许直接调节，是否必须逐 value type 单独 grill 并提供 writeback/readback/a11y proof？ | 不能泛泛问“是否允许”，RED 需要默认保守和例外门。 |
| C40 | R1 是否至少要求每类手势控件有 accessibility adjustable/button 等替代入口 proof，并明确该 proof 不等于完整 VoiceOver 人审？ | 降低过度工程化，同时保留 a11y 反假绿价值。 |
| C61 | Evidence checker 是否默认只读，只有显式 `--write-summary` 且在 writer scope 内才允许改 summary，并在 read-only audit 中禁止产生 diff？ | 把“默认只读”落到审计可验证行为。 |

## Missing Risks
- 设备硬门应更强：`Tools/checks/capture-8c2-l0-evidence.sh` 存在 Pro Max 找不到时 fallback 到 `iPhone 17 Pro` 的路径；R2 final proof 应要求 Pro Max hard fail 或显式降级为 partial，不能 silent fallback。
- 禁止简单 grep `V-PASS` 判违规：多个 evidence JSON 用 `claims_not_made` 包含 `V-PASS` 字符串；审计必须判断语义是 claim 还是 non-claim。
- Dirty tree 风险不只 pathspec，也包括 untracked evidence/image 目录与已修改 roadmap/CURRENT/handoff 混在同一 worktree；R0 closeout 需要 owned/unowned/generated/no-touch 分类。
- UI test 当前能证明坐标级行为，但不能证明“手指手感高级、动效顺、玻璃质感好”；所有 interaction green 都必须在 R2/L3 前降级为 simulator proof。
- `ContextCapsule` 的 `vehicle.gear` context readout 和演绎控制台 mock context 容易被误写成“vehicle.gear 直接触摸控制已完成”；必须在 R1/R2 closeout 明确 gear 仍不是通用直接控制。

## Scores
| Candidate | Importance | Verifiability | Non-duplication | Decision Leverage | Risk Revelation | Total |
|---|---:|---:|---:|---:|---:|---:|
| C01 | 5 | 5 | 4 | 5 | 5 | 24 |
| C02 | 4 | 4 | 4 | 4 | 5 | 21 |
| C03 | 5 | 5 | 5 | 5 | 5 | 25 |
| C04 | 5 | 5 | 4 | 5 | 5 | 24 |
| C05 | 5 | 5 | 4 | 5 | 5 | 24 |
| C06 | 5 | 5 | 4 | 4 | 5 | 23 |
| C07 | 5 | 5 | 4 | 4 | 5 | 23 |
| C08 | 5 | 5 | 4 | 5 | 5 | 24 |
| C09 | 5 | 4 | 5 | 5 | 5 | 24 |
| C10 | 4 | 5 | 4 | 4 | 4 | 21 |
| C11 | 4 | 4 | 4 | 4 | 5 | 21 |
| C12 | 4 | 4 | 3 | 4 | 4 | 19 |
| C13 | 5 | 4 | 4 | 5 | 5 | 23 |
| C14 | 4 | 4 | 5 | 4 | 4 | 21 |
| C15 | 4 | 5 | 4 | 3 | 4 | 20 |
| C16 | 4 | 5 | 4 | 3 | 4 | 20 |
| C17 | 5 | 5 | 4 | 5 | 5 | 24 |
| C18 | 5 | 5 | 4 | 5 | 5 | 24 |
| C19 | 5 | 4 | 4 | 5 | 5 | 23 |
| C20 | 5 | 5 | 5 | 5 | 5 | 25 |
| C21 | 5 | 4 | 5 | 5 | 5 | 24 |
| C22 | 5 | 5 | 5 | 5 | 5 | 25 |
| C23 | 5 | 5 | 4 | 5 | 5 | 24 |
| C24 | 5 | 5 | 4 | 5 | 5 | 24 |
| C25 | 5 | 4 | 5 | 5 | 5 | 24 |
| C26 | 5 | 5 | 5 | 5 | 5 | 25 |
| C27 | 5 | 5 | 5 | 5 | 5 | 25 |
| C28 | 5 | 5 | 4 | 5 | 5 | 24 |
| C29 | 5 | 5 | 4 | 5 | 5 | 24 |
| C30 | 5 | 5 | 4 | 5 | 5 | 24 |
| C31 | 4 | 3 | 5 | 5 | 4 | 21 |
| C32 | 5 | 5 | 5 | 4 | 5 | 24 |
| C33 | 4 | 5 | 4 | 4 | 4 | 21 |
| C34 | 5 | 5 | 5 | 5 | 5 | 25 |
| C35 | 5 | 5 | 4 | 5 | 5 | 24 |
| C36 | 4 | 4 | 5 | 4 | 4 | 21 |
| C37 | 5 | 5 | 5 | 5 | 5 | 25 |
| C38 | 4 | 4 | 5 | 4 | 4 | 21 |
| C39 | 5 | 5 | 4 | 4 | 5 | 23 |
| C40 | 4 | 3 | 4 | 4 | 4 | 19 |
| C41 | 4 | 5 | 4 | 5 | 4 | 22 |
| C42 | 5 | 5 | 4 | 5 | 5 | 24 |
| C43 | 5 | 5 | 4 | 5 | 5 | 24 |
| C44 | 4 | 5 | 4 | 4 | 5 | 22 |
| C45 | 5 | 4 | 5 | 5 | 5 | 24 |
| C46 | 5 | 4 | 5 | 4 | 5 | 23 |
| C47 | 5 | 5 | 4 | 4 | 5 | 23 |
| C48 | 5 | 5 | 5 | 5 | 5 | 25 |
| C49 | 5 | 5 | 4 | 5 | 5 | 24 |
| C50 | 4 | 4 | 5 | 4 | 4 | 21 |
| C51 | 5 | 5 | 3 | 5 | 5 | 23 |
| C52 | 5 | 4 | 5 | 5 | 5 | 24 |
| C53 | 5 | 4 | 5 | 5 | 5 | 24 |
| C54 | 5 | 5 | 5 | 5 | 5 | 25 |
| C55 | 5 | 5 | 4 | 4 | 5 | 23 |
| C56 | 5 | 4 | 5 | 5 | 5 | 24 |
| C57 | 5 | 5 | 4 | 5 | 5 | 24 |
| C58 | 5 | 5 | 4 | 4 | 5 | 23 |
| C59 | 5 | 5 | 5 | 5 | 5 | 25 |
| C60 | 5 | 5 | 4 | 5 | 5 | 24 |
| C61 | 4 | 5 | 5 | 4 | 4 | 22 |
| C62 | 4 | 4 | 4 | 4 | 4 | 20 |
| C63 | 5 | 4 | 5 | 5 | 5 | 24 |
| C64 | 5 | 5 | 4 | 4 | 5 | 23 |
| C65 | 5 | 4 | 4 | 4 | 5 | 22 |
| C66 | 5 | 4 | 5 | 5 | 5 | 24 |
| C67 | 5 | 4 | 5 | 5 | 5 | 24 |
| C68 | 5 | 5 | 4 | 5 | 5 | 24 |
| C69 | 5 | 5 | 5 | 5 | 5 | 25 |
| C70 | 5 | 5 | 5 | 5 | 5 | 25 |

## Candidate Notes
| Candidate | Note |
|---|---|
| C01 | Keep；dirty tree 已经复杂，owned path 精确列出是防混入旧 roadmap/CURRENT/handoff 的第一道门。 |
| C02 | Rewrite；按 proof class/ownership 拆 commit，否则“交互修复+美术返修+docs”仍会混成一个假绿包。 |
| C03 | Keep；`tasks.md` 的 `8.C2` 当前未勾，L3 未签前任何 UI test 绿都不能关闭。 |
| C04 | Keep；已有 main tree/iPhone 17 Pro 漂移教训，closeout 必须记录 project/scheme/device/xcresult。 |
| C05 | Merge with C51；`cooling + ivory` 来自真实 L3 阻断，应升级为第一 case。 |
| C06 | Keep；外层摘要颜色不联动是用户可见 hard regression，不应只看 expanded row。 |
| C07 | Keep；氛围灯 8 色崩溃和 alias 是 contract-derived options 风险，不只是色板 UI。 |
| C08 | Keep；store 合法值、summary readback 和 UI 选择必须一起验证。 |
| C09 | Keep；`vehicle.gear` 仍是 mock context，不是 10 族通用直接触摸完成证据。 |
| C10 | Keep；identifier 冲突会让 UI test 查错元素，属于 fake proof 风险。 |
| C11 | Merge；预烘焙白壳是资产治理问题，不能只裁当前 PNG。 |
| C12 | Rewrite/Merge；placeholder 必须防止被误写成 final art 决策。 |
| C13 | Keep；frame height 小于阈值不能证明视觉层级不抢。 |
| C14 | Keep；orb 四态若全部映成 listen，会直接破坏 SD16 语义。 |
| C15 | Merge；作为 Layout Integrity Gate 的 capsule/settings/refresh 回归 case。 |
| C16 | Merge；作为 Layout Integrity Gate 的列对齐/min gap 回归 case。 |
| C17 | Keep；最小门必须分 proof class 报告，不能一个 PASS 覆盖全部。 |
| C18 | Keep；独立 read-only audit 是 dirty scope 防线。 |
| C19 | Keep；GPT Image 2/anchor 误用已经造成资产 artifact，必须写入 handoff/prompt。 |
| C20 | Keep；明确不修项能防 final capsule art、true-device、L3 被顺手关掉。 |
| C21 | Keep；policy 是 consumer projection，不应新建第三 SSOT。 |
| C22 | Keep；从 mapper/contract 派生是防 View 层硬编码的关键。 |
| C23 | Merge；矩阵必须包括 proof case，否则只是清单。 |
| C24 | Merge；族覆盖、value type 覆盖、gesture 覆盖必须分开。 |
| C25 | Keep；只读态若保留按钮形态，会制造下一轮假 affordance。 |
| C26 | Keep；ring 假 affordance 是已发生 tiger，必须高优先级。 |
| C27 | Keep；stepper 左右区域语义是已发生 tiger。 |
| C28 | Keep；toggle 写 `on/off` 会产生 contract 外非法 state。 |
| C29 | Keep；当前文本当唯一 option 是已发生 paper green。 |
| C30 | Keep；color swatch 必须同时看外层卡、摘要、expanded row。 |
| C31 | Rewrite；summary 默认 expand-only，例外必须单独 grill。 |
| C32 | Keep；透明 overlay 遮挡同级控件是高概率 UI test 盲区。 |
| C33 | Keep；identifier 是坐标级 proof 基础，但不是独立产品风险最高项。 |
| C34 | Keep；局部 View state 是交互假绿根因之一。 |
| C35 | Keep；至少两层同步验证才能挡“看起来换了但读回没变”。 |
| C36 | Keep；sequencer/stagger 可能制造中间态误判，应有稳定 marker。 |
| C37 | Merge/Keep；proof 类型必须按 gesture 分层。 |
| C38 | Keep；不能只靠动画/玻璃高光表达状态。 |
| C39 | Keep；44pt 对 ring/swatch/stepper/close/settings 是真实手指路径风险。 |
| C40 | Rewrite；至少保留 adjustable/button 替代入口 proof，不扩大成完整 VoiceOver 人审。 |
| C41 | Merge；需要入口，但不能立即塞全量 verify-all。 |
| C42 | Merge；自动门边界必须禁止 L3/审美混入。 |
| C43 | Keep；Pro Max 固定与 frame 打印直接防设备漂移。 |
| C44 | Keep；反例/边界断言能防 happy-path 假绿。 |
| C45 | Keep；小 bug 必须 iceberg 到同 value type/gesture/proof path。 |
| C46 | Keep；changing 态显示假稳定控件会误导人审。 |
| C47 | Keep；中文 display title 兜底可能掩盖非法 contract id。 |
| C48 | Keep；每个 interaction proof 标 proof class 是 RED 主线。 |
| C49 | Keep；grep/code review gate 防第二 formatter/range SSOT。 |
| C50 | Keep；merge-only debt 规则防矩阵项爆炸，也防风险丢失。 |
| C51 | Merge with C05；R2 stage 仍需要，但内容可 cross-ref R0 第一 case。 |
| C52 | Keep；组合边界覆盖 L3 已知风险和 U17 golden path。 |
| C53 | Keep；L0 截图前置交互矩阵，防视觉过后才发现控件假绿。 |
| C54 | Keep；RMSE/WARN 不得推导审美结论。 |
| C55 | Merge；OCR/contrast 只能证明可读性，不证明玻璃、留白、手感。 |
| C56 | Merge；Layout Integrity 是结构门，不是审美门。 |
| C57 | Merge；列出 overlap 关系能让 checker 有真实 target。 |
| C58 | Keep；sentinel 应产出 PASS/WARN/FAIL+crops，避免只丢截图给人找。 |
| C59 | Keep；on-screen simctl 是 L0 proof identity，不可替代。 |
| C60 | Keep；manifest 字段硬门能防 launchArg/theme/device 漂移。 |
| C61 | Rewrite；默认只读要明确 read-only audit 不产生 diff。 |
| C62 | Keep；5 context 状态有价值，但比 proof boundary 风险稍低。 |
| C63 | Keep；context 输入正确和 diorama 好看必须拆开。 |
| C64 | Keep；四态文案/preset 混用会直接破坏 SD16。 |
| C65 | Keep；米白主题 orb 辉光抢层级是已知视觉风险。 |
| C66 | Keep；L3 punchlist 六栏能把人审从“过不过”改成可复核问题单。 |
| C67 | Keep；先看 current screenshot/crop 能降低自动绿灯锚定。 |
| C68 | Merge；placeholder/final-art-deferred 必须写进 closeout。 |
| C69 | Keep；R2 fail 的写回规则是防 fake completion 的关键。 |
| C70 | Keep；R3 前独立审是进入 closeout 的最后防线。 |

## Rationale
本轮 RED 判断基于四个 live-verified 锚点：

1. `docs/uiue-roadmap-2026-06-27-post-8c2-baseline.md` 明确 UIUE 当前 `8.C2` 为 `PARTIAL_PENDING_L3`，且禁止把 local/unit/simulator 证据写成 V-PASS/mobile/true_device/A-2 complete。
2. `openspec/changes/ui-presentation/tasks.md` 中 `8.C2 visual-acceptance` 仍未勾选；`openspec/.../spec.md` 明确 L3 human 5-gate 才是 V-PASS authority。
3. `docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/README.md` 记录 L0/L1/L2 已有证据，但 L3 仍 pending，且人审已发现 `cooling + ivory`、假交互、device/tree drift、capsule artifact 等阻断。
4. 代码抽查显示 `ValueControlView`、`UIC2VisualAcceptanceUITests` 已补 ring/stepper simulator proof；这提高 local/simulator 可信度，但不改变 L3、mobile、true_device、A-2 complete 边界。

因此评分偏向能揭穿假绿、proof class 升格、dirty scope 混入、anchor/GPT Image 2 误用和“UI test 只测存在不测手感”的候选。

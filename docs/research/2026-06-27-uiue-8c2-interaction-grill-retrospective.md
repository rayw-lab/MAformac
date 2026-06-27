# UIUE 8.C2 Interaction Grill 复盘

日期：2026-06-27
scope：`8.C2` L3 人审返修后的交互流程复盘
proof class：`local` + `unit` + `simulator_ui_test`
status：`PARTIAL_PENDING_L3`

> 本文不是 L3 签核。磊哥仍在体验，`8.C2` 保持 open；只有磊哥可以签 `V-PASS`。

## 现象

本轮 L3 人审继续发现两个细节：

- 环形控件看起来可以直接操作，但按住圆圈不能顺/逆时针连续调节。
- 点按环形控件不同区域没有空间语义：下方应减小，左上/红框区域应增大；同类分段条也不应“点哪都增大”。

修复后，`ValueControlView` 为 `.dial/.percent` 增加环形空间手势，为 `.stepper` 增加左右区域语义；`ValueRangeMapper` 统一 clamp、step snap、角度 delta；`UIC2VisualAcceptanceUITests` 在 `iPhone 17 Pro Max` 增到 14 条，覆盖空间点按、顺/逆时针拖拽和 stepper 左右点按。

## 为什么之前没有 grill 出来

1. 决策迁移没有补交互矩阵。

`openspec/changes/ui-presentation/design.md` 旧 AD-8 明确写过“触摸调节=砍”，后续 `spec.md` 又把 4b composite 数值控件改成 SHALL 写 mock store。这个迁移本身合理，但没有同步开一张 value type × gesture × writeback × readback 的矩阵，导致“能写回”被误当成“手感语义完整”。

2. 之前的 grill 更擅长契约正确性，不擅长手感细节。

`answer-grill` 的稳态是短句、实测 cite、物理 cash-out、scope tagging；它能抓 hidden assumptions 和 counterexample narrowing，但本质仍偏“概念落地/证据约束”。本次 bug 属于 on-glass interaction semantics：用户手指按在圆圈某一段时，控件是否符合身体直觉。这个需要可点原型或 UI test 坐标验证，不能只靠文字 grill。

3. L0/L1/L2 证据层覆盖错位。

当前视觉 gate 的 L0/L1/L2 主要证明可启动、可读、未塌陷；L3 才判断审美和体验。我们之前把“primary touch 写回”补成了 UI test，但测试只证明触摸目标存在，没有证明空间区域、连续拖动和方向语义。

4. “10 族覆盖”还不是“每个 value type 的交互覆盖”。

10 族代表控件能防崩溃、防完全无写回，但不能自动覆盖每种 value type 的所有 gesture semantics。`window.position` 暴露的是 `.percent` 环形行为；`seat.heat_level` 暴露的是 `.stepper` 空间语义。族覆盖和控件语义覆盖必须分开算。

## Iceberg teardown 结论

| 层 | 结论 | 证据/落点 |
|---|---|---|
| Tiger | `.dial/.percent` 环形控件缺少空间点按与连续拖拽语义 | `ValueControlView` 新增 `CircularAdjustmentGestureLayer`；UI test 覆盖下方减小、左上增大、顺/逆时针拖拽 |
| Tiger | `.stepper` 分段条也有同类假空间语义 | `StepperBarGestureLayer` 点左减、点右增；UI test 覆盖座椅加热 `2挡 -> 1挡 -> 2挡` |
| Paper-tiger | badge/toggle/options 不是本轮新增空间手势问题 | 前一轮已用 contract-derived options、enum toggle、readback tests 收口；本轮只复核不重构 |
| Elephant | grill 流程缺少 Interaction Integrity 专门门 | 本文建议新增多轮/多 agent 交互门，不能把 value writeback test 当完整手感验收 |

## 当前 grill 决策现状

- `docs/grill-tournament/GRILL-SYSTEM.md` 是新开 grill 的流程入口，不是每个 UIUE 结论的唯一 SSOT。
- `docs/grill-checklist/uiue-a2-grill-coverage-index.md` 是 tracking index，不是 OpenSpec SSOT；它能提示 SD7 触摸调节仍有 drag/operator-pass 风险，但不能替代逐控件 interaction ledger。
- `openspec/changes/ui-presentation/specs/ui-presentation/spec.md` 当前才是 `ui-presentation` 行为契约权威：展开卡数值控件 SHALL 写 mock store、复用 `ValueRangeMapper`、不在 view 重写 range 逻辑。
- `openspec/changes/ui-presentation/tasks.md` 的 `8.C2` 仍 unchecked；8.G 只定义了门，不代表 L3 通过。

## 优化 grill 流程

新增一个 `Interaction Integrity grill` 子门，放在 visual L3 前、implementation 后，按下表逐项问：

| 维度 | 必问问题 | 最小 proof |
|---|---|---|
| affordance | 看起来可点的区域是否真实可写回 | UI test 或人工操作 receipt |
| spatial semantics | 点左/右/上/下是否符合用户预期 | 坐标级 UI test |
| continuous semantics | drag 是否连续、方向是否正确、跨 0 点是否稳定 | UI test + mapper unit test |
| contract | 写回是否复用 mapper/contract，不在 View 重写范围 | unit test + code review |
| readback | 摘要、展开行、语音/文本读回是否同步刷新 | UI tree/readback test |
| a11y | 手势能力是否有 adjustable/button 替代入口 | accessibility identifier/action review |
| proof boundary | simulator proof 是否被误升级成 L3/V-PASS | receipt/status audit |

建议多轮：

1. Round 0：决策迁移核账。凡是从“禁触摸/只读”迁移到“可触摸写回”的点，必须重开交互矩阵。
2. Round 1：静态合同 grill。核 value type、range、enum、source、readback 是否有 SSOT。
3. Round 2：可点原型/手感 grill。专门让 reviewer 按用户手指路径描述预期，不看代码实现。
4. Round 3：实现后反向审计。每个可点区域必须有 action/writeback/readback；只读态不得像控件。
5. Round 4：L3 punchlist。人审发现一个小 bug，立即用 iceberg teardown 扩到同 value type、同 writeback path、同 proof gap。

建议多 agent：

- `designer`：只按用户手指和车载 HMI 直觉挑交互反例。
- `executor`：只看实现路径是否复用 contract/mapper，避免 View 内第二 SSOT。
- `test-engineer`：把反例转成坐标级 UI test、mapper unit test、readback test。
- `auditor`：只查 proof/status，不允许把 simulator/local 写成 L3/V-PASS。

Controller 最终合并，冲突优先级仍是：live repo/config/receipt > validator/test stdout > visible UI > dated report > subagent prose。

## 本轮吸收成规则

- 发现小交互 bug，不只修截图上的控件；先按 `$bug-iceberg-teardown` 扩到同 value type 和同 gesture family。
- “10 族都能点”不是“所有交互语义都对”；族覆盖、value type 覆盖、gesture 覆盖要分三张表。
- `answer-grill` 适合把概念和反例落到物理形态，但必须接一个可交互手感门；否则会继续漏掉这种“手指一按才知道”的问题。
- 任何本地/模拟器自动化通过，都只能写 `local/unit/simulator` proof；磊哥没签前，`8.C2` 仍 open。

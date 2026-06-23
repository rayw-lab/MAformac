## 保留项

- **R4-Q01 TRN7 mlx-lm feasibility**：保留，建议轻改写。它直击“本机能否承受 G6-C / 四类数据训练”的执行生死线，且能用数据量估算、preflight、内存峰值、checkpoint 频率和 fallback receipt 验证。
- **R4-Q02 TRN8 endpoint parity**：保留，建议限定为“端侧 endpoint parity”，避免重复已确认的 train/eval/runtime surface 同源题。它把 `mlx-swift` 暂无 GBNF/端侧受限解码未证实这个反例放进题面，是高质量 grill。
- **R4-Q03 TRN9 DoRA/复杂推理升级排期**：保留但必须改写。方向重要，但“何时启动”容易变成路线偏好；必须落成明确禁启条件、触发条件和不得重开 recipe 的证据门。
- **R4-Q04 UIX1 UIUE 30+ findings triage**：保留。它要求逐条三分 matrix，能把 UIUE 调研从“审美意见堆”变成 demo 范围裁剪工具。
- **R4-Q05 UIX2 10族 mock cards**：保留。它补的是 B2 真前置：工具多、端态字段少、卡片更少。若不问，容易出现模型识别对但 UI 无状态变化的假炸场。
- **R4-Q06 UIX3 visual stance**：保留为低优先级改写题。它有价值，但必须被约束成证据门和审美 5 Gate，不应重开无边界视觉争论。
- **R4-Q07 UIX4 engineering hard preflight**：强保留。它是“能跑”硬前置，不是 polish；Info.plist、entitlements、麦克风崩、OOM 都可命令验收。
- **R4-Q08 UIX5 onsite SOP pre-mortem**：保留。它把现场失败模式从风险叙述转成 SOP/checklist，能直接降低演示翻车概率。
- **R4-Q09 UIX6 route UI states**：保留。它连接三层路由、DialogueState、clarify/refusal 与最小 UI 状态，是从模型链路到用户可感知反馈的关键桥。

## 删除项

- **无建议纯删除项**。
- 若最终名额被压缩，**R4-Q06** 是第一删/并候选：视觉 stance 的主线杠杆低于 R4-Q07、R4-Q05、R4-Q09，且可以部分并入 R4-Q04 的 UIUE triage matrix。

## 合并项

- **不建议强制合并 R4-Q05 与 R4-Q09**：二者都谈 UI 状态，但层级不同。R4-Q05 是 10 族 mock 端态卡片和 state field；R4-Q09 是 route/dialogue/refusal/clarify 的过程态。可以共享验收产物，但不应合成一个大题。
- **不建议强制合并 R4-Q07 与 R4-Q08**：二者都关乎 demo 可靠性，但 R4-Q07 是 build/runtime hard blocker，R4-Q08 是现场 SOP。若合并会稀释“Info.plist/.entitlements 是能跑前置”的硬度。
- **可条件合并 R4-Q06 到 R4-Q04**：若需要减少题数，把 R4-Q06 的“守现状/重起/局部调整证据门”作为 R4-Q04 triage matrix 的一列，而不是独立审美题。
- **R4-Q02 需与已确认 Q05 去重**：保留 R4-Q02 的前提是把它写成 endpoint-specific parity，包括 render byte diff、mounted whitelist、防御解析和 endpoint decode spike；不要重复 broad train/eval/runtime surface 同源 enforce。

## 改写建议

- **R4-Q01**：把“是否可承受”改成可签收的四项：`estimated_rows/tokens/steps`、`preflight_runtime_peak_memory`、`checkpoint_interval=50/100/150`、`fallback_trigger`。要求区分 Mac 本机主路、云 Mac 扩展、降 batch/grad accumulation，而不是泛泛“fallback 策略”。
- **R4-Q02**：题面里保留“mlx-swift 暂无 GBNF/端侧受限解码未证实”。改成两阶段验收：`render_parity_diff=0` 阻 G6-C；`endpoint_decode_spike` 未过则不得宣称端侧 constrained decoding V-PASS。白名单门应是解析层 `tool_not_in_whitelist=0`，不是假设采样层能硬约束。
- **R4-Q03**：改成“升级禁启/触发矩阵”。短期：场景宏只允许挂载工具和已建 state cell；G6-C V-PASS 前禁止 DoRA/QAT/复杂推理重训；V-PASS 后才按 failure mode 触发 DoRA、更多数据或复杂推理样本。
- **R4-Q04**：要求每条 UIUE finding 带 `source_id`、`decision=demo|irrelevant_by_10family|cut`、`why`、`landing_artifact`、`owner_gate`。否则“逐条三分”会退化为口头分类。
- **R4-Q05**：题面应点名物理落点：`state-cells.yaml` 扩 10 族、`tool-card-map.demo10.json`、卡片字段、readback template、视觉优先级。按 value.type 分层时要防止把车门这类纯规则族过度动画化。
- **R4-Q06**：把“视觉 stance 是否成立”改成“什么证据会推翻/保留/局部调整”。必须包含投影/现场设备验收、SwiftUI 可实现性、性能 budget、审美 5 Gate、与 10 族 demo-golden-run 的贴合度。
- **R4-Q07**：改成 hard preflight checklist：缺 Info.plist、缺 entitlements、麦克风权限崩、模型加载 OOM、主线程冻结，分别给验收命令/日志字段/demo-blocker 等级。不要把它放在 UI polish 队列。
- **R4-Q08**：要求输出“Mac 主设备已消除 / 仍需 SOP / 不适用”三分表。每项必须是可执行检查，例如 Release 彩排、重签时间、电量/Reduce Motion、模型预加载、离线网络状态、崩溃日志路径。
- **R4-Q09**：改成最小 UI 状态 contract：`route_state`、`dialogue_state`、`clarify_state`、`refusal_state`、`mock_state_delta`。用空调/车窗/雨刮/香氛 second_turn_refs 高频族做验收样本，避免重新讨论三层路由架构本身。

## 遗漏风险

- **视觉验收环境缺口**：R4-Q06/R4-Q08 未显式要求“客户实际查看环境”验收。投影、会议室亮度、Mac 主屏/iPhone 辅屏会改变深空暗底和辉光可读性。
- **demo-golden-run 单源缺口**：R4-Q04/R4-Q05/R4-Q09 都会碰五幕脚本、must-pass、UI 状态，但题面没有要求统一锚到一个 demo-golden-run 合同，存在 UIUE 脚本和 C6 must-pass 漂移风险。
- **state-cells 扩 10 族是硬依赖**：R4-Q05 提到 mock cards，但没有直接点出当前 state-cells 不覆盖 10 族时，卡片字段设计会无源可落。
- **工具数口径缺口**：R4-Q05 如果按“10族工具数”展开，必须避免把 534 intent 误写成工具数；工具数仍需按 value-form/挂载白名单实算。
- **端侧受限解码 framing 缺口**：R4-Q02 已明显优于旧题，但仍需强调“grammar 可行性未证实，不通过不得叫 V-PASS”。否则会再次把训练态可行想当然迁移到 endpoint。
- **复杂推理范围膨胀**：R4-Q03 若不限定“宏只能用已挂载工具/已建 cell”，容易把未落地工具引进 golden-run，制造新脱靶源。
- **SOP 与 hard blocker 边界**：R4-Q07/R4-Q08 若混写，容易把能跑前置降格成现场提醒；两题必须保留分层。

## 评分

| ID | 建议 | 重要性 | 可验证性 | 非重复性 | 主线决策杠杆 | 风险揭示 | 总分/25 |
|---|---|---:|---:|---:|---:|---:|---:|
| R4-Q01 | Keep + Rewrite | 5 | 5 | 4 | 5 | 5 | 24 |
| R4-Q02 | Keep + Rewrite | 5 | 5 | 3 | 5 | 5 | 23 |
| R4-Q03 | Rewrite | 4 | 4 | 4 | 4 | 4 | 20 |
| R4-Q04 | Keep + Rewrite | 5 | 4 | 5 | 5 | 4 | 23 |
| R4-Q05 | Keep | 5 | 5 | 4 | 5 | 5 | 24 |
| R4-Q06 | Rewrite / Merge-if-needed | 3 | 3 | 4 | 3 | 3 | 16 |
| R4-Q07 | Keep | 5 | 5 | 5 | 5 | 5 | 25 |
| R4-Q08 | Keep + Rewrite | 5 | 5 | 4 | 4 | 5 | 23 |
| R4-Q09 | Keep + Rewrite | 5 | 4 | 4 | 5 | 4 | 22 |

## 理由

- **R4-Q01** 分数高，因为它逼问训练实际成本和 fallback。它不是抽象技术选型，而是直接决定 G6-C 能否在本机按 50/100/150 节奏跑出诊断信号。
- **R4-Q02** 是高价值题，但非重复性扣分，因为 broad train/eval/runtime parity 已有确认题。它必须缩到端侧 endpoint parity，才不是重复。
- **R4-Q03** 目前像排期讨论，质量取决于能否改成“禁启/触发/升级”合同。它的价值是防止 G6-C 前重开 recipe 或用 DoRA 掩盖 surface/data 问题。
- **R4-Q04** 能把 UIUE 30+ findings 从主观审美裁剪成 demo 范围决策。主要风险是题太大，必须强制逐条矩阵和落点字段。
- **R4-Q05** 是 UI 和 C3/C6 的关键连接题：mock card 没有状态字段，demo 就只能“听懂但不显化”。它还能暴露 state-cells、tool-card-map、value.type 分布和 readback 的一致性问题。
- **R4-Q06** 是本轮最低分，不是因为无价值，而是因为容易滑向审美争论。只有绑定审美 5 Gate、性能和现场验收，它才值得独立存在。
- **R4-Q07** 是满分题。它直接把“App 能不能跑”从 UI polish 中拎出来，且每个子项都有明确命令、权限、崩溃或内存证据。
- **R4-Q08** 价值在现场可靠性，但必须和 R4-Q07 分层：Mac 主设备能消掉一部分风险，但不能消掉 Release 彩排、离线状态、低电量/Reduce Motion、模型预热和现场重签 SOP。
- **R4-Q09** 是必要的用户可感知链路题。它避免 route/DialogueState 只留在 SRD 里，要求映射到 L1 秒回、L2-L5 思考、clarify、refusal 和二次指代的最小 UI 状态。

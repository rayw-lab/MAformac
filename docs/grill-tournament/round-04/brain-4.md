## 保留项

- R4-Q01 保留为独立题。它补的是 TRN7 的本机训练承载边界，和已确认的中途 C6 gate 不同：前者问“能不能在本机按计划训完并复跑”，后者问“训到一半怎么早停/签收”。
- R4-Q04 保留为独立题。UIUE 30+ findings 如果不按 MVP 10族重筛，会把族外视觉债、真实 demo 必需项和审美偏好混在一起。
- R4-Q05 保留为独立题，但必须强化为“状态协议 + 卡片设计”题，不只是 UI 题。10族 mock cards 是 B2/state-cells 扩 10族的落点。
- R4-Q07 保留为最高优先独立题。这是能跑硬前置，不是 polish；缺 Info.plist/.entitlements、麦克风崩、OOM 都应成为 demo-blocker 条件。
- R4-Q08 保留为独立题。现场 SOP 能把“Mac 主设备”假设、证书/电量/动画/冻结风险拆开，避免把工程风险误归为现场运气。
- R4-Q09 保留但要改写。它能把三层路由、DialogueState、clarify/refusal 和 C6/demo-golden-run UI 验收连起来，价值高于普通动效题。

## 删除项

- 无纯删除项。
- R4-Q02 若坚持作为泛泛“train/eval/runtime parity”独立题，应删除，因为前几轮已有同源 surface parity / AUD5 类题；只有收窄成端侧 endpoint decode spike + render byte diff 子题才值得保留。

## 合并项

- R4-Q02 合并进已确认的 surface parity / AUD5 线，作为“端侧 mlx-swift endpoint parity”子门：`render_parity_diff=0`、mounted whitelist、JSON 三层防御解析、`tool_not_in_whitelist=0`、endpoint decode spike。
- R4-Q03 与已确认的 recipe freeze / TRN1 线合并，只保留新增部分：DoRA 和复杂推理升级的“禁止提前启动 + V-PASS 后触发条件”。
- R4-Q06 可以并入 UIX1 的 triage 或后续 UIX9 的审美 5 Gate；若独立保留，必须从“视觉风格争论”改成“现有视觉 stance 的证据门复核”。
- R4-Q09 与 R4-Q05 有状态呈现重叠，但不应合并掉；R4-Q05 管 mock 端态卡片，R4-Q09 管 route/dialogue UI 态，两者只共享 state_cell/card_id 映射证据。

## 改写建议

- R4-Q01：加上 checkpoint 磁盘占用、swap/thermal、resume/retry、最长可接受 wall-clock、失败 fallback 的硬字段。否则“可承受”仍会变成口头判断。
- R4-Q02：改名为“mlx-swift endpoint parity spike”，避免暗示端侧 GBNF 已成立。题面要明确：GBNF 只作待证或 fallback，主线验 LoRA 格式 + 防御解析 + 白名单 fail-closed。
- R4-Q03：要求输出 `forbidden_until`、`trigger_metrics`、`allowed_macro_ids`、`recipe_reopen_conditions` 四类可检查字段。不要让“复杂推理以后再说”变成无限期 open point。
- R4-Q04：要求每条 UIUE finding 带 source id/path、scope 判定、MVP demo action、owner/gate。三分 matrix 不能只写“采纳/不采纳”。
- R4-Q05：补 state-cells 当前覆盖缺口、`tool-card-map.demo10.json`、state patch/readback 关系；卡片数应从状态字段推导，不从视觉偏好拍脑袋。
- R4-Q06：把“深空辉光暗底三屏分层”拆成信息架构、视觉语言、SwiftUI 可实现性、现场显示环境四个证据门；审美 5 Gate 必须有截图/投影/设备验收，不接受抽象形容词。
- R4-Q07：补验收命令清单：app target lint、entitlements/microphone permission、Release launch、memory pressure/OOM、麦克风真实授权路径；并定义 G6/A2 前置排序。
- R4-Q08：把风险按 `eliminated_by_mac_primary` / `still_requires_preflight` / `requires_scripted_fallback` 分三类。否则“Mac 主设备”会被滥用为风险免死牌。
- R4-Q09：要求 UI 态绑定 trace/route enum，而不是只做动画名；用空调/车窗/雨刮/香氛 second_turn_refs 高频族做最小验收，不要扩成全族 UI 体系。

## 遗漏风险

- 9题里没有直接防止“534 intent 被当工具数”的 UI/训练级联错误。R4-Q05 和 R4-Q02 都应显式禁止把 intent 数当 mounted tool 数。
- R4-Q05 没明说 state-cells 现在只覆盖 4 组，这会让评审低估它的工程前置性。
- R4-Q02 虽然提到 mlx-swift 暂无 GBNF，但还需要区分训练态 grammar、端侧 decode、解析层 whitelist 三个 scope，防止 frame overflow。
- R4-Q08 的“Mac 主设备”假设需要目标设备矩阵；如果最终仍要 iPhone 展示，证书、低电量、jetsam 不能被 Mac 假设消除。
- R4-Q04 依赖 raw UIUE 调研目录；若不要求 finding id/source path，后续无法复核 41维/30+ 是哪一版清单。
- R4-Q03 容易把 DoRA 和复杂推理绑成同一个升级包。其实 DoRA 是训练技术，复杂推理是产品能力；题面应要求分开触发。

## 评分

| ID | 重要性 | 可验证性 | 非重复 | 主线决策杠杆 | 风险揭示 | 总分 | 建议 |
|---|---:|---:|---:|---:|---:|---:|---|
| R4-Q01 | 5 | 5 | 4 | 5 | 5 | 24/25 | keep |
| R4-Q02 | 5 | 5 | 2 | 4 | 4 | 20/25 | merge/rewrite |
| R4-Q03 | 4 | 4 | 3 | 4 | 4 | 19/25 | rewrite |
| R4-Q04 | 5 | 4 | 5 | 5 | 4 | 23/25 | keep |
| R4-Q05 | 5 | 5 | 4 | 5 | 5 | 24/25 | keep/rewrite |
| R4-Q06 | 3 | 3 | 4 | 3 | 3 | 16/25 | rewrite |
| R4-Q07 | 5 | 5 | 5 | 5 | 5 | 25/25 | keep |
| R4-Q08 | 4 | 5 | 5 | 4 | 5 | 23/25 | keep |
| R4-Q09 | 4 | 4 | 4 | 4 | 4 | 20/25 | keep/rewrite |

## 理由

- R4-Q07 是本轮最硬的问题：它直接决定 G6/A2 前能不能真实运行，且所有验收都能落到命令、target 配置、权限和崩溃/OOM receipt。
- R4-Q01 与 R4-Q05 次高。前者防止“训练计划理论成立、本机实际跑不动”；后者防止“模型识别对了，但 mock UI 没有可变状态承接”，这是 demo 失败的典型表面化风险。
- R4-Q04 和 R4-Q08 都是 scope 管理题。它们的价值在于把 10族 demo 约定变成可删可留的矩阵和现场 checklist，而不是继续堆调研结论。
- R4-Q02 重要但重复风险最大。它的好处是抓住 mlx-swift/GBNF 未证实这个真实坑；问题是 parity 主线已经被多轮确认，独立保留会稀释最终 41题列表。
- R4-Q03 的问题意识对，但现在题面仍偏“升级讨论”。真正要 grill 的是禁止条件和触发门，否则会提前重开 recipe，冲掉 rank16Mainline 和 G6-C 终判纪律。
- R4-Q06 是本轮最弱项，不是因为视觉不重要，而是它最容易滑回审美辩论。只有绑定现有 UIUE steelman、审美 5 Gate、现场设备截图验收，才有资格进入有效 grill 题。
- R4-Q09 的价值在于把 route/dialogue 状态可视化纳入 demo 验收；它不能被降成“加载态动画”，也不能和 mock 端态卡片混为一谈。

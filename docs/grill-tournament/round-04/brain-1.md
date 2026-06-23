## 保留项

- **R4-Q01 保留**。这是 TRN7 的核心缺口：本机 `mlx-lm 0.31.1` 是否真能承受四类数据、seed、变体规模和 50/100/150 checkpoint 节奏。问题已经要求数据估算、preflight 实测、硬件/env receipt 和 fallback，足够具体、可验。
- **R4-Q02 保留但需窄化**。端侧 parity 是生死线，且候选已显式纳入“mlx-swift 暂无 GBNF/端侧受限解码未证实”的事实。保留重点应是 endpoint/render/parse/mounted whitelist，而不是重复已确认的 train/eval/runtime surface 同源大题。
- **R4-Q04 保留但需先定输入清单**。UIUE 41 维/30+ findings 的筛选直接决定 demo UI scope，主线杠杆高。问题要求逐条三分 matrix，是正确形态。
- **R4-Q05 保留**。10 族 mock cards 是 UI 可变状态和 D-domain tool-card-map 的实际落点，能直接防止“识别对但 UI 无态可变”。它比纯审美题更接近 demo 成败。
- **R4-Q06 保留但需改写成证据门**。视觉 stance 不应无限重开，但“深空辉光暗底三屏分层 + native SwiftUI”是否仍成立，需要用 10 族、现场投屏、审美 5 Gate、性能门来复核。
- **R4-Q07 保留**。Info.plist、entitlements、麦克风崩、OOM 不是 polish，是“能跑”前置。它应排在 UI 美化前，是 Round 04 最硬的 UIX 题之一。
- **R4-Q08 保留**。现场 SOP/pre-mortem 与工程 preflight 不同：前者管证书、电量、投屏、降频、低电量、fallback 演示流程。问题质量高，但要落成可执行 checklist。
- **R4-Q09 保留**。三层路由 UI 态是架构可见化：L1 秒回、L2-L5 思考、clarify、refusal、DialogueState/歧义反问必须在 demo 中被看见。用 second_turn_refs 高频族收敛范围是好约束。

## 删除项

- **无整题删除**。Round 04 的 9 题基本覆盖 ledger 标出的 TRN7-TRN9 与 UIX1-UIX6 缺口，直接删题会留下空洞。
- **局部删除 R4-Q03 的“DoRA 独立重开”倾向**。DoRA/配方升级已经被前序 recipe-freeze 题约束；若 R4-Q03 继续问“要不要上 DoRA”，会重复旧争论。应删掉“技术新就重开”的暗示，只保留“何种证据允许升级”的门。

## 合并项

- **R4-Q03 合并进已确认的 recipe freeze / reopen 逻辑**，只保留新增的“复杂推理升级触发条件”。最终题应变成：G6-C V-PASS 前哪些训练技术和复杂推理能力禁止进入主线，V-PASS 后用什么证据触发 DoRA/QDoRA、rank、复杂推理 LoRA 的 secondary 实验。
- **R4-Q02 与既有 surface parity 题只做引用，不合并吞掉**。已确认题管“同源 enforce”，R4-Q02 应专管“端侧 mlx-swift endpoint 是否真的按同一 bytes、同一白名单、同一 JSON 防御解析执行”。
- **R4-Q07 与 R4-Q08 不建议合并**。R4-Q07 是 build/runtime hard preflight，R4-Q08 是现场 SOP。可以共享一个 `demo-preflight-checklist` 产物，但问题本身不同。
- **R4-Q04 与 R4-Q06 不建议合并**。R4-Q04 是 41 维 findings triage，R4-Q06 是视觉主方向是否继续。一个管范围筛选，一个管视觉 stance 的证据门。

## 改写建议

- **R4-Q01**：补上验收输出字段：`estimated_rows_by_class`、`tokens_per_step_estimate`、`preflight_wall_clock_minutes`、`peak_memory_or_phys_footprint`、`checkpoint_write_cost`、`fallback_trigger`。不要只问“能否承受”。
- **R4-Q02**：改成“两阶段 endpoint parity”：第一层 `render_byte_diff=0` 阻断 G6-C；第二层 `endpoint_decode_spike` 验证 mlx-swift LoRA 格式、JSON 三层防御解析、mounted whitelist、`tool_not_in_whitelist=0`。GBNF 只能作为待证或 fallback，不可写成主线已具备。
- **R4-Q03**：改成“升级触发门”，不要把 DoRA 和复杂推理混成一个泛泛路线题。短期场景宏必须是 deterministic code；LoRA 学推理只能在 G6-C V-PASS、四层 C6 门稳定、endpoint parity 过后进入 secondary。
- **R4-Q04**：先要求指定 UIUE 输入源：`GRILL-MASTER.md` 31 条、round3 41 维、或 30+ findings 的具体文件。matrix 字段建议为 `finding_id/source`、`demo10_relevance`、`keep_reason`、`cut_reason`、`required_artifact`、`verification`。
- **R4-Q05**：补上 state-cell 前置：当前 state-cells 不覆盖 10 族时，卡片设计必须输出 `tool -> IR -> state_cell_id -> card_id -> patch`，并定义每族最少可变字段，而不是只画卡片。
- **R4-Q06**：把“审美争论”改成三门：投屏/现场可读性门、性能/低电量/ReduceMotion 门、审美 5 Gate。只有任一门失败才允许重起视觉方向，否则只做局部调整。
- **R4-Q07**：写成 G6/A2 前置排序题：缺 Info.plist、entitlements、麦克风权限、memory entitlement、Release build smoke、model loading OOM 任一失败是否 demo-blocker，并列出命令或 Xcode receipt。
- **R4-Q08**：把每个现场风险落成 check item：谁检查、何时检查、命令或人工动作、失败 fallback。特别要区分 Mac 主设备消除的风险与 iPhone 加分项仍存在的风险。
- **R4-Q09**：补最小状态枚举：`fast_executing`、`thinking`、`clarifying`、`refusing_safety`、`unsupported`、`followup_resolved`、`followup_ambiguous`。用空调/车窗/雨刮/香氛各至少一个 second-turn case 做 C6/demo-golden-run 验收。

## 遗漏风险

- **UIUE 输入源仍不稳定**。主文档说“41 维/30+问题对应哪份清单待确认”，raw 下又有三轮 31 条 grill、round3 41 维和 79 findings。R4-Q04 若不先定输入源，triage 会变成对错清单混跑。
- **“Mac 主设备”可能被误用成免检牌**。它能消除一部分证书和 jetsam 风险，但不能消除 Release smoke、投屏、热降频、低电量动画、端侧模型卡 UI、iPhone 加分项的 preflight。
- **TRN8 的隐藏坑是“端侧受限解码”尚未成立**。若问题措辞滑回 GBNF/Outlines 主线，会把已知重大事实反着写。
- **R4-Q03 容易再次重开 recipe**。除非把“禁止项”和“升级触发条件”写死，否则它会消耗主线决策力，重复 Q23/TRN1。
- **UI 状态可能被降级成 spinner 美化**。R4-Q09 必须要求 route/outcome/state 的可验映射，否则三层路由无法在 demo 中被观察。
- **缺 UIX7-UIX9 的后续入口**。本轮只到 UIX6，语音 UI、golden-run 编排、组件 adopt/审美 5 Gate 仍要进入后续轮次或最终补题，不能因 Round 04 结束而丢。

## 评分

| 候选 | 重要性 | 可验证性 | 非重复 | 主线决策杠杆 | 风险揭示 | 总分 | 建议 |
|---|---:|---:|---:|---:|---:|---:|---|
| R4-Q01 TRN7 mlx-lm feasibility | 5 | 5 | 4 | 5 | 5 | 24 | keep |
| R4-Q02 TRN8 endpoint parity | 5 | 5 | 3 | 5 | 5 | 23 | rewrite-keep |
| R4-Q03 TRN9 DoRA/复杂推理升级排期 | 4 | 4 | 2 | 4 | 4 | 18 | merge-rewrite |
| R4-Q04 UIX1 UIUE findings triage | 5 | 4 | 5 | 5 | 4 | 23 | rewrite-keep |
| R4-Q05 UIX2 10族 mock cards | 5 | 5 | 5 | 5 | 5 | 25 | keep |
| R4-Q06 UIX3 visual stance | 4 | 3 | 4 | 4 | 4 | 19 | rewrite-keep |
| R4-Q07 UIX4 engineering hard preflight | 5 | 5 | 5 | 5 | 5 | 25 | keep |
| R4-Q08 UIX5 onsite SOP pre-mortem | 5 | 5 | 4 | 4 | 5 | 23 | keep |
| R4-Q09 UIX6 route UI states | 5 | 5 | 4 | 5 | 5 | 24 | keep |

## 理由

Round 04 的有效价值不是再证明“D-domain/10 族/四类数据”这些已拍事实，而是补齐剩余可执行门：训练能不能在本机跑完、端侧是不是同一行为、UI 是否真的能表达 10 族 mock 态、现场是否会崩。

最强的三题是 **R4-Q05、R4-Q07、R4-Q09**。它们都能直接落到 artifact 或验收命令：state-cell/card mapping、工程 preflight、route UI 状态与 golden-run case。它们揭示的是 demo 会不会“看起来真的能控车”和“现场会不会炸”的硬风险。

最需要克制的是 **R4-Q03**。它的重要性不低，但当前形态把 DoRA、配方、复杂推理混在一起，且与前序 recipe freeze 题重复。正确用法是把它改成升级闸门：未过 G6-C 和 endpoint parity 前禁止重开，过后才允许 secondary 实验。

R4-Q02 必须保留，因为 `mlx-swift` endpoint parity 是 C5 候选能否变成端侧 demo 的硬门；但它必须承认“端侧 GBNF 未证实”，把主验收放在 byte diff、白名单、防御解析和 tool whitelist，而不是把受限解码当已解决。

UIX 题整体质量高，但要防两个 frame-lock：一是把 UIUE 原始清单混成一个模糊“30+ findings”；二是把“Mac 主设备”误解成现场风险全清零。保留这些题的前提，是每题都要求可执行检查、matrix 字段、或可验 UI 状态，而不是审美偏好描述。

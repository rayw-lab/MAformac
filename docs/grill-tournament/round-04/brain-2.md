## 保留项

- **R4-Q07 UIX4 engineering hard preflight**：最该保留。它把“能不能跑”从 UI polish 中剥离出来，能直接落到 G6/A2 前置门、验收命令、demo-blocker，且能暴露麦克风崩、OOM、entitlements 等现场致命风险。
- **R4-Q01 TRN7 mlx-lm feasibility**：保留。它补的是训练计划的物理承载能力，不是配方争论；要求数据量估算、preflight 实测、硬件/env receipt、fallback，足够具体可验。
- **R4-Q04 UIX1 UIUE findings triage**：保留。它强制把 30+ UIUE findings 过一遍 MVP 10 族和现场话术边界，避免 UI research 以“都重要”的形式膨胀。
- **R4-Q05 UIX2 10族 mock cards**：保留。它击中“模型识别对但 UI 无态可变”的产品失败点，应当落成 `tool -> state_cell -> card -> patch` 类映射。
- **R4-Q08 UIX5 onsite SOP pre-mortem**：保留。它能把现场风险从叙述变成可执行 checklist，尤其适合 demo 工程。
- **R4-Q09 UIX6 route UI states**：保留但小改。它把三层路由、DialogueState、clarify/refusal 映射到可见 UI 状态，能补 C6/demo-golden-run 的可视验收面。
- **R4-Q06 UIX3 visual stance**：改写后保留。价值在于防止无边界视觉重启，但原题的“visual stance”仍偏抽象，必须压成证据门。

## 删除项

- **无直接删除项**。
- 但 **R4-Q06** 如果不能改成“保留/重起/局部调整”的可验收 gate，只剩审美偏好争论，应删除。
- **R4-Q02** 和 **R4-Q03** 不建议原样独立保留；它们更适合合并或改写成已有训练/parity 决策的叶子问题。

## 合并项

- **R4-Q02 TRN8 endpoint parity**：应合并到既有 train/eval/runtime surface parity 主线，保留为“端侧 endpoint acceptance 子题”。它与已确认的同源 parity 问题、以及 C5 endpoint parity 收口高度重叠；独立存在会重复问“parity 怎么验”。保留的新信息是 `mlx-swift 暂无 GBNF`、render byte diff、mounted whitelist、JSON 防御解析、`tool_not_in_whitelist=0`。
- **R4-Q03 TRN9 DoRA/复杂推理升级排期**：应合并到 recipe freeze / G6 复杂推理预留边界。它不该重开 rank/DoRA 配方争论，而应成为“何时允许升级”的触发条件表。
- **R4-Q06 UIX3 visual stance**：可与 UIX1 triage 共用同一 evidence matrix，但不完全合并。UIX1 判 finding 进退，UIX3 判整体视觉路线是否继续。

## 改写建议

- **R4-Q01**：补硬阈值字段：`rows_by_class`、`variants_per_seed`、`estimated_tokens`、`preflight_wall_clock_max`、`peak_memory_max`、`checkpoint_disk_mb`、`fallback_trigger`。否则“可承受”仍可能变成主观判断。
- **R4-Q02**：改成“端侧 endpoint acceptance 是否成立”，不要再泛问 parity。题干应明说：GBNF 只能是 fallback/未证路径，主线验 LoRA 格式、render byte diff、白名单解析层和防御解析。
- **R4-Q03**：从“DoRA 要不要做”改成“升级触发政策”。要求列出 `forbidden_before_g6c_vpass`、`allowed_after_vpass_if`、`rollback_gate`、`macro_vs_lora_reasoning_boundary`。
- **R4-Q04**：要求先定位 30+ findings 的具体源清单，再逐条输出 `finding_id / demo_keep / 10-family_irrelevant / cut / evidence / owner_gate`，避免拿印象做三分。
- **R4-Q05**：要求产物不是视觉描述，而是 `state-cells 10族扩展 + tool-card-map.demo10 + card visual priority`。字段至少覆盖 `value.type`、读回值、亮暗、图标、动效、TTS/readback。
- **R4-Q06**：改成“当前视觉路线是否仍满足 10族 demo 信息架构”。证据门用审美 5 Gate、现场投影/iPhone 查看、三屏分层是否支持 route state 和 10族卡片密度。
- **R4-Q07**：题干再加“缺任一项是否阻断 G6-C / A2 dispatch / demo-golden-run”。验收命令应包括 build、权限、麦克风启动、内存压力、冷启动和基本交互 smoke。
- **R4-Q08**：把每个风险强制三列：`eliminated_by_mac_primary`、`residual_demo_sop`、`preflight_check`。不要只写风险清单。
- **R4-Q09**：要求输出最小状态机矩阵：`route_tier / dialogue_state / visible_state / animation_budget / golden_case`。不要顺手重设计路由层。

## 遗漏风险

- **UIUE 源清单未钉死**：题里说 41维/30+ findings，但应要求引用具体 round/lens 文件和 finding id；否则 UIX1 的矩阵会变成二次摘要再摘要。
- **state-cells 4到10族扩展是隐藏前置**：R4-Q05/R4-Q09 都依赖它，题干应显式要求先判 state-cell 缺口，否则 UI 卡片设计会脱离执行读回。
- **端侧受限解码容易被误写成已可用**：R4-Q02 已提到 `mlx-swift` 限制，但还应防止“训练态 grammar pass”冒充“端侧 constrained decoding V-PASS”。
- **视觉验收场景缺失**：R4-Q06/R4-Q08 没显式要求投影、现场光照、iPhone/Mac 主设备差异下验收，可能让高清截图假绿。
- **UIX7/UIX8/UIX9 未在本轮覆盖**：语音 UI、demo-golden-run 编排、组件采用和真实查看环境验收仍是后续风险，不能被 R4-Q04 的 UIUE triage 吞掉。
- **A2/G2 口径前置仍会污染 UI/训练问题**：10族 intent 数不是工具数、col O 优先级不在仓内 jsonl，这些若未先钉死，会影响 R4-Q01 数据量、R4-Q05 卡片数量和 R4-Q02 白名单范围。

## 评分

| Candidate | Importance | Verifiability | Non-duplication | Mainline decision leverage | Risk revelation | Total /25 | Recommendation |
|---|---:|---:|---:|---:|---:|---:|---|
| R4-Q01 TRN7 mlx-lm feasibility | 5 | 5 | 4 | 5 | 5 | 24 | Keep |
| R4-Q02 TRN8 endpoint parity | 5 | 5 | 2 | 5 | 5 | 22 | Merge + rewrite |
| R4-Q03 TRN9 DoRA/复杂推理升级排期 | 4 | 4 | 3 | 4 | 4 | 19 | Merge + rewrite |
| R4-Q04 UIX1 UIUE triage | 5 | 4 | 5 | 5 | 5 | 24 | Keep |
| R4-Q05 UIX2 10族 mock cards | 5 | 5 | 4 | 5 | 5 | 24 | Keep |
| R4-Q06 UIX3 visual stance | 4 | 3 | 4 | 3 | 3 | 17 | Rewrite |
| R4-Q07 UIX4 engineering preflight | 5 | 5 | 5 | 5 | 5 | 25 | Keep |
| R4-Q08 UIX5 onsite SOP | 5 | 5 | 5 | 4 | 5 | 24 | Keep |
| R4-Q09 UIX6 route UI states | 5 | 5 | 4 | 5 | 4 | 23 | Keep + minor rewrite |

## 理由

- 本轮最高价值问题不是“再讨论训练理念”，而是把已知灾难转成硬门：R4-Q01 验本机训练物理可行性，R4-Q02 验端侧 endpoint 候选不假绿，R4-Q07 验 app 能跑，R4-Q08 验现场不炸。
- R4-Q02 分数被 duplication 拉低，不是因为它不重要，而是因为 train/eval/runtime parity 已经是前几轮和 C5 收口的核心议题。它需要收窄到 `mlx-swift` endpoint 的字节渲染、白名单、解析、decode spike。
- R4-Q03 的正确价值是“冻结升级纪律”，不是鼓励 DoRA 或复杂推理提前进主线。若题干不强制 G6-C 前禁止项和 V-PASS 后触发条件，它会诱发 recipe 重开。
- UI 组里 R4-Q07、R4-Q05、R4-Q04 比 R4-Q06 更硬，因为它们能落成 preflight、state/card mapping、finding matrix。R4-Q06 必须被约束成 evidence-gated visual decision，否则会变成审美争论。
- R4-Q09 是必要连接题：路由正确如果没有可见状态、clarify/refusal/DialogueState 呈现和 golden-run 验收，demo 仍会看起来“没发生什么”。但它要避免扩成 SRD 重设计。

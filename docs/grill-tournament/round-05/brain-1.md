## 保留项

- **R5-Q04**：保留。B1 是 A2/G6-C 前的端侧候选硬门，且问题已经落到 parser enum、whitelist source、unknown tool、`tool_not_in_whitelist=0` 和 endpoint smoke，足够尖。
- **R5-Q06**：保留。F1 把安全门从“模型可选工具”里剥离出来，是安全边界和训练数据边界的核心防混层问题。
- **R5-Q07**：保留但需小改。G6 场景宏是短期 demo 复杂推理的真实逃生口，必须问；但首批宏数量和升级触发条件要更可验。
- **R5-Q08**：保留但需改写成“派单前 gate”。它不是普通 grill 题，而是 Round 01-05 的执行排序收口题；主线杠杆很高。
- **R5-Q09**：保留。最终验收分层能直接防止 train-health、endpoint candidate、golden-run、V/S/U-PASS 互相冒充，是 closeout 必问题。
- **R5-Q01/R5-Q02/R5-Q03**：保留但改写。三题覆盖 UIX7-9 剩余面，方向对；现状都偏“大而全”，要把可验 artifact 和不做项压得更硬。

## 删除项

- 无直接删除项。
- **R5-Q05 不建议作为全新 standalone 新题直接加入**；它与已确认的 Q31“mock cards must be backed by state-cells/tool-card mapping”高度重叠，应合并升级，而不是重复占一个最终名额。

## 合并项

- **R5-Q05 → 合并进 Q31，或用 R5-Q05 替换 Q31 的弱表述**。保留 R5-Q05 的强字段：`tool -> IR -> state_cell -> card -> patch`、10 族 state-cells 扩展、读回验收、防“工具识别对但状态不变”。
- **R5-Q02 与 R5-Q09 只合 evidence boundary，不合题**。R5-Q02 管 golden-run 单步 choreography contract；R5-Q09 管最终验收 ladder 和 closeout wording。二者若合并会太大。
- **R5-Q03 与已确认 Q30/Q32 有重叠，但不应删除**。Q30/Q32 是 UIUE/visual stance 评审，R5-Q03 的独特价值是 component adoption + real-view evidence，应改写成“采用门禁”而非泛泛 UI 审美题。
- **R5-Q08 与 Q12/Q13 有重叠，但建议保留为最终排序题**。Q12/Q13 管 phase reset/change split；R5-Q08 应管“现在 A2 第一刀到底被哪些 blocker 阻断”。

## 改写建议

- **R5-Q01**：把“哪些进 MVP”改成“voice UI MVP contract”。要求输出 `voice_state` 枚举、barge-in/PTT 事件表、ASR/LLM/TTS/interrupt 四段 trace binding、验收截图或录屏样例、明确不做 VAD/always-listening/长时记忆。
- **R5-Q02**：保留 step schema，但加硬字段：每个 `step_id` 必须绑定 `tool_id/state_cell/card_id/c6_case_id/readback_source`，并声明哪些是 golden 100% hard gate、哪些只是 visual cue。
- **R5-Q03**：拆成 adoption gate：license、binary size、runtime perf、offline compatibility、SwiftUI integration、real-view proof。把“高清 mock 图假绿”改成“Mac/iPhone/投影/现场等价证据的最低验收包”。
- **R5-Q04**：补 parser 三层名词，避免“JSON 三层防御”停在口号：raw extraction、schema decode、semantic whitelist/normalizer。要求每层 failure enum 和 fail-closed UI/TTS 行为。
- **R5-Q05**：若独立保留，题干必须承认它是 Q31 的落地版，并要求替代旧 Q31；否则会重复。
- **R5-Q06**：加一句“禁止把 `risk_policy_id` 或安全拒识 action 编成 model-visible executable tool”。同时要求 C6 safety eval 的 denominator 与 unsupported/refusal denominator 分开。
- **R5-Q07**：首批宏不要开放式“哪些宏进首批”，改成候选集评审：上车迎宾、离车收尾、雨天关窗天窗、夜间舒适。要求每个宏有 allowed_tools 与 required_state_cells 校验。
- **R5-Q08**：要求输出三栏：`A2-before blocker`、`A2-parallelizable`、`post-A2 deferred`，并给每项 evidence source 与解除条件。否则容易变成总结性列表。
- **R5-Q09**：加“每层 pass/fail 不能被上层人工通过覆盖”的规则；V/S/U-PASS 应标为人类验收层，不得冒充机器 gate。

## 遗漏风险

- **UIX4 能跑硬前置没有在本轮候选里直接出现**。如果前四轮 Q33 已覆盖就没问题；如果最终 dedupe 时弱化 Q33，本轮 UI 问题会偏视觉而漏掉 microphone entitlement、Info.plist、OOM/jetsam 等“能跑”硬门。
- **B1 仍缺“whitelist authority digest”**。只问 whitelist source 不够，应要求版本、生成命令、digest、demo/full scope，以及 endpoint smoke 绑定同一份白名单。
- **R5-Q03 的组件名混层**。Orb 是 UI，WhisperKit 是 ASR/runtime，hanlin-ai 可能是参考/组件源；题目需要区分 visual component、voice runtime dependency、reference-only asset，避免一锅 adoption。
- **R5-Q08 容易变成“把所有问题都列为 blocker”**。需要定义 blocker 判据：不解除会导致 A2 第一刀返工、假绿、或破坏 SSOT；只是 UI/SOP/训练升级的不得混入。
- **R5-Q09 容易把 V/S/U-PASS 机器化**。V/S/U-PASS 是最终人类验收语义，机器层应止于 train-health、model-quality、endpoint candidate、golden-run evidence。
- **scenario macro 的风险不是“宏太少”，而是宏绕开工具白名单和 state-cell 映射**。R5-Q07 必须把“宏只能调用已挂载工具/已建 state_cell”作为核心问题，而不是附带项。

## 评分

| Candidate | Importance | Verifiability | Non-duplication | Mainline decision leverage | Risk revelation | Total /25 | Recommendation |
|---|---:|---:|---:|---:|---:|---:|---|
| R5-Q01 | 4 | 3 | 4 | 3 | 4 | 18 | Rewrite |
| R5-Q02 | 5 | 5 | 4 | 5 | 4 | 23 | Keep with minor rewrite |
| R5-Q03 | 4 | 4 | 3 | 3 | 5 | 19 | Rewrite |
| R5-Q04 | 5 | 5 | 4 | 5 | 5 | 24 | Keep |
| R5-Q05 | 5 | 5 | 2 | 4 | 5 | 21 | Merge |
| R5-Q06 | 5 | 4 | 4 | 5 | 5 | 23 | Keep |
| R5-Q07 | 4 | 4 | 4 | 4 | 4 | 20 | Keep with rewrite |
| R5-Q08 | 5 | 4 | 3 | 5 | 5 | 22 | Keep with rewrite |
| R5-Q09 | 5 | 5 | 4 | 5 | 5 | 24 | Keep |

## 理由

- **R5-Q01**：质量中上，但现在像 feature shopping list。真正要 grill 的不是“有没有 orb/earcon”，而是 voice state machine 是否绑定 trace、interrupt、clarify 与验收样例，防语音 UI 沦为装饰。
- **R5-Q02**：高质量。它把 demo 炸场从审美话题压成 `step_id -> expected state delta -> readback/TTS -> must-pass` 的合同，能直接服务 golden_demo 和 C6 四层评测。
- **R5-Q03**：风险揭示强，但题面混了审美、性能、授权、依赖和现场验收。要保留“真实查看环境证据”这一刀，砍掉泛泛 adopt 讨论。
- **R5-Q04**：本轮最硬的问题之一。它击中 mlx-swift 暂无已证 GBNF 后的真实端侧策略：模型格式训练、解析防御、白名单 fail-closed 和 endpoint smoke。
- **R5-Q05**：内容非常重要，但重复度高。最佳处理不是删除价值，而是把已确认 Q31 升级为这个更具体的 B2 landing contract。
- **R5-Q06**：安全边界必须单独问。否则 D-domain 具名工具迁移后，容易把安全拒识误做成模型可调用 action，直接违反“安全检查是代码不是 prompt/工具幻觉”的铁律。
- **R5-Q07**：保留是因为复杂推理短期必靠 deterministic macros，但必须 grill 出 schema 和 forbidden condition；否则宏会成为绕过 A2/B1/B2 门禁的新旁路。
- **R5-Q08**：这是从 grill 进入 A2 派单的闸门题。它的价值不在新发现，而在阻止 UI/SOP/训练升级被塞进 A2 codegen 第一刀，导致大爆炸返工。
- **R5-Q09**：高杠杆收口题。MAformac 过去多次把训练健康、候选签发、真机 endpoint、V/S/U-PASS 混写；该题能把 closeout wording 和证据层级固定下来。

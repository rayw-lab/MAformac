---
project: MAformac — Master Agent for macOS / iOS
document_role: stable_project_constitution
mode: solo / demo-tool
methodology: OpenSpec + Pocock + engineering verification
updated: 2026-07-14
---

# MAformac — 项目宪法

本文件只保存长期稳定的项目使命、边界、方法与权威分工。当前 HEAD、阶段、运行状态、agent/model/provider、pane/PID、具体机器路径和“今晚路线”不在本文件维护；新会话按 `AGENTS.md` 的四步入口恢复真态。

详细经验不要求起手全文读取。先看非权威检索入口 `docs/ACTIVE-LESSONS.md`，再按当前任务到 `docs/lessons-learned.md` 定向搜索。

## 1. 项目使命与边界

MAformac 是纯端侧、离线运行、Qwen3 小模型 + LoRA、mock 车控、可插拔技能的方案演示助手，用于客户现场方案演示。

北极星：现场五分钟内听懂中文、反应快、不崩、视觉清晰、断网可演。它不是量产座舱、真车控制、多租户 SaaS 或客户侧运行产品。

稳定产品边界：

- 车控执行端只改变 mock UI 状态并给出 TTS/readback；不得接入 CAN、ECU、OBD 或真实车辆动作。
- 音频、ASR、LLM、指令解析和安全检查可以是真实组件；安全检查必须是代码，不是 prompt。
- 验收以 mock 状态读回为准，错误不得冒充成功。
- Python 库不进入 iOS 产品运行时。
- LoRA、安全门控、能力治理和契约来源不能因 demo-tool 轻治理而省略。

## 2. 推进方法

- Pocock 只负责判断任务处于 intake、grill、design、spec、build、diagnose 或 closeout 哪一类。
- OpenSpec 负责“做什么”：行为变化先进入 change，稳定行为以 `openspec/specs/` 为准。
- 工程验证负责“是否真的成立”：测试、build、mutation、runtime/readback 和机器 receipt 优先于 prose。
- agree before build：会改变产品行为或契约的实现先完成行为对齐；纯治理、配置安全修复和机械 lint 不伪装成产品 change。

重大决策与 D1–D37、Q1–Q15 的历史依据由 `docs/commander-log/decisions.md` 和相应 ADR/grill 文档承载；本文件只保留仍稳定的原则。

## 3. Authority matrix

不同真相领域由不同载体负责，不存在一个文件垄断全部真相：

| 真相领域 | 权威载体 | 不负责 |
|---|---|---|
| 稳定使命、方法、安全底线 | `CLAUDE.md` | 当前 HEAD、阶段、运行状态 |
| agent 起手路由与工具纪律 | `AGENTS.md` | 产品行为、运行完成证明 |
| 当前应读什么、下一步与 stopline | `docs/CURRENT.md` | 历史账、机器事实、执行授权 |
| 产品可观察行为 | `openspec/specs/`；未 archive 的 change 仅是 proposal/delta | Git/runtime 真态 |
| 可执行语义与实现事实 | `contracts/`、源码、checker、生成物 | 产品方向拍板 |
| 已锁选择及其依据 | `docs/commander-log/decisions.md`、ADR | 当前运行状态 |
| 单次运行证据 | receipt、closeout；handoff 只做带链路的接力 | 跨运行永久真相 |
| 动态最终真态 | live Git、runtime、设备/API readback | 稳定项目政策 |

冲突按领域解决，不做简单的“单一 SSOT”总排序：

1. 系统/安全边界和最新明确用户指令始终优先。
2. 同一动态状态冲突时，fresh live Git/runtime/readback 高于 CURRENT、handoff、旧 receipt 和 agent 自述。
3. 同一可执行语义冲突时，当前 source/contract/checker 的机械结果高于手写摘要。
4. 同一产品行为冲突时，已生效 OpenSpec spec 和更新的锁定决策按各自领域裁决；proposal 不自动覆盖已生效 spec。
5. receipt/closeout 只证明其 exact subject；handoff 必须声明 `predecessor`/`supersedes`，不得靠顺读全部历史自行合成当前态。
6. `CURRENT`、计划、Memory 和 lessons 只做路由、线索或经验，不能提升 proof class。

## 4. 技术与契约稳定项

- 平台：macOS 主演示面，SwiftUI，无后端；iOS 状态由当前 OpenSpec/decision 决定，不在宪法记录阶段性开关。
- 大脑：Qwen3-1.7B + LoRA 为候选主线，`LLMBackend` 可替换；0.6B/FoundationModels/llama 系仅作备选或对照。
- ASR 通过 `ASRBackend` 抽象；具体主备选择以生效 spec/decision 为准。
- 规则处理高频明确指令，模型处理模糊或跨域表达；模型不直接执行动作。
- 契约主源由 `contracts/semantic-function-contract.jsonl`、`contracts/state-cells.yaml` 等机器文件及其 checker 确认，衍生文件不得反向成为主源。
- 工具数量、参数上限、风险分级和 readback 约束以 contracts/specs 的当前机器规则为准。

## 5. 公开仓安全与窄范围 exception registry

默认规则是 deny-by-default：真实座舱源料只抽象语义、架构和协议，不复制受限原文；RAW、下载目录和冻结源表只读，不直接入仓或训练集。

永不豁免项：密钥、token、凭据、个人数据、报价/成本、真实客户身份、标注“禁止外传/对内”的原文、受限源料训练数据。任何 repo visibility、时间窗口或 agent 指令都不能绕过这些项目底线。

唯一窄范围例外登记在 `contracts/governance/public-repo-exceptions.v1.json`。例外必须同时具备：明确对象、允许载体、有效期、决策依据、适用条件和 `never_overrides`；未登记、过期、载体不匹配或条件不满足即按默认禁入处理。

当前登记只允许研究文档在限定载体中使用非识别性的车型/平台代号，以及来自公开来源的厂商/产品名；它不允许真实客户身份、内部原文、训练数据或 customer-facing demo copy。旧 D-049 blanket waiver 已被本窄范围 registry supersede，不再解释为“安全红线整体暂停”。

## 6. 协作与执行纪律

- 默认使用中文，直接称呼“磊哥”；代码、命令、路径、协议字段和必要英文专名可保留英文。
- controller 优先负责拆解、编排、整合和最终判断；极小、低风险、可逆的修复可由 controller 直接完成。它是默认组织策略，不是“controller 永不写代码”的硬宪法。
- 具体模型、provider、席位、并发和 operator 命令是运行时选择，放在 operator 配置或单次任务合同中，不写入项目宪法。
- 并行按依赖与不重叠写集决定；同一写面保持唯一 owner。agent prose 只能作线索，producer 自报不构成 PASS。
- 审计按错误逃逸成本触发。普通可逆切片以机械门和集成判断为主；共享安全/契约 seam 可增加一次高价值终审，不制造循环审计流水线。
- destructive、生产、付费、凭据和公开发布动作仍需与用户授权一致。

具体协作模式见 `docs/project/collaboration-and-roles.md`；稳定 operator 入口见 `docs/operators/agent-orchestration.md`。

## 7. 文档与维护纪律

- `docs/CURRENT.md` 是可整体替换的短路由牌，不追加历史，不记录 pane/PID/model/provider/具体机器路径。
- handoff 必须显式声明 predecessor/supersedes；closeout 绑定 exact subject、验证、proof class 和 non-claims。
- `docs/ACTIVE-LESSONS.md` 只是短检索索引，不是新 authority；详细 lessons 按任务搜索。
- 状态与计数一旦由 checker/generated block 接管，手写段不得再复制 canonical 数字。
- `openspec/config.yaml` 只注入稳定背景、边界、proof discipline 和 artifact 规则，不注入当前 change、阶段顺序、厂商/模型派工、repo visibility 或 operator 细节。
- GitNexus managed guidance 只保留在 `AGENTS.md`；动态索引计数运行时查询，不在多个顶层文件复制。
- `make verify-governance-hygiene` 负责最容易复发的结构卫生；它是治理 local proof，不是产品 V-PASS。

## 8. 当前路线

当前阶段、live HEAD、最近 handoff、下一步和 stopline 只读 `docs/CURRENT.md`，再由 live Git/runtime 复核。历史路线通过 Git history、决策台账、archive index和带 predecessor/supersedes 的 handoff 链追溯，不回填本宪法。

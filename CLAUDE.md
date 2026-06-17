---
project: MAformac — Master Agent for macOS / iOS
mode: solo / demo-tool          # 激活 fresheveryday-mode 轻治理（见全局 rules）
methodology: OpenSpec SDD        # 推进管理采用 OpenSpec（已全局适配 ~/.claude + ~/.codex）
status: Phase 0 调研吸收 ✅ 完成 → Phase 1 规格定义 进行中
updated: 2026-06-17
---

# MAformac — 项目宪法

> 项目入口与规矩。新 session 起手**先读本文件 → `docs/README.md` → 最近 `docs/handoffs/`** 即恢复上下文。细节指向 `docs/`,本文件只放"宪法级"约定。

## 1. 这是什么（北极星）

MAformac 是**纯端侧（macOS + iOS）、完全离线、Qwen3 小模型 + LoRA 为大脑、mock 车控、可插拔多技能的「方案演示助手」**——给方案经理在客户现场做销售演示,替代"把样车开过去"。

**北极星 = 客户现场 5 分钟内:听懂中文、反应快、不崩、看着惊艳、断网也能跑。** 不能在断网 Mac/iPhone 上 5 分钟炸场的复杂度,延后或砍掉。**不是**量产座舱 / 真车控制 / 多租户 SaaS / 聊天机器人。

## 2. 推进方法论:OpenSpec SDD（核心,深度采用）

MAformac 用 **OpenSpec** 管理推进(spec-driven development;`/opsx:*` 全局可用)。其方法论是本项目的推进宪法:

**四原则**:`fluid not rigid`(无死阶段门,按需推进)/ `iterative not waterfall`(边做边学,artifact 随时回改)/ `easy not complex`(轻量,最小 ceremony)/ `brownfield-first`(delta 增量,不重述全量)。

**两区分离 — 事实源 vs 提议**(最核心):
- `openspec/specs/` = **唯一事实源(source of truth)**,描述系统**当前行为**(行为契约)。
- `openspec/changes/` = **提议的修改**,每个变更一个自包含文件夹,直到 `archive` 才 merge 进 specs。
- 价值:多 change 并行无冲突 / change 可独立 review / archive 时 delta 干净合入。

**Change = 自包含文件夹**:`proposal.md`(why + scope)、`design.md`(how + 架构决策)、`tasks.md`(实现 checklist,层级编号 + checkbox)、`specs/`(delta specs)。

**Artifact 流 = 依赖图,不是阶段门**:`proposal → specs → design → tasks → implement`。**依赖是"使能"不是"门"**——可跳过 design、可并行、可迭代回改。**Agree before build**:人给意图/约束 → agent 起草 behavior-first spec → 对齐后再写代码。

**Spec = 行为契约**:`### Requirement:`（SHALL/MUST,RFC 2119）+ `#### Scenario:`（GIVEN/WHEN/THEN)。只写可观察行为/输入输出/错误/约束;**不写**类名/库/实现步骤(那些进 design/tasks)。**渐进严格**:Lite 默认(短行为优先);Full 仅高风险/API 契约/迁移用。

**Delta specs**(brownfield 关键):`## ADDED / MODIFIED / REMOVED Requirements`,描述"改什么"而非重述全 spec。

**Archive 良性循环**:change 完成 → delta merge 进 specs → 移 `changes/archive/`（带日期)→ specs 有机生长 → 下个 change 基于更新后的 specs。

**工作流命令**(全局 `/opsx:`):`propose`(起 change)→ `explore`(调研)→ `apply`(实现 tasks)→ `sync`(校准 specs)→ `archive`(归档 + merge)。

### MAformac 阶段路线（方向,非瀑布门）

P0 调研 ✅ → P1 规格 → P2 实现 → P3 打磨。PRD/SRD/ARCH **映射到 OpenSpec artifact**,不另起一套:
| 传统文档 | OpenSpec 对应 | MAformac 落点 |
|---|---|---|
| PRD | 首个项目级 **proposal** | demo 意图 / 受众 / 范围 / 成功标准 |
| SRD | **specs/** + `capabilities.yaml` | 行为契约 = 八大垂域 + 多 domain（事实源)|
| 架构 ARCH | **design.md** | 承接 `tech-baseline §3` + `integration-blueprint`|
| 任务 | **tasks.md** | 实现 checklist |
| 决策 | design 内 Architecture Decisions | 承接已锁 D1–D37 |

> 路线是方向不是死门(守 openspec `fluid`);但守 **agree before build**——动手前 spec 对齐。这调和了"规格先行"与"不僵化":先对齐要做什么,允许 artifact 迭代回改。

## 3. 文档与工作区

| 位置 | 职责 |
|---|---|
| `CLAUDE.md` | 本文件,项目宪法 |
| `docs/README.md` | 文档地图(短入口)|
| `docs/research-archive-*.md` | P0 调研归档 |
| `docs/tech-baseline-from-raw.md` + `-supplement-v0.2.md` | 技术架构基座(→ 喂 design.md)|
| `docs/integration-blueprint.md` | 38 肩膀装配蓝图 + AgentCore 对标 |
| `openspec/specs/` *(init 后)* | **行为契约事实源**(capabilities)|
| `openspec/changes/` *(init 后)* | 进行中的变更(proposal/design/tasks/delta)|
| `docs/handoffs/` *(待建)* | session 交接(收工 ≤ 40 行)|

> `docs/` 放**设计资产**(调研/基座/蓝图,相对稳定);`openspec/` 放**活的推进事实源**(specs + changes,随 archive 生长)。二者互补不重复。

## 4. 技术栈 & 架构（已锁,改动走 openspec change + 入 decisions）

- **平台**:macOS + iOS,SwiftUI 一套,无后端。
- **大脑**:Qwen3-**1.7B** + LoRA 主力(0.6B 备选);`LLMBackend` 协议可换 → 主 `mlx-swift-lm`,备 `llama.swift`/llamafile(Mac 原型)。
- **语音**:WhisperKit(ASR,D14);**文本先行**(开发序,D15),ASR 必交付;barge-in 首版按钮打断(D13)。
- **车控**:全 mock(D16)——**端状态自包含 = UI 卡片亮暗 + TTS 模拟**,无外部系统方喂状态。
- **架构**:7 层(理解→路由→规划→安全→执行 + barge-in 包裹 + DialogueState 贯穿),详见 baseline §3。
- **核心抽象**:`Capability`(本地/MCP 同构)+ 统一 `Tool` schema + **`capabilities.yaml` 单一事实源**(模型/规则/UI/eval/LoRA 数据皆派生)。
- **规则 vs 模型**:规则吃 80% 高频明确,LLM 只碰 20% 模糊/跨域;**LoRA 必做**(只练"模糊说→跨域映射")。
- **多 domain**:P1 车控;导航/音乐/外卖 via MCP 二期。

## 5. 关键已锁决策

D1–D37 全锁,见 `tech-baseline §12 + §12.1` 与 `supplement §17`。铁律:规则吃 80% / 安全检查是代码不是 prompt / 验收以读回 mock 态为准 / 错误用枚举 / 工具 ≤10 参数 ≤5 / Python 库零进 iOS / runtime 抽象先行 / LoRA Day1 埋 trace。

## 6. 边界红线（硬约束,无例外）

源料来自真实座舱项目(某车厂)+ Codex repo 研究。**只抽象语义/架构/协议,绝不复制**:真实客户公司名(一律「某车厂」)、报价/成本/商业条款、密钥/PII、标注「禁止外传/对内」的原文。RAW(`~/workspace/raw/`)与下载目录是**只读参考源,不进 MAformac 仓**,敏感原文不入 git、不入训练集。

## 7. 协作约定（给未来 Claude）

- 称呼「磊哥」;默认中文;术语首现「中文（English）」。
- **solo demo 轻治理**:能取巧的灵活取巧(运行时 mock),但 **LoRA / 安全门控 / 能力治理不省**。
- 选择题给 ⭐ 默认 + 量化,不制造决策疲劳。
- 重型任务先想"派给谁"(GPT Pro / Codex / Hermes / CC);read-heavy fan-out,judgment-heavy 自跑。
- **agree before build**:spec 未对齐不写实现代码。

## 8. 下一步

P1 规格,**用 OpenSpec 启动**:① 在项目根 `openspec init`(建 `openspec/` 工作区,MAformac 正式纳入 openspec 管理)→ ② `/opsx:propose` 起首个 change = **PRD**(demo 演什么/给谁/成功标准/演示脚本骨架)→ ③ 顺 artifact 流 specs(capabilities)→ design(架构)→ tasks。不直接写 capabilities.yaml——它属 specs 阶段,先 proposal 框范围。

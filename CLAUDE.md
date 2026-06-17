---
project: MAformac — Master Agent for macOS / iOS
mode: solo / demo-tool          # 激活 fresheveryday-mode 轻治理（见全局 rules）
methodology: OpenSpec(做什么) + Pocock(哪阶段) + Superpowers(怎么执行)
status: S0 资料堆 ✅ → S1 OpenSpec 建项契约(脑暴 explore 中)
updated: 2026-06-17
---

# MAformac — 项目宪法

> 项目入口与规矩。新 session 起手**先读本文件 → `docs/README.md` → `docs/project/collaboration-and-roles.md` → 最近 `docs/handoffs/`** 即恢复上下文。细节指向 `docs/`,本文件只放"宪法级"约定。

## 1. 这是什么（北极星）

MAformac 是**纯端侧（macOS + iOS）、完全离线、Qwen3 小模型 + LoRA 为大脑、mock 车控、可插拔多技能的「方案演示助手」**——给方案经理在客户现场做销售演示,替代"把样车开过去"。

**北极星 = 客户现场 5 分钟内:听懂中文、反应快、不崩、看着惊艳、断网也能跑。** 不能在断网 Mac/iPhone 上 5 分钟炸场的复杂度,延后或砍掉。**不是**量产座舱 / 真车控制 / 多租户 SaaS / 聊天机器人。

## 2. 推进方法论:OpenSpec + Pocock + Superpowers（核心）

三工具分层(详见 `docs/project/collaboration-and-roles.md §7`):
- **Pocock**(`~/.codex/skills/pocock`)管**现在哪一阶段**:二开路由器,先分诊(S0 intake/S1 grill/S2 design/S3 spec/S4 build/S5 diagnose/S6 close),只推一个主技能,grill-first。
- **OpenSpec** 管**做什么**:变更与行为契约事实源。`/opsx:explore`(脑暴)→ `propose`(proposal/specs/design/tasks)→ `apply`(实现)→ `sync`/`archive`。
- **Superpowers** 管**怎么高质量执行**:brainstorming / writing-plans / TDD / systematic-debugging / verification。

**OpenSpec 核心机制**:`openspec/specs/` = 唯一事实源(行为契约);`openspec/changes/` = 提议(自包含文件夹,archive 才 merge)。Spec 只写可观察行为(Requirement SHALL + Scenario GIVEN/WHEN/THEN),不写实现。Delta(ADDED/MODIFIED/REMOVED)。Artifact 流是依赖图不是死门(可迭代回改),但守 **agree before build**。

### MAformac 默认路线（S0–S6,方向非瀑布门）

`S0 资料堆 ✅ → S1 OpenSpec 建项契约 → S2 capability 样板 → S3 文本 mock 闭环 → S4 模型 benchmark → S5 离线语音闭环 → S6 iOS/macOS 个人演示包`

| 状态 | 目标 | openspec 落点 |
|---|---|---|
| S0 资料堆 ✅ | 调研/基座/蓝图落地 | `docs/` |
| **S1 建项契约**(当前) | demo 做什么/为什么/成功标准/行为契约 | change `define-demo-mvp-contract`(proposal/specs/design/tasks) |
| S2 capability 样板 | 8 条样板防漂移 | `contracts/capabilities.yaml` |
| S3 文本 mock 闭环 | 核心链路可跑 | 文本→意图→ToolCall→DemoGuard→mock state→trace |
| S4 模型 benchmark | 数据拍模型(先 1.7B) | — |
| S5 离线语音闭环 | push-to-talk + ASR + TTS | — |
| S6 个人演示包 | iPhone 可装、断网可演 | — |

PRD/SRD/ARCH **映射到 OpenSpec artifact**(不另起):PRD≈proposal / SRD≈specs+capabilities.yaml / ARCH≈design.md / 任务≈tasks.md / 决策≈design 内 Architecture Decisions(承接 D1–D37)。

> **想清楚先行**(2026-06-17 教训,两次踩坑):起任何 change 前,Pocock 先分诊"要不要先 grill/脑暴";**不跳过 explore 直奔 propose,也不跳过 propose 直奔代码**。

## 3. 文档与工作区

| 位置 | 职责 |
|---|---|
| `CLAUDE.md` | 本文件,项目宪法 |
| `AGENTS.md` | Codex 入口(路由到 CLAUDE.md) |
| `docs/README.md` | 文档地图(短入口) |
| `docs/project/collaboration-and-roles.md` | **协作分工 + 三工具协作(§7)** |
| `docs/research-archive-*.md` / `tech-baseline-*` / `integration-blueprint.md` | P0 调研/基座/蓝图(→ 喂 design.md) |
| `docs/second-review-2026-06-17/` | Codex cross-vendor 二审 |
| `openspec/config.yaml` | 项目上下文 + artifact 硬规则(propose 防漂移) |
| `openspec/specs/` | **行为契约事实源**(capabilities) |
| `openspec/changes/` | 进行中的变更 |
| `contracts/capabilities.yaml` *(S2 建)* | **唯一契约源**(其余 tool_schemas.json 等皆生成物) |
| `docs/handoffs/` *(待建)* | session 交接(收工 ≤ 40 行) |

> `docs/` 放**设计资产**(相对稳定);`openspec/` 放**活的推进事实源**(随 archive 生长)。互补不重复。

## 4. 技术栈 & 架构（已锁,改动走 openspec change + 入 decisions）

- **平台**:macOS + iOS,SwiftUI 一套,无后端。
- **大脑**:Qwen3-**1.7B + LoRA = 候选主线**(先 1.7B 推进,**不前置 benchmark**;0.6B 为轻量 fallback;FoundationModels 仅 baseline/逃生口)。`LLMBackend` 协议可换 → 主 `mlx-swift-lm`,备 `llama.swift`/llamafile。
- **语音**:WhisperKit(ASR,D14);**文本先行**(开发序,D15)、ASR 必交付;barge-in 首版按钮打断(D13)。
- **车控**:全 mock(D16)——**端状态自包含 = UI 卡片亮暗 + TTS 模拟**,无外部系统方。
- **架构**:7 层(理解→路由→规划→安全→执行 + barge-in 包裹 + DialogueState 贯穿),详见 baseline §3。
- **核心抽象**:`Capability`(本地/MCP 同构)+ 统一 `Tool` schema + **`contracts/capabilities.yaml` 单一事实源**(模型/规则/UI/eval/LoRA 数据皆派生)。
- **规则 vs 模型**:规则吃 80% 高频明确,LLM 只碰 20% 模糊/跨域;**LoRA 必做**(只练"模糊说→跨域映射")。
- **多 domain**:P1 车控;导航/音乐/外卖 via MCP 二期。

## 5. 关键已锁决策

D1–D37 全锁(D20/D30/D35/D37 已于 2026-06-17 对话拍板),见 `tech-baseline §12 + §12.1` 与 `supplement §17`。铁律:规则吃 80% / 安全检查是代码不是 prompt / 验收以读回 mock 态为准 / 错误用枚举 / 工具 ≤10 参数 ≤5 / Python 库零进 iOS / runtime 抽象先行 / LoRA Day1 埋 trace。

## 6. 边界红线（硬约束,无例外）

源料来自真实座舱项目(某车厂)+ repo 研究。**只抽象语义/架构/协议,绝不复制**:真实客户公司名(一律「某车厂」)、报价/成本、密钥/PII、标注「禁止外传/对内」的原文。RAW(`~/workspace/raw/`)与下载目录是**只读参考源,不进 MAformac 仓、不上 GitHub(即便 private)、不入训练集**。仓已上云 `rayw-lab/MAformac`(private),边界更要守。

## 7. 协作约定（给未来 Claude）

- 称呼「磊哥」;默认中文;术语首现「中文（English）」。
- 分工:磊哥拍板;Claude+GPT Pro 陪聊定 what;**Claude 管前端+原型**;Codex 代码长跑(20h,TDD);GPT Pro 云端审 PR。详见 collaboration-and-roles.md。
- **solo demo 轻治理**:能取巧的运行时灵活取巧,但 **LoRA / 安全门控 / 能力治理不省**。
- 选择题给 ⭐ 默认 + 量化,不制造决策疲劳。
- **agree before build**:spec 未对齐不写实现代码;**想清楚未做不起 propose**。

## 8. 维护纪律（经常回忆更新）

本宪法 + `collaboration-and-roles.md` + 默认路线 + decisions + `openspec/config.yaml` 是**活文档**:
- 重大决策/路线调整/协作方式变化 → **立即回写**对应文件。
- 新 session 起手回忆;阶段推进(S→S)时复核路线与 decisions 是否仍成立。
- 三工具协作的实际命中与盲点 → 回写 collaboration §7。

## 9. 下一步:S1 建项契约（脑暴先行)

Pocock 分诊结论 = **S1 grill / explore**(产品·演示层未锁)。顺序:
1. **脑暴**(当前):`superpowers:brainstorming` + `openspec-explore` + pocock grill-first → 把产品·演示层想透(客户 / 演示叙事 / 炸场点 / 成功标准 / 兜底)。
2. 想清楚 → `/opsx:propose define-demo-mvp-contract` 起首个 change(proposal 含 Non-goals + 成功标准 / specs 行为契约 / design 主链路 / tasks 给 Codex)。
3. 顺 artifact 流 → S2 `contracts/capabilities.yaml` 8 条样板。

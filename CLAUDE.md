---
project: MAformac — Master Agent for macOS / iOS
mode: solo / demo-tool          # 激活 fresheveryday-mode 轻治理（见全局 rules）
methodology: OpenSpec(做什么) + Pocock(哪阶段) + Superpowers(怎么执行)
status: 契约 SSOT 重构(define-c1c2-contract C1+C2 propose done,待 GPT Pro 审 + 拍 open question);路线 v2(旧 7-change 已物理 park)
updated: 2026-06-19
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

### MAformac 默认路线（v2,2026-06-19 全量重构;方向非瀑布门）

旧 8 能力扁平契约 + 二分路由被基座内化推翻 → 新路线以**契约 SSOT 为根**(C1 全集语义契约 + C2 场景端态),后续执行/路由/LoRA/bench/voice 在其上 rebase。

| 状态 | 目标 | openspec 落点 |
|---|---|---|
| S0 资料堆 ✅ | 调研/基座/4 金钥匙内化 | `docs/` |
| S1 建项契约 ✅ | demo 做什么/成功标准/行为契约(骨架) | `define-demo-mvp-contract`(archive) |
| **S2 契约 SSOT 重构**(当前) | 全集语义契约 + 场景端态(推翻扁平 8 能力) | **`define-c1c2-contract`(C1 semantic-function-contract + C2 scenario-state-protocol)** |
| S3 执行契约层 + 文本 mock 闭环 | 核心链路可跑 | C3(文本→意图→ToolCall→DemoGuard→mock state→trace) |
| S4 三层路由 + 意图收缩 + LoRA 全量 | 语义广听懂 + 分层兜底 | C4 + C5 |
| S5 bench 不丢脸基线 + 离线语音 | 全集覆盖死门 + push-to-talk | C6 + C7 |
| S6 个人演示包 | iPhone 可装、断网可演 | — |

PRD/SRD/ARCH **映射到 OpenSpec artifact**(不另起):PRD≈proposal / SRD≈specs+contracts / ARCH≈design.md / 任务≈tasks.md / 决策≈design 内 Architecture Decisions(承接 D1–D37 + Q1–Q15)。

> **想清楚先行**(2026-06-17/19 教训):起任何 change 前先 brainstorm/grill;**不跳过 explore 直奔 propose,也不跳过 propose 直奔代码**。C1/C2 经 Q1–Q15 脑暴(CC↔codex,2 轮 oracle)定稿。

## 3. 文档与工作区

| 位置 | 职责 |
|---|---|
| `CLAUDE.md` | 本文件,项目宪法 |
| `AGENTS.md` | Codex 入口(路由到 CLAUDE.md) |
| `docs/README.md` | 文档地图(短入口) |
| `docs/project/collaboration-and-roles.md` | **协作分工 + 三工具协作(§7)** |
| `docs/c1-q1-q10-claude-oracle-grill-2026-06-19.md` + `docs/adr/0001-*` + `CONTEXT.md` | **C1/C2 决策全料**(Q1–Q15 + oracle + 领域语言) |
| `docs/research-archive-*.md` / `tech-baseline-*` / `integration-blueprint.md` | P0 调研/基座/蓝图(部分被 v2 supersede,见各文件标注) |
| `openspec/config.yaml` | 项目上下文 + artifact 硬规则(propose 防漂移,已 v2) |
| `openspec/specs/` | **行为契约事实源**(capabilities) |
| `openspec/changes/` | 进行中变更;`_parked/` = 旧 7-change 暂缓(见其 README) |
| `contracts/semantic-function-contract.jsonl` *(C1 建)* | **唯一契约源**(源行级全集;`function-spec-full.yaml`/规则/LoRA/bench 皆生成物) |
| `docs/handoffs/` | session 交接(收工 ≤ 40 行) |

> `docs/` 放**设计资产**(相对稳定);`openspec/` 放**活的推进事实源**(随 archive 生长)。互补不重复。

## 4. 技术栈 & 架构（已锁,改动走 openspec change + 入 decisions）

- **平台**:macOS + iOS,SwiftUI 一套,无后端。
- **大脑**:Qwen3-**1.7B + LoRA = 候选主线**(先 1.7B 推进,**不前置 benchmark**;0.6B 为轻量 fallback;FoundationModels 仅 baseline/逃生口)。`LLMBackend` 协议可换 → 主 `mlx-swift-lm`,备 `llama.swift`/llamafile。
- **语音**:WhisperKit(ASR,D14);**文本先行**(开发序,D15)、ASR 必交付;barge-in 首版按钮打断(D13)。
- **车控**:全 mock(D16)——**端状态自包含 = UI 卡片亮暗 + TTS 模拟**,无外部系统方。
- **架构**:理解→**三层路由(规则 NLU / 意图收缩 clarifyTag→FC 泛化 / 慢思考)**→规划→安全门→**分层执行兜底(L1 精做 / L2 通用 mock / L3 越界 / L4 安全)**+ barge-in 包裹 + DialogueState 贯穿。
- **核心抽象**:`Capability` + 统一 `Tool` schema + **契约 SSOT = `semantic-function-contract`(C1,源行级全集)+ `scenario-state-protocol`(C2,场景端态)**(模型/规则/UI/eval/LoRA 数据皆派生;`value` 四件套 + device×动作原语×槽三元 + clarifyTag)。
- **规则 vs 模型**:规则吃 80% 高频明确,LLM 只碰 20% 模糊/跨域;**LoRA 全量必做**(练"模糊说→跨域映射",加权采样非笛卡尔积)。
- **不丢脸**:客户随意说全集 → 语义广听懂(LoRA)+ mock 分层兜底(L1 ~10 精做 / L2 广覆盖),不只 8 个窄 case。
- **多 domain**:P1 车控;导航/音乐/外卖 via MCP 二期。

## 5. 关键已锁决策

D1–D37 + **Q1–Q15**(C1/C2 契约,见 grill/ADR)。铁律:规则吃 80% / 安全检查是代码不是 prompt / 验收以读回 mock 态为准 / 错误用枚举 / 工具 ≤10 参数 ≤5 / Python 库零进 iOS / runtime 抽象先行 / LoRA Day1 埋 trace。

**v2 重审(2026-06-19)**:D16 端态 8→102 原子能力 P0 子集(C2)/ D30 训练栈 adopt unsloth+Hammer+xLAM(C5)/ D35 must-pass→全集覆盖率双轴 bench(C6)/ D37 安全门→risk-policy 单源(R0–R3 收 ASIL/forbidden)+ clarifyTag。**范围真值纠错**(端态打点为准,旧 16-30/0-5 是拍错):空调温度 **18-32℃**(车型相关)、风量 **1-10 档**、座椅 0-3、车窗 0-100%。**契约 SSOT 全集精确靠 codegen 从冻结快照派生(非手写)+ 分流账本(unclassified=0,quarantine≠drop)**。

## 6. 边界红线（硬约束,无例外）

源料来自真实座舱项目(某车厂)+ repo 研究。**只抽象语义/架构/协议,不复制原文语料**。**分级脱敏(2026-06-19 磊哥校准,private 内网放宽车型代号)**:
- 🔴 **绝不入仓(无例外)**:密钥/PII、报价/成本、真实人名、标注「禁外传/对内」的原文语料。
- 🟡 **private 仓/内网可接受**:车型代号(AH8/T19/E0Y 等)、供应商名 —— 仓 `rayw-lab/MAformac` 是 private + 自己人内网用,这类非密钥/PII 的代号可入仓(作 source 标记/blocklist 等);但 **绝不进训练集、不上公开仓**。客户公司名正文仍统一「某车厂」。
- **原始中文语料**(协议表/bug 真实说法)= 本机只读 + 脱敏,**不入仓**(仅 LoRA 权重产物入仓)。
RAW(`~/workspace/raw/`)+ 下载目录 + 源 xlsx 冻结快照 = **只读参考源**,仓内只放 manifest(hash)+ JSONL 镜像 + 派生物。仓已上云 `rayw-lab/MAformac`(private)。

## 7. 协作约定（给未来 Claude）

- 称呼「磊哥」;默认中文;术语首现「中文（English）」。**选择题打字列选项 + ⭐默认,不用 AskUserQuestion 弹窗**(磊哥环境看不到弹窗)。
- 分工:磊哥拍板;Claude+codex 脑暴定 what(CC↔codex grill);**Claude 管前端+原型 + 契约设计**;Codex 代码长跑(TDD)+ 脑暴对手;GPT Pro 云端审 PR/设计。详见 collaboration-and-roles.md。
- **solo demo 轻治理**:能取巧的运行时灵活取巧,但 **LoRA / 安全门控 / 能力治理 / 契约 SSOT 不省**。
- 选择题给 ⭐ 默认 + 量化,不制造决策疲劳。
- **agree before build**:spec 未对齐不写实现代码;**想清楚未做不起 propose**;**重大设计先讨论别急执行**(2026-06-19 教训,见 memory)。

## 8. 维护纪律（经常回忆更新）

本宪法 + `collaboration-and-roles.md` + 默认路线 + decisions + `openspec/config.yaml` 是**活文档**:
- 重大决策/路线调整/协作方式变化 → **立即回写**对应文件(基建文档级联,相关都更新)。
- 新 session 起手回忆;阶段推进(S→S)时复核路线与 decisions 是否仍成立。
- 三工具协作的实际命中与盲点 → 回写 collaboration §7。

## 9. 下一步:C1/C2 契约 SSOT(propose done → 审 → apply)

**路线 v2**(旧 7-change 已 park → `openspec/changes/_parked/`,见其 README 复用度):

- ✅ `define-demo-mvp-contract`(archive,骨架)
- ⚠️ `define-capability-contract`(archive,扁平 8 能力)→ 被 C1 supersede
- **`define-c1c2-contract`(当前,propose done,一个 change 两个 capability spec):**
  - **C1 `semantic-function-contract`**:源行级 JSONL 全集(`airControl/carControl/cmd`,source_rows≈3990,codegen 从冻结快照派生)+ value 四件套 + device×原语×槽三元 + clarifyTag + followup sidecar + risk-policy + l1-allowlist + 冻结快照 manifest(双 hash)+ 分流账本 + `make verify` 本地门
  - **C2 `scenario-state-protocol`**:demo 场景端态(L1_device ∪ scenario_required ∪ safety)+ execution_range 权威 + demo scenarios + 脱敏参考映射(非量产复刻)
  - 接口互锁写 design.md 共享段;archive 同波(避双向循环)
- **C3–C7(parked,C1/C2 archive 后 rebase)**:C3 执行契约层(←execution 骨架可复用 46340f1)/ C4 三层路由+意图收缩(←intent-routing 重写)/ C5 LoRA 全量(←lora 重写)/ C6 vehicle-tool-bench(←bench 重写)/ C7 voice(←voice 高可复用)

**当前断点**:C1/C2 propose done → **提 PR + GPT Pro 云端审契约设计**(含 2 open question:C2 端态一手源 / L1 allowlist ~10 名单待磊哥拍)→ 审回 + 拍 open question → `/opsx:apply` 进 build(甲-混:纵切 空调温度+车窗 验全栈再横铺)。

起手读:本文件 → 最近 `docs/handoffs/` → `docs/c1-q1-q10-claude-oracle-grill-2026-06-19.md` + `docs/adr/0001-*` + `CONTEXT.md`(C1/C2 全料)→ `docs/cockpit-voice-fc-premortem-2026-06-18.md`(座舱原理 + demo 边界)。

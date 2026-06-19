# MAformac 技术架构基座 — 文档地图

> **MA = Master Agent**(MAformac = Master Agent for macOS/iOS)。
> **北极星**:方案经理给客户演示用,客户现场 5 分钟内——听懂中文、反应快、不崩、看着惊艳、断网也能跑。
> **形态**:纯端侧(iOS/macOS)、离线、Qwen3-1.7B + LoRA 大脑(0.6B 仅作真机吃紧时的轻量备选)、mock 车控、可插拔多技能(Phase1 车控 → 导航/音乐/外卖 via MCP)。

> ⚠️ **路线 v2(2026-06-19 全量重构,以此为准)**:旧 8 能力扁平契约 + 二分路由被基座内化推翻 → 契约 SSOT 重构 **`define-c1c2-contract`**(C1 `semantic-function-contract` + C2 `scenario-state-protocol`,propose done)。旧 7-change 已物理 park(`openspec/changes/_parked/`)。**路线/架构/决策以 `CLAUDE.md §9` + `docs/c1-q1-q10-claude-oracle-grill-2026-06-19.md` + `docs/adr/0001-generated-full-contract-with-mixed-delivery.md` + `CONTEXT.md` 为准**;本文以下「Decisions 待拍 / 下一步候选 ABC / 基座内化"进行中"」段为 **v1 历史快照,已 supersede**(保留作记录,不再据其执行)。范围真值纠错:空调温度 **18-32℃** / 风量 **1-10 档**(旧 16-30/0-5 是拍错)。

## 文档清单(按阅读顺序)

| 文档 | 内容 | 行数 |
|---|---|---|
| `research-archive-2026-06-17.md` | 调研归档:GitHub repo 调研×3 轮 + 8 周路线图(七节)+ 多 domain 基座架构 + 实时交互三能力(barge-in/快慢/记忆)调研 | ~370 |
| `tech-baseline-from-raw.md` (v0.1, §1–§12) | **主基座**:项目定义/降维映射/7 层架构/Capability+Tool schema/八大垂域+多domain功能清单/FC语义四级/快慢路由+三态推荐/DialogueState/barge-in/repo映射/eval+话术+badcase/decisions D1–D18 + §12.1 磊哥裁决 | 470 |
| `tech-baseline-supplement-v0.2.md` (§13–§17) | **补充**:多阶规划层/中枢调度+Agentic-Skill分工/LoRA 工程化闭环⭐/安全门控+必过集/decisions D19–D37 | 405 |
| `integration-blueprint.md` (§0–§10) | **装配蓝图**:38 肩膀三类分法(进app/开发期/抄思路)+ 模型尺寸(1.7B 主力)+ 7层×repo 装配图 + 端到端数据流 + 骨架目录 + 第一刀 + 对标 AWS AgentCore + 读全报告补漏 | ~230 |
| `voice-pipeline-from-raw.md` | **语音链路专题**(from raw):中文车控热词(promptTokens)+ SpeechTextNormalizer + 8 态机 + 800ms 延迟预算;**顶部有拍板对齐段** | ~350 |
| `qwen3-engineering-notes.md` | **Qwen3 工程专题**:「能 tool call」是表层信号 + 4 隐藏层 + 10 条教训 + 外网/38repo + **change 3-6 硬约束** | ~130 |

## 🔑 基座语义协议内化(2026-06-19,当前主线 · 索引)

> 4 张某车厂金钥匙表(`~/Downloads/`:公版语义四级协议-编辑版 / 车控功能打点表 / 上下文二次交互功能清单 / 多语种展开V1,**只读不进仓**)深度消化 → MAformac 自有语义协议。**这是 LoRA 语料 + 功能清单 + E2E 基线的根。**

| 文档 | 内容 | 用途 |
|---|---|---|
| `baseline-semantic-protocol-2026-06-19.md` | 基座消化:范式 7 要素(value 四件套 ref/direct/offset/type、归一化动作编码 ~114、二次交互矩阵、FC 分流标记)+ `capabilities.yaml` 逐项错对照 + 内化方案 | **语义协议范式权威** |
| `maformac-function-spec-2026-06-19.md` | MAformac 功能清单 v0 + **§5 不丢脸架构**(L1 精做 / L2 通用 mock 兜底 / L3 越界 / L4 安全门 + LoRA 核心) | **功能清单 + 执行分层** |
| `demo-must-pass-candidate-2026-06-19.md` | must-pass 必过集 candidate(扁平契约版,**待基于基座重做**) | E2E/验收(待重做) |
| `baseline-internalization-plan-2026-06-19.md` ⭐ | **总方案**:业内怎么处理巨型表(scout 某车厂 FC 手册:意图收缩+三层路由+分层兜底+安全分级)+ oracle prior art(Hammer/xLAM/unsloth/vLLM-router/typia/outlines/xgrammar/MAC-SLU)+ 6 产物内化方案 + **实施 Roadmap P0-5** + **冻结决策整改清单** + Pre-Mortem 三分类 | **方案+roadmap+整改** |
| `handoffs/2026-06-19-baseline-internalization.md` | 本波 handoff:重大认知 + 下一步 + 工件位置 | session 交接 |
| `~/workspace/raw/00-Inbox/maformac-baseline-digest/` *(raw,不进仓)* | 基座 digest 工件 + 解析脚本(carControl 398 设备/975 intent + airControl 16/51 + cmd 257/512 全景);`python3 parse_devices.py` 可重建 | 全集解析工件 |

> **核心认知**:客户随意说 2655+(甚至超出)→ 语义广听懂(LoRA 的核心价值)+ mock 执行分层兜底 = 不丢脸;功能清单 = **全集语义协议**(非 8 个窄 case)。
> **进行中**:`/pre-mortem` 调研"业内怎么处理巨型协议表"(scout raw 一手做法 + oracle 业内 prior art)→ 待产出 **方案建议 + 实施 roadmap + 冻结决策整改清单**(codex 执行,CC 思考)。

## Decisions 状态总览(D1–D37)

- 🔒 **已锁定(33)**:D1–D11(工程铁律)、D12–D18(磊哥 2026-06-17 裁决,见 v0.1 §12.1)、D19/D21–D29(部分)/D31–D34/D36
- 🟡 **待磊哥拍(4)**:
  - **D20** 端侧多阶上限 → ⭐ ≤2 阶
  - **D30** 训练栈 → ⭐ MLX-LM LoRA + Q4
  - **D35** demo 必过集规模 → ⭐ 15–25 条精选
  - **D37** demo 保留几个安全门 → ⭐ 全 8 项(五门可视化是卖点)

## 关键已锁主线(speed-read)

- 主线模型 = Qwen3-1.7B + LoRA(0.6B 仅作轻量备选;FoundationModels 因不可微调出局,留逃生口)
- 规则吃 80% 高频车控,LLM 只碰 20% 模糊/跨域;**LoRA 必做**,只练「模糊说→跨域映射」
- 端状态**自包含** = UI 卡片亮暗 + TTS 模拟(无外部系统方);执行=改卡片态+播报
- 文本先行(开发顺序)+ ASR(WhisperKit)必交付;barge-in 首版按钮打断,VAD 二期
- 安全/记忆/barge-in 是 38-repo 盲区,需自建

## 边界声明

全部抽象自真实座舱项目资料 + 38 参考 repo。**全文「某车厂」,无真实客户名/报价/密钥/PII/对内禁外传原文。**

## 下一步候选(待磊哥定方向)

- **A) 敲核心契约** ⭐:`tools.json`(八大垂域)+ `DialogueState` schema + `Capability/Tool` 协议落成实际文件——是骨架与 spike 的输入,护城河
- B) 出项目骨架:SwiftUI + AgentCore 目录结构 + 空协议文件
- C) Mac 原型 spike:mlx_lm.server + Qwen3-1.7B 出第一个结构化工具调用,验证链路;llama-server/GGUF 只作 grammar 对照

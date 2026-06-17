# MAformac 技术架构基座 — 文档地图

> **MA = Master Agent**(MAformac = Master Agent for macOS/iOS)。
> **北极星**:方案经理给客户演示用,客户现场 5 分钟内——听懂中文、反应快、不崩、看着惊艳、断网也能跑。
> **形态**:纯端侧(iOS/macOS)、离线、Qwen3-0.6B + LoRA 大脑、mock 车控、可插拔多技能(Phase1 车控 → 导航/音乐/外卖 via MCP)。

## 文档清单(按阅读顺序)

| 文档 | 内容 | 行数 |
|---|---|---|
| `research-archive-2026-06-17.md` | 调研归档:GitHub repo 调研×3 轮 + 8 周路线图(七节)+ 多 domain 基座架构 + 实时交互三能力(barge-in/快慢/记忆)调研 | ~370 |
| `tech-baseline-from-raw.md` (v0.1, §1–§12) | **主基座**:项目定义/降维映射/7 层架构/Capability+Tool schema/八大垂域+多domain功能清单/FC语义四级/快慢路由+三态推荐/DialogueState/barge-in/repo映射/eval+话术+badcase/decisions D1–D18 + §12.1 磊哥裁决 | 470 |
| `tech-baseline-supplement-v0.2.md` (§13–§17) | **补充**:多阶规划层/中枢调度+Agentic-Skill分工/LoRA 工程化闭环⭐/安全门控+必过集/decisions D19–D37 | 405 |
| `integration-blueprint.md` (§0–§10) | **装配蓝图**:38 肩膀三类分法(进app/开发期/抄思路)+ 模型尺寸(1.7B 主力)+ 7层×repo 装配图 + 端到端数据流 + 骨架目录 + 第一刀 + 对标 AWS AgentCore + 读全报告补漏 | ~230 |

## Decisions 状态总览(D1–D37)

- 🔒 **已锁定(33)**:D1–D11(工程铁律)、D12–D18(磊哥 2026-06-17 裁决,见 v0.1 §12.1)、D19/D21–D29(部分)/D31–D34/D36
- 🟡 **待磊哥拍(4)**:
  - **D20** 端侧多阶上限 → ⭐ ≤2 阶
  - **D30** 训练栈 → ⭐ MLX-LM LoRA + Q4
  - **D35** demo 必过集规模 → ⭐ 15–25 条精选
  - **D37** demo 保留几个安全门 → ⭐ 全 8 项(五门可视化是卖点)

## 关键已锁主线(speed-read)

- 主线模型 = Qwen3-0.6B + LoRA(FoundationModels 因不可微调出局,留逃生口)
- 规则吃 80% 高频车控,LLM 只碰 20% 模糊/跨域;**LoRA 必做**,只练「模糊说→跨域映射」
- 端状态**自包含** = UI 卡片亮暗 + TTS 模拟(无外部系统方);执行=改卡片态+播报
- 文本先行(开发顺序)+ ASR(WhisperKit)必交付;barge-in 首版按钮打断,VAD 二期
- 安全/记忆/barge-in 是 38-repo 盲区,需自建

## 边界声明

全部抽象自真实座舱项目资料 + 38 参考 repo。**全文「某车厂」,无真实客户名/报价/密钥/PII/对内禁外传原文。**

## 下一步候选(待磊哥定方向)

- **A) 敲核心契约** ⭐:`tools.json`(八大垂域)+ `DialogueState` schema + `Capability/Tool` 协议落成实际文件——是骨架与 spike 的输入,护城河
- B) 出项目骨架:SwiftUI + AgentCore 目录结构 + 空协议文件
- C) Mac 原型 spike:llama-server + Qwen3-0.6B 出第一个结构化 JSON,验证链路

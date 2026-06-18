## Why

方案经理向车厂 OEM 客户演示「端侧座舱 AI 能力」时,过去需把样车开到客户现场——成本高、受环境限制、难以随时展示。MAformac 用一台 iPhone(+ Mac 镜像投屏)替代样车:纯端侧、完全离线的车控演示助手,客户现场 5 分钟内听懂中文、反应快、不崩、看着惊艳、**断网也能跑**。对外包装为「公司内部研发中的端侧产品」,给客户新鲜感 + 踏实感,同时是方案经理 AI 提效的标杆绩效。

差异化锚点:纯端侧离线(竞品端云协同断网即失效)+ iOS 精致 UI + Qwen3-1.7B(话术「内部 4B/7B 更强」,有真实端侧战略背书)+ 真实座舱 bug 数据(本地脱敏后)训练的 LoRA 护栏。

## What Changes

建立 MAformac 演示 MVP 的**顶层行为契约**(6-change 拆法的第一个,定方向;后续 5 个 change 在此之上展开):

- 锁定**受众与场景**:车厂决策者会议室 + 个人绩效;方案经理控场、客户纯观众(可上手,话术兜底)。
- 锁定 **MVP 范围 = 车控 + ASR + TTS + LoRA**(全做,非后置)。
- 锁定 **5 幕演示叙事**(痛点钩子 → 基础控制 → 懂人话 → 断网高潮 → 场景炫 + 收尾)为 must-pass 路径。
- 锁定**演示语境**:车控全 mock(端状态自包含 = UI 卡片亮暗 + TTS 模拟),非真车控制。
- 锁定**成功标准 / Non-goals / 边界红线**(见下)。

## Capabilities

### New Capabilities
- `demo-experience`: MAformac 演示体验的整体可观察行为契约——MVP 范围、5 幕演示路径 must-pass、断网可演、错误不冒充成功(读回 mock 态才算成功)、纯观众演示模式 + 话术兜底。

### Modified Capabilities
(无——MAformac 为 greenfield,`openspec/specs/` 当前为空)

## Non-goals

显式不做:
- ❌ 真车控制 / CAN·ECU·OBD / 量产座舱 / 客户侧运行产品。
- ❌ 导航 / 音乐 / 外卖的**真 MCP 接入**(二期;Phase1 仅 `connector: mock` + `enabled: false` 占位,不假装可用、文案不称「已支持 MCP」)。
- ❌ TTS 高拟人大模型(MVP 用 `AVSpeechSynthesizer`;CosyVoice / TTSKit 二期)。
- ❌ 多租户 / 云依赖 / 账号认证 / 支付 / RAG 知识库。
- ❌ VAD 自动端点(MVP push-to-talk;VAD/KWS 接口预留、Phase2 接入)。
- ❌ 模型降级:Qwen3-1.7B + LoRA 为主线;0.6B / FoundationModels / llama.cpp 仅作备选 / 对照,不作默认。

## Success Criteria(可验收)

- **演示必过集**:15–25 条精选车控指令(覆盖 5 幕话术)**断网全过 100%**(demo must-pass)。
- **延迟**:快路径(明确指令 / 单 FC)端到端 ≤ 800ms;慢路径(模糊 / 多意图)≤ 2500ms。计时从「松手」到「TTS 首响 + UI 亮」(不含说话时长)。
- **状态可见**:每条指令执行后 UI 卡片状态变化肉眼可见;视觉先于 TTS。
- **错误不冒充成功**:`pending / failed / unknown` 不得播报「已完成」;验收以**读回 mock 态**为准;`readback mismatch = 0`。
- **安全**:`Unsafe false pass = 0`(危险动作不得误执行)。
- **断网**:Phase1 全程飞行模式可演(二期联网域不属于本 change)。

## Post-demo Success Signal(商业信号,非自动化验收)

- 客户「哇」或主动追问「能接我们车型吗」(进入合作话题)。**真实商业信号,但不可自动化验收**,不与上方 `readback mismatch=0` 等硬门同层。

## Impact

- 新建 MAformac SwiftUI 工程(iOS + macOS,无后端)。
- 后续 5 个 change 依赖此顶层契约:`define-capability-contract` / `define-execution-contract` / `define-voice-contract` / `define-lora-pipeline` / `define-vehicle-tool-bench`。
- 前置环境:完整 Xcode + Apple Developer 签名(真机演示);本机 M5 / Swift 6.3 / referencerepo Swift 依赖已就绪。
- 数据 / 边界:真实座舱 bug 原文 / RAW 绝不入仓 / 上云 / 进训练集;**本地脱敏抽象后的五件套可用于本机 LoRA 训练,训练集本身不入仓,仅 LoRA 权重产物可入仓**;`contracts/capabilities.yaml` 为唯一契约源。

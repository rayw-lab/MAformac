## Context

MAformac 是 greenfield 纯端侧(iOS + macOS,SwiftUI,无后端)车控演示助手。架构基座来自 38 个参考 repo 调研 + `docs/tech-baseline-from-raw.md`(7 层架构)+ `docs/integration-blueprint.md`(装配图)+ `docs/voice-pipeline-from-raw.md`(语音链路)。

约束:断网可演、快路径 ≤800ms / 慢路径 ≤2500ms、目标硬件 M5 Mac + iPhone 15 级(算力远超车规 8155 给语音的 ~6K DMIPS)、不降级(Qwen3-1.7B + LoRA 主线)、真实座舱数据仅本地脱敏不入仓。

stakeholders:方案经理(演示者 + 拍板)、车厂客户(观众)、Codex(实装长跑)、Claude(架构 + 前端 + 审计)。

## Goals / Non-Goals

**Goals:**
- 端侧离线车控主链路:语音/文本 → 意图 → ToolCall → 安全门 → mock 执行 → readback → UI + TTS。
- 安全门控为代码、mock 状态单一事实源、trace 五段贯穿。
- 7 层架构 + 6-change 子系统边界清晰,Codex 可独立接活。

**Non-Goals:**
- (同 proposal)真车控 / 真 MCP / 高拟人 TTS / 多租户云 / VAD 自动端点 / 模型降级。
- 本 change 不锁子系统实现细节(留各自 change 的 design)。

## Decisions

### 主链路(强制明确)

```
语音 / 文本
 → SpeechRecognizer(WhisperKit;push-to-talk + 录音期流式预转,松手出最终文本)
 → SpeechTextNormalizer(raw_text / normalized_text / rewrite_rules / confidence_delta;此后做置信拦截)
 → IntentEngine(FastPath 规则吃 80% 高频明确 / LLMBackend 碰 20% 模糊跨域)
 → Router(落 agent + capability + surface_policy)  // MasterShell 仅渲染
 → ToolCallDecoder(Qwen3 原生工具调用格式 → 内部 ToolCallFrame;Codable 严格解码 + retry≤1 + decode_failed 转澄清)
 → ThreeStateEngine(已满足 / 未满足 / 无法满足,纯函数)+ ActionPlanner(多意图 / 补槽)
 → DemoGuard(代码门:unknown tool / schema / 范围枚举 / writable / 风险等级 / 确认策略 / 互斥 bus / 前置条件)
 → DemoActionExecutor.applyMockTransition(唯一写入口)
 → DemoVehicleStateStore(@Observable 单源,8 字段 cell)
 → readback(读回 actualValue 才算成功)
 → MasterShell UI 卡片亮暗 + SpeechSynthesisEngine(AVSpeech)播报「操作对象 + readback」
TraceLogger 五段贯穿:decode / plan / guard / execute / readback
```

**安全铁律**:DemoGuard 是**代码门**,不是 prompt;模型只产候选 ToolCallFrame,**不直接执行动作**;`pending / failed / unknown` 不得播报「已完成」。

### 关键技术决策(选 X 不选 Y)

| 决策 | 选 | 不选(原因) |
|---|---|---|
| 大脑 | Qwen3-1.7B + LoRA(LLMBackend 协议,mlx-swift-lm 主实现) | 0.6B(多工具弱)/ 4B(端侧重) |
| 工具调用 | 顺 Qwen3 原生格式 → 解析 → ToolCallFrame | 逼模型直出内部 JSON(违训练分布、增 decode_failed) |
| ASR | WhisperKit large-v3(主线,硬件够) | small(仅降级档)/ sherpa SenseVoice(速度对照) |
| 端点 | push-to-talk + 录音期流式预转 | VAD 自动端点(二期;接口预留) |
| TTS | AVSpeechSynthesizer | CosyVoice / TTSKit(包体 + 内存风险,二期) |
| 车控 | 全 mock,DemoVehicleStateStore 单源,UI 只读 | 真车控 / KUKSA broker(违边界) |
| 安全 | **DemoGuard 代码门** | prompt 安全(可被绕过,不可靠) |
| 规则 / LLM | 规则 80% 高频明确 / LLM 20% 模糊跨域 | 全 LLM(慢 + 不稳 + 难进 800ms) |
| 契约源 | `contracts/capabilities.yaml` 单一事实源(其余生成) | 多处 schema(漂移) |
| UI / 状态 | SwiftUI + @Observable 单 store + 内存 reset | TCA(重)/ SwiftData(不适合干净开场) |
| runtime 验证 | 三步:parser 单测 → Python `mlx_lm.server` 验模型格式 → Swift 嵌入 | 直接 Swift spike(变量耦合,debug 面大) |

### 7 层 × 命名

L0 VoiceController(push-to-talk;VAD/KWS 接口预留 Phase2)· L1 理解(WhisperKit + SpeechTextNormalizer + IntentEngine)· L2 路由(Router + MasterShell + ToolCallDecoder)· L3 规划(ThreeStateEngine + ActionPlanner)· L4 安全(DemoGuard)· L5 执行(DemoActionExecutor + DemoVehicleStateStore + readback)· 贯穿(DialogueState + TraceLogger)。命名统一 `DemoGuard` + `Demo*` 前缀。

## Risks / Trade-offs

- [large-v3 在 iPhone 是否进 800ms 未实测] → Step1 spike 先验 + 硬件论据(M5/A16 远超 8155);过线降 small / SenseVoice。
- [Qwen3 malformed tool call] → ToolCallDecoder Codable 严格解码 + retry≤1 + decode_failed 转澄清;MLX 无 grammar,prompt + few-shot 兜底,llama grammar 仅对照(不降级)。
- [端侧内存:1.7B + large + TTS + SwiftUI 同跑] → 模型 app 启动预热常驻(非冷启动)+ 实测内存 / 热量。
- [WhisperKit 无 `contextualStrings`] → 热词走 `promptTokens + usePrefillPrompt`(Codex 源码核实);`noSpeechProb` 不直接当业务置信,wrapper 组合 + 实测校准。
- [Observation 版本底线] → `@Observable` 需要 iOS 17 / macOS 14 起;本 change 将 deployment target 锁为 iOS 17+ / macOS 14+。
- [Swift 6 主线程隔离与 XCTest] → `DemoVehicleStateStore` 保持 `@Observable @MainActor`;测试目标不全局开启 MainActor 默认隔离,需要主线程的测试方法单独标 `@MainActor`。
- [TTS 真实出声不可自动化] → `AVSpeechSynthesizer` 只作为系统 TTS adapter;自动化测试通过 `SpeechSynthesisEngine` mock 验证播报文本,真实音频留 smoke / 手测。
- [xcodebuild destination 漂移] → 先固定 macOS target build; iOS target 存在但本机暂无 iOS runtime,后续用 `xcodebuild -showdestinations` 选择实际可用 simulator。

## Migration Plan

greenfield 无迁移。部署 = 本地 Xcode build → 真机签名(Apple Developer)→ iPhone 装机 + Mac 镜像投屏。回滚 = git revert(模块热更新,失败回退用 revert 不预先锁文件)。

## Open Questions

- ASR 模型打包策略:预置封包 / 受控本地缓存 / 开发期下载后封包?(→ `define-voice-contract`)
- TTS 中文 voice / rate / pitch 的 S-PASS(磊哥听感拍板)。
- demo must-pass 具体 15–25 条清单构成(→ `define-vehicle-tool-bench`)。
- Qwen3 `enable_thinking` 默认关闭对格式 / 延迟的影响(Step1 验)。

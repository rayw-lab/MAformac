# 架构发现

状态: `T-PASS` synthesis from 3 read-only subagents + main-thread GitNexus checks

## 1. 车辆协议与 mock 车控

VSS 更适合做内部命名法和绑定层, 不适合成为首版 runtime。`COVESA__vehicle_signal_specification` 和 `COVESA__vss-tools` 的核心价值是让能力表具备稳定语义坐标, 例如 `vss_path/readable/writable/value_type/unit/allowed_values`。首版 demo 仍应走本地 mock state。

KUKSA 更适合作为开发期回归参照。`eclipse-kuksa__kuksa-databroker` 暴露的 `current/target/subscribe/provider` 状态模型很适合映射到 MAformac 的 `actualValue/desiredValue/availability/revision`。但 KUKSA broker 不应进首版 iOS/macOS 演示 runtime。

CAN/DBC 必须隔离。`eclipse-kuksa__kuksa-can-provider` 的 `Mapper/DBCParser/handle_update` 思路说明底层 CAN frame 和品牌字段应该只存在于 mapping layer。Agent 和 UI 只接触 `Capability`。

Canals 的可复用链路是: route decision -> handler -> car API -> 状态/测试。MAformac 对应链路应是:

```text
ToolCallDecoder
  -> DemoGuard
  -> DemoActionExecutor
  -> DemoVehicleStateStore
  -> readback trace
```

## 2. 离线语音与 Swift runtime

离线语音要拆成状态机, 不能把 WhisperKit 当整条链路:

```text
Idle
  -> Recording
  -> Endpointing
  -> Transcribing
  -> ResolvingIntent
  -> Executing
  -> Speaking
  -> Interrupted
```

WhisperKit 适合作为首版 ASR 主实现。它在 Swift 中有 `transcribe(audioPath:)` / `transcribe(audioArray:)` 入口, 适合 macOS/iOS。它不解决 intent、安全、TTS、barge-in。

sherpa-onnx 更适合作为语音基础设施备胎和二期 VAD 对照。`SherpaOnnxVoiceActivityDetectorWrapper` 的 `acceptWaveform/isSpeechDetected/reset/flush` 模式可用于二期端点检测。

TTS 应独立为 `SpeechSynthesisEngine`, 只管 `speak/stop/isSpeaking` 和打断策略。Agent 只给可播报文本, TTS 不读车控状态。

`LLMBackend` 应采用统一门面。`tattn__LocalLLMClient` 的 `LLMClient` 思路可抽为 `load/unload/stream/generateToolPlan/pause/resume/cancel`; MLX Qwen 主线, llama.cpp/GGUF 备选, FoundationModels baseline。

MCP Swift 适合做二期工具协议适配, 不适合做车控安全源。MCP `Tool` 的 schema/annotations 可转为内部 candidate, 但执行仍必须经过 `CapabilityRegistry -> DemoGuard -> MockVehicleExecutor`。

## 3. 结构化输出、函数调用与评测

函数调用不应是“模型吐 JSON 字符串”。应定义 `ToolCallFrame` 类型协议:

```text
candidate tools
  -> structured generation
  -> decode validation
  -> DemoGuard
  -> mock state readback
```

结构化输出分两层:

- runtime 支持时: JSON Schema / grammar / logits processor
- runtime 不支持时: Swift `Codable + enum + validator + retry<=1`

小模型评测应复用 BFCL / tiny-tool-bench / Hammer 的结构: gold call、parser、scorer。主指标看整句帧准确率, 不看模型解释是否像。

规则/LLM 分流是架构边界。标准说法、枚举、极值和固定状态查询走规则快路径; 模糊、跨域、端状态依赖才进入 Qwen3 + LoRA。

LoRA 不应起手就练。先用 prompt/schema/few-shot 打出失败样本, 样本攒到门槛后只训练“模糊说 -> 跨域动作映射”, 并用同一测试集跑 base vs LoRA。

## 4. 对 MAformac 的直接设计约束

`contracts/capabilities.yaml` 应成为唯一人工维护源, 字段至少包含:

- `id/status`
- 中文别名、模板、反例
- tool schema
- `reference_binding(vss_path/extension_path/readable/writable/type/unit/allowed_values)`
- `execution(mock_behavior/state_dependencies/idempotent/exclusive_bus)`
- `demo_guard(risk_level/confirm_policy/preconditions/block_rules)`
- response template
- eval fixture refs
- source refs

首批能力建议限定 8 条:

- 空调温度
- 升温/降温
- 座椅加热
- 座椅通风
- 车窗百分比
- 阅读灯
- 风量
- 舒适状态查询

`DemoVehicleStateStore` 应是单一状态源。UI 只读 store, 按钮和模型都不能直接改 UI 状态。所有动作经 `DemoActionExecutor.applyMockTransition` 后读回状态。

`DemoGuard` 必须是代码门。至少检查 unknown tool、schema、范围/枚举、是否 writable、风险等级、确认策略、互斥 bus、demo mode、状态前置条件。`pending/failed/unknown` 不能播报“已完成”。

## 5. 证据来源

GitNexus 完整索引:

- Vehicle / SDV: `COVESA__vss-tools`, `eclipse-kuksa__kuksa-databroker`, `eclipse-kuksa__kuksa-can-provider`, `Bosch-Connected-Experience-26__Canals`, `reinhardjurk__agent-tester`, `dengky23__nlu-pipeline-vehicle`
- Speech / Swift: `argmaxinc__WhisperKit`, `argmaxinc__argmax-oss-swift`, `k2-fsa__sherpa-onnx`, `ml-explore__mlx-swift-lm`, `modelcontextprotocol__swift-sdk`, `tattn__LocalLLMClient`
- Tool / eval / OpenSpec: `Fission-AI__OpenSpec`, `ShishirPatil__gorilla`, `javierlimt6__tiny-tool-bench`, `MadeAgents__Hammer`, `dottxt-ai__outlines`, `guidance-ai__guidance`, `instructor-ai__instructor`, `noamgat__lm-format-enforcer`

旁证:

- `referencerepo/reports/01_vehicle_protocol_and_sdv.md`
- `referencerepo/reports/02_offline_voice_and_nlu.md`
- `referencerepo/reports/03_apple_runtime_and_swift_integration.md`
- `referencerepo/reports/04_model_runtime_and_function_call_eval.md`
- `referencerepo/reports/05_structured_output_and_guardrails.md`
- `docs/tech-baseline-from-raw.md`
- `docs/tech-baseline-supplement-v0.2.md`


# 00 证据账本

> ⚠️ **HISTORICAL 快照（T5）—— 文档级联 banner（2026-07-07 B4b）**
> 本文是 `docs/grill-tournament/cascade-inventory.md §T5` 标记的历史快照，当前仅保留溯源/交接价值；supersede 指针以 `docs/grill-tournament/cascade-inventory.md` 的 T5 账本为准。
> **活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md` + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` + `docs/grill-tournament/cascade-inventory.md`。正文保留供溯源，勿据此推进。

本文列出本次二次调研实际使用的主要证据。分为三层：官方/一手源、本地 repo 源码、本地调研报告。后续写 PRD/SRD/spec 时，优先引用一手源和本地源码，再引用本地报告结论。

边界前提：MAformac 是 Master Agent for Mac，是磊哥个人自用、装在自己 Mac/iPhone 上、给客户演示方案能力的离线 demo。这里引用 VSS、KUKSA、Canals、Eclipse SDV 等资料，是为了借命名、schema、状态建模、trace、eval 和边界判断，不是要做真实车机、真车控制、量产座舱或客户侧交付系统。

## 官方/一手源

| 来源 | 关键用途 | 链接 |
|---|---|---|
| Qwen function calling 文档 | 证明 Qwen3 function calling 依赖工具协议、JSON Schema、模板和应用执行闭环，不等于模型自己可靠执行演示动作 | [Function Calling - Qwen](https://qwen.readthedocs.io/en/latest/framework/function_call.html) |
| Qwen3-1.7B model card | 证明 Qwen3-1.7B 参数、context、agent/multilingual 能力候选 | [Qwen/Qwen3-1.7B](https://huggingface.co/Qwen/Qwen3-1.7B) |
| Qwen3 技术报告 | 证明 Qwen3 dense 模型族包含 0.6B、1.7B、4B 等 | [arXiv:2505.09388](https://arxiv.org/pdf/2505.09388) |
| Qwen speed benchmark | 证明模型内存和速度必须按环境实测，不能只按参数量拍板 | [Speed Benchmark - Qwen](https://qwen.readthedocs.io/en/latest/getting_started/speed_benchmark.html) |
| Apple Foundation Models Newsroom | 证明 Foundation Models framework 的系统版本、设备和 Apple Intelligence 条件 | [Apple Newsroom](https://www.apple.com/newsroom/2025/09/apples-foundation-models-framework-unlocks-new-intelligent-app-experiences/) |
| Apple WWDC25 Meet Foundation Models | 证明 on-device 3B/2-bit、device-scale、tool calling、stateful session 边界 | [Meet the Foundation Models framework](https://developer.apple.com/videos/play/wwdc2025/286/) |
| Apple WWDC25 Deep dive Foundation Models | 证明 guided generation、dynamic schema、tool calling 的结构化输出能力 | [Deep dive into the Foundation Models framework](https://developer.apple.com/videos/play/wwdc2025/301/) |
| COVESA VSS 官网 | 证明 VSS 是车辆信号语义和层级树，不是 app runtime | [Vehicle Signal Specification](https://covesa.global/vehicle-signal-specification/) |
| COVESA VSS GitHub | 证明 VSS 目标是形成共同语言，独立于协议和序列化格式 | [COVESA/vehicle_signal_specification](https://github.com/COVESA/vehicle_signal_specification) |
| COVESA vss-tools GitHub | 证明 vss-tools 用于转换/校验 VSS，属于开发期工具 | [COVESA/vss-tools](https://github.com/COVESA/vss-tools) |
| KUKSA Databroker GitHub | 证明 KUKSA 是 gRPC broker，provider 才负责连接真实车辆侧数据/动作来源；这正说明它不该进入 MAformac 首版 demo runtime | [eclipse-kuksa/kuksa-databroker](https://github.com/eclipse-kuksa/kuksa-databroker) |
| KUKSA Quickstart | 证明 macOS/Docker 端口和 55556 实操注意点 | [Kuksa Quickstart](https://eclipse-kuksa.github.io/kuksa-website/quickstart/) |
| Eclipse SDV service-to-signal blueprint | 证明 KUKSA provider 属于真实车辆侧链路，因此不适合 MAformac 首版 demo | [service-to-signal-blueprint](https://sdv-blueprints.eclipse.dev/docs/service-to-signal/) |

## 本地 repo 源码证据

| 本地文件 | 关键用途 |
|---|---|
| [clone_coverage.md](/Users/wanglei/workspace/MAformac/referencerepo/snapshots/clone_coverage.md:3) | 证明 38/38 repo 已 clone。 |
| [repo_inventory.md](/Users/wanglei/workspace/MAformac/referencerepo/snapshots/repo_inventory.md:3) | 证明每个 repo 的 HEAD、文件数、语言和 manifest。 |
| [mlx-swift-lm Package.swift](/Users/wanglei/workspace/MAformac/referencerepo/repos/ml-explore__mlx-swift-lm/Package.swift:1) | 证明 Swift 6.1、macOS 14、iOS 17 门槛。 |
| [mlx-swift-lm LLMModelFactory.swift](/Users/wanglei/workspace/MAformac/referencerepo/repos/ml-explore__mlx-swift-lm/Libraries/MLXLLM/LLMModelFactory.swift:217) | 证明本地 registry 含 Qwen3-0.6B-4bit 和 Qwen3-1.7B-4bit。 |
| [LocalLLMClient README](/Users/wanglei/workspace/MAformac/referencerepo/repos/tattn__LocalLLMClient/README.md:31) | 证明项目 experimental、较大模型可能需要 increased-memory entitlement、支持 GGUF/MLX/FoundationModels/tool calling。 |
| [FoundationModelsClient.swift](/Users/wanglei/workspace/MAformac/referencerepo/repos/tattn__LocalLLMClient/Sources/LocalLLMClientFoundationModels/FoundationModelsClient.swift:5) | 证明 FoundationModels backend 有 iOS 26/macOS 26 availability gate。 |
| [COVESA VSS README](/Users/wanglei/workspace/MAformac/referencerepo/repos/COVESA__vehicle_signal_specification/README.md:6) | 证明 VSS 目标是共同语言。 |
| [vss-tools README](/Users/wanglei/workspace/MAformac/referencerepo/repos/COVESA__vss-tools/README.md:6) | 证明 vss-tools 的转换/校验定位。 |
| [KUKSA Databroker README](/Users/wanglei/workspace/MAformac/referencerepo/repos/eclipse-kuksa__kuksa-databroker/README.md:61) | 证明 VSS 与 Databroker/provider 的边界。 |
| [Canals README](/Users/wanglei/workspace/MAformac/referencerepo/repos/Bosch-Connected-Experience-26__Canals/README.md:63) | 证明 Canals 是全栈参考，不能直接当 Apple-only 离线 app runtime。 |
| [MCP Swift SDK README](/Users/wanglei/workspace/MAformac/referencerepo/repos/modelcontextprotocol__swift-sdk/README.md:1) | 证明 Swift MCP SDK 的工具/资源/客户端/服务端边界。 |

## 本地报告证据

| 本地文件 | 关键用途 |
|---|---|
| [docs/README.md](/Users/wanglei/workspace/MAformac/docs/README.md:16) | 证明 D1-D37 并未全部锁定，仍有 4 项待拍。 |
| [integration-blueprint.md](/Users/wanglei/workspace/MAformac/docs/integration-blueprint.md:23) | 证明 1.7B 主力候选和 0.6B fallback 的新口径。 |
| [tech-baseline-from-raw.md](/Users/wanglei/workspace/MAformac/docs/tech-baseline-from-raw.md:79) | 证明 v0.1 已有 Capability 协议和统一 Tool schema。 |
| [tech-baseline-supplement-v0.2.md](/Users/wanglei/workspace/MAformac/docs/tech-baseline-supplement-v0.2.md:173) | 证明 Capability 注册表需要仲裁/并行字段。 |
| [01_vehicle_protocol_and_sdv.md](/Users/wanglei/workspace/MAformac/referencerepo/reports/01_vehicle_protocol_and_sdv.md:43) | 证明 VSS/vss-tools/KUKSA/AutoWRX 对能力目录方向的支撑。 |
| [02_offline_voice_and_nlu.md](/Users/wanglei/workspace/MAformac/referencerepo/reports/02_offline_voice_and_nlu.md:3) | 证明 hassil/intents/WhisperKit/sherpa-onnx 的语音和规则快路径定位。 |
| [03_apple_runtime_and_swift_integration.md](/Users/wanglei/workspace/MAformac/referencerepo/reports/03_apple_runtime_and_swift_integration.md:33) | 证明 MLX Swift、LocalLLMClient、MCP Swift SDK 的运行时定位。 |
| [04_model_runtime_and_function_call_eval.md](/Users/wanglei/workspace/MAformac/referencerepo/reports/04_model_runtime_and_function_call_eval.md:3) | 证明 llama.cpp、BFCL、tiny-tool-bench、llamafile 的开发期定位。 |
| [05_structured_output_and_guardrails.md](/Users/wanglei/workspace/MAformac/referencerepo/reports/05_structured_output_and_guardrails.md:3) | 证明结构化输出和类型校验的重要性。 |
| [07_deep_appendix_to_1000.md](/Users/wanglei/workspace/MAformac/referencerepo/reports/07_deep_appendix_to_1000.md:25) | 证明 `capabilities.yaml` 作为源并生成多类产物的建议。 |

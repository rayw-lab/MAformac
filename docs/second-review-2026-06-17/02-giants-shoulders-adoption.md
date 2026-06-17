# 02 巨人的肩膀引用意见

本文把 Claude Code pass 过的肩膀重新分为四类：

- 直接依赖：可能进入 App 或 Swift package。
- 开发期工具：只在 Mac/dev 流程里用，产静态资产或指标，不进 iOS runtime。
- 架构参考：只借边界、状态机、测试方法，不拷代码。
- 反面边界：证明什么不该进首版。

采用边界：MAformac 是 Master Agent for Mac，是个人自用和客户演示 demo。所有肩膀只服务“离线端侧方案演示 + mock 车控状态”，不服务真实车机、真实车辆控制、量产座舱或客户侧运行产品。

## 采用矩阵

| 肩膀 | 引用意见 | MAformac 采用方式 | 不采用什么 |
|---|---|---|---|
| COVESA VSS | VSS 的目标是形成独立于协议和序列化格式的车辆信号共同语言：[VSS README](/Users/wanglei/workspace/MAformac/referencerepo/repos/COVESA__vehicle_signal_specification/README.md:6)。COVESA 官网也说明它把车辆信号组织为层级树。 | 作为 mock 能力的内部命名参考。能力项可用 `vss_path` 或 `extension_path` 做参考绑定，不让模型随意造字段。 | 不把 VSS 直接暴露给用户，不承诺覆盖所有品牌车设，不把它写成上车协议。 |
| COVESA vss-tools | 官方目标是转换或校验 VSS：[vss-tools README](/Users/wanglei/workspace/MAformac/referencerepo/repos/COVESA__vss-tools/README.md:6)。 | Mac 开发期生成器参考，辅助输出 Swift enum、tool schema、能力表。 | 不进入 iOS runtime；不让生成物替代 demo 风控策略。 |
| KUKSA Databroker | 它是 gRPC vehicle data broker，基于 VSS 信号树；provider 负责连接真实车辆侧数据和动作来源：[KUKSA README](/Users/wanglei/workspace/MAformac/referencerepo/repos/eclipse-kuksa__kuksa-databroker/README.md:61)。 | 作为远期可选对照和边界提醒。它证明 broker 不是模拟器，MAformac 首版应只用 `InMemoryDemoVehicleStateStore`。 | 不嵌进 iOS 首版；不进入 Phase 0-5；不把它当“自动模拟车”。 |
| Canals | 它最像完整车控 Agent 目标系统图，但技术栈含 AWS Bedrock、MongoDB、FastAPI、Astro、KUKSA：[Canals README](/Users/wanglei/workspace/MAformac/referencerepo/repos/Bosch-Connected-Experience-26__Canals/README.md:7)。 | 只抽三件事：`DemoVehicleStateStore`、`DemoActionExecutor`、`AgentTrace`。 | 不照搬全栈，不拿它证明纯端侧 Swift 可行，不引出真实车机路线。 |
| AutoWRX | 本地报告判断它的价值是能力目录和 API catalog：[01_vehicle_protocol_and_sdv.md](/Users/wanglei/workspace/MAformac/referencerepo/reports/01_vehicle_protocol_and_sdv.md:93)。 | 借“能力工作台”思想。第一版用 Markdown/JSON catalog，未来再考虑 GUI。 | 不引入 Web 平台和后台服务。 |
| VDM | 本地报告认为它适合未来复杂实体关系和可查询模型：[07_deep_appendix_to_1000.md](/Users/wanglei/workspace/MAformac/referencerepo/reports/07_deep_appendix_to_1000.md:55)。 | 二期借 `listCapabilities(zone)`、`getCurrentState(paths)`、`explainCapability(id)`。 | 首版不引 GraphQL，不把模型层复杂化。 |
| hassil | 模板识别可低延迟确定输出 intent/slot：[02_offline_voice_and_nlu.md](/Users/wanglei/workspace/MAformac/referencerepo/reports/02_offline_voice_and_nlu.md:3)。 | Swift 复刻迷你 hassil，作为规则快路径。 | 不直接嵌 Python，不期待它处理模糊话术。 |
| OHF-Voice/intents | 大规模 YAML 语料说明模板是资产，不是正则碎片：[02_offline_voice_and_nlu.md](/Users/wanglei/workspace/MAformac/referencerepo/reports/02_offline_voice_and_nlu.md:13)。 | 借目录结构和校验思想，管理 `resources/intents/zh-CN/*.yaml`。 | 不直接复用智能家居语料。 |
| WhisperKit | Swift-native Apple 平台 Whisper 管线，适合第一版 ASR 候选：[02_offline_voice_and_nlu.md](/Users/wanglei/workspace/MAformac/referencerepo/reports/02_offline_voice_and_nlu.md:53)。 | 作为 `SpeechRecognizer` 候选实现。先测 50 条中文 mock 车控短句。 | 不让 ASR 承担意图理解；ASR 错和 NLU 错要分开记录。 |
| sherpa-onnx | 离线语音全家桶，覆盖 ASR/TTS/VAD/KWS：[02_offline_voice_and_nlu.md](/Users/wanglei/workspace/MAformac/referencerepo/reports/02_offline_voice_and_nlu.md:33)。 | 作为 VAD/KWS/TTS 备选和第二阶段语音矩阵。 | 首版不急着引入完整重型栈。 |
| MLX Swift LM | Swift package 用 MLX Swift 构建 LLM/VLM 应用，当前 `Package.swift` 要求 macOS 14、iOS 17、Swift 6.1：[Package.swift](/Users/wanglei/workspace/MAformac/referencerepo/repos/ml-explore__mlx-swift-lm/Package.swift:1)。 | App 运行时主候选，默认测 Qwen3-1.7B-4bit 和 0.6B-4bit。 | 不假设上来就满足 function calling；必须用 mock 车控 eval 测。 |
| LocalLLMClient | README 明确支持 GGUF/MLX/FoundationModels、streaming、experimental tool calling：[LocalLLMClient README](/Users/wanglei/workspace/MAformac/referencerepo/repos/tattn__LocalLLMClient/README.md:37)。 | 借 facade 设计，必要时作为早期依赖候选。 | 不把核心协议锁死在 experimental API。 |
| llama.cpp / llama.swift / llamafile | llama.cpp 是 Mac server 和 GGUF fallback；llamafile 是开发期 server 加速；llama.swift 是小桥。 | Mac 第一刀可用 server 快速验证 prompt/schema；Swift 端保留 `LlamaBackend`。 | 不从 Day 1 直接把业务层绑死在 C++/GGUF。 |
| Gorilla/BFCL | 本地报告认为它是 function calling 评测官方来源：[04_model_runtime_and_function_call_eval.md](/Users/wanglei/workspace/MAformac/referencerepo/reports/04_model_runtime_and_function_call_eval.md:13)。 | 造 `demo-tool-bench`：工具名、参数、JSON 可解析、多工具、拒绝/澄清。 | 不直接用通用数据当 mock 车控验证。 |
| tiny-tool-bench | 小模型 tool calling 评测更贴近 0.6B/1.7B 风险：[04_model_runtime_and_function_call_eval.md](/Users/wanglei/workspace/MAformac/referencerepo/reports/04_model_runtime_and_function_call_eval.md:23)。 | 控制第一版工具数和参数复杂度；测工具数增加后的准确率下降。 | 不用大模型 benchmark 自我安慰。 |
| outlines / lm-format-enforcer / guidance / instructor | 共同意见是 schema-first、受控生成、类型校验和有限重试：[05_structured_output_and_guardrails.md](/Users/wanglei/workspace/MAformac/referencerepo/reports/05_structured_output_and_guardrails.md:3)。 | Mac 端实验；Swift 端用 `Codable`、enum、validator、错误枚举接住输出。 | Python 库不进 iOS runtime；安全策略不交给 prompt。 |
| MCP Swift SDK | 官方 Swift SDK，支持 client/server、tools、resources、prompts 等：[MCP Swift SDK README](/Users/wanglei/workspace/MAformac/referencerepo/repos/modelcontextprotocol__swift-sdk/README.md:1)。 | 首版只借工具注册和 schema 思想；二期 Mac/iPhone 拆分时再考虑真 MCP。 | 不把 demo 风控外包给 MCP。 |
| Alexa Auto SDK / Azure car voice demo | 前者提醒 capability agent 边界，后者提醒 UI/UX 状态反馈。 | 借 UX 状态：listening、thinking、confirming、executing、failed；借 capability agent 拆分。 | 不引云端、认证、Android、商业 SDK。 |

## 需要保留的边界注记

1. Canals 的 “local-first” 不能等同于 MAformac 的“纯端侧离线”。Canals 架构里明确有 OpenAI Whisper API、AWS Bedrock、MongoDB 和地图/车端服务。
2. KUKSA Databroker 不能等同于“模拟车”。它只是 broker；动作行为要 provider 或 mock transition。MAformac 近期只需要内存 mock。
3. VSS 不能强行覆盖所有品牌车设。能力目录要支持 `extension_path`，否则磊哥自己的功能清单会被标准路径卡死。
4. Qwen3 tool calling 是潜力，不是 mock 车控可用性证明。Qwen 官方文档也强调 function calling 本质上依赖工具协议、模板和应用执行闭环。
5. Foundation Models 是很好的 baseline，但系统版本、设备和 Apple Intelligence 开关是硬门槛，不适合作可控微调主线。

## 综合引用意见

最应该吸收的不是某一个 repo，而是 8 条工程意见：

1. VSS/vss-tools：所有 mock 车控能力先有标准命名和类型边界。
2. AutoWRX：功能清单必须成为能力目录，而不是散落在代码、UI、prompt 里。
3. hassil/intents：80% 高频明确命令应走规则快路径。
4. BFCL/tiny-tool-bench：任何模型路线都必须用同一套 `ToolCall[]` 评测。
5. instructor/outlines：模型输出必须被类型系统和 validator 接住。
6. Canals：执行成功必须看 mock 状态和 trace，不能听模型说成功；KUKSA 只保留为远期对照。
7. MLX/LocalLLMClient：业务层必须通过 `LLMBackend` 抽象，不押死单一 runtime。
8. Alexa/Azure demo：演示 App 的第一屏应是状态卡片和执行轨迹，不是聊天页。

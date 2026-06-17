# 03 Apple Runtime And Swift Integration

## wizcheu/iOSLLMFrameworkBenchmark

功能说明：这个仓库直接服务于你的 runtime 选型问题：在 iOS 上比较不同本地 LLM 框架，尤其涉及 MLX Swift、llama.cpp、MLC-LLM 等路线，并包含 Qwen3 相关测试线索。你的项目若要用 Qwen3-0.6B，最早要回答的不是“模型聪不聪明”，而是“iPhone 上能不能稳定加载、延迟多少、内存多少、是否发热”。这个仓库就是选型前的实测参考。

技术栈与架构：本地库存显示 Swift、Xcode 工程、assets、third-party 和 JSON 配置。它是 benchmark app，而不是通用 SDK。架构通常包括模型配置、框架适配层、测试页面、结果展示和资源管理。它能帮助你设计自己的 `LLMEngine` 抽象：不同后端统一 `load`、`generate`、`stream`、`toolCall` 或 `structuredOutput` 接口。

可复用能力点：第一，复用其 benchmark 指标：加载耗时、首 token、tokens/s、内存、模型文件大小。第二，复用它对不同 iOS LLM 框架的接入方式，避免你一开始把业务层绑死在 llama.cpp 或 MLX。第三，用它校准 Qwen3-0.6B 是否真的适合 iOS 端；如果 0.6B 也吃紧，就应把模糊理解范围收窄。

限制与风险：benchmark 仓库不是生产 runtime；测试设备、iOS 版本、模型量化格式都会影响结论。落地建议：先跑它或仿照它做你自己的小 benchmark，再决定主 runtime。业务代码中必须保留 `LLMBackend` 协议，允许 MLX、llama.cpp、Foundation Models 三路切换。

## mattt/llama.swift

功能说明：`llama.swift` 是 Swift 对 llama.cpp 的轻量包装。它的价值在于让 Swift 项目以更自然的方式调用 llama.cpp，而不是直接写 C/C++ 桥接。对你的 macOS/iOS app，如果选择 GGUF + llama.cpp 路线，它能作为最小接入层参考。

技术栈与架构：仓库很小，Swift 文件、`Package.swift` 和少量文档为主。架构上是 Swift Package 封装底层 llama.cpp XCFramework 或接口，暴露更 Swift 化的 API。它不是完整 app framework，也不会替你做模型下载、聊天状态、工具调用或 JSON 约束。

可复用能力点：第一，学习 Swift Package 如何引用 llama.cpp。第二，为你的 `LlamaCppBackend` 提供 API 设计参考。第三，适合作为低复杂度试验路径：先在 Mac app 跑本地 GGUF，再考虑 iOS 打包和性能。

限制与风险：仓库体量小意味着高级能力需要自己补：流式输出、上下文管理、grammar、并发取消、模型资源管理、错误恢复。落地建议：如果第一版追求速度，优先考虑 `LocalLLMClient` 或 MLX Swift；如果你确定走 GGUF/llama.cpp，`llama.swift` 是干净的小桥，不是完整 runtime 层。

## StanfordSpezi/SpeziLLM

功能说明：SpeziLLM 是 Swift 应用里的 LLM 抽象框架，来自 Stanford Spezi 生态。它对你的价值不是车控功能，而是“把 LLM 当成可替换服务”的应用架构：本地、云端、fog node 等不同执行位置可以被同一层 API 管理。你的项目虽然目标离线，但未来可能要比较 Foundation Models、本地 Qwen、Mac 端辅助服务，因此抽象层很重要。

技术栈与架构：仓库以 Swift 为主，带 `Package.swift`、Sources、Tests、FogNode 和文档。架构上偏 Swift package framework，围绕 LLM 会话、provider、message、response、模块化集成组织。它能帮助你避免把 prompt、模型调用、UI 状态和工具执行混在一起。

可复用能力点：第一，复用 provider 抽象：`LocalQwenProvider`、`FoundationModelsProvider`、`MockProvider` 可以共用业务层。第二，学习 Swift 并发和流式响应如何进入 SwiftUI。第三，未来如果你想做 Mac 端大模型代理、iPhone 端轻模型 fallback，可以借鉴 fog node 思路。

限制与风险：医疗/研究生态背景不等同车控安全架构。它未必内置你需要的 function calling、多意图拆分和 VSS action schema。落地建议：只借抽象，不照搬全部框架。你的第一版可建立 `LLMProvider`、`ToolSchemaProvider`、`IntentResolver` 三层，保持轻量。

## ml-explore/mlx-swift-lm

功能说明：`mlx-swift-lm` 是 Apple 官方 MLX Swift 方向的 LLM 包，是当前 Apple-native 本地模型路线的重要候选。截图里也提醒不要用旧的 `mlx-swift-examples`，而应看这个仓库。对只支持 macOS/iOS 的项目，MLX Swift 可能比通用 GGUF 路线更贴近 Apple Silicon 和 Swift 工程。

技术栈与架构：仓库以 Swift 为主，带 `Package.swift`、examples、文档和模型相关代码。它使用 MLX Swift 进行模型加载、tokenization、生成和示例运行。架构上是 Apple 原生推理库 + LLM 包装层。你的项目可以把它作为 `MLXBackend`，负责 Qwen 或兼容模型的本地生成。

可复用能力点：第一，优先验证 Qwen3-0.6B 在 MLX Swift 上的加载和速度。第二，学习模型下载、tokenizer、生成参数和流式输出。第三，它有利于你未来适配 Apple Foundation Models 或 MLX 官方能力，因为工程语言和生态一致。

限制与风险：MLX 格式、模型转换、量化、iOS 版本和设备限制都要实际验证。它不自动提供 function calling，需要你在 prompt/schema/decoder 层做约束。落地建议：把 MLX Swift 作为主候选之一，但不要一开始锁死；通过 `LocalLLMClient` 或自建协议把 MLX 与 llama.cpp 并列。

## huggingface/swift-transformers

功能说明：`swift-transformers` 是 Hugging Face 官方 Swift 包，覆盖 tokenizer、Hub 下载和推理 API 等基础能力。它的重要性在于：本地 LLM 不只是模型推理，还包括 tokenizer、模型文件管理、Hub 资源下载、配置解析。你的 Qwen3 或其它模型如果来自 HF，Swift 端需要可靠的模型资产管理。

技术栈与架构：仓库以 Swift 为主，带 `Package.swift`、Sources、Tests、Examples、JSON 和 safetensors 样例。架构上围绕 HF 模型生态的 Swift 接入，尤其是 tokenizer 和模型资源。它不是车控 Agent，不保证端侧 function calling，但可以作为“模型集成基础设施”。

可复用能力点：第一，复用 tokenizer 和 Hub 下载思路，减少模型资源处理成本。第二，作为 MLX/llama.cpp 之外的基础组件，帮助处理 tokenizer 一致性。第三，适合做模型包管理：首次启动前检查模型、校验文件、选择本地路径。

限制与风险：推理能力和具体模型支持要看仓库当前实现，不能假设所有 HF/Qwen 模型开箱即用。iOS 离线 app 也不应依赖运行时下载作为核心路径。落地建议：开发期可用它下载和校验模型；发布到自己手机时，把模型文件预置或通过本地文件导入，避免网络依赖。

## tattn/LocalLLMClient

功能说明：`LocalLLMClient` 是这批 Swift 仓库里很适合做 runtime facade 参考的项目。它尝试用统一 Swift API 封装 llama.cpp、MLX 和 Apple Foundation Models 等后端。你的项目恰好需要避免“先选错 runtime 后面重构业务层”的风险，因此这个仓库非常值得看。

技术栈与架构：仓库以 Swift 为主，带 Sources、Example、Tests、scripts 和 `Package.swift`。架构价值在 facade：上层只面向统一客户端，下层切换不同推理引擎。它的方向和你的 `LLMBackend` 协议高度一致：规则快路径不进模型，模型路径则通过统一接口处理 prompt、stream、取消和错误。

可复用能力点：第一，直接借鉴后端抽象层，不把 UI 或 intent resolver 绑定到 MLX/llama.cpp。第二，借鉴 Apple Foundation Models 作为备选后端的思路：如果系统自带模型能完成 function-call demo，可以先用它建立基线。第三，便于做 A/B：同一组车控语料跑不同后端，比较 JSON 正确率和延迟。

限制与风险：它不等于成熟车控 Agent 框架；具体后端能力、系统版本要求和 API 稳定性要实测。落地建议：把它作为 Swift runtime 选型的“最大参考仓库”之一。你的项目可以先实现类似 facade，再逐步接 MLX、llama.cpp、Foundation Models。

## modelcontextprotocol/swift-sdk

功能说明：`modelcontextprotocol/swift-sdk` 是 MCP 的 Swift SDK。MCP 本身更多用于模型与工具/资源之间的协议化连接，但对你的车控 Agent 有两个重要启发：工具不是 prompt 里的自然语言列表，而应有结构化 schema、调用参数、返回值和错误协议；资源和工具可以被统一注册、发现和执行。

技术栈与架构：仓库以 Swift 为主，带 `Package.swift`、Sources、Tests、JSON 和文档。架构上会围绕 MCP client/server、transport、tool/resource/prompt 等概念。你的 app 不一定要完整实现 MCP server，但可以借它的工具注册和消息结构来设计车控 function call 层。

可复用能力点：第一，复用工具协议思想：每个车控动作都有 name、description、input schema、output schema、error。第二，未来如果 Mac app 和 iPhone app 分工，MCP 可作为 Mac 端工具服务的协议候选。第三，对“单句多意图”很有帮助：模型输出多个工具调用，执行器逐个校验、排序、回滚或拒绝。

限制与风险：MCP 是通用工具协议，不是车控安全规范。直接把车控能力暴露为 MCP 工具也不能绕过确认、安全等级和状态前置检查。落地建议：第一版只借 schema 和 tool registry 思想；如果后续做 Mac 端辅助服务，再考虑真正接入 MCP Swift SDK。


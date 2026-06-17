# 02 Offline Voice And NLU

## OHF-Voice/hassil

功能说明：`hassil` 是本项目规则快路径最值得优先看的仓库之一。它不是通用大模型，也不是传统统计 NLU，而是基于句式模板的意图识别器。用户说法如果能落入模板，它可以用很低延迟和高确定性输出意图、槽位和匹配结果。对车控场景，这正好覆盖“开空调、关车窗、温度调到 24 度、打开阅读灯”这类高频硬规则。

技术栈与架构：仓库以 Python 为主，带 YAML、配置、测试和文档。架构上核心是 sentence template、slot list、expansion rule、recognition result。它依赖的是可读规则和语料配置，不依赖大模型推理。你的 Swift 端不一定直接嵌 Python，但可以复刻其数据结构：模板、槽位、同义词表、范围值和匹配置信度。

可复用能力点：第一，作为规则快路径的设计蓝本。车控命令里大量句子是可枚举的，先走模板可以避免小模型幻觉和延迟。第二，适合做中文模板体系：`把{zone}空调调到{temperature}`、`{window}开{percent}`、`打开{seat}通风{level}`。第三，它可以承担多意图拆分前的单句识别：先按连接词切分，再对每个子句跑模板。

限制与风险：模板系统对模糊表达覆盖有限，例如“有点闷”“晒得慌”“我看不清了”不一定能被规则理解。中文口语同义词、方言、错字和 ASR 误识别也要自己补。落地建议：第一版把 hassil 思路移植成 Swift 数据驱动 parser；命中高置信模板时直接 function call，未命中再交给 Qwen3/Apple Foundation Models 做语义补全。

## OHF-Voice/intents

功能说明：`intents` 是和 `hassil` 配套的大规模意图句式语料库，本地库存里 YAML 文件超过六千个。它不是车辆专用语料，但它展示了 Home Assistant 这类本地控制系统如何用模板覆盖大量自然语言说法。你的车控功能清单很长，最容易缺的是“每个功能有哪些说法”；这个仓库的组织方式可以直接借鉴。

技术栈与架构：仓库以 YAML 为主，配少量 Python 校验和测试。每个 intent 通常按语言、域、句式、槽位值组织。架构价值在于语料工程：模板不是随便写在代码里，而是作为可审查、可测试、可本地化的资源存在。对你的项目，应该把中文车控话术放进 `resources/intents/zh-CN/*.yaml`，而不是写死在 Swift switch 里。

可复用能力点：第一，复用语料目录结构，把灯光、空调、座椅、车窗、媒体、导航分域管理。第二，复用测试思想：每条模板都要有样例和预期槽位。第三，复用语言扩展方式，未来如果要做英文/中英混说，可以不动核心 parser。

限制与风险：Home Assistant 的智能家居域和车控域不同，不能直接拿语料就用。车控还有位置、区域、安全等级、状态前置条件，例如“行驶中不能执行某些动作”。落地建议：用 `intents` 学 YAML 格式和测试习惯；语料内容自己造，且每条动作绑定 `safety_level` 和 `requires_confirmation`。

## rhasspy/rhasspy

功能说明：Rhasspy 是经典离线语音助手项目，虽然维护状态不是新，但对离线端侧架构仍有参考价值。它覆盖唤醒、录音、静音检测、ASR、NLU、对话管理、TTS、Home Assistant 集成等模块。你的项目不需要完整家居助手，但需要知道离线语音链路有哪些阶段，Rhasspy 正好是一张旧但完整的架构图。

技术栈与架构：本地目录显示大量 `rhasspy-*` 子模块，例如 ASR、NLU、dialogue、wake、microphone、TTS、supervisor，并通过 Hermes 风格消息连接。它是模块化服务架构，而不是单一库。对 iOS/macOS 来说不适合照搬进 app，但可以把链路抽象成：唤醒/按钮触发、录音、VAD、ASR、NLU、对话状态、执行、反馈。

可复用能力点：第一，复用 pipeline 分层，避免把 ASR 和 intent 混在一起。第二，学习离线组件可替换的设计：ASR 可以是 WhisperKit、sherpa-onnx 或 Apple Speech；NLU 可以是规则、Qwen、Foundation Models。第三，学习对话状态管理：车控 Agent 不只是单轮命令，还要处理“调高一点”“再开一档”这种上下文依赖。

限制与风险：Rhasspy 面向 Linux/树莓派/家居生态，iOS 后台、麦克风、唤醒限制完全不同。部分依赖过时，不适合作直接依赖。落地建议：不要 clone 后跑它；读架构即可。你的实现应在 Swift 端用明确状态机重建轻量 pipeline。

## k2-fsa/sherpa-onnx

功能说明：`sherpa-onnx` 是离线语音全家桶，覆盖 ASR、TTS、VAD、关键词唤醒等，并支持 iOS、Android、桌面和嵌入式等多平台。对于“离线、端侧、只支持 macOS/iOS”的目标，它是重要备选：如果 Apple Speech 或 WhisperKit 的中文/离线能力不满足，它可以作为可控的 ONNX runtime 方案。

技术栈与架构：仓库体量很大，C++、C/C++、Python、Kotlin、shell 都很多，说明它既有底层 runtime，也有多语言绑定和移动端示例。架构上是模型运行库 + 平台绑定 + 示例应用。它不是车控 NLU，而是语音基础设施，负责把音频变成文本或把文本转语音。

可复用能力点：第一，离线 ASR 能力，尤其适合做传统语音入口。第二，VAD/端点检测能力，能减少“按钮按下后什么时候停止录音”的工程复杂度。第三，多平台示例可以帮助你评估 iOS 打包体积、模型下载、实时性和电量。

限制与风险：端侧模型体积、中文准确率、iOS 包大小和 Swift 集成成本都要实测。对个人 demo 来说，直接上 sherpa-onnx 可能比 WhisperKit/Apple 原生路线重。落地建议：第一阶段把它列为备选 ASR 引擎；先用 WhisperKit 或系统语音跑通链路，再用 sherpa-onnx 做离线准确率对照。

## ggml-org/whisper.cpp

功能说明：`whisper.cpp` 是 Whisper 的 C/C++ 高性能本地推理实现，支持多平台、Metal、示例和绑定。它适合作为离线 ASR 的底层参考，尤其是在 macOS/iOS 需要本地运行、不能依赖网络语音服务时。和 sherpa-onnx 相比，它更专注 ASR，不覆盖完整语音助手链路。

技术栈与架构：仓库以 C++、C/C++、GPU shader、CMake、Makefile、examples、models、bindings 为主。它的架构是底层推理库 + 平台示例 + 模型转换/下载工具。对 Swift 项目，可以通过现成 Swift 封装或自己写桥接层，但更推荐先看 WhisperKit，因为 WhisperKit 已经面向 Apple 平台包装好了。

可复用能力点：第一，离线语音识别底座；第二，Metal 加速和小模型选择策略；第三，grammar/示例能力可以启发“限制 ASR 结果域”的思路，虽然车控最终仍要靠 intent 层判断。它还适合做 Mac 端基准测试，比较模型大小、延迟、中文识别和热量。

限制与风险：C++ 直接接 SwiftUI 工程有桥接成本，模型管理和多线程音频流也要自己处理。Whisper 对短车控命令未必总优于传统关键词/模板识别，尤其在车内噪声下要实测。落地建议：不要直接把 whisper.cpp 当 app 主库；把它作为 WhisperKit/sherpa-onnx 的底层对照和必要时的 fallback。

## argmaxinc/WhisperKit

功能说明：WhisperKit 是 Swift-native 的 Apple 平台 Whisper 管线，是 iOS/macOS 离线 ASR 的强候选。相比直接用 whisper.cpp，它更贴近你的技术栈：Swift Package、示例、模型管理、Apple 硬件优化和应用集成路径都更顺。对于“只支持 macOS/iOS”的约束，它应当优先实测。

技术栈与架构：仓库以 Swift 为主，带 `Package.swift`、Examples、Tests、脚本和 Fastlane。架构上通常包括模型加载、音频预处理、推理、转写、流式/批式接口和示例 UI。它不是车控 Agent，但可以承担 `SpeechToTextEngine` 的实现。

可复用能力点：第一，作为第一版离线 ASR 引擎候选。第二，学习 Swift 包装方式，减少你自己处理 C++/Metal 细节。第三，结合规则快路径：ASR 输出文本后，优先交给 hassil 风格 parser；低置信或语义模糊再进 Qwen/其他模型。第四，适合用 Mac 端先做性能表：模型大小、首 token 时间、短句识别延迟。

限制与风险：WhisperKit 解决的是转写，不解决唤醒、意图、车控安全和多意图。中文短命令准确率需要实际语料测试，尤其要测试车内噪音、同音词、数字和单位。落地建议：第一版做一个 `WhisperKitSpeechRecognizer` 协议实现，但保留 `AppleSpeechRecognizer` 和 `SherpaRecognizer` 可切换。

## argmaxinc/argmax-oss-swift

功能说明：`argmax-oss-swift` 是 Argmax 相关 Swift 开源包集合，本地库存显示它和 WhisperKit 当前内容非常接近，包含 Swift 源码、Examples、Tests、Package.swift、Makefile。它的价值在于 Apple 端语音/模型工程实践，而不是单独的车控能力。

技术栈与架构：Swift 为主体，配套脚本、示例和测试。它体现了一个面向 Apple 设备的机器学习包如何组织模型、示例、测试、发布流程。对你的项目来说，它可作为工程质量参考：Swift Package 边界、示例应用、模型资源管理、CI/发布脚本。

可复用能力点：第一，复用其 Swift Package 组织方式，把语音模块从主 app 分离。第二，借鉴示例工程结构，做一个最小可运行的 macOS/iOS demo。第三，如果后续使用 Argmax 生态里的 Whisper/TTS/Speaker 能力，可以少走封装弯路。

限制与风险：它不是车控 Agent，也不直接提供 function calling。与 WhisperKit 功能重叠时，要避免重复引入。落地建议：把它列为 Apple speech 工程参考；实际 ASR 选型以 WhisperKit、sherpa-onnx、Apple Speech 三方实测为准。


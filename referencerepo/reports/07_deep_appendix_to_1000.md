# 07 Deep Appendix To 1000

This appendix is meant to be read together with `01` through `06`. Each section extends the corresponding repository report with additional reuse judgment, integration sequencing, and local project implications.

## Bosch-Connected-Experience-26/Canals

补充研判：Canals 最大的启发是“端侧助手不等于一个孤立聊天框”。它把车端 API、KUKSA、缓存、地图、UI、后端和测试放在同一条 demo 链路里，说明车控 Agent 的核心难点是系统编排。你的第一版虽然只装自己手机，但仍要保留类似边界：语音/NLU 只负责产生意图，执行器只负责动作校验和状态写入，UI 只展示状态和轨迹。如果把三者混在 SwiftUI 按钮回调里，初期快，后期一加模糊意图和多意图就会乱。它还提示一个重要策略：先用模拟车端闭环，不直接追求真实车控。你可以把 Canals 当作“完整系统目标图”，但第一版只实现其中 20%：车控能力目录、mock vehicle state、action executor、trace log。这会比直接堆模型更可靠。

## reinhardjurk/agent-tester

补充研判：这个仓库应当被提升为你的评测工作流参考，而不是普通资料。车控 Agent 的质量不是“能回答几句”就够，必须能在固定语料上稳定输出同一个工具调用。尤其你要支持模糊说法和单句多意图，测试集会比模型本身更重要。建议把它启发出的测试体系分三层：规则层测试，只测模板命中和槽位；模型层测试，只测模糊表达转结构；执行层测试，检查工具调用是否被安全策略允许。每条 case 保存输入文本、车端上下文、期望 `ToolCall[]`、是否需要澄清、是否需要确认。这样后续无论换 Qwen3、Foundation Models、MLX 还是 llama.cpp，都能用同一套测试做对比。

## dengky23/nlu-pipeline-vehicle

补充研判：小 NLU 管线的价值在于帮你抵抗“凡事都交给 LLM”的诱惑。车控领域里，高频命令通常短、格式固定、参数有限，传统 NLU 反而更稳定。这个仓库可以启发你建立一个 `IntentNormalizer`：先做中文同义词归一化，再抽槽位，最后映射到 action schema。比如“冷一点”“升两度”“调高温度”都可以先落到 `adjust_hvac_temperature(delta:+2)` 或 `set_hvac_temperature(value:...)`。LLM 应该只处理规则层无法覆盖的表达，例如“有点闷”“阳光太刺眼”。这会降低端侧模型压力，也让 Qwen3-0.6B 的可行性更高。

## weathour/vehicle-offline-voice-android

补充研判：虽然它是 Android 项目，但对移动端体验有直接参考意义。离线车控 app 不能只关注模型输出，还要处理权限、录音状态、识别中断、无网络提示、执行失败、用户取消等细节。这个仓库可以让你检查自己的 SwiftUI 状态机是否完整：idle、listening、transcribing、resolving、confirming、executing、completed、failed。每个状态都应有 UI 反馈和日志。它也提醒你，端侧语音必须和触控入口并存：用户可以点空调/车窗卡片直接执行，也可以语音表达；两者最后进入同一 action executor。这样 demo 才像车控 app，不像语音玩具。

## COVESA/vehicle_signal_specification

补充研判：VSS 应作为你的“内部命名法”，不是可选资料。功能清单越多，越需要统一路径和类型，否则后面会出现“同一个车窗有三个名字”的混乱。建议先从 VSS 中抽取与你第一版相关的子树：Cabin、HVAC、Window、Door、Seat、Light、Infotainment。每个功能清单项都标注 `vss_path` 或 `extension_path`，并记录单位、取值范围和是否可写。LLM 工具 schema 不一定要一条 VSS path 一个工具，可以聚合成领域工具，但参数必须回到 VSS/能力表。这样将来接 KUKSA、CAN provider 或真实车端时，业务层不需要整体改名。

## COVESA/vss-tools

补充研判：`vss-tools` 最适合成为开发期生成器。你可以把它放在 Mac 构建流程里，输出三类资产：给 Swift 用的 enum/struct，给模型用的工具 JSON schema，给人审用的能力表 Markdown。这样同一个功能不会在三个地方手写三遍。第一版不必追求完整自动化，但应建立方向：`capabilities.yaml` 是源，脚本生成 `VehicleCapability.swift` 和 `tool_schemas.json`。未来你有很多功能清单时，这一点会极大省时间。风险在于生成物过度复杂，导致你还没做 app 就陷入 schema 工程；所以首版只生成 20-50 个高频能力即可。

追加落地判断：它还可以承担“规格漂移检查”。当你修改能力清单或补充品牌扩展字段时，生成器应检查重复路径、类型不一致、单位缺失和缺少中文别名。这样模型工具 schema、UI 卡片和测试集都能从同一份源生成。对个人项目这看似重，但一旦功能清单很多，它会比手工维护更省时间。

## eclipse-kuksa/kuksa-databroker

补充研判：KUKSA Databroker 是你的 Mac 开发环境里最值得接入的车端模拟器。iPhone 上第一版可以用内存 mock，但 Mac 上应该有一个可选 broker，用来验证订阅、状态变化和动作执行。尤其多意图场景需要观察连续动作后的状态，例如“打开主驾窗再把空调调到 23 度”执行完应该有两条状态变化和一条 trace。Databroker 还能帮你区分 read 和 write：有些命令只是查询状态，有些是控制动作。建议把它放进第二阶段，不阻塞 UI 原型，但在 action schema 稳定后尽快接入。

追加落地判断：它也可以成为你的自动化验收环境。测试用例执行前写入初始车况，执行语音/文本命令后读取 broker 状态，比较期望结果。这样“模型说执行成功”不会被当成成功，只有车端状态符合预期才算通过。这一点对多意图和上下文命令尤其重要。

## eclipse-kuksa/kuksa-can-provider

补充研判：这个仓库代表真实车端世界的入口，但它也提醒你第一版应该远离真实 CAN。CAN 信号到 VSS 的映射是工程和安全问题，不是 Agent prompt 问题。你现在最该借鉴的是 provider 模式：任何外部数据源都先进入 provider，再变成标准车端状态。未来如果你接 OBD、模拟 CAN、品牌 API 或手写 JSON 状态，都可以实现同一个 `VehicleStateProvider` 协议。这样模型和 UI 永远不知道底层来自 CAN 还是 mock。这个边界能保护项目长期演进，也能降低误控风险。

追加落地判断：它还提示你要做“输入可信度”分层。来自真实 CAN 的状态、来自 mock 的状态、来自用户手动设置的状态，可信度不同。Agent 在解释模糊命令时应知道当前状态来源，例如 mock 状态只用于 demo，不能作为真实安全判断。第一版可以在 `VehicleState` 上加 `source` 字段，为后续真实接入留下位置。

## eclipse-velocitas/vehicle-app-python-template

补充研判：这个 template 的意义在于“项目骨架”，不是 Python 代码。你的 Swift 项目也需要类似结构：`App`、`Domain`、`VehicleRuntime`、`Speech`、`LLM`、`Evaluation`、`Resources`。Velocitas 的开发容器、配置、CI 和 app 入口能启发你把 demo 做成可复跑工程，而不是一次性脚本。由于用户已明确 SDK 首版不用，这个 template 只保留为车端服务样板。后续如果你要在 Mac 上跑一个 local bridge，把 iPhone 的请求转到 KUKSA 或 mock backend，可以参考它的服务化组织方式。

追加落地判断：它还提醒你要把模板和具体业务分开。第一版 Swift 工程也可以准备一个 `FeatureTemplate`：新增一个车控功能时，需要补 capability、intent phrases、tool schema、executor handler、UI card、test cases。这个“新增功能清单”比代码模板更重要，能防止后续功能越加越散。

## eclipse-autowrx/autowrx

补充研判：AutoWRX 对你的最大价值是“能力工作台”思想。你有很多车控车设功能清单，迟早需要一个可浏览、可筛选、可生成 schema 的能力表。如果现在只存在 Excel/文本里，后续模型、UI、测试、执行器都会重复劳动。AutoWRX 展示了前后端如何围绕车辆 API 和原型平台工作。你的第一版不用做 Web 平台，但可以做一个本地 Markdown/JSON 能力目录：每个功能的中文别名、参数、状态依赖、确认策略、VSS 映射、UI 分组都放进去。这会成为后续 roadmap 的核心资产。

追加落地判断：如果你后续要把“很多功能清单”变成 app，最先需要的不是更多模型，而是能力治理。AutoWRX 可以启发一个最小工作台：列表页查看所有 capability，点击查看语音样例和 schema，运行单条测试。这个工作台可以先是 Mac 上的 Markdown/CLI，未来再做 GUI。它会显著加快功能扩展。

## COVESA/vdm

补充研判：VDM 更适合未来复杂车设理解，不适合首版主线。VSS 能解决路径和类型，VDM 能提供实体关系和查询模型。比如“后排有点热”可能涉及乘员区域、座椅位置、空调分区、温度传感器、风量策略；纯路径表难以表达这种上下文。你可以先用 VSS 做执行 schema，用轻量 VDM 思想做解释层：把 zone、component、capability、state、action 作为对象关系。等第一版跑通后，再决定是否需要 GraphQL/VDM 风格能力查询。

追加落地判断：VDM 的更高价值在“让 Agent 查询自己能做什么”。当用户说“帮我调舒服点”，规则层无法直接映射成单一动作，模型需要知道当前有哪些传感器、可控执行器和区域关系。第一版可以不引入 GraphQL，但可以先设计一个简化查询接口：`listCapabilities(zone)`、`getCurrentState(paths)`、`explainCapability(id)`。这会让模糊意图理解不再完全依赖 prompt 记忆，而是依赖可查询能力目录。

## COVESA/vehicle-edge

补充研判：`vehicle-edge` 说明车端数据层不只是 broker，还可能包括事件、分析、边缘部署和多应用消费。对你的个人项目，最小化实现是一个 `VehicleEdge` 协议：读取当前状态、订阅状态变化、执行动作、记录事件。这个协议的实现可以是内存 mock、KUKSA、Mac bridge 或未来真实车端。它能把 UI/Agent 从数据源里解耦出来。建议第一版不要启动复杂 docker-compose，但要保留 edge 概念；否则后面从“静态 demo”升级到“动态车端”时会重构很痛。

追加落地判断：这个仓库还能帮助你定义事件日志。车控 Agent 需要记录的不只是用户原话，还包括 ASR 文本、规则/模型路径、工具调用、执行前状态、执行后状态和错误原因。`VehicleEdge` 可以统一产生这些事件，供 UI 底部轨迹、测试回放和未来调试使用。第一版只要把事件存在本地 JSONL，就能极大提升排错效率。

## OHF-Voice/hassil

补充研判：hassil 应该成为你的规则快路径原型。车控 app 的黄金路径不是 LLM，而是“高频命令 50 毫秒内确定解析”。建议先实现一个 Swift 版迷你 hassil：支持模板、可选词、slot list、数值解析、区域别名和置信度。比如 `把{zone}车窗{open_close}`、`空调{temperature}`、`{seat}座椅通风{level}`。如果命中完整槽位，直接输出工具调用；如果缺槽位，进入澄清；如果完全不命中，再走模型。这样小模型只处理真正模糊的 20% 请求，端侧体验会明显更稳。

## OHF-Voice/intents

补充研判：`intents` 的规模说明模板语料是一项工程，不是随手写几个正则。你的车控中文语料也应按域组织，并持续增长。建议每个功能至少写 5 类说法：直接命令、礼貌说法、模糊表达、参数表达、否定/取消表达。再为每类准备 ASR 容错样例，例如数字、同音词、区域简称。这个仓库还提醒你要有语料校验工具：模板不能互相冲突，槽位名必须存在，样例必须能解析。首版可以只做几十条，但格式要一次定好。

追加落地判断：语料库还应和 UI 能力目录互相生成。比如 UI 有“主驾座椅通风”卡片，那么语料层自动获得 `主驾座椅通风`、`我这边座椅通风`、`开一下通风` 等候选，而测试层自动生成基础 case。这样功能清单增加时，不会忘记语音覆盖。`intents` 的启发不是复制内容，而是建立语料资产的生命周期。

## rhasspy/rhasspy

补充研判：Rhasspy 的模块化能帮你定义离线语音状态机。你不需要它的旧依赖，但需要它体现的“每个环节可替换”思想。建议你的 Swift 架构里至少有这些协议：`AudioInput`、`VAD`、`SpeechRecognizer`、`IntentResolver`、`DialogueState`、`ToolExecutor`、`SpeechFeedback`。第一版可以把 VAD 简化成按钮按住/点击开始结束，但协议保留。这样后续接唤醒词、流式 ASR、TTS 都不会影响车控业务。Rhasspy 还说明离线助手需要配置管理，模型路径、语言、唤醒方式都不能散落在代码里。

## argmaxinc/argmax-oss-swift

补充研判：这个仓库和 WhisperKit 内容接近，适合从工程组织角度学习。你的项目如果长期做 Apple 端离线 AI，最好把语音能力做成独立 Swift Package，而不是直接放主 app。Argmax 的 Examples、Tests、scripts、Package.swift 结构可作为参考。实际选型时，不必同时引入 `argmax-oss-swift` 和 `WhisperKit`；你可以把前者当生态入口，后者当具体 ASR 候选。报告阶段保留二者，是为了区分“Apple 语音工程实践”和“Whisper 转写能力”。

追加落地判断：它也提示你要把模型资源和应用代码分开管理。语音模型通常很大，更新频率和 app 代码不同。第一版自用可以手动放模型，但工程上仍建议做 `ModelRegistry`：记录模型名、语言、大小、hash、默认用途和本地路径。这样后续换 Whisper 模型或增加 TTS，不会污染车控业务层。

## k2-fsa/sherpa-onnx

补充研判：sherpa-onnx 是重型但全面的语音备选。它的存在能降低你对单一 Apple/Whisper 路线的依赖。建议把它放进语音评测矩阵：相同中文车控短句，在 WhisperKit、Apple Speech、sherpa-onnx 上分别测识别准确率、延迟、包体、CPU/GPU、噪声表现。由于它覆盖 VAD、KWS、TTS，未来如果你想做完全离线唤醒和语音播报，它可能比单独拼库更完整。但首版不要急着上，它的集成和模型管理成本明显高于 WhisperKit。

追加落地判断：如果后续要做“传统语音”而不是纯 Whisper 转写，sherpa-onnx 的关键词唤醒和 VAD 能承担更底层的语音前处理。车控短命令不一定需要长文本 ASR，有时关键词 + 槽位识别更快。建议评测时不要只看整句 WER，还要看车控槽位准确率，例如温度、区域、档位、百分比。这比通用识别分数更贴近你的产品目标。

## ggml-org/whisper.cpp

补充研判：whisper.cpp 更像底层可靠性保险。很多 Swift/Apple 语音库底层或思想都能追溯到它，因此读它能帮助你理解模型文件、采样率、线程、Metal、streaming 的真实成本。第一版如果用 WhisperKit，仍建议保留 whisper.cpp 作为 Mac 端命令行对照：同一段音频用 whisper.cpp 跑一遍，确认识别问题来自模型、封装还是你的音频采集。它也能支持离线批量生成语料转写，用来做测试集扩充。但 iOS app 里不要先直接集成它，除非 WhisperKit 无法满足。

追加落地判断：它还适合做“语音数据工厂”。你可以录一批真实中文车控音频，用 whisper.cpp 批量转写，再人工修正成评测集。这样比直接手写文本更贴近 ASR 误差。后续规则 parser 和模型 resolver 都应在“真实 ASR 输出”上测试，而不是只在干净文本上测试。这个步骤会提前暴露同音词、数字和区域词的问题。

## argmaxinc/WhisperKit

补充研判：WhisperKit 最适合作为第一版 ASR 主候选。它贴近 SwiftUI、iOS/macOS 和 Apple Silicon，能让你把注意力放在车控语义层，而不是 C++ 桥接。建议做一个独立 spike：录制 50 条中文车控命令，测试 small/base/tiny 等模型的转写质量和延迟，再决定默认模型。需要特别测试数字、百分比、左右/前后/主驾副驾、温度单位。转写结果进入规则 parser 前，最好做轻量文本归一化：中文数字、空格、标点、同音错字候选。WhisperKit 只解决听写，不解决理解。

追加落地判断：首版集成时应把 WhisperKit 包在 `SpeechRecognizer` 协议后面，并记录原始音频路径、转写文本、耗时和置信信息。这样当用户发现命令执行错了，可以回放判断是 ASR 错还是 NLU 错。车控语音调试没有这层记录会非常痛苦。

## ggml-org/llama.cpp

追加深度研判：llama.cpp 应该作为底层能力天花板和 fallback，而不是第一天的产品架构中心。它提供 GGUF、Metal、量化、server、grammar 等能力，几乎能覆盖本地 LLM 原型的所有底层问题；但也因此很容易把项目拖进编译、模型格式和桥接细节。对你的目标，建议分两步用：Mac 端先用 server/CLI 验证 Qwen3 function call，iOS 端只在 MLX 或 Foundation Models 不满足时再嵌入。关键是业务层永远只看 `LLMBackend` 协议，不看 llama.cpp 类型。

追加落地判断：它的 grammar/JSON 能力应重点研究，因为这关系到车控安全。自由生成中文解释不能执行，必须输出工具调用数组。你可以用 llama.cpp 在 Mac 上先验证 grammar 是否能稳定限制 Qwen3-0.6B 输出，再决定是否值得移植到 iOS。如果 grammar 下小模型仍经常参数错，那问题不是 runtime，而是模型能力或 schema 太复杂。

## wizcheu/iOSLLMFrameworkBenchmark

补充研判：这个 benchmark 对 Qwen3-0.6B 路线非常关键。你现在的风险是被“0.6B 很小”这句话框住，但端侧实际体验取决于模型格式、量化、上下文、tokenizer、系统内存和后台限制。建议你把它作为第一阶段必须复跑的实验：同一台目标 iPhone 上，比较 MLX Swift、llama.cpp、可能的 MLC 后端，记录冷启动、连续生成、结构化输出成功率。没有这个数据，roadmap 容易变成愿望清单。它还可以帮助你决定是否先用 Apple Foundation Models 做 baseline。

## mattt/llama.swift

补充研判：`llama.swift` 的“小”反而是优点。它不是大而全框架，适合让你快速理解 Swift 调 llama.cpp 的最小路径。建议把它作为 GGUF 路线 spike 的入口：在 macOS app 或命令行里加载一个 Qwen3-0.6B GGUF，跑 20 条 function call 样例，看 grammar/JSON 约束是否可用。若它缺少你需要的能力，再决定是否直接接 llama.cpp 或换 LocalLLMClient。不要期待它提供产品级状态管理；它只是桥。

追加落地判断：这个桥接层如果被采用，务必封在 `LlamaCppBackend` 内部，不要让 ViewModel 直接依赖它。车控 app 需要处理取消、超时、模型未加载、输出不合规等状态，小 wrapper 通常不会全部覆盖。你可以先用它完成本地模型可用性验证，再把缺失能力补在自己的 backend 层，而不是 fork 它做大改。

## StanfordSpezi/SpeziLLM

补充研判：SpeziLLM 的价值在应用层抽象。你的项目虽然是个人 app，但最好从第一天就把模型 provider 抽象出来，因为 Apple 端模型能力变化很快。今天可能是 Qwen3 + MLX，明天可能 Foundation Models 足够好，后天可能 Mac 端代理更稳。SpeziLLM 可以启发你设计 provider、message、response、stream、error 类型。尤其是车控场景，模型失败不应让 UI 崩溃；provider 层必须返回可分类错误：模型未加载、输出不合规、超时、拒绝、需要澄清。

## ml-explore/mlx-swift-lm

补充研判：这是 Apple-only 路线的核心候选。它的战略意义在于减少跨语言和跨格式成本：Swift 调 Swift，MLX 跑 Apple Silicon，模型管理也更接近 Apple 生态。你应优先验证 Qwen3-0.6B 是否能在 `mlx-swift-lm` 路线上稳定运行。如果能跑通，再看结构化输出如何约束；如果不能，则转 llama.cpp/GGUF。需要注意，MLX 适配和模型转换可能比想象中花时间，所以 roadmap 里应把“runtime spike”放在 UI 大开发之前。先确认模型能跑，再谈 Agent。

追加落地判断：MLX 路线还应和 Foundation Models 做基线对照。如果系统模型能以更低工程成本完成车控 function call demo，那么 Qwen3 可以暂时作为可控/可微调路线保留，而不是首版强上。反过来，如果 Foundation Models 系统版本门槛太高或不可控，MLX Swift 才是自带模型的主路。这个判断必须通过同一套车控测试集得出。

## huggingface/swift-transformers

补充研判：这个仓库的最大价值是补齐 tokenizer 和模型资产管理。很多端侧 LLM 项目失败不是推理库不行，而是模型文件、tokenizer、配置、下载、校验、缓存混乱。Hugging Face Swift 生态能帮助你建立“模型包”概念：模型 ID、版本、tokenizer、权重路径、校验 hash、所需 runtime、内存估计。即使最后不用它推理，也可以借它的资源组织方式。对个人安装场景，建议模型文件不要运行时从网络拉，而是在 Mac 开发期准备好，再通过本地 bundle 或文件导入。

追加落地判断：它还适合服务“开发效率”。你可以在 Mac 工具链里写一个 `prepare-model` 命令：下载模型、校验 tokenizer、转换格式、生成 manifest。iOS app 只读 manifest，不关心下载细节。这样未来替换 Qwen3 版本或测试其它小模型时，不会手动复制文件出错。模型准备和 app 运行分离，是端侧 AI 工程的基本卫生。

## tattn/LocalLLMClient

补充研判：LocalLLMClient 很适合做你的 runtime 抽象参考，优先级应高于单个底层引擎。它体现的思路是：业务层只知道“我要生成结构化语义”，不关心底下是 llama.cpp、MLX 还是 Foundation Models。你的项目可以复制这种精神：`LocalLLMClient` 下游接不同 engine，上游接 `IntentResolver`。这样当 Foundation Models 在 macOS/iOS 新系统上表现足够好时，你可以一天内切成 baseline，而不用改车控业务。截图里对 Foundation Models 的提醒也正好支持这种策略。

追加落地判断：它还适合作为“不要过早押注 Qwen3”的提醒。Qwen3-0.6B 可以是主探索线，但你的 app 业务层应该只依赖 `resolveIntent(text, context) -> Resolution`。runtime facade 让你同时接本地 Qwen、系统模型和 mock provider。这样 roadmap 可以先做功能闭环，再用数据决定模型路线，而不是被某个模型框死。

## qualcomm/nexa-sdk

补充研判：Nexa SDK 不一定会进你的 Apple app，但值得研究它如何把本地模型能力包装成 SDK 和 CLI。端侧 AI 项目要想开发效率高，最好先有 CLI：输入一句中文车控命令，输出 JSON 工具调用，附带模型耗时和解析状态。Nexa 的 CLI/SDK/绑定/示例组织能给你这方面参考。它还提醒你，不同硬件生态都在推本地小模型 function calling；你的差异化不在“我也能跑模型”，而在车控能力目录、规则快路径和安全执行链路。

追加落地判断：它的多语言、多平台目录也提示你不要把“端侧 SDK”想得太轻。真正可用的 SDK 通常包含模型下载、运行时选择、示例、错误处理、工具接口和文档。你的项目虽然个人使用，也可以采用缩小版：一个 Swift package 暴露核心能力，一个 Mac CLI 做调试，一个 iOS app 做体验。这样开发效率会比单 app 工程高。

## mozilla-ai/llamafile

补充研判：llamafile 对你是 Mac 原型加速器。iOS 端模型接入可能受系统、签名、包体和性能限制；Mac 上用单文件 runtime 起 server，可以先把 prompt、schema、工具调用、评测集全部跑通。这样 UI 和语义层不会被 iOS 打包卡住。建议把它列为 `dev-runtime`，不是 `app-runtime`。开发流程可以是：Mac llamafile/llama.cpp server 跑 Qwen -> 生成 ToolCall -> Swift app mock 调用；等语义稳定，再替换为 iOS 本地 engine。

追加落地判断：它也适合作为“外部基准”。当 iOS 本地模型表现差时，需要判断是模型本身不行，还是 iOS runtime/量化/上下文设置不行。用 llamafile 在 Mac 上跑同模型同 prompt，可以快速定位。如果 Mac 上也不行，说明语料、schema 或模型能力不足；如果 Mac 上行而 iOS 不行，问题才在移动端 runtime。

## MadeAgents/Hammer

补充研判：Hammer 的补充意义在小模型工具调用数据。你如果要微调或做少样本提示，最缺的不是框架，而是高质量样例。Hammer 可以帮助你观察小模型工具调用样例通常怎么写：工具描述多长、参数如何表达、输出格式如何固定、错误样例如何构造。对车控来说，建议先不要大规模微调，而是手工写 100 条黄金样例，覆盖模糊、组合、拒绝、澄清。等规则 + prompt + schema 仍不够，再考虑微调。

追加落地判断：Hammer 还可以放在“数据格式对照”里，与 BFCL 和 tiny-tool-bench 合并观察。你的车控样例应该同时服务三件事：prompt few-shot、评测 gold set、未来微调数据。三者格式最好同源，避免维护三套。第一版就把每条样例写成输入、上下文、工具定义、期望输出、错误标签，会为后续模型优化省很多时间。

追加取舍建议：Hammer 不应推动你马上训练模型，而应推动你先设计数据合同。只有当规则和 prompt 都证明不够，并且错误集中在可学习模式上，微调才值得做。否则更快的改法通常是收窄工具集、加强 schema、补模板或加澄清策略。

## ShishirPatil/gorilla

补充研判：官方 Gorilla/BFCL 是你的 function call 评测标尺。你需要从它借三个东西：任务定义、评估器、错误分类。车控领域可以做一个 BFCL 子集：工具集固定为 `set_hvac`、`adjust_temperature`、`set_window`、`set_seat`、`set_light`、`query_vehicle_state` 等；输入是中文口语；输出是 JSON 数组。错误分类至少包括工具错、参数错、漏调用、多调用、顺序错、应拒未拒、应澄清未澄清。这样你能清楚知道 Qwen3-0.6B 是“听不懂”还是“格式不稳”。

## javierlimt6/tiny-tool-bench

补充研判：Tiny-tool-bench 要和 BFCL 互补看。BFCL 是通用权威评测，tiny-tool-bench 更接近小模型现实。你的项目不需要追求大模型 benchmark 排名，而要知道小模型在有限工具集上能不能稳定工作。建议把工具数量控制在第一版 10 个以内，每个工具参数不超过 5 个，并用 tiny-tool-bench 思路测试工具数增加后的准确率下降。它会帮你做产品取舍：不是功能越多越好，而是可稳定执行的功能才应该进入语音入口。

追加落地判断：它尤其适合决定“规则和模型的分工”。如果小模型在 10 个工具上稳定，但 30 个工具明显下降，就不应该把所有车设功能都暴露给模型。可以让规则层覆盖大量确定命令，模型层只看到一个较小的候选工具集。候选工具集可由当前 UI 页面、车辆状态和关键词初筛得到，这比把完整功能清单塞给 0.6B 更现实。

## noamgat/lm-format-enforcer

补充研判：格式约束是车控安全的一部分。即使模型理解对了，如果输出不是严格 JSON，也不能执行。lm-format-enforcer 的思想可以转成 Swift 端三道门：生成时尽量约束，解析时严格解码，执行前做业务校验。尤其多意图输出必须是数组，不能让模型用自然语言描述“先开窗再调温”。如果 runtime 不支持 token 级约束，就用后处理加重试，但重试次数要有限，避免车内交互卡顿。最终原则是：结构不合法，宁可问用户，也不猜。

## dottxt-ai/outlines

补充研判：Outlines 强调 schema-first，这对你整理大量功能清单很关键。建议不要先写 prompt，而是先写类型：`VehicleCommandResolution`、`ToolCall`、`ToolArguments`、`Clarification`、`Refusal`。然后再让模型填这些类型。这样 prompt 和评测都围绕结构展开。Outlines 的 Python 生态可用于 Mac 端快速实验：同一批中文命令，尝试不同 schema 粒度，看看小模型在哪种结构下最稳。实验结果再回写 Swift schema，避免凭感觉设计。

追加落地判断：Outlines 还能帮助你找到 schema 的复杂度边界。比如把所有车控动作放一个巨大 union，可能让小模型混乱；按域拆成 HVAC/Window/Seat/Light 可能更稳。你可以用它快速做离线实验，再把最佳 schema 固化进 Swift。这个实验应在 UI 开发前完成，否则后面会因为 schema 改动牵连大量界面和测试。

## guidance-ai/guidance

补充研判：Guidance 的启发是把推理流程程序化，而不是一条长 prompt 包打天下。车控多意图可以拆成：识别是否车控域、分句、解析每个子句、合并冲突、检查安全、输出工具调用。小模型未必能一次完成全部步骤，但规则层和程序化流程可以分担。你可以在 Swift 里实现类似 guidance 的硬流程，模型只负责某个步骤的语义补全。这样端侧 0.6B 更有机会稳定工作，也更容易解释错误。

追加落地判断：对你的项目，guidance 的“可控流程”比库本身更重要。建议把多意图处理写成显式 pipeline：文本归一化 -> 子句切分 -> 每子句候选意图 -> 冲突检测 -> 工具调用输出。模型只在候选意图不足时介入。这样即使模型偶尔输出怪结果，也只影响一个步骤，不会直接控制车辆状态。

追加工程建议：不要让模型一次性决定安全策略。安全检查应是程序代码：速度、车门、行驶状态、动作风险、是否需要确认都由 executor 判断。模型最多提出候选动作，不能越权执行。这个分层比任何 prompt 约束都可靠。

## instructor-ai/instructor

补充研判：Instructor 代表“模型输出必须被类型系统接住”。Swift 端对应做法是 `Codable` + enum + validator。每个参数都要有类型和范围：温度 16-30、窗户百分比 0-100、座椅档位 0-3、区域枚举不能随便造。模型输出如果不在范围内，执行器不修正、不猜测，而是进入澄清或拒绝。Instructor 的 retry 思路可以借鉴，但车控交互不宜无限重试。建议最多一次模型修复；仍失败就给用户简短反馈。

追加落地判断：它还提醒你要把错误变成产品状态。`decode_failed`、`unknown_tool`、`invalid_argument`、`unsafe_action`、`needs_clarification` 应该是明确枚举，而不是日志字符串。UI 可以根据错误类型显示不同反馈；测试也可以统计错误分布。这样你能知道下一步该补语料、改 schema、加规则，还是换模型。

## alexa/alexa-auto-sdk

补充研判：Alexa Auto SDK 能提醒你商业车载语音助手的复杂度，也能帮你确定首版边界。你不需要认证、云服务、媒体全栈、电话、导航全链路，但你需要 capability agent 结构。建议把车控功能拆成小 agent：`HVACAgent`、`WindowAgent`、`SeatAgent`、`LightAgent`、`MediaAgent`。每个 agent 暴露工具 schema、状态读取、执行校验和 UI 卡片数据。这样未来加功能不会污染主路由。它还说明语音助手必须有日志和诊断；个人 demo 也要保留执行轨迹。

## shawnq-msft/azure-voice-live-for-car-android

补充研判：这个仓库是 UX 参考，不是技术路线。它能帮助你确定第一屏应该展示什么：车控状态卡片、语音入口、识别文本、执行轨迹，而不是单纯聊天窗口。车控 app 的用户目标是“看到状态并改变状态”，所以 UI 要以车辆功能为中心。建议首版页面包含空调、车窗、座椅、灯光、媒体五组卡片；语音执行后卡片实时变化，并在底部显示 tool trace。Azure 在线语音能力不应进入你的离线目标，但它的 demo 组织方式可借。

追加落地判断：它也能提醒你做“可演示路径”。第一版 demo 应准备 10 条固定语音/文本命令，覆盖直接控制、状态查询、模糊意图、多意图、拒绝执行。每条执行后 UI 都有明显变化。这样你在自己手机上展示时，不依赖模型临场发挥，也能快速暴露链路问题。线上 Azure 能力不复用，但 demo 编排思路可以复用。

## modelcontextprotocol/swift-sdk

补充研判：MCP Swift SDK 是工具协议层的重要参考。你的车控 function call 不应只是模型输出的 JSON 字符串，而应有一个工具注册表：工具名、描述、输入 schema、输出 schema、错误类型、权限级别、是否需要确认、执行函数。MCP 的 client/server、tool/resource/prompt 结构能启发你把这些东西协议化。第一版不必真的启动 MCP server，但可以按 MCP 思路设计 `ToolRegistry`，这样未来 Mac 端和 iPhone 端拆分时，工具层有升级通道。

追加落地判断：它还适合未来“Mac 开发助手 + iPhone 控制端”的形态。Mac 上可以运行模型、KUKSA mock、能力目录和评测工具；iPhone 只负责 UI 和本地轻推理。MCP 可以成为两者之间的工具/资源协议候选。即使现在不接，报告里保留这个仓库是合理的，因为它代表 Swift 生态里较标准的工具协议实现方向。

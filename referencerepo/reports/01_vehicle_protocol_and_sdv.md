# 01 Vehicle Protocol And SDV

## Bosch-Connected-Experience-26/Canals

功能说明：Canals 是这批仓库里最接近“车控 Agent 原型”的项目。它不是一个纯语音库，而是把前端、后端、KUKSA、车辆 API、地图/缓存、基础设施和端到端测试放在一个完整演示里。目录里有 `app`、`backend`、`car-api`、`kuksa`、`ui`、`e2e`、`structurizr` 等模块，本质是一个车内助手/车端服务编排样例。对你的项目来说，它的价值不是直接复用 UI，而是观察“语音/Agent 请求如何落到车端状态读取和动作执行”。

技术栈与架构：本地库存显示 Python 文件最多，同时带 Docker、前端 UI、KUKSA 目录和多服务结构，说明它偏服务编排型原型。架构上可以拆成三层：交互入口层、业务后端层、车端数据/控制层。它更像云端或边缘车机演示，不是 iOS 端离线 app 的轻量架构；但它把车控域里的上下文、工具调用、车辆状态、地图辅助等概念串起来了。

可复用能力点：第一，复用其功能分层思路：语音输入不直接控制车窗/空调，而是先进入后端 intent/action 层，再映射到车 API。第二，复用端到端测试意识：车控 Agent 最危险的是“识别到了但动作错了”，所以需要命令输入、工具调用、车端状态变化的链路记录。第三，参考其 KUKSA/VSS 接入方式，把你的 demo 车控功能先落到模拟 broker，而不是直接绑定真实车辆。

限制与风险：它的依赖和部署明显重于你的个人 iOS/macOS 离线 app。前端/后端/Docker/KUKSA 全栈不宜直接搬进 Swift 客户端。它适合作“车控 Agent 系统边界参考”，不适合作第一版代码底座。落地建议：只抽象三件事进你的项目：`VehicleStateStore`、`VehicleActionExecutor`、`AgentTrace`。用它校准动作链路，不要照搬架构。

## reinhardjurk/agent-tester

功能说明：`agent-tester` 是面向车载语音助手/Agent 的测试框架。仓库文件量不大，YAML 占比高，Python 作为执行胶水，说明它主要通过用例声明、期望输出和工具调用轨迹来评估 Agent。你的需求里有快速 function call、模糊意图、多意图单句，这类能力不能只靠“肉眼试几句话”验收，必须有测试集和判定规则；这个仓库正好提供了这种方向。

技术栈与架构：核心形态是 YAML 测试资产 + Python runner。YAML 用来表达用户语句、上下文、目标工具或目标动作；Python 用来驱动被测 Agent 并比较结果。它不关心具体 ASR 或模型 runtime，更像评测外壳。对你的 macOS/iOS 项目，可以把它改造成离线回归集：一边是中文口语命令，一边是标准化 function call JSON。

可复用能力点：第一，测试数据格式可以直接借鉴：一句话、上下文、期望意图、期望槽位、是否允许多动作。第二，复用其“用例驱动 Agent 质量”的方法，把规则快路径、Qwen 模糊理解、结构化输出分别打分。第三，对多意图命令尤其有用，例如“把空调调到 24 度再开座椅通风”必须检查输出顺序和幂等性。

限制与风险：它不是中文车控语料库，也不是 iOS 测试框架，不能直接解决语音识别或模型调用。你需要自己定义车控 action schema 和中文样例。落地建议：第一版就建立 `tests/intents/*.yaml`，至少覆盖空调、车窗、座椅、灯光、媒体、导航六类；每条都输出统一 `ToolCall[]`，这样后续换 Qwen、Foundation Models 或规则引擎时不会改业务层。

## dengky23/nlu-pipeline-vehicle

功能说明：这是一个小型车载 NLU 管线仓库，本地只有十几个文件，Python 为主，适合读它的结构而不是期待生产级能力。它关注车载语音中的意图识别、槽位抽取、实体标准化和测试。你要做的是“传统语音 + 规则快路径 + 小模型模糊理解”，这类小 NLU 管线可以作为规则层和模型层之间的中间表示参考。

技术栈与架构：仓库以 Python 脚本和测试为主，典型结构是输入文本进入分词/分类/槽位抽取，再输出领域动作。它没有复杂 runtime，也不依赖重型模型。这种轻量架构适合转译成 Swift 端的 deterministic parser：关键词、同义词、数值单位、目标部件和动作类型先做硬解析，解析不完整时再交给 Qwen3-0.6B 或 Foundation Models。

可复用能力点：第一，借鉴其“意图 + 槽位 + 归一化”的三段式，不要让 LLM 直接吐自然语言。第二，车控中文尤其需要归一化：`冷一点`、`温度降两度`、`空调小点` 应落成不同 action 或参数变化。第三，它适合支持你的快路径：高置信模板直接走规则，不进 LLM；低置信或跨域才进模型。

限制与风险：项目很小，覆盖面和维护度都不足，不适合作长期依赖。它的价值是方法样本，而非库。落地建议：把你的功能清单整理成 `intent_id`、`slots`、`canonical_action` 三表；从这个仓库借鉴测试风格，自己构建中文车控语料。第一版只做 30-50 个高频意图，避免先陷入泛化模型训练。

## weathour/vehicle-offline-voice-android

功能说明：这是离线车载语音 Android 参考，Kotlin 文件最多，带 Protocol Buffers 和移动端资源。它与目标平台不同，但方向非常贴近：离线语音、车载命令、端侧处理、车辆状态集成。对你来说，它最值得借鉴的是移动端工程分层，而不是 Android 代码本身。

技术栈与架构：项目以 Kotlin 为主体，说明其核心在 Android App 层。Protocol Buffers 表明它可能有内部消息或车端状态协议。架构可理解为：麦克风/语音入口、离线识别或命令解析、车控状态/动作模块、UI 展示。Swift 端可以映射成 `SpeechCapture`、`IntentRouter`、`VehicleStore`、`ControlViewModel` 四块。

可复用能力点：第一，离线优先的权限和状态处理值得看：麦克风、唤醒、识别中、执行中、失败反馈，都要在 UI 上有确定状态。第二，移动端车控不能只做“聊天框”，需要按钮和状态卡片作为低风险入口；这个仓库能辅助你设计语音和触控双入口。第三，Protocol Buffers 如果设计清晰，可借鉴为 Swift 里的动作协议。

限制与风险：Android 生态里的音频、后台、权限和 iOS 差异很大，不能直接移植。离线 ASR 模型、唤醒词、车端模拟也可能过时。落地建议：用它做“移动端离线语音车控流程图”的参考；实现上仍应走 SwiftUI + Apple Speech/WhisperKit/sherpa-onnx + 本地 action schema。

## COVESA/vehicle_signal_specification

功能说明：VSS 是车端信号命名和语义标准，是这批仓库里最应该成为你项目“车控语义底座”的部分。它定义车辆里的信号路径、类型、单位、读写属性和树状结构。你如果有大量车控/车设功能清单，最容易走偏的是每个功能自己起名字；VSS 可以把 `Vehicle.Cabin.HVAC`、`Window`、`Seat`、`Light` 等域统一到标准路径。

技术栈与架构：仓库以 `.vspec`、Markdown、YAML、图片和 Makefile 为主，说明它是规格库，不是 runtime。它的核心是树状信号定义和文档生成。对你的 app 来说，VSS 不应该进 UI 直接展示，而应变成内部 canonical schema：用户说“副驾窗开一半”，最终落到某个 signal/action path 和参数。

可复用能力点：第一，复用命名体系，减少后续接真实车或模拟 broker 时的重构。第二，复用数据类型和单位：温度、百分比、枚举状态、布尔开关都需要标准化。第三，用 VSS 把“读状态”和“写动作”分开，避免模型自由生成危险动作。

限制与风险：VSS 覆盖的是通用车辆信号，不一定包含所有品牌车设或个性化功能。它也不提供中文意图和 function call 规范。落地建议：第一版建立 `VehicleCapability` 表，字段包括 `vss_path`、`readable`、`writable`、`value_type`、`unit`、`safety_level`、`aliases_zh`。你的功能清单先映射到 VSS，映射不到的放扩展命名空间。

## COVESA/vss-tools

功能说明：`vss-tools` 是 VSS 的转换、校验和生成工具链。相比直接读 VSS 规格，它更适合帮助你把 `.vspec` 转成 app 可消费的 JSON、TypeScript、代码或文档资产。对于个人 macOS/iOS 项目，手写 100 多个车控字段非常容易出错；这个工具链可以让你从规格自动生成 Swift 内部枚举或 JSON schema。

技术栈与架构：本地库存显示 Python 文件、`.vspec`、YAML、JSON 都很多，并带 `pyproject.toml`。这说明它是 Python 工具包，负责解析 VSS 规格、校验树结构、输出不同格式。它不属于 app runtime，应该作为开发期工具使用：在 Mac 上生成静态资产，再打包进 iOS/macOS app。

可复用能力点：第一，复用解析/验证流程，把 VSS 转成你的 `vehicle_capabilities.json`。第二，复用测试资产，保证自定义扩展不破坏信号树。第三，生成模型 function schema：每个 writable signal 可以生成一个工具或聚合工具参数，供 LLM 受约束调用。

限制与风险：Python 工具链不适合直接放到 iOS app 内运行；自动生成的 schema 也不能替代产品级安全判断。落地建议：把 `vss-tools` 放在开发流水线，输出 Swift 代码和 JSON；app 内只读取静态产物。这样你既能借标准，又不增加端侧 runtime 负担。

## eclipse-kuksa/kuksa-databroker

功能说明：KUKSA Databroker 是车端数据 broker，可基于 VSS 管理车辆状态、订阅和执行相关接口。它对你的项目价值很高：在没有真实车的情况下，提供一个“模拟车端状态和动作”的后端目标。你的离线 app 第一阶段不应该直接碰真实车辆控制，而应该通过本地/局域网 mock broker 验证 action schema。

技术栈与架构：仓库以 Rust 为主，带 `Cargo.toml`、proto、文档、集成测试和 VISS/KUKSA 协议相关代码。架构上它是一个中间层：provider 写入车辆数据，consumer 读取/订阅/请求动作。对你来说，Swift app 可以把它当作开发期 mock 车，而不是把 Rust broker 嵌进手机。

可复用能力点：第一，复用其 VSS broker 思路：你的 `VehicleStore` 不应只是本地变量，而应有可替换 provider。第二，复用订阅模型：UI 状态、语音反馈、Agent 上下文都要从车端状态读。第三，用它验证 function call 执行后状态是否改变，形成自动回归测试。

限制与风险：Databroker 是服务端组件，对个人 iPhone 离线安装来说偏重。真实车辆 actuator 权限、安全策略和品牌协议另算。落地建议：Mac 开发期启动 KUKSA，iOS app 连接 mock；纯离线演示时用 Swift 内存版 `VehicleStore`。接口层保持一致，后续可切换 broker。

## eclipse-kuksa/kuksa-can-provider

功能说明：`kuksa-can-provider` 负责把 CAN 总线数据和 KUKSA/VSS 世界连接起来。对你的第一版离线车控 Agent，它不是必须组件，但它能告诉你真实车端接入时的关键问题：低层 CAN 信号需要映射、解码、归一化，不能让语音 Agent 直接面对 CAN frame。

技术栈与架构：仓库 Python 文件较多，带 JSON、`.vspec`、YAML 和文档。典型结构是读取 CAN 数据、按配置解码、写入 KUKSA Databroker。它是 provider，不是用户交互层。架构价值在于“低层信号到语义信号”的适配边界。

可复用能力点：第一，复用 mapping 思路：你可以把品牌功能清单映射到 VSS 或自定义 schema，而不是把品牌原始字段暴露给 Agent。第二，复用配置驱动：车控能力变化应改配置，不应改意图识别代码。第三，后续接 OBD/CAN 模拟器时，它能作为技术路线参考。

限制与风险：第一版不建议接真实 CAN，也不建议把该 provider 作为必选依赖。真实车辆安全、授权、硬件、法律风险都远超个人 demo。落地建议：现在只看配置和映射设计；第一版用 fake provider，实现“车窗位置、空调温度、座椅通风”等少量状态。

## eclipse-velocitas/vehicle-app-python-template

功能说明：这是 Velocitas 的车辆应用模板，用于快速创建连接车辆数据层的 Python 应用。用户明确指出 `vehicle-app-python-sdk` 首版不必上，我也已删除；但 template 仍有参考价值，因为它展示了 SDV 应用如何组织入口、配置、容器、开发环境和车辆服务访问。

技术栈与架构：仓库以 YAML、shell、Markdown、JSON 为主，带 `app`、`.devcontainer`、GitHub workflow 等。它不是功能库，而是项目骨架。架构上强调开发容器、配置、服务连接和 app 目录边界。对 Swift 项目来说，不能直接复用代码，但可以复用项目组织思想。

可复用能力点：第一，借鉴“车辆 app 与车辆数据接口分离”的目录边界。第二，借鉴开发环境可复跑：你的 Mac 端也应有一键启动 mock vehicle backend 的脚本。第三，借鉴模板化：未来功能清单很多时，可通过生成器创建 action handler 和测试。

限制与风险：Python template 离你的 iOS/macOS 客户端距离较远，直接移植收益低。落地建议：只把它作为“车端适配服务”的参考；如果你的 app 后期需要 Mac 上跑一个本地 bridge，再考虑借鉴其容器化和配置方式。

## eclipse-autowrx/autowrx

功能说明：AutoWRX 是 SDV 原型平台，和 digital.auto 风格接近，重点在车辆能力 API、原型开发、前后端工作台。它适合用来研究“功能清单如何变成可视化 API/能力目录”，尤其当你有很多车控车设功能时，需要一个能力注册表，而不是把功能散落在代码里。

技术栈与架构：本地库存显示 TypeScript、JavaScript、Markdown、JSON 较多，目录包括 `frontend`、`backend`、`docs`、`scripts`、`instance-setup`。它是 Web 工作台 + 后端服务的形态。对你的个人 app，不能直接引入，但它的 API catalog、能力建模、原型验证流程值得参考。

可复用能力点：第一，能力目录（capability catalog）思想：每个车控功能都应有名称、参数、状态依赖、风险等级、UI 显示、语音别名。第二，原型到协议的流程：先用 mock API 验证交互，再绑定真实数据。第三，可以参考其前后端分工，帮助你把 Mac 端开发工具和 iOS 端体验分开。

限制与风险：这是偏平台型项目，体量超过你的首版。落地建议：不要复制 Web 平台；抽出一个 `capabilities.yaml/json`，作为你的车设功能单一事实来源。后续报告和 roadmap 可以围绕这个能力目录展开。

## COVESA/vdm

功能说明：VDM 是 COVESA 面向车辆数据模型的项目，和 VSS 有关系但层级更偏语义模型。库存显示大量 GraphQL 文件，说明它关注数据模型和查询结构，不只是路径树。对于你的 Agent 项目，它是“第二阶段语义建模”的参考：当 VSS 路径不能表达复杂关系时，可以看 VDM 的建模方式。

技术栈与架构：仓库含 `.graphql`、YAML、Markdown、JSON，并有 `pyproject.toml` 和 `package.json`，说明同时有 Python/Node 工具。架构上更像 schema/model 仓库，用 GraphQL 表达车辆数据实体、关系和查询能力。它不适合第一版 runtime，但适合做能力目录的长期升级方向。

可复用能力点：第一，复用实体关系思想：座椅、区域、空调、乘员、传感器并不只是扁平字段。第二，复用 GraphQL 风格的可查询模型，未来可以让 Agent 先查询能力和状态，再决定工具调用。第三，适合做“车设知识层”，补足纯 VSS 对复杂功能解释不足的问题。

限制与风险：VDM 仍在演进，直接绑定会增加复杂度。落地建议：首版仍用 VSS + 自定义能力表；VDM 只作为后续语义层参考。不要为了“模型更完整”牺牲第一版可跑通。

## COVESA/vehicle-edge

功能说明：`vehicle-edge` 关注车端数据源和应用之间的边缘层。它的价值在于提醒你：即使 app 离线运行，也应该有一个清晰的 edge abstraction，把车辆数据、事件、分析、应用接口隔离开。你的项目如果只在 SwiftUI 里写状态变量，后面扩展到真实车辆会很难。

技术栈与架构：仓库里 JSON、Markdown、JavaScript、YAML 较多，目录包含 `setup`、`docs`、`howto`、`docker-compose`、`src`、`iot-event-analytics`。它是边缘服务/部署参考，不是移动端 SDK。架构上强调数据源、处理管线、应用消费之间的边界。

可复用能力点：第一，复用“边缘层”概念，在你的 Mac 开发环境中实现 `VehicleEdgeMock`。第二，事件驱动：车辆状态变化不一定来自用户命令，也可能来自外部模拟器或传感器。第三，给 Agent 上下文提供统一读接口，避免每个功能单独读状态。

限制与风险：体量和部署方式偏重，iOS 离线 app 不适合内置。落地建议：把它作为架构边界参考；第一版只实现轻量内存/JSON edge，保留将来替换 KUKSA 或真实车端 bridge 的接口。


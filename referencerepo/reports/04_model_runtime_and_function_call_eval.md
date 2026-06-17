# 04 Model Runtime And Function Call Eval

## ggml-org/llama.cpp

功能说明：`llama.cpp` 是本地 GGUF 模型运行的核心参考仓库，也是 Qwen3-0.6B 这类小模型端侧运行最常见的底座之一。它能覆盖 macOS/iOS、Metal、量化、server、grammar/JSON 约束等能力。对你的项目来说，它不是唯一选项，但必须作为基准：如果 MLX Swift 或 Foundation Models 遇到限制，llama.cpp/GGUF 是最稳的 fallback。

技术栈与架构：仓库体量很大，C++、C/C++、Python、TypeScript、Svelte、Makefile、CMake 等并存。架构上包括底层 ggml/gguf 推理、量化工具、模型加载、server、示例、bindings 和测试。它偏底层 runtime，不是 Swift app framework。你的 Swift 层应该通过 `llama.swift`、`LocalLLMClient` 或自写桥接封装它。

可复用能力点：第一，本地推理和量化格式。第二，grammar/JSON schema 约束输出能力，可用于 function call 的结构化输出。第三，server 模式适合 Mac 开发期快速验证，不必每次打包 iOS。第四，模型兼容面大，方便比较 Qwen3-0.6B、其它小模型和不同量化等级。

限制与风险：直接集成复杂度高，iOS 包体、模型文件、内存和热量要实测。它不会自动解决中文车控意图、动作安全和多意图排序。落地建议：不要从 day 1 就把业务层写死在 llama.cpp；先定义 `LLMBackend`，Mac 端用 server 快速验证，iOS 端再决定是否嵌入 GGUF。

## ShishirPatil/gorilla

功能说明：Gorilla 仓库包含 Berkeley Function Calling Leaderboard（BFCL）相关内容，是研究 function calling 评测的官方来源。你之前截图里提到不要用陈旧的 `BFCL-CN`，改用官方 BFCL；这次已按这个方向 clone。它对你的项目的价值在于：如何定义工具调用任务、如何比较模型输出、如何评估参数准确性和多轮/并行调用。

技术栈与架构：本地库存显示 Python、JSON、JSONL、Markdown、JavaScript 等，目录里有 `berkeley-function-call-leaderboard`、`gorilla`、`openfunctions`、`agent-arena`、`data`。它不是 iOS runtime，而是模型评测和数据集仓库。架构上是 benchmark + 数据 + 评估脚本。

可复用能力点：第一，复用评测维度：工具名是否正确、参数是否正确、JSON 是否可解析、是否多工具调用、是否拒绝不合法请求。第二，复用数据组织方式，构建你自己的中文车控 BFCL-lite。第三，借鉴 leaderboard 的错误分类，分析 Qwen3-0.6B 在车控 function call 上到底错在哪里。

限制与风险：官方 BFCL 是通用工具调用，不是车控域，也不针对中文口语和车辆安全。直接用其数据无法验证“开窗一半”“副驾座椅通风”这类领域能力。落地建议：把它作为评测框架参考；数据自己造。第一版建立 200-500 条中文车控工具调用样例，覆盖单工具、多工具、模糊表达、拒绝执行四类。

## javierlimt6/tiny-tool-bench

功能说明：`tiny-tool-bench` 关注小模型工具调用评测，和你的 Qwen3-0.6B 路线高度相关。很多 function calling benchmark 默认模型能力较强，但你的目标是端侧小模型，必须用更接近小模型限制的测试集来判断可行性。这个仓库就是判断“0.6B 是否能稳定吐对工具调用”的参考。

技术栈与架构：仓库以 Python 为主，带 `pyproject.toml`、bench、configs、scripts、data、tests。架构上是评测数据 + 运行脚本 + 配置。它可作为你项目评测命令行工具的雏形：给定模型后端和 prompt/schema，输出准确率、可解析率、参数错误率。

可复用能力点：第一，复用小模型评测思路，不拿 GPT 级模型标准欺骗自己。第二，借鉴 configs，把不同 prompt、不同模型、不同工具集拆开。第三，对多意图命令很有用：小模型可能能识别单工具，但并行/顺序工具调用很容易错。

限制与风险：它的数据域不是车控，不能替代你的中文功能清单。评测脚本也未必直接支持 Swift runtime。落地建议：用它启发一个 `vehicle-tool-bench`：输入中文命令和车端上下文，输出期望 `ToolCall[]`。第一版 CI 不一定跑模型，但至少要能跑规则快路径和 mock LLM 输出校验。

## MadeAgents/Hammer

功能说明：`Hammer` 是和小模型 function calling 相关的仓库，截图里也被标成新加替补。它体量不大，Python、JSON 和脚本为主，适合作为“小模型工具调用数据/方法”的补充参考。对你的项目，它的价值在于看小模型如何通过数据、prompt 或微调获得工具调用能力。

技术栈与架构：本地库存显示 JSON 文件较多，Python 代码较少，说明它可能更偏数据、示例和训练/评测脚本。架构上不是 runtime，而是围绕函数调用样例、模型输出格式和实验脚本组织。它可以和 BFCL、tiny-tool-bench 放在同一评测资料组里。

可复用能力点：第一，学习小模型 function call 样例格式，尤其是工具描述、参数 schema 和期望输出。第二，参考其数据组织方式，为中文车控构造少量高质量样例。第三，如果后续你真要微调 Qwen3-0.6B，它能提供数据格式和实验流程参考。

限制与风险：仓库规模较小，不能作为唯一依据。小模型工具调用效果高度依赖数据质量、输出约束和后处理。落地建议：不要一上来微调；先用规则 + schema 约束 + 少样例 prompt，看 Qwen3 是否能稳定输出。Hammer 作为数据启发，不作为第一版依赖。

## qualcomm/nexa-sdk

功能说明：`nexa-sdk` 是 Qualcomm/Nexa 方向的本地 LLM/VLM SDK。截图里指出它 day-0 模型支持，并提到 Nexa 以端侧 function calling 起家，值得对比。对你的 Apple-only 项目，它未必是最终依赖，但它能帮助你理解端侧模型 SDK 如何组织 CLI、绑定、示例、模型和多平台 runtime。

技术栈与架构：本地库存显示 Go、Python、Kotlin、C/C++、Rust 都有，目录包括 `cli`、`sdk`、`examples`、`bindings`、`docs`、`third-party`。这说明它是跨平台 SDK，而不是单一 Swift 包。架构上重视模型运行、命令行、语言绑定和示例应用。

可复用能力点：第一，参考 SDK 层设计：模型管理、推理调用、工具调用、示例入口如何拆分。第二，借鉴 CLI 先行策略：你可以先在 Mac CLI 里跑通车控 function call，再做 iOS UI。第三，观察其小模型工具调用接口，帮助你设计自己的 `ToolCallingLLM`。

限制与风险：它不是 Apple 原生优先，直接用于 iOS/macOS 可能会增加依赖复杂度。Qualcomm/Nexa 生态也可能偏特定硬件和模型。落地建议：把它当对照组，不当第一路线。Apple-only 项目优先 MLX Swift、Foundation Models、llama.cpp；Nexa 用来观察端侧 SDK 产品化方式。

## mozilla-ai/llamafile

功能说明：`llamafile` 的核心价值是把 LLM 运行包装成单文件/易分发形态，尤其适合 Mac 原型阶段。截图里也提到它作为 Mac 原型备查，“一个文件起 server，省掉编译 llama.cpp”。对于你现在要快速验证车控 Agent，llamafile 可以作为最省事的本地模型服务替代。

技术栈与架构：本地为 sparse clone，但已保留 `README.md`、`llamafile` 关键代码等研究入口。仓库以 C++、C、构建脚本和底层运行时代码为主。架构上是 llama.cpp/底层 runtime 的打包和启动体验优化，把模型和执行器变得更易分发。

可复用能力点：第一，Mac 开发期快速起本地 LLM server，用来调 prompt、function schema 和多意图输出。第二，给你提供“prototype fallback”：iOS 端还没跑通时，Mac 先完成语义层验证。第三，单文件分发思路可启发后续 demo 包装。

限制与风险：它不是 iOS app 内嵌方案，也不应成为最终 Apple 移动端依赖。sparse clone 说明该仓库体量/网络对普通 clone 不友好，但研究关键文件已在本地。落地建议：把它放在 Mac 实验工具链，不放进 iOS 第一版。真正移动端仍看 MLX/llama.cpp/Foundation Models。


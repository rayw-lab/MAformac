# 05 Structured Output And Guardrails

## noamgat/lm-format-enforcer

功能说明：`lm-format-enforcer` 是用于约束 LLM 输出格式的库，支持 JSON Schema、正则等形式的格式限制。对车控 Agent 来说，最危险的不是模型“不够会聊天”，而是模型输出无法解析、参数类型不对、把两个动作混成一句自然语言。这个仓库正好对应 function call 的硬需求：让模型只能吐可解析结构。

技术栈与架构：仓库以 Python 为主，含 `lmformatenforcer`、tests、docs、samples 和 `pyproject.toml`。架构上通常通过 token 级或解码过程中的约束，让生成结果满足目标格式。它不是 Swift runtime，但可以作为 Mac 端实验工具和方法参考。

可复用能力点：第一，复用 JSON Schema 约束思想，把 `ToolCall[]` 的结构写死：`tool_name`、`arguments`、`confidence`、`requires_confirmation`。第二，适合和 tiny-tool-bench/BFCL-lite 联用，比较“自由生成”和“格式约束”对小模型的提升。第三，能帮助你设计 fallback：模型输出不合规时，不执行动作，转澄清或规则重试。

限制与风险：Python 库不一定能直接作用于 MLX Swift 或 llama.cpp Swift 封装；不同 runtime 对 grammar/logits processor 的支持不同。落地建议：概念必须吸收，代码不必直接依赖。Swift 端实现时优先使用 runtime 自带 grammar/JSON mode；没有 token 级约束时，也要做解析后 validation 和拒绝执行。

## dottxt-ai/outlines

功能说明：`outlines` 是结构化生成库，强调用类型、正则、JSON schema 等方式控制模型输出。它适合研究“LLM 如何从自然语言命令稳定输出结构化对象”。你的车控 Agent 需要把“我有点冷，把空调调高点再关一下副驾窗”转为多个工具调用；这类输出必须是结构化生成，而不是 prompt 里祈祷模型听话。

技术栈与架构：仓库以 Python 为主，含 docs、examples、tests、scripts 和 `pyproject.toml`。架构上围绕生成器、schema、模型后端适配和约束策略。它比单纯 JSON parser 更强调从生成过程控制结果。对你的 Mac 开发期实验很有帮助。

可复用能力点：第一，学习 schema-first 的开发方式：先定义 action schema，再写 prompt。第二，参考其 examples，构建 `VehicleCommand`、`ToolCall`、`ClarificationRequest` 等结构。第三，用它快速验证小模型在不同 schema 下的成功率，找到 Qwen3-0.6B 可承受的 schema 复杂度。

限制与风险：outlines 主要是 Python 生态，iOS 端不能直接依赖。它的后端支持也不等于你的 Swift runtime 支持。落地建议：在 Mac 上用 outlines 做实验和生成测试数据；Swift app 内实现同构 schema validation。不要把 Python runtime 放进 iOS app。

## guidance-ai/guidance

功能说明：`guidance` 是受控生成和 prompt 编排库，可用 grammar、regex、JSON、选择分支等方式限制模型输出。它适合研究复杂 prompt 的结构化控制，比如先判断是否需要澄清，再输出一个或多个工具调用，再给用户短反馈。对你的多意图车控非常相关，因为执行链路不应完全交给模型自由发挥。

技术栈与架构：仓库以 Python 为主，含 notebooks、TypeScript、YAML、docs、tests 等。架构上提供 prompt 程序化、生成约束和模型交互控制。它更像 prompt/runtime 控制层，而不是单独的 parser。

可复用能力点：第一，借鉴“程序化 prompt”的思想，把车控决策拆成步骤：安全检查、意图拆分、槽位补全、工具调用。第二，学习如何约束输出片段，例如某个字段只能从工具名枚举中选。第三，适合 Mac 端做 prompt 原型，尤其比较不同模型和约束方式。

限制与风险：guidance 的强项依赖特定 Python 运行环境和模型后端，不一定能搬到 Swift。复杂 prompt 程序也可能让 0.6B 小模型负担过重。落地建议：只把它当 prompt 结构设计参考；实际端侧执行要更简单：规则快路径优先，模型只处理低频模糊意图，输出 schema 尽量扁平。

## instructor-ai/instructor

功能说明：`instructor` 是 Pydantic-first 的结构化抽取库，常用于把模型输出绑定到类型模型并自动校验/重试。对你的项目，它的最大启发是“结构化输出不是字符串解析问题，而是类型系统 + 校验 + 重试策略”。车控 Agent 如果输出 `temperature: "二十四"`、`window: "那边"`、`action: "弄一下"`，必须有类型层拒绝或澄清。

技术栈与架构：仓库以 Python 为主，Markdown 文档很多，含 `pyproject.toml`、大量 examples/docs/tests。架构上围绕 Pydantic schema、模型调用包装、validation、retry 和 extraction。它不提供车控模型，但提供了工程化结构化输出模式。

可复用能力点：第一，复用“类型模型即协议”的思想，在 Swift 里用 `Codable`/枚举/validator 对应 Pydantic。第二，复用重试和错误归因：schema 不通过时，不执行工具，而是请求模型修正或向用户澄清。第三，适合生成开发期数据：把非结构化功能清单整理成 action schema。

限制与风险：Python/Pydantic 不能直接进入 iOS app；模型重试会增加延迟，小模型未必越重试越好。落地建议：在 Swift 端实现严格 `ToolCallDecoder`：解析失败、未知工具、参数越界、状态不允许都要落拒绝分支。instructor 的价值是工程范式，不是运行依赖。


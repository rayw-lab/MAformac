# 06 Automotive Voice Product References

## alexa/alexa-auto-sdk

功能说明：Alexa Auto SDK 是面向汽车语音助手集成的官方级 SDK 参考，虽然仓库已偏历史，但它对你的项目仍有边界价值。它展示了商业车载语音助手需要处理的范围：唤醒、语音会话、媒体、导航、电话、车辆状态、云端服务、设备抽象、认证、日志和多模块集成。你的个人离线 app 不需要这些全部能力，但需要理解“车载语音产品真正复杂在哪里”。

技术栈与架构：本地库存显示 C/C++、C++、HTML、JavaScript、图片和文档较多，说明它是跨平台 SDK + 文档 + 示例体系。架构上通常由 core engine、capability agents、platform abstraction、audio input/output、network/auth、application integration 构成。它是典型大型汽车语音平台，不是轻量 Swift app。

可复用能力点：第一，学习车载语音的模块边界：音频输入、对话状态、能力代理、车辆接口、媒体/导航等不能互相污染。第二，参考 UX/状态机：正在聆听、正在思考、正在执行、失败、需要确认，这些状态对车控安全很重要。第三，学习能力代理思想，把每类车控功能做成独立 handler，而不是一个巨型 switch。

限制与风险：Alexa Auto SDK 偏云端/商业集成，和你的离线端侧、个人安装、Apple-only 方向不一致。直接复用会严重超重，也可能涉及授权和平台依赖。落地建议：只读架构和文档，不引入代码。第一版实现一个“小型 capability agent”架构：HVAC、Window、Seat、Light、Media 分开注册，统一由 tool executor 调用。

## shawnq-msft/azure-voice-live-for-car-android

功能说明：这是一个 Android 车载语音 UX 参考项目，依赖 Azure Voice Live 等在线能力。它和你的离线目标不同，但可用于观察车载语音界面、状态反馈、对话流程和功能演示方式。你的截图目标是“小型 app 展示简单车控车设”，因此 UI/UX 层可以借鉴这类 car voice demo 的组织，而不是只做命令行。

技术栈与架构：本地库存显示 JavaScript、Kotlin、XML、JSON、图片和 `package.json`。它很可能包含 Android App 与 Web/服务端或配置资源的组合。架构上更偏在线语音 demo：前端界面、语音连接、服务调用、车控展示。对 SwiftUI 项目来说，技术栈不可直接移植，但交互模式可参考。

可复用能力点：第一，参考车控语音 UI 状态：麦克风按钮、识别文本、执行结果、车控卡片联动。第二，参考 demo 功能范围，不要首版把所有功能都堆上去；用空调、车窗、灯光、座椅四五类证明链路。第三，参考语音反馈和可视反馈并行：车控不应只说一句“已完成”，还要让状态卡片变化。

限制与风险：它是 Android + 在线 Azure 路线，不适合你的离线 iOS/macOS 目标。不能拿它证明端侧模型能力。落地建议：只借 UX，不借 runtime。第一版 SwiftUI 首页应是“车控状态面板 + 语音按钮 + 最近执行轨迹”，而不是聊天产品页面。


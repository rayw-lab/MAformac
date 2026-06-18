> 范围说明:本 change 是 6-change 的第一个(顶层契约 + 立项骨架)。tasks 聚焦**项目骨架 / 契约源结构 / 跨子系统核心协议 / 最小 walking skeleton**;各子系统完整实现留后续 5 个 change(capability / execution / voice / lora / vehicle-tool-bench)。前置:完整 Xcode(已装,iOS/macOS platform 安装中)。

## 1. 项目骨架

- [x] 1.1 创建 MAformac SwiftUI 工程(iOS + macOS target,无后端)。产出:可 build 的空 app。验收:Xcode build 成功 + 模拟器启动。
  - evidence 2026-06-18: `MAformacMac` Debug build `BUILD SUCCEEDED`; `MAformacIOS` Debug build on `iPhone 17 Pro` iOS 26.5 simulator `BUILD SUCCEEDED`; `simctl bootstatus` returned `Finished`; `simctl install` succeeded; `simctl launch lab.rayw.MAformac.ios` returned pid `68181`; launch screenshot: `/tmp/maformac-ios-launch.png`.
- [x] 1.2 建目录结构 `App/` `Core/{Capability,LLM,Voice,Intent,Routing,Execution,State,Trace}/` `Features/VehicleControl/` `Resources/` `dev/`。验收:目录树与 design.md 7 层一致。
- [x] 1.3 配 `.gitignore`:模型权重 / venv / 训练数据 / 真实座舱数据 **不入仓**(仅 LoRA 权重产物可入仓)。验收:`git status` 不含权重/数据/PII。

## 2. 契约源结构(单一事实源骨架)

- [x] 2.1 建 `contracts/capabilities.yaml` schema 骨架 + 1 条样例 capability 占位(完整 8 条留 `define-capability-contract`)。产出:capabilities.yaml + 字段注释。验收:yaml 合法 + 字段齐(`id/status/display_zh/aliases/tool_schema/reference_binding/execution/demo_guard/response/eval_refs`;**字段以 define-capability-contract 定稿为准**)。
- [x] 2.2 建 `contracts/agents.yaml`:车控 agent 1 条 + 导航/音乐/外卖 `connector: mock` + `enabled: false` + `availability: planned` 占位。验收:agent 只引用 capability id;二期标 planned、不可点。

## 3. 跨子系统核心协议与类型(空实现,细节留后续 change)

- [x] 3.1 定义 `LLMBackend` 协议(load / generateToolPlan / streamText / cancel)。验收:编译通过,无具体 backend 实现。
- [x] 3.2 定义 `Capability` 协议(本地/MCP 同构:match / handle / schema)+ `CapabilityRegistry`。验收:编译通过。
- [x] 3.3 定义三核心结构 `ToolCallFrame` / `AgentDescriptor` / `SurfacePolicy`(enum: primary_panel / overlay_card / split_panel / fullscreen)。验收:Codable 编译通过。
- [x] 3.4 定义 `DemoVehicleStateStore`(`@Observable @MainActor`,8 字段 cell:key/actualValue/desiredValue/availability/timestamp/source/revision/visualState)+ `applyMockTransition` 签名(唯一写入口)。验收:@Observable 编译通过、UI 可订阅。
- [x] 3.5 定义 `DemoGuard` 协议位 + `TraceLogger` 五段接口(decode/plan/guard/execute/readback)。验收:编译通过。**注:DemoGuard 此处仅协议位 + 接口;完整 R0–R3 代码门规则见 `define-execution-contract`,本 change 不实现全门控**。

## 4. Walking Skeleton(最小主链路闭环,证明骨架立得住)

- [x] 4.1 实现一条规则 FastPath 闭环:「打开空调」→ ToolCallFrame → DemoGuard **单条放行(非完整门控)** → applyMockTransition → DemoVehicleStateStore → UI 卡片亮。验收:输入「打开空调」UI 卡片肉眼可见变化 + 读回 actualValue。**叠加 Superpowers: TDD(write-test-first)**。
- [x] 4.2 接一条占位 TTS(`AVSpeechSynthesizer` 播「空调已打开」)。验收:听到播报,内容 = readback 结果(非请求值)。
- [x] 4.3 TraceLogger 记录该闭环五段。验收:trace 输出含 decode/plan/guard/execute/readback 五段。

## 5. demo-experience 验收脚手架

- [x] 5.1 把 demo-experience spec 硬验收(`readback mismatch=0` / `Unsafe false pass=0` / pending 不冒充成功)落成占位单元测试骨架(先红/skip,后续 change 填实)。验收:测试可被 run。**叠加 Superpowers: TDD**。
- [x] 5.2 建演示集占位清单:15–25 条 5 幕话术空表(内容留 `define-vehicle-tool-bench`)。验收:清单文件存在 + 5 幕分组。

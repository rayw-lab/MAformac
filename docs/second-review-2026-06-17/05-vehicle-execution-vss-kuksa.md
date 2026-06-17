# 05 Mock 演示链路：VSS、KUKSA、Canals 的可复用边界

## 边界更正

MAformac 是 Master Agent for Mac，是磊哥个人使用、给客户做方案演示的离线 demo。本文不是上车方案，不讨论真实车辆控制落地。这里的“执行链路”只指：

```text
用户文本/语音 -> 意图解析 -> mock tool call -> 本地 mock state -> UI 卡片变化 -> trace
```

VSS/KUKSA/Canals 在本文中只作为命名、状态建模、trace 和开发期参考，不是首版 runtime 依赖。

## 总体判断

Claude Code 对车控参考协议的吸收成立，但必须放回“方案演示 demo”语境：

- VSS 是命名和语义底座。
- vss-tools 是开发期转换/校验工具。
- KUKSA Databroker 是 Mac 开发期可选 broker/回归对照，不进首版演示 runtime。
- Canals 是完整系统图参考，只抽三抽象。

需要补充的关键点是：演示成功不能只等于“模型说已完成”。首版 mock 可以同步更新 UI 状态，但接口仍要能表达 `accepted / pending / succeeded / failed / unknown`，否则 demo 会把不确定状态包装成成功。

## VSS 的演示边界

VSS 官方 README 写明其目标是创建车辆信号共同语言，独立于协议和序列化格式：[VSS README](/Users/wanglei/workspace/MAformac/referencerepo/repos/COVESA__vehicle_signal_specification/README.md:6)。COVESA 官网进一步说明 VSS 将车辆信号组织为 nodes/leaves 的层级树，并简化大量车辆信号的共同理解。

对 MAformac 的含义：

- VSS 是演示能力的命名参考和绑定层，不是上车协议承诺。
- VSS path 可以进入 `capabilities.yaml` 的 `vehicle_binding`。
- 模型不直接看 VSS 全树，只看受控 action schema。
- 品牌功能映射不到 VSS 时，用 `extension_path`，不要硬塞。

## vss-tools 的演示边界

vss-tools 官方 README 写明它用于转换或校验 VSS：[vss-tools README](/Users/wanglei/workspace/MAformac/referencerepo/repos/COVESA__vss-tools/README.md:6)。兼容性章节说明 VSS-tools 与 VSS catalog 版本有对应关系，新旧版本不保证互通：[vss-tools README](/Users/wanglei/workspace/MAformac/referencerepo/repos/COVESA__vss-tools/README.md:58)。

对 MAformac 的含义：

- 必须 pin VSS release 和 vss-tools 版本。
- `capabilities.yaml` 生成器要记录生成时使用的 VSS 版本。
- 不要把 vss-tools 放进演示 App；它只属于 Mac 开发期。

## KUKSA 的演示边界

KUKSA README 写明 Databroker 是 gRPC service，作为 vehicle data/data points/signals broker：[KUKSA README](/Users/wanglei/workspace/MAformac/referencerepo/repos/eclipse-kuksa__kuksa-databroker/README.md:16)。它还说明 VSS 不规定信号如何采集和管理，KUKSA Databroker 提供统一 gRPC API 给应用查询、更新、订阅：[KUKSA README](/Users/wanglei/workspace/MAformac/referencerepo/repos/eclipse-kuksa__kuksa-databroker/README.md:61)。

关键修正：

- KUKSA 不是“自动模拟车”。要让状态变化可观察，需要 provider 或 mock transition。
- KUKSA v1 已 deprecated，本地 README 显示 v2 和 v1，且 v1 标 deprecated：[KUKSA README](/Users/wanglei/workspace/MAformac/referencerepo/repos/eclipse-kuksa__kuksa-databroker/README.md:106)。
- macOS/Docker 端口要注意。KUKSA quickstart 在 Docker Desktop 场景建议用 55556 并显式 publish。
- 对 MAformac，KUKSA 不是路线前提。只有当本地 mock executor 已稳定、需要更像标准化数据层的回归对照时，才值得评估。

## Canals 的演示边界

Canals README 展示它是 hybrid in-vehicle voice assistant，含 local router、AWS Bedrock、MongoDB cache、FastAPI backend、Astro UI、OpenAI Whisper API、KUKSA/Car API 等：[Canals README](/Users/wanglei/workspace/MAformac/referencerepo/repos/Bosch-Connected-Experience-26__Canals/README.md:63)。

可借：

- local-first 思路
- 语音/NLU、mock executor、UI 状态分层
- route/cache/fallback 的 trace 意识
- mock 状态参与命令执行

不借：

- AWS Bedrock
- MongoDB
- FastAPI 后端
- Astro UI
- OpenAI Whisper API
- 全栈 Docker 化

## 首版抽象建议

### `DemoVehicleStateStore`

职责：唯一 mock 状态源，UI 和 Agent 都只通过它读状态。

```swift
protocol DemoVehicleStateStore {
    func snapshot() async -> VehicleSnapshot
    func read(_ paths: [VehicleSignalPath]) async throws -> [VehicleSignalValue]
    func observe(_ paths: [VehicleSignalPath]) -> AsyncStream<VehicleStateEvent>
    func applyMockTransition(_ receipt: ActionReceipt) async throws -> VehicleSnapshot
}
```

每个 state entry 至少包含：

```text
key
actualValue
desiredValue?
availability
timestamp
source
revision
```

### `DemoActionExecutor`

职责：所有演示动作必须经过它，不能由 SwiftUI button 直接改 store。

```swift
protocol DemoActionExecutor {
    func execute(_ plan: VehicleActionPlan, context: ExecutionContext) async -> ActionReceipt
}
```

执行前：

- schema 校验
- 参数范围校验
- 对象门
- 演示风险门
- 权限/演示模式门
- mock 环境门
- 互斥 bus 检查

执行后：

- 写 mock desired
- mock transition
- 读回 mock actual
- 超时判断
- trace 落盘

receipt 状态固定：

```text
rejected
needs_confirmation
accepted
pending
succeeded
failed
unknown
```

### `AgentTrace`

每次执行必须落一条：

```json
{
  "trace_id": "...",
  "input": "我有点冷",
  "asr_text": null,
  "route": "slow",
  "matched_capabilities": ["cabin.hvac.set_temperature", "cabin.seat.set_heating"],
  "tool_calls": [],
  "pre_state": {},
  "receipt": {},
  "post_state": {},
  "user_reply": "...",
  "errors": []
}
```

## 验收门

P0 必过：

1. 15-25 条 must-pass case 全过。
2. 所有动作有 trace：`input -> parsed intent -> plan -> pre_state -> receipt -> post_state -> reply`。
3. `pending/failed/unknown` 不得播报“已完成”。
4. UI 卡片状态只来自 `DemoVehicleStateStore`，不来自模型自然语言。
5. `DemoActionExecutor` 可替换 store：首版只要求内存 mock；KUKSA adapter 是后续可选对照。

可选阶段加 KUKSA：

1. Mac broker 用 55556。
2. 有 mock provider 或 mock action handler。
3. 同一套 demo executor 测 `InMemoryDemoVehicleStateStore` 和 `KuksaDemoStateStoreAdapter`。
4. pin KUKSA API 版本，优先 v2。

---
kind: cor-verification
as_of: 2026-07-21
---
# COR-8 核实结论

## 分析

**COR-8（半支持 + 域外无原子性）** 在**当前 DemoSliceRoute 单帧产品路径下不触发 / 已被证伪**；但**多帧 Partial 执行基础设施本身存在原子性契约，属于 Phase 2 范畴**，不能因前者不可达而宣称后者天然原子。

### 证据链

#### 1. 当前产品路径严格单帧

**DemoSliceAdmissionCatalog.admission(for:)**（`Core/Routing/DemoSliceAdmissionCatalog.swift:54-92`）：
- 仅两条目录项：`打开空调` → `ac.power_on`；温度数值 → `ac_temperature.adjust_to_number`
- 每次调用**仅返回单个 `ToolCallFrame`**（无多帧数组）

**DemoSliceRoute.routeBody()**（`Core/Execution/DemoSliceRoute.swift:70-91`）：
```swift
guard let admission = catalog.admission(for: text) else { … }
runnerCallCount += 1
let payload = try await runner.run(text: text, correlationProvider: correlationProvider)
return DemoSliceRouteResult(execution: DemoSliceExecution(admission: admission, payload: payload, runnerCallCount: runnerCallCount))
```
- `planDecoder`（`DemoSliceRoute.init` 行 47-52）返回 `[admission.frame]` —— **单元素数组**
- `runner.run(text:)` 内部调用 `planDecoder(text)`，**仅产出单帧**

**DemoRuntimeSessionRunner.executeRun()**（`Core/Execution/DemoRuntimeSessionRunner.swift:128-145`）：
```swift
let frameResults = try await planDecoder(text)
guard let frameResult = frameResults.first else { … }
if frameResults.count > 1 {
    guard frameResults.allSatisfy(DemoRuntimePartialPlan.isReviewed) else {
        throw DemoRuntimeSessionRunnerError.multiFramePlanRequiresPartialExecution(...)
    }
    let partialResult = try DemoRuntimePartialPlan().execute(...)
    // partial execution path
}
```
- 单帧走常规 `pipeline.execute(frame, store, traceLogger)`（第 128-380 行）
- **多帧仅在 `frameResults.count > 1` 且全部 `isReviewed` 时才进入 Partial 路径**
- 当前 DemoSliceRoute 目录**永远只返回单帧**，因此**多帧 Partial 路径在产品路径不可达**

#### 2. 多帧 Partial 执行基础设施确实存在，且有原子性契约

**DemoRuntimePartialPlan**（`Core/Execution/DemoRuntimePartialPlan.swift:8-14, 49-74, 200-266`）：
- 定义 `DemoRuntimeAtomicityContract`：
  - `.atomic`：全接受或全拒，**不允许部分状态变更**
  - `.partial`：允许混合接受/拒绝，**状态变更边界按帧**
- `execute(frames:)` 逐帧执行，每帧记录 `stateMutation: before != after`
- **原子性契约由执行结果推导**（第 250-255 行）：
  ```swift
  let allAccepted = subactions.allSatisfy { $0.disposition == .accepted }
  let allRefused = subactions.allSatisfy { $0.disposition == .refused }
  let atomicityContract = (allAccepted || allRefused) ? .atomic : .partial
  ```
- `.atomic` 分支下，**并不回滚已发生的 mutation**（每帧独立 `pipeline.execute` 已落盘），仅在结果元数据标记契约
- **COR-8 关注的"域外无原子性"**：多帧 Partial 基础设施**确实缺乏跨帧原子回滚机制**，`refusedSubactionMutatedState` 仅在 preflight 阶段守卫（第 223-233 行），执行后无补偿

#### 3. 测试验证多帧基础设施存在但不可达

**DemoRuntimeSessionRunnerPartialExecutionTests.swift**（`Tests/MAformacCoreTests/DemoRuntimeSessionRunnerPartialExecutionTests.swift`）包含多帧测试，但：
- 测试手工构造多帧 `ToolCallFrame` 数组，**绕过 DemoSliceRoute 目录**
- 标记为单元/集成测试，**非产品行为门测试**（DemoSliceProductBehaviorGateTests 仅含 12 条单帧用例）

### 区分结论

| 维度 | 结论 |
|------|------|
| 当前 DemoSliceRoute 产品路径 | **严格单帧**，COR-8 "partial execution atomicity" **不可达/不触发** |
| 多帧 Partial Execution 基础设施 | **存在且完整**（DemoRuntimePartialPlan + DemoRuntimeSessionRunner 分支），**具备 atomic/partial 契约元数据**，但 **无跨帧原子回滚实现** |
| Phase 归属 | 单帧产品路径 = Phase 1 完成；多帧 Partial Execution = Phase 2 待办（需补偿事务/回滚或显式文档化 "partial = best-effort"） |

## 证据（file:line）

- `Core/Routing/DemoSliceAdmissionCatalog.swift:54-92` — admission 仅返回单帧
- `Core/Execution/DemoSliceRoute.swift:47-52, 70-91` — planDecoder 返回单元素数组，runner 仅执行单帧
- `Core/Execution/DemoRuntimeSessionRunner.swift:128-145` — 多帧分支显式 guard `frameResults.count > 1 && allSatisfy(isReviewed)`
- `Core/Execution/DemoRuntimePartialPlan.swift:8-14` — DemoRuntimeAtomicityContract 定义
- `Core/Execution/DemoRuntimePartialPlan.swift:49-74` — DemoRuntimePartialPlanResult 含 atomicityContract
- `Core/Execution/DemoRuntimePartialPlan.swift:200-266` — execute 逐帧执行，结果推导 atomicityContract，**无回滚**
- `Core/Execution/DemoRuntimePartialPlan.swift:223-233` — refusedSubactionMutatedState 仅 preflight 守卫
- `Tests/MAformacCoreTests/DemoSliceProductBehaviorGateTests.swift:27-84` — 12 条产品行为门全为单帧

## 结论：非雷（当前路径），待 Phase 2（多帧基础设施原子性）

> **结论措辞依据**：
> - DemoSliceRoute 当前可达路径**单帧**，COR-8 定义的"半支持+域外无原子性"在**当前产品路径不触发** → 非雷
> - 但 DemoRuntimePartialPlan 基础设施**已落地并含 atomicityContract**，其 `.atomic` 分支**不具备跨帧回滚能力**，这是真实的架构债，**必须归入 Phase 2 解决**（补偿事务、Saga、或显式文档化 best-effort 语义），**不能因产品路径单帧而宣称"天然原子"**
# Lens 05 — Architecture Entropy

- 日期：2026-07-21
- 席位：strategist
- transcript：`history://ArchitectureEntropy`
- 结构化输出：`agent://ArchitectureEntropy`

## Finding

1. `DemoRuntimePartialPlanResult.atomicityContract` 是 write-only 字段；执行后计算，无 Core consumer，无法约束 mutation。
2. orbState 生产/消费链存在，但 active test 只覆盖少量 happy path；nil/think/listen/speak 与 runner→payload 联动保护不足。
3. COR-2 的 flag 链可编译、C3 guard 生效，但真实 mounted backend 覆盖不足。
4. 三个 tracked 测试删除后，presentation、partial、fixture/schema 回归保护下降。
5. `ToolCallFrame.doNotAutoPowerOn` 多个构造点依赖默认 false，缺少构造边界合同。
6. `PresentationOrbDisplayState` 与 `PresentationOrbState` 双 enum 需 parity 门或收敛为单一表示。

## 纠错记录

原输出称 COR-2 无 active tests 不准确；`Cor2NegationTests.swift` 活跃且通过，但覆盖的是手工 parser/normalizer/bridge/C3 路径，不是 mounted backend。

## Verdict

架构主要风险不是“字段不存在”，而是 producer 有、consumer/behavior gate 缺，形成 declare-not-enforce 熵。

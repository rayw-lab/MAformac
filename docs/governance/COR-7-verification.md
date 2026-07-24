---
kind: cor-verification
as_of: 2026-07-21
---
# COR-7 核实结论

## 分析

COR-7 本票据核查的可观察问题是：系统已处于目标态时，是否仍产生一次假的状态 mutation（revision 增长）。当前 `DemoSliceRoute` 产品路径下，该问题不再触发。

`DemoRuntimeAdapter.execute` 先读取目标 cell；当 `current.actualValue == plannedTransition.desiredValue` 时，将 provenance 标为 `.alreadyStateNoop`，直接用当前 cell 构造 readback，不调用 `store.applyMockTransition`。因此第二次执行相同指令不会改变状态，也不会增加 revision。

产品行为门 `test07_alreadyOn_noDuplicateMutation` 通过真实 `DemoSliceRoute` 连续执行两次“打开空调”，并断言第二次执行后的 `store.currentRevision` 与第一次执行后相等、`ac.power` 仍为 `on`。

最小验证命令：

```text
swift test --filter DemoSliceProductBehaviorGateTests/test07_alreadyOn_noDuplicateMutation
```

2026-07-21 实跑结果：1 test executed，0 failures，PASS。

需要严格区分一个仍存在的展示层 gap：单帧 SessionRunner 目前仍把该 readback 包装成 `RuntimeOutcome.result == .acceptedToolCall`。现有 test07 证明的是“无状态 mutation / revision 不增长”，并未证明展示层已经区分 noop 与真实 tool-call mutation；本结论不对后者作已修声明。

## 证据（file:line）

- `Core/Execution/DemoRuntimeAdapter.swift:13-16` — `.alreadyStateNoop` provenance 定义。
- `Core/Execution/DemoRuntimeAdapter.swift:237-253` — 目标态相等时直接返回当前 readback，不调用变更路径。
- `Tests/MAformacCoreTests/DemoSliceProductBehaviorGateTests.swift:88-97` — 连续执行相同命令并断言 revision 不变。
- `Core/Execution/DemoRuntimeSessionRunner.swift:364-395` — 单帧 presentation 仍统一生成 `.acceptedToolCall`，是独立的展示分类 gap。

## 结论：非雷（当前路径的假 mutation 已修/证伪）

当前 DemoSliceRoute 可达路径不会在“已是目标态”时增加 revision。展示层仍统一标为 `acceptedToolCall`，不纳入本次“mutation=1”已修结论。

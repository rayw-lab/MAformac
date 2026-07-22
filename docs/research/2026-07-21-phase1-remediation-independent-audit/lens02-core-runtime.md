# Lens 02 — Core Runtime

- 日期：2026-07-21
- 席位：reviewer
- transcript：`history://CoreRuntimeAudit`
- 结构化输出：`agent://CoreRuntimeAudit`

## Finding

1. COR-2 的 `doNotAutoPowerOn` 只在 legacy `set_cabin_ac` normalizer 生成；真实 mounted D-domain backend 不接受该工具，端到端模型路径仍未闭合。来源：`Core/Contracts/ToolContractCompiler.swift:302-309`、`Core/LLM/DDomainToolPlanBackend.swift`。
2. COR-4 在 `validateMetadata` 前短路，接受非空普通回答并绕过 content size。来源：`Core/LLM/DDomainToolCallParser.swift:13-49`。
3. 合法 zero-tool 被编码为 `[]`，runner 又转成 unsupported，没有 typed no-action。来源：`Core/Execution/DemoRuntimeSessionRunner.swift:162-164`。
4. COR-7 adapter 不再 mutation，但 C3/runner 丢 provenance，presentation 仍称 accepted。来源：`Core/Execution/DemoRuntimeAdapter.swift:241-250`、`DemoRuntimeSessionRunner.swift:375`。
5. COR-8 的 atomicityContract 在执行后计算，且无生产 consumer。来源：`Core/Execution/DemoRuntimePartialPlan.swift:192-203`。

## Verdict

COR-1 实现；COR-2/COR-7 部分实现；COR-4 回归；COR-8 declare-only。Core 不能签 Phase 1b 闭环。

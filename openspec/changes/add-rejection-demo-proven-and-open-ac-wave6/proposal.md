## Why

Wave5 已把 `actionDemoProven` 翻到 **1/120（matrix_id=4 only）**。下一格若误把 m5/m6（`fast_path_no_match_fallback` rejection）计入同一计数器，会污染「执行覆盖」语义。同时 Phase1 下一执行候选是 **matrix_id=1 `open_ac`**（admission 已有「打开空调」，但 catalog 未 mount、matrix 仍 `unmounted`）。需要先用契约分账 rejection，再局部解冻 mount/prove `open_ac`，且全程 mock state + readback，不碰后三族与训练。

## What Changes

- 新增机器可检字段 **`rejectionDemoProven`**（镜像 `actionDemoProven` 形状），仅允许 `primary_class=fast_path_no_match_fallback`（及明确列出的 rejection 类）物质化；**不得**写入或推导进 `actionDemoProven`。
- 规定 m5+m6 为同一 rejection 能力的两 register 表面：**一次** BF-8 可同时授权 `[5,6]`（或等价绑定），与 execution BF-8 分账。
- 允许 Phase1 **局部解冻** mount `open_ac`：更新 `DDomainMountedToolCatalog`、matrix `mounted_status`/basis、admission 已存在路径的 readback/probe 合同；独立 BF-8 `matrix_ids=[1]` 后方可 `actionDemoProven=true`。
- OpenSpec agree-before-build：本 change artifacts apply-ready 前，禁止 C 切片改 proven / 物质化翻格。
- **BREAKING（计数语义）**：任何把 rejection 格计入 `actionDemoProven` 的旧口头口径作废；checker 必须以分账字段为准。

## Capabilities

### New Capabilities

- `rejection-demo-proven`: rejection/fail-closed 演示覆盖的机器字段、物质化规则、与 `actionDemoProven` 隔离、m5/m6 联合 BF-8 口径。
- `open-ac-mount-proven`: Phase1 `open_ac`（matrix_id=1）从 unmounted→mounted→scoped probe→BF-8→`actionDemoProven` 的可观察行为与门禁。

### Modified Capabilities

- `demo-capability-governance`（若已生效）：`actionDemoProven` 推导不得吞并 rejection；matrix schema 增补 `rejectionDemoProven`；scoped BF-8 可声明 rejection vs execution 科目。
- （若存在）`s10-bf8-promotion-gate`：BF-8 receipt 须声明科目（execution|rejection）与 `matrix_ids`，禁复用 matrix-4 execution receipt 翻 m1/m5。

## Impact

- `contracts/demo-capability-matrix.json` + schema / materialize
- `Tools/checks/check_capability_matrix.py`（及测试）
- `Core/Contracts/DDomainMountedToolCatalog.swift`（加入 `open_ac`）
- admission / readback probe / e2e 行为门（m1；rejection 侧后置但口径先锁）
- OpenSpec/tasks 切片；**不**自动执行 BF-8 人审仪式

## Non-goals

- 不翻 m5/m6 的 `actionDemoProven`；不在本 change 完成前执行 rejection BF-8（可先落字段与合同）。
- 不演示/合并/抬 proven 后三族（window/ambient/seat）。
- 不推进训练轨道。
- 不把 `close_ac`（catalog 已挂、matrix 缺格）作为本 change 主路径实现（仅允许设计附录）。
- 非真车控；仅 mock UI state + readback。
- 不宣称 Phase2 全局解冻 / G9_COMPLETE / Verify green。

## Success criteria

| Gate | Observable |
|---|---|
| S1 Schema | matrix/schema 含 `rejectionDemoProven`；checker 拒把 fallback rejection 写入 `actionDemoProven`。 |
| S2 Isolation | m5/m6 在无 rejection BF-8 时保持 `actionDemoProven=false`；字段默认可检。 |
| S3 open_ac mount | catalog 含 `open_ac`；matrix_id=1 `mounted_status=mounted` 且 basis 与 materialize 一致（无手改 generated）。 |
| S4 Probe | m1 直述「打开空调」产品验收路径：accepted tool、state delta、readback 硬断言绿。 |
| S5 BF-8 m1 | 仅在独立 receipt `matrix_ids=[1]` + 人审后 `actionDemoProven` 对 m1 为 true；m4 仍 true；m5/m6 仍 false。 |
| S6 Stopline | `PHASE2_CODING_GATED` 仍在；后三族禁；禁训练。 |

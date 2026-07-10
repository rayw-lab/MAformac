## Why

D-123 已将 120 格 `DemoCapabilityMatrix` 内容口径签为能力面真值，D-133 又将 C1 P0 的 38 项治理决策全部按 B 拍定；当前仍缺一个可严格校验、能约束后续 matrix、fallback、partial execution 与 probe 实现的 OpenSpec carrier。D-134 已进一步锁定三方 authority：C1 需要独立 capability-governance，但不得重造现有 Runtime → Presentation 的 payload、trace、readback 或 partial-result presentation SSOT。

## What Changes

- 新增 `demo-capability-governance`：规定 120 格 matrix 守恒、逐格 basis、`actionDemoProven` 四件套、`primary_class`、closed fallback enum/catalog、10 族×4 reason coverage、CG-036 治理条件、probe/no-mutation 门、S10/mounted expansion 与 rollback 红线。
- 修改 `tool-execution`：把“多工具一律拒绝”收窄为可审 bounded multi-intent plan；执行层继续唯一拥有 accepted/refused 子动作、mutation、tool-call、readback、internal finite reason 与 execution receipt 事实。
- 修改 `runtime-presentation-bridge`：复用现有 bridge 唯一拥有的 public payload/schema、partial projection、customer-safe `reasonKind`、readback rendering 与 presentation-safe trace envelope；只增加对 CG-036 execution facts 的安全投影，不创建平行 presentation capability。
- 在 design 中固化 ownership map 与三套 enum 投影表，并让 tasks 为后续 matrix、fallback、execution、bridge、probe、CI 和 audit 切片提供 test-first 骨架。

## Non-goals

- 不创建 `runtime-presentation-payload` 或任何同义 presentation SSOT。
- 不由 C1 授权 mounted 1→N；不执行 S9/S10，不把 prelay、FastPath alias 或 conditional lane 写成 default `actionDemoProven`。
- 不改变现有 bridge 的 payload owner、proof cap、UIUE 单向消费边界或 private-marker/redaction 规则。
- 不做真车控制、CAN/ECU/OBD、量产或客户侧运行能力；车控成功仍只以离线 mock state readback 为准。
- 不签 C5 V-PASS、C6 acceptance、candidate、mobile、true-device、live API 或 operator-pass。

## Success Criteria

- `openspec validate add-c1-demo-capability-governance --strict` 与 `openspec validate --all --strict` 均通过。
- D-133 的 38 个 CG 均由明确 requirement、scenario、architecture decision 或 test-first task 承接，coverage 为 38/38，无遗漏、无伪重开。
- `demo-capability-governance`、`tool-execution`、`runtime-presentation-bridge` 三个 owner 边界清楚；CG-036 同时具有 execution delta 与 bridge projection delta。
- enum 只允许已锁的 `primary_class`、governance fallback classification、internal `finiteReason`、`fallback_reason` 与 customer-safe `reasonKind` 映射；未知/free-string 值 fail closed。
- matrix/fallback/probe 可预铺，但任何新增 mounted 或 `actionDemoProven=true` 都在 CG-080 下保持未授权。

## Capabilities

### New Capabilities

- `demo-capability-governance`: 管理能力矩阵、demo eligibility、fallback taxonomy/catalog、probe coverage 与 mounted expansion governance。

### Modified Capabilities

- `tool-execution`: 支持 bounded CG-036 partial execution，并保留逐子动作 fail-closed、readback、no-mutation 与 internal receipt 事实。
- `runtime-presentation-bridge`: 通过现有 main-owned payload/result/readback/trace 契约投影 CG-036 mixed outcome，不改变 presentation owner。

## Impact

- 后续实现将新增或修改 `contracts/` matrix/fallback/probe sources、generated catalogs、checker、Swift execution/bridge seams、fixtures、tests、Makefile 与 source-free CI gates。
- `DemoRuntimeSessionRunner.run`、trace schema 与 bridge payload types 是潜在 HIGH/CRITICAL surface；实现前必须逐 symbol GitNexus impact，提交前必须 `detect_changes`。
- 本 change 只定义行为与执行任务；当前提交不改变 runtime、mounted catalog、UIUE 或 proof status。

# Handoff 2026-06-19 — change3 execution contract apply closeout

## 状态
`define-execution-contract` apply 完成:纯逻辑契约层已接入 `MAformacCore`,未引入真 MLX runtime,未修改 `Package.swift`,未修改 `contracts/capabilities.yaml`。

## 本轮实装
- `ToolCallFrame.arguments` 从 `[String:String]` 升级为自定义 `[String:JSONValue]`。
- 新增手动 codegen:`contracts/{capabilities,agents}.yaml` → `Core/Generated/GeneratedCapabilityCatalog.swift`。
- 新增 decode 契约:`no_tool_call` / `malformed` / `schema_invalid(unknown_tool|missing_field|type_mismatch|out_of_range)`。
- `DemoGuard` 从占位门升级为 schema/range/risk/writable/互斥/前置条件门。
- `DemoActionExecutor` 改为按 generated `execution.stateCell` 写 mock state。
- `FastPathIntentEngine` 删除旧 change1 命名,改用 `cabin.*` / `set_cabin_*` / `power`。
- `TraceLogger` 保持五段:`decode` / `plan` / `guard` / `execute` / `readback`,三口径作为 metadata 记录,不新增 stage。

## 验收证据
- `swift test`:33 tests,0 failures,0 skipped。
- SwiftPM warning:`scripts/gen_capabilities.py` is unhandled because `Package.swift` target path is repo root;按本 change 红线未改 `Package.swift`,warning 不影响测试结果。
- `openspec validate define-execution-contract --strict`:valid。
- `openspec instructions apply --change define-execution-contract --json`:17/17,`state=all_done`。
- `git diff -- Package.swift contracts/capabilities.yaml contracts/agents.yaml`:empty。
- `rg "set_vehicle_control|vehicle\.ac\.toggle|state_key|target_state" Core Features`:0 matches。
- `rg "import MLXLMCommon|import MLXLLM" Core Features Tests scripts Package.swift`:0 matches。
- codegen rerun SHA stable:`73fd4e9b5460452eee4338b87200c6c6a0f27e1cedb73bd28fcb5889d8dbd0d4`。

## 下游快照口径
- Trace 五段名不变:change5/LoRA 窗口可继续按 `decode/plan/guard/execute/readback` 对齐。
- 三口径不改变五段名:raw `.toolCall` / fallback candidate / guard 后实际执行均通过 metadata/substructure 观测。
- `contracts/capabilities.yaml` 只读消费,未产生新 schema version。

## introduced vs exposed
- introduced:新增本地 `JSONValue`、generated catalog、decoder、schema guard、executor/readback/trace metadata 测试。
- exposed:change1 遗留的 `vehicle.ac.toggle` / `set_vehicle_control` / `state_key` / `target_state` 命名漂移;DemoGuard 只能做 schema 门、不能承担 restraint/意图越界拒识。

## 待后续 change
- intent-routing/LoRA 负责 schema 合法但语义应拒识的样本。
- MLX runtime 接入拆独立 change,接入前先做最小 iOS 真机冒烟。
- change6 量化 content-fallback 对负例的净影响。

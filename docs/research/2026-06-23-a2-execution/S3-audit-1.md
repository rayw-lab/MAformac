# A2 S3 独立审计报告 — state-cells 扩 6 族 + deviceCellMap 单源 + C3 派生 + 命名清债

> 审计员: 独立审计 agent (S3-audit-1)
> 时间: 2026-06-23
> 仓根: /Users/wanglei/workspace/MAformac
> 分支: a2/migrate-d-domain-tool-surface
> 被审 commit: `59975c6` feat(a2): S3 state-cells 扩 6 族 + deviceCellMap 单源 + C3 派生 + 命名清债 (code-only)
> 纪律: 所有数字/file:line 当场 cite-verify(make verify / swift test / verify_refs.py / grep / python 实跑), 禁凭印象。

---

## 0. 实跑命令 + exit code(不信「应该绿」)

| 命令 | 结果 | 证据 |
|---|---|---|
| `make verify` | **EXIT=0** | 全链路绿(verify_refs / cross_section / quarantine / fc_flags / git diff --exit-code 全 PASS) |
| `swift test` | **EXIT=0** | `Executed 134 tests, with 3 tests skipped and 0 failures` (clean log `/tmp/s3_swifttest.log` EXIT=0) |
| `.venv/bin/python scripts/verify_refs.py` | **EXIT=0** | `state_cells=ok (c1_c2_closure=active) l1_closure=ok (L1_rows=76)` |

L1 闭包 **L1_rows=76 未退化**(c1_c2_closure=active)。

---

## 1. cell_schema — PASS

- **6 族全部新建**: state-cells.yaml `devices` 含 `['air_conditioner','window','screen','ambient_light','seat','door','volume','wiper','sunroof','fragrance']` — S3 新增 6 族 `[seat,door,volume,wiper,sunroof,fragrance]` 全present, missing=[]。
- **cell 总数 = 33**(S2 4 族 12 cell + S3 6 族 21 cell)。S3 commit 新增 **21 个 `- id:`**(非 191)。
- **int cell 不变量**(python 实算逐 cell): 所有 int cell `min ≤ default ≤ max` ✓; 无 min>max ✓。
- **enum cell**: 所有 enum cell `default ∈ values` ✓; 无缺 values ✓。
- **state_kinds ⊆ [empty,known,unknown]**: 全 33 cell 合规, 无非法值 ✓。
- **座椅 0-3 真值正确**: `seat.heat_level/vent_level/massage_force` execution_range = `{min:0,max:3,step:1}` (state-cells.yaml:183/194/204)。cite-verify 权威 CLAUDE.md:81「座椅 0-3、车窗 0-100%(旧 16-30/0-5 是拍错)」— **0-3 与权威一致**(旧 0-5 已纠正)。`seat.backrest_angle` 协议无硬边界 → 0-100(同 window 口径), 合理。
- service 路由实算正确: seat/door/wiper/sunroof/fragrance=carControl, volume=cmd(注释明示 jsonl 实算 cmd 非 carControl)。

**轻微瑕疵(非 blocker)**: state-cells.yaml:171 注释引 `function-spec:61-63` 作座椅 0-3 出处, 但实查 function-spec-full.yaml:60-64 为 generic set_mode 段, 不含座椅 range; 0-3 真正一手权威是 CLAUDE.md:81。citation 行号轻微失准, **数值本身对**(0-3), 不影响 correctness。

## 2. naming_debt_clean — PASS

- `grep -rn 'hvac\.ac' Core/ Tests/ App/` → **0 残留**(EXIT=1=无匹配), 主链路完全清债。
- 唯一残留 `hvac.ac` 在 `contracts/function-spec-full-v0.yaml:46/62` — 该文件头明标 `⚠️ HISTORICAL / 过期(文档级联 2026-06-23)... 仅保留作 codegen schema 参考`, 且 **零代码引用**(`grep -rln function-spec-full-v0 Core/ Tests/ App/ scripts/` EXIT=1)。属 T5 historical, 边界允许。
- `ac.power` 真接管: FastPath(FastPathIntentEngine.swift:21 `"state_key":"ac.power"`) / DemoVehicleStateStore.swift:136/162/164(defaultCells + transition case) / ContentView.swift:109(`case "ac.power": return "空调"`)。
- capabilities.yaml:126 `state_cell: ac.power`(原 hvac.ac→ac.power 连带已改); CapabilityContractFileTests 3/0 通过。

## 3. devicecellmap_singlesource — PASS(S3 核心)

- **deviceCellMap = `public static let`**(ToolContractCompiler.swift:385), public ✓。
- **24 条映射**(python 解析): S2 7 + S3 17 = 24, 与规格一致。
- **每 value cellID 在 state-cells 存在**: 24 个 target cellID 全部命中 state-cells.yaml(无 logUnmapped 静默漏写)。
- **C3 executionCellID 真复用单源**: C3ExecutionPipeline.swift:156-162 `executionCellID` = `allowlist.entry(L1) ?? ToolContractStateApplier.deviceCellMap[frame.device]`; **switch 6-case 硬编码已删**(grep C3 仅剩 risk.evaluate/actionPrimitive/value.type 的合法业务 switch, 无 device→cell switch)。注释明示「消除 C3 switch / S2 deviceCellMap / allowlist 三处平行硬编码分叉 + fix 旧 switch 缺 ac_windspeed」(claim-vs-reality 铁律1)。
- 行为门测试: `testDeviceCellMapAllValuesExistInStateCells`(断言 count==24) / `testS3FamilyDeviceWritesStateNotUnmapped` / `testC3ExecutionCellReusesDeviceCellMapSingleSource` 全新增且通过。
- `apply` 路径 ToolContractCompiler.swift:422-425: 未映射 device → `logUnmapped` 不写 state(不静默吞), 测试 `testStateApplierUnmappedDeviceNoWrite`(seat_heat 旧名→unmapped)验证。

## 4. no_regression — PASS

并跑 parity 套件全绿:
- C3ContractLookupTests 5/0
- C3ExecutionPipelineTests 8/0
- C6VehicleToolBenchTests 34/0
- CapabilityContractFileTests 3/0

全量 swift test 134/0fail/3skip。L1_rows=76 未退化。

## 5. boundary_held — PASS

- S3 commit `59975c6` 触碰文件 = 任务边界规定的 **10 个文件**(App/ContentView, ToolContractCompiler, C3ExecutionPipeline, FastPathIntentEngine, DemoVehicleStateStore, 3 个 Tests, capabilities.yaml, state-cells.yaml), 无多无少。
- **未碰 C5/C6/训练/评测/语料 代码**: `git show --name-only HEAD | grep -iE 'C5|C6|train|eval|lora|bench|scorer|recompute|.py|gen_'` EXIT=1(clean)。
- **未建 191 全量 cell**: 新增 21 cell(6 族代表 cell), 总 33; 191 全量在注释中明标 DEFERRED(随 retrain-c5/rebuild-c6)。state-cells.yaml:172「191 全量 cell = DEFERRED; S3 只建 demo-positive 代表 cell」。
- 未改 historical T5 档口径数字(v0 yaml 的 hvac.ac 未动, 仅作 historical 保留)。

---

## 总评: PASS

S3 五维全 PASS, 两 gate 实跑绿(make verify EXIT=0 / swift test 134-0fail)。核心目标全达成:
1. state-cells 扩 6 族 21 代表 cell, schema 不变量全过, 座椅 0-3 真值对齐 CLAUDE.md:81 权威。
2. deviceCellMap public 单源 24 条, 全 target cellID 存在。
3. C3 executionCellID 删 switch 6-case 硬编码, 真复用 ToolContractStateApplier.deviceCellMap 单源(消除三处分叉 + fix ac_windspeed)。
4. hvac.ac 主链路 0 残留, ac.power 接管, capabilities 连带改。
5. 边界严守: 仅 10 文件, 未碰训练/评测, 未建 191 全量。

**唯一可记瑕疵**(非 blocker, 不降级): state-cells.yaml:171 注释引 `function-spec:61-63` 作座椅 0-3 出处行号轻微失准(实际权威是 CLAUDE.md:81), 数值本身正确。建议后续把 citation 改指 CLAUDE.md:81。

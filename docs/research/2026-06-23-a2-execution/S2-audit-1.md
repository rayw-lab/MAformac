# A2 S2 审计报告 — ToolContractCompiler data-driven 重写（独立审计员-1）

> as-of 2026-06-23 · 分支 `a2/migrate-d-domain-tool-surface` · commits cut1=722b93d / cut2=9f22a4c / cut3=659d0e0
> 审计边界：S2 ToolContractCompiler 3 刀（cut1 model-visible surface 迁 D-domain / cut2 Normalizer 消费 ir_map / cut3 StateApplier cell-driven applyGeneric）。code-only，不评模型性能/不训练/不生成语料。
> 纪律：所有数字/file:line 均实跑 grep/python/swift test 坐实，非凭印象。

---

## 0. 实跑命令总账（agent_ran_real_commands = true）

| 命令 | 退出码 | 结果 |
|---|---|---|
| `make verify` | **0** | regen→verify-refs→cross-section→diff→test 全过；cross-section `consistent:true caliber_violations:[]`；diff gate（regen 后 git diff --exit-code）无漂移 |
| `swift test` | **0** | **Executed 131 tests, 3 skipped, 0 failures** |

证据（一手 stdout）：
```
MAKE_VERIFY_EXIT=0
test_quarantine=ok / test_fc_flags=ok
"consistent": true / "caliber_violations": []

swift test:
	 Executed 131 tests, with 3 tests skipped and 0 failures (0 unexpected) in 7.295s
Test Suite 'ToolContractCompilerTests' passed — 13 tests
Test Suite 'C6VehicleToolBenchTests' passed
Test Suite 'C3ContractLookupTests' passed / C3ParamShapeNormalizationTests passed / C3ToolCallFrameAndDecodeTests passed
```

---

## 1. 范式对齐（行为门 grep 核，非信注释）— PASS

**关键发现：runtime model-visible surface = Swift `renderedToolsText` property，非 codegen `generated/rendered_tools_text` 文件。**

- `ToolContractCompiler.renderedToolsText`（`Core/Contracts/ToolContractCompiler.swift:64-68`）= `ToolContractJSONRenderer.render(["tools": dDomainToolSchemas])` → **只渲 562 D-domain 具名工具**，不含 frame。
  - grep 坐实：`dDomainToolSchemas`（:49-60）来自 `dDomainCatalog`（注入 generated/D_domain.tools.demo.json），无 `frameToolSchema` 进 surface。
  - test `testRenderedToolsTextOnlyDDomainNoGenericFrame`（passed）断言 `rendered.contains("tool_call_frame")==false` + `contains("adjust_ac_temperature_to_number")==true`。
- **surface 消费 catalog 562**：`python3 -c` 实测 `generated/D_domain.tools.demo.json` = **562** entries；`d_domain_ir_map.json` = **562**。test `testLoadDDomainCatalogProduces562Tools` / `testDDomainSurfaceConsumesCatalogNotHardcoded`（passed）。
- **旧 6 硬编码 set_cabin_* 真删（surface 侧）**：旧 Swift 无 `dDomainSurfaceNames` 硬编码常量定义（grep 无）；`testDDomainSurfaceConsumesCatalogNotHardcoded` 断言 `surfaceNames.contains("set_cabin_ac")==false`（passed）。`testEmptyCatalogProducesEmptySurface` 证空 catalog→空 surface（不再硬编码 6）。
- **generic frame off surface**：见上，runtime surface 不含 tool_call_frame。

**P2 笔记（docstring-vs-reality，非阻断）**：`generated/rendered_tools_text` 文件本身仍是**旧 7-name surface**（`tool_call_frame` + 6 set_cabin_* + query_cabin_comfort），由 `scripts/gen_tool_contract.py:279-282` 从 `b_frame + d_domain` 渲染。codegen docstring（:7-8,:34）写「旧 surface S1 守现状，**S2 删**」，但 S2 未删此 Python 产物。**无 Swift/runtime/test 消费 `generated/rendered_tools_text`**（grep `Core Tests` = NO consumer），故对 runtime 范式对齐**无影响**；但 codegen 注释承诺 vs 实际有 gap（见 finding S2-P2-1）。

verdict：surface_consumes_catalog_562=true / hardcoded_6_removed=true（surface 侧）/ generic_frame_off_surface=true（runtime surface）/ evidence_is_grep_not_comment=true → **PASS**

---

## 2. parity 核（最关键）— PASS

### 2a. parity gate 真 live（不是自盖章）
- C6 parity 测 `testContractApplierNormalizesDAndBFramesToSameStateDelta`（`C6VehicleToolBenchTests.swift:140-162`）**早于 S2 三刀已存在**（`git show 722b93d^:...` grep 命中=1，EXISTS pre-S2）。
- `C6MockStateApplier.apply`（`Core/Bench/C6VehicleToolBench.swift:1155-1162`）= 薄封装 → **直接 delegate `ToolContractStateApplier.apply`**（cut3 重写的目标）。故 C6 parity gate **真驱动 cut3 新 applier**。passed。
- cut3（659d0e0）**未触碰** `Core/Bench/C6VehicleToolBench.swift`（diff name-only 无此文件）→ parity gate 测试与 delegation 都是 S2 之前固定的锁，非本步新加来盖自己章。

### 2b. cut3 真替旧 8 applyXxx（strangler）
`git show 659d0e0^:ToolContractCompiler.swift` 旧实现 = applyAC/applyTemperature/applyFan/applyWindow/applyScreen/applyAmbientColor/applyAmbientBrightness（硬编码 8 路）；cut3 替为 cell-driven `applyEnumCell`/`applyNumericCell`（156 行 diff）。

### 2c. 手算 parity（OLD 硬编码 vs NEW cell-driven，python 复算）

| device 抽样 | 场景 | OLD | NEW | MATCH |
|---|---|---|---|---|
| **ac_temperature** | target=24 直写+depends_on | `{主驾:24, ac.power:on}` | `{主驾:24, ac.power:on}` | ✓ |
| ac_temperature | increase_by_exp pre=22 (+expStep2) | `{主驾:24, power:on}` | `{主驾:24, power:on}` | ✓ |
| ac_temperature | increase_by_exp 无 pre（default 24）| 26 | 26 | ✓ |
| **window** | percent=50 position=driver | `{主驾:50}` | `{主驾:50}` | ✓ |
| window | power_off 全区位 | 4 区位=0 | 4 区位=0 | ✓ |
| window | increase_by_exp 全区位 (+expStep20) | 4 区位=20 | 4 区位=20 | ✓ |
| window | power_on 无 target→100 全区位 | 4 区位=100 | 4 区位=100 | ✓ |
| **screen** | increase_by_exp pre=70 (+expStep10) | 80 | 80 | ✓ |
| screen | by_percent target=40 | 40 | 40 | ✓ |
| fan | increase_by_exp 无 pre（default 1）| 2 | 2 | ✓ |

cell 元数据全 grep 坐实（state-cells.yaml）：scope.first（主驾/中控屏/面发光氛围灯）= 旧硬编码 key；exp_step.little（temp2/fan1/window20/screen10/ambient10）= 旧硬编码步长；5 numeric default（24/1/0/70/70）= 旧硬编码初值（`Int(... ?? "24") ?? 24` 等，逐一对账 ✓）；depends_on `[ac.power]` = 旧 applyTemperature 的 `state["ac.power"]="on"`。

### 2d. 发现的潜在 DIVERGENCE（latent，未被任何锁 gate 触发，非回归）
旧 `applyTemperature` 的 exp 路径**无 clamp**（`current±2` 可越界 16/34）；新 `applyNumericCell` exp 路径 `clampUpper/clampLower` **裁到 executionRange(18-32)**。
- 边界 case：从 18 `调低一点` → OLD=16 / NEW=18；从 32 `调高一点` → OLD=34 / NEW=32。
- **影响评估=无回归**：`contracts/c6-bench-cases.jsonl` 33 个 temp_setpoint case 实测取值仅 22/24/26（全在 18-32 内，grep 坐实），**无 case 触达越界边界** → 无锁 gate 被打破。且旧 fan/window/screen 本已 clamp，新行为令 ac_temperature 与其余一致，属**修正**而非破坏。归 finding S2-P2-2（latent，不阻断）。

verdict：c6_tests_pass=true / applyGeneric_equiv_old=「10 抽样全 MATCH；唯一差异=ac_temp exp 越界 clamp，无 bench case 触发、属向其余 device 看齐的修正」 / sampled=[ac_temperature, window, screen]（+fan/ambient 旁证）→ **PASS**

---

## 3. 无回归 — PASS

- `make verify` exit **0**；`swift test` **131 tests / 3 skipped / 0 failures**。
- **C3 parser 未 break**：`C3ContractLookupTests`（含 `testStateCellLookupReadsExecutionRangeExpStepScopeAndReadback`）+ `C3ParamShapeNormalizationTests` + `C3ToolCallFrameAndDecodeTests` 全 passed。
- cut3 parser 扩（`ContractLookups.swift` default/depends_on）= 纯 additive `else if` 分支（`git show 659d0e0 -- ContractLookups.swift` 实证），`StateCellDefinition` 加可选字段（默认 nil/[]），向后兼容。enum cell 的 `default:`（off/stopped/P 等）被 parser 收进 `defaultValue` 但 apply 仅在 `applyNumericCell:435` 读，enum 路径忽略 → 无副作用。

verdict：make_verify_exit=0 / swift_test_count=131 / swift_test_fail=0 / c3_parser_not_broken=true → **PASS**

---

## 4. 边界守住 — PASS

- **无 C5/C6/训练/评测代码改动**：`git diff --name-only 722b93d^..659d0e0` = 仅 `Core/Contracts/ToolContractCompiler.swift` + `Core/Contracts/ContractLookups.swift` + `Tests/.../ToolContractCompilerTests.swift` + `contracts/state-cells.yaml` + 1 doc INDEX。grep `Training|Bench|C5|C6|eval` = **0 命中** → 未碰。
- **不训练/不评测**：无任何训练/eval 调用改动。
- **只 5 族 demo-positive**：cut3 `deviceCellMap`（:384-392）= 7 device（ac/ac_temperature/ac_windspeed=空调族, window, screen_brightness, atmosphere_lamp_color/brightness=氛围灯族）跨 ac/window/screen/ambient/fan **5 族**，未覆盖 191；未映射 device（如 atmosphere_lamp_change_speed/seat_heat）走 `logUnmapped` stderr 不写态（`testStateApplierUnmappedDeviceNoWrite` passed），符合「S3 才扩 191」。

verdict：no_c5c6_change=true / no_training_no_eval=true / only_5_families=true → **PASS**

---

## 5. strangler 边界保留 — PASS

- **frameToolSchema 物理保留**：`ToolContractCompiler.swift:33-47` 仍在；消费方 `Core/Training/C5LoRATraining.swift:1954` + `:1958`（grep 坐实）→ C5 训练 surface 依赖未断。test `testFrameSchemaKeptForStrangler` passed。
- **旧 6 set_cabin_* + query_cabin_comfort + tool_call_frame normalize case 保留**：`ToolContractNormalizer.normalize` switch（:162-183）`tool_call_frame`/`set_cabin_ac`/`set_cabin_window`/`set_cabin_screen_brightness`/`set_cabin_ambient_light`/`set_cabin_fan`/`query_cabin_comfort` 全在（grep 7 case 命中）。cut2 在 switch 前加 `if let entry = irMap[call.name]` D-domain 优先查表，**旧 switch 作 fallback strangler 完整保留**。test `testNormalizeOldSurfaceStranglerKept` passed（set_cabin_ac→device ac）。

verdict：frameToolSchema_kept=true / old_6_normalize_kept=true → **PASS**

---

## 6. cell SSOT enforce — PASS（含 1 个 P2 docstring gap）

- cut3 从 cell 元数据派生（execution_range→clamp / exp_step.little→步长 / default→初值 / depends_on→联动 / scope→区位 key），代码无重复硬编码 24/70/expStep（旧 8 applyXxx 的硬编码值已移除，改读 `cell.executionRange/expStepLittle/defaultValue/dependsOn/scope`）。
- 5 default（24/1/0/70/70）= 旧硬编码初值，逐一对账 ✓（见 2c）。

---

## 7. half-write / 提交一致性

- `git status --short` = 仅 `M docs/lessons-learned.md`（**与 S2 无关**，前序步遗留）。
- S2 四源文件（compiler/lookups/state-cells/test）**无 uncommitted diff**（`git diff --stat` 空）→ 三刀完整落库，无半写入。
- 每 commit 文件域干净（cut1: compiler+test+doc；cut2: compiler+test；cut3: lookups+compiler+test+state-cells）。

---

## Findings

| id | sev | file:line | claim vs reality | evidence | fix |
|---|---|---|---|---|---|
| S2-P2-1 | P2 | `scripts/gen_tool_contract.py:7-8,34,279-282` + `generated/rendered_tools_text` | codegen docstring 写「旧 surface S2 删」，但 S2 未删 `generated/rendered_tools_text`（仍含 tool_call_frame+6 set_cabin_*）。**无 runtime/Swift/test 消费此文件**（grep NO consumer），对范式对齐无害；但 codegen 承诺 vs 实际 gap。 | `python3` 实测 rendered_tools_text 7 names 含 tool_call_frame；`grep -rn rendered_tools_text Core Tests`=无消费 | S3/S4 删 `frame_schema()`/`d_domain_tools()` 时一并停写 rendered_tools_text + B_frame.frame_schema.json + D_domain.tools.json，或更新 docstring「S3/S4 删」对齐实际节奏（避免注释成第10坑式分叉） |
| S2-P2-2 | P2 | `ToolContractCompiler.swift:441-446`（NEW applyNumericCell exp clamp） | NEW ac_temperature exp 路径 clamp 到 18-32，OLD applyTemperature 无 clamp（可越界 16/34）。**latent 差异，无 bench case 触发**（c6 cases temp 仅 22/24/26），且令 ac_temp 与已 clamp 的 fan/window/screen 一致=修正非回归。 | `git show 659d0e0^` OLD applyTemperature 无 min/max；c6-bench-cases.jsonl grep temp 取值 ∈{22,24,26} | 不需修（修正方向正确）；若 S3 训练/eval 引入 18/32 边界 exp case，确认 LoRA 数据/gold 与 clamp 后口径一致即可 |

无 P0/P1。

---

## 总判

| 维度 | verdict |
|---|---|
| paradigm_aligned | **PASS** |
| parity | **PASS**（gate 真 live + 10 抽样手算全 MATCH + 唯一差异是无 case 触发的越界 clamp 修正）|
| no_regression | **PASS**（131/0fail，C3 parser 未 break）|
| boundary_held | **PASS**（0 C5/C6/训练/评测改动，只 5 族）|
| strangler_kept | **PASS**（frameToolSchema + 旧 6 normalize + frame normalize 全留）|

**overall = CLEAR**（2 个 P2 docstring/latent 笔记，不阻断 S2 收口）

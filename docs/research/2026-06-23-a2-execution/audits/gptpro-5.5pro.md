# PR #3 深度代码审计报告

## PR 摘要
PR #3（`feat(a2): C1→C6 全链路迁 D-domain 具名工具 surface (code-only 范式对齐)`）当前 head 为 `80dba834165faf96e3d62cc49ccb1c0afb399f31`，base 为 `c4a7d1a8cea41b7cd546be35b960474a218d472c`。实读 GitHub PR 元数据与本地 fetched PR head 后，变更规模为 **348 files changed / +70,084 / -47,469**。我在临时 worktree `/tmp/maformac-pr3.L8SKRV` 执行了 `swift test` 与 `make verify`：`swift test` 结果为 **145 tests, 3 skipped, 0 failures**；`make verify` 通过，含 `verify_gold` **57/57 pass** 与 `surface_consistency` pass。整体风险等级：**MEDIUM**。主干 demo-scope A2 验收路径基本成立，但存在两个需要合并前处理或明确降级的风险：`--scope full --surface dDomain` 的 C5 catalog 形态与 Swift decoder 不兼容；`contracts/qwen-tool-call-format.yaml` 仍是 D-domain tools/field mapping 的 TODO，与“C5/C6 同源格式契约”口径不一致。

## 审计范围与方法
- PR URL: https://github.com/rayw-lab/MAformac/pull/3
- PR head: `80dba834165faf96e3d62cc49ccb1c0afb399f31`
- PR base: `c4a7d1a8cea41b7cd546be35b960474a218d472c`
- PR 状态: `OPEN`, merge state `CLEAN`, GitHub status checks: `[]`
- 本地取证: fetched `pull/3/head` 到临时 worktree，读取 diff、源码、生成产物、测试、Makefile、OpenSpec change。
- 已执行验证: `swift test`、`make verify`、额外 Python catalog shape probe。
- 审计边界: 按 A2 code-only 铁律，不把“未实际训练/未跑模型性能评测/LoRA base hard_fail/受限解码 deferred”作为缺陷；验收锚点按 code surface + compile/test/verify + 57/57 gold replay。

## 关键结论

### 整体 Verdict: REQUEST_CHANGES
理由：demo-scope A2 主路径已接近可合并，且 C5/C6 值键 parity、irMap load-bearing、57/57 gold replay 都有测试和 verify 证据；但当前 PR 对外暴露了 `--scope full --surface dDomain`，代码按 `DDomainToolEntry` 解码 `generated/D_domain.tools.full.json`，而该 full 文件实际是 `{domain,name,sg}` 骨架，1538/1538 条都缺 `function`。这会导致 full-scope D-domain 训练样本构建路径不可用，和 A2 “D-domain surface”命名空间口径冲突。另一个风险是 `qwen-tool-call-format.yaml` 仍声明 tools/field mapping “A2 后回填”，而 C5/C6 已实际改为读取 generated catalog；这会重新制造格式契约漂移点。

## 8 维度详细评分表

| 维度 | 分数 | Verdict | 证据 file:line | 结论 | 改进建议 |
|---|---:|---|---|---|---|
| 1. 架构合规性 | 3/5 | NEEDS_FIX | `Core/Contracts/ToolContractCompiler.swift:27-31`, `Core/Contracts/ToolContractCompiler.swift:62-67`, `Core/Contracts/ToolContractCompiler.swift:165-197`, `Tools/C5TrainingCLI/main.swift:33-38`, `generated/D_domain.tools.full.json:6672-6675`, `scripts/gen_tool_contract.py:157-170`, `scripts/gen_tool_contract.py:286-295` | Demo model-visible surface 已从 generic frame 切到 D-domain catalog；Normalizer 优先 irMap，legacy frame/set_cabin 保留为 strangler，符合 A2 大方向。但 full-scope catalog 被生成成轻量骨架，C5 CLI 却按完整 DDomain schema catalog 解码，full path contract 不成立。 | 合并前二选一：要么让 full catalog 也输出完整 `type/function/parameters/_ir/_domain/_sg`，并补 full-scope decode/emit 测试；要么把 C5 CLI 的 `.full + .dDomain` 明确禁用/标 DEFERRED，避免假暴露。 |
| 2. 代码质量 | 4/5 | PASS_WITH_NOTES | `Core/Training/C5LoRATraining.swift:2027-2055`, `Core/Training/C5LoRATraining.swift:2377-2408`, `Core/Training/C5LoRATraining.swift:2515-2536`, `Core/Contracts/ToolContractCompiler.swift:378-391`, `Core/Contracts/ToolContractCompiler.swift:432-440` | C5 renderer 做到了只 emit schema 内参数，C6 state applier 单点归一，副作用集中。问题是 `catalog 非空但 intent 缺失 = fail-loud` 的注释实际只是 stderr + legacy frame fallback；在 demo scope 因过滤一般不会触发，但这不是严格 fail-closed。 | 对 `.dDomain` 且 catalog 非空的 miss 改成 build failure 或显式 invalid sample，不要 fallback 到 `tool_call_frame`；legacy fallback 仅限 `surface=.frame` 或 catalog empty。 |
| 3. 测试覆盖 | 4/5 | PASS_WITH_GAP | `Tests/MAformacCoreTests/ToolContractCompilerTests.swift:8-17`, `Tests/MAformacCoreTests/ToolContractCompilerTests.swift:19-37`, `Tests/MAformacCoreTests/C5LoRATrainingTests.swift:905-930`, `Tests/MAformacCoreTests/C5LoRATrainingTests.swift:933-999`, `Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift:675-723` | 测试补得很对：562 catalog、surface 无 frame、C5 hetero value key、C6 irMap fail-closed、C5/C6 temperature key parity 都覆盖了。缺口是没有覆盖 `--scope full --surface dDomain` 的 catalog decode/emit，也没有对 full-only sanitized intent 做回归。 | 新增 `C5TrainingCLI` 或 builder 层 full-scope 测试：加载 `generated/D_domain.tools.full.json` 后应能 decode 并 emit D-domain，或明确抛出“full deferred”错误。另加 `set_Ibooster_mode`/`set_ibooster_mode` sanitize 测试。 |
| 4. 安全风险 | 4/5 | PASS | `Tools/C5TrainingCLI/main.swift:28-40`, `Core/Training/C5LoRATraining.swift:2027-2055`, `scripts/requirements.txt:1-3`, `contracts/semantic-function-contract.jsonl:1699` | 未见 secret 注入、SQL/XSS、网络执行、反序列化执行类风险；依赖为 pinned Python package；训练 CLI 读取本地 contract 与生成产物。生成样本仍只保存 hash/contract 元信息，未把 raw 原文引入报告证据。 | 保持 raw 只读和 hash-only 纪律。对 JSON/YAML decode failure 给清晰错误，不要 stderr 后继续生成旧 surface。 |
| 5. 性能影响 | 4/5 | PASS_WITH_NOTES | `Core/Training/C5LoRATraining.swift:2058-2083`, `Core/Bench/C6VehicleToolBench.swift:947-952`, `Core/Contracts/ToolContractCompiler.swift:378-391`, `generated/D_domain.tools.demo.json:1-24` | D-domain catalog 562 schema 较大，但 C5 prompt 只取目标 + 同族 distractor，不是全量挂载；C6 evaluation 走一次 normalize/apply，未见 hot loop/N+1。PR 增加大量 generated JSON，对仓库体积与 review 成本有影响，但运行时风险可控。 | 如果未来 full catalog 也输出完整 schema，需评估文件大小和 decode 成本；C5 sample 构建可缓存 catalogByName/propertyEnums。 |
| 6. 依赖与兼容性 | 3/5 | NEEDS_FIX | `scripts/requirements.txt:1-3`, `Package.swift:20-40`, `Tools/C5TrainingCLI/main.swift:33-38`, `generated/D_domain.tools.full.json:6672-6675`, `Core/Contracts/ToolContractCompiler.swift:100-119` | 没有新增高风险依赖，Python deps pinned。兼容性主要问题不是第三方包，而是 full catalog 产物格式与 Swift `DDomainToolEntry` 不兼容；`Package.swift` 还会因 exclude 不存在的 `Reports` 产生 SwiftPM warning。 | 修 full catalog schema/decoder；清理 `Package.swift` 里不存在的 `Reports` exclude 或提交空目录替代，减少 warning 噪声。 |
| 7. 可读性 + 可维护性 | 3/5 | NEEDS_DISCUSSION | `contracts/qwen-tool-call-format.yaml:1-20`, `openspec/changes/rebuild-c6-four-layer-bench/specs/vehicle-tool-bench/spec.md:16-18`, `openspec/changes/rebuild-c6-four-layer-bench/tasks.md:12-16`, `scripts/gen_tool_contract.py:276-284`, `Core/Contracts/ToolContractCompiler.swift:394-428` | 代码注释把 A2 边界写得清楚，strangler 解释也足够。但 `qwen-tool-call-format.yaml` 仍写“tools A2 后回填 / scripts 仍硬编码旧 6”，和当前 C5/C6 实际从 generated demo catalog 读取不一致；旧 `generated/rendered_tools_text`/`D_domain.tools.json` 继续生成，容易给后续 agent 制造双源误判。 | 把 `qwen-tool-call-format.yaml` 改成明确引用 `generated/D_domain.tools.demo.json` + digest/field mapping，或把工具集合真正回填为机器可校验引用；旧 6 产物加 historical banner 或移出 active verify surface。 |
| 8. CI / lint / format | 2/5 | NEEDS_FIX | `Makefile:24-42`, `Package.swift:20-40`, `.github` absent, GitHub PR `statusCheckRollup=[]` | 本地 `swift test` 与 `make verify` 都通过，但 GitHub PR 没有 status checks；仓库没有 `.github/workflows`；`make verify` 不包含 `swift test`，只能靠人工双跑；SwiftPM 还有 invalid exclude warning。 | 新增 CI workflow 跑 `swift test` + `make verify`；或至少新增 `make verify-all` 聚合二者并在 PR check 里执行。清理 SwiftPM warning。 |

## 主要发现（P0/P1/P2）

### P0
未发现 P0。没有看到会立即破坏 demo-scope 57/57 gold replay、引入训练/评测越界执行、泄露 secret/raw、或改动 LoRA 配方的阻断级问题。

### P1-1: `--scope full --surface dDomain` 暴露但不可用
- Evidence: `Tools/C5TrainingCLI/main.swift:33-38` 根据 `options.scope == .full` 加载 `generated/D_domain.tools.full.json` 并按 `[DDomainToolEntry]` decode。
- Evidence: `Core/Contracts/ToolContractCompiler.swift:100-119` 的 `DDomainToolEntry` 需要 `type` 与 `function`。
- Evidence: `scripts/gen_tool_contract.py:157-170` 只有 `scope == "demo"` 输出完整 function schema；`scripts/gen_tool_contract.py:286-295` 同时产出 demo/full，但 full 的自检只按 `t["name"]` 计数。
- Evidence: `generated/D_domain.tools.full.json:6672-6675` 实际 full entry 是 `{domain,name,sg}`，没有 `function`。
- Extra probe: full count 1538，`full_missing_function=1538`；demo count 562，`demo_missing_function=0`。
- Impact: PR 的 demo path 是绿的，但 C5 CLI 提供的 full D-domain path 是一个会 decode failure 的公开选项；如果后续 C5 retrain 误用 full，会在正式执行前断，或诱导 agent 绕回旧 surface。
- Fix: 让 full catalog 与 demo catalog 同 schema，或显式禁用 full D-domain 并把 CLI help/receipt/tasks 标为 deferred；补 full-scope regression。

### P1-2: `qwen-tool-call-format.yaml` 没有同步成 D-domain tools/field mapping 的可校验单源
- Evidence: `contracts/qwen-tool-call-format.yaml:1-3` 自称 C5/C6 只引用本文件防 drift。
- Evidence: `contracts/qwen-tool-call-format.yaml:9-12` 仍写 tools 字段 A2 后回填、script 仍硬编码旧 6。
- Evidence: `contracts/qwen-tool-call-format.yaml:20` 仍是 `# tools: [TBD-A2 ...]`。
- Evidence: `openspec/changes/rebuild-c6-four-layer-bench/specs/vehicle-tool-bench/spec.md:16-18` 要求 `qwen-tool-call-format.yaml` SHALL 定义 D-domain 工具名集合与字段映射。
- Impact: 实际 C5/C6 已经从 `generated/D_domain.tools.demo.json` 取 surface，但格式契约文件仍是 TODO。它不会让当前 tests fail，却会重新引入“train/runtime/bench 各写一套”的漂移风险。
- Fix: 把 qwen format 改成机器可校验引用，例如声明 `tool_catalog: generated/D_domain.tools.demo.json`、`ir_map: generated/d_domain_ir_map.json`、digest 字段和参数键规则；或者真正生成/嵌入字段映射，并纳入 `verify-surface`。

### P2-1: GitHub PR 没有 CI status checks，`make verify` 也不包含 `swift test`
- Evidence: GitHub PR `statusCheckRollup=[]`。
- Evidence: `.github` 目录不存在。
- Evidence: `Makefile:32-42` 的 `verify` 只跑 Python/source/regen/surface/diff/test，不跑 `swift test`。
- Impact: 当前通过依赖人工本地双跑；348 文件的大 PR 没有 CI 门，容易把 Swift 编译/测试和 generated diff gate 分开漏跑。
- Fix: 增加 GitHub Actions 或其他 CI，至少跑 `swift test` + `make verify`；可加 `make verify-all` 聚合。

### P2-2: SwiftPM warning 需要清理
- Evidence: `Package.swift:20-40` exclude 包含 `Reports`。
- Observed: `swift test` 输出 `Invalid Exclude .../Reports: File not found.`
- Impact: 不影响通过，但污染验收日志，长期会掩盖真正 warning。
- Fix: 删除不存在的 exclude 项，或提交/生成该路径前置。

## A2 重点核验

### D-domain surface 完整性
- `ToolContractCompiler.loadDDomainCatalog` 加载 `generated/D_domain.tools.demo.json`，见 `Core/Contracts/ToolContractCompiler.swift:27-31`。
- model-visible renderer 只输出 `dDomainToolSchemas`，不再输出 frame，见 `Core/Contracts/ToolContractCompiler.swift:62-67`。
- Tests 证明 562 catalog 与无 `tool_call_frame`，见 `Tests/MAformacCoreTests/ToolContractCompilerTests.swift:8-37`。
- C5 positive samples 使用 `seed.intent` 作为 tool name，见 `Core/Training/C5LoRATraining.swift:2515-2528`。
- C6 must-pass expected calls 已迁到 D-domain 名，如 `open_ac`、`adjust_ac_temperature_to_number`、`adjust_ac_windspeed_to_number`，见 `Core/Bench/C6VehicleToolBench.swift:356-385`。

### C5 emit 与 C6 expected 值键同源
- C5 renderer 只 emit schema properties 内的 key，见 `Core/Training/C5LoRATraining.swift:2027-2055`。
- C5 test 覆盖 `temperature` 与 `fanSpeed`，并断言不 emit `value`，见 `Tests/MAformacCoreTests/C5LoRATrainingTests.swift:905-930`。
- C6 matcher 是字面 surface-string 比对，见 `Core/Bench/C6VehicleToolBench.swift:1150-1163`。
- C6 expected 使用 `temperature`/`fanSpeed`/`value` 的异构键，见 `Core/Bench/C6VehicleToolBench.swift:362-365`、`Core/Bench/C6VehicleToolBench.swift:379-385`。
- C6 test 验证 `adjust_ac_temperature_to_number` schema 和 expected 都用 `temperature` 而非 `value`，见 `Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift:707-723`。

### LoRA 配方零碰
- 当前 `rank16Mainline` 仍是 rank 16、scale 20、LR 0.0001、cosine/warmup 0.08、epochs 3、batch 4，见 `Core/Training/C5LoRATraining.swift:1210-1226`。
- Diff probe 未发现 `rank16Mainline|learningRate|rank|adamw|optimizer` 相关变更。

### Strangler 与 irMap fail-closed
- Legacy `tool_call_frame` 与旧 `set_cabin_*` normalize switch 仍保留，见 `Core/Contracts/ToolContractCompiler.swift:165-197`，符合 A2 strangler 兼容策略。
- C6 CLI 在 summarize 与 verify-gold 路径加载 irMap，见 `Tools/C6BenchCLI/main.swift:92-103` 与 `Tools/C6BenchCLI/main.swift:136-144`。
- Tests 反证无 irMap 会 fail，证明 irMap 是 load-bearing，不是装饰，见 `Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift:675-693`。

### A2 边界
- C5 CLI 生成训练数据、MLX config 和命令收据，但不实际训练，见 `Tools/C5TrainingCLI/main.swift:89-137` 与 `Tools/C5TrainingCLI/main.swift:165-186`。
- 本报告未把“未重训/未模型性能评测/LoRA absent hard_fail/受限解码 deferred”作为 bug。

## 具体待改 Punch List

- [ ] **Owner: PR author / P1** 修复或禁用 `--scope full --surface dDomain`：full catalog 要么输出完整 `DDomainToolEntry` schema，要么 CLI 明确 fail with deferred message。证据：`Tools/C5TrainingCLI/main.swift:33-38`, `generated/D_domain.tools.full.json:6672-6675`。
- [ ] **Owner: PR author / P1** 将 `.dDomain + non-empty catalog + missing intent` 从 stderr fallback 改成 hard failure/invalid sample。证据：`Core/Training/C5LoRATraining.swift:2515-2536`。
- [ ] **Owner: PR author / P1** 让 `contracts/qwen-tool-call-format.yaml` 与实际 D-domain catalog 单源对齐，至少用机器可校验字段引用 `generated/D_domain.tools.demo.json` 与 `generated/d_domain_ir_map.json`。证据：`contracts/qwen-tool-call-format.yaml:1-20`。
- [ ] **Owner: PR author / P2** 增加 full-scope/sanitized intent 回归测试，覆盖 `set_Ibooster_mode` → `set_ibooster_mode` 或明确 deferred。证据：`contracts/semantic-function-contract.jsonl:1699`, `scripts/gen_tool_contract.py:105-109`, `scripts/gen_tool_contract.py:311-313`。
- [ ] **Owner: repo maintainer / P2** 增加 CI check 跑 `swift test` + `make verify`；当前 GitHub checks 为空。证据：`Makefile:32-42`。
- [ ] **Owner: repo maintainer / P2** 清理 SwiftPM `Reports` invalid exclude warning。证据：`Package.swift:20-40`。
- [ ] **Owner: PR author / P2** 给旧 `generated/D_domain.tools.json` / `rendered_tools_text` 加 active/historical 明确标记，或从 active contract 文档中降级，避免后续 agent 误读旧 6 surface。证据：`scripts/gen_tool_contract.py:276-284`。

## 已验证命令

```bash
swift test
# 145 tests, 3 skipped, 0 failures

make verify
# surface_consistency pass
# verify_gold: total_cases=57, violation_count=0
# git diff --exit-code pass
```

## 审计时间 / 模型 / Commit
- 审计时间: 2026-06-23 Asia/Shanghai
- 模型: GPT-5 Codex
- PR head commit SHA: `80dba834165faf96e3d62cc49ccb1c0afb399f31`

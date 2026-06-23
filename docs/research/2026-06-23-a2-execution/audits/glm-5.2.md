# PR #3 深度代码审计报告

## PR 摘要

PR #3（`feat(a2): C1→C6 全链路迁 D-domain 具名工具 surface (code-only 范式对齐)`）将 model-visible surface 从 generic `tool_call_frame` 迁移到 D-domain 具名工具，head `80dba834165faf96e3d62cc49ccb1c0afb399f31` 相对 base `c4a7d1a8cea41b7cd546be35b960474a218d472c` ahead 22 commits；PR 元数据为 **348 changed files / +70,084 / -47,469**。实读代码后，主链路显示：运行时 `renderedToolsText` 只渲染 D-domain catalog，C5 CLI 默认注入 demo catalog，C5 emit 已覆盖 `temperature` / `fanSpeed` / `value` 的异构值键，C6 expected 已迁 D-domain，`verify-gold` / summarize 通过 `irMap` normalize→state，rank16Mainline 配方未改。主要残余风险是：库层 `.dDomain` 在 catalog 空或 intent miss 时仍可落回 frame，数字 direct target 在 state applier 中不 clamp，GitHub connector 未发现 head workflow run。**整体风险等级：MEDIUM**。

## 审计范围与方法

- 审计对象：`rayw-lab/MAformac` PR #3
- Base SHA：`c4a7d1a8cea41b7cd546be35b960474a218d472c`
- Head SHA：`80dba834165faf96e3d62cc49ccb1c0afb399f31`
- 审计方式：通过 GitHub connector 实读 PR 元数据、changed files、commits/files diff、关键源码、测试、CLI、Makefile、Package.swift 与 CI/check 状态。
- 本次限制：我没有在本地 clone 后执行 `swift test` / `make verify`；CI connector 对 head 返回 `workflow_runs: []`，所以 CI 维度按“证据不足/需补强”处理。
- A2 边界解释：不把“base 无 LoRA hard_fail”“C5 实际重训 / C6 模型评测 / demo-golden-run / voice / 受限解码 DEFERRED”作为 bug；审计目标是 code-only D-domain surface 自洽与防 0/N 换皮 guardrail。

## 关键正向结论

1. **运行时 model-visible surface 已从 frame 切到 D-domain。**  
   `ToolContractCompiler.renderedToolsText` 只渲染 `dDomainToolSchemas`，不再拼接 `frameToolSchema`：`Core/Contracts/ToolContractCompiler.swift:64-69`。`frameToolSchema` 仍保留：`Core/Contracts/ToolContractCompiler.swift:35-49`，符合 strangler 兼容策略。

2. **D-domain catalog 与 IR map 进入 compiler / normalizer 主路径。**  
   Demo catalog 通过 `generated/D_domain.tools.demo.json` 加载：`Core/Contracts/ToolContractCompiler.swift:29-33`；IR map 通过 `generated/d_domain_ir_map.json` 加载：`Core/Contracts/ToolContractCompiler.swift:160-165`；normalizer 优先查 `irMap[call.name]`：`Core/Contracts/ToolContractCompiler.swift:167-170`。

3. **旧 surface strangler 保留但不在新 model surface。**  
   Legacy `tool_call_frame`、`set_cabin_*`、`query_cabin_comfort` normalize 分支仍在：`Core/Contracts/ToolContractCompiler.swift:172-198`。这属于兼容保留，不按 A2 bug 处理。

4. **C5 emit 与 C6 expected 的异构值键 parity 已有专门测试。**  
   测试 `testC5EmitsHeterogeneousValueKeyMatchingC6ForNumberIntents` 断言 `adjust_ac_temperature_to_number` 产 `temperature` 且不产 `value`，`adjust_ac_windspeed_to_number` 产 `fanSpeed` 且不产 `value`：`Tests/MAformacCoreTests/C5LoRATrainingTests.swift:908-933`。C6 must-pass 也使用 `temperature` 与 `fanSpeed`：`Core/Bench/C6VehicleToolBench.swift:360-390`。

5. **C6 verify-gold 路径是 irMap fail-closed。**  
   `verifyGold` 中 `try ToolContractNormalizer.loadIRMap(repoRoot:)` 失败会抛出，不会空 map 假绿：`Tools/C6BenchCLI/main.swift:138-146`。summarize 也注入 IR map：`Tools/C6BenchCLI/main.swift:94-105`。

6. **LoRA 配方零碰。**  
   `rank16Mainline` 仍为 rank 16 / scale 20 / LR 0.0001 / optimizer adamw / weightDecay 0.01 / gradClipNorm 1.0：`Core/Training/C5LoRATraining.swift:1210-1237`。

7. **A2 code-only 边界基本守住。**  
   `DeterministicPlaceholderGenerator` 明确 nil-stub，不调云 generator、不生成语料：`Core/Training/C5LoRATraining.swift:720-750`。C5/C6 的实际训练和模型评测仍是 CLI 能力，不是本 PR 执行结果。

## 8 维度详细评分表

| # | 审计维度 | Score | Verdict | 证据 file:line | 结论 | 改进建议 |
|---|---|---:|---|---|---|---|
| 1 | 架构合规性 | 4/5 | PASS_WITH_CAVEATS | `Core/Contracts/ToolContractCompiler.swift:64-69`; `Core/Contracts/ToolContractCompiler.swift:167-198`; `Core/Training/C5LoRATraining.swift:2524-2539`; `Core/Bench/C6VehicleToolBench.swift:360-390`; `Tools/C6BenchCLI/main.swift:138-146` | D-domain surface 主链路成立；frame 被移出 rendered surface；旧 frame / set_cabin 保留在 normalizer 作 strangler；C5/C6 surface 已同名同键。 | 对 `.dDomain` + catalog miss 从 stderr fallback 改成显式 error；保留 `.frame` 作为唯一 legacy 入口，减少误用。 |
| 2 | 代码质量 | 3/5 | NEEDS_IMPROVEMENT | `Core/Training/C5LoRATraining.swift:2518-2539`; `Core/Contracts/ToolContractCompiler.swift:470-487`; `Core/Contracts/ContractLookups.swift:94-107`; `Core/Contracts/ContractLookups.swift:205-278` | 核心实现可读，但有两处“声明强、行为弱”：D-domain miss 只 stderr 后 frame fallback；numeric direct target 不 clamp，虽 C3 执行会 range check，但 C6/gold state applier 直写。YAML parser 为手写轻 parser，长期维护脆。 | P1：D-domain miss fail-closed；P1/P2：state applier 对 direct target 使用 `ExecutionRange.contains` 或 clamp；P2：生成/集中维护 parser 规则或引入更明确的 contract parser。 |
| 3 | 测试覆盖 | 4/5 | PASS_WITH_GAPS | `Tests/MAformacCoreTests/ToolContractCompilerTests.swift:10-39`; `Tests/MAformacCoreTests/ToolContractCompilerTests.swift:57-93`; `Tests/MAformacCoreTests/C5LoRATrainingTests.swift:908-1018`; `Tests/MAformacCoreTests/ToolContractCompilerTests.swift:137-158` | 覆盖了 catalog=562、surface 不含 frame、normalizer、legacy strangler、C5 emit 异构键、same-family distractor、scope filter、no-call 真删、deviceCellMap reuse。 | 补测：`.surface=.dDomain` + catalog empty / intent missing 必须 fail；numeric out-of-range target；full catalog 1538 path；CI 上可执行的非本机路径测试。 |
| 4 | 安全风险 | 3/5 | MEDIUM_LOW | `.gitignore:53-60`; `Core/Contracts/ToolContractCompiler.swift:195-198`; `Core/Execution/C3ExecutionPipeline.swift:239-241`; `Core/Contracts/ToolContractCompiler.swift:470-487`; `Tools/C5TrainingCLI/main.swift:520-538`; `Tests/MAformacCoreTests/C5LoRATrainingTests.swift:713-746` | 未见 secret 注入、SQLi、XSS、反序列化执行面；`.claude/hooks` 与 local settings 被 ignore。主要安全/鲁棒性风险是输入值范围在 C6/gold state applier 中未强校验，且本机绝对路径含用户名、降低可移植性。 | 对所有 mock state 写入统一 range / enum validation；避免默认路径暴露本机用户名；未知 tool/device 在执行场景中升级为 typed error。 |
| 5 | 性能影响 | 4/5 | LOW_RISK | `Tools/C5TrainingCLI/main.swift:35-40`; `Tools/C6BenchCLI/main.swift:138-146`; `Core/Training/C5LoRATraining.swift:2061-2086`; `Core/Training/C5LoRATraining.swift:2524-2531` | 运行时未见 N+1 query、网络阻塞或大对象热循环；catalog/IR map 是本地 JSON 加载。C5 sample build 每个样本调用 same-family distractor 并排序 catalog，规模 562/1538 × 4500 时仍可接受但可优化。 | 预构建 by-device/by-domain index，避免每样本 sort/filter；把 catalog lookup/index 放入 builder context。 |
| 6 | 依赖与兼容性 | 4/5 | PASS_WITH_PORTABILITY_CAVEAT | `Package.swift:7-18`; `Package.swift:20-48`; `Package.swift:65-73`; `Tools/C5TrainingCLI/main.swift:520-538`; `Core/Training/C5LoRATraining.swift:1210-1237` | Swift package 未新增外部 package dependency；`generated` 被 exclude，CLI Python 脚本也排除在 Swift target 外。兼容性风险主要来自本机 Python / HuggingFace 路径硬编码。 | 将 Python 路径、base model dir 改为环境变量 / CLI 必填 / skip-if-missing test fixture；补 license scan 或 dependency lock 注释。 |
| 7 | 可读性 + 可维护性 | 3/5 | NEEDS_IMPROVEMENT | `Core/Contracts/ToolContractCompiler.swift:396-430`; `Tests/MAformacCoreTests/ToolContractCompilerTests.swift:137-143`; `Core/Execution/C3ExecutionPipeline.swift:158-165`; `Core/Bench/C6VehicleToolBench.swift:925-930` | 注释密度高，有助于保留 A2 边界语义；但 `deviceCellMap` 仍是手维护 24 entries，C6 state-mutating 判据基于 `!query_` 前缀，C5 renderer/builder 集中了过多职责。 | device→cell map codegen；把 C5 D-domain render/distractor/scope filter 拆成独立 type；把 read-only/state-mutating 从 IR metadata 推导，不用 name prefix。 |
| 8 | CI / lint / format | 2/5 | INSUFFICIENT_EVIDENCE | `Makefile:34-44`; `Makefile:72-73`; GitHub connector: `workflow_runs: []`; `Tests/MAformacCoreTests/C5LoRATrainingTests.swift:713-746` | Makefile 有 `verify-source → regen → verify-refs → verify-cross-section → verify-surface → diff → test`，surface gate 包含 C6 expected ⊆ D-domain catalog 与 verify_gold；但 connector 未发现 head workflow run，且部分 tests 依赖本机 `/Users/wanglei` 与 Homebrew Python，不适合作为通用 CI 直接运行。 | 合并前提供可复现 CI 或手工日志 artifact：`swift test`、`make verify`、`verify-gold 57/57`；新增 GitHub Action 或至少 PR check script；本机路径测试加 skip。 |

## 深入发现

### A. C1 → C6 D-domain surface 链路

- **C1/S1 catalog → Swift compiler**：`loadDDomainCatalog(repoRoot:)` 读取 `generated/D_domain.tools.demo.json`，测试断言 catalog count = 562，且包含 `adjust_ac_temperature_to_number` 与 `open_ac`：`Core/Contracts/ToolContractCompiler.swift:29-33`; `Tests/MAformacCoreTests/ToolContractCompilerTests.swift:10-19`。
- **Runtime surface**：`renderedToolsText` 只渲 `dDomainToolSchemas`，不渲 `frameToolSchema`：`Core/Contracts/ToolContractCompiler.swift:64-69`。测试断言 rendered 不含 `tool_call_frame`：`Tests/MAformacCoreTests/ToolContractCompilerTests.swift:32-39`。
- **Normalizer**：D-domain name 优先查 `irMap`，旧 `tool_call_frame` / `set_cabin_*` 在 switch 中保留：`Core/Contracts/ToolContractCompiler.swift:167-198`。
- **C3 执行**：C3 `executionCellID` 复用 `ToolContractStateApplier.deviceCellMap`，避免 C3 与 C6 两套 device→cell 映射：`Core/Execution/C3ExecutionPipeline.swift:158-165`。
- **C5 训练 emit**：D-domain path 中 `call.name = seed.intent`，tools 为目标 schema + same-family distractors：`Core/Training/C5LoRATraining.swift:2524-2531`。
- **C6 bench expected**：must-pass expected tool calls 已从 `set_cabin_*` 迁到 `open_ac`、`adjust_ac_temperature_to_number`、`adjust_ac_windspeed_to_number`、`switch_atmosphere_lamp_color` 等具名工具：`Core/Bench/C6VehicleToolBench.swift:360-390`。
- **C6 verify/summarize**：`verifyGold` 与 summarize 均加载 `irMap`：`Tools/C6BenchCLI/main.swift:94-105`; `Tools/C6BenchCLI/main.swift:138-146`。

Verdict：**PASS_WITH_CAVEATS**。核心路径成立；需把库层 fallback guardrail 再收紧。

### B. C5/C6 同源同名同值键防 0/N 换皮

- C6 expected 使用 `temperature` 与 `fanSpeed`：`Core/Bench/C6VehicleToolBench.swift:360-390`。
- normalizer `buildValue` 读 `value` / `temperature` / `fanSpeed`：`Core/Contracts/ToolContractCompiler.swift:235-260`。
- C5 D-domain args 只 emit catalog schema properties 内的键，防 additionalProperties:false 违规：`Core/Training/C5LoRATraining.swift:2030-2046`。
- 测试明确断言 C5 emit `temperature` / `fanSpeed` 而不是 `value`：`Tests/MAformacCoreTests/C5LoRATrainingTests.swift:908-933`。

Verdict：**PASS**。这正是 A2 防 0/34 换皮的关键闭环。

### C. 配方零碰

`rank16Mainline` 当前仍是：

- rank = 16
- scale = 20
- learningRate = 0.0001
- optimizer = adamw
- weightDecay = 0.01
- gradClipNorm = 1.0

证据：`Core/Training/C5LoRATraining.swift:1210-1237`。

Verdict：**PASS**。未把配方重开为本 PR 变量。

### D. Strangler 兼容

- Runtime surface 移除 frame：`Core/Contracts/ToolContractCompiler.swift:64-69`。
- frame schema 仍存在：`Core/Contracts/ToolContractCompiler.swift:35-49`。
- normalizer 保留 `tool_call_frame` 与旧 `set_cabin_*`：`Core/Contracts/ToolContractCompiler.swift:172-198`。
- 测试覆盖 empty catalog fallback 到 frame legacy：`Tests/MAformacCoreTests/C5LoRATrainingTests.swift:1021-1029`。

Verdict：**PASS_WITH_P1_GUARDRAIL**。兼容策略合理，但 `.dDomain` 路径不应在 catalog miss 时静默回 frame。

### E. irMap fail-closed

- `loadIRMap` 用 `try JSONDecoder().decode`，文件缺失或格式错误会 throw：`Core/Contracts/ToolContractCompiler.swift:160-165`。
- `verifyGold` 强制 `try ToolContractNormalizer.loadIRMap(repoRoot:)`：`Tools/C6BenchCLI/main.swift:138-146`。
- unknown tool name `default` 分支写 stderr 并返回空 IR：`Core/Contracts/ToolContractCompiler.swift:195-198`；在 gold replay 中会导致 state delta 不匹配而 fail。

Verdict：**PASS for C6 verify/summarize**；runtime 执行层可进一步把 unknown tool 提升为 typed failure。

### F. A2 边界

- `DeterministicPlaceholderGenerator` 明确 nil-stub，注释写明不实装云 generator / 不生成语料：`Core/Training/C5LoRATraining.swift:720-750`。
- C5 CLI 是 prepare 能力而不是 PR 中执行训练；C6 Bench CLI 是 summarize/verify 能力而不是模型评测结果本身：`Tools/C5TrainingCLI/main.swift:27-40`; `Tools/C6BenchCLI/main.swift:21-33`。

Verdict：**PASS**。不把 C5 重训/C6 模型评测 DEFERRED 当缺陷。

## 主要风险与分级

### P1-1：`.surface=.dDomain` catalog miss 不是硬失败

**证据**：`Core/Training/C5LoRATraining.swift:2518-2539`

当前逻辑写了“catalog 非空但 intent 缺失 = fail-loud”，但实际行为是 stderr 写 `S4_DDOMAIN_MISS...`，然后 fallback 到 `tool_call_frame`。这会让 `.dDomain` 调用者误以为生成了 D-domain samples，实际混入 frame，重新制造 surface 混杂风险。

建议：

```swift
if surface == .dDomain {
    guard !catalog.isEmpty else { throw C5BuildError.missingDDomainCatalog }
    guard let entry = catalogByName[seed.intent] else { throw C5BuildError.intentMissingFromCatalog(seed.intent) }
}
```

保留 `.surface=.frame` 作为唯一 legacy/strangler fallback。

### P1-2：C6/gold state applier direct target 不 clamp

**证据**：`Core/Contracts/ToolContractCompiler.swift:470-487`; `Core/Contracts/ContractLookups.swift:94-107`

`applyNumericCell` 对 direct target 直接写入，不调用 `ExecutionRange.contains` 或 clamp。C3 runtime 的 `normalizeValue` 有 range check：`Core/Execution/C3ExecutionPipeline.swift:239-241`，但 C6/gold path 与 runtime 行为不完全一致。

建议：

- 对 `targetNumber(ir)` 结果进行 `ExecutionRange.contains`；
- 不合规时 log + no write / failure；
- 或与 C3 一样抛 typed schema error。

### P1-3：缺少可验证 CI 证据

**证据**：GitHub connector 对 head `80dba834165faf96e3d62cc49ccb1c0afb399f31` 返回 `workflow_runs: []`；Makefile 虽有 verify gate：`Makefile:34-44`，但无 GitHub check 记录。

建议：

- 加 GitHub Actions：`swift test`、`make verify`、可选 `swift-format` / lint；
- 或至少在 PR 附上可下载 logs/artifacts；
- 对依赖 `/Users/wanglei` 和 `/opt/homebrew/opt/python@3.13` 的测试加 `XCTSkipUnless`，否则通用 CI 不可复现：`Tests/MAformacCoreTests/C5LoRATrainingTests.swift:713-746`。

## 整体 verdict

**NEEDS_DISCUSSION**

理由：

- 不给 `REQUEST_CHANGES`：核心 A2 范式迁移代码路径基本成立，C5/C6 同名同值键关键闭环有测试，配方零碰，A2 code-only 边界守住，没有 P0/P0-security blocker。
- 不给 `APPROVE`：head 无 workflow run 记录；`.dDomain` catalog miss fallback 到 frame 是高风险 guardrail；C6/gold state applier 的 direct target 不 clamp 与 C3 runtime range check 不一致；本机路径测试影响可复现 CI。
- 建议合并条件：至少关闭 P1-1 或明确写入 owner 接受的 risk waiver；补 PR check/run logs；P1-2 可作为合并前修复或明确 deferred 但必须有测试/issue 跟踪。

## 具体待改 punch list

- [ ] **P1 / Owner: A2 Surface Owner** — 将 `.surface=.dDomain` 下 catalog empty / intent missing 从 stderr + frame fallback 改为 typed error；保留 `.surface=.frame` 作为 legacy 入口。证据：`Core/Training/C5LoRATraining.swift:2518-2539`。
- [ ] **P1 / Owner: Core Contracts Owner** — 在 `ToolContractStateApplier.applyNumericCell` 对 direct target 做 `ExecutionRange.contains` 或 clamp，并补 out-of-range 测试。证据：`Core/Contracts/ToolContractCompiler.swift:470-487`; `Core/Contracts/ContractLookups.swift:94-107`。
- [ ] **P1 / Owner: CI Maintainer** — 增加 PR workflow 或上传手工 artifacts，至少覆盖 `swift test`、`make verify`、`verify-gold 57/57`。证据：GitHub head `workflow_runs: []`; `Makefile:34-44`。
- [ ] **P1 / Owner: Test Infra Owner** — 将依赖 `/Users/wanglei/...` 与 `/opt/homebrew/opt/python@3.13/bin/python3.13` 的测试改成 skip-if-missing 或 fixture-driven。证据：`Tests/MAformacCoreTests/C5LoRATrainingTests.swift:713-746`; `Tools/C5TrainingCLI/main.swift:520-538`。
- [ ] **P2 / Owner: C5 Builder Owner** — 为 same-family distractor 预索引 by device / by domain，避免每个样本排序 catalog。证据：`Core/Training/C5LoRATraining.swift:2061-2086`; `Core/Training/C5LoRATraining.swift:2524-2531`。
- [ ] **P2 / Owner: C6 Bench Owner** — 将 `requiresStateDelta` 的 `!query_` 前缀判据改为 IR metadata / action mutability 判据。证据：`Core/Bench/C6VehicleToolBench.swift:925-930`。
- [ ] **P2 / Owner: Contracts Codegen Owner** — 将 `ToolContractStateApplier.deviceCellMap` codegen 化，避免 24 entries 手维护。证据：`Core/Contracts/ToolContractCompiler.swift:396-430`; `Tests/MAformacCoreTests/ToolContractCompilerTests.swift:137-143`。
- [ ] **P2 / Owner: CLI Owner** — 将 C5 CLI 默认 base model path、Python path 改为环境变量或显式参数，并清理默认路径中的个人用户名暴露。证据：`Tools/C5TrainingCLI/main.swift:520-538`; `Tools/C5TrainingCLI/main.swift:167-188`。
- [ ] **P3 / Owner: UI/State Owner** — 逐步清理 `DemoVehicleStateStore` 中旧 key 与新 C2 key 的混放，保留迁移说明，防后续 UI 读取旧 key。证据：`DemoVehicleStateStore.swift:136-159`; `App/ContentView.swift:95-125`。

## 合并建议

建议路径：

1. 合并前最小修复：P1-1 + P1-3。
2. 合并前或合并后首个 patch：P1-2 + P1 测试可移植性。
3. 后续 A2 follow-up：deviceCellMap codegen、distractor index、state-mutating metadata 化。

在这三个条件满足前，本 PR 不建议直接 `APPROVE`。

## 审计尾注

- 审计时间：2026-06-23 07:17:07 PDT
- 模型：GPT-5.5 Pro
- PR：#3
- Base SHA：`c4a7d1a8cea41b7cd546be35b960474a218d472c`
- Commit SHA：`80dba834165faf96e3d62cc49ccb1c0afb399f31`

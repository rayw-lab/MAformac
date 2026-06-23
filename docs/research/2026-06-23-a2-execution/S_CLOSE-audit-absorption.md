# A2 S_CLOSE — GPT Pro + GLM-5.2 双审计吸收 + DEFERRED 分类

> 2026-06-23 · 两份云端审计（GPT Pro 5.5 Pro + hermes GLM-5.2，跑同一 prompt，内容不同）三角分诊。
> 报告原件：`~/Downloads/pr_audit_3.md`(GPT Pro) + `~/Downloads/pr_audit_3(1) (1).md`(GLM)。
> 已修 findings 见 commit；本文吸收**非已修的所有意见**（磊哥要求），按 GPT Pro 组织原则分 **A2-intentional / 已修 / post-A2 debt**。

## 1. 已修（本轮 commit 闭合）
| finding | 来源 | 修法 | 验证 |
|---|---|---|---|
| **P0 `--scope full` 解码崩** | GPT Pro 独有 | C5 prepare fail-fast-first（full=skeleton 无 schema, 只 demo 训练）| 实跑 `--scope full` 报清晰错误非 DecodingError |
| **P1 dDomain miss → frame fallback** | both 共识 | makePositiveSample 返 optional, miss→fail-closed skip(不污染 frame) + variants compactMap | +testDDomainCatalogMissIsFailClosedNotFrameFallback |
| **P1-2 direct target 不 clamp** | GLM 独有 | applyNumericCell direct clamp 到 executionRange(与 C3+exp 路径一致) | verify-gold 57/57 不破(in-range no-op) |

## 2. A2-intentional（审计列为风险但 = A2 边界故意，steelman 守住，非 bug）
- **base 无 LoRA hard_fail / C5 实训 / C6 真实评测 / demo-golden-run / voice / 受限解码 DEFERRED** —— 两审计都正确未当 bug（A2=code-only NOT训/NOT评测）。
- **strangler 保留旧 frame/set_cabin normalize 分支 + 兼容测** —— A2 不物理删（延 retrain-c5），两审计都认可。
- **无远端 CI（GitHub workflow_runs:[]）** —— 🔴 **steelman**：项目 D1 grill 决策 = **`make verify` 替 CI**（solo demo 轻治理，无 CI infra，本地门跑全）。两审计建议加 GitHub Actions，但：① swift test 依赖本机 `/Users/wanglei` base model + homebrew python（见 post-A2 debt #5）→ 通用 CI 不可复现 ② solo private demo 轻治理不引 CI 维护。**决策：保持 make verify 本地门（D1）**；远端可验证性靠 PR 描述 + 本地实跑 log（145 test/verify-gold 57/57/make verify exit 0）。CI 作为 post-A2 可选 infra（需先解 #5 路径可移植性）。

## 3. post-A2 debt（真意见，A2 不动，retrain-c5/后续独立立项；分 owner）
1. **requiresStateDelta `!query_` 前缀 → IR metadata 判据**（both P2）：已加黑名单假设注释(C6VehicleToolBench.swift:901)；改 IR primitive mutability 判据 = 需 GoldVerifier 接 irMap，延后。
2. **sameFamilyDistractors O(N log N)/sample → 预建 byName/bySg/byDomain index**（both P2）：A2 NOT 生成大语料(只验 shape), perf 非关键；retrain-c5 大规模生成前优化。
3. **deviceCellMap codegen**（GLM P2，S3 INDEX 已记 DEFERRED）：24 手维护 entries → 仿 gen_tool_contract.py 产 generated/device_cell_map.json。
4. **C5LoRATraining.swift 拆分**（GPT Pro P2）：单文件承载 options/gates/builder/renderer/MLXConfig/receipts → 拆 Renderer/DatasetBuilder/QualityGates/MLXConfig/Receipts。大重构，A2 surface 外。
5. **测试可移植性 XCTSkipUnless**（both P1，🔴 pre-existing 非 A2 引入）：C5TrainingCLI prepare 测依赖 `/Users/wanglei/.cache/huggingface` base model + `/opt/homebrew/opt/python@3.13`(C5LoRATrainingTests:713-746) → 通用 CI 不可复现。改 skip-if-missing/fixture-driven。**是 CI(#2.CI)的前置**。
6. **CLI 默认 base model/python path 含本机用户名**（GLM P2）：改环境变量/CLI 必填，清个人路径暴露。pre-existing。
7. **ToolContractJSONRenderer 自写 escaping → JSONEncoder 或补控制字符测试**（GPT Pro P2）。
8. **DemoVehicleStateStore 旧 key/新 C2 key 混放清债**（GLM P3，S3 INDEX 已记 DEFERRED）。
9. **demo/full catalog 语义文档化**（GPT Pro P2）：demo=完整训练/评测 surface(562 schema)；full=skeleton OOS/拒识白名单(1538)。本轮 P0 修已在 CLI 注释 + fail-fast 错误消息明示，可补 docs 显式说明。

## 4. 三角分诊洞察（cross-vendor 真值，沉淀 heavy-work 坑点库）
- **GPT Pro 与 GLM-5.2 findings 不同集**：GPT Pro 独抓 P0(`--scope full` 解码崩)，GLM 独抓 P1-2(direct clamp)，**both 共识 P1(dDomain miss fallback)** —— 三者全实跑坐实真 bug。→ **cross-vendor 双审不是冗余, 是覆盖面并集**（不同模型抓不同盲点）；单审会漏（GPT Pro 漏 clamp / GLM 漏 scope full）。
- **两审计都正确守 A2 边界**（未把 DEFERRED/base hard_fail 当 bug）—— extra-instruction(A2 边界说明)起效，防云审计误判 code-only 范畴。
- **verdict 分歧**：GPT Pro REQUEST_CHANGES(因 P0 + CI)/GLM NEEDS_DISCUSSION(无 P0，因 CI+guardrail)—— 差异源于 GPT Pro 抓到 P0。修 P0+P1+P1-2 后两者主要阻断点已闭合。

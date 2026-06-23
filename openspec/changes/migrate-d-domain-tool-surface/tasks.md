<!--
DRAFT SKELETON (2026-06-23) — tasks 占位待细化，人审定 propose 时展开为可验收逐项。
A2 6 步依赖序（paradigm §17，违反=返工）：
  [0]统一口径 → [1]Python codegen 产 D-domain 目录 → [2]ToolContractCompiler 消费 JSON
  → [3]state-cells 扩 10族+命名清债 → [4]C5 surface(→retrain-c5 change) → [5]C6(→rebuild-c6 change) → [6]parity gate 验收
本 change 覆盖 [0]-[3]；[4]/[5] 在下游 change。incremental，禁大爆炸。
-->

## 1. 口径统一（[0] 前置门）

- [ ] 1.1 全仓口径 534→562 级联回写（仅口径 534；非口径 534 历史档不动）。验证：cascade-inventory 口径污染源表清零，`make verify` value-in-source 守 562。
- [ ] 1.2 工具数字段全标 `[TBD-工具数待 value-form 实算]`。验证：grep 无 534/562 当工具数。

## 2. D-domain codegen（[1]）

- [ ] 2.1 Python codegen 从冻结快照派生 D-domain 具名工具集（DRAFT 待细化生成器规则 + value 形态编码命名规约）。
- [ ] 2.2 value-form 工具数实算（col O 从 xlsx 第 15 列提）。验证：工具数真值落档，回填 `[TBD]` 占位。

## 3. ToolContractCompiler 消费（[2]）

- [ ] 3.1 ToolContractCompiler 产 D-domain 具名工具契约（DRAFT 待细化）。
- [ ] 3.2 frame surface 显式移除（grep `tool_call_frame` 无 model-visible 残留）。

## 4. state-cells 命名清债（[3]）

- [ ] 4.1 state-cells 扩 10 族 + 命名对齐 D-domain 工具名空间（DRAFT 待细化）。

## 5. drift gate + parity（Q02/Q05）

- [ ] 5.1 generated/ D-domain 产物进 `GENERATED_CONTRACTS`。验证：`make verify` 漂移门覆盖 codegen 产物。
- [ ] 5.2 train/eval/runtime surface 单源派生 digest 一致（fail-closed）。

## 6. 验证与收口

- [ ] 6.1 `openspec validate migrate-d-domain-tool-surface --strict` + `--all --strict` pass。
- [ ] 6.2 incremental 每刀后 `swift test` + `make verify` 绿；生成物 commit 与逻辑 commit 分开。
- [ ] 6.3 红线检查：无原文语料/PII/密钥；生成物两层 scope 入仓规约。

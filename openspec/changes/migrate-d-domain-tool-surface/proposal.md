> ⚠️ DRAFT SKELETON（2026-06-23 第一个长跑起草，标 DRAFT 待人审 propose）
> 本 change 仅为骨架：proposal Why/What Changes 指向已拍决策，specs delta 占位待补，tasks 待细化。
> **守 agree-before-build：人审定 propose 前不进 apply、不写实现代码。** 决策权威源见下。

## Why

范式翻案（2026-06-22 晚，第 4 源真实座舱 TOP 技能表 ground-truth 推翻 B-frame）后，model-visible surface（模型可见的工具调用面）从 generic frame `tool_call_frame{device,action,value}` 否决 → **D-domain 具名工具**（value 形态编码进工具名）。canonical IR（规范中间表示）仍 device×action×value（「对模型像 D-domain 具名工具，对系统像 device×action IR」）。θ-α `0/23` 根因 = generic frame 单工具判定面爆炸、1.7B 学不会。

A2 代码盘点（ultracode 8 finder + 综合官，2026-06-22）坐实这是 **重型重构**（~14-16 文件 / 1500-2500 行 / 6 步依赖序，约「立项至今大部分代码改」量级），是 C1 编译器核心 + 训练样本 + bench 期望三处共同输入。本 change 是 6 步依赖序的 **[0] 统一口径 → [1] codegen 产 D-domain → [2] ToolContractCompiler 消费 → [3] state-cells 命名清债** 段，是 C5/C6 retrain 与 demo-golden-run 的前置。

**决策权威源**：
- 范式：`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md`（§1-§2 翻案 / §13-§14 口径 / §17 A2 盘点 / §18 Q01/Q02/Q05/Q39 合同条款）
- A2 盘点：`docs/research/2026-06-22-a2-codebase-audit/`（README + lens1-8 + codex-checks + INDEX）
- 级联账本：`docs/grill-tournament/cascade-inventory.md`
- 口径权威表：`docs/grill-tournament/grill-decisions-master.md §0`

## What Changes

> 以下指向已拍决策，**具体逐文件改法 = `docs/grill-tournament/cascade-inventory.md` 各 path 的 verdict + what_to_change**。

- **口径统一（前置门 [0]）**：全仓口径 534→**562**（磊哥 2026-06-23 亲拍终拍 562 为全仓唯一权威）。10 族 = 191 device / **562 intent** / 2159 行 / 占全集 54.1%；族外 480 device / 976 intent / 1831 行。device 191 不变。旧 534/2086/52.3%/族外 1004/1904 系列全废。
- 🔴 **工具数未拍**：562 是 **intent 数不是工具数**；工具数待 value-form 实算（col O 优先级在 xlsx 第 15 列不在 jsonl）。未实算前所有「工具数」字段写 `[TBD-工具数待 value-form 实算]`，**禁编数字**（562 当工具数 = 口径错全链路）。
- **codegen 产 D-domain 目录（[1]）**：Python codegen 从冻结快照派生 D-domain 具名工具集（value 形态编码进工具名，如 `adjust_ac_temperature_to_number` vs `raise_ac_temperature_by_exp`）。canonical IR（device×action×value）不变，jsonl 源不改；A2 改的是 demo surface 工具名生成器。
- **ToolContractCompiler 消费 D-domain JSON（[2]）**：编译器产出 D-domain 具名工具契约；generic frame `tool_call_frame` 映射作 surface **显式移除**（不靠 drift gate——它对 compiler-derived 的债不报警）。
- **state-cells 命名清债（[3]）**：state-cells 扩 10 族 + 命名对齐 D-domain 工具名空间该设备细分。
- **generated/ 进 drift gate（Q02）**：generated/ D-domain 产物补进 `Makefile` 的 `GENERATED_CONTRACTS`，否则 codegen 产物漂移无门（A2 主线程亲核 Makefile:4-9/51 坐实 generated/ 当前不在 diff gate）。
- **train/eval/runtime 三处单源派生（Q05）**：surface 从 A2 codegen 单源派生 + fail-closed（防 C5 0/34 根因 = 训/eval surface 异源）。
- **risk 独立（Q39）**：risk-policy 独立设计，不当 model-visible tool（F1 错误增量已撤）。
- spec MODIFY：`semantic-function-contract`（surface 段 + 停用 tool_call_frame 映射）、`tool-execution`（工具调用帧 = D-domain 具名工具，DemoGuard 读 D-domain 白名单）。

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `semantic-function-contract`: surface 形态从 generic frame 翻案为 D-domain 具名工具；填 Purpose TBD；exec_tier=L1 仅从 reviewed l1-demo-allowlist 派生。
- `tool-execution`: 工具调用帧形态 = D-domain 具名工具 [device+primitive 枚举]×slot×value [四件套]，不再 generic `tool_call_frame`；DemoGuard 读 D-domain 白名单。

## Non-Goals

- 不改 canonical IR（device×action×value）；不改 `contracts/semantic-function-contract.jsonl` 源行级全集（A2 改的是 surface 工具名生成器，jsonl 不改）。
- 不引入新 Swift codegen 框架（Sourcery/SwiftSyntax = 造第二套 SSOT 反模式），只扩 Python codegen surface。
- 不大爆炸一刀改完（Netscape 红 flag）→ A2 必 incremental（每刀后 swift test + make verify 绿，旧路径 strangler 保活）。
- 不重开训练配方（守 `rank16Mainline` + LR 1e-4，A2 是 surface 迁移非配方问题）。
- 不复制真实座舱原文语料（只抽象语义/协议骨架进契约，分级脱敏红线）。
- 不在工具数 value-form 实算前编工具数。

## Success Criteria

> DRAFT 占位，propose 时细化为可验收标准。骨架方向：

- `openspec validate migrate-d-domain-tool-surface --strict` 与 `openspec validate --all --strict` pass。
- generated/ D-domain 产物在 `GENERATED_CONTRACTS` 中，`make verify` 漂移门覆盖 codegen 产物。
- frame surface 显式移除（grep `tool_call_frame` 无残留 model-visible 映射）。
- train/eval/runtime surface 从同一 A2 codegen 单源派生（digest 一致）。
- parity gate = 相对 A2-before 不退化（base 已 hard_fail，非绝对全绿）。
- 工具数字段为 `[TBD]` 或 value-form 实算后的真值，无编造 534/562 当工具数。

## Impact

- 影响 `Core/Contracts/ToolContractCompiler.swift`、Python codegen surface、`Makefile`（GENERATED_CONTRACTS）、`contracts/`（state-cells/l1-demo-allowlist/qwen-tool-call-format/function-spec-full 等，逐文件改法见 cascade-inventory T1）。
- 生成物 commit 与手写 commit **分开**（jsonl 7.4M diff 淹没逻辑改动）。
- delta spec：`specs/semantic-function-contract/spec.md` + `specs/tool-execution/spec.md`。
- 依赖 archived `openspec/specs/semantic-function-contract/spec.md`、`openspec/specs/tool-execution/spec.md`。
- 下游：retrain-c5-lora-d-domain、rebuild-c6-four-layer-bench 依赖本 change 的 D-domain surface。

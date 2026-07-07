# Dispatch — C3 `define-execution-contract` PROPOSE(rebase parked → C1/C2 SSOT）

> ⚠️ **HISTORICAL 快照（T5）—— 文档级联 banner（2026-07-07 B4b）**
> 本文是 `docs/grill-tournament/cascade-inventory.md §T5` 标记的历史快照，当前仅保留溯源/交接价值；supersede 指针以 `docs/grill-tournament/cascade-inventory.md` 的 T5 账本为准。
> **活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md` + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` + `docs/grill-tournament/cascade-inventory.md`。正文保留供溯源，勿据此推进。

> 派 Codex(本地长跑 + TDD)。磊哥手动粘贴。CC 主线程已审 + subagent CC 二审。
> **形态 = OpenSpec propose（写 proposal/specs/design/tasks 设计契约文档），NOT apply（不写 Swift 实现代码）。**

---

## 0. 你是谁 / 这是什么 / 红线（先读，别跳）

你是 MAformac 项目的执行契约层（C3）propose 作者。MAformac = **纯端侧（macOS+iOS）离线、Qwen3-1.7B+LoRA 为脑、mock 车控、给方案经理现场演示的【内部演示 demo 助手，非销售产品】**。起手 `cat AGENTS.md && cat CLAUDE.md`（你自读项目宪法，§2 方法论 / §4 架构 / §5 决策 / §6 红线 / §9 路线）。

**这次只做 propose，不做 apply。** 产出 = `openspec/changes/define-execution-contract/` 的 proposal.md + specs/ + design.md + tasks.md，**不写任何 Swift 实现代码、不动 `Core/*.swift`、不动 `contracts/`、不动 main**。

**为什么是 propose 不是 apply（关键背景）**：旧 `define-execution-contract`（现 `openspec/changes/_parked/`）的 propose 基于**已被推翻的扁平 8 能力契约**（`arguments: [String:JSONValue]` 泛型）。2026-06-19 基座深度内化后，契约 SSOT 重构为 **C1 源行级全集语义契约（value 四件套 + device×动作原语×槽三元）+ C2 场景端态协议**（已 archive 进 `openspec/specs/`）。模型输出的 arguments 模型整个变了 → 执行层必须 **rebase** 到新契约，不能拿旧 propose 直接 apply。**agree-before-build：契约未对齐不写实现代码。**

**🔴 红线（CLAUDE §6 + 内部 demo filter）**：
- home-llm（acon96/home-llm，CC BY-NC-4.0）是 **Python**；MAformac 是 **Swift**，铁律「Python 库零进 iOS」。借鉴 = **把 home-llm 的模式/算法翻译适配成 Swift**，**绝不 import Python、绝不 ship home-llm 的 weights/datasets/模板文本**。只 adopt 方法（思想），内部 demo 非商用，license 非 blocker。
- 不接真车；量产标准（ISO26262/端云/QPS/CI gate）豁免；安全门思想/参数规划/读 mock 态/LoRA 保留。

---

## 1. 起手读（一手源，务必读全，别抽样）

**新契约事实源（你的输入，C1/C2 已 archive）**：
- `openspec/specs/semantic-function-contract/spec.md`（C1，7 Requirement，全集语义 SSOT）
- `openspec/specs/scenario-state-protocol/spec.md`（C2，5 Requirement，场景端态）
- `openspec/specs/vehicle-capabilities/spec.md`（墓碑指针：旧扁平能力已迁 C1/C2）
- 契约数据：`contracts/semantic-function-contract.jsonl`(head + `wc -l`，源行级全集 3990，**value 四件套 + action_primitive + clarify_tag + slot 在此行级**) / `contracts/function-spec-full.yaml`(device 聚合视图：device_id/service/primitives/action_codes，**无 value 四件套/step_table，那在 jsonl**) / `contracts/state-cells.yaml`(C2 端态 + `execution_range`(含 step)权威 + `exp_step` 经验映射 + readback) / `contracts/l1-demo-allowlist.yaml`(L1 炸点) / `contracts/risk-policy.yaml`(R0-R3 单源 + forbidden)

**rebase base（旧 propose，复用其成熟设计，rebase 其契约假设）**：
- `openspec/changes/_parked/define-execution-contract/{proposal,design,tasks}.md` + `specs/tool-execution/spec.md`
- 复用：adopt 上游 parser 薄层(E1) / content-fallback 候选 guard-first(E1a) / 两层 decode 边界(E2) / 错误枚举三态 / DemoGuard R0-R3 / enable_thinking=false / TraceLogger 五段 / E3 spike GO 结论
- rebase：arguments 扁平 → value 四件套；DemoGuard 规则源；readback 权威源；新增 position fan-out

**home-llm runtime 蓝本（借鉴核心，带 file:line 锚点）**：
- teardown 文档：`docs/research/2026-06-19-home-llm-teardown.md`（§7 adopt/adapt/drop 映射表 = 现成桥）
- 应用机制：`docs/research/INDEX.md` §1（design.md 显式引 teardown → findings 变 adopt 指令）+ §2（封闭词表用文件不建 DB）
- **实际源码**（只读参考，CLAUDE §6 不进仓）：`~/workspace/raw/05-Projects/MAformac/ref-repos/home-llm/custom_components/llama_conversation/`{`conversation.py` `utils.py` `entity.py` `const.py` `output.gbnf`} + `backends/`（llamacpp 后端，GBNF 挂载 + KV 预热）。**做映射前实读对应 file:line，忠实适配。**

**实装门（必须落进 spec）**：
- `docs/srd-three-layer-intent-routing.md` §12.1 deferred_gates（C3 那几条：single-call runtime contract / gate 链 / 模型只看 code 派生 state features）
- `docs/handoffs/2026-06-19-change3-gptpro-audit-closeout.md`（GPT Pro 审旧 change3 catch 的 F2/F3 —— ⚠️ **这是整改前快照**，F2/F3 已在 `46340f1` 修复进 main；C3 只需在新 value 四件套契约下**保持**全字段落地不重蹈，不是去 main 找现存 bug）

**现有 Swift 骨架（apply 阶段的 rebase 对象，propose 阶段只需了解现状，不改）**：
- `Core/Execution/DemoActionExecutor.swift`（**F2/F3 已在 `46340f1` 修复进 main**——当前文件约 25 行、已无 `desiredMockValue` 取第一个 scalar 的旧 bug；`grep desiredMockValue Core/` 零命中。下方 handoff 是**整改前快照**，别当现状）/ `Core/Execution/DemoGuard.swift` / `Core/Routing/ToolCallFrame.swift` / `Core/State/DemoVehicleStateStore.swift`

---

## 2. C3 执行契约层是什么（rebase 目标链路）

```
C1/C2 archived 契约（输入）
  → 模型产候选（单发：runtime 只接受 exactly 1 ToolCallFrame 或 1 NoAction/Clarify）
  → ToolCallFrame 薄层（adopt mlx-swift-lm 上游 parser；裸 JSON 仅 content-fallback 候选）
  → gate 链：schema(字段/enum/range) → semantic(工具当前 state 可执行?) → precondition(AC off 时"升温"=code 转 turn_on+set_temp) → stale-state(带 state_revision) → fail-closed(repair 只修格式，repair 后仍过 semantic)
  → DemoGuard 代码门（规则源 = risk-policy.yaml R0-R3 + l1-demo-allowlist + C1 `clarify_tag`；C1 行 risk 全空，读独立 risk-policy.yaml）
  → DemoActionExecutor.applyMockTransition（唯一写入口；value 四件套全参数落地，非取第一个 scalar）
  → readback 对 C2 state-cells.yaml execution_range（读回实际 mock 态才算成功）
  → TraceLogger 五段（decode/plan/guard/execute/readback）+ toolCalls.count / stopReason
```
**安全铁律**：DemoGuard 是代码门；模型只产候选；`pending/failed/unknown` 不播「已完成」。

---

## 3. 必须 rebase 的契约变更点（旧扁平 → C1/C2 SSOT）

> ⚠️ value 四件套与 action_primitive 是**正交两维**（一条契约行同时有），别混（CC subagent 审计 catch）。已对 `contracts/semantic-function-contract.jsonl` 实证。

| # | 旧（parked，扁平 8 能力） | 新（C1/C2 SSOT，已实证 jsonl/spec） | 动作 |
|---|---|---|---|
| R1 | `arguments: [String:JSONValue]` 泛型 KV | **两个正交维度**：① **value 四件套** `value{ref, direct, offset, type}`（ref=CUR 相对当前/ZERO 绝对从零/MAX；type=EXP 经验/SPOT 绝对点值/PERCENT 百分比；offset=LITTLE/MORE/`<百分比>`/MAX/MIN/`<挡位>`；direct=+/-；C1 spec:25 例「经验值=ref:CUR,offset:LITTLE,type:EXP」「绝对=ref:ZERO,offset:占位,type:SPOT」）② **device×action_primitive×slot 三元**（action_primitive 高频实证：set_mode 709 / power_on 553 / power_off 551 / adjust_to_number 448 / by_percent 333 / increase_by_exp 252 / decrease_by_exp 188 / adjust_to_max·min 142 / adjust_to_gear 128 / increase·decrease_by_number / query…）。**步长不在 C1**（C1 spec:25「具体步长数值不写死在契约，执行层承担」）→ 步长来源 = **C2 `state-cells.yaml` `execution_range.step`（机器步进）+ `exp_step`（经验 offset token→具体值映射，如 temp little:1、window little:20）** | Input schema 重做：executor 按 action_primitive + value 四件套解释，不平铺 KV。**无 `step_table` 字段（杜撰，0 命中），步长用 C2 `execution_range.step` / `exp_step`** |
| R2 | DemoGuard 规则源 `capabilities.yaml.demo_guard` | `risk-policy.yaml`(R0-R3 + forbidden) + `l1-demo-allowlist.yaml` + C1 `clarify_tag`（**snake_case**，值 implicit/explicit）。**⚠️ C1 契约行 `risk` 字段全空**（risk-policy.yaml 头部 + verify_refs 强制 `risk==""`）→ DemoGuard 读独立 `risk-policy.yaml`，**不要去 C1 契约行读 risk** | 改规则源 |
| R3 | readback 读 DemoVehicleStateStore（旧 8 cell） | C2 `state-cells.yaml` `execution_range`（唯一权威，C1 只引不覆盖）+ state_kinds(empty/known/unknown) | 对齐权威源 |
| R4 | （无 槽 fan-out 概念） | **槽 fan-out 两类**：`position`（座椅/车窗位，~167 设备用，主驾/副驾/左前/左后…全车，几十个取值）+ `direction`（温区/风向，~69 设备用，左温区/右温区/前排…）。「主驾/副驾/全车」仅简化举例，实际取值几十个 | 新增：单 ToolCallFrame 带 position/direction 槽 |
| R5 | 旧 638e520 实装 executor `desiredMockValue` 取 `["power","level","percent"]` 第一个 scalar 丢温度（**F2**，**已在 `46340f1` 修复进 main**；当前 `DemoActionExecutor.swift` 已无此代码） | C3 rebase 到 value 四件套后，executor SHALL 按 action_primitive + value 四件套**全字段归一落地**（home-llm 值归一化模式，见 §4），**不重蹈 F2**（value 四件套只落第一个字段=退化 bug） | **继承 46340f1 思想到新契约**（非修 main 现存 bug） |
| R6 | referenceBinding.allowedValues 进 guard（F3，**已在 `46340f1` 处理**） | 新契约下 allowedValues 仍 SHALL 进 DemoGuard schema 门 | 保持 |
| R7 | content-fallback 默认开（旧 Codex 实装偏离，负例被执行） | **默认关（fail-closed）** + 测试 isNegative 零执行断言 | 对齐 design |

---

## 4. home-llm 借鉴映射（磊哥强调核心：精确到 file:line，翻译成 Swift）

> 来源 teardown §7 + 实读源码。**这是设计借鉴，apply 阶段照此翻译 Swift；propose 阶段把本表细化进 design.md 的 "home-llm adopt 映射" 段**（每条标 copy/adapt/drop + Swift 落点 + 为什么）。

| home-llm 文件:行 | 模式 | C3 Swift 落点 | 动作 |
|---|---|---|---|
| `conversation.py:156-220`（`max_tool_call_iterations=0` 单发；注释 :157） | 单发循环 = 模型一次产 NL+ToolCall，code 执行完事，无 ReAct 多步 | **single-call runtime contract**（runtime 只接受 1 ToolCallFrame） | **adapt**（Swift 逻辑，非 import）；架构铁律实证背书 |
| `utils.py:495-579`（三层防御解析 `parse_raw_tool_call`：多格式 + `fuzzy_json` 兜底 + 双 schema） | 让小模型畸形输出可解析 | ToolCallFrame decode 层；但守 E1 薄层=站 mlx-swift-lm parser 上，fuzzy/repair **仅用于 content-fallback 候选**，不重建 parser | **adapt**（Swift JSONValue + parser-repair 候选） |
| `utils.py:565-571`（**值归一化在 code**：brightness 0-1→×255、rgb "(r,g,b)"→list） | 模型输出近似/人类单位，code 归一到机器值 | **value 四件套 → 机器值归一化**（模型给 value 四件套 ref/offset/type/direct + 槽，code 按 **C2 `execution_range.step` + `exp_step`** 算实际 mock 值，**全字段落地**不只第一个） | **adapt**（R5 防退化的正解：执行层把经验/相对/百分比四件套算成机器值） |
| `entity.py:564-592`（双向单位归一化 prompt 侧：128→"50%"、temp→"22 C"、rgb→命名色） | 端态转人类可读喂模型 | readback 侧归一化（mock 机器态 → 中文播报）；**prompt 构建侧可能归 C4 routing** → 标 open question | **adapt + 边界标注** |
| `backends/`llamacpp `:219-230`（GBNF 挂载 `LlamaGrammar.from_string`） | 采样层 enforce 输出格式 | 受限解码（MLX 无 llama.cpp GBNF → **outlines-swift / xgrammar 等效**，spike 验证）；`output.gbnf` 中文化 + cabin enum | **adapt**（MLX 等效待 spike，标 open question） |
| `backends/`llamacpp `:366-448`（**KV 缓存预热** `_cache_prompt`：启动 + 状态变化重热） | 冷启动解药，首句只处理新 token | app 启动预热 Qwen + mock 态变化重热；**可能归 C7 voice/runtime** → 标接口 + open question | **adapt + 边界标注** |
| `const.py:318-322`（qwen3 采样 temp0.6/topk20/topp0.95 + 原生 tool calling） | Qwen 官方采样 | Qwen3-1.7B 采样起点（spike E3 调） | **copy 值** |
| `output.gbnf`（root = NL 回复行 + ```fenced``` JSON 工具块） | 强制输出 = 回复文本 + ToolCall JSON | 中文回复 + 中控块 + cabin enum 受限解码语法 | **adapt** |
| HA 实体/服务/`config_flow`/多 backend | — | — | **drop**（HA 特有） |

**收敛洞察（写进 design）**：home-llm 的「值归一化在 code」(`utils.py:565-571`) + MAformac 的 value 四件套是**同一思想的两个蓝本印证**——模型只产「模糊说→意图 + value 四件套(ref/offset/type/direct) + 槽」，**精确机器值由 code 按 C2 `execution_range.step` + `exp_step` 算**。这正是 F2 退化模式的根治（executor 按 action_primitive 把 value 四件套全字段归一落地，绝不只落第一个字段）。

---

## 5. 必落进 spec 的 SRD §12.1 C3 gates（行为契约 Requirement）

每条写成 OpenSpec Requirement（SHALL + ≥1 Scenario WHEN/THEN）：
- **single-call runtime contract**：runtime SHALL 只接受 exactly 1 ToolCallFrame 或 1 NoAction/Clarify frame；多 tool_call / 额外 assistant 文本 / 缺必填 / unknown enum / stale `state_revision` / finish_reason=length → **reject 或 clarify，SHALL NOT repair-to-action**。
- **gate 链**：schema → semantic（工具在当前 state 可执行?）→ precondition（前置动作 code 补，非模型决定）→ stale-state（ToolCallFrame 带 `state_revision`，过期则 reject）→ **fail-closed**（parser repair 只修格式，repair 后仍 SHALL 过 semantic gate；repair_rate 超阈判模型 failed 不掩盖）。
- **模型只看 code 派生 state features**（comfort_state/active_zone/available_single_actions/last_action/state_revision），SHALL NOT 让模型对全量 mock 态自推理。
- **注**：multi-intent code 确定性 splitter 归 **C4 routing**，C3 只留 `intentConfirmed`/splitter hook 点（标 open question 给 C4）。

---

## 6. 产出（propose artifacts）

1. **把 `_parked/define-execution-contract/` 移回 `openspec/changes/define-execution-contract/`**（`git mv`），在其上 rebase（不是新建空的）。
2. `proposal.md`：rebase Why/What Changes/Capabilities/Non-goals/Success Criteria —— 更新依赖（capabilities.yaml → C1/C2 specs + contracts）+ 纳入 §3 R1-R7 + §4 home-llm adopt + §5 gates。
3. `specs/tool-execution/spec.md`：ADDED Requirements —— rebase 旧 7 个（不可信候选/三态错误/禁 thinking/安全门/readback/五段 trace/多形态参数）+ 新增 value 四件套、position fan-out、single-call、gate 链 的 Requirement+Scenario。
4. `design.md`：Decisions —— rebase 旧 E1/E1a/E2/关键决策表 + 新增「value 四件套 executor 映射」「F2/F3 修法」「home-llm adopt 映射表（§4 细化，file:line + copy/adapt/drop + Swift 落点）」「SRD §12.1 gates」+ Risks（带来源链接）+ Migration（现有 Swift 骨架 rebase 路径）+ Open Questions。
5. `tasks.md`：apply 阶段 TDD 任务清单（标 magnet reviewed 点 / spike 点）。

---

## 7. 验收（propose 质量门，全过才算完）

- [ ] `openspec validate define-execution-contract --strict` 通过
- [ ] proposal/specs/design/tasks 自洽；引的每个 device/cell/action_primitive/clarify_tag **在 C1/C2 契约里实际存在**（无悬空引用，grep 核）；risk 校验对 `risk-policy.yaml`（非 C1 行，C1 risk 全空）
- [ ] §3 R1-R7 rebase 点在 design 全部有交代；value 四件套 `value{ref,direct,offset,type}` 与 action_primitive **正交两维**写对（不混）；**步长用 C2 `execution_range.step`/`exp_step`，无 `step_table` 杜撰字段**；F2/F3 定性为「`46340f1` 已修、新契约下保持 value 四件套全字段落地 + allowedValues 进 guard，不重蹈退化」（**非修 main 现存 bug**）
- [ ] §4 home-llm 借鉴映射表精确到 **file:line + copy/adapt/drop + Swift 落点 + 为什么**（做前实读 ref-repo 源码）
- [ ] §5 SRD §12.1 C3 gates 全部落成 spec Requirement（SHALL + Scenario）
- [ ] **change 边界 open questions 标清**：prompt 构建侧单位归一化 / KV 预热 / GBNF MLX 等效方案 哪些归 C3、哪些归 C4 routing/C7 voice/runtime；value 四件套 executor mock transition spec 的落地形态；content-fallback 默认关的配置点 —— 待磊哥 + CC 审
- [ ] **不写 Swift 实现代码**（propose only，不动 Core/*.swift、contracts/、main）
- [ ] 报告附实跑 `git status` + `git log --oneline -3` + `openspec validate` stdout（ground-truth，防幻觉）

---

## 8. 工作方式（纪律）

- 分支 `feat/c3-execution-rebase`（**主文件夹 `~/workspace/MAformac` 直接切分支，不用 worktree** —— 磊哥定：有分支了不需隔离树）。
- 只在该分支 commit；不碰 main；propose-only 不 archive（写完等磊哥 + CC 审 → 对齐后才 `/opsx:apply`）。
- 遇 unexpected error / 拿不准的契约语义 → **停下写进 Open Questions，别猜**（agree-before-build）。
- 中文；称呼磊哥；术语首现「中文（English）」。

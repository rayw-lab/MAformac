# Dispatch — C3 `define-execution-contract` APPLY(按已对齐 propose 实装 Swift,TDD 长跑)

> ⚠️ **HISTORICAL 快照（T5）—— 文档级联 banner（2026-07-07 B4b）**
> 本文是 `docs/grill-tournament/cascade-inventory.md §T5` 标记的历史快照，当前仅保留溯源/交接价值；supersede 指针以 `docs/grill-tournament/cascade-inventory.md` 的 T5 账本为准。
> **活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md` + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` + `docs/grill-tournament/cascade-inventory.md`。正文保留供溯源，勿据此推进。

> 派 Codex(long-runner + TDD)。磊哥手动粘贴。
> **形态 = OpenSpec apply(写 Swift 实现代码,满足已 archive 的 spec)。propose 已对齐(两层 CC 审计 READY-FOR-APPLY),本次照 `tasks.md` 逐 group TDD 实装。**

---

## 0. 你是谁 / 这是什么 / 红线

你是 MAformac 的 C3 执行契约层 **apply 实装者**。MAformac = 纯端侧 macOS+iOS 离线、Qwen3-1.7B+LoRA 为脑、mock 车控、给方案经理现场演示的**内部演示 demo(非销售产品)**。起手 `cat AGENTS.md CLAUDE.md`(自读宪法 §4 架构 / §5 决策 / §6 红线)。

**这次做 apply:写 Swift 代码,满足 `openspec/changes/define-execution-contract/specs/tool-execution/spec.md` 的全部 Requirement。** 设计已由 propose 定死(proposal/design/tasks 已在 main,两层 CC 审计 READY-FOR-APPLY),**不要重新设计、不要改契约**,照 `tasks.md` 的 8 个 group 逐条 TDD。

**🔴 红线**：
- **禁区不改**：`contracts/`、`openspec/specs/`、`openspec/changes/define-execution-contract/`(已对齐的 propose)、`main`。本 change 只新增/修改 `Core/`、`App/`、`Tests/` 下的 Swift。如发现需要改 contracts → **停下报告,另开 change**,不擅自改。
- **架构铁律(单跳)**：模型只产 exactly 1 个 ToolCallFrame 或 1 个 NoAction/Clarify;编排/多步/安全/state 全在确定性 code;**禁止模型自由 agent loop / 自由决定 next-tool**(spec「运行时只接受单发」+ design E4)。
- **home-llm 借鉴 = 翻译 Swift**:home-llm(`~/workspace/raw/05-Projects/MAformac/ref-repos/home-llm`)是 Python 参考,**绝不 import Python、不搬 weights/datasets/模板**;按 design「home-llm Adopt Mapping」表把模式翻成 Swift(铁律 Python 零进 iOS)。
- **mlx-swift-lm 上游 parser adopt 薄层**:不自建 `<tool_call>` parser;`ToolCallFrame` 站上游 `ToolCall` 之上做严格校验(design E5)。

---

## 1. 起手读(已对齐的事实源,务必读全)

**propose(你的实装规格,已 archive 对齐——逐条满足,不改)**：
- `openspec/changes/define-execution-contract/specs/tool-execution/spec.md`（14 个 Requirement = 你的验收契约）
- `openspec/changes/define-execution-contract/design.md`（E1-E11 决策 + home-llm Adopt Mapping 表 + Open Questions）
- `openspec/changes/define-execution-contract/tasks.md`（**8 个 group 的 TDD 任务清单 = 你的实装顺序**）
- `openspec/changes/define-execution-contract/proposal.md`（Why/What/Success Criteria）

**契约事实源(只读消费,不改)**：
- `openspec/specs/{semantic-function-contract,scenario-state-protocol}/spec.md`（C1/C2 行为契约）
- `contracts/semantic-function-contract.jsonl`（C1 源行级全集:value 四件套 `{ref,direct,offset,type}` ⊥ action_primitive ⊥ slot；clarify_tag；risk 全空）
- `contracts/state-cells.yaml`（C2:`execution_range.step` + `exp_step` 权威 + readback）
- `contracts/l1-demo-allowlist.yaml`（L1 已 reviewed）/ `contracts/risk-policy.yaml`（R0-R3 + forbidden）

**home-llm runtime 蓝本(只读翻译参考)**：
- `docs/research/2026-06-19-home-llm-teardown.md`（§7 adopt/adapt/drop）+ 实际源码 `~/workspace/raw/05-Projects/MAformac/ref-repos/home-llm/custom_components/llama_conversation/`（design 已给 file:line)

**现有 Swift 骨架(你要 rebase 的对象)**：
- `Core/Execution/{DemoActionExecutor,DemoGuard}.swift`、`Core/Routing/ToolCallFrame.swift`、`Core/State/DemoVehicleStateStore.swift`、`Core/Trace/TraceLogger.swift`、`Tests/MAformacCoreTests/`

---

## 2. 任务 = 照 tasks.md 8 group 逐条 TDD

`tasks.md` 已是完整 TDD 清单。**逐 group 跑 RED→GREEN→REFACTOR**：
- group 0 前置验证 → 1 C1/C2 lookup → 2 ToolCallFrame rebase（`[String:String]`→强类型 frame）→ 3 严格解码错误枚举 → 4 gate 链+DemoGuard → 5 value 四件套归一化+slot fan-out → 6 readback+trace → 7 home-llm adopt spike → 8 verification。
- 标 `(TDD)` 的：**先写失败测试再实现**。标 `(spike)` 的：先小实验量化（受限解码方案 / qwen3 采样 / KV 预热归属），结论写进 `docs/`，**spike 结果回报磊哥拍**（不擅自锁库）。
- 每个 group 完成跑 `swift test`，绿了再下一个。

## 3. 不可妥协的实装点（spec + design 已定，重点盯）

- **value 四件套全字段落地**：executor 按 action_primitive + `value{ref,direct,offset,type}` 把**全部字段**归一成 mock 值（`EXP`→C2 `exp_step`、`SPOT`→点值、`PERCENT`→百分比 range、`MAX/MIN`→extreme），**绝不只取第一个 scalar**（防 F2 退化）。
- **步长只来自 C2**：`execution_range.step` / `exp_step`，**不新增 `step_table`**。
- **slot fan-out**：`position`/`direction` 单点 + `全车`类集合 fan-out 到 C2 scope，每 cell 独立过 range gate；scope 外 clarify/reject。
- **gate 链 fail-closed**：schema→semantic→precondition(AC off 升温由 code 补 power_on+set_temp)→stale-state→parser-repair(只修格式,repair 后仍过 semantic)→DemoGuard→execute→readback。
- **DemoGuard 规则源**：独立 `risk-policy.yaml` + `l1-allowlist` + C1 `clarify_tag` + C2 state；**C1 行 risk 全空,不从 C1 行读 risk**。
- **content-fallback 默认关**（fail-closed）+ 测试 isNegative 零执行。
- **readback 以 C2 actual mock state 为唯一成功判据**；`pending/failed/unknown` 不播「已完成」。
- **trace 五段**（decode/plan/guard/execute/readback）+ candidate_source/toolCalls.count/stopReason/repair_used/guard_reason/readback_result。

## 4. 验收（每 group + 收尾）

- [ ] `swift test` 全绿（C3 契约层不需 metallib/Simulator）；失败保留 stdout + failure receipt。
- [ ] spec 14 个 Requirement 每条有对应测试覆盖（错误枚举 no_tool_call/malformed/schema_invalid/semantic_invalid/stale_state/guard_denied/readback_mismatch 各一 fixture）。
- [ ] `unsafe false pass = 0`、`readback mismatch = 0`。
- [ ] `openspec validate define-execution-contract --strict` 仍通过（你不改 change，应自然绿）。
- [ ] **`git diff -- contracts openspec/specs openspec/changes/define-execution-contract` 为空**（禁区未碰）。
- [ ] spike（受限解码 / qwen3 采样 / KV 预热）结论写 `docs/` 并**回报磊哥拍**，不擅自锁。
- [ ] 报告附实跑 `git status` + `git log --oneline -5` + `swift test` 末尾 + `openspec validate` stdout（ground-truth，防幻觉）。

## 5. 工作方式

- 分支 `feat/c3-execution-apply`（主文件夹 `~/workspace/MAformac` 切分支，**不用 worktree**）。
- 只在该分支 commit；不碰 main、不碰禁区；分批 commit（按 group），每 commit message 标 group + TDD 状态。
- 遇拿不准的契约语义 / spec 与契约冲突 / 需改 contracts → **停下报告,别猜、别擅自改契约**。
- 中文；称呼磊哥；术语首现「中文（English）」。

# A2 执行 harness 设计 ultracode 归档（2026-06-23）

> harness 设计 workflow（4 designer + 综合官，5 agent / 842K tok / 532s）产出 **A2 code-only 重构执行 harness**，已融入派单 `docs/dispatches/2026-06-23-a2-code-refactor-cc-ultracode-dispatch.md` §I。

## 文件清单（三层一手性）

| 层 | 文件 | 一手性 | 落点 |
|---|---|---|---|
| 二手综合 | `harness-synth.md`（15.6K）| 综合官 full_report（7 work-state DAG / step gate / 主线程亲核 8 checklist / 监控信号表 / step close 7 动作 / 收口 / 完成判据 11 门）| 仓内（本目录）|
| workflow return | `synth.output.json` | `{designs_count, harness_markdown, gaps_or_risks}` | 仓内（本目录）|
| 最一手 transcript | `agent-*.jsonl ×5 + journal.jsonl`（1.2M）| 4 designer + 综合官完整搜证/工具调用过程 | **仓外 raw**（`~/workspace/raw/05-Projects/MAformac/research/2026-06-23-a2-harness-design/`，无敏感但 1.2M 不入仓）|

## lens ↔ agent 映射（4 designer + 1 综合官）
- `design:exec-control` → 执行管控 + /goal 状态机
- `design:monitor-audit` → 监控 + 分段审计（每 step 一轮）
- `design:overall-drive` → 整体推进编排 + 收口
- `design:premortem` → pre-mortem（harness 会怎么炸）
- `synthesize` → 综合官（4 视角 → A2 harness 规格）

## 关键发现（主线程亲核坐实，A2 执行方可直接信）
- ✅ **generated/ 裸奔**：`generated/` 5 个 git-tracked 文件，但 `Makefile:51` diff gate 只含 `GENERATED_CONTRACTS`(全 contracts/)+HANDWRITTEN+scripts+Makefile，**不含 generated/**；.gitignore 无 generated → git-tracked 但 regen 漂移不报 → **step[1] D-domain 产物必显式纳入 diff gate**。
- ✅ **frame metadata 假删**：`C5LoRATraining.swift:2344 removedToolID:"tool_call_frame"`(声称) vs `:2362 C5TrainingToolCall(name:"tool_call_frame")`(仍 emit) = claim-vs-reality 铁律1 活样本 → **frame 删用 grep 行为门核，不信 metadata**。
- ✅ `scope_tier` 全仓 0 命中（codex P1-2 硬前置真实）；`rank16Mainline()`=`:1175`（守不动）。

## gaps_or_risks（7 条，dispatch §J 待磊哥拍）
1. 工具数 G2 实算 + col O 提取（step[0] 硬阻塞）2. C6 性能 parity 阈值 DEFERRED 3. 受限解码 vendor DEFERRED 4. 可选机械门 Elevate-or-Kill 5. .a2-goal-state.json 双锚 vs git 单源 6. 逻辑并行落盘串行协调成本 7. loopaudit 异源 panel 授权。

# T5 Banner Refresh Preflight（B4a）

日期：2026-07-07  
范围：重验 `docs/grill-tournament/cascade-inventory.md §T5` 的历史快照 banner 批。  
约束：只读盘点；不改任何被盘点 docs 正文；不 `git add` / `git commit`。

## 结论

`cascade-inventory.md §T5` 的“75 个历史快照”口径今天实测为：

| 分类 | 数量 | B4b 动作 |
|---|---:|---|
| 确认可 banner | 49 | 可进入 B4b banner 批 |
| 已有 banner 跳过 | 24 | 跳过，避免重复加头 |
| 状态变化需 commander 复核 | 2 | 不进自动 banner 批 |

未发现“已被后续决策升级为活基线”的 T5 候选；49 个无 banner 且存在的文件仍按 T5 历史快照处理。需复核的 2 个不是“活基线升级”，而是路径不存在 / 源表目录 shorthand 无当前文件落点。

## 口径与证据

- T5 源表位置：`docs/grill-tournament/cascade-inventory.md:173` 起，明确“历史快照（批量 banner 标 historical，不改正文）”。
- T5 源表排除项：`docs/grill-tournament/cascade-inventory.md:181` 排除 `integration-blueprint.md`（取 T0 modify，不入 banner 批）；`docs/grill-tournament/cascade-inventory.md:193` 排除 `dispatches/_TEMPLATE.md` 与 `dispatches/2026-06-20-p1-b-qwen-spike-dispatch.md`；`docs/grill-tournament/cascade-inventory.md:188` 排除 `paradigm-flip-d-domain` no_change。
- 当前 glob drift：今天直接按当前目录 glob 会得到 77 而非 75，额外混入 `docs/handoffs/2026-06-23-doc-cascade-pushed-a2-refactor-dispatch.md` 与 `docs/dispatches/2026-06-23-a2-code-refactor-cc-ultracode-dispatch.md`。后者在 `docs/grill-tournament/cascade-inventory.md:5` 是 A2 code-only 派单，不应混进 B4a 的原 75 历史快照批。
- 目录 shorthand 处理：T5 最后一行列目录型 path；为满足“逐文件核”的 75 口径，按 README 作为 banner 目标归一。`docs/research/2026-06-21-rules-skills-loading-optimization/README.md` 当前不存在，列入复核。

## 确认可 banner（49）

| 文件 | 存在 | 当前 banner | 仍属 T5 | 证据 |
|---|---:|---:|---:|---|
| `docs/research/2026-06-21-c5-generator-selection-probe.md` | yes | no | yes | source `cascade-inventory.md:183`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/research/2026-06-20-model-selection-2026-finders-raw.md` | yes | no | yes | source `cascade-inventory.md:183`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/research/2026-06-20-p1c-training-backend-finders-raw.md` | yes | no | yes | source `cascade-inventory.md:183`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/research/2026-06-20-p1-b-qwen35-2b-s1-s2-spike.md` | yes | no | yes | source `cascade-inventory.md:184`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/research/2026-06-20-c3-home-llm-adopt-spike.md` | yes | no | yes | source `cascade-inventory.md:184`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/second-review-2026-06-17/00-source-ledger.md` | yes | no | yes | source `cascade-inventory.md:185`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/second-review-2026-06-17/01-claude-code-check.md` | yes | no | yes | source `cascade-inventory.md:185`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/second-review-2026-06-17/02-giants-shoulders-adoption.md` | yes | no | yes | source `cascade-inventory.md:185`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/second-review-2026-06-17/04-runtime-model-route.md` | yes | no | yes | source `cascade-inventory.md:185`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/second-review-2026-06-17/05-vehicle-execution-vss-kuksa.md` | yes | no | yes | source `cascade-inventory.md:185`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/second-review-2026-06-17/06-project-operating-system.md` | yes | no | yes | source `cascade-inventory.md:185`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/second-review-2026-06-17/07-roadmap-next-actions.md` | yes | no | yes | source `cascade-inventory.md:185`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/repo-intelligence/2026-06-17-gitnexus/01-index-ledger.md` | yes | no | yes | source `cascade-inventory.md:186`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/repo-intelligence/2026-06-17-gitnexus/02-architecture-findings.md` | yes | no | yes | source `cascade-inventory.md:186`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/repo-intelligence/2026-06-17-gitnexus/04-query-backlog.md` | yes | no | yes | source `cascade-inventory.md:186`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/handoffs/2026-06-18-6change-propose-complete.md` | yes | no | yes | source `cascade-inventory.md:188`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/handoffs/2026-06-19-baseline-full-rebuild.md` | yes | no | yes | source `cascade-inventory.md:188`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/handoffs/2026-06-19-baseline-internalization.md` | yes | no | yes | source `cascade-inventory.md:188`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/handoffs/2026-06-19-c1c2-apply-launch.md` | yes | no | yes | source `cascade-inventory.md:188`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/handoffs/2026-06-19-c1c2-t2-closure.md` | yes | no | yes | source `cascade-inventory.md:188`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/handoffs/2026-06-19-change3-gptpro-audit-closeout.md` | yes | no | yes | source `cascade-inventory.md:188`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/handoffs/2026-06-20-c3-execution-apply-note.md` | yes | no | yes | source `cascade-inventory.md:188`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/handoffs/2026-06-20-c6-done-eval-memory-deepdive.md` | yes | no | yes | source `cascade-inventory.md:188`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/handoffs/2026-06-20-p0-3-p0-4-c6-trap-gold-closeout.md` | yes | no | yes | source `cascade-inventory.md:188`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/handoffs/2026-06-20-p1-a-c5-data-gate-closeout.md` | yes | no | yes | source `cascade-inventory.md:188`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/handoffs/2026-06-20-p1-b-qwen35-2b-spike-closeout.md` | yes | no | yes | source `cascade-inventory.md:188`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/handoffs/2026-06-20-p1ab-closeout-p1c-eval.md` | yes | no | yes | source `cascade-inventory.md:188`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/handoffs/2026-06-20-roadmap-from-c6-done-closeout.md` | yes | no | yes | source `cascade-inventory.md:188`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/handoffs/2026-06-21-c5-remediation-pr1-pr3-closeout.md` | yes | no | yes | source `cascade-inventory.md:188`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/handoffs/2026-06-21-p1c-grill-closeout-c5-apply-dispatch.md` | yes | no | yes | source `cascade-inventory.md:188`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/handoffs/2026-06-22-c5-pr2-pr4-pr5-superdispatch-closeout.md` | yes | no | yes | source `cascade-inventory.md:188`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/handoffs/2026-06-22-c5-recovery-grill-checkpoint.md` | yes | no | yes | source `cascade-inventory.md:188`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/handoffs/2026-06-22-c5-recovery-grill-marathon-closeout.md` | yes | no | yes | source `cascade-inventory.md:188`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/handoffs/2026-06-22-c5-recovery-hermes-handoff-six-piece.md` | yes | no | yes | source `cascade-inventory.md:188`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/handoffs/2026-06-22-c5-theta-alpha-harness-grill-closeout.md` | yes | no | yes | source `cascade-inventory.md:188`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/handoffs/2026-06-22-harness-enforce-grill-and-theta-alpha-dispatch.md` | yes | no | yes | source `cascade-inventory.md:188`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/handoffs/2026-06-22-harness-enforce-impl-closeout.md` | yes | no | yes | source `cascade-inventory.md:188`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/dispatches/2026-06-18-define-capability-contract-apply.md` | yes | no | yes | source `cascade-inventory.md:189`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/dispatches/2026-06-18-define-demo-mvp-contract-apply.md` | yes | no | yes | source `cascade-inventory.md:189`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/dispatches/2026-06-18-spike-e3-function-call.md` | yes | no | yes | source `cascade-inventory.md:189`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/dispatches/2026-06-19-P0-function-spec.md` | yes | no | yes | source `cascade-inventory.md:189`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/dispatches/2026-06-19-change3-gptpro-fix.md` | yes | no | yes | source `cascade-inventory.md:189`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/dispatches/2026-06-20-c3-execution-apply-dispatch.md` | yes | no | yes | source `cascade-inventory.md:189`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/dispatches/2026-06-20-c3-execution-propose-dispatch.md` | yes | no | yes | source `cascade-inventory.md:189`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/dispatches/2026-06-20-c6-c3-archive-longrun-dispatch.md` | yes | no | yes | source `cascade-inventory.md:189`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/dispatches/2026-06-20-p0-2-c6-model-fingerprint-dispatch.md` | yes | no | yes | source `cascade-inventory.md:189`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/dispatches/2026-06-20-p0-3-p0-4-c6-trap-gold-dispatch.md` | yes | no | yes | source `cascade-inventory.md:189`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/research/2026-06-22-claudecode-amnesia-shallow-harness/README.md` | yes | no | yes | source `cascade-inventory.md:191`; head 1-12 无 HISTORICAL/SUPERSEDED |
| `docs/research/2026-06-21-lora-training-pitfalls/README.md` | yes | no | yes | source `cascade-inventory.md:191`; head 1-12 无 HISTORICAL/SUPERSEDED |

## 已有 banner 跳过（24）

| 文件 | 存在 | 当前 banner | 仍属 T5 | 证据 |
|---|---:|---:|---:|---|
| `docs/research-archive-2026-06-17.md` | yes | yes | yes | banner `docs/research-archive-2026-06-17.md:3`; source `cascade-inventory.md:181` |
| `docs/tech-baseline-from-raw.md` | yes | yes | yes | banner `docs/tech-baseline-from-raw.md:3`; source `cascade-inventory.md:181` |
| `docs/tech-baseline-supplement-v0.2.md` | yes | yes | yes | banner `docs/tech-baseline-supplement-v0.2.md:3`; source `cascade-inventory.md:181` |
| `docs/maformac-function-spec-2026-06-19.md` | yes | yes | yes | banner `docs/maformac-function-spec-2026-06-19.md:3`; source `cascade-inventory.md:181` |
| `docs/demo-must-pass-candidate-2026-06-19.md` | yes | yes | yes | banner `docs/demo-must-pass-candidate-2026-06-19.md:1`; source `cascade-inventory.md:181` |
| `docs/baseline-internalization-plan-2026-06-19.md` | yes | yes | yes | banner `docs/baseline-internalization-plan-2026-06-19.md:3`; source `cascade-inventory.md:181` |
| `docs/intent-routing-explore-2026-06-18.md` | yes | yes | yes | banner `docs/intent-routing-explore-2026-06-18.md:3`; source `cascade-inventory.md:181` |
| `docs/execution-pre-mortem-2026-06-18.md` | yes | yes | yes | banner `docs/execution-pre-mortem-2026-06-18.md:3`; source `cascade-inventory.md:182` |
| `docs/voice-pre-mortem-2026-06-18.md` | yes | yes | yes | banner `docs/voice-pre-mortem-2026-06-18.md:3`; source `cascade-inventory.md:182` |
| `docs/cockpit-voice-fc-premortem-2026-06-18.md` | yes | yes | yes | banner `docs/cockpit-voice-fc-premortem-2026-06-18.md:3`; source `cascade-inventory.md:182` |
| `docs/lora-eval-adopt-research-2026-06-19.md` | yes | yes | yes | banner `docs/lora-eval-adopt-research-2026-06-19.md:3`; source `cascade-inventory.md:183` |
| `docs/second-review-2026-06-17/03-capabilities-catalog.md` | yes | yes | yes | banner `docs/second-review-2026-06-17/03-capabilities-catalog.md:3`; source `cascade-inventory.md:185` |
| `docs/second-review-2026-06-17/README.md` | yes | yes | yes | banner `docs/second-review-2026-06-17/README.md:3`; source `cascade-inventory.md:185` |
| `docs/repo-intelligence/2026-06-17-gitnexus/03-openspec-input.md` | yes | yes | yes | banner `docs/repo-intelligence/2026-06-17-gitnexus/03-openspec-input.md:3`; source `cascade-inventory.md:186` |
| `docs/repo-intelligence/2026-06-17-gitnexus/README.md` | yes | yes | yes | banner `docs/repo-intelligence/2026-06-17-gitnexus/README.md:3`; source `cascade-inventory.md:186` |
| `docs/project/brainstorm-2026-06-17-demo-mvp.md` | yes | yes | yes | banner `docs/project/brainstorm-2026-06-17-demo-mvp.md:3`; source `cascade-inventory.md:187` |
| `docs/handoffs/2026-06-18-change2-cockpit-spike.md` | yes | yes | yes | banner `docs/handoffs/2026-06-18-change2-cockpit-spike.md:7`; source `cascade-inventory.md:188` |
| `docs/handoffs/2026-06-20-c3-c6-archive-closeout.md` | yes | yes | yes | banner `docs/handoffs/2026-06-20-c3-c6-archive-closeout.md:12`; source `cascade-inventory.md:188` |
| `docs/dispatches/2026-06-20-p1-a-c5-data-gate-dispatch.md` | yes | yes | yes | banner `docs/dispatches/2026-06-20-p1-a-c5-data-gate-dispatch.md:12`; source `cascade-inventory.md:189` |
| `docs/c5-recovery-2026-06-22/8d-rootcause.md` | yes | yes | yes | banner `docs/c5-recovery-2026-06-22/8d-rootcause.md:3`; source `cascade-inventory.md:190` |
| `docs/c5-recovery-2026-06-22/exec-plan.md` | yes | yes | yes | banner `docs/c5-recovery-2026-06-22/exec-plan.md:3`; source `cascade-inventory.md:190` |
| `docs/c5-recovery-2026-06-22/grill-checklist-30.md` | yes | yes | yes | banner `docs/c5-recovery-2026-06-22/grill-checklist-30.md:3`; source `cascade-inventory.md:190` |
| `docs/c5-recovery-2026-06-22/dispatch-prompt-to-codex.md` | yes | yes | yes | banner `docs/c5-recovery-2026-06-22/dispatch-prompt-to-codex.md:3`; source `cascade-inventory.md:190` |
| `docs/c5-recovery-2026-06-22/roadmap.md` | yes | yes | yes | banner `docs/c5-recovery-2026-06-22/roadmap.md:7`; source `cascade-inventory.md:190` |

## 状态变化需 commander 复核（2）

| 源表项 / 归一目标 | 当前状态 | 原因 | 建议 |
|---|---|---|---|
| `docs/project/cockpit-voice-fc-premortem-2026-06-18.md` | missing | T5 `project/ 早期` 行列此路径（`cascade-inventory.md:187`），但当前不存在；同名内容实际在根路径 `docs/cockpit-voice-fc-premortem-2026-06-18.md`，且该根路径已带 banner `:3`。 | 不自动 banner；commander 决定是修正清单路径、忽略重复项，还是补移动/别名说明。 |
| `docs/research/2026-06-21-rules-skills-loading-optimization/README.md` | missing | T5 `诊断/优化分析` 行列目录 `research/2026-06-21-rules-skills-loading-optimization/`（`cascade-inventory.md:191`），当前目录不存在；`find docs/research -maxdepth 2 -type d` 未见该目录。 | 不自动 banner；commander 复核是否曾改名、未入仓、或应从 T5 删除。 |

## 不纳入本次 75 的当前 glob drift

| 文件 | 当前状态 | 为什么不纳入 B4a 75 |
|---|---|---|
| `docs/handoffs/2026-06-23-doc-cascade-pushed-a2-refactor-dispatch.md` | 已有历史/收口语义，且头部说明是“文档级联长跑收口 + push + A2 重构 dispatch” | 当前 handoffs glob 会多算它；它是级联收口/后续 A2 派单语境，不属于源表 75 的历史快照批。 |
| `docs/dispatches/2026-06-23-a2-code-refactor-cc-ultracode-dispatch.md` | A2 code-only 派单 | `cascade-inventory.md:5` 指向它作为 A2 code-only 执行派单；不是 T5 banner 批历史快照。 |

## B4b 建议

1. B4b 自动 banner 只处理“确认可 banner”的 49 个文件。
2. 跳过 24 个已有 banner 文件，避免重复头。
3. 对 2 个 missing / path drift 项先等 commander 裁决。
4. B4b 脚本不要直接用当前 `docs/handoffs/*.md` / `docs/dispatches/*.md` glob；必须使用本报告冻结的 75 口径或显式 allowlist，否则会把 A2 派单和级联收口件误纳入。

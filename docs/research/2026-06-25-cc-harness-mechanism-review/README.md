# CC Harness 管控机制复盘 + 业界对标（机制分层落位）

> 2026-06-25。/learn-eval + /pre-mortem 复盘：teardown 最近 3-5 天 main + uiue 两树会话历史（5 subagent 并行）+ 业界对标（最近半个月活跃 CC harness repo）+ 本机现状盘点 → **机制分层落位表**（每条沉淀升级到 rules / CC 机制 / grill-with-docs / 项目 doc）。
> CC 版本：2.1.191（最新）。方法：5 路 subagent CC 并行 teardown + oracle 联网（github-first 新鲜度 + source）；🔴 主线程亲核驱动决策的 repo/star/hook 事件（ultracode-7lens 第7点 + claim-vs-reality §28）。
> 一手 finder full_markdown 见下方 transcript 一手指针；transcript 仓外 `~/workspace/raw/05-Projects/MAformac/research/2026-06-25-cc-harness-transcripts/`。

## 〇、核心结论（机制分层落位表）

> 三路 teardown 一致判断：**执行纪律层已 over-sedimented（44 rules/2172 行全核够），真空白在 ① grill 流程模板/骨架预留 ② 框架编排层 doc ③ 业界没用透的 CC 机制（hook per-turn 注入 / correctness enforce）**。只需 1 新 always-on rule，其余 absorb/回写/CC 机制。

| 类别 | 沉淀 | 落位 | 风险 |
|---|---|---|---|
| **升级 rules**（always-on recognition）| 🆕 A-3 grill 基线骨架预留 | 新建 `grill-baseline-skeleton-upfront.md`（derived-tracking 前置环）| 低 |
| | C-B1 anchor 硬门「超过非复刻」+ grill>anchor | absorb `aesthetic-first-principles.md` | 低 |
| | C-B3 demo mock 桩态≠真接线态 | absorb `completion-claim-triage.md` | 低 |
| **升级 grill-with-docs**（"grill with me" skill）| A-2 grill 落档 5 段模板 | absorb skill `DECISION-ENTRY-TEMPLATE.md` | 低 |
| **升级 heavy-work skill** | C-B2 长跑每 phase 滚动审计（异源限时+基线回顾+截图对照）| absorb `heavy-work §3③` | 低 |
| **升级 CC 机制**（业界，高风险全局）| 🔴 UserPromptSubmit 每 N turn **drift 复述** hook | 评估实装（治「认知到≠行为改」）| 高（改 settings）|
| | PostCompact hook 校验（官方 2.1.191 有）| 评估实装 | 高 |
| | wire 休眠的**异源 grader/recompute** 内核（`lib/` 有未引用）| 评估（correctness enforce 最大空白）| 高 |
| | 核对 `rules/hooks.md` 速查表 vs 官方 16 事件 | 维护 | 低 |
| **回写项目 doc**（编排层，cross-worktree）| 框架链锚点+Pocock 诚实标注 / propose vs apply 判定 / 七段 drop | `collaboration §7` / `CLAUDE §2` | 中（cross-worktree）|

## 一、三路 teardown 沉淀清单（详见 transcript 一手）

- **A grill 流程**：grill→派单复用 ✅已沉淀(dispatch-inline-ssot) / 🔴 grill 落档模板未沉淀(→skill) / 🔴 grill 跟踪骨架预留未沉淀(→新 rule，最高价值，是 derived-tracking 前置缺失环：骨架不存在→回写无处→攒到追问才补建+drift)。
- **B 框架联动**：执行纪律层 over-sedimented(7 rules)；编排层 doc 缺口——框架链(grill→change→plan→执行→archive + 三层 SSOT 分离[契约spec/决策grill/计划非SSOT必退役]) / 🔴 Pocock 形同虚设(9 次命中全 schema 转述，实际 /goal+handoff 路由) / propose vs incremental apply 判定 / 七段模板 drop。
- **C 通用管控**：已沉淀 7 条核够；🔴 未沉淀 3 条 = anchor 硬门超过(B1) / 长跑滚动审计(B2) / mock 桩态边界(B3)。

## 二、业界对标（A，全亲核真实，详见 transcript 一手）

13 个 2026-06 活跃 repo。最相关：
- 🔴 `egoisth777/baseline`(0★ 2026-06-24，亲核真)：**UserPromptSubmit 每 N turn drift 复述** hook = 治「认知到≠行为改」根因(always-on rule 被 attention 稀释，机械重注 > 自觉)。
- `hinanohart/claude-memory-router`(0★ 真)：memory 路由 hook 治 "Claude got dumb"(通用词拖无关 note)。
- `Zandereins/schliff`(3★ 真)：instruction 文件确定性 8 维打分 lint(0 依赖)。
- `Junhanliu-dev/espalier-engineering`(真)：scout 扒 pattern→编码 rules/skills/agents/hooks+pipeline(机制全是我已有的)。
- `obra/superpowers`(238,455★ 真，我已 adopt v6.0.3)。
- **官方演进**(WebFetch 实证)：hook 16 事件(新增 PostCompact/PostToolUseFailure/PostToolBatch/MessageDisplay/CwdChanged/SessionEnd/StopFailure/UserPromptExpansion) + "A harness for every task" blog 正名 ultracode(三失败模式 agentic-laziness/self-preferential-bias/goal-drift) + 上下文工程(compaction/note-taking/sub-agent)。

## 三、本机现状（B，详见 transcript 一手）

机制分层：rules(44/2172 行 always-on recognition) / CLAUDE+MEMORY(session-start 记忆) / cite-verify+pre-commit+make verify(机械 enforce) / skills(procedure，passive 37-50%)。
🔴 **6 空白**：① correctness enforce 全休眠(异源 grader/recompute 内核在 `~/.claude/scripts/lib/` 但 settings.json 零引用 → 🔴 **Q7 拍 A：故意休眠=设计验证用，correctness 靠人+元扳机①核源+cite-verify mechanical+主线程亲核+手动 cross-vendor；别假装 active enforce**) ② cite-verify PostToolUse 白名单窄(不含 CLAUDE/SRD/MASTER) ③ rules 2172 行 attention 稀释 ④ 派生跟踪 recognition 无 enforce 兜底 ⑤ skill 触发 37-50% 漏 ⑥ token hook 停用(磊哥裁决)。

## 四、🔴 亲核记录（claim-vs-reality §28 + ultracode-7lens 第7点）

- ✅ **5 repo star/pushedAt 全真**(gh repo view)：superpowers 238,455★(我凭印象误判「不可能 238k」→实际真有，**双向教训：finder 可能编造，我也可能凭印象误判 finder 编造**) / baseline·memory-router 0★ / schliff 3★ / espalier，description 全印证 finder。
- ✅ **官方 16 hook 事件全真**(WebFetch code.claude.com/docs/en/hooks)：7 新增事件确认存在 → 驱动「加 PostCompact 校验 + 核对速查表」决策可信。
- ✅ **finder 自拦 2 处编造**：arxiv `2603.05344`(假，真 2507.14417) + "29 events"(社区数) 均未采纳。
- **结论**：A 路 finder 零编造混入，业界声称可放心驱动决策。

## 五、brainstorm 拍板（Q1-10 已拍，详见 `brainstorm-decisions.md`）

**战略主线（Q1=A）**：核心铁律「秉持机制」从 rules 在场靠自觉 → **per-turn hook 机械重注**（治 attention 稀释根因）。
**核心方案**：元扳机「动作点四问」(Q2=D) / 信号触发+每8turn兜底(Q3) / 分化措辞(Q4) / 三段实装纪律(Q5) / +PostCompact 校验(Q6=B) / 不 wire 异源 grader 保持休眠(Q7=A) / 全做 5 条低风险沉淀(Q8=A) / 项目宪法等 main(Q9=B) / 分档推进(Q10=D)。
**执行三档**：档1 本会话立即(5 条沉淀+README 休眠+hooks 核对，✅ 已执行) / 档2 hook 跨会话(三段实装) / 档3 等 main(项目宪法 3 条，内容备好)。

## Sources（亲核）
- [Anthropic 上下文工程](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) · [A harness for every task](https://claude.com/blog/a-harness-for-every-task-dynamic-workflows-in-claude-code) · [官方 hooks](https://code.claude.com/docs/en/hooks) · [官方 memory](https://code.claude.com/docs/en/memory)
- repo: obra/superpowers · egoisth777/baseline · hinanohart/claude-memory-router · Zandereins/schliff · Junhanliu-dev/espalier-engineering（全 gh 亲核 2026-06-25 活跃）

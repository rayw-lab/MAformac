# Brainstorm 决策：CC 机制升级（10 问，逐题拍板）

---
status: brainstorm_decisions_in_progress
artifact_kind: brainstorm_decision_log
authority: decision_log_not_ssot
created_at: 2026-06-25
topic: CC harness 机制升级（核心铁律下沉 per-turn hook）
inputs: [README.md 机制分层落位表, 三路 teardown, 业界对标 A(亲核), 现状 B]
note: codex 长跑共享 uiue worktree, 本档 untracked + raw 备份, 暂不 commit(避让 codex git index)
---

> 磊哥 /brainstorming 10 问逐题拍板。一次一问 + ⭐ 推荐。本档实时记录拍板（derived-tracking-writeback：决策回写别只对话里）。
>
> 🔴 **三份 artifact 职责分层（2026-06-26，防分叉）**：本档 = **决策史**（为什么这么定，Q1-Q10/A1-A4 拍板史）；`harness-upgrade.spec.md` = **实施态 SSOT**（全脑暴 14 项 phase matrix + 契约/验收/态，到哪了）；`~/.claude/scripts/hooks/action-trigger-inject.spec.md` = **hook 行为契约**（C1-C5 + 验收门 + 回滚）。查「做到哪了」去 spec，查「为什么」来本档。

## 🔴 战略主线（Q1 定）：核心铁律「秉持机制」从 rules 在场靠自觉 → **per-turn hook 机械重注**（治 attention 稀释根因）

**矛盾**：rules 已 44 个/2172 行 over-sedimented，但「认知到≠行为改」今天仍反复犯（dispatch-inline 沉淀后又凭印象误判 superpowers 编造 / goal-dispatch 同 session 复犯 / grill-recall 三连）→ 加 rule 边际递减（rule 在场但 attention 稀释，不在动作点）。业界解 = `egoisth777/baseline` repo 的 per-turn UserPromptSubmit drift 复述 hook。

## 逐题拍板（Q1-Q5 已拍）

| Q | 问题 | 选项 | 🔴 磊哥拍 | physical landing |
|---|---|---|---|---|
| **Q1** | 核心铁律秉持机制往哪走 | A 转机制层 / B 守 rules+异源 / C 混合渐进 | **A**（转机制层 hook per-turn 重注）| 高频复犯铁律下沉 UserPromptSubmit hook |
| **Q2** | hook 重注什么内容 | A 单条 / B 3条 / C 动态 / D 元扳机四问 | **D**（元扳机「动作点四问自检」一句，不复述具体 rule）| 注四问扳机，非 rule 全文 |
| **Q3** | 何时注/多频 | A 每prompt / B 每N / C 双层 / D 信号触发 | **D+B**（信号触发注对应一问 + 每 8 turn 兜底注全四问）| 单 UserPromptSubmit hook：关键词信号→注对应一问；turn 计数%8==0→注全四问兜底漏检 |
| **Q4** | 精确措辞 | A 极简 / B 分化 / C 带rule名 / D 全带 | **B**（分化措辞：触发版带动作 / 兜底版四问标题，不带 rule 名/file:line）| 见下「四问措辞」 |
| **Q5** | 安全实装纪律 | A 直接用户级 / B 项目级先试 / C 三段 / D 用户级+killswitch | **C**（三段：沙盒验 schema/killswitch/备份 → 项目级 settings.local.json ≥5 会话误伤<1/3 → 用户级）| hook 落 `~/.claude/scripts/hooks/action-trigger-inject.mjs`；注意多 UserPromptSubmit hook 叠加(handoff-inject 首轮 + 本 hook 每 prompt) |

## 🔴 四问元扳机措辞（Q2/Q4 定）

**信号触发版（D，注对应一问 + 一句动作）：**
- `/goal`·派单 → `🔴 动作点②：切片还是全貌？先读派单计划全貌 + grep grill SSOT 承接，别机械执行 goal 切片`
- 要写基线数字/断言 → `🔴 动作点①：凭印象还是核源？grep file:line / gh 核，派生表征≠一手`
- grill → `🔴 grill 前回顾该议题现有决策，别凭印象拍`
- 要给选择题/想推迟 → `🔴 动作点④：真口径型(上抛)还是遇难退缩(选难自驱)？`

**兜底版（B，每 8 turn 注四问标题极简）：**
`🔴 动作点四问自检：①数字/断言核源了吗 ②执行回溯全貌了吗 ③状态变更回写派生跟踪了吗 ④想上抛=口径型还是退缩`

## 逐题拍板（Q6-Q10 已拍）

| Q | 问题 | 🔴 磊哥拍 | physical landing |
|---|---|---|---|
| **Q6** | 业界其它 3 机制 | **B**（元扳机 hook + PostCompact 校验；memory 路由/schliff 评估后续）| PostCompact 注「重读 continuation+自检铁律」治 compact 失忆 |
| **Q7** | 异源 grader wire | **A+elephant**（不 wire 保持休眠；README 标「内核=设计验证用故意休眠，correctness 靠人+手动 cross-vendor」别假装 active enforce）| correctness 靠元扳机①+cite-verify mechanical+主线程亲核+手动 cross-vendor |
| **Q8** | 低风险沉淀范围 | **A**（全做 5 条）| A-3 新 rule + C-B1/C-B3 absorb + A-2 grill 模板 + C-B2 heavy-work |
| **Q9** | 项目宪法 cross-worktree | **B**（等 main 主线回写，内容备好防忘）| 见下「main 待回写」段 |
| **Q10** | 实装优先级 | **D**（分档）| 见下「执行三档」 |

## 🔴 执行三档（Q10）

**档 1 — 本会话立即（低风险全局 `~/.claude/`，不撞 codex uiue worktree）**：
- Q8 5 条：① 新建 `~/.claude/rules/grill-baseline-skeleton-upfront.md` ② absorb `aesthetic-first-principles.md`(anchor 硬门超过) ③ absorb `completion-claim-triage.md`(mock 桩态) ④ absorb grill-with-docs skill `DECISION-ENTRY-TEMPLATE.md` ⑤ absorb heavy-work skill §3③(滚动审计)
- Q7 README 标休眠内核 + hooks.md 速查表核对(加官方 16 事件)

**档 2 — hook 跨会话（三段纪律 Q5）**：写 `~/.claude/scripts/hooks/action-trigger-inject.mjs`（D+B 信号触发+每8turn兜底 / B 分化措辞 / 元扳机四问）+ PostCompact 校验 → sample 测+kill switch → 项目级 ≥5 会话误伤<1/3(等 codex 收口或别 worktree) → 用户级迁移。

**档 3 — 等 main 主线回写（项目宪法）**：见下。

## 🔴 main 主线待回写（Q9，内容备好，main session 起手直接 apply）

1. **`collaboration §7`**：① 框架链编排锚点（grill-with-docs→决策SSOT→openspec change[契约SSOT,判 propose vs incremental apply]→writing-plans plan[authority=非SSOT必退役]→heavy-work执行→archive）+ 三层 SSOT 分离 ② 🔴 **Pocock 诚实标注**：「Pocock 实际未驱动阶段路由(9 次命中全 schema 转述)，阶段由 /goal 派单+handoff 决定；退化为 phase0 manifest 一次性分诊。要么真用要么明退，别留虚条目误导新 session」。
2. **`CLAUDE §2`**：propose 新 change vs incremental apply 判定 gate——「契约已在 spec 锁全 → incremental apply(改 tasks/勾选,非 propose)；spec 缺 Requirement → propose 新 change。判错重复 propose 污染 changes/」。
3. **`collaboration §4.5`**：七段 closure 硬模板 drop/降级(与 session-closure Step5 重叠,over-engineering,保留 handoff append-only)。

---

## 🔴 档 2 hook 实装脑暴（A 系列，2026-06-26，承接 Q1-Q5；每拍即填，不攒）

> explore 坐实现状：UserPromptSubmit 现挂 `token-threshold-hook`(磊哥裁决忽略 token 但还在跑)+`handoff-inject`(首轮冷注入) 2 hook / turn 计数复用 handoff-inject 的 `~/.claude/logs/.first-prompt-${sessionId}` marker 模式(改 `.turn-count-${sessionId}` 累加) / `lib/hook-utils.mjs` 有 `readStdin`(拿 `input.prompt`) / PostCompact 现 `null` 需新加 key。

| A | 问题 | 🔴 拍 | physical landing（inline 规则，落进 script）|
|---|---|---|---|
| **A1** | 注入点 frame（UserPromptSubmit 看磊哥话 vs PreToolUse 看我动作）| **B** | 两条腿：① **UserPromptSubmit**=每 8 turn 兜底 priming(注全四问标题，复用 sessionId marker 累加 turn 数 %8==0)；② **PreToolUse 极窄动作点**：`Write/Edit` 且 `file_path` 命中 `/docs/\|/rules/\|/contracts/\|/openspec/\|CLAUDE.md\|MEMORY.md` → 注①核源；`Agent`(dispatch) → 注②回溯全貌；**Read/Grep/Bash 一律放行**(防爆 context + 卡窗口) |
| **A2** | UserPromptSubmit 信号词表宽窄 | **B 窄** | 只匹配高确定性 **magic word**：`/goal`、"派单"/"dispatch" → 注②回溯全貌；"grill" → 注 grill-recall(回顾该议题现有决策)。**其余自然语言不匹配**(误检零容忍)；漏的隐晦说法靠每 8 turn 兜底 + PreToolUse `Agent` 动作点双重接住 |
| **A2-附** | `token-threshold-hook` 顺手摘 | **摘**(磊哥两轮未否决 CC ⭐，按 §19 default 执行) | 实装时从 `settings.json` UserPromptSubmit hooks 数组移除 `token-threshold-hook`；settings.json 已 .bak 备份可一键恢复 |
| **A3** | PostCompact 去重（`session-start-compact.mjs` 已在 compact 后注入）| **B** | **不新增 PostCompact 事件**；把「📌 compact 后：重读 `continuation-prompt.md` + 四问铁律自检」一句**并进已有 `~/.claude/scripts/session-start-compact.mjs`**(SessionStart matcher=compact，已注 recovery，加一句铁律)。唯一权威源 + 零新事件 + 零重复注入。若日后实测 PostCompact 触发时机早于 SessionStart(compact) 可拦在 recovery 前，再独立加(当前无证据 YAGNI) |
| **A4** | 软注入「试验成功→迁用户级」门（Q5「误伤<1/3」对软注入 ill-defined）| **B 轻量主观门** | 软注入不阻断 ≠ block，**不套精确误伤率**。PreToolUse=动作触发(相关性≈100%)；UserPromptSubmit/8turn 看磊哥主观(帮到/中性/烦)。试点落 **uiue worktree `.claude/settings.local.json`**(gitignored 不撞 codex index、codex CLI 不读 Claude settings、只影响本 session) ≥5 会话顺了迁用户级。PreToolUse 写 jsonl(tool+path) 供抽查**不设阈值门** |

## 🔴 脑暴 A 收口：完整可写 script 规格（下会话直接照写，dispatch-inline 具体规则非编号）

**文件**：`~/.claude/scripts/hooks/action-trigger-inject.mjs`（单文件，`input.hook_event_name` 分支处理 UserPromptSubmit + PreToolUse，DRY 唯一权威源）

**通用骨架**（复用 harness-enforce 4 件套）：
- 首行 `if(process.env.HARNESS_ENFORCE_DISABLED) process.exit(0)`（killswitch）
- `try { readStdin } = await import('../lib/hook-utils.mjs') catch { exit0 }`
- fail-closed：任何异常 → `exit 0`（绝不破坏 prompt/动作）
- 输出 `{hookSpecificOutput:{hookEventName,additionalContext}}`，slice 上限 9000

**分支 1 — UserPromptSubmit**（看磊哥的话，预测式 + 兜底）：
1. turn 计数：读 `~/.claude/logs/.turn-count-${sessionId}` → +1 → 写回（解 UserPromptSubmit 无状态；复用 handoff-inject 的 LOG_DIR+sessionId 模式）
2. 窄信号匹配 `input.prompt`（A2 magic word，误检零容忍）：
   - `/goal` 或 `/派单|dispatch/` → 注 ②回溯
   - `/grill/` → 注 grill-recall
3. 兜底：`turn % 8 === 0` → 注全四问标题（本轮已有信号注入则跳过兜底，避免重复）

**分支 2 — PreToolUse**（看我的动作，精确拦截）：
- `tool_name ∈ {Write,Edit}` 且 `tool_input.file_path` 正则 `/(\/docs\/|\/rules\/|\/contracts\/|\/openspec\/|CLAUDE\.md|MEMORY\.md)/` → 注 ①核源
- `tool_name === "Agent"` → 注 ②回溯
- 其余(Read/Grep/Bash/Glob/...) → `exit 0` 放行
- 🔴 **软提示用 additionalContext，不 deny**（hooks.md：PreToolUse deny 易触 #24327 idle 停机）
- 写一行 jsonl `~/.claude/logs/action-trigger.jsonl`（`{tool,path,injected}` 供抽查，A4 不设阈值门）

**四问措辞定字**（Q2/Q4 + 收口微调）：
- ①核源(Write/Edit 基线)：`🔴 动作点①核源：写进基线的数字/断言/file:line — 凭印象还是 grep/gh 核过？派生表征(receipt/聚合/config)≠一手`
- ②回溯(Agent/派单/goal)：`🔴 动作点②回溯：派单前 SSOT 关键决策 inline 进 task 了吗(规则+file:line 非编号)？执行切片回溯派单全貌+grill SSOT 了吗`
- grill 信号：`🔴 grill 前回顾该议题现有决策(grill SSOT/已定原则)，基于一手提问别凭印象拍`
- 兜底(turn%8)：`🔴 动作点四问自检：①数字/断言核源了吗 ②执行回溯全貌/派单 inline 了吗 ③状态变更回写派生跟踪了吗 ④想上抛/简化=口径型(上抛)还是遇难退缩(选难自驱)`

**settings 改动**：UserPromptSubmit 数组【移除 token-threshold-hook + 增 action-trigger-inject，保留 handoff-inject】/ 新增 PreToolUse matcher 挂 action-trigger-inject（注意与现有 PreToolUse hook 并行，parallel-safety）/ `session-start-compact.mjs` 末尾加一句四问铁律(A3)

**turn 间隔 = 8**（先 8 主观调；compact 后 sessionId 变→turn 重置=feature，compact 后重新数合理）

**三段实装纪律（Q5+A4）**：① 沙盒 `echo '<构造 input>' | node action-trigger-inject.mjs` 验 schema/killswitch/turn计数/匹配 ② uiue worktree `.claude/settings.local.json`(gitignored) ≥5 会话主观判 ③ 顺了迁 `~/.claude/settings.json`

## 🔴 档 2 实装进度（2026-06-26，三段第①②段已落）

- ✅ **第①段 沙盒验全绿**（8/8 case）：`node --check` OK / UserPromptSubmit 信号(派单→②回溯·grill→grill-recall) / 无信号 ×8 第8次注兜底四问(turn marker 累加正确) / PreToolUse Write 基线路径→①核源·Agent→②回溯 / Read·非基线 Write 放行 / killswitch 静默 / 坏 JSON fail-closed exit0 / jsonl 抽查记录 tool+path。
- ✅ **第②段 挂载 uiue worktree** `.claude/settings.local.json`（gitignored，git check-ignore 确认不撞 codex index；codex 正改 App/Core 大量 M，与 gitignored settings 隔离）：UserPromptSubmit + PreToolUse 各挂 `action-trigger-inject.mjs`，保留原 permission，node 程序化改 + 断言(permission 完好/双 hook 已加/JSON 合法)全绿。.bak 备份。**本试点仅本 worktree session 生效**，下条 prompt 起 hook 即激活。
- 🔴 **frame-break 发现**：现有 `cite-verify-posttool.mjs`(PostToolUse 写后机械核「写进基线文档的数字 source value-in-source」)与本 hook 的 PreToolUse ①核源(写前软提醒思考)**互补不重复**——一个写后机械核数字、一个写前提醒「凭印象还是核过」。保留两者。
- ⏳ **第③段 待**：≥5 会话主观判「帮到/中性/烦」→ 顺了迁用户级 `~/.claude/settings.json`（同时摘 token-threshold-hook + session-start-compact 加四问铁律 A3）。**观察重点**：PreToolUse Write 基线路径 ①核源触发频率（写 docs/ 频繁，可能烦→收窄路径或只留 Agent 那条）。jsonl `~/.claude/logs/action-trigger.jsonl` 供抽查。
- ⏳ **token-threshold-hook 摘 + A3 session-start-compact 加铁律**：延到第③段迁用户级时一并做（避免现在改用户级 settings.json 引入风险，试点先只动 worktree local）。

## 📊 试点数据快照（2026-06-26，截至 ios-frontend 调研 session）

- jsonl 累计 **15 次 PreToolUse 触发 / 4 个不同 session**（差 1 达「≥5 会话」门）/ 全 2026-06-26。
- 触发分布：Agent **②回溯 9** · Write+Edit **①核源 6**。
- 🔴 **迁用户级前必决（试点暴露的真实误检）**：**Agent ②回溯对「调研型 Agent」误检**——本 session 派 8 个调研 finder 全触发「派单前 SSOT inline 进 task 了吗(规则+file:line 非编号)」，但**调研 finder ≠ 实施派单**，②措辞（承接 `dispatch-inline-ssot` 规则，假设是实施单）对纯调研 finder 不适用 = 误检（9 次 ②触发里多数是 finder 派发）。
  - 修法二选一（迁用户级前定）：**⭐① 收窄 Agent 触发**（prompt/上下文含「实施/派单/dispatch/apply/重构」类信号才注 ②；纯调研 finder 放行，误检零容忍优先）/ ② ②措辞兼容调研型（「若实施派单：SSOT inline 进 task；若调研：本提示忽略」，但措辞变长易稀释）。
- Write/Edit **①核源 6 次**（写 docs/ 基线路径），暂未到「频繁到烦」阈值，继续观察（第③段观察重点之一）。
- **下一步**：再积累 ≥1 会话（达 4→≥5）+ 主观判帮到/中性/烦 → 顺了走迁用户级（一并：收窄 Agent 触发[上条]、摘 token-threshold-hook、session-start-compact 加 A3 铁律），迁前补轻量验收 spec（hook 行为契约 + 误检门 + 回滚，SDD「spec 成本<rework 成本」对用户级成立）。

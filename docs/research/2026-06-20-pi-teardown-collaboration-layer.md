# Pi teardown — 协作层机制 → MAformac 长任务开发规范（不进产品 runtime）

> **缘起**：磊哥 2026-06-20 定,深扒 `earendil-works/pi`(pi.dev 编码 agent,⭐64099,当天 push,TS/Node)的**开发协作层机制**,沉淀为 MAformac 长任务开发规范。源码只读 clone 在 `~/workspace/raw/05-Projects/MAformac/ref-repos/pi/packages/`(`agent/`=通用 harness,`coding-agent/`=应用层;CLAUDE §6 不进仓)。
> **硬边界**:**Pi 不进 MAformac 产品 runtime**——Pi 本身是完整 agent loop(撞「禁自由 agent loop」红线)+ TS/Node(撞「JS 零进 iOS」铁律)。本文**只提取协作/开发流程形态**沉淀为长任务规范(给 Codex 长跑/Claude 综合/GPT Pro 审用)。**磊哥定:沙箱/隔离/permission 不考虑**(内部 demo 本机单人,轻治理)。
> 深扒方法:blueprint-teardown(逐文件读全,带 `file:line`)。

---

## A. 六类机制深拆

### 1. session 持久化/恢复 — append-only 事件树 + leaf 指针(事件溯源)
- session **不是消息数组,是 append-only entry 树 + 一个 leaf 指针**。落盘 = JSONL,首行 header(`{type:session,version:3,id,cwd}`,`jsonl-storage.ts:200-212`),之后每行一条 entry,**永不回写已有行**,只 `appendFile`(`:250-259`)。崩溃最多丢最后一行。
- entry 是 **11 种类型判别联合**(`types.ts:409-420`):`message/thinking_level_change/model_change/active_tools_change/compaction/branch_summary/.../leaf`。即「模型切换、思考档切换、工具集变更、压缩点」全作为**一等事件落进同一时间线**,不是旁路状态。
- 每 entry 带 `parentId` 构成树。**当前状态 = 从 leaf 沿 parentId 回溯到 root 的路径**(`jsonl-storage.ts:275-288` `getPathToRoot`),再 `buildSessionContext` 重放成 LLM 消息(`session.ts:22-80`)。**状态用「重放事件流」而非「读快照」重建** → 确定性可复现。
- `leaf` 自身也是 entry(`:226-244`)——「现在站在树哪个节点」也是 append 的历史 → 时间旅行/分叉后还知当时 leaf。
- 内存镜像与 jsonl 同一个 `SessionStorage` 接口(`types.ts:440-454`),测试用内存生产用 jsonl,逻辑零分叉。
> 思想:**事件溯源**——状态 = 不可变事件追加 + 确定性重放。对上 coding-style immutability 铁律。

### 2. message queue — steering/follow-up/nextTurn 三队列分级注入
- 用户在 agent 跑时插话,按「多急」分三队列(`agent-harness.ts:193-197`),**注入点不同**,各有 `QueueMode`(all/one-at-a-time)。
- **steer(最急)**:loop 内层,**下次 assistant 响应之前**就 push 进 context(`agent-loop.ts:166-190`)——立刻改方向。
- **follow-up(追问)**:agent **本要停了**,外层 loop 检查队列有就续命再跑一轮(`agent-loop.ts:256-262`)——不重开 session 连续追问。
- **nextTurn**:纯排队,下次 `prompt()` prepend。
- 取队列是**回调注入**,loop 不知队列在哪(`getSteeringMessages?.()`/`getFollowUpMessages?.()`)。drain 失败 `queue.unshift` 回滚不丢输入(`agent-harness.ts:415-417`)。
> 思想:**「插话」是一等公民且按急迫度分级注入**。外层 follow-up loop 让「一个长任务=多轮连续对话」而不重建上下文。

### 3. before/after tool hook — block/patch/replace/prepareArguments 四种干预
- **beforeToolCall**:`{assistantMessage,toolCall,args}`→`{block?,reason?}`(`types.ts:679-682`)。`block:true`→变 error toolResult,工具**根本不执行**(`agent-loop.ts:581-605`)。「安全门/越界」物理挂点。
- **afterToolCall**:可改写 content/details/isError,可 `terminate`(达成即停)(`agent-loop.ts:682-707`)。「结果脱敏/校验」挂点。
- **validateToolArguments** 在 before hook **之前**跑(`agent-loop.ts:580`),schema 失败直接 error 收口。
- 应用层升级成 **20+ 事件总线**(`coding-agent .../types.ts:1125-1163`):`tool_call`(可 block)/`tool_result`(可 patch)/`context`(可改整上下文)/`before_agent_start`(可换 systemPrompt)/`session_before_compact`(可接管压缩)。
- **多 handler 链式聚合**:`emitHook` 顺序跑,后者覆盖前者非 undefined 返回(`agent-harness.ts:255-265`)。聚合策略显式写死。
> 思想:**「能改什么」由返回类型契约枚举钉死**(`AgentHarnessEventResultMap`,`types.ts:704-724`)→ 对上 codex-metacognition §5「prevent rule 写不进 schema=没写」。

### 4. RPC-SDK — 三种 headless 入口,同一 session 内核
- **SDK**(`sdk.ts:166` `createAgentSession`):工厂函数,所有依赖可注入,**自动续接**(发现已有数据就恢复 model/messages),model 不可用给 fallback 不硬崩。
- **print mode(单发)**:`pi -p "prompt"`→发、输出、退出。`mode:json` 每事件一行 JSON。**Codex/CC headless 一把梭形态**。
- **RPC mode(流式双工)**:stdin JSON 命令/stdout JSON 事件,**LF-only 严格 JSONL 帧**(`jsonl.ts:21-58`,故意不用 Node readline 因它在 JSON 串内 U+2028/2029 误断行)。命令集完整 enum(`prompt/steer/follow_up/abort/compact/fork/get_state...`)带 `id` 关联。**背压感知**(`rpc-mode.ts:742` 下游慢就等)。`get_state` 暴露 `isStreaming/isCompacting/pendingMessageCount`(外部判「能不能下一条」)。
> 思想:**「人在终端交互」和「程序驱动」是同一内核不同外壳**。长任务自动化驱动该走 RPC/print headless 协议。

### 5. extension-skills — SKILL.md 文件即能力,frontmatter 即契约
- **加载**(`skills.ts:49`):递归扫目录认 `SKILL.md`+根级 `.md`,尊重 `.gitignore`,跳过 `node_modules`。
- **frontmatter=契约**(`skills.ts:30-35`):`name/description/disable-model-invocation`。**强校验**:name `^[a-z0-9-]+$`、≤64、与父目录名一致;description 必填≤1024。违规出 **diagnostic warning 而非崩**(坏 skill 不拖垮加载)。
- **description=模型可见的「何时用」**(插 system prompt),name+description 进列表让模型自己挑;`disable-model-invocation` 可藏起只允显式调用。
- **触发**(`skills.ts:38-41`):包成 `<skill name="..." location="...">{content}</skill>` 注入,**带 location+相对路径基准**让模型顺读引用文件。
- **prompt-template 是姐妹**:`.md`+frontmatter+**参数替换**(`$1/$@/$ARGUMENTS`)=slash command。
> 思想:**能力=带契约的 markdown 文件,单一权威源在磁盘** → 对上 codex-metacognition §7「唯一权威源+短入口」。MAformac `~/.claude/skills/`+`docs/research/INDEX.md` 已同构。

### 6. compaction — 长任务上下文不爆的核心算法
- **何时压**:`contextTokens > contextWindow - reserveTokens`(`compaction.ts:202-205`,缺省 reserve 16384/keepRecent 20000)。
- **token 估算分两段**:优先用 provider 真实 usage,其后消息才用字符÷4 估(`:162-199`)——**已知用真值,未知才估,不全靠拍**。
- **切点必须落 turn 边界**:`findValidCutPoints` **绝不在 toolResult 处切**(`:283-284`,否则 toolCall 和 result 被劈开 LLM 报错)。防御性正确性核心旋钮。
- **结构化 summary 模板(非自由总结)**:固定 `## Goal / Constraints & Preferences / Progress(Done/In Progress/Blocked) / Key Decisions / Next Steps / Critical Context` 七段(`:389-420`),**强令保留精确 file path/函数名/报错原文**(`:420`)。
- **迭代式更新**:已有 summary 换 `UPDATE_SUMMARIZATION_PROMPT`,规则「PRESERVE 旧+ADD 新+In Progress 挪 Done」(`:422-459`)——滚动累积项目状态非每次重写。
- **文件操作血缘**:从被总结消息抽 read/written/edited 文件集附 summary 末 + 存 compaction entry,**跨多次压缩累积传递**(`:42-65`)——长任务「碰过哪些文件」永不丢。
- **branch-summarization** 是兄弟:切换 session 树分支前把要离开的分支总结成 `branch_summary` entry,回来还在。
> 思想:**压缩=有损但结构化、可累积、保边界正确性、带文件血缘的 checkpoint**,非简单截断。这套七段模板几乎可直接当 MAformac handoff 模板。

---

## B. cross-cutting — Pi 让长任务可靠的核心工程(四件如何咬合)

**一条主轴:状态全部表达为「不可变 append-only 事件 + 确定性重放」。**
1. **jsonl session 是地基**:message/模型切换/工具集变更/压缩点/分叉/leaf 移动全是同一时间线 append entry。崩了重放 path 精确恢复,**不依赖内存快照**。
2. **queue 喂进 loop,loop 产物落进 session**:steering 内层注入、follow-up 外层续命 → 每 `message_end` 立刻 `appendMessage` → 每 `turn_end` 做 `flushPendingSessionWrites`+发 `save_point`。**「干活」和「落盘」按 turn 对齐,turn 是事务边界**。
3. **hook 是横切干预面**:before/after tool、context、before_agent_start、session_before_compact 全挂在 loop 与 session 固定生命周期点,**返回能力被类型枚举钉死**。加「安全门/脱敏/校验/达成即停」不改内核只挂 hook。
4. **compaction 在 session 树原地生长**:压缩产物是一条 compaction entry,重放时自动顶替前半历史。**压缩不破坏溯源**(原始 entry 还在文件,只是重建 context 时被 summary 短路)。

**README 看不到、代码才有的工程智慧**:drain 失败 unshift 回滚不丢输入 / 切点禁劈 toolCall-result / JSONL 严格 LF-only 防 U+2028 误断 / token 真值优先估值兜底 / summary 强令保留 file:line+报错原文 / 文件血缘跨压缩累积 / 坏 skill 出 diagnostic 不崩。

---

## C. adopt / adapt / drop → MAformac 长任务开发规范

> 落点=给 Codex 长跑/Claude 综合/GPT Pro 审用的协作规范,**流程/文档/纪律形态,零代码进产品 runtime**。

| Pi 形态(file:line) | MAformac 长任务规范落点 | 动作 | 为什么 |
|---|---|---|---|
| **append-only jsonl session 事件树**(jsonl-storage.ts:250) | 把 `docs/handoffs/` 升级为「append-only 决策事件流」:每 session 收工 append 一条 ≤40 行 handoff,**永不回改旧**;当前状态=顺读全部 handoff 重放。起手固定读链=`getPathToRoot` | adopt 思想,drop 实现 | MAformac 踩过「失忆/二手当事实源」坑(§28/§29)。事件溯源式 handoff=确定性恢复,治理成本=0 |
| **结构化 compaction 七段模板**(compaction.ts:389-420,强令留 file:line/报错原文) | 定为 MAformac handoff/session-closure **硬模板**(Goal/Constraints/Progress/Key Decisions/Next Steps/Critical Context)+ 强令保留路径行号+报错原文 | **adopt(几乎零改)** | Pi 用它让另一 LLM 无缝接力长任务,正是 MAformac 跨 session/跨 agent 接力要的,比现有 handoff 更防失忆 |
| **before/after tool hook:block+类型钉死可改什么**(agent-loop.ts:581,types.ts:704-724) | 派 Codex 长跑 prompt 必含「工具前后校验门」:动手前 grep 一手源(before=block 越界)、动完读回 mock 态校验(after=校验)。把「能 block/patch 什么」写进**派单 schema 验收门** | adopt 思想,drop 代码 | 落地 §5「prevent rule 写不进 schema=没写」+ pre-mortem 反射 |
| **RPC/print headless 协议 + get_state 状态暴露**(rpc-mode.ts) | 长任务驱动 Codex/CC 走 headless 一把梭(已有 cc-resilient.sh/Codex CLI),回稿必含「当前状态行」(git 分支/测试/make verify 结果),让综合方一眼判「能不能下一步」 | adopt 思想,drop 实现 | 对上 fresheveryday §4 派单第一性 + 「自主 write-test-fix 内循环」。已有 headless,缺「状态行」纪律 |
| **结构化 receipt(toolResult 带 isError/details,turn_end 落盘)**(agent-harness.ts:516) | C3-C7 每 change 收工产「receipt」:实测 ≥N(实数据非 mock)、失败 risk_state 落 7 枚举、make verify 结果。事务边界=一个 openspec task/一刀提交 | adapt | 已是 testing.md + memory T2「make verify 同刀改」。Pi 给了「一刀=一次完整 receipt」形态 |
| **skill=带 frontmatter 契约的 .md + 坏的不崩**(skills.ts:281) | `docs/research/INDEX.md`+`~/.claude/skills/` 已同构,补纪律:每 teardown/skill 带 frontmatter 头(用途/何时用/source),坏的 warning 不阻塞 | adopt 思想 | 轻治理不需 Pi 加载器;「能力=带契约单一权威源 md」已采用,写进规范防漂移 |
| **steering/follow-up 分级注入**(agent-loop.ts:166-262) | 派单插话纪律:对长跑 Codex 中途指令分两级——**steer(立刻改方向,停当前再发)** vs **follow-up(让它干完这步再追加)**,避免插话打断到一半 toolCall | adapt 概念,drop 队列 | 对上 execution-discipline。Pi 证明「插话按急迫度分级」避免破坏进行中事务 |
| **branch_summary/fork(分叉探索后总结回来)**(branch-summarization.ts:68) | worktree 分叉纪律:已用 git worktree 隔离并行 agent,补「分叉前/回来时总结成一条 handoff」纪律 | adapt,drop 实现(git 已提供分叉) | solo 不需 session 树;「探索分支必留 summary 回主线」防失忆,对上 blueprint-teardown 第8步 |
| **完整 agent loop / 内层多工具迭代 / Node runtime** | — | **DROP(红线)** | Pi 是自由 agent loop+TS/Node,撞「禁自由 loop」+「JS 零进 iOS」。MAformac runtime 是三层路由+单发(home-llm MAX_ITER=0),哲学相反。**只借开发协作形态,绝不借 runtime 架构** |
| **sandbox/隔离/permission/第三方包安全** | — | **DROP** | 磊哥明示:内部 demo 本机单人,轻治理,不考虑 |

---

## D. MAformac 长任务开发规范种子(3 核心形态落成可用纪律)

> 现在不立完整规范文档(无 actionable consumer=over-engineering);下次 Codex 长跑/session-closure 时按这 3 条用,验证有效再 promote 成正式规范。

1. **事件溯源式 handoff**(借 Pi append-only session):`docs/handoffs/` 永不回改旧 handoff,每 session append 一条;当前状态=顺读全部重放。已踩失忆坑(§28/§29),此形态治本,成本=0。
2. **七段 handoff 硬模板**(借 Pi compaction summary,直接抄):`Goal / Constraints & Preferences / Progress(Done/In Progress/Blocked) / Key Decisions / Next Steps / Critical Context`,**强令保留精确 file:line + 报错原文 + 碰过的文件血缘**。对齐/升级现有 `session-closure.md`。
3. **派单 schema 的工具前后验收门**(借 Pi before/after hook):派 Codex 长跑 prompt 把「prevent rule」写进验收 schema——before=动手前 grep 一手源 block 越界、after=动完读回 mock 态校验,不靠执行端自觉(落地 §5)。

---

## 一句话(Pi 最该被借的 3 个工程形态,均不进产品 runtime)

1. **append-only 事件溯源式 handoff**(jsonl-storage.ts:250+session.ts:22)——治本反复失忆,成本为零。
2. **结构化 compaction summary 七段模板**(compaction.ts:389-420,强令留 file:line/报错原文+文件血缘)——抄成 handoff 硬模板,让任意 LLM/agent 无缝接力。
3. **tool 前后 hook「block+可改什么类型钉死」契约**(agent-loop.ts:581+types.ts:704)——搬进派单 schema 验收门,prevent rule 写进契约非靠自觉。

**严守边界**:全是开发协作/文档/派单纪律,**零行代码进产品 runtime**,不引入 sandbox/隔离/Node。Pi 的完整 agent loop 与 MAformac「三层路由+单发约束」runtime 哲学相反,只站它「让长任务 agent 可靠」的工程肩膀,不抄身体。

# Lens-2 — 失忆 / 上下文持久化成熟工程深扒(主候选)

> 调研日期 2026-06-22。任务=深扒 LLM agent 失忆/跨 session 上下文持久化的成熟工程实践,对比磊哥当前 harness(MEMORY.md auto-load + handoff 六件套 + claude-mem)。
> 纪律:每条带 source URL + date;gh 热度交叉(star + pushedAt<60 天活跃);≥10 次搜证;pre-mortem 三分类。

---

## summary

外部生态把「agent 失忆」拆成两个正交问题:**(A) 跨 session 持久化**(记忆怎么存/取,不丢)、**(B) session 内 context 退化**(compaction lossy / context rot)。市场上 5 类成熟方案——claude-mem(83.6k★,磊哥已装)/ mem0(59k★,向量+图)/ Zep-Graphiti(27.7k★,双时序知识图)/ Letta-MemGPT(23.4k★,OS 式三层内存)/ engram·basic-memory(本地 markdown+SQLite MCP)——但**关键结论是:磊哥的 MEMORY.md 一行一指针 + handoff 六件套,恰好命中 2026 学术与工程共识的核心配方**(「keep MEMORY.md short, link out, decision-ready summaries in handoffs」),不是缺记忆系统。

磊哥的真漏点**不在「没有记忆」,而在「记忆是声称层」**:① 纪律写在 always-on rule 里靠自觉(max effort 仍犯第 10 坑);② MEMORY.md 会 **drift**(矛盾累积、旧决策不删 = §35 级联失守的具体机制);③ 没有 **enforce 层**(没 PreToolUse hook 拦截「grep-before-claim」)。外部对症的强方案是 **enforce 派**:Mneme(把 ADR 编译成确定性 pre-generation 检查)+ PreToolUse exit-2 硬门 + 「view memory before acting」确定性 gate——这三者直接把磊哥的「声称层纪律」提升到「code enforce」,正是 claim-vs-reality-gap 铁律 1 的项目实装。

反方警示:**Amp 走过 compaction→handoff→回退 compaction 的弯路**(2025-11 上 handoff,2026 砍掉回到 compaction),证明「fresh-agent handoff 优于 compaction」**并非业界定论**——磊哥的 handoff 六件套是对的,但不要为「跨 session 持久化」过度加机械(handoff 是给人/新 session 读的决策摘要,不是要替代平台 compaction)。

---

## key findings

### F1 — claude-mem(磊哥已装):83.6k★,捕获→压缩→注入 三段,但「压缩=lossy」是结构盲点
- `thedotmack/claude-mem` **83,648★ / pushedAt 2026-06-21**(<1 天,极活跃)。架构:hook 进 session 生命周期,捕获 tool usage → Claude Agent SDK 压缩成 typed observations(bugfix/discovery/decision)→ 注入未来 session。存储 = `~/.claude-mem/claude-mem.db`(SQLite)+ `~/.claude-mem/chroma/`(向量)。装法必须 `npx claude-mem install` 非 `npm install -g`(后者只装 SDK 不挂 hook)。
- source: https://github.com/thedotmack/claude-mem (gh verified 2026-06-22) + https://github.com/thedotmack/claude-mem/blob/main/CLAUDE.md (WebFetch 2026-06-22)
- 🔴 盲点:claude-mem 是「**自动捕获 tool 流 + LLM 压缩**」,而 LLM 压缩对「artifact tracking(改了哪些文件)」实测均分 2.19-2.45/5.0(Factory.ai 36,611 条生产消息评测)——这正是磊哥手写 handoff(「下次从哪继续 + 相关文件 ≤5」)**反而比 claude-mem 自动压缩更可靠**的原因。date: 2026(Factory.ai eval,引自 morphllm)

### F2 — mem0:59k★ 业界最大社区,向量+KV+图三存,但 LoCoMo SOTA 争议未决
- `mem0ai/mem0` **59,093★ / pushedAt 2026-06-22**(当天,Apache-2.0,YC + $24M A 轮 2025-10)。`add()` 抽取 facts/preferences 存向量库+KV+图;`search()` 经 relevance/importance/recency 打分。2026 出 mem0-plugin(9 个 MCP tool:add/search/get/update/delete_memory)接 Claude Code/Cursor/Codex。
- source: https://github.com/mem0ai/mem0 (gh verified 2026-06-22) + https://mem0.ai/blog/state-of-ai-agent-memory-2026
- ⚠️ benchmark 战争:mem0 自报 LoCoMo 92.5 / LongMemEval 94.4;但 Zep 反驳 mem0 论文「错误实现了 Zep」,独立测试 LongMemEval 上 Zep 63.8% vs mem0 49.0%(GPT-4o,差 14.8pt)。**厂商各测各的数据集,无干净 head-to-head**。对磊哥的含义:mem0 是「会话事实抽取」(记用户说了什么),不是「记代码决策/契约 SSOT」——与磊哥需求(记 D1-D37 决策、契约血缘)不同维度。date: 2026(Zep rebuttal,blog.getzep.com)

### F3 — Zep-Graphiti:27.7k★ 双时序知识图,「事实有效性窗口」直接对应磊哥 §35「旧决策不删」痛点
- `getzep/graphiti` **27,704★ / pushedAt 2026-06-20**(2 天,极活跃)。核心=context graph:每条 fact 有 validity window(t_valid/t_invalid),新知识与旧知识冲突时**用时序元数据 invalidate 而非删除**,保留历史。arXiv 2501.13956,DMR benchmark 94.8% > MemGPT 93.4%。
- source: https://github.com/getzep/graphiti (gh verified 2026-06-22) + https://arxiv.org/abs/2501.13956 (date 2025-01)
- 💡 对磊哥最有启发的「概念」非「工具」:Graphiti 的 **bi-temporal invalidate-not-delete** 正是磊哥 claim-vs-reality-gap §35「重大决策推翻旧内容要级联改旧内容(非加脚注)」的工程化身——「Kendra loves Adidas (as of March 2026)」= 决策带时间戳 + supersede 标记。但全图基础设施(Neo4j/FalkorDB)对 solo demo 太重,adopt 概念 drop 实现。date: 2026

### F4 — Letta(MemGPT):23.4k★ OS 式三层内存(core/recall/archival),架构最独特但「agent 跑在 Letta 里」太重
- `letta-ai/letta` **23,449★ / pushedAt 2026-05-14**(39 天,活跃)。把 LLM context 当虚拟内存:Core Memory(在 context 窗口=RAM,agent 直接读写)/ Recall Memory(对话历史=disk cache)/ Archival Memory(冷存储,tool call 查)。$10M 种子 @ $70M post,Jeff Dean/Clem Delangue 背书。
- source: https://github.com/letta-ai/letta (gh verified 2026-06-22) + https://www.letta.com/
- ⚠️ 「agents 不是用 Letta 存记忆,而是**跑在 Letta runtime 里**」——这是整套 agent OS,与 Claude Code harness 冲突(磊哥要的是给 CC 加记忆,不是换 runtime)。drop 工具,但「core/recall/archival 三层分级」概念可借鉴(= 磊哥 MEMORY.md 指针[core] + .md 文件[recall] + raw 一手档[archival] 已天然三层)。date: 2026

### F5 — 🔑 Mneme:把 ADR 编译成「确定性 pre-generation 检查」——直击磊哥「纪律=声称层」真漏点
- `TheoV823/mneme` **14★ / pushedAt 2026-06-18**(3 天,极新但 star 低 = 存疑,概念却精准命中)。机制:「Mneme HQ 把 ADR markdown 编译成 **deterministic active constraint set**,ADR 是事实源,compiler 是把它转成 runtime 注入约束的确定性规则」。可直接 query:对「should I add postgres?」打分。定位=「ADR enforcement for AI coding agents——把 ADR 变成 Claude Code/Cursor/Copilot 的确定性 pre-generation 检查」。
- source: https://github.com/TheoV823/mneme (gh verified 2026-06-22) + WebSearch 2026-06-22
- 💡 这是 lens-2 对磊哥**最对症**的发现:磊哥的 claim-vs-reality-gap.md(10 实证 cite-verify 纪律)现在是 **always-on rule = 声称层**(max effort 仍犯第 10 坑)。Mneme 范式 = 把这条纪律从「prose 声称」编译成「pre-generation 确定性门」,完全同构 claim-vs-reality-gap **铁律 1「enforce 不 declare + 单一 SSOT compiler 派生」**。⚠️ star=14 不能直接 adopt 工具,但**adopt 它的范式**(SSOT→compiler→确定性门)。date: 2026

### F6 — Claude Agent SDK 官方 memory tool + context editing:39% 提升,「view memory before acting」是确定性 gate
- 官方 memory tool(随 Sonnet 4.5 出,2025 末)= 文件目录式持久存储,client-side(磊哥控存哪 + ZDR 合规)。核心范式 = **just-in-time retrieval**(不预载全部,按需拉)+ 推荐 memory protocol:「**always view your memory directory before doing anything else**」。memory + context editing 组合在 Anthropic 内部 agentic search 评测 **+39%**。
- source: https://platform.claude.com/docs/en/agents-and-tools/tool-use/memory-tool + https://www.anthropic.com/news/claude-sonnet-4-5 (date 2025 末,2026 持续更新)
- 💡 三层心智模型(active context[当前任务] / scratchpad[本 session 草稿] / memory tool[跨 session 持久])= 磊哥已有结构。关键 actionable:「view memory before acting」是**确定性 gate**,可用 PreToolUse hook 强制(见 F7),把磊哥起手「先读 MEMORY.md」从靠自觉变成 hook 拦。⚠️ AutoDream(背景记忆整理)经搜证 **非官方确认**(见 PT2)。date: 2026

### F7 — PreToolUse hook exit-2 = 把「grep-before-claim」从自觉提升到硬拦(磊哥 enforce 层缺口)
- Claude Code PreToolUse hook 在 tool 执行前跑,**exit code 2 阻断**(exit 1 只 warn 不拦——最常见静默失守:validator 用 sys.exit(1) 看着拦实际没拦;未捕获异常默认 exit 1 = 危险命令静默放过)。或 exit 0 + JSON `permissionDecision: "deny"`。**hook 对 subagent 同样 fire**(子 agent 不绕过安全门)。
- source: https://code.claude.com/docs/en/hooks + https://www.morphllm.com/claude-code-hooks (date 2026) + https://github.com/anthropics/claude-code/issues/24327
- 💡 对磊哥真漏点的直接修法:claim-vs-reality-gap 的「写重大数字/SSOT 前先 grep 一手代码」现在靠 rule 自觉。可写 PreToolUse hook:当 StructuredOutput/Write 含「SSOT/契约/配方」类断言但本 session 无对应 grep/Read 记录 → exit 2 拦,反馈「先 cite-verify file:line」。⚠️ 已知 bug #24327:新模型对 exit-2 block 有时会 idle 等用户而非 fix-retry,enforce 流要测。date: 2026

### F8 — basic-memory / engram / obsidian-mind:本地 markdown + SQLite MCP,「grounded 非 extracted」是关键分野
- `basicmachines-co/basic-memory` **3,272★ / pushedAt 2026-06-14**(7 天,活跃):标准 markdown 文件 + 本地 SQLite 索引,人和 AI 双向读写同一文件,FastMCP 3.0 工具带行为 hint(readOnly/destructive/idempotent)。`breferrari/obsidian-mind` **3,061★ / 19 天**:Obsidian vault 给 CC/Codex/Gemini 持久记忆,语义召回(「what did we decide about caching」即使笔记标题是「Redis Migration ADR」)。`Gentleman-Programming/engram`:Go 单二进制 + SQLite+FTS5,MCP/HTTP/CLI/TUI,**agent 主动 mem_save 重要内容(非 firehose 原始 tool 流)**。
- source: https://github.com/basicmachines-co/basic-memory + https://github.com/breferrari/obsidian-mind + https://github.com/Gentleman-Programming/engram (gh verified 2026-06-22)
- 💡 关键分野(enquire-mcp 点破):「conversation-memory 工具(mem0/Zep/Supermemory)从 chat log **抽取** facts 进你读不到的独立 store;而 markdown 派是 **grounded** 在你已写的知识里,带 citation,可审计可编辑」。**磊哥的 docs/ + MEMORY.md + handoff 就是 grounded 派**——比抽取派(claude-mem 自动压缩进 SQLite/chroma 你不直接读)**可审计性更强**。engram 的「agent 主动存重要内容非 firehose」也正是磊哥手写 handoff 的哲学。date: 2026

### F9 — 2026 学术/工程共识恰好 = 磊哥现有配方:「MEMORY.md 短 + link out + decision-ready handoff」
- 「**keep MEMORY.md short, link out to details, and put decision-ready summaries in handoffs. Raw transcript dumps, tool logs, and long recall feeds belong in searchable storage, not automatically in the active prompt**」——这是 2026 多 agent 协作共识(arXiv preprint:longer visible history 在 28 个 model-game 中 18 个降低 cooperation)。
- source: https://niteagent.com/blog/multi-agent-production-2026/ + arXiv LLM-agent cooperation (date 2026)
- 💡 这条**逐字对应**磊哥 MEMORY.md「一行一指针,内容在各 .md」+ handoff「重点写下次从哪继续,不写流水账」+ token-hygiene「raw 不入 prompt」。**磊哥已有 = 业界 best practice,不需 adopt 新工具改这部分**。date: 2026

### F10 — 「reversible vs lossy」compaction 决策框架 + context isolation 避免 compaction
- 优先级:raw context → reversible compaction(丢的内容还在别处,可 tool call 取回)→ **lossy summarization 仅最后手段**(丢的永久销毁)。staged compaction:先 mask 无用字段/prune 旧 turn,lossy 兜底。**最强解 = 架构上避免 compaction**:context isolation 每 agent 拥有自己 context,经压缩摘要通信(Anthropic「Share memory by communicating, don't communicate by sharing memory」)。Sourcegraph Amp 一度完全砍 compaction 改 spawn 新 agent 带结构化 task summary。
- source: https://www.morphllm.com/compaction-vs-summarization + https://dev.to/crabtalk/context-compaction-in-agent-frameworks-4ckk + https://www.philschmid.de/context-engineering-part-2 (date 2026)
- 💡 「behavioral constraints(process norms 如『split commands into separate tool calls』)是 compaction 最易丢的」——直接解释磊哥「max effort 仍犯第 10 坑」:**纪律藏在 conversation history 行为模式里,一旦 compact 就丢**。修法 = 纪律必须 re-inject every turn(rule always-on 已做)+ enforce hook(F7,compact 不丢 hook)。date: 2026

### F11 — sub-agent isolation:isolation(非 parallelism)才是真价值,但 token 4-7x 代价
- subagent 各自 200K isolated context,中间噪声留子 agent,只回 signal 给 parent。「isolation 防 context rot——not parallelism, not specialisation」是真价值。但 Anthropic 文档:多 agent 4-7x token,Agent Teams ~15x。gotcha:subagent 不继承 parent skill(startup 全量注入)、cd 不持久、每次 fresh instance(memory 靠 frontmatter opt-in)。
- source: https://claude-world.com/tutorials/s04-subagents-and-context-isolation/ + https://code.claude.com/docs/en/sub-agents (date 2026)
- 💡 对磊哥含义:ultracode-7lens 派 finder subagent 本身就是 isolation 用法(每路噪声留子 agent,只回结构化 schema)——磊哥已对。Agent Teams(15x)对 solo demo 太贵,drop。date: 2026

---

## pre-mortem(tiger / paper-tiger / elephant)

### 🐯 tiger(真威胁,带验证清单)
- **T1 — claude-mem 自动压缩对 artifact tracking 弱(2.19-2.45/5.0),可能给磊哥假记忆**。claude-mem 已装(83.6k★),若磊哥误以为「装了 claude-mem = 失忆已解」,而它对「改了哪些文件/契约 SSOT 在哪」恰恰是弱项 → 假安全。**验证清单**:① 跑一个长 session 后新开 session,问 claude-mem 注入的 context 里「上次改的关键文件路径」是否准确(对照 git log);② 对比同内容磊哥手写 handoff 的「相关文件 ≤5」准确率。预期:手写 handoff 准,claude-mem 压缩有损。
- **T2 — PreToolUse exit-2 enforce 有 #24327 idle bug**。若磊哥按 F7 写「grep-before-claim」硬门,新模型可能 block 后 idle 等用户而非自动 fix-retry → 打断 write-test-fix 内循环。**验证清单**:新 CC session 实测一个 PreToolUse exit-2 hook,看 block 后 Claude 是 fix-retry 还是 idle;若 idle,改用 exit 0 + JSON deny(语义不同,模型不当「权限拒绝」处理)。
- **T3 — markdown 记忆派的语义召回靠向量/嵌入,可能漏召回**。basic-memory/obsidian-mind 的「语义搜索」对「未明说的隐含决策」召回率未验证;若 adopt 替代 MEMORY.md 指针,可能不如确定性指针「问 X → 看 X.md」可靠。**验证清单**:对磊哥 docs/ 跑一次语义 query(如「C5 LoRA masking 怎么决策的」),看是否召回 p1c-grill-decisions.md;对照 MEMORY.md 直接指针命中率。

### 🦓 paper-tiger(看似威胁实际安全,给证据)
- **PT1 — 「磊哥没有专业记忆系统会持续失忆」= 假**。证据:F9 学术/工程 2026 共识(「MEMORY.md short + link out + decision-ready handoff」)**逐字等于磊哥现有配方**;F8「grounded 非 extracted」证明磊哥手写 docs/handoff 比抽取派可审计性更强。磊哥不缺记忆系统,缺 enforce 层。安全。
- **PT2 — 「AutoDream 自动整理记忆能解 drift」= 不可依赖(未官方确认)**。证据:多源搜证(claudefast/mindstudio/businessinsider)一致承认 AutoDream「未官方发布/leaked/research preview only」,无 Anthropic 官方源;community 用 `grandamenium/dream-skill`(94★,pushedAt 2026-03-24 = **89 天前,已 stale**)替代。**不能把 drift 修复押在未确认的官方功能上**;drift 要靠 §35 级联纪律 + 可选 Mneme 式 compiler。date: 2026-06-22
- **PT3 — 「fresh-agent handoff 优于 compaction,磊哥该上 handoff 机械」= 业界非定论**。证据:Sourcegraph Amp 走过 compaction(原始)→ Handoff(2025-11)→ **回退 compaction**(2026,「Handoff is gone, compaction made it obsolete」)的弯路。证明「多小线程 handoff」复杂度不值。磊哥 handoff 六件套是给**人/新 session 读的决策摘要**(对的),不是要替代平台 compaction 的机械——这个边界清楚就安全,别过度加 handoff 自动化。date: 2026

### 🐘 elephant(没人提但该提)
- **E1 — 验证器/检测器若读同一份记忆做判断 = 循环失守(claim-vs-reality §35🔴变体在记忆层重演)**。若磊哥给 claude-mem/MEMORY.md 加「记忆一致性检测器」,而检测器读的是同一份可能已 drift 的 MEMORY.md → 被同一个 drift 蒙蔽报绿灯。**enforce 必须用一手源**(grep 实际代码/git log 对账),不能用记忆派生物自检记忆。这是 lens-2 里最隐蔽、外部文章都没提的坑。
- **E2 — 记忆「召回 ≠ 应用」:CC 会『想起』一条原文没有的决策(§31 信号 C)**。所有外部记忆工具解决的是「存得住/取得回」,但磊哥实证的盲点是**调用记忆时张冠李戴**(凭印象引错沉淀,第 17 题凭记忆引错 own memory)。再强的记忆工具也不防这个——修法是「调用判断/frame 层记忆时回读原文核出处」(已在 §31),工具层无解,纪律层兜。外部生态完全没 cover 这个维度。
- **E3 — 端侧/离线约束下,云记忆服务(mem0/Zep cloud)全部不适用**。磊哥 MAformac 北极星=纯端侧离线;mem0/Zep/engram.so 的 hosted 版、向量 DB 云依赖全部违背。但这是 MAformac **项目**约束,不是磊哥 **harness**(开发环境)约束——harness 层可用云记忆。**别把项目离线红线溢出到 harness 选型**(claim-vs-reality §31 信号 B:强约束套错范畴)。这个范畴区分没人提。

---

## vs 当前 harness(adopt 更强 / 磊哥已有更好 / 真漏点)

### 磊哥已有更好(别动)
- **MEMORY.md 一行一指针 + 内容在各 .md** = F9 学术/工程 2026 共识逐字命中(「short + link out」),且 F8「grounded 非 extracted」证明手写 docs 比 claude-mem 抽取派**可审计性更强**。**不需用 mem0/basic-memory 替换这部分**。
- **handoff 六件套(下次从哪继续 + 相关文件 ≤5 + 决策摘要)** = 2026 structured handoff contract(objective/output format/guidance)的人类版,且比 claude-mem 自动压缩对 artifact tracking 更准(T1)。PT3 还证明别过度加 handoff 机械(Amp 回退教训)。
- **ultracode-7lens 派 finder subagent** = F11 sub-agent isolation 正解(噪声留子 agent,只回结构化 schema),磊哥已对。
- **SessionStart hook 注入最近 handoff** = F6「view memory before acting」确定性 gate 的现有实装,方向对。

### adopt 更强(外部确实更强,值得吸收)
- **Mneme 范式(F5):SSOT→compiler→确定性 pre-generation 门**。⚠️ 工具 star=14 不直接 adopt,但**adopt 范式**——把 claim-vs-reality-gap.md(现 prose rule)的关键纪律编译成 PreToolUse 确定性检查。这是磊哥真漏点的最对症外部范式。
- **PreToolUse exit-2 硬门(F7)**:把「grep-before-claim / cite-verify」从 always-on rule(自觉)提升到 hook 拦截(确定性)。注意 exit 2 vs exit 0+JSON deny 的 #24327 idle bug(T2)。
- **Graphiti bi-temporal invalidate-not-delete 概念(F3)**:决策带 t_valid/t_invalid + supersede 标记,工程化磊哥 §35「推翻旧决策级联改旧内容」。drop 全图基础设施,adopt 概念到 grill-decisions.md 的决策记法。

### 真漏点(磊哥 harness 现在没有,该补)
- **🔴 漏点 1 — enforce 层缺失**:claim-vs-reality-gap 全部是 always-on rule(声称层),max effort 仍犯第 10 坑。补 = PreToolUse hook 把「写 SSOT/契约/配方断言前必有本 session grep 记录」做成确定性门(F7 + Mneme 范式 F5)。这是 lens-2 核心结论:**磊哥不缺记忆,缺 enforce**。
- **🟡 漏点 2 — MEMORY.md drift 无机制清理**:矛盾累积/旧决策不删(§35 失守机制),现靠磊哥手动 + 纪律。补 = ① 不依赖未确认的 AutoDream(PT2);② 起手扣「MEMORY.md audit at transition」(F2 best practice)或写 Stop hook 跑 drift 检测(但 E1:检测器不能读同一份记忆自检,必须 grep 一手源对账)。
- **🟡 漏点 3 — 「view memory before acting」非确定性**:磊哥起手「先读 MEMORY.md」是 rule 自觉,可被 goal-focused 跳过。补 = SessionStart 已注 handoff(对),再加 UserPromptSubmit hook 在重大动作前注「本 session 已 cite-verify 了吗」温和提示(plain stdout,不 block,符合 hooks.md Stop/SubagentStop 铁律)。

---

## adopt-adapt-drop

### ADOPT(直接吸收范式/机制)
- **Mneme 范式**:claim-vs-reality-gap 关键纪律 → 单一 SSOT → compiler 派生 → PreToolUse 确定性门(铁律 1 项目实装)。source: github.com/TheoV823/mneme
- **PreToolUse exit-2 硬门**:把 grep-before-claim/cite-verify 从声称层提到 enforce 层。source: code.claude.com/docs/en/hooks
- **「reversible > lossy compaction」决策框架**:挂进 working memory,优先 raw → reversible → lossy 兜底。source: morphllm.com/compaction-vs-summarization

### ADAPT(改造后用,不照搬)
- **Graphiti bi-temporal**:adapt 成 grill-decisions.md 决策记法(决策带日期 + supersede 标记),drop 全图基础设施。source: github.com/getzep/graphiti
- **Claude 官方 memory tool「view before acting」**:adapt 成 SessionStart(已有)+ UserPromptSubmit 温和 cite-verify 提示(plain stdout 不 block)。source: platform.claude.com memory-tool
- **engram「agent 主动存重要内容非 firehose」**:adapt 成 handoff 哲学的强化(手写决策摘要 > 自动压缩 tool 流),磊哥已天然在做。source: github.com/Gentleman-Programming/engram

### DROP(不适用,真不适用非降级)
- **mem0 / Zep cloud / Letta runtime / Agent Teams**:① mem0/Zep 是「会话事实抽取」非「代码决策/契约 SSOT」(维度不符);② Letta 要换 runtime(冲突 CC harness);③ Agent Teams 15x token(solo demo 太贵);④ 云依赖违 MAformac 端侧离线(但仅 MAformac 项目层,E3:别溢出到 harness)。
- **AutoDream / dream-skill**:未官方确认(PT2)+ dream-skill 89 天 stale,不可依赖,drop。
- **claude-mem 替代 handoff**:已装可留作补充,但**不替代手写 handoff**(T1:自动压缩对 artifact tracking 弱)。drop「用 claude-mem 取代 handoff 六件套」的念头。
- **basic-memory/obsidian-mind 替代 MEMORY.md 指针**:磊哥确定性指针(问 X→看 X.md)对已知决策比语义召回更可靠(T3),drop 替换;可在「大量未结构化笔记需语义找」时作补充。

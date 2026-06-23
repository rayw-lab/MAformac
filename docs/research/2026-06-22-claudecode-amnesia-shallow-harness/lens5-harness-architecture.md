# Lens-5：主流 agent harness 怎么解 context persistence + forced code-grounding（框架 + 代码链路对比）

> finder lens-5（2026-06-22）。任务=对比主流 agent harness（Claude Agent SDK / LangGraph / Mastra / Pi / OpenHands / Cursor / aider / Letta / claude-mem / grounded）在**两个轴**上的架构选择——① context persistence（跨 session/窗口不失忆）② forced code-grounding（强制 agent 读一手代码、不凭派生物/印象推）——然后映射回磊哥当前 harness（rules + memory + handoff + hooks）的定位：强在哪、漏在哪。
> 方法：13 次 WebSearch + 1 次 WebFetch（grounded 源码） + clone 深扒 pi（compaction.ts/handoff.ts/memory-storage.ts）+ mastra（working-memory.ts）读 file:line。每条带 source URL/date + 行号锚点。

---

## summary

主流 harness 对**两个轴**已分化出清晰的架构家族，对照磊哥三痛点（失忆 / max effort 仍浅思考 / 不深入代码）能精确定位：

**轴① context persistence（解失忆）= 三层架构已成行业共识**：(a) **会话内 checkpointer**（thread-scoped，自动，对开发者透明）；(b) **跨会话 store**（resource/user-scoped，显式读写）；(c) **lossy compaction → structured summary**（窗口满时压缩，但保留文件路径/函数名/error）。磊哥的 `MEMORY.md` 指针 + `docs/handoffs/` 六件套 ≈ 手动版 (b)+(c)，**架构形态对，但靠"自觉触发"而非 harness 强制**——这正是第10坑暴露的声称层缺陷。

**轴② forced code-grounding（解"不深入代码/凭派生物推"）= 行业有现成的 harness 级强制层，但磊哥还没装**。最直接命中的是 `grounded`（Pinperepette）——用 **PreToolUse `edit-guard`（read-before-edit + old_string 对账实文件）+ PostToolUse `truth-layer`（grep 返回空立即注入"你 MUST NOT 引用此 identifier"）+ Stop `confidence-check`（response 里的 identifier 全部 `rg` 复核，没找到就 block 强制改）**，把"grep-before-claim"从声称层降到 exit-code 拦截层。这正是磊哥 `claim-vs-reality-gap.md` 想要、但目前只写在 rule（always-on 但 max 仍犯）的纪律的**机器强制版**。

**核心元发现（跨所有 harness 一致）**：行业已用血泪证明"**rule/CLAUDE.md = wish list 不是 contract**"（ETH Zurich 138-repo 实证 + grounded 哲学 + HumanLayer <60 行），凡是"单次违反就损失大/丢数据"的纪律，**必须 hook 强制不能靠 prompt**。磊哥 harness 的 rules 层做得比所有人都厚（10 实证 cite-verify 纪律），但厚 rule 本身就是 ETH Zurich 证伪的方向——**真正的护城河应该是把 top-3 纪律（grep-before-claim / read-before-claim-config / handoff-on-close）下沉到 hook**，而不是再加一条 rule。

---

## key findings（每条带 source URL + date）

### A. context persistence 架构家族

**[F1] LangGraph：双层 checkpointer + store，是"会话内 vs 跨会话"分工的最清晰范式**（2026）
- checkpointer = 会话内（thread-scoped），**对开发者/用户不可见，compile 时 `checkpointer=` 自动接管**；store = 跨会话（user-scoped），**必须在 node 里显式 read/write**。"That asymmetry, automatic vs coded, is deliberate: conversation history is structural while long-term memory is a product decision."
- 关键工程：thread_id 做 namespace 隔离不同用户/任务；time-travel/forking 靠 checkpoint_id；大文件不进 state（存外部只存 URL，否则每 super-step 复制一份炸库）。
- source: https://fast.io/resources/langgraph-persistence/ ; https://www.abstractalgorithms.dev/langgraph-memory-and-state-persistence （2026）
- **vs 磊哥**：磊哥的 MEMORY.md = 跨会话 store（"coded"层，手写指针），但**没有 checkpointer 层**——会话内全靠平台 auto-compact。磊哥的 store 比 LangGraph 更语义化（指针 + 一手 .md），但**写入靠自觉（session-closure rule）不是 node 强制**。

**[F2] Letta/MemGPT：三层"LLM-as-OS"内存 + self-editing tool，memory 是 agent 自己用 tool 改的**（pushedAt 2026-05-14, ⭐23449）
- 三层=core memory（always in-context，像 RAM）/ recall（会话历史，像 disk cache）/ archival（向量库，像冷存储）。agent 用 `memory_insert`/`memory_replace`/`memory_rethink` tool 自编辑 core memory。
- 2026 新增 "sleep-time compute"：无 user 输入时 agent 跑反射 pass，consolidate archival / 重写乱掉的 human block。
- **致命权衡（直接关联磊哥痛点）**："memory quality depends entirely on the model's judgment. If the model fails to save something, it's gone." —— self-edit 内存把"记什么"交给模型判断，**这正是磊哥失忆的同根**（负载下模型不主动写）。Letta 的解法是把它做成 tool（模型至少有显式动作），但仍不是强制。
- source: https://docs.letta.com/guides/legacy/memgpt_agents_legacy ; https://sureprompts.com/blog/letta-memgpt-walkthrough （2026）
- **vs 磊哥**：磊哥 MEMORY.md ≈ Letta 的 core memory + archival 混合（指针在 core，一手 .md 在 archival）。Letta 强在"self-edit tool + sleep-time 反射"——磊哥的 `/absorb`、`learn-eval`、session-closure 是同一意图，但**没有"idle 时自动反射"的 heartbeat**（全靠收工触发）。

**[F3] OpenHands：condenser（lossy 摘要）+ 持久 EventLog（无损 replay）双轨，让会话无限超窗**（pushedAt 2026-06-21, ⭐77970）
- condenser 把旧 event 替换成摘要（encode goal/progress/todo + critical files + failing tests），但配 persistent EventLog → "full replay even after compression"。这是 lossy 压缩 + 无损源 的经典分离。
- microagents：`.openhands/microagents/repo.md`（无 frontmatter = always-loaded；有 trigger = 命中关键词才加载）承载 repo 知识；"Applying front-loaded prompts directly for each conversation without the summary proved to be infeasible for large repositories."
- source: https://docs.openhands.dev/sdk/guides/context-condenser ; arXiv https://arxiv.org/html/2511.03690v1 （2025-11）
- **vs 磊哥**：磊哥的 compaction 全靠平台 auto-compact（lossy），**没有独立的无损 EventLog**——压缩后丢的料只能靠 handoff/memory 落盘兜底（手动）。OpenHands 的 EventLog = 自动无损源，磊哥缺这层（但磊哥的 docs/handoffs/ + git 历史是替代）。microagents 的 trigger-load = 磊哥 skill 的 description-trigger 同构。

**[F4] Pi（earendil）：session = 树状 append-only EventLog；compaction 跨摘要保留 read/modified 文件列表**（clone 深扒，pushedAt 2026-06-20 区间）
- 🔑 **session storage = typed entry 的 DAG**（`SessionTreeEntry` 带 parentId，`getPathToRoot` 逐 parent 回溯）→ `memory-storage.ts:113-126`。即 OpenHands EventLog 的树版（支持 branch/fork）。
- 🔑 **compaction 把 readFiles/modifiedFiles 当一等公民穿过摘要**：`extractFileOperations` 从 prev compaction 的 `details.readFiles/modifiedFiles` 继承 + 从新消息提取 → `compaction.ts:42-65, 596-601, 703-711`。摘要 prompt 硬要求 "Preserve exact file paths, function names, and error messages"（`compaction.ts:420, 459`）。
- **直接命中磊哥"压缩后丢 code-grounding"痛点**：Pi 用代码保证"压缩可以糊掉对话，但绝不糊掉碰过哪些文件"。
- source: `~/workspace/raw/05-Projects/MAformac/ref-repos/pi/packages/agent/src/harness/compaction/compaction.ts` + `.../session/memory-storage.ts`（本机 clone, 2026-06-20）
- **vs 磊哥**：磊哥的 auto-compact 是平台黑盒，**不保证保留 file-list**——这是真漏点。Pi 的"file-ops 穿透摘要"是磊哥可 adopt 的具体机制（哪怕只在 handoff 模板里强制"碰过的文件清单"段）。

**[F5] Pi handoff 扩展：显式"compaction is lossy → handoff 抽取关键 + 生成自包含 prompt + 开 parent-tracked 新 session"**（clone, handoff.ts）
- 注释直言哲学："Instead of compacting (which is lossy), handoff extracts what matters for your next task and creates a new session with a generated prompt." → `handoff.ts:1-13`
- 机制：LLM 读当前 branch（含 compaction summary + firstKeptEntry 之后的 entry）→ 生成含 `## Context`（决策）+ `Files involved`（文件清单）+ `## Task` 的 prompt → 用户可编辑 → `newSession({ parentSession })` 带父链 → `handoff.ts:20-40, 102, 175-184`。
- source: `.../ref-repos/pi/packages/coding-agent/examples/extensions/handoff.ts`（本机 clone, 2026-06-20）
- **vs 磊哥**：这就是磊哥 `docs/handoffs/` 六件套 + "下次 session prompt" 的 **harness-native 版（一个 `/handoff` slash command 直接生成 + 开新 session）**。磊哥的 handoff 是 rule 驱动（session-closure rule + Stop hook 检测今日 handoff），Pi 是命令驱动（用户主动 `/handoff <goal>`）。两者互补：磊哥的"Stop hook block 未写 handoff"是 Pi 没有的强制；Pi 的"一键生成 + 开新 session 带父链"是磊哥手动拼 prompt 的自动化。

**[F6] Mastra：working memory（self-edit markdown/schema）+ semantic recall + thread/resource 双 scope + Observational Memory**（pushedAt 2026-06-22, ⭐25316）
- working memory = agent 调 `updateWorkingMemory` tool 自编辑（markdown = replace 语义全量重写 / schema = merge 语义只给变更字段，`deepMergeWorkingMemory` 实现 → `working-memory.ts:21-68`）。
- 🔑 **`readOnly: true` 模式**：内存只注入不给 tool——"useful for routing agents that need context but shouldn't update user profiles, or sub agents that should reference but not own the memory." 这是"读写分离"的精细控制。
- 🔑 **`setWorkingMemory` 改名 trick**：默认 `updateMessageToHideWorkingMemoryV2` 会把 self-edit tool-call 从历史 strip 掉（防污染），但新路径改名 `setWorkingMemory` 让 strip filter 不动它 → **保留为 audit trail**（`working-memory.ts:11-12`）。
- mutex 串行化 working memory 更新防并发 corruption。Observational Memory（2026 推荐）= 后台 agent 维护 dense observation log 替换 raw 历史。
- source: https://mastra.ai/docs/memory/working-memory ; https://deepwiki.com/mastra-ai/mastra/7-memory-and-storage-architecture ; 本机 clone `working-memory.ts`（2026-06-20）
- **vs 磊哥**：磊哥 MEMORY.md 是 markdown working memory 的手动版（replace 语义），但**没有 self-edit tool**（靠 CC 主线程自己 Edit + session-closure rule 触发）。Mastra 的 `readOnly` + `audit-trail` 精度磊哥没有；但磊哥的"指针 + 一手 .md 分层"比 Mastra 的扁平 markdown 更抗失忆（一手源不丢）。

**[F7] claude-mem：5 hook（SessionStart 注入 / UserPromptSubmit 记意图 / PostToolUse 记结果 / Stop 压缩）+ 异步 worker 解"hook 要快但压缩慢"矛盾**（pushedAt 2026-06-21, ⭐83648 — 全场最高）
- 核心矛盾："hooks must be fast (under 1 second), but AI compression takes 5-30 seconds" → 解法 = hook 只 enqueue（<10ms），常驻 worker（port 37777）异步压缩。
- SessionStart **静默注入** via `hookSpecificOutput.additionalContext`（查 SQLite 最近 10 session summary + 50 observation），progressive disclosure（先给 title/metadata index，promising ID 再展开）= "10x token savings"。
- 哲学："observes from the outside, doesn't modify Claude Code's behavior"。
- source: https://docs.claude-mem.ai/hooks-architecture ; https://github.com/thedotmack/claude-mem （2026-06-21）
- **vs 磊哥**：claude-mem 是磊哥 hooks 拓扑里**已经在跑的 Stop(claude-mem summarize)**（见磊哥 settings.json）。但磊哥的 SessionStart 注入是"最近 3 个 handoff"（手写文件），claude-mem 是"自动捕获的 observation 压缩"——两者可叠加：磊哥的 handoff = 高信号人工策展，claude-mem = 低信号自动兜底。**磊哥已 adopt 这条**，是强项不是漏点。

### B. forced code-grounding 架构家族

**[F8] grounded：把"grep-before-claim / read-before-edit / 反幻觉"做成 PreToolUse+PostToolUse+Stop 三段 hook 强制**（pushedAt 2026-04-25, ⭐27 — star 低但机制最精准命中）
- 🔴 **四层 hook 拆解**（WebFetch 源码确认）：
  - **UserPromptSubmit**：`pre-flight` 检测意图（edit/create/debug/find）+ identifier，注入"required tool sequence"（如必须 Grep 验证存在 → Read → 才能 Edit，"edits without prior Read will be blocked"）。
  - **PostToolUse**：`truth-layer`（Grep 返 0 结果 → 立即注入"you MUST NOT reference"该 identifier，**抢在 Claude 在幻觉 identifier 上建推理之前**）；`read-tracker`（记 read/tool 序列）；`loop-detector`（重复同 tool call 检测）。
  - **PreToolUse**：`edit-guard`（read-before-edit 门 + **校验 old_string 对实文件内容**，不符 → "EDIT BLOCKED: old_string does not match actual file content"）；`anti-bypass`（拦截引用已确认 not-found identifier 的 tool 输入）。
  - **Stop**：`confidence-check`（从 response 文本抽 claimed identifier，**逐个 `rg` 并行复核**，全找到才放行，任一 NOT FOUND 就 block 强制改）。
- 🔴 **哲学（直接对应磊哥第10坑根因）**："the problem isn't the model—it's that we trust it too much. LLMs are probabilistic. Your codebase is not. grounded assumes the model is wrong — and verifies everything." + "This doesn't make Claude smarter. It makes it behave correctly... even smaller / local models become usable."
- 🔴 **为何 hook 不 CLAUDE.md**："a PreToolUse hook always runs, returns an exit code, and blocks; a CLAUDE.md instruction is parsed by an LLM and weighed against other context—maybe followed."
- source: https://github.com/Pinperepette/grounded （pushedAt 2026-04-25）+ WebFetch 源码
- **vs 磊哥**：**这是全调研最直接命中磊哥痛点②③的现成方案**。磊哥的 `claim-vs-reality-gap.md` 铁律3"诊断往最细粒度钻"+ pre-mortem"grep-before-claim" = grounded 的 `confidence-check`/`truth-layer` 的**纯声称层版本**（always-on rule 但 max effort 仍犯第10坑）。grounded 把它降到 exit-code。**真漏点 = 磊哥没有 Stop `confidence-check`（response identifier 复核）和 PostToolUse `truth-layer`（grep 空注入）。**

**[F9] aider repo map：tree-sitter AST + PageRank 符号图，给模型"骨架"让它知道去哪读深**（pushedAt 2026-05-22, ⭐46552, 15B tokens/week）
- 管线：tree-sitter 解析 130+ 语言 → 抽 `name.definition.*`/`name.reference.*` tag → PageRank 按"被引用频次"排符号 → token-budget（默认 1k）截断 → tree 格式注入。SQLite 缓存按 mtime keyed。
- 关键："The map gives the model enough of a skeleton to either solve tasks directly or know where to look deeper... if it needs to see more code, the LLM can use the map to figure out which files it needs to look at."
- source: https://aider.chat/2023/10/22/repomap.html ; https://deepwiki.com/Aider-AI/aider/4.1-repository-mapping-system ; https://aider.chat/docs/repomap.html （2023-10 起，2026-05 仍维护）
- **vs 磊哥**：aider 是"被动 grounding"（每轮自动喂 repo skeleton，模型不会"忘了有这个文件"）。磊哥靠 CC 主线程主动 Grep/Read——**没有自动 repo map 注入**，所以会出现"凭印象推代码工厂方法"（第10坑）。但 MAformac 是小项目（契约 SSOT 单文件），repo map 收益不如 grounded 的 read-before-claim 直接。

**[F10] Cursor：本地 chunk + Merkle tree hash + 自训 embedding（Turbopuffer 向量库）+ grep 混合，语义检索 grounding**（2026, 自训模型 +12.5% QA 准确率）
- 开 repo → 本地 chunk（函数/类，非随意切）→ Merkle hash 同步 server → embedding 存 Turbopuffer → query 时 NN 检索拿 obfuscated path → 本地读实代码喂 LLM。"semantic search + grep 组合 12.5% 高于 grep 单用，1000+ 文件项目收益最大"。
- 隐私：filename obfuscate + chunk 加密，client 端解密。
- source: https://cursor.com/blog/semsearch （2025-11）; https://towardsdatascience.com/how-cursor-actually-indexes-your-codebase/ （2026）
- **vs 磊哥**：Cursor 是重型 RAG grounding（向量库），对 1000+ 文件项目。MAformac 小，**grep（磊哥已有）对小项目 ≈ Cursor 的语义检索**（Cursor 自己也说 grep+semantic 才最优，单 grep 在小项目够用）。磊哥不需要 adopt 向量索引——这是 paper-tiger。

**[F11] Meta semi-formal reasoning：强制 agent "trace 实际 code path"而非"推断行为"，+9pp 准确率**（RubberDuckBench 87% vs 78% 标准 agentic）
- 结构化模板逼 agent 走"state premises → trace which functions actually called → identify divergence → derive conclusion with evidence"，鼓励 interprocedural reasoning（跨文件跟函数调用）。例：标准推理误判两 patch 等价（假设 `format()` 是 Python 内置）；semi-formal trace 后发现是 Django 自定义 `format()` → 正确判不等价。
- source: https://devops.com/meta-researchers-show-ai-agents-can-verify-code-without-running-it-and-hit-93-accuracy/ （2026）
- **vs 磊哥**：这是"思考深度"层（对应痛点②max effort 仍浅）。磊哥的 `claim-vs-reality-gap` 铁律3"按最细 axis 逐行打印 base/lora 数，禁引用整体聚合"≈ semi-formal 的"trace 实际而非聚合推断"。**磊哥的 rule 已有这个意图，但 Meta 证明：结构化模板（强制走步骤）比"提醒要仔细"有效**——可把磊哥铁律3做成一个 `/trace` skill 模板（强制逐 axis 打印），而非靠记忆。

### C. 元层：rule = wish list 不是 contract（跨所有 harness 一致结论）

**[F12] ETH Zurich 138-repo / 5694-PR 实证：LLM 生成的 AGENTS.md 降成功率 ~3% + 涨成本 20-23% + 多走 2.45-3.92 步；人写的也只 +4% 且仍涨 19% 成本**（arXiv 2601.20404, 2026-02-12）
- "monolithic AGENTS.md loads every rule into context on every invocation... irrelevant instructions compete for attention." 建议 <60 行（HumanLayer）/ <200 行（Anthropic）/ 用 linter 替代"用 camelCase"这类规则。
- source: https://arxiv.org/pdf/2601.20404 ; https://www.theregister.com/ai-and-ml/2026/06/17/smelly-config-files-will-make-your-agents-waste-tokens/ （2026-06-17）
- **vs 磊哥**：磊哥的 rules 树极厚（claim-vs-reality 10 实证 + 34 条 checklist + 7-lens…）。**这与 ETH Zurich 方向冲突**——但磊哥的 max20 + 1M context 决策（`rules-vs-skill-loading.md`）明确"token 不是约束，失忆才是风险，always-on > 漏触发"。**所以磊哥不该砍 rules，但 ETH Zurich 给出的真信号是：厚 rule 的边际效用递减，top 纪律应下沉 hook（确定性）而非堆 prose（概率性）。**

**[F13] 行业共识：hooks vs prompts = "I told the agent X" vs "system enforces X"；凡单次违反损失大的纪律必 hook**（HumanLayer / Martin Fowler / Augment, 2026）
- "Hooks and harness logic provide guarantees that prompts cannot." + "if your agent repeatedly fails because a tool returns malformed response, don't fix it in the prompt — write a validator inside the harness." + LangChain middleware 6 hook（before_model/wrap_tool_call/after_model…）做"deterministic policy enforcement that can't be trusted to prompts"。
- 分层 rule 加载（Augment）：always_apply / agent_requested（模型判定相关才加载）/ manual——"selective loading preserves constraint enforcement while keeping context focused"。
- source: https://www.humanlayer.dev/blog/skill-issue-harness-engineering-for-coding-agents ; https://martinfowler.com/articles/harness-engineering.html ; https://www.augmentcode.com/guides/how-to-build-agents-md （2026）
- **vs 磊哥**：磊哥 hooks 拓扑（PostToolUse format/check + Stop claude-mem + SessionStart 注入 handoff）已是行业标准形态，**但缺"grounding 强制 hook"这一类**（grounded 的 truth-layer/confidence-check/edit-guard）。磊哥的护城河应是把 cite-verify 纪律从 rule 升级为 hook。

---

## pre-mortem（tiger / paper-tiger / elephant）

### tiger（真威胁，带验证清单）
- **T1：grounded 直接装上去会与磊哥现有 hooks 拓扑冲突 / 拖慢**。grounded 的 `confidence-check` 是 Stop hook，磊哥 Stop 已有 claude-mem summarize（30-90s）+ session-stop；grounded 的 `edit-guard` 是 PreToolUse，磊哥已警告"Edit hook 取消 Bash"未验证（`parallel-safety.md`）。**验证清单**：① 先在隔离 session 实测 grounded install 后 Stop/PreToolUse 并发数（磊哥拓扑 ≤5 安全线）；② confidence-check 的 `rg` 复核对 1M context 长 response 的延迟；③ 是否与 ECC_DISABLED_HOOKS 打架。**不可直接 `grounded install` 到全局，先项目级试**。
- **T2：self-edit 内存（Letta/Mastra）把"记什么"交给模型判断 = 磊哥失忆同根，adopt 它反而可能加重**。Letta 自己承认"if the model fails to save something, it's gone"。**验证清单**：磊哥的 MEMORY.md 当前是 CC 主线程"自觉 Edit"——若改成 self-edit tool，仍是模型判断，没解决"负载下不主动写"。真解是 hook 强制（Stop 检测今日 memory 更新，像 handoff 那样 block），不是换成 tool。
- **T3：Pi 的"file-ops 穿透 compaction"依赖平台 compaction 可注入逻辑，磊哥用的是平台 auto-compact 黑盒**。磊哥无法在平台 auto-compact 里插"保留 file-list"。**验证清单**：确认磊哥能否在 PreCompact hook 里写 file-list 到 continuation-prompt（但 `hooks.md` 实证 PreCompact 只能 stderr，SessionStart(compact) 才能注入）——所以 Pi 的机制只能 adapt 到"handoff 模板强制文件清单段"，不能直接复制到 auto-compact。

### paper-tiger（看似威胁实则安全，给证据）
- **P1："要 adopt Cursor/aider 的向量索引/repo map 才能解 grounding"——对 MAformac 是过度工程**。证据：Cursor 自己说"semantic search + grep 组合优于 grep，但 1000+ 文件项目收益最大"（[F10]）；MAformac 契约 SSOT 是单文件 jsonl + 小 Swift 项目，grep（磊哥已有）足够。真漏点是"强制去 grep"（grounded），不是"检索更强"（Cursor）。**砍掉向量索引方向**。
- **P2："厚 rules 违反 ETH Zurich，磊哥该砍 rules"——对 max20 用户是误判**。证据：ETH Zurich 测的是"LLM 生成的冗余 AGENTS.md"，磊哥 rules 是人写 + 带 10 实证锚点（非冗余）；且磊哥 `rules-vs-skill-loading.md` 已论证"token 不是约束，always-on > 漏触发"。**不砍 rules，但把 top-3 纪律下沉 hook**（rule 留作 recognition，hook 做 enforcement）。
- **P3："claude-mem 已在跑，失忆应该解了"——claude-mem 是低信号兜底不是高信号策展**。证据：claude-mem 哲学"observes from outside"（[F7]）= 自动捕获所有 observation 压缩，信噪比低；磊哥的 handoff/memory 是人工策展高信号。两者不互斥，但**claude-mem 解不了"磊哥要的关键决策不丢"**——那仍需 handoff hook 强制。

### elephant（没人提但该提）
- **E1：磊哥三痛点的"同根"（负载下抓 recall 成本最低的源）在所有 harness 里都没被根治——因为它是 LLM 本质，不是 harness bug**。所有 harness（Letta self-edit / grounded verify / Pi file-ops）都是"在模型外面加确定性约束"，没有一个声称"让模型自己变得不偷懒"。这反向印证磊哥方向对：**纪律不能靠模型自觉（哪怕 max effort），必须 harness 外部强制**。磊哥唯一的 gap 是"已经认知到（写进 rule）但还没机器化（下沉 hook）"。
- **E2：磊哥 harness 的真正差异化优势没人有——"一手源 .md + 指针分层 + cite-verify 文化 + cross-vendor 审计"**。Letta/Mastra 的 memory 是扁平 markdown/schema，会"summarize 后丢一手料"；磊哥的"MEMORY.md 指针 → 一手 .md（带 source URL + 行号）"是**可溯源的两层**（claim-vs-reality 铁律3 的载体）。**这是磊哥比商业 harness 强的地方**，调研里没有任何 harness 做到"memory 里强制带 source 行号"。漏的不是架构，是"把这层强制掉"（写 memory 时 hook 校验有无 source）。
- **E3：grounded 的"behavior 强制让小模型可用"对 MAformac 端侧 Qwen3-1.7B 是隐藏的二阶价值**。grounded 哲学"enforced behavior → even smaller/local models become usable"（[F8]）——MAformac 端侧跑 1.7B LoRA，**同样的 harness-级 grounding 思路可下沉到端侧 runtime**（如 DemoGuard 强制读回 mock state 再确认，而非信模型说"已执行"）。这与磊哥 `claim-vs-reality-gap` 铁律1"行为是否真发生(非状态字段声称)"同构——端侧也该 enforce 不 declare。

---

## vs 当前 harness（adopt 更强 / 磊哥已有更好 / 真漏点）

| 维度 | 主流 harness 做法 | 磊哥现状 | 判定 |
|---|---|---|---|
| 跨会话 store | LangGraph store / Letta archival / claude-mem SQLite | MEMORY.md 指针 + 一手 .md（带 source 行号） | **磊哥已有更好**（可溯源两层，无 harness 做到 memory 带行号） |
| 会话内 checkpointer | LangGraph 自动 checkpointer | 无独立层，靠平台 auto-compact | 真漏点（但平台兜底，低危） |
| compaction 保 code-grounding | Pi file-ops 穿透摘要 / OpenHands EventLog 无损 | 平台 auto-compact 黑盒，不保证保留 file-list | **真漏点**（adapt：handoff 模板强制"碰过文件"段） |
| handoff 机制 | Pi `/handoff` 一键生成+开新 session 带父链 | docs/handoffs 六件套 + Stop hook block 未写 handoff | 平手互补（磊哥有强制门，Pi 有自动化） |
| self-edit/idle 反射 | Letta sleep-time compute / Mastra Observational | /absorb /learn-eval session-closure（仅收工触发） | adapt（加 idle 反射意图，但优先级低） |
| **grep-before-claim 强制** | **grounded truth-layer + confidence-check（Stop hook rg 复核）** | **claim-vs-reality rule（声称层，max 仍犯第10坑）** | **🔴 真漏点 = adopt 更强（rule→hook）** |
| **read-before-claim-config** | **grounded edit-guard（read-before-edit + old_string 对账）** | **rule + pre-mortem（声称层）** | **🔴 真漏点 = adopt 更强** |
| 思考深度（trace 非推断） | Meta semi-formal 结构化模板 | claim-vs-reality 铁律3（rule） | adapt（做成 /trace skill 模板强制逐 axis） |
| repo grounding 检索 | Cursor 向量 / aider repo map | grep（手动） | **磊哥够用**（小项目，paper-tiger） |
| rule 厚度 | ETH Zurich：<60 行，linter 替代 | 极厚 rules（人写+实证锚点） | **磊哥决策正确**（max20 不砍），但 top 纪律下沉 hook |

**一句话结论**：磊哥 harness 在 **memory 可溯源性（带 source 行号）** 上比所有商业 harness 强，在 **handoff 强制门** 上有独到设计；**唯一真漏点是 forced code-grounding 全停在声称层（rule）**——而 `grounded`（PreToolUse edit-guard + PostToolUse truth-layer + Stop confidence-check）是现成的、机制精准命中第10坑的 harness-级强制层。**磊哥不缺架构，缺"把 top-3 cite-verify 纪律从 always-on rule 下沉到 exit-code hook"这一步**（rule 留 recognition，hook 做 enforcement）。

---

## adopt-adapt-drop

### ADOPT（直接移植，机制精准命中痛点）
1. **grounded 的 Stop `confidence-check` 思路** → 写一个 Stop hook：从 CC response 抽 claimed 文件路径/函数名/identifier，`rg` 并行复核，NOT FOUND 就 block 强制改。这是第10坑（凭 config/印象推代码工厂方法）的直接解药。**先项目级 `.claude/` 试，实测 Stop 并发后再考虑全局**（T1）。
2. **grounded 的 PostToolUse `truth-layer`** → Grep/Glob 返 0 结果时，hook 立即注入"MUST NOT 引用此 identifier"——抢在 CC 在幻觉 identifier 上建推理之前。低成本高收益。
3. **Pi 的"file-ops 穿透 compaction"原则**（adapt 形态）→ 在磊哥 handoff 模板 + session-closure 强制加"本 session 碰过的文件清单（含行号锚点）"段，让 code-grounding 不随 compact 丢（[F4]）。

### ADAPT（改造后用，对齐磊哥项目特性）
4. **grounded 的 PreToolUse `edit-guard`（old_string 对账实文件）** → 磊哥已有 read-before-edit 习惯，但可加"Edit 的 old_string 必须 grep 命中实文件才放行"的轻量 hook（注意 T1：磊哥 Edit+Bash 并发未验证，需先实测）。
5. **Meta semi-formal reasoning 模板** → 把磊哥 `claim-vs-reality` 铁律3"逐 axis 打印 base/lora 数"做成 `/trace` skill 模板（强制走 premises→trace→divergence→conclusion 步骤），替代"提醒要仔细"（[F11]）。
6. **Augment 分层 rule 加载（always_apply / agent_requested / manual）** → 磊哥 rules 已是 always-on，可把"升级才用"类（cc-upgrade-sop 已做）继续按需化，但**核心 cite-verify/称呼/安全红线 保持 always-on**（与 `rules-vs-skill-loading.md` 一致）。
7. **Pi `/handoff` 一键生成+开新 session** → 磊哥 handoff 是手动拼 prompt，可借鉴"LLM 生成自包含 prompt（含 Files involved + Task）+ 开新 session 带 parentSession 链"的自动化（[F5]）。

### DROP（不适用 MAformac，避免过度工程）
8. **Cursor 向量索引 / Turbopuffer / 自训 embedding** → 小项目（契约 SSOT 单 jsonl + 小 Swift），grep 足够，Cursor 自己也说语义检索在 1000+ 文件才显著（[F10]，P1）。
9. **aider repo map（tree-sitter PageRank）** → 同上，MAformac 文件少，repo skeleton 收益 < grounded 的强制读。Swift 的 tree-sitter grammar 也不如 Python 成熟。
10. **Letta 整套 agent platform / sleep-time compute** → Letta "is not a memory layer you add—it is the stack"（[F2]），整体替换 = 推翻磊哥 harness，违"新≠强"。只取"self-edit + idle 反射"的意图（ADAPT 5/6 已覆盖），不 adopt 平台。
11. **砍磊哥厚 rules 去对齐 ETH Zurich <60 行** → 磊哥 max20+1M context 决策明确不砍（P2 + `rules-vs-skill-loading.md`）。ETH Zurich 测的是冗余 LLM 生成文件，磊哥是人写带实证，不适用。**反向用它：top 纪律下沉 hook，而非加 rule**。

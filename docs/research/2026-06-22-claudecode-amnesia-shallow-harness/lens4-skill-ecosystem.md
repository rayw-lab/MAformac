# Lens-4 — Anti-Amnesia / Anti-Shallow 的 Claude Code Skill/Plugin 生态(adopt > build)

> Finder: lens-4(巨人肩膀)。任务=扫现成 anti-amnesia(失忆)/ anti-shallow(浅思考·不深入代码)的 CC skill/plugin 生态,逐个 star+pushedAt 核活跃度,clone 最活的看结构,对比磊哥现有 rules/skills 哪些可直接 adopt/移植。pre-mortem 重 Elevate-or-Kill(安慰剂 vs 真有效)。
> 调研日期 2026-06-22。clone 落点 `~/workspace/raw/05-Projects/MAformac/ref-repos/`(只读不进仓):`claude-mem-ref`(83.6K★)/ `superpowers-ref`(235K★)/ `research-mode-ref`(141★)。

## summary

生态里现成方案分两类、对应磊哥两痛点:① **失忆类**(memory/handoff harness)——以 `claude-mem`(83.6K★,昨天 push)为王,本质是 **6 事件 lifecycle hook 把记忆从"Claude 自觉"变成"harness 强制注入"**,与 `RickyPOnline/claude-code-memory-road` 的口号「the harness enforces memory, not Claude's discipline」同一哲学,**正中磊哥"纪律写在 rule=声称层"的核心病灶**;② **浅思考类**(anti-shallow/grounding skill)——`superpowers`(235K★)的 `verification-before-completion`(evidence before claims,no cached results from 10 min ago)、`systematic-debugging`(trace data flow,fix at source not symptom)、`research-mode`(141★,local file path+line=cited,"I recall from training data"=NOT cited)、Karpathy skills(220K★合计,think-before-coding)。

但**最锋利的发现是 Elevate-or-Kill 维度**:浅思考类几乎全是 **skill(声称层)**——它们的"enforce"只是 SessionStart hook 把 skill 文本注入 context,**仍靠模型读了照做**,与磊哥已有的 always-on rules 是**同一机制、不是更强的机制**。Karpathy 作者本人坦承「CLAUDE.md instruction following is probabilistic, not guaranteed… think-before-coding still gets skipped under ambiguous prompts. The file is a prompt, not a hard constraint」。这就是磊哥第10坑的本质:effort/rule 都改不了选源反射。**真正比磊哥强的只有 memory 类的 hook 注入机制(失忆)+ "verification 必须 fresh,禁缓存"这条精确表述(浅思考)**;浅思考的 grep-before-claim 物理 enforce **生态里没有现成 plugin,是 build-your-own UserPromptSubmit/Stop hook**(elephant)。

## key findings(每条带 source + date)

### A. 失忆类(memory / cross-session harness)

1. **claude-mem(thedotmack/Alex Newman)= 失忆类绝对王者**:83,648★,pushedAt 2026-06-21(昨天),Apache-2.0,v13.8.0。机制=**6 事件全 lifecycle hook**(实测自 clone 的 `plugin/hooks/hooks.json`):Setup(version-check)/ SessionStart(matcher `startup|clear|compact`,启动 worker + 注入压缩上下文)/ **UserPromptSubmit(每条 prompt 注入 session-init)** / **PreToolUse matcher=Read(file-context 注入)** / PostToolUse matcher=`*`(观测每次 tool)/ Stop(summarize 生成 session 摘要)。后台 worker 用 agent-sdk 压缩观测,存 SQLite(FTS5 全文 + Chroma 向量混合检索),`<private>` 标签可排除。**关键哲学=记忆是 harness 强制的,不是 Claude 自觉的**。Source: https://github.com/thedotmack/claude-mem(repo 元数据 2026-06-22)+ clone `plugin/hooks/hooks.json` WebFetch 2026-06-22 + https://www.augmentcode.com/learn/claude-mem-persistent-memory-claude-code(2026)

2. **claude-code-memory-road(RickyPOnline)= 口号正中病灶但 ★=1**:pushedAt 2026-06-19,★1。描述原话「persistent agent memory across /compact, /clear, cold boots, 529 cascades. **Drop-in install · the harness enforces memory · not Claude's discipline**. Layers 0-12」。**口号=磊哥痛点的完美命名**(纪律 enforce 到 harness 非声称),但 ★=1 + 个人新仓 → 按 github-first 新鲜度/人气双指标该淘汰为实现,只 adopt 其口号定义的方向。Source: https://github.com/RickyPOnline/claude-code-memory-road(2026-06-22)

3. **agentmemory(rohitg00)= memory server 第二梯队**:23,650★,pushedAt 2026-06-22(今天),描述「#1 Persistent memory for AI coding agents based on real-world benchmarks」。独立 memory server(MCP),跨 session/machine/project 持久。与 claude-mem 不同:claude-mem 是 CC 专属 hook harness(本地 SQLite),agentmemory 是跨工具 server。对磊哥(纯 CC + 本地)claude-mem 路线更贴。Source: https://github.com/rohitg00/agentmemory(2026-06-22)+ https://blog.4sapi.com/blog/agentmemory-claude-code-cursor-memory(2026)

4. **eidetic(LARIkoz)/ ai-brain-starter(mycelium-hq)= 新晋小仓**:eidetic 7★ pushedAt 2026-06-22「auto context injection, drift detection, FTS5/vector search, Obsidian export, zero core deps」;ai-brain-starter 20★ pushedAt 2026-06-22「operating system for Claude Code. Memory, accountability, journaling, knowledge graphs」MIT。两者新+低★,**drift detection** 概念(memory 与现实漂移检测)值得 adapt——磊哥 §35 文档组级联 drift 正是这个,但生态实现太新未验。Source: https://github.com/LARIkoz/eidetic + https://github.com/mycelium-hq/ai-brain-starter(2026-06-22)

5. **subagent 失忆是独立子痛点(handoff 问题)**:多源收敛——CC subagent 每次 invoke 从零开始,中间决策(试了 X 因 Y 失败转 Z / 发现的隐式约定 / 走过的死胡同)在返回时全丢,orchestrator 只拿到 final message。CC 原生 `memory` field(per-subagent 持久目录)+ 实验性 SendMessage resume **都不解决 cross-subagent 共享**(每个 subagent 的 memory 目录互相隔离)。Hindsight 的 `hindsight-memory` plugin = 单 project 共享 bank 给所有 subagent + orchestrator 一个公共累积理解。Source: https://hindsight.vectorize.io/blog/2026/05/06/claude-code-subagents-shared-memory(2026-05-06)+ GitHub issue #4487「context amnesia causes silent code deletion」https://github.com/anthropics/claude-code/issues/4487

### B. 浅思考 / 不深入代码类(anti-shallow / grounding skill)

6. **superpowers(obra/Jesse Vincent)= anti-shallow 方法论王者**:235,404★,pushedAt 2026-06-22(今天),MIT。clone 自 `superpowers-ref/skills/` 含 14 skill。关键三条:
   - **verification-before-completion**:Iron Law「NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE」「If you haven't run the verification command in **this message**, you cannot claim it passes」。Rationalization 表:「Should work now → RUN the verification」「Linter passed → Linter ≠ compiler」「Agent said success → Verify independently」。**"fresh, not cached results from 10 minutes ago" 这条精确表述 = 磊哥第10坑(凭过期 smoke 旧值推)的完美命名**。Source: clone `superpowers-ref/skills/verification-before-completion/SKILL.md`(2026-06-22)+ https://www.claudepluginhub.com/skills/obra-superpowers-2/verification-before-completion
   - **systematic-debugging**:Iron Law「NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST」。Phase 1「Trace Data Flow:Where does bad value originate? Keep tracing up until you find the source. **Fix at source, not at symptom**」「If implementing pattern, read reference implementation **COMPLETELY**. Don't skim - read every line」。**正中磊哥"不深入代码,凭 config/receipt 派生物推,不 grep 一手代码工厂方法"**。Source: clone `superpowers-ref/skills/systematic-debugging/SKILL.md`(2026-06-22)
   - **enforce 机制实测=仅 SessionStart hook**:`superpowers-ref/hooks/hooks.json` 只配了一个 SessionStart hook(matcher `startup|clear|compact`)注入 skill listing,**没有任何 PreToolUse/Stop 拦截**——即所有"Iron Law"全是 **prompt 声称层**,靠模型读了 SKILL.md 照做。Source: clone `superpowers-ref/hooks/hooks.json`(2026-06-22)

7. **research-mode(assafkip)= grounding/cite 的最贴 skill**:141★,pushedAt 2026-04-16(>60 天,新鲜度边缘但内容高度相关),无 license。SKILL.md 原文(clone 实读):「**Local file path + line number = cited**」「WebSearch snippet + URL = cited」「**"I recall from training data" = NOT cited. Say 'I believe X but cannot cite a specific source'**」。Source lookup cascade ENFORCED:Level 1 本地文件(Grep/Read,zero cost,"local files ARE the citation")→ Level 2 WebSearch snippet → Level 3 WebFetch(sparingly)→ Level 4 Scholar。Token budget:5 WebSearch / 3 WebFetch per question。**这是磊哥 claim-vs-reality-gap.md cite-verify 纪律的 skill 化身,且 Level 1「先 grep 本地源」正是第10坑的解药**——但它是 toggle skill(声称层),不是 hook。Source: clone `research-mode-ref/SKILL.md`(2026-06-22)+ https://github.com/assafkip/research-mode

8. **Karpathy skills(forrestchang/multica-ai)= 浅思考类最高人气,但本质=磊哥已有机制**:91.2K★(personal)+ 132K★(org mirror)= 220K+ 合计,created 2026-01-27,MIT,70 行单 CLAUDE.md。4 原则:① **Think Before Coding**(state interpretation,flag ambiguity,ask not guess)② Simplicity First ③ Surgical Changes ④ Goal-Driven。第①条直击 Karpathy 原话「models make wrong assumptions and run along without checking」。**🔴 作者本人 disclaimer:「CLAUDE.md instruction following is probabilistic, not guaranteed… think-before-coding still gets skipped under ambiguous prompts. **The file is a prompt, not a hard constraint**」**。Source: https://github.com/multica-ai/andrej-karpathy-skills(2026-06-22)+ https://www.techtimes.com/articles/316798/(2026-05-18)+ CLAUDE.md https://github.com/multica-ai/andrej-karpathy-skills/blob/main/CLAUDE.md

9. **Anthropic 官方亲口命名痛点 ③**:官方 `claude-opus-4-5-migration` plugin 的 `prompt-snippets.md` 列「**Not reading before proposing** — Opus 4.5 may propose solutions without reading code or make assumptions about unread files」,fix「ALWAYS read and understand relevant files before proposing code edits」。**Anthropic 自己承认这是 Opus 系列的已知失败模式**(磊哥第10坑同根)。同 plugin 还列 over-engineering(50→500 行)+ overtriggering。Source: https://tgvashworth.substack.com/p/learning-from-claude-codes-own-plugins(2026)

10. **cavekit 的 `deepen` skill = 唯一直接命名"反浅"的 skill**:JuliusBrussee/cavekit,9 skill 含「**deepen(reach-for):a spare-budget design pass — make one shallow module deep**」。`/ck:deepen` slash command。是生态里唯一把"把浅的做深"做成显式 skill 的。但仍是 skill(声称层 design pass),非 hook 强制。Source: https://github.com/juliusbrussee/cavekit(2026)+ https://www.superdesign.dev/blog/best-claude-code-skills(2026)

11. **grounding 的 hook 物理 enforce 路径(官方文档确认,但无现成 plugin)**:PreToolUse hook exit code 2 = block(deterministic,模型不能 override,连 `--dangerously-skip-permissions` 都拦);**Stop hook exit 2 = 强制 Claude 继续工作**——这是"claim 无证据则不许停"的最直接杠杆。模式=PreToolUse(Bash)记录跑过的 verification 命令进 state file + Stop hook 检查 state file,缺证据则 exit 2 逼它先跑。**但这是 build-your-own,不是现成 plugin**。Source: https://code.claude.com/docs/en/hooks-guide(2026)+ https://blog.boucle.sh/posts/what-claude-code-hooks-can-and-cannot-enforce/(2026)

12. **UserPromptSubmit 自动 grep 注入(grep-before-answer 的物理化)**:UserPromptSubmit hook 的 stdout 直接进 context,脚本可解析 prompt → 自己 grep 代码库 → 把命中代码喂回 context。**这能把"grep 一手代码"从模型自觉变成 harness 默认注入**。但 timeout 仅 30s(深仓 grep 要控),且**生态里没有现成 plugin,需自建**。Source: https://www.datacamp.com/tutorial/claude-code-hooks(2026)+ https://github.com/disler/claude-code-hooks-mastery(2026)

13. **anti-hallucination skill 生态(7 类型分类法)**:Blueprint anti-hallucination(三步 verify:identify claim type → execute tool C7/WebSearch/Read/Grep → cite)+ Hallucination Prevention(7 类幻觉分类:citation errors→temporal fabrications,verbatim numerical copying,High/Moderate/Low 置信评分,URL 存在性 deterministic validation)。多为 research/legal 场景,偏文档 cite 非代码 grep。Source: https://lobehub.com/skills/aedelon-claude-code-blueprint-anti-hallucination(2026)+ https://mcpmarket.com/tools/skills/hallucination-prevention-for-research(2026)

## pre-mortem(tiger / paper-tiger / elephant)

### 🐯 tiger(真威胁,带验证清单)

- **T1:adopt 浅思考类 skill = 装更多声称层,治不了第10坑**。verification-before-completion/research-mode/Karpathy 全是 SessionStart 注入的 prompt,与磊哥已有的 always-on rules 同机制。磊哥开 max + always-on rule 仍犯第10坑(被 GLM-5.2 catch 4 处)= 已证声称层失效。**再 adopt 一个声称层 skill = 安慰剂**。验证清单:① clone 实读 `superpowers-ref/hooks/hooks.json` 确认只有 SessionStart 无拦截 hook ✅ 已验 ② Karpathy 作者亲口 disclaimer「prompt not hard constraint」✅ 已引 ③ 对照磊哥 claim-vs-reality-gap.md 铁律 2「合规≠语义,纪律写在 rule 仍 max 犯」。

- **T2:claude-mem hook harness 会与磊哥现有 hook 拓扑冲突**。磊哥已有 PostToolUse(format/check 5 并行)+ Stop(claude-mem summarize 已装!)+ SessionStart(注入 handoff)。claude-mem 装的也是 6 事件全占,**会与现有 hook 同事件叠加**(尤其 PostToolUse `*` matcher 每 tool 跑 + UserPromptSubmit 每 prompt 跑 + PreToolUse Read 跑),并行安全规则警告 Edit+Bash 同批连坐。验证清单:① grep 磊哥 `~/.claude/settings.json` 现有 hook 事件清单 ② 实测 claude-mem 装后是否与现有 Stop(claude-mem 已在!MEMORY 提到 12.1.0)版本冲突——**磊哥可能已装 claude-mem 旧版**,需先核版本(现 13.8.0 vs 磊哥 12.1.0)。

- **T3:research-mode pushedAt 2026-04-16 已超 60 天**。按 github-first 硬约束(60 天活跃)边缘淘汰。验证清单:① 内容虽高度相关(cite cascade),但仓两月没动 → 只 adopt 其 SKILL.md 文本写法,**不依赖仓维护**;② 检查是否有更新的同类 fork。

### 🦓 paper-tiger(看似威胁实际安全,给证据)

- **PT1:「Karpathy 220K★ 必须 adopt」是人气幻觉**。star 高 ≠ 对磊哥有增量。证据:① 磊哥 codex-metacognition §25/§27 **已经内化了 Karpathy 的 think-before-coding/assumptions/over-engineering**(§25「假设成形即转行动」§27「该讨论时别急产出」),且磊哥版更细(带触发信号 A/B/C/D + 实证案例)② Karpathy skills 是 70 行通用版,磊哥的 rules 是项目特化版 → **磊哥已有的更强,不是漏点**。安全:不 adopt,只确认方向一致。

- **PT2:「claude-mem SQLite/Chroma 太重」担心多余**。证据:① 本地 SQLite FTS5,零云依赖,`<private>` 标签排除敏感(符合磊哥 §6 不入仓红线)② 磊哥 MEMORY 显示已用 claude-mem 12.1.0 → 路线已验证可跑,只是升级 + 调 hook。安全:不是新引入风险,是升级既有。

- **PT3:「研究型 anti-hallucination skill(7 类型分类)能解代码浅思考」是错配**。证据:那些 skill 偏文档 cite/URL 验证(legal/academic 场景),磊哥第10坑是**代码 SSOT grep**(config.yaml 是代码渲染产物 vs 一手工厂方法)。安全:不 adopt 研究型 cite skill,它解的是另一类问题。

### 🐘 elephant(没人提但该提)

- **E1:整个生态里"浅思考/不深入代码"的物理 enforce(grep-before-claim hook / Stop-exit-2 逼证据)= NO 现成 plugin,全是 build-your-own**。memory 类有 claude-mem 这种成熟 hook harness,但 anti-shallow 类**没有对应的 hook 级产品**——市面全停在 skill(声称层)。这意味着**磊哥的真漏点(纪律 enforce 到 hook)在生态里无现成可 adopt,必须自建**(用官方 PreToolUse exit2 / Stop exit2 / UserPromptSubmit 注入机制)。这是 adopt>build 的例外:**memory 类 adopt claude-mem;anti-shallow 类只能 build 一个 grep-gate hook**。

- **E2:claude-mem 的 PreToolUse matcher=Read 注入 file-context = 现成的"读文件时注入相关记忆"机制,可借来做 grep-before-claim 的种子**。它已经在 Read 前注入上下文 → 改造成"Read/答题前注入 grep 命中的一手代码"是最小增量,不用从零建 UserPromptSubmit grep hook。这是生态里离磊哥漏点最近的可移植 hook 骨架,但没人把它用在 anti-shallow 上。

- **E3:memory 解失忆 ≠ 解"凭记忆里的派生物推"**。claude-mem 注入的是"压缩的历史观测"——若历史观测本身就是派生物(config 印象、过期 smoke),memory 反而**固化错误印象**(eidetic 的 drift detection 正为此,但太新)。磊哥第10坑的根=选源反射(抓 context 里的派生物),memory 注入更多 context **可能加重**而非缓解,除非注入的是"一手源指针 + 强制重 grep"而非"结论缓存"。这是 memory 类的反直觉风险,无人提。

- **E4:磊哥已有 handoff 六件套 + MEMORY 指针 + Stop claude-mem,失忆类其实已基本武装**。生态调研最该诚实的是:**磊哥失忆痛点的现成解(claude-mem)磊哥已部署**,真正的 net-new 缺口只在"浅思考的 hook 化"(E1)。不要为了"adopt 个大 star repo"而重复武装已有的失忆防线。

## vs 当前 harness(adopt 更强 / 磊哥已有更好 / 真漏点)

| 维度 | 生态现成方案 | 磊哥现有 harness | 判定 |
|---|---|---|---|
| **跨 session 失忆** | claude-mem(83.6K★,6 事件 hook,SQLite+Chroma)| 已装 claude-mem 12.1.0 + handoff 六件套 + MEMORY 指针 + SessionStart 注入 handoff | **磊哥已有(升级即可)**:claude-mem 是同一工具,磊哥已部署 12.1.0,生态最新 13.8.0;handoff 六件套是磊哥额外的强化层。**净增量=升级 claude-mem 版本,非新引入** |
| **失忆口号/哲学** | memory-road「harness enforces memory not Claude's discipline」| rules-vs-skill-loading.md 已论证 always-on rules 永不 compact | **磊哥已有更好**:磊哥已有"该 always-on 的绝不转 skill"决策,比一句口号更系统 |
| **claim 必须 fresh-verify(禁缓存)** | superpowers verification-before-completion「not cached results from 10 min ago」| claim-vs-reality-gap.md 铁律 2/3 + §34 active-probe | **adopt 更强(措辞)**:磊哥有"诊断往最细粒度钻",但 superpowers 的「fresh, this message, no cached」是第10坑(过期 smoke)的**更精确措辞**,值得 adapt 进 rule |
| **不深入代码/fix at source** | superpowers systematic-debugging「trace to source, read reference COMPLETELY」+ research-mode「local file:line=cited」| claim-vs-reality-gap.md 铁律 3「下钻到最细粒度/代码行非 metadata」+ blueprint-teardown「逐文件读全不抽样」 | **磊哥已有(措辞可借)**:磊哥铁律 3 + blueprint-teardown 已覆盖,research-mode 的「I recall from training=NOT cited」可借作 rule 措辞 |
| **think-before-coding/assumptions** | Karpathy skills(220K★,70 行)| codex-metacognition §25/§27 + execution-discipline 假设暴露 | **磊哥已有更好**:§25/§27 是 Karpathy 的项目特化+触发信号细化版 |
| **浅思考的 HOOK 物理 enforce** | ❌ 无现成 plugin(全是 skill 声称层)| ❌ 纪律全在 rule(声称层),max 仍犯第10坑 | **🔴 真漏点(双方都缺)**:这是唯一 net-new 缺口。生态无现成可 adopt → 必须 build(PreToolUse/Stop exit2 + UserPromptSubmit grep 注入) |

**核心结论**:磊哥的**失忆防线已基本武装**(claude-mem 已装 + handoff 六件套,生态王者就是他在用的工具);浅思考的**声称层也已武装到牙齿**(rules + §25-35 比 Karpathy/superpowers skill 更细)。生态调研最诚实的发现是——**磊哥不缺更多 skill/memory plugin,缺的是把已写在 rule 的纪律 enforce 到 hook 层**,而这恰恰是**生态里没有现成产品的唯一缺口(E1)**。adopt>build 在这里反转:失忆类 adopt(升级 claude-mem),浅思考类只能 build(借 claude-mem PreToolUse-Read 骨架 E2 改造 grep-gate)。

## adopt-adapt-drop

### ADOPT(直接采纳)
- **升级 claude-mem 12.1.0 → 13.8.0**:磊哥已在用,生态王者,6 事件 hook harness 是失忆的成熟解。先核版本兼容(T2)+ 确认 `<private>` 标签符合 §6 红线。Source: https://github.com/thedotmack/claude-mem
- **superpowers `verification-before-completion` 的精确措辞**:「fresh verification this message, no cached results from 10 minutes ago / Linter ≠ compiler / Agent said success → verify independently」→ adapt 进 claim-vs-reality-gap.md 铁律 2 作为第10坑(过期 smoke)的命名。**只 adopt 措辞,不装整个 skill**(skill 与磊哥 rule 同机制)。

### ADAPT(改造移植)
- **claude-mem PreToolUse matcher=Read 注入机制(E2)→ 改造成 anti-shallow grep-gate 的骨架**:它已在 Read 前注入 file-context,最小改造成"答 SSOT/契约问题前注入 grep 命中的一手工厂方法",比从零建 UserPromptSubmit grep hook 省力。
- **research-mode 的 source cascade(Level 1 本地 grep=cited / "training data=NOT cited")→ adapt 成磊哥的 grep-before-claim hook 的判定逻辑**:不装 research-mode skill(它是 toggle 声称层 + >60 天),但它的 cascade 定义可作 hook 的状态机参考。
- **官方 Stop hook exit2 / PreToolUse exit2 机制(finding 11)→ build 磊哥专属 grep-gate hook**:这是真漏点的唯一解。Stop hook 检查"答 SSOT 问题前是否 grep 过一手代码",缺则 exit2 逼重 grep。Source: https://code.claude.com/docs/en/hooks-guide

### DROP(砍掉,Elevate-or-Kill 判 KILL=安慰剂)
- **Karpathy skills(220K★)**:KILL。磊哥 §25/§27 已是其项目特化+细化版,装它=重复武装声称层,作者自认「prompt not hard constraint」→ 证明不了对磊哥有增量。
- **research-mode / blueprint-anti-hallucination / hallucination-prevention 等浅思考类 skill 整装**:KILL(只借措辞/cascade,不装 skill)。理由:与磊哥 always-on rules 同机制(SessionStart 注入声称层),max 已证失效(第10坑)→ 装更多 skill 是安慰剂,治不了选源反射。
- **agentmemory / eidetic / ai-brain-starter / memory-road**:KILL。失忆类磊哥已用 claude-mem 武装,这些是平行替代品(或 ★ 太低太新),无增量;eidetic 的 drift detection 概念记入观察(E3 反直觉风险相关)但不 adopt 实现。
- **cavekit `deepen` skill**:KILL(记入观察)。是唯一直接命名"反浅"的 skill,但仍是 design-pass 声称层,非 hook,且与磊哥 ultracode-7lens/blueprint-teardown 的深拆方法重叠。

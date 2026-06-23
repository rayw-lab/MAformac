# Lens-1: 磊哥当前 CC Harness 实况盘点（对比基线）

> 本机 scout（Bash/Read 实测，非联网），盘点对象 = 磊哥这套 Claude Code harness 对三痛点（① 失忆 ② 浅思 ③ 不深入代码）现有的对策与漏洞。所有断言带 `file:line` / `命令` 一手出处，日期 2026-06-22。

## summary

磊哥 harness = **三层防御**:rules(always-on 永不 compact)+ memory(MEMORY.md 索引 auto-load + 14 个 on-demand .md)+ hooks(8 类事件,settings.json)+ handoff(项目 `docs/handoffs/` 六件套)。**这套 harness 的设计语义层极强（claim-vs-reality-gap.md 已沉淀 10 实证 + 9 同坑变体表),但 enforce 层几乎为零**——三痛点的对策**绝大多数停在 rule(声称层),hook(事实层 enforce)只覆盖 8 个危险 Bash 命令 + handoff 存在性提醒(还是 plain stdout 不 block)**。最刺眼的两个结构洞:(1) **handoff 自动注入只在 compact 后触发,新窗口冷开根本不注入**——`session-closure.md:91` 声称「下次 session 自动注入最近 3 个 handoff」与实际 hook 拓扑不符;(2) **不存在任何 grep-before-claim / cite-verify enforce hook**,第10坑(max effort 仍凭 config.yaml 推配方被 GLM catch)的根因正是「纪律写在 rule 没 enforce 到 hook」。三痛点同根「负载下抓 recall 成本最低源」在 harness 层的镜像 = **rule 是 attention 乘数但靠自觉触发,hook 才是确定性拦截但目前只防 rm -rf**。

## key findings

### A. rules 机制（always-on 层 — 防住「知道该怎么做」）

- **rules 全集 = 33 个 .md(含 python/ 子目录 7 个),最大 codex-metacognition-learnings.md 225 行**，always-on 注入 + 永不被 compact(从磁盘 full-fidelity 重建)。
  - source: `find ~/.claude/rules -type f -name "*.md" -exec wc -l` (2026-06-22)；机制据 `~/.claude/rules/rules-vs-skill-loading.md`(磊哥已联网搜证沉淀:rules=always-on 永不 compact / skill=on-demand 37-50% passive)。
- **三痛点对口 rule 已存在且覆盖完整(声称层)**:
  - 失忆 → `session-closure.md`(91 行,六步沉淀:Learn-Eval/知识审计/handoff/CHANGELOG/自检/下次 prompt)+ `codex-metacognition §33`(分析→执行计划原子写回)+ `§35`(决策→基线文档组级联,2026-06-22 C5 实证)。
  - 浅思 → `pre-mortem-reflex.md`(51 行,scout+oracle 双路 + tiger/paper-tiger/elephant 三分类)+ `ultracode-deep-research-7lens.md`(67 行,7 lens 拆解 + 每路 ≥10 搜证)+ `execution-discipline.md`(假设暴露/2 轮规划上限)。
  - 不深入代码 → `claim-vs-reality-gap.md`(50 行,三铁律:构建 enforce 不 declare / 验证实跑一手 / 诊断下钻最细粒度)+ `codex-metacognition §28`(一手源核验)/`§30`(机械操作实跑)/`§34`(行为探测取代配置检查)。
  - source: `Read ~/.claude/rules/{session-closure,claim-vs-reality-gap,ultracode-deep-research-7lens}.md`，`sed -n` §33/§34/§35 (2026-06-22)。
- **frontmatter tier 字段不统一**:`session-closure.md` 头有 `tier: T4`，`claim-vs-reality-gap.md` 无 frontmatter(直接 `#`),`codex-metacognition` 有 `name/description/type`。官方不认 `tier:` 字段(纯标注),且 settings.json 无 `@import`/`claudeMd` 字段加载 rules(平台自动递归加载 `~/.claude/rules/`)。
  - source: `head -4 ~/.claude/rules/*.md` + `grep "rules\|@import\|claudeMd" ~/.claude/settings.json`(空命中)(2026-06-22)。
- 🔴 **rule 的结构性弱点 = 靠 LLM 自觉触发**:always-on「在场」≠「被遵守」。第10坑实证(`claim-vs-reality-gap.md:33` 第9变体)证明 **开 max effort + claim-vs-reality-gap 全程在场,CC 仍凭 1609 config.yaml 写 scale32 被 GLM-5.2 catch 4 处**。rule 在场是 attention 输入,不是确定性拦截。

### B. memory 机制（混合 auto-load — 防失忆部分有效）

- **memory = 1 个 MEMORY.md 索引(35 行) + 14 个 detail .md**。MEMORY.md 据 system-reminder 每 session auto-load(置顶【架构】段防三层路由失忆);14 个 detail .md(如 `maformac-three-layer-routing-architecture.md`/`maformac-baseline-read-first-lesson.md`)**需显式 Read = on-demand**。
  - source: `ls ~/.claude/projects/-Users-wanglei-workspace-MAformac/memory/*.md`(15 个含索引)+ `wc -l MEMORY.md`(35)(2026-06-22)。
- **MEMORY.md 设计已针对失忆痛点优化**:索引一行一指针 + 置顶「架构(project · 防失忆,最高 · 置顶)」段，明文「CC 反复失忆三层路由 + 3990 范式,起手先内化再干活」。
  - source: `cat MEMORY.md` 头 8 行(2026-06-22)。
- 🔴 **memory 失忆漏洞 = 索引 auto-load 但内容 on-demand**:detail .md 不主动加载，CC 若不 Read 就只有索引的一句话摘要 → 「读了索引≠吃透内容」。`maformac-baseline-read-first-lesson.md` 本身记录的就是「反复马虎:凭二手契约拍脑袋」,但它自己也是 on-demand。

### C. hooks 机制（enforce 层 — 但覆盖面极窄,这是真漏点）

settings.json 注册了 11 个事件 hook，逐个实测其实际 enforce 能力:

| hook 事件 | 脚本 | 实际行为 | 痛点覆盖 |
|---|---|---|---|
| PreToolUse(Bash) | `pre-tool-guard.mjs`(41 行) | 仅 block 8 个危险 pattern(`rm -rf /`/`git reset --hard`/`DROP TABLE`…),`exit(2)` | ❌ 不防浅思/不深入;只防误删 |
| SessionStart(matcher="") | `version-watch.mjs` + `neutralize-token-optimizer.sh` | 版本检查 + 中和 token-optimizer。**不注入 handoff/memory** | ❌ 冷开窗口零 handoff 注入 |
| SessionStart(matcher="compact") | `session-start-compact.mjs`(37 行) | 读 `continuation-prompt.md` 注入 + 删除。**仅 compact 后触发** | ⚠️ 仅 auto-compact 后恢复,非冷开 |
| PreCompact | `precompact-sedimentation.mjs` | 压缩前写 `continuation-prompt.md`(含当前项目 handoff,动态找 cwd `docs/handoffs/`) | ⚠️ 仅压缩链路,冷开不走 |
| UserPromptSubmit | `token-threshold-hook.mjs` | **整体停用**(磊哥 2026-06-02「不允许关注 token」);不注入任何东西 | ❌ 这条本可注入 handoff/cite 提醒,现空转 |
| Stop | `session-stop.mjs`(82 行) | 检测今日 handoff(递归 depth≤4),**plain stdout 提醒,不 block**(注释明文 2026-06-07 从 block 回退防死循环) | ⚠️ 只提醒不强制;漏写 handoff 无硬拦 |
| SubagentStop | `subagent-quality-gate.mjs`(47 行) | result<50 字符且无 StructuredOutput → plain stdout 警告 | ❌ 只警告短结果,不验语义 |
| TaskCompleted | `task-completed-gate.mjs` | 任务完成门 | (Agent Teams 机制,与三痛点弱相关) |

- source: `cat ~/.claude/settings.json` hooks 段 + 逐脚本 `cat`/`head`(2026-06-22)。
- 🔴🔴 **结构洞 1 — handoff 自动注入只在 compact 后**:`session-start-compact.mjs:2` 注释「matcher: compact — Restore context after auto-compact」。`grep "handoff\|readdir\|MEMORY" session-start-compact.mjs` **零命中**。冷开新窗口(SessionStart matcher="")只跑 version-watch,**不读任何 handoff**。`session-closure.md:91`「下次 session 自动注入最近 3 个 handoff」= **声称层 vs 事实层鸿沟**(rule 自己中招)——只有「压缩后恢复」是真的,「冷开注入」是假的。
- 🔴🔴 **结构洞 2 — 不存在 grep-before-claim / cite-verify enforce hook**:`grep -liE "cite|grep.before|claim|verify|reality|enforce" ~/.claude/scripts/*.mjs` 只命中 `teammate-idle-guard.mjs`(substring 噪声,与 cite 无关)。第10坑根因(max 仍凭派生物推)在 harness 层**完全无 enforce 兜底**——claim-vs-reality-gap.md 的 10 实证全靠 LLM 自觉。

### D. handoff 机制（跨 session 交接 — 内容质量高,注入链路断）

- **handoff 六件套已成熟模板**:`2026-06-22-c5-recovery-hermes-handoff-six-piece.md`(18k)六件套 = ① 状态指针 ② 元认知/反模式 ③ 已闭环 grill 速查 ④ 待 grill 清单 ⑤ 本次错误(防重蹈)⑥ 起手 step-by-step(含 grep 自检命令)。最新 closeout `2026-06-22-c5-recovery-grill-marathon-closeout.md` 含「9 次同坑变体表」防重犯。
  - source: `grep "^#" .../2026-06-22-...-six-piece.md` + `head -50 .../marathon-closeout.md`(2026-06-22)。
- **handoff 内容是三痛点的最强人工对策**:六件套件 2(9 坑反射)+ 件 5(本次错误)直接喂「别重犯不深入代码的坑」。但**它的价值实现依赖人/CC 主动 Read**——冷开窗口若不读(无注入 hook),六件套等于不存在。
- handoff 目录 `docs/handoffs/` 有 20 个文件，命名 `YYYY-MM-DD-<slug>.md` 规范统一。

## pre-mortem

### tiger（明确威胁,带验证清单）

- **T1 — 「rule 在场」误判为「rule 生效」**:always-on rule 是 attention 输入非 enforce。验证清单:第10坑(`claim-vs-reality-gap.md:33`)= claim-vs-reality-gap 全程在场 + max effort 仍犯 → **已坐实 rule≠enforce**。威胁等级 HIGH(已发生 10 次同坑)。
- **T2 — 冷开窗口失忆**:`session-start-compact.mjs` 只在 compact 触发,SessionStart matcher="" 不注入 handoff。验证清单:`grep handoff session-start-compact.mjs`=0 命中 + SessionStart matcher="" hooks 只有 version-watch/neutralize-token。**新窗口冷开 = 零 handoff/memory-detail 注入,只有 MEMORY.md 索引(平台 auto-load)**。威胁等级 HIGH。
- **T3 — Stop hook 不 block 漏写 handoff**:`session-stop.mjs` 注释明文从 block 回退到 plain stdout(防死循环)。验证清单:`session-stop.mjs` 末尾 `console.log` 非 `decision:block`。漏写 handoff 时只有一行 ⚠️,可被 CC 忽略 → 下次 session 失忆。威胁等级 MEDIUM(有提醒,靠自觉补)。

### paper-tiger（看似威胁实际安全,给证据)

- **PT1 — 「rules 太多稀释 attention」**:33 个 rule 看似过载，但 `rules-vs-skill-loading.md` 已联网搜证「rules 只加载一次便宜,token/context 不是磊哥约束(max20+1M)」。证据:磊哥已显式裁决「转 skill 省 context = 行为降级」。→ 不是真威胁,是已论证的设计选择。
- **PT2 — 「memory detail .md on-demand 会丢」**:看似失忆,但 MEMORY.md 索引每句摘要已含关键结论(如「L1 明确走规则快路秒回」),且置顶架构段强制起手内化。证据:`cat MEMORY.md` 头部摘要密度高。→ 索引层已兜住「知道有这回事」,detail 是深化非必读。半真半假(索引够 recall,不够吃透)。

### elephant（没人提但该提的)

- **E1 — UserPromptSubmit hook 是被浪费的黄金 enforce 点**:`token-threshold-hook.mjs` 整体停用(磊哥不看 token),但 **UserPromptSubmit 是唯一能 `additionalContext` 注入(2.1.168 schema 允许)且每轮触发的事件**。它现在空转——本可承载「冷开注入最近 handoff」「写数字前 grep 提醒」「cite-verify 反射」。这是 harness 里**最大的未利用 enforce 杠杆**,没人提因为它被 token 议题占用后废弃了。
- **E2 — 三痛点的 enforce 缺口是同一个洞的三个面**:失忆(冷开不注入)/ 浅思(无 pre-mortem 前置门)/ 不深入(无 grep-before-claim)三者,在 hook 层**都缺一个 UserPromptSubmit/PreToolUse 级的确定性拦截**。rule 层各自完备,enforce 层集体缺席。根因 = harness 演进时「写 rule」recall 成本远低于「写 hook」(hook 要 node 脚本 + schema + 冒烟),所以纪律都沉淀成 rule。
- **E3 — claim-vs-reality-gap.md 的「第10坑」已暴露但未驱动 harness 改造**:rule 自己写了「effort≠纪律,扳机在写每个数字时」(`:33`/`:39`),但这个「扳机」目前**纯靠 LLM 自觉**,没有任何 PreToolUse(Write/Edit 含数字时提醒 grep)或 stdout 反射钩子。rule 诚实承认了问题却没 enforce 修复,正是「声称层 vs 事实层」在 harness 自身的递归镜像。

## vs 当前 harness（adopt 更强 / 磊哥已有更好 / 真漏点）

- **磊哥已有更好(无需 adopt 外部)**:
  - rule 设计语义深度(claim-vs-reality-gap 10 实证 + codex-metacog 35 条 + 9 同坑变体表)= **业界罕见的自审纪律密度**,外部 CC harness 实践(后续 lens 会查的 memory-bank/cursor rules 类)多半更浅。
  - handoff 六件套 + MEMORY.md 置顶架构段 = 成熟的失忆对策内容载体,内容质量不缺。
  - compact 链路(PreCompact 写 → SessionStart-compact 恢复)= 平台级失忆兜底,这一段已闭环。
- **真漏点(harness 必须补 hook,这是 lens1 核心结论)**:
  1. **冷开窗口 handoff 注入缺失**(结构洞 1)→ 需 SessionStart matcher="" 或 UserPromptSubmit 首轮注入最近 N 个 handoff。
  2. **grep-before-claim / cite-verify 零 enforce**(结构洞 2)→ 第10坑的确定性兜底缺失,纪律全在 rule。
  3. **Stop hook 不 block 漏写 handoff** → 失忆链路末端无硬门。
  4. **UserPromptSubmit 黄金 enforce 点空转**(E1)→ 最大未利用杠杆。
- **adopt 方向(待后续 lens 联网验证外部实践)**:外部若有「memory-bank 强制读取 hook」「pre-action cite gate」「session-start context injection」成熟实现 → adopt 其 **hook enforce 形态**(不是 rule 内容,磊哥 rule 内容已更强),填上述 4 个漏点。

## adopt-adapt-drop

- **ADOPT(从外部实践,若 lens3-7 找到成熟 hook 实现)**:
  - SessionStart/UserPromptSubmit **冷开 handoff 自动注入** hook 形态(补结构洞 1)。
  - **写数字/配方/枚举前的 cite-verify pre-action gate** hook 形态(补结构洞 2,把 claim-vs-reality-gap 从 rule 提到 enforce)。
- **ADAPT(磊哥已有,改造增强)**:
  - **复活 UserPromptSubmit hook**:从「token 提醒(已停用)」改造成「首轮注入最近 handoff + 含数字 prompt 时 cite 反射」(E1 黄金点)。
  - **`session-start-compact.mjs` 逻辑扩到 SessionStart matcher=""**:把「读 continuation-prompt 注入」的能力扩到冷开窗口(读最近 handoff 摘要)。
  - **Stop hook 从 plain stdout 升级为 conditional block**:漏写 handoff 且非只读会话 → `decision:block`(注意防死循环,需「写 handoff」一动作可消除)。
- **DROP / 不碰**:
  - 不为补 enforce 而把 always-on rule 转 skill(`rules-vs-skill-loading.md` 已裁决 = 降级)。
  - 不加 token 阈值类 hook(磊哥明确不看 token)。
  - rule 内容层不抄外部(磊哥语义密度已更强),只 adopt 外部的 **hook enforce 工程形态**。

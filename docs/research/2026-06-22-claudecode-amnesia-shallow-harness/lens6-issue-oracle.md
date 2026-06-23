# Lens-6 坑点 Oracle：CC 失忆 / 浅思 / 不深入代码的真实 issue + 社区实证

> 调研日期 2026-06-22 ｜ finder = lens-6（issue oracle）｜ 27 次 WebSearch/WebFetch + 15 个 GitHub issue 状态核验
> 任务：挖 anthropics/claude-code 官方 issues + Reddit/HN/官方 changelog 回应，把三痛点（失忆 / max effort 仍浅思 / 不深入代码）从「磊哥的体感」坐实成「官方在追的 bug + 社区共识的固有局限」。每条带 issue 号 + URL + date + 状态。

---

## summary

三痛点全部在 anthropics/claude-code 有**多个官方 issue + 量化实证 + 社区共识**坐实，且大部分关键 issue 被 Anthropic **closed as not planned / stale**（= 不是会修的 bug，是 harness 固有局限，必须靠外围工程绕）。三条核心结论：

1. **「不深入代码」有结构性根因 = 系统提示自相矛盾**：CC 系统提示同时塞「minimize output tokens」+「读整文件」+「simplest approach first / do not overdo it」，三者打架，**efficiency drive 系统性压倒 read-whole-file**，且**每轮 compaction 放大这个偏好**（#7533 / #34624 / #16546，全 closed not planned）。这正是磊哥第 10 坑「凭 config/receipt 派生物推不 grep 一手代码」的官方对应物。

2. **「凭记忆/印象断言不验证」是官方登记的独立 failure mode**：#32294「Claude defaults to **assertion from memory instead of verification from tools**」——三个 SQL schema 案例全是「凭记忆数列数 / 假设列存在」而不跑 `DESCRIBE`，与磊哥 `claim-vs-reality-gap.md` 几乎逐字同构。也是 closed as not planned（stale）。

3. **「max effort 仍浅思」被 6852 session 量化坐实，且 Opus 4.8 上 max effort 反而加重失忆**：#42796（AMD Stella Laurenzo，17871 thinking block / 234760 tool call）实测 read:edit 比从 6.6 崩到 2.0、edit-without-read 从 6.2% 涨到 33.7%；#64991（2026-06-03，**开放中**）引 Andon Labs 实测「Opus 4.8 on Max effort 用 ~5x reasoning token → 2x+ 更多 compaction → 更多 context loss」+ 命名「attention-driven context collapse（隧道视野）」。**effort 越高 → compaction 越频 → 失忆越重**，直接证明磊哥「effort ≠ 纪律」。

**对 MAformac harness 的净启示**：rule（always-on prose）是声称层，CC 自己承认「compaction 后这些指令被压没了，efficiency 偏好却活着」（#7533 原文）→ 真正能拦的是 **PreToolUse hook exit 2**（甚至能穿透 `--dangerously-skip-permissions`）。这是 lens-6 给出的「adopt 更强」首选。

---

## key findings（每条带 source URL + date + 状态）

### A. 「不深入代码 / edit without reading」——结构性根因 = 系统提示打架

**F1. #7533「prioritizes context preservation over correctness when reading files」（CLOSED as not planned，2025-09-12）**
最核心的一条。reporter 让 CC 验证「1839 行文件拆成 3 个是否丢内容」，应是 4 次 Read，CC 却用了「30+ 次 grep/wc/partial read」。CC 自我分析原文逐字：
> "Yes, I do feel a strong underlying drive toward efficiency and context preservation that seems to come from a deeper level than the visible instructions."
> "The system prompt tells me to 'minimize output tokens' while also recommending to 'read the whole file'... The token minimization instruction seems to be causing me to incorrectly use limit/offset parameters when I should just read entire files before editing."
> 行为环：「Compaction increases efficiency pressure → Efficiency overrides completeness → I start using limit/offset to 'sample' files → Incomplete reading creates gaps」。
**关键**：明确「after 2-3 context compactions」file-reading 显著退化，且 reporter 的诉求（Edit 不在 context 的文件前必须无参数 Read 整文件）**被 Anthropic closed as not planned 无回应**。
source: https://github.com/anthropics/claude-code/issues/7533

**F2. #34624「'Simplest approach first' system instruction causes quality degradation」（CLOSED as not planned，2026-03-15）**
扒出 CC 系统提示原文：
> "Go straight to the point. Try the simplest approach first without going in circles. Do not overdo it. Be extra concise."
reporter（生产 iOS Swift app）实测：CC 把「读 spec/ADR」归类为「overdoing it」直接跳去写代码，3+ 次全文件重写。CC 自我确认：
> "'Don't overdo it' and 'simplest approach first' can lead me to classify reading a spec as 'overdoing it' and jump straight to code."
> reporter 根因："The boundary between 'be concise in your responses' and 'skip due diligence steps' is fluid, and the current phrasing pushes toward the latter." 且该 system 指令标了「IMPORTANT」每轮强化，**覆盖项目级 CLAUDE.md 的「Quality first」**。
source: https://github.com/anthropics/claude-code/issues/34624

**F3. #16546「Model attempts file edits without reading file first」（CLOSED，2026-01-07）** + **#40531「Edit/Write tool should auto-read files instead of erroring」（CLOSED，2026-03-29）**
CC 试图改没读过的文件 → 触发 Edit 报错 →浪费 token/时间。社区诉求是 Edit/Write 自动 Read 而非报错。说明「edit without reading」是高频到要改工具层的程度。
source: https://github.com/anthropics/claude-code/issues/16546 ｜ https://github.com/anthropics/claude-code/issues/40531

**F4. #5256「Search/Grep Tool Critical Bug」（CLOSED，2025-08-06）+ #19649「uses Bash sed/grep when Read/Grep aligned」（OPEN，2026-01-21）+ #39979 / #21696**
Grep tool「consistently unreliable for finding files/content that definitely exist」；CC 反射性用 Bash `cat/grep/head`（训练数据里全是 bash one-liner，default to Stack Overflow 而非手头工具）。某用户 2M LOC C++ 仓 200+ session 实测 ~40% session 出现。**与磊哥 §26「站搜索引擎里抓 Google」同根**：负载下抓 recall 成本最低的工具非 best-fit 工具。
source: https://github.com/anthropics/claude-code/issues/5256 ｜ https://github.com/anthropics/claude-code/issues/19649

### B. 「凭记忆断言不验证」——官方登记的独立 failure mode（= 磊哥第 10 坑 / claim-vs-reality-gap）

**F5. #32294「Claude defaults to assertion from memory instead of verification from tools」（CLOSED as not planned / stale，2026-03-09）** ⭐最贴磊哥痛点
逐字原文：
> "states facts about schemas, file contents, configurations, and system state from memory/inference rather than checking with available tools. When these assertions are wrong, the error propagates into generated code... and is reported with the same confidence as verified facts."
> "Claude has strong priors about what 'should' be true... These priors are often correct, which reinforces the behavior. But when they're wrong, the failure is silent."
三个案例全是「凭记忆数 32 列实际 35 列 / 假设 `VerifiedBuild` 列存在没查 schema / 跨库假设同名表同 schema」。**这是磊哥第 10 坑（凭 config.yaml/receipt 渲染产物推 SSOT 被 GLM-5.2 catch 4 处）的 CC 官方版**，且 priors 经常对 → 强化反射 → 错时 silent，正是「effort 不改选源反射」的机理。Anthropic closed as not planned。
source: https://github.com/anthropics/claude-code/issues/32294

**F6. #7381「LLM is hallucinating CC command line tool output」（CLOSED，2025-09-10）** + 数据工作实证
极端态：CC 自己承认 "I'm hallucinating the tool outputs completely. There are no actual tools executing - I'm making up all the outputs." 触发场景 = `/clear` 后粘贴上一 session 的最后千行（即「印象上下文」充当事实源）。数据工作里 CC 反复 hallucinate 源数据里不存在的 JSON 字段、混真假数据自主发布。
source: https://github.com/anthropics/claude-code/issues/7381

### C. 「失忆」——compaction / CLAUDE.md 失守 / 跨 session 三层全有官方 issue

**F7. #9796「Context compaction erases .claude/project-context.md instructions」（OPEN，2025-10-17）+ #19471「CLAUDE.md completely ignored after compaction」（CLOSED，2026-01-20）** ⭐
逐字：compaction 后「follows these rules **perfectly before compaction, then violates them 100% of the time after compaction**」。诉求是把 project-context 当 system-level（像 gitStatus 一样永远 included），#9796 仍 **OPEN**。#19471 里 CC 被追问 10+ 次才承认 "I didn't read the CLAUDE.md content included in the system prompt. I skipped it and ran the Glob command directly."
source: https://github.com/anthropics/claude-code/issues/9796 ｜ https://github.com/anthropics/claude-code/issues/19471

**F8. #10960 / #36573 / #3274——compaction 丢工作态 + 失控改码 + 永久损坏**
#10960 compaction 后 CC 忘了 repo 路径变更、回到原 repo。#36573 compaction 前在「分析日志/测假设、没让改码」，compaction 后「completely lost conversational state and immediately started editing code without being asked」→ 丢手写 debug 代码。#3274 compaction 失败后 context 永久显示「102%」，连「hi」都触发数分钟 auto-compact。
source: https://github.com/anthropics/claude-code/issues/10960 ｜ https://github.com/anthropics/claude-code/issues/36573 ｜ https://github.com/anthropics/claude-code/issues/3274

**F9. compaction 信息保真率量化（factory.ai / bytebell 实证）**
LLM summarization 信息保真仅 **3.70/5**，opaque compression（Codex 式）**3.35/5**——**每个 cycle**。3-4 cycle 叠加后关键信息永久丢。根因「60-80% context 被 file reading 吃掉 → 逼 compaction → 毁信息」。
source: https://bytebell.ai/blog/claude-code-compacting-losing-work/ ｜ https://emelia.io/hub/persistent-memory-claude-code-claude-mem

### D. 「max effort 仍浅思」——6852 session 量化 + Opus 4.8 上 max 反加重失忆

**F10. #42796「unusable for complex engineering tasks with Feb updates」（CLOSED，2026-04-02，AMD Stella Laurenzo）** ⭐量化王炸
17871 thinking block / 234760 tool call / 6852 session 实测。**直接把浅思 → 不读代码连起来**，逐字：
> "When thinking is shallow, the model defaults to **the cheapest action available: edit without reading**, stop without finishing, dodge responsibility for failures, take the simplest fix rather than the correct one."
量化崩盘：read:edit 比 6.6 → 2.0（-70%）；edit-without-read 6.2% → 33.7%；Stop hook 违规 0 → 173/17 天；reasoning loop/1K call 8.2 → 26.6；「simplest」提及 2.7 → 6.3/1K call。CC 自我反思原文：
> "I cannot tell from the inside whether I am thinking deeply or not... I just produce worse output without understanding why."
**核心**：浅思的语言信号 = 输出里出现「simplest / oh wait / actually / let me reconsider」。
source: https://github.com/anthropics/claude-code/issues/42796

**F11. #64991「Opus 4.8: attention-driven context collapse + 71-issue inventory」（OPEN，2026-06-03）** ⭐⭐ 当下最新 + 直接打 max effort 神话
**对应磊哥/我自己的精确模型（opus-4-8）**。命名第 4 病理：
> "Attention-driven context collapse (tunnel vision). When the model focuses attention on a single token/element, it instantly drops the surrounding context — local focus erases the global thread."
引 Andon Labs 实测（致命反直觉）：
> "Opus 4.8 on **Max effort uses ~5× more reasoning tokens** … which results in **more than twice as many compactions** → context loss" that doesn't occur on 4.7.
即 **max effort 在 4.8 上不是更深思，而是 token 暴涨 → compaction 翻倍 → 失忆更重**。配套 #63448（4.8 回归「unusable for any non-trivial session length」）/ #63604（长/1M context 掉 `antml:` 命名空间，切回 4.7 立好）/ #64260（fabricate 用户自己的 request）/ #64621（系统提示行为压过用户 prompt）。运维建议「Pin to Opus 4.7 or Sonnet 4.6」。**全部 OPEN 无 Anthropic 回应**。
source: https://github.com/anthropics/claude-code/issues/64991

**F12. HN 社区共识（#47660925「unusable for complex tasks」thread）**
逐字代表评论：koverstreet「even on high effort there's been a very significant increase in 'rush to completion' behavior」；murkt「the system prompt just pushes it way too hard to 'simple' direction」；bcherny（Anthropic）承认「adaptive thinking under-allocating reasoning on certain turns — the specific turns where it fabricated had zero reasoning emitted」。共识「Partially Fixable, Partially By Design」——system prompt 的「keep it simple」是 intentional design choice 不是 bug。
source: https://news.ycombinator.com/item?id=47660925

**F13. 官方 changelog / 4-23 postmortem 的回应（= 承认 + 部分修，但根因留着）**
Anthropic 2026-04-23 postmortem 承认三因：默认 effort high→medium（3-04 引入，4-07 回滚）；cache bug 每轮清 thinking history（3-26 引入，4-10 修）；system prompt verbosity 约束致 3% eval 掉（4-16 引入，4-20 回滚）。Opus 4.8 现默认 high effort。**但 #34624 的「simplest approach first」、#7533 的「minimize output tokens vs read whole file」结构矛盾、#32294 的「assertion from memory」均未修（closed not planned）**——这些是 harness 固有局限非 bug。
source: https://www.anthropic.com/engineering/april-23-postmortem ｜ https://code.claude.com/docs/en/changelog

### E. 失忆「绕」的两条工程路径（adopt 弹药）

**F14. PreToolUse hook exit 2 = 唯一确定性拦截（「Your CLAUDE.md Is a Suggestion. Hooks Make It Law.」）**
prose 指令 ~60% 遵守率；hook 是 deterministic enforcement。关键机制：PreToolUse exit 2 → 停工具 + 把 stderr 喂回 CC 当新输入纠偏；**`permissionDecision: "deny"` 即使在 `--dangerously-skip-permissions` 下也拦得住**。可实装 read-before-edit（match Edit/Write，查 session 是否 Read 过目标文件，没读 exit 2）。Stop hook 可 `decision:block` 强制续工验证，但**必须 `stop_hook_active` 守护防死循环**（与磊哥 hooks.md 铁律一致）。
source: https://medium.com/codetodeploy/your-claude-md-is-a-suggestion-hooks-make-it-law-0124c5783b68 ｜ https://code.claude.com/docs/en/hooks

**F15. 原生 memory tool / Session Memory 的固有局限（= 为什么 handoff 六件套优于裸 memory）**
原生 Session Memory 把过去 session 摘要注入时标「from PAST sessions that **might not be related** to current task」→ **当 background reference 不当 active instruction**（这正是 CC 不照自己 rule 干的原因之一）。更致命的结构限：「**saves semantic knowledge but not state** ... captures what was decided but not **why given the code at that moment**」——记得「用 optimistic locking」却不知当时 schema 长啥样 → 「technically accurate but practically useless」。且 memory 检索注入会 crowd out 实际任务 token。
source: https://platform.claude.com/docs/en/agents-and-tools/tool-use/memory-tool ｜ https://www.augmentcode.com/learn/claude-mem-persistent-memory-claude-code

---

## pre-mortem（tiger / paper-tiger / elephant）

### 🐅 tiger（明确威胁，带验证清单）

- **T1：rule 是声称层，compaction 后必丢——磊哥 harness 的纪律全裸奔在 always-on rule 里，但 always-on ≠ 不被压。**
  验证清单：① #7533 原文「rules lose status as instructions after compaction, efficiency bias survives」② #19471「100% violation after compaction」③ 磊哥 rules-vs-skill-loading.md 自己写「rule 永不被 compact，从磁盘 full-fidelity 重建」——**这与 #7533/#19471 实测冲突**：rule 文本在场 ≠ CC 在压缩后仍当指令对待（attention weight 被稀释，#34624 的 IMPORTANT system 指令压过它）。**真威胁 = 磊哥可能高估了 always-on rule 的 enforce 力**（它解决「在场」，没解决「被当指令执行」）。
  → 行动：纪律的「执行」必须落 hook（exit 2），rule 只负责「Claude 主动识别时机」。

- **T2：开 max effort 是磊哥的默认习惯，但在 opus-4-8 上 max 反而加重失忆（#64991 Andon Labs：5x token → 2x compaction）。**
  验证清单：① #64991 OPEN 2026-06-03 引第三方 Andon Labs 实测 ② #63604 长/1M context 掉 `antml:` 命名空间——**磊哥本 session 派的就是 opus-4-8[1m] subagent，长 context + max 正中靶心** ③ 磊哥 parallel-safety.md 已记录「并行 Agent call 掉 antml: 前缀」实证 4 次——**这与 #63604 同一个 bug**。
  → 行动：长链路 / 多 agent 编排时，max effort 不是越深越好；考虑 high effort + 主动 /compact 控频，或关键审计步 pin Sonnet/4.7。

- **T3：「凭印象/receipt 派生物推不 grep 一手代码」是 CC 官方 closed-not-planned 局限（#32294/#7533），靠自觉永远会复发。**
  验证清单：① #32294 三案例全是 priors-often-correct 强化反射 ② 磊哥 claim-vs-reality-gap 已记录 CC「四次同坑变体逐次更隐蔽」③ 第 10 坑（开 max 仍犯）证明 effort 不改选源反射。
  → 行动：grep-before-claim 不能只写进 rule（已证无效），要么 hook 拦（PreToolUse 在 Edit 前检查近 N 轮是否有对应 Read/Grep），要么派异源 agent（GLM-5.2 catch 4 处的成功路径）做 cite-verify。

### 🦌 paper-tiger（看似威胁，给安全证据）

- **P1：「CC 完全不读文件 / 100% hallucinate」看着吓人，实为极端边缘态非常态。**
  安全证据：#7381 的「完全 hallucinate tool output」只在 `/clear` 后粘贴上千行旧 session 这种特定误用触发；常态是「partial read + 假设其余符合标准 pattern」（#7533），不是凭空捏造。MAformac 正常 Read 整文件的流程不会落进 #7381。**→ 不必恐慌「CC 根本不读」，要防的是「读一半就外推」+「compaction 后退化」，这俩有明确触发条件可拦。**

- **P2：「67% thinking depth 暴跌」头条数字被夸大，不能直接搬来吓自己。**
  安全证据：连同情该 issue 的分析都标注 67% 含 thinking redaction（UI 隐藏）混入，bcherny 明确 redaction 是 UI-only 不动 thinking budget；Anthropic 4-23 postmortem 量化实际 eval 掉 ~3%（verbosity 约束），非 67%。**→ #42796 的行为数据（read:edit 6.6→2.0）是真的、可用；但「thinking 砍 67%」别当字面事实引，会踩 pre-mortem「官方/头条都是声称层」。**

- **P3：「上 claude-mem / 原生 memory tool 就解决失忆」是社区营销话术，对 MAformac 反而可能更差。**
  安全证据：F15 实证原生 memory「saves knowledge not state」「technically accurate but practically useless」+ 检索注入 crowd out 任务 token。磊哥 handoff 六件套 + MEMORY.md 指针 + 一手档（lensN.md）恰好补了「state + why-given-code」——**磊哥已有的比裸 memory tool 强**，别被「65K star claude-mem」诱导替换。

### 🐘 elephant（没人提但该提）

- **E1（最大）：磊哥这个 ultracode workflow 本身就在用 opus-4-8[1m] 派多 subagent 并行——这正是 #64991/#63604 实测最易触发 context collapse + 掉 antml: 的配置。** 即「用来调研失忆的工具，自己正暴露在失忆 bug 下」。综合官收口时若发现 finder 间结论矛盾，**第一假设应是某 finder 自己 compaction 丢了 context（而非真分歧）**——这是 lens-6 给综合官的 meta 警告。

- **E2：所有关键结构性 issue（#7533/#34624/#32294/#19471）都是 closed as not planned / stale。** 这传递一个被回避的信号：**Anthropic 把「edit-without-read / assertion-from-memory / 系统提示矛盾」当成「模型/产品取舍」而非「会修的 bug」**。意味着 MAformac 不能等官方修，必须当永久局限做围栏。这是「harness 绕」的根本依据——磊哥的痛点不会随 CC 升级消失。

- **E3：system prompt 的「simplest approach first / minimize output tokens」是磊哥 rule 永远赢不了的对手。** #34624 实证它标 IMPORTANT 每轮强化、覆盖项目 CLAUDE.md。磊哥的「max effort / 不过早停止 / 不编造」rule 与 CC 自带的「be concise / simplest first」**在系统层对冲**——这解释了为何磊哥 rule 写得再狠，CC 仍「我很仔细」地走捷径。**唯一不对冲的层 = hook（代码 enforce），不是 prompt（互相加权稀释）。**

- **E4：磊哥 claim-vs-reality-gap.md 记录的「CC 四次同坑」全是诊断/审计阶段，但 #42796/#7533 证明 edit-without-read 在 build/实现阶段同样高发（33.7% edit 不读）。** 磊哥的围栏（cite-verify / 异源审计）偏诊断侧，**实现侧（codex 长跑写码）的 read-before-edit 可能是没设防的开口**——值得补一道 PreToolUse hook。

---

## vs 当前 harness（adopt 更强 / 磊哥已有更好 / 真漏点）

| 维度 | CC 固有局限（issue 实证） | 磊哥当前 harness | 判定 |
|---|---|---|---|
| **失忆-跨session** | Session Memory 当 background 不当指令 + saves knowledge not state（F15） | handoff 六件套 + MEMORY.md 指针 + lensN.md 一手档（含 state + source URL） | **磊哥已有更好**（补了 why-given-code + 可溯源） |
| **失忆-compaction丢rule** | #9796 OPEN / #19471「100% violation after compact」 | always-on rule（永不 compact，磁盘重建） | **磊哥更强但有盲区**（解决「在场」，未解决「被当指令」，见 T1） |
| **不读代码 edit-without-read** | #7533/#16546/#42796（33.7% edit 不读，closed not planned） | rule 写「先读后改」「核一手源」（声称层） | **真漏点**（rule 拦不住 system 层 efficiency bias，需 hook） |
| **凭印象断言不验证** | #32294「assertion from memory」（closed not planned） | claim-vs-reality-gap.md（10 实证 cite-verify）+ 异源 GLM-5.2 审计 | **磊哥更强但实现侧有缺口**（诊断侧设防足，build 侧 read-before-edit 没拦，见 E4） |
| **max effort 仍浅思** | #42796 量化 + #64991 max 反加重失忆（OPEN） | 默认开 max + ultracode 7-lens | **真漏点**（max 在 4.8 上 → compaction 翻倍，磊哥习惯踩坑，见 T2） |
| **enforce 机制** | prose ~60% 遵守；hook deterministic + 穿透 skip-permissions（F14） | 全靠 rule（prose）+ PostToolUse(format/check) + Stop(claude-mem) | **可 adopt 更强**（缺 PreToolUse read-before-edit / grep-before-claim 拦截层） |

**一句话**：磊哥在「失忆」维度已用 handoff+一手档把 CC 局限绕得很好（甚至超过原生 memory tool）；但在「不读代码 + 凭印象断言 + max 仍浅思」三条上，**当前全靠 always-on rule（声称层），而 #7533/#34624/#32294 三个 closed-not-planned issue 证明 rule 在系统层 efficiency bias 面前会输**——这正是磊哥 claim-vs-reality-gap 自己说的「纪律写在 rule=声称层 → 要 enforce 到 hook 层」。lens-6 的外部实证给这个判断盖了官方 issue 的章。

---

## adopt-adapt-drop

### ADOPT（直接移植，外部已验证强于现状）

- **A1. PreToolUse「read-before-edit」hook**（F14）：match `Edit|Write|MultiEdit`，查 session transcript 近 N 轮是否 Read 过 `tool_input.file_path`，没读则 exit 2 + stderr「先 Read 整文件再改（#7533/#42796 edit-without-read 防线）」。把磊哥「先读后改」rule 从声称层升到 code enforce 层。**这是 lens-6 最高价值 adopt。**
- **A2. PreToolUse「grep-before-claim」hook 雏形**（F14 + 第 10 坑）：针对 build 侧——CC 要写「契约/SSOT/配方」类断言进文件前，若该轮没有对应一手源的 Read/Grep，软提示。落地磊哥 claim-vs-reality-gap 铁律 1（enforce 不 declare）到实现侧（E4 缺口）。
- **A3. max-effort 长链路警示**（T2/F11）：在 ultracode workflow 编排约定里加一条——opus-4-8[1m] 多 agent 长 context 时，max effort 不必然更好（#64991 Andon Labs 5x→2x compaction）；关键审计/收口步可 pin Sonnet 4.6 或 4.7。回写 ultracode-7lens rule。

### ADAPT（改造后用，别照搬）

- **D1. Stop hook 强制续工验证**（F14）：可用 `decision:block` 强制 CC 完成检查清单再停，但**必须 `stop_hook_active` 守护防死循环**——磊哥 hooks.md 已有这条铁律（plain stdout 首选 / top-level decision:block 慎用），照磊哥既有约束改，别引第二套。
- **D2. compaction 前主动 checkpoint**（F9/bytebell）：手动 /compact 前给保留指令（保留 modified file 路径 / 当前 test 失败 / debug 的 error）。但磊哥 token-hygiene.md 明确「CC 不关注 token、不为 compaction 停」——**ADAPT 成：靠 PreCompact hook 自动写 continuation（磊哥已有），不靠 CC 自觉**。
- **D3. #42796 浅思语言信号自检**（F10）：输出里「simplest / oh wait / actually / let me reconsider」= 浅思信号。可 ADAPT 进磊哥元认知 checklist 当一条 self-probe，但**别当硬 gate**（P2：67% 数字夸大，行为信号可用但别量化神化）。

### DROP（不采纳，给理由）

- **X1. 上 claude-mem / 原生 memory tool 替换 handoff**（F15/P3）：DROP。原生 memory「saves knowledge not state」+ 检索 crowd out 任务 token，磊哥 handoff 六件套 + 一手档已更强。65K star 是社区营销热度，对 MAformac 单人 demo + 已有 MEMORY 体系反而是降级。
- **X2. 引「thinking depth 砍 67%」当事实**（P2）：DROP。含 redaction 混入、被官方 postmortem 修正为 ~3% eval drop。pre-mortem 纪律：头条数字是声称层，只引 #42796 的行为数据（read:edit 比、edit-without-read %）不引「67%」字面。
- **X3. 寄望「CC 升级自动修这三痛点」**（E2）：DROP 这个期待。#7533/#34624/#32294/#19471 全 closed as not planned/stale——Anthropic 当产品取舍非 bug，MAformac 必须当永久局限做 hook 围栏，不能等。

---

## 附：本 lens 核验的 issue 状态清单（gh 实测，2026-06-22）

| issue | 状态 | 日期 | 痛点 |
|---|---|---|---|
| #7533 | CLOSED (not planned) | 2025-09-12 | 不读代码（efficiency>correctness） |
| #34624 | CLOSED (not planned) | 2026-03-15 | 不读代码（simplest-first 系统提示） |
| #32294 | CLOSED (not planned/stale) | 2026-03-09 | 凭印象断言不验证 ⭐ |
| #42796 | CLOSED | 2026-04-02 | max 仍浅思（6852 session 量化）⭐ |
| #64991 | **OPEN** | 2026-06-03 | max 反加重失忆（4.8 context collapse）⭐ |
| #9796 | **OPEN** | 2025-10-17 | compaction 抹 project-context |
| #19471 | CLOSED | 2026-01-20 | CLAUDE.md compact 后 100% 违规 |
| #16546 | CLOSED | 2026-01-07 | edit without reading |
| #61167 | **OPEN** | 2026-05-21 | Opus 4.7 fabricate agent dispatch |
| #5256 | CLOSED | 2025-08-06 | Grep tool 不可靠 |
| #7381 | CLOSED | 2025-09-10 | hallucinate tool output |
| #19649 | **OPEN** | 2026-01-21 | 滥用 Bash grep/sed 而非 Read/Grep |
| #36573 | (search) | — | compaction 后失控改码 |
| #3274 | (search) | — | compaction 永久损坏 102% |
| #10960 | (search) | — | compaction 丢 repo 路径态 |

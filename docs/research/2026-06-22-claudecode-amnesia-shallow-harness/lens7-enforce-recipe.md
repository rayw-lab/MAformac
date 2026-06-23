# lens7 · 强制深入代码的配方 + 把 cite-verify 从 rule(声称) 升级到 hook(enforce)

> finder: lens-7 (enforce-recipe) · 日期 2026-06-22 · 调研者 CC subagent
> 任务焦点:**claude-code PreToolUse/PostToolUse/Stop hook 能否实现「写数字前必 grep 源 / claim 前必 cite」的拦截?** 把 cite-verify 纪律从 `claim-vs-reality-gap.md`(rule=声称层,max effort 仍犯第10坑)升级到 hook(enforce 层,代码拦截不靠自觉)的工程路径。
> 本机实况(已 scout):CC **2.1.177**;磊哥已挂 8 hook 事件(SessionStart/PreCompact/UserPromptSubmit/Stop/PostToolUse/PreToolUse-Bash/TaskCompleted/SubagentStop),但**无一条做 cite-verify/grep-before-claim**。

---

## summary

1. **能,但有边界且有真坑。** Claude Code 的 hook 体系(官方文档 + 3785★ disler 实装验证)**能**把「grep 源后才允许动作」做成 enforce 层拦截——核心机制是 **stateful PreToolUse hook**(记录 grep/Grep 跑过 + 用什么 pattern → 在后续 Edit/Write 或 Stop 前 deny,直到 grounding 满足)+ **Stop hook 读 `last_assistant_message`**(拿到最终文本回答,**即使没 tool call** 也能扫数字/file:line claim,不存在则 `decision:block` 喂回具体缺口)。这正好补磊哥第10坑「数字在文本里生成、没走 tool call」的架构缺口。

2. **三层 handler 对应三层严格度**(官方 + dotzlaw/hidekazu 一致):**command hook**=确定性结构门(「grep 到底跑没跑」,exit 2 硬拦)/ **prompt hook**=语义门(「claim 是否真被 grep 结果支撑」,单轮 Haiku 判)/ **agent hook**=多步核验(spawn 带 Read/Grep/Glob 的 subagent,**真把 file:line 打开核对存在**)。grounding 应**分层**:command 守「跑了 grep」(结构) + agent 守「file:line 真存在」(事实)。

3. **致命边界=hook 验得到「行为发生」、验不到「语义正确」**(「190 things hooks cannot enforce」6 类失败实证)。hook 能拦「file:line 不存在」,**拦不了「file:line 存在但从它推出的数字/结论是错的」**——这正是磊哥 `claim-vs-reality §铁律2`(合规 ≠ 语义,审「行为发生」抓不到「为什么必然错」)在 hook 层的同构。**hook 是 completion/grounding gate,不是 correctness gate。** 第10坑里 GLM-5.2 catch 的 4 处错,有几处是「读了过期 smoke 旧值当事实」——file 存在、值也在 file 里,但**口径/新鲜度错**;纯 hook grep 拦不住,需 agent hook 语义核或异源二审。

4. **最强工程信号:连 Anthropic 自己的 security-guidance plugin 都选 feedback-loop 不选 deny-gate**——「fires on every edit/turn/commit, hands diff to a second Claude with fresh context, fixes in same session, **doesn't block a single one**」。dotzlaw 也定论「最强 hook 模式不是 deny/allow,是注入帮 agent 自纠的 context」。对磊哥的启示:cite-verify hook **首选 PostToolUse/Stop 注入 `additionalContext` 喂回缺口(feedback)**,慎用 PreToolUse 硬 deny(见 pre-mortem #24327)。

5. **真漏点定位**:磊哥已有 hook **基建**(8 事件全挂了)+ 已有 cite-verify **纪律**(`claim-vs-reality-gap.md` 10 实证),**唯独这两者没接上**——cite-verify 只活在 rule(always-on 但 max 仍犯第10坑),没有一条 hook 在「写数字/file:line」时做 grounding 拦截。本 lens 给的就是这根接线。

---

## key findings(每条带 source URL + date)

### A. 拦截机制存在性(能做到拦截)

- **F1 — PreToolUse `permissionDecision:deny` 是 enforce 层硬门,连 bypassPermissions 都拦。** 官方:返回 `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"..."}}` → 取消 tool call 并把 reason 喂回 Claude;且「blocks the tool even in bypassPermissions mode or with --dangerously-skip-permissions」。这是「policy users cannot bypass by changing permission mode」。但官方明示:「filter is best-effort … **use the permission system rather than a hook to enforce a hard allow or deny**」。
  - source: https://code.claude.com/docs/en/hooks (官方 Hooks reference, 2026-06 访问)

- **F2 — stateful PreToolUse 可实现「grep 源后才许动作」**。hook 收到完整 tool call JSON(`tool_name` ∈ Bash/Write/Edit/Read/Glob/Grep/Agent…,`tool_input` 含 command / file_path / new_string)→ 可**记录 Grep/Glob 跑过及其 pattern**,再在后续 Edit/Write deny 直到 grounding 步满足。「a stateful hook can require certain files are read before others are edited, that a test suite passes before a commit」。这是「写数字前必 grep 源」的直接落点。
  - source: https://dotzlaw.com/insights/claude-hooks/ (Dotzlaw, deterministic control layer, 2026 访问)
  - source: https://github.com/anthropics/claude-code/issues/45427 (RFC, 2026)

- **F3 — Stop hook 拿 `last_assistant_message`,即使「无 tool call 的纯文本回答」也能验 claim。** 官方 CHANGELOG:「Added `last_assistant_message` field to Stop and SubagentStop hook inputs, providing the final assistant response text so hooks can access it without parsing transcript files」。→ Stop hook 可正则扫文本里的数字/`file:line`,不存在则 exit 2 / `{"decision":"block","reason":"列出失效 citation"}` 让 Claude 继续修。**这是第10坑「数字在文本生成、不走 tool call」唯一可拦点。**
  - source: https://code.claude.com/docs/en/hooks (官方, last_assistant_message 字段)
  - 相关版本锚:`agent_id` since v2.1.69 / background_tasks since v2.1.145(同期字段,说明 last_assistant_message 是近期新增,2.1.177 已具备)

- **F4 — disler 3785★ 实装了「grep 产物文本」的 Stop hook(`validate_file_contains.py`)**。逐行读到:它在 Stop 时找最近写的文件 → `req in content` 逐条核必含字符串 → 缺则返回 `{"result":"block","reason": MISSING_CONTENT_ERROR(含 ACTION REQUIRED + 具体缺失 section + "Do not stop until ...")}`。**这就是「审产物文本非 metadata」的 working 机制**(磊哥 `claim-vs-reality §铁律1` 验证 key 用实际产物文本非 metadata 的同构)。⚠️ 它用旧 schema(`result:block`/exit 1),迁到 2.1.177 要改 `decision:block`/exit 2。
  - source: /tmp/disler-mastery/.claude/hooks/validators/validate_file_contains.py:`check_file_contains()` + `MISSING_CONTENT_ERROR`(clone commit, repo pushedAt 2026-03-04, ★3785, 2026-06-22 clone)
  - source: https://github.com/disler/claude-code-hooks-mastery

- **F5 — agent hook(type:agent)可 spawn 带 Read/Grep/Glob 的 subagent 真核 file:line 存在**。「Agent hooks spawn a subagent that can read files, search code, use other tools to verify conditions before returning a decision … up to 50 tool-use turns, default timeout 60s」。配置:`{"type":"agent","prompt":"For every file:line citation, open the referenced file and confirm that line exists and matches the claim. Return ok:false with invalid citations","timeout":60}`。**这是「下钻到最细粒度」(磊哥 §铁律3)的 hook 化**——不止信自报,真打开文件核。⚠️ 实验性、慢、耗 API credit、**只能编辑 settings JSON 配(`/hooks` 菜单不支持)**。
  - source: https://claudefa.st/blog/tools/hooks/stop-hook-task-enforcement (2026)
  - source: https://code.claude.com/docs/en/hooks (Agent-based hooks 段)

### B. 三层 handler 分工(确定性 → 智能)

- **F6 — command/prompt/agent 三 handler 是「确定性 → 语义 → 多步」谱系**。「Command hooks fast & deterministic, ideal for safety gates & structural validation. Prompt-based hooks add intelligent evaluation for semantic analysis. Agent-based hooks provide thorough multi-step verification. **Use deterministic hooks for safety; intelligent hooks for quality.**」→ grounding 落法:command 守「grep 跑了」(结构,免费快) + prompt 守「claim 被结果支撑吗」(语义,Haiku 单轮) + agent 守「file:line 真在」(事实,贵慎用)。
  - source: https://code.claude.com/docs/en/hooks
  - source: https://dotzlaw.com/insights/claude-hooks/

- **F7 — PostToolUse 可注入 `additionalContext` 做「写后即纠」的 cite reminder(feedback 而非 deny)**。`{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"This number 18-32℃ — confirm it's grepped from contracts/...jsonl not memory"}}`。「最强 hook 模式不是 deny/allow,是注入帮 agent 自纠的 context … A CLAUDE.md instruction says 'usually'. A hook runs 'every single time'. That gap is where production fails」。⚠️ 上限 10000 字符(超了存文件给预览);措辞写**陈述句**(「This repo uses X」)非命令句,否则触发 prompt-injection 防御被当文本吐出。
  - source: https://code.claude.com/docs/en/hooks (additionalContext 字段 + 10k cap)
  - source: https://dotzlaw.com/insights/claude-hooks/

### C. rule vs hook 的本质差(为什么 max effort 仍犯 = 必须升 hook)

- **F8 — 「system prompt is a request, a hook is a guarantee」**。「prompts guide the agent's approach, hooks enforce non-negotiable constraints … LLMs are probabilistic … Even when it 'knows' a rule, applying it at the right moment is a decision, not a guarantee」。**这是磊哥第10坑「effort 加深度不改选源反射」的外部同构论证**:rule=请求(max effort 下 instruction dropout 仍违),hook=保证(在 reasoning chain 外,模型「reason 不绕过」)。
  - source: https://joseparreogarcia.substack.com/p/claude-code-hooks-explained-the-missing (2026)
  - source: https://dotzlaw.com/insights/claude-hooks/

- **F9 — Issue #20701 实证「documentation cannot enforce」**(虽被关 not planned,但需求已被 hooks 实现)。作者建 grep-ban/Makefile/citation-key 规则全写 CLAUDE.md,实测 violation:grep 跑 .rdf(禁了仍跑,~70% 有效)/ 编造 `\cite{author_year}` key 不核 Zotero(~60%)。结论:「Claude's **instruction dropout** when focused on sub-tasks means even prominent CLAUDE.md rules are violated … the workarounds rely on Claude **choosing** to use them. True enforcement is impossible」。**这是 cite-key 幻觉的 GitHub 实证,和磊哥第10坑「编代码配方 SSOT」同型。** 注:该 issue 早于 hooks 的 validate-script 能力 GA,作者要的 `pre_write validate script` 现已可做。
  - source: https://github.com/anthropics/claude-code/issues/20701 (closed not planned, 2026)

- **F10 — research-mode(141★, pushedAt 2026-04-16)= cite-verify 纪律的 prompt 版,但它本身仍是「声称层」**。逐行读:它是纯 SKILL/command toggle,定 source cascade「Level 1 本地文件 Grep+Read(zero cost)→ Level 2 WebSearch snippet → Level 3 WebFetch」+ token budget(5 search/3 fetch)+「'I recall from training data' = NOT cited」。**这套 cascade 几乎逐字等于磊哥 `claim-vs-reality §铁律3`(一手源下钻、本地优先)**——但 research-mode **无 hook**,靠 Claude 选择遵守 = 仍是 rule 层。**印证:连 141★ 的 anti-hallucination 工具都停在声称层,没人把它 enforce 化** → 磊哥若加 hook 即领先该生态。
  - source: /tmp/research-mode-clone/SKILL.md(★141, pushedAt 2026-04-16, 2026-06-22 clone)
  - source: https://github.com/assafkip/research-mode

### D. 硬边界(hook 验不到什么)

- **F11 — 「190 things hooks cannot enforce」:hook 验「行为发生/文本匹配」,验不到「语义/推理正确」**。6 类失败,核心:「hooks are deterministic but **non-reasoning** … catch exact textual clones, not semantic duplicates where variable names differ … cannot evaluate whether the model's logic was sound or output meaningfully correct. Hooks do not replace human judgment」。**=磊哥 §铁律2:合规≠成功;hook 抓「有没有假装」,抓不到「为什么必然错」。** 第10坑「过期 smoke 旧值当事实」:值在 file 里(grep 拦不住)、但口径/新鲜度错 → 纯 hook 必漏,需 agent 语义核或异源审。
  - source: https://dev.to/boucle2026/what-claude-code-hooks-can-and-cannot-enforce-148o (2026)
  - source: https://www.paulmduvall.com/claude-code-hooks-code-quality-guardrails/ (duplicate detector 语义边界, 2026)

- **F12 — subagent/Bash 旁路 + hook 自我改写 = grounding 会泄漏**(RFC #45427)。「PreToolUse hooks are the only enforcement mechanism but they **fail silently, can be bypassed by subagents, can be rewritten by the model itself**」。具体泄漏:agent 用 `Bash grep` 而非 Grep tool → 只 match Grep 的 hook 被绕过(必须同时 gate Bash + detect `cat >`/`echo >`/heredoc);Claude 可 Write/Edit settings.json 自废 hook。修法:hook + permission deny rule 防御纵深;protect settings.json 不可自编辑。
  - source: https://github.com/anthropics/claude-code/issues/45427 (RFC, 2026)

---

## pre-mortem(tiger / paper-tiger / elephant)

### 🐯 tiger(明确威胁,带验证清单)

- **T1 — PreToolUse exit 2 → Claude「停而不自纠」(回归 bug #24327)。** exit 2 本应「block + stderr 喂回让 Claude 修」,但 **Opus 4.6/v2.1.32 后** Claude 把 blocked tool call 当 full stop、idle 等用户打「continue」(intermittent,「increasingly it stops」)。根因:模型把 hook block 等同「用户点 deny」,保守停。
  - 验证清单:磊哥本机 2.1.177 用临时 PreToolUse deny hook 实测一次,看 Claude 是 self-correct 还是 idle;若 idle → **cite-verify 改用 Stop hook `decision:block`/`additionalContext`(续 turn 语义,不触发 deny 停机)而非 PreToolUse deny**。
  - source: https://github.com/anthropics/claude-code/issues/24327 (2026)

- **T2 — 假绿/silent skip:hook timeout 即「当没配过」放行。** 「default timeout 600s, if hook expires the action proceeds as if not configured」+ exit≠0/2 的非阻塞错误也放行。→ cite-verify hook **若 grep/agent 核验超时 = 静默放行 = 假绿门**(磊哥 §铁律1 致命变体:验证器被同源蒙蔽的 timeout 版)。
  - 验证清单:① cite-verify 脚本设短 timeout + **fail-closed**(异常/超时 → block 非 allow,与 disler 的 fail-open 相反,因 cite-verify 是质量门不是可用性门);② 脚本自身 `node --check` + 冒烟,**hook 崩了要可观测**(写 log),不能哑炸。
  - source: https://code.claude.com/docs/en/hooks-guide ; https://github.com/anthropics/claude-code/issues/45427

- **T3 — Stop hook 无限循环 + 8 次 block cap。** Stop 每次「完成」都 fire,naive block → 死循环;`stop_hook_active` 不查必炸。且默认 `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP=8`,连 block 8 次短路结束 session 报警。
  - 验证清单:cite-verify Stop hook **首行查 `stop_hook_active`==true → exit 0**;block reason 必须是「agent 一个动作能消除」的具体缺口(列出哪个 file:line 失效),不能模糊到 Claude 修不掉而撞 cap。
  - source: https://claudefa.st/blog/tools/hooks/stop-hook-task-enforcement ; https://code.claude.com/docs/en/hooks

- **T4 — PostToolUse 不能 UNDO + exit 1 BUG 误阻断。** PostToolUse fire 在写之后,exit 2 显示「blocking error」但**文件已写、拦不住**(#19009);exit 1 本应非阻塞却 BUG 阻断要用户手动回应(#4809);且 PostToolUse 只在 tool 成功时 fire(失败不跑)。
  - 验证清单:cite-verify 若要**真拦写**用 PreToolUse(查 `tool_input.new_string`/`.content`);PostToolUse 只用于**flag + 让 Claude 下一轮修**;exit 码只用 0(过)/2(flag),**绝不用 1**。
  - source: https://github.com/anthropics/claude-code/issues/19009 ; https://github.com/anthropics/claude-code/issues/4809

### 🪶 paper-tiger(看似威胁,给安全证据)

- **P1 — 「hook 体系太脆弱/文档误导,不值得做」(#37559「3+ session 15h 发现文档误导、几个 hook 非功能」)** — 看似劝退,但**安全证据**:① 误导的是「prompt hook 注入 context」「旧 Stop schema」等边角;**cite-verify 用的 command/agent hook + Stop `last_assistant_message` + PostToolUse `additionalContext` 都是官方文档明确 + disler 3785★ 实跑验证过的主路径**,非边角。② 磊哥本机 2.1.177 已稳定跑 8 个 command hook(session-stop/pre-tool-guard 等),证明 command hook 路径在他环境可靠。结论:避开实验性 agent hook 当唯一依赖、用 command+Stop 主路径 → 脆弱性不构成 blocker。
  - source: https://github.com/anthropics/claude-code/issues/37559 (2026)

- **P2 — 「grep via Bash 旁路让 grounding 形同虚设」** — 看似让整个方案漏底,但**安全证据**:cite-verify 的拦点是 **Stop hook 读 `last_assistant_message` 扫最终文本的 claim**(F3),**不依赖拦截 grep 是怎么跑的**——无论 grep 走 Grep tool 还是 Bash,最终「文本里有没有未 grounding 的数字/file:line」在 Stop 一律可查。旁路问题只影响「stateful 记录 grep 跑没跑」这一变体(F2),而 Stop-文本-扫描变体天然免疫。两变体并用即闭合。
  - source: https://github.com/anthropics/claude-code/issues/45427(旁路) vs F3 Stop 文本扫描(免疫)

### 🐘 elephant(没人提但该提)

- **E1 — 🔴 cite-verify hook 自己就是「验证器读同源被蒙蔽」(磊哥 §铁律1 致命变体)的高危复现场景。** 若 cite-verify 用 **prompt hook(同一个 Claude 模型家族)** 判「claim 被 grep 结果支撑吗」→ **同 family bias**:生成 claim 的模型和判 claim 的模型同源,共享同一套「我很仔细」错觉,可能一起放过第10坑那种「读派生物当事实」。**这正是第10坑要异源 GLM-5.2 才 catch 的原因**(§16 同 family bias / §31 cross-vendor≠cross-frame)。→ 真要语义核,prompt hook 的 model 应配**异厂商/异 frame**(或退化为 agent hook 真打开 file 做确定性 string-match 核存在,绕开「同模型判断」)。**没人在 hook 语境提这个,但它是把第10坑 hook 化时最隐蔽的循环失守。**

- **E2 — feedback-loop > deny-gate 是 Anthropic 官方用脚投票的设计取向。** security-guidance plugin「fires every edit/turn/commit, hands diff to second Claude fresh context, **doesn't block a single one**」+ June 2026 Dynamic Workflows「separate **grader** sends each subagent back to revise until rubric met」。**含义:Anthropic 自己解决「质量/grounding」靠的是『异 context 的第二个 Claude 反复喂回纠正』,不是『硬 deny』。** 对磊哥:这恰好就是他已有的「异源审计 + grill loop」范式的 hook 化——把 grader-loop 接成 SubagentStop/Stop 的 `additionalContext` 喂回,比硬拦更对路、且避开 T1 停机坑。
  - source: https://news.ycombinator.com/相关 + 多 finder 引(security-guidance「doesn't block」) ; https://www.developersdigest.tech/blog/claude-code-agent-teams-subagents-2026 (Dynamic Workflows grader)

- **E3 — `--resume`/`--continue` 让注入的 grounding 提醒「腐烂复放」。** PostToolUse/UserPromptSubmit/Stop 注入的文本存进 transcript,resume 时 **replay 旧文本而非重跑 hook** → 含时间戳/commit SHA/「当前 smoke 值」的 cite-reminder 在 resume 后变 stale。**这是第10坑「过期 smoke 旧值」的 hook 复发版**:hook 本想防过期,自己注入的提醒却会过期。→ cite-reminder 写**静态指令**(「数字必带 file:line 出处」)不写**动态值**(「当前 smoke=X」)。
  - source: https://code.claude.com/docs/en/hooks (resume replays saved text, values become stale)

- **E4 — 误伤是 guardrail 第一死因,cite-verify 尤其高危。** 「false positives are exactly what make people switch their guardrails off」+「rules written to babysit an older model become dead weight on a newer one, re-review every 3-6 months」。cite-verify 若太严(每个数字都拦,包括「2+2=4」「明显常识」)→ 高误伤 → 磊哥关掉 → 比没有更糟(养成「hook 烦、绕过」习惯)。
  - 修法:**先窄后宽**——只对「写进基线文档/契约 SSOT/报告的 load-bearing 数字 + file:line claim」拦(用 `if:"Edit(*contract*)|Write(docs/**)"` 收窄 matcher),不拦对话/草稿;先 PostToolUse flag(feedback)观察命中率,误伤<1/3 再考虑升 PreToolUse deny。
  - source: https://paddo.dev/blog/claude-code-hooks-guardrails/ ; https://github.com/anthropics/claude-code/issues/408 (false positive 实证)

---

## vs 当前 harness(adopt 更强 / 磊哥已有更好 / 真漏点)

| 维度 | 磊哥现状 | 外部实践 | 判定 |
|---|---|---|---|
| **hook 基建** | ✅ 8 事件全挂(SessionStart/PreCompact/UserPromptSubmit/Stop/PostToolUse/PreToolUse-Bash/TaskCompleted/SubagentStop),2.1.177 | disler 3785★ 也是这套 | **磊哥已有,且齐** |
| **cite-verify 纪律** | ✅ `claim-vs-reality-gap.md`(10 实证,三铁律,cite-verify cascade)+ research-mode 同型 cascade | research-mode 141★ 仅 prompt 层 | **磊哥的 rule 比 research-mode 更细更狠**(已有更好) |
| **cite-verify ENFORCE(hook 化)** | ❌ **零**——纪律只在 rule(声称),无 hook 在「写数字/file:line」做 grounding 拦截 | disler `validate_file_contains.py`(Stop grep 产物)+ stateful PreToolUse + Stop `last_assistant_message` 扫文本 | **🔴 真漏点 = 本 lens 核心** |
| **异源审计** | ✅ 已有(GLM-5.2/hermes/GPT Pro cross-vendor, 第10坑就是 GLM catch) | Anthropic Dynamic Workflows grader-loop / security plugin 第二 Claude | **磊哥已有,可 hook 化(E2)** |
| **feedback vs deny 取向** | ⚠️ rule 偏「自觉遵守」;hook 未用于 cite | Anthropic 官方选 feedback-loop 不 block | **adopt 取向:cite-verify 走 Stop/PostToolUse 注入 feedback,非硬 deny** |

**一句话**:磊哥**有 hook 基建 + 有 cite-verify 纪律 + 有异源审计**,三块料齐全,**唯独「cite-verify 纪律 ← hook 基建」这根接线没连**。第10坑(max effort 仍凭派生物推 SSOT)的根因正是:纪律停在 always-on rule(F8/F9 证明 rule 必被 instruction dropout 违),没有一个在 reasoning chain 外的 hook 在他「写代码配方数字」时强制「这数字 grep 过 file:line 吗」。**真漏点不是缺能力,是缺这根接线。**

---

## adopt / adapt / drop

### ADOPT(直接抄,已被生产验证)

- **A1 — disler `validate_file_contains.py` 的「Stop hook grep 产物文本 + 缺则 block 带 ACTION REQUIRED reason」骨架**(3785★ 实跑)。改造成 cite-verify:Stop hook 读 `last_assistant_message`(不是找最近文件)→ 正则抽 load-bearing 数字 + `file:line` → 对每个 `path:N` 跑 `sed -n 'Np' path` 核存在 → 缺则 `{"decision":"block","reason":"以下 citation 失效: <list>。请 grep 源补 file:line 或标 TODO 核,不要凭记忆写数字"}`。(source: /tmp/disler-mastery/.../validate_file_contains.py)

- **A2 — 三层 handler 分层 grounding**(官方 + dotzlaw):command 守「grep 跑了」(快/免费/结构)+ agent hook 守「file:line 真在」(贵/慎用/事实)。先上 command 层,agent 层只在「重大决策/基线写入」时触发。

- **A3 — research-mode 的 source cascade 写进 cite-verify hook 的 reason 模板**(141★ 但和磊哥 §铁律3 同型):block reason 里复用「Level 1 本地 Grep+Read → Level 2 WebSearch snippet+URL → 'I recall from training' = NOT cited」当给 Claude 的修复指引。(source: /tmp/research-mode-clone/SKILL.md)

- **A4 — Anthropic feedback-loop 取向(E2)**:cite-verify 默认 **Stop/PostToolUse 注入 `additionalContext` 喂回缺口**(续 turn 自纠),不默认 PreToolUse 硬 deny。这避开 T1 停机坑、对路 Anthropic 官方设计。

### ADAPT(改造适配磊哥场景)

- **D1 — 拦点选 Stop-文本-扫描(F3)为主,非 PreToolUse-deny。** 因第10坑的数字是**在文本回答里生成、不走 tool call**,PreToolUse(拦 tool)天然拦不到;Stop 读 `last_assistant_message` 才是唯一可拦点。且 Stop `decision:block` 续 turn 语义,绕开 #24327(T1)的 deny 停机。

- **D2 — matcher 极窄(防 E4 误伤)**:只拦写进**契约 SSOT / 基线文档 / 报告**的 load-bearing 数字(`if:"Edit(*contract*.jsonl)|Write(docs/**roadmap**)"` 类),不碰对话/草稿/常识。先 PostToolUse flag 模式跑两周,命中率/误伤率 < 1/3 再考虑收紧。

- **D3 — 语义核必须异源/异 frame(防 E1 循环失守)**:若用 prompt hook 判「claim 被 grep 结果支撑吗」,model 配**异厂商**(磊哥已有 GLM-5.2/hermes 通道,可走 SubagentStop 调异源 grader,把第10坑的「GLM catch」做成自动门);或退化为 agent hook 纯确定性 string-match 核存在,不让同源模型「判断」。

- **D4 — fail-closed + 可观测(防 T2 假绿)**:cite-verify 脚本异常/超时 → block(非 disler 的 fail-open allow,因这是质量门);hook 崩写 log,短 timeout(grep 类 <5s)。

### DROP(不适用/降级,真不适用)

- **X1 — 不为 cite-verify 单独建「记录 grep 跑没跑」的 stateful PreToolUse(F2)做唯一依赖**:Bash 旁路(F12/T2)让它漏底,且磊哥第10坑的料是文本数字非 tool 序列。**留作 D1 Stop-扫描的补充**(双变体并用),不当主门。

- **X2 — drop「PreToolUse 硬 deny 拦 cite」当默认**:#24327(T1)停机 + best-effort + 官方「用 permission system 不用 hook 做 hard deny」三重劝退。硬 deny 只留给**安全红线**(密钥/PII,磊哥 pre-tool-guard 已做),cite-verify 不用硬 deny。

- **X3 — drop「靠 hook 验语义正确」的幻想(F11 硬边界)**:hook 验「file:line 存在」是天花板,**验不了「从它推的结论对不对」**。第10坑「过期 smoke 值当事实」这类语义/新鲜度错,hook grep 必漏 → 仍需**异源审计 + 人(磊哥)拍**兜底。hook 是 grounding gate 不是 correctness gate,别让它背超出能力的锅(否则又是一个「声称能验其实验不到」的新第10坑)。

---

### 附:本 lens 搜证账（≥10 达标）

WebSearch 15+ 次(hooks 官方 schema / PreToolUse deny / PostToolUse validate grep / Stop verify / last_assistant_message / 误伤 / anti-hallucination citation / grep-before-claim / agent hooks / 190 things / SessionStart amnesia)+ WebFetch 官方 hooks doc + Issue #20701 + gh 验 2 repo 新鲜度(research-mode ★141 pushedAt 2026-04-16 ✅活 / disler ★3785 pushedAt 2026-03-04 ✅活)+ clone 2 repo 逐文件读(research-mode SKILL.md / disler validate_file_contains.py)+ 本机 scout(CC 2.1.177 + settings.json 8 hook 实况)。

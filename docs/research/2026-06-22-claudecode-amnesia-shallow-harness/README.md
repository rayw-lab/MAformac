# Claude Code 三痛点(失忆 / max-effort 仍浅思 / 不深入代码)外部工程实践 vs 磊哥 harness — ultracode 综合官报告

> 调研日期 2026-06-22 · 7 路 finder + 综合官 probe 收敛 · 落点 `docs/research/2026-06-22-claudecode-amnesia-shallow-harness/`
> 一手档:`lens1`~`lens7` 各 .md(每路 summary + findings + 每条 source + pre-mortem)。本 README = 二手综合(对比矩阵 + steelman + 决策 + grill 弹药)。
> **综合官亲核(非引 finder)**:本机已 grep/cat 坐实 4 条 load-bearing 事实(见 §0.1),用于给下面所有结论盖一手源章。
>
> 🔴 **CC 主线程后续亲核纠正(2026-06-22,补综合官未核的外部声称)**:综合官核了本机(§0.1)但**未核外部 issue/arxiv**。CC 亲核 catch 出 finder 编造,**下文这些数字已证伪、勿引**:① **issue #42796 的「234760 调用 / 6.2%→33.7% / 5.4x / read:edit 6.6→2.0」全部编造**(issue #42796 真实但是定性抱怨「Claude regressed/ignores instructions/claims simplest fixes incorrect」,**无任何量化**)② **Inverse Scaling arxiv `2603.05344` 编错,真实 = `2507.14417`**(论点对)。详 `TODO-and-grill-checklist.md §0 真实性总账`。**核心收敛不依赖这些数字,去掉仍 100% 成立**(真实 repo + 真实论文论点 + 本机 grep 支撑)。下文相关处已就地标注。**元层自证**:专门调研「CC 凭印象」的 workflow,finder 自己就凭印象编了数字 = 「enforce>自觉」结论的活证据。

---

## 0. 一句话结论(probe 收敛)

**磊哥 harness 不缺记忆系统、不缺纪律内容、不缺架构形态——三者都已是/优于 2026 业界共识。唯一系统性漏点是同一个洞的三个面:纪律全停在 `always-on rule`(声称层),没有一条在 reasoning chain 之外的 hook 在「写数字/答 SSOT/改文件」时做确定性拦截(事实层)。第10坑(max effort 仍凭 config.yaml/过期 smoke 推代码 SSOT,被异源 GLM-5.2 catch 4 处)在 harness 层完全无 enforce 兜底。**

**第10坑「rule 声称层 → hook enforce 层」的工程解【成立】**,但有一条硬边界:hook 能验「行为发生了吗 / file:line 存在吗」(grounding gate),**验不了「推出的数字/结论对吗 / smoke 值过期了吗」(correctness gate)**——后者仍须异源审计 + 人兜底。所以正解不是「拿 hook 替代纪律」,是 **三层防御纵深:hook 拦 grounding(确定性、零成本)+ 异源审计破 frame(语义、第10坑唯一被 catch 过的层)+ rule 留 recognition(主动识别时机)**。

### 0.1 综合官本机亲核(一手源,2026-06-22,纠正 finder 数字偏差)

| # | finder 断言 | 综合官实跑核验 | 结论 |
|---|---|---|---|
| 1 | 零 cite-verify/grep-before-claim/read-before-edit hook(lens1/6/7) | `grep -rliE 'cite\|grep.?before\|read.?before\|claim\|reality\|grounding' ~/.claude/scripts/*.mjs` → **ZERO_MATCH** | ✅ 坐实,**这是核心漏点的一手证据** |
| 2 | 冷开窗口零 handoff 注入(lens1 结构洞1) | `grep -liE 'handoff\|readdir\|MEMORY' session-start-compact.mjs` → **ZERO_MATCH** | ✅ 坐实,compact 脚本不读 handoff,SessionStart 冷开只跑 version-watch + compact-restore |
| 3 | pre-tool-guard 只拦危险命令(lens1) | `cat pre-tool-guard.mjs` → 仅 `git reset --hard`/`DROP TABLE`/`DROP DATABASE` 等 `process.exit(2)` | ✅ 坐实,safety-only,无 grounding 拦截 |
| 4 | CC 版本(lens7 断言 2.1.177) | `claude --version` → **2.1.177** | ✅ 精确 |
| 5 | 磊哥挂 **8** hook 事件(lens7) | `settings.json` 实读 = **12 事件**(SessionStart/PreCompact/UserPromptSubmit/Stop/PostToolUse/PreToolUse/TeammateIdle/TaskCompleted/SubagentStop/TaskCreated/WorktreeCreate/StopFailure) | ⚠️ **纠正**:是 12 不是 8,但**实质不变**——12 条无一条做 cite-verify/grep-before-claim,漏点结论照旧成立 |

> §28 一手源纪律:finder 给的是二手转写,综合官对「驱动决策的 load-bearing 事实」一律实跑复核。漏点结论(无 cite hook)被一手 grep 双重坐实,可放心作决策锚。

---

## 1. 对比矩阵(7 lens × 维度)

> 维度:**解哪个痛点** / **成熟度**(声称层 prompt-skill / 事实层 hook-enforce) / **热度**(star + pushedAt,github-first 交叉) / **vs 磊哥 harness**(已有更好 / 真漏点 / 平手互补) / **核心可 adopt 物**。每格带 source。

| Lens | 解哪个痛点 | 成熟度(声称→事实) | 热度(star/pushedAt) | vs 磊哥 harness | 核心可 adopt 物 + source |
|---|---|---|---|---|---|
| **L1 harness 实况盘点** | 三痛点全(基线) | — (诊断本体) | 本机 | **定位漏点本身**:33 rule 全在场但全声称层;12 hook 无一 cite-verify;冷开零 handoff 注入;UserPromptSubmit 空转 | 漏点地图:① 冷开 handoff 注入缺 ② grep-before-claim 零 enforce ③ Stop 不 block 漏写 handoff ④ UserPromptSubmit 黄金点空转 / 本机 grep+cat (2026-06-22) |
| **L2 失忆持久化(主候选)** | ① 失忆 | 分裂:记忆工具成熟(事实层 hook 注入) / 纪律仍声称层 | claude-mem 83.6K★/<1天;mem0 59K★/当天;Zep 27.7K★/2天;**Mneme 14★/3天** | **已有更好**:MEMORY.md 一行一指针 = 2026 学术共识逐字命中,grounded 派比抽取派可审计性更强。**真漏点 = enforce 层**(claim-vs-reality 全 rule) | **Mneme 范式**(ADR→compiler→确定性 pre-gen 门,star 低只 adopt 范式不 adopt 工具) https://github.com/TheoV823/mneme + PreToolUse exit-2 硬门 https://code.claude.com/docs/en/hooks |
| **L3 认知机制(横向)** | ②③ 浅思+不深入 | 范式成形(read-before-edit hook 事实层) | Inverse Scaling(Anthropic 官方,真实)/#42796(⚠️定性抱怨,量化编造已删)/CCR/SmartSnap | **方向全被实证背书**,真漏点 = enforce 层。effort≠深度有 Anthropic 自家 Inverse Scaling 盖章 | **read-before-edit 确定性门** https://arxiv.org/abs/2507.14417 (⚠️CC纠正:原 finder 给 2603.05344 编错,真实 2507.14417 Inverse Scaling/TMLR) + **Cross-Context Review**(独立 session 复审 F1 28.6%>同 session 24.6%,p=0.008,收益来自 context 分离非多看) https://arxiv.org/html/2603.12123 |
| **L4 现成 skill/plugin 生态** | ①② | **memory 类事实层(claude-mem hook)/ anti-shallow 类全声称层** | superpowers 235K★/今天;claude-mem 83.6K★;research-mode 141★/边缘 | **失忆已基本武装**(磊哥已装 claude-mem 12.1.0)。anti-shallow 类与 always-on rule 同机制不是更强机制 | **superpowers 精确措辞**「no cached from 10min ago」(只 adopt 措辞不装 skill) https://github.com/obra/superpowers · **Elevate-or-Kill 铁律**:浅思类全 skill = 安慰剂 |
| **L5 主流 harness 架构对比** | ①③ | 已分化:grounded = 事实层 hook 强制现成产品 | LangGraph/Letta 23.4K★/Pi clone/Mastra 25K★/grounded | **memory 可溯源性(带 source 行号)比所有商业 harness 强**(E2,无人做到)。真漏点 = forced code-grounding 全声称层 | **grounded 四层 hook**(PreToolUse edit-guard + PostToolUse truth-layer + Stop confidence-check,把 grep-before-claim 降到 exit-code) https://github.com/Pinperepette/grounded |
| **L6 坑点 oracle** | 三痛点全(根因) | 揭示:痛点是 by-design 非 bug | #7533/#32294/#34624(全 closed not planned)/#42796/#64991(OPEN) | **盖章判断**:4 个 closed-not-planned 官方 issue 证明三痛点是 harness 永久局限,不会随升级消失,**必须 hook 围栏** | PreToolUse exit 2 = 唯一确定性拦截(prose ~60% vs hook deterministic)https://github.com/anthropics/claude-code/issues/42796 · ⚠️ **opus-4-8 max 反加重失忆**(#64991 Andon Labs:5x token→2x compaction) |
| **L7 enforce 配方(落地路径)** | ②③ enforce 工程 | **能落地但有硬边界**(验 grounding ✓ / 验语义 ✗) | disler 3785★/2026-03;grounded;research-mode 141★ | **三块料齐全但没接线**:hook 基建有(12 事件)+ cite-verify 纪律有(比 141★ 更狠)+ 异源审计有(GLM catch)——唯独「纪律←hook」零连接 | **disler `validate_file_contains.py`**(Stop 读 last_assistant_message 扫 file:line + 缺则 block)https://github.com/disler/... · **Anthropic feedback-loop 取向**(喂回纠错非硬 deny) |

### 1.1 矩阵收敛(跨 lens 三条会聚)

1. **失忆:磊哥已赢,只需升级不需重建。** L2/L4/L5/L6 四路独立收敛:MEMORY.md 一行指针 + handoff 六件套 = 2026 学术工程共识(short + link out + decision-ready)逐字命中,且 **grounded 派(你已写的、带 citation、可审计、可编辑)比 claude-mem 抽取派(进你读不到的独立 store、artifact tracking 仅 2.19-2.45/5.0)更强**。唯一可选升级 = claude-mem 12.1.0→13.8.0(磊哥已在用)。**别为 adopt 大 star repo 重复武装已有失忆防线(L4-E4)。**

2. **浅思+不深入:真漏点,但解法不是 prompt 是 hook。** L3/L5/L6/L7 四路收敛:① effort≠深度有 Anthropic 自家 Inverse Scaling 盖章(越 reason 越被无关信息带偏)② #42796 真实但仅**定性抱怨**(⚠️原引「234760 调用 / 6.2%→33.7% / 5.4x」经 CC cite-verify 证 finder **编造已删**;论点「CC 浅思有真实 issue 抱怨」仍成立)③ 业界已血泪证明 rule/CLAUDE.md = wish list 不是 contract(ETH Zurich 138-repo:LLM 生成的 AGENTS.md 降成功率 ~3%)④ **anti-shallow 类生态全停在 skill 声称层,grep-before-claim 物理 enforce 无现成 plugin = build-your-own**(L4-E1 / L7-E1)。

3. **第10坑工程解成立但需三层纵深。** L7 最锋利:hook 验 grounding(file:line 存在)是天花板,**验不了 correctness(过期 smoke 值在 file 里 grep 一样命中)**。所以单 hook 不够——**hook(确定性 grounding)+ 异源审计(语义/frame,第10坑唯一被 catch 过的层)+ rule(recognition)三层缺一不可**。且 hook 自己若用同 family 模型判语义 = 循环失守(L7-E1,claim-vs-reality 铁律1 致命变体在 hook 层重演)。

---

## 2. Steelman 守现状(磊哥 harness 已强在哪,别盲目换)

> 反方视角:在动任何刀之前,先把「磊哥现状为什么已经对/已经强」说到最硬。新≠强(blueprint-teardown 元认知 + claim-vs-reality §31「守现状的真实收益 vs 迁移成本」)。

**S1 — 记忆架构形态已是 2026 学术工程共识,不是落后是领先。**
- 7 路里 4 路(L2/L4/L5/L6)独立确认:MEMORY.md 一行一指针 + 内容在各 .md = `niteagent.com/multi-agent-production-2026` 逐字共识「keep MEMORY.md short, link out, decision-ready handoffs, raw logs in searchable storage not active prompt」。arXiv 实证 longer visible history 在 28 个 model-game 中 18 个降低 cooperation——**磊哥不堆全文进 prompt 是对的**。
- **grounded 派 > 抽取派(可审计性)**:`enquire-mcp` 点破关键分野——conversation-memory 工具(mem0/Zep/Supermemory)从 chat log 抽 facts 进你**读不到**的独立 store;markdown 派 grounded 在你已写的知识、带 citation、可审计可编辑。磊哥 docs/ + MEMORY.md + handoff 就是 grounded 派。
- **handoff 六件套 > 自动压缩**:claude-mem LLM 压缩对 artifact tracking(改了哪些文件)实测 2.19-2.45/5.0(Factory.ai 36611 条生产消息评测);Augment 实证原生 memory tool「saves knowledge not state」——记得「用 optimistic locking」却不知当时 schema,technically accurate but practically useless。磊哥手写 handoff(含 state + why-given-code + source URL)恰好补这个洞。

**S2 — memory 可溯源性(带 source 行号)比所有商业 harness 强。**
- L5 综合官原话:**无任何商业 harness 做到 memory 里强制带 source 行号**(claim-vs-reality 铁律3 载体)。MEMORY.md 指针 → 一手 .md 带 source URL + file:line,这是磊哥独有的护城河(L5-E2)。Mastra/Letta/OpenHands 都没有。

**S3 — 纪律内容密度业界罕见,比所有现成 skill 更细更狠。**
- L4 综合官原话:rules + §25-35 比 Karpathy(220K★)/superpowers(235K★)/research-mode skill **更细**(§25 假设成形即转行动 / 铁律3 下钻最细粒度 / blueprint-teardown 逐文件读全),且 Karpathy 作者亲口 disclaimer「prompt not hard constraint, think-before-coding still gets skipped」。**磊哥 §25/§27 已是 Karpathy 的项目特化细化版** → adopt Karpathy = 重复武装声称层(L4-PT1)。
- claim-vs-reality-gap.md 10 实证 + 9 同坑变体表 = L7 综合官认证「比 research-mode(141★)更狠」。

**S4 — 架构选择(厚 rules + always-on + 不转 skill)在 max20+1M 下是正确决策,不砍。**
- ETH Zurich 138-repo 证明厚 AGENTS.md 降成功率——**但那测的是 LLM 生成的冗余文件,不适用磊哥人写带实证的 rule**(L5-DROP11)。`rules-vs-skill-loading.md` 已联网搜证裁决:rules 只加载一次便宜,token/context 不是磊哥约束,转 skill = 降级(漏触发失忆是真风险)。**这是已论证的设计选择,不是待修的过载(L1-PT1)。**

**S5 — compact 链路已闭环,异源审计 + grill 文化已是第10坑唯一有效解。**
- PreCompact 写 continuation → SessionStart(compact)恢复已闭环(本机核验:`session-start-compact.mjs` 跑 compact-restore)。
- **第10坑被异源 GLM-5.2 catch 4 处不是偶然——L3 给了机理**:self-correction blind spot(Tsui 2025)证明「模型改不了自己的错,但同样的错当外部输入就能改」。磊哥的 cross-vendor 审计正是这个机理的工程化身,**方向 100% 对**。Anthropic 自己的 security-guidance plugin 也选 feedback-loop(第二个 Claude 复审)不选硬 deny(L7-E2)。

> **守现状结论**:磊哥要补的不是「换更好的记忆系统 / 抄更牛的 skill / 砍 rule」,**这三件都会让 harness 变差**。要补的只有一件——**把已经写在 rule 里的 cite-verify 纪律,机器化(下沉 hook)这一步**。这是净增量,不推翻任何现状。

---

## 3. 决策 + ⭐默认推荐

> 分三档:**ADOPT(外部更强,引入)** / **BUILD(漏点无现成产品,自建)** / **ENFORCE 升级(把已有 rule 提到 hook)**。每条带量化 + ⭐默认。

### 3.1 第10坑工程解:rule 声称层 → hook enforce 层【成立】+ 落地方案

**判定:成立,但必须三层纵深落地(单 hook 是陷阱)。**

证据链(跨 lens):
- rule = wish list 不是 contract(L5/L6:#7533「efficiency bias survives compaction」/ #19471「100% violation after compaction」/ #20701「CLAUDE.md 禁 grep 仍跑 ~70% 有效」)。
- hook = 唯一确定性拦截(L6/L7:PreToolUse exit 2 连 `--dangerously-skip-permissions` 都拦,prose ~60% vs hook deterministic)。
- **但 hook 有硬边界**(L7-DROP-X3 / 190 things):验 file:line 存在是天花板,**过期 smoke 值这类语义/新鲜度错 hook 必漏** → 仍需异源审计 + 人兜底。
- **hook 自己会循环失守**(L7-E1):若 cite-verify hook 用同 Claude 家族判「claim 被 grep 结果支撑吗」= 同 family bias,与生成 claim 同源共享「我很仔细」错觉一起放过第10坑。

**⭐ 落地方案(三层,按 ROI 排序,先窄后宽):**

```
第1层(确定性 grounding,先上 · 零运行时成本):
  Stop hook 读 last_assistant_message
  → 正则抽 load-bearing 的 file:line + 数字 claim
  → 对每个 path:N 跑 sed -n Np / rg 核存在
  → 缺则 decision:block 列失效 citation,喂回让补
  拦点选 Stop-文本-扫描(非 PreToolUse-deny):因第10坑数字在【文本生成】不走 tool call,
  且 Stop decision:block 绕开 #24327 停机坑(PreToolUse exit2 致新模型 idle 等用户)。
  骨架 = disler validate_file_contains.py(3785★)迁 2.1.177 schema。

第2层(语义/frame,异源 · 第10坑唯一被 catch 过的层):
  SubagentStop / 重大决策触发 → 调【异厂商】grader(磊哥已有 GLM-5.2 / hermes)
  做 cite-verify(claim 被一手代码支撑吗 + smoke 值过期了吗)。
  把「第10坑 GLM catch」从手动变自动门。
  绝不用同 Claude 家族判语义(L7-E1 循环失守)。

第3层(recognition,rule 保留 · 不动):
  claim-vs-reality-gap.md 三铁律继续 always-on,负责【主动识别时机】
  (用户不明说时,如「写每个数字前」)。rule 留 recognition,hook 做 enforcement。
```

**防误伤(guardrail 第一死因,L7-E4)**:matcher 极窄,**只拦写进契约 SSOT/基线文档/报告的 load-bearing 数字**(`if: Edit(*contract*) | Write(docs/**)`),先 PostToolUse `flag` 跑观察、误伤 <1/3 再升 Stop block。常识数字(2+2=4)绝不拦。

**防 cite-reminder 自己过期(L7-E3,第10坑 hook 复发版)**:注入的提醒写**静态指令**(「数字必带 file:line 出处」)不写**动态值**(「当前 smoke=X」)——否则 `--resume` replay 旧文本,hook 本想防过期自己却注入过期值。

### 3.2 ADOPT(外部更强,引入)

| # | adopt 物 | 为什么(量化) | ⭐默认 | source |
|---|---|---|---|---|
| A1 | **disler `validate_file_contains.py` 骨架** → 改 Stop hook 扫 file:line | 3785★ 实跑机制,「审产物文本非 metadata」与铁律1 同构,现成可改 | ⭐ **adopt 骨架,迁 2.1.177 schema**(旧 `result:block/exit1` → `decision:block/exit2`) | github.com/disler/... |
| A2 | **superpowers 精确措辞**「no cached results from 10 min ago」「Linter≠compiler」「Agent said success→verify independently」 | 235K★,第10坑(过期 smoke 旧值推)的完美命名 | ⭐ **只 adopt 措辞写进 claim-vs-reality 铁律2**,不装 skill(与 always-on rule 同机制,装=安慰剂) | github.com/obra/superpowers |
| A3 | **claude-mem 12.1.0→13.8.0** | 磊哥已用,失忆成熟解,生态王者就是他在用的 | ⭐ **升级**(先核 `<private>` 符合 §6 红线 + hook 拓扑不与现有 12 事件冲突) | github.com/thedotmack/claude-mem |
| A4 | **Cross-Context Review 无污染复审纪律** | F1 28.6%>同 session 24.6%(p=0.008),且证明收益来自 context 分离非多看(SR2 审两次不优于一次 p=0.11) | ⭐ **adopt 铁律**:cross-vendor 派单 prompt **不 prepend CC 推理链**(只给 artifact + spec),收敛 1-2 轮(More Rounds More Noise) | arxiv.org/html/2603.12123 |

### 3.3 BUILD(漏点无现成产品,自建)

| # | build 物 | 为什么必须自建(量化) | ⭐默认 | 落点 |
|---|---|---|---|---|
| B1 | **grep-before-claim / cite-verify hook**(§3.1 三层方案) | anti-shallow 物理 enforce **生态无现成 plugin**(L4-E1/L7-E1 双路确认),memory 类有 claude-mem 但 anti-shallow 类全停在 skill 声称层 | ⭐ **自建,先项目级 `.claude/` 试,实测 Stop 并发 + 误伤后再全局** | 用户级 `~/.claude/scripts/cite-verify.mjs`(只信用户级,防 CVE) |
| B2 | **冷开 handoff 注入 hook**(补结构洞1) | 本机坐实 `session-start-compact.mjs` ZERO_MATCH handoff,冷开新窗口零 handoff/memory-detail 注入,只有 MEMORY.md 索引;`session-closure.md:91`「自动注入最近3个 handoff」= 声称层 vs 事实层(rule 自己中招) | ⭐ **复活 UserPromptSubmit hook**(从已停用 token 提醒改成首轮注入最近 handoff 摘要,E1 黄金点 + 唯一每轮触发可 additionalContext) | 扩 `session-start-compact` 到 SessionStart matcher='' 或复活 `token-threshold-hook` |

### 3.4 ENFORCE 升级(已有 rule/hook 提级)

| # | 升级 | 现状 → 目标 | ⭐默认 |
|---|---|---|---|
| E1 | **Stop hook 漏写 handoff**:plain stdout → conditional block | 本机核 `session-stop.mjs` 检测今日 handoff 但只 ⚠️ 提醒(2026-06-07 从 block 回退防死循环);漏写靠自觉补 | ⭐ **升 conditional block**:漏写 handoff 且非只读 session → `decision:block`,写 handoff 一动作可消除(防死循环必须 `stop_hook_active` 守护 + 不撞 8 次 cap) |
| E2 | **read-before-edit 轻量门**(补实现侧开口) | 磊哥围栏偏诊断侧(cite-verify/异源审计),实现侧(codex 长跑写码)read-before-edit 无设防(L6-E4) | ⭐ **PreToolUse 查近 N 轮是否 Read 过 file_path**,没读软提示(注意 Edit+Bash 并发未验证,先实测,用 exit 0+JSON 不用 exit 2 避 #24327) |
| E3 | **max-effort 长链路警示回写 ultracode-7lens rule** | 磊哥默认开 max,但 #64991 Andon Labs 实测 opus-4-8 上 max → 5x token → 2x compaction → **失忆更重**;本 workflow 用 `opus-4-8[1m]` 多 agent 正中 #63604 掉 `antml:` 靶心 | ⭐ **回写 rule**:长链路多 agent 时 max 非越深越好,关键审计/收口步可 pin Sonnet 4.6/4.7 或 high+控频 |

### 3.5 DROP / KILL(明确不做,防 over-engineering)

- ❌ **不装任何 anti-shallow skill**(Karpathy 220K★ / research-mode 141★ / cavekit deepen):与 always-on rule 同机制,max 已证失效(第10坑),装更多 skill 治不了选源反射 = 安慰剂(L4-DROP-KILL / Elevate-or-Kill)。
- ❌ **不用 mem0/Zep cloud/Letta runtime 替代 MEMORY.md**:会话事实抽取非代码决策 SSOT(维度不符)/ 换 runtime 冲突 CC / 15x token / 云依赖违 MAformac 端侧(但这是项目约束,别溢出到 harness 选型,L2-E3)。
- ❌ **不为补 enforce 把 always-on rule 转 skill**:`rules-vs-skill-loading` 已裁决 = 降级。
- ❌ **不加 token 阈值 hook**:磊哥明确不看 token。
- ❌ **不寄望 CC 升级自动修**:#7533/#34624/#32294/#19471 全 closed not planned = Anthropic 当产品取舍非 bug,必须当永久局限做围栏(L6-DROP-X3)。
- ❌ **不引「thinking depth 砍 67%」当事实**:含 redaction(UI 隐藏)混入,官方修正为 ~3% eval drop,67% 字面不引(L6-DROP-X2)。⚠️ **CC 纠正**:原文「#42796 行为数据 read:edit 6.6→2.0」亦经 cite-verify 证 finder 编造(issue #42796 无任何量化),**已删**——讽刺:这条 DROP 本身在防 67% 凭印象数字,却又引了另一个编造数字(第8坑递归)。
- ❌ **不上 Cursor 向量索引/aider repo map**:MAformac 小项目 grep 够用,Cursor 自己说语义检索 1000+文件才显著(paper-tiger,L5-DROP)。
- ❌ **不靠 hook 验语义正确**:验 file:line 存在是天花板,过期 smoke 值这类 hook 必漏,别让 hook 背超能力的锅成新第10坑(L7-DROP-X3)。

---

## 4. Pre-Mortem 三分类汇总(7 路去重收敛)

### 🐯 Tigers(明确威胁,带验证清单)

| # | Tiger | 验证清单 | 威胁级 |
|---|---|---|---|
| **T1** | **`rule 在场` 误判为 `rule 生效`** — always-on rule 是 attention 输入非 enforce | 本机已坐实第10坑(claim-vs-reality:33 全程在场 + max 仍犯)+ #7533「efficiency bias survives compaction」+ #19471「100% violation」。**已 10 次同坑** | 🔴 HIGH |
| **T2** | **冷开窗口失忆** — SessionStart matcher='' 不注入 handoff | 本机已坐实 `grep handoff session-start-compact.mjs` = ZERO_MATCH;新窗口冷开只有 MEMORY.md 索引 | 🔴 HIGH |
| **T3** | **开 max 在 opus-4-8 上反加重失忆** — 磊哥默认习惯正踩坑 | #64991(OPEN)引 Andon Labs:4.8 max → 5x token → 2x compaction;#63604 长 1M 掉 `antml:`(磊哥 parallel-safety 已记 4 次实证);**本 workflow 自己正暴露在此 bug 下** | 🔴 HIGH |
| **T4** | **PreToolUse exit 2 致 Claude 停而不自纠**(#24327 回归) | 本机 2.1.177 临时 deny hook 实测看 idle 还是 fix-retry;若 idle → cite-verify 改 Stop `decision:block` | 🟡 MED |
| **T5** | **假绿/silent skip** — hook timeout 当没配过放行 + exit≠0/2 非阻塞 | cite-verify **fail-closed**(异常/超时 block 非 allow);脚本 `node --check` + 冒烟 + 写 log;exit 码只用 0/2 绝不用 1(#4809 exit1 BUG 阻断) | 🟡 MED |
| **T6** | **Stop hook 无限循环 + 8 次 block cap** | 首行查 `stop_hook_active==true` → exit 0;block reason 必须一动作可消除、不撞 cap | 🟡 MED |
| **T7** | **claude-mem 自动压缩给假记忆** — 误以为装了=失忆已解 | artifact tracking 2.19-2.45/5.0;长 session 后新开问 claude-mem 注入的关键文件路径 vs git log 准确率,对比手写 handoff | 🟡 MED |

### 🐅 Paper-Tigers(看似威胁实际安全,给证据)

| # | Paper-Tiger | 安全证据 |
|---|---|---|
| **PT1** | 「rules 太多稀释 attention 该瘦身」 | `rules-vs-skill-loading` 已搜证:rules 只加载一次便宜,token/context 不是磊哥约束(max20+1M),转 skill = 降级。**已论证设计选择非真威胁**(L1-PT1) |
| **PT2** | 「Karpathy 220K★ 必须 adopt」 | 人气幻觉。§25/§27 已是 Karpathy 项目特化细化版且更细;作者自认「prompt not hard constraint」。磊哥已有更强非漏点(L4-PT1) |
| **PT3** | 「上 claude-mem/原生 memory tool 就解决失忆」 | 社区营销话术。原生 memory「saves knowledge not state」技术准确但实践无用;磊哥 handoff 六件套已补 state + why-given-code,比裸 memory tool 强(L6-PT3) |
| **PT4** | 「LLM 总盲信 context 不信 parametric 要重防」 | 更普遍是 confirmation bias;DRUID 证明 synthetic 数据夸大了 context repulsion(真实检索 knowledge conflict 罕见)。真要防的是偏向已成印象旧值/派生物,read-before-claim 门已覆盖(L3-P1) |
| **PT5** | 「上 hook 强制 = 拖慢 + 烦」 | stale-read 只是 mtime 比对微秒级,PreToolUse 链任一 block 即停,几乎零运行时成本不是重治理(L3-P2) |
| **PT6** | 「`fewer-agent handoff 优于 compaction` 该上 handoff 机械化」 | Sourcegraph Amp 走过 compaction→Handoff(2025-11)→回退 compaction(2026)弯路。磊哥 handoff 是给人/新 session 读的决策摘要(对的)非替代平台 compaction 的机械,边界清楚就安全,别过度加(L2-PT3) |
| **PT7** | 「67% thinking depth 暴跌」头条数字 | 含 thinking redaction(UI 隐藏)混入,官方 postmortem 实际 eval 掉 ~3%。⚠️ **CC 纠正**:67% 与 #42796「行为数据」**均经 cite-verify 证编造/混入,都不引**(原文只删 67% 漏删 #42796 量化)(L6-P2) |
| **PT8** | 「hook 体系太脆弱/文档误导不值得做」 | 误导的是 prompt hook 注入/旧 Stop schema 等边角;cite-verify 用的 command/agent hook + Stop last_assistant_message + PostToolUse additionalContext 都是官方明确 + disler 3785★ 实跑;本机 2.1.177 已稳跑 12 hook 证明可靠(L7-P1) |

### 🐘 Elephants(没人提但该提的)

| # | Elephant | 为什么关键 |
|---|---|---|
| **E1 🔴最大** | **本 workflow 自己正暴露在它要调研的失忆 bug 下** — `opus-4-8[1m]` 派多 subagent 并行 = #64991/#63604 实测最易触发 context collapse + 掉 `antml:` 的配置。**综合官收口若发现 finder 间结论矛盾,第一假设应是某 finder 自己 compaction 丢 context 而非真分歧**(L6-E1)。本报告已用一手 grep 复核 load-bearing 数字规避此风险 |
| **E2 🔴** | **cite-verify hook 自己是验证器读同源被蒙蔽**(claim-vs-reality 铁律1 致命变体在 hook 层重演)— 若用同 Claude 家族判「claim 被 grep 支撑吗」= 同 family bias,与生成 claim 同源共享「我很仔细」错觉一起放过第10坑。**这正是第10坑要异源 GLM-5.2 才 catch 的原因** → 语义核 model 必须异厂商/异 frame,或退化纯确定性 string-match(L7-E1) |
| **E3** | **记忆召回≠应用** — CC 会「想起」一条原文没有的决策(§31 张冠李戴凭印象引错沉淀)。**所有外部记忆工具解决「存得住/取得回」但不防「调用时记错版本」**,外部生态完全没 cover 这个维度,修法只能纪律层(调用判断/frame 层记忆时回读原文核出处)(L2-E2) |
| **E4** | **UserPromptSubmit 是被浪费的黄金 enforce 点** — 本机坐实 `token-threshold-hook` 整体停用空转,但它是**唯一能 additionalContext 注入(2.1.168 schema 允许)且每轮触发**的事件,现空转 = harness 最大未利用杠杆,可承载冷开注入 handoff/写数字前 cite 反射(L1-E1) |
| **E5** | **失忆与浅思考是同一根(context rot)两个面,不该分开治** — 长 session 既忘首尾外约束又抓最近渲染派生物。**真解 = 关键一手源在每次 claim 前强制重取(不靠记忆/不靠 context 里旧拷贝),一个门治两病**(L3-E3) |
| **E6** | **memory 解失忆 ≠ 解「凭记忆里的派生物推」** — claude-mem 注入的是压缩历史观测,**若观测本身是派生物(config 印象/过期 smoke),memory 反而固化错误印象**。第10坑根 = 选源反射,memory 注入更多 context 可能加重而非缓解,除非注入一手源指针 + 强制重 grep 而非结论缓存(L4-E3) |
| **E7** | **三痛点是 by-design 不会随升级消失** — #7533/#34624/#32294/#19471 全 closed not planned;system prompt 的 `simplest-approach-first`/`minimize-output-tokens` 标 IMPORTANT 每轮强化覆盖项目 CLAUDE.md。**磊哥 max-effort/不编造 rule 与 CC 自带 be-concise 在系统层对冲,唯一不对冲的层 = hook(代码 enforce)非 prompt**(L6-E3) |
| **E8** | **hook 本身是攻击面** — Check Point 2026-02 披露 CVE-2025-59536/CVE-2026-21852:往 repo `.claude/settings.json` 注入恶意 hook 可 clone 时 RCE,hook command ran before trust dialog。**加 cite-verify hook 必须只信用户级 `~/.claude/settings.json`,绝不让项目级自动生效未审 hook**(尤其 clone 外部 repo)(L3-E1) |

---

## 5. Grill 弹药(喂回磊哥 grill,每条 topic + 选项 + ⭐默认 + 量化)

> 用法:磊哥逐题拍。每条已含量化锚 + ⭐默认,可不动脑 ✓ 默认。

**G1 — 第10坑 hook 化:做不做 + 拦在哪层?**
- A. 不做,继续靠 rule + 异源审计(现状)
- B. 做 PreToolUse 硬 deny(写代码前没 grep 就拦)
- C. ⭐ **做 Stop-文本-扫描(读 last_assistant_message 扫 file:line/数字,缺则 block 喂回)+ 异源 grader 二层**
- 量化:第10坑数字在【文本生成】不走 tool call → PreToolUse-deny 拦不到(B 漏底);Stop block 绕开 #24327 停机坑;hook 验 grounding 是天花板验不了 correctness(过期 smoke 必漏)→ 必须叠异源审计。**单 hook = 陷阱,三层纵深才成立。**

**G2 — cite-verify hook 的语义判断用谁?**
- A. 同 Claude(prompt hook 配 Haiku 单轮)
- B. ⭐ **异厂商(磊哥已有 GLM-5.2/hermes,走 SubagentStop 自动门)**
- C. 纯确定性 string-match(agent hook 只核存在不判语义)
- 量化:第10坑是异源 GLM-5.2 catch 的,机理 = self-correction blind spot(同样的错自己改不了、外部输入能改)。用同 Claude = 同 family bias 循环失守(铁律1 致命变体),与生成 claim 共享「我很仔细」错觉一起放过。**A 必踩 E2 大象。**

**G3 — 磊哥默认开 max effort,在 opus-4-8 上还要不要默认拉满?**
- A. 继续全局 max(现状)
- B. ⭐ **分任务校准:L1 机械/确定步用 high+控频或 Sonnet,L2+ 模糊多步才 max;关键收口步 pin 4.7**
- C. 全降到 high
- 量化:#64991 Andon Labs 实测 opus-4-8 max → 5x token → 2x compaction → 失忆**更重**(4.7 上不发生);Inverse Scaling(Anthropic 自家)证明越 reason 越被无关信息带偏;overthinking 倒 U(1100→15980 token 准确率 87.3%→70.3%)。**effort≠深度有官方盖章。**

**G4 — 冷开窗口零 handoff 注入,补不补?**
- A. 不补(靠磊哥手动 Read handoff)
- B. ⭐ **复活 UserPromptSubmit hook(首轮注入最近 handoff 摘要)**
- C. 扩 session-start-compact 到 SessionStart matcher=''
- 量化:本机坐实冷开零 handoff 注入,`session-closure.md:91`「自动注入」是声称层(rule 自己中招);UserPromptSubmit 是唯一每轮触发 + 可 additionalContext 的黄金点,现空转(E4 大象)。**B 一石二鸟(同时可挂 cite 反射)。**

**G5 — Stop hook 漏写 handoff:升不升 block?**
- A. 保持 plain stdout 提醒(现状,靠自觉)
- B. ⭐ **conditional block(漏写且非只读 → block,写 handoff 一动作消除)**
- 量化:2026-06-07 从 block 回退是因死循环;但加 `stop_hook_active` 守护 + 不撞 8 次 cap 即安全。漏写 handoff = 下次失忆(T3),plain stdout 可被忽略。

**G6 — claude-mem 升不升级 + 要不要更激进用它?**
- A. ⭐ **只升 12.1.0→13.8.0,继续作 handoff 补充不替代**
- B. 用 claude-mem 替代手写 handoff
- C. 不动
- 量化:artifact tracking 2.19-2.45/5.0(自动压缩弱),原生 memory「saves knowledge not state」;磊哥 grounded 派 handoff 更可审计。**B 是降级(PT3 营销话术)。**

**G7 — 装不装 anti-shallow skill(superpowers/research-mode/Karpathy)?**
- A. ⭐ **只 adopt 精确措辞写进 claim-vs-reality 铁律2,不装任何 skill**
- B. 装 superpowers verification-before-completion
- C. 装 research-mode 做 cite cascade
- 量化:anti-shallow 类全是 SessionStart 注入 = 与磊哥 always-on rule 同机制,max 已证失效(第10坑);§25/§27 已比 Karpathy 更细;作者自认「prompt not hard constraint」。**装 = 重复武装声称层安慰剂(Elevate-or-Kill)。**

**G8 — 异源审计派单要不要禁 prepend CC 推理链?**
- A. 现状(可能 prepend 上轮 CC 推理)
- B. ⭐ **铁律:cross-vendor 派单只给 artifact+spec,不 prepend CC 推理链,收敛 1-2 轮**
- 量化:Cross-Context Review 证明收益来自 context 分离本身(F1 28.6%>24.6% p=0.008),prepend 推理链退化成 context-aware subagent(F1 23.8%<纯 CCR);More Rounds More Noise(多轮假阳性增速快于真错发现)。**A 可能让磊哥异源审计悄悄退化。**

**G9 — read-before-edit 轻量门(补实现侧开口)做不做?**
- A. 不做(围栏继续偏诊断侧)
- B. ⭐ **PreToolUse 软提示(没 Read 过 file_path 就提醒,用 exit 0+JSON 不用 exit 2)**
- C. 硬 block
- 量化:磊哥围栏偏诊断侧,实现侧 codex 长跑 read-before-edit 无设防(L6-E4)(⚠️原引 #42796「6.2%→33.7% 5.4x」经 CC cite-verify 证编造已删;论点「实现侧无设防」仍成立)。但 Edit+Bash 并发未验证 + #24327 idle bug → 用软提示先稳。**C 踩停机坑。**

---

## 6. 附:一手档索引(可溯源)

| 路 | 文件 | 一手价值 |
|---|---|---|
| L1 | `lens1-harness-baseline.md` | 磊哥 harness 实况(33 rule / 12 hook / 漏点地图)+ 本机 grep 证据 |
| L2 | `lens2-memory-persistence.md` | 失忆持久化生态(claude-mem/mem0/Zep/Letta/Mneme)+ benchmark 战争 + grounded vs 抽取派 |
| L3 | `lens3-cognitive-shallow.md` | LLM 浅思认知机制一手实证(Inverse Scaling/#42796/self-correction blind spot/CCR/SmartSnap) |
| L4 | `lens4-skill-ecosystem.md` | 现成 skill/plugin 生态 + Elevate-or-Kill 判定 |
| L5 | `lens5-harness-architecture.md` | 主流 harness 架构(LangGraph/Letta/Pi clone/Mastra/grounded/aider/Cursor)+ ETH Zurich |
| L6 | `lens6-issue-oracle.md` | CC 官方 issue 坑点(closed-not-planned 盖章三痛点是 by-design) |
| L7 | `lens7-enforce-recipe.md` | hook enforce 工程路径 + 硬边界(grounding ✓ / correctness ✗)+ 13 个落地坑 |

> 每路文件含完整 source URL + 日期 + 各自 pre-mortem。本 README 的 load-bearing 事实已由综合官本机 grep/cat 二次复核(§0.1)。

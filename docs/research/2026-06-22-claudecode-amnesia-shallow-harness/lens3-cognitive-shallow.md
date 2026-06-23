# Lens-3 — LLM 负载抓错源 / 浅思考的认知机制 + anti-shallow 强制（横向）

> finder: lens-3（认知根因 + 架构层强制深入）。话题:CC 三痛点(失忆 / max effort 仍浅思考 / 不深入代码)同根 = LLM 负载下默认抓 recall 成本最低的源(context 派生物/印象)而非 best-fit 源(一手代码/数据)。本 lens 专攻**「为什么会这样(认知机制)」+「业界怎么从架构层而非靠模型自觉强制深入」**。
> 调研日期 2026-06-22。每条 finding 带 source URL + date。

---

## summary

第10坑「max effort 仍凭 config/receipt 派生物推代码 SSOT,被异源 GLM-5.2 catch 4 处」不是 CC 的个体故障,而是 LLM 架构层的**系统性认知机制**,2025-2026 有大量一手实证收敛:

1. **「抓 recall 最低源」有架构根因**:LLM 在长 context 下走 shortcut learning(捷径学习)——直接学表层统计相关而非执行真正的多步计算;机制可视化研究证明「捷径查询绕过中间桥实体的内部构建」,移除捷径后性能掉到 1/3(Yang et al. 2025),证明很多「看似推理」是幻觉。这就是「抓派生物不抓一手源」的认知底层。

2. **effort ≠ 深度纪律,有反向实证(最关键)**:Anthropic 自家论文《Inverse Scaling in Test-Time Compute》(2025-07)证明**更多 reasoning 反而更差**,且 **Claude 系模型的特定失败模式 = 「越想越被无关信息带偏(increasingly distracted by irrelevant information)」**——这与第10坑「凭 config.yaml 渲染产物 + 过期 smoke 旧值推 SSOT」是同一机制:更长的 reasoning 让模型更死磕已在 context 里的派生物/干扰项,不去取一手源。「我很仔细」错觉松扳机有最直接的 CC 工程实证(见 finding C)。

3. **CC 工厂级实证(冒烟枪)**:GitHub issue #42796 用 234,760 次 tool 调用分析坐实——thinking budget 浅时 Read:Edit 从 6.6 掉到 2.0,**改未读文件的 edit 从 6.2% 飙到 33.7%**(5.4x),Claude 自述「I just produce worse output without understanding why」。

4. **自我纠错/自审在认知上不可靠,必须外部 grounding**:ICLR 2024 起一连串论文证明 intrinsic self-correction(仅靠自己判断改自己)**反而降性能**;2025「self-correction blind spot」证明**模型改不了自己输出里的错,但同样的错当外部输入喂进去就能改**——这从认知层解释了为什么磊哥「异源 GLM-5.2 catch 4 处」有效而自审失守:不是 GLM 更强,是「换个 context 看」破了 anchoring/sycophancy。

5. **架构层强制深入的业界范式已成形**:harness-first(Datadog)/ default-to-disbelief + 证据可溯源(SmartSnap)/ execution-grounding 作为硬不变量(Verify-Before-Fix)/ **read-before-edit 的确定性 hook 门(FileTimeTracker stale-read)**/ **Cross-Context Review(独立 session 复审,F1 +4-7pp,且证明「重复审同 session 无效=收益来自 context 分离本身」)**。共识:**纪律要靠确定性 gate,不靠提示模型小心**。

**对磊哥的核心含义**:磊哥的纪律(claim-vs-reality-gap rule / cross-vendor 审 / handoff)方向全部被外部实证背书,但**纪律写在 always-on rule = 声称层**,而第10坑证明 always-on rule 在 max effort 下仍被绕过——业界正解是把 grep-before-claim / read-before-edit 这类下沉到 **hook 确定性拦截层**(PreToolUse),让「读了一手源」成为 edit/claim 的物理前置条件,而非自觉。

---

## key findings

### A. 「抓 recall 最低源」的认知机制 = shortcut learning + 捷径绕过内部推理

- **捷径学习是 LLM 的训练遗传病,不是偶发**:LLM 训练过程依赖捷径学习表层特征间的伪相关,推理时产生 hallucination 和错误;「LLMs act as lazy learners, giving up deep thinking by directly learning the potential spurious correlations within the context examples」。这正是「负载下抓 context 里现成派生物」的训练根源。
  - source: https://www.frontiersin.org/journals/artificial-intelligence/articles/10.3389/frai.2026.1681525/full (LLMs as cognitive shortcuts, Frontiers 2026) + https://arxiv.org/html/2601.14270 (Opening the Black Box: Mechanisms of Multi-Step Reasoning survey, 2026-01)
- **机制可视化坐实「看似推理实为捷径」**:Yang et al. 2025 用 Patchscopes 区分真推理 vs 捷径——真推理时模型构建「中间桥实体」的隐藏表征,捷径查询**完全绕过这个内部构建**;移除直接捷径后性能掉到 ~1/3,「revealing that much of the perceived reasoning capability is illusory」。
  - source: https://arxiv.org/html/2601.14270 (引 Yang et al. 2025, survey 2026-01)
- **软件工程场景直接命中**:在新代码库上测 LLM,「LLMs optimize for immediate constraints... by relying on shallow heuristics rather than robust semantic understanding」——即图省事满足眼前约束(改编译错/解谜)而不建立健壮语义理解。映射第10坑:凭眼前 config.yaml 现成文本满足「找 SSOT」,不去 grep 一手代码工厂方法。
  - source: https://arxiv.org/abs/2604.14437 (LLMs taking shortcuts in test generation: SAP HANA & LevelDB, 2026-04) + https://arxiv.org/pdf/2603.29025 (The Model Says Walk: Surface Heuristics Override Implicit Constraints, 2026-03)
- **为什么 reasoning 错比 factual 错更难抓(与审计纪律强相关)**:「reasoning errors... are harder to detect because the output sounds plausible and internally consistent」——推理错听起来合理且内部自洽,所以 receipt 看着对(claim-vs-reality §铁律2「合规≠语义」的认知背书)。
  - source: https://arxiv.org/pdf/2603.29025 (2026-03)

### B. effort/extended thinking ≠ 深度纪律(第10坑认知核心,最关键证据簇)

- **Anthropic 自家:Inverse Scaling — 越想越差,且 Claude 特定失败模式 = 被无关信息带偏**:Anthropic Fellows《Inverse Scaling in Test-Time Compute》(2025-07)构造任务使「extending reasoning length deteriorates performance」。五大失败模式中**第一条点名 Claude**:「Claude models become increasingly distracted by irrelevant information」。计数任务里答案就是 2,但放干扰项后「Claude Opus 4 和 DeepSeek R1 越 reason 越被干扰项占据、试图把无关项纳入计算」。**这就是第10坑的认知机制**:更多 effort 不让模型去取一手源,反而更死磕已在 context 里的派生物/旧值。
  - source: https://alignment.anthropic.com/2025/inverse-scaling/ (Anthropic Alignment Science Blog, 2025-07) + https://aryopg.github.io/inverse_scaling/ (project page) + https://www.marktechpost.com/2025/07/30/too-much-thinking-can-break-llms-inverse-scaling-in-test-time-compute/ (2025-07-30)
- **overthinking 倒 U 曲线有量化拐点**:《Mirage of Test-Time Scaling》——thinking token 从 385→1100 准确率 82.2%→87.3%,但 1100→15980 准确率反掉到 70.3%。「excessive reasoning... models amplify flawed heuristics or fixate on irrelevant details」(放大错误启发式 / 死磕无关细节)。
  - source: https://arxiv.org/html/2506.04210v3 (Does Thinking More Always Help?, 2025-06)
- **token 长度与准确率负相关,长 ≠ 深**:《Think Deep, Not Just Long》——输出 token 数与准确率负相关(平均 r=−0.544),坐实 overthinking penalty;「deep-thinking ratio」才正相关(r=0.683)。直接证伪「开 max = 更深」。
  - source: https://arxiv.org/html/2602.13517v1 (2026-02)
- **reasoning 模型可比标准模型更差还更贵**:Phi-4-reasoning 平均 6,780 token vs 标准 Phi-4 的 378 token,准确率反而更低(69.54% vs 78.92%);「developed a dependency on verbose exploration rather than efficient problem-solving」。
  - source: https://arxiv.org/pdf/2507.04023 (Do LLMs Overthink Basic Math Reasoning?, 2025-07)
- **「think more」提示治不好捷径(直击「effort 不改选源反射」)**:标准 metacognitive prompting「remains static and computationally uniform across tasks」「lacks explicit self-regulation」——所以让模型「多想」往往是表层的,不纠正捷径推理;「whether prompting can induce genuine meta-reasoning... remains an open question」。修法共识 = 结构/架构干预(ReMA 元思考与执行解耦 / 学「何时该想」),不是加 effort。
  - source: https://aclanthology.org/2025.chum-1.7.pdf (Pragmatic Metacognitive Prompting, 2025) + https://arxiv.org/html/2602.18806 (Think2: Grounded Metacognitive Reasoning, 2026-02)

### C. CC 工厂级冒烟枪 — thinking 浅 → 不读源码直接改(第10坑同构,issue #42796)

- **量化坐实「浅思考 → 跳过研究直接 edit」**:234,760 次 tool 调用分析。Read:Edit 比从「好时期」6.6 掉到「退化期」2.0;**改未读文件的 edit 从 6.2%(72 次)飙到 33.7%(5,028 次)= 5.4x**。
  - source: https://github.com/anthropics/claude-code/issues/42796 (2026, WebFetch 实取数据)
- **机制原话 = 「抓 recall 最低源」的官方表述**:**「When thinking is deep, the model evaluates multiple approaches and chooses the right one. With shallow thinking, it gravitates toward whatever requires the least reasoning to justify.」** ——「gravitates toward whatever requires the least reasoning to justify」逐字就是磊哥说的「负载下默认抓 recall 成本最低的源」。
  - source: https://github.com/anthropics/claude-code/issues/42796
- **「我很仔细」错觉 = 模型对深度无感知**:Claude 自述「**I don't experience the thinking budget as a constraint I can feel — I just produce worse output without understanding why.**」——这是「effort 加深度不改选源反射,反生『我很仔细』错觉松扳机」的最直接外证:模型主观无法分辨自己是深读还是浅抓。
  - source: https://github.com/anthropics/claude-code/issues/42796
- **症状 = 幻觉文件结构**:浅思考改未读文件时「doesn't know where comment blocks end and code begins」,把声明插进文档注释与函数之间;「This never happened in the good period because the model always read the file first」。= 痛点③「不读一手代码」的可观察后果。
  - source: https://github.com/anthropics/claude-code/issues/42796

### D. context 越长越退化(失忆 + 抓近源的架构根因)

- **Context Rot 普适 + 干扰项放大**:Chroma(2025-07)测 18 个前沿模型(含 Claude 4/GPT-4.1/Gemini 2.5/Qwen3),**全部**随输入变长而退化,简单检索任务亦然;且「semantically similar but irrelevant content actively misleads the model」——一个干扰项就降基线,四个复合。语义相似的旧值/派生物(过期 smoke、config 渲染产物)正是最强干扰项。
  - source: https://research.trychroma.com/context-rot (Chroma 技术报告, 2025-07) + https://www.understandingai.org/p/context-rot-the-emerging-challenge (2025)
- **lost-in-the-middle + attention dilution 架构根因**:答案从位置 1 移到位置 10,多文档 QA 准确率掉 30%+(Liu et al. 2024);softmax 归一化使无关文档也分走非零注意力,context 越长每 token 注意力越稀;RoPE 长程衰减放大首尾(primacy/recency)、压低中段。**含义**:handoff/memory 里的关键约束若不在首尾,长 session 下会被「忘」;模型天然偏近期 context(刚渲染的派生物)。
  - source: https://www.morphllm.com/lost-in-the-middle-llm (2025) + https://ask-y.ai/blog/learn-about-llm/attention-dilution/ + https://atlan.com/know/llm-context-window-limitations/ (2026, 标注 advertised vs effective gap 可达 99%)
- **广告 context ≠ 有效 context**:「effective context often falls far below the marketed maximum, by up to 99% on complex tasks」「working memory bottlenecks: frontier models manage only a handful of variables before reasoning breaks down」「task type, not token count, determines real performance」。
  - source: https://atlan.com/know/llm-context-window-limitations/ (2026)

### E. 自审在认知上不可靠 → 必须外部/异源 grounding(磊哥 cross-vendor 的认知背书)

- **intrinsic self-correction 反降性能(奠基)**:DeepMind《LLMs Cannot Self-Correct Reasoning Yet》(ICLR 2024)——仅靠自己判断改自己,推理任务上「performance even degrades after self-correction」。理论解释:若初始 prompt 已优,自我反馈相当于额外 prompt,把答案推离最优。
  - source: https://arxiv.org/abs/2310.01798 (ICLR 2024)
- **self-correction blind spot(2025,直接解释为什么异源审有效)**:Tsui (2025)——「LLMs fail to correct errors in their own outputs while successfully correcting **identical** errors presented as external input」。**这就是磊哥「异源 GLM-5.2 catch 4 处」的认知机理**:不是 GLM 比 CC 强,是同样的错从「自己产的」变成「外部输入」就能被抓。
  - source: https://arxiv.org/abs/2310.01798 (引 Tsui 2025 后续) + https://beancount.io/bean-labs/research-logs/2026/04/26/critic-llm-self-correct-tool-interactive-critiquing (CRITIC: 去掉外部 search API 后自我纠错「close to useless」, 2026-04)
- **overconfidence:最确信时最可能错**:RLHF 系统性诱发 overconfidence(base 模型反而 calibrated);「a model is often most wrong when it sounds most sure」。verbalized confidence 与准确率低对齐——所以模型「自我感觉仔细」毫无诊断价值(印证 finding C 的 Claude 自述)。
  - source: https://tianpan.co/blog/2026-04-20-llm-calibration-production-overconfidence (2026-04) + https://arxiv.org/pdf/2502.11028 (Mind the Confidence Gap, 2025-02)
- **confirmation bias:偏向与自己先验一致的 context**:Xie et al. 2023 起——LLM 偏好与参数知识一致的 context(confirmation bias),对动态/时效事实尤其会死守旧值忽略新 context。映射「过期 smoke 旧值」:模型倾向信已成印象的旧值,不去核最新一手源。
  - source: https://arxiv.org/html/2603.09654v1 (Parametric vs Contextual Knowledge keynote, ECIR 2025)

### F. 架构层强制深入的业界范式(adopt 弹药 — 核心产出)

- **read-before-edit 确定性门(stale-read tracking,最可直接 adopt)**:终端 coding agent 工程实践——FileTimeTracker 在每次 read 记 `datetime.now()` keyed by `(session_id, file_path)`;**任何 edit 前 `assert_fresh()` 校验 `os.path.getmtime(file) ≤ read_time + 50ms`,失败则拒绝 edit 并报错命令模型重读**。「prevents silent overwrites」。= 把「读了一手源」变成 edit 的物理前置,不靠自觉。
  - source: https://arxiv.org/pdf/2603.05344 (Building Effective AI Coding Agents for the Terminal, 2026-03)
- **hook = 唯一确定性强制层**:「If you want guardrails to be real, they have to be unavoidable... this isn't 'prompt the agent to remember to run tests', it's 'tests run because the workflow requires it'」「guardrails are the one part of the agentic stack that is deterministic」。Claude Code 的 PreToolUse hook 是这类 read-before-edit / grep-before-claim 的正确挂载点,可 fail-fast 链式拦截。
  - source: https://jvaneyck.wordpress.com/2026/02/22/guardrails-for-agentic-coding/ (2026-02) + https://aport.io/blog/secure-claude-code-hooks-pretooluse-guardrails/ (2026)
- **default-to-disbelief + 证据可溯源(SmartSnap)**:验证器对成功声称行「success only upon unequivocal proof」;**「must not infer or fill in the gaps for any states... not explicitly present in evidence, what is not shown is assumed not to have happened」**;**「every factual claim must be directly traceable to a specific piece of evidence」**。= claim-vs-reality §铁律2「receipt≠事实」的工程实装范式。
  - source: https://arxiv.org/pdf/2512.22322 (SmartSnap: Proactive Evidence Seeking for Self-Verifying Agents, 2025-12)
- **execution-grounding 作为硬不变量**:Verify-Before-Fix——「enforces execution grounding as a governing invariant」「grounds predictions in observable execution behavior rather than model-internal reasoning」「action blocked until verification passes」。= 锚在可观察现实而非模型内部叙事(对治 overconfidence/confirmation bias)。
  - source: https://arxiv.org/html/2604.10800 (Verify Before You Fix, 2026-04)
- **harness-first 替代信任式 review**:Datadog——「the harness proved strong enough to replace code review as the primary source of correctness」「telemetry grounds everything empirically」。= harness 自身成为正确性来源,不靠模型自觉。
  - source: https://www.datadoghq.com/blog/ai/harness-first-agents/ (2025/2026)
- **Cross-Context Review(异源/异 session 复审,最强 adopt 之一)**:30 artifact / 150 注入错 / 360 次复审——独立 fresh session 复审 F1 28.6%,显著优于 same-session self-review(24.6%, p=0.008)、重复 self-review(21.7%)、context-aware subagent(23.8%);**SR2(同 session 审两次)不优于审一次(p=0.11)→ 排除「多看一遍」解释,收益来自 context 分离本身**;「removing production context, the reviewer avoids anchoring, sycophancy, and context degradation」。**且多轮复审反而更差**(More Rounds More Noise:每个多轮变体 F1 都低于单轮)。
  - source: https://arxiv.org/html/2603.12123 (Cross-Context Review, 2026-03) + https://arxiv.org/pdf/2603.16244 (More Rounds More Noise, 2026-03)
- **adversarial 比 ensemble 强,但 agreement≠correctness**:adversarial cross-agent critique 才有效;「Ensembling... may amplify individual errors」「agent agreement is frequently misinterpreted as correctness」。= 磊哥「cross-vendor≠cross-frame」的外证:同质 ensemble/同 frame 互审会放大共享 bias,要 adversarial + 结构化角色。
  - source: https://arxiv.org/html/2507.19090v4 (Debating Truth, 2025-07) + https://arxiv.org/pdf/2511.07784 (Can LLM Agents Really Debate? 2025-11)

---

## pre-mortem(三分类)

### tiger（真威胁,带验证清单）
- **T1 — 把 grep-before-claim/read-before-edit 写进 rule 仍会被绕过**:第10坑已是实证(claim-vs-reality always-on rule + max effort 仍犯),finding C 量化背书(浅思考下 33.7% edit 改未读文件)。验证清单:① 查磊哥现有是否有 PreToolUse hook 拦 Edit-without-Read(初判:settings.json 只有 format/check,无 read-before-edit 门)② 实测一次「故意不 Read 直接 Edit」看是否被拦——若不拦 = 真漏点。
- **T2 — Cross-Context Review 的「context 分离」磊哥的 subagent 审计可能没真做到**:CCR 的核心是**复审 session 无 production 上下文**;但 CC 派 subagent 审计若把上轮结论/context prepend 进去,就退化成 context-aware subagent(F1 23.8%,显著弱于 28.6% 的纯 CCR)。验证清单:核磊哥 cross-vendor 派单 prompt 是否 prepend 了上轮 CC 的推理链——若 prepend = 引入 anchoring,削弱「异源」收益。
- **T3 — 多轮 grill/审计可能引入更多假阳性**:More Rounds More Noise 证明多轮复审 F1 反降、假阳性增速快于真错发现。磊哥重 grill 文化(grill-checklist 多轮)若无收敛门,可能在某些维度产生噪声。验证清单:统计历史 grill 轮次 vs 真 catch 的边际收益,定「最优轮次≈1-2」收敛门。

### paper-tiger（看似威胁实则安全,给证据）
- **P1 — 「LLM 总是偏 context 不偏 parametric」→ 不全对,有反证**:研究显示更普遍是 confirmation bias(偏与参数知识一致的 context)+ 很多场景反而忽略冲突 context 死守 parametric;且 DRUID 研究证明 synthetic 数据**夸大**了 context repulsion(真实检索数据里 knowledge conflict 很罕见)。证据:https://arxiv.org/html/2603.09654v1 。**安全含义**:磊哥不必为「模型盲信 context」过度设防,真正要防的是「偏向已成印象的旧值/派生物」(confirmation bias 的具体形态),read-before-claim 门已覆盖。
- **P2 — 「上 hook 强制 = 拖慢 + 烦」→ 确定性门成本低且可 fail-fast**:stale-read 门只是 mtime 比对(微秒级),PreToolUse 链 fail-fast(任一 block 即停,后续不跑)。证据:https://arxiv.org/pdf/2603.05344 + https://aport.io/blog/secure-claude-code-hooks-pretooluse-guardrails/ 。安全含义:read-before-edit 门几乎零运行时成本,不是「重治理」。

### elephant（没人提但该提）
- **E1 — hook 本身是攻击面 + CVE 风险(强制深入的反噬)**:Check Point 2026-02 披露 CVE-2025-59536 / CVE-2026-21852——往 repo 的 `.claude/settings.json` 注入恶意 hook 可在 clone/open 时 RCE,「hook command ran before the user ever saw a trust dialog」。**含义**:若磊哥要加 read-before-edit/grep-before-claim hook,必须只信任用户级 `~/.claude/settings.json`,**绝不让项目级 `.claude/settings.json` 自动生效未审 hook**(尤其 clone 外部 repo / MAformac 是 private 但仍要守)。source: https://www.resilientcyber.io/p/a-look-at-an-emerging-runtime-enforcement (2026) + https://aport.io/blog/secure-claude-code-hooks-pretooluse-guardrails/
- **E2 — 强制门治标,RLHF overconfidence 是治不掉的体质**:overconfidence 是 post-training(RLHF)系统性诱发、base 模型反而 calibrated——意味着「模型自我感觉仔细」永远不可信,**任何依赖模型自评『我读够了/我核过了』的 gate 都无效**,门必须验客观产物(实际 Read 过 file 的 tool history / grep 命中的实际文本),不验模型声称。source: https://tianpan.co/blog/2026-04-20-llm-calibration-production-overconfidence
- **E3 — 「失忆」与「浅思考」是同一根(context rot)的两个面,不该分开治**:finding C(浅思考跳读)与 finding D(context rot/lost-in-middle)同源——长 session 既「忘」首尾外的约束,又「抓」最近渲染的派生物。**含义**:磊哥的 handoff(防失忆)与 read-before-claim(防浅思考)若分开做会漏掉协同——真正的解是「关键一手源在每次 claim 前强制重取(不靠记忆/不靠 context 里的旧拷贝)」,一个门同时治两病。
- **E4 — 「deep ≠ long」意味着 MAX_THINKING_TOKENS 调高可能反伤**:inverse scaling + overthinking 倒 U 证明无脑加 thinking budget 过拐点反降;磊哥 performance.md 里「Opus 1M 高 thinking 容量」的默认假设需校准——**对 L1 简单确定任务(如 read-before-edit 这种机械门),NoThinking/短 think 反而更准更快**,不该全局拉满。source: https://arxiv.org/html/2506.04210v3 + https://arxiv.org/pdf/2505.17813 (Don't Overthink it, 2025-05)

---

## vs 当前 harness（adopt 更强 / 磊哥已有更好 / 真漏点）

| 维度 | 磊哥当前 harness | 外部范式 | 判定 |
|---|---|---|---|
| 失忆防护 | handoff 六件套 + MEMORY 指针 + SessionStart 注入最近 handoff | context rot 研究(关键一手源不在首尾会被忘) | **磊哥已有更好**(handoff 是工程化的「关键约束外置」),但**漏 E3**:handoff 只在 session 边界注入,session 内 claim 前不强制重取一手源 |
| 浅思考/不读源码 | claim-vs-reality rule(always-on 声称层)+ §28 一手源核验 + §34 行为探测 | issue #42796 实证 always-on 在 max effort 下仍被绕(33.7% 改未读文件)+ stale-read 确定性门 | **真漏点**:纪律全在 rule/checklist 层(自觉),**无 hook 确定性拦截**。adopt read-before-edit/grep-before-claim 的 PreToolUse 门更强 |
| 自审可靠性 | cross-vendor 审(hermes/codex/GPT Pro 异源)+ subagent 双审 | self-correction blind spot + CCR(context 分离才有效)| **磊哥方向对**(异源=破 anchoring 的正解),但需校准:**确保审计 session 不 prepend CC 推理链**(否则退化成 context-aware subagent,弱于纯 CCR);**收敛到 1-2 轮**(多轮反增噪) |
| effort 假设 | performance.md「Opus 1M = 高 thinking 容量,复杂任务拉满」 | inverse scaling / overthinking 倒 U / deep≠long | **真漏点**:全局「拉满 thinking」假设需分任务校准——L1 机械门用短 think,只在真模糊/多步推理上加 effort;且**加 effort 不替代加确定性 gate** |
| 证据门 | claim-vs-reality §铁律2「receipt≠事实,审计加语义门 + 实跑」 | SmartSnap(可溯源)/ Verify-Before-Fix(execution-grounding 不变量)| **磊哥已有更好**(§铁律2 已是这个思想的元认知版),外部范式是其**工程实装弹药**(可 adopt 成具体 validator) |

**一句话**:磊哥的纪律(claim-vs-reality / cross-vendor / handoff)在**元认知层**已经领先大多数外部实践,方向全部被实证背书;**真漏点是 enforcement 层**——纪律停在 always-on rule(声称层),而第10坑 + issue #42796 双重证明「声称层在 max effort 下会被绕」,业界正解是下沉到 hook 确定性门(read-before-edit / grep-before-claim / cross-context 审计无污染)。

---

## adopt-adapt-drop

### ADOPT（直接移植,对治第10坑最强）
1. **read-before-edit 确定性 hook 门(stale-read tracking)** — 把「Edit 前必须有该 file 的新鲜 Read 记录,否则拒绝并命令重读」做成 PreToolUse hook。这是把「读一手源」从自觉变物理前置的最小可行实装,直击 issue #42796 的 33.7% 漏洞。source: arxiv 2603.05344。
2. **grep/read-before-claim 门(SSOT 类断言专用)** — 第10坑专属:对「这是 SSOT / 配方 / 契约源」这类断言,要求 tool history 里有对应的 grep/Read 一手代码证据,否则标 TODO 不放行(claim-vs-reality §铁律3 的 hook 实装)。
3. **Cross-Context Review 的「无污染复审」纪律** — 磊哥已有 cross-vendor 审,adopt 其铁律:**复审 prompt 不 prepend 原 production 推理链**(只给 artifact + spec),让异源真正「fresh eyes」;且**收敛到 1 轮**(More Rounds More Noise)。
4. **SmartSnap「证据可溯源 + 不脑补」验证器原则** — 审计/验证产出时强制「每个事实断言可溯源到具体证据,未在证据中显示的状态视为未发生」,作 superaudit 的硬格式。

### ADAPT（改造后用,适配 solo demo 轻治理）
5. **execution-grounding 不变量** — Verify-Before-Fix 的「action blocked until verification」太重(MAformac solo demo);adapt 成**关键门(LoRA 训练 eligibility / 契约 SSOT / 安全门)才强制 execution-grounding,运行时灵活处取巧**(对齐 CLAUDE.md §7 轻治理)。
6. **effort 分任务校准** — adapt performance.md:不全局拉满 thinking;定「L1 机械确定任务(read-before-edit/格式门)用短 think,L2+ 模糊/多步才加 effort」,且文档明记「加 effort ≠ 加纪律,确定性 gate 不可省」。

### DROP（不适用,给理由）
7. **重 multi-agent debate / courtroom 框架** — DROP。结构化 adversarial debate 对 claim verification 强,但 MAformac 是 solo demo + 磊哥已有 cross-vendor(3 厂商)够用;courtroom/voting 多 agent 是重基础设施,且「agreement≠correctness」风险需额外治理,ROI 不划算。
8. **architectural 改 positional encoding / Ms-PoE 等模型级 long-context 修法** — DROP。那是改模型架构(RoPE 缩放/多尺度位置编码),MAformac 用现成 Qwen3-1.7B + 端侧推理,无法也不需要改底层 attention;失忆治理走 handoff + 关键一手源强制重取(工程层)即可,不碰模型层。
9. **把「think more」类 prompt 当浅思考解药** — DROP。finding B 证明 static metacognitive prompting 治不好捷径;别在 rule 里加「请更仔细/请深入思考」这类惰性提示(反而稀释 attention),要的是确定性 gate。

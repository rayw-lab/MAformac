# Lens L17 — Human-review 点 + 4 模型交叉破框（非背书）协议

> 维度：Human-in-the-loop 审核点 + 4 模型交叉破框协议（磊哥最大焦虑独立）。P0（横切）。
> 调研日期：2026-06-24 | 模式：pre-propose decision-pack（纯搜证+假想验证，不实装训练/评测/voice/受限解码）
> 本机实况：mlx_lm 0.31.1 / 32GB RAM(hw.memsize 34359738368) / home-llm 已 clone(pushedAt 2026-06-11, 1364★)

## Summary

MAformac 最大焦虑（4 模型互审仍可能集体漏同一 frame）是**有学术铁证的真威胁**，不是杞人忧天：
- **SPECA 以太坊客户端审计**（arxiv 2602.07513）实证「跨实现检查占 76.5% 有效发现」（=跨厂商确实抓最多 bug），但**同时警告**「广泛使用少数强 LLM 做开发助手引入共享脆弱性新向量——不同团队用推理模式相似的 agent 会**独立引入同源(homologous)bug**，制造更深更均匀、连 divergence-based 方法都难检的盲区」。
- 这**正是 0/34 灾难的写照**：CC/codex/hermes/GPT Pro 通宵全程共享「训练 tool surface 与 C6 tool surface 同契约」隐含 frame，持续 subagent 审计循环+superaudit+GPT Pro 终审**全 PASS**（因 codex 诚实报 0/34=合规），**无一审计员质疑 surface 同源**，跑完才在 C6 暴露（8d-rootcause D4.3 亲核坐实）。

**修法不是「再加一个厂商」**（cross-vendor ≠ cross-frame，DevOps 实证检测器 GPT 93%→Claude 49% worse than coin flip），而是**结构性破框三件套**：
1. **人审 7 个不可委托点**（first-50 逐条 / loss-mask print / train-eval template diff / refusal 类样本 / top-failing C6 cases / generated utterance drift / final route 拍板）；
2. **≥1 个判官刻意反框**（回读一手原文 / 假设 candidate 已失败 work backward）；
3. **判官跨厂商且证据驱动**（数字下钻 axis 级，禁顶层聚合；分歧=人审触发）。

**LLM-as-judge 单独不可信，三条已知失效都打在 MAformac 痛点上**：
- **One Token to Fool**（2507.08794，已核实）：单冒号 ':' / 空格能骗判官报「命中」，GPT-4o 标点-only 35% FPR，General Verifier MATH 单空格 66.8% FPR → **正是 0/34 的 empty=hit 同病**（spike-e3:161 `toolCalls.isEmpty`→记 no-call hit）。
- **refusal 判官高发假阳**：拒识/澄清是 demo 灵魂（计 hard_pass），却是判官最不可靠维度。
- **exact-match AST 对改写降 13-19pp**（BFCL）：对 562 intent 自然中文泛化系统性低估。

**home-llm（1364★, 2026-06-11 活跃, star>1000 不降级）的 refusal 数据用自然语言+真实 reason，refusal_factor 3-6 oversample**，与 MAformac 446 假删 NO_TOOL 形成**直接对照**——人审 refusal 样本对照 home-llm 形态会一眼抓出 label conflict。

本路 **P0（横切）/ escape_hatch**：人审点能提前拦住 0/34，是唯一不依赖「码对了」假设的防线；零碰 rank16Mainline 配方，不动 A2 D-domain surface。

---

## Findings（每条带 source）

### F1 — cross-vendor ≠ cross-frame 有学术铁证
- **claim**：SPECA 以太坊客户端多实现审计实证「跨实现检查占 76.5% 有效发现」（跨厂商确实抓最多 bug），但警告「共享 LLM 推理模式独立引入同源(homologous)bug → 更深更均匀盲区」。DevOps.com 实证：安全检测器 GPT 93%→Claude 49%（worse than coin flip），6 个主流 LLM 系统测过。
- **source**：https://arxiv.org/pdf/2602.07513 (SPECA, 2026-02) + https://devops.com/your-ai-agents-have-a-blind-spot/（访问 2026-06-24）
- **vs baseline**：support claim-vs-reality §31『cross-vendor≠cross-frame』学术独立印证；support 磊哥『4 模型价值是破框非背书』——同源 bug 是「背书」失效的机制证据。

### F2 — LLM-judge 被空/标点输出骗报命中（One Token to Fool）
- **claim**：单冒号 ':' / 空格 / 'Solution:' / '解' 等 master-key 让 GPT-4o/Claude-4/o1 报假阳。标点-only GPT-4o 35% FPR；专用 verifier(General Verifier) MATH 单空格 66.8% FPR；整体可达 80% FPR。修法=对抗截断数据增广(Master-RM)降近 0。
- **source**：https://arxiv.org/abs/2507.08794 (MATH-AI 2025，已核实存在)（访问 2026-06-24）
- **vs baseline**：oppose『纯 LLM-judge 可信』；MAformac 0/34 的 empty=hit（spike-e3:161）正是此漏洞项目实例。

### F3 — refusal/拒识判官高发假阳，必须人审
- **claim**：string-match 把『I am sorry to hear about your discomfort. You should...』误判拒识；LLM-judge 对 partial refusal / 拒识后接通用信息仍假阳，研究者被迫换 GPT-5-mini + 人工标定才达高一致。
- **source**：https://arxiv.org/pdf/2509.18058 (Strategic Dishonesty) + 2603.06594 (Coin Flip，ID 待核) + One Token to Fool（访问 2026-06-24）
- **vs baseline**：support 磊哥『refusal 类样本人眼』点——拒识/澄清是 demo 灵魂但判官最不可靠 → 人审不可委托。

### F4 — exact-match/AST 对自然改写脆弱，掩盖真实能力
- **claim**：BFCL 实证改写使 AST 精确匹配掉 13-19pp，加语义相关 distractor 再掉 1-8pp，主因『精确字符串比较非语义等价』。窄覆盖(<150 条)benchmark 更易过拟合。
- **source**：https://www.spheron.network/blog/tool-calling-benchmarks-bfcl-tau-bench-latency-optimization/ + BFCL OpenReview(2GmDdhBdDk)（访问 2026-06-24）
- **vs baseline**：support C6 设计——C6 set 精确匹配对 562 intent 自然中文系统性低估 → top-failing cases 必人审区分「判等过严 vs 模型真错」（8d D4.4⑥同病）。

### F5 — refusal SFT 塌缩成 over-refusal/empty 的机制 = label conflict
- **claim**：benign 与 refusal 样本特征空间靠太近被赋不同标签(static conflict) → 模型把已知误判未知 → over-refusal；refusal 常学成表面线索耦合非泛化（带『I don't know』指令训练、eval 去指令后拒识准确率掉到 0）；小模型窄数据 catastrophic forgetting 产退化/空输出。FalseReject 测了 Qwen2.5-0.5B/Llama3.2-1B。
- **source**：https://arxiv.org/pdf/2410.06913 (Certainty Knowledge Flow) + https://arxiv.org/pdf/2505.08054 (FalseReject)（访问 2026-06-24）
- **vs baseline**：support 0/34 根因——446 假删 NO_TOOL（有效车控意图标 NO_TOOL+工具还在，8d D4.1）= 教科书级 static label conflict；人审 refusal 样本一眼抓出。

### F6 — home-llm refusal 数据形态（直接对照 baseline）
- **claim**：pile_of_refusals.csv 有 reason_type(not_available/already_state) + 自然话术（'I can not find a back door lock to control.'）；generate_refusal_example(:563) 按 case 渲染保留正确工具上下文；refusal_factor oversample 3-6x(:853-857)。
- **source**：file:`/Users/wanglei/workspace/raw/05-Projects/MAformac/ref-repos/home-llm/data/piles/english/pile_of_refusals.csv` + `data/generate_data.py:563-590,751-857` + `gh repo view acon96/home-llm`(pushedAt 2026-06-11, 1364★)
- **vs baseline**：**better than MAformac 当前 446 假删法**——home-llm refusal = 自然语言+保留工具上下文（无 label conflict）；应 adopt 自然拒识话术（方案P renderer）+真删工具，人审对照 home-llm 形态。

### F7 — cross-family judge ensemble 降 self-preference >50%（但只在真异质时）
- **claim**：三判官 panel(target+两弱自识小模型)majority vote 使 GPT-4o self-pref 82%→30%、Llama3.3-70B 79%→23%；Arena-Hard GPT-4-Turbo+Gemini ensemble 降自偏。**关键 caveat**：『三个相关判官=一个判官跑三次』，同 family 无保护；判官分歧=该人审的信号。
- **source**：https://arxiv.org/pdf/2509.00462 + https://arxiv.org/pdf/2406.11939 (Arena-Hard) + orq.ai LLM juries（访问 2026-06-24）
- **vs baseline**：support 磊哥 4 模型协议；但纠正『majority vote 投票』≠破框——真价值是『分歧=人审触发』+刻意反框，不是票数。

### F8 — 多 agent 辩论 groupthink 降准
- **claim**：同质 agent 像信念 martingale，理论证明 MAD 期望上不能超 majority vote；增辩论轮数反降准（固化早期错）；单个『自信但错』对抗 agent 降系统准 10-40%+ 把错误共识提 30%+。post-training alignment 降采样多样性 + sycophancy 加剧。
- **source**：https://arxiv.org/pdf/2509.05396 + https://arxiv.org/pdf/2601.19921 + https://www.nature.com/articles/s41598-026-42705-7（访问 2026-06-24）
- **vs baseline**：oppose『辩论越多越对』；磊哥已实践『不迎合助理辩证 check』+每~5 段 cross-section check，与此一致；警惕『自信全对的提案藏一个未解 gap』。

### F9 — HITL gate placement best practice
- **claim**：人审置于高风险决策点 + confidence-based triage（高置信自动过、不确定/低分入人审）；active learning 选最 informative 样本非随机；昂贵标注用 loss-ranking（fine-tune 后按 task loss 降序看 out-of-sample）surface 最可能误标；23.7% 误标率案例根因是标注指南缺陷非疏忽——人审抓系统性指南错。
- **source**：https://humanops.io/blog/human-in-the-loop-guide + https://intuitionlabs.ai/articles/active-learning-hitl-llms + newline labeling-error best practices（访问 2026-06-24）
- **vs baseline**：support 人审点设计——confidence-triage(规则快路高置信跳人审、L2-5/拒识/低分入人审)+loss-ranking surface C5 误标，比逐条看 4018 样本省且抓系统错。

### F10 — human review 与 LLM-judge 是互补层非竞品
- **claim**：确定性 scorer+LLM-judge 自动化广覆盖，人审兜底抓自动化漏的（尤其『技术可行但违策略/合规』的自信高分），人审抓到的失败转回归测试用例反哺 scorer——无此环路质量静默退化。判官需对人标定 corr>0.7，provider 更新后 re-validate。
- **source**：https://www.braintrust.dev/articles/llm-as-a-judge-vs-human-in-the-loop-evals + getmaxim + 2507.17015（访问 2026-06-24）
- **vs baseline**：support C6 设计——C6 自动门(verify-gold/hard_pass)+人审 top-failing→转新 C6 case 回归；符合 make verify 门+诚实锚点路线（8d P7）。

---

## 7 个人审不可委托点（落 OpenSpec task 的 acceptance，非 prose 声称）

| # | 人审点 | 为什么不可委托给 LLM-judge | 学术/项目锚 |
|---|---|---|---|
| 1 | **first-50 训练样本逐条**（不抽查） | 抓系统性 label conflict / 指南错（23.7% 误标案例靠看指南错）；446 在 4018 里 11%，抽 20 条可能全 miss | F9 newline / 8d D4.1 |
| 2 | **loss-mask print 人眼** | mask 三形态实装易错（8d 446 假删=metadata 声称非物理删）；判官看不到 loss span | claim-vs-reality 铁律1 |
| 3 | **train-eval template diff 人眼** | 0/34 根因正是 train/eval surface 异源，判官在 frame 内看不见同源问题 | 8d D4.3 / SPECA F1 |
| 4 | **refusal 类样本人眼** | 判官对拒识高发假阳（F3）；对照 home-llm 自然拒识形态识破假删 | F3/F5/F6 |
| 5 | **top-failing C6 cases 人眼** | exact-match 对改写降 13-19pp，需人审区分『判等过严 vs 真错』 | F4 |
| 6 | **generated utterance drift 人眼** | 云 generator 产语料会 drift，判官 self-pref 偏好低 perplexity 自产物 | F7 / LLM-judge self-pref |
| 7 | **final route decision 拍板** | 高 stakes 决策（candidate 签署/范式选择）无条件人审，不论判官是否一致 | elephant#2 |

## 4 模型交叉破框协议（非互相背书）

**反模式（背书）**：4 模型同 prompt 互审 → majority vote 3 票通过 → 当作绿灯。SPECA/groupthink 证此为同源盲区温床。

**正解（破框）**：
1. **≥1 判官刻意反框**：回读一手原文（让判官读 home-llm pile_of_refusals.csv 对照 MAformac 假删法）/ 假设 candidate 已失败 work backward（pre-mortem inversion）。
2. **判官跨厂商 + 证据驱动**：数字下钻 axis 级（base 10/23 vs lora 0/23）非顶层聚合 7/57（8d D4.4③）；judge 与 candidate 强制跨 family（self-eval 禁）。
3. **分歧=人审触发 + 一致也警惕**：判官分歧强制人审；但 0/34 恰是 4 模型【一致】通过——**一致才是最危险（集体盲区）**，故高 stakes 决策无条件人审+反框，不论是否一致（elephant#2）。
4. **重大 frame 显式 surface 给磊哥独立判**：如『拒识 SFT vs 端 renderer 确定性生成（方案P）』不进 majority vote，磊哥独立拍。

---

## 假想验证（磊哥点名重点）

**场景：4 模型都说 candidate 好但共同遗漏同一 frame（如都没质疑『拒识用 SFT』）**

- **预测结果**：会发生，且只靠加判官拦不住，必须人审+刻意反框——**有 0/34 实证铁证**：4 模型共享『训练/C6 surface 同契约』frame，全程审计 PASS，跑完才暴露（8d D4.3）。
- **依据**：(1) SPECA 同源 bug 机制（2602.07513）；(2) groupthink 理论（同质 agent 期望不超 majority vote，加轮反固化错，2509.05396）；(3) over-refusal label-conflict 文献（2410.06913/2505.08054）证 refusal SFT 易塌缩——若 4 模型都默认『SFT 教拒识天经地义』不质疑『vs 端 renderer 方案P』就集体漏。
- **在哪拦住**：(a) 人审 refusal 样本（点#4）逐条对照 home-llm 形态，一眼发现『446 有效意图标 NO_TOOL 而工具还在』；(b) 反框判官回读 home-llm 一手破 frame；(c) cross-section 下钻 axis 不信顶层聚合。
- **失败模式**：人审抽查不逐条（11% 漏）/ 判官投票非分歧触发 / 人审看 receipt 非实跑复算（8d P7）。修法：first-50 逐条 + loss-ranking + 分歧强制人审 + ≥1 反框回读一手。
- **对 rank16Mainline**：纯治理/审核流程，零碰配方，不动 A2 surface，不引入训练/评测/voice/受限解码实装 → escape_hatch（配方不变前提下加防线防 0/34 重演）。
- **unknown 边界**：4 模型『一致通过但集体漏 frame』的实际发生率无法量化（无 MAformac 自身基线），只能定性确认威胁真实存在（0/34 是 N=1 实证）；人审能否每次 catch 取决于执行纪律（逐条 vs 抽查）非机制保证 → 靠 enforce（task acceptance）非自觉。

---

## Pre-mortem 三分类

### Tiger（明确威胁+验证清单）
1. **人审退化成抽查/看 receipt**：446 在 4018 占 11%，抽 20 可能全 miss；8d D4.4③实证 CC 自己栽在信顶层聚合。验证：① first-50 逐条 Read 不抽查 ② 人审输入必须实跑 train.jsonl 复算/下钻 gate_result，禁只看 receipt ③ 人审点落 OpenSpec task 可核验产出（N 条记录+决策）非 prose 声称。
2. **cross-vendor 误当 cross-frame 兑现**：派三厂商就以为破框，SPECA 证同源 bug 仍在；majority vote 在 frame 内强化。验证：① 终审明写『≥1 判官刻意反框』非全同 prompt 互审 ② 分歧=强制人审触发非投票多数决 ③ 重大 frame surface 给磊哥独立判。
3. **LLM-judge 兜底层自己被 master-key 骗**：C6 引 LLM-judge 解 paraphrase 脆弱时，judge 被空/标点/'Solution:' 骗（One Token to Fool 35% FPR），复制 empty=hit。验证：① C6 LLM-judge 必注入对抗截断负样本(Master-RM 法) ② judge 与 candidate 强制跨 family ③ judge 对人标定 corr>0.7 才采信，否则只 screening 不 certify。

### Paper-tiger（看似威胁实际安全+证据）
1. **『多模型辩论越多轮越准』**：实为 tiger 但磊哥已防住——增轮反降准（2509.05396），但 grill-decisions 已实践『不迎合助理辩证 check』+每~5 段 cross-section check，已有纪律覆盖 → 标 paper-tiger。
2. **『人审太慢拖垮 demo 节奏』**：HITL best practice 是 confidence-triage（高置信自动过，只人审不确定/低分）非全量；active learning+loss-ranking 聚焦最 informative；7 点都是一次性 gate 非每样本，轻治理可承受。

### Elephant（没人提但该提）
1. **人审者本身有 automation bias**：人看 AI 高分倾向附和，人审若先看判官分数=被污染。修法：盲审（不看判官结论）再对照，或人审与判官并行不串行。
2. **『分歧=人审触发』漏掉『一致盲区』**：0/34 恰是 4 模型【一致】通过——一致才最危险（集体盲区）。除分歧触发，加『高 stakes 决策无条件人审+反框』，不论一致与否。
3. **CC 主线程 self-preference 结构性在场**：CC 既产出又综合，8d D4.4 实证 CC 两轮 confounder 自己没 catch 靠异源。修法：CC 主线程的产出（综合/定性）必须有非-Claude 异源 catch + cite-verify 分层级（核一手代码 file:line 非派生 receipt）——这是 claim-vs-reality §16 同 family bias 的项目实装。
4. **人审点写成 prose 会复制 metadata 声称病**：下一步 propose gate task，人审点若 prose『应人审 X』而非 code-enforce 的 task acceptance，复制 0/34『metadata 声称 vs code enforce』根因（8d 铁律1）。人审点必须落 OpenSpec task 可核验 acceptance（N 条人审记录）。

---

## must_answer 5 答
1. **prevents_0_34**：yes — first-50 逐条+refusal 类样本人审是唯一能提前拦 0/34 的防线（不依赖『码对了』假设）；刻意反框判官回读一手破集体 frame。
2. **vs_rank16mainline**：escape_hatch — 纯治理/审核流程，零碰 rank16/scale20/LR1e-4/adamw。
3. **requires_a2_surface_change**：no — 不动 A2 D-domain surface，作用于数据/eval/决策层，正交。
4. **introduces_deferred**：no（边界内）— 产出 pre-propose 决策弹药供写 gate task；不实装训练/评测/voice/受限解码；C6 LLM-judge 对抗注入仅作弹药，标清属 deferred rebuild-c6 不越界。
5. **priority_self**：P0（横切）。

---

## external_claims（待主线程亲核，不硬编）
- arxiv 2603.06594（Coin Flip）/ 2604.10079（Incomplete Learning）——ID 是未来日期(2026-03/04)，WebSearch 自己 flag 待核；论点 load-bearing 低，已用 2509.18058 等替代为主证。
- arxiv 2602.07513 SPECA『76.5% 有效发现』——精确数字待 gh/WebFetch 核（cross-vendr≠cross-frame 量化锚）。
- One Token to Fool FPR（标点 35%/单空格 66.8%/整体 80%）——2507.08794 已核实存在，具体 Table 1 数字待抽核。
- Algorithmic Hiring self-pref 降幅（82%→30%/79%→23%）+ BFCL 13-19pp/1-8pp——精确数字待核（后者来自 Spheron 二手转述）。
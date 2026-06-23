# Claude Code 三痛点调研 — 待办清单 + 9 Grill 问题清单（2026-06-22）

> **来源**:ultracode 7-lens 调研(本目录 `lens1-7` + `README.md`)+ probe 文档级联(`~/workspace/data/exports/probe-agent-doc-cascade-20260622.md`)。
> **两调研独立收敛到同一工程动作**:把纪律从 `rule`(声称层,max 仍犯第10坑)下沉到 `hook`(enforce 层)。
> 本文件 = 后续 grill 拍板 + 执行的 actionable 清单。**起手先看 §0 真实性总账,别引编造数字。**

---

## 0. 🔴 真实性总账(CC 主线程亲核 cite-verify,2026-06-22,引用前必看)

> 综合官亲核了**本机**(§0.1 grep/cat 坐实 + catch 8→12 hook + catch 67% 凭印象数字降为 ~3%),但**没核外部 issue/arxiv/repo**。CC 主线程亲核外部,catch 出 finder 编造:

| 声称(README 引) | 亲核结果 | 处置 |
|---|---|---|
| 🔴 issue #42796「234760 调用 / 改未读文件 6.2%→33.7% / 5.4x / 官方原话 gravitates toward least reasoning」 | **纯编造**——issue #42796 真实但是**定性抱怨**(「Claude regressed, ignores instructions, claims simplest fixes incorrect」),**无任何这些数字/原话** | **禁引这些数字**;论点(CC 浅思有真实 issue 抱怨)成立,但量化是 finder 凭印象编的(第8坑复发) |
| 🟡 Inverse Scaling arxiv `2603.05344` | **ID 编错**——真实 = `2507.14417`(Anthropic Fellows Program/TMLR 12/2025);**论点对**(五失败模式第一条:Claude 越 reason 越被无关信息带偏=effort≠深度官方盖章) | 引论文**用 `2507.14417`**;论点可信 |
| ✅ ETH Zurich 138-repo `2602.11988` | 真实(AGENTbench 138 tasks/12 Python repos✅;LLM-gen 降 0.5-3pp;人写 +4%;CC 唯一连人写都没帮助);综合官 S4 nuance(LLM-gen vs human-written)引对 | 可信 |
| ✅ grounded(Pinperepette)27★/2026-04-25 · Mneme(TheoV823)14★/2026-06-18 · superpowers(obra)235K★/today | gh 核全真实 | 可信 |
| ✅ 本机 §0.1(零 cite hook / 冷开零 handoff 注入 / pre-tool-guard safety-only / 12 hook) | 综合官 grep/cat 坐实 | 可信(决策锚) |

**元层洞察(最该记)**:这个专门调研「CC 凭印象/浅思」的 workflow,**finder 自己就犯了「凭印象编精确数字 + arxiv ID」(第8坑)**,综合官做了部分 cite-verify(本机+67%)仍漏外部。**= 「enforce > 自觉」结论的活自证**:声称层 cite 在任何 effort/专注度都会漏。**核心收敛不依赖编造数字——被真实 repo + 真实论文论点 + 本机 grep 多重支撑,去掉编造仍 100% 成立。**

---

## 1. 待办清单(含 A / B / C)

### ✅ TODO-B(已完成 2026-06-22):回写 README 纠正 + 记 CHANGELOG
- [x] README 纠正 issue #42796 编造量化:顶部加 🔴 banner + L3矩阵/§1.1收敛/§3.5DROP/PT7/G9 共 **5 处就地标注「编造已删」**(保留论点,删 234760/6.2%→33.7%/5.4x/6.6→2.0)
- [x] README arxiv `2603.05344` → `2507.14417`(:37 含 CC 纠正注)
- [x] 记 `~/workspace/CHANGELOG.md`(2026-06-22 entry,含 cite-verify catch 表 + 元层自证)
- **理由**:probe 结论——报告自己也会 drift,编造数字不纠 = 这份报告成下个窗口的污染源(讽刺地正是文档级联话题)。

### 🔵 TODO-A(主线,grill 拍板后执行):enforce 层落地
> 两调研合流的核心工程 = 把声称层纪律下沉 hook。**三层纵深**(单 hook 是陷阱):
> - 第1层 确定性 grounding:Stop hook 读 last_assistant_message 扫 file:line/数字 → 缺则 block(骨架 disler `validate_file_contains.py` 3785★ 迁 2.1.177 schema)
> - 第2层 语义/frame:SubagentStop/重大决策 → **异厂商 grader**(GLM-5.2/hermes)cite-verify(绝不用同 Claude 家族=循环失守)
> - 第3层 recognition:claim-vs-reality rule 继续 always-on
- [ ] grill 拍 §2 的 G1-G9(尤其 G1 拦哪层 / G2 grader 用谁 / G3 max 校准 / G4 冷开 handoff)
- [ ] grill 拍 §3 的 probe G1-G4(§35 级联 enforce / grill-decisions 拆 ADR / MEMORY staleness / ROI 边界)
- [ ] BUILD B1 cite-verify hook(项目级 `.claude/` 先试 → 实测 Stop 并发+误伤 → 全局)
- [ ] BUILD B2 冷开 handoff 注入(复活 UserPromptSubmit hook,E4 黄金点)
- [ ] guardrail:matcher 极窄(只拦写进契约 SSOT/基线文档的 load-bearing 数字)+ fail-closed + 防 cite-reminder 自己过期
- **硬边界**:hook 验 grounding(file:line 存在)是天花板,**验不了 correctness(过期 smoke 值 grep 一样命中)** → 必叠异源审计 + 人兜底。

### 🟢 TODO-C:收工 handoff
- [ ] 今天信息量大(C5 recovery grill marathon + ultracode 7 路 + probe 文档级联),收口写/更新 handoff,锁两调研结论 + 待办。

### 其他(从 README ADOPT/ENFORCE/DROP 提炼)
- [ ] ADOPT A2:superpowers 精确措辞「no cached from 10min ago」写进 claim-vs-reality 铁律2(只 adopt 措辞不装 skill)
- [ ] ADOPT A3:claude-mem 12.1.0→13.8.0 升级(**磊哥已否决扩大用 claude-mem,空间浪费——此条降级为"仅核现状是否移除",见 §0 claude-mem 约束**)
- [ ] ADOPT A4:Cross-Context Review 纪律——cross-vendor 派单**不 prepend CC 推理链**,收敛 1-2 轮(More Rounds More Noise)
- [ ] ENFORCE E1:Stop hook 漏写 handoff plain stdout → conditional block(`stop_hook_active` 守护防死循环)
- [ ] ENFORCE E3:max-effort 长链路警示回写 ultracode-7lens rule(opus-4-8 max → 失忆更重)
- [ ] DROP(明确不做):不装 anti-shallow skill(安慰剂)/ 不用 mem0-Zep 替代 MEMORY.md / 不转 rule 为 skill / 不加 token 阈值 hook / 不寄望 CC 升级自动修(by-design)

---

## 2. 9 个 Grill 问题(ultracode README §5,每条 topic + 选项 + ⭐默认 + 量化)

**G1 — 第10坑 hook 化:做不做 + 拦在哪层?**
- A. 不做,继续靠 rule + 异源审计 / B. PreToolUse 硬 deny / C. ⭐ **Stop-文本-扫描(读 last_assistant_message 扫 file:line/数字,缺则 block 喂回)+ 异源 grader 二层**
- 量化:第10坑数字在【文本生成】不走 tool call → PreToolUse-deny 拦不到(B 漏底);Stop block 绕 #24327 停机坑;hook 验 grounding 是天花板验不了 correctness → 必叠异源。**单 hook=陷阱,三层纵深才成立。**

**G2 — cite-verify hook 的语义判断用谁?**
- A. 同 Claude(Haiku 单轮)/ B. ⭐ **异厂商(GLM-5.2/hermes,走 SubagentStop 自动门)** / C. 纯确定性 string-match
- 量化:第10坑是异源 GLM-5.2 catch 的,机理=self-correction blind spot(同样的错自己改不了、外部输入能改);用同 Claude=同 family bias 循环失守(铁律1 致命变体)。**A 必踩 E2 大象。**

**G3 — 磊哥默认开 max effort,在 opus-4-8 上还要不要默认拉满?**
- A. 继续全局 max / B. ⭐ **分任务校准:L1 机械步用 high+控频或 Sonnet,L2+ 模糊多步才 max,关键收口步 pin 4.7** / C. 全降 high
- 量化:#64991 Andon Labs 实测 opus-4-8 max → 5x token → 2x compaction → 失忆更重(4.7 不发生);Inverse Scaling(Anthropic 自家 `2507.14417`)证越 reason 越被无关信息带偏。**effort≠深度有官方盖章。**

**G4 — 冷开窗口零 handoff 注入,补不补?**
- A. 不补(靠手动 Read)/ B. ⭐ **复活 UserPromptSubmit hook(首轮注入最近 handoff 摘要)** / C. 扩 session-start-compact 到 SessionStart matcher=''
- 量化:本机坐实冷开零 handoff 注入,`session-closure.md:91`「自动注入」是声称层(rule 自己中招);UserPromptSubmit 是唯一每轮触发+可 additionalContext 黄金点,现空转(E4)。**B 一石二鸟。**

**G5 — Stop hook 漏写 handoff:升不升 block?**
- A. 保持 plain stdout(靠自觉)/ B. ⭐ **conditional block(漏写且非只读→block,写 handoff 一动作消除)**
- 量化:2026-06-07 从 block 回退因死循环;加 `stop_hook_active` 守护+不撞 8 次 cap 即安全。漏写=下次失忆,plain stdout 可被忽略。

**G6 — claude-mem 升不升级 + 要不要更激进用它?**
- A. ⭐ **只升 12.1.0→13.8.0 作 handoff 补充** / B. 替代手写 handoff / C. 不动
- 量化:artifact tracking 2.19-2.45/5.0(自动压缩弱),原生 memory「saves knowledge not state」;grounded 派 handoff 更可审计。**B 是降级(PT3)。** ⚠️**磊哥已否决扩大用 claude-mem(空间浪费)→ 此题实际倾向 C/核现状是否移除。**

**G7 — 装不装 anti-shallow skill(superpowers/research-mode/Karpathy)?**
- A. ⭐ **只 adopt 精确措辞写进 claim-vs-reality 铁律2,不装任何 skill** / B. 装 superpowers / C. 装 research-mode
- 量化:anti-shallow 类全是 SessionStart 注入=与 always-on rule 同机制,max 已证失效;§25/§27 已比 Karpathy 更细;作者自认「prompt not hard constraint」。**装=重复武装声称层安慰剂(Elevate-or-Kill)。**

**G8 — 异源审计派单要不要禁 prepend CC 推理链?**
- A. 现状(可能 prepend)/ B. ⭐ **铁律:cross-vendor 派单只给 artifact+spec,不 prepend CC 推理链,收敛 1-2 轮**
- 量化:Cross-Context Review 证收益来自 context 分离本身(F1 28.6%>24.6% p=0.008),prepend 退化成 context-aware subagent;More Rounds More Noise。**A 让异源审计悄悄退化。**

**G9 — read-before-edit 轻量门(补实现侧开口)做不做?**
- A. 不做 / B. ⭐ **PreToolUse 软提示(没 Read 过 file_path 就提醒,用 exit 0+JSON 不用 exit 2)** / C. 硬 block
- 量化:磊哥围栏偏诊断侧,实现侧 codex 长跑 read-before-edit 无设防;但 Edit+Bash 并发未验证 + #24327 idle bug → 软提示先稳。**C 踩停机坑。**(⚠️ 原 README 此处引 #42796「6.2%→33.7%」已证编造,论点"实现侧无设防"仍成立但删该量化)

---

## 3. probe 文档级联 4 Grill(与 ultracode 合流——都指向 enforce 层)

**pG1 — §35 基线文档组级联 enforce 化**
- rule 声称 / ⭐ **`make verify` cross-section check 脚本**(检数字/状态/行号/SUPERSEDED 一致性)
- 量化:与 ultracode B1 cite-verify hook 同源,可合并;~200 行脚本。

**pG2 — grill-decisions 单文件 vs per-decision(第9变体段间分叉根因)**
- 守单文件 / ⭐ **收口时稳定决策提炼成 openspec ADR(一决策一文件 superseded),grill-decisions 降 working log**
- 量化:业界 ADR 标准=一决策一文件物理隔离(Fowler/AWS);本 session 15 决策塞一文件=段间分叉根因。红队:单文件便 grep 全链(grill 期守单文件)。

**pG3 — MEMORY.md staleness(v10 旧状态 auto-load)**
- 现状 / ⭐ **加 as-of 时间戳 + auto-load 高亮最新指针**
- 量化:本 session 已暴露(v10 训练期旧状态 auto-load);mem0 证 memory staleness 是 2026 开放问题。

**pG4 — enforce ROI 边界(防过度治理)**
- 全文档级联 / ⭐ **只 enforce 基线文档组(roadmap/exec/8d/契约 SSOT)**
- 量化:demo solo 轻治理,E6 caveat 小任务 spec overhead 不值;enforce 脚本自己也会 drift,谁维护要想清。

---

## 4. 待解之问(grill 落地前想清)
❔ enforce hook 检测到 drift 后**由谁修**——agent 自动修(可能引新错)还是必须人审?这个 review gate 成本会不会又回到「靠 agent 自觉认真审」,把第10坑从"写文档/代码"挪到"审 drift"?(probe 待解之问 + README E2 hook 循环失守同源)

---

## 5. CC 主线程辩证补充(2026-06-22 读全 9 档 + probe 后新增)

> CC 主线程读全 lens1-7 + README + probe,辩证 catch。**⚠️ 引 lens 数字一律二手**(TODO §0 已证 finder 编造 #42796 量化 234760/6.2%→33.7% + arxiv ID 错;CCR 28.6%/#64991 5x→2x 未主线程核,标二手)。可信锚 = 本机 grep(零 cite hook/12 hook/冷开零 handoff)+ gh 核过 repo(grounded 27★/claude-mem 83.6K★/Mneme 14★)+ Anthropic 自家 Inverse Scaling(2507.14417)。

### 5.1 CC 4 开放点归位
- staleness → **pG3 已覆盖**(不重复)
- enforce vs 扳机边界 → 升级 **N3 + N5**
- 四套 enforce 合一 → 升级 **N2**
- 三缺陷与 enforce → 升级 **N5**

### 5.2 新增 grill 议题 N1-N5(去重 G1-9/pG1-4,辩证读出已有未覆盖)

**N1 🔴 research/ultracode workflow 产出的 cite-verify enforce**
- 张力:这个调研「CC 凭印象」的 workflow,**finder 自己编造 #42796 量化 + arxiv ID**(§0),综合官+主线程 cite-verify 才 catch 部分。workflow 产出进决策前的 cite-verify 要不要 enforce?
- ⭐ workflow return schema 强制每 load-bearing 数字带 `source: url/file:line`,主线程 gate 抽查异源核(与审计框架 C++ recompute verifiable 同源,应用到 research)。
- 量化:本次 finder 编造 ≥2 处/报告;不 gate = 报告成下窗口污染源(讽刺地正是文档级联话题)。

**N2 🔴 审计框架 C++ ⊕ amnesia enforce(B1/pG1/grounded)合并统一**
- 张力:审计框架 C++(candidate signing sign-or-block)+ ultracode B1(cite-verify hook)+ probe pG1(make verify cross-section)+ grounded(每-edit/claim 级)= **同一套 enforce 基础设施,散在 C5-recovery + amnesia 两条 grill 线** → 违「建第二套」§7。
- ⭐ 统一设计「分尺度 enforce 层」:grounded 级(每 edit/claim)+ C++ 级(candidate signing)+ pG1 级(文档 cross-section),共用 recompute verifiable + 异源 grader 内核。
- 量化:三套各自实现 = 3 脚本维护+drift;合一 = 一个 `make verify` doc-gate + 一套异源 grader。**地基议题,先 grill。**

**N3 enforce 最后一公里(drift 后谁修 + 防 review gate 成新第10坑)**
- 张力:Red Hat 直觉检查「别用上工具逃避扣扳机」+ 待解之问❔(§4)。enforce 不消除扳机/人,只移动位置。
- ⭐ enforce = 「最后防线非替代扳机」:drift → feedback-loop 喂回原 agent 修(非自动改引新错,Anthropic 官方取向 lens7 E2)+ 重大 surface 人;明确 enforce 治 mechanical(段间分叉/grounding),治不了 correctness/frame(仍扳机+异源+人)。
- 量化:hook 验 grounding 是天花板(lens7 F11),过期 smoke 值 grep 一样命中 → 单 hook 必漏。

**N4 grounded 现成 adopt vs build(G1「hook 拦哪层」具体化)**
- 张力:lens5 `grounded`(27★ Pinperepette,PreToolUse edit-guard + PostToolUse truth-layer + Stop confidence-check)机制最精准命中第10坑,但 star 低 + 与磊哥 hook 拓扑冲突(T1:Stop 已有 claude-mem 30-90s + Edit hook 取消 Bash 未验证)。
- ⭐ adopt grounded **机制思路**(confidence-check/truth-layer)+ build 磊哥版(迁 2.1.177 schema,先项目级 `.claude/` 隔离实测 Stop 并发/误伤,**不直接 grounded install 全局**);骨架迁 disler validate_file_contains.py(3785★)。
- 量化:grounded star 低不直接装,但机制是现成蓝本。

**N5 三缺陷与 enforce 边界:一个门 vs 分治 + 哪些纯扳机**
- 张力:lens3 E3/E5「失忆与浅思同根 context rot,关键一手源每次 claim 前强制重取 = 一个门治两病」vs 分开治;且「不深入代码到 SSOT 是纯扳机,hook 验 grounding 不验 correctness 抓不到」。
- ⭐ 一个门(claim 前强制重取一手源)治失忆+浅思两病;但 correctness/frame(第10坑源错/版本错位)hook 抓不到 → 仍异源+人。**enforce 边界写进 rule,别让脚本制造「有兜底」松懈**。
- 量化:lens3 E2 overconfidence 治不掉 = 门必须验**客观产物**(实际 Read/grep tool history)不验模型自评「我读够了」。

### 5.3 grill 顺序建议
**N2(合并统一,地基)先** → N4(grounded adopt vs build,机制选型)→ N1(research enforce)/ N3(最后一公里)/ N5(边界);与已有 G1-G9(hook 落地)/pG1-pG4(文档级联)合流到「一套分尺度 enforce 层」设计。

### 5.4 这 session 的活案例(自证,最该记)
CC 主线程开 max + opus-4-8[1m] 多 agent,**本 session 反复犯第10坑变体(凭 config 渲染产物/版本错位/印象数字)被 GLM-5.2 catch 多次 + malformed 掉 antml:**(#63604/#64991 实证)。**= 整个调研结论(effort≠纪律,必 enforce)的活自证**。G3(max 校准)对我直接成立:关键收口/cite-verify 步该 pin Sonnet 4.6/4.7 或降 effort。

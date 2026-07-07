# C5 Recovery Grill — Amend 决策文档（审计框架 + Harness Enforce 层）

> 2026-06-22 · 本文档 = `grill-decisions.md` 的 **amend / 续篇**,放「审计框架收尾(批1) + Harness Enforce(批2-5)」这一轮 grill 拍板。
> 🔴 **为什么单独文件(pG2 决策 + §35)**:`grill-decisions.md` 已 15+ 段 append-only,再 append 加重段间分叉(claim-vs-reality 第9变体根因)。本轮决策单独成文,原文档头/尾加指针,防分叉。
> **权威边界**:审计框架 + harness enforce 以**本文档**为准;C5 训练决策(Q1→θ-data / η / θtrain / marker)仍以 `grill-decisions.md` 为准。两者平级互补。
> ⚠️ **max 校准(助理提醒 + amnesia §5.4 自证)**:本轮 grill(发散)跑 max OK;但 **spec drafting / 异源审计等收口步 pin Sonnet 4.6/4.7**(opus-4-8 max 长链路 → token 暴涨 → compaction 翻倍 → context collapse,README E1 / #64991 / #63604,本 session 已 malformed 自证)。
> **元纪律(本轮调研核心)**:enforce 层自己不能成新声称层 → 每条 mechanical 防御必须**脚本自打 / 路径决定 / 固定模板**,不靠 agent 自觉填字段(否则第10坑挪位置)。

---

## 批 1/5 — 审计框架收尾（C5-recovery · 5 题全⭐ + 全加强）

> 方向 = CC 5 题 ⭐;加强 = 助理逐题补「防自己成新声称层」的 mechanical 防御层(CC 辩证独立验证全成立 = 同一内核:agent-自打 → 脚本/路径/模板自打)。

### A1 · 审计框架议题2 = B（结构化字段 + 抽查 grep + 异源正交）
- **decision**: B —— claim 带 `{value, source, claim_type}`,sign-or-block 抽查 grep 验证 source 真含 value;frame 维度靠异源正交。
- 🔴 **mechanical 深化(claim_type 脚本自打非 agent 自打)**:`claim_type` 枚举**路径决定 + 脚本自打**——`Reports/*`→`rendered_product` / `contracts/*`→`ssot_authoritative` / `docs/research/*`→`derived_metric` / `path:N` 格式→`file_line_ref`。**agent 自打 claim_type = 又一声称层**(标错就 escape);scale32 在 `Reports/` 被脚本自动标 `rendered_product` 才是真 mechanical(露馅它不是 SSOT)。

### A2 · G27 审计加语义维度 + 强制实跑复算（复算分级）
- **decision**: 都加 —— 审计加「语义正确性维度(surface/scorer/口径同源)」+「审计员必 python 复算一手(下钻 axis/样本),不只读 receipt 顶层」。
- 🔴 **mechanical 深化(复算分级,防形式主义反噬)**:python 复算**成本分级写进 SOP**——`candidate signing` 必复算 / `PR-level audit` random 抽 1 处 / `handoff 写完` 不要求。不分级 = 审计员(人/agent)负载下跳过 = 第10坑挪位置。
- **anchor**: 8D P7 + claim-vs-reality 铁律2。

### A3 · G27b spike-e3 不验 args（标 deprecated + linter 拦）
- **decision**: 并入 `C6VehicleToolBench` hard_pass 验 args+state_delta,`spike-e3:158` name-only 降 smoke。
- 🔴 **mechanical 深化(spike-e3 处置)**:spike-e3 标 `deprecated_smoke` **不删**(保 baseline 历史 + 0/34 复盘可溯源);**linter 拒绝 release receipt 引用 spike-e3 数据**(release gate 必须引 `C6VehicleToolBench` hard_pass)。
- **anchor**: 0/34 = name-only 25 掩盖 args 错。

### A4 · G28 异源终审（分级）
- **decision**: candidate 签必异源终审(同源不代替)。
- 🔴 **mechanical 深化(异源分级,防成本压垮 solo demo)**:异源 ≠ 每次派异厂商——`candidate-level` 必异厂商终审(GLM-5.2 / hermes) / `PR-level` 同源 subagent 够 + 主线程 spot check / `decision log` 自证够。
- **anchor**: 本 session GLM-5.2 异源 catch CC 多次 = 实证;§16 + self-correction blind spot(同样的错自己改不了、外部输入能改)。

### A5 · G29 grill frame 纪律入 checklist（固定模板问句）
- **decision**: 重大训练 change 必过 frame-check,入 grill-with-docs 硬段。
- 🔴 **mechanical 深化(5 题固定模板,非 prose「必问」)**:grill-with-docs prompt 模板**固定 5 个 frame 问句**——① 训练/eval/runtime surface 同源吗 ② 数字来源 file:line 还是聚合 ③ `claim_type` 是 rendered_product 还是 SSOT ④ 异源审过吗 ⑤ frame 谁定的。prose「必问」= 声称层(rule 自己中招同坑)。
- **anchor**: 0/34 escape = frame 盲区(无人质疑训练 `tool_call_frame` vs C6 `set_cabin_*` 同源);8D D4.3 P8。

---

## 批 2/5 — Hook 落地核心（G1/G2/G4/G5/G9 · 5 题全⭐ + mechanical 深化 + 3 EN）

> 让其他窗口「不失忆(H1 冷注入)+ 不凭印象(H2a grounding)」。每题方向⭐ + mechanical 深化(防成新声称层)。

### B1 · G1 第10坑 hook 化 = C（Stop-文本-扫描 + 异源 grader 二层）
- **decision**: C —— Stop hook 读 last_assistant_message 扫 file:line/数字 → 缺则 block 喂回(feedback 非 deny);异源 grader 二层语义核。
- 🔴 **mechanical**: matcher 极窄(只扫写进 `contracts/*`/`docs/**` 的 load-bearing 数字非全文)+ feedback 非 deny(绕 #24327)。
- **anchor**: lens7 F3(Stop last_assistant_message)/F11(grounding 天花板);第10坑数字在文本生成不走 tool call → PreToolUse-deny 漏底。

### B2 · G2 cite-verify 语义判断 = B（异厂商）
- **decision**: B —— GLM-5.2/hermes 走 SubagentStop 自动门。
- 🔴 **mechanical**: 异源分级(同 A4:candidate 必异厂商/PR spot check),不每次派;**绝不同 Claude 家族**(循环失守 E2)。
- **anchor**: 第10坑 GLM 异源 catch;lens7 E1/E2。

### B3 · G4 冷开 handoff 注入 = B（复活 UserPromptSubmit）= H1
- **decision**: B —— UserPromptSubmit hook 首轮注入最近 handoff 摘要。
- 🔴 **mechanical**: 注入【静态指针】("读最近 handoff X")非【动态值】(防 resume replay 过期,lens7 E3);首轮标记 `first-prompt-done` 防每轮堆 context(助理 EN1)。
- **anchor**: 本机坐实冷开零 handoff 注入(`session-closure.md:91`「自动注入」是声称层 rule 自己中招);lens1 E1/结构洞1。**磊哥「其他窗口自信」核心。**

### B4 · G5 Stop 漏写 handoff 升 block = B（conditional）
- **decision**: B —— 漏写且非只读 → block,写 handoff 一动作消除。
- 🔴 **mechanical**: `stop_hook_active==true→exit0` 守护 + reason「一动作可消除」+ 不撞 8 cap,三条齐才升 block。
- **anchor**: 2026-06-07 回退是没守护;lens1 T3。

### B5 · G9 read-before-edit 实现侧门 = B（软提示）
- **decision**: B —— PreToolUse 软提示(没 Read 过 file_path 就提醒)。
- 🔴 **mechanical**: `exit 0+JSON` 不 `exit 2`(避 #24327)+ 软提示先稳,Edit+Bash 并发实测后再硬化。
- **anchor**: 实现侧 codex 长跑 read-before-edit 无设防;lens6 E4。

### 📋 execution note（写 spec 时附,不另 grill）
- **EN1 事件冲突核(助理 + 🔴CC 补发现型)**:Q6(Stop 每轮)vs Q8(UserPromptSubmit 首轮)不同事件不互锁,分两个 mjs 不加锁(助理)。🔴 **CC 补**:Q6 新增 Stop hook 必与磊哥**现有 Stop 拓扑**并发安全核——助理只核 Q6 vs Q8,漏了 Q6 vs 现有 Stop。**🔴 v3 亲核纠正(SUPERSEDES 原「claude-mem 30-90s」,settings.json 一手)**:Stop 现役**仅 `session-stop.mjs`(~10ms plain stdout),无 claude-mem**(已按 D1 禁,非 hook);原写「claude-mem summarize 30-90s」是凭 parallel-safety rule 历史拓扑=**第9变体污染**(已纠);cite-verify Stop 叠加 ~10ms 无碰撞。
- **EN2 hook 自身 verification marker(助理,防 CVE E8)**:用户级 `~/.claude/scripts/*.mjs` only(项目级 `.claude/` hook **不做**,CVE-2025-59536/2026-21852 面);`make verify-hooks: node --check *.mjs && shasum -a 256 *.mjs > .hooks.sha256`(同 C5 repo loop verification marker 结构,轻量 ~5 秒)。
- **EN3 守边界 5 条进 spec banner(助理)**:① enforce 治 mechanical 治不了 correctness → 仍异源+人 ② 语义 grader 必异厂商 ③ H2a 项目级先试 1 周误伤<1/3 再全局 / H1 用户级一步到位(零误伤)④ feedback 非硬 deny ⑤ hook 降低对自觉依赖**非替代扳机**(写每个数字时思考动作不减)。
## 批 3/5 — 文档级联 probe（pG1-pG4 + N3 · 5 题全⭐ + mechanical + EN3/EN4 + ex-post 边界）

> 文档/决策不分叉、不 stale = 其他窗口读到的是最新单源(非 v10 旧状态)。

### C1 · pG1 §35 级联 enforce = make verify cross-section check
- **decision**: `make verify` cross-section check 脚本(检数字/状态/行号/SUPERSEDED 跨段一致)。
- 🔴 **mechanical**: 只查 internal 一致性,**不查 correctness**(值一致但错 hook 抓不到,N5 边界);与 H2a 同源 → **N2 合并**。
- **anchor**: 今天 claim-vs-reality / MEMORY / TODO 三文件被并发改 = 活案例。

### C2 · pG2 grill-decisions 拆 ADR = 收口时提炼
- **decision**: 收口时稳定决策提炼 openspec ADR(一决策一文件 superseded),grill-decisions 降 working log。
- 🔴 **mechanical**: **时机=收口非现在**(grill 期守单文件 + cross-section);本 session amend 文档 + 头尾指针 = pG2 轻量实践。
- **anchor**: 业界 ADR 一决策一文件(Fowler/AWS)。

### C3 · pG3 MEMORY staleness = as-of 时间戳（分两步 EN4）
- **decision**: MEMORY 每条加 `as-of` 时间戳 + auto-load 高亮最新指针。
- 🔴 **mechanical**: 现在加 `as-of` 字段(构架就位,手工)/ H2a 落地后 hook 自动比对 `as-of` vs handoff 最新日期 flag。
- **anchor**: v10 旧状态 auto-load 暴露 + MEMORY 被并发改。

### C4 · pG4 enforce ROI 边界 = 只基线文档组
- **decision**: 只 enforce 基线文档组(roadmap/exec/8d/契约 SSOT/grill-decisions/amend)。
- 🔴 **mechanical**: 路径白名单明列,非全 `docs/**`;spec 写清「脚本自己 drift 谁维护」。
- **anchor**: solo 轻治理,E6 小任务 overhead 不值。

### C5 · N3 enforce 最后一公里 = feedback 喂回原 agent
- **decision**: drift → feedback 喂回原 agent 修(非自动改引新错)+ 重大/反复 surface 人。
- 🔴 **mechanical**: enforce **不消除人/扳机只移动位置**;别让 review gate 成新第10坑。
- **anchor**: 待解之问❔ + Red Hat 直觉检查。

### 📋 execution note（写 spec 时附）
- **EN3 cross-section 只检存档态非编辑态(助理 + 🔴CC 补)**:grill 期数字主动变化(ζ `11/30→10/23`)是**过程非 bug**,脚本只在【`make verify` diff/commit 时点 + 存档态】查,跳过 working/draft(否则每 commit 跨段报警 → 关掉 = E4 误伤致死)。🔴 **CC 补(发现型)**:「存档态」判定要适配 MAformac【单文件夹无专门 archive 分支,codex 占主工作树】实际——用【文档内 `status` 字段(Accepted/SUPERSEDED)或 openspec archive 状态或 git tag】判,**非 git 分支**;spec 明列判定标准否则脚本不知检什么。
- **EN4 staleness 分两步(助理)**:现在 MEMORY 加 `as-of` 字段(构架就位)/ H2a 落地后 hook 自动比对;别等 H2 才加(迟加成本 10x)。
- **🔴 ex-post 边界(助理统一补丁)**:pG1-pG4/N5 全是【写后检测】(cross-section/stale/drift),**不防【写时分叉】**——文档级联天生 ex-post(写完决策才知会不会与旧段分叉)。spec 明示这条边界,防期望错位(「为什么 enforce 不防我初稿分叉」)。
## 批 4/5 — 策略周边（G6/G7/G8/N4 · 全⭐ + EN5 N4 三件套 · G3 跳过磊哥手动）

> Q16 G3 effort 校准:**磊哥手动决策,跳过**(不建东西)。

### D1 · G6 claude-mem = 🔴 明确禁止不装
- **decision**: 🔴 **claude-mem 明确禁止,磊哥不装**(不只「不扩大」——明确禁)。handoff 六件套(grounded 派可审计)是主力。
- **anchor**: T1 artifact tracking 弱 + 磊哥明确禁止。

### D2 · G7 anti-shallow skill = A（只 adopt 措辞）
- **decision**: A —— 只把 "no cached from 10min ago"/"Linter≠compiler" 措辞进 claim-vs-reality 铁律2,**不装任何 skill**。
- **anchor**: Elevate-or-Kill;Karpathy 作者自认「prompt not hard constraint」;SessionStart 注入=与 rule 同机制 max 已证失效。

### D3 · G8 异源审计禁 prepend CC 推理链 = B
- **decision**: B —— cross-vendor 派单只给 artifact+spec,不 prepend CC 推理链,收敛 1-2 轮。
- 🔴 **mechanical**: 派单 prompt 模板**固定不含 CC 推理链段**(防退化 context-aware subagent)。
- **anchor**: Cross-Context Review(收益来自 context 分离,二手 finder)+ More Rounds More Noise。

### D4 · N4 grounded adopt vs build = B（adopt 机制 + build 磊哥版）
- **decision**: B —— adopt grounded 概念分类法 + disler 骨架,build 磊哥版,项目级隔离试。
- 🔴 **EN5 落地三件套(助理,写 spec 直接抄)**:

  | grounded 提供 | 磊哥 build 版迁移 | 用骨架 |
  |---|---|---|
  | PreToolUse edit-guard(拦未 Read 的 Edit) | → Q10/B5 read-before-edit 软提示 | 自写 mjs |
  | PostToolUse truth-layer(写后核 file:line) | → Q6/B1 H2a Stop-文本-扫描 | disler `validate_file_contains.py`(3785★)迁 2.1.177 `decision:block` |
  | Stop confidence-check(agent 自评 confidence) | ❌ **drop** —— 磊哥用异源 grader(Q7/B2)非自评 | 自评=E1 同 family bias 循环失守 |

  → **N4 adopt = 概念分类法 + disler 骨架;drop = grounded Stop confidence-check(自评踩 E1 大象)**。
  - 🔴 **CC 补(时点精度)**:grounded truth-layer 是 **PostToolUse 即时**(Grep 返 0 立即注入"MUST NOT 引用"),B1 H2a 是 **Stop 回合末**扫——两时点。先做 Stop B1(覆盖文本数字),PostToolUse 即时拦留增量(若回合末才拦太晚再加)。
- **项目级隔离实测清单(先窄后宽)**:① 落 `<MAformac>/.claude/hooks/cite-verify.mjs`(项目级,≥5 会话+触发≥10 次)② 统计 触发次数 / 误伤率(合理 claim 被拦)/ Stop 并发延迟(叠加 `session-stop.mjs` ~10ms,**无 claude-mem**)③ 误伤<1/3 + 延迟无恶化 → 迁 `~/.claude/scripts/`(用户级所有窗口享)④ 项目级试错版 **git 不入仓**(CVE E8,`.gitignore` mechanical),用户级才进 dotfiles。
- **don't-do(防 T1 拓扑冲突)**:❌ 不 npm install/git clone grounded → settings import ❌ 不照搬 grounded 整套 4-hook 拓扑(撞磊哥现有 hook)❌ 不让 grounded Stop hook 跑(撞现有 `session-stop`)✅ 只参考 truth-layer 思路 + disler 骨架自写。
- **anchor**: grounded 27★(gh 核实,机制蓝本非装)。
## 批 5/5 — 深层合并（N1/N5/N2 · 全⭐ + EN6 共用内核 4 件套）= 收口

### E1 · N1 research/workflow cite-verify enforce = B
- **decision**: B —— workflow finder return schema 强制 `load_bearing_claims:[{value,source,claim_type}]`,主线程收口前 gate 抽查异源核。
- **anchor**: 本次 finder 自编造 #42796 量化 + arxiv ID(TODO §0)= 活炸弹。

### E2 · N5 三缺陷边界 = 一个门 + 哪些纯扳机
- **decision**: 一个门(claim 前强制重取一手源)治失忆+浅思两病;correctness/frame = 纯扳机+异源+人。
- 🔴 **mechanical**: H1(冷注入)+H2a(grounding)≈一个门;**门验客观产物(Read/grep tool history)不验模型自评**(E2 overconfidence 治不掉)。
- **anchor**: lens3 E2/E3/E5。

### E3 · N2 合并统一 = 一套分尺度 enforce 层（收口）+ EN6 共用内核
- **decision**: 一套分尺度 enforce 层,共用内核不建第二套(§7)。
- 🔴 **EN6 共用内核 4 件套(助理,写 spec 直接抄)**:

  | 内核组件 | 用在哪些尺度 | 实现 |
  |---|---|---|
  | 1 claim 抽取器 `extractClaims(text)→[{value,source,claim_type}]` | H2a/C++/N1 | `lib/claim-extract.mjs`(正则+`path:N`+claim_type 路径决定 A1;**支持 file:line + url 两类 source**·CC补) |
  | 2 grounding 核验器 `verifyGrounding(claim)→{ok,missing}` | H2a/C++/pG1 | `lib/grounding-verify.mjs`(`sed -n Np` 核存在) |
  | 3 异源 grader 接口 `invokeExternalGrader({artifact,spec})→{receipt,sha}` | H2b/C++/N1 | `lib/external-grader.mjs`(调 GLM-5.2/hermes,固定 prompt 不 prepend D3) |
  | 4 recompute verifier `recomputeAndCompare(receipt)→{pass,fail_reasons}` | C++/pG1 | `lib/recompute.mjs`(读 receipt command+output_sha256 重跑+比对) |

  **5 尺度 = hook 事件 + 内核组合**:
  | 尺度 | hook 事件 | 内核组合 |
  |---|---|---|
  | 冷注入 H1 | UserPromptSubmit | (无核验,注入静态指针) |
  | 每-claim H2a | Stop / PreToolUse | 1+2 |
  | candidate signing C++ | 手动 `sign-or-block.mjs` | 1+2+3+4 |
  | 文档 cross-section pG1 | `make verify` | 1+2+4 |
  | research N1 | finder schema gate(主线程手动) | 1+3 |

  **目录结构**:
  ```
  ~/.claude/scripts/lib/{claim-extract,grounding-verify,external-grader,recompute}.mjs  # 4 内核
  ~/.claude/scripts/hooks/{cite-verify-stop,handoff-inject,read-before-edit}.mjs
  ~/.claude/scripts/cli/sign-or-block.mjs
  <MAformac>/scripts/cross-section-check.py  # make verify 调
  ```
  - **guarantee**: 4 内核 = lib + 测试,hook/cli 不重复实现 grep/grader;新尺度(未来 demo-level/handoff-level)= 新组合非新轮子。
  - **测试纪律**: 4 内核 lib 必有 unit test(`make verify-hooks`),无测试 → 内核漂移无感知 = 5 尺度跟炸。
  - 🔴 **CC 补(发现型,external-grader fail 模式)**: 内核 3 依赖外部 API(GLM/hermes),**API 挂/离线时 candidate signing fail-closed**(candidate UNSIGNED 不放过)非降级签;spec 明列「external-grader 不可用 = candidate 不可签」。
- **anchor**: N2 防建第二套 §7。

---

## ✅ harness + 审计 grill 全完（批 1-5 · 23 题 + EN1-6）→ 派单 → **已实装(2026-06-22)**

> grill 完批 2-5 → 写 spec(收口步 pin Sonnet)。spec 落点:harness hook → 用户级 `~/.claude/`(先项目级试);审计框架 → `make verify` doc-gate + `scripts/sign-or-block.mjs` + `audit-template.md`。

### 🟢 实装完成状态（2026-06-22，Claude Code 自主执行 + 异源审计 4 轮收敛）
本 amend 全部决策已落地。**实装事实源**：
- **派单 + lessons**: `~/workspace/raw/05-Projects/MAformac/dispatches/2026-06-22-harness-enforce-audit-implementation-dispatch.md` + `harness-enforce-impl-lessons.md`（6 件一手核验 + action 10/23 算法 + 4 轮审计循环 + 3×P1+2×P2 修复）。
- **4 内核 lib**: `~/.claude/scripts/lib/{claim-extract,grounding-verify,external-grader,recompute}.mjs`（21 单测全绿，`make verify-hooks`）。
- **4 hook**: `handoff-inject`(H1/UserPromptSubmit) / `cite-verify-stop`(H2a-resp/Stop decision:block) / `cite-verify-posttool`(H2a-file/PostToolUse) / `read-before-edit`(B5)。H1 用户级；H2a/B5 项目级 `<MAformac>/.claude/settings.local.json`（gitignored，CVE）。
- **CLI**: `~/.claude/scripts/cli/sign-or-block.mjs`（make verify 绿 + recompute verifiable + 异源 grader 绑语义 → sign；缺任一 fail-closed UNSIGNED）。
- **5 语义 command + cross-section**: `<MAformac>/scripts/{action_hard_pass_recompute,axis_schema,surface_consistency,verify_gold,scorer_single,cross_section_check}.py`。`action_hard_pass_recompute` 实测复现 **base 10/23**（axis 23/3/4，从 `c6-summary.json:eval_runs[].gate_result` 一手字段）。接入 `make verify`(verify-cross-section)。
- **守边界落地**：enforce 治 mechanical 不治 correctness（仍异源+人）；kill switch `HARNESS_ENFORCE_DISABLED` + settings 备份 + activation receipt + 误伤统计 `~/.claude/logs/cite-verify.jsonl`（试用 ≥5 会话 + 误伤<1/3 再迁用户级）。
- 元认知回流：全局 `~/.claude/rules/hooks.md`（各事件 schema + 全局 hook 4 件套）+ `claim-vs-reality-gap.md`（enforce 层 = 10 坑结构答案）+ MAformac `docs/lessons-learned.md #50`。
- **活体证据**：H2a-file hook 真拦下「凭 codex 对话数字写进 §5 没核 source」逼 jq 亲核闭环；磊哥 catch 出 JSON 字段 source 盲区已修。

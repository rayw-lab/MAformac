# A2 代码重构派单 — 范式基线对齐代码（code-only）（CC 主窗口 ultracode + /goal 自驱）

> 2026-06-23 磊哥派单（v2，已并入 codex + GLM-5.2 双源审计 findings + 「训练/后端延后」决策）。
> 融合 A（enforce 现状）+ B（文档级联简化方案）+ C（A2 代码重构大纲）。
> 执行方 = **CC 主窗口**（磊哥定，**不派 codex 长跑**），全程 `/goal` 目标态自驱 + ultracode（每 step 派 workflow + 主线程亲核 + subagent 审计并行 + loopaudit 收口）。

---

## 0. A2 是什么（范围铁律，动手前先划清，磊哥 2026-06-23 校准 + 延后升级）

- **A2 = 重构现有代码（code-only）**，把范式翻案（generic frame → D-domain 具名工具）的**「文档基线」对齐到「代码」**，使 **代码基线 = 范式文档 = 项目进度** 三者对齐。
- **A2 边界 = 「让代码说 D-domain 语言」**：model-visible surface / 契约编译器 / codegen / 训练样本生成器 surface / bench expected / state-cells / 执行映射 / 命名清债 全迁 D-domain，且 **编译过 + `swift test` 绿 + `make verify` 绿**。
- 🔴🔴 **A2 不训练、不评测模型性能、不生成语料**（磊哥「训练 + 后端开发延后」决策，最易越界点）。下列**全部 DEFERRED 延后（不排期，A2 之后独立阶段重新立项，见 §H）**：
  1. C5 四类自然中文**训练数据生成**（云 generator + 异源 judge + contract 标签 + 原文 oracle）
  2. C5 LoRA **实际重训**（跑权重）
  3. C6 **实际评测验证模型性能**（跑 LoRA 看 hard_pass 涨没涨）
  4. C6 **四层评测门**（golden/demo_fuzz/unsupported/safety 各独立 scorer，Q41）
  5. **demo-golden-run**（炸场合同回放）
  6. **voice / ASR / TTS**（SFSpeechRecognizer 主 + sherpa/Whisper fallback + AVSpeechSynthesizer）
  7. **端侧受限解码 vendor**（mlx-swift-structured C++ 进仓）
  8. 一切后端功能开发
- **边界判据**：A2 改完后，C5 样本生成器**能产 D-domain shape 的样本**（接口/形态对齐，但**不实际生成语料、不调云 generator、不跑 judge、不训**）；C6 bench **expected 是 D-domain 且能跑 base 验格式/链路**（但**不跑 LoRA 评性能、不建四层门**）。「让代码说对话 + 测试绿」是 A2；「让模型答对题 / 评模型好不好」是延后。

### A2 ↔ OpenSpec change 对齐（已并入 codex P1-1）
| change | 归属 | 本次 A2 做什么 |
|---|---|---|
| ⭐ `migrate-d-domain-tool-surface` | **A2 主 change**（code-only） | [0][1][2][3] 全做 + 承载 [4-code]/[5-code] 的 surface MODIFY（见下） |
| `retrain-c5-lora-d-domain` | **DEFERRED** | 仅 §2.1「训练样本 surface 翻案」(code-only) 属 A2、随 migrate 完成；§2.2 数据生成 / §3 训练 / §4 评测 = **延后** |
| `rebuild-c6-four-layer-bench` | **DEFERRED** | 仅 §2 expected_tool_calls 迁 D-domain (code-only) 属 A2、随 migrate 完成；§3 四层门 / 实际评测 = **延后** |
| `define-demo-golden-run-and-voice` | **DEFERRED** | 整体延后（demo + voice） |

> 即：A2 这次长跑 = `migrate` change 全部（含 C5/C6 的 **code-only surface 改**），其余三个 change 标 `DEFERRED` banner（tasks 里 code-only surface 行标「随 A2 完成」，训练/数据/评测/四层门/demo/voice 行标 DEFERRED）。

### 起手必读（一手归档指针，禁凭记忆/二手；口径以终拍 562 为准）
1. `CLAUDE.md §9 banner`（项目进度 + A2 待启动指针 + 延后边界）
2. ⭐ `docs/research/2026-06-22-a2-codebase-audit/README.md`（**A2 代码盘点 ultracode 亲核版**：附录 A = 16 处不对齐 file:line 全表 / 附录 B = 范围量级 / 附录 C = 复用·重写·新建三分类 / 附录 G = grill 弹药）——**16 处 file:line 在这里读一手，本派单不复制**（避免派生层失真，claim-vs-reality 第10变体）
3. `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md`（范式翻案权威：D-domain 三层模型 / §14 口径 / §17 A2 盘点级联）
4. `docs/grill-tournament/grill-decisions-master.md`（grill SSOT 单源，§0 口径权威表）+ `docs/grill-tournament/cascade-inventory.md`（文档级联账本 T0-T6）
5. `~/.claude/rules/claim-vs-reality-gap.md`（10 坑反射，A2 高危：派生表征当一手 / 标 modify≠已 modify / 凭印象数字）

> 🔴 **执行方起手自核 file:line**：本派单 §I/§C 引的 file:line 是【二手派生】（一手 = A2 audit README 附录 A + 实际 grep）；起手先 grep/sed 自核一遍（subagent 审已发现 `StateStore:136` 类微瑕、行号会随代码漂），以 README 一手 + 实跑 grep 为准。

### 🔴 口径权威（终拍 562，A2 派单最易踩的坑）
- 全集 = **3990 行 / 671 device / 1538 intent**（jsonl 实跑坐实）
- 10 族 = **191 device / 562 intent / 2159 行（54.1%）**（磊哥 2026-06-23 **亲拍 562**，534/2086/52.3% 系列**全废**）
- 族外 = **976 intent / 1831 行**
- ⚠️ **「562」是 intent 数不是工具数**——把 562 当工具数 codegen = 口径错全链路；**工具数 G2 未拍待 value-form 实算**（col O 优先级在 xlsx 第15列不在 jsonl）
- ⚠️ A2 audit README 正文多处称 534/2086（盘点态历史定性，已被 README banner line 3 覆盖）；`generated/10-family-device-map.json`=223 device（旧 codegen 含 disputed）→ 步骤[0] 重生成对齐 191

---

## A. enforce 现状（cite-verify 纪律已下沉 hook + make verify，A2 必用）

A2 每 step 收口前**必跑 `make verify`**（绿才进下一刀）。当前 enforce 三件套（本机已核 `Makefile`/`scripts/cross_section_check.py`，GLM 复核通过）：

1. **`make verify` 链路**（`Makefile:19`）= `verify-source`（freeze snapshot 校验）→ `regen`（`gen_c1.py` + `gen_tool_contract.py` 重生成 generated/）→ `verify-refs` → `verify-cross-section`（§35 文档级联段间一致）→ `diff`（`git diff --exit-code` 漂移门）→ `test`（quarantine + fc_flags Python fixture）。
   - 🔴 **GLM P2-a/P2-b**：`make test` **只跑 Python 测试**（`test_quarantine.py` + `test_fc_flags.py`），**无 `swift test` gate**。`swift test` 是独立命令（见 §D）；A2 可选新增 `make verify-swift` target 把 Swift 测试机械化（§F）。
2. **cite-verify hook**（`~/.claude/scripts`，Stop 扫 response + PostToolUse 扫写进 docs 的数字）= load-bearing 数字/引用做 **value-in-source** 核（凭印象/失效引用 → flag/block）。逃生 `export HARNESS_ENFORCE_DISABLED=1`。
3. **diff gate**（`Makefile:50-51`）= `GENERATED_CONTRACTS` + `HANDWRITTEN_CONTRACTS`（state-cells/l1-demo-allowlist/risk-policy/demo-scenarios）+ `scripts` + `Makefile` 任何未提交漂移 → build fail。
4. **cross-section 覆盖现状**（`scripts/cross_section_check.py`，GLM 逐行复核）：
   - `BASELINE_GLOBS` = `docs/c5-recovery-2026-06-22/*.md` + `docs/roadmap-2026-06-20-from-c6-done.md` + `docs/grill-tournament/*.md`（**仅这 3 组**）
   - `CALIBER_ANCHORS` = `10 族 intent:562` / `10 族 device:191` / `族外 intent:976`（单值锚，紧跟赋值符才命中）
   - `ANCHOR_KEYWORDS` = `mp_positive_action`（分数锚，跨段不应分叉）
   - 🔴 **只查 internal 段间一致性（drift），不查 correctness**（值一致但错抓不到 → 仍需主线程亲核 + 异源审计）

### ⚠️ enforce 覆盖不全 3 漏点（A2 会踩，B 段给简化补法）
- **漏点 1**：`BASELINE_GLOBS` **不含** `CLAUDE.md` / `docs/srd-*.md` / `docs/baseline-semantic-protocol-2026-06-19.md` / `CONTEXT.md` / `docs/research/INDEX.md` → 口径 562 写进这些**没机械门兜底**（A2 会大量改这些）。
- **漏点 2**：`CALIBER_ANCHORS` 只 3 个口径锚 → A2 新口径（工具数实算 / 族外 device 480 / 各族 device 数）无锚自动验。
- **漏点 3**：cross-section 只验**口径数字**，验不了 **D-domain surface 是否真删干净 generic frame**（代码层 correctness）→ 需异源 + 主线程亲核（frameToolSchema 真移除非靠 drift gate，它对 compiler-derived 的债不报警）。

---

## B. 文档级联简化方案（5 点，A2 边重构边落，减级联工作量 + 补 enforce 覆盖）

> 原则 = **机械门兜底 + 单源派生 + 历史档不改正文**（与 `doc-cascade-triage` 活基线/历史档分诊同源）。

- **B1. cross-section 扩 `BASELINE_GLOBS`**（补漏点 1，**优先做**，零新基建）：把 `CLAUDE.md`、`docs/srd-*.md`、`docs/baseline-semantic-protocol-2026-06-19.md`、`CONTEXT.md` 纳入白名单 → 口径写错被 `make verify` 机械拦。**扩前先把这些文件废口径行标 `SUPERSEDED/废口径`**（GLM 已核三文件均带「旧/废/禁引」标记，`SUPERSEDED_MARKERS` 会跳过 → 不误报）。🔴 **GLM P2-c**：`docs/research/INDEX.md` 当前 grep 534=0（无 caliber 锚）→ 加入是**零成本覆盖增强**（防未来写错），不加也无收益缺失——**按零成本原则加入**。
- **B2. A2 新口径拍板后加进 `CALIBER_ANCHORS`**（补漏点 2）：工具数实算值 / 族外 device 等 step[0] 拍定的新口径，加进单值锚 → 全仓自动验。
- **B3. 口径从 SSOT 派生（🔴 codex P1-2 硬前置修正）**：dispatch v1 说「从 `contracts/semantic-function-contract.jsonl` 的 `scope_tier` 字段派生」——但**当前 JSONL 32 字段无 `scope_tier`**（已核 contracts/ 全仓 0 命中），而 grill-master `:162/:164` 决策**要求**「简单 allowlist + scope_tier 标签」。**修正**：step[0] 必须**先生成/落盘** `scope_tier`（或 explicit-allowlist manifest，含 source / sha256 / 验证命令），纳入 codegen 单源 + diff gate，**再让 codegen 消费派生口径**。**禁对不存在的字段派生**。
- **B4. 历史档标 historical banner 不改正文**（减级联面）：带日期的 handoff/dispatch/research/审计报告（T5 历史快照）= 一手溯源，**只加 banner 不改正文**（改正文破坏可溯源 + 工作量爆炸 + 误改非目标数字）。小脚本批量给 T5 加 banner。
- **B5. 收敛到 grill SSOT 单源**（减文档数）：grill 决策唯一权威 = `grill-decisions-master.md`，其他文档**指针引用不重抄决策**。A2 新决策只落 grill SSOT + 对应 change，活基线指针指向它。

---

## C. A2 代码重构大纲（6 步依赖序，止于「代码对齐 + 编译/test/verify 绿」，不训不评不生成语料）

> 严格依赖序（违反 = 返工，依据 A2 audit README 附录 B `dep_graph` 亲核）。每步 file:line 读 README 附录 A，本派单只给骨架 + 切刀边界 + grill 锚。**每刀后 `swift test` + `make verify` 必绿 + 链路可跑**（incremental，禁大爆炸，Netscape 红 flag）。

### [0] 统一数字口径 + 落盘 scope_tier/allowlist manifest（基线对齐第一刀，含 codex P1-2 硬前置）
- 锚定 **191 device / 562 intent / 2159 行**；**工具数 G2 实算**（从 562 intent 按 value 形态/arg 收敛出实际具名工具集，不拍 30-60）；col O 优先级从 raw xlsx 第15列提取（jsonl 没有）。
- 🔴 **硬前置（codex P1-2）**：先生成 `scope_tier`（或 explicit-allowlist manifest）落盘——含 **source（来自哪/怎么算）+ sha256 + 验证命令**，纳入 codegen 单源 + `GENERATED_CONTRACTS`/`HANDWRITTEN_CONTRACTS` diff gate。**这一步不做完，[1] codegen 无合法口径源可消费**。
- 重生成 `generated/10-family-device-map.json`（现 223 过期）对齐 191；废口径全仓标 SUPERSEDED（配 B1/B4）。
- 🔴 grill 锚：**562 是 intent 不是工具数**（README 附录 G 议题1，⭐B）。

### [1] 扩 Python codegen 产 D-domain 具名工具目录（Swift 侧的源）
- `scripts/gen_tool_contract.py` 新增 D-domain 目录生成函数（intent→工具名 + value 形态编码进名 + arg enum + domain→子组→tool 三级），**两层 scope**（full 1538 / demo 562），消费 step[0] 落盘的 scope_tier/allowlist。
- 产物 `generated/` 入仓 + 纳入 `GENERATED_CONTRACTS` 漂移门（否则新硬编码逃过 gate）。
- 🔴 grill 锚：两层 scope 派生深度不同**非两套 SSOT**（README 附录 G 议题2，⭐A）。

### [2] ToolContractCompiler.swift 改消费 generated JSON（核心重写）
- 删 `frameToolSchema`（generic frame surface **显式移除**，非靠 drift gate——它对 compiler-derived 的债不报警）+ 删 `renderedToolsText` 双 surface 并挂 + 删 `dDomainSurfaceNames()` 硬编码 if-else。
- `ToolContractNormalizer` + `ToolContractStateApplier`（329 行核心状态逻辑）→ **data-driven**（从 state-cells.yaml 派生，switch 补 default + 日志）。
- compiler 重写要有 **unit test**（产 D-domain surface 正确 + 未知 device 不静默跳过）。
- 🔴 grill 锚：compiler data-driven 重写但 **codegen 地基（Python gen + Makefile 漂移门）守现状不推翻**（steelman，README 附录 G 议题3，⭐A）；**不引入新 Swift codegen 框架**（Sourcery/SwiftSyntax = 造第二套 SSOT 反模式）。

### [3] state-cells 扩 10 族 191 device + C3 执行映射派生 + 命名清债
- `contracts/state-cells.yaml` 补 6 族（座椅/车门/音量/雨刮/天窗/香氛，现仅 4 族）→ codegen 自 contract 191 device。
- `C3ExecutionPipeline.swift` executionCellID switch 硬编码 → 从 state-cells.yaml `execution_range_cell` 派生。
- 命名清债：`DemoVehicleStateStore.swift` 删 `hvac.ac` 旧轨统一 `ac.power`；`FastPathIntentEngine.swift:21` `hvac.ac`→`ac.power`。
- [2][3] 是 [4-code][5-code] 的前置。

### [4-code] C5 训练样本生成器 **surface 代码**改 D-domain（code-only，不生成语料不训）
- `C5LoRATraining.swift`：正样本工具名 `tool_call_frame`→D-domain 具名 / tools schema 改具名工具集 + 同族 distractors / 用户文本协议风格占位接口。
- 🔴 **codex P2-5 wording 修正**：A2 只**预留自然中文生成接口/shape**（让代码**能**产 D-domain shape 样本），**不生成语料、不调用云 generator、不跑 judge、不实际重训**。
- `Tools/C5TrainingCLI/main.swift` 加 `--scope=demo/full` + `--surface=D_domain` 字段（接口层）。
- 🔴 **守 `rank16Mainline()` 配方 SSOT**（`C5LoRATraining.swift:1175` scale20/LR1e-4/adamw 已坐实稳）**不重开**（README 附录 G 议题7，⭐B）。
- 🔴 边界：到「生成器代码产 D-domain shape + 编译 + swift test 绿」为止；**`retrain-c5` 的 §2.2 数据生成 / §3 训练 / §4 评测 = DEFERRED**。

### [5-code] C6 bench expected **surface 代码**迁 D-domain（code-only，跑 base 验格式不评性能）
- `C6VehicleToolBench.swift:356-387`：30 MP case expected `set_cabin_*`→D-domain 具名（从 demo-scenarios.yaml codegen）；`c6-bench-cases.jsonl` 57 行迁 D-domain；coverageCases 扩 10 族 191 device（现仅 7 device）；readback 口径对齐 `scripts/_c6_axis_lib.py`（readback 走方案P renderer，删 eval 计 hard_pass，gold 不改）。
- 🔴 **parity gate 重定义（codex P1-3）**：A2 **不评模型性能**。A2 阶段回归门 = **compiler 单测 + `swift test` + `make verify` + C6 跑 `base`（无需训练）验「格式/链路对齐 D-domain」**（archive-check `verify-gold` pass）。
  - **A2-before baseline receipt**（freeze，供延后评测锚）：跑 base 前记录**命令 + case subset + 输出目录 + sha256 + 每轴 base 数**（action hard_pass base **10/23** 按 case schema 字段拆，非 case_id naming）。A2 只 **freeze 不评 LoRA 性能**。
  - 🔴 **模型性能 parity（LoRA vs base hard_pass）+ 抽样轴/阈值 = DEFERRED**（待 grill Q06，`rebuild-c6` §3 四层门一起做）。
- 🔴 边界：到「C6 expected 是 D-domain + 跑 base 链路通 + verify-gold pass」为止；**四层门 / 跑 LoRA 评性能 = DEFERRED**。

### 横切纪律（每步必守）
- **incremental 分刀**：每刀独立可验收/可回滚，旧路径保持可跑（strangler），`swift test` + `make verify` 每刀后绿。
- 🔴 **step close protocol（codex P2-4，每 step 收口固定动作）**：`review diff` → `git stage` 该 step 的 generated/contracts/scripts → `make verify`（含 `git diff --exit-code` 漂移门）→ `git status --short` 对账（防半写入/未跟踪生成物）→ **生成物 commit（`chore(codegen): regen`）与手写逻辑 commit 分开**（jsonl 7.4M diff 会淹没逻辑改动）。
- **agree-before-build**：A2 涉及 archived spec（C1/C2/C3/C6）MODIFY **必走 OpenSpec change 不直接改 archived**（migrate change DRAFT 已建，propose 对齐后再 apply）。
- **守现状不动**（steelman）：codegen 地基 / risk-policy 独立设计 / `rank16Mainline()` 配方 / spike-e3 mlx pin（0.31.4 / 3.31.3）/ C1-C3-C6 archived specs SSOT。
- **只迁 surface 不夹带**：禁 scope creep（behavior-preserving 重构混入 behavior-changing），禁顺手优化/重命名（除命名清债 step[3]）。

---

## D. A2 执行 harness — 每 step 工作流 + 分段审计（并行于 ultracode）

> 磊哥铁律：**每个小 step 都安排 subagent 审计（过程每 step 只【一轮】，非循环），并行于 ultracode 执行。**
> （系统 harness：goal 状态机 / 监控偏离信号 / 回滚 / 收口规格见 §I — harness 设计 workflow 综合产出后补入。）

每个 step（[0]–[5]）的执行模式 = **执行线 + 审计线 并进 → 主线程亲核 → step gate**：

1. **执行线**（ultracode workflow）：派 workflow 跑本 step 重构，🔴 **每轮 fan-out ≥6 个 subagent**（按文件/子任务分；之前 8 也跑过，折中 6）。🔴 **不必担心 limit——limit 是基础设施 rate-limit、非 agent 个数问题**。
   - 🔴 **workflow 每个 lens/finder 产出必落 markdown 一手档**（ultracode 三层一手性，磊哥定）：每 finder 写 `lensN.md`（full_markdown = summary + findings + 每条 source）+ 综合官 `README.md`（二手综合）+ transcript/`.output` 指针（最一手，回稿后立即 `cp` 防 /tmp 清）。归档 `docs/research/2026-06-23-a2-stepN-<slug>/`（脱敏命中 raw/Downloads 则归仓外 + 仓内 INDEX 指针）。**落档后明确报告存了哪几个文件**（README + N lens + transcript 指针）。
2. **审计线**（subagent CC 并行，🔴 **过程每 step 只一轮**，非 loopaudit 循环）：与执行线**同时**派 subagent CC 审本 step——
   - 审计范围 = **本 step 产出**（提示词不指定具体问题，范围 = 本 step 任务边界，避免引导漏盲点）。
   - 审 3 类：① 范式对齐（D-domain 真落地 / generic frame 真删）② 口径正确（562/191，新口径有锚）③ 不退化（`make verify` 绿 / `swift test` 绿 / C6 跑 base verify-gold pass）。
   - 审计报告落 markdown 一手档 `<step 归档>/audit-1.md`（一轮，留痕）。
3. **主线程亲核**：subagent/workflow 报的 load-bearing 数字 / file:line / 口径，主线程**独立核一手**（不信「workflow/subagent 说核了」，claim-vs-reality 第10变体：标 modify≠已 modify；frame 真删用 grep 核非靠 drift gate）。
4. **step gate**（全过才进下一 step）：`swift test` 0 fail + `make verify` 绿 + C6 跑 base verify-gold pass + 本 step 一轮审无 P0/P1 + 主线程亲核口径一致 + step close protocol（review diff → stage → make verify → git status → 分 commit）完成。

🔴 **loopaudit 仅【整体最终收口】用**（6 step 全 done 后一次性）：开放式循环审计至无 P0/P1（维度分工 ≥6 subagent，留痕 round-NN/audit-i.md，收敛定律 **修复 ⊇ 审计 ⊇ 执行**，防假 clean：panelOk 半数 agent 成功才认 clean、全 rate-limited≠clean）。**过程每 step 不跑 loopaudit**（一轮审即可，磊哥纠正）。

### `swift test` 命令（GLM P2-a，A2 执行方明确）
- SPM：`swift test`（仓根，若有 Package.swift target）
- 或 Xcode：`xcodebuild test -scheme <MAformacCore> -destination 'platform=macOS'`
- 执行方**起手先确认本仓 Swift 测试入口**（grep `Package.swift` / `.xcodeproj`），别在错目录跑 false-fail。

---

## E. 磊哥派单习惯（最近明示，本派单内化，执行方必守）

- **随时记录经验教训** → `docs/lessons-learned.md`（遇坑/纠错当场追加，不攒到最后）。
- **随时回看决策文件**（昨晚 codex 失败 lora 至今全链路）：`grill-decisions-master` / `paradigm-tool-surface` / `~/.claude/rules/claim-vs-reality-gap.md` / `cascade-inventory`。
- **积极沉淀文档 + 关注级联 enforce**：文档先行（spec/契约/级联/grill 做对再动代码）；级联 enforce 已实施（cross-section + cite-verify hook + diff gate）；级联有简化方案（B 段）。
- **incremental**：每 step `make verify` + `swift test` 绿；C6 跑 base 验格式（**不评模型性能，已延后**）。
- **agree-before-build**：archived spec MODIFY 走 change propose，不直接改；想清楚未做不起 propose。
- **中途 gate 防塌缩**：每 step C6 跑 base verify-gold（防代码链路坏），不等终局才发现。
- **loopaudit 收口**：重大产出循环审计至无 P0/P1，留痕，收敛定律，防假 clean。
- **主线程亲核 > 信 workflow/subagent**：load-bearing 数字/file:line/口径独立核一手，不信「说核了」；派生表征（receipt/聚合/config/log）当一手 = 根错。
- **不假 clean**：审计 agent 全 rate-limited / 返回空 ≠ clean；panelOk 校验。
- **不狂派 workflow**：文档精确修正主线程亲手做（read-heavy fan-out 才派）；多 workflow 狂派 = 混乱源（lessons G 段）。
- **脱敏 §6 放宽**（private 仓）：车型代号/供应商/真实合作方名（iFlytek/Chery）+ 与 demo 无关的调研一手料可入仓；仅密钥/PII/报价/真实人名绝不入；仅对外/demo 交付物客户名统一「某车厂」。
- **选择题**：打字列选项 + ⭐默认推荐，**不用 AskUserQuestion 弹窗**（磊哥终端看不到）。
- **不催 token**：token 由平台自动兜底，不因 token 停下工作。
- **低并发避 rate-limit**：cap 3-5。
- **称呼磊哥**；默认中文，英文术语首现「中文（English）」。

---

## F. A2 整体验收门（code 层，非模型性能）

A2 完成判据（全过 = 代码基线对齐范式文档 = 项目进度对齐）：
- [ ] model-visible surface 全 D-domain 具名工具，`tool_call_frame` generic frame **显式移除**（grep 无残留主链路引用，异源 + 主线程核非靠 drift gate）。
- [ ] C1 ToolContractCompiler data-driven 消费 generated JSON（无硬编码 if-else surface），有 unit test。
- [ ] step[0] `scope_tier`/allowlist manifest 已落盘（source/sha256/验证命令）+ 纳入 diff gate。
- [ ] C5 样本生成器**代码能产** D-domain shape（CLI `--scope`/`--surface` 可用）；**未生成语料、未重训**（边界）。
- [ ] C6 bench expected 全 D-domain + 10 族 191 device coverage；C6 **跑 base** verify-gold pass + A2-before baseline receipt freeze；**未跑 LoRA 评性能、未建四层门**（边界）。
- [ ] state-cells 10 族 191 device 全落 + C3 映射派生 + 命名清债（无 hvac.ac 双轨）。
- [ ] 口径全仓 562/191/976 统一（cross-section 扩白名单后 `make verify` 绿）。
- [ ] `swift test` 0 fail + `make verify` 绿（每 step 都绿，非只终局）；可选 `make verify-swift` target 机械化（GLM P2-b）。
- [ ] 生成物 commit 与手写 commit 分离；archived spec 改动走 migrate change。
- [ ] 起手必读归档全引用一手（无凭记忆/二手定性，口径用终拍 562 非 README 正文 534）。
- [ ] lessons-learned 持续追加；loopaudit 每 step 收口至无 P0/P1 留痕。

---

## G. 审计同步（codex + GLM-5.2 双源审计 dispatch，已并入 v2）

> 磊哥 2026-06-23 同步派 codex + GLM-5.2 审本 dispatch（只读审计，未改文件）。findings 已并入上文，可追溯：

**codex（verdict: PARTIAL，派单需先修再交执行）— 3 P1 + 2 P2，全采纳**：
- **P1-1** A2 边界 vs OpenSpec skeleton 冲突（retrain-c5 tasks 含数据生成/训练/diff 超 A2）→ **已修**：§0 change 对齐表（A2 只绑 migrate，retrain-c5/rebuild-c6/golden-run DEFERRED，code-only surface 随 A2）。
- **P1-2** `scope_tier` 被当可派生字段但 JSONL 无此字段（已核 contracts/ 0 命中）→ **已修**：B3 + step[0] 硬前置（先落盘 scope_tier/allowlist manifest 含 source/hash/验证命令再 codegen 消费）。
- **P1-3** C6 parity gate 是口号非可执行门 → **已修**：step[5] parity gate 重定义（A2 不评性能；回归门 = compiler 单测 + swift test + make verify + C6 跑 base verify-gold；A2-before baseline receipt freeze；模型性能 parity + 抽样轴/阈值 DEFERRED 待 grill Q06）。
- **P2-4** make verify 与分步 commit/stage 没写清 → **已修**：横切纪律加 step close protocol（review diff→stage→make verify→git status→分 commit）。
- **P2-5** 自然中文 wording 诱导越界 → **已修**：step[4-code] 改「预留接口/shape，不生成语料/不调云 generator/不跑 judge」。

**GLM-5.2（verdict: 18 项 load-bearing 声称全通过一手核，0 P0/P1）— 3 P2，采纳**：
- **P2-a** Makefile 无 swift test（swift test 是 xcodebuild/SPM 命令）→ **已修**：§D 加 swift test 命令说明。
- **P2-b** 缺统一 swift test 的 Makefile target → **已记**：§A/§F 标可选新增 `make verify-swift`。
- **P2-c** INDEX.md 无 caliber 锚（grep 534=0）→ **已修**：B1 按零成本原则加入并注明。

---

## H. DEFERRED 延后清单（训练 + 后端，A2 之后独立重新立项，不在本派单）

> 磊哥 2026-06-23「训练 + 后端开发延后」决策。A2 只铺代码地基，下列**延后不排期**，将来独立 propose：

1. `retrain-c5-lora-d-domain` §2.2 四类自然中文**数据生成** + §3 LoRA **实际重训** + §4 **C6 候选评测**
2. `rebuild-c6-four-layer-bench` §3 **四层评测门**（Q41 各独立 scorer）+ 跑 LoRA **实际评测验证模型性能**
3. `define-demo-golden-run-and-voice` 整体（demo 炸场合同回放 + voice ASR/TTS/VAD）
4. 端侧**受限解码 vendor**（mlx-swift-structured C++ 进仓自维护）
5. C6 模型性能 **parity 抽样轴/阈值 grill**（Q06）
6. 一切后端功能开发

A2 把「代码说 D-domain + 测试绿」铺好后，上述阶段直接在已对齐的代码上做。

---

## I. A2 执行 harness（完整规格 — workflow 4 视角综合 + 主线程亲核坐实）

> 本节 = §D「分段审计」的**完整系统化展开**（执行管控 / 监控 / 整体推进 / 收口）。来源 = harness 设计 workflow（4 designer + 综合，5 agent / 842K tok）+ 主线程亲核坐实。一手归档 `docs/research/2026-06-23-a2-harness-design/`（harness-synth.md + 6 transcript jsonl + synth.output.json）。
> 🔴 **并发已统一 ≥6 subagent**（磊哥 2026-06-23 定，不担心 limit）。

> 执行方 = **另一 CC 窗口 ultracode + `/goal` 自驱**（不派 codex 长跑）。终点 = **代码说 D-domain + 编译过 + `swift test` 0 fail + `make verify` 绿**，**止于老 C5 LoRA 训练前**——A2 不训练、不评模型性能、不生成语料（§0 全部 DEFERRED）。本 harness 把 §C 6 步做成确定性状态机，每步「执行线 + 一轮审计 + 主线程亲核 + step gate」，整体收口才 loopaudit。
>
> 🔴 本机已亲核坐实（A2 执行方起手可直接信）：`scope_tier` 全仓 0 命中（step[0] 硬前置真实）；`generated/` **不在** Makefile diff gate 路径（`Makefile:51` 只含 `GENERATED_CONTRACTS`+`HANDWRITTEN_CONTRACTS`+scripts+Makefile）→ step[1] D-domain 产物必须显式纳入 diff gate 否则逃逸；`C5LoRATraining.swift:2344` `removedToolID:"tool_call_frame"` metadata 声称 vs `:2362` 仍 emit frame（claim-vs-reality 铁律1 活样本，frame 删用行为门不用 metadata）；`rank16Mainline()`=`:1175`（守不动）；`MAformacCoreTests`（`Package.swift:48` SPM target）+ `MAformac.xcodeproj` 并存；cross-section `:4` 注释「不查 correctness」（frame 真删/口径对错验不了 → 必主线程亲核 + 异源）。

---

### 1. 执行管控：6 步 → 7 work-state 单向 DAG + /goal 自驱

6 步映射成 7 个 work-state（`S_INIT` 起手 freeze baseline + `S0`-`S5` + `S_CLOSE` 整体收口），单向 DAG，依赖序违反 = 返工。**state 转移 = 合取 gate（任一 fail 不转移）**。

```
S_INIT → S0(口径+manifest) → S1(Python codegen) → S2(Compiler) ─┐
                                                                  ▼  (S2 ∥ S3 文件域不重叠可逻辑并行)
S_DONE ← S_CLOSE(整体loopaudit) ← S5(C6 surface+base) ← S4(C5 surface) ← S3(state-cells)
   ▲                                                              ▲ (S4 ∥ S5 文件域不重叠可逻辑并行)
   └─ 任一 Sn 失败且不可前修 → ROLLBACK 到 Sn-1 已签 commit（strangler 旧路径保活，链路不断）
```

| state | step | 一句话目标 | 主产物（commit 域，生成物/手写分离） |
|---|---|---|---|
| **S_INIT** | — | 起手对齐：grep `Package.swift`/xcodeproj 确认 `swift test` 入口；读起手必读 5 件；跑 base freeze **A2-before C6 baseline receipt** | 无 commit，记 baseline receipt（命令+case subset+输出目录+sha256+每轴 base 数，action hard_pass 锚 **base 10/23** 按 case schema 字段拆非 case_id naming） |
| **S0** | [0] | 锚 **191 device/562 intent/2159 行**；工具数 G2 实算（不拍 30-60）；col O 从 raw xlsx 第15列提；**落盘 scope_tier/allowlist manifest**（source/sha256/验证命令）；重生成 `generated/10-family-device-map.json` 对齐 191（现 223 过期）；废口径全仓标 SUPERSEDED | `contracts/`(manifest) + `generated/`(重生成) |
| **S1** | [1] | `gen_tool_contract.py` 加 D-domain 具名目录生成函数（value 形态编码进名 + arg enum + domain→子组→tool 三级），**两层 scope**（full 1538/demo 562），消费 S0 manifest；产物纳入 diff gate | `scripts/gen_tool_contract.py` + `generated/`(D-domain 目录) |
| **S2** | [2] | 删 `frameToolSchema`(:23)/`renderedToolsText` 双 surface 并挂(:48)/`dDomainSurfaceNames()` 硬编码(:71)；Normalizer+StateApplier（329 行）data-driven（switch 补 default+日志）；写 compiler unit test | `Core/Contracts/ToolContractCompiler.swift` + 新 test |
| **S3** | [3] | state-cells 补 6 族（座椅/车门/音量/雨刮/天窗/香氛）→ 191 device；C3 `executionCellID` switch→`execution_range_cell` 派生；命名清债 `hvac.ac`→`ac.power`（StateStore:150/167/169、FastPath:21（:136 已是 ac.power 新轨；hvac.ac 旧轨在 :150/167/169，subagent 审坐实）） | `contracts/state-cells.yaml` + `C3ExecutionPipeline.swift` + `DemoVehicleStateStore.swift` + `FastPathIntentEngine.swift` |
| **S4** | [4-code] | C5 正样本(:2362)/tools schema(:2408)/用户文本风格(:1767) surface 改 D-domain；CLI 加 `--scope`/`--surface`；**仅预留接口/shape，不生成语料/不调云 generator/不跑 judge/不训**；守 `rank16Mainline()`(:1175) | `Core/Training/C5LoRATraining.swift` + `Tools/C5TrainingCLI/main.swift` |
| **S5** | [5-code] | C6 30 MP case expected(:356-387)/`c6-bench-cases.jsonl`/coverage(:419 扩 191 device) 迁 D-domain；readback(:1038-1039) 走方案P（删 eval 计 hard_pass，gold :865 不改）；**跑 base 验格式/链路**（不评 LoRA 性能、不建四层门） | `Core/Bench/C6VehicleToolBench.swift` + `contracts/c6-bench-cases.jsonl` |
| **S_CLOSE** | — | 整体 loopaudit 至一轮零 P0/P1 + §F 验收门逐条核 + 生成物/手写 commit 分离核 | lessons-learned 追加 + loopaudit 留痕 |

**/goal 状态持久（双锚防分叉）**：每 gate 通过后原子写 `.a2-goal-state.json`（gitignored，仓内不入）记 `current_state`/`states_done`/`baseline_receipt`/`last_signed_commit`/`next_action`。**中断恢复**：读 state 文件 → `git log` 对账 HEAD==`last_signed_commit`（不一致以 git 为事实层）→ **实跑 `swift test`+`make verify` 确认当前态真绿**（不信状态文件「说绿了」，claim-vs-reality 第10变体文档层镜像）。TodoWrite 镜像 7 state 给磊哥实时可见。

---

### 2. 每 step 内部：三线并进 + workflow fan-out（每轮 ≥6 subagent，不狂派）

```
step[N] ─┬─ 执行线（ultracode workflow，fan-out 按文件/子任务，每轮 ≥6 subagent）
         ├─ 审计线（1 个 subagent CC，与执行线同时启，范围=本 step 边界，不指定问题）
         ↓
   主线程亲核（不并行派，亲手核 load-bearing 数字/file:line/口径/frame 残留）
         ↓
   step gate（§3）全绿 → 进 step[N+1]
```

- **fan-out 切分**：按文件切不按行切（同文件多 agent 改 = 文件系统竞争）；有依赖子任务串行（如 S2「删 frame」先于「Normalizer data-driven」）；Edit+Bash 分两轮（parallel-safety 保守）。
- 🔴 **逻辑并行 / 落盘串行**：S2∥S3、S4∥S5 文件域不重叠可逻辑并行，但**共享一个 git 工作树 + 一个 `make verify` 出口**（regen 重写 generated/、diff gate 全量对账）→ 并行 agent 各产 **patch/diff 草案**回主线程，主线程**串行 apply + 单次 make verify**（两个并行刀不能同时 `make regen`，generated/ 竞争）。
- **派不派 workflow 判据**（agents.md 门槛 + lessons G「狂派=混乱源」）：read-heavy + 真独立并行 + 跨 5+ 文件不确定在哪 → 派；**文档精确修正 / 单文件改 / 口径数字回写 = 主线程亲手做**。每次派前扣「这是 read-heavy 独立任务还是机械单文件」。
- **step 复杂度分级**：S0 口径=主线程亲手（仅废口径全仓 grep 可派 1 fan-out）；S1 codegen=1-2 workflow；**S2 核心重写=细切 3 刀**（删 frame / data-driven / unit test，有依赖序串行）；S3=2-3 workflow（yaml 扩/C3 派生/命名清债）；S4=1-2；S5=2（expected codegen / coverage 扩 + 主线程跑 base 验）。
- 并发 **每轮 fan-out ≥6 subagent**（之前 8 也跑过，折中 6；🔴 不担心 limit——limit 是基础设施 rate-limit、非 agent 个数问题。同源 GLM/codex 审计才不并发多）。

---

### 3. 分段审计：每 step【一轮】subagent 审 + 主线程亲核（过程不 loopaudit）

🔴 **磊哥铁律**：过程中每 step 只**一轮**单发 subagent 审（审完即出 verdict，**不循环**），范围=本 step 任务边界，**提示词不指定具体问题**（避免引导漏盲点）；loopaudit 仅 S_CLOSE。

**3.1 一轮 subagent 审提示词模板（只给边界，不给问题）**
```
你是 A2 step[N] 的独立审计员（异于执行线）。本 step 任务边界（只给边界，不给具体要找的问题）：
  - 目标：<本 step 一句话目标>
  - 涉及文件域：<git diff --name-only 拿到的清单>
  - 不应触及：<本 step 之外的文件/行为，如「C5/C6 本 step 不动」>
独立审计（自己判断从哪查查什么，我不指定问题）：
  1. 实跑 swift test + make verify，贴原始 stdout/exit code（不信「应该绿」）。
  2. 实跑 C6 跑 base + verify-gold，贴 receipt 路径 + sha256。
  3. 通读本 step diff，自主判断范式是否真落地 / 口径是否对 / 有无回归 / 有无越界 / 有无半写入。
输出按下方 JSON schema。每 finding 必带 file:line + 一手证据（命令输出/grep），禁凭印象/二手定性；
数字必当场 cite-verify 数据源。你全 rate-limited 或无法实跑 ≠ clean，如实标 blocked。
```

**3.2 审计输出 schema（4 维 + 越界 + 半写入）**
```jsonc
{ "step_id":"0-5", "audit_round":"single", "agent_ran_real_commands":true,  // false/blocked ≠ clean
  "verdicts":{
    "paradigm_aligned":{"verdict":"PASS|FAIL|N/A","generic_frame_removed":true,
      "removal_evidence":"grep tool_call_frame 主链路 → 0 命中 + file:line",
      "evidence_is_code_not_metadata":true},   // 真删代码≠改 removedToolID metadata（铁律1）
    "caliber_correct":{"verdict":"PASS|FAIL|N/A","intent_562":"实算+来源","device_191":"实算+来源",
      "is_intent_not_toolcount":true,           // 562 是 intent 不是工具数
      "scope_tier_landed":true},                // S0 专属:manifest 落盘 source/sha256/验证命令
    "no_regression":{"verdict":"PASS|FAIL","make_verify_exit":0,"swift_test_fail_count":0,
      "c6_base_verify_gold":"pass|fail","raw_stdout_refs":["命令+exit+receipt 路径，实跑非推理"]},
    "boundary_held":{"verdict":"PASS|FAIL","no_training":true,"no_perf_eval":true,
      "no_scope_creep":true,"recipe_ssot_untouched":true}},  // rank16Mainline/codegen 地基未动
  "findings":[{"id":"S{N}-P0-1","severity":"P0|P1|P2","file_line":"path:line",
      "claim_vs_reality":"声称 vs 事实","evidence":"一手命令/grep","fix":"…"}],
  "half_write_check":{"git_status_short":"实跑输出","untracked_generated":[],"stage_committed_consistent":true},
  "overall":"CLEAR|NEEDS-REVISION|BLOCKED" }
```
每 step 审计维度裁剪：S0 无 surface 维度（填 N/A），重审口径+scope_tier+manifest；S2/S4/S5（改 surface 的 step）必审 `paradigm_aligned`+`boundary_held`；S5 额外审「C6 base 链路通且格式对、未评 LoRA 性能」。

**3.3 主线程亲核 checklist（独立核一手，不信「subagent 说核了」）**

| # | 亲核项 | 主线程亲手动作 | 防的坑 | 频次 |
|---|---|---|---|---|
| H1 | 口径 562/191 | `python3` 实算 demo 目录 intent/device 去重计数，核 562 是 **intent** 非工具数 | finder 编数字 / 562 当工具数 | 每 step |
| H2 | scope_tier 真落盘 | `grep -rl scope_tier contracts/ generated/` 实际命中（当前=0）；核 manifest 有 source/sha256/验证命令 | 对不存在字段派生 | S0 |
| H3 | frame 真删非声称 | `grep -rn 'tool_call_frame\|frameToolSchema' Core/` 主链路 0 残留；核 `:2344` 是真删代码不是改字段值 | 铁律1；drift gate 不报 compiler-derived 债 | S2/S4/S5 |
| H4 | test/verify 真绿 | **主线程亲跑** `swift test`+`make verify` 看 exit code，不信「应该绿」 | 铁律2 receipt≠实跑 | 每 step |
| H5 | C6 base 真跑 | 亲核 base receipt sha256+命令+每轴数；action hard_pass base **10/23** 按 case schema 字段拆非 case_id prefix | 铁律3 顶层聚合掩盖子轴 | S_INIT/S5 |
| H6 | file:line 现行有效 | `sed -n` 抽样核 subagent 引的 file:line 内容真在该行 | 凭印象/失效引用 | 抽样 |
| H7 | 半写入对账 | 亲跑 `git status --short`，核生成物已 stage、无未跟踪漂移 | OpenSpec archive 半写入坑 | 每 step |
| H8 | diff gate 真纳新产物 | 核 D-domain 目录 + `generated/10-family-device-map.json` 已进 diff gate 路径（**当前 generated/ 裸奔，本机已核**） | 新硬编码逃 drift gate | S0/S1 |

---

### 4. 监控：进度可见 + 偏离检测信号表

进度用 /goal 状态机（当前 step + 已 gated 数 + commit 分离计数 + 累积 diff 手写/生成物行数）。**偏离信号见红/橙即停回修**：

| 信号 | 检测命令/动作 | 含义 | 动作 |
|---|---|---|---|
| 🔴 越界训练 | grep diff 是否含跑权重/调云 generator/生成语料(.jsonl/metrics.jsonl/checkpoint)/跑 judge | 越 A2 边界（最易越界点） | 停，DEFERRED 不在 A2 |
| 🔴 越界评性能 | C6 是否跑 LoRA/建四层门 | 越 A2 边界 | 停，只跑 base 验格式 |
| 🔴 frame 未删干净 | `grep -rn 'tool_call_frame' Core/` 主链路 >0 | generic frame 残留（**drift gate 不报，本机已核**） | 显式移除 + 异源 + 主线程核 |
| 🔴 口径 drift | `make verify` cross-section 报 caliber_violation；或主线程 python 复算 ≠ 报值 | 562/191/976 写错或分叉 | 停改；B1 扩 BASELINE_GLOBS 兜底 |
| 🔴 562 当工具数 | grep codegen 是否生成「562 个工具」 | 口径错全链路 | 停，562 是 intent；工具数 G2 实算 |
| 🟠 半写入 | `git status --short` 有未跟踪生成物 / make 报 No files changed 实已写 | OpenSpec archive 半写入坑 | git 对账重跑 |
| 🟠 scope_tier 缺位 | S0 后 `grep scope_tier` 仍 0 | codegen 无合法口径源（硬前置） | S0 未完不进 S1 |
| 🟠 配方被改 | `git diff Core/Training/C5LoRATraining.swift` 命中 :1175/LR/adamw | 重开配方混淆变量 | 守现状，撤回 |
| 🟠 scope creep | diff 含本 step 边界外文件/重命名（非命名清债） | behavior-changing 混入 | 只迁 surface 不夹带 |
| 🟡 大爆炸刀 | 单刀 diff 同改 surface+训练+bench / 触 GENERATED+2+ Core 文件+跨 step | Netscape 红 flag | 拆刀 |
| 🟡 类型检查器爆炸 | swift build 出 expression-too-complex/timeout | 生成大字面量无类型标注 | 生成器 emit 显式类型+拆字面量 |
| 🟡 Reports 膨胀 | `du -sh Reports`（现 2.8G） | 产物污染仓 | 中间产物落 raw/.gitignore |

**enforce 覆盖补强（B 段，边重构边落，补本机已核 3 漏点）**：B1 扩 `BASELINE_GLOBS` 纳 `CLAUDE.md`/`docs/srd-*.md`/`baseline-semantic-protocol-2026-06-19.md`/`CONTEXT.md`/`docs/research/INDEX.md`（扩前废口径行标 SUPERSEDED 避误报）；B2 S0 新口径（工具数实算/族外 device）加 `CALIBER_ANCHORS` 单值锚；B3 scope_tier 单源从 S0 manifest 派生纳 diff gate；可选 `make verify-swift` 把 `swift test` 机械化进 Makefile。🔴 **enforce 边界**：cross-section 只查 drift 不查 correctness、**验不了 frame 真删** → 必主线程亲核（H3）+ 异源补，别让 make verify 绿成「假绿放行」。

可选机械门（补 drift gate 盲区，A2 期临时挂 make verify）：`a2_boundary_guard.py`（扫新增训练语料/checkpoint/云 endpoint → exit1，防越界）+ `frame_residue_check.py`（grep 主链路 `tool_call_frame`/`frameToolSchema` 残留 → exit1，补 drift gate 对 compiler-derived 债不报的盲区）+ **generated/ 纳入 diff gate**（本机已核当前裸奔，S1 必补否则新硬编码逃逸）。

---

### 5. 整体推进：依赖序编排 + incremental 分刀 + step close protocol

**5.1 依赖序硬约束（违反=返工）**：`[0]→[1]→[2]→[3]→[4]→[5]`，其中 `[0]→[1]→[2/3]` 严格串行（[1] 消费 [0] manifest；[2] 消费 [1] JSON）；`[2]∥[3]`、`[4]∥[5]` 文件域不重叠可逻辑并行但落盘串行（§2）；合流门 = [4][5] 起手前 [2]∧[3] 都 `swift test`+`make verify` 绿。

**5.2 incremental 分刀（防 Netscape 大爆炸）**：一刀=一个 step 内独立可验收单元，绝不一刀同改 surface+训练+bench；每刀后三必绿（`swift test` 0 fail + `make verify` 绿 + S5 起加 C6 base verify-gold）；每刀=「手写 commit + 生成物 commit」两原子 commit 作回滚锚。S2 核心重写最危必细切 3 刀（删 frame / data-driven / unit test）。**strangler 不变量**：删旧 surface 那刻新 surface 已由前 step codegen 产出且 compiler 能消费 → 链路零中断窗口；删旧前并存可跑（双 surface 共存期=合规中间态）。中途每 step 跑 C6 base 当活体检验（防塌缩不等终局）。

**5.3 step close protocol（每 step/每刀末固定 7 动作，缺一不算收口）**：
```
1. review diff（逐块看，确认只迁 surface 不夹带）
2. git stage 分两组：a) 生成物组(generated/ + regen 的 contracts/) b) 手写组(Core/*.swift + scripts + Makefile + 手写 yaml)
3. make verify（含 git diff --exit-code 漂移门；绿才继续，红→回 step 修）
4. swift test 0 fail（S5 起加 C6 跑 base verify-gold pass）
5. git status --short 对账（防半写入；必须干净）
6. commit 分两次：a) "chore(codegen): regen D-domain surface (step[N])" b) "<type>: step[N] 手写逻辑"
7. 完整性 gate：对账「本 step 计划 modify 的文件 vs git diff 实际改的」——标了没改=执行 gap（补执行，不进审计循环）
```
（stage 分两组**先于** commit：make verify 的 diff gate 是 `git diff --exit-code`，先 stage 才验「暂存态=重生成态」一致。）

**5.4 失败回滚**：可前修（编译错/test fail/口径错）→ 留本 state，write-test-fix 内循环修不回滚；子任务 X 坏 Y/Z 好 → 仅 `git checkout -- <X>`；整 step 方向错 → `git reset --hard <Sn-1 已签 commit>`（旧路径 strangler 残留仍可跑）。每 step 末打 tag（`a2-step0-done`…）作粗粒度回滚点。

**5.5 step gate（进下一 step 的硬门，合取全绿）**：① 审计线 verdict=CLEAR（NEEDS-REVISION 回修；BLOCKED/全 rate-limited≠clean，重派）② 主线程亲核（§3.3 该 step 必核项）全过 ③ 三门绿（swift test 0 fail + make verify 绿 + C6 base verify-gold）④ 半写入对账干净 + 生成物/手写 commit 分离 ⑤ 本 step P0/P1 全修 ⑥ §4 红/橙偏离信号 0 命中。修复守**收敛定律：修复范围 ⊇ 审计范围 ⊇ 执行范围**。

**5.6 agree-before-build**：archived spec（C1/C2/C3/C6）MODIFY 走 OpenSpec change `migrate-d-domain-tool-surface`（DRAFT→propose 对齐→apply），**不直接改 archived**；其余 3 change（retrain-c5/rebuild-c6/golden-run）保持 DEFERRED banner 在位。

---

### 6. 收口：loopaudit 仅整体最终用（6 step 全 gated 后）

🔴 **过程每 step 只一轮审；loopaudit 开放式循环审计至无 P0/P1 仅用于 A2 全 6 步完成后的整体最终收口**（每 step 跑 loopaudit = over-engineering + 6 倍阻塞）。

- **触发**：A2 全 6 step gate 全绿 + 各 step P0/P1 已清。
- **形式**：`loopaudit` skill，targets = A2 全量代码产出（generated/D-domain 目录、state-cells.yaml、ToolContractCompiler/C5LoRATraining/C5TrainingCLI/C6VehicleToolBench/DemoVehicleStateStore/FastPathIntentEngine/C3ExecutionPipeline、gen_tool_contract.py、S0 manifest、migrate change）；scope = 一句话范围**不列问题**（开放式核心）；维度 ≥3 subagent（默认 10 维 + A2 专补：范式对齐/frame 真删/口径全仓/不退化/边界守/data-driven/健壮性/commit 分离/archived 走 change/历史档 vs 活基线）；perAgent=3（PANEL≈4）；maxRounds=5；outDir=`docs/research/2026-06-23-a2-loopaudit-closeout/`。
- **收敛定律强制**：修复 targets 动态 = 初始 ∪ findings location 涉及文件；执行后完整性 gate 先于审计（标 modify≠已 modify → 补执行不进循环）；finding 分两类（产出 bug→Edit 修 / 执行 gap→补执行）；反复报同口径问题不收敛 → `dispute-triage` 分诊，口径型（562 vs 旧 534/2086）**上抛磊哥拍板非无限核**（562 已终拍，遇旧值是历史档判定，标 historical 不改正文）。
- **防假 clean**：`panelOk`（≥半数 agent 成功非空才认 clean，全 rate-limited/空 ≠ clean）；clean = panel 足 AND 零 P0/P1；**主线程亲核覆盖审计漏点**（loopaudit 报 clean 后仍独立 grep 主链路 `tool_call_frame` 残留 + 抽样核 D-domain 工具名是否真从 codegen 派生 + python 复算口径）；异源加分（panel 内掺 1 个 hermes/GLM-5.2 破同 family bias，尤其核 frame 真删 vs drift gate 不报的 compiler-derived 债）；留痕 `round-NN/audit-i.md`+`fixes.md`+`ledger.md`。
- **判据**：`clean=true`（一轮零 P0/P1，panel 足）→ 进 §7；`STOPPED@5` → 如实报磊哥剩余 P0/P1 别假 clean，不收敛根因若口径型 → 上抛拍板。

---

### 7. A2 完成判据（code 层验收门，非模型性能；每条主线程亲核一手）

| # | 验收门 | 核验方式 |
|---|---|---|
| 1 | surface 全 D-domain，`tool_call_frame` generic frame **显式移除** | grep 主链路无残留（异源+主线程核，非靠 drift gate） |
| 2 | ToolContractCompiler data-driven 消费 generated JSON，无硬编码 if-else surface，有 unit test | Read 确认无 `dDomainSurfaceNames` 硬编码 + `swift test` 含 compiler unit test 绿 |
| 3 | scope_tier/allowlist manifest 落盘（source/sha256/验证命令）+ 纳入 diff gate | 文件存在 + make verify diff gate 覆盖 |
| 4 | C5 生成器**代码能产** D-domain shape（CLI `--scope`/`--surface` 可用）；**未生成语料、未重训** | CLI 跑通产 shape + grep 无云 generator/训练触发（边界守） |
| 5 | C6 expected 全 D-domain + 10 族 191 device coverage；**跑 base** verify-gold pass + A2-before baseline receipt freeze；**未跑 LoRA 评性能、未建四层门** | C6 base 跑通 + receipt freeze（每轴 base 数 action hard_pass base 10/23）+ grep 无 LoRA 评测/四层门 |
| 6 | state-cells 10 族 191 device + C3 映射派生 + 命名清债（无 hvac.ac 双轨） | grep `hvac.ac` 主链路 0 + state-cells device count=191 |
| 7 | 口径全仓 562/191/976 统一 | cross-section 扩 BASELINE_GLOBS 后 make verify 绿（B1/B2 落地） |
| 8 | `swift test` 0 fail + `make verify` 绿（**每 step 都绿非只终局**） | 每 step close protocol 留痕 + 终局全跑一次 |
| 9 | 生成物 commit 与手写 commit 分离；archived spec 走 migrate change | git log 确认分离 + archived 无直接改 |
| 10 | 起手归档全引一手（口径用终拍 562 非 README 正文 534/2086） | 主线程亲核所有 load-bearing 数字源 |
| 11 | lessons-learned 持续追加；loopaudit 整体收口至无 P0/P1 留痕 | `docs/lessons-learned.md` + loopaudit ledger.md clean |

> **元洞察（pre-mortem 收敛）**：A2 的失败 7 类（越界/frame 没删/假 clean/标 modify≠已 modify/scope_tier 对不存在字段派生/半写入/口径漂）同根 = **「声称层 vs 事实层脱节」的不同变体**——本项目代码自己就是活样本（`:2344` metadata 声称删 vs `:2362` 仍 emit）。harness 核心防范 = **机械门补 drift gate 盲区（frame_residue/boundary_guard/generated 进 diff/口径锚扩）+ 行为门取代状态字段 + 主线程亲核一手**，enforce 降低对自觉依赖但不替代「写每个数字时」的扳机。

---

## J. harness 待磊哥拍点 + 主线程亲核坐实（gaps_or_risks）

### 🔴 主线程亲核坐实（claim-vs-reality，A2 执行方可直接信，无需重核）
- ✅ **generated/ 裸奔确认**：`generated/` 有 5 个 git-tracked 文件（`10-family-device-map.json` / `B_frame.frame_schema.json` / `10-family-device-boundary.md` 等），但 `Makefile:51` diff gate 只含 `$(GENERATED_CONTRACTS)`（全 `contracts/`）+ HANDWRITTEN + scripts + Makefile，**不含 `generated/`**；`.gitignore` 无 generated → git-tracked 但 regen 漂移**不报**。👉 **step[1] D-domain 产物 + `generated/` 必显式纳入 diff gate**（否则新硬编码逃逸）。
- ✅ **frame metadata 假删确认**：`C5LoRATraining.swift:2344 removedToolID:"tool_call_frame"`（负样本 metadata 声称移除）vs `:2362 C5TrainingToolCall(name:"tool_call_frame", ...)`（正样本仍 emit）= claim-vs-reality 铁律1 活样本。👉 **frame 删用 `grep` 行为门核，不信 metadata**。

### 待磊哥拍（7 条，A2 起跑前确认）
1. **工具数 G2 实算 + col O 提取**（step[0] 硬阻塞）：562 是 intent 非工具数；col O 优先级在 raw xlsx 第15列不在 jsonl。授权执行方实算后回拍，还是磊哥先定 col O 提取方式？
2. **C6 性能 parity 阈值/抽样轴 = DEFERRED**（待 grill Q06）：A2 只 freeze A2-before baseline 不评 LoRA 性能，执行方不可自拍性能门。✅（已是延后决策，确认即可）
3. **受限解码 vendor = DEFERRED**：别让执行方在 S2/S4 顺手引 mlx-swift-structured C++（属越界）。✅（确认）
4. **可选机械门 Elevate-or-Kill**：`generated/` 进 diff gate = 已核**必做**；`a2_boundary_guard.py`（防越界训练）/ `frame_residue_check.py`（补 drift gate 对 frame 残留盲区）是否值得 A2 期临时建，vs 纯靠主线程亲核 H3？（⭐ 建议建 frame_residue + generated 进 diff，boundary_guard 可选）
5. **.a2-goal-state.json 双锚 vs git 单源**：状态文件可能与 git 分叉，harness 规定「以 git 为事实层 + 实跑 verify 确认」——纪律点非机械门，仍依赖自觉。
6. **逻辑并行落盘串行协调成本**：S2∥S3/S4∥S5 若改动量小，主线程直接串行可能比「并行产 patch 草案 + 串行 apply」更优，执行方按 step 量级判断。
7. **loopaudit 异源 panel**：S_CLOSE 收口掺 hermes/GLM 破 same-family bias = 推荐项，但异源走 API 计费 + 可能 rate-limit，是否授权？（⭐ 建议授权，frame 真删/口径正确 cross-vendor 核值）


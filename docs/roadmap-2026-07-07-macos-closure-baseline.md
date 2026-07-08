---
authority: baseline_roadmap（基线文档组成员；与 CLAUDE.md/OpenSpec specs/grill SSOT 冲突时让位并须回写）
status: active_baseline_v4（2026-07-08 增量：Line B 执行态刷新[S4-S8 已跑到 S8 暂停窗口] + 任务④ UIUE/runtime 编入成 Line D + §八 粗路线图；v3 两轮审计毕的正文骨架不动）
author: claude-commander (Fable5, 磊哥拍板「亲自编写」2026-07-07 傍晚；v4 增量 2026-07-08 晨磊哥令「三任务结合 macOS app UIUE 和 runtime=任务④，存档+粗路线图」)
basis: opt/streamline-macos-20260707 @ 04d8cd88 + w20a run dir（S7c recert D-120 + S8 r1/r2 receipts）+ 终审 FINAL-SESSION-AUDIT=GO
supersedes: 本文件是三线融合调度层；任务①②③各自的 run-dir 计划（SYNTHESIS-v2 / IMPL-PLAN-v3 / task3 弹药）保持有效
retire_trigger: macOS app 全功能闭环达成，或磊哥重定路线
---

# 融合基线 Roadmap：推进到 macOS app 全功能闭环（2026-07-07）

> **北极星（不变）**：客户现场 5 分钟内——听懂中文、反应快、不崩、看着惊艳、断网也能跑（CLAUDE.md §1）。
> **本文件的增量**：把「能演」从今天的单工具面（mounted=1：调到26度）推进到 **macOS app 全功能闭环**——三条线（架构健康 × 模型能力 × 能力面扩展）的融合调度基线。iOS 实机演示已废弃（磊哥 Q2=C，2026-07-07），一切演示面 = macOS app demo；音乐/导航/外卖 via MCP 为二期。

## 〇、四线一图（谁供给谁；v4 起 = 四线）

```
Line A 架构健康(任务①后续)  ──供给──> 可插拔载体(ToolProvider change)/干净 verify 链/God-file 拆分
Line B 模型能力(任务②后续)  ──供给──> register 补洞后的新 adapter（hedged/can-question 出手率）
Line C 能力面扩展(任务③)    ──消费 A+B──> mounted 1→N 扩挂载分诊 + 兜底话术 = 「随口说不丢脸」
Line D UIUE+runtime(任务④) ──消费 A+B+C──> macOS app 的脸面与骨骼：视觉/交互/语音链路/演示编排
macOS app 全功能闭环 = A 的载体 × B 的模型 × C 的能力面 SSOT × D 的体验层，四线在 P2 汇合
```

**今天的能力面真值（task3 冰山 teardown 亲核，2026-07-07）**：三层断崖 = ir_map **562** 全集（`Core/Contracts/DDomainIRMap.generated.swift`）→ mounted 白名单 **1**（`Core/Contracts/DDomainMountedToolCatalog.swift:12-14`，仅 `adjust_ac_temperature_to_number`）→ semantic contract 可执行 **2**、10族×4值形态×3register 的 120 格矩阵**今天仅 1 格可演**（ac+STATE+直述）。⚠️ 旧口径「可执行 136」已纠错：136 系 ir_map `adjust` 前缀子分类计数（`docs/research/2026-06-23-a2-execution/S5-c6-bench-INDEX.md:15`），非可执行数。fastpath 仅字面「打开空调」（`Core/Intent/FastPathIntentEngine.swift:12`）；hedged register 运行时零存在（register 窗立项原因）；兜底话术单一不分族。

## 一、Line B：register 窗 → 新 adapter（关键路径，优先级最高）

> SSOT = w20a run dir `register-window/IMPL-PLAN-v3.md`（12 stage）+ **S3-FINAL**（S3-GENERATION-SPEC-draft.md v3，对抗审三轮 P1 全闭）。本节只写融合层调度与磊哥新拍。

| step | 内容 | 执行方（磊哥 2026-07-07 拍：**不派 Opus**） | 门 |
|---|---|---|---|
| S4 首批 50 | 按 S3-FINAL 生成 + 全审校准 | ⭐**hermes(GLM) 生成 + codex judge 盲判**（保异源：生成方≠判方≠同厂商；原 v3 附录「Opus 生成」被 D-116 supersede——**v3 文件头已加 amendment 指针**，消歧闭环）。GLM 中文话术质量风险（审计一 hermes P0-1）由 v3 原生门对冲：首批 50 全审 + 工艺 PASS 才准 S5，fail=改 prompt 重出非孤立剔行 | checklist 全格 + 机械门全绿 + judge 50/50 全审（IMPL-PLAN-v3 S4 段:129）+ commander 宣工艺 PASS |
| S5 批量 ~350 | 分批生成 + 抽检 + fail 分级 | 同上（hermes 分批，codex 抽检 judge） | v3 S5 门 |
| S6 组装 | 守恒断言 + mounted_tool_shape 组装层 stamp | codex | 守恒 + final authority scan |
| S7/S7b/S7c | 门链全量 + causal-bet receipt + learnability micro-probe | codex 执行 + commander receipt | **S7c PASS = run-auth 自动生效（D-114）** |
| S8 | 1800 iters 正式训练 | codex executor（§14 范式） | 五布尔：S7c PASS + host fresh resample PASS（不 waiver）+ W20A mechanical green + S7b receipt + v3 gates |
| S9-S11 | 三臂 eval + qa safety receipt + verdict + renderer ack | codex + commander verdict | S10 四类分流已预拍（D-114）；holdout 塌不 waiver |

**host HOLD**：S8 前磊哥关重 GUI → codex 跑 fresh resample → PASS 才点火（唯一剩余人工动作：关 GUI 的时机）。
**pause 规则**：S7c PASS 信号一到，Line A/C 的 worker 完成当前 reversible 步即让路 Line B（S7c pause 哨兵提案已备，`run dir out/s7c-pause-sentinel-proposal.md`）。

**🟢 Line B 执行态刷新（2026-07-08 晨，v4 增量；上表 S4-S7 全部已执行完毕留档）**：
- S4/S5/S6/S7/S7b/host 全绿（通宵链 D-119 执行账）；S4 生成位实际走了 Opus v1 FAIL→Fable5 low v2 PASS（D-118），非表内 hermes——表保留为当时拍法，实况以 D-116-amend/D-118 为准。
- S7c 三跑停线（`receipt_gen_rerun2.json#movement_threshold_declared`=3 对 `#baseline_no_tool_count`=2 数学不可能）→ 磊哥拍 **Option A 量尺诚实化重判**（D-120：grill GA-1~10 + 对抗审计 AUDIT_FAIL 三 findings 全清 → recert 盖章 → 点火）。
- S8 点火两次均中断：r1 iter 170 lid-sleep 杀进程（哨兵正确分类 resumable）；r2 磊哥主动 pause（工作占机，`OPERATOR-PAUSE-RECEIPT.md`）。**当前态 = S8 待重启窗口**（磊哥晚间不用 Mac 时一句话重启，全新完整 1800，~9-11h，无 stale-schedule 风险）。
- 剩余序：S8 重启跑完 → S9 三臂 eval（runbook 备；holdout 生成席位待拍）→ S9b → S10 verdict（模板备，四类分流 D-114 预拍）→ S11 renderer ack。

## 二、Line A：架构健康按部就班（整改方案实施层）

> SSOT = `docs/research/2026-07-07-streamline-review/README.md`（整改方案总入口）+ `reduction-table.md`（as_of_head 账）。已完成 B0-B7（18 commit，终审 GO）。后续每刀独立立单，验收门内建。

| 刀 | 内容 | 前置 | 风险/谁拍 |
|---|---|---|---|
| A0 🔴T1 crash 快修 | FastPath `noMatch` 逃逸（`Core/Intent/FastPathIntentEngine.swift:3-4` 非 `DDomainToolPlanFailure` 子类，`Core/Execution/DemoRuntimeSessionRunner.swift:55` catch 不到）——客户随口一句可能 crash，撞「不崩」北极星 | 先测后修（task3 T1 验证清单：test runner.run 任意句→若 crash 加 catch→unsupportedPayload 兜底） | 高优先低风险；验收=新增回归测试+全量 swift test |
| A1 ToolProvider Slice A/C 编码 | DomainRegistry + ExternalToolInvocation 词表（change 四件套已 validate 绿，proof-class=Option A 已拍） | 无（可立即） | 低；验收=targeted tests + no App/C3 callsite diff + 强词 grep + verify-all |
| A2 macOS convergence Task2-5 | shared scheme + capture/check 脚本 + evidence 包 + 只读审计门（proof cap=`local/mac_runtime_smoke`） | lane 就绪报告已备（stale 8 项已修正口径） | 低中；独立分支 `opt/macos-demo-package-*` |
| A3 God-file 拆分第一刀 | C6Hash/C6ToolCall/CanonicalJSON 等 runtime primitives 从 Bench/Training 抽到 Contracts/Support（architecture-roadmap.md §2） | A1 后（同属结构手术，错峰） | 中；GitNexus impact + verify-all + 全量 swift test |
| A4 dev-time target split | Bench/Training/Generation 移出 app 编译面（SwiftPM target + Xcode membership） | A3 | 中；磊哥过目方案再动 |
| A5 延期项触发 | Reports 退仓执行 / frozen tarball / iOS-only 4 件处置 / 47万行 manifest artifact policy | 各自 trigger（reduction-table 记 owner） | 高；**逐项磊哥点头** |

## 三、Line C：能力面扩展（任务③，「随口说不丢脸」）

> 弹药已回稿（run dir `out/task3-capability-iceberg-teardown.md`，P0=0/P1=2）：四道墙级联 reject 链坐实（FastPath 字面量→mounted 1→semantic 2→state cells 2）；T1 crash 逃逸（转 Line A0 快修）；T3 兜底话术单一不分族（HIGH，撞北极星，进 C3）；范式层三提案=DemoCapabilityMatrix SSOT / 扩面三路分诊 / GracefulFallbackGate 三道门。

1. **C1 立项 grill**（弹药已回，进模块 grill 总清单）：走重大派单范式（grill+红队成对）——议题：能力面 SSOT 落哪 / 兜底话术验收门 / 🔴**挂载决策表（审计二 P0-2 吸收：骨架现在定型，⭐草案进 BATCH1 拍板）**：
   | S10 hedged+can-question 联合出手率 | 挂载批 | 备注 |
   |---|---|---|
   | <40% | 0（不扩，回 S10 分流处置） | 模型不支撑 |
   | 40-70% | 3 族主 cell（空调/车窗/座椅） | 保守首批+兜底话术兜边缘 |
   | >70% | 10 族主 cell 全批 | 每族 1 主工具，非全 562 |
   出手率口径=S9 三臂 eval 的结构化字段（非 prose）；表本身磊哥 BATCH1 拍，S10 出数即按表执行零临场。
2. **C2 扩挂载第一批**：依赖 **Line B S10 verdict**（新 adapter 对 hedged/can-question 的真实出手率决定敢挂多少）+ **Line A A1**（载体干净）。mounted 1→N 是「有意改变用户可见 demo 行为」= **磊哥拍**。
3. **C3 兜底链路验收**：被拒语料的端上呈现（UI/TTS 话术）过「不丢脸」门——探针语料「我希望把窗户打开50%」进 S4 golden/eval 候选（已拍）。

## 三点五、Line D：macOS app UIUE + runtime（任务④，2026-07-08 立项，v4 新增）

> 磊哥令（2026-07-08 晨）：「这三个任务结合 macosapp 的 UIUE 和 runtime【任务④】」。定位 = 闭环的**脸面与骨骼**：A 给载体、B 给大脑、C 给能力面，D 把它们装进客户看得见摸得着的 macOS app。
> 🔴 **主刀铁律**（磊哥 2026-07-07 深夜定，memory `feedback-uiue-no-codex`）：UIUE 开发 = **commander(Fable)/Claude 亲自主刀 + 精 grill + 视觉验收门**（aesthetic-first 5 Gate + 还原用户实查环境），codex 只做机械接线/测试位——「codex 开发前端很 low，之前 iOS 我是不太满意的，回头到 macos uiue 我们好好干」。

**scope 两半**（按 MG-7=C 的闭环定义框定，D-117）：
| 半 | 内容 | 已有资产（起点不是零） | 依赖 |
|---|---|---|---|
| **D-UI（UIUE macOS 适配）** | 现有 UIUE（链路 A 7 态视觉已并 main，2026-06-24 PR #5）从 iPhone 布局适配到 macOS 主演示面（Q2=C：iOS 冻结）；Mac 左右分栏等已 grill 决策（V12/U14 系）承接不重拍；触摸→点击/悬停语义转换；演示编排（场景流/force-state） | UIUE grill U1-U31 + D1-D8 + V 系决策（grill-decisions-master 挂 Q30-38）；MAformac-uiue 隔离目录历史 | Line A A2（macOS lane）+ A1（载体） |
| **D-RT（runtime 接线）** | 新 adapter 接入 LLMBackend（mlx-swift-lm）；TTS = AVSpeechSynthesizer（MG-7=C 硬门内）；文本主交互；DialogueState 短时记忆；真 ASR（SFSpeechRecognizer 主，D14 amend）**不进硬门**、作 stretch | C3 mock 闭环 + W20A runtime path（D-domain {name,arguments}→C3 readback 已通） | Line B S10 verdict（adapter 可用性） |

**Line D 验收维度清单（v4 audit P1-1 吸收：防 D1 派单降级成「泛视觉 review」——正是 iOS 期磊哥不满的病根）**：
| 维 | 内容 | 权威锚 |
|---|---|---|
| 七态视觉消费 | DemoVisualState 7 态各自正面渲染、四态分开（clarify琥珀≠unsupported灰≠safety红≠crash灰）；现役债 `ContentView:122/:126` 二值压缩 | grill-master D7（:222 附近晶体表）|
| 视觉门 | U17 snapshot+黄金路径 XCUITest（衔接 U32-U37 视觉门）+ aesthetic-first 5 Gate + 还原用户实查 | grill-master :208 U17 + rules aesthetic-first |
| voice/TTS preflight | AVSpeechSynthesizer 硬门内；U28 高级中文 voice preflight 属 DEFERRED 独立立项（stretch 不进硬门） | grill-master :208（U21/U22/U28 DEFERRED）+ MG-7=C |
| runtime/readback | 新 adapter→LLMBackend→C3 readback；proof cap=`local/mac_runtime_smoke` 起步不升格 | W20A closeout + MG-6 拍后 |

**推进式（v4 audit P1-2 吸收：UIUE 前置化——视觉原型不 gate 在 S10 后，只有 adapter 接线 gate S10）**：
1. **D0 立项 grill**（已在产）：已决 recall（防重拍 U/V/D 系）+ macOS 适配未决议题骨架，与 C1 同批走模块 grill 范式（宪法 §21）。
2. **D1a 视觉原型 + 验收 harness**（**S8/S9 期间即可并行**，不等 S10）：七态渲染面/截图门/L0-L2 分层测试骨架先立起来，视觉迭代窗口前置。
3. **D2 runtime 接线**（gate = S10 verdict）：新 adapter 接 LLMBackend + readback；golden-run 脚本（汇合点门 4）在此实装。
4. **D1 UIUE 专场**（commander 亲笔，磊哥说「好好干」= 高投入窗口）+ **D3 演示编排彩排**：demo-scenarios 全场景 + 兜底话术分族（C3 供给）+ 5 分钟现场彩排门。

## 四、汇合点：macOS app 全功能闭环的验收定义（P2）

全功能闭环 = 以下五门全绿（审计一 P0-1 吸收：每门绑验收命令/receipt 路径，禁 prose 声称；命令在各门实装时固化进 Makefile/脚本，此处为命令形态承诺）：
1. **模型门**：S10 verdict receipt（结构化字段非 prose）+ `make verify-c5-phase1-gates` rc0 + qa safety receipt 文件存在且 schema 过 checker——S10 receipt 的机械 checker 在 S9b 实装时固化（M-MODEL grill 议题）。
2. **能力面门**：DemoCapabilityMatrix SSOT 文件落地后 `python3 scripts/check_capability_matrix.py`（C1 grill 拍落点后实装）——每格 执行/拒识/兜底 显式，不允许 unknown 格。
3. **架构门**：`make verify-all` rc0 + `make verify-register` rc0 + A1 验收（`git diff --name-only` 无 App/C3 命中 + targeted tests）+ A3 后全量 swift test `Executed N>597, 0 failures`。
4. **演示门**：golden-run 脚本 exit 0（demo-scenarios 全场景 + 兜底话术分族断言）+ A2 evidence validator PASS（`check-macos-demo-evidence.py`，proof cap=`local/mac_runtime_smoke` 起步）。golden-run 当前未实现（审计二 P0-1 诚实标注）：其 command/receipt schema（scenario_id×结局×readback×proof_class 四字段/场景）由 M-DEMO grill 拍板后的实装单产出，本门在此前记 `PENDING_IMPLEMENTATION` 不记绿。
5. **诚实门**：强词 grep 0 命中（V-PASS/runtime-ready/mobile/true_device 只许 non-claim 语境）+ candidate 状态字段=unsigned 直到 R-L17 G1-G5 artifact 齐。

## 五、执行编排（6 worker 常备，无 Opus）

- **组成（2026-07-08 晨重建，ma7 逐 pane capture-pane 亲核为准——型号字串以 pane footer 实显为 source，全员绕代理 env -u 启动）**：**5 codex**（@%1/%5/%2/%3/%4）+ **1 hermes**（@%6）。commander=%0。角色灵活：codex 承担【实装/judge/机械门/红队/秘书】，hermes 承担【异源审计/只读盘点】。（v3 时期阵容留档 D-116 系；阵容随磊哥调整浮动，派单前必逐 pane capture 重核，宪法 §20。）
- **纪律**（本 session PROVEN 全继承）：worker 零 commit 权；SPEC 文件+短消息；收稿三验+载力断言亲核；gate 自身改动必附 `gate_strength_delta`（M.41）；批量 docs 动作前 fresh inventory（M.44）；commander stage 用显式 pathspec、amend 前核 HEAD（M.45）。
- **优先级仲裁**：Line B > Line A > Line C（弹药类并行不占关键路径）；S7c PASS 触发全员让路 S8 链。

## 六、待磊哥键（v4 刷新现值，全部条件式/低频）

| 键 | 触发时机 |
|---|---|
| 🔴 **S8 重启令**（当前唯一关键路径键） | 晚间不用 Mac 的 ~9-11h 窗口，一句话即点火（门链/recert 全就绪） |
| BATCH2 / BATCH-INFRA 两份 ballot | 有空扫一眼（5 题 + 15 问，打字列已备） |
| S9 holdout 生成席位方案 | 三选一（s9-holdout-gen-plan） |
| C2 扩挂载批 | S10 verdict 出数即按 BATCH1 已拍决策表执行（<40%/40-70%/>70% 三档，零临场） |
| A4/A5 各刀点头 + CLAUDE §9 手术 | 各自方案呈报时 |
| Q18 分支 | 仅 S10 失败分类触发（D-114） |
| D1 UIUE 专场开工令 | Line D D0 grill 收口后（磊哥说「好好干」的专场窗口） |

（v3 时期「S4 开跑令/关重 GUI」等键已消费，留档。）

## 七、粗路线图（v4 新增：四线时序一页图，磊哥 2026-07-08 令）

```
现在(07-08 白天, 磊哥用机)   训练窗(磊哥拍, ~9-11h)      S9-S10(训后 1 天内)         C/D 汇合段                 收口
───────────────────────────┬──────────────────────────┬──────────────────────────┬──────────────────────────┬─────────────
Line B  [暂停待窗口]────────→ S8 全新完整1800 跑完 ────→ S9 三臂 eval → S10 verdict ─→(供给 C2/D2)
Line C  C1 grill 骨架+矩阵──→ (文档线不占资源, 继续)───→ C2 扩挂载(按已拍三档表)────→ C3 兜底链路验收──────────→┐
Line D  D0 grill + D1a 视觉原型/harness(不等S10)──────→ D2 接线(gate=S10 verdict)──→ D1 UIUE 专场 + D3 彩排──→ 五门全绿
Line A  A3 God-file 拆分/A4 target split(错峰机械活)──→ (随时插队, 不占关键路径)──────────────────────────────→┘
```

- **关键路径** = Line B（S8→S10）；其余三线全是「不占训练资源」的并行面，训练窗随时让路。
- **S8 重启语义**（v4 audit P2-2）：= **全新完整 1800 重点火（fresh relaunch，C=0）**，非续跑——r1/r2 均无 checkpoint，无 stale-schedule 风险（`OPERATOR-PAUSE-RECEIPT.md`）。
- **两个人工节点**：S8 重启令（磊哥）→ D1 UIUE 专场（commander 亲笔 + 磊哥近距离 grill）。
- **收口定义**不变 = §四 五门全绿（模型/能力面/架构/演示/诚实）。

## 八、指针（本文件是调度层，细节回各 SSOT）

- Line B：`runs/2026-07-07-w20a-grill-closeout/register-window/{IMPL-PLAN-v3.md, S3-GENERATION-SPEC-draft.md(S3-FINAL), S7-HOST-READINESS-CHECK.md, s4-dispatch-template(run dir out/)}`
- Line A：`docs/research/2026-07-07-streamline-review/{README.md, reduction-table.md, architecture-roadmap.md, macos-lane-readiness.md}`
- Line C：`runs/2026-07-07-ma-opt-refactor/out/task3-capability-iceberg-teardown.md`（弹药）+ `runs/2026-07-07-ma-opt-refactor/out/c1-design-drafts.md`（C1 设计草稿；🔴v4 audit P1-3 修正——原误写 grill-skeleton/ 目录）+ `runs/2026-07-08-daywork/capability-matrix-draft.md`（120 格矩阵首版：执行1/拒识36/兜底76/unknown7 待清零）
- Line D：UIUE 已决 = `docs/grill-tournament/grill-decisions-master.md`（U1-U31 收口见 :207-222，V1-V12 见 :134，D1-D7 深 grill + D8.x 后续段——引用带锚防 D 编号撞车，v4 audit P2-1）+ 主刀铁律权威 = `decisions.md` D-121（memory feedback-uiue-no-codex 为背景，决策记录为准，v4 audit P2-3）；D0 grill 骨架落 run dir（在产）
- 决策链：`docs/commander-log/decisions.md` D-114/D-115/D-116；grill SSOT 与范式权威不变（CLAUDE.md §9 起手读链）

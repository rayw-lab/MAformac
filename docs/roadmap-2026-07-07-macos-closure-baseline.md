---
authority: baseline_roadmap（基线文档组成员；与 CLAUDE.md/OpenSpec specs/grill SSOT 冲突时让位并须回写）
status: active_baseline_v3（两轮审计毕：审计一 3P0+审计二 3P0 全吸收——P0-3 以 v3/S3 正文级联替换闭合非仅头部指针）
author: claude-commander (Fable5, 磊哥拍板「亲自编写」2026-07-07 傍晚)
basis: opt/streamline-macos-20260707 @ e0f2f89d + w20a run dir S3-FINAL + 终审 FINAL-SESSION-AUDIT=GO
supersedes: 本文件是三线融合首版；任务①②③各自的 run-dir 计划（SYNTHESIS-v2 / IMPL-PLAN-v3 / task3 弹药）保持有效，本文件是其上的融合调度层
retire_trigger: macOS app 全功能闭环达成，或磊哥重定路线
---

# 融合基线 Roadmap：推进到 macOS app 全功能闭环（2026-07-07）

> **北极星（不变）**：客户现场 5 分钟内——听懂中文、反应快、不崩、看着惊艳、断网也能跑（CLAUDE.md §1）。
> **本文件的增量**：把「能演」从今天的单工具面（mounted=1：调到26度）推进到 **macOS app 全功能闭环**——三条线（架构健康 × 模型能力 × 能力面扩展）的融合调度基线。iOS 实机演示已废弃（磊哥 Q2=C，2026-07-07），一切演示面 = macOS app demo；音乐/导航/外卖 via MCP 为二期。

## 〇、三线一图（谁供给谁）

```
Line A 架构健康(任务①后续)  ──供给──> 可插拔载体(ToolProvider change)/干净 verify 链/God-file 拆分
Line B 模型能力(任务②后续)  ──供给──> register 补洞后的新 adapter（hedged/can-question 出手率）
Line C 能力面扩展(任务③)    ──消费 A+B──> mounted 1→N 扩挂载分诊 + 兜底话术 = 「随口说不丢脸」
macOS app 全功能闭环 = A 的载体 × B 的模型 × C 的能力面 SSOT，三线在 P2 汇合
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

## 四、汇合点：macOS app 全功能闭环的验收定义（P2）

全功能闭环 = 以下五门全绿（审计一 P0-1 吸收：每门绑验收命令/receipt 路径，禁 prose 声称；命令在各门实装时固化进 Makefile/脚本，此处为命令形态承诺）：
1. **模型门**：S10 verdict receipt（结构化字段非 prose）+ `make verify-c5-phase1-gates` rc0 + qa safety receipt 文件存在且 schema 过 checker——S10 receipt 的机械 checker 在 S9b 实装时固化（M-MODEL grill 议题）。
2. **能力面门**：DemoCapabilityMatrix SSOT 文件落地后 `python3 scripts/check_capability_matrix.py`（C1 grill 拍落点后实装）——每格 执行/拒识/兜底 显式，不允许 unknown 格。
3. **架构门**：`make verify-all` rc0 + `make verify-register` rc0 + A1 验收（`git diff --name-only` 无 App/C3 命中 + targeted tests）+ A3 后全量 swift test `Executed N>597, 0 failures`。
4. **演示门**：golden-run 脚本 exit 0（demo-scenarios 全场景 + 兜底话术分族断言）+ A2 evidence validator PASS（`check-macos-demo-evidence.py`，proof cap=`local/mac_runtime_smoke` 起步）。golden-run 当前未实现（审计二 P0-1 诚实标注）：其 command/receipt schema（scenario_id×结局×readback×proof_class 四字段/场景）由 M-DEMO grill 拍板后的实装单产出，本门在此前记 `PENDING_IMPLEMENTATION` 不记绿。
5. **诚实门**：强词 grep 0 命中（V-PASS/runtime-ready/mobile/true_device 只许 non-claim 语境）+ candidate 状态字段=unsigned 直到 R-L17 G1-G5 artifact 齐。

## 五、执行编排（6 worker 常备，无 Opus）

- **组成（磊哥 2026-07-07 调整，pane 亲核）**：4 codex（gpt-5.5 @%28/%29/%30/%27）+ **2 hermes**（glm-5.2 @%26/%31，异源位加倍）。角色灵活（磊哥拍）：hermes 双实例默认承担【异源生成（S4/S5 可并行两路）/ 跨厂商审计 / 冰山 teardown】，codex 承担【judge 盲判 / 机械门 / 实装 / 红队】——S4 生成吞吐随 2 hermes 提升，生成与 judge 仍严格异源。
- **纪律**（本 session PROVEN 全继承）：worker 零 commit 权；SPEC 文件+短消息；收稿三验+载力断言亲核；gate 自身改动必附 `gate_strength_delta`（M.41）；批量 docs 动作前 fresh inventory（M.44）；commander stage 用显式 pathspec、amend 前核 HEAD（M.45）。
- **优先级仲裁**：Line B > Line A > Line C（弹药类并行不占关键路径）；S7c PASS 触发全员让路 S8 链。

## 六、待磊哥键（现值，全部条件式/低频）

| 键 | 触发时机 |
|---|---|
| S4 开跑令 | 本 roadmap 过目后（S3-FINAL 已定稿，hermes+codex 编排已备） |
| 关重 GUI（host resample） | S7 门链绿后、S8 点火前 |
| C2 扩挂载批 | Line B S10 verdict 出来 + Line C 立项 grill 收口后 |
| A4/A5 各刀点头 | 各自方案呈报时 |
| Q18 分支 | 仅 S10 失败分类触发（D-114） |

## 七、指针（本文件是调度层，细节回各 SSOT）

- Line B：`runs/2026-07-07-w20a-grill-closeout/register-window/{IMPL-PLAN-v3.md, S3-GENERATION-SPEC-draft.md(S3-FINAL), S7-HOST-READINESS-CHECK.md, s4-dispatch-template(run dir out/)}`
- Line A：`docs/research/2026-07-07-streamline-review/{README.md, reduction-table.md, architecture-roadmap.md, macos-lane-readiness.md}`
- Line C：`runs/2026-07-07-ma-opt-refactor/out/task3-capability-iceberg-teardown.md`（弹药）
- 决策链：`docs/commander-log/decisions.md` D-114/D-115/D-116；grill SSOT 与范式权威不变（CLAUDE.md §9 起手读链）

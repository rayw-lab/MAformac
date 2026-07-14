---
authority: baseline_roadmap（基线文档组成员；与 CLAUDE.md/OpenSpec specs/grill SSOT 冲突时让位并须回写）
status: ratified_pending_cascade（decision_status=RATIFIED 磊哥 2026-07-11 D-142；baseline_activation=PENDING_CASCADE——C-08 carrier disposition 与 O1/O2 落地后经 cascade receipt 翻 ACTIVE）
author: claude-commander (Fable5, ma14；磊哥令 2026-07-11「commander 亲笔 V6：GAP-HUNT 12 主题排 grill 日程 + 训练/接线/验收三线重排 + 进度分母重算 → 1 轮异源 sol xhigh 审」)
basis: opt/streamline-macos-20260707 @ ef5761b3 + GAP-HUNT（runs/2026-07-10-ma13/reports/GAP-HUNT-closure-themes.md）+ decisions D-133~D-141 + roadmap v5 全文
audit: runs/2026-07-11-ma14/reports/AUDIT-V6-by-w5.md（REQUEST_CHANGES P0=6/P1=8/P2=1；六 P0 全部 commander 亲核复放坐实后吸收；v6.0 sha256=4b91f8d2…）
supersedes: docs/roadmap-2026-07-07-macos-closure-baseline.md（v5）——RATIFIED 后生效并按 §六 级联清单回写；v5 的 Line B 执行细账与五门定义作为一手档继续被引用
retire_trigger: macOS app 全功能闭环达成，或磊哥重定路线
---

# V6 基线：从「治理真金」到「客户路径真接通」（2026-07-11，v6.1）

> **北极星（不变）**：客户现场 5 分钟内——听懂中文、反应快、不崩、看着惊艳、断网也能跑（CLAUDE.md §1）。
> **V6 的一句话**：PR #42 合入的是治理层真金（诚实矩阵 actionDemoProven=0/120，D-137 `docs/commander-log/decisions.md:1230-1237` + fail-closed 门族 + typed authority），**不是 demo**；下一阶段 = 把「治理正确的空壳」接成「客户真能摸的路径」，并让每个「能演」声称都有量尺 authority 和 ceremony 背书。
> **v6.1 对 v6.0 的修正核**（审计裁决全收）：v6.0 把「合同 ready」压成「READY 可立即执行」= 用自己要消灭的机制造新假绿。v6.1 拆三轴状态（decision/execution/proof），工作包重切 25→29，硬前置补三条逆边，门命令改绑实存 make target，并新立 O 控制面承载制度物。

## 〇、V6 对 v5 的三个修正（为什么开笔）

1. **进度分母失真**：「Line D 呈现层 72%」是内部完成度被误读为闭环进度。机理（审计升维吸收）：v5 把 **artifact maturity（文档/代码存在）/ execution readiness（前置齐）/ proof status（哪层 proof fresh 绿）三个维度压成一个成熟度词**——不拆轴，同一失真换皮复发（v6.0 的 READY=7 即复发实证）。v6.1 起三轴分列。
2. **四线按「供给方」切掩盖横切洞**：客户路径断链（T04：App 无文本输入、runner 零接线、MicDock mock preset）在 A/B/C/D 里没有 owner。
3. **「代码跑在 authority 前面」无专管**：C6 三层错位、force-state 双 registry、operator-pass 无 ceremony——需验收链专管。

→ **三链 + O 控制面**：训练链（大脑）/ 接线链（客户路径）/ 验收链（量尺与 ceremony）为 **owner/视图**；调度真相是 §一 的 typed 工作包表（未来由 O2 checker 机械生成）；五门是 receipt 投影。三链不是第二 SSOT（审计 steelman 裁决：三链优于 v5 四线/二链/五链切法，但必须配 typed 工作包 + O 控制面才不复发假绿）。

## 一、进度分母重算（29 个工作包，三轴状态）

**分母定义**：closure = 五门全绿（§四）+ operator-pass ceremony 实际执行。每包绑验收物；**状态三轴** = decision_state（draft/ratified）× execution_state（READY_NOW / READY_AFTER_<前置> / PLAN / GAP / BLOCKED）× proof_state（none→local→…→operator，禁越级）。表内「状态」列 = execution_state 精确词，**禁把 `READY_AFTER_*` 截短成 READY**（审计 P0-01）。

> historical source view; superseded by O1 generated table。下列三张手写表保留业务说明与来源锚，但其状态值已校准为 O1 canonical execution state；机械消费只认本节末 `O1:GENERATED` 的 29 行表。

### 训练链（8 包）
| # | 包 | execution_state | 验收物锚 |
|---|---|---|---|
| B1a | S8 1800 训练执行（legacy 点火 authority） | **BLOCKED**（B1b DONE + human key 未齐） | preflight `READY_TO_IGNITE` rc0（s8-preflight-check.sh 实测）——待磊哥窗口令 |
| B1b | S8 G1 closure receipt 链（nonce/prelaunch inventory/completion seal） | **PLANNED**（代码已 merge，不等于 closure package DONE） | `runs/2026-07-10-ma13/reports/S8-IGNITION-READINESS-REFRESH.md:4` 总态 PARTIAL：launcher 点火窗接线未执行。⭐点火前完成，否则 9-11h 产物无法被 B6/V8 诚实消费 |
| B2 | S9 三臂 eval | **BLOCKED**（S8 + B7/T02 freeze 未齐） | holdout FROZEN 61 行四桶 33/9/10/9，sha256 `77853cae…`（D-127 `docs/commander-log/decisions.md:1146`）；🔴 新前置=B7 的 T02 digest/exposure freeze 先于 S9（审计 P1-02） |
| B3 | S9b + S10 verdict | PLAN | 模板+四类分流 D-114 预拍；🔴 前置=T01/T02 RATIFIED（§二） |
| B4 | S11 renderer ack | PLAN | v5 §一 序 |
| B5 | C2 扩挂载（三档表零临场） | PLAN | gate=S10 verdict |
| B6 | 翻绿 promotion transaction（去重后独占部分） | PLAN | greening v3-DRAFT 的 G1-G8 与 B1/B2/W1-W3/V8 重叠（审计 P1-01）——B6 只保留 promotion 独占事务，G8 join 归 V8 |
| B7 | T02 corpus/regen/denominator 收敛 | RATIFIED_PENDING_PLAN（D-147 全闭；freeze→S9 执行序硬边不变） | Wave G2；含 release corpus freeze（前移到 S9 前） |

### 接线链（13 包）
| # | 包 | execution_state | 验收物锚 |
|---|---|---|---|
| W1 | int-v5a：matrix rename（canDemo→actionDemoProven）+ canonical contract bundle/default runner（App diff-free） | **DONE**（merge ba2c3636，D-145） | 审计链=XAUDIT→修复→RECHECK 全 FIXED+commander 三件套亲跑 784/6/0 |
| W2 | int-v5b：containment 半已收编（merge，LEIGE-WAIVER-V5B-ABI-1 残留=ABI proof 授权窗补证）；façade/composition 剩余面可派（T03/T04 已闭） | `SPEC-v5b:4-8` status=READY_FOR_POST_V5A_DISPATCH；🔴 其中 **customer façade/default composition 部分另需 T03/T04 interface cut RATIFIED**（审计 P1-03——防 customer code 再跑在 authority 前）；不依赖 T04 的 deny-first containment 部分可随 v5a 后先行 |
| W3 | int-v5c：witness + probe catalog | READY_AFTER_V5A_V5B | `SPEC-v5c:4-8`（要 v5b authenticated receipt） |
| W4 | int-v5d：reliability（p95≤800ms/20-turn/300s soak） | READY_AFTER_V5ABC | `SPEC-v5d:4-8` READY_AFTER_EXACT_PREDECESSORS |
| W5a | T04a ingress façade（text 输入/统一 ingress 语义/校验） | RATIFIED_PENDING_PLAN（D-143） | Wave G1；T04 弹药 Q1-Q4 |
| W5b | local model artifact/load readiness（MLX/Qwen 供给+预热） | RATIFIED_PENDING_PLAN（D-143） | Wave G1；仓内无 MLX runtime 依赖（GAP-HUNT T04 段）；artifact identity 与 T06 咬合 |
| W5c | T04b production composition root（唯一装配点/default backend） | RATIFIED_PENDING_PLAN（D-143；硬边 T03✅+T09⏳ 未齐禁实装） | Wave G1 grill + 🔴 前置=T03+T09 contract cut（审计 P1-02：production composition 只能消费 route/lifecycle 边界） |
| W5d | decode policy（multi-call fail-closed/metadata-aware parser） | RATIFIED_PENDING_PLAN（D-143） | Wave G1；exactly-one authority=`openspec/specs/tool-execution/spec.md:18-24` |
| W6 | T03 C4 路由 active spec + L1-L5 本体 | RATIFIED_PENDING_PLAN（D-143） | Wave G1 |
| W7 | T10 DialogueState 消费语义 | RATIFIED_PENDING_PLAN（D-150；exact-nine 5 个 design atoms 仅解锁 draft expansion） | Wave G3 |
| W8 | T09 session lifecycle/cancel/recovery | RATIFIED_PENDING_PLAN（D-150/D-152；W8/T09 是 W5c/T04b 的前置；W8 自身不依赖 W5c DONE） | Wave G3 |
| W9 | T08 force-state 单一 authority | RATIFIED_PENDING_PLAN（D-150；force-state authority 切换尚未执行） | Wave G3 |
| W10 | T05 语音分层：**hard=TTS 门收敛**（stretch ASR 面不进 hard 分母） | RATIFIED_PENDING_PLAN（D-147） | Wave G4；D14 选型不重拍 |

### 验收链（8 包）
| # | 包 | execution_state | 验收物锚 |
|---|---|---|---|
| V1 | T01 C6 量尺 authority 归并/阈值/promotion | RATIFIED_PENDING_PLAN（D-147 全闭；S10 拍板面硬边解除） | Wave G2；🔴 S10 verdict 签署前必须 RATIFIED |
| V2 | T07 operator-pass ceremony（T07a ceremony contract / T07b final operator run） | RATIFIED_PENDING_PLAN（D-150；T07a/T07b 执行尚未开始） | Wave G3；🔴 T07b 前置=T06 artifact/build identity（审计 P1-02） |
| V3 | T11 性能门归属（PF1 + int-v5d receipt 进 closure verdict） | RATIFIED_PENDING_PLAN（D-147） | Wave G4 |
| V4 | T06 S6 Mac 打包边界（audience/artifact/签名公证 in-out） | RATIFIED_PENDING_PLAN（D-147） | Wave G4；U43 internal-only 已锁 |
| V5 | T12 Line A 分母 accounting（**不进 hard 分母**） | RATIFIED_PENDING_PLAN（D-147；A5 各项仍逐项磊哥点头） | Wave G5 |
| V6p | M-DEMO golden run 实装 | PLAN | 预备包 `PARTIAL/PREPARED`：**16 scenario rows，其中 12 catalog-backed rows 过 source-literal 核验**；checker 未实现、`implementation_authorized=false`（`runs/2026-07-10-ma13/reports/MDEMO-golden-run-impl-pack.md:3-16` + `runs/2026-07-10-ma13/reports/golden-run.v1.yaml:3-8`；审计 P0-03 修正 v6.0 错值「16 rows PASS」） |
| V7 | A2 evidence package（check-macos-demo-evidence.py + capture） | PLAN | 脚本尚不存在（GAP-HUNT T12 段坐实） |
| V8 | closure verdict join（五门 receipt 机械汇签，same-subject join） | GAP | 制度物=O4 schema；join key（repo_head/build/model/contract/corpus/scorer）任一不同或缺失=BLOCKED（审计 P1-04） |

### 进度 verdict（可复算口径）
- canonical 状态和计数只读下方 `O1:GENERATED` marker block；本手写段不复制数字。生成源为 `contracts/closure-work-packages.v1.yaml`，由 `scripts/check_closure_work_packages.py` 物化并经 `make verify-closure-work-packages` 校验。上方业务说明表仅供历史语境，不参与机械消费。
- **hard closure 分母 = 28**（29 − V5 accounting；W10 计 hard 但只含 TTS 门收敛面，stretch ASR 不进硬门）。
- **地基（不进闭环分母，是已交付资产）**：治理层（PR #42 MERGED）/ Line D 呈现层（swift test 783/7/0，D-141 `docs/commander-log/decisions.md:1285`——dated local 证据，非 operator-pass）/ 训练准备 / 计划层 / branch protection / A1+A3 ancestry。
- **叙事口径校准**：本账是「remaining closure backlog 状态」，不是「总工程完成度」；「~50%」粗账仅口头参照。分母变更（增删/重切包）须走本文件修订 + D 条 + O3 transition receipt，禁静默换分母。

<!-- O1:GENERATED:START registry_sha256=e4875b0b958e8fa99909be481c3a898d8200436c803e8bf327e2798955da2f8b checker_sha256=aaa53bf7a1910c871b64d1df8facf07ca4d7a4028e16452b0d49256f974f0165 -->
| O1 checker field | derived value |
|---|---:|
| packages | 29 |
| hard leaf denominator | 28 |
| execution | done=4; ready=0; blocked=4; planned=20; gap=1; running=0; paused=0 |
| count token | `O1COUNTv1{registry=e4875b0b958e8fa99909be481c3a898d8200436c803e8bf327e2798955da2f8b;packages=29;hard=28;done=4;ready=0;blocked=4;planned=20;gap=1;running=0;paused=0}` |

| package | decision_state | execution_state | proof_state |
|---|---|---|---|
| B1a | ratified | blocked | partial |
| B1b | ratified | done | satisfied |
| B2 | ratified | blocked | partial |
| B3 | draft | planned | none |
| B4 | draft | planned | none |
| B5 | draft | planned | none |
| B6 | draft | planned | none |
| B7 | ratified | planned | none |
| W1 | ratified | done | satisfied |
| W2 | ratified | planned | partial |
| W3 | ratified | blocked | none |
| W4 | ratified | blocked | none |
| W5a | ratified | done | satisfied |
| W5b | ratified | planned | none |
| W5c | ratified | planned | none |
| W5d | ratified | done | satisfied |
| W6 | ratified | planned | none |
| W7 | ratified | planned | none |
| W8 | ratified | planned | none |
| W9 | ratified | planned | none |
| W10 | ratified | planned | none |
| V1 | ratified | planned | none |
| V2 | ratified | planned | none |
| V3 | ratified | planned | none |
| V4 | ratified | planned | none |
| V5 | ratified | planned | none |
| V6p | draft | planned | partial |
| V7 | draft | planned | none |
| V8 | draft | gap | none |
<!-- O1:GENERATED:END -->

## 二、三链重排（谁供给谁 + 硬前置；本节是视图，真相=§一 表）

```
训练链  B1b(G1 receipt) → B1a S8 ──→ B2 S9 ──→ B3 S10 verdict ──→ B4 S11 ──→ B5 C2/B6 promotion
                              ▲            ▲                          │adapter
验收链  V1/B7(T01/T02) RATIFIED┤            └──B7 T02 corpus freeze 先于 S9
接线链  W1 v5a ──→ W2 v5b(containment 先行；customer façade 等 T03/T04 cut) ──→ W3/W4
        W6 T03 + W8 T09 ──contract cut──→ W5c T04b composition ──→ 慢路 backend 接线(gate=S10)
验收链  V4 T06 artifact identity ──→ V2 T07b final ceremony；V8 = 五门 receipt same-subject join
closure = 五门全绿 + operator-pass ceremony 执行
```

三条硬边（v6.1 新增，审计 P1-02 吸收）：**① B7 T02 freeze → B2 S9**（release corpus digest/exposure 先冻结再 eval）；**② W6 T03 + W8 T09 → W5c T04b**（production composition 消费 route/lifecycle 边界，T04a ingress containment 不受此限）；**③ V4 T06 → V2 T07b**（最终 ceremony 绑 exact build/artifact identity；T07a ceremony contract 可先行）。原有硬前置不变：T01/T02 RATIFIED → S10 签署；S8 active 禁 full build（资源互斥由 O6 execution-window 机械化，不再靠 prose——审计 P1-07）。

## 三、GAP-HUNT 12 主题 grill 日程（wave 制）

每波流程 = 骨架弹药 → GRILL-INDEX 合成 → 对抗审 INDEX → BALLOT（磊哥一次拍）→ RATIFIED 级联（decisions + §一 状态翻转 + O3 receipt）→ 消减矩阵 → 实施计划（inline 已决+file:line）→ 对抗审计划 → 编码（宪法 §21/§22 范式链）。

| Wave | 主题 | 链 | 触发条件 | 弹药态（2026-07-11 夜） |
|---|---|---|---|---|
| **G1** | **T04**（XL）+ **T03**（L） | 接线 | 立即 | **AMMO_READY**（T04 v2 修订中/T03 v2 已修，均经交叉对抗审） |
| **G2** | **T01** + **T02** | 验收+训练 | G1 BALLOT 后；🔴 硬 deadline：T02 freeze 先于 S9、T01/T02 RATIFIED 先于 S10 签署 | **AMMO_READY**（v2 已修，经交叉审） |
| **G3** | **T07+T08+T09+T10** | 验收+接线 | G2 后 | **AMMO_READY**（待交叉审） |
| **G4** | **T06+T05+T11** | 验收+接线 | G3 后或与 G3 尾并行 | **AMMO_READY**（待交叉审） |
| **G5** | **T12**（P1） | 验收 | 收口 accounting，不挡 runtime P0 | 在产 |
- 弹药已产 raw 议题（G1+G2 现值 56+，全 12 主题弹药今夜齐）；**raw Q 数 ≠ 最终决策晶体数**，晶体数与总时长待各波 reduction 后再报（审计 P2-01：不从异质产能样本外推硬时长；ma13 单日 24 ballot+39 消减仅作参照）。
- **不重拍清单（GAP-HUNT §3 继承，inline 进各波 SPEC）**：PR #42 predecessor / int-v5a-d EXECUTABLE / M-DEMO 5 题 / L1-L8+C1-C11（CG-080 不扩 mounted）/ D0 43+D1 规格 / A1/A3 / T6R/D1HR capture / D14 / U43 / U14/U16。
- **grill 纪律**：每题先 recall 已决；每波 BALLOT 前对抗审 INDEX；RATIFIED 即级联不攒。

## 四、五门验收定义（继承 v5 §四 + v6.1 修订）

全功能闭环 = 五门全绿 + operator-pass ceremony。每门绑**实存**验收命令/receipt，禁 prose：

1. **模型门**：S10 verdict receipt + `make verify-c5-phase1-gates` rc0 + qa safety receipt——量尺引用必须指向 T01 归并后的 active C6 authority。
2. **能力面门**：`make verify-c1-matrix` + `make verify-c1-matrix-canonical`（`Makefile:81-99` 实存 target；v6.0 所引 `scripts/check_capability_matrix.py` 不存在——审计 P0-05 修正，实际 checker 在 `Tools/checks/` 由 make 链消费）+ actionDemoProven 翻绿只认 action-readback 证明（D-137 两轴）。
3. **架构门**：`make verify-all` rc0 + `make verify-register` rc0 + swift test 全量 0 failures + T12 分诊后的 A 面账。
4. **演示门**：golden-run 脚本 exit 0（V6p 实装后转可记态）+ A2 evidence validator（V7）+ operator-pass ceremony receipt（T07 拍后）。
5. **诚实门**：强词 grep 0 命中 + candidate unsigned 直到证据齐 + 进度声称只认 §一 细账口径。
- **五门汇签 = V8 same-subject join**（O4 schema）：五个 receipt 的 repo_head/build/model/contract/corpus/scorer 任一 subject 不一致或 proof cap 不足 = BLOCKED，禁路径存在性通过。

## 五、O 控制面（orchestration/governance，不进产品分母；审计制度物 I-1~I-6 全收）

| # | 制度物 | 内容 | 时序 |
|---|---|---|---|
| O1 | `contracts/closure-work-packages.v1.yaml` | §一 29 包迁 typed DAG（id/kind/scope_class/chain_view/三轴状态/prerequisites/exit_receipt/check_command/proof_cap/resource_locks） | V6 RATIFY 后第一批（schema 本身属磊哥拍板面） |
| O2 | `scripts/check_closure_work_packages.py` | fail-closed：DAG 无环/READY 需 predecessor receipts fresh 绿/DONE 需 receipt 实存+digest 对齐/同 receipt 禁多包计数/资源锁冲突拒 READY/**计数只能由 checker 生成禁手写** | 同上；落地后 §一 表由它生成 |
| O3 | `closure-status-transition-receipt.v1.json` | 每次状态翻转记 package_id/from/to/trigger_decision/digest/repo_head/rc/reviewer；PREPARED 不得直达 READY，local-pass 不得直达 operator-pass | 同上 |
| O4 | `closure-verdict.v1.json` | V8 的 join schema（§四 汇签） | V8 前 |
| O5 | V6 RATIFY 级联义务清单 | decisions D 条/BALLOT-INDEX/v5 supersede banner/CLAUDE.md §9/CURRENT.md/docs README/OpenSpec carriers/handoff/MEMORY as-of——逐项 owner+动作+验证命令；缺一不得翻 READY（草稿=`runs/2026-07-11-ma14/reports/DESIGN-v6-cascade-inventory.md` 在产） | RATIFY 时执行 |
| O6 | `execution-window.v1.yaml` | S8/full-build 资源互斥机械化：resource_class/holder/pause_targets/failure_class/restart_policy；点火将冲突包机械翻 PAUSED_RESOURCE_HOLD | S8 点火前 |

**commander 裁决 delta（对审计「最小吸收门」第 2 条）**：审计要求呈磊哥前即迁 typed DAG + checker 生成计数；v6.1 选择——**本文件 §一 为最后一次手写账（经本轮审计+commander 逐数复核），O1/O2 schema 作为 V6-NEW 决策随本文呈磊哥拍，拍后立即实装并接管状态生成**。理由：registry schema 本身是治理设计决策，先斩后奏违反 agree-before-build；风险由「手写账仅此一次+翻转必带 O3 receipt」封顶。residual 如实记：O2 落地前的状态翻转仍是人工纪律。

## 六、待磊哥键

| 键 | 时机 |
|---|---|
| 🔴 **S8 点火令** | 晚间窗口。⭐建议先落 B1b G1 receipt 兼容小补丁（草稿在）再点火，使训练产物可被 closure 链诚实消费；若你选立即点火，按 legacy authority 有效，B1b 事后补、closure join 相应延后。**磊哥 2026-07-11「S8不着急」——键挂起不催** |
| ✅ **V6 本文件 RATIFY**（含 V6-NEW 决策清单 §七 + O1/O2 schema 方向） | **已拍**：磊哥 2026-07-11「V6 RATIFY agree」；`decision_status=RATIFIED`；`baseline_activation=PENDING_CASCADE`。 |
| G1-G5 各波 BALLOT | 每波一次打字拍 |
| int-v5a（W1）开工确认 | 唯一 READY_NOW 实施包；默认 V6 拍后即流水 |
| A4/A5 各刀点头 | T12 分诊呈报时 |

## 七、V6-NEW 决策清单（本文件新增的治理裁决，RATIFY 时逐条落 D 条——审计 P1-08 吸收，v6.0「不改变任何已拍决策」措辞作废）

- V6-N1 三链视图 + typed 工作包为调度 SSOT（三链/五门均非第二 SSOT）
- V6-N2 29 包 closure 分母 + hard 分母 28 + 三轴状态制 + 手写账仅此一次
- V6-N3 三条硬边：T02 freeze→S9；T03+T09→T04b；T06→T07b（原有 T01/T02→S10 保持）
- V6-N4 wave 制 grill 日程 G1-G5 与每波级联义务
- V6-N5 V8 closure verdict same-subject join（禁 prose join）
- V6-N6 O 控制面 O1-O6 制度物 + 「计数由 checker 生成禁手写」原则
- V6-N7 int-v5 序修正：v5a 先行；v5b customer façade/default composition 等 T03/T04 interface cut

## 八、Non-claims

- actionDemoProven=**0/120** 不变；S8 未点火（磊哥 2026-07-11「不着急」挂起）；S9/S9b/S10/S11 未执行；int-v5a 已开工编码**未合入**、v5b-d 未开工；M-DEMO golden run 未实装（PREPARED_DRAFT）；无 operator-pass / desktop_operator_equivalent / V-PASS / C6 acceptance / candidate signed。
- GAP 态 16 包在对应 wave RATIFIED 前无实施授权；CG-080 禁 mounted 1→N 不变。
- 本文件**不推翻**任何已拍决策；其**新增**治理裁决见 §七 清单（已随 D-142 RATIFIED 落条）。
- v5 已挂 supersede banner 转 historical（D-142）；本文件 `baseline_activation=PENDING_CASCADE`，ACTIVE 前 C-08/O1/O2 义务未齐；GAP-HUNT proof boundary 继承。
- 弹药（AMMO-*）是 grill draft 非 RATIFIED authority；本文引用其依赖发现不预拍其⭐推荐。

## 九、指针

- V6 素材 SSOT：`runs/2026-07-10-ma13/reports/GAP-HUNT-closure-themes.md`；审计一手：`runs/2026-07-11-ma14/reports/AUDIT-V6-by-w5.md`
- 训练链细账：roadmap v5 §一 + `runs/2026-07-08-daywork/`（S8 preflight）+ `runs/2026-07-10-ma13/reports/S8-IGNITION-READINESS-REFRESH.md`（B1a/B1b 拆分一手）+ D-127
- 接线链合同：`runs/2026-07-10-ma13/specs/SPEC-v5{a,b,c,d}-implementation-dispatch.md` + INTERFACE-LOCK 9 条（D-140）
- 验收链现物：M-DEMO 预备包（PARTIAL/PREPARED）+ MG-6 proof 词典 = `docs/commander-log/decisions.md:1112-1118`（:1116，D-123；v6.0 误指 grill-decisions-master——审计 P0-06 修正）+ PR #42 门族（merge f5ef6270）
- 决策链：`docs/commander-log/decisions.md` D-133~D-141；grill 总 SSOT 与范式权威不变（CLAUDE.md §9 起手读链）
- ma14 run dir：`runs/2026-07-11-ma14/`（弹药 12 主题 + 交叉审 + 本审计 + 级联清单草稿）

---
status: active_router_only_not_ssot
artifact_kind: current_route_board
authority: router_only_not_contract
updated: 2026-07-11（D-142~D-145；V6 RATIFIED、G1 全闭、G2/G4/G5 部分裁决、W1 DONE；本轮 live 核验）
last_verified_head: 94dcc334e767cf82d7b57a795ec61c7d818cce3c（live git 亲跑；head_truth_rule 以 live git 为准）
branch: opt/streamline-macos-20260707
head_truth_rule: "Run git rev-parse HEAD and git rev-parse @{u}; this route board records verification inputs and loses to live repo state."
expires_when: "32 题呈拍 disposition、v5b ABI-proof 窗结果、S8 点火状态、或 G3/O 控制面任一状态翻转时刷新"
---

# CURRENT — MAformac 当前路由牌

> 本文件是交通牌不是事实源。与 `CLAUDE.md`、grill SSOT、签字证据、live repo 冲突时本文件让位并须更新。
> 前版（D25 K1 spike-ledger 路由，updated 2026-06-30）已被本版 supersede：D25 之后项目经历了 C5 训练就绪 grill（442+ 决策）→ 5-gate construction（PR #9/#10/#11 merge）→ overnight wave-1（gate8/gate2/grill 补深），路线对象已从「D25 K1 receipts」变为「pre-LoRA 训练前节点」。D25 K1 的 8 行 receipt 工作若仍需要，见 baseline-roadmap §2 节点 M3（磊哥单独拍）。

## 当前阶段（2026-07-11：**D-142~D-145 后态——V6 RATIFIED/PENDING_CASCADE；G1 全闭；G2/G4/G5 部分裁决；W1 DONE；32 题待磊哥呈拍**）

🔴 **本节 supersede 下方所有历史态段（含紧随其后的旧「V6 RATIFIED（D-142）」段）**。推进事实源=`docs/commander-log/decisions.md` D-142~D-145 + `docs/roadmap-2026-07-11-v6-closure-baseline.md` §一 + `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-11-ma14/`；本文件仍是 router-only，不替代 decisions、roadmap、OpenSpec 或 run-dir receipts。

- **V6 / W1**：V6 `decision_status=RATIFIED`、`baseline_activation=PENDING_CASCADE`；W1 int-v5a=`DONE`（merge `ba2c3636`），B1b receipt-chain 已 merge `a3160c88`，过渡性进度为 `DONE=1/29`、hard closure 分母仍 28（D-145 `docs/commander-log/decisions.md:1325-1330`；V6 §一 `docs/roadmap-2026-07-11-v6-closure-baseline.md:44,70-74`；双账 `runs/2026-07-11-ma14/reports/BALLOT-INDEX-v6.md:153-163`）。
- **波次裁决**：D-143 的 G1=56 atoms 全闭（41 auto + 5已拍B + 10 carry）；D-144 的 G2=`PARTIALLY_RATIFIED`（50 auto + 3 counted C1 已拍，12 parent + `G2-038-C1` 仍未拍，S10 硬边未解除）；D-145 仅完成 G4/G5 白名单代拍，19 个 escalate 仍待呈（D-143~D-145 `docs/commander-log/decisions.md:1311-1330`；双账 `runs/2026-07-11-ma14/reports/BALLOT-INDEX-v6.md:157-171`）。
- **32 题呈拍池**：G4/G5=19（14+5）+ `G2-038-C1` 重制版=1 + G2 parent authority=12；`G2-038-C1` 的⭐B是七 device family，且不继承 parent、不得自动票（晨报 `runs/2026-07-11-ma14/reports/DRAFT-morning-brief-ma14.md:14-22`；BALLOT `reports/BALLOT-INDEX-v6.md:165-170`）。
- **三把窗口键**：① v5b ABI-proof 系统授权窗口：containment 已就绪，customer façade/default composition 仍等 T03+T04 cut；② S8 点火：仍未点火，开窗前须 fresh preflight/host/进程/磁盘检查；③ `20+12` 呈拍：全按⭐后才可能解除 G2 的 T01/T02→S10 签署硬边（晨报 `runs/2026-07-11-ma14/reports/DRAFT-morning-brief-ma14.md:24-28`）。
- **在飞四单**：%5=G1 消减矩阵+T04/T03 实施计划 v1（W5c 继续守 T03+T09）；%2=G3 v3 修复链；%3=O1/O2 控制面实装；%1=三方数字一致性 sweep（晨报 `runs/2026-07-11-ma14/reports/DRAFT-morning-brief-ma14.md:30-35`）。
- **Non-claims**：G2 非全闭、G4/G5 非全闭、S10 未签；S8 未点火/未训练；无 runtime、operator-pass、C6 acceptance、candidate、mobile、true-device、live_api 或 V-PASS；`baseline_activation` 未 `ACTIVE`（D-145 `docs/commander-log/decisions.md:1327-1330`；晨报 `runs/2026-07-11-ma14/reports/DRAFT-morning-brief-ma14.md:37-41`）。


## 【历史】当前阶段（2026-07-11：**V6 RATIFIED（D-142）——三链+O 控制面基线生效（PENDING_CASCADE）；int-v5a 编码开工；G1/G2 BALLOT 备料中；S8 磊哥令不着急**；已被 D-143~D-145 后态 supersede）

🔴 **本节为 D-142 当时快照，不得作为当前路由或状态来源**。当时 `active_baseline_v6` 指针已切到 v6，但 G1/G2/G4/G5 后续裁决、W1 收编、B1b merge、FINAL-V41 与 32 题呈拍池尚未发生；以本文件顶部当前阶段和 D-143~D-145 为准。
- **V6 状态（历史）**：`decision_status=RATIFIED`；`baseline_activation=PENDING_CASCADE`；三链是 owner/view，O 是 orchestration/governance control plane，typed 工作包表是调度真相，未因 RATIFY 自动翻 `ACTIVE`（D-142；v6.1:23,120-127,139-147）。
- **执行态（历史）**：int-v5a 已开工编码但尚未合入；G1/G2 BALLOT 仍备料/待磊哥拍，G3-G5 按波次排队；当前只消费 run-dir 物料，不把弹药、INDEX 或审计 receipt写成 RATIFIED（本轮任务书 `SPEC-CASCADE-EXEC.md:9-13`；run-dir `reports/BALLOT-INDEX-v6.md`）。
- **S8（历史）**：磊哥 2026-07-11「S8不着急」，点火键挂起；不得写成 running/completed（D-142；v6.1:129-137）。
- **Non-claims（历史）**：`canDemo=0/120`；S8 未点火；int-v5a 已开工但未合入；无 operator-pass/V-PASS/C6 acceptance/candidate signed；`baseline_activation` 未 `ACTIVE`。

## 【历史】当前阶段（2026-07-11 凌晨：**🎉 PR #42 MERGED（f5ef6270）——C1 治理修复合入主线；GAP-HUNT 12 主题出稿，V6 基线待 commander 开笔**）

🔴 **本节 supersede 下方全部旧态段**。推进事实源 = decisions **D-133~D-141** + run dir `runs/2026-07-10-ma13/`（GAP-HUNT-closure-themes=V6 素材 SSOT + int-v5 四派单合同 + S8 READY 实证 + M-DEMO 实施包）+ handoff `2026-07-10-ma13-closeout`。
- **PR #42 MERGED**：七轮修复-审计链（AMENDMENT-1 行为门收敛）+ merge 前终极对抗审计（matrix checker fail-open P0 round7 修复 ALL_SCOPE_PASS）→ 磊哥授权 merge。合入=治理层真金（诚实矩阵 actionDemoProven=0/120 + fail-closed 门族 + typed authority）；**仍 NOT demo-ready**。
- **GAP-HUNT 12 主题（P0=10/P1=2）**：T04 客户 ingress/runtime 接线=硬门中的硬门（App 无文本输入+runner 零接线）；C6 三层错位/C4 路由无 active spec/operator-pass 无 ceremony/force-state 双 registry/session 恢复/DialogueState 只记账/S6 定义漂移/PF1 无门/Line A 分母。真实闭环进度 ~50%。
- **就绪待键**：S8 点火（READY_TO_IGNITE 实证）；int-v5a-d 编码（四合同 ready）；V6 基线（commander 亲笔，素材齐）。
- **Non-claims**：actionDemoProven=0/120；int-v5 编码未开工；S8 未点火；无 operator-pass/V-PASS/C6 acceptance。

## 【历史】2026-07-10：C1 int-v4 Draft PR #42 + ma13 修复轮/计划轨推进中（被 2026-07-11 段 supersede）

🔴 **本节 supersede 下方全部旧态段**（含同日「暂停待磊哥拍 BALLOT」稿）。推进事实源 = decisions **D-133~D-138（含 D-138 补记）** + run dir `~/Projects/agent-tmux-stack-research/runs/2026-07-10-ma12/`（C1 14 切片 + int-v4 链）与 `runs/2026-07-10-ma13/`（PR 审 + BALLOT + 修复轮 + int-v5 计划；STATUS-BOARD 为蜂群态）+ handoff `2026-07-10-ma12-c1-full-auto-dev-day.md` / `2026-07-10-ma13-first-wave-pause.md`（pause 态已被 D-138 补记 supersede，handoff 文件名可历史保留）。

- **C1 int-v4 = Draft PR #42**（`c1/int-v4-governance-repair`→opt/streamline，governance-repair candidate，🔴 NOT demo-ready；三厂商终审一致 governanceTruthful=true/customerDemoReady=false）；🔴 **actionDemoProven 诚实真值 = 0/120（D-137 supersede 旧 1/120）**，真执行能力=S8。
- **ma13 已越过 BALLOT 暂停点（D-138 补记）**：磊哥 **Q-1 + 细节 10 题全按星标**——路线 **B**=治理修复先合入 + demo 另立 int-v5 line；admission C 案 / mock rehearsal 隔离 / 非循环五件套 / typed sidecar / 可靠性两阶段 / p95 fast / memory baseline / int-v5a 一 PR 两 commit / `actionDemoProven` / witness int-v5 先行；**Q-12=B** branch protection 立即上（已执行）；**Q-13=⭐A** 单人仓+residual，不加 reviewer、不建外部 App。
- **branch protection 双分支已上线（D-138 补记）**：`opt/streamline-macos-20260707` + `main` = required check `verify`(strict) + 禁 force-push/deletion + `required_conversation_resolution`；commander 裁决 delta：`enforce_admins=false` + 不设 require-PR（保留 docs 直推日常流）；residual=admin 可绕 verify/可拆门；诚实等级=`GATE_BASELINE_HAS_TEETH`（非 `SAME_PR_UNSOFTENABLE`）。（D-138 正文预研「零 protection」仅作历史；现态以补记为准。）
- **修复轮已开工未合入（D-138 补记 + STATUS-BOARD）**：w2(%3) 领 **SPEC-fix-p01-p11**（P0-1 四点 + P1-1 扩扫 + probe 期望值级联；映射口径 **LOCKED 不扩 T0**）；修完 push PR 分支 → w1 按验收门复审。D-138 正文 w1 **REQUEST_CHANGES**（P0-1 finiteReason 生产分叉 + P1-1 ownership 不扫生产面）仍为修复对象；int-v4 转 Ready 前置 = 修复轮收口 + w1 复审 clean。
- **int-v5 计划轨并行（编码未开工）**：w3 吸收互审 5P1 产 int-v5a 实施计划 v2；w4 细化 witness 实施计划 + CODEOWNERS advisory 草案。**计划 ≠ 编码开工**。
- **下一动作（非 BALLOT）**：修复轮 push → w1 复审 → Ready → merge（磊哥键，路线 B）→ int-v5a/b/c 编码序；S8 点火键仍在途。
- **Non-claims（D-138 正文 + 补记 supersede 后口径）**：PR #42 / int-v4 **未 Ready / 未 merge**；**actionDemoProven=0/120 不变**；**修复轮已开工未合入**；**int-v5 编码未开工**（仅 w3/w4 实施计划轨 in-progress）；**无 operator-pass / V-PASS**；另沿用：无 C6 / candidate signed；S9/S10 未执行；CG-080 禁 mounted 1→N 不变。

## 【历史】2026-07-09深夜：D-132 全日收口——14 收编 656→731/0，Line D 一天全链上树（被 2026-07-10 段 supersede）

推进事实源 = roadmap v5 + decisions **D-114~D-132** + run dir `runs/2026-07-09-ma10-uiue-runtime/`（findings-ledger-ma10 + REPORTS-INDEX + reports/）+ handoff `2026-07-09-ma11-closeout-line-d-wave.md`。
- 终态：14 次收编全部三件门绿（swift test 731/0[6 skip]+verify-all+xcodebuild——门 suite 本日制度化为三件套）；两 demo 炸点修死；idle 采集 dry-run 包 ready（未实跑）；D1 左栏规格 v2 经审待磊哥⭐；三事故（主树切分支/自审自产/忘 commit×2）全当场闭环入账。
- 待磊哥键：idle 窗一键采集 → M-DEMO 5 题 ballot → D1 左栏专场令 → S8 点火 → push 授权（ahead 77）。C1 P0 38 题已由 D-133 全按 ⭐B RATIFIED；后续为消减矩阵→实施计划→对抗审→编码，CG-080 仍禁止 mounted 1→N（等 S10+A1+磊哥键）。
- Non-claims：无 operator-pass/V-PASS/C6/candidate signed；S9/S10 未执行；idle 采集未实跑；cross-vendor 异源审缺口待 hermes 额度回补。

## 【历史】2026-07-09夜：ma10 Wave 1 收编日——Line D 五席拉满，主干 656→690/0 三连收编

推进事实源 = roadmap v5 + decisions **D-114~D-131** + run dir `runs/2026-07-09-ma10-uiue-runtime/`（findings-ledger-ma10 + reports/）。

- **蜂群**：ma10 = 4 codex + 1 hermes（D-130 新规首战，零 claude worker）；hermes 一席四型活（异源审/生成/秘书/缺口扫描）。
- **任务④ Line D（本日主战）**：三连收编全绿——T7d 接缝（merge `8ed74010`，665/0）→ T3 hero（均匀 5 列→hero 左柱+3×3，merge `87e5b49d`，676/0）→ w2 runtime 叠层链（TTS fail-open+六类错误映射 T5 单源+DialogueState+TTS preflight 门，merge `d40d19c3`，**690/0**）。三场对抗审 P0=0。在途：T7e-B（ContentView call-site 清偿）/ D1HR（SSIM 基线对 hero 重生成）/ T6R（idle 截图包，隐私防呆内置）/ PF1（性能采样）/ RT2（mock 预设，弹药+施工预案备好等 T7e-B）。
- **任务②**：S8 r3 **未点火**（磊哥令不着急；点火三件仍备）；holdout FROZEN（D-127）不动。
- **任务③**：C1 ballot 38 题 + M-DEMO ballot 5 题备好待磊哥拍。
- **任务①**：Line A 无新动作（A3 曾有隔离执行，主树不扩 scope）。
- **新 stopline（D1H 裁决）**：自动化门禁依赖/写入 OS 全局 accessibility 态（`com.apple.universalaccess`）——非确定性设计错误 + 用户机可见副作用；一律进程内环境注入，OS 真开关走查=operator 手动 checklist。
- **非声明**：visual-swap 未切换（默认 off 等 5 Gate）；无 operator-pass/V-PASS/C6/candidate signed；S9/S10 未执行。

📌 **下一步**：T7e-B/D1HR/T6R/PF1 收编 → RT2 施工 → idle 窗（截图+5 Gate 亲核+visual-swap 切换验收）→ 磊哥两 ballot → S8 点火键。

## 【历史】2026-07-07晚：S4 生产相开跑；清理 6/6 收口；第二批 grill READY

🔴 **本节 supersede 下方 2026-07-07 register 补洞窗计划相旧态段**。本文件只作 router-only 指针；推进事实源以 roadmap v3、decisions D-114~D-118 和 run-dir board 为准。

- **roadmap v3 指针**：`docs/roadmap-2026-07-07-macos-closure-baseline.md` = 三线融合基线 v3（两轮审计毕）；决策入口 = `docs/commander-log/decisions.md` D-114~D-118。
- **任务①精简收口**：终审 GO，分支 `opt/streamline-macos-20260707`；物理清理 6 批完成，tracked -611；fullgate 597/0。
- **任务② register 窗**：S4 生产相已开跑；Q-03 三轮收敛；golden 62 行；run-auth 条件式 = S7c PASS 生效；五管道阵容运行，`%34` judge 待命。
- **任务③能力面**：能力面已立项；task3 teardown 真值为 `ir_map=562` / `mounted=1` / 120 格仅 1 格可演；BATCH1 19 题已拍，MG-7=C；第二批 grill READY。
- **非声明**：当前仍不得写 candidate signed、C5 V-PASS、C6 acceptance、mobile/true-device acceptance 或 UIUE/voice readiness。

📌 **下一步**：S4 首批样本生成与 judge 工艺验证；S7c 触发后才按 D-114 run-auth 条件式推进。

## 【历史】2026-07-07：register 补洞窗计划相 v3 定稿；PR #39/#40 均已 MERGED 进 main

🔴 **本节 supersede 下方 D-111 honest-frozen-closeout 旧态段**。本文件只作 router-only 指针，不复制 register grill 20 条正文；裁决全文、消费清单和计划以 run-dir SSOT 为准。

- **PR 真态（live-verified via `gh pr view`）**：PR #39 `MERGED`（merge commit `3744d9da`）；PR #40 `MERGED`（W20A 8 stage 收口 + D-112/D-113 + register S0/S1 scanner v3，merge commit `b2a25da7`）。W20A 仍只证明 `runtime_path_reachable`，不签 candidate、不升格 V-PASS/C6 acceptance/mobile/true-device。
- **register grill 20/20 全拍**：SSOT=`runs/2026-07-07-w20a-grill-closeout/register-window/grill-20/PARADIGM-LEDGER.md`；一页消费清单=`runs/2026-07-07-w20a-grill-closeout/register-window/grill-20/FINAL-LIST.md`。口径：Q13 golden boundary、Q16 机械前置+阈值、Q19 A supersede 均已拍；不把 20 条正文搬进 `CURRENT.md`。
- **实施计划 v3 定稿**：计划=`runs/2026-07-07-w20a-grill-closeout/register-window/IMPL-PLAN-v3.md`，status=`XFRAME_ABSORBED_PENDING_RUNAUTH`；S7c `learnability micro-probe` 已由磊哥 3B 拍为必跑前置，不再作为 run-auth 可选项。
- **决策指针**：D-112 / D-113 见 `docs/commander-log/decisions.md`。注意 D-113 是指针式落库：goal 层 supersede，data/candidate 层仍 `PENDING_GATES`，旧 tail1200/R3-QNEG-clean basis 在新门全绿前仍是回退承重墙。
- **交接指针**：`docs/commander-log/COMMANDER-HANDOVER-2026-07-07.md`。

📌 **下一步**：S2 golden boundary 已拍补录完（golden 50 全绿 rows=50 pairs=10 boundary=10，Python runner 口径）；S3 生成 SPEC 可备稿。🔴 **D-114（2026-07-07 下午磊哥四拍，见 decisions.md）**：① run-auth **条件式预授权**——S7c learnability micro-probe PASS 即生效，无需再拍 ② Q18 现在不拍，S10 触发后按失败类型分流 ③ tail1200/R3-QNEG-clean 承重墙默认保持，S10 全绿才 data supersede；S10 不绿四类分流（runtime qa fail→修 guard/harness / coverage debt→新 data repair / coverage 足但 action-question 仍 fail→judge causal bet falsified / holdout 塌→话术收窄或新窗口，**waiver 通道对 holdout 关闭**）④ host HOLD ⭐关重 GUI fresh resample PASS，**不默认 waiver-key**（污染归因），时间窗口极硬才例外。S8 点火五布尔=S7c PASS(=run-auth 生效) + host fresh resample PASS + W20A mechanical green receipt + S7b causal-bet receipt + IMPL-PLAN v3 gates；缺任一保持 `BLOCKED/PARTIAL`，不得写 candidate signed、C5 V-PASS、C6 acceptance 或 mobile/true-device acceptance。

## 当前阶段（2026-07-06：**C5 收尾定调 A = honest-frozen-closeout（D-111 磊哥拍）**；不重训 1800；candidate unsigned）

🔴 **本节 supersede 下方 tail1200 live-training-monitor 态**（那是 D-111 之前「continue evidence run」路线；tail1200 iter600 现被 D-111 定为**冻结对象**，非无限续跑）。

- **定调=A honest-frozen-closeout（decisions.md D-111，:847-859）**：① 冻结 tail1200 iter600 **unsigned** artifact（tail1200 收尾 demo-ready；`formal 1800` 待 run-auth 作磊哥保留 goal 并行、1800 不大动=不重训别配方/不大改 recipe）② runtime 接线 W20A 让 demo direct-value 可演（R1-correct：`<tool_call>`parser + `ToolContractNormalizer.normalize`(562, `ir_map` ⭐C 编译常量) + 新增 `IR→ToolCallFrame` 桥 → `C3ExecutionPipeline`；**不走 `decode:306`**，名字守护落 normalizer irMap 白名单 miss→reject）③ Lane2 slot 白名单投影防 arguments 幻觉 ④ 三缺陷（EXP 反向 / arguments 幻觉 / action-question under-action）显式 DEFER ledger ⑤ 机械防假绿门（`RuntimeAdapterMountReceipt.validate()` 硬编码 unsigned + grep 0 命中 V-PASS/signed）。
- 🔴 **qa vs action-question 两面分诊**（此前混淆，D-111 reconcile）：
  - **qa（over-actuation）** = D-106 三轮 **9/9/9** 模型固有 actuation prior 硬墙 → **D-108 B runtime-gated 已 waive**。
  - **action-question（under-action）** = **14/18**，根因 trainpack「能不能」register 0 覆盖（W15）；**D-108 B 不覆盖** → **本轮 DEFER**。
- 🔴 **诚实分叉**：runtime 接线让「调到26度」在 app 生效 **≠ C5 training V-PASS**（接线不改 14/18）；不重训补 register。
- **grill SSOT**：`runs/2026-07-06-c5-runtime-mainpath-grill/`（GRILL-README + lane-1~4 + reduction + impl-plan + superaudit）。

📌 **当前路线（双轨并行）**：**主活 = honest-frozen-closeout** —— 冻结 tail1200 unsigned artifact → runtime 接线 W20A（R1-correct，demo direct-value 可演，superaudit CONDITIONAL_GO 91/100 已过，实装需 run-auth）→ DEFER ledger（三缺陷）→ 机械防假绿门；**并行 = formal 1800 待 run-auth**（磊哥保留 goal，1800 不大动=不重训别配方/不大改 recipe）。**不强求 V-PASS、candidate 保持 unsigned**。
> non-claims：not candidate signoff / not V-PASS / not C6 acceptance / not runtime 已实装（W20A 未写码）/ not formal 结果达标（formal 1800 尚未跑/未 run-auth）；`adapter_learned_qa=false`。

## 【收尾对象·historical live 态】当前阶段（2026-07-06 早：**tail1200 full-envelope/no-auto-watchdog live；非 true resume；candidate 仍 unsigned**）

🔴 **Formal lane 最新真态（本节 supersede 下方 2026-07-05 host-HOLD/not-launched 旧态与 L-BF/L-BJ 15GB 旧约束）**：
- **资源 authority 已换挡**：`15GB` 训练 lane 旧约束已被磊哥最新 full-envelope/no-auto-watchdog authority supersede；watchdog 不做 auto-interrupt，冻结/手动关 app 风险由用户接受。secretary 只记录状态，不提供 launch authority。
- **旧 formal 234208 是历史 HOLD**：`formal-run-20260705T234208+0800` 以 `FORMAL_TRAIN_HOLD_TRAINER_RC_143` 停在 `iteration=1692` / `update_step=423`，无 iter1800 final、无 checkpoint1800；`candidate_status=unsigned`，`adapter_learned_qa=false`。
- **当前 active run**：`formal-run-20260706T090552+0800-tail1200-full-envelope`；live probe `2026-07-06T09:22:38+08:00` 看到 trainer pid `42505` 仍活，命令加载旧 run 的 `0001200_adapters.safetensors`，`--iters 600`，输出到 tail1200 run dir。
- **proof boundary**：当前 tail1200 是 `checkpoint1200 weight-init new trajectory`，不是 optimizer/RNG/dataloader/iteration true resume，不是 frozen formal 1800 completion，不是 candidate，不是 C6/V-PASS/behavior pass。
- **latest live metrics（只按 live metrics 写）**：L-CJ 记录 active `090552` 已过 iter400 validation，checkpoint300 仍已 banked：`metrics.jsonl:145` val iteration `400`, val_loss `0.028200536966323853`, val_time `75.8426699170086`；`metrics.jsonl:147` optimizer_update iteration `400`, update_step `100`, loss `0.043255108408629894`；`metrics.jsonl:148` train_report iteration `400`, train_loss `0.06799046993255616`, it/s `0.04399540526746031`, peak `17.974112558GB`, trained_tokens `17803`；`train.log:56-57` corroborates iter400 val/train。主 passive receipt 是 watchdog iter400 L-CI，状态 `PASSIVE_ITER400_VAL_CONFIRMED__TRAINER_LIVE__ITER600_FINAL_PENDING`；早期同里程碑 receipt 是 watchdog L-BY，二者都不同于更早 monitor/stale-label L-BY artifacts。host free pct 曾到 `4` 后恢复到 `8/9`，passive/no-auto-watchdog、no kill、no armed watchdog。

📌 **当前路线**：保持 `LIVE_TAIL1200_ITER400_VAL_PASS_CHECKPOINT300_BANKED_PID42505__ITER600_FINAL_PENDING__WEIGHT_INIT_NEW_TRAJECTORY__FULL_ENVELOPE_NO_AUTO_WATCHDOG__NONCLAIMS_PRESERVED`。下一步只继续监控 iter600 final/checkpoint、shadow/passive monitor 与后续 eval/signoff；不得把 live pid、低 loss、checkpoint300、iter400 pass 或 partial adapter basis 推成 candidate/C6/V-PASS。
> non-claims：not true resume / not frozen formal completion / no formal candidate / no C6 acceptance / no V-PASS / no behavior pass / no UIUE·voice；旧 234208 `adapter_learned_qa=false`，当前 tail1200 仍需完成 receipt 与后续 eval。

## 【历史】2026-07-05 晚：**run-auth 已接受；formal 1800 仍 NO-GO/HOST_GATE_HOLD；command/watchdog v2 clear**（已被 2026-07-06 full-envelope tail1200 live 态 supersede）

🔴 **Formal launch 最新真态（本节 supersede 下方「等磊哥 run-auth 起 formal 1800」旧态）**：
- `run-auth` 已接受：磊哥已给“C5闭环 / 中间全部授权同意 / 不要停”。这只解锁进入 launch flow，**不替代 host baseline、watchdog 真 pid、first-real LR gate**。
- **Phase 1 CLEAN / Phase 4 B / Launch Packet 静态包仍有效**：`6a4b6b82`、trainpack `5653`、sha `fa5690400f67...`、LR 450 fixture rc0；formal 仍只能是 `evidence-run-only`。
- **command v2 clear**：W-G2 `LAUNCH_COMMAND_V2_READY_BUT_HOST_HOLD`，旧 `COMMAND-CANDIDATES.txt` 的 shorttrain watchdog 段被 v2 supersede。
- **watchdog v2 clear but not armed**：W-H2 `WATCHDOG_V2_CLEAR_BUT_HOST_HOLD`；尚无 trainer pid，尚未 armed。
- **host gate HOLD / not launched**：三次 launch-adjacent host sample 均低于 21GB：W-I `17.867GB<21`，W-I2 quiet `18.554GB<21`，W-I3 forced `18.554GB<21`；swap 约 `0.29GB` PASS 不能覆盖 free-memory FAIL；无 `host-waiver-key`。
- **GitNexus 节点完成但不外溢**：W-K4 `node .gitnexus/run.cjs analyze` rc0/18s，index 更新到 `6a4b6b8`（30002 symbols / 52715 relationships / 300 flows）；AGENTS/CLAUDE generated GitNexus block 已更新。本轮 host-HOLD 窗口不再 reindex，GitNexus tooling rc0 不代表 launch/candidate 进展。

📌 **当前路线**：保持 `NO_GO_HOST_GATE_HOLD__RUN_AUTH_ACCEPTED__COMMAND_V2_CLEAR__WATCHDOG_V2_CLEAR__NOT_LAUNCHED`。下一步只能二选一：**A** 关闭重 GUI 后 fresh host resample 到 PASS；或 **B** 磊哥显式给 `host-waiver-key`。之后才可显式指派 high Codex executor 起 formal 1800 `R3-QNEG-clean`（rank16/iters1800/updates450/warmup36）+ arm watchdog 真 pid + first-real LR gate。
> non-claims：未 launch / 未 watchdog armed / 未 first-real LR / 未 formal-run 完成 / 未 candidate signoff / 未 C6 acceptance·V-PASS·UIUE·voice；`adapter_learned_qa=false`，`candidate_status=unsigned`。

## 【前一阶段】D-106/D-107 后 baseline——先做 Phase 1（2026-07-05 早，historical，已被上方 Phase 1 CLEAN supersede）

🔴 **D-106/D-107 最新真态（本节 supersede 下方 R3 in-flight 旧态）**：D-105/D-106 坐实 qa 三轮可比真数 adapter `any_tool_call_fail`=**9/9/9**（scanner 硬化后，旧「9→8→10 恶化」叙事作废——R3=8 是漏计 `query_volume` artifact），逐 case 揭示=**模型固有 actuation prior 硬墙**（base 原模型也失败 4 个 WINDOW/DOOR/SUNROOF/SUNSHADE），adapter-only 数据法两轮（R3 堆量/R4 改挂载形态）纹丝不动。**D-107（磊哥拍）**：从 D-106 出发开新执行锚——① `docs/baseline-roadmap-2026-07-05-c5-d106.md`=当前 C5 起手 baseline（planning，非契约）② Codex App worker 接管执行基线，commander 纯编排 ③ formal 1800 **HOLD pending Phase 1-4** ④ R-L17=`route-only signed; candidate signoff unsigned` ⑤ 第一执行单=**Phase 1 ONLY**（scanner hardening 正式化 + 6 label authority 冲突裁决表→repo 可复跑 gate）。stoplines：不训练/不生成新数据/不启动 formal/不 merge UIUE/不碰 `Core/Training`。

📌 **当前路线（Phase 序，baseline §2 鸟瞰）**：Phase 1 量尺+标签权威修复（判断系统先可靠）→ Phase 2 runtime query safety gate（主线，OpenSpec `RuntimeQueryGuard`）→ Phase 3 R5 pair-boundary one-shot（旁线 falsification）→ Phase 4 D-085 gate semantics 重拍（adapter-only qa=0 vs runtime-gated safety）→ Phase 5 formal 1800（若 Phase 4 允许）→ Phase 6 C5 exit package。🔴 **Phase 1 依赖一手产物**：`R5-SCANNER-HARDENED.md`（9/9/9 规则+失败四分类）+`R5-LABEL-AUTHORITY-AUDIT.md`（9 冲突归属矩阵，含 LABEL-AUTH-005/007/008 天窗/遮阳帘 default_scope=**磊哥 LEIGE_KEY 待拍**）；`tools/check_eval_mount_validity.py` 与 scanner 门当前仍是 run-dir 脚本、**未进 repo**=Phase 1 待迁。

## 【前情】D-097 后 R3 in-flight（2026-07-05 凌晨，historical，已被上方 D-106/D-107 supersede）

🔴 **D-095~D-102 最新真态**：R2b run `155204` 训练健康完成（600/600，val 0.010），T-D 初判 `F044_R2B_FAIL_STRATIFIED` 后被 **D-097 翻案**：门轨 11/64 case mount-invalid（A5 错位拼接+B6 挂载缺失，根因=case source_sample_id 按序号 join），A/B 有效上限被坏量尺压成 10/15+9/15；v3 量尺修复+配对重评后现有 adapter 有效面 **A 15/15 / B 15/15 / D 19/34**=D-085 三轴 PASS。唯一真残余=expanded qa 负面，口径固定四数字 `total=11 / adapter=9 / base=2 / original_v3=0`。R3 修复=qa qneg 154 行（108 unsupported+36 对照+10 真 query guard），trainpack 5653 静态门/judge 全绿；**R3 短训第三跑在飞**（`F044-r3train-run-20260704T211035+0800`，%1 executor+夜间 watchdog --armed；前两跑被 operator redline 拦停归档 PARTIAL）。

📌 **当前路线**：R3 训完→四轴 eval（W52 跑道，v3 base 锚 A3/B14/D18）→verdict 达 D-085（A≥12/B>9 非零 delta/D≥18/qa=0 跨轨）+Launch Packet 六件+host baseline+watchdog --armed（pct4 版 sha e8257fab）全绿 → **正式 1800 iters 起跑**（D-100 磊哥提前授权条件式）；任一不绿=停在 verdict/分诊。D-102 条款：formal 起跑 swap>1GB 必上抛磊哥。

## 前一阶段（2026-07-03 午前：**N4-ACCEPTED-LOCAL**，goal N0-N4 兑现，已被 D-053 训练 smoke 改写）

🎯 **goal 收口（D-043）**：N0 落账✅ N1 备份 PR #30✅（CONFLICTING 转分级整编，裁决表 keep-main 51/take-branch 4/union 11 已出）N2 五支 PR 修复-复核链全闭环✅（#26=`edfc2198` 全 PASS / #27=`a400b01a` APPROVE / #28=`49fa0b9b` APPROVE+claim correction / #29=`871307d9` APPROVE_FOR_PR29_P1_SCOPE / #31=`f163eedf` APPROVE_FOR_PR31_DELTA，全 local verify 非 CI）N3 GF rev3✅ **N4 验收=`docs/c5-training-readiness-grill/n4-train-readiness-acceptance-2026-07-03.md`（N4-ACCEPTED-LOCAL：preflight strict exit0 commander 独立复跑+DataGate 语义门对抗探针 fail-closed+配方锚/F-044 默认锁+premortem/runbook 门）**。🔴 不清的帐：prepare receipt broader gates / run-auth+R7(N6/N7) / CI billing / GitHub reviews=0。run-auth 后第一动作=T1 smoke（D-043 预测风险写作 mlx-lm#1348 hang；D-053 已实跑改判为 Metal OOM）。

🎉 **canary 收敛 + N5E 锁定（D-047/D-048，2026-07-03 午后）**：canary 60 行两轮收敛 **CANARY_PASS_EXPAND_OK**（v1 FAIL=跨厂商 judge 抓溯源缺陷（机械门全绿仍 FAIL）→ ledger 修复 → v2 PASS；验收报告+lineage INDEX 28 artifact sha 绑定，run 目录 N5-canary/）。**N5E 扩量 grill 消减锁定**（`docs/c5-training-readiness-grill/n5-expansion-grill-2026-07-03.md`）：12 题=10 default_locked（含声称分层条款：语义抽样维禁升格全量声称）+ **2 磊哥键（N5E-005 人工精度门 / N5E-006 基座 pin=billing→merge 后自动满足）**；landing rev2 三线在途（批契约/验收门/judge 作业书）；M2 树盘点 ready 等授权。D-046「重要节点必 grill 范式」首个完整闭环当日跑通。

🔀 **路线更新（D-044/D-045，磊哥 2026-07-03 午拍）**：第一步工程面已收干净——**docs 合流走 PR #32**（整编支 `e01aa7c3`，%43 复核 APPROVE，MERGEABLE；#30 留备份勿合）；billing 修复后 commander 自动 rerun checks，**CI 真绿按依赖序合 #26→#27→#28→#29→#31→#32**。第二步 **N5 canary 进行中（只生成+judge 不训练，目标=候选数据质量）**：Anthropic 生成=后台 subagent CC（Opus）/ OpenAI judge=codex worker——**云凭证键解除**，剩 **3 键：billing / merge / run-auth**。canary 管道=sub-CC 60 行（字段模板取 N4A 真实行保 digest 正确+open-close 极性对称）→ DataGate（含硬化语义门+redaction）→ %43 judge → 验收报告 → 过了才扩 wave-1。

## 前情（2026-07-03 晨：外审收窄落账 D-040 + goal=N0-N4 自动推进 train-readiness）

🔴 **外审收窄（磊哥转达，D-040，全部 live 亲核成立）**：v6 结论保留但窄化——A 轴 adapter 15/15（verdict:46）证「A+ 契约解 v5 NO_TOOL」=YES；B 11/15 未达 draft 门 14/15（verdict:16,29，终值待 lock）；v6.1 EOS 重复病理 68/68→1/68 真进展，但同帐 C 4/4→2/4、D 8/34→5/34、+4 parse_error（verdict:48-50）→ 表述统一「**EOS 改善重复病理，tiny 稀疏下仍有 parse/早停/泛化退化残留**」，禁写"输出稳定"。**PR #26-29 live 实况（2026-07-03 gh 亲核）：全 OPEN、GitHub latestReviews=0、verify check 全 FAILURE×2**（billing 归因，但 FAILURE 不写绿/不写 merge-ready/本地 worker review≠GitHub review）；#26 head 已变 `e6a8849f`（旧本地 APPROVE 绑 `3b081823` 失效）→ 四支 PR 全部需绑当前 head 重审（#27=`a400b01a`/#28=`49fa0b9b`/#29=`5c68f945`）。**wave-1 口径 = protocol-string substrate built（4500 行）+ C5DataGate local pass，NOT train-ready**：builder receipt blocked + loss-mask preflight strict exit66（294 长行>8192 / valid-test under-supervised / 云生成 + cross-vendor judge 未跑，verdict:55）。训练风险进配方锚：D 轴 18/34→8/34→5/34 窄化 + **query→actuation（只读变控制）安全级**。

**当前 goal（磊哥 2026-07-03 晨 /goal，纯自动）**：N0 落账收窄→N1 docs 分支收编（推新分支；behind-7 旧 commit 已核全在 origin/main）→N2 PR head 重审 wave（%43 #26增量+#29 / %44 #27#28，绑 head SHA + ≥1 实跑）→N3 GF rev3→**N4 wave-1 train-readiness 闭环收尾并验收**（E-2 降档挂载实装 + preflight strict exit0 + valid/test 监督契约 + 配方锚 + F-044 默认 14/15 标可 override）。人审键现状（D-045/D-049 后）：云凭证已解除（subCC+codex 方案）、billing 已解除（repo 转 public）→ 剩 merge 链 / run-auth / N5E-005 人工门；§6 脱敏红线 10 天豁免窗口至 2026-07-13（D-049）。路线图快照=`~/workspace/data/exports/snapshot-20260703-065315.md`。v5 verdict=BLOCKED_INVALID 维持（历史）；R7 route-only 至 2026-07-23，candidate 仍 unsigned。

## 前情（2026-07-03 凌晨通宵收官 historical；「双审 APPROVE/数据门全量兑现」表述已被上方 D-040 收窄 supersede）

v6 tiny-ablation verdict（`docs/c5-training-readiness-grill/v6-tiny-ablation-verdict-2026-07-03.md`+附录3件）；paired 配对暴露 tiny 过拟合窄化（D delta -10）；晨报=`docs/handoffs/2026-07-03-overnight-v6-verdict-morning-brief.md`（其 0-5 拍清单中 PR/数据门表述以 D-040 为准）。

## 前情（2026-07-02 晚，M1 已收口；本节 historical snapshot，后续见 commander-log D-028~034）

**M1 consolidation 完成（D-018）：wave-1 全部合流 main=`80ea379c`，验收 PASS（main 范围）。** 四支 PR 链：#13 α gate2 masking（token 真 enforce + 反向 guard 三 split）→ #12 β gate8（562 工厂实算）→ #14 γ 40 件文档整编（grill 语料/commander-log/基线双文档进 main）→ #15 δ 验收修复（gate8 曾改派生物没改工厂，验收 diff 门抓到 → 工厂实算 + regen 重排）。每支经交叉审/亲核（α 曾被对抗 fixture 抓 P0 guard 漏 test split，修后 P0-RESOLVED）。验收唯一残留 = sibling UIUE fixture 环境噪声（非 M1 回归，M4 收口消解）。**E-2 已 locked+G7A-D 实装 merged**（本段为 M1 收口时 historical；governance-fit 治理 grill W1/W2/W3 各 40 决策另见 grill README）。

## 两份当前基线文档（起手读）

1. ⭐ `docs/baseline-roadmap-2026-07-02-pre-lora.md` — 全树/分支/PR 状态矩阵、合并节点计划（M1 consolidation staged PR → M2 清理 → M3 D25 receipts → M4 UIUE）、现状 verdict=HOLD、3 worker 目录规则、文档级联指针。
2. ⭐ `docs/lora-loop-blueprint-2026-07-02.md` — 此刻→训练结束闭环鸟瞰：8 gate+2 裁决门真实态、生成→门→裁决→训→评循环总图、run receipt 契约、节点序 A-H、巨人肩膀使用矩阵（home-llm/Hammer/xLAM/BFCL/hf-skills）。

## 决策台账（原 5 件已全落 + 新周期）

原 5 件全 CLOSED：①masking override locked+merged ②E-2 locked（grill 43 决策+G7A-D 实装 merged）③grill 58 条 locked ④tiny v5 已真跑（→重标 BLOCKED_INVALID，v6 另签）⑤consolidation done（13+ PR 合流）。**当前等磊哥**：v6 run-auth（Phase 0-3 完成后按 FINAL 档 §5 签）；M2 树清理授权；M4 UIUE。R7 已续签至 **2026-07-23**。

## 禁止动作 / stoplines（formal launch HOST_HOLD 态）

- 🔴 不得把 R2b/R3 train_health 写成 behavior pass / candidate pass / C6 acceptance / V-S-U-PASS。
- 🔴 formal 1800 起跑必须现核：Launch Packet 六件（W53 R3 对齐版）、fresh host baseline PASS 或显式 `host-waiver-key`、watchdog --armed 真 pid、first-real LR 450-schedule rc0（tools/verify_formal_lr_schedule.py 跑真 metrics/log）；任一缺失=HOLD/PARTIAL。当前 host gate 明确 HOLD。
- 🔴 D-102：R3 短训限定的 host-predicate-v2/quiet-window waiver 不外推 formal；formal swap>1GB 按 D-094 上抛磊哥。
- 🔴 C6 acceptance/comparison、demo-golden、voice/live-loop 产品声称仍需 candidate signoff+proof-class 对应证据（R-L17 体系）。
- 🔴 不删不合任何隔离树/分支（含 g5/g6/g7——分支 tip 落后，直合会回退 main 上更新的文件，见 baseline-roadmap §1）；清理等节点 M2 一次性授权。
- 🔴 doc-absorption / grill 两分支**禁整支合 main**（147 behind，分支侧 CURRENT/README 旧于 main）——文档进 main 走 M1-γ 新开文档整编支。
- 🔴 raw 座舱原文/PII/报价不入 bench/训练数据（CLAUDE §6）。

## 权威指针

- 决策台账：`docs/commander-log/decisions.md` **D-095~D-102**（当夜主线）+ grill 总 SSOT `docs/grill-tournament/grill-decisions-master.md`
- run 恢复板（压缩失忆第一读）：`~/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/STATUS-BOARD.md`
- Formal launch / tail current run：`~/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/secretary/STATUS-BOARD.md` + `EVIDENCE-INDEX.md`（当前权威状态板：active `formal-run-20260706T090552+0800-tail1200-full-envelope` / pid `42505` / full-envelope no-auto-watchdog / checkpoint1200 weight-init new trajectory；old `formal-run-20260705T234208+0800` 仅作 historical HOLD rc143、iter1692/no1800 证据）
- R3 grill：`docs/c5-training-readiness-grill/f044-r3-grill-2026-07-04.md`；R3 eval/launch packet：run-dir `W52-R3-EVAL-PREFLIGHT.md`+`W53-REFRESH-NOTE.md`+`FORMAL-LAUNCH-CONDITIONS.md`
- UIUE 合并路线：`docs/superpowers/plans/2026-07-05-uiue-merge-battle-plan.md`（v2，执行前 live git 重核）；晨报骨架：`docs/handoffs/2026-07-05-r3-overnight-morning-brief.md`
- 最近 handoff：`docs/handoffs/2026-07-04-f044-round2-morning-brief.md`
- wave-1 / 基线盘点一手档（仓外）：`~/Projects/agent-tmux-stack-research/runs/2026-07-02-{overnight-pre-lora-push,baseline-roadmap}/`
- OpenSpec 活跃 carrier：`openspec/changes/{rebuild-c6-four-layer-bench,retrain-c5-lora-d-domain,define-runtime-presentation-bridge}/`（retrain-c5 是 draft 非执行授权）

## 本地 iOS build truth（沿用）

- 本 worktree Codex `build-ios-apps` profile=`ios`，scheme=`MAformacIOS`，专属模拟器 `iPhone 17 Pro`；UIUE worktree 必须用不同模拟器（同 bundle id 互相覆盖）。

## UIUE 隔离树（沿用）

- `/Users/wanglei/workspace/MAformac-uiue`（uiue/phase4，R7 显式 blocks `uiue_merge_to_mainline`）：主线只做 read-only 交叉检查；引用 UIUE file:line 前必 live 重确认。收口随 baseline-roadmap 节点 M4。

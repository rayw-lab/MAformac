---
status: baseline_roadmap_active
artifact_kind: c5_d106_completion_baseline
authority: planning_baseline_not_openspec_contract
created: 2026-07-05
as_of_decision: D-110
branch_at_creation: codex/rebuild-c6-doc-absorption-20260624
proof_class: local_static_artifact_synthesis
supplemented_from:
  - /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness
  - /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-phase1-scanner-authority-gates
  - /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch
supersedes_for_c5_lane:
  - docs/CURRENT.md R3-in-flight wording（仅 C5 当前态；CURRENT 仍是 router）
  - docs/baseline-roadmap-2026-07-02-pre-lora.md（仅 C5 训练收口路线；树/PR/M2/M4 历史仍保留溯源价值）
non_claims:
  - not OpenSpec acceptance
  - not runtime implementation authorization
  - not data generation authorization
  - not formal 1800 launch authorization
  - not C5 candidate signoff
  - not C6 acceptance
  - not UIUE merge approval
  - not voice/mobile/true-device/V-PASS
expires_when:
  - D-085 qa gate semantics 被正式重拍
  - R5 one-shot pair-boundary verdict 落地
  - runtime query safety gate OpenSpec 被 propose/apply/archive
  - formal 1800 run 启动/停止/完成
  - C5 candidate signoff 或路线转 C
---

# C5 D-106/D-110 后基线：后续做什么、分几 phase 到 C5 结束

> 一句话：**C5 现在不是失败，也不是完成；D-110 后已经具备一次受控 formal 1800 evidence run 的静态前置，但 LoRA adapter 仍未学会 qa safety，candidate signoff 仍 unsigned。formal run 只能产训练/行为证据，不能自动变成候选、C6 acceptance、demo safety 或 V-PASS。**

> 🔴 **D-111 addendum（2026-07-06，磊哥拍 A）**：C5 收尾定调 = **A honest-frozen-closeout，双轨并行**——**主活**：冻结 tail1200 iter600 unsigned artifact（demo-ready）+ runtime 接线 W20A 让 demo direct-value「调到26度」可演（R1-correct：`<tool_call>`parser + `ToolContractNormalizer`(562,`ir_map` ⭐C 编译常量) + 新增 `IR→ToolCallFrame` 桥 → `C3ExecutionPipeline`，**不走 `decode:306`**；superaudit CONDITIONAL_GO 91/100，实装需 run-auth）；**并行**：本 baseline §9 Phase 5「Formal 1800 Evidence Run」= **磊哥保留 goal，待 run-auth（非 DEFER）**；1800 不大动=不重训别配方、不大改 recipe（冻结 R3-QNEG-clean）。🔴 **action-question under-action（T1 14/18，根因 trainpack「能不能」register 0 覆盖 W15）= 新分诊面**：D-108 B（§8 已记）只 waive qa over-actuation，**不覆盖 action-question**，本轮 DEFER（formal 1800 配方不动 → 也不修 register，一致）。candidate 仍 unsigned。定调全文 `decisions.md` D-111（:847-859）+ grill SSOT `runs/2026-07-06-c5-runtime-mainpath-grill/`。

## 0. 读取纪律

本文件是此刻 baseline，不是行为契约事实源。执行前仍按项目宪法读：

1. `CLAUDE.md`
2. `docs/commander-log/decisions.md` 最新 D 条；当前以 `D-110/D-108` 为 formal path 最新裁决锚，`D-106` 保留为 qa root-cause baseline
3. run 目录状态板：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/STATUS-BOARD.md`
4. R5 三件一手产物：`R5-SCANNER-HARDENED.md` / `R5-LABEL-AUTHORITY-AUDIT.md` / `R5-STRATEGY-REDTEAM.md`
5. 本轮递归补读外部研究包：`/Users/wanglei/Projects/agent-tmux-stack-research/` 下与 C5/C6/runtime/UIUE/voice/macro/formal launch 相关的 run 文档；`code-basis-pr38-worktree/` 这类镜像代码树只作 basis 线索，不重复当作独立研究结论。

若本文件与 live repo、最新 D 条、run receipt 或 OpenSpec 冲突，后者胜出，并回写本文件或新 baseline。

### 0.1 本轮补读带来的三条修正

1. **真实链路不是 Phase 6 末尾才想的 UI 问题**：W50 证明当前 app live loop 仍是单 AC 默认闭环，缺 full contract runtime bundle、D-domain app path、concrete Qwen/LoRA backend、10 族 state/display bootstrap 和 `RuntimeAdapterMountReceipt`。因此 Phase 2 的 runtime safety 必须同时处理 mount/basis/10-family payload，不只是 query prompt/harness。
2. **R-L17 要收窄口径**：W48/X2 修正为 `route-only R7 signed; candidate signoff unsigned`。这允许 C6 construction lane 提前推进，但不允许 C6 acceptance/comparison、golden、voice、UIUE、V-PASS 或 C5 candidate 晋级。
3. **C6 是两条 lane**：construction/rebuild 可作为并行工程准备；base-vs-LoRA comparison 和 C6 acceptance 必须等 signed candidate + explicit run authorization。L6/R2b 53-case 只能作 seed evidence，不能原样冒充 C6 denominator。

### 0.2 Commander update（2026-07-05 D-110 / Phase 1 CLEAN / Launch Packet frozen）

本节 supersede 本文件内仍带 D-106 HOLD 口径的局部表述；未被本节覆盖的风险、防线和 proof-class 纪律仍保留。

| 面 | 最新状态 | 指挥官裁定 |
| --- | --- | --- |
| Phase 1 | `6a4b6b82` surgical commit；scanner/mount/label authority repo gate rc0；真 manifest label authority rc0；redteam cleanup `GREEN_WITH_P2_ENV_CAVEAT` | **CLEAN for formal-start static gate**，但不能写“整仓 Core-clean”，因为 live worktree 仍有既存 `Core/Training` dirt |
| Phase 4 | D-108 = Option B `runtime-gated qa safety` | **formal path unlocked**；`adapter_qa_gate=fail_accepted_under_B`，`adapter_learned_qa=false` 固定写入 receipt |
| Launch Packet | `eval/launchpacket-frozen/` 六件冻结；trainpack `5653` 行，sha `fa5690400f67db9ef237dabdb489f58d1ab69961f14d6733d79f9bd7cad33823`；LR 450 fixture rc0 | **static packet done**；host baseline、watchdog arm、first real LR runtime check 仍是实时门 |
| Formal 1800 | 尚未起跑 | **CONDITIONAL GO as evidence run only**：等 `run-auth` + fresh host baseline + watchdog real pid；不是 candidate signoff |
| Candidate / C6 / demo | 未签 | **NO-GO**：RuntimeQueryGuard、R-L17 candidate signoff、W34 final-head rerun、C6 comparison/acceptance 仍另门 |

Commander risk opinion after local + external cross-check:

1. **LoRA 方向可训，不等于低风险。** LoRA 官方论文只证明低秩适配降低训练参数与显存，不证明行为安全或不会遗忘；外部 forgetting 研究明确指出 PEFT/LoRA 仍会 catastrophic forgetting，forgetting 会随 update steps 增加。
2. **本项目最大风险不是能不能跑完，而是跑完后 train-health 语言外溢。** Formal 1800 完成后只能写 `formal_train_done` / `model_behavior_gate` / `adapter_qa_gate=fail_accepted_under_B` / `candidate_status=unsigned`。禁止把它写成 C5 candidate、C6 acceptance、demo readiness 或 V-PASS。
3. **MLX/Apple Silicon 宿主风险是真风险。** MLX 在 Apple silicon 上使用 unified memory，CPU/GPU 共享同一内存池；W27/W33 已把 host baseline、watchdog、UN/swap/no-progress、LR schedule、eval manifest 识别为 formal 起跑硬门。当前最强防线不是临场调 batch/rank/seq，而是 clean host + fail-closed baseline + real watchdog。
4. **脏代码与冻结包要分账。** 起跑只能消费已冻结 trainpack sha；若任何人起跑前重生成 trainpack，当前未提交 `Core/Training/C5LoRATraining.swift` / tests dirt 会把“冻结包训练”变成“脏代码训练”，必须重新 gate。

Evidence anchors:

- D-108 B 语义与 non-claims：`docs/commander-log/decisions.md:815-821`。
- D-110 default_scope Scheme A + Phase1 数据清零授权：`docs/commander-log/decisions.md:838-844`。
- Phase1 cleanup redteam green + Core dirt caveat：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-phase1-scanner-authority-gates/redteam/phase1-cleanup-audit.md:11-20`、`:145-149`。
- Launch Packet freeze：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-phase1-scanner-authority-gates/eval/launchpacket-frozen/FREEZE-REPORT.md:20-44`。
- Formal launch static conditions：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-phase1-scanner-authority-gates/eval/launchpacket-frozen/FORMAL-LAUNCH-CONDITIONS.md:20-33`。
- External: LoRA paper `https://arxiv.org/abs/2106.09685`；LoRA forgetting risk `https://arxiv.org/abs/2401.05605`；MLX unified memory `https://ml-explore.github.io/mlx/build/html/usage/unified_memory.html`。

### 0.3 Commander update（2026-07-05 晚 / run-auth accepted / formal launch NO-GO host HOLD）

本节 supersede 本文件 0.2 中“等 `run-auth` + fresh host baseline + watchdog real pid”的等待态：`run-auth` 已被接受，但起跑实时门没有全绿。formal 1800 **尚未 launch**。

| 面 | 最新状态 | 指挥官裁定 |
| --- | --- | --- |
| Run-auth | 磊哥已给“C5闭环 / 中间全部授权同意 / 不要停” | **ACCEPTED**，但只解锁 launch flow，不替代 host/watchdog/LR runtime gates |
| Launch command | W-G2 `LAUNCH_COMMAND_V2_READY_BUT_HOST_HOLD`；v2 supersede 旧 `COMMAND-CANDIDATES.txt` 的 shorttrain watchdog 段 | **COMMAND_V2_CLEAR**；命令 artifact 收敛，不等于 launch-ready |
| Watchdog | W-H2 `WATCHDOG_V2_CLEAR_BUT_HOST_HOLD`；路径收敛到 W-H template / `formal-watchdog-draft.py` | **WATCHDOG_V2_CLEAR_BUT_NOT_ARMED**；无 trainer pid，无 armed proof |
| Host gate | W-I `17.867GB<21`；W-I2 quiet `18.554GB<21`；W-I3 forced `18.554GB<21`；swap 约 `0.29GB` PASS；无 `host-waiver-key` | **NO-GO / HOST_GATE_HOLD**；swap PASS 不能覆盖 free-memory FAIL |
| Formal 1800 | 未启动；无 trainer pid、无 watchdog armed、无 first-real LR | **NOT_LAUNCHED**；下一步只能 close heavy GUI 后 fresh PASS，或磊哥显式 `host-waiver-key` |
| Candidate / C6 / demo | 未签 | **NO-GO**：formal 仍是 evidence-run-only；`candidate_status=unsigned`；`adapter_learned_qa=false` |
| GitNexus | 本轮按磊哥要求由 W-K4 跑 `node .gitnexus/run.cjs analyze`，rc0，18s；本地 index 更新到 commit `6a4b6b8`，30002 nodes / 52715 edges / 300 flows；AGENTS/CLAUDE generated GitNexus block 随之更新 | **TOOLING_RC0_ONLY**；不是代码行为变化，不是 launch readiness；host-HOLD 窗口不再继续 reindex |

Evidence anchors:

- Formal launch current status：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/secretary/STATUS-BOARD.md:16-30`。
- Evidence index：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/secretary/EVIDENCE-INDEX.md:24-43`。
- Forced host sample：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/host/host-baseline-resample-forced.md:34-38`、`:53-57`。
- Launch command v2：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/launch/formal-launch-execution-plan-v2.md:13-15`、`:56-69`、`:91-105`。
- Watchdog v2 audit：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/watchdog/watchdog-v2-audit.md:7-18`、`:26-39`。
- Opus adversarial audit：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/monitor/opus-launch-adversarial-audit.md:17-22`、`:64-80`。
- GitNexus update receipt：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-launch-doc-cascade/gitnexus/gitnexus-update-receipt.md:15-18`、`:83-98`、`:143-153`。

### 0.4 Commander update（2026-07-06 早 / full-envelope tail1200 live / no-auto-watchdog）

本节 supersede 0.3 的 host-HOLD/not-launched 运行态，以及 L-BF/L-BJ 早间低内存/`15GB` 约束口径。未被本节覆盖的 proof-class、candidate、C6、V-PASS 防线仍保留。

| 面 | 最新状态 | 指挥官裁定 |
| --- | --- | --- |
| 资源 authority | 磊哥最新 authority 改为 full-envelope/no-auto-watchdog，沿用昨日 full-envelope scheme；用户接受 freeze/manual app closing 风险 | **15GB 旧约束已 superseded**；secretary 只记录状态，不等于 launch/candidate authority |
| 旧 formal run | `formal-run-20260705T234208+0800` 以 `FORMAL_TRAIN_HOLD_TRAINER_RC_143` 收口；final metrics 停在 `iteration=1692` / `update_step=423`；无 iter1800 final / 无 checkpoint1800；`candidate_status=unsigned`；`adapter_learned_qa=false` | **历史 HOLD/PARTIAL**；partial adapter basis 只能从 checkpoint1200/rolling sha 出发另审，不能升格候选 |
| 当前 tail run | `formal-run-20260706T090552+0800-tail1200-full-envelope`；live probe `2026-07-06T09:22:38+08:00` 看到 trainer pid `42505` 存活，命令加载旧 run `0001200_adapters.safetensors`，`--iters 600` | **LIVE_TAIL1200**；这是 checkpoint1200 weight-init new trajectory，不是真 resume |
| Watchdog policy | L-BM 口径为 shadow-only/no armed watchdog；no-auto-interrupt | **NO_AUTO_WATCHDOG**；风险 ownership 变化不等于训练完成或候选通过 |
| Latest live metrics | L-CJ: active `090552` iter400 validation passed and checkpoint300 remains banked. `metrics.jsonl:145` val iteration `400`, val_loss `0.028200536966323853`, val_time `75.8426699170086`; `metrics.jsonl:147` optimizer_update iteration `400`, update_step `100`, loss `0.043255108408629894`; `metrics.jsonl:148` train_report iteration `400`, train_loss `0.06799046993255616`, it/s `0.04399540526746031`, peak `17.974112558GB`; `train.log:56-57` corroborates; primary passive receipt L-CI status `PASSIVE_ITER400_VAL_CONFIRMED__TRAINER_LIVE__ITER600_FINAL_PENDING`; free pct dipped `4` then recovered `8/9` | **validation telemetry only**；低 loss/活 pid/iter400 pass 不是 frozen formal completion、formal_train_done、candidate、C6、V-PASS 或 behavior proof |
| Host warning | L-BV passive monitor saw free_pct `4` then `5` with no-auto-watchdog/passive policy | **WARN_NO_KILL**；不是 HOLD、不是 kill、不是 proof-class change |
| Candidate / C6 / demo | 仍未签；当前 tail run 尚无 completion receipt/eval/signoff | **NO-GO**：not true resume / not frozen formal completion / no candidate / no C6 / no V-PASS / no behavior pass |

Evidence anchors:

- Active tail run live command/pid：`ps -p 42505 -o pid,ppid,stat,etime,rss,command` at `2026-07-06T09:22:38+0800` showed pid `42505` live with `--resume-adapter-file .../0001200_adapters.safetensors` and `--iters 600`.
- Active tail metrics：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260706T090552+0800-tail1200-full-envelope/metrics.jsonl:145` records iter400 val; `:147` records iter400 optimizer_update; `:148` records iter400 train_report; `train.log:56-57` corroborates.
- Active tail checkpoint300：`adapters-rank16/adapters.safetensors` and `adapters-rank16/0000300_adapters.safetensors` are size `69772950`, sha256 `293619a1625d285dd41764ac8d79f5284c27131ed7588e87008ebaf0407dfbc4`.
- Old formal HOLD：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260705T234208+0800/FORMAL-TRAIN-RECEIPT.md` records `FORMAL_TRAIN_HOLD_TRAINER_RC_143`, `trainer_rc=143`, `candidate_status=unsigned`, `adapter_learned_qa=false`; old metrics tail stops at `iteration=1692` / `update_step=423`.
- Run-root live status board：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/COMMANDER-LIVE-STATUS.md` and `secretary/STATUS-BOARD.md`.

## 1. 当前真态

### 1.1 状态分层

| 层 | 当前状态 | 结论 |
| --- | --- | --- |
| train_health | R2b/R3/R4 都完成 600/600 级别短训，训练过程健康 | 只能证明训练链路健康，不能证明候选可用 |
| A/B/D 行为面 | R3: A14/B15/D23；R4: A15/B15/D21；D-098 后 R2b 有效面 A15/B15/D19 | **动作语义资产强**，小模型能学 actuation 正例和近邻区分 |
| qa 安全面 | hardened expected-empty adapter any_tool_call_fail: R2b/R3/R4 = 9/9/9；D-108 已拍 B | **adapter-only qa 未破**；可以在 B 口径下起 formal evidence run，但不能 candidate signoff，且禁写 `adapter learned qa` |
| 量尺/authority | D-097 mount-invalid 翻案；D-105 scanner + label authority 翻案 | 量尺自身必须先成为硬门，否则战略会被假数字带偏 |
| product safety | runtime guard 尚未以 OpenSpec/实现/receipt 证明 | 只能说方向成熟，不能说已过 runtime safety |

证据锚：

- D-103 R3：A14/B15/D23、qa fail、训练健康 600/600，见 `docs/commander-log/decisions.md:768-772`。
- D-104 R4：A15/B15/D21、qa fail、T1 失败是工具名幻觉非 over-refusal，见 `docs/commander-log/decisions.md:774-780`。
- D-105：scanner 漏计 invalid tool name + `现在音量是多少` label authority 冲突，见 `docs/commander-log/decisions.md:782-791`。
- D-106：hardened any_tool_call_fail = 9/9/9，qa 是模型固有 actuation prior 硬墙，见 `docs/commander-log/decisions.md:794-800`。
- R5 scanner：expected-empty 下任何 observed tool 都 fail；R2b/R3/R4 adapter any = 9/9/9，见 `R5-SCANNER-HARDENED.md:23-37`。

### 1.2 不能再说的话

- 不能说 “R4 已经 C5 完成”：缺 qa safety、缺 formal、缺 candidate signoff。
- 不能说 “R3 到 R4 qa 恶化 8→10” 作为主叙事：D-105/D-106 已把它改写为 hardened 9/9/9，旧 8 是 scanner 漏计 artifact。
- 不能说 “继续加负例/扩大挂载就能解决”：R3 证伪单纯加量，R4 证伪单纯换 mount。
- 不能说 “runtime 兜底 = LoRA 学会了 qa”：proof class 必须写 `runtime-gated qa safety`，禁写 `adapter learned qa`。
- 不能把 formal 1800 当“多训一会就好”：R4 已证明 train_health + A/B/D 好看不代表 qa safety。

## 2. 大鸟瞰图

```
D-106 root-cause baseline + D-110 formal-path update
  |
  |-- Phase 0: 冻结当前 truth / 更新路由 / 禁止 formal 误起跑
  |
  |-- Phase 1: 量尺与标签权威修复（D-110: clean for formal-start static gate）
  |       - scanner hardening 进入正式 gate
  |       - primary label conflicts rc0
  |       - true query / unsupported / action-question 三类分账
  |
  |-- Phase 2: runtime query safety gate（主线）
  |       - OpenSpec 定义 RuntimeQueryGuard
  |       - unsupported query 不挂 mutating tools
  |       - true query 只挂 query_* 或直走 query route
  |       - action-question 仍放 action path
  |
  |-- Phase 3: R5 pair-boundary one-shot（旁线）
  |       - authority-clean
  |       - same mount / same device / same slot
  |       - 问状态 vs 发操作 成对
  |       - 失败即停止 data-only qa 修复
  |
  |-- Phase 4: D-085 gate semantics 重拍（D-108: Option B）
  |       - adapter-only qa 失败可接受，但必须写 fail_accepted_under_B
  |       - runtime-gated qa safety 是候选晋级另门
  |       - dual-track candidate 不自动成立
  |
  |-- Phase 5: formal 1800 evidence run（run-auth + realtime gates 后）
  |       - Launch Packet 六件
  |       - host baseline
  |       - watchdog --armed
  |       - eval manifest freeze
  |
  |-- Phase 6: C5 exit package
          - model candidate / runtime safety / proof class 分层 receipt
          - dynamic/fused/quantized parity 规划
          - handoff to C6 / UIUE / voice / demo-golden
```

## 3. C5 “结束”的定义

这里的 “C5 结束” 定义为 **C5 LoRA 阶段可关闭，并把候选交给后续 C6/端侧/演示验收**，不是项目整体 V-PASS。

### 3.1 C5 结束必须满足

| Gate | 必须证明 | Proof class |
| --- | --- | --- |
| G1 model behavior | A/B/D 达锁定门，且无新增工具名幻觉扩散 | local/integration eval |
| G2 qa safety | adapter-only qa=0，或 D-085 经正式重拍允许 runtime-gated qa safety=0 | local/integration/runtime，按路线分层 |
| G3 authority hygiene | scanner hardening + label authority conflict gate 无 P0 | local/static + targeted tests |
| G4 formal candidate | 若仍需要 formal 1800：正式 run 完成、receipt 完整、eval manifest frozen、host/watchdog 证据齐 | local train/eval artifacts |
| G5 candidate signoff | 明确 `lora_candidate` 状态、adapter sha、basis、non-claims；R-L17 只能从 `candidate signoff unsigned` 变为 signed，不能复用 route-only R7 当 candidate signoff | project decision receipt |
| G6 downstream handoff | C6/UIUE/voice 只拿到分层后的候选，不继承假绿 | docs + receipt |

### 3.2 C5 结束不包含

- 不包含 C6 acceptance。
- 不包含 R-L17 candidate signoff，除非另有候选级 human-owner receipt。
- 不包含 UIUE merge 完成。
- 不包含真实 ASR/TTS、mobile/true-device、live API。
- 不包含 V/S/U-PASS。
- 不包含 “客户现场演示最终体验完成”。

这些是 C5 之后的验收或产品化阶段。

## 4. Phase 0 — 基线冻结与误起跑防线

### Goal

让所有后续 worker、commander、新窗口都从 D-110/D-108 后态出发，同时保留 D-106 的 qa root-cause 结论，不再从 `CURRENT.md` 的 R3 in-flight 旧状态出发。

### Scope in

- 更新/引用本 baseline。
- 刷 `docs/CURRENT.md` 的 C5 当前态（若另开任务授权）。
- 在后续派单写明 formal 1800 只是 evidence run，需 `run-auth` + realtime launch gates。

### Scope out

- 不改代码。
- 不生成新训练数据。
- 不训练。
- 不改 D-085 gate semantics。

### Acceptance

- 新派单必须写：`formal 1800 evidence run only; candidate_status=unsigned; run-auth + host baseline + watchdog real pid required`。
- 新 closeout 必须分层：`train_health / behavior gate / candidate-product gate`。
- 引用 qa 数字必须用 hardened 四数，不再单报旧 adapter 8/10。
- R-L17 一律写成 `route-only signed; candidate signoff unsigned`，直到候选级 receipt 改写。

### Evidence

- `docs/CURRENT.md` 若仍写 R3 in-flight 或旧 HOLD 口径，只当 router，不作当前事实源。
- D-106 是 qa root-cause baseline：`docs/commander-log/decisions.md:794-800`；D-108/D-110 是 formal path 最新裁决锚：`docs/commander-log/decisions.md:815-844`。

## 5. Phase 1 — 量尺与标签权威修复

### Goal

先让 “判断系统” 自己可靠，再允许任何新数据或新训练进入主线。

### Work items

1. **Scanner hardening 正式化**  
   把 R5 hardened rule 变成 repo 内可复跑 gate：expected=[] 时任何 observed tool call 都 fail；invalid tool name 与 actuation 分账。

2. **Label authority conflict 清零**  
   先处理 6 个 primary qa/qneg/guard 冲突，尤其 `现在音量是多少`：应走 `query_current_volume`，不是 `NO_TOOL`。  
   R5 authority audit 已给口径：改 absent-query counterfactual 侧，不改 qguard/query 侧。

3. **Default-scope canonical 拍点**  
   天窗/遮阳帘类 no-arg vs `position=全车`、`value=LITTLE` 必须统一；这不是模型能学会的“歧义”，是标签一致性问题。

4. **Default-scope current-head gate**  
   W34 证明 default-scope 核心实现和三道机械门在当时 local pass，但历史 receipt 绑定旧 head 且当前树 dirty。候选晋级前必须在最终 candidate head 重跑 `make verify-default-scope` 或三脚本等价门，并把 runtime `scope_origin` 语义和 R2b data 面分账。

   > 🔴 **AMEND（D-109，2026-07-05）**：本项（W34 current-head 重跑）**归 candidate-promotion gate，不是 Phase 1 completion gate**——Phase 1 时尚无 final candidate head（formal 训练才产），此项在 Phase 1 不可满足。**Phase 1 completion 只负责 default_scope canonical 决策（磊哥 LEIGE_KEY）+ label authority conflict 清零（真 manifest rc0）**；W34 current-head rerun 在 final candidate head/data/adapter sha 冻结后（Phase 5/6 candidate promotion）执行。依据 `redteam/phase1-audit-round2-final.md` E + `grill/phase4b-formal-decompose-grill.md §5`。

5. **Gate 输出四分账**  
   `expected-empty any_tool_call_fail`、`actuation_fail`、`invalid_fail`、`query_expected_actuation` 分开报。

### Stop conditions

- 任何 identical input 在同一 train/eval 面仍有 conflicting expected：停止生成/训练。
- scanner 只能在 run-dir 一次性脚本里跑，未进入可复跑 gate：不能宣称量尺已修。
- default_scope 拍点缺失时，相关 family 的 R5 pair 不得进入训练包。
- default-scope 只引用旧 receipt 或 R2b data_ready，不在 final candidate head 重跑：不得用于 candidate promotion。

### Acceptance

- `R5-SCANNER-HARDENED.md` 的规则被迁入 repo gate 或明确的 run-dir reusable script。
- `R5-LABEL-AUTHORITY-AUDIT.md` 列出的 P0/P1 冲突有裁决表。
- 针对 `现在音量是多少` 的测试能证明 query authority 与 absent-query counterfactual 不再同句冲突。
- final candidate head 上 default-scope 三门或 `make verify-default-scope` 重新通过，并绑定 head/data/receipt。

### Evidence

- Scanner 规则：`R5-SCANNER-HARDENED.md:23-37`。
- Label authority 6 冲突：`R5-LABEL-AUTHORITY-AUDIT.md:7-24`、`R5-LABEL-AUTHORITY-AUDIT.md:73-75`。
- `现在音量是多少` 裁决：`R5-LABEL-AUTHORITY-AUDIT.md:9-24`、`R5-LABEL-AUTHORITY-AUDIT.md:92-110`。
- Default-scope current-head 风险：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/W34-DEFAULT-SCOPE-APPLY-STATUS.md:12-15`、`:133-139`。

## 6. Phase 2 — Runtime Query Safety Gate（主线）

### Goal

把 query/status 安全边界从 “让 adapter 在大工具面里自判不出手” 改成 “runtime 先裁掉危险 mount 面”。

### Why now

D-106 的核心教训不是 “LoRA 完全不行”，而是 **adapter 的 actuation prior 太强，query/status 安全边界不适合继续只靠 SFT 学**。项目原始铁律也是规则吃 80%、LLM 碰 20%、安全检查是代码。

### Proposed contract

新建或扩展 OpenSpec change，定义 `RuntimeQueryGuard`：

| 输入类型 | Runtime 行为 | Model mount |
| --- | --- | --- |
| true query：C1 有 `query_*` | 直走 query route，或只挂对应 query tool | 不挂同族 mutating tools |
| unsupported status query：C1 无 query 能力 | 返回 unsupported/readback，不让模型看到 mutating tools | 空或安全 fallback |
| action-question：如“能不能帮我打开 X” | 视为 action intent，进入正常 action route | 挂 mutating tools |
| ambiguous query/action | clarify，不默认动作 | 最小安全 mount |

### W50 live-loop supplement

Phase 2 不能只写成 “query guard prompt 改造”。W50 把 main runtime 断点拆得更硬：

- 当前真实 app 闭环只覆盖默认 `打开空调`，不能 claim `UIUE 输入文本 -> Qwen+LoRA -> 10 族正确显示`。
- 最小 runtime 设计是 `DemoNLURouter + full contract runtime bundle + D-domain parser/normalizer + 10-family state/display bootstrap + RuntimeAdapterMountReceipt`。
- 慢路模型加载前必须有 `RuntimeAdapterMountReceipt`：绑定 code/data basis、base/tokenizer/config/tool-catalog/prompt/decode/receipt；缺任一项只能 `BLOCKED/PARTIAL`，不能 fallback 到 base model 或 fake local green。
- UI 手输 10 条可见 card/readback 最高只是 `operator-pass`；不等于 model behavior、LoRA candidate、mobile、true-device 或 V-PASS。

### Work items

1. OpenSpec propose：定义可观察行为、三类 query/action-question 场景、proof class 边界。
2. Runtime route/mount preflight：在模型前过滤或收窄工具面。
3. Harness：用同一组 qa cross-track cases + T1 true_query/action_question 运行 runtime path，而不是只跑 adapter prompt path。
4. Receipt：输出 `runtime-gated qa safety`，并明确 non-claim：`adapter learned qa = false/unknown`。
5. Live-loop 接线：补 full demo bundle、D-domain parser/normalizer、10-family state/display bootstrap、`RuntimeAdapterMountReceipt`，并把 adapter/basis 信息留在 mount receipt，不能塞进 public UI payload。

### Acceptance

- runtime path 下 qa safety total = 0。
- true query guard 达 10/10。
- action-question control 达 18/18 或至少不低于 R3 水位，并解释任何差异。
- A/B/D action path 不因 query guard 被误拒。
- receipt 禁止写 “LoRA 学会 query no-call”。
- 10-family local/integration loop：每族 exactly-one frame，经 C3 写 mock state，payload 有对应 card + 中文 readback。
- slow path 若涉及 LoRA：`RuntimeAdapterMountReceipt.mount_verdict=PASS`，且 basis/sha/manifest 全字段绑定。

### Stop conditions

- 若 OpenSpec 未对 `query_*`、unsupported、action-question 三分给出 SHALL 场景，不实装。
- 若 action-question 被误拒，不能晋级 safety gate。
- 若实现只改 prompt、不改 route/mount，不能算 runtime safety。
- 若 `ContentView` 仍以 `singleCommandDemoDefault` 作为 app 默认，不能 claim 10-family live loop。
- 若训练占卡或 host memory constrained，禁止加载模型/推理；只做静态/path/sha preflight。
- 若 mount receipt 未 PASS，慢路只能 `BLOCKED/PARTIAL`。

### Evidence

- R5 redteam 推荐 B runtime guard 主线：`R5-STRATEGY-REDTEAM.md:12-16`、`R5-STRATEGY-REDTEAM.md:100-154`、`R5-STRATEGY-REDTEAM.md:202-232`。
- R5 grill 已把 runtime 兜底列为 R5-2，且要求 proof class 分层：`docs/c5-training-readiness-grill/f044-r5-grill-2026-07-05.md:52-61`。
- W50 live-loop P0 断点与最小设计：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/W50-LIVE-LOOP-WIRING-DESIGN-v2.md:14-23`。
- W50 mount receipt stopline：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/W50-LIVE-LOOP-WIRING-DESIGN-v2.md:81-136`。
- W50 proof cap：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/W50-LIVE-LOOP-WIRING-DESIGN-v2.md:168-199`。

## 7. Phase 3 — R5 Pair-Boundary One-Shot（旁线）

### Goal

给数据-only 路线最后一次公平机会：不是再堆孤立负例，而是验证 “同 mount/同 device/同 slot 下，问状态 vs 发操作的强对比对” 是否能把 qa 拉到 0。

### Hard framing

R5 是 **falsification experiment**，不是新主线。失败后停止 data-only qa 修复，不再 R6/R7 堆量、换 mount、加 epoch。

### Work items

1. Phase 1 authority-clean 后，针对 D-106 失败族生成 pair ledger。
2. 每个 family 至少覆盖：
   - unsupported status-question -> `NO_TOOL` 或 unsupported
   - true query family -> `query_*`
   - same noun imperative/action -> mutating tool
   - action-question control -> mutating tool
3. 同 pair 使用同 mount，同 device，同 slot/同话术邻域，只改可见 discriminator。
4. 加 exact tool-name precision gate：invalid alias、valid-neighbor misroute 分账。
5. 跑一轮 600 iters 短训，保留 R3/R4 同款 knob，除非 Phase 4 重拍。

### Acceptance

- qa adapter expected-empty any_tool_call_fail = 0。
- true_query_guard = 10/10。
- action_question_control 不低于 R3 水位，理想 18/18。
- A/B/D 不跌破 D-085。
- tool-name hallucination 不扩散。

### Stop conditions

- Phase 1 authority 未清零：不生成 R5。
- R5 跑后 qa 未归零：停止 data-only qa 修复。
- T1 比 R3 退化：停止 data-only qa 修复，转 runtime/架构讨论。
- A/B/D 跌破门：R5 不可作为 candidate，保留 R3/R4 asset 复议。

### Evidence

- R5 mechanism 建议：authority-clean、same mount/device/slot、tool-name precision guard，见 `R5-QA-MECHANISM-ATTRIBUTION.md:19`、`R5-QA-MECHANISM-ATTRIBUTION.md:196-248`。
- R5 redteam：Route A 成功率估 35%，只允许一次，见 `R5-STRATEGY-REDTEAM.md:38-90`。

## 8. Phase 4 — D-085 Gate Semantics 重拍

### Goal

正式决定 “C5 candidate 的 qa=0 到底必须由 adapter-only 满足，还是允许 runtime-gated qa safety 满足”。

### Options

| Option | 解释 | 何时成立 | 风险 |
| --- | --- | --- | --- |
| A adapter-only | 维持 D-085 原门：adapter prompt path qa=0 才 candidate | R5 one-shot 成功 | 可能继续被小模型固有 actuation prior 卡死 |
| B runtime-gated | A/B/D 由 model candidate gate 证明，qa 由 runtime safety gate 证明 | Phase 2 runtime guard 过门 | 治理上必须明写 model defect 由 runtime 兜底，不可假装 LoRA 学会 |
| C dual-track | R5 one-shot + runtime guard 同时完成，candidate receipt 分层 | 默认推荐 | 文档/receipt 若写不好会混 proof class |
| D architecture/base switch | 换基座、换架构、call/no-call classifier、constrained decoding、DPO 等 | R5 失败且 runtime gate 被否决 | 重开全链路，成本高 |

### Recommended baseline

默认走 **C dual-track**，但主权重给 **B runtime-gated**：

- R5 是最后一次数据-only 证伪试验。
- runtime guard 是 demo/product safety 正解。
- 若 R5 过，candidate 更干净；若 R5 不过，仍可在 B 口径下推进，但必须诚实写 non-claim。

### Acceptance

- D-085 修订或解释有明确 decision entry。
- Candidate receipt 字段拆分：
  - `model_behavior_gate`
  - `adapter_qa_gate`
  - `runtime_qa_safety_gate`
  - `candidate_status`
  - `non_claims`
- formal 1800 是否仍需跑、跑哪个 adapter/recipe，有明确 basis。
- D-085 重拍不能替代 R-L17 candidate signoff；它只能定义 qa gate 语义，不能签候选。

### Evidence

- D-106 strategy options：A 35%、B 75%、C 双管，见 `docs/commander-log/decisions.md:794-800`。
- R5 redteam 默认路线：先拍 qa 是否允许 runtime-gated safety，见 `R5-STRATEGY-REDTEAM.md:220-232`。

## 9. Phase 5 — Formal 1800 Evidence Run

> 2026-07-06 早补记：本节仍是 Phase 5 行为边界；当前 launch-adjacent 实况见 §0.4。§0.3 的 host-HOLD/not-launched 仅为 2026-07-05 historical 状态，已被 §0.4 full-envelope/no-auto-watchdog tail1200 live 态 supersede。当前 active `090552` 是 checkpoint1200 weight-init new trajectory，不是真 resume、不是 frozen formal completion、不是 candidate/C6/V-PASS/behavior pass。

### Goal

在 gate semantics 明确后，启动 formal 1800 **evidence run**；formal 只验证“被冻结配方在长训下是否训练健康、A/B/D/T1 是否维持、qa 在 B 口径下如何分层”，不能拿来证明 adapter 已学会 qa，也不能替代 candidate signoff。

### Preconditions

- Phase 1 完成：scanner + label authority 清楚；D-110 后当前状态 = clean for formal-start static gate。
- Phase 4 明确允许某一路径进入 formal；D-108 已拍 B。Phase 2 RuntimeQueryGuard / Phase 3 R5 不再是 formal 起跑硬前置，但仍是 candidate signoff / falsification 轨。
- `FORMAL-LAUNCH-CONDITIONS.md` 六条件全部由 launch owner 填 verdict，且 W27/W47/W52 无 open P0/P1。
- Launch Packet 六件齐：
  - `FORMAL-LAUNCH-CONDITIONS.md`
  - `formal-config.diff`
  - `formal-host-baseline.json`
  - `formal-watchdog-contract.md`
  - `formal-eval-manifest.json`
  - `formal-receipt-template.md`
- host baseline：swap/free 按 D-094/D-102 条款，不可静默放宽。
- watchdog --armed 真 pid，LR 450 schedule rc0；watchdog draft/配置必须部署进 run package，不能只引用未接线草稿。
- 起跑必须消费 frozen trainpack sha；若重生成 trainpack，必须重新跑 Phase1 gates、sha/row gate 和 Launch Packet freeze。
- 起跑前必须明示 worktree dirt 分账：existing `Core/Training` dirt 不得进入 frozen-trainpack claim，也不得静默参与数据再生成。

### Run policy

- 不训中并行推理/eval/browser/Xcode。
- 不用 checkpoint 中测杀训练，除非 watchdog stopline 触发。
- checkpoint 只做 post-run 留档和诊断，不 cherry-pick。
- 任何 host redline、nonfinite、no-progress、memory pressure 触发都记 receipt，不临场改门。
- UN/swap/no-progress 是环境进展 stop，receipt 写 `PARTIAL`，不能误报成 model/train-health fail。
- 不临场“优化” batch/rank/layers/seq/target keys/cache/wired limits；任何此类改动都必须进入 `formal-config.diff`，并把本轮改判为 config-drift branch。

### Acceptance

- formal 1800 完成，train receipt 完整。
- behavior eval 使用 frozen manifest。
- A/B/D pass。
- qa 按 Phase 4 B semantics 分层记录：`adapter_qa_gate=fail_accepted_under_B` 或有新证据证明 adapter qa=0；无论哪种都不得写 `adapter_learned_qa=true`，除非另有独立 proof 反转。
- T1 true query/action-question pass 或明确分层失败。
- formal receipt 给出 adapter sha、basis、proof class、non-claims；candidate receipt 另起，默认 `candidate_status=unsigned`。

### Stop conditions

- Phase 1/D-110 或 Phase 4/D-108 被新证据反转：formal HOLD。
- Launch Packet 缺任一件：formal HOLD。
- host baseline 不达标：按 D-094 上抛，不自改。
- formal 训后 qa/T1/A/B/D 任一 hard gate fail：不得 candidate signoff。
- `adapter_learned_qa=true`、C6 acceptance、V-PASS、demo readiness 等词出现在 formal receipt 中且无对应 proof：receipt 退回重写。

### Evidence

- D-093 起跑硬门与 Launch Packet 六件：`docs/commander-log/decisions.md:706-712`。
- D-094 host 门：`docs/commander-log/decisions.md:714-716`。
- D-100 formal 条件式授权只在 R3 全绿时成立，后续 R4/D-106 已使其 HOLD：`docs/commander-log/decisions.md:750-752`。
- D-108/D-110 已更新 formal path：`docs/commander-log/decisions.md:815-844`。
- Frozen Launch Packet 边界：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-phase1-scanner-authority-gates/eval/launchpacket-frozen/FORMAL-LAUNCH-CONDITIONS.md:20-33`。
- Frozen host/watchdog 边界：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-phase1-scanner-authority-gates/eval/launchpacket-frozen/formal-host-baseline.json:12-35`；`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-phase1-scanner-authority-gates/eval/launchpacket-frozen/formal-watchdog-contract.md:7-56`。
- W27/W33 风险基线：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/W27-FORMAL-TRAIN-REDTEAM.md:11-22`；`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/W33-MEMORY-OPT-PREMORTEM.md:11-20`、`:173-234`。

## 10. Phase 6 — C5 Exit Package

### Goal

把 C5 收成一个可移交的候选包，而不是把短训/运行时/产品验收混成一个模糊 “完成”。

### Deliverables

1. **C5 Candidate Receipt**
   - adapter sha / basis ids / training config / eval manifest
   - model behavior gate
   - adapter qa gate
   - runtime qa safety gate
   - runtime adapter mount receipt（若声称 live-loop slow path）
   - formal run status
   - R-L17 candidate signoff state
   - non-claims

2. **C5 Lessons + Gate Updates**
   - scanner hardening
   - label authority gate
   - query/action-question split
   - pair-boundary one-shot rule
   - proof-class language

3. **Downstream Handoff**
   - to C6 bench：which adapter and which gate semantics
   - to C6 construction：which cases/scorer/BehaviorClass/replay/readback/fingerprint can be built before candidate
   - to C6 comparison：blocked until signed candidate + explicit run authorization
   - to runtime/UIUE：what safety is runtime-owned
   - to voice/live loop：what remains blocked

4. **OpenSpec/Docs Sync**
   - CURRENT route board refreshed
   - decisions D-entry added
   - run-dir status board closed or superseded
   - any active change tasks updated

### C5 Exit Status Vocabulary

| Status | Meaning |
| --- | --- |
| `C5_FORMAL_TRAIN_DONE` | formal run done, not necessarily candidate |
| `C5_MODEL_BEHAVIOR_PASS` | A/B/D pass under frozen eval |
| `C5_RUNTIME_QA_SAFETY_PASS` | runtime guard proves qa safety, not adapter learning |
| `C5_ADAPTER_QA_PASS` | adapter-only qa=0 |
| `C5_CANDIDATE_SIGNED` | project decision says C5 candidate is accepted for downstream |
| `C5_PARTIAL_QA_BLOCKED` | behavior asset strong, qa unresolved |
| `C5_ROUTE_ONLY_READY_FOR_C6_CONSTRUCTION` | route-only R7 allows C6 construction prep, not candidate comparison |

## 11. 并行工作池

### 11.1 可并行，且不抢 C5 训练资源

| Lane | 可做什么 | 禁止什么 | 依赖 |
| --- | --- | --- | --- |
| UIUE merge prep | 按 `docs/superpowers/plans/2026-07-05-uiue-merge-battle-plan.md` 做 fresh-main selective port 计划、schema/fixture drift 复核 | 不直接 merge UIUE 旧树；不碰 `Core/Training`；不声称 UIUE complete | C5 formal artifacts frozen 前只做 read-only/prep |
| Runtime query guard + live-loop design | OpenSpec propose、harness 设计、case matrix、mount receipt、10-family payload/state/display bootstrap | 未 agree before build 不实装；不把 proof 写成 adapter pass；不在训练占卡时加载模型 | Phase 2 主线 |
| C6 construction prep | 四层 scorer、manifest、case selector、BehaviorClass SSOT、replay/readback/fingerprint、L6 seed recoding方案 | 不跑 C6 acceptance/comparison，不拿 L6/R2b 53-case 原样当 denominator | route-only R7 已允许 construction；model comparison 等 signed candidate |
| Voice C7 design | ASRBackend/TTS 合同、system SFSpeech primary preflight、fake backend、normalizer/confidence gate、TTS premium voice preflight | 不做 dependency adoption；不声称 ASR/TTS ready、offline ready、mobile/true-device/V-PASS | 可 spec-first；真链路等 C7 |
| Live-loop slow path prep | `RuntimeAdapterMountReceipt`、basis registry、Qwen/LoRA load preflight schema、no-fallback wording | 不跑推理；不声称 candidate/model behavior | 等 host 空闲与 adapter basis |
| Macro scene/state | `scenario-macros.yaml`、Core `SceneMacroMatcher`/macro policy、mock state readback、presentation mapping | 不让 LLM 自由多工具规划；不把 UIUE `MultiCallSequencer` 当 Core executor；不把 mock simulator 证据升格 mobile/live | 可独立 spec-first |
| Launch infra | formal packet 模板、watchdog replay、host baseline 命令、receipt schema | 不启动训练；不改 host 门 | Phase 5 前置 |
| Docs/governance | CURRENT 刷新、lessons learned、commander handoff、receipt vocabulary | 不把 stale docs 写成 SSOT | 随时 |
| Data salvage prep | 旧文本 projection ledger、judge rubric、DataGate plan | 不直接混入 R5/正式训练 | Phase 1 后才可进训练候选 |

### 11.2 必须串行或等拍

- D-085 gate semantics 重拍：必须等 Phase 1/2/3 证据，不让 worker 自拍。
- Formal 1800：必须等 Phase 4 + Launch Packet + host baseline。
- UIUE merge 实施：建议等 C5 formal artifacts 或 runtime safety contract 稳定，避免 shared payload 与模型候选同时漂移。
- C6 construction：可在 route-only R7 + accepted OpenSpec 下推进；但 proof cap 是 construction/local/static。
- C6 acceptance/comparison：必须等 C5 candidate signoff + explicit run authorization，不拿 R4/R5 partial 或 L6 seed 直接跑成产品验收。
- Voice implementation/adoption：C7 spec-first 后再做；不能从现有 TTS seam 或 mock UIUE 得出 voice-ready。
- M2 destructive cleanup：需要磊哥明确授权，不在 C5 自动推进里顺手删。

## 12. 建议派工拓扑

| 角色 | 任务 | 输出 |
| --- | --- | --- |
| commander | 维护 D-entry、裁决 Phase 4、亲核 receipts | decisions + final verdict |
| worker-data | Phase 1 label authority + R5 pair ledger | conflict table + pair data spec |
| worker-runtime | Phase 2 OpenSpec + harness + route/mount design | RuntimeQueryGuard proposal + tests |
| worker-eval | scanner hardening + T1/A/B/D/qa harness | reproducible gate scripts |
| worker-infra | Launch Packet + watchdog + host baseline | formal launch packet |
| worker-uiue | UIUE selective-port prep | drift table + no-touch list |
| worker-c6 | C6 construction-only prep | four-layer shape + denominator + no-acceptance receipt |
| worker-voice | C7 voice spec-first | ASRBackend/TTS contract + proof caps |
| worker-macro | SceneMacro spec-first | macro policy + terminal snapshot/readback gates |
| critic/redteam | Phase 2/3/4 对抗审 | risk table + stopline verdict |

并行规则：Phase 1/2/UIUE/infra/docs 可以并行；Phase 3 依赖 Phase 1；Phase 5 依赖 Phase 4；candidate signoff 只能由 commander/磊哥拍，不下放。

## 13. 风险与防线

| Risk | 典型误判 | 防线 |
| --- | --- | --- |
| 训练健康外溢 | loss 好看就写 C5 done | 三层报告：train_health / behavior / candidate |
| 量尺再次错 | scanner 旧口径或 stale bundle 进决策 | scanner hardening + manifest/basis sha |
| label 冲突残留 | 同句双标签让模型背锅 | identical-input expected conflict gate |
| runtime 偷换 proof | runtime guard 过了写成 adapter 学会 | receipt 字段分层 + non-claims |
| live-loop 假绿 | 单 AC app 闭环写成 10-family Qwen+LoRA live loop | W50 10-family gates + `RuntimeAdapterMountReceipt` |
| adapter/basis 漂移 | slow path 载入了不同 code/data/model/tool surface | basis ids + sha + formal manifest fail-closed |
| LoRA 风险低估 | “参数少/冻结基座”写成不会遗忘或不会学偏 | external LoRA/forgetting citations + frozen eval + no candidate signoff without runtime/R-L17 |
| MLX unified-memory 低估 | process alive 或 MLX peak 写成宿主稳定 | fresh host baseline + OS memory/swap/wired evidence + watchdog PARTIAL stop |
| GitNexus/工具索引外溢 | reindex rc0 写成代码/launch 进展，或在 host-HOLD 窗口反复 reindex 加压 | GitNexus 只作 tooling receipt；AGENTS/CLAUDE generated block 已更新一次，本轮不再 reindex；不用 GitNexus 输出替代 runtime host gate |
| frozen packet 被重生成污染 | 已冻结 sha 被起跑前 dirty code/data 再生成覆盖 | trainpack sha/row gate；若重生成则重新 Phase1 + freeze，不继承 packet |
| R5 无限循环 | 失败后继续 R6/R7 堆数据 | one-shot stopline |
| UIUE 抢线 | stale UIUE 树 merge 漂移污染 C5/shared payload | fresh-main selective port + no-touch Core/Training + 10-family consumer smoke |
| formal 误起跑 | 想靠 1800 解决未定义 gate，或把 formal 当 candidate | D-108 B 只解 formal evidence run；candidate signoff 另门 |
| C5/C6 混账 | construction receipt 或 L6 seed 写成 C6 acceptance | construction/comparison 双 lane + signed candidate hard gate |
| voice proof inflation | TTS seam/mock UI 写成 ASR/TTS ready | C7 ASRBackend/TTS 独立 proof，UIUE mock 不替代 voice |
| macro executor 幻觉 | UIUE 展示 sequencer 写成 Core 多步执行 | Core deterministic macro + C3 single-tool gate/readback |

## 14. 今日/下一步最小动作

如果只做最小推进，顺序如下：

1. **保持本 baseline 为 commander 起手读物**；本版已吸收 D-110 / Phase1 clean / Launch Packet frozen。
2. **起 formal 前只做实时门**：quiet workers / fresh host baseline / watchdog real pid / trainpack sha+row gate / first real LR runtime check。
3. **run-auth 已接受；formal 启动前先解 host gate**：关闭重 GUI 后 fresh host PASS，或磊哥显式 `host-waiver-key`；之后才可指派 high Codex executor 启动 formal 1800 evidence run，且只消费 frozen `R3-QNEG-clean` trainpack；不重生成数据。
4. **训后只写 formal receipt**：train_health、A/B/D、T1、qa(B口径)、adapter sha、non-claims；candidate receipt 另起。
5. **并行但不抢资源**：Phase2 RuntimeQueryGuard spec、C6 construction prep、UIUE selective-port prep、voice/macro spec-first 可以做；formal 起跑/运行期间禁止 browser-heavy、Xcode、model inference、C6 eval。
6. **candidate 晋级另门**：RuntimeQueryGuard proof + W34 final-head rerun + R-L17 candidate signoff + C6 comparison explicit run-auth。

当前不建议做：

- 不建议把 formal 1800 写成 candidate run 完成；它只是 evidence run。
- 不建议继续只堆 unsupported-query 负例。
- 不建议继续只换 mount 或扩大 mount。
- 不建议起跑前重生成 trainpack 或静默吃进 Core/Training dirt。
- 不建议直接 merge UIUE。
- 不建议把 R4/R3 adapter 写成 C5 candidate。
- 不建议把 C6 construction、UIUE fixture、voice/TTS seam 或 macro display proof 写成产品验收。

## 15. References

- `docs/commander-log/decisions.md:650-724` — D-080~D-095：短训门、R2/R2b、正式训练硬门与失败分诊。
- `docs/commander-log/decisions.md:733-800` — D-097~D-106：mount-invalid 翻案、R3/R4、scanner/authority 翻案、D-106 战略拍点。
- `docs/commander-log/decisions.md:815-844` — D-108~D-110：Phase4 B、split gates、R3-QNEG-clean、Phase1 cleanup、default_scope Scheme A。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/R5-SCANNER-HARDENED.md:23-37` — hardened qa 真数。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/R5-LABEL-AUTHORITY-AUDIT.md:7-24` — label authority 主冲突与修法。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/R5-QA-MECHANISM-ATTRIBUTION.md:196-248` — R5 pair-boundary 配方约束。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/R5-STRATEGY-REDTEAM.md:220-232` — 推荐默认路线与禁行路线。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-phase1-scanner-authority-gates/PHASE-CLOSURE-STRATEGY-2026-07-05.md:16-23`、`:45-55` — Phase1/Phase4 到 formal 的关键路径与 run-auth 链。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-phase1-scanner-authority-gates/redteam/phase1-cleanup-audit.md:11-20`、`:145-149` — Phase1 cleanup GREEN 与 Core dirt caveat。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-phase1-scanner-authority-gates/eval/launchpacket-frozen/FREEZE-REPORT.md:20-44` — Launch Packet 六件 freeze status 与实时缺口。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-phase1-scanner-authority-gates/eval/launchpacket-frozen/FORMAL-LAUNCH-CONDITIONS.md:20-33` — frozen formal launch six conditions 与 stop lines。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-phase1-scanner-authority-gates/eval/launchpacket-frozen/formal-host-baseline.json:12-35` — host baseline fail-closed policy 与实时字段。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-phase1-scanner-authority-gates/eval/launchpacket-frozen/formal-watchdog-contract.md:7-56` — watchdog contract 非 armed 边界与实时字段。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-phase1-scanner-authority-gates/eval/launchpacket-frozen/formal-eval-manifest.json` — formal eval manifest；`adapter_learned_qa=false` / `candidate_status=unsigned`。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/W27-FORMAL-TRAIN-REDTEAM.md:11-22`、`:192-220` — formal launch P0/P1 redteam 与 required packet。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/W33-MEMORY-OPT-PREMORTEM.md:11-20`、`:71-93`、`:173-234` — MLX/unified-memory/host baseline premortem、external source map、launch checklist。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/W47-R3-REDTEAM.md:8-16`、`:202-220` — R3 qneg redteam、shorttrain start/PASS rules。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/W55-R4-REDTEAM.md:8-15`、`:97-127` — R4 mount-isomorphism redteam 与 formal release hard stoplines。
- `docs/c5-training-readiness-grill/f044-r5-grill-2026-07-05.md:35-115` — R5 grill skeleton 与 landing 守门。
- `docs/superpowers/plans/2026-07-05-uiue-merge-battle-plan.md:1-53` — UIUE selective-port 计划边界。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/W34-DEFAULT-SCOPE-APPLY-STATUS.md:12-15`、`:133-139` — default-scope current-head promotion 边界。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/W48-GRILL-RESIDUAL-SCAN-v2.md:16-20`、`:37-43`、`:98-107` — R-L17 candidate signoff、C6 construction/comparison、UIUE/voice/macro 真未决。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/W50-LIVE-LOOP-WIRING-DESIGN-v2.md:14-23`、`:81-136`、`:168-199` — live-loop 断点、mount receipt、10-family proof cap。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/W28-C6-RESTART-ASSESSMENT.md:198-261` — C6 restart 双 lane、L6 seed claim ceiling、post-candidate worklist。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/W24-UIUE-TREE-AUDIT.md:11-22`、`:218-233`、`:259-281` — UIUE stale/high-merge-risk 和 proof cap。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/W37-VOICE-ASR-LINE-ASSESSMENT.md:15-21`、`:137-147`、`:157-170` — voice C7 spec-first、ASR/TTS proof cap。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/W51-MACRO-SCENE-PRERESEARCH-v2.md:13-23`、`:28-30`、`:151-160`、`:192-199` — deterministic macro route、executor gap、voice/display proof cap、reentrancy gates。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/FORMAL-LAUNCH-CONDITIONS.md:10-25`、`:27-36` — formal 六条件与 packet inventory。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/formal-watchdog-contract.md:12-19`、`:29-45`、`:198-213` — watchdog 非授权边界、memory stopline 与部署要求。
- https://arxiv.org/abs/2106.09685 — LoRA paper：低秩适配降低训练参数/显存，不等于行为安全 proof。
- https://arxiv.org/abs/2401.05605 — Scaling Laws for Forgetting：PEFT/LoRA 仍有 catastrophic forgetting 风险，且与 update steps 等相关。
- https://ml-explore.github.io/mlx/build/html/usage/unified_memory.html — MLX unified memory：Apple silicon CPU/GPU 共享同一 memory pool。

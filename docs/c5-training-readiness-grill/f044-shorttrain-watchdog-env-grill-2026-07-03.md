---
authority: grill_in_progress_skeleton_upfront
series: F044-WD
status: locked_2026-07-03（D-046 范式全程：骨架→三 worker xhigh 弹药（WD-AMMO-43/44/45）→四层 15 题全消减→WD-15 第三跑参数 commander 拍；触发=watchdog 两连误杀）
decision_ref: D-077（两连误杀）/ D-078（全消减+第三跑）
basis: CODE-2026-07-03-PR38 + DATA-WAVE1-SUBSTRATE-v3 + F044-shorttrain-run-{171454,172640}+0800 两次 BLOCKED receipt
---

# F044 短训执行环境 grill（watchdog 判据 × 多进程工作站共存）

> 触发事实（数字源=仓外 run 目录一手 artifact，绝对路径，commander 均亲读/亲跑）：run-auth 后两连误杀。第一跑 `memory_fail_threshold_exceeded`：系统 used `21.81`GB 起点（source: 第一跑 watchdog stdout 首轮，run dir `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-shorttrain-run-20260703T171454+0800/`）对比 `22.34`GB 阈（source: 修复前 watchdog `memory_fail_gb` 默认值，工具路径 `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-shorttrain-eval-prep/tools/f044_watchdog.py` 第 53 行；阈值推导=R2 进程 peak `17.868956778`GB × `1.25`，source: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-SHORTTRAIN-EVAL-PREP.md` §6.3 Resource Budget 表）=口径混用，~2min 触发。修复后第二跑 `system_memory_fail_threshold_exceeded`：辅助阈 `30.0`GB（source: 同 watchdog 文件修复版第 54 行 `system_memory_fail_gb`），val 阶段系统 used 已 `29.52`GB（source: 第二跑 watchdog stdout 第三轮，run dir `.../F044-shorttrain-run-20260703T172640+0800/`），train step 上量即触发，~4min。训练本身两次均健康：两跑 preflight `records=4878 / trainable_tokens=119579`（source: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-shorttrain-data-ready/F044-DATA-READY-RECEIPT.md` Gates 表 + commander 独立复跑 log，两者一致）、iters 600 开训、无 mlx OOM。

## 问题面（四层，D-046 范式全展开；xhigh worker 弹药拓展 corner case × C5 现状 × openspec 体系 × 愿景）

### 层1 技术判据（watchdog 本体）
| ID | 问题 | 弹药源 | 状态 |
|---|---|---|---|
| WD-1 | 系统内存辅助判据去留与形态 | %43 联网 pre-mortem | **locked（commander 拍，三选一=禁用 hard kill）**（WD-AMMO-43 §WD-1，本地+外证：psutil 文档「available 才是可给进程的量」/Apple Activity Monitor 用 Memory Pressure 非 used/MLX 官方 get_peak_memory=框架自身 accounting；第二跑 used 34.07>32GB 物理铁证口径污染）：**system used 永不单独 kill trainer**；hard 只留 process peak 22.34（metrics 同口径）+ Metal OOM/nonfinite/no-update/adapter missing/wall clock；系统级降为 **pressure warning + 降载动作**（先降 worker/浏览器不杀 trainer）；组合 pressure 机械判据（red/critical+swap 升+progress 停滞才 BLOCK）记 P3 后补。「继续调阈=把口径错误往后推」。 |
| WD-2 | process peak 判据盲区 + watchdog 自愈 + receipt 结构 | %44 自证+盲区分析 | **locked**（弹药=WD-AMMO-44 §WD-2）：① train_report 每 10 iters 写（mlx TrainingArgs 默认，%44 实测），间隔内 Metal OOM 由 train.log OOM 扫描+process_exited_missing_adapter **事后收尸**接手——非假绿但**不称 preemptive**；watchdog interval 60→**15s** 加快收尸；② watchdog 自愈=shell supervisor（崩 3 次重启→杀 trainer 写 SUPERVISOR_BLOCKED receipt），零新 Python；③ 🔴 receipt「evidence None」= **commander jq 读法错**（schema 顶层 `.evidence` 非 `.trigger.evidence`），%44 live 复读+合成 fixture 双证 evidence 完整；第二跑触发时 `system_memory_used_gb=34.072150016`>32GB 物理=psutil used 语义扭曲实证（source: `jq '.evidence.system_memory_used_gb' /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-shorttrain-run-20260703T172640+0800/F044_SHORTTRAIN_BLOCKED.json`，%44 live 读出记录于 WD-AMMO-44.md:140-144）。 |
| WD-3 | 🐘 9.4h 长跑 × 3 codex worker 内存共存 | %45 本机实测快照 | **locked_with_fix**（WD-AMMO-45 §2，commander 确认）：实测=worker 常驻 RSS 仅 ~1.7GB 非主风险（总 ps RSS 9.2GB / memory_pressure free 74%），主风险=长跑期**突发工具负载**（浏览器/Playwright/build/全仓 rg）；系统 used 口径 34.07>32GB 物理=不可作 hard kill，**降为 pressure warning + 降载动作**；三层停线（训练硬故障杀 / 进程 peak 22.34 杀 / 系统压力 warn→先降 worker 不杀 trainer）；🔴 第三跑期间 swarm 进 **quiet_observer_mode**（%43/44/45 冻结重负载操作，只收 stop/receipt 指令，checkpoint 点才读 metrics）。 |
| WD-4 | 时长/预算重校：两跑实测修正 226s/update 保守账与 checkpoint 预算 | commander 用两跑实测 | **locked**：两跑均死于首个 train_report 前（仅得 val 速率 ~3.6s/batch，第二跑 15/25 用时 54s 推算），**per-update 无实测→维持 R2 保守账**（226s/update、checkpoint50 deadline 11300s）；第三跑首个 train_report 落地后按实际间隔即时重校 wall clock 预算（PREP §6.3 本就要求 checkpoint 重校）。不阻塞第三跑。 |

### 层2 Corner case（长跑环境全景，磊哥点名充分拓展）
| ID | 问题 | 弹药源 | 状态 |
|---|---|---|---|
| WD-6 | macOS 睡眠/锁屏/省电 | %44 | **locked**（WD-AMMO-44 §WD-6，pmset 实查）：AC profile `sleep 0`（且 powerd/Codex 已持 assertion）、电池 profile `sleep 1min` → 第三跑整体包 `caffeinate -is`（防 AC 拔掉/assertion 消失），锁屏/灭屏无害；**不合盖 + AC 保持**（clamshell 未验证不冒险）。可执行 wrapper 已在弹药 §WD-6。 |
| WD-7 | 磁盘与产物 | %44 | **locked**（WD-AMMO-44 §WD-7，df/du 实查）：余量 290GiB vs 预算 <1GiB（adapter 69.8MB×7 checkpoint≈489MB+日志）；ENOSPC→trainer crash→watchdog 收尸路径覆盖；残余风险=部分写入 adapter 无完整性 hash 门（290GiB 余量下接受，记 P3）；wrapper 含 10GiB 起跑磁盘 guard。 |
| WD-8 | 热降频/中断恢复 | %43 联网 + %44 本地 | **locked（全闭）**：本地份（WD-AMMO-44）=tmux detach/codex compact 不杀进程；resume 非严格（仅 load weights strict=False，无 optimizer/RNG/iterator/step state）。联网份（WD-AMMO-43 §WD-8，MacRumors/Wccftech/Tom's 外证 sustained throttle 10-25% 量级 + mlx-examples discussion#997 resume 从 iter 1 记数）：**thermal 不设 hard fail**（10-25% 贴 25% wall headroom 边缘→hard fail 看 checkpoint 进度不只 wall clock）；42375s 保留 envelope + checkpoint 50/100/150 实测重校（慢了=更新 receipt derivation 非静默延长）；中断恢复=首 checkpoint 前重跑，之后 continuation **必须新 run 新 receipt 新 metrics segment**（跨 run 曲线不揉单条）；thermalState telemetry 作 WARN 可选项。 |
| WD-9 | 成功但坏 + eval 资源面 + 衔接判据 | %43 | **locked**（WD-AMMO-43 §WD-9，commander 确认）：F044 PASS 拆三层——**train-health PASS**（exit0+无触发+期望 update 数+finite+adapter 存在+snapshot）→ **artifact PASS**（adapter/config/base/code/data/metrics 全 sha 绑定，缺任一=artifact_unbound 不进 eval；含 num_layers=-1 归一化坑 cite lessons:63）→ **behavior PASS**（A/B/D 阈值）；**exit0≠adapter 可用**；eval 必 **fresh process**（防 MLX cache 串峰值归因）、A+B+D 双模型=128 次生成、首个真实 eval run 建独立预算（暂借 process cap 作 guard）；衔接=5 条件全真才进 eval（train receipt PASS/metrics 无停线/adapter sha+config/basis 全绑/eval 自带 receipt）。 |

### 层3 OpenSpec 体系整合（短训评在项目体系中的位置）
| ID | 问题 | 弹药源 | 状态 |
|---|---|---|---|
| WD-10 | F-044 verdict 决策树预落档 | %45 结合 openspec/ 体系 | **locked**（WD-AMMO-45 §3，commander 确认）：四层状态机预落 run-dir `F044-VERDICT-DECISION-TREE.md`（env_blocked→环境层不判模型 / train_health_failed→loop层不跑 eval / PASS→只解锁 step4 DONE+shorttrain_behavior_gate_pass+下一步 owner 讨论，**不解锁** train-ready/C6/endpoint/正式训练 / FAIL 按 A→训练信号、B→语料自然度、D 或 query→actuation→安全层分层回退+禁抵消）；与 `openspec/specs/lora-training/spec.md`「loss=train_health only、candidate 需 C6 diff/parity/byte parity」对齐。 |
| WD-11 | 短训 adapter 的 basis 治理 | %45 | **locked**（WD-AMMO-45 §4，commander 确认）：开 **MODEL/ADAPTER 候选 lane**（非 live baseline）：`MODEL-F044-SHORTTRAIN-<runid>`，绑 adapter/config/base/tokenizer/code/data/metrics/eval 全 sha（缺任一=artifact_unbound 不得 PASS）；acceptance_stage 封顶 `shorttrain_behavior_gate_pass`；supersede 规则=同 basis 家族内 PASS 可 supersede 旧短训 probe，跨 basis 不静默 supersede，`lora_candidate` 只留给过 C6/parity/endpoint/异源+owner 签的正式候选。 |
| WD-12 | corpus 250 在 C5 spec 体系位置 | %45 | **locked**（WD-AMMO-45 §5，commander 确认）：corpus=C1/C2 派生训练资产**不回写契约 SSOT**；登记 DATA 派生包 `DATA-F044-SHORTTRAIN-v1`（basis=SUBSTRATE-v3+corpus250，不覆盖 v3）；契约缺口走 OpenSpec change 改 C1/C2 再 regenerate；SCALE-PLAN S1-S3=数据生成运行 carrier 非 vehicle behavior spec。 |

### 层4 愿景对齐（demo 北极星）
| ID | 问题 | 弹药源 | 状态 |
|---|---|---|---|
| WD-13 | 短训评的定位校准与 F-044/C6 分工边界 | %43 结合愿景 | **locked**（WD-AMMO-43 §WD-13，cite CLAUDE.md 北极星+CURRENT+lessons T/V 分层）：F044=**双重定位**「wave-1 数据配方有效性验证 + 候选配方晋级门」；PASS 只推进 step4→shorttrain_behavior_gate_pass + owner signoff 讨论，**不回答** train-ready/C6 acceptance/endpoint/V-S-U；A=协议记忆回归底线、B=自然中文配方起效、D=安全泛化不退化 smoke（query→actuation 零容忍），**C6 才能声明完整 bench 不丢脸**——F044 三轴是 C6 的前置 smoke 非替代；PASS/FAIL wording 模板照弹药 §WD-13（不升格措辞已模板化）。 |
| WD-14 | 250 行对 10 族 MVP 覆盖盘点与下一 wave 优先级 | %45 数据盘点 | **locked**（WD-AMMO-45 §6，jq 一手分布，commander 确认）：🔴 **纠偏——10 族顶层已 10/10 触达，没有空白族**（ac 50/seat 50/window 25/door 25/氛围灯 18/sunroof 17/wiper 17/screen 16/volume 16/fragrance 16）；**真空白=class 全 positive**（unsupported/safety/already_state/followup/多意图=0 行）+ 子能力深度（door 只 3 类工具、sunroof 17 intent 各 1 行）。下一 wave 优先级：①负例与不乱控全族补（北极星最怕误控/query→actuation）②高频可见族深挖至 75-100 行 ③位置槽 scanner 全量化进 generator（D3 根治）④炸场族补深带 negative ⑤连续两句多意图独立 lane（C 轴仍 observation 不升门）。 |
| WD-15 | 第三跑参数拍板 | commander 拍 | **locked（commander 拍，全弹药收敛后）**：入口=`runs/.../f044-third-run.sh`（WD-AMMO-44 wrapper 落档：caffeinate -is 包裹 + watchdog supervisor 崩 3 次自愈 + 10GiB 磁盘 guard + trap cleanup）；参数=`PROCESS_PEAK_FAIL_GB=22.34`（主判据，metrics train_report.peak_memory 同口径）/ `SYSTEM_MEMORY_FAIL_GB=999`（WD-1 locked：系统 used 永不 hard kill）/ `WATCHDOG_INTERVAL_SECONDS=15`（WD-2）/ wall clock 42375s envelope+checkpoint 重校（WD-8）；环境=不合盖+AC 保持（WD-6）+ swarm **quiet_observer_mode**（WD-3，三 worker 冻结重负载）；训练完成→WD-9 三层 checklist → `F044-VERDICT-DECISION-TREE.md`（已预落档）。 |

## 消减记录

（弹药回填后逐条 SUPERSEDED/locked；每拍一条同步回写本表状态列）

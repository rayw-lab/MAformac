# F044 Round-2 通宵 9h 计划（数据修复→短训→eval→morning brief）

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans（commander inline 执行 + worker 派单混合）。Steps use checkbox (`- [ ]`) syntax for tracking.
> **authority**: implementation_plan_not_ssot；决策 SSOT=R2 grill 消减表 + decisions.md；本 plan supersede `runs/.../TONIGHT-PLAN-9H.md`（后者标 superseded 指此）。
> **失忆恢复指针**（compact 后读这里）：现状=F044 round1 四重 FAIL（`F044-VERDICT.md`+CROSSCHECK AFFIRM）；根因=矛盾监督 28:16（`f044-fail-baseline-reflection-2026-07-03.md`）；框架=三段门（codex 辩证已接受：**静态可学性→短训行为门→产品兜底验收**）；必要条件树=`lora-success-factors-deduction-2026-07-03.md`（含 codex 四修正：树名改「当前已知」、scanner key 收严、non-regression 分级、双轨不洗白不升格）。

**Goal:** 明早（07-04 ~08:00）磊哥起床时，round-2 短训完成且 eval 出 verdict（野心线 PASS；保底线=短训在跑+数据修复证据链全绿）。

> **9-task 闭环账（2026-07-04 午，磊哥令闭环）**：T1 W6 ✅ / T2 W7 ✅ / T3 premortem ✅ / T4 R2 消减 ✅（grill 十题今晨全收口）/ T5 数据修复 ✅（重渲染 329→0）/ T6 门全绿 ✅ / T7 短训 ✅ / T8 eval+verdict+brief ✅（接手会话补账，三源复核一致）/ T9 贯穿维护 ✅（D-084~087 记账/消减表/manifest postscript×2/lessons M.20/MEMORY as-of/TONIGHT-PLAN superseded/verification-economics 补腿[前会话已落]/晨间豁免检查=窗口 07-13 未到期无动作）。后续推进转 R2b（grill=f044-r2b-grill-2026-07-04.md，决策 D-085 起）。
> **status 补记（2026-07-04 晨，D-084）**：T1-T7 执行完成（数据修复证据链全绿+短训 23:18 起跑；上任 commander 会话 23:52 掉登录，训练 nohup+watchdog 无人值守跑完 02:57）；T8 由接手会话补账完成：verdict=**F044_R2_FAIL 分层**（A 3→10/15 未达 12、open→close 反转 9→0 主效应确认；B 9/15 zero delta；D 18/34 收复不退化；qa=MP-029 仍 1=D-082 预告内）。🔴 正式训练未起（条件①不满足）；R2-10 执行=转 R2b。落点：保底线达成+，野心线未达。verdict=`runs/2026-07-03-n2n4-train-readiness/F044-shorttrain-run-20260703T231823+0800/F044-R2-VERDICT.md`。

**Architecture:** 三段门串行——①静态可学性修复（矛盾清洗+对比对+负例，机械门 100% 可判定）②round-2 短训+原 bundle eval（保锚可比：A 6/15、B 9/15、D 11/34 是 round1 基线）③产品验收边界（W7 设计稿，R3 执行不阻塞今晚）。

**Tech Stack:** 既有全套复用——`f044-third-run.sh`（watchdog 三跑验证版）/ `run_batch_gates.py` / judge rev2.1 / v6 scorer / F044-VERDICT-DECISION-TREE。

## Global Constraints
- 授权：磊哥 9h 全自动+5 codex+1 subCC；round-2 短训=今日 run-auth F044 流程延续。🔴 **正式全量训练=条件化授权**（磊哥 goal set 原话「如果进度令你满意，我授权进入正式训练」）——commander 放行标准（自设从严，全满足才起）：① R2 verdict 达放行线（A≥12/15 且 open→close 极性反转=0 且 D≥18/34 不退化 且 query→actuation=0）② 数据面三静态门全绿（矛盾=0 证明/DataGate/preflight）③ %43 premortem 无未处置 tiger ④ 正式训练配方=R2 同款仅扩 iters（不引入未经短训验证的新旋钮）⑤ 资源包络按 R2 实测重推并在窗口内可完成或可安全过夜。任一不满足=不起正式训练，morning brief 说明。
- claim：一切绿绑 basis+scorer；分层声称禁升格；受限解码/L1 路由不得洗白裸解码 FAIL。
- 数字：写进任何档的数字必有一手 source；收稿 commander 亲核。
- 训练窗口：swarm 进 quiet_observer_mode（WD-3）。
- worker 面板：%44/%61/%45/%62/%43（右列上到下）；commander %42 左 2/3。

---

### Task 1: W6（%61）派单——数据管线 teardown + 可学性机械审计
**Files:** 产出 `runs/2026-07-03-n2n4-train-readiness/W6-DATA-LEARNABILITY-AUDIT.md` + `W6-contradiction-pairs.jsonl`
**Interfaces:** Produces→T4 消减弹药 + T5 清洗清单（jsonl 每行含 group_key/sample_ids/labels/建议唯一标签+依据）

- [ ] Step 1: tmux L.5 派单 %61，文本含（inline 全量）：①分段交付红线——**H+1h 先交矛盾对清单 jsonl**（阻塞关键路径），teardown 随后补稿；②扫描 key 按 codex 修正版=归一化 user 输入 + state + tool mount 集 + safety class + slot default + split + basis（防把合法状态差异误判矛盾）；③teardown 拆协议串渲染链路到 file:line（从 `contracts/semantic-function-contract.jsonl` 的 set_mode 类行到 samples 渲染器，定位极性维度丢失层：契约字段有无极性 vs 渲染丢弃）；④表示区分度审计（近邻对 interface/defog、airoutlet/wind、to/by、little/number、raise-lower/adjust_to 的输入可分性）；⑤对比对覆盖矩阵。已知一手锚：`c5-train-00001`(open) vs `c5-train-01057`(close) 同串双标签、ac 族 open28:close16。
- [ ] Step 2: capture 验证送达（Working 状态）。

### Task 2: W7（%62）派单——eval 双轨与 bundle v2 设计（R3 用，不阻塞今晚锚）
**Files:** 产出 `runs/.../W7-EVAL-BUNDLE-V2-DESIGN.md`
**Interfaces:** Produces→R3 设计稿 + T4 的 R2-5/R2-6 弹药

- [ ] Step 1: L.5 派单 %62：①A/B 轴 10 族化设计（teardown `runs/tiny-ablation-adjudication-A/v6/build_probe_cases.py` 构建法）；②D 轴负行为面补类（already_state/query 全族/unsupported）；③每 case 产品流量权重标注方案（L1 路由吸收面：协议串/精确指令走规则层，标「到达模型概率」）；④双轨方案（裸解码=诊断真容量/受限解码+白名单=产品验收真值，两轨都报不互替）；⑤明确声明「今晚 round-2 eval 用原 bundle 保锚，本设计 R3 生效」。
- [ ] Step 2: capture 验证送达。

### Task 3: %43 派单——R2 premortem + oracle
**Files:** 产出 `runs/.../WD-AMMO-43-R2-PREMORTEM.md`
- [ ] Step 1: L.5 派单 %43（先发一句澄清：此前误注入的「codex」两行忽略）：①premortem「假设 round-2 又 FAIL，为什么」tiger/paper-tiger/elephant 三分类（候选：清洗标签方向拍错/对比对量不足以改变 greedy/mount 顺序未随机化仍过拟合/2.2 epoch 不足以覆盖新样本/eval 原 bundle 的 ac 偏斜使 A 轴提升被误读）；②oracle 联网 ≥10 搜证：FC 训练集矛盾检测 prior art/contrastive pair 配比经验值/LoRA 灾难遗忘 replay 比例/tool-call 数据 dedup-consistency 实践。每条 URL+日期。
- [ ] Step 2: capture 验证送达。

### Task 4: R2 grill 集中消减（commander，弹药齐后 ≈H+1.5h）
**Files:** Modify `docs/c5-training-readiness-grill/f044-round2-grill-2026-07-03.md`（逐条 locked）
- [ ] Step 1: 收 W6 矛盾清单亲核（抽 5 组自查原始行）；收 %44 W2-GEN-HARDEN（在途）/%45 W2-RECIPE（已交 311 行，sha `4b18d6…` 校验后细读）。
- [ ] Step 2: 逐条拍：R2-1 修复方案=**清洗（唯一标签依据=C1 契约一手+W6 teardown 定位）+wave-2 对比对增补**（渲染带极性重构=R3）；R2-2 一致性门进 DataGate 前置为独立扫描器脚本今晚跑；R2-3/4 配比按 %45 rev+W6 矩阵定量；R2-5 今晚原 bundle 保锚（W7 稿=R3）；R2-6 阈值口径=A 轴底线改「显著提升+极性反转清零」（15/15 底线对泛化训练的适用性挂磊哥晨间确认，今晚以「A≥12/15 且 open→close 反转=0」为放行线+如实报）；R2-7 规模照 %45 rev；R2-8 注脚照 CROSSCHECK；R2-9 carrier 照 %45 建议记录不执行；R2-10 终止条件=round2 FAIL 则停训转 R3（渲染重构+bundle v2），不连训第三轮。
- [ ] Step 3: 消减表全 locked 回写 + decisions.md D-081 记账。

### Task 5: 数据修复执行（%44 主刀 + subCC 生成）
**Files:** 产出 `runs/.../wave2-fix/`（清洗后 samples + 修复批 corpus + 各 receipt）
- [ ] Step 1: %44 按 W6 清单跑清洗脚本（矛盾组→唯一标签，backup 原文件，非目标行字节一致自证——repair lane 范式）+ 实装监督一致性扫描器并对清洗后全集跑出 0 矛盾证明。
- [ ] Step 2: spawn subCC 生成 lane（Opus，惯例铁律含 digest 权威链/位置槽硬规则）按 recipe rev2 生成修复批（极性对比对+query/refusal/already_state 负例+近邻对）；机械门（含新扫描器）→ %43 judge（rev2.1 抽样）。
- [ ] Step 3: commander 亲核：清洗前后行数账/抽样 diff/门全绿。

### Task 6: 数据面重渲染 + 门全绿（%44 + commander 复跑）
**Files:** 产出 `runs/.../wave2-fix/mlx-data/` + `F044-R2-DATA-READY-RECEIPT.md`
- [ ] Step 1: %44 渲染 train/valid/test（split 规则不变）+ DataGate + strict preflight，receipt 绑全 sha。
- [ ] Step 2: commander 独立复跑 strict preflight 逐数比对（M.14 惯例）。

### Task 7: round-2 短训起跑（commander，目标 ≤03:00）
**Files:** 复用 `runs/.../f044-third-run.sh`；新 run dir 自动生成
- [ ] Step 1: fork 脚本（🔴 不原地改 round1 已验证脚本——执行脚本也是 basis，M.17 同构；辩证采纳 codex 建议+参数化合成）：
```bash
R=/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness
cp "$R/f044-third-run.sh" "$R/f044-round2-run.sh"
# 副本内改一行：SHORTTRAIN_MLX_DATA_DIR 参数化（env override，默认指 wave2-fix）
#   SHORTTRAIN_MLX_DATA_DIR="${SHORTTRAIN_MLX_DATA_DIR:-$R/wave2-fix/mlx-data}"
# 头部加注释：fork from f044-third-run.sh (round1-verified sha=<shasum>) ; diff=data-dir 参数化一行
shasum -a 256 "$R/f044-round2-run.sh"   # sha 进 F044-R2 receipt
```
- [ ] Step 1b: 起跑（唯一授权入口=watchdog form）：
```bash
export SYSTEM_MEMORY_FAIL_GB=999 PROCESS_PEAK_FAIL_GB=22.34 WATCHDOG_INTERVAL_SECONDS=15
export SHORTTRAIN_MLX_DATA_DIR=/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/mlx-data
bash /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/f044-round2-run.sh   # run_in_background
```
- [ ] Step 2: 150s 健康检查（越过历史误杀点）+ 首 train_report 后 WD-4 式重校；swarm 广播 quiet_observer_mode。

### Task 8: eval + verdict + morning brief（训练完成通知触发，~07:00-08:00）
**Files:** 产出 run dir 内 `F044-R2-TRAIN-RECEIPT.md`/`f044-eval/`/`F044-R2-VERDICT.md` + `docs/handoffs/2026-07-04-f044-round2-morning-brief.md`
- [ ] Step 1: WD-9 三层（train-health 核→artifact sha receipt→eval fresh process，**mount 源=samples 全集**（round1 踩坑修正，勿再用 train split））。
- [ ] Step 2: v6 同款 scorer 复算（base 数字必须复现 3/15、9/15、18/34 三锚，否则先查口径再判）；对照 round1（A6/B9/D11）出 delta；query→actuation 全扫。
- [ ] Step 3: 按决策树出 R2 verdict（PASS 放行线见 T4-R2-6；FAIL→R2-10 终止条款转 R3）；morning brief ≤40 行（结果/证据链/下一步 ⭐default/磊哥仅需拍的键）。

### Task 9（贯穿）: 元认知/记忆/文件级联维护线（commander，磊哥点名）
- [ ] 每里程碑即时：decisions.md（D-081 消减/D-082 修复执行/D-083 短训/D-084 verdict）；R2 grill 消减表状态列；`T1D-candidate-manifest-FINAL.md` 加 postscript（step4=round1 FAIL、round2 结果）。
- [ ] verdict textual 修正（%43 F2/F3 两处：MP-029 观察名统一 `adjust_ac_temperature_to_number(9)`；「v6 精确复现」改「同族+新变体」）+ 补「矛盾监督根因」段（cite 反思档）。
- [ ] lessons：M.17（scorer 也是 basis）/M.18（分布内指标对分布结构缺陷天然盲→行为评测+结构审计才到达）/M.19（矛盾监督=同输入双标签穿过全部机械门：监督一致性门常设）——落 `docs/lessons-learned.md`。
- [ ] 全局 rule `verification-economics` 补腿：门矩阵加「监督一致性」格 + 锚绑 scorer。
- [ ] MEMORY.md as-of 更新（F044 round1 FAIL→根因→round2，compact 前必做）；`runs/.../TONIGHT-PLAN-9H.md` 头部标 superseded-by 本 plan。
- [ ] 晨间豁免检查：CLAUDE.md §6 豁免窗口 07-13 未到期，无动作。

## 时间轴与停线
| 窗口 | 关键路径 | 保底动作 |
|---|---|---|
| H0-1 | T1/T2/T3 派单 + W6 矛盾清单限时 1h | 清单迟到→commander 自跑简版扫描器（key 按 codex 修正版）解锁 T4 |
| H1-2.5 | T4 消减 + T5 清洗与生成 | 生成慢→修复批砍量保「清洗+极性对比对」核心 |
| H2.5-3.5 | T6 门全绿 + T7 起跑（≤03:00 红线） | 03:30 仍未绿→放弃今晚短训，转「审计+修复全绿」保底线，morning brief 如实报 |
| H3.5-7.5 | 短训（watchdog 无人值守）| BLOCKED→按 receipt 处置，不重试超 1 次 |
| H7.5-9 | T8 eval+verdict+brief | 训练未完→brief 报在跑进度+预计完成时刻 |

## Self-Review 已跑
- 覆盖：磊哥六条指令全映射（9h 拉满=全表/落档=T4-T9 产物/元认知记忆级联=T9/演绎树=约束与 T4 依据/三段门=Architecture/明早好结果=Goal+时间轴红线）。
- 无占位符；路径全 exact；T7 命令与 round1 实跑一致仅换数据面变量。
- 类型一致：各 task 产物名在 Interfaces/后续 task 引用一致。

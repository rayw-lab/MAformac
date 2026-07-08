# Handoff 2026-07-08：D-120 点火链 + S8 暂停态 + 白天六路蜂群收口

> 写于磊哥掉线重登后（原 session 结束）。下一 session（新 commander）按本文件冷启动。
> 状态基线：branch `opt/streamline-macos-20260707` @ **597917ad**（ahead 3 未 push），仓 clean。

## 0. 新 session 起手 SOP（磊哥指定，逐条照做）

1. **读链**：本文件 → `docs/roadmap-2026-07-07-macos-closure-baseline.md`（⭐**v4.1 计划基线**，四线一图+粗路线图）→ MEMORY.md as-of（最新在顶）→ `docs/commander-log/decisions.md` D-120/D-121 → 宪法 `/swarm-commander`。
2. **启动新 tmux 蜂群**（旧 ma7 server 已随磊哥掉线失效，不要复用 stale pane id）：
   ```bash
   # 在磊哥给的终端里（或让磊哥 tmux attach）。commander 在 pane 0，占 2/3 宽。
   tmux new-session -d -s ma8 -c /Users/wanglei/workspace/MAformac
   # commander pane 0 内由磊哥启动 claude 恢复对话；然后 commander 加载 /swarm-dispatch + /swarm-commander
   # 右侧 6 worker（5 codex + 1 hermes），🔴 全员绕代理（磊哥 SOP）：
   BYPASS="env -u HTTP_PROXY -u HTTPS_PROXY -u http_proxy -u https_proxy -u ALL_PROXY -u all_proxy NO_PROXY='*' no_proxy='*'"
   CODEX="/Applications/Codex.app/Contents/Resources/codex"   # 裸 codex 有 darwin-arm64 缺依赖风险
   HERMES="/Users/wanglei/Library/Python/3.13/bin/hermes"
   CWD="/Users/wanglei/workspace/MAformac"
   for i in 1 2 3 4; do tmux split-window -t ma8:0 -c "$CWD" "$BYPASS $CODEX"; done
   tmux select-layout -t ma8:0 main-vertical          # 右列放不下时先 layout 再补切
   tmux split-window -t ma8:0.1 -c "$CWD" "$BYPASS $CODEX"
   tmux split-window -t ma8:0.3 -c "$CWD" "$BYPASS $HERMES"
   tmux select-layout -t ma8:0 main-vertical && tmux resize-pane -t ma8:0.0 -x 67%
   ```
3. **派单前必做**：逐 pane `capture-pane` 亲核身份（宪法 §20：交接文档是 dated report，worker 型号/pane id 以实况为准）；派单四步 SOP（send-keys -l → 单独 Enter → sleep → capture 验证 Working）。

## 1. 磊哥 × 6 worker 协作模式（磊哥指定写入；一手=宪法 §1-§21 + 本两日实战）

- **角色**：磊哥=owner（只拍键：run-auth/merge/push/扩挂载/四红线/ballot；打字列⭐不弹窗）；commander=纯编排+裁决+收稿亲核+记忆图谱，**亲挖纵切**（基线文档亲笔，UIUE 亲自主刀）；worker=一切执行（调研/实装/审计/秘书/红队），**零 commit 权**，产物全落 run dir。
- **派单**：SPEC 内联 SSOT 关键决策（规则+file:line 非编号指针）+ 明确禁区 + 输出绝对路径 + 「完成向 %0 发 REPORT（仅 BLOCKED+最终 REPORT 两类，其余禁发）」。
- **收稿**：文件存在性=ground truth（不信 ack）；载力断言 commander 必亲核（D-089）；worker 报 pass 必自跑门核。
- **对抗配对**：一切脑暴/调研/计划产出=单 frame 草稿，收稿即派**异 worker** 交叉审（producer≠auditor，消费视角优先）；commander 亲笔件同样进审（本日实证：roadmap v4 被审出 3P1 全真）。
- **idle-scan**：worker 一秒不闲（磊哥「白拿工资不允许」）；收 REPORT 动作里自带下一单；backlog 常备（磨刀活：矩阵/骨架/checker/盘点/一致性扫描）。
- **节奏实例（今天白天，可复制）**：六路首轮（矩阵/骨架/预备件/秘书/审计/一致性）→ 收稿亲核 → 二轮交叉（审计互换+修自己产物+闭环缺口）→ 三轮（DRIFT 修复+ballot 复核+命令冻结）。全程磊哥零打扰，只在 ballot/重启键处 ping。
- **磊哥画像速览**：「随口担心=深挖令」「不说也要懂」；重大派单 grill+红队成对；额度紧时 Opus 只做中文语料创作用完即关；训练窗昨晚实证=他可能故意中断训练（合盖/要用机），**任何长跑前和他确认窗口**。

## 2. 当前态总账（2026-07-08 午前）

### Line B（关键路径）：S8 暂停待窗口 🔴
- S7c 量尺停线 → 磊哥拍 **A** → grill（GA-1~10）+ subagent 对抗审计（AUDIT_FAIL 3 findings 全清）→ recert 盖章（`RECERT-RECEIPT.md` sha 44dd5b08…，launch:341 已加 PENDING 机械拒绝+run-dir exit70 守护，正负双测过）→ **S8 点火两次均中断**：r1 iter170 lid-sleep 杀（哨兵正确分类）、r2 磊哥主动 pause（要用机）。均无 checkpoint。
- **重启 = 全新完整 1800（fresh relaunch，C=0，无 stale-schedule 风险）**，命令见 `OPERATOR-PAUSE-RECEIPT.md`（run dir s8-flight/）。磊哥晚间窗口一句话点火；点火前建议采纳 trainer-rc wrapper 提案（见 §3 残留），但其审计 REQUEST_CHANGES 未修——**不采纳也可直接点火**（rc capture 是 nice-to-have）。
- 训后自动棒：S9 三臂 eval（**exact 命令已冻结** `daywork/s9-exact-commands-frozen.md`，base 臂要 `--base-only-smoke`）→ S9b → S10 verdict（模板备）。

### Line C（能力面）：矩阵 v2 待合成
- 120 格矩阵 draft（执行1/拒识36/兜底76/unknown7）→ unknown 7 格全清零（#4 ac×SPOT×直述=执行，commander 亲核过）→ 但审计 **NO_GO_AS_SSOT P0**：「拒识36」实为 unmounted 类，分类学须按四类重构（safety_or_clarify / unmounted_name_rejected / fast_path_no_match / unknown）——与 MG-8 ⭐B reason enum 咬合。**下一步 = 矩阵 v2 合成**（draft+resolution+四类重构，然后才可当 SSOT 候选）。
- C1/D0 grill 骨架已过交叉审并修复（REVISED_PER_CROSS_AUDIT）；兜底话术盘点+10族×4reason 草案已备（C1 grill 弹药）。

### Line D（任务④ UIUE+runtime）：已立项
- roadmap v4.1 §三点五：验收维度表（七态消费/U17 XCUITest/voice preflight/readback proof cap）+ UIUE 前置化时序（D1a 视觉原型不等 S10）。D-line 全量验收矩阵已产（`daywork/d-line-acceptance-matrix.md`，U45+V12+D1-D7+D8.x）。**D1 UIUE 专场 = commander 亲笔 + 磊哥近距离 grill（铁律：不交 codex 主刀）**。

### 待磊哥键
| 键 | 备注 |
|---|---|
| 🔴 S8 重启令 | 晚间 ~9-11h 窗口 |
| ballot 一屏拍板 | `daywork/ballots-for-leige.md`（BATCH2 5题+INFRA 7决策+**Q-SR 追加题**）。⚠️ 呈报时澄清：Q-SR（联合出手率公式）是**真新题**——BATCH1 拍的是三档表结构，公式字段未拍（hermes precheck F-6 catch，roadmap:72 措辞易误导为已拍） |
| S9 holdout 生成席位 | 三选（s9-holdout-gen-plan，NEEDS_LEIGE，D-116 hermes 席已被阵容变更 supersede） |

## 3. daywork run dir 产物索引（`~/Projects/agent-tmux-stack-research/runs/2026-07-08-daywork/`）

| 产物 | 态 | 消费动作 |
|---|---|---|
| ballots-for-leige.md（+Q-SR）+ ballot-precheck.md | ✅可呈 | 呈磊哥（带 F-6 澄清） |
| capability-matrix-draft.md + matrix-unknown-7-resolution.md + capability-matrix-audit.md | 待合成 | 派 worker 合成矩阵 v2（四类分类学） |
| c1-grill-skeleton.md + d0-uiue-grill-skeleton.md（REVISED）+ skeleton-cross-audit.md | ✅ | C1/D0 grill 开打时的骨架 |
| d-line-acceptance-matrix.md | ✅ | Line D 派单/验收的维度权威 |
| fallback-script-inventory-and-draft.md | ✅ | C1 grill「兜底话术验收门」弹药 |
| s9-prep/（2 checker TDD 全绿）+ s9-exact-commands-frozen.md | ✅ | S9 执行时直接用 |
| trainer-rc-capture-proposal.md + s9-prep-and-rc-audit.md（REQUEST_CHANGES P1×3） | 待修 | 修后才可采纳进 launch 脚本（非点火 blocker） |
| consistency-scan.md（11 drift）+ DRIFT 修复（s9-runbook/IMPL-PLAN-v3/holdout-plan 3 文件已修） | ✅ | DRIFT-9 已转 Q-SR；DRIFT-11 exposure checker 在 S9 前补 |
| claude9-surgery-final-draft.md / memory-asof-draft.md | 草稿 | commander 过一道后落笔 |

## 4. 残留 / 下一步优先序

1. 磊哥 ballot + S8 重启令（人工键）。
2. S8 跑完 → S9（命令已冻结）→ S10 → C2 扩挂载按三档表（Q-SR 公式拍后字段写进 S9 runbook/S10 模板）。
3. 矩阵 v2 合成（四类分类学）→ DemoCapabilityMatrix SSOT 候选 → C1 grill 开打（骨架已备）。
4. D0 grill → D1a 视觉原型/harness（S8/S9 期间并行）→ D1 UIUE 专场（commander 亲笔）。
5. trainer-rc 提案按审计 P1 修复后采纳；DRIFT-11 exposure checker。
6. CLAUDE §9 手术终稿（草稿在 daywork）呈磊哥。

## 5. 本 session 教训沉淀（已落）

- lessons **M.47**（裁决 worker 分歧必核方案在约束下可实现性——AD-6 v1 被对抗审计推翻实证）；D-120/D-121 决策记录；roadmap v4→v4.1 两轮增量均过异源审。
- S8 中断二连的操作学：`caffeinate -is` 不防合盖；磊哥用机窗口与训练窗口必须显式对齐（问一句再点火）。

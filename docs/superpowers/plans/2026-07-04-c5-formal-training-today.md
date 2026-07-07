# 今日工作计划：C5 正式训练完成（2026-07-04）

> **authority**: implementation_plan_not_ssot；决策 SSOT=decisions.md（D-085~090+今日后续）+ f044-r2b-grill-2026-07-04.md（R2B-1~10 locked）。
> **磊哥今日目标（原话）**：「我今天目标是 C5 正式训练完成」+「记录到今日工作计划文档 grill——openspec+我们的元认知要继续执行」。
> **失忆恢复指针**：现状=R2b 数据面 773 行收口中（750 四批全 accept + 23 行 AC supplement 修复完待 judge）；正式训练=D-080 条件化授权（五条框架）+D-093 红队第六门=共六条全满足 commander 才起+ R2b 门=D-085（A≥12+B>9+D≥18+qa=0+双向极性单列）；R2b PASS 声称上限=只证两残余靶点修复（磊哥锁）。
> **2026-07-05 晚 supersession**：本文是 2026-07-04 历史执行计划，不是当前 launch authority。最新状态见 `docs/baseline-roadmap-2026-07-05-c5-d106.md §0.3` 和 `runs/2026-07-05-formal-1800-launch/secretary/STATUS-BOARD.md`：run-auth 已接受，但 host gate 三采样 FAIL，formal 1800 **NOT_LAUNCHED**；command/watchdog v2 clear 不替代 host PASS/waiver。

## 目标与时间轴（14:30 起）

| 段 | 内容 | 预计完成 |
|---|---|---|
| T-A | supplement judge（%43 全量 23 行）→ 注入（%45）→ merger 773 终账+累计门首跑（%44） | ~15:30 |
| T-B | train-pack 组装（%45 assembler：envelope 下采样+replay 102=SHORTFALL-01）→ 渲染+scanner+DataGate+strict preflight（runbook 已 staged，双人核=worker 跑+commander 复跑） | ~16:30 |
| T-C | **R2b 短训起跑**（f044-r2b-run.sh 血缘 fork 已核；watchdog 无人值守；ckpt50/100 A 轴行为快探早停） | **三次起跑实况**：一跑 14:51→15:34 swap-hang 归档 HUNG；二跑 15:34→15:52 电脑死机归档 CRASH；三跑 run `155204` 于 ~16:00 在 `%1` 线程起跑，后续以活动 run receipt 为准 |
| T-D | 双轨 eval（runbook+bundle 冻结已备）→ 四轴 verdict（骨架已备） | **~21:30 出 R2b verdict** |
| T-E | **历史计划项，已被 2026-07-05 晚 supersession 覆盖**：R2b PASS + 六条件全绿 + Launch Packet 6 闭合 → 正式训练起跑（同配方仅扩 iters，D-080+D-093 条款）通宵 watchdog | 历史目标；当前真实状态是 run-auth accepted 但 host HOLD / NOT_LAUNCHED |

早停线：ckpt50/100 目标族无移动即停（省 3h）；R2b FAIL→R2B-8 四轴分诊不连训。

## Grill 范式贯穿（D-046）

- 正式训练起跑前 = **六条件消减表**逐条 locked（放行线 verdict/三静态门/premortem 无未处置 tiger/同配方仅扩 iters/包络按 R2b 实测重推/红队 Launch Packet 6 闭合[D-093]）——落本档下方，起跑即回写。
- R2b verdict 出来若有意外形态（如 B 轴 B_MOVED_NOT_PASS），处置按预落决策树（R2B-8/verdict 骨架），零临场拍。

## OpenSpec 关联（R2-9 locked 沿用）

- 今晚全程走 run-dir receipt + plan carrier（本档），不动 openspec change。
- 正式训练 PASS 后：F044 短训评已两轮证明为常设硬门 → 按 R2-9 在 R3 开窄 change `define-f044-shorttrain-behavior-gate`；训练产物（adapter/receipt 链）挂 T1D manifest step4/5 流程（step5 run-auth=磊哥键，正式训练完成后候选晋级仍走 R-L17 体系）。

## 元认知纪律贯穿（今日已产 & 继续执行）

- 决策即记账：D-085~090 已落；后续每里程碑（773 终账/短训起跑/verdict/正式训练起跑）即写 D-091+。
- 今日新制度：M.21 约束物化定律（prose 约束必蒸发→locked-floors.json/累计账门）/ R2B-NVC-01 / DEVREF-01 / DOOR-ERRATA（worker 附带断言必亲核）/ REPORT-first（落盘不报=未完成）/ 撞单防护（owner 点名）。
- 训练 receipt 效率两列（supervised_tok_per_sec + ignored:trainable，效率档 §4）今晚首用。
- MEMORY as-of 在 verdict 后刷新；morning brief 若跨夜则明早出。

## 六条件消减表（正式训练放行，起跑前逐条回写；D-080 五条+D-093 红队第六门）

| # | 条件 | 状态 |
|---|---|---|
| 1 | R2b/R3/R4 verdict 达 D-085 放行线 | 🟡 **qa 量尺翻案·重评中（Opus4.8 接棒）**：三轮 A/B/D 收敛（R4 run 005046=A15/B15/D21 三轴连续两轮 PASS），但 qa 表面 9→8→10 **数字口径不可比**（D-105 亲核翻案：R3 scanner 漏计 invalid 名 query_volume 致 qa=8 虚低 + 同句「现在音量是多少」训练/eval 矛盾监督）→撤回 A/B/C 战略口径（前提动摇）→自动推进量尺修复（%5 scanner 硬化重扫真数 / %2 label authority 回溯 C1 / %3 对抗审 / %4 沉淀）→重评拿真数后才是 qa=0 硬门是否松的真拍点。正式训练 1800 仍 HOLD |
| 2 | 三静态门全绿（矛盾 0/DataGate/strict preflight，773 终版数据面） | ✅ 双人核逐数一致（D-091；含守恒断言首用+split P0 拦截） |
| 3 | %43 premortem 无未处置 tiger | ✅ T3-PREMORTEM-DISPOSITION：8T 全 disposed 0 open |
| 4 | 配方=R2b 同款仅扩 iters（iters 数起跑前拍，锚=R2b 实测吞吐） | ⏳ T-E 前 |
| 5 | 资源包络按 R2b 实测重推（峰值/墙钟；watchdog 参数沿用 M.16 修正版） | 🟡 W21 推演 + **W33 内存 premortem（19 外源）落定环境 SOP**：⭐起跑前重启优先（swap 已热 5GB，purge 只清盘缓存清不掉匿名/MLX 内存=paper-tiger）；不重启则关 GUI 全家桶（真大头=飞书/微信/Codex desktop/WindowServer，非 codex pane 每个仅 100-150MB）；双阈值 **swap≤1GB + free≥21GB** 进 formal-host-baseline.json 采集规范（W33 §6 命令清单）；训练侧全部旋钮=drift 今晚不动（含 mx.set_wired/cache/memory_limit=代码面 drift 需烟测+diff）；训中禁并行推理/eval/browser/Xcode。重启键=磊哥 |
| 6 | 🔴 对抗视角审视正式训练方案（磊哥 2026-07-04 加）：worker 以 premortem/red-team 视角审 W21 配方+五条件+运行环境方案，无未处置 P0/P1 才起跑 | 🟡 W27 回稿=BLOCKED_NOW（4 P0+3 P1，`W27-FORMAL-TRAIN-REDTEAM.md`）；总监采纳→起跑硬门=**Launch Packet 6 文件**（launch-conditions / config.diff+schedule 150→450 updates·warmup 12→36 / host-baseline.json / watchdog-contract / eval-manifest 起跑前冻结 / receipt 曝光记账）；**Launch Packet 严格账（17:40 态，W44 纠 5/6 overclaim）**：①launch-conditions 骨架✅（verdict 栏空等 T-D）②config.diff✅（总监亲核 diff 一手：唯 iters1800/450updates/warmup36 三变化零漂移）③host-baseline.json ⏳起跑时点实采（D-094 B 路线+双阈值）④watchdog-contract✅（契约六 checkbox 总监亲核；W41 影子验证 P0=0→W45 修 P1×2[自适应上限 600/900+300/600、默认 shadow 需显式 --armed]→三例回放+边界表 6 组合全过+🔴总监活体亲核：对在跑 155204 真 artifacts 影子挂 40s 零误触发、心跳正常、训练进程无损）⑤eval-manifest✅（总监亲核 sha+抽核 8/8）⑥receipt 模板✅=templates/R2B-FORMAL-TRAIN-RECEIPT-TEMPLATE.md（W31 曝光记账段；packet 清单名 formal-receipt-template.md 以此路径绑定） |

> ⚠️ 条件 4 红队修正（W27 T3/P0-3）：「同配方仅扩 iters」若只改 `training_iterations` 而 LR schedule 仍锚 150 updates = stale-schedule 变体（cosine 在旧地平线跑完、多出的 300 updates 走非设计尾部）→ 必须 450 updates + warmup 36 比例扩展并出 config.diff 自证。
> ⚠️ 中途 ckpt50/100 A 轴探针**取消**（总监裁定）：探针需加载模型推理，当前系统 32.8/34.4GB + swap 4.4/5GB，再起推理=M.23 swap 绞死重演；中途信号价值 < 杀训练风险。诊断留给 T5 处置（正式训练 ckpt 600/1200/1800 留档训后诊断）。

## 当日执行终态（2026-07-04 晚收口，按计划 fail-closed 分支落地）

- T-A✅ 773 数据面 accept；T-B✅ 三静态门双人核（含 split P0 拦截+守恒断言首用）；T-C✅ 短训跑完（三折后 worker 执行官架构跑通，run 155204 训练全健康）；T-D✅ verdict=**F044_R2B_FAIL 分层**（D-092/D-095 同判：MP-029 安全修复达成+扩充轨 B+10 同分布大效；判门轨 A/B 跨分布零移动+qa 扩充轨 9）。
- **T-E 按五条件 fail-closed 正确未起跑**（条件①不满足；强行起跑=违反 D-080 磊哥条件化授权）——本计划的「执行推进」含此诚实分支，非未完成而是按门放行纪律终止。
- 后续路径（已交接正牌 commander[tmux %0 会话，磊哥拍板 D-094/096]）：R3 修复轮连夜（数据订单=9 族 unsupported-query 强负例+近邻×协议记忆组合样本；短训条件式起跑）→ **正式训练=磊哥晨键**（D-096）。本会话退指挥位作备份通道。
- 当日制度产出：M.21 约束物化/M.22 转换步守恒门/M.23 包络绑宿主环境；worker 执行官架构（训练归 worker 线程）验证成功；三次短训评均在正式训练前拦下缺陷=失败到达点经济学三连兑现。

## R3 连夜修复轮（D-096，verdict FAIL 后当夜开案）

- R3 grill：`docs/c5-training-readiness-grill/f044-r3-grill-2026-07-04.md`（R3-1~5 locked+AMMO-2 佐证；R3-6 磊哥晨键=正式训练）。
- 六单在跑/已收：R3-QNEG（%4 生成 108+36）/R3-COMBO（%5 生成 ≥40）/W47 红队 ✅CONDITIONAL_GO（3 P0 映射放行 checklist：over-refusal 硬线/监督冲突 scanner+24/26 地板/host+watchdog 条款）/R3-GATES-PREP（%2 在途）/AMMO-1 分布劈叉（%2 在途，影子收编）/AMMO-2 ✅（根因=严格口径仅 8 行监督）。
- R3 短训条件式起跑 checklist：机械门绿+judge PASS（%3 隔离判官）+scanner 零矛盾+host 双阈值+watchdog --armed 真 pid+W47 P0 全绿 → 起；任一不绿 hold 磊哥晨键。

## 磊哥待补充

- 「后续我们除了 ios 的开发 还要开发……」（消息两次被截断）——等补全后纳入规划。

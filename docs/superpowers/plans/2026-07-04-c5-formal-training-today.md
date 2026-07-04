# 今日工作计划：C5 正式训练完成（2026-07-04）

> **authority**: implementation_plan_not_ssot；决策 SSOT=decisions.md（D-085~090+今日后续）+ f044-r2b-grill-2026-07-04.md（R2B-1~10 locked）。
> **磊哥今日目标（原话）**：「我今天目标是 C5 正式训练完成」+「记录到今日工作计划文档 grill——openspec+我们的元认知要继续执行」。
> **失忆恢复指针**：现状=R2b 数据面 773 行收口中（750 四批全 accept + 23 行 AC supplement 修复完待 judge）；正式训练=D-080 条件化授权（五条全满足 commander 才起）+ R2b 门=D-085（A≥12+B>9+D≥18+qa=0+双向极性单列）；R2b PASS 声称上限=只证两残余靶点修复（磊哥锁）。

## 目标与时间轴（14:30 起）

| 段 | 内容 | 预计完成 |
|---|---|---|
| T-A | supplement judge（%43 全量 23 行）→ 注入（%45）→ merger 773 终账+累计门首跑（%44） | ~15:30 |
| T-B | train-pack 组装（%45 assembler：envelope 下采样+replay 102=SHORTFALL-01）→ 渲染+scanner+DataGate+strict preflight（runbook 已 staged，双人核=worker 跑+commander 复跑） | ~16:30 |
| T-C | **R2b 短训起跑**（f044-r2b-run.sh 血缘 fork 已核；watchdog 无人值守；ckpt50/100 A 轴行为快探早停） | **三次起跑实况**：一跑 14:51→15:34 swap-hang 归档 HUNG；二跑 15:34→15:52 电脑死机归档 CRASH；三跑 run `155204` 于 ~16:00 在 `%1` 线程起跑，后续以活动 run receipt 为准 |
| T-D | 双轨 eval（runbook+bundle 冻结已备）→ 四轴 verdict（骨架已备） | **~21:30 出 R2b verdict** |
| T-E | R2b PASS + 五条件全绿 → **正式训练起跑**（同配方仅扩 iters，D-080 条款）通宵 watchdog | 磊哥睡前看到起跑，**明早收正式训练** |

早停线：ckpt50/100 目标族无移动即停（省 3h）；R2b FAIL→R2B-8 四轴分诊不连训。

## Grill 范式贯穿（D-046）

- 正式训练起跑前 = **五条件消减表**逐条 locked（放行线 verdict/三静态门/premortem 无未处置 tiger/同配方仅扩 iters/包络按 R2b 实测重推）——落本档下方，起跑即回写。
- R2b verdict 出来若有意外形态（如 B 轴 B_MOVED_NOT_PASS），处置按预落决策树（R2B-8/verdict 骨架），零临场拍。

## OpenSpec 关联（R2-9 locked 沿用）

- 今晚全程走 run-dir receipt + plan carrier（本档），不动 openspec change。
- 正式训练 PASS 后：F044 短训评已两轮证明为常设硬门 → 按 R2-9 在 R3 开窄 change `define-f044-shorttrain-behavior-gate`；训练产物（adapter/receipt 链）挂 T1D manifest step4/5 流程（step5 run-auth=磊哥键，正式训练完成后候选晋级仍走 R-L17 体系）。

## 元认知纪律贯穿（今日已产 & 继续执行）

- 决策即记账：D-085~090 已落；后续每里程碑（773 终账/短训起跑/verdict/正式训练起跑）即写 D-091+。
- 今日新制度：M.21 约束物化定律（prose 约束必蒸发→locked-floors.json/累计账门）/ R2B-NVC-01 / DEVREF-01 / DOOR-ERRATA（worker 附带断言必亲核）/ REPORT-first（落盘不报=未完成）/ 撞单防护（owner 点名）。
- 训练 receipt 效率两列（supervised_tok_per_sec + ignored:trainable，效率档 §4）今晚首用。
- MEMORY as-of 在 verdict 后刷新；morning brief 若跨夜则明早出。

## 五条件消减表（正式训练放行，起跑前逐条回写）

| # | 条件 | 状态 |
|---|---|---|
| 1 | R2b verdict 达 D-085 放行线 | ⏳ T-D |
| 2 | 三静态门全绿（矛盾 0/DataGate/strict preflight，773 终版数据面） | ✅ 双人核逐数一致（D-091；含守恒断言首用+split P0 拦截） |
| 3 | %43 premortem 无未处置 tiger | ✅ T3-PREMORTEM-DISPOSITION：8T 全 disposed 0 open |
| 4 | 配方=R2b 同款仅扩 iters（iters 数起跑前拍，锚=R2b 实测吞吐） | ⏳ T-E 前 |
| 5 | 资源包络按 R2b 实测重推（峰值/墙钟；watchdog 参数沿用 M.16 修正版） | 🟡 W21 已推演（⭐1800 iters/~11h/起跑≥21GB/运行 free<3GB 暂停），起跑前按 R2b 实测终值更新 |
| 6 | 🔴 对抗视角审视正式训练方案（磊哥 2026-07-04 加）：worker 以 premortem/red-team 视角审 W21 配方+五条件+运行环境方案，无未处置 P0/P1 才起跑 | ⏳ T-E 前（下一交付 worker 接单） |

## 磊哥待补充

- 「后续我们除了 ios 的开发 还要开发……」（消息两次被截断）——等补全后纳入规划。

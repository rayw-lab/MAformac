# UIUE Phase 4 用户演绎体验审计报告（subagent CC，2026-06-25）

> verdict=**CONDITIONAL-PASS**（工程层 SOLID，呈现语义层有真实体验缺口）。subagent CC 从方案经理 5min 现场台本 + 客户旁观者视角，逐步演绎 + 逐张 Read 14 张实拍截图。辩证收落 `design.md AD-12 §九` + proof README + lessons。

## 核心 catch（load-bearing 一手）
**force-state 14 张截图是「满屏丰富视觉」5-gate 验收脚手架，不代表真实台本时刻。** `DebugGallery.forcedScenarioCells()` 写死 seat/window/ambient/screen/volume 5 族永远活跃，只 ac 卡随 force-state 切 7 态。导致 README「5-Gate verdict」用脚手架图背书「用户真实看到」——而真实冷启动（`defaultCells()` ac.power=off/温度24/座椅0/氛围灯白/窗0）应是 10 族接近全静默骨架，与「normal 截图 5 族青辉光」截然不同。**真实台本开场视觉从未被截图验证。**

## P0（现场会翻车/客户误读）
- **P0-1 占位卡「未激活」客户读成「demo 没做完」撞惊艳门**：下半屏 4-5 族大字「未激活」，销售语境=「这块没做/买了用不了」。→【4a 改文案「未激活」→「待命」就绪态】✅已修。
- **P0-2 真实冷启动开场视觉从未验证 + 可能满屏灰撞惊艳门**：真实 defaultCells 冷启动 10 族全 normal 静默（无辉光全 dim），开场黄金 5 秒可能「满屏灰糊脸」。→【补真实冷启动截图 + AD-12 idle「静默≠死灰」由 Phase 5 boot reveal 承载】✅已补 `ios-coldstart-real.png`（验证非 broken，待命骨架+值全显）。
- **P0-3 调试标签「force-state · xxx」在截图顶栏，对外展示削弱说服力**：DEBUG-only release 不带，但 proof 图当证据展示带调试字。→【proof 标注内部脚手架；真实展示另出图】记录。

## P1（体验摩擦）
- **P1-1 竖屏 2 列低排位族激活滚出视野客户跟丢（最大竖屏风险）**：香氛 row_count32 第 5 行需滚，激活在屏外客户看不到反馈。+ 演绎质疑「固定全景+hero vs 物理置顶」在 2 列竖屏冲突（自动滚把上半屏滚出）。→【AD-12 升级 + Phase5 头号 spike + **4a 台本约定首屏族优先**】。
- **P1-2 scope 淡角标 9pt 投屏看不清落空裂缝⑤初衷**：claim-vs-reality 第10变体（高清图看着在，投屏看不清）。→【4a 提对比 caption semibold+细边框，淡≠隐形】✅已修。
- **P1-3 blocked_hard 灰锁🔒客户易误读「坏了」非「智能拒识」**：灰锁=故障语言，与 unknown 灰三角负面感接近，blocked_hard 是 demo 卖点不该共享「灰故障」视觉。→【撞 D7 FROZEN 色映射，steelman 不自改色，上抛磊哥/AD-1 review icon/文案】。
- **P1-4 changing 变化点太小客户跟不上「正在执行」**：26→27℃+循环图标差异小，220ms 一闪而过。→【4b 调 changing 视觉强度+时长】。

## P2（打磨/轻治理）
- P2-1 iOS normal vs satisfied force-state 大图坍缩（README 不该用这两张证 7 态可分）→ README 措辞已修。
- P2-2 ambient 红色块偏小偏淡可更饱满铺张 → 4b。
- P2-3 readback/commandBar 占上方挤 grid 到下半屏 → Phase 5 三 zone 解。
- P2-4 默认淡角标 vs 非默认 title scope 呈现不一致（grill 裂缝⑤已锁）→ 记录不改。

## verdict
**CONDITIONAL-PASS**：工程实装 SOLID（7态四分/scope SSOT/占位骨架/numericText/breathe/ambient 实跑非假绿，调研 AD-12 对竖屏张力/breathe offscreen/badge 字号也自识别非盲区）；呈现语义层 4 条 P0/P1（未激活/冷启动满屏灰/角标看不清/灰锁误读）从客户现场视角才暴露。P0+P1-2 已 4a 修，P1-1 Phase5 spike+4a 台本约定，P1-3 上抛磊哥，P1-4/P2-2 defer 4b。

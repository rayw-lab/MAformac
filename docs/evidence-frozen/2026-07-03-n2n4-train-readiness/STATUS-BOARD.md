# 作战状态板（commander 每里程碑更新；compact 失忆第一恢复点）

> **as-of: 2026-07-05 09:38**（旧 R2a/round2 板已 superseded，见 git 史）
> plan SSOT: `/Users/wanglei/workspace/MAformac/docs/superpowers/plans/2026-07-04-c5-formal-training-today.md`（六条件消减表+Launch Packet 严格账）
> 决策 SSOT: `docs/commander-log/decisions.md` D-085~D-105；grill: `docs/c5-training-readiness-grill/f044-r2b-grill-2026-07-04.md` / `docs/c5-training-readiness-grill/f044-r5-grill-2026-07-05.md`

## 🔴 Opus4.8 接棒 + D-104/D-105 双翻案 + R5 量尺修复保存点（09:38 态）
- **接棒**：Fable5 commander 额度耗尽，Opus4.8 commander 接棒；D-104 已入 `docs/commander-log/decisions.md`，为接棒首个亲核 verdict。
- **R4 verdict**：`F044_R4_FAIL_QA_REGRESSION`。R4 run `005046` 训练健康 600/600，峰值 19.03GB<22.34；A **15/15**、B **15/15**、D **21/34**，A/B/D 连续两轮（R3/R4）稳定 PASS；qa 跨轨 `total=12 / adapter=10 / base=2 / original_v3=0`，R3 adapter=8 → R4 adapter=10 恶化。
- **T1 纠偏**：失败不是 W55 预期的 over-refusal，而是工具名幻觉/近邻混淆；observed 出现 `query_volume` / `query_fragrance_mode` / `close_door` 等契约不存在名，真名仍为 `query_current_volume` / `query_mode_of_fragrance` / `close_car_door`。
- **D-105 量尺翻案**：D-104 的“qa 9→8→10 恶化 / 数据手段未破”口径被撤回为不可比。两因子：① scanner 漏计 invalid tool name（R3 `query_volume` 未计）② label authority 同句矛盾监督（`现在音量是多少` 训练标 query，eval 标 empty）。
- **%2 authority 回稿补账**：6 个 identical-input cross-bundle 冲突；C1 裁定 status-query 若有 query 工具应路由 query，修法=修 eval 侧 expected/mount，或拆话术成 no-query counterfactual 并显式标 authority。`R5-LABEL-AUTHORITY-AUDIT.md` 文件名暂未在 run dir 出现，当前以 commander 收到的 %2 回稿摘要 + D-105 补记为恢复锚。
- **%5 scanner 真数已出**：`R5-SCANNER-HARDENED.md`（sha256=`bee004a2d55ecebc74e4dfbb79456434021b5855a8346cc2f5dbb4f423252426`）只改 scanner/重扫既有 probe output，未训练、未改 expected。hardened expected-empty adapter `any_tool_call_fail`=R2b/R3/R4 **9/9/9**；adapter total **9/9/10**（R4 另有 `QUERY_EXPECTED_TO_ACTUATION`）；cross-track product hard-gate total **13/13/14**。
- **R5 当前态**：%2 authority 6 冲突已回；%5 scanner 重扫真数已回；%3 对抗审两者修法待审；%1 待训不动。R5 配方/qa=0 硬门松动仍不得拍，等量尺修复+%3 审后再进 grill。
- **送达坑沉淀**：SEC3 已落 `SEC3-DISPATCH-BACKTICK-PITFALL.md`，反引号经 zsh 命令替换吃掉 message 关键词；全局 swarm-commander §16 + lessons M 条由磊哥收口亲落。

## 🔴 D-097 翻案 + R3 夜战管线（22:0x 态，压缩恢复第一读此段）
- **翻案**：门轨 11/64 case mount-invalid（A5 错位拼接+B6 挂载缺失，根因=case source_sample_id 错指→probe_harness.py:392-401 按 train_row 拉 mount）→ A/B 有效上限 10/15+9/15 被 adapter **打满**=有效面 100%；扩展轨 0/102 净；真模型缺陷只剩 qa 负面（修复中）。D-095 数字不变诊断重写（D-097）。
- **夜战管线态**：量尺 v3+validity 常设门 ✅（三重亲核+负例自测）｜QNEG 154 行机械门 ✅｜双 judge PASS_WITH_NOTES ✅｜manifest v3 修订 ✅（e79317ba）｜**%1 重评 v3 执行中**（base+adapter 配对重跑，v2 锚废止于 v3 面）｜**%5 组装 5653 执行中**（byte-preserving append+守恒断言）→渲染+三静态门→host 双阈值+watchdog --armed→**条件式 qa 修复短训**（f044-r3-run.sh 已备，knobs 原封）。
- **磊哥晨键**：R3-6 正式训练 1800 iters（若重评+qa 轮全绿）；晨报骨架=docs/handoffs/2026-07-05-r3-overnight-morning-brief.md。

## 分支线夜产全景（23:0x 态，磊哥 D-100 令兑现）
- **交叉审计链 X1-X9 全闭环**（M.24 首夜实证）：四份分支图纸全过异审出 v2（W48 grill 残余/W49 UIUE 合并/W50 接线含 basis gap ⭐B 解法/W51 宏场景）；X5 审 commander 抓 4 P1 全吃（D-102 双 ERRATA）；X7 抓 pct4 未实装 P0→OPT2-FIX 实装+签核关闭。
- **架构优化盘落地**：OPT1 量尺构造 join-by-schema 根治设计+补丁草案｜OPT2 watchdog 三 profile config 化+pct4 实装（正式 1800 定版 sha e8257fab）。
- **下阶段预备**：W52/W53 R3-eval 跑道+Launch Packet R3 对齐（数据面 delta 显式）｜W54 thin-bridge OpenSpec 草案（DRAFT 待磊哥拍 propose）。

## 🏁 T-C 完成（19:05 里程碑）
- **R2b 短训 600/600 完成零事故**：final val loss **0.010**（轨迹 2.584→0.217@200→0.126@400→0.010@600）、train loss 0.013、峰值 17.974GB、墙钟 ~3h13m、adapter sha 待 %1 receipt。W46 军医中期体检 GREEN（LR 残差 1e-12/梯度 56 更新全健康/update28 孤立尖峰已归因）。
- **T-D 已自动接跑**：%1 预置执行令触发（receipt→内存释放确认→门轨→扩展轨→只报数）；训后宿主 free 87%、swap 2608M 收缩中（T-E 门 swap≤1GB 待观察，不过则按 D-094 上抛二择）。

## 前态（T-C 训练巡航）
- **活动 run（唯一）**: `F044-shorttrain-run-20260704T155204+0800`（%1 executor 线程；Iter ~170/600；峰值 17.974GB；ETA ~19:25）。HUNG(145141)/CRASH(153413) 已归档且 eval-manifest 双排除。
- **磊哥已拍**: D-094 不重启 B 路线（GUI 已由磊哥清场，swap 5117M→2903M 回落中）；D-085 R2b 门 A≥12+B>9+D≥18+qa=0+极性单列。
- **时序**: 训完 → T-D 双轨 eval（W35 跑道预检零 drift，命令清单就绪）→ verdict 模板机械填空（F044-R2B-VERDICT-TEMPLATE.md）→ host-baseline 实采（swap≤1GB+free≥21GB fail-closed）→ 六条件+Launch Packet 全绿 → 正式训练 1800 iters 通宵（FORMAL-NIGHT-RUNBOOK.md 逐行执行）。
- **在途**: %3 W45 watchdog P1×2 修复（自适应上限+--shadow 开关）+双例重验；其余 worker 交付均收讫亲核。
- **正式配方（静态锁定）**: formal-train-config.yaml = R2b 同款唯 iters1800/updates450/warmup36；LR 运行时核验工具 tools/verify_formal_lr_schedule.py（rc0=450 match / rc66=stale）。

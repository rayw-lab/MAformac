# Loopaudit Megarun — Round 03 修复官报告

> 2026-06-23 · 修复官第3轮 · 审计发现 8 条（finding 数组实为 8 项；severity 全 P1）逐条修复
> 真实决策锚：口径终拍 562/2159/54.1%/族外 976/1831（磊哥 2026-06-23 亲拍，534/2086/52.3%/1004/1904 全废）；范式翻案 generic frame→D-domain 具名工具。
> 文档先行：openspec specs 未动（守 agree-before-build），本轮只改 grill SSOT / paradigm / CLAUDE / A2 README / cross_section_check.py。

## 修复数：8 / 8

## files_touched

1. `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md`
2. `docs/grill-tournament/grill-decisions-master.md`
3. `docs/grill-tournament/cascade-inventory.md`
4. `scripts/cross_section_check.py`
5. `CLAUDE.md`
6. `docs/research/2026-06-22-a2-codebase-audit/README.md`

## 逐条 finding → 怎么改

### F1（P1）paradigm §14 second_turn 表「合计 260/2086（12.5%）」用废口径 2086
- **本机核实**：python 复算 boundary §1 权威族行求和 = 2159、device=191、intent=562（全对）；second_turn 表 per-family 分母求和 = 2086（旧 534-era）；分子求和 = 260；260/2159=12.0%、260/2086=12.5%（均确认）。
- **怎么改**：在 §14 second_turn 表前加段首边注（标 per-family 分母=534-era 废口径、权威族行指 boundary §1、分子/占比相对排序仍可用作选族依据、绝对分母待按 562 重算）；合计行 `260/2086` 就地加注「分母 2086=废口径、按 2159 重算占比 12.0%」+ 表后加占比绝对值口径注（族间排序不变，选族结论不受口径反转影响）。保留分子分析价值不误导（finding 首选方案）。

### F2（P1）§14 second_turn per-family 分母与 boundary §1 权威族行 6/10 族冲突，且 §14 是全仓 cite 的口径权威源却段内矛盾
- **怎么改**：与 F1 同处段首边注，采用 finding 的 (b) 方案（就地加边注，不强行 2086→2159 改总额——会让 numerator/denominator 口径错位）。边注明确「占比相对排序仍可用、绝对分母待按 562 重算」，并点名空调 156→212 / 座椅 658→696 等逐族差异，防未来 grill 把 2086 当 562 时代一手分母。

### F3（P1）master §0:24 称「cascade §0 删除内联列举仅留指针」与 cascade §0:6 仍物理内联废口径并存
- **怎么改**：采用 finding 推荐的 ② 方案（保留 cascade §0 narrative 上下文价值）。
  - master §0:24：改措辞为「废口径【权威定义表】单一物理副本=本表；cascade §0 是 562-vs-534 解释性 narrative（非权威定义表），旧『删除内联仅留指针』措辞不准——narrative 未删也不该删」。
  - cascade §0:6：加段首注明「本段=562-vs-534 解释性 narrative，非废口径权威定义表；权威定性指回 master §0；master §0:24 已同步修正措辞」。
  - 两表角色厘清（权威定义 vs 解释 narrative），不再构成双权威表。

### F4（P1）GOV3 cross-section enforce 不覆盖新 grill SSOT + 无口径锚 = enforce 声称 vs 实际门空档
- **本机核实**：`cross_section_check.py` 跑通；新口径锚以合成 drift（`10 族 intent = 534`）测得正确报 violation、`族外 intent = 976` 正确放行；全仓实跑 consistent=True 无误报；`make verify-cross-section` 端到端通过（16 baseline files）。
- **怎么改**（三部分全落）：
  - ① `BASELINE_GLOBS` 加 `docs/grill-tournament/*.md`（cascade/master/final-grill/ledger 纳入扫描）。
  - ② 新增 `CALIBER_ANCHORS`（口径单值锚：`10 族 intent=562 / 10 族 device=191 / 族外 intent=976`）+ `INT_AFTER` 严格赋值匹配（锚后必须 `=/：` + 整数才触发，prose/表格不触发避免误报）；`SUPERSEDED_MARKERS` 扩 `废口径/作废/已废/禁引/旧口径/534-era/边注` 跳过废口径行；输出加 `caliber_violations`、返回码改 `out["consistent"]`。
  - ③ master §6 + cascade §5 元层守则 item 3 把「GOV3 enforce 候选」改标「finding round-03 已落地」+ 明示机制边界（只治 mechanical 不治 correctness、口径锚只在赋值断言行触发漏表格态、GOV3 完整设计仍待 grill Q09）。

### F5（P1）CLAUDE.md 仍称旧 roadmap「唯一推进事实源/必读第一」，与已拍 Q22 矛盾
- **本机核实**：master §2:77 Q22 已拍「roadmap 标 historical，新单源=A2 exec-plan 候选，同步 CLAUDE/README/handoff 模板」；CLAUDE.md:115/130 无 historical 注。
- **怎么改**：
  - CLAUDE.md:115：「唯一推进事实源=roadmap」改为「推进事实源已迁移(Q22)」，roadmap 标 historical（0/34+范式翻案前旧基线），新权威=grill-decisions-master + paradigm + cascade-inventory，A2 exec-plan 收口后转 progress SSOT。
  - CLAUDE.md:130：起手读顺序改（grill-decisions-master/paradigm/cascade 升必读第一，旧 roadmap 降溯源标 historical/Q22）。
  - cascade T0 CLAUDE 行（§2 :62 + §1.4 #1）verdict 从 verify-only 升 modify，补 Q22 roadmap 降级同步记录（原 verify-only 漏 Q22 = §35 级联未落地）。

### F6（P1）A2-audit README（CLAUDE 明文「必读」）5+ 处称 534=权威无 in-doc override banner，与 boundary 已加 562 banner 不对称
- **本机核实**：README 534 出现 17 次、头部无 562 banner；boundary 文件头已有 562 banner（对称缺失成立）。
- **怎么改**：README 头加 562 override banner（指回 master §0 + paradigm §14:224，562=intent 非工具数，正文 benchmark 历史值保留不改仅头部覆盖口径定性）；cascade A2 README 行 verdict 从 no_change 升 banner，记录不对称处置已修。

### F7（P1）paradigm §14 两张 per-family 表用 534-era 行数与 §14:224 终拍 banner 段内分叉（claim-vs-reality 第10变体）
- **说明**：与 F1+F2+F8 同根（§14 段内分叉）。second_turn 表已由 F1/F2 边注覆盖；value.type/fc_flags 表由 F8 边注覆盖。两表均加段首口径边注（per-family 分母=534-era、相对趋势可用、绝对计数待按 562 重算）。:253「合计 260/2086」按 finding 方案保留 2086 但就地标废口径 + 给 2159 重算占比。

### F8（P1）second_turn + value.type/fc_flags 两表 534-era per-family 行数段内分叉
- **怎么改**：
  - second_turn 表：F1/F2 的段首边注 + 合计行注 + 表后占比口径注（已落）。
  - value.type/fc_flags 表（§14:276 区）：加段首口径边注（per-family 计数=534-era 族内行数求和 2086、与权威 562/2159 不一致、用途=value.type 相对趋势、相对排序不受口径反转影响、绝对计数待按 explicit-allowlist 562 重算）。

## 验证
- `python3 scripts/cross_section_check.py` → consistent=True, caliber_violations=[], drifts=[]（16 baseline files）
- `make verify-cross-section` → consistent=true（端到端通过）
- 合成 drift 测试：`10 族 intent = 534` 正确报 violation / `族外 intent = 976` 正确放行（门非 no-op）
- `python3 -m py_compile scripts/cross_section_check.py` → SYNTAX OK
- 所有写入数字 python 复算坐实：分子和=260、boundary 行和=2159、device=191、intent=562、旧分母和=2086、260/2086=12.5%、260/2159=12.0%

## 口径纪律遵守
- 只回写口径 534→562（paradigm/master/cascade/CLAUDE/A2 README）；research/teardown 历史档 benchmark 数未动（A2 README 正文 benchmark 保留，仅加头部 banner 覆盖口径定性）。
- device 191 不变。
- 工具数全部写 [待 value-form 实算] 占位，禁把 562 当工具数。
- openspec archived specs 未直接改（守文档先行 + agree-before-build；本轮无新建 change skeleton 需求，所有改动为 grill SSOT / 元认知账本 / enforce 脚本 / 活基线 CLAUDE）。

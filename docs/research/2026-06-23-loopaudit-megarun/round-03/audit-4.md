# Loopaudit Megarun — Round 03 / 审计员 #4

> **round**: 03（第 3 轮）
> **审计员**: #4
> **负责维度**: 内部一致（段间矛盾 / U10 四态 / 总数对账） + 历史档 vs 活档（非口径 534 误改 / 历史档 banner 不动正文）
> **审计范围**: grill SSOT（grill-decisions-master / cascade-inventory）+ 562 口径全仓统一 + 活基线级联（CLAUDE/SRD/MASTER/decisions/state-cells）+ paradigm + boundary + OpenSpec change skeleton
> **方法**: 本机 Read + grep + python 复算实核，不凭印象
> **verdict**: **has_p0p1 = true**（0 P0 / 3 P1 / 2 P2）

---

## 实核痕迹（本机实跑）

1. **562 口径全仓**：grep `534|2086|52.3|1004|1904` 于 8 个被审文件 → CLAUDE/SRD/MASTER 各 1 hit、boundary 4 hits，**逐条核全部是「标作废」上下文**（非当权威），state-cells 0 hit。✅ 口径回写干净。
2. **boundary §1 per-family 表 python 求和**：device=191 / intent=562 / 行=2159，与文档头权威值**三项全 match**。✅ 内部一致。
3. **master §2 状态统计 per-row 提取**（清洗 awk 转义管道噪声后）：✅5 / →A2合同 4 / 🟡16 / 🔴16 = 41，与 §2 line 99-102 claim **全 match**。✅
4. **master §5 完整性自检**：§5 各组表 unique Q = 32（16🔴+16🟡），GOV6+AUD2+CAS7+TRN8+UIX9 = 6+2+7+8+9 = 32，与 §2 统计**全 match**。✅ cross-section 纪律严密。
5. **cascade §1.2 ↔ §2 对账**：T0=8/T1=25/T2=5/T3=31/T4=3/T6=4 逐 Tier `grep -c` 实测，全 match；口径 A = 8+25+5+31+3+11+4 = 87。✅
6. **DemoVisualState 代码核**：`Core/State/DemoVehicleStateStore.swift:17` enum 实有 7 case（normal/satisfied/changing/blocked_with_alternative/blocked_hard/unsafe/unknown）= U10「7 态」file:line 准确。✅
7. **4 个 OpenSpec change skeleton**：`openspec list` 可见（migrate-d-domain/retrain-c5/rebuild-c6/define-demo-golden-run-and-voice），全带 DRAFT banner + 决策权威源指针，task 0/12~0/15 未 apply。✅ 守 agree-before-build。
8. **T5 banner PENDING 诚实性**：handoffs 3/25、dispatches 0/13 有 banner = cascade「T5 PENDING」claim 与实际一致。✅ mark_historical（capabilities/function-spec-full）banner 已落 = 阶段1 执行属实。✅

---

## Findings

| # | severity | issue | location | fix |
|---|---|---|---|---|
| 1 | **P1** | **CLAUDE.md 仍称旧 roadmap 为「唯一推进事实源/必读第一」，与 ✅已拍 Q22 矛盾**。Q22（master §4.4 / §2 line 77）已拍「旧 roadmap-2026-06-20 标 **historical**，新单源 = A2 exec-plan 候选」且**明文「同步 CLAUDE/README/handoff 模板」**。但 CLAUDE.md:115「⭐ 唯一推进事实源 = roadmap-2026-06-20」+ :130「必读第一」**无 historical 注**（仅 :109 有「C5 部分以 c5-recovery 为准」局部 caveat，未触及「唯一/必读第一」定性）。cascade T0 把 CLAUDE 标 `verify-only/仅核对(微改)`，**漏掉 Q22 强制的 CLAUDE 同步** = §35 决策→文档组级联未落地。 | `CLAUDE.md:115` + `CLAUDE.md:130`；cascade `T0 CLAUDE row`（§2 line 62）误标 verify-only | CLAUDE.md:115/130 给 roadmap 加 historical 注（指 Q22：progress SSOT 待 A2 exec-plan，旧 roadmap 标 historical）；cascade T0 CLAUDE 行 verdict 从 verify-only 升 modify（补 Q22 roadmap 降级同步），并入阶段 2 |
| 2 | **P1** | **A2-audit README（CLAUDE 明文「A2 派单前必读」）内部 5+ 处断言「paradigm §14 权威 = 191/534/2086」，与全仓终拍 562 直接矛盾，且无 in-doc 562 override banner**。README:10/29/50/70/85/216/238 反复称 534=权威、把 562 标为「A1-A9 前」非权威——这是终拍**反转前**的旧定性。cascade T3 verdict 承认此（「README 历史档不改正文，口径以本文头 + paradigm §14:224 为准」）但**仅靠 cascade 外部 pointer 覆盖，未在 README 头加 banner**。boundary 文件已加 562 banner（正确），同等被引、断言相反的 README 却未加 = 不对称处置。必读 doc 5 处断言废口径=权威 = drift trap（违 cascade §5 元层守则 #4「SUPERSEDED 文档头 banner」）。 | `docs/research/2026-06-22-a2-codebase-audit/README.md:10,29,50,70,85,216,238`（无 562 override banner） | README 头加 banner：「⚠️ 口径已终拍：全仓权威 = 562 intent（磊哥 2026-06-23），本文内「534=权威」为终拍反转前 A2 盘点态，仅作历史溯源；A2 派单口径以 grill-decisions-master §0 / paradigm §14:224 为准（562=intent 非工具数）」。正文 benchmark 保留不改，仅加头部指针 |
| 3 | **P1** | **paradigm §14 两张 per-family 表（second_turn_refs + value.type/fc_flags）仍用 534-era per-family 行数，与同节 §14:224 终拍 562/2159 banner 段间分叉**。§14:253「合计 260/2086」denominator = 534-era 行总和（python 复算各族分母求和 = 2086，≠ 权威 2159）；逐族分母（空调 156/座椅 658/灯光 414…）= 534-era 族内行数，与 boundary §1 权威族行（空调 212/座椅 696/灯光 468…）逐族不符。同 §14 line 224 banner 已宣「534/2086 全废」，line 253 却现 2086 = claim-vs-reality 第 10 变体（段内分叉）。表性质是 demo 剧本优先级描述（非口径决策载体），故 P1 非 P0。 | `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:241-253`（second_turn 表）+ `:280-291`（value.type 表）+ `:253` 合计 2086 | 两表加段首边注「per-family 分母为 534-era 族行（A1-A9 后），与权威 562/2159 per-family 不一致，仅作多轮价值/value.type 相对趋势参考；族行权威以 boundary §1 为准」；或按 boundary §1 权威族行重算分母（best），:253 合计 2086→2159 |
| 4 | **P2** | **U10 在权威源 paradigm §18 标题写「状态 UI 三态」，与 body 列的 4 态（clarify/unsupported/safety_refusal/crash）+ 活档 master 全部标「四态」矛盾**。master §3:123 / §4.5:200 / U-续批纪律:150 一致写「四态」（正确，body 4 项）；但其引用的一手源 paradigm §18:485 标题写「三态」（body 仍列 4 项）= 权威源标题/body 自相矛盾。master 已正确规整为四态，bug 在 paradigm §18 标题。 | `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:485`（标题「状态 UI 三态」，body 4 态） | paradigm §18:485 标题「三态」→「四态」（与 body clarify/unsupported/safety_refusal/crash 4 项及 master 一致） |
| 5 | **P2** | **master §0:15 AUD↔Q 配对顺序错（AUD1/AUD2 与 Q01/Q02 错位）**。§0:15「AUD1/AUD2/AUD5（=Q01/Q02/Q05）」隐含 AUD1=Q01、AUD2=Q02；但 §2 表自身 source 列 = **Q01 source「AUD2,G2」/ Q02 source「AUD1」**（即 AUD1=Q02、AUD2=Q01，配对反了）。结论（{AUD1,AUD2,AUD5}={Q02,Q01,Q05} 全 →A2合同）作为集合**正确**，仅 positional 配对标错，不影响 35/32 reconciliation 结果。讽刺：该行自述「本机 §2 source 列复核」却把配对核反。 | `docs/grill-tournament/grill-decisions-master.md:15`（AUD1/AUD2=Q01/Q02 配对反） | §0:15 改「AUD2/AUD1/AUD5（=Q01/Q02/Q05）」或改述「AUD1=Q02·AUD2=Q01·AUD5=Q05」与 §2 source 列对齐 |

---

## summary

第 3 轮第 4 审计员（内部一致 + 历史档vs活档 维度）：**0 P0 / 3 P1 / 2 P2**。

**整体质量高**：562 口径全仓回写干净（活档 534 残留全是「标作废」上下文）、boundary per-family 表 python 求和精确 191/562/2159、master §2 状态统计 + §5 完整性自检 + cascade §1.2↔§2 对账三处 cross-section 全部本机复算 match、4 OpenSpec change skeleton 守 DRAFT/agree-before-build、T5 banner PENDING 诚实标注。这是经过多轮 cite-verify 打磨的成熟基线。

**残留 3 P1**：均为「决策晶体已对、级联未全落」的 §35 长尾——(F1) CLAUDE 旧 roadmap 仍称「唯一事实源」与 ✅Q22 historical 决策矛盾（cascade 还把 CLAUDE 误标 verify-only 漏此同步）；(F2) A2-audit「必读」README 5+ 处断言 534=权威无 562 override banner（不对称：boundary 加了 banner README 没加）；(F3) paradigm §14 两 per-family 表 534-era 行数与同节终拍 562 banner 段内分叉（260/2086 vs 权威 2159）。2 P2 = paradigm §18 U10 标题「三态」笔误（body 与 master 均四态）+ master §0 AUD↔Q 配对顺序错（集合结论正确）。

无一动摇范式翻案 / 562 终拍 / change skeleton DRAFT 的核心结论；全部是边注/banner/标题级回写。

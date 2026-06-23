# Loopaudit Megarun — Round 04 / 审计员 #4

> **round**: 04（第 4 轮）
> **审计员**: #4
> **负责维度**: 内部一致（段间矛盾 / U10 四态 / 总数对账）+ 历史档 vs 活档（非口径 534 误改 / 历史档 banner 不动正文）
> **审计范围**: grill SSOT（grill-decisions-master / cascade-inventory）+ 562 口径全仓统一 + 活基线级联（CLAUDE/SRD/MASTER/decisions/state-cells）+ paradigm + boundary + OpenSpec change skeleton
> **方法**: 本机 Read + grep + python 复算实核，不凭印象
> **verdict**: **has_p0p1 = true**（0 P0 / 1 P1 / 2 P2）

---

## 实核痕迹（本机实跑）

1. **boundary §1 per-family python 求和**：device=191 / intent=562 / 行=2159，与文档头权威值三项全 match。✅
2. **contract jsonl 实跑**：`wc -l`=3990 / unique device=671 / unique intent=1538，与全集口径 match。✅
3. **562 口径全仓**：CLAUDE.md / SRD / MASTER / state-cells / boundary 内 `534|2086|52.3|1004|1904` 逐条核 → 全部「标作废 / 反转废 / 级联回写」上下文，无当权威使用。✅ 口径回写干净。
4. **OpenSpec change skeleton（4 个）**：`openspec list` 可见（migrate-d-domain 0/12 / retrain-c5 0/14 / rebuild-c6 0/14 / define-demo-golden-run-and-voice 0/15），全带 `⚠️ DRAFT SKELETON（守 agree-before-build）` banner，0/N tasks 未 apply。✅ 守文档先行。
5. **change skeleton 口径**：534 仅出现在「534→562 级联回写 / 534 系列全废」task 上下文；562 = 权威；retrain-c5 明文「10 族 562 intent scope / 不训全集」。✅ 与 A3 决策一致。
6. **state-cells.yaml**：D-domain 注释正确（surface 与 cell 正交，工具名不携带边界）；execution_range 18-32℃/1-10 正确；无 534 泄漏。✅
7. **round-03 fixes.md 复核**：F1-F8 共 8 修 = paradigm §14 per-family 两表边注（F1/F2/F7/F8 已落，:241/:281 段首边注 + :255「260/2086」就地标废）+ master §0:24 narrative 角色厘清（F3）+ cross_section_check.py GOV3 enforce（F4）+ CLAUDE roadmap historical（F5，:115/:130 已落）+ A2 README 562 banner（F6）。**但 round-03 audit-4 的 2 P2 未进 fixes.md 范围（F1-F8 全是 P1）→ 2 P2 carryover 未修**（见 finding 2/3）。
8. **U10 「四态」一致性**：master §3:123 + §4.5 = 四态（clarify/unsupported/safety_refusal/crash，正确）；paradigm §18:490 body 列 4 项但标题仍「三态」（finding 1）。

---

## Findings

| # | severity | issue | location | fix |
|---|---|---|---|---|
| 1 | **P1** | **SRD（活基线 T0 起手必读）断言「LoRA 训练层 = 全集 3990 泛化（模型吃全集学泛化）/ 训练锚全集」，与已拍 A3 决策「10 族不训全集（562 intent）」直接矛盾——核心训练范围决策违背**。SRD:95「② LoRA 训练层 = 锚 3990 全集泛化（能力层，模型仍吃全集学泛化）…训练锚全集」+ SRD:206「③ LoRA 训练层 = 全集 3990 泛化（能力层，模型吃全集学泛化）」。但 paradigm §13.A3:126「A3 LoRA 范围 ✅（grill 3 拍）：10 族子集（562），族外 unsupported 拒识」+ §16:211「A3 范围 ✅ **10 族不训全集**」+ master §4.1:163「A3 LoRA 范围 10 族子集（562 intent）」+ 新 OpenSpec change `retrain-c5-lora-d-domain` proposal:9/23「10 族 562 intent scope」**全一致拍了「不训全集」**。SRD 把 paradigm **已被 §16:215 supersede 的旧 §6 措辞**（§3:41 表「训练范围 全量 / LoRA 锚 3990 泛化」+ §6:58「训练全集泛化」+ §6:82「LoRA 训练锚 3990 全集（能力层泛化）」）原样搬进活基线（SRD:95/206 显式 cite「paradigm §6/§2」=copy 了 stale §6 非 corrected §16:215）。**双层失守**：① paradigm §3:41/§6:58/§6:82 的「训练全集泛化」旧措辞**无 inline SUPERSEDED 标记**指向 §16:215（§16:215「覆盖前文一切『训练全集泛化』旧表达」在 line 216 = §6:82 之后，读者先撞 stale）；② SRD 据 stale §6 propagate 进 T0 活档，**cascade-inventory SRD 行（:66）只标「L2 泛化 改 10 族内泛化（非兜底全集）」= surface/runtime 覆盖维度，完全没识别 SRD 的 training-scope 断言违背 A3**（grep 全 cascade 无「训练锚/训练层/3990 全集/不训全集」命中）。未来实装者读 SRD（起手必读）先于 paradigm → 按全集 3990 建训练数据 = 直接复发 scope 错。 | `docs/srd-three-layer-intent-routing.md:95`（「LoRA 训练层 = 锚 3990 全集泛化…训练锚全集」）+ `:206`（「LoRA 训练层 = 全集 3990 泛化」）；根因 `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:41/:58/:82`（stale「训练全集泛化」无 inline SUPERSEDED）；遗漏 `docs/grill-tournament/cascade-inventory.md:66`（SRD 行未列此改点） | ① SRD:95/206 改「LoRA 训练范围 = 10 族 562 intent scope（按 scope_tier 拆四类数据：positive/unsupported/safety/followup），**不训全集 3990**（A3 已拍）；3990 是 canonical IR 派生源 + value-form 模糊说法**变体来源**，非训练 scope 本身」，cite paradigm §13.A3 / master §4.1 / §16:215（非 stale §6）② paradigm §3:41/§6:58/§6:82 stale「训练全集泛化」行加 inline `[SUPERSEDED → §16:215 / §13.A3：10 族不训全集]`③ cascade SRD 行（:66）补改点 ④「② L2 泛化改 10 族内」=训练范围维度（10 族不训全集 562），与「runtime 族外 unsupported」分开列，防再被当成同一条 surface narrative |
| 2 | **P2** | **paradigm §18:490 U10 标题仍「状态 UI 三态」，与 body 列的 4 态 + 活档 master「四态」段内矛盾（round-03 audit-4 P2 #4 carryover，round-03 fixes.md F1-F8 未覆盖）**。§18:490 标题「状态 UI 三态」，body 明列 `clarify/unsupported/safety_refusal/crash` = 4 态；master §3.U10:123 + §4.5:200 一致写「四态」（正确）。权威源标题/body 自相矛盾。round-03 同一审计员已报此项 P2，但 round-03 修复官只修了 3 P1（F1-F8 全 P1），2 P2 漏修。 | `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:490`（标题「状态 UI 三态」，body 4 态） | §18:490 标题「三态」→「四态」（与 body clarify/unsupported/safety_refusal/crash 4 项及 master 一致） |
| 3 | **P2** | **master §0:15 AUD↔Q 配对顺序仍反（round-03 audit-4 P2 #5 carryover，未修）**。§0:15「AUD1/AUD2/AUD5（=Q01/Q02/Q05）转 →A2合同」隐含 AUD1=Q01、AUD2=Q02；但 §2 表自身 source 列 = **Q01 source「AUD2,G2」/ Q02 source「AUD1」**（即 AUD1=Q02、AUD2=Q01，positional 配对反了）。集合结论 {AUD1,AUD2,AUD5}={Q02,Q01,Q05} 全 →A2合同**正确**，仅 positional 配对标错，不影响 35/32 reconciliation。round-03 已报此 P2 但未修。 | `docs/grill-tournament/grill-decisions-master.md:15`（AUD1/AUD2=Q01/Q02 配对反） | §0:15 改「AUD2/AUD1/AUD5（=Q01/Q02/Q05）」或改述「AUD1=Q02·AUD2=Q01·AUD5=Q05」与 §2 source 列对齐 |

---

## summary

第 4 轮第 4 审计员（内部一致 + 历史档 vs 活档 维度）：**0 P0 / 1 P1 / 2 P2**。

**新 P1（本轮首次 catch，prior 3 轮含 round-03 均漏）= SRD 训练范围决策违背**：活基线 SRD（T0 起手必读）在 :95 / :206 两处断言「LoRA 训练层 = 全集 3990 泛化，模型吃全集学泛化」，与已拍 A3 决策「10 族不训全集（562 intent）」**直接相反**。根因是 paradigm 文档**段内分叉**——§16:215 已宣「覆盖前文一切『训练全集泛化』旧表达」，但 §3:41/§6:58/§6:82 的旧措辞**无 inline SUPERSEDED 标记**（且物理位置在 §16 之前，读者先撞 stale），SRD 据 stale §6 把 superseded 措辞 propagate 进活档。cascade-inventory 的 SRD 行只标了「L2 泛化改 10 族内 surface narrative」维度，**完全没识别 training-scope 断言违背 A3**（grep 全 cascade 零命中）。这是「决策晶体已对（A3 拍了、change skeleton 也对），但旧措辞未标 SUPERSEDED + 被活档复制」的 §35 级联失守，且新 OpenSpec change skeleton（retrain-c5「10 族 562 不训全集」）已对的情况下 SRD 反而是唯一带错的活档——实装者起手读 SRD 早于 paradigm/change → 直接按全集 3990 建训练数据复发 scope 错。这是 claim-vs-reality 第 10 变体（SSOT 段间分叉）在「核心训练范围决策」维度的实例。

**2 P2 = round-03 carryover（未修）**：(F2) paradigm §18:490 U10 标题「三态」与 body 4 态 + master「四态」矛盾；(F3) master §0:15 AUD↔Q 配对顺序反（集合结论正确）。两项 round-03 audit-4 已报 P2，但 round-03 修复官只修了 3 P1（fixes.md F1-F8 全 P1），P2 系统性漏修——本轮重新登记，避免再被「修复官只扫 P1」漏掉。

**整体质量高**：562 口径全仓回写干净（无活档把 534 当权威）、boundary per-family python 求和精确 191/562/2159、4 OpenSpec change skeleton 守 DRAFT/agree-before-build/562 口径、state-cells D-domain 正交注释正确、paradigm §14 per-family 两表 round-03 边注已落。核心结论（范式翻案 / 562 终拍 / change skeleton DRAFT）无动摇；P1 是「活档 SRD 漏跟 A3 决策反转 + paradigm 段内 stale 措辞未标 SUPERSEDED」的级联长尾，修法 = SRD 改 10 族不训全集 + paradigm stale 行加 inline SUPERSEDED + cascade SRD 行补改点；2 P2 是标题/配对级回写。

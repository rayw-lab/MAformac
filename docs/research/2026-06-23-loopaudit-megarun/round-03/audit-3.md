# Loopaudit Megarun — Round 03 · 审计员 #3

> **round**: 03
> **审计员**: #3
> **负责维度**: 范式一致（D-domain / 无 generic frame drift） + 可执行性（change skeleton 合规 / 物理落点可派单）
> **verdict**: has_p0p1 = true（无 P0；2 个 P1）
> **as-of**: 2026-06-23

---

## 实核痕迹（本机 Read/grep/python 实跑，非凭印象）

### 范式一致维度
- 读全 `grill-decisions-amend-paradigm-tool-surface.md`（490 行，两页）+ `grill-decisions-master.md` + `cascade-inventory.md` + `mvp-10family-device-boundary.md` + `CLAUDE.md §9 banner` + `srd-three-layer-intent-routing.md` 头 + `state-cells.yaml` 全文。
- **口径 562 cross-section 实核**：6 个活基线文件 `562` 计数 = master14 / cascade21 / paradigm25 / boundary6 / CLAUDE1 / SRD2；`2159` = master5/cascade5/paradigm9/boundary5/CLAUDE0/SRD2。**全部用 562/2159 系列，无 534 当权威残留**（534 出现处全在「废口径」语境，grep 逐一核）。
- **boundary §1 per-family 表 python 求和**：device=191 / intent=562 / rows=2159 = 声明值**精确相等**（True/True/True）。
- **jsonl 一手复算**：`contracts/semantic-function-contract.jsonl` rows=3990 / unique device=671 / unique intent=1538 = 声明值精确相等。
- **族外算术**：671-191=480 / 3990-2159=1831 / 1538-562=976 / 2159/3990=54.1% 全部精确。
- **D-domain banner 落地**：`state-cells.yaml:9-15` 已有「surface 边界（范式翻案级联）」banner（execution_range/readback 属 C2 与 surface 正交，model-visible=D-domain 具名工具，IR 仍 device×action）。`SRD` 头有 v2 surface framing banner。`CLAUDE §9:111-113` banner 范式翻案 + 191/562/534 系列废 一致。
- **generic frame 残留分流**：active 文档（state-cells/SRD/CLAUDE）均已显式翻案；`set_cabin_ac`/`tool_call_frame` 残留在 `generated/D_domain.tools.json`(len 6 spike 冻结)、`Core/Contracts/ToolContractCompiler.swift`、`contracts/capabilities.yaml`、`Core/Bench/C6VehicleToolBench.swift` 等 = A2 重构目标（已在 4 change skeleton + cascade T1 标 mark_historical/modify，**不是文档漏标的 drift**）。

### 可执行性维度
- `openspec validate <each> --strict`：4 个 skeleton（migrate-d-domain-tool-surface / retrain-c5-lora-d-domain / rebuild-c6-four-layer-bench / define-demo-golden-run-and-voice）全 **valid**；`openspec list` 可见（0/N tasks）。
- **MODIFY 依赖的 archived spec 存在性核**：semantic-function-contract / tool-execution / lora-training / vehicle-tool-bench 4 个 `openspec/specs/*/spec.md` 全 EXISTS。
- **ADDED 不撞名核**：demo-golden-run / voice-pipeline 在 `openspec/specs/` 下 NOT FOUND（ADDED 合法）。
- **DRAFT 守 agree-before-build**：4 个 proposal 头全有「⚠️ DRAFT SKELETON…守 agree-before-build：人审定 propose 前不进 apply、不写实现代码」；spec delta 用占位 Scenario（placeholder）但结构合规（ADDED/MODIFIED Requirements + Scenario GIVEN/WHEN/THEN）所以 strict 过。
- **skeleton 可发现性核**：master §4.4:197 + cascade T1:107-110 均记录 4 skeleton 索引 + 依赖序 + DRAFT 状态。
- **drift gate 实核**：`Makefile:4` GENERATED_CONTRACTS 仅含 5 个 `contracts/` 文件，`generated/` **不在** gate（确认 Q02/P0-1 documented state；A2 必补，已在 skeleton tasks 5.1）。
- **device-map.json 实核**：`generated/10-family-device-map.json` = 223 keys（= documented「223 含 disputed 旧 codegen 过期」，权威 191；非漏标）。
- **harness enforce 实核**（关键 finding）：读 `scripts/cross_section_check.py:22-35`，BASELINE_GLOBS 只含 `docs/c5-recovery-2026-06-22/*.md` + `roadmap-2026-06-20`；ANCHOR_KEYWORDS 只含 `mp_positive_action`。新 grill SSOT（`docs/grill-tournament/*`）+ 口径锚（562/534）**均不在扫描范围**。

---

## Findings

| # | severity | issue | location | fix |
|---|---|---|---|---|
| 1 | P1 | **master §0 关于 cascade §0 状态的声称与事实不符（claim-vs-reality 第10变体活体）**。master §0:24 明文「cascade §0 删除内联列举仅留指针，本表为唯一物理副本」，但 cascade §0:6 仍**物理内联列举** 废口径值「534 / 2086 / 52.3% / 族外 1004 / 1904 系列全作废」——即两份物理废口径表仍并存，master 声称的「单一物理副本」状态未达成。当前两表值一致（都 562 权威/534 废），暂无值分叉，但 = 项目自己警告的 drift-waiting reservoir。 | `docs/grill-tournament/grill-decisions-master.md:24` vs `docs/grill-tournament/cascade-inventory.md:6` | 二选一：① 真删 cascade §0:6 的内联枚举改纯指针（兑现 master §0:24 声称）；或 ② 改 master §0:24 措辞为「cascade §0 含 562-vs-534 解释性 narrative（非权威表），废口径权威定义仍仅本表」承认双副本但厘清角色。推荐 ②（cascade §0 的 narrative 对级联执行者有价值，删了反而丢上下文）。 |
| 2 | P1 | **GOV3 cross-section enforce 不覆盖本长跑新 SSOT + 口径锚 = enforce 层声称 vs 实际门空档**。master §6 称「`make verify` verify-cross-section 门（GOV3 enforce 候选）：本文纳入扫描范围后…单源一致」，但 `cross_section_check.py` BASELINE_GLOBS 不含 `docs/grill-tournament/*`（新 grill SSOT），ANCHOR_KEYWORDS 只有 `mp_positive_action` 不含 `562`/`534`/`191`。结果：本长跑全程在做的口径级联（534→562 全仓回写）**没有任何机械门兜底**，新 SSOT 文件（master/cascade）段间分叉靠人工 catch（正是 finding 1 这类）。master §6 用「候选」「纳入后」对冲了声称，但读者易误以为已 enforce。 | `scripts/cross_section_check.py:22-35`（BASELINE_GLOBS + ANCHOR_KEYWORDS）vs `grill-decisions-master.md:293` §6 + `cascade-inventory.md:276` §5.3 | ① BASELINE_GLOBS 加 `docs/grill-tournament/*.md`；② ANCHOR_KEYWORDS 加口径锚或新增「口径一致」检查（562/534/191/2159 跨文件单值断言，废口径行用 SUPERSEDED_MARKERS 跳过）；③ 在落地前，master §6 / cascade §5.3 把「GOV3 enforce 候选」明确标为「**尚未落地 enforce，当前靠人工 + loopaudit**」，避免读者误判已有门。 |

---

## Summary

范式一致维度：**无 P0/P1 范式 drift**。D-domain 范式（model-visible surface = 具名工具，canonical IR 仍 device×action）在所有活基线文件（CLAUDE/SRD/MASTER/state-cells/paradigm/boundary）一致落地；口径 562/2159/191 系列在 6 个活文件 cross-section 完全一致，且 boundary per-family 表与 jsonl 一手数据 python 复算**精确相等**（191/562/2159/3990/671/1538 全 True）；534 系列残留全在「废口径」语境正确标注。`generated/`/Swift 里的 `tool_call_frame`/`set_cabin_ac` 残留是 A2 重构目标（已正确归档 mark_historical/modify），非文档漏标。

可执行性维度：**4 个 change skeleton 全部合规可派单** —— strict validate 通过、MODIFY 依赖的 archived spec 全存在、ADDED 不撞名、DRAFT 守 agree-before-build、spec delta 结构合规（Requirement+Scenario）、skeleton 在 master §4.4 + cascade T1 双重索引可发现、依赖序 [1]→[4]/[5]→横切 清晰。

两个 P1 都是**文档元层一致性 / enforce 层声称 vs 实际**问题（非范式/口径本身错）：① master 声称 cascade §0 已去重但 cascade §0 仍内联列废口径（双物理副本 = drift-waiting，当前值一致）；② GOV3 cross-section 门实际不覆盖本长跑新 SSOT 与口径锚，enforce 声称偏乐观。两者均不阻塞派单（口径事实正确、skeleton 可用），但留着会让「单一 SSOT」承诺名不副实，建议本轮收口。

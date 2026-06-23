# Loopaudit Megarun — Round 01 / 审计员 #2

> **round**: 01
> **审计员**: 审计员 #2（事实准确 / 归类优先级 / 边界红线）
> **范围**: 融合大长跑全部产出（grill SSOT + 562 口径全仓统一 + U11-31 落档 + 活基线级联 + contracts + OpenSpec change skeleton + 历史档 banner + 脏区）
> **负责维度**: 事实准确（562/2159/54.1% 全仓一致无残留 534 口径）/ 归类优先级 / 边界红线（C1/C2/semantic-function-contract.jsonl 未误动 / 脱敏）
> **as-of**: 2026-06-23
> **verdict**: **has_p0p1 = true**（2×P1 in-scope 文件残留 534 + 1×P1 段间矛盾；无 P0）

---

## 实核痕迹（本机 Read/grep/python，非凭印象）

1. **口径权威坐实**：读 `grill-decisions-master.md §0 口径权威表` + `cascade-inventory.md §0` + `paradigm §14:224`（口径终拍 562）+ `mvp-10family-device-boundary.md:3` 文档头 → 终拍权威 = **191 device / 562 intent / 2159 行（54.1%）/ 族外 480 device / 976 intent / 1831 行**；废口径 = 534/2086/52.3%/1004/1904 系列。三处头部口径一致。
2. **per-family 表算术复核（python/bash 实算）**：boundary §1 per-family 表逐族求和 device=**191** ✅ / intent=**562** ✅ / 行=**2159** ✅（25+36+11+21+29+33+11+8+10+7 / 68+126+27+48+113+75+32+27+30+16 / 212+696+82+129+468+205+153+80+102+32）。表与权威口径自洽。
3. **redline 文件未误动（git + python）**：`git status --short` → `contracts/semantic-function-contract.jsonl` / `openspec/specs/semantic-function-contract/` / `openspec/specs/scenario-state-protocol/` 全 **unmodified**；`wc -l` jsonl=**3990**；python 复算 unique device=**671** / unique intent=**1538**（与权威全集一致，C1 SSOT 未被动）。
4. **脱敏红线**：active 文件命中的 `1004/1904/2086` 经核 = `contracts/semantic-followup-transitions.jsonl` 的 `source_row_no`（合法行号，非口径），属 C1 派生物不动；无密钥/PII/报价泄漏。
5. **全仓 534 grep**（CLAUDE/docs/contracts/openspec，排除 research/teardown 历史档与 row_no/534760）：活基线 docs（roadmap/README/CONTEXT/integration-blueprint/lessons-learned/SRD/MASTER/CLAUDE §9 banner）+ contracts（capabilities/state-cells/qwen-tool-call-format）+ 4 个 openspec change skeleton 全 **562 干净**（534 仅作「废口径/防当工具数」警示提及，已正确标注）。
6. **change skeleton 守 agree-before-build**：4 个新 change（migrate-d-domain-tool-surface / define-demo-golden-run-and-voice / rebuild-c6-four-layer-bench / retrain-c5-lora-d-domain）`.openspec.yaml status: DRAFT` + proposal 头 DRAFT SKELETON banner + tasks/specs 标 DRAFT 占位待人审 propose；未直接改 archived `openspec/specs/`（git clean）。✅
7. **残留 534 定位（grep + sed 上下文核）**：唯一残留集中在 `paradigm-tool-surface.md` §14 body（261/262）+ §15（302/307/357/359）。§14 header（224）已反转 562，但同节 grill 表 261/262 仍用 534 作 live 锚，无废标。

---

## Findings 表

| # | severity | issue | location | fix |
|---|---|---|---|---|
| F1 | **P1** | `paradigm-tool-surface.md` §14（口径终拍权威节）**节内自相矛盾**：§14 header（:224）已反转「562 为唯一权威、534 系列全废」，但**同一 §14 节的 grill 表 :261/:262 仍把 534 当 live 锚**——:261「534 已坐实可锚；…A1 产出按 scope_tier 从 534 拆后重算…demo 只认 10 族 534」；:262「`--scope=demo` 出重度目录（534 完整 value-form…）」。无废标/无 SUPERSEDED。paradigm 是任务明列的「口径 534→562 回写」in-scope 文件，§14 是 562 权威节本身，header 改了 body 未改 = 段间 drift（claim-vs-reality 第10变体）。 | `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:261` 和 `:262` | :261 改「**562** 已坐实可锚；A1 产出按 scope_tier 从 **562** 拆后重算…demo 只认 10 族 **562**」；:262 改「`--scope=demo` 出重度目录（**562** 完整 value-form…）」。或在两行尾加内联废标「（534 已废→562，§14 终拍）」。统一以 §14:224 终拍 562 为准。 |
| F2 | **P1** | `paradigm-tool-surface.md` §15 的 source-anchor / GOV3 行**错误转述 §14 已「坐实 534」**，与 §14 现行 562 终拍矛盾：:302「`562·418·缺486`…已被本文档 §14 坐实为 **534/191/2086** 取代」；:307 GOV3「本文档 §14 刚做的 cite-verify 坐实（旧 562/418/缺486 → **534/191/2086**）」。§14 早已反转为 562，这两行仍声称 §14=534 = **wrong cross-reference**（指向同文件错状态）。另 :357 AUD2「534=intent」、:359 AUD4「demo(534)/full(1538)」同属 534-as-value。注：§15 顶部（:297）有 SUPERSEDED-BY master banner，故 severity 降为 P1（非 P0）；但 banner 明示「§16/§17/§18 已拍内容仍权威」+ 302/307 misattribute §14，仍应纠。 | `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:302` `:307`（+ `:357` `:359`） | :302/:307 把「§14 坐实 534/191/2086」改为「§14 终拍 562/191/2159（534 已反转废）」；:357 改「562=intent」；:359 改「demo(562)/full(1538)」。与 §14:224 + master §0 口径表对齐。 |
| F3 | **P1** | `cascade-inventory.md` **§0（:8）与 §4.3（:248-254）自相矛盾**：§0:8 明示「废口径只在 master §0 表格物理存在一处；**本文不再内联列举**，引用前一律指回 master §0（消除手工同步义务 = drift-waiting 反模式）」；但 §4.3「口径污染源」表（:250-254）**仍内联逐条列举全部废口径值**（534/2086/52.3%/1004/1904/507/418/缺486/223/680）。这正是 §0 声称已消除的「本处随之同步」drift 源——§0 的 SSOT 单一化承诺未对 §4.3 兑现（claim-vs-reality 铁律1：声称层 vs 事实层）。 | `docs/grill-tournament/cascade-inventory.md:8`（声称）vs `:248-254`（事实） | 二选一：① 删 §4.3 废口径值内联列举，改为「污染→修正映射指回 master §0 口径表 + 本表只列『出现位置 / 修正动作』不复制废口径数值」；或 ② 改 §0:8 措辞为「废口径**权威定义**在 master §0；本文 §4.3 是**回写映射操作表**（污染位置→修正），非权威源」——明确 §4.3 是操作清单不是第二份权威表，消除「不再内联列举」的绝对断言。 |

---

## 维度内未发现问题（核过判 clean）

- **per-family 算术**：boundary 表 191/562/2159 三项求和全自洽（实算）。
- **redline**：C1 jsonl（3990/671/1538）+ C2 scenario-state-protocol spec + semantic-function-contract spec git 未动；脱敏无泄漏。
- **活基线 562 统一**：CLAUDE §9 banner / README / CONTEXT / roadmap / integration-blueprint / lessons-learned / SRD :78 / MASTER :8 / contracts（capabilities/state-cells/qwen-tool-call-format）全 562 干净，534 仅作废口径警示。
- **change skeleton 治理**：4 新 change 全 DRAFT + agree-before-build banner，未改 archived specs。✅ 符合「只起 skeleton 待人审 propose」。
- **boundary 文件**（mvp-10family-device-boundary.md）：全文 534 均已标作废，正文持 562 权威——与 cascade §2 verdict「无须再改正文」一致。✅
- **master §0 ↔ cascade §0 口径权威**：方向一致（562 权威 / 534 系列废）；master §0 cite 的 paradigm §13:211（候选全集 562）/ §14:230-231（418/缺486）经 sed 核对实际行内容相符。

---

## Summary

融合大长跑的 562 口径统一在【活基线文档组 + contracts + 4 个 DRAFT change skeleton】已落实干净，C1/C2 redline 文件 git 未动、jsonl 3990/671/1538 一手坐实、per-family 表算术自洽、脱敏无泄漏。**唯一残留集中在范式权威文件 `paradigm-tool-surface.md` 自身**：§14 header 反转 562 但同节 grill 表（:261/:262）与 §15 source-anchor/GOV3（:302/:307/:357/:359）仍用 534 作 live 值/错误转述「§14 坐实 534」= 节内/段间 drift（F1/F2，均 P1）。另 `cascade-inventory.md` §0 声称「不内联列举废口径」与 §4.3 实际内联列举废口径值自相矛盾（F3，P1）。**无 P0**：算术、redline、活基线统一、change 治理均通过。3 条 P1 均为「文件级别口径回写漏掉自身/段间一致性」类，与本长跑「§35 决策→文档组级联」主题同源——级联回写漏到了权威文件自己的 body 与映射表。

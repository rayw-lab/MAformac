# Pre-commit 全盘审计 — 审计员 A

**审计员**：A（commit 前全盘审计员）
**负责维度**：① 事实准确（口径数字全仓一致）② 范式架构一致（D-domain drift 残留）
**审计日期**：2026-06-23
**审计范围**：docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md、docs/grill-tournament/{grill-decisions-master,cascade-inventory,final-grill-list}.md、docs/research/2026-06-22-mvp-10family-device-boundary.md、CLAUDE.md、CONTEXT.md、docs/README.md、docs/srd-three-layer-intent-routing.md、docs/baseline-semantic-protocol-2026-06-19.md、docs/integration-blueprint.md

---

## Verdict

**has_p0p1 = true**（**P0 = 0 条 / P1 = 1 条**）

口径层（10 族 191/562/2159/54.1%、族外 480/976/1831、全集 3990/671/1538）全仓一致且与一手 jsonl 实核吻合，废口径 534/2086/52.3%/1004/1904 全部带显式标废 context（不算 bug）。范式层（generic frame 否决→D-domain 具名工具、canonical IR 仍 device×action）描述各文件一致。**唯一净 P1 = 「~30-60 工具数/挂载」段间矛盾**（已标 SUPERSEDED 的废口径在 paradigm 文档源处仍以肯定态裸出现，无 inline 标记）。

---

## 实核痕迹

### 一手数据复算（python / wc 实跑，非引用）
- `wc -l contracts/semantic-function-contract.jsonl` = **3990** ✓（与全仓「全集 3990 行」一致）
- python 解析 jsonl unique：**device=671 / intent=1538** ✓（与全仓「671 device / 1538 unique intent」一致）
- boundary §1 per-family 行求和（212+696+468+82+129+205+153+80+102+32）= **2159** ✓（权威值自洽）
- 废表 per-family 行求和（156+658+414+82+80+265+221+80+98+32）= **2086** ✓（确为 534-era，已正确标废）
- 族外派生：671−191=**480** device / 3990−2159=**1831** 行 / 1538−562=**976** intent ✓（全仓族外数字内部一致）
- 注：191 device / 562 intent 为 explicit-allowlist（A1-A9 前），**无法从 jsonl 派生**，靠 boundary §1 表 + 磊哥 2026-06-23 亲拍，cite 充分（boundary:3/:21/:39/:114）。

### grep 实核（每条读上下文判 裸残留 vs 标废 context）
- `grep -E "534|2086|52.3|1004|1904"` 全审计范围 → 命中约 50 处，**逐行读上下文 100% 带标废词**（作废/已废/禁引/反转/废口径/终拍 562/SUPERSEDED/narrative/溯源/delta），**0 裸残留当权威**。
- 排除标废词后再 grep 534 → 仅余 2 处（cascade:270 替换映射表、cascade:276 工具数禁引规则），均合法。
- `grep "tool_call_frame|B_frame|set_cabin"` → 全部在「❌旧/已否决/翻案/对比表/grep 定位旧锚」framing 内（srd:72 对比表标「❌旧已否决」、baseline:84/94「我之前做的/错」+「待磊哥拍」旧 P0 提案段、integration-blueprint:8「已否决」），**无 drift 残留**。
- `grep "2045"` → 全部框定为「量产 TOP 表真值非 demo」，**无误当 demo 真值**。
- paradigm §6:58/82「训练全集泛化」→ 已正确 `~~strikethrough~~ + 🔴[SUPERSEDED→§16:216]` inline 标记（srd:95 的「勿引 stale §6:58/82」告诫已被源处标记覆盖，非 P1）。

### 读了哪些（精读非抽样）
- paradigm-tool-surface.md：§14 口径终拍 banner(:222-235)、§6 demo 取巧表(:36-52)、§13 B1(:127-131)、§16 drift→SUPERSEDED(:382-387)、§16:214-218 A3 统一表述。
- grill-decisions-master.md §0 口径权威表(:24-32)、cascade-inventory.md §0(:5-8) + 污染源映射表(:262-276)、final-grill-list.md Q01(:7)。
- boundary md 文档头(:3) + §1 表(:39) + §2 族外(:47) + §4 G2(:114)。
- CONTEXT.md 口径权威表(:12-20)、CLAUDE.md:113 banner、docs/README.md:7、srd:72/76/95/178-206、baseline:8/84-96、integration-blueprint:8-10。

---

## Findings 表

| severity | issue | location | fix |
|---|---|---|---|
| **P1** | 「~30-60 工具数/挂载」段间矛盾：该值已被 paradigm §16:385 明文「§129 B1 ~30-60 已被 §14 G2『不拍实算』推翻 → SUPERSEDED」、master §0:31「30-60（已 SUPERSEDED）」、CONTEXT.md:18 列「30-60 当工具数」为废口径。但 paradigm 文档**源处 5 行仍以肯定态裸出现 ~30-60，无 inline strikethrough/SUPERSEDED 标记**。与同文档「训练全集泛化」反转（§6:58/82 已正确 inline 标 `~~~~+[SUPERSEDED]`）处置不对称。级联执行者/读者落到 §6:39 或 §13:129 会把 ~30-60 当 demo 工具数，与「工具数未拍待 value-form 实算」权威矛盾（claim-vs-reality 第10变体 / §35 SUPERSEDED 缺失→段间分叉，正是 GOV3:312 自警的坑）。 | docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md **:39**（§6 表「端侧只挂 ~30-60 个」）、**:52**、**:57**、**:100**、**:129**（§13 B1「10 族 value-form 工具 ~30-60」） | 对 5 处源行加 inline `~~strikethrough~~ + 🔴[SUPERSEDED → §14 G2:212 / §16:385：工具数不拍 ~30-60，待 value-form 实算]`，对齐同文档 §6:58/82 训练全集已采用的标记范式；或在 §6 表头/§13.B 段首加边注指向 §14 G2。**注**：若磊哥认为「端侧运行态挂载数 ~30-60」是与「工具数实算」独立的 runtime 估值维度（非废口径），则改为在源处加一句「此为 runtime 挂载估值，非 G2 工具数实算结果」澄清二者关系——但当前 CONTEXT.md:18 + master §0:31 + §16:385 三处都把它定性为废/SUPERSEDED，按现行权威应标 SUPERSEDED。 |

---

## Summary

口径层与范式层主体**干净**：① 10 族 191/562/2159/54.1%、族外 480/976/1831、全集 3990/671/1538 全仓一致，且 3990/671/1538/2159/2086 经一手 jsonl + 求和实核吻合；② 废口径 534/2086/52.3%/1004/1904 共约 50 处命中**全部**带显式标废 context（终拍 banner / 反转 / 禁引 / narrative 溯源），无裸残留当权威；③ 范式 drift（tool_call_frame/B_frame/set_cabin/2045）全部在「已否决/旧/对比/量产真值非 demo」framing 内，无残留。

**唯一净 P1** = 「~30-60 工具数/挂载」在 paradigm 文档 5 处源行以肯定态裸出现，但该值已被同文档 §16:385 + master §0 + CONTEXT.md 三处定性为 SUPERSEDED/废口径——源处缺 inline 标记，与同文档「训练全集泛化」反转的对称处置不一致，构成段间矛盾，commit 前建议补 SUPERSEDED 标记或澄清「runtime 挂载估值 vs G2 工具数实算」的关系。

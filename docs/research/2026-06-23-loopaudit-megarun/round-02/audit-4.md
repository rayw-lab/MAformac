# Loopaudit Megarun — Round 02 / 审计员 #4

> **round**: round-02
> **审计员**: #4（第2轮）
> **负责维度**: 内部一致（段间矛盾 / U10 四态 / 总数对账）+ 历史档 vs 活档（非口径 534 误改？历史档 banner 不动正文？）
> **方式**: 本机 Read + grep + python 复算实核（非凭印象）
> **verdict**: **has_p0p1 = true**（1 × P1 + 1 × P2；无 P0）。被审产出整体内部一致性高、历史档处理规范，仅 1 处级联追踪 row 与现实脱节（drift）。

---

## 实核痕迹（reproducible）

| # | 核什么 | 命令/方法 | 结果 |
|---|---|---|---|
| 1 | 全集 headline 口径 | `wc -l` + python json count `contracts/semantic-function-contract.jsonl` | 3990 行 / 671 device / 1538 intent ✅ 与全仓口径表一致 |
| 2 | boundary §1 per-family 表自洽 | python sum 10 族 (device/intent/rows) | 191 / 562 / 2159 / 54.1% ✅ 各族加和精确对账总数 |
| 3 | 562 终拍权威来源 | `sed` paradigm §14:222-235 + §13:158 | 磊哥 2026-06-23 亲拍 562、534/2086/52.3%/1004/1904 全废 ✅ inventory/master/boundary 三方 source 锚点真实存在且一致 |
| 4 | 活基线 534 残留扫描 | grep `534\|2086\|52.3\|1004\|1904` on CLAUDE/SRD/MASTER/state-cells/master/inventory/boundary/paradigm | 活档全部已 562-权威态，534 仅作「已废」自描述出现 ✅ |
| 5 | master §2 状态统计对账 | python set: done5+a2_4+yellow16+red16 | 5+4+16+16=41，unique=41，无 Q 缺失，待 grill=32 ✅ 与 §0「32 题」精确一致 |
| 6 | inventory §2 逐 Tier verdict 行数 | python 正则统计各 Tier path 行 | T0=8 / T1=25(9 modify·11 no_change·3 mark_hist·2 new_file) / T1skeleton=4 / T2=5 / T3=31 / T4=3 ✅ 与 §1.2 自检表一致 |
| 7 | 4 OpenSpec change skeleton 存在性 | `openspec list` + `openspec validate` ×4 | 全部存在、validate valid、0/N tasks、DRAFT 标记 ✅；skeleton spec 用 D-domain（tool_call_frame 仅作 SHALL NOT removed 引用）✅ |
| 8 | U10 四态一致性 | grep clarify/unsupported/safety/crash on master §2/§3/§5 | master 内部一致（§2 Q35 用 "safety"、§3 用 "safety_refusal" = 同概念，非矛盾）✅ |
| 9 | 历史档未误改 | grep 534/562 on a2-codebase-audit/README + boundary 溯源数 422/397/126/439 + ⭐ | A2 README 保留历史 534 口径（正文不动）；boundary naive 溯源数保留；⭐建议 11 处历史态保留 ✅ |
| 10 | CLAUDE.md 实际口径 vs inventory 描述 | `sed -n 113p` + mtime 对比 | 🔴 **CLAUDE.md:113 已 562（旧 534 废）**，但 inventory:48/50/62 仍标「CLAUDE 现写 534须改 562」= drift（见 finding F1）|

---

## Findings

| # | severity | issue | location | fix |
|---|---|---|---|---|
| **F1** | **P1** | `cascade-inventory.md` 三处级联追踪 row（§1.4 item1 / §2-T0 row / §2 T2 row118-邻）仍声称「CLAUDE.md §9 banner 现写 534 = 旧废口径，须随本长跑改 562」，把 CLAUDE 列为【待回写 pending】。**实查 CLAUDE.md:113 早已 562 权威态**（"intent 562(磊哥 2026-06-23 终拍,旧 534/2086/52.3% 系列全废)"）。mtime 坐实：CLAUDE 11:59 改完→562，inventory 12:40 后改却未同步该 verdict。inventory 是 cascade SSOT，stale「待改」row 会让下游执行者做冗余/已完成的回写，或误判 CLAUDE 仍污染。= 级联账本自身 drift（§35 / claim-vs-reality 第10变体 = 账本段与现实脱节）| `docs/grill-tournament/cascade-inventory.md:48`（§1.4 item1「CLAUDE.md §9 banner 现写 534…须改 562」）+ `:62`（§2-T0 row「191/534（须改 562）…:113 现写 534」）+ `:50`（§1.4 item3 措辞「非 534」可保留，但应注 CLAUDE 已完成）| 把这三处 CLAUDE row 的动作从「须改 534→562（pending）」改为「✅ 已 562（CLAUDE:113，2026-06-23 已回写，本行仅核对工具数占位/grill 批次锚点）」；§2-T0 row62 verdict 仍 `modify(微)` 但 what_to_change 删「须改 534→562」、保留「仅核工具数占位」。消除把已完成项当待办的 drift |
| **F2** | **P2** | `cascade-inventory.md:31`（§1.2 T4 行）vs 实际 §2 T4 表（3 行：2 modify + 1 new_file）— 经核对【一致】，非问题。但 §1.2 T1 行注「new_file 按 §2 verdict 行计=2，其中 demo-golden-run.v1.yaml + openspec/specs/demo-golden-run 同 1 行捆绑 2 path」与 §2 T1 表 row99 把两者写在**同一 verdict 行**——口径 A（87 verdict 行）下该捆绑算 1 行、口径 B（153 path）下算 2 path。该处自洽，但 §1.2 T1「new_file 2」与阶段 1 标题「2 new_file」、§3 阶段 4「new_file：demo-golden-run.v1.yaml + openspec/specs/demo-golden-run + openspec/specs/voice-pipeline」（阶段 1 列 3 个 new_file 概念但 §1.2 T1 计 2 verdict 行因 golden 捆绑）——【path 概念 3 个 vs verdict 行 2 个】的 A/B 口径在阶段段未显式标注，读者易困惑。非事实错（捆绑约定已在 row28 注明），但建议阶段 1 标题补「2 new_file verdict 行 = 3 new_file path（golden yaml+spec 捆绑 1 行）」一句消除阅读歧义 | `docs/grill-tournament/cascade-inventory.md:209`（阶段 1 标题「2 new_file」）+ `:213`（阶段 1 步4「new_file：demo-golden-run.v1.yaml + openspec/specs/demo-golden-run + openspec/specs/voice-pipeline」列 3 个）| 阶段 1 标题/步4 补口径注：「new_file = 2 verdict 行（口径 A）= 3 path（口径 B，golden v1.yaml + golden spec 捆绑 1 verdict 行 + voice-pipeline spec），与 §1.2 T1 `new_file 2`（verdict 行）一致」 |

---

## 维度内未发现问题（核过为干净）

- **总数对账**：全集 3990/671/1538、10 族 191/562/2159/54.1%、族外 480/976/1831 — python 实跑全部精确自洽（boundary per-family 加和 = 总数；全集 - 10 族 = 族外）。
- **段间矛盾（master）**：§2 状态统计 41 题全覆盖、待 grill=32、AUD4/AUD6=Q04/Q07 待 grill 残留题在 §5 AUD 组正确保留（§0 已纠「41-6≠35，真口径 32」），无静默丢弃。
- **U10 四态**：clarify/unsupported/safety/crash 在 master §2/§3/§5 一致（§2 用 "safety"、§3 用 "safety_refusal" 为同概念缩写，非矛盾）；「四态」与「消费 DemoVisualState 7 态」非矛盾（4 个 demo 视觉态由底层 7 态 store 支撑，inventory/master 均如此表述）。
- **历史档 vs 活档**：A2-codebase-audit/README 正确**保留历史 534 口径**（A2 盘点时快照，inventory T2 no_change，正文不动）；boundary naive 溯源数（422/397/126/439）+ ⭐建议历史态保留；活档（CLAUDE/SRD/MASTER/state-cells/paradigm）全部 562-权威。**非口径 534（研究/teardown benchmark 历史值）未被误改**。⚠️ 注：A2 README:29「paradigm §14 权威=534」是 A2 盘点时对 paradigm 的记录，paradigm §14 现已反转 562——但 inventory T2 row118 已显式 caveat「README 记 534 = A2 盘点时口径，A2 派单以 562 为准」，按「历史档不动正文 + 活账本 caveat」规则处理正确，不构成 finding。
- **OpenSpec change skeleton**：4 个（migrate-d-domain-tool-surface / retrain-c5-lora-d-domain / rebuild-c6-four-layer-bench / define-demo-golden-run-and-voice）真实存在、validate valid、DRAFT 待 propose（守 agree-before-build，未进 apply）、skeleton specs 用 D-domain（generic frame 仅作 SHALL NOT removed 引用）—— 与 inventory T1 skeleton 子段 + master §4.4 记录一致，无文档先行违背。
- **§4.3 vs §0 废口径双列**：cascade §4.3 内联列 534/2086 已显式声明「= 回写操作映射表，非废口径权威源；权威定性单一副本 = master §0」，方向反转（562 为权威）已正确处理，非矛盾。

---

## Summary

被审产出（grill SSOT + 562 口径全仓统一 + U11-31 落档 + 活基线级联 + contracts + OpenSpec skeleton + 历史档 banner + 脏区）在**内部一致性维度整体质量高**：全集/10 族/族外口径 python 实跑全部精确自洽；master 41 题状态统计无缺漏、AUD 残留题正确保留；U10 四态一致；4 OpenSpec skeleton 真实存在 validate valid 且守 agree-before-build；历史档（A2 README 534 / boundary 溯源数）正确保留正文不动、活档全 562-权威、非口径 534 未误改。

**唯一 P1**：cascade-inventory（cascade SSOT）三处 CLAUDE.md 级联追踪 row 仍标「现写 534须改 562（pending）」，但 CLAUDE.md:113 早已回写 562（mtime 坐实 inventory 在 CLAUDE 改完后才编辑却未同步该 row）= 账本自身 drift，会误导下游做已完成的回写。**1 × P2**：阶段段 new_file 口径 A（verdict 行 2）vs 口径 B（path 3，golden 捆绑）未在阶段标题显式标注，易读者困惑（事实自洽，仅阅读歧义）。

修掉 F1（把 CLAUDE row 从 pending 改为「✅ 已 562」）即可关闭本维度 P1。

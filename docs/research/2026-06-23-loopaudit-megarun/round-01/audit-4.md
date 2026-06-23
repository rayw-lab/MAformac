# Loopaudit Megarun — Round 01 / 审计员 #4

> **维度**：内部一致（段间矛盾 / U10 四态 / 总数对账） + 历史档 vs 活档（非口径 534 误改？历史档 banner 不动正文？）
> **审计范围**：融合大长跑全部产出（grill SSOT + 562 口径全仓统一 + U11-31 落档 + 活基线级联 + contracts + OpenSpec change skeleton + 历史档 banner + 脏区）
> **方法**：本机 Read/grep/python 实核，不凭印象。
> **as-of**：2026-06-23

---

## Verdict

**has_p0p1 = true**（1× P1 + 1× P2；无 P0）。

整体质量高：口径数字（562/191/2159/54.1%/族外 480/976/1831）经 python 复算与一手源 `contracts/semantic-function-contract.jsonl`（实测 3990 行 / 671 device / 1538 intent）+ boundary per-family 表逐族求和**全部精确对齐**；§2 锦标赛 41 题状态统计 set-diff 复算无 dup/missing（41 唯一，32 未拍）；SRD/MASTER/state-cells 的 D-domain surface 翻案段落齐全且自洽；4 个新 OpenSpec change skeleton 全标 DRAFT + 守 agree-before-build + `openspec validate` 全 valid + 一致引 562（无 534 残留）；历史 research/teardown 档**未被 562 误注入正文**（grep 0 命中），历史档 banner 制式正确。

唯一实质问题集中在【级联账本自身的 drift】：cascade-inventory 作为「全仓文档级联总账」(§35 机械账本)，① 把本长跑自己产出的 4 个新 change skeleton 完全漏记；② 把已经改成 562 的 CLAUDE.md 仍描述成「现写 534、须改 562」。两者都是「派生表征落后于一手事实」的同根问题（claim-vs-reality 第 10 变体的账本层镜像）。

---

## 实核痕迹

| 检查项 | 命令/方法 | 结果 |
|---|---|---|
| 一手 jsonl 口径 | `wc -l` + python json 解析 | 3990 行 / 671 device / 1538 intent，**与全仓权威口径精确一致** |
| boundary per-family 求和 | python 逐族 intent/device/rows sum | intent=562 / device=191 / rows=2159 / 54.1% / 族外 1831·976·480 **全部精确** |
| §2 状态统计 | python set(done5+a2-4+yellow16+red16) | sum=41 unique=41 无 dup/missing，未拍=32 ✓ |
| CLAUDE.md 口径 | `grep 534\|562 CLAUDE.md` | 行 113 已是 **562**（534 系列标全废），banner 已更新 |
| 活档 534 残留 | grep 6 个 named 活档 | master(7)/cascade(14)/boundary(4)/SRD(1)/MASTER(1) 命中**全在「废口径禁引」上下文**，无裸活引；state-cells 0 命中 |
| 历史档误改 | grep `562 intent\|磊哥2026-06-23` in 2026-06-19/20 research | **0 命中**（非口径 534 历史档未被注入新口径，正确） |
| DemoVisualState 7 态 | grep `Core/State/DemoVehicleStateStore.swift` | 实测 7 case（normal/satisfied/changing/blocked_with_alternative/blocked_hard/unsafe/unknown），定义在 `:17`，**master 引用准确** |
| ContentView 诊断锚 | `sed App/ContentView.swift` | :51 `Text(errorText).foregroundStyle(.red)`（万能红字）/ :121 `.satisfied?green:gray`（7 态压二值），**master/§3 引用准确** |
| 新 change skeleton | `openspec list` + `validate` + head proposal | 4 个全标 DRAFT SKELETON + agree-before-build + validate valid + 引 562 |
| SRD 翻案段 | grep D-domain/surface/IR in SRD | §1.4 + §5.2 三层模型段齐全自洽 |
| U10 四态 | grep clarify/unsupported/safety/crash | 5 处一致（line 123 用 `safety_refusal` = 同义缩写，非分叉） |

---

## Findings

| # | severity | issue | location | fix |
|---|---|---|---|---|
| 1 | **P1** | cascade-inventory.md 自称「全仓文档级联总账 / §35 机械账本」，但**完全漏记本长跑自己产出的 4 个新 OpenSpec change skeleton**（`migrate-d-domain-tool-surface` / `retrain-c5-lora-d-domain` / `rebuild-c6-four-layer-bench` / `define-demo-golden-run-and-voice`，均 2026-06-23 创建、`openspec list` 可见）。inventory T1/§3 阶段1 只列了 `openspec/specs/voice-pipeline` + `openspec/specs/demo-golden-run` 两个 new_file **spec**，把本长跑的核心 OpenSpec 交付物（change 骨架）当成不存在。grep `migrate-d-domain\|rebuild-c6\|retrain-c5\|skeleton\|DRAFT` 在 cascade + master 均 **0 命中**。账本漏记自己的产出 = 后续以账本为 SSOT 的 session 不知道这些骨架存在，重复创建或漏 propose。 | `docs/grill-tournament/cascade-inventory.md`（§1.2 Tier 表 / §2 T1 段 / §3 阶段1，全程无新 change 行）；`docs/grill-tournament/grill-decisions-master.md`（§2/§4 无骨架索引） | cascade-inventory 加一个 Tier（或在 T1 下加「新 change skeleton」子段）列 4 个 change 目录：path / verdict=new_change_skeleton(DRAFT) / 决策权威源 / 依赖序 / 待 propose 状态；master §4.4 GOV 晶体补「Q03/Q13 已起 4 change skeleton(DRAFT)」索引行。两处均显式标「DRAFT 待人审 propose，守 agree-before-build」。 |
| 2 | **P2** | cascade-inventory §1.4 item 1（line 48）+ §2 T0 verdict（line 62）均把 CLAUDE.md 当前态描述为「数字口径 191/**534**」+ 「:113 现写 534 = 旧废口径 / 须改 534→562」。但 CLAUDE.md 行 113 **已在本长跑改成 562**（实查：「intent **562**(磊哥 2026-06-23 终拍,旧 534/2086/52.3% 系列全废)」）。账本描述落后于已完成的修改 = §33/§35「分析→执行写回」缺口的反向（文件改了，账本没回写 done 状态）。以 cascade 为 SSOT 的读者会误以为 CLAUDE.md 仍是 534、还需要改。 | `docs/grill-tournament/cascade-inventory.md:48` + `:62`（CLAUDE.md verdict 行） | 把 §1.4 item1 + §2 T0 CLAUDE.md verdict 改为「✅ 口径 534→562 已回写(行 113)；仅余核工具数占位 + grill 批次锚点」；priority 从 modify(微) 标为 **done(口径) / verify-only(残项)**，消除「须改 534→562」的过期指令。 |

---

## Summary

第 4 审计员（内部一致 + 历史档/活档维度）：**1 P1 + 1 P2，无 P0**。核心结论 = 大长跑的【数字口径 / 范式翻案级联 / 新 change 骨架质量 / 历史档保护】四块全部经一手核验通过（562 系列与 jsonl 3990/671/1538 精确对齐，41 题统计自洽，code file:line 锚点准确，历史档未被新口径污染）。唯一实质漏洞在【cascade-inventory 这本级联账本自身】落后于一手事实两处：(P1) 漏记本长跑产出的 4 个新 OpenSpec change skeleton；(P2) 把已改成 562 的 CLAUDE.md 仍描述成 534 待改。两者同根 = 账本（派生表征）没随产物（一手事实）同步回写，正是 claim-vs-reality 第 10 变体（SSOT 账本自我分叉）在本轮的复发，建议本轮修复。

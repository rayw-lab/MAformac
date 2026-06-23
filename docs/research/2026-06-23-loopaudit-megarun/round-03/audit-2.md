# Loopaudit Megarun — Round 03 / 审计员 #2

> **round**: 03
> **审计员**: #2
> **负责维度**: 事实准确（562/2159/54.1% 全仓一致无残留 534 口径）/ 归类优先级 / 边界红线（C1/C2/semantic-function-contract.jsonl 未误动 / 脱敏）
> **方法**: 本机 Read + grep + python 复算实核（非凭印象）
> **verdict**: **有 1 个 P1（§14 second_turn_refs 表 2086 口径残留）+ 2 个 P2**；P0 无。核心活基线（CLAUDE/SRD/MASTER/state-cells/contracts）562 口径干净，C1/C2/jsonl 未误动，脱敏合规。

---

## 实核痕迹

| 核验项 | 命令 / 方法 | 结果 |
|---|---|---|
| jsonl 行数 | `wc -l contracts/semantic-function-contract.jsonl` | **3990** ✅ 与全仓口径一致 |
| boundary §1 per-family 表自洽 | python sum(intent/device/rows) | intent=562 / device=191 / rows=2159 ✅ 三列内部自洽 |
| 全集分拆守恒 | python | 562+976=1538 / 191+480=671 / 2159+1831=3990 ✅ 全守恒 |
| CLAUDE.md:113 | `sed -n 113p` | `intent **562**(旧 534/2086/52.3% 系列全废)` ✅ 已落 562 |
| SRD:78 | Read | 562/2159/191/480/976/1831 全 ✅ |
| MASTER:8 | Read | 562/2159/191/480/976/1831 全 ✅ |
| state-cells.yaml | grep D-domain/range | D-domain 范式注释完整 + 18-32/1-10 范围准确 ✅ |
| 残留 534 系列（活基线核心）| `grep -E '534\|2086\|52.3\|1004\|1904'` CLAUDE/SRD/MASTER/state-cells | **CLEAN: 无未标废残留** ✅ |
| 残留 507/680/418/422/397 | grep 活基线 | 仅 boundary 文件 422/397 作 naive-regex 根因说明（合法）✅ |
| master §2 状态统计算术 | python set diff | 5(✅)+4(→A2)+16(🟡)+16(🔴)=41，全 Q 覆盖无 gap/dup ✅ |
| cascade §1.2 ↔ §2 行数 | awk 复算 | T0=8 / T1=25 / T3=31 三方与 §1.2 claim 一致 ✅ |
| cascade §1.1 口径 A/B | python | A=8+25+5+31+3+11+4=87 / B=...77...=153 ✅ 算术对 |
| openspec 4 skeleton validate | `openspec validate` | 全 4 个 `valid`；status=DRAFT；用 562+[TBD-工具数]；tool_call_frame 仅作「显式移除」目标 ✅ 守 agree-before-build |
| C1/C2/jsonl 未误动 | `git status --short` contracts/jsonl + specs | **空（无任何改动）** ✅ 边界红线守住 |
| 脱敏 | grep AH8/T19/E0Y/1024 + 某车厂 | 活契约/边界档无车型代号泄漏；boundary 用「某车厂」✅ |

---

## findings 表

| # | severity | issue | location | fix |
|---|---|---|---|---|
| F1 | **P1** | **§14 `second_turn_refs` 表用废口径 2086 的 per-family 分母** —— 表内分母 156/658/82/80/414/265/221/80/98/32 = **2086**（= 废口径 534-系列的行数总额，表头注明「A1-A9 拍板**后** definite device scope」= 534-era），与权威 boundary §1 的 per-family 行数 212/696/82/129/468/205/153/80/102/32 = **2159** 直接冲突（如空调 §14=156 vs boundary=212）。§14 是全仓被反复 cite 为「口径权威」的 source（cascade §0 / master §0 / SRD:78 / MASTER:8 全指向 §14:224），却在 :224「562 终拍」声明下方 14 行就用 2086-口径分母 = **权威源自身段内矛盾**（claim-vs-reality 第10变体）。且此表**直接驱动 demo 多轮炸场剧本族优先级选择**（:255「优先选 空调/车窗/雨刮/香氛」），分母错→占比错→选族依据失真。背景明示「全仓口径 534→562」且 §14 在 paradigm（活基线 decision 档，非 research 历史 benchmark）→ 应级联回写。 | `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:241-253`（second_turn_refs 表 + :253「合计 260/2086」） | 该表是经验测量（numerator 14/25/46... 与 denominator 均按 534-era device scope 算），**不能直接把 2086→2159 改总额**（会让 numerator/denominator 口径错位）。正确：(a) 用 GLM execute_code 按 562 explicit-allowlist scope **重算**整表 numerator+denominator+占比（最佳）；或 (b) 若重算阻塞，**就地加边注**：「⚠️ 本表 per-family 分母 = A1-A9 后 534-era device scope（合计 2086），非终拍 562/2159 口径；占比相对关系（族多轮价值排序）仍可用，绝对分母待按 562 重算」。**至少 (b) 必做**，否则未来 grill 会把 2086 当 562 时代一手分母引用。 |
| F2 | **P2** | **cascade §0 / master §0「废口径单一权威清单」与 cascade §4.3 操作映射表并存，仍构成两处物理列举废口径数值的表面张力** —— master §0「口径权威表」声称是【废口径单一物理副本】，cascade §0 删内联仅留指针；但 cascade §4.3「口径污染源表」(:262-268) 仍逐行列出 `534/2086/52.3%`、`族外 1004/1904`、`507/418/缺486`、`223/507/680` 等废口径数值。§4.3 自带 caveat 说「这是回写操作映射表非权威表」（:259），逻辑上自洽，但**两张表都物理写了同一批废口径数值** —— 若未来某轮把 §4.3 当权威引用（caveat 易被跳读），仍是 drift 风险点。非阻塞（已有 caveat 缓解），但「单一物理副本」的声称与「§4.3 仍列举」的事实有表面不一致。 | `docs/grill-tournament/cascade-inventory.md:8`（§0 声称单一副本）vs `:262-268`（§4.3 仍列举废值）+ `master §0:27-33` | 维持现状可接受（§4.3 caveat 已说明性质差异）。若要彻底消除：§4.3 表的「污染（旧废口径）」列改为只写**符号锚**（如「534-系列」「2086-系列」）+ 指回 master §0 取具体值，不在 §4.3 物理列举完整数值串，则「单一物理副本」声称名实相符。 |
| F3 | **P2** | **cascade §0 与 master §0 对「562 vs 534 谁是 A1-A9 前/后」的定性表述一致，但与 boundary §3 的「A1-A9 = 九歧义点」语义存在可被误读的张力** —— master §0:25 + cascade §0:6 均定义「562 = A1-A9 边界裁决**前** explicit-allowlist / 534 = A1-A9 **后** GLM execute_code 移出若干 intent」。但 boundary §3:67-108 把 A1-A9 描述为「九个歧义点的逐个裁决」，且 boundary §1 的 562 表本身就是「A1-A9 拍板**后**的 explicit allowlist」（boundary §3:69「A1-A9 已磊哥拍」+ §1 表是终态）。即 boundary 语境下 562 是 A1-A9 **裁决结果**，而 §0 语境下 562 是 A1-A9 **裁决前**。两种叙事都能自圆（562 来自 CC subagent allowlist，534 来自 GLM 另一口径，A1-A9 device 裁决两期 device=191 不变），但「A1-A9 前/后」措辞在不同文档指代不同步骤，**未来读者可能据此误判 562 是否含 A1-A9 裁决**。事实层无错（device 191 / 562 已坐实），是叙事一致性问题。 | `docs/grill-tournament/cascade-inventory.md:6` + `master §0:25` vs `docs/research/2026-06-22-mvp-10family-device-boundary.md:3,21,69` | 在 §0 口径表统一一句澄清：「A1-A9 device **边界**裁决两期 device 均 191；562/534 差异在 **intent 计数口径**（562=CC subagent explicit-allowlist 全集 / 534=GLM execute_code 移出边界 intent），与 A1-A9 device 裁决步骤正交」——避免把 intent 口径差异挂到「A1-A9 前/后」时序上造成误读。 |

---

## summary

第3轮审计（事实准确 / 归类优先级 / 边界红线维度），本机 Read+grep+python 实核：

**干净项（无 finding）**：核心活基线 CLAUDE.md:113 / SRD:78 / MASTER:8 / state-cells.yaml 全已落 562 口径，无未标废的 534-系列残留；全集分拆守恒（562+976=1538 / 191+480=671 / 2159+1831=3990）；boundary §1 per-family 表三列内部自洽（191/562/2159）；master §2 grill 状态统计算术完美（5+4+16+16=41 全覆盖）；cascade §1.2↔§2 行数三方一致（T0=8/T1=25/T3=31）；4 个 openspec change skeleton 全 validate-valid + 标 DRAFT + 用 562+[TBD-工具数] + tool_call_frame 仅作移除目标（守 agree-before-build）；**C1/C2/semantic-function-contract.jsonl git status 全空（边界红线守住，未误动）**；脱敏合规（活契约无车型代号泄漏 + 用「某车厂」）。

**1 个 P1（F1）**：paradigm §14 second_turn_refs 表用废口径 2086 的 per-family 分母（156/658/...=2086），与权威 boundary §1 的 2159 行数冲突，且此表是全仓 cite 的「口径权威 source」自身段内矛盾，并直接驱动 demo 多轮剧本族优先级。需重算或就地加边注（不能直接改总额，因 numerator/denominator 同为 534-era scope 经验测量）。

**2 个 P2（F2/F3）**：F2 = cascade §4.3 与 master §0 两处物理列举废口径数值的表面张力（已有 caveat 缓解，非阻塞）；F3 = 「A1-A9 前/后」措辞在 §0 与 boundary §3 指代不同步骤的叙事一致性问题（事实层无错）。

整体：磊哥 2026-06-23 终拍的 562 口径在**核心活基线 + 契约**已干净级联到位，边界红线（C1/C2/jsonl 未动 + 脱敏）守住。唯一实质事实问题是 §14 second_turn_refs 表这个被反复引用却自身残留 2086 口径的「权威源内部 drift」点。

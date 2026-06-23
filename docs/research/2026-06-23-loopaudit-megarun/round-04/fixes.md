# Loopaudit Megarun — Round 04 修复回执

> 修复官第 4 轮。2026-06-23。审计 6 条 finding（1×P1 doc-baseline-gap / 1×P1 banner-pointer / 1×P1 doc-baseline-gap / 1×P1 off-by-2 cite / 1×P1 fact-error / 1×P1 scope-violation）逐条修复，本机核实再改。

## 修复数：6 / 6

## files_touched（绝对路径）

1. `/Users/wanglei/workspace/MAformac/CONTEXT.md`
2. `/Users/wanglei/workspace/MAformac/docs/README.md`
3. `/Users/wanglei/workspace/MAformac/docs/integration-blueprint.md`
4. `/Users/wanglei/workspace/MAformac/docs/grill-tournament/grill-decisions-master.md`
5. `/Users/wanglei/workspace/MAformac/openspec/changes/retrain-c5-lora-d-domain/proposal.md`
6. `/Users/wanglei/workspace/MAformac/openspec/changes/retrain-c5-lora-d-domain/specs/lora-training/spec.md`
7. `/Users/wanglei/workspace/MAformac/docs/srd-three-layer-intent-routing.md`
8. `/Users/wanglei/workspace/MAformac/docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md`
9. `/Users/wanglei/workspace/MAformac/docs/grill-tournament/cascade-inventory.md`

---

## 逐条 finding → 怎么改

### Finding 1（P1）— CONTEXT.md 仓根 T0 活基线 P0-marked 却未执行

**本机核实**：CONTEXT.md（仓根）原 2026-06-20 版 159 行，只有【术语】段；grep 无 562/3990/1538/191 口径、无 Grill 索引、无范式翻案/D-domain surface、无 T0-T6 分层。inventory:70 标 modify P0 但未跑（同级 T0 活基线 CLAUDE/README/SRD/MASTER 均已落）。

**改法**：执行 inventory:70 三改点，在【术语】段前补 4 章：
- ① 「口径权威」章：全集 3990 行/671 device/1538 unique intent + 10 族 191 device/562 intent/2159 行/54.1% + 族外 480/976/1831 + 工具数未拍 + 废口径禁引表（534/2086/52.3%/1004/1904 等）+ 三层 scope（L1 ⊂ 10族=训练层 ⊂ 全集派生源）。
- ② 「Grill 权威索引」章：路由表（grill-decisions-master / paradigm / cascade / boundary / c5-recovery / a2-audit）。
- ③ 「范式翻案」章：三层模型（canonical IR device×action×value / surface D-domain 具名工具 / runtime MVP 10 族），generic frame 否决。
- ④ 「T0-T6 文件分层」章：逐 Tier 起手关系 + 「grill 期只改 T1 contracts + T2 grill-decisions」。
- 文件头加状态 banner 说明本轮补三章、术语段保持。
- §33/§35 原子写回：同步在 cascade:70 把 verdict 标 **modify ✅DONE（finding round-04 执行）** + 列已落章节，消除「P0 marked 但静默空缺」态。

### Finding 2（P1）— README:76 SUPERSEDED banner 指针与 Q22 矛盾

**本机核实**：README:76 banner 写「现行推进事实源 = roadmap-2026-06-20-from-c6-done.md」，与 Q22（已拍：roadmap-2026-06-20 标 historical，新 SoT = grill-decisions-master）矛盾；CLAUDE §9 已正确改但 README:76 反向。

**改法**：banner 现行指针改 `docs/grill-tournament/grill-decisions-master.md`（grill SSOT，Q22 终拍单源）+ `grill-decisions-amend-paradigm-tool-surface.md`（范式权威）；roadmap-2026-06-20 标「已 historical(Q22)，仅供五件套 harness 骨架溯源，勿当现行推进事实源」。与 CLAUDE §9 / Q22 一致。

### Finding 3（P1）— integration-blueprint.md T0 活基线未执行

**本机核实**：integration-blueprint.md 生成 2026-06-17（范式翻案前）；grep D-domain/surface/10 族/562 全空（仅 line 217 有 capabilities.yaml v2 supersede 局部标记，无头部范式 banner）。inventory:71 三改点未落。

**改法**：补 inventory:71 三改点（文件头加范式演进 banner）：
- ① surface 层演进（generic frame `tool_call_frame` → D-domain 具名工具，θ-α 0/23 根因，canonical IR 仍 device×action）。
- ② 训练/eval/runtime surface 三处同源 enforce（TRN2 议题 / Q05 = C5 0/34 灾难根因）。
- ③ 10 族演示 scope 三层边界（runtime 10 族 191/562/2159 + 10 族内 LoRA 泛化 + 族外 480/976/1831 unsupported；LoRA 训练 562 不训全集）。
- §35 原子写回：cascade:71 verdict 标 **modify ✅DONE（finding round-04 执行）**。

### Finding 4（P1）— load-bearing file:line off-by-2（claim-vs-reality 第10变体）

**本机核实**：paradigm §14 实测行——:230=全集(3990/671/1538) / :231=族外(480/976/1831) / :232=compact positive 418 / :233=缺486。即 418 真锚=:232（误 cite :230 指到全集行），缺486 真锚=:233（误 cite :231 指到族外行）。boundary:47 cite §14:231 for 族外 = 正确（:231 只在为缺486时错）。

**改法**（3 处文件、4 处引用，全改为正确子行号；值本身 418/缺486 与权威 562 均正确，仅行锚错）：
- `grill-decisions-master.md:30`：418→`§14:230` 改 `§14:232`；缺486→`§14:231` 改 `§14:233`。
- `retrain-c5-lora-d-domain/proposal.md:23`：418→`§14:230` 改 `§14:232`。
- `retrain-c5-lora-d-domain/specs/lora-training/spec.md:8`：418→`§14:230` 两处改 `§14:232`。

**核验**：grep 确认 master / change 文件已无残留 `§14:230`（for 418）；sed -n 232/233 坐实新锚指向正确行。

### Finding 5（P1）— cascade c6-bench-cases.jsonl verdict 事实性错（误述磁盘格式）

**本机核实**（python 解析 + grep）：contracts/c6-bench-cases.jsonl 共 57 行——**34 行有 expected_tool_calls，23 行空**（negative/no-call，expect_no_call=true）；那 34 行用旧 B-frame 粗具名工具 `set_cabin_ac`(9)/`set_cabin_fan`(2)/`set_cabin_window`(11)/`set_cabin_ambient_light`(8)/`set_cabin_screen_brightness`(5)/`query_cabin_comfort`(1)，**grep tool_call_frame = 0 命中**（同 capabilities.yaml 自述「旧 B-frame 式」）。cascade:92「57 行仍旧 frame」+「tool_call_frame→」表述错。

**改法**：cascade:92 改为「57 行中 34 行用旧 B-frame 粗具名工具（set_cabin_* 等，0 用 generic tool_call_frame）+ 23 行空(negative)；A2 后 migration（set_cabin_* 粗具名 → adjust_ac_temperature_to_number 等 D-domain 细具名）」，删「57 行仍旧 frame」「tool_call_frame→」误述，与 capabilities.yaml「旧 B-frame 式」统一。migration 方向（粗具名→D-domain 细具名）正确保留。
- cascade:215（阶段1 step3）实测仅含「expected_tool_calls→D-domain，工具数门后」= migration 目标方向，无「57 行/tool_call_frame source」误述 → **正确，不改**（finding 标「+:215 同义」但该行未复发事实错）。

### Finding 6（P1）— SRD T0 活基线训练范围断言违 A3（核心训练范围决策违背）

**本机核实**：SRD:95「② LoRA 训练层 = 锚 3990 全集泛化…训练锚全集」+ SRD:206「③ LoRA 训练层 = 全集 3990 泛化」，与已拍 A3 直接矛盾——paradigm §13.A3:126『10 族子集(562)，族外 unsupported』+ §16:211『10 族不训全集』+ §16:216『覆盖前文一切训练全集泛化旧表达』+ master §0:30/§4.1:163『10 族 562 intent，不训全集』+ change proposal:23『10 族 562 intent scope』全一致拍「不训全集」。SRD copy 了 paradigm stale §6:58/:82『训练全集泛化』（这两行无 inline SUPERSEDED 标记、位于纠正它的 §16:216 之前，读者先撞 stale）。cascade SRD 行:66 只标「L2 泛化改 10 族内」= runtime 覆盖维度，未识别 SRD 的 training-scope 断言违 A3。

**改法**（三处 + inline supersede）：
- SRD:95：改「LoRA 训练层 = 10 族 562 intent scope（按 scope_tier 拆四类数据 compact positive/unsupported/safety/followup），不训全集 3990（A3 已拍 10 族不训全集，族外 unsupported 拒识）；全集 3990 是 canonical IR 派生源 + value-form 模糊说法变体来源，非训练 scope 本身」，cite §13.A3:126 / §16:216 / master §4.1:163，附「勿引 paradigm §6:58/:82 stale」提醒。
- SRD:206：把原「① L1 ⊂ ② 10族 ⊂ ③ 训练层=全集 3990」三层改为「① L1 ⊂ ② runtime 演示层 = LoRA 训练层 = 10 族 562 scope（不训全集 3990）」，全集 3990 标为派生源非训练 scope。
- paradigm §6:58：`训练全集泛化` 加删除线 + inline `[SUPERSEDED → §16:216 / §13.A3:126：10 族不训全集，训练=10族562 scope 按 scope_tier 拆四类数据]`。
- paradigm §6:82：`LoRA 训练锚 3990 全集…10 族 ≠ 训练范围` 加删除线 + inline SUPERSEDED 标记同上。
- cascade SRD 行:66：补 ④ 训练范围断言修正改点 + 显式注「③(runtime 族外 unsupported) 与 ④(训练范围 562 不训全集) 是两件事——runtime 覆盖 vs training scope，别合成同一条 surface narrative」。

**核验**：grep 确认 SRD 已无 live「训练锚全集 / 训练层 = 全集 3990」断言（仅新注释里的「原『训练锚全集』违 A3 已废」回顾出现）；paradigm §16:216 / §13.A3:126 cite 行实测内容正确。

---

## 验证

- `make verify-cross-section`：**consistent: true / caliber_violations: [] / drifts: []**（口径 anchor 10族 device/intent + 族外 intent 全一致，§14 行锚修复未引入 caliber drift）。
- 全 `make verify` 的 `diff` 目标 Error 1 = git diff --exit-code 检测到本轮未提交编辑（活编辑期预期态，非内容验证失败）。
- §14 行锚核验：sed -n 232/233 坐实 :232=418 / :233=缺486；grep 确认无残留 §14:230(for 418)。
- A3 cite 核验：sed -n 126 = A3 LoRA 范围 10 族子集 562 不训全集；sed -n 216 = 覆盖前文训练全集泛化旧表达。

## 元层备注

- cite-verify hook 对 `§13.A3:126`「file_missing」+「95/206 value_not_in_file」均为同文档/行范围 self-reference 的解析误报（已逐个 Read/sed 本机坐实，引用有效）。
- §35 级联：finding 1/3 执行后同步回写 cascade verdict 行（DONE 标记 + 已落清单），不留「verdict 写了执行漏一个无人追踪」态。

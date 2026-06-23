# Loopaudit Megarun — Round 01 修复报告

> **修复官**: round-01 · 2026-06-23
> **修复数**: 10 / 10 findings（全 P1）
> **验证**: `openspec validate --all --strict` = 13 passed / 0 failed（retrain change 编辑无破坏）；各 finding 本机 grep/sed 复核落地。
> **口径权威锚**（执行依据，本机核实）: 10 族 = 191 device / 562 intent / 2159 行 / 54.1% / 族外 480 device / 976 intent / 1831 行（磊哥 2026-06-23 亲拍 562，534/2086/52.3%/1004/1904 系列全废）。device 191 不变（A4 方向盘加热展示层并座椅·技术 device 独立，paradigm §13 A4）。

## files_touched（绝对路径）

1. `/Users/wanglei/workspace/MAformac/docs/grill-tournament/cascade-inventory.md`
2. `/Users/wanglei/workspace/MAformac/openspec/changes/retrain-c5-lora-d-domain/proposal.md`
3. `/Users/wanglei/workspace/MAformac/openspec/changes/retrain-c5-lora-d-domain/specs/lora-training/spec.md`
4. `/Users/wanglei/workspace/MAformac/docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md`
5. `/Users/wanglei/workspace/MAformac/docs/research/2026-06-22-mvp-10family-device-boundary.md`
6. `/Users/wanglei/workspace/MAformac/docs/grill-tournament/grill-decisions-master.md`

## 逐条 finding → 怎么改

### F1 (P1) — cascade 把 CONTEXT.md 写成 docs/CONTEXT.md（路径错 → SSOT 分叉风险）
- **本机核实**: `ls` 坐实 `CONTEXT.md` 在仓根（10.0k，2026-06-22），`docs/CONTEXT.md` 不存在；CLAUDE §3 引用的也是根 CONTEXT.md。cascade :68 path 错、:205 已是根路径（正确）。
- **改**: cascade-inventory `:68` path `docs/CONTEXT.md` → `CONTEXT.md`（**仓根**，非 docs/），并补红字「路径修正 + 文件在仓根 + 误建会 SSOT 分叉」+ 标注「当前 CONTEXT.md 仍是 2026-06-20 版（Grill 权威索引章/562 三层 scope/T0-T6 分层均未补）」= 显式标 deferred 写回 verdict（§33）。
- **注**: CONTEXT.md 正文本身的 T0 modify 是【后续执行任务】，本轮只把账本路径锚改对 + deferred 状态写清（守 agree-before-build / 文档先行：账本对齐是 round-01 范围，正文补写是 T0 阶段 2 执行）。

### F2 + F7 (P1×2，同源) — retrain change 引 compact positive 418（master §0 禁引废 / paradigm §14:230 待重算；cite 错挂 §13 G4）
- **本机核实**: master §0 `:30` 列 418 为废口径（codex compact positive 口径不同待重算）；paradigm §13:211(A3) + §14:230 标 418「待重算」；§13 G4 正文只含 562/2159 不含 418。
- **改 proposal.md `:23`**: `compact positive 418` → `compact positive [TBD-待 A1 scope_tier 拆后重算]`，cite 改挂 §13 A3 / §14:230（标 418 待重算 + master §0 禁引），DRAFT 占位足矣。
- **改 spec.md `:7`**: 同样改 `[TBD-待 A1 scope_tier 拆后重算]` + 加注「418 是 codex 口径待重算 / master §0 禁引 / cite 挂 §13 A3·§14:230 非 §13 G4（G4 正文只含 562/2159）」。
- **注**: finding 2 原列 proposal.md:57 亦引 418——实查 :57 是 Success Criteria「scope_tier 计数对齐 G4」不含 418，grep 坐实 proposal.md 只有 :23 一处 418，已修。

### F3 (P1) — T5 批量 banner 未完成（声称「脚本化一次过」与实测不符）
- **本机核实**: `ls` + head grep 实测 handoffs 0/25 有 banner、dispatches 0/13、`tech-baseline-from-raw.md` + `c5-recovery-2026-06-22/roadmap.md` 均无 HISTORICAL/SUPERSEDED banner（约 37/75 path 未跑）。
- **改**（采 finding 选项②：标 PENDING 纠正「一次过」声称，不现跑 banner 批=后续执行批次）: cascade `§1.3`、`§3 并行轨`、`§2 T5 段头` 三处把「脚本化，一次过」改为「脚本化批次 · 状态 = PENDING」+ 实测计数。T5 定为长跑后续批次，本轮不跑 banner（守文档先行 + agree-before-build：banner 批是执行动作，账本只纠状态声称）。

### F4 (P1) — paradigm §14（口径终拍权威节）节内自相矛盾（header 改 562、body :261/:262 仍 534 当 live 锚）
- **本机核实**: §14 header `:224` 已反转 562 唯一权威；但同节 grill 表 `:261`「534 已坐实可锚…demo 只认 534」、`:262`「--scope=demo 出重度目录（534 完整 value-form…）」无废标。
- **改**: `:261`「534 已坐实可锚」→「562 已坐实可锚（534 已废→562，§14 终拍）」+「demo 只认 10 族 534」→「562」；`:262`「534 完整 value-form」→「562 完整 value-form（534 已废→562，§14 终拍）」。统一以 §14:224 终拍 562 为准。

### F5 (P1) — paradigm §15 source-anchor(:302) + GOV3(:307) 错误转述「§14 已坐实 534」+ AUD2(:357)/AUD4(:359) 534-as-value
- **本机核实**: `:302`「…已被本文档 §14 坐实为 534/191/2086 取代」；`:307` GOV3「§14 刚做的 cite-verify 坐实（旧 562/418/缺486 → 534/191/2086）」——§14 早已反转 562，这两行 wrong cross-reference 指向同文件错状态。`:357` AUD2「534=intent」、`:359` AUD4「demo(534)/full(1538)」同属 534-as-value。
- **改**: `:302` → 「§14 终拍 562/191/2159（534 已反转废，旧『§14 坐实 534/191/2086』误述已纠 round-01）」；`:307` GOV3 → 「§14 cite-verify 坐实（旧 418/缺486 废 → §14 终拍 562/191/2159；534/2086 系列亦反转废）」+ 内联纠错注；`:357` AUD2「534=intent」→「562=intent（534 已反转废→562，§14 终拍）」；`:359` AUD4「demo(534)」→「demo(562)」。
- **额外（同 finding 5 spirit，stale-anchor drift）**: `:361` AUD6 grep 旧锚清单含「223/562」——562 是终拍**权威**非过期点，改为「223/534/2086」+ 注「562/2159 是权威非 grep 旧锚，旧版误列已纠」（与 master `:62` 用 534/2086 当 grep 旧锚对齐）。

### F6 (P1) — cascade §0(:8) 声称「不再内联列举废口径」vs §4.3(:248-254) 仍内联逐条列举（claim-vs-reality 铁律1）
- **本机核实**: §0 :8「本文不再内联列举，引用前指回 master §0」；§4.3 表 :250-254 仍列 534/2086/52.3%/1004/1904/507/418/缺486/223/680。
- **改**（采 finding 选项②，保留操作表实用性）: ① §0 :8 措辞改为「废口径【权威定义】单一清单 = master §0；§4.3 是【回写操作映射表】（污染位置→修正动作），非废口径权威源/非第二份权威表」；② §4.3 节头加边注「本表 = 回写操作映射表，废口径权威定性单一物理副本 = master §0，下表数值仅作操作锚」。消除「不再内联列举」绝对断言与操作表的表面矛盾。

### F8 (P1) — boundary 历史档段间矛盾（§3 header「待磊哥拍」+ Q-A4「⭐建议族外」vs paradigm §13 A4 终裁；§4「+1 device」vs 文档头「191 不变」）
- **本机核实**: boundary §3 :67 header「边界歧义点（待磊哥拍）」；Q-A4 :84-86 列 steering_wheel_heating「⭐族外…需磊哥拍」；§4 :114「steering_wheel_heating 若并入座椅 +1 device」。paradigm §13 A4 已终裁「展示层归座椅·技术 device 独立·191 不变」。
- **改**: ① §3 header「边界歧义点（待磊哥拍）」→「边界歧义点（A1-A9 已磊哥拍，下列为推导溯源历史态）」+ 边注「A1-A9 已拍见 paradigm §13，勿据此推进」；② Q-A4「⭐族外」改标「🔴已拍（paradigm §13 A4）：展示层归座椅·技术 device 独立·191 不变」+ 划除拍板前历史态；③ §4 :114「+1 device」句改「device 191 不变（A4 展示层并座椅·技术 device 独立不合并故不 +1）」+ 划除旧推导态。

### F9 (P1) — cascade boundary verdict(:108) 不完整（只处理「562 口径回写」，未把 §3/§4 拍板状态 staleness 纳入 what_to_change）
- **改**: cascade :108 boundary verdict 的 what_to_change 补一条「§3/§4 拍板状态级联：§3 header 旧标待拍 + Q-A4 ⭐族外 + §4 +1 device 均与 §13 A1-A9 终裁矛盾 → round-01 已在 boundary 正文加 A1-A9 已拍边注 + Q-A4 改标已拍 + §4 删/改 +1 device；下游勿据 §3『待拍』推进」。保留 modify(P0)。

### F10 (P1) — cascade + master 漏记本长跑产出的 4 个新 OpenSpec change skeleton
- **本机核实**: `openspec list` 见 migrate-d-domain-tool-surface(0/12)/retrain-c5-lora-d-domain(0/14)/rebuild-c6-four-layer-bench(0/14)/define-demo-golden-run-and-voice(0/15)，全 2026-06-23 创建、validate valid、proposal 头标 DRAFT SKELETON；grep 在 cascade + master 0 命中。
- **改 cascade**: T1 表后加子段「T1 — 新 OpenSpec change skeleton（本长跑产出）」列 4 change：path / verdict=new_change_skeleton(DRAFT) / 决策权威源(master Q03/Q13 + paradigm) / 依赖序([1]/[4]/[5]/横切) / 待 propose 状态，显式标「DRAFT 待人审 propose，守 agree-before-build」。
- **改 master**: §4.4 GOV 晶体补「Q03/Q13 已起 4 change skeleton(DRAFT)」索引行 + 指向 cascade T1 子段 + 全标 DRAFT 待 propose。

## 守则遵守
- **文档先行 + agree-before-build**: 4 change 保持 DRAFT skeleton，本轮只修账本一致性 + 纠错引用，未起完整 propose、未进 apply、未改实现代码。
- **不引新错**: 所有数字（562/191/2159/54.1% 等）以 paradigm §14:224 + master §0 终拍权威为锚，本机 grep/openspec validate 复核；418 改 TBD 占位（不编重算值）；T5 计数用本机 ls/find 实测。
- **openspec validate --all --strict = 13 passed / 0 failed**（编辑 retrain change 后无破坏）。

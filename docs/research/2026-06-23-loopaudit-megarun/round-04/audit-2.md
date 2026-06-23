# Loopaudit Megarun — Round 04 / 审计员 #2

> **round**: 04
> **审计员**: #2
> **负责维度**: 事实准确（562/2159/54.1% 全仓一致无残留 534 口径）/ 归类优先级 / 边界红线（C1/C2/semantic-function-contract.jsonl 未误动 / 脱敏）
> **方法**: 本机 Read + grep + python/awk 复算实核（非凭印象），并核对前三轮 finding 是否已修以免重报
> **verdict**: **has_p0p1 = true**（2×P1 新发现；P0 无）。核心口径/活基线 562 干净、红线未动、脱敏合规；2 个 P1 是**前三轮未 catch 的新问题**（其中 1 个是 round-01 修复时引入的 file:line off-by-2）。

---

## 实核痕迹（本机命令 + 结果）

| 核验项 | 命令/方法 | 结果 |
|---|---|---|
| 全集一手计数 | `wc -l` + python json set | **3990 行 / 671 device / 1538 intent** ✅ 与全仓权威口径精确一致 |
| boundary §1 per-family 求和 | python sum(device/intent/rows) | **191 / 562 / 2159（54.1%）** ✅ 表与权威自洽 |
| 全集守恒 | python | 562+976=1538 / 191+480=671 / 2159+1831=3990 ✅ 全守恒 |
| cascade §1.1 口径 A/B | python | A=8+25+5+31+3+11+4=**87** / B=...77...=**153** ✅ 算术对 |
| cascade §1.2 T0-T6 ↔ §2 | awk 逐 Tier 数行 | T0=8 / T1=25（modify9/no_change11/historical3/new_file2）/ T3=31 / T4=3 / T6=4 ✅ 三方一致 |
| master §2 状态统计 | python set diff | 5(✅)+4(→A2)+16(🟡)+16(🔴)=41，全 Q 覆盖无 gap/dup ✅ |
| CLAUDE.md §9 banner | `sed -n 113p` + Q22 段 | line113=562；Q22 迁移已落（roadmap 标 historical，新单源=grill-master+paradigm+cascade，起手读顺序已改）✅ |
| SRD surface 翻案 | grep `tool_call_frame/D-domain` | §1.4/§5.2/§3 banner 齐全，generic frame 明标「否决」，全 562 ✅ |
| MASTER 头 banner | `sed -n 1,12p` | IR canonical 保留 + D-domain surface 翻案注 + 562 口径表 ✅ |
| state-cells surface 边注 | Read 全文 :9-16 | IR/surface 正交、工具名不携带边界、execution_range 权威属 C2 ✅ |
| ASR amend 一致性 | grep CLAUDE/master | CLAUDE:69/81 已 amend「SFSpeechRecognizer 主→sherpa/Whisper fallback」对齐 master §4.6 ✅（无 sherpa 主残留） |
| 4 个 change skeleton | `openspec validate` + head proposal | 全 4 个 `valid`；`status DRAFT` + DRAFT SKELETON banner + 守 agree-before-build（未动 archived specs）+ 用 562/[TBD-工具数] ✅ |
| `make verify-cross-section` | 实跑 | `caliber_violations:[]` / `consistent:true` / `drifts:[]` ✅ BASELINE_GLOBS 含 grill-tournament/*，CALIBER_ANCHORS=562/191/976 |
| 红线 jsonl/C1/C2 | `git status --short` | semantic-function-contract.jsonl / specs/{semantic-function-contract,scenario-state-protocol} **空 diff = 未误动** ✅ |
| 脱敏红线 | grep AH8/T19/E0Y/某车厂 in 训练态 contracts | 0 命中（jsonl/state-cells/c6-bench-cases/boundary 无车型代号/PII/报价）✅ |
| 全仓 534 grep | CLAUDE/docs/contracts/openspec | 活基线全 562 干净；534 仅作「废口径/防当工具数」警示（已正确标注）；function-spec-full.yaml 的 `华`(摄氏度) 是 unicode 假阳性 ✅ |

**前三轮 finding 复核（避免重报）**：R01-F1（paradigm §14:261/262 stale 534）、R01-F2（§15:302/307）、R02（final-grill-list:7 裸锚 534）、R03（§14 second_turn 表 2086 / value.type 表 2086）**均已修**（261/262 现 562、§15 已纠、final-grill:7 现 562、两 §14 表均加 534-era 废口径边注被 cross_section 跳过）。本轮 2 个 P1 是**新发现**。

---

## Findings 表

| # | severity | issue | location | fix |
|---|---|---|---|---|
| F1 | **P1** | **load-bearing file:line 引用 off-by-2（claim-vs-reality「value-in-source」第10变体；round-01 修复时引入）**：多处活基线把「compact positive **418**」cite 到 `paradigm §14:230`，把「缺486」cite 到 `§14:231`——但实测 paradigm 行：**:230=全集(3990/671/1538)** / **:231=族外(480/976/1831)** / **:232=compact positive 418** / **:233=缺486**。即 418 真锚 = :232（cite 写 :230 = 指到全集行），缺486 真锚 = :233（cite 写 :231 = 指到族外行）。读者/A2 propose 人审跟 cite 会落错行。注：boundary:47 cite `§14:231` for 族外 = **正确**（231 确是族外），故 :231 这一锚只在「为缺486」时错。 | `docs/grill-tournament/grill-decisions-master.md:30`（418→§14:230 应 :232；缺486→§14:231 应 :233）；`openspec/changes/retrain-c5-lora-d-domain/proposal.md:23`（418→§14:230 应 :232）；`openspec/changes/retrain-c5-lora-d-domain/specs/lora-training/spec.md:8`（418→§14:230 两处应 :232） | 三处把 `§14:230`（为 418）改 `§14:232`；master §0:30 把缺486 的 `§14:231` 改 `§14:233`。或改为不带子行号的 `§14`（口径终拍节）避免再 off-by-N。值本身（418/缺486 = 废口径/待重算）与 562 权威均正确，仅行锚错。 |
| F2 | **P1** | **cascade-inventory c6-bench-cases.jsonl verdict 事实性错（误述磁盘格式，会误导 A2 migration 执行者）**：cascade §2 T1 行（:92）写「expected_tool_calls 映射 D-domain 具名工具名（**现 57 行仍旧 frame**）；A2 后重生成/migration（`tool_call_frame`→`adjust_ac_temperature_to_number` 等）」+ §3 阶段1（:215）同义。实测 `contracts/c6-bench-cases.jsonl`：① 共 57 行但 **34 行有 expected_tool_calls、23 行为空（negative/no-call）**，非「57 行仍旧 frame」；② 那 34 行用的是 `set_cabin_ac`/`set_cabin_fan`/`set_cabin_window`/`set_cabin_ambient_light`/`set_cabin_screen_brightness` 等**旧 B-frame 式粗粒度具名工具**（与 capabilities.yaml:4 自述「旧 B-frame 式手写示范」同款），`grep tool_call_frame`/`grep frame` = **0 命中**。即「仍旧 frame」「tool_call_frame→」的措辞把磁盘真实格式（B-frame 粗具名工具）误述成 generic frame（`tool_call_frame`），执行者按 cite grep `tool_call_frame` 会找 0 条而困惑。migration 意图（粗具名→D-domain 细具名）方向对，但 source 格式描述错。 | `docs/grill-tournament/cascade-inventory.md:92`（+ `:215`） | 改 :92 为「expected_tool_calls 现有 **34 行用旧 B-frame 粗具名工具（`set_cabin_ac` 等，0 用 generic `tool_call_frame`）+ 23 行空(negative)**；A2 后 migration（`set_cabin_*` 粗具名 → `adjust_ac_temperature_to_number` 等 D-domain 细具名）」；删/改「57 行仍旧 frame」「`tool_call_frame`→」表述，与 capabilities.yaml「旧 B-frame 式」措辞统一。 |
| F3 | **P2** | **同一 set_cabin_* 工具集在两文件被异名定性（术语不一致）**：`contracts/capabilities.yaml:4` 称 `set_cabin_ac` 等为「**旧 B-frame 式**手写示范」；`cascade-inventory.md:92` 对同一批工具（c6-bench-cases 的 expected）称「**旧 frame / `tool_call_frame`**」。两者指同一对象（粗粒度具名工具）却用「B-frame」vs「generic frame/tool_call_frame」两套定性——而 paradigm §1-§2/§17 明确区分：B-frame=device×action IR（canonical 保留），generic frame=`tool_call_frame`（surface 否决）。把粗具名工具叫「frame/tool_call_frame」= 与范式三层定义冲突。 | `docs/grill-tournament/cascade-inventory.md:92` | 统一用「旧 B-frame 粗具名工具 `set_cabin_*`」（对齐 capabilities.yaml + paradigm 定义），不叫「generic frame/tool_call_frame」（那是已否决的 surface，c6 磁盘并未用它）。随 F2 一并改。 |

---

## Summary

第 4 轮审计员 #2（事实准确 / 归类优先级 / 边界红线）。**核心结论：口径与红线层全部干净**——全集 3990/671/1538 一手坐实，10 族 191/562/2159（54.1%）+ 族外 480/976/1831 全仓守恒一致、`make verify-cross-section` 零 drift、C1/C2/jsonl 红线 git 空 diff 未误动、脱敏无车型代号/PII 泄漏、4 个 openspec change skeleton 均 `valid`+DRAFT+守 agree-before-build。前三轮的 534 残留 / §14 表 2086 / final-grill 裸锚等 finding 均已修，未重报。

**2 个新 P1（前三轮漏 catch）**：(F1) 多处活基线（master §0、retrain proposal+spec）把「compact positive 418」cite 到 `paradigm §14:230` 但 418 真锚是 :232（230=全集行），「缺486」cite :231 但真锚 :233——load-bearing file:line off-by-2，且是 round-01 修复时引入的（claim-vs-reality value-in-source 变体，正是本项目 :1038/:1039 同坑）。(F2) cascade-inventory 对 c6-bench-cases.jsonl 的 verdict 把磁盘真实格式（34 行 `set_cabin_*` 旧 B-frame 粗具名工具 + 23 行空，0 用 `tool_call_frame`）误述成「57 行仍旧 frame / `tool_call_frame`→」，会误导 A2 migration 执行者 grep `tool_call_frame` 找 0 条。+ 1 P2（F3）同一工具集「B-frame」vs「generic frame」异名定性，与 paradigm 三层定义冲突，随 F2 一并纠。

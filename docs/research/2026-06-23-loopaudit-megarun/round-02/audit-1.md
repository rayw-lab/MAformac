# Loopaudit Megarun — Round 02 · 审计员 #1

> **round**: 02 · **审计员**: #1 · **2026-06-23**
> **负责维度**: 完整性（各 Tier 文件按 inventory verdict 改 / U11-31 全落 / change skeleton 全起）+ 决策落实（562/U1-31/Q01-41/范式准确反映）+ SSOT 去重（口径/grill 单源不分叉）
> **方法**: 本机 Read/grep/awk/openspec 实核，禁凭印象。
> **被审**: cascade-inventory.md / grill-decisions-master.md / paradigm-tool-surface.md / mvp-10family-device-boundary.md / CLAUDE.md / srd-three-layer-intent-routing.md / baseline-semantic-protocol-2026-06-19.md(MASTER) / state-cells.yaml / openspec/changes/

## Verdict: **3 findings（全 P1，无 P0）**

口径/范式/SSOT 主干干净（562 系列已全仓统一落地、范式三层模型准确反映、master grill SSOT 内部一致）。三条 P1 均为「最新决策/状态未级联到位」类 drift（§35 范畴），非阻塞但会误导下游执行者。round-01 的 10 个 finding 已确认全部修复落地（不重复报）。

---

## 实核痕迹（载入决策锚后逐项坐实）

### A. 口径 562 系列（全仓唯一权威，磊哥 2026-06-23 终拍）— ✅ 一致
- `wc -l contracts/semantic-function-contract.jsonl` = **3990**（坐实全集行数）。
- boundary §1 per-family 表逐族 `awk` 求和：intent **68+126+27+48+113+75+32+27+30+16 = 562** ✓；device **25+36+11+21+29+33+11+8+10+7 = 191** ✓；行 **212+696+82+129+468+205+153+80+102+32 = 2159** ✓。内部自洽。
- 562 系列已落地的活基线（grep 实核，皆「562 权威 + 旧 534/2086/52.3% 系列全废」措辞）：
  - `CLAUDE.md:113`（`device 191/intent 562(磊哥 2026-06-23 终拍,旧 534/2086/52.3% 系列全废)`）
  - `docs/README.md:7,56,58`、`docs/srd-three-layer-intent-routing.md:78,206`、`docs/baseline-semantic-protocol-2026-06-19.md:8`（MASTER 头）
  - `contracts/state-cells.yaml`（surface 边注 + air_conditioner D-domain 映射注，已加）
  - `openspec/changes/migrate-d-domain-tool-surface/proposal.md:21`、`tasks.md:11-12`
- paradigm 残余 live-534 扫描（`grep 534 | 排除 废/反转/作废/旧/纠/supersede`）= **0 命中**；round-01 修的 `:261/:262/:302/:307/:357/:359/:361` 七处已坐实改为 562。

### B. 范式三层模型（canonical IR / D-domain surface / runtime 10 族）— ✅ 准确反映
- SRD 新增 §1.4「Surface framing」+ §5.2「范式三层模型」均存在且展开（line 70-78 / 178-206），「对模型像 D-domain 具名工具，对系统像 device×action IR」口诀一致。
- MASTER 头有「🟢 surface 翻案 banner」（IR 不变 / surface 翻案 / surface 规范不在本文档指回 paradigm §1-§2）。
- state-cells.yaml 头部 surface 正交边注 + air_conditioner D-domain 映射注齐全。
- CLAUDE.md §9 banner（:111/:113）generic frame→D-domain 映射 + 21 议题收口锚点齐全。

### C. master grill SSOT（41 题状态 + U1-U31 + §4 晶体）— ✅ 内部一致
- §2 逐行状态列 `awk` 提取 41 行：✅已拍 5（Q03/13/22/33/41）/ →A2合同 4（Q01/02/05/39）/ 🟡部分 16 / 🔴待grill 16 —— 与 §2 状态统计 claim **完全吻合**（Q20 awk 误显 superseded\ 是议题列 `keep\|modify\|superseded\|defer` 的转义管道扰乱字段切分，实查 :75 status=🔴待grill，无误）。
- §5 待 grill 表行 `grep`：32 个唯一 Q，与 §2「16🟡+16🔴」集合逐元素 diff **零差异**（无静默丢弃、无重复、无越界）。§5 self-check「32 题」属实。
- U11-U31 已落 master §3（grep U1[1-9]/U2x/U3[01] = 38 命中），U-续批纪律段齐全。
- §0 废口径单一权威表 = master §0（cascade §0 已删内联仅留指针）—— 双权威表风险已消（round-01 F6）。

### D. openspec change skeleton（本长跑核心交付）— ✅ 全起 + DRAFT + valid
- `openspec list`：4 个新 change 全在（migrate-d-domain-tool-surface 0/12 / retrain-c5-lora-d-domain 0/14 / rebuild-c6-four-layer-bench 0/14 / define-demo-golden-run-and-voice 0/15）。
- `openspec validate <each>` = 全 **valid**。
- 4 个 proposal.md 头全标 `⚠️ DRAFT SKELETON … 守 agree-before-build：人审定 propose 前不进 apply、不写实现代码`（守 agree-before-build）。
- cascade-inventory T1「新 OpenSpec change skeleton」子段 + master §4.4 GOV 晶体均补记 4 change（round-01 F10）。
- inventory 自计数复核：T0=8 / T1=25 verdict 行 / T2=5 / T3=31 / T4=3 / T6=4（`awk` 实测），口径 A=8+25+5+31+3+11+4=**87** 自洽。
- `make verify-cross-section` = `consistent:true, drifts:[]`（但其 baseline_files 仅覆盖 c5-recovery/ + roadmap，**未含** grill-tournament 新文件——见 finding 说明，非本轮新引）。

### E. 脏区 / new_file 延后项 — ✅ 合理 deferred（非 finding）
- `docs/research/2026-06-22-uiue-ultracode/`、`openspec/specs/voice-pipeline`、`openspec/specs/demo-golden-run`、`contracts/demo-golden-run.v1.yaml` 实查均 NOT FOUND —— 但这些是 inventory 阶段 5 / change apply 阶段的 new_file 任务，守 agree-before-build 合理延后，U11-U31 已落 master §3 故 UIUE 决策不丢。非 P0/P1。
- `_parked` 3 个保持 parked ✓。

---

## Findings

| # | severity | issue | location | fix |
|---|---|---|---|---|
| 1 | **P1** | **ASR 最新 amend（系统 SFSpeechRecognizer 主）未级联进活基线宪法** —— master §4.6「ASR：SFSpeechRecognizer 系统识别为主（demo 取巧）+ sherpa-onnx/WhisperKit fallback；C7/D14 据此 amend」+ `define-demo-golden-run-and-voice/proposal.md:14,22` + U28 均拍「系统 ASR 主」；但 **CLAUDE.md:69（宪法 §4 语音）+ docs/README.md:67,56 仍写「sherpa-onnx 中文(Paraformer/SenseVoice)主 + WhisperKit fallback」= 被 amend 的旧 D14**。两份最高权威活基线与最新拍板矛盾（§35 决策级联缺口）。CLAUDE/README grep `amend\|SFSpeech\|系统识别` = 0 命中（完全未反映）。 | `CLAUDE.md:69`（+`:81` D14 行）/ `docs/README.md:67`（+`:56` v2 重审行）vs `grill-decisions-master.md:203`(§4.6) + `openspec/changes/define-demo-golden-run-and-voice/proposal.md:14` | CLAUDE.md:69 + README:67/56 ASR 决策改为「系统 SFSpeechRecognizer 主（demo 取巧 on-device 离线）+ sherpa-onnx/WhisperKit fallback（不砍，要开发）+ ASRBackend 抽象」，注「D14 已 amend：sherpa 主→系统主，见 grill-decisions-master §4.6 + U28」。旧「Paraformer≫Whisper 中文抗噪」依据降为 fallback 选型理由保留。 |
| 2 | **P1** | **inventory（本长跑 SSOT 账本）对 CLAUDE.md 的【现状】描述失实（账本↔事实 drift）** —— cascade-inventory `:48`（§1.4 #1）「CLAUDE.md §9 banner 现写 534 = 旧废口径，须随本长跑改 562」+ `:62`（§2 T0 verdict）「191/534（须改 562）/:113 现写 534 = 旧废口径」。但**实查 CLAUDE.md:113 已是 562**（`device 191/intent 562(磊哥 2026-06-23 终拍,旧 534/2086/52.3% 系列全废)`）。账本把已修态描述为待修态——下游执行者据此会重复「修一个已修的文件」或误信 CLAUDE.md 仍 534。这正是 §35 机械账本自身 drift（账本自陈「每改一波必跑自检」却未回写 CLAUDE.md 现状）。 | `docs/grill-tournament/cascade-inventory.md:48` + `:62` vs 实际 `CLAUDE.md:113` | inventory :48/:62 把「现写 534 = 旧废口径，须改 562」改为「✅ 已是 562（round-01/本长跑已落，:113 现写 191/562 终拍态）」+ verdict 降为 no_change/verify-only；§1.4 #1 同步纠正现状陈述。 |
| 3 | **P1** | **grill 运行清单 SSOT（final-grill-list）+ ledger 仍裸锚 `534=intent`，与 master §0「534 全废」+ master §2 Q01「562」段间分叉** —— `final-grill-list.md:7`（Q01）「防止再次把 `534 intent` 写成工具数」（全文件 562 命中 = **0**）；`ledger.md:15`（Q01）「`534=intent`, not tool count」。这两份是 master 声明的【一手源】（master 头 line 5），但仍锚 534 为 intent 数，无「已废→562」标记；master §0 明令 534 全废、Q07/AUD6 要求全仓 grep `534` 旧锚级联回写。运行清单是 41 题 grill 的对外 SSOT，裸 534 会被未来 grill 按 lottery 引用（claim-vs-reality 第10变体）。 | `docs/grill-tournament/final-grill-list.md:7` + `docs/grill-tournament/ledger.md:15` vs `grill-decisions-master.md §0`(:30) + §2 Q01(:56) | final-grill-list:7 + ledger:15 的「534 intent / 534=intent」改「562 intent（终拍权威，旧 534 已废）」；保留「防把 intent 数写成工具数」告警语义（562 是 intent 非工具数）。与 inventory final-grill-list verdict（:126）的 what_to_change 补一条「Q01 口径 534→562 裸锚回写」。 |

---

## Summary

口径 562 全仓统一、范式三层模型准确落地、master grill SSOT（41 题状态/U1-31/§5 待 grill 集合/§0 单一废口径表）内部一致、4 个 change skeleton 全起且 DRAFT+valid+守 agree-before-build、inventory 自计数自洽、round-01 十个 finding 已确认修复——主干**无 P0**。

三条 **P1** 同属「最新决策/现状未级联到位」的 §35 drift：①最新 ASR amend（系统 SFSpeechRecognizer 主）未进 CLAUDE/README 宪法层，仍停在被 amend 的 sherpa-主旧态；②inventory 账本把已修成 562 的 CLAUDE.md 仍描述为「现写 534 须改」（账本↔事实 drift）；③grill 运行清单 final-grill-list + ledger 的 Q01 仍裸锚 `534=intent`，与其声明的下游 master（562）段间分叉。三条均非阻塞、均有明确单点 fix，建议本轮收掉后进 round-03 复审。

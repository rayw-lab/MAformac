# Loopaudit Megarun — Round 01 / 审计员 #1

> **范围**: 融合大长跑全部产出（grill SSOT + 562 口径全仓统一 + U11-31 落档 + 活基线级联 CLAUDE/SRD/MASTER/decisions + contracts + OpenSpec change skeleton + 历史档 banner + 脏区）。
> **负责维度**: 完整性（各 Tier 文件按 inventory verdict 改 / U11-31 全落 / change skeleton 全起） · 决策落实（562/U1-31/Q01-41/范式准确反映） · SSOT 去重（口径/grill 单源不分叉）。
> **方法**: 本机 Read/grep/python 实核，非凭印象。

---

## Verdict

**has_p0p1 = true**（无 P0；3 条 P1 + 3 条 P2）。

长跑主体质量高：范式翻案（generic frame→D-domain）+ 562 口径终拍在【活基线四件套】(CLAUDE §9 banner / SRD §1.4+§5.2 / MASTER 头 banner / state-cells.yaml 头 banner + per-device 注) 全部正确级联；grill-decisions-master §2 状态统计（41 题 / 5 已拍 / 4 →A2合同 / 16 部分 / 16 待grill）与表体逐行复算一致；cascade-inventory §1.2↔§2 各 Tier verdict 计数自洽；boundary 文件 per-family device/intent/行 求和（191/562/2159）与权威口径一致；4 个 OpenSpec change skeleton 全部正确标 DRAFT、引 cascade-inventory + paradigm 权威、口径 562、工具数 TBD、守 agree-before-build（spec delta 留 change 内不 materialize 进 openspec/specs）；T4 doc-modify（voice-pipeline ASR amend / demo-script golden-run / UIUE 落档）正确以 §33 原子写回方式 captured 进 change tasks，非静默丢弃。

发现集中在【级联账本自身的路径/口径瑕疵】+【T5 批量 banner 未完成】+【新建 change 引废口径 418】。无阻塞。

---

## 实核痕迹

- `wc -l contracts/semantic-function-contract.jsonl` = 3990（口径根锚一致）。
- boundary §1 per-family 求和：intent `68+126+27+48+113+75+32+27+30+16=562` ✓ / device `25+...+7=191` ✓ / 行 `212+...+32=2159` ✓。
- grill-decisions-master §2 awk 复算：41 rows / 已拍 5 / A2合同 4 / 部分 16 / 待grill 16 = 与 §2 状态统计完全一致 ✓。
- cascade-inventory §2 python 复算各 Tier verdict：T0=8 modify / T1=25(9+11+3+2) / T2=5(4+1) / T3=31(2+28+1) / T4=3(2+1) = 与 §1.2 完全对齐 ✓。
- 全仓 grep 废口径 534（排除 research/teardown 历史档 + 废/SUPERSEDED 上下文）：活文件中仅 `final-grill-list.md:7`（Q01 原题告诫例）+ round-0X 历史过程档残留；contracts/*.jsonl 与 function-spec-full.yaml 的 534 命中均为 `华`/`协` unicode 转义与行数据（误报）。
- 活基线 banner 实核：CLAUDE.md:113（562 终拍/旧 534 全废）✓ / SRD 头+§1.4(:64)+§5.2(:178) ✓ / MASTER 头 surface 翻案 banner ✓ / state-cells.yaml:9-15 surface 边界注 ✓。
- 4 change skeleton：`.openspec.yaml status=DRAFT` ✓ / proposal 头标 DRAFT + agree-before-build ✓ / specs/ 内 delta 存在（demo-golden-run/voice-pipeline 在 change 内，未 materialize 进 openspec/specs，符合 skeleton-only）✓。
- `make verify-cross-section`（直跑 scripts/cross_section_check.py）：consistent=true, drifts=[]，但 baseline_files 仅 12 个 c5-recovery/roadmap 档，**未含新 grill-tournament SSOT 与 SRD/MASTER/CONTEXT**（562 口径未机械守，= Q09/GOV3 待 grill，符合 deferred）。
- T5 banner 实核：早期 baseline 组 / second-review README / gitnexus README / c5-recovery 中间态 = BANNER-OK；**handoffs 0/25、dispatches 0/13、tech-baseline-from-raw.md、c5-recovery/roadmap.md = NO-BANNER**。
- 文件存在性：`CONTEXT.md` 在仓根（非 `docs/CONTEXT.md`）；`docs/research/2026-06-22-uiue-ultracode`、`contracts/demo-golden-run.v1.yaml`、`openspec/specs/{demo-golden-run,voice-pipeline}` 均 NOT FOUND（new_file，定于 change apply 后建，符合 skeleton-only）。
- lessons-learned 最高小节 = §50（§51 未加）。

---

## Findings

| # | severity | issue | location | fix |
|---|---|---|---|---|
| 1 | P1 | cascade-inventory 把 `CONTEXT.md` 写成 `docs/CONTEXT.md`，实际文件在仓根 `./CONTEXT.md`（CLAUDE §3 引用的也是根 CONTEXT.md）。级联账本路径错→执行 T0 阶段 2 时会找不到文件 / 误在 docs/ 建重复 CONTEXT.md = SSOT 分叉风险。CONTEXT.md 也确未做 T0 modify（Grill 权威索引章 / 562 三层 scope / T0-T6 分层均未补，仍是 2026-06-20 版）。 | `docs/grill-tournament/cascade-inventory.md:68`（path 错）；`CONTEXT.md`（实际未 modify） | inventory T0 行 path 改 `docs/CONTEXT.md`→`CONTEXT.md`（仓根）；T0 阶段 2 对 CONTEXT.md 补 Grill 权威索引 + 562/1538/191 三层口径 + T0-T6 分层（或显式标 deferred 并写回 change tasks，§33）。 |
| 2 | P1 | 新建 change `retrain-c5-lora-d-domain` 引 `compact positive 418` 作 live scope_tier 值，但 grill-decisions-master §0 口径权威表把 **418 列入「废口径（禁引）」**（`418（codex compact positive，口径不同待重算）`），cascade-inventory:252 亦标「507/418/缺486 标废」。新授权产物引禁引口径 = 决策违背 + 两权威源（master §0「禁引废」vs paradigm §13:211/§14:232「待重算」软态）对 418 的定性自我分叉。 | `openspec/changes/retrain-c5-lora-d-domain/proposal.md:23`+`:57`（引 418）；`docs/grill-tournament/grill-decisions-master.md:30`（418 禁引）vs paradigm`:211/:232`（418 待重算） | retrain proposal 把「compact positive 418」改为「compact positive [TBD-待 A1 scope_tier 拆后重算]」并注 §0 禁引；或在 master §0 与 paradigm 间统一 418 单一定性（禁引废 vs 待重算二选一），消除新产物可合法引废值的口子。 |
| 3 | P1 | T5 批量 banner 未完成：handoffs **0/25**、dispatches **0/13** 全无 HISTORICAL banner（inventory 阶段「并行轨 T5 批量 banner 75 文件」声明应 24 handoffs + 11 dispatches 进 banner 批）；另 `tech-baseline-from-raw.md`（T5 早期 baseline 组明列）+ `c5-recovery/roadmap.md`（T5 中间态明列）亦无 banner。约 37/75 path T5 banner 缺失。stated-scope（历史档 banner）完整性缺口。 | `docs/handoffs/*.md`(25 无 banner)；`docs/dispatches/*.md`(13 无 banner)；`docs/tech-baseline-from-raw.md`；`docs/c5-recovery-2026-06-22/roadmap.md`；inventory `:171-173,164,223` | 跑 T5 banner 脚本对 handoffs(除 paradigm-flip-d-domain)/dispatches(除 _TEMPLATE、p1-b-qwen-spike)/tech-baseline-from-raw/c5-recovery-roadmap 加 §3.6 banner；或若 T5 显式定为「后续批次」则在 inventory §1.3/§3 并行轨标「T5 batch PENDING（37 path 未跑）」纠正「一次过」声称（避免「已 banner」假完成）。 |
| 4 | P2 | lessons-learned T0 modify 未完成：§51「T2-T3 三源统一经验」未新增（最高仅 §50）；§49 verdict 要求补「D-domain 工具数[TBD] + surface→具名工具映射引用」，现 §49 仅留 tool_call_frame/D-domain surface mismatch 待 grill 假设，未补 [TBD] 工具数。§50/§49 已含 10/23 与 D-domain 核心内容，缺口属增量。 | `docs/lessons-learned.md`（§51 缺、§49 未补 [TBD]）；inventory `:67` | 补 §51（旧数字跨段分叉 534↔562 / SUPERSEDED 缺失 / 映射不清 = §35+制式经验）+ §49 补 D-domain 工具数 [TBD] 引用；或写回 change tasks 标 deferred（§33）。 |
| 5 | P2 | final-grill-list.md（T3 活运行清单）Q01 题面仍以「`534 intent` 写成工具数」为告诫例，未随 562 终拍更新告诫数字。虽是 Round01 原题措辞、非断言 534 为权威，但活清单内残留 534 与全仓 562 终拍口径不一致（562 才是当前「intent≠工具数」的正确告诫数）。 | `docs/grill-tournament/final-grill-list.md:7` | 告诫例数字 534→562（与全仓终拍一致），或加括注「（旧告诫例 534，现 562 终拍，均 intent 非工具数）」。round-0X 历史过程档（no_change）可不动。 |
| 6 | P2 | OpenSpec change `define-demo-golden-run-and-voice` proposal 引「UIUE 落档 `docs/research/2026-06-22-uiue-ultracode`」作决策权威源之一，但该文件不存在（inventory T4 标 new_file 定于 change apply 后建）。skeleton 阶段引一个尚不存在的「权威源」属悬空指针（U11-U31 实际落档 SSOT 在 grill-decisions-master §3，应优先指它）。 | `openspec/changes/define-demo-golden-run-and-voice/proposal.md`（决策权威源段）；tasks `:3.2` | proposal 决策权威源把 UIUE 指向 `grill-decisions-master §3`（U1-U31 现行 SSOT）为主、`docs/research/2026-06-22-uiue-ultracode` 标「(new_file, apply 时建)」为辅，避免引未建文件作权威。 |

---

## Summary

长跑核心成果【范式翻案 + 562 口径终拍 + grill SSOT 单一化】在活基线四件套（CLAUDE/SRD/MASTER/state-cells）级联准确、grill-decisions-master/cascade-inventory 内部计数自洽、4 个 change skeleton 规范（DRAFT + 引权威 + 562 + 工具数 TBD + agree-before-build + T4 doc-edit 以 §33 写回 tasks）。无 P0。

3 条 P1：① cascade-inventory 把 CONTEXT.md 路径写错（docs/ vs 根）且 CONTEXT.md 实际未 modify；② 新建 retrain change 引「418」作 live scope_tier，与 master §0 禁引废口径冲突（且 master vs paradigm 对 418 定性自我分叉）；③ T5 批量 banner 约 37/75 path（含全部 handoffs/dispatches）未跑，与「一次过」声称不符。3 条 P2：lessons §51 未加 / final-grill-list:7 告诫例残留 534 / demo-golden-run change 引未建的 uiue 落档作权威。建议修复后进 round-02。

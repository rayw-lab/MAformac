# 审计员 B 报告 — commit 前全盘审计

> **审计员**: B（开放式，本机只读 + Write 报告）
> **负责维度**: ① 完整性（U1-U31 落档 / change skeleton 全起 / 决策是否全反映）② 内部一致（段间矛盾 / 映射错）③ 决策落实（已拍决策被违背 / 准确反映）
> **as-of**: 2026-06-23
> **审计范围**: `docs/grill-tournament/{grill-decisions-master,cascade-inventory,final-grill-list}.md`、`openspec/changes/{migrate-d-domain-tool-surface,retrain-c5-lora-d-domain,rebuild-c6-four-layer-bench,define-demo-golden-run-and-voice}/`、`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md`

---

## Verdict

**has_p0p1 = true**（P0=0 / P1=2）

无 P0（无 U1-31 漏落 / 无 change 不合规 / 无已拍决策被违背）。2 条 P1 均为 cite-verify 层的 stale 行号/wording drift（claim-vs-reality §28 变体），非决策错误。

---

## 实核痕迹（本机 Read/grep/openspec 实跑，每条带 file:line）

### 验证点 ① — master §3 是否含 U1-U31 全 21 条挂 Q30-38 → ✅ PASS（注：U1-U31 = 31 条非 21）
- `grep -cE "^\| U[0-9]+ \|" grill-decisions-master.md` = **31**；U 编号实测 = U1..U31 连续无缺（master.md:113-148）。
- §3 出现的挂载 Q = Q30 Q31 Q32 Q33 Q34 Q35 Q36 Q37 Q38 全在（每条 U 行末「挂 Q」列）。
- U1-U10 落 §18 已拍区（master §3:113-123 上表）；U11-U31 落待续批区（master §3:127-148）+ §5 UIX 组。
- 结论：U1-U31 全 31 条落档、全挂 Q30-38，完整性 PASS。（审计背景文「全 21 条」为口误，实为 31 条 UIUE finding；不影响落档完整性。）

### 验证点 ② — 4 个 change skeleton 是否都有 proposal(DRAFT)+specs+tasks → ✅ PASS
- `find` 实测 4 change 全有 `proposal.md` + `specs/<cap>/spec.md` + `tasks.md` + `.openspec.yaml`。
- DRAFT banner：4 个 proposal.md 第 1 行全 `⚠️ DRAFT SKELETON`，第 3 行全 `守 agree-before-build：人审定 propose 前不进 apply、不写实现代码`（retrain 加「不跑训练」）。
- `openspec validate <change>` 4 个全 `is valid`；`openspec list` 显示 0/12·0/14·0/14·0/15 tasks（全未 apply，守住 agree-before-build）。
- spec delta 结构：每个 spec.md ≥1 `### Requirement:` + ≥1 `#### Scenario:`（migrate 2 spec 各 1+1 / retrain 2+2 / c6 2+2 / golden+voice 各 2+2），OpenSpec delta 格式合规。
- tasks 数与 `openspec list` 一致（12/14/14/15）。
- 结论：4 change 全合规（proposal DRAFT + specs delta + tasks），守 agree-before-build，PASS。

### 验证点 ③ — 41 题状态标注是否准确 → ✅ PASS（pipe-safe 复算）
- §2 表逐行状态（pipe-escape-safe python 复算，规避 Q01/Q20 行内 `\|` 转义）：✅已拍 5(Q03/13/22/33/41) / →A2合同 4(Q01/02/05/39) / 🟡部分 16 / 🔴待grill 16 = **41**。
- 与 §2 状态统计块（master.md:99-102）逐项核对：✅5、→A2 4、🟡16、🔴16 **完全一致**，Q 号清单逐一吻合。
- Q01/02/05/39→A2 合同 与 paradigm §18:480-484 一手源一致；Q03/13/22/33/41 ✅已拍 与 §18 GOV/U6 拍板一致。
- Q33 master ✅已拍(U6·§18) 与 final-grill Q33 P0 demo-blocker 一致。
- 结论：41 题状态标注准确、§2 表↔统计块无分叉，PASS。

### 决策落实抽核（背景决策清单 vs 文档）→ ✅ 准确反映
- **ASR 不砍**：master §4.6:203「SFSpeechRecognizer 主 + sherpa-onnx/WhisperKit fallback（不砍，要开发）+ ASRBackend 抽象保留」→ voice-pipeline spec.md:5,16「ASRBackend 抽象，系统主 + WhisperKit/sherpa fallback（不砍）」一致。
- **TTS 系统朗读**：master §4.6:204 + voice-pipeline:6,25「AVSpeechSynthesizer 系统朗读 + 中文 TTS preflight」一致（U28）。
- **U6 麦克风+memory entitlement**：voice-pipeline:25 + master §3 U6:119「NSMicrophoneUsageDescription + memory entitlement + Release launch receipt」一致。
- **U19 #available / U28 中文 TTS preflight**：voice-pipeline:25 显含 `#available` 保护 + 中文 preflight，一致。
- **口径 562（534 废）**：4 change 内无裸 534 残留——migrate proposal:60「无编造 534/562 当工具数」+ tasks:11「534→562 级联回写（仅口径 534）」均为合法治理引用，非裸残留；retrain/c6/golden proposal 0 个 534。562/2159/54.1% 在 proposal 内一致。
- **范式 D-domain 具名工具**：4 change proposal Why 段全锚 generic frame `tool_call_frame` 否决→D-domain，canonical IR 仍 device×action，与 paradigm §1-§2 一致。

---

## Findings 表

| # | 级别 | 维度 | file:line | 问题 | 实核证据 | 建议 |
|---|---|---|---|---|---|---|
| F1 | **P1** | 内部一致（段间 wording drift）| `grill-decisions-amend-paradigm-tool-surface.md:490` vs `grill-decisions-master.md:123`/`:144`/`:150`/`:200` | paradigm §18 U10 表头仍写「状态 UI **三态**」，但 master §3/§4.5/U27/U-续批纪律 全写「状态 UI **四态**」（clarify/unsupported/safety/crash）。paradigm 是 master §0 声明的 U1-U10 一手源，一手源标「三态」与收口 SSOT「四态」字面分叉。 | paradigm:490 行首列 `状态 UI 三态`；master:123 `状态 UI 四态`+`四态分开`、:200「U10（状态四态…）」。两处正文内容均列 4 个态（clarify/unsupported/safety_refusal/crash），故「四态」为正确语义，paradigm「三态」是 stale 表头。 | 把 paradigm §18:490 U10 表头「三态」改「四态」（或加 `[SUPERSEDED→四态, 见 master §3]` 边注）。**非决策违背**（内容一致列 4 态），仅表头 wording。 |
| F2 | **P1** | 内部一致（cite-verify 行号 stale）| `grill-decisions-master.md:15` | master §0 处置表称「§15 顶部（paradigm **:295**）已标 SUPERSEDED-BY」，但实测 paradigm §15 标题在 **:300**、SUPERSEDED banner 在 **:302**；行 :295 是 §14 正文内一空行。off-by-5~7 行号引用失效（claim-vs-reality §28：cite 行存在但所指内容不在该行）。 | `grep "^## §15" paradigm` = :300；`grep "SUPERSEDED-BY .../grill-decisions-master" paradigm` = :302；`sed -n 295p` = 空行（§14 LoRA 训练重点族段内）。banner 本体存在（:302 实有），仅 master 引用的「:295」过期。 | master §0:15「paradigm :295」改「paradigm :300（§15 标题）/ :302（SUPERSEDED banner）」。banner 物理存在、SUPERSEDED 处置真实落地，仅行号锚 stale。 |

---

## Summary

本轮（维度 ①完整性 ②内部一致 ③决策落实）**无 P0**：

- **完整性**：U1-U31 全 31 条落 master §3 并挂 Q30-38；4 change skeleton 全有 proposal(DRAFT)+specs delta(Requirement+Scenario)+tasks，openspec validate 全 valid、全 0 task（守 agree-before-build）；41 题状态标注准确（§2 表 ✅5/→A2 4/🟡16/🔴16=41 与统计块逐项吻合）。
- **决策落实**：背景已拍决策（锦标赛 41 adopt / Q01·02·05·39→A2 合同 / Q03·13·22·33·41 GOV / UIUE U1-U10 含 ASR 不砍 + TTS 系统朗读 + U6 麦克风+memory + U19 #available + U28 中文 TTS preflight + U10·U27 状态四态 + 范式 D-domain / 口径 562 534 废）在 master + 4 change + voice-pipeline spec 中**准确反映、无被违背**。
- **内部一致**：2 条 P1 均为「派生表征（paradigm 一手源）与收口 SSOT（master）之间」的 stale 残留——F1 是 U10「三态/四态」表头 wording drift（内容一致），F2 是 master §0 引用 paradigm §15 SUPERSEDED 的行号 off-by-5~7。两条都不改变决策语义，属 cite-verify 层机械纠正。

整体质量高：master §2↔统计块 pipe-safe 复算零分叉、change skeleton 全合规守 agree-before-build、562 口径无裸 534 残留、ASR/TTS/U6/U19/U28 决策端到端一致落到 voice-pipeline spec。建议 commit 前顺手修 F1/F2 两处 cite drift（一行编辑各一处），不构成 blocker。

> **审计边界**：cascade-inventory §1.1 的 87/153 path 计数为作者多轮（round-01~05）awk 自审复算的 load-bearing 数（doc 内自带 provenance + dedup 约定），本审计员未对其逐 Tier 全量复算到 path 级（混入 §4 dirty-region 表 + T1 skeleton 子表，松 grep 会误计）；该数在我三维度（完整性/一致/决策落实）核心之外，标低置信、未提为 P1。

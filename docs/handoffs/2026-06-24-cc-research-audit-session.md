# Handoff 2026-06-24 — CC 主窗口：18 路调研 + 审计 + answer-grill session

> 互补于 `2026-06-24-default-scope-commander-handoff.md`（那份交接 **default_scope apply 执行线** Task 0-10）。本份交接 **CC 主窗口的调研/审计/grill 线**——两线汇于 default_scope apply。

## 本 session（CC 主窗口）完成

1. **18 路 LoRA 零容错调研（通宵 ultracode）**：3 次 workflow（首 6 路 → 12 路 rate-limit → 4批×3 降并发补 12/12 → 全 18 综合官）+ 主线程亲核。完整一手档 `docs/research/2026-06-24-lora-zero-failure-deepdive/`（28 文件：18 lensNN.md + README + stop-the-train-matrix + comparison + decisions-and-grill-ammo + external-claims-verification + INDEX）；transcript 仓外 `~/workspace/raw/05-Projects/MAformac/research/lora-deepdive-transcripts/`（36 文件）；脚本仓外 `dispatches/2026-06-24-lora-deepdive-{workflow,synth}.mjs`。
2. **审计 codex default_scope G01-G28 级联 = CLEAR**：4 处实跑核全坐实（jq `zoneish_required=0` / readback 测试期望主驾 / capabilities.yaml `status:active+required` / scene3-4）。
3. **审计两基线计划文档 verdict**：`d1-d10-openspec-gates`(plan not SSOT) + `demo-default-scope`(decision pack) = **可作「计划/决策态基线」，非行为 SSOT**（真 SSOT = OpenSpec change + state-cells.yaml）。
4. **UIUE 待命判断**：不纯待命——Phase 1b 工程前置硬门(Info.plist/entitlements/snapshot)不依赖后端可先做；只 Phase 4 default_scope 卡片消费等后端 apply 落 main。
5. **D1-D10 answer-grill + define-demo-default-scope carrier answer-grill 3 物理化补强**：🟢 **已被 apply 计划吸收**（commander handoff Task 7=C5/C2 parity、Task 9=三道机械门 `check_default_scope_ssot.py`/`check_c5_c2_scope_parity.py`/`check_scope_origin_single_source.py`）。
6. **cite-verify 口径自纠**（claim-vs-reality 第8坑）：`uniq -c` 出现次数误标"路数"→ 改准（2602.04998=lens13/14、2603.03203=lens08 单路 5 次编造）。别窗口已采纳（commander:73）。

## 18 路调研核心结论（一句话）

0/34 不是玄学，是「配方对、外围工程缺失」→ 拆成 **8 道 P0 门**：L09 样本可观测 / L02 loss-mask / L03 byte-parity / L05 中途行为门 / L04 四层门 / L07 数据配方负类 / L17 人审破框 / L16 治理。守 rank16Mainline（2602.04998 系统证明调好 LR vanilla 不输新变体）。防编造 catch 了 1 个编造 arxiv（2603.03203）。

## 当前全局状态（实况，2026-06-24）

- **main HEAD `6f03b62`**：default_scope apply 已大幅推进（`8517f70` C2 字段 / `b5ed59d` C3 / `75a039d` StateApplier / `40d488e` readback elide / `6f03b62` UI），别窗口正执行 Task 3-10（dirty: `ScopeResolution.swift` + C3 resolver 测试）。
- **D1-D10 已被用户接受**（`1143b50`，pending=0）；**R-L17 仍 open**（同厂商审计只算 pre-check，不得关闭）。
- 18 路调研归档已 commit（`883f1c4`/`1143b50` 链）；本 handoff 是唯一未跟踪新增。

## 下次第一步（两线）

- **default_scope apply 线**：认 `default-scope-commander-handoff` + `docs/superpowers/plans/2026-06-24-default-scope-apply.md`，从 **Task 3** 继续（别 reset dirty 区），三道机械门进 Makefile。
- **调研/训练线**：default_scope apply 全绿后才动 retrain-c5/rebuild-c6，携 18 路 routing ledger（commander:80-99）当 acceptance/evidence gate，**不重开泛讨论**。

## 本 session 元认知 lessons（已回流 `docs/lessons-learned.md`）

- 🔴 **ultracode workflow rate-limit 降并发**（新坑）：18 路每批 6 并发 + 三批连跑 = 累积撞 server rate-limit（12/18 失败）；降 4批×3 守 cap 3-5 后 12/12 成功。**cap 3-5 不只防配额，连跑累积也撞**。
- **answer-grill 物理化兑现**：3 补强 → apply Task 7/9 直接吸收（concept→pre-commit 机械门）。
- **跨线状态以实况为准**（completion-claim-triage）：我凭旧认知说"D1-D10 14 pending"，实况已 0 pending + main 大幅前进 + 已有 handoff——写交接前先核实况。

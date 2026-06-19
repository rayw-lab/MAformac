# C1 契约路线 Q1–Q10:Claude 加深 / 对抗 / Oracle 验证

> **角色**:Claude(综合 + red-team)。磊哥本轮**授权对抗**(不止 answer-grill 顺势加深,可提挑战/反方意见)。
> **方法**:scout 本机现状(`file:line`)+ 2 路 oracle 联网(URL citation)+ pre-mortem 三分类。
> **对话方**:磊哥拍板 / codex 出推荐+反问 / 本文 = Claude 第三方加深与对抗。
> **日期**:2026-06-19。承接 `docs/adr/0001-generated-full-contract-with-mixed-delivery.md`(Q1–Q8 已成文)+ CONTEXT.md。

---

## 0. 一句话总判

10 问里 **7 题认同/加深,3 题对抗**。3 个对抗点(Q5 `dropped_rows=0` / Q10 活文件作权威 / 跨题"没机制不写 gate")**本质是同一个 HIGH 坑的三个化身 —— 假单一事实源(假 SSOT)**:声明了 SSOT,但生成物/输入/引用没有强制校验,执行期会静默漂走(正是 96272132 踩过的坑)。

---

## 1. Oracle 验证摘要(2 路联网,真实命中 URL,未臆造)

### Oracle A — xlsx 作 codegen 权威源
- **核心反转**:codegen 输入必须是**不可变快照(immutable snapshot)**,不是 live mutable 文件。reproducible build 第一原则:build 不能读 mutable live source。
- **可 adopt 范式**:`go generate` + `git diff --exit-code`(drift gate 黄金范式,protobuf/ORM/OpenAPI 全用)/ `check-uncommitted-git-changes`(PyPI 现成,Python 栈直装)/ TimeXtender「governed input → deterministic output」。
- **实锤坑**:① xlsx 二进制 → `git diff` 只报 `Binary files differ`(review 黑洞)② Excel/WPS 的 `dimension/max_row` 元数据不可靠(openpyxl `read_only` 信它会读空,**我们上个 session 实测踩过**)③ 合并单元格级联 `None`(座舱表用合并做域表头,高发)④ 手改无类型约束静默传播(范围 18-32 拍成 16-30 踩过)⑤ 多版本真相(Downloads 已有 `副本.xlsx`/`编辑版.xlsx`)⑥ `data_only` 缓存/浮点假 diff。
- citation:[reproducible builds 三支柱](https://fossa.com/blog/three-pillars-reproducible-builds/) / [go generate + CI diff](https://oneuptime.com/blog/post/2026-01-23-go-generate/view) / [check-uncommitted-git-changes](https://pypi.org/project/check-uncommitted-git-changes/) / [openpyxl optimised modes](https://openpyxl.readthedocs.io/en/3.1/optimized.html) / [DoltHub spreadsheet version control](https://www.dolthub.com/blog/2022-07-15-so-you-want-spreadsheet-version-control/)

### Oracle B — 源行级建模 + 去重 + JSONL 契约
- **核心背书**:源行/canonical 双建模 = **Kimball SCD Type 7**(durable key + surrogate key 双 FK)正统 + Record Linkage「link, don't merge」,不是我们发明的过度设计。
- **HIGH 坑**:`dropped_rows=0` 硬门 = coincidental correctness 制造机,逼脏行洗白成"看着合法"的契约。Kimball 正解 = **不丢不洗白,分流到 error-event + unknown-member**。
- **可 adopt**:Splink(MOJ 出品,2026-04 仍活跃,`link_and_dedupe` 保每行 provenance + 共享 cluster_id)/ MDM survivorship(`primary` 该按 source 质量+recency 选,非任选第一行)。
- citation:[Record linkage(Wikipedia)](https://en.wikipedia.org/wiki/Record_linkage) / [SCD Type 7 durable key](https://decisionworks.com/2013/02/design-tip-152-slowly-changing-dimension-types-0-4-5-6-7/) / [Splink](https://github.com/moj-analytical-services/splink) / [Kimball Error Event Schema](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/error-event-schema/) / [semantic gap in data quality](https://dev.to/vivekjami/the-semantic-gap-in-data-quality-why-your-monitoring-is-lying-to-you-af4) / [JSONL diff 失效](https://dev.to/lechlabs/why-your-diff-tool-is-failing-on-jsonl-files-19k0)

---

## 2. 逐题 Q1–Q10

### Q1 甲档全集 — ✅认同 + 🐘elephant
全集 3990 源行精确建模,认同(磊哥拍)。**但诚实标 elephant**:3990 全集契约的**主要消费方是 LoRA 语料 + bench 覆盖,runtime 实际只跑 L1 ~10 设备 + L2 通用兜底**。别为"全集精确"过度投入 runtime 不消费的精度。价值在"地基正确 + 可演进",不在"runtime 都用到"。

### Q2 甲-混节奏 — ✅认同
codex 自己的 pre-mortem 停点(「C1/C2 做完做对」别被理解成"全部人工核到 100% 才纵切",否则 demo 被地基拖死)对,采纳。纵切选 `空调温度`(覆盖 value 四件套/经验步长/端态读取)+ `车窗`(覆盖 position fan-out/百分比/安全读回)选得准。**补一条前置**:纵切前必须先有 schema validation gate(Oracle A 坑④),否则纵切验的是脏地基。

### Q3 新建 `semantic-function-contract` spec 替代 `vehicle-capabilities` — ✅认同 + 机制实锤
本地核实:archive 的 `define-capability-contract` 已有 **「superseded 标注」先例**(`proposal.md:7` 三处 draft 标 superseded 指向权威)。所以新 spec 用 **ADDED 新 capability + 旧 `vehicle-capabilities` 标 `superseded`**(不是物理 REMOVED,OpenSpec archive 的 spec 不回炉)。这有现成范式,照做。

### Q4 JSONL 主源 + YAML 派生视图 — ⚡加深 + ⚔️对抗
Oracle A/B 双重背书(IR 中间镜像 + go generate drift gate)。**但实锤对抗**:现有 P0 `function-spec-full.yaml` = **671 device、`grep source_row/source_sheet/row_hash` 命中 0、无 `.jsonl`** → 它是"设备聚合稿",**根本不是 Q4 拍的源行级 JSONL 主源**。结论:**P0 那份 YAML 不能当 C1 起点**,C1 必须从源表重建 JSONL(带 provenance),YAML 再从 JSONL 派生。+ Oracle B 坑:JSONL 无原生 FK/schema,`canonical_id/dedupe_group/second_turn_refs/execution_range_ref` 四类跨行引用**格式一个都不替你校验** → 必须落 `verify_refs.py` 实跑(见 §3 元对抗)。

### Q5 源行级建模 + dedupe + `dropped_rows=0` — ⚔️**最强对抗(HIGH)**
双建模本身 ✅(Kimball SCD Type 7 正统,Oracle B 背书)。**但 `dropped_rows=0` 必须改** —— Oracle B 实锤:它是 coincidental correctness 制造机,**逼脏行(合并格/重复表头/空语义)洗白成契约,比丢掉更危险**(丢掉至少总数对,洗白让下游静默吃 garbage)。
**改成分流账本**:`source_rows == valid_contract + quarantined + legacy_mapping`(守恒);硬门 = **`unclassified_rows == 0`**(每行必有归宿),但 `quarantined ≠ dropped`,带 reason 枚举(`merged_cell/duplicate_header/empty_semantics/malformed`),可审计可回头救。**目标不是"一行不丢",是"一行不黑洞"**。
+ `primary` 角色加 survivorship rule(按 `ds_protocol` 完整度/有无例句选,非任选第一行;记 `primary_selection_rule_version`)。

### Q6 源料中文不进仓 + hash + LoRA 从只读源取数 — ✅认同 + 加深
守红线,认同。**加深(接 Oracle A)**:hash 不只存 `source_row_hash`,还要存**整文件 sha256 锁定快照版本**(见 Q10)。链条写明:仓内 hash 仅作覆盖率/diff 锚,**LoRA 训练独立读冻结快照源表**,不依赖仓内 hash 还原原文。

### Q7 二次交互 sidecar(C4 消费)— ⚡加深
架构对(关系边独立 JSONL,C1 不并入主覆盖行)。**加深(Oracle B 坑)**:`unresolved_ref` 不能只"标记就放过" —— 设**收敛门 `unresolved_ref_ratio ≤ 2%`(目标 0),超阈 CI 红**;否则悬空边静默堆积,C4 多轮指代瘸腿("看着完整"的假象)。

### Q8 `semantic_range`(C1 引用)vs `execution_range`(C2 权威)— ⚡加深 + ⚔️小对抗
分层对(C1 只引用、C2 拥有、C3/DemoGuard 只按 C2 guard)。**对抗**:`range_conflicts` 会**爆炸成噪声** —— 语义范围大量是 `<摄氏度>`/`<N>` **占位型开放槽**(`function-spec-full-v0.yaml:19-21` 实证),naive 比对会让几乎每行都"conflict"。**必须区分**:`placeholder_open`(语义本就开放占位,正常,不进冲突账)vs `material_conflict`(语义明确 16-30 但执行 18-32,**才进** `range_conflicts` 必审)。

### Q9 `exec_tier`/`risk` 由 C1 定(A)— ✅(上轮已加强,已入 ADR:19)
上轮 3 点已记录:挂源行(非 device)+ `risk-policy.yaml` 单源收 R0-R3/ASIL 双轨 + `l1-demo-allowlist` 的 L1 必须 `reviewed`。本轮确认:`risk-policy.yaml` 单源 = Oracle 的"单源权威 policy 表"范式;`integration-blueprint.md:88` 已有 R0-R3 SafetyGate + `baseline-internalization-plan:36` 有 ASIL,双轨收口不可省。

### Q10 生成权威 = xlsx vs raw digest — ⚔️**对抗 codex 的 A(HIGH)**
codex 推 A(xlsx 活文件权威,digest 审阅缓存)。**方向对,但"活文件"是反模式**(Oracle A 强证据:codegen 输入必须不可变)。**正解 = A 的变体**:
- 权威 **不是** live `~/Downloads/*.xlsx`(随时被改、无版本控制、`副本/编辑版` 满天飞),**也不是** digest(二手,违 R1);
- 权威 = **冻结快照 `contracts/snapshots/<name>@<sha256>.xlsx` + manifest 记 hash/frozen_at**;活 xlsx 只作"人编辑入口";
- digest/JSONL **文本镜像 commit 进仓做 review 载体**(解决 xlsx 二进制 diff 黑洞),不是"只做缓存"。
codegen 只读冻结快照,起手三道硬 gate:`reset_dimensions()`(治 WPS dimension 不可靠)/ 合并单元格 forward-fill / schema validation。

---

## 3. 跨题元对抗:ADR「仓库没机制前不写 pre-commit/CI/gate」要改(HIGH)

ADR:19 + CONTEXT 反复写"没 husky/CI 前不写 gate"。**两路 oracle 都指出这是假 SSOT 的根**:
- Oracle A:drift gate(regen + `git diff --exit-code`)是 SSOT 成立的**前提不是可选** —— 没它,生成物被手改不被发现 = 96272132 的"假 SSOT"HIGH 坑。
- Oracle B:JSONL 跨行引用完整性"是 application logic 必须实跑,不是声明就有"。

**对抗结论**:**drift gate ≠ CI**。codex 把"没 CI/husky"当"不做 gate"的理由 = 混淆。Gate 可以是**一条本地命令**:`make verify`(= `python gen.py && git diff --exit-code` + `python verify_refs.py`)。没有 husky/GitHub Actions 也能本地手跑、能写进 dispatch 验收门。**建议:C1 必须落 `make verify` 本地校验,不等 CI**。这是把"假 SSOT"HIGH 坑钉死的最便宜动作(< 半天)。

---

## 4. 现有 P0 物料的处置(实锤)

`MAformac-p0/contracts/function-spec-full.yaml` = 671 device / 0 provenance / 无 jsonl。它**不符合** Q4/Q5 拍的 C1 架构(源行级 JSONL + provenance)。处置:**降级为"设备名 + 归一化编码的参考清单"输入证据**(帮 C1 知道有哪些 device),**不作 C1 主源**;C1 从冻结快照源表重新生成带 provenance 的 JSONL。守磊哥"不确认对不对,重新来"。

---

## 5. 给磊哥的 3 个 HIGH(停下拍)

1. **`dropped_rows=0` → 分流账本(`unclassified=0` + quarantine 显式列账)?** ⭐ 改(Oracle B 实锤:0-drop 洗白脏行比丢更危险)。
2. **Q10 权威 = 冻结快照(snapshot+sha256)而非活 xlsx?** ⭐ 改成冻结快照(Oracle A:活文件作权威是反模式)。
3. **C1 必须落 `make verify` 本地 drift+引用校验(不等 CI)?** ⭐ 落(否则 SSOT 是纸面,假 SSOT 坑复发)。

---

## 6. pre-mortem 三分类汇总

**🐯 tiger(HIGH,已给 mitigation)**:① `dropped_rows=0` 洗白脏行 → 分流账本 ② 活 xlsx 作权威漂移 → 冻结快照+hash ③ "没机制不写 gate" → 本地 `make verify` ④ JSONL 跨行引用无 FK → `verify_refs.py` 实跑 ⑤ WPS dimension/合并格静默丢字段 → 三道 codegen 硬 gate。
**🐯📄 paper-tiger(可控,有据)**:① "双建模太重" → Kimball SCD Type 7 正统,非过度设计 ② "JSONL 几千行扛不住" → 远在舒适区,真坑是引用校验非规模 ③ "xlsx 不能 merge" → solo 单人编辑无并发需求。
**🐘 elephant**:3990 全集契约主要服务 LoRA/bench,runtime 只跑 L1+L2 —— 别为全集精确过度投入 runtime 不消费的精度;甲档价值在地基正确与可演进,不在"全演"。

---

*本文 oracle URL 均为联网实际命中;file:line 均本地核对;pre-mortem 坑均带 mitigation,非空泛通用风险。*

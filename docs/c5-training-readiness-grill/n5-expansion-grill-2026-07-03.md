---
authority: grill_skeleton_tracking_not_ssot（决策 lock 后逐条回写 grill SSOT）
series: N5E
status: grill_expanded_reduced_default_locked（12 题：10 default_locked + N5E-005/006 磊哥键；2026-07-03 午后）
decision_ref: D-044/D-045/D-046
created: 2026-07-03 午后
ammo_status: 全齐（5 draft + 2 cross-grill + canary v1 FAIL→v2 PASS 两轮实跑）
canary_final: CANARY_PASS_EXPAND_OK（CANARY-ACCEPTANCE-REPORT.md，run 目录）
---

# N5E · wave-1 扩量节点 grill（canary→4.5k）骨架

> 按 D-046 常备规则：节点开始即建骨架，弹药喂入后 grill 展开 → 消减 → 磊哥 lock → 沉淀。
> 回顾入口（每题 recall 已决）：拍点包 1-7（`docs/c5-training-readiness-grill/wave1-owner-decision-package-2026-07-03.md`）/ gate7「§10.4 生成配比/§10.5 bug→C6 映射」（p5w 树，行锚见 `docs/c5-training-readiness-grill/n5-canary-grill-2026-07-03.md:10`）/ quota 公式 locked（`docs/c5-training-readiness-grill/landing-matrix.md:69`）/ N5 canary grill G1-G9（`docs/c5-training-readiness-grill/n5-canary-grill-2026-07-03.md`）/ F-044 默认锁（`docs/c5-training-readiness-grill/f044-default-lock-and-wave1-recipe-anchors-2026-07-03.md`）/ D-042 负例 deferred 裁决。

## 一、议题清单（historical：骨架期占位，终态见 §二决策矩阵）

| ID | 议题 | 承接已决 | 状态 |
|---|---|---|---|
| N5E-001 | 生成形态：多 sub-CC fan-out×批 vs 单长跑分段 vs 混合（成本/耗时/一致性） | D-045（sub-CC=Anthropic 厂商实现）；G4 | ⬜ 待弹药（%45 draft） |
| N5E-002 | 批任务契约：每批 prompt/字段模板/receipt 规范（保 digest 机械正确 + value-changed 登记，承 G2 教训） | G2 处置；FIX-PR29 硬化门 | ⬜ |
| N5E-003 | quota 公式接线：quota 公式（locked，`docs/c5-training-readiness-grill/landing-matrix.md:69`）的族×类 quota → 批次任务分配的 SSOT（Gate7RecipeQuotaConfig?） | landing-matrix:69；N4c config 面 | ⬜ |
| N5E-004 | judge 抽样设计：全量机械门 + family 抽样 judge（family 抽样停线语义，行锚见 `docs/c5-training-readiness-grill/n5-canary-grill-2026-07-03.md:17`）+ 抽样率 | 拍点5；G7 双 judge 交叉选项 | ⬜ |
| N5E-005 | 🔴 人工精度门 staffing：磊哥本人抽检 vs 首波跳过（拍点5 原题，磊哥键） | 拍点包:18 | ⬜ 磊哥拍 |
| N5E-006 | 🔴 执行基座 pin：merge 链（#26→#27→#28→#29→#31→#32）完成后 pin main SHA 重跑门（扩量硬前置） | 拍点1；G1 | ⬜ 卡 merge |
| N5E-007 | salvage 路径：旧文本 salvage 全量重过 vendor-enum judge + DataGate 的执行形态与批排（数字锚 `docs/c5-training-readiness-grill/wave1-owner-decision-package-2026-07-03.md:17`） | G9 | ⬜ |
| N5E-008 | diversity 门接线：canary 轻量检查 → 扩量的正式 diversity 门（进 pipeline 还是旁路脚本） | G3；FIX-PR31 diversity reason | ⬜ 待 %44 工具 |
| N5E-009 | C6 leakage 全量探针：扩量数据过探针的批次时机与 fail 处置 | G6 | ⬜ |
| N5E-010 | 数据 lineage 与落点：三件套归档规范 + 数据从 run 目录到训练输入的迁移与重验（pin 基座重跑 DataGate） | G8；P1-A lineage 先例 | ⬜ |
| N5E-011 | canary FAIL 回路：judge FAIL 行的处置（丢弃/修复重判/回喂生成器 prompt 改法）与再 canary 判据 | judge SPEC 门槛 ≥85% | ⬜ |
| N5E-012 | 扩量验收门：4.5k 全量的 CANARY→WAVE 升级判据（机械门全绿 + judge 抽样 PASS 率 + family 停线零触发?） | F-044/runbook 门 | ⬜ |

## 二、决策矩阵（2026-07-03 午后 grill 展开；弹药=5 draft + 2 cross-grill + canary 两轮实跑）

> 弹药文件（run 目录 `2026-07-03-n2n4-train-readiness/N5-canary/`）：EXPANSION-PLAN-draft / BATCH-CONTRACT-draft / SALVAGE-INVENTORY-draft / DIVERSITY-GATE-AND-WAVE-ACCEPTANCE-draft / JUDGE-SAMPLING-draft / CROSS-GRILL-44（0 P0 6 P1 3 P2）/ CROSS-GRILL-45（1 合同层 P0）/ canary-judge-verdict（v1 FAIL→v2 PASS）。

| ID | 锁定决策（⭐default，pending_leige_override 除注明磊哥键） | 吸收的 cross-grill 修正 | verdict |
|---|---|---|---|
| N5E-001 | **C 混合形态**：controller 从 locked quota 出批次 manifest；4 条 sub-CC lane 并发；🔴 **warmup 首批 N=50**（canary 60 行已证该量级可控），微批 D9/A12 全 PASS 后升到 EXPANSION-PLAN §0 的每批 75 行（run 目录 EXPANSION-PLAN-draft.md，%45 实算）；按 green/expected/bad 三情景各设 KPI | CG44-P1-4（N 条件化）+P1-5（三情景+warmup KPI） | default_locked |
| N5E-002 | **批任务契约 rev2**（%45 执笔）：①ledger（template_sample_id+args_diff）为生成方**硬产出 fail-closed**（缺=批直接 blocked，D-047 教训制度化，不靠中途补约束）②值优先不改+改值登记③**长度带宽下限进生成要求**（canary WARN 长度带宽的裁决落点（diversity-report-v2.md 长度分布 p90=11.1/p10=6.0，run 目录））④批 artifact SHA 绑定⑤diversity WARN → 显式 `paused_diversity` 状态（消 CG45-P1-3 无名 pause 态）⑥🔴 派生 hash/签名字段（prompt_hash/expected_tool_call_signature 等）必须由管道真配方**重算**，禁克隆模板原值（生成器 2026-07-03 披露：canary 克隆 hash 属探针既定属性 receipt §5 已声明不回改；扩量数据进训练前此项=与 ledger 同级 fail-closed 硬门） | CG44-P1-6（SHA 绑定）+CG45-P1-3+生成器 hash 披露 | default_locked→rev2 执行 |
| N5E-003 | quota SSOT=`Gate7RecipeQuotaConfig`（N4c 已实装 config 面），controller manifest 从其派生，禁手写第二份 | — | default_locked |
| N5E-004 | judge 抽样：**机械可判维（D5 泄漏/D6 脱敏/D9 ledger 对账）下沉脚本全量跑；LLM judge 只审语义维（D1/D2/D8 等）按 family 抽样 min(50,max(20,10%))**；可执行 family_judge_status 状态机+Wilson 下界+next-action；warning 行拆结构性/语义性两类，硬性上限+超限升级而非无界全审 | CG44-P1-1（状态机可执行化）+P1-2（warning 行拆分封顶）+P1-3（owner/tool 矩阵） | default_locked |
| **N5E-005** | 🔴 **磊哥键**：人工精度门 staffing——⭐磊哥本人按 sample size 抽检（拍点5 原 default）或拍「首波跳过人工门，数据门+judge 双机械门先行」 | — | **pending_leige** |
| **N5E-006** | 🔴 **磊哥键（卡 merge 链）**：扩量启动前 pin merge 后 main SHA；controller 记录四元组（main_pin_sha/quota-config SHA/catalog-manifest SHA/vendor enum）；中途 main 变=旧批降级 candidate 不混正式 receipt | EXPANSION-PLAN §1 全文吸收 | **pending_leige（billing→merge 后自动满足）** |
| N5E-007 | salvage=**A 全量重判入 recovery pool，两道 stop gate**：projection gate（4500 行全投影当前 schema，`direct_pass=0` 预期，🔴 禁 legacy flag 放行）→ rejudge/DataGate gate（全量 vendor-enum judge+DataGate）；3804 行仅作 10 族 recovery quota（`reuse_origin=pr3_generated_utterances_final`），696 非 10 族 unsupported/drop 不改写；旧文件 sha 冻结 `46a36018…` | SALVAGE-INVENTORY 实算（4500/3804/696/direct_pass=0 全一手） | default_locked |
| N5E-008 | diversity **双接线**：controller 旁路脚本=每批/每 family 即时硬门（含长度带宽阈值）；Gate7 Swift port 在正式 4.5k 验收前完成（现 Gate7 只有 distinctRate+lengthBuckets，p5w 树 Gate7GeneratorPipeline.swift 行 517-555（%44 draft 亲核锚）） | %44 draft default 全吸收 | default_locked |
| N5E-009 | C6 leakage：exact-ID probe **每批跑** + 全量收口再跑一次；任何交集>0=批 blocked | — | default_locked |
| N5E-010 | lineage：每批三件套（生成 receipt/门 receipt/judge verdict）+INDEX sha256 绑定；🔴 数据进训练前必在 pin 基座重跑 DataGate（G8→制度） | CG44-P1-6 同源 | default_locked |
| N5E-011 | FAIL 回路（canary 一轮收敛实证）：FAIL→**作者修**（生成器/契约按归属）→**scoped re-judge**（失败维+改动行，不全量重审）；同批 **2 轮不收敛→上抛 commander 裁决**（防无限回圈，同 canary「不再翻改」裁决先例） | — | default_locked |
| N5E-012 | 扩量验收门（%44 判据 + CG45 P0 修正）：🔴 **声称分层**——机械全量维（DataGate/diversity 脚本/C6 probe/D5/D6/D9 脚本化对账）可出全量声称；语义抽样维只出「抽样置信」声称**禁升格全量**（CG45-P0-1 抽样假绿封堵）；判据=机械门全绿+judge 抽样 family 全≥0.8+无停线+整体抽样 PASS≥0.90+F-044 配方锚在位；措辞=`WAVE_EXPANSION_ACCEPTED_LOCAL`，非 train-ready/V-PASS；DataGate status 写死真实字符串（CG45-P1-2）；反例引用更新为 canary v1 历史态（CG45-P1-4） | CG45 P0-1/P1-2/P1-4 + %44 draft | default_locked |

## 三、消减表

| 消减组 | 吸收 | 状态 |
|---|---|---|
| R1 生成执行（形态/批契约/quota） | N5E-001、002、003 + CG44 P1 第4、5、6条 + CG45 P1-3 | default_locked，落点=BATCH-CONTRACT rev2 |
| R2 评审体系（抽样/声称分层/人工门） | N5E-004 与 N5E-012 + CG44 P1 第1、2、3条 + CG45 P0-1、P1-2、P1-4；N5E-005 磊哥键 | default_locked（005 除外） |
| R3 数据治理（salvage/diversity/leakage/lineage） | N5E-007、008、009、010 | default_locked |
| R4 边界与回路（基座 pin/FAIL 回路） | N5E-006（磊哥键，卡 merge）/011 | 011 locked；006 pending |

## 四、landing

| 落点 | 承接 | 状态 |
|---|---|---|
| BATCH-CONTRACT rev2（%45） | N5E-001、002、003、008 条款执笔 | ⬜ 待派 |
| JUDGE-SAMPLING rev2 → 可执行状态机（%43） | N5E-004 与 N5E-012 | ⬜ 待派（可并入 rev2 批契约附录） |
| canary 三件套+INDEX 归档 | N5E-010 | 🔄 %43/%44 在产 |
| 磊哥键打包 | N5E-005（人工门）+ N5E-006（基座 pin，billing→merge 后自动满足） | ⬜ 与 billing/merge/run-auth 同包上抛 |
| 沉淀 | D-048（grill lock 记账）+ MEMORY as-of + N5E 骨架状态刷 | 🔄 本次 |

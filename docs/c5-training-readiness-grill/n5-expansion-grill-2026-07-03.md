---
authority: grill_skeleton_tracking_not_ssot（决策 lock 后逐条回写 grill SSOT）
series: N5E
status: skeleton_upfront（D-046 常备规则第 1 步；弹药未齐，grill 未开跑）
decision_ref: D-044/D-045/D-046
created: 2026-07-03 午后
ammo_pending:
  - N5-canary 验收三件套（生成 receipt / DataGate receipt / %43 judge verdict）
  - "%45 EXPANSION-PLAN-draft.md（生成形态/quota 接线/judge 抽样/salvage/基座前置）"
  - "%44 diversity-report + canary C6 leakage probe"
grill_run_precondition: canary verdict 落地
---

# N5E · wave-1 扩量节点 grill（canary→4.5k）骨架

> 按 D-046 常备规则：节点开始即建骨架，弹药喂入后 grill 展开 → 消减 → 磊哥 lock → 沉淀。
> 回顾入口（每题 recall 已决）：拍点包 1-7（`docs/c5-training-readiness-grill/wave1-owner-decision-package-2026-07-03.md`）/ gate7「§10.4 生成配比/§10.5 bug→C6 映射」（p5w 树，行锚见 `docs/c5-training-readiness-grill/n5-canary-grill-2026-07-03.md:10`）/ quota 公式 locked（`docs/c5-training-readiness-grill/landing-matrix.md:69`）/ N5 canary grill G1-G9（`docs/c5-training-readiness-grill/n5-canary-grill-2026-07-03.md`）/ F-044 默认锁（`docs/c5-training-readiness-grill/f044-default-lock-and-wave1-recipe-anchors-2026-07-03.md`）/ D-042 负例 deferred 裁决。

## 一、议题清单（占位，grill 时逐题展开；来源=G 系列升级 + 拍点包未决项）

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

## 二、决策矩阵（grill 展开时逐题填）

| ID | 选项 | ⭐default | 量化 | 事实锚 | verdict |
|---|---|---|---|---|---|
| （待 grill） | | | | | |

## 三、消减表（grill 后填）

| 消减组 | 吸收 ID | 映射验证 | 状态 |
|---|---|---|---|
| （待消减） | | | |

## 四、landing（lock 后填）

| ID | 落点（代码/配置/receipt/流程） | 状态 |
|---|---|---|
| （待 lock） | | |

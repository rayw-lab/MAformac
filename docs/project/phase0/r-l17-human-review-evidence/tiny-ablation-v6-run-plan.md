---
authority: run_plan_under_v6_overnight_auth
run_auth: v6-overnight-run-auth-2026-07-02.md（磊哥 verbal 转写）
created: 2026-07-02 深夜
status: staged_pending_phase123_closeout
---

# v6 tiny-ablation + wave-1 数据 执行计划（通宵）

## Phase A — Phase 1-3 收稿亲核（commander）
- P12（%45）：亲自重跑镜像门两命令——old v5 `c5-training-samples.jsonl` 喂新 coverage 门必 FAIL（失败原因=trainable 区缺 `<tool_call>` wrapper/payload）；新 builder 产物必 PASS 双门。swift test 全绿亲核。
- P3H（%44）：亲核 truncate P1 修复回归测试（训练形态 `\n\n<tool_call>` 输出必提取出 tool）+ 重放我的复现脚本确认修复。
- P3D（%43 已收割）+ GF-W2 grill 稿收讫即可（grill lock 不阻塞 run）。

## Phase B — tiny v6 数据 rebuild + 数据门
- 命令面沿 v5 addendum v2：`prepare + --dev-selection 0`，40 行 tiny subset，A+ 契约 builder（loss_objective=assistant_full_except_think）。
- 绿门：40 行全 trainable、coverage 双门 PASS、supervision digest 进 receipt、C6 泄漏排除复核（B 轴 15 行若入 train 面则同门检查）。

## Phase C — tiny v6 训练（配方冻结，四红线）
- 与 v5 完全同配方：rank16Mainline / batch1 / grad16 / grad_checkpoint / seq5120 / 600 iters / LR 不变。唯一变化=数据契约（A+），使裁决"数据契约修复是否解 NO_TOOL"单变量成立。
- 输出：metrics jsonl（NONFINITE=0 绿门）+ checkpoint（不入仓）。

## Phase D — 四轴 probe（base + adapter 双臂）
- P3H 修复版 harness；decode 契约 `decode-contract.greedy.json` 固化进 receipt；A15/B15/C4/D34 全轴双臂各跑一遍，same tokenizer/prompt skeleton/parser。

## Phase E — paired verdict
- A hard=15/15、B hard=14/15+无同族连败（F-044 草案 default，阈值敏感则单列敏感性不自拍终值）；C/D report-only。
- verdict 词表：PASS_TINY_SCOPE / FAIL_WITH_ATTRIBUTION / INVALID_PROBE（决不升格为 candidate/C6/V-PASS 语义）。
- 若 FAIL → 按磊哥令：先 grill 拆解（7 列矩阵）→ bug-iceberg-teardown 反思 → 报告 → 融合 grill 清单。

## Phase F — wave-1 数据真生成 + C5DataGate（与 D/E 可并行起）
- A+ 契约 builder 全量生成（D-domain 562 工具面）→ C5DataGate 全量：must_not_train=0 / parent_overlap=0 / C6+trap 零进 train / masking(supervision) coverage 全 true / exit 65 阻断验证。
- 输出：wave-1 数据 receipt + 数据门 receipt（数据本身按 §6 纪律处理，不入仓的部分只入 hash/manifest）。

## 收口
RECEIPT-V6（含各 Phase 证据表 + residual risk）→ 报磊哥（含 F-044 阈值敏感性 + GF grill 消减包）。

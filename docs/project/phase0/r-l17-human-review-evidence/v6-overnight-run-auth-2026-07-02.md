---
authority: run_authorization_transcribed_from_owner
signer: 磊哥（human owner，verbal via /goal 指令）
transcribed_by: claude-commander %42
signed_at: 2026-07-02 深夜
scope: v6 tiny-ablation rerun + wave-1 数据真生成 + C5 数据门
---

# v6 通宵 run-auth（磊哥 verbal 转写）

## 授权原文（/goal 指令节选，逐字）
「今晚所有决策我授权 通宵任务；tiny ablation要跑完，数据 wave-1 真生成 + 数据门也要跑完；遇到问题 先拆解grill，再融合到之前grill清单，先按 A+ 契约修 loss/augmentation、coverage gate、probe 四轴、base-vs-adapter 配对和 decode 契约；old v5 数据必须 fail，新 v6 数据必须 pass。每个 worker 必须有 output file、证据表、residual risk；commander 收稿以文件为准…审计的话不安排hermes或者gptpro了，就让3个worker干即可。」

## 授权范围（明确解锁）
1. **tiny-ablation v6 真跑**：tiny-scope 训练（A+ 契约构建的数据）+ 四轴 probe（A/B hard、C observe、D report-only）+ base-vs-adapter 配对 + decode 契约固定。前置=Phase 1-3 交付收口 + 镜像门过（old v5 FAIL / new v6 PASS）。
2. **wave-1 数据真生成**：C5 训练数据全量生成（D-domain 562 工具面）。
3. **C5 数据门跑完**：C5DataGate validator 全量 pass（must_not_train=0/泄漏零/masking coverage）。

## 仍 BLOCKED（本授权不覆盖）
full wave-1 训练、C6 acceptance、candidate comparison、model-quality 评测定案、demo-golden-run、voice、endpoint readiness、UIUE merge、V/S/U-PASS 声称。

## 四红线（仍生效）
不降 LR / 不改 rank/scale/clip/iters / 不扩样本口径 / 不改阈值语义（F-044 阈值 Q1-Q2 用草案 default 15/15、14/15 跑 v6，终值仍待磊哥 lock——若 v6 结果对阈值敏感，报告中单列敏感性，不自拍终值）。

## 过程纪律（磊哥同令）
- 遇问题先 grill 拆解（7 列矩阵落文件）→ 融合进既有 grill 清单 → 按 ⭐default 推进。
- 重大决策发现之前错了 → bug-iceberg-teardown 三轮反思模式 → 输出报告 → 继续 grill 推进。
- 审计由 3 worker 交叉互审承担（本晚不派 hermes/gptpro）。
- 每 worker 交付硬三件：output file + 证据表 + residual risk；收稿以文件为准。

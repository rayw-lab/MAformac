---
authority: grill_scoring_table
artifact_kind: c5_grill_scoring_table
paradigm: UIUE 215-grill 评分表（关键选型多维评分选 ⭐）
created: 2026-07-01
status: commander_scored_pending_human
---

# C5 grill 评分表（Scoring Table）

> UIUE 215-grill 范式三件套之三（决策矩阵 / 消减表 / **评分表**）。从 331 决策挑【关键选型/裁决性 load-bearing】决策，commander 多维评分辅助磊哥拍板。🔴 **评分 = commander 工程判断，拍板权归磊哥**（高分 = 强 ⭐ 默认，磊哥可直接 ✓；低分项需磊哥权衡）。

## §1 评分维度（1-5 分，5 最强）

| 维度 | 含义 |
|---|---|
| **防0/34力** | 防双仓惨败（0/34 + θ-α）重演的强度（cite P1-P9 直击根因=5）|
| **工程量** | 实装成本（5=已实装/低成本，1=大重构）|
| **论文背书** | 论文/一手依据强度（5=论文+代码双坐实，1=拍脑袋）|
| **端侧可行** | 端侧部署约束兼容（5=完全兼容，1=违离线/资源）|
| **R-L17前置** | 是否训练前节点必需（5=硬前置必过，1=可选优化）|

## §2 关键选型评分（17 条 load-bearing，总分降序）

| 决策 | 议题 | ⭐选项 | 防0/34 | 工程量 | 论文 | 端侧 | R-L17 | 总分 | commander 备注 |
|---|---|---|:-:|:-:|:-:|:-:|:-:|:-:|---|
| **F-002** | counterfactual 真删工具 | A 物理删+活断言 | 5 | 5 | 5 | 5 | 5 | **25** | 🟢 已修（cut5 `:2612`），守住不回退即可 |
| **F-001** | tool surface 单源派生 | A ToolContractCompiler | 5 | 3 | 4 | 5 | 5 | **22** | 🔴 惨败1③+惨败2主因，最高优先 |
| **F-004** | C6 成功标准口径 | A hard_pass 锚 10/23 | 5 | 4 | 3 | 5 | 5 | **22** | 🔴 P9 成功标准定义（两次惨败都缺）|
| **F-010** | surface-source preflight 门 | A <80%→exit65 | 5 | 4 | 3 | 5 | 5 | **22** | 🔴 θ-α 主因防线（gate 3 已立）|
| **F-044** | G6-C tiny ablation 裁决门 | A 未过不得声称范式修复 | 5 | 3 | 4 | 5 | 5 | **22** | 🔴🔴 audit「最该补」，能否进训练唯一闭环证据 |
| **A-001** | LR 1e-4 守不回 2e-4 | A | 5 | 5 | 5 | 4 | 3 | **22** | 🟢 lr-matters`2602.04998` 亲核背书+本机实测 |
| **F-043** | positive-not-diluted+OOD | A action 轴独立 fail-closed | 5 | 4 | 3 | 5 | 4 | **21** | 🔴 audit P1-1，0/34 混合体假象防线 |
| **F-003** | 矛盾检测器 grouping key | A 用实际 prompt 文本 | 5 | 4 | 3 | 4 | 5 | **21** | 惨败1②循环失守，P3 |
| **E-002~006** | C6 四层阈值化 | C 逐层 fail-closed | 5 | 3 | 4 | 5 | 4 | **21** | 🔴 gate 6（当前只统计无阈值）|
| **F-006** | tool_call 渲染序 | A name-first | 4 | 5 | 4 | 4 | 4 | **21** | 🟢 已修（`:1823`），守住 |
| **A-016~018** | masking 三形态实装 | A enforce | 4 | 3 | 5 | 4 | 4 | **20** | gate 2，Hammer 背书 |
| **F-009** | 审计加语义+实跑 | A | 5 | 3 | 3 | 4 | 4 | **19** | 惨败1⑨（本 grill 双 audit 正是落地）|
| **D-016** | 多轴 held-out 切法 | A 六轴硬切 | 4 | 2 | 4 | 4 | 4 | **18** | gate 5（当前只 parent 级）|
| **D-031~037** | 云 generator 多源+异源judge | A | 4 | 2 | 4 | 3 | 4 | **17** | gate 7（research 锁方向代码未闭环）|
| **F-019** | 范式 surface 择一 | A G6-C tiny 定（倾向 D-domain）| 4 | 3 | 3 | 4 | 3 | **17** | 不凭推测拍，tiny 实验定 |
| **A-028** | 训练后端 | A mlx-lm 本机 | 3 | 4 | 3 | 5 | 4 | **19** | 无 N 卡，云训不考虑 |
| **F-014** | train-health vs model-quality | A 严格分账 | 5 | 4 | 3 | 4 | 3 | **19** | θ-α 训练健康 action 全塌 |

## §3 高分共识（≥21 = 强 ⭐ 默认，建议磊哥直接 ✓）

- **已修守住类**（F-002 真删 25 / F-006 name-first 21）：代码已修（cut5/name-first），grill 决策 = 「retrain 时仍 enforce 不回退」，磊哥 ✓ 低风险。
- **最高优先实装类**（F-001 单源 22 / F-004 成功标准 22 / F-010 preflight 22 / E-002~006 四层 21）：直击两次惨败根因 + R-L17 硬前置，建议优先实装。
- **audit 补的裁决门**（F-044 G6-C ablation 22 / F-043 positive-not-diluted 21）：audit 强调「最该补」，能否进训练的闭环裁决，建议磊哥重点确认。
- **论文背书类**（A-001 LR 1e-4 22，lr-matters 亲核）：守住别回 2e-4。

## §4 待 audit round-02 回后补

round-02 深化（D-/A-/E-046~095）+ commander F- 的 audit 跑中 → 回后把 round-02 的关键选型（如五轴具体切法/DoRA/checkpoint指标/四层具体阈值数）纳入评分表 + 修正。

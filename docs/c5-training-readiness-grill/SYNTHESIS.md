---
authority: grill_synthesis_closeout
artifact_kind: c5_grill_synthesis
paradigm: UIUE 215-grill 收口综合（汇总 + 双审吸收 + 人审拍板清单）
created: 2026-07-01
status: 5_gate_groups_signed_2026-07-01_construction_dispatched
---

# C5 训练就绪 grill — 收口综合（SYNTHESIS）

> 🔴 **grill 主体完成**。magnet goal「推进到 C5 可开始 LoRA 训练前节点」的 grill 阶段（想清楚做什么）收口。本文 = 一处看全貌 + 磊哥睡醒拍板入口。**守 R7：到节点为止，真训练等磊哥 candidate signoff + run auth**。
> 入口链：本 SYNTHESIS（收口结论）→ `README.md`（范式+12维度）→ 6 worker 决策矩阵 + `worker-commander-failure-defense-decisions.md`（332 决策）→ `reduction-table.md` / `scoring-table.md` / `landing-matrix.md`。

## §0 交付总览（UIUE 215 范式）

| 产物 | 数量/状态 |
|---|---|
| **决策矩阵** | **332 决策**：W1 数据 95（D-001~095）/ W2 算法 95（A-001~095）/ W3 评测 95（E-001~095）/ commander 纵切 47（F-001~047）|
| 消减表 | 12 维度计数 + 8 gate 覆盖 8/8 + 消减规则（`reduction-table.md`）|
| 评分表 | 17 条 load-bearing 选型多维评分选 ⭐（`scoring-table.md`）|
| landing matrix | 8 gate + 2 裁决门 × 落地态 × 现状（`landing-matrix.md`）|
| 双审（magnet 铁律回稿审）| 第一轮 135 + round-02 150 + commander 47 = **两轮 adversarial-auditor 全 0 P0** |

## §1 双审吸收清单（两轮 audit findings 逐条状态）

### 第一轮 audit（135 决策，V-PASS-WITH-FIXES，cite 最干净抽核 ≥35 条零编造）
| finding | 吸收 |
|---|---|
| P1-1 positive-not-diluted+OOD 遗漏 | ✅ 补 **F-043** |
| P1-2 G6-C/tiny-overfit ablation 裁决门遗漏（audit「最该补」）| ✅ 补 **F-044** |
| P1-3 README 惨败表旧行号 stale | ✅ 加行号 banner（已修根因别当威胁）|
| P2-1 lr-matters `2602.04998` 亲核 | ✅ commander WebSearch 坐实（真，2026-02 NTU/MIT，LR调好vanilla够用）|
| P2-3 工具数 [TBD] landing 收口 | ✅ 补 **F-046** |
| P2-2 E-027 normalization 待实装措辞 | 🟡 综合标注（E-027 per-tool normalization 当前未实装属 agentevals 借鉴提案）|

### round-02 audit（196 决策，T-PASS+V-PASS-WITH-FIXES，cite 逐字命中 ≈97% / ID 100%）
| finding | 吸收 |
|---|---|
| P1-1 enable_thinking/no-think 训练 surface 全零覆盖（唯一真遗漏，θ-α 第二战线）| ✅ 补 **F-047**（亲核 `:2352` discoveryFinding + B1 patch `:1668`）|
| P1-2 W2 round-02 重复率 ≈30%（超参守护层，非缺陷）| 🟡 综合定位：W2 round-02 = round-01 超参的「反 θ-α 证据门」，非 50 独立新决策 |
| P1-3 E-060 contractBundleFingerprint 嵌套组件当 C6EvalRun 顶层 | 🟡 综合标注：E-060 的 stateCells/caseDataset/semanticContract 在嵌套 `contractBundleFingerprint`（`C6VehicleToolBench.swift:697,:733` + `C6ContractBundleFingerprint.swift:92-97`）非 C6EvalRun 顶层 |
| P2-1 F-029 cite R7:13→13-14 | 🟡 综合标注（差 1 行，语义对）|
| P2-2 D-065 防惨败列补 cite P5（empty=hit 最对口）| 🟡 综合标注：D-065 应补 cite P5（`8d-rootcause.md:101` C6口径修）+ `:30-32` 混合体定性，与 F-043 对齐 |
| P2-3 W3 ⭐ 全选 C（最严）| 🟡 综合留意：安全/golden/unsupported 维持 C（100%/一票否决正确）；demo_fuzz 层允许阈值化非 100%（E-047 已选 80% 合理），别因怕 θ-α 一刀切到不可达（retreat-reflex 对偶）|

🔴 **覆盖度（audit completeness critic 双轮确认）**：SYNTHESIS 8 gate = 8/8 全覆盖；pre-mortem 7 失败模式 = F-034~039+043 逐一映射；R-L17 = F-027~031+045 覆盖；θ-α 通宵教训 = E-093 中途 checkpoint gate。**唯一遗漏（enable_thinking）已补 F-047**。

## §2 🔴 人审拍板清单（磊哥睡醒拍，评分表 ≥21 高分 ⭐ + 关键裁决）

> 默认采纳 commander ⭐（magnet「有推荐选项默认你的推荐」）。下列高分共识可直接 ✓，裁决门重点确认。
>
> ✅ **2026-07-01 磊哥拍「我都按照推荐来 没啥问题」= formal lock 本批 5 gate ⭐ 组**（E-002~006 / F-043 / D-016 / F-044 / D-031~037），construction 已派发 g6/g5/g7（**D-007** + reduction-table §4）。其余高分 ⭐（F-001/F-004/F-010/A-001 等）随各自 construction 排期再 lock。🔴 PR merge to main 仍是磊哥最终 apply gate。

**A. 已修守住类（✓ 低风险，retrain 时不回退）**
- F-002 真删工具(25)、F-006 name-first(21) —— 代码已修（cut5 `:2612` / `:1823`）

**B. 最高优先实装（直击两次惨败根因 + R-L17 硬前置）**
- F-001 tool surface 单源派生(22) / F-004 C6 成功标准 hard_pass 锚 10/23(22) / F-010 surface-source preflight ≥80%(22) / E-002~006 C6 四层阈值化 fail-closed(21) / F-003 矛盾检测器 key 用实际文本(21)

**C. audit 补的裁决门（重点确认，能否进训练的闭环证据）**
- 🔴 **F-044 G6-C/D-fix tiny ablation 裁决门(22)**：未过不得声称范式修复成功（empty 28/34→<5/34）—— audit 两次强调「最该补」
- 🔴 **F-043 positive-not-diluted+OOD invariant(21)**：action 轴独立 fail-closed 防被 negative 稀释成 0/34 混合体假象
- **F-047 think/no-think surface 同源**：θ-α surface mismatch 第二战线

**D. 论文背书**
- A-001 LR 1e-4 守住别回 2e-4(22) —— lr-matters `2602.04998` 亲核背书

## §3 到训练前节点缺口（landing-matrix 现状）

差 **5 ❌ gate**（多轴held-out / C6四层阈值化 / 云generator pipeline / tiny ablation裁决 / positive-not-diluted）+ **3 ⚠️**（训练循环真跑 / masking三形态 / 工具数实算）+ **R-L17 candidate signoff（磊哥最后一拍）**。
🔓 **R-L17 route-only 已签解锁 rebuild-C6 four-layer construction**（gate 6，可先做，是 retrain-c5 硬前置）。

## §4 下一步（commander 自驱，守 agree-before-build + R7）

1. **磊哥人审拍板**（§2 清单）→ locked 决策落 landing matrix。
2. **rebuild-C6 §1 construction preconditions**（R-L17 已解锁，gate 6，不需额外授权；§2/§3 需 magnet propose review）—— commander 可自驱推进。
3. 🔴 **真训练（retrain-c5 data gen + train）守 R7 BLOCKED**，等磊哥 candidate signoff + run auth，本 grill 不越此线。

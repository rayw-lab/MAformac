> 🔁 **双 commander 独立收敛注记（2026-07-04 夜）**：本档为影子 commander（死机前原会话）19:25 独立判定；正牌 commander 20:0x 独立填 `../..//F044-R2B-VERDICT-TEMPLATE.md` 终判段得**相同结论**（F044_R2B_FAIL_STRATIFIED，D-095）。canonical=D-095+模板终判段；本档保留作独立佐证。

# F044-R2B-VERDICT — R2b shorttrain behavior gate

verdict: **F044_R2B_FAIL（分层：安全面大捷+同分布大效，跨分布零移动+新负面探针恶化）**
judged_by: claude-commander 四轴判定（D-085 门+R2B-4 跨轨 qa 口径）；eval 执行=%1 训练执行官（raw counts only, no verdict claim）
claim_boundary: 不声称 train-ready/V-PASS/C6；扩充轨改善只归因同分布配方有效，不证明跨分布泛化。

## 四轴判定（D-085 门）
| 轴 | base | adapter | 门 | 判 |
|---|---|---|---|---|
| A 判门轨 | 3/15 | 10/15 | ≥12 | ❌（与 R2a 完全持平，残余同 5 例 A-011~015，零新退化） |
| B 判门轨 | 9/15 | 9/15 | >9 | ❌ zero delta 第三轮（失败集逐例同 R2a） |
| D 判门轨 | 18/34 | 19/34 | ≥18 | ✅ +1 |
| qa 跨轨 | 判门轨 0+扩充 base 2 | **判门轨 0**+扩充 adapter 9 | =0 | ❌（扩充轨 QUERY_ABSENT_TO_ACTUATION 9 例） |

## 载力发现（三条，全一手）
1. **MP-029 修复达成**：判门轨 query→actuation 清零（R2a 安全级病例）——负例批在已覆盖形态上有效。
2. **同分布 vs 跨分布劈叉**：扩充轨 B 15/26→**25/26（+10）**、Q 14→17，判门轨 A/B **逐例纹丝不动**——修复配方在与其同源的 case 上大效、对 R2a 时代判门 case 零迁移。判据性证据=训练分布与判门 case 话术空间不重叠，非模型容量问题。
3. **新负面探针恶化**：无 query intent 族「查询式话术」adapter 出手 9 例 vs base 2（unsupported 负例每族仅 1-3 行 vs positive 满配→配比不足反被 positive 带偏）。

## 处置（R2B-8 决策树，零临场拍）
- qa>0（跨轨口径）=FAIL_SAFETY → 不连训；审 query-style unsupported 配比。
- B zero delta=FAIL_B_DIRECTION → R3 表示层/bundle 复审（W7/W11 bundle v2 全案+判门 case 话术空间纳入配方的口径 grill）。
- 候选晋级 BLOCKED；正式训练不起（五条件①不满足）。

## 产物
train receipt=$D/F044-R2B-TRAIN-RECEIPT.md（sha 6d17b197）；eval=TD-eval-run155204-ready/{original-gate,expanded,TD-EVAL-RECEIPT.md,TD-EVAL-RAW-COUNTS.json,query-zero-tolerance-cross-track.json}；adapter sha 0d9b712b。

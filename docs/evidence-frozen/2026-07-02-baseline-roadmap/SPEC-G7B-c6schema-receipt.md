# SPEC-G7B — C6 add-only subset schema + 六轴 digest receipt（%43）

## 边界（磊哥 D-019 硬条件二，写死）
🔴 Phase-1 construction only：schema/receipt/fixture + 单测。不 C6 acceptance / 不真评测 / 不训练。
🔴 worktree：`git -C ~/workspace/MAformac worktree add ~/workspace/MAformac-g7b -b c5gate/g7impl-b-c6schema-receipt 80ea379c`。禁 doc-absorption 主树写实现。🔴 文件面只碰 `Core/Bench/` + `Tests/` 新文件（G7A 在 scripts/generated，别撞）。

## inline locked 决策
1. **C6SubsetContext add-only（S-208 ⭐C）**：C6 case 与 eval run 新增 optional 结构 `subset_policy_id/subset_group_id/mount_mode/mounted_tool_ids_digest/grammar_tools_digest`——**add-only**（旧 case 不带字段必须照常 decode，legacy Codable 教训 = PR#10 `decodeIfPresent ?? nil` 模式）。
2. **subset_failure_class（S-209 ⭐C）**：gate_result 增枚举 `missing_expected_in_mounted / actual_not_in_allowed / none`——**漏挂失败与模型失败分账**（S-010 routing_miss 同源；四层语义不变）。
3. **三层不支持（S-210 ⭐C）**：expected 侧支持三层拒识语义 `group_out_of_mount(允许重载/澄清，非全局 unsupported) / mvp_unsupported(10 族外车控) / global_unsupported(非车控)`。
4. **六轴 digest receipt writer**：新 receipt 结构含 `target_in_prompt / expected_in_mounted / actual_in_allowed / prompt_tools_digest / grammar_tools_digest / subset_policy_digest`，任一失配 = BLOCKED verdict（fail-closed），禁 warn-only。digest 口径与 G7A manifest entry 一致（先按字段名对齐，G7A 的 manifest 落地后 fixture 对接）。
5. **测试**：legacy decode 兼容（无 subset 字段旧 fixture 全过）+ subset_failure_class 分账行为测试（构造漏挂 fixture→missing_expected_in_mounted 非模型失败）+ receipt 失配 BLOCKED 行为测试。

## 验收
`swift test` 相关 suite 全绿 + make verify-all 过（sibling UIUE 噪声照旧单列）→ commit → env -u push → PR base=main 不 merge → RECEIPT-G7B.md + DONE-G7B + REPORT 行。

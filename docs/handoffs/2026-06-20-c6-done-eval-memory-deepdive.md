# Handoff 2026-06-20 深夜 — C6 done + eval/短时记忆深扒 workflow 进行中

> 七段模板（collaboration §4.5 长任务规范，append-only 永不回改）。compact 续接 / 跨 session 接力用。

## Goal
MAformac 端侧离线 Qwen+LoRA 车控语音 demo。当前 = 吸收三刀（深扒 eval+短时记忆 repos）+ **Qwen3.5-2B 选型研究**（磊哥倾向升主力）。

## Constraints & Preferences
1. **不降级**（star>1000 工程价值全量吸收，只 drop 真不适用载体）。
2. **选型/版本/"有没有 X" 事实断言必先 pre-mortem 联网搜证**（刚复犯 Qwen3.5-2B：凭知识库断言"没有 2B"被磊哥纠；已沉淀 `pre-mortem-reflex` 触发条）。
3. **单工作树并发硬 gate**：`git checkout`/`merge` 前先 `git status`，有我没建的 untracked/modified（Core/contracts/Tests）= codex/workflow 在跑，STOP 别切（已复犯 2 次，memory `maformac-single-worktree-concurrency`）。
4. 称磊哥 / 中文 / 选择题打字列选项+⭐默认（不用 AskUserQuestion 弹窗）。

## Progress (Done / In Progress / Blocked)
- **Done**：C1/C2 archived → C3 apply done(swift test 48绿) → **C6 propose+apply done**（两层 CC 审 SOLID；base Qwen3-1.7B 无 LoRA `hard_fail` 如实 IrrelAcc 0.789=C5 提升判据；merge main `6d02771`）。长任务规范落 `collaboration §4.5`。pre-mortem-reflex 加"选型断言必搜证"触发条。
- **In Progress**：**workflow `wf_2ce97aa2-9bd` 后台跑中**——14 repo blueprint-teardown(写 `docs/research/2026-06-20-teardown-*.md`，已写 6/14) + **Qwen3.5-2B vs 1.7B 可行性**(agent 先 pre-mortem 联网搜证) + 综合吸纳意见。完成有 `<task-notification>`。
- **Blocked**：无。

## Key Decisions
- 三刀 = 第一刀归位✅ / 第二刀 C6✅ / **第三刀 C5 next**。
- C6 三 NIT（readback 门退化纯文本 / coverage MVP 9-671 / model 权重 hash 未入 eval）= C5 前补。
- **Qwen3.5-2B**：磊哥 2026-06-20 倾向**升主力**(1.7B 降 fallback)，但端侧 MLX/`qwen3_coder` 格式/Metal 延迟可行性**由 workflow agent 联网搜证定**（CC 不预写死，吸取复犯教训）。

## Next Steps
1. **等 workflow 完成 → ground-truth 核产出**（teardown 真扒非空壳带 file:line + Qwen 实测分有来源）+ 综合吸纳意见给磊哥 + 两层审。
2. **统一 commit**（workflow 写的 docs/research/teardown + 本 handoff + continuation）。
3. 第三刀 **C5 数据门 dispatch**（含补 C6 NIT readback 模板 + model hash）。
4. C4 短时记忆/三层路由解冻 → C7 voice（后接 **UI/UE 重评估**待办）。

## Critical Context
- workflow script + transcript：`~/.claude/projects/.../workflows/`（Run ID `wf_2ce97aa2-9bd`，`/workflows` 看进度）。
- 暂存 `raw/05-Projects/MAformac/teardown-staging/`：dispatch 文件（C6 apply / first-knife / second-knife / 长任务规范段）。
- **起手读**：`CLAUDE.md` → `MEMORY.md`(进度 v5) → `docs/优化待讨论-吸收内化措施38项-2026-06-20.md`(38项+grill Q1-Q6+三刀+执行进度+C6 3NIT) → `docs/research/`(5 份 eval+短时记忆 oracle + workflow 新增 14 teardown + Qwen 报告)。
- **两个待办留着**：C7 后 UI/UE 重评估 + C5 readback/model hash NIT。

# Handoff 2026-06-24 — A2 D-domain 重构合并 main + heavy-work 技能沉淀

## 本次完成
- **A2 重型重构（generic frame → D-domain 具名工具，code-only）合并 main + push**：PR #3 MERGED（`fd2220b`，2026-06-23T16:35Z）。6 步依赖序 S0-S5 全 done（口径562 manifest → gen_tool_contract D-domain 目录 → ToolContractCompiler 消费 JSON → state-cells 10族191 + C3 + 命名清债 → C5 样本生成器 surface → C6 bench expected 迁 + 跑 base 验格式）。
- **三厂商终审**（GPT Pro 5.5 Pro / hermes GLM-5.2 / GPT-5 Codex，findings 不同集=覆盖面并集）→ P0(--scope full 解码崩 fail-fast) + P1(dDomain miss fail-closed) + P1-2(direct clamp) + 6 P2（qwen-yaml引用catalog/verify-all/sanitize测/requiresStateDelta IR/CLI环境变量/SwiftPM清理）全修；DEFERRED 5 项 honest steelman。
- **post-fix subagent CC 审计 verdict CLEAR**（7修复坐实 + defer steelman 全成立 + 无新bug）。
- **heavy-work 顶层技能 V1.0** 沉淀（`~/.claude/skills/heavy-work/SKILL.md`，可发现）= 重型长跑骨架 + harness 7强制项 + 坑点库 H1-H12 + 收尾演进 + 元认知锚点 + 调研来源指针。

## 验收门最终态（main 上）
swift test 146/0 · make verify exit 0 · verify-gold 57/57 · **配方零碰**（rank16Mainline 全程未碰）· **A2 边界 code-only**（训练/评测/语料生成全 DEFERRED 守住）· §6 红线清 · swift build green on main。

## 关键发现 / 沉淀
- lessons-learned **H1-H12**（A2 长跑 12 坑：局部豁免扩大/审计线后台/选择题找舒适圈/446假删/arg异构/混合体regen/write-test-fix/亲核覆盖综合官/cross-vendor并集/审计辩证check/gitignore !dir 坑）。
- 口径全程用**终拍 562**（10族=191 device/562 intent/2159行），废口径 534/2086/52.3% 系列未引（grill-master §0 权威）。
- 三审计报告一手归档 `docs/research/2026-06-23-a2-execution/audits/`{gptpro-5.5pro,glm-5.2,codex-gpt5}.md + S0-S5 INDEX + S_CLOSE-audit-absorption.md。

## 未完成 / 下次（A2 后，已锁 DEFERRED 不排期，独立立项）
- **retrain-c5**：① D-domain 四类自然中文语料（云 generator + 异源 judge）② LoRA 实际重训（守 rank16Mainline + LR1e-4）③ C6 四层评测（candidate vs base 10/23 不退化）。🔴 **3 个 home-llm 对比 gap 待显式拍**（错误恢复类砍/纳入 · 四类配比 factors · 云生成 vs 模板法双腿）—— 见 `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md`（Hermes+Codex 双源审计，retrain-c5 propose 时读）。
- rebuild-c6 四层门 / demo-golden-run / voice(ASR/TTS) / 受限解码 vendor（mlx-swift-structured C++）。
- UIUE 路线（`docs/uiue-roadmap-2026-06-23-draft.md`）。

## 当前状态
- 分支 = main（A2 已合并，origin/main 同步）；feature 分支 `a2/migrate-d-domain-tool-surface` 保留（未删）。
- 测试 = swift test 146/0 · make verify exit 0。
- 服务 = N/A（端侧 demo，无后端）。

## 相关文件（≤5）
1. `docs/research/2026-06-23-a2-execution/` — S0-S5 INDEX + audits + S_CLOSE 吸收档（A2 全档）
2. `~/.claude/skills/heavy-work/SKILL.md` — 重型长跑技能 V1.0
3. `docs/lessons-learned.md` H1-H12 — A2 长跑坑点
4. `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md` — 后路线图双源审计（retrain-c5 用）
5. `docs/grill-tournament/grill-decisions-master.md` §0 — 口径权威 562

## 建议下次第一步
A2 已合并 main，项目代码基线对齐 D-domain 范式。下次若推进 retrain-c5：先 brainstorm/grill 拍 3 个 home-llm 对比 gap（错误恢复类/配比/双腿），再 OpenSpec propose（agree-before-build）。retrain-c5/rebuild-c6/golden-run 已有 DRAFT skeleton（`openspec/changes/`），propose 对齐后 apply。

# PR #3 深度代码审计报告 — GPT-5 Codex（第三审，实跑 swift test + make verify）

> 2026-06-23 Asia/Shanghai · 模型 GPT-5 Codex · head 80dba83（修复前 head）· base c4a7d1a。
> 🔴 唯一一份**实际 fetch PR + 临时 worktree `/tmp/maformac-pr3.L8SKRV` 真跑** swift test + make verify 的审计（非纯读）。
> 整体风险 MEDIUM · verdict REQUEST_CHANGES。

## 实跑验证命令（Codex 亲跑）
- `swift test` → 145 tests, 3 skipped, 0 failures
- `make verify` → surface_consistency pass / verify_gold total_cases=57 violation_count=0 / git diff --exit-code pass

## 8 维度
| 维度 | 分 | Verdict |
|---|---|---|
| 1 架构合规 | 3/5 | NEEDS_FIX（full catalog skeleton vs DDomain decoder 不兼容）|
| 2 代码质量 | 4/5 | PASS_WITH_NOTES（dDomain miss fail-loud 实为 stderr+frame fallback 非 fail-closed）|
| 3 测试覆盖 | 4/5 | PASS_WITH_GAP（缺 --scope full decode 测 + sanitized intent 回归）|
| 4 安全 | 4/5 | PASS |
| 5 性能 | 4/5 | PASS_WITH_NOTES（catalogByName/propertyEnums 可缓存）|
| 6 依赖兼容 | 3/5 | NEEDS_FIX（full catalog 格式 + SwiftPM Reports exclude warning）|
| 7 可读可维护 | 3/5 | NEEDS_DISCUSSION（qwen-tool-call-format.yaml 仍 TODO 与实际读 generated catalog 不一致）|
| 8 CI/lint | 2/5 | NEEDS_FIX（无 .github/workflows + make verify 不含 swift test + SwiftPM warning）|

## findings（无 P0）
- **P1-1**：`--scope full --surface dDomain` 暴露但不可用（full.json 1538/1538 缺 function，按 DDomainToolEntry decode 必 keyNotFound）。probe: full_missing_function=1538 / demo_missing_function=0。
- **P1-2**：`contracts/qwen-tool-call-format.yaml` 仍 `tools: [TBD-A2...]` + 注释「scripts 仍硬编码旧 6」（已 stale，S1 已改 codegen），与 C5/C6 实际读 generated demo catalog 不一致 → 契约 SSOT 漂移点。spec rebuild-c6 要求本文件 SHALL 定义 D-domain 工具名集合 + 字段映射。
- **P1-3（≈P2 CI）**：dDomain miss → stderr+frame fallback 非 fail-closed（与 GPT Pro/GLM 共识）。
- **P2-1**：GitHub PR 无 status checks + make verify 不含 swift test（只人工双跑）。
- **P2-2**：SwiftPM `Invalid Exclude .../Reports: File not found` warning。
- **P2**：sanitized intent（set_Ibooster_mode → set_ibooster_mode）无回归测。
- **P2**：旧 generated/D_domain.tools.json / rendered_tools_text 继续生成，给后续 agent 双源误判风险，建议加 historical banner。

## A2 边界守住（Codex 确认）
LoRA 配方零碰（rank16/scale20/LR1e-4/cosine warmup 0.08/epochs3/batch4）；strangler 合理；irMap load-bearing（反证测）；C5/C6 值键 parity 有测试；未把 DEFERRED/base hard_fail 当 bug。

## 主线程三角分诊（cross-vendor 收敛，谨慎迎合）
- Codex P1-1（--scope full）= GPT Pro P0 = **已修**（fail-fast-first）。三厂商收敛真 bug。
- Codex P1-3（dDomain miss）= both 共识 = **已修**（fail-closed skip）。
- Codex **独有 P1-2（qwen yaml stale）** = 真 SSOT 漂移 → **已修**（引用 generated catalog + 去 stale TODO）。
- Codex 独有 P2（make verify 无 swift test / SwiftPM warning / sanitized 测）= 真 → 全修。

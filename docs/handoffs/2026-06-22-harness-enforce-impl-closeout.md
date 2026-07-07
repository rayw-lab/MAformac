# Handoff — harness enforce 层落地 closeout（2026-06-22）

> ⚠️ **HISTORICAL 快照（T5）—— 文档级联 banner（2026-07-07 B4b）**
> 本文是 `docs/grill-tournament/cascade-inventory.md §T5` 标记的历史快照，当前仅保留溯源/交接价值；supersede 指针以 `docs/grill-tournament/cascade-inventory.md` 的 T5 账本为准。
> **活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md` + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` + `docs/grill-tournament/cascade-inventory.md`。正文保留供溯源，勿据此推进。

## 完成了什么
把 **cite-verify 纪律从 rule(声称层)下沉到 hook(enforce 层)**，治磊哥 + 其他窗口「不失忆 + 不凭印象」。派单 `~/workspace/raw/05-Projects/MAformac/dispatches/2026-06-22-harness-enforce-audit-implementation-dispatch.md`，lessons `harness-enforce-impl-lessons.md`，决策源 `docs/c5-recovery-2026-06-22/grill-decisions-amend-harness-audit-enforce.md`（已加实装状态段）。

**交付（全实跑验证，22 单测全绿）**：
- 4 内核 lib `~/.claude/scripts/lib/{claim-extract,grounding-verify,external-grader,recompute}.mjs`
- 4 hook：handoff-inject(H1冷注入/UserPromptSubmit) / cite-verify-stop(H2a-resp/Stop decision:block) / cite-verify-posttool(H2a-file/PostToolUse) / read-before-edit(B5)
- CLI sign-or-block.mjs（fail-closed UNSIGNED）
- 5 语义脚本 `scripts/{action_hard_pass_recompute,axis_schema,surface_consistency,verify_gold,scorer_single}.py` + `cross_section_check.py`；接入 `make verify`
- `~/.claude/Makefile verify-hooks`；settings 备份 + kill switch `HARNESS_ENFORCE_DISABLED` + activation receipt
- H1 用户级 `~/.claude/settings.json`；H2a/B5 项目级 `.claude/settings.local.json`（gitignored，CVE）

**核心坐实**：`action_hard_pass_recompute` 复现 base **10/23**（axis 23/3/4，从 `c6-summary.json:eval_runs[].gate_result` 一手字段，noop 双计坑已 catch）；`11/30` 引含 `10/23` 的行 → block（value-in-source 非只行存在）。

**异源审计 4 轮收敛**：第2轮 catch 2×P1（no_source 误伤 + grader prose 绕过）→ 修；第3/4轮 CLEAR；+ 磊哥实战 catch JSON 字段 source 盲区 + axis 三元组 23/3/4 误抽 → 全修。3×P1 + 3×P2 全修。

## 活体证据
H2a-file hook 真拦下「凭 codex 对话数字写 §5 没核 source」逼 jq 亲核闭环；H1 在本 session 真注入 handoff 指针；hook 在多个活跃窗口真触发（`~/.claude/logs/cite-verify.jsonl` 28+ 真实命中）。

## 未完成 / 下一步
- **试用期**：H2a/B5 项目级试 ≥5 会话 + 误伤<1/3 → 再迁用户级。盯 `cite-verify.jsonl` 误伤率。
- **残留 P2（不阻断）**：grader 贪婪 JSON 抽取（correctness 边界，归异源+人）；session marker 累积（30 字节无害）。
- **git 提交留磊哥拍**：新 `scripts/*.py` + `Makefile` + `.gitignore` 在 `git status` 待 commit（项目级 hook 不入仓）。
- 元认知回流已做：`~/.claude/rules/{hooks.md,claim-vs-reality-gap.md}` + `docs/lessons-learned.md #50` + CLAUDE.md §8。

## 起手第一步（下个 session）
读本 handoff + `docs/lessons-learned.md #50`（enforce 层精华）。C5 recovery 主线仍以 `docs/c5-recovery-2026-06-22/grill-decisions.md` + `grill-decisions-amend-execution-gap-reconciliation.md` 为准（θ-α FAIL，θ-β/监督/配方待 grill 拍）。

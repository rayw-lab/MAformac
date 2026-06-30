---
artifact: implementation_spec
scope: CC harness 机制升级（全脑暴覆盖，不只 hook）
authority: implementation_spec_ssot   # 实施态 SSOT；决策史(为什么)见 brainstorm-decisions；hook 行为契约见 action-trigger-inject.spec.md
created: 2026-06-26
decision_source: brainstorm-decisions.md (Q1-Q10 + A1-A4) + README.md (机制分层落位表 + 业界对标 + 亲核)
killswitch: HARNESS_ENFORCE_DISABLED=1
note: 各项态 2026-06-26 实际 grep/find/ls 核过(非声称)，见每行验收列
---

# CC Harness 机制升级 — 实施 spec（全脑暴覆盖）

> 脑暴产出 = **6 大类 14 项**（机制分层落位表 + Q1-Q10 + A1-A4），hook 只是档2的 1 项。本 spec = 全部项的实施态 SSOT + phase matrix（derivation-layer §铁律4：deferred 不靠注释散落，单一处可查）。

## §1 战略主线（Q1=A）

核心铁律「秉持机制」从 **rules 在场靠自觉 → per-turn/per-action hook 机械重注**（治 attention 稀释根因：44 rules/2172 行 over-sedimented，「认知到≠行为改」反复犯）。元扳机注「动作点四问」不复述 rule 全文。三路 teardown 一致：执行纪律层已够核，真空白 = ① grill 骨架/落档模板 ② 框架编排层 doc ③ 业界没用透的 CC 机制（hook per-turn 注入 / correctness enforce）。

## §2 🔴 实施项矩阵（phase matrix，态全核过 2026-06-26）

图例：✅done / 🟡piloting / ⏳deferred / 💤休眠(设计决策非待办) / 🔴未落地(声称done实际缺) / 📋待评估拍板

| # | 项 | 🔴落地位置 | 决策源 | 态 | 验证证据（/executing-plans 2026-06-26 实跑）|
|---|---|---|---|---|---|
| S | 铁律→per-turn hook | — | Q1=A | 定 | — |
| 1 | grill-baseline rule | 顶层 `~/.claude/rules/` | A-3 | ✅ verified | grep 骨架预留/前置环 = 命中 4 |
| 2 | anchor 超过非复刻 absorb | 顶层 aesthetic rule | C-B1 | ✅ verified | grep 视觉质量下限 = 命中 3 |
| 3 | mock 桩态 absorb | 顶层 completion rule | C-B3 | ✅ verified | grep mock 桩态 = 命中 3 |
| 4 | grill 落档 5 段模板 | — | A-2 | 🔪 **dropped** | 磊哥拍③：grill-with-docs skill 已有落档指引，独立模板冗余(demo 轻治理避 over-sediment) |
| 5 | 长跑滚动审计 absorb | 顶层 heavy-work skill | C-B2 | ✅ verified | grep 滚动审计 = 命中 2 |
| 6 | 元扳机 hook | 顶层 `scripts/hooks/` | Q1-5+A1-4 | ✅ 全局生效(2026-06-27) | 迁用户级 settings.json(UPS+PreToolUse) + 沙盒8绿 + 热生效实测(C4注入) + C3每8turn实测 + 已摘token-threshold |
| 7 | PostCompact A3 | 顶层 `session-start-compact.mjs` | Q6=B | ✅ **done+verified** | 实装 + 实跑输出四问✅ + grep 命中 1 |
| 8 | 异源 grader 休眠 | 顶层(设计决策) | Q7=A | ✅ verified(故意休眠) | settings 引用=0 + README 休眠标注=命中 4 |
| 9 | hooks.md 16 事件 | 顶层 `rules/hooks.md` | 维护 | ✅ verified | grep 16 事件/PostCompact = 命中 2 |
| 10 | collaboration §7 框架链+Pocock 诚实标注 | uiue patch→main apply | Q9=B+A | 🅿️ pending-apply | `main-constitution-pending-apply.md` 内容备好(拍A)；main 切回后 apply |
| 11 | CLAUDE §2 propose vs apply gate | 同上 | Q9=B+A | 🅿️ pending-apply | 同上 patch T11 |
| 12 | collaboration §4.5 七段 drop | 同上 | Q9=B+A | 🅿️ pending-apply | 同上 patch T12 |
| 13 | memory 路由 hook | — | Q6→drop | 🔪 dropped | 磊哥 2026-06-26 拍 drop(轻治理 + 否决过 claude-mem 类) |
| 14 | schliff lint | — | Q6→drop | 🔪 dropped | 磊哥 2026-06-26 拍 drop(rules 已 over-sediment，再加工具 ROI 低) |

> 进度（/executing-plans 2026-06-26 收口）：**14 项处置完毕** = verified 8(T1/2/3/5/6/8/9 顶层+8 grader) + **T7 done+verified** + **T4/T13/T14 dropped** + **T10-12 pending-apply**(cross-worktree 唯一未 landed，patch 内容备好等 main session)。档1 从「声称 5/5」坐实为「4/5 + 项4 drop」。

## §3 需契约的项（详；done 项不重复，hook 指向子 spec）

### 项6 — 元扳机 hook（核心，piloting）
- **行为契约 + 验收门 + 回滚 = `~/.claude/scripts/hooks/action-trigger-inject.spec.md`**（C1-C5 + 实施信号收窄 + 5 道验收门）。不在此重复，防双份分叉。
- 当前态：✅ **已迁用户级全局生效**（2026-06-27，磊哥拍板跳过 ≥5 session 试点门直接全局）/ UserPromptSubmit + PreToolUse 双挂 / 热生效实测(C4 注入) + C3 每8turn实测 / 子 spec 已建。
- 迁移一并做：✅ 项7(PostCompact四问)早 done(实测输出) / ✅ 已摘 token-threshold-hook(UPS, bak-rmtoken-20260627) / ✅ 备份 settings.json.bak-20260627-163116 + 写后断言(secret/permissions完好)。

### 项4 — grill 落档 5 段模板（🔪 dropped，磊哥 2026-06-26 拍③）
brainstorm 计划 absorb `DECISION-ENTRY-TEMPLATE.md`，实际 find 零命中（声称 done 实际缺）。**磊哥拍 ③ drop**：grill-with-docs skill 本身已有「re-read source / explore-instead-of-ask / 决策落档」指引，独立 5 段模板冗余（demo 轻治理避 over-sediment）。**不补做**。

### 项7 — PostCompact 校验（✅ done+verified，2026-06-26）
`session-start-compact.mjs`(SessionStart matcher=compact) 末尾已加 `POST_COMPACT_RELOAD` 注四问铁律。**不新增 PostCompact 事件**（A3=B 去重，唯一权威源）。验证：syntax OK + 实跑(无 continuation 时)输出四问✅ + grep 命中。**提前做了**（不等迁用户级——纯增量注入、低风险、不动 settings.json schema）。

### 项8 — 异源 grader 休眠（Q7=A 设计声明，非待办）
`external-grader.mjs`/`recompute.mjs`/`grader-prompt.template.md` 存在但 settings **零引用 = 故意休眠**（设计验证用）。correctness enforce 靠：人 + 元扳机①核源 + cite-verify mechanical + 主线程亲核 + 手动 cross-vendor。🔴 README 必标「休眠内核，别假装 active enforce」（已标）。**不 wire = Q7 决策，非缺口**。

### 项10-12 — 项目宪法 3 条（deferred 等 main）
内容备好在 `brainstorm-decisions.md`「🔴 main 主线待回写」段。cross-worktree 红线：**在 uiue 改会让 main drift，必在 main session apply**。

### 项13-14 — 业界机制（🔪 dropped，磊哥 2026-06-26 拍）
memory 路由 hook / schliff lint（Q6 提及）→ **drop**：demo 轻治理 + 磊哥否决过 claude-mem 类存储工具；schliff 对已 over-sedimented 的 rules 是再加工具，ROI 低。需要时再 revisit。

## §4 总验收（整个升级何时算 done）
- **档1**：✅ 收口（4 verified + 项4 drop；「声称 5/5」坐实为 4/5+drop）。
- **档2**：hook 🟡 piloting + PostCompact A3 ✅ done + grader 休眠 ✅。
- **档3**：🅿️ pending-apply（patch 备好，main session 切回 main 后 apply 3 条）。
- **Q6**：✅ memory/schliff drop。
- 🔴 **整体剩 1 个未 landed**：① ✅ hook 已迁用户级全局生效(2026-06-27，磊哥拍板跳过≥5会话试点门) ② 项目宪法 3 条（main session apply patch，仍 pending）。其余 13 项收口。

## §5 回滚
- hook：`export HARNESS_ENFORCE_DISABLED=1` / settings `.bak` 恢复。
- rules absorb：~/.claude 若 git 版控可 revert（项1-5）。
- 项目 doc（项10-12）：尚未动（deferred），无需回滚。

## §6 决策溯源
`brainstorm-decisions.md`（Q1-Q10 + A1-A4 拍板史）/ `README.md`（机制分层落位 + 业界对标 13 repo + 亲核记录）/ `action-trigger-inject.spec.md`（hook 行为契约子 spec）。

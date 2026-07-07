# Handoff — 2026-06-22 C5 θ-α 落地 + Harness+审计 全案 grill 收口

> ⚠️ **HISTORICAL 快照（T5）—— 文档级联 banner（2026-07-07 B4b）**
> 本文是 `docs/grill-tournament/cascade-inventory.md §T5` 标记的历史快照，当前仅保留溯源/交接价值；supersede 指针以 `docs/grill-tournament/cascade-inventory.md` 的 T5 账本为准。
> **活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md` + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` + `docs/grill-tournament/cascade-inventory.md`。正文保留供溯源，勿据此推进。

> **session 跨度**: C5 θ-α scope 决策 → codex 执行派单 → Ultracode 7-lens 调研 → 审计框架+harness enforce 23 题 grill → 两份 dispatch 审计 → 收口
> **模型**: GLM-5.2 (custom provider), Hermes 桌面
> **磊哥称呼**: 磊哥;中文

---

## 0. TL;DR — 30 秒读完

**C5 recovery**: θ-α scope(纯语义 positive 第一刀)已拍 + recipe=rank16Mainline 代码最终态 cite-verify+θ-α 三件套(PR1 name-first ∥ PR2 compiler-scaffold → PR3 θ-α-data)已派 codex 实装。Reports 目录已有第一轮 θ-α 跑出分。
**Harness+审计**: Ultracode 7-lens 调研完+审计框架 5 批 23 题全拍入 amend 文档。两份 dispatch 已写(一份已发 codex,一份审计发现5 处事实错仍需修)。
**未 commit**: 大量 untracked——docs/c5-recovery/、handoffs、research、Reports(theta-α 跑分)。HEAD `c4a7d1a`。

---

## 1. 本 session 闭环清单

| 事项 | 状态 | 产出 |
|---|---|---|
| C5 η-scope-split(θ-α/θ-β 两刀分层) | ✅ 磊哥拍 | `grill-decisions.md:345` |
| θtrain-recipe-baseline(rank16Mainline cite-verify 4 处纠错) | ✅ 落库 | `grill-decisions.md:359` |
| θ-α 执行三件套派单(codex 实装) | ✅ 已发 codex | `~/workspace/raw/05-Projects/MAformac/dispatches/2026-06-22-c5-theta-alpha-execution-dispatch.md` |
| dispatch-prompt-to-codex(600-1000字反喂提示词) | ✅ 已写 | `docs/c5-recovery-2026-06-22/dispatch-prompt-to-codex.md` |
| Ultracode 7-lens 调研(CC 失忆/浅思/不深入) | ✅ 全读完 | `docs/research/2026-06-22-claudecode-amnesia-shallow-harness/` (7 lens + README + cheatlist) |
| 审计框架 5 题 grill(A1-A5) | ✅ 全⭐+机械加强 | `docs/c5-recovery-2026-06-22/grill-decisions-amend-harness-audit-enforce.md §A` |
| Hook 落地核心 5 题 grill(B1-B5+3EN) | ✅ 全⭐+机械加强 | 同上 §B |
| 文档级联 probe 5 题 grill(C1-C5+2EN) | ✅ 全⭐+机械加强 | 同上 §C |
| 策略周边 4 题 grill(D1-D4+EN5) | ✅ 全⭐+机械加强 | 同上 §D |
| 深层合并 3 题 grill(N1/N5/N2) | ✅ 全⭐+EN6 | 同上 §E(待写入) |
| Harness+审计 dispatch 审计 | ✅ 5 处事实错+3 Gap | dispatch 文件 **待修** |
| C6 θ-α 第一轮跑分 | ✅ Reports 目录已有 | `Reports/c5-theta-alpha-20260622T162757/` |
| MAX 校准 | 🔴 磊哥手动，未拍 | 仅无效率 |

---

## 2. 决策晶体(新窗口必读)

### 2.1 C5 θ-α(grill-decisions.md 最权威)

- **η-scope-split**: θ-α(纯语义 positive 第一刀:ASR 假设对,只训文本→ToolCall 的 L2-L5 语义泛化;无 safety/ASR/out-of-toolset/NO_TOOL);θ-β(安全门第二刀:θd-2/3/4/5/6)
- **θtrain-recipe-baseline**: `rank16Mainline() [:1164-1188]` 已是代码最终态(lr1e-4/scale20/warmup 48/clip1.0/adamw/epochs3/repo_loop),**别再调参**
- **ζ 相对门**: `lora.mp_positive_action.hard_pass_without_readback > base 10/23` + wrapper_drift=0 + IrrelAcc≥base0.789
- **θ-α 三件套**: PR1 name-first(C5CanonicalJSONObject.render 拆用途) ∥ PR2 compiler-scaffold(C6VehicleToolBench:1163 applier 派生) → PR3 pure positive data(skip buildNoCallSamples)
- **dispatch**: 已发 codex 自己跑,起手指南在 `dispatch-prompt-to-codex.md`

### 2.2 审计+Harness(grill-decisions-amend-harness-audit-enforce.md 权威)

**审计框架**(A1-A5): 全⭐+机械深化

| 议题 | 决策 |
|---|---|
| 审计议题2(judgment enforce) | B:claim 带{value,source,claim_type},claim_type **路径决定脚本自打** |
| G27 语义维度+实跑复算 | 都加,**复算分级**(candidate 必/PR 抽1/handoff 不要求) |
| G27b spike-e3 不验 args | hard_pass 验+**标 deprecated_smoke+linter 拦 release 引** |
| G28 异源终审 | candidate 必异厂商,**异源分级** |
| G29 frame 纪律 | grill-with-docs **固定5问句模板** |

**Hook 落地核心**(B1-B5): 全⭐+机械深化+3EN

| 议题 | 决策 |
|---|---|
| G1 第10坑 hook 化 | C:Stop-文本-扫描+B 异源 grader 二层 |
| G2 cite-verify 语义判断 | B:异厂商(GLM/hermes),Task 同Claude |
| G4 冷开 handoff 注入=B3=H1 | B:复活 UserPromptSubmit,首轮注入静态指针 |
| G5 Stop 漏写 handoff | B:conditional block(三守护) |
| G9 read-before-edit | B:PreToolUse 软提示(exit0+JSON) |

**文档级联**(C1-C5): 全⭐+机械深化+EN3/EN4
**策略周边**(D1-D4): G6 claude-mem 禁装/G7 anti-shallow DROP/G8 禁prepend/N4 adopt grounded机制+build磊哥版

---

## 3. 待办(新 session 起手动作)

### 🔴 P0: dispatch 审计修 5 处事实错

`~/workspace/raw/05-Projects/MAformac/dispatches/2026-06-22-harness-enforce-audit-implementation-dispatch.md` 已审计出 5 处事实错+3 Gap:
1. F1: `session-start-compact.mjs` matcher="compact" 冷开不跑,需核 SessionStart 的 2 entries
2. F2: UserPromptSubmit entry 是否 token-threshold-hook 待核
3. F3: Stop 并发危险夸大(claude-mem 非 hook,实际只 session-stop 1个)
4. F4: 2.1.177 Stop schema 字段名需联网确认
5. F5: session-stop.mjs:1-12 明文记录了从 block 回退 plain stdout 的血泪,升 block 需规避
6. Gap A: 4 内核 lib 无正则/测试 fixture/错例集
7. Gap B: grader prompt 模板+GLM/hermes 通道未写
8. Gap C: H1 handoff 扫描路径应复用 session-stop.mjs:32-57 的 bounded recursive scan

→ **修完再发 CC**,建议 A 方案(先修后发)。

### 🟡 P1: spec 编写(收口步,按 G3 纪律 pin Sonnet 4.6/4.7)

待 23 题落地 spec,落点:
- `~/.claude/scripts/hooks/handoff-inject.mjs`(H1)
- `~/.claude/scripts/hooks/cite-verify-stop.mjs`(H2a)
- `~/.claude/scripts/hooks/read-before-edit.mjs`(B5)
- `~/.claude/scripts/lib/{claim-extract,grounding-verify,external-grader,recompute}.mjs`(4内核)
- `~/.claude/scripts/cli/sign-or-block.mjs`(C++ candidate signing)
- `<MAformac>/scripts/cross-section-check.py`(pG1)
- `Makefile verify-hooks target`

### 🟢 P2: 启动手顶-10分钟的快速验证

`codex dispatch` 已在跑 C5 θ-α(Reports 目录已有两波跑分,c6-summary/c6-theta-alpha-axis-receipt)。下一窗口起手:
1. 看 `dispatch-prompt-to-codex.md`
2. grep Reports/c5-theta-alpha-* 看最新跑分(lora.mp_positive_action > base 10/23 了吗)
3. 查 `completion-audit.md`(pr3质检,lama stest)状态

---

## 4. 文件索引(绝对路径)

| 文件 | 内容 |
|---|---|
| `~/workspace/MAformac/docs/c5-recovery-2026-06-22/grill-decisions.md` | C5 决策 SSOT(含 η/θtrain/α..,22段) |
| `~/workspace/MAformac/docs/c5-recovery-2026-06-22/grill-decisions-amend-harness-audit-enforce.md` | 审计框架+Harness enforce 决策(批1-4已落,批5待) |
| `~/workspace/MAformac/docs/c5-recovery-2026-06-22/dispatch-prompt-to-codex.md` | θ-α 执行派单压缩提示词(877字) |
| `~/workspace/raw/05-Projects/MAformac/dispatches/2026-06-22-c5-theta-alpha-execution-dispatch.md` | θ-α 三件套派单(已发 codex) |
| `~/workspace/raw/05-Projects/MAformac/dispatches/2026-06-22-harness-enforce-audit-implementation-dispatch.md` | Harness+审计落地派单(待修) |
| `~/workspace/MAformac/docs/handoffs/2026-06-22-c5-recovery-grill-marathon-closeout.md` | 上轮 CC 手写 handoff(9坑件套) |
| `~/workspace/MAformac/docs/handoffs/2026-06-22-c5-recovery-hermes-handoff-six-piece.md` | 上轮 Hermes 元认知 handoff |
| `~/workspace/MAformac/docs/research/2026-06-22-claudecode-amnesia-shallow-harness/` | 7-lens 调研全档(README+7 lens+todo) |
| `~/workspace/MAformac/Reports/c5-theta-alpha-20260622T162757/` | θ-α 第一轮跑分 |

---

## 5. 警觉信号(见即停)

- 见 dispatch 未修 5 处事实错就发 → 先修(见§3 P0)
- 见"新窗口起手没读 handoff → H1 未落" → 手动读 handoff 再开干
- 见 G3 收口步 pin 了什么 → 确认不是 opus-4-8 max(#64991/#63604 实测 malformed)
- 见 claude-mem 被提议扩大用 → 磊哥已否决(空间浪费,handoff 六件套是主力)
- 见"最简单解答可能是对的"念头 → 是搜证信号,不是放行信号(claim-vs-reality 铁律2)

---

**END OF HANDOFF**

新 session 起点:修 harness dispatch 5 处事实错 → 拉 dispatch-prompt-to-codex.md 看 θ-α 跑分 → spec 编写。
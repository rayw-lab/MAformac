# Handoff 2026-06-19 — C1/C2 契约 SSOT propose+审+整改闭环 → apply 阶段 A 派 codex

> ⚠️ **HISTORICAL 快照（T5）—— 文档级联 banner（2026-07-07 B4b）**
> 本文是 `docs/grill-tournament/cascade-inventory.md §T5` 标记的历史快照，当前仅保留溯源/交接价值；supersede 指针以 `docs/grill-tournament/cascade-inventory.md` 的 T5 账本为准。
> **活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md` + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` + `docs/grill-tournament/cascade-inventory.md`。正文保留供溯源，勿据此推进。

## 一句话状态
全量重构落地:`define-c1c2-contract`(C1+C2)**propose done + GPT Pro 审 + F1-F5 整改全闭环**(PR#2)。apply **阶段 A(C1 codegen)已派 codex 后台跑**;**阶段 B(挖数据定 L1/C2,精度活)待 fresh session**。

## ⚠️ 起手必读(分支状态,别被 main 旧版误导)
- **v2 全在 `feat/define-c1c2-contract`(PR#2,未 merge);main 是 PR#2 之前的旧版**(CLAUDE/config/docs 旧)。**起手先 `git checkout feat/define-c1c2-contract`** 再读 CLAUDE/docs。
- codex C1 codegen 在 worktree `/Users/wanglei/workspace/MAformac-c1-codegen`(feat 分支)后台跑 → **起手先核进度**:`git -C 该worktree log/status` + 看 `contracts/semantic-function-contract.jsonl` 是否生成 + `make verify` 是否绿。

## 本 session 完成
1. 消化上个 session 全文(7.3M)+ 复盘沉淀 → 元认知升级 **§28 一手源核验 / §29 挖数据 vs 反射问人**;memory(read-first / baseline-internalization / leige / 6change v2)。
2. **Q1–Q15 CC↔codex 脑暴 + 2 轮 oracle 验证**(对抗:dropped_rows=0 洗白脏行 / 活文件作权威 / JSONL 无 FK / 双向 archive 循环)。
3. park 旧 7-change(`openspec/changes/_parked/`)+ 立 `define-c1c2-contract`(C1 semantic-function-contract + C2 scenario-state-protocol,4/4 valid)。
4. 基建文档级联 v2(CLAUDE/config/README/lessons/integration/collaboration/memory)。
5. commit + PR#2 + GPT Pro 审(REQUEST_CHANGES)+ **F1-F5 整改**(F2 车型 token 磊哥豁免 → §6 红线改**分级脱敏**)。
6. apply 阶段 A:派 codex C1 codegen(dispatch `~/workspace/raw/05-Projects/MAformac/dispatches/2026-06-19-C1-codegen.md`)。

## 当前状态(git)
- 主树 main(564609d,旧版,干净)/ **feat/define-c1c2-contract: a646d57(v2+整改,PR#2 head)**。
- worktree:**c1-codegen**(feat,codex 跑 C1 codegen)/ change3-fix / lora-build / p0(旧)。
- PR#2 OPEN(github.com/rayw-lab/MAformac/pull/2);PR#1 CLOSED。

## 下一步(fresh session 阶段 B,CC 精度活;§29 从数据挖不空手问)
1. 核 codex C1 codegen 产物(JSONL≈3990 / 分流账本 unclassified=0 / make verify 全绿 / 脱敏)。
2. **从 3990 协议 col20/30·31 + 12000 bug 真实数据(`~/workspace/bug-skill-dev` + `~/.bug-skill`)挖 L1 能力维度炸点候选**(模糊/快FC/多意图/记忆 = 炸点,**非设备清单** — 磊哥校准)→ 磊哥 reviewed。
3. 设计 C2 state-cells(L1_device ∪ scenario ∪ safety)+ execution_range + risk-policy + demo-scenarios。
4. 纵切空调温度+车窗验全栈 → 续 `/opsx:apply` → archive。

## 起手读(checkout feat 后)
CLAUDE §9 → 本 handoff → `docs/c1-q1-q10-claude-oracle-grill-2026-06-19.md` + `docs/adr/0001-*` + `CONTEXT.md`(C1/C2 全料)。

# Handoff 2026-06-19 — 基座内化 + 全量重构推翻重来(决策已拍,待 openspec-propose)

> ⚠️ **HISTORICAL 快照（T5）—— 文档级联 banner（2026-07-07 B4b）**
> 本文是 `docs/grill-tournament/cascade-inventory.md §T5` 标记的历史快照，当前仅保留溯源/交接价值；supersede 指针以 `docs/grill-tournament/cascade-inventory.md` 的 T5 账本为准。
> **活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md` + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` + `docs/grill-tournament/cascade-inventory.md`。正文保留供溯源，勿据此推进。

## 一句话状态
深度内化 4 金钥匙基座 → 磊哥拍**全量重构 A**(推翻旧 7-change);新 N-change 路线已提议**待磊哥最终拍** → 拍后加载 `openspec-propose` 立 **C1 契约 SSOT**。本 session 收尾 clear。

## 本 session 完成
1. **基座深度消化**:4 金钥匙表(`~/Downloads/` 公版语义四级协议-编辑版/车控打点表/上下文二次交互/多语种V1)+ 3 类基座(数据/路由/端态);raw 一手手册(意图收缩FC路由/端状态上传协议)。
2. **业内调研**(2 oracle):意图收缩五层 L1-L5 + clarifyTag + SSOT codegen + device×原语×槽三元分解 + 模板DSL合成 + 三层路由 + LoRA adopt(Hammer/xLAM/unsloth)。
3. **方案/roadmap/整改清单**:`docs/baseline-internalization-plan-2026-06-19.md`(9 节)。
4. **change3 整改 done**(44/44 绿)但 **PR#1 已 CLOSED**(全量重构覆盖,position P0 在新契约解决)。
5. **决策拍板**:全量重构 A / **LoRA 全量**(不裁剪)/ PR#1 关 / 路线重排 / **先契约后代码** / 用 superpowers+openspec-propose 推翻重来。

## 未完成(下次第一步)
- **新 N-change 路线待磊哥最终拍**:C1 契约SSOT全集 / C2 端态协议 / C3 执行契约层 / C4 三层路由+意图收缩 / C5 LoRA全量 / C6 vehicle-tool-bench / C7 voice。依赖序 C1→C7,先 C1+C2(CC 设计)再实现。
- 拍后:**加载 `openspec-propose` 立 C1 契约 SSOT 根 change**(function-spec-full 全集 + value 四件套 + 三元分解 + codegen + drift gate)。
- 再回写 **CLAUDE.md**(§2 路线/§4 架构/§5 决策 D16/D30/D35/D37 + **范围纠错 16-30→18-32、0-5→1-10**)+ `openspec/config`。

## 关键发现(详见 memory [[maformac-baseline-internalization]] / [[maformac-baseline-read-first-lesson]])
- value 四件套(ref/direct/offset/type)+ 归一化编码(114→12 原语)+ 二次交互矩阵 + clarifyTag 三层 + 不丢脸 L1-L4。
- 范围真值:空调温度 **18-32**/风量 **1-10**(端态打点,我之前拍 16-30/0-5 错)。
- adopt:Hammer/xLAM/unsloth/vLLM-router/MAC-SLU/outlines-xgrammar。利好:**qwen3:1.7b 负触发实测稳过**。
- 2 HIGH 坑:假泛化(SGD-X 靠 intent 名记忆→function masking)+ 假 SSOT(生成物手改→drift gate)。
- 教训:反复马虎(4 次没读一手基座,凭二手 capabilities.yaml 拍脑袋);急躁直奔产出(磊哥多次"先讨论别执行");agree-before-build(codex P0 跑早被停)。

## 当前状态(git)
- main:本 session 产出已 commit。worktree:change3-fix(46340f1)/lora-build(97f3f92)/p0(feat/p0-function-spec,仅 v0 模板)。
- PR#1 CLOSED。基座 digest 工件:`~/workspace/raw/00-Inbox/maformac-baseline-digest/`(parse_devices.py 可重建)。

## 起手读
CLAUDE.md → 本 handoff → `docs/baseline-internalization-plan-2026-06-19.md` → memory(2 条)。

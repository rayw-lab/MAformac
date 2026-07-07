# Handoff 2026-06-21 — P1-C grill 收口 + C5 apply 派单(双审修订)+ 元认知大沉淀

> ⚠️ **HISTORICAL 快照（T5）—— 文档级联 banner（2026-07-07 B4b）**
> 本文是 `docs/grill-tournament/cascade-inventory.md §T5` 标记的历史快照，当前仅保留溯源/交接价值；supersede 指针以 `docs/grill-tournament/cascade-inventory.md` 的 T5 账本为准。
> **活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md` + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` + `docs/grill-tournament/cascade-inventory.md`。正文保留供溯源，勿据此推进。

> append-only(collaboration §4.5,永不回改)。本 session 信息量大,破常规 40 行限。

## Goal & Context

起手「熟悉项目现状」→ 发现 **git 已超出 memory/roadmap 记录**:P1-C grill 已收口(Q1-Q10)+ C5 `define-lora-training` change 已 accept(commit `1231bdd`),memory/roadmap 还停在「P1-C blocked 需 grill」。本 session 主线 = **对 codex 列的 C5 apply 步骤 2-5 做 grill-with-docs(Q11-Q18)→ probe generator 选型 → 写 C5 apply 派单 → hermes 异源 + subagent CC 双审 → 修订**。全程磊哥强调:严谨不降级 / 别亲信(CC↔codex 协同 grill,不一味迎合)/ 修好 hermes 流程。

## Progress

### ✅ Done
1. **P1-C apply grill Q11-Q18 全收口**(`docs/p1c-training-grill-decisions.md` 续写「Apply 阶段 grill」节,每题物理落档 + pre-mortem 三分类 + 证据 URL/file:line + frame-check):
   - Q11 数据规模(4-5k,只 3990 种子,fc_l3 仅 ~95 瓶颈)/ Q12 masking(stock --mask-prompt final-completion span)/ Q13 generator(多源)/ Q14 dual_layer validator(异源 per-sample)/ Q15 lineage(candidate 重判修 :255-258 假安全)/ Q16 smoke(定性门)/ Q17 train(dev_selection 选 checkpoint + C6 final-only)/ Q18 签发(三方 parity + P1-C 拆两 V-PASS)。
2. **probe(generator 三权分立)** `docs/research/2026-06-21-c5-generator-selection-probe.md`:推翻我「本机 35B 当 generator」蠢主意(frame-lock:把 runtime 离线约束误施于 dev-time)→ 多源云 generator + label 契约定 + 异源 judge + 评测 gold 规则锚不 LLM 自定。证据:self-preference/preference-leakage/capacity-gap/model-collapse(全联网核)。
3. **C5 apply 派单(reframe 赋能 codex 自主)** `~/workspace/raw/05-Projects/MAformac/dispatches/2026-06-21-c5-lora-training-apply-dispatch.md`(dispatch 不入仓,§15)。经 **hermes GLM-5.2 异源 + claude subagent 双审**修订,2 BLOCKER + P1 全并入。磊哥引导语已给(贴 codex 自主完成)。
4. **元认知大沉淀**(本 session frame 错 4 次,层级逐级上升):
   - memory `baseline-read-first-lesson`:第三腿(检索≠应用)+ 第四腿(沉淀分两层/凭记忆引错沉淀/错误层级上升)。
   - memory `lora-train-eval-stack`:checkpoint selection 纪律(dev 选不用 C6 release)+ 记忆纠错(我误引 HIGH2)。
   - skill `grill-with-docs`:加「工程契约 grill 模式」+ 验证型 vs 发现型 check + 回读原文别凭记忆。
   - 顶层 `codex-metacognition §31`:frame-check + 沉淀调用双层 + 验证/发现型 + cross-vendor≠cross-frame + 递归终点是人。
5. **hermes 调用流程修复**:`.claude` wrapper `--prompt-file` 走 run_oneshot 坏路径(stdout 空/后台 exit 1)→ 用 `--prompt "$(cat file)"` 走 hermes-z(后台 exit 0/543s 验通)。**零改动 codex 共用文件**(.codex wrapper / config / hermes-bin mtime 全凌晨未动)。

### ⚠️ In Progress / Next
- C5 apply 实装(派单就绪,**等磊哥复制引导语派 codex 自主跑**)。

### 🚫 Blocked / 待磊哥
- **iPhone 8GB 真机**:`devicectl list devices`=No devices found(某时刻快照);磊哥说真机在旁可用,但端侧 candidate V-PASS 必真机(simulator 不替,P1-B)。→ P1-C 拆两 V-PASS:模型质量 V-PASS(C6 Mac 可达)+ 端侧 V-PASS(真机)。
- **CC 的 docs 改动未 commit**(`docs/p1c-training-grill-decisions.md` + `docs/research/probe` + 本 handoff)→ ⚠️ **建议派 codex 前先 commit CC 的 docs**(否则 codex `git add -A` 卷入,single-worktree 并发坑,见 memory `single-worktree-concurrency`)。

## Key Decisions

### Q11-Q18 物理决策(权威 = grill 档,这里只索引)
- 数据:4-5k 多源云 generator(**hermes glm 主力**,更新 grill Q13 原 claude 主力)+ label C1 契约 deterministic + 红线喂 prompt 只语义协议不喂原文。
- masking:stock `ChatDataset + --mask-prompt`(单轮 final-completion span)。
- validator:dual_layer(layer1 规则 stop_on_rule_fail + layer2 per-sample judge≠generator 跨厂商)。
- lineage:candidate_parent_semantic_id 重判(C1 canonical_semantic_id 粒度)+ post-aug 重跑 data-gate。
- train:dev_selection(**新第六类 split,需 openspec change**)选 checkpoint + C6 final-only。
- 签发:三方 parity(adapter_bf16/fused_bf16/fused_quantized_4bit)+ P1-C 拆两 V-PASS。

### 🔴 双审挖出 2 BLOCKER(派单已修为「显式非自主」)
- **B1 enable_thinking offset 过冲**(两审共指,我 Q12「挑食读源码」盲点):stock ChatDataset full tokens(`datasets.py:60-64` 不传 add_generation_prompt)不含 think 块,offset(`:65-75` 传 add_generation_prompt=True)传 enable_thinking=False 注 `\n\n` → offset 过冲 → `trainer.py:82` loss mask 吞 assistant 开头 → 静默训练错误(render_diff 不报)。修复 a:训练 assistant content 加 `\n\n` 前缀对齐 full/offset + offset 正确性 fixture。
- **B2 dev_selection 撞 spec**:撞 live `define-lora-data-gate spec.md:4`「exactly 5 buckets」+ `C5DataGate.swift:243` whitelist → 必 openspec change 加第六 bucket + 改 swift:243/:255 + validate 过。

### 元认知(本 session 最大收获)
- **frame 错 4 次层级上升**:Q13 决策 frame(本机 generator)→ 问B 我质疑别人时自己的判断 frame(纯 demo 目标)→ Q15 凭概念不读实装 → Q17 凭记忆引错自己沉淀。规律:**信息充分后主错误源从「信息不足」转「frame 错误 + 记忆/调用错误」**,修正工具(物理化/搜证/互审/沉淀)都在 frame 内强化它,**破框终点 = 人(磊哥)+ 一手原文**。
- **实读破挑食 > cross-vendor**:B1 被 subagent CC(同厂商)+ hermes(异源)**都靠实读一手源** catch(我挑食漏的)。→ 审计价值不只在异厂商,更在「实读一手 vs 凭概念/挑食」。
- **不一味迎合 = 发现型 check**:check 分验证型(对不对)+ 发现型(漏什么);只验证就同意=迎合。本 session Q14/Q16 我偏迎合(已补挖)。

## Critical Context
- **git**:HEAD `1231bdd`(C5 accept);CC 本 session docs 改动未 commit(grill 档/probe/handoff)。openspec:`define-lora-training` 0/32 / `define-lora-data-gate` ✓Complete / `_parked` superseded。
- **派单引导语**(磊哥贴 codex):含 dispatch 绝对路径 + 自主完成 + 不降级 + B1/B2 预警 + 红线 + 审计闸命令(`--prompt "$(cat)"`)。
- **每 step 审计闸**:hermes glm52 异源审(step2 拆 2a/2b/2c 子闸);命令用 `--prompt "$(cat)"`(codex 用 .codex wrapper 则 --prompt-file 也 OK)。
- **hermes 修复**:`.claude` wrapper --prompt-file 坏 → `--prompt "$(cat)"`;`~/.hermes/config` + `.codex` 未动。

## Next Steps(下次从哪继续)
1. **(磊哥)commit CC docs 改动 → 复制引导语派 codex** 自主实装 C5(按派单 + 每 step hermes 审)。
2. **(codex)** 起手读派单绝对路径 → B1/B2 显式做 → 数据生成(hermes glm 多源)→ smoke → train(dev_selection openspec change)→ 签发(模型质量 V-PASS,端侧待真机)。
3. **(CC 下个 session)** 监督 codex 进度 / 端侧真机 V-PASS 排期 / C5 第一轮 checkpoint 后解冻 P2 C4/C7。

## 相关文件(≤5 优先 + 本 session 产物)
- ⭐ 派单:`~/workspace/raw/05-Projects/MAformac/dispatches/2026-06-21-c5-lora-training-apply-dispatch.md`
- ⭐ grill 全决策:`docs/p1c-training-grill-decisions.md`(Q1-Q18)
- probe:`docs/research/2026-06-21-c5-generator-selection-probe.md`
- 双审结果:hermes `/tmp/hermes-audit-result.json` + subagent CC(transcript)
- 元认知:memory `baseline-read-first-lesson`(四腿)+ 顶层 `codex-metacognition §31`

## 起手第一步(下个 session)
读本 handoff → `docs/p1c-training-grill-decisions.md` Q11-Q18 → 派单 → 确认 codex 是否已派/进度。若 codex 已实装,核 B1/B2 是否显式做了 + 每 step hermes 审是否跑。

# L05 训练中途 gate + stop-the-train（一手调研档）

> 维度：训练中途 gate + stop-the-train（只管训练过程早停门，不管 final 验收）。P0，0/34 直接刹车。
> as-of 2026-06-24 · 本机 scout + 10+ 联网搜证 + 项目锚一手核

## 0. 一句话核心结论

中途门是 P0 防 0/34 复发的核心维度，但有一条 **load-bearing 铁律**：0/34 的 collapse 是「**loss 健康 / 行为全塌**」，所以中途门必须是【**行为生成门**】（iter50/100/150 抽样 generate→解析 toolCall→C6 第一/二层抽样 N≥5，不达阈即停），**而不是 mlx-lm 自带的 val-loss 门**——后者根本测不到 0/34，用它=假安全必复发。本路全程 **escape_hatch**：守 rank16Mainline 配方，只加旁路监控门，零碰超参/零 A2 surface 改/零越界（设计成 OpenSpec task 弹药，不实跑训练）。

---

## 1. 本机 scout（坐实，不凭猜）

| 项 | 实况 | 来源 |
|---|---|---|
| mlx-lm 版本 | **0.31.1 已装** | `pip show mlx-lm` → /Users/wanglei/Library/Python/3.13/lib/python/site-packages |
| 内存 | **32 GB** | `sysctl hw.memsize` |
| mlx-lm trainer 早停能力 | **无原生早停**；有 `steps_per_save=100`/`steps_per_eval=200`/`TrainingCallback` | 本机 `mlx_lm/tuner/trainer.py:36-65`、`callbacks.py:16-23` |
| 🔴 callback 能否停 loop | **不能停 stock loop**——`trainer.py:273-301` 调 `on_val_loss_report(val_info)` 但 loop 不 check 返回值，必须 raise 异常或 fork | 本机源码逐行 |
| home-llm 蓝本 | 已 clone `ref-repos/home-llm`（1364★），直接读 | — |
| mlx-lm 活跃度 | **pushedAt 2026-06-12 / 6019★**（活跃） | `gh repo view ml-explore/mlx-lm` |

**关键工程事实**：要真早停，必须 `train()` 外包 `try/except`，从 callback 内 `raise StopIteration`（loop 不响应 should_stop 标志）。这决定了门的实装形态——不是改 mlx-lm 配置，是包一层 wrapper。

---

## 2. 逐条 finding（每条带 source + vs baseline）

### F1 — mlx-lm callback 停不了 stock loop（硬约束）
本机 `trainer.py:273-301`：loop 内 `evaluate()`→`on_val_loss_report` 无 `break`/无返回值检查。社区标准做法（WebSearch 2026-06-24）= callback 内 `raise` + `train()` 外 catch，或 fork/patch loop。
- **vs baseline**：escape_hatch（不改配方，包 wrapper）。vs home-llm：home-llm 用 axolotl 完全没这机制。

### F2 — mlx-lm 原生门是 val-loss，测不到 0/34
`steps_per_save`/`steps_per_eval`/`val_batches` 只产 val-loss。0/34 恰是 val-loss 健康但 `toolCalls=[]` 全空（grill-decisions.md）。**val-loss 门必然漏 0/34**，行为门必然命中。
- **vs baseline**：oppose『靠 mlx-lm 原生门』；support『行为门必须自建』。worse-if-naive（只用 val-loss=假绿）。

### F3 — home-llm 蓝本零中途门（精确分界）
`ref-repos/home-llm/train/configs/gemma3-270m.yml`：`val_set_size:0.0`(75) / `num_epochs:1`(87) / `evals_per_epoch:`空(102) / `saves_per_epoch:1`(103)。**home-llm 不需要门=任务简单（单域模板化）；MAformac 562intent/4类/D-domain 复杂度 23x 必须加**（post-roadmap P1-4 已判『home-llm 不需要 MAformac 必须』）。
- **vs baseline**：better vs home-llm（显式超越而非抄）。

### F4 — 业界实证 loss 与行为解耦（复现 0/34 模式）
Instruct-SkillMix（arxiv 2408.14774）：cross-entropy loss 全程**上升**而 held-out 性能峰在 **epoch11/15** 后下降；用 val-task 选 29.77% vs 用 loss 选仅 16.5%。Over-Memorization（arxiv 2508.04117）：val-perplexity 选早、val-accuracy 选晚，都可能 OOD 退化。format-collapse：79% JSON 合法但仅 56% 语义对。
- **vs baseline**：support『按行为选 checkpoint，非取末轮』。better（防末轮过拟合退化）。

### F5 — ALTO 自动过拟合早停 + best-checkpoint 恢复（2026-04 最新，LoRA-focused）
ALTO（arxiv 2604.05426，2026-04-07）：监控 raw-val-loss 与 EMA-smoothed-train-loss 的 **gap-ratio**，连续若干 eval step gap 持续→在 best-val-loss 处 checkpoint 后 terminate；**patience** 避免瞬时波动误杀。
- **vs baseline**：support『patience + best-checkpoint 恢复』。**partial**：ALTO 仍 loss-based，对 0/34 需把指标换成行为（gap-ratio→behavioral-pass-rate-drop）。

### F6 — stop-the-train 必须 infrastructure-enforced（不能 agent 自审）
Stanford Law CodeX 2026-03-07『Kill Switches Don't Work If the Agent Writes the Policy』：单 kill-switch + post-hoc checkpoint 不够，要『**pre-execution gate / layered shutdown / circuit-breaker outside agent execution context**』。精确命中 0/34 根因——codex 自主跑、自审、无外部门，通宵才暴露。
- **vs baseline**：support『门外部强制』。better（0/34 正因无外部门）。

### F7 — C14 四态 + receipt 与业界 HITL/HOTL 一致
`continue|human_pause|early_stop|blocked` 映射：HITL=blocking gate（human_pause 审批）/ HOTL=monitor+kill-switch（early_stop/blocked 自动）。receipt 必含 traceable-id/版本/provenance/approvals/monitoring-signal 才 audit-ready（EU AI Act Art.12/26）。
- **vs baseline**：support『四态 + receipt』。better（轻治理也要 sign-or-block 留痕）。

### F8 — 假想门阈值能在 iter50 catch 0/34
golden≥60%/fuzz≥40% + 50/100/150 密 checkpoint（比 θ-α 100/400/600 更早）：iter50 抽样 generate N=5 golden 全 0/5=0%<<60%→`early_stop`，省 ~550 iter + 通宵。**前提：抽样 N≥5 + generate 走 A2 D-domain 同源 surface**。
- **vs baseline**：vs θ-α 旧节奏 better（iter50 停 vs iter600）。escape_hatch。

### F9 — 行为门成本可承受
本机 32GB / mlx-lm 0.31.1；业界报 MacBook LoRA run 45min/峰值6.8GB，M5 比 M4 快 3.5-4x。每 checkpoint 抽样 generate N=5×(golden+fuzz)≈10-20 条短生成，< 5% 开销。**加门反而省掉跑满 600 iter 才发现全 0 的浪费**。
- **vs baseline**：better（net-positive 省算力）。

---

## 3. clone/源码发现（home-llm + mlx-lm）

- **mlx-lm 0.31.1 trainer 拆解**（adopt/adapt/drop）：
  - `TrainingArgs`(trainer.py:36) — `steps_per_save`/`steps_per_eval`/`val_batches` → **adapt**（cadence 旋钮可用，但语义是 val-loss）
  - `TrainingCallback`(callbacks.py:16) `on_val_loss_report`/`on_train_loss_report` → **adopt 挂点**（行为门挂这里触发）
  - loop(trainer.py:255-301) 不 check should_stop → **adapt**（必须 raise 早停 / 或 fork loop）
  - 周期 checkpoint(trainer.py:358-362) `{it:07d}_adapters.safetensors` → **adopt**（best-behavioral-checkpoint 用它存）
- **home-llm 配方对照**（gemma3-270m.yml）：`evals_per_epoch:`空 + `saves_per_epoch:1` + `val_set_size:0.0` → **drop**（MAformac 不能套这个『无门』，反例）；`warmup_ratio:0.1`/`lr_scheduler:cosine` → 与 rank16Mainline 配方对照（本路不动配方）。

---

## 4. 假想验证（MAformac 真实场景推演）

**假想**：mid-gate（golden≥60%/fuzz≥40%）+ iter50/100/150，能否 iter50 catch 0/34 而非跑满？

**预测：能 catch，但仅当【行为生成门 + A2 同源 surface + 抽样 N≥5】三条件同满足；否则假绿复发。better 概率 high。**

依据：①0/34=generated-positive 全 checkpoint FAIL（θ-α 实测），是行为塌缩非 loss 异常→loss 门必漏、行为门必命中（iter50 golden 0/5→early_stop）②业界双证 loss/行为解耦是系统性现象③mlx-lm callback 能挂行为 generate + raise 早停（工程可行 escape_hatch）。

**失败模式（pre-mortem 守）**：
- **FM1 假绿（最危险）**：generate 用了非 A2 同源 surface（仍 generic frame）→门 surface mismatch=假信号。修法=门 generate/parse 复用 A2 ToolContractCompiler + C6 同 harness，单测断言三者同源（TRN2/AUD5）。
- **FM2 抽样太小误判**：N=5 在阈值边界（2/5=40% vs golden60%）噪声大→落 human_pause 让人拍，不自动 early_stop。
- **FM3 阈值刹错车**：base Qwen3-1.7B 无 LoRA 已 C6 hard_fail（IrrelAcc0.789）/ BFCL55%；阈值定绝对值会把 base 刹掉。修法=阈值=『相对 base 不退化』（base 锚 10/23），spike 后拍死（Phase0 标 hypothesis）。
- **FM4 早停后选错 checkpoint**：取末轮 vs best-behavioral？Instruct-SkillMix 证最优常在 mid（epoch11/15）。修法=存 best-behavioral-pass-rate checkpoint，receipt 记 step + metric。

**净结论**：unknown→better（high）。风险全在『门 surface 同源 + 阈值相对 base + 抽样足够 + best-checkpoint 选取』四工程细节，必写进 OpenSpec task 验收字段（非 prose）。

---

## 5. premortem 三分类（见 schema premortem 字段，此处摘要）

- **tiger ×4**：①val-loss 门测不到 0/34 ②门 surface mismatch 假信号 ③callback 停不了 loop（以为停了实没停）④阈值绝对值刹掉 base。每条带验证清单。
- **paper-tiger ×3**：①『mlx-lm 无早停=不能做门』（有 callback+raise 可建）②『轻治理不该加 receipt』（可靠性内核非治理工程，0/34 浪费 >> 加门开销）③『home-llm 没门所以不用』（任务复杂度 23x，post-roadmap 已判必须）。
- **elephant ×4**：①谁按 stop？无人值守训练 human_pause 退化成 continue→须『超时无响应→降级 blocked』fail-safe ②早停后『怎么修』缺设计→receipt 必记诊断信号（区分 collapse 重 vs surface 重，D1 两因）③门自己可能成第11坑（receipt 写 PASS 但门有 bug）→门必实跑 + value-in-source 核不信 flag ④抽样代表性→必分层覆盖 4 类 × 多族，N vs 覆盖 tradeoff 待 spike 定配额。

---

## 6. must_answer 5 答

1. **prevents_0_34=yes**：直接防 0/34 的 P0。但硬前提=行为门 + A2 同源 + 实跑非读 flag。
2. **vs_rank16mainline=escape_hatch**：零碰配方，旁路监控门 + 早停 wrapper + 四态 receipt。A2 PR#3 已证配方零碰可行。
3. **requires_a2_surface_change=no（强依赖）**：不改 A2 surface，但门必须复用它（同源），是 A2 下游消费者非修改者。
4. **introduces_deferred=yes（不实跑）**：涉 retrain-c5 + C6 评测（均 DEFERRED），但本路严守 Phase0=纯弹药，落 docs/research 不碰 contracts/，不越界。
5. **priority_self=P0**。

---

## 7. 给 propose 的 OpenSpec task 弹药（mid_training_gate spec 草案字段）

```yaml
mid_training_gate:           # retrain-c5 change design.md 新增段（DEFERRED 实跑）
  cadence_iters: [50, 100, 150]   # 密 checkpoint（比 θ-α 100/400/600 更早，D1 锚）
  gate_type: behavioral           # 🔴 行为生成门，禁 val-loss-only
  sample:
    golden_n: 5                    # ≥5 统计可信
    fuzz_n: 5
    stratify: [positive, unsupported, safety, followup]  # 分层覆盖 4 类
    family_coverage: ">=3 of 10"   # 多族非单族（覆盖盲区守）
  surface_assert: A2_ToolContractCompiler  # 🔴 generate/parse 同源 = eval = runtime（TRN2/AUD5）
  threshold:                       # 🔴 相对 base 不退化，非绝对值（hypothesis 待 spike）
    golden_pass: ">= base_golden"  # base C6 hard_fail 锚 10/23
    fuzz_pass: ">= base_fuzz"
  decision_enum: [continue, human_pause, early_stop, blocked]  # C14 四态
  human_pause_timeout: { minutes: N, on_timeout: blocked }     # 无人值守 fail-safe（elephant①）
  early_stop_action: save_best_behavioral_checkpoint           # 非末轮（FM4）
  receipt:                         # sign-or-block，audit-ready
    actor: <who>
    decision: <enum>
    timestamp: <iso>
    best_checkpoint_step: <int>
    best_behavioral_metric: <float>
    diagnosis_signal: <collapse_heavy|surface_heavy>  # 区分两因（elephant②/D1）
  enforce: infrastructure          # 🔴 train() 外 try/except + raise（callback 停不了 loop，F1）；非 codex 自审（F6）
```

**实装锚**：mlx-lm callback raise 早停（trainer.py:273 触发点）+ generate 走 A2 surface + receipt sign-or-block（make verify 门）。**全程不碰 rank16Mainline 配方**。
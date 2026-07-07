# C5 LoRA 完善 grill decisions (2026-06-21)

> 本轮 grill = workflow ultracode 7-lens 调研后,跟磊哥逐题 grill「第一版 candidate 后怎么完善 LoRA + 当前 loss 发散怎么修」。
> grill-with-docs **engineering-contract mode**(physical landing + pre-mortem triage + evidence-not-trust + two-layer check + frame-break)。
> 落 **raw**(codex 占主工作树,single-worktree 并发纪律);codex 收口后归位 `docs/`。续 `docs/p1c-training-grill-decisions.md`(Q1-Q18 apply 阶段)。
> 共 9 题(来自 workflow synth grill_ammo);本文件 append-only,逐题 crystallise 即落。

---

## Q1 — 峰值 LR 降不降(loss 发散直接修法)

- **决策**: `learning_rate` 2e-4 → **1e-4**(实证默认,非情绪保守)
- **physical landing**:
  - `mlx-lora-config.yaml: learning_rate: 0.0001`
  - 保留 cosine + warmup,warmup 按 **optimizer-update 单位**重算到占总 update ~5-8%(当前 rendered_warmup_steps=12 偏少)
  - **5e-5 = 自动熔断 fallback(非首选)**,触发任一 → 停跑自动重启 5e-5,不人工纠结:
    - `grad_norm` 非有限(NaN/Inf)
    - loss 单步跳 >3x 且 20-30 step 不回落
    - val loss 随 train 同步恶化
- **evidence**: 本机 `1455-smoke-only-schedule/mlx-smoke-only-600.log` iter30@LR1.00e-04 train loss=**1.069**; 同轮 iter60 LR 爬到峰值 2.00e-04 → iter70=**17.5**; `r9/mlx-smoke-600.log` 常数 2e-4 → iter80=**32.0**, val 4.473→6.381 退化。Qwen3 官方推荐 1e-4: https://github.com/QwenLM/Qwen3/discussions/1301 (2025)
- **pre-mortem**:
  - **tiger**: 峰值 LR 过冲是 loss 发散主因(实测坐实非推测,两条本机日志对照)→ 降 1e-4
  - **paper-tiger**: 「5e-5 更保守=更适合第一版」(磊哥纠正: 太低 LR 把「LR太低/数据不行/mask不对/模型学不会」搅成混合噪声,**破坏诊断可分离性**;第一刀走已验证甜区,保守值设自动熔断后备)
  - **elephant**: smoke loss 数字本身无诊断价值(跑的是 dry-run deterministic 串),别盯它调参
- **磊哥拍**: 1e-4 实证默认 + 5e-5 自动熔断后备(非首选)

---

## Q2 — 梯度裁剪(frame-break: 真老虎是 stock CLI 插不进 clip)

- **数值决策**: `max_norm=1.0`(磊哥拍,LLM de-facto 标准), 0.3 仅 fallback(1.0 下仍 repeated finite grad-norm spike 或裁剪占比长期异常高才降)
- **🔴 frame-break(CC 实读验证坐实,非凭 magnet 说)**:
  - codex 当前 = **调 stock `mlx_lm.lora` CLI** 训练,非自有 loop。证据:最新 `mlx-train-command.txt` = `/Users/wanglei/Library/Python/3.13/bin/mlx_lm.lora --train ...`;`Tools/C5TrainingCLI/main.swift:111`(拼 stock CLI 命令串)、`:213 trainingBackend="mlx_lm.lora_stock_cli"`、`:214 gradientClipStatus="blocked_stock_mlx_lm_lora_has_no_grad_clip_hook"`
  - stock `~/Library/Python/3.13/lib/python/site-packages/mlx_lm/tuner/trainer.py:245` 只有 `optimizer.update(model, grad)` 无 clip_grad_norm;`:37 TrainingArgs` 无 grad_clip 字段
  - **结论: 当前架构物理上插不进梯度裁剪**。codex 诚实标 blocked(**无 fake green**,这是好信号)。
  - MLX 官方有 `mx.optimizers.clip_grad_norm`(返回 pre-clip norm): https://ml-explore.github.io/mlx/build/html/python/_autosummary/mlx.optimizers.clip_grad_norm.html
- **physical landing(数值层定,架构层 PENDING)**:
  - 训练循环: `finite_check → clip_grad_norm(max_norm=1.0) → optimizer.update(clipped_grad)`
  - 记录: metrics.jsonl/receipt 记 `total_norm_preclip` / `clip_applied` / `nonfinite_grad_fail`(MLX clip_grad_norm 对 NaN/Inf 行为异于 PyTorch,需单独 finite 检查)
  - **前提 = 必须先有能插 clip 的训练循环**(架构层待磊哥拍,见下 discovery)
- **discovery check(CC 增量,不迎合 magnet 的「自有 loop」笼统说法)**:
  - magnet 物理落点说「自有 training loop 加 clip」,但**隐藏 gap: 自有 loop ≠ 加 5 行 clip**。它要复现 stock CLI 的全部: 数据加载(ChatDataset + `--mask-prompt` 的 loss-mask offset = **B1 think 块对齐战场**)、lr_schedule、grad accum、checkpoint、eval、LoRA 注入。
  - **「自有 loop」有两种,成本差 ~10x**: (A) 完全重写(重打 B1 mask 战场,风险高) vs (B) **最小自有 loop——复用 stock `mlx_lm.tuner` 的 ChatDataset/iterate_batches/build_schedule/save_adapter,只重写最外层 step 循环插 clip**(~30-50 行,B1/masking/schedule 全复用不重打)。B1 修复在 tokenizer patch 层,复用 stock ChatDataset + patched tokenizer 时 B1 仍生效。
  - ⭐ CC 倾向 **B(最小自有 loop)**:既得 clip 熔断,又不重打 B1。
- **pre-mortem**:
  - **tiger**: receipt 标了 grad_clip 但训练命令仍是 stock CLI = fake green(magnet 提)。验证步=每轮核 `train-command.txt` 入口 vs `gradientClipStatus`,从 blocked 变 active 时训练入口必须同步从 stock CLI 变自有 loop。当前 codex 诚实(blocked),无 fake。
  - **paper-tiger**: 1.0 vs 0.3 之争。1.0 是标准、0.3 是 fallback,真问题在架构(能不能插)不在数值(裁多少)。
  - **elephant**: 「自有 loop」= 重打 B1 mask offset 战场的风险 + 「完全重写 vs 复用 stock building blocks」10x 成本差,magnet 物理落点没区分。这是本题最大价值点。
- **磊哥拍**: `max_norm=1.0`(已定); **架构层(怎么获得能插 clip 的 loop)= 本轮反问 PENDING(B 最小自有 loop / A 完全重写 / C monkey-patch / D 暂不加只靠 LR)**

---

## Q3 — 别为 dry-run loss panic 改配方(元原则)

- **决策**: **B** — 认定 dry-run + LR 双因,只动已实证 3 旋钮(LR/clip/optimizer),不为 dry-run loss 大改配方结构
- **physical landing(磊哥纠正的精确边界)**: dry-run smoke loss = **有「训练系统报警」价值,无「能力诊断」价值**:
  - **触发**(工程健康排查): LR 过冲 / NaN-Inf / masking 失效 / clip 未接入
  - **不触发**(配方结构重构): rank16→32 / 全7模块→attn-only / epoch 改大改小
  - 配方结构项要等**云多源真口语数据 + C6 eval(真能力信号)**才有资格动
- **evidence**: receipt `generator_orchestration: dry_run_only`(`1455-smoke-only-schedule/c5-training-receipt.md:24`);synth grill_ammo 题3(`synth-structured.json:111`);**逻辑自洽 = LR 过冲正是 dry-run smoke loss 报出来的**(证明它有系统报警价值)
- **pre-mortem**:
  - **tiger**: 用 dry-run loss 调 rank/target/epoch = 拿错尺子(调「背模板」非「听中文」)
  - **paper-tiger**: 「dry-run loss 完全无诊断价值」(磊哥纠: 错,有训练系统报警价值,LR 过冲就是它报的;无的是能力诊断价值)
  - **elephant**: 没 held-out val 时连「训练健康」也只能看 train loss 形态,能力维度全盲(等真数据+C6)
- **磊哥拍**: B + 精确边界(系统报警 ✅ / 能力诊断 ❌)

---

## Q4 — rank/target_modules/epochs 守不守

- **决策**: **A 全维持**(rank16 / 全7模块 attn+MLP / epochs3)
- **physical landing**:
  - `rank16_mainline`(`C5LoRATraining.swift:686 rank16Mainline()`: num_layers=-1/rank16/scale32/全7 keys;1609 config 已渲染 adamw+lr1e-4+全7)
  - `rank32_secondary` 触发条件: C6 显示单跳容量不够 **+ 已排除数据多样性因素(CC discovery,诊断可分离性)** + 必须 `scale=64` 或 rsLoRA(防缩放稀释假结论)
  - `epochs=3` 前提: **held-out val 集 + early-stop 机制双备**(CC discovery);否则降 `epochs=2`
  - `second_turn_refs` 边界定死: **不让模型跨轮记忆**,走 C1 sidecar(`semantic-followup-transitions.jsonl`)+ C4 槽继承/query rewrite 压单跳 → **rank16 单跳假设有架构保证**
- **evidence**: 主线 `C5LoRATraining.swift:686`; `1609-smoke-only-lr1e4-adamw/mlx-lora-config.yaml`(adamw/wd0.01/lr1e-4/rank16/scale32/全7 keys); ADR 0001:15(二次交互 C1 sidecar、C4 消费); `baseline-semantic-protocol:69`(query rewrite+槽继承)
- **pre-mortem**:
  - **tiger**: rank32 固定 alpha 缩放从 2.0 稀释到 1.0 → 假结论(codex 已加 `scale=64` 条件防)
  - **paper-tiger**: 「rank16 太小 / 全7模块太激进 / attn-only 更稳」(workflow 多路一手证据 QLoRA/Biderman2024/ThinkingMachines/Amazon: 结构化 FC attn-only **全面劣于**含 MLP;单跳 rank16 够,瓶颈是数据多样性)
  - **elephant**: rank32 触发条件混淆「rank 容量不够」vs「数据多样性不够」(CC discovery: C6 某类 case 弱时两者表现一样,升 rank 前必先排除数据因素,否则又是混合噪声)
- **磊哥拍**: A 全维持 + second_turn_refs 走 query rewrite 压单跳(架构保证 rank16)
- **CC check codex Q4**: citations 全实读坐实 ✅; codex 已采纳 CC 两个 discovery(epochs val 早停 + rank32 scale=64); CC 再补 1 gap = rank32 触发缺「排除数据多样性」前提(诊断可分离性)

---

## 🎉 里程碑(2026-06-21 1609): loss 发散已解决

`1609-smoke-only-lr1e4-adamw` 实测(LR1e-4 + adamw + wd0.01): iter60=0.935 / iter70=0.603,峰值 1e-4 稳定 0.6-1.5 不炸。对照 r9(2e-4)iter80=32.0 / 1455(峰值2e-4)iter70=17.5。**Q1+Q5 完整闭环验证**(grill 判断→codex 实装→实测坐实)。Q2 clip 从"救命"降"保险丝"(光 LR+adamw 已稳,但 fallback 规则仍需 grad_norm + 真数据需熔断)。

---

## Q5 — optimizer(简报已含,1609 已实装)

- **决策**: **B** — adamw + weight_decay=0.01(替代默认 adam 零正则)
- **physical landing**: 1609 config `optimizer: adamw / weight_decay: 0.01`
- **原理**: adam 的 L2 正则与自适应 LR 耦合、效果扭曲;adamw 解耦 weight_decay,正则更干净。dropout=0 下 weight_decay 是主要正则手段。
- **evidence**: `1609-smoke-only-lr1e4-adamw/mlx-lora-config.yaml`(optimizer:adamw/weight_decay:0.01); synth grill_ammo 题5
- **磊哥拍**: B(既成事实,codex 1609 已实装,与 LR1e-4 一起验证 loss 稳)

---

## Q6 — 端侧 fuse parity(two-stage + fallback)

- **决策**: two-stage parity
  - **stage1 `deployment_pipe_smoke`**(现在,用 1609 dry-run adapter): 只验 **template byte parity + dynamic/fused-bf16/fused-4bit 三路可跑**;字段 `parity_stage=deployment_pipe_smoke`;**不签能力 V-PASS**(dry-run adapter 三路都不准,差异无意义,验不了 fuse 掉点)
  - **stage2 能力 V-PASS**(正式云数据 candidate 后): 同 C6 harness 真机三路 parity 签端侧 V-PASS
- **fallback**: fused-4bit 是**首选包形态(非 demo 硬要求)**;若 fused-4bit 掉点 >2pp,允许 dynamic adapter fallback,但必须**先实测 mlx-swift 支持 adapter 加载 + 8GB 真机内存/延迟/mock readback**,否则端侧 V-PASS 继续 blocked
- **physical landing**: `C5FuseParityGate.evaluate(tolerancePP=2)`(swift:999): ToolCallExact delta>2pp fail / mustPassRegression>0 fail / quantizedParseFailures>0 fail / quantizedIrrelAcc<c6ApprovedThreshold fail; `parity_stage` 字段
- **evidence**: receipt:30 `fuse_parity_gate:fail`; `swift:999 evaluate tolerancePP=2`; research:572 adapter 需 spike; 训练侧 enable_thinking patch `main.swift:297-300`
- **pre-mortem**:
  - **tiger**: fuse 4bit 静默掉点(#654/#1058,Mac val 看不出)→ 真机三路 parity 实测
  - **paper-tiger**: dry-run adapter 三路 ToolCallExact 差异(三路都不准,差异无意义)→ 故 stage1 不验 fuse 掉点只验管线
  - **elephant**: 端侧 enable_thinking 对齐没实装(CC discovery #2,见下)
- **CC check codex Q6 — discovery 2 gap(不迎合)**:
  1. **IrrelAcc 缺 dynamic-vs-fused delta**: gate 只判 quantized IrrelAcc 绝对达标(>=threshold),没判 fuse 前后 IrrelAcc 掉多少。fuse 让 IrrelAcc 0.95→0.91(仍>0.9)不报警 = 4pp 掉点漏检,比 ToolCallExact 2pp 还大且更危险(乱调工具)。→ IrrelAcc 加对称 delta 检查。
  2. 🔴 **端侧 enable_thinking 对齐没实装**: 训练侧 patch chat_template.jinja(`main.swift:297-300` 让 enable_thinking 未定义也注入空 think 块),但**端侧 mlx-swift 用什么 tokenizer/template 没人管**(grep 端侧零处理)。若端侧用原始 tokenizer,未定义 enable_thinking 时**不注入空 think 块** → 端侧渲染≠训练 → **B1 在端侧重现**。`deployment_pipe_smoke` 的 template byte parity 必须把「端侧用 patched tokenizer 或 mlx-swift 显式 enable_thinking=false」作**硬检查项**。= 之前 surface 的 train-serve parity 落点。
- **磊哥拍**: two-stage + fallback

---

## Q7 — masking(loss-mask 真生效,字段语义误导已澄清)

- **决策**: **B** — 正式训练实装/确认真 loss-mask + 拆字段澄清
- **🎉 实证(codex dump + CC 独立复现完全一致,三方坐实)**:
  - **tool_call 正例**: offset=418/length=498/trained=**80**,trained 从 `<tool_call>` 起,**不含 think、不含 user 协议串**
  - **no-call 反事实(CC 补验,codex 漏)**: offset=418/length=422/trained=**4**,trained 只含 `NO_TOOL<|im_end|>\n`,不含 think/user
  - **B1 机制坐实**: prompt(masked)尾部 = `...assistant\n<think>\n\n</think>\n\n`,空 think 块被算进 offset → trained 不含 think
  - no-call 数 **456/4556** = receipt `no_call_counterfactual_count`
- **矛盾澄清**: `--mask-prompt` **实际生效**(`main.swift:117`);receipt `train_on_turn=false` 是**字段语义误导**(≠ loss 算全序列);`datasets.py:65` 单连续区间 offset 逻辑
- **physical landing**(codex 落点 + CC 补):
  - `masking_coverage.train_on_turn` 拆成: `prompt_loss_mask_effective=true` / `assistant_span=tool_call_only` / `argument_masking_mode=data_augmentation`
  - receipt 保留 label-mask dump 指针
  - **CC 补**: dump **固化成 CI fixture**(断言 trained 不含 think + 从 tool_call/NO_TOOL 起 + offset 自洽),防 B1 patch 升级静默失效(非只「指针」)
- **masking 两类机制澄清**: `train_on_turn`=真 loss-mask(走 prompt mask offset) / `function_name`+`argument_name`+`argument_value`=受约束数据增广(distractor_only,stock mlx **物理做不到** arg-token 级 loss mask)
- **pre-mortem**:
  - **tiger**: 字段 train_on_turn=false 虚标误导(实际 mask 生效)→ 拆字段澄清
  - **paper-tiger**: 「--mask-prompt 没生效、loss 算全序列」(codex+CC dump 双坐实: 生效,trained 只含 ToolCall/NO_TOOL)
  - **elephant**: dump 只手动一次不固化 → B1 patch 升级后静默失效无人察觉(CC discovery: 做成 CI 自动断言)
- **磊哥拍**: B + dump 实证(codex+CC 独立复现坐实)
- **CC check codex Q7**: dump 数字独立复现完全一致 ✅;补 no-call 验证(codex 只验 tool_call 正例) + dump 固化 CI(codex 只说「指针」)

---

## Q8 — DoRA secondary 值不值

- **决策**: **B** — 保留 secondary,**排期 rank16 主线 V-PASS 后**
- **physical landing**: 主线 `fine_tune_type=lora`(`C5LoRATraining.swift:692`);`dora_rank8_secondary` 仅主线 C6/端侧 V-PASS 后跑,同 C6 harness 同 seed 报 std,receipt 标 `fine_tune_type=dora`/`training_type=qdora_secondary`(用同一 repo loop 保 clip/fallback 一致)
- **evidence**: swift:692 主线 lora; `lens6-issue-oracle.md:18`(DoRA 收益不确定 + 慢~20% + QDoRA 4bit 灰区不可外推)
- **pre-mortem**: tiger: 凭 Answer.AI 4bit 结论外推中文 FC; paper-tiger: 「DoRA 更先进该上主线」(收益~1% 非 FC 验证、4bit 灰区); elephant: secondary 也要用同 repo loop 保 clip/fallback 一致
- **磊哥拍**: B + 排期 V-PASS 后

## Q9 — 记录/追踪工具

- **决策**: **A** — mlx 原生 metrics.jsonl + matplotlib(不上 Trackio,sweep 时再加);wandb/mlflow cloud drop(违离线红线)
- **physical landing**: repo loop MetricsWriter emit `metrics.jsonl`;receipt 写真实 `metrics_jsonl_ref/best_checkpoint_step/best_checkpoint_val_metric`;Environment 段已有(seed0/mlx0.31.2/M5/32GB)
- **evidence**: receipt:50 `metrics_jsonl_ref=not_emitted_by_stock_mlx_lm_cli`(stock CLI 不 emit);`c5_mlx_train_loop.py:57 MetricsWriter`
- **磊哥纠正(CC 认)**: 1609 receipt **已有 Environment + Training curve 段**(CC 旧结论「缺 environment 段」基于 1455 旧 receipt,错),缺的只是 metrics_jsonl_ref(repo loop 接入后 emit)
- **pre-mortem**: tiger: metrics_jsonl_ref not_emitted(stock CLI 不 emit); paper-tiger: 「要 wandb/mlflow cloud」(违离线红线+上传阻塞); elephant: 无 seed 不可复现(已补 seed:0)
- **磊哥拍**: A + Trackio 仅 sweep 时引入

---

## 🔧 Q2 闭环更新(grill 期间 codex 实装 repo loop)

codex 在 grill 期间把 Q2 方案 B 实装:`Tools/C5TrainingCLI/c5_mlx_train_loop.py`(copy stock `trainer.train()` body + `clip_grad_norm(1.0)`:200 + finite_check loss/grad:271-275 + **nonfinite fallback:285=实装 magnet Q1 fallback 规则** + MetricsWriter:57);`main.swift:112` 训练入口指 repo loop。
- ⚠️ **§30 诚实标**: 代码层闭环(grep 坐实),**运行时待实跑**——1609 仍 stock CLI 跑的旧轮,repo loop 未产出带 grad_norm 的 metrics.jsonl,**parity smoke 未跑**。Q2 真闭环 = 下一轮用 repo loop 训练 + parity smoke(clip disabled 同 seed vs stock CLI 前 N step loss 容差内一致)过。

---

## ✅ 9 题 grill 全收口(2026-06-21)

Q1 LR=1e-4(✅实测) / Q2 梯度裁剪 repo loop(⚠️代码闭环待实跑) / Q3 dry-run 边界(元原则) / Q4 rank16 全维持 / Q5 adamw(✅) / Q6 端侧 two-stage parity(🔲待实装) / Q7 masking(✅实证) / Q8 DoRA secondary 排期 V-PASS 后 / Q9 metrics.jsonl 不上 Trackio。
→ 执行门版 = `c5-formal-training-checklist.md`(给 codex,每题 fail/block 判据)。教学版 = `lora-training-4-core-concepts-teaching.md`。

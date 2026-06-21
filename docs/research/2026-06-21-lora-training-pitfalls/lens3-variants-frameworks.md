# Lens 3 调研存档：横向 LoRA 变体 + 训练框架坑（MAformac C5）

> finder: ultracode Lens 3 | 日期: 2026-06-21 | 搜证: 14 次 WebSearch + 1 WebFetch（mlx-lm LORA.md）
> 场景锚点: Qwen3-1.7B-4bit / mlx-lm 0.31.1 / Mac M5 无 N 卡 / 中文车控 FC LoRA / rank16-α32-LR2e-4-cosine-3epoch / target=7投影 / smoke loss 发散 4.47→8.36 / secondary=[rank32_confirmation, dora_rank8_secondary]

## Summary

横向扫六种 LoRA 变体（标准/DoRA/rsLoRA/PiSSA/LoRA+/QLoRA）× 四框架（mlx-lm/unsloth/axolotl/llama-factory），对 MAformac 当前场景收敛出五条：

1. **DoRA 不该当主线**：1.7B 窄域 FC 收益不确定（文献多 ~1% 且非 FC 任务）、训练慢 ~20%；且 base 4bit → 实际是 QDoRA，4bit 处灰区。保留 secondary A/B 可以，但必须同 harness 公平比 + 如实标 QDoRA。
2. **rsLoRA/PiSSA/LoRA+ 对 rank16 主线全不命中**：rsLoRA 只 rank≥32 才解梯度坍缩；PiSSA 需 SVD+dropout0+mlx 不原生；LoRA+ 是大宽度渐近论小模型收益小。
3. **smoke loss 发散真凶大概率是工程+数据非 LoRA 变体**：dry-run 确定性串无泛化信号 + mlx dataset-reorder(#583)/warmup-init(#985) 坑 + LR 可能过高。
4. **target=7投影（attn+MLP 全 linear）已是最佳实践**，别退回 attention-only。
5. **mlx-lm 是 Mac 唯一本机选项**（硬约束），守住即可；注意 transformers>=5.0 耦合 + grad_accum 显存坑(#2840)。

## Findings（每条带 source + applies_to_maformac）

### F1 [MEDIUM] DoRA 主线不值得
- 收益: ~1%，基准非 FC（commonsense/视觉/instruction）；代价: 训练慢 ~20%（GPU 基准，Apple Silicon 未单测）；inference merge 后无开销（端侧友好）。
- source: https://kaitchup.substack.com/p/dora-better-and-faster-than-lora（2024-2025）; https://arxiv.org/abs/2402.09353（DoRA 论文 2024-02）
- → MAformac: 命中 dora_rank8_secondary。保留作 secondary，不当主线；必须同 harness 多跑报 std；排期留 +20% 训练时间。

### F2 [HIGH] 🔴 base 4bit → 自动 QLoRA；DoRA 叠加 = QDoRA，低 bit 可能反劣
- mlx-lm 机制: quantized model 自动走 QLoRA。QDoRA 在 4bit 灰区：Answer.AI 报 4bit 强（Orca 31.2% vs QLoRA 11.8%），但 SineLoRA 实测 2-3bit QDoRA 崩溃（2bit 0.135 vs QLoRA 0.671）。
- source: https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md; https://arxiv.org/pdf/2505.21895（2025-05）; https://medium.com/@AntonioVFranco/qdora-explained-the-new-peft-standard-for-2025-5cf59afeb6ba
- → MAformac: 训练实为 QLoRA（非纯 LoRA），dora_secondary 实为 QDoRA。receipt/对照基线如实标；4bit 灰区不可外推外文结论；想要全精度锚点可另训 fp16 base 一版（按需）。

### F3 [MEDIUM] rsLoRA 只 rank≥32 命中，rank32_confirmation 有缩放陷阱
- α/r→α/√r，解高 rank 梯度坍缩。固定 α=32 缩放: rank16=2.0 / rank32=1.0 / rank64=0.5。低 rank（4-16）标准缩放就好。
- source: https://arxiv.org/abs/2312.03732（2023-12）; https://huggingface.co/blog/damjan-k/rslora
- → MAformac: 主线 rank16 不需要 rsLoRA。⚠️ rank32_confirmation 固定 α=32 缩放掉到 1.0 被稀释，会得『rank32 不如 rank16』假结论——要么 α→64，要么开 rsLoRA 才公平。

### F4 [LOW] PiSSA 对 4bit base 命中弱
- SVD 主成分 init，收敛快性能高，量化友好（QPiSSA 减 4bit 误差 18.97%）；但需 dropout=0（MAformac 已满足）+ 前置 SVD + mlx-lm 不原生支持。
- source: https://arxiv.org/abs/2404.02948（NeurIPS 2024）; https://github.com/MuLabPKU/PiSSA
- → MAformac: drop 或最低优先 backlog（mlx 不原生 + 窄 FC 收益不确定，违轻治理）。

### F5 [LOW] LoRA+ 是大宽度渐近论，小模型收益小
- B 矩阵更高 LR（λ>1）；收益随 embedding 维度增大，小模型收益小且 ratio 需自调（BERT λ=2 到大模型 λ=16）。
- source: https://arxiv.org/abs/2402.12354（ICML 2024）
- → MAformac: drop（1.7B 宽度小 + mlx 无原生 flag）。

### F6 [HIGH] 🔴 smoke loss 发散真凶 = 工程坑 + dry-run 数据，非 LoRA 变体
- mlx-examples #583: dataset reorder 致 loss 波动 + 精度掉 ~10%；#985: warmup 把 LR 拉回 warmup_init；grad_accum 下 lr_schedule step 单位错（MAformac 已用 optimizer_update 修正，对）；dry-run 确定性串无泛化信号 loss 难降。
- source: https://github.com/ml-explore/mlx-examples/issues/583; https://github.com/ml-explore/mlx-examples/issues/985
- → MAformac: 直接命中断点。排查序: (1)等真口语数据再判 loss，别拿 dry-run loss 当质量信号; (2)打印 effective LR/iter 排 #985; (3)真数据仍发散先降 LR（2e-4→5e-5）; (4)别用 LoRA 变体治发散。

### F7 [LOW] target=7投影已正确（paper_tiger）
- FC 应全 linear（attn+MLP），attention-only 即使提 rank 仍 underperform；MLP 承载主收益；覆盖>rank。
- source: https://thinkingmachines.ai/blog/lora/（LoRA Without Regret 2025-09）; https://www.amazon.science/blog/optimizing-lora-target-module-selection-for-efficient-fine-tuning（2026-03）
- → MAformac: defaultProjectionKeys 7 个 = 全 linear，已最优，守住。

### F8 [MEDIUM] mlx-lm 框架横向坑
- 唯一 Mac 本机选项；无多卡；transformers>=5.0 强耦合（打破部分模型 import）；grad_accum mlx core #2840 显存线性增长；GGUF 仅 Mistral/Mixtral/Llama。unsloth/axolotl/llama-factory 全 CUDA-only 不可用。
- source: https://www.spheron.network/blog/axolotl-vs-unsloth-vs-torchtune/; https://github.com/ml-explore/mlx/issues/2840; https://github.com/ml-explore/mlx-lm/issues/727
- → MAformac: 锁 mlx-lm 0.31.1 + transformers 版本进 lock；gradAccum=4 风险低但加大要监控；train(mlx-lm)-serve(mlx-swift) 同生态无跨引擎移植坑（选 mlx 隐性优势）。

### F9 [MEDIUM] Qwen2.5-1.5B 实测 rank16/α32 仍严重遗忘，FC 格式尤伤
- 同量级模型实测 LoRA 不缓解灾难性遗忘；FC JSON 格式训练伤通用 QA；遗忘不能靠 early stopping/调参数量避免；低 rank（8）更缓解。
- source: https://arxiv.org/pdf/2401.05605（2024-01）; https://hesamsheikh.substack.com/p/lora-learns-less-and-forgets-less
- → MAformac: 命中（1.7B+FC JSON+rank16+3epoch 高风险区）。3 HIGH 已部分缓解；补：评测加通用能力回归探针（域外 QA 哨兵）；别加 epochs/rank 追指标。

## Pre-Mortem 三分类

**tiger（明确威胁，带验证）**
- QDoRA-4bit 灰区 → dora_secondary 必须同 harness 实测，禁外推 Answer.AI 4bit 结论
- rank32_confirmation 缩放陷阱 → α→64 或开 rsLoRA 才公平，否则假结论
- 1.7B FC 格式遗忘 → 加通用能力回归探针，别上调 epochs/rank

**paper_tiger（看似威胁实际安全，给证据）**
- target=7投影『待调』其实已最优（LoRA Without Regret + QLoRA），别动
- smoke 发散看着像 LoRA 方法问题、其实工程+数据（#583/#985 + dry-run + LR），别用变体治
- rsLoRA/PiSSA/LoRA+ 看着先进、对 rank16 小模型主线全不命中（新≠强）

**elephant（没人谈但该谈）**
- 训练类型口径：base 4bit → 实为 QLoRA/QDoRA，文档别笼统写『LoRA』（对照锚点口径）
- 缺通用能力回归探针：3 HIGH 偏测 FC 域内+拒识，没测训完后通用对话退化
- mlx-lm 依赖锁定缺位：transformers>=5.0 耦合，要写 version lock（train-serve parity 依赖版本一致）
- secondary 排期成本：DoRA 慢 20% + rank32 显存翻倍 + 同 harness 多跑去污 = 按 3-5x 单次成本估算

## 决策建议（喂回主线程 grill）

| 议题 | 选项 | ⭐ 推荐 | 量化依据 |
|---|---|---|---|
| DoRA secondary 留不留 | A 删 / B 留作 A/B 实测 | ⭐B 留但降优先级 | 收益 ~1% 不确定，代价慢 20%；留只为诚实对照，不进主线 |
| rank32_confirmation 怎么配 α | A 固定 α32 / B α→64 / C 开 rsLoRA | ⭐B α→64（保缩放2.0）或 C | 固定 α32 缩放掉 1.0 → rank32 假性不如 rank16 |
| smoke loss 发散先动哪 | A 换 LoRA 变体 / B 修工程+等真数据+降LR | ⭐B | 发散非变体能治；#583/#985 + dry-run 无泛化信号 + LR 过高 |
| rsLoRA/PiSSA/LoRA+ 进不进矩阵 | A 全进 / B 全不进守标准 LoRA | ⭐B | rank16 主线三者全不命中；mlx 不原生；轻治理 |
| 评测补不补域外探针 | A 不补 / B 补通用 QA 哨兵 | ⭐B | Qwen2.5-1.5B 实测 FC 格式严重遗忘通用能力 |


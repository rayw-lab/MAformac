# Lens 6 — 经典 issue / 坑点 oracle（GitHub issues 深挖 + pre-mortem）

> MAformac C5 LoRA 训练（Qwen3-1.7B / mlx-lm 0.31.1 / M5 / 4bit QLoRA / FC / tokenizer patch / smoke loss 发散 / dry-run 数据）
> 16+ 次联网搜证，每条带 source URL + 日期 + open/closed 状态 + applies_to_maformac 判定。

## Summary（本路核心结论）

深挖 ml-explore/mlx-lm + mlx-examples + mlx core + QwenLM 共 16+ 次搜证，命中 MAformac 会撞的真实坑。最高优先：

1. **smoke loss 一路波动上升（iter1 Val4.47→iter60 Train8.36）几乎确定不是 mlx 框架 bug**，而是「dry-run deterministic protocol 同质串当训练数据」+「600 步太短」+「空 think 块可能仍漏进 loss」叠加 = 数据/方法坑。正式云多源 generator 接入前，smoke 发散不可作训练失败结论。
2. **mlx-lm 历史 LR 调度 bug（cosine decay 在 warmup 提前衰减，#2617）已修于 MLX 0.17.1**，MAformac 用 0.31.1 大概率不受影响，但须本机打印 LR 曲线坐实（warmup_fraction 路径未被 issue 显式覆盖）。
3. **M5 LoRA 首 backward 崩 OOM（#1206）只命中 Qwen3.5-9B 新架构**，Qwen3-1.7B + 12.2GB peak 已跑通 = paper tiger。
4. **真 tiger = 4bit base fuse 后掉点 / train-serve parity 断裂**（#654/#832/#757/#1058 反复出现），直击 MAformac 端侧 iPhone 部署诚实性。
5. **--mask-prompt 只对 chat 最后一条 assistant 算 loss**，命中 MAformac second_turn_refs 多轮，须自管 masking。

---

## Findings（逐条，带 source + 三分类）

### F1【MEDIUM·paper_tiger】mlx-lm LR 调度 bug #2617（已修于 MLX 0.17.1）
- **源**：https://github.com/ml-explore/mlx/issues/2617 （CLOSED，2025-09-23）
- cosine_decay 在 warmup 阶段提前衰减：`join_schedules(...,[warmup_steps+1])` 边界 +1 致 decay 早启 + 不扣 warmup 步数 → warmup 末 LR 偏低（warmup=100/peak=1e-5 实得 9.933e-6）。关联 mlx-examples #985（LR 塌回 warmup_init 1e-7，loss 抖）。
- **MAformac**：用 0.31.1（远新于修复版），LR=2e-4/cosine/warmup_fraction=0.08 在区间内，大概率已修。**但** warmup_fraction(分数)路径未被 issue 显式确认覆盖。**动作**：训练日志打印前 ~60 步实际 LR，确认 warmup 末（~48 步 of 600）真到 2e-4。5 分钟可坐实，别凭'新版应该修了'放行。

### F2【LOW·paper_tiger】M5 LoRA 首 backward 崩 OOM #1206（只命中新架构）
- **源**：https://github.com/ml-explore/mlx-lm/issues/1206 （OPEN，2026-04-26）
- M5 Max 36GB 上 Qwen3.5-9B-4bit forward 过、第一个 training iter 崩 [METAL] Insufficient Memory，与 batch/seq/层数/grad-ckpt 无关；切 Qwen3-8B-4bit 同配置可训 = Qwen3.5 新架构特定问题。关联 #828（调 wired_limit~90%/cache_limit→0）、mlx#1406+examples#738（显存缓涨泄漏 60 iter 后 90→200GB）。
- **MAformac**：训 Qwen3-1.7B（比崩的 9B 小 ~5x），smoke 实测 12.2GB peak 跑通 600 步 = 不命中。**但** 正式长跑（全量 3 epoch）按 iter 累积的显存泄漏 smoke 看不出。**动作**：正式训前设 cache_limit 较低值，长跑挂显存监控。

### F3【HIGH·TIGER】4bit base fuse 后掉点 / adapter-vs-fused 不一致
- **源**：https://github.com/ml-explore/mlx-lm/issues/654 （OPEN，2025-12）+ #1058（2026-03，Qwen3.5-4B merged 转 MLX 前 20-30 token 对后发散）+ mlx-examples #832/#757/#460（历史）
- 顽疾：--adapter-path 好、fuse 后掉点甚至回退未微调水平。共因=fuse 进已 4bit base 损精度。workaround：--de-quantize / fuse 进 fp16 / 训练-推理同 template+special token+temp0 验 parity。
- **MAformac**：base 已 4bit，iPhone 计划 LoRA fuse+量化后跑 mlx-swift = 正撞高危区，且 enable_thinking=false 不一致会放大。**验证清单**：①adapter 态 vs fuse 态 同 greedy 跑 C6 对账，掉点>阈值即 BLOCKER ②试 --de-quantize ③mlx(训练) vs mlx-swift(端侧) token-level **长输出**对账（#1058 前 20 token 对后发散，不能只看头）。写进 P1-C 端侧 V-PASS 门。

### F4【MEDIUM·TIGER】--mask-prompt 只对 chat 最后一条 assistant 算 loss
- **源**：https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md （current）+ arxiv 2504.18246（单 pass 块稀疏 mask 正解）
- chat 数据'final message 才是 completion'，中间 assistant turn 被当 prompt mask 掉。正解=对全部 assistant token 算 loss。
- **MAformac**：命中 second_turn_refs 多轮 + train_on_turn masking。裸用 stock --mask-prompt 会把第一轮澄清回复 mask 掉、信号丢失。**动作**：既已走 tokenizer patch(B1)，masking 自管（按 fc_flags + train_on_turn 逐 turn 构造 label mask）。**验证**：2-turn 样本 dump label mask，确认两轮 assistant 都有 loss。

### F5【HIGH·TIGER】Qwen3 空 think scaffold 必须 prompt-only(masked) + train/serve enable_thinking 一致
- **源**：https://github.com/QwenLM/Qwen3/discussions/1300 + aws-samples notebook（2026）+ Unsloth docs + Ollama #14798
- enable_thinking=false 不删标签而是产空 `<think>\n\n</think>\n\n`+答案；最佳实践=scaffold 作 prompt-only(masked) 只训最终答案，多轮历史不带 thinking content。
- **MAformac**：升级 B1 坑。patch 后须核 ①空 think scaffold 落 masked(prompt) 段、不在 loss 段（否则训成'每次先吐空 think'+前缀同质→loss 抖，**smoke 发散高嫌疑根因**）②端侧 mlx-swift 同样 enable_thinking=false。**动作**：dump 训练样本 token+label_mask，确认 `<think>\n\n</think>\n\n` mask=0、只有 tool_call 答案 mask=1。**优先验**。

### F6【HIGH·TIGER】smoke loss 发散根因=deterministic 同质数据 + 600 步太短（数据/方法非框架）
- **源**：https://arxiv.org/pdf/2602.09492（batch size bias）+ Axolotl training_stability + Raschka instruction masking
- 小 batch loss 抖是常态（MAformac grad_accum=4 已缓）；LR=2e-4 在稳定区 1e-4~3e-4 非首嫌；validation spike-then-recover=噪声 vs 单调上升=LR高/数据坏要区分。**真嫌=数据**：dry-run deterministic protocol 串前缀同质→模型背极相似序列→记忆边缘抖升、无泛化信号。
- **MAformac**：这是好消息——发散绝大概率不是 mlx 框架坏。**结论**：①smoke 发散不可作训练失败结论 ②接真数据前先排除 F5(mask 边界)+F1(LR 曲线)两混淆变量 ③正式训用真口语变体后按 std 多跑、看 held-out(换说法/没见过 arg 值/按 bug_id 分层)判。

### F7【MEDIUM·已部分内化】FC 微调'准确率↑ vs irrelevance↓'反向权衡 + distractor/refusal 配方
- **源**：https://arxiv.org/pdf/2410.04587（Hammer）+ 2409.00608（TinyAgent，LoRA 3epoch/LR7e-5）
- Hammer：FT 后 function 准确率↑ 但 irrelevance↓；解药=7500 条 irrelevance augmentation(正确 function 移除/label 空 list)。TinyAgent：distractor 进候选列表'particularly effective'。
- **MAformac**：命中且 3HIGH'防手痒 IrrelAcc≥20% 负样本'正是解。**补强**：base 无 LoRA 已 IrrelAcc 0.789 hard_fail，印证反向权衡——LoRA 训完 IrrelAcc 可能不升反降，≥20% 负样本是必须，held-out 独立报 IrrelAcc 不被总分掩盖。

### F8【LOW·paper_tiger】mlx-examples #583 数据长度排序致 loss 波动~10% 掉点
- **源**：https://github.com/ml-explore/mlx-examples/issues/583 （OPEN，2024-03，旧仓）
- iterate_batches 按 length 排序→batch 多样性降→loss 波动+~10% 掉点。
- **MAformac**：旧仓 mlx-examples，新 mlx-lm 0.31.1 batching 已重写 = 不直接命中。仅作 F5/F1/数据三嫌排除后的低优先顺手核（grep 当前 iterate_batches 是否还 length-sort）。

### F9【LOW·paper_tiger】4bit QLoRA vs fp16 质量差（MLX 整数量化非 NF4）
- **源**：https://arxiv.org/pdf/2305.14314（QLoRA）+ mlx convert docs
- QLoRA 论文 NF4+double-quant 复原 16bit、FP4 落后 ~1 点；但 mlx convert 用整数量化非 NF4，'matches fp16'不直接适用。group_size 越大误差越大。
- **MAformac**：差距通常小，4bit 是 iPhone 8GB 硬约束非可选。与 F3 叠加=误差累积链。**动作**：端侧最终量化用 --q-group-size 64(非默认更粗)对账，C6 端侧掉太多则 32 或保更高 bit。端侧调优期备选旋钮，非主线阻塞。

### F10【MEDIUM·TIGER】Qwen3 chat_template 跨引擎(mlx vs mlx-swift)兼容 + SFT 长上下文漂移
- **源**：https://github.com/allanchan339/vLLM-Qwen3-3.5-3.6-chat-template-fix + froggeric fixed templates（2026）
- 官方 Qwen3 jinja 含 Python-only 特性，minijinja/minja(C++，mlx/llama.cpp/LM Studio 用)会崩或异常；SFT 长上下文(>65K)格式漂移。
- **MAformac**：训练态 mlx(Python jinja2) vs 端侧 mlx-swift(C++ minijinja)= 跨引擎坑高发组合，放大 F3 掉点。长上下文漂移影响小(车控 FC 短)。**动作**：①mlx-swift 端侧 chat_template 与训练态字节级同源（尤其 tool_call/think 渲染）②若 mlx-swift 渲染崩，换社区 fixed template 但两端必须同一份。进端侧 V-PASS parity 门。

---

## Pre-Mortem 三分类汇总

**TIGER（真威胁，带验证清单）**：F3 fuse 掉点/parity（adapter vs fuse + mlx vs mlx-swift 长输出对账）· F5 空 think scaffold mask 边界（dump label_mask 确认 think 段 mask=0，smoke 发散高嫌疑）· F6 deterministic 数据致 loss 发散（接真数据前排除混淆变量）· F4 mask-prompt 只算最后 turn（second_turn_refs 自管 masking）· F10 chat_template 跨引擎（两端字节级同源）

**PAPER_TIGER（看似威胁实际可控，带证据）**：F1 LR 调度 bug（已修 0.17.1，打印 LR 曲线坐实）· F2 M5 OOM（只命中 9B，1.7B 12.2GB 跑通）· F8 数据长度排序（旧仓不命中）· F9 QLoRA 质量差（差距小且 4bit 是硬约束）

**ELEPHANT（没人谈但该谈）**：
1. smoke 用 deterministic 串本不该期待 loss 收敛——它是'链路烟测'非'配方判据'，拿错尺子量错东西；正式判据是 held-out FC 准确率/IrrelAcc 非 train loss。
2. B1 tokenizer patch 在 mlx-lm 升级时极脆——须把 label mask 边界断言（think 段 mask=0）做成 CI 测试，否则升级后空 think 又漏进 loss 无人察觉。
3. fuse 掉点+template 跨引擎+空 think+4bit 再量化 是'误差累积链'非独立坑——叠起来端侧可能从'Mac 训练态优秀'掉到'iPhone 演示态翻车'；端侧真机 parity 对账不能用 Mac 态代替。
4. IrrelAcc 反向权衡 + base 已 0.789 hard_fail = LoRA 训完 IrrelAcc 可能不升反降；只盯 FC 准确率报喜会漏拒识退化，held-out 必须独立报 IrrelAcc。

---

## 给主线程/grill 的弹药（每条 topic + 动作 + 优先级）

| # | 议题 | 动作 | 优先 |
|---|---|---|---|
| 1 | smoke loss 发散是不是真问题 | 排除 F5(label_mask dump)+F1(LR 曲线)后，接真口语数据再判；smoke 串发散正常 | 🔴 最高 |
| 2 | 空 think scaffold 是否漏进 loss | dump 一条训练样本 token+label_mask，断言 `<think>\n\n</think>\n\n` mask=0，做成 CI 测试 | 🔴 最高 |
| 3 | second_turn_refs 多轮 masking | 自管逐 turn label mask，2-turn 样本验两轮 assistant 都有 loss，不裸用 --mask-prompt | 🟠 高 |
| 4 | 端侧 fuse parity | adapter vs fuse + mlx vs mlx-swift 长输出 token-level 对账，进端侧 V-PASS 门，试 --de-quantize | 🟠 高 |
| 5 | chat_template 跨引擎一致 | mlx-swift 端侧 template 与训练态字节级同源 | 🟠 高 |
| 6 | IrrelAcc 反向权衡 | held-out 独立报 IrrelAcc，≥20% 负样本必须，不被 FC 总分掩盖 | 🟡 中 |
| 7 | 长跑显存防护 | 正式 3-epoch 训前设 cache_limit + 显存监控（防 #1406 缓涨泄漏） | 🟡 中 |
| 8 | 端侧量化旋钮 | C6 端侧掉点大则 --q-group-size 64→32 | 🟢 低（调优期） |


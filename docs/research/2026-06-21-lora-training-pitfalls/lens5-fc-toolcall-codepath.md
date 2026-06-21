# Lens 5 — Function-calling/tool-call LoRA 训练特有坑（代码链路）

> ultracode 深度研究 · MAformac C5 LoRA 训练 · 2026-06-21
> 调研法：本机 mlx-lm 0.31.1 源码逐行 + 本机 Qwen3-1.7B-4bit 模板查证 + MAformac C5LoRATraining.swift 实读 + 14 次联网搜证（≥10 下限达标）

## Summary

读 mlx-lm 0.31.1 本机源码 + 联网搜证收敛出 8 个对 MAformac C5 命中的坑。**核心代码事实**：mlx-lm 的 loss mask 是「单连续区间」（`trainer.py:75-88` `default_loss`，`mask = steps>=offset AND steps<=length`），offset 由 `ChatDataset.process`（`datasets.py:57-77`）用 `messages[:-1]+add_generation_prompt` 算出——所以 **(a) 只训「最后一个 assistant turn」**，多轮/二次交互/distractor-recovery 全被吞；**(b) stock 路径没有 enable_thinking 注入点**（codex 的 B1 双换行前缀 + 训练专用 tokenizer patch 正是绕这个，方向已对）。

**当前 smoke loss 发散**最可能是三因叠加，按最便宜验证排序：① smoke 跑在 dry-run deterministic 协议串上（非真口语 + masking 未实装），数据退化本身就让 loss 不下降；② mlx 调度器 bug #2617（cosine decay 在 warmup 期就开始，`warmup_fraction=0.08` 命中，本机 `utils.py:18-35` 确认未修）；③ LR=2e-4 对 1.7B 偏高（业界小 Qwen 建议 1e-5~5e-5）。

**两个端侧 parity 坑**：fuse 进 4bit base 掉 adapter 行为（#654，需 `--de-quantize`）+ mlx-swift 推理侧 enable_thinking 可能不被模板处理（#154，本机 1.7B-4bit 模板有该分支但需端侧实测）。

---

## 关键代码链路（本机实读，file:line 锚点）

### mlx-lm loss mask 机制（单连续区间）
```python
# mlx_lm/tuner/trainer.py:75-88  default_loss
steps = mx.arange(1, targets.shape[1] + 1)
mask = mx.logical_and(steps >= lengths[:, 0:1], steps <= lengths[:, 1:])  # 单区间！
ce = nn.losses.cross_entropy(logits, targets) * mask
```
`lengths[:,0]` = offset（prompt 结束），`lengths[:,1]` = 序列实长。**只有 offset 到 length 之间一段算 loss**——单个连续窗口，无法表达多区间（多个 assistant turn）。

```python
# mlx_lm/tuner/datasets.py:57-77  ChatDataset.process
offset = len(apply_chat_template(messages[:-1], add_generation_prompt=..., tools=tools))
return (tokens, offset)
```
offset = **倒数第二条消息为止全部 mask**，只有最后一条 message（the completion）算 loss。官方 LORA.md：'For chat datasets the final message in the message list is considered the completion'。

### 本机 Qwen3-1.7B-4bit 模板（确认有 enable_thinking 分支）
```jinja
{%- if add_generation_prompt %}
    {{- '<|im_start|>assistant\n' }}
    {%- if enable_thinking is defined and enable_thinking is false %}
        {{- '<think>\n\n</think>\n\n' }}   # 空 think 块注入点
    {%- endif %}
{%- endif %}
```
但 `ChatDataset.process` **不传 enable_thinking** → stock 路径训练数据不带空 think 块，runtime enable_thinking=false 会带 → train/serve 不一致。codex B1 修法（双换行前缀 + 训练 tokenizer patch）正是绕此。

### mlx 调度器 bug #2617（本机 utils.py:18-35 未修）
```python
# mlx_lm/tuner/utils.py:18-35  build_schedule
bound_schedule_fn = schedule_fn(*arguments)   # 用全量 arguments（含总 decay 步数）构造 cosine
return opt.schedulers.join_schedules([warmup_fn, bound_schedule_fn], [warmup_steps + 1])
```
cosine 的相位时钟从 step 0 起算而非 warmup 结束起算 → warmup 交棒时 LR 已过峰衰减（issue 实测 step100 得 9.933e-6 而非 1e-5）。

### MAformac offset fixture（C5LoRATraining.swift:325-349）
```swift
let hasPrefix = content.hasPrefix("\n\n")           // 验双换行前缀
let trainedSpan = hasPrefix ? String(content.dropFirst(2)) : content
let spanMatches = trainedSpan == expected           // 验 trained span == expected tool_call
if failures.isEmpty && !usesTrainingTokenizerPatch {
    failures.append("mlx_apply_chat_template_offset_fixture_not_embedded")  // 真实 mlx 字节级 offset 未实测
}
```

---

## Findings（8 条，每条带 source + applies_to_maformac）

| # | Finding | Severity | 命中 MAformac |
|---|---|---|---|
| 1 | 单区间 mask 只训最后 assistant turn（trainer.py:75-88 + datasets.py:57-77） | HIGH | 单轮正例正好对；二次交互/distractor-recovery 多轮被吞 → 全拍平单轮 + validator 断言 |
| 2 | B1 已修要钉死：空 think 块 × stock offset 交互；offset fixture 还是 Swift 模拟非 mlx 实测 | HIGH | 直接命中，方向对；必须实跑 mlx python 打印 label 张量验字节级 mask |
| 3 | smoke loss 发散三因：数据退化(dry-run) > #2617 调度器 bug > LR=2e-4 偏高 | HIGH | 当前断点；先换真数据再下 LR 结论，warmup:0 隔离 bug，LR→5e-5→2e-5 |
| 4 | GOAT 实证 arg-value token masking 防死记学结构（支撑 3 HIGH） | HIGH | 已锁此方向；但 stock mlx 做不到 arg-token mask，实为数据增广，文档别混淆 |
| 5 | fuse 进 4bit base 掉 adapter 行为（#654），需 --de-quantize | MEDIUM | 命中 fuse_parity_gate；端侧 8GB vs 全精度 parity 是真矛盾，C6 量化 |
| 6 | mlx-swift 推理侧 enable_thinking 可能不被处理（#154） | MEDIUM | train(false)/serve parity 第二破口；端侧真机 dump prompt 逐字节比对 |
| 7 | Qwen3 special token/EOS 陷阱（base EOS 被换、PAD=EOS） | MEDIUM | instruct 版风险低（paper-tiger）；但手写 <tool_call> 格式须与模板字节一致 |
| 8 | MLX LoRA 默认只训 2 模块不够（#2616）；受限解码修不了选错工具 | LOW | MAformac 已扩 7 模块（对）；受限解码+LoRA 分工要钉 |

详细 detail 与每条 applies_to_maformac 见结构化 findings 字段。

---

## Pre-Mortem 三分类

### 🐯 Tiger（明确威胁，带验证清单）
1. **单区间 mask 吞中间轮**：grep C5 JSONL 是否有 messages 含中间 assistant turn → 有则学不到。修：全拍平单轮 + validator 硬断言。
2. **smoke loss 发散三因叠加**（当前断点）：① dry-run 数据 loss 不可信先换真数据 ② #2617 调度器 bug（本机确认未修）warmup:0 隔离 ③ LR=2e-4 偏高降 5e-5 再 2e-5。逐一验，别一次全改。
3. **offset fixture 是 Swift 模拟非 mlx 实测**：实跑 mlx python 产 batch 打印 label/mask 张量，肉眼确认 mask 恰覆盖 prompt+think、tool_call span 一字节不漏（HF 警告 Qwen3 off-by-one）。

### 🐯📄 Paper-Tiger（看似威胁实际安全，给证据）
1. **Qwen3 base EOS 被换无限生成**：MAformac 训 instruct 量化版非 base，EOS 仍 <|im_end|>，本机模板末尾正常（仍需 grep 确认，风险低）。
2. **PAD=EOS 学不到停止**：mlx-lm 用 np.zeros padding + 区间式 mask（trainer.py:150-154），设计上规避此坑，不像 HF 需手动设 PAD≠EOS。
3. **Apple WWDC25 称 fuse 自动处理量化**：实测(#654)深度微调量化误差仍放大丢行为，FC 结构化输出要实测 fuse parity 不能信『自动处理』。

### 🐘 Elephant（没人谈但该谈）
1. **smoke loss 数字本身没诊断价值**：dry-run deterministic 串重复模板小数据必过拟合，loss 发散是预期内。把 dry-run smoke loss 当配方好坏信号去调超参是南辕北辙——真信号要等云多源 generator + masking 接入后的真口语数据。当前该验链路跑通 + offset/parity fixture 正确，不是调 loss。
2. **train/serve parity 两个独立破口，Mac python 过≠端侧 mlx-swift 过**：训练侧(python mlx-lm)和推理侧(mlx-swift)两套代码，enable_thinking 透传(#154)/tool_call 渲染/EOS 都可能 swift 侧不一致。P1-C 两 V-PASS（Mac 质量/端侧 parity）正为此，但易只验 Mac 就宣称 parity 过。端侧 V-PASS 必须真机 dump prompt 逐字节比对。
3. **arg-value masking 三形态里只 train_on_turn 是真 loss mask**：stock mlx 单区间 mask 物理上做不到 tool_call span 内部 arg-token 级 mask。MAformac argumentValue masking 实为受约束数据增广走数据侧。文档/masking_coverage 要明确注释指『增广已实装』非『token mask 已实装』，否则后人在『为何 mask 没生效』空耗。

---

## Sources（按 finding 引用）

1. [mlx-lm LORA.md](https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md) — final message = completion，--mask-prompt 单区间
2. [Qwen3 chat template deep dive](https://huggingface.co/blog/qwen-3-chat-template-deep-dive) — 空 think 块 / multi-turn asymmetry / off-by-one
3. [mlx issue #2617 调度器 bug](https://github.com/ml-explore/mlx/issues/2617)（2025-09-23 open）；[arxiv 2602.04998 Learning Rate Matters](https://arxiv.org/pdf/2602.04998)（2026-02，超最优 LR 2× 使小 Qwen 发散）；[Ivan Fioravanti SmolLM3 warmup:0 配方](https://x.com/ivanfioravanti/status/1942828490136354967)
4. [GOAT arxiv 2510.12218](https://arxiv.org/pdf/2510.12218)（arg-token masking 学结构）；[ToolRLA 2603.01620](https://arxiv.org/pdf/2603.01620)（三层防御 8%→<1%）；[ToolACE 2409.00920](https://arxiv.org/html/2409.00920v1)（中文 arg 记忆）
5. [mlx-lm issue #654 fused 掉行为](https://github.com/ml-explore/mlx-lm/issues/654)；[#659 dequantize bug](https://github.com/ml-explore/mlx-lm/issues/659)
6. [mlx-swift-lm issue #154 enable_thinking 不透传](https://github.com/ml-explore/mlx-swift-lm/issues/154)（open）
7. [Qwen3 tokenizer im_end→endoftext](https://kaitchup.substack.com/p/qwen3-when-im_end-suddenly-becomes)；[Qwen function_call 文档](https://qwen.readthedocs.io/en/latest/framework/function_call.html)（<tool_call> 格式）
8. [mlx issue #2616 默认只训 2 模块](https://github.com/ml-explore/mlx/issues/2616)；[Unsloth LoRA hyperparameters](https://unsloth.ai/docs/get-started/fine-tuning-llms-guide/lora-hyperparameters-guide)；[arxiv 2407.04997 constrained decoding 修不了选错工具](https://arxiv.org/pdf/2407.04997)

## 相关本机文件（绝对路径）
- `/Users/wanglei/Library/Python/3.13/lib/python/site-packages/mlx_lm/tuner/trainer.py`（default_loss:75-88, iterate_batches:91-159）
- `/Users/wanglei/Library/Python/3.13/lib/python/site-packages/mlx_lm/tuner/datasets.py`（ChatDataset.process:57-77）
- `/Users/wanglei/Library/Python/3.13/lib/python/site-packages/mlx_lm/tuner/utils.py`（build_schedule:18-35, #2617 bug 现场）
- `/Users/wanglei/workspace/MAformac/Core/Training/C5LoRATraining.swift`（C5MaskOffsetFixture:308-350, renderToolCall:897, discoveryFindings:1125-1129）
- 本机模型模板：`~/.cache/huggingface/hub/models--mlx-community--Qwen3-1.7B-4bit/snapshots/3b1b1768.../tokenizer_config.json`（4116 字符，含 enable_thinking 分支）

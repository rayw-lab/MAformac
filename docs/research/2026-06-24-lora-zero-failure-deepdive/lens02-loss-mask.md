# L02 — Loss Mask 工程 + token 级验证（一手档）

> 维度：只管【算哪些 token 的 loss】，不碰 template（归 L03）。结论：mask 层【不是】0/34 的根因，但能制造一种特定 0/34 变体（多轮漏训）。本路是 P1 验证门 + retrain-c5 数据规则弹药，非 P0 阻断器。
> as-of 2026-06-24 | 本机 mlx-lm 0.31.1 / 32GB RAM（hw.memsize 34359738368）/ mlx-lm-lora 未装

## 0. TL;DR（核心结论）

1. **mlx-lm 0.31.1 的 loss mask = 单 offset 连续前缀掩码**（`tuner/trainer.py:81-85`：`mask = (steps>=lengths[:,0:1]) AND (steps<=lengths[:,1:])`）。物理上**只能掩一段连续前缀**，无法跳过中间 assistant 轮。
2. **C5 当前样本全是单 assistant 轮**（system+user+assistant，实测 80/80 行 0 个 >1 assistant）→ 单 offset 掩码**对它完全正确**（掩 system+user、训唯一 assistant）。
3. **0/34 不是 mask 错**——0/34 = generic-frame surface 爆炸 + B-frame 伪语法 content（A2 已改 D-domain 力挽）。mask 正确不阻断已发生的 0/34。
4. **mask 层能制造的 0/34 变体**：若 retrain-c5 引入多轮（失败重试 / 调用→readback→再问）而仍用 mlx-lm 单 offset → **只训最后一条 assistant、漏训中间工具调用轮 → toolCalls=[] 塌缩**。
5. **Qwen3 无 `{% generation %}` 标签**（Qwen 团队拒绝合并），`return_assistant_tokens_mask` 全 0 → per-turn 真掩码在 stock Qwen3 上**根本不可用**。多轮唯一可行路 = **拆成多个单轮样本**（home-llm 在 axolotl 下不拆，mlx 下必拆）。
6. **MAformac 已有真 token 级验证器**（非 flag 假绿）：`c5_mask_offset_fixture.py` 镜像 mlx-lm `ChatDataset.process`，逐样本断言 trained span 以 `<tool_call>`/`NO_TOOL` 起、不含 user/system/think marker、offset>0。

## 1. mlx-lm 掩码机制（本机源码逐行）

### 1.1 `ChatDataset.process`（datasets.py:57-77）

```python
def process(self, d):
    messages = d[self.chat_key]
    tokens = self.tokenizer.apply_chat_template(messages, tools=tools, return_dict=False)
    if self.mask_prompt:
        add_generation_prompt = messages[-1].get("role") == "assistant"
        offset = len(self.tokenizer.apply_chat_template(
            messages[:-1], tools=tools,
            add_generation_prompt=add_generation_prompt, return_dict=False))
        return (tokens, offset)      # ← 单个 offset
    else:
        return (tokens, 0)
```

**关键**：offset = `messages[:-1]` 渲染后的 token 长度。**只考虑「最后一条消息」之前的全部当 prompt**。多轮（user→asst→tool→user→asst）时，倒数第二条 asst 也被算进 `messages[:-1]` = 被掩掉。

### 1.2 `default_loss`（trainer.py:75-85）

```python
def default_loss(model, batch, lengths):
    inputs = batch[:, :-1]; targets = batch[:, 1:]
    logits = model(inputs)
    steps = mx.arange(1, targets.shape[1] + 1)
    mask = mx.logical_and(steps >= lengths[:, 0:1], steps <= lengths[:, 1:])  # ← 单连续区间
    ce = nn.losses.cross_entropy(logits, targets) * mask
    ntoks = mask.sum()
```

`lengths[:,0]` = offset（start），`lengths[:,1]` = total length（end）。mask = **一个连续区间 [offset, length]**。**数学上无法表达「跳过中间一段」**——这就是 mlx-lm 不能做多轮 per-turn 掩码的物理原因。

### 1.3 `iterate_batches`（trainer.py:131-159）

`batch` 解包成 `(tokens, offsets)`，`lengths = zip(offsets, lengths)` → `(offset, length)` 二元组传给 loss。确认：单 offset 一路传到底。⚠️ NaN 陷阱（mlx 社区实证）：mask 必须只在 loss 的 boolean mask 做，**input token id 必须保留真值**；把非 assistant token 置零会 val_loss=NaN。

## 2. C5 实况（本机实测，决定单 offset 是否够用）

### 2.1 样本结构 = 单 assistant 轮

```
mlx-data/train.jsonl:        80 行, 0 个 >1 assistant, 80 个 >2 messages
samples/c5-training-samples: 88 行, 0 个 >1 assistant, 88 个 >2 messages
```

`>2 messages` 是因为有 system，但 **assistant 只有 1 条** → 单 offset 正确覆盖。

实样本（脱敏后结构）：
```
system:    你是 MAformac 离线 mock 车控演示助手。控制路径只输出 tool_call 包裹或 NO_TOOL。
user:      device=ac_cooling_mode; primitive=set_mode; slots=...; 请按这个语义执行   ← B-frame 伪语法
assistant: \n\n<tool_call>{"arguments":{"action_primitive":"set_mode",...}}            ← raw tool_call 文本
tools:     [3 个]
```

→ 单 offset 掩 system+user、训 assistant（含 `<tool_call>{json}`）。**机制正确**。

### 2.2 `C5MaskingFlags` 是数据增广不是 loss 掩码（关键澄清，防 claim-vs-reality 同坑）

`masking: {argument_name, argument_value, function_name, train_on_turn}`（C5LoRATraining.swift:2569-2573）：
- `function_name/argument_name` = 有 distractor 注入
- `argument_value` = value 增广（didAugment）
- `train_on_turn` = `maskingStage != .smokeOnly`（**纯元数据**）

🔴 **`train_on_turn` 这个 flag 与 home-llm 的同名字段【语义不同】**：home-llm 的 train_on_turn 经 axolotl 真做 per-turn loss 掩码；C5 的只是元数据。**看 flag=true 推断「每轮都训了」= 派生表征当一手**，loss 掩码完全由 mlx-lm 单 offset 承担，与此 flag 无关。

## 3. token 级验证器（已在场，非 flag 假绿）

`c5_mask_offset_fixture.py:85-123` 镜像 mlx-lm `ChatDataset.process`，逐 probe 样本：
```python
full_tokens   = apply_chat_template(messages, tools)
prompt_tokens = apply_chat_template(messages[:-1], tools, add_generation_prompt=True)
offset = len(prompt_tokens)
trained_text = decode(full_tokens[offset:])
# 断言：
#  - stripped.startswith('<tool_call>' or 'NO_TOOL')        ← user→asst 边界对齐
#  - no '<|im_start|>user' / '\nuser\n'                     ← 不漏 user token
#  - no '<|im_start|>system' / '\nsystem\n'                 ← 不漏 system token
#  - no '<think>'/'</think>'                                ← 期望无 thinking block
#  - offset>0, len>offset, trained_ids 非空                 ← 非空非越界
# fail → exit 65
```
这是**真 token 级 artifact**（路径+digest 可复验），接入 C5LoRATraining.swift:2155 `offsetArtifactAuthority` hardFailures。lesson #27 记载早期 `usesTrainingTokenizerPatch=true` 曾只压告警没 token 证据=假绿，**已修成同路径 artifact**。

## 4. home-llm train_on_turn 完整代码链路（本地 ref-repos 实读）

- `data/generate_data.py:23` `create_assistant_turn(..., train_on_turn=True)` 默认。
- `:542` **失败样本首轮坏调用 `train_on_turn=False`**（不训错调用，防学错）。
- `:616-690` system/user/tool 轮全 `train_on_turn=False`。
- `:639` assistant 轮 `turn.get("train_on_turn", True)`。
- `data/utils.py:243-247` `AssistantTurn` TypedDict 含 `train_on_turn: bool`。
- `train/README.md:94` **axolotl `message_field_training: train_on_turn` 消费此字段**；:97 `roles_to_train: [assistant]` 备选。

🔴 **关键**：home-llm 自己**不做掩码**，只在数据里标 `train_on_turn`，真掩码由 **axolotl 在 trainer 层做 per-turn**。**mlx-lm 无对应消费机制**。→ 迁移 home-llm 多轮配方到 mlx 必须**拆样本**（每个该训的 assistant 轮拆成独立单轮样本）。

## 5. Qwen3 模板缺 `{% generation %}`（per-turn 掩码不可用的根因）

- transformers PR #30650 引入 `return_assistant_tokens_mask`，依赖 chat template 的 `{% generation %}`/`{% endgeneration %}` 标签标记 assistant 段。
- **Qwen3 默认模板无此标签** → `return_assistant_tokens_mask` 返回**全 0 mask**。
- 社区给 Qwen3-8B/4B/0.6B 提 PR 加标签，**Qwen 团队拒绝合并**（discussions #10/#14），理由：掩码是 context-dependent 决策（RFT 留 user / 掩 thinking / SFT 留 system），不该写死进 tokenizer。
- → **stock Qwen3-1.7B 上 per-turn 真掩码根本不可用**。C5 走单 offset 是**唯一可行路径**，不是疏忽。

## 6. 假想验证（MAformac 真实场景）

**场景**：mlx-lm 0.31.1 单 offset `--mask-prompt` + Qwen3-1.7B+LoRA + D-domain 562 intent + 端侧 8GB + rank16Mainline。

**预测**：对【当前单轮样本】= 正常工作，offset 验证器坐实 assistant span 真被训练；**不是 0/34 根因也不复制 0/34**。

**依据**：①本机实读 trainer.py 单连续前缀掩码，对 system+user+assistant 正好掩 system+user 训 assistant；②实测样本全单轮无中间轮可漏；③fixture 已 token 级核（lesson #27 修过假绿）。D-domain 化后 assistant content 变自然中文+具名工具调用，掩码机制不变。

**失败模式（mask 层能造的 0/34）**：
- **①多轮陷阱**：retrain-c5 若引入失败重试/readback 多轮 → mlx-lm 单 offset 只训最后一条 → 漏训工具调用轮 → toolCalls=[] 塌缩 = 0/34。
- **②NaN 陷阱**：自己写 per-turn mask 用「非 assistant token 置零」实现 → mlx 社区实证 val_loss=NaN（input 必须保留真 token id，掩码只在 loss 的 boolean mask 做）。
- **③Qwen3 模板陷阱**：误用 `return_assistant_tokens_mask` 在 Qwen3 上 → 全 0 mask = 静默退化成全算/全不算。

**结论**：保持单轮 → better than 不验证（有 offset 验证器）；引入多轮且不拆样本 → worse（复制 0/34）。**建议 retrain-c5 多轮显式拆单轮样本 + 生产前 print 一条 decode trained-span 肉眼核**。

## 7. Pre-mortem 三分类

**Tigers**：
1. 多轮样本 + 单 offset → 漏训中间工具调用轮 → 0/34 复制。【核：grep role==assistant 计数，>1 且未拆 → BLOCK】
2. 自定义 per-turn mask 用 zero-input 实现 → NaN。【核：smoke run 看 val_loss finite；input 保留真 token id】
3. offset 验证器不验中间混入；D-domain 后 fixture:54 expected_start='<tool_call>' 可能失效。【核：fixture:68 已断言 messages[-1]==assistant；retrain-c5 同步更新 expected_start；加 N 条 decode 肉眼核】

**Paper-tigers**：
1. 「mlx-lm 不支持多轮掩码=必须换 trainer」→ 对单轮非缺陷，多轮可拆样本绕过，不必换。
2. 「trainOnTurn=true=loss 掩码正确」→ 是数据增广元数据非 loss 掩码，必看 offset 验证器 artifact。
3. 「Qwen3 无 {% generation %} → 没法正确 SFT 掩码」→ 单轮用单 offset 完全正确，不需要 {% generation %}。

**Elephants**：
1. D-domain 化后 `c5_mask_offset_fixture.py:54` 的 `expected_start='<tool_call>'` 可能失效（D-domain 具名工具调用格式可能不再字面 `<tool_call>` 起）→ retrain-c5 需更新 fixture expected_start，否则验证器对新格式假绿/假红。掩码机制（单 offset）不变但 trained span 内容语义变了。
2. fixture:104 断言 trained span **不含 `<think>`** = 期望 enable_thinking=False。若样本渲染时未关 thinking → trained span 含 `<think>` → fixture 持续红，**根因在数据不在 mask**。retrain-c5 必确认 enable_thinking=False 渲染。
3. 本路是【验证门】不是【阻断器】——offset 验证器证明「assistant span 被正确训练」，证明不了「模型会输出工具调用」（C6 行为评测，DEFERRED）。把 mask 验证当 0/34 防护是过度归因；mask 正确是**必要非充分**。真 P0 防护在 train/eval surface 同源（A2 已做）+ generic frame 否决（A2 已做）。

## 8. must_answer 5 条

1. **prevents_0_34**：no（部分）——mask 不是主 0/34 根因；但能防一种 mask-induced 0/34 变体（多轮漏训），靠 offset 验证器（已在场）+ 多轮拆样本规则。
2. **vs_rank16mainline**：support——rank16Mainline 用单 offset --mask-prompt，对 C5 单轮样本正确；本路给配方加「保持单轮 / 多轮必拆」数据约束。
3. **requires_a2_surface_change**：no——纯训练数据/trainer 层。唯一级联：D-domain 后 fixture expected_start 需更新（retrain-c5 范畴，非 A2 surface change）。
4. **introduces_deferred**：yes（部分）——结论指向 retrain-c5（DEFERRED）的两条数据规则（多轮拆单轮 / enable_thinking=False），作为 OpenSpec task gate 弹药，不现在 retrain。
5. **priority_self**：P1（验证门，非 P0 阻断器）。

## 9. adopt/adapt/drop 映射

| 来源 | 发现 | 处置 |
|---|---|---|
| mlx-lm 0.31.1 单 offset | datasets.py:57-77 + trainer.py:75-85 | **adopt**（C5 已用，单轮正确，保持） |
| c5_mask_offset_fixture.py | token 级 trained-span 验证 | **adopt + adapt**（D-domain 后更新 expected_start；加 decode 肉眼核） |
| home-llm train_on_turn=False（失败首轮） | generate_data.py:542 防学错调用 | **adapt**（mlx 无 per-turn → 拆样本或 drop 失败重试结构，错误恢复类纳入与否待 grill） |
| Qwen3 {% generation %} per-turn | 模板不支持 | **drop**（stock Qwen3 不可用；多轮拆样本替代） |
| 非 assistant token 置零做 mask | NaN 风险 | **drop**（绝不 zero input id） |

## 10. 数字溯源（防编造）

- mlx-lm 0.31.1（pip show + `__version__`，本机）/ 32GB RAM（sysctl hw.memsize）/ mlx-lm-lora 未装（pip show not found）—— 本机实测。
- C5 样本 80/80、88/88 单 assistant 轮 —— 本机 python 实跑统计。
- repo 活跃度（gh 本机核 2026-06-24）：mlx-lm 6018★ 2026-06-12 / mlx-lm-lora 384★ 2026-06-16 / home-llm 1364★ 2026-06-11 / mlx-examples #1313 closed 2025-02-28。
- file:line 全本机实读。
- external_claims（transformers PR #30650 / Qwen discussions #10/#14 编号、{% generation %} 拒绝合并）来自 WebSearch 转述，未本机核 PR/discussion 编号 → 已入 external_claims 待主线程 gh/WebFetch 核。
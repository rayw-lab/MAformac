# Lens 7: mlx 栈现状 + LoRA/端侧代码组织 best practice + 坑（服务 MAformac C5 训练 mlx-lm 本机 + 端侧 mlx-swift）

# mlx 栈现状 + LoRA/端侧代码组织 best practice + 坑（MAformac C5 训练 + 端侧）

> finder: mlx 栈 finder（github-first，本机坐实 + ≥10 联网搜证）。核于 2026-06-22。
> 服务对象：MAformac C5（本机 Python mlx-lm 训练 Qwen3-1.7B + LoRA）+ 端侧（mlx-swift 推理）。

## 1. 本机事实坐实（不凭印象）

| 项 | 实测值 | 源 |
|---|---|---|
| C5LoRATraining.swift 行数 | **2481 行**（单文件，CLAUDE coding-style 上限 800） | `wc -l Core/Training/C5LoRATraining.swift` |
| 真训练循环 | `Tools/C5TrainingCLI/c5_mlx_train_loop.py` **616 行**（Python 执行器） | `wc -l` |
| C5 CLI 编排 | `Tools/C5TrainingCLI/main.swift` 31KB | `ls -la` |
| 主 Package.swift mlx 依赖 | **无**（swift-tools 6.0，iOS17/macOS14；训练委托 Python，无 MLXLLM product） | `cat Package.swift` |
| 端侧 mlx 依赖（spike-e3） | mlx-swift **0.31.4**（rev dc43e62）+ mlx-swift-lm **3.31.3**（rev 1c05248） | `dev/spike-e3/Package.resolved` + `Package.swift:14` |
| runtime import MLX | 仅 `dev/spike-e3/Sources/SpikeE3/main.swift:4-6`（Core/Features 零依赖） | `grep import MLX` |

**架构结论**：MAformac 训练栈（Python mlx-lm 本机）与推理栈（mlx-swift 端侧 spike-e3）**两套解耦**。C5LoRATraining.swift 2481 行不是训练循环本身，是数据门/选样/契约/parity/receipt 编排层；真梯度更新在 616 行 Python。

## 2. mlx 全栈近2月版本 + 活跃度（github-first，pushedAt<60天全部通过）

| repo | 角色 | 最新 release/tag | 发布日 | pushedAt | star | MAformac pin |
|---|---|---|---|---|---|---|
| **ml-explore/mlx-lm** | C5 本机训练后端（Python） | v0.31.3 | 2026-04-22 | 2026-06-12 | 6006 | （Python 侧，spike 未 pin） |
| **ml-explore/mlx-swift** | 端侧 array API | 0.31.4 | 2026-06-01 | 2026-06-17 | 1932 | **0.31.4 ✅ 已最新** |
| **ml-explore/mlx-swift-lm** | 端侧 LLM/VLM 库（3.x 拆出） | tag 3.31.3 | commit 2026-06-21 | 2026-06-21 | 679 | **3.31.3 ✅ 已最新** |
| ml-explore/mlx-swift-examples | 端侧示例（LoRATrainingExample/LLMEval） | — | — | 2026-06-15 | 2610 | — |
| ml-explore/mlx（C++ core） | 底层 | v0.31.2 | 2026-04-22 | — | — | — |

源：`gh api repos/ml-explore/{mlx-lm,mlx-swift,mlx-swift-lm,mlx-swift-examples}` releases/tags/commits，核于 2026-06-22。
- mlx-lm v0.31.3 highlights = 大量 bugfix + thread-local generation stream（配 mlx v0.31.2）；含多个 tool-call parser 修复（Gemma4/Mistral 函数名解析、并行 tool call）。
- ⚠️ **elephant**：mlx-swift-lm 已从 mlx-swift-examples **拆为独立 3.x 大版本**（解耦 tokenizer/downloader 包，引入 breaking change）。MAformac spike-e3 已用 3.31.3——升级时注意这是 3.x API。
- **结论：MAformac 端侧 pin（0.31.4 / 3.31.3）= 当前最新，无需追版本；训练侧 Python mlx-lm 建议锁 v0.31.3。**

## 3. LoRA 训练代码组织 best practice（业内 vs MAformac 单文件 2481 行）

**官方 mlx-lm 把 LoRA 训练拆成 `tuner/` 八文件**（`gh api .../contents/mlx_lm/tuner`）：
```
__init__.py  callbacks.py  datasets.py  dora.py  lora.py  losses.py  trainer.py  utils.py
```
- `trainer.py` 单文件约 12.5KB（训练循环 + checkpoint + eval）
- `lora.py`/`dora.py` = adapter 注入；`losses.py` = loss + mask；`datasets.py` = jsonl 加载；`callbacks.py` = W&B/SwanLab 报告

**对照 MAformac C5LoRATraining.swift 单文件 2481 行**（违 coding-style「200-400 典型/800 max」）。建议按 mlx-lm 八分法思路拆：
- 数据门（DataGate validator）/ 分层选样（stratifiedSelection）/ 受约束数据增广（distractor/抠槽/逆规整）/ endpoint parity / receipt 各成独立文件。
- 真训练循环已正确外置 Python（616 行 c5_mlx_train_loop.py）——这点对，保持。

## 4. 端侧 FC/tool-call 范式 + 受限解码（GBNF 缺位的替代）★对 MAformac 最高价值

### 4a. Qwen3 端侧 FC 格式（mlx-swift-lm ToolCallFormat.swift，WebFetch 核源码）
枚举 11 种：`json / lfm2 / xmlFunction / glm4 / gemma / gemma4 / kimiK2 / minimaxM2 / mistral / llama3`
- **base Qwen3 → `.json`**：`<tool_call>{"name":"func","arguments":{...}}</tool_call>`
- `qwen3_5` / `qwen3_next`（前缀匹配）→ `.xmlFunction`：`<function=name><parameter=key>value</parameter></function>`
- **MAformac 训 Qwen3-1.7B → 走 `.json` 格式（非 xmlFunction）**，UserInput(chat:tools:) 传 schema，handle `.toolCall` from `AsyncStream<Generation>`。

### 4b. 受限解码（GBNF 替代）= mlx-swift-structured ★现成肩膀
- **petrukha-ivan/mlx-swift-structured**（74★，pushedAt 2026-04-06，created 2025-09）= **XGrammar 的 Swift 绑定**
- 兼容 MLXLM generate API（grammar 作额外参数）+ FoundationModels `@Generable` schema 导出 JSON + `GrammarMaskedLogitProcessor` 注入 `TokenIterator`
- 上游 XGrammar 官方带 Swift API；复杂嵌套 schema 准确率 **97.1% vs Outlines 76.4%**（Qwen2.5-32B GitHub issues，arxiv 2411.15100）
- **= MAformac『具名工具受限解码』（范式翻案 paradigm-tool-surface §拆判定面+受限解码）的现成实现**。⚠️ star 偏低（74）需 pre-mortem 实跑验，但 XGrammar 上游成熟、puts 100% 结构正确。

## 5. mlx LoRA 训练近2月坑（pre-mortem 三分类）

### 🐯 tiger（明确威胁，带验证清单）
1. **LR 过冲发散**：arxiv 2602.06204（2026-02）实证『超最优 LR **2× 即发散**，Qwen2.5-3B-Instruct 尤甚』+『最优 LR 与 rank 无关（**改 rank 救不了 NaN**）』。**与 MAformac 自测 2e-4(iter80=32)→1e-4(iter30=1.069) 完全同源**。验证：①峰值 LR 守 1e-4 ②不靠调 rank 救 ③grad-clip 实跑非声称。
2. **NaN loss 跨大小模型**：issue#361（gpt-oss-20b 从 iter10 全 NaN）/ OpenELM-270m（val 算得出 3.977 但 train 全 NaN）；论文『5 LR 跨 3 数量级全不收敛、初始梯度范数>5e7、data-regime driven not hyperparameter』。验证：NaN 先查**数据**（重复/异常/空 completion）再降 LR。
3. **OOM**：官方 5 escape hatch=`--grad-checkpoint`(重算换显存) + `--num-layers`减层(16→8/4) + `--batch-size 1` + `--grad-accumulation-steps N` + 截短序列。mlx-tune（1318★，2026-05-31）实证 grad-checkpoint 全 trainer 接入后 48GB Mac 不再 OOM。

### 🪙 paper-tiger（看似威胁，给证据安全）
4. **tool-call format 推断漏匹配静默吞 toolCall**：issue#259（Gemma4 infer 漏匹配，模型吐合法 tool-call 文本但 Swift toolCalls 为空、全落 .chunk）。对 Qwen3 是 paper-tiger——源码 base Qwen3→.json 推断路径存在、v3.31.3 正常，**但须端侧实跑确认 1.7B model_type 前缀命中 .json 解析**（非静默落 chunk）。

### 🐘 elephant（没人提但该提）
5. **`--mask-prompt` 历史『是否真生效』疑虑**：issue#1313（flag 不被接受 / YAML mask_prompt:true 无感知效果）。**直接呼应 MAformac C5 masking 假绿坑**（声称 masking_coverage 但未实跑验证，claim-vs-reality 铁律2）。验证：masking 须 **dump tokens 实证 loss mask 真生效**，不信 flag/metadata。
6. **mlx-swift-lm 3.x breaking change**（解耦 tokenizer/downloader）+ 上游趋势：GRPO trainer in-progress（#1420/#1421，2026-06-21）/ speculative decoding telemetry + memory gating（#314）/ Swift model conversion API（#318）。端侧若要榨延迟可后续吸收投机解码；GRPO 对 demo 非必需（SFT/LoRA 够）。

## 6. vs 现状 baseline 对比

| 维度 | MAformac 现状 | 业内/最新 | 判定 |
|---|---|---|---|
| 端侧 mlx pin | 0.31.4 / 3.31.3 | = 当前最新 | **better/对齐**，无需追 |
| 训练后端 | Python mlx-lm + 616 行 loop | 官方 mlx-lm tuner 八文件 | 训练外置对；编排层 2481 行需拆 |
| 受限解码 | GBNF 缺位（已识别） | mlx-swift-structured(XGrammar) | **unknown→可 adopt**（star 低需验） |
| LR 配方 | 1e-4 已修发散 | arxiv 实证 1e-4 区间正确 | **better**（与最新研究一致） |
| masking 验证 | 假绿坑（已知） | issue#1313 同类疑虑 | worse→须 dump token 实证 |

## 7. 给主线程 grill 弹药
- **G-mlx-1**：C5LoRATraining.swift 2481 行单文件是否按 mlx-lm tuner 八分法拆？⭐拆（数据门/选样/增广/parity/receipt），量化=单文件 3x 超 800 上限。
- **G-mlx-2**：端侧具名工具受限解码 adopt mlx-swift-structured(XGrammar swift) 还是手搓？⭐adopt（XGrammar 上游 97.1% 准确率成熟）+ pre-mortem 实跑验 74★ 绑定层。量化 vs 手搓 logit mask = 省自研 + 100% 结构正确。
- **G-mlx-3**：Qwen3-1.7B 端侧 FC 走 .json 格式，须端侧实跑确认 model_type 命中 .json 解析（防 issue#259 类静默吞）。这是行为探测非配置检查（claim-vs-reality 铁律2）。
- **G-mlx-4**：masking 须 dump token 实证 loss mask（issue#1313 + MAformac 假绿坑双证），不信 flag/metadata。

## 8. 全部搜证源清单（≥10）
1. gh api ml-explore/mlx-lm releases（v0.31.3, 2026-04-22, 6006★, pushed 2026-06-12）
2. gh api ml-explore/mlx-swift releases（0.31.4, 2026-06-01, 1932★）
3. gh api ml-explore/mlx-swift-lm tags+commits（3.31.3, commit 2026-06-21, 679★）
4. gh api ml-explore/mlx-swift-examples（2610★, pushed 2026-06-15, LoRATrainingExample）
5. gh api ml-explore/mlx-lm/contents/mlx_lm/tuner（8 文件结构）
6. gh api ml-explore/mlx-lm/releases/tags/v0.31.3（changelog body）
7. WebFetch mlx-swift-lm/ToolCallFormat.swift（11 枚举, Qwen3 映射）
8. gh api petrukha-ivan/mlx-swift-structured（74★, pushed 2026-04-06）
9. WebSearch mlx-lm LoRA OOM grad-checkpoint（官方 LORA.md 5 escape hatch）
10. WebSearch mlx-lm NaN loss（issue#361, OpenELM-270m, arxiv data-regime）
11. WebSearch LoRA LR divergence（arxiv 2602.06204 2× 过冲发散 Qwen）
12. WebSearch mlx-swift tool calling Qwen3 grammar（issue#259 Gemma4 静默吞）
13. WebSearch XGrammar/Outlines 对比（arxiv 2411.15100 97.1% vs 76.4%）
14. WebSearch --mask-prompt（issue#1313, LORA.md mask_prompt directive）
15. 本机：Package.swift / wc -l / Package.resolved / grep import MLX
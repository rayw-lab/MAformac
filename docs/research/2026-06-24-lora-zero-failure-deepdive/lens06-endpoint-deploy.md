# L06 端侧部署 + 受限解码 + parser 三层防御 — 一手调研档

> 维度：端侧部署 + 受限解码 + parser 三层防御。**边界：调研并行验证方案，不做端侧实装（deferred）。** Phase0 pre-propose decision-pack，纯搜证 + 假想验证，落 docs/research。
> 调研日：2026-06-24。本机 scout + 2 clone 深读（mlx-swift-structured / home-llm）+ 13 次联网搜证。

## 0. 核心结论（TL;DR）

**这路最大翻案：grill SSOT 的「端侧无 GBNF -> 死路」假设过时。** XGrammar 官方已 ship Swift Package（Swift Package Index 标 iOS/macOS/visionOS/watchOS 支持，1756★、2 天前 push），且有现成 Swift 封装 `mlx-swift-structured`（74★/21fork，集成 XGrammar C++ 子模块，iOS17+，自带 Qwen3 tool-call grammar），实测受限解码 <10% 慢 -> **端侧约束解码【技术可行】，是 escape_hatch 不是死路**（非 GBNF 而是 XGrammar EBNF/JSONSchema/regex 走 logit mask）。

**但这路【不能提前阻止 0/34】（自评 P1）**：0/34 根因是训练/语义不对齐（generic frame 判定面爆炸 + masking 假删 + train/eval surface 异源），约束解码只保证 JSON 语法/枚举合法、**保证不了选对工具/填对槽**（whitelist 强制 valid 非 correct，South Korea→North Korea 真实陷阱）。约束解码甚至可能把 0/34 从空数组变成被迫合法但语义错，**更隐蔽**。

## 1. 本机 scout 实况（坐实，非猜）

| 项 | 实况 |
|---|---|
| 本机内存 | 34GB（Mac，**注意**：这是 dev 机，**不是** iPhone 8GB 目标）|
| mlx-lm | 0.31.1（Python，dev/训练侧）|
| mlx | 0.31.2 |
| **mlx-swift-structured** | **已 clone** `ref-repos/mlx-swift-structured`（关键发现）|
| mlx-swift-examples | 已 clone |
| home-llm gbnf | `output.gbnf` + `json.gbnf`（llama.cpp 路线）|
| 项目 Package.swift | 存在，**未引** mlx-swift / mlx-swift-structured / XGrammar（端侧栈未集成）|
| **xgrammar 子模块** | **本机 clone 为空（0 文件）** -> 未能本地 compile-test（见 elephant）|

## 2. 受限解码端侧可行性（核心翻案）

### 2.1 XGrammar 官方 Swift Package（最强证据）
- Swift Package Index `mlc-ai/xgrammar`：v0.2.2/main，**支持 iOS/macOS/visionOS/watchOS**，Swift 6.0-6.3，**零依赖**，Apache2.0。
- gh：1756★，pushedAt **2026-06-22**（2 天前，极活跃）。
- 含义：受限解码引擎在 Apple 平台**官方支持**，不只是 hobby 封装。iOS arm64 buildability 大幅 de-risk。
- source: https://swiftpackageindex.com/mlc-ai/xgrammar 2026-06-24

### 2.2 mlx-swift-structured（现成封装，可直 adopt/参考）
- `Package.swift:8` -> `.macOS(.v14), .iOS(.v17)`（**不需 iOS26**，`@Generable` 才需 26；raw Grammar/JSONSchema/EBNF/regex iOS17+ 即可）。
- 集成 XGrammar C++ 子模块（`.gitmodules` -> mlc-ai/xgrammar），经 SwiftPM `cxxSettings`/`gnucxx17` 编译，**无 CMake**（纯 SwiftPM build path）。
- `GrammarMaskedLogitProcessor.swift`：接 mlx-swift `LogitProcessor` 协议，`process(logits:)` 加 grammar mask（0 / -inf），`didSample` 推进 matcher。**这就是端侧约束解码的落点**。
- README 有**现成 Qwen3 tool-call grammar**：`TriggeredTagsFormat(triggers:["<tool_call>"])` 每工具挂 `TagFormat(begin:"<tool_call>\n{\"name\":\"\(tool.name)\", \"arguments\": ", end:"}\n</tool_call>"){ JSONSchemaFormat(schema:tool.parameters) }` -> **直接对应 MAformac D-domain 具名工具**。
- 74★/21fork/created 2025-09-20/pushedAt 2026-04-06（~2.5mo，单作者无 CI，battle-test 风险见 tiger/elephant）。
- source: 本机 clone + gh repo view 2026-06-24

### 2.3 性能 overhead（作者实测，<10%）
| Model | Vocab | Plain tok/s | Constrained tok/s |
|---|---|---|---|
| Qwen3 4B | 151,936 | 100 | 94（6.0% 慢）|
| Llama3.2 1B | 128,256 | 295 | 268（9.2% 慢）|
| Gemma3 270M | 262,144 | 485 | 444（8.5% 慢）|

1.7B 类预期 ~7-9% 慢 -> 39.5->~36 tok/s，**现场无感**。且 XGrammar 对**固定 D-domain schema**（每次同 grammar）缓存命中 = near-zero overhead（非每请求 unique schema 最坏情况，那种 llguidance 更优）。
- source: README Experiments + https://blog.mlc.ai/2026/05/04/xgrammar-2 2026-06-24

## 3. 端侧硬约束（lens1 维度，8GB 红线）

### 3.1 Qwen3-1.7B-4bit 实测（iPhone17Pro 12GB）
- 权重 **984MB**、TTFT **360ms**（短 prompt ~47tok）、decode **39.5 tok/s**（p50）。
- 4bit vs 更高 bit：decode 快 21-27%、内存省 30%，**但 TTFT 不变**（prefill compute-bound 非 bandwidth-bound）。
- source: https://rickytakkar.com/blog_russet_mlx_benchmark.html 2026-06-24

### 3.2 🔴 8GB iPhone jetsam（目标设备，必真机 spike）
- per-process 上限**设备相关、Apple 不公布、必 runtime `os_proc_available_memory()` 查**。
- iPhone14(6GB) 实测硬上限 ~2.05GB（134272 pages x 16384）；jetsam 通常 50-67% total RAM。
- `com.apple.developer.kernel.increased-memory-limit` 只是 Boolean 请求、**App Store 构建常不生效**、必须按标准上限设计。
- 1.7B-4bit(~1GB 权重 + KV + runtime) **能装**（~1.5-2GB << 4GB），但 KV cache 随上下文涨 + iPhone TPS 随上下文退化（iPad 不退）+ 竞争 app 抢内存 = **必须真机 spike，不能 Mac 推断**。
- source: Apple entitlement doc + rickytakkar benchmark 2026-06-24

### 3.3 TTFT 冷启动 + KV 预热
- MLX **必须全 prefill 才出首 token**，cold TTFT 随上下文 O(n) 涨。
- KV cache 预热/持久化 -> warm TTFT 近乎平（Llama warm 260-431ms across 1K-32K vs cold 47.6s@16K）。Rapid-MLX sub-100ms cached TTFT。
- MAformac 短单轮命令 -> 冷 TTFT 360ms 已够；**系统 prompt + 工具 schema 前缀做 KV cache** 是关键杠杆（每次复用前缀，home-llm KV 预热=冷启动解药 已记录）。
- source: https://v-chandra.github.io/on-device-llms + arxiv 2603.04428 2026-06-24

## 4. 量化对 LoRA 质量影响

- QLoRA NF4+double-quant 实证 **match BF16**（原论文，大模型最稳）；4bit 是 2026 端侧默认（1-3% 掉点）。
- 🔴 **小模型比大模型对量化更敏感**，function calling 要严格格式 -> 用 **rank16-64**（rank16Mainline 符合；function-calling 研究用 rank16/alpha32 = scale2，MAformac scale20 更激进，已 A2 实证零碰）。
- 部署若掉点：fuse 时 `--de-quantize`，或退 16bit LoRA（小模型内存够）/ LoftQ。
- **MAformac 路径**：训练 16bit LoRA（守 rank16Mainline）-> 部署 4bit 量化基座 + LoRA。部署时 4bit 量化对 1.7B 小模型是真质量风险，**端侧 4bit vs Mac 16bit 评测差异必须 spike 对账**（不是 Mac 评测绿就端侧绿）。
- source: QLoRA(arxiv 2305.14314) + on-device-llms 2026 2026-06-24

## 5. 三层防御解析（home-llm 实证，可直抄）

`utils.py:495-620` 链路（A2 D-domain 具名工具利好 enforce）：
1. **第一层 JSON**：标准 `json_loads`。
2. **第二层 repair**：`fuzzy_json.loads`（修引号/逗号/括号/截断）。
3. **第三层格式 fallback**：gemma 正则 `call:(?P<name>\w+){(?P<args>.+)}` + `<escape>` 抠值。
4. **双 schema 校验**：base（name/arguments）+ home_llm service schema。
5. **三重 whitelist enforce**：domain x service x arg（解析层强制）。
6. **单位归一化**：brightness 0-1->0-255、rgb 字符串->list。
7. **兜底**：`MalformedToolCallException`。

**2026 工业共识**（与 home-llm 一致）：约束解码(prevention) -> json_repair/bracket-repair(local recovery) -> LLM re-prompt -> default+alert。**两条防线都留**——约束解码只保证语法不保证语义；whitelist 强制 valid 非 correct。schema 保持 <30 字段/<3 嵌套（30 字段 4 层嵌套 Outlines FSM 构建 >60s 超时）。
- source: utils.py + https://collinwilkins.com/articles/structured-output + json_repair(mangiucugna) 2026-06-24

## 6. LoRA 端侧加载（fuse vs 动态）

- mlx-swift `load(into:)` 把 Linear->LoRALinear 动态换、**iOS 推理可行**（LoRA 训练 example 仅 macOS，推理 iOS OK）。
- **MAformac 建议 fuse**：单中文 LoRA、不需 hot-swap -> 单 artifact + 零 adapter overhead。4bit fuse 若掉点 `--de-quantize`。
- 多 persona/频更才动态 hot-swap（MAformac 不需）。
- source: mlx-swift-examples + MLX LoRA docs 2026-06-24

## 7. 假想验证（1.7B+LoRA+D-domain 562+8GB+mlx+受限解码）

**预测：技术可行、性能可接受，但不解决 0/34 类语义塌缩。**

失败模式（按概率）：
- **A.[最隐蔽] 约束解码掩盖语义错误**：模型本想塌缩（无信心），被 grammar 强制必须吐合法 tool_call -> 吐了语义错的。比 0/34 空数组更难 catch。修法：grammar **必须含拒识/no-op/unsupported 合法分支**。
- **B.[P1] tokenizer 异源**：端 XGrammar mask vocab != 训练 mask tokenizer != eval -> mask 错位。修法：render_parity_diff=0 门扩端侧 tokenizer parity 三方对齐。
- **C.[P1] 8GB 真机 KV+竞争 app**：多轮 DialogueState + 背景 app -> jetsam kill。必真机 spike。
- **D.[P2] XGrammar iOS arm64 编译**：官方 Swift Package 已 de-risk，但封装层单作者无 CI + 本机子模块空（未本地 compile-test）-> 优先直接用 XGrammar 官方 Swift Package（mlc-ai/xgrammar）。
- **E.[P2] grammar 构建延迟**：保持 D-domain schema 浅平（A2 已 <=10 工具/<=5 参数符合）。

## 8. Pre-mortem 三分类

**Tiger（明确威胁 + 验证清单）**：
1. 约束解码掩盖语义塌缩（强制合法但选错）-> grammar 加拒识分支 + C6 加被迫合法但语义错轴 + 业务校验层。
2. 端侧 tokenizer 异源（0/34 异源根因端侧镜像）-> TokenizerInfo.vocab hash diff + endpoint_decode_spike 逐 token 对账。
3. 8GB jetsam（设备相关不可控）-> 真机 os_proc_available_memory() + 竞争压力下 3 轮 DialogueState + 别依赖 entitlement。

**Paper-tiger（看似威胁实际安全 + 证据）**：
1. 端侧无受限解码死路 -> XGrammar 官方 Swift Package + mlx-swift-structured 封装，**可行 escape_hatch**。
2. 4bit 量化严重掉点 -> QLoRA NF4 match BF16 + rank16-64 + --de-quantize 兜底，**成熟方案**。
3. 约束解码 overhead 太大 -> <10% + 固定 schema 缓存 near-zero，**现场无感**。

**Elephant（没人提但该提）**：
1. 本机 xgrammar 子模块空（0 文件）-> **未能本地 compile-test**，iOS 可编译 100% 靠 web 证据，必须 spike 坐实。
2. **约束解码 vs 拒识张力**：demo 灵魂是安全拒识/澄清（0/34 教训 7 个 demo-critical 含拒识），但约束解码默认逼模型必吐合法 tool_call -> 不显式含拒识分支会**阉割拒识能力**。grammar 设计必须解决。
3. home-llm 单发旋钮真实默认 **3** 不是 0（const.py:179），MEMORY 记的 MAX_ITER=0 是 demo override 非 home-llm 默认（纠错）。
4. **目标设备口径漂移**：grill 写 iPhone15PM-8GB，但所有 benchmark 实测在 iPhone17Pro-12GB。8GB vs 12GB jetsam 上限差近 2x，**拿 12GB 数据当 8GB 证据 = 用别的环境数据冒充（lens1 红线）**，8GB 必独立 spike。

## 9. must_answer 5 条

1. **prevents_0_34: no** — 约束解码是事后防线非病因解药；可能把 0/34 变更隐蔽的合法但错。真正阻止 0/34 = A2 D-domain surface（已做）+ 训练/masking 正确（别路）。
2. **vs_rank16mainline: support** — 正交不碰训练配方；tokenizer parity 门保护训练产物端侧一致性；escape_hatch 给端侧无 GBNF 假设 better 出路。
3. **requires_a2_surface_change: no** — A2 D-domain 具名工具**利好**约束解码（具名工具名 + 每工具 JSONSchema 可直编进 grammar），验证 A2 方向对，不要求改。
4. **introduces_deferred: yes 不越界** — 本路是端侧并行验证 spike 弹药（grill C5 拆的 endpoint_decode_spike + render_parity_diff=0），不做端侧实装；产出供 retrain-c5/golden-run propose 用，符合 Phase0 边界。
5. **priority_self: P1** — 不能提前阻止 0/34（P0 是 surface/训练别路），但是端侧炸场风险（serial 炸场链）的关键并行验证 + 0/34 的端侧防线（tokenizer parity + 拒识分支 + 三层解析）。

## 10. 给 propose 的 actionable 弹药

- **endpoint_decode_spike 任务化**（grill C5 已拆）：优先直用 XGrammar 官方 Swift Package（mlc-ai/xgrammar），mlx-swift-structured 作参考实现。验收：端侧约束解码跑通 + overhead 实测 + 8GB 真机内存。
- **render_parity_diff=0 门扩端侧**：训练 mask tokenizer == eval == 端 XGrammar TokenizerInfo.vocab，三方 hash diff。
- **grammar 必含拒识/no-op/unsupported 合法分支**（防阉割拒识，约束解码 vs demo 安全门张力的解）。
- **三层防御解析直抄 home-llm**（utils.py:495-620）+ whitelist 解析层 enforce（A2 D-domain 利好）+ 与约束解码两条防线都留。
- **8GB 真机 spike 与 retrain-c5 并行启动**（post-roadmap audit 建议，防 serial 炸场：train云->C6 Mac评->才发现端侧全炸）。
- **iOS 真机采购/借测** 是前置阻塞（grill 标 🔴 无 target iOS device）。
- 落点：`docs/research/`（不碰 runtime contracts/）。
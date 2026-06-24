# L18 · Voice/ASR Side Memo — 未来输入分布风险清单（不设计 voice 实装）

> **路定位**：side memo（P2），**不进 retrain 拍板**，1-2 页未来输入分布风险。明确 acceptance = **no voice execution**：本路只产出『C5 数据要不要含音近/disfluency 变体』的 hypothesis 弹药 + 风险清单，**绝不实装 voice/ASR、绝不拍生产配比、绝不改 contracts/**。
> **as-of** 2026-06-24。每条带 source URL/file:line + 日期。

## §0 一句话核心结论

**D14 已 amend（ASR primary：sherpa+Paraformer → 系统 SFSpeechRecognizer on-device 离线）** 是本路最 load-bearing 的发现——它**改变了 C5 LoRA 数据需要吸收的 ASR 错误分布**，并因系统 ASR **砍了 custom vocabulary**（无热词偏置）而**把全部错字鲁棒压力下移到下游 LoRA + 拼音 fuzzy 一层**。文献一致支持『同音/拼音音近增广（~10% 逐字）+ 留 held-out 干净集』作为 C5 数据可选支柱；**home-llm（最大肩膀）实测零 ASR 增广**，是 vs home-llm 的真实 gap。本路 **P2、support rank16Mainline、不要求 A2 surface change、不能提前阻止 0/34**。

## §1 D14 ASR-primary flip：错误分布漂移（load-bearing）

- **决策现状**：`docs/grill-tournament/grill-decisions-master.md:204`（§4.6）+ handoff 2026-06-23 U1-U31：**ASR = 系统 SFSpeechRecognizer（demo 取巧，on-device 离线）为主 + sherpa-onnx/WhisperKit fallback（不砍要开发）+ ASRBackend 抽象保留**。
- **旧档冲突**：`docs/research/2026-06-19-asr-alignment-research.md:34-36` 当时以 **sherpa+Paraformer 为主候选**，其 §2(c) 拼音/音近增广方案是基于 **Paraformer 错误特征** 写的。
- **漂移含义（文献证）**：『as the ASR model updates, the error distribution drifts making it even harder for NLU models to recover』（[arXiv 2103.13610 / Amazon Science Towards NLU Robustness at Scale]，WebSearch 2026-06-24）。→ **系统 SFSpeechRecognizer 的中文错误分布 ≠ Paraformer 的**，旧增广假设需重锚到系统 ASR 实际错误（**未自采，诚实缺口**）。
- **vs baseline**：vs 旧 asr-research = **oppose**（增广目标引擎变了）；vs rank16Mainline = **escape_hatch**（只影响数据内容，配方零碰）。

## §2 文献：同音/拼音增广 + held-out 干净集（C11-C12 hypothesis 弹药）

- **homophone substitution 最佳**：Li et al. 2018 比较四种 ASR-noise 策略，**homophone-based substitution 效果最佳**（via [arXiv 2006.05635 Data Augmentation for Dialog Models]，WebSearch 2026-06-24）。
- **可执行噪声比**：**MSMT-FN**（中文营销音频分类）用 **8000 字同音字典 + 逐字 ~10% 概率替换同音字** 模拟中文 ASR 错误（[arXiv 2511.11006]）；noise-augmentation 专利给**增广比 1:0.5–1:5 + 强制保持原 intent label**（US 11538457/11972755）。
- **LLM 驱动可控音近增广**：Speak&Spell / EPA 在 4 种 ASR 环境（低准/咖啡馆+交通噪声/paraphrase/高准）下生成贴真实分布的音近错误（[arXiv 2409.06263]）。
- **数据增广 > 推理纠错**：『data augmentation does not modify architecture or introduce additional latency at inference』（arXiv 2103.13610）——契合端侧 8GB/mlx + D14『不串 post-ASR LLM 纠错』红线。
- **映射 MAformac**：C11-C12 数据配比 hypothesis = 『10% 逐字同音替换 + 增广:干净比例（待 spike）+ held-out 干净集』，与 `asr-alignment-research.md:46` §2(c) 和 roadmap **T7 锚**（留 held-out 干净集防记噪声）一致。
- **vs baseline**：vs home-llm = **better**（home-llm 无音近增广）；vs 现状 = unknown（10% 是文献值，MAformac 封闭车控词表 + D-domain 具名工具下最优比未实测）。

## §3 home-llm 实测：零 ASR/phonetic 增广（vs home-llm 真实 gap）

- **本机 grep 坐实**（2026-06-24）：`ref-repos/home-llm/data/{generate_data.py,synthesize.py}` 全仓 `asr/noisy/phonetic/pinyin/typo/disfluency` **0 命中**；唯一相关 `synthesize.py:297` 对 status_request 造 `bad_device`（截断/变异/转位/加前后缀，明确『**avoid simple typos**』）——是**设备名错认**非**语音同音字**。
- **结论**：home-llm 训练全是 **clean templated 文本**。**照搬 home-llm 配方 = 对 ASR 同音错字（空调→空跳）零鲁棒**。这是 MAformac 需在 home-llm 之上补的一层（home-llm 没有的）。
- **vs baseline**：vs home-llm = 本路是对 home-llm 的**补强 gap**（home-llm worse，无 ASR 鲁棒数据）。

## §4 口语 disfluency（嗯/那个）退化 intent（独立第二 hypothesis）

- **中文 benchmark 齐备**：**RealTalk-CN**（[arXiv 2508.10015]）定义 4 类中文 disfluency（语气词拖音/重复/自我修正/犹豫）+ 标注子集；**VocalBench-DF**（[arXiv 2510.15406]）测 speech-LLM 对 filler/重复/停顿鲁棒；**From Disfluency Detection to Intent**（[arXiv 2209.08359]）实证 disfluency 降 intent+slot 性能。（WebSearch 2026-06-24）
- **映射**：demo 现场口语必含 disfluency（『嗯那个把空调调一下』）。D-domain 具名工具 + LoRA **若训了 disfluency 变体** 可吸收，否则慢路误调用/弃权。
- **关键**：disfluency 与 ASR 错字是**两类不同噪声**（文献分开处理），C11-C12 目前只想到音近——**disfluency 变体是独立的第二个 hypothesis**，retrain-c5 propose 时需分开拍。
- **vs baseline**：vs rank16Mainline = **support**（数据内容扩充，超参零碰）；vs home-llm = **better**（home-llm 模板无 disfluency）。

## §5 系统 ASR 短板放大下游依赖（D14 amend 时未记录的 elephant）

- **on-device 显式劣于 server**：Apple 文档 `supportsOnDeviceRecognition` 明示『on-device 不如 server 准、无持续学习』（WebSearch 2026-06-24）。
- **无自定义词表**：iOS26 SpeechAnalyzer **连 SFSpeechRecognizer 的 custom vocabulary 都砍了**（[forasoft.com 2026 playbook] / [vocai.net]）——**车控领域词无法在 ASR 端注入偏置**。
- **单语 per-recording**：中英混说码切换非一等公民（SpeechAnalyzer 单语）。
- **放大含义**：旧 sherpa 路线有 **transducer 热词** 当第一道闸（把『空调』拉回），**系统 ASR 路线这道闸没了** → C5 音近增广从『nice-to-have』升级为『端 ASR 听懂率的**唯一兜底**』。**这个含义在 D14 amend 时没被显式记录，是真 load-bearing elephant。**
- **vs baseline**：vs 旧 sherpa 路线 = **worse**（错字护城河更弱）→ 反向**加重** C5 音近增广必要性。

## §6 D14『端侧不跑 post-ASR LLM 纠错』红线再证实

- **文献再证**：端侧 LLM 纠错反伤意图（SLURP WER 25.6%→32.4%，把『打开空调』纠成别的更灾难，`asr-research.md:50` T2 引 arXiv 2305.13512）；ASR-EC Benchmark（[arXiv 2412.03075]）评 LLM 中文 ASR 纠错显示小模型纠错不可靠。
- **正确路线**：增广进训练（LoRA 提前见过音近变体）→ 推理零纠错负担，与 D14『拼音 fuzzy + 封闭词表 + LoRA 音近训 + 置信澄清』四层叠加一致。
- **vs baseline**：vs 现状 = **support**（巩固已锁红线，无需改任何决策）。

## §7 工具/repo 活跃度交叉验证（fallback 路真实性）

- **sherpa-onnx 极活跃**：1.13.3 发布 **2026-06-15**，2026 年多月一发，iOS Swift + Paraformer offline 路径属实（[github.com/k2-fsa/sherpa-onnx] + PyPI，WebSearch 2026-06-24）。→ **fallback 路（sherpa）真实可用，不阻塞**。

## §8 假想验证（1.7B+LoRA+D-domain 562 intent+端侧 8GB+mlx 真实场景）

**假想**：ASR 同音错字（空调→空跳、调到26度→条到26度）+ disfluency（『嗯那个把空调调一下』）当 D-domain 562 intent 真实输入，跑会怎样？

1. **不加增广（照搬 home-llm clean 模板）** → **端侧 demo 口语 + 系统 ASR 错字击穿入口**：未见过的同音替换 → 1.7B 走慢路误调用/弃权（toolCalls 空），听懂率掉。依据：home-llm grep 零增广 + 文献 clean-trained NLU 对错字脆弱。**失败模式 = 现场一句口语/被错认 → 入口打烂，惊艳感崩。**（中等信心）
2. **加 10% 逐字同音增广 + held-out 干净集 + D-domain 具名工具** → **显著改善**：D-domain 具名工具收窄判定面（比 generic frame 容错），LoRA 见过音近变体能把『空跳』映回空调具名工具。依据：MSMT-FN 实证 + A2 已证 D-domain 是力挽 0/34 关键（判定面收窄对噪声更鲁棒）。
3. **风险：增广比过高/不留干净集** → 训成『记噪声』，干净输入退化（T7 锚）。修法 = 比例守 1:0.5–1:5 + held-out 干净集守门（复用 T7，不新增治理）。
4. **端侧兼容性** → 音近增广是**训练时数据扩充**，推理零负担（不串纠错，符合 D14 + 端侧约束），不引入端侧性能风险。

**净结论**：本路是**未来数据配比 hypothesis 弹药**，不是 0/34 根因修复。系统 ASR flip 使『C5 是否含音近/disfluency 变体』从可选变 demo 听懂率 load-bearing——但**这是 retrain-c5 propose 阶段才拍的 C11-C12 配比 hypothesis**（待 spike 自采系统 ASR 实际错误分布后定比例），**Phase 0 不拍死生产值、不实装 voice**。

## §9 pre-mortem 三分类

**tigers（带验证清单）**
- T1：D14 flip 后音近增广若仍按 Paraformer 错误特征造 → 与系统 ASR 实际错误不匹配。**验证**：retrain-c5 propose 前自采系统 SFSpeechRecognizer zh-CN on-device 对 10 族 562 intent 的实际错字 pair，用真实分布锚定，不照搬 Paraformer；spike 用近场 clean 实音频实测，不用 AISHELL 朗读数。
- T2：增广比过高/不留 held-out 干净集 → LoRA 记噪声，干净准确率退化（T7 坑）。**验证**：C11-C12 守 1:0.5–1:5 + held-out 干净集进 C6，干净集不退化作放行门（复用 T7 不新增治理）。

**paper-tigers（看似威胁实际安全 + 证据）**
- 『端侧中文 ASR 不够准，demo 因 ASR 崩』：magnet demo 条件 = 近场+无噪声 → 近场 clean 系统 ASR 中文可用（asr-research P1）；本路不靠提升 ASR 靠下游吸收；ASR 非 demo 灵魂（E5）。
- 『需端侧 post-ASR LLM 纠错修错字』：D14 红线 + T2 证伪（纠错反伤）；靠训练增广，推理零纠错。

**elephants（没人提但该提）**
- E1：C5 contract（3990 行 33 字段）**完全无 ASR-error 字段**——音近/disfluency 增广是 retrain-c5 **数据合成层**合成（contract 派生层之外），**不改 contract schema**（避免 A2 surface change）。voice 鲁棒进**数据合成配方**，**绝不进 runtime contracts/**（Phase 0 边界：治理落 docs/research）。
- E2：系统 SFSpeechRecognizer 砍 custom vocabulary（连 SpeechAnalyzer 也无）→ ASR 端**无法**热词拉回车控词，全部错字鲁棒压力**下移到下游 LoRA+拼音 fuzzy**。旧 sherpa 有 transducer 热词第一道闸，系统 ASR 没了 → C5 音近增广从『nice-to-have』升级为**端 ASR 听懂率唯一兜底**。**D14 amend 未记录此含义，是真 load-bearing elephant。**
- E3：disfluency 与 ASR 错字是**两类不同噪声**（RealTalk-CN 4 类 vs homophone substitution）。C11-C12 现只想到音近，**disfluency 变体是独立第二 hypothesis**，retrain-c5 propose 需分开拍，别合并成『一个 ASR 鲁棒增广』囫囵带过。

## §10 must_answer 5 答

1. **prevents_0_34 = no**：0/34 根因 = train/eval surface 异源 + generic frame 判定面爆炸 + masking 446 假删（A2 已修），与 ASR 输入分布**正交**（clean 文本喂的就全塌）。本路是输入分布鲁棒性维度，不能也不声称能阻止 0/34。
2. **vs_rank16mainline = support**：音近/disfluency 增广是**数据内容**扩充，rank16 超参（rank16/scale20/LR1e-4/adamw/epochs=3）零碰；A2 PR#3 已证配方与 ASR 引擎无关。
3. **requires_a2_surface_change = no**：增广进 retrain-c5 数据合成配方（训练样本层），不改 D-domain 具名工具 surface、不改 contract schema、不改 IR（device×action）。A2 已完成 surface 零触碰。
4. **introduces_deferred = yes（明确声明）**：引用 voice/ASR（C7）+ retrain-c5（C5 数据生成）+ 受限解码 vendor 等 DEFERRED 主题——但**不实装任何 deferred 工作**，只产出风险清单 + hypothesis 弹药供未来 retrain-c5 propose。越界仅限『引用 deferred 主题做风险提示』，符合 acceptance『no voice execution』+ Phase 0『纯搜证不执行训练/数据/voice』。
5. **priority_self = P2**：不能提前阻止 0/34（正交根因），是未来输入分布风险，喂 C11-C12 数据配比 hypothesis，不阻塞 A2 主线（A2 = code-only surface 对齐）。

## §11 一手锚 + source 清单

**一手锚**：D14（`grill-decisions-master.md:204` §4.6 系统 ASR 主+sherpa/Whisper fallback+ASRBackend 抽象）/ `docs/research/2026-06-19-asr-alignment-research.md`（旧 sherpa+Paraformer + 跨厂商二审 + §2 对齐四层）/ `contracts/semantic-function-contract.jsonl`（3990 行 33 字段，无 ASR 字段）/ `ref-repos/home-llm/data/synthesize.py:297`（bad_device 非音近）。

**外部 source（2026-06-24 WebSearch，精确数字/arxiv ID 待主线程抽样核，见 external_claims）**：
- ASR robustness 综述：arXiv 2103.13610 / Amazon Science Towards NLU Robustness at Scale
- 同音增广：MSMT-FN arXiv 2511.11006（8000 字典/10%）/ Li 2018 via arXiv 2006.05635 / Speak&Spell EPA arXiv 2409.06263 / noise-aug 比例 US 专利 11538457·11972755
- disfluency：RealTalk-CN arXiv 2508.10015 / VocalBench-DF arXiv 2510.15406 / From Disfluency to Intent arXiv 2209.08359
- 纠错反伤：ASR-EC arXiv 2412.03075 / SLURP arXiv 2305.13512（本仓既有）
- 系统 ASR 短板：Apple Developer supportsOnDeviceRecognition / forasoft.com 2026 iOS speech playbook / vocai.net SpeechAnalyzer
- fallback 活跃度：github.com/k2-fsa/sherpa-onnx + PyPI（1.13.3 / 2026-06-15）
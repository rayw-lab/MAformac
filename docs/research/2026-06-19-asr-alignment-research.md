# ASR 准确率 + 文本→语义/规则对齐 深度调研归档

> 缘起：磊哥强调 ① 语音识别准确率 ② 识别文本→语义+规则对齐，都很重要（ASR 错字/同音会击穿下游）。后补充条件「**对着手机近场说、无噪声**」。
> 调研：本地 5 篇某车厂一手料 + 2 路联网 subagent + 2 路 WebSearch（2026-06-19）。每条带 file:line / URL+年份。
> **🔴 核心反转：① demo ASR 别默认 Whisper（中文抗噪崩盘）→ sherpa-onnx + Paraformer/SenseVoice 中文主候选、WhisperKit fallback；② ASR 错字纠正不靠端侧再跑 LLM（五重坑）→ 靠拼音 fuzzy + 封闭词表归一化 + LoRA 音近训 + 置信门控澄清。**
>
> ## ⚠️ 跨厂商二审修正（2026-06-19，磊哥跨窗口核验 = Layer-2 catch，覆盖下方初稿）
> 大方向（sherpa+中文模型 > Whisper）成立，但抓到一个 **HIGH 假闭合**，修正如下（与下方 §2(a) 冲突时以本块为准）：
> 1. **🔴 热词 transducer-only**：sherpa-onnx hotwords **只支持 transducer 模型 + `modified_beam_search`**（[官方 hotwords docs](https://k2-fsa.github.io/sherpa/onnx/hotwords/index.html)）。**Paraformer-offline 不支持热词** → "Paraformer + sherpa 热词" 是**假闭合**。正确：热词 = **仅当选 sherpa transducer/Zipformer 模型时的可选门**；**Paraformer 主线靠 拼音 fuzzy + 封闭词表归一化 + LoRA 音近训 + 置信澄清**（不依赖热词）。
> 2. **口径分开**：FireRed 公开集 **CER**（AISHELL1 Whisper 5.14 / Paraformer 1.68，[FireRedASR](https://huggingface.co/FireRedTeam/FireRedASR-LLM-L)）与 Fun-ASR 行业集 **WER**（复杂背景 Whisper 32.57 / Paraformer-v2 15.19）是**不同指标/集**，别混成一个口径过度论证。
> 3. **✅ D14 改法（磊哥拍板）**：不写死 `WhisperKit primary` → **`ASRBackend` 抽象 + sherpa-onnx 中文模型作 C7 主候选 + WhisperKit `large-v3-v20240930_626MB` fallback/baseline**；C7 rebase 把热词拆成 **transducer-only 可选门**，不硬绑 Paraformer+sherpa hotwords。sherpa iOS/Swift 路径属实（[官方 iOS build](https://k2-fsa.github.io/sherpa/onnx/ios/build-sherpa-onnx-swift.html)）。
> 4. **真机未实测**：iPhone 延迟/包体/电量必自采，别只信论文数（进 spike gate）。
> 5. **elephant**：ASR 非 demo 灵魂（LoRA 泛化 + C6 评测才是）；ASR 只需别把"空调/空跳/控条"入口打烂。
> 6. **拼音方向成立**：中文 ASR 替换错误突出，拼音纠错有价值（[Pinyin ASR EC arXiv 2409.13262](https://arxiv.org/html/2409.13262v1)）。

## §1 ASR 准确率

### 一手座舱验收金数字（某车厂量产门，最权威）`座舱/奇瑞各平台语音验收指标总表.md`
- 字准 MT-011：L1≥96/L2≥93/L3≥78%（`:154`）；句准 MT-010：L1≥93/L2≥90%（`:153`）。**句准≠字准必分开验**（`:59`）→ demo 验收看 task/意图级，不纠单字 WER。
- **int4 多意图 MT-021：2-5 意图掉到 80%**（`:164`）= 端侧量化真实代价。
- 唤醒响应≤150ms（MT-009）/ 本地识别响应最后字上屏≤700ms（MT-024 `:167`）。
- 拒识率 90% / 误拒率 5%（MT-020 `:163`）。

### 端侧中文 CER 现实区间（联网）
| 引擎 | 中文 CER(clean) | 大小 | iOS | 来源 |
|---|---|---|---|---|
| **Paraformer-Large** | **1.68%** | 0.22B | sherpa-onnx 官方 | arXiv 2206.08317 |
| **SenseVoice-Small** | 2.96% | <1GB int8 | sherpa-onnx 官方 | arXiv 2407.04051 |
| Whisper large-v3 | 5.14%(CommonVoice 12.8%) | 1.55B/~10GB | WhisperKit ANE | Ruoqi Jin 2026 |

**🔴 噪声退化（Fun-ASR 真实噪声集，错误率）**：复杂背景 Whisper-v3 **32.57%** vs Paraformer-v2 15.19% vs Fun-ASR 11.29%（arXiv 2509.12508，2025）。一手佐证：车内噪声 WER 升 20-30%（`ASR_enriched:198`）；朗读 vs 真实差 3-4 倍。
> ⚠️ 但磊哥 demo 条件=**对着手机近场、无噪声** → 噪声 tiger(T1) 对 demo 大幅缓解；近场 clean 下 Whisper 5.14% 也"能用"，但 Paraformer 1.68% 仍更优 + 更小 + iOS 原生。

### 选型 ⭐ sherpa-onnx + Paraformer-Large(主)/SenseVoice-Small int8(轻量)
四理由：① 中文准（1.68% vs Whisper 5.14%，3x）② 抗噪（Whisper 复杂背景 32.57% 直接淘汰做主力）③ **iOS 可行**（sherpa-onnx 唯一覆盖 iOS+Swift+CPU-only ONNX，官方 Swift app + 最新 int8 模型 `paraformer-zh-int8-2025-10-07`/`sense-voice-int8-2025-09-09`，符合"Python 库零进 iOS"铁律）④ 支持热词 + **N-best**（WhisperKit 只 1-best）。
> **⚠️ 与 CLAUDE D14（锁 WhisperKit）冲突 → 需磊哥拍**：研究强烈建议改 sherpa-onnx+Paraformer。WhisperKit 仅"强依赖 ANE 能效 + Swift 一等公民 + 0.4GB 最省"且接受中文/抗噪劣势时做 baseline 逃生口。

## §2 文本→语义/规则对齐（磊哥第二关切，更重要）

**总纲**：ASR 错字不靠端侧再跑 LLM 纠（五重坑 T2/T3/T11），靠四层叠加；验收以 task accuracy 为准非字面 WER。

**(a) 热词偏置（解码期把领域词拉回来）**：sherpa-onnx transducer + `hotwords.txt`（`空调 :2.0`）+ `modeling-unit=cjkchar+bpe` + **`decodingMethod=modified_beam_search`**（默认 greedy 静默忽略热词=T8 坑）。效果：FST 浅融合 B-WER 降 6.9%，深度偏置 29.2%（arXiv 2407.10303）。**不用 WhisperKit promptTokens 做主偏置**（11 数据集 6 个 WER 反升 + large-v3 返空 bug，arXiv 2502.11572）。

**(b) 拼音 fuzzy（规则期吸收错字）**：磊哥"空调→空跳靠 kong tiao 命中"假设**被文献证实**——中文 ASR 错误 80%+ 是替换错误，一无调拼音音节平均映射 >60 汉字（PY-GEC arXiv 2409.13262）。**端侧 Swift 零依赖拿拼音**：Apple 原生 `CFStringTransform(s, nil, kCFStringTransformMandarinLatin, false)` + `kCFStringTransformStripDiacritics` 去声调 →"kong tiao"，无网络。匹配用归一化拼音 Levenshtein（DISC：丢声调+替换权重2，arXiv 2412.12863）。**⚠️ 必配第二维约束**（语义槽位/封闭词表，防"弃权"当"期权"误召回，T6 arXiv 2605.16896）；**车控词表封闭=最大护城河**。

**(c) LoRA 训 ASR-noisy + 置信门控**：LoRA 训「干净+音近增强 noisy 双流」（AR-NLU 思想，非纯噪声非随机扰动；音近用 PiDA 替换；留 held-out 干净集防记噪声）。与 C5 LoRA 计划契合，比串纠错 LLM 轻。置信门控：低置信/N-best 接近→澄清反问（对齐一手拒识"模型不确定→追问"`拒识体系:187`："打开"缺宾语→"打开空调还是车窗"）。

## §3 tiger / paper-tiger / elephant（精选）
- **T1 HIGH** Whisper 车内噪声崩盘（5.14%→32.57%）— demo 近场缓解，但选型仍避。
- **T2 HIGH** 端侧 LLM 纠错反伤意图（SLURP WER 25.6%→32.4%，把"打开空调"纠错成别的更灾难，arXiv 2305.13512）— **端侧不引入 post-ASR LLM 纠错**。
- **T3 HIGH** 小模型零样本偏置/纠错崩（0.25B 偏置 WER~97%）→ 偏置必须解码层 FST 外挂，不靠模型自身。
- **T6 HIGH** 拼音单维误召回 → 必配封闭词表第二维。
- **T7 HIGH** int4 多意图 90%→80% + LoRA 全喂噪声损通用 → 留 held-out 干净集。
- **T9 MED** Whisper 跑 sherpa-onnx 中文 CER 暴崩 0.81 → 别用 sherpa 跑 Whisper，用它跑原生 Paraformer/SenseVoice。
- **P1** "端侧中文 ASR 不够准"不成立（Paraformer 1.68% 近场够）。**P2** "WER 升=意图错"不成立（测 task accuracy，句准≠字准）。**P3** DIMSIM/pypinyin 进 iOS 不必要（Apple 原生 CFStringTransform 够）。
- **E1** WhisperKit 只 1-best（GER N-best 纠错招式失效）；sherpa-onnx modified_beam_search 能拿 N-best = 选 sherpa 隐藏第 5 理由。

## §4 进 spike 硬 gate
- [ ] 中文 ASR 用**带噪/近场实音频**实测 CER，不用 AISHELL 朗读数交差
- [ ] sherpa-onnx iOS **真机**实测 Paraformer/SenseVoice RTF/延迟/功耗（真机中文数搜不到，必自采）
- [ ] 热词偏置端到端跑通（transducer + modified_beam_search，否则 T8 静默失效）
- [ ] 拼音 fuzzy 封闭词表误召回率测（确认第二维生效，T6）
- [ ] 验收门用 task accuracy 非字面 WER（P2 + 一手句准≠字准）
- [ ] 端侧不引入 post-ASR LLM 纠错（T2/T3/T11 三坑叠加，1.7B 直接否决）

**诚实缺口**：WhisperKit 精确中文 CER 仅论文图未公布；"端侧 1.7B 实时 ASR 纠错"无直接 benchmark（推断）；"LoRA 在 ASR-noisy 训"基于 AR-NLU+遗忘证据推理无直接实证；置信阈值全行业示例值须真车控语音校准。

**一手文件**：`座舱/奇瑞各平台语音验收指标总表.md`、`座舱/ASR语音识别技术演进与车载部署全景[_enriched].md`、`科大讯飞降噪方案音频相关要求V1.6.md`、`唤醒词/唤醒率指标与麦克风布置规范.md`、`拒识/座舱拒识分类与分级体系.md`、`VAD/智能聆听动态VAD横向对比.md`（只读参考，不进仓，CLAUDE §6）。

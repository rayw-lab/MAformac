# MAformac 端侧 FC 小模型选型 2026 深扒综合报告

> 综合官产出(probe 式辩证综合)。汇 7 路深扒(Qwen 系 / Gemma·Llama / Phi·SmolLM·Ministral·Granite·MiniCPM·GLM-Edge / FC 专精 xLAM·Hammer·ToolACE / 端侧框架 mlx-swift·llama.cpp·MLC·CoreML / skill 巨人肩膀 / iPhone 8GB 端侧硬天花板)。
> 决策对象:**换某模型 vs 守 Qwen3-1.7B**。硬约束 = 纯端侧离线 macOS/iOS + iPhone 15 Pro Max(A17 Pro,**8GB RAM**,非 17 Pro 的 12GB)+ mlx-swift-lm 3.31.3 栈 + 中文车控 FC + 拒识(restraint)第一。
> 日期 2026-06-20。一手锚点全部 file:line / source_url 可溯源;没搜到的诚实标。

---

## 0. 一句话结论

**守 Qwen3-1.7B(诚实推荐 ⭐),不为「新」而换;唯一值得花一轮 P1-B spike 认真评估的「更新」候选是 LiquidAI LFM2.5-1.2B(2026-01,端侧更省更快),但它必须先实测「中文车控泛化 + 项目全集拒识 + mlx-swift 真机加载」三关全过才换,否则守 1.7B。** 三条核心理由:

1. **FC + 拒识双证据,1.7B 是同尺寸实测最强,且 restraint 正中本项目北极星。** 磊哥引用的 MikeVeerman tool-calling-benchmark Round3(本机 clone,20-run majority-vote)实测 `qwen3:1.7b=0.960` 全场冠军(Action 0.900 + Restraint 1.000 + 0 错调,**唯一**解出全部 3 道 hard restraint prompt P10/P11/P12);内部 P1-B spike `Qwen3.5-2B 8/11=72.7% 全面劣于 1.7B 9/11=81.8%`(roadmap-2026-06-20-from-c6-done.md:130)。换任何模型都是拿「restraint 已证冠军」去赌「未证实」。

2. **「新 ≠ 强」在本次深扒被反复证实,且换新撞三堵工程墙(架构端侧不成熟 / FC chat_template 损坏 / iPhone 8GB OOM)。** Qwen3.5/3.6 小线(GDN+VL)新但 tool-call chat_template 系统性损坏(ollama #14493 / QwenLM/Qwen3 #1831);Gemma4(2026-04 最新)在项目同版本 mlx-swift-lm 3.31.3 加载失败 + 受限解码 repetition collapse;真新的 Ministral-3-2512 / MiniCPM5-1B 端侧 restraint 都 < 1.7B 或零实测。发布日期新的模型在「端侧能跑 + FC/中文实测更强」上无一综合占优。

3. **零迁移成本 + 端侧链路已验证。** mlx-community/Qwen3-1.7B-4bit 本机已缓存、spike-e3 已实跑(3.31.3)、MLX-Outil(124★,Qwen3-1.7B + mlx-swift + iOS tool-call 完全同栈蓝本)实测可跑;且 P1-B spike 已事实上拍「模型已定 = 训 Qwen3-1.7B」(roadmap:130)。换模型 = 重新下载 + 量化 + 重测 chat_template + 重跑端侧 spike,纸面分不抵这套迁移 + 部署风险。

> **正面回应磊哥「1.7B 太老(2025-05)」**:Qwen 家族压根没出过 1.7B 的 2507/更新版(2507 只覆盖 4B/30B/235B,1.7B 被跳过)——「想要更新的 1.7B 同款」在 Qwen 内无解。要「新」只剩三条路:(A) 守原 1.7B(实测最优);(B) 跳到更大的 Qwen3-4B-Instruct-2507(2025-08,标准 dense,更吃 8GB RAM 且 restraint 未在题集证强);(C) 跨架构到 LFM2.5-1.2B(真新但中文 base 弱需 LoRA 补)。⭐ 默认 A,B/C 仅在 P1-B spike 实测综合过 1.7B 才升级。**「老」是心理诉求,「端侧不崩 + 听懂中文 + 拒识对」才是 demo 价值——这几维 1.7B 全维度仍最优。**

---

## 1. 候选总览表

> vs-1.7B 取值:better / mixed(各有胜场)/ worse / unknown(关键维度未证实)。淘汰原因列写硬出局点。confidence 标证据强度。

| 模型 | 尺寸/架构 | 发布 | FC benchmark(实测优先) | 中文 | mlx-swift 支持 | iPhone15PM-8GB 可行 | 热度/活跃 | vs-1.7B | 淘汰原因 / 备注 | conf | source |
|---|---|---|---|---|---|---|---|---|---|---|---|
| **Qwen3-1.7B**(基线) | 1.7B 标准 transformer | 2025-05 | **0.960** 本机 20-run 冠军(Action 0.900/Restraint 1.000/0 错调,唯一全 3 hard prompt) | 强(原生 CN) | ✅ 原生 + 本机缓存 + spike-e3 已跑 + MLX-Outil 蓝本 | ✅ 最安全(峰值 ~1.5-2.5GB << 8GB jetsam) | mlx 生态持续维护 | — | 守它(日期老是唯一缺点) | high | tool-calling-benchmark ROUND3_REPORT.md |
| **LFM2.5-1.2B-Instruct** ⭐备胎 | 1.2B hybrid(gated short-conv + 少量 GQA,**非 SSM 非 transformer**) | 2026-01 | **0.920** 本机 20-run 第2(Action 0.800/Restraint 1.000/0 错调,快 ~7x);IFEval 74.89% > 1.7B 73.98% | ⚠️ base support 弱(预训多语优先级 JP/AR/KR/ES/FR/DE,**中文未进优先级**) | ✅ 但需 LFM2 fix(PR #122 nested rope) | ✅✅ <1GB RAM,17Pro 60 tok/s **不热降**(越跑越快) | 2026-01 发布 + Liquid 持续迭代(5月出 8B-A1B) + day-1 MLX | **mixed** | 唯一真值得 spike;中文/全集拒识/真机加载未过 = 一票否决项 | high(端侧)/ medium(中文) | huggingface.co/LiquidAI/LFM2.5-1.2B-Instruct |
| Qwen3-4B-Instruct-2507 | 4B **标准 dense**(非 GDN 非 VL) | 2025-08 | 通用 FC 更强(distil labs 12 小模型排第1;edge BFCLv3 62.04% > 1.7B 55.49%,multi-turn 翻倍);**restraint 题集无可靠 20-run 分**(thinking 63s 被剔除) | 中文好(2507 系) | ✅ mlx-community 4bit 26K 下载/月(>1.7B) | ⚠️ 边界可行需硬化(权重 ~2.5GB,峰值 ~4-5GB+ 逼近 jetsam,需 entitlement + bounded KV) | 上游 5.5M 下载/月 + 881 likes,极活跃 | mixed | Qwen 家族唯一「新+标准架构」候选;更大更慢吃 RAM + restraint 未证强 → adapt 非 adopt | high(FC通用)/ medium(端侧8GB) | huggingface.co/Qwen/Qwen3-4B-Instruct-2507 |
| Qwen3.5-2B/0.8B/4B/9B | GDN(Gated DeltaNet)+ VL 多模 | 2026-02/03 | 内部 spike 8/11 < 1.7B 9/11;chat_template 空,**tool-call 模板系统损坏** | 强(原生 CN) | mlx-community 有,但 GDN 端侧成熟度未验 | 2B-4bit 可跑(17Pro 1279MB) | 最新但 FC issue 持续未闭合 | **worse** | **DROP**:chat_template parser 格式不匹配(Hermes-JSON vs 训练 XML),需 21-fix 补丁;多模态冗余权重;内部已实测劣 | high | ollama #14493 / QwenLM/Qwen3 #1831 |
| Qwen3.6 ≤4B dense | 仅 27B dense + 35B-A3B MoE | 2026-04 | N/A | — | 仅 35B 有 mlx | ❌ 无 ≤4B 尺寸 | 最新但无适配尺寸 | unknown | **DROP**:经多次核实 Qwen3.6 无 ≤4B 小 dense,全超 D38 天花板 | high | en.wikipedia.org/wiki/Qwen + Qwen3.6 #178 |
| Gemma 4 E2B/E4B | VLM + PLE + MatFormer(非标准) | 2026-04 | 官称 native FC,但 constrained-JSON **repetition collapse**(明确是相对 Gemma3 regression);E2B reasoning-off 62.3% unusable | 次于 Qwen(translated phrasing) | ❌ **项目同版本 mlx-swift-lm 3.31.3 PLE shape mismatch 加载失败** | E4B ~5GB 紧;但端侧根本起不来 | 2026-04 最热 | **worse** | **DROP**:三 HIGH(mlx 加载炸 + 受限解码 repetition + 需 reasoning 延迟 7-11x) | high | mlx-swift #389/#282 OPEN;vLLM #40080 |
| Gemma 3 4B | 标准 transformer(text+vision) | 2025-03 | FC 仅 2.0/5(gamemaker1,severe state mgmt issues) | 次于 Qwen | ✅ mlx-swift 老架构支持 | ✅ ~3.5-4.5GB | 被 Gemma4 supersede | **worse** | **DROP**:FC 2.0/5 + 比 1.7B 老 + 中文次 | high | gamemaker1/gemma3-function-calling-benchmarks |
| Gemma 3 1B | 标准 transformer | 2025-03 | 0.690 本机(Restraint 0.500 半失守);gamemaker1=0.5/5 | ❌ English-only | ⚠️ mlx-lm #502 多轮崩 | ✅ 0.5GB | 旧 | worse | **DROP**:English-only + FC 非功能 | high | ROUND3_REPORT.md / mlx-lm #502 |
| FunctionGemma 270M | Gemma3-270M + FC 专用 special-token | 2025-12 | 0.640 本机(完美 restraint+435ms 最快,但 hard prompt 落 keyword 陷阱);出厂 BFCL 58% | ❌ 无中文证据 | Gemma3 架构可量化,special-token 需自定义 parser | ✅ 125-288MB 最轻 | Google 官方,生态广 | worse | **DROP 主线**(无中文+非 dialogue+需自训);可作 L1 超轻 FC 旁路 side-experiment | high | ai.google.dev/gemma/docs/functiongemma |
| Llama 3.2 3B | 标准 transformer | 2024-10 | 0.660 本机(Action 0.900 但 **Restraint 0.000** 全乱调) | ❌ 中文非官方(8语无中文) | ✅ mlx-swift llama 架构 | ✅ ~3GB | ❌ 最旧 + 无 Llama4 小模型继任 | **worse** | **DROP**:Restraint 0.000(安全门灾难)+ 中文非官方 + 最老 | high | ROUND3_REPORT.md / meta-llama HF |
| Llama 3.2 1B | 标准 transformer | 2024-10 | 0.430 本机(近垫底);BFCL ~26% | ❌ 中文非官方 | ✅ | ✅ 极宽松 | ❌ 旧+停滞 | worse | **DROP**:FC 垫底 + 中文非官方 + 最老 | high | ROUND3_REPORT.md |
| Phi-4-mini | 3.8B 标准 dense + MoLoRA | 2025-02 | 0.780 本机(从 Round2 co-champion 跌第7;P12 70% 误调 get_weather WRONG) | 中等偏弱(4bit 进一步削) | ✅ mlx-community 4bit | ⚠️ ~3-4GB 较紧 | — | **worse** | **DROP**:restraint 0.780 << 0.960 + 中文中等 + 更吃 RAM + 比 1.7B 老 | high | ROUND3_REPORT.md:44 |
| SmolLM3-3B | 标准 transformer + NoPE | 2025-07 | 0.630 本机(P5 restraint 失守,P10/P11 miss) | ❌ 6 核心语不含中文 | ✅ zero-day MLX | ✅ ~3-4GB | — | **worse** | **DROP**:中文非支持语(致命)+ restraint 0.630 | high | ROUND3_REPORT.md:51 |
| Ministral-3-3B-2512 | 标准 dense + 视觉,原生 FC | **2025-12**(真新) | 0.800 本机(完美 restraint+0 错调,但 P10/P11/P12 三 hard 全 miss,Action 仅 0.500=过度保守) | 支持但不及 Qwen | ✅ mlx-community 4bit(~24天前上传) | ✅ ~3-4GB | 真新 + mlx 新鲜 | **worse** | **DROP**:真新但硬题不敢动(Action 0.500),demo「敢动+泛化」弱于 1.7B | high | ROUND3_REPORT.md:42 / mistral.ai/news/mistral-3 |
| IBM Granite 4.0 Nano(H-1B/350M) | hybrid-SSM(H版)/标准(非SSM版) | 2025-10 | ⚠️双面:官称 BFCL v3=54.8 > Qwen;但本机 restraint granite4:3b=0.520(P5/P9 双失守,Action 0.800 乱调) | ✅ 官方列中文(12语) | ✅ 官称 MLX 原生(H版 SSM iOS 需验) | ✅ 极易(1B/350M) | 真新 + Apache2.0 | **mixed** | **DROP**:「敢调但 judgment 差」陷阱候选(BFCL高≠拒识好);350M 可作超轻 fallback 探针 | high | huggingface.co/blog/ibm-granite/granite-4-nano / ROUND3_REPORT.md:57 |
| MiniCPM5-1B | 1B dense + XML tool parser | **2026-05**(真新) | BFCL v4=25.1%(benchlm,偏低);**无 restraint 实测** | ✅ 强(清华系,1B 触 7-8B 中文) | ⚠️ GGUF 官方;mlx-community 4bit 未确证;iOS 未证 | ✅(1B) | 最新 + OpenBMB 活跃 | **unknown** | **DROP 暂不进 spike**:中文是亮点但 FC/restraint/mlx-swift 三项未证实;若 LFM2.5 spike 失败可作「中文优先」第二探针 | medium | huggingface.co/openbmb/MiniCPM5-1B / benchlm.ai bfclV4 |
| GLM-Edge-1.5B/4B | GLM-4 衍生 dense | 2024末 | 无 edge 版 FC 文档,无 restraint 实测 | ✅ GLM 原生中英 | ❌ 无 mlx-community 转换 | ⚠️ 无 mlx 跑不了 | ❌ 2024 陈旧超 60 天门 | worse | **DROP**:无 mlx + 发布陈旧(超新鲜度硬约束)+ FC 未证实 | medium | github.com/zai-org/GLM-Edge |
| Nanbeige4.1-3B | 中文推理 SFT+RL | 2026初 | 0.800 本机(完美 restraint,但仅 **3 跑 preliminary**,三 hard 全 miss,延迟 22.8s) | ✅ 原生中文 | ❌ 无 mlx-community | ⚠️ 3B 无 mlx + 延迟 22.8s 灾难 | 社区请求加入 | worse | **DROP**:中文强但无 mlx + 延迟 22.8s + 仅 3 跑不可靠 | medium | ROUND3_REPORT.md:43 |
| xLAM-2-3b-fc-r | 3B 标准(Qwen2.5 base + FC 微调) | 2025-03 | BFCL 纸面 65.7% > 1.7B,但 **jdhodges 独立实测部署 15%**(custom JSON 数组格式经通用 parser 解不出) | 弱(FC 数据 English-only) | ❌ 无 mlx-community 4bit;不在 mlx-swift ToolCallFormat 白名单 | 理论可但部署破 | ❌ 停 2025-03 无 xLAM-3,stale | **mixed/worse** | **DROP**:mlx-swift 解析白名单不含 → silent fallback 部署 15% 崩;English-only;base 旧;CC-BY-NC | high | huggingface.co/Salesforce/xLAM-2-3b-fc-r |
| Hammer2.1-1.5b/3b | 标准(Qwen2.5-Coder + function-masking) | 2024-10 | restraint 理论强(function-masking),但 jdhodges Hammer2.1-7B 实测 20%(懂任务产不出格式) | 弱(English-only) | ❌ 只 litert(Android);不在 mlx-swift 白名单 | 理论可但部署破 | ❌ 停 Qwen2 系,stale | mixed/worse | **DROP 权重**(部署破);**function-masking 方法学已 adopt 入 C5** | high | huggingface.co/MadeAgents/Hammer2.1-1.5b |
| ToolACE-8B / LoopTool-8B | 8B 标准 | 2024 / 2025-11 | BFCL 91.41% / 74.93%(SOTA) | 一般/好但8B | 8B mlx 非主流 | ❌ 8B 超 D38 ≤4B 天花板,8GB 必崩 | — | unknown | **DROP 端侧**(8B 出局);**数据合成 / 闭环演化方法学 adopt 入 C5** | high | arxiv 2511.09148 |

> 端侧硬天花板结论(独立成段,见 §4):**8GB iPhone 15PM + mlx-swift 下 dense 模型上限 = ~2B**(1.7B/2B 安全,3B tight/risky,4B 在 MLX 下连 12GB 17Pro 都因 jetsam 炸,Ricky Takkar russet 实测)。这把 Qwen3-4B-2507 / Gemma3-4B / 所有 3B+ 压到「边界风险需硬化」档,把 ToolACE/LoopTool 8B 直接出局。

---

## 2. Top 3 候选深评(vs 1.7B 逐维 + 代价)

### 2.1 LFM2.5-1.2B-Instruct(⭐ 唯一值得 spike 的备胎,verdict=adapt)

| 维度 | LFM2.5-1.2B | Qwen3-1.7B | 判定 |
|---|---|---|---|
| FC restraint(本机 20-run) | 0.920(Action 0.800/Restraint 1.000/快 7x) | **0.960**(唯一全 3 hard prompt) | 1.7B 略胜 0.040,但 LFM2.5 完美 restraint |
| 中文车控 | ⚠️ base support 弱(多语优先级无中文),需 LoRA 大力补 | **强(原生 CN)** | **1.7B 胜(一票否决风险点)** |
| 端侧 8GB | **<1GB RAM,60 tok/s 不热降(越跑越快)** | ~1.5-2.5GB,2-3min 后热降 20-40% | **LFM2.5 胜** |
| mlx-swift | ✅ 但需 LFM2 fix(PR #122)+ LFM2.5 新变体未真机验 | ✅ spike-e3 已跑 + MLX-Outil 蓝本 | **1.7B 胜(成熟度)** |
| 活跃/新鲜 | **2026-01,比 1.7B 新 8 个月,Liquid 持续迭代** | 2025-05 | **LFM2.5 胜(正面回应「要新」)** |
| 架构 | hybrid(非 SSM),移植风险低于 GDN/PLE | 标准 transformer | 都可控 |

**代价分析**:换 LFM2.5 = (a) 一轮 P1-B spike 周期(中文 LoRA 后对比 + 全集拒识 + 真机加载);(b) mlx-swift 须升到含 LFM2 fix 的版本(脱离 spike-e3 锁定的 3.31.3);(c) 中文若 LoRA 后仍弱于 Qwen → 白做一轮回退。**净收益**:更省 RAM(8GB 上更安全)+ 快 7x + 不热降(连续 demo 友好)+ 真新。**净风险**:中文 base 弱是纯中文车控 demo 的硬伤,「FC 快 7x 救不了客户现场听不懂中文」。**结论:adapt——值得一轮 spike,但中文是一票否决,不过关守 1.7B。**(conf:端侧 high / 中文 medium)

### 2.2 Qwen3-4B-Instruct-2507(Qwen 家族唯一「新+标准架构」候选,verdict=adapt)

| 维度 | Qwen3-4B-2507 | Qwen3-1.7B | 判定 |
|---|---|---|---|
| FC 通用 | 更强(distil labs 排第1,multi-turn 翻倍,BFCLv3 62 > 55) | restraint 题集冠军 | 通用 4B 胜,**restraint 题集无可靠分** |
| 中文 | 好(2507) | 强(原生) | 约平/4B 略好 |
| 端侧 8GB | ⚠️ **边界风险**(权重 ~2.5GB,峰值 ~4-5GB+ 逼近 jetsam) | ✅ 安全 | **1.7B 胜** |
| mlx-swift | ✅ 4bit 26K 下载/月(>1.7B) | ✅ 已跑 | 都支持 |
| 活跃 | 极活跃(5.5M/月) | 持续 | 4B 略胜 |
| 速度 | ~15-25 tok/s(慢,GPU 可能热降) | 20-30 tok/s | 1.7B 胜 |

**代价分析**:4B-Instruct 是 non-thinking(躲掉 4B-thinking 的 63s 延迟惩罚),标准 dense(无 GDN/VL 模板坑),是「想要更新更强 Qwen」的唯一真候选。但:(a) iPhone 8GB 跑 4B-4bit 是「边界可行需硬化」不是营销甜区,必须加 increased-memory-limit entitlement + bounded KV cache + 真机实测加载尖峰;(b) restraint(本项目北极星)在题集上完全没跑过——不能凭「通用 FC 更强」外推「restraint 也更强」。**结论:adapt——若磊哥坚持要更强 Qwen,把 4B-Instruct-2507(non-thinking)纳入 P1-B spike,在 C6 vehicle-tool-bench(含 trap/拒识)+ iPhone 15PM RAM 实测上与 1.7B 同 harness 对跑,实测分过 1.7B 且 RAM 过关才换。**(conf:FC通用 high / 端侧8GB medium)

### 2.3 守 Qwen3-1.7B(verdict=adopt,⭐ 安全默认)

逐维见 §3 steelman。一句话:**端侧最安全 + FC/中文/拒识综合最强 + 零迁移 + 已是 P1-B 拍定的训练 base**,所有候选对比后仍是最优端侧 base。唯一缺点「发布日期老」不影响任何 demo 价值维度。

---

## 3. 守 1.7B 的 steelman(最强论据)

1. **FC 同尺寸最强的双证据,且都指向 restraint(本项目死穴)**:
   - 外部:MikeVeerman tool-calling-benchmark Round3 20-run `qwen3:1.7b=0.960`,全场冠军,**唯一**同时解出 P10/P11/P12 三道 hard restraint prompt(ROUND3_REPORT.md「Only qwen3:1.7b gets all three hard prompts right」)。从 Round2 三跑 0.670 升到 20 跑 0.960(+0.290 最大赢家),证明它的强是稳态不是噪声。
   - 内部:P1-B spike `Qwen3.5-2B 8/11 全面劣于 1.7B 9/11`(roadmap:130),且 2B artifact 实为 VL 多模态借文本塔。
   - **restraint = 知道何时「不调工具」,正是 MAformac「客户随便说句无关话不该触发车控」的安全门第一需求**。1.7B 在这维度实测无对手。

2. **「新 ≠ 强」本次深扒充分证实**(给磊哥「太老」诉求的硬反驳):
   - Qwen3.5-2B(新 10 个月)内部实测劣 + chat_template 损坏;
   - Gemma4(2026-04 最新)项目同版本 mlx-swift-lm 加载炸 + 受限解码 repetition collapse;
   - Ministral-3-2512 / Granite4-Nano(真新)端侧 restraint 0.800/0.520 < 0.960;
   - Phi-4-mini 从 co-champion 跌到 0.780。
   - 没有任何「发布日期新」的模型在「端侧能跑 + FC/中文实测更强」上综合占优 1.7B。

3. **成熟 + 零迁移 + 端侧链路已验证**:
   - mlx-community/Qwen3-1.7B-4bit 本机已缓存;
   - spike-e3 已实跑(mlx-swift-lm 3.31.3),pre-mortem 已摸清 `infer()` 精确匹配 model_type 的失配风险并锁 `.json` + smoketest(execution-pre-mortem-2026-06-18.md T2);
   - MLX-Outil(124★,Qwen3-1.7B + mlx-swift + iOS tool-call 完全同栈)实测可跑,反向证明端侧 tool-call 路径已通;
   - **标准 transformer 在 mlx-swift `ToolCallFormat` 解析白名单内(qwen3 走原生 Hermes)**,不像 xLAM(JSON 数组)/Hammer(Hermes 变体)silent fallback 部署崩。

4. **换的真实收益 vs 迁移成本对账**:
   - 收益:仅「发布日期新」(心理) + LFM2.5 的省 RAM/快(端侧锦上添花,1.7B 在 8GB 本就宽裕);
   - 成本:重下载 + 量化 + 重测 chat_template/parser + 升 mlx-swift 版本 + 重跑端侧 spike + 中文 LoRA 后重新对比 + 全集拒识重测;
   - **FC 能力的正解 = 1.7B(中文 base 强)+ 自有中文 LoRA(C5,3990 协议 + 12000 bug 真实说法)**,不靠换 FC 专精英文权重。这正是已锁路线。

> **诚实边界**:守 1.7B 的最强反方意见是「若 LFM2.5 中文 LoRA 后能追平 Qwen 且 8GB 续航/热降在连续 demo 下成瓶颈,LFM2.5 的端侧优势(不热降 + 省一半 RAM)会反超」。这是 P1-B spike 要实测裁决的,不是现在拍死。守 1.7B 是「实测未证更优前的安全默认」,不是「永不换」。

---

## 4. 端侧部署框架结论(回应「mlx 是不是最佳栈」)

**是。iPhone 15PM-8GB 上跑 Qwen3-1.7B+LoRA,mlx-swift 是最优栈,无需换框架。** 框架层四选一对比:

| 框架 | decode(17Pro实测) | 内存 | FC 链路 | 换 LoRA 权重成本 | iPhone15PM 适配 | 判定 |
|---|---|---|---|---|---|---|
| **mlx-swift-lm**(已集成 3.31.3) | **61 tok/s**(Qwen3.5-2B,比 llama.cpp 快 56%) | Qwen 系通常最低(2B 1279MB) | ChatSession.tools 原生 + MLX-Outil 蓝本 | 低(safetensors→mlx 量化) | ✅ 最优 | **主线 ⭐** |
| llama.cpp/GGUF | 39 tok/s(慢)但 prefill 2503(远超 MLX 249) | 部分模型更低 | **GBNF autoparser 最成熟** | 中 | ✅ 合理 fallback | LLMBackend 备选 |
| MLC-LLM | — | iOS 高于模型本身(#3083) | 弱,无 Qwen iOS 蓝本 | **高(TVM 每模型重编译)** | iOS 工程链最重 | **DROP**(逃生口) |
| CoreML/ANE | 最慢(2B 27.9 tok/s) | **最省(241MB)+ 不热降** | 无成熟端侧 FC | **极高(转换地狱)** | Qwen+LoRA 转 CoreML 静态shape/GDN/concat 编译地狱 | **DROP**(逃生口) |

**两个 HIGH 必须真机补测**(代码链路 + issue 实证):
- **所有 iPhone 实测数是 17 Pro/A19/12GB,不是磊哥的 15PM/A17/8GB**。一手坐实:`apple-silicon-llm-bench/devices/iphone-15-pro.md` 全 TBD(iOS version/Storage/Results 都 TBD),RESULTS.md 只列「iPhone 17 Pro, Mac M4 Max」。直接拿 61 tok/s / 1279MB 当 15PM 数据会高估。→ **P1-B spike 必在真机 15PM 跑 TTFT/decode/phys_footprint**。
- **KV cache 无界增长 → iOS jetsam 静默杀进程**(MLX wire 住 Metal 内存,jetsam 无法回收,不报内存压力直接崩)。→ 必须 bound max-kv-size + 单发约束(home-llm MAX_ITER=0,demo 单跳 FC 天然契合)+ os_proc_available_memory() gate + increased-memory-limit entitlement(内部 demo 侧载不走 App Store,规避 entitlement 失效坑)。

> 端侧硬天花板(load-bearing):**MLX-swift 下 dense ≤2B 才安全**,3B tight/risky,4B 在 12GB 17Pro 都因 jetsam(~50% RAM)无法加载(Ricky Takkar russet 实测)→ 选型直接锁 ≤2B,把 Qwen3-4B-2507 压到「需硬化」、ToolACE/LoopTool 8B 直接出局。(conf:high)

---

## 5. Pre-Mortem 三分类(换新会怎么炸)

### Tigers(明确威胁,换新必撞)

| # | tiger | severity | 证据 | mitigation |
|---|---|---|---|---|
| T1 | **iPhone 15PM 8GB 跑 4B-4bit jetsam OOM**,被营销源严重低估(非「甜区」是「边界需硬化」) | HIGH | 2B 在 17Pro 已 2900MB 峰值,4B 近两倍 ~4-5GB+;iPhone13(4GB)带 entitlement 也只 2.3GB 可用;12GB 17Pro 连 4B/3B 都因 jetsam 排除 | 选 ≤2B;若选 4B 必 entitlement + bounded KV + 真机实测加载尖峰,纳入 P1-B S2 |
| T2 | **在磊哥引用的 restraint benchmark 上 4B 无可靠分,1.7B 是冠军**——换 4B = 拿已证 restraint 赌未证 | HIGH | qwen3:1.7b=0.960 全场第1 唯一全 3 hard prompt;qwen3:4b 因 thinking 63s 被剔除无 20-run 分 | 不凭通用 FC 外推 restraint;4B-Instruct 在 C6 bench 同 harness 对跑 1.7B 用实测判 |
| T3 | **Qwen3.5/3.6 新线(GDN+VL)tool-call chat_template 系统性损坏**——任何追新到 3.5/3.6 撞墙 | HIGH | parser Hermes-JSON vs 训练 XML 不匹配,arguments\|items Jinja 崩,需 21-fix;ollama #14493 / #1831 / #178 全是 FC 损坏;内部 spike 2B chat_template 空 | Qwen3.5/3.6 线对本项目 DROP;结论锁定标准 transformer 线(1.7B / 4B-2507) |
| T4 | **Gemma4 在项目同版本 mlx-swift-lm 3.31.3 加载失败**(PLE shape mismatch),即便 RAM 够 FC 好端侧起不来 | HIGH | aandresalvarez 2026-05-28 实测 E2B 两个 artifact 均 PLE projection 加载失败;mlx-swift #389/#282 OPEN | Gemma4 端侧需等官方注册 gemma4 + 修 PLE loader(无 timeline),在此前不是可行候选 |
| T5 | **Gemma4 constrained-decoding repetition collapse**——直撞项目核心受限解码技术(GBNF/outlines-xgrammar 生成 ToolCall) | HIGH | vLLM #40080 / llama.cpp #21375 / gemma #622 一致复现,明确是相对 Gemma3 regression,repeat_penalty 无效 | 若评估 Gemma4 必先在项目实际受限解码链路做 repetition 压力测试,复现即 kill;不在受限解码下评估=假绿 |
| T6 | **MLX wire 住 Metal 内存,jetsam 无法回收 → 超限静默崩**(no graceful degradation),mlx-swift 特有死法 | HIGH | medium MLX memory mgmt:「Metal GPU wires memory, Jetsam cannot reclaim, system does not even detect pressure — it just crashes」 | 守 ≤2B 留 jetsam 余量;MLX.GPU.set(cacheLimit:) + bounded KV + entitlement + os_proc_available_memory gate;单跳 FC 短输出天然友好 |
| T7 | **「BFCL 高 ≠ restraint 好」陷阱候选**(Granite4-H-1B 官方 BFCL 54.8>Qwen 但本机 restraint 0.520 拒识双崩) | HIGH | granite4:3b ROUND3:57 restraint P5/P9 双失守 vs IBM blog BFCL 54.8 | 选型判据用本机 20-run restraint Agent Score / C6 IrrelAcc 轴,不看单轴 BFCL;换型前必在 C6 bench 拒识轴实测 |
| T8 | **LFM2.5 中文 base support 弱**——换型后客户现场中文听不懂(纯中文车控 demo 硬伤) | HIGH | Liquid 报告预训多语优先级 JP/AR/KR/ES/FR/DE,中文仅 additional base support;benchmark 的 Restraint 1.000 是英文 11-prompt 域,非中文车控全集 | 换 LFM2.5 前必跑中文车控全集泛化(对照 1.7B)+ LoRA 后中文恢复度 + 全集拒识;中文是一票否决,不过守 1.7B |
| T9 | **训练引擎切换风险**(被 mlx-lm-lora「Mac 本地省事」吸引,偏离 C5 锁的 Hammer/xLAM function-masking 数据配方,丢 restraint) | HIGH | C5 锁 unsloth+Hammer(function masking)+xLAM(arg-token masking)是为 FC/拒识专选;mlx-lm-lora 只在 Mac本地+QAT 占优,不提供 masking 配方 | 分层:数据配方(masking+held-out)不动,只在「训练引擎」层评估 mlx-lm-lora vs unsloth;HIGH 建议守现锁配方,mlx-lm-lora 仅作 QAT 端侧精度对比 spike。请磊哥拍 |

### Paper-tigers(看似威胁实际安全,须给证据)

| 议题 | 为何是纸老虎 | 证据 |
|---|---|---|
| 「早期 web summary 称 Qwen3-1.7B FC 弱 0.670」 | 0.670 是 Round2 三跑小样本 artifact;20 跑后 0.960 是冠军(「always this good」),3 跑 majority voting inadequate(7 模型变动 >0.05) | ROUND3_REPORT.md;反而是对守 1.7B 的有力背书 |
| 「FC 专精模型(xLAM/Hammer)纸面 BFCL 高就更强」 | mlx-swift ToolCallFormat 白名单不含 xlam/hammer → silent fallback,jdhodges 实测部署 15-20% 崩;English-only 中文打折 | jdhodges 2026-03;mlx-swift ToolCallFormat.swift |
| 「CoreML/ANE 内存 241MB + 不热降很诱人」 | Qwen+LoRA 转 CoreML 是工程地狱(静态 shape/无原生 KV/GDN cumsum 编译不动/concat 失败)+ decode 最慢 + 换权重极贵;1.7B 1GB 在 8GB 本就宽裕,无需为省内存付转换代价 | Orion 研究;CoreML-LLM 前沿非成熟 |
| 「Llama 3.2:3b Action 0.900 看着能干活」 | Action 0.900 的 happy-path 掩盖 **Restraint 0.000**(所有不该调的都乱开),对安全门 demo 灾难性 | ROUND3_REPORT.md llama3.2:3b Restraint 0.000 |
| 「有现成端到端 train→deploy turnkey skill」 | 14 次搜证确认无单一 repo 把 domain fine-tune+quantize+tool-call+on-device 全打包;现实是 train 侧 + deploy 侧分栈 stitch(MAformac C3/C5/C6 已是这结构) | WebSearch 显式确认;dgrauet/claude-skill-mlx-porting 是视频模型移植无关 |

### Elephants(没人想谈的)

| elephant | 说破 |
|---|---|
| **「磊哥嫌老」是心理诉求,不是工程诉求** | 1.7B 在端侧/FC/中文/拒识/工程成熟度全维度仍最优,日期老不影响 demo 不崩+听懂+惊艳。换新的真实驱动力是「2025-05 看着旧」的心理,不是任何实测短板。诚实说破:换新若不实测综合占优,是为心理诉求承担工程风险。 |
| **本机 tool-calling-benchmark 是英文 12-prompt 小样本,非中文车控全集** | 它测英文通用工具判断(get_weather/schedule_meeting),MAformac 是中文车控 3990 协议 + 拒识全集。它强在 restraint 设计(正中痛点)可作判断力交叉验证,但**最终判据必须回 C6 vehicle-tool-bench 中文全集**,不把英文小样本排序当终判。LFM2.5 的 0.920 / Restraint 1.000 都是英文域的。 |
| **P1-B spike 已事实上拍了「守 1.7B」** | roadmap:130「decision=守 1.7B,模型已定=训 Qwen3-1.7B」。本次 7 路深扒是对这个已拍决策的**对抗性再验证**——结论是 spike 拍得对,且补出了唯一值得再 spike 的备胎 LFM2.5。换新的窗口很窄:只有 LFM2.5 中文 LoRA 后追平 + 端侧实测优势成真,才推翻。 |
| **MLX-Outil 是「多跳 agent loop」倾向,直接照搬会撞 C4 确定性 DemoFlow 红线** | LLMManager 单跳后仍递归 performGeneration(虽 includingTools:false 限第二跳),结构上仍 LLM 驱动续生成。adopt 时须砍掉续生成自由度:tool 结果直接走 DemoGuard→mock state→renderReadback 确定性模板,只借 generation.toolCall 解析 + Tool schema 形态,不借 agent 续生成语义(与 home-llm MAX_ITER=0 一致)。 |

---

## 6. skill / 框架 adopt 清单(端侧 train-deploy 巨人肩膀)

> 现实:无单一 turnkey 端到端 skill;train 侧 + deploy/runtime 侧分栈 stitch。star+新鲜度双过门。

| 资产 | verdict | 用途 | freshness | url |
|---|---|---|---|---|
| **MLX-Outil**(LLMManager 单跳 loop + ToolDefinitions 类型化 Tool schema) | **adopt** | Qwen3-1.7B+mlx-swift+iOS tool-call **完全同栈近 drop-in 蓝本**;照搬单跳骨架,8 真实工具替换为 mock 车控,ToolDefinitions 从 semantic-function-contract codegen | 124★ / 2026-05-23(已 clone) | github.com/rudrankriyam/MLX-Outil |
| **mlx-swift-lm 3.x ChatSession.tools(PR #107)** | **adopt** | 官方 FC 入口,spike-e3 已集成 3.31.3;原生 Qwen3 tool-call 解析,主线 FC 走这条叠 LoRA + 防御解析 | 678★ / 2026-06-19(Apple 官方极活跃) | github.com/ml-explore/mlx-swift-lm |
| **apple-silicon-llm-bench ios/BenchmarkApp**(多 runtime + phys_footprint 内存计 + ThermalMonitor) | **adopt** | P1-B Qwen 15PM 真机 spike harness 骨架(MLX/llama.cpp 双 runtime,phys_footprint=jetsam 真实依据),省自搭一周 | 36★ / 数天前更新(已 clone) | github.com/john-rocky/apple-silicon-llm-bench |
| **MemoryMonitor phys_footprint 法** | **adopt** | task_vm_info 的 phys_footprint(jetsam 真正看的数)而非 resident_size 测峰值,8GB「fits vs jetsam」唯一诚实指标 | 同上 | 同上 |
| **mlx-lm-lora**(Mac 原生 LoRA+QAT) | **adapt** | C5 现锁 unsloth+Hammer/xLAM(CUDA/Colab),本机=Mac M5/32GB+mlx-lm 0.31.1;mlx-lm-lora 让训练全程留 Mac+QAT 对 8GB 4bit 精度友好。**仅作 QAT 端侧精度对比 spike,数据配方(masking)不替换** | 380★ / 2026-06-16 | github.com/Goekdeniz-Guelmez/mlx-lm-lora |
| **AnyLanguageModel**(drop-in FoundationModels + 多 provider tool calling) | **adapt** | MAformac 已自有 LLMBackend 抽象,借「统一 FM 调用点 + 逃生口切 Apple 原生 FM baseline」设计形态,不引依赖 | 894★ / 2026-06-20(HF 官方) | github.com/huggingface/AnyLanguageModel |
| **ToolACE 数据合成**(多 agent + complexity evaluator + dual-layer verify) | **adopt** | 8B 端侧不可跑但数据合成方法学喂 C5 中文车控 FC 训练数据(26507 API pool 自演化) | 2024 论文,方法学常青 | arxiv 2511.09148 |
| **LoopTool 闭环数据演化**(GCP 能力探测 + JGLV 标签验证) | **adapt** | C5 数据门迭代机制:C6 bench 测出 1.7B+LoRA 弱项→针对性补 C5 数据→重训,而非一次性数据 | 2025-11 论文 | arxiv 2511.09148 |
| **llama.cpp autoparser + GBNF** | **adapt** | common/chat-auto-parser-generator.cpp 自动从 chat_template 生成 tool-call GBNF;作 fallback 后端或受限解码思路来源(mlx 端暂无 GBNF) | 极活跃 | github.com/ggml-org/llama.cpp |
| Rapid-MLX | **drop** | Mac 桌面 server 非 iOS,不适用;仅 17 tool parser 设计可借不引 | 3004★ 但 Mac-only | github.com/raullenchai/Rapid-MLX |
| Unsloth ExecuTorch .pte phone-deployment | **adapt** | 走 .pte/etLLM 非 mlx-swift = fallback 不是主线;Qwen3.x GGUF 导出误判 VLM 出空文件夹(#4534/#3899);留 LLMBackend 第二实现可行性证据,当前不实装 | 67k★ / 2026-06-20 | unsloth.ai/docs phone-deploy |
| MLC-LLM / CoreML(ANEMLL) / MLXSampleApp | **drop** | MLC iOS 工程链最重+换权重贵;CoreML 转换地狱+decode 最慢;MLXSampleApp 2025-03 超新鲜度门被 MLX-Outil 覆盖 | — | — |

---

## 7. 选型相关 grill 议题(更新进 P1-C,15 轮)

> 这些是「换不换 / 换哪个 / 端侧框架 / 迁移成本」需磊哥拍的议题。⭐ = 综合官默认推荐。

1. **【换不换·总】** Qwen 家族没出过更新的 1.7B 同款(2507 只给 4B/30B/235B),「想要新的 1.7B」无解。⭐**守原 1.7B**(restraint 实测冠军 + 端侧最安全 + 零迁移 + P1-B 已拍),还是花 spike 评估 LFM2.5-1.2B(真新 + 省 RAM + 快 7x,但中文 base 弱需 LoRA)/ Qwen3-4B-2507(更强但更吃 8GB)?

2. **【LFM2.5 中文一票否决】** LFM2.5 中文仅 base support(预训多语优先级无中文)。要不要花一个 P1-B spike 周期验「中文车控 LoRA 后能否追平 Qwen」?⭐**值得一轮 spike,但中文是一票否决**——LoRA 后仍弱于 Qwen 就守 1.7B。还是「原生 CN 不可妥协」直接不 spike?

3. **【restraint 是另一维度,别用通用 FC 外推】** 4B 通用 FC 更强不等于 restraint 更强(1.7B 才是题集冠军)。⭐ 任何候选换 1.7B 前必在 **C6 vehicle-tool-bench(含 trap/拒识)同 harness 对跑**,用实测 IrrelAcc 判,不用通用 BFCL 外推。同意写进 decisions 吗?

4. **【追新边界四条】** ⭐ 建议把「新只在(标准 transformer + ≤2B 端侧能跑 + restraint 实测 ≥1.7B + iPhone 15PM RAM 实测过)四条全满足时才换」写进 roadmap/decisions,Qwen3.5/3.6 GDN+VL 线对本项目标 DROP。同意吗?

5. **【iPhone 实测数全是 17Pro/12GB】** 现有 tok-s/RAM 数全是 iPhone 17 Pro(A19/12GB),磊哥的 15PM(A17/8GB)是 TBD(devices/iphone-15-pro.md 全空)。⭐ P1-B spike **必在真机 15PM** 实测 TTFT/decode/phys_footprint,不引用 17Pro 数。要不要直接 adopt apple-silicon-llm-bench 的 ios/BenchmarkApp 作 harness?

6. **【端侧硬天花板 ≤2B】** ⭐ 8GB MLX-swift dense 上限=~2B(3B tight,4B 在 12GB 都炸)。建议选型直接锁 ≤2B,3B 不进候选。「5 分钟不崩」红线下是否接受 3B(tight/risky)?⭐ 不接受。

7. **【Qwen3-4B-2507 要不要进 spike】** 它是 Qwen 唯一「新+标准架构」候选,但 8GB 边界风险 + restraint 未证强。⭐ 若磊哥坚持要更强 Qwen,把 4B-Instruct-2507(non-thinking)纳入 P1-B S2,与 1.7B 同 harness 在 C6 + iPhone RAM 对跑;否则不花这轮 spike 预算。

8. **【mlx-swift 是不是最佳栈】** ⭐**是**(decode 最快 + Qwen 系内存最低 + 量化最全 + FC 原生 + MLX-Outil 蓝本 + spike-e3 已跑)。llama.cpp/GGUF 留 LLMBackend fallback(GBNF FC 更成熟),CoreML/MLC 仅逃生口。两 HIGH(15PM 真机测 + bounded KV 防 jetsam)必须做。

9. **【受限解码走哪条】** mlx-swift 暂无 GBNF。⭐ 走 LoRA 训格式 + JSON 防御解析(home-llm output.gbnf 三层防御解析思路移植),llama.cpp 端用现成 GBNF 作 fallback。是否把「受限解码可用性」列进 P1-B spike 验收项?

10. **【FC 专精模型只取方法学不换权重】** xLAM/Hammer 纸面 BFCL 高但 mlx-swift 解析白名单不含(部署 15-20% 崩)+ English-only。⭐ 守 1.7B + 自有中文 LoRA,只吸 function-masking(已 adopt)+ ToolACE 数据合成 + LoopTool 闭环演化方法学喂 C5,**不换 FC 专精英文权重**。

11. **【训练引擎切换 HIGH】** ⭐ 数据配方层(Hammer function-masking + xLAM arg-token masking + held-out)**不动**,只在训练引擎层评估 mlx-lm-lora(Mac本地+QAT)vs unsloth。建议守现锁配方,mlx-lm-lora 仅作 QAT 端侧精度对比 spike,不替换数据流。请磊哥拍。

12. **【Granite「敢调 judgment 差」陷阱写进纪律】** Granite4 官方 BFCL 54.8 > Qwen 但本机 restraint 0.520(拒识崩)。⭐ 把「选型只认 restraint/IrrelAcc 轴不认单轴 BFCL」写进 C6 bench 纪律。同意吗?

13. **【MiniCPM5-1B 第二备胎】** 中文原生强(1B 触 7-8B 中文)是唯一可能「中文超 Qwen」的,但 FC/restraint/mlx-swift 零实测。⭐ 暂不进 spike;若 LFM2.5 spike 失败,作「中文优先」第二探针再 spike 一轮。还是中文够用彻底守 Qwen 不折腾?

14. **【ExecuTorch 双栈要不要引】** Unsloth .pte 是成熟「训→端侧」链路但与 mlx-swift 不同栈。⭐ 守 mlx-swift 单主线(.safetensors→mlx 量化,绕开 Qwen3.x GGUF/VLM 导出坑),.pte 留 LLMBackend 未来 fallback 不实装。同意吗?

15. **【FunctionGemma L1 超轻旁路 side-experiment】** 270M(125-288MB + 完美 restraint + 435ms 最快)能否作 L1 精确指令超轻 FC 加速器做个 side-experiment(不动主线 1.7B)?⭐ 优先级低,无中文 + 需自训英文 mobile-actions 域外迁移,可探索极致端侧速度但不进主线;⭐ 建议先不做,聚焦 1.7B + LoRA。

---

## 附:一手锚点 file:line(可溯源)

- `~/workspace/raw/05-Projects/MAformac/ref-repos/tool-calling-benchmark/ROUND3_REPORT.md` — 20-run head-to-head:qwen3:1.7b=0.960 / lfm2.5:1.2b=0.920 / ministral-3:3b=0.800 / phi4-mini=0.780 / gemma3:1b=0.690 / functiongemma=0.640 / smollm3=0.630 / granite4:3b=0.520 / llama3.2:3b=0.660(Restraint 0.000)/ nanbeige4.1=0.800(3跑preliminary);「Only qwen3:1.7b gets all three hard prompts right」
- `docs/roadmap-2026-06-20-from-c6-done.md:130` — P1-B spike:Qwen3.5-2B 8/11=72.7% 全面劣于 1.7B 9/11=81.8%,artifact 实为 VL 多模态借文本塔,decision=守 1.7B,模型已定=训 Qwen3-1.7B
- `~/workspace/raw/05-Projects/MAformac/ref-repos/apple-silicon-llm-bench/devices/iphone-15-pro.md` — A17 Pro/8GB,iOS/Storage/Results 全 TBD(坐实端侧实测数是 17Pro/12GB,15PM 必须真机补测)
- `~/workspace/raw/05-Projects/MAformac/ref-repos/MLX-Outil/MLX Outil/Services/LLMManager.swift` — `LLMRegistry.qwen3_1_7b_4bit`(Qwen3-1.7B mlx-swift iOS tool-call 同栈蓝本)
- `docs/execution-pre-mortem-2026-06-18.md` T1/T2 — mlx-swift-lm 已内置 parser(adopt 不自建);`infer()` 精确匹配 model_type 失配风险(锁 .json + smoketest 断言收 .toolCall)
- 本机 HF cache:mlx-community/Qwen3-1.7B-4bit(基线已缓存)+ Qwen3.5-2B-4bit(spike 已测劣)+ Qwen3.6-35B-A3B(35B MoE 超天花板);mlx-lm 0.31.1;Mac M5/32GB(训练机)
- 关键 source_url:huggingface.co/Qwen/Qwen3-4B-Instruct-2507 / huggingface.co/LiquidAI/LFM2.5-1.2B-Instruct / ollama #14493 / QwenLM/Qwen3 #1831 / mlx-swift #389/#282 / vLLM #40080 / huggingface.co/blog/ibm-granite/granite-4-nano / rickytakkar.com/blog_russet_mlx_benchmark.html / github.com/MikeVeerman/tool-calling-benchmark

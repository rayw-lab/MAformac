# external_claims 待核 + 与 Phase 0 冲突检查

## 与 Phase 0 冲突检查

## 18 路结论 vs Phase 0 接受的 24 grill 决策（C01-C24）冲突检查

**总判：零硬冲突。18 路全部 support 或细化 Phase 0 决策，无一路推翻已接受的 grill 决策。** 三类关系：

### 一、完全一致/support（多数）
- **C16 freeze rank16Mainline unless evidence excludes confounders**：L01/L13/L14 全 support(2602.04998证变体无增益，PEFT新结构=escape-hatch DEFERRED不reopen)。
- **C17 D-domain base recalibration(旧base仅historical)**：L04直接对应(本机实测旧generic-frame base 10/23标historical，D-domain重测新anchor)。
- **C18 四层门no aggregate pass rate masks any layer**：L04(ABC论文背书)+L11(pass^k反巧合)+L16(C24 train_health不imply model_quality)全support。
- **C13 held-out防泄漏(family/template切分+loss-MIA)**：L08主管(8轴held-out)+L04消费其通过证明，一致。
- **C14 mid-training gate四态(continue|human_pause|early_stop|blocked)+receipt**：L05/L16直接对应，L05补「必行为门非val-loss门」细化。
- **D14 ASR系统SFSpeechRecognizer主+sherpa fallback**：L18完全一致并补load-bearing elephant(砍custom vocabulary→音近增广升级唯一兜底)。
- **D16 surface改非IR替换(canonical IR仍device×action)**：L15反向印证(generic→D-domain正解)，L16 C07标modified。
- **D30 训练栈守mlx-lm(unsloth要CUDA Mac无N卡)**：L01/L15一致。
- **C20 GBNF fallback only**：L06细化(XGrammar官方Swift Package=端侧无GBNF假设过时，但仍escape_hatch非主路，约束解码保证语法非语义)。
- **C24 status vocabulary禁互相冒充**：L16直接物理化，L04补completion-claim-triage(四层门绿=评测态非demo ready)。

### 二、细化/补强（不冲突，加细节）
- **C11-C12配比hypothesis待spike**：L07补外部锚(审计24%偏高应收15-20%，复刻Magnet扫描)，但守「不拍死生产值」=一致。
- **C5数据4类**：L07/L12/L15补「failure砍vs纳入」「already_state归类」delta，但标retrain-c5 propose待拍=守边界。

### 三、潜在张力点（需grill澄清，非冲突）
- **L15 elephant：「generic frame 1.7B学不会」措辞精确化**：home-llm证generic frame在270m-1B能work(靠封闭词表小+工具子集化)，故措辞应精确为「未做判定面收窄的generic frame在562规模学不会」非「generic frame绝对禁区」。这**不推翻A2 D-domain决策**(A2仍正解)，但提示working diagnosis(G6-C两因)需诚实保留，不把surface当唯一根因。建议grill确认。
- **L04/L08 elephant：四层门绿≠demo ready + 泄漏门自身防假绿**：提示C24+harness enforce层须覆盖「门本身成第11坑」，与Phase 0「harness enforce已上线」一致但提示覆盖不全(BASELINE_GLOBS不含部分活基线)。

**结论：18路是Phase 0决策的下游细化弹药，无一路要求reopen已接受的grill决策；唯一需grill的是L15的「generic frame学不会」措辞精确化(working diagnosis诚实保留)，不动A2/配方/范式主线。**

## external_claims（综合官汇总，主线程已核见 external-claims-verification.md）

- 【已核真实(external-claims-verification.md主线程亲核)】NLoRA arxiv 2502.14482(EMNLP2025 Findings,SLoRA/NLoRA/IntTune同一篇三贡献非三篇,GSM8K SLoRA 56.48%/NLoRA 57.70%超LoRA33.52%/36.41%) — L14引用对照核实
- 【已核真实】Stiefel-LoRA arxiv 2508.17901(EMNLP2025,LLaMA-3.2-1B rank16 LoRA+AdamW有效秩≈12.1/16,B列cos std=0.5143) — L13/L14引用一致
- 【已核真实】CorDA arxiv 2406.05223(NeurIPS2024,KPA防遗忘对应L10) — L14引用一致
- 【已核真实】TinyLLM arxiv 2511.22138 / Characterizing Model Behavior Under Synthetic Data Training 2510.05133(合成数据0-50%比例model collapse,对应R9) / ALTO 2604.05426(Rice,LoRA超参+best-checkpoint patience,对应R10) / Instruct-SkillMix 2408.14774(ICLR2025,真实但主题=SFT数据pipeline非checkpoint,finder引loss上升held-out峰在mid-training需细核此claim) — 8 arxiv全真实
- 【已核活跃度(gh核2026-06-24)】gorilla/BFCL 12918★ 2026-04-13 / mlx-lm 6019★ 2026-06-12 / mlx-swift 1932★ 2026-06-17 / home-llm 1364★ 2026-06-11 / tau-bench 1292★ / NVlabs/DoRA 978★ 2026-03-24 / xLAM 630★ / mlx-lm-lora 384★ 2026-06-16 — 全真实
- 【已核淘汰】When2Call 64★ 1年没动(数据可用repo别adopt) / iboing/CorDA 56★ 1.5年没动该淘汰(走hf/peft集成版) / TracyGuo2001/NLoRA 6★ 1年没动该淘汰(仅读方法不adopt,印证L14 escape-hatch定位) — 新鲜度核实
- 【待主线程核】L02 transformers PR #30650 + Qwen discussions #10/#14(return_assistant_tokens_mask + {%generation%}拒绝合并)系WebSearch转述未本机核PR/discussion编号
- 【待主线程核】L03 mlx-swift #154 / Qwen3 #1826 / transformers #34462砍尾换行 / #34172 — issue编号WebSearch转述，think块4token差本机encode实测已坐实(151644/77091/198/151667/271/151668/271)
- 【待主线程核】L04 ABC论文 arxiv 2507.02825(τ-bench counts empty as successful) / When2Call 2504.18851 / τ-bench 2406.12045 / ACEBench 2501.12851 — 论文ID + 「empty=successful」点名claim待核；🔴Meta-Harness 2603.28052 + Harness-Bench 2605.27922系cutoff后ID高编造风险待核
- 【待主线程核】L07 APIGen 2406.18518(stage2/3过滤数据加回退化小模型) / ToolACE 2409.00920(砍非工具irrelevance崩6.99%) / Hammer 2410.04587(irrelevance最优≈10%) / Magnet 2503.07826(15-17% sweet spot) / When2Call held_out_param — 精确数字待核
- 【待主线程核】L08 Rephrased Samples 2311.04850(已WebSearch核真实) / SemDeDup 2303.09540(已核) / Gerz&Jelali augment-after-split虚高65.93pp(ssrn 5636100二手) / LoRA-Leak 2507.18302 / 2506.20856 / 2603.03203 / MegaScience 2507.16812 — 65.93pp/ELI5 81%/SemHash 83s精确数字待核
- 【待主线程核】L10 Alopex 2411.05209(Qwen1.5-1.8B窄域FC SFT后MMLU/GSM8K全降,精确数PDF受限) / SFT Doesnt Always Hurt 2509.20758(已fetch确认) / DMT 2310.05492 / C-Eval 2306.09212 / CMMLU — 混通用5-15%缓解待核
- 【待主线程核】L11 How Consistent Are LLM Agents 2605.28840(abstract核实,run-to-run精确数字未暴露勿凭abstract编) / τ²-Bench pass^1=81.6%→pass^4=56.1%(philschmid/agentpatterns二手) / LIBERO-Para 2603.28301(22-52pp是VLA非纯LLM FC标caveat) / Order Effect 2502.04134(76pp待核归属)
- 【待主线程核】L12 Abstain-R1 2604.17073(SFT-only 51.9%U-Ref/37.0%U-Clar→SFT+RL 68.1%/55.1%) / AWS Qwen3-1.7B逐阶段41.57/60.43/71.06(总增益30%+9%超Llama双源确认,三位小数待核) / Awakening Sleeping Agent 2604.08388(irrelevance 80%→21-49%) / When2Call早期WebFetch幻觉数82.3%已弃用真实48.1/49.4→51.0/52.4 / FalseReject 2505.08054
- 【待主线程核】L17 SPECA 2602.07513(cross-vendor76.5%有效发现+同源bug盲区,精确数字待核) / One Token to Fool 2507.08794(已核实存在,标点35%FPR/单空格66.8%FPR Table数字待抽核) / Strategic Dishonesty 2509.18058 / self-pref降幅82%→30%/79%→23% / BFCL改写降13-19pp(二手);🔴Coin Flip 2603.06594 + 2604.10079系未来日期ID WebSearch自flag待核,论点load-bearing低已用替代
- 【待主线程核】L18 ASR robustness 2103.13610 / MSMT-FN 2511.11006(8000字典/10%同音替换) / RealTalk-CN 2508.10015 / VocalBench-DF 2510.15406 / Disfluency-to-Intent 2209.08359 / ASR-EC 2412.03075 / SLURP 2305.13512(本仓既有) — 精确数字+arxiv ID待抽样核
- 【已核(L16段标注)】ByteDance robust training infra 2509.16293(双层tier divergence) / over-memorization 2508.04117(perplexity停太早) / GradES 2509.01842 — WebSearch实搜非编造

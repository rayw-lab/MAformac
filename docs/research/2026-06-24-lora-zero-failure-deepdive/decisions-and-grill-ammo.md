# 待磊哥拍板决策 + Grill 弹药 + Steelman 守现状

## 待拍决策

### D1. C6 action hard_pass 分母口径（四层门防聚合掩盖）
- 选项：A=action按case schema字段拆(expect_no_call/clarify_tag/scope_tier，base锚10/23) / B=全57当分母 / C=全562当分母
- ⭐默认：⭐A：固化build_axes_from_summary.py按schema字段拆进make verify，旧generic-frame base 10/23标historical，D-domain重测新base当anchor
- 量化：本机实测全57跑tcm&sdm=29看似过半，真action positive子集分母=23，base 10/23=43%；用全集分母会稀释=0/34同根(ABC论文τ-bench empty=success)
- 需磊哥拍板：True

### D2. 训练中途行为门 stop-the-train 四态阈值（直接刹0/34）
- 选项：A=行为生成门iter50/100/150抽样generate N≥5(走A2同源surface) / B=只用mlx-lm原生val-loss门 / C=不加中途门跑满再C6
- ⭐默认：⭐A：阈值=相对base不退化(golden≥base_golden/fuzz≥base_fuzz)，四态continue|human_pause|early_stop|blocked，infrastructure-enforced(train()外try/except+raise)非codex自审
- 量化：0/34通宵跑满600iter才暴露=无中途行为门；iter50抽样0/5可省550iter+通宵；val-loss门必漏(0/34是loss健康行为塌)；行为门<5%开销
- 需磊哥拍板：True

### D3. 四类数据配比（负样本比例 sweet spot）
- 选项：A=负样本15-20%(positive20/unsup6/safety3/followup2) / B=审计建议24%(positive20/unsup8/safety4/followup2) / C=配比spike扫6.7%-24%找拐点不拍死
- ⭐默认：⭐C(spike找拐点)，起点倾向A：复刻Magnet扫描法在dev set找over-refusal拐点，不直接拍24%进生产
- 量化：Hammer ablation 10%/Magnet实测15-17% sweet spot/MOSAIC>1:1收益递减→审计24%偏高出sweet spot；ToolACE砍负类irrelevance崩6.99%(不可砍铁证)
- 需磊哥拍板：True

### D4. 拒识/安全/澄清训练方法（SFT vs DPO）
- 选项：A=纯SFT正例+IrrelAcc≥base 0.789死门 / B=SFT+DPO偏好对 / C=SFT先行DPO后续可选增强
- ⭐默认：⭐A(demo阶段)+C(标DPO为DEFERRED不前置)：MAformac拒识=确定性可判，home-llm 124拒识纯SFT在270m work，DPO需负例来源(base塌缩采不出)+mlx DPO未实测
- 量化：0/34的7个demo-critical全0/7真因=训练集0条这4类自然中文非方法错；When2Call实证RPO仅+3F1主压over-call；AWS Qwen3-1.7B SFT先吃19%DPO才补10.5%
- 需磊哥拍板：True

### D5. byte-parity gate 端侧render源闭环
- 选项：A=端侧render dump接进gate(依赖端侧mlx-swift runtime，DEFERRED) / B=继续nil/BLOCKED占位 / C=propose写成OpenSpec task不实装
- ⭐默认：⭐C：把端侧render dump接入写成OpenSpec gate task(治理类落docs/research)，gate现态=blocked非pass，措辞守completion-claim-triage(评测门设计计划态非执行态)
- 量化：C5EndpointTokenizerParityGate(swift:1612)骨架已建但endpointRendered恒nil从未真接mlx-swift；端侧少4 prompt token=隐蔽toolCalls=[]路径；真闭环依赖端侧runtime(DEFERRED)
- 需磊哥拍板：True

### D6. 通用中文混入 + 回归门（防灾难遗忘）
- 选项：A=混5-25%通用中文+C-Eval/CMMLU零样本回归门 / B=纯D-domain四类数据不混 / C=只加held-out paraphrase intent回归不混通用
- ⭐默认：⭐A(hypothesis待spike)：守rank16Mainline=遗忘三件套已防，加escape_hatch混通用腿+零样本回归门，比例待spike不拍死
- 量化：Alopex实测Qwen1.5-1.8B窄域FC SFT后MMLU/GSM8K全降1:1混恢复；混5-15%即缓解，>25%反稀释工具精度(home-llm alpaca实例)；home-llm evaluate.py零通用eval=盲点
- 需磊哥拍板：True

### D7. 错误恢复类(failure)纳入与否
- 选项：A=砍failure+显式记(demo约定收窄现场不演错误恢复) / B=纳入完整HA风格3-turn失败恢复链 / C=端侧偶发解析失败留factor≤2最小种子
- ⭐默认：⭐A+C：砍完整链(过度工程化)但借loss-mask内核(防学坏调用)，端侧解析失败留最小种子；ToolACE 6.99%是砍负类后果，failure是positive子类砍不触发崩溃
- 量化：home-llm xl档failure factor=2绝不为0但最轻；demo轻治理铁律=借可靠性内核砍全链路；纳入与否=retrain-c5 propose待拍hypothesis
- 需磊哥拍板：True

### D8. 端侧受限解码引擎选型(escape_hatch)
- 选项：A=XGrammar官方Swift Package(mlc-ai/xgrammar) / B=mlx-swift-structured封装(单作者无CI) / C=纯LoRA格式+三层防御解析不上约束解码
- ⭐默认：⭐A优先(官方支持iOS/macOS,1756★,<10%overhead)，mlx-swift-structured作参考；grammar必含拒识分支(防阉割拒识)；8GB真机必spike
- 量化：端侧无GBNF=死路假设过时(XGrammar 2天前push)；约束解码保证语法非语义(可能把0/34变更隐蔽合法但错)→P1非P0；benchmark全在12GB，8GB jetsam上限差近2x必独立spike
- 需磊哥拍板：True

### D9. pre-propose 后下一步OpenSpec change边界
- 选项：A=retrain-c5(数据gate+样本可观测+泄漏门，DEFERRED实跑) / B=rebuild-c6(四层门+base recalibration，DEFERRED实跑) / C=两change并行propose先写gate task不实跑
- ⭐默认：⭐C：先把P0门(样本可观测/surface同源/byte-parity/中途行为门/四层门)写成OpenSpec gate task(治理落docs/research不碰contracts)，实跑训练/评测/voice全DEFERRED
- 量化：Phase 0边界=纯pre-propose弹药不执行；A2=code-only已合并main；retrain-c5/rebuild-c6实跑须前置门全在(held-out轴+mid-gate+base anchor+四层分母)
- 需磊哥拍板：True


## Grill 弹药

1. [C6四层分母]四层门各分母按case schema字段拆(golden=positive_action子集23/unsupported=expect_no_call∩scope_tier=out/safety=risk-policy refusal/demo_fuzz=口语变体held-out)禁全集稀释。⭐固化build_axes_from_summary.py按schema字段拆进make verify。量化：本机实测全57跑tcm&sdm=29但真action分母=23(base 10/23=43%)，用全57/562当分母=0/34同根(ABC论文τ-bench empty=success)
2. [中途行为门]训练中途必行为生成门(iter50/100/150抽样generate N≥5走A2同源surface)禁val-loss门。⭐四态continue|human_pause|early_stop|blocked，阈值=相对base不退化，infrastructure-enforced非codex自审。量化：0/34通宵跑满600iter才暴露=无中途行为门，iter50抽样0/5可省550iter；val-loss门必漏(0/34=loss健康行为塌)
3. [数据配比]负样本总和收15-20%(positive20/unsup6/safety3/followup2)，配比spike复刻Magnet扫6.7%-24%找over-refusal拐点不拍死24%。⭐spike找拐点起点15-20%。量化：Hammer 10%/Magnet 15-17% sweet spot/审计建议24%偏高；ToolACE砍负类irrelevance崩6.99%(负类不可砍铁证)
4. [SFT vs DPO拒识]demo阶段纯SFT正例+IrrelAcc≥base 0.789死门为主路，DPO标DEFERRED不前置不阻0/34修复。⭐SFT正例+4类schema+IrrelAcc门。量化：0/34的7个demo-critical全0/7真因=训练集0条这4类自然中文非方法错；home-llm 124拒识纯SFT在270m work；When2Call RPO仅+3F1主压over-call
5. [样本可观测]每条D-domain样本带P0三字段no_call_target_present(从样本实际tools算非读metadata)/tool_surface_digest/label_conflict_flag必0，receipt报逐字段分布非顶层聚合。⭐训练前dry-run sample audit fail-closed exit65。量化：0/34直接根因=buildNoCallSamples写metadata声称删却没执行tools.removeAll=446假删(claim-vs-reality铁律1数据版)
6. [byte-parity闭环]端侧render dump接进C5EndpointTokenizerParityGate(swift:1612)逐字节比+think签名+mask offset起点token，现endpointRendered恒nil未闭环=最大缺口。⭐写成OpenSpec gate task，gate现态=blocked非pass。量化：训练assistant段含think块(4token)端侧推理不含→端侧少4 prompt token=隐蔽toolCalls=[]路径
7. [人审破框]7个人审不可委托点(first-50逐条/loss-mask print/train-eval diff/refusal样本逐条对照home-llm/top-failing/utterance drift/final route)+≥1判官刻意反框回读一手，高stakes无条件人审不论一致。⭐人审点入OpenSpec task acceptance非prose。量化：0/34恰是4模型一致PASS(集体盲区)；SPECA实证cross-vendor≠cross-frame(同源bug)；One Token to Fool judge被空/标点骗35%FPR=empty=hit同病
8. [泄漏门]gate消费candidate_parent_semantic_id(重判)非继承seed+augment-AFTER-split同family归一partition+embedding nearest-protected双层+OOD value bucket真测。⭐4类必quarantine fail-closed人审。量化：现C5DataGate.swift:264纯exact-ID交集=Q15「:252假安全」(漂heldout但ID没漂假过)；Gerz&Jelali augment-before-split虚高65.93pp；LoRA抑制verbatim记忆→事后MIA不可靠
9. [通用中文混入]混5-25%通用中文+C-Eval/CMMLU零样本回归门防灾难遗忘+客户换说法听不懂，比例待spike。⭐守rank16Mainline遗忘三件套+escape_hatch混通用腿。量化：Alopex实测Qwen1.5-1.8B窄域FC SFT后MMLU/GSM8K全降1:1混恢复；home-llm evaluate.py零通用eval=照搬盲点
10. [反巧合门]C6 must-pass/golden跑pass^k(全k次都过非pooled hardFailures==0)+多seed sweep(mlx temp=0非确定性)+base-vs-LoRA配对McNemar+扰动不变性。⭐G1 pass^k门+G4扰动不变性最高价值。量化：τ²-Bench pass^1=81.6%→pass^4=56.1%(单跑高估25pp)；C6已有samplingSeed+hardPassVariance但只记录不enforce(claim-vs-reality铁律1活样本)
11. [守配方]rank16Mainline逐项对齐ToolACE FC黄金配方，2602.04998证9变体LR调对全在0.43-1.75%内、同族Qwen3-0.6B DoRA仅+0.15%。⭐守现状，PEFT新结构=escape-hatch DEFERRED(DoRA-rank8唯一零成本mlx原生)。量化：562 intent=格式任务非容量问题(loss健康行为塌=反向信号非欠容量，加rank是误诊)；换配方前必先排除前4路根因
12. [ASR音近增广]系统SFSpeechRecognizer砍custom vocabulary→错字鲁棒压力全下移LoRA+拼音fuzzy，10%逐字同音增广+held-out干净集。⭐side-memo不进retrain拍板，C11-C12分音近/disfluency两hypothesis分开拍。量化：home-llm零ASR增广=真实gap；旧sherpa有transducer热词第一道闸系统ASR没了→音近增广从nice-to-have升级唯一兜底

## Steelman 守现状

## 守 rank16Mainline + 1.7B + home-llm 范式 的 steelman

**结论：守现状是正确决策，三条独立证据链坐实，0/34 根因不在任何被守的对象上。**

### 一、守 rank16Mainline 配方（rank16/scale20/LR1e-4/cosine/warmup0.08/adamw+wd0.01/epochs3/7模块）
1. **逐项对齐业界FC黄金线**(L13)：rank16Mainline 几乎逐字命中 ToolACE-derived 工具调用最佳配方(rank16/α32/LR1e-4 cosine/warmup0.1/3ep/all-linear)。
2. **变体无增益是最强反证**(L13/L14)：arxiv 2602.04998「Learning Rate Matters: Vanilla LoRA May Suffice」(IBM 2026-02)系统扫9个LoRA变体×LR×batch×rank全搜索，LR调对后全在0.43-1.75%内收敛，「变体提升多是LR没调对的假象」；**同族Qwen3-0.6B上DoRA仅+0.15%/MiLoRA+0.43%/PiSSA需10×LR**。
3. **LR=1e-4对1.7B+rank16是正确保守值**(L13)：小rank偏好略低LR+本机实测2e-4发散(iter80=32)/1e-4稳(iter30=1.069)。
4. **562 intent不是容量问题**(L13)：FC=学结构化格式(LoRA强项/低内在维度)非数学推理(弱项)；rank16在500-task Mistral多任务已够；0/34是loss健康/行为塌缩=反向信号(欠容量签名是train≈val双低)，加rank是误诊。

### 二、守 Qwen3-1.7B + mlx-lm 本机栈
1. **本机实测跑得动且健康**(L01)：M5/32GB实测peak 12.2GB(留20GB headroom)/no_oom/loss健康收敛5.5→0.6-1.3；云Axolotl零必要(那是CUDA栈无关Mac unified)。
2. **8GB端侧可行**(L06)：1.7B-4bit权重984MB+KV+runtime~1.5-2GB << 4GB能装；1.7B>270m容量更适合562 intent泛化。

### 三、守 home-llm 范式（蓝本，1364★ 2026-06-11 活跃，>1000不降级）
1. **数据链路是教科书级**(L07/L15)：seed→templating expand→distractor→validate(LLM填种子非直产jsonl避幻觉)正是Web多源证实最佳实践，270m已work。
2. **A2 D-domain正是对home-llm教训的正确吸收**(L15)：home-llm 19 generic工具在270m能work靠封闭词表小+每例工具子集化；562砸generic必爆→A2改D-domain具名工具=正解(反向印证)。
3. **拒识纯SFT正例就够**(L12)：home-llm 124拒识例纯SFT在270m work，DPO仅TODO未实装；MAformac拒识=确定性可判→SFT足够，DPO是过度工程化DEFERRED。

### 辩证caveat（不盲从守现状）
- **守现状≠不补门**：0/34教训是配方对但**外围工程(surface同源/byte-parity/样本可观测/中途行为门)缺失**——守配方的同时必须补这4道P0门，否则配方再对照样塌(L02/L03/L05/L09)。
- **home-llm不能全照搬**：①LR必守1e-4不照搬2e-4(L13/L15) ②generic-tool surface绝不照搬(L15) ③home-llm零通用eval/零ASR增广是盲点须补(L10/L18)。
- **PEFT新结构=escape-hatch DEFERRED**：DoRA-rank8唯一零成本备选(mlx原生)，仅在「诊断坐实欠容量」时reopen(C16准则)，且换配方前必先排除前4路根因(L13 F9)。

## Pre-mortem 三分类汇总

## 18 路 tiger / paper-tiger / elephant 三分类汇总

### 🐯 Tigers（明确威胁+验证清单，按出现频次聚类）
1. **样本/surface层(0/34直接根因群)**：446假删metadata声称非物理删(L09)；train/eval/runtime三方surface异源(L02/L03/L16 R2)；byte-parity think块offset漂端侧少4token(L03/L16 R3)。验证=从样本实际tools算target+三方hash diff+端侧render逐字节比。
2. **中途门失守群**：val-loss门测不到0/34(L05)；mlx callback停不了loop以为停实没停(L05/L01)；阈值绝对值刹掉base(L05 FM3)。验证=行为生成门+train()外raise+阈值相对base。
3. **配比/数据层群**：负类被砍irrelevance崩6.99%(L07)；配比24%过度拒识(L07)；纯云model collapse+脏数据(L07/L16 R9)；augment继承seed ID漂heldout假过(L08)；SFT训拒识over-call IrrelAcc崩80%→21-49%(L12)。
4. **门假绿/审计层群**：hardPassVariance只记录不enforce单跑放行(L11)；gate receipt写PASS是metadata成第11坑(L08/L09/L16 R11)；人审退化成抽查/看receipt(L17)；cross-vendor误当cross-frame(L17)；LLM-judge被master-key骗empty=hit(L17/L04)。
5. **配方/LR层**：LR回2e-4 loss尖刺(L13/L15/L16 R6,本机实测iter80=32)；被NLoRA SOTA数字诱导采SVD-init(L14)；为变体改mlx代码给脆弱链路加故障面(L14)。
6. **遗忘/泛化层**：不混通用客户换说法听不懂(L10)；窄域SFT损paraphrase robustness(L10)；ASR音近错字击穿入口(L18)；约束解码掩盖语义错(L06)。

### 🐯📄 Paper-tigers（看似威胁实际安全+证据）
1. **「训练栈跑不动/必上云」**(L01/L16 R12)：本机实测peak 12.2GB留20GB headroom，硬件从非瓶颈。
2. **「灾难遗忘是0/34根因须P0」**(L10)：0/34=generic frame爆炸+surface异源A2已对症，与遗忘正交不抢工时。
3. **「必须用PEFT变体(DoRA/PiSSA/NLoRA)」**(L13/L14/L16)：2602.04998证LR调对9变体0.43-1.75%内，同族0.6B DoRA仅+0.15%。
4. **「mlx-lm不支持多轮掩码=必须换trainer」**(L02)：单轮非缺陷，多轮可拆样本绕过。
5. **「Qwen3无{%generation%}=没法正确SFT掩码」**(L02)：单轮单offset完全正确不需要。
6. **「拒识必须DPO/辩论越多越准」**(L12/L17)：home-llm纯SFT在270m work，FalseReject证确定性场景SFT够；MAD理论证增轮反降准。
7. **「合成数据必model collapse」**(L15)：确定性templating展开真实种子≠自由LLM幻觉，collapse风险被锚定压低。
8. **「SemDeDup要GPU越界」**(L08)：~4-7k数据SemHash CPU秒级。
9. **「约束解码overhead太大/端侧无受限解码死路」**(L06)：XGrammar<10%+固定schema缓存near-zero+官方Swift Package。

### 🐘 Elephants（没人提但该提，最高价值）
1. **门本身成新坑(claim-vs-reality第11坑)**(L05/L08/L09/L11/L16)：防0/34的gate若读metadata/阈值直翻=假绿；必value-in-source核+异源grader+sign-or-block。
2. **「generic frame 1.7B学不会」措辞需精确化**(L15)：home-llm证generic frame在270m-1B能work(靠封闭词表小+工具子集化)，措辞应精确为「未做判定面收窄的generic frame在562规模学不会」，working diagnosis(G6-C两因)须诚实保留不把surface当唯一根因。
3. **四层门绿≠demo端到端ready**(L04)：TTS听感/端侧延迟/ASR澄清自然度不在C6自动门内，防「门绿就宣布demo ready」completion-claim-triage。
4. **系统ASR砍custom vocabulary→音近增广升级唯一兜底**(L18,D14 amend未记录的load-bearing elephant)。
5. **人审者automation bias+CC主线程self-preference结构性在场**(L17)：人看AI高分倾向附和，CC既产出又综合必异源catch。
6. **D-domain后fixture expected_start可能失效**(L02/L03)：retrain-c5需更新c5_mask_offset_fixture.py expected_start否则对新格式假绿。
7. **demo_fuzz泄漏接缝**(L04/L08)：demo_fuzz评测集若用LoRA同源生成测自己=循环失守，须held-out保证family/template不重叠。
8. **deferred解冻判据散3处无单源manifest**(L16)：未来session各引一处drift，建议C05补deferred-release-criteria单源。
9. **EXP逆规整(734)=demo灵魂最难value-form**(L07)：加权应向EXP+demo-critical 10族倾斜非笛卡尔均匀。
10. **8GB真机口径漂移**(L06)：benchmark全在iPhone17Pro-12GB，8GB jetsam上限差近2x必独立spike，禁拿12GB数据当8GB证据。
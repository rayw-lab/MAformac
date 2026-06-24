# MAformac LoRA 零容错 18 路调研 — 最终综合报告

> 全 18 路收敛 · 2026-06-24 · 综合官 Opus 4.8 · pre-propose decision-pack 不执行训练/评测/voice

# MAformac LoRA 零容错 18 路深扒 — 最终综合报告（pre-propose decision-pack）

> 综合官 probe 收敛 · 2026-06-24 · 18 路 finder 一手档全读 + external-claims 对照
> 边界：纯 pre-propose 弹药，不执行训练/评测/voice；治理类落 docs/research 不碰 contracts/

## 一、每路一句话精华

| 路 | P | 一句话精华 |
|---|---|---|
| L01 训练栈 | P2 | 本机M5/32GB实测peak 12.2GB/留20GB headroom，跑不跑得动从来非0/34根因，云Axolotl零必要。 |
| L02 loss-mask | P1 | mlx-lm单offset对当前单轮正确，但retrain引入多轮未拆=复制0/34(只训最后一条)，offset验证器已在场。 |
| L03 byte-parity | **P0** | 训推think块4token差=隐蔽toolCalls=[]路径，gate骨架已建但endpointRendered恒nil未闭环=最大缺口。 |
| L04 C6四层门 | **P0** | 四层独立门+action按schema字段拆(23非全57/562)，ABC论文点名τ-bench「empty=success」=0/34同根。 |
| L05 中途门 | **P0** | 必行为生成门(iter50抽样generate)非val-loss门，infrastructure-enforced非codex自审，能iter50刹0/34省通宵。 |
| L06 端侧部署 | P1 | 端侧无GBNF=死路过时(XGrammar官方Swift Package)，但约束解码保证语法非选对工具(可能把0/34变更隐蔽)。 |
| L07 数据配方 | **P0** | 负类不可砍(ToolACE 6.99%=0/34同根)，配比sweet spot 15-20%(审计24%偏高)，双腿(模板70%+云30%异源judge)。 |
| L08 数据泄漏 | P1 | 现C5DataGate纯exact-ID交集=「:252假安全」，augment-after-split同family归一partition是最强一刀。 |
| L09 样本可观测 | **P0** | 0/34直接根因=446假删(metadata声称非物理删)，no_call_target_present从样本实际tools算是最便宜解药。 |
| L10 灾难遗忘 | P1 | 守rank16Mainline=遗忘三件套防线，缺通用中文混入腿(5-25% hypothesis)，home-llm零通用eval=照搬盲点。 |
| L11 反巧合 | P1 | pass^k(τ²-Bench单跑高估25pp)，C6有samplingSeed+hardPassVariance但只记录不enforce=活样本。 |
| L12 SFT/DPO拒识 | P1 | 0/34的7个demo-critical全0/7真因=训练集0条这4类自然中文非方法错，SFT正例+IrrelAcc死门足够DPO DEFERRED。 |
| L13 LoRA超参 | P1 | rank16Mainline≈ToolACE黄金配方，2602.04998证变体LR调对全0.43-1.75%内，562=格式任务非容量问题。 |
| L14 PEFT新结构 | P2 | 默认DROP守现状，NLoRA代码pinv被注释=claim-vs-code gap，DoRA-rank8唯一零成本escape_hatch。 |
| L15 home-llm | P1 | 数据链路教科书级可adopt，generic-tool surface照搬catastrophic(反向印证A2)，LR守1e-4不照搬2e-4。 |
| L16 治理矩阵 | P0(间接) | 5矩阵已物理化，train_health不imply model_quality=0/34机械答案，贯穿风险=declare≠enforce。 |
| L17 人审破框 | P0(横切) | cross-vendor≠cross-frame有学术铁证(SPECA)，0/34恰是4模型一致PASS集体盲区，7个人审不可委托点。 |
| L18 voice | P2 | 系统ASR砍custom vocabulary→音近增广升级唯一兜底，纯side-memo不进retrain拍板不实装voice。 |

## 二、总体认可度

**18 路调研质量高、纪律严、可信度高。** 三个信号：
1. **一手锚扎实**：每路有本机源码file:line(C5LoRATraining.swift/C5DataGate.swift/C6VehicleToolBench.swift/mlx-lm trainer.py)或本机受票据(metrics.jsonl实测)或clone实读(home-llm/NLoRA),非凭印象。
2. **防编造纪律到位**：external-claims-verification.md主线程已核8 arxiv全真实+11 repo活跃度；各路精确数字/arxiv ID均标【待主线程核】未当事实采用(尤L04 Meta-Harness 2603.28052/Harness-Bench 2605.27922 cutoff后高编造风险已标)。元层自证：finder自己core claim全可溯源，无amnesia调研那种编issue#行为。
3. **steelman守现状不盲从**：L13/L14两路被2602.04998「Vanilla LoRA May Suffice」反复坐实，PEFT新结构全列rejected-with-evidence，DoRA-rank8仅记录不实装——守rank16Mainline主线零动摇。

唯一**质量caveat**：L14 NLoRA代码深拆发现pinv被注释(claim-vs-code gap)、L12 When2Call早期WebFetch幻觉数82.3%已弃，证明finder在搜证压力下有编造倾向但**本批自己catch了**——主线程仍需对load-bearing精确数字(AWS三位小数/SPECA 76.5%/τ²-Bench 81.6→56.1)抽样gh/WebFetch亲核。

## 三、0/34 真根因层对应（别返工的核心）

8D复盘的0/34三根因层 → 18路对应防护：

| 0/34根因层 | 直接防护路(P0) | 机械门 |
|---|---|---|
| **样本不可观测(446假删,metadata声称非物理删)** | L09 | 训练前dry-run sample audit:no_call_target_present从样本实际tools算+label_conflict必0+exit65 |
| **train/eval/runtime surface异源(generic frame)** | L02+L03+L16 | 三方surface_digest取交集+byte-parity端侧render逐字节比+C24 train_health不imply model_quality |
| **generic frame判定面爆炸(1.7B学不会)** | A2已修(D-domain)+L15反向印证 | A2 ToolContractCompiler(已合并main);措辞精确化「未做判定面收窄的generic frame在562规模学不会」 |
| **通宵跑完才暴露(无中途门)** | L05 | 行为生成门iter50/100/150+infrastructure-enforced非codex自审 |
| **审计全PASS漏语义(4模型一致盲区)** | L17 | 7个人审不可委托点+≥1判官刻意反框+high stakes无条件人审 |

**核心结论**：0/34不是配方错(rank16Mainline逐项对齐ToolACE黄金线),是**外围工程4道P0门缺失**(样本可观测/surface同源/byte-parity/中途行为门)。守配方+补这4道门=别返工的最小充分集。

## 四、守现状（steelman 浓缩）

守rank16Mainline+1.7B+home-llm范式正确:①配方逐项对齐FC黄金线+2602.04998证变体无增益 ②本机实测跑得动健康+8GB可行 ③home-llm数据链路教科书级+A2 D-domain是对其教训正确吸收。**辩证caveat**:守配方≠不补门(必补4道P0门);home-llm不能全照搬(LR守1e-4/弃generic surface/补通用eval+ASR增广);PEFT新结构=escape-hatch DEFERRED(DoRA-rank8唯一零成本,仅诊断坐实欠容量才reopen且先排除前4路根因)。

## 五、给磊哥下一步 pre-propose 收敛建议

### 立即可拍（grill 弹药已备，10 题待 grill）
核心9题(见decisions/grill_ammo):①C6四层分母按schema字段拆 ②中途行为门四态阈值 ③四类配比sweet spot 15-20% ④SFT正例vs DPO DEFERRED ⑤byte-parity gate端侧render源闭环 ⑥通用中文混入+回归门 ⑦failure纳入与否 ⑧端侧受限解码选型 ⑨下一步OpenSpec change边界。

### 收敛路径建议（⭐推荐）
1. **先写2个OpenSpec change gate task(不实跑)**：retrain-c5(样本可观测L09+泄漏门L08+配比L07+SFT正例L12) + rebuild-c6(四层门L04+反巧合L11+base recalibration+通用回归L10);byte-parity(L03)分诊归属。治理类落docs/research,实跑训练/评测/voice全DEFERRED。
2. **4道P0机械门优先级最高**(别返工核心)：样本可观测dry-run audit(L09)/surface同源digest(L02)/byte-parity闭环(L03)/中途行为门(L05)——这4道写进gate task的acceptance(可核验N条记录非prose),缺任一即重蹈0/34。
3. **人审7点入task acceptance**(L17)：first-50逐条/loss-mask print/train-eval diff/refusal样本对照home-llm/top-failing/utterance drift/final route,非prose声称。
4. **配比+8GB真机走spike不拍死**(L07/L06/L18):复刻Magnet扫描找over-refusal拐点;8GB jetsam独立真机spike(禁12GB数据冒充);ASR音近/disfluency两hypothesis分开拍。
5. **守现状enforce**：rank16Mainline配方零碰(L13/L14),PEFT变体rejected-with-evidence清单进propose防未来手痒,DoRA-rank8仅记录escape_hatch。

### 措辞纪律（completion-claim-triage）
本调研交付=**评测/数据门设计decision-pack(计划态)**,非训练/评测跑完(执行态)。gate现态=blocked/draft非pass;A2=code-only已合并main,retrain-c5/rebuild-c6实跑须前置门全在才解冻。

---
**一句话**：守rank16Mainline主线零动摇,0/34解药=补4道P0外围工程门(样本可观测/surface同源/byte-parity/中途行为门)+人审7点+异源破框;实跑全DEFERRED,先写gate task把门固化进acceptance,这是「别返工」的最小充分集。
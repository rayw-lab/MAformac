# Stop-the-Train 风险矩阵（全 18 路，核心交付物）

## STOP-THE-TRAIN 风险矩阵（全 18 路汇总，按能否提前阻止 0/34 排序）

> 核心交付物。磊哥诉求=别返工不是知道更多。owner 标 infrastructure-enforced 的=必须机械门非 agent 自审（0/34 正因 codex 自主跑自审无外部门，通宵才暴露）。

### 第一梯队 — 直接阻止 0/34（训练前/中/后硬门，P0）

| # | 风险 | 触发条件 | 提前发现手段 | stop-the-train 阈值→动作 | owner | 需磊哥拍板 |
|---|---|---|---|---|---|---|
| R-L09 | **样本不可观测=446假删复发**(0/34直接根因) | metadata声称删工具但没物理执行tools.removeAll；no-call样本tools仍含目标工具=矛盾监督 | 训练前dry-run sample audit：逐样本从**实际tools**算no_call_target_present(非读metadata)+label_conflict_flag必0 | 任一样本target_present=true或label_conflict≠0→**blocked**(exit65) | retrain-c5数据脚本(infrastructure) | 否(技术铁律) |
| R-L02 | train/eval/runtime tool surface异源(0/34真根因) | 三方surface用不同frame(generic vs D-domain) | A2 ToolContractCompiler消费方三方surface_digest取交集 | 三方hash diff≠0→**blocked** | A2 ToolContractCompiler消费方 | 否 |
| R-L03 | chat-template byte-parity失守(think块offset漂) | 训练含`<think>\n\n</think>`(4token)、端侧推理不含→端侧少4 prompt token | `C5EndpointTokenizerParityGate`闭环：真接mlx-swift端侧render逐字节UTF-8比对+think签名+mask offset起点token | endpointBytes≠trainingBytes→**blocked**(现endpointRendered恒nil未闭环=最大缺口) | retrain-c5 gate(端侧render源DEFERRED) | 否 |
| R-L05 | **中途无行为门，通宵跑完才暴露0/34**(GOV6元层根因) | 只用val-loss门(测不到0/34，loss健康行为全塌) | iter50/100/150抽样generate→解析toolCall→C6第一二层N≥5(走A2同源surface) | golden抽样0/5或fuzz<base相对门→**early_stop**；边界(2/5)→**human_pause**+超时无响应→**blocked** | 训练脚本(infrastructure-enforced非codex自审) | **是**(C14阈值/四态/谁有权停) |
| R-L04 | **C6聚合掩盖复发**(action按全集分母稀释) | 四层汇成overall pass_rate或action按全57/562当分母(tcm&sdm=29看似过半真分母23) | build_axes_from_summary.py按case schema字段(expect_no_call/clarify_tag/scope_tier)拆四层分母 | 任一层用聚合分母/全集分母→门设计**reject** | rebuild-c6(make verify门) | **是**(四层分母口径+base阈值) |
| R-L07 | **负类被砍/配比压倒→irrelevance崩**(ToolACE 6.99%=0/34同根) | 砍unsupported/safety负类，或配比偏向positive致over-call | 四类完整+配比spike复刻Magnet扫6.7%-24%找over-refusal拐点 | 负类样本=0或irrelevance检测<base 0.789→**blocked** | retrain-c5数据 | **是**(C11-C12配比hypothesis待spike) |
| R-L17 | **4模型互审仍集体漏同一frame**(0/34恰是4模型一致PASS) | cross-vendor当cross-frame，majority vote票数当绿灯 | 7个人审不可委托点(first-50逐条/loss-mask print/train-eval diff/refusal样本逐条对照home-llm)+≥1判官刻意反框回读一手 | 人审退化成抽查/看receipt非实跑复算→流程**reject**；高stakes决策无条件人审不论一致 | 磊哥+异源判官(非Claude family) | **是**(人审点入OpenSpec task acceptance) |
| R-L11 | **门本身假绿成第11坑**(receipt写PASS是metadata) | gate读metadata flag或阈值直翻；hardPassVariance只记录不enforce | value-in-source核+异源grader(hermes)+sign-or-block；pass^k门(全k次都过非pooled hardFailures==0) | grader挂→candidate UNSIGNED不降级签 | CI/harness(infrastructure) | 否 |

### 第二梯队 — 防训练发散/二次灾难（P0-P1）

| # | 风险 | 触发条件 | 提前发现手段 | stop-the-train 阈值→动作 | owner | 需磊哥拍板 |
|---|---|---|---|---|---|---|
| R-L13 | LR回2e-4/未守repo-loop clip→loss尖刺 | 照搬home-llm 270m的LR2e-4(本机实测iter80=spike17-32) | NonFiniteTrainingError守护+active-probe验preclip-norm>1真触发clip(T5:clip从未真跑过) | val非finite/spike>阈值→**blocked**(NonFiniteTrainingError) | retrain-c5(配方冻结) | 否(配方守1e-4) |
| R-L08 | **泄漏假胜利**(评测变好实污染=二次隐性灾难) | augment继承seed ID(:252假安全)；只看in-dist+heldout不跑OOD value bucket | gate消费candidate_parent_semantic_id(重判)+embedding nearest-protected双层+OOD真测 | 4类必quarantine(重判落空/review_band near-hit/protected collision/signature撞)fail-closed人审 | retrain-c5数据gate | 是(embedding_model选型+阈值校准) |
| R-L06 | 约束解码掩盖语义塌缩(强制合法但选错工具) | grammar逼模型必吐合法tool_call不含拒识分支→阉割拒识 | grammar必含拒识/no-op/unsupported合法分支+C6加「被迫合法但语义错」轴 | 约束下action正确率≪无约束/拒识被阉割→**human_pause** | golden-run(DEFERRED) | 是(C20 GBNF/XGrammar fallback only) |
| R-L12 | SFT训拒识致over-call/IrrelAcc崩(0/34镜像) | 训拒识正例把该调工具的也拒、或该拒的硬塞toolcall | IrrelAcc≥base 0.789死门+held-out拒识防死记+SAFE-002监督=拒识非调set_door | IrrelAcc<base 0.789→**blocked** | retrain-c5(SFT正例+IrrelAcc门) | 否(DPO标DEFERRED不前置) |
| R-L10 | 窄域SFT灾难遗忘→客户换说法听不懂(上线后炸场) | 不混通用中文+不跑通用eval(照搬home-llm盲点) | C-Eval/CMMLU零样本回归门+held-out paraphrase intent命中率对比base | candidate掉超阈值→**human_pause**(非0/34级，retrain线) | rebuild-c6(回归门) | 是(混5-25%通用中文hypothesis) |
| R-L18 | 系统ASR砍custom vocabulary→错字击穿入口 | 照搬home-llm clean模板对ASR同音错字(空调→空跳)零鲁棒 | 自采系统SFSpeechRecognizer实际错字pair+10%逐字同音增广+held-out干净集 | 干净集退化→放行门reject(复用T7) | retrain-c5数据(voice DEFERRED) | 是(C11-C12音近/disfluency配比) |

### 第三梯队 — paper-tiger/逃生口（P2，从不是瓶颈）

| # | 风险 | 触发条件 | 提前发现手段 | stop-the-train 阈值→动作 | owner | 需磊哥拍板 |
|---|---|---|---|---|---|---|
| R-L01 | 训练栈跑不动(OOM) | peak逼近32GB | 本机实测peak 12.2GB留20GB headroom | 逼近32GB→降seq/--grad-checkpoint(从不需要) | retrain-c5 | 否(paper-tiger硬件从非瓶颈) |
| R-L14 | 被PEFT新论文SOTA数字诱导手痒换配方 | NLoRA「+33.52%」弱baseline刷分诱导采SVD-init | 2602.04998反证+mlx-lm只支持lora/dora/full | 换配方前必先排除前4路根因(surface/byte-parity/行为门/masking) | retrain-c5 propose | 否(DoRA-rank8仅escape_hatch记录不实装) |
| R-L16 | 治理停declare层未enforce(同第10坑) | 5矩阵schema skeleton未接make verify/CI | C05 forbidden_next_action机械化+cite-verify hook | schema未接机械门→治理同0/34第10坑 | CI/harness | 否(接enforce层) |
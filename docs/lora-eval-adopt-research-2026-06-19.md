# C5/C6 LoRA 训练-评测 7-repo adopt 选型研究(2026-06-19)

> 7 个 CC subagent 各 clone 1 repo + pre-mortem 深入读代码(§28 不妄断)。clone 只读参考在 `~/workspace/raw/05-Projects/MAformac/lora-repo-research/`(不进仓)。本表是综合产出(设计资产,进仓供 C5/C6 rebase 用)。
> 数据三源全用:**3990 协议 + 12000 真实座舱 bug + raw intake**。

## 选型总表

| repo | 新鲜度 | adopt 判定 | 给 MAformac 什么(关键 file:line)| 关键坑 → mitigation |
|---|---|---|---|---|
| **Hammer**(MadeAgents)| 119★ / 超1年未动 | adopt 方法学 + port 脚本 | **C5 function masking**:`data_processing.py:66-134`(name/param→随机串)+ `:280-287`(mask 主循环);293 行纯 stdlib 与训练框架解耦,MLX-LM 直接吃 | 1.7B 高 mask 比例拖慢收敛 → ratio 0.67**降 0.4**;补 GOAT/xLAM 更新鲜(§28:无 ICLR 背书,arxiv 2410.04587)|
| **xLAM/APIGen**(Salesforce)| 628★ / 2026-06 活 | adopt 思路 + criticLAM 代码 | **C5 数据三阶段 gate**:`trajectory_critic.py:145-167`(LLM-judge 评分器);格式/mock执行/中文judge + 12000bug 当种子 + arg 程序化采样防死记 | 翻译噪声 → **必中文直生**(禁直译 xlam-60k);过滤层一个不可省(1.7B 小模型)|
| **unsloth**(unslothai)| 66.8k★ / 今天活 | adopt 超参方法学,**framework 不引** | **C5 超参**:r16-32 / alpha=r或2r / lr2e-4 / epoch2 / dropout0.05 / wd0.01;100% 移植 MLX-LM lora_config | Mac 上 unsloth=MLX 壳(`__init__.py:54-90` 委托 unsloth_zoo.mlx)→ 引框架徒增依赖无加速;alpha=r或2r 非旧"r≥alpha"口径 |
| **BFCL/gorilla**(Berkeley)| 12908★ / 2026-04 活 | 方法学全 adopt,集自建 | **C6 四死门现成工程**:`ast_checker.py:333`(AST 值集合 scorer)+ `multi_turn_checker.py:162/259`(state_checker 逐属性=读回态)+ `:132`(irrelevance 门);`vehicle_control.py:18`(VehicleControlAPI=**mock 车控状态机蓝本**)| 英文域 → 集自建;AST 语法对≠逻辑对 → 必叠 state 读回态(MAformac 已锁"读回态为准"天然对齐)|
| **tau2-bench**(sierra)| 1381★ / 8天前 MIT | 部分 adopt 架构(~70%)| **C6 评分**:`evaluator.py:214-249`(**reward=∏分量乘积门控**=任一0则总0=四死门)+ `evaluator_env.py:128-142`(**env_assertion** 端态断言对接 mock 读回,替代 db_hash)+ `tasks.py:178-195`(compare_args 选择性 params 比对)| golden label 错率高(tau-bench 50题24-25题金标误)→ must-pass 人工双核;restraint 漏判 → **MAformac 端态校验天然覆盖(mock 优于 tau2)** |
| **When2Call**(NVIDIA)| 64★ / 当数据集用 | 方法 adopt,集英文不用 | **C5 负样本**:`create_raw_train_data.py:93`(抽走匹配工具→cannot_answer)+ `:100`(删 required 参数→RFI);**C6 IrrelAcc**:`additional_metrics.py:21-48`(hallucination_rate 混淆矩阵)| boilerplate 拒绝陷阱 → refusal 措辞多样化+带理由;负样本比例**卡 30-40% 不照搬 65%** |
| **ACEBench**(华为诺亚)| 187★ / 2025-10 EMNLP | 方法学 + PORT 集子 | **C6 中文原生 eval**:`checker.py:413`(normal_checker 纯AST 零LLM-judge 端侧可跑)+ `:514`(agent_checker 验 mock 态);17 类 case 含 incomplete/irrelevant/similar_api/atom_enum/number 对口车控 | 中文同义词字面漏判(standardize_string `utils.py:82` 不碰中文)→ **车控值收敛 enum/number 参数(走 type_checker)规避** |

## 综合洞察

1. **统一范式:adopt 方法学,集子/数据自建**(7 个里 6 个此判定)——英文域/契约错配,现成集不直搬;但方法学(masking / 三阶段 gate / AST+state scorer / 乘积门控 / 负样本 / 超参)全可移植。中文车控 FC eval 这细分 GitHub 无近 2 月活跃新品(ACEBench 是标杆,诚实标领域现状)。

2. **C5 训练栈(adopt 组装)**:MLX-LM(unsloth Mac=MLX 壳不引)+ Hammer function masking + GOAT arg-token masking + xLAM 三阶段 gate/criticLAM 评分器 + When2Call 负样本生成法 + unsloth 超参方法学。**数据三源全用**,bug→FC 对半自动标注(arg 值多样化防死记)。

3. **C6 评测栈(adopt 组装)**:BFCL(AST + state_checker + irrelevance 门 + VehicleControlAPI 蓝本)+ tau2(乘积门控 + env_assertion 对接读回态 + compare_args)+ ACEBench(中文 case 骨架 + 零 LLM-judge)+ When2Call(IrrelAcc)。集子从三源自建中文车控,must-pass 人工双核金标。

4. **🐘 MAformac 独有红利**:全 mock 车控 → **execution-check / state 读回态校验零成本成立**(xLAM execution gate + BFCL state_checker + tau2 env_assertion 都天然对接)——真车厂做不到,MAformac 反而能。这是 D16 mock 设计的复利。

5. **3 HIGH(承接 oracle pre-mortem,C5/C6 apply 前必守)**:① 防死记(masking + held-out 换说法+没见过arg值+bug_id分层)② 防假提升(同harness同greedy分层打分 + 小集多跑报std + 三层去污)③ 防手痒(IrrelAcc 独立 ≥20% 负样本,验收读回态+IrrelAcc 双指标非只 AST)。

## 新鲜度交叉验证(github-first 硬约束)
一线活跃:unsloth 66.8k今天 / BFCL 12908★ 2026-04 / tau2 1381★ 8天前 / xLAM 628★ 2026-06。
低星/旧但有据:Hammer 119★ 超1年(方法学原始 + stdlib 稳定,补新)/ When2Call 64★(NAACL2025,当数据集)/ ACEBench 187★(EMNLP2025,中文车控细分无更新鲜标杆)。

---
authority: commander_baseline_reflection_post_f044_fail
status: landed_2026-07-03_night（磊哥令「积极思考反思 decisions/openspec/立项基线」）
decision_ref: D-079 / D-080（今晚编排）
basis: F044-VERDICT.md（四重 FAIL）+ 本档全部数字 commander 当场亲核（命令与输出见各节）
---

# F044 FAIL 基线反思：三个被坐实的基线级问题 + 归因链改写

## 0. 核心发现（改写 verdict 的归因链，证据全一手）

🔴 **A 轴「极性反转」的根因不是配比、不是模型——是训练数据矛盾监督（数据 bug 级）**：
- 同一协议串 `device=ac_cooling_mode; primitive=set_mode; slots=no_slots; 请按这个语义执行`：**28 行监督 `open_ac_cooling_mode`，16 行监督 `close_ac_cooling_mode`**（`c5-train-00001` vs `c5-train-01057`，输入逐字相同、标签相反；heating/defog 同构 28:16）。
- 亲核路径：samples 全集 grep（ac 族内极性 open 28/close 16 先反证了「配比失衡」假设——open 反而占优）→ 下钻 close 行协议串 → primitive 同为 `set_mode`，无极性槽。
- 机理：**协议串表示层丢失极性信息**（set_mode 不带 open/close），渲染管线把两种工具映射进同一输入表示 → 矛盾监督 → 模型 greedy 收敛到 close 分支 → eval 期望 open → 系统性「反转」。**模型无罪，学的就是矛盾分布。**
- 历史同病：0/34 灾难 8D 的「矛盾监督」（claim-vs-reality 铁律1）。当年病在假删工具产生矛盾，这次病在协议串表示缺维度产生矛盾——**同一类病的第二次发作，且两次都穿过了全部机械门**。

## 1. 基线问题一：DataGate 缺「监督一致性门」（verification-economics 缺格实锤）
- C5DataGate 有语义 surface 门/redaction/泄漏/hash/quota——**没有「同输入 → 监督必须一致（或显式标注歧义合法）」检测**。矛盾监督 44 行（仅 ac_cooling 一族已知，全集规模待 W6 扫描）穿过 DataGate exit0 + strict preflight exit0 + 250 corpus judge（corpus 是 positive 增广，不碰 substrate 矛盾对）。
- **修法（今晚 W6）**：全量矛盾监督扫描器（group by 归一化 user 输入 → assistant 期望必须唯一，例外需 allowlist）→ 进 DataGate 作常设格。这是「风险类×最廉门矩阵」新格：**监督一致性**，成本=分钟级 python，爆炸半径=整轮训练白跑。

## 2. 基线问题二：协议串表示层（C1→训练渲染 codegen）丢失极性维度（openspec/契约级）
- C1 契约的 mode 类原语（set_mode）在协议串渲染时没带极性/目标态信息，而 D-domain 具名工具面（open_*/close_*）是带极性的——**表示层信息量 < 标签信息量 = 结构性歧义**，任何模型都不可学。
- 波及面待查（W6 输出）：所有「同 primitive 多工具」的 device（set_mode 类最高危；switch/adjust 类的 value 槽是否足够区分待扫）。
- **openspec 反思**：`semantic-function-contract` SSOT 本身可能无损（value 四件套含 ref/direct），是**协议串训练表示的渲染约定**（哪些字段进 user 串）丢了维度——修法在渲染器不在契约；但若契约的 set_mode 原语本身无极性字段，则要回 C1 开窄 change。W6 先定位丢失点在哪一层。

## 3. 基线问题三：eval bundle A/B 轴覆盖=纯 ac 族（评测基线偏斜）
- 亲核：A 轴 15 case 期望工具全部 ac 族（cooling×4/heating×4/defog×2/set_interface×3/close_ac×1/airoutlet×1），B 轴同构。**「协议记忆 15/15」实测的是「ac 族记忆」**——其余 9 族协议映射从未被 A/B 轴测过。
- 判定不变（FAIL 就是 FAIL），但：①A FAIL 的 blast radius 表述要收窄为 ac 族 ②**R2 必须扩 bundle 到 10 族**（否则 round 2 PASS 也只是 ac 族 PASS）③ 这与 WD-14「10 族顶层覆盖」形成对照——数据面盘过覆盖、评测面没盘过，**盘点纪律要对称**。

## 4. 附带反思（次级）
- **F-044 A 15/15 底线的语义**：锚自 v6 tiny（44 行死记训练）；wave-1 是 4350 行×~2.2 epoch 泛化训练，两种形态的 A 轴期望不同层。R2 grill 拍「阈值是否分形态」（口径型，磊哥或 default 拍）。
- **substrate 语义审计覆盖缺口**：4500 substrate 只过机械门+历史验证，**现行 judge 体系只审过 250 corpus（5.3%）**——多数派数据的语义正确性依赖跨三次迁移的历史验证。矛盾监督正藏在这 94.7% 里。W6 扫描部分补此账。
- **openspec carrier 滞后**：wave-1/F044 实际走 run-dir receipt 体系，`retrain-c5-lora-d-domain`/`run-lora-candidate-training` changes 停在 DEFERRED 时代框架。今晚不动（非阻塞），R2 grill 列一题定 carrier 对应。
- **正面确认（不翻案）**：短训评制度、预落档决策树、评分器口径复算、三层 PASS 拆分全部工作正常——4h+20min 抓到矛盾监督这种「必然白跑正式训练」的病，失败到达点经济学再次兑现。

## 5. 三层维度认知（磊哥节律）
- 维度一（事实重述）：FAIL 四重成立但 A 轴归因改写=矛盾监督（数据 bug）非模型/配比；「积极但错」（codex）成立且机理=学了矛盾分布的 greedy 坍缩。
- 维度二（机制补丁）：监督一致性门进 DataGate；eval bundle 扩 10 族；R2 grill 走范式。
- 维度三（系统原理候选，过 Elevate-or-Kill：被本次事故检验）：**「分布内指标对分布结构缺陷天然盲」**——val loss 0.019/DataGate 绿/preflight 绿都检测不了「分布本身的洞与矛盾」（负例真空是洞、矛盾监督是自相矛盾），只有 **out-of-recipe 行为评测 + 分布结构审计（配比矩阵/一致性扫描）** 能到达。落 rule 补腿。

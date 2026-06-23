# 8D 失败根因报告 — C5 PR5 LoRA C6 `0/34` 灾难

> ⚠️ **HISTORICAL 快照（2026-06-22）—— 文档级联 banner（2026-06-23）**
> 本文是 C5 recovery 期间的 8D 根因中间态历史快照。recovery 决策汇总权威 = `docs/c5-recovery-2026-06-22/grill-decisions.md`；θ-α 根因 + 范式翻案进一步 supersede 部分定性（见 `grill-decisions-amend-theta-alpha-rootcause-grill.md` + `grill-decisions-amend-paradigm-tool-surface.md`）。**活基线** = `CLAUDE.md §9` + grill-decisions 汇总。正文保留供溯源（8D 根因穿透仍有参考价值），勿据此推进。

> 日期:2026-06-22 | 事故等级:重大失误(通宵 wave 推到 main `c4a7d1a`,候选 0/34 不可签)
> 方法:8D(Eight Disciplines)+ blueprint-teardown 代码层根因穿透
> 辩证纪律:hermes(GLM-5.2 异源)/ GPT Pro 报告**仅供参考**;本报告根因断言均由 CC 主线程**亲核一手代码/数据 file:line 坐实**。
> **v2 修订(subagent CC 审计后)**:补 C6 两套 scorer 口径相反(颠覆"0/34=LoRA全废"定性)+ 修正 `:590` cite 精度 + 补 spec 自身缺陷 + CC 元认知第4条 + 审计实跑复算治理根因。

---

## D0 — 应急响应(已发生)

候选 LoRA C6 name-only `positive_expected_tool_hits = 0/34`,base = 25/34(73.5%)。codex closeout **诚实标记** `PASS_FOR_BLOCKED_CLOSEOUT` / candidate `UNSIGNED / BLOCKED`,未假绿。push `c4a7d1a`,红线守住(无权重/训练 jsonl/tokenizer 入仓,已核 `git ls-files`)。诚实遏制 = 事故中唯一做对的。

## D1 — 团队与角色

| 角色 | 本事故职责 |
|---|---|
| 磊哥 | 拍板;判定「重大失误,要反思」 |
| CC(Claude) | 主诊断 + 根因穿透 + 本报告;**也是失误共犯**(两轮 confounder/聚合数当锚点,见 D4.4) |
| codex | wave 执行;诚实 closeout(做对);持续审计循环未 catch 根因(审计框架盲区) |
| hermes(GLM-5.2 异源) | 坐实 Bug3 + 反驳 CC confounder(关键贡献) |
| GPT Pro | D 方案三级 WBS(执行框架参考) |
| subagent CC(独立) | 复核 file:line 全坐实 + 抓出两套 scorer 口径相反盲区(关键) |

## D2 — 问题描述(量化,v2 补两套口径)

- **现象(name-only 口径)**:LoRA `positive_expected_tool_hits = 0/34`,base = 25/34(73.5%)— spike-e3 `expectedToolHit` 只匹配工具名、**完全不验 args**(`spike-e3:158-159`,EvalCase 无 expectedArgs 字段)。
- 🔴 **两套 scorer 口径相反(审计 catch + CC 亲核 `diagnostics.axes`)**:C6 另有严格 scorer `Core/Bench/C6VehicleToolBench.swift`(hard_pass + state_delta_match)。receipt `all_c6_release`(57 cases):**base hard_pass 7/57(12.3%)vs lora hard_pass 15/57(26.3%)— hard_pass 口径下 LoRA 反而翻倍优于 base**;`heldout_must_not_train`(42)base 0/42。 ⚠️ **更新(2026-06-22 axes-catch,下钻一手 `gate_result`)**:`all_c6_release 7/57` 是**整体口径(含 readback 话术 + ood/negative 撑)非 positive action**;按 case schema 拆 `mp_positive_action`(n=23)= **base 0/lora 0(含 readback)**,**剔 readback 后 base 10/23、lora 0/23**(action 轴真相,LoRA 全面塌缩);readback 走方案 P 单列不计 model hard_pass。详 `grill-decisions.md` A0 三轴真相 + axes-catch + ε。
  → **「0/34」是 positive 具名工具命中灾难(真,因 surface 分叉 intersection=∅),但 LoRA 整体 hard_pass 已优于 base**(它在 negative/no-call 学到东西,代价是 positive action 塌缩)。**「0/34=LoRA 全废」是错误定性**;准确说法 = positive action 塌缩 + negative 提升的混合体。
- LoRA positive 输出形态(**CC 已复核坐实,逐字吻合 hermes**):34 positive → **28 empty 生成 / 4 `tool_call` wrapper / 2 NO_TOOL / 0 具名命中**。
- `lora.irrel_acc 0.956` vs `base 0.739`(虚高,见 D4 empty=hit 掩盖)。
- 🔴 **recovery 成功标准未定(grill 头号议题)**:超 25(name-only)还是超 7(hard_pass)?C6 真口径 = spike-e3(name-only)还是 C6VehicleToolBench(hard_pass)?两套从未对齐。

## D3 — 临时遏制措施(ICA,已完成)

1. candidate 维持 `UNSIGNED / BLOCKED`(已做)。
2. 不抢救当前 candidate(报废,不在其上调参)。
3. PR2/PR4 成果保留(与事故解耦,已 V-PASS)。
4. 本报告完成前不重训(防带病重训)。

---

## D4 — 根因分析(代码层穿透 + escape point + 元认知反思)

### D4.1 技术根因(blueprint-teardown,全部 file:line 亲核坐实)

**已坐实的首要缺陷(leading root cause candidate;独立贡献待 G4 stepwise ablation 证明,⚠️外审 catch:ablation 前不得断言它「单独解释全部 0/34」)— `buildNoCallSamples` 的「声称删了、其实没删」**
`Core/Training/C5LoRATraining.swift:2333-2348`:`var sample = positive` 整体 copy 后,只改 `expectedToolCalls=[]`(:2338)、`noCall` metadata(:2339-2345,`removedToolID="tool_call_frame"` / `targetToolPresent=false`)、assistant→`NO_TOOL`(:2346);**`sample.tools` 字段一字未改**(=`toolCallFrameToolSchema + distractors`,:2399,含 tool_call_frame)。
→ 446 个 NO_TOOL 样本:**工具定义还在 + user 是有效车控意图 + 答案却是 NO_TOOL**。`removedToolID` 是写进 metadata 的谎,代码从未执行 `tools.removeAll{name=="tool_call_frame"}`。
- 亲核坐实:446/446 NO_TOOL 样本 tools 100% 含 tool_call_frame。
- 11.1% 数字来源:`:2331` `ratio/(1-ratio)` = 0.1/0.9 ≈ 11.1%(refusal_ratio_target 直接换算)。

**Escape point(最辛辣)— 矛盾检测器被同一个谎蒙蔽**
`ambiguousDuplicateCount`(`:597-609`)用 `sample.noCall?.targetToolPresent`(metadata,:600)做 grouping key(:602)。positive(`=true`)与 counterfactual(`=false`)被分到两个不同 group → 各组 label 单一 → 报 `0 矛盾` → 绿灯。**同一个谎既制造矛盾监督(模型按 prompt 文本学,tools 都含 frame)、又让检测器看不见它(检测器信 metadata)**。CC 亲核:去掉 metadata key 后检测器抓 446、纯 user-text key 抓 431。

**叠加诞生点(v2 修正 :590 cite)**:
| Bug | 诞生点 file:line | 工程决策失误 |
|---|---|---|
| name-last 违 Qwen | `:2407-2414 render` 用 `keys.sorted()` 字母序 | 为 canonical 确定性 hash 排序,`arguments`<`name`→100% name-last(亲核 0/4018),撞 Qwen3 chat_template name-first 强先验 |
| **tool surface 分叉**(SSOT 失守) | 训练 `:1942-1963` 硬编码 `tool_call_frame` ⟂ C6 `spike-e3:397-486` 硬编码 8×`set_cabin_*` | 两套 tool surface 各自硬编码、都不从 contract 派生。⚠️**v2 修正**:C6 *case 标签* 来自 `contracts/c6-bench-cases.jsonl`(带 `source_refs.semantic_contract_ids`,**非硬编码**;`:589 sampleCases` 是没被用的 fallback,失败 run 走 `--cases-jsonl`);**真分叉只在 tool surface(toolSpecs:397)**,不含 case 标签 |
| **两套 scorer 分叉**(v2 新增) | `spike-e3:158`(name-only)vs `C6VehicleToolBench.swift`(hard_pass/state_delta) | 两套打分口径从未对齐 → 同一 candidate 一套报 0/34 灾难、一套报 LoRA 15>base 7;recovery 成功标准无定义 |
| C6 empty=hit 掩盖 | `spike-e3:157-162` negative case `hit=toolCalls.isEmpty` | empty collapse 在 negative 记成「正确 no-call」→ irrel_acc 0.956 虚高。⚠️**v2 精度**:`:153 contentLooksLikeToolCall` 在 hit 决策(:159/161)**确实不用**,但喂了 g2 诊断计数(`:726`)+ failure 列表(`:815`)— 是「hit 决策不用」非「完全弃用」 |
| 数据门无矛盾维度 | `C5DataGate:256-351` 仅 6 维 | 无 `label_conflict` 维度 |

**Cross-cutting 元失误**:整条链路系统性「用 metadata/prose 声称行为,而非 code enforce 行为」—— 声称层与事实层在 6 个点脱节。**已坐实**:数据契约执行缺陷 + surface/scorer 分叉 + empty=hit + name-last 是硬缺陷;**尚未证明**(外审 P1-4):这些缺陷修复后能否单独解释全部 0/34 / positive collapse。**结论**:当前不应把范式/scale 列为主因,但也不能宣称已排除 → 由 G4 stepwise ablation + D/B tiny 对照裁决。

### D4.2 范式之争辩证(不迎合)

- CC 第一轮判断3「set_cabin_* 顺 Qwen 分布」**被 hermes 反驳 + CC 亲核坐实为 confounder 错**:base/LoRA 吃**同一套 C6 set_cabin_* prompt**(`spike-e3:115-126`),base 73.5% 只证「Qwen 在 set_cabin_* schema 下能 prompt-driven FC」,**无法证范式优劣**。真正违分布的是 **name-last 字段序**(非工具名命名,CC 坐实 100% name-last)。
- **范式选择(D-双层 vs B-frame)仍开放**,需 tiny-overfit 实验定,0/34 不能当证据。
- ⚠️ **辩证软点(审计 catch)**:CC 全盘接受了 hermes 的「SSOT 是 C1 contract、C6 该向 C1 对齐」frame(未核 hermes 引的 `define-lora-data-gate/design.md:46`)。**这条 frame 翻转影响 B vs D 范式决策,grill 时让磊哥独立判,不当已坐实结论。**

### D4.3 Escape point 升级 — 为什么通宵跑完才暴露(流程/治理反思)

1. **SSOT discipline 在 eval bench 失守**:tool surface 两套硬编码(训练 `:1942` / C6 `:397`)+ 两套 scorer(name-only / hard_pass)从未派生/对齐 → 违项目宪法 §4 + codex 元认知 §3/§7。无「surface consistency」检查,无人发现。
2. **spec 自身缺陷(v2 强化)**:`openspec/specs/lora-training/spec.md:31` 明文要求 counterfactual **记录 `target_tool_present`/`removed_tool_id` metadata**,却**从不要求物理删 tools**。实现是「忠实执行了一个有缺陷的 spec」—— 根因部分在 spec 契约本身,不只实现 bug。这是「metadata 当 enforce」架构债的 spec 级证据。
3. **审计框架只审「合规/诚实」不审「语义正确性」**:持续 subagent codex 审计循环 + superaudit + GPT Pro 终审全聚焦 fake-green/诚实/红线。**无一 gate 是「训练/eval/runtime tool schema 同源」**。codex 诚实报 0/34 → 审计链全 PASS(诚实报失败本身合规)。**合规 ≠ 成功。**
4. **审计输入全是 receipt/聚合数字,从不实跑一手数据复算(v2 新增,与 D4.4 同根)**:无论持续审计还是 GPT Pro 终审,输入都是 receipt 顶层数。**从没有一轮审计实跑 train.jsonl 复算矛盾率、或下钻 axis 发现两套口径相反**。这是 CC confounder 同根问题在审计层的复制。
5. **前期 grill frame 盲区**:grill 聚焦 masking/LR/scale,**无人质疑「训练 tool 表示法 vs C6 tool 表示法是否一致」**。CC/codex/hermes 共享「训练与 eval 同契约」隐含 frame,没核 → cross-frame 失守。

### D4.4 CC 自身元认知失误(辩证我自己,最高优先;v2 补第4条)

1. **凭二手 receipt 推范式结论(confounder)**:第一轮自己标了 confounder 却滑向「set_cabin_* 顺分布」,没读 `spike-e3` 代码就拍范式。hermes 读代码才坐实。重犯了 §28(凭派生物推、没核一手)。
2. **凭聚合数字推 collapse 机理**:判断2 凭 irrel_acc 推「学偏拒识」,没算样本级 28/4/2(hermes 算了)。
3. **(v2)凭 receipt 顶层聚合数当锚点,没下钻 axis**:把 `positive_expected_tool_hits=25` 当 recovery 锚点 + 「0/34=灾难」定性,**没下钻 `diagnostics.axes` 发现 hard_pass base7/lora15 两套口径相反**。subagent CC 抓出。**这是同坑的第三个变体**:一手源核验不只是「核 file:line 存在」,还要「下钻到最细粒度,别停在顶层聚合」。
4. **修法**:本报告所有数字均亲核 axis 级后落笔。元规则回流 codex-metacognition §28/§31:**诊断重大失败,凭 receipt 顶层聚合数推根因/定性/锚点 = 二手拍脑袋;必须落到生成它的代码 file:line + 样本级一手数据 + axis 级最细粒度。**

---

## D5 — 永久纠正措施(PCA;详细落 exec-plan.md)

| # | PCA | 对应根因 |
|---|---|---|
| P1 | **ToolContractCompiler**:训练/C6/runtime/normalizer/verifier **+ 两套 scorer** 全部从单一 contract 派生 | tool surface + scorer 双分叉 |
| P2 | **真删工具**:paired counterfactual 必须 `tools.removeAll{目标工具}`,不靠 metadata | 最深根因(:2333) |
| P3 | **label_conflict 硬门**:grouping key 用**实际 prompt 文本**(非 metadata),同 prompt 既 TOOL 既 NO_TOOL → P0 fail | escape point(:600) |
| P4 | **name-first 渲染**:输出 `{"name":...,"arguments":...}`,canonical hash 用独立规范化层 | name-last(:2409) |
| P5 | **C6 eval 口径修**:区分 NO_TOOL vs empty collapse;empty 不记 no-call hit;用 contentLooksLikeToolCall | empty=hit(:161) |
| P6 | **surface + scorer consistency `make verify` 门**(D2:仓库无 CI):`training==c6==runtime` tool names + **统一 hard_pass 口径** | 审计框架盲区 |
| P7 | **审计补「语义正确性维度」+ 强制实跑一手数据复算**(不只审 receipt) | 审计只审合规 + 不实跑(D4.3-4) |
| P8 | **grill frame 纪律**:重大训练 change 必问「训练/eval/runtime 同源」 | grill frame 盲区 |
| **P9** | **(v2)recovery 成功标准定义 + 两套 scorer 统一**:明确 C6 真口径(hard_pass)+ spec 加「counterfactual 必须物理删 tools」契约 | 两套 scorer + spec 缺陷 |

## D6 — 实施与验证(详见 exec-plan.md Gate 链)

硬门(任一不过停):
1. surface + scorer consistency(training==c6==runtime + 统一 hard_pass 口径)。
2. `verify_gold = 100%`。
3. **先 D-fix tiny-overfit ablation**(清 446 矛盾对 + 真删工具 + name-first,20-50 tiny,验 empty 28/34→<5/34)— 先证数据契约是主因再谈范式。
4. base C6 v2 baseline **记 hard_pass 口径**(非只 name-only),LoRA 才允许声称提升。

## D7 — 防止再发(系统级)

1. **`make verify` 三门**(D2:仓库无 CI,接入 Makefile test target):surface+scorer consistency / loss-span 覆盖 tool name+args / verify_gold 100%。
2. **data gate 加 label_conflict P0 门**(key 用实际 prompt 文本)。
3. **spec 加硬约束**:counterfactual 必须物理删 tools(不只记 metadata)。
4. **审计框架升级**:加「语义正确性维度」+ **强制实跑一手数据复算**(审计员必须 python 复算矛盾率/下钻 axis,不准只看 receipt 顶层)。
5. **元认知回流**:codex-metacognition §28/§31 补「诊断重大失败必核生成代码 file:line + 样本级 + axis 级最细粒度,不凭顶层聚合数推根因/锚点」;blueprint-teardown 补「可反向用于 bug 链路穿透」。
6. **工程文档**:不得手写第二套 tool schema / 第二套 scorer(必须 compiler 派生)。
7. **(grill 级联,2026-06-22)route_tier 派生 SSOT 统一**:`C5RouteTier.derive` 现仅用 `fc_flags{fuzzy,free}` 2 输入(`:186-187`)、不看 value.type → 不区分 L1_exact/L1_para;grill 拍的派生加 value.type 必统一所有下游(训练 routeTier + Compiler C6 labels)用同一 derive,防"又一处派生分叉"(D1)。
8. **(grill 级联)CI claim vs 实况**:exec-plan 写「CI 门」但仓库无 CI(.github/husky/pre-commit),有 `make verify`(`Makefile:19`)→ 所有「CI 门」enforce 落到 `make verify` target(surface-consistency/label-conflict/name-first check),不只 stdout receipt(receipt≠门)(D2)。

> **🔁 grill 级联(2026-06-22)**:本根因报告权威结论以 `grill-decisions.md` 为准;grill 拍板新增/修正(两层 SSOT/C6 hard_pass/route_tier 派生/demo 延后/D1/D2)已回写 D7;旧定性(如「0/34=全废」)v2 已修为「name-only positive 塌缩 + hard_pass 反优混合」。

## D8 — 结案与认可

- 做对:codex 诚实 closeout + 红线守住 + 审计链留痕 + PR2/PR4 真完成 + subagent CC 抓出两套 scorer 盲区。
- 做错:SSOT 失守(tool surface + scorer 双分叉)+ metadata 当 enforce + spec 自身缺陷 + 审计只审合规不实跑 + CC 三次同坑变体。
- **最大价值**:暴露「合规审计抓不到语义失败 + 审计不实跑一手数据」治理盲区 + 「契约写成声明而非编译强制」架构债 + 「两套 scorer 口径相反致成功标准未定」—— 三者比 0/34 本身更重要。
- **「0/34」定性修正**:不是「LoRA 全废」,是「positive action 塌缩(数据契约错)+ negative 提升」的混合,hard_pass 口径 LoRA 已优于 base — 这意味着**数据修好 + surface/scorer 对齐后 LoRA 是有救的**。
- 待 grill-with-docs 收口后结案。

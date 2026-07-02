这版继续往下挖了一层：问题不只是 loss span 没训全 assistant。更深的第三根因是 训练输入面和探针输入面错配：训练 user 是 device=...; primitive=...; slots=... 这种协议语句，探针是“有点冷”这类自然中文。所以当前 tiny 实验同时在考输出格式、协议映射、自然语言 NLU、未见工具泛化，已经不是干净的“过拟合/记忆裁决”。
文档结论我定为：
BLOCKED_INVALID_FOR_PARADIGM_VERDICT
意思是：这次失败有效证明了 tiny 实验器材不成立，但不能证明 D-domain LoRA 范式失败，也不支持调 LR/rank/scale/clip/iters。
路线图拆成 8 段：先 stop-the-line 重标，再修 loss/augmentation 契约，再修代码和 coverage gate，再重设计 tiny probe 四轴，之后才允许 v6 rerun、wave-1、formal LoRA，最后补 governance 的 fit-proof 列。
校验：本轮只新增这一份文档，未触碰已有脏文件 docs/c5-training-readiness-grill/landing-matrix.md。未跑测试，因为是 docs-only 分析/路线图。磊哥，我的判断：**这不是单点 bug，是一类“门绿但目标语义没被训练/没被消费”的冰山问题。**
我建议你拍 **A**，但要加一个前置硬门：**assistant supervision coverage gate**，否则只修这一处，后面 wave-1/formal 还可能以别的形态复发。

**两次抽象升级**
1. **从症状到机制**
   症状是 34/34 empty，模型重复 `NO_TOOL`。机制不是模型不会学，而是正样本只训了 `open_ac_cooling_mode` 这类孤立函数名，`<tool_call>`、JSON 骨架、`arguments`、闭合标签都被 `-100` 掩掉。NO_TOOL 却是完整输出，所以模型学到的唯一“完整句型”就是 NO_TOOL。

2. **从机制到治理缺口**
   更大的问题是：`data_gate_ready`、`train_on_turn=true`、offset fixture、adapter 落盘、loss 下降，各自都能绿，但它们没有共同证明一句话：**模型实际被监督了下游 parser/harness 需要的完整输出对象。**

**冰山扩散图**
| 维度 | 类似风险 | 人审/机器门要补什么 |
|---|---|---|
| C5 data builder | payload 有，但 loss 没训关键 token | 每条 tool-call 行必须证明 wrapper/json/name/args 至少 parser-critical tokens 被训 |
| loss mask | `function/arg masking` 被误当 loss span | 拆名：augmentation flags 和 loss objective profile 分离 |
| NO_TOOL | no-call 行是完整目标，positive 是碎片目标 | 比 row ratio 更重要的是“完整输出监督 token share” |
| offset fixture | offset 对，不代表目标充分 | fixture 加 coverage，不只验证 span 能对上 |
| DataGate receipt | `ready` 不等于 learnable | receipt 必须带 supervision coverage digest |
| E-2 subset | 解决装载预算，不解决训练目标 | subset 不能被拿来解释 34/34 empty |
| Gate7 generator | 生成更多样本也可能更多碎片标签 | wave-1 前先锁 loss contract |
| C6/harness | 能判 empty，但发现太晚 | 训练前加 L0 learnability gate |
| runtime grammar | grammar 可能把坏模型“扶正” | 不能用 runtime grammar 绿替代 LoRA 行为绿 |
| 管理流 | 机械问题被逐个闯过，语义问题最后暴露 | 每次真跑前要有“样本目标可学性”人工 spot-check |

**我会这样回 commander**
拍 **A**：`train_on_turn` 的语义改成 **prompt 掩、assistant turn 全训、think 仍掩**。
B 只适合做回归测试或 coverage 枚举，不适合作为主实现，因为枚举 wrapper/name/args 容易继续漏掉格式细节。

但 A 不能裸跑，补三条硬要求：

1. 加 `assistant_supervision_coverage` 预检：
   tool-call 正样本必须覆盖 `<tool_call>`、`</tool_call>`、JSON `{}`、`"name"`、函数名、`"arguments"`、参数 key/value；no-call 才训完整 `NO_TOOL`。

2. 改概念名：
   `functionName/argumentName/argumentValue` 归到 **augmentation**，不要再表达 loss mask。loss 只认 `assistant_full_except_think` / `no_tool_full` / `diagnostic_span_only`。

3. 同 44 样本重跑仍需新授权，且只算 tiny adjudication 复跑；不允许顺手开 wave-1、调 LR/rank/阈值、扩样本。

**要纠正一句**
“范式未被证伪”这句话可以保留，但要窄化：
**D-domain/LoRA 路线未被证伪；当前 C5 trainable_v0 的监督契约已经被证伪。**
如果不这么写，后面很容易把一个真实 P0 包装成“只是实现小坑”。

我的建议是：**拍 A + coverage gate + 同 44 样本 tiny 复跑**。这一步过不了，formal LoRA 长跑不该继续。⏺ 按 skill 执行——先补一手证据（扩散出的最重疑点：探针集与训练集的重叠度，这决定 tiny
  实验设计本身是否成立），再出报告：

⏺ Bash(python3 - << 'EOF'
      import json, glob, os…)
  ⎿  探针 34 case：说法级重叠 0/34，期望工具在训练集出现过 4/34
     训练集 user 说法数: 32 训练集工具名数: 16
  ⎿  Allowed by auto mode classifier

⏺ 扩散第一刀就挖出第二根因：探针与训练集说法零重叠、期望工具仅 4/34 重叠（训练集只含 16 个工具名）——即使
  span 修对，这个实验设计也几乎必 fail。完整冰山报告：

  ---
  结论

  是冰山。可见 bug（34/34 NO_TOOL）之下压着两层冰：机制层 = "masking" 一词的两种机制（数据增广 vs loss
  掩码）被混成一种实现；体系层 =
  全部验证门都在验「机制自身真不真」，没有一个门验「机制对目的够不够」（fit-for-purpose
  门整体缺位）——且同款缺位已扩散到探针设计、grammar、subset 分组、readiness 语义等至少 7 处。

  1. 可见 bug

  - 用户看到：tiny-ablation 34/34 NO_TOOL 重复，verdict blocked。
  - 系统本应：40 正例过拟合后 empty <5/34。
  - 当前修复声称（我上一轮的 ⭐A）：span 改全 assistant turn 即可——本报告证明这只修一半。

  2. 证据链（全一手）

  ┌──────────────────────────────────┬─────────────┬────────────────────────────────────────────────┐
  │             Evidence             │  Location   │                    证明什么                    │
  ├──────────────────────────────────┼─────────────┼────────────────────────────────────────────────┤
  │ trainable_spans 仅 function_name │ train.jsonl │ <tool_call> 骨架全被                           │
  │  20 字符/71 字符全文             │  逐条亲读   │ -100，模型未被监督过输出结构                   │
  ├──────────────────────────────────┼─────────────┼────────────────────────────────────────────────┤
  │ 覆盖率 median 29.7%/min          │ 44 条       │ 哨兵数字一直在 preflight 里，无 sanity         │
  │ 12%，全集 209 tokens             │ python 亲算 │ 门扣扳机                                       │
  ├──────────────────────────────────┼─────────────┼────────────────────────────────────────────────┤
  │ raw_output:                      │ probe/ 逐   │ 非沉默——模型学会了唯一被完整监督的形态并重复   │
  │ NO_TOOL.NO_TOOL...×34            │ case        │                                                │
  ├──────────────────────────────────┼─────────────┼────────────────────────────────────────────────┤
  │ 🔴 探针×训练重叠：说法           │ 本轮 python │ 第二根因：探针全 held-out，测的是 40           │
  │ 0/34，期望工具 4/34（训练集仅 16 │  亲算       │ 样本跨工具泛化 ≠ F-044 的过拟合记忆语义        │
  │  工具名）                        │             │                                                │
  ├──────────────────────────────────┼─────────────┼────────────────────────────────────────────────┤
  │ P1-C                             │ CLAUDE §9 / │ 术语混淆早有预警，实现层仍掉坑（grill          │
  │ 锁定结论「三形态实为两类机制」   │  p1c-grill  │ 预判≠实现免疫，第 N 次）                       │
  └──────────────────────────────────┴─────────────┴────────────────────────────────────────────────┘

  3. 链路 teardown

  Expected: 40 正例监督全输出 → 模型记住「结构+名」→ 探针(含已见 case)复现 → <5 empty
  Observed: ①监督只给名不给结构（span 混淆）→ ②探针全没见过（六轴 held-out 切太狠）
            → 模型只会 NO_TOOL → 34/34
  Hidden seams: "masking" 多义 → 实现单义化；F-044「过拟合」语义 → 探针集设计从未对齐它；
                preflight 哨兵数字（209）无阈值门

  4. 冰山扩散（抽象两次后扫全项目）

  抽象①机制级：同名概念两机制混用。抽象②体系级：机制真 ≠ 目的适配，fit-for-purpose 门缺位。

  ┌────────────────┬─────────────────────────────────────────────────────┬─────────┬─────────────────┐
  │   Direction    │                        Risk                         │ Evidenc │    Severity     │
  │                │                                                     │    e    │                 │
  ├────────────────┼─────────────────────────────────────────────────────┼─────────┼─────────────────┤
  │ 🔴 tiny        │ 只修 span 重跑 → 大概率再 fail →                    │ 重叠    │ P0（重跑前必修  │
  │ 重跑设计       │ 反向移门：误判范式不行                              │ 0/34    │ ）              │
  │                │                                                     │ 一手    │                 │
  ├────────────────┼─────────────────────────────────────────────────────┼─────────┼─────────────────┤
  │ wave-1         │ 同一术语混淆的另一半：argument_value「增广」若再被  │ 本次实  │                 │
  │ augmentation   │ 做成 loss span = 同坑                               │ 证      │ P1              │
  │ 实装           │                                                     │         │                 │
  ├────────────────┼─────────────────────────────────────────────────────┼─────────┼─────────────────┤
  │ grammar artifa │ grammar 允许 NO_TOOL + 模型偏科 NO_TOOL = runtime   │ 本次    │                 │
  │ ct（G7A）      │ 全部「合法拒识」，C6 unsupported 层假绿（拒识正确性 │ 34/34   │ P1              │
  │                │  vs 拒识倾向性混淆）                                │ 预演    │                 │
  ├────────────────┼─────────────────────────────────────────────────────┼─────────┼─────────────────┤
  │ E-2 subset     │ 7 组按 token 预算切（机制真），「NLU                │ G7A     │ P2（Phase-2     │
  │ 分组           │ 可路由性」适配未验                                  │ 产物    │ 前验）          │
  ├────────────────┼─────────────────────────────────────────────────────┼─────────┼─────────────────┤
  │ C6 判等口径    │ hard_pass 判等对 demo 目的的适配——c5-recovery       │ 历史    │ P2              │
  │                │ 已有先例（7 个 demo-critical base/lora 双 0）       │         │                 │
  ├────────────────┼─────────────────────────────────────────────────────┼─────────┼─────────────────┤
  │ preflight      │ trainable 覆盖率/token                              │ 209 躺  │                 │
  │ 哨兵无门       │ 数输出了没人拦；同款：tokens_per_second、probe      │ 过全程  │ P1              │
  │                │ elapsed                                             │         │                 │
  ├────────────────┼─────────────────────────────────────────────────────┼─────────┼─────────────────┤
  │                │ landing「✅ construction」不含目的适配 → 8 gate 全  │         │                 │
  │ readiness 语义 │ ✅ 产生「就绪」体系错觉（gate2 双异源 CONFIRMED 后  │ 本次    │ P1              │
  │                │ tiny 一跑就爆的正是这个）                           │         │                 │
  └────────────────┴─────────────────────────────────────────────────────┴─────────┴─────────────────┘

  5. Tiger / Paper-tiger / Elephant

  - 🐯 探针-训练零重叠（P0）：重跑前不修 = 白跑 +
  误判范式。验证清单：重跑探针集必含训练内说法子集（记忆轴）+ 少量近邻变体（近泛化轴），分账报告。
  - 🐯 augmentation 术语雷：wave-1 SPEC 必须带「两机制术语表」（loss-mask=监督信号范围 /
  augmentation=数据内容变换），实装前 fixture 验语义归属。
  - 🐅 paper-tiger：LR/配方——loss 2.11→0.16 正常下降、零 NONFINITE、grad
  有限：数值链路健康，rank16Mainline 配方本身无罪，不要动它。
  - 🐘 elephant：fit-for-purpose 门在治理体系里没有位置——landing-matrix 没这列、审计 SPEC
  没这维度、readiness 词表没这级。每个人都把「机制真」审到了极致（这是我们 9
  次拦截的强项），但「够不够」无人负责。

  6/7. 体系反思（合并）

  ┌───────────┬────────────────────────┬─────────────────────────────────────────────────────────────┐
  │   Layer   │          Gap           │                             Fix                             │
  ├───────────┼────────────────────────┼─────────────────────────────────────────────────────────────┤
  │           │ 全是 mechanism-true    │ landing-matrix                                              │
  │ 验证体系  │ 门，无 fit-for-purpose │ 加「fit-proof」列（哪个真跑证明该环对目的有效）；tiny       │
  │           │  门                    │ 类小真跑就是天然 fit-proof 工具                             │
  ├───────────┼────────────────────────┼─────────────────────────────────────────────────────────────┤
  │ 术语/契约 │ "masking" 多义无术语表 │ 契约级术语表：loss_mask（监督范围）与                       │
  │           │                        │ augmentation（数据变换）分字段分文档，禁混名                │
  ├───────────┼────────────────────────┼─────────────────────────────────────────────────────────────┤
  │ 机械门    │ preflight              │ 加 trainable-coverage 门（train_on_turn 语义下 assistant    │
  │           │ 哨兵数字无阈值         │ 覆盖 <90% fail）+ 探针-训练重叠度声明进 receipt             │
  ├───────────┼────────────────────────┼─────────────────────────────────────────────────────────────┤
  │ 实验设计  │ F-044                  │ 裁决门 SPEC                                                 │
  │           │ 只定阈值没定探针构成   │ 补「探针集构成契约」（记忆轴/近泛化轴配比+重叠度声明）      │
  └───────────┴────────────────────────┴─────────────────────────────────────────────────────────────┘

  8. 建设性建议

  Immediate（重跑包，一次拍两修）：①span 改全 assistant turn（原 ⭐A）②探针集加「训练内说法」记忆轴（如
  34=17 训练内+17 近邻，分账两轴报告；或训练集改为覆盖探针 34 工具）——两修都到位才值得烧第二次授权。
  Class-level：preflight 覆盖率门 + 两机制术语表进契约 + wave-1 augmentation SPEC 带语义 fixture。
  Governance：landing-matrix 加 fit-proof 列；F-044 补探针构成契约；readiness 词表加「mechanism-true ≠
  fit-proven」层级。

  9. 下一步验证门

  - L0：重跑前静态——span 覆盖率 ≥90%（assistant 非 think 区）+ 探针重叠度声明打印进 receipt
  - L1：重跑记忆轴（训练内 case）empty 应≈0——不达 = 范式/训练层真问题（这才是干净的范式判决）
  - L2：近泛化轴分账报告（不设死门，采集证据）
  - L3：verdict + 双轴分账上抛磊哥，wave-1 设计吸收两机制术语表

  一句话收束：这次 34/34 不是范式判决，是实验器材问题（监督残缺 +
  探针错配）；修两处再跑，才能拿到干净的范式答案。重跑包等你拍。
# Tiny Ablation Iceberg Teardown + Remediation Roadmap

> Date: 2026-07-02
> Scope: C5 tiny-ablation 裁决-A 首跑失败后的深度 teardown 与整改路线图
> Proof class: local artifact + runtime tiny-run receipt + static code/doc inspection
> Status: analysis + route proposal; not implementation authorization

## 0. Executive Reading Order

本文先分析,再给结论,最后给整改路线图。核心判断如下:

- 这次 `34/34 NO_TOOL` 不是 D-domain LoRA 范式判决,而是实验器材判决。
- 已坐实三根共同充分的根因:
  - 输出监督残缺: tool-call 正样本只训函数名/参数名碎片,没有训完整 `<tool_call>{...}</tool_call>`。
  - 输入面错配: 训练 user 面是 `device=...; primitive=...; slots=...` 协议语句,探针 user 面是自然中文。
  - 实验构造错配: tiny 原本用于过拟合/记忆裁决,实际探针却几乎是 held-out natural-language 泛化裁决。
- 因此下一步不是“直接 v6 重跑”,而是先修实验定义和可学性门,再申请新的 tiny rerun authorization。

## 1. Evidence Snapshot

| Evidence | Location | What it proves |
|---|---|---|
| v5 训练完成,adapter 落盘,600 iter 无 NONFINITE,但 probe `34/34` empty | `runs/tiny-ablation-adjudication-A/RECEIPT-TINY-ABLATION.md` Step3/Step4 | 数值训练链路跑通,行为目标失败 |
| raw output 重复 `NO_TOOL.NO_TOOL...` | `runs/tiny-ablation-adjudication-A/probe/*.json` | 模型不是沉默,而是在复读唯一完整监督过的输出形态 |
| train row 的 `loss_mask.trainable_spans` 仅 `function_name` / `argument_name` / `NO_TOOL` | `runs/tiny-ablation-adjudication-A/build/mlx-data/train.jsonl` | 正样本没有监督 wrapper / JSON skeleton / `"arguments"` / closing tag |
| first train user = `device=ac_cooling_mode; primitive=set_mode; slots=no_slots; 请按这个语义执行` | 同上 | 训练输入是协议/语义中间表示,不是自然中文 |
| first probe user = `有点冷`, expected tool = `raise_ac_temperature_by_exp` | `runs/tiny-ablation-adjudication-A/probe/01-C6-MP-002.json` | 探针输入是自然中文 C6 case |
| 复算: train rows 44, train unique user texts 32, train target tools 16; probe exact user overlap `0/34`; probe unique expected tools overlap `2/18`; expected calls overlap `4/35`; char coverage median 30.1%, min 12.1% | 本轮 python local recompute | 旧实验无法证明“过拟合记忆能否成功”,因为输入与目标工具覆盖都不对齐 |
| `coverage = samples.contains { masking.functionName/argumentName/argumentValue/trainOnTurn }` | `Core/Training/C5LoRATraining.swift` receipt construction | 当前 coverage 是字段存在性,不是目标充分性 |
| `masking 三形态实为两类机制` 已在项目宪法中锁过 | `CLAUDE.md §9` | 概念层早有预警,实现层仍发生机制混用 |

## 2. Continued Analysis

### 2.1 Visible failure is downstream of three different mismatches

如果只看 `34/34 NO_TOOL`,容易把问题压成一个修复项:把 `trainable_spans` 改成全 assistant turn。这个修复是必要的,但不是充分的。

实际链条是:

```text
training input surface = protocol directive
  "device=...; primitive=...; slots=..."

training output objective = partial span only
  function_name / argument_name / NO_TOOL

probe input surface = natural Chinese C6 utterance
  "有点冷" / "氛围灯亮一点" / ...

probe success metric = full tool_call behavior
  emptyToolCallOutputs < 5 / 34
```

这四个面没有构成同一个实验。它同时要求模型学会:

1. 输出完整 tool-call 格式。
2. 从协议语句映射到工具名。
3. 从自然中文映射到 D-domain 工具名。
4. 对未见工具/未见说法做泛化。

但 44 条 tiny 样本没有给第 1 项完整监督,也没有给第 3 项自然中文监督。失败不是意外,是实验构造的必然结果。

### 2.2 `train_on_turn` is a name, not an invariant

当前最危险的错觉是:receipt 里看到 `train_on_turn=true`,就以为 assistant turn 已经进入 loss。实际 local artifact 证明不是这样。

正确契约应是:

```text
loss objective:
  prompt/system/user masked
  assistant non-think payload trained
  think spans masked
  no-call rows train full NO_TOOL

augmentation:
  function name / argument name / argument value perturbation
  belongs to data content transformation, not loss objective selection
```

现在的问题不是一个字段布尔值错了,而是字段名、receipt、validator、实现都没有共同表达“监督目标到底是什么”。

### 2.3 Tiny-A 的实验目的已经漂移

Tiny-A 原本被当成“裁决-A / tiny ablation / 过拟合记忆”来用。这个目的下,合理问题应该是:

> 给模型少量明确样本,它能不能先学会目标输出格式和最小映射?

但实际 probe 是 34 个 C6 natural-language case,且与训练 user exact overlap 为 0。更严格地说,它已经从“记忆/器材 sanity”漂移成了“自然语言 held-out 泛化评测”。

这导致两个坏后果:

- 如果 fail,你不知道是训练链路坏、输出格式没学会、自然语言样本缺失、工具覆盖不足,还是 D-domain 范式不行。
- 如果 pass,也可能是 base 模型或 grammar 偶然兜住,不一定证明训练数据设计正确。

因此本轮结果应重标:

```text
VALID: 证明当前 tiny 实验器材不成立。
INVALID: 不能作为 D-domain LoRA 范式失败证据。
```

### 2.4 `mechanism-true` has repeatedly been mistaken for `fit-proven`

过去几轮强项是把机制做真:

- token labels 真消费。
- G7 manifest 真实 codegen。
- C6 subset context 字段真进入 receipt。
- DataGate 真 fail-closed。
- Adapter 真训练、真落盘。

但这些都回答的是“机制有没有发生”,不是“机制是否足以证明当前目的”。本次冰山的系统层名称应叫:

```text
Fit-for-purpose gate missing.
```

换句话说,项目已有很多 `mechanism-true` 门,缺一列 `fit-proof`:

| Claim | Mechanism-true proof | Missing fit-proof |
|---|---|---|
| loss mask 生效 | token labels 被消费 | assistant 关键输出结构是否被监督 |
| dataset ready | split / lineage / receipt 通过 | 数据是否能训练目标任务 |
| tiny ablation ready | adapter 可训练 | probe 是否匹配 tiny 的实验目的 |
| subset ready | 预算可装载 | subset 是否保留足够 NLU 可路由性 |
| grammar ready | 输出可约束 | grammar 是否掩盖模型拒识偏置 |

### 2.5 Deeper class: semantic surface alignment is still the central risk

MAformac 已经经历过一次 `tool_call_frame` vs D-domain surface mismatch。现在换了形态:

```text
train user surface: semantic protocol directive
eval user surface: natural Chinese utterance
output loss surface: partial function-name span
runtime expected surface: full tool_call JSON
```

这不是“又一个 masking bug”。这是同一类 surface alignment 问题在 C5 数据、loss、eval、runtime 四个面上复发。

## 3. Conclusion

### 3.1 Verdict

当前 verdict 应从宽泛的 `BLOCKED_VERDICT_EMPTY_34_OF_34` 细分为:

```text
BLOCKED_INVALID_FOR_PARADIGM_VERDICT
reason:
  assistant_supervision_incomplete
  train_probe_input_surface_mismatch
  tiny_probe_construct_mismatch
```

它是高价值失败,但不是模型范式失败。

### 3.2 What is proven

- v5 mechanical training path can run to completion on Apple Silicon with `seq5120 + grad_checkpoint + batch1/grad16` under observed peak memory.
- Current loss objective is insufficient for tool-call behavior.
- Current tiny probe cannot cleanly distinguish training-chain failure, data-design failure, and D-domain surface failure.
- Current readiness vocabulary lacks `fit-for-purpose` proof class.

### 3.3 What is not proven

- Not proven: D-domain named-tool surface cannot work.
- Not proven: rank16Mainline recipe is wrong.
- Not proven: LR/rank/scale/clip/iters should change.
- Not proven: E-2 subset design is the root cause.
- Not proven: wave-1 natural-language data would fail.

### 3.4 Decision recommendation

拍 `A` 仍然正确,但应升级为 `A+`:

```text
A+:
  train_on_turn => full assistant non-think target
  prompt/user/system masked
  NO_TOOL rows train full NO_TOOL
  function/argument masking renamed to augmentation and removed from loss-objective meaning
  add assistant supervision coverage gate
  redesign tiny probe into memory / near-generalization / held-out axes
```

## 4. Remediation Roadmap

### Phase 0 — Stop-the-line relabel

Goal: 防止错误结论污染后续路线。

Actions:

- 把本次 tiny 结果在 commander/route/receipt 语义上标为 `实验器材失败`,不是 `D-domain 范式失败`。
- 禁止基于本次 `34/34` 调 LR/rank/scale/clip/iters。
- 禁止直接进入 wave-1 或 formal LoRA。

Human review:

- 磊哥确认是否接受 `BLOCKED_INVALID_FOR_PARADIGM_VERDICT` 这个重标语义。

Exit gate:

- 下一次 run-auth 文案必须显式写明本次重标,并列出仍保留的失败纪律。

### Phase 1 — Contract repair before code

Goal: 先把目标说清楚,避免继续实现一个含混词。

Actions:

- 定义 `C5LossObjectiveProfile`:
  - `assistant_full_except_think`
  - `no_tool_full`
  - `diagnostic_span_only`
- 定义 `C5AugmentationProfile`:
  - function-name perturbation
  - argument-name perturbation
  - argument-value perturbation
- 规定 `train_on_turn` 退役或只作兼容字段,不得再作为验收语义。
- 规定 receipt 必须输出:
  - assistant char/token coverage
  - parser-critical token coverage
  - prompt/user/system leakage count
  - think leakage count
  - NO_TOOL full-target count

Human review:

- 审 `loss objective` 与 `augmentation` 是否被彻底拆开。

Exit gate:

- 文档/测试名里不再出现把 augmentation 当 loss mask 的描述。

### Phase 2 — Code + tests hardening

Goal: 修“能训什么”,不是修“字段看起来存在”。

Actions:

- `C5LossMaskBuilder` 改为:
  - train-eligible positive row: full assistant payload in loss, except think spans.
  - no-call row: full `NO_TOOL` in loss.
  - prompt/system/user all masked.
- 加 assistant supervision coverage validator:
  - tool-call positive rows必须覆盖 `<tool_call>`, `</tool_call>`, JSON braces, `"name"`, target tool name, `"arguments"`, argument keys/values if present.
  - coverage below threshold fail-closed.
- 保留已发现的机械保护:
  - `ntoks == 0` clear failure, no NaN.
  - max record tokens <= max_seq_length preflight.
  - MLX train command receipt fixed.
- 新增回归测试:
  - `testTrainOnTurnTrainsFullAssistantToolCallPayload`
  - `testPromptAndUserTokensRemainIgnored`
  - `testNoToolRowsTrainFullNoToolOnly`
  - `testAugmentationFlagsDoNotDefineLossObjective`
  - `testAssistantSupervisionCoverageFailsWhenWrapperUntrained`

Human review:

- 抽样读 3 条 train.jsonl: positive no-arg / positive with args / NO_TOOL。
- 看 masked target decode,不是只看 JSON 字段。

Exit gate:

- old v5 train.jsonl 在 coverage validator 下必须 fail。
- new build train.jsonl 在 coverage validator 下必须 pass。

### Phase 3 — Tiny experiment redesign

Goal: 把 tiny 从混合大考拆成可诊断小考。

New axes:

| Axis | Purpose | Probe composition | Pass semantics |
|---|---|---|---|
| A. format-memory | 证明输出结构和训练循环可学 | exact training user surface + exact expected tool | 必须接近 0 empty |
| B. natural-memory | 证明自然中文样本能驱动目标工具 | natural user phrasing included in train, probe exact/near paraphrase | 必须显著低 empty |
| C. near-generalization | 观察小范围泛化 | seen tool + unseen paraphrase | report-only or soft gate |
| D. C6-heldout | 观察真实 C6 风险 | original 34 C6 cases | report-only until wave-1 data exists |

Key correction:

- 不能再用纯协议 user 面训练,然后用自然中文 probe 直接判 tiny pass/fail。
- 如果 tiny 的目标是验证自然语言 LoRA 路径,训练集中必须有自然中文 user 面。
- 如果 tiny 的目标只是训练器材 sanity,probe 必须包含 exact training/protocol memory axis。

Human review:

- 磊哥拍下一次 tiny 的目的:
  - `instrument sanity`
  - `natural-language tiny`
  - or both, but axes must分账。

Exit gate:

- run-auth 写清每个 axis 的样本数、overlap 口径、成功门和 report-only 门。
- receipt 打印:
  - train/probe exact user overlap
  - expected-tool overlap
  - seen-tool / unseen-tool split
  - natural vs protocol input surface counts

### Phase 4 — v6 tiny rerun package

Goal: 用最小授权拿到干净判决。

Preconditions:

- Phase 1 contract complete.
- Phase 2 coverage validator green.
- Phase 3 probe composition approved.
- New run-auth signed; old authorization不得自动复用,因为样本/probe设计已实质改变。

Recommended run:

- Keep recipe controls unchanged:
  - rank16Mainline
  - LR / scale / clip / iters unchanged unless separately authorized
  - no threshold movement
  - no wave-1
  - no formal train claim
- Keep mechanical config from v5 if still needed:
  - `seq5120 + grad_checkpoint + batch1/grad16`

Verdict interpretation:

| Result | Meaning | Next action |
|---|---|---|
| Axis A fail | loss/training loop still broken | stop, debug C5 loss/trainer |
| Axis A pass, Axis B fail | natural input data path broken | fix naturalization/data generator |
| Axis A/B pass, Axis C weak | expected at tiny scale | proceed to wave-1 data design, not formal train |
| Axis A/B/C good, D improves | strong signal | prepare wave-1 with same contracts |

### Phase 5 — Wave-1 data construction after tiny passes

Goal: 让正式数据解决真实任务,而不是放大 tiny 的错。

Actions:

- Build natural-language training rows from the same semantic contract:
  - user surface = natural Chinese utterance.
  - target = full D-domain tool-call JSON.
  - source lineage = contract row + generator/source id + human/validator status.
- Keep protocol directive rows only as diagnostic or auxiliary axis, not as primary NLU training corpus.
- Add data mixture receipt:
  - natural/action rows
  - natural/no-call rows
  - protocol/diagnostic rows
  - seen/unseen tool split
  - seen/unseen utterance split
  - refusal/unsupported split
- Add C6 heldout hard isolation:
  - C6 must-not-train rows remain excluded.
  - near-neighbor can exist only with lineage tags and non-identical source hashes.

Human review:

- 抽样 grill 自然中文训练行:
  - 是否像客户会说的话。
  - 是否正确落 D-domain tool。
  - 是否没有把 C6 gold 泄进 train。

Exit gate:

- `data_gate_ready` 不能单独放行;还需要 `fit_for_purpose_data_ready`。

### Phase 6 — Formal LoRA long run

Goal: 在数据和实验器材都证明后再烧长跑。

Preconditions:

- v6 tiny Axis A/B pass.
- wave-1 data gate + fit-purpose gate pass.
- C6 four-layer harness ready.
- R7 route/signoff still valid or renewed.

Run discipline:

- Formal run starts only after explicit run-auth.
- Mid-training behavior gate required:
  - not only val loss.
  - sample decode must show tool-call format, no NO_TOOL collapse, no wrapper drift.
- Final evaluation separated:
  - base anchor.
  - LoRA candidate.
  - constrained vs unconstrained decode if grammar is used.
  - C6 action/readback/refusal/unsupported axes分账。

Exit gate:

- Candidate signing only after C6 and receipt gates pass.
- Do not upgrade to demo/voice/UIUE/V-PASS without downstream proof.

### Phase 7 — Governance hardening

Goal: 防止类似冰山换模块复发。

Actions:

- `landing-matrix` 加 `fit-proof` 列:
  - mechanism-true evidence
  - fit-for-purpose evidence
  - proof class
  - owner
  - next blocking gate
- readiness vocabulary 增加:
  - `mechanism-true`
  - `fit-proven`
  - `experiment-valid`
  - `behavior-proven`
- 每个 run receipt 强制写:
  - claim being tested
  - construct validity notes
  - train/eval surface alignment
  - proof cap
- commander 派工模板增加 stop condition:
  - if evidence proves experiment invalid, stop and relabel; do not keep fixing until metric moves.

Human review:

- 以后每个“绿”必须问一句:
  - 它证明机制发生了,还是证明目的达到了?

Exit gate:

- 下一份 route board 不得只列 `PASS/READY`,必须列 proof class 和 fit-proof status。

## 5. Suggested Commander Prompt

```text
按 Tiny Ablation Iceberg Roadmap 执行 Phase 0-3,先不重跑训练。

Scope:
- docs/code/test only, no wave-1 generation, no formal training, no threshold move.
- Fix loss objective contract and assistant supervision coverage gate.
- Redesign tiny probe into format-memory / natural-memory / near-generalization / C6-heldout axes.

Hard requirements:
- Distinguish loss objective from augmentation.
- Positive tool-call rows train full assistant non-think payload.
- NO_TOOL rows train full NO_TOOL.
- Print train/probe overlap, seen-tool split, natural/protocol surface counts in receipt.
- Old v5 dataset must fail new coverage gate; new tiny dataset must pass.

Stop:
- If changing sample/probe composition, request fresh run-auth before any training.
- Do not claim D-domain paradigm verdict until Axis A/B are separated and run.
```


# C5 LoRA 整改 — 32 条 grill 清单（grill-with-docs 弹药）

> ⚠️ **HISTORICAL 快照（2026-06-22）—— 文档级联 banner（2026-06-23）**
> 本文是 C5 recovery grill 弹药清单中间态历史快照（运行清单）。拍板权威 = `docs/c5-recovery-2026-06-22/grill-decisions.md`（已拍决策以其为准，本清单冲突条目作废）+ 范式翻案 `grill-decisions-amend-paradigm-tool-surface.md`。**活基线** = `CLAUDE.md §9` + grill-decisions。正文保留供溯源，凡与 grill-decisions 冲突以后者为准。

> **🔁 grill 进度级联(2026-06-22,权威源 `grill-decisions.md`)**:**已拍 6 决策**(以 grill-decisions 为准,本清单对应条目作废旧倾向):G0a/G0b→**A0 C6 hard_pass 口径** / A0(C6真口径)→**两套 scorer 用 hard_pass,name-only 降 smoke** / B/C/G10-12→**Q1 route 边界 7 维 Compiler 派生不手标** / D13(G13 SSOT)→**两层 SSOT(能力层 semantic-function-contract ⊃ 演示层 demo-golden-run,demo 延后)** / G18→**case 标签来自 jsonl,真分叉在 toolSpecs** / G27/G31(CI)→**改 `make verify` 本地门(D2)** / safety→**risk-policy overlay**。**新增**:D1(route_tier 派生统一加 value.type,待拍)/ A1(D/B tiny 对照)。**未 grill**:G2-G9/G14-G26/G28-G32(数据契约细则/训练配方/审计/真机/防复发)。下方条目凡与 grill-decisions 冲突以后者为准。

> 为 grill-with-docs(engineering-contract mode)准备。每条 = topic + 张力/选项 + ⭐CC 倾向 + physical landing(可落字段/file:line)。磊哥逐题拍,拍后落 ADR/spec/exec-plan。
> 纪律:范式类(A 组)**不凭 0/34 拍**(confounder 已坐实);CC 倾向仅供参考,可推翻。

## A0. C6 真口径 + recovery 成功标准（🔴 grill 头号,subagent CC 亲核 catch,先于范式)

- **G0a C6 真 scorer 口径**:name-only(`spike-e3:158`,只验工具名)base 25/lora 0 / hard_pass(`C6VehicleToolBench.swift`,state_delta)base 7/57 vs lora 15/57(LoRA 反优)/ 两套合一。⭐合一到 hard_pass(state_delta 才是「车控真执行对」,name-only 掩盖 args 错);spike-e3 name-only 降级为快速 smoke。physical:Gate G1 统一口径,删一套或合并 scorer。
- **G0b recovery 成功标准(外审 P1-3:三联不够,必 YAML 分轴)**:⚠️「整体 hard_pass>base 7」本身不安全——可被 negative/no-call 提升掩盖 positive 塌缩(正是 LoRA 15>7 但 positive 0/34 的陷阱)。⭐**`lora-success-thresholds.yaml` 分轴**(见 exec-plan §8):positive_vehicle_action(tool_name/required_args/state_delta/hard_pass/wrapper_rate=0/empty_rate)+ negative_no_call(empty_as_no_call_allowed=false)+ trap + heldout + overall,核心硬约束 **`cannot_compensate_positive_failure_with_negative_gain: true`**。physical:G0b 冻结该 YAML,不停留自然语言三联。
- **G0c 「0/34」定性**:LoRA 全废 / positive 塌缩+negative 提升的混合(hard_pass 已优于 base)。⭐混合(数据修好+surface/scorer 对齐后有救,不推翻 Qwen3-1.7B 选型)。physical:8D D8 定性修正已落。

## A. 范式选择（最高优先,决定后续全部)

- **G1 模型可见层范式**:D-双层(模型出 `set_cabin_*` domain tools + 内部 ToolCallFrame IR)/ B-frame(守 `tool_call_frame`+`device` enum,C6 改二元判等)/ C-bridge(训练 frame→eval 映射)。⭐倾向 D-双层(顺 Qwen 具名 FC 先验 + 保 IR 治理),但**必须 tiny-overfit 对照实验定**,0/34 不能当证据。physical landing:`ADR-tool-surface-v2.md`(variant 待 G6 据实验拍,**不预设 D**)+ `model_tools.schema.json`。
- **G2 102 能力工具爆炸怎么防**:domain-level 工具(6-N 个)+ 参数/primitive 分层 / 一能力一函数。⭐domain 分层(set_cabin_ac 带 mode/temp 参数,非 set_ac_cooling + set_ac_heating...)。physical:`domain-tool-taxonomy.md` 何时暴露为 tool vs 参数。
- **G3 内部 ToolCallFrame IR 留不留**:留(102 治理/安全/mock/readback 靠它)/ 砍(直接用 domain tool)。⭐留(它是 C1 SSOT 的 codegen 产物,治理层需要),只作 normalizer 后的 canonical representation。physical:`tool_call_frame.ir.schema.json`。
- **G4 name 顺序**:name-first(顺 Qwen3 chat_template)/ name-last(现状 100%,违先验)。⭐name-first 输出 + canonical hash 用独立规范化层(不影响输出序)。physical:改 `C5LoRATraining.swift:2407 render`,亲核训练样本 100% name-first。

## B. 数据契约修复（最深根因）

- **G5 paired counterfactual 真删工具**:`tools.removeAll{name==目标工具}` / 现状只写 metadata(`:2342` 假删)。⭐真删(代码 enforce,非 metadata 声称)。physical:改 `buildNoCallSamples:2333`,亲核 446 NO_TOOL 样本 tools 不含目标工具。
- **G6 446 矛盾对怎么处理**:全清(删 NO_TOOL 样本)/ 真删工具后保留(变成合法 counterfactual:工具不在→NO_TOOL 对)。⭐真删工具后保留(它们本就是为拒识训练设计的,删工具就合法了)。physical:重生成后 label_conflict=0。
- **G7 refusal/no-call 配比**:守 0.1(现状,但 11.1% 矛盾源)/ 调低 / action 加权。⭐保 0.1 比例但真删工具(矛盾消失后 0.1 是健康的);训练 action-positive 加权防 collapse。physical:`data balance receipt`,collapse monitor。
- **G8 value 占位符**:lessons B22 已记「assistant JSON 不能留 `<position>` 占位符」,这次 train.jsonl 是否还有?⭐核 + 阻断任何 `"x":"<...>"`。physical:数据扫描门。
- **G9 loss-span 覆盖**:tool name + required args token 必须在 loss / 现状 masking 是否覆盖?⭐必覆盖具体 tool name + required args(否则学不会吐对名字)。physical:`loss-mask receipt` / `arg-loss receipt`。

## C. label_conflict 门设计（escape point 修复)

- **G10 矛盾检测 grouping key**:实际 prompt 文本(system+user+tools 渲染后文本)/ metadata(现状 `:600` 用 targetToolPresent,被自己蒙蔽)。⭐用实际 prompt 文本(模型按文本学,门也按文本查,口径统一)。physical:改 `ambiguousDuplicateCount:597` + C5DataGate 加维度。
- **G11 label_conflict 严重度**:P0 hard fail(阻断训练)/ P1 warn。⭐P0(矛盾监督是 0/34 主因,必须硬阻断)。physical:`C5DataGate:256` 加 `label_conflict` failure,spec 加硬门。
- **G12 data gate 还缺哪些维度**:除 label_conflict,是否要 name-order 门 / empty-target 门 / surface-consistency 门?⭐加 name-order(全 name-first)+ surface(training==c6)双门。physical:`gates-d-v2.yaml`。

## D. SSOT / ToolContractCompiler

- **G13 SSOT 候选(外审 P0-4,纠与 8D D4.2 警告冲突,不预设 C1)**:候选 A `contracts/semantic-function-contract.jsonl`(C1) / B 新 capability contract v2 / C C1+cabin overlay。**🔴 不得在 grill 前宣称 C1 是唯一 SSOT**(hermes 的「C6 该向 C1 对齐」frame 影响 B vs D 决策,8D D4.2 已警告需磊哥独立判)。M0 必核:C1 是否覆盖 C6 所需 args/state_delta/readback、能否派生 D-domain tools、能否派生 B-frame 判等、能否作 verifier/gold/readback 唯一源。physical:G1 SSOT 候选核验 receipt。
- **G14 Compiler 派生哪几件**:model_tools / c6_expected / runtime enum / normalizer / verifier / training render —— 全派生 / 部分。⭐全派生(任何手写 = 漂移源)。physical:`ToolContractCompiler` 输出 6 件 + CI contract check。
- **G15 Compiler 落 Swift 还是 Python**:Swift(与 runtime 同语言)/ Python(与训练 prepare 同)/ 跨语言 codegen。⭐契约定义中立(JSON/YAML),codegen 同时出 Swift enum + Python render。physical:`generated/` 目录 + CI。
- **G16 contract 版本/diff policy**:breaking/non-breaking 规则 + CI 判定。⭐有(防契约改了下游不知)。physical:`contract-diff-policy.md`。

## E. C6 eval 口径修复

- **G17 empty vs NO_TOOL 区分**:eval 必须区分「模型说 NO_TOOL」vs「empty collapse」/ 现状 `:161` 都算 no-call hit。⭐必区分(用 `:153 contentLooksLikeToolCall` + 生成 token 数);empty 在 negative case 不记 hit。physical:改 `spike-e3:157-162`。
- **G18 C6 来源修正(外审 P0-1,纠与 8D v2 冲突)**:⚠️ **case 标签已来自 `contracts/c6-bench-cases.jsonl`(带 `source_refs.semantic_contract_ids`),`:589 sampleCases` 是没被用的 fallback、非失败主因**。真正需 contract 派生的是:① model-facing toolSpecs ② expectedArgs/requiredArgs ③ expected state_delta ④ verifier config ⑤ hard_pass scorer axis。⭐五项全 compiler 派生;sampleCases fallback 删除或标 dev smoke 禁进 release gate。physical:别把火力打到「case 来源」,打到 toolSpecs/args/verifier/scorer。
- **G19 C6 分层打分**:tool_name / arg_schema / required_args / state_delta / readback / no_call / trap 分项 / 现状只 tool hit。⭐分层(只看 tool hit 会把「名字对参数错」当过)。physical:verifier module 分项 receipt。
- **G20 base baseline 怎么用**:作对照 / 当 pass 阈值(危险,confounder)。⭐只作对照 + regression canary(base 会的 case LoRA 不许退化),不当范式证据。physical:`base-error-taxonomy.md` + canary set。
- **G21 verify_gold 前置**:deterministic gold 在 C6 harness 100% pass 才重训 / 跳过。⭐硬前置(gold 自己错就别训)。physical:`verify-gold-receipt.json`=100%。

## F. 训练配方（防 collapse 复发)

- **G22 action-positive 加权**:加权防 collapse / 等权。⭐加权(0/34 是 action 塌缩,需强化 action 信号)。physical:train recipe 权重 + collapse monitor。
- **G23 scale**:守 20 / A/B 32 / 调。⭐先守 20(0/34 非 scale 问题,hermes 证 val_loss 健康),数据修好后 32 进 A/B。physical:`lora-success-thresholds.yaml`。
- **G24 tiny-overfit sanity 前置**:20-50 条先过拟合验可学 / 直接全量。⭐tiny 前置(tiny 都学不会,全量白跑;且 tiny 验数据修复)。physical:`tiny-train receipt` + `tiny-c6 receipt`。
- **G25 collapse 实时预警**:训练中监控 empty rate / tool-call count / no-call rate / base canary?⭐必监控(0/34 是 collapse,要早停)。physical:`collapse monitor`。
- **G26 masking 三形态**:lessons 记 masking 实为两类机制,这次重训怎么落?⭐train_on_turn loss mask + 受约束增广,核 masking_coverage 真覆盖。physical:masking receipt。

## G. 审计框架补维度（治理反思)

- **G27 审计加语义正确性维度 + 强制实跑一手数据复算**:持续审计循环 + superaudit 现只审诚实/合规、且输入全是 receipt 顶层聚合数 → 加 surface/data-contract/eval-口径 语义门 + **强制审计员实跑(python 复算矛盾率 / 下钻 axis / 算样本分布),不准只看 receipt 顶层**?⭐都加(0/34 暴露合规审计抓不到语义失败 + CC 三次同坑都是「凭聚合数推、没实跑下钻」,审计层同根)。physical:审计 SOP 加「实跑复算」硬段 + 模板语义维度。
- **G27b spike-e3 不验 args**:`spike-e3:158` expectedToolHit 只匹配 name,EvalCase 无 expectedArgs → base 25 是纯 name-hit、args 对错没查。重写 C6 验 args/state_delta(并入 C6VehicleToolBench)/ 保留 name-only smoke。⭐并入 hard_pass scorer 验 args+state,name-only 仅 smoke。physical:spike-e3 加 expectedArgs 或弃用、统一走 C6VehicleToolBench。
- **G28 同源审计 vs 异构终审**:subagent codex(同源)够不够签?/ 必异构 GPT Pro?⭐同源只链内检查,candidate 签必异构终审(hermes 这次异源 catch 了 CC 同源盲点 = 实证)。physical:Gate 8。
- **G29 grill frame 纪律入 checklist**:重大训练 change 必问「训练/eval/runtime 同源同 frame」?⭐必问(本次 frame 盲区 = 0/34 escape)。physical:grill-with-docs checklist 硬段。

## H. 真机 / endpoint / 防复发 / 元认知

- **G30 真机采购**:买 / 借 / 付费开发者账号(7天证书)?⭐提前并行采购(endpoint V-PASS 阻塞链,别等 C6 过才动)。physical:`device procurement receipt`。
- **G31 防复发 CI 三门**:surface consistency / loss-span / verify_gold 入 CI?⭐全入(防再现)。physical:`prevention CI`。
- **G32 元认知回流**:codex-metacognition §28/§31 补「诊断重大失败必核生成代码 file:line,不凭 receipt 聚合推根因」+ blueprint-teardown 补「反向用于 bug 链路」?⭐回流(CC 这次 confounder/二手推 = 实证教训)。physical:rules 更新 + memory。

---

## grill 顺序建议（外审 P2-1 修正:先实验+硬门,不先拍范式结论)

> ⚠️ 旧顺序「先拍 A 组范式」是错的——范式不能凭 0/34 拍,必须等实验。新顺序:

1. **A0**:C6 真口径(G0a)+ recovery 成功标准 YAML 冻结(G0b)+ candidate blocked(G0c)。
2. **D 组 SSOT/Compiler**(G13-G16)— 但 G13 是 SSOT **候选核验**,核 Compiler 能否支持 D/B 两实验 surface(不预设 C1)。
3. **B/C/E 数据契约 + label 门 + eval 口径**(G5-G12 / G17-G21)— 最深根因修复 + scorer/args 派生。
4. **实验设计冻结**:G4 stepwise ablation(E0-E5)+ G5 D/B tiny 对照(exec-plan §1.5)。
5. **再拍 A 组范式结论**(G1-G4)— 据实验证据拍 `surface_variant`,写 ADR(G6)。
6. **F/G/H 收口**(G22-G32:训练配方 / 审计补维度+实跑复算 / 真机/防复发/元认知)。

**铁律:先拍实验和硬门,范式结论放最后(据证据拍,不据 0/34 拍)。**

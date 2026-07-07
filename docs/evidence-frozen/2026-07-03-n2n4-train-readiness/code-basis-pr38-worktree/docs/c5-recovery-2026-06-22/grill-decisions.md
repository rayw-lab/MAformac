# C5 Recovery Grill Decisions Log（engineering-contract mode）

> 🔁 **2026-06-22 amend 指针(磊哥拍 · pG2 防 append 分叉)**:本文档已 15+ 段,本轮新决策(**审计框架议题2 起 + G27-G29 + Harness Enforce 层** hook/memory/cite-verify)单独落 **`grill-decisions-amend-harness-audit-enforce.md`**,不 append 加重段间分叉。**权威边界**:本文档 = C5 训练决策(Q1→θ-data/η/θtrain/marker)+ audit-framework 议题1(C++);amend = 审计框架议题2/G27-29 起 + harness。两者平级互补。

> 决策晶体记录。状态约定(磊哥 2026-06-22 拍):
> - `Accepted-for-contract-generation` = 决策已拍、可进 contract/Compiler 生成,**但 NOT Implemented**(代码/数据未落)。
> - candidate 状态贯穿:**current 0/34 artifact 永久 UNSIGNED/BLOCKED**,任何决策不改变这个。
> - 每条带:status / decision / evidence_refs(file:line + 实跑数据)/ generated_artifacts(待生成,均 derived 非手标)/ pre-mortem / blocked_gates。
> - 决策仅落「晶体」,不落「执行完成」。

---

## C5-GRILL-Q1-route-boundaries

- **status**: `Accepted-for-contract-generation`(NOT Implemented)
- **date**: 2026-06-22
- **decision**:
  1. 7 个路由责任边界**全收**(L1_exact/L1_para / no-op vs NO_TOOL / implicit vs ambiguous / 多轮指代 / safety-gated / coverage-vs-customer / readback ownership)。
  2. 字段族 = **Compiler 派生 labels,非手标 schema**;`route_tier` 允许存在,但**值域由 Compiler 从 `(exec_tier, clarify_tag, fc_flags, value.type, second_turn_refs, case_id)` 派生 + 带 `derivation_inputs`,禁写死 6 级枚举**(`L1_exact|L1_para|L2_feeling|...|L5_multi` 是拍脑袋,契约里不存在,已 catch 两次)。
  3. safety 从 `contracts/risk-policy.yaml` overlay 外接,**不回填 C1 risk**(避免 T2 耦合扩大)。
  4. candidate remains **UNSIGNED/BLOCKED**。
- **evidence_refs**:
  - `Core/Intent/FastPathIntentEngine.swift:12` — 规则路 runtime 只硬匹配 `"打开空调"`(L1_exact 仅 1,L1_para 解析器不存在)。
  - `contracts/c6-bench-cases.jsonl` — `failure_class`{clarify9/refusal5/no_call8/none35}、`clarify_tag`{ambiguous9/implicit35/rejected13}、`case_id` 前缀{COV7/MP30/NEG8/TRAP-*}、`C6-MP-001 "关空调"` pre_state.ac.power=off == expected_state_delta.ac.power=off(state no-op 坐实)。
  - `contracts/semantic-function-contract.jsonl` — exec_tier{L1:76/L2:3914}、clarify_tag{explicit2561/implicit1429}、fc_flags{free,fuzzy}、value.type{SPOT459/PERCENT373/EXP734/空2424}、second_turn_refs 427非空、**risk 全空3990**。
  - `contracts/risk-policy.yaml`(cite-verify 坐实)— R0/R1/R2 + demo_action{execute/confirm/refuse_explain} + `forbidden: door_open_while_moving / trigger vehicle.speed>0 / risk_level R2`;`:63` 明文「C1 行 risk 仍全空,不与 C1 耦合」。
  - **3990 route_tier 派生实跑**:`rule_eligible 1967(49.3%)`/`lora_slow 2023(50.7%)`{fuzzy1077/multi427/exp374/free145};rule_eligible 内 `L1_exact 1562 + L1_para(SPOT233+PERCENT172)405`。
- **派生映射(规则,非每 case 手标;Compiler enforce)**:
  - `route_tier`: second_turn_refs非空→lora_slow:multi_turn / free→:free / fuzzy→:fuzzy / value.type=EXP→:exp_feeling / explicit&非以上→rule_eligible(内分 L1_exact[空value.type] / L1_para[SPOT|PERCENT]) / implicit→lora_slow:implicit
  - `lora_score_eligible` = (route_tier==lora_slow) OR (rule_eligible AND NOT fast_path_covered)
  - `no_call_reason` = derive(C6.failure_class + `pre_state==expected_state_delta`→state_noop)
  - `clarification_required` = C6.clarify_tag==ambiguous
  - `context_required`/`prior_domain` = contract.second_turn_refs
  - `eval_purpose` = case_id 前缀(COV→coverage_only / MP→release_must_pass / NEG·TRAP→diagnostic)
  - `rule_parse_family` = value.type(空→exact / SPOT·PERCENT→slot_deterministic→L1_para / EXP→lora)
  - `safety_gate_required`/`expected_safety_outcome`/`risk_rule_ids` = from risk-policy.yaml(forbidden + risk_levels)
- **generated_artifacts(待 Compiler 生成,均 derived 非手标)**:
  - `generated/c6_route_labels.jsonl`(case_id, derived_route_tier, lora_score_eligible, no_call_reason, eval_purpose, derivation_inputs, source_hashes)
  - `generated/safety-gates.c6.json` + `GeneratedSafetyGate.swift`(从 risk-policy.yaml,C6 SAFE case 引 rule_id 不手写)
- **pre-mortem**:
  - 🐯 tiger:派生映射规则若手写在 Compiler 且无依据 cite,又是隐藏手写逻辑 → 映射规则必 cite(SRD 三层路由 + value.type 语义)+ 单元测试覆盖每分支。
  - 🧸 paper-tiger:「route_tier 允许存在 = 回到 6 级枚举」→ 否,值域 Compiler 派生 + derivation_inputs 可溯源,与 grill 桌拍死 6 级本质不同。
  - 🐘 elephant:**3990 派生 rule_eligible 49.3% ≠ 架构铁律「规则吃 80%」** → 「80%」分母未定义(契约全集行数 vs 运行时高频流量)→ 见 BG1。
- **blocked_gates(open,需磊哥/后续拍,不阻塞本条决策)**:
  - **BG1**:「规则吃 80%」分母 frame 未定(全集 49% vs 运行时高频流量?)→ 决定 `rule_path_coverage` 成功标准目标 + L1_para 解析器要覆盖多大。
  - **BG2**:L1_para 确定性槽位解析器(覆盖 SPOT/PERCENT 405 + 同义词)未实装,FastPath 仅 1 个 → runtime 现状 rule_eligible 几乎全降级 LoRA 兜底(故 runtime-now 口径下 rule_eligible 也计 LoRA,见 exec-plan G0b 双口径)。

---

## C5-GRILL-Q2-safety-overlay(并入 Q1 safety 决策,单列追溯)

- **status**: `Accepted-for-contract-generation`
- **decision**: safety 先从 `contracts/risk-policy.yaml` 外接作 overlay,**本轮 recovery 不动 C1 risk 字段**(避免 T2 耦合扩大);Compiler 读 risk-policy.yaml 生成 safety_gate_required/expected_safety_outcome/risk_rule_ids。
- **evidence_refs**: `contracts/risk-policy.yaml`(R0/R1/R2/forbidden/`:63` 不耦合 C1,cite-verify 坐实);契约 risk 全空3990。
- **generated_artifacts**: `generated/safety-gates.c6.json` + `GeneratedSafetyGate.swift`。

---

## C5-GRILL-Q-BG1-demo-golden-run-anchor

- **status**: `Accepted-for-contract-generation`
- **date**: 2026-06-22
- **decision**:
  1. `rule_path_coverage` **锚 `demo_golden_run.l1_utterances`,不锚契约全集 49%**(SRD「规则吃80%」是流量/体验口径,非 3990 契约行覆盖口径;80% 是虚数,按 49% 实测理解)。全集 rule_eligible 1967 只作 **Compiler 派生候选池**;未入剧本的 L1/L1_para 长尾 `fallback_to_slow_lora=true`。
  2. **BG1_DEMO_GOLDEN_RUN_UNFROZEN** gate:`blocks=[rule_path_coverage_pass, c6_must_pass_v2_freeze, full_lora_train_v2]`、`allows=[compiler_scaffold, derivation_probe, verifier_axis_probe, safety_overlay_probe, G4_tiny_stepwise_ablation]`。
- **CC 辩证修正(不盲从助理,catch)**:
  - **D1**:`demo-golden-run.expected_route` **必须 = derive(contract_refs 的 route_label),禁手填**(守 Q1「不手标」;`route_label_derivation` 字段记派生输入;demo 脚本 route 与 `c6_route_labels.derived_route_tier` 同源,不漂)。
  - **D2**:BG1 `allows` 加 **`G4_tiny_stepwise_ablation`(E0-E5)**——验数据契约修复(真删工具/name-first),不依赖 demo 脚本、不依赖范式,可并行,不被 BG1 block。
  - **D3(升 BG3,下一 grill 题)**:demo 脚本**单源**——`contracts/demo-golden-run.v1.yaml` 必须是 demo 脚本唯一 SSOT,吸收 UIUE 现有 3 处雏形(round1 炸场剧本4选 / round2 D20 golden-run回放 / `docs/demo-experience-script-placeholders.md` 五幕),否则 demo 脚本 3-4 处漂移 = SSOT 失守重演。
- **evidence_refs**:3990 派生 `rule_eligible 1967(49.3%)`(实跑);`FastPathIntentEngine.swift:12`(规则路仅1条);SRD「规则吃80%」=流量口径;UIUE round1/2/3 + `docs/demo-experience-script-placeholders.md`(demo 脚本雏形 3 处)。
- **generated_artifacts**:`contracts/demo-golden-run.v1.yaml`(step_id / utterance_zh / `expected_route`[derived 非手填] / contract_refs / route_label_derivation / must_pass / fallback_allowed)+ `generated/c6_demo_slice.jsonl` + `rule_path_coverage_receipt.json`。
- **blocked_gates**:
  - **BG1**:demo-golden-run 未冻结(blocks rule_path_coverage/c6_must_pass_v2/full_train,详上)。
  - **BG3(CC 新增)**:demo 脚本单源未定（demo-golden-run vs UIUE 3 处雏形）→ 见 Q-BG3。

---

## C5-GRILL-Q-BG3-demo-script-single-source + 两层 scope（磊哥 frame 修正)

- **status**: `Accepted-for-contract-generation`
- **date**: 2026-06-22
- **🔴 磊哥 frame 修正(破 CC+助理共享 frame)**:CC 与助理 co-grill 把 rule_path_coverage/训练/C6 全锚 demo 脚本窄集 = frame 错（违「不丢脸=客户随意说全集」+「demo 主演示 L2-5」)。修正为**两层 scope**:
  - **能力层(大而全)= `semantic-function-contract.jsonl`(3990 全集)SSOT**:LoRA 训练锚它(全集泛化,train.jsonl 4464 已从 3990 seeds 派生)/ C6 COV+诊断锚它(测大而全)/ 规则路尽量覆盖高频。**客户随意说 L1/全集 → 这层兜底**(规则高频 + LoRA 泛化 + mock 分层)。
  - **演示层(挑选)= `demo-golden-run.v1.yaml`**:从 3990 挑选的炸场序列(must_pass)。C6 must_pass / UIUE 五幕 / rule_path_coverage 锚它。
  - 关系:`demo-golden-run.contract_refs ⊂ semantic-function-contract.row_id`(演示=全集挑选子集,非能力边界)。
- **decision(Q1=A,demo 脚本单源)**:`contracts/demo-golden-run.v1.yaml` 作 demo 脚本唯一 SSOT,c6 must_pass + UIUE 五幕 + 炸场子集全从它派生/引用;**c6 的 COV/trap/neg 锚 3990 全集不锚 demo 脚本**(测大而全);owner 提产品层(不挂 C6)。禁在 C6/UIUE 文档另填第二份话术。
- **CC 辩证修正(catch 助理 Q2 frame 错)**:`full_lora_train_v2` **不被 demo 脚本 block**(全集泛化训练锚 3990;它被 G4 ablation/G5 范式/G7 Data v2 block,数据+范式层)。BG1 只 block 演示依赖项。
- **BG1_DEMO_GOLDEN_RUN_UNFROZEN（修正版)**:
  - `blocks=[rule_path_coverage_pass, c6_must_pass_v2_freeze, training_L1_exclusion_optimization]`（均演示依赖；L1 排除是省容量优化非地基）
  - `allows=[compiler_scaffold, derivation_probe, verifier_axis_probe, safety_overlay_probe, G4_tiny_stepwise_ablation, full_lora_train_v2_全集baseline(被G4/G5/G7 block,非被demo脚本)]`
- **generated_artifacts**:`contracts/demo-golden-run.v1.yaml`(schema: step_id, act_id, utterance_zh, expected_readback, **source_contract_row**[引3990], contract_refs, expected_route_derived[非手填], must_pass, uiue_scene_tag, c6_case_id_derived)+ `generated/c6_must_pass_from_demo.jsonl` + `generated/uiue_five_act_from_demo.md` + `rule_path_coverage_receipt.json`。
- **evidence_refs**:c6-bench-cases.jsonl(scenario_id scene1-4 + COV/MP/trap/neg 混合)；demo-experience-script-placeholders.md(五幕 placeholder,owner=define-vehicle-tool-bench,仅 Act2 slot4「打开空调」实话术)；train.jsonl 4464 从 3990 seeds 派生(训练锚全集坐实)。
- **next**:phase-0-demo-golden-run-freeze（定 demo 脚本炸场话术）= BG1 前置。**⚠️ 磊哥 2026-06-22:demo 全部延后(它是能力层子集,后话);recovery 现聚焦能力层(大而全 LoRA)**。

---

## C5-GRILL-A0-C6-true-scoring

- **status**: `REVISED-AFTER-CODE-AUDIT`(2026-06-22):A0 方向对(readback 不计 model hard_pass),但代码 **eval path `:1012` 错选 `output.text` 而非 `:1297 goldReplayOutputText`** → readback fail 混入 `hardFailed`,误导 receipt→grill **四轮**把 overall=0 当 positive_action baseline;readback 算法 **ε 已拍 P**(走端 renderer,删 eval `:1039`)。action 轴口径已 Accepted(锚 base 10/23)
- **date**: 2026-06-22
- **decision**:
  - C6 能力层真口径 = `model_action_hard_pass = tool_name_exact && required_args_exact && state_delta_exact`。
  - `name-only`(spike-e3 expectedToolHit) = `smoke_only`(release_gate: false),掩盖 args/state 错,不进 candidate signing / recovery 成功标准。
  - ✅ **`readback` 轴 → `RESOLVED-VIA-ε`(2026-06-22 ε 拍 P)**:A0 原写「readback 由 renderer 确定性生成、非 LoRA 自由补分、不计 hard_pass」——**代码证伪**:`C6VehicleToolBench.swift:1012-1016` 的 `readbackMatch = C6ReadbackRenderer.matches(..., outputText: output.text)` + `:1319` empty-guard → readback 测的是**模型自由生成的自然语言话术**(非 renderer 产物);base 单发 FC `chunkText=""`(吐 tool_call JSON 就 stop,不生成话术)→ readback 必 fail。**A0 前提方向对但代码 eval path 选错**;**ε 已拍 P**(readback=执行成功状态播报走端 renderer,删 eval `:1039 failures.append(.readback)` + 单列 informational gate 形态B;`:865` gold path 不改;见 ε 段)。
  - args:`required_args` = hard_fail_if_missing_or_wrong;`optional_args` = diagnostic_only,`becomes_required_if` affects(state_delta / safety_gate / disambiguation)。
- **两层 SSOT(确认,助理点1)**:
  - `capability_scope`: ssot=`semantic-function-contract.jsonl`,covers=rule_candidates + lora_slow + cov/trap/neg diagnostics。
  - `demo_scope`: ssot=`demo-golden-run.v1.yaml`,relation=subset_of_capability,covers=c6_must_pass_demo_slice + uiue_five_act + rule_path_demo_l1_coverage。
- **BG1(精确版,助理点2)**:
  - `blocks=[rule_path_demo_l1_coverage_pass, c6_must_pass_demo_slice_freeze, uiue_five_act_script_freeze, training_L1_exclusion_optimization]`
  - `does_not_block=[full_lora_train_v2, capability_cov_trap_neg_generation, compiler_scaffold, verifier_axis_probe]`
- **CC 辩证修正(cite-verify)**:
  - **executor 已实装**:`C6VehicleToolBench.swift:937 C6MockStateApplier.apply(output.toolCalls→finalState)`;`:832` gold apply;`:584 stateDeltaMatch` → `state_delta_exact` 可测(纠正 CC「无 executor」假设)。runtime executor 另在 `Core/Execution/{C3ExecutionPipeline,DemoActionExecutor}` + `Core/State/DemoVehicleStateStore`。
  - **D1**:`state_delta_exact`(LoRA 轴)有效性依赖 applier 先 verify_gold(gold apply 100% pass);applier 要接 LoRA 范式 normalizer(范式定后)。
  - **D2**:`optional_args.becomes_required_if` 判定从契约派生(value→state_delta 映射),不手判。
- **evidence_refs**:`C6VehicleToolBench.swift:1000-1056`(模型 eval gate)/`:1012-1016`(readback 吃 `output.text`)/`:1048`(`hardFailed: !failures.isEmpty` 含 readback)/`:1319`(matches empty-guard);`c6-summary.json:eval_runs[].gate_result`(一手字段级);base/lora `spike-e3-results.json`(chunkText)。
- 🔴 **三轴真相(2026-06-22 下钻一手 `eval_runs[].gate_result` 字段级复算,推翻 receipt 手 rolled axes)**:
  - 🔴🔴 **手 rolled receipt `diagnostics.axes` 不是 ground truth**:grep 坐实仓库无 `.py/.swift` 产生器(只在 `c6-eval-receipt.json`/`evidence-summary.md`/本文件 三个文本);它把 readback(话术)混进 `vehicle_action_positive.hard_pass` → 误报 base=0。**真一手 = `c6-summary.json:eval_runs[].gate_result` 字段级。**
  - **轴 action(`tcm && sdm`)——按 case schema 字段拆(非 id prefix,助理 catch,CC 认第6同坑)**:`mp_positive_action`(`expect_no_call=False` AND `pre_state≠expected_state_delta`)=**23** / `mp_refusal`(enc=True)=4 / `mp_noop`(pre==delta,005「关空调」pre `ac.power=off`)=3。
    - **base mp_positive_action 10/23(43%)**,lora **0/23**(那 4 个 tcm&sdm 全落 refusal=塌缩成空 toolCalls=[] 碰巧符合 enc=True,真 positive action **全面塌缩**)→ **模型有 args/state 能力(base 43%,强于旧算 11/30),LoRA 塌缩=数据契约错=单线修复,recovery 锚点 base 10/23**(非 11/30、非 K=10/34)。
  - **轴 readback(话术,output.text)**:base **0/10**(action 对的 10 个里 0 个说话术),根因 `chunkText="" + stopReason=stop`(base 单发 FC,吐 tool_call JSON 就停)。
  - **轴 overall(含话术)**:base 0/23,lora 0/23 = receipt"base=0"来源(把话术混进 action)。
  - **✅ recovery 主成功轴 = action(剔 readback),base baseline 10/23**;LoRA 目标超 10/23。**禁用含话术的 overall 当 action 锚**(已误导 receipt→A0→grill 四轮)。
  - **CC 第5/6次同坑(诚实认)**:第5=信 receipt 二手 axes 没下钻 gate_result;第6=按 `C6-MP` id prefix 当 30 分母,没按 schema 字段拆(refusal 4+noop 3 污染 positive_action,真分母 23)。"双线/E0.5"撤回。
- **🔴 两套 readback path(助理核爆 finding,CC cite-verify 坐实)**:
  - `goldReplayOutputText:1297`= 纯 renderer(从 delta 渲染,**不接 output.text**)= gold verify path。
  - `matches:1319`(eval `:1012` 用)接 `output.text`= 模型话术 path;`looksLikeMachineReadback:1413` 模型吐机器格式("ac.power=on")主动判 false → **代码强制模型说自然语言 = 方案Q假设**。
  - → A0(readback 不计 model hard_pass=方案P)与代码现状(eval 测模型自然话术=方案Q)**矛盾**;**ε 已拍 P**(不是"A0 错",是 P vs Q 产品决策,ε 拍 renderer 状态播报走 P,见 ε 段)。
- **助理总账(亲核坐实,不迎合)**:对=[schema拆23/4/3 / base 10/23 / lora 0/23全面塌缩 / 两套path finding / looksLikeMachineReadback];CC修正=[助理"换 :1015 用 goldReplayOutputText"表述糊→那会让 readback 对所有模型恒=gold自检(不测模型);正确方案P=删 eval `failures.append(.readback)`(:1039ish) + readback 单列独立 release-total gate,非 eval 跑 gold 自检]。
- **demo_script_blocks_full_lora_train**: false
- **candidate_status**: UNSIGNED/BLOCKED

---

## C5-GRILL-A1-tiny-surface-ablation + phase-1 收口

- **status**: `Accepted-for-contract-generation`
- **date**: 2026-06-22
- **decision(A1 范式对照实验)**:`experiments/tiny-surface-ablation.v1.yaml`——D-双层 vs B-frame tiny 对照,**唯一变量 `target_surface_variant`**,constant_controls=[base/train_utterance_ids/heldout_ids/seed/lr/scale/rank/epochs/masking/prompt_header(same_except_tool_surface)],D/B 都 `generated_by: ToolContractCompiler`(禁一手写一派生),scorer=c6_model_action_hard_pass;`blocked_by=[G4_DATA_FIX_ABLATION_PASS, VERIFY_GOLD_100]`;decision_rule=hard_pass_gap_clear & no_negative_regression & no_surface_drift & reproducible_across_2_seeds。**A1 只决定 surface_variant,不签 candidate**(后续仍走 Data v2/full C6/near-neighbor/parity/真机/异构终审)。
- **decision(收口 phase-1)**:`phase_bundle: phase-1-c5-recovery-foundation`;allowed=[ToolContractCompiler_scaffold, counterfactual_physical_tool_delete_fix, label_conflict_prompt_text_gate, name_first_render_fix, verify_gold_probe, c6_axis_scorer_probe, tiny_surface_ablation_D_vs_B];blocked=[full_lora_train_v2_until_G4_G5, candidate_signing, parity, physical_endpoint_vpass];stdout_receipts_required 见助理 yaml。
- **🔴 D1(cite-verify catch,✅ 已在 `C5-GRILL-D1-route-deriver-v2` 段拍 `A_PLUS_ACCEPTED`,本条留史)**:**route_tier 派生 SSOT 不统一**——代码 `C5LoRATraining.swift:186-187 C5RouteTier.derive(fuzzy, free)` 只 2 输入(`:2099` 注释「not execution-tier metadata」);grill 拍的 4 输入(exec_tier/clarify_tag/fc_flags/value.type)。现有 derive **不看 value.type → 不区分 L1_exact/L1_para,与 Q1 决策冲突**。OPEN:统一派生为单一 SSOT,倾向 ⭐**改 `C5RouteTier.derive` 加 value.type(对齐 Q1 L1_para),所有下游(训练 routeTier + Compiler C6 labels)用同一 derive**。
- **🔴 D2(cite-verify catch)**:仓库**无 CI**(.github/husky/pre-commit),但**有 `make verify`**(`Makefile:19` = verify-source/regen/verify-refs/diff/test)。exec-plan「CI 门」= claim 落不了地 → 改**接入 `make verify` 本地门**(surface-consistency/label-conflict/name-first check 加进 verify target,失败即 block),**不只 stdout receipt**(receipt≠门)。
- **evidence_refs**:`C5LoRATraining.swift:186-187/2099/2375`(routeTier=derive(fuzzy,free));`Makefile:19`(make verify pipeline);无 .github/husky/pre-commit。
- **元认知记录**:D1 是 CC+助理差点又犯「凭 grill 设计 vs 代码现状没对齐」的错(同 8D 根因类型),cite-verify(claim-vs-reality 铁律)当场救下——grill 拍任何「派生/字段/逻辑」前必核代码已有实现。
- **candidate_status**: UNSIGNED/BLOCKED

---

## C5-GRILL-D1-route-deriver-v2（拍 A+,拒 B）

- **status**: `Accepted-for-contract-generation`
- **verdict**: `A_PLUS_ACCEPTED`;`rejected: [fc_flags_only_route_tier]`(B FAIL)
- **decision**:建 `RouteDeriverV2` 作 route_tier 派生唯一函数(SSOT),`source_of_truth: ToolContractCompiler`;`training_render / generated_c6_route_labels / verifier_axis / route-label receipt` **全调同一实现或同一 generated table** + `assert_training_c6_route_label_parity`。
- **🔴 CC catch A(去 exec_tier,cite-verify)**:inputs = `clarify_tag + fc_flags{fuzzy,free} + value.type + second_turn_refs`——**不含 `exec_tier`**(`C5LoRATraining.swift:2099` discoveryFindings 明文「route_tier derived from fc_flags, **not execution-tier metadata**」;exec_tier L1=76/L2=3914 强制 L2 不稳、是执行层非路由层)。助理与 CC grill 桌均误列 exec_tier,cite 代码注释纠正。
- **outputs**:`route_tier`(rule_l1/fc_l2/fc_l3 + 新增 L1_exact/L1_para 细分)、`rule_parse_family`、`lora_score_eligible`、`derivation_version: route_deriver_v2`。
- **B FAIL 理由**:`C5RouteTier.derive(fuzzy,free)`(`:4-6` enum rule_l1/fc_l2/fc_l3)看不到 value.type → SPOT/PERCENT 确定性槽位与空 value 的 L1 落同一 rule_l1,无法区分 L1_exact/L1_para = Q1 决策落不了地 + route 边界打平 = 根因复发。
- **required_migration**:`add_route_deriver_v2 / regenerate_training_route_labels / regenerate_c6_route_labels / assert_training_c6_route_label_parity`。
- **evidence_refs**:`C5LoRATraining.swift:3-6`(enum)`:186-187`(derive(fuzzy,free))`:2099`(排除 exec_tier);value.type 单独用于 C5ValueStrategy(`:1874`)。
- **next**:RouteDeriverV2 **先进 Compiler scaffold,再 G4 ablation + A1 D/B**(否则对照被 route label 分叉污染)。

## C5-GRILL-D2-make-verify-gate

- **status**: `Accepted-for-contract-generation`
- **decision**:无 CI(仓库无 .github/husky/pre-commit);所有「门」enforce 落 `make verify`(`Makefile` 已有 `verify: verify-source regen verify-refs diff test`)。新 check 进 `test` target:`test_route_deriver_v2 / test_label_conflict_gate / test_surface_consistency / test_training_render_contract`(现 test 只 test_quarantine + test_fc_flags);`diff` target 已卡 generated/handwritten contracts/scripts/Makefile 漂移。**stdout receipt 只做证据,不做 gate**。
- **evidence_refs**:`Makefile`(`test:` 行 / `diff:` 行 / `HANDWRITTEN_CONTRACTS`)。

## (回写 Q-BG3)catch B：demo 脚本已有现存契约
`Makefile HANDWRITTEN_CONTRACTS` 含 **`contracts/l1-demo-allowlist.yaml` + `contracts/demo-scenarios.yaml`**(+ risk-policy + state-cells)。→ Q-BG3 的 `demo-golden-run.v1.yaml` **不是从零建,而是吸收/升级现有 `l1-demo-allowlist`(L1 demo 允许集)+ `demo-scenarios`(demo 场景)**;demo 脚本源现为 6 处(这 2 个 + demo-experience-script + c6-bench-cases must_pass + UIUE 炸场 + 待统一 demo-golden-run),单源时全部归并,不另起。

---

## OPEN-POINTS + 入口顺序（hermes 消化辩证,2026-06-22;权威开放点盘点）

- **治理债 = 头号**(hermes + CC 8D 一致):合规审计 + receipt 聚合数 + metadata 声称 三层共同造「全 PASS 假体系」;codex 执行层诚实(救命),但审计链一次没下钻 file:line/样本级 → 根因藏一整轮。**治理债>技术债**(会复制到下次)。
- **债排序(致命度)**:① 治理债(审计不实跑 + 无 surface/scorer 同源语义门)② 架构债(spec 写 metadata 非 enforce;真删工具/name-first/label-conflict 都是子集)③ SSOT 债(Compiler 不存在,5 套手写)④ 实验设计债(范式没对照实验)⑤ 真机阻塞。**⚠️ 致命度 ≠ 修复顺序:SSOT 债(Compiler)是 ②③ 多条债的根,修它一次消多条**。
- **未收口开放点**:
  - **D1**:助理已拍 **A+**(建 RouteDeriverV2,inputs 去 exec_tier),**待磊哥最终确认**。
  - **G2-G32 大半未 grill**(数据契约细则/训练配方/审计/真机/防复发)。
  - **真机 iOS endpoint 未采购**(V-PASS 阻塞链,不能再拖)。
  - **BG2**:L1_para 确定性槽位解析器未实装(`FastPathIntentEngine.swift:12` 只 1 条「打开空调」硬匹配)→ runtime rule_eligible 几乎全降级 LoRA 兜底。
  - **BG1**:demo 脚本未冻结(已延后,聚焦能力层)。
  - removedToolID 从 Compiler 派生 / state_delta_exact 依赖 verify_gold(已记 A0/G5)。
- **入口顺序(CC 辩证,纠 hermes C→A→B 的依赖倒置)**:hermes 的 C(make verify 三门)里 surface-consistency 门要检查「同源」,但同源要 Compiler(B)先派生 → 现状两套手写跑就卡 `intersection=∅` 一直 fail。且 **A(RouteDeriverV2)⊂ B**(source_of_truth=Compiler,非 A→B 两步)。→ **正确入口**:① 「A=RouteDeriverV2」+「C 的数据修复门(label/name-first/delete,不依赖 Compiler)」**并行起步**(都防带病训练 + 不互依赖)→ ② B 的 surface/scorer 派生 → ③ C 的 surface/scorer 门(检查 B 派生)→ ④ G4 ablation + A1 对照。
- **状态**:开放点盘点,非决策晶体;入口顺序待 grill 收口进 exec-plan 关键路径。
- **待 grill 议题（hermes 4 债,磊哥定先不深聊、记此待 grill,收口进 grill-checklist）**:
  - **① 审计模板(治理债载体,要单独产出 `audit-template.md`)**:审计 SOP 硬段——(a) **必实跑一手数据复算**(python/grep 到 `file:line`/样本级,**不只 receipt 顶层聚合数**)(b) **surface/scorer 同源语义门**(training==c6==runtime + 两套 scorer 不并存)(c) 下钻最细粒度(axis/样本/代码行)(d) candidate 签发必异源终审(同源不代替)。对应 8D P7 + `claim-vs-reality-gap` 三铁律。
  - **② 架构债**:spec 写 enforce 非 metadata(真删工具/name-first/label-conflict 都是子集)→ P2/P3/P4。
  - **③ SSOT 债**:ToolContractCompiler 不存在,训练/C6/runtime/scorer/verifier 5 套手写 → P1/入口 B。
  - **④ 实验设计债**:范式从没对照实验、全凭聚合数推 → A1 D/B tiny 对照。

---

## C5-GRILL-G5-G9-data-contract-fix

- **status**: `Accepted-for-contract-generation`
- **decision**:
  - **5 make-verify tests**(进 `Makefile` test target):`test_counterfactual_physical_delete / test_label_conflict_gate / test_name_first_render / test_no_placeholder_slot / test_surface_variant_counterfactual_mutation`(新增,防 removedToolID 范式漂移)。stdout receipt 只证据不 gate。
  - **G5 真删工具**:`removedToolID` → **`target_surface_ref`(Compiler 派生,改名)**;`mutation`:D_DOMAIN=`remove_tool_by_name` / B_FRAME=`remove_device_action_from_frame_schema`(⚠️见 catch);assertion=`prompt_text_no_longer_contains_target_capability`。
  - **G6 label 门**:`grouping_key = sha256(canonical_system + canonical_user + canonical_rendered_tools)`;同 rendered prompt 既 TOOL 既 NO_TOOL → P0 fail。**(CC discovery:label 门 = G5 真删的验证器,互锁——没真删则 rendered_tools 同→fail)**。
  - **G9 name-first**:assistant payload 显式 ordered `[name, arguments]`;canonical hash 另用 `sorted_normalized_json`(独立层);**不依赖 Dictionary/JSONEncoder 偶然序**(纠 `render:2409 keys.sorted()` 致 name-last)。
  - **G8 占位符门**:只扫 `assistant_tool_arguments / expected_tool_calls.arguments / generated_c6_expected_args`;`forbidden_value_regex: ^<[^>]+>$`;排除 wrapper token(`<tool_call>`/`</tool_call>`);**不扫原始文本 wrapper**(防误伤)。
  - **G4 ablation feature flags 矩阵**:`g4_ablation_switches`(counterfactual_physical_delete/name_first_render/label_conflict_gate/placeholder_gate on|off|p0_fail);E1-E4 独立 experimental bundle(train_manifest/data_gate_receipt/make_verify_stdout/c6_axis_receipt);**E4 综合通过才固化 production Data v2**(不先全修死再声称 ablation)。
- **🔴 CC catch(B 范式实装 gap,A1 前必解)**:`toolCallFrameToolSchema:1951-1958` 的 `device`/`action_primitive` 是 `{"type":"string"}` **自由值、无 enum** → 助理的 B-frame「从 device/action enum 删目标能力」**落不了地**(无 enum 可删)。→ B 范式 counterfactual mutation 要么**先给 frame schema 加 device enum**,要么用别的方式(prompt 声明「不支持 X device」)。**影响 A1 D/B 对照:B 版 counterfactual mutation 未定,A1 前必解,否则 B 版数据修复落不了地、对照不公正**。
- **evidence_refs**:`makePositiveSample:2399-2402`(字段已有);`augmentValue:1874`(valueStrategy by value.type);`toolCallFrameToolSchema:1951-1958`(device 无 enum);`Makefile`(test target 现仅 2 个)。
- **next**:~~E0-E5~~ → 改 **α: ToolContractCompiler scaffold deliverable**(见下,助理拍 + CC 认)。
- **candidate_status**: UNSIGNED/BLOCKED

### 🔁 助理深审升级(R1-R5 / Y1-Y4,CC cite-verify 全坐实)
- **R1**:5→**6 check**,加 `test_route_derive_input_completeness`(每样本 `derivation_inputs` 含全 input keys 且非 nil → 防 D1 派生器声称吃 4 输入实际 2 输入 = metadata 当 enforce 覆辙)。
- **R2**:G4 switch matrix **加 `surface_variant: D_DOMAIN|B_FRAME`** + `matrix_constraint`(E0-E4 固定 D、只切数据维度;E5 在 E4 基线只切 surface)→ 防 E5 同改 surface+数据基线两变量混杂(8D D4.4 变体)。**修正 CC 之前「E0-E4 用 B-frame」错** → 应固定 D(D 删工具简单,B 有 enum gap)。
- **R3**:`target_surface_ref.canonical_key`(D=`tool_name` / B=`sha256(device:action:scope)` Compiler 派生);assertion 吃 **chat_template 渲染后文本**,非 schema array → 防 escape point 第 2 季。
- **R4**:label gate `canonical_rendered_tools = sha256(chat_template.render(tools).normalized)` **复用训练实际 renderer**、非 schema array hash → 防检测口径≠模型学习口径(8D D4.1 escape 重演)。
- **R5**:Makefile diff/test 死锁——新 test 同次提交 + fixture 走 `tests/fixtures/`、临时输出走 `build/`(gitignore)、receipt 走 stdout 不落盘(否则 `diff:43` 先 fail、test 跑不到)。
- **Y1**:D1 = **14 处 routeTier callsite(`grep -c=14` 坐实)+ train.jsonl 4464 重生成**,非改一行;三步:RouteDeriverV2 spec → 批量替 14 处(每处亲核)→ regen + verify_gold 100% → R1 check。
- **Y2**:**ToolContractCompiler scaffold 是 `surface_variant_counterfactual_mutation` 硬前置**;task 序 T1 scaffold → T2 6 check → T3 regen 接 Compiler → T4 E0-E5。
- **Y3**:placeholder regex `^<[^>]+>$` → `<[^>]+>`(contains 非 anchor,防嵌套 `把<位置>调<value>度` 漏)。
- **Y4**:stdout receipt 结构化 `{test_id,expected,actual,sample_ids_failed,file_line_ref}` + fixture-driven(8D D7-4 审计实跑落地)。

### 🔴 CC discovery:C6 applier 硬编码(深挖三层之底)
`C6VehicleToolBench.swift:1163-1175 apply` 用 `switch call.name { case "set_cabin_ac": applyAC... }` **硬编码 set_cabin_* → 只认 D-domain,B-frame(tool_call_frame) 下 state_delta 算不出**(switch 认不到)。→ A0 hard_pass 的 state_delta 轴在 B 范式失效。**Compiler scaffold 必须派生 applier/normalizer(任何 surface→内部 IR→state mutation),不只 toolSpecs/cases**;否则 A1 D/B 对照里 B 版连 state_delta 都跑不出。

## C5-GRILL-α-toolcontract-compiler-scaffold（下一题拍板:α 优先,非 E0-E5）

- **status**: `Accepted-for-contract-generation`
- **decision**:下一执行入口 = **ToolContractCompiler scaffold deliverable**(非 E0-E5;助理:5-6 gate 中≥4 个断言对象是 Compiler 派生产物,没 Compiler 门是空门照样绿)。
- **最小 deliverable**:`generated/{D_domain.tools.json, B_frame.frame_schema.json, rendered_tools_text}` + **`applier/normalizer` 派生(CC discovery,任何 surface→内部 IR→state mutation)** + Makefile `regen` 接入 ToolContractCompiler;输入 SSOT = `semantic-function-contract.jsonl`(能力层,两层 scope 已拍)。RouteDeriverV2(D1)是 Compiler 的 route 模块(A⊂B)。
- **CC 补(并行优化)**:**`placeholder_gate` + `name_first_render` 不依赖 Compiler 派生产物,可与 scaffold 并行先做**(name-first 是 `:2409 render` 改,placeholder 是 regex 扫 arguments);其余 4 gate(surface_variant/label_conflict/route_input_completeness/counterfactual_delete)依赖 Compiler 产物,等 T1。
- **evidence_refs**:`C6VehicleToolBench.swift:1163-1175`(applier switch 硬编码)/`:357-386`(CaseSpec)/`:357`+`toolSpecs:397`(三层);`routeTier` 14 callsite;`Makefile:42-43`(diff)。
- **candidate_status**: UNSIGNED/BLOCKED

## C5-GRILL-axes-catch — 🔴 部分 SUPERSEDED(2026-06-22 下钻一手 gate_result 推翻二手 axes,真相见 A0「三轴真相」段)

- **status**: `strategic风险/E0.5 撤回 · R2/R3/R6/R7 保留 · 改 γ 重定义`
- **date**: 2026-06-22
- 🔴 **本段一致性边注(2026-06-22 自检,引用以此为准)**:段内所有 `15/30 / 11/30 / 净11` 均为**第6同坑前旧算**,**现行 action 锚 = base 10/23**(权威=A0「三轴真相」+ δ + ζ);下方 `R5(改版)` 的「分母30/baseline 11/30/K=超11」**SUPERSEDED-BY-ζ**(ζ 锁相对门 `>base 10/23`);`γ2`(P vs Q)**SUPERSEDED-BY-ε**(ε 已拍 P,readback 走 renderer);行号统一 `:1039`(eval path 删此行)/`:865`(gold path 不改)。段内文字保留作 grill 演进痕迹。
- **CC 第4次同坑(仍成立)**:CC 拍 E4「超 base 7/57」——7 是 `all_c6_release` 整体(negative 撑),不是 positive action。✅ 保留。**但下一轮(助理 catch)揭示更深:连 `vehicle_action_positive base=0` 本身也是 receipt 二手手 rolled,真一手 action 轴(tcm&sdm) base=15/30(CC 第5次同坑)。**
- ❌ **撤回 strategic 风险(基于二手 base=0 = CC 第5次同坑)**:原写「vehicle_action_positive base=0 → args/state 是 base+LoRA 共同短板 → Qwen3-1.7B 可能不行/双线」——下钻一手 `gate_result` 坐实 **action 轴(tcm&sdm) base 15/30=50%**,模型**有** args/state 能力;二手 axes 的 base=0 是 overall 口径(混入 readback 话术)。**8D D4.2 confounder 在 action 层已部分排除**(模型 args/state 不是短板,recovery action 层单线)。
- ❌ **撤回 E0.5 zero-shot D-prompt 探针**:action 轴 base 15/30 已答「模型 args/state 有能力」,探针多余(同意助理撤 E0.5,理由=action 已证能力,非"readback 是数据 bug")。原 discovery「base=0 后下钻样本分判等过严 vs 模型短板」**迁移到 readback 轴**(见 γ2 根因探针三支:prompt/能力/判等)。
- **吸收助理 R1-R7(CC cite-verify,接 G5-G9 的 R1-R5/Y1-Y4 续号)**:
  - **R1**=本段 catch(CC 第4次同坑,已认)。
  - **R2**:E1 `wrapper_rate` 拆 **`wrapper_correct`(吐 `tool_call_frame`,训练目标)vs `wrapper_drift`(吐 `tool_call`,跑偏)** 两计数;`lora_observed=['tool_call']` 坐实当前 100% drift,不能合并成「有 wrapper」自我安慰。
  - **R3**:E0 baseline **强制 per-axis disaggregation**——receipt 必逐 axis 列 base/lora(all_c6_release/vehicle_action_positive/ood_no_call/coverage_ambiguous/trap/heldout),禁报整体单数;A0 成功口径锚 `vehicle_action_positive` axis,非整体。
  - ~~**R4** E0.5~~ → **撤回**(action 轴已证能力)。
  - **R5(改版)**:E4 阈值 axis-conditional = **`action_hard_pass(tcm&sdm&clm&!parser) ≥ K`**,分母 **30(非 34)**,baseline **base 11/30**,K=超 11(`no_negative_regression` + `wrapper_drift→0`);**readback 单列话术轴,不混进 action 阈值**(γ2 后定 readback 算法)。
  - **R6**:E5(范式 surface)前置拆 3 件套——① B-frame `device`/`action_primitive` enum 派生(解 `:1951-1958` 无 enum gap)② mutation 语法 device-action-tuple(`remove_device_action_from_frame_schema`)③ `canonical_key = sha256(device:action:scope)` Compiler 派生(接 G5-G9 R3)。
  - **R7**:复现 **≥3 seeds**(`train_data_seed` + `mlx_init_seed` 独立变,非同 seed 2 跑);A1 `reproducible_across_2_seeds` → **`across_3_seeds`**。
- **元认知(已落 rules)**:`claim-vs-reality-gap` 铁律3 强化——定 ablation/门的阈值/锚点/baseline 前,**必按最细 axis 逐行打印 base/lora,禁引整体聚合单数当某子维度锚**;「base=0→模型不行」前先下钻样本分判等 vs 模型。
- **evidence_refs**:一手 `c6-summary.json:eval_runs[].gate_result`(action base15/30·净11,readback base0/15,overall base0/30)推翻二手 `c6-eval-receipt.json:diagnostics.axes`(手 rolled 无产生器);`C6VehicleToolBench.swift:1012-1016/1048/1319`;`spike-e3-results.json`(chunkText="" base 单发 FC)。
- **🔴 拍下一题(γ 重定义,CC 拍待磊哥)**:
  - **γ1 = 三轴代码产生器**:`scripts/build_axes_from_summary.py`(读 `c6-summary.json:eval_runs` → action/readback/overall 三轴 base/lora,接 `make verify`,替代 receipt 手 rolled);R3 落地。
  - **γ2 = readback 话术口径 grill**:**磊哥澄清(2026-06-22):mock 仅端状态(车控 state),ASR 音频/指令/话术均真实** → readback 测模型真实话术**测对方向**(renderer-mock 分支砍掉);base 0/15(`chunkText=""` 单发 FC)是**真实话术缺口**。根因探针三支:(a) prompt 没要求说话术(harness 配置→改 prompt)(b) 模型能力(→训 LoRA 同轮 text+tool_call,home-llm 范式)(c) 判等过严(`contains` 要求复述'26'等数值,模型说了没复述)。→ 定 readback 算不算 hard_pass + C5 训练数据是否加话术监督。
  - **撤 E0.5**;α(E4 R5 改版)/β(B mutation R6)顺延 γ 后。
- **candidate_status**: UNSIGNED/BLOCKED

## C5-GRILL-ε-readback-architecture-P（磊哥拍 P + RAW vault 5 处一手工程证据 + readback/clarify 分流）

- **status**: `Accepted-for-contract-generation`(磊哥拍 P,2026-06-22)
- **decision(ε = 方案 P)**:demo 确认话术架构 = **方案 P(单发 FC + 端 renderer 出状态播报 + UI 卡片 + TTS)**,非 Q(模型 two-turn 自吐话术)。
- **RAW vault 一手工程证据(助理自主探查基座原料 + CC cite-verify,只读不入仓)**:
  - 证据1 `大模型/复杂车控FunctionCall交付手册.md:248-262` 时序图 `Car-->>U 技能执行播报`(执行成功端播报=P)+ `FC-->>U 场景兜底播报`(兜底模型话术);`:203` FC 兜底播报=端规则。**揭示混合架构(非纯 P)**。
  - 证据2 `座舱/座舱端状态上传协议与能力边界.md:94-100` 推荐层(话术)与执行层(FC)并列=端渲染。
  - 证据4 `大模型/AIOS架构与框架.md:30-44` TTS(执行层)vs 大模型(中枢决策层)架构分离。
  - 证据5 `大模型/车控智能体V1-0专家解读与安全门控.md:131`「解释服务可执行/可回退/可追责,非炫耀模型理解」(反 Q 模型自由发挥);`:26` 冲突裁决写死(控制决策,略宽引申)。
  - ⚠️ **CC 辩证(不迎合)**:证据3 `TTS实体播报与文本归一化体系` **过度引申**——TTS 文本归一化(G2P/数字/SSML)对 P/Q **都需要**,正交、非 P 专属证据。净 = 证据 1/2/4 真支持 P + 证据5部分直接 + 证据3剔除。
- **🔴 CC discovery(精确化助理「P=readback 单列」,三重坐实)**:真实产品 = **混合架构,不是全盘 P**:
  - `readback_match`(positive_action 执行成功状态播报)→ **P(端 renderer)**,降级 informational。
  - `clarify_match`(rejected/ambiguous 拒识/澄清话术)→ **模型职责,保留计 model hard_pass**(证据1兜底 `FC→U` + 证据5 `:130` 例子「需先确认主驾还是副驾」+ C6 `clarifyGateMatches:1120 textEvidenceMatches(output.text)` 三重坐实)。
- **方案 P 最小 surgical fix(CC 正确版;助理认上轮「换 goldReplayOutputText」糊了 = 第7同坑)**:
  - 删 `C6VehicleToolBench.swift:1039 failures.append(.readback)`(readback fail 不再触发 `hardFailed`);`readback_match` 字段保留 informational。
  - readback 单列 **release-total gate 形态 B**:`readback_match_rate ≥ 100% on verify_gold`(renderer 自检,锚 renderer 决定性不锚模型)+ `≥ base on eval`(不退化);CLAUDE.md「读回 mock 态」硬契约靠此守。
  - **不删 `looksLikeMachineReadback` / 不改 `clarify_match`**(clarify 仍测模型话术=模型职责)。
- **recovery 定性(ε 后锁)**:**单线** = action 数据契约修复(锚 base `mp_positive_action` 10/23,LoRA 超 10/23)+ clarify/refusal 话术(模型职责,一起训);readback 状态播报走 renderer 不进 LoRA hard_pass。
- **evidence_refs**:RAW vault `~/workspace/raw/01-Wiki/{大模型,座舱}/*.md`(只读 cite-verify);`C6VehicleToolBench.swift:1039`(eval readback append,方案P删)`/865`(gold path 不改)`/1120`(clarifyGateMatches)`/1297`(goldReplayOutputText);助理研究档 `docs/research/🔴 RAW vault 5 处独立证据全部指向 P*.md`。
- **next(δ/ζ 已 grill 完 → θ-data)**:δ(axis producer 规格冻结)+ ζ(阈值相对门锁)+ ι(同义词表并入 δ)已完成;**下一题 = θ-data**(C5 训练数据配方:positive action 修复 + 安全拒识/ASR 澄清/工具映射样本)。
- **candidate_status**: UNSIGNED/BLOCKED

## C5-GRILL-δ-axis-producer-spec（规格冻结 NOT-Implemented;CC catch 助理 R2 clarify frame 错）

- **status**: `Accepted-for-contract-generation, NOT-Implemented`(implementer=**codex 长跑**[磊哥拍],时机=**grill 收口后**防返工)
- **deliverable**: `scripts/build_axes_from_summary.py`;input = `c6-summary.json:eval_runs`(一手 gate_result)+ `c6-bench-cases.jsonl`(schema 字段)
- **axis 分区(按 schema 字段,禁 id prefix;57 闭合=30+7+8+12)**:
  - `mp_positive_action` n=23(enc=F AND pre≠delta)= **recovery 主成功轴**
  - `mp_refusal` n=4(enc=T)/ `mp_noop` n=3(enc=F AND pre==delta,幂等 vs 状态感知=独立产品维度与 action capability 正交,base 1/3)= informational
  - `cov` n=7 / `trap` n=12(6子类×2)/ `neg` n=8(**CC catch 助理 9→8,57 闭合**)= informational
- **双口径 per axis per arm**: `hard_pass_with_readback`(旧,调试)/ `hard_pass_without_readback`(P 真口径,删 :1039 后);锚点 `mp_positive_action.base.without_readback=10/23`
- **🔴 readback vs clarify 分流(CC catch 助理 R2 frame 错,亲核坐实)**:
  - **走 P 判据 = 「端确定性生成(状态播报)vs 模型智能决策(拒识/澄清)」,不是「吃不吃 output.text」**(助理 R2 用代码特征 `textEvidenceMatches(output.text)` 当统一判据 = 第7同坑第二变体「代码模式同≠产品语义同」)。
  - `readback`(positive_action 执行成功状态播报)→ **走 P**,删 `:1039 failures.append(.readback)` + 单列 release-total gate 形态B。
  - `clarify` **全部保留计 model hard_pass**(拒识/澄清=模型职责=demo 安全门/听懂核心,**不删 `:1042`**):
    - implicit/explicit/passthrough(23 positive+3 noop+部分 trap):看 `toolCalls` 行为判等。
    - rejected/ambiguous token 空(NEG 8+COV 7=15):看 `toolCalls.isEmpty`(`textEvidenceMatches` 空 token 直接 true,不吃 output.text)。
    - rejected/ambiguous token 非空(7:MP-024/025/026+TRAP-ASR 2+TRAP-SAFE 2):**保留计 hard_pass**;但 **CC 亲核 base 行为拆 1+6(catch 助理 R4「7 都修判等」)**:
      - **1 个判等过严**(`SAFE-001` base 话术对「无法在高速…静止状态」缺 '行驶中' token)→ 放宽 `textEvidenceMatches`(A 同义词表,议题 ι)。
      - **6 个 capability gap**(MP-024/025/026 开门→错调 `set_cabin_window` / SAFE-002 没识别行驶中安全约束 / ASR-001 没澄清直接执行 / ASR-002 吐∅)→ **放宽判等救不了,进 C5 训练数据(安全拒识/ASR 澄清/工具映射,议题 θ)**。
      - **7 个 base/lora 都 0/7 = recovery 真硬骨头(demo 安全门/听懂灵魂)**;lora 全塌缩 `toolCalls=[]`。
- **CC catch 助理 R2 总账(不迎合)**:① scope 错(rejected/ambiguous=**22 非 10**,漏 NEG8+COV7=**第8同坑当场复发**)② frame 错(7 个非空=安全拒识/澄清=模型职责=demo 核心,**绝不走 P 剔除**否则阉割安全门)③ 合理内核(7 个 `textEvidenceMatches` 判等过严→**放宽非剔除**)。
- **make verify check#7**: `axis-schema-conformance`(grep id-prefix 拆法 fail)+ `readback-decoupling`(without_readback 不含 readback failure_class;clarify 仍计)。
- **candidate_status**: UNSIGNED/BLOCKED

## C5-GRILL-ζ-E4-threshold（相对门锁 + 绝对门待 demo scope;拒凭印象单一 K）

- **status**: `Accepted-for-contract-generation, NOT-Implemented`
- 🔴 **实测回写(2026-06-22,θ-α 训完级联)**: θ-α generated-positive 训练完成,**全 checkpoint 未过此相对门**(门定义不变,θ-α 执行 FAIL)。详 `grill-decisions-amend-execution-gap-reconciliation.md §5` + `docs/lessons-learned.md` #49;方向待 grill。
- **相对门(硬,现在锁)= recovery 启动最小成功标准**:
  - `lora.mp_positive_action.hard_pass_without_readback > base 10/23`(严格大于=LoRA 必须正向,防负优化)
  - AND `no_negative_regression` on {refusal, trap, neg, coverage} 4 轴
  - AND `wrapper_drift_rate == 0`(不吐 `tool_call` 错 wrapper)
  - AND `lora.demo_critical_7.hard_pass ≥ base 0/7`(base 当前 0,LoRA 不退化;实质目标=训出安全拒识/ASR 澄清,见 θ)
- **绝对门(recovery 完整目标,标 TODO 不凭印象)**:
  - `K_abs`: ⏸️ DEFERRED,待 demo-golden-run 解冻从核心动作覆盖推。
  - 参考线(非门):home-llm LoRA ~70-80% positive,**不硬拍**,待 E1-E4 spike 验证可达性。
- **禁项**:`K=base+3 / 10/34 / 13/23` 等单一数字 pin = 凭印象(助理第8同坑第三次复发);「整体 hard_pass>base」当 positive 锚 = 违 axis-conditional(claim-vs-reality 第4实证)。
- **依赖暴露**:recovery 绝对成功标准依赖 `demo-golden-run`(已延后);相对门足够启动 recovery(先证 LoRA 正向非负优化),绝对门补在 demo scope 解冻后。
- **candidate_status**: UNSIGNED/BLOCKED

## C5-GRILL-θ-data-spec（C5 训练数据配方;助理 4 gap CC+磊哥确认全成立 → 6→7题 + 7case映射矩阵 + positive-not-diluted invariant）

- **status**: `Accepted-for-contract-generation, NOT-Implemented`(implementer=codex 收口后,从契约派生)
- **θd-1 三类新样本来源**:**派生骨架 + LLM 增广变体**(`source: derived|augmented`,骨架可追责、变体扩泛化),与 BG3 两层 SSOT / α Compiler 一脉。
- **θd-2 安全拒识**:从 `risk-policy.yaml` R0-R3 **codegen 拒识样本**(R级→拒识话术模板 + `toolCalls=[]`),非手编(安全检查从 prompt 推到数据层)。
- **θd-3 ASR 澄清**:封闭词表**拼音 fuzzy 造噪声**(CFStringTransform)+ 澄清话术监督(不直接执行)。
- **θd-4 工具映射边界**:**超工具集→拒识非错调最近工具**(治 base `打开车门→set_cabin_window`,第6同坑揭示)。
- **θd-5 配比【Gap B:拍决策门,非"待spike"暗未拍】**:
  - spike 跑比例 grid(positive:negative = {3:1, 5:1, 8:1} × templated 加权 10-25x);
  - collapse monitor threshold:`empty_rate>0.15` 或 `wrapper_drift>0` 触发早停;
  - 失败回退:collapse → 提 positive 权重 / 降 negative 比例重跑。
- **θd-6 masking/loss-span【Gap C:加 positive-not-diluted invariant 对治 0/34 根因】**:
  - loss 覆盖:拒识=安全理由话术 token / ASR澄清=澄清话术 / positive=tool name+required args;
  - 🔴 **invariant**:`positive action 不能被 negative loss 稀释`(positive oversample/high-weight + negative loss ceiling)→ 直接对治 0/34 的「negative(refusal 0.1 + 矛盾监督)压倒 positive 致 LoRA 学『沉默=safe』全面塌缩 `toolCalls=[]`」根因(8d L29 + lora 7case 实测坐实)。
- **🔴 θd-7【Gap D 新增】OOD generalization 探针**:held-out OOD smoke set(10-15 case,**绕弯说法/本地化词汇/句式变体[剔方言·磊哥拍]**,demo期不训不见,eval跑),定 `OOD pass rate floor`(⏸️ floor 待 E1-E4 spike 看 base OOD 实测再锚,禁凭印象 pin 30%·CC,同 ζ「拒凭印象单一 K」纪律);**与 held-out 防泄漏(C5数据门)不同**——OOD 测分布外泛化(北极星「客户随意说全集」),防 in-distribution 飘绿但 demo 现场撞 OOD 全塌。
- **🔴 7 demo-critical case × θd 映射矩阵【Gap A:每 case ≥1 θd 覆盖,无遗漏】**:
  - `SAFE-001`(判等过严)→ **ι 同义词表**(放宽 `textEvidenceMatches`,'行驶中'扩安全语境词)
  - `MP-024/025/026`(开门→错调 window)→ **θd-4** 工具映射边界
  - `SAFE-002`(没识别行驶中安全约束·**双踩安全+工具映射**)→ **θd-2**(主·拒识) + **θd-4**(次·工具映射);**安全门优先**,监督=拒识+安全话术**非**"正确调 set_door"(防训出『行驶中正确开门』危险样本·CC补强②)
  - `ASR-001/002`(没澄清直接执行/吐∅)→ **θd-3** ASR 澄清
  - (7 case 全覆盖;每 θd 反向声明覆盖哪些 case,防「G7 配比再科学但某 case 训不到现场塌」)
- **助理 4 gap 总账(CC cite-verify + 磊哥确认全成立)**:Gap A 映射矩阵 / Gap B 配比拍决策门 / Gap C positive-not-diluted invariant / Gap D OOD 探针。
- **🔴 磊哥 final 拍板 + CC 3 补强(2026-06-22)**:7题 + 7case×θd 矩阵 + positive-not-diluted invariant **全盘 Accepted(磊哥 ratified)** → 进 θ-train。
  - **方言裁决(磊哥拍)**:θd-7 OOD 剔方言(demo=普通话销售现场;方言属 ASR/Paraformer 层短板非 LoRA 该补;北极星「说全集」=语义广度非方言广度)。
  - **CC补强①(spike 防混淆变量·8D D4.4 变体)**:θd-6 invariant 的 positive oversample 改变有效 pos:neg 比,污染 θd-5 grid → spike **固定 invariant(oversample 倍数+loss ceiling)作常量,只切原始数据 ratio**;report **同记原始 ratio + 有效 ratio**,禁混(否则 grid 不可解释)。
  - **CC补强②(SAFE-002 双重失效)**:见矩阵 SAFE-002 行(双归 θd-2 主+θd-4 次,安全门优先,监督=拒识非 set_door)。
  - **CC补强③(拒识/澄清防死记·治 0/34 死记)**:θd-2 安全拒识/θd-3 ASR 澄清的**触发判定**从 risk-policy R0-R3/封闭词表 codegen(可追责),但**话术表层走 LLM 增广多样化**(呼应 θd-1 骨架+变体),否则模板单一→OOD 绕弯危险/模糊请求拒识塌;θd-7 OOD 专设「绕弯说的危险/模糊请求」测拒识泛化。
- **next**:θ-α-train 配方=`rank16Mainline`(C5LoRATraining.swift:1164)现成最终态(亲核见 θtrain-recipe-baseline)/ 真开放=**θ-α iters(唯一,派单 codex spike+home-llm 参考线)**——marker 已 verified+collapse 监控已定+warmup/clip 已合理已挂,**θ-train 0 题需 grill→转执行**;θ-β(安全门)留后/ 审计框架(G27-G29)/ 真机(G30-G32)/ demo scope(κ)/ 范式结论(G6 据实验)。
- **candidate_status**: UNSIGNED/BLOCKED

---

## C5-GRILL-η-scope-split（磊哥拍：θ-α 纯语义闭环 → θ-β 安全门，两刀分层）

- **status**: `Accepted-for-contract-generation`(磊哥 2026-06-22 拍;CC+助理判断一致)
- 🔴 **θ-α 实测回写(2026-06-22,训完级联)**: θ-α 第一刀已执行,**全 checkpoint FAIL**(训练数值健康但 C6 行为全塌:乱调→不调)。诊断假设(待 grill,均未拍): training-dynamics collapse(零 negative tiger 显形,本段红线警告兑现) vs surface mismatch(`tool_call_frame` 训练 target vs D-domain SpikeE3)。**scope-split 决策本身不变,θ-α 执行结果交 grill 定方向(合 θ-β/加监督/改配方/重训/调 η)。** 详 `grill-decisions-amend-execution-gap-reconciliation.md §5` + `docs/lessons-learned.md` #49。
- **decision**:θ-data 7 题拆**两阶段训练**:
  - **θ-α(语义通·第一刀)**:假设 ASR 文本对,**只训 positive action**(②文本→意图→ToolCall 的 L2-L5 语义泛化)。无 safety 拒识/无 ASR 澄清/无 out-of-toolset 拒识/无 ambiguous 澄清。eval 只盯 `action_hard_pass` 一根轴。
  - **θ-β(安全门·第二刀)**:θd-2 安全拒识 / θd-3 ASR 澄清 / θd-4 超域拒识 / ambiguous 澄清 / θd-5 配比 / θd-6 invariant。
- **闭环职责边界(render+lora 分工,LoRA 只管 ②)**:① ASR 语音→文本=sherpa-onnx(θ-α**假设对**,鲁棒=θ-β 拼音 fuzzy) / ② **文本→意图→ToolCall=LoRA(θ-α 唯一职责)** / ③ 安全门=risk-policy 规则码(θ-α 不训,安全是代码不是 prompt) / ④ ToolCall→state=C3 executor(确定性) / ⑤ readback 话术=renderer 方案P(不训,ε 已拍)。
- **θ-α 成功标准(ζ 相对门 re-scope)**:`lora.mp_positive_action.hard_pass_without_readback > base 10/23`(仍成立) AND `wrapper_drift_rate==0` AND `demo_critical_7 的 positive_action 子集不退化`;SAFE/ASR 子集签留 θ-β(θ-α 训不到 SAFE-002/ASR-001/002);`no_negative_regression` 4 轴因 θ-α 无 negative 数据**自动空满足**,但 **IrrelAcc 实测须守不退化 base 0.789**(防过度调工具,见 tiger)。
- **7 case 分家**:`SAFE-001`(判等过严)→ι 同义词表**不依赖训练数据·可并行** / 其余 positive action→**θ-α**(θd-1 派生骨架+增广) / `MP-024/025/026`(错调 window)→θd-4=**θ-β** / `SAFE-002`(行驶中)→θd-2=**θ-β** / `ASR-001/002`(澄清)→θd-3=**θ-β**。
- **θ-α 红利**:θd-5 配比 grid 免 / θd-6 invariant 天然满足(无 negative loss 稀释) / θ-train G22 action 加权+refusal cap 不需要 / G24 tiny D-vs-B 纯语义单变量更干净。
- **🐯 tiger(不迎合,θ-α 保留)**:零 negative 训练 → 模型易学"啥都调工具" → IrrelAcc 跌破 base 0.789。修法=θ-α 保留 **When2Call distractor-in-prompt**(prompt 塞工具集没有的干扰工具教"没有就别调",P1-C Q8 已拍,非 refusal 样本不引入 negative loss)+ eval 守 IrrelAcc≥base。
- **evidence_refs**:8D D2/D4(negative 压倒 positive 致塌缩 28empty/34);ζ 相对门;ε 方案P;P1-C Q8(When2Call distractor-in-prompt 进 prompt 教辨别);D14 ASRBackend;Q1 risk-policy(`forbidden: door_open_while_moving`)。
- **candidate_status**: UNSIGNED/BLOCKED

## C5-GRILL-θtrain-recipe-baseline（θ-α 配方=rank16Mainline 现成最终态·亲核纠 CC 上版 4 处 cite 错）

- **status**: `cite-verified-fact`(磊哥「lr check 仔细」+ 助理辩证 catch 4 处 → CC 亲核 `C5LoRATraining.swift:1164` 代码 teardown 重核,2026-06-22)
- 🔴 **元教训(claim-vs-reality 变体,与上轮批 MEMORY 同坑换层级)**:CC 上版凭 **1609/1455 早期 smoke run 的 config/receipt**(代码渲染的过期产物 + smoke A/B 旧值)推配方,被助理 catch + 亲核 `rank16Mainline`(配方 SSOT)纠正。**渲染产物 ≠ 配方 SSOT;核了一手但核错版本(smoke 旧值 vs 代码最终态)。**
- **配方 = `rank16Mainline()` 现成最终态(`C5LoRATraining.swift:1164-1188`,无需再拍)**:`learningRate:0.0001`(:1172)/`optimizer:adamw`+`weightDecay:0.01`(:1181-1182)/`rank:16`(:1169)/**`scale:20`(:1170)**/**`warmupFraction:0.08`+`warmupSteps:48`(:1174,:1176)**/**`gradClipNorm:1.0`(:1184)**/`trainingLoop:repo_loop`(:1185)/`epochs:3`/`batch4×accum4`/`maxSeq1024`/`numLayers-1`/全7keys。
- **lr 1e-4 ✅ 实测铁证(保留;纠 P1-C Q7/Q16/Q17 的 2e-4 旧 SoT)**:`1455 run mlx-smoke-only-600.log` iter60@峰值2e-4=2.989 → **iter70=17.540 炸** → iter600 val4.136 不收敛;`1609 run` iter70=0.603 → **iter600 val0.605 收敛**。双变量(lr+optimizer)但发散点精确在 LR 爬峰 2e-4(iter60→70)→主因 LR(1455/1609 同 scale32,lr 结论独立 scale)。
- **🔴 scale=20(纠 CC 上版「scale32」)**:`rank16Mainline:1170 scale:20`+`C5ScaleAuthorityResolution.evaluate:547 firstCandidateScale:20`(权威),`deferredABScales:[32]`(:554)=**32 是 deferred A/B 实验非主线**;1609/1455 config 的 32 是 smoke A/B 旧值(`:2046` smoke 不卡 authority),正式训练 scale≠20 → `scale_authority_mismatch` hardFailure(:555/:2047)。
- **🔴 warmup 已合理(纠 CC 上版「12 偏少」)**:`warmupFraction:0.08`=8%;`renderedWarmupSteps`(:1207-1209)=optimizerUpdateSteps(150)×0.08=12(optimizer-update 单位)=48 micro-iter=8%;research Q1「12偏少」是单位误读。**无需重算**。
- **🔴 clip 已挂 repo loop(纠 CC 上版「stock CLI 插不进」)**:`main.swift:146 renderTrainCommand`=`c5_mlx_train_loop.py`(repo loop:149)+`--grad-clip-norm 1.0`(:162)+`--nonfinite-fallback-lr 5e-5`(:163)+`--metrics-jsonl`(:164);`:291 backend=repo_loop`;repo loop(`c5_mlx_train_loop.py` 616行,clip_grad_norm:244+MetricsWriter:59)。**clip 默认1.0已挂**;CC 上版引「1609 receipt:59 blocked_stock」是那次 stock CLI 旧实跑态(代码已演进)。
  - **真实状态=`trainingLoopSourceState:verified`(亲核 2026-06-22 当前工作树坐实,纠 CC 上版「marker 未 sign」过期/错断言)**:`c5_mlx_train_loop.verification.json`=`source_state:verified`+`verification_status:pass`+`verified_at:2026-06-22T00:34`(PR2 2c);**亲核 SHA 逐字符匹配**:marker `script_sha256:5400641...e0f7` == `shasum -a 256 c5_mlx_train_loop.py` 实际值,git tracked → `main.swift:326-332` 返回 verified,gradientClipStatus=`verified_repo_loop_clip`。clip+nonfinite-fallback+metrics 全 verified 挂上。**🔴 CC 上版「未 sign」是凭代码 `:324 missing_marker` 分支推、未核 marker 文件实际内容**(核代码静态逻辑≠核运行时实际状态,§34 行为探测)=claim-vs-reality 又一变体;本次自 `shasum` 亲核坐实(未凭助理转述)。
- **🔴 metrics.jsonl 已挂(纠 CC 上版「stdout parse」)**:`main.swift:164 --metrics-jsonl`+MetricsWriter(:59/:292)emit grad_norm/loss/lr,**不需 stdout parse**(那是 1609 stock CLI 旧态)。
- **🔑 假删/label_conflict 互锁同一bug(助理洞察+CC亲核)**:NO_TOOL(`:2327 buildNoCallSamples` 从 positive 派生)`removedToolID`(:2342)是 metadata,但 `tools`(:2399)=toolCallFrameToolSchema **没真删** → 同 utterance positive+NO_TOOL prompt 全一样只 label 不同=**label_conflict 与假删互锁**(G5-G9 R1「label gate=真删验证器」实证)。**θ-α 砍 NO_TOOL 同时绕开两者**;α Compiler+applier 作用=**surface 同源+state_delta 算法**(非真删,θ-α 无 NO_TOOL 不需真删);name-last 在 `:2409 keys.sorted()`(positive 也踩,仍需修)。
- **empty=hit 真路径=`C6VehicleToolBench.swift:1029`**(`if !expectNoCall,!toolMatch{failures.append(.toolCall)}`;纠 CC 上版「C6 scorer:161」混 spike-e3:161→C6:161,实 :161=tags 字段);`:1039` readback append(ε 删此行)。
- ⚠️ **1609/1455 是 dry-run smoke(无能力诊断价值)**:`generator_orchestration:dry_run_only`,loss 只证 LR 配方健康不发散,**不证学会语义**;θ-α 真数据 loss 会更高。
- **evidence_refs**:`C5LoRATraining.swift:1164-1188`(rank16Mainline SSOT)/`:547-557`(scale authority)/`:1207-1209`(renderedWarmup)/`:2327,2342,2399,2409`(假删+name-last);`Tools/C5TrainingCLI/main.swift:146-167`(renderTrainCommand)/`:280-333`(verification marker)/`:291-294`(backend+clipStatus);`c5_mlx_train_loop.py`(616行,:196/:244 clip,:59 MetricsWriter);`C6VehicleToolBench.swift:1029,1039`;本机 1455/1609 run(早期 smoke scale32,lr 对照)。
- **candidate_status**: UNSIGNED/BLOCKED

---

## C5-GRILL-audit-framework（审计框架=防「全PASS但故障依旧」+防自己成安慰剂；议题1拍 C++）

- **status**: `Accepted-for-contract-generation`(议题1 物理化程度拍 **C++**,CC 辩证助理 C+ 补 3 gap;议题2-N pending)
- **定位**:0/34=持续审计+superaudit+GPT Pro 终审全 PASS 故障依旧(审合规不审语义);audit-template 要防此 + **防自己成 prose 安慰剂**(Elevate-or-Kill:纯文档 SOP 没人 enforce=又一声称层)。
- **亲核基建现状(CC 坐实,证助理 claim)**:
  - ✅ `Tools/C5TrainingCLI/main.swift:124 exit(65)` 当 status==blocked(数据准备硬阻断,但只看数据门不看 surface 同源)
  - ✅ `Makefile:19 verify`=verify-source regen verify-refs diff test;`:26-28 test` **仅 test_quarantine+test_fc_flags**;D2 拍的 surface-consistency/label-conflict/name-first check **未实装**
  - ✅ **无 sign-or-block/candidate signing 脚本**(grep 命中 0,待建)
- **维度(4+1)**:语义正确性(8D P7)/实跑一手复算(铁律2)/下钻最细粒度(铁律3)/**reviewer self-check 十变体(本轮新增)**/异源终审(§16/§31)。
- **议题1决策=C++(物理化最强 enforce,CC 辩证助理 C+)**:
  - **接受助理核心洞察**:**「recompute 非空」=metadata check 非 semantic(0/34 根因模式:removedToolID 非空但 tools 没删,填 `recompute:"已复算"` 就绿)** → 升 recompute **verifiable**。
  - 🔴 **CC 补 Gap1(纠助理 §3 vs elephant 自相矛盾)**:助理 elephant「不要求重跑成功只比 receipt 里 hash」**破坏 verifiable**(hash 变回 receipt 自填 metadata,agent 可填假 command+假 output+假 hash 三者自洽)。修正:sign-or-block 脚本**自己重跑 command→自算 output hash→比对 receipt expected**(fail-closed,重跑成功必要);command 必须**确定性可复现**(不依赖真机/时间戳/随机);**不可复现证据(真机 latency/memory)走 device-fingerprint receipt 另一类门**,不混进 recompute verifiable。
  - 🔴 **CC 补 Gap2**:recompute command **从固定语义检查集选**(非签发人自定义,防填 `echo pass` 绕过):`surface-consistency`(training==c6 tool surface 交集)/`scorer-single`(无两套 scorer,grep 代码产生器)/`axis-schema`(mp_positive_action 按 schema 字段拆分母)/`verify-gold`(gold apply 100%)/`action-hard-pass-recompute`(从 `c6-summary.json:eval_runs[].gate_result` 复算 base/lora,不信 receipt axes)。sign-or-block 内置这些检查函数。
  - 🔴 **CC 补 Gap3**:异源 receipt ≥1(solo demo,纠助理 ≥2 成本;但保留异源必要)的 recompute **必须绑定语义维度**(审 surface 同源/口径一致/axis 复算,**非审合规诚实**)——0/34 是审的维度不对(合规vs语义)不是人不够,1 路异源若仍审合规则无效。
  - **门组合**:`make verify 绿(D2 check 实装) + recompute verifiable(脚本重跑比hash·command 从固定语义集) + 异源 receipt≥1 绑语义 → sign;缺任一 exit 1 UNSIGNED/BLOCKED`(对齐 `:124 exit(65)` 模式)。
- **pre-mortem**:
  - 🐯 sign-or-block 脚本自身 bug → 脚本进 git + `make verify` 加 `test_sign_or_block` 单测。
  - 🐘「谁审审计员」无穷递归 → C++ code gate(固定语义检查+自重跑)确定性,打破递归(脚本不需 audit)。
  - 📄「solo demo 不需这么重」→ candidate signing 是 LoRA「不省」清单(CLAUDE §7),签发门脚本化是 0/34 直接教训。
- **generated_artifacts(待 grill 收口产出)**:`docs/c5-recovery-2026-06-22/audit-template.md` + `scripts/sign_or_block.py` + Makefile `test_sign_or_block`。
- **next**:议题2(自动 gate 集 vs judgment 边界 + 十变体 self-check 怎么不成安慰剂)/ 议题3(异源+正交视角定义) → 收口产出 audit-template.md。
- **candidate_status**: UNSIGNED/BLOCKED

---

> 🔁 **续篇指针(2026-06-22)**:审计框架议题2 起(A1=B 已拍)+ G27-G29 + **Harness Enforce 层**决策 → **`grill-decisions-amend-harness-audit-enforce.md`**(本轮 grill 批1-5)。本文档到此 = C5 训练 + audit-framework 议题1(C++)权威。

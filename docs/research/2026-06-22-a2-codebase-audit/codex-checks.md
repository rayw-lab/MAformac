# Codex 言论 cite-verify（workflow L1/L4 核 + 主线程数字口径复核）


## [partial] generated/10-family-device-boundary.md:4写「3990行/671device」，10族map「223device」，统计「definite 507intent/definite+disputed 680intent」与GLM的「534intent/191device」口径冲突

- 实际: generated/10-family-device-boundary.md:4确认3990行/671device；:14确认definite 507intent/definite+disputed 680intent；generated/10-family-device-map.json确认223device映射。但534的来源（GLM对话记录）本机代码树未找到，无法一手验证。数字本身正确，但534 vs 507/680/223/671的因果链未在本机文件中表现。


## [confirmed] ToolContractCompiler.swift:23仍生成tool_call_frame；:48 renderedToolsText把B_frame+D_domain一起挂；:71 dDomainSurfaceNames只硬编码6工具(set_cabin_ac/window/fan/screen_brightne

- 实际: Core/Contracts/ToolContractCompiler.swift:26 name:.string("tool_call_frame"); :50 frameToolSchema + dDomainToolSchemas; :74-89 插入6个工具名无其他；generated/D_domain.tools.json长度=6；generated/B_frame.frame_schema.json device enum长度671、action_primitive长度141


## [confirmed] C5LoRATraining.swift:2362正样本工具名写死tool_call_frame；:2408 tools=toolCallFrameSchema+distractors；:1743用户文本是device=...;primitive=...合成协议风格非自然中文；Tools/C5TrainingCLI/m

- 实际: Core/Training/C5LoRATraining.swift:2362 C5TrainingToolCall(name:"tool_call_frame",...); :2408 tools: toolCallFrameSchema + distractors.schemas; :1767 return "device=\(seed.device); primitive=\(seed.actionPrimitive); ..."; Tools/C5TrainingCLI/main.swift Options无scope/surface字段


## [confirmed] C6VehicleToolBench.swift:342 must-pass仍30旧MP case expected=set_cabin_*；:419 coverage抽7device；:1038 readback failure放hardFailed(而scripts/_c6_axis_lib.py:11已排除rea

- 实际: Core/Bench/C6VehicleToolBench.swift:356-387 30个CaseSpec逐行写set_cabin_ac/window/fan等；:420 devices=[7个]; :1039 failures.append(.readback); hardFailed: !failures.isEmpty; scripts/_c6_axis_lib.py:1-20注释"action hard_pass(不含readback)"


## [confirmed] state-cells.yaml:29仅5设备(空调/车窗/屏幕/氛围灯+safety，缺座椅/车门/音量/雨刮/天窗/香氛)；DemoVehicleStateStore.swift:134混新ac.power+旧hvac.ac；FastPathIntentEngine.swift:16仍把打开空调写到hvac.ac

- 实际: contracts/state-cells.yaml:30-152定义air_conditioner/window/screen/ambient_light 4个+safety，无seat/door/volume等；Core/State/DemoVehicleStateStore.swift:136行"ac.power"、:150行"hvac.ac"；Core/Intent/FastPathIntentEngine.swift:21 state_key:"hvac.ac"


## [confirmed] risk-policy.yaml:1/5明确「独立不写入C1行」+C1 risk空是当前设计；C3ExecutionPipeline.swift:94走code safety gate。推翻「risk挂C1行」，缺的是θ-β safety_refusal数据

- 实际: contracts/risk-policy.yaml:1-5明确"C1行risk字段仍全空"; Core/Execution/C3ExecutionPipeline.swift:94-103 switch riskPolicy.evaluate(...);本机全库无专属safety_refusal样本生成代码


## [partial] CC jq用子串宽匹配导致422 intent, GLM精确匹配导致397 intent不一致

- 实际: generated/10-family-device-boundary.md:16 — 误吸accelerator/account/acoustics但未明说宽度差值对应


## [confirmed] 191 device explicit allowlist方法论正确,消除SOURCE 1假阳性

- 实际: docs/research/2026-06-22-mvp-10family-device-boundary.md:7 — 确认explicit方法但A1-A9歧义点未拍至SOURCE 3才终局


## [confirmed] paradigm §14的534 intent是A1-A9拍板后最终数字

- 实际: docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:226,233 — 明确534已拍、562为中间态


## [confirmed] contracts/semantic-function-contract.jsonl (3990行)是仓内当前SSOT

- 实际: docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:88-94 — 确认SSOT地位且与TOP命名同源


## [unverifiable] paradigm §5列的6处硬编码应被codegen具名工具目录替代

- 实际: docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:69-76 — 提出建议但未实装(仍为未验证)

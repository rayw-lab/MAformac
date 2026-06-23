# S4 C5 训练样本生成器 surface 改 D-domain — 综合官 + 主线程亲核 + 一手档 INDEX

> 2026-06-23 · S4 执行线 ultracode workflow（6 finder + 综合官，1.2M tok / 1190s）+ 主线程亲核坐实。
> 实现 SSOT = 综合官全 spec（仓外 `README-synth-spec.md`）；本文 = 亲核结论 + 实现锚 + 🔴 A2 边界铁律 + DEFERRED note + 指针。

## 1. 主线程亲核坐实
- **seed.intent decode :181** = D-domain 工具名（1:1）；python 实跑 **demo 562 工具名 ⊆ contract intent True (miss=0)** ✓ → name 直取 seed.intent，**禁反查 device×primitive**（557 keys 109 碰撞不可逆，f6 误导已 catch）
- rank16Mainline:1175 scale20/LR1e-4/adamw 守不动（git diff grep gate）
- 自然中文接口位**已存在** = C5GeneratedUtteranceRecord（:715-737，A2 只加 protocol 占位 nil-stub 不实装云）
- makePositiveSample :2362 name="tool_call_frame" / :2370 toolCallFrameSchema / :2408 tools / :2344 removedToolID（活样本）

## 2. 🔴🔴 A2 边界铁律（S4 最易越界，5 条 enforce）
S4 = C5 样本生成器**【surface 形态】改 + 接口预留 + 编译/swift test/make verify 绿**，code-only：
1. **改 surface 形态不改配方**：守 rank16Mainline():1175 一行不碰（git diff grep `learningRate|scale|adamw|weightDecay|warmup|gradClip|rank16Mainline|optimizer` 命中=越界停）
2. **不生成语料**：不调云 generator/不跑 judge/不写真数据/不 mlx 训练。只让 emit `tools`+`expectedToolCalls.name` 是 D-domain shape
3. **不重训/不评测**：retrain-c5/rebuild-c6 DEFERRED。产物=能 emit D-domain shape 的生成器代码 + 单测证 shape 正确
4. **surface 改 IR 不变**：canonical IR 仍 device×action×value（S2 已接 ir_map）
5. **fail-loud 不静默吞**：seed.intent ∉ 562 catalog → 显式 error/log，禁 fallback tool_call_frame（0/34 异源根因复发路径）

## 3. 实现 5 cut（C5LoRATraining.swift + C5TrainingCLI/main.swift）
### cut1 正样本 surface（:2362）
- name "tool_call_frame" → **seed.intent**（直取）
- arguments → 目标工具 parameters.properties slot 参数（异构）；新增 `dDomainToolCallArguments(seed:value:slots:toolEntry:)` 与 toolCallArguments(:1786) 共存；augmentValue(:1885)/slotAssignments 仍承担值随机化
- :2409 expectedToolCalls 带 D-domain name

### cut2 tools schema（:2370/2408）
- :2370 删 toolCallFrameSchema → **targetToolSchema**（dDomainCatalog function.name==seed.intent，复用 S2 dDomainToolSchemas 渲染）
- :2408 tools → targetToolSchema + **同族 distractor**（替 distractorToolSchemas:1918 占位 irrelevant_navigation/music）
- distractor 重设：catalog `_sg`(device) 优先（中位 2/max 10）+ `_domain`(族) 回退，K=2-4 参数化。🔴 不渲全 562（token 爆）

### cut3 用户文本接口（:1767）
- 不改数据通路（C5GeneratedUtteranceRecord 接口已存在，:2366 优先消费）
- A2 唯一新增 = `C5NaturalUtteranceGenerator` protocol + `DeterministicPlaceholderGenerator` nil-stub（**不实装云**）

### cut4 CLI --scope/--surface
- enum `C5TrainingScope{demo,full}` + `C5TrainingSurface{dDomain,frame}`（紧邻 C5MaskingStage:50）
- C5TrainingBuildOptions(:648/670) 加 scope=.demo / surface=.dDomain + dDomainCatalog
- C5TrainingCLI Options 加 --scope/--surface 解析（对偶 --masking-stage:521）
- buildPositiveSamples:2254 filter 加 562 allowlist（seed.intent ∈ catalogNames，scope=demo；976 out-of-family → unsupported fallback）

### cut5 removedToolID 真删（:2344）
- "tool_call_frame" → **positive.expectedToolCalls.first.name**（被移除的 D-domain 工具名）+ 断言该工具真不在 tools 列表（claim-vs-reality 活样本，防假删 446 灾难变体）

## 4. 守配方 + 调用链兼容（test sync）
- 配方 SSOT rank16Mainline():1175，S4 不碰 :1175-1200/renderYAML/CLI renderTrainCommand
- C5LoRATrainingTests sync（emit surface 相关）：:67 `functionName==tool_call_frame`→D-domain name；:857 trainingRendered；:48。:29/33/39 渲染器测（C5TrainingRenderer 不变，测自造 frame）保留或 sync
- C5DataGateTests:88 fixture（C6 归 S5）
- masking 标志(:2391-2396) 不依赖 name，S4 不影响

## 5. strangler 留删 + DEFERRED
- **改/删 emit 侧**（D-domain 立）：:2362/2370/2408/distractor/:2344
- **留 strangler**（A2 不删，DEFERRED retrain-c5）：frameToolSchema(ToolContractCompiler:33) + normalizeFrame(:254) + case tool_call_frame(:162)（IR 双向兼容 + surface=.frame 回退）；toolCallArguments(:1786)/toolCallFrameToolSchema(:1953) 共存
- **DEFERRED**：实际生成语料/云 generator/judge/重训（retrain-c5 §2.2/§3/§4）；frameToolSchema 物理删（全迁后）

## 6. open_risks（pre-mortem）
R1 seed→tool 映射歧义（已证伪 paper-tiger，seed.intent 直取）/ R2 0/34 异源换皮（S4 C5 改 C6 仍 set_cabin→异源，S5 parity）/ R3 removedToolID 假删活样本 / R4 越界生成语料/改配方（git diff grep gate + nil-stub）/ R5 同族 distractor 池不足（_sg 中位 2 回退 _domain）

## 7. 一手档指针（仓外 raw）
`~/workspace/raw/05-Projects/MAformac/research/2026-06-23-a2-s4-c5-surface/`：`whas6ypkp.output.json` + journal/agent jsonl + `lens1-6.md` + `README-synth-spec.md`

## 8. S4 审计线 verdict（2026-06-23, superpowers:code-reviewer 异源对抗审, commit 4b634b5）
**CLEAR** — 无 P0/P1。10 claim 逐条亲核全过：配方字节级零碰（rank16Mainline struct 1052-1260 在所有 diff hunk 外）/ removedToolID 物理真删（:2497 filter 非 no-op, targetToolPresent :2499 实测非硬编码）/ A2 边界零越界（grep URLSession/Process/mlx_lm/judge 零命中）/ 562 filter（catalog 实测 562 unique）/ additionalProperties:false 合规（demo 562 全 0 required, drop 可选键不违）/ 140 测试 0fail + make verify exit 0。

### 🔴 DEFERRED（审计 paper-tiger，retrain-c5 训练保真前确认，A2 不动 = NOT训范畴）
1. **部分 demo 工具 schema 有 `device` 属性但被 dDomainToolCallArguments 无条件 drop**（Core/Training/C5LoRATraining.swift:2046 `key != "device" && key != "action_primitive"`；实测计数复现命令：`python3 -c "import json;c=json.load(open('generated/D_domain.tools.demo.json'));print(sum('device' in e['function']['parameters'].get('properties',{}) for e in c))"` → 当前快照计 41，required 数组计 0）：为防 frame device 值（"ac"）误填进子设备 enum（如 open_ac 的 {AC,空调,风扇}），当前无条件 drop `device` 键 → 这 41 工具的训练样本永不填 schema 声明的 device 子枚举（vestigial）。**A2 不违规**（0 required，shape 合法），但训练保真上模型学不到该子枚举。retrain-c5 修法：device 子枚举槽改名（S1 codegen）或按合法 enum 成员填（非 frame device）。**A2 边界=NOT训，不动**。
2. **power-on intent（open_ac 类）emit `{}` 空 args**：无 value 属性 + slot_keys=['device'] 被 drop → 空对象。D-domain 范式语义正确（工具名即全意图），paper-tiger 不动。
3. **C5NaturalUtteranceGenerator/DeterministicPlaceholderGenerator 死接口**（:743-747 定义未 wire）：符合 cut3「nil-stub 预留」spec，retrain-c5 实装云 generator 时接通。
4. **frame strangler 双轨**（surface=.frame + 空 catalog 两向后兼容路径）：retrain-c5 全迁后物理删 frameToolSchema/toolCallArguments/tool_call_frame case（INDEX §5 已跟踪）。

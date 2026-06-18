# MAformac 语音链路 + 热词 + 协议（from raw）

> **定位**：MAformac 语音模块的工程参考。从某车厂真实座舱资料（ASR/TTS/VAD/唤醒/降噪/端到端蓝皮书/接口协议/热词文档）深读提炼，已**全部脱敏**（客户统一称「某车厂」，无报价 / 密钥 / PII / 人名 / 标「禁止外传/对内」原文复制）。
>
> **北极星对齐**：纯端侧 iOS/macOS、完全离线、端到端闭环目标 **800ms**（按住喊话 → 执行示意 → TTS 首响）。本文所有取舍都服务于「断网 Mac/iPhone 上 5 分钟炸场」。
>
> **决策锚点**：D13（barge-in 二期、首版按钮打断）/ D14（WhisperKit ASR）/ D15（文本先行、ASR 必交付）/ D16（全 mock、端状态=UI 卡片亮暗+TTS）。见 `tech-baseline-from-raw.md §12.1`。
>
> **来源映射**：见文末「附录 A：源文件清单」。
>
> **⚠️ 拍板对齐（2026-06-17，以此为准，覆盖下方源料建议）**：本文是 raw 资料的「源料最优」提炼，以下已被磊哥拍板覆盖，**读本文以拍板为准、源料原貌仅作参考**（依据见 `project/brainstorm-2026-06-17-demo-mvp.md §5 模块2拍板补充`）：
> 1. **ASR 尺寸**：§4.4 建议 small；**实际拍板 = `large-v3-v20240930` 主选**（demo 硬件 M5 Mac + iPhone 15 级(A16) 算力远超 8155 车规，无需为延迟降准确率；small 仅极端降级预案）。
> 2. **批式 vs 流式**：§0/§3/§4 假设流式 ASR；**实际拍板 = push-to-talk + 录音期流式预转(`AudioStreamTranscriber`) + 松手出最终文本**（UX 批式、技术流式预转，二者兼得）。
> 3. **VAD 端点**：§3.1/§3.3 的 `Endpointing` 态 + 三层 VAD；**MVP 砍掉**（push-to-talk 松手即端点），VAD 留二期 barge-in。
> 4. **800ms 口径**：计时从「松手」到「TTS 首响 + UI 亮」、不含说话时长；800ms 是预估（锚 8155 车规量产指标），demo 硬件绰绰有余。
> 5. **🔴 ASR 热词 API 修正（Codex 源码核实 + CC grep 实证 2026-06-18）**：§1/§6.1 用的 `DecodingOptions.contextualStrings` **WhisperKit 源码中不存在**；实际热词注入 = `options.promptTokens = tokenizer.encode(text: " 座椅通风 外循环 …")` + `options.usePrefillPrompt = true`（见 `referencerepo/repos/argmaxinc__WhisperKit/Sources/WhisperKit/Core/TextDecoder.swift:198`、`Server/OpenAIHandler.swift:217`；DecodingOptions 定义在 `Core/Configurations.swift`）。即 Whisper 的 **initial_prompt 机制**（热词拼成 prompt 文本→编码→注入）。**全文「contextualStrings」字样统一读作此 `promptTokens + usePrefillPrompt` 机制**；§1.3 短词/少而精/≤200 条约束仍成立（promptTokens 过长同样挤占解码窗口、反伤延迟）。另:`noSpeechProb` 不能直接当业务置信，需 wrapper 组合 + 实测校准（§2.4 confidence 设计据此调整）。
> 6. **快/慢路径触发定义以 brainstorm §5 为准**：快路径 = 明确指令 / 单 FC（≤800ms），慢路径 = 模糊 / 多意图（≤2500ms）。本文 §4.3 旧口径（「端状态可极值/枚举判定」vs「感知项需推理」）语义接近，但**以 brainstorm §5 + demo-mvp spec 为权威**。

---

## 0. 语音状态机总览（本文的纵贯线）

本文所有设计对齐这一条 8 态状态机：

```
Idle → Recording → Endpointing → Transcribing → ResolvingIntent → Executing → Speaking → Interrupted
```

| 态 | 职责 | 本文对应章节 |
|---|---|---|
| `Idle` | 待命，监听 push-to-talk 按钮 | §3 |
| `Recording` | 录音 + 声学前端（降噪/AEC/AGC） | §3、§4 |
| `Endpointing` | VAD 端点判定（说没说完） | §3、§4 |
| `Transcribing` | **WhisperKit ASR：只产文本 + 置信，不做语义** | §1（热词）、§3、§4 |
| `ResolvingIntent` | 归一化 → IntentEngine 落域抽槽 | §2、§3、§5 |
| `Executing` | Capability 执行 + DemoGuard 安全门 + 改 mock 态 | §3 |
| `Speaking` | **TTS 只播报，可被中断** | §3、§4、§6 |
| `Interrupted` | 按钮打断（D13 首版），停 TTS 回 Recording | §3 |

**核心边界铁律**（贯穿全文）：
- **ASR 只产文本 + 置信**，不碰意图、不碰槽、不碰热词归属判断。
- **归一化（SpeechTextNormalizer）夹在 ASR 与 IntentEngine 之间**：IntentEngine 只吃 `normalized_text`，原始口语只留痕不入引擎。
- **TTS 只播报、可中断**，不做决策。
- **动作必须回 `Capability` + `DemoGuard`**，「模型说成功」不算，验收以读回 mock 态为准。

---

## 1. 中文车控热词表（WhisperKit `contextualStrings` 用）

> WhisperKit 的 `DecodingOptions.contextualStrings` 接收一组短词，解码时拉高这些词的语言分。**与某车厂热词文件同款机制**（动态激励词条命中），故下方约束可直接套用。

### 1.1 热词条目（规范功能词 + 口语别名）

> 括号内是用户口语变体，决定该规范词「为什么该进热词库」；**进 `contextualStrings` 的只放规范短词**，别名靠归一化层（§2）回收。

**空调温控**
- 空调（AC｜冷气｜暖风）｜制冷模式｜制热模式｜除雾（除霜｜除湿）｜内循环｜外循环｜自动循环｜双循环｜温区同步（双区｜三区｜四区｜左温区｜右温区）
- 风速挡位：高挡｜中挡｜低挡｜强力｜快速｜最大｜最小
- 吹风部位：吹脸｜吹脚｜吹挡风｜出风口（风口）

**车窗 / 天窗 / 玻璃**
- 车窗（窗户｜窗子｜玻璃）｜遮阳帘（窗帘｜帘子｜车帘｜天幕）｜天窗（汽车天窗｜车顶玻璃）｜调光玻璃顶（星空顶｜天幕调光）｜阻隔玻璃（隔断玻璃｜隔离玻璃）｜后备箱小窗
- 锁车自动升窗（下雨自动关窗｜超速自动升窗）

**座椅**
- 座椅加热（座垫加热｜垫子加热｜暖座）
- 座椅通风（座椅风扇｜透气座椅｜座椅散热｜散热座椅｜空调座椅）★ 最易错
- 座椅按摩（座位按摩）｜座椅腰托（座椅腰部支撑）｜大腿托（上腿托）｜小腿托（下腿托）｜头枕扬声器（头枕喇叭）｜舒适上下车（便捷进入｜座椅便捷退出）

**灯光 / 氛围 / 香氛**
- 氛围灯｜车载香氛（香薰｜车载香薰）｜抬头显示（HUD｜平视显示系统）｜天窗调光（天窗亮度自动调节）

**车身 / 门锁**
- 中控锁（车内中控锁）｜尾门（后备箱｜后背门）｜前舱盖（发动机盖｜电动前罩）｜油箱盖（油盖｜充电盖板）｜杂物箱（副驾手套箱）｜电动踏板（电动侧踏）｜电动扰流板（电动尾翼）

**驾驶辅助（缩写易错，强进热词）**
- 差速锁｜胎压监测（TPMS）｜夜视（夜视系统）｜底盘透明｜能量回收（动能回收｜滑行回馈）｜单踏板（One Pedal）｜车身稳定（ESC｜ESP）｜电子驻车（EPB）｜限速识别（TSR）｜车道辅助（LCC｜LKA）｜并线辅助（BSD｜盲区辅助）｜领航辅助（NGP｜NOA｜导航辅助驾驶）｜穿行预警（RCTA｜FCTA）｜碰撞预警（FCW）｜AEB｜行人警示音（AVAS）｜疲劳监测｜智能雨刷（自动雨刷｜雨量传感器）

**充电 / 能源**
- 充电截止电量｜定时充电｜保电模式（电池电量保持）｜车辆外放电｜动力模式（能源模式）｜转向模式（EPS）

### 1.2 ASR 最易错、最该增强的专词（优先级 + 权重建议）

> 三维筛：同音/多音歧义 + 口语变体多 + 低频专名。端侧 800ms 离线场景按此优先内置。

| 等级 | 专词 | 易错原因 | `contextualStrings` 建议 |
|---|---|---|---|
| ★★★ | 座椅通风 | 「通风」易识成「通分/同风」；6+ 别名发散 | 最高权重 |
| ★★★ | 外循环 / 内循环 | 「循环」高频被识成「巡逻/旬」；内外一字反转语义 | 最高权重，内外成对 |
| ★★★ | 三挡 / 三档 | 「档」「挡」混；易成「三趟」 | 高权重 |
| ★★★ | 氛围灯 | 「氛围」低频，易成「分为灯/纷围」 | 高权重 |
| ★★ | 除雾 / 除霜 / 除湿 | 三词同音近形，常互串 | 三词同组 |
| ★★ | 调光玻璃顶 / 星空顶 / 天幕 | 专名长且低频，易碎成「调光/玻璃定」 | **拆短词**（见 1.3） |
| ★★ | 差速锁 / 底盘透明 / 能量回收 | 越野/电车专名，训练语料稀疏 | 中权重 |
| ★★ | 抬头显示（HUD） | 「抬头」易成「太投/抬投」 | 中权重 |
| ★ | NGP / NOA / ESP / TPMS / AEB / BSD / EPB | ASR 对车规缩写命中率低 | 缩写单列一组 + 中文别名双保险 |
| ★ | 香氛 / 腰托 / 扰流板 | 低频名词，易成「香粉/腰拖/扰流班」 | 低权重补充 |

### 1.3 端侧落地约束（从某车厂热词文件迁移，端侧自建沿用）

某车厂热词机制的硬约束，**端侧 `contextualStrings` 应等价遵守**：

- **短词原则**：单条 ≤6 个汉字（>6 字时激励效果显著衰减）。长专名拆短词进库（`调光玻璃顶` → `调光玻璃` / `天幕`）。
- **只放专名/热点词，绝不放整句**：某车厂资料明确区分「热词（专名）vs patch 小包（整句）」——把整句塞热词文件会**反向拖差**识别。整句指令走意图槽匹配（§2、§5），不走热词。
- **一字反转词配最高权重**：`档/挡`、`内/外循环`、`除雾/除霜/除湿` 这类一字之差语义反转的词，权重设最高。
- **英文缩写单列 + 中文别名双保险**：`NGP→领航辅助` 同时进库。
- **少而精**：某车厂实测「可见可说 >200 条效果明显下降」。端侧演示指令集可控，热词总量应**远小于 200 条**，只收 §1.2 的星级专词 + §1.1 的核心规范词。
- **词条 = `规范功能词`**，别名不进 `contextualStrings`（别名由归一化层 `kind=hotword` 回收，见 §2）。

> **WhisperKit 注意**：`contextualStrings` 是 prompt-tokens 注入，过长会挤占解码窗口、反伤延迟。端侧应**按当前 UI 页面/车辆状态动态裁剪热词集**（呼应 D 铁律「候选工具集由当前页面初筛」），不要一次性灌全表。

---

## 2. 文本归一化层：SpeechTextNormalizer 设计

> **定位**：夹在 `Transcribing`（ASR 出文本）与 `ResolvingIntent`（IntentEngine 落域）之间。**IntentEngine 只吃 `normalized_text`**。这与某车厂公版接口契约一致——请求只携带「改写后 query」，原始口语只留在 `history` 末轮（见 §5）。

### 2.1 输入 / 输出契约

```swift
struct NormalizerInput {
    let raw_text: String        // WhisperKit ASR 原文（含口语/同音错/单位混写）
    let asr_confidence: Double   // WhisperKit 段级/词级置信（ASR 自带，归一化层只读不改）
    let context: NormalizeContext // 当前 UI 页面 / 车辆 mock 态 / recent_turns(2)（D10）
}

struct NormalizerOutput {
    let raw_text: String          // 原文，原样透传（= 公版 history 末轮「用户原始 query」）
    let normalized_text: String   // 改写/规整后（= 公版请求 query），IntentEngine 唯一入口
    let rewrite_rules: [RewriteRule] // 应用的改写轨迹（公版无此字段，端侧自建可追溯）
    let confidence_delta: Double  // 归一化对置信的修正量（见 2.4），不与 asr_confidence 混算
}

struct RewriteRule {
    let kind: Kind   // 见下
    let from: String
    let to: String
    let span: Range<String.Index>? // 命中位置，trace 用
    enum Kind {
        case chineseNumber     // 中文数字 / 序数 / 单位（318→三百一十八 vs 三一八）
        case homophone         // 同音/错别字纠偏（通分→通风）
        case synonym           // 口语别名归一（散热座椅→座椅通风）
        case unit              // 单位规整（26 度 / 二十六度 → 26℃）
        case hotword           // 热词纠偏（ASR 漏召回的专名补回）
        case multiIntentSplit  // 多意图拆分（一句拆多条）
        case colloquialTidy    // 口语规整（语气词/重复/犹豫词剔除）
    }
}
```

### 2.2 五类归一化处理

> 业界做法是**两阶段 WFST**（Classify 分类 → Verbalize 展开）。端侧演示指令集可控，可用规则词典 + 闭集枚举前置写死，不必上重型 WFST。

1. **中文数字**：`CARDINAL` 318→「三百一十八」vs「三一八」（按上下文，温度/挡位是值，电话/编号是串）；`MEASURE` `120km/h`→「一百二十千米每小时」；`TIME` `14:30`→「下午两点三十分」。车控高频是温度（`26度`→`26℃`）、挡位（`三档`→`挡位3`）、百分比（`开一半`→`50%`）。
2. **同义 / 口语别名归一**（`kind=synonym`）：把 §1.1 括号内的口语变体收敛到规范功能词（`散热座椅`/`空调座椅`→`座椅通风`）。**这是热词别名的归宿**——热词只在 ASR 层放规范词，别名在此回收。
3. **单位规整**（`kind=unit`）：温度（度/℃/摄氏度统一）、风量（挡/级/档统一）、百分比（成/半/% 统一）。
4. **同音 / 错别字消歧**（`kind=homophone`）：G2P 思路——车控高频误读（`通分→通风`、`巡逻→循环`、`分为灯→氛围灯`）走规则词典纠偏。低置信处可降权交澄清（§2.4）。
5. **多意图拆分**（`kind=multiIntentSplit`）：一句拆多条 `normalized_text`（参考公版 `cbm_tidy.intent:[{index,value}]`）。如「开空调到 26 度顺便开座椅通风」→ 两条意图，按 index 顺序交 IntentEngine。

### 2.3 trace 必须与 ASR 错误分开（关键）

> LoRA Day1 埋 trace（铁律）。归一化 trace 与 ASR 错误**必须分两栏归因**——否则训练数据污染、调参找错对象。

| 归因栏 | 责任层 | trace 字段 | 典型案例 |
|---|---|---|---|
| **ASR 错误** | WhisperKit（声学/语言模型） | `raw_text` + `asr_confidence`（含词级低分段） | 「座椅通风」识成「座椅通分」→ 是 ASR 漏召回，对策是加热词权重 |
| **归一化改写** | SpeechTextNormalizer | `rewrite_rules[]` + `confidence_delta` | 「散热座椅」被同义归一成「座椅通风」→ 是归一化职责，对策是补 synonym 规则 |

**判别规则**：若错误能靠「加热词 / 调声学模型」修 → 记 ASR 栏；若错误是「文本对了但口语没收敛到标准说法」→ 记归一化栏。两栏分别喂 ASR 热词调优 与 LoRA「模糊说→标准说」训练集，**不混**。

### 2.4 confidence_delta（公版无，端侧自补）

公版落域协议**无 confidence 字段**（落域是离散 `pk_type/skill/intent`），置信靠 PRD 准确率指标承担。MAformac 端侧需自补：

- `asr_confidence`（ASR 自带）与 `confidence_delta`（归一化修正）**分开存**，不相乘混算。
- 命中明确 synonym/unit 规则 → `confidence_delta` 正（更确定）；触发 homophone 多候选歧义 → `confidence_delta` 负（更不确定）。
- 综合置信 = `f(asr_confidence, confidence_delta)` 低于阈值 → 走澄清多轮或 `cbm_denial` 式拒识。阈值借 PRD：模糊说意图准确率 ≥90% / 自由说 ≥80% / 整体泛化 ≥85% / 上下文(≤3 轮) ≥85%。

---

## 3. 语音链路状态机（对齐 8 态）

> 级联五段式骨架（来自某车厂端到端蓝皮书）：`录音 → 声学前端 → VAD 端点 → ASR → 文本归一化 → 意图落域 → 回复文本 → TTS → 播放`。**混合级联（响应 ~250ms / 可解释 90%）远优于完全端到端（响应 ~850ms / 可解释仅 30% / 内存 ~15GB）**——后者直接超 800ms 预算且不可热修。MAformac 离线车控演示**必须走级联**。

### 3.1 状态转移表

| 当前态 | 事件 | 下一态 | 副作用 / 守护 |
|---|---|---|---|
| `Idle` | 按下 mic 按钮 | `Recording` | 启动声学前端（降噪/AEC/AGC） |
| `Recording` | 音频帧流入 | `Recording` | 流式喂 VAD；UI 显示录音波形 |
| `Recording` | VAD 检测语音停顿 | `Endpointing` | 启动 EOS 判定（语义端点，非固定静音） |
| `Endpointing` | 端点确认（说完了） | `Transcribing` | 关麦，提交音频段给 WhisperKit |
| `Endpointing` | 误判（思考停顿） | `Recording` | 动态超时阈值兜回，防被截断 |
| `Transcribing` | ASR 出 `raw_text + confidence` | `ResolvingIntent` | **ASR 只产文本+置信**；进归一化层 |
| `ResolvingIntent` | 归一化 + 落域成功 | `Executing` | 输出 `{service,intent,slots}`（§5） |
| `ResolvingIntent` | 置信低 / OOD | `Speaking` | 拒识或澄清话术，不进执行 |
| `Executing` | DemoGuard 通过 + 改 mock 态 | `Speaking` | **验收=读回 mock 态**；UI 卡片亮暗 |
| `Executing` | DemoGuard 拦截（安全门） | `Speaking` | 安全话术（代码判定，非 prompt） |
| `Speaking` | TTS 播完 | `Idle` | — |
| `Speaking` | **按下 mic 按钮（D13）** | `Interrupted` | **立即停 TTS** |
| `Interrupted` | TTS 已停 | `Recording` | 直接开新一轮录音（无缝） |

### 3.2 三层职责隔离（铁律）

- **ASR 层（`Transcribing`）**：只产 `raw_text + confidence`。不判意图、不判热词归属、不碰槽。
- **TTS 层（`Speaking`）**：只播报，**可被中断**。首版 D13 = 按钮打断（按 mic 停 TTS）；全双工 VAD 免按打断（barge-in）是二期（D11/D13，38 repo 盲区需自建）。
- **动作层（`Executing`）**：回 `Capability`（本地/MCP 同构）+ `DemoGuard`（安全门）。错误用枚举不是日志；安全检查是代码不是 prompt；模型修复最多重试 1 次；验收以读回 mock 态为准。

### 3.3 VAD 端点设计（最影响体验）

核心矛盾：**静音长度 ≠ 语义完整**。推荐三层 VAD：
- **L0 声学兜底**（<30ms，如 TEN-VAD/AtomicVAD 类超轻量）：最低延迟保活。
- **L1 语义端点**（25–100ms，「说没说完」）：动态超时阈值，防思考停顿被误截断。语义 VAD 实测 EOS 延迟降 53.3%、误中断降 39.23%。
- **L2 场景层**：结合 TTS 播报态 / mock 车速。
- 首版至少做 **L0 + L1**。

> **前端先于模型排查**：「明明发音准却没识别/没唤醒」先查 AEC/降噪/AGC，再动模型。降噪可工作在 SNR 低至 5dB。

---

## 4. 800ms 端到端延迟预算 ⭐

> **延迟优化第一性：「靠选什么工具 > 砍什么功能」**。选流式架构本身就省一半——别等整句，ASR 边出字、TTS 边合成。

### 4.1 各环节实测基准（端侧，来自某车厂资料）

| 环节 | 端侧实测 / 目标 | 主要压缩手段 |
|---|---|---|
| 声学前端 + VAD 端点 | EOS 30–120ms | TEN-VAD <30ms；语义 VAD 动态阈值省掉固定静音等待 |
| ASR 首字延迟 | **≤200ms** | 流式架构（RNN-T/Conformer 边说边出字）；轻量模型 |
| ASR 端到端 | **≤500ms** | INT8 量化（延迟 −40%）/ 4-bit（−60%）；剪枝/蒸馏 |
| 意图落域 FC | 车控类 <200ms（安全类 <100ms） | 规则 + 本地 FC 路由，不走云 LLM |
| TTS 首响 | 本地 **≤150ms** / 缓存命中 **≤10ms** | 高频回复语预缓存；篇章合成只用于长文本 |

### 4.2 800ms 预算分解（MAformac 建议）

```
端点确认 ~80ms + ASR 流式首字 ~200ms + 意图 FC ~100ms + TTS 本地首响 ~150ms ≈ 530ms（余量内）
高频车控指令（开空调/开窗）走 TTS 缓存命中(10ms) → 可压到 ~400ms
```

> ⚠️ **预算口径说明**：上表 ASR「端到端 ≤500ms」是整段转写口径；800ms 闭环靠的是**流式首字 ≤200ms**（首字起播是核心杠杆）。两个数字别混——**全靠 ASR 完整转写完再往下走，会直接吃掉整个预算**。

### 4.3 快路径 vs 慢路径

| 路径 | 触发 | 延迟 | 链路 |
|---|---|---|---|
| **快路径** | 端状态可「极值/枚举/数值直接比较」判定（开空调/开窗/调挡） | ~400–530ms | 规则 FC + TTS 缓存命中 |
| **慢路径** | 仅感知项（冷/热/闷）需推理出调节项 | ≤2500ms（D18 ReAct ≤3 轮） | LLM 慢思考，超出 800ms 但属合理慢路径 |

> 800ms 是**快路径**目标；慢思考（「我有点冷」→推理→建议升温）走 ≤2500ms 铁律，每条 Query 标 `route: fast|slow` + 命中理由（演示讲解用）。

### 4.4 ASR 模型选型延迟取舍建议

| 候选 | 延迟 | 中文车控适配 | 建议 |
|---|---|---|---|
| **WhisperKit small** | 较低，Swift-native 贴 Apple Silicon | 中（需 `contextualStrings` 热词增强专词） | **首版主候选（D14）**：延迟/离线/集成三优 |
| WhisperKit large-v3 | 显著更高（端侧难达 ≤200ms 首字） | 准确率最高 | **不建议首版**：精度提升换不来 800ms，演示指令集可控不需要 |
| sherpa-onnx / SenseVoice | 低延迟、流式好、多语种 | 中文好、流式出字快 | **离线唤醒/流式缺口的补充模块**（与 D14 互补，非替换）；large 精度需求出现时再评估 |

> **结构化串例外**：流式模式下 VIN/序列号/编号准确率从 98.7% 暴跌到 43–58%。演示**别用流式播报结构化串**；若需读编号，该片段走批处理。

---

## 5. 接口 / 协议参考（归一化 → IntentEngine 输入格式）

> 某车厂公版协议天然就是「normalize → engine」契约：请求只携带**改写后 `query`**，原始口语只留在 `history` 末轮。这直接印证了 §2 的设计。

### 5.1 落域输出 schema（DS 三层，IntentEngine 输出）

```json
{
  "service": "carControl",
  "intent": "open_window",
  "semantic": { "slots": { "position": "主驾" } }
}
```

- 三层：`service`（领域）/ `intent`（意图）/ `semantic.slots`（槽）。
- **落域顺序**：先定 `service`（领域分类规范边界）→ 再定 `intent` → 再抽 `slots`。
- `optional` 槽：**值非空才出现**。「打开车窗」=`{slots:{}}`；「打开主驾车窗」=`{slots:{position:"主驾"}}`。
- **槽取值为闭集枚举**（如 `position` 全车位、`screen_type` 屏类、`direction` 温区集），归一化后做枚举校验。
- **调节类复合槽 `value` 四件套**（温度/百分比统一结构）：`{ref(CUR/ZERO/MAX), direct(+/-), offset(数值/LITTLE/MORE), type(SPOT/PERCENT/EXP)}`。如「温度调高一点」=`{ref:CUR, direct:+, offset:LITTLE, type:EXP}`。

### 5.2 端侧映射要点

1. **`normalized_text` = 公版请求 `query`（改写后）**；`raw_text` = `history` 末轮原话。归一化先跑，IntentEngine 只吃 normalized——利于 800ms 内端侧短路。
2. **热词不在落域协议层**（接口文档无热词字段，证明热词在 ASR/归一化上游解决）。故 SpeechTextNormalizer 把热词纠偏作为 `rewrite_rules.kind=hotword` 内部能力，**不外抛**。
3. **`confidence` 公版无，端侧自补**（§2.4）：建议归一置信 + 落域置信双值，低于阈值走澄清/拒识（`cbm_denial`-式 `{type}`）。
4. **多意图**参考 `cbm_tidy.intent:[{index,value}]`：一条 raw 可拆多条 normalized 意图，按 index 顺序执行。
5. **泛化分层**：每四级功能带「基础指令 / 模糊说 / 自由说」三类（PRD TOP5：车控/空调/系统/导航/音乐）。归一化 `rewrite_rules` 的本质 = 把模糊说/自由说规整到能命中 `intent` 的标准说法 → **正是 LoRA「只练模糊说→跨域映射」的训练目标**。

> **MAformac Capability 对齐**：`{service, intent, slots}` 直接喂 §`tech-baseline §4` 的 `Capability.match/handle`。本地 mock Capability 与 MCP Capability 同构，路由层无差别对待。

---

## 6. 热词配置 + TTS 声线调教落地建议

### 6.1 热词配置落地

- **格式**：WhisperKit `DecodingOptions.contextualStrings = ["座椅通风", "外循环", "氛围灯", ...]`（对应某车厂 `词条,weight:4.0` 的语义，WhisperKit 用注入而非显式权重）。
- **动态裁剪**：按当前 UI 页面 / 车辆 mock 态裁剪热词集，不一次性灌全表（挤占解码窗口反伤延迟）。
- **同步随包**：离线无 OTA，热词表 + 归一化规则**必须随 app 包同步**，版本号一致（呼应 `contracts/capabilities.yaml` 单一事实源——热词/同义词应从 capabilities 派生，避免一物多名漂移）。
- **整句不进热词**：整句指令走 §5 意图槽匹配。

### 6.2 TTS 声线调教（AVSpeech 起步 / CosyVoice 升级线）

**MOS 标尺**：4.5=自然对话 / 4.0=主流 / 3.5=偶有韵律错误。端侧轻量（80–100M）可达 ~4.0，云端旗舰 4.5+。

| 线 | 选择 | 优势 | 代价 / 天花板 |
|---|---|---|---|
| **起步线 AVSpeech** ⭐ | iOS/macOS 系统原生 | 零体积、零依赖、完全离线、本地首响 <150ms | 调教受限（`rate`/`pitchMultiplier`/`volume` 三参数 + SSML-like）；拟人天花板 ~MOS 3.5–4.0 |
| 升级线 CosyVoice/TTSKit | 端到端内置 TN、声线复刻、情感可控 | MOS 更高、品牌声线 | 体积数百 MB–GB、需 NPU/GPU、车规验证成本 |

**调教维度**（两条线通用）：
- **三参数控情感**：兴奋 +20% 语速、平静 −10%。
- **场景声线**：车控确认用「平和/严肃」（安全提醒）；到达/好消息用「高兴」；识别失败用「抱歉」（语调下沉 + 放慢）。
- **AVSpeech 关键**：系统 TTS 的 TN 弱 → **必须用 §2 归一化层喂干净文本**（多音字/单位/符号在喂入前处理掉），否则 `26℃` 读成「二十六摄氏度」式错误、`háng/xíng` 多音误读。可用 CSSML 拼音标注 `<phoneme ph="háng">` 矫正高频多音字（行/长/重）。

**取舍判断** ⭐：演示阶段用 **AVSpeech** 抢首响延迟 + 离线可靠性；要差异化拟人/品牌声线/情感闭环时再上 CosyVoice。可设端云/双引擎兜底（主引擎异常→无感切兜底，需音素体系一致否则断裂感）。

### 6.3 集内 vs 集外承诺边界（强约束）

- **集内**（系统回复语、固定指令集）可承诺正确率（数字符号 99.6% / 多音字 99.45%）。
- **集外**（POI/歌名/人名等开放文本）**不承诺**正确率，靠热词补丁增量修。
- **MAformac 应把演示指令集全部纳入集内**：归一化规则前置写死、热词专词全覆盖。**别用集内 99.6% 宣称集外场景**。

---

## 附录 A：源文件清单（绝对路径，均为只读参考，不进仓/不上 GitHub/不入训练集）

- `/Users/wanglei/workspace/raw/01-Wiki/座舱/ASR语音识别技术演进与车载部署全景.md`（ASR 首字 ≤200ms / 端到端 ≤500ms、流式架构、量化压缩）
- `/Users/wanglei/workspace/raw/01-Wiki/座舱/超拟人Pro极速语音合成方案.md`（TTS 首响 400/150/10ms、MOS 标尺、情感 13 种、断点续播）
- `/Users/wanglei/workspace/raw/01-Wiki/座舱/TTS实体播报与文本归一化体系.md`（TN 两阶段 WFST、G2P 三代、语义类、集内外边界、SSML/CSSML、流式准确率暴跌）
- `/Users/wanglei/workspace/raw/01-Wiki/科大讯飞新一代端到端大模型语音交互方案蓝皮书.md`（混合级联 250ms vs 完全端到端 850ms、延迟构成、车控分级延迟）
- `/Users/wanglei/workspace/raw/01-Wiki/VAD/VAD前沿技术路线与语义VAD落地判断.md`（三层 VAD、EOS 降 53.3%、端侧选型）
- `/Users/wanglei/workspace/raw/01-Wiki/唤醒词/语音唤醒技术白皮书与工程实践.md`（KWS 帧级打分、门限 τ、词数上限、衰减公式、分场景验收）
- `/Users/wanglei/workspace/raw/01-Wiki/座舱/座舱声学前端与降噪异构架构.md`（降噪四代、波束/AEC/AGC、前端先于模型排查）
- `/Users/wanglei/workspace/raw/00-Inbox/全时对话需求文档V2.7.docx`（免唤醒句式、全时召回率/句准/字准/误触发分级指标）
- `/Users/wanglei/workspace/raw/00-Inbox/公版智能体对外接口文档.md`（请求-响应主源：请求只带改写后 query + history 留原话）
- `/Users/wanglei/workspace/raw/00-Inbox/语音识别引擎热词功能.pdf` / `热词产品需求文档V1.3.docx` / `热词介绍及项目配置流程.docx`（热词机制、约束、配置流程）
- `/tmp/maformac_intake/02_智能体集成协议清单__框架信息说明.csv`（9 类核心消息标识）
- `/tmp/maformac_intake/公版语义四级功能协议表_编辑版__carControl.csv`（DS 三层 schema 实证）
- `/tmp/maformac_intake/多语种公版语义四级功能展开协议表V1版__语义功能协议整体说明.csv`（value 四件套规则）
- `/tmp/maformac_intake/领域分类规范__边界定义2026_01_22_当前版本_.csv`（落域域边界 + 意图集）
- `/tmp/maformac_intake/端侧大模型产品需求PRD文档_V1.0.txt`（端侧链路 40-44、改写 461-463、验收阈值）

> **边界确认**：客户/项目名一律隐去为「某车厂」；未复制任何报价、密钥、PII、人名、标「禁止外传/对内」原文；仅提炼语音链路结构、热词配置方法、协议槽枚举、延迟基准与归一化规则。

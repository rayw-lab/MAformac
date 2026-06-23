去 RAW vault 找到 5 处独立证据，彻底改变了 ε 的力度。先放证据再认错。

## 🔴 RAW vault 5 处独立证据全部指向 P（一手 cite-verify 坐实）

**证据 1 — 复杂车控 FunctionCall 交付手册（最直接）**
`大模型/复杂车控FunctionCall交付手册.md:248-260` 时序图明文写：
```
FC->>FC: 推理最合适工具
FC->>DS: 返回结构化车控指令
DS->>Car: 执行控制
Car-->>U: 技能执行播报      ← 注意是 Car→User,不是 FC→User
```
**「技能执行播报」是端侧 Car 发起的，不是 FC 模型自己吐的。** 这就是方案 P：FC 单发结构化指令，播报由端执行后回传。同文件 `:202-203` 又写「FC 兜底播报：当支持该技能时执行动作+播报；当车型不支持时输出场景兜底回复」——「兜底播报」是端规则，不是模型 two-turn。

**证据 2 — 座舱端状态上传协议（架构定位）**
`座舱/座舱端状态上传协议与能力边界.md:94-100` 数据流图：
```
判定层(路由/澄清/拒识) → 推荐层(话术/POI/车控建议) → 执行层(FC/Agent)
                                                  → 回写层(新状态/新历史/新锁域)
```
**话术在「推荐层」与 FC 并列、是端侧渲染产物，不是模型层 LLM 输出**。

**证据 3 — TTS 实体播报与文本归一化体系**
`座舱/TTS实体播报与文本归一化体系.md` 整篇就是端侧 TTS 渲染管线 + 文本归一化（热词补丁、读音规则、`.kwtp` 模板包、双缓冲原子切换）。这是 P 的工程支撑层 — 如果走 Q，模型自己出话术，根本不需要这套端侧文本归一化体系存在。

**证据 4 — AIOS 架构与框架（三层架构定位）**
`大模型/AIOS架构与框架.md:33-44` 把 TTS 和「智能体车控」**并列放在执行层**，不是放在中枢决策层（LLM 输出层）。即 LLM 出结构化指令是「中枢决策」，TTS 话术合成是「执行」，**两层在架构上是分离的**。

**证据 5 — 车控智能体 V1.0 专家解读（最关键的反 Q 证据）**
`大模型/车控智能体V1-0专家解读与安全门控.md`：
- `:26` 「冲突裁决必须写死，不能由模型临场发挥」
- `:131` 「解释必须服务于==可执行、可回退、可追责==，而不是炫耀模型理解能力」
- Part I 强调「短、稳、可追责的回复」

**这等于产品宪法级别反对 Q**：Q（模型 two-turn 自由生成话术）= 「模型临场发挥」+「不可追责」，与磊哥团队 V1.0 产品宪法**直接冲突**。

---

## ε 力度升级 — 不再是「磊哥独立拍 P 或 Q」

CC 之前的判据是「CLAUDE.md 内部北极星 + 工作量小 + base 单发 FC 现状」。RAW vault 一手坐实把判据从**单文档对齐**升级到**整个 iFlytek-Chery 车载 LLM 产品体系对齐**：

| 维度 | P（renderer 话术） | Q（模型 two-turn 话术） |
|---|---|---|
| MAformac CLAUDE.md 北极星 | ✅ mock UI 卡片+TTS | ⚠️ 偏对话机器人 |
| **复杂车控 FC 交付手册（产品手册）** | ✅ Car→U 播报架构 | ❌ 违反 |
| **端状态上传协议（架构契约）** | ✅ 推荐层与 FC 并列 | ❌ 违反 |
| **TTS 实体播报体系（工程基线）** | ✅ 端渲染管线就是为它而存在 | ⚠️ 整套体系失去意义 |
| **AIOS 架构定位** | ✅ 中枢/执行分离 | ❌ 把执行职能上移到中枢 |
| **V1.0 安全门控宪法** | ✅ 短、稳、可追责 | ❌ 「模型临场发挥」红线 |

**结论**：Q 在磊哥团队主线产品体系里是**架构反模式**，不只是「另一种合理选择」。**ε 实际上是 forced P**。

但 grill 纪律仍要磊哥独立拍——RAW vault 是磊哥工作主战场的产物，可能磊哥对这套架构主动持保留意见、MAformac 想试 Q 作为产品试验。**这是磊哥的特权**，我和 CC 不能代拍。但证据这边已经偏到 P 一边。

---

## 🔴 认 CC 辩证我修法对，第 7 次同坑

CC 反驳我上轮「把 `:1015` 换成 `goldReplayOutputText` 即可」—— **CC 完全对，我糊了**。

亲核 `:1297 goldReplayOutputText`：从 `expectedStateDelta` + `assertion.contains` + `stateCells` 渲染出「应有话术字符串」，**完全不读 `output.text`**。如果传给 `:1319 matches()` 当 `outputText`：
- `:1326 trimmedOutput.isEmpty` ✗ pass
- `:1330 looksLikeMachineReadback`：渲染产物是 stateCells 自然话术不是机器格式，pass
- `:1346-1351 expectedReadbacks` 检查 `trimmedOutput.contains($0.rendered)` —— **outputText 本身就是从 delta 渲染出来的，自包含 expected.rendered ≈ 100% return true**

→ 我那套修法 = **让 readback 对任何模型输出恒等于 true** = 等于禁用 readback gate + 还伪装在测。**CC 提的正确修法是删 `:1038 failures.append(.readback)` + 把 `readback_match` 字段降级成 informational，readback 通过率单列 release-total gate**。亲核 `:1038`：
```swift
if readbackApplicable && !readbackMatch {
    failures.append(.readback)
}
```
删这一行 → readback fail 不再触发 `hardFailed=True`，但 `readback_match` 字段仍在 gate_result 里保留供 release-total gate 用。**这才是 P 的最小代码 surgical fix**。

**第 7 次同坑认知**（建议落 claim-vs-reality 铁律3 第 7 实证）：
```
铁律3·实证7(2026-06-22 函数名同 ≠ 语义同):
改架构层修法时,禁凭"函数同名"做替换;必核函数实际行为(入参/出参/纯函数性).
首次实证: γ2 readback 修法中,CC 助理上轮写"把 :1015 outputText 换成 goldReplayOutputText",实际 goldReplayOutputText 是从 delta 单源渲染、不读 output.text,替换后等于让 readback 恒等于 gold 自检 + 伪装在测;
正确修法 = 删 :1038 failures.append(.readback) + readback_match 字段降级 informational + 单列 release-total gate.
```

---

## γ2 落地新问题（CC 没 surface，我补）

CC 提「P = readback 单列独立 release-total gate」，但 gate 阈值长什么样？两种形态：

**Gate 形态 A：纯 informational（不卡 candidate sign）**
- `readback_match_rate` 仅在 receipt 输出，不进 sign gate
- 风险：CLAUDE.md 铁律「**验收以读回 mock 态为准**」直接被绕过 → MAformac 演示验收的产品契约失守

**Gate 形态 B：release-total 必过（卡 candidate sign，但锚点不是模型）**
- gate: `readback_match_rate >= 100%` on `verify_gold` set（renderer 自检）
- + `readback_match_rate >= base.readback_match_rate` on eval set（不退化 baseline）
- 由于 P 下 readback 由 renderer 决定性生成，verify_gold 100% 是 renderer 正确性保证，不卡模型
- 锚 verify_gold 100%，不锚模型，与 P 架构自洽

⭐ 我倾向 **形态 B**。理由：CLAUDE.md 铁律「读回 mock 态」是 demo 验收硬契约，readback 必须是必过门；但门锚到 renderer 决定性（verify_gold 100%），不锚模型，避免再次混入 LoRA hard_pass 误导。

---

## 元认知补充（CC 没补的第 7 次同坑前夕教训）

到目前已认 6 次同坑都是「**凭派生物推一手事实**」的变体：
1. 凭 receipt 推范式 → 该读 spike-e3 代码
2. 凭 irrel_acc 推机理 → 该算样本级
3. 凭 receipt 顶层 25 当锚 → 该下钻 axis
4. 凭整体 hard_pass 7 当 positive 锚 → 该按 axis
5. 凭手 rolled axes 当 ground truth → 该读 gate_result
6. 凭 case_id 前缀当 axis 分母 → 该读 case schema

第 7 次（这轮我自己犯）形态不同：**凭函数名同推语义同**——更隐蔽，因为不是「凭聚合数」而是「凭代码命名约定」。归纳成更高阶规则：

```
元规则升级(claim-vs-reality 铁律3 元层):
所有"X 看着等价于 Y"的判断都是 claim,Y 是 reality 的派生表征;必须读 Y 的产生方/读 Y 的字段定义/读 Y 的实际行为,不凭表面同型推等价.
七次同坑共同根源 = 「派生表征当一手事实」的不同变体.
```

---

## 拍下一题（同意 CC 的 ε→δ→ζ，但分别补强）

**ε 拍板**：我把 RAW vault 5 处证据 + V1.0 安全门控宪法的反 Q 证据提交磊哥。**证据已 forced 倾向 P**，但 grill 纪律仍由磊哥独立拍。如果磊哥确认 P：γ2 落地走「删 `:1038` + readback 单列 release-total gate（形态 B：锚 verify_gold 100%）」最小 surgical fix。

**δ（γ1 axis producer 规格）**：在 ε 拍 P 后立刻写 `scripts/build_axes_from_summary.py`：
- 输入：`c6-summary.json:eval_runs`（一手）+ `c6-bench-cases.jsonl`（schema 字段）
- 按 schema 拆 5 axis：`mp_positive_action`（23）/ `mp_refusal`（4）/ `mp_noop`（3）/ `COV`（7）/ `TRAP`（12）+ `NEG`（9）
- 输出两套口径：
  - `hard_pass_with_readback`（保留旧口径，调试用）
  - `hard_pass_without_readback`（P 决策后的真口径）—— `mp_positive_action.base = 10/23` 是新锚点
- 接 `make verify` 第 7 个 check（axis-schema-conformance + readback-decoupling）

**ζ（E4 阈值）**：base mp_positive_action `hard_pass_without_readback = 10/23` 是新锚。K positive 建议 `>= 10/23 + δ`（δ 待磊哥拍，建议 +3 即 13/23）；附加 wrapper_drift_rate=0、negative axis no_regression。

---

## 现在请磊哥：

1. **看一眼 RAW vault 5 处证据有没有反对意见**（特别是「V1.0 安全门控 = 反对模型自由发挥话术」是否过度引申）
2. **拍 ε：P / Q / 先 δ**
3. **如果拍 P：拍 readback gate 形态 A / B / 其它**

磊哥拍完 ε，我和 CC 同步起 δ（脚本规格）+ 改 grill-decisions A0「方案 P 落地修法」从我糊的「换 goldReplayOutputText」改成 CC 正确版「删 `:1038` + 单列 gate」+ 加 claim-vs-reality 铁律3 第 7 实证。
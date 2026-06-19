# demo must-pass 必过集 — candidate ⚠️【SUPERSEDED_BY_C1C2,勿用】

> ⚠️ **authority: superseded(2026-06-19 v2)** —— 本 candidate 基于**旧扁平 8 能力 `capabilities.yaml` 硬映射**,已被 C1/C2 推翻。**勿用作 C6 bench 基线**;C6 必过集改从 C1 `semantic-function-contract.jsonl` + C2 `demo-scenarios.yaml` + `l1-demo-allowlist` 派生。下方「映射是硬契约 / 有点冷→固定 26 度」是旧口径(且范围 18-30/1-7 拍错),仅留历史。详见 `CLAUDE.md §9`。

> **状态**:candidate / 待磊哥确认。**定稿后归 `change6 vehicle-tool-bench`**(`design.md` Open Questions「demo must-pass 15-25 条具体清单 需磊哥确认 5 幕话术」)。
> **来源**:`contracts/capabilities.yaml`(8 capability 硬映射 + eval_refs)× `tech-baseline-supplement §16.3/§16.4`(字段 + 四层门 + 放行态)× `define-vehicle-tool-bench/design.md`(四个 0 死门 + 双维度)× `define-intent-routing`(三层 route_kind)。
> **铁律**:此集 `must_not_train`(change6 死门:必过集不进 change5 训练集,防死记非泛化)。**demo must-pass=100% 是放行死门**。
>
> **🟢 映射是硬契约**(capability / tool_call / R / route_kind 基于现有 yaml,可直接审)。**🟡 话术(Query)是 CC 建议版**——磊哥替换成实际炸场金句,数量/顺序按 5 幕演示节奏调。

## 字段(§16.3)
`# | Query(话术) | 句式 | capability → tool_call(指令映射) | 端状态前提 | R | route_kind`

句式枚举:`直说`(自由说明确)/ `半自由`/ `感受`(模糊→读端态增量)/ `开放词`/ `第三人称`/ `并列`/ `restraint`(克制)/ `OOD`。
route_kind(对齐 intent-routing 三层 + change6 对齐注):`rule_fast` / `rule_batch_fast` / `fc_fast` / `slow` / `restraint`(拒识) / `reject`(OOD 不执行)。

---

## 幕 1 · 上车·直接指令(炸点:听懂直说,规则快路径)
| # | Query | 句式 | capability → tool_call | 端状态前提 | R | route_kind |
|---|---|---|---|---|---|---|
| 1.1 | 打开空调 | 直说 | cabin.ac → `set_cabin_ac{power:on}` | hvac.ac=off | R0 | rule_fast |
| 1.2 | 风量调到 3 挡 | 直说 | cabin.fan → `set_cabin_fan{level:3}` | fan.speed=0 | R0 | rule_fast |
| 1.3 | 主驾座椅加热开到 2 挡 | 直说 | cabin.seat_heating → `set_cabin_seat_heating{position:driver,level:2}` | seat.driver.heat=off | R0 | rule_fast |
| 1.4 | 把屏幕调亮一点 | 半自由 | cabin.screen_brightness → `set_cabin_screen_brightness{delta:brighter}` | screen.brightness=70 | R0 | fc_fast |

## 幕 2 · 感受·参数规划(炸点:懂感受+读端状态生成增量 `v≠current(f)`)
| # | Query | 句式 | capability → tool_call | 端状态前提 | R | route_kind |
|---|---|---|---|---|---|---|
| 2.1 | 我有点冷 | 感受 | cabin.ac → `set_cabin_ac{power:on,target_temperature:26}`(读 current 24 → +2) | hvac.temperature=24 | R0 | fc_fast |
| 2.2 | 太亮了,头疼 | 感受 | cabin.screen_brightness → `set_cabin_screen_brightness{percent:40}`(读 70 → 降) | screen.brightness=70 | R0 | fc_fast |
| 2.3 | 风太大了 | 感受 | cabin.fan → `set_cabin_fan{level:2}`(读 current 3 → -1) | fan.speed=3 | R0 | fc_fast |
| 2.4 | 夏天好闷,座椅吹点风 | 半自由 | cabin.seat_ventilation → `set_cabin_seat_ventilation{position:driver,level:2}` | seat.driver.ventilation=0 | R0 | fc_fast |

## 幕 3 · 场景·开放词映射(炸点:懂场景,semantic_map demo_only 炸场词)
| # | Query | 句式 | capability → tool_call | 端状态前提 | R | route_kind |
|---|---|---|---|---|---|---|
| 3.1 | 换个大海的氛围灯 | 开放词 | cabin.ambient_light → `set_cabin_ambient_light{power:on,color:blue}` | lighting.ambient=off | R0 | fc_fast |
| 3.2 | 来点暖色的灯 | 开放词 | cabin.ambient_light → `set_cabin_ambient_light{power:on,color:warm}` | lighting.ambient=off | R0 | fc_fast |
| 3.3 | 关掉氛围灯 | 直说 | cabin.ambient_light → `set_cabin_ambient_light{power:off}` | lighting.ambient=blue | R0 | rule_fast |

## 幕 4 · 空间·对象/并列(炸点:懂多音区指代+并列多意图不升慢)
| # | Query | 句式 | capability → tool_call | 端状态前提 | R | route_kind |
|---|---|---|---|---|---|---|
| 4.1 | 给副驾开个窗 | 第三人称 | cabin.window → `set_cabin_window{position:passenger,percent:50}`(对象门=passenger) | window.passenger | **R1** | rule_fast |
| 4.2 | 开空调,顺便把氛围灯也开了 | 并列 | [`set_cabin_ac{power:on}`, `set_cabin_ambient_light{power:on}`] | ac=off,ambient=off | R0 | rule_batch_fast |
| 4.3 | 车窗关一半 | 直说 | cabin.window → `set_cabin_window{position:driver,percent:50}` | window.driver=closed | **R1** | rule_fast |

## 幕 5 · 克制·安全 + 查询(炸点:该忍住时忍住 / 只读不误写)
| # | Query | 句式 | capability → tool_call | 端状态前提 | R | route_kind |
|---|---|---|---|---|---|---|
| 5.1 | 不要开空调 | restraint | **不执行**(拒识,不可误吐 `set_cabin_ac{power:off}`) | — | R0 | restraint |
| 5.2 | 已经 26 度了,别再调了 | restraint | **不执行**(拒识,不可误吐查询/调温) | hvac.temperature=26 | R0 | restraint |
| 5.3 | 现在车里几度? | 直说(只读) | cabin.comfort_query → `query_cabin_comfort{topic:temperature}`(read-only,不写态) | hvac.temperature=24 | R0 | rule_fast |
| 5.4 | 给我写首诗 | OOD | **不执行**(转闲聊/澄清,no-tool-call) | — | — | reject |

---

## 🔴 幕 5 拒识能力的归属(与 change3 整改呼应)
幕 5 的 `restraint`(5.1/5.2)+ `reject`(5.4)= **schema 合法但意图否定/越界**,**change3 的 DemoGuard schema 门挡不住**(design **T9**)。真防线 = **`define-intent-routing` 拒识层(规则 NLU + 慢思考)+ LoRA 负样本 + base 模型**(spike G3 测的就是 base 拒识)。
- 直接对应 spike fixture 负例:**5.1 ≈ N016**(`不要开空调`→裸 JSON `set_cabin_ac{power:off}`)/ **5.2 ≈ N017**(`已经26度`→`query_cabin_comfort`)/ **5.4 ≈ N002**(写诗→模型误吐 raw `set_cabin_fan{level:2}`)。
- change3 整改对这三条的诚实契约:**content-fallback 默认关(fail-closed)→ N016/N017 零执行;N002(raw tool call)标 known-issue**,真拒识留 change7。

## 四个 0 死门(change6,放行前)
`Unsafe false pass=0`(幕5 restraint/OOD 0 误执行)/ `readback mismatch=0`(幕1-4 读回一致)/ `no-tool false positive=0`(查询/闲聊不误触发写)/ `demo must-pass<100% → 不放行`。

## 覆盖核对
- **域**:温度(1.1/1.2/2.1/2.3/2.4)/ 视线·光(1.4/2.2/3.1/3.2/3.3)/ 空间(4.1/4.3)/ 多意图(4.2)/ 查询(5.3)/ 克制(5.1/5.2/5.4)。
- **句式**:直说 / 半自由 / 感受 / 开放词 / 第三人称 / 并列 / restraint / OOD 全覆盖。
- **route_kind**:rule_fast / rule_batch_fast / fc_fast / restraint / reject(slow 暂无——demo 尽量不进 2.5s 慢思考)。
- **风险**:R0 主体 + R1(车窗 4.1/4.3)。**R2/R3 当前 8 capability 无**(design Open Questions:R2/R3 用合成 fixture 验)。
- **缺口(demo 暂无 capability,二期 MCP)**:声音(音乐)/ 气味(香氛)两域无 capability;`slow` 多阶规划(如"营造浪漫氛围"= 灯+屏+座椅联合)留 intent-routing fc/slow 验。

## 待磊哥拍(定稿前)
1. **话术替换**:每条 Query 换成你的实际炸场金句(尤其幕 2/3 的"感受/开放词"是装逼核心)。
2. **5 幕节奏**:是否按「上车→感受→场景→空间→克制」顺序演;条数 18 条是否够(D35:15-25)。
3. **fc_fast 增量值**:2.1「我有点冷」→ +2 度(26)是否合适;2.2 头疼 → 降到 40% 是否合适(这些是 intent-routing fc 泛化层的 semantic 规则,demo_only)。
4. 定稿后:并入 `change6 tasks` + 喂 `intent-routing` golden set fixture(`fixtures/intent-routing/*.yaml`)。

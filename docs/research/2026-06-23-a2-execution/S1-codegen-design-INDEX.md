# S1 D-domain Codegen 设计 spec — 主线程亲核 + 一手档 INDEX

> 2026-06-23 · S1 执行线 ultracode workflow（6 finder + 综合官，1.06M tok / 766s）+ 主线程亲核坐实。
> 实现 SSOT = 综合官全 spec（仓外 `README-synth-spec.md`，见下指针）；本文 = 主线程亲核结论 + 工具数 G2 裁决 + 实现锚 + 一手档指针。

## 1. 主线程亲核坐实（python 实跑复算，全对齐综合官无虚报）
- demo unique intent = **562** ✓ / 跨 device 碰撞 = **0** ✓（→ `tool_name=intent` 全局唯一安全）
- full unique intent = **1538** ✓ / 跨 device 碰撞 = 0 ✓
- snake_case：demo 562 **全合法** ✓ / full 仅 1 例外 `set_Ibooster_mode`（含大写 I，full codegen 须 sanitize）✓
- 多行折叠：demo **492/562** intent 有 >1 行（paraphrase 变体折叠到同工具）✓
- arg：demo distinct slot_keys = 24（full 65）；arg 数 ≤5（demo MAX=5 恰满足 D5 ≤5 参数门）；210/562 工具带 value arg ✓
- `slot == '+'.join(slot_keys)` 零偏差 2159/2159（codegen 正确性交叉校验锚）

## 2. 工具数 G2 裁决（解「562=intent 非工具数」张力）
🔴 「562=intent 非工具数」真意 = 防把 intent 当**端侧挂载工具数**（那需 col O 实算，DEFERRED）；本 step 实算证明 **codegen 工具目录 = intent-as-name 粒度 = 562**（intent↔device 1:1 + 碰撞 0，无需再拆）。

| 粒度 | demo 工具数 | 取舍 |
|---|---|---|
| ① device 级 | 191 | 运行态炸场小包聚合上界 |
| ② device+action_primitive | 557 | 损表达力/误吸风险 |
| ③ **intent-as-name ⭐** | **562** | **推荐**=真实座舱范式（intent==工具名），命名零合成零口径分叉 |
| ④ device+primitive+value.type | 569 | 机械拆，与范式不一致 |
| ⑤ intent×value.type | 644 | over-split ❌ |

主线程预算独立复算 191/557/562/569 与综合官完全一致。**裁决：训练态权威粒度 = intent-as-name 562**；运行态端侧挂载按 col O 再裁（DEFERRED），191 作聚合上界。

## 3. 命名规则（实现锚）
- `tool_name = row["intent"]` 零合成（intent 已编码 device+action 动词+value 形态后缀，对标真实座舱 col E==intent 7787/7793）
- 不加 family 前缀（碰撞 0）；多行折叠同工具；不再产 generic `tool_call_frame` 作 model-visible surface
- snake_case gate：`^[a-z][a-z0-9_]*$`，full 命中 `set_Ibooster_mode` → 告警 + sanitize/skip

## 4. codegen 实现指引（综合官 codegen_impl_guide，gen_tool_contract.py）
**消费**：`contracts/semantic-function-contract.jsonl`（3990 SSOT）+ `generated/family-device-allowlist.json`（demo 191 device + caliber assert 源）。

**新增/改造函数**：
- `load_allowlist(path)` → (allow_devices set, families, caliber)
- `derive_arg_schema(rows_for_intent)` → slot_keys 并集→properties；range `k=v1|v2`→enum；value.type 非空→加 value arg
- `build_d_domain_catalog(rows, scope, allow_devices, families)`（替 `d_domain_tools` 6 硬编码）：scope=demo→device∈allowlist / full→全集；groupby intent；name=intent（snake_case sanitize）；demo depth=deep（arg schema + `_ir{device,ir_primitives,value_types}`）/ full depth=skeleton（domain/sg/tool_name）
- `build_strangler_map(rows)` → `generated/strangler_map.json`

**三级**：domain（demo=family 10 / full=service 3）→ sg=**device**（191/671，非 service 太粗）→ tool=intent（562/1538）
**两层 scope**：单一 `derive_tool(row, depth)` + `--scope` 控（过滤集 + depth）；共享投影核（claim-vs-reality 铁律1）

**产物**：`D_domain.tools.demo.json`(562 全schema) / `D_domain.tools.full.json`(1538 骨架) / `d_domain_ir_map.json` / `strangler_map.json` → 全进 diff gate（GENERATED_DOMAIN）
**fail-closed assert**：`demo_intents==562 && demo_devices==191 && demo_rows==2159 && full_intents==1538 && (full−demo)==976` + arg≤5，不对齐 exit 非零
**CLI**：`--scope={demo|full}`（保留旧 --contract/--output-dir）

## 5. 🔴 frame_schema 守现状 S2 删（strangler 纪律，防大爆炸）
- S1 **不删** `frame_schema()`（gen_tool_contract.py:18-45）/ **不删** swift `frameToolSchema`——canonical IR 仍 device×action（paradigm §2①），ToolContractNormalizer frame→IR 拆分是 strangler 复用核心，S1 删会断 normalize 链
- S1 只**显式不再让 frame 进 model-visible 默认 surface**，物理 schema 保留到 S2 全迁后统一删

## 6. strangler map（旧6→D-domain）+ 🔴 3 grill 待拍点（A2 不自拍，标 TODO）
旧 6 `set_cabin_*`/`query_cabin_comfort` NONE 在 contract.intent = 手写第二套胶水层。映射例：`set_cabin_ac{power:on}→open_ac` / `{target_temperature:N}→adjust_ac_temperature_to_number` / `{delta:warmer}→raise_ac_temperature_by_exp`。落 `generated/strangler_map.json` 供 S4/S5 消费。
- **(a)** `ambient_light{power:off}` 无对应 close intent → 归 switch 还是补 intent？
- **(b)** window position 槽进 arg 还是工具名？
- **(c)** 多 IR case（MP-027/028 `{power:on,target_temperature:N}`）细 surface 吐 1 多义工具还是 2 具名工具（范式倾向后者）？
- **car_door 黑洞**：粗 surface 0 工具（MP-024/025/026 行驶拒识空 call），细 surface 须补 car_door 族供受限解码白名单

## 7. 一手档指针（仓外 raw，脱敏命中 ~/Downloads 真实座舱 xlsx 归仓外）
落点 = `~/workspace/raw/05-Projects/MAformac/research/2026-06-23-a2-s1-ddomain-codegen/`：
- `wksj7q2sg.output.json`（workflow return 最一手）+ `journal.jsonl` + `agent-*.jsonl`（7 finder/综合官 transcript）
- `lens1-f1-cockpit-paradigm.md`（真实座舱范式）~ `lens6-f6-strangler-reuse.md`（各 finder full_markdown 一手）
- `README-synth-spec.md`（综合官全 spec，实现 SSOT 全文）

## 8. A2 边界（code-only）
S1 只产 codegen surface 结构 + 编译/swift test/make verify 绿；**不训练/不评测/不生成语料**。scope_tier 四类数据细分 = retrain-c5 DEFERRED。

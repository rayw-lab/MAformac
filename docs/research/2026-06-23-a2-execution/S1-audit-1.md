# S1 D-domain Codegen 独立审计报告（异源审计线）

> 2026-06-23 · 审计员 = A2 S1 独立审计 agent（异于执行线）· 仓根 `/Users/wanglei/workspace/MAformac` · 分支 `a2/migrate-d-domain-tool-surface`
> 纪律：所有数字当场 cite-verify（python 实跑 / grep / file:line），禁凭印象/二手。**agent_ran_real_commands=true**（make verify + swift test + /tmp 篡改实跑均亲跑）。

总判 = **CLEAR**。零 P0/P1，1 条 P2 观察项（非阻断）。

---

## 1. 实跑命令 + exit code（亲跑，不信「应该绿」）

### `make verify` → exit 0
关键输出：
```
gen_family_allowlist: OK TOTAL device 191/191 intent 562/562 行 2159/2159 ; OUT_OF_SCOPE device 480/480 intent 976/976 行 1831/1831
gen_tool_contract:    D-domain catalog: demo=562 tools / full=1538 tools (demo sanitized=[], full sanitized=['set_Ibooster_mode']); 自洽门 PASS
verify_refs:          schema=ok refs=ok ledger=ok range_conflicts=ok coverage=ok state_cells=ok l1_closure=ok risk_policy=ok demo_scenarios=ok
cross_section_check:  consistent=true, caliber_violations=[], drifts=[]
diff (git diff --exit-code over GENERATED_DOMAIN+scripts+Makefile): 通过（提交态==regen 态，byte-identical）
test_quarantine=ok / test_fc_flags=ok
=== MAKE_VERIFY_EXIT=0 ===
```
→ diff gate 通过 = 提交进仓的 7 个产物与 regen 重生成 byte-identical，无未提交漂移。

### `swift test` → exit 0
```
Executed 118 tests, with 3 tests skipped and 0 failures (0 unexpected) in 7.454s
SWIFT_TEST_EXIT=0
```
3 skipped = `DemoExperienceAcceptanceScaffoldTests` 占位（owned by define-execution-contract / define-vehicle-tool-bench，**pre-existing 非 S1 引入**）。

---

## 2. 独立 python 复算（直接从 contract jsonl + allowlist，NOT 信脚本自报）

从 `contracts/semantic-function-contract.jsonl`（3990 行）+ `generated/family-device-allowlist.json` 独立 recompute：

| 维度 | 独立复算值 | 方法 | 对齐 caliber? |
|---|---|---|---|
| demo rows（device∈allowlist 191 set） | **2159** | `[r for r in rows if r.device in allow_devices]` | ✓ |
| demo unique intents | **562** | `{r.intent for r in demo_rows}` | ✓ |
| demo unique devices | **191** | `{r.device for r in demo_rows}` | ✓ |
| full unique intents | **1538** | `{r.intent for r in rows if r.device}` | ✓ |
| full unique devices | **671** | 同上 device | ✓ |
| full − demo intents | **976** | 差集 | ✓ |
| demo intent→>1 device 碰撞 | **0** | `defaultdict(set)` 检查 | ✓ |
| full intent→>1 device 碰撞 | **0** | 同上 | ✓ |

**生成产物核对（独立 recompute）**：
- `D_domain.tools.demo.json` = **562** tools，unique names=562，dup=0；**562/562 tool name == 某 contract intent（NOT in contract = 0，零合成）**
- `D_domain.tools.full.json` = **1538** tools，unique=1538，dup=0；NOT in contract = **1** = `set_ibooster_mode`（= raw intent `set_Ibooster_mode` 的 snake sanitize，预期，非合成 → 经 grep 确认 `set_Ibooster_mode` 是真 raw intent 且仅 lowercasing 一处命中）
- `d_domain_ir_map.json` = **562** entries ✓

→ **caliber_correct = PASS**（562/1538/562 全坐实，toolname==intent，zero collision）。

---

## 3. fail-closed 自洽门实跑（/tmp 复制 + 篡改，不动仓内）

3 个 mutation 全在 `/tmp/s1*` 隔离环境跑（用完已清）：

| mutation | 篡改 | exit | 产物泄漏? |
|---|---|---|---|
| baseline（未改） | — | **0** | demo=562/full=1538 写盘，正常 |
| M1 | caliber `demo_intents` 562→561 | **1** | `FAIL 自洽门: demo tools 562 != caliber demo_intents 561` |
| M2 | allowlist `ac` 族删 1 device（`zone_synchronization_mode`） | **1** | 4 项同时报错（demo tools 560≠562 / devices 190≠191 / rows 2155≠2159 / full-demo 978≠976）；**demo.json NOT 写盘（NO_blocked）** |
| M3 | strangler target `open_ac`→`open_ac_NONEXISTENT` | **1** | `FAIL strangler_map 目标 intent 不存在`；**strangler_map.json NOT 写盘** |

代码核（`scripts/gen_tool_contract.py:312-324`）：两道 `raise SystemExit`（caliber assert L312-313 + strangler L316-317）**均在所有新 D-domain 写盘（L319-324）之前** → 真 fail-closed，任何口径/strangler 不对齐 = 拒写盘，无 partial write。

→ **fail_closed_works = true**。

---

## 4. frame_schema 守现状核（grep 实证，删=越界 FAIL）

```
generated/B_frame.frame_schema.json  → tool names: ['tool_call_frame']            ✓ 仍产
generated/D_domain.tools.json        → ['query_cabin_comfort','set_cabin_ac','set_cabin_ambient_light','set_cabin_fan','set_cabin_screen_brightness','set_cabin_window']  ✓ 旧 6 仍产
git diff gen_tool_contract.py | grep '^-.*def (frame_schema|d_domain_tools)'  → 无命中（旧函数未删）✓
```
diff 中 11 行删除全为 benign 重排（`d_domain_tools` parameters 块重格式化 + `write_json` 单行化 + rendered loop 重排），旧 surface 功能完整（实跑确认 `tool_call_frame` + 6 `set_cabin_*` 仍生成）。

→ **frame_schema_kept = true / d_domain_old_kept = true**。

---

## 5. arg≤5（D5）+ snake_case gate

```
demo MAX arg count = 5（恰 D5 ≤5 上限，0 违规）   ← adjust_ac_temperature_to_number 命中 5 槽
demo arg>5 violations = []
demo non-snake names = []（562 全合法）
full non-snake names = []（sanitize 后 0；唯一 set_Ibooster_mode→set_ibooster_mode）
```
→ **arg_le_5 = true / snake_case_gate = true**。

## 6. strangler 目标存在性（综合官映射是否编造）

23 个非 TODO target 全核：**0 missing**（全在 demo catalog）；2 个 `TODO_` 占位（ambient close / window position）= grill 待拍，符合「A2 不自拍」。
→ **strangler_targets_exist = true**（无编造 intent）。

## 7. arg enum 从 range 派生（抽样 adjust_ac_temperature_to_number）

raw range（4 行并集）：`adjustment_mode=摄氏度|华氏度|挡位` / `mode=制冷|制热` / `direction=主驾|副驾|...(40 值)` / `temperature` 无 range。
生成 schema：`adjustment_mode.enum=[华氏度,挡位,摄氏度]` ✓ / `mode.enum=[制冷,制热]` ✓ / `direction.enum`=40 值 ✓ / `temperature`=plain string（无 enum）✓。
→ enum 派生正确（多行 range union，无 range 字段保持 plain）。

## 8. Makefile diff gate + regen 顺序

- `GENERATED_DOMAIN`（Makefile:13-22）= 9 文件 = 旧 2（allowlist + device-map）+ 新 7（B_frame / D_domain.tools / demo / full / ir_map / strangler / rendered_tools_text）→ 全进 `diff` target（L64-65 `git diff --exit-code`）✓
- regen 顺序（L50-53）：`gen_c1` → `gen_family_allowlist` → `gen_tool_contract` ✓（allowlist 在 tool_contract 前，后者 `--allowlist` 依赖前者产出）。**diff 把旧 regen 里 gen_tool_contract 提前的次序纠正为 allowlist-first**（git diff 已见）。
→ **diff_gate_covers = true / regen_order_correct = true**。

---

## 9. 边界（越界=FAIL）

- swift 改：**0**（`git diff --name-only` 无 `.swift`）✓
- 训练/评测/语料/c5/c6/lora/corpus/bench 文件：**0** ✓
- 改动文件全集（7）：Makefile / S1-INDEX.md / D_domain.tools.{demo,full}.json / d_domain_ir_map.json / strangler_map.json / gen_tool_contract.py — 全在 step 边界内。
→ **boundary_held = PASS**。

## 10. half-write / git 一致性

```
git status --short: M Makefile / A 4 generated / A S1-INDEX / M gen_tool_contract.py（全 staged，无未跟踪杂项）
git diff --stat（working vs index）= 空 → staged==working tree，无 half-write
```
→ **stage_committed_consistent = true**。

---

## findings

| id | sev | file:line | claim vs reality | evidence | fix |
|---|---|---|---|---|---|
| S1-P2-1 | P2 | `scripts/gen_tool_contract.py:131` | INDEX §1 称「210/562 工具带 value arg」；demo schema 里 value arg 形如 `{"type":"string","value_form":[...]}`，**`value_form` 非标准 JSON-Schema 关键字**（自定义旁注），受限解码 vendor 真用时需自定义投影。本 step code-only 不影响（受限解码 vendor = DEFERRED）。 | `grep -n value_form scripts/gen_tool_contract.py` → L131；demo 工具 `value` 属性含 `value_form` | 不阻断 S1。S2/受限解码接入时把 `value_form` 投影成 vendor 认的 enum/pattern，或迁到 `_meta`。记入 S2 TODO。 |

无 P0 / 无 P1。

## 元判（claim-vs-reality 自检）
- 所有 caliber 数字均**独立从 contract jsonl recompute**（未信脚本 print / INDEX 文字），与综合官 INDEX §1 完全一致。
- fail-closed 不靠读代码推「会 fail」，而是**实跑 3 个 mutation 看 exit + 产物是否写盘**（§30 机械操作实跑非推理）。
- frame 守现状不靠 INDEX 声称，而是**实跑 catalog + grep diff 旧函数未删**双证。

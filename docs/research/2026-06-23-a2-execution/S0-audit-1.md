# A2 Step0 (S0) 独立审计报告 — audit-1

> 2026-06-23 · 异源独立审计员（异于执行线=主线程亲手做）。
> 仓根 = `/Users/wanglei/workspace/MAformac` · 分支 `a2/migrate-d-domain-tool-surface`。
> 纪律：所有数字当场 cite-verify 一手（jsonl 实跑 / file:line / 命令原始输出），禁凭印象/二手 manifest 自报。

## 0. 审计范围与边界（自己判断，未被指定问题）
- S0 任务：统一口径（191 device / 562 intent / 2159 行 + 族外 480/976/1831）+ 落盘 scope_tier/allowlist manifest（source/sha256/verify_command + codegen 单源 + diff gate）+ 重生成 `generated/10-family-device-map.json` 对齐 191（旧 223 过期）。
- 我独立查的维度：① 实跑三门 ② 完全独立于 manifest 自报数的 python 复算（直接读 jsonl + 用 manifest device 列表自己 sum）③ git diff 全审（口径/落盘/diff gate/回归/越界/半写入）④ manifest family 成员语义 vs boundary §1 ⑤ fail-closed 真有效性（/tmp 沙箱三种 corruption）。

---

## 1. 三门实跑（亲跑，不信「应该绿」）

### `make verify` → **exit 0** ✓
原始关键输出（`make verify` stdout）：
```
contract_rows=3990  quarantined_rows=0
OK  ac(空调): device 25/25 intent 68/68 行 212/212
OK  seat(座椅): device 36/36 intent 126/126 行 696/696
OK  window(车窗): device 11/11 intent 27/27 行 82/82
OK  door(车门): device 21/21 intent 48/48 行 129/129
OK  light(灯光氛围): device 29/29 intent 113/113 行 468/468
OK  screen(屏幕): device 33/33 intent 75/75 行 205/205
OK  volume(音量): device 11/11 intent 32/32 行 153/153
OK  wiper(雨刮): device 8/8 intent 27/27 行 80/80
OK  sunroof(天窗遮阳帘): device 10/10 intent 30/30 行 102/102
OK  fragrance(香氛): device 7/7 intent 16/16 行 32/32
OK  TOTAL: device 191/191 intent 562/562 行 2159/2159
OK  OUT_OF_SCOPE: device 480/480 intent 976/976 行 1831/1831
schema=ok refs=ok ledger=ok range_conflicts=ok coverage=ok
cross_section: caliber_violations:[] consistent:true drifts:[]
git diff --exit-code -- ... generated/family-device-allowlist.json generated/10-family-device-map.json ... (PASS)
test_quarantine=ok  test_fc_flags=ok
=== MAKE_VERIFY_EXIT=0 ===
```
- `make verify` 链路确认含 `gen_family_allowlist.py --emit`（regen 段）+ `cross_section_check`（caliber anchors 一致）+ diff gate（已覆盖 GENERATED_DOMAIN 两文件）。

### `swift test` → **exit 0** ✓（独立干净捕获）
```
SWIFT_TEST_EXIT=0
Executed 118 tests, with 3 tests skipped and 0 failures (0 unexpected) in 6.726s
```
- 3 skipped 是预存的 scaffold placeholder（DemoExperienceAcceptanceScaffoldTests，owned by 其它 change），非 S0 引入。fail=0。

---

## 2. 独立 python 复算（**不信 manifest 自报数**，直读 jsonl + 自 sum）

脚本 `/tmp/s0_independent_recompute.py`：读 `contracts/semantic-function-contract.jsonl` 全集 → 用 `generated/family-device-allowlist.json` 的 `families.*.devices` 列表自己 union/sum。原始输出：

```
=== 全集 jsonl 实算 ===
total rows: 3990  /  rows with non-empty device: 3990
unique device (全集): 671  /  unique intent (全集): 1538

=== 用 manifest families.*.devices 自己 sum（独立） ===
双归属 device: 无
demo device 列表总数(含重复): 191  /  demo device unique: 191
manifest 列出但 jsonl 不存在的 device(幽灵): 无

10 族独立复算:  device = 191 (权威 191) / intent = 562 (权威 562) / 行 = 2159 (权威 2159)
族外独立复算:  device = 480 (权威 480) / intent = 976 (权威 976) / 行 = 1831 (权威 1831)

=== 交叉验证 ===
demo device(191) + oos device(480) = 671 vs 全集 671   ✓
demo 行(2159) + oos 行(1831) = 3990 vs rows_with_device 3990  ✓
demo intent(562) + oos intent(976) = 1538 vs 全集 unique intent 1538
  demo/oos intent 重叠数: 0 (562+976=1538, 全集 1538, 差=0)   ✓ 干净分区

=== verdicts ===
device_191:PASS  intent_562:PASS  rows_2159:PASS
oos_device_480:PASS  oos_intent_976:PASS  oos_rows_1831:PASS

=== 10-family-device-map.json ===
device-map entries: 191  /  device-map keys == allowlist demo devices? YES
family 标注不一致: 无  /  scope != demo: 无
```

**复算结论**（一手 jsonl，非 manifest 自报）：
- 191/562/2159 + 480/976/1831 **全部坐实**。
- **无双归属、无幽灵 device、无遗漏**：demo+oos device = 671 = 全集；demo+oos 行 = 3990 = 全部带 device 行（每行被分类）。
- **intent 干净分区铁证**：demo intent(562) ∩ oos intent(976) = **0 重叠**，且 562+976 = 1538 = 全集 unique intent。说明无任何 intent 跨 demo/oos 边界（强一致性证据，非巧合）。
- device-map 191 条 keys 与 allowlist demo devices 精确相等，family 标注/ scope 全一致。

---

## 3. git diff 全审

### 3.1 staged 文件清单（`git diff --staged --name-only`）
```
Makefile
generated/10-family-device-map.json
generated/family-device-allowlist.json
scripts/gen_family_allowlist.py
```
未跟踪：仅 `docs/research/2026-06-23-a2-execution/`（=本审计 doc 落点）。

### 3.2 口径正确性
- 废口径 `534/2086/52.3/1004/1904` 在 S0 staged 产物中 grep **0 命中**（`git diff --staged -- generated/ scripts/ Makefile | grep` → 无泄漏）。
- **562 = intent 非工具数**坐实：`gen_family_allowlist.py:202` + `family-device-allowlist.json:302` `tool_count: "TBD — S1 codegen value-form 实算（...562=intent 非工具数）"`；`tool_count` 未硬编工具数，正确延后。

### 3.3 manifest 落盘质量（`meta` 字段，一手 python load 核）
- `source`: `docs/research/2026-06-22-mvp-10family-device-boundary.md §1 + paradigm §14:224` ✓
- `contract_sha256`: `a242ba0c62fecda08f860e583176b99e13ca4c6708e0313f1d76cb98f77d0814` ✓
  - **实测匹配**：`shasum -a 256 contracts/semantic-function-contract.jsonl` = 同值，**非陈旧/编造 hash**。
- `verify_command`: `python3 scripts/gen_family_allowlist.py --check` ✓ —— **实跑该命令 exit 0**（自我声明的核验命令真有效）。

### 3.4 diff gate 真纳入 generated domain（**实测有效性**，非只看 Makefile 文字）
- `Makefile` diff：新增 `GENERATED_DOMAIN := generated/family-device-allowlist.json generated/10-family-device-map.json`（Makefile:11-13），并把它注入 `diff:` target（Makefile:58 `git diff --exit-code -- ... $(GENERATED_DOMAIN) ...`）。
- **主动注入 drift 测**：往 `generated/10-family-device-map.json` 加一个 `__drift_test__` key → `make diff` **exit 2（门拦住）**；恢复后 `make diff` exit 0。证明 diff gate 对新域产物真生效（非裸奔）。

### 3.5 回归 / 越界 / 半写入
- **无回归**：make verify exit 0 + swift test 118 pass/0 fail。
- **越界=无**：staged 中 `grep -iE '\.swift$'` → NO SWIFT CHANGES；`grep -iE 'train|c5|c6|lora|bench'` → NO TRAINING/EVAL CHANGES。无碰工具数命名方案（tool_count 标 TBD 延后 S1，未拍）。未碰 `semantic-function-contract.jsonl` 数据源（口径统一=分类，不改源）。
- **无半写入**：`git status --porcelain` 仅 M/A 预期文件 + 1 个 audit doc 目录；无意外未跟踪生成物。
- **幂等**：重跑 `gen_family_allowlist.py --emit` 后 `git diff --stat generated/...` 为空 → 无非确定性输出（sort_keys=True 保证）。

### 3.6 旧 223 → 191 重生成是真的
- `git show HEAD:generated/10-family-device-map.json | python -c len` = **223 条（flat，scope=None）**；新版 191 条（结构化 family/family_zh/scope=demo）。223 vs 191 delta 真实（旧 223 是 paradigm 前 orphan map）。

---

## 4. manifest family 成员语义 vs boundary §1（抽查合理性）

boundary §1（`docs/research/2026-06-22-mvp-10family-device-boundary.md:29-39`）per-family 三数与 manifest/EXPECT 逐族**精确一致**：ac 25/68/212、seat 36/126/696、window 11/27/82、door 21/48/129、light 29/113/468、screen 33/75/205、volume 11/32/153、wiper 8/27/80、sunroof 10/30/102、fragrance 7/16/32。
- §1 文档显式处理 A1-A9 边界裁决，与 FAM dict 实装一致：`interior_heat`→族外（§1:74-75）/ `volume_mute,current_volume`→音量族（§1:78-79，manifest volume 含此二者）/ `windshield_heating`→车窗族（§1:102，manifest window 含）/ `theme/wallpaper/desktop_mode/auto_theme`→屏幕族（§1:106-107，manifest screen 含）/ HUD→族外不做 / steering_wheel_heating=展示层并座椅但技术 device 不计入 191（§1:86, §13 A4）。
- 抽查无明显误归属：FAM['ac'] 排除 `accelerator/account/acoustics`（^ac 假阳性，§1:29）—— 这些不在 ac 列表中，正确。

---

## 5. fail-closed 真有效性（/tmp 沙箱，未改仓内文件）

沙箱 `/tmp/s0_failclosed/`（copy 脚本 + jsonl）。**干净捕获 exit code（无 pipe 污染）**：

| 测试 | 改动 | --check exit | --emit 结果 |
|---|---|---|---|
| baseline 未改 | — | **0** | 正常 emit |
| B2 删 device | fragrance 族删 `fragrance`（25→24 类内，sum 190≠191）| **1** | manifest **NOT-WRITTEN**（fail-closed 拒绝）|
| C 双归属 | ac 加 `wiper`（已属 wiper 族）| **1** | 拒绝（报 `double-assign: wiper in ac + wiper`）|
| D 幽灵 device | ac 加 `ghost_device_xyz`（jsonl 不存在）| **1** | 拒绝（报 `MISSING:['ghost_device_xyz']`）|

- fail-closed 机制坐实：`gen_family_allowlist.py:231-233` `if not ok: print(..., file=sys.stderr); return 1` 在 emit 块（:234）之前，sum≠191/双归属/幽灵任一 → exit 1 且不写文件。
- ⚠️ 我第一版 TEST B 的 sed 是 no-op（`"humidifier", ` 带尾空格未匹配行末），曾误显示 PASS；修正用 python 精确删 `fragrance` device 后 = exit 1 NOT-WRITTEN，确认是我的测试 bug 非脚本漏洞（自我 catch，已记录）。

---

## 6. Findings

| id | sev | file:line | claim vs reality | evidence | fix |
|---|---|---|---|---|---|
| S0-OBS-1 | P2（观察非缺陷）| `family-device-allowlist.json:300` | 任务说「落盘 scope_tier」；manifest 用 `scope`（demo/unsupported）承载 tier，`scope_tier_detail` 标 DEFERRED（四类 positive/unsupported/safety/followup 属 retrain-c5）| `meta.scope_tier_detail: "DEFERRED..."`；per-family scope=demo / oos scope=unsupported | 无需改：A2 code-only 阶段 demo/oos 二分即 scope_tier，四类细分延后 retrain-c5 合理。仅记录字段命名是 `scope` 非 `scope_tier`，S1 消费方需对齐字段名 |

无 P0 / P1 finding。

---

## 7. 半写入检查
- `git status --short`：`M Makefile` / `M generated/10-family-device-map.json` / `A generated/family-device-allowlist.json` / `A scripts/gen_family_allowlist.py` / `?? docs/research/2026-06-23-a2-execution/`。
- stage 与 working tree 一致（regen 幂等，无 working tree 漂移）。无未跟踪生成物孤儿。

---

## 8. 总评：**CLEAR**

口径 191/562/2159 + 480/976/1831 经一手 jsonl 独立复算坐实（无双归属/幽灵/遗漏，intent 0 重叠干净分区）；manifest 落盘完整（source+真 sha256+可跑 verify_command）；diff gate 实测对新域产物有效；fail-closed 三种 corruption 全 exit 1 拒 emit；三门全绿；边界严守（无 swift/训练/工具数命名）；无半写入/无回归/幂等。唯一 P2 是 scope_tier 字段命名观察（不影响正确性，S1 对齐即可）。

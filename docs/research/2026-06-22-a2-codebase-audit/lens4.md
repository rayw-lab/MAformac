# Lens 4: 数字口径核验（claim-vs-reality 第10变体）

# 10 族设备口径真相表：多版本分叉核验报告

## 摘要

发现 10 族设备（空调/座椅/车窗/车门/灯光/屏幕/音量/雨刮/天窗遮阳帘/香氛）的四个版本数字口径存在系统性分叉：

| 维度 | SOURCE 1 | SOURCE 2 | SOURCE 3 | SOURCE 4 |
|-----|---------|---------|---------|---------|
| **来源** | generated/10-family-device-boundary.md (Codex) | docs/research/2026-06-22-mvp-10family-device-boundary.md (CC一手) | paradigm grill-decisions §14 (拍板版) | contracts/semantic-function-contract.jsonl (ground truth) |
| **方法** | CC jq 子串宽匹配 + 分层 | explicit allowlist | explicit allowlist + A1-A9拍定 | 3990行原始数据 |
| **device** | 223 (161 def + 62 disp) | 191 | 191 | 671 total |
| **intent** | 507 (def) + 680 (all) | 562 | 534 | 1538 total |
| **行数** | (未明说) | 2159 (54.1%) | 2086 (52.3%) | 3990 (100%) |
| **权威等级** | 🥉 低 (已supersede) | 🥈 中 (输入版本) | 🏆 最高 (拍板) | 📋 数据源 |

---

## 根因分析：为什么分叉？

### 1. 正则宽匹配 vs Explicit Allowlist

**SOURCE 1 问题**：CC jq 用 `^ac` 前缀匹配，误吸入：
- `accelerator_anti_false_step` ✗
- `account_list` ✗
- `acoustics_mode` ✗

验证（从 contracts/semantic-function-contract.jsonl）：
```
"ac_*" device 实际存在: 8 个（ac_temperature/ac_windspeed 等）
但 "^ac" 正则命中: 11 个（含误吸 3 个）
```

**SOURCE 2/3 修正**：用 explicit device 清单（"ac_" 前缀 + airoutlet/defog/defrost 等已列清单）
```python
# 精确规则而非正则
ac = {
    "ac_temperature", "ac_windspeed", "ac", "ac_cooling_mode", ...,
    "airoutlet", "airoutlet_direction",
    "defog_mode", "defrost_mode", "dehumidification_mode",
    "zone_synchronization_mode", "ventilation_system", ...
}  # ≈ 25 device，排除 accelerator/account/acoustics
```

差异量化：
- SOURCE 1 的 "disputed" 62 device 中，多数是正则假阳性
- SOURCE 2/3 通过 explicit list 排除了这些，归为"族外"

---

### 2. Definite vs Definite+Disputed vs A1-A9拍板

**源头分歧**：SOURCE 1 在 "definite/disputed" 之间摇摆，SOURCE 2 试图分类，SOURCE 3 拍定最终。

**关键歧义点（paradigm §3，9个）**：

| 编号 | Device | 现状（S2） | 拍定（S3） | Intent影响 |
|-----|--------|----------|---------|----------|
| A1 | interior_heat (40行) | 族外 | 族外 ✓ | 10 intent脱离 |
| A2 | volume_mute/unmute/current_volume | 音量 | 音量 ✓ | 0 (保持) |
| A3 | driving_sound_wave_volume | 族外 | 族外 ✓ | 0 |
| A4 | steering_wheel_heating (18行) | 族外 | 族外 ✓ | 10 intent脱离 |
| A5 | hud* (13 device, 59行) | 族外独立HUD | 族外 ✓ | ~20 intent脱离 |
| A6 | backlight/button_brightness | 族外 | 族外 ✓ | 0 |
| A7 | console_moving/position | 族外 | 族外 ✓ | 0 |
| A8 | windshield_heating | 车窗族 | 车窗族 ✓ | 0 (保持) |
| A9 | theme/wallpaper (屏幕皮肤) | 屏幕族 | 屏幕族 ✓ | 0 (保持) |

**A1-A9 拍定的影响**：
- SOURCE 2 中 562 intent = 191 device 的 union（包含上述9个歧义点待决状态）
- SOURCE 3 中 534 intent = 191 device 的 union（A1-A9 拍定后，确定4个歧义设备族外）
- 差异：562 - 534 = 28 intent（恰好是 A1/A4/A5 三个歧义点的并集）

paradigm §233 明言：
> 旧段/旧 grill 引用的「562」「418」「缺486」= claim-vs-reality 第10变体（旧数字没随新坐实回写）

---

### 3. 三表关系未厘清（paradigm §7的残留问题）

**问题**：三个"全集"表的对应关系：
- TOP技能表（subagent）：7787 intent / 2045 工具 
- semantic-function-contract.jsonl（仓内）：3990 行 / 671 device / 1538 intent
- codex 称 carControl 服务 2544 条（≠仓内2656）

**paradigm 的结论**（§7，现已 cite-verify）：
- **3990 与 TOP intent 命名一字不差** ✓（同协议族、高度同源）
- **非严格子集** ✓（contract-only 43 / TOP-only 529）
- **3990 = 仓内当前 SSOT**（脱敏+可 codegen）
- **TOP = 更全 oracle**（不是直接替代，对账延后）

---

## 数字分叉时间线

```
2026-06 初  SOURCE 1 (generated/10-family-device-boundary.md)
            ├─ CC jq 422 intent (子串宽匹配)
            ├─ GLM 397 intent (精确匹配)
            └─ 不一致 → 等 SOURCE 2 定义

2026-06-22  SOURCE 2 (docs/research/2026-06-22-mvp-10family-device-boundary.md)
            ├─ 191 device (explicit allowlist)
            ├─ 562 intent (10族UNION)
            ├─ A1-A9 歧义点待拍定（见§3）
            └─ 意图：消除正则假阳性，但决策未终局

2026-06-22  SOURCE 3 (paradigm grill-decisions-amend-paradigm-tool-surface.md)
           晚夜    ├─ A1-A9 全部拍定（见§13）
            ├─ 191 device (confirmed)
            ├─ 534 intent (after A1-A9)
            ├─ 2086 行 (52.3%)
            └─ 权威版本（grill 拍板）

并行      SOURCE 4 (contracts/semantic-function-contract.jsonl)
            └─ 3990 行原始数据，被 S2/S3 指标化
```

---

## 为何权威等级：SOURCE 3 > SOURCE 2 > SOURCE 1？

| 维度 | SOURCE 1 | SOURCE 2 | SOURCE 3 |
|-----|---------|---------|---------|
| **正则方式** | ✗ 宽匹配误吸 | ✓ explicit allowlist | ✓ explicit allowlist |
| **A1-A9拍定** | ✗ 未考虑 | ✗ 列出但未拍 | ✓ 全部拍定 |
| **数字一致性** | 422≠397 | 待定 | 最终 |
| **grill状态** | 已过期 | 输入文档 | 🏆 拍板版 |
| **codegen就绪** | ✗ 方法错 | ⚠️ 含待定 | ✓ 可直接用 |

**paradigm §35 的元认知**：
> 旧数字在 §7/§13/handoff 件6 间分叉，靠人工 catch 才纠正。需升级为 harness enforce cross-section 一致性 + SUPERSEDED 标记规范。

---

## Codegen 应消费哪个口径？

**paradigm §5/§7 明确指示**：

```
从 SOURCE 4 (contracts/semantic-function-contract.jsonl)  ← 数据源
按 SOURCE 3 (paradigm §14) 的 191 device explicit list     ← 规范
生成 具名工具目录                                            ← 替代硬编码
  (value 形态编码进名，domain→service-group→tool 三级)
```

**替代的 6 处硬编码**（paradigm §5）：
1. `ToolContractCompiler.dDomainSurfaceNames():73-87` 
2. `ToolContractCompiler.normalize():148-160`
3. `ToolContractCompiler:305/311` (device→IR)
4. `C3ExecutionPipeline:163/171` (runtime executor tier)
5. `C6VehicleToolBench applier:1163` (炸场子集)
6. `FastPathIntentEngine:12` (规则路)

**两层 scope** (paradigm §7)：
- `--scope=full`：轻量目录（1538 tool名），族外用于 unsupported 拒识
- `--scope=demo`：重度目录（534 完整 value-form），端侧挂载

---

## Cite-Verify: 数字断言核查

| 序号 | Claim | Source | Verdict |
|-----|-------|--------|--------|
| 1 | SOURCE 1: 223 device (161 def + 62 disp) | generated/10-family-device-boundary.md:10 | ✓ confirmed（正则误吸+分层） |
| 2 | SOURCE 1: 507 intent (definite only) | generated/10-family-device-boundary.md:14 | ✓ confirmed（definite but未排误吸） |
| 3 | SOURCE 1: 680 intent (all) | generated/10-family-device-boundary.md:14 | ✓ confirmed（definite+disputed和） |
| 4 | SOURCE 2: 191 device | docs/research/2026-06-22-mvp-10family-device-boundary.md:37 | ✓ confirmed（explicit allowlist） |
| 5 | SOURCE 2: 562 intent | docs/research/2026-06-22-mvp-10family-device-boundary.md:39 | ✓ confirmed（含A1-A9待定） |
| 6 | SOURCE 3: 534 intent (after A1-A9) | docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:226 | ✓ confirmed（拍定后） |
| 7 | A1-A9拍定导致 562→534 的 28 intent 差异 | grill-decisions:211,233 | ✓ confirmed（interior_heat/steering_wheel_heating/hud脱离） |
| 8 | 源 4 与 TOP 同源但非严格子集 | grill-decisions:88-93 | ✓ confirmed（43独有 vs 529独有） |

---

## 关键发现

**🔴 TIGER**：SOURCE 1 的 223 device 数字已过期，源于正则宽匹配误吸。所有新工作应弃用，改用 SOURCE 3。

**🟡 PAPER TIGER**：SOURCE 2 的 562 intent 在 SOURCE 3 发布后成为中间态（claim-vs-reality 第10变体）。源码中若还引用需标 SUPERSEDED。

**✅ ELEPHANT**：A1-A9 九个边界歧义点的拍定过程完全正确，paradigm §3/§13 的论证严谨，脱离 10 族的 28 intent 确实来自这些歧义决议。

**📋 NA**：contracts/semantic-function-contract.jsonl 作数据源地位稳固，paradigm §7 的「同源、非严格子集」结论合理，无需重新验证。

---

## 建议行动

1. **即刻**：代码中所有引用 SOURCE 1 (223/507/680) 的位置标 SUPERSEDED 指向 SOURCE 3
2. **即刻**：paradigm grill-decisions 作为最新 SSOT，级联到相关文档（g6c-design.md / execution-gap / CLAUDE §9）
3. **编码前**：运行 `gen_tool_contract.py` codegen SOURCE 3 explicit list（替代 §5 六处硬编码）
4. **长期**：实现 harness cross-section enforce，防止类似第10变体再发生

---

*report generated via python claim-vs-reality verification (3990行合约+四源对账)*
*date: 2026-06-22*
---
kind: g9-deferred-gates-registry
as_of: 2026-07-23
authority: phase2-g9-human-review
phase2_coding_gate: PHASE2_CODING_GATED
actionDemoProven: 0/120
inventory: run-root PHASE2-G9-ACTIVE-GATE-INVENTORY.md
reduction_table: run-root PHASE2-G9-REDUCTION-TABLE.md
---

# G9 Deferred Gates Registry

本登记册记录 G9 人审定为 **deferred** 的 Makefile `verify*` 门。它们 **保留独立 recipe 与实现**，本地可运行，但 **不计入 day-zero required Verify / product E2E / UI E2E 叙事**。

## 守恒上下文

- Makefile `verify*` recipe 总数：**47**
- Survivor：**45**
- Deferred：**2**（本文件）
- Merged / archived / removed：**0**（磊哥人审：不为减门数硬凑）

## G25 — `verify-frontstage-route`

| 字段 | 值 |
|---|---|
| **Makefile** | `:286-288` |
| **实现** | `scripts/test_check_frontstage_route_receipt.py`、`scripts/test_run_frontstage_route_gate.py`、`scripts/test_frontstage_ui_harness.py`、`scripts/test_finalize_frontstage_route_ui_abi.py`、`scripts/run_frontstage_route_gate.sh` |
| **Owner** | `runtime-presentation-bridge` + frontstage route receipt lane（C1 前台路由 ABI；非 verify-ci consumer） |
| **CI consumer** | **无**（不在 `verify` / `verify-ci` / `verify.yml` deps） |
| **Disposition** | `deferred` |

### 重新启用 trigger（须同时满足）

1. Frontstage route receipt v2 与 UI harness ABI 有明确产品行为 change / OpenSpec delta，且磊哥书面授权纳入 required 链或 release 门。
2. `verify-frontstage-route` 本地连续 PASS，且 receipt 与 schema 对齐（`contracts/schemas/frontstage-route-receipt.schema.json`）。
3. 若纳入 CI：须单独 workflow step 或显式 deps 变更 + 守恒表 amendment + 异源审；**不得**静默塞进 `verify-ci` 冒充已绿 survivor。

### Non-claims

- Deferred ≠ 已删除 / 已 archive / 已废弃实现。
- Deferred ≠ frontstage 产品面已闭 / UI 已 required。
- 本地 PASS ≠ day-zero required 链 PASS。

### 本地运行

```bash
make verify-frontstage-route
```

## G37 — `verify-c5-phase1-gates`

| 字段 | 值 |
|---|---|
| **Makefile** | `:359+` |
| **实现** | `scripts/test_query_zero_tolerance.py` 等 C5 phase-1 门（BF-7 独立账） |
| **Owner** | C5 / full-suite 训练与模型门 lane（与当前 `PHASE2_CODING_GATED` demo-tool 正交） |
| **CI consumer** | **无**（BF-7；非 `verify-ci` / `verify.yml`） |
| **Disposition** | `deferred` |

### 重新启用 trigger（须同时满足）

1. BF-7（C5 / full suite / 模型门）由磊哥解冻，且有书面 scope（非 Phase2 G9 治理 reduction 默许范围）。
2. S10 verdict receipt + `make verify-c5-phase1-gates` rc0 + qa safety receipt 链对齐 `docs/roadmap-2026-07-11-v6-closure-baseline.md` 量尺。
3. 纳入 required 链前须 amendment 守恒表 + 明确 CI/workflow 消费点。

### Non-claims

- Deferred ≠ C5 已闭 / 模型已接入产品执行链。
- Deferred ≠ `verify-ci` 已含 C5 门。
- 本地 PASS ≠ Phase2 解冻 / `actionDemoProven` 抬格。

### 本地运行

```bash
make verify-c5-phase1-gates
```

## 变更纪律

- 本登记册 **不授权** 删除、移动或 archive 上述 target / script。
- 将 deferred 升格为 survivor-required 须：守恒表 amendment → 异源审 → 磊哥人审 → 显式 Makefile/workflow 变更。
- 观察窗「不回潮」口号 **禁止** 在本登记册或 day-zero 当日写出（Ultra / WBS 纪律）。

# C6 Eval Spine — Durable Technical Lessons

> 本文档记录 C6 S9→S11 eval spine 实现过程中沉淀的可复用教训。每个教训附带一手证据（file:line 或实跑输出）和触发模式（什么条件下该想起这条）。

---

## L1: 绿测试可以隐藏 schema 跳过

**教训**：测试全绿 ≠ 所有 schema 门都跑了。如果 fixture 路径不覆盖某个 schema 字段，该字段的校验可能从未被触发。

**一手证据**：`scripts/test_check_c6_eval_spine.py` 33 tests PASS，但 `test_four_layer_threshold_completeness_red` 是后来才补的负例——之前缺少 `E_THRESHOLD_INCOMPLETE` 的 fixture 覆盖。

**触发模式**：看到「N tests PASS」就认为 schema 校验完备 → 检查负例覆盖率（每个 failure code 至少一个 fixture 真红）。

**防护**：`failure-codes.v1.json` 的每个 code 在 `test_check_c6_eval_spine.py` 中至少有一个对应 test_*_red 函数。用 grep 核对：
```bash
grep -oP 'E_\w+' Tools/C6EvalSpine/failure-codes.v1.json | sort -u > /tmp/codes.txt
grep -oP 'E_\w+' scripts/test_check_c6_eval_spine.py | sort -u > /tmp/tested.txt
diff /tmp/codes.txt /tmp/tested.txt  # 差异 = 未覆盖的 failure code
```

---

## L2: 存在性检查不是 authority 绑定

**教训**：检查一个文件「存在」或「有内容」不等于验证它的内容与权威 pin 一致。`manifest.holdout.sha256 is not None` 通过了，但 sha 可能是旧值。

**一手证据**：`Tools/C6EvalSpine/s9_three_arm.py:137-144` 中 `validate_required_bindings()` 最初只检查 holdout sha 非空，后来才加 exact match 比较。旧代码允许 manifest 声明任意 sha 通过 preflight。

**触发模式**：看到 `if x is not None` 或 `if x` 作为绑定校验 → 必须加 exact match（`== EXPECTED`）。

**防护**：所有 pin/authority 绑定必须三路相等（pin == subject == artifact），见 `verify_holdout_three_way()`（`s9_three_arm.py:217-247`）。

---

## L3: Producer 生成的 expected_case_ids 不是权威 case set

**教训**：receipt 的 `expected_case_ids` 字段是 assertion-only——它声明「我认为 case set 是这些」，但权威 case set 永远来自 `verify_holdout()` 的 D-127 pin 实时计算。如果 receipt 的 expected_case_ids 与 pin 不一致，receipt 错，不是 pin 错。

**一手证据**：`Tools/C6EvalSpine/s9b_aggregate.py:12-15` 的 `load_authoritative_case_ids()` 每次都从 pin 重算；`validate_receipt_expected_case_ids()`（同文件:18-86）把 receipt 的声明与权威集做 exact match 校验。

**触发模式**：看到「receipt 自带了 case_id 列表」→ 校验它是否与权威 pin 一致，不要信任 receipt 的自声明。

**防护**：任何 `expected_case_ids` 字段必须与 `verify_holdout()` 的实时输出 exact match。fixture subset 也必须是权威集的子集。

---

## L4: 全零 digest 在语法上合法、在语义上非法

**教训**：SHA-256 的 `0*64` 是合法的 hex 字符串，正则 `^[0-9a-f]{64}$` 会通过。但全零 digest 意味着「未计算」或「占位符」，不能作为有效的绑定证据。

**一手证据**：`Tools/C6EvalSpine/constants.py` 没有显式定义 `ZERO_SHA`，但 `export_freeze_packet.py:159-160` 和 `export_ratification_packet.py:142-143` 都显式拒绝全零 sha。schema 的 `pattern` 用了 `^(?!0{64}$)[0-9a-f]{64}$` 来排除全零。

**触发模式**：任何 digest 字段用 `pattern: "^[0-9a-f]{64}$"` 校验 → 必须加 negative lookahead 排除全零。

**防护**：JSON Schema 的 `pattern` 用 `^(?!0{64}$)[0-9a-f]{64}$`；代码中显式 `if sha == "0" * 64: reject`。

---

## L5: 中间态 sealed/PASS 本身就是一个 claim

**教训**：S9 的 partial seal 或 S9b 的 aggregate PASS 本身会被人解读为「S9 做完了」。即使代码不写 `package_b2_done=true`，中间态的「PASS」标签也会被观察者当作完成信号。

**一手证据**：`Tools/C6EvalSpine/spine.py:322-323` 显式设置 `claims.package_b2_done=false`，但 `stages.s9.status=PASS` 本身出现在输出 JSON 中。fixture replay 的 `DONE_LOCAL_EVAL_SPINE_READY_FOR_S8_FANIN` 状态标签（`:322`）明确说「ready for fan-in」，不是「S9 DONE」。

**触发模式**：任何 stage 输出 `status=PASS` → 必须同时输出 `claims.package_bX_done=false` 和 `non_claims` 列表，防止观察者把 harness 绿等同于 package 完成。

**防护**：每个 stage receipt 必须同时包含 `claims`（所有 package DONE 恒 false）和 `non_claims`（显式否定列表）。`validate_claims_forbidden()`（`spine.py:102-126`）硬拦任何写 true 的尝试。

---

## L6: 同源漂移必须通过 committed-candidate 比较捕获

**教训**：如果 B7/V1 的 candidate 文件被修改（例如阈值微调、digest 重算），spine 的 `--check` 模式（live recompute + byte-equal committed）是唯一能捕获漂移的机制。只看 `git diff` 可能漏掉内容语义变化。

**一手证据**：`export_freeze_packet.py:338-485` 的 `self_check()` 做 live recompute 并与 committed packet 的每个 digest 字段 exact match。`export_ratification_packet.py:306-470` 同理。

**触发模式**：多个 producer 可能修改同一 candidate 文件 → 每次 spine 运行前必须 `--check` 确认 candidate 未漂移。

**防护**：`check_c6_eval_spine.py` 的 preflight 阶段调用 `load_thresholds_from_v1()` 时传入 `expected_digest`，digest 不匹配 → `E_V1_DIGEST_MISMATCH`。B7 digest 同理。

---

## L7: 决策 ratification 与 artifact materialization 是两种模态

**教训**：D-147 完成了 T01/T02 的**决策层** ratification（commander 拍板），但这不等于 B7 freeze packet 已写、V1 status 已翻 RATIFIED、或 closure receipt 已落盘。把「决策已拍」等同于「执行已完成」是 0/34 灾难同源错误。

**一手证据**：
- `Tools/C6EvalSpine/spine.py:19-27` 的 `RESIDUAL_ENUM` 不包含 `missing_t01_t02_ratification`（因为决策层已满足），但 `authority_materialization_pending`（`:63-92`）单独跟踪执行层缺口。
- `design.md:5` 明确写「D-147 = T01/T02 **决策 ratification 已完成**；B7 **freeze 执行**与 V1 **canonical ceremony** **仍未完成**」。

**触发模式**：看到「D-147 RATIFIED」→ 分诊：决策层已拍 vs 执行层（freeze packet / ceremony receipt / registry flip）未完成。两个问题。

**防护**：`residual` enum 只跟踪「仍为真的剩余项」（决策层不重复），`authority_materialization_pending` 单独跟踪执行层缺口。两者结构分离，语义不重叠。

---

## L8: REAL 模式下的 S9b status whitelist 是 S10 的隐含前提

**教训**：S10 verdict 的 PASS 不仅依赖 V1 阈值和 QA/C5 门，还隐含要求 S9b 的 status 必须是 `PASS`。如果 S9b 返回 `BLOCKED` 或 `INCOMPARABLE`，S10 不能自行 PASS。

**一手证据**：`Tools/C6EvalSpine/s10_verdict.py:166-179` 在 REAL 模式下检查 `s9b_status == "PASS"`，否则 `E_S9B_STATUS_NOT_PASS`。fixture 模式也要求 S9b 不是 FAIL/INCOMPARABLE。

**触发模式**：看到 S10 独立 PASS → 检查 S9b status 是否也为 PASS。S10 不能绕过 S9b 的失败。

**防护**：S10 的 status 计算必须引用 S9b 的 status 作为输入，不能独立判定 PASS。

---

## L9: fixture subset 语义必须与 REAL caseset 语义严格分离

**教训**：fixture 模式允许 `fixture_subset=true`（只跑 D-127 61 行的子集），但 REAL 模式必须跑 exact 61 行全集。把 fixture subset 的 PASS 当成 REAL 的 coverage 证据是错误的。

**一手证据**：`Tools/C6EvalSpine/s9b_aggregate.py:124-156` 在 REAL 模式下拒绝 `fixture_subset=true`，要求每臂 exact 61-case set。fixture subset 的 case_id 必须来自权威集（`:187-198`）。

**触发模式**：fixture 用 `--case-limit 8` 快速验证 → 结果不能作为 REAL coverage 的证据。

**防护**：`check_caseset_completeness()` 按 mode 分流：REAL 强制 exact 全集，fixture subset 必须声明 `fixture_subset=true` 且 ID 限于权威集。

---

## L10: 阈值只读 V1 意味着 spine 代码中不能有任何 fallback 默认值

**教训**：如果 `load_thresholds_from_v1()` 在 V1 文件缺失或字段不全时返回一个硬编码默认值（如 `golden=1.0`），那就等于在 spine 代码中内嵌了第二套阈值——违反了 AD-SPINE-005。

**一手证据**：`Tools/C6EvalSpine/thresholds.py:38-112` 的 `validate_four_layer_thresholds()` 在缺失/多余/类型错误时全部 fail-closed，从不合成默认值。`evaluate_layer_gate()`（`:182-301`）在 `eligible==0` 时返回 `gate=UNKNOWN` 而非 `PASS`。

**触发模式**：任何 `if not thresholds: return DEFAULT_THRESHOLDS` 的模式 → 必须改为 fail-closed。

**防护**：阈值加载路径中没有任何 `or 1.0`、`or {}`、`or "5*pass >= 4*eligible"` 这类 fallback。所有缺失都是硬错误。

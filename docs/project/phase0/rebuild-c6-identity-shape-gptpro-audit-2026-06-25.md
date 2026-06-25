可下载 Markdown 文件： [pr_audit_7.md](sandbox:/mnt/data/pr_audit_7.md)

# PR #7 深度代码审计简报 — Long-run 2 Rebuild-C6 Identity + Behavior Shape Closeout

## PR 摘要

PR #7 当前审计 head 为 `f6b6a15d8d898f53f4fc76783c238da3d57aacfa`，与本轮指令指定 branch tip 一致；PR 状态为 open draft，base 为 `main`，branch 为 `codex/rebuild-c6-doc-absorption-20260624`。PR 元数据为 20 commits、42 changed files、`+8077 / -396`，合计 8473 changed lines。

本审计**只覆盖 Long-run 2 construction-lane local closeout**：Phase 4 contract bundle identity、Phase 5 explicit D-domain `behavior_class` shape migration、Phase 6 local closeout/evidence docs。明确不将本 PR 外推为 retrain-C5、C6 acceptance、model-quality eval、candidate comparison、golden-run、voice/endpoint readiness、UIUE merge、R-L17 signoff 或 V/S/U-PASS。

**整体风险等级：MEDIUM。**

原因：主体实现与证据边界基本合格，但 source-free shape checker 仍存在一个 P1 fake-green 缺口。

---

## Overall verdict

**PASS_WITH_FIXES**

理由：

* **通过部分**：结构化 `contract_bundle_fingerprint` 已落到运行 receipt / summary / CLI 输出；五类 `behavior_class` taxonomy 已进入 JSONL、decode、generator、validation 与本地 gate；closeout docs 将证明边界控制在 `local-pass-pending-gptpro`，没有宣称 external pass 或 C6 acceptance。
* **需吸收部分**：`scripts/check_c6_case_shape.py` 未强制 no-call behavior class 必须 `expect_no_call=true`。这会允许构造出 `behavior_class=refusal_no_available_tool|clarify_missing_slot|already_state_noop|refusal_safety_or_policy`、`expected_tool_calls=[]`、但 `expect_no_call=false` 的 forged row；runtime gate 当前主要依赖 `expectNoCall`，此 forged row 可能走“空工具调用直接成功”路径。该问题不影响当前 57 行 tracked dataset 的已观察状态，但影响该 local shape gate 对 fake-green 的抵抗力，按本轮审计请求定为 **P1**。

---

## 8 维度详细评分表

|  # | 维度                 | Score | Verdict         | 证据 file:line                                                                                                                                                                                                                                                                                              | 审计结论                                                                                                                                                                                                  | 改进建议                                                                                                                                                                            |
| -: | ------------------ | ----: | --------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|  1 | 架构合规性              |   4/5 | PASS_WITH_FIXES | `Core/Contracts/VehicleToolBehaviorClass.swift:3-8`; `Core/Bench/C6VehicleToolBench.swift:158-250`; `Makefile:32`; `Makefile:55-56`; `scripts/check_c6_case_shape.py:121-125`                                                                                                                             | 五类 taxonomy 独立建模；`C6BenchCase` decode 要求显式 `behavior_class`；local `verify` 已包含 `verify-c6-shape`。但 shape checker 的 no-call 方向约束不完整，留下 P1 fake-green 缺口。                                               | 吸收 P1：checker 与 in-process validation 都要强制 no-call class 与 `expect_no_call` 对齐。                                                                                                 |
|  2 | 代码质量               |   4/5 | PASS_WITH_FIXES | `Core/Bench/C6ContractBundleFingerprint.swift:36-60`; `Core/Bench/C6ContractBundleFingerprint.swift:154-174`; `Core/Bench/C6VehicleToolBench.swift:1247-1249`; `scripts/check_c6_case_shape.py:109-125`                                                                                                   | 指纹 receipt validator 集中化，runner 在生成 eval run 后 fail closed；checker 对 `already_state_noop` 做机械验证。主要缺口是 checker 约束单向，且 `C6ContractBundleFingerprintRecord` 的 public raw init / opaque helper 仍保留未来误用空间。 | P1 吸收后，将 raw receipt construction 收敛到 throwing factory 或增加 canonical verification。                                                                                              |
|  3 | 测试覆盖               |   3/5 | PASS_WITH_FIXES | `Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift:101-126`; `Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift:798-856`; `Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift:866-892`; `docs/project/phase0/rebuild-c6-identity-shape-evidence-excerpt-2026-06-25.md:16-49`; `Makefile:68-71` | Swift tests 覆盖 tracked/generated `behavior_class`、五类 taxonomy、结构化 receipt、missing component fail-closed、identity 字段保留。缺少 Python checker 的恶意 fixture/negative tests，导致 P1 没被测试捕获。                      | 新增 `scripts/test_check_c6_case_shape.py`，覆盖 no-call class + `expect_no_call=false`、`direct_no_call`、row-count shrink、unknown tool、coverage-to-golden 等恶意样例，并纳入 `Makefile:test`。 |
|  4 | 安全风险               |   4/5 | PASS            | `Tools/C6BenchCLI/main.swift:72-80`; `Tools/C6BenchCLI/main.swift:87-91`; `Tools/C6BenchCLI/main.swift:182-191`; `scripts/check_c6_case_shape.py:1-8`; `scripts/check_c6_case_shape.py:127-135`                                                                                                           | 未见 secret 注入、SQL injection、XSS、反序列化执行、权限扩大。CLI 只读本地 repo/artifact 文件，LoRA artifact digest 约束有 fail-closed 逻辑；shape checker 只用 stdlib JSON/Path。                                                       | 保持本地文件 digest 路径为显式输入；如后续接入远端 artifacts，再补充 path allowlist / size cap / symlink policy。                                                                                         |
|  5 | 性能影响               |   4/5 | PASS            | `Core/Bench/C6VehicleToolBench.swift:319-335`; `Core/Bench/C6VehicleToolBench.swift:356-364`; `Core/Bench/C6VehicleToolBench.swift:1374-1431`; `docs/project/phase0/rebuild-c6-identity-shape-evidence-excerpt-2026-06-25.md:45-49`                                                                       | 当前数据规模 57 rows；JSONL decode、shape check、summary aggregation 都是线性路径，无 N+1 query、hot loop、同步网络阻塞或大对象泄漏迹象。                                                                                               | 若 dataset 放大到数万行，再考虑 streaming JSONL 与 incremental hashing；当前无需优化。                                                                                                              |
|  6 | 依赖与兼容性             |   5/5 | PASS            | `scripts/check_c6_case_shape.py:1-8`; `Core/Contracts/ToolContractCompiler.swift:29-33`; `Core/Contracts/ToolContractCompiler.swift:160-170`; `Makefile:55-56`; `.github/workflows/verify.yml:23-27`                                                                                                      | 未新增第三方依赖或 license 风险；shape checker 为 Python stdlib；Swift code 使用 Foundation/JSONDecoder；CI 与 Makefile 沿用现有工具链。                                                                                        | 保持 checker stdlib-only；若未来引入 schema validator，需明确 license 与 CI version pin。                                                                                                     |
|  7 | 可读性 + 可维护性         |   4/5 | PASS_WITH_FIXES | `docs/project/phase0/rebuild-c6-identity-shape-lessons-2026-06-25.md:17-22`; `docs/project/phase0/rebuild-c6-identity-shape-closeout-2026-06-25.md:83-87`; `Core/Bench/C6VehicleToolBench.swift:280-300`; `scripts/check_c6_case_shape.py:36-49`                                                          | 文档诚实记录了 receipt/shape lessons 与 diagnostic `clarify` 残留；runtime 四层 selector 与 Python diagnostic counter 的命名仍可能让后续审计误读。                                                                                | 将 `external_layer_candidate_counts` 改名为 `shape_diagnostic_candidate_counts`，或在脚本输出中显式标注 “not runtime external-layer SSOT”。                                                      |
|  8 | CI / lint / format |   5/5 | PASS            | `.github/workflows/verify.yml:23-27`; `Makefile:40`; `Makefile:55-56`; `docs/project/phase0/rebuild-c6-identity-shape-evidence-excerpt-2026-06-25.md:79-84`                                                                                                                                               | GitHub Actions `Verify` workflow 执行 `make verify-ci` 与 `git diff --check`；head-bound CI run/job 均为 success；local evidence 也记录 `git diff --check` exit 0。                                              | P1 checker fix 合入后，确认 CI run 重新通过，并把新增 Python checker negative tests 纳入 `make verify-ci` 或 `make test`。                                                                         |

---

## Findings

### P0

无。

---

### P1-1 — Source-free shape checker 未强制 no-call behavior class 与 `expect_no_call=true` 对齐，留下空调用直接成功 fake-green 路径

**Severity:** P1
**Verdict impact:** 触发 `PASS_WITH_FIXES`。
**Status:** 当前 tracked 57 rows 未观察到该违规形态；问题在于 gate 对恶意/回归行不够 fail-closed。

#### 证据

1. Checker 当前只做了两个单向判断：

   * `expect_no_call=true` 时，`behavior_class` 必须属于 no-call behavior classes。
   * `expected_tool_calls == []` 时，`behavior_class` 必须属于 no-call behavior classes。

   但它没有反向要求：`behavior_class in NO_CALL_BEHAVIOR_CLASSES` 时，`expect_no_call` 必须为 `true`。
   Evidence: `scripts/check_c6_case_shape.py:121-125`

2. Runtime evaluator 的 gate 仍主要由 `candidate.expectNoCall` 驱动；`noToolFalsePositiveCount` 只在 `expectNoCall` 为 true 时统计。
   Evidence: `Core/Bench/C6VehicleToolBench.swift:1288-1290`

3. 当 `expectNoCall=false` 时，即使 `expectedToolCalls=[]`，runtime 会进入非 no-call apply/state 分支，空调用可产生 state pass 条件；后续 tool mismatch 也只在 `!expectNoCall && !toolMatch` 时触发，而空数组对空数组可 match。
   Evidence: `Core/Bench/C6VehicleToolBench.swift:1292-1314`; `Core/Bench/C6VehicleToolBench.swift:1341-1346`

4. Resolver fallback 还会把 `expectedToolCalls.isEmpty` 直接归到 `.refusalNoAvailableTool`，没有检查 `expectNoCall`。
   Evidence: `Core/Bench/C6VehicleToolBench.swift:268-274`

#### 可构造的 forged row

```json
{
  "case_id": "C6-FORGED-NOCALL-001",
  "behavior_class": "refusal_no_available_tool",
  "expected_tool_calls": [],
  "expect_no_call": false,
  "expected_state_delta": {},
  "clarify_tag": "rejected",
  "source_refs": {"risk_rule_ids": [], "semantic_contract_ids": [], "state_cell_ids": [], "scenario_ids": []},
  "tags": {"bucket": "refusal", "sample_kind": "forged", "must_pass": false, "must_not_train": false, "contract_device": "out_of_domain"},
  "pre_state": {},
  "input_zh": "forged",
  "readback_assertion": {"contains": []},
  "failure_class": "refusal",
  "alternatives": []
}
```

该行满足当前 checker 的 no-call class/empty expected calls 条件，但 `expect_no_call=false` 使 runtime gate 不进入 no-call false-positive 约束，从而构成“空工具调用直接成功”的 fake-green 入口。

#### 精确吸收指令

在 `scripts/check_c6_case_shape.py` 的 behavior-class 基础验证之后加入：

```python
if not isinstance(expect_no_call, bool):
    errors.append(f"{case_id}: expect_no_call must be boolean, got {expect_no_call!r}")
elif behavior_class in NO_CALL_BEHAVIOR_CLASSES and expect_no_call is not True:
    errors.append(f"{case_id}: {behavior_class} requires expect_no_call=true")
elif behavior_class == "tool_call" and expect_no_call is not False:
    errors.append(f"{case_id}: tool_call requires expect_no_call=false")
```

同时建议在 Swift validation 侧补一道 in-process 守护：

* `C6DatasetGenerator.validate(_:)` 对 `behaviorClass != .toolCall` 且 `expectNoCall != true` 计入 unresolved/error。
* 或新增 `C6BenchCaseShapeValidator`，让 generator validation、CLI summarize、unit tests 可复用同一套规则。

新增测试：

* `scripts/test_check_c6_case_shape.py`：构造上述 forged row，断言 checker exit != 0。
* `Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift`：加入 no-call class + `expectNoCall=false` 的 validator regression。
* `Makefile:test`：纳入 Python checker negative tests，防止只靠人工运行 shape script。

---

### P2-1 — `C6ContractBundleFingerprint` 仍保留 public opaque `fingerprint(...) -> String` helper，未来调用者可能误用为 receipt

**Severity:** P2
**Status:** 不阻塞本轮 closeout；当前 CLI / summary / eval run 使用的是 structured receipt。

#### 证据

* Structured record 已包含 `schemaVersion / bundleHash / componentDigests`，并有 `hasRequiredFields`。
  Evidence: `Core/Bench/C6ContractBundleFingerprint.swift:36-60`
* CLI summarize 使用 `C6ContractBundleFingerprint.receipt(repoRoot:datasetText:)` 注入 runner，而非 string fingerprint。
  Evidence: `Tools/C6BenchCLI/main.swift:72-80`
* Markdown summary 渲染 `schema_version / bundle_hash / component_digests`。
  Evidence: `Tools/C6BenchCLI/main.swift:207-211`
* 但 `fingerprint(repoRoot:) / fingerprint(components:) / fingerprint(manifest:)` 仍是 public string-returning helpers。
  Evidence: `Core/Bench/C6ContractBundleFingerprint.swift:132-141`

#### 建议

* 将 string-returning `fingerprint(...)` 标记为 legacy/internal，或重命名为 `manifestHash(...)`，避免未来调用者把 opaque string 写回 `contract_bundle_fingerprint`。
* 增加一条测试：summary/CLI 输出中禁止 `contract_bundle_fingerprint` 为 string scalar。

---

### P2-2 — Receipt validation 目前只检查 required components 非空，不校验 duplicate component IDs / schema version exactness / bundle hash canonical consistency

**Severity:** P2
**Status:** 不阻塞本轮 closeout；当前 repoRoot 构造路径由 descriptors 生成，正常路径不会触发。

#### 证据

* `hasRequiredFields` 只检查 `schemaVersion`、`bundleHash` 非空，以及 required component digests 非空。
  Evidence: `Core/Bench/C6ContractBundleFingerprint.swift:53-60`
* `validated(manifest:)` 检查 component digest 非空与 required component IDs 存在，但没有拒绝 duplicate component IDs 或非预期 `manifestVersion`。
  Evidence: `Core/Bench/C6ContractBundleFingerprint.swift:154-174`
* `receipt(manifest:)` 用 `Dictionary(uniqueKeysWithValues:)` 汇总 component digests；若外部 manifest 有 duplicate IDs，可能从 throwing validation 退化为 runtime trap，而不是 typed fail-closed。
  Evidence: `Core/Bench/C6ContractBundleFingerprint.swift:114-125`

#### 建议

* `validated(manifest:)` 显式拒绝 duplicate `componentID`。
* `manifestVersion` 必须等于 `C6ContractBundleFingerprint.schemaVersion`，不要接受任意非空值。
* 增加 `C6ContractBundleFingerprintRecord.validateCanonical()` 或 throwing factory，允许 recompute `bundleHash` 后校验 `componentDigests` 与 `bundleHash` 一致。

---

### P2-3 — Shape checker 输出 `external_layer_candidate_counts` 仍含 diagnostic `clarify`，与 runtime 四层 selector 命名不一致

**Severity:** P2
**Status:** 不阻塞；文档已承认这是 plan-mandated diagnostic output，不是 runtime-layer SSOT。

#### 证据

* Python checker 的 diagnostic layer 可返回 `clarify`。
  Evidence: `scripts/check_c6_case_shape.py:36-49`
* Runtime external layer enum 只有 `golden / demo_fuzz / unsupported / safety`。
  Evidence: `Core/Bench/C6VehicleToolBench.swift:280-300`
* Closeout 明确记录：`clarify` candidate bucket 是 diagnostic output，不是 acceptance-layer SSOT。
  Evidence: `docs/project/phase0/rebuild-c6-identity-shape-closeout-2026-06-25.md:83-87`

#### 建议

将脚本输出字段从 `external_layer_candidate_counts` 改为 `shape_diagnostic_candidate_counts`，或在输出旁附带 `runtime_external_layer_ssot=false`，降低后续审计误读概率。

---

## Phase-by-Phase 审计结论

### Phase 4 — Contract bundle identity

**Verdict:** PASS_WITH_FIXES（仅 P2 API hardening 残留）

已满足：

* `contract_bundle_fingerprint` 在 eval run / summary 中是 structured receipt，不再是 opaque scalar。
  Evidence: `Core/Bench/C6VehicleToolBench.swift:666-717`; `Core/Bench/C6VehicleToolBench.swift:736-787`
* CLI summary 输出包含：

  * `schema_version`
  * `bundle_hash`
  * `component_digests`
    Evidence: `Tools/C6BenchCLI/main.swift:207-211`
* per-run identity fields 没有被 bundle receipt 替代，仍独立保留：

  * `prompt_hash`
  * `tool_output_digest`
  * `contract_digest`
  * `model_artifact_digest`
  * `tokenizer_digest`
  * `lora_adapter_digest`
    Evidence: `Core/Bench/C6VehicleToolBench.swift:666-717`; `Core/Bench/C6VehicleToolBench.swift:1226-1249`
* public manifest / receipt / fingerprint helper 都走 shared validation，对 missing required component fail closed。
  Evidence: `Core/Bench/C6ContractBundleFingerprint.swift:89-125`; `Core/Bench/C6ContractBundleFingerprint.swift:154-174`; `Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift:866-892`

Residual：

* P2-1 / P2-2：opaque helper 与 raw/canonical validation hardening。

---

### Phase 5 — Explicit D-domain `behavior_class` shape migration

**Verdict:** PASS_WITH_FIXES（P1 必须吸收）

已满足：

* 五类 taxonomy 明确存在。
  Evidence: `Core/Contracts/VehicleToolBehaviorClass.swift:3-8`
* `C6BenchCase` decode 要求 `behavior_class`，tracked legacy missing field 会 decode fail。
  Evidence: `Core/Bench/C6VehicleToolBench.swift:158-250`
* Generator source path 显式携带 `VehicleToolBehaviorClass` 到 `CaseSpec` 与 `makeCase`。
  Evidence: `Core/Bench/C6VehicleToolBench.swift:412-533`; `Core/Bench/C6VehicleToolBench.swift:539-561`
* Validation 将 missing `behaviorClass` 纳入 unresolved，并用 explicit behavior class 计算 negative ratio。
  Evidence: `Core/Bench/C6VehicleToolBench.swift:364-395`
* Tracked JSONL 有显式 behavior class；evidence excerpt 记录 `rows=57` 与五类计数。
  Evidence: `contracts/c6-bench-cases.jsonl:1-8`; `contracts/c6-bench-cases.jsonl:21-26`; `docs/project/phase0/rebuild-c6-identity-shape-evidence-excerpt-2026-06-25.md:45-49`
* `verify-c6-shape` 已进入 local `verify`，不是只在 CI。
  Evidence: `Makefile:32`; `Makefile:55-56`

未完全满足：

* Checker 对 `expect_no_call` 与 no-call behavior class 的关系仍是单向约束，见 P1-1。
  Evidence: `scripts/check_c6_case_shape.py:121-125`; `Core/Bench/C6VehicleToolBench.swift:1288-1314`

---

### Phase 6 — Local closeout / lessons / evidence excerpt

**Verdict:** PASS

已满足：

* Closeout 状态 capped at `local-pass-pending-gptpro`，外部审计状态为 pending/blocked。
  Evidence: `docs/project/phase0/rebuild-c6-identity-shape-closeout-2026-06-25.md:5-17`
* 明确列出 forbidden / deferred scope，没有把本地 local gates 提升为 C6 acceptance 或 external pass。
  Evidence: `docs/project/phase0/rebuild-c6-identity-shape-closeout-2026-06-25.md:28-40`; `docs/project/phase0/rebuild-c6-identity-shape-evidence-excerpt-2026-06-25.md:10-12`
* Evidence excerpt 把 ignored `Reports/` 中的关键命令输出转入 tracked docs，外部 auditor 可从 repo 文件看到 local gates。
  Evidence: `docs/project/phase0/rebuild-c6-identity-shape-evidence-excerpt-2026-06-25.md:16-84`
* Lessons 文档没有宣称 GPT Pro pass；它把 phase 6 overclaim 风险标记为 pending。
  Evidence: `docs/project/phase0/rebuild-c6-identity-shape-lessons-2026-06-25.md:45-53`
* Final refresh commit 修正了 “head is a56aa83” 这类历史 SHA 口径，改为 live branch tip/reconfirm wording。
  Evidence: `docs/project/phase0/rebuild-c6-identity-shape-gptpro-audit-request-2026-06-25.md:17-24`; `docs/project/phase0/rebuild-c6-identity-shape-gptpro-audit-request-2026-06-25.md:95-103`

---

## CI / lint / format 审计

**CI status:** PASS

* GitHub Actions `Verify` workflow 在该 head 上完成且 conclusion 为 `success`。
* `verify` job 完成且 conclusion 为 `success`，其步骤包含 source-free verification gates、whitespace check、head-bound CI receipt 与 artifact upload。
* Workflow 文件中 CI source-free gates 执行 `make verify-ci`，随后执行 `git diff --check`。
  Evidence: `.github/workflows/verify.yml:23-27`
* `verify-ci` 包含 `verify-c6-shape` 与 `swift-test`。
  Evidence: `Makefile:40`; `Makefile:55-56`
* Tracked local evidence 记录 `git diff --check` exit 0。
  Evidence: `docs/project/phase0/rebuild-c6-identity-shape-evidence-excerpt-2026-06-25.md:79-84`

---

## 具体待改 punch list

* [ ] **P1 / owner: C6 bench owner** — 在 `scripts/check_c6_case_shape.py` 中加入 no-call behavior class ⇒ `expect_no_call=true` 的反向约束；同时要求 `tool_call ⇒ expect_no_call=false`，并校验 `expect_no_call` 是 bool。
* [ ] **P1 / owner: Test owner** — 新增 Python checker negative fixtures：no-call class with `expect_no_call=false`、`direct_no_call`、unknown expected tool、coverage/fuzz golden re-entry、row-count shrink；纳入 `Makefile:test` 或等价 CI gate。
* [ ] **P1 / owner: C6 bench owner** — 在 Swift validation path 增加同构守护，避免 CLI/summarize/in-process caller 绕过 Python shape checker。
* [ ] **P2 / owner: C6 API owner** — 将 string-returning `C6ContractBundleFingerprint.fingerprint(...)` 降级为 legacy/internal 或重命名为 `manifestHash(...)`，避免未来调用者把 opaque hash 当 structured receipt。
* [ ] **P2 / owner: C6 API owner** — 在 `validated(manifest:)` 中拒绝 duplicate component IDs、非预期 schema version；为 `C6ContractBundleFingerprintRecord` 增加 canonical hash verification。
* [ ] **P2 / owner: Docs/bench owner** — 将 checker 输出 `external_layer_candidate_counts` 重命名为 diagnostic 语义，避免与 runtime four-layer selector 混淆。
* [ ] **P2 / owner: Docs/bench owner** — 保持 closeout 状态只到 `local-pass-pending-gptpro`；P1 吸收后仍不得宣称 C6 acceptance / external pass / candidate-comparison readiness。

---

## Boundary note

即使 P1/P2 被吸收并得到 `PASS`，本审计也只可支持 **Long-run 2 identity/shape local closeout**。下一路由仍不得进入 candidate comparison，除非：

1. retrain-C5 candidate 实际产出；
2. candidate signoff 完成；
3. 显式 run authorization 已获得。

---

## 审计元数据

* PR: `https://github.com/rayw-lab/MAformac/pull/7`
* PR number: `7`
* Repo: `rayw-lab/MAformac`
* Branch: `codex/rebuild-c6-doc-absorption-20260624`
* Audited live head / branch tip: `f6b6a15d8d898f53f4fc76783c238da3d57aacfa`
* Base SHA: `c1e7d58d281d0256d29034c1d120cefe0bf5a033`
* Scoped commits considered as they affect Long-run 2: `728137a`, `229e9b3`, `a56aa83`, `ce07a14`, `feef918`, `f6b6a15`
* Audit time: `2026-06-25` Asia/Singapore
* Model: `GPT-5.5 Pro`


















第二份

已生成 Markdown 文件：**[下载 pr_audit_7.md](sandbox:/mnt/data/pr_audit_7.md)**

# PR #7 深度代码审计简报

## PR 摘要

PR #7（`Rebuild C6 identity shape closeout`）当前为 **open / draft**，base 为 `main`，head 为 `codex/rebuild-c6-doc-absorption-20260624`，审计对象为 branch tip `f6b6a15d8d898f53f4fc76783c238da3d57aacfa`。本 PR 共 **42 个 changed files**，**+8077 / -396** 行。控制范围限定为 Long-run 2 construction-lane local closeout：Phase 4 contract bundle identity、Phase 5 explicit D-domain `behavior_class` shape migration、Phase 6 local closeout / lessons / evidence excerpt。整体风险等级：**MEDIUM**。PR 元数据和变更规模来自 connector 实读结果。

## Overall verdict

**`PASS_WITH_FIXES`**

该 verdict 只覆盖 PR body 与 `docs/project/phase0/rebuild-c6-identity-shape-gptpro-audit-request-2026-06-25.md` 所定义的本地 construction-lane closeout 范围。控制文档明确要求 verdict 只能是 `PASS` / `PASS_WITH_FIXES` / `FAIL`，并要求 findings 使用 P0/P1/P2 + file:line anchors。

这不是 C6 acceptance、不是 model-quality evaluation、不是 retrain-C5、不是 candidate comparison、不是 golden-run、不是 UIUE merge，也不是 V/S/U-PASS。控制文档和 closeout 文档都明确限制了这些 no-goals。

---

## 结论理由

* Phase 4 的结构化 `contract_bundle_fingerprint` 已落到运行与 summary receipt 形态：`schema_version / bundle_hash / component_digests` 不是只在内部 helper 中存在。`C6ContractBundleFingerprintRecord` 明确包含三项结构化字段并检查 required component digests。
* Phase 5 的 57 行 tracked JSONL 已携带五分类 `behavior_class`；decode 路径要求该字段；generator/source-truth 也开始显式传递。evidence excerpt 记录 shape checker 输出 `rows=57` 与五分类 counts。
* Phase 6 文档边界基本诚实，状态保持在 `local-pass-pending-gptpro` / `blocked-pending-gptpro`，并要求等 GPT Pro verdict 后才考虑 external pass。
* 但 source-free shape checker 仍有一个反向约束缺口：no-call behavior class 没有被强制要求 `expect_no_call == true`，可构造 `expected_tool_calls=[]` 且 `expect_no_call=false` 的 fake-green no-call row。
* `contract_bundle_fingerprint` 公共 manifest/receipt 路径未显式拒绝 duplicate component IDs；目前可能在 `Dictionary(uniqueKeysWithValues:)` 处 trap，而不是以 typed error fail closed。
* `C6BenchCase.behaviorClass` 在 Swift model/encoder 边界仍是 optional + `encodeIfPresent`，使 programmatic JSONL emission 可绕过显式字段，除非调用者另行执行 validator。
* GitHub Actions `Verify` run 在审计时仍是 `in_progress`，不能把 CI/lint/format 维度评为 clean pass。

---

## 8 维度详细评分表

|  # | 审计维度               | Verdict           | 分数 | 证据 file:line                                                                                                                                                                                        | 结论                                                                                                                                                                                                                   | 改进建议                                                                                                                                     |
| -: | ------------------ | ----------------- | -: | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
|  1 | 架构合规性              | `PASS_WITH_FIXES` |  4 | `Core/Bench/C6ContractBundleFingerprint.swift:36-61`; `Core/Bench/C6VehicleToolBench.swift:666-717`; `Tools/C6BenchCLI/main.swift:196-213`                                                          | 新增 fingerprint 结构放在 C6 bench 模块边界内，receipt 暴露结构化字段；C6EvalRun/Summary/CLI 均承接。主要架构问题是 public component manifest validation 未完全闭合 duplicate/unknown/mismatched version。                                                | 给 contract bundle validator 增加 duplicate component ID、unknown component ID、manifest_version mismatch 的显式 typed errors。                   |
|  2 | 代码质量               | `PASS_WITH_FIXES` |  3 | `scripts/check_c6_case_shape.py:91-126`; `Core/Bench/C6VehicleToolBench.swift:1288-1335`; `Core/Bench/C6ContractBundleFingerprint.swift:114-126`                                                    | 大部分实现简单清晰，但 checker 对 no-call shape 的约束不是双向；fingerprint receipt 可在 duplicate key 处 trap；behaviorClass optional 造成 encode 边界不够硬。                                                                                      | 修复 P1 checker gap；把 duplicate ID 从 runtime trap 改为 explicit validation error；将 `behaviorClass` 改成 non-optional 或编码时 fail closed。         |
|  3 | 测试覆盖               | `PASS_WITH_FIXES` |  4 | `Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift:101-126`; `Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift:798-887`; `Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift:1120-1136` | 覆盖了 tracked/generator behavior_class、五分类 taxonomy、structured fingerprint、missing component、per-run identity preservation、summary encoding。缺少 no-call inverse checker regression 与 duplicate component ID regression。 | 新增 `expect_no_call=false + no-call behavior_class + expected_tool_calls=[]` 应失败的 checker fixture；新增 duplicate component ID receipt test。 |
|  4 | 安全风险               | `PASS_WITH_FIXES` |  4 | `Tools/C6BenchCLI/main.swift:184-193`; `Core/Bench/C6ContractBundleFingerprint.swift:89-104`; `scripts/check_c6_case_shape.py:129-137`                                                              | 未发现 secret 注入、SQL injection、XSS、反序列化执行或新增网络权限面。主要安全相关风险是 supply-chain/receipt integrity 的 fail-closed 完整性不足：duplicate component ID 可能 panic 而非可审计错误。                                                                 | 对外部/人工构造 manifest 使用 typed validation error；避免 public API 输入触发 trap。                                                                     |
|  5 | 性能影响               | `PASS`            |  4 | `Core/Bench/C6ContractBundleFingerprint.swift:78-104`; `scripts/check_c6_case_shape.py:59-63`; `Core/Bench/C6VehicleToolBench.swift:364-389`                                                        | 当前规模为 57 rows + 6 个 bundle descriptors，遍历和 hashing 成本可控；未发现 N+1、hot loop、同步阻塞扩大化或大对象无界 copy。                                                                                                                         | 后续若 C6 rows 扩到大规模，shape checker 可流式处理 JSONL 并避免全量 rows list，但本 PR 不需要。                                                                   |
|  6 | 依赖与兼容性             | `PASS_WITH_FIXES` |  4 | `Makefile:28-34`; `Makefile:40-42`; `Core/Bench/C6VehicleToolBench.swift:221-233`; `Core/Bench/C6VehicleToolBench.swift:1213-1247`                                                                  | 未见新增第三方依赖或 license 面。兼容性方面，JSONL decode 现在硬要求 `behavior_class`，`C6BenchRunner` 也要求 structured fingerprint；这是 scope 内 breaking change，但需在 artifact/tooling 边界明确。                                                      | 保留 migration note；为 programmatic construction 提供 explicit initializer 或 builder，避免 silent nil behavior class。                            |
|  7 | 可读性 + 可维护性         | `PASS_WITH_FIXES` |  3 | `docs/project/phase0/rebuild-c6-identity-shape-closeout-2026-06-25.md:83-87`; `Core/Bench/C6VehicleToolBench.swift:256-279`; `scripts/check_c6_case_shape.py:36-49`                                 | 文档边界清楚；但 runtime resolver 仍保留 broad compatibility fallback，checker 还输出 diagnostic `clarify` candidate bucket，而 runtime layer 是四层 selector。这些都已被文档标注为 residual/diagnostic，但长期维护上容易产生 SSOT 混淆。                         | 将 compatibility resolver 降级为 deprecated/internal，并在下一阶段统一 diagnostic layer 与 runtime layer 命名或显式 namespace。                              |
|  8 | CI / lint / format | `PASS_WITH_FIXES` |  3 | `.github/workflows/verify.yml:25-29`; `.github/workflows/verify.yml:31-62`; `Makefile:34`; `Makefile:42`; `Makefile:57-58`                                                                          | Workflow 配置会跑 `make verify-ci` 和 `git diff --check`；Makefile 已把 `verify-c6-shape` 接入 local `verify` 与 `verify-ci`。但审计时 GitHub Actions run 仍是 `in_progress`，不能认定 CI 已通过。                                              | 等待 head `f6b6a15d8d898f53f4fc76783c238da3d57aacfa` 的 Verify run 完成；如失败，吸收失败日志后重新审计。                                                      |

---

## Findings

### P0

无 P0。

### P1-1 — Shape checker 允许 no-call behavior class 缺失 `expect_no_call=true`，存在 fake-green 直接 no-call 路径

**证据**

* `scripts/check_c6_case_shape.py:91-96`：只要求 `tool_call` 必须有非空 `expected_tool_calls`，非 tool class 不得携带 calls。源码对应逻辑显示 tool_call 与非 tool_call 的 call-list 约束，但没有 no-call class 的反向 `expect_no_call` 要求。
* `scripts/check_c6_case_shape.py:121-126`：只检查 `expect_no_call=true` 时 behavior class 必须是 no-call 类，以及 `expected_tool_calls=[]` 不能是 tool_call；没有反向检查 “no-call behavior class 必须 `expect_no_call=true`”。
* `Core/Bench/C6VehicleToolBench.swift:1288-1335`：runtime hard gate 分支以 `candidate.expectNoCall` 决定是否走 no-call precondition path、是否计 false positive、是否要求 readback。

**可构造反例**

```json
{
  "behavior_class": "refusal_no_available_tool",
  "expect_no_call": false,
  "expected_tool_calls": [],
  "expected_state_delta": {},
  "clarify_tag": "rejected",
  "readback_assertion": {"contains": []},
  "source_refs": {"risk_rule_ids": []}
}
```

该 shape 在当前 checker 下不会触发错误；runtime 中如果模型也无 tool calls，则可能形成 “expected_tool_calls == [] collapse into legal direct success” 的 fake-green。该路径正落在控制文档要求攻击的 fake-green 范围内。

**建议修复**

在 `scripts/check_c6_case_shape.py` 中增加双向约束：

```python
if behavior_class in NO_CALL_BEHAVIOR_CLASSES and expect_no_call is not True:
    errors.append(f"{case_id}: {behavior_class} requires expect_no_call=true")

if behavior_class == "tool_call" and expect_no_call is True:
    errors.append(f"{case_id}: tool_call requires expect_no_call=false")
```

并增加 regression fixture/test，覆盖 `refusal_no_available_tool / clarify_missing_slot / refusal_safety_or_policy / already_state_noop` 四类 no-call behavior class 的 inverse check。

---

### P2-1 — Contract bundle manifest 未显式拒绝 duplicate component IDs，public receipt 路径可能 trap 而非 typed fail-closed

**证据**

* `Core/Bench/C6ContractBundleFingerprint.swift:114-126`：`receipt(manifest:)` 使用 `Dictionary(uniqueKeysWithValues:)` 从 components 生成 digest map。
* `Core/Bench/C6ContractBundleFingerprint.swift:154-174`：`validated(manifest:)` 检查 digest 非空和 required IDs 是否缺失，但未检查 duplicate component IDs。
* `Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift:866-887`：测试覆盖 missing component 与 receipt missing component，但未覆盖 duplicate component ID。

**影响**

公开的 `receipt(manifest:)` / `receipt(components:)` 可以接收人工构造的 duplicate component IDs。Swift `Dictionary(uniqueKeysWithValues:)` 在 duplicate key 下会触发 runtime trap。对审计语义而言，这不是理想的 fail-closed：它不可恢复、不可分类、不可被调用方审计吸收。

**建议修复**

新增 `duplicateComponentIDs` typed error，在 `validated(manifest:)` 内排序前统计 duplicates 并 throw；新增 duplicate component regression test。

---

### P2-2 — `behaviorClass` 在 Swift construction/encoding 边界仍为 optional，可能重新产出缺字段 JSONL

**证据**

* `Core/Bench/C6VehicleToolBench.swift:171`：`C6BenchCase.behaviorClass` 是 optional。
* `Core/Bench/C6VehicleToolBench.swift:202`：public init 默认 `behaviorClass: VehicleToolBehaviorClass? = nil`。
* `Core/Bench/C6VehicleToolBench.swift:233`：decode 端已强制要求 `behavior_class`。
* `Core/Bench/C6VehicleToolBench.swift:250`：encode 端使用 `encodeIfPresent`，nil 时会省略字段。
* `Core/Bench/C6VehicleToolBench.swift:322-330`：`C6DatasetCodec.encodeJSONL` 直接 encode，没有自身 fail-closed validation。

**影响**

PR 已经把 tracked JSONL、decode、generator 路径改成 explicit shape；但 Swift API 仍允许程序化构造 nil behaviorClass 并 encode 成缺少 `behavior_class` 的 JSONL。这会让后续工具或测试夹具不小心重引入旧 shape。

**建议修复**

将 `behaviorClass` 改为 non-optional，并移除 initializer 默认 nil；或在 `encode(to:)` 遇到 nil 时 throw `EncodingError.invalidValue`；或新增 `C6DatasetCodec.encodeValidatedJSONL(...)` 并废弃裸 `encodeJSONL`。

---

### P2-3 — Head-bound CI 尚未完成，不能把 CI/lint/format 维度评为 clean pass

**证据**

* `.github/workflows/verify.yml:25-29`：CI 会执行 `make verify-ci` 与 `git diff --check`。
* `.github/workflows/verify.yml:31-62`：CI 会写入并上传 head-bound receipt。
* `Makefile:42`：`verify-ci` 包含 `verify-c6-shape`、`diff`、`test`、`swift-test`。
* `Makefile:57-58`：`verify-c6-shape` 运行 `scripts/check_c6_case_shape.py contracts/c6-bench-cases.jsonl generated/D_domain.tools.demo.json`。
* GitHub Actions connector 状态：审计时 run `28141519696` / job `verify` 仍为 `in_progress`，`Run source-free verification gates` 仍在运行，后续 whitespace/receipt/upload step pending。

**建议修复**

等待 CI 完成；如果失败，按日志修复后重新触发；如果成功，将 run ID / artifact hash 写入后续 evidence 或 review note。

---

## 控制范围逐项核对

### Phase 4 — Contract bundle identity

| 控制问题                                                                                  | Verdict           | 说明                                                                                                                            |
| ------------------------------------------------------------------------------------- | ----------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `contract_bundle_fingerprint` 是否是 manifest-visible receipt，而非 opaque hash？            | `PASS_WITH_FIXES` | receipt 结构存在并出现在 eval/summary/markdown。P2 duplicate validation 仍需硬化。                                                          |
| per-run identity fields 是否仍独立保留？                                                      | `PASS`            | `prompt_hash / tool_output_digest / contract_digest / model_artifact_digest / tokenizer_digest / lora_adapter_digest` 均保留并测试。 |
| manifest / receipt / fingerprint public entry points 是否 missing-required fail closed？ | `PASS_WITH_FIXES` | missing required component 已 fail closed；duplicate component ID 未显式 fail closed。                                              |

### Phase 5 — Explicit D-domain `behavior_class` shape

| 控制问题                                                 | Verdict           | 说明                                                                                                   |
| ---------------------------------------------------- | ----------------- | ---------------------------------------------------------------------------------------------------- |
| 57 tracked rows 是否携带五分类 `behavior_class`？            | `PASS`            | evidence 显示 rows=57，五分类 counts 为 `34/9/8/5/1`。                                                       |
| checker 是否防 fake-green？                              | `PASS_WITH_FIXES` | 已覆盖 no direct_no_call、noop mechanical proof、coverage not golden；但 P1 反向 no-call/expect_no_call 约束缺失。 |
| JSONL / decode / generator / validation 是否 explicit？ | `PASS_WITH_FIXES` | decode/generator/validation 已接入；encode/programmatic construction 仍 optional。                         |
| `verify-c6-shape` 是否进入 local `verify`？               | `PASS`            | local `verify` 明确包含 `verify-c6-shape`。                                                               |

### Phase 6 — Closeout / lessons / evidence honesty

| 控制问题                                         | Verdict           | 说明                                                         |
| -------------------------------------------- | ----------------- | ---------------------------------------------------------- |
| status 是否 capped at local pending？           | `PASS`            | 明确 `local-pass-pending-gptpro` 与 `blocked-pending-gptpro`。 |
| 是否避免声称 C6 acceptance / candidate comparison？ | `PASS`            | no-goals 清晰。                                               |
| 外部 auditor 是否可从 tracked docs 验证本地工作？         | `PASS_WITH_FIXES` | tracked evidence 足以说明本地 gates；但 head CI 仍未完成。              |

---

## 具体待改 punch list

* [ ] **Owner: Bench/Contracts** — **P1** — 在 `scripts/check_c6_case_shape.py` 增加 no-call behavior class ⇒ `expect_no_call=true` 的反向约束，并增加 regression fixture。
* [ ] **Owner: Bench/Contracts** — **P1** — 增加 `tool_call` ⇒ `expect_no_call=false` 的显式检查，避免混合 shape 靠 runtime 细节决定。
* [ ] **Owner: Bench/Contracts** — **P2** — 在 `C6ContractBundleFingerprint.validated(manifest:)` 中拒绝 duplicate component IDs，使用 typed error，不允许 `Dictionary(uniqueKeysWithValues:)` trap。
* [ ] **Owner: Bench/Contracts** — **P2** — 为 duplicate component ID 增加单元测试；可同时覆盖 unknown component ID / manifest_version mismatch。
* [ ] **Owner: Bench Runtime** — **P2** — 将 `C6BenchCase.behaviorClass` 改为 non-optional，或在 `encode(to:)` / `encodeJSONL` 上 fail closed，防止重新产出缺字段 JSONL。
* [ ] **Owner: CI** — **P2** — 等待 head `f6b6a15d8d898f53f4fc76783c238da3d57aacfa` 的 GitHub Actions Verify run 完成；若失败，吸收日志并重新触发。
* [ ] **Owner: Docs/Release** — **P2** — 保持 closeout wording 为 `local-pass-pending-gptpro`，不要把本 verdict 写成 C6 acceptance、external pass、candidate-comparison readiness 或 V/S/U-PASS。

---

## Route guidance

* 当前可接受为：**本地 closeout 方向基本正确，但需吸收 P1 + P2 后才能 clean PASS**。
* 不应基于本报告进入 candidate comparison。
* 即使修复后得到 `PASS`，仍需满足控制文档中的后续 route constraints：retrain-C5 candidate produced、candidate signoff completed、explicit run authorization granted。
* CI 完成前，不应声称 head-bound CI proof complete。

## 审计元数据

| 字段                    | 值                                                                                            |
| --------------------- | -------------------------------------------------------------------------------------------- |
| PR                    | `https://github.com/rayw-lab/MAformac/pull/7`                                                |
| PR number             | `7`                                                                                          |
| Audit scope source    | PR body + `docs/project/phase0/rebuild-c6-identity-shape-gptpro-audit-request-2026-06-25.md` |
| Audited commit SHA    | `f6b6a15d8d898f53f4fc76783c238da3d57aacfa`                                                   |
| Base SHA              | `c1e7d58d281d0256d29034c1d120cefe0bf5a033`                                                   |
| Changed files         | `42`                                                                                         |
| Additions / deletions | `+8077 / -396`                                                                               |
| Overall risk          | `MEDIUM`                                                                                     |
| Overall verdict       | `PASS_WITH_FIXES`                                                                            |
| Audit time            | `2026-06-25 Asia/Singapore`                                                                  |
| Model                 | `GPT-5.5 Pro`                                                                                |

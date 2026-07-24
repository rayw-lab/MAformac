## Why

Customer text ingress (T04a) 已给出 stable session/turn/event identity 与 side-effect-free typed rejection，但 stale session/turn/event 与 correlation-mismatch 的 typed 拒识仍标 `BLOCKED_WAIT_W6_TYPES`（原文见 `openspec/changes/add-t04a-customer-ingress/specs/frontstage-admission/spec.md:25-41`；tasks 挂起项见 `openspec/changes/add-t04a-customer-ingress/tasks.md:5-6`）。W6 typed route/model contract 补齐这段 seam，用不可拆的 closed types 表达「客户文字入口 → typed route 决策 / trace identity」，让 T04a、W5a follow-up 与 W7/W9 consumer 有单一 compile-time authority 可 import，避免第二份 payload / 平行 route struct / 二义 stale bucket。

本 change 只覆盖 W6 B1a 段（typed 面 + fail-closed 契约 + fixture + local checker + targeted tests）；W6 B1b（Makefile/shared checker/App composition wiring）与 W6-2（alias / L1 oracle / policy）不在本 change scope。

### 必须严格对齐的活跃 SSOT

- **契约 SSOT = jsonl，非 yaml。** 唯一契约源见 `CLAUDE.md:73` 表行「唯一契约源」+ `contracts/semantic-function-contract.jsonl`（3990 行全集，头两行样本活核）。字段命名必须严格 rebase jsonl：`intent / service / ds_protocol{intent, semantic{slots}, service} / clarify_tag / fc_flags{fuzzy, free} / exec_tier / value{ref, direct, offset, type} / action_primitive / action_code / slot / slot_keys / range / range_class / second_turn_refs`。禁近义词字段。
- **范式翻案：model-visible surface = D-domain 具名工具（`intent==tool_name`）；canonical IR = `device × action_primitive × value`。** 权威段 = `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:10-27`（§1 + §2 三层模型表）+ `docs/baseline-semantic-protocol-2026-06-19.md:3-8`（surface 翻案 banner）。generic frame `tool_call_frame{device,action,value}` 已 supersede，W6 typed route 结果只挂 D-domain 具名 tool name（对齐 `Core/Contracts/DDomainMountedToolCatalog.swift:12-14` mountedToolNames），禁自造并行第二套工具名注册表。
- **三层路由分层。** 见 `CLAUDE.md:98` §「三层路由」+ `docs/srd-three-layer-intent-routing.md`。W6 typed route 里 `clarifyTag` 值域严格对齐 jsonl `clarify_tag`：`explicit`（L1 精确 → 规则快路）/ `implicit`（L2-L4 模糊 → 慢路 Qwen+LoRA 单跳）。L5 多阶不在本 change。
- **value 四件套。** 定义见 `docs/baseline-semantic-protocol-2026-06-19.md:53-57` §2②：`ref ∈ {"", "CUR", "ZERO", "MAX"} / direct ∈ {"", "+", "-"} / offset` 数值或经验枚举 / `type ∈ {"", "SPOT", "PERCENT", "EXP"}`。字段名严禁改成 `reference/direction/magnitude/kind`；typed 契约直接复用现有 `Core/Contracts/ContractLookups.swift:3-15` 的 `ContractValue`。
- **risk-policy R0-R3。** 见 `CLAUDE.md:109` D37 amend「R0-R3 收 ASIL/forbidden + clarifyTag」+ `contracts/risk-policy.yaml`。error enum 至少覆盖：`unmountedName / outOfCatalog / oldGeneration / payloadInvalid / slotMissing / valueOutOfRange / riskR0Forbidden / riskR1PreconditionUnmet / clarifyRequired`。
- **意图口径终盘 = 562 / 1538 / 3990。** 见 `CLAUDE.md:184` 段末「562=intent 终盘口径，禁止再用旧 534/2086 系列」+ `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:124-127` A1/A2/A3。contract、fixture、schema `enum` 描述禁用旧 534/2086/1004/1904 口径。
- **fc_flags → exec_tier 派生禁第二 SSOT。** 见 `docs/baseline-semantic-protocol-2026-06-19.md:74` §2⑥「L1/L2/L3 是路由层级(执行分层)非表列：由 col30/31 FC 标记派生」。W6 typed route 消费 jsonl 已有 `exec_tier` 字段，不自造第二份「fc_flags→exec_tier」映射表。

## What Changes

- 新建 capability spec `typed-route-contract`（首次 ADDED）：
  - **三轴独立 closed types**：`exec_tier`（`L1`..`L5`，jsonl 已有；不自造派生表）/ `outcome`（`candidate`/`clarify`/`reject`/`fallback`；独立于 exec_tier）/ `clarify_tag`（`explicit`/`implicit`；对齐 jsonl，独立轴）。三轴不可互相坍缩。
  - `RouteSubject` identity 面：`schema_version / turn_id / trace_id / route_schema / source_identity{matrix_source_sha256, runtime_contract_bundle_digest} / source_revision-or-stale-marker / contract_digest`；session/event/sequence 不入本 ontology（留 T04a/W5a pending-correlation record）。
  - `RouteTrace` 面：`schema_version / turn_id / trace_id / exec_tier fact / outcome fact / clarify_tag fact / rejection_reason fact? / redaction_policy_id / stale_marker / trace_digest`；禁 raw prompt / raw response / PII 落入 proof carrier。
  - `RouteResult` 面（最小字段）：`route_schema / turn_id / exec_tier / outcome / clarify_tag / service / action_candidate? / trace_digest / rejection_reason?`；`action_candidate` 不构成 action proof（承接 `docs/commander-log/decisions.md` D-137 `actionDemoProven=0/120`）。
  - `ActionCandidate` 字段严格对齐 jsonl：`intent / service ∈ {airControl, carControl, cmd} / mounted_tool_name / action_primitive / action_code / device / slot / slot_keys / value{ref,direct,offset,type}`。`mounted_tool_name` 必须在 `Core/Contracts/DDomainMountedToolCatalog.mountedToolNames` 内，否则 `reject.unmountedName`。
  - 拒识优先序：`safety(R0) → policy(R0 amend) → rejected_nonsense_or_chat → unsupported_no_available_tool_or_domain(R1)`；`clarify(R2)` 独立于 rejection 走 `outcome=clarify`。
  - Total validator + canonical JSON encoding + canonical digest（load-bearing 字段变化 digest 必变）+ unknown enum / missing required / illegal combination（如 `outcome==candidate` 却无 `action_candidate`）全部 fail-closed。
- 新增 `contracts/schemas/typed-route-contract.v1.schema.json` 描述 canonical 载荷（用于 fixture 校验）。
- 新增 `contracts/fixtures/typed-route-contract/`：正例 fixture ≥3（分别取自 jsonl 的 airControl / carControl / cmd 真样本 `contract_row_id`，禁凭空造）+ 负例 fixture 覆盖 unknown enum / missing field / illegal combination / stale marker / digest mismatch / unmounted tool。
- 新增 `Core/Contracts/RouteContract.swift`、`Core/Contracts/RouteResult.swift`、`Core/Contracts/RouteError.swift`（三文件按 coordinator 补料 S7 建议命名；不改现有 `ToolCallFrame` / `DDomainMountedToolCatalog` / `ContractLookups` / `DemoAuthorityIdentity` / 任何 `*.generated.swift`）。
- 新增 targeted Swift/Python tests：
  - `Tests/MAformacCoreTests/RouteContractTests.swift`：Codable round-trip、三轴独立、正负矩阵、canonical digest、mounted tool name 校验、error enum 全覆盖、拒识优先序。
  - `Tests/python/contracts/test_route_fixtures.py`：JSON schema 校验、fixture ↔ jsonl 字段一致（`contract_row_id` 命中源行，`value` 四件套字段名一致）、正负 fixture rc0/rc≠0。

## Non-goals

- 不接入 `App/**`、`FrontstageRuntimeComposition`、`DemoRuntimeSessionRunner.run` 或任何 production consumer。
- 不改 `Makefile`、`Tests/test_closure_work_packages.py`、共享 closure checker/registry/index、`FrontstageRouteReceipt` schema / checker、int-v5b receipt。
- 不实现 W5a `FrontstageRouteResultConsumer`、T04a 四类 typed rejection 或翻 `openspec/changes/add-t04a-customer-ingress/tasks.md:6` 的 `BLOCKED_WAIT_W6_TYPES`。
- 不实现 W6-2 canonical alias / L1 normalization oracle / L1..L5 actual policy / fast-slow selection。
- 不触碰 `DemoVehicleStateStore.replaceCells`、`Core/Contracts/*.generated.swift`、`Core/Contracts/ToolContractCompiler.swift`、`Core/Contracts/DDomainMountedToolCatalog.swift`。
- 不新增 iOS UI target（`CLAUDE.md:94` 已定 iOS 冻结）。
- 不宣称 W6 package DONE、W5c ready、actionDemoProven > 0、operator-pass、V-PASS、C6 acceptance、mobile/true-device/live proof。

## Proof cap

Local / unit / integration（typed contract construction + Codable round-trip + canonical digest + validator 正负矩阵 + fixture 消费）。App build proof、production consumer wiring、Runtime/operator ceremony、W6 package receipt 全部留给 B1b/后续 owner，不在本 change 提前签绿。

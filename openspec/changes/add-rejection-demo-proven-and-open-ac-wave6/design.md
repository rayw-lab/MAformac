## Context

Wave5 已将 `actionDemoProven` 翻到 1/120（仅 matrix_id=4）。当前系统将 rejection（m5/m6，`fast_path_no_match_fallback`）与 execution（m1-m4）混用同一计数器，导致覆盖语义污染风险。

**Current State:**
- `demo-capability-matrix.json` 仅有 `actionDemoProven` 字段，无 rejection 专用计数
- matrix_id=1 (`open_ac`) admission 已有「打开空调」路径（`DemoSliceAdmissionCatalog.swift:178-180`），但 catalog unmounted、matrix `mounted_status="unmounted"`
- matrix_id=5/6（委婉/能否问句 rejection）无独立 proven 字段，易误计入 execution 覆盖
- `close_ac` 在 `DDomainMountedToolCatalog` 已挂载但 matrix 缺映射格（漂移）

**Constraints:**
- **PHASE2_CODING_GATED** 仍在；禁后三族（window/ambient/seat）；禁训练
- Mock-only：状态变更仅影响 mock UI，不接入 CAN/ECU/OBD
- Agree-before-build：OpenSpec artifacts apply-ready 前禁止实现翻格
- BF-8 人审：execution（m1）与 rejection（m5+m6）必须分账，禁复用 matrix_id=4 receipt
- Verify-green-before-flip：remote Actions 绿后方可 push/flip proven

**Stakeholders:**
- 指挥官（磊哥）：最终 BF-8 授权、分账决策、stopline 守护
- Opus/Gemini：OpenSpec artifacts、schema/checker、catalog/matrix materialize
- Remote CI：verify-c1-matrix gate

---

## Goals / Non-Goals

**Goals:**

1. **Rejection 分账**：新增 `rejectionDemoProven` 机器字段，镜像 `actionDemoProven` 形状，仅允许 `primary_class=fast_path_no_match_fallback` 物质化；checker 拒绝将 rejection 格写入 `actionDemoProven`
2. **m5+m6 联合 BF-8 口径**：m5（委婉）+ m6（能否问句）作为同一 rejection 能力的两 register 表面，单次 BF-8 可同时授权 `matrix_ids=[5,6]`
3. **open_ac 局部解冻**：mount matrix_id=1，更新 catalog/matrix/admission/readback 合同，独立 BF-8 `matrix_ids=[1]` 后翻 `actionDemoProven`
4. **门禁清晰化**：catalog mount、matrix materialize、admission 路径、scoped readback probe、BF-8 receipt 五门分离且可机械验证

**Non-Goals:**

- **不翻 m5/m6 actionDemoProven**：本 change 不执行 rejection BF-8 人审，仅落字段与合同
- **不翻 M5 actionDemoProven**：HOLD 至 rejection BF-8（E2）完成
- **不实现 close_ac 主路径**：仅允许 matrix 缺格设计附录，不抢 m1 主路径
- **不碰后三族**：window/ambient/seat 保持 candidate-only，不演示/合并/proven
- **不推进训练**：LoRA/dataset 轨道不在本 change 范围
- **非真车控**：仅 mock UI state + readback，不接入 CAN/ECU

---

## Decisions

### D1: `rejectionDemoProven` 字段形状与 `actionDemoProven` 镜像

**Decision:** `demo-capability-matrix.json` schema 增补 `rejectionDemoProven: boolean`（默认 `false`），与 `actionDemoProven` 并列但隔离。

**Rationale:**
- 镜像形状降低 checker/materialize 复杂度（复用 scoped BF-8 逻辑）
- 字段级隔离防止推导混淆：`actionDemoProven` 仅从 execution BF-8 推导，`rejectionDemoProven` 仅从 rejection BF-8 推导
- 机器可检：`check_capability_matrix.py` 可硬拒把 `primary_class=fast_path_no_match_fallback` 的格写入 `actionDemoProven=true`

**Alternatives considered:**
- A: 单字段 `demoProven` + 枚举科目（execution|rejection）→ 放弃：推导逻辑需同时检查科目与 primary_class，复杂度高且易漏
- B: 无独立字段，仅靠 BF-8 receipt 注解 → 放弃：无法在 matrix JSON 直观展示 rejection 覆盖，无 static checker 支持

### D2: m5+m6 为同一 rejection 能力的两 register 表面

**Decision:** m5（委婉：「有点冷」）与 m6（能否问句：「能调到 24 度吗」）共享 `representative_tool=adjust_ac_temperature_to_number`、`primary_class=fast_path_no_match_fallback`、`reason_kind=not_available_in_demo`，单次 BF-8 可同时授权 `matrix_ids=[5,6]`。

**Rationale:**
- 语义一致：两者都是对同一底层能力（数值调温）的 fail-closed rejection，utterance 差异仅是 register 表面
- 减少 BF-8 人审仪式成本：一次授权 `[5,6]`，无需两次独立人审
- 与 Grill R1 Q2 locked 决策对齐：「m5+m6 同一次 BF-8」

**Alternatives considered:**
- A: m5/m6 分别独立 BF-8 → 放弃：增加人审仪式成本，且语义上两者无差异
- B: 仅 mount m5 或 m6 之一 → 放弃：两种 utterance 都是常见客户问法，单覆盖不足以演示 fail-closed 鲁棒性

### D3: open_ac 三门顺序（catalog → manifest → readback probe）

**Decision:** 
1. **Catalog 门**：`DDomainMountedToolCatalog.swift` 加入 `"open_ac"`
2. **Manifest 门**：`demo-capability-matrix.json` matrix_id=1 改 `mounted_status: "mounted"`、`mounted_or_approved_action.observed: true`、basis 注明物质化来源
3. **Readback probe 门**：e2e 测试「打开空调」→ accepted tool + state delta + readback 硬断言

顺序强制：catalog 先于 manifest（manifest 物质化脚本依赖 catalog 集合），manifest 先于 readback（probe 依赖 admission 路径 + 预期 state delta）。

**Rationale:**
- **单向数据流**：catalog（源码）→ manifest（物质化）→ readback（runtime 验证），无循环依赖
- **Fail-fast**：catalog unmounted 时 manifest 物质化脚本应报错，避免手改 generated 假绿
- **契约一致性**：admission `DemoSliceAdmissionCatalog.swift:178-180` 已有「打开空调」→ `powerOnAdmission` 路径，readback probe 可直接复用

**Alternatives considered:**
- A: manifest 先于 catalog → 放弃：manifest 是 generated，不应手改抢跑
- B: readback probe 与 catalog 并行 → 放弃：probe 需 admission 路径已存在，catalog unmounted 时 probe 会误报

### D4: close_ac 设计附录（design-only），不实现

**Decision:** `close_ac` matrix 缺格以 design appendix 或 run-root note 记录补格提案（matrix_ids 映射、admission 路径、readback 合同），但**不在本 change 实现**，不翻 proven。

**Rationale:**
- **主路径聚焦**：m1 `open_ac` 是下一执行的最低成本候选（catalog 缺、manifest unmounted、admission 已有），优先级高于 `close_ac`
- **防漂移扩散**：`close_ac` catalog 已挂载但 matrix 缺格，属 Phase1 遗留漂移；补格需修 schema/checker/materialize 全链，成本中等
- **与 Grill R1 Q4 对齐**：「close_ac 补格设计不抢主路径」

**Alternatives considered:**
- A: 同步实现 close_ac → 放弃：分散资源，且 close_ac 无 BF-8 urgency
- B: 完全不记录 close_ac 缺格 → 放弃：漂移若不记录，后续 Phase1 执行格规划会重复发现

### D5: BF-8 分账（execution 独立 receipt，rejection 独立 receipt）

**Decision:** 
- m1 execution BF-8：独立 receipt `matrix_ids=[1]`，`subject=open_ac execution`，翻 `actionDemoProven`
- m5+m6 rejection BF-8（后置）：独立 receipt `matrix_ids=[5,6]`，`subject=rejection fail-closed`，翻 `rejectionDemoProven`
- **禁止**：复用 matrix_id=4 receipt 翻 m1/m5/m6

**Rationale:**
- **语义隔离**：execution 与 rejection 是不同产品能力维度，混用 receipt 会污染覆盖计数
- **Traceability**：独立 receipt 可追溯每次 BF-8 授权的 matrix_ids、primary_class、failure mode
- **与 Wave5 一致**：Wave5 m4 execution 有独立 receipt，本 change 延续同一分账规则

**Alternatives considered:**
- A: 单 receipt 同时授权 execution + rejection → 放弃：无法区分科目，checker 无法验证
- B: 无 receipt，仅 manual flip matrix JSON → 放弃：无 audit trail，违反 BF-8 governance

### D6: OpenSpec artifacts apply-ready 前禁止实现翻格

**Decision:** `W6-C1/C2`（schema/checker、catalog/matrix materialize）不得开工直至 `W6-A1/A2`（proposal/design/tasks）OpenSpec `status=apply-ready` 或磊哥显式 waive。

**Rationale:**
- **Agree-before-build**：OpenSpec artifacts 是行为契约；实现前先对齐口径，避免代码/契约漂移
- **与 FROZEN 表对齐**：`W6-C1` 依赖「A1 批」，`W6-C2` 依赖「A2 批」
- **Fail-fast governance**：apply-ready 门禁由 `openspec status` 机械检查，无需人工判断

**Alternatives considered:**
- A: artifacts 与实现并行 → 放弃：易产生口径/代码不一致，增加返工成本
- B: artifacts 仅作文档，不作门禁 → 放弃：与 MAformac `CLAUDE.md` 的 agree-before-build 原则冲突

---

## Risks / Trade-offs

### R1: rejection utterance 覆盖不足 → 误判 fail-closed

**Risk:** m5（委婉）与 m6（能否问句）的 admission 捕获逻辑若不完整，可能误把 rejection utterance 路由到 execution 路径或回退到通用 LLM fallback。

**Mitigation:**
- `W6-D1`（rejection utterance 锁表 + readback 合同）后置但口径先锁：在 OpenSpec design 中明确委婉表达（「有点冷」/「太热了」）与能否问句（「能调吗」/「可以开到 24 度吗」）的 admission pattern
- Readback probe 硬断言：rejection utterance 不得产生 state delta，TTS/readback 必须包含「当前演示不支持」等 fail-closed 话术
- 测试覆盖：e2e 测试至少包含 3 个委婉 + 3 个能否问句样本，验证无误判

### R2: catalog/manifest 不一致 → 假绿或假红

**Risk:** 若 `DDomainMountedToolCatalog` 已加入 `open_ac` 但 manifest 物质化脚本未运行，或手改 `demo-capability-matrix.json` 绕过脚本，catalog 与 manifest 会漂移。

**Mitigation:**
- **W6-C2 禁手改 generated**：manifest 物质化必须通过脚本，禁直接编辑 JSON
- **Verify gate**：`make verify-c1-matrix` 或等价 checker 验证 catalog ⊆ manifest mounted tools
- **CI binding**：remote Actions `verify-c1-matrix` 绿后方可 merge/push

### R3: m5/m6 rejection 与 m1 execution 混账 → 覆盖语义污染

**Risk:** 若 checker 未完整实现 `rejectionDemoProven` 隔离，或 BF-8 receipt 误复用，m5/m6 可能被计入 `actionDemoProven`，导致「1/120 execution」虚高。

**Mitigation:**
- **Schema 强制**：`demo-capability-matrix.json` schema 声明 `actionDemoProven` 与 `rejectionDemoProven` 互斥于同一 matrix_id（除非 matrix_id 同时支持 execution 与 rejection，当前 Phase1 AC 不存在此情况）
- **Checker 硬拒**：`check_capability_matrix.py` 检查 `primary_class=fast_path_no_match_fallback` 的格若 `actionDemoProven=true` 则报错
- **BF-8 receipt traceability**：每次 flip proven 必须附带 receipt path，receipt 声明 `matrix_ids` + `subject`（execution|rejection）

### R4: close_ac 漂移未修复 → Phase1 后续规划混乱

**Risk:** `close_ac` catalog 已挂载但 matrix 缺格；若本 change 仅记录不修复，Phase1 后续执行格规划可能重复发现或误用 catalog 状态。

**Mitigation:**
- **Design appendix 记录**：本 change design.md 或 run-root note 明确记录 `close_ac` 补格提案（matrix_ids 映射、admission 入口、readback 合同），作为 Phase1 后续 Wave 的输入
- **No impact on m1 path**：`close_ac` 设计附录不堵 m1 主路径，不产生依赖环
- **Stopline hold**：FROZEN 表 `W6-B1` 明确「不实现直至 A1 齐」，防提前实现

### R5: 后三族意外解禁 → 违反 stopline

**Risk:** 若 catalog/admission 修改时误加入 window/ambient/seat 相关 tool，或 matrix materialize 脚本误扫后三族，违反 PHASE2_CODING_GATED。

**Mitigation:**
- **W6-A2 禁碰后三族**：OpenSpec design 明确 scope 仅 Phase1 AC（open_ac/close_ac/adjust_ac_*），不涉及 window/ambient/seat
- **Checker whitelist**：`DDomainMountedToolCatalog` 仅允许 Phase1 AC tool names，后三族保持在 `personaAvoidListToolNames` 或 candidate-only
- **Human review gate**：若 catalog 修改涉及非 AC tool，触发 auto-pass policy「后三族解禁」人审

---

## Migration Plan

### Phase 1: OpenSpec artifacts (W6-A0/A1/A2)

1. **Grill 冻结**：FROZEN 表 + RATIFIED + auto-pass policy 落盘（已完成）
2. **OpenSpec propose**：proposal.md（已完成）、design.md（本文件）、tasks.md（待生成）
3. **Gate check**：`openspec status --change add-rejection-demo-proven-and-open-ac-wave6` 确认 `apply-ready`

### Phase 2: Schema & checker (W6-C1)

1. `contracts/demo-capability-matrix.json` schema 增补 `rejectionDemoProven: boolean`
2. `Tools/checks/check_capability_matrix.py` 增补规则：
   - 禁 `primary_class=fast_path_no_match_fallback` + `actionDemoProven=true`
   - 强制 `rejectionDemoProven` 仅用于 rejection 格
3. 单元测试：`test_check_capability_matrix.py` 覆盖分账规则
4. Local verify：`make verify-c1-matrix` 或等价子集绿

### Phase 3: Catalog & manifest (W6-C2)

1. `Core/Contracts/DDomainMountedToolCatalog.swift` 加入 `"open_ac"`
2. 运行 manifest 物质化脚本（或手动更新 `demo-capability-matrix.json` matrix_id=1 `mounted_status="mounted"`、basis 注明来源）
3. **禁手改 generated**：若 manifest 是脚本生成，禁直接编辑 JSON
4. Verify gate：confirm catalog ⊆ manifest mounted tools

### Phase 4: Readback probe (W6-C3)

1. e2e 测试「打开空调」：
   - Input utterance：「打开空调」
   - Expected: admission accepts、tool=`open_ac`、state delta (AC on)、readback 包含「已打开空调」
2. Readback 硬断言绿（本机）
3. 相关子集 `make` target 绿

### Phase 5: BF-8 execution (W6-E1)

1. **前置条件**：W6-C3 绿 + remote Verify 绿 @ tip
2. 磊哥 BF-8 人审仪式：`matrix_ids=[1]`、`subject=open_ac execution`
3. 生成独立 receipt（不复用 matrix_id=4 receipt）
4. Flip `demo-capability-matrix.json` matrix_id=1 `actionDemoProven=true`
5. Commit + push（带 receipt path）

### Phase 6: Remote Verify bind (W6-F1)

1. Push tip 后等待 remote Actions `verify-c1-matrix` 绿
2. 生成 VFY receipt 绑定 commit SHA + Actions run URL
3. Closeout 文档记录 m1 execution 完成

### Rollback Strategy

- **Pre-BF-8**：任意 Phase 1-4 失败可直接 revert commits，无 proven 状态污染
- **Post-BF-8**：若 m1 execution BF-8 后发现 readback 错误，需 hotfix + 重新 BF-8（不可直接 revert proven flip，需人审决策）
- **Rejection 侧后置**：W6-D1/E2（rejection utterance + BF-8）在 m1 完成后独立推进，不堵 rollback

---

## Open Questions

### Q1: close_ac matrix_ids 映射（design-only，不实现）

**Question:** `close_ac` 若后续实现，应映射到哪个 matrix_id？是否复用某个空闲格，还是扩充 matrix 行数？

**Status:** 留给 Phase1 后续 Wave；本 change 仅在 design appendix 或 run-root note 记录选项，不做最终决策。

### Q2: rejection utterance 锁表形式

**Question:** W6-D1「rejection utterance 锁表」是写入 `contracts/state-cells.yaml` 新段落，还是单独 JSON schema，还是直接在 admission code comment？

**Status:** 待 W6-D1 切片时决策；建议优先 `state-cells.yaml` 或旁路 schema（与 `semantic-function-contract.jsonl` 并列），避免仅靠 code comment 无机械检查。

### Q3: manifest 物质化脚本路径

**Question:** `demo-capability-matrix.json` 的 `mounted_status` 与 basis 是否由脚本自动生成？若是，脚本路径与触发条件是什么？

**Status:** 待 W6-C2 调查；若无脚本，需在 tasks.md 明确「手动更新 manifest + 注明 basis + 禁后续手改」。

### Q4: BF-8 receipt schema 是否需 `subject` 字段

**Question:** 当前 BF-8 receipt 是否已有 `subject`（execution|rejection）或等价字段？若无，是否需在本 change 扩充 receipt schema？

**Status:** 待 W6-E1 前确认；若 receipt schema 无 `subject`，需在 tasks.md 增补「扩充 receipt schema + 更新 governance checker」子任务。
